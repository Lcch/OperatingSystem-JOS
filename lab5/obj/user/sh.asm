
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
  800057:	68 20 33 80 00       	push   $0x803320
  80005c:	e8 9b 0a 00 00       	call   800afc <cprintf>
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
  800076:	68 2f 33 80 00       	push   $0x80332f
  80007b:	e8 7c 0a 00 00       	call   800afc <cprintf>
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
  80009f:	68 3d 33 80 00       	push   $0x80333d
  8000a4:	e8 14 12 00 00       	call   8012bd <strchr>
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
  8000c8:	68 42 33 80 00       	push   $0x803342
  8000cd:	e8 2a 0a 00 00       	call   800afc <cprintf>
  8000d2:	83 c4 10             	add    $0x10,%esp
		return 0;
  8000d5:	bb 00 00 00 00       	mov    $0x0,%ebx
  8000da:	e9 b8 00 00 00       	jmp    800197 <_gettoken+0x163>
	}
	if (strchr(SYMBOLS, *s)) {
  8000df:	83 ec 08             	sub    $0x8,%esp
  8000e2:	0f be c0             	movsbl %al,%eax
  8000e5:	50                   	push   %eax
  8000e6:	68 53 33 80 00       	push   $0x803353
  8000eb:	e8 cd 11 00 00       	call   8012bd <strchr>
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
  800116:	68 47 33 80 00       	push   $0x803347
  80011b:	e8 dc 09 00 00       	call   800afc <cprintf>
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
  80013d:	68 4f 33 80 00       	push   $0x80334f
  800142:	e8 76 11 00 00       	call   8012bd <strchr>
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
  800167:	68 5b 33 80 00       	push   $0x80335b
  80016c:	e8 8b 09 00 00       	call   800afc <cprintf>
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
  800276:	68 65 33 80 00       	push   $0x803365
  80027b:	e8 7c 08 00 00       	call   800afc <cprintf>
				exit();
  800280:	e8 83 07 00 00       	call   800a08 <exit>
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
  8002a8:	68 b8 34 80 00       	push   $0x8034b8
  8002ad:	e8 4a 08 00 00       	call   800afc <cprintf>
				exit();
  8002b2:	e8 51 07 00 00       	call   800a08 <exit>
  8002b7:	83 c4 10             	add    $0x10,%esp
			}
			if ((fd = open(t, O_RDONLY)) < 0) {
  8002ba:	83 ec 08             	sub    $0x8,%esp
  8002bd:	6a 00                	push   $0x0
  8002bf:	ff 75 a4             	pushl  -0x5c(%ebp)
  8002c2:	e8 29 20 00 00       	call   8022f0 <open>
  8002c7:	89 c3                	mov    %eax,%ebx
  8002c9:	83 c4 10             	add    $0x10,%esp
  8002cc:	85 c0                	test   %eax,%eax
  8002ce:	79 1b                	jns    8002eb <runcmd+0xdf>
				cprintf("open %s for read: %e", t, fd);
  8002d0:	83 ec 04             	sub    $0x4,%esp
  8002d3:	50                   	push   %eax
  8002d4:	ff 75 a4             	pushl  -0x5c(%ebp)
  8002d7:	68 79 33 80 00       	push   $0x803379
  8002dc:	e8 1b 08 00 00       	call   800afc <cprintf>
				exit();
  8002e1:	e8 22 07 00 00       	call   800a08 <exit>
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
  8002f9:	e8 ff 1a 00 00       	call   801dfd <dup>
				close(fd);
  8002fe:	89 1c 24             	mov    %ebx,(%esp)
  800301:	e8 a9 1a 00 00       	call   801daf <close>
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
  800324:	68 e0 34 80 00       	push   $0x8034e0
  800329:	e8 ce 07 00 00       	call   800afc <cprintf>
				exit();
  80032e:	e8 d5 06 00 00       	call   800a08 <exit>
  800333:	83 c4 10             	add    $0x10,%esp
			}
			if ((fd = open(t, O_WRONLY|O_CREAT|O_TRUNC)) < 0) {
  800336:	83 ec 08             	sub    $0x8,%esp
  800339:	68 01 03 00 00       	push   $0x301
  80033e:	ff 75 a4             	pushl  -0x5c(%ebp)
  800341:	e8 aa 1f 00 00       	call   8022f0 <open>
  800346:	89 c3                	mov    %eax,%ebx
  800348:	83 c4 10             	add    $0x10,%esp
  80034b:	85 c0                	test   %eax,%eax
  80034d:	79 19                	jns    800368 <runcmd+0x15c>
				cprintf("open %s for write: %e", t, fd);
  80034f:	83 ec 04             	sub    $0x4,%esp
  800352:	50                   	push   %eax
  800353:	ff 75 a4             	pushl  -0x5c(%ebp)
  800356:	68 8e 33 80 00       	push   $0x80338e
  80035b:	e8 9c 07 00 00       	call   800afc <cprintf>
				exit();
  800360:	e8 a3 06 00 00       	call   800a08 <exit>
  800365:	83 c4 10             	add    $0x10,%esp
			}
			if (fd != 1) {
  800368:	83 fb 01             	cmp    $0x1,%ebx
  80036b:	0f 84 bc fe ff ff    	je     80022d <runcmd+0x21>
				dup(fd, 1);
  800371:	83 ec 08             	sub    $0x8,%esp
  800374:	6a 01                	push   $0x1
  800376:	53                   	push   %ebx
  800377:	e8 81 1a 00 00       	call   801dfd <dup>
				close(fd);
  80037c:	89 1c 24             	mov    %ebx,(%esp)
  80037f:	e8 2b 1a 00 00       	call   801daf <close>
  800384:	83 c4 10             	add    $0x10,%esp
  800387:	e9 a1 fe ff ff       	jmp    80022d <runcmd+0x21>
			}
			break;

		case '|':	// Pipe
			if ((r = pipe(p)) < 0) {
  80038c:	83 ec 0c             	sub    $0xc,%esp
  80038f:	8d 85 9c fb ff ff    	lea    -0x464(%ebp),%eax
  800395:	50                   	push   %eax
  800396:	e8 1f 29 00 00       	call   802cba <pipe>
  80039b:	83 c4 10             	add    $0x10,%esp
  80039e:	85 c0                	test   %eax,%eax
  8003a0:	79 16                	jns    8003b8 <runcmd+0x1ac>
				cprintf("pipe: %e", r);
  8003a2:	83 ec 08             	sub    $0x8,%esp
  8003a5:	50                   	push   %eax
  8003a6:	68 a4 33 80 00       	push   $0x8033a4
  8003ab:	e8 4c 07 00 00       	call   800afc <cprintf>
				exit();
  8003b0:	e8 53 06 00 00       	call   800a08 <exit>
  8003b5:	83 c4 10             	add    $0x10,%esp
			}
			if (debug)
  8003b8:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  8003bf:	74 1c                	je     8003dd <runcmd+0x1d1>
				cprintf("PIPE: %d %d\n", p[0], p[1]);
  8003c1:	83 ec 04             	sub    $0x4,%esp
  8003c4:	ff b5 a0 fb ff ff    	pushl  -0x460(%ebp)
  8003ca:	ff b5 9c fb ff ff    	pushl  -0x464(%ebp)
  8003d0:	68 ad 33 80 00       	push   $0x8033ad
  8003d5:	e8 22 07 00 00       	call   800afc <cprintf>
  8003da:	83 c4 10             	add    $0x10,%esp
			if ((r = fork()) < 0) {
  8003dd:	e8 48 14 00 00       	call   80182a <fork>
  8003e2:	89 c3                	mov    %eax,%ebx
  8003e4:	85 c0                	test   %eax,%eax
  8003e6:	79 16                	jns    8003fe <runcmd+0x1f2>
				cprintf("fork: %e", r);
  8003e8:	83 ec 08             	sub    $0x8,%esp
  8003eb:	50                   	push   %eax
  8003ec:	68 ba 33 80 00       	push   $0x8033ba
  8003f1:	e8 06 07 00 00       	call   800afc <cprintf>
				exit();
  8003f6:	e8 0d 06 00 00       	call   800a08 <exit>
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
  800412:	e8 e6 19 00 00       	call   801dfd <dup>
					close(p[0]);
  800417:	83 c4 04             	add    $0x4,%esp
  80041a:	ff b5 9c fb ff ff    	pushl  -0x464(%ebp)
  800420:	e8 8a 19 00 00       	call   801daf <close>
  800425:	83 c4 10             	add    $0x10,%esp
				}
				close(p[1]);
  800428:	83 ec 0c             	sub    $0xc,%esp
  80042b:	ff b5 a0 fb ff ff    	pushl  -0x460(%ebp)
  800431:	e8 79 19 00 00       	call   801daf <close>
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
  800454:	e8 a4 19 00 00       	call   801dfd <dup>
					close(p[1]);
  800459:	83 c4 04             	add    $0x4,%esp
  80045c:	ff b5 a0 fb ff ff    	pushl  -0x460(%ebp)
  800462:	e8 48 19 00 00       	call   801daf <close>
  800467:	83 c4 10             	add    $0x10,%esp
				}
				close(p[0]);
  80046a:	83 ec 0c             	sub    $0xc,%esp
  80046d:	ff b5 9c fb ff ff    	pushl  -0x464(%ebp)
  800473:	e8 37 19 00 00       	call   801daf <close>
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
  800480:	68 c3 33 80 00       	push   $0x8033c3
  800485:	6a 6e                	push   $0x6e
  800487:	68 df 33 80 00       	push   $0x8033df
  80048c:	e8 93 05 00 00       	call   800a24 <_panic>
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
  8004aa:	68 e9 33 80 00       	push   $0x8033e9
  8004af:	e8 48 06 00 00       	call   800afc <cprintf>
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
  8004dc:	e8 b5 0c 00 00       	call   801196 <strcpy>
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
  800504:	68 f8 33 80 00       	push   $0x8033f8
  800509:	e8 ee 05 00 00       	call   800afc <cprintf>
		for (i = 0; argv[i]; i++)
  80050e:	8b 45 a8             	mov    -0x58(%ebp),%eax
  800511:	83 c4 10             	add    $0x10,%esp
  800514:	85 c0                	test   %eax,%eax
  800516:	74 1d                	je     800535 <runcmd+0x329>
  800518:	8d 5d ac             	lea    -0x54(%ebp),%ebx
			cprintf(" %s", argv[i]);
  80051b:	83 ec 08             	sub    $0x8,%esp
  80051e:	50                   	push   %eax
  80051f:	68 83 34 80 00       	push   $0x803483
  800524:	e8 d3 05 00 00       	call   800afc <cprintf>
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
  800538:	68 40 33 80 00       	push   $0x803340
  80053d:	e8 ba 05 00 00       	call   800afc <cprintf>
  800542:	83 c4 10             	add    $0x10,%esp
	}

	// Spawn the command!
	if ((r = spawn(argv[0], (const char**) argv)) < 0)
  800545:	83 ec 08             	sub    $0x8,%esp
  800548:	8d 45 a8             	lea    -0x58(%ebp),%eax
  80054b:	50                   	push   %eax
  80054c:	ff 75 a8             	pushl  -0x58(%ebp)
  80054f:	e8 40 1f 00 00       	call   802494 <spawn>
  800554:	89 c3                	mov    %eax,%ebx
  800556:	83 c4 10             	add    $0x10,%esp
  800559:	85 c0                	test   %eax,%eax
  80055b:	79 1b                	jns    800578 <runcmd+0x36c>
		cprintf("spawn %s: %e\n", argv[0], r);
  80055d:	83 ec 04             	sub    $0x4,%esp
  800560:	50                   	push   %eax
  800561:	ff 75 a8             	pushl  -0x58(%ebp)
  800564:	68 06 34 80 00       	push   $0x803406
  800569:	e8 8e 05 00 00       	call   800afc <cprintf>

	// In the parent, close all file descriptors and wait for the
	// spawned command to exit.
	close_all();
  80056e:	e8 67 18 00 00       	call   801dda <close_all>
  800573:	83 c4 10             	add    $0x10,%esp
  800576:	eb 56                	jmp    8005ce <runcmd+0x3c2>
  800578:	e8 5d 18 00 00       	call   801dda <close_all>
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
  800593:	68 14 34 80 00       	push   $0x803414
  800598:	e8 5f 05 00 00       	call   800afc <cprintf>
  80059d:	83 c4 10             	add    $0x10,%esp
		wait(r);
  8005a0:	83 ec 0c             	sub    $0xc,%esp
  8005a3:	53                   	push   %ebx
  8005a4:	e8 97 28 00 00       	call   802e40 <wait>
		if (debug)
  8005a9:	83 c4 10             	add    $0x10,%esp
  8005ac:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  8005b3:	74 19                	je     8005ce <runcmd+0x3c2>
			cprintf("[%08x] wait finished\n", thisenv->env_id);
  8005b5:	a1 24 54 80 00       	mov    0x805424,%eax
  8005ba:	8b 40 48             	mov    0x48(%eax),%eax
  8005bd:	83 ec 08             	sub    $0x8,%esp
  8005c0:	50                   	push   %eax
  8005c1:	68 29 34 80 00       	push   $0x803429
  8005c6:	e8 31 05 00 00       	call   800afc <cprintf>
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
  8005e8:	68 3f 34 80 00       	push   $0x80343f
  8005ed:	e8 0a 05 00 00       	call   800afc <cprintf>
  8005f2:	83 c4 10             	add    $0x10,%esp
		wait(pipe_child);
  8005f5:	83 ec 0c             	sub    $0xc,%esp
  8005f8:	56                   	push   %esi
  8005f9:	e8 42 28 00 00       	call   802e40 <wait>
		if (debug)
  8005fe:	83 c4 10             	add    $0x10,%esp
  800601:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  800608:	74 19                	je     800623 <runcmd+0x417>
			cprintf("[%08x] wait finished\n", thisenv->env_id);
  80060a:	a1 24 54 80 00       	mov    0x805424,%eax
  80060f:	8b 40 48             	mov    0x48(%eax),%eax
  800612:	83 ec 08             	sub    $0x8,%esp
  800615:	50                   	push   %eax
  800616:	68 29 34 80 00       	push   $0x803429
  80061b:	e8 dc 04 00 00       	call   800afc <cprintf>
  800620:	83 c4 10             	add    $0x10,%esp
	}

	// Done!
	exit();
  800623:	e8 e0 03 00 00       	call   800a08 <exit>
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
  800636:	68 08 35 80 00       	push   $0x803508
  80063b:	e8 bc 04 00 00       	call   800afc <cprintf>
	exit();
  800640:	e8 c3 03 00 00       	call   800a08 <exit>
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
  80065f:	e8 10 14 00 00       	call   801a74 <argstart>
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
  8006aa:	e8 fe 13 00 00       	call   801aad <argnext>
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
  8006ce:	e8 dc 16 00 00       	call   801daf <close>
		if ((r = open(argv[1], O_RDONLY)) < 0)
  8006d3:	83 c4 08             	add    $0x8,%esp
  8006d6:	6a 00                	push   $0x0
  8006d8:	ff 76 04             	pushl  0x4(%esi)
  8006db:	e8 10 1c 00 00       	call   8022f0 <open>
  8006e0:	83 c4 10             	add    $0x10,%esp
  8006e3:	85 c0                	test   %eax,%eax
  8006e5:	79 1b                	jns    800702 <umain+0xb8>
			panic("open %s: %e", argv[1], r);
  8006e7:	83 ec 0c             	sub    $0xc,%esp
  8006ea:	50                   	push   %eax
  8006eb:	ff 76 04             	pushl  0x4(%esi)
  8006ee:	68 5f 34 80 00       	push   $0x80345f
  8006f3:	68 1e 01 00 00       	push   $0x11e
  8006f8:	68 df 33 80 00       	push   $0x8033df
  8006fd:	e8 22 03 00 00       	call   800a24 <_panic>
		assert(r == 0);
  800702:	85 c0                	test   %eax,%eax
  800704:	74 19                	je     80071f <umain+0xd5>
  800706:	68 6b 34 80 00       	push   $0x80346b
  80070b:	68 72 34 80 00       	push   $0x803472
  800710:	68 1f 01 00 00       	push   $0x11f
  800715:	68 df 33 80 00       	push   $0x8033df
  80071a:	e8 05 03 00 00       	call   800a24 <_panic>
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
  800737:	b8 5c 34 80 00       	mov    $0x80345c,%eax
  80073c:	eb 05                	jmp    800743 <umain+0xf9>
  80073e:	b8 00 00 00 00       	mov    $0x0,%eax
  800743:	83 ec 0c             	sub    $0xc,%esp
  800746:	50                   	push   %eax
  800747:	e8 14 09 00 00       	call   801060 <readline>
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
  800761:	68 87 34 80 00       	push   $0x803487
  800766:	e8 91 03 00 00       	call   800afc <cprintf>
  80076b:	83 c4 10             	add    $0x10,%esp
			exit();	// end of file
  80076e:	e8 95 02 00 00       	call   800a08 <exit>
		}
		if (debug)
  800773:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  80077a:	74 11                	je     80078d <umain+0x143>
			cprintf("LINE: %s\n", buf);
  80077c:	83 ec 08             	sub    $0x8,%esp
  80077f:	56                   	push   %esi
  800780:	68 90 34 80 00       	push   $0x803490
  800785:	e8 72 03 00 00       	call   800afc <cprintf>
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
  80079c:	68 9a 34 80 00       	push   $0x80349a
  8007a1:	e8 d6 1c 00 00       	call   80247c <printf>
  8007a6:	83 c4 10             	add    $0x10,%esp
		if (debug)
  8007a9:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  8007b0:	74 10                	je     8007c2 <umain+0x178>
			cprintf("BEFORE FORK\n");
  8007b2:	83 ec 0c             	sub    $0xc,%esp
  8007b5:	68 a0 34 80 00       	push   $0x8034a0
  8007ba:	e8 3d 03 00 00       	call   800afc <cprintf>
  8007bf:	83 c4 10             	add    $0x10,%esp
		if ((r = fork()) < 0)
  8007c2:	e8 63 10 00 00       	call   80182a <fork>
  8007c7:	89 c3                	mov    %eax,%ebx
  8007c9:	85 c0                	test   %eax,%eax
  8007cb:	79 15                	jns    8007e2 <umain+0x198>
			panic("fork: %e", r);
  8007cd:	50                   	push   %eax
  8007ce:	68 ba 33 80 00       	push   $0x8033ba
  8007d3:	68 36 01 00 00       	push   $0x136
  8007d8:	68 df 33 80 00       	push   $0x8033df
  8007dd:	e8 42 02 00 00       	call   800a24 <_panic>
		if (debug)
  8007e2:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  8007e9:	74 11                	je     8007fc <umain+0x1b2>
			cprintf("FORK: %d\n", r);
  8007eb:	83 ec 08             	sub    $0x8,%esp
  8007ee:	50                   	push   %eax
  8007ef:	68 ad 34 80 00       	push   $0x8034ad
  8007f4:	e8 03 03 00 00       	call   800afc <cprintf>
  8007f9:	83 c4 10             	add    $0x10,%esp
		if (r == 0) {
  8007fc:	85 db                	test   %ebx,%ebx
  8007fe:	75 16                	jne    800816 <umain+0x1cc>
			runcmd(buf);
  800800:	83 ec 0c             	sub    $0xc,%esp
  800803:	56                   	push   %esi
  800804:	e8 03 fa ff ff       	call   80020c <runcmd>
			exit();
  800809:	e8 fa 01 00 00       	call   800a08 <exit>
  80080e:	83 c4 10             	add    $0x10,%esp
  800811:	e9 1d ff ff ff       	jmp    800733 <umain+0xe9>
		} else
			wait(r);
  800816:	83 ec 0c             	sub    $0xc,%esp
  800819:	53                   	push   %ebx
  80081a:	e8 21 26 00 00       	call   802e40 <wait>
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
  800838:	68 29 35 80 00       	push   $0x803529
  80083d:	ff 75 0c             	pushl  0xc(%ebp)
  800840:	e8 51 09 00 00       	call   801196 <strcpy>
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
  800886:	e8 cc 0a 00 00       	call   801357 <memmove>
		sys_cputs(buf, m);
  80088b:	83 c4 08             	add    $0x8,%esp
  80088e:	53                   	push   %ebx
  80088f:	57                   	push   %edi
  800890:	e8 cc 0c 00 00       	call   801561 <sys_cputs>
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
  8008c0:	e8 2c 0d 00 00       	call   8015f1 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  8008c5:	e8 bd 0c 00 00       	call   801587 <sys_cgetc>
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
  800905:	e8 57 0c 00 00       	call   801561 <sys_cputs>
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
  80091d:	e8 ca 15 00 00       	call   801eec <read>
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
  800947:	e8 1f 13 00 00       	call   801c6b <fd_lookup>
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
  800970:	e8 83 12 00 00       	call   801bf8 <fd_alloc>
  800975:	83 c4 10             	add    $0x10,%esp
  800978:	85 c0                	test   %eax,%eax
  80097a:	78 3a                	js     8009b6 <opencons+0x50>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  80097c:	83 ec 04             	sub    $0x4,%esp
  80097f:	68 07 04 00 00       	push   $0x407
  800984:	ff 75 f4             	pushl  -0xc(%ebp)
  800987:	6a 00                	push   $0x0
  800989:	e8 8a 0c 00 00       	call   801618 <sys_page_alloc>
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
  8009ae:	e8 1d 12 00 00       	call   801bd0 <fd2num>
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
  8009c3:	e8 05 0c 00 00       	call   8015cd <sys_getenvid>
  8009c8:	25 ff 03 00 00       	and    $0x3ff,%eax
  8009cd:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  8009d4:	c1 e0 07             	shl    $0x7,%eax
  8009d7:	29 d0                	sub    %edx,%eax
  8009d9:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8009de:	a3 24 54 80 00       	mov    %eax,0x805424

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8009e3:	85 f6                	test   %esi,%esi
  8009e5:	7e 07                	jle    8009ee <libmain+0x36>
		binaryname = argv[0];
  8009e7:	8b 03                	mov    (%ebx),%eax
  8009e9:	a3 1c 40 80 00       	mov    %eax,0x80401c
	// call user main routine
	umain(argc, argv);
  8009ee:	83 ec 08             	sub    $0x8,%esp
  8009f1:	53                   	push   %ebx
  8009f2:	56                   	push   %esi
  8009f3:	e8 52 fc ff ff       	call   80064a <umain>

	// exit gracefully
	exit();
  8009f8:	e8 0b 00 00 00       	call   800a08 <exit>
  8009fd:	83 c4 10             	add    $0x10,%esp
}
  800a00:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800a03:	5b                   	pop    %ebx
  800a04:	5e                   	pop    %esi
  800a05:	c9                   	leave  
  800a06:	c3                   	ret    
	...

00800a08 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800a08:	55                   	push   %ebp
  800a09:	89 e5                	mov    %esp,%ebp
  800a0b:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800a0e:	e8 c7 13 00 00       	call   801dda <close_all>
	sys_env_destroy(0);
  800a13:	83 ec 0c             	sub    $0xc,%esp
  800a16:	6a 00                	push   $0x0
  800a18:	e8 8e 0b 00 00       	call   8015ab <sys_env_destroy>
  800a1d:	83 c4 10             	add    $0x10,%esp
}
  800a20:	c9                   	leave  
  800a21:	c3                   	ret    
	...

00800a24 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800a24:	55                   	push   %ebp
  800a25:	89 e5                	mov    %esp,%ebp
  800a27:	56                   	push   %esi
  800a28:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800a29:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800a2c:	8b 1d 1c 40 80 00    	mov    0x80401c,%ebx
  800a32:	e8 96 0b 00 00       	call   8015cd <sys_getenvid>
  800a37:	83 ec 0c             	sub    $0xc,%esp
  800a3a:	ff 75 0c             	pushl  0xc(%ebp)
  800a3d:	ff 75 08             	pushl  0x8(%ebp)
  800a40:	53                   	push   %ebx
  800a41:	50                   	push   %eax
  800a42:	68 40 35 80 00       	push   $0x803540
  800a47:	e8 b0 00 00 00       	call   800afc <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800a4c:	83 c4 18             	add    $0x18,%esp
  800a4f:	56                   	push   %esi
  800a50:	ff 75 10             	pushl  0x10(%ebp)
  800a53:	e8 53 00 00 00       	call   800aab <vcprintf>
	cprintf("\n");
  800a58:	c7 04 24 40 33 80 00 	movl   $0x803340,(%esp)
  800a5f:	e8 98 00 00 00       	call   800afc <cprintf>
  800a64:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800a67:	cc                   	int3   
  800a68:	eb fd                	jmp    800a67 <_panic+0x43>
	...

00800a6c <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800a6c:	55                   	push   %ebp
  800a6d:	89 e5                	mov    %esp,%ebp
  800a6f:	53                   	push   %ebx
  800a70:	83 ec 04             	sub    $0x4,%esp
  800a73:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800a76:	8b 03                	mov    (%ebx),%eax
  800a78:	8b 55 08             	mov    0x8(%ebp),%edx
  800a7b:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  800a7f:	40                   	inc    %eax
  800a80:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  800a82:	3d ff 00 00 00       	cmp    $0xff,%eax
  800a87:	75 1a                	jne    800aa3 <putch+0x37>
		sys_cputs(b->buf, b->idx);
  800a89:	83 ec 08             	sub    $0x8,%esp
  800a8c:	68 ff 00 00 00       	push   $0xff
  800a91:	8d 43 08             	lea    0x8(%ebx),%eax
  800a94:	50                   	push   %eax
  800a95:	e8 c7 0a 00 00       	call   801561 <sys_cputs>
		b->idx = 0;
  800a9a:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800aa0:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  800aa3:	ff 43 04             	incl   0x4(%ebx)
}
  800aa6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800aa9:	c9                   	leave  
  800aaa:	c3                   	ret    

00800aab <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800aab:	55                   	push   %ebp
  800aac:	89 e5                	mov    %esp,%ebp
  800aae:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800ab4:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800abb:	00 00 00 
	b.cnt = 0;
  800abe:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800ac5:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800ac8:	ff 75 0c             	pushl  0xc(%ebp)
  800acb:	ff 75 08             	pushl  0x8(%ebp)
  800ace:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800ad4:	50                   	push   %eax
  800ad5:	68 6c 0a 80 00       	push   $0x800a6c
  800ada:	e8 82 01 00 00       	call   800c61 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800adf:	83 c4 08             	add    $0x8,%esp
  800ae2:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800ae8:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800aee:	50                   	push   %eax
  800aef:	e8 6d 0a 00 00       	call   801561 <sys_cputs>

	return b.cnt;
}
  800af4:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800afa:	c9                   	leave  
  800afb:	c3                   	ret    

00800afc <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800afc:	55                   	push   %ebp
  800afd:	89 e5                	mov    %esp,%ebp
  800aff:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800b02:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800b05:	50                   	push   %eax
  800b06:	ff 75 08             	pushl  0x8(%ebp)
  800b09:	e8 9d ff ff ff       	call   800aab <vcprintf>
	va_end(ap);

	return cnt;
}
  800b0e:	c9                   	leave  
  800b0f:	c3                   	ret    

00800b10 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800b10:	55                   	push   %ebp
  800b11:	89 e5                	mov    %esp,%ebp
  800b13:	57                   	push   %edi
  800b14:	56                   	push   %esi
  800b15:	53                   	push   %ebx
  800b16:	83 ec 2c             	sub    $0x2c,%esp
  800b19:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800b1c:	89 d6                	mov    %edx,%esi
  800b1e:	8b 45 08             	mov    0x8(%ebp),%eax
  800b21:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b24:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800b27:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800b2a:	8b 45 10             	mov    0x10(%ebp),%eax
  800b2d:	8b 5d 14             	mov    0x14(%ebp),%ebx
  800b30:	8b 7d 18             	mov    0x18(%ebp),%edi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800b33:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800b36:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  800b3d:	39 55 d4             	cmp    %edx,-0x2c(%ebp)
  800b40:	72 0c                	jb     800b4e <printnum+0x3e>
  800b42:	3b 45 d8             	cmp    -0x28(%ebp),%eax
  800b45:	76 07                	jbe    800b4e <printnum+0x3e>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800b47:	4b                   	dec    %ebx
  800b48:	85 db                	test   %ebx,%ebx
  800b4a:	7f 31                	jg     800b7d <printnum+0x6d>
  800b4c:	eb 3f                	jmp    800b8d <printnum+0x7d>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800b4e:	83 ec 0c             	sub    $0xc,%esp
  800b51:	57                   	push   %edi
  800b52:	4b                   	dec    %ebx
  800b53:	53                   	push   %ebx
  800b54:	50                   	push   %eax
  800b55:	83 ec 08             	sub    $0x8,%esp
  800b58:	ff 75 d4             	pushl  -0x2c(%ebp)
  800b5b:	ff 75 d0             	pushl  -0x30(%ebp)
  800b5e:	ff 75 dc             	pushl  -0x24(%ebp)
  800b61:	ff 75 d8             	pushl  -0x28(%ebp)
  800b64:	e8 5f 25 00 00       	call   8030c8 <__udivdi3>
  800b69:	83 c4 18             	add    $0x18,%esp
  800b6c:	52                   	push   %edx
  800b6d:	50                   	push   %eax
  800b6e:	89 f2                	mov    %esi,%edx
  800b70:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800b73:	e8 98 ff ff ff       	call   800b10 <printnum>
  800b78:	83 c4 20             	add    $0x20,%esp
  800b7b:	eb 10                	jmp    800b8d <printnum+0x7d>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800b7d:	83 ec 08             	sub    $0x8,%esp
  800b80:	56                   	push   %esi
  800b81:	57                   	push   %edi
  800b82:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800b85:	4b                   	dec    %ebx
  800b86:	83 c4 10             	add    $0x10,%esp
  800b89:	85 db                	test   %ebx,%ebx
  800b8b:	7f f0                	jg     800b7d <printnum+0x6d>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800b8d:	83 ec 08             	sub    $0x8,%esp
  800b90:	56                   	push   %esi
  800b91:	83 ec 04             	sub    $0x4,%esp
  800b94:	ff 75 d4             	pushl  -0x2c(%ebp)
  800b97:	ff 75 d0             	pushl  -0x30(%ebp)
  800b9a:	ff 75 dc             	pushl  -0x24(%ebp)
  800b9d:	ff 75 d8             	pushl  -0x28(%ebp)
  800ba0:	e8 3f 26 00 00       	call   8031e4 <__umoddi3>
  800ba5:	83 c4 14             	add    $0x14,%esp
  800ba8:	0f be 80 63 35 80 00 	movsbl 0x803563(%eax),%eax
  800baf:	50                   	push   %eax
  800bb0:	ff 55 e4             	call   *-0x1c(%ebp)
  800bb3:	83 c4 10             	add    $0x10,%esp
}
  800bb6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bb9:	5b                   	pop    %ebx
  800bba:	5e                   	pop    %esi
  800bbb:	5f                   	pop    %edi
  800bbc:	c9                   	leave  
  800bbd:	c3                   	ret    

00800bbe <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800bbe:	55                   	push   %ebp
  800bbf:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800bc1:	83 fa 01             	cmp    $0x1,%edx
  800bc4:	7e 0e                	jle    800bd4 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800bc6:	8b 10                	mov    (%eax),%edx
  800bc8:	8d 4a 08             	lea    0x8(%edx),%ecx
  800bcb:	89 08                	mov    %ecx,(%eax)
  800bcd:	8b 02                	mov    (%edx),%eax
  800bcf:	8b 52 04             	mov    0x4(%edx),%edx
  800bd2:	eb 22                	jmp    800bf6 <getuint+0x38>
	else if (lflag)
  800bd4:	85 d2                	test   %edx,%edx
  800bd6:	74 10                	je     800be8 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800bd8:	8b 10                	mov    (%eax),%edx
  800bda:	8d 4a 04             	lea    0x4(%edx),%ecx
  800bdd:	89 08                	mov    %ecx,(%eax)
  800bdf:	8b 02                	mov    (%edx),%eax
  800be1:	ba 00 00 00 00       	mov    $0x0,%edx
  800be6:	eb 0e                	jmp    800bf6 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800be8:	8b 10                	mov    (%eax),%edx
  800bea:	8d 4a 04             	lea    0x4(%edx),%ecx
  800bed:	89 08                	mov    %ecx,(%eax)
  800bef:	8b 02                	mov    (%edx),%eax
  800bf1:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800bf6:	c9                   	leave  
  800bf7:	c3                   	ret    

00800bf8 <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
  800bf8:	55                   	push   %ebp
  800bf9:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800bfb:	83 fa 01             	cmp    $0x1,%edx
  800bfe:	7e 0e                	jle    800c0e <getint+0x16>
		return va_arg(*ap, long long);
  800c00:	8b 10                	mov    (%eax),%edx
  800c02:	8d 4a 08             	lea    0x8(%edx),%ecx
  800c05:	89 08                	mov    %ecx,(%eax)
  800c07:	8b 02                	mov    (%edx),%eax
  800c09:	8b 52 04             	mov    0x4(%edx),%edx
  800c0c:	eb 1a                	jmp    800c28 <getint+0x30>
	else if (lflag)
  800c0e:	85 d2                	test   %edx,%edx
  800c10:	74 0c                	je     800c1e <getint+0x26>
		return va_arg(*ap, long);
  800c12:	8b 10                	mov    (%eax),%edx
  800c14:	8d 4a 04             	lea    0x4(%edx),%ecx
  800c17:	89 08                	mov    %ecx,(%eax)
  800c19:	8b 02                	mov    (%edx),%eax
  800c1b:	99                   	cltd   
  800c1c:	eb 0a                	jmp    800c28 <getint+0x30>
	else
		return va_arg(*ap, int);
  800c1e:	8b 10                	mov    (%eax),%edx
  800c20:	8d 4a 04             	lea    0x4(%edx),%ecx
  800c23:	89 08                	mov    %ecx,(%eax)
  800c25:	8b 02                	mov    (%edx),%eax
  800c27:	99                   	cltd   
}
  800c28:	c9                   	leave  
  800c29:	c3                   	ret    

00800c2a <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800c2a:	55                   	push   %ebp
  800c2b:	89 e5                	mov    %esp,%ebp
  800c2d:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800c30:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  800c33:	8b 10                	mov    (%eax),%edx
  800c35:	3b 50 04             	cmp    0x4(%eax),%edx
  800c38:	73 08                	jae    800c42 <sprintputch+0x18>
		*b->buf++ = ch;
  800c3a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c3d:	88 0a                	mov    %cl,(%edx)
  800c3f:	42                   	inc    %edx
  800c40:	89 10                	mov    %edx,(%eax)
}
  800c42:	c9                   	leave  
  800c43:	c3                   	ret    

00800c44 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800c44:	55                   	push   %ebp
  800c45:	89 e5                	mov    %esp,%ebp
  800c47:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800c4a:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800c4d:	50                   	push   %eax
  800c4e:	ff 75 10             	pushl  0x10(%ebp)
  800c51:	ff 75 0c             	pushl  0xc(%ebp)
  800c54:	ff 75 08             	pushl  0x8(%ebp)
  800c57:	e8 05 00 00 00       	call   800c61 <vprintfmt>
	va_end(ap);
  800c5c:	83 c4 10             	add    $0x10,%esp
}
  800c5f:	c9                   	leave  
  800c60:	c3                   	ret    

00800c61 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800c61:	55                   	push   %ebp
  800c62:	89 e5                	mov    %esp,%ebp
  800c64:	57                   	push   %edi
  800c65:	56                   	push   %esi
  800c66:	53                   	push   %ebx
  800c67:	83 ec 2c             	sub    $0x2c,%esp
  800c6a:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800c6d:	8b 75 10             	mov    0x10(%ebp),%esi
  800c70:	eb 13                	jmp    800c85 <vprintfmt+0x24>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800c72:	85 c0                	test   %eax,%eax
  800c74:	0f 84 6d 03 00 00    	je     800fe7 <vprintfmt+0x386>
				return;
			putch(ch, putdat);
  800c7a:	83 ec 08             	sub    $0x8,%esp
  800c7d:	57                   	push   %edi
  800c7e:	50                   	push   %eax
  800c7f:	ff 55 08             	call   *0x8(%ebp)
  800c82:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800c85:	0f b6 06             	movzbl (%esi),%eax
  800c88:	46                   	inc    %esi
  800c89:	83 f8 25             	cmp    $0x25,%eax
  800c8c:	75 e4                	jne    800c72 <vprintfmt+0x11>
  800c8e:	c6 45 dc 20          	movb   $0x20,-0x24(%ebp)
  800c92:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  800c99:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
  800ca0:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  800ca7:	b9 00 00 00 00       	mov    $0x0,%ecx
  800cac:	eb 28                	jmp    800cd6 <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800cae:	89 de                	mov    %ebx,%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  800cb0:	c6 45 dc 2d          	movb   $0x2d,-0x24(%ebp)
  800cb4:	eb 20                	jmp    800cd6 <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800cb6:	89 de                	mov    %ebx,%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800cb8:	c6 45 dc 30          	movb   $0x30,-0x24(%ebp)
  800cbc:	eb 18                	jmp    800cd6 <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800cbe:	89 de                	mov    %ebx,%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  800cc0:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800cc7:	eb 0d                	jmp    800cd6 <vprintfmt+0x75>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  800cc9:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  800ccc:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800ccf:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800cd6:	8a 06                	mov    (%esi),%al
  800cd8:	0f b6 d0             	movzbl %al,%edx
  800cdb:	8d 5e 01             	lea    0x1(%esi),%ebx
  800cde:	83 e8 23             	sub    $0x23,%eax
  800ce1:	3c 55                	cmp    $0x55,%al
  800ce3:	0f 87 e0 02 00 00    	ja     800fc9 <vprintfmt+0x368>
  800ce9:	0f b6 c0             	movzbl %al,%eax
  800cec:	ff 24 85 a0 36 80 00 	jmp    *0x8036a0(,%eax,4)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800cf3:	83 ea 30             	sub    $0x30,%edx
  800cf6:	89 55 d4             	mov    %edx,-0x2c(%ebp)
				ch = *fmt;
  800cf9:	0f be 03             	movsbl (%ebx),%eax
				if (ch < '0' || ch > '9')
  800cfc:	8d 50 d0             	lea    -0x30(%eax),%edx
  800cff:	83 fa 09             	cmp    $0x9,%edx
  800d02:	77 44                	ja     800d48 <vprintfmt+0xe7>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800d04:	89 de                	mov    %ebx,%esi
  800d06:	8b 55 d4             	mov    -0x2c(%ebp),%edx
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800d09:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
  800d0a:	8d 14 92             	lea    (%edx,%edx,4),%edx
  800d0d:	8d 54 50 d0          	lea    -0x30(%eax,%edx,2),%edx
				ch = *fmt;
  800d11:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  800d14:	8d 58 d0             	lea    -0x30(%eax),%ebx
  800d17:	83 fb 09             	cmp    $0x9,%ebx
  800d1a:	76 ed                	jbe    800d09 <vprintfmt+0xa8>
  800d1c:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  800d1f:	eb 29                	jmp    800d4a <vprintfmt+0xe9>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800d21:	8b 45 14             	mov    0x14(%ebp),%eax
  800d24:	8d 50 04             	lea    0x4(%eax),%edx
  800d27:	89 55 14             	mov    %edx,0x14(%ebp)
  800d2a:	8b 00                	mov    (%eax),%eax
  800d2c:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800d2f:	89 de                	mov    %ebx,%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800d31:	eb 17                	jmp    800d4a <vprintfmt+0xe9>

		case '.':
			if (width < 0)
  800d33:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800d37:	78 85                	js     800cbe <vprintfmt+0x5d>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800d39:	89 de                	mov    %ebx,%esi
  800d3b:	eb 99                	jmp    800cd6 <vprintfmt+0x75>
  800d3d:	89 de                	mov    %ebx,%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800d3f:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
			goto reswitch;
  800d46:	eb 8e                	jmp    800cd6 <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800d48:	89 de                	mov    %ebx,%esi
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  800d4a:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800d4e:	79 86                	jns    800cd6 <vprintfmt+0x75>
  800d50:	e9 74 ff ff ff       	jmp    800cc9 <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800d55:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800d56:	89 de                	mov    %ebx,%esi
  800d58:	e9 79 ff ff ff       	jmp    800cd6 <vprintfmt+0x75>
  800d5d:	89 5d d8             	mov    %ebx,-0x28(%ebp)
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800d60:	8b 45 14             	mov    0x14(%ebp),%eax
  800d63:	8d 50 04             	lea    0x4(%eax),%edx
  800d66:	89 55 14             	mov    %edx,0x14(%ebp)
  800d69:	83 ec 08             	sub    $0x8,%esp
  800d6c:	57                   	push   %edi
  800d6d:	ff 30                	pushl  (%eax)
  800d6f:	ff 55 08             	call   *0x8(%ebp)
			break;
  800d72:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800d75:	8b 75 d8             	mov    -0x28(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800d78:	e9 08 ff ff ff       	jmp    800c85 <vprintfmt+0x24>
  800d7d:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// error message
		case 'e':
			err = va_arg(ap, int);
  800d80:	8b 45 14             	mov    0x14(%ebp),%eax
  800d83:	8d 50 04             	lea    0x4(%eax),%edx
  800d86:	89 55 14             	mov    %edx,0x14(%ebp)
  800d89:	8b 00                	mov    (%eax),%eax
  800d8b:	85 c0                	test   %eax,%eax
  800d8d:	79 02                	jns    800d91 <vprintfmt+0x130>
  800d8f:	f7 d8                	neg    %eax
  800d91:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800d93:	83 f8 0f             	cmp    $0xf,%eax
  800d96:	7f 0b                	jg     800da3 <vprintfmt+0x142>
  800d98:	8b 04 85 00 38 80 00 	mov    0x803800(,%eax,4),%eax
  800d9f:	85 c0                	test   %eax,%eax
  800da1:	75 1a                	jne    800dbd <vprintfmt+0x15c>
				printfmt(putch, putdat, "error %d", err);
  800da3:	52                   	push   %edx
  800da4:	68 7b 35 80 00       	push   $0x80357b
  800da9:	57                   	push   %edi
  800daa:	ff 75 08             	pushl  0x8(%ebp)
  800dad:	e8 92 fe ff ff       	call   800c44 <printfmt>
  800db2:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800db5:	8b 75 d8             	mov    -0x28(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800db8:	e9 c8 fe ff ff       	jmp    800c85 <vprintfmt+0x24>
			else
				printfmt(putch, putdat, "%s", p);
  800dbd:	50                   	push   %eax
  800dbe:	68 84 34 80 00       	push   $0x803484
  800dc3:	57                   	push   %edi
  800dc4:	ff 75 08             	pushl  0x8(%ebp)
  800dc7:	e8 78 fe ff ff       	call   800c44 <printfmt>
  800dcc:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800dcf:	8b 75 d8             	mov    -0x28(%ebp),%esi
  800dd2:	e9 ae fe ff ff       	jmp    800c85 <vprintfmt+0x24>
  800dd7:	89 5d d8             	mov    %ebx,-0x28(%ebp)
  800dda:	89 de                	mov    %ebx,%esi
  800ddc:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  800ddf:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800de2:	8b 45 14             	mov    0x14(%ebp),%eax
  800de5:	8d 50 04             	lea    0x4(%eax),%edx
  800de8:	89 55 14             	mov    %edx,0x14(%ebp)
  800deb:	8b 00                	mov    (%eax),%eax
  800ded:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800df0:	85 c0                	test   %eax,%eax
  800df2:	75 07                	jne    800dfb <vprintfmt+0x19a>
				p = "(null)";
  800df4:	c7 45 d0 74 35 80 00 	movl   $0x803574,-0x30(%ebp)
			if (width > 0 && padc != '-')
  800dfb:	85 db                	test   %ebx,%ebx
  800dfd:	7e 42                	jle    800e41 <vprintfmt+0x1e0>
  800dff:	80 7d dc 2d          	cmpb   $0x2d,-0x24(%ebp)
  800e03:	74 3c                	je     800e41 <vprintfmt+0x1e0>
				for (width -= strnlen(p, precision); width > 0; width--)
  800e05:	83 ec 08             	sub    $0x8,%esp
  800e08:	51                   	push   %ecx
  800e09:	ff 75 d0             	pushl  -0x30(%ebp)
  800e0c:	e8 53 03 00 00       	call   801164 <strnlen>
  800e11:	29 c3                	sub    %eax,%ebx
  800e13:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800e16:	83 c4 10             	add    $0x10,%esp
  800e19:	85 db                	test   %ebx,%ebx
  800e1b:	7e 24                	jle    800e41 <vprintfmt+0x1e0>
					putch(padc, putdat);
  800e1d:	0f be 5d dc          	movsbl -0x24(%ebp),%ebx
  800e21:	89 75 dc             	mov    %esi,-0x24(%ebp)
  800e24:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  800e27:	83 ec 08             	sub    $0x8,%esp
  800e2a:	57                   	push   %edi
  800e2b:	53                   	push   %ebx
  800e2c:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800e2f:	4e                   	dec    %esi
  800e30:	83 c4 10             	add    $0x10,%esp
  800e33:	85 f6                	test   %esi,%esi
  800e35:	7f f0                	jg     800e27 <vprintfmt+0x1c6>
  800e37:	8b 75 dc             	mov    -0x24(%ebp),%esi
  800e3a:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800e41:	8b 55 d0             	mov    -0x30(%ebp),%edx
  800e44:	0f be 02             	movsbl (%edx),%eax
  800e47:	85 c0                	test   %eax,%eax
  800e49:	75 47                	jne    800e92 <vprintfmt+0x231>
  800e4b:	eb 37                	jmp    800e84 <vprintfmt+0x223>
				if (altflag && (ch < ' ' || ch > '~'))
  800e4d:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800e51:	74 16                	je     800e69 <vprintfmt+0x208>
  800e53:	8d 50 e0             	lea    -0x20(%eax),%edx
  800e56:	83 fa 5e             	cmp    $0x5e,%edx
  800e59:	76 0e                	jbe    800e69 <vprintfmt+0x208>
					putch('?', putdat);
  800e5b:	83 ec 08             	sub    $0x8,%esp
  800e5e:	57                   	push   %edi
  800e5f:	6a 3f                	push   $0x3f
  800e61:	ff 55 08             	call   *0x8(%ebp)
  800e64:	83 c4 10             	add    $0x10,%esp
  800e67:	eb 0b                	jmp    800e74 <vprintfmt+0x213>
				else
					putch(ch, putdat);
  800e69:	83 ec 08             	sub    $0x8,%esp
  800e6c:	57                   	push   %edi
  800e6d:	50                   	push   %eax
  800e6e:	ff 55 08             	call   *0x8(%ebp)
  800e71:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800e74:	ff 4d e4             	decl   -0x1c(%ebp)
  800e77:	0f be 03             	movsbl (%ebx),%eax
  800e7a:	85 c0                	test   %eax,%eax
  800e7c:	74 03                	je     800e81 <vprintfmt+0x220>
  800e7e:	43                   	inc    %ebx
  800e7f:	eb 1b                	jmp    800e9c <vprintfmt+0x23b>
  800e81:	8b 75 dc             	mov    -0x24(%ebp),%esi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800e84:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800e88:	7f 1e                	jg     800ea8 <vprintfmt+0x247>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800e8a:	8b 75 d8             	mov    -0x28(%ebp),%esi
  800e8d:	e9 f3 fd ff ff       	jmp    800c85 <vprintfmt+0x24>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800e92:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  800e95:	43                   	inc    %ebx
  800e96:	89 75 dc             	mov    %esi,-0x24(%ebp)
  800e99:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  800e9c:	85 f6                	test   %esi,%esi
  800e9e:	78 ad                	js     800e4d <vprintfmt+0x1ec>
  800ea0:	4e                   	dec    %esi
  800ea1:	79 aa                	jns    800e4d <vprintfmt+0x1ec>
  800ea3:	8b 75 dc             	mov    -0x24(%ebp),%esi
  800ea6:	eb dc                	jmp    800e84 <vprintfmt+0x223>
  800ea8:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800eab:	83 ec 08             	sub    $0x8,%esp
  800eae:	57                   	push   %edi
  800eaf:	6a 20                	push   $0x20
  800eb1:	ff 55 08             	call   *0x8(%ebp)
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800eb4:	4b                   	dec    %ebx
  800eb5:	83 c4 10             	add    $0x10,%esp
  800eb8:	85 db                	test   %ebx,%ebx
  800eba:	7f ef                	jg     800eab <vprintfmt+0x24a>
  800ebc:	e9 c4 fd ff ff       	jmp    800c85 <vprintfmt+0x24>
  800ec1:	89 5d d8             	mov    %ebx,-0x28(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800ec4:	89 ca                	mov    %ecx,%edx
  800ec6:	8d 45 14             	lea    0x14(%ebp),%eax
  800ec9:	e8 2a fd ff ff       	call   800bf8 <getint>
  800ece:	89 c3                	mov    %eax,%ebx
  800ed0:	89 d6                	mov    %edx,%esi
			if ((long long) num < 0) {
  800ed2:	85 d2                	test   %edx,%edx
  800ed4:	78 0a                	js     800ee0 <vprintfmt+0x27f>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800ed6:	b8 0a 00 00 00       	mov    $0xa,%eax
  800edb:	e9 b0 00 00 00       	jmp    800f90 <vprintfmt+0x32f>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  800ee0:	83 ec 08             	sub    $0x8,%esp
  800ee3:	57                   	push   %edi
  800ee4:	6a 2d                	push   $0x2d
  800ee6:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  800ee9:	f7 db                	neg    %ebx
  800eeb:	83 d6 00             	adc    $0x0,%esi
  800eee:	f7 de                	neg    %esi
  800ef0:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800ef3:	b8 0a 00 00 00       	mov    $0xa,%eax
  800ef8:	e9 93 00 00 00       	jmp    800f90 <vprintfmt+0x32f>
  800efd:	89 5d d8             	mov    %ebx,-0x28(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800f00:	89 ca                	mov    %ecx,%edx
  800f02:	8d 45 14             	lea    0x14(%ebp),%eax
  800f05:	e8 b4 fc ff ff       	call   800bbe <getuint>
  800f0a:	89 c3                	mov    %eax,%ebx
  800f0c:	89 d6                	mov    %edx,%esi
			base = 10;
  800f0e:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  800f13:	eb 7b                	jmp    800f90 <vprintfmt+0x32f>
  800f15:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// (unsigned) octal
		case 'o':
            // (MIT 6.828, lab1, Ex.8)  my code : 
            num = getint(&ap, lflag);
  800f18:	89 ca                	mov    %ecx,%edx
  800f1a:	8d 45 14             	lea    0x14(%ebp),%eax
  800f1d:	e8 d6 fc ff ff       	call   800bf8 <getint>
  800f22:	89 c3                	mov    %eax,%ebx
  800f24:	89 d6                	mov    %edx,%esi
            if ((long long) num < 0) {
  800f26:	85 d2                	test   %edx,%edx
  800f28:	78 07                	js     800f31 <vprintfmt+0x2d0>
                putch('-', putdat);
                num = -(long long) num;
            }
            base = 8;
  800f2a:	b8 08 00 00 00       	mov    $0x8,%eax
  800f2f:	eb 5f                	jmp    800f90 <vprintfmt+0x32f>
		// (unsigned) octal
		case 'o':
            // (MIT 6.828, lab1, Ex.8)  my code : 
            num = getint(&ap, lflag);
            if ((long long) num < 0) {
                putch('-', putdat);
  800f31:	83 ec 08             	sub    $0x8,%esp
  800f34:	57                   	push   %edi
  800f35:	6a 2d                	push   $0x2d
  800f37:	ff 55 08             	call   *0x8(%ebp)
                num = -(long long) num;
  800f3a:	f7 db                	neg    %ebx
  800f3c:	83 d6 00             	adc    $0x0,%esi
  800f3f:	f7 de                	neg    %esi
  800f41:	83 c4 10             	add    $0x10,%esp
            }
            base = 8;
  800f44:	b8 08 00 00 00       	mov    $0x8,%eax
  800f49:	eb 45                	jmp    800f90 <vprintfmt+0x32f>
  800f4b:	89 5d d8             	mov    %ebx,-0x28(%ebp)
            goto number;

        // pointer
		case 'p':
			putch('0', putdat);
  800f4e:	83 ec 08             	sub    $0x8,%esp
  800f51:	57                   	push   %edi
  800f52:	6a 30                	push   $0x30
  800f54:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  800f57:	83 c4 08             	add    $0x8,%esp
  800f5a:	57                   	push   %edi
  800f5b:	6a 78                	push   $0x78
  800f5d:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800f60:	8b 45 14             	mov    0x14(%ebp),%eax
  800f63:	8d 50 04             	lea    0x4(%eax),%edx
  800f66:	89 55 14             	mov    %edx,0x14(%ebp)

        // pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800f69:	8b 18                	mov    (%eax),%ebx
  800f6b:	be 00 00 00 00       	mov    $0x0,%esi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800f70:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800f73:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  800f78:	eb 16                	jmp    800f90 <vprintfmt+0x32f>
  800f7a:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800f7d:	89 ca                	mov    %ecx,%edx
  800f7f:	8d 45 14             	lea    0x14(%ebp),%eax
  800f82:	e8 37 fc ff ff       	call   800bbe <getuint>
  800f87:	89 c3                	mov    %eax,%ebx
  800f89:	89 d6                	mov    %edx,%esi
			base = 16;
  800f8b:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  800f90:	83 ec 0c             	sub    $0xc,%esp
  800f93:	0f be 55 dc          	movsbl -0x24(%ebp),%edx
  800f97:	52                   	push   %edx
  800f98:	ff 75 e4             	pushl  -0x1c(%ebp)
  800f9b:	50                   	push   %eax
  800f9c:	56                   	push   %esi
  800f9d:	53                   	push   %ebx
  800f9e:	89 fa                	mov    %edi,%edx
  800fa0:	8b 45 08             	mov    0x8(%ebp),%eax
  800fa3:	e8 68 fb ff ff       	call   800b10 <printnum>
			break;
  800fa8:	83 c4 20             	add    $0x20,%esp
  800fab:	8b 75 d8             	mov    -0x28(%ebp),%esi
  800fae:	e9 d2 fc ff ff       	jmp    800c85 <vprintfmt+0x24>
  800fb3:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800fb6:	83 ec 08             	sub    $0x8,%esp
  800fb9:	57                   	push   %edi
  800fba:	52                   	push   %edx
  800fbb:	ff 55 08             	call   *0x8(%ebp)
			break;
  800fbe:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800fc1:	8b 75 d8             	mov    -0x28(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800fc4:	e9 bc fc ff ff       	jmp    800c85 <vprintfmt+0x24>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800fc9:	83 ec 08             	sub    $0x8,%esp
  800fcc:	57                   	push   %edi
  800fcd:	6a 25                	push   $0x25
  800fcf:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800fd2:	83 c4 10             	add    $0x10,%esp
  800fd5:	eb 02                	jmp    800fd9 <vprintfmt+0x378>
  800fd7:	89 c6                	mov    %eax,%esi
  800fd9:	8d 46 ff             	lea    -0x1(%esi),%eax
  800fdc:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  800fe0:	75 f5                	jne    800fd7 <vprintfmt+0x376>
  800fe2:	e9 9e fc ff ff       	jmp    800c85 <vprintfmt+0x24>
				/* do nothing */;
			break;
		}
	}
}
  800fe7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800fea:	5b                   	pop    %ebx
  800feb:	5e                   	pop    %esi
  800fec:	5f                   	pop    %edi
  800fed:	c9                   	leave  
  800fee:	c3                   	ret    

00800fef <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800fef:	55                   	push   %ebp
  800ff0:	89 e5                	mov    %esp,%ebp
  800ff2:	83 ec 18             	sub    $0x18,%esp
  800ff5:	8b 45 08             	mov    0x8(%ebp),%eax
  800ff8:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800ffb:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800ffe:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  801002:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  801005:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80100c:	85 c0                	test   %eax,%eax
  80100e:	74 26                	je     801036 <vsnprintf+0x47>
  801010:	85 d2                	test   %edx,%edx
  801012:	7e 29                	jle    80103d <vsnprintf+0x4e>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  801014:	ff 75 14             	pushl  0x14(%ebp)
  801017:	ff 75 10             	pushl  0x10(%ebp)
  80101a:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80101d:	50                   	push   %eax
  80101e:	68 2a 0c 80 00       	push   $0x800c2a
  801023:	e8 39 fc ff ff       	call   800c61 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  801028:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80102b:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80102e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801031:	83 c4 10             	add    $0x10,%esp
  801034:	eb 0c                	jmp    801042 <vsnprintf+0x53>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  801036:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80103b:	eb 05                	jmp    801042 <vsnprintf+0x53>
  80103d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  801042:	c9                   	leave  
  801043:	c3                   	ret    

00801044 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  801044:	55                   	push   %ebp
  801045:	89 e5                	mov    %esp,%ebp
  801047:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80104a:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80104d:	50                   	push   %eax
  80104e:	ff 75 10             	pushl  0x10(%ebp)
  801051:	ff 75 0c             	pushl  0xc(%ebp)
  801054:	ff 75 08             	pushl  0x8(%ebp)
  801057:	e8 93 ff ff ff       	call   800fef <vsnprintf>
	va_end(ap);

	return rc;
}
  80105c:	c9                   	leave  
  80105d:	c3                   	ret    
	...

00801060 <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
  801060:	55                   	push   %ebp
  801061:	89 e5                	mov    %esp,%ebp
  801063:	57                   	push   %edi
  801064:	56                   	push   %esi
  801065:	53                   	push   %ebx
  801066:	83 ec 0c             	sub    $0xc,%esp
  801069:	8b 45 08             	mov    0x8(%ebp),%eax

#if JOS_KERNEL
	if (prompt != NULL)
		cprintf("%s", prompt);
#else
	if (prompt != NULL)
  80106c:	85 c0                	test   %eax,%eax
  80106e:	74 13                	je     801083 <readline+0x23>
		fprintf(1, "%s", prompt);
  801070:	83 ec 04             	sub    $0x4,%esp
  801073:	50                   	push   %eax
  801074:	68 84 34 80 00       	push   $0x803484
  801079:	6a 01                	push   $0x1
  80107b:	e8 e5 13 00 00       	call   802465 <fprintf>
  801080:	83 c4 10             	add    $0x10,%esp
#endif

	i = 0;
	echoing = iscons(0);
  801083:	83 ec 0c             	sub    $0xc,%esp
  801086:	6a 00                	push   $0x0
  801088:	e8 ad f8 ff ff       	call   80093a <iscons>
  80108d:	89 c7                	mov    %eax,%edi
  80108f:	83 c4 10             	add    $0x10,%esp
#else
	if (prompt != NULL)
		fprintf(1, "%s", prompt);
#endif

	i = 0;
  801092:	be 00 00 00 00       	mov    $0x0,%esi
	echoing = iscons(0);
	while (1) {
		c = getchar();
  801097:	e8 73 f8 ff ff       	call   80090f <getchar>
  80109c:	89 c3                	mov    %eax,%ebx
		if (c < 0) {
  80109e:	85 c0                	test   %eax,%eax
  8010a0:	79 21                	jns    8010c3 <readline+0x63>
			if (c != -E_EOF)
  8010a2:	83 f8 f8             	cmp    $0xfffffff8,%eax
  8010a5:	0f 84 89 00 00 00    	je     801134 <readline+0xd4>
				cprintf("read error: %e\n", c);
  8010ab:	83 ec 08             	sub    $0x8,%esp
  8010ae:	50                   	push   %eax
  8010af:	68 5f 38 80 00       	push   $0x80385f
  8010b4:	e8 43 fa ff ff       	call   800afc <cprintf>
  8010b9:	83 c4 10             	add    $0x10,%esp
			return NULL;
  8010bc:	b8 00 00 00 00       	mov    $0x0,%eax
  8010c1:	eb 76                	jmp    801139 <readline+0xd9>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
  8010c3:	83 f8 08             	cmp    $0x8,%eax
  8010c6:	74 05                	je     8010cd <readline+0x6d>
  8010c8:	83 f8 7f             	cmp    $0x7f,%eax
  8010cb:	75 18                	jne    8010e5 <readline+0x85>
  8010cd:	85 f6                	test   %esi,%esi
  8010cf:	7e 14                	jle    8010e5 <readline+0x85>
			if (echoing)
  8010d1:	85 ff                	test   %edi,%edi
  8010d3:	74 0d                	je     8010e2 <readline+0x82>
				cputchar('\b');
  8010d5:	83 ec 0c             	sub    $0xc,%esp
  8010d8:	6a 08                	push   $0x8
  8010da:	e8 14 f8 ff ff       	call   8008f3 <cputchar>
  8010df:	83 c4 10             	add    $0x10,%esp
			i--;
  8010e2:	4e                   	dec    %esi
  8010e3:	eb b2                	jmp    801097 <readline+0x37>
		} else if (c >= ' ' && i < BUFLEN-1) {
  8010e5:	83 fb 1f             	cmp    $0x1f,%ebx
  8010e8:	7e 21                	jle    80110b <readline+0xab>
  8010ea:	81 fe fe 03 00 00    	cmp    $0x3fe,%esi
  8010f0:	7f 19                	jg     80110b <readline+0xab>
			if (echoing)
  8010f2:	85 ff                	test   %edi,%edi
  8010f4:	74 0c                	je     801102 <readline+0xa2>
				cputchar(c);
  8010f6:	83 ec 0c             	sub    $0xc,%esp
  8010f9:	53                   	push   %ebx
  8010fa:	e8 f4 f7 ff ff       	call   8008f3 <cputchar>
  8010ff:	83 c4 10             	add    $0x10,%esp
			buf[i++] = c;
  801102:	88 9e 20 50 80 00    	mov    %bl,0x805020(%esi)
  801108:	46                   	inc    %esi
  801109:	eb 8c                	jmp    801097 <readline+0x37>
		} else if (c == '\n' || c == '\r') {
  80110b:	83 fb 0a             	cmp    $0xa,%ebx
  80110e:	74 05                	je     801115 <readline+0xb5>
  801110:	83 fb 0d             	cmp    $0xd,%ebx
  801113:	75 82                	jne    801097 <readline+0x37>
			if (echoing)
  801115:	85 ff                	test   %edi,%edi
  801117:	74 0d                	je     801126 <readline+0xc6>
				cputchar('\n');
  801119:	83 ec 0c             	sub    $0xc,%esp
  80111c:	6a 0a                	push   $0xa
  80111e:	e8 d0 f7 ff ff       	call   8008f3 <cputchar>
  801123:	83 c4 10             	add    $0x10,%esp
			buf[i] = 0;
  801126:	c6 86 20 50 80 00 00 	movb   $0x0,0x805020(%esi)
			return buf;
  80112d:	b8 20 50 80 00       	mov    $0x805020,%eax
  801132:	eb 05                	jmp    801139 <readline+0xd9>
	while (1) {
		c = getchar();
		if (c < 0) {
			if (c != -E_EOF)
				cprintf("read error: %e\n", c);
			return NULL;
  801134:	b8 00 00 00 00       	mov    $0x0,%eax
				cputchar('\n');
			buf[i] = 0;
			return buf;
		}
	}
}
  801139:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80113c:	5b                   	pop    %ebx
  80113d:	5e                   	pop    %esi
  80113e:	5f                   	pop    %edi
  80113f:	c9                   	leave  
  801140:	c3                   	ret    
  801141:	00 00                	add    %al,(%eax)
	...

00801144 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  801144:	55                   	push   %ebp
  801145:	89 e5                	mov    %esp,%ebp
  801147:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80114a:	80 3a 00             	cmpb   $0x0,(%edx)
  80114d:	74 0e                	je     80115d <strlen+0x19>
  80114f:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  801154:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  801155:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  801159:	75 f9                	jne    801154 <strlen+0x10>
  80115b:	eb 05                	jmp    801162 <strlen+0x1e>
  80115d:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  801162:	c9                   	leave  
  801163:	c3                   	ret    

00801164 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  801164:	55                   	push   %ebp
  801165:	89 e5                	mov    %esp,%ebp
  801167:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80116a:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80116d:	85 d2                	test   %edx,%edx
  80116f:	74 17                	je     801188 <strnlen+0x24>
  801171:	80 39 00             	cmpb   $0x0,(%ecx)
  801174:	74 19                	je     80118f <strnlen+0x2b>
  801176:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  80117b:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80117c:	39 d0                	cmp    %edx,%eax
  80117e:	74 14                	je     801194 <strnlen+0x30>
  801180:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  801184:	75 f5                	jne    80117b <strnlen+0x17>
  801186:	eb 0c                	jmp    801194 <strnlen+0x30>
  801188:	b8 00 00 00 00       	mov    $0x0,%eax
  80118d:	eb 05                	jmp    801194 <strnlen+0x30>
  80118f:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  801194:	c9                   	leave  
  801195:	c3                   	ret    

00801196 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  801196:	55                   	push   %ebp
  801197:	89 e5                	mov    %esp,%ebp
  801199:	53                   	push   %ebx
  80119a:	8b 45 08             	mov    0x8(%ebp),%eax
  80119d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8011a0:	ba 00 00 00 00       	mov    $0x0,%edx
  8011a5:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  8011a8:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  8011ab:	42                   	inc    %edx
  8011ac:	84 c9                	test   %cl,%cl
  8011ae:	75 f5                	jne    8011a5 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  8011b0:	5b                   	pop    %ebx
  8011b1:	c9                   	leave  
  8011b2:	c3                   	ret    

008011b3 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8011b3:	55                   	push   %ebp
  8011b4:	89 e5                	mov    %esp,%ebp
  8011b6:	53                   	push   %ebx
  8011b7:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8011ba:	53                   	push   %ebx
  8011bb:	e8 84 ff ff ff       	call   801144 <strlen>
  8011c0:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8011c3:	ff 75 0c             	pushl  0xc(%ebp)
  8011c6:	8d 04 03             	lea    (%ebx,%eax,1),%eax
  8011c9:	50                   	push   %eax
  8011ca:	e8 c7 ff ff ff       	call   801196 <strcpy>
	return dst;
}
  8011cf:	89 d8                	mov    %ebx,%eax
  8011d1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8011d4:	c9                   	leave  
  8011d5:	c3                   	ret    

008011d6 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8011d6:	55                   	push   %ebp
  8011d7:	89 e5                	mov    %esp,%ebp
  8011d9:	56                   	push   %esi
  8011da:	53                   	push   %ebx
  8011db:	8b 45 08             	mov    0x8(%ebp),%eax
  8011de:	8b 55 0c             	mov    0xc(%ebp),%edx
  8011e1:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8011e4:	85 f6                	test   %esi,%esi
  8011e6:	74 15                	je     8011fd <strncpy+0x27>
  8011e8:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
  8011ed:	8a 1a                	mov    (%edx),%bl
  8011ef:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8011f2:	80 3a 01             	cmpb   $0x1,(%edx)
  8011f5:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8011f8:	41                   	inc    %ecx
  8011f9:	39 ce                	cmp    %ecx,%esi
  8011fb:	77 f0                	ja     8011ed <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8011fd:	5b                   	pop    %ebx
  8011fe:	5e                   	pop    %esi
  8011ff:	c9                   	leave  
  801200:	c3                   	ret    

00801201 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  801201:	55                   	push   %ebp
  801202:	89 e5                	mov    %esp,%ebp
  801204:	57                   	push   %edi
  801205:	56                   	push   %esi
  801206:	53                   	push   %ebx
  801207:	8b 7d 08             	mov    0x8(%ebp),%edi
  80120a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80120d:	8b 75 10             	mov    0x10(%ebp),%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  801210:	85 f6                	test   %esi,%esi
  801212:	74 32                	je     801246 <strlcpy+0x45>
		while (--size > 0 && *src != '\0')
  801214:	83 fe 01             	cmp    $0x1,%esi
  801217:	74 22                	je     80123b <strlcpy+0x3a>
  801219:	8a 0b                	mov    (%ebx),%cl
  80121b:	84 c9                	test   %cl,%cl
  80121d:	74 20                	je     80123f <strlcpy+0x3e>
  80121f:	89 f8                	mov    %edi,%eax
  801221:	ba 00 00 00 00       	mov    $0x0,%edx
	}
	return ret;
}

size_t
strlcpy(char *dst, const char *src, size_t size)
  801226:	83 ee 02             	sub    $0x2,%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  801229:	88 08                	mov    %cl,(%eax)
  80122b:	40                   	inc    %eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  80122c:	39 f2                	cmp    %esi,%edx
  80122e:	74 11                	je     801241 <strlcpy+0x40>
  801230:	8a 4c 13 01          	mov    0x1(%ebx,%edx,1),%cl
  801234:	42                   	inc    %edx
  801235:	84 c9                	test   %cl,%cl
  801237:	75 f0                	jne    801229 <strlcpy+0x28>
  801239:	eb 06                	jmp    801241 <strlcpy+0x40>
  80123b:	89 f8                	mov    %edi,%eax
  80123d:	eb 02                	jmp    801241 <strlcpy+0x40>
  80123f:	89 f8                	mov    %edi,%eax
			*dst++ = *src++;
		*dst = '\0';
  801241:	c6 00 00             	movb   $0x0,(%eax)
  801244:	eb 02                	jmp    801248 <strlcpy+0x47>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  801246:	89 f8                	mov    %edi,%eax
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
		*dst = '\0';
	}
	return dst - dst_in;
  801248:	29 f8                	sub    %edi,%eax
}
  80124a:	5b                   	pop    %ebx
  80124b:	5e                   	pop    %esi
  80124c:	5f                   	pop    %edi
  80124d:	c9                   	leave  
  80124e:	c3                   	ret    

0080124f <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80124f:	55                   	push   %ebp
  801250:	89 e5                	mov    %esp,%ebp
  801252:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801255:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  801258:	8a 01                	mov    (%ecx),%al
  80125a:	84 c0                	test   %al,%al
  80125c:	74 10                	je     80126e <strcmp+0x1f>
  80125e:	3a 02                	cmp    (%edx),%al
  801260:	75 0c                	jne    80126e <strcmp+0x1f>
		p++, q++;
  801262:	41                   	inc    %ecx
  801263:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  801264:	8a 01                	mov    (%ecx),%al
  801266:	84 c0                	test   %al,%al
  801268:	74 04                	je     80126e <strcmp+0x1f>
  80126a:	3a 02                	cmp    (%edx),%al
  80126c:	74 f4                	je     801262 <strcmp+0x13>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  80126e:	0f b6 c0             	movzbl %al,%eax
  801271:	0f b6 12             	movzbl (%edx),%edx
  801274:	29 d0                	sub    %edx,%eax
}
  801276:	c9                   	leave  
  801277:	c3                   	ret    

00801278 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  801278:	55                   	push   %ebp
  801279:	89 e5                	mov    %esp,%ebp
  80127b:	53                   	push   %ebx
  80127c:	8b 55 08             	mov    0x8(%ebp),%edx
  80127f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801282:	8b 45 10             	mov    0x10(%ebp),%eax
	while (n > 0 && *p && *p == *q)
  801285:	85 c0                	test   %eax,%eax
  801287:	74 1b                	je     8012a4 <strncmp+0x2c>
  801289:	8a 1a                	mov    (%edx),%bl
  80128b:	84 db                	test   %bl,%bl
  80128d:	74 24                	je     8012b3 <strncmp+0x3b>
  80128f:	3a 19                	cmp    (%ecx),%bl
  801291:	75 20                	jne    8012b3 <strncmp+0x3b>
  801293:	48                   	dec    %eax
  801294:	74 15                	je     8012ab <strncmp+0x33>
		n--, p++, q++;
  801296:	42                   	inc    %edx
  801297:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  801298:	8a 1a                	mov    (%edx),%bl
  80129a:	84 db                	test   %bl,%bl
  80129c:	74 15                	je     8012b3 <strncmp+0x3b>
  80129e:	3a 19                	cmp    (%ecx),%bl
  8012a0:	74 f1                	je     801293 <strncmp+0x1b>
  8012a2:	eb 0f                	jmp    8012b3 <strncmp+0x3b>
		n--, p++, q++;
	if (n == 0)
		return 0;
  8012a4:	b8 00 00 00 00       	mov    $0x0,%eax
  8012a9:	eb 05                	jmp    8012b0 <strncmp+0x38>
  8012ab:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8012b0:	5b                   	pop    %ebx
  8012b1:	c9                   	leave  
  8012b2:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8012b3:	0f b6 02             	movzbl (%edx),%eax
  8012b6:	0f b6 11             	movzbl (%ecx),%edx
  8012b9:	29 d0                	sub    %edx,%eax
  8012bb:	eb f3                	jmp    8012b0 <strncmp+0x38>

008012bd <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8012bd:	55                   	push   %ebp
  8012be:	89 e5                	mov    %esp,%ebp
  8012c0:	8b 45 08             	mov    0x8(%ebp),%eax
  8012c3:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  8012c6:	8a 10                	mov    (%eax),%dl
  8012c8:	84 d2                	test   %dl,%dl
  8012ca:	74 18                	je     8012e4 <strchr+0x27>
		if (*s == c)
  8012cc:	38 ca                	cmp    %cl,%dl
  8012ce:	75 06                	jne    8012d6 <strchr+0x19>
  8012d0:	eb 17                	jmp    8012e9 <strchr+0x2c>
  8012d2:	38 ca                	cmp    %cl,%dl
  8012d4:	74 13                	je     8012e9 <strchr+0x2c>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8012d6:	40                   	inc    %eax
  8012d7:	8a 10                	mov    (%eax),%dl
  8012d9:	84 d2                	test   %dl,%dl
  8012db:	75 f5                	jne    8012d2 <strchr+0x15>
		if (*s == c)
			return (char *) s;
	return 0;
  8012dd:	b8 00 00 00 00       	mov    $0x0,%eax
  8012e2:	eb 05                	jmp    8012e9 <strchr+0x2c>
  8012e4:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8012e9:	c9                   	leave  
  8012ea:	c3                   	ret    

008012eb <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8012eb:	55                   	push   %ebp
  8012ec:	89 e5                	mov    %esp,%ebp
  8012ee:	8b 45 08             	mov    0x8(%ebp),%eax
  8012f1:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  8012f4:	8a 10                	mov    (%eax),%dl
  8012f6:	84 d2                	test   %dl,%dl
  8012f8:	74 11                	je     80130b <strfind+0x20>
		if (*s == c)
  8012fa:	38 ca                	cmp    %cl,%dl
  8012fc:	75 06                	jne    801304 <strfind+0x19>
  8012fe:	eb 0b                	jmp    80130b <strfind+0x20>
  801300:	38 ca                	cmp    %cl,%dl
  801302:	74 07                	je     80130b <strfind+0x20>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  801304:	40                   	inc    %eax
  801305:	8a 10                	mov    (%eax),%dl
  801307:	84 d2                	test   %dl,%dl
  801309:	75 f5                	jne    801300 <strfind+0x15>
		if (*s == c)
			break;
	return (char *) s;
}
  80130b:	c9                   	leave  
  80130c:	c3                   	ret    

0080130d <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  80130d:	55                   	push   %ebp
  80130e:	89 e5                	mov    %esp,%ebp
  801310:	57                   	push   %edi
  801311:	56                   	push   %esi
  801312:	53                   	push   %ebx
  801313:	8b 7d 08             	mov    0x8(%ebp),%edi
  801316:	8b 45 0c             	mov    0xc(%ebp),%eax
  801319:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  80131c:	85 c9                	test   %ecx,%ecx
  80131e:	74 30                	je     801350 <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  801320:	f7 c7 03 00 00 00    	test   $0x3,%edi
  801326:	75 25                	jne    80134d <memset+0x40>
  801328:	f6 c1 03             	test   $0x3,%cl
  80132b:	75 20                	jne    80134d <memset+0x40>
		c &= 0xFF;
  80132d:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  801330:	89 d3                	mov    %edx,%ebx
  801332:	c1 e3 08             	shl    $0x8,%ebx
  801335:	89 d6                	mov    %edx,%esi
  801337:	c1 e6 18             	shl    $0x18,%esi
  80133a:	89 d0                	mov    %edx,%eax
  80133c:	c1 e0 10             	shl    $0x10,%eax
  80133f:	09 f0                	or     %esi,%eax
  801341:	09 d0                	or     %edx,%eax
  801343:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  801345:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  801348:	fc                   	cld    
  801349:	f3 ab                	rep stos %eax,%es:(%edi)
  80134b:	eb 03                	jmp    801350 <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  80134d:	fc                   	cld    
  80134e:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  801350:	89 f8                	mov    %edi,%eax
  801352:	5b                   	pop    %ebx
  801353:	5e                   	pop    %esi
  801354:	5f                   	pop    %edi
  801355:	c9                   	leave  
  801356:	c3                   	ret    

00801357 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  801357:	55                   	push   %ebp
  801358:	89 e5                	mov    %esp,%ebp
  80135a:	57                   	push   %edi
  80135b:	56                   	push   %esi
  80135c:	8b 45 08             	mov    0x8(%ebp),%eax
  80135f:	8b 75 0c             	mov    0xc(%ebp),%esi
  801362:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  801365:	39 c6                	cmp    %eax,%esi
  801367:	73 34                	jae    80139d <memmove+0x46>
  801369:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  80136c:	39 d0                	cmp    %edx,%eax
  80136e:	73 2d                	jae    80139d <memmove+0x46>
		s += n;
		d += n;
  801370:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801373:	f6 c2 03             	test   $0x3,%dl
  801376:	75 1b                	jne    801393 <memmove+0x3c>
  801378:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80137e:	75 13                	jne    801393 <memmove+0x3c>
  801380:	f6 c1 03             	test   $0x3,%cl
  801383:	75 0e                	jne    801393 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  801385:	83 ef 04             	sub    $0x4,%edi
  801388:	8d 72 fc             	lea    -0x4(%edx),%esi
  80138b:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  80138e:	fd                   	std    
  80138f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801391:	eb 07                	jmp    80139a <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  801393:	4f                   	dec    %edi
  801394:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  801397:	fd                   	std    
  801398:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  80139a:	fc                   	cld    
  80139b:	eb 20                	jmp    8013bd <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80139d:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8013a3:	75 13                	jne    8013b8 <memmove+0x61>
  8013a5:	a8 03                	test   $0x3,%al
  8013a7:	75 0f                	jne    8013b8 <memmove+0x61>
  8013a9:	f6 c1 03             	test   $0x3,%cl
  8013ac:	75 0a                	jne    8013b8 <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  8013ae:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  8013b1:	89 c7                	mov    %eax,%edi
  8013b3:	fc                   	cld    
  8013b4:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8013b6:	eb 05                	jmp    8013bd <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8013b8:	89 c7                	mov    %eax,%edi
  8013ba:	fc                   	cld    
  8013bb:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8013bd:	5e                   	pop    %esi
  8013be:	5f                   	pop    %edi
  8013bf:	c9                   	leave  
  8013c0:	c3                   	ret    

008013c1 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8013c1:	55                   	push   %ebp
  8013c2:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  8013c4:	ff 75 10             	pushl  0x10(%ebp)
  8013c7:	ff 75 0c             	pushl  0xc(%ebp)
  8013ca:	ff 75 08             	pushl  0x8(%ebp)
  8013cd:	e8 85 ff ff ff       	call   801357 <memmove>
}
  8013d2:	c9                   	leave  
  8013d3:	c3                   	ret    

008013d4 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8013d4:	55                   	push   %ebp
  8013d5:	89 e5                	mov    %esp,%ebp
  8013d7:	57                   	push   %edi
  8013d8:	56                   	push   %esi
  8013d9:	53                   	push   %ebx
  8013da:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8013dd:	8b 75 0c             	mov    0xc(%ebp),%esi
  8013e0:	8b 7d 10             	mov    0x10(%ebp),%edi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8013e3:	85 ff                	test   %edi,%edi
  8013e5:	74 32                	je     801419 <memcmp+0x45>
		if (*s1 != *s2)
  8013e7:	8a 03                	mov    (%ebx),%al
  8013e9:	8a 0e                	mov    (%esi),%cl
  8013eb:	38 c8                	cmp    %cl,%al
  8013ed:	74 19                	je     801408 <memcmp+0x34>
  8013ef:	eb 0d                	jmp    8013fe <memcmp+0x2a>
  8013f1:	8a 44 13 01          	mov    0x1(%ebx,%edx,1),%al
  8013f5:	8a 4c 16 01          	mov    0x1(%esi,%edx,1),%cl
  8013f9:	42                   	inc    %edx
  8013fa:	38 c8                	cmp    %cl,%al
  8013fc:	74 10                	je     80140e <memcmp+0x3a>
			return (int) *s1 - (int) *s2;
  8013fe:	0f b6 c0             	movzbl %al,%eax
  801401:	0f b6 c9             	movzbl %cl,%ecx
  801404:	29 c8                	sub    %ecx,%eax
  801406:	eb 16                	jmp    80141e <memcmp+0x4a>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801408:	4f                   	dec    %edi
  801409:	ba 00 00 00 00       	mov    $0x0,%edx
  80140e:	39 fa                	cmp    %edi,%edx
  801410:	75 df                	jne    8013f1 <memcmp+0x1d>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  801412:	b8 00 00 00 00       	mov    $0x0,%eax
  801417:	eb 05                	jmp    80141e <memcmp+0x4a>
  801419:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80141e:	5b                   	pop    %ebx
  80141f:	5e                   	pop    %esi
  801420:	5f                   	pop    %edi
  801421:	c9                   	leave  
  801422:	c3                   	ret    

00801423 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  801423:	55                   	push   %ebp
  801424:	89 e5                	mov    %esp,%ebp
  801426:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  801429:	89 c2                	mov    %eax,%edx
  80142b:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  80142e:	39 d0                	cmp    %edx,%eax
  801430:	73 12                	jae    801444 <memfind+0x21>
		if (*(const unsigned char *) s == (unsigned char) c)
  801432:	8a 4d 0c             	mov    0xc(%ebp),%cl
  801435:	38 08                	cmp    %cl,(%eax)
  801437:	75 06                	jne    80143f <memfind+0x1c>
  801439:	eb 09                	jmp    801444 <memfind+0x21>
  80143b:	38 08                	cmp    %cl,(%eax)
  80143d:	74 05                	je     801444 <memfind+0x21>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  80143f:	40                   	inc    %eax
  801440:	39 c2                	cmp    %eax,%edx
  801442:	77 f7                	ja     80143b <memfind+0x18>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  801444:	c9                   	leave  
  801445:	c3                   	ret    

00801446 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  801446:	55                   	push   %ebp
  801447:	89 e5                	mov    %esp,%ebp
  801449:	57                   	push   %edi
  80144a:	56                   	push   %esi
  80144b:	53                   	push   %ebx
  80144c:	8b 55 08             	mov    0x8(%ebp),%edx
  80144f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801452:	eb 01                	jmp    801455 <strtol+0xf>
		s++;
  801454:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801455:	8a 02                	mov    (%edx),%al
  801457:	3c 20                	cmp    $0x20,%al
  801459:	74 f9                	je     801454 <strtol+0xe>
  80145b:	3c 09                	cmp    $0x9,%al
  80145d:	74 f5                	je     801454 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  80145f:	3c 2b                	cmp    $0x2b,%al
  801461:	75 08                	jne    80146b <strtol+0x25>
		s++;
  801463:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  801464:	bf 00 00 00 00       	mov    $0x0,%edi
  801469:	eb 13                	jmp    80147e <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  80146b:	3c 2d                	cmp    $0x2d,%al
  80146d:	75 0a                	jne    801479 <strtol+0x33>
		s++, neg = 1;
  80146f:	8d 52 01             	lea    0x1(%edx),%edx
  801472:	bf 01 00 00 00       	mov    $0x1,%edi
  801477:	eb 05                	jmp    80147e <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  801479:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  80147e:	85 db                	test   %ebx,%ebx
  801480:	74 05                	je     801487 <strtol+0x41>
  801482:	83 fb 10             	cmp    $0x10,%ebx
  801485:	75 28                	jne    8014af <strtol+0x69>
  801487:	8a 02                	mov    (%edx),%al
  801489:	3c 30                	cmp    $0x30,%al
  80148b:	75 10                	jne    80149d <strtol+0x57>
  80148d:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  801491:	75 0a                	jne    80149d <strtol+0x57>
		s += 2, base = 16;
  801493:	83 c2 02             	add    $0x2,%edx
  801496:	bb 10 00 00 00       	mov    $0x10,%ebx
  80149b:	eb 12                	jmp    8014af <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  80149d:	85 db                	test   %ebx,%ebx
  80149f:	75 0e                	jne    8014af <strtol+0x69>
  8014a1:	3c 30                	cmp    $0x30,%al
  8014a3:	75 05                	jne    8014aa <strtol+0x64>
		s++, base = 8;
  8014a5:	42                   	inc    %edx
  8014a6:	b3 08                	mov    $0x8,%bl
  8014a8:	eb 05                	jmp    8014af <strtol+0x69>
	else if (base == 0)
		base = 10;
  8014aa:	bb 0a 00 00 00       	mov    $0xa,%ebx
  8014af:	b8 00 00 00 00       	mov    $0x0,%eax
  8014b4:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  8014b6:	8a 0a                	mov    (%edx),%cl
  8014b8:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  8014bb:	80 fb 09             	cmp    $0x9,%bl
  8014be:	77 08                	ja     8014c8 <strtol+0x82>
			dig = *s - '0';
  8014c0:	0f be c9             	movsbl %cl,%ecx
  8014c3:	83 e9 30             	sub    $0x30,%ecx
  8014c6:	eb 1e                	jmp    8014e6 <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  8014c8:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  8014cb:	80 fb 19             	cmp    $0x19,%bl
  8014ce:	77 08                	ja     8014d8 <strtol+0x92>
			dig = *s - 'a' + 10;
  8014d0:	0f be c9             	movsbl %cl,%ecx
  8014d3:	83 e9 57             	sub    $0x57,%ecx
  8014d6:	eb 0e                	jmp    8014e6 <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  8014d8:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  8014db:	80 fb 19             	cmp    $0x19,%bl
  8014de:	77 13                	ja     8014f3 <strtol+0xad>
			dig = *s - 'A' + 10;
  8014e0:	0f be c9             	movsbl %cl,%ecx
  8014e3:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  8014e6:	39 f1                	cmp    %esi,%ecx
  8014e8:	7d 0d                	jge    8014f7 <strtol+0xb1>
			break;
		s++, val = (val * base) + dig;
  8014ea:	42                   	inc    %edx
  8014eb:	0f af c6             	imul   %esi,%eax
  8014ee:	8d 04 01             	lea    (%ecx,%eax,1),%eax
		// we don't properly detect overflow!
	}
  8014f1:	eb c3                	jmp    8014b6 <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  8014f3:	89 c1                	mov    %eax,%ecx
  8014f5:	eb 02                	jmp    8014f9 <strtol+0xb3>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  8014f7:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  8014f9:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8014fd:	74 05                	je     801504 <strtol+0xbe>
		*endptr = (char *) s;
  8014ff:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801502:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  801504:	85 ff                	test   %edi,%edi
  801506:	74 04                	je     80150c <strtol+0xc6>
  801508:	89 c8                	mov    %ecx,%eax
  80150a:	f7 d8                	neg    %eax
}
  80150c:	5b                   	pop    %ebx
  80150d:	5e                   	pop    %esi
  80150e:	5f                   	pop    %edi
  80150f:	c9                   	leave  
  801510:	c3                   	ret    
  801511:	00 00                	add    %al,(%eax)
	...

00801514 <syscall>:
	return ret;
}

static int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  801514:	55                   	push   %ebp
  801515:	89 e5                	mov    %esp,%ebp
  801517:	57                   	push   %edi
  801518:	56                   	push   %esi
  801519:	53                   	push   %ebx
  80151a:	83 ec 1c             	sub    $0x1c,%esp
  80151d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801520:	89 55 e0             	mov    %edx,-0x20(%ebp)
  801523:	89 ca                	mov    %ecx,%edx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801525:	8b 75 14             	mov    0x14(%ebp),%esi
  801528:	8b 7d 10             	mov    0x10(%ebp),%edi
  80152b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80152e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801531:	cd 30                	int    $0x30
  801533:	89 c2                	mov    %eax,%edx
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  801535:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  801539:	74 1c                	je     801557 <syscall+0x43>
  80153b:	85 c0                	test   %eax,%eax
  80153d:	7e 18                	jle    801557 <syscall+0x43>
		panic("syscall %d returned %d (> 0)", num, ret);
  80153f:	83 ec 0c             	sub    $0xc,%esp
  801542:	50                   	push   %eax
  801543:	ff 75 e4             	pushl  -0x1c(%ebp)
  801546:	68 6f 38 80 00       	push   $0x80386f
  80154b:	6a 42                	push   $0x42
  80154d:	68 8c 38 80 00       	push   $0x80388c
  801552:	e8 cd f4 ff ff       	call   800a24 <_panic>

	return ret;
}
  801557:	89 d0                	mov    %edx,%eax
  801559:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80155c:	5b                   	pop    %ebx
  80155d:	5e                   	pop    %esi
  80155e:	5f                   	pop    %edi
  80155f:	c9                   	leave  
  801560:	c3                   	ret    

00801561 <sys_cputs>:

void
sys_cputs(const char *s, size_t len)
{	
  801561:	55                   	push   %ebp
  801562:	89 e5                	mov    %esp,%ebp
  801564:	83 ec 08             	sub    $0x8,%esp
	// my_sysenter(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
	// return;
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
  801567:	6a 00                	push   $0x0
  801569:	6a 00                	push   $0x0
  80156b:	6a 00                	push   $0x0
  80156d:	ff 75 0c             	pushl  0xc(%ebp)
  801570:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801573:	ba 00 00 00 00       	mov    $0x0,%edx
  801578:	b8 00 00 00 00       	mov    $0x0,%eax
  80157d:	e8 92 ff ff ff       	call   801514 <syscall>
  801582:	83 c4 10             	add    $0x10,%esp
	return;
}
  801585:	c9                   	leave  
  801586:	c3                   	ret    

00801587 <sys_cgetc>:

int
sys_cgetc(void)
{
  801587:	55                   	push   %ebp
  801588:	89 e5                	mov    %esp,%ebp
  80158a:	83 ec 08             	sub    $0x8,%esp
	// return my_sysenter(SYS_cgetc, 0, 0, 0, 0, 0, 0);
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
  80158d:	6a 00                	push   $0x0
  80158f:	6a 00                	push   $0x0
  801591:	6a 00                	push   $0x0
  801593:	6a 00                	push   $0x0
  801595:	b9 00 00 00 00       	mov    $0x0,%ecx
  80159a:	ba 00 00 00 00       	mov    $0x0,%edx
  80159f:	b8 01 00 00 00       	mov    $0x1,%eax
  8015a4:	e8 6b ff ff ff       	call   801514 <syscall>
}
  8015a9:	c9                   	leave  
  8015aa:	c3                   	ret    

008015ab <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8015ab:	55                   	push   %ebp
  8015ac:	89 e5                	mov    %esp,%ebp
  8015ae:	83 ec 08             	sub    $0x8,%esp
	// return my_sysenter(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
  8015b1:	6a 00                	push   $0x0
  8015b3:	6a 00                	push   $0x0
  8015b5:	6a 00                	push   $0x0
  8015b7:	6a 00                	push   $0x0
  8015b9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8015bc:	ba 01 00 00 00       	mov    $0x1,%edx
  8015c1:	b8 03 00 00 00       	mov    $0x3,%eax
  8015c6:	e8 49 ff ff ff       	call   801514 <syscall>
}
  8015cb:	c9                   	leave  
  8015cc:	c3                   	ret    

008015cd <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  8015cd:	55                   	push   %ebp
  8015ce:	89 e5                	mov    %esp,%ebp
  8015d0:	83 ec 08             	sub    $0x8,%esp
	// return my_sysenter(SYS_getenvid, 0, 0, 0, 0, 0, 0);
	return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
  8015d3:	6a 00                	push   $0x0
  8015d5:	6a 00                	push   $0x0
  8015d7:	6a 00                	push   $0x0
  8015d9:	6a 00                	push   $0x0
  8015db:	b9 00 00 00 00       	mov    $0x0,%ecx
  8015e0:	ba 00 00 00 00       	mov    $0x0,%edx
  8015e5:	b8 02 00 00 00       	mov    $0x2,%eax
  8015ea:	e8 25 ff ff ff       	call   801514 <syscall>
}
  8015ef:	c9                   	leave  
  8015f0:	c3                   	ret    

008015f1 <sys_yield>:

void
sys_yield(void)
{
  8015f1:	55                   	push   %ebp
  8015f2:	89 e5                	mov    %esp,%ebp
  8015f4:	83 ec 08             	sub    $0x8,%esp
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
  8015f7:	6a 00                	push   $0x0
  8015f9:	6a 00                	push   $0x0
  8015fb:	6a 00                	push   $0x0
  8015fd:	6a 00                	push   $0x0
  8015ff:	b9 00 00 00 00       	mov    $0x0,%ecx
  801604:	ba 00 00 00 00       	mov    $0x0,%edx
  801609:	b8 0b 00 00 00       	mov    $0xb,%eax
  80160e:	e8 01 ff ff ff       	call   801514 <syscall>
  801613:	83 c4 10             	add    $0x10,%esp
}
  801616:	c9                   	leave  
  801617:	c3                   	ret    

00801618 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  801618:	55                   	push   %ebp
  801619:	89 e5                	mov    %esp,%ebp
  80161b:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
  80161e:	6a 00                	push   $0x0
  801620:	6a 00                	push   $0x0
  801622:	ff 75 10             	pushl  0x10(%ebp)
  801625:	ff 75 0c             	pushl  0xc(%ebp)
  801628:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80162b:	ba 01 00 00 00       	mov    $0x1,%edx
  801630:	b8 04 00 00 00       	mov    $0x4,%eax
  801635:	e8 da fe ff ff       	call   801514 <syscall>
}
  80163a:	c9                   	leave  
  80163b:	c3                   	ret    

0080163c <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  80163c:	55                   	push   %ebp
  80163d:	89 e5                	mov    %esp,%ebp
  80163f:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
  801642:	ff 75 18             	pushl  0x18(%ebp)
  801645:	ff 75 14             	pushl  0x14(%ebp)
  801648:	ff 75 10             	pushl  0x10(%ebp)
  80164b:	ff 75 0c             	pushl  0xc(%ebp)
  80164e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801651:	ba 01 00 00 00       	mov    $0x1,%edx
  801656:	b8 05 00 00 00       	mov    $0x5,%eax
  80165b:	e8 b4 fe ff ff       	call   801514 <syscall>
}
  801660:	c9                   	leave  
  801661:	c3                   	ret    

00801662 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  801662:	55                   	push   %ebp
  801663:	89 e5                	mov    %esp,%ebp
  801665:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
  801668:	6a 00                	push   $0x0
  80166a:	6a 00                	push   $0x0
  80166c:	6a 00                	push   $0x0
  80166e:	ff 75 0c             	pushl  0xc(%ebp)
  801671:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801674:	ba 01 00 00 00       	mov    $0x1,%edx
  801679:	b8 06 00 00 00       	mov    $0x6,%eax
  80167e:	e8 91 fe ff ff       	call   801514 <syscall>
}
  801683:	c9                   	leave  
  801684:	c3                   	ret    

00801685 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  801685:	55                   	push   %ebp
  801686:	89 e5                	mov    %esp,%ebp
  801688:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
  80168b:	6a 00                	push   $0x0
  80168d:	6a 00                	push   $0x0
  80168f:	6a 00                	push   $0x0
  801691:	ff 75 0c             	pushl  0xc(%ebp)
  801694:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801697:	ba 01 00 00 00       	mov    $0x1,%edx
  80169c:	b8 08 00 00 00       	mov    $0x8,%eax
  8016a1:	e8 6e fe ff ff       	call   801514 <syscall>
}
  8016a6:	c9                   	leave  
  8016a7:	c3                   	ret    

008016a8 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  8016a8:	55                   	push   %ebp
  8016a9:	89 e5                	mov    %esp,%ebp
  8016ab:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
  8016ae:	6a 00                	push   $0x0
  8016b0:	6a 00                	push   $0x0
  8016b2:	6a 00                	push   $0x0
  8016b4:	ff 75 0c             	pushl  0xc(%ebp)
  8016b7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8016ba:	ba 01 00 00 00       	mov    $0x1,%edx
  8016bf:	b8 09 00 00 00       	mov    $0x9,%eax
  8016c4:	e8 4b fe ff ff       	call   801514 <syscall>
}
  8016c9:	c9                   	leave  
  8016ca:	c3                   	ret    

008016cb <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8016cb:	55                   	push   %ebp
  8016cc:	89 e5                	mov    %esp,%ebp
  8016ce:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
  8016d1:	6a 00                	push   $0x0
  8016d3:	6a 00                	push   $0x0
  8016d5:	6a 00                	push   $0x0
  8016d7:	ff 75 0c             	pushl  0xc(%ebp)
  8016da:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8016dd:	ba 01 00 00 00       	mov    $0x1,%edx
  8016e2:	b8 0a 00 00 00       	mov    $0xa,%eax
  8016e7:	e8 28 fe ff ff       	call   801514 <syscall>
}
  8016ec:	c9                   	leave  
  8016ed:	c3                   	ret    

008016ee <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8016ee:	55                   	push   %ebp
  8016ef:	89 e5                	mov    %esp,%ebp
  8016f1:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
  8016f4:	6a 00                	push   $0x0
  8016f6:	ff 75 14             	pushl  0x14(%ebp)
  8016f9:	ff 75 10             	pushl  0x10(%ebp)
  8016fc:	ff 75 0c             	pushl  0xc(%ebp)
  8016ff:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801702:	ba 00 00 00 00       	mov    $0x0,%edx
  801707:	b8 0c 00 00 00       	mov    $0xc,%eax
  80170c:	e8 03 fe ff ff       	call   801514 <syscall>
}
  801711:	c9                   	leave  
  801712:	c3                   	ret    

00801713 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  801713:	55                   	push   %ebp
  801714:	89 e5                	mov    %esp,%ebp
  801716:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
  801719:	6a 00                	push   $0x0
  80171b:	6a 00                	push   $0x0
  80171d:	6a 00                	push   $0x0
  80171f:	6a 00                	push   $0x0
  801721:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801724:	ba 01 00 00 00       	mov    $0x1,%edx
  801729:	b8 0d 00 00 00       	mov    $0xd,%eax
  80172e:	e8 e1 fd ff ff       	call   801514 <syscall>
}
  801733:	c9                   	leave  
  801734:	c3                   	ret    

00801735 <sys_set_priority>:

int
sys_set_priority(envid_t envid, uint32_t new_priority)
{
  801735:	55                   	push   %ebp
  801736:	89 e5                	mov    %esp,%ebp
  801738:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_set_priority, 0, envid, new_priority, 0, 0, 0);
  80173b:	6a 00                	push   $0x0
  80173d:	6a 00                	push   $0x0
  80173f:	6a 00                	push   $0x0
  801741:	ff 75 0c             	pushl  0xc(%ebp)
  801744:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801747:	ba 00 00 00 00       	mov    $0x0,%edx
  80174c:	b8 0e 00 00 00       	mov    $0xe,%eax
  801751:	e8 be fd ff ff       	call   801514 <syscall>
}
  801756:	c9                   	leave  
  801757:	c3                   	ret    

00801758 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  801758:	55                   	push   %ebp
  801759:	89 e5                	mov    %esp,%ebp
  80175b:	53                   	push   %ebx
  80175c:	83 ec 04             	sub    $0x4,%esp
  80175f:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  801762:	8b 18                	mov    (%eax),%ebx

	// LAB 4: Your code here.
	
	// cprintf("PAGE FAULT HANDLER, 0x%08x %d\n", (uint32_t)addr, err & FEC_WR);
	
	if ((err & FEC_WR) == 0)
  801764:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  801768:	75 14                	jne    80177e <pgfault+0x26>
		panic("pgfault, the fault is not a write\n");
  80176a:	83 ec 04             	sub    $0x4,%esp
  80176d:	68 9c 38 80 00       	push   $0x80389c
  801772:	6a 20                	push   $0x20
  801774:	68 e0 39 80 00       	push   $0x8039e0
  801779:	e8 a6 f2 ff ff       	call   800a24 <_panic>

	uint32_t uaddr = (uint32_t) addr;
	if ((uvpd[PDX(addr)] & PTE_P) == 0 || (uvpt[uaddr / PGSIZE] & PTE_COW) == 0) {
  80177e:	89 d8                	mov    %ebx,%eax
  801780:	c1 e8 16             	shr    $0x16,%eax
  801783:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80178a:	a8 01                	test   $0x1,%al
  80178c:	74 11                	je     80179f <pgfault+0x47>
  80178e:	89 d8                	mov    %ebx,%eax
  801790:	c1 e8 0c             	shr    $0xc,%eax
  801793:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80179a:	f6 c4 08             	test   $0x8,%ah
  80179d:	75 14                	jne    8017b3 <pgfault+0x5b>
		panic("pgfault, not a copy-on-write page\n");
  80179f:	83 ec 04             	sub    $0x4,%esp
  8017a2:	68 c0 38 80 00       	push   $0x8038c0
  8017a7:	6a 24                	push   $0x24
  8017a9:	68 e0 39 80 00       	push   $0x8039e0
  8017ae:	e8 71 f2 ff ff       	call   800a24 <_panic>
	//   No need to explicitly delete the old page's mapping.

	// LAB 4: Your code here.

	// static int sys_page_alloc(envid_t envid, void *va, int perm)
	r = sys_page_alloc(0, (void *)PFTEMP, PTE_W | PTE_U | PTE_P);
  8017b3:	83 ec 04             	sub    $0x4,%esp
  8017b6:	6a 07                	push   $0x7
  8017b8:	68 00 f0 7f 00       	push   $0x7ff000
  8017bd:	6a 00                	push   $0x0
  8017bf:	e8 54 fe ff ff       	call   801618 <sys_page_alloc>
	if (r < 0) panic("pgfault, sys_page_alloc error : %e\n", r);
  8017c4:	83 c4 10             	add    $0x10,%esp
  8017c7:	85 c0                	test   %eax,%eax
  8017c9:	79 12                	jns    8017dd <pgfault+0x85>
  8017cb:	50                   	push   %eax
  8017cc:	68 e4 38 80 00       	push   $0x8038e4
  8017d1:	6a 32                	push   $0x32
  8017d3:	68 e0 39 80 00       	push   $0x8039e0
  8017d8:	e8 47 f2 ff ff       	call   800a24 <_panic>

	// Oh my god, I forget this at the first, it waste me a lot of time to debug!!!
	addr = ROUNDDOWN(addr, PGSIZE);
  8017dd:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	
	memcpy(PFTEMP, addr, PGSIZE);
  8017e3:	83 ec 04             	sub    $0x4,%esp
  8017e6:	68 00 10 00 00       	push   $0x1000
  8017eb:	53                   	push   %ebx
  8017ec:	68 00 f0 7f 00       	push   $0x7ff000
  8017f1:	e8 cb fb ff ff       	call   8013c1 <memcpy>
	
	r = sys_page_map(0, PFTEMP, 0, addr, PTE_W | PTE_U | PTE_P);
  8017f6:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  8017fd:	53                   	push   %ebx
  8017fe:	6a 00                	push   $0x0
  801800:	68 00 f0 7f 00       	push   $0x7ff000
  801805:	6a 00                	push   $0x0
  801807:	e8 30 fe ff ff       	call   80163c <sys_page_map>
	if (r < 0) panic("pgfault, sys_page_map error : %e\n", r);
  80180c:	83 c4 20             	add    $0x20,%esp
  80180f:	85 c0                	test   %eax,%eax
  801811:	79 12                	jns    801825 <pgfault+0xcd>
  801813:	50                   	push   %eax
  801814:	68 08 39 80 00       	push   $0x803908
  801819:	6a 3a                	push   $0x3a
  80181b:	68 e0 39 80 00       	push   $0x8039e0
  801820:	e8 ff f1 ff ff       	call   800a24 <_panic>

	return;
}
  801825:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801828:	c9                   	leave  
  801829:	c3                   	ret    

0080182a <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  80182a:	55                   	push   %ebp
  80182b:	89 e5                	mov    %esp,%ebp
  80182d:	57                   	push   %edi
  80182e:	56                   	push   %esi
  80182f:	53                   	push   %ebx
  801830:	83 ec 28             	sub    $0x28,%esp
	// static int num = 0x100;

	// LAB 4: Your code here.
	set_pgfault_handler(pgfault);
  801833:	68 58 17 80 00       	push   $0x801758
  801838:	e8 8b 16 00 00       	call   802ec8 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  80183d:	ba 07 00 00 00       	mov    $0x7,%edx
  801842:	89 d0                	mov    %edx,%eax
  801844:	cd 30                	int    $0x30
  801846:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801849:	89 c7                	mov    %eax,%edi
	int childpid = sys_exofork();
	if (childpid < 0) {
  80184b:	83 c4 10             	add    $0x10,%esp
  80184e:	85 c0                	test   %eax,%eax
  801850:	79 12                	jns    801864 <fork+0x3a>
		panic("fork sys_exofork error : %e\n", childpid);
  801852:	50                   	push   %eax
  801853:	68 eb 39 80 00       	push   $0x8039eb
  801858:	6a 7f                	push   $0x7f
  80185a:	68 e0 39 80 00       	push   $0x8039e0
  80185f:	e8 c0 f1 ff ff       	call   800a24 <_panic>
	}
	int r;

	if (childpid == 0) {
  801864:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  801868:	75 25                	jne    80188f <fork+0x65>
		// child process
		// Remember to fix "thisenv" in the child process. ??? 
		thisenv = &envs[ENVX(sys_getenvid())];
  80186a:	e8 5e fd ff ff       	call   8015cd <sys_getenvid>
  80186f:	25 ff 03 00 00       	and    $0x3ff,%eax
  801874:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  80187b:	c1 e0 07             	shl    $0x7,%eax
  80187e:	29 d0                	sub    %edx,%eax
  801880:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801885:	a3 24 54 80 00       	mov    %eax,0x805424
		// cprintf("fork child ok\n");
		return 0;
  80188a:	e9 be 01 00 00       	jmp    801a4d <fork+0x223>
	if (childpid < 0) {
		panic("fork sys_exofork error : %e\n", childpid);
	}
	int r;

	if (childpid == 0) {
  80188f:	bb 00 00 00 00       	mov    $0x0,%ebx
	} else {
		// map page to new environment
		// kernel page is already in new environment
		uint32_t i;
		for (i = 0; i != UTOP; i += PGSIZE) 
		if ((uvpd[PDX(i)] & PTE_P) && (uvpt[i / PGSIZE] & PTE_P) && (uvpt[i / PGSIZE] & PTE_U)) {
  801894:	89 d8                	mov    %ebx,%eax
  801896:	c1 e8 16             	shr    $0x16,%eax
  801899:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8018a0:	a8 01                	test   $0x1,%al
  8018a2:	0f 84 10 01 00 00    	je     8019b8 <fork+0x18e>
  8018a8:	89 d8                	mov    %ebx,%eax
  8018aa:	c1 e8 0c             	shr    $0xc,%eax
  8018ad:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8018b4:	f6 c2 01             	test   $0x1,%dl
  8018b7:	0f 84 fb 00 00 00    	je     8019b8 <fork+0x18e>
  8018bd:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8018c4:	f6 c2 04             	test   $0x4,%dl
  8018c7:	0f 84 eb 00 00 00    	je     8019b8 <fork+0x18e>
//
static int
duppage(envid_t envid, unsigned pn)
{
	// do not dup exception stack
	if (pn * PGSIZE == UXSTACKTOP - PGSIZE) return 0;
  8018cd:	89 c6                	mov    %eax,%esi
  8018cf:	c1 e6 0c             	shl    $0xc,%esi
  8018d2:	81 fe 00 f0 bf ee    	cmp    $0xeebff000,%esi
  8018d8:	0f 84 da 00 00 00    	je     8019b8 <fork+0x18e>

	int r;
	void * addr = (void *)(pn * PGSIZE);
    if (uvpt[pn] & PTE_SHARE) {
  8018de:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8018e5:	f6 c6 04             	test   $0x4,%dh
  8018e8:	74 37                	je     801921 <fork+0xf7>
        r = sys_page_map(0, addr, envid, addr, uvpt[pn] & PTE_SYSCALL);
  8018ea:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8018f1:	83 ec 0c             	sub    $0xc,%esp
  8018f4:	25 07 0e 00 00       	and    $0xe07,%eax
  8018f9:	50                   	push   %eax
  8018fa:	56                   	push   %esi
  8018fb:	57                   	push   %edi
  8018fc:	56                   	push   %esi
  8018fd:	6a 00                	push   $0x0
  8018ff:	e8 38 fd ff ff       	call   80163c <sys_page_map>
        if (r < 0) panic("duppage sys_page_map error : %e\n", r);
  801904:	83 c4 20             	add    $0x20,%esp
  801907:	85 c0                	test   %eax,%eax
  801909:	0f 89 a9 00 00 00    	jns    8019b8 <fork+0x18e>
  80190f:	50                   	push   %eax
  801910:	68 2c 39 80 00       	push   $0x80392c
  801915:	6a 54                	push   $0x54
  801917:	68 e0 39 80 00       	push   $0x8039e0
  80191c:	e8 03 f1 ff ff       	call   800a24 <_panic>
    } else
	if ((uvpt[pn] & PTE_W) || (uvpt[pn] & PTE_COW)) {
  801921:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801928:	f6 c2 02             	test   $0x2,%dl
  80192b:	75 0c                	jne    801939 <fork+0x10f>
  80192d:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801934:	f6 c4 08             	test   $0x8,%ah
  801937:	74 57                	je     801990 <fork+0x166>
		// cow
		r = sys_page_map(0, addr, envid, addr, PTE_COW | PTE_P | PTE_U);
  801939:	83 ec 0c             	sub    $0xc,%esp
  80193c:	68 05 08 00 00       	push   $0x805
  801941:	56                   	push   %esi
  801942:	57                   	push   %edi
  801943:	56                   	push   %esi
  801944:	6a 00                	push   $0x0
  801946:	e8 f1 fc ff ff       	call   80163c <sys_page_map>
		if (r < 0) panic("duppage sys_page_map error : %e\n", r);
  80194b:	83 c4 20             	add    $0x20,%esp
  80194e:	85 c0                	test   %eax,%eax
  801950:	79 12                	jns    801964 <fork+0x13a>
  801952:	50                   	push   %eax
  801953:	68 2c 39 80 00       	push   $0x80392c
  801958:	6a 59                	push   $0x59
  80195a:	68 e0 39 80 00       	push   $0x8039e0
  80195f:	e8 c0 f0 ff ff       	call   800a24 <_panic>
		
		r = sys_page_map(0, addr, 0, addr, PTE_COW | PTE_P | PTE_U);
  801964:	83 ec 0c             	sub    $0xc,%esp
  801967:	68 05 08 00 00       	push   $0x805
  80196c:	56                   	push   %esi
  80196d:	6a 00                	push   $0x0
  80196f:	56                   	push   %esi
  801970:	6a 00                	push   $0x0
  801972:	e8 c5 fc ff ff       	call   80163c <sys_page_map>
		if (r < 0) panic("duppage sys_page_map error : %e\n", r);
  801977:	83 c4 20             	add    $0x20,%esp
  80197a:	85 c0                	test   %eax,%eax
  80197c:	79 3a                	jns    8019b8 <fork+0x18e>
  80197e:	50                   	push   %eax
  80197f:	68 2c 39 80 00       	push   $0x80392c
  801984:	6a 5c                	push   $0x5c
  801986:	68 e0 39 80 00       	push   $0x8039e0
  80198b:	e8 94 f0 ff ff       	call   800a24 <_panic>
	} else {
		// read only
		r = sys_page_map(0, addr, envid, addr, PTE_P | PTE_U);
  801990:	83 ec 0c             	sub    $0xc,%esp
  801993:	6a 05                	push   $0x5
  801995:	56                   	push   %esi
  801996:	57                   	push   %edi
  801997:	56                   	push   %esi
  801998:	6a 00                	push   $0x0
  80199a:	e8 9d fc ff ff       	call   80163c <sys_page_map>
		if (r < 0) panic("duppage sys_page_map error : %e\n", r);
  80199f:	83 c4 20             	add    $0x20,%esp
  8019a2:	85 c0                	test   %eax,%eax
  8019a4:	79 12                	jns    8019b8 <fork+0x18e>
  8019a6:	50                   	push   %eax
  8019a7:	68 2c 39 80 00       	push   $0x80392c
  8019ac:	6a 60                	push   $0x60
  8019ae:	68 e0 39 80 00       	push   $0x8039e0
  8019b3:	e8 6c f0 ff ff       	call   800a24 <_panic>
		return 0;
	} else {
		// map page to new environment
		// kernel page is already in new environment
		uint32_t i;
		for (i = 0; i != UTOP; i += PGSIZE) 
  8019b8:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  8019be:	81 fb 00 00 c0 ee    	cmp    $0xeec00000,%ebx
  8019c4:	0f 85 ca fe ff ff    	jne    801894 <fork+0x6a>
		if ((uvpd[PDX(i)] & PTE_P) && (uvpt[i / PGSIZE] & PTE_P) && (uvpt[i / PGSIZE] & PTE_U)) {
			duppage(childpid, i / PGSIZE);
		}

		// allocate exception stack
		r = sys_page_alloc(childpid, (void *)(UXSTACKTOP - PGSIZE), PTE_U | PTE_W | PTE_P);
  8019ca:	83 ec 04             	sub    $0x4,%esp
  8019cd:	6a 07                	push   $0x7
  8019cf:	68 00 f0 bf ee       	push   $0xeebff000
  8019d4:	ff 75 e4             	pushl  -0x1c(%ebp)
  8019d7:	e8 3c fc ff ff       	call   801618 <sys_page_alloc>
		if (r < 0) panic("fork, sys_page_alloc user exception stack error : %e\n", r);
  8019dc:	83 c4 10             	add    $0x10,%esp
  8019df:	85 c0                	test   %eax,%eax
  8019e1:	79 15                	jns    8019f8 <fork+0x1ce>
  8019e3:	50                   	push   %eax
  8019e4:	68 50 39 80 00       	push   $0x803950
  8019e9:	68 94 00 00 00       	push   $0x94
  8019ee:	68 e0 39 80 00       	push   $0x8039e0
  8019f3:	e8 2c f0 ff ff       	call   800a24 <_panic>

		// set user environment user page fault handler 
		extern void _pgfault_upcall(void);
		r = sys_env_set_pgfault_upcall(childpid, _pgfault_upcall);
  8019f8:	83 ec 08             	sub    $0x8,%esp
  8019fb:	68 34 2f 80 00       	push   $0x802f34
  801a00:	ff 75 e4             	pushl  -0x1c(%ebp)
  801a03:	e8 c3 fc ff ff       	call   8016cb <sys_env_set_pgfault_upcall>
		if (r < 0) panic("fork, set pgfault upcall fail : %e\n", r);
  801a08:	83 c4 10             	add    $0x10,%esp
  801a0b:	85 c0                	test   %eax,%eax
  801a0d:	79 15                	jns    801a24 <fork+0x1fa>
  801a0f:	50                   	push   %eax
  801a10:	68 88 39 80 00       	push   $0x803988
  801a15:	68 99 00 00 00       	push   $0x99
  801a1a:	68 e0 39 80 00       	push   $0x8039e0
  801a1f:	e8 00 f0 ff ff       	call   800a24 <_panic>
		r = sys_set_priority(childpid, num);
		if (r < 0) panic("fork, set priority error\n");
		*/

		// mark the child as runnable and return
		r = sys_env_set_status(childpid, ENV_RUNNABLE);
  801a24:	83 ec 08             	sub    $0x8,%esp
  801a27:	6a 02                	push   $0x2
  801a29:	ff 75 e4             	pushl  -0x1c(%ebp)
  801a2c:	e8 54 fc ff ff       	call   801685 <sys_env_set_status>
		if (r < 0) panic("fork, set child process to ENV_RUNNABLE error : %e\n", r);
  801a31:	83 c4 10             	add    $0x10,%esp
  801a34:	85 c0                	test   %eax,%eax
  801a36:	79 15                	jns    801a4d <fork+0x223>
  801a38:	50                   	push   %eax
  801a39:	68 ac 39 80 00       	push   $0x8039ac
  801a3e:	68 a4 00 00 00       	push   $0xa4
  801a43:	68 e0 39 80 00       	push   $0x8039e0
  801a48:	e8 d7 ef ff ff       	call   800a24 <_panic>
		// cprintf("fork father ok!")
		return childpid;
	}

	panic("fork not implemented");
}
  801a4d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801a50:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801a53:	5b                   	pop    %ebx
  801a54:	5e                   	pop    %esi
  801a55:	5f                   	pop    %edi
  801a56:	c9                   	leave  
  801a57:	c3                   	ret    

00801a58 <sfork>:

// Challenge!
int
sfork(void)
{
  801a58:	55                   	push   %ebp
  801a59:	89 e5                	mov    %esp,%ebp
  801a5b:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  801a5e:	68 08 3a 80 00       	push   $0x803a08
  801a63:	68 b1 00 00 00       	push   $0xb1
  801a68:	68 e0 39 80 00       	push   $0x8039e0
  801a6d:	e8 b2 ef ff ff       	call   800a24 <_panic>
	...

00801a74 <argstart>:
#include <inc/args.h>
#include <inc/string.h>

void
argstart(int *argc, char **argv, struct Argstate *args)
{
  801a74:	55                   	push   %ebp
  801a75:	89 e5                	mov    %esp,%ebp
  801a77:	8b 55 08             	mov    0x8(%ebp),%edx
  801a7a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801a7d:	8b 45 10             	mov    0x10(%ebp),%eax
	args->argc = argc;
  801a80:	89 10                	mov    %edx,(%eax)
	args->argv = (const char **) argv;
  801a82:	89 48 04             	mov    %ecx,0x4(%eax)
	args->curarg = (*argc > 1 && argv ? "" : 0);
  801a85:	83 3a 01             	cmpl   $0x1,(%edx)
  801a88:	7e 0b                	jle    801a95 <argstart+0x21>
  801a8a:	85 c9                	test   %ecx,%ecx
  801a8c:	75 0e                	jne    801a9c <argstart+0x28>
  801a8e:	ba 00 00 00 00       	mov    $0x0,%edx
  801a93:	eb 0c                	jmp    801aa1 <argstart+0x2d>
  801a95:	ba 00 00 00 00       	mov    $0x0,%edx
  801a9a:	eb 05                	jmp    801aa1 <argstart+0x2d>
  801a9c:	ba 41 33 80 00       	mov    $0x803341,%edx
  801aa1:	89 50 08             	mov    %edx,0x8(%eax)
	args->argvalue = 0;
  801aa4:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
}
  801aab:	c9                   	leave  
  801aac:	c3                   	ret    

00801aad <argnext>:

int
argnext(struct Argstate *args)
{
  801aad:	55                   	push   %ebp
  801aae:	89 e5                	mov    %esp,%ebp
  801ab0:	57                   	push   %edi
  801ab1:	56                   	push   %esi
  801ab2:	53                   	push   %ebx
  801ab3:	83 ec 0c             	sub    $0xc,%esp
  801ab6:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int arg;

	args->argvalue = 0;
  801ab9:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)

	// Done processing arguments if args->curarg == 0
	if (args->curarg == 0)
  801ac0:	8b 43 08             	mov    0x8(%ebx),%eax
  801ac3:	85 c0                	test   %eax,%eax
  801ac5:	74 6c                	je     801b33 <argnext+0x86>
		return -1;

	if (!*args->curarg) {
  801ac7:	80 38 00             	cmpb   $0x0,(%eax)
  801aca:	75 4d                	jne    801b19 <argnext+0x6c>
		// Need to process the next argument
		// Check for end of argument list
		if (*args->argc == 1
  801acc:	8b 0b                	mov    (%ebx),%ecx
  801ace:	83 39 01             	cmpl   $0x1,(%ecx)
  801ad1:	74 52                	je     801b25 <argnext+0x78>
		    || args->argv[1][0] != '-'
  801ad3:	8b 43 04             	mov    0x4(%ebx),%eax
  801ad6:	8d 70 04             	lea    0x4(%eax),%esi
  801ad9:	8b 50 04             	mov    0x4(%eax),%edx
  801adc:	80 3a 2d             	cmpb   $0x2d,(%edx)
  801adf:	75 44                	jne    801b25 <argnext+0x78>
		    || args->argv[1][1] == '\0')
  801ae1:	8d 7a 01             	lea    0x1(%edx),%edi
  801ae4:	80 7a 01 00          	cmpb   $0x0,0x1(%edx)
  801ae8:	74 3b                	je     801b25 <argnext+0x78>
			goto endofargs;
		// Shift arguments down one
		args->curarg = args->argv[1] + 1;
  801aea:	89 7b 08             	mov    %edi,0x8(%ebx)
		memmove(args->argv + 1, args->argv + 2, sizeof(const char *) * (*args->argc - 1));
  801aed:	83 ec 04             	sub    $0x4,%esp
  801af0:	8b 11                	mov    (%ecx),%edx
  801af2:	8d 14 95 fc ff ff ff 	lea    -0x4(,%edx,4),%edx
  801af9:	52                   	push   %edx
  801afa:	83 c0 08             	add    $0x8,%eax
  801afd:	50                   	push   %eax
  801afe:	56                   	push   %esi
  801aff:	e8 53 f8 ff ff       	call   801357 <memmove>
		(*args->argc)--;
  801b04:	8b 03                	mov    (%ebx),%eax
  801b06:	ff 08                	decl   (%eax)
		// Check for "--": end of argument list
		if (args->curarg[0] == '-' && args->curarg[1] == '\0')
  801b08:	8b 43 08             	mov    0x8(%ebx),%eax
  801b0b:	83 c4 10             	add    $0x10,%esp
  801b0e:	80 38 2d             	cmpb   $0x2d,(%eax)
  801b11:	75 06                	jne    801b19 <argnext+0x6c>
  801b13:	80 78 01 00          	cmpb   $0x0,0x1(%eax)
  801b17:	74 0c                	je     801b25 <argnext+0x78>
			goto endofargs;
	}

	arg = (unsigned char) *args->curarg;
  801b19:	8b 53 08             	mov    0x8(%ebx),%edx
  801b1c:	0f b6 02             	movzbl (%edx),%eax
	args->curarg++;
  801b1f:	42                   	inc    %edx
  801b20:	89 53 08             	mov    %edx,0x8(%ebx)
	return arg;
  801b23:	eb 13                	jmp    801b38 <argnext+0x8b>

    endofargs:
	args->curarg = 0;
  801b25:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
	return -1;
  801b2c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  801b31:	eb 05                	jmp    801b38 <argnext+0x8b>

	args->argvalue = 0;

	// Done processing arguments if args->curarg == 0
	if (args->curarg == 0)
		return -1;
  801b33:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	return arg;

    endofargs:
	args->curarg = 0;
	return -1;
}
  801b38:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b3b:	5b                   	pop    %ebx
  801b3c:	5e                   	pop    %esi
  801b3d:	5f                   	pop    %edi
  801b3e:	c9                   	leave  
  801b3f:	c3                   	ret    

00801b40 <argnextvalue>:
	return (char*) (args->argvalue ? args->argvalue : argnextvalue(args));
}

char *
argnextvalue(struct Argstate *args)
{
  801b40:	55                   	push   %ebp
  801b41:	89 e5                	mov    %esp,%ebp
  801b43:	56                   	push   %esi
  801b44:	53                   	push   %ebx
  801b45:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (!args->curarg)
  801b48:	8b 43 08             	mov    0x8(%ebx),%eax
  801b4b:	85 c0                	test   %eax,%eax
  801b4d:	74 57                	je     801ba6 <argnextvalue+0x66>
		return 0;
	if (*args->curarg) {
  801b4f:	80 38 00             	cmpb   $0x0,(%eax)
  801b52:	74 0c                	je     801b60 <argnextvalue+0x20>
		args->argvalue = args->curarg;
  801b54:	89 43 0c             	mov    %eax,0xc(%ebx)
		args->curarg = "";
  801b57:	c7 43 08 41 33 80 00 	movl   $0x803341,0x8(%ebx)
  801b5e:	eb 41                	jmp    801ba1 <argnextvalue+0x61>
	} else if (*args->argc > 1) {
  801b60:	8b 03                	mov    (%ebx),%eax
  801b62:	83 38 01             	cmpl   $0x1,(%eax)
  801b65:	7e 2c                	jle    801b93 <argnextvalue+0x53>
		args->argvalue = args->argv[1];
  801b67:	8b 53 04             	mov    0x4(%ebx),%edx
  801b6a:	8d 4a 04             	lea    0x4(%edx),%ecx
  801b6d:	8b 72 04             	mov    0x4(%edx),%esi
  801b70:	89 73 0c             	mov    %esi,0xc(%ebx)
		memmove(args->argv + 1, args->argv + 2, sizeof(const char *) * (*args->argc - 1));
  801b73:	83 ec 04             	sub    $0x4,%esp
  801b76:	8b 00                	mov    (%eax),%eax
  801b78:	8d 04 85 fc ff ff ff 	lea    -0x4(,%eax,4),%eax
  801b7f:	50                   	push   %eax
  801b80:	83 c2 08             	add    $0x8,%edx
  801b83:	52                   	push   %edx
  801b84:	51                   	push   %ecx
  801b85:	e8 cd f7 ff ff       	call   801357 <memmove>
		(*args->argc)--;
  801b8a:	8b 03                	mov    (%ebx),%eax
  801b8c:	ff 08                	decl   (%eax)
  801b8e:	83 c4 10             	add    $0x10,%esp
  801b91:	eb 0e                	jmp    801ba1 <argnextvalue+0x61>
	} else {
		args->argvalue = 0;
  801b93:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)
		args->curarg = 0;
  801b9a:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
	}
	return (char*) args->argvalue;
  801ba1:	8b 43 0c             	mov    0xc(%ebx),%eax
  801ba4:	eb 05                	jmp    801bab <argnextvalue+0x6b>

char *
argnextvalue(struct Argstate *args)
{
	if (!args->curarg)
		return 0;
  801ba6:	b8 00 00 00 00       	mov    $0x0,%eax
	} else {
		args->argvalue = 0;
		args->curarg = 0;
	}
	return (char*) args->argvalue;
}
  801bab:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801bae:	5b                   	pop    %ebx
  801baf:	5e                   	pop    %esi
  801bb0:	c9                   	leave  
  801bb1:	c3                   	ret    

00801bb2 <argvalue>:
	return -1;
}

char *
argvalue(struct Argstate *args)
{
  801bb2:	55                   	push   %ebp
  801bb3:	89 e5                	mov    %esp,%ebp
  801bb5:	83 ec 08             	sub    $0x8,%esp
  801bb8:	8b 55 08             	mov    0x8(%ebp),%edx
	return (char*) (args->argvalue ? args->argvalue : argnextvalue(args));
  801bbb:	8b 42 0c             	mov    0xc(%edx),%eax
  801bbe:	85 c0                	test   %eax,%eax
  801bc0:	75 0c                	jne    801bce <argvalue+0x1c>
  801bc2:	83 ec 0c             	sub    $0xc,%esp
  801bc5:	52                   	push   %edx
  801bc6:	e8 75 ff ff ff       	call   801b40 <argnextvalue>
  801bcb:	83 c4 10             	add    $0x10,%esp
}
  801bce:	c9                   	leave  
  801bcf:	c3                   	ret    

00801bd0 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801bd0:	55                   	push   %ebp
  801bd1:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801bd3:	8b 45 08             	mov    0x8(%ebp),%eax
  801bd6:	05 00 00 00 30       	add    $0x30000000,%eax
  801bdb:	c1 e8 0c             	shr    $0xc,%eax
}
  801bde:	c9                   	leave  
  801bdf:	c3                   	ret    

00801be0 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801be0:	55                   	push   %ebp
  801be1:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  801be3:	ff 75 08             	pushl  0x8(%ebp)
  801be6:	e8 e5 ff ff ff       	call   801bd0 <fd2num>
  801beb:	83 c4 04             	add    $0x4,%esp
  801bee:	05 20 00 0d 00       	add    $0xd0020,%eax
  801bf3:	c1 e0 0c             	shl    $0xc,%eax
}
  801bf6:	c9                   	leave  
  801bf7:	c3                   	ret    

00801bf8 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801bf8:	55                   	push   %ebp
  801bf9:	89 e5                	mov    %esp,%ebp
  801bfb:	53                   	push   %ebx
  801bfc:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801bff:	a1 00 dd 7b ef       	mov    0xef7bdd00,%eax
  801c04:	a8 01                	test   $0x1,%al
  801c06:	74 34                	je     801c3c <fd_alloc+0x44>
  801c08:	a1 00 00 74 ef       	mov    0xef740000,%eax
  801c0d:	a8 01                	test   $0x1,%al
  801c0f:	74 32                	je     801c43 <fd_alloc+0x4b>
  801c11:	b8 00 10 00 d0       	mov    $0xd0001000,%eax
  801c16:	89 c1                	mov    %eax,%ecx
  801c18:	89 c2                	mov    %eax,%edx
  801c1a:	c1 ea 16             	shr    $0x16,%edx
  801c1d:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801c24:	f6 c2 01             	test   $0x1,%dl
  801c27:	74 1f                	je     801c48 <fd_alloc+0x50>
  801c29:	89 c2                	mov    %eax,%edx
  801c2b:	c1 ea 0c             	shr    $0xc,%edx
  801c2e:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801c35:	f6 c2 01             	test   $0x1,%dl
  801c38:	75 17                	jne    801c51 <fd_alloc+0x59>
  801c3a:	eb 0c                	jmp    801c48 <fd_alloc+0x50>
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  801c3c:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
  801c41:	eb 05                	jmp    801c48 <fd_alloc+0x50>
  801c43:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
  801c48:	89 0b                	mov    %ecx,(%ebx)
			return 0;
  801c4a:	b8 00 00 00 00       	mov    $0x0,%eax
  801c4f:	eb 17                	jmp    801c68 <fd_alloc+0x70>
  801c51:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  801c56:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  801c5b:	75 b9                	jne    801c16 <fd_alloc+0x1e>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801c5d:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_MAX_OPEN;
  801c63:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  801c68:	5b                   	pop    %ebx
  801c69:	c9                   	leave  
  801c6a:	c3                   	ret    

00801c6b <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  801c6b:	55                   	push   %ebp
  801c6c:	89 e5                	mov    %esp,%ebp
  801c6e:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801c71:	83 f8 1f             	cmp    $0x1f,%eax
  801c74:	77 36                	ja     801cac <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801c76:	05 00 00 0d 00       	add    $0xd0000,%eax
  801c7b:	c1 e0 0c             	shl    $0xc,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801c7e:	89 c2                	mov    %eax,%edx
  801c80:	c1 ea 16             	shr    $0x16,%edx
  801c83:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801c8a:	f6 c2 01             	test   $0x1,%dl
  801c8d:	74 24                	je     801cb3 <fd_lookup+0x48>
  801c8f:	89 c2                	mov    %eax,%edx
  801c91:	c1 ea 0c             	shr    $0xc,%edx
  801c94:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801c9b:	f6 c2 01             	test   $0x1,%dl
  801c9e:	74 1a                	je     801cba <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  801ca0:	8b 55 0c             	mov    0xc(%ebp),%edx
  801ca3:	89 02                	mov    %eax,(%edx)
	return 0;
  801ca5:	b8 00 00 00 00       	mov    $0x0,%eax
  801caa:	eb 13                	jmp    801cbf <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801cac:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801cb1:	eb 0c                	jmp    801cbf <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801cb3:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801cb8:	eb 05                	jmp    801cbf <fd_lookup+0x54>
  801cba:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  801cbf:	c9                   	leave  
  801cc0:	c3                   	ret    

00801cc1 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801cc1:	55                   	push   %ebp
  801cc2:	89 e5                	mov    %esp,%ebp
  801cc4:	53                   	push   %ebx
  801cc5:	83 ec 04             	sub    $0x4,%esp
  801cc8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801ccb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
		if (devtab[i]->dev_id == dev_id) {
  801cce:	39 0d 20 40 80 00    	cmp    %ecx,0x804020
  801cd4:	74 0d                	je     801ce3 <dev_lookup+0x22>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801cd6:	b8 00 00 00 00       	mov    $0x0,%eax
  801cdb:	eb 14                	jmp    801cf1 <dev_lookup+0x30>
		if (devtab[i]->dev_id == dev_id) {
  801cdd:	39 0a                	cmp    %ecx,(%edx)
  801cdf:	75 10                	jne    801cf1 <dev_lookup+0x30>
  801ce1:	eb 05                	jmp    801ce8 <dev_lookup+0x27>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801ce3:	ba 20 40 80 00       	mov    $0x804020,%edx
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
  801ce8:	89 13                	mov    %edx,(%ebx)
			return 0;
  801cea:	b8 00 00 00 00       	mov    $0x0,%eax
  801cef:	eb 31                	jmp    801d22 <dev_lookup+0x61>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801cf1:	40                   	inc    %eax
  801cf2:	8b 14 85 9c 3a 80 00 	mov    0x803a9c(,%eax,4),%edx
  801cf9:	85 d2                	test   %edx,%edx
  801cfb:	75 e0                	jne    801cdd <dev_lookup+0x1c>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801cfd:	a1 24 54 80 00       	mov    0x805424,%eax
  801d02:	8b 40 48             	mov    0x48(%eax),%eax
  801d05:	83 ec 04             	sub    $0x4,%esp
  801d08:	51                   	push   %ecx
  801d09:	50                   	push   %eax
  801d0a:	68 20 3a 80 00       	push   $0x803a20
  801d0f:	e8 e8 ed ff ff       	call   800afc <cprintf>
	*dev = 0;
  801d14:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_INVAL;
  801d1a:	83 c4 10             	add    $0x10,%esp
  801d1d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801d22:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801d25:	c9                   	leave  
  801d26:	c3                   	ret    

00801d27 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  801d27:	55                   	push   %ebp
  801d28:	89 e5                	mov    %esp,%ebp
  801d2a:	56                   	push   %esi
  801d2b:	53                   	push   %ebx
  801d2c:	83 ec 20             	sub    $0x20,%esp
  801d2f:	8b 75 08             	mov    0x8(%ebp),%esi
  801d32:	8a 45 0c             	mov    0xc(%ebp),%al
  801d35:	88 45 e7             	mov    %al,-0x19(%ebp)
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801d38:	56                   	push   %esi
  801d39:	e8 92 fe ff ff       	call   801bd0 <fd2num>
  801d3e:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801d41:	89 14 24             	mov    %edx,(%esp)
  801d44:	50                   	push   %eax
  801d45:	e8 21 ff ff ff       	call   801c6b <fd_lookup>
  801d4a:	89 c3                	mov    %eax,%ebx
  801d4c:	83 c4 08             	add    $0x8,%esp
  801d4f:	85 c0                	test   %eax,%eax
  801d51:	78 05                	js     801d58 <fd_close+0x31>
	    || fd != fd2)
  801d53:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801d56:	74 0d                	je     801d65 <fd_close+0x3e>
		return (must_exist ? r : 0);
  801d58:	80 7d e7 00          	cmpb   $0x0,-0x19(%ebp)
  801d5c:	75 48                	jne    801da6 <fd_close+0x7f>
  801d5e:	bb 00 00 00 00       	mov    $0x0,%ebx
  801d63:	eb 41                	jmp    801da6 <fd_close+0x7f>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801d65:	83 ec 08             	sub    $0x8,%esp
  801d68:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801d6b:	50                   	push   %eax
  801d6c:	ff 36                	pushl  (%esi)
  801d6e:	e8 4e ff ff ff       	call   801cc1 <dev_lookup>
  801d73:	89 c3                	mov    %eax,%ebx
  801d75:	83 c4 10             	add    $0x10,%esp
  801d78:	85 c0                	test   %eax,%eax
  801d7a:	78 1c                	js     801d98 <fd_close+0x71>
		if (dev->dev_close)
  801d7c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801d7f:	8b 40 10             	mov    0x10(%eax),%eax
  801d82:	85 c0                	test   %eax,%eax
  801d84:	74 0d                	je     801d93 <fd_close+0x6c>
			r = (*dev->dev_close)(fd);
  801d86:	83 ec 0c             	sub    $0xc,%esp
  801d89:	56                   	push   %esi
  801d8a:	ff d0                	call   *%eax
  801d8c:	89 c3                	mov    %eax,%ebx
  801d8e:	83 c4 10             	add    $0x10,%esp
  801d91:	eb 05                	jmp    801d98 <fd_close+0x71>
		else
			r = 0;
  801d93:	bb 00 00 00 00       	mov    $0x0,%ebx
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801d98:	83 ec 08             	sub    $0x8,%esp
  801d9b:	56                   	push   %esi
  801d9c:	6a 00                	push   $0x0
  801d9e:	e8 bf f8 ff ff       	call   801662 <sys_page_unmap>
	return r;
  801da3:	83 c4 10             	add    $0x10,%esp
}
  801da6:	89 d8                	mov    %ebx,%eax
  801da8:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801dab:	5b                   	pop    %ebx
  801dac:	5e                   	pop    %esi
  801dad:	c9                   	leave  
  801dae:	c3                   	ret    

00801daf <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801daf:	55                   	push   %ebp
  801db0:	89 e5                	mov    %esp,%ebp
  801db2:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801db5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801db8:	50                   	push   %eax
  801db9:	ff 75 08             	pushl  0x8(%ebp)
  801dbc:	e8 aa fe ff ff       	call   801c6b <fd_lookup>
  801dc1:	83 c4 08             	add    $0x8,%esp
  801dc4:	85 c0                	test   %eax,%eax
  801dc6:	78 10                	js     801dd8 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  801dc8:	83 ec 08             	sub    $0x8,%esp
  801dcb:	6a 01                	push   $0x1
  801dcd:	ff 75 f4             	pushl  -0xc(%ebp)
  801dd0:	e8 52 ff ff ff       	call   801d27 <fd_close>
  801dd5:	83 c4 10             	add    $0x10,%esp
}
  801dd8:	c9                   	leave  
  801dd9:	c3                   	ret    

00801dda <close_all>:

void
close_all(void)
{
  801dda:	55                   	push   %ebp
  801ddb:	89 e5                	mov    %esp,%ebp
  801ddd:	53                   	push   %ebx
  801dde:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801de1:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801de6:	83 ec 0c             	sub    $0xc,%esp
  801de9:	53                   	push   %ebx
  801dea:	e8 c0 ff ff ff       	call   801daf <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801def:	43                   	inc    %ebx
  801df0:	83 c4 10             	add    $0x10,%esp
  801df3:	83 fb 20             	cmp    $0x20,%ebx
  801df6:	75 ee                	jne    801de6 <close_all+0xc>
		close(i);
}
  801df8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801dfb:	c9                   	leave  
  801dfc:	c3                   	ret    

00801dfd <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801dfd:	55                   	push   %ebp
  801dfe:	89 e5                	mov    %esp,%ebp
  801e00:	57                   	push   %edi
  801e01:	56                   	push   %esi
  801e02:	53                   	push   %ebx
  801e03:	83 ec 2c             	sub    $0x2c,%esp
  801e06:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801e09:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801e0c:	50                   	push   %eax
  801e0d:	ff 75 08             	pushl  0x8(%ebp)
  801e10:	e8 56 fe ff ff       	call   801c6b <fd_lookup>
  801e15:	89 c3                	mov    %eax,%ebx
  801e17:	83 c4 08             	add    $0x8,%esp
  801e1a:	85 c0                	test   %eax,%eax
  801e1c:	0f 88 c0 00 00 00    	js     801ee2 <dup+0xe5>
		return r;
	close(newfdnum);
  801e22:	83 ec 0c             	sub    $0xc,%esp
  801e25:	57                   	push   %edi
  801e26:	e8 84 ff ff ff       	call   801daf <close>

	newfd = INDEX2FD(newfdnum);
  801e2b:	8d b7 00 00 0d 00    	lea    0xd0000(%edi),%esi
  801e31:	c1 e6 0c             	shl    $0xc,%esi
	ova = fd2data(oldfd);
  801e34:	83 c4 04             	add    $0x4,%esp
  801e37:	ff 75 e4             	pushl  -0x1c(%ebp)
  801e3a:	e8 a1 fd ff ff       	call   801be0 <fd2data>
  801e3f:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  801e41:	89 34 24             	mov    %esi,(%esp)
  801e44:	e8 97 fd ff ff       	call   801be0 <fd2data>
  801e49:	83 c4 10             	add    $0x10,%esp
  801e4c:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801e4f:	89 d8                	mov    %ebx,%eax
  801e51:	c1 e8 16             	shr    $0x16,%eax
  801e54:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801e5b:	a8 01                	test   $0x1,%al
  801e5d:	74 37                	je     801e96 <dup+0x99>
  801e5f:	89 d8                	mov    %ebx,%eax
  801e61:	c1 e8 0c             	shr    $0xc,%eax
  801e64:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801e6b:	f6 c2 01             	test   $0x1,%dl
  801e6e:	74 26                	je     801e96 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801e70:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801e77:	83 ec 0c             	sub    $0xc,%esp
  801e7a:	25 07 0e 00 00       	and    $0xe07,%eax
  801e7f:	50                   	push   %eax
  801e80:	ff 75 d4             	pushl  -0x2c(%ebp)
  801e83:	6a 00                	push   $0x0
  801e85:	53                   	push   %ebx
  801e86:	6a 00                	push   $0x0
  801e88:	e8 af f7 ff ff       	call   80163c <sys_page_map>
  801e8d:	89 c3                	mov    %eax,%ebx
  801e8f:	83 c4 20             	add    $0x20,%esp
  801e92:	85 c0                	test   %eax,%eax
  801e94:	78 2d                	js     801ec3 <dup+0xc6>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801e96:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801e99:	89 c2                	mov    %eax,%edx
  801e9b:	c1 ea 0c             	shr    $0xc,%edx
  801e9e:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801ea5:	83 ec 0c             	sub    $0xc,%esp
  801ea8:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  801eae:	52                   	push   %edx
  801eaf:	56                   	push   %esi
  801eb0:	6a 00                	push   $0x0
  801eb2:	50                   	push   %eax
  801eb3:	6a 00                	push   $0x0
  801eb5:	e8 82 f7 ff ff       	call   80163c <sys_page_map>
  801eba:	89 c3                	mov    %eax,%ebx
  801ebc:	83 c4 20             	add    $0x20,%esp
  801ebf:	85 c0                	test   %eax,%eax
  801ec1:	79 1d                	jns    801ee0 <dup+0xe3>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801ec3:	83 ec 08             	sub    $0x8,%esp
  801ec6:	56                   	push   %esi
  801ec7:	6a 00                	push   $0x0
  801ec9:	e8 94 f7 ff ff       	call   801662 <sys_page_unmap>
	sys_page_unmap(0, nva);
  801ece:	83 c4 08             	add    $0x8,%esp
  801ed1:	ff 75 d4             	pushl  -0x2c(%ebp)
  801ed4:	6a 00                	push   $0x0
  801ed6:	e8 87 f7 ff ff       	call   801662 <sys_page_unmap>
	return r;
  801edb:	83 c4 10             	add    $0x10,%esp
  801ede:	eb 02                	jmp    801ee2 <dup+0xe5>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
		goto err;

	return newfdnum;
  801ee0:	89 fb                	mov    %edi,%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  801ee2:	89 d8                	mov    %ebx,%eax
  801ee4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801ee7:	5b                   	pop    %ebx
  801ee8:	5e                   	pop    %esi
  801ee9:	5f                   	pop    %edi
  801eea:	c9                   	leave  
  801eeb:	c3                   	ret    

00801eec <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801eec:	55                   	push   %ebp
  801eed:	89 e5                	mov    %esp,%ebp
  801eef:	53                   	push   %ebx
  801ef0:	83 ec 14             	sub    $0x14,%esp
  801ef3:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801ef6:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801ef9:	50                   	push   %eax
  801efa:	53                   	push   %ebx
  801efb:	e8 6b fd ff ff       	call   801c6b <fd_lookup>
  801f00:	83 c4 08             	add    $0x8,%esp
  801f03:	85 c0                	test   %eax,%eax
  801f05:	78 67                	js     801f6e <read+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801f07:	83 ec 08             	sub    $0x8,%esp
  801f0a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801f0d:	50                   	push   %eax
  801f0e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801f11:	ff 30                	pushl  (%eax)
  801f13:	e8 a9 fd ff ff       	call   801cc1 <dev_lookup>
  801f18:	83 c4 10             	add    $0x10,%esp
  801f1b:	85 c0                	test   %eax,%eax
  801f1d:	78 4f                	js     801f6e <read+0x82>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801f1f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801f22:	8b 50 08             	mov    0x8(%eax),%edx
  801f25:	83 e2 03             	and    $0x3,%edx
  801f28:	83 fa 01             	cmp    $0x1,%edx
  801f2b:	75 21                	jne    801f4e <read+0x62>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801f2d:	a1 24 54 80 00       	mov    0x805424,%eax
  801f32:	8b 40 48             	mov    0x48(%eax),%eax
  801f35:	83 ec 04             	sub    $0x4,%esp
  801f38:	53                   	push   %ebx
  801f39:	50                   	push   %eax
  801f3a:	68 61 3a 80 00       	push   $0x803a61
  801f3f:	e8 b8 eb ff ff       	call   800afc <cprintf>
		return -E_INVAL;
  801f44:	83 c4 10             	add    $0x10,%esp
  801f47:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801f4c:	eb 20                	jmp    801f6e <read+0x82>
	}
	if (!dev->dev_read)
  801f4e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801f51:	8b 52 08             	mov    0x8(%edx),%edx
  801f54:	85 d2                	test   %edx,%edx
  801f56:	74 11                	je     801f69 <read+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801f58:	83 ec 04             	sub    $0x4,%esp
  801f5b:	ff 75 10             	pushl  0x10(%ebp)
  801f5e:	ff 75 0c             	pushl  0xc(%ebp)
  801f61:	50                   	push   %eax
  801f62:	ff d2                	call   *%edx
  801f64:	83 c4 10             	add    $0x10,%esp
  801f67:	eb 05                	jmp    801f6e <read+0x82>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801f69:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_read)(fd, buf, n);
}
  801f6e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801f71:	c9                   	leave  
  801f72:	c3                   	ret    

00801f73 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801f73:	55                   	push   %ebp
  801f74:	89 e5                	mov    %esp,%ebp
  801f76:	57                   	push   %edi
  801f77:	56                   	push   %esi
  801f78:	53                   	push   %ebx
  801f79:	83 ec 0c             	sub    $0xc,%esp
  801f7c:	8b 7d 08             	mov    0x8(%ebp),%edi
  801f7f:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801f82:	85 f6                	test   %esi,%esi
  801f84:	74 31                	je     801fb7 <readn+0x44>
  801f86:	b8 00 00 00 00       	mov    $0x0,%eax
  801f8b:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = read(fdnum, (char*)buf + tot, n - tot);
  801f90:	83 ec 04             	sub    $0x4,%esp
  801f93:	89 f2                	mov    %esi,%edx
  801f95:	29 c2                	sub    %eax,%edx
  801f97:	52                   	push   %edx
  801f98:	03 45 0c             	add    0xc(%ebp),%eax
  801f9b:	50                   	push   %eax
  801f9c:	57                   	push   %edi
  801f9d:	e8 4a ff ff ff       	call   801eec <read>
		if (m < 0)
  801fa2:	83 c4 10             	add    $0x10,%esp
  801fa5:	85 c0                	test   %eax,%eax
  801fa7:	78 17                	js     801fc0 <readn+0x4d>
			return m;
		if (m == 0)
  801fa9:	85 c0                	test   %eax,%eax
  801fab:	74 11                	je     801fbe <readn+0x4b>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801fad:	01 c3                	add    %eax,%ebx
  801faf:	89 d8                	mov    %ebx,%eax
  801fb1:	39 f3                	cmp    %esi,%ebx
  801fb3:	72 db                	jb     801f90 <readn+0x1d>
  801fb5:	eb 09                	jmp    801fc0 <readn+0x4d>
  801fb7:	b8 00 00 00 00       	mov    $0x0,%eax
  801fbc:	eb 02                	jmp    801fc0 <readn+0x4d>
		m = read(fdnum, (char*)buf + tot, n - tot);
		if (m < 0)
			return m;
		if (m == 0)
  801fbe:	89 d8                	mov    %ebx,%eax
			break;
	}
	return tot;
}
  801fc0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801fc3:	5b                   	pop    %ebx
  801fc4:	5e                   	pop    %esi
  801fc5:	5f                   	pop    %edi
  801fc6:	c9                   	leave  
  801fc7:	c3                   	ret    

00801fc8 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801fc8:	55                   	push   %ebp
  801fc9:	89 e5                	mov    %esp,%ebp
  801fcb:	53                   	push   %ebx
  801fcc:	83 ec 14             	sub    $0x14,%esp
  801fcf:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801fd2:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801fd5:	50                   	push   %eax
  801fd6:	53                   	push   %ebx
  801fd7:	e8 8f fc ff ff       	call   801c6b <fd_lookup>
  801fdc:	83 c4 08             	add    $0x8,%esp
  801fdf:	85 c0                	test   %eax,%eax
  801fe1:	78 62                	js     802045 <write+0x7d>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801fe3:	83 ec 08             	sub    $0x8,%esp
  801fe6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801fe9:	50                   	push   %eax
  801fea:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801fed:	ff 30                	pushl  (%eax)
  801fef:	e8 cd fc ff ff       	call   801cc1 <dev_lookup>
  801ff4:	83 c4 10             	add    $0x10,%esp
  801ff7:	85 c0                	test   %eax,%eax
  801ff9:	78 4a                	js     802045 <write+0x7d>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801ffb:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801ffe:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  802002:	75 21                	jne    802025 <write+0x5d>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  802004:	a1 24 54 80 00       	mov    0x805424,%eax
  802009:	8b 40 48             	mov    0x48(%eax),%eax
  80200c:	83 ec 04             	sub    $0x4,%esp
  80200f:	53                   	push   %ebx
  802010:	50                   	push   %eax
  802011:	68 7d 3a 80 00       	push   $0x803a7d
  802016:	e8 e1 ea ff ff       	call   800afc <cprintf>
		return -E_INVAL;
  80201b:	83 c4 10             	add    $0x10,%esp
  80201e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  802023:	eb 20                	jmp    802045 <write+0x7d>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  802025:	8b 55 f4             	mov    -0xc(%ebp),%edx
  802028:	8b 52 0c             	mov    0xc(%edx),%edx
  80202b:	85 d2                	test   %edx,%edx
  80202d:	74 11                	je     802040 <write+0x78>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80202f:	83 ec 04             	sub    $0x4,%esp
  802032:	ff 75 10             	pushl  0x10(%ebp)
  802035:	ff 75 0c             	pushl  0xc(%ebp)
  802038:	50                   	push   %eax
  802039:	ff d2                	call   *%edx
  80203b:	83 c4 10             	add    $0x10,%esp
  80203e:	eb 05                	jmp    802045 <write+0x7d>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  802040:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  802045:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802048:	c9                   	leave  
  802049:	c3                   	ret    

0080204a <seek>:

int
seek(int fdnum, off_t offset)
{
  80204a:	55                   	push   %ebp
  80204b:	89 e5                	mov    %esp,%ebp
  80204d:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802050:	8d 45 fc             	lea    -0x4(%ebp),%eax
  802053:	50                   	push   %eax
  802054:	ff 75 08             	pushl  0x8(%ebp)
  802057:	e8 0f fc ff ff       	call   801c6b <fd_lookup>
  80205c:	83 c4 08             	add    $0x8,%esp
  80205f:	85 c0                	test   %eax,%eax
  802061:	78 0e                	js     802071 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  802063:	8b 45 fc             	mov    -0x4(%ebp),%eax
  802066:	8b 55 0c             	mov    0xc(%ebp),%edx
  802069:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  80206c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802071:	c9                   	leave  
  802072:	c3                   	ret    

00802073 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  802073:	55                   	push   %ebp
  802074:	89 e5                	mov    %esp,%ebp
  802076:	53                   	push   %ebx
  802077:	83 ec 14             	sub    $0x14,%esp
  80207a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80207d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  802080:	50                   	push   %eax
  802081:	53                   	push   %ebx
  802082:	e8 e4 fb ff ff       	call   801c6b <fd_lookup>
  802087:	83 c4 08             	add    $0x8,%esp
  80208a:	85 c0                	test   %eax,%eax
  80208c:	78 5f                	js     8020ed <ftruncate+0x7a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80208e:	83 ec 08             	sub    $0x8,%esp
  802091:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802094:	50                   	push   %eax
  802095:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802098:	ff 30                	pushl  (%eax)
  80209a:	e8 22 fc ff ff       	call   801cc1 <dev_lookup>
  80209f:	83 c4 10             	add    $0x10,%esp
  8020a2:	85 c0                	test   %eax,%eax
  8020a4:	78 47                	js     8020ed <ftruncate+0x7a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8020a6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8020a9:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8020ad:	75 21                	jne    8020d0 <ftruncate+0x5d>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8020af:	a1 24 54 80 00       	mov    0x805424,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8020b4:	8b 40 48             	mov    0x48(%eax),%eax
  8020b7:	83 ec 04             	sub    $0x4,%esp
  8020ba:	53                   	push   %ebx
  8020bb:	50                   	push   %eax
  8020bc:	68 40 3a 80 00       	push   $0x803a40
  8020c1:	e8 36 ea ff ff       	call   800afc <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8020c6:	83 c4 10             	add    $0x10,%esp
  8020c9:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8020ce:	eb 1d                	jmp    8020ed <ftruncate+0x7a>
	}
	if (!dev->dev_trunc)
  8020d0:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8020d3:	8b 52 18             	mov    0x18(%edx),%edx
  8020d6:	85 d2                	test   %edx,%edx
  8020d8:	74 0e                	je     8020e8 <ftruncate+0x75>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8020da:	83 ec 08             	sub    $0x8,%esp
  8020dd:	ff 75 0c             	pushl  0xc(%ebp)
  8020e0:	50                   	push   %eax
  8020e1:	ff d2                	call   *%edx
  8020e3:	83 c4 10             	add    $0x10,%esp
  8020e6:	eb 05                	jmp    8020ed <ftruncate+0x7a>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8020e8:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  8020ed:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8020f0:	c9                   	leave  
  8020f1:	c3                   	ret    

008020f2 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8020f2:	55                   	push   %ebp
  8020f3:	89 e5                	mov    %esp,%ebp
  8020f5:	53                   	push   %ebx
  8020f6:	83 ec 14             	sub    $0x14,%esp
  8020f9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8020fc:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8020ff:	50                   	push   %eax
  802100:	ff 75 08             	pushl  0x8(%ebp)
  802103:	e8 63 fb ff ff       	call   801c6b <fd_lookup>
  802108:	83 c4 08             	add    $0x8,%esp
  80210b:	85 c0                	test   %eax,%eax
  80210d:	78 52                	js     802161 <fstat+0x6f>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80210f:	83 ec 08             	sub    $0x8,%esp
  802112:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802115:	50                   	push   %eax
  802116:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802119:	ff 30                	pushl  (%eax)
  80211b:	e8 a1 fb ff ff       	call   801cc1 <dev_lookup>
  802120:	83 c4 10             	add    $0x10,%esp
  802123:	85 c0                	test   %eax,%eax
  802125:	78 3a                	js     802161 <fstat+0x6f>
		return r;
	if (!dev->dev_stat)
  802127:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80212a:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  80212e:	74 2c                	je     80215c <fstat+0x6a>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  802130:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  802133:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80213a:	00 00 00 
	stat->st_isdir = 0;
  80213d:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  802144:	00 00 00 
	stat->st_dev = dev;
  802147:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  80214d:	83 ec 08             	sub    $0x8,%esp
  802150:	53                   	push   %ebx
  802151:	ff 75 f0             	pushl  -0x10(%ebp)
  802154:	ff 50 14             	call   *0x14(%eax)
  802157:	83 c4 10             	add    $0x10,%esp
  80215a:	eb 05                	jmp    802161 <fstat+0x6f>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  80215c:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  802161:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802164:	c9                   	leave  
  802165:	c3                   	ret    

00802166 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  802166:	55                   	push   %ebp
  802167:	89 e5                	mov    %esp,%ebp
  802169:	56                   	push   %esi
  80216a:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  80216b:	83 ec 08             	sub    $0x8,%esp
  80216e:	6a 00                	push   $0x0
  802170:	ff 75 08             	pushl  0x8(%ebp)
  802173:	e8 78 01 00 00       	call   8022f0 <open>
  802178:	89 c3                	mov    %eax,%ebx
  80217a:	83 c4 10             	add    $0x10,%esp
  80217d:	85 c0                	test   %eax,%eax
  80217f:	78 1b                	js     80219c <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  802181:	83 ec 08             	sub    $0x8,%esp
  802184:	ff 75 0c             	pushl  0xc(%ebp)
  802187:	50                   	push   %eax
  802188:	e8 65 ff ff ff       	call   8020f2 <fstat>
  80218d:	89 c6                	mov    %eax,%esi
	close(fd);
  80218f:	89 1c 24             	mov    %ebx,(%esp)
  802192:	e8 18 fc ff ff       	call   801daf <close>
	return r;
  802197:	83 c4 10             	add    $0x10,%esp
  80219a:	89 f3                	mov    %esi,%ebx
}
  80219c:	89 d8                	mov    %ebx,%eax
  80219e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8021a1:	5b                   	pop    %ebx
  8021a2:	5e                   	pop    %esi
  8021a3:	c9                   	leave  
  8021a4:	c3                   	ret    
  8021a5:	00 00                	add    %al,(%eax)
	...

008021a8 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8021a8:	55                   	push   %ebp
  8021a9:	89 e5                	mov    %esp,%ebp
  8021ab:	56                   	push   %esi
  8021ac:	53                   	push   %ebx
  8021ad:	89 c3                	mov    %eax,%ebx
  8021af:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  8021b1:	83 3d 20 54 80 00 00 	cmpl   $0x0,0x805420
  8021b8:	75 12                	jne    8021cc <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8021ba:	83 ec 0c             	sub    $0xc,%esp
  8021bd:	6a 01                	push   $0x1
  8021bf:	e8 62 0e 00 00       	call   803026 <ipc_find_env>
  8021c4:	a3 20 54 80 00       	mov    %eax,0x805420
  8021c9:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8021cc:	6a 07                	push   $0x7
  8021ce:	68 00 60 80 00       	push   $0x806000
  8021d3:	53                   	push   %ebx
  8021d4:	ff 35 20 54 80 00    	pushl  0x805420
  8021da:	e8 f2 0d 00 00       	call   802fd1 <ipc_send>
	
	return ipc_recv(NULL, dstva, NULL);
  8021df:	83 c4 0c             	add    $0xc,%esp
  8021e2:	6a 00                	push   $0x0
  8021e4:	56                   	push   %esi
  8021e5:	6a 00                	push   $0x0
  8021e7:	e8 70 0d 00 00       	call   802f5c <ipc_recv>
}
  8021ec:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8021ef:	5b                   	pop    %ebx
  8021f0:	5e                   	pop    %esi
  8021f1:	c9                   	leave  
  8021f2:	c3                   	ret    

008021f3 <devfile_stat>:
}


static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8021f3:	55                   	push   %ebp
  8021f4:	89 e5                	mov    %esp,%ebp
  8021f6:	53                   	push   %ebx
  8021f7:	83 ec 04             	sub    $0x4,%esp
  8021fa:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8021fd:	8b 45 08             	mov    0x8(%ebp),%eax
  802200:	8b 40 0c             	mov    0xc(%eax),%eax
  802203:	a3 00 60 80 00       	mov    %eax,0x806000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0) {
  802208:	ba 00 00 00 00       	mov    $0x0,%edx
  80220d:	b8 05 00 00 00       	mov    $0x5,%eax
  802212:	e8 91 ff ff ff       	call   8021a8 <fsipc>
  802217:	85 c0                	test   %eax,%eax
  802219:	78 2c                	js     802247 <devfile_stat+0x54>
		return r;
	}
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  80221b:	83 ec 08             	sub    $0x8,%esp
  80221e:	68 00 60 80 00       	push   $0x806000
  802223:	53                   	push   %ebx
  802224:	e8 6d ef ff ff       	call   801196 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  802229:	a1 80 60 80 00       	mov    0x806080,%eax
  80222e:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  802234:	a1 84 60 80 00       	mov    0x806084,%eax
  802239:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  80223f:	83 c4 10             	add    $0x10,%esp
  802242:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802247:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80224a:	c9                   	leave  
  80224b:	c3                   	ret    

0080224c <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  80224c:	55                   	push   %ebp
  80224d:	89 e5                	mov    %esp,%ebp
  80224f:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  802252:	8b 45 08             	mov    0x8(%ebp),%eax
  802255:	8b 40 0c             	mov    0xc(%eax),%eax
  802258:	a3 00 60 80 00       	mov    %eax,0x806000
	return fsipc(FSREQ_FLUSH, NULL);
  80225d:	ba 00 00 00 00       	mov    $0x0,%edx
  802262:	b8 06 00 00 00       	mov    $0x6,%eax
  802267:	e8 3c ff ff ff       	call   8021a8 <fsipc>
}
  80226c:	c9                   	leave  
  80226d:	c3                   	ret    

0080226e <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  80226e:	55                   	push   %ebp
  80226f:	89 e5                	mov    %esp,%ebp
  802271:	56                   	push   %esi
  802272:	53                   	push   %ebx
  802273:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  802276:	8b 45 08             	mov    0x8(%ebp),%eax
  802279:	8b 40 0c             	mov    0xc(%eax),%eax
  80227c:	a3 00 60 80 00       	mov    %eax,0x806000
	fsipcbuf.read.req_n = n;
  802281:	89 35 04 60 80 00    	mov    %esi,0x806004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  802287:	ba 00 00 00 00       	mov    $0x0,%edx
  80228c:	b8 03 00 00 00       	mov    $0x3,%eax
  802291:	e8 12 ff ff ff       	call   8021a8 <fsipc>
  802296:	89 c3                	mov    %eax,%ebx
  802298:	85 c0                	test   %eax,%eax
  80229a:	78 4b                	js     8022e7 <devfile_read+0x79>
		return r;
	assert(r <= n);
  80229c:	39 c6                	cmp    %eax,%esi
  80229e:	73 16                	jae    8022b6 <devfile_read+0x48>
  8022a0:	68 ac 3a 80 00       	push   $0x803aac
  8022a5:	68 72 34 80 00       	push   $0x803472
  8022aa:	6a 7d                	push   $0x7d
  8022ac:	68 b3 3a 80 00       	push   $0x803ab3
  8022b1:	e8 6e e7 ff ff       	call   800a24 <_panic>
	assert(r <= PGSIZE);
  8022b6:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8022bb:	7e 16                	jle    8022d3 <devfile_read+0x65>
  8022bd:	68 be 3a 80 00       	push   $0x803abe
  8022c2:	68 72 34 80 00       	push   $0x803472
  8022c7:	6a 7e                	push   $0x7e
  8022c9:	68 b3 3a 80 00       	push   $0x803ab3
  8022ce:	e8 51 e7 ff ff       	call   800a24 <_panic>
	memmove(buf, &fsipcbuf, r);
  8022d3:	83 ec 04             	sub    $0x4,%esp
  8022d6:	50                   	push   %eax
  8022d7:	68 00 60 80 00       	push   $0x806000
  8022dc:	ff 75 0c             	pushl  0xc(%ebp)
  8022df:	e8 73 f0 ff ff       	call   801357 <memmove>
	return r;
  8022e4:	83 c4 10             	add    $0x10,%esp
}
  8022e7:	89 d8                	mov    %ebx,%eax
  8022e9:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8022ec:	5b                   	pop    %ebx
  8022ed:	5e                   	pop    %esi
  8022ee:	c9                   	leave  
  8022ef:	c3                   	ret    

008022f0 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  8022f0:	55                   	push   %ebp
  8022f1:	89 e5                	mov    %esp,%ebp
  8022f3:	56                   	push   %esi
  8022f4:	53                   	push   %ebx
  8022f5:	83 ec 1c             	sub    $0x1c,%esp
  8022f8:	8b 75 08             	mov    0x8(%ebp),%esi
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  8022fb:	56                   	push   %esi
  8022fc:	e8 43 ee ff ff       	call   801144 <strlen>
  802301:	83 c4 10             	add    $0x10,%esp
  802304:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  802309:	7f 65                	jg     802370 <open+0x80>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  80230b:	83 ec 0c             	sub    $0xc,%esp
  80230e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802311:	50                   	push   %eax
  802312:	e8 e1 f8 ff ff       	call   801bf8 <fd_alloc>
  802317:	89 c3                	mov    %eax,%ebx
  802319:	83 c4 10             	add    $0x10,%esp
  80231c:	85 c0                	test   %eax,%eax
  80231e:	78 55                	js     802375 <open+0x85>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  802320:	83 ec 08             	sub    $0x8,%esp
  802323:	56                   	push   %esi
  802324:	68 00 60 80 00       	push   $0x806000
  802329:	e8 68 ee ff ff       	call   801196 <strcpy>
	fsipcbuf.open.req_omode = mode;
  80232e:	8b 45 0c             	mov    0xc(%ebp),%eax
  802331:	a3 00 64 80 00       	mov    %eax,0x806400



	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  802336:	8b 55 f4             	mov    -0xc(%ebp),%edx
  802339:	b8 01 00 00 00       	mov    $0x1,%eax
  80233e:	e8 65 fe ff ff       	call   8021a8 <fsipc>
  802343:	89 c3                	mov    %eax,%ebx
  802345:	83 c4 10             	add    $0x10,%esp
  802348:	85 c0                	test   %eax,%eax
  80234a:	79 12                	jns    80235e <open+0x6e>
		fd_close(fd, 0);
  80234c:	83 ec 08             	sub    $0x8,%esp
  80234f:	6a 00                	push   $0x0
  802351:	ff 75 f4             	pushl  -0xc(%ebp)
  802354:	e8 ce f9 ff ff       	call   801d27 <fd_close>
		return r;
  802359:	83 c4 10             	add    $0x10,%esp
  80235c:	eb 17                	jmp    802375 <open+0x85>
	}

	return fd2num(fd);
  80235e:	83 ec 0c             	sub    $0xc,%esp
  802361:	ff 75 f4             	pushl  -0xc(%ebp)
  802364:	e8 67 f8 ff ff       	call   801bd0 <fd2num>
  802369:	89 c3                	mov    %eax,%ebx
  80236b:	83 c4 10             	add    $0x10,%esp
  80236e:	eb 05                	jmp    802375 <open+0x85>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  802370:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  802375:	89 d8                	mov    %ebx,%eax
  802377:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80237a:	5b                   	pop    %ebx
  80237b:	5e                   	pop    %esi
  80237c:	c9                   	leave  
  80237d:	c3                   	ret    
	...

00802380 <writebuf>:
};


static void
writebuf(struct printbuf *b)
{
  802380:	55                   	push   %ebp
  802381:	89 e5                	mov    %esp,%ebp
  802383:	53                   	push   %ebx
  802384:	83 ec 04             	sub    $0x4,%esp
  802387:	89 c3                	mov    %eax,%ebx
	if (b->error > 0) {
  802389:	83 78 0c 00          	cmpl   $0x0,0xc(%eax)
  80238d:	7e 2e                	jle    8023bd <writebuf+0x3d>
		ssize_t result = write(b->fd, b->buf, b->idx);
  80238f:	83 ec 04             	sub    $0x4,%esp
  802392:	ff 70 04             	pushl  0x4(%eax)
  802395:	8d 40 10             	lea    0x10(%eax),%eax
  802398:	50                   	push   %eax
  802399:	ff 33                	pushl  (%ebx)
  80239b:	e8 28 fc ff ff       	call   801fc8 <write>
		if (result > 0)
  8023a0:	83 c4 10             	add    $0x10,%esp
  8023a3:	85 c0                	test   %eax,%eax
  8023a5:	7e 03                	jle    8023aa <writebuf+0x2a>
			b->result += result;
  8023a7:	01 43 08             	add    %eax,0x8(%ebx)
		if (result != b->idx) // error, or wrote less than supplied
  8023aa:	39 43 04             	cmp    %eax,0x4(%ebx)
  8023ad:	74 0e                	je     8023bd <writebuf+0x3d>
			b->error = (result < 0 ? result : 0);
  8023af:	89 c2                	mov    %eax,%edx
  8023b1:	85 c0                	test   %eax,%eax
  8023b3:	7e 05                	jle    8023ba <writebuf+0x3a>
  8023b5:	ba 00 00 00 00       	mov    $0x0,%edx
  8023ba:	89 53 0c             	mov    %edx,0xc(%ebx)
	}
}
  8023bd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8023c0:	c9                   	leave  
  8023c1:	c3                   	ret    

008023c2 <putch>:

static void
putch(int ch, void *thunk)
{
  8023c2:	55                   	push   %ebp
  8023c3:	89 e5                	mov    %esp,%ebp
  8023c5:	53                   	push   %ebx
  8023c6:	83 ec 04             	sub    $0x4,%esp
  8023c9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct printbuf *b = (struct printbuf *) thunk;
	b->buf[b->idx++] = ch;
  8023cc:	8b 43 04             	mov    0x4(%ebx),%eax
  8023cf:	8b 55 08             	mov    0x8(%ebp),%edx
  8023d2:	88 54 03 10          	mov    %dl,0x10(%ebx,%eax,1)
  8023d6:	40                   	inc    %eax
  8023d7:	89 43 04             	mov    %eax,0x4(%ebx)
	if (b->idx == 256) {
  8023da:	3d 00 01 00 00       	cmp    $0x100,%eax
  8023df:	75 0e                	jne    8023ef <putch+0x2d>
		writebuf(b);
  8023e1:	89 d8                	mov    %ebx,%eax
  8023e3:	e8 98 ff ff ff       	call   802380 <writebuf>
		b->idx = 0;
  8023e8:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	}
}
  8023ef:	83 c4 04             	add    $0x4,%esp
  8023f2:	5b                   	pop    %ebx
  8023f3:	c9                   	leave  
  8023f4:	c3                   	ret    

008023f5 <vfprintf>:

int
vfprintf(int fd, const char *fmt, va_list ap)
{
  8023f5:	55                   	push   %ebp
  8023f6:	89 e5                	mov    %esp,%ebp
  8023f8:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.fd = fd;
  8023fe:	8b 45 08             	mov    0x8(%ebp),%eax
  802401:	89 85 e8 fe ff ff    	mov    %eax,-0x118(%ebp)
	b.idx = 0;
  802407:	c7 85 ec fe ff ff 00 	movl   $0x0,-0x114(%ebp)
  80240e:	00 00 00 
	b.result = 0;
  802411:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  802418:	00 00 00 
	b.error = 1;
  80241b:	c7 85 f4 fe ff ff 01 	movl   $0x1,-0x10c(%ebp)
  802422:	00 00 00 
	vprintfmt(putch, &b, fmt, ap);
  802425:	ff 75 10             	pushl  0x10(%ebp)
  802428:	ff 75 0c             	pushl  0xc(%ebp)
  80242b:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  802431:	50                   	push   %eax
  802432:	68 c2 23 80 00       	push   $0x8023c2
  802437:	e8 25 e8 ff ff       	call   800c61 <vprintfmt>
	if (b.idx > 0)
  80243c:	83 c4 10             	add    $0x10,%esp
  80243f:	83 bd ec fe ff ff 00 	cmpl   $0x0,-0x114(%ebp)
  802446:	7e 0b                	jle    802453 <vfprintf+0x5e>
		writebuf(&b);
  802448:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  80244e:	e8 2d ff ff ff       	call   802380 <writebuf>

	return (b.result ? b.result : b.error);
  802453:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  802459:	85 c0                	test   %eax,%eax
  80245b:	75 06                	jne    802463 <vfprintf+0x6e>
  80245d:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
}
  802463:	c9                   	leave  
  802464:	c3                   	ret    

00802465 <fprintf>:

int
fprintf(int fd, const char *fmt, ...)
{
  802465:	55                   	push   %ebp
  802466:	89 e5                	mov    %esp,%ebp
  802468:	83 ec 0c             	sub    $0xc,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80246b:	8d 45 10             	lea    0x10(%ebp),%eax
	cnt = vfprintf(fd, fmt, ap);
  80246e:	50                   	push   %eax
  80246f:	ff 75 0c             	pushl  0xc(%ebp)
  802472:	ff 75 08             	pushl  0x8(%ebp)
  802475:	e8 7b ff ff ff       	call   8023f5 <vfprintf>
	va_end(ap);

	return cnt;
}
  80247a:	c9                   	leave  
  80247b:	c3                   	ret    

0080247c <printf>:

int
printf(const char *fmt, ...)
{
  80247c:	55                   	push   %ebp
  80247d:	89 e5                	mov    %esp,%ebp
  80247f:	83 ec 0c             	sub    $0xc,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  802482:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vfprintf(1, fmt, ap);
  802485:	50                   	push   %eax
  802486:	ff 75 08             	pushl  0x8(%ebp)
  802489:	6a 01                	push   $0x1
  80248b:	e8 65 ff ff ff       	call   8023f5 <vfprintf>
	va_end(ap);

	return cnt;
}
  802490:	c9                   	leave  
  802491:	c3                   	ret    
	...

00802494 <spawn>:
// argv: pointer to null-terminated array of pointers to strings,
// 	 which will be passed to the child as its command-line arguments.
// Returns child envid on success, < 0 on failure.
int
spawn(const char *prog, const char **argv)
{
  802494:	55                   	push   %ebp
  802495:	89 e5                	mov    %esp,%ebp
  802497:	57                   	push   %edi
  802498:	56                   	push   %esi
  802499:	53                   	push   %ebx
  80249a:	81 ec 94 02 00 00    	sub    $0x294,%esp
	//   - Call sys_env_set_trapframe(child, &child_tf) to set up the
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
  8024a0:	6a 00                	push   $0x0
  8024a2:	ff 75 08             	pushl  0x8(%ebp)
  8024a5:	e8 46 fe ff ff       	call   8022f0 <open>
  8024aa:	89 85 88 fd ff ff    	mov    %eax,-0x278(%ebp)
  8024b0:	83 c4 10             	add    $0x10,%esp
  8024b3:	85 c0                	test   %eax,%eax
  8024b5:	0f 88 36 05 00 00    	js     8029f1 <spawn+0x55d>
		return r;
	fd = r;

	// Read elf header
	elf = (struct Elf*) elf_buf;
	if (readn(fd, elf_buf, sizeof(elf_buf)) != sizeof(elf_buf)
  8024bb:	83 ec 04             	sub    $0x4,%esp
  8024be:	68 00 02 00 00       	push   $0x200
  8024c3:	8d 85 e8 fd ff ff    	lea    -0x218(%ebp),%eax
  8024c9:	50                   	push   %eax
  8024ca:	ff b5 88 fd ff ff    	pushl  -0x278(%ebp)
  8024d0:	e8 9e fa ff ff       	call   801f73 <readn>
  8024d5:	83 c4 10             	add    $0x10,%esp
  8024d8:	3d 00 02 00 00       	cmp    $0x200,%eax
  8024dd:	75 0c                	jne    8024eb <spawn+0x57>
	    || elf->e_magic != ELF_MAGIC) {
  8024df:	81 bd e8 fd ff ff 7f 	cmpl   $0x464c457f,-0x218(%ebp)
  8024e6:	45 4c 46 
  8024e9:	74 38                	je     802523 <spawn+0x8f>
		close(fd);
  8024eb:	83 ec 0c             	sub    $0xc,%esp
  8024ee:	ff b5 88 fd ff ff    	pushl  -0x278(%ebp)
  8024f4:	e8 b6 f8 ff ff       	call   801daf <close>
		cprintf("elf magic %08x want %08x\n", elf->e_magic, ELF_MAGIC);
  8024f9:	83 c4 0c             	add    $0xc,%esp
  8024fc:	68 7f 45 4c 46       	push   $0x464c457f
  802501:	ff b5 e8 fd ff ff    	pushl  -0x218(%ebp)
  802507:	68 ca 3a 80 00       	push   $0x803aca
  80250c:	e8 eb e5 ff ff       	call   800afc <cprintf>
		return -E_NOT_EXEC;
  802511:	83 c4 10             	add    $0x10,%esp
  802514:	c7 85 84 fd ff ff f2 	movl   $0xfffffff2,-0x27c(%ebp)
  80251b:	ff ff ff 
  80251e:	e9 da 04 00 00       	jmp    8029fd <spawn+0x569>
  802523:	ba 07 00 00 00       	mov    $0x7,%edx
  802528:	89 d0                	mov    %edx,%eax
  80252a:	cd 30                	int    $0x30
  80252c:	89 85 74 fd ff ff    	mov    %eax,-0x28c(%ebp)
  802532:	89 85 84 fd ff ff    	mov    %eax,-0x27c(%ebp)
	}


	// Create new child environment
	if ((r = sys_exofork()) < 0)
  802538:	85 c0                	test   %eax,%eax
  80253a:	0f 88 bd 04 00 00    	js     8029fd <spawn+0x569>
	child = r;



	// Set up trap frame, including initial stack.
	child_tf = envs[ENVX(child)].env_tf;
  802540:	25 ff 03 00 00       	and    $0x3ff,%eax
  802545:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  80254c:	89 c6                	mov    %eax,%esi
  80254e:	c1 e6 07             	shl    $0x7,%esi
  802551:	29 d6                	sub    %edx,%esi
  802553:	81 c6 00 00 c0 ee    	add    $0xeec00000,%esi
  802559:	8d bd a4 fd ff ff    	lea    -0x25c(%ebp),%edi
  80255f:	b9 11 00 00 00       	mov    $0x11,%ecx
  802564:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	child_tf.tf_eip = elf->e_entry;
  802566:	8b 85 00 fe ff ff    	mov    -0x200(%ebp),%eax
  80256c:	89 85 d4 fd ff ff    	mov    %eax,-0x22c(%ebp)
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  802572:	8b 55 0c             	mov    0xc(%ebp),%edx
  802575:	8b 02                	mov    (%edx),%eax
  802577:	85 c0                	test   %eax,%eax
  802579:	74 39                	je     8025b4 <spawn+0x120>
	char *string_store;
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
  80257b:	be 00 00 00 00       	mov    $0x0,%esi
	for (argc = 0; argv[argc] != 0; argc++)
  802580:	bb 00 00 00 00       	mov    $0x0,%ebx
  802585:	89 d7                	mov    %edx,%edi
		string_size += strlen(argv[argc]) + 1;
  802587:	83 ec 0c             	sub    $0xc,%esp
  80258a:	50                   	push   %eax
  80258b:	e8 b4 eb ff ff       	call   801144 <strlen>
  802590:	8d 74 30 01          	lea    0x1(%eax,%esi,1),%esi
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  802594:	43                   	inc    %ebx
  802595:	8d 0c 9d 00 00 00 00 	lea    0x0(,%ebx,4),%ecx
  80259c:	8b 04 9f             	mov    (%edi,%ebx,4),%eax
  80259f:	83 c4 10             	add    $0x10,%esp
  8025a2:	85 c0                	test   %eax,%eax
  8025a4:	75 e1                	jne    802587 <spawn+0xf3>
  8025a6:	89 9d 80 fd ff ff    	mov    %ebx,-0x280(%ebp)
  8025ac:	89 8d 7c fd ff ff    	mov    %ecx,-0x284(%ebp)
  8025b2:	eb 1e                	jmp    8025d2 <spawn+0x13e>
  8025b4:	c7 85 7c fd ff ff 00 	movl   $0x0,-0x284(%ebp)
  8025bb:	00 00 00 
  8025be:	c7 85 80 fd ff ff 00 	movl   $0x0,-0x280(%ebp)
  8025c5:	00 00 00 
	char *string_store;
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
  8025c8:	be 00 00 00 00       	mov    $0x0,%esi
	for (argc = 0; argv[argc] != 0; argc++)
  8025cd:	bb 00 00 00 00       	mov    $0x0,%ebx
	// Determine where to place the strings and the argv array.
	// Set up pointers into the temporary page 'UTEMP'; we'll map a page
	// there later, then remap that page into the child environment
	// at (USTACKTOP - PGSIZE).
	// strings is the topmost thing on the stack.
	string_store = (char*) UTEMP + PGSIZE - string_size;
  8025d2:	f7 de                	neg    %esi
  8025d4:	8d be 00 10 40 00    	lea    0x401000(%esi),%edi
	// argv is below that.  There's one argument pointer per argument, plus
	// a null pointer.
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));
  8025da:	89 fa                	mov    %edi,%edx
  8025dc:	83 e2 fc             	and    $0xfffffffc,%edx
  8025df:	89 d8                	mov    %ebx,%eax
  8025e1:	f7 d0                	not    %eax
  8025e3:	8d 04 82             	lea    (%edx,%eax,4),%eax
  8025e6:	89 85 94 fd ff ff    	mov    %eax,-0x26c(%ebp)

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
  8025ec:	83 e8 08             	sub    $0x8,%eax
  8025ef:	3d ff ff 3f 00       	cmp    $0x3fffff,%eax
  8025f4:	0f 86 11 04 00 00    	jbe    802a0b <spawn+0x577>
		return -E_NO_MEM;

	// Allocate the single stack page at UTEMP.
	if ((r = sys_page_alloc(0, (void*) UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  8025fa:	83 ec 04             	sub    $0x4,%esp
  8025fd:	6a 07                	push   $0x7
  8025ff:	68 00 00 40 00       	push   $0x400000
  802604:	6a 00                	push   $0x0
  802606:	e8 0d f0 ff ff       	call   801618 <sys_page_alloc>
  80260b:	83 c4 10             	add    $0x10,%esp
  80260e:	85 c0                	test   %eax,%eax
  802610:	0f 88 01 04 00 00    	js     802a17 <spawn+0x583>
	//	  (Again, argv should use an address valid in the child's
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
  802616:	85 db                	test   %ebx,%ebx
  802618:	7e 44                	jle    80265e <spawn+0x1ca>
  80261a:	be 00 00 00 00       	mov    $0x0,%esi
  80261f:	89 9d 8c fd ff ff    	mov    %ebx,-0x274(%ebp)
  802625:	8b 5d 0c             	mov    0xc(%ebp),%ebx
		argv_store[i] = UTEMP2USTACK(string_store);
  802628:	8d 87 00 d0 7f ee    	lea    -0x11803000(%edi),%eax
  80262e:	8b 95 94 fd ff ff    	mov    -0x26c(%ebp),%edx
  802634:	89 04 b2             	mov    %eax,(%edx,%esi,4)
		strcpy(string_store, argv[i]);
  802637:	83 ec 08             	sub    $0x8,%esp
  80263a:	ff 34 b3             	pushl  (%ebx,%esi,4)
  80263d:	57                   	push   %edi
  80263e:	e8 53 eb ff ff       	call   801196 <strcpy>
		string_store += strlen(argv[i]) + 1;
  802643:	83 c4 04             	add    $0x4,%esp
  802646:	ff 34 b3             	pushl  (%ebx,%esi,4)
  802649:	e8 f6 ea ff ff       	call   801144 <strlen>
  80264e:	8d 7c 07 01          	lea    0x1(%edi,%eax,1),%edi
	//	  (Again, argv should use an address valid in the child's
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
  802652:	46                   	inc    %esi
  802653:	83 c4 10             	add    $0x10,%esp
  802656:	3b b5 8c fd ff ff    	cmp    -0x274(%ebp),%esi
  80265c:	7c ca                	jl     802628 <spawn+0x194>
		argv_store[i] = UTEMP2USTACK(string_store);
		strcpy(string_store, argv[i]);
		string_store += strlen(argv[i]) + 1;
	}
	argv_store[argc] = 0;
  80265e:	8b 95 94 fd ff ff    	mov    -0x26c(%ebp),%edx
  802664:	8b 85 7c fd ff ff    	mov    -0x284(%ebp),%eax
  80266a:	c7 04 02 00 00 00 00 	movl   $0x0,(%edx,%eax,1)
	assert(string_store == (char*)UTEMP + PGSIZE);
  802671:	81 ff 00 10 40 00    	cmp    $0x401000,%edi
  802677:	74 19                	je     802692 <spawn+0x1fe>
  802679:	68 54 3b 80 00       	push   $0x803b54
  80267e:	68 72 34 80 00       	push   $0x803472
  802683:	68 f5 00 00 00       	push   $0xf5
  802688:	68 e4 3a 80 00       	push   $0x803ae4
  80268d:	e8 92 e3 ff ff       	call   800a24 <_panic>

	argv_store[-1] = UTEMP2USTACK(argv_store);
  802692:	8b 85 94 fd ff ff    	mov    -0x26c(%ebp),%eax
  802698:	2d 00 30 80 11       	sub    $0x11803000,%eax
  80269d:	8b 95 94 fd ff ff    	mov    -0x26c(%ebp),%edx
  8026a3:	89 42 fc             	mov    %eax,-0x4(%edx)
	argv_store[-2] = argc;
  8026a6:	8b 85 80 fd ff ff    	mov    -0x280(%ebp),%eax
  8026ac:	89 42 f8             	mov    %eax,-0x8(%edx)

	*init_esp = UTEMP2USTACK(&argv_store[-2]);
  8026af:	89 d0                	mov    %edx,%eax
  8026b1:	2d 08 30 80 11       	sub    $0x11803008,%eax
  8026b6:	89 85 e0 fd ff ff    	mov    %eax,-0x220(%ebp)

	// After completing the stack, map it into the child's address space
	// and unmap it from ours!
	if ((r = sys_page_map(0, UTEMP, child, (void*) (USTACKTOP - PGSIZE), PTE_P | PTE_U | PTE_W)) < 0)
  8026bc:	83 ec 0c             	sub    $0xc,%esp
  8026bf:	6a 07                	push   $0x7
  8026c1:	68 00 d0 bf ee       	push   $0xeebfd000
  8026c6:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  8026cc:	68 00 00 40 00       	push   $0x400000
  8026d1:	6a 00                	push   $0x0
  8026d3:	e8 64 ef ff ff       	call   80163c <sys_page_map>
  8026d8:	89 c3                	mov    %eax,%ebx
  8026da:	83 c4 20             	add    $0x20,%esp
  8026dd:	85 c0                	test   %eax,%eax
  8026df:	78 18                	js     8026f9 <spawn+0x265>
		goto error;
	if ((r = sys_page_unmap(0, UTEMP)) < 0)
  8026e1:	83 ec 08             	sub    $0x8,%esp
  8026e4:	68 00 00 40 00       	push   $0x400000
  8026e9:	6a 00                	push   $0x0
  8026eb:	e8 72 ef ff ff       	call   801662 <sys_page_unmap>
  8026f0:	89 c3                	mov    %eax,%ebx
  8026f2:	83 c4 10             	add    $0x10,%esp
  8026f5:	85 c0                	test   %eax,%eax
  8026f7:	79 1d                	jns    802716 <spawn+0x282>
		goto error;

	return 0;

error:
	sys_page_unmap(0, UTEMP);
  8026f9:	83 ec 08             	sub    $0x8,%esp
  8026fc:	68 00 00 40 00       	push   $0x400000
  802701:	6a 00                	push   $0x0
  802703:	e8 5a ef ff ff       	call   801662 <sys_page_unmap>
  802708:	83 c4 10             	add    $0x10,%esp
	return r;
  80270b:	89 9d 84 fd ff ff    	mov    %ebx,-0x27c(%ebp)
  802711:	e9 e7 02 00 00       	jmp    8029fd <spawn+0x569>
	if ((r = init_stack(child, argv, &child_tf.tf_esp)) < 0)
		return r;


	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
  802716:	8b 85 04 fe ff ff    	mov    -0x1fc(%ebp),%eax
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  80271c:	66 83 bd 14 fe ff ff 	cmpw   $0x0,-0x1ec(%ebp)
  802723:	00 
  802724:	0f 84 c3 01 00 00    	je     8028ed <spawn+0x459>
	if ((r = init_stack(child, argv, &child_tf.tf_esp)) < 0)
		return r;


	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
  80272a:	8d 84 05 e8 fd ff ff 	lea    -0x218(%ebp,%eax,1),%eax
  802731:	89 85 80 fd ff ff    	mov    %eax,-0x280(%ebp)
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  802737:	c7 85 7c fd ff ff 00 	movl   $0x0,-0x284(%ebp)
  80273e:	00 00 00 
		if (ph->p_type != ELF_PROG_LOAD)
  802741:	8b 95 80 fd ff ff    	mov    -0x280(%ebp),%edx
  802747:	83 3a 01             	cmpl   $0x1,(%edx)
  80274a:	0f 85 7c 01 00 00    	jne    8028cc <spawn+0x438>
			continue;
		perm = PTE_P | PTE_U;
		if (ph->p_flags & ELF_PROG_FLAG_WRITE)
  802750:	8b 42 18             	mov    0x18(%edx),%eax
  802753:	83 e0 02             	and    $0x2,%eax
	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
	for (i = 0; i < elf->e_phnum; i++, ph++) {
		if (ph->p_type != ELF_PROG_LOAD)
			continue;
		perm = PTE_P | PTE_U;
  802756:	83 f8 01             	cmp    $0x1,%eax
  802759:	19 db                	sbb    %ebx,%ebx
  80275b:	83 e3 fe             	and    $0xfffffffe,%ebx
  80275e:	83 c3 07             	add    $0x7,%ebx
		if (ph->p_flags & ELF_PROG_FLAG_WRITE)
			perm |= PTE_W;
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
  802761:	8b 42 04             	mov    0x4(%edx),%eax
  802764:	89 85 78 fd ff ff    	mov    %eax,-0x288(%ebp)
  80276a:	8b 52 10             	mov    0x10(%edx),%edx
  80276d:	89 95 94 fd ff ff    	mov    %edx,-0x26c(%ebp)
  802773:	8b 85 80 fd ff ff    	mov    -0x280(%ebp),%eax
  802779:	8b 40 14             	mov    0x14(%eax),%eax
  80277c:	89 85 8c fd ff ff    	mov    %eax,-0x274(%ebp)
  802782:	8b 95 80 fd ff ff    	mov    -0x280(%ebp),%edx
  802788:	8b 52 08             	mov    0x8(%edx),%edx
  80278b:	89 95 90 fd ff ff    	mov    %edx,-0x270(%ebp)
	int i, r;
	void *blk;

	//cprintf("map_segment %x+%x\n", va, memsz);

	if ((i = PGOFF(va))) {
  802791:	89 d0                	mov    %edx,%eax
  802793:	25 ff 0f 00 00       	and    $0xfff,%eax
  802798:	74 1a                	je     8027b4 <spawn+0x320>
		va -= i;
  80279a:	29 c2                	sub    %eax,%edx
  80279c:	89 95 90 fd ff ff    	mov    %edx,-0x270(%ebp)
		memsz += i;
  8027a2:	01 85 8c fd ff ff    	add    %eax,-0x274(%ebp)
		filesz += i;
  8027a8:	01 85 94 fd ff ff    	add    %eax,-0x26c(%ebp)
		fileoffset -= i;
  8027ae:	29 85 78 fd ff ff    	sub    %eax,-0x288(%ebp)
	}

	for (i = 0; i < memsz; i += PGSIZE) {
  8027b4:	83 bd 8c fd ff ff 00 	cmpl   $0x0,-0x274(%ebp)
  8027bb:	0f 84 0b 01 00 00    	je     8028cc <spawn+0x438>
  8027c1:	bf 00 00 00 00       	mov    $0x0,%edi
  8027c6:	be 00 00 00 00       	mov    $0x0,%esi
		if (i >= filesz) {
  8027cb:	3b bd 94 fd ff ff    	cmp    -0x26c(%ebp),%edi
  8027d1:	72 28                	jb     8027fb <spawn+0x367>
			// allocate a blank page
			if ((r = sys_page_alloc(child, (void*) (va + i), perm)) < 0)
  8027d3:	83 ec 04             	sub    $0x4,%esp
  8027d6:	53                   	push   %ebx
  8027d7:	03 bd 90 fd ff ff    	add    -0x270(%ebp),%edi
  8027dd:	57                   	push   %edi
  8027de:	ff b5 84 fd ff ff    	pushl  -0x27c(%ebp)
  8027e4:	e8 2f ee ff ff       	call   801618 <sys_page_alloc>
  8027e9:	83 c4 10             	add    $0x10,%esp
  8027ec:	85 c0                	test   %eax,%eax
  8027ee:	0f 89 c4 00 00 00    	jns    8028b8 <spawn+0x424>
  8027f4:	89 c3                	mov    %eax,%ebx
  8027f6:	e9 cf 01 00 00       	jmp    8029ca <spawn+0x536>
				return r;
		} else {
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  8027fb:	83 ec 04             	sub    $0x4,%esp
  8027fe:	6a 07                	push   $0x7
  802800:	68 00 00 40 00       	push   $0x400000
  802805:	6a 00                	push   $0x0
  802807:	e8 0c ee ff ff       	call   801618 <sys_page_alloc>
  80280c:	83 c4 10             	add    $0x10,%esp
  80280f:	85 c0                	test   %eax,%eax
  802811:	0f 88 a9 01 00 00    	js     8029c0 <spawn+0x52c>
				return r;
			if ((r = seek(fd, fileoffset + i)) < 0)
  802817:	83 ec 08             	sub    $0x8,%esp
// prog: the pathname of the program to run.
// argv: pointer to null-terminated array of pointers to strings,
// 	 which will be passed to the child as its command-line arguments.
// Returns child envid on success, < 0 on failure.
int
spawn(const char *prog, const char **argv)
  80281a:	8b 85 78 fd ff ff    	mov    -0x288(%ebp),%eax
  802820:	8d 04 06             	lea    (%esi,%eax,1),%eax
				return r;
		} else {
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
				return r;
			if ((r = seek(fd, fileoffset + i)) < 0)
  802823:	50                   	push   %eax
  802824:	ff b5 88 fd ff ff    	pushl  -0x278(%ebp)
  80282a:	e8 1b f8 ff ff       	call   80204a <seek>
  80282f:	83 c4 10             	add    $0x10,%esp
  802832:	85 c0                	test   %eax,%eax
  802834:	0f 88 8a 01 00 00    	js     8029c4 <spawn+0x530>
				return r;
			if ((r = readn(fd, UTEMP, MIN(PGSIZE, filesz-i))) < 0)
  80283a:	83 ec 04             	sub    $0x4,%esp
  80283d:	8b 85 94 fd ff ff    	mov    -0x26c(%ebp),%eax
  802843:	29 f8                	sub    %edi,%eax
  802845:	3d 00 10 00 00       	cmp    $0x1000,%eax
  80284a:	76 05                	jbe    802851 <spawn+0x3bd>
  80284c:	b8 00 10 00 00       	mov    $0x1000,%eax
  802851:	50                   	push   %eax
  802852:	68 00 00 40 00       	push   $0x400000
  802857:	ff b5 88 fd ff ff    	pushl  -0x278(%ebp)
  80285d:	e8 11 f7 ff ff       	call   801f73 <readn>
  802862:	83 c4 10             	add    $0x10,%esp
  802865:	85 c0                	test   %eax,%eax
  802867:	0f 88 5b 01 00 00    	js     8029c8 <spawn+0x534>
				return r;
			if ((r = sys_page_map(0, UTEMP, child, (void*) (va + i), perm)) < 0)
  80286d:	83 ec 0c             	sub    $0xc,%esp
  802870:	53                   	push   %ebx
  802871:	03 bd 90 fd ff ff    	add    -0x270(%ebp),%edi
  802877:	57                   	push   %edi
  802878:	ff b5 84 fd ff ff    	pushl  -0x27c(%ebp)
  80287e:	68 00 00 40 00       	push   $0x400000
  802883:	6a 00                	push   $0x0
  802885:	e8 b2 ed ff ff       	call   80163c <sys_page_map>
  80288a:	83 c4 20             	add    $0x20,%esp
  80288d:	85 c0                	test   %eax,%eax
  80288f:	79 15                	jns    8028a6 <spawn+0x412>
				panic("spawn: sys_page_map data: %e", r);
  802891:	50                   	push   %eax
  802892:	68 f0 3a 80 00       	push   $0x803af0
  802897:	68 28 01 00 00       	push   $0x128
  80289c:	68 e4 3a 80 00       	push   $0x803ae4
  8028a1:	e8 7e e1 ff ff       	call   800a24 <_panic>
			sys_page_unmap(0, UTEMP);
  8028a6:	83 ec 08             	sub    $0x8,%esp
  8028a9:	68 00 00 40 00       	push   $0x400000
  8028ae:	6a 00                	push   $0x0
  8028b0:	e8 ad ed ff ff       	call   801662 <sys_page_unmap>
  8028b5:	83 c4 10             	add    $0x10,%esp
		memsz += i;
		filesz += i;
		fileoffset -= i;
	}

	for (i = 0; i < memsz; i += PGSIZE) {
  8028b8:	81 c6 00 10 00 00    	add    $0x1000,%esi
  8028be:	89 f7                	mov    %esi,%edi
  8028c0:	39 b5 8c fd ff ff    	cmp    %esi,-0x274(%ebp)
  8028c6:	0f 87 ff fe ff ff    	ja     8027cb <spawn+0x337>
		return r;


	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  8028cc:	ff 85 7c fd ff ff    	incl   -0x284(%ebp)
  8028d2:	0f b7 85 14 fe ff ff 	movzwl -0x1ec(%ebp),%eax
  8028d9:	3b 85 7c fd ff ff    	cmp    -0x284(%ebp),%eax
  8028df:	7e 0c                	jle    8028ed <spawn+0x459>
  8028e1:	83 85 80 fd ff ff 20 	addl   $0x20,-0x280(%ebp)
  8028e8:	e9 54 fe ff ff       	jmp    802741 <spawn+0x2ad>
			perm |= PTE_W;
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
				     fd, ph->p_filesz, ph->p_offset, perm)) < 0)
			goto error;
	}
	close(fd);
  8028ed:	83 ec 0c             	sub    $0xc,%esp
  8028f0:	ff b5 88 fd ff ff    	pushl  -0x278(%ebp)
  8028f6:	e8 b4 f4 ff ff       	call   801daf <close>
  8028fb:	83 c4 10             	add    $0x10,%esp
copy_shared_pages(envid_t child)
{
	// LAB 5: Your code here.
    uint32_t i;
    int r;
    for (i = 0; i != UTOP; i += PGSIZE) 
  8028fe:	bb 00 00 00 00       	mov    $0x0,%ebx
  802903:	8b b5 84 fd ff ff    	mov    -0x27c(%ebp),%esi
    if ((uvpd[PDX(i)] & PTE_P) && (uvpt[i / PGSIZE] & PTE_P) && (uvpt[i / PGSIZE] & PTE_SHARE)) {
  802909:	89 d8                	mov    %ebx,%eax
  80290b:	c1 e8 16             	shr    $0x16,%eax
  80290e:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  802915:	a8 01                	test   $0x1,%al
  802917:	74 3e                	je     802957 <spawn+0x4c3>
  802919:	89 d8                	mov    %ebx,%eax
  80291b:	c1 e8 0c             	shr    $0xc,%eax
  80291e:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  802925:	f6 c2 01             	test   $0x1,%dl
  802928:	74 2d                	je     802957 <spawn+0x4c3>
  80292a:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  802931:	f6 c6 04             	test   $0x4,%dh
  802934:	74 21                	je     802957 <spawn+0x4c3>
        r = sys_page_map(0, (void *)i, child, (void *)i, uvpt[i / PGSIZE] & PTE_SYSCALL);
  802936:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80293d:	83 ec 0c             	sub    $0xc,%esp
  802940:	25 07 0e 00 00       	and    $0xe07,%eax
  802945:	50                   	push   %eax
  802946:	53                   	push   %ebx
  802947:	56                   	push   %esi
  802948:	53                   	push   %ebx
  802949:	6a 00                	push   $0x0
  80294b:	e8 ec ec ff ff       	call   80163c <sys_page_map>
        if (r < 0) return r;
  802950:	83 c4 20             	add    $0x20,%esp
  802953:	85 c0                	test   %eax,%eax
  802955:	78 13                	js     80296a <spawn+0x4d6>
copy_shared_pages(envid_t child)
{
	// LAB 5: Your code here.
    uint32_t i;
    int r;
    for (i = 0; i != UTOP; i += PGSIZE) 
  802957:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  80295d:	81 fb 00 00 c0 ee    	cmp    $0xeec00000,%ebx
  802963:	75 a4                	jne    802909 <spawn+0x475>
  802965:	e9 b5 00 00 00       	jmp    802a1f <spawn+0x58b>
	close(fd);
	fd = -1;

	// Copy shared library state.
	if ((r = copy_shared_pages(child)) < 0)
		panic("copy_shared_pages: %e", r);
  80296a:	50                   	push   %eax
  80296b:	68 0d 3b 80 00       	push   $0x803b0d
  802970:	68 86 00 00 00       	push   $0x86
  802975:	68 e4 3a 80 00       	push   $0x803ae4
  80297a:	e8 a5 e0 ff ff       	call   800a24 <_panic>

	if ((r = sys_env_set_trapframe(child, &child_tf)) < 0)
		panic("sys_env_set_trapframe: %e", r);
  80297f:	50                   	push   %eax
  802980:	68 23 3b 80 00       	push   $0x803b23
  802985:	68 89 00 00 00       	push   $0x89
  80298a:	68 e4 3a 80 00       	push   $0x803ae4
  80298f:	e8 90 e0 ff ff       	call   800a24 <_panic>

	if ((r = sys_env_set_status(child, ENV_RUNNABLE)) < 0)
  802994:	83 ec 08             	sub    $0x8,%esp
  802997:	6a 02                	push   $0x2
  802999:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  80299f:	e8 e1 ec ff ff       	call   801685 <sys_env_set_status>
  8029a4:	83 c4 10             	add    $0x10,%esp
  8029a7:	85 c0                	test   %eax,%eax
  8029a9:	79 52                	jns    8029fd <spawn+0x569>
		panic("sys_env_set_status: %e", r);
  8029ab:	50                   	push   %eax
  8029ac:	68 3d 3b 80 00       	push   $0x803b3d
  8029b1:	68 8c 00 00 00       	push   $0x8c
  8029b6:	68 e4 3a 80 00       	push   $0x803ae4
  8029bb:	e8 64 e0 ff ff       	call   800a24 <_panic>
  8029c0:	89 c3                	mov    %eax,%ebx
  8029c2:	eb 06                	jmp    8029ca <spawn+0x536>
  8029c4:	89 c3                	mov    %eax,%ebx
  8029c6:	eb 02                	jmp    8029ca <spawn+0x536>
  8029c8:	89 c3                	mov    %eax,%ebx

	return child;

error:
	sys_env_destroy(child);
  8029ca:	83 ec 0c             	sub    $0xc,%esp
  8029cd:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  8029d3:	e8 d3 eb ff ff       	call   8015ab <sys_env_destroy>
	close(fd);
  8029d8:	83 c4 04             	add    $0x4,%esp
  8029db:	ff b5 88 fd ff ff    	pushl  -0x278(%ebp)
  8029e1:	e8 c9 f3 ff ff       	call   801daf <close>
	return r;
  8029e6:	83 c4 10             	add    $0x10,%esp
  8029e9:	89 9d 84 fd ff ff    	mov    %ebx,-0x27c(%ebp)
  8029ef:	eb 0c                	jmp    8029fd <spawn+0x569>
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
		return r;
  8029f1:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  8029f7:	89 85 84 fd ff ff    	mov    %eax,-0x27c(%ebp)

error:
	sys_env_destroy(child);
	close(fd);
	return r;
}
  8029fd:	8b 85 84 fd ff ff    	mov    -0x27c(%ebp),%eax
  802a03:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802a06:	5b                   	pop    %ebx
  802a07:	5e                   	pop    %esi
  802a08:	5f                   	pop    %edi
  802a09:	c9                   	leave  
  802a0a:	c3                   	ret    
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
		return -E_NO_MEM;
  802a0b:	c7 85 84 fd ff ff fc 	movl   $0xfffffffc,-0x27c(%ebp)
  802a12:	ff ff ff 
  802a15:	eb e6                	jmp    8029fd <spawn+0x569>

	// Allocate the single stack page at UTEMP.
	if ((r = sys_page_alloc(0, (void*) UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
		return r;
  802a17:	89 85 84 fd ff ff    	mov    %eax,-0x27c(%ebp)
  802a1d:	eb de                	jmp    8029fd <spawn+0x569>

	// Copy shared library state.
	if ((r = copy_shared_pages(child)) < 0)
		panic("copy_shared_pages: %e", r);

	if ((r = sys_env_set_trapframe(child, &child_tf)) < 0)
  802a1f:	83 ec 08             	sub    $0x8,%esp
  802a22:	8d 85 a4 fd ff ff    	lea    -0x25c(%ebp),%eax
  802a28:	50                   	push   %eax
  802a29:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  802a2f:	e8 74 ec ff ff       	call   8016a8 <sys_env_set_trapframe>
  802a34:	83 c4 10             	add    $0x10,%esp
  802a37:	85 c0                	test   %eax,%eax
  802a39:	0f 89 55 ff ff ff    	jns    802994 <spawn+0x500>
  802a3f:	e9 3b ff ff ff       	jmp    80297f <spawn+0x4eb>

00802a44 <spawnl>:
// Spawn, taking command-line arguments array directly on the stack.
// NOTE: Must have a sentinal of NULL at the end of the args
// (none of the args may be NULL).
int
spawnl(const char *prog, const char *arg0, ...)
{
  802a44:	55                   	push   %ebp
  802a45:	89 e5                	mov    %esp,%ebp
  802a47:	56                   	push   %esi
  802a48:	53                   	push   %ebx
  802a49:	8b 75 0c             	mov    0xc(%ebp),%esi
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  802a4c:	8d 45 14             	lea    0x14(%ebp),%eax
  802a4f:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  802a53:	74 5f                	je     802ab4 <spawnl+0x70>
{
	// We calculate argc by advancing the args until we hit NULL.
	// The contract of the function guarantees that the last
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
  802a55:	b9 00 00 00 00       	mov    $0x0,%ecx
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
		argc++;
  802a5a:	41                   	inc    %ecx
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  802a5b:	89 c2                	mov    %eax,%edx
  802a5d:	83 c0 04             	add    $0x4,%eax
  802a60:	83 3a 00             	cmpl   $0x0,(%edx)
  802a63:	75 f5                	jne    802a5a <spawnl+0x16>
		argc++;
	va_end(vl);

	// Now that we have the size of the args, do a second pass
	// and store the values in a VLA, which has the format of argv
	const char *argv[argc+2];
  802a65:	8d 04 8d 26 00 00 00 	lea    0x26(,%ecx,4),%eax
  802a6c:	83 e0 f0             	and    $0xfffffff0,%eax
  802a6f:	29 c4                	sub    %eax,%esp
  802a71:	8d 44 24 0f          	lea    0xf(%esp),%eax
  802a75:	83 e0 f0             	and    $0xfffffff0,%eax
  802a78:	89 c3                	mov    %eax,%ebx
	argv[0] = arg0;
  802a7a:	89 30                	mov    %esi,(%eax)
	argv[argc+1] = NULL;
  802a7c:	c7 44 88 04 00 00 00 	movl   $0x0,0x4(%eax,%ecx,4)
  802a83:	00 

	va_start(vl, arg0);
  802a84:	8d 55 10             	lea    0x10(%ebp),%edx
	unsigned i;
	for(i=0;i<argc;i++)
  802a87:	89 ce                	mov    %ecx,%esi
  802a89:	85 c9                	test   %ecx,%ecx
  802a8b:	74 14                	je     802aa1 <spawnl+0x5d>
  802a8d:	b8 00 00 00 00       	mov    $0x0,%eax
		argv[i+1] = va_arg(vl, const char *);
  802a92:	40                   	inc    %eax
  802a93:	89 d1                	mov    %edx,%ecx
  802a95:	83 c2 04             	add    $0x4,%edx
  802a98:	8b 09                	mov    (%ecx),%ecx
  802a9a:	89 0c 83             	mov    %ecx,(%ebx,%eax,4)
	argv[0] = arg0;
	argv[argc+1] = NULL;

	va_start(vl, arg0);
	unsigned i;
	for(i=0;i<argc;i++)
  802a9d:	39 f0                	cmp    %esi,%eax
  802a9f:	72 f1                	jb     802a92 <spawnl+0x4e>
		argv[i+1] = va_arg(vl, const char *);
	va_end(vl);
	return spawn(prog, argv);
  802aa1:	83 ec 08             	sub    $0x8,%esp
  802aa4:	53                   	push   %ebx
  802aa5:	ff 75 08             	pushl  0x8(%ebp)
  802aa8:	e8 e7 f9 ff ff       	call   802494 <spawn>
}
  802aad:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802ab0:	5b                   	pop    %ebx
  802ab1:	5e                   	pop    %esi
  802ab2:	c9                   	leave  
  802ab3:	c3                   	ret    
		argc++;
	va_end(vl);

	// Now that we have the size of the args, do a second pass
	// and store the values in a VLA, which has the format of argv
	const char *argv[argc+2];
  802ab4:	83 ec 20             	sub    $0x20,%esp
  802ab7:	8d 44 24 0f          	lea    0xf(%esp),%eax
  802abb:	83 e0 f0             	and    $0xfffffff0,%eax
  802abe:	89 c3                	mov    %eax,%ebx
	argv[0] = arg0;
  802ac0:	89 30                	mov    %esi,(%eax)
	argv[argc+1] = NULL;
  802ac2:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
  802ac9:	eb d6                	jmp    802aa1 <spawnl+0x5d>
	...

00802acc <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  802acc:	55                   	push   %ebp
  802acd:	89 e5                	mov    %esp,%ebp
  802acf:	56                   	push   %esi
  802ad0:	53                   	push   %ebx
  802ad1:	8b 75 0c             	mov    0xc(%ebp),%esi
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  802ad4:	83 ec 0c             	sub    $0xc,%esp
  802ad7:	ff 75 08             	pushl  0x8(%ebp)
  802ada:	e8 01 f1 ff ff       	call   801be0 <fd2data>
  802adf:	89 c3                	mov    %eax,%ebx
	strcpy(stat->st_name, "<pipe>");
  802ae1:	83 c4 08             	add    $0x8,%esp
  802ae4:	68 7a 3b 80 00       	push   $0x803b7a
  802ae9:	56                   	push   %esi
  802aea:	e8 a7 e6 ff ff       	call   801196 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  802aef:	8b 43 04             	mov    0x4(%ebx),%eax
  802af2:	2b 03                	sub    (%ebx),%eax
  802af4:	89 86 80 00 00 00    	mov    %eax,0x80(%esi)
	stat->st_isdir = 0;
  802afa:	c7 86 84 00 00 00 00 	movl   $0x0,0x84(%esi)
  802b01:	00 00 00 
	stat->st_dev = &devpipe;
  802b04:	c7 86 88 00 00 00 3c 	movl   $0x80403c,0x88(%esi)
  802b0b:	40 80 00 
	return 0;
}
  802b0e:	b8 00 00 00 00       	mov    $0x0,%eax
  802b13:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802b16:	5b                   	pop    %ebx
  802b17:	5e                   	pop    %esi
  802b18:	c9                   	leave  
  802b19:	c3                   	ret    

00802b1a <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  802b1a:	55                   	push   %ebp
  802b1b:	89 e5                	mov    %esp,%ebp
  802b1d:	53                   	push   %ebx
  802b1e:	83 ec 0c             	sub    $0xc,%esp
  802b21:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  802b24:	53                   	push   %ebx
  802b25:	6a 00                	push   $0x0
  802b27:	e8 36 eb ff ff       	call   801662 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  802b2c:	89 1c 24             	mov    %ebx,(%esp)
  802b2f:	e8 ac f0 ff ff       	call   801be0 <fd2data>
  802b34:	83 c4 08             	add    $0x8,%esp
  802b37:	50                   	push   %eax
  802b38:	6a 00                	push   $0x0
  802b3a:	e8 23 eb ff ff       	call   801662 <sys_page_unmap>
}
  802b3f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802b42:	c9                   	leave  
  802b43:	c3                   	ret    

00802b44 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  802b44:	55                   	push   %ebp
  802b45:	89 e5                	mov    %esp,%ebp
  802b47:	57                   	push   %edi
  802b48:	56                   	push   %esi
  802b49:	53                   	push   %ebx
  802b4a:	83 ec 1c             	sub    $0x1c,%esp
  802b4d:	89 c7                	mov    %eax,%edi
  802b4f:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  802b52:	a1 24 54 80 00       	mov    0x805424,%eax
  802b57:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  802b5a:	83 ec 0c             	sub    $0xc,%esp
  802b5d:	57                   	push   %edi
  802b5e:	e8 21 05 00 00       	call   803084 <pageref>
  802b63:	89 c6                	mov    %eax,%esi
  802b65:	83 c4 04             	add    $0x4,%esp
  802b68:	ff 75 e4             	pushl  -0x1c(%ebp)
  802b6b:	e8 14 05 00 00       	call   803084 <pageref>
  802b70:	83 c4 10             	add    $0x10,%esp
  802b73:	39 c6                	cmp    %eax,%esi
  802b75:	0f 94 c0             	sete   %al
  802b78:	0f b6 c0             	movzbl %al,%eax
		nn = thisenv->env_runs;
  802b7b:	8b 15 24 54 80 00    	mov    0x805424,%edx
  802b81:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  802b84:	39 cb                	cmp    %ecx,%ebx
  802b86:	75 08                	jne    802b90 <_pipeisclosed+0x4c>
			return ret;
		if (n != nn && ret == 1)
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
	}
}
  802b88:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802b8b:	5b                   	pop    %ebx
  802b8c:	5e                   	pop    %esi
  802b8d:	5f                   	pop    %edi
  802b8e:	c9                   	leave  
  802b8f:	c3                   	ret    
		n = thisenv->env_runs;
		ret = pageref(fd) == pageref(p);
		nn = thisenv->env_runs;
		if (n == nn)
			return ret;
		if (n != nn && ret == 1)
  802b90:	83 f8 01             	cmp    $0x1,%eax
  802b93:	75 bd                	jne    802b52 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  802b95:	8b 42 58             	mov    0x58(%edx),%eax
  802b98:	6a 01                	push   $0x1
  802b9a:	50                   	push   %eax
  802b9b:	53                   	push   %ebx
  802b9c:	68 81 3b 80 00       	push   $0x803b81
  802ba1:	e8 56 df ff ff       	call   800afc <cprintf>
  802ba6:	83 c4 10             	add    $0x10,%esp
  802ba9:	eb a7                	jmp    802b52 <_pipeisclosed+0xe>

00802bab <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  802bab:	55                   	push   %ebp
  802bac:	89 e5                	mov    %esp,%ebp
  802bae:	57                   	push   %edi
  802baf:	56                   	push   %esi
  802bb0:	53                   	push   %ebx
  802bb1:	83 ec 28             	sub    $0x28,%esp
  802bb4:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  802bb7:	56                   	push   %esi
  802bb8:	e8 23 f0 ff ff       	call   801be0 <fd2data>
  802bbd:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802bbf:	83 c4 10             	add    $0x10,%esp
  802bc2:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  802bc6:	75 4a                	jne    802c12 <devpipe_write+0x67>
  802bc8:	bf 00 00 00 00       	mov    $0x0,%edi
  802bcd:	eb 56                	jmp    802c25 <devpipe_write+0x7a>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  802bcf:	89 da                	mov    %ebx,%edx
  802bd1:	89 f0                	mov    %esi,%eax
  802bd3:	e8 6c ff ff ff       	call   802b44 <_pipeisclosed>
  802bd8:	85 c0                	test   %eax,%eax
  802bda:	75 4d                	jne    802c29 <devpipe_write+0x7e>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  802bdc:	e8 10 ea ff ff       	call   8015f1 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  802be1:	8b 43 04             	mov    0x4(%ebx),%eax
  802be4:	8b 13                	mov    (%ebx),%edx
  802be6:	83 c2 20             	add    $0x20,%edx
  802be9:	39 d0                	cmp    %edx,%eax
  802beb:	73 e2                	jae    802bcf <devpipe_write+0x24>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  802bed:	89 c2                	mov    %eax,%edx
  802bef:	81 e2 1f 00 00 80    	and    $0x8000001f,%edx
  802bf5:	79 05                	jns    802bfc <devpipe_write+0x51>
  802bf7:	4a                   	dec    %edx
  802bf8:	83 ca e0             	or     $0xffffffe0,%edx
  802bfb:	42                   	inc    %edx
  802bfc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802bff:	8a 0c 39             	mov    (%ecx,%edi,1),%cl
  802c02:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  802c06:	40                   	inc    %eax
  802c07:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802c0a:	47                   	inc    %edi
  802c0b:	39 7d 10             	cmp    %edi,0x10(%ebp)
  802c0e:	77 07                	ja     802c17 <devpipe_write+0x6c>
  802c10:	eb 13                	jmp    802c25 <devpipe_write+0x7a>
  802c12:	bf 00 00 00 00       	mov    $0x0,%edi
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  802c17:	8b 43 04             	mov    0x4(%ebx),%eax
  802c1a:	8b 13                	mov    (%ebx),%edx
  802c1c:	83 c2 20             	add    $0x20,%edx
  802c1f:	39 d0                	cmp    %edx,%eax
  802c21:	73 ac                	jae    802bcf <devpipe_write+0x24>
  802c23:	eb c8                	jmp    802bed <devpipe_write+0x42>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  802c25:	89 f8                	mov    %edi,%eax
  802c27:	eb 05                	jmp    802c2e <devpipe_write+0x83>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  802c29:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  802c2e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802c31:	5b                   	pop    %ebx
  802c32:	5e                   	pop    %esi
  802c33:	5f                   	pop    %edi
  802c34:	c9                   	leave  
  802c35:	c3                   	ret    

00802c36 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  802c36:	55                   	push   %ebp
  802c37:	89 e5                	mov    %esp,%ebp
  802c39:	57                   	push   %edi
  802c3a:	56                   	push   %esi
  802c3b:	53                   	push   %ebx
  802c3c:	83 ec 18             	sub    $0x18,%esp
  802c3f:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  802c42:	57                   	push   %edi
  802c43:	e8 98 ef ff ff       	call   801be0 <fd2data>
  802c48:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802c4a:	83 c4 10             	add    $0x10,%esp
  802c4d:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  802c51:	75 44                	jne    802c97 <devpipe_read+0x61>
  802c53:	be 00 00 00 00       	mov    $0x0,%esi
  802c58:	eb 4f                	jmp    802ca9 <devpipe_read+0x73>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
				return i;
  802c5a:	89 f0                	mov    %esi,%eax
  802c5c:	eb 54                	jmp    802cb2 <devpipe_read+0x7c>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  802c5e:	89 da                	mov    %ebx,%edx
  802c60:	89 f8                	mov    %edi,%eax
  802c62:	e8 dd fe ff ff       	call   802b44 <_pipeisclosed>
  802c67:	85 c0                	test   %eax,%eax
  802c69:	75 42                	jne    802cad <devpipe_read+0x77>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  802c6b:	e8 81 e9 ff ff       	call   8015f1 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  802c70:	8b 03                	mov    (%ebx),%eax
  802c72:	3b 43 04             	cmp    0x4(%ebx),%eax
  802c75:	74 e7                	je     802c5e <devpipe_read+0x28>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  802c77:	25 1f 00 00 80       	and    $0x8000001f,%eax
  802c7c:	79 05                	jns    802c83 <devpipe_read+0x4d>
  802c7e:	48                   	dec    %eax
  802c7f:	83 c8 e0             	or     $0xffffffe0,%eax
  802c82:	40                   	inc    %eax
  802c83:	8a 44 03 08          	mov    0x8(%ebx,%eax,1),%al
  802c87:	8b 55 0c             	mov    0xc(%ebp),%edx
  802c8a:	88 04 32             	mov    %al,(%edx,%esi,1)
		p->p_rpos++;
  802c8d:	ff 03                	incl   (%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802c8f:	46                   	inc    %esi
  802c90:	39 75 10             	cmp    %esi,0x10(%ebp)
  802c93:	77 07                	ja     802c9c <devpipe_read+0x66>
  802c95:	eb 12                	jmp    802ca9 <devpipe_read+0x73>
  802c97:	be 00 00 00 00       	mov    $0x0,%esi
		while (p->p_rpos == p->p_wpos) {
  802c9c:	8b 03                	mov    (%ebx),%eax
  802c9e:	3b 43 04             	cmp    0x4(%ebx),%eax
  802ca1:	75 d4                	jne    802c77 <devpipe_read+0x41>
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  802ca3:	85 f6                	test   %esi,%esi
  802ca5:	75 b3                	jne    802c5a <devpipe_read+0x24>
  802ca7:	eb b5                	jmp    802c5e <devpipe_read+0x28>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  802ca9:	89 f0                	mov    %esi,%eax
  802cab:	eb 05                	jmp    802cb2 <devpipe_read+0x7c>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  802cad:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  802cb2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802cb5:	5b                   	pop    %ebx
  802cb6:	5e                   	pop    %esi
  802cb7:	5f                   	pop    %edi
  802cb8:	c9                   	leave  
  802cb9:	c3                   	ret    

00802cba <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  802cba:	55                   	push   %ebp
  802cbb:	89 e5                	mov    %esp,%ebp
  802cbd:	57                   	push   %edi
  802cbe:	56                   	push   %esi
  802cbf:	53                   	push   %ebx
  802cc0:	83 ec 28             	sub    $0x28,%esp
  802cc3:	8b 7d 08             	mov    0x8(%ebp),%edi
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  802cc6:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  802cc9:	50                   	push   %eax
  802cca:	e8 29 ef ff ff       	call   801bf8 <fd_alloc>
  802ccf:	89 c3                	mov    %eax,%ebx
  802cd1:	83 c4 10             	add    $0x10,%esp
  802cd4:	85 c0                	test   %eax,%eax
  802cd6:	0f 88 24 01 00 00    	js     802e00 <pipe+0x146>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802cdc:	83 ec 04             	sub    $0x4,%esp
  802cdf:	68 07 04 00 00       	push   $0x407
  802ce4:	ff 75 e4             	pushl  -0x1c(%ebp)
  802ce7:	6a 00                	push   $0x0
  802ce9:	e8 2a e9 ff ff       	call   801618 <sys_page_alloc>
  802cee:	89 c3                	mov    %eax,%ebx
  802cf0:	83 c4 10             	add    $0x10,%esp
  802cf3:	85 c0                	test   %eax,%eax
  802cf5:	0f 88 05 01 00 00    	js     802e00 <pipe+0x146>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  802cfb:	83 ec 0c             	sub    $0xc,%esp
  802cfe:	8d 45 e0             	lea    -0x20(%ebp),%eax
  802d01:	50                   	push   %eax
  802d02:	e8 f1 ee ff ff       	call   801bf8 <fd_alloc>
  802d07:	89 c3                	mov    %eax,%ebx
  802d09:	83 c4 10             	add    $0x10,%esp
  802d0c:	85 c0                	test   %eax,%eax
  802d0e:	0f 88 dc 00 00 00    	js     802df0 <pipe+0x136>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802d14:	83 ec 04             	sub    $0x4,%esp
  802d17:	68 07 04 00 00       	push   $0x407
  802d1c:	ff 75 e0             	pushl  -0x20(%ebp)
  802d1f:	6a 00                	push   $0x0
  802d21:	e8 f2 e8 ff ff       	call   801618 <sys_page_alloc>
  802d26:	89 c3                	mov    %eax,%ebx
  802d28:	83 c4 10             	add    $0x10,%esp
  802d2b:	85 c0                	test   %eax,%eax
  802d2d:	0f 88 bd 00 00 00    	js     802df0 <pipe+0x136>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  802d33:	83 ec 0c             	sub    $0xc,%esp
  802d36:	ff 75 e4             	pushl  -0x1c(%ebp)
  802d39:	e8 a2 ee ff ff       	call   801be0 <fd2data>
  802d3e:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802d40:	83 c4 0c             	add    $0xc,%esp
  802d43:	68 07 04 00 00       	push   $0x407
  802d48:	50                   	push   %eax
  802d49:	6a 00                	push   $0x0
  802d4b:	e8 c8 e8 ff ff       	call   801618 <sys_page_alloc>
  802d50:	89 c3                	mov    %eax,%ebx
  802d52:	83 c4 10             	add    $0x10,%esp
  802d55:	85 c0                	test   %eax,%eax
  802d57:	0f 88 83 00 00 00    	js     802de0 <pipe+0x126>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802d5d:	83 ec 0c             	sub    $0xc,%esp
  802d60:	ff 75 e0             	pushl  -0x20(%ebp)
  802d63:	e8 78 ee ff ff       	call   801be0 <fd2data>
  802d68:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  802d6f:	50                   	push   %eax
  802d70:	6a 00                	push   $0x0
  802d72:	56                   	push   %esi
  802d73:	6a 00                	push   $0x0
  802d75:	e8 c2 e8 ff ff       	call   80163c <sys_page_map>
  802d7a:	89 c3                	mov    %eax,%ebx
  802d7c:	83 c4 20             	add    $0x20,%esp
  802d7f:	85 c0                	test   %eax,%eax
  802d81:	78 4f                	js     802dd2 <pipe+0x118>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  802d83:	8b 15 3c 40 80 00    	mov    0x80403c,%edx
  802d89:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802d8c:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  802d8e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802d91:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  802d98:	8b 15 3c 40 80 00    	mov    0x80403c,%edx
  802d9e:	8b 45 e0             	mov    -0x20(%ebp),%eax
  802da1:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  802da3:	8b 45 e0             	mov    -0x20(%ebp),%eax
  802da6:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  802dad:	83 ec 0c             	sub    $0xc,%esp
  802db0:	ff 75 e4             	pushl  -0x1c(%ebp)
  802db3:	e8 18 ee ff ff       	call   801bd0 <fd2num>
  802db8:	89 07                	mov    %eax,(%edi)
	pfd[1] = fd2num(fd1);
  802dba:	83 c4 04             	add    $0x4,%esp
  802dbd:	ff 75 e0             	pushl  -0x20(%ebp)
  802dc0:	e8 0b ee ff ff       	call   801bd0 <fd2num>
  802dc5:	89 47 04             	mov    %eax,0x4(%edi)
	return 0;
  802dc8:	83 c4 10             	add    $0x10,%esp
  802dcb:	bb 00 00 00 00       	mov    $0x0,%ebx
  802dd0:	eb 2e                	jmp    802e00 <pipe+0x146>

    err3:
	sys_page_unmap(0, va);
  802dd2:	83 ec 08             	sub    $0x8,%esp
  802dd5:	56                   	push   %esi
  802dd6:	6a 00                	push   $0x0
  802dd8:	e8 85 e8 ff ff       	call   801662 <sys_page_unmap>
  802ddd:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  802de0:	83 ec 08             	sub    $0x8,%esp
  802de3:	ff 75 e0             	pushl  -0x20(%ebp)
  802de6:	6a 00                	push   $0x0
  802de8:	e8 75 e8 ff ff       	call   801662 <sys_page_unmap>
  802ded:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  802df0:	83 ec 08             	sub    $0x8,%esp
  802df3:	ff 75 e4             	pushl  -0x1c(%ebp)
  802df6:	6a 00                	push   $0x0
  802df8:	e8 65 e8 ff ff       	call   801662 <sys_page_unmap>
  802dfd:	83 c4 10             	add    $0x10,%esp
    err:
	return r;
}
  802e00:	89 d8                	mov    %ebx,%eax
  802e02:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802e05:	5b                   	pop    %ebx
  802e06:	5e                   	pop    %esi
  802e07:	5f                   	pop    %edi
  802e08:	c9                   	leave  
  802e09:	c3                   	ret    

00802e0a <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  802e0a:	55                   	push   %ebp
  802e0b:	89 e5                	mov    %esp,%ebp
  802e0d:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802e10:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802e13:	50                   	push   %eax
  802e14:	ff 75 08             	pushl  0x8(%ebp)
  802e17:	e8 4f ee ff ff       	call   801c6b <fd_lookup>
  802e1c:	83 c4 10             	add    $0x10,%esp
  802e1f:	85 c0                	test   %eax,%eax
  802e21:	78 18                	js     802e3b <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  802e23:	83 ec 0c             	sub    $0xc,%esp
  802e26:	ff 75 f4             	pushl  -0xc(%ebp)
  802e29:	e8 b2 ed ff ff       	call   801be0 <fd2data>
	return _pipeisclosed(fd, p);
  802e2e:	89 c2                	mov    %eax,%edx
  802e30:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802e33:	e8 0c fd ff ff       	call   802b44 <_pipeisclosed>
  802e38:	83 c4 10             	add    $0x10,%esp
}
  802e3b:	c9                   	leave  
  802e3c:	c3                   	ret    
  802e3d:	00 00                	add    %al,(%eax)
	...

00802e40 <wait>:
#include <inc/lib.h>

// Waits until 'envid' exits.
void
wait(envid_t envid)
{
  802e40:	55                   	push   %ebp
  802e41:	89 e5                	mov    %esp,%ebp
  802e43:	57                   	push   %edi
  802e44:	56                   	push   %esi
  802e45:	53                   	push   %ebx
  802e46:	83 ec 0c             	sub    $0xc,%esp
  802e49:	8b 45 08             	mov    0x8(%ebp),%eax
	const volatile struct Env *e;

	assert(envid != 0);
  802e4c:	85 c0                	test   %eax,%eax
  802e4e:	75 16                	jne    802e66 <wait+0x26>
  802e50:	68 99 3b 80 00       	push   $0x803b99
  802e55:	68 72 34 80 00       	push   $0x803472
  802e5a:	6a 09                	push   $0x9
  802e5c:	68 a4 3b 80 00       	push   $0x803ba4
  802e61:	e8 be db ff ff       	call   800a24 <_panic>
	e = &envs[ENVX(envid)];
  802e66:	89 c6                	mov    %eax,%esi
  802e68:	81 e6 ff 03 00 00    	and    $0x3ff,%esi
	while (e->env_id == envid && e->env_status != ENV_FREE)
  802e6e:	8d 0c b5 00 00 00 00 	lea    0x0(,%esi,4),%ecx
  802e75:	89 f2                	mov    %esi,%edx
  802e77:	c1 e2 07             	shl    $0x7,%edx
  802e7a:	29 ca                	sub    %ecx,%edx
  802e7c:	81 c2 08 00 c0 ee    	add    $0xeec00008,%edx
  802e82:	8b 7a 40             	mov    0x40(%edx),%edi
  802e85:	39 c7                	cmp    %eax,%edi
  802e87:	75 37                	jne    802ec0 <wait+0x80>
  802e89:	89 f0                	mov    %esi,%eax
  802e8b:	c1 e0 07             	shl    $0x7,%eax
  802e8e:	29 c8                	sub    %ecx,%eax
  802e90:	05 04 00 c0 ee       	add    $0xeec00004,%eax
  802e95:	8b 40 50             	mov    0x50(%eax),%eax
  802e98:	85 c0                	test   %eax,%eax
  802e9a:	74 24                	je     802ec0 <wait+0x80>
  802e9c:	c1 e6 07             	shl    $0x7,%esi
  802e9f:	29 ce                	sub    %ecx,%esi
  802ea1:	8d 9e 08 00 c0 ee    	lea    -0x113ffff8(%esi),%ebx
  802ea7:	81 c6 04 00 c0 ee    	add    $0xeec00004,%esi
		sys_yield();
  802ead:	e8 3f e7 ff ff       	call   8015f1 <sys_yield>
{
	const volatile struct Env *e;

	assert(envid != 0);
	e = &envs[ENVX(envid)];
	while (e->env_id == envid && e->env_status != ENV_FREE)
  802eb2:	8b 43 40             	mov    0x40(%ebx),%eax
  802eb5:	39 f8                	cmp    %edi,%eax
  802eb7:	75 07                	jne    802ec0 <wait+0x80>
  802eb9:	8b 46 50             	mov    0x50(%esi),%eax
  802ebc:	85 c0                	test   %eax,%eax
  802ebe:	75 ed                	jne    802ead <wait+0x6d>
		sys_yield();
}
  802ec0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802ec3:	5b                   	pop    %ebx
  802ec4:	5e                   	pop    %esi
  802ec5:	5f                   	pop    %edi
  802ec6:	c9                   	leave  
  802ec7:	c3                   	ret    

00802ec8 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  802ec8:	55                   	push   %ebp
  802ec9:	89 e5                	mov    %esp,%ebp
  802ecb:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  802ece:	83 3d 00 70 80 00 00 	cmpl   $0x0,0x807000
  802ed5:	75 52                	jne    802f29 <set_pgfault_handler+0x61>
		// First time through!	
		// LAB 4: Your code here.

		//int sys_page_alloc(envid_t envid, void *va, int perm)
		r = sys_page_alloc(0, (void*)(UXSTACKTOP - PGSIZE), PTE_U | PTE_W | PTE_P);
  802ed7:	83 ec 04             	sub    $0x4,%esp
  802eda:	6a 07                	push   $0x7
  802edc:	68 00 f0 bf ee       	push   $0xeebff000
  802ee1:	6a 00                	push   $0x0
  802ee3:	e8 30 e7 ff ff       	call   801618 <sys_page_alloc>
		if (r < 0) {
  802ee8:	83 c4 10             	add    $0x10,%esp
  802eeb:	85 c0                	test   %eax,%eax
  802eed:	79 12                	jns    802f01 <set_pgfault_handler+0x39>
			panic("sys_page_alloc error : %e\n", r);
  802eef:	50                   	push   %eax
  802ef0:	68 af 3b 80 00       	push   $0x803baf
  802ef5:	6a 24                	push   $0x24
  802ef7:	68 ca 3b 80 00       	push   $0x803bca
  802efc:	e8 23 db ff ff       	call   800a24 <_panic>
		}

		// how to know envid, put 0, envid2env will help us to get curenv in syscall
		r = sys_env_set_pgfault_upcall(0, _pgfault_upcall);		
  802f01:	83 ec 08             	sub    $0x8,%esp
  802f04:	68 34 2f 80 00       	push   $0x802f34
  802f09:	6a 00                	push   $0x0
  802f0b:	e8 bb e7 ff ff       	call   8016cb <sys_env_set_pgfault_upcall>
		if (r < 0) {
  802f10:	83 c4 10             	add    $0x10,%esp
  802f13:	85 c0                	test   %eax,%eax
  802f15:	79 12                	jns    802f29 <set_pgfault_handler+0x61>
			panic("sys_env_set_pgfault_upcall error : %e\n", r);
  802f17:	50                   	push   %eax
  802f18:	68 d8 3b 80 00       	push   $0x803bd8
  802f1d:	6a 2a                	push   $0x2a
  802f1f:	68 ca 3b 80 00       	push   $0x803bca
  802f24:	e8 fb da ff ff       	call   800a24 <_panic>
		}
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  802f29:	8b 45 08             	mov    0x8(%ebp),%eax
  802f2c:	a3 00 70 80 00       	mov    %eax,0x807000
}
  802f31:	c9                   	leave  
  802f32:	c3                   	ret    
	...

00802f34 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  802f34:	54                   	push   %esp
	movl _pgfault_handler, %eax
  802f35:	a1 00 70 80 00       	mov    0x807000,%eax
	call *%eax
  802f3a:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  802f3c:	83 c4 04             	add    $0x4,%esp
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	
	// fix old esp
	movl 0x30(%esp), %eax
  802f3f:	8b 44 24 30          	mov    0x30(%esp),%eax
	subl $0x4, %eax
  802f43:	83 e8 04             	sub    $0x4,%eax
	movl %eax, 0x30(%esp)
  802f46:	89 44 24 30          	mov    %eax,0x30(%esp)

	// set trap-time %eip
	movl 0x28(%esp), %ebx
  802f4a:	8b 5c 24 28          	mov    0x28(%esp),%ebx
	movl %ebx, (%eax)
  802f4e:	89 18                	mov    %ebx,(%eax)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	addl $0x08, %esp 	// ignore err_code and fault_va
  802f50:	83 c4 08             	add    $0x8,%esp
	popal 				// restore registers
  802f53:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $0x04, %esp 	// ignore eip 
  802f54:	83 c4 04             	add    $0x4,%esp
	popfl				// modify eflags
  802f57:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp
  802f58:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  802f59:	c3                   	ret    
	...

00802f5c <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  802f5c:	55                   	push   %ebp
  802f5d:	89 e5                	mov    %esp,%ebp
  802f5f:	56                   	push   %esi
  802f60:	53                   	push   %ebx
  802f61:	8b 75 08             	mov    0x8(%ebp),%esi
  802f64:	8b 45 0c             	mov    0xc(%ebp),%eax
  802f67:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// cprintf("0x%x 0x%x 0x%x\n", (uint32_t)from_env_store, (uint32_t)pg, (uint32_t)perm_store);
	int r;
	if (pg != NULL) {
  802f6a:	85 c0                	test   %eax,%eax
  802f6c:	74 0e                	je     802f7c <ipc_recv+0x20>
		r = sys_ipc_recv(pg);
  802f6e:	83 ec 0c             	sub    $0xc,%esp
  802f71:	50                   	push   %eax
  802f72:	e8 9c e7 ff ff       	call   801713 <sys_ipc_recv>
  802f77:	83 c4 10             	add    $0x10,%esp
  802f7a:	eb 10                	jmp    802f8c <ipc_recv+0x30>
	} else {
		r = sys_ipc_recv((void *)UTOP);
  802f7c:	83 ec 0c             	sub    $0xc,%esp
  802f7f:	68 00 00 c0 ee       	push   $0xeec00000
  802f84:	e8 8a e7 ff ff       	call   801713 <sys_ipc_recv>
  802f89:	83 c4 10             	add    $0x10,%esp
	}

	if (r == 0) {
  802f8c:	85 c0                	test   %eax,%eax
  802f8e:	75 26                	jne    802fb6 <ipc_recv+0x5a>
		if (from_env_store != NULL) *from_env_store = thisenv->env_ipc_from;
  802f90:	85 f6                	test   %esi,%esi
  802f92:	74 0a                	je     802f9e <ipc_recv+0x42>
  802f94:	a1 24 54 80 00       	mov    0x805424,%eax
  802f99:	8b 40 74             	mov    0x74(%eax),%eax
  802f9c:	89 06                	mov    %eax,(%esi)
		if (perm_store != NULL) *perm_store = thisenv->env_ipc_perm;
  802f9e:	85 db                	test   %ebx,%ebx
  802fa0:	74 0a                	je     802fac <ipc_recv+0x50>
  802fa2:	a1 24 54 80 00       	mov    0x805424,%eax
  802fa7:	8b 40 78             	mov    0x78(%eax),%eax
  802faa:	89 03                	mov    %eax,(%ebx)
		return thisenv->env_ipc_value;
  802fac:	a1 24 54 80 00       	mov    0x805424,%eax
  802fb1:	8b 40 70             	mov    0x70(%eax),%eax
  802fb4:	eb 14                	jmp    802fca <ipc_recv+0x6e>
	} else {
		// fails;
		if (from_env_store != NULL) *from_env_store = 0;
  802fb6:	85 f6                	test   %esi,%esi
  802fb8:	74 06                	je     802fc0 <ipc_recv+0x64>
  802fba:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		if (perm_store != NULL) *perm_store = 0;
  802fc0:	85 db                	test   %ebx,%ebx
  802fc2:	74 06                	je     802fca <ipc_recv+0x6e>
  802fc4:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
		return r;
	}
}
  802fca:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802fcd:	5b                   	pop    %ebx
  802fce:	5e                   	pop    %esi
  802fcf:	c9                   	leave  
  802fd0:	c3                   	ret    

00802fd1 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  802fd1:	55                   	push   %ebp
  802fd2:	89 e5                	mov    %esp,%ebp
  802fd4:	57                   	push   %edi
  802fd5:	56                   	push   %esi
  802fd6:	53                   	push   %ebx
  802fd7:	83 ec 0c             	sub    $0xc,%esp
  802fda:	8b 7d 0c             	mov    0xc(%ebp),%edi
  802fdd:	8b 5d 10             	mov    0x10(%ebp),%ebx
  802fe0:	8b 75 14             	mov    0x14(%ebp),%esi
	// LAB 4: Your code here.
	// int sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
	int r;
	if (pg == NULL) pg = (void *)UTOP;
  802fe3:	85 db                	test   %ebx,%ebx
  802fe5:	75 25                	jne    80300c <ipc_send+0x3b>
  802fe7:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
  802fec:	eb 1e                	jmp    80300c <ipc_send+0x3b>
	
	while ((r = sys_ipc_try_send(to_env, val, pg, perm)) != 0) {
		if (r == -E_IPC_NOT_RECV) {
  802fee:	83 f8 f9             	cmp    $0xfffffff9,%eax
  802ff1:	75 07                	jne    802ffa <ipc_send+0x29>
			// cprintf("Try Again and Again....\n");
			sys_yield();
  802ff3:	e8 f9 e5 ff ff       	call   8015f1 <sys_yield>
  802ff8:	eb 12                	jmp    80300c <ipc_send+0x3b>
		} else {
			panic("ipc_send error %e\n", r);
  802ffa:	50                   	push   %eax
  802ffb:	68 00 3c 80 00       	push   $0x803c00
  803000:	6a 43                	push   $0x43
  803002:	68 13 3c 80 00       	push   $0x803c13
  803007:	e8 18 da ff ff       	call   800a24 <_panic>
	// LAB 4: Your code here.
	// int sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
	int r;
	if (pg == NULL) pg = (void *)UTOP;
	
	while ((r = sys_ipc_try_send(to_env, val, pg, perm)) != 0) {
  80300c:	56                   	push   %esi
  80300d:	53                   	push   %ebx
  80300e:	57                   	push   %edi
  80300f:	ff 75 08             	pushl  0x8(%ebp)
  803012:	e8 d7 e6 ff ff       	call   8016ee <sys_ipc_try_send>
  803017:	83 c4 10             	add    $0x10,%esp
  80301a:	85 c0                	test   %eax,%eax
  80301c:	75 d0                	jne    802fee <ipc_send+0x1d>
		} else {
			panic("ipc_send error %e\n", r);
		}
	}
	return;
}
  80301e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  803021:	5b                   	pop    %ebx
  803022:	5e                   	pop    %esi
  803023:	5f                   	pop    %edi
  803024:	c9                   	leave  
  803025:	c3                   	ret    

00803026 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  803026:	55                   	push   %ebp
  803027:	89 e5                	mov    %esp,%ebp
  803029:	53                   	push   %ebx
  80302a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	for (i = 0; i < NENV; i++)
		if (envs[i].env_type == type)
  80302d:	39 1d 50 00 c0 ee    	cmp    %ebx,0xeec00050
  803033:	74 22                	je     803057 <ipc_find_env+0x31>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  803035:	b8 01 00 00 00       	mov    $0x1,%eax
		if (envs[i].env_type == type)
  80303a:	8d 0c 85 00 00 00 00 	lea    0x0(,%eax,4),%ecx
  803041:	89 c2                	mov    %eax,%edx
  803043:	c1 e2 07             	shl    $0x7,%edx
  803046:	29 ca                	sub    %ecx,%edx
  803048:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  80304e:	8b 52 50             	mov    0x50(%edx),%edx
  803051:	39 da                	cmp    %ebx,%edx
  803053:	75 1d                	jne    803072 <ipc_find_env+0x4c>
  803055:	eb 05                	jmp    80305c <ipc_find_env+0x36>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  803057:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
			return envs[i].env_id;
  80305c:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  803063:	c1 e0 07             	shl    $0x7,%eax
  803066:	29 d0                	sub    %edx,%eax
  803068:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  80306d:	8b 40 40             	mov    0x40(%eax),%eax
  803070:	eb 0c                	jmp    80307e <ipc_find_env+0x58>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  803072:	40                   	inc    %eax
  803073:	3d 00 04 00 00       	cmp    $0x400,%eax
  803078:	75 c0                	jne    80303a <ipc_find_env+0x14>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  80307a:	66 b8 00 00          	mov    $0x0,%ax
}
  80307e:	5b                   	pop    %ebx
  80307f:	c9                   	leave  
  803080:	c3                   	ret    
  803081:	00 00                	add    %al,(%eax)
	...

00803084 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  803084:	55                   	push   %ebp
  803085:	89 e5                	mov    %esp,%ebp
  803087:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  80308a:	89 c2                	mov    %eax,%edx
  80308c:	c1 ea 16             	shr    $0x16,%edx
  80308f:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  803096:	f6 c2 01             	test   $0x1,%dl
  803099:	74 1e                	je     8030b9 <pageref+0x35>
		return 0;
	pte = uvpt[PGNUM(v)];
  80309b:	c1 e8 0c             	shr    $0xc,%eax
  80309e:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  8030a5:	a8 01                	test   $0x1,%al
  8030a7:	74 17                	je     8030c0 <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  8030a9:	c1 e8 0c             	shr    $0xc,%eax
  8030ac:	66 8b 04 c5 04 00 00 	mov    -0x10fffffc(,%eax,8),%ax
  8030b3:	ef 
  8030b4:	0f b7 c0             	movzwl %ax,%eax
  8030b7:	eb 0c                	jmp    8030c5 <pageref+0x41>
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
		return 0;
  8030b9:	b8 00 00 00 00       	mov    $0x0,%eax
  8030be:	eb 05                	jmp    8030c5 <pageref+0x41>
	pte = uvpt[PGNUM(v)];
	if (!(pte & PTE_P))
		return 0;
  8030c0:	b8 00 00 00 00       	mov    $0x0,%eax
	return pages[PGNUM(pte)].pp_ref;
}
  8030c5:	c9                   	leave  
  8030c6:	c3                   	ret    
	...

008030c8 <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  8030c8:	55                   	push   %ebp
  8030c9:	89 e5                	mov    %esp,%ebp
  8030cb:	57                   	push   %edi
  8030cc:	56                   	push   %esi
  8030cd:	83 ec 10             	sub    $0x10,%esp
  8030d0:	8b 7d 08             	mov    0x8(%ebp),%edi
  8030d3:	8b 4d 10             	mov    0x10(%ebp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  8030d6:	89 7d f0             	mov    %edi,-0x10(%ebp)
  8030d9:	8b 75 0c             	mov    0xc(%ebp),%esi
  const DWunion dd = {.ll = d};
  8030dc:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  8030df:	8b 45 14             	mov    0x14(%ebp),%eax
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  8030e2:	85 c0                	test   %eax,%eax
  8030e4:	75 2e                	jne    803114 <__udivdi3+0x4c>
    {
      if (d0 > n1)
  8030e6:	39 f1                	cmp    %esi,%ecx
  8030e8:	77 5a                	ja     803144 <__udivdi3+0x7c>
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  8030ea:	85 c9                	test   %ecx,%ecx
  8030ec:	75 0b                	jne    8030f9 <__udivdi3+0x31>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  8030ee:	b8 01 00 00 00       	mov    $0x1,%eax
  8030f3:	31 d2                	xor    %edx,%edx
  8030f5:	f7 f1                	div    %ecx
  8030f7:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  8030f9:	31 d2                	xor    %edx,%edx
  8030fb:	89 f0                	mov    %esi,%eax
  8030fd:	f7 f1                	div    %ecx
  8030ff:	89 c6                	mov    %eax,%esi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  803101:	89 f8                	mov    %edi,%eax
  803103:	f7 f1                	div    %ecx
  803105:	89 c7                	mov    %eax,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  803107:	89 f8                	mov    %edi,%eax
  803109:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  80310b:	83 c4 10             	add    $0x10,%esp
  80310e:	5e                   	pop    %esi
  80310f:	5f                   	pop    %edi
  803110:	c9                   	leave  
  803111:	c3                   	ret    
  803112:	66 90                	xchg   %ax,%ax
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  803114:	39 f0                	cmp    %esi,%eax
  803116:	77 1c                	ja     803134 <__udivdi3+0x6c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  803118:	0f bd f8             	bsr    %eax,%edi
	  if (bm == 0)
  80311b:	83 f7 1f             	xor    $0x1f,%edi
  80311e:	75 3c                	jne    80315c <__udivdi3+0x94>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  803120:	39 f0                	cmp    %esi,%eax
  803122:	0f 82 90 00 00 00    	jb     8031b8 <__udivdi3+0xf0>
  803128:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80312b:	39 55 f4             	cmp    %edx,-0xc(%ebp)
  80312e:	0f 86 84 00 00 00    	jbe    8031b8 <__udivdi3+0xf0>
  803134:	31 f6                	xor    %esi,%esi
  803136:	31 ff                	xor    %edi,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  803138:	89 f8                	mov    %edi,%eax
  80313a:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  80313c:	83 c4 10             	add    $0x10,%esp
  80313f:	5e                   	pop    %esi
  803140:	5f                   	pop    %edi
  803141:	c9                   	leave  
  803142:	c3                   	ret    
  803143:	90                   	nop
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  803144:	89 f2                	mov    %esi,%edx
  803146:	89 f8                	mov    %edi,%eax
  803148:	f7 f1                	div    %ecx
  80314a:	89 c7                	mov    %eax,%edi
  80314c:	31 f6                	xor    %esi,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  80314e:	89 f8                	mov    %edi,%eax
  803150:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  803152:	83 c4 10             	add    $0x10,%esp
  803155:	5e                   	pop    %esi
  803156:	5f                   	pop    %edi
  803157:	c9                   	leave  
  803158:	c3                   	ret    
  803159:	8d 76 00             	lea    0x0(%esi),%esi
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  80315c:	89 f9                	mov    %edi,%ecx
  80315e:	d3 e0                	shl    %cl,%eax
  803160:	89 45 e8             	mov    %eax,-0x18(%ebp)
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  803163:	b8 20 00 00 00       	mov    $0x20,%eax
  803168:	29 f8                	sub    %edi,%eax

	      d1 = (d1 << bm) | (d0 >> b);
  80316a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80316d:	88 c1                	mov    %al,%cl
  80316f:	d3 ea                	shr    %cl,%edx
  803171:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  803174:	09 ca                	or     %ecx,%edx
  803176:	89 55 ec             	mov    %edx,-0x14(%ebp)
	      d0 = d0 << bm;
  803179:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80317c:	89 f9                	mov    %edi,%ecx
  80317e:	d3 e2                	shl    %cl,%edx
  803180:	89 55 f4             	mov    %edx,-0xc(%ebp)
	      n2 = n1 >> b;
  803183:	89 f2                	mov    %esi,%edx
  803185:	88 c1                	mov    %al,%cl
  803187:	d3 ea                	shr    %cl,%edx
  803189:	89 55 e8             	mov    %edx,-0x18(%ebp)
	      n1 = (n1 << bm) | (n0 >> b);
  80318c:	89 f2                	mov    %esi,%edx
  80318e:	89 f9                	mov    %edi,%ecx
  803190:	d3 e2                	shl    %cl,%edx
  803192:	8b 75 f0             	mov    -0x10(%ebp),%esi
  803195:	88 c1                	mov    %al,%cl
  803197:	d3 ee                	shr    %cl,%esi
  803199:	09 d6                	or     %edx,%esi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  80319b:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  80319e:	89 f0                	mov    %esi,%eax
  8031a0:	89 ca                	mov    %ecx,%edx
  8031a2:	f7 75 ec             	divl   -0x14(%ebp)
  8031a5:	89 d1                	mov    %edx,%ecx
  8031a7:	89 c6                	mov    %eax,%esi
	      umul_ppmm (m1, m0, q0, d0);
  8031a9:	f7 65 f4             	mull   -0xc(%ebp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  8031ac:	39 d1                	cmp    %edx,%ecx
  8031ae:	72 28                	jb     8031d8 <__udivdi3+0x110>
  8031b0:	74 1a                	je     8031cc <__udivdi3+0x104>
  8031b2:	89 f7                	mov    %esi,%edi
  8031b4:	31 f6                	xor    %esi,%esi
  8031b6:	eb 80                	jmp    803138 <__udivdi3+0x70>
	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  8031b8:	31 f6                	xor    %esi,%esi
  8031ba:	bf 01 00 00 00       	mov    $0x1,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  8031bf:	89 f8                	mov    %edi,%eax
  8031c1:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  8031c3:	83 c4 10             	add    $0x10,%esp
  8031c6:	5e                   	pop    %esi
  8031c7:	5f                   	pop    %edi
  8031c8:	c9                   	leave  
  8031c9:	c3                   	ret    
  8031ca:	66 90                	xchg   %ax,%ax

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  8031cc:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8031cf:	89 f9                	mov    %edi,%ecx
  8031d1:	d3 e2                	shl    %cl,%edx

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  8031d3:	39 c2                	cmp    %eax,%edx
  8031d5:	73 db                	jae    8031b2 <__udivdi3+0xea>
  8031d7:	90                   	nop
		{
		  q0--;
  8031d8:	8d 7e ff             	lea    -0x1(%esi),%edi
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  8031db:	31 f6                	xor    %esi,%esi
  8031dd:	e9 56 ff ff ff       	jmp    803138 <__udivdi3+0x70>
	...

008031e4 <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  8031e4:	55                   	push   %ebp
  8031e5:	89 e5                	mov    %esp,%ebp
  8031e7:	57                   	push   %edi
  8031e8:	56                   	push   %esi
  8031e9:	83 ec 20             	sub    $0x20,%esp
  8031ec:	8b 45 08             	mov    0x8(%ebp),%eax
  8031ef:	8b 4d 10             	mov    0x10(%ebp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  8031f2:	89 45 e8             	mov    %eax,-0x18(%ebp)
  8031f5:	8b 75 0c             	mov    0xc(%ebp),%esi
  const DWunion dd = {.ll = d};
  8031f8:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  8031fb:	8b 7d 14             	mov    0x14(%ebp),%edi
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  8031fe:	89 45 f0             	mov    %eax,-0x10(%ebp)
  n1 = nn.s.high;
  803201:	89 f2                	mov    %esi,%edx

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  803203:	85 ff                	test   %edi,%edi
  803205:	75 15                	jne    80321c <__umoddi3+0x38>
    {
      if (d0 > n1)
  803207:	39 f1                	cmp    %esi,%ecx
  803209:	0f 86 99 00 00 00    	jbe    8032a8 <__umoddi3+0xc4>
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  80320f:	f7 f1                	div    %ecx

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
  803211:	89 d0                	mov    %edx,%eax
  803213:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  803215:	83 c4 20             	add    $0x20,%esp
  803218:	5e                   	pop    %esi
  803219:	5f                   	pop    %edi
  80321a:	c9                   	leave  
  80321b:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  80321c:	39 f7                	cmp    %esi,%edi
  80321e:	0f 87 a4 00 00 00    	ja     8032c8 <__umoddi3+0xe4>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  803224:	0f bd c7             	bsr    %edi,%eax
	  if (bm == 0)
  803227:	83 f0 1f             	xor    $0x1f,%eax
  80322a:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80322d:	0f 84 a1 00 00 00    	je     8032d4 <__umoddi3+0xf0>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  803233:	89 f8                	mov    %edi,%eax
  803235:	8a 4d ec             	mov    -0x14(%ebp),%cl
  803238:	d3 e0                	shl    %cl,%eax
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  80323a:	bf 20 00 00 00       	mov    $0x20,%edi
  80323f:	2b 7d ec             	sub    -0x14(%ebp),%edi

	      d1 = (d1 << bm) | (d0 >> b);
  803242:	8b 55 f4             	mov    -0xc(%ebp),%edx
  803245:	89 f9                	mov    %edi,%ecx
  803247:	d3 ea                	shr    %cl,%edx
  803249:	09 c2                	or     %eax,%edx
  80324b:	89 55 f0             	mov    %edx,-0x10(%ebp)
	      d0 = d0 << bm;
  80324e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  803251:	8a 4d ec             	mov    -0x14(%ebp),%cl
  803254:	d3 e0                	shl    %cl,%eax
  803256:	89 45 f4             	mov    %eax,-0xc(%ebp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  803259:	89 f2                	mov    %esi,%edx
  80325b:	d3 e2                	shl    %cl,%edx
	      n0 = n0 << bm;
  80325d:	8b 45 e8             	mov    -0x18(%ebp),%eax
  803260:	d3 e0                	shl    %cl,%eax
  803262:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  803265:	8b 45 e8             	mov    -0x18(%ebp),%eax
  803268:	89 f9                	mov    %edi,%ecx
  80326a:	d3 e8                	shr    %cl,%eax
  80326c:	09 d0                	or     %edx,%eax

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  80326e:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  803270:	89 f2                	mov    %esi,%edx
  803272:	f7 75 f0             	divl   -0x10(%ebp)
  803275:	89 d6                	mov    %edx,%esi
	      umul_ppmm (m1, m0, q0, d0);
  803277:	f7 65 f4             	mull   -0xc(%ebp)
  80327a:	89 55 e8             	mov    %edx,-0x18(%ebp)
  80327d:	89 c1                	mov    %eax,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  80327f:	39 d6                	cmp    %edx,%esi
  803281:	72 71                	jb     8032f4 <__umoddi3+0x110>
  803283:	74 7f                	je     803304 <__umoddi3+0x120>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  803285:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  803288:	29 c8                	sub    %ecx,%eax
  80328a:	19 d6                	sbb    %edx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
  80328c:	8a 4d ec             	mov    -0x14(%ebp),%cl
  80328f:	d3 e8                	shr    %cl,%eax
  803291:	89 f2                	mov    %esi,%edx
  803293:	89 f9                	mov    %edi,%ecx
  803295:	d3 e2                	shl    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
  803297:	09 d0                	or     %edx,%eax
  803299:	89 f2                	mov    %esi,%edx
  80329b:	8a 4d ec             	mov    -0x14(%ebp),%cl
  80329e:	d3 ea                	shr    %cl,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  8032a0:	83 c4 20             	add    $0x20,%esp
  8032a3:	5e                   	pop    %esi
  8032a4:	5f                   	pop    %edi
  8032a5:	c9                   	leave  
  8032a6:	c3                   	ret    
  8032a7:	90                   	nop
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  8032a8:	85 c9                	test   %ecx,%ecx
  8032aa:	75 0b                	jne    8032b7 <__umoddi3+0xd3>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  8032ac:	b8 01 00 00 00       	mov    $0x1,%eax
  8032b1:	31 d2                	xor    %edx,%edx
  8032b3:	f7 f1                	div    %ecx
  8032b5:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  8032b7:	89 f0                	mov    %esi,%eax
  8032b9:	31 d2                	xor    %edx,%edx
  8032bb:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  8032bd:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8032c0:	f7 f1                	div    %ecx
  8032c2:	e9 4a ff ff ff       	jmp    803211 <__umoddi3+0x2d>
  8032c7:	90                   	nop
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
  8032c8:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  8032ca:	83 c4 20             	add    $0x20,%esp
  8032cd:	5e                   	pop    %esi
  8032ce:	5f                   	pop    %edi
  8032cf:	c9                   	leave  
  8032d0:	c3                   	ret    
  8032d1:	8d 76 00             	lea    0x0(%esi),%esi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  8032d4:	39 f7                	cmp    %esi,%edi
  8032d6:	72 05                	jb     8032dd <__umoddi3+0xf9>
  8032d8:	3b 4d f0             	cmp    -0x10(%ebp),%ecx
  8032db:	77 0c                	ja     8032e9 <__umoddi3+0x105>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  8032dd:	89 f2                	mov    %esi,%edx
  8032df:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8032e2:	29 c8                	sub    %ecx,%eax
  8032e4:	19 fa                	sbb    %edi,%edx
  8032e6:	89 45 f0             	mov    %eax,-0x10(%ebp)

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
  8032e9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  8032ec:	83 c4 20             	add    $0x20,%esp
  8032ef:	5e                   	pop    %esi
  8032f0:	5f                   	pop    %edi
  8032f1:	c9                   	leave  
  8032f2:	c3                   	ret    
  8032f3:	90                   	nop
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  8032f4:	8b 55 e8             	mov    -0x18(%ebp),%edx
  8032f7:	89 c1                	mov    %eax,%ecx
  8032f9:	2b 4d f4             	sub    -0xc(%ebp),%ecx
  8032fc:	1b 55 f0             	sbb    -0x10(%ebp),%edx
  8032ff:	eb 84                	jmp    803285 <__umoddi3+0xa1>
  803301:	8d 76 00             	lea    0x0(%esi),%esi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  803304:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  803307:	72 eb                	jb     8032f4 <__umoddi3+0x110>
  803309:	89 f2                	mov    %esi,%edx
  80330b:	e9 75 ff ff ff       	jmp    803285 <__umoddi3+0xa1>
