
obj/user/sh.debug:     file format elf32-i386


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
  80002c:	e8 87 09 00 00       	call   8009b8 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800034 <_gettoken>:
#define WHITESPACE " \t\r\n"
#define SYMBOLS "<|>&;()"

int
_gettoken(char *s, char **p1, char **p2)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	57                   	push   %edi
  800038:	56                   	push   %esi
  800039:	53                   	push   %ebx
  80003a:	83 ec 0c             	sub    $0xc,%esp
  80003d:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800040:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int t;

	if (s == 0) {
  800043:	85 db                	test   %ebx,%ebx
  800045:	75 22                	jne    800069 <_gettoken+0x35>
		if (debug > 1)
  800047:	83 3d 00 50 80 00 01 	cmpl   $0x1,0x805000
  80004e:	0f 8e 30 01 00 00    	jle    800184 <_gettoken+0x150>
			cprintf("GETTOKEN NULL\n");
  800054:	83 ec 0c             	sub    $0xc,%esp
  800057:	68 a0 35 80 00       	push   $0x8035a0
  80005c:	e8 97 0a 00 00       	call   800af8 <cprintf>
  800061:	83 c4 10             	add    $0x10,%esp
  800064:	e9 2e 01 00 00       	jmp    800197 <_gettoken+0x163>
		return 0;
	}

	if (debug > 1)
  800069:	83 3d 00 50 80 00 01 	cmpl   $0x1,0x805000
  800070:	7e 11                	jle    800083 <_gettoken+0x4f>
		cprintf("GETTOKEN: %s\n", s);
  800072:	83 ec 08             	sub    $0x8,%esp
  800075:	53                   	push   %ebx
  800076:	68 af 35 80 00       	push   $0x8035af
  80007b:	e8 78 0a 00 00       	call   800af8 <cprintf>
  800080:	83 c4 10             	add    $0x10,%esp

	*p1 = 0;
  800083:	c7 07 00 00 00 00    	movl   $0x0,(%edi)
	*p2 = 0;
  800089:	8b 45 10             	mov    0x10(%ebp),%eax
  80008c:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

	while (strchr(WHITESPACE, *s))
  800092:	eb 04                	jmp    800098 <_gettoken+0x64>
		*s++ = 0;
  800094:	c6 03 00             	movb   $0x0,(%ebx)
  800097:	43                   	inc    %ebx
		cprintf("GETTOKEN: %s\n", s);

	*p1 = 0;
	*p2 = 0;

	while (strchr(WHITESPACE, *s))
  800098:	83 ec 08             	sub    $0x8,%esp
  80009b:	0f be 03             	movsbl (%ebx),%eax
  80009e:	50                   	push   %eax
  80009f:	68 bd 35 80 00       	push   $0x8035bd
  8000a4:	e8 10 12 00 00       	call   8012b9 <strchr>
  8000a9:	83 c4 10             	add    $0x10,%esp
  8000ac:	85 c0                	test   %eax,%eax
  8000ae:	75 e4                	jne    800094 <_gettoken+0x60>
  8000b0:	89 de                	mov    %ebx,%esi
		*s++ = 0;
	if (*s == 0) {
  8000b2:	8a 03                	mov    (%ebx),%al
  8000b4:	84 c0                	test   %al,%al
  8000b6:	75 27                	jne    8000df <_gettoken+0xab>
		if (debug > 1)
  8000b8:	83 3d 00 50 80 00 01 	cmpl   $0x1,0x805000
  8000bf:	0f 8e c6 00 00 00    	jle    80018b <_gettoken+0x157>
			cprintf("EOL\n");
  8000c5:	83 ec 0c             	sub    $0xc,%esp
  8000c8:	68 c2 35 80 00       	push   $0x8035c2
  8000cd:	e8 26 0a 00 00       	call   800af8 <cprintf>
  8000d2:	83 c4 10             	add    $0x10,%esp
		return 0;
  8000d5:	bb 00 00 00 00       	mov    $0x0,%ebx
  8000da:	e9 b8 00 00 00       	jmp    800197 <_gettoken+0x163>
	}
	if (strchr(SYMBOLS, *s)) {
  8000df:	83 ec 08             	sub    $0x8,%esp
  8000e2:	0f be c0             	movsbl %al,%eax
  8000e5:	50                   	push   %eax
  8000e6:	68 d3 35 80 00       	push   $0x8035d3
  8000eb:	e8 c9 11 00 00       	call   8012b9 <strchr>
  8000f0:	83 c4 10             	add    $0x10,%esp
  8000f3:	85 c0                	test   %eax,%eax
  8000f5:	74 2e                	je     800125 <_gettoken+0xf1>
		t = *s;
  8000f7:	0f be 1b             	movsbl (%ebx),%ebx
		*p1 = s;
  8000fa:	89 37                	mov    %esi,(%edi)
		*s++ = 0;
  8000fc:	c6 06 00             	movb   $0x0,(%esi)
  8000ff:	46                   	inc    %esi
  800100:	8b 55 10             	mov    0x10(%ebp),%edx
  800103:	89 32                	mov    %esi,(%edx)
		*p2 = s;
		if (debug > 1)
  800105:	83 3d 00 50 80 00 01 	cmpl   $0x1,0x805000
  80010c:	0f 8e 85 00 00 00    	jle    800197 <_gettoken+0x163>
			cprintf("TOK %c\n", t);
  800112:	83 ec 08             	sub    $0x8,%esp
  800115:	53                   	push   %ebx
  800116:	68 c7 35 80 00       	push   $0x8035c7
  80011b:	e8 d8 09 00 00       	call   800af8 <cprintf>
  800120:	83 c4 10             	add    $0x10,%esp
  800123:	eb 72                	jmp    800197 <_gettoken+0x163>
		return t;
	}
	*p1 = s;
  800125:	89 1f                	mov    %ebx,(%edi)
	while (*s && !strchr(WHITESPACE SYMBOLS, *s))
  800127:	8a 03                	mov    (%ebx),%al
  800129:	84 c0                	test   %al,%al
  80012b:	75 09                	jne    800136 <_gettoken+0x102>
  80012d:	eb 1f                	jmp    80014e <_gettoken+0x11a>
		s++;
  80012f:	43                   	inc    %ebx
		if (debug > 1)
			cprintf("TOK %c\n", t);
		return t;
	}
	*p1 = s;
	while (*s && !strchr(WHITESPACE SYMBOLS, *s))
  800130:	8a 03                	mov    (%ebx),%al
  800132:	84 c0                	test   %al,%al
  800134:	74 18                	je     80014e <_gettoken+0x11a>
  800136:	83 ec 08             	sub    $0x8,%esp
  800139:	0f be c0             	movsbl %al,%eax
  80013c:	50                   	push   %eax
  80013d:	68 cf 35 80 00       	push   $0x8035cf
  800142:	e8 72 11 00 00       	call   8012b9 <strchr>
  800147:	83 c4 10             	add    $0x10,%esp
  80014a:	85 c0                	test   %eax,%eax
  80014c:	74 e1                	je     80012f <_gettoken+0xfb>
		s++;
	*p2 = s;
  80014e:	8b 45 10             	mov    0x10(%ebp),%eax
  800151:	89 18                	mov    %ebx,(%eax)
	if (debug > 1) {
  800153:	83 3d 00 50 80 00 01 	cmpl   $0x1,0x805000
  80015a:	7e 36                	jle    800192 <_gettoken+0x15e>
		t = **p2;
  80015c:	0f b6 33             	movzbl (%ebx),%esi
		**p2 = 0;
  80015f:	c6 03 00             	movb   $0x0,(%ebx)
		cprintf("WORD: %s\n", *p1);
  800162:	83 ec 08             	sub    $0x8,%esp
  800165:	ff 37                	pushl  (%edi)
  800167:	68 db 35 80 00       	push   $0x8035db
  80016c:	e8 87 09 00 00       	call   800af8 <cprintf>
		**p2 = t;
  800171:	8b 55 10             	mov    0x10(%ebp),%edx
  800174:	8b 02                	mov    (%edx),%eax
  800176:	89 f2                	mov    %esi,%edx
  800178:	88 10                	mov    %dl,(%eax)
  80017a:	83 c4 10             	add    $0x10,%esp
	}
	return 'w';
  80017d:	bb 77 00 00 00       	mov    $0x77,%ebx
  800182:	eb 13                	jmp    800197 <_gettoken+0x163>
	int t;

	if (s == 0) {
		if (debug > 1)
			cprintf("GETTOKEN NULL\n");
		return 0;
  800184:	bb 00 00 00 00       	mov    $0x0,%ebx
  800189:	eb 0c                	jmp    800197 <_gettoken+0x163>
	while (strchr(WHITESPACE, *s))
		*s++ = 0;
	if (*s == 0) {
		if (debug > 1)
			cprintf("EOL\n");
		return 0;
  80018b:	bb 00 00 00 00       	mov    $0x0,%ebx
  800190:	eb 05                	jmp    800197 <_gettoken+0x163>
		t = **p2;
		**p2 = 0;
		cprintf("WORD: %s\n", *p1);
		**p2 = t;
	}
	return 'w';
  800192:	bb 77 00 00 00       	mov    $0x77,%ebx
}
  800197:	89 d8                	mov    %ebx,%eax
  800199:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80019c:	5b                   	pop    %ebx
  80019d:	5e                   	pop    %esi
  80019e:	5f                   	pop    %edi
  80019f:	c9                   	leave  
  8001a0:	c3                   	ret    

008001a1 <gettoken>:

int
gettoken(char *s, char **p1)
{
  8001a1:	55                   	push   %ebp
  8001a2:	89 e5                	mov    %esp,%ebp
  8001a4:	83 ec 08             	sub    $0x8,%esp
  8001a7:	8b 45 08             	mov    0x8(%ebp),%eax
	static int c, nc;
	static char* np1, *np2;

	if (s) {
  8001aa:	85 c0                	test   %eax,%eax
  8001ac:	74 22                	je     8001d0 <gettoken+0x2f>
		nc = _gettoken(s, &np1, &np2);
  8001ae:	83 ec 04             	sub    $0x4,%esp
  8001b1:	68 04 50 80 00       	push   $0x805004
  8001b6:	68 08 50 80 00       	push   $0x805008
  8001bb:	50                   	push   %eax
  8001bc:	e8 73 fe ff ff       	call   800034 <_gettoken>
  8001c1:	a3 0c 50 80 00       	mov    %eax,0x80500c
		return 0;
  8001c6:	83 c4 10             	add    $0x10,%esp
  8001c9:	b8 00 00 00 00       	mov    $0x0,%eax
  8001ce:	eb 3a                	jmp    80020a <gettoken+0x69>
	}
	c = nc;
  8001d0:	a1 0c 50 80 00       	mov    0x80500c,%eax
  8001d5:	a3 10 50 80 00       	mov    %eax,0x805010
	*p1 = np1;
  8001da:	8b 15 08 50 80 00    	mov    0x805008,%edx
  8001e0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8001e3:	89 10                	mov    %edx,(%eax)
	nc = _gettoken(np2, &np1, &np2);
  8001e5:	83 ec 04             	sub    $0x4,%esp
  8001e8:	68 04 50 80 00       	push   $0x805004
  8001ed:	68 08 50 80 00       	push   $0x805008
  8001f2:	ff 35 04 50 80 00    	pushl  0x805004
  8001f8:	e8 37 fe ff ff       	call   800034 <_gettoken>
  8001fd:	a3 0c 50 80 00       	mov    %eax,0x80500c
	return c;
  800202:	a1 10 50 80 00       	mov    0x805010,%eax
  800207:	83 c4 10             	add    $0x10,%esp
}
  80020a:	c9                   	leave  
  80020b:	c3                   	ret    

0080020c <runcmd>:
// runcmd() is called in a forked child,
// so it's OK to manipulate file descriptor state.
#define MAXARGS 16
void
runcmd(char* s)
{
  80020c:	55                   	push   %ebp
  80020d:	89 e5                	mov    %esp,%ebp
  80020f:	57                   	push   %edi
  800210:	56                   	push   %esi
  800211:	53                   	push   %ebx
  800212:	81 ec 64 04 00 00    	sub    $0x464,%esp
	char *argv[MAXARGS], *t, argv0buf[BUFSIZ];
	int argc, c, i, r, p[2], fd, pipe_child;

	pipe_child = 0;
	gettoken(s, 0);
  800218:	6a 00                	push   $0x0
  80021a:	ff 75 08             	pushl  0x8(%ebp)
  80021d:	e8 7f ff ff ff       	call   8001a1 <gettoken>
  800222:	83 c4 10             	add    $0x10,%esp

again:
	argc = 0;
  800225:	bf 00 00 00 00       	mov    $0x0,%edi
	while (1) {
		switch ((c = gettoken(0, &t))) {
  80022a:	8d 75 a4             	lea    -0x5c(%ebp),%esi
  80022d:	83 ec 08             	sub    $0x8,%esp
  800230:	56                   	push   %esi
  800231:	6a 00                	push   $0x0
  800233:	e8 69 ff ff ff       	call   8001a1 <gettoken>
  800238:	83 c4 10             	add    $0x10,%esp
  80023b:	83 f8 77             	cmp    $0x77,%eax
  80023e:	74 2e                	je     80026e <runcmd+0x62>
  800240:	83 f8 77             	cmp    $0x77,%eax
  800243:	7f 1b                	jg     800260 <runcmd+0x54>
  800245:	83 f8 3c             	cmp    $0x3c,%eax
  800248:	74 48                	je     800292 <runcmd+0x86>
  80024a:	83 f8 3e             	cmp    $0x3e,%eax
  80024d:	0f 84 bb 00 00 00    	je     80030e <runcmd+0x102>
  800253:	85 c0                	test   %eax,%eax
  800255:	0f 84 36 02 00 00    	je     800491 <runcmd+0x285>
  80025b:	e9 1f 02 00 00       	jmp    80047f <runcmd+0x273>
  800260:	83 f8 7c             	cmp    $0x7c,%eax
  800263:	0f 85 16 02 00 00    	jne    80047f <runcmd+0x273>
  800269:	e9 1e 01 00 00       	jmp    80038c <runcmd+0x180>

		case 'w':	// Add an argument
			if (argc == MAXARGS) {
  80026e:	83 ff 10             	cmp    $0x10,%edi
  800271:	75 15                	jne    800288 <runcmd+0x7c>
				cprintf("too many arguments\n");
  800273:	83 ec 0c             	sub    $0xc,%esp
  800276:	68 e5 35 80 00       	push   $0x8035e5
  80027b:	e8 78 08 00 00       	call   800af8 <cprintf>
				exit();
  800280:	e8 7f 07 00 00       	call   800a04 <exit>
  800285:	83 c4 10             	add    $0x10,%esp
			}
			argv[argc++] = t;
  800288:	8b 45 a4             	mov    -0x5c(%ebp),%eax
  80028b:	89 44 bd a8          	mov    %eax,-0x58(%ebp,%edi,4)
  80028f:	47                   	inc    %edi
			break;
  800290:	eb 9b                	jmp    80022d <runcmd+0x21>

		case '<':	// Input redirection
			// Grab the filename from the argument list
			if (gettoken(0, &t) != 'w') {
  800292:	83 ec 08             	sub    $0x8,%esp
  800295:	56                   	push   %esi
  800296:	6a 00                	push   $0x0
  800298:	e8 04 ff ff ff       	call   8001a1 <gettoken>
  80029d:	83 c4 10             	add    $0x10,%esp
  8002a0:	83 f8 77             	cmp    $0x77,%eax
  8002a3:	74 15                	je     8002ba <runcmd+0xae>
				cprintf("syntax error: < not followed by word\n");
  8002a5:	83 ec 0c             	sub    $0xc,%esp
  8002a8:	68 38 37 80 00       	push   $0x803738
  8002ad:	e8 46 08 00 00       	call   800af8 <cprintf>
				exit();
  8002b2:	e8 4d 07 00 00       	call   800a04 <exit>
  8002b7:	83 c4 10             	add    $0x10,%esp
			}
			if ((fd = open(t, O_RDONLY)) < 0) {
  8002ba:	83 ec 08             	sub    $0x8,%esp
  8002bd:	6a 00                	push   $0x0
  8002bf:	ff 75 a4             	pushl  -0x5c(%ebp)
  8002c2:	e8 8d 20 00 00       	call   802354 <open>
  8002c7:	89 c3                	mov    %eax,%ebx
  8002c9:	83 c4 10             	add    $0x10,%esp
  8002cc:	85 c0                	test   %eax,%eax
  8002ce:	79 1b                	jns    8002eb <runcmd+0xdf>
				cprintf("open %s for read: %e", t, fd);
  8002d0:	83 ec 04             	sub    $0x4,%esp
  8002d3:	50                   	push   %eax
  8002d4:	ff 75 a4             	pushl  -0x5c(%ebp)
  8002d7:	68 f9 35 80 00       	push   $0x8035f9
  8002dc:	e8 17 08 00 00       	call   800af8 <cprintf>
				exit();
  8002e1:	e8 1e 07 00 00       	call   800a04 <exit>
  8002e6:	83 c4 10             	add    $0x10,%esp
  8002e9:	eb 08                	jmp    8002f3 <runcmd+0xe7>
			}
			if (fd != 0) {
  8002eb:	85 c0                	test   %eax,%eax
  8002ed:	0f 84 3a ff ff ff    	je     80022d <runcmd+0x21>
				dup(fd, 0);
  8002f3:	83 ec 08             	sub    $0x8,%esp
  8002f6:	6a 00                	push   $0x0
  8002f8:	53                   	push   %ebx
  8002f9:	e8 63 1b 00 00       	call   801e61 <dup>
				close(fd);
  8002fe:	89 1c 24             	mov    %ebx,(%esp)
  800301:	e8 0d 1b 00 00       	call   801e13 <close>
  800306:	83 c4 10             	add    $0x10,%esp
  800309:	e9 1f ff ff ff       	jmp    80022d <runcmd+0x21>
			}
			break;

		case '>':	// Output redirection
			// Grab the filename from the argument list
			if (gettoken(0, &t) != 'w') {
  80030e:	83 ec 08             	sub    $0x8,%esp
  800311:	56                   	push   %esi
  800312:	6a 00                	push   $0x0
  800314:	e8 88 fe ff ff       	call   8001a1 <gettoken>
  800319:	83 c4 10             	add    $0x10,%esp
  80031c:	83 f8 77             	cmp    $0x77,%eax
  80031f:	74 15                	je     800336 <runcmd+0x12a>
				cprintf("syntax error: > not followed by word\n");
  800321:	83 ec 0c             	sub    $0xc,%esp
  800324:	68 60 37 80 00       	push   $0x803760
  800329:	e8 ca 07 00 00       	call   800af8 <cprintf>
				exit();
  80032e:	e8 d1 06 00 00       	call   800a04 <exit>
  800333:	83 c4 10             	add    $0x10,%esp
			}
			if ((fd = open(t, O_WRONLY|O_CREAT|O_TRUNC)) < 0) {
  800336:	83 ec 08             	sub    $0x8,%esp
  800339:	68 01 03 00 00       	push   $0x301
  80033e:	ff 75 a4             	pushl  -0x5c(%ebp)
  800341:	e8 0e 20 00 00       	call   802354 <open>
  800346:	89 c3                	mov    %eax,%ebx
  800348:	83 c4 10             	add    $0x10,%esp
  80034b:	85 c0                	test   %eax,%eax
  80034d:	79 19                	jns    800368 <runcmd+0x15c>
				cprintf("open %s for write: %e", t, fd);
  80034f:	83 ec 04             	sub    $0x4,%esp
  800352:	50                   	push   %eax
  800353:	ff 75 a4             	pushl  -0x5c(%ebp)
  800356:	68 0e 36 80 00       	push   $0x80360e
  80035b:	e8 98 07 00 00       	call   800af8 <cprintf>
				exit();
  800360:	e8 9f 06 00 00       	call   800a04 <exit>
  800365:	83 c4 10             	add    $0x10,%esp
			}
			if (fd != 1) {
  800368:	83 fb 01             	cmp    $0x1,%ebx
  80036b:	0f 84 bc fe ff ff    	je     80022d <runcmd+0x21>
				dup(fd, 1);
  800371:	83 ec 08             	sub    $0x8,%esp
  800374:	6a 01                	push   $0x1
  800376:	53                   	push   %ebx
  800377:	e8 e5 1a 00 00       	call   801e61 <dup>
				close(fd);
  80037c:	89 1c 24             	mov    %ebx,(%esp)
  80037f:	e8 8f 1a 00 00       	call   801e13 <close>
  800384:	83 c4 10             	add    $0x10,%esp
  800387:	e9 a1 fe ff ff       	jmp    80022d <runcmd+0x21>
			}
			break;

		case '|':	// Pipe
			if ((r = pipe(p)) < 0) {
  80038c:	83 ec 0c             	sub    $0xc,%esp
  80038f:	8d 85 9c fb ff ff    	lea    -0x464(%ebp),%eax
  800395:	50                   	push   %eax
  800396:	e8 ab 2b 00 00       	call   802f46 <pipe>
  80039b:	83 c4 10             	add    $0x10,%esp
  80039e:	85 c0                	test   %eax,%eax
  8003a0:	79 16                	jns    8003b8 <runcmd+0x1ac>
				cprintf("pipe: %e", r);
  8003a2:	83 ec 08             	sub    $0x8,%esp
  8003a5:	50                   	push   %eax
  8003a6:	68 24 36 80 00       	push   $0x803624
  8003ab:	e8 48 07 00 00       	call   800af8 <cprintf>
				exit();
  8003b0:	e8 4f 06 00 00       	call   800a04 <exit>
  8003b5:	83 c4 10             	add    $0x10,%esp
			}
			if (debug)
  8003b8:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  8003bf:	74 1c                	je     8003dd <runcmd+0x1d1>
				cprintf("PIPE: %d %d\n", p[0], p[1]);
  8003c1:	83 ec 04             	sub    $0x4,%esp
  8003c4:	ff b5 a0 fb ff ff    	pushl  -0x460(%ebp)
  8003ca:	ff b5 9c fb ff ff    	pushl  -0x464(%ebp)
  8003d0:	68 2d 36 80 00       	push   $0x80362d
  8003d5:	e8 1e 07 00 00       	call   800af8 <cprintf>
  8003da:	83 c4 10             	add    $0x10,%esp
			if ((r = fork()) < 0) {
  8003dd:	e8 b0 14 00 00       	call   801892 <fork>
  8003e2:	89 c3                	mov    %eax,%ebx
  8003e4:	85 c0                	test   %eax,%eax
  8003e6:	79 16                	jns    8003fe <runcmd+0x1f2>
				cprintf("fork: %e", r);
  8003e8:	83 ec 08             	sub    $0x8,%esp
  8003eb:	50                   	push   %eax
  8003ec:	68 3a 36 80 00       	push   $0x80363a
  8003f1:	e8 02 07 00 00       	call   800af8 <cprintf>
				exit();
  8003f6:	e8 09 06 00 00       	call   800a04 <exit>
  8003fb:	83 c4 10             	add    $0x10,%esp
			}
			if (r == 0) {
  8003fe:	85 db                	test   %ebx,%ebx
  800400:	75 41                	jne    800443 <runcmd+0x237>
				if (p[0] != 0) {
  800402:	8b 85 9c fb ff ff    	mov    -0x464(%ebp),%eax
  800408:	85 c0                	test   %eax,%eax
  80040a:	74 1c                	je     800428 <runcmd+0x21c>
					dup(p[0], 0);
  80040c:	83 ec 08             	sub    $0x8,%esp
  80040f:	6a 00                	push   $0x0
  800411:	50                   	push   %eax
  800412:	e8 4a 1a 00 00       	call   801e61 <dup>
					close(p[0]);
  800417:	83 c4 04             	add    $0x4,%esp
  80041a:	ff b5 9c fb ff ff    	pushl  -0x464(%ebp)
  800420:	e8 ee 19 00 00       	call   801e13 <close>
  800425:	83 c4 10             	add    $0x10,%esp
				}
				close(p[1]);
  800428:	83 ec 0c             	sub    $0xc,%esp
  80042b:	ff b5 a0 fb ff ff    	pushl  -0x460(%ebp)
  800431:	e8 dd 19 00 00       	call   801e13 <close>
				goto again;
  800436:	83 c4 10             	add    $0x10,%esp

	pipe_child = 0;
	gettoken(s, 0);

again:
	argc = 0;
  800439:	bf 00 00 00 00       	mov    $0x0,%edi
  80043e:	e9 ea fd ff ff       	jmp    80022d <runcmd+0x21>
				}
				close(p[1]);
				goto again;
			} else {
				pipe_child = r;
				if (p[1] != 1) {
  800443:	8b 85 a0 fb ff ff    	mov    -0x460(%ebp),%eax
  800449:	83 f8 01             	cmp    $0x1,%eax
  80044c:	74 1c                	je     80046a <runcmd+0x25e>
					dup(p[1], 1);
  80044e:	83 ec 08             	sub    $0x8,%esp
  800451:	6a 01                	push   $0x1
  800453:	50                   	push   %eax
  800454:	e8 08 1a 00 00       	call   801e61 <dup>
					close(p[1]);
  800459:	83 c4 04             	add    $0x4,%esp
  80045c:	ff b5 a0 fb ff ff    	pushl  -0x460(%ebp)
  800462:	e8 ac 19 00 00       	call   801e13 <close>
  800467:	83 c4 10             	add    $0x10,%esp
				}
				close(p[0]);
  80046a:	83 ec 0c             	sub    $0xc,%esp
  80046d:	ff b5 9c fb ff ff    	pushl  -0x464(%ebp)
  800473:	e8 9b 19 00 00       	call   801e13 <close>
				goto runit;
  800478:	83 c4 10             	add    $0x10,%esp
				cprintf("pipe: %e", r);
				exit();
			}
			if (debug)
				cprintf("PIPE: %d %d\n", p[0], p[1]);
			if ((r = fork()) < 0) {
  80047b:	89 de                	mov    %ebx,%esi
				if (p[1] != 1) {
					dup(p[1], 1);
					close(p[1]);
				}
				close(p[0]);
				goto runit;
  80047d:	eb 17                	jmp    800496 <runcmd+0x28a>
		case 0:		// String is complete
			// Run the current command!
			goto runit;

		default:
			panic("bad return %d from gettoken", c);
  80047f:	50                   	push   %eax
  800480:	68 43 36 80 00       	push   $0x803643
  800485:	6a 6e                	push   $0x6e
  800487:	68 5f 36 80 00       	push   $0x80365f
  80048c:	e8 8f 05 00 00       	call   800a20 <_panic>
runcmd(char* s)
{
	char *argv[MAXARGS], *t, argv0buf[BUFSIZ];
	int argc, c, i, r, p[2], fd, pipe_child;

	pipe_child = 0;
  800491:	be 00 00 00 00       	mov    $0x0,%esi
		}
	}

runit:
	// Return immediately if command line was empty.
	if(argc == 0) {
  800496:	85 ff                	test   %edi,%edi
  800498:	75 22                	jne    8004bc <runcmd+0x2b0>
		if (debug)
  80049a:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  8004a1:	0f 84 81 01 00 00    	je     800628 <runcmd+0x41c>
			cprintf("EMPTY COMMAND\n");
  8004a7:	83 ec 0c             	sub    $0xc,%esp
  8004aa:	68 69 36 80 00       	push   $0x803669
  8004af:	e8 44 06 00 00       	call   800af8 <cprintf>
  8004b4:	83 c4 10             	add    $0x10,%esp
  8004b7:	e9 6c 01 00 00       	jmp    800628 <runcmd+0x41c>

	// Clean up command line.
	// Read all commands from the filesystem: add an initial '/' to
	// the command name.
	// This essentially acts like 'PATH=/'.
	if (argv[0][0] != '/') {
  8004bc:	8b 45 a8             	mov    -0x58(%ebp),%eax
  8004bf:	80 38 2f             	cmpb   $0x2f,(%eax)
  8004c2:	74 23                	je     8004e7 <runcmd+0x2db>
		argv0buf[0] = '/';
  8004c4:	c6 85 a4 fb ff ff 2f 	movb   $0x2f,-0x45c(%ebp)
		strcpy(argv0buf + 1, argv[0]);
  8004cb:	83 ec 08             	sub    $0x8,%esp
  8004ce:	50                   	push   %eax
  8004cf:	8d 9d a4 fb ff ff    	lea    -0x45c(%ebp),%ebx
  8004d5:	8d 85 a5 fb ff ff    	lea    -0x45b(%ebp),%eax
  8004db:	50                   	push   %eax
  8004dc:	e8 b1 0c 00 00       	call   801192 <strcpy>
		argv[0] = argv0buf;
  8004e1:	89 5d a8             	mov    %ebx,-0x58(%ebp)
  8004e4:	83 c4 10             	add    $0x10,%esp
	}
	argv[argc] = 0;
  8004e7:	c7 44 bd a8 00 00 00 	movl   $0x0,-0x58(%ebp,%edi,4)
  8004ee:	00 

	// Print the command.
	if (debug) {
  8004ef:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  8004f6:	74 4d                	je     800545 <runcmd+0x339>
		cprintf("[%08x] SPAWN:", thisenv->env_id);
  8004f8:	a1 24 54 80 00       	mov    0x805424,%eax
  8004fd:	8b 40 48             	mov    0x48(%eax),%eax
  800500:	83 ec 08             	sub    $0x8,%esp
  800503:	50                   	push   %eax
  800504:	68 78 36 80 00       	push   $0x803678
  800509:	e8 ea 05 00 00       	call   800af8 <cprintf>
		for (i = 0; argv[i]; i++)
  80050e:	8b 45 a8             	mov    -0x58(%ebp),%eax
  800511:	83 c4 10             	add    $0x10,%esp
  800514:	85 c0                	test   %eax,%eax
  800516:	74 1d                	je     800535 <runcmd+0x329>
  800518:	8d 5d ac             	lea    -0x54(%ebp),%ebx
			cprintf(" %s", argv[i]);
  80051b:	83 ec 08             	sub    $0x8,%esp
  80051e:	50                   	push   %eax
  80051f:	68 03 37 80 00       	push   $0x803703
  800524:	e8 cf 05 00 00       	call   800af8 <cprintf>
	argv[argc] = 0;

	// Print the command.
	if (debug) {
		cprintf("[%08x] SPAWN:", thisenv->env_id);
		for (i = 0; argv[i]; i++)
  800529:	8b 03                	mov    (%ebx),%eax
  80052b:	83 c3 04             	add    $0x4,%ebx
  80052e:	83 c4 10             	add    $0x10,%esp
  800531:	85 c0                	test   %eax,%eax
  800533:	75 e6                	jne    80051b <runcmd+0x30f>
			cprintf(" %s", argv[i]);
		cprintf("\n");
  800535:	83 ec 0c             	sub    $0xc,%esp
  800538:	68 c0 35 80 00       	push   $0x8035c0
  80053d:	e8 b6 05 00 00       	call   800af8 <cprintf>
  800542:	83 c4 10             	add    $0x10,%esp
	}

	// Spawn the command!
	if ((r = spawn(argv[0], (const char**) argv)) < 0)
  800545:	83 ec 08             	sub    $0x8,%esp
  800548:	8d 45 a8             	lea    -0x58(%ebp),%eax
  80054b:	50                   	push   %eax
  80054c:	ff 75 a8             	pushl  -0x58(%ebp)
  80054f:	e8 68 22 00 00       	call   8027bc <spawn>
  800554:	89 c3                	mov    %eax,%ebx
  800556:	83 c4 10             	add    $0x10,%esp
  800559:	85 c0                	test   %eax,%eax
  80055b:	79 1b                	jns    800578 <runcmd+0x36c>
		cprintf("spawn %s: %e\n", argv[0], r);
  80055d:	83 ec 04             	sub    $0x4,%esp
  800560:	50                   	push   %eax
  800561:	ff 75 a8             	pushl  -0x58(%ebp)
  800564:	68 86 36 80 00       	push   $0x803686
  800569:	e8 8a 05 00 00       	call   800af8 <cprintf>

	// In the parent, close all file descriptors and wait for the
	// spawned command to exit.
	close_all();
  80056e:	e8 cb 18 00 00       	call   801e3e <close_all>
  800573:	83 c4 10             	add    $0x10,%esp
  800576:	eb 56                	jmp    8005ce <runcmd+0x3c2>
  800578:	e8 c1 18 00 00       	call   801e3e <close_all>
	if (r >= 0) {
		if (debug)
  80057d:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  800584:	74 1a                	je     8005a0 <runcmd+0x394>
			cprintf("[%08x] WAIT %s %08x\n", thisenv->env_id, argv[0], r);
  800586:	a1 24 54 80 00       	mov    0x805424,%eax
  80058b:	8b 40 48             	mov    0x48(%eax),%eax
  80058e:	53                   	push   %ebx
  80058f:	ff 75 a8             	pushl  -0x58(%ebp)
  800592:	50                   	push   %eax
  800593:	68 94 36 80 00       	push   $0x803694
  800598:	e8 5b 05 00 00       	call   800af8 <cprintf>
  80059d:	83 c4 10             	add    $0x10,%esp
		wait(r);
  8005a0:	83 ec 0c             	sub    $0xc,%esp
  8005a3:	53                   	push   %ebx
  8005a4:	e8 23 2b 00 00       	call   8030cc <wait>
		if (debug)
  8005a9:	83 c4 10             	add    $0x10,%esp
  8005ac:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  8005b3:	74 19                	je     8005ce <runcmd+0x3c2>
			cprintf("[%08x] wait finished\n", thisenv->env_id);
  8005b5:	a1 24 54 80 00       	mov    0x805424,%eax
  8005ba:	8b 40 48             	mov    0x48(%eax),%eax
  8005bd:	83 ec 08             	sub    $0x8,%esp
  8005c0:	50                   	push   %eax
  8005c1:	68 a9 36 80 00       	push   $0x8036a9
  8005c6:	e8 2d 05 00 00       	call   800af8 <cprintf>
  8005cb:	83 c4 10             	add    $0x10,%esp
	}

	// If we were the left-hand part of a pipe,
	// wait for the right-hand part to finish.
	if (pipe_child) {
  8005ce:	85 f6                	test   %esi,%esi
  8005d0:	74 51                	je     800623 <runcmd+0x417>
		if (debug)
  8005d2:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  8005d9:	74 1a                	je     8005f5 <runcmd+0x3e9>
			cprintf("[%08x] WAIT pipe_child %08x\n", thisenv->env_id, pipe_child);
  8005db:	a1 24 54 80 00       	mov    0x805424,%eax
  8005e0:	8b 40 48             	mov    0x48(%eax),%eax
  8005e3:	83 ec 04             	sub    $0x4,%esp
  8005e6:	56                   	push   %esi
  8005e7:	50                   	push   %eax
  8005e8:	68 bf 36 80 00       	push   $0x8036bf
  8005ed:	e8 06 05 00 00       	call   800af8 <cprintf>
  8005f2:	83 c4 10             	add    $0x10,%esp
		wait(pipe_child);
  8005f5:	83 ec 0c             	sub    $0xc,%esp
  8005f8:	56                   	push   %esi
  8005f9:	e8 ce 2a 00 00       	call   8030cc <wait>
		if (debug)
  8005fe:	83 c4 10             	add    $0x10,%esp
  800601:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  800608:	74 19                	je     800623 <runcmd+0x417>
			cprintf("[%08x] wait finished\n", thisenv->env_id);
  80060a:	a1 24 54 80 00       	mov    0x805424,%eax
  80060f:	8b 40 48             	mov    0x48(%eax),%eax
  800612:	83 ec 08             	sub    $0x8,%esp
  800615:	50                   	push   %eax
  800616:	68 a9 36 80 00       	push   $0x8036a9
  80061b:	e8 d8 04 00 00       	call   800af8 <cprintf>
  800620:	83 c4 10             	add    $0x10,%esp
	}

	// Done!
	exit();
  800623:	e8 dc 03 00 00       	call   800a04 <exit>
}
  800628:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80062b:	5b                   	pop    %ebx
  80062c:	5e                   	pop    %esi
  80062d:	5f                   	pop    %edi
  80062e:	c9                   	leave  
  80062f:	c3                   	ret    

00800630 <usage>:
}


void
usage(void)
{
  800630:	55                   	push   %ebp
  800631:	89 e5                	mov    %esp,%ebp
  800633:	83 ec 14             	sub    $0x14,%esp
	cprintf("usage: sh [-dix] [command-file]\n");
  800636:	68 88 37 80 00       	push   $0x803788
  80063b:	e8 b8 04 00 00       	call   800af8 <cprintf>
	exit();
  800640:	e8 bf 03 00 00       	call   800a04 <exit>
  800645:	83 c4 10             	add    $0x10,%esp
}
  800648:	c9                   	leave  
  800649:	c3                   	ret    

0080064a <umain>:

void
umain(int argc, char **argv)
{
  80064a:	55                   	push   %ebp
  80064b:	89 e5                	mov    %esp,%ebp
  80064d:	57                   	push   %edi
  80064e:	56                   	push   %esi
  80064f:	53                   	push   %ebx
  800650:	83 ec 30             	sub    $0x30,%esp
  800653:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r, interactive, echocmds;
	struct Argstate args;

	interactive = '?';
	echocmds = 0;
	argstart(&argc, argv, &args);
  800656:	8d 45 d8             	lea    -0x28(%ebp),%eax
  800659:	50                   	push   %eax
  80065a:	56                   	push   %esi
  80065b:	8d 45 08             	lea    0x8(%ebp),%eax
  80065e:	50                   	push   %eax
  80065f:	e8 74 14 00 00       	call   801ad8 <argstart>
	while ((r = argnext(&args)) >= 0)
  800664:	83 c4 10             	add    $0x10,%esp
{
	int r, interactive, echocmds;
	struct Argstate args;

	interactive = '?';
	echocmds = 0;
  800667:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
umain(int argc, char **argv)
{
	int r, interactive, echocmds;
	struct Argstate args;

	interactive = '?';
  80066e:	bf 3f 00 00 00       	mov    $0x3f,%edi
	echocmds = 0;
	argstart(&argc, argv, &args);
	while ((r = argnext(&args)) >= 0)
  800673:	8d 5d d8             	lea    -0x28(%ebp),%ebx
  800676:	eb 2e                	jmp    8006a6 <umain+0x5c>
		switch (r) {
  800678:	83 f8 69             	cmp    $0x69,%eax
  80067b:	74 0c                	je     800689 <umain+0x3f>
  80067d:	83 f8 78             	cmp    $0x78,%eax
  800680:	74 1d                	je     80069f <umain+0x55>
  800682:	83 f8 64             	cmp    $0x64,%eax
  800685:	75 11                	jne    800698 <umain+0x4e>
  800687:	eb 07                	jmp    800690 <umain+0x46>
		case 'd':
			debug++;
			break;
		case 'i':
			interactive = 1;
  800689:	bf 01 00 00 00       	mov    $0x1,%edi
  80068e:	eb 16                	jmp    8006a6 <umain+0x5c>
	echocmds = 0;
	argstart(&argc, argv, &args);
	while ((r = argnext(&args)) >= 0)
		switch (r) {
		case 'd':
			debug++;
  800690:	ff 05 00 50 80 00    	incl   0x805000
			break;
  800696:	eb 0e                	jmp    8006a6 <umain+0x5c>
			break;
		case 'x':
			echocmds = 1;
			break;
		default:
			usage();
  800698:	e8 93 ff ff ff       	call   800630 <usage>
  80069d:	eb 07                	jmp    8006a6 <umain+0x5c>
			break;
		case 'i':
			interactive = 1;
			break;
		case 'x':
			echocmds = 1;
  80069f:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
	struct Argstate args;

	interactive = '?';
	echocmds = 0;
	argstart(&argc, argv, &args);
	while ((r = argnext(&args)) >= 0)
  8006a6:	83 ec 0c             	sub    $0xc,%esp
  8006a9:	53                   	push   %ebx
  8006aa:	e8 62 14 00 00       	call   801b11 <argnext>
  8006af:	83 c4 10             	add    $0x10,%esp
  8006b2:	85 c0                	test   %eax,%eax
  8006b4:	79 c2                	jns    800678 <umain+0x2e>
  8006b6:	89 fb                	mov    %edi,%ebx
			break;
		default:
			usage();
		}

	if (argc > 2)
  8006b8:	83 7d 08 02          	cmpl   $0x2,0x8(%ebp)
  8006bc:	7e 05                	jle    8006c3 <umain+0x79>
		usage();
  8006be:	e8 6d ff ff ff       	call   800630 <usage>
	if (argc == 2) {
  8006c3:	83 7d 08 02          	cmpl   $0x2,0x8(%ebp)
  8006c7:	75 56                	jne    80071f <umain+0xd5>
		close(0);
  8006c9:	83 ec 0c             	sub    $0xc,%esp
  8006cc:	6a 00                	push   $0x0
  8006ce:	e8 40 17 00 00       	call   801e13 <close>
		if ((r = open(argv[1], O_RDONLY)) < 0)
  8006d3:	83 c4 08             	add    $0x8,%esp
  8006d6:	6a 00                	push   $0x0
  8006d8:	ff 76 04             	pushl  0x4(%esi)
  8006db:	e8 74 1c 00 00       	call   802354 <open>
  8006e0:	83 c4 10             	add    $0x10,%esp
  8006e3:	85 c0                	test   %eax,%eax
  8006e5:	79 1b                	jns    800702 <umain+0xb8>
			panic("open %s: %e", argv[1], r);
  8006e7:	83 ec 0c             	sub    $0xc,%esp
  8006ea:	50                   	push   %eax
  8006eb:	ff 76 04             	pushl  0x4(%esi)
  8006ee:	68 df 36 80 00       	push   $0x8036df
  8006f3:	68 1e 01 00 00       	push   $0x11e
  8006f8:	68 5f 36 80 00       	push   $0x80365f
  8006fd:	e8 1e 03 00 00       	call   800a20 <_panic>
		assert(r == 0);
  800702:	85 c0                	test   %eax,%eax
  800704:	74 19                	je     80071f <umain+0xd5>
  800706:	68 eb 36 80 00       	push   $0x8036eb
  80070b:	68 f2 36 80 00       	push   $0x8036f2
  800710:	68 1f 01 00 00       	push   $0x11f
  800715:	68 5f 36 80 00       	push   $0x80365f
  80071a:	e8 01 03 00 00       	call   800a20 <_panic>
	}
	if (interactive == '?')
  80071f:	83 fb 3f             	cmp    $0x3f,%ebx
  800722:	75 0f                	jne    800733 <umain+0xe9>
		interactive = iscons(0);
  800724:	83 ec 0c             	sub    $0xc,%esp
  800727:	6a 00                	push   $0x0
  800729:	e8 0c 02 00 00       	call   80093a <iscons>
  80072e:	89 c7                	mov    %eax,%edi
  800730:	83 c4 10             	add    $0x10,%esp

	while (1) {
		char *buf;

		buf = readline(interactive ? "$ " : NULL);
  800733:	85 ff                	test   %edi,%edi
  800735:	74 07                	je     80073e <umain+0xf4>
  800737:	b8 dc 36 80 00       	mov    $0x8036dc,%eax
  80073c:	eb 05                	jmp    800743 <umain+0xf9>
  80073e:	b8 00 00 00 00       	mov    $0x0,%eax
  800743:	83 ec 0c             	sub    $0xc,%esp
  800746:	50                   	push   %eax
  800747:	e8 10 09 00 00       	call   80105c <readline>
  80074c:	89 c6                	mov    %eax,%esi
		if (buf == NULL) {
  80074e:	83 c4 10             	add    $0x10,%esp
  800751:	85 c0                	test   %eax,%eax
  800753:	75 1e                	jne    800773 <umain+0x129>
			if (debug)
  800755:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  80075c:	74 10                	je     80076e <umain+0x124>
				cprintf("EXITING\n");
  80075e:	83 ec 0c             	sub    $0xc,%esp
  800761:	68 07 37 80 00       	push   $0x803707
  800766:	e8 8d 03 00 00       	call   800af8 <cprintf>
  80076b:	83 c4 10             	add    $0x10,%esp
			exit();	// end of file
  80076e:	e8 91 02 00 00       	call   800a04 <exit>
		}
		if (debug)
  800773:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  80077a:	74 11                	je     80078d <umain+0x143>
			cprintf("LINE: %s\n", buf);
  80077c:	83 ec 08             	sub    $0x8,%esp
  80077f:	56                   	push   %esi
  800780:	68 10 37 80 00       	push   $0x803710
  800785:	e8 6e 03 00 00       	call   800af8 <cprintf>
  80078a:	83 c4 10             	add    $0x10,%esp
		if (buf[0] == '#')
  80078d:	80 3e 23             	cmpb   $0x23,(%esi)
  800790:	74 a1                	je     800733 <umain+0xe9>
			continue;
		if (echocmds)
  800792:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  800796:	74 11                	je     8007a9 <umain+0x15f>
			printf("# %s\n", buf);
  800798:	83 ec 08             	sub    $0x8,%esp
  80079b:	56                   	push   %esi
  80079c:	68 1a 37 80 00       	push   $0x80371a
  8007a1:	e8 3a 1d 00 00       	call   8024e0 <printf>
  8007a6:	83 c4 10             	add    $0x10,%esp
		if (debug)
  8007a9:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  8007b0:	74 10                	je     8007c2 <umain+0x178>
			cprintf("BEFORE FORK\n");
  8007b2:	83 ec 0c             	sub    $0xc,%esp
  8007b5:	68 20 37 80 00       	push   $0x803720
  8007ba:	e8 39 03 00 00       	call   800af8 <cprintf>
  8007bf:	83 c4 10             	add    $0x10,%esp
		if ((r = fork()) < 0)
  8007c2:	e8 cb 10 00 00       	call   801892 <fork>
  8007c7:	89 c3                	mov    %eax,%ebx
  8007c9:	85 c0                	test   %eax,%eax
  8007cb:	79 15                	jns    8007e2 <umain+0x198>
			panic("fork: %e", r);
  8007cd:	50                   	push   %eax
  8007ce:	68 3a 36 80 00       	push   $0x80363a
  8007d3:	68 36 01 00 00       	push   $0x136
  8007d8:	68 5f 36 80 00       	push   $0x80365f
  8007dd:	e8 3e 02 00 00       	call   800a20 <_panic>
		if (debug)
  8007e2:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  8007e9:	74 11                	je     8007fc <umain+0x1b2>
			cprintf("FORK: %d\n", r);
  8007eb:	83 ec 08             	sub    $0x8,%esp
  8007ee:	50                   	push   %eax
  8007ef:	68 2d 37 80 00       	push   $0x80372d
  8007f4:	e8 ff 02 00 00       	call   800af8 <cprintf>
  8007f9:	83 c4 10             	add    $0x10,%esp
		if (r == 0) {
  8007fc:	85 db                	test   %ebx,%ebx
  8007fe:	75 16                	jne    800816 <umain+0x1cc>
			runcmd(buf);
  800800:	83 ec 0c             	sub    $0xc,%esp
  800803:	56                   	push   %esi
  800804:	e8 03 fa ff ff       	call   80020c <runcmd>
			exit();
  800809:	e8 f6 01 00 00       	call   800a04 <exit>
  80080e:	83 c4 10             	add    $0x10,%esp
  800811:	e9 1d ff ff ff       	jmp    800733 <umain+0xe9>
		} else
			wait(r);
  800816:	83 ec 0c             	sub    $0xc,%esp
  800819:	53                   	push   %ebx
  80081a:	e8 ad 28 00 00       	call   8030cc <wait>
  80081f:	83 c4 10             	add    $0x10,%esp
  800822:	e9 0c ff ff ff       	jmp    800733 <umain+0xe9>
	...

00800828 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  800828:	55                   	push   %ebp
  800829:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  80082b:	b8 00 00 00 00       	mov    $0x0,%eax
  800830:	c9                   	leave  
  800831:	c3                   	ret    

00800832 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  800832:	55                   	push   %ebp
  800833:	89 e5                	mov    %esp,%ebp
  800835:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  800838:	68 a9 37 80 00       	push   $0x8037a9
  80083d:	ff 75 0c             	pushl  0xc(%ebp)
  800840:	e8 4d 09 00 00       	call   801192 <strcpy>
	return 0;
}
  800845:	b8 00 00 00 00       	mov    $0x0,%eax
  80084a:	c9                   	leave  
  80084b:	c3                   	ret    

0080084c <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  80084c:	55                   	push   %ebp
  80084d:	89 e5                	mov    %esp,%ebp
  80084f:	57                   	push   %edi
  800850:	56                   	push   %esi
  800851:	53                   	push   %ebx
  800852:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800858:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  80085c:	74 45                	je     8008a3 <devcons_write+0x57>
  80085e:	b8 00 00 00 00       	mov    $0x0,%eax
  800863:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  800868:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  80086e:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800871:	29 c3                	sub    %eax,%ebx
		if (m > sizeof(buf) - 1)
  800873:	83 fb 7f             	cmp    $0x7f,%ebx
  800876:	76 05                	jbe    80087d <devcons_write+0x31>
			m = sizeof(buf) - 1;
  800878:	bb 7f 00 00 00       	mov    $0x7f,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  80087d:	83 ec 04             	sub    $0x4,%esp
  800880:	53                   	push   %ebx
  800881:	03 45 0c             	add    0xc(%ebp),%eax
  800884:	50                   	push   %eax
  800885:	57                   	push   %edi
  800886:	e8 c8 0a 00 00       	call   801353 <memmove>
		sys_cputs(buf, m);
  80088b:	83 c4 08             	add    $0x8,%esp
  80088e:	53                   	push   %ebx
  80088f:	57                   	push   %edi
  800890:	e8 c8 0c 00 00       	call   80155d <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800895:	01 de                	add    %ebx,%esi
  800897:	89 f0                	mov    %esi,%eax
  800899:	83 c4 10             	add    $0x10,%esp
  80089c:	3b 75 10             	cmp    0x10(%ebp),%esi
  80089f:	72 cd                	jb     80086e <devcons_write+0x22>
  8008a1:	eb 05                	jmp    8008a8 <devcons_write+0x5c>
  8008a3:	be 00 00 00 00       	mov    $0x0,%esi
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  8008a8:	89 f0                	mov    %esi,%eax
  8008aa:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8008ad:	5b                   	pop    %ebx
  8008ae:	5e                   	pop    %esi
  8008af:	5f                   	pop    %edi
  8008b0:	c9                   	leave  
  8008b1:	c3                   	ret    

008008b2 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  8008b2:	55                   	push   %ebp
  8008b3:	89 e5                	mov    %esp,%ebp
  8008b5:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
  8008b8:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8008bc:	75 07                	jne    8008c5 <devcons_read+0x13>
  8008be:	eb 25                	jmp    8008e5 <devcons_read+0x33>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  8008c0:	e8 28 0d 00 00       	call   8015ed <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  8008c5:	e8 b9 0c 00 00       	call   801583 <sys_cgetc>
  8008ca:	85 c0                	test   %eax,%eax
  8008cc:	74 f2                	je     8008c0 <devcons_read+0xe>
  8008ce:	89 c2                	mov    %eax,%edx
		sys_yield();
	if (c < 0)
  8008d0:	85 c0                	test   %eax,%eax
  8008d2:	78 1d                	js     8008f1 <devcons_read+0x3f>
		return c;
	if (c == 0x04)	// ctl-d is eof
  8008d4:	83 f8 04             	cmp    $0x4,%eax
  8008d7:	74 13                	je     8008ec <devcons_read+0x3a>
		return 0;
	*(char*)vbuf = c;
  8008d9:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008dc:	88 10                	mov    %dl,(%eax)
	return 1;
  8008de:	b8 01 00 00 00       	mov    $0x1,%eax
  8008e3:	eb 0c                	jmp    8008f1 <devcons_read+0x3f>
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
		return 0;
  8008e5:	b8 00 00 00 00       	mov    $0x0,%eax
  8008ea:	eb 05                	jmp    8008f1 <devcons_read+0x3f>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  8008ec:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  8008f1:	c9                   	leave  
  8008f2:	c3                   	ret    

008008f3 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  8008f3:	55                   	push   %ebp
  8008f4:	89 e5                	mov    %esp,%ebp
  8008f6:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  8008f9:	8b 45 08             	mov    0x8(%ebp),%eax
  8008fc:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  8008ff:	6a 01                	push   $0x1
  800901:	8d 45 f7             	lea    -0x9(%ebp),%eax
  800904:	50                   	push   %eax
  800905:	e8 53 0c 00 00       	call   80155d <sys_cputs>
  80090a:	83 c4 10             	add    $0x10,%esp
}
  80090d:	c9                   	leave  
  80090e:	c3                   	ret    

0080090f <getchar>:

int
getchar(void)
{
  80090f:	55                   	push   %ebp
  800910:	89 e5                	mov    %esp,%ebp
  800912:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  800915:	6a 01                	push   $0x1
  800917:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80091a:	50                   	push   %eax
  80091b:	6a 00                	push   $0x0
  80091d:	e8 2e 16 00 00       	call   801f50 <read>
	if (r < 0)
  800922:	83 c4 10             	add    $0x10,%esp
  800925:	85 c0                	test   %eax,%eax
  800927:	78 0f                	js     800938 <getchar+0x29>
		return r;
	if (r < 1)
  800929:	85 c0                	test   %eax,%eax
  80092b:	7e 06                	jle    800933 <getchar+0x24>
		return -E_EOF;
	return c;
  80092d:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  800931:	eb 05                	jmp    800938 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  800933:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  800938:	c9                   	leave  
  800939:	c3                   	ret    

0080093a <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  80093a:	55                   	push   %ebp
  80093b:	89 e5                	mov    %esp,%ebp
  80093d:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800940:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800943:	50                   	push   %eax
  800944:	ff 75 08             	pushl  0x8(%ebp)
  800947:	e8 83 13 00 00       	call   801ccf <fd_lookup>
  80094c:	83 c4 10             	add    $0x10,%esp
  80094f:	85 c0                	test   %eax,%eax
  800951:	78 11                	js     800964 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  800953:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800956:	8b 15 00 40 80 00    	mov    0x804000,%edx
  80095c:	39 10                	cmp    %edx,(%eax)
  80095e:	0f 94 c0             	sete   %al
  800961:	0f b6 c0             	movzbl %al,%eax
}
  800964:	c9                   	leave  
  800965:	c3                   	ret    

00800966 <opencons>:

int
opencons(void)
{
  800966:	55                   	push   %ebp
  800967:	89 e5                	mov    %esp,%ebp
  800969:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  80096c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80096f:	50                   	push   %eax
  800970:	e8 e7 12 00 00       	call   801c5c <fd_alloc>
  800975:	83 c4 10             	add    $0x10,%esp
  800978:	85 c0                	test   %eax,%eax
  80097a:	78 3a                	js     8009b6 <opencons+0x50>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  80097c:	83 ec 04             	sub    $0x4,%esp
  80097f:	68 07 04 00 00       	push   $0x407
  800984:	ff 75 f4             	pushl  -0xc(%ebp)
  800987:	6a 00                	push   $0x0
  800989:	e8 86 0c 00 00       	call   801614 <sys_page_alloc>
  80098e:	83 c4 10             	add    $0x10,%esp
  800991:	85 c0                	test   %eax,%eax
  800993:	78 21                	js     8009b6 <opencons+0x50>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  800995:	8b 15 00 40 80 00    	mov    0x804000,%edx
  80099b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80099e:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  8009a0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8009a3:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  8009aa:	83 ec 0c             	sub    $0xc,%esp
  8009ad:	50                   	push   %eax
  8009ae:	e8 81 12 00 00       	call   801c34 <fd2num>
  8009b3:	83 c4 10             	add    $0x10,%esp
}
  8009b6:	c9                   	leave  
  8009b7:	c3                   	ret    

008009b8 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8009b8:	55                   	push   %ebp
  8009b9:	89 e5                	mov    %esp,%ebp
  8009bb:	56                   	push   %esi
  8009bc:	53                   	push   %ebx
  8009bd:	8b 75 08             	mov    0x8(%ebp),%esi
  8009c0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = envs + ENVX(sys_getenvid());
  8009c3:	e8 01 0c 00 00       	call   8015c9 <sys_getenvid>
  8009c8:	25 ff 03 00 00       	and    $0x3ff,%eax
  8009cd:	89 c2                	mov    %eax,%edx
  8009cf:	c1 e2 07             	shl    $0x7,%edx
  8009d2:	8d 84 82 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,4),%eax
  8009d9:	a3 24 54 80 00       	mov    %eax,0x805424

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8009de:	85 f6                	test   %esi,%esi
  8009e0:	7e 07                	jle    8009e9 <libmain+0x31>
		binaryname = argv[0];
  8009e2:	8b 03                	mov    (%ebx),%eax
  8009e4:	a3 1c 40 80 00       	mov    %eax,0x80401c
	// call user main routine
	umain(argc, argv);
  8009e9:	83 ec 08             	sub    $0x8,%esp
  8009ec:	53                   	push   %ebx
  8009ed:	56                   	push   %esi
  8009ee:	e8 57 fc ff ff       	call   80064a <umain>

	// exit gracefully
	exit();
  8009f3:	e8 0c 00 00 00       	call   800a04 <exit>
  8009f8:	83 c4 10             	add    $0x10,%esp
}
  8009fb:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8009fe:	5b                   	pop    %ebx
  8009ff:	5e                   	pop    %esi
  800a00:	c9                   	leave  
  800a01:	c3                   	ret    
	...

00800a04 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800a04:	55                   	push   %ebp
  800a05:	89 e5                	mov    %esp,%ebp
  800a07:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800a0a:	e8 2f 14 00 00       	call   801e3e <close_all>
	sys_env_destroy(0);
  800a0f:	83 ec 0c             	sub    $0xc,%esp
  800a12:	6a 00                	push   $0x0
  800a14:	e8 8e 0b 00 00       	call   8015a7 <sys_env_destroy>
  800a19:	83 c4 10             	add    $0x10,%esp
}
  800a1c:	c9                   	leave  
  800a1d:	c3                   	ret    
	...

00800a20 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800a20:	55                   	push   %ebp
  800a21:	89 e5                	mov    %esp,%ebp
  800a23:	56                   	push   %esi
  800a24:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800a25:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800a28:	8b 1d 1c 40 80 00    	mov    0x80401c,%ebx
  800a2e:	e8 96 0b 00 00       	call   8015c9 <sys_getenvid>
  800a33:	83 ec 0c             	sub    $0xc,%esp
  800a36:	ff 75 0c             	pushl  0xc(%ebp)
  800a39:	ff 75 08             	pushl  0x8(%ebp)
  800a3c:	53                   	push   %ebx
  800a3d:	50                   	push   %eax
  800a3e:	68 c0 37 80 00       	push   $0x8037c0
  800a43:	e8 b0 00 00 00       	call   800af8 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800a48:	83 c4 18             	add    $0x18,%esp
  800a4b:	56                   	push   %esi
  800a4c:	ff 75 10             	pushl  0x10(%ebp)
  800a4f:	e8 53 00 00 00       	call   800aa7 <vcprintf>
	cprintf("\n");
  800a54:	c7 04 24 c0 35 80 00 	movl   $0x8035c0,(%esp)
  800a5b:	e8 98 00 00 00       	call   800af8 <cprintf>
  800a60:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800a63:	cc                   	int3   
  800a64:	eb fd                	jmp    800a63 <_panic+0x43>
	...

00800a68 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800a68:	55                   	push   %ebp
  800a69:	89 e5                	mov    %esp,%ebp
  800a6b:	53                   	push   %ebx
  800a6c:	83 ec 04             	sub    $0x4,%esp
  800a6f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800a72:	8b 03                	mov    (%ebx),%eax
  800a74:	8b 55 08             	mov    0x8(%ebp),%edx
  800a77:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  800a7b:	40                   	inc    %eax
  800a7c:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  800a7e:	3d ff 00 00 00       	cmp    $0xff,%eax
  800a83:	75 1a                	jne    800a9f <putch+0x37>
		sys_cputs(b->buf, b->idx);
  800a85:	83 ec 08             	sub    $0x8,%esp
  800a88:	68 ff 00 00 00       	push   $0xff
  800a8d:	8d 43 08             	lea    0x8(%ebx),%eax
  800a90:	50                   	push   %eax
  800a91:	e8 c7 0a 00 00       	call   80155d <sys_cputs>
		b->idx = 0;
  800a96:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800a9c:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  800a9f:	ff 43 04             	incl   0x4(%ebx)
}
  800aa2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800aa5:	c9                   	leave  
  800aa6:	c3                   	ret    

00800aa7 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800aa7:	55                   	push   %ebp
  800aa8:	89 e5                	mov    %esp,%ebp
  800aaa:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800ab0:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800ab7:	00 00 00 
	b.cnt = 0;
  800aba:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800ac1:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800ac4:	ff 75 0c             	pushl  0xc(%ebp)
  800ac7:	ff 75 08             	pushl  0x8(%ebp)
  800aca:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800ad0:	50                   	push   %eax
  800ad1:	68 68 0a 80 00       	push   $0x800a68
  800ad6:	e8 82 01 00 00       	call   800c5d <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800adb:	83 c4 08             	add    $0x8,%esp
  800ade:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800ae4:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800aea:	50                   	push   %eax
  800aeb:	e8 6d 0a 00 00       	call   80155d <sys_cputs>

	return b.cnt;
}
  800af0:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800af6:	c9                   	leave  
  800af7:	c3                   	ret    

00800af8 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800af8:	55                   	push   %ebp
  800af9:	89 e5                	mov    %esp,%ebp
  800afb:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800afe:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800b01:	50                   	push   %eax
  800b02:	ff 75 08             	pushl  0x8(%ebp)
  800b05:	e8 9d ff ff ff       	call   800aa7 <vcprintf>
	va_end(ap);

	return cnt;
}
  800b0a:	c9                   	leave  
  800b0b:	c3                   	ret    

00800b0c <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800b0c:	55                   	push   %ebp
  800b0d:	89 e5                	mov    %esp,%ebp
  800b0f:	57                   	push   %edi
  800b10:	56                   	push   %esi
  800b11:	53                   	push   %ebx
  800b12:	83 ec 2c             	sub    $0x2c,%esp
  800b15:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800b18:	89 d6                	mov    %edx,%esi
  800b1a:	8b 45 08             	mov    0x8(%ebp),%eax
  800b1d:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b20:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800b23:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800b26:	8b 45 10             	mov    0x10(%ebp),%eax
  800b29:	8b 5d 14             	mov    0x14(%ebp),%ebx
  800b2c:	8b 7d 18             	mov    0x18(%ebp),%edi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800b2f:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800b32:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  800b39:	39 55 d4             	cmp    %edx,-0x2c(%ebp)
  800b3c:	72 0c                	jb     800b4a <printnum+0x3e>
  800b3e:	3b 45 d8             	cmp    -0x28(%ebp),%eax
  800b41:	76 07                	jbe    800b4a <printnum+0x3e>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800b43:	4b                   	dec    %ebx
  800b44:	85 db                	test   %ebx,%ebx
  800b46:	7f 31                	jg     800b79 <printnum+0x6d>
  800b48:	eb 3f                	jmp    800b89 <printnum+0x7d>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800b4a:	83 ec 0c             	sub    $0xc,%esp
  800b4d:	57                   	push   %edi
  800b4e:	4b                   	dec    %ebx
  800b4f:	53                   	push   %ebx
  800b50:	50                   	push   %eax
  800b51:	83 ec 08             	sub    $0x8,%esp
  800b54:	ff 75 d4             	pushl  -0x2c(%ebp)
  800b57:	ff 75 d0             	pushl  -0x30(%ebp)
  800b5a:	ff 75 dc             	pushl  -0x24(%ebp)
  800b5d:	ff 75 d8             	pushl  -0x28(%ebp)
  800b60:	e8 d7 27 00 00       	call   80333c <__udivdi3>
  800b65:	83 c4 18             	add    $0x18,%esp
  800b68:	52                   	push   %edx
  800b69:	50                   	push   %eax
  800b6a:	89 f2                	mov    %esi,%edx
  800b6c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800b6f:	e8 98 ff ff ff       	call   800b0c <printnum>
  800b74:	83 c4 20             	add    $0x20,%esp
  800b77:	eb 10                	jmp    800b89 <printnum+0x7d>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800b79:	83 ec 08             	sub    $0x8,%esp
  800b7c:	56                   	push   %esi
  800b7d:	57                   	push   %edi
  800b7e:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800b81:	4b                   	dec    %ebx
  800b82:	83 c4 10             	add    $0x10,%esp
  800b85:	85 db                	test   %ebx,%ebx
  800b87:	7f f0                	jg     800b79 <printnum+0x6d>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800b89:	83 ec 08             	sub    $0x8,%esp
  800b8c:	56                   	push   %esi
  800b8d:	83 ec 04             	sub    $0x4,%esp
  800b90:	ff 75 d4             	pushl  -0x2c(%ebp)
  800b93:	ff 75 d0             	pushl  -0x30(%ebp)
  800b96:	ff 75 dc             	pushl  -0x24(%ebp)
  800b99:	ff 75 d8             	pushl  -0x28(%ebp)
  800b9c:	e8 b7 28 00 00       	call   803458 <__umoddi3>
  800ba1:	83 c4 14             	add    $0x14,%esp
  800ba4:	0f be 80 e3 37 80 00 	movsbl 0x8037e3(%eax),%eax
  800bab:	50                   	push   %eax
  800bac:	ff 55 e4             	call   *-0x1c(%ebp)
  800baf:	83 c4 10             	add    $0x10,%esp
}
  800bb2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bb5:	5b                   	pop    %ebx
  800bb6:	5e                   	pop    %esi
  800bb7:	5f                   	pop    %edi
  800bb8:	c9                   	leave  
  800bb9:	c3                   	ret    

00800bba <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800bba:	55                   	push   %ebp
  800bbb:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800bbd:	83 fa 01             	cmp    $0x1,%edx
  800bc0:	7e 0e                	jle    800bd0 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800bc2:	8b 10                	mov    (%eax),%edx
  800bc4:	8d 4a 08             	lea    0x8(%edx),%ecx
  800bc7:	89 08                	mov    %ecx,(%eax)
  800bc9:	8b 02                	mov    (%edx),%eax
  800bcb:	8b 52 04             	mov    0x4(%edx),%edx
  800bce:	eb 22                	jmp    800bf2 <getuint+0x38>
	else if (lflag)
  800bd0:	85 d2                	test   %edx,%edx
  800bd2:	74 10                	je     800be4 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800bd4:	8b 10                	mov    (%eax),%edx
  800bd6:	8d 4a 04             	lea    0x4(%edx),%ecx
  800bd9:	89 08                	mov    %ecx,(%eax)
  800bdb:	8b 02                	mov    (%edx),%eax
  800bdd:	ba 00 00 00 00       	mov    $0x0,%edx
  800be2:	eb 0e                	jmp    800bf2 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800be4:	8b 10                	mov    (%eax),%edx
  800be6:	8d 4a 04             	lea    0x4(%edx),%ecx
  800be9:	89 08                	mov    %ecx,(%eax)
  800beb:	8b 02                	mov    (%edx),%eax
  800bed:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800bf2:	c9                   	leave  
  800bf3:	c3                   	ret    

00800bf4 <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
  800bf4:	55                   	push   %ebp
  800bf5:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800bf7:	83 fa 01             	cmp    $0x1,%edx
  800bfa:	7e 0e                	jle    800c0a <getint+0x16>
		return va_arg(*ap, long long);
  800bfc:	8b 10                	mov    (%eax),%edx
  800bfe:	8d 4a 08             	lea    0x8(%edx),%ecx
  800c01:	89 08                	mov    %ecx,(%eax)
  800c03:	8b 02                	mov    (%edx),%eax
  800c05:	8b 52 04             	mov    0x4(%edx),%edx
  800c08:	eb 1a                	jmp    800c24 <getint+0x30>
	else if (lflag)
  800c0a:	85 d2                	test   %edx,%edx
  800c0c:	74 0c                	je     800c1a <getint+0x26>
		return va_arg(*ap, long);
  800c0e:	8b 10                	mov    (%eax),%edx
  800c10:	8d 4a 04             	lea    0x4(%edx),%ecx
  800c13:	89 08                	mov    %ecx,(%eax)
  800c15:	8b 02                	mov    (%edx),%eax
  800c17:	99                   	cltd   
  800c18:	eb 0a                	jmp    800c24 <getint+0x30>
	else
		return va_arg(*ap, int);
  800c1a:	8b 10                	mov    (%eax),%edx
  800c1c:	8d 4a 04             	lea    0x4(%edx),%ecx
  800c1f:	89 08                	mov    %ecx,(%eax)
  800c21:	8b 02                	mov    (%edx),%eax
  800c23:	99                   	cltd   
}
  800c24:	c9                   	leave  
  800c25:	c3                   	ret    

00800c26 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800c26:	55                   	push   %ebp
  800c27:	89 e5                	mov    %esp,%ebp
  800c29:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800c2c:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  800c2f:	8b 10                	mov    (%eax),%edx
  800c31:	3b 50 04             	cmp    0x4(%eax),%edx
  800c34:	73 08                	jae    800c3e <sprintputch+0x18>
		*b->buf++ = ch;
  800c36:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c39:	88 0a                	mov    %cl,(%edx)
  800c3b:	42                   	inc    %edx
  800c3c:	89 10                	mov    %edx,(%eax)
}
  800c3e:	c9                   	leave  
  800c3f:	c3                   	ret    

00800c40 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800c40:	55                   	push   %ebp
  800c41:	89 e5                	mov    %esp,%ebp
  800c43:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800c46:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800c49:	50                   	push   %eax
  800c4a:	ff 75 10             	pushl  0x10(%ebp)
  800c4d:	ff 75 0c             	pushl  0xc(%ebp)
  800c50:	ff 75 08             	pushl  0x8(%ebp)
  800c53:	e8 05 00 00 00       	call   800c5d <vprintfmt>
	va_end(ap);
  800c58:	83 c4 10             	add    $0x10,%esp
}
  800c5b:	c9                   	leave  
  800c5c:	c3                   	ret    

00800c5d <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800c5d:	55                   	push   %ebp
  800c5e:	89 e5                	mov    %esp,%ebp
  800c60:	57                   	push   %edi
  800c61:	56                   	push   %esi
  800c62:	53                   	push   %ebx
  800c63:	83 ec 2c             	sub    $0x2c,%esp
  800c66:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800c69:	8b 75 10             	mov    0x10(%ebp),%esi
  800c6c:	eb 13                	jmp    800c81 <vprintfmt+0x24>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800c6e:	85 c0                	test   %eax,%eax
  800c70:	0f 84 6d 03 00 00    	je     800fe3 <vprintfmt+0x386>
				return;
			putch(ch, putdat);
  800c76:	83 ec 08             	sub    $0x8,%esp
  800c79:	57                   	push   %edi
  800c7a:	50                   	push   %eax
  800c7b:	ff 55 08             	call   *0x8(%ebp)
  800c7e:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800c81:	0f b6 06             	movzbl (%esi),%eax
  800c84:	46                   	inc    %esi
  800c85:	83 f8 25             	cmp    $0x25,%eax
  800c88:	75 e4                	jne    800c6e <vprintfmt+0x11>
  800c8a:	c6 45 dc 20          	movb   $0x20,-0x24(%ebp)
  800c8e:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  800c95:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
  800c9c:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  800ca3:	b9 00 00 00 00       	mov    $0x0,%ecx
  800ca8:	eb 28                	jmp    800cd2 <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800caa:	89 de                	mov    %ebx,%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  800cac:	c6 45 dc 2d          	movb   $0x2d,-0x24(%ebp)
  800cb0:	eb 20                	jmp    800cd2 <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800cb2:	89 de                	mov    %ebx,%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800cb4:	c6 45 dc 30          	movb   $0x30,-0x24(%ebp)
  800cb8:	eb 18                	jmp    800cd2 <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800cba:	89 de                	mov    %ebx,%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  800cbc:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800cc3:	eb 0d                	jmp    800cd2 <vprintfmt+0x75>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  800cc5:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  800cc8:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800ccb:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800cd2:	8a 06                	mov    (%esi),%al
  800cd4:	0f b6 d0             	movzbl %al,%edx
  800cd7:	8d 5e 01             	lea    0x1(%esi),%ebx
  800cda:	83 e8 23             	sub    $0x23,%eax
  800cdd:	3c 55                	cmp    $0x55,%al
  800cdf:	0f 87 e0 02 00 00    	ja     800fc5 <vprintfmt+0x368>
  800ce5:	0f b6 c0             	movzbl %al,%eax
  800ce8:	ff 24 85 20 39 80 00 	jmp    *0x803920(,%eax,4)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800cef:	83 ea 30             	sub    $0x30,%edx
  800cf2:	89 55 d4             	mov    %edx,-0x2c(%ebp)
				ch = *fmt;
  800cf5:	0f be 03             	movsbl (%ebx),%eax
				if (ch < '0' || ch > '9')
  800cf8:	8d 50 d0             	lea    -0x30(%eax),%edx
  800cfb:	83 fa 09             	cmp    $0x9,%edx
  800cfe:	77 44                	ja     800d44 <vprintfmt+0xe7>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800d00:	89 de                	mov    %ebx,%esi
  800d02:	8b 55 d4             	mov    -0x2c(%ebp),%edx
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800d05:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
  800d06:	8d 14 92             	lea    (%edx,%edx,4),%edx
  800d09:	8d 54 50 d0          	lea    -0x30(%eax,%edx,2),%edx
				ch = *fmt;
  800d0d:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  800d10:	8d 58 d0             	lea    -0x30(%eax),%ebx
  800d13:	83 fb 09             	cmp    $0x9,%ebx
  800d16:	76 ed                	jbe    800d05 <vprintfmt+0xa8>
  800d18:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  800d1b:	eb 29                	jmp    800d46 <vprintfmt+0xe9>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800d1d:	8b 45 14             	mov    0x14(%ebp),%eax
  800d20:	8d 50 04             	lea    0x4(%eax),%edx
  800d23:	89 55 14             	mov    %edx,0x14(%ebp)
  800d26:	8b 00                	mov    (%eax),%eax
  800d28:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800d2b:	89 de                	mov    %ebx,%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800d2d:	eb 17                	jmp    800d46 <vprintfmt+0xe9>

		case '.':
			if (width < 0)
  800d2f:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800d33:	78 85                	js     800cba <vprintfmt+0x5d>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800d35:	89 de                	mov    %ebx,%esi
  800d37:	eb 99                	jmp    800cd2 <vprintfmt+0x75>
  800d39:	89 de                	mov    %ebx,%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800d3b:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
			goto reswitch;
  800d42:	eb 8e                	jmp    800cd2 <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800d44:	89 de                	mov    %ebx,%esi
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  800d46:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800d4a:	79 86                	jns    800cd2 <vprintfmt+0x75>
  800d4c:	e9 74 ff ff ff       	jmp    800cc5 <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800d51:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800d52:	89 de                	mov    %ebx,%esi
  800d54:	e9 79 ff ff ff       	jmp    800cd2 <vprintfmt+0x75>
  800d59:	89 5d d8             	mov    %ebx,-0x28(%ebp)
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800d5c:	8b 45 14             	mov    0x14(%ebp),%eax
  800d5f:	8d 50 04             	lea    0x4(%eax),%edx
  800d62:	89 55 14             	mov    %edx,0x14(%ebp)
  800d65:	83 ec 08             	sub    $0x8,%esp
  800d68:	57                   	push   %edi
  800d69:	ff 30                	pushl  (%eax)
  800d6b:	ff 55 08             	call   *0x8(%ebp)
			break;
  800d6e:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800d71:	8b 75 d8             	mov    -0x28(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800d74:	e9 08 ff ff ff       	jmp    800c81 <vprintfmt+0x24>
  800d79:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// error message
		case 'e':
			err = va_arg(ap, int);
  800d7c:	8b 45 14             	mov    0x14(%ebp),%eax
  800d7f:	8d 50 04             	lea    0x4(%eax),%edx
  800d82:	89 55 14             	mov    %edx,0x14(%ebp)
  800d85:	8b 00                	mov    (%eax),%eax
  800d87:	85 c0                	test   %eax,%eax
  800d89:	79 02                	jns    800d8d <vprintfmt+0x130>
  800d8b:	f7 d8                	neg    %eax
  800d8d:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800d8f:	83 f8 0f             	cmp    $0xf,%eax
  800d92:	7f 0b                	jg     800d9f <vprintfmt+0x142>
  800d94:	8b 04 85 80 3a 80 00 	mov    0x803a80(,%eax,4),%eax
  800d9b:	85 c0                	test   %eax,%eax
  800d9d:	75 1a                	jne    800db9 <vprintfmt+0x15c>
				printfmt(putch, putdat, "error %d", err);
  800d9f:	52                   	push   %edx
  800da0:	68 fb 37 80 00       	push   $0x8037fb
  800da5:	57                   	push   %edi
  800da6:	ff 75 08             	pushl  0x8(%ebp)
  800da9:	e8 92 fe ff ff       	call   800c40 <printfmt>
  800dae:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800db1:	8b 75 d8             	mov    -0x28(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800db4:	e9 c8 fe ff ff       	jmp    800c81 <vprintfmt+0x24>
			else
				printfmt(putch, putdat, "%s", p);
  800db9:	50                   	push   %eax
  800dba:	68 04 37 80 00       	push   $0x803704
  800dbf:	57                   	push   %edi
  800dc0:	ff 75 08             	pushl  0x8(%ebp)
  800dc3:	e8 78 fe ff ff       	call   800c40 <printfmt>
  800dc8:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800dcb:	8b 75 d8             	mov    -0x28(%ebp),%esi
  800dce:	e9 ae fe ff ff       	jmp    800c81 <vprintfmt+0x24>
  800dd3:	89 5d d8             	mov    %ebx,-0x28(%ebp)
  800dd6:	89 de                	mov    %ebx,%esi
  800dd8:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  800ddb:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800dde:	8b 45 14             	mov    0x14(%ebp),%eax
  800de1:	8d 50 04             	lea    0x4(%eax),%edx
  800de4:	89 55 14             	mov    %edx,0x14(%ebp)
  800de7:	8b 00                	mov    (%eax),%eax
  800de9:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800dec:	85 c0                	test   %eax,%eax
  800dee:	75 07                	jne    800df7 <vprintfmt+0x19a>
				p = "(null)";
  800df0:	c7 45 d0 f4 37 80 00 	movl   $0x8037f4,-0x30(%ebp)
			if (width > 0 && padc != '-')
  800df7:	85 db                	test   %ebx,%ebx
  800df9:	7e 42                	jle    800e3d <vprintfmt+0x1e0>
  800dfb:	80 7d dc 2d          	cmpb   $0x2d,-0x24(%ebp)
  800dff:	74 3c                	je     800e3d <vprintfmt+0x1e0>
				for (width -= strnlen(p, precision); width > 0; width--)
  800e01:	83 ec 08             	sub    $0x8,%esp
  800e04:	51                   	push   %ecx
  800e05:	ff 75 d0             	pushl  -0x30(%ebp)
  800e08:	e8 53 03 00 00       	call   801160 <strnlen>
  800e0d:	29 c3                	sub    %eax,%ebx
  800e0f:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800e12:	83 c4 10             	add    $0x10,%esp
  800e15:	85 db                	test   %ebx,%ebx
  800e17:	7e 24                	jle    800e3d <vprintfmt+0x1e0>
					putch(padc, putdat);
  800e19:	0f be 5d dc          	movsbl -0x24(%ebp),%ebx
  800e1d:	89 75 dc             	mov    %esi,-0x24(%ebp)
  800e20:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  800e23:	83 ec 08             	sub    $0x8,%esp
  800e26:	57                   	push   %edi
  800e27:	53                   	push   %ebx
  800e28:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800e2b:	4e                   	dec    %esi
  800e2c:	83 c4 10             	add    $0x10,%esp
  800e2f:	85 f6                	test   %esi,%esi
  800e31:	7f f0                	jg     800e23 <vprintfmt+0x1c6>
  800e33:	8b 75 dc             	mov    -0x24(%ebp),%esi
  800e36:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800e3d:	8b 55 d0             	mov    -0x30(%ebp),%edx
  800e40:	0f be 02             	movsbl (%edx),%eax
  800e43:	85 c0                	test   %eax,%eax
  800e45:	75 47                	jne    800e8e <vprintfmt+0x231>
  800e47:	eb 37                	jmp    800e80 <vprintfmt+0x223>
				if (altflag && (ch < ' ' || ch > '~'))
  800e49:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800e4d:	74 16                	je     800e65 <vprintfmt+0x208>
  800e4f:	8d 50 e0             	lea    -0x20(%eax),%edx
  800e52:	83 fa 5e             	cmp    $0x5e,%edx
  800e55:	76 0e                	jbe    800e65 <vprintfmt+0x208>
					putch('?', putdat);
  800e57:	83 ec 08             	sub    $0x8,%esp
  800e5a:	57                   	push   %edi
  800e5b:	6a 3f                	push   $0x3f
  800e5d:	ff 55 08             	call   *0x8(%ebp)
  800e60:	83 c4 10             	add    $0x10,%esp
  800e63:	eb 0b                	jmp    800e70 <vprintfmt+0x213>
				else
					putch(ch, putdat);
  800e65:	83 ec 08             	sub    $0x8,%esp
  800e68:	57                   	push   %edi
  800e69:	50                   	push   %eax
  800e6a:	ff 55 08             	call   *0x8(%ebp)
  800e6d:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800e70:	ff 4d e4             	decl   -0x1c(%ebp)
  800e73:	0f be 03             	movsbl (%ebx),%eax
  800e76:	85 c0                	test   %eax,%eax
  800e78:	74 03                	je     800e7d <vprintfmt+0x220>
  800e7a:	43                   	inc    %ebx
  800e7b:	eb 1b                	jmp    800e98 <vprintfmt+0x23b>
  800e7d:	8b 75 dc             	mov    -0x24(%ebp),%esi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800e80:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800e84:	7f 1e                	jg     800ea4 <vprintfmt+0x247>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800e86:	8b 75 d8             	mov    -0x28(%ebp),%esi
  800e89:	e9 f3 fd ff ff       	jmp    800c81 <vprintfmt+0x24>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800e8e:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  800e91:	43                   	inc    %ebx
  800e92:	89 75 dc             	mov    %esi,-0x24(%ebp)
  800e95:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  800e98:	85 f6                	test   %esi,%esi
  800e9a:	78 ad                	js     800e49 <vprintfmt+0x1ec>
  800e9c:	4e                   	dec    %esi
  800e9d:	79 aa                	jns    800e49 <vprintfmt+0x1ec>
  800e9f:	8b 75 dc             	mov    -0x24(%ebp),%esi
  800ea2:	eb dc                	jmp    800e80 <vprintfmt+0x223>
  800ea4:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800ea7:	83 ec 08             	sub    $0x8,%esp
  800eaa:	57                   	push   %edi
  800eab:	6a 20                	push   $0x20
  800ead:	ff 55 08             	call   *0x8(%ebp)
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800eb0:	4b                   	dec    %ebx
  800eb1:	83 c4 10             	add    $0x10,%esp
  800eb4:	85 db                	test   %ebx,%ebx
  800eb6:	7f ef                	jg     800ea7 <vprintfmt+0x24a>
  800eb8:	e9 c4 fd ff ff       	jmp    800c81 <vprintfmt+0x24>
  800ebd:	89 5d d8             	mov    %ebx,-0x28(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800ec0:	89 ca                	mov    %ecx,%edx
  800ec2:	8d 45 14             	lea    0x14(%ebp),%eax
  800ec5:	e8 2a fd ff ff       	call   800bf4 <getint>
  800eca:	89 c3                	mov    %eax,%ebx
  800ecc:	89 d6                	mov    %edx,%esi
			if ((long long) num < 0) {
  800ece:	85 d2                	test   %edx,%edx
  800ed0:	78 0a                	js     800edc <vprintfmt+0x27f>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800ed2:	b8 0a 00 00 00       	mov    $0xa,%eax
  800ed7:	e9 b0 00 00 00       	jmp    800f8c <vprintfmt+0x32f>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  800edc:	83 ec 08             	sub    $0x8,%esp
  800edf:	57                   	push   %edi
  800ee0:	6a 2d                	push   $0x2d
  800ee2:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  800ee5:	f7 db                	neg    %ebx
  800ee7:	83 d6 00             	adc    $0x0,%esi
  800eea:	f7 de                	neg    %esi
  800eec:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800eef:	b8 0a 00 00 00       	mov    $0xa,%eax
  800ef4:	e9 93 00 00 00       	jmp    800f8c <vprintfmt+0x32f>
  800ef9:	89 5d d8             	mov    %ebx,-0x28(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800efc:	89 ca                	mov    %ecx,%edx
  800efe:	8d 45 14             	lea    0x14(%ebp),%eax
  800f01:	e8 b4 fc ff ff       	call   800bba <getuint>
  800f06:	89 c3                	mov    %eax,%ebx
  800f08:	89 d6                	mov    %edx,%esi
			base = 10;
  800f0a:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  800f0f:	eb 7b                	jmp    800f8c <vprintfmt+0x32f>
  800f11:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// (unsigned) octal
		case 'o':
            // (MIT 6.828, lab1, Ex.8)  my code : 
            num = getint(&ap, lflag);
  800f14:	89 ca                	mov    %ecx,%edx
  800f16:	8d 45 14             	lea    0x14(%ebp),%eax
  800f19:	e8 d6 fc ff ff       	call   800bf4 <getint>
  800f1e:	89 c3                	mov    %eax,%ebx
  800f20:	89 d6                	mov    %edx,%esi
            if ((long long) num < 0) {
  800f22:	85 d2                	test   %edx,%edx
  800f24:	78 07                	js     800f2d <vprintfmt+0x2d0>
                putch('-', putdat);
                num = -(long long) num;
            }
            base = 8;
  800f26:	b8 08 00 00 00       	mov    $0x8,%eax
  800f2b:	eb 5f                	jmp    800f8c <vprintfmt+0x32f>
		// (unsigned) octal
		case 'o':
            // (MIT 6.828, lab1, Ex.8)  my code : 
            num = getint(&ap, lflag);
            if ((long long) num < 0) {
                putch('-', putdat);
  800f2d:	83 ec 08             	sub    $0x8,%esp
  800f30:	57                   	push   %edi
  800f31:	6a 2d                	push   $0x2d
  800f33:	ff 55 08             	call   *0x8(%ebp)
                num = -(long long) num;
  800f36:	f7 db                	neg    %ebx
  800f38:	83 d6 00             	adc    $0x0,%esi
  800f3b:	f7 de                	neg    %esi
  800f3d:	83 c4 10             	add    $0x10,%esp
            }
            base = 8;
  800f40:	b8 08 00 00 00       	mov    $0x8,%eax
  800f45:	eb 45                	jmp    800f8c <vprintfmt+0x32f>
  800f47:	89 5d d8             	mov    %ebx,-0x28(%ebp)
            goto number;

        // pointer
		case 'p':
			putch('0', putdat);
  800f4a:	83 ec 08             	sub    $0x8,%esp
  800f4d:	57                   	push   %edi
  800f4e:	6a 30                	push   $0x30
  800f50:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  800f53:	83 c4 08             	add    $0x8,%esp
  800f56:	57                   	push   %edi
  800f57:	6a 78                	push   $0x78
  800f59:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800f5c:	8b 45 14             	mov    0x14(%ebp),%eax
  800f5f:	8d 50 04             	lea    0x4(%eax),%edx
  800f62:	89 55 14             	mov    %edx,0x14(%ebp)

        // pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800f65:	8b 18                	mov    (%eax),%ebx
  800f67:	be 00 00 00 00       	mov    $0x0,%esi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800f6c:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800f6f:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  800f74:	eb 16                	jmp    800f8c <vprintfmt+0x32f>
  800f76:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800f79:	89 ca                	mov    %ecx,%edx
  800f7b:	8d 45 14             	lea    0x14(%ebp),%eax
  800f7e:	e8 37 fc ff ff       	call   800bba <getuint>
  800f83:	89 c3                	mov    %eax,%ebx
  800f85:	89 d6                	mov    %edx,%esi
			base = 16;
  800f87:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  800f8c:	83 ec 0c             	sub    $0xc,%esp
  800f8f:	0f be 55 dc          	movsbl -0x24(%ebp),%edx
  800f93:	52                   	push   %edx
  800f94:	ff 75 e4             	pushl  -0x1c(%ebp)
  800f97:	50                   	push   %eax
  800f98:	56                   	push   %esi
  800f99:	53                   	push   %ebx
  800f9a:	89 fa                	mov    %edi,%edx
  800f9c:	8b 45 08             	mov    0x8(%ebp),%eax
  800f9f:	e8 68 fb ff ff       	call   800b0c <printnum>
			break;
  800fa4:	83 c4 20             	add    $0x20,%esp
  800fa7:	8b 75 d8             	mov    -0x28(%ebp),%esi
  800faa:	e9 d2 fc ff ff       	jmp    800c81 <vprintfmt+0x24>
  800faf:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800fb2:	83 ec 08             	sub    $0x8,%esp
  800fb5:	57                   	push   %edi
  800fb6:	52                   	push   %edx
  800fb7:	ff 55 08             	call   *0x8(%ebp)
			break;
  800fba:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800fbd:	8b 75 d8             	mov    -0x28(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800fc0:	e9 bc fc ff ff       	jmp    800c81 <vprintfmt+0x24>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800fc5:	83 ec 08             	sub    $0x8,%esp
  800fc8:	57                   	push   %edi
  800fc9:	6a 25                	push   $0x25
  800fcb:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800fce:	83 c4 10             	add    $0x10,%esp
  800fd1:	eb 02                	jmp    800fd5 <vprintfmt+0x378>
  800fd3:	89 c6                	mov    %eax,%esi
  800fd5:	8d 46 ff             	lea    -0x1(%esi),%eax
  800fd8:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  800fdc:	75 f5                	jne    800fd3 <vprintfmt+0x376>
  800fde:	e9 9e fc ff ff       	jmp    800c81 <vprintfmt+0x24>
				/* do nothing */;
			break;
		}
	}
}
  800fe3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800fe6:	5b                   	pop    %ebx
  800fe7:	5e                   	pop    %esi
  800fe8:	5f                   	pop    %edi
  800fe9:	c9                   	leave  
  800fea:	c3                   	ret    

00800feb <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800feb:	55                   	push   %ebp
  800fec:	89 e5                	mov    %esp,%ebp
  800fee:	83 ec 18             	sub    $0x18,%esp
  800ff1:	8b 45 08             	mov    0x8(%ebp),%eax
  800ff4:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800ff7:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800ffa:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800ffe:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  801001:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  801008:	85 c0                	test   %eax,%eax
  80100a:	74 26                	je     801032 <vsnprintf+0x47>
  80100c:	85 d2                	test   %edx,%edx
  80100e:	7e 29                	jle    801039 <vsnprintf+0x4e>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  801010:	ff 75 14             	pushl  0x14(%ebp)
  801013:	ff 75 10             	pushl  0x10(%ebp)
  801016:	8d 45 ec             	lea    -0x14(%ebp),%eax
  801019:	50                   	push   %eax
  80101a:	68 26 0c 80 00       	push   $0x800c26
  80101f:	e8 39 fc ff ff       	call   800c5d <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  801024:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801027:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80102a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80102d:	83 c4 10             	add    $0x10,%esp
  801030:	eb 0c                	jmp    80103e <vsnprintf+0x53>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  801032:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801037:	eb 05                	jmp    80103e <vsnprintf+0x53>
  801039:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  80103e:	c9                   	leave  
  80103f:	c3                   	ret    

00801040 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  801040:	55                   	push   %ebp
  801041:	89 e5                	mov    %esp,%ebp
  801043:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  801046:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  801049:	50                   	push   %eax
  80104a:	ff 75 10             	pushl  0x10(%ebp)
  80104d:	ff 75 0c             	pushl  0xc(%ebp)
  801050:	ff 75 08             	pushl  0x8(%ebp)
  801053:	e8 93 ff ff ff       	call   800feb <vsnprintf>
	va_end(ap);

	return rc;
}
  801058:	c9                   	leave  
  801059:	c3                   	ret    
	...

0080105c <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
  80105c:	55                   	push   %ebp
  80105d:	89 e5                	mov    %esp,%ebp
  80105f:	57                   	push   %edi
  801060:	56                   	push   %esi
  801061:	53                   	push   %ebx
  801062:	83 ec 0c             	sub    $0xc,%esp
  801065:	8b 45 08             	mov    0x8(%ebp),%eax

#if JOS_KERNEL
	if (prompt != NULL)
		cprintf("%s", prompt);
#else
	if (prompt != NULL)
  801068:	85 c0                	test   %eax,%eax
  80106a:	74 13                	je     80107f <readline+0x23>
		fprintf(1, "%s", prompt);
  80106c:	83 ec 04             	sub    $0x4,%esp
  80106f:	50                   	push   %eax
  801070:	68 04 37 80 00       	push   $0x803704
  801075:	6a 01                	push   $0x1
  801077:	e8 4d 14 00 00       	call   8024c9 <fprintf>
  80107c:	83 c4 10             	add    $0x10,%esp
#endif

	i = 0;
	echoing = iscons(0);
  80107f:	83 ec 0c             	sub    $0xc,%esp
  801082:	6a 00                	push   $0x0
  801084:	e8 b1 f8 ff ff       	call   80093a <iscons>
  801089:	89 c7                	mov    %eax,%edi
  80108b:	83 c4 10             	add    $0x10,%esp
#else
	if (prompt != NULL)
		fprintf(1, "%s", prompt);
#endif

	i = 0;
  80108e:	be 00 00 00 00       	mov    $0x0,%esi
	echoing = iscons(0);
	while (1) {
		c = getchar();
  801093:	e8 77 f8 ff ff       	call   80090f <getchar>
  801098:	89 c3                	mov    %eax,%ebx
		if (c < 0) {
  80109a:	85 c0                	test   %eax,%eax
  80109c:	79 21                	jns    8010bf <readline+0x63>
			if (c != -E_EOF)
  80109e:	83 f8 f8             	cmp    $0xfffffff8,%eax
  8010a1:	0f 84 89 00 00 00    	je     801130 <readline+0xd4>
				cprintf("read error: %e\n", c);
  8010a7:	83 ec 08             	sub    $0x8,%esp
  8010aa:	50                   	push   %eax
  8010ab:	68 df 3a 80 00       	push   $0x803adf
  8010b0:	e8 43 fa ff ff       	call   800af8 <cprintf>
  8010b5:	83 c4 10             	add    $0x10,%esp
			return NULL;
  8010b8:	b8 00 00 00 00       	mov    $0x0,%eax
  8010bd:	eb 76                	jmp    801135 <readline+0xd9>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
  8010bf:	83 f8 08             	cmp    $0x8,%eax
  8010c2:	74 05                	je     8010c9 <readline+0x6d>
  8010c4:	83 f8 7f             	cmp    $0x7f,%eax
  8010c7:	75 18                	jne    8010e1 <readline+0x85>
  8010c9:	85 f6                	test   %esi,%esi
  8010cb:	7e 14                	jle    8010e1 <readline+0x85>
			if (echoing)
  8010cd:	85 ff                	test   %edi,%edi
  8010cf:	74 0d                	je     8010de <readline+0x82>
				cputchar('\b');
  8010d1:	83 ec 0c             	sub    $0xc,%esp
  8010d4:	6a 08                	push   $0x8
  8010d6:	e8 18 f8 ff ff       	call   8008f3 <cputchar>
  8010db:	83 c4 10             	add    $0x10,%esp
			i--;
  8010de:	4e                   	dec    %esi
  8010df:	eb b2                	jmp    801093 <readline+0x37>
		} else if (c >= ' ' && i < BUFLEN-1) {
  8010e1:	83 fb 1f             	cmp    $0x1f,%ebx
  8010e4:	7e 21                	jle    801107 <readline+0xab>
  8010e6:	81 fe fe 03 00 00    	cmp    $0x3fe,%esi
  8010ec:	7f 19                	jg     801107 <readline+0xab>
			if (echoing)
  8010ee:	85 ff                	test   %edi,%edi
  8010f0:	74 0c                	je     8010fe <readline+0xa2>
				cputchar(c);
  8010f2:	83 ec 0c             	sub    $0xc,%esp
  8010f5:	53                   	push   %ebx
  8010f6:	e8 f8 f7 ff ff       	call   8008f3 <cputchar>
  8010fb:	83 c4 10             	add    $0x10,%esp
			buf[i++] = c;
  8010fe:	88 9e 20 50 80 00    	mov    %bl,0x805020(%esi)
  801104:	46                   	inc    %esi
  801105:	eb 8c                	jmp    801093 <readline+0x37>
		} else if (c == '\n' || c == '\r') {
  801107:	83 fb 0a             	cmp    $0xa,%ebx
  80110a:	74 05                	je     801111 <readline+0xb5>
  80110c:	83 fb 0d             	cmp    $0xd,%ebx
  80110f:	75 82                	jne    801093 <readline+0x37>
			if (echoing)
  801111:	85 ff                	test   %edi,%edi
  801113:	74 0d                	je     801122 <readline+0xc6>
				cputchar('\n');
  801115:	83 ec 0c             	sub    $0xc,%esp
  801118:	6a 0a                	push   $0xa
  80111a:	e8 d4 f7 ff ff       	call   8008f3 <cputchar>
  80111f:	83 c4 10             	add    $0x10,%esp
			buf[i] = 0;
  801122:	c6 86 20 50 80 00 00 	movb   $0x0,0x805020(%esi)
			return buf;
  801129:	b8 20 50 80 00       	mov    $0x805020,%eax
  80112e:	eb 05                	jmp    801135 <readline+0xd9>
	while (1) {
		c = getchar();
		if (c < 0) {
			if (c != -E_EOF)
				cprintf("read error: %e\n", c);
			return NULL;
  801130:	b8 00 00 00 00       	mov    $0x0,%eax
				cputchar('\n');
			buf[i] = 0;
			return buf;
		}
	}
}
  801135:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801138:	5b                   	pop    %ebx
  801139:	5e                   	pop    %esi
  80113a:	5f                   	pop    %edi
  80113b:	c9                   	leave  
  80113c:	c3                   	ret    
  80113d:	00 00                	add    %al,(%eax)
	...

00801140 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  801140:	55                   	push   %ebp
  801141:	89 e5                	mov    %esp,%ebp
  801143:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  801146:	80 3a 00             	cmpb   $0x0,(%edx)
  801149:	74 0e                	je     801159 <strlen+0x19>
  80114b:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  801150:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  801151:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  801155:	75 f9                	jne    801150 <strlen+0x10>
  801157:	eb 05                	jmp    80115e <strlen+0x1e>
  801159:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  80115e:	c9                   	leave  
  80115f:	c3                   	ret    

00801160 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  801160:	55                   	push   %ebp
  801161:	89 e5                	mov    %esp,%ebp
  801163:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801166:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801169:	85 d2                	test   %edx,%edx
  80116b:	74 17                	je     801184 <strnlen+0x24>
  80116d:	80 39 00             	cmpb   $0x0,(%ecx)
  801170:	74 19                	je     80118b <strnlen+0x2b>
  801172:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  801177:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801178:	39 d0                	cmp    %edx,%eax
  80117a:	74 14                	je     801190 <strnlen+0x30>
  80117c:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  801180:	75 f5                	jne    801177 <strnlen+0x17>
  801182:	eb 0c                	jmp    801190 <strnlen+0x30>
  801184:	b8 00 00 00 00       	mov    $0x0,%eax
  801189:	eb 05                	jmp    801190 <strnlen+0x30>
  80118b:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  801190:	c9                   	leave  
  801191:	c3                   	ret    

00801192 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  801192:	55                   	push   %ebp
  801193:	89 e5                	mov    %esp,%ebp
  801195:	53                   	push   %ebx
  801196:	8b 45 08             	mov    0x8(%ebp),%eax
  801199:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  80119c:	ba 00 00 00 00       	mov    $0x0,%edx
  8011a1:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  8011a4:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  8011a7:	42                   	inc    %edx
  8011a8:	84 c9                	test   %cl,%cl
  8011aa:	75 f5                	jne    8011a1 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  8011ac:	5b                   	pop    %ebx
  8011ad:	c9                   	leave  
  8011ae:	c3                   	ret    

008011af <strcat>:

char *
strcat(char *dst, const char *src)
{
  8011af:	55                   	push   %ebp
  8011b0:	89 e5                	mov    %esp,%ebp
  8011b2:	53                   	push   %ebx
  8011b3:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8011b6:	53                   	push   %ebx
  8011b7:	e8 84 ff ff ff       	call   801140 <strlen>
  8011bc:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8011bf:	ff 75 0c             	pushl  0xc(%ebp)
  8011c2:	8d 04 03             	lea    (%ebx,%eax,1),%eax
  8011c5:	50                   	push   %eax
  8011c6:	e8 c7 ff ff ff       	call   801192 <strcpy>
	return dst;
}
  8011cb:	89 d8                	mov    %ebx,%eax
  8011cd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8011d0:	c9                   	leave  
  8011d1:	c3                   	ret    

008011d2 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8011d2:	55                   	push   %ebp
  8011d3:	89 e5                	mov    %esp,%ebp
  8011d5:	56                   	push   %esi
  8011d6:	53                   	push   %ebx
  8011d7:	8b 45 08             	mov    0x8(%ebp),%eax
  8011da:	8b 55 0c             	mov    0xc(%ebp),%edx
  8011dd:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8011e0:	85 f6                	test   %esi,%esi
  8011e2:	74 15                	je     8011f9 <strncpy+0x27>
  8011e4:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
  8011e9:	8a 1a                	mov    (%edx),%bl
  8011eb:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8011ee:	80 3a 01             	cmpb   $0x1,(%edx)
  8011f1:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8011f4:	41                   	inc    %ecx
  8011f5:	39 ce                	cmp    %ecx,%esi
  8011f7:	77 f0                	ja     8011e9 <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8011f9:	5b                   	pop    %ebx
  8011fa:	5e                   	pop    %esi
  8011fb:	c9                   	leave  
  8011fc:	c3                   	ret    

008011fd <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8011fd:	55                   	push   %ebp
  8011fe:	89 e5                	mov    %esp,%ebp
  801200:	57                   	push   %edi
  801201:	56                   	push   %esi
  801202:	53                   	push   %ebx
  801203:	8b 7d 08             	mov    0x8(%ebp),%edi
  801206:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801209:	8b 75 10             	mov    0x10(%ebp),%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80120c:	85 f6                	test   %esi,%esi
  80120e:	74 32                	je     801242 <strlcpy+0x45>
		while (--size > 0 && *src != '\0')
  801210:	83 fe 01             	cmp    $0x1,%esi
  801213:	74 22                	je     801237 <strlcpy+0x3a>
  801215:	8a 0b                	mov    (%ebx),%cl
  801217:	84 c9                	test   %cl,%cl
  801219:	74 20                	je     80123b <strlcpy+0x3e>
  80121b:	89 f8                	mov    %edi,%eax
  80121d:	ba 00 00 00 00       	mov    $0x0,%edx
	}
	return ret;
}

size_t
strlcpy(char *dst, const char *src, size_t size)
  801222:	83 ee 02             	sub    $0x2,%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  801225:	88 08                	mov    %cl,(%eax)
  801227:	40                   	inc    %eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  801228:	39 f2                	cmp    %esi,%edx
  80122a:	74 11                	je     80123d <strlcpy+0x40>
  80122c:	8a 4c 13 01          	mov    0x1(%ebx,%edx,1),%cl
  801230:	42                   	inc    %edx
  801231:	84 c9                	test   %cl,%cl
  801233:	75 f0                	jne    801225 <strlcpy+0x28>
  801235:	eb 06                	jmp    80123d <strlcpy+0x40>
  801237:	89 f8                	mov    %edi,%eax
  801239:	eb 02                	jmp    80123d <strlcpy+0x40>
  80123b:	89 f8                	mov    %edi,%eax
			*dst++ = *src++;
		*dst = '\0';
  80123d:	c6 00 00             	movb   $0x0,(%eax)
  801240:	eb 02                	jmp    801244 <strlcpy+0x47>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  801242:	89 f8                	mov    %edi,%eax
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
		*dst = '\0';
	}
	return dst - dst_in;
  801244:	29 f8                	sub    %edi,%eax
}
  801246:	5b                   	pop    %ebx
  801247:	5e                   	pop    %esi
  801248:	5f                   	pop    %edi
  801249:	c9                   	leave  
  80124a:	c3                   	ret    

0080124b <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80124b:	55                   	push   %ebp
  80124c:	89 e5                	mov    %esp,%ebp
  80124e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801251:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  801254:	8a 01                	mov    (%ecx),%al
  801256:	84 c0                	test   %al,%al
  801258:	74 10                	je     80126a <strcmp+0x1f>
  80125a:	3a 02                	cmp    (%edx),%al
  80125c:	75 0c                	jne    80126a <strcmp+0x1f>
		p++, q++;
  80125e:	41                   	inc    %ecx
  80125f:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  801260:	8a 01                	mov    (%ecx),%al
  801262:	84 c0                	test   %al,%al
  801264:	74 04                	je     80126a <strcmp+0x1f>
  801266:	3a 02                	cmp    (%edx),%al
  801268:	74 f4                	je     80125e <strcmp+0x13>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  80126a:	0f b6 c0             	movzbl %al,%eax
  80126d:	0f b6 12             	movzbl (%edx),%edx
  801270:	29 d0                	sub    %edx,%eax
}
  801272:	c9                   	leave  
  801273:	c3                   	ret    

00801274 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  801274:	55                   	push   %ebp
  801275:	89 e5                	mov    %esp,%ebp
  801277:	53                   	push   %ebx
  801278:	8b 55 08             	mov    0x8(%ebp),%edx
  80127b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80127e:	8b 45 10             	mov    0x10(%ebp),%eax
	while (n > 0 && *p && *p == *q)
  801281:	85 c0                	test   %eax,%eax
  801283:	74 1b                	je     8012a0 <strncmp+0x2c>
  801285:	8a 1a                	mov    (%edx),%bl
  801287:	84 db                	test   %bl,%bl
  801289:	74 24                	je     8012af <strncmp+0x3b>
  80128b:	3a 19                	cmp    (%ecx),%bl
  80128d:	75 20                	jne    8012af <strncmp+0x3b>
  80128f:	48                   	dec    %eax
  801290:	74 15                	je     8012a7 <strncmp+0x33>
		n--, p++, q++;
  801292:	42                   	inc    %edx
  801293:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  801294:	8a 1a                	mov    (%edx),%bl
  801296:	84 db                	test   %bl,%bl
  801298:	74 15                	je     8012af <strncmp+0x3b>
  80129a:	3a 19                	cmp    (%ecx),%bl
  80129c:	74 f1                	je     80128f <strncmp+0x1b>
  80129e:	eb 0f                	jmp    8012af <strncmp+0x3b>
		n--, p++, q++;
	if (n == 0)
		return 0;
  8012a0:	b8 00 00 00 00       	mov    $0x0,%eax
  8012a5:	eb 05                	jmp    8012ac <strncmp+0x38>
  8012a7:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8012ac:	5b                   	pop    %ebx
  8012ad:	c9                   	leave  
  8012ae:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8012af:	0f b6 02             	movzbl (%edx),%eax
  8012b2:	0f b6 11             	movzbl (%ecx),%edx
  8012b5:	29 d0                	sub    %edx,%eax
  8012b7:	eb f3                	jmp    8012ac <strncmp+0x38>

008012b9 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8012b9:	55                   	push   %ebp
  8012ba:	89 e5                	mov    %esp,%ebp
  8012bc:	8b 45 08             	mov    0x8(%ebp),%eax
  8012bf:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  8012c2:	8a 10                	mov    (%eax),%dl
  8012c4:	84 d2                	test   %dl,%dl
  8012c6:	74 18                	je     8012e0 <strchr+0x27>
		if (*s == c)
  8012c8:	38 ca                	cmp    %cl,%dl
  8012ca:	75 06                	jne    8012d2 <strchr+0x19>
  8012cc:	eb 17                	jmp    8012e5 <strchr+0x2c>
  8012ce:	38 ca                	cmp    %cl,%dl
  8012d0:	74 13                	je     8012e5 <strchr+0x2c>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8012d2:	40                   	inc    %eax
  8012d3:	8a 10                	mov    (%eax),%dl
  8012d5:	84 d2                	test   %dl,%dl
  8012d7:	75 f5                	jne    8012ce <strchr+0x15>
		if (*s == c)
			return (char *) s;
	return 0;
  8012d9:	b8 00 00 00 00       	mov    $0x0,%eax
  8012de:	eb 05                	jmp    8012e5 <strchr+0x2c>
  8012e0:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8012e5:	c9                   	leave  
  8012e6:	c3                   	ret    

008012e7 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8012e7:	55                   	push   %ebp
  8012e8:	89 e5                	mov    %esp,%ebp
  8012ea:	8b 45 08             	mov    0x8(%ebp),%eax
  8012ed:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  8012f0:	8a 10                	mov    (%eax),%dl
  8012f2:	84 d2                	test   %dl,%dl
  8012f4:	74 11                	je     801307 <strfind+0x20>
		if (*s == c)
  8012f6:	38 ca                	cmp    %cl,%dl
  8012f8:	75 06                	jne    801300 <strfind+0x19>
  8012fa:	eb 0b                	jmp    801307 <strfind+0x20>
  8012fc:	38 ca                	cmp    %cl,%dl
  8012fe:	74 07                	je     801307 <strfind+0x20>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  801300:	40                   	inc    %eax
  801301:	8a 10                	mov    (%eax),%dl
  801303:	84 d2                	test   %dl,%dl
  801305:	75 f5                	jne    8012fc <strfind+0x15>
		if (*s == c)
			break;
	return (char *) s;
}
  801307:	c9                   	leave  
  801308:	c3                   	ret    

00801309 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  801309:	55                   	push   %ebp
  80130a:	89 e5                	mov    %esp,%ebp
  80130c:	57                   	push   %edi
  80130d:	56                   	push   %esi
  80130e:	53                   	push   %ebx
  80130f:	8b 7d 08             	mov    0x8(%ebp),%edi
  801312:	8b 45 0c             	mov    0xc(%ebp),%eax
  801315:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  801318:	85 c9                	test   %ecx,%ecx
  80131a:	74 30                	je     80134c <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  80131c:	f7 c7 03 00 00 00    	test   $0x3,%edi
  801322:	75 25                	jne    801349 <memset+0x40>
  801324:	f6 c1 03             	test   $0x3,%cl
  801327:	75 20                	jne    801349 <memset+0x40>
		c &= 0xFF;
  801329:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  80132c:	89 d3                	mov    %edx,%ebx
  80132e:	c1 e3 08             	shl    $0x8,%ebx
  801331:	89 d6                	mov    %edx,%esi
  801333:	c1 e6 18             	shl    $0x18,%esi
  801336:	89 d0                	mov    %edx,%eax
  801338:	c1 e0 10             	shl    $0x10,%eax
  80133b:	09 f0                	or     %esi,%eax
  80133d:	09 d0                	or     %edx,%eax
  80133f:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  801341:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  801344:	fc                   	cld    
  801345:	f3 ab                	rep stos %eax,%es:(%edi)
  801347:	eb 03                	jmp    80134c <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  801349:	fc                   	cld    
  80134a:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  80134c:	89 f8                	mov    %edi,%eax
  80134e:	5b                   	pop    %ebx
  80134f:	5e                   	pop    %esi
  801350:	5f                   	pop    %edi
  801351:	c9                   	leave  
  801352:	c3                   	ret    

00801353 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  801353:	55                   	push   %ebp
  801354:	89 e5                	mov    %esp,%ebp
  801356:	57                   	push   %edi
  801357:	56                   	push   %esi
  801358:	8b 45 08             	mov    0x8(%ebp),%eax
  80135b:	8b 75 0c             	mov    0xc(%ebp),%esi
  80135e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  801361:	39 c6                	cmp    %eax,%esi
  801363:	73 34                	jae    801399 <memmove+0x46>
  801365:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  801368:	39 d0                	cmp    %edx,%eax
  80136a:	73 2d                	jae    801399 <memmove+0x46>
		s += n;
		d += n;
  80136c:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80136f:	f6 c2 03             	test   $0x3,%dl
  801372:	75 1b                	jne    80138f <memmove+0x3c>
  801374:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80137a:	75 13                	jne    80138f <memmove+0x3c>
  80137c:	f6 c1 03             	test   $0x3,%cl
  80137f:	75 0e                	jne    80138f <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  801381:	83 ef 04             	sub    $0x4,%edi
  801384:	8d 72 fc             	lea    -0x4(%edx),%esi
  801387:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  80138a:	fd                   	std    
  80138b:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80138d:	eb 07                	jmp    801396 <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  80138f:	4f                   	dec    %edi
  801390:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  801393:	fd                   	std    
  801394:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  801396:	fc                   	cld    
  801397:	eb 20                	jmp    8013b9 <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801399:	f7 c6 03 00 00 00    	test   $0x3,%esi
  80139f:	75 13                	jne    8013b4 <memmove+0x61>
  8013a1:	a8 03                	test   $0x3,%al
  8013a3:	75 0f                	jne    8013b4 <memmove+0x61>
  8013a5:	f6 c1 03             	test   $0x3,%cl
  8013a8:	75 0a                	jne    8013b4 <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  8013aa:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  8013ad:	89 c7                	mov    %eax,%edi
  8013af:	fc                   	cld    
  8013b0:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8013b2:	eb 05                	jmp    8013b9 <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8013b4:	89 c7                	mov    %eax,%edi
  8013b6:	fc                   	cld    
  8013b7:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8013b9:	5e                   	pop    %esi
  8013ba:	5f                   	pop    %edi
  8013bb:	c9                   	leave  
  8013bc:	c3                   	ret    

008013bd <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8013bd:	55                   	push   %ebp
  8013be:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  8013c0:	ff 75 10             	pushl  0x10(%ebp)
  8013c3:	ff 75 0c             	pushl  0xc(%ebp)
  8013c6:	ff 75 08             	pushl  0x8(%ebp)
  8013c9:	e8 85 ff ff ff       	call   801353 <memmove>
}
  8013ce:	c9                   	leave  
  8013cf:	c3                   	ret    

008013d0 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8013d0:	55                   	push   %ebp
  8013d1:	89 e5                	mov    %esp,%ebp
  8013d3:	57                   	push   %edi
  8013d4:	56                   	push   %esi
  8013d5:	53                   	push   %ebx
  8013d6:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8013d9:	8b 75 0c             	mov    0xc(%ebp),%esi
  8013dc:	8b 7d 10             	mov    0x10(%ebp),%edi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8013df:	85 ff                	test   %edi,%edi
  8013e1:	74 32                	je     801415 <memcmp+0x45>
		if (*s1 != *s2)
  8013e3:	8a 03                	mov    (%ebx),%al
  8013e5:	8a 0e                	mov    (%esi),%cl
  8013e7:	38 c8                	cmp    %cl,%al
  8013e9:	74 19                	je     801404 <memcmp+0x34>
  8013eb:	eb 0d                	jmp    8013fa <memcmp+0x2a>
  8013ed:	8a 44 13 01          	mov    0x1(%ebx,%edx,1),%al
  8013f1:	8a 4c 16 01          	mov    0x1(%esi,%edx,1),%cl
  8013f5:	42                   	inc    %edx
  8013f6:	38 c8                	cmp    %cl,%al
  8013f8:	74 10                	je     80140a <memcmp+0x3a>
			return (int) *s1 - (int) *s2;
  8013fa:	0f b6 c0             	movzbl %al,%eax
  8013fd:	0f b6 c9             	movzbl %cl,%ecx
  801400:	29 c8                	sub    %ecx,%eax
  801402:	eb 16                	jmp    80141a <memcmp+0x4a>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801404:	4f                   	dec    %edi
  801405:	ba 00 00 00 00       	mov    $0x0,%edx
  80140a:	39 fa                	cmp    %edi,%edx
  80140c:	75 df                	jne    8013ed <memcmp+0x1d>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  80140e:	b8 00 00 00 00       	mov    $0x0,%eax
  801413:	eb 05                	jmp    80141a <memcmp+0x4a>
  801415:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80141a:	5b                   	pop    %ebx
  80141b:	5e                   	pop    %esi
  80141c:	5f                   	pop    %edi
  80141d:	c9                   	leave  
  80141e:	c3                   	ret    

0080141f <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  80141f:	55                   	push   %ebp
  801420:	89 e5                	mov    %esp,%ebp
  801422:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  801425:	89 c2                	mov    %eax,%edx
  801427:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  80142a:	39 d0                	cmp    %edx,%eax
  80142c:	73 12                	jae    801440 <memfind+0x21>
		if (*(const unsigned char *) s == (unsigned char) c)
  80142e:	8a 4d 0c             	mov    0xc(%ebp),%cl
  801431:	38 08                	cmp    %cl,(%eax)
  801433:	75 06                	jne    80143b <memfind+0x1c>
  801435:	eb 09                	jmp    801440 <memfind+0x21>
  801437:	38 08                	cmp    %cl,(%eax)
  801439:	74 05                	je     801440 <memfind+0x21>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  80143b:	40                   	inc    %eax
  80143c:	39 c2                	cmp    %eax,%edx
  80143e:	77 f7                	ja     801437 <memfind+0x18>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  801440:	c9                   	leave  
  801441:	c3                   	ret    

00801442 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  801442:	55                   	push   %ebp
  801443:	89 e5                	mov    %esp,%ebp
  801445:	57                   	push   %edi
  801446:	56                   	push   %esi
  801447:	53                   	push   %ebx
  801448:	8b 55 08             	mov    0x8(%ebp),%edx
  80144b:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  80144e:	eb 01                	jmp    801451 <strtol+0xf>
		s++;
  801450:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801451:	8a 02                	mov    (%edx),%al
  801453:	3c 20                	cmp    $0x20,%al
  801455:	74 f9                	je     801450 <strtol+0xe>
  801457:	3c 09                	cmp    $0x9,%al
  801459:	74 f5                	je     801450 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  80145b:	3c 2b                	cmp    $0x2b,%al
  80145d:	75 08                	jne    801467 <strtol+0x25>
		s++;
  80145f:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  801460:	bf 00 00 00 00       	mov    $0x0,%edi
  801465:	eb 13                	jmp    80147a <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  801467:	3c 2d                	cmp    $0x2d,%al
  801469:	75 0a                	jne    801475 <strtol+0x33>
		s++, neg = 1;
  80146b:	8d 52 01             	lea    0x1(%edx),%edx
  80146e:	bf 01 00 00 00       	mov    $0x1,%edi
  801473:	eb 05                	jmp    80147a <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  801475:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  80147a:	85 db                	test   %ebx,%ebx
  80147c:	74 05                	je     801483 <strtol+0x41>
  80147e:	83 fb 10             	cmp    $0x10,%ebx
  801481:	75 28                	jne    8014ab <strtol+0x69>
  801483:	8a 02                	mov    (%edx),%al
  801485:	3c 30                	cmp    $0x30,%al
  801487:	75 10                	jne    801499 <strtol+0x57>
  801489:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  80148d:	75 0a                	jne    801499 <strtol+0x57>
		s += 2, base = 16;
  80148f:	83 c2 02             	add    $0x2,%edx
  801492:	bb 10 00 00 00       	mov    $0x10,%ebx
  801497:	eb 12                	jmp    8014ab <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  801499:	85 db                	test   %ebx,%ebx
  80149b:	75 0e                	jne    8014ab <strtol+0x69>
  80149d:	3c 30                	cmp    $0x30,%al
  80149f:	75 05                	jne    8014a6 <strtol+0x64>
		s++, base = 8;
  8014a1:	42                   	inc    %edx
  8014a2:	b3 08                	mov    $0x8,%bl
  8014a4:	eb 05                	jmp    8014ab <strtol+0x69>
	else if (base == 0)
		base = 10;
  8014a6:	bb 0a 00 00 00       	mov    $0xa,%ebx
  8014ab:	b8 00 00 00 00       	mov    $0x0,%eax
  8014b0:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  8014b2:	8a 0a                	mov    (%edx),%cl
  8014b4:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  8014b7:	80 fb 09             	cmp    $0x9,%bl
  8014ba:	77 08                	ja     8014c4 <strtol+0x82>
			dig = *s - '0';
  8014bc:	0f be c9             	movsbl %cl,%ecx
  8014bf:	83 e9 30             	sub    $0x30,%ecx
  8014c2:	eb 1e                	jmp    8014e2 <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  8014c4:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  8014c7:	80 fb 19             	cmp    $0x19,%bl
  8014ca:	77 08                	ja     8014d4 <strtol+0x92>
			dig = *s - 'a' + 10;
  8014cc:	0f be c9             	movsbl %cl,%ecx
  8014cf:	83 e9 57             	sub    $0x57,%ecx
  8014d2:	eb 0e                	jmp    8014e2 <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  8014d4:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  8014d7:	80 fb 19             	cmp    $0x19,%bl
  8014da:	77 13                	ja     8014ef <strtol+0xad>
			dig = *s - 'A' + 10;
  8014dc:	0f be c9             	movsbl %cl,%ecx
  8014df:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  8014e2:	39 f1                	cmp    %esi,%ecx
  8014e4:	7d 0d                	jge    8014f3 <strtol+0xb1>
			break;
		s++, val = (val * base) + dig;
  8014e6:	42                   	inc    %edx
  8014e7:	0f af c6             	imul   %esi,%eax
  8014ea:	8d 04 01             	lea    (%ecx,%eax,1),%eax
		// we don't properly detect overflow!
	}
  8014ed:	eb c3                	jmp    8014b2 <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  8014ef:	89 c1                	mov    %eax,%ecx
  8014f1:	eb 02                	jmp    8014f5 <strtol+0xb3>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  8014f3:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  8014f5:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8014f9:	74 05                	je     801500 <strtol+0xbe>
		*endptr = (char *) s;
  8014fb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8014fe:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  801500:	85 ff                	test   %edi,%edi
  801502:	74 04                	je     801508 <strtol+0xc6>
  801504:	89 c8                	mov    %ecx,%eax
  801506:	f7 d8                	neg    %eax
}
  801508:	5b                   	pop    %ebx
  801509:	5e                   	pop    %esi
  80150a:	5f                   	pop    %edi
  80150b:	c9                   	leave  
  80150c:	c3                   	ret    
  80150d:	00 00                	add    %al,(%eax)
	...

00801510 <syscall>:
	return ret;
}

static int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  801510:	55                   	push   %ebp
  801511:	89 e5                	mov    %esp,%ebp
  801513:	57                   	push   %edi
  801514:	56                   	push   %esi
  801515:	53                   	push   %ebx
  801516:	83 ec 1c             	sub    $0x1c,%esp
  801519:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80151c:	89 55 e0             	mov    %edx,-0x20(%ebp)
  80151f:	89 ca                	mov    %ecx,%edx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801521:	8b 75 14             	mov    0x14(%ebp),%esi
  801524:	8b 7d 10             	mov    0x10(%ebp),%edi
  801527:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80152a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80152d:	cd 30                	int    $0x30
  80152f:	89 c2                	mov    %eax,%edx
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  801531:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  801535:	74 1c                	je     801553 <syscall+0x43>
  801537:	85 c0                	test   %eax,%eax
  801539:	7e 18                	jle    801553 <syscall+0x43>
		panic("syscall %d returned %d (> 0)", num, ret);
  80153b:	83 ec 0c             	sub    $0xc,%esp
  80153e:	50                   	push   %eax
  80153f:	ff 75 e4             	pushl  -0x1c(%ebp)
  801542:	68 ef 3a 80 00       	push   $0x803aef
  801547:	6a 42                	push   $0x42
  801549:	68 0c 3b 80 00       	push   $0x803b0c
  80154e:	e8 cd f4 ff ff       	call   800a20 <_panic>

	return ret;
}
  801553:	89 d0                	mov    %edx,%eax
  801555:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801558:	5b                   	pop    %ebx
  801559:	5e                   	pop    %esi
  80155a:	5f                   	pop    %edi
  80155b:	c9                   	leave  
  80155c:	c3                   	ret    

0080155d <sys_cputs>:

void
sys_cputs(const char *s, size_t len)
{	
  80155d:	55                   	push   %ebp
  80155e:	89 e5                	mov    %esp,%ebp
  801560:	83 ec 08             	sub    $0x8,%esp
	// my_sysenter(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
	// return;
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
  801563:	6a 00                	push   $0x0
  801565:	6a 00                	push   $0x0
  801567:	6a 00                	push   $0x0
  801569:	ff 75 0c             	pushl  0xc(%ebp)
  80156c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80156f:	ba 00 00 00 00       	mov    $0x0,%edx
  801574:	b8 00 00 00 00       	mov    $0x0,%eax
  801579:	e8 92 ff ff ff       	call   801510 <syscall>
  80157e:	83 c4 10             	add    $0x10,%esp
	return;
}
  801581:	c9                   	leave  
  801582:	c3                   	ret    

00801583 <sys_cgetc>:

int
sys_cgetc(void)
{
  801583:	55                   	push   %ebp
  801584:	89 e5                	mov    %esp,%ebp
  801586:	83 ec 08             	sub    $0x8,%esp
	// return my_sysenter(SYS_cgetc, 0, 0, 0, 0, 0, 0);
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
  801589:	6a 00                	push   $0x0
  80158b:	6a 00                	push   $0x0
  80158d:	6a 00                	push   $0x0
  80158f:	6a 00                	push   $0x0
  801591:	b9 00 00 00 00       	mov    $0x0,%ecx
  801596:	ba 00 00 00 00       	mov    $0x0,%edx
  80159b:	b8 01 00 00 00       	mov    $0x1,%eax
  8015a0:	e8 6b ff ff ff       	call   801510 <syscall>
}
  8015a5:	c9                   	leave  
  8015a6:	c3                   	ret    

008015a7 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8015a7:	55                   	push   %ebp
  8015a8:	89 e5                	mov    %esp,%ebp
  8015aa:	83 ec 08             	sub    $0x8,%esp
	// return my_sysenter(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
  8015ad:	6a 00                	push   $0x0
  8015af:	6a 00                	push   $0x0
  8015b1:	6a 00                	push   $0x0
  8015b3:	6a 00                	push   $0x0
  8015b5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8015b8:	ba 01 00 00 00       	mov    $0x1,%edx
  8015bd:	b8 03 00 00 00       	mov    $0x3,%eax
  8015c2:	e8 49 ff ff ff       	call   801510 <syscall>
}
  8015c7:	c9                   	leave  
  8015c8:	c3                   	ret    

008015c9 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  8015c9:	55                   	push   %ebp
  8015ca:	89 e5                	mov    %esp,%ebp
  8015cc:	83 ec 08             	sub    $0x8,%esp
	// return my_sysenter(SYS_getenvid, 0, 0, 0, 0, 0, 0);
	return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
  8015cf:	6a 00                	push   $0x0
  8015d1:	6a 00                	push   $0x0
  8015d3:	6a 00                	push   $0x0
  8015d5:	6a 00                	push   $0x0
  8015d7:	b9 00 00 00 00       	mov    $0x0,%ecx
  8015dc:	ba 00 00 00 00       	mov    $0x0,%edx
  8015e1:	b8 02 00 00 00       	mov    $0x2,%eax
  8015e6:	e8 25 ff ff ff       	call   801510 <syscall>
}
  8015eb:	c9                   	leave  
  8015ec:	c3                   	ret    

008015ed <sys_yield>:

void
sys_yield(void)
{
  8015ed:	55                   	push   %ebp
  8015ee:	89 e5                	mov    %esp,%ebp
  8015f0:	83 ec 08             	sub    $0x8,%esp
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
  8015f3:	6a 00                	push   $0x0
  8015f5:	6a 00                	push   $0x0
  8015f7:	6a 00                	push   $0x0
  8015f9:	6a 00                	push   $0x0
  8015fb:	b9 00 00 00 00       	mov    $0x0,%ecx
  801600:	ba 00 00 00 00       	mov    $0x0,%edx
  801605:	b8 0b 00 00 00       	mov    $0xb,%eax
  80160a:	e8 01 ff ff ff       	call   801510 <syscall>
  80160f:	83 c4 10             	add    $0x10,%esp
}
  801612:	c9                   	leave  
  801613:	c3                   	ret    

00801614 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  801614:	55                   	push   %ebp
  801615:	89 e5                	mov    %esp,%ebp
  801617:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
  80161a:	6a 00                	push   $0x0
  80161c:	6a 00                	push   $0x0
  80161e:	ff 75 10             	pushl  0x10(%ebp)
  801621:	ff 75 0c             	pushl  0xc(%ebp)
  801624:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801627:	ba 01 00 00 00       	mov    $0x1,%edx
  80162c:	b8 04 00 00 00       	mov    $0x4,%eax
  801631:	e8 da fe ff ff       	call   801510 <syscall>
}
  801636:	c9                   	leave  
  801637:	c3                   	ret    

00801638 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  801638:	55                   	push   %ebp
  801639:	89 e5                	mov    %esp,%ebp
  80163b:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
  80163e:	ff 75 18             	pushl  0x18(%ebp)
  801641:	ff 75 14             	pushl  0x14(%ebp)
  801644:	ff 75 10             	pushl  0x10(%ebp)
  801647:	ff 75 0c             	pushl  0xc(%ebp)
  80164a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80164d:	ba 01 00 00 00       	mov    $0x1,%edx
  801652:	b8 05 00 00 00       	mov    $0x5,%eax
  801657:	e8 b4 fe ff ff       	call   801510 <syscall>
}
  80165c:	c9                   	leave  
  80165d:	c3                   	ret    

0080165e <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  80165e:	55                   	push   %ebp
  80165f:	89 e5                	mov    %esp,%ebp
  801661:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
  801664:	6a 00                	push   $0x0
  801666:	6a 00                	push   $0x0
  801668:	6a 00                	push   $0x0
  80166a:	ff 75 0c             	pushl  0xc(%ebp)
  80166d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801670:	ba 01 00 00 00       	mov    $0x1,%edx
  801675:	b8 06 00 00 00       	mov    $0x6,%eax
  80167a:	e8 91 fe ff ff       	call   801510 <syscall>
}
  80167f:	c9                   	leave  
  801680:	c3                   	ret    

00801681 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  801681:	55                   	push   %ebp
  801682:	89 e5                	mov    %esp,%ebp
  801684:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
  801687:	6a 00                	push   $0x0
  801689:	6a 00                	push   $0x0
  80168b:	6a 00                	push   $0x0
  80168d:	ff 75 0c             	pushl  0xc(%ebp)
  801690:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801693:	ba 01 00 00 00       	mov    $0x1,%edx
  801698:	b8 08 00 00 00       	mov    $0x8,%eax
  80169d:	e8 6e fe ff ff       	call   801510 <syscall>
}
  8016a2:	c9                   	leave  
  8016a3:	c3                   	ret    

008016a4 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  8016a4:	55                   	push   %ebp
  8016a5:	89 e5                	mov    %esp,%ebp
  8016a7:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
  8016aa:	6a 00                	push   $0x0
  8016ac:	6a 00                	push   $0x0
  8016ae:	6a 00                	push   $0x0
  8016b0:	ff 75 0c             	pushl  0xc(%ebp)
  8016b3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8016b6:	ba 01 00 00 00       	mov    $0x1,%edx
  8016bb:	b8 09 00 00 00       	mov    $0x9,%eax
  8016c0:	e8 4b fe ff ff       	call   801510 <syscall>
}
  8016c5:	c9                   	leave  
  8016c6:	c3                   	ret    

008016c7 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8016c7:	55                   	push   %ebp
  8016c8:	89 e5                	mov    %esp,%ebp
  8016ca:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
  8016cd:	6a 00                	push   $0x0
  8016cf:	6a 00                	push   $0x0
  8016d1:	6a 00                	push   $0x0
  8016d3:	ff 75 0c             	pushl  0xc(%ebp)
  8016d6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8016d9:	ba 01 00 00 00       	mov    $0x1,%edx
  8016de:	b8 0a 00 00 00       	mov    $0xa,%eax
  8016e3:	e8 28 fe ff ff       	call   801510 <syscall>
}
  8016e8:	c9                   	leave  
  8016e9:	c3                   	ret    

008016ea <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8016ea:	55                   	push   %ebp
  8016eb:	89 e5                	mov    %esp,%ebp
  8016ed:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
  8016f0:	6a 00                	push   $0x0
  8016f2:	ff 75 14             	pushl  0x14(%ebp)
  8016f5:	ff 75 10             	pushl  0x10(%ebp)
  8016f8:	ff 75 0c             	pushl  0xc(%ebp)
  8016fb:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8016fe:	ba 00 00 00 00       	mov    $0x0,%edx
  801703:	b8 0c 00 00 00       	mov    $0xc,%eax
  801708:	e8 03 fe ff ff       	call   801510 <syscall>
}
  80170d:	c9                   	leave  
  80170e:	c3                   	ret    

0080170f <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  80170f:	55                   	push   %ebp
  801710:	89 e5                	mov    %esp,%ebp
  801712:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
  801715:	6a 00                	push   $0x0
  801717:	6a 00                	push   $0x0
  801719:	6a 00                	push   $0x0
  80171b:	6a 00                	push   $0x0
  80171d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801720:	ba 01 00 00 00       	mov    $0x1,%edx
  801725:	b8 0d 00 00 00       	mov    $0xd,%eax
  80172a:	e8 e1 fd ff ff       	call   801510 <syscall>
}
  80172f:	c9                   	leave  
  801730:	c3                   	ret    

00801731 <sys_set_priority>:

int
sys_set_priority(envid_t envid, uint32_t new_priority)
{
  801731:	55                   	push   %ebp
  801732:	89 e5                	mov    %esp,%ebp
  801734:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_set_priority, 0, envid, new_priority, 0, 0, 0);
  801737:	6a 00                	push   $0x0
  801739:	6a 00                	push   $0x0
  80173b:	6a 00                	push   $0x0
  80173d:	ff 75 0c             	pushl  0xc(%ebp)
  801740:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801743:	ba 00 00 00 00       	mov    $0x0,%edx
  801748:	b8 0e 00 00 00       	mov    $0xe,%eax
  80174d:	e8 be fd ff ff       	call   801510 <syscall>
}
  801752:	c9                   	leave  
  801753:	c3                   	ret    

00801754 <sys_exec>:

int
sys_exec(uint32_t eip, uint32_t esp, void * ph, uint32_t elf_phnum)
{
  801754:	55                   	push   %ebp
  801755:	89 e5                	mov    %esp,%ebp
  801757:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_exec, 0, eip, esp, (uint32_t)ph, elf_phnum, 0);
  80175a:	6a 00                	push   $0x0
  80175c:	ff 75 14             	pushl  0x14(%ebp)
  80175f:	ff 75 10             	pushl  0x10(%ebp)
  801762:	ff 75 0c             	pushl  0xc(%ebp)
  801765:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801768:	ba 00 00 00 00       	mov    $0x0,%edx
  80176d:	b8 0f 00 00 00       	mov    $0xf,%eax
  801772:	e8 99 fd ff ff       	call   801510 <syscall>
} 
  801777:	c9                   	leave  
  801778:	c3                   	ret    

00801779 <sys_join>:

// thread:
int
sys_join(envid_t envid)
{
  801779:	55                   	push   %ebp
  80177a:	89 e5                	mov    %esp,%ebp
  80177c:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_join, 0, envid, 0, 0, 0, 0);
  80177f:	6a 00                	push   $0x0
  801781:	6a 00                	push   $0x0
  801783:	6a 00                	push   $0x0
  801785:	6a 00                	push   $0x0
  801787:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80178a:	ba 00 00 00 00       	mov    $0x0,%edx
  80178f:	b8 11 00 00 00       	mov    $0x11,%eax
  801794:	e8 77 fd ff ff       	call   801510 <syscall>
}
  801799:	c9                   	leave  
  80179a:	c3                   	ret    

0080179b <sys_getpid>:

envid_t
sys_getpid(void)
{
  80179b:	55                   	push   %ebp
  80179c:	89 e5                	mov    %esp,%ebp
  80179e:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_getpid, 0, 0, 0, 0, 0, 0);
  8017a1:	6a 00                	push   $0x0
  8017a3:	6a 00                	push   $0x0
  8017a5:	6a 00                	push   $0x0
  8017a7:	6a 00                	push   $0x0
  8017a9:	b9 00 00 00 00       	mov    $0x0,%ecx
  8017ae:	ba 00 00 00 00       	mov    $0x0,%edx
  8017b3:	b8 10 00 00 00       	mov    $0x10,%eax
  8017b8:	e8 53 fd ff ff       	call   801510 <syscall>
  8017bd:	c9                   	leave  
  8017be:	c3                   	ret    
	...

008017c0 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  8017c0:	55                   	push   %ebp
  8017c1:	89 e5                	mov    %esp,%ebp
  8017c3:	53                   	push   %ebx
  8017c4:	83 ec 04             	sub    $0x4,%esp
  8017c7:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  8017ca:	8b 18                	mov    (%eax),%ebx

	// LAB 4: Your code here.
	
	// cprintf("PAGE FAULT HANDLER, 0x%08x %d\n", (uint32_t)addr, err & FEC_WR);
	
	if ((err & FEC_WR) == 0)
  8017cc:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  8017d0:	75 14                	jne    8017e6 <pgfault+0x26>
		panic("pgfault, the fault is not a write\n");
  8017d2:	83 ec 04             	sub    $0x4,%esp
  8017d5:	68 1c 3b 80 00       	push   $0x803b1c
  8017da:	6a 20                	push   $0x20
  8017dc:	68 60 3c 80 00       	push   $0x803c60
  8017e1:	e8 3a f2 ff ff       	call   800a20 <_panic>

	uint32_t uaddr = (uint32_t) addr;
	if ((uvpd[PDX(addr)] & PTE_P) == 0 || (uvpt[uaddr / PGSIZE] & PTE_COW) == 0) {
  8017e6:	89 d8                	mov    %ebx,%eax
  8017e8:	c1 e8 16             	shr    $0x16,%eax
  8017eb:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8017f2:	a8 01                	test   $0x1,%al
  8017f4:	74 11                	je     801807 <pgfault+0x47>
  8017f6:	89 d8                	mov    %ebx,%eax
  8017f8:	c1 e8 0c             	shr    $0xc,%eax
  8017fb:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801802:	f6 c4 08             	test   $0x8,%ah
  801805:	75 14                	jne    80181b <pgfault+0x5b>
		panic("pgfault, not a copy-on-write page\n");
  801807:	83 ec 04             	sub    $0x4,%esp
  80180a:	68 40 3b 80 00       	push   $0x803b40
  80180f:	6a 24                	push   $0x24
  801811:	68 60 3c 80 00       	push   $0x803c60
  801816:	e8 05 f2 ff ff       	call   800a20 <_panic>
	//   No need to explicitly delete the old page's mapping.

	// LAB 4: Your code here.

	// static int sys_page_alloc(envid_t envid, void *va, int perm)
	r = sys_page_alloc(0, (void *)PFTEMP, PTE_W | PTE_U | PTE_P);
  80181b:	83 ec 04             	sub    $0x4,%esp
  80181e:	6a 07                	push   $0x7
  801820:	68 00 f0 7f 00       	push   $0x7ff000
  801825:	6a 00                	push   $0x0
  801827:	e8 e8 fd ff ff       	call   801614 <sys_page_alloc>
	if (r < 0) panic("pgfault, sys_page_alloc error : %e\n", r);
  80182c:	83 c4 10             	add    $0x10,%esp
  80182f:	85 c0                	test   %eax,%eax
  801831:	79 12                	jns    801845 <pgfault+0x85>
  801833:	50                   	push   %eax
  801834:	68 64 3b 80 00       	push   $0x803b64
  801839:	6a 32                	push   $0x32
  80183b:	68 60 3c 80 00       	push   $0x803c60
  801840:	e8 db f1 ff ff       	call   800a20 <_panic>

	// Oh my god, I forget this at the first, it waste me a lot of time to debug!!!
	addr = ROUNDDOWN(addr, PGSIZE);
  801845:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	
	memcpy(PFTEMP, addr, PGSIZE);
  80184b:	83 ec 04             	sub    $0x4,%esp
  80184e:	68 00 10 00 00       	push   $0x1000
  801853:	53                   	push   %ebx
  801854:	68 00 f0 7f 00       	push   $0x7ff000
  801859:	e8 5f fb ff ff       	call   8013bd <memcpy>
	
	r = sys_page_map(0, PFTEMP, 0, addr, PTE_W | PTE_U | PTE_P);
  80185e:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  801865:	53                   	push   %ebx
  801866:	6a 00                	push   $0x0
  801868:	68 00 f0 7f 00       	push   $0x7ff000
  80186d:	6a 00                	push   $0x0
  80186f:	e8 c4 fd ff ff       	call   801638 <sys_page_map>
	if (r < 0) panic("pgfault, sys_page_map error : %e\n", r);
  801874:	83 c4 20             	add    $0x20,%esp
  801877:	85 c0                	test   %eax,%eax
  801879:	79 12                	jns    80188d <pgfault+0xcd>
  80187b:	50                   	push   %eax
  80187c:	68 88 3b 80 00       	push   $0x803b88
  801881:	6a 3a                	push   $0x3a
  801883:	68 60 3c 80 00       	push   $0x803c60
  801888:	e8 93 f1 ff ff       	call   800a20 <_panic>

	return;
}
  80188d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801890:	c9                   	leave  
  801891:	c3                   	ret    

00801892 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  801892:	55                   	push   %ebp
  801893:	89 e5                	mov    %esp,%ebp
  801895:	57                   	push   %edi
  801896:	56                   	push   %esi
  801897:	53                   	push   %ebx
  801898:	83 ec 28             	sub    $0x28,%esp
	// static int num = 0x100;

	// LAB 4: Your code here.
	set_pgfault_handler(pgfault);
  80189b:	68 c0 17 80 00       	push   $0x8017c0
  8018a0:	e8 a7 18 00 00       	call   80314c <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  8018a5:	ba 07 00 00 00       	mov    $0x7,%edx
  8018aa:	89 d0                	mov    %edx,%eax
  8018ac:	cd 30                	int    $0x30
  8018ae:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8018b1:	89 c7                	mov    %eax,%edi
	int childpid = sys_exofork();
	if (childpid < 0) {
  8018b3:	83 c4 10             	add    $0x10,%esp
  8018b6:	85 c0                	test   %eax,%eax
  8018b8:	79 12                	jns    8018cc <fork+0x3a>
		panic("fork sys_exofork error : %e\n", childpid);
  8018ba:	50                   	push   %eax
  8018bb:	68 6b 3c 80 00       	push   $0x803c6b
  8018c0:	6a 7f                	push   $0x7f
  8018c2:	68 60 3c 80 00       	push   $0x803c60
  8018c7:	e8 54 f1 ff ff       	call   800a20 <_panic>
	}
	int r;

	if (childpid == 0) {
  8018cc:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8018d0:	75 20                	jne    8018f2 <fork+0x60>
		// child process
		// Remember to fix "thisenv" in the child process. ??? 
		thisenv = &envs[ENVX(sys_getenvid())];
  8018d2:	e8 f2 fc ff ff       	call   8015c9 <sys_getenvid>
  8018d7:	25 ff 03 00 00       	and    $0x3ff,%eax
  8018dc:	89 c2                	mov    %eax,%edx
  8018de:	c1 e2 07             	shl    $0x7,%edx
  8018e1:	8d 84 82 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,4),%eax
  8018e8:	a3 24 54 80 00       	mov    %eax,0x805424
		// cprintf("fork child ok\n");
		return 0;
  8018ed:	e9 be 01 00 00       	jmp    801ab0 <fork+0x21e>
	if (childpid < 0) {
		panic("fork sys_exofork error : %e\n", childpid);
	}
	int r;

	if (childpid == 0) {
  8018f2:	bb 00 00 00 00       	mov    $0x0,%ebx
	} else {
		// map page to new environment
		// kernel page is already in new environment
		uint32_t i;
		for (i = 0; i != UTOP; i += PGSIZE) 
		if ((uvpd[PDX(i)] & PTE_P) && (uvpt[i / PGSIZE] & PTE_P) && (uvpt[i / PGSIZE] & PTE_U)) {
  8018f7:	89 d8                	mov    %ebx,%eax
  8018f9:	c1 e8 16             	shr    $0x16,%eax
  8018fc:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801903:	a8 01                	test   $0x1,%al
  801905:	0f 84 10 01 00 00    	je     801a1b <fork+0x189>
  80190b:	89 d8                	mov    %ebx,%eax
  80190d:	c1 e8 0c             	shr    $0xc,%eax
  801910:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801917:	f6 c2 01             	test   $0x1,%dl
  80191a:	0f 84 fb 00 00 00    	je     801a1b <fork+0x189>
  801920:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801927:	f6 c2 04             	test   $0x4,%dl
  80192a:	0f 84 eb 00 00 00    	je     801a1b <fork+0x189>
//
static int
duppage(envid_t envid, unsigned pn)
{
	// do not dup exception stack
	if (pn * PGSIZE == UXSTACKTOP - PGSIZE) return 0;
  801930:	89 c6                	mov    %eax,%esi
  801932:	c1 e6 0c             	shl    $0xc,%esi
  801935:	81 fe 00 f0 bf ee    	cmp    $0xeebff000,%esi
  80193b:	0f 84 da 00 00 00    	je     801a1b <fork+0x189>

	int r;
	void * addr = (void *)(pn * PGSIZE);
    if (uvpt[pn] & PTE_SHARE) {
  801941:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801948:	f6 c6 04             	test   $0x4,%dh
  80194b:	74 37                	je     801984 <fork+0xf2>
        r = sys_page_map(0, addr, envid, addr, uvpt[pn] & PTE_SYSCALL);
  80194d:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801954:	83 ec 0c             	sub    $0xc,%esp
  801957:	25 07 0e 00 00       	and    $0xe07,%eax
  80195c:	50                   	push   %eax
  80195d:	56                   	push   %esi
  80195e:	57                   	push   %edi
  80195f:	56                   	push   %esi
  801960:	6a 00                	push   $0x0
  801962:	e8 d1 fc ff ff       	call   801638 <sys_page_map>
        if (r < 0) panic("duppage sys_page_map error : %e\n", r);
  801967:	83 c4 20             	add    $0x20,%esp
  80196a:	85 c0                	test   %eax,%eax
  80196c:	0f 89 a9 00 00 00    	jns    801a1b <fork+0x189>
  801972:	50                   	push   %eax
  801973:	68 ac 3b 80 00       	push   $0x803bac
  801978:	6a 54                	push   $0x54
  80197a:	68 60 3c 80 00       	push   $0x803c60
  80197f:	e8 9c f0 ff ff       	call   800a20 <_panic>
    } else
	if ((uvpt[pn] & PTE_W) || (uvpt[pn] & PTE_COW)) {
  801984:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80198b:	f6 c2 02             	test   $0x2,%dl
  80198e:	75 0c                	jne    80199c <fork+0x10a>
  801990:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801997:	f6 c4 08             	test   $0x8,%ah
  80199a:	74 57                	je     8019f3 <fork+0x161>
		// cow
		r = sys_page_map(0, addr, envid, addr, PTE_COW | PTE_P | PTE_U);
  80199c:	83 ec 0c             	sub    $0xc,%esp
  80199f:	68 05 08 00 00       	push   $0x805
  8019a4:	56                   	push   %esi
  8019a5:	57                   	push   %edi
  8019a6:	56                   	push   %esi
  8019a7:	6a 00                	push   $0x0
  8019a9:	e8 8a fc ff ff       	call   801638 <sys_page_map>
		if (r < 0) panic("duppage sys_page_map error : %e\n", r);
  8019ae:	83 c4 20             	add    $0x20,%esp
  8019b1:	85 c0                	test   %eax,%eax
  8019b3:	79 12                	jns    8019c7 <fork+0x135>
  8019b5:	50                   	push   %eax
  8019b6:	68 ac 3b 80 00       	push   $0x803bac
  8019bb:	6a 59                	push   $0x59
  8019bd:	68 60 3c 80 00       	push   $0x803c60
  8019c2:	e8 59 f0 ff ff       	call   800a20 <_panic>
		
		r = sys_page_map(0, addr, 0, addr, PTE_COW | PTE_P | PTE_U);
  8019c7:	83 ec 0c             	sub    $0xc,%esp
  8019ca:	68 05 08 00 00       	push   $0x805
  8019cf:	56                   	push   %esi
  8019d0:	6a 00                	push   $0x0
  8019d2:	56                   	push   %esi
  8019d3:	6a 00                	push   $0x0
  8019d5:	e8 5e fc ff ff       	call   801638 <sys_page_map>
		if (r < 0) panic("duppage sys_page_map error : %e\n", r);
  8019da:	83 c4 20             	add    $0x20,%esp
  8019dd:	85 c0                	test   %eax,%eax
  8019df:	79 3a                	jns    801a1b <fork+0x189>
  8019e1:	50                   	push   %eax
  8019e2:	68 ac 3b 80 00       	push   $0x803bac
  8019e7:	6a 5c                	push   $0x5c
  8019e9:	68 60 3c 80 00       	push   $0x803c60
  8019ee:	e8 2d f0 ff ff       	call   800a20 <_panic>
	} else {
		// read only
		r = sys_page_map(0, addr, envid, addr, PTE_P | PTE_U);
  8019f3:	83 ec 0c             	sub    $0xc,%esp
  8019f6:	6a 05                	push   $0x5
  8019f8:	56                   	push   %esi
  8019f9:	57                   	push   %edi
  8019fa:	56                   	push   %esi
  8019fb:	6a 00                	push   $0x0
  8019fd:	e8 36 fc ff ff       	call   801638 <sys_page_map>
		if (r < 0) panic("duppage sys_page_map error : %e\n", r);
  801a02:	83 c4 20             	add    $0x20,%esp
  801a05:	85 c0                	test   %eax,%eax
  801a07:	79 12                	jns    801a1b <fork+0x189>
  801a09:	50                   	push   %eax
  801a0a:	68 ac 3b 80 00       	push   $0x803bac
  801a0f:	6a 60                	push   $0x60
  801a11:	68 60 3c 80 00       	push   $0x803c60
  801a16:	e8 05 f0 ff ff       	call   800a20 <_panic>
		return 0;
	} else {
		// map page to new environment
		// kernel page is already in new environment
		uint32_t i;
		for (i = 0; i != UTOP; i += PGSIZE) 
  801a1b:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  801a21:	81 fb 00 00 c0 ee    	cmp    $0xeec00000,%ebx
  801a27:	0f 85 ca fe ff ff    	jne    8018f7 <fork+0x65>
		if ((uvpd[PDX(i)] & PTE_P) && (uvpt[i / PGSIZE] & PTE_P) && (uvpt[i / PGSIZE] & PTE_U)) {
			duppage(childpid, i / PGSIZE);
		}

		// allocate exception stack
		r = sys_page_alloc(childpid, (void *)(UXSTACKTOP - PGSIZE), PTE_U | PTE_W | PTE_P);
  801a2d:	83 ec 04             	sub    $0x4,%esp
  801a30:	6a 07                	push   $0x7
  801a32:	68 00 f0 bf ee       	push   $0xeebff000
  801a37:	ff 75 e4             	pushl  -0x1c(%ebp)
  801a3a:	e8 d5 fb ff ff       	call   801614 <sys_page_alloc>
		if (r < 0) panic("fork, sys_page_alloc user exception stack error : %e\n", r);
  801a3f:	83 c4 10             	add    $0x10,%esp
  801a42:	85 c0                	test   %eax,%eax
  801a44:	79 15                	jns    801a5b <fork+0x1c9>
  801a46:	50                   	push   %eax
  801a47:	68 d0 3b 80 00       	push   $0x803bd0
  801a4c:	68 94 00 00 00       	push   $0x94
  801a51:	68 60 3c 80 00       	push   $0x803c60
  801a56:	e8 c5 ef ff ff       	call   800a20 <_panic>

		// set user environment user page fault handler 
		extern void _pgfault_upcall(void);
		r = sys_env_set_pgfault_upcall(childpid, _pgfault_upcall);
  801a5b:	83 ec 08             	sub    $0x8,%esp
  801a5e:	68 b8 31 80 00       	push   $0x8031b8
  801a63:	ff 75 e4             	pushl  -0x1c(%ebp)
  801a66:	e8 5c fc ff ff       	call   8016c7 <sys_env_set_pgfault_upcall>
		if (r < 0) panic("fork, set pgfault upcall fail : %e\n", r);
  801a6b:	83 c4 10             	add    $0x10,%esp
  801a6e:	85 c0                	test   %eax,%eax
  801a70:	79 15                	jns    801a87 <fork+0x1f5>
  801a72:	50                   	push   %eax
  801a73:	68 08 3c 80 00       	push   $0x803c08
  801a78:	68 99 00 00 00       	push   $0x99
  801a7d:	68 60 3c 80 00       	push   $0x803c60
  801a82:	e8 99 ef ff ff       	call   800a20 <_panic>
		r = sys_set_priority(childpid, num);
		if (r < 0) panic("fork, set priority error\n");
		*/

		// mark the child as runnable and return
		r = sys_env_set_status(childpid, ENV_RUNNABLE);
  801a87:	83 ec 08             	sub    $0x8,%esp
  801a8a:	6a 02                	push   $0x2
  801a8c:	ff 75 e4             	pushl  -0x1c(%ebp)
  801a8f:	e8 ed fb ff ff       	call   801681 <sys_env_set_status>
		if (r < 0) panic("fork, set child process to ENV_RUNNABLE error : %e\n", r);
  801a94:	83 c4 10             	add    $0x10,%esp
  801a97:	85 c0                	test   %eax,%eax
  801a99:	79 15                	jns    801ab0 <fork+0x21e>
  801a9b:	50                   	push   %eax
  801a9c:	68 2c 3c 80 00       	push   $0x803c2c
  801aa1:	68 a4 00 00 00       	push   $0xa4
  801aa6:	68 60 3c 80 00       	push   $0x803c60
  801aab:	e8 70 ef ff ff       	call   800a20 <_panic>
		// cprintf("fork father ok!")
		return childpid;
	}

	panic("fork not implemented");
}
  801ab0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801ab3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801ab6:	5b                   	pop    %ebx
  801ab7:	5e                   	pop    %esi
  801ab8:	5f                   	pop    %edi
  801ab9:	c9                   	leave  
  801aba:	c3                   	ret    

00801abb <sfork>:

// Challenge!
int
sfork(void)
{
  801abb:	55                   	push   %ebp
  801abc:	89 e5                	mov    %esp,%ebp
  801abe:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  801ac1:	68 88 3c 80 00       	push   $0x803c88
  801ac6:	68 b1 00 00 00       	push   $0xb1
  801acb:	68 60 3c 80 00       	push   $0x803c60
  801ad0:	e8 4b ef ff ff       	call   800a20 <_panic>
  801ad5:	00 00                	add    %al,(%eax)
	...

00801ad8 <argstart>:
#include <inc/args.h>
#include <inc/string.h>

void
argstart(int *argc, char **argv, struct Argstate *args)
{
  801ad8:	55                   	push   %ebp
  801ad9:	89 e5                	mov    %esp,%ebp
  801adb:	8b 55 08             	mov    0x8(%ebp),%edx
  801ade:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801ae1:	8b 45 10             	mov    0x10(%ebp),%eax
	args->argc = argc;
  801ae4:	89 10                	mov    %edx,(%eax)
	args->argv = (const char **) argv;
  801ae6:	89 48 04             	mov    %ecx,0x4(%eax)
	args->curarg = (*argc > 1 && argv ? "" : 0);
  801ae9:	83 3a 01             	cmpl   $0x1,(%edx)
  801aec:	7e 0b                	jle    801af9 <argstart+0x21>
  801aee:	85 c9                	test   %ecx,%ecx
  801af0:	75 0e                	jne    801b00 <argstart+0x28>
  801af2:	ba 00 00 00 00       	mov    $0x0,%edx
  801af7:	eb 0c                	jmp    801b05 <argstart+0x2d>
  801af9:	ba 00 00 00 00       	mov    $0x0,%edx
  801afe:	eb 05                	jmp    801b05 <argstart+0x2d>
  801b00:	ba c1 35 80 00       	mov    $0x8035c1,%edx
  801b05:	89 50 08             	mov    %edx,0x8(%eax)
	args->argvalue = 0;
  801b08:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
}
  801b0f:	c9                   	leave  
  801b10:	c3                   	ret    

00801b11 <argnext>:

int
argnext(struct Argstate *args)
{
  801b11:	55                   	push   %ebp
  801b12:	89 e5                	mov    %esp,%ebp
  801b14:	57                   	push   %edi
  801b15:	56                   	push   %esi
  801b16:	53                   	push   %ebx
  801b17:	83 ec 0c             	sub    $0xc,%esp
  801b1a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int arg;

	args->argvalue = 0;
  801b1d:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)

	// Done processing arguments if args->curarg == 0
	if (args->curarg == 0)
  801b24:	8b 43 08             	mov    0x8(%ebx),%eax
  801b27:	85 c0                	test   %eax,%eax
  801b29:	74 6c                	je     801b97 <argnext+0x86>
		return -1;

	if (!*args->curarg) {
  801b2b:	80 38 00             	cmpb   $0x0,(%eax)
  801b2e:	75 4d                	jne    801b7d <argnext+0x6c>
		// Need to process the next argument
		// Check for end of argument list
		if (*args->argc == 1
  801b30:	8b 0b                	mov    (%ebx),%ecx
  801b32:	83 39 01             	cmpl   $0x1,(%ecx)
  801b35:	74 52                	je     801b89 <argnext+0x78>
		    || args->argv[1][0] != '-'
  801b37:	8b 43 04             	mov    0x4(%ebx),%eax
  801b3a:	8d 70 04             	lea    0x4(%eax),%esi
  801b3d:	8b 50 04             	mov    0x4(%eax),%edx
  801b40:	80 3a 2d             	cmpb   $0x2d,(%edx)
  801b43:	75 44                	jne    801b89 <argnext+0x78>
		    || args->argv[1][1] == '\0')
  801b45:	8d 7a 01             	lea    0x1(%edx),%edi
  801b48:	80 7a 01 00          	cmpb   $0x0,0x1(%edx)
  801b4c:	74 3b                	je     801b89 <argnext+0x78>
			goto endofargs;
		// Shift arguments down one
		args->curarg = args->argv[1] + 1;
  801b4e:	89 7b 08             	mov    %edi,0x8(%ebx)
		memmove(args->argv + 1, args->argv + 2, sizeof(const char *) * (*args->argc - 1));
  801b51:	83 ec 04             	sub    $0x4,%esp
  801b54:	8b 11                	mov    (%ecx),%edx
  801b56:	8d 14 95 fc ff ff ff 	lea    -0x4(,%edx,4),%edx
  801b5d:	52                   	push   %edx
  801b5e:	83 c0 08             	add    $0x8,%eax
  801b61:	50                   	push   %eax
  801b62:	56                   	push   %esi
  801b63:	e8 eb f7 ff ff       	call   801353 <memmove>
		(*args->argc)--;
  801b68:	8b 03                	mov    (%ebx),%eax
  801b6a:	ff 08                	decl   (%eax)
		// Check for "--": end of argument list
		if (args->curarg[0] == '-' && args->curarg[1] == '\0')
  801b6c:	8b 43 08             	mov    0x8(%ebx),%eax
  801b6f:	83 c4 10             	add    $0x10,%esp
  801b72:	80 38 2d             	cmpb   $0x2d,(%eax)
  801b75:	75 06                	jne    801b7d <argnext+0x6c>
  801b77:	80 78 01 00          	cmpb   $0x0,0x1(%eax)
  801b7b:	74 0c                	je     801b89 <argnext+0x78>
			goto endofargs;
	}

	arg = (unsigned char) *args->curarg;
  801b7d:	8b 53 08             	mov    0x8(%ebx),%edx
  801b80:	0f b6 02             	movzbl (%edx),%eax
	args->curarg++;
  801b83:	42                   	inc    %edx
  801b84:	89 53 08             	mov    %edx,0x8(%ebx)
	return arg;
  801b87:	eb 13                	jmp    801b9c <argnext+0x8b>

    endofargs:
	args->curarg = 0;
  801b89:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
	return -1;
  801b90:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  801b95:	eb 05                	jmp    801b9c <argnext+0x8b>

	args->argvalue = 0;

	// Done processing arguments if args->curarg == 0
	if (args->curarg == 0)
		return -1;
  801b97:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	return arg;

    endofargs:
	args->curarg = 0;
	return -1;
}
  801b9c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b9f:	5b                   	pop    %ebx
  801ba0:	5e                   	pop    %esi
  801ba1:	5f                   	pop    %edi
  801ba2:	c9                   	leave  
  801ba3:	c3                   	ret    

00801ba4 <argnextvalue>:
	return (char*) (args->argvalue ? args->argvalue : argnextvalue(args));
}

char *
argnextvalue(struct Argstate *args)
{
  801ba4:	55                   	push   %ebp
  801ba5:	89 e5                	mov    %esp,%ebp
  801ba7:	56                   	push   %esi
  801ba8:	53                   	push   %ebx
  801ba9:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (!args->curarg)
  801bac:	8b 43 08             	mov    0x8(%ebx),%eax
  801baf:	85 c0                	test   %eax,%eax
  801bb1:	74 57                	je     801c0a <argnextvalue+0x66>
		return 0;
	if (*args->curarg) {
  801bb3:	80 38 00             	cmpb   $0x0,(%eax)
  801bb6:	74 0c                	je     801bc4 <argnextvalue+0x20>
		args->argvalue = args->curarg;
  801bb8:	89 43 0c             	mov    %eax,0xc(%ebx)
		args->curarg = "";
  801bbb:	c7 43 08 c1 35 80 00 	movl   $0x8035c1,0x8(%ebx)
  801bc2:	eb 41                	jmp    801c05 <argnextvalue+0x61>
	} else if (*args->argc > 1) {
  801bc4:	8b 03                	mov    (%ebx),%eax
  801bc6:	83 38 01             	cmpl   $0x1,(%eax)
  801bc9:	7e 2c                	jle    801bf7 <argnextvalue+0x53>
		args->argvalue = args->argv[1];
  801bcb:	8b 53 04             	mov    0x4(%ebx),%edx
  801bce:	8d 4a 04             	lea    0x4(%edx),%ecx
  801bd1:	8b 72 04             	mov    0x4(%edx),%esi
  801bd4:	89 73 0c             	mov    %esi,0xc(%ebx)
		memmove(args->argv + 1, args->argv + 2, sizeof(const char *) * (*args->argc - 1));
  801bd7:	83 ec 04             	sub    $0x4,%esp
  801bda:	8b 00                	mov    (%eax),%eax
  801bdc:	8d 04 85 fc ff ff ff 	lea    -0x4(,%eax,4),%eax
  801be3:	50                   	push   %eax
  801be4:	83 c2 08             	add    $0x8,%edx
  801be7:	52                   	push   %edx
  801be8:	51                   	push   %ecx
  801be9:	e8 65 f7 ff ff       	call   801353 <memmove>
		(*args->argc)--;
  801bee:	8b 03                	mov    (%ebx),%eax
  801bf0:	ff 08                	decl   (%eax)
  801bf2:	83 c4 10             	add    $0x10,%esp
  801bf5:	eb 0e                	jmp    801c05 <argnextvalue+0x61>
	} else {
		args->argvalue = 0;
  801bf7:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)
		args->curarg = 0;
  801bfe:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
	}
	return (char*) args->argvalue;
  801c05:	8b 43 0c             	mov    0xc(%ebx),%eax
  801c08:	eb 05                	jmp    801c0f <argnextvalue+0x6b>

char *
argnextvalue(struct Argstate *args)
{
	if (!args->curarg)
		return 0;
  801c0a:	b8 00 00 00 00       	mov    $0x0,%eax
	} else {
		args->argvalue = 0;
		args->curarg = 0;
	}
	return (char*) args->argvalue;
}
  801c0f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801c12:	5b                   	pop    %ebx
  801c13:	5e                   	pop    %esi
  801c14:	c9                   	leave  
  801c15:	c3                   	ret    

00801c16 <argvalue>:
	return -1;
}

char *
argvalue(struct Argstate *args)
{
  801c16:	55                   	push   %ebp
  801c17:	89 e5                	mov    %esp,%ebp
  801c19:	83 ec 08             	sub    $0x8,%esp
  801c1c:	8b 55 08             	mov    0x8(%ebp),%edx
	return (char*) (args->argvalue ? args->argvalue : argnextvalue(args));
  801c1f:	8b 42 0c             	mov    0xc(%edx),%eax
  801c22:	85 c0                	test   %eax,%eax
  801c24:	75 0c                	jne    801c32 <argvalue+0x1c>
  801c26:	83 ec 0c             	sub    $0xc,%esp
  801c29:	52                   	push   %edx
  801c2a:	e8 75 ff ff ff       	call   801ba4 <argnextvalue>
  801c2f:	83 c4 10             	add    $0x10,%esp
}
  801c32:	c9                   	leave  
  801c33:	c3                   	ret    

00801c34 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801c34:	55                   	push   %ebp
  801c35:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801c37:	8b 45 08             	mov    0x8(%ebp),%eax
  801c3a:	05 00 00 00 30       	add    $0x30000000,%eax
  801c3f:	c1 e8 0c             	shr    $0xc,%eax
}
  801c42:	c9                   	leave  
  801c43:	c3                   	ret    

00801c44 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801c44:	55                   	push   %ebp
  801c45:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  801c47:	ff 75 08             	pushl  0x8(%ebp)
  801c4a:	e8 e5 ff ff ff       	call   801c34 <fd2num>
  801c4f:	83 c4 04             	add    $0x4,%esp
  801c52:	05 20 00 0d 00       	add    $0xd0020,%eax
  801c57:	c1 e0 0c             	shl    $0xc,%eax
}
  801c5a:	c9                   	leave  
  801c5b:	c3                   	ret    

00801c5c <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801c5c:	55                   	push   %ebp
  801c5d:	89 e5                	mov    %esp,%ebp
  801c5f:	53                   	push   %ebx
  801c60:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801c63:	a1 00 dd 7b ef       	mov    0xef7bdd00,%eax
  801c68:	a8 01                	test   $0x1,%al
  801c6a:	74 34                	je     801ca0 <fd_alloc+0x44>
  801c6c:	a1 00 00 74 ef       	mov    0xef740000,%eax
  801c71:	a8 01                	test   $0x1,%al
  801c73:	74 32                	je     801ca7 <fd_alloc+0x4b>
  801c75:	b8 00 10 00 d0       	mov    $0xd0001000,%eax
  801c7a:	89 c1                	mov    %eax,%ecx
  801c7c:	89 c2                	mov    %eax,%edx
  801c7e:	c1 ea 16             	shr    $0x16,%edx
  801c81:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801c88:	f6 c2 01             	test   $0x1,%dl
  801c8b:	74 1f                	je     801cac <fd_alloc+0x50>
  801c8d:	89 c2                	mov    %eax,%edx
  801c8f:	c1 ea 0c             	shr    $0xc,%edx
  801c92:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801c99:	f6 c2 01             	test   $0x1,%dl
  801c9c:	75 17                	jne    801cb5 <fd_alloc+0x59>
  801c9e:	eb 0c                	jmp    801cac <fd_alloc+0x50>
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  801ca0:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
  801ca5:	eb 05                	jmp    801cac <fd_alloc+0x50>
  801ca7:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
  801cac:	89 0b                	mov    %ecx,(%ebx)
			return 0;
  801cae:	b8 00 00 00 00       	mov    $0x0,%eax
  801cb3:	eb 17                	jmp    801ccc <fd_alloc+0x70>
  801cb5:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  801cba:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  801cbf:	75 b9                	jne    801c7a <fd_alloc+0x1e>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801cc1:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_MAX_OPEN;
  801cc7:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  801ccc:	5b                   	pop    %ebx
  801ccd:	c9                   	leave  
  801cce:	c3                   	ret    

00801ccf <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  801ccf:	55                   	push   %ebp
  801cd0:	89 e5                	mov    %esp,%ebp
  801cd2:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801cd5:	83 f8 1f             	cmp    $0x1f,%eax
  801cd8:	77 36                	ja     801d10 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801cda:	05 00 00 0d 00       	add    $0xd0000,%eax
  801cdf:	c1 e0 0c             	shl    $0xc,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801ce2:	89 c2                	mov    %eax,%edx
  801ce4:	c1 ea 16             	shr    $0x16,%edx
  801ce7:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801cee:	f6 c2 01             	test   $0x1,%dl
  801cf1:	74 24                	je     801d17 <fd_lookup+0x48>
  801cf3:	89 c2                	mov    %eax,%edx
  801cf5:	c1 ea 0c             	shr    $0xc,%edx
  801cf8:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801cff:	f6 c2 01             	test   $0x1,%dl
  801d02:	74 1a                	je     801d1e <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  801d04:	8b 55 0c             	mov    0xc(%ebp),%edx
  801d07:	89 02                	mov    %eax,(%edx)
	return 0;
  801d09:	b8 00 00 00 00       	mov    $0x0,%eax
  801d0e:	eb 13                	jmp    801d23 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801d10:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801d15:	eb 0c                	jmp    801d23 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801d17:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801d1c:	eb 05                	jmp    801d23 <fd_lookup+0x54>
  801d1e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  801d23:	c9                   	leave  
  801d24:	c3                   	ret    

00801d25 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801d25:	55                   	push   %ebp
  801d26:	89 e5                	mov    %esp,%ebp
  801d28:	53                   	push   %ebx
  801d29:	83 ec 04             	sub    $0x4,%esp
  801d2c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801d2f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
		if (devtab[i]->dev_id == dev_id) {
  801d32:	39 0d 20 40 80 00    	cmp    %ecx,0x804020
  801d38:	74 0d                	je     801d47 <dev_lookup+0x22>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801d3a:	b8 00 00 00 00       	mov    $0x0,%eax
  801d3f:	eb 14                	jmp    801d55 <dev_lookup+0x30>
		if (devtab[i]->dev_id == dev_id) {
  801d41:	39 0a                	cmp    %ecx,(%edx)
  801d43:	75 10                	jne    801d55 <dev_lookup+0x30>
  801d45:	eb 05                	jmp    801d4c <dev_lookup+0x27>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801d47:	ba 20 40 80 00       	mov    $0x804020,%edx
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
  801d4c:	89 13                	mov    %edx,(%ebx)
			return 0;
  801d4e:	b8 00 00 00 00       	mov    $0x0,%eax
  801d53:	eb 31                	jmp    801d86 <dev_lookup+0x61>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801d55:	40                   	inc    %eax
  801d56:	8b 14 85 1c 3d 80 00 	mov    0x803d1c(,%eax,4),%edx
  801d5d:	85 d2                	test   %edx,%edx
  801d5f:	75 e0                	jne    801d41 <dev_lookup+0x1c>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801d61:	a1 24 54 80 00       	mov    0x805424,%eax
  801d66:	8b 40 48             	mov    0x48(%eax),%eax
  801d69:	83 ec 04             	sub    $0x4,%esp
  801d6c:	51                   	push   %ecx
  801d6d:	50                   	push   %eax
  801d6e:	68 a0 3c 80 00       	push   $0x803ca0
  801d73:	e8 80 ed ff ff       	call   800af8 <cprintf>
	*dev = 0;
  801d78:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_INVAL;
  801d7e:	83 c4 10             	add    $0x10,%esp
  801d81:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801d86:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801d89:	c9                   	leave  
  801d8a:	c3                   	ret    

00801d8b <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  801d8b:	55                   	push   %ebp
  801d8c:	89 e5                	mov    %esp,%ebp
  801d8e:	56                   	push   %esi
  801d8f:	53                   	push   %ebx
  801d90:	83 ec 20             	sub    $0x20,%esp
  801d93:	8b 75 08             	mov    0x8(%ebp),%esi
  801d96:	8a 45 0c             	mov    0xc(%ebp),%al
  801d99:	88 45 e7             	mov    %al,-0x19(%ebp)
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801d9c:	56                   	push   %esi
  801d9d:	e8 92 fe ff ff       	call   801c34 <fd2num>
  801da2:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801da5:	89 14 24             	mov    %edx,(%esp)
  801da8:	50                   	push   %eax
  801da9:	e8 21 ff ff ff       	call   801ccf <fd_lookup>
  801dae:	89 c3                	mov    %eax,%ebx
  801db0:	83 c4 08             	add    $0x8,%esp
  801db3:	85 c0                	test   %eax,%eax
  801db5:	78 05                	js     801dbc <fd_close+0x31>
	    || fd != fd2)
  801db7:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801dba:	74 0d                	je     801dc9 <fd_close+0x3e>
		return (must_exist ? r : 0);
  801dbc:	80 7d e7 00          	cmpb   $0x0,-0x19(%ebp)
  801dc0:	75 48                	jne    801e0a <fd_close+0x7f>
  801dc2:	bb 00 00 00 00       	mov    $0x0,%ebx
  801dc7:	eb 41                	jmp    801e0a <fd_close+0x7f>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801dc9:	83 ec 08             	sub    $0x8,%esp
  801dcc:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801dcf:	50                   	push   %eax
  801dd0:	ff 36                	pushl  (%esi)
  801dd2:	e8 4e ff ff ff       	call   801d25 <dev_lookup>
  801dd7:	89 c3                	mov    %eax,%ebx
  801dd9:	83 c4 10             	add    $0x10,%esp
  801ddc:	85 c0                	test   %eax,%eax
  801dde:	78 1c                	js     801dfc <fd_close+0x71>
		if (dev->dev_close)
  801de0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801de3:	8b 40 10             	mov    0x10(%eax),%eax
  801de6:	85 c0                	test   %eax,%eax
  801de8:	74 0d                	je     801df7 <fd_close+0x6c>
			r = (*dev->dev_close)(fd);
  801dea:	83 ec 0c             	sub    $0xc,%esp
  801ded:	56                   	push   %esi
  801dee:	ff d0                	call   *%eax
  801df0:	89 c3                	mov    %eax,%ebx
  801df2:	83 c4 10             	add    $0x10,%esp
  801df5:	eb 05                	jmp    801dfc <fd_close+0x71>
		else
			r = 0;
  801df7:	bb 00 00 00 00       	mov    $0x0,%ebx
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801dfc:	83 ec 08             	sub    $0x8,%esp
  801dff:	56                   	push   %esi
  801e00:	6a 00                	push   $0x0
  801e02:	e8 57 f8 ff ff       	call   80165e <sys_page_unmap>
	return r;
  801e07:	83 c4 10             	add    $0x10,%esp
}
  801e0a:	89 d8                	mov    %ebx,%eax
  801e0c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801e0f:	5b                   	pop    %ebx
  801e10:	5e                   	pop    %esi
  801e11:	c9                   	leave  
  801e12:	c3                   	ret    

00801e13 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801e13:	55                   	push   %ebp
  801e14:	89 e5                	mov    %esp,%ebp
  801e16:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801e19:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e1c:	50                   	push   %eax
  801e1d:	ff 75 08             	pushl  0x8(%ebp)
  801e20:	e8 aa fe ff ff       	call   801ccf <fd_lookup>
  801e25:	83 c4 08             	add    $0x8,%esp
  801e28:	85 c0                	test   %eax,%eax
  801e2a:	78 10                	js     801e3c <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  801e2c:	83 ec 08             	sub    $0x8,%esp
  801e2f:	6a 01                	push   $0x1
  801e31:	ff 75 f4             	pushl  -0xc(%ebp)
  801e34:	e8 52 ff ff ff       	call   801d8b <fd_close>
  801e39:	83 c4 10             	add    $0x10,%esp
}
  801e3c:	c9                   	leave  
  801e3d:	c3                   	ret    

00801e3e <close_all>:

void
close_all(void)
{
  801e3e:	55                   	push   %ebp
  801e3f:	89 e5                	mov    %esp,%ebp
  801e41:	53                   	push   %ebx
  801e42:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801e45:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801e4a:	83 ec 0c             	sub    $0xc,%esp
  801e4d:	53                   	push   %ebx
  801e4e:	e8 c0 ff ff ff       	call   801e13 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801e53:	43                   	inc    %ebx
  801e54:	83 c4 10             	add    $0x10,%esp
  801e57:	83 fb 20             	cmp    $0x20,%ebx
  801e5a:	75 ee                	jne    801e4a <close_all+0xc>
		close(i);
}
  801e5c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801e5f:	c9                   	leave  
  801e60:	c3                   	ret    

00801e61 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801e61:	55                   	push   %ebp
  801e62:	89 e5                	mov    %esp,%ebp
  801e64:	57                   	push   %edi
  801e65:	56                   	push   %esi
  801e66:	53                   	push   %ebx
  801e67:	83 ec 2c             	sub    $0x2c,%esp
  801e6a:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801e6d:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801e70:	50                   	push   %eax
  801e71:	ff 75 08             	pushl  0x8(%ebp)
  801e74:	e8 56 fe ff ff       	call   801ccf <fd_lookup>
  801e79:	89 c3                	mov    %eax,%ebx
  801e7b:	83 c4 08             	add    $0x8,%esp
  801e7e:	85 c0                	test   %eax,%eax
  801e80:	0f 88 c0 00 00 00    	js     801f46 <dup+0xe5>
		return r;
	close(newfdnum);
  801e86:	83 ec 0c             	sub    $0xc,%esp
  801e89:	57                   	push   %edi
  801e8a:	e8 84 ff ff ff       	call   801e13 <close>

	newfd = INDEX2FD(newfdnum);
  801e8f:	8d b7 00 00 0d 00    	lea    0xd0000(%edi),%esi
  801e95:	c1 e6 0c             	shl    $0xc,%esi
	ova = fd2data(oldfd);
  801e98:	83 c4 04             	add    $0x4,%esp
  801e9b:	ff 75 e4             	pushl  -0x1c(%ebp)
  801e9e:	e8 a1 fd ff ff       	call   801c44 <fd2data>
  801ea3:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  801ea5:	89 34 24             	mov    %esi,(%esp)
  801ea8:	e8 97 fd ff ff       	call   801c44 <fd2data>
  801ead:	83 c4 10             	add    $0x10,%esp
  801eb0:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801eb3:	89 d8                	mov    %ebx,%eax
  801eb5:	c1 e8 16             	shr    $0x16,%eax
  801eb8:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801ebf:	a8 01                	test   $0x1,%al
  801ec1:	74 37                	je     801efa <dup+0x99>
  801ec3:	89 d8                	mov    %ebx,%eax
  801ec5:	c1 e8 0c             	shr    $0xc,%eax
  801ec8:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801ecf:	f6 c2 01             	test   $0x1,%dl
  801ed2:	74 26                	je     801efa <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801ed4:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801edb:	83 ec 0c             	sub    $0xc,%esp
  801ede:	25 07 0e 00 00       	and    $0xe07,%eax
  801ee3:	50                   	push   %eax
  801ee4:	ff 75 d4             	pushl  -0x2c(%ebp)
  801ee7:	6a 00                	push   $0x0
  801ee9:	53                   	push   %ebx
  801eea:	6a 00                	push   $0x0
  801eec:	e8 47 f7 ff ff       	call   801638 <sys_page_map>
  801ef1:	89 c3                	mov    %eax,%ebx
  801ef3:	83 c4 20             	add    $0x20,%esp
  801ef6:	85 c0                	test   %eax,%eax
  801ef8:	78 2d                	js     801f27 <dup+0xc6>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801efa:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801efd:	89 c2                	mov    %eax,%edx
  801eff:	c1 ea 0c             	shr    $0xc,%edx
  801f02:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801f09:	83 ec 0c             	sub    $0xc,%esp
  801f0c:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  801f12:	52                   	push   %edx
  801f13:	56                   	push   %esi
  801f14:	6a 00                	push   $0x0
  801f16:	50                   	push   %eax
  801f17:	6a 00                	push   $0x0
  801f19:	e8 1a f7 ff ff       	call   801638 <sys_page_map>
  801f1e:	89 c3                	mov    %eax,%ebx
  801f20:	83 c4 20             	add    $0x20,%esp
  801f23:	85 c0                	test   %eax,%eax
  801f25:	79 1d                	jns    801f44 <dup+0xe3>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801f27:	83 ec 08             	sub    $0x8,%esp
  801f2a:	56                   	push   %esi
  801f2b:	6a 00                	push   $0x0
  801f2d:	e8 2c f7 ff ff       	call   80165e <sys_page_unmap>
	sys_page_unmap(0, nva);
  801f32:	83 c4 08             	add    $0x8,%esp
  801f35:	ff 75 d4             	pushl  -0x2c(%ebp)
  801f38:	6a 00                	push   $0x0
  801f3a:	e8 1f f7 ff ff       	call   80165e <sys_page_unmap>
	return r;
  801f3f:	83 c4 10             	add    $0x10,%esp
  801f42:	eb 02                	jmp    801f46 <dup+0xe5>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
		goto err;

	return newfdnum;
  801f44:	89 fb                	mov    %edi,%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  801f46:	89 d8                	mov    %ebx,%eax
  801f48:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801f4b:	5b                   	pop    %ebx
  801f4c:	5e                   	pop    %esi
  801f4d:	5f                   	pop    %edi
  801f4e:	c9                   	leave  
  801f4f:	c3                   	ret    

00801f50 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801f50:	55                   	push   %ebp
  801f51:	89 e5                	mov    %esp,%ebp
  801f53:	53                   	push   %ebx
  801f54:	83 ec 14             	sub    $0x14,%esp
  801f57:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801f5a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801f5d:	50                   	push   %eax
  801f5e:	53                   	push   %ebx
  801f5f:	e8 6b fd ff ff       	call   801ccf <fd_lookup>
  801f64:	83 c4 08             	add    $0x8,%esp
  801f67:	85 c0                	test   %eax,%eax
  801f69:	78 67                	js     801fd2 <read+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801f6b:	83 ec 08             	sub    $0x8,%esp
  801f6e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801f71:	50                   	push   %eax
  801f72:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801f75:	ff 30                	pushl  (%eax)
  801f77:	e8 a9 fd ff ff       	call   801d25 <dev_lookup>
  801f7c:	83 c4 10             	add    $0x10,%esp
  801f7f:	85 c0                	test   %eax,%eax
  801f81:	78 4f                	js     801fd2 <read+0x82>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801f83:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801f86:	8b 50 08             	mov    0x8(%eax),%edx
  801f89:	83 e2 03             	and    $0x3,%edx
  801f8c:	83 fa 01             	cmp    $0x1,%edx
  801f8f:	75 21                	jne    801fb2 <read+0x62>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801f91:	a1 24 54 80 00       	mov    0x805424,%eax
  801f96:	8b 40 48             	mov    0x48(%eax),%eax
  801f99:	83 ec 04             	sub    $0x4,%esp
  801f9c:	53                   	push   %ebx
  801f9d:	50                   	push   %eax
  801f9e:	68 e1 3c 80 00       	push   $0x803ce1
  801fa3:	e8 50 eb ff ff       	call   800af8 <cprintf>
		return -E_INVAL;
  801fa8:	83 c4 10             	add    $0x10,%esp
  801fab:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801fb0:	eb 20                	jmp    801fd2 <read+0x82>
	}
	if (!dev->dev_read)
  801fb2:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801fb5:	8b 52 08             	mov    0x8(%edx),%edx
  801fb8:	85 d2                	test   %edx,%edx
  801fba:	74 11                	je     801fcd <read+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801fbc:	83 ec 04             	sub    $0x4,%esp
  801fbf:	ff 75 10             	pushl  0x10(%ebp)
  801fc2:	ff 75 0c             	pushl  0xc(%ebp)
  801fc5:	50                   	push   %eax
  801fc6:	ff d2                	call   *%edx
  801fc8:	83 c4 10             	add    $0x10,%esp
  801fcb:	eb 05                	jmp    801fd2 <read+0x82>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801fcd:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_read)(fd, buf, n);
}
  801fd2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801fd5:	c9                   	leave  
  801fd6:	c3                   	ret    

00801fd7 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801fd7:	55                   	push   %ebp
  801fd8:	89 e5                	mov    %esp,%ebp
  801fda:	57                   	push   %edi
  801fdb:	56                   	push   %esi
  801fdc:	53                   	push   %ebx
  801fdd:	83 ec 0c             	sub    $0xc,%esp
  801fe0:	8b 7d 08             	mov    0x8(%ebp),%edi
  801fe3:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801fe6:	85 f6                	test   %esi,%esi
  801fe8:	74 31                	je     80201b <readn+0x44>
  801fea:	b8 00 00 00 00       	mov    $0x0,%eax
  801fef:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = read(fdnum, (char*)buf + tot, n - tot);
  801ff4:	83 ec 04             	sub    $0x4,%esp
  801ff7:	89 f2                	mov    %esi,%edx
  801ff9:	29 c2                	sub    %eax,%edx
  801ffb:	52                   	push   %edx
  801ffc:	03 45 0c             	add    0xc(%ebp),%eax
  801fff:	50                   	push   %eax
  802000:	57                   	push   %edi
  802001:	e8 4a ff ff ff       	call   801f50 <read>
		if (m < 0)
  802006:	83 c4 10             	add    $0x10,%esp
  802009:	85 c0                	test   %eax,%eax
  80200b:	78 17                	js     802024 <readn+0x4d>
			return m;
		if (m == 0)
  80200d:	85 c0                	test   %eax,%eax
  80200f:	74 11                	je     802022 <readn+0x4b>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  802011:	01 c3                	add    %eax,%ebx
  802013:	89 d8                	mov    %ebx,%eax
  802015:	39 f3                	cmp    %esi,%ebx
  802017:	72 db                	jb     801ff4 <readn+0x1d>
  802019:	eb 09                	jmp    802024 <readn+0x4d>
  80201b:	b8 00 00 00 00       	mov    $0x0,%eax
  802020:	eb 02                	jmp    802024 <readn+0x4d>
		m = read(fdnum, (char*)buf + tot, n - tot);
		if (m < 0)
			return m;
		if (m == 0)
  802022:	89 d8                	mov    %ebx,%eax
			break;
	}
	return tot;
}
  802024:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802027:	5b                   	pop    %ebx
  802028:	5e                   	pop    %esi
  802029:	5f                   	pop    %edi
  80202a:	c9                   	leave  
  80202b:	c3                   	ret    

0080202c <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80202c:	55                   	push   %ebp
  80202d:	89 e5                	mov    %esp,%ebp
  80202f:	53                   	push   %ebx
  802030:	83 ec 14             	sub    $0x14,%esp
  802033:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  802036:	8d 45 f0             	lea    -0x10(%ebp),%eax
  802039:	50                   	push   %eax
  80203a:	53                   	push   %ebx
  80203b:	e8 8f fc ff ff       	call   801ccf <fd_lookup>
  802040:	83 c4 08             	add    $0x8,%esp
  802043:	85 c0                	test   %eax,%eax
  802045:	78 62                	js     8020a9 <write+0x7d>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  802047:	83 ec 08             	sub    $0x8,%esp
  80204a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80204d:	50                   	push   %eax
  80204e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802051:	ff 30                	pushl  (%eax)
  802053:	e8 cd fc ff ff       	call   801d25 <dev_lookup>
  802058:	83 c4 10             	add    $0x10,%esp
  80205b:	85 c0                	test   %eax,%eax
  80205d:	78 4a                	js     8020a9 <write+0x7d>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80205f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802062:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  802066:	75 21                	jne    802089 <write+0x5d>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  802068:	a1 24 54 80 00       	mov    0x805424,%eax
  80206d:	8b 40 48             	mov    0x48(%eax),%eax
  802070:	83 ec 04             	sub    $0x4,%esp
  802073:	53                   	push   %ebx
  802074:	50                   	push   %eax
  802075:	68 fd 3c 80 00       	push   $0x803cfd
  80207a:	e8 79 ea ff ff       	call   800af8 <cprintf>
		return -E_INVAL;
  80207f:	83 c4 10             	add    $0x10,%esp
  802082:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  802087:	eb 20                	jmp    8020a9 <write+0x7d>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  802089:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80208c:	8b 52 0c             	mov    0xc(%edx),%edx
  80208f:	85 d2                	test   %edx,%edx
  802091:	74 11                	je     8020a4 <write+0x78>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  802093:	83 ec 04             	sub    $0x4,%esp
  802096:	ff 75 10             	pushl  0x10(%ebp)
  802099:	ff 75 0c             	pushl  0xc(%ebp)
  80209c:	50                   	push   %eax
  80209d:	ff d2                	call   *%edx
  80209f:	83 c4 10             	add    $0x10,%esp
  8020a2:	eb 05                	jmp    8020a9 <write+0x7d>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8020a4:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  8020a9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8020ac:	c9                   	leave  
  8020ad:	c3                   	ret    

008020ae <seek>:

int
seek(int fdnum, off_t offset)
{
  8020ae:	55                   	push   %ebp
  8020af:	89 e5                	mov    %esp,%ebp
  8020b1:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8020b4:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8020b7:	50                   	push   %eax
  8020b8:	ff 75 08             	pushl  0x8(%ebp)
  8020bb:	e8 0f fc ff ff       	call   801ccf <fd_lookup>
  8020c0:	83 c4 08             	add    $0x8,%esp
  8020c3:	85 c0                	test   %eax,%eax
  8020c5:	78 0e                	js     8020d5 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8020c7:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8020ca:	8b 55 0c             	mov    0xc(%ebp),%edx
  8020cd:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8020d0:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8020d5:	c9                   	leave  
  8020d6:	c3                   	ret    

008020d7 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8020d7:	55                   	push   %ebp
  8020d8:	89 e5                	mov    %esp,%ebp
  8020da:	53                   	push   %ebx
  8020db:	83 ec 14             	sub    $0x14,%esp
  8020de:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8020e1:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8020e4:	50                   	push   %eax
  8020e5:	53                   	push   %ebx
  8020e6:	e8 e4 fb ff ff       	call   801ccf <fd_lookup>
  8020eb:	83 c4 08             	add    $0x8,%esp
  8020ee:	85 c0                	test   %eax,%eax
  8020f0:	78 5f                	js     802151 <ftruncate+0x7a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8020f2:	83 ec 08             	sub    $0x8,%esp
  8020f5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8020f8:	50                   	push   %eax
  8020f9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8020fc:	ff 30                	pushl  (%eax)
  8020fe:	e8 22 fc ff ff       	call   801d25 <dev_lookup>
  802103:	83 c4 10             	add    $0x10,%esp
  802106:	85 c0                	test   %eax,%eax
  802108:	78 47                	js     802151 <ftruncate+0x7a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80210a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80210d:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  802111:	75 21                	jne    802134 <ftruncate+0x5d>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  802113:	a1 24 54 80 00       	mov    0x805424,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  802118:	8b 40 48             	mov    0x48(%eax),%eax
  80211b:	83 ec 04             	sub    $0x4,%esp
  80211e:	53                   	push   %ebx
  80211f:	50                   	push   %eax
  802120:	68 c0 3c 80 00       	push   $0x803cc0
  802125:	e8 ce e9 ff ff       	call   800af8 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  80212a:	83 c4 10             	add    $0x10,%esp
  80212d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  802132:	eb 1d                	jmp    802151 <ftruncate+0x7a>
	}
	if (!dev->dev_trunc)
  802134:	8b 55 f4             	mov    -0xc(%ebp),%edx
  802137:	8b 52 18             	mov    0x18(%edx),%edx
  80213a:	85 d2                	test   %edx,%edx
  80213c:	74 0e                	je     80214c <ftruncate+0x75>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80213e:	83 ec 08             	sub    $0x8,%esp
  802141:	ff 75 0c             	pushl  0xc(%ebp)
  802144:	50                   	push   %eax
  802145:	ff d2                	call   *%edx
  802147:	83 c4 10             	add    $0x10,%esp
  80214a:	eb 05                	jmp    802151 <ftruncate+0x7a>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  80214c:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  802151:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802154:	c9                   	leave  
  802155:	c3                   	ret    

00802156 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  802156:	55                   	push   %ebp
  802157:	89 e5                	mov    %esp,%ebp
  802159:	53                   	push   %ebx
  80215a:	83 ec 14             	sub    $0x14,%esp
  80215d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  802160:	8d 45 f0             	lea    -0x10(%ebp),%eax
  802163:	50                   	push   %eax
  802164:	ff 75 08             	pushl  0x8(%ebp)
  802167:	e8 63 fb ff ff       	call   801ccf <fd_lookup>
  80216c:	83 c4 08             	add    $0x8,%esp
  80216f:	85 c0                	test   %eax,%eax
  802171:	78 52                	js     8021c5 <fstat+0x6f>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  802173:	83 ec 08             	sub    $0x8,%esp
  802176:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802179:	50                   	push   %eax
  80217a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80217d:	ff 30                	pushl  (%eax)
  80217f:	e8 a1 fb ff ff       	call   801d25 <dev_lookup>
  802184:	83 c4 10             	add    $0x10,%esp
  802187:	85 c0                	test   %eax,%eax
  802189:	78 3a                	js     8021c5 <fstat+0x6f>
		return r;
	if (!dev->dev_stat)
  80218b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80218e:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  802192:	74 2c                	je     8021c0 <fstat+0x6a>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  802194:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  802197:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80219e:	00 00 00 
	stat->st_isdir = 0;
  8021a1:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8021a8:	00 00 00 
	stat->st_dev = dev;
  8021ab:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8021b1:	83 ec 08             	sub    $0x8,%esp
  8021b4:	53                   	push   %ebx
  8021b5:	ff 75 f0             	pushl  -0x10(%ebp)
  8021b8:	ff 50 14             	call   *0x14(%eax)
  8021bb:	83 c4 10             	add    $0x10,%esp
  8021be:	eb 05                	jmp    8021c5 <fstat+0x6f>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8021c0:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8021c5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8021c8:	c9                   	leave  
  8021c9:	c3                   	ret    

008021ca <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8021ca:	55                   	push   %ebp
  8021cb:	89 e5                	mov    %esp,%ebp
  8021cd:	56                   	push   %esi
  8021ce:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8021cf:	83 ec 08             	sub    $0x8,%esp
  8021d2:	6a 00                	push   $0x0
  8021d4:	ff 75 08             	pushl  0x8(%ebp)
  8021d7:	e8 78 01 00 00       	call   802354 <open>
  8021dc:	89 c3                	mov    %eax,%ebx
  8021de:	83 c4 10             	add    $0x10,%esp
  8021e1:	85 c0                	test   %eax,%eax
  8021e3:	78 1b                	js     802200 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8021e5:	83 ec 08             	sub    $0x8,%esp
  8021e8:	ff 75 0c             	pushl  0xc(%ebp)
  8021eb:	50                   	push   %eax
  8021ec:	e8 65 ff ff ff       	call   802156 <fstat>
  8021f1:	89 c6                	mov    %eax,%esi
	close(fd);
  8021f3:	89 1c 24             	mov    %ebx,(%esp)
  8021f6:	e8 18 fc ff ff       	call   801e13 <close>
	return r;
  8021fb:	83 c4 10             	add    $0x10,%esp
  8021fe:	89 f3                	mov    %esi,%ebx
}
  802200:	89 d8                	mov    %ebx,%eax
  802202:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802205:	5b                   	pop    %ebx
  802206:	5e                   	pop    %esi
  802207:	c9                   	leave  
  802208:	c3                   	ret    
  802209:	00 00                	add    %al,(%eax)
	...

0080220c <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  80220c:	55                   	push   %ebp
  80220d:	89 e5                	mov    %esp,%ebp
  80220f:	56                   	push   %esi
  802210:	53                   	push   %ebx
  802211:	89 c3                	mov    %eax,%ebx
  802213:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  802215:	83 3d 20 54 80 00 00 	cmpl   $0x0,0x805420
  80221c:	75 12                	jne    802230 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  80221e:	83 ec 0c             	sub    $0xc,%esp
  802221:	6a 01                	push   $0x1
  802223:	e8 82 10 00 00       	call   8032aa <ipc_find_env>
  802228:	a3 20 54 80 00       	mov    %eax,0x805420
  80222d:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  802230:	6a 07                	push   $0x7
  802232:	68 00 60 80 00       	push   $0x806000
  802237:	53                   	push   %ebx
  802238:	ff 35 20 54 80 00    	pushl  0x805420
  80223e:	e8 12 10 00 00       	call   803255 <ipc_send>
	
	return ipc_recv(NULL, dstva, NULL);
  802243:	83 c4 0c             	add    $0xc,%esp
  802246:	6a 00                	push   $0x0
  802248:	56                   	push   %esi
  802249:	6a 00                	push   $0x0
  80224b:	e8 90 0f 00 00       	call   8031e0 <ipc_recv>
}
  802250:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802253:	5b                   	pop    %ebx
  802254:	5e                   	pop    %esi
  802255:	c9                   	leave  
  802256:	c3                   	ret    

00802257 <devfile_stat>:
}


static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  802257:	55                   	push   %ebp
  802258:	89 e5                	mov    %esp,%ebp
  80225a:	53                   	push   %ebx
  80225b:	83 ec 04             	sub    $0x4,%esp
  80225e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  802261:	8b 45 08             	mov    0x8(%ebp),%eax
  802264:	8b 40 0c             	mov    0xc(%eax),%eax
  802267:	a3 00 60 80 00       	mov    %eax,0x806000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0) {
  80226c:	ba 00 00 00 00       	mov    $0x0,%edx
  802271:	b8 05 00 00 00       	mov    $0x5,%eax
  802276:	e8 91 ff ff ff       	call   80220c <fsipc>
  80227b:	85 c0                	test   %eax,%eax
  80227d:	78 2c                	js     8022ab <devfile_stat+0x54>
		return r;
	}
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  80227f:	83 ec 08             	sub    $0x8,%esp
  802282:	68 00 60 80 00       	push   $0x806000
  802287:	53                   	push   %ebx
  802288:	e8 05 ef ff ff       	call   801192 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  80228d:	a1 80 60 80 00       	mov    0x806080,%eax
  802292:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  802298:	a1 84 60 80 00       	mov    0x806084,%eax
  80229d:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8022a3:	83 c4 10             	add    $0x10,%esp
  8022a6:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8022ab:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8022ae:	c9                   	leave  
  8022af:	c3                   	ret    

008022b0 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8022b0:	55                   	push   %ebp
  8022b1:	89 e5                	mov    %esp,%ebp
  8022b3:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8022b6:	8b 45 08             	mov    0x8(%ebp),%eax
  8022b9:	8b 40 0c             	mov    0xc(%eax),%eax
  8022bc:	a3 00 60 80 00       	mov    %eax,0x806000
	return fsipc(FSREQ_FLUSH, NULL);
  8022c1:	ba 00 00 00 00       	mov    $0x0,%edx
  8022c6:	b8 06 00 00 00       	mov    $0x6,%eax
  8022cb:	e8 3c ff ff ff       	call   80220c <fsipc>
}
  8022d0:	c9                   	leave  
  8022d1:	c3                   	ret    

008022d2 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  8022d2:	55                   	push   %ebp
  8022d3:	89 e5                	mov    %esp,%ebp
  8022d5:	56                   	push   %esi
  8022d6:	53                   	push   %ebx
  8022d7:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8022da:	8b 45 08             	mov    0x8(%ebp),%eax
  8022dd:	8b 40 0c             	mov    0xc(%eax),%eax
  8022e0:	a3 00 60 80 00       	mov    %eax,0x806000
	fsipcbuf.read.req_n = n;
  8022e5:	89 35 04 60 80 00    	mov    %esi,0x806004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8022eb:	ba 00 00 00 00       	mov    $0x0,%edx
  8022f0:	b8 03 00 00 00       	mov    $0x3,%eax
  8022f5:	e8 12 ff ff ff       	call   80220c <fsipc>
  8022fa:	89 c3                	mov    %eax,%ebx
  8022fc:	85 c0                	test   %eax,%eax
  8022fe:	78 4b                	js     80234b <devfile_read+0x79>
		return r;
	assert(r <= n);
  802300:	39 c6                	cmp    %eax,%esi
  802302:	73 16                	jae    80231a <devfile_read+0x48>
  802304:	68 2c 3d 80 00       	push   $0x803d2c
  802309:	68 f2 36 80 00       	push   $0x8036f2
  80230e:	6a 7d                	push   $0x7d
  802310:	68 33 3d 80 00       	push   $0x803d33
  802315:	e8 06 e7 ff ff       	call   800a20 <_panic>
	assert(r <= PGSIZE);
  80231a:	3d 00 10 00 00       	cmp    $0x1000,%eax
  80231f:	7e 16                	jle    802337 <devfile_read+0x65>
  802321:	68 3e 3d 80 00       	push   $0x803d3e
  802326:	68 f2 36 80 00       	push   $0x8036f2
  80232b:	6a 7e                	push   $0x7e
  80232d:	68 33 3d 80 00       	push   $0x803d33
  802332:	e8 e9 e6 ff ff       	call   800a20 <_panic>
	memmove(buf, &fsipcbuf, r);
  802337:	83 ec 04             	sub    $0x4,%esp
  80233a:	50                   	push   %eax
  80233b:	68 00 60 80 00       	push   $0x806000
  802340:	ff 75 0c             	pushl  0xc(%ebp)
  802343:	e8 0b f0 ff ff       	call   801353 <memmove>
	return r;
  802348:	83 c4 10             	add    $0x10,%esp
}
  80234b:	89 d8                	mov    %ebx,%eax
  80234d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802350:	5b                   	pop    %ebx
  802351:	5e                   	pop    %esi
  802352:	c9                   	leave  
  802353:	c3                   	ret    

00802354 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  802354:	55                   	push   %ebp
  802355:	89 e5                	mov    %esp,%ebp
  802357:	56                   	push   %esi
  802358:	53                   	push   %ebx
  802359:	83 ec 1c             	sub    $0x1c,%esp
  80235c:	8b 75 08             	mov    0x8(%ebp),%esi
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  80235f:	56                   	push   %esi
  802360:	e8 db ed ff ff       	call   801140 <strlen>
  802365:	83 c4 10             	add    $0x10,%esp
  802368:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  80236d:	7f 65                	jg     8023d4 <open+0x80>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  80236f:	83 ec 0c             	sub    $0xc,%esp
  802372:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802375:	50                   	push   %eax
  802376:	e8 e1 f8 ff ff       	call   801c5c <fd_alloc>
  80237b:	89 c3                	mov    %eax,%ebx
  80237d:	83 c4 10             	add    $0x10,%esp
  802380:	85 c0                	test   %eax,%eax
  802382:	78 55                	js     8023d9 <open+0x85>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  802384:	83 ec 08             	sub    $0x8,%esp
  802387:	56                   	push   %esi
  802388:	68 00 60 80 00       	push   $0x806000
  80238d:	e8 00 ee ff ff       	call   801192 <strcpy>
	fsipcbuf.open.req_omode = mode;
  802392:	8b 45 0c             	mov    0xc(%ebp),%eax
  802395:	a3 00 64 80 00       	mov    %eax,0x806400



	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  80239a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80239d:	b8 01 00 00 00       	mov    $0x1,%eax
  8023a2:	e8 65 fe ff ff       	call   80220c <fsipc>
  8023a7:	89 c3                	mov    %eax,%ebx
  8023a9:	83 c4 10             	add    $0x10,%esp
  8023ac:	85 c0                	test   %eax,%eax
  8023ae:	79 12                	jns    8023c2 <open+0x6e>
		fd_close(fd, 0);
  8023b0:	83 ec 08             	sub    $0x8,%esp
  8023b3:	6a 00                	push   $0x0
  8023b5:	ff 75 f4             	pushl  -0xc(%ebp)
  8023b8:	e8 ce f9 ff ff       	call   801d8b <fd_close>
		return r;
  8023bd:	83 c4 10             	add    $0x10,%esp
  8023c0:	eb 17                	jmp    8023d9 <open+0x85>
	}

	return fd2num(fd);
  8023c2:	83 ec 0c             	sub    $0xc,%esp
  8023c5:	ff 75 f4             	pushl  -0xc(%ebp)
  8023c8:	e8 67 f8 ff ff       	call   801c34 <fd2num>
  8023cd:	89 c3                	mov    %eax,%ebx
  8023cf:	83 c4 10             	add    $0x10,%esp
  8023d2:	eb 05                	jmp    8023d9 <open+0x85>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  8023d4:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  8023d9:	89 d8                	mov    %ebx,%eax
  8023db:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8023de:	5b                   	pop    %ebx
  8023df:	5e                   	pop    %esi
  8023e0:	c9                   	leave  
  8023e1:	c3                   	ret    
	...

008023e4 <writebuf>:
};


static void
writebuf(struct printbuf *b)
{
  8023e4:	55                   	push   %ebp
  8023e5:	89 e5                	mov    %esp,%ebp
  8023e7:	53                   	push   %ebx
  8023e8:	83 ec 04             	sub    $0x4,%esp
  8023eb:	89 c3                	mov    %eax,%ebx
	if (b->error > 0) {
  8023ed:	83 78 0c 00          	cmpl   $0x0,0xc(%eax)
  8023f1:	7e 2e                	jle    802421 <writebuf+0x3d>
		ssize_t result = write(b->fd, b->buf, b->idx);
  8023f3:	83 ec 04             	sub    $0x4,%esp
  8023f6:	ff 70 04             	pushl  0x4(%eax)
  8023f9:	8d 40 10             	lea    0x10(%eax),%eax
  8023fc:	50                   	push   %eax
  8023fd:	ff 33                	pushl  (%ebx)
  8023ff:	e8 28 fc ff ff       	call   80202c <write>
		if (result > 0)
  802404:	83 c4 10             	add    $0x10,%esp
  802407:	85 c0                	test   %eax,%eax
  802409:	7e 03                	jle    80240e <writebuf+0x2a>
			b->result += result;
  80240b:	01 43 08             	add    %eax,0x8(%ebx)
		if (result != b->idx) // error, or wrote less than supplied
  80240e:	39 43 04             	cmp    %eax,0x4(%ebx)
  802411:	74 0e                	je     802421 <writebuf+0x3d>
			b->error = (result < 0 ? result : 0);
  802413:	89 c2                	mov    %eax,%edx
  802415:	85 c0                	test   %eax,%eax
  802417:	7e 05                	jle    80241e <writebuf+0x3a>
  802419:	ba 00 00 00 00       	mov    $0x0,%edx
  80241e:	89 53 0c             	mov    %edx,0xc(%ebx)
	}
}
  802421:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802424:	c9                   	leave  
  802425:	c3                   	ret    

00802426 <putch>:

static void
putch(int ch, void *thunk)
{
  802426:	55                   	push   %ebp
  802427:	89 e5                	mov    %esp,%ebp
  802429:	53                   	push   %ebx
  80242a:	83 ec 04             	sub    $0x4,%esp
  80242d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct printbuf *b = (struct printbuf *) thunk;
	b->buf[b->idx++] = ch;
  802430:	8b 43 04             	mov    0x4(%ebx),%eax
  802433:	8b 55 08             	mov    0x8(%ebp),%edx
  802436:	88 54 03 10          	mov    %dl,0x10(%ebx,%eax,1)
  80243a:	40                   	inc    %eax
  80243b:	89 43 04             	mov    %eax,0x4(%ebx)
	if (b->idx == 256) {
  80243e:	3d 00 01 00 00       	cmp    $0x100,%eax
  802443:	75 0e                	jne    802453 <putch+0x2d>
		writebuf(b);
  802445:	89 d8                	mov    %ebx,%eax
  802447:	e8 98 ff ff ff       	call   8023e4 <writebuf>
		b->idx = 0;
  80244c:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	}
}
  802453:	83 c4 04             	add    $0x4,%esp
  802456:	5b                   	pop    %ebx
  802457:	c9                   	leave  
  802458:	c3                   	ret    

00802459 <vfprintf>:

int
vfprintf(int fd, const char *fmt, va_list ap)
{
  802459:	55                   	push   %ebp
  80245a:	89 e5                	mov    %esp,%ebp
  80245c:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.fd = fd;
  802462:	8b 45 08             	mov    0x8(%ebp),%eax
  802465:	89 85 e8 fe ff ff    	mov    %eax,-0x118(%ebp)
	b.idx = 0;
  80246b:	c7 85 ec fe ff ff 00 	movl   $0x0,-0x114(%ebp)
  802472:	00 00 00 
	b.result = 0;
  802475:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80247c:	00 00 00 
	b.error = 1;
  80247f:	c7 85 f4 fe ff ff 01 	movl   $0x1,-0x10c(%ebp)
  802486:	00 00 00 
	vprintfmt(putch, &b, fmt, ap);
  802489:	ff 75 10             	pushl  0x10(%ebp)
  80248c:	ff 75 0c             	pushl  0xc(%ebp)
  80248f:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  802495:	50                   	push   %eax
  802496:	68 26 24 80 00       	push   $0x802426
  80249b:	e8 bd e7 ff ff       	call   800c5d <vprintfmt>
	if (b.idx > 0)
  8024a0:	83 c4 10             	add    $0x10,%esp
  8024a3:	83 bd ec fe ff ff 00 	cmpl   $0x0,-0x114(%ebp)
  8024aa:	7e 0b                	jle    8024b7 <vfprintf+0x5e>
		writebuf(&b);
  8024ac:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  8024b2:	e8 2d ff ff ff       	call   8023e4 <writebuf>

	return (b.result ? b.result : b.error);
  8024b7:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  8024bd:	85 c0                	test   %eax,%eax
  8024bf:	75 06                	jne    8024c7 <vfprintf+0x6e>
  8024c1:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
}
  8024c7:	c9                   	leave  
  8024c8:	c3                   	ret    

008024c9 <fprintf>:

int
fprintf(int fd, const char *fmt, ...)
{
  8024c9:	55                   	push   %ebp
  8024ca:	89 e5                	mov    %esp,%ebp
  8024cc:	83 ec 0c             	sub    $0xc,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8024cf:	8d 45 10             	lea    0x10(%ebp),%eax
	cnt = vfprintf(fd, fmt, ap);
  8024d2:	50                   	push   %eax
  8024d3:	ff 75 0c             	pushl  0xc(%ebp)
  8024d6:	ff 75 08             	pushl  0x8(%ebp)
  8024d9:	e8 7b ff ff ff       	call   802459 <vfprintf>
	va_end(ap);

	return cnt;
}
  8024de:	c9                   	leave  
  8024df:	c3                   	ret    

008024e0 <printf>:

int
printf(const char *fmt, ...)
{
  8024e0:	55                   	push   %ebp
  8024e1:	89 e5                	mov    %esp,%ebp
  8024e3:	83 ec 0c             	sub    $0xc,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8024e6:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vfprintf(1, fmt, ap);
  8024e9:	50                   	push   %eax
  8024ea:	ff 75 08             	pushl  0x8(%ebp)
  8024ed:	6a 01                	push   $0x1
  8024ef:	e8 65 ff ff ff       	call   802459 <vfprintf>
	va_end(ap);

	return cnt;
}
  8024f4:	c9                   	leave  
  8024f5:	c3                   	ret    
	...

008024f8 <map_segment>:
}

static int
map_segment(envid_t child, uintptr_t va, size_t memsz,
	int fd, size_t filesz, off_t fileoffset, int perm)
{
  8024f8:	55                   	push   %ebp
  8024f9:	89 e5                	mov    %esp,%ebp
  8024fb:	57                   	push   %edi
  8024fc:	56                   	push   %esi
  8024fd:	53                   	push   %ebx
  8024fe:	83 ec 1c             	sub    $0x1c,%esp
  802501:	89 c7                	mov    %eax,%edi
  802503:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  802506:	89 4d e0             	mov    %ecx,-0x20(%ebp)
	int i, r;
	void *blk;

	//cprintf("map_segment %x+%x\n", va, memsz);

	if ((i = PGOFF(va))) {
  802509:	89 d0                	mov    %edx,%eax
  80250b:	25 ff 0f 00 00       	and    $0xfff,%eax
  802510:	74 0c                	je     80251e <map_segment+0x26>
		va -= i;
  802512:	29 45 e4             	sub    %eax,-0x1c(%ebp)
		memsz += i;
  802515:	01 45 e0             	add    %eax,-0x20(%ebp)
		filesz += i;
  802518:	01 45 0c             	add    %eax,0xc(%ebp)
		fileoffset -= i;
  80251b:	29 45 10             	sub    %eax,0x10(%ebp)
	}

	for (i = 0; i < memsz; i += PGSIZE) {
  80251e:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  802522:	0f 84 ee 00 00 00    	je     802616 <map_segment+0x11e>
  802528:	be 00 00 00 00       	mov    $0x0,%esi
  80252d:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (i >= filesz) {
  802532:	39 75 0c             	cmp    %esi,0xc(%ebp)
  802535:	77 20                	ja     802557 <map_segment+0x5f>
			// allocate a blank page
			if ((r = sys_page_alloc(child, (void*) (va + i), perm)) < 0)
  802537:	83 ec 04             	sub    $0x4,%esp
  80253a:	ff 75 14             	pushl  0x14(%ebp)
  80253d:	03 75 e4             	add    -0x1c(%ebp),%esi
  802540:	56                   	push   %esi
  802541:	57                   	push   %edi
  802542:	e8 cd f0 ff ff       	call   801614 <sys_page_alloc>
  802547:	83 c4 10             	add    $0x10,%esp
  80254a:	85 c0                	test   %eax,%eax
  80254c:	0f 89 ac 00 00 00    	jns    8025fe <map_segment+0x106>
  802552:	e9 c4 00 00 00       	jmp    80261b <map_segment+0x123>
				return r;
		} else {
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  802557:	83 ec 04             	sub    $0x4,%esp
  80255a:	6a 07                	push   $0x7
  80255c:	68 00 00 40 00       	push   $0x400000
  802561:	6a 00                	push   $0x0
  802563:	e8 ac f0 ff ff       	call   801614 <sys_page_alloc>
  802568:	83 c4 10             	add    $0x10,%esp
  80256b:	85 c0                	test   %eax,%eax
  80256d:	0f 88 a8 00 00 00    	js     80261b <map_segment+0x123>
				return r;
			if ((r = seek(fd, fileoffset + i)) < 0)
  802573:	83 ec 08             	sub    $0x8,%esp
	sys_page_unmap(0, UTEMP);
	return r;
}

static int
map_segment(envid_t child, uintptr_t va, size_t memsz,
  802576:	8b 45 10             	mov    0x10(%ebp),%eax
  802579:	8d 04 03             	lea    (%ebx,%eax,1),%eax
				return r;
		} else {
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
				return r;
			if ((r = seek(fd, fileoffset + i)) < 0)
  80257c:	50                   	push   %eax
  80257d:	ff 75 08             	pushl  0x8(%ebp)
  802580:	e8 29 fb ff ff       	call   8020ae <seek>
  802585:	83 c4 10             	add    $0x10,%esp
  802588:	85 c0                	test   %eax,%eax
  80258a:	0f 88 8b 00 00 00    	js     80261b <map_segment+0x123>
				return r;
			if ((r = readn(fd, UTEMP, MIN(PGSIZE, filesz-i))) < 0)
  802590:	83 ec 04             	sub    $0x4,%esp
  802593:	8b 45 0c             	mov    0xc(%ebp),%eax
  802596:	29 f0                	sub    %esi,%eax
  802598:	3d 00 10 00 00       	cmp    $0x1000,%eax
  80259d:	76 05                	jbe    8025a4 <map_segment+0xac>
  80259f:	b8 00 10 00 00       	mov    $0x1000,%eax
  8025a4:	50                   	push   %eax
  8025a5:	68 00 00 40 00       	push   $0x400000
  8025aa:	ff 75 08             	pushl  0x8(%ebp)
  8025ad:	e8 25 fa ff ff       	call   801fd7 <readn>
  8025b2:	83 c4 10             	add    $0x10,%esp
  8025b5:	85 c0                	test   %eax,%eax
  8025b7:	78 62                	js     80261b <map_segment+0x123>
				return r;
			if ((r = sys_page_map(0, UTEMP, child, (void*) (va + i), perm)) < 0)
  8025b9:	83 ec 0c             	sub    $0xc,%esp
  8025bc:	ff 75 14             	pushl  0x14(%ebp)
  8025bf:	03 75 e4             	add    -0x1c(%ebp),%esi
  8025c2:	56                   	push   %esi
  8025c3:	57                   	push   %edi
  8025c4:	68 00 00 40 00       	push   $0x400000
  8025c9:	6a 00                	push   $0x0
  8025cb:	e8 68 f0 ff ff       	call   801638 <sys_page_map>
  8025d0:	83 c4 20             	add    $0x20,%esp
  8025d3:	85 c0                	test   %eax,%eax
  8025d5:	79 15                	jns    8025ec <map_segment+0xf4>
				panic("spawn: sys_page_map data: %e", r);
  8025d7:	50                   	push   %eax
  8025d8:	68 4a 3d 80 00       	push   $0x803d4a
  8025dd:	68 84 01 00 00       	push   $0x184
  8025e2:	68 67 3d 80 00       	push   $0x803d67
  8025e7:	e8 34 e4 ff ff       	call   800a20 <_panic>
			sys_page_unmap(0, UTEMP);
  8025ec:	83 ec 08             	sub    $0x8,%esp
  8025ef:	68 00 00 40 00       	push   $0x400000
  8025f4:	6a 00                	push   $0x0
  8025f6:	e8 63 f0 ff ff       	call   80165e <sys_page_unmap>
  8025fb:	83 c4 10             	add    $0x10,%esp
		memsz += i;
		filesz += i;
		fileoffset -= i;
	}

	for (i = 0; i < memsz; i += PGSIZE) {
  8025fe:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  802604:	89 de                	mov    %ebx,%esi
  802606:	39 5d e0             	cmp    %ebx,-0x20(%ebp)
  802609:	0f 87 23 ff ff ff    	ja     802532 <map_segment+0x3a>
			if ((r = sys_page_map(0, UTEMP, child, (void*) (va + i), perm)) < 0)
				panic("spawn: sys_page_map data: %e", r);
			sys_page_unmap(0, UTEMP);
		}
	}
	return 0;
  80260f:	b8 00 00 00 00       	mov    $0x0,%eax
  802614:	eb 05                	jmp    80261b <map_segment+0x123>
  802616:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80261b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80261e:	5b                   	pop    %ebx
  80261f:	5e                   	pop    %esi
  802620:	5f                   	pop    %edi
  802621:	c9                   	leave  
  802622:	c3                   	ret    

00802623 <init_stack>:
// On success, returns 0 and sets *init_esp
// to the initial stack pointer with which the child should start.
// Returns < 0 on failure.
static int
init_stack(envid_t child, const char **argv, uintptr_t *init_esp, uint32_t stack_addr)
{
  802623:	55                   	push   %ebp
  802624:	89 e5                	mov    %esp,%ebp
  802626:	57                   	push   %edi
  802627:	56                   	push   %esi
  802628:	53                   	push   %ebx
  802629:	83 ec 2c             	sub    $0x2c,%esp
  80262c:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80262f:	89 d7                	mov    %edx,%edi
  802631:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  802634:	8b 02                	mov    (%edx),%eax
  802636:	85 c0                	test   %eax,%eax
  802638:	74 31                	je     80266b <init_stack+0x48>
  80263a:	bb 00 00 00 00       	mov    $0x0,%ebx
	char *string_store;
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
  80263f:	be 00 00 00 00       	mov    $0x0,%esi
	for (argc = 0; argv[argc] != 0; argc++)
		string_size += strlen(argv[argc]) + 1;
  802644:	83 ec 0c             	sub    $0xc,%esp
  802647:	50                   	push   %eax
  802648:	e8 f3 ea ff ff       	call   801140 <strlen>
  80264d:	8d 74 30 01          	lea    0x1(%eax,%esi,1),%esi
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  802651:	43                   	inc    %ebx
  802652:	8d 0c 9d 00 00 00 00 	lea    0x0(,%ebx,4),%ecx
  802659:	8b 04 9f             	mov    (%edi,%ebx,4),%eax
  80265c:	83 c4 10             	add    $0x10,%esp
  80265f:	85 c0                	test   %eax,%eax
  802661:	75 e1                	jne    802644 <init_stack+0x21>
  802663:	89 5d d0             	mov    %ebx,-0x30(%ebp)
  802666:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  802669:	eb 18                	jmp    802683 <init_stack+0x60>
  80266b:	c7 45 cc 00 00 00 00 	movl   $0x0,-0x34(%ebp)
  802672:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%ebp)
  802679:	bb 00 00 00 00       	mov    $0x0,%ebx
	char *string_store;
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
  80267e:	be 00 00 00 00       	mov    $0x0,%esi
	// Determine where to place the strings and the argv array.
	// Set up pointers into the temporary page 'UTEMP'; we'll map a page
	// there later, then remap that page into the child environment
	// at (USTACKTOP - PGSIZE).
	// strings is the topmost thing on the stack.
	string_store = (char*) UTEMP + PGSIZE - string_size;
  802683:	f7 de                	neg    %esi
  802685:	81 c6 00 10 40 00    	add    $0x401000,%esi
  80268b:	89 75 dc             	mov    %esi,-0x24(%ebp)
	// argv is below that.  There's one argument pointer per argument, plus
	// a null pointer.
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));
  80268e:	89 f2                	mov    %esi,%edx
  802690:	83 e2 fc             	and    $0xfffffffc,%edx
  802693:	89 d8                	mov    %ebx,%eax
  802695:	f7 d0                	not    %eax
  802697:	8d 04 82             	lea    (%edx,%eax,4),%eax
  80269a:	89 45 e4             	mov    %eax,-0x1c(%ebp)

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
  80269d:	83 e8 08             	sub    $0x8,%eax
  8026a0:	3d ff ff 3f 00       	cmp    $0x3fffff,%eax
  8026a5:	0f 86 fb 00 00 00    	jbe    8027a6 <init_stack+0x183>
		return -E_NO_MEM;

	// Allocate the single stack page at UTEMP.
	if ((r = sys_page_alloc(0, (void*) UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  8026ab:	83 ec 04             	sub    $0x4,%esp
  8026ae:	6a 07                	push   $0x7
  8026b0:	68 00 00 40 00       	push   $0x400000
  8026b5:	6a 00                	push   $0x0
  8026b7:	e8 58 ef ff ff       	call   801614 <sys_page_alloc>
  8026bc:	89 c6                	mov    %eax,%esi
  8026be:	83 c4 10             	add    $0x10,%esp
  8026c1:	85 c0                	test   %eax,%eax
  8026c3:	0f 88 e9 00 00 00    	js     8027b2 <init_stack+0x18f>
	//	  (Again, argv should use an address valid in the child's
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
  8026c9:	85 db                	test   %ebx,%ebx
  8026cb:	7e 3e                	jle    80270b <init_stack+0xe8>
  8026cd:	be 00 00 00 00       	mov    $0x0,%esi
  8026d2:	89 5d e0             	mov    %ebx,-0x20(%ebp)
  8026d5:	8b 5d dc             	mov    -0x24(%ebp),%ebx
		argv_store[i] = UTEMP2USTACK(string_store);
  8026d8:	8d 83 00 d0 7f ee    	lea    -0x11803000(%ebx),%eax
  8026de:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8026e1:	89 04 b2             	mov    %eax,(%edx,%esi,4)
		strcpy(string_store, argv[i]);
  8026e4:	83 ec 08             	sub    $0x8,%esp
  8026e7:	ff 34 b7             	pushl  (%edi,%esi,4)
  8026ea:	53                   	push   %ebx
  8026eb:	e8 a2 ea ff ff       	call   801192 <strcpy>
		string_store += strlen(argv[i]) + 1;
  8026f0:	83 c4 04             	add    $0x4,%esp
  8026f3:	ff 34 b7             	pushl  (%edi,%esi,4)
  8026f6:	e8 45 ea ff ff       	call   801140 <strlen>
  8026fb:	8d 5c 03 01          	lea    0x1(%ebx,%eax,1),%ebx
	//	  (Again, argv should use an address valid in the child's
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
  8026ff:	46                   	inc    %esi
  802700:	83 c4 10             	add    $0x10,%esp
  802703:	3b 75 e0             	cmp    -0x20(%ebp),%esi
  802706:	7c d0                	jl     8026d8 <init_stack+0xb5>
  802708:	89 5d dc             	mov    %ebx,-0x24(%ebp)
		argv_store[i] = UTEMP2USTACK(string_store);
		strcpy(string_store, argv[i]);
		string_store += strlen(argv[i]) + 1;
	}
	argv_store[argc] = 0;
  80270b:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80270e:	8b 45 cc             	mov    -0x34(%ebp),%eax
  802711:	c7 04 02 00 00 00 00 	movl   $0x0,(%edx,%eax,1)
	assert(string_store == (char*)UTEMP + PGSIZE);
  802718:	81 7d dc 00 10 40 00 	cmpl   $0x401000,-0x24(%ebp)
  80271f:	74 19                	je     80273a <init_stack+0x117>
  802721:	68 d4 3d 80 00       	push   $0x803dd4
  802726:	68 f2 36 80 00       	push   $0x8036f2
  80272b:	68 51 01 00 00       	push   $0x151
  802730:	68 67 3d 80 00       	push   $0x803d67
  802735:	e8 e6 e2 ff ff       	call   800a20 <_panic>

	argv_store[-1] = UTEMP2USTACK(argv_store);
  80273a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80273d:	2d 00 30 80 11       	sub    $0x11803000,%eax
  802742:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  802745:	89 42 fc             	mov    %eax,-0x4(%edx)
	argv_store[-2] = argc;
  802748:	8b 45 d0             	mov    -0x30(%ebp),%eax
  80274b:	89 42 f8             	mov    %eax,-0x8(%edx)

	*init_esp = UTEMP2USTACK(&argv_store[-2]);
  80274e:	89 d0                	mov    %edx,%eax
  802750:	2d 08 30 80 11       	sub    $0x11803008,%eax
  802755:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  802758:	89 02                	mov    %eax,(%edx)

	// After completing the stack, map it into the child's address space
	// and unmap it from ours!
	
	if ((r = sys_page_map(0, UTEMP, child, (void*) stack_addr, PTE_P | PTE_U | PTE_W)) < 0)
  80275a:	83 ec 0c             	sub    $0xc,%esp
  80275d:	6a 07                	push   $0x7
  80275f:	ff 75 08             	pushl  0x8(%ebp)
  802762:	ff 75 d8             	pushl  -0x28(%ebp)
  802765:	68 00 00 40 00       	push   $0x400000
  80276a:	6a 00                	push   $0x0
  80276c:	e8 c7 ee ff ff       	call   801638 <sys_page_map>
  802771:	89 c6                	mov    %eax,%esi
  802773:	83 c4 20             	add    $0x20,%esp
  802776:	85 c0                	test   %eax,%eax
  802778:	78 18                	js     802792 <init_stack+0x16f>
		goto error;
	if ((r = sys_page_unmap(0, UTEMP)) < 0)
  80277a:	83 ec 08             	sub    $0x8,%esp
  80277d:	68 00 00 40 00       	push   $0x400000
  802782:	6a 00                	push   $0x0
  802784:	e8 d5 ee ff ff       	call   80165e <sys_page_unmap>
  802789:	89 c6                	mov    %eax,%esi
  80278b:	83 c4 10             	add    $0x10,%esp
  80278e:	85 c0                	test   %eax,%eax
  802790:	79 1b                	jns    8027ad <init_stack+0x18a>
		goto error;
	return 0;

error:
	sys_page_unmap(0, UTEMP);
  802792:	83 ec 08             	sub    $0x8,%esp
  802795:	68 00 00 40 00       	push   $0x400000
  80279a:	6a 00                	push   $0x0
  80279c:	e8 bd ee ff ff       	call   80165e <sys_page_unmap>
	return r;
  8027a1:	83 c4 10             	add    $0x10,%esp
  8027a4:	eb 0c                	jmp    8027b2 <init_stack+0x18f>
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
		return -E_NO_MEM;
  8027a6:	be fc ff ff ff       	mov    $0xfffffffc,%esi
  8027ab:	eb 05                	jmp    8027b2 <init_stack+0x18f>
	
	if ((r = sys_page_map(0, UTEMP, child, (void*) stack_addr, PTE_P | PTE_U | PTE_W)) < 0)
		goto error;
	if ((r = sys_page_unmap(0, UTEMP)) < 0)
		goto error;
	return 0;
  8027ad:	be 00 00 00 00       	mov    $0x0,%esi

error:
	sys_page_unmap(0, UTEMP);
	return r;
}
  8027b2:	89 f0                	mov    %esi,%eax
  8027b4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8027b7:	5b                   	pop    %ebx
  8027b8:	5e                   	pop    %esi
  8027b9:	5f                   	pop    %edi
  8027ba:	c9                   	leave  
  8027bb:	c3                   	ret    

008027bc <spawn>:
// argv: pointer to null-terminated array of pointers to strings,
// 	 which will be passed to the child as its command-line arguments.
// Returns child envid on success, < 0 on failure.
int
spawn(const char *prog, const char **argv)
{
  8027bc:	55                   	push   %ebp
  8027bd:	89 e5                	mov    %esp,%ebp
  8027bf:	57                   	push   %edi
  8027c0:	56                   	push   %esi
  8027c1:	53                   	push   %ebx
  8027c2:	81 ec 74 02 00 00    	sub    $0x274,%esp
	//   - Call sys_env_set_trapframe(child, &child_tf) to set up the
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
  8027c8:	6a 00                	push   $0x0
  8027ca:	ff 75 08             	pushl  0x8(%ebp)
  8027cd:	e8 82 fb ff ff       	call   802354 <open>
  8027d2:	89 85 90 fd ff ff    	mov    %eax,-0x270(%ebp)
  8027d8:	83 c4 10             	add    $0x10,%esp
  8027db:	85 c0                	test   %eax,%eax
  8027dd:	0f 88 3f 02 00 00    	js     802a22 <spawn+0x266>
		return r;
	fd = r;

	// Read elf header
	elf = (struct Elf*) elf_buf;
	if (readn(fd, elf_buf, sizeof(elf_buf)) != sizeof(elf_buf)
  8027e3:	83 ec 04             	sub    $0x4,%esp
  8027e6:	68 00 02 00 00       	push   $0x200
  8027eb:	8d 85 e8 fd ff ff    	lea    -0x218(%ebp),%eax
  8027f1:	50                   	push   %eax
  8027f2:	ff b5 90 fd ff ff    	pushl  -0x270(%ebp)
  8027f8:	e8 da f7 ff ff       	call   801fd7 <readn>
  8027fd:	83 c4 10             	add    $0x10,%esp
  802800:	3d 00 02 00 00       	cmp    $0x200,%eax
  802805:	75 0c                	jne    802813 <spawn+0x57>
	    || elf->e_magic != ELF_MAGIC) {
  802807:	81 bd e8 fd ff ff 7f 	cmpl   $0x464c457f,-0x218(%ebp)
  80280e:	45 4c 46 
  802811:	74 38                	je     80284b <spawn+0x8f>
		close(fd);
  802813:	83 ec 0c             	sub    $0xc,%esp
  802816:	ff b5 90 fd ff ff    	pushl  -0x270(%ebp)
  80281c:	e8 f2 f5 ff ff       	call   801e13 <close>
		cprintf("elf magic %08x want %08x\n", elf->e_magic, ELF_MAGIC);
  802821:	83 c4 0c             	add    $0xc,%esp
  802824:	68 7f 45 4c 46       	push   $0x464c457f
  802829:	ff b5 e8 fd ff ff    	pushl  -0x218(%ebp)
  80282f:	68 73 3d 80 00       	push   $0x803d73
  802834:	e8 bf e2 ff ff       	call   800af8 <cprintf>
		return -E_NOT_EXEC;
  802839:	83 c4 10             	add    $0x10,%esp
  80283c:	c7 85 94 fd ff ff f2 	movl   $0xfffffff2,-0x26c(%ebp)
  802843:	ff ff ff 
  802846:	e9 eb 01 00 00       	jmp    802a36 <spawn+0x27a>
  80284b:	ba 07 00 00 00       	mov    $0x7,%edx
  802850:	89 d0                	mov    %edx,%eax
  802852:	cd 30                	int    $0x30
  802854:	89 85 8c fd ff ff    	mov    %eax,-0x274(%ebp)
  80285a:	89 85 94 fd ff ff    	mov    %eax,-0x26c(%ebp)
	}


	// Create new child environment
	if ((r = sys_exofork()) < 0)
  802860:	85 c0                	test   %eax,%eax
  802862:	0f 88 ce 01 00 00    	js     802a36 <spawn+0x27a>
		return r;
	child = r;

	// Set up trap frame, including initial stack.
	child_tf = envs[ENVX(child)].env_tf;
  802868:	25 ff 03 00 00       	and    $0x3ff,%eax
  80286d:	89 c2                	mov    %eax,%edx
  80286f:	c1 e2 07             	shl    $0x7,%edx
  802872:	8d b4 82 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,4),%esi
  802879:	8d bd a4 fd ff ff    	lea    -0x25c(%ebp),%edi
  80287f:	b9 11 00 00 00       	mov    $0x11,%ecx
  802884:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	child_tf.tf_eip = elf->e_entry;
  802886:	8b 85 00 fe ff ff    	mov    -0x200(%ebp),%eax
  80288c:	89 85 d4 fd ff ff    	mov    %eax,-0x22c(%ebp)

	if ((r = init_stack(child, argv, &child_tf.tf_esp, (USTACKTOP - PGSIZE))) < 0)
  802892:	83 ec 0c             	sub    $0xc,%esp
  802895:	8d 8d e0 fd ff ff    	lea    -0x220(%ebp),%ecx
  80289b:	68 00 d0 bf ee       	push   $0xeebfd000
  8028a0:	8b 55 0c             	mov    0xc(%ebp),%edx
  8028a3:	8b 85 8c fd ff ff    	mov    -0x274(%ebp),%eax
  8028a9:	e8 75 fd ff ff       	call   802623 <init_stack>
  8028ae:	83 c4 10             	add    $0x10,%esp
  8028b1:	85 c0                	test   %eax,%eax
  8028b3:	0f 88 77 01 00 00    	js     802a30 <spawn+0x274>
		return r;

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
  8028b9:	8b 85 04 fe ff ff    	mov    -0x1fc(%ebp),%eax
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  8028bf:	66 83 bd 14 fe ff ff 	cmpw   $0x0,-0x1ec(%ebp)
  8028c6:	00 
  8028c7:	74 5d                	je     802926 <spawn+0x16a>

	if ((r = init_stack(child, argv, &child_tf.tf_esp, (USTACKTOP - PGSIZE))) < 0)
		return r;

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
  8028c9:	8d 9c 05 e8 fd ff ff 	lea    -0x218(%ebp,%eax,1),%ebx
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  8028d0:	be 00 00 00 00       	mov    $0x0,%esi
  8028d5:	8b bd 90 fd ff ff    	mov    -0x270(%ebp),%edi
		if (ph->p_type != ELF_PROG_LOAD)
  8028db:	83 3b 01             	cmpl   $0x1,(%ebx)
  8028de:	75 35                	jne    802915 <spawn+0x159>
			continue;
		perm = PTE_P | PTE_U;
		if (ph->p_flags & ELF_PROG_FLAG_WRITE)
  8028e0:	8b 43 18             	mov    0x18(%ebx),%eax
  8028e3:	83 e0 02             	and    $0x2,%eax
	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
	for (i = 0; i < elf->e_phnum; i++, ph++) {
		if (ph->p_type != ELF_PROG_LOAD)
			continue;
		perm = PTE_P | PTE_U;
  8028e6:	83 f8 01             	cmp    $0x1,%eax
  8028e9:	19 c0                	sbb    %eax,%eax
  8028eb:	83 e0 fe             	and    $0xfffffffe,%eax
  8028ee:	83 c0 07             	add    $0x7,%eax
		if (ph->p_flags & ELF_PROG_FLAG_WRITE)
			perm |= PTE_W;
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
  8028f1:	8b 4b 14             	mov    0x14(%ebx),%ecx
  8028f4:	8b 53 08             	mov    0x8(%ebx),%edx
  8028f7:	50                   	push   %eax
  8028f8:	ff 73 04             	pushl  0x4(%ebx)
  8028fb:	ff 73 10             	pushl  0x10(%ebx)
  8028fe:	57                   	push   %edi
  8028ff:	8b 85 94 fd ff ff    	mov    -0x26c(%ebp),%eax
  802905:	e8 ee fb ff ff       	call   8024f8 <map_segment>
  80290a:	83 c4 10             	add    $0x10,%esp
  80290d:	85 c0                	test   %eax,%eax
  80290f:	0f 88 e4 00 00 00    	js     8029f9 <spawn+0x23d>
	if ((r = init_stack(child, argv, &child_tf.tf_esp, (USTACKTOP - PGSIZE))) < 0)
		return r;

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  802915:	46                   	inc    %esi
  802916:	0f b7 85 14 fe ff ff 	movzwl -0x1ec(%ebp),%eax
  80291d:	39 f0                	cmp    %esi,%eax
  80291f:	7e 05                	jle    802926 <spawn+0x16a>
  802921:	83 c3 20             	add    $0x20,%ebx
  802924:	eb b5                	jmp    8028db <spawn+0x11f>
			perm |= PTE_W;
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
				     fd, ph->p_filesz, ph->p_offset, perm)) < 0)
			goto error;
	}
	close(fd);
  802926:	83 ec 0c             	sub    $0xc,%esp
  802929:	ff b5 90 fd ff ff    	pushl  -0x270(%ebp)
  80292f:	e8 df f4 ff ff       	call   801e13 <close>
  802934:	83 c4 10             	add    $0x10,%esp
copy_shared_pages(envid_t child)
{
	// LAB 5: Your code here.
    uint32_t i;
    int r;
    for (i = 0; i != UTOP; i += PGSIZE) 
  802937:	bb 00 00 00 00       	mov    $0x0,%ebx
  80293c:	8b b5 94 fd ff ff    	mov    -0x26c(%ebp),%esi
    if ((uvpd[PDX(i)] & PTE_P) && (uvpt[i / PGSIZE] & PTE_P) && (uvpt[i / PGSIZE] & PTE_SHARE)) {
  802942:	89 d8                	mov    %ebx,%eax
  802944:	c1 e8 16             	shr    $0x16,%eax
  802947:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80294e:	a8 01                	test   $0x1,%al
  802950:	74 3e                	je     802990 <spawn+0x1d4>
  802952:	89 d8                	mov    %ebx,%eax
  802954:	c1 e8 0c             	shr    $0xc,%eax
  802957:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80295e:	f6 c2 01             	test   $0x1,%dl
  802961:	74 2d                	je     802990 <spawn+0x1d4>
  802963:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80296a:	f6 c6 04             	test   $0x4,%dh
  80296d:	74 21                	je     802990 <spawn+0x1d4>
        r = sys_page_map(0, (void *)i, child, (void *)i, uvpt[i / PGSIZE] & PTE_SYSCALL);
  80296f:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  802976:	83 ec 0c             	sub    $0xc,%esp
  802979:	25 07 0e 00 00       	and    $0xe07,%eax
  80297e:	50                   	push   %eax
  80297f:	53                   	push   %ebx
  802980:	56                   	push   %esi
  802981:	53                   	push   %ebx
  802982:	6a 00                	push   $0x0
  802984:	e8 af ec ff ff       	call   801638 <sys_page_map>
        if (r < 0) return r;
  802989:	83 c4 20             	add    $0x20,%esp
  80298c:	85 c0                	test   %eax,%eax
  80298e:	78 13                	js     8029a3 <spawn+0x1e7>
copy_shared_pages(envid_t child)
{
	// LAB 5: Your code here.
    uint32_t i;
    int r;
    for (i = 0; i != UTOP; i += PGSIZE) 
  802990:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  802996:	81 fb 00 00 c0 ee    	cmp    $0xeec00000,%ebx
  80299c:	75 a4                	jne    802942 <spawn+0x186>
  80299e:	e9 a1 00 00 00       	jmp    802a44 <spawn+0x288>
	close(fd);
	fd = -1;

	// Copy shared library state.
	if ((r = copy_shared_pages(child)) < 0)
		panic("copy_shared_pages: %e", r);
  8029a3:	50                   	push   %eax
  8029a4:	68 8d 3d 80 00       	push   $0x803d8d
  8029a9:	68 85 00 00 00       	push   $0x85
  8029ae:	68 67 3d 80 00       	push   $0x803d67
  8029b3:	e8 68 e0 ff ff       	call   800a20 <_panic>

	if ((r = sys_env_set_trapframe(child, &child_tf)) < 0)
		panic("sys_env_set_trapframe: %e", r);
  8029b8:	50                   	push   %eax
  8029b9:	68 a3 3d 80 00       	push   $0x803da3
  8029be:	68 88 00 00 00       	push   $0x88
  8029c3:	68 67 3d 80 00       	push   $0x803d67
  8029c8:	e8 53 e0 ff ff       	call   800a20 <_panic>

	if ((r = sys_env_set_status(child, ENV_RUNNABLE)) < 0)
  8029cd:	83 ec 08             	sub    $0x8,%esp
  8029d0:	6a 02                	push   $0x2
  8029d2:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  8029d8:	e8 a4 ec ff ff       	call   801681 <sys_env_set_status>
  8029dd:	83 c4 10             	add    $0x10,%esp
  8029e0:	85 c0                	test   %eax,%eax
  8029e2:	79 52                	jns    802a36 <spawn+0x27a>
		panic("sys_env_set_status: %e", r);
  8029e4:	50                   	push   %eax
  8029e5:	68 bd 3d 80 00       	push   $0x803dbd
  8029ea:	68 8b 00 00 00       	push   $0x8b
  8029ef:	68 67 3d 80 00       	push   $0x803d67
  8029f4:	e8 27 e0 ff ff       	call   800a20 <_panic>
  8029f9:	89 c7                	mov    %eax,%edi

	return child;

error:
	sys_env_destroy(child);
  8029fb:	83 ec 0c             	sub    $0xc,%esp
  8029fe:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  802a04:	e8 9e eb ff ff       	call   8015a7 <sys_env_destroy>
	close(fd);
  802a09:	83 c4 04             	add    $0x4,%esp
  802a0c:	ff b5 90 fd ff ff    	pushl  -0x270(%ebp)
  802a12:	e8 fc f3 ff ff       	call   801e13 <close>
	return r;
  802a17:	83 c4 10             	add    $0x10,%esp
		if (ph->p_type != ELF_PROG_LOAD)
			continue;
		perm = PTE_P | PTE_U;
		if (ph->p_flags & ELF_PROG_FLAG_WRITE)
			perm |= PTE_W;
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
  802a1a:	89 bd 94 fd ff ff    	mov    %edi,-0x26c(%ebp)
	return child;

error:
	sys_env_destroy(child);
	close(fd);
	return r;
  802a20:	eb 14                	jmp    802a36 <spawn+0x27a>
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
		return r;
  802a22:	8b 85 90 fd ff ff    	mov    -0x270(%ebp),%eax
  802a28:	89 85 94 fd ff ff    	mov    %eax,-0x26c(%ebp)
  802a2e:	eb 06                	jmp    802a36 <spawn+0x27a>
	// Set up trap frame, including initial stack.
	child_tf = envs[ENVX(child)].env_tf;
	child_tf.tf_eip = elf->e_entry;

	if ((r = init_stack(child, argv, &child_tf.tf_esp, (USTACKTOP - PGSIZE))) < 0)
		return r;
  802a30:	89 85 94 fd ff ff    	mov    %eax,-0x26c(%ebp)

error:
	sys_env_destroy(child);
	close(fd);
	return r;
}
  802a36:	8b 85 94 fd ff ff    	mov    -0x26c(%ebp),%eax
  802a3c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802a3f:	5b                   	pop    %ebx
  802a40:	5e                   	pop    %esi
  802a41:	5f                   	pop    %edi
  802a42:	c9                   	leave  
  802a43:	c3                   	ret    

	// Copy shared library state.
	if ((r = copy_shared_pages(child)) < 0)
		panic("copy_shared_pages: %e", r);

	if ((r = sys_env_set_trapframe(child, &child_tf)) < 0)
  802a44:	83 ec 08             	sub    $0x8,%esp
  802a47:	8d 85 a4 fd ff ff    	lea    -0x25c(%ebp),%eax
  802a4d:	50                   	push   %eax
  802a4e:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  802a54:	e8 4b ec ff ff       	call   8016a4 <sys_env_set_trapframe>
  802a59:	83 c4 10             	add    $0x10,%esp
  802a5c:	85 c0                	test   %eax,%eax
  802a5e:	0f 89 69 ff ff ff    	jns    8029cd <spawn+0x211>
  802a64:	e9 4f ff ff ff       	jmp    8029b8 <spawn+0x1fc>

00802a69 <exec>:
// 		 0x80000000(MYTEMPLATE) to be template block cache. Then sys_exec is a system call to complete 
// 		 memory setting.
// Remember: When there is virtual memory in ELF linking address overlaped with MYTEMPLATE, exec will fail.
int
exec(const char *prog, const char **argv)
{
  802a69:	55                   	push   %ebp
  802a6a:	89 e5                	mov    %esp,%ebp
  802a6c:	57                   	push   %edi
  802a6d:	56                   	push   %esi
  802a6e:	53                   	push   %ebx
  802a6f:	81 ec 34 02 00 00    	sub    $0x234,%esp
	struct Elf *elf;
	struct Proghdr *ph;
	int perm;	


	if ((r = open(prog, O_RDONLY)) < 0)
  802a75:	6a 00                	push   $0x0
  802a77:	ff 75 08             	pushl  0x8(%ebp)
  802a7a:	e8 d5 f8 ff ff       	call   802354 <open>
  802a7f:	89 85 d0 fd ff ff    	mov    %eax,-0x230(%ebp)
  802a85:	83 c4 10             	add    $0x10,%esp
  802a88:	85 c0                	test   %eax,%eax
  802a8a:	0f 88 a9 01 00 00    	js     802c39 <exec+0x1d0>
		return r;
	fd = r;

	// Read elf header
	elf = (struct Elf*) elf_buf;
  802a90:	8d bd e8 fd ff ff    	lea    -0x218(%ebp),%edi
	if (readn(fd, elf_buf, sizeof(elf_buf)) != sizeof(elf_buf)
  802a96:	83 ec 04             	sub    $0x4,%esp
  802a99:	68 00 02 00 00       	push   $0x200
  802a9e:	57                   	push   %edi
  802a9f:	50                   	push   %eax
  802aa0:	e8 32 f5 ff ff       	call   801fd7 <readn>
  802aa5:	83 c4 10             	add    $0x10,%esp
  802aa8:	3d 00 02 00 00       	cmp    $0x200,%eax
  802aad:	75 0c                	jne    802abb <exec+0x52>
	    || elf->e_magic != ELF_MAGIC) {
  802aaf:	81 bd e8 fd ff ff 7f 	cmpl   $0x464c457f,-0x218(%ebp)
  802ab6:	45 4c 46 
  802ab9:	74 34                	je     802aef <exec+0x86>
		close(fd);
  802abb:	83 ec 0c             	sub    $0xc,%esp
  802abe:	ff b5 d0 fd ff ff    	pushl  -0x230(%ebp)
  802ac4:	e8 4a f3 ff ff       	call   801e13 <close>
		cprintf("elf magic %08x want %08x\n", elf->e_magic, ELF_MAGIC);
  802ac9:	83 c4 0c             	add    $0xc,%esp
  802acc:	68 7f 45 4c 46       	push   $0x464c457f
  802ad1:	ff 37                	pushl  (%edi)
  802ad3:	68 73 3d 80 00       	push   $0x803d73
  802ad8:	e8 1b e0 ff ff       	call   800af8 <cprintf>
		return -E_NOT_EXEC;
  802add:	83 c4 10             	add    $0x10,%esp
  802ae0:	c7 85 d0 fd ff ff f2 	movl   $0xfffffff2,-0x230(%ebp)
  802ae7:	ff ff ff 
  802aea:	e9 4a 01 00 00       	jmp    802c39 <exec+0x1d0>
	}


	// Set up program segments as defined in ELF header.
	uint32_t now_addr = MYTEMPLATE;
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
  802aef:	8b 47 1c             	mov    0x1c(%edi),%eax
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  802af2:	66 83 7f 2c 00       	cmpw   $0x0,0x2c(%edi)
  802af7:	0f 84 8b 00 00 00    	je     802b88 <exec+0x11f>
	}


	// Set up program segments as defined in ELF header.
	uint32_t now_addr = MYTEMPLATE;
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
  802afd:	8d 9c 05 e8 fd ff ff 	lea    -0x218(%ebp,%eax,1),%ebx
		return -E_NOT_EXEC;
	}


	// Set up program segments as defined in ELF header.
	uint32_t now_addr = MYTEMPLATE;
  802b04:	c7 85 d4 fd ff ff 00 	movl   $0x80000000,-0x22c(%ebp)
  802b0b:	00 00 80 
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  802b0e:	be 00 00 00 00       	mov    $0x0,%esi
		if (ph->p_type != ELF_PROG_LOAD)
  802b13:	83 3b 01             	cmpl   $0x1,(%ebx)
  802b16:	75 62                	jne    802b7a <exec+0x111>
			continue;
		perm = PTE_P | PTE_U;
		if (ph->p_flags & ELF_PROG_FLAG_WRITE)
  802b18:	8b 43 18             	mov    0x18(%ebx),%eax
  802b1b:	83 e0 02             	and    $0x2,%eax
	uint32_t now_addr = MYTEMPLATE;
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
	for (i = 0; i < elf->e_phnum; i++, ph++) {
		if (ph->p_type != ELF_PROG_LOAD)
			continue;
		perm = PTE_P | PTE_U;
  802b1e:	83 f8 01             	cmp    $0x1,%eax
  802b21:	19 c0                	sbb    %eax,%eax
  802b23:	83 e0 fe             	and    $0xfffffffe,%eax
  802b26:	83 c0 07             	add    $0x7,%eax
		if (ph->p_flags & ELF_PROG_FLAG_WRITE)
			perm |= PTE_W;
		if ((r = map_segment(0, PGOFF(ph->p_va) + now_addr, ph->p_memsz,
  802b29:	8b 4b 14             	mov    0x14(%ebx),%ecx
  802b2c:	8b 53 08             	mov    0x8(%ebx),%edx
  802b2f:	81 e2 ff 0f 00 00    	and    $0xfff,%edx
  802b35:	03 95 d4 fd ff ff    	add    -0x22c(%ebp),%edx
  802b3b:	50                   	push   %eax
  802b3c:	ff 73 04             	pushl  0x4(%ebx)
  802b3f:	ff 73 10             	pushl  0x10(%ebx)
  802b42:	ff b5 d0 fd ff ff    	pushl  -0x230(%ebp)
  802b48:	b8 00 00 00 00       	mov    $0x0,%eax
  802b4d:	e8 a6 f9 ff ff       	call   8024f8 <map_segment>
  802b52:	83 c4 10             	add    $0x10,%esp
  802b55:	85 c0                	test   %eax,%eax
  802b57:	0f 88 a3 00 00 00    	js     802c00 <exec+0x197>
				     fd, ph->p_filesz, ph->p_offset, perm)) < 0)
			goto error;
		now_addr += ROUNDUP(ph->p_memsz + PGOFF(ph->p_va), PGSIZE);
  802b5d:	8b 53 14             	mov    0x14(%ebx),%edx
  802b60:	8b 43 08             	mov    0x8(%ebx),%eax
  802b63:	25 ff 0f 00 00       	and    $0xfff,%eax
  802b68:	8d 84 02 ff 0f 00 00 	lea    0xfff(%edx,%eax,1),%eax
  802b6f:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  802b74:	01 85 d4 fd ff ff    	add    %eax,-0x22c(%ebp)


	// Set up program segments as defined in ELF header.
	uint32_t now_addr = MYTEMPLATE;
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  802b7a:	46                   	inc    %esi
  802b7b:	0f b7 47 2c          	movzwl 0x2c(%edi),%eax
  802b7f:	39 f0                	cmp    %esi,%eax
  802b81:	7e 0f                	jle    802b92 <exec+0x129>
  802b83:	83 c3 20             	add    $0x20,%ebx
  802b86:	eb 8b                	jmp    802b13 <exec+0xaa>
		return -E_NOT_EXEC;
	}


	// Set up program segments as defined in ELF header.
	uint32_t now_addr = MYTEMPLATE;
  802b88:	c7 85 d4 fd ff ff 00 	movl   $0x80000000,-0x22c(%ebp)
  802b8f:	00 00 80 
		if ((r = map_segment(0, PGOFF(ph->p_va) + now_addr, ph->p_memsz,
				     fd, ph->p_filesz, ph->p_offset, perm)) < 0)
			goto error;
		now_addr += ROUNDUP(ph->p_memsz + PGOFF(ph->p_va), PGSIZE);
	}
	close(fd);
  802b92:	83 ec 0c             	sub    $0xc,%esp
  802b95:	ff b5 d0 fd ff ff    	pushl  -0x230(%ebp)
  802b9b:	e8 73 f2 ff ff       	call   801e13 <close>
	fd = -1;

	// Set up Stack 
	if ((r = init_stack(0, argv, &tf_esp, now_addr)) < 0)
  802ba0:	83 c4 04             	add    $0x4,%esp
  802ba3:	8d 8d e4 fd ff ff    	lea    -0x21c(%ebp),%ecx
  802ba9:	ff b5 d4 fd ff ff    	pushl  -0x22c(%ebp)
  802baf:	8b 55 0c             	mov    0xc(%ebp),%edx
  802bb2:	b8 00 00 00 00       	mov    $0x0,%eax
  802bb7:	e8 67 fa ff ff       	call   802623 <init_stack>
  802bbc:	89 85 d0 fd ff ff    	mov    %eax,-0x230(%ebp)
  802bc2:	83 c4 10             	add    $0x10,%esp
  802bc5:	85 c0                	test   %eax,%eax
  802bc7:	78 70                	js     802c39 <exec+0x1d0>
		return r;

	// Syscall to exec
	if (sys_exec(elf->e_entry, tf_esp, (void *)(elf_buf + elf->e_phoff), elf->e_phnum) < 0)
  802bc9:	0f b7 47 2c          	movzwl 0x2c(%edi),%eax
  802bcd:	50                   	push   %eax
  802bce:	8d 85 e8 fd ff ff    	lea    -0x218(%ebp),%eax
  802bd4:	03 47 1c             	add    0x1c(%edi),%eax
  802bd7:	50                   	push   %eax
  802bd8:	ff b5 e4 fd ff ff    	pushl  -0x21c(%ebp)
  802bde:	ff 77 18             	pushl  0x18(%edi)
  802be1:	e8 6e eb ff ff       	call   801754 <sys_exec>
  802be6:	83 c4 10             	add    $0x10,%esp
  802be9:	85 c0                	test   %eax,%eax
  802beb:	79 42                	jns    802c2f <exec+0x1c6>
	}
	close(fd);
	fd = -1;

	// Set up Stack 
	if ((r = init_stack(0, argv, &tf_esp, now_addr)) < 0)
  802bed:	8b 85 d0 fd ff ff    	mov    -0x230(%ebp),%eax
  802bf3:	89 85 d4 fd ff ff    	mov    %eax,-0x22c(%ebp)
				     fd, ph->p_filesz, ph->p_offset, perm)) < 0)
			goto error;
		now_addr += ROUNDUP(ph->p_memsz + PGOFF(ph->p_va), PGSIZE);
	}
	close(fd);
	fd = -1;
  802bf9:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
  802bfe:	eb 0c                	jmp    802c0c <exec+0x1a3>
  802c00:	89 85 d4 fd ff ff    	mov    %eax,-0x22c(%ebp)
	int perm;	


	if ((r = open(prog, O_RDONLY)) < 0)
		return r;
	fd = r;
  802c06:	8b 9d d0 fd ff ff    	mov    -0x230(%ebp),%ebx
	if (sys_exec(elf->e_entry, tf_esp, (void *)(elf_buf + elf->e_phoff), elf->e_phnum) < 0)
		goto error;
	return 0;

error:
	sys_env_destroy(0);
  802c0c:	83 ec 0c             	sub    $0xc,%esp
  802c0f:	6a 00                	push   $0x0
  802c11:	e8 91 e9 ff ff       	call   8015a7 <sys_env_destroy>
	close(fd);
  802c16:	89 1c 24             	mov    %ebx,(%esp)
  802c19:	e8 f5 f1 ff ff       	call   801e13 <close>
	return r;
  802c1e:	83 c4 10             	add    $0x10,%esp
  802c21:	8b 85 d4 fd ff ff    	mov    -0x22c(%ebp),%eax
  802c27:	89 85 d0 fd ff ff    	mov    %eax,-0x230(%ebp)
  802c2d:	eb 0a                	jmp    802c39 <exec+0x1d0>
		return r;

	// Syscall to exec
	if (sys_exec(elf->e_entry, tf_esp, (void *)(elf_buf + elf->e_phoff), elf->e_phnum) < 0)
		goto error;
	return 0;
  802c2f:	c7 85 d0 fd ff ff 00 	movl   $0x0,-0x230(%ebp)
  802c36:	00 00 00 

error:
	sys_env_destroy(0);
	close(fd);
	return r;
}
  802c39:	8b 85 d0 fd ff ff    	mov    -0x230(%ebp),%eax
  802c3f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802c42:	5b                   	pop    %ebx
  802c43:	5e                   	pop    %esi
  802c44:	5f                   	pop    %edi
  802c45:	c9                   	leave  
  802c46:	c3                   	ret    

00802c47 <execl>:
// Exec, taking command-line arguments array directly on the stack.
// NOTE: Must have a sentinal of NULL at the end of the args
// (none of the args may be NULL).
int
execl(const char *prog, const char *arg0, ...)
{
  802c47:	55                   	push   %ebp
  802c48:	89 e5                	mov    %esp,%ebp
  802c4a:	56                   	push   %esi
  802c4b:	53                   	push   %ebx
  802c4c:	8b 75 0c             	mov    0xc(%ebp),%esi
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  802c4f:	8d 45 14             	lea    0x14(%ebp),%eax
  802c52:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  802c56:	74 5f                	je     802cb7 <execl+0x70>
{
	// We calculate argc by advancing the args until we hit NULL.
	// The contract of the function guarantees that the last
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
  802c58:	b9 00 00 00 00       	mov    $0x0,%ecx
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
		argc++;
  802c5d:	41                   	inc    %ecx
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  802c5e:	89 c2                	mov    %eax,%edx
  802c60:	83 c0 04             	add    $0x4,%eax
  802c63:	83 3a 00             	cmpl   $0x0,(%edx)
  802c66:	75 f5                	jne    802c5d <execl+0x16>
		argc++;
	va_end(vl);

	// Now that we have the size of the args, do a second pass
	// and store the values in a VLA, which has the format of argv
	const char *argv[argc+2];
  802c68:	8d 04 8d 26 00 00 00 	lea    0x26(,%ecx,4),%eax
  802c6f:	83 e0 f0             	and    $0xfffffff0,%eax
  802c72:	29 c4                	sub    %eax,%esp
  802c74:	8d 44 24 0f          	lea    0xf(%esp),%eax
  802c78:	83 e0 f0             	and    $0xfffffff0,%eax
  802c7b:	89 c3                	mov    %eax,%ebx
	argv[0] = arg0;
  802c7d:	89 30                	mov    %esi,(%eax)
	argv[argc+1] = NULL;
  802c7f:	c7 44 88 04 00 00 00 	movl   $0x0,0x4(%eax,%ecx,4)
  802c86:	00 

	va_start(vl, arg0);
  802c87:	8d 55 10             	lea    0x10(%ebp),%edx
	unsigned i;
	for(i=0;i<argc;i++)
  802c8a:	89 ce                	mov    %ecx,%esi
  802c8c:	85 c9                	test   %ecx,%ecx
  802c8e:	74 14                	je     802ca4 <execl+0x5d>
  802c90:	b8 00 00 00 00       	mov    $0x0,%eax
		argv[i+1] = va_arg(vl, const char *);
  802c95:	40                   	inc    %eax
  802c96:	89 d1                	mov    %edx,%ecx
  802c98:	83 c2 04             	add    $0x4,%edx
  802c9b:	8b 09                	mov    (%ecx),%ecx
  802c9d:	89 0c 83             	mov    %ecx,(%ebx,%eax,4)
	argv[0] = arg0;
	argv[argc+1] = NULL;

	va_start(vl, arg0);
	unsigned i;
	for(i=0;i<argc;i++)
  802ca0:	39 f0                	cmp    %esi,%eax
  802ca2:	72 f1                	jb     802c95 <execl+0x4e>
		argv[i+1] = va_arg(vl, const char *);
	va_end(vl);
	return exec(prog, argv);
  802ca4:	83 ec 08             	sub    $0x8,%esp
  802ca7:	53                   	push   %ebx
  802ca8:	ff 75 08             	pushl  0x8(%ebp)
  802cab:	e8 b9 fd ff ff       	call   802a69 <exec>
}
  802cb0:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802cb3:	5b                   	pop    %ebx
  802cb4:	5e                   	pop    %esi
  802cb5:	c9                   	leave  
  802cb6:	c3                   	ret    
		argc++;
	va_end(vl);

	// Now that we have the size of the args, do a second pass
	// and store the values in a VLA, which has the format of argv
	const char *argv[argc+2];
  802cb7:	83 ec 20             	sub    $0x20,%esp
  802cba:	8d 44 24 0f          	lea    0xf(%esp),%eax
  802cbe:	83 e0 f0             	and    $0xfffffff0,%eax
  802cc1:	89 c3                	mov    %eax,%ebx
	argv[0] = arg0;
  802cc3:	89 30                	mov    %esi,(%eax)
	argv[argc+1] = NULL;
  802cc5:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
  802ccc:	eb d6                	jmp    802ca4 <execl+0x5d>

00802cce <spawnl>:
// Spawn, taking command-line arguments array directly on the stack.
// NOTE: Must have a sentinal of NULL at the end of the args
// (none of the args may be NULL).
int
spawnl(const char *prog, const char *arg0, ...)
{
  802cce:	55                   	push   %ebp
  802ccf:	89 e5                	mov    %esp,%ebp
  802cd1:	56                   	push   %esi
  802cd2:	53                   	push   %ebx
  802cd3:	8b 75 0c             	mov    0xc(%ebp),%esi
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  802cd6:	8d 45 14             	lea    0x14(%ebp),%eax
  802cd9:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  802cdd:	74 5f                	je     802d3e <spawnl+0x70>
{
	// We calculate argc by advancing the args until we hit NULL.
	// The contract of the function guarantees that the last
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
  802cdf:	b9 00 00 00 00       	mov    $0x0,%ecx
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
		argc++;
  802ce4:	41                   	inc    %ecx
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  802ce5:	89 c2                	mov    %eax,%edx
  802ce7:	83 c0 04             	add    $0x4,%eax
  802cea:	83 3a 00             	cmpl   $0x0,(%edx)
  802ced:	75 f5                	jne    802ce4 <spawnl+0x16>
		argc++;
	va_end(vl);

	// Now that we have the size of the args, do a second pass
	// and store the values in a VLA, which has the format of argv
	const char *argv[argc+2];
  802cef:	8d 04 8d 26 00 00 00 	lea    0x26(,%ecx,4),%eax
  802cf6:	83 e0 f0             	and    $0xfffffff0,%eax
  802cf9:	29 c4                	sub    %eax,%esp
  802cfb:	8d 44 24 0f          	lea    0xf(%esp),%eax
  802cff:	83 e0 f0             	and    $0xfffffff0,%eax
  802d02:	89 c3                	mov    %eax,%ebx
	argv[0] = arg0;
  802d04:	89 30                	mov    %esi,(%eax)
	argv[argc+1] = NULL;
  802d06:	c7 44 88 04 00 00 00 	movl   $0x0,0x4(%eax,%ecx,4)
  802d0d:	00 

	va_start(vl, arg0);
  802d0e:	8d 55 10             	lea    0x10(%ebp),%edx
	unsigned i;
	for(i=0;i<argc;i++)
  802d11:	89 ce                	mov    %ecx,%esi
  802d13:	85 c9                	test   %ecx,%ecx
  802d15:	74 14                	je     802d2b <spawnl+0x5d>
  802d17:	b8 00 00 00 00       	mov    $0x0,%eax
		argv[i+1] = va_arg(vl, const char *);
  802d1c:	40                   	inc    %eax
  802d1d:	89 d1                	mov    %edx,%ecx
  802d1f:	83 c2 04             	add    $0x4,%edx
  802d22:	8b 09                	mov    (%ecx),%ecx
  802d24:	89 0c 83             	mov    %ecx,(%ebx,%eax,4)
	argv[0] = arg0;
	argv[argc+1] = NULL;

	va_start(vl, arg0);
	unsigned i;
	for(i=0;i<argc;i++)
  802d27:	39 f0                	cmp    %esi,%eax
  802d29:	72 f1                	jb     802d1c <spawnl+0x4e>
		argv[i+1] = va_arg(vl, const char *);
	va_end(vl);
	return spawn(prog, argv);
  802d2b:	83 ec 08             	sub    $0x8,%esp
  802d2e:	53                   	push   %ebx
  802d2f:	ff 75 08             	pushl  0x8(%ebp)
  802d32:	e8 85 fa ff ff       	call   8027bc <spawn>
}
  802d37:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802d3a:	5b                   	pop    %ebx
  802d3b:	5e                   	pop    %esi
  802d3c:	c9                   	leave  
  802d3d:	c3                   	ret    
		argc++;
	va_end(vl);

	// Now that we have the size of the args, do a second pass
	// and store the values in a VLA, which has the format of argv
	const char *argv[argc+2];
  802d3e:	83 ec 20             	sub    $0x20,%esp
  802d41:	8d 44 24 0f          	lea    0xf(%esp),%eax
  802d45:	83 e0 f0             	and    $0xfffffff0,%eax
  802d48:	89 c3                	mov    %eax,%ebx
	argv[0] = arg0;
  802d4a:	89 30                	mov    %esi,(%eax)
	argv[argc+1] = NULL;
  802d4c:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
  802d53:	eb d6                	jmp    802d2b <spawnl+0x5d>
  802d55:	00 00                	add    %al,(%eax)
	...

00802d58 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  802d58:	55                   	push   %ebp
  802d59:	89 e5                	mov    %esp,%ebp
  802d5b:	56                   	push   %esi
  802d5c:	53                   	push   %ebx
  802d5d:	8b 75 0c             	mov    0xc(%ebp),%esi
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  802d60:	83 ec 0c             	sub    $0xc,%esp
  802d63:	ff 75 08             	pushl  0x8(%ebp)
  802d66:	e8 d9 ee ff ff       	call   801c44 <fd2data>
  802d6b:	89 c3                	mov    %eax,%ebx
	strcpy(stat->st_name, "<pipe>");
  802d6d:	83 c4 08             	add    $0x8,%esp
  802d70:	68 fa 3d 80 00       	push   $0x803dfa
  802d75:	56                   	push   %esi
  802d76:	e8 17 e4 ff ff       	call   801192 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  802d7b:	8b 43 04             	mov    0x4(%ebx),%eax
  802d7e:	2b 03                	sub    (%ebx),%eax
  802d80:	89 86 80 00 00 00    	mov    %eax,0x80(%esi)
	stat->st_isdir = 0;
  802d86:	c7 86 84 00 00 00 00 	movl   $0x0,0x84(%esi)
  802d8d:	00 00 00 
	stat->st_dev = &devpipe;
  802d90:	c7 86 88 00 00 00 3c 	movl   $0x80403c,0x88(%esi)
  802d97:	40 80 00 
	return 0;
}
  802d9a:	b8 00 00 00 00       	mov    $0x0,%eax
  802d9f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802da2:	5b                   	pop    %ebx
  802da3:	5e                   	pop    %esi
  802da4:	c9                   	leave  
  802da5:	c3                   	ret    

00802da6 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  802da6:	55                   	push   %ebp
  802da7:	89 e5                	mov    %esp,%ebp
  802da9:	53                   	push   %ebx
  802daa:	83 ec 0c             	sub    $0xc,%esp
  802dad:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  802db0:	53                   	push   %ebx
  802db1:	6a 00                	push   $0x0
  802db3:	e8 a6 e8 ff ff       	call   80165e <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  802db8:	89 1c 24             	mov    %ebx,(%esp)
  802dbb:	e8 84 ee ff ff       	call   801c44 <fd2data>
  802dc0:	83 c4 08             	add    $0x8,%esp
  802dc3:	50                   	push   %eax
  802dc4:	6a 00                	push   $0x0
  802dc6:	e8 93 e8 ff ff       	call   80165e <sys_page_unmap>
}
  802dcb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802dce:	c9                   	leave  
  802dcf:	c3                   	ret    

00802dd0 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  802dd0:	55                   	push   %ebp
  802dd1:	89 e5                	mov    %esp,%ebp
  802dd3:	57                   	push   %edi
  802dd4:	56                   	push   %esi
  802dd5:	53                   	push   %ebx
  802dd6:	83 ec 1c             	sub    $0x1c,%esp
  802dd9:	89 c7                	mov    %eax,%edi
  802ddb:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  802dde:	a1 24 54 80 00       	mov    0x805424,%eax
  802de3:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  802de6:	83 ec 0c             	sub    $0xc,%esp
  802de9:	57                   	push   %edi
  802dea:	e8 09 05 00 00       	call   8032f8 <pageref>
  802def:	89 c6                	mov    %eax,%esi
  802df1:	83 c4 04             	add    $0x4,%esp
  802df4:	ff 75 e4             	pushl  -0x1c(%ebp)
  802df7:	e8 fc 04 00 00       	call   8032f8 <pageref>
  802dfc:	83 c4 10             	add    $0x10,%esp
  802dff:	39 c6                	cmp    %eax,%esi
  802e01:	0f 94 c0             	sete   %al
  802e04:	0f b6 c0             	movzbl %al,%eax
		nn = thisenv->env_runs;
  802e07:	8b 15 24 54 80 00    	mov    0x805424,%edx
  802e0d:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  802e10:	39 cb                	cmp    %ecx,%ebx
  802e12:	75 08                	jne    802e1c <_pipeisclosed+0x4c>
			return ret;
		if (n != nn && ret == 1)
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
	}
}
  802e14:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802e17:	5b                   	pop    %ebx
  802e18:	5e                   	pop    %esi
  802e19:	5f                   	pop    %edi
  802e1a:	c9                   	leave  
  802e1b:	c3                   	ret    
		n = thisenv->env_runs;
		ret = pageref(fd) == pageref(p);
		nn = thisenv->env_runs;
		if (n == nn)
			return ret;
		if (n != nn && ret == 1)
  802e1c:	83 f8 01             	cmp    $0x1,%eax
  802e1f:	75 bd                	jne    802dde <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  802e21:	8b 42 58             	mov    0x58(%edx),%eax
  802e24:	6a 01                	push   $0x1
  802e26:	50                   	push   %eax
  802e27:	53                   	push   %ebx
  802e28:	68 01 3e 80 00       	push   $0x803e01
  802e2d:	e8 c6 dc ff ff       	call   800af8 <cprintf>
  802e32:	83 c4 10             	add    $0x10,%esp
  802e35:	eb a7                	jmp    802dde <_pipeisclosed+0xe>

00802e37 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  802e37:	55                   	push   %ebp
  802e38:	89 e5                	mov    %esp,%ebp
  802e3a:	57                   	push   %edi
  802e3b:	56                   	push   %esi
  802e3c:	53                   	push   %ebx
  802e3d:	83 ec 28             	sub    $0x28,%esp
  802e40:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  802e43:	56                   	push   %esi
  802e44:	e8 fb ed ff ff       	call   801c44 <fd2data>
  802e49:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802e4b:	83 c4 10             	add    $0x10,%esp
  802e4e:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  802e52:	75 4a                	jne    802e9e <devpipe_write+0x67>
  802e54:	bf 00 00 00 00       	mov    $0x0,%edi
  802e59:	eb 56                	jmp    802eb1 <devpipe_write+0x7a>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  802e5b:	89 da                	mov    %ebx,%edx
  802e5d:	89 f0                	mov    %esi,%eax
  802e5f:	e8 6c ff ff ff       	call   802dd0 <_pipeisclosed>
  802e64:	85 c0                	test   %eax,%eax
  802e66:	75 4d                	jne    802eb5 <devpipe_write+0x7e>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  802e68:	e8 80 e7 ff ff       	call   8015ed <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  802e6d:	8b 43 04             	mov    0x4(%ebx),%eax
  802e70:	8b 13                	mov    (%ebx),%edx
  802e72:	83 c2 20             	add    $0x20,%edx
  802e75:	39 d0                	cmp    %edx,%eax
  802e77:	73 e2                	jae    802e5b <devpipe_write+0x24>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  802e79:	89 c2                	mov    %eax,%edx
  802e7b:	81 e2 1f 00 00 80    	and    $0x8000001f,%edx
  802e81:	79 05                	jns    802e88 <devpipe_write+0x51>
  802e83:	4a                   	dec    %edx
  802e84:	83 ca e0             	or     $0xffffffe0,%edx
  802e87:	42                   	inc    %edx
  802e88:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802e8b:	8a 0c 39             	mov    (%ecx,%edi,1),%cl
  802e8e:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  802e92:	40                   	inc    %eax
  802e93:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802e96:	47                   	inc    %edi
  802e97:	39 7d 10             	cmp    %edi,0x10(%ebp)
  802e9a:	77 07                	ja     802ea3 <devpipe_write+0x6c>
  802e9c:	eb 13                	jmp    802eb1 <devpipe_write+0x7a>
  802e9e:	bf 00 00 00 00       	mov    $0x0,%edi
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  802ea3:	8b 43 04             	mov    0x4(%ebx),%eax
  802ea6:	8b 13                	mov    (%ebx),%edx
  802ea8:	83 c2 20             	add    $0x20,%edx
  802eab:	39 d0                	cmp    %edx,%eax
  802ead:	73 ac                	jae    802e5b <devpipe_write+0x24>
  802eaf:	eb c8                	jmp    802e79 <devpipe_write+0x42>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  802eb1:	89 f8                	mov    %edi,%eax
  802eb3:	eb 05                	jmp    802eba <devpipe_write+0x83>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  802eb5:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  802eba:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802ebd:	5b                   	pop    %ebx
  802ebe:	5e                   	pop    %esi
  802ebf:	5f                   	pop    %edi
  802ec0:	c9                   	leave  
  802ec1:	c3                   	ret    

00802ec2 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  802ec2:	55                   	push   %ebp
  802ec3:	89 e5                	mov    %esp,%ebp
  802ec5:	57                   	push   %edi
  802ec6:	56                   	push   %esi
  802ec7:	53                   	push   %ebx
  802ec8:	83 ec 18             	sub    $0x18,%esp
  802ecb:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  802ece:	57                   	push   %edi
  802ecf:	e8 70 ed ff ff       	call   801c44 <fd2data>
  802ed4:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802ed6:	83 c4 10             	add    $0x10,%esp
  802ed9:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  802edd:	75 44                	jne    802f23 <devpipe_read+0x61>
  802edf:	be 00 00 00 00       	mov    $0x0,%esi
  802ee4:	eb 4f                	jmp    802f35 <devpipe_read+0x73>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
				return i;
  802ee6:	89 f0                	mov    %esi,%eax
  802ee8:	eb 54                	jmp    802f3e <devpipe_read+0x7c>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  802eea:	89 da                	mov    %ebx,%edx
  802eec:	89 f8                	mov    %edi,%eax
  802eee:	e8 dd fe ff ff       	call   802dd0 <_pipeisclosed>
  802ef3:	85 c0                	test   %eax,%eax
  802ef5:	75 42                	jne    802f39 <devpipe_read+0x77>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  802ef7:	e8 f1 e6 ff ff       	call   8015ed <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  802efc:	8b 03                	mov    (%ebx),%eax
  802efe:	3b 43 04             	cmp    0x4(%ebx),%eax
  802f01:	74 e7                	je     802eea <devpipe_read+0x28>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  802f03:	25 1f 00 00 80       	and    $0x8000001f,%eax
  802f08:	79 05                	jns    802f0f <devpipe_read+0x4d>
  802f0a:	48                   	dec    %eax
  802f0b:	83 c8 e0             	or     $0xffffffe0,%eax
  802f0e:	40                   	inc    %eax
  802f0f:	8a 44 03 08          	mov    0x8(%ebx,%eax,1),%al
  802f13:	8b 55 0c             	mov    0xc(%ebp),%edx
  802f16:	88 04 32             	mov    %al,(%edx,%esi,1)
		p->p_rpos++;
  802f19:	ff 03                	incl   (%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802f1b:	46                   	inc    %esi
  802f1c:	39 75 10             	cmp    %esi,0x10(%ebp)
  802f1f:	77 07                	ja     802f28 <devpipe_read+0x66>
  802f21:	eb 12                	jmp    802f35 <devpipe_read+0x73>
  802f23:	be 00 00 00 00       	mov    $0x0,%esi
		while (p->p_rpos == p->p_wpos) {
  802f28:	8b 03                	mov    (%ebx),%eax
  802f2a:	3b 43 04             	cmp    0x4(%ebx),%eax
  802f2d:	75 d4                	jne    802f03 <devpipe_read+0x41>
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  802f2f:	85 f6                	test   %esi,%esi
  802f31:	75 b3                	jne    802ee6 <devpipe_read+0x24>
  802f33:	eb b5                	jmp    802eea <devpipe_read+0x28>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  802f35:	89 f0                	mov    %esi,%eax
  802f37:	eb 05                	jmp    802f3e <devpipe_read+0x7c>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  802f39:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  802f3e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802f41:	5b                   	pop    %ebx
  802f42:	5e                   	pop    %esi
  802f43:	5f                   	pop    %edi
  802f44:	c9                   	leave  
  802f45:	c3                   	ret    

00802f46 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  802f46:	55                   	push   %ebp
  802f47:	89 e5                	mov    %esp,%ebp
  802f49:	57                   	push   %edi
  802f4a:	56                   	push   %esi
  802f4b:	53                   	push   %ebx
  802f4c:	83 ec 28             	sub    $0x28,%esp
  802f4f:	8b 7d 08             	mov    0x8(%ebp),%edi
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  802f52:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  802f55:	50                   	push   %eax
  802f56:	e8 01 ed ff ff       	call   801c5c <fd_alloc>
  802f5b:	89 c3                	mov    %eax,%ebx
  802f5d:	83 c4 10             	add    $0x10,%esp
  802f60:	85 c0                	test   %eax,%eax
  802f62:	0f 88 24 01 00 00    	js     80308c <pipe+0x146>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802f68:	83 ec 04             	sub    $0x4,%esp
  802f6b:	68 07 04 00 00       	push   $0x407
  802f70:	ff 75 e4             	pushl  -0x1c(%ebp)
  802f73:	6a 00                	push   $0x0
  802f75:	e8 9a e6 ff ff       	call   801614 <sys_page_alloc>
  802f7a:	89 c3                	mov    %eax,%ebx
  802f7c:	83 c4 10             	add    $0x10,%esp
  802f7f:	85 c0                	test   %eax,%eax
  802f81:	0f 88 05 01 00 00    	js     80308c <pipe+0x146>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  802f87:	83 ec 0c             	sub    $0xc,%esp
  802f8a:	8d 45 e0             	lea    -0x20(%ebp),%eax
  802f8d:	50                   	push   %eax
  802f8e:	e8 c9 ec ff ff       	call   801c5c <fd_alloc>
  802f93:	89 c3                	mov    %eax,%ebx
  802f95:	83 c4 10             	add    $0x10,%esp
  802f98:	85 c0                	test   %eax,%eax
  802f9a:	0f 88 dc 00 00 00    	js     80307c <pipe+0x136>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802fa0:	83 ec 04             	sub    $0x4,%esp
  802fa3:	68 07 04 00 00       	push   $0x407
  802fa8:	ff 75 e0             	pushl  -0x20(%ebp)
  802fab:	6a 00                	push   $0x0
  802fad:	e8 62 e6 ff ff       	call   801614 <sys_page_alloc>
  802fb2:	89 c3                	mov    %eax,%ebx
  802fb4:	83 c4 10             	add    $0x10,%esp
  802fb7:	85 c0                	test   %eax,%eax
  802fb9:	0f 88 bd 00 00 00    	js     80307c <pipe+0x136>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  802fbf:	83 ec 0c             	sub    $0xc,%esp
  802fc2:	ff 75 e4             	pushl  -0x1c(%ebp)
  802fc5:	e8 7a ec ff ff       	call   801c44 <fd2data>
  802fca:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802fcc:	83 c4 0c             	add    $0xc,%esp
  802fcf:	68 07 04 00 00       	push   $0x407
  802fd4:	50                   	push   %eax
  802fd5:	6a 00                	push   $0x0
  802fd7:	e8 38 e6 ff ff       	call   801614 <sys_page_alloc>
  802fdc:	89 c3                	mov    %eax,%ebx
  802fde:	83 c4 10             	add    $0x10,%esp
  802fe1:	85 c0                	test   %eax,%eax
  802fe3:	0f 88 83 00 00 00    	js     80306c <pipe+0x126>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802fe9:	83 ec 0c             	sub    $0xc,%esp
  802fec:	ff 75 e0             	pushl  -0x20(%ebp)
  802fef:	e8 50 ec ff ff       	call   801c44 <fd2data>
  802ff4:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  802ffb:	50                   	push   %eax
  802ffc:	6a 00                	push   $0x0
  802ffe:	56                   	push   %esi
  802fff:	6a 00                	push   $0x0
  803001:	e8 32 e6 ff ff       	call   801638 <sys_page_map>
  803006:	89 c3                	mov    %eax,%ebx
  803008:	83 c4 20             	add    $0x20,%esp
  80300b:	85 c0                	test   %eax,%eax
  80300d:	78 4f                	js     80305e <pipe+0x118>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  80300f:	8b 15 3c 40 80 00    	mov    0x80403c,%edx
  803015:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  803018:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  80301a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80301d:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  803024:	8b 15 3c 40 80 00    	mov    0x80403c,%edx
  80302a:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80302d:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  80302f:	8b 45 e0             	mov    -0x20(%ebp),%eax
  803032:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  803039:	83 ec 0c             	sub    $0xc,%esp
  80303c:	ff 75 e4             	pushl  -0x1c(%ebp)
  80303f:	e8 f0 eb ff ff       	call   801c34 <fd2num>
  803044:	89 07                	mov    %eax,(%edi)
	pfd[1] = fd2num(fd1);
  803046:	83 c4 04             	add    $0x4,%esp
  803049:	ff 75 e0             	pushl  -0x20(%ebp)
  80304c:	e8 e3 eb ff ff       	call   801c34 <fd2num>
  803051:	89 47 04             	mov    %eax,0x4(%edi)
	return 0;
  803054:	83 c4 10             	add    $0x10,%esp
  803057:	bb 00 00 00 00       	mov    $0x0,%ebx
  80305c:	eb 2e                	jmp    80308c <pipe+0x146>

    err3:
	sys_page_unmap(0, va);
  80305e:	83 ec 08             	sub    $0x8,%esp
  803061:	56                   	push   %esi
  803062:	6a 00                	push   $0x0
  803064:	e8 f5 e5 ff ff       	call   80165e <sys_page_unmap>
  803069:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  80306c:	83 ec 08             	sub    $0x8,%esp
  80306f:	ff 75 e0             	pushl  -0x20(%ebp)
  803072:	6a 00                	push   $0x0
  803074:	e8 e5 e5 ff ff       	call   80165e <sys_page_unmap>
  803079:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  80307c:	83 ec 08             	sub    $0x8,%esp
  80307f:	ff 75 e4             	pushl  -0x1c(%ebp)
  803082:	6a 00                	push   $0x0
  803084:	e8 d5 e5 ff ff       	call   80165e <sys_page_unmap>
  803089:	83 c4 10             	add    $0x10,%esp
    err:
	return r;
}
  80308c:	89 d8                	mov    %ebx,%eax
  80308e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  803091:	5b                   	pop    %ebx
  803092:	5e                   	pop    %esi
  803093:	5f                   	pop    %edi
  803094:	c9                   	leave  
  803095:	c3                   	ret    

00803096 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  803096:	55                   	push   %ebp
  803097:	89 e5                	mov    %esp,%ebp
  803099:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80309c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80309f:	50                   	push   %eax
  8030a0:	ff 75 08             	pushl  0x8(%ebp)
  8030a3:	e8 27 ec ff ff       	call   801ccf <fd_lookup>
  8030a8:	83 c4 10             	add    $0x10,%esp
  8030ab:	85 c0                	test   %eax,%eax
  8030ad:	78 18                	js     8030c7 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  8030af:	83 ec 0c             	sub    $0xc,%esp
  8030b2:	ff 75 f4             	pushl  -0xc(%ebp)
  8030b5:	e8 8a eb ff ff       	call   801c44 <fd2data>
	return _pipeisclosed(fd, p);
  8030ba:	89 c2                	mov    %eax,%edx
  8030bc:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8030bf:	e8 0c fd ff ff       	call   802dd0 <_pipeisclosed>
  8030c4:	83 c4 10             	add    $0x10,%esp
}
  8030c7:	c9                   	leave  
  8030c8:	c3                   	ret    
  8030c9:	00 00                	add    %al,(%eax)
	...

008030cc <wait>:
#include <inc/lib.h>

// Waits until 'envid' exits.
void
wait(envid_t envid)
{
  8030cc:	55                   	push   %ebp
  8030cd:	89 e5                	mov    %esp,%ebp
  8030cf:	57                   	push   %edi
  8030d0:	56                   	push   %esi
  8030d1:	53                   	push   %ebx
  8030d2:	83 ec 0c             	sub    $0xc,%esp
  8030d5:	8b 55 08             	mov    0x8(%ebp),%edx
	const volatile struct Env *e;

	assert(envid != 0);
  8030d8:	85 d2                	test   %edx,%edx
  8030da:	75 16                	jne    8030f2 <wait+0x26>
  8030dc:	68 19 3e 80 00       	push   $0x803e19
  8030e1:	68 f2 36 80 00       	push   $0x8036f2
  8030e6:	6a 09                	push   $0x9
  8030e8:	68 24 3e 80 00       	push   $0x803e24
  8030ed:	e8 2e d9 ff ff       	call   800a20 <_panic>
	e = &envs[ENVX(envid)];
  8030f2:	89 d0                	mov    %edx,%eax
  8030f4:	25 ff 03 00 00       	and    $0x3ff,%eax
	while (e->env_id == envid && e->env_status != ENV_FREE)
  8030f9:	89 c1                	mov    %eax,%ecx
  8030fb:	c1 e1 07             	shl    $0x7,%ecx
  8030fe:	8d 8c 81 08 00 c0 ee 	lea    -0x113ffff8(%ecx,%eax,4),%ecx
  803105:	8b 79 40             	mov    0x40(%ecx),%edi
  803108:	39 d7                	cmp    %edx,%edi
  80310a:	75 36                	jne    803142 <wait+0x76>
  80310c:	89 c2                	mov    %eax,%edx
  80310e:	c1 e2 07             	shl    $0x7,%edx
  803111:	8d 94 82 04 00 c0 ee 	lea    -0x113ffffc(%edx,%eax,4),%edx
  803118:	8b 52 50             	mov    0x50(%edx),%edx
  80311b:	85 d2                	test   %edx,%edx
  80311d:	74 23                	je     803142 <wait+0x76>
  80311f:	89 c2                	mov    %eax,%edx
  803121:	c1 e2 07             	shl    $0x7,%edx
  803124:	8d 34 82             	lea    (%edx,%eax,4),%esi
  803127:	89 cb                	mov    %ecx,%ebx
  803129:	81 c6 04 00 c0 ee    	add    $0xeec00004,%esi
		sys_yield();
  80312f:	e8 b9 e4 ff ff       	call   8015ed <sys_yield>
{
	const volatile struct Env *e;

	assert(envid != 0);
	e = &envs[ENVX(envid)];
	while (e->env_id == envid && e->env_status != ENV_FREE)
  803134:	8b 43 40             	mov    0x40(%ebx),%eax
  803137:	39 f8                	cmp    %edi,%eax
  803139:	75 07                	jne    803142 <wait+0x76>
  80313b:	8b 46 50             	mov    0x50(%esi),%eax
  80313e:	85 c0                	test   %eax,%eax
  803140:	75 ed                	jne    80312f <wait+0x63>
		sys_yield();
}
  803142:	8d 65 f4             	lea    -0xc(%ebp),%esp
  803145:	5b                   	pop    %ebx
  803146:	5e                   	pop    %esi
  803147:	5f                   	pop    %edi
  803148:	c9                   	leave  
  803149:	c3                   	ret    
	...

0080314c <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  80314c:	55                   	push   %ebp
  80314d:	89 e5                	mov    %esp,%ebp
  80314f:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  803152:	83 3d 00 70 80 00 00 	cmpl   $0x0,0x807000
  803159:	75 52                	jne    8031ad <set_pgfault_handler+0x61>
		// First time through!	
		// LAB 4: Your code here.

		//int sys_page_alloc(envid_t envid, void *va, int perm)
		r = sys_page_alloc(0, (void*)(UXSTACKTOP - PGSIZE), PTE_U | PTE_W | PTE_P);
  80315b:	83 ec 04             	sub    $0x4,%esp
  80315e:	6a 07                	push   $0x7
  803160:	68 00 f0 bf ee       	push   $0xeebff000
  803165:	6a 00                	push   $0x0
  803167:	e8 a8 e4 ff ff       	call   801614 <sys_page_alloc>
		if (r < 0) {
  80316c:	83 c4 10             	add    $0x10,%esp
  80316f:	85 c0                	test   %eax,%eax
  803171:	79 12                	jns    803185 <set_pgfault_handler+0x39>
			panic("sys_page_alloc error : %e\n", r);
  803173:	50                   	push   %eax
  803174:	68 2f 3e 80 00       	push   $0x803e2f
  803179:	6a 24                	push   $0x24
  80317b:	68 4a 3e 80 00       	push   $0x803e4a
  803180:	e8 9b d8 ff ff       	call   800a20 <_panic>
		}

		// how to know envid, put 0, envid2env will help us to get curenv in syscall
		r = sys_env_set_pgfault_upcall(0, _pgfault_upcall);		
  803185:	83 ec 08             	sub    $0x8,%esp
  803188:	68 b8 31 80 00       	push   $0x8031b8
  80318d:	6a 00                	push   $0x0
  80318f:	e8 33 e5 ff ff       	call   8016c7 <sys_env_set_pgfault_upcall>
		if (r < 0) {
  803194:	83 c4 10             	add    $0x10,%esp
  803197:	85 c0                	test   %eax,%eax
  803199:	79 12                	jns    8031ad <set_pgfault_handler+0x61>
			panic("sys_env_set_pgfault_upcall error : %e\n", r);
  80319b:	50                   	push   %eax
  80319c:	68 58 3e 80 00       	push   $0x803e58
  8031a1:	6a 2a                	push   $0x2a
  8031a3:	68 4a 3e 80 00       	push   $0x803e4a
  8031a8:	e8 73 d8 ff ff       	call   800a20 <_panic>
		}
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  8031ad:	8b 45 08             	mov    0x8(%ebp),%eax
  8031b0:	a3 00 70 80 00       	mov    %eax,0x807000
}
  8031b5:	c9                   	leave  
  8031b6:	c3                   	ret    
	...

008031b8 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  8031b8:	54                   	push   %esp
	movl _pgfault_handler, %eax
  8031b9:	a1 00 70 80 00       	mov    0x807000,%eax
	call *%eax
  8031be:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  8031c0:	83 c4 04             	add    $0x4,%esp
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	
	// fix old esp
	movl 0x30(%esp), %eax
  8031c3:	8b 44 24 30          	mov    0x30(%esp),%eax
	subl $0x4, %eax
  8031c7:	83 e8 04             	sub    $0x4,%eax
	movl %eax, 0x30(%esp)
  8031ca:	89 44 24 30          	mov    %eax,0x30(%esp)

	// set trap-time %eip
	movl 0x28(%esp), %ebx
  8031ce:	8b 5c 24 28          	mov    0x28(%esp),%ebx
	movl %ebx, (%eax)
  8031d2:	89 18                	mov    %ebx,(%eax)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	addl $0x08, %esp 	// ignore err_code and fault_va
  8031d4:	83 c4 08             	add    $0x8,%esp
	popal 				// restore registers
  8031d7:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $0x04, %esp 	// ignore eip 
  8031d8:	83 c4 04             	add    $0x4,%esp
	popfl				// modify eflags
  8031db:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp
  8031dc:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  8031dd:	c3                   	ret    
	...

008031e0 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8031e0:	55                   	push   %ebp
  8031e1:	89 e5                	mov    %esp,%ebp
  8031e3:	56                   	push   %esi
  8031e4:	53                   	push   %ebx
  8031e5:	8b 75 08             	mov    0x8(%ebp),%esi
  8031e8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8031eb:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// cprintf("0x%x 0x%x 0x%x\n", (uint32_t)from_env_store, (uint32_t)pg, (uint32_t)perm_store);
	int r;
	if (pg != NULL) {
  8031ee:	85 c0                	test   %eax,%eax
  8031f0:	74 0e                	je     803200 <ipc_recv+0x20>
		r = sys_ipc_recv(pg);
  8031f2:	83 ec 0c             	sub    $0xc,%esp
  8031f5:	50                   	push   %eax
  8031f6:	e8 14 e5 ff ff       	call   80170f <sys_ipc_recv>
  8031fb:	83 c4 10             	add    $0x10,%esp
  8031fe:	eb 10                	jmp    803210 <ipc_recv+0x30>
	} else {
		r = sys_ipc_recv((void *)UTOP);
  803200:	83 ec 0c             	sub    $0xc,%esp
  803203:	68 00 00 c0 ee       	push   $0xeec00000
  803208:	e8 02 e5 ff ff       	call   80170f <sys_ipc_recv>
  80320d:	83 c4 10             	add    $0x10,%esp
	}

	if (r == 0) {
  803210:	85 c0                	test   %eax,%eax
  803212:	75 26                	jne    80323a <ipc_recv+0x5a>
		if (from_env_store != NULL) *from_env_store = thisenv->env_ipc_from;
  803214:	85 f6                	test   %esi,%esi
  803216:	74 0a                	je     803222 <ipc_recv+0x42>
  803218:	a1 24 54 80 00       	mov    0x805424,%eax
  80321d:	8b 40 74             	mov    0x74(%eax),%eax
  803220:	89 06                	mov    %eax,(%esi)
		if (perm_store != NULL) *perm_store = thisenv->env_ipc_perm;
  803222:	85 db                	test   %ebx,%ebx
  803224:	74 0a                	je     803230 <ipc_recv+0x50>
  803226:	a1 24 54 80 00       	mov    0x805424,%eax
  80322b:	8b 40 78             	mov    0x78(%eax),%eax
  80322e:	89 03                	mov    %eax,(%ebx)
		return thisenv->env_ipc_value;
  803230:	a1 24 54 80 00       	mov    0x805424,%eax
  803235:	8b 40 70             	mov    0x70(%eax),%eax
  803238:	eb 14                	jmp    80324e <ipc_recv+0x6e>
	} else {
		// fails;
		if (from_env_store != NULL) *from_env_store = 0;
  80323a:	85 f6                	test   %esi,%esi
  80323c:	74 06                	je     803244 <ipc_recv+0x64>
  80323e:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		if (perm_store != NULL) *perm_store = 0;
  803244:	85 db                	test   %ebx,%ebx
  803246:	74 06                	je     80324e <ipc_recv+0x6e>
  803248:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
		return r;
	}
}
  80324e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  803251:	5b                   	pop    %ebx
  803252:	5e                   	pop    %esi
  803253:	c9                   	leave  
  803254:	c3                   	ret    

00803255 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  803255:	55                   	push   %ebp
  803256:	89 e5                	mov    %esp,%ebp
  803258:	57                   	push   %edi
  803259:	56                   	push   %esi
  80325a:	53                   	push   %ebx
  80325b:	83 ec 0c             	sub    $0xc,%esp
  80325e:	8b 7d 0c             	mov    0xc(%ebp),%edi
  803261:	8b 5d 10             	mov    0x10(%ebp),%ebx
  803264:	8b 75 14             	mov    0x14(%ebp),%esi
	// LAB 4: Your code here.
	// int sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
	int r;
	if (pg == NULL) pg = (void *)UTOP;
  803267:	85 db                	test   %ebx,%ebx
  803269:	75 25                	jne    803290 <ipc_send+0x3b>
  80326b:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
  803270:	eb 1e                	jmp    803290 <ipc_send+0x3b>
	
	while ((r = sys_ipc_try_send(to_env, val, pg, perm)) != 0) {
		if (r == -E_IPC_NOT_RECV) {
  803272:	83 f8 f9             	cmp    $0xfffffff9,%eax
  803275:	75 07                	jne    80327e <ipc_send+0x29>
			// cprintf("Try Again and Again....\n");
			sys_yield();
  803277:	e8 71 e3 ff ff       	call   8015ed <sys_yield>
  80327c:	eb 12                	jmp    803290 <ipc_send+0x3b>
		} else {
			panic("ipc_send error %e\n", r);
  80327e:	50                   	push   %eax
  80327f:	68 80 3e 80 00       	push   $0x803e80
  803284:	6a 43                	push   $0x43
  803286:	68 93 3e 80 00       	push   $0x803e93
  80328b:	e8 90 d7 ff ff       	call   800a20 <_panic>
	// LAB 4: Your code here.
	// int sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
	int r;
	if (pg == NULL) pg = (void *)UTOP;
	
	while ((r = sys_ipc_try_send(to_env, val, pg, perm)) != 0) {
  803290:	56                   	push   %esi
  803291:	53                   	push   %ebx
  803292:	57                   	push   %edi
  803293:	ff 75 08             	pushl  0x8(%ebp)
  803296:	e8 4f e4 ff ff       	call   8016ea <sys_ipc_try_send>
  80329b:	83 c4 10             	add    $0x10,%esp
  80329e:	85 c0                	test   %eax,%eax
  8032a0:	75 d0                	jne    803272 <ipc_send+0x1d>
		} else {
			panic("ipc_send error %e\n", r);
		}
	}
	return;
}
  8032a2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8032a5:	5b                   	pop    %ebx
  8032a6:	5e                   	pop    %esi
  8032a7:	5f                   	pop    %edi
  8032a8:	c9                   	leave  
  8032a9:	c3                   	ret    

008032aa <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  8032aa:	55                   	push   %ebp
  8032ab:	89 e5                	mov    %esp,%ebp
  8032ad:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
		if (envs[i].env_type == type)
  8032b0:	39 0d 50 00 c0 ee    	cmp    %ecx,0xeec00050
  8032b6:	74 1a                	je     8032d2 <ipc_find_env+0x28>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8032b8:	b8 01 00 00 00       	mov    $0x1,%eax
		if (envs[i].env_type == type)
  8032bd:	89 c2                	mov    %eax,%edx
  8032bf:	c1 e2 07             	shl    $0x7,%edx
  8032c2:	8d 94 82 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,4),%edx
  8032c9:	8b 52 50             	mov    0x50(%edx),%edx
  8032cc:	39 ca                	cmp    %ecx,%edx
  8032ce:	75 18                	jne    8032e8 <ipc_find_env+0x3e>
  8032d0:	eb 05                	jmp    8032d7 <ipc_find_env+0x2d>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8032d2:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
			return envs[i].env_id;
  8032d7:	89 c2                	mov    %eax,%edx
  8032d9:	c1 e2 07             	shl    $0x7,%edx
  8032dc:	8d 84 82 08 00 c0 ee 	lea    -0x113ffff8(%edx,%eax,4),%eax
  8032e3:	8b 40 40             	mov    0x40(%eax),%eax
  8032e6:	eb 0c                	jmp    8032f4 <ipc_find_env+0x4a>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8032e8:	40                   	inc    %eax
  8032e9:	3d 00 04 00 00       	cmp    $0x400,%eax
  8032ee:	75 cd                	jne    8032bd <ipc_find_env+0x13>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  8032f0:	66 b8 00 00          	mov    $0x0,%ax
}
  8032f4:	c9                   	leave  
  8032f5:	c3                   	ret    
	...

008032f8 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  8032f8:	55                   	push   %ebp
  8032f9:	89 e5                	mov    %esp,%ebp
  8032fb:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8032fe:	89 c2                	mov    %eax,%edx
  803300:	c1 ea 16             	shr    $0x16,%edx
  803303:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80330a:	f6 c2 01             	test   $0x1,%dl
  80330d:	74 1e                	je     80332d <pageref+0x35>
		return 0;
	pte = uvpt[PGNUM(v)];
  80330f:	c1 e8 0c             	shr    $0xc,%eax
  803312:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  803319:	a8 01                	test   $0x1,%al
  80331b:	74 17                	je     803334 <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  80331d:	c1 e8 0c             	shr    $0xc,%eax
  803320:	66 8b 04 c5 04 00 00 	mov    -0x10fffffc(,%eax,8),%ax
  803327:	ef 
  803328:	0f b7 c0             	movzwl %ax,%eax
  80332b:	eb 0c                	jmp    803339 <pageref+0x41>
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
		return 0;
  80332d:	b8 00 00 00 00       	mov    $0x0,%eax
  803332:	eb 05                	jmp    803339 <pageref+0x41>
	pte = uvpt[PGNUM(v)];
	if (!(pte & PTE_P))
		return 0;
  803334:	b8 00 00 00 00       	mov    $0x0,%eax
	return pages[PGNUM(pte)].pp_ref;
}
  803339:	c9                   	leave  
  80333a:	c3                   	ret    
	...

0080333c <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  80333c:	55                   	push   %ebp
  80333d:	89 e5                	mov    %esp,%ebp
  80333f:	57                   	push   %edi
  803340:	56                   	push   %esi
  803341:	83 ec 10             	sub    $0x10,%esp
  803344:	8b 7d 08             	mov    0x8(%ebp),%edi
  803347:	8b 4d 10             	mov    0x10(%ebp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  80334a:	89 7d f0             	mov    %edi,-0x10(%ebp)
  80334d:	8b 75 0c             	mov    0xc(%ebp),%esi
  const DWunion dd = {.ll = d};
  803350:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  803353:	8b 45 14             	mov    0x14(%ebp),%eax
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  803356:	85 c0                	test   %eax,%eax
  803358:	75 2e                	jne    803388 <__udivdi3+0x4c>
    {
      if (d0 > n1)
  80335a:	39 f1                	cmp    %esi,%ecx
  80335c:	77 5a                	ja     8033b8 <__udivdi3+0x7c>
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  80335e:	85 c9                	test   %ecx,%ecx
  803360:	75 0b                	jne    80336d <__udivdi3+0x31>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  803362:	b8 01 00 00 00       	mov    $0x1,%eax
  803367:	31 d2                	xor    %edx,%edx
  803369:	f7 f1                	div    %ecx
  80336b:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  80336d:	31 d2                	xor    %edx,%edx
  80336f:	89 f0                	mov    %esi,%eax
  803371:	f7 f1                	div    %ecx
  803373:	89 c6                	mov    %eax,%esi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  803375:	89 f8                	mov    %edi,%eax
  803377:	f7 f1                	div    %ecx
  803379:	89 c7                	mov    %eax,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  80337b:	89 f8                	mov    %edi,%eax
  80337d:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  80337f:	83 c4 10             	add    $0x10,%esp
  803382:	5e                   	pop    %esi
  803383:	5f                   	pop    %edi
  803384:	c9                   	leave  
  803385:	c3                   	ret    
  803386:	66 90                	xchg   %ax,%ax
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  803388:	39 f0                	cmp    %esi,%eax
  80338a:	77 1c                	ja     8033a8 <__udivdi3+0x6c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  80338c:	0f bd f8             	bsr    %eax,%edi
	  if (bm == 0)
  80338f:	83 f7 1f             	xor    $0x1f,%edi
  803392:	75 3c                	jne    8033d0 <__udivdi3+0x94>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  803394:	39 f0                	cmp    %esi,%eax
  803396:	0f 82 90 00 00 00    	jb     80342c <__udivdi3+0xf0>
  80339c:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80339f:	39 55 f4             	cmp    %edx,-0xc(%ebp)
  8033a2:	0f 86 84 00 00 00    	jbe    80342c <__udivdi3+0xf0>
  8033a8:	31 f6                	xor    %esi,%esi
  8033aa:	31 ff                	xor    %edi,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  8033ac:	89 f8                	mov    %edi,%eax
  8033ae:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  8033b0:	83 c4 10             	add    $0x10,%esp
  8033b3:	5e                   	pop    %esi
  8033b4:	5f                   	pop    %edi
  8033b5:	c9                   	leave  
  8033b6:	c3                   	ret    
  8033b7:	90                   	nop
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  8033b8:	89 f2                	mov    %esi,%edx
  8033ba:	89 f8                	mov    %edi,%eax
  8033bc:	f7 f1                	div    %ecx
  8033be:	89 c7                	mov    %eax,%edi
  8033c0:	31 f6                	xor    %esi,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  8033c2:	89 f8                	mov    %edi,%eax
  8033c4:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  8033c6:	83 c4 10             	add    $0x10,%esp
  8033c9:	5e                   	pop    %esi
  8033ca:	5f                   	pop    %edi
  8033cb:	c9                   	leave  
  8033cc:	c3                   	ret    
  8033cd:	8d 76 00             	lea    0x0(%esi),%esi
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  8033d0:	89 f9                	mov    %edi,%ecx
  8033d2:	d3 e0                	shl    %cl,%eax
  8033d4:	89 45 e8             	mov    %eax,-0x18(%ebp)
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  8033d7:	b8 20 00 00 00       	mov    $0x20,%eax
  8033dc:	29 f8                	sub    %edi,%eax

	      d1 = (d1 << bm) | (d0 >> b);
  8033de:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8033e1:	88 c1                	mov    %al,%cl
  8033e3:	d3 ea                	shr    %cl,%edx
  8033e5:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  8033e8:	09 ca                	or     %ecx,%edx
  8033ea:	89 55 ec             	mov    %edx,-0x14(%ebp)
	      d0 = d0 << bm;
  8033ed:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8033f0:	89 f9                	mov    %edi,%ecx
  8033f2:	d3 e2                	shl    %cl,%edx
  8033f4:	89 55 f4             	mov    %edx,-0xc(%ebp)
	      n2 = n1 >> b;
  8033f7:	89 f2                	mov    %esi,%edx
  8033f9:	88 c1                	mov    %al,%cl
  8033fb:	d3 ea                	shr    %cl,%edx
  8033fd:	89 55 e8             	mov    %edx,-0x18(%ebp)
	      n1 = (n1 << bm) | (n0 >> b);
  803400:	89 f2                	mov    %esi,%edx
  803402:	89 f9                	mov    %edi,%ecx
  803404:	d3 e2                	shl    %cl,%edx
  803406:	8b 75 f0             	mov    -0x10(%ebp),%esi
  803409:	88 c1                	mov    %al,%cl
  80340b:	d3 ee                	shr    %cl,%esi
  80340d:	09 d6                	or     %edx,%esi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  80340f:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  803412:	89 f0                	mov    %esi,%eax
  803414:	89 ca                	mov    %ecx,%edx
  803416:	f7 75 ec             	divl   -0x14(%ebp)
  803419:	89 d1                	mov    %edx,%ecx
  80341b:	89 c6                	mov    %eax,%esi
	      umul_ppmm (m1, m0, q0, d0);
  80341d:	f7 65 f4             	mull   -0xc(%ebp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  803420:	39 d1                	cmp    %edx,%ecx
  803422:	72 28                	jb     80344c <__udivdi3+0x110>
  803424:	74 1a                	je     803440 <__udivdi3+0x104>
  803426:	89 f7                	mov    %esi,%edi
  803428:	31 f6                	xor    %esi,%esi
  80342a:	eb 80                	jmp    8033ac <__udivdi3+0x70>
	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  80342c:	31 f6                	xor    %esi,%esi
  80342e:	bf 01 00 00 00       	mov    $0x1,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  803433:	89 f8                	mov    %edi,%eax
  803435:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  803437:	83 c4 10             	add    $0x10,%esp
  80343a:	5e                   	pop    %esi
  80343b:	5f                   	pop    %edi
  80343c:	c9                   	leave  
  80343d:	c3                   	ret    
  80343e:	66 90                	xchg   %ax,%ax

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  803440:	8b 55 f0             	mov    -0x10(%ebp),%edx
  803443:	89 f9                	mov    %edi,%ecx
  803445:	d3 e2                	shl    %cl,%edx

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  803447:	39 c2                	cmp    %eax,%edx
  803449:	73 db                	jae    803426 <__udivdi3+0xea>
  80344b:	90                   	nop
		{
		  q0--;
  80344c:	8d 7e ff             	lea    -0x1(%esi),%edi
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  80344f:	31 f6                	xor    %esi,%esi
  803451:	e9 56 ff ff ff       	jmp    8033ac <__udivdi3+0x70>
	...

00803458 <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  803458:	55                   	push   %ebp
  803459:	89 e5                	mov    %esp,%ebp
  80345b:	57                   	push   %edi
  80345c:	56                   	push   %esi
  80345d:	83 ec 20             	sub    $0x20,%esp
  803460:	8b 45 08             	mov    0x8(%ebp),%eax
  803463:	8b 4d 10             	mov    0x10(%ebp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  803466:	89 45 e8             	mov    %eax,-0x18(%ebp)
  803469:	8b 75 0c             	mov    0xc(%ebp),%esi
  const DWunion dd = {.ll = d};
  80346c:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  80346f:	8b 7d 14             	mov    0x14(%ebp),%edi
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  803472:	89 45 f0             	mov    %eax,-0x10(%ebp)
  n1 = nn.s.high;
  803475:	89 f2                	mov    %esi,%edx

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  803477:	85 ff                	test   %edi,%edi
  803479:	75 15                	jne    803490 <__umoddi3+0x38>
    {
      if (d0 > n1)
  80347b:	39 f1                	cmp    %esi,%ecx
  80347d:	0f 86 99 00 00 00    	jbe    80351c <__umoddi3+0xc4>
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  803483:	f7 f1                	div    %ecx

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
  803485:	89 d0                	mov    %edx,%eax
  803487:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  803489:	83 c4 20             	add    $0x20,%esp
  80348c:	5e                   	pop    %esi
  80348d:	5f                   	pop    %edi
  80348e:	c9                   	leave  
  80348f:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  803490:	39 f7                	cmp    %esi,%edi
  803492:	0f 87 a4 00 00 00    	ja     80353c <__umoddi3+0xe4>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  803498:	0f bd c7             	bsr    %edi,%eax
	  if (bm == 0)
  80349b:	83 f0 1f             	xor    $0x1f,%eax
  80349e:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8034a1:	0f 84 a1 00 00 00    	je     803548 <__umoddi3+0xf0>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  8034a7:	89 f8                	mov    %edi,%eax
  8034a9:	8a 4d ec             	mov    -0x14(%ebp),%cl
  8034ac:	d3 e0                	shl    %cl,%eax
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  8034ae:	bf 20 00 00 00       	mov    $0x20,%edi
  8034b3:	2b 7d ec             	sub    -0x14(%ebp),%edi

	      d1 = (d1 << bm) | (d0 >> b);
  8034b6:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8034b9:	89 f9                	mov    %edi,%ecx
  8034bb:	d3 ea                	shr    %cl,%edx
  8034bd:	09 c2                	or     %eax,%edx
  8034bf:	89 55 f0             	mov    %edx,-0x10(%ebp)
	      d0 = d0 << bm;
  8034c2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8034c5:	8a 4d ec             	mov    -0x14(%ebp),%cl
  8034c8:	d3 e0                	shl    %cl,%eax
  8034ca:	89 45 f4             	mov    %eax,-0xc(%ebp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  8034cd:	89 f2                	mov    %esi,%edx
  8034cf:	d3 e2                	shl    %cl,%edx
	      n0 = n0 << bm;
  8034d1:	8b 45 e8             	mov    -0x18(%ebp),%eax
  8034d4:	d3 e0                	shl    %cl,%eax
  8034d6:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  8034d9:	8b 45 e8             	mov    -0x18(%ebp),%eax
  8034dc:	89 f9                	mov    %edi,%ecx
  8034de:	d3 e8                	shr    %cl,%eax
  8034e0:	09 d0                	or     %edx,%eax

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  8034e2:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  8034e4:	89 f2                	mov    %esi,%edx
  8034e6:	f7 75 f0             	divl   -0x10(%ebp)
  8034e9:	89 d6                	mov    %edx,%esi
	      umul_ppmm (m1, m0, q0, d0);
  8034eb:	f7 65 f4             	mull   -0xc(%ebp)
  8034ee:	89 55 e8             	mov    %edx,-0x18(%ebp)
  8034f1:	89 c1                	mov    %eax,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  8034f3:	39 d6                	cmp    %edx,%esi
  8034f5:	72 71                	jb     803568 <__umoddi3+0x110>
  8034f7:	74 7f                	je     803578 <__umoddi3+0x120>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  8034f9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8034fc:	29 c8                	sub    %ecx,%eax
  8034fe:	19 d6                	sbb    %edx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
  803500:	8a 4d ec             	mov    -0x14(%ebp),%cl
  803503:	d3 e8                	shr    %cl,%eax
  803505:	89 f2                	mov    %esi,%edx
  803507:	89 f9                	mov    %edi,%ecx
  803509:	d3 e2                	shl    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
  80350b:	09 d0                	or     %edx,%eax
  80350d:	89 f2                	mov    %esi,%edx
  80350f:	8a 4d ec             	mov    -0x14(%ebp),%cl
  803512:	d3 ea                	shr    %cl,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  803514:	83 c4 20             	add    $0x20,%esp
  803517:	5e                   	pop    %esi
  803518:	5f                   	pop    %edi
  803519:	c9                   	leave  
  80351a:	c3                   	ret    
  80351b:	90                   	nop
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  80351c:	85 c9                	test   %ecx,%ecx
  80351e:	75 0b                	jne    80352b <__umoddi3+0xd3>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  803520:	b8 01 00 00 00       	mov    $0x1,%eax
  803525:	31 d2                	xor    %edx,%edx
  803527:	f7 f1                	div    %ecx
  803529:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  80352b:	89 f0                	mov    %esi,%eax
  80352d:	31 d2                	xor    %edx,%edx
  80352f:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  803531:	8b 45 f0             	mov    -0x10(%ebp),%eax
  803534:	f7 f1                	div    %ecx
  803536:	e9 4a ff ff ff       	jmp    803485 <__umoddi3+0x2d>
  80353b:	90                   	nop
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
  80353c:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  80353e:	83 c4 20             	add    $0x20,%esp
  803541:	5e                   	pop    %esi
  803542:	5f                   	pop    %edi
  803543:	c9                   	leave  
  803544:	c3                   	ret    
  803545:	8d 76 00             	lea    0x0(%esi),%esi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  803548:	39 f7                	cmp    %esi,%edi
  80354a:	72 05                	jb     803551 <__umoddi3+0xf9>
  80354c:	3b 4d f0             	cmp    -0x10(%ebp),%ecx
  80354f:	77 0c                	ja     80355d <__umoddi3+0x105>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  803551:	89 f2                	mov    %esi,%edx
  803553:	8b 45 f0             	mov    -0x10(%ebp),%eax
  803556:	29 c8                	sub    %ecx,%eax
  803558:	19 fa                	sbb    %edi,%edx
  80355a:	89 45 f0             	mov    %eax,-0x10(%ebp)

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
  80355d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  803560:	83 c4 20             	add    $0x20,%esp
  803563:	5e                   	pop    %esi
  803564:	5f                   	pop    %edi
  803565:	c9                   	leave  
  803566:	c3                   	ret    
  803567:	90                   	nop
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  803568:	8b 55 e8             	mov    -0x18(%ebp),%edx
  80356b:	89 c1                	mov    %eax,%ecx
  80356d:	2b 4d f4             	sub    -0xc(%ebp),%ecx
  803570:	1b 55 f0             	sbb    -0x10(%ebp),%edx
  803573:	eb 84                	jmp    8034f9 <__umoddi3+0xa1>
  803575:	8d 76 00             	lea    0x0(%esi),%esi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  803578:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  80357b:	72 eb                	jb     803568 <__umoddi3+0x110>
  80357d:	89 f2                	mov    %esi,%edx
  80357f:	e9 75 ff ff ff       	jmp    8034f9 <__umoddi3+0xa1>
