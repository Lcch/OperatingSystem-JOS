
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
  800057:	68 a0 32 80 00       	push   $0x8032a0
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
  800076:	68 af 32 80 00       	push   $0x8032af
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
  80009f:	68 bd 32 80 00       	push   $0x8032bd
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
  8000c8:	68 c2 32 80 00       	push   $0x8032c2
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
  8000e6:	68 d3 32 80 00       	push   $0x8032d3
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
  800116:	68 c7 32 80 00       	push   $0x8032c7
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
  80013d:	68 cf 32 80 00       	push   $0x8032cf
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
  800167:	68 db 32 80 00       	push   $0x8032db
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
  800276:	68 e5 32 80 00       	push   $0x8032e5
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
  8002a8:	68 38 34 80 00       	push   $0x803438
  8002ad:	e8 4a 08 00 00       	call   800afc <cprintf>
				exit();
  8002b2:	e8 51 07 00 00       	call   800a08 <exit>
  8002b7:	83 c4 10             	add    $0x10,%esp
			}
			if ((fd = open(t, O_RDONLY)) < 0) {
  8002ba:	83 ec 08             	sub    $0x8,%esp
  8002bd:	6a 00                	push   $0x0
  8002bf:	ff 75 a4             	pushl  -0x5c(%ebp)
  8002c2:	e8 f8 1f 00 00       	call   8022bf <open>
  8002c7:	89 c3                	mov    %eax,%ebx
  8002c9:	83 c4 10             	add    $0x10,%esp
  8002cc:	85 c0                	test   %eax,%eax
  8002ce:	79 1b                	jns    8002eb <runcmd+0xdf>
				cprintf("open %s for read: %e", t, fd);
  8002d0:	83 ec 04             	sub    $0x4,%esp
  8002d3:	50                   	push   %eax
  8002d4:	ff 75 a4             	pushl  -0x5c(%ebp)
  8002d7:	68 f9 32 80 00       	push   $0x8032f9
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
  8002f9:	e8 bb 1a 00 00       	call   801db9 <dup>
				close(fd);
  8002fe:	89 1c 24             	mov    %ebx,(%esp)
  800301:	e8 65 1a 00 00       	call   801d6b <close>
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
  800324:	68 60 34 80 00       	push   $0x803460
  800329:	e8 ce 07 00 00       	call   800afc <cprintf>
				exit();
  80032e:	e8 d5 06 00 00       	call   800a08 <exit>
  800333:	83 c4 10             	add    $0x10,%esp
			}
			if ((fd = open(t, O_WRONLY|O_CREAT|O_TRUNC)) < 0) {
  800336:	83 ec 08             	sub    $0x8,%esp
  800339:	68 01 03 00 00       	push   $0x301
  80033e:	ff 75 a4             	pushl  -0x5c(%ebp)
  800341:	e8 79 1f 00 00       	call   8022bf <open>
  800346:	89 c3                	mov    %eax,%ebx
  800348:	83 c4 10             	add    $0x10,%esp
  80034b:	85 c0                	test   %eax,%eax
  80034d:	79 19                	jns    800368 <runcmd+0x15c>
				cprintf("open %s for write: %e", t, fd);
  80034f:	83 ec 04             	sub    $0x4,%esp
  800352:	50                   	push   %eax
  800353:	ff 75 a4             	pushl  -0x5c(%ebp)
  800356:	68 0e 33 80 00       	push   $0x80330e
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
  800377:	e8 3d 1a 00 00       	call   801db9 <dup>
				close(fd);
  80037c:	89 1c 24             	mov    %ebx,(%esp)
  80037f:	e8 e7 19 00 00       	call   801d6b <close>
  800384:	83 c4 10             	add    $0x10,%esp
  800387:	e9 a1 fe ff ff       	jmp    80022d <runcmd+0x21>
			}
			break;

		case '|':	// Pipe
			if ((r = pipe(p)) < 0) {
  80038c:	83 ec 0c             	sub    $0xc,%esp
  80038f:	8d 85 9c fb ff ff    	lea    -0x464(%ebp),%eax
  800395:	50                   	push   %eax
  800396:	e8 6f 28 00 00       	call   802c0a <pipe>
  80039b:	83 c4 10             	add    $0x10,%esp
  80039e:	85 c0                	test   %eax,%eax
  8003a0:	79 16                	jns    8003b8 <runcmd+0x1ac>
				cprintf("pipe: %e", r);
  8003a2:	83 ec 08             	sub    $0x8,%esp
  8003a5:	50                   	push   %eax
  8003a6:	68 24 33 80 00       	push   $0x803324
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
  8003d0:	68 2d 33 80 00       	push   $0x80332d
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
  8003ec:	68 3a 33 80 00       	push   $0x80333a
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
  800412:	e8 a2 19 00 00       	call   801db9 <dup>
					close(p[0]);
  800417:	83 c4 04             	add    $0x4,%esp
  80041a:	ff b5 9c fb ff ff    	pushl  -0x464(%ebp)
  800420:	e8 46 19 00 00       	call   801d6b <close>
  800425:	83 c4 10             	add    $0x10,%esp
				}
				close(p[1]);
  800428:	83 ec 0c             	sub    $0xc,%esp
  80042b:	ff b5 a0 fb ff ff    	pushl  -0x460(%ebp)
  800431:	e8 35 19 00 00       	call   801d6b <close>
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
  800454:	e8 60 19 00 00       	call   801db9 <dup>
					close(p[1]);
  800459:	83 c4 04             	add    $0x4,%esp
  80045c:	ff b5 a0 fb ff ff    	pushl  -0x460(%ebp)
  800462:	e8 04 19 00 00       	call   801d6b <close>
  800467:	83 c4 10             	add    $0x10,%esp
				}
				close(p[0]);
  80046a:	83 ec 0c             	sub    $0xc,%esp
  80046d:	ff b5 9c fb ff ff    	pushl  -0x464(%ebp)
  800473:	e8 f3 18 00 00       	call   801d6b <close>
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
  800480:	68 43 33 80 00       	push   $0x803343
  800485:	6a 6e                	push   $0x6e
  800487:	68 5f 33 80 00       	push   $0x80335f
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
  8004aa:	68 69 33 80 00       	push   $0x803369
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
  800504:	68 78 33 80 00       	push   $0x803378
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
  80051f:	68 03 34 80 00       	push   $0x803403
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
  800538:	68 c0 32 80 00       	push   $0x8032c0
  80053d:	e8 ba 05 00 00       	call   800afc <cprintf>
  800542:	83 c4 10             	add    $0x10,%esp
	}

	// Spawn the command!
	if ((r = spawn(argv[0], (const char**) argv)) < 0)
  800545:	83 ec 08             	sub    $0x8,%esp
  800548:	8d 45 a8             	lea    -0x58(%ebp),%eax
  80054b:	50                   	push   %eax
  80054c:	ff 75 a8             	pushl  -0x58(%ebp)
  80054f:	e8 1c 1f 00 00       	call   802470 <spawn>
  800554:	89 c3                	mov    %eax,%ebx
  800556:	83 c4 10             	add    $0x10,%esp
  800559:	85 c0                	test   %eax,%eax
  80055b:	79 1b                	jns    800578 <runcmd+0x36c>
		cprintf("spawn %s: %e\n", argv[0], r);
  80055d:	83 ec 04             	sub    $0x4,%esp
  800560:	50                   	push   %eax
  800561:	ff 75 a8             	pushl  -0x58(%ebp)
  800564:	68 86 33 80 00       	push   $0x803386
  800569:	e8 8e 05 00 00       	call   800afc <cprintf>

	// In the parent, close all file descriptors and wait for the
	// spawned command to exit.
	close_all();
  80056e:	e8 23 18 00 00       	call   801d96 <close_all>
  800573:	83 c4 10             	add    $0x10,%esp
  800576:	eb 56                	jmp    8005ce <runcmd+0x3c2>
  800578:	e8 19 18 00 00       	call   801d96 <close_all>
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
  800593:	68 94 33 80 00       	push   $0x803394
  800598:	e8 5f 05 00 00       	call   800afc <cprintf>
  80059d:	83 c4 10             	add    $0x10,%esp
		wait(r);
  8005a0:	83 ec 0c             	sub    $0xc,%esp
  8005a3:	53                   	push   %ebx
  8005a4:	e8 e7 27 00 00       	call   802d90 <wait>
		if (debug)
  8005a9:	83 c4 10             	add    $0x10,%esp
  8005ac:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  8005b3:	74 19                	je     8005ce <runcmd+0x3c2>
			cprintf("[%08x] wait finished\n", thisenv->env_id);
  8005b5:	a1 24 54 80 00       	mov    0x805424,%eax
  8005ba:	8b 40 48             	mov    0x48(%eax),%eax
  8005bd:	83 ec 08             	sub    $0x8,%esp
  8005c0:	50                   	push   %eax
  8005c1:	68 a9 33 80 00       	push   $0x8033a9
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
  8005e8:	68 bf 33 80 00       	push   $0x8033bf
  8005ed:	e8 0a 05 00 00       	call   800afc <cprintf>
  8005f2:	83 c4 10             	add    $0x10,%esp
		wait(pipe_child);
  8005f5:	83 ec 0c             	sub    $0xc,%esp
  8005f8:	56                   	push   %esi
  8005f9:	e8 92 27 00 00       	call   802d90 <wait>
		if (debug)
  8005fe:	83 c4 10             	add    $0x10,%esp
  800601:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  800608:	74 19                	je     800623 <runcmd+0x417>
			cprintf("[%08x] wait finished\n", thisenv->env_id);
  80060a:	a1 24 54 80 00       	mov    0x805424,%eax
  80060f:	8b 40 48             	mov    0x48(%eax),%eax
  800612:	83 ec 08             	sub    $0x8,%esp
  800615:	50                   	push   %eax
  800616:	68 a9 33 80 00       	push   $0x8033a9
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
  800636:	68 88 34 80 00       	push   $0x803488
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
  80065f:	e8 cc 13 00 00       	call   801a30 <argstart>
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
  8006aa:	e8 ba 13 00 00       	call   801a69 <argnext>
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
  8006ce:	e8 98 16 00 00       	call   801d6b <close>
		if ((r = open(argv[1], O_RDONLY)) < 0)
  8006d3:	83 c4 08             	add    $0x8,%esp
  8006d6:	6a 00                	push   $0x0
  8006d8:	ff 76 04             	pushl  0x4(%esi)
  8006db:	e8 df 1b 00 00       	call   8022bf <open>
  8006e0:	83 c4 10             	add    $0x10,%esp
  8006e3:	85 c0                	test   %eax,%eax
  8006e5:	79 1b                	jns    800702 <umain+0xb8>
			panic("open %s: %e", argv[1], r);
  8006e7:	83 ec 0c             	sub    $0xc,%esp
  8006ea:	50                   	push   %eax
  8006eb:	ff 76 04             	pushl  0x4(%esi)
  8006ee:	68 df 33 80 00       	push   $0x8033df
  8006f3:	68 1e 01 00 00       	push   $0x11e
  8006f8:	68 5f 33 80 00       	push   $0x80335f
  8006fd:	e8 22 03 00 00       	call   800a24 <_panic>
		assert(r == 0);
  800702:	85 c0                	test   %eax,%eax
  800704:	74 19                	je     80071f <umain+0xd5>
  800706:	68 eb 33 80 00       	push   $0x8033eb
  80070b:	68 f2 33 80 00       	push   $0x8033f2
  800710:	68 1f 01 00 00       	push   $0x11f
  800715:	68 5f 33 80 00       	push   $0x80335f
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
  800737:	b8 dc 33 80 00       	mov    $0x8033dc,%eax
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
  800761:	68 07 34 80 00       	push   $0x803407
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
  800780:	68 10 34 80 00       	push   $0x803410
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
  80079c:	68 1a 34 80 00       	push   $0x80341a
  8007a1:	e8 b2 1c 00 00       	call   802458 <printf>
  8007a6:	83 c4 10             	add    $0x10,%esp
		if (debug)
  8007a9:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  8007b0:	74 10                	je     8007c2 <umain+0x178>
			cprintf("BEFORE FORK\n");
  8007b2:	83 ec 0c             	sub    $0xc,%esp
  8007b5:	68 20 34 80 00       	push   $0x803420
  8007ba:	e8 3d 03 00 00       	call   800afc <cprintf>
  8007bf:	83 c4 10             	add    $0x10,%esp
		if ((r = fork()) < 0)
  8007c2:	e8 63 10 00 00       	call   80182a <fork>
  8007c7:	89 c3                	mov    %eax,%ebx
  8007c9:	85 c0                	test   %eax,%eax
  8007cb:	79 15                	jns    8007e2 <umain+0x198>
			panic("fork: %e", r);
  8007cd:	50                   	push   %eax
  8007ce:	68 3a 33 80 00       	push   $0x80333a
  8007d3:	68 36 01 00 00       	push   $0x136
  8007d8:	68 5f 33 80 00       	push   $0x80335f
  8007dd:	e8 42 02 00 00       	call   800a24 <_panic>
		if (debug)
  8007e2:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  8007e9:	74 11                	je     8007fc <umain+0x1b2>
			cprintf("FORK: %d\n", r);
  8007eb:	83 ec 08             	sub    $0x8,%esp
  8007ee:	50                   	push   %eax
  8007ef:	68 2d 34 80 00       	push   $0x80342d
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
  80081a:	e8 71 25 00 00       	call   802d90 <wait>
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
  800838:	68 a9 34 80 00       	push   $0x8034a9
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
  80091d:	e8 86 15 00 00       	call   801ea8 <read>
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
  800947:	e8 db 12 00 00       	call   801c27 <fd_lookup>
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
  800970:	e8 3f 12 00 00       	call   801bb4 <fd_alloc>
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
  8009ae:	e8 d9 11 00 00       	call   801b8c <fd2num>
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
  800a0e:	e8 83 13 00 00       	call   801d96 <close_all>
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
  800a42:	68 c0 34 80 00       	push   $0x8034c0
  800a47:	e8 b0 00 00 00       	call   800afc <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800a4c:	83 c4 18             	add    $0x18,%esp
  800a4f:	56                   	push   %esi
  800a50:	ff 75 10             	pushl  0x10(%ebp)
  800a53:	e8 53 00 00 00       	call   800aab <vcprintf>
	cprintf("\n");
  800a58:	c7 04 24 c0 32 80 00 	movl   $0x8032c0,(%esp)
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
  800b64:	e8 df 24 00 00       	call   803048 <__udivdi3>
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
  800ba0:	e8 bf 25 00 00       	call   803164 <__umoddi3>
  800ba5:	83 c4 14             	add    $0x14,%esp
  800ba8:	0f be 80 e3 34 80 00 	movsbl 0x8034e3(%eax),%eax
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
  800cec:	ff 24 85 20 36 80 00 	jmp    *0x803620(,%eax,4)
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
  800d98:	8b 04 85 80 37 80 00 	mov    0x803780(,%eax,4),%eax
  800d9f:	85 c0                	test   %eax,%eax
  800da1:	75 1a                	jne    800dbd <vprintfmt+0x15c>
				printfmt(putch, putdat, "error %d", err);
  800da3:	52                   	push   %edx
  800da4:	68 fb 34 80 00       	push   $0x8034fb
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
  800dbe:	68 04 34 80 00       	push   $0x803404
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
  800df4:	c7 45 d0 f4 34 80 00 	movl   $0x8034f4,-0x30(%ebp)
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
  801074:	68 04 34 80 00       	push   $0x803404
  801079:	6a 01                	push   $0x1
  80107b:	e8 c1 13 00 00       	call   802441 <fprintf>
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
  8010af:	68 df 37 80 00       	push   $0x8037df
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
  801546:	68 ef 37 80 00       	push   $0x8037ef
  80154b:	6a 42                	push   $0x42
  80154d:	68 0c 38 80 00       	push   $0x80380c
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
  80176d:	68 1c 38 80 00       	push   $0x80381c
  801772:	6a 20                	push   $0x20
  801774:	68 60 39 80 00       	push   $0x803960
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
  8017a2:	68 40 38 80 00       	push   $0x803840
  8017a7:	6a 24                	push   $0x24
  8017a9:	68 60 39 80 00       	push   $0x803960
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
  8017cc:	68 64 38 80 00       	push   $0x803864
  8017d1:	6a 32                	push   $0x32
  8017d3:	68 60 39 80 00       	push   $0x803960
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
  801814:	68 88 38 80 00       	push   $0x803888
  801819:	6a 3a                	push   $0x3a
  80181b:	68 60 39 80 00       	push   $0x803960
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
  801838:	e8 db 15 00 00       	call   802e18 <set_pgfault_handler>
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
  801853:	68 6b 39 80 00       	push   $0x80396b
  801858:	6a 7b                	push   $0x7b
  80185a:	68 60 39 80 00       	push   $0x803960
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
  80188a:	e9 7b 01 00 00       	jmp    801a0a <fork+0x1e0>
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
  8018a2:	0f 84 cd 00 00 00    	je     801975 <fork+0x14b>
  8018a8:	89 d8                	mov    %ebx,%eax
  8018aa:	c1 e8 0c             	shr    $0xc,%eax
  8018ad:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8018b4:	f6 c2 01             	test   $0x1,%dl
  8018b7:	0f 84 b8 00 00 00    	je     801975 <fork+0x14b>
  8018bd:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8018c4:	f6 c2 04             	test   $0x4,%dl
  8018c7:	0f 84 a8 00 00 00    	je     801975 <fork+0x14b>
//
static int
duppage(envid_t envid, unsigned pn)
{
	// do not dup exception stack
	if (pn * PGSIZE == UXSTACKTOP - PGSIZE) return 0;
  8018cd:	89 c6                	mov    %eax,%esi
  8018cf:	c1 e6 0c             	shl    $0xc,%esi
  8018d2:	81 fe 00 f0 bf ee    	cmp    $0xeebff000,%esi
  8018d8:	0f 84 97 00 00 00    	je     801975 <fork+0x14b>

	int r;
	void * addr = (void *)(pn * PGSIZE);
	if ((uvpt[pn] & PTE_W) || (uvpt[pn] & PTE_COW)) {
  8018de:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8018e5:	f6 c2 02             	test   $0x2,%dl
  8018e8:	75 0c                	jne    8018f6 <fork+0xcc>
  8018ea:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8018f1:	f6 c4 08             	test   $0x8,%ah
  8018f4:	74 57                	je     80194d <fork+0x123>
		// cow
		r = sys_page_map(0, addr, envid, addr, PTE_COW | PTE_P | PTE_U);
  8018f6:	83 ec 0c             	sub    $0xc,%esp
  8018f9:	68 05 08 00 00       	push   $0x805
  8018fe:	56                   	push   %esi
  8018ff:	57                   	push   %edi
  801900:	56                   	push   %esi
  801901:	6a 00                	push   $0x0
  801903:	e8 34 fd ff ff       	call   80163c <sys_page_map>
		if (r < 0) panic("duppage sys_page_map error : %e\n", r);
  801908:	83 c4 20             	add    $0x20,%esp
  80190b:	85 c0                	test   %eax,%eax
  80190d:	79 12                	jns    801921 <fork+0xf7>
  80190f:	50                   	push   %eax
  801910:	68 ac 38 80 00       	push   $0x8038ac
  801915:	6a 55                	push   $0x55
  801917:	68 60 39 80 00       	push   $0x803960
  80191c:	e8 03 f1 ff ff       	call   800a24 <_panic>
		
		r = sys_page_map(0, addr, 0, addr, PTE_COW | PTE_P | PTE_U);
  801921:	83 ec 0c             	sub    $0xc,%esp
  801924:	68 05 08 00 00       	push   $0x805
  801929:	56                   	push   %esi
  80192a:	6a 00                	push   $0x0
  80192c:	56                   	push   %esi
  80192d:	6a 00                	push   $0x0
  80192f:	e8 08 fd ff ff       	call   80163c <sys_page_map>
		if (r < 0) panic("duppage sys_page_map error : %e\n", r);
  801934:	83 c4 20             	add    $0x20,%esp
  801937:	85 c0                	test   %eax,%eax
  801939:	79 3a                	jns    801975 <fork+0x14b>
  80193b:	50                   	push   %eax
  80193c:	68 ac 38 80 00       	push   $0x8038ac
  801941:	6a 58                	push   $0x58
  801943:	68 60 39 80 00       	push   $0x803960
  801948:	e8 d7 f0 ff ff       	call   800a24 <_panic>
	} else {
		// read only
		r = sys_page_map(0, addr, envid, addr, PTE_P | PTE_U);
  80194d:	83 ec 0c             	sub    $0xc,%esp
  801950:	6a 05                	push   $0x5
  801952:	56                   	push   %esi
  801953:	57                   	push   %edi
  801954:	56                   	push   %esi
  801955:	6a 00                	push   $0x0
  801957:	e8 e0 fc ff ff       	call   80163c <sys_page_map>
		if (r < 0) panic("duppage sys_page_map error : %e\n", r);
  80195c:	83 c4 20             	add    $0x20,%esp
  80195f:	85 c0                	test   %eax,%eax
  801961:	79 12                	jns    801975 <fork+0x14b>
  801963:	50                   	push   %eax
  801964:	68 ac 38 80 00       	push   $0x8038ac
  801969:	6a 5c                	push   $0x5c
  80196b:	68 60 39 80 00       	push   $0x803960
  801970:	e8 af f0 ff ff       	call   800a24 <_panic>
		return 0;
	} else {
		// map page to new environment
		// kernel page is already in new environment
		uint32_t i;
		for (i = 0; i != UTOP; i += PGSIZE) 
  801975:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  80197b:	81 fb 00 00 c0 ee    	cmp    $0xeec00000,%ebx
  801981:	0f 85 0d ff ff ff    	jne    801894 <fork+0x6a>
		if ((uvpd[PDX(i)] & PTE_P) && (uvpt[i / PGSIZE] & PTE_P) && (uvpt[i / PGSIZE] & PTE_U)) {
			duppage(childpid, i / PGSIZE);
		}

		// allocate exception stack
		r = sys_page_alloc(childpid, (void *)(UXSTACKTOP - PGSIZE), PTE_U | PTE_W | PTE_P);
  801987:	83 ec 04             	sub    $0x4,%esp
  80198a:	6a 07                	push   $0x7
  80198c:	68 00 f0 bf ee       	push   $0xeebff000
  801991:	ff 75 e4             	pushl  -0x1c(%ebp)
  801994:	e8 7f fc ff ff       	call   801618 <sys_page_alloc>
		if (r < 0) panic("fork, sys_page_alloc user exception stack error : %e\n", r);
  801999:	83 c4 10             	add    $0x10,%esp
  80199c:	85 c0                	test   %eax,%eax
  80199e:	79 15                	jns    8019b5 <fork+0x18b>
  8019a0:	50                   	push   %eax
  8019a1:	68 d0 38 80 00       	push   $0x8038d0
  8019a6:	68 90 00 00 00       	push   $0x90
  8019ab:	68 60 39 80 00       	push   $0x803960
  8019b0:	e8 6f f0 ff ff       	call   800a24 <_panic>

		// set user environment user page fault handler 
		extern void _pgfault_upcall(void);
		r = sys_env_set_pgfault_upcall(childpid, _pgfault_upcall);
  8019b5:	83 ec 08             	sub    $0x8,%esp
  8019b8:	68 84 2e 80 00       	push   $0x802e84
  8019bd:	ff 75 e4             	pushl  -0x1c(%ebp)
  8019c0:	e8 06 fd ff ff       	call   8016cb <sys_env_set_pgfault_upcall>
		if (r < 0) panic("fork, set pgfault upcall fail : %e\n", r);
  8019c5:	83 c4 10             	add    $0x10,%esp
  8019c8:	85 c0                	test   %eax,%eax
  8019ca:	79 15                	jns    8019e1 <fork+0x1b7>
  8019cc:	50                   	push   %eax
  8019cd:	68 08 39 80 00       	push   $0x803908
  8019d2:	68 95 00 00 00       	push   $0x95
  8019d7:	68 60 39 80 00       	push   $0x803960
  8019dc:	e8 43 f0 ff ff       	call   800a24 <_panic>
		r = sys_set_priority(childpid, num);
		if (r < 0) panic("fork, set priority error\n");
		*/

		// mark the child as runnable and return
		r = sys_env_set_status(childpid, ENV_RUNNABLE);
  8019e1:	83 ec 08             	sub    $0x8,%esp
  8019e4:	6a 02                	push   $0x2
  8019e6:	ff 75 e4             	pushl  -0x1c(%ebp)
  8019e9:	e8 97 fc ff ff       	call   801685 <sys_env_set_status>
		if (r < 0) panic("fork, set child process to ENV_RUNNABLE error : %e\n", r);
  8019ee:	83 c4 10             	add    $0x10,%esp
  8019f1:	85 c0                	test   %eax,%eax
  8019f3:	79 15                	jns    801a0a <fork+0x1e0>
  8019f5:	50                   	push   %eax
  8019f6:	68 2c 39 80 00       	push   $0x80392c
  8019fb:	68 a0 00 00 00       	push   $0xa0
  801a00:	68 60 39 80 00       	push   $0x803960
  801a05:	e8 1a f0 ff ff       	call   800a24 <_panic>
		// cprintf("fork father ok!")
		return childpid;
	}

	panic("fork not implemented");
}
  801a0a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801a0d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801a10:	5b                   	pop    %ebx
  801a11:	5e                   	pop    %esi
  801a12:	5f                   	pop    %edi
  801a13:	c9                   	leave  
  801a14:	c3                   	ret    

00801a15 <sfork>:

// Challenge!
int
sfork(void)
{
  801a15:	55                   	push   %ebp
  801a16:	89 e5                	mov    %esp,%ebp
  801a18:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  801a1b:	68 88 39 80 00       	push   $0x803988
  801a20:	68 ad 00 00 00       	push   $0xad
  801a25:	68 60 39 80 00       	push   $0x803960
  801a2a:	e8 f5 ef ff ff       	call   800a24 <_panic>
	...

00801a30 <argstart>:
#include <inc/args.h>
#include <inc/string.h>

void
argstart(int *argc, char **argv, struct Argstate *args)
{
  801a30:	55                   	push   %ebp
  801a31:	89 e5                	mov    %esp,%ebp
  801a33:	8b 55 08             	mov    0x8(%ebp),%edx
  801a36:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801a39:	8b 45 10             	mov    0x10(%ebp),%eax
	args->argc = argc;
  801a3c:	89 10                	mov    %edx,(%eax)
	args->argv = (const char **) argv;
  801a3e:	89 48 04             	mov    %ecx,0x4(%eax)
	args->curarg = (*argc > 1 && argv ? "" : 0);
  801a41:	83 3a 01             	cmpl   $0x1,(%edx)
  801a44:	7e 0b                	jle    801a51 <argstart+0x21>
  801a46:	85 c9                	test   %ecx,%ecx
  801a48:	75 0e                	jne    801a58 <argstart+0x28>
  801a4a:	ba 00 00 00 00       	mov    $0x0,%edx
  801a4f:	eb 0c                	jmp    801a5d <argstart+0x2d>
  801a51:	ba 00 00 00 00       	mov    $0x0,%edx
  801a56:	eb 05                	jmp    801a5d <argstart+0x2d>
  801a58:	ba c1 32 80 00       	mov    $0x8032c1,%edx
  801a5d:	89 50 08             	mov    %edx,0x8(%eax)
	args->argvalue = 0;
  801a60:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
}
  801a67:	c9                   	leave  
  801a68:	c3                   	ret    

00801a69 <argnext>:

int
argnext(struct Argstate *args)
{
  801a69:	55                   	push   %ebp
  801a6a:	89 e5                	mov    %esp,%ebp
  801a6c:	57                   	push   %edi
  801a6d:	56                   	push   %esi
  801a6e:	53                   	push   %ebx
  801a6f:	83 ec 0c             	sub    $0xc,%esp
  801a72:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int arg;

	args->argvalue = 0;
  801a75:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)

	// Done processing arguments if args->curarg == 0
	if (args->curarg == 0)
  801a7c:	8b 43 08             	mov    0x8(%ebx),%eax
  801a7f:	85 c0                	test   %eax,%eax
  801a81:	74 6c                	je     801aef <argnext+0x86>
		return -1;

	if (!*args->curarg) {
  801a83:	80 38 00             	cmpb   $0x0,(%eax)
  801a86:	75 4d                	jne    801ad5 <argnext+0x6c>
		// Need to process the next argument
		// Check for end of argument list
		if (*args->argc == 1
  801a88:	8b 0b                	mov    (%ebx),%ecx
  801a8a:	83 39 01             	cmpl   $0x1,(%ecx)
  801a8d:	74 52                	je     801ae1 <argnext+0x78>
		    || args->argv[1][0] != '-'
  801a8f:	8b 43 04             	mov    0x4(%ebx),%eax
  801a92:	8d 70 04             	lea    0x4(%eax),%esi
  801a95:	8b 50 04             	mov    0x4(%eax),%edx
  801a98:	80 3a 2d             	cmpb   $0x2d,(%edx)
  801a9b:	75 44                	jne    801ae1 <argnext+0x78>
		    || args->argv[1][1] == '\0')
  801a9d:	8d 7a 01             	lea    0x1(%edx),%edi
  801aa0:	80 7a 01 00          	cmpb   $0x0,0x1(%edx)
  801aa4:	74 3b                	je     801ae1 <argnext+0x78>
			goto endofargs;
		// Shift arguments down one
		args->curarg = args->argv[1] + 1;
  801aa6:	89 7b 08             	mov    %edi,0x8(%ebx)
		memmove(args->argv + 1, args->argv + 2, sizeof(const char *) * (*args->argc - 1));
  801aa9:	83 ec 04             	sub    $0x4,%esp
  801aac:	8b 11                	mov    (%ecx),%edx
  801aae:	8d 14 95 fc ff ff ff 	lea    -0x4(,%edx,4),%edx
  801ab5:	52                   	push   %edx
  801ab6:	83 c0 08             	add    $0x8,%eax
  801ab9:	50                   	push   %eax
  801aba:	56                   	push   %esi
  801abb:	e8 97 f8 ff ff       	call   801357 <memmove>
		(*args->argc)--;
  801ac0:	8b 03                	mov    (%ebx),%eax
  801ac2:	ff 08                	decl   (%eax)
		// Check for "--": end of argument list
		if (args->curarg[0] == '-' && args->curarg[1] == '\0')
  801ac4:	8b 43 08             	mov    0x8(%ebx),%eax
  801ac7:	83 c4 10             	add    $0x10,%esp
  801aca:	80 38 2d             	cmpb   $0x2d,(%eax)
  801acd:	75 06                	jne    801ad5 <argnext+0x6c>
  801acf:	80 78 01 00          	cmpb   $0x0,0x1(%eax)
  801ad3:	74 0c                	je     801ae1 <argnext+0x78>
			goto endofargs;
	}

	arg = (unsigned char) *args->curarg;
  801ad5:	8b 53 08             	mov    0x8(%ebx),%edx
  801ad8:	0f b6 02             	movzbl (%edx),%eax
	args->curarg++;
  801adb:	42                   	inc    %edx
  801adc:	89 53 08             	mov    %edx,0x8(%ebx)
	return arg;
  801adf:	eb 13                	jmp    801af4 <argnext+0x8b>

    endofargs:
	args->curarg = 0;
  801ae1:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
	return -1;
  801ae8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  801aed:	eb 05                	jmp    801af4 <argnext+0x8b>

	args->argvalue = 0;

	// Done processing arguments if args->curarg == 0
	if (args->curarg == 0)
		return -1;
  801aef:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	return arg;

    endofargs:
	args->curarg = 0;
	return -1;
}
  801af4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801af7:	5b                   	pop    %ebx
  801af8:	5e                   	pop    %esi
  801af9:	5f                   	pop    %edi
  801afa:	c9                   	leave  
  801afb:	c3                   	ret    

00801afc <argnextvalue>:
	return (char*) (args->argvalue ? args->argvalue : argnextvalue(args));
}

char *
argnextvalue(struct Argstate *args)
{
  801afc:	55                   	push   %ebp
  801afd:	89 e5                	mov    %esp,%ebp
  801aff:	56                   	push   %esi
  801b00:	53                   	push   %ebx
  801b01:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (!args->curarg)
  801b04:	8b 43 08             	mov    0x8(%ebx),%eax
  801b07:	85 c0                	test   %eax,%eax
  801b09:	74 57                	je     801b62 <argnextvalue+0x66>
		return 0;
	if (*args->curarg) {
  801b0b:	80 38 00             	cmpb   $0x0,(%eax)
  801b0e:	74 0c                	je     801b1c <argnextvalue+0x20>
		args->argvalue = args->curarg;
  801b10:	89 43 0c             	mov    %eax,0xc(%ebx)
		args->curarg = "";
  801b13:	c7 43 08 c1 32 80 00 	movl   $0x8032c1,0x8(%ebx)
  801b1a:	eb 41                	jmp    801b5d <argnextvalue+0x61>
	} else if (*args->argc > 1) {
  801b1c:	8b 03                	mov    (%ebx),%eax
  801b1e:	83 38 01             	cmpl   $0x1,(%eax)
  801b21:	7e 2c                	jle    801b4f <argnextvalue+0x53>
		args->argvalue = args->argv[1];
  801b23:	8b 53 04             	mov    0x4(%ebx),%edx
  801b26:	8d 4a 04             	lea    0x4(%edx),%ecx
  801b29:	8b 72 04             	mov    0x4(%edx),%esi
  801b2c:	89 73 0c             	mov    %esi,0xc(%ebx)
		memmove(args->argv + 1, args->argv + 2, sizeof(const char *) * (*args->argc - 1));
  801b2f:	83 ec 04             	sub    $0x4,%esp
  801b32:	8b 00                	mov    (%eax),%eax
  801b34:	8d 04 85 fc ff ff ff 	lea    -0x4(,%eax,4),%eax
  801b3b:	50                   	push   %eax
  801b3c:	83 c2 08             	add    $0x8,%edx
  801b3f:	52                   	push   %edx
  801b40:	51                   	push   %ecx
  801b41:	e8 11 f8 ff ff       	call   801357 <memmove>
		(*args->argc)--;
  801b46:	8b 03                	mov    (%ebx),%eax
  801b48:	ff 08                	decl   (%eax)
  801b4a:	83 c4 10             	add    $0x10,%esp
  801b4d:	eb 0e                	jmp    801b5d <argnextvalue+0x61>
	} else {
		args->argvalue = 0;
  801b4f:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)
		args->curarg = 0;
  801b56:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
	}
	return (char*) args->argvalue;
  801b5d:	8b 43 0c             	mov    0xc(%ebx),%eax
  801b60:	eb 05                	jmp    801b67 <argnextvalue+0x6b>

char *
argnextvalue(struct Argstate *args)
{
	if (!args->curarg)
		return 0;
  801b62:	b8 00 00 00 00       	mov    $0x0,%eax
	} else {
		args->argvalue = 0;
		args->curarg = 0;
	}
	return (char*) args->argvalue;
}
  801b67:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801b6a:	5b                   	pop    %ebx
  801b6b:	5e                   	pop    %esi
  801b6c:	c9                   	leave  
  801b6d:	c3                   	ret    

00801b6e <argvalue>:
	return -1;
}

char *
argvalue(struct Argstate *args)
{
  801b6e:	55                   	push   %ebp
  801b6f:	89 e5                	mov    %esp,%ebp
  801b71:	83 ec 08             	sub    $0x8,%esp
  801b74:	8b 55 08             	mov    0x8(%ebp),%edx
	return (char*) (args->argvalue ? args->argvalue : argnextvalue(args));
  801b77:	8b 42 0c             	mov    0xc(%edx),%eax
  801b7a:	85 c0                	test   %eax,%eax
  801b7c:	75 0c                	jne    801b8a <argvalue+0x1c>
  801b7e:	83 ec 0c             	sub    $0xc,%esp
  801b81:	52                   	push   %edx
  801b82:	e8 75 ff ff ff       	call   801afc <argnextvalue>
  801b87:	83 c4 10             	add    $0x10,%esp
}
  801b8a:	c9                   	leave  
  801b8b:	c3                   	ret    

00801b8c <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801b8c:	55                   	push   %ebp
  801b8d:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801b8f:	8b 45 08             	mov    0x8(%ebp),%eax
  801b92:	05 00 00 00 30       	add    $0x30000000,%eax
  801b97:	c1 e8 0c             	shr    $0xc,%eax
}
  801b9a:	c9                   	leave  
  801b9b:	c3                   	ret    

00801b9c <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801b9c:	55                   	push   %ebp
  801b9d:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  801b9f:	ff 75 08             	pushl  0x8(%ebp)
  801ba2:	e8 e5 ff ff ff       	call   801b8c <fd2num>
  801ba7:	83 c4 04             	add    $0x4,%esp
  801baa:	05 20 00 0d 00       	add    $0xd0020,%eax
  801baf:	c1 e0 0c             	shl    $0xc,%eax
}
  801bb2:	c9                   	leave  
  801bb3:	c3                   	ret    

00801bb4 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801bb4:	55                   	push   %ebp
  801bb5:	89 e5                	mov    %esp,%ebp
  801bb7:	53                   	push   %ebx
  801bb8:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801bbb:	a1 00 dd 7b ef       	mov    0xef7bdd00,%eax
  801bc0:	a8 01                	test   $0x1,%al
  801bc2:	74 34                	je     801bf8 <fd_alloc+0x44>
  801bc4:	a1 00 00 74 ef       	mov    0xef740000,%eax
  801bc9:	a8 01                	test   $0x1,%al
  801bcb:	74 32                	je     801bff <fd_alloc+0x4b>
  801bcd:	b8 00 10 00 d0       	mov    $0xd0001000,%eax
  801bd2:	89 c1                	mov    %eax,%ecx
  801bd4:	89 c2                	mov    %eax,%edx
  801bd6:	c1 ea 16             	shr    $0x16,%edx
  801bd9:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801be0:	f6 c2 01             	test   $0x1,%dl
  801be3:	74 1f                	je     801c04 <fd_alloc+0x50>
  801be5:	89 c2                	mov    %eax,%edx
  801be7:	c1 ea 0c             	shr    $0xc,%edx
  801bea:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801bf1:	f6 c2 01             	test   $0x1,%dl
  801bf4:	75 17                	jne    801c0d <fd_alloc+0x59>
  801bf6:	eb 0c                	jmp    801c04 <fd_alloc+0x50>
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  801bf8:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
  801bfd:	eb 05                	jmp    801c04 <fd_alloc+0x50>
  801bff:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
  801c04:	89 0b                	mov    %ecx,(%ebx)
			return 0;
  801c06:	b8 00 00 00 00       	mov    $0x0,%eax
  801c0b:	eb 17                	jmp    801c24 <fd_alloc+0x70>
  801c0d:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  801c12:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  801c17:	75 b9                	jne    801bd2 <fd_alloc+0x1e>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801c19:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_MAX_OPEN;
  801c1f:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  801c24:	5b                   	pop    %ebx
  801c25:	c9                   	leave  
  801c26:	c3                   	ret    

00801c27 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  801c27:	55                   	push   %ebp
  801c28:	89 e5                	mov    %esp,%ebp
  801c2a:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801c2d:	83 f8 1f             	cmp    $0x1f,%eax
  801c30:	77 36                	ja     801c68 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801c32:	05 00 00 0d 00       	add    $0xd0000,%eax
  801c37:	c1 e0 0c             	shl    $0xc,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801c3a:	89 c2                	mov    %eax,%edx
  801c3c:	c1 ea 16             	shr    $0x16,%edx
  801c3f:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801c46:	f6 c2 01             	test   $0x1,%dl
  801c49:	74 24                	je     801c6f <fd_lookup+0x48>
  801c4b:	89 c2                	mov    %eax,%edx
  801c4d:	c1 ea 0c             	shr    $0xc,%edx
  801c50:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801c57:	f6 c2 01             	test   $0x1,%dl
  801c5a:	74 1a                	je     801c76 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  801c5c:	8b 55 0c             	mov    0xc(%ebp),%edx
  801c5f:	89 02                	mov    %eax,(%edx)
	return 0;
  801c61:	b8 00 00 00 00       	mov    $0x0,%eax
  801c66:	eb 13                	jmp    801c7b <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801c68:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801c6d:	eb 0c                	jmp    801c7b <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801c6f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801c74:	eb 05                	jmp    801c7b <fd_lookup+0x54>
  801c76:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  801c7b:	c9                   	leave  
  801c7c:	c3                   	ret    

00801c7d <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801c7d:	55                   	push   %ebp
  801c7e:	89 e5                	mov    %esp,%ebp
  801c80:	53                   	push   %ebx
  801c81:	83 ec 04             	sub    $0x4,%esp
  801c84:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801c87:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
		if (devtab[i]->dev_id == dev_id) {
  801c8a:	39 0d 20 40 80 00    	cmp    %ecx,0x804020
  801c90:	74 0d                	je     801c9f <dev_lookup+0x22>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801c92:	b8 00 00 00 00       	mov    $0x0,%eax
  801c97:	eb 14                	jmp    801cad <dev_lookup+0x30>
		if (devtab[i]->dev_id == dev_id) {
  801c99:	39 0a                	cmp    %ecx,(%edx)
  801c9b:	75 10                	jne    801cad <dev_lookup+0x30>
  801c9d:	eb 05                	jmp    801ca4 <dev_lookup+0x27>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801c9f:	ba 20 40 80 00       	mov    $0x804020,%edx
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
  801ca4:	89 13                	mov    %edx,(%ebx)
			return 0;
  801ca6:	b8 00 00 00 00       	mov    $0x0,%eax
  801cab:	eb 31                	jmp    801cde <dev_lookup+0x61>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801cad:	40                   	inc    %eax
  801cae:	8b 14 85 1c 3a 80 00 	mov    0x803a1c(,%eax,4),%edx
  801cb5:	85 d2                	test   %edx,%edx
  801cb7:	75 e0                	jne    801c99 <dev_lookup+0x1c>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801cb9:	a1 24 54 80 00       	mov    0x805424,%eax
  801cbe:	8b 40 48             	mov    0x48(%eax),%eax
  801cc1:	83 ec 04             	sub    $0x4,%esp
  801cc4:	51                   	push   %ecx
  801cc5:	50                   	push   %eax
  801cc6:	68 a0 39 80 00       	push   $0x8039a0
  801ccb:	e8 2c ee ff ff       	call   800afc <cprintf>
	*dev = 0;
  801cd0:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_INVAL;
  801cd6:	83 c4 10             	add    $0x10,%esp
  801cd9:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801cde:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801ce1:	c9                   	leave  
  801ce2:	c3                   	ret    

00801ce3 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  801ce3:	55                   	push   %ebp
  801ce4:	89 e5                	mov    %esp,%ebp
  801ce6:	56                   	push   %esi
  801ce7:	53                   	push   %ebx
  801ce8:	83 ec 20             	sub    $0x20,%esp
  801ceb:	8b 75 08             	mov    0x8(%ebp),%esi
  801cee:	8a 45 0c             	mov    0xc(%ebp),%al
  801cf1:	88 45 e7             	mov    %al,-0x19(%ebp)
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801cf4:	56                   	push   %esi
  801cf5:	e8 92 fe ff ff       	call   801b8c <fd2num>
  801cfa:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801cfd:	89 14 24             	mov    %edx,(%esp)
  801d00:	50                   	push   %eax
  801d01:	e8 21 ff ff ff       	call   801c27 <fd_lookup>
  801d06:	89 c3                	mov    %eax,%ebx
  801d08:	83 c4 08             	add    $0x8,%esp
  801d0b:	85 c0                	test   %eax,%eax
  801d0d:	78 05                	js     801d14 <fd_close+0x31>
	    || fd != fd2)
  801d0f:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801d12:	74 0d                	je     801d21 <fd_close+0x3e>
		return (must_exist ? r : 0);
  801d14:	80 7d e7 00          	cmpb   $0x0,-0x19(%ebp)
  801d18:	75 48                	jne    801d62 <fd_close+0x7f>
  801d1a:	bb 00 00 00 00       	mov    $0x0,%ebx
  801d1f:	eb 41                	jmp    801d62 <fd_close+0x7f>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801d21:	83 ec 08             	sub    $0x8,%esp
  801d24:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801d27:	50                   	push   %eax
  801d28:	ff 36                	pushl  (%esi)
  801d2a:	e8 4e ff ff ff       	call   801c7d <dev_lookup>
  801d2f:	89 c3                	mov    %eax,%ebx
  801d31:	83 c4 10             	add    $0x10,%esp
  801d34:	85 c0                	test   %eax,%eax
  801d36:	78 1c                	js     801d54 <fd_close+0x71>
		if (dev->dev_close)
  801d38:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801d3b:	8b 40 10             	mov    0x10(%eax),%eax
  801d3e:	85 c0                	test   %eax,%eax
  801d40:	74 0d                	je     801d4f <fd_close+0x6c>
			r = (*dev->dev_close)(fd);
  801d42:	83 ec 0c             	sub    $0xc,%esp
  801d45:	56                   	push   %esi
  801d46:	ff d0                	call   *%eax
  801d48:	89 c3                	mov    %eax,%ebx
  801d4a:	83 c4 10             	add    $0x10,%esp
  801d4d:	eb 05                	jmp    801d54 <fd_close+0x71>
		else
			r = 0;
  801d4f:	bb 00 00 00 00       	mov    $0x0,%ebx
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801d54:	83 ec 08             	sub    $0x8,%esp
  801d57:	56                   	push   %esi
  801d58:	6a 00                	push   $0x0
  801d5a:	e8 03 f9 ff ff       	call   801662 <sys_page_unmap>
	return r;
  801d5f:	83 c4 10             	add    $0x10,%esp
}
  801d62:	89 d8                	mov    %ebx,%eax
  801d64:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801d67:	5b                   	pop    %ebx
  801d68:	5e                   	pop    %esi
  801d69:	c9                   	leave  
  801d6a:	c3                   	ret    

00801d6b <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801d6b:	55                   	push   %ebp
  801d6c:	89 e5                	mov    %esp,%ebp
  801d6e:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801d71:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801d74:	50                   	push   %eax
  801d75:	ff 75 08             	pushl  0x8(%ebp)
  801d78:	e8 aa fe ff ff       	call   801c27 <fd_lookup>
  801d7d:	83 c4 08             	add    $0x8,%esp
  801d80:	85 c0                	test   %eax,%eax
  801d82:	78 10                	js     801d94 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  801d84:	83 ec 08             	sub    $0x8,%esp
  801d87:	6a 01                	push   $0x1
  801d89:	ff 75 f4             	pushl  -0xc(%ebp)
  801d8c:	e8 52 ff ff ff       	call   801ce3 <fd_close>
  801d91:	83 c4 10             	add    $0x10,%esp
}
  801d94:	c9                   	leave  
  801d95:	c3                   	ret    

00801d96 <close_all>:

void
close_all(void)
{
  801d96:	55                   	push   %ebp
  801d97:	89 e5                	mov    %esp,%ebp
  801d99:	53                   	push   %ebx
  801d9a:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801d9d:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801da2:	83 ec 0c             	sub    $0xc,%esp
  801da5:	53                   	push   %ebx
  801da6:	e8 c0 ff ff ff       	call   801d6b <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801dab:	43                   	inc    %ebx
  801dac:	83 c4 10             	add    $0x10,%esp
  801daf:	83 fb 20             	cmp    $0x20,%ebx
  801db2:	75 ee                	jne    801da2 <close_all+0xc>
		close(i);
}
  801db4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801db7:	c9                   	leave  
  801db8:	c3                   	ret    

00801db9 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801db9:	55                   	push   %ebp
  801dba:	89 e5                	mov    %esp,%ebp
  801dbc:	57                   	push   %edi
  801dbd:	56                   	push   %esi
  801dbe:	53                   	push   %ebx
  801dbf:	83 ec 2c             	sub    $0x2c,%esp
  801dc2:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801dc5:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801dc8:	50                   	push   %eax
  801dc9:	ff 75 08             	pushl  0x8(%ebp)
  801dcc:	e8 56 fe ff ff       	call   801c27 <fd_lookup>
  801dd1:	89 c3                	mov    %eax,%ebx
  801dd3:	83 c4 08             	add    $0x8,%esp
  801dd6:	85 c0                	test   %eax,%eax
  801dd8:	0f 88 c0 00 00 00    	js     801e9e <dup+0xe5>
		return r;
	close(newfdnum);
  801dde:	83 ec 0c             	sub    $0xc,%esp
  801de1:	57                   	push   %edi
  801de2:	e8 84 ff ff ff       	call   801d6b <close>

	newfd = INDEX2FD(newfdnum);
  801de7:	8d b7 00 00 0d 00    	lea    0xd0000(%edi),%esi
  801ded:	c1 e6 0c             	shl    $0xc,%esi
	ova = fd2data(oldfd);
  801df0:	83 c4 04             	add    $0x4,%esp
  801df3:	ff 75 e4             	pushl  -0x1c(%ebp)
  801df6:	e8 a1 fd ff ff       	call   801b9c <fd2data>
  801dfb:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  801dfd:	89 34 24             	mov    %esi,(%esp)
  801e00:	e8 97 fd ff ff       	call   801b9c <fd2data>
  801e05:	83 c4 10             	add    $0x10,%esp
  801e08:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801e0b:	89 d8                	mov    %ebx,%eax
  801e0d:	c1 e8 16             	shr    $0x16,%eax
  801e10:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801e17:	a8 01                	test   $0x1,%al
  801e19:	74 37                	je     801e52 <dup+0x99>
  801e1b:	89 d8                	mov    %ebx,%eax
  801e1d:	c1 e8 0c             	shr    $0xc,%eax
  801e20:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801e27:	f6 c2 01             	test   $0x1,%dl
  801e2a:	74 26                	je     801e52 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801e2c:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801e33:	83 ec 0c             	sub    $0xc,%esp
  801e36:	25 07 0e 00 00       	and    $0xe07,%eax
  801e3b:	50                   	push   %eax
  801e3c:	ff 75 d4             	pushl  -0x2c(%ebp)
  801e3f:	6a 00                	push   $0x0
  801e41:	53                   	push   %ebx
  801e42:	6a 00                	push   $0x0
  801e44:	e8 f3 f7 ff ff       	call   80163c <sys_page_map>
  801e49:	89 c3                	mov    %eax,%ebx
  801e4b:	83 c4 20             	add    $0x20,%esp
  801e4e:	85 c0                	test   %eax,%eax
  801e50:	78 2d                	js     801e7f <dup+0xc6>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801e52:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801e55:	89 c2                	mov    %eax,%edx
  801e57:	c1 ea 0c             	shr    $0xc,%edx
  801e5a:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801e61:	83 ec 0c             	sub    $0xc,%esp
  801e64:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  801e6a:	52                   	push   %edx
  801e6b:	56                   	push   %esi
  801e6c:	6a 00                	push   $0x0
  801e6e:	50                   	push   %eax
  801e6f:	6a 00                	push   $0x0
  801e71:	e8 c6 f7 ff ff       	call   80163c <sys_page_map>
  801e76:	89 c3                	mov    %eax,%ebx
  801e78:	83 c4 20             	add    $0x20,%esp
  801e7b:	85 c0                	test   %eax,%eax
  801e7d:	79 1d                	jns    801e9c <dup+0xe3>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801e7f:	83 ec 08             	sub    $0x8,%esp
  801e82:	56                   	push   %esi
  801e83:	6a 00                	push   $0x0
  801e85:	e8 d8 f7 ff ff       	call   801662 <sys_page_unmap>
	sys_page_unmap(0, nva);
  801e8a:	83 c4 08             	add    $0x8,%esp
  801e8d:	ff 75 d4             	pushl  -0x2c(%ebp)
  801e90:	6a 00                	push   $0x0
  801e92:	e8 cb f7 ff ff       	call   801662 <sys_page_unmap>
	return r;
  801e97:	83 c4 10             	add    $0x10,%esp
  801e9a:	eb 02                	jmp    801e9e <dup+0xe5>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
		goto err;

	return newfdnum;
  801e9c:	89 fb                	mov    %edi,%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  801e9e:	89 d8                	mov    %ebx,%eax
  801ea0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801ea3:	5b                   	pop    %ebx
  801ea4:	5e                   	pop    %esi
  801ea5:	5f                   	pop    %edi
  801ea6:	c9                   	leave  
  801ea7:	c3                   	ret    

00801ea8 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801ea8:	55                   	push   %ebp
  801ea9:	89 e5                	mov    %esp,%ebp
  801eab:	53                   	push   %ebx
  801eac:	83 ec 14             	sub    $0x14,%esp
  801eaf:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801eb2:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801eb5:	50                   	push   %eax
  801eb6:	53                   	push   %ebx
  801eb7:	e8 6b fd ff ff       	call   801c27 <fd_lookup>
  801ebc:	83 c4 08             	add    $0x8,%esp
  801ebf:	85 c0                	test   %eax,%eax
  801ec1:	78 67                	js     801f2a <read+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801ec3:	83 ec 08             	sub    $0x8,%esp
  801ec6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801ec9:	50                   	push   %eax
  801eca:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801ecd:	ff 30                	pushl  (%eax)
  801ecf:	e8 a9 fd ff ff       	call   801c7d <dev_lookup>
  801ed4:	83 c4 10             	add    $0x10,%esp
  801ed7:	85 c0                	test   %eax,%eax
  801ed9:	78 4f                	js     801f2a <read+0x82>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801edb:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801ede:	8b 50 08             	mov    0x8(%eax),%edx
  801ee1:	83 e2 03             	and    $0x3,%edx
  801ee4:	83 fa 01             	cmp    $0x1,%edx
  801ee7:	75 21                	jne    801f0a <read+0x62>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801ee9:	a1 24 54 80 00       	mov    0x805424,%eax
  801eee:	8b 40 48             	mov    0x48(%eax),%eax
  801ef1:	83 ec 04             	sub    $0x4,%esp
  801ef4:	53                   	push   %ebx
  801ef5:	50                   	push   %eax
  801ef6:	68 e1 39 80 00       	push   $0x8039e1
  801efb:	e8 fc eb ff ff       	call   800afc <cprintf>
		return -E_INVAL;
  801f00:	83 c4 10             	add    $0x10,%esp
  801f03:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801f08:	eb 20                	jmp    801f2a <read+0x82>
	}
	if (!dev->dev_read)
  801f0a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801f0d:	8b 52 08             	mov    0x8(%edx),%edx
  801f10:	85 d2                	test   %edx,%edx
  801f12:	74 11                	je     801f25 <read+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801f14:	83 ec 04             	sub    $0x4,%esp
  801f17:	ff 75 10             	pushl  0x10(%ebp)
  801f1a:	ff 75 0c             	pushl  0xc(%ebp)
  801f1d:	50                   	push   %eax
  801f1e:	ff d2                	call   *%edx
  801f20:	83 c4 10             	add    $0x10,%esp
  801f23:	eb 05                	jmp    801f2a <read+0x82>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801f25:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_read)(fd, buf, n);
}
  801f2a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801f2d:	c9                   	leave  
  801f2e:	c3                   	ret    

00801f2f <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801f2f:	55                   	push   %ebp
  801f30:	89 e5                	mov    %esp,%ebp
  801f32:	57                   	push   %edi
  801f33:	56                   	push   %esi
  801f34:	53                   	push   %ebx
  801f35:	83 ec 0c             	sub    $0xc,%esp
  801f38:	8b 7d 08             	mov    0x8(%ebp),%edi
  801f3b:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801f3e:	85 f6                	test   %esi,%esi
  801f40:	74 31                	je     801f73 <readn+0x44>
  801f42:	b8 00 00 00 00       	mov    $0x0,%eax
  801f47:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = read(fdnum, (char*)buf + tot, n - tot);
  801f4c:	83 ec 04             	sub    $0x4,%esp
  801f4f:	89 f2                	mov    %esi,%edx
  801f51:	29 c2                	sub    %eax,%edx
  801f53:	52                   	push   %edx
  801f54:	03 45 0c             	add    0xc(%ebp),%eax
  801f57:	50                   	push   %eax
  801f58:	57                   	push   %edi
  801f59:	e8 4a ff ff ff       	call   801ea8 <read>
		if (m < 0)
  801f5e:	83 c4 10             	add    $0x10,%esp
  801f61:	85 c0                	test   %eax,%eax
  801f63:	78 17                	js     801f7c <readn+0x4d>
			return m;
		if (m == 0)
  801f65:	85 c0                	test   %eax,%eax
  801f67:	74 11                	je     801f7a <readn+0x4b>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801f69:	01 c3                	add    %eax,%ebx
  801f6b:	89 d8                	mov    %ebx,%eax
  801f6d:	39 f3                	cmp    %esi,%ebx
  801f6f:	72 db                	jb     801f4c <readn+0x1d>
  801f71:	eb 09                	jmp    801f7c <readn+0x4d>
  801f73:	b8 00 00 00 00       	mov    $0x0,%eax
  801f78:	eb 02                	jmp    801f7c <readn+0x4d>
		m = read(fdnum, (char*)buf + tot, n - tot);
		if (m < 0)
			return m;
		if (m == 0)
  801f7a:	89 d8                	mov    %ebx,%eax
			break;
	}
	return tot;
}
  801f7c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801f7f:	5b                   	pop    %ebx
  801f80:	5e                   	pop    %esi
  801f81:	5f                   	pop    %edi
  801f82:	c9                   	leave  
  801f83:	c3                   	ret    

00801f84 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801f84:	55                   	push   %ebp
  801f85:	89 e5                	mov    %esp,%ebp
  801f87:	53                   	push   %ebx
  801f88:	83 ec 14             	sub    $0x14,%esp
  801f8b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801f8e:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801f91:	50                   	push   %eax
  801f92:	53                   	push   %ebx
  801f93:	e8 8f fc ff ff       	call   801c27 <fd_lookup>
  801f98:	83 c4 08             	add    $0x8,%esp
  801f9b:	85 c0                	test   %eax,%eax
  801f9d:	78 62                	js     802001 <write+0x7d>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801f9f:	83 ec 08             	sub    $0x8,%esp
  801fa2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801fa5:	50                   	push   %eax
  801fa6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801fa9:	ff 30                	pushl  (%eax)
  801fab:	e8 cd fc ff ff       	call   801c7d <dev_lookup>
  801fb0:	83 c4 10             	add    $0x10,%esp
  801fb3:	85 c0                	test   %eax,%eax
  801fb5:	78 4a                	js     802001 <write+0x7d>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801fb7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801fba:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801fbe:	75 21                	jne    801fe1 <write+0x5d>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801fc0:	a1 24 54 80 00       	mov    0x805424,%eax
  801fc5:	8b 40 48             	mov    0x48(%eax),%eax
  801fc8:	83 ec 04             	sub    $0x4,%esp
  801fcb:	53                   	push   %ebx
  801fcc:	50                   	push   %eax
  801fcd:	68 fd 39 80 00       	push   $0x8039fd
  801fd2:	e8 25 eb ff ff       	call   800afc <cprintf>
		return -E_INVAL;
  801fd7:	83 c4 10             	add    $0x10,%esp
  801fda:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801fdf:	eb 20                	jmp    802001 <write+0x7d>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801fe1:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801fe4:	8b 52 0c             	mov    0xc(%edx),%edx
  801fe7:	85 d2                	test   %edx,%edx
  801fe9:	74 11                	je     801ffc <write+0x78>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801feb:	83 ec 04             	sub    $0x4,%esp
  801fee:	ff 75 10             	pushl  0x10(%ebp)
  801ff1:	ff 75 0c             	pushl  0xc(%ebp)
  801ff4:	50                   	push   %eax
  801ff5:	ff d2                	call   *%edx
  801ff7:	83 c4 10             	add    $0x10,%esp
  801ffa:	eb 05                	jmp    802001 <write+0x7d>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801ffc:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  802001:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802004:	c9                   	leave  
  802005:	c3                   	ret    

00802006 <seek>:

int
seek(int fdnum, off_t offset)
{
  802006:	55                   	push   %ebp
  802007:	89 e5                	mov    %esp,%ebp
  802009:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80200c:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80200f:	50                   	push   %eax
  802010:	ff 75 08             	pushl  0x8(%ebp)
  802013:	e8 0f fc ff ff       	call   801c27 <fd_lookup>
  802018:	83 c4 08             	add    $0x8,%esp
  80201b:	85 c0                	test   %eax,%eax
  80201d:	78 0e                	js     80202d <seek+0x27>
		return r;
	fd->fd_offset = offset;
  80201f:	8b 45 fc             	mov    -0x4(%ebp),%eax
  802022:	8b 55 0c             	mov    0xc(%ebp),%edx
  802025:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  802028:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80202d:	c9                   	leave  
  80202e:	c3                   	ret    

0080202f <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  80202f:	55                   	push   %ebp
  802030:	89 e5                	mov    %esp,%ebp
  802032:	53                   	push   %ebx
  802033:	83 ec 14             	sub    $0x14,%esp
  802036:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  802039:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80203c:	50                   	push   %eax
  80203d:	53                   	push   %ebx
  80203e:	e8 e4 fb ff ff       	call   801c27 <fd_lookup>
  802043:	83 c4 08             	add    $0x8,%esp
  802046:	85 c0                	test   %eax,%eax
  802048:	78 5f                	js     8020a9 <ftruncate+0x7a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80204a:	83 ec 08             	sub    $0x8,%esp
  80204d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802050:	50                   	push   %eax
  802051:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802054:	ff 30                	pushl  (%eax)
  802056:	e8 22 fc ff ff       	call   801c7d <dev_lookup>
  80205b:	83 c4 10             	add    $0x10,%esp
  80205e:	85 c0                	test   %eax,%eax
  802060:	78 47                	js     8020a9 <ftruncate+0x7a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  802062:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802065:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  802069:	75 21                	jne    80208c <ftruncate+0x5d>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  80206b:	a1 24 54 80 00       	mov    0x805424,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  802070:	8b 40 48             	mov    0x48(%eax),%eax
  802073:	83 ec 04             	sub    $0x4,%esp
  802076:	53                   	push   %ebx
  802077:	50                   	push   %eax
  802078:	68 c0 39 80 00       	push   $0x8039c0
  80207d:	e8 7a ea ff ff       	call   800afc <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  802082:	83 c4 10             	add    $0x10,%esp
  802085:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80208a:	eb 1d                	jmp    8020a9 <ftruncate+0x7a>
	}
	if (!dev->dev_trunc)
  80208c:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80208f:	8b 52 18             	mov    0x18(%edx),%edx
  802092:	85 d2                	test   %edx,%edx
  802094:	74 0e                	je     8020a4 <ftruncate+0x75>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  802096:	83 ec 08             	sub    $0x8,%esp
  802099:	ff 75 0c             	pushl  0xc(%ebp)
  80209c:	50                   	push   %eax
  80209d:	ff d2                	call   *%edx
  80209f:	83 c4 10             	add    $0x10,%esp
  8020a2:	eb 05                	jmp    8020a9 <ftruncate+0x7a>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8020a4:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  8020a9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8020ac:	c9                   	leave  
  8020ad:	c3                   	ret    

008020ae <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8020ae:	55                   	push   %ebp
  8020af:	89 e5                	mov    %esp,%ebp
  8020b1:	53                   	push   %ebx
  8020b2:	83 ec 14             	sub    $0x14,%esp
  8020b5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8020b8:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8020bb:	50                   	push   %eax
  8020bc:	ff 75 08             	pushl  0x8(%ebp)
  8020bf:	e8 63 fb ff ff       	call   801c27 <fd_lookup>
  8020c4:	83 c4 08             	add    $0x8,%esp
  8020c7:	85 c0                	test   %eax,%eax
  8020c9:	78 52                	js     80211d <fstat+0x6f>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8020cb:	83 ec 08             	sub    $0x8,%esp
  8020ce:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8020d1:	50                   	push   %eax
  8020d2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8020d5:	ff 30                	pushl  (%eax)
  8020d7:	e8 a1 fb ff ff       	call   801c7d <dev_lookup>
  8020dc:	83 c4 10             	add    $0x10,%esp
  8020df:	85 c0                	test   %eax,%eax
  8020e1:	78 3a                	js     80211d <fstat+0x6f>
		return r;
	if (!dev->dev_stat)
  8020e3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8020e6:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8020ea:	74 2c                	je     802118 <fstat+0x6a>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8020ec:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8020ef:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8020f6:	00 00 00 
	stat->st_isdir = 0;
  8020f9:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  802100:	00 00 00 
	stat->st_dev = dev;
  802103:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  802109:	83 ec 08             	sub    $0x8,%esp
  80210c:	53                   	push   %ebx
  80210d:	ff 75 f0             	pushl  -0x10(%ebp)
  802110:	ff 50 14             	call   *0x14(%eax)
  802113:	83 c4 10             	add    $0x10,%esp
  802116:	eb 05                	jmp    80211d <fstat+0x6f>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  802118:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  80211d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802120:	c9                   	leave  
  802121:	c3                   	ret    

00802122 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  802122:	55                   	push   %ebp
  802123:	89 e5                	mov    %esp,%ebp
  802125:	56                   	push   %esi
  802126:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  802127:	83 ec 08             	sub    $0x8,%esp
  80212a:	6a 00                	push   $0x0
  80212c:	ff 75 08             	pushl  0x8(%ebp)
  80212f:	e8 8b 01 00 00       	call   8022bf <open>
  802134:	89 c3                	mov    %eax,%ebx
  802136:	83 c4 10             	add    $0x10,%esp
  802139:	85 c0                	test   %eax,%eax
  80213b:	78 1b                	js     802158 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  80213d:	83 ec 08             	sub    $0x8,%esp
  802140:	ff 75 0c             	pushl  0xc(%ebp)
  802143:	50                   	push   %eax
  802144:	e8 65 ff ff ff       	call   8020ae <fstat>
  802149:	89 c6                	mov    %eax,%esi
	close(fd);
  80214b:	89 1c 24             	mov    %ebx,(%esp)
  80214e:	e8 18 fc ff ff       	call   801d6b <close>
	return r;
  802153:	83 c4 10             	add    $0x10,%esp
  802156:	89 f3                	mov    %esi,%ebx
}
  802158:	89 d8                	mov    %ebx,%eax
  80215a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80215d:	5b                   	pop    %ebx
  80215e:	5e                   	pop    %esi
  80215f:	c9                   	leave  
  802160:	c3                   	ret    
  802161:	00 00                	add    %al,(%eax)
	...

00802164 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  802164:	55                   	push   %ebp
  802165:	89 e5                	mov    %esp,%ebp
  802167:	56                   	push   %esi
  802168:	53                   	push   %ebx
  802169:	89 c3                	mov    %eax,%ebx
  80216b:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  80216d:	83 3d 20 54 80 00 00 	cmpl   $0x0,0x805420
  802174:	75 12                	jne    802188 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  802176:	83 ec 0c             	sub    $0xc,%esp
  802179:	6a 01                	push   $0x1
  80217b:	e8 29 0e 00 00       	call   802fa9 <ipc_find_env>
  802180:	a3 20 54 80 00       	mov    %eax,0x805420
  802185:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  802188:	6a 07                	push   $0x7
  80218a:	68 00 60 80 00       	push   $0x806000
  80218f:	53                   	push   %ebx
  802190:	ff 35 20 54 80 00    	pushl  0x805420
  802196:	e8 b9 0d 00 00       	call   802f54 <ipc_send>
	
	return ipc_recv(NULL, dstva, NULL);
  80219b:	83 c4 0c             	add    $0xc,%esp
  80219e:	6a 00                	push   $0x0
  8021a0:	56                   	push   %esi
  8021a1:	6a 00                	push   $0x0
  8021a3:	e8 04 0d 00 00       	call   802eac <ipc_recv>
}
  8021a8:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8021ab:	5b                   	pop    %ebx
  8021ac:	5e                   	pop    %esi
  8021ad:	c9                   	leave  
  8021ae:	c3                   	ret    

008021af <devfile_stat>:
}


static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8021af:	55                   	push   %ebp
  8021b0:	89 e5                	mov    %esp,%ebp
  8021b2:	53                   	push   %ebx
  8021b3:	83 ec 04             	sub    $0x4,%esp
  8021b6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8021b9:	8b 45 08             	mov    0x8(%ebp),%eax
  8021bc:	8b 40 0c             	mov    0xc(%eax),%eax
  8021bf:	a3 00 60 80 00       	mov    %eax,0x806000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0) {
  8021c4:	ba 00 00 00 00       	mov    $0x0,%edx
  8021c9:	b8 05 00 00 00       	mov    $0x5,%eax
  8021ce:	e8 91 ff ff ff       	call   802164 <fsipc>
  8021d3:	85 c0                	test   %eax,%eax
  8021d5:	78 39                	js     802210 <devfile_stat+0x61>
		return r;
	}
	cprintf("OVER\n");
  8021d7:	83 ec 0c             	sub    $0xc,%esp
  8021da:	68 2c 3a 80 00       	push   $0x803a2c
  8021df:	e8 18 e9 ff ff       	call   800afc <cprintf>
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8021e4:	83 c4 08             	add    $0x8,%esp
  8021e7:	68 00 60 80 00       	push   $0x806000
  8021ec:	53                   	push   %ebx
  8021ed:	e8 a4 ef ff ff       	call   801196 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8021f2:	a1 80 60 80 00       	mov    0x806080,%eax
  8021f7:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8021fd:	a1 84 60 80 00       	mov    0x806084,%eax
  802202:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  802208:	83 c4 10             	add    $0x10,%esp
  80220b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802210:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802213:	c9                   	leave  
  802214:	c3                   	ret    

00802215 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  802215:	55                   	push   %ebp
  802216:	89 e5                	mov    %esp,%ebp
  802218:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  80221b:	8b 45 08             	mov    0x8(%ebp),%eax
  80221e:	8b 40 0c             	mov    0xc(%eax),%eax
  802221:	a3 00 60 80 00       	mov    %eax,0x806000
	return fsipc(FSREQ_FLUSH, NULL);
  802226:	ba 00 00 00 00       	mov    $0x0,%edx
  80222b:	b8 06 00 00 00       	mov    $0x6,%eax
  802230:	e8 2f ff ff ff       	call   802164 <fsipc>
}
  802235:	c9                   	leave  
  802236:	c3                   	ret    

00802237 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  802237:	55                   	push   %ebp
  802238:	89 e5                	mov    %esp,%ebp
  80223a:	56                   	push   %esi
  80223b:	53                   	push   %ebx
  80223c:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  80223f:	8b 45 08             	mov    0x8(%ebp),%eax
  802242:	8b 40 0c             	mov    0xc(%eax),%eax
  802245:	a3 00 60 80 00       	mov    %eax,0x806000
	fsipcbuf.read.req_n = n;
  80224a:	89 35 04 60 80 00    	mov    %esi,0x806004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  802250:	ba 00 00 00 00       	mov    $0x0,%edx
  802255:	b8 03 00 00 00       	mov    $0x3,%eax
  80225a:	e8 05 ff ff ff       	call   802164 <fsipc>
  80225f:	89 c3                	mov    %eax,%ebx
  802261:	85 c0                	test   %eax,%eax
  802263:	78 51                	js     8022b6 <devfile_read+0x7f>
		return r;
	assert(r <= n);
  802265:	39 c6                	cmp    %eax,%esi
  802267:	73 19                	jae    802282 <devfile_read+0x4b>
  802269:	68 32 3a 80 00       	push   $0x803a32
  80226e:	68 f2 33 80 00       	push   $0x8033f2
  802273:	68 80 00 00 00       	push   $0x80
  802278:	68 39 3a 80 00       	push   $0x803a39
  80227d:	e8 a2 e7 ff ff       	call   800a24 <_panic>
	assert(r <= PGSIZE);
  802282:	3d 00 10 00 00       	cmp    $0x1000,%eax
  802287:	7e 19                	jle    8022a2 <devfile_read+0x6b>
  802289:	68 44 3a 80 00       	push   $0x803a44
  80228e:	68 f2 33 80 00       	push   $0x8033f2
  802293:	68 81 00 00 00       	push   $0x81
  802298:	68 39 3a 80 00       	push   $0x803a39
  80229d:	e8 82 e7 ff ff       	call   800a24 <_panic>
	memmove(buf, &fsipcbuf, r);
  8022a2:	83 ec 04             	sub    $0x4,%esp
  8022a5:	50                   	push   %eax
  8022a6:	68 00 60 80 00       	push   $0x806000
  8022ab:	ff 75 0c             	pushl  0xc(%ebp)
  8022ae:	e8 a4 f0 ff ff       	call   801357 <memmove>
	return r;
  8022b3:	83 c4 10             	add    $0x10,%esp
}
  8022b6:	89 d8                	mov    %ebx,%eax
  8022b8:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8022bb:	5b                   	pop    %ebx
  8022bc:	5e                   	pop    %esi
  8022bd:	c9                   	leave  
  8022be:	c3                   	ret    

008022bf <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  8022bf:	55                   	push   %ebp
  8022c0:	89 e5                	mov    %esp,%ebp
  8022c2:	56                   	push   %esi
  8022c3:	53                   	push   %ebx
  8022c4:	83 ec 1c             	sub    $0x1c,%esp
  8022c7:	8b 75 08             	mov    0x8(%ebp),%esi
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  8022ca:	56                   	push   %esi
  8022cb:	e8 74 ee ff ff       	call   801144 <strlen>
  8022d0:	83 c4 10             	add    $0x10,%esp
  8022d3:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8022d8:	7f 72                	jg     80234c <open+0x8d>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8022da:	83 ec 0c             	sub    $0xc,%esp
  8022dd:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8022e0:	50                   	push   %eax
  8022e1:	e8 ce f8 ff ff       	call   801bb4 <fd_alloc>
  8022e6:	89 c3                	mov    %eax,%ebx
  8022e8:	83 c4 10             	add    $0x10,%esp
  8022eb:	85 c0                	test   %eax,%eax
  8022ed:	78 62                	js     802351 <open+0x92>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  8022ef:	83 ec 08             	sub    $0x8,%esp
  8022f2:	56                   	push   %esi
  8022f3:	68 00 60 80 00       	push   $0x806000
  8022f8:	e8 99 ee ff ff       	call   801196 <strcpy>
	fsipcbuf.open.req_omode = mode;
  8022fd:	8b 45 0c             	mov    0xc(%ebp),%eax
  802300:	a3 00 64 80 00       	mov    %eax,0x806400



	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  802305:	8b 55 f4             	mov    -0xc(%ebp),%edx
  802308:	b8 01 00 00 00       	mov    $0x1,%eax
  80230d:	e8 52 fe ff ff       	call   802164 <fsipc>
  802312:	89 c3                	mov    %eax,%ebx
  802314:	83 c4 10             	add    $0x10,%esp
  802317:	85 c0                	test   %eax,%eax
  802319:	79 12                	jns    80232d <open+0x6e>
		fd_close(fd, 0);
  80231b:	83 ec 08             	sub    $0x8,%esp
  80231e:	6a 00                	push   $0x0
  802320:	ff 75 f4             	pushl  -0xc(%ebp)
  802323:	e8 bb f9 ff ff       	call   801ce3 <fd_close>
		return r;
  802328:	83 c4 10             	add    $0x10,%esp
  80232b:	eb 24                	jmp    802351 <open+0x92>
	}


	cprintf("OPEN\n");
  80232d:	83 ec 0c             	sub    $0xc,%esp
  802330:	68 50 3a 80 00       	push   $0x803a50
  802335:	e8 c2 e7 ff ff       	call   800afc <cprintf>

	return fd2num(fd);
  80233a:	83 c4 04             	add    $0x4,%esp
  80233d:	ff 75 f4             	pushl  -0xc(%ebp)
  802340:	e8 47 f8 ff ff       	call   801b8c <fd2num>
  802345:	89 c3                	mov    %eax,%ebx
  802347:	83 c4 10             	add    $0x10,%esp
  80234a:	eb 05                	jmp    802351 <open+0x92>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  80234c:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx


	cprintf("OPEN\n");

	return fd2num(fd);
}
  802351:	89 d8                	mov    %ebx,%eax
  802353:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802356:	5b                   	pop    %ebx
  802357:	5e                   	pop    %esi
  802358:	c9                   	leave  
  802359:	c3                   	ret    
	...

0080235c <writebuf>:
};


static void
writebuf(struct printbuf *b)
{
  80235c:	55                   	push   %ebp
  80235d:	89 e5                	mov    %esp,%ebp
  80235f:	53                   	push   %ebx
  802360:	83 ec 04             	sub    $0x4,%esp
  802363:	89 c3                	mov    %eax,%ebx
	if (b->error > 0) {
  802365:	83 78 0c 00          	cmpl   $0x0,0xc(%eax)
  802369:	7e 2e                	jle    802399 <writebuf+0x3d>
		ssize_t result = write(b->fd, b->buf, b->idx);
  80236b:	83 ec 04             	sub    $0x4,%esp
  80236e:	ff 70 04             	pushl  0x4(%eax)
  802371:	8d 40 10             	lea    0x10(%eax),%eax
  802374:	50                   	push   %eax
  802375:	ff 33                	pushl  (%ebx)
  802377:	e8 08 fc ff ff       	call   801f84 <write>
		if (result > 0)
  80237c:	83 c4 10             	add    $0x10,%esp
  80237f:	85 c0                	test   %eax,%eax
  802381:	7e 03                	jle    802386 <writebuf+0x2a>
			b->result += result;
  802383:	01 43 08             	add    %eax,0x8(%ebx)
		if (result != b->idx) // error, or wrote less than supplied
  802386:	39 43 04             	cmp    %eax,0x4(%ebx)
  802389:	74 0e                	je     802399 <writebuf+0x3d>
			b->error = (result < 0 ? result : 0);
  80238b:	89 c2                	mov    %eax,%edx
  80238d:	85 c0                	test   %eax,%eax
  80238f:	7e 05                	jle    802396 <writebuf+0x3a>
  802391:	ba 00 00 00 00       	mov    $0x0,%edx
  802396:	89 53 0c             	mov    %edx,0xc(%ebx)
	}
}
  802399:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80239c:	c9                   	leave  
  80239d:	c3                   	ret    

0080239e <putch>:

static void
putch(int ch, void *thunk)
{
  80239e:	55                   	push   %ebp
  80239f:	89 e5                	mov    %esp,%ebp
  8023a1:	53                   	push   %ebx
  8023a2:	83 ec 04             	sub    $0x4,%esp
  8023a5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct printbuf *b = (struct printbuf *) thunk;
	b->buf[b->idx++] = ch;
  8023a8:	8b 43 04             	mov    0x4(%ebx),%eax
  8023ab:	8b 55 08             	mov    0x8(%ebp),%edx
  8023ae:	88 54 03 10          	mov    %dl,0x10(%ebx,%eax,1)
  8023b2:	40                   	inc    %eax
  8023b3:	89 43 04             	mov    %eax,0x4(%ebx)
	if (b->idx == 256) {
  8023b6:	3d 00 01 00 00       	cmp    $0x100,%eax
  8023bb:	75 0e                	jne    8023cb <putch+0x2d>
		writebuf(b);
  8023bd:	89 d8                	mov    %ebx,%eax
  8023bf:	e8 98 ff ff ff       	call   80235c <writebuf>
		b->idx = 0;
  8023c4:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	}
}
  8023cb:	83 c4 04             	add    $0x4,%esp
  8023ce:	5b                   	pop    %ebx
  8023cf:	c9                   	leave  
  8023d0:	c3                   	ret    

008023d1 <vfprintf>:

int
vfprintf(int fd, const char *fmt, va_list ap)
{
  8023d1:	55                   	push   %ebp
  8023d2:	89 e5                	mov    %esp,%ebp
  8023d4:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.fd = fd;
  8023da:	8b 45 08             	mov    0x8(%ebp),%eax
  8023dd:	89 85 e8 fe ff ff    	mov    %eax,-0x118(%ebp)
	b.idx = 0;
  8023e3:	c7 85 ec fe ff ff 00 	movl   $0x0,-0x114(%ebp)
  8023ea:	00 00 00 
	b.result = 0;
  8023ed:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8023f4:	00 00 00 
	b.error = 1;
  8023f7:	c7 85 f4 fe ff ff 01 	movl   $0x1,-0x10c(%ebp)
  8023fe:	00 00 00 
	vprintfmt(putch, &b, fmt, ap);
  802401:	ff 75 10             	pushl  0x10(%ebp)
  802404:	ff 75 0c             	pushl  0xc(%ebp)
  802407:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  80240d:	50                   	push   %eax
  80240e:	68 9e 23 80 00       	push   $0x80239e
  802413:	e8 49 e8 ff ff       	call   800c61 <vprintfmt>
	if (b.idx > 0)
  802418:	83 c4 10             	add    $0x10,%esp
  80241b:	83 bd ec fe ff ff 00 	cmpl   $0x0,-0x114(%ebp)
  802422:	7e 0b                	jle    80242f <vfprintf+0x5e>
		writebuf(&b);
  802424:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  80242a:	e8 2d ff ff ff       	call   80235c <writebuf>

	return (b.result ? b.result : b.error);
  80242f:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  802435:	85 c0                	test   %eax,%eax
  802437:	75 06                	jne    80243f <vfprintf+0x6e>
  802439:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
}
  80243f:	c9                   	leave  
  802440:	c3                   	ret    

00802441 <fprintf>:

int
fprintf(int fd, const char *fmt, ...)
{
  802441:	55                   	push   %ebp
  802442:	89 e5                	mov    %esp,%ebp
  802444:	83 ec 0c             	sub    $0xc,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  802447:	8d 45 10             	lea    0x10(%ebp),%eax
	cnt = vfprintf(fd, fmt, ap);
  80244a:	50                   	push   %eax
  80244b:	ff 75 0c             	pushl  0xc(%ebp)
  80244e:	ff 75 08             	pushl  0x8(%ebp)
  802451:	e8 7b ff ff ff       	call   8023d1 <vfprintf>
	va_end(ap);

	return cnt;
}
  802456:	c9                   	leave  
  802457:	c3                   	ret    

00802458 <printf>:

int
printf(const char *fmt, ...)
{
  802458:	55                   	push   %ebp
  802459:	89 e5                	mov    %esp,%ebp
  80245b:	83 ec 0c             	sub    $0xc,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80245e:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vfprintf(1, fmt, ap);
  802461:	50                   	push   %eax
  802462:	ff 75 08             	pushl  0x8(%ebp)
  802465:	6a 01                	push   $0x1
  802467:	e8 65 ff ff ff       	call   8023d1 <vfprintf>
	va_end(ap);

	return cnt;
}
  80246c:	c9                   	leave  
  80246d:	c3                   	ret    
	...

00802470 <spawn>:
// argv: pointer to null-terminated array of pointers to strings,
// 	 which will be passed to the child as its command-line arguments.
// Returns child envid on success, < 0 on failure.
int
spawn(const char *prog, const char **argv)
{
  802470:	55                   	push   %ebp
  802471:	89 e5                	mov    %esp,%ebp
  802473:	57                   	push   %edi
  802474:	56                   	push   %esi
  802475:	53                   	push   %ebx
  802476:	81 ec 94 02 00 00    	sub    $0x294,%esp
	//   - Call sys_env_set_trapframe(child, &child_tf) to set up the
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
  80247c:	6a 00                	push   $0x0
  80247e:	ff 75 08             	pushl  0x8(%ebp)
  802481:	e8 39 fe ff ff       	call   8022bf <open>
  802486:	89 85 88 fd ff ff    	mov    %eax,-0x278(%ebp)
  80248c:	83 c4 10             	add    $0x10,%esp
  80248f:	85 c0                	test   %eax,%eax
  802491:	0f 88 ce 04 00 00    	js     802965 <spawn+0x4f5>
		return r;
	fd = r;

	// Read elf header
	elf = (struct Elf*) elf_buf;
	if (readn(fd, elf_buf, sizeof(elf_buf)) != sizeof(elf_buf)
  802497:	83 ec 04             	sub    $0x4,%esp
  80249a:	68 00 02 00 00       	push   $0x200
  80249f:	8d 85 e8 fd ff ff    	lea    -0x218(%ebp),%eax
  8024a5:	50                   	push   %eax
  8024a6:	ff b5 88 fd ff ff    	pushl  -0x278(%ebp)
  8024ac:	e8 7e fa ff ff       	call   801f2f <readn>
  8024b1:	83 c4 10             	add    $0x10,%esp
  8024b4:	3d 00 02 00 00       	cmp    $0x200,%eax
  8024b9:	75 0c                	jne    8024c7 <spawn+0x57>
	    || elf->e_magic != ELF_MAGIC) {
  8024bb:	81 bd e8 fd ff ff 7f 	cmpl   $0x464c457f,-0x218(%ebp)
  8024c2:	45 4c 46 
  8024c5:	74 38                	je     8024ff <spawn+0x8f>
		close(fd);
  8024c7:	83 ec 0c             	sub    $0xc,%esp
  8024ca:	ff b5 88 fd ff ff    	pushl  -0x278(%ebp)
  8024d0:	e8 96 f8 ff ff       	call   801d6b <close>
		cprintf("elf magic %08x want %08x\n", elf->e_magic, ELF_MAGIC);
  8024d5:	83 c4 0c             	add    $0xc,%esp
  8024d8:	68 7f 45 4c 46       	push   $0x464c457f
  8024dd:	ff b5 e8 fd ff ff    	pushl  -0x218(%ebp)
  8024e3:	68 56 3a 80 00       	push   $0x803a56
  8024e8:	e8 0f e6 ff ff       	call   800afc <cprintf>
		return -E_NOT_EXEC;
  8024ed:	83 c4 10             	add    $0x10,%esp
  8024f0:	c7 85 84 fd ff ff f2 	movl   $0xfffffff2,-0x27c(%ebp)
  8024f7:	ff ff ff 
  8024fa:	e9 72 04 00 00       	jmp    802971 <spawn+0x501>
  8024ff:	ba 07 00 00 00       	mov    $0x7,%edx
  802504:	89 d0                	mov    %edx,%eax
  802506:	cd 30                	int    $0x30
  802508:	89 85 74 fd ff ff    	mov    %eax,-0x28c(%ebp)
  80250e:	89 85 84 fd ff ff    	mov    %eax,-0x27c(%ebp)
	}


	// Create new child environment
	if ((r = sys_exofork()) < 0)
  802514:	85 c0                	test   %eax,%eax
  802516:	0f 88 55 04 00 00    	js     802971 <spawn+0x501>
	child = r;



	// Set up trap frame, including initial stack.
	child_tf = envs[ENVX(child)].env_tf;
  80251c:	25 ff 03 00 00       	and    $0x3ff,%eax
  802521:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  802528:	89 c6                	mov    %eax,%esi
  80252a:	c1 e6 07             	shl    $0x7,%esi
  80252d:	29 d6                	sub    %edx,%esi
  80252f:	81 c6 00 00 c0 ee    	add    $0xeec00000,%esi
  802535:	8d bd a4 fd ff ff    	lea    -0x25c(%ebp),%edi
  80253b:	b9 11 00 00 00       	mov    $0x11,%ecx
  802540:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	child_tf.tf_eip = elf->e_entry;
  802542:	8b 85 00 fe ff ff    	mov    -0x200(%ebp),%eax
  802548:	89 85 d4 fd ff ff    	mov    %eax,-0x22c(%ebp)
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  80254e:	8b 55 0c             	mov    0xc(%ebp),%edx
  802551:	8b 02                	mov    (%edx),%eax
  802553:	85 c0                	test   %eax,%eax
  802555:	74 39                	je     802590 <spawn+0x120>
	char *string_store;
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
  802557:	be 00 00 00 00       	mov    $0x0,%esi
	for (argc = 0; argv[argc] != 0; argc++)
  80255c:	bb 00 00 00 00       	mov    $0x0,%ebx
  802561:	89 d7                	mov    %edx,%edi
		string_size += strlen(argv[argc]) + 1;
  802563:	83 ec 0c             	sub    $0xc,%esp
  802566:	50                   	push   %eax
  802567:	e8 d8 eb ff ff       	call   801144 <strlen>
  80256c:	8d 74 30 01          	lea    0x1(%eax,%esi,1),%esi
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  802570:	43                   	inc    %ebx
  802571:	8d 0c 9d 00 00 00 00 	lea    0x0(,%ebx,4),%ecx
  802578:	8b 04 9f             	mov    (%edi,%ebx,4),%eax
  80257b:	83 c4 10             	add    $0x10,%esp
  80257e:	85 c0                	test   %eax,%eax
  802580:	75 e1                	jne    802563 <spawn+0xf3>
  802582:	89 9d 80 fd ff ff    	mov    %ebx,-0x280(%ebp)
  802588:	89 8d 7c fd ff ff    	mov    %ecx,-0x284(%ebp)
  80258e:	eb 1e                	jmp    8025ae <spawn+0x13e>
  802590:	c7 85 7c fd ff ff 00 	movl   $0x0,-0x284(%ebp)
  802597:	00 00 00 
  80259a:	c7 85 80 fd ff ff 00 	movl   $0x0,-0x280(%ebp)
  8025a1:	00 00 00 
	char *string_store;
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
  8025a4:	be 00 00 00 00       	mov    $0x0,%esi
	for (argc = 0; argv[argc] != 0; argc++)
  8025a9:	bb 00 00 00 00       	mov    $0x0,%ebx
	// Determine where to place the strings and the argv array.
	// Set up pointers into the temporary page 'UTEMP'; we'll map a page
	// there later, then remap that page into the child environment
	// at (USTACKTOP - PGSIZE).
	// strings is the topmost thing on the stack.
	string_store = (char*) UTEMP + PGSIZE - string_size;
  8025ae:	f7 de                	neg    %esi
  8025b0:	8d be 00 10 40 00    	lea    0x401000(%esi),%edi
	// argv is below that.  There's one argument pointer per argument, plus
	// a null pointer.
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));
  8025b6:	89 fa                	mov    %edi,%edx
  8025b8:	83 e2 fc             	and    $0xfffffffc,%edx
  8025bb:	89 d8                	mov    %ebx,%eax
  8025bd:	f7 d0                	not    %eax
  8025bf:	8d 04 82             	lea    (%edx,%eax,4),%eax
  8025c2:	89 85 94 fd ff ff    	mov    %eax,-0x26c(%ebp)

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
  8025c8:	83 e8 08             	sub    $0x8,%eax
  8025cb:	3d ff ff 3f 00       	cmp    $0x3fffff,%eax
  8025d0:	0f 86 a9 03 00 00    	jbe    80297f <spawn+0x50f>
		return -E_NO_MEM;

	// Allocate the single stack page at UTEMP.
	if ((r = sys_page_alloc(0, (void*) UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  8025d6:	83 ec 04             	sub    $0x4,%esp
  8025d9:	6a 07                	push   $0x7
  8025db:	68 00 00 40 00       	push   $0x400000
  8025e0:	6a 00                	push   $0x0
  8025e2:	e8 31 f0 ff ff       	call   801618 <sys_page_alloc>
  8025e7:	83 c4 10             	add    $0x10,%esp
  8025ea:	85 c0                	test   %eax,%eax
  8025ec:	0f 88 99 03 00 00    	js     80298b <spawn+0x51b>
	//	  (Again, argv should use an address valid in the child's
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
  8025f2:	85 db                	test   %ebx,%ebx
  8025f4:	7e 44                	jle    80263a <spawn+0x1ca>
  8025f6:	be 00 00 00 00       	mov    $0x0,%esi
  8025fb:	89 9d 8c fd ff ff    	mov    %ebx,-0x274(%ebp)
  802601:	8b 5d 0c             	mov    0xc(%ebp),%ebx
		argv_store[i] = UTEMP2USTACK(string_store);
  802604:	8d 87 00 d0 7f ee    	lea    -0x11803000(%edi),%eax
  80260a:	8b 95 94 fd ff ff    	mov    -0x26c(%ebp),%edx
  802610:	89 04 b2             	mov    %eax,(%edx,%esi,4)
		strcpy(string_store, argv[i]);
  802613:	83 ec 08             	sub    $0x8,%esp
  802616:	ff 34 b3             	pushl  (%ebx,%esi,4)
  802619:	57                   	push   %edi
  80261a:	e8 77 eb ff ff       	call   801196 <strcpy>
		string_store += strlen(argv[i]) + 1;
  80261f:	83 c4 04             	add    $0x4,%esp
  802622:	ff 34 b3             	pushl  (%ebx,%esi,4)
  802625:	e8 1a eb ff ff       	call   801144 <strlen>
  80262a:	8d 7c 07 01          	lea    0x1(%edi,%eax,1),%edi
	//	  (Again, argv should use an address valid in the child's
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
  80262e:	46                   	inc    %esi
  80262f:	83 c4 10             	add    $0x10,%esp
  802632:	3b b5 8c fd ff ff    	cmp    -0x274(%ebp),%esi
  802638:	7c ca                	jl     802604 <spawn+0x194>
		argv_store[i] = UTEMP2USTACK(string_store);
		strcpy(string_store, argv[i]);
		string_store += strlen(argv[i]) + 1;
	}
	argv_store[argc] = 0;
  80263a:	8b 95 94 fd ff ff    	mov    -0x26c(%ebp),%edx
  802640:	8b 85 7c fd ff ff    	mov    -0x284(%ebp),%eax
  802646:	c7 04 02 00 00 00 00 	movl   $0x0,(%edx,%eax,1)
	assert(string_store == (char*)UTEMP + PGSIZE);
  80264d:	81 ff 00 10 40 00    	cmp    $0x401000,%edi
  802653:	74 19                	je     80266e <spawn+0x1fe>
  802655:	68 cc 3a 80 00       	push   $0x803acc
  80265a:	68 f2 33 80 00       	push   $0x8033f2
  80265f:	68 f5 00 00 00       	push   $0xf5
  802664:	68 70 3a 80 00       	push   $0x803a70
  802669:	e8 b6 e3 ff ff       	call   800a24 <_panic>

	argv_store[-1] = UTEMP2USTACK(argv_store);
  80266e:	8b 85 94 fd ff ff    	mov    -0x26c(%ebp),%eax
  802674:	2d 00 30 80 11       	sub    $0x11803000,%eax
  802679:	8b 95 94 fd ff ff    	mov    -0x26c(%ebp),%edx
  80267f:	89 42 fc             	mov    %eax,-0x4(%edx)
	argv_store[-2] = argc;
  802682:	8b 85 80 fd ff ff    	mov    -0x280(%ebp),%eax
  802688:	89 42 f8             	mov    %eax,-0x8(%edx)

	*init_esp = UTEMP2USTACK(&argv_store[-2]);
  80268b:	89 d0                	mov    %edx,%eax
  80268d:	2d 08 30 80 11       	sub    $0x11803008,%eax
  802692:	89 85 e0 fd ff ff    	mov    %eax,-0x220(%ebp)

	// After completing the stack, map it into the child's address space
	// and unmap it from ours!
	if ((r = sys_page_map(0, UTEMP, child, (void*) (USTACKTOP - PGSIZE), PTE_P | PTE_U | PTE_W)) < 0)
  802698:	83 ec 0c             	sub    $0xc,%esp
  80269b:	6a 07                	push   $0x7
  80269d:	68 00 d0 bf ee       	push   $0xeebfd000
  8026a2:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  8026a8:	68 00 00 40 00       	push   $0x400000
  8026ad:	6a 00                	push   $0x0
  8026af:	e8 88 ef ff ff       	call   80163c <sys_page_map>
  8026b4:	89 c3                	mov    %eax,%ebx
  8026b6:	83 c4 20             	add    $0x20,%esp
  8026b9:	85 c0                	test   %eax,%eax
  8026bb:	78 18                	js     8026d5 <spawn+0x265>
		goto error;
	if ((r = sys_page_unmap(0, UTEMP)) < 0)
  8026bd:	83 ec 08             	sub    $0x8,%esp
  8026c0:	68 00 00 40 00       	push   $0x400000
  8026c5:	6a 00                	push   $0x0
  8026c7:	e8 96 ef ff ff       	call   801662 <sys_page_unmap>
  8026cc:	89 c3                	mov    %eax,%ebx
  8026ce:	83 c4 10             	add    $0x10,%esp
  8026d1:	85 c0                	test   %eax,%eax
  8026d3:	79 1d                	jns    8026f2 <spawn+0x282>
		goto error;

	return 0;

error:
	sys_page_unmap(0, UTEMP);
  8026d5:	83 ec 08             	sub    $0x8,%esp
  8026d8:	68 00 00 40 00       	push   $0x400000
  8026dd:	6a 00                	push   $0x0
  8026df:	e8 7e ef ff ff       	call   801662 <sys_page_unmap>
  8026e4:	83 c4 10             	add    $0x10,%esp
	return r;
  8026e7:	89 9d 84 fd ff ff    	mov    %ebx,-0x27c(%ebp)
  8026ed:	e9 7f 02 00 00       	jmp    802971 <spawn+0x501>
	if ((r = init_stack(child, argv, &child_tf.tf_esp)) < 0)
		return r;


	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
  8026f2:	8b 85 04 fe ff ff    	mov    -0x1fc(%ebp),%eax
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  8026f8:	66 83 bd 14 fe ff ff 	cmpw   $0x0,-0x1ec(%ebp)
  8026ff:	00 
  802700:	0f 84 c3 01 00 00    	je     8028c9 <spawn+0x459>
	if ((r = init_stack(child, argv, &child_tf.tf_esp)) < 0)
		return r;


	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
  802706:	8d 84 05 e8 fd ff ff 	lea    -0x218(%ebp,%eax,1),%eax
  80270d:	89 85 80 fd ff ff    	mov    %eax,-0x280(%ebp)
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  802713:	c7 85 7c fd ff ff 00 	movl   $0x0,-0x284(%ebp)
  80271a:	00 00 00 
		if (ph->p_type != ELF_PROG_LOAD)
  80271d:	8b 95 80 fd ff ff    	mov    -0x280(%ebp),%edx
  802723:	83 3a 01             	cmpl   $0x1,(%edx)
  802726:	0f 85 7c 01 00 00    	jne    8028a8 <spawn+0x438>
			continue;
		perm = PTE_P | PTE_U;
		if (ph->p_flags & ELF_PROG_FLAG_WRITE)
  80272c:	8b 42 18             	mov    0x18(%edx),%eax
  80272f:	83 e0 02             	and    $0x2,%eax
	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
	for (i = 0; i < elf->e_phnum; i++, ph++) {
		if (ph->p_type != ELF_PROG_LOAD)
			continue;
		perm = PTE_P | PTE_U;
  802732:	83 f8 01             	cmp    $0x1,%eax
  802735:	19 db                	sbb    %ebx,%ebx
  802737:	83 e3 fe             	and    $0xfffffffe,%ebx
  80273a:	83 c3 07             	add    $0x7,%ebx
		if (ph->p_flags & ELF_PROG_FLAG_WRITE)
			perm |= PTE_W;
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
  80273d:	8b 42 04             	mov    0x4(%edx),%eax
  802740:	89 85 78 fd ff ff    	mov    %eax,-0x288(%ebp)
  802746:	8b 52 10             	mov    0x10(%edx),%edx
  802749:	89 95 94 fd ff ff    	mov    %edx,-0x26c(%ebp)
  80274f:	8b 85 80 fd ff ff    	mov    -0x280(%ebp),%eax
  802755:	8b 40 14             	mov    0x14(%eax),%eax
  802758:	89 85 8c fd ff ff    	mov    %eax,-0x274(%ebp)
  80275e:	8b 95 80 fd ff ff    	mov    -0x280(%ebp),%edx
  802764:	8b 52 08             	mov    0x8(%edx),%edx
  802767:	89 95 90 fd ff ff    	mov    %edx,-0x270(%ebp)
	int i, r;
	void *blk;

	//cprintf("map_segment %x+%x\n", va, memsz);

	if ((i = PGOFF(va))) {
  80276d:	89 d0                	mov    %edx,%eax
  80276f:	25 ff 0f 00 00       	and    $0xfff,%eax
  802774:	74 1a                	je     802790 <spawn+0x320>
		va -= i;
  802776:	29 c2                	sub    %eax,%edx
  802778:	89 95 90 fd ff ff    	mov    %edx,-0x270(%ebp)
		memsz += i;
  80277e:	01 85 8c fd ff ff    	add    %eax,-0x274(%ebp)
		filesz += i;
  802784:	01 85 94 fd ff ff    	add    %eax,-0x26c(%ebp)
		fileoffset -= i;
  80278a:	29 85 78 fd ff ff    	sub    %eax,-0x288(%ebp)
	}

	for (i = 0; i < memsz; i += PGSIZE) {
  802790:	83 bd 8c fd ff ff 00 	cmpl   $0x0,-0x274(%ebp)
  802797:	0f 84 0b 01 00 00    	je     8028a8 <spawn+0x438>
  80279d:	bf 00 00 00 00       	mov    $0x0,%edi
  8027a2:	be 00 00 00 00       	mov    $0x0,%esi
		if (i >= filesz) {
  8027a7:	3b bd 94 fd ff ff    	cmp    -0x26c(%ebp),%edi
  8027ad:	72 28                	jb     8027d7 <spawn+0x367>
			// allocate a blank page
			if ((r = sys_page_alloc(child, (void*) (va + i), perm)) < 0)
  8027af:	83 ec 04             	sub    $0x4,%esp
  8027b2:	53                   	push   %ebx
  8027b3:	03 bd 90 fd ff ff    	add    -0x270(%ebp),%edi
  8027b9:	57                   	push   %edi
  8027ba:	ff b5 84 fd ff ff    	pushl  -0x27c(%ebp)
  8027c0:	e8 53 ee ff ff       	call   801618 <sys_page_alloc>
  8027c5:	83 c4 10             	add    $0x10,%esp
  8027c8:	85 c0                	test   %eax,%eax
  8027ca:	0f 89 c4 00 00 00    	jns    802894 <spawn+0x424>
  8027d0:	89 c3                	mov    %eax,%ebx
  8027d2:	e9 67 01 00 00       	jmp    80293e <spawn+0x4ce>
				return r;
		} else {
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  8027d7:	83 ec 04             	sub    $0x4,%esp
  8027da:	6a 07                	push   $0x7
  8027dc:	68 00 00 40 00       	push   $0x400000
  8027e1:	6a 00                	push   $0x0
  8027e3:	e8 30 ee ff ff       	call   801618 <sys_page_alloc>
  8027e8:	83 c4 10             	add    $0x10,%esp
  8027eb:	85 c0                	test   %eax,%eax
  8027ed:	0f 88 41 01 00 00    	js     802934 <spawn+0x4c4>
				return r;
			if ((r = seek(fd, fileoffset + i)) < 0)
  8027f3:	83 ec 08             	sub    $0x8,%esp
// prog: the pathname of the program to run.
// argv: pointer to null-terminated array of pointers to strings,
// 	 which will be passed to the child as its command-line arguments.
// Returns child envid on success, < 0 on failure.
int
spawn(const char *prog, const char **argv)
  8027f6:	8b 85 78 fd ff ff    	mov    -0x288(%ebp),%eax
  8027fc:	8d 04 06             	lea    (%esi,%eax,1),%eax
				return r;
		} else {
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
				return r;
			if ((r = seek(fd, fileoffset + i)) < 0)
  8027ff:	50                   	push   %eax
  802800:	ff b5 88 fd ff ff    	pushl  -0x278(%ebp)
  802806:	e8 fb f7 ff ff       	call   802006 <seek>
  80280b:	83 c4 10             	add    $0x10,%esp
  80280e:	85 c0                	test   %eax,%eax
  802810:	0f 88 22 01 00 00    	js     802938 <spawn+0x4c8>
				return r;
			if ((r = readn(fd, UTEMP, MIN(PGSIZE, filesz-i))) < 0)
  802816:	83 ec 04             	sub    $0x4,%esp
  802819:	8b 85 94 fd ff ff    	mov    -0x26c(%ebp),%eax
  80281f:	29 f8                	sub    %edi,%eax
  802821:	3d 00 10 00 00       	cmp    $0x1000,%eax
  802826:	76 05                	jbe    80282d <spawn+0x3bd>
  802828:	b8 00 10 00 00       	mov    $0x1000,%eax
  80282d:	50                   	push   %eax
  80282e:	68 00 00 40 00       	push   $0x400000
  802833:	ff b5 88 fd ff ff    	pushl  -0x278(%ebp)
  802839:	e8 f1 f6 ff ff       	call   801f2f <readn>
  80283e:	83 c4 10             	add    $0x10,%esp
  802841:	85 c0                	test   %eax,%eax
  802843:	0f 88 f3 00 00 00    	js     80293c <spawn+0x4cc>
				return r;
			if ((r = sys_page_map(0, UTEMP, child, (void*) (va + i), perm)) < 0)
  802849:	83 ec 0c             	sub    $0xc,%esp
  80284c:	53                   	push   %ebx
  80284d:	03 bd 90 fd ff ff    	add    -0x270(%ebp),%edi
  802853:	57                   	push   %edi
  802854:	ff b5 84 fd ff ff    	pushl  -0x27c(%ebp)
  80285a:	68 00 00 40 00       	push   $0x400000
  80285f:	6a 00                	push   $0x0
  802861:	e8 d6 ed ff ff       	call   80163c <sys_page_map>
  802866:	83 c4 20             	add    $0x20,%esp
  802869:	85 c0                	test   %eax,%eax
  80286b:	79 15                	jns    802882 <spawn+0x412>
				panic("spawn: sys_page_map data: %e", r);
  80286d:	50                   	push   %eax
  80286e:	68 7c 3a 80 00       	push   $0x803a7c
  802873:	68 28 01 00 00       	push   $0x128
  802878:	68 70 3a 80 00       	push   $0x803a70
  80287d:	e8 a2 e1 ff ff       	call   800a24 <_panic>
			sys_page_unmap(0, UTEMP);
  802882:	83 ec 08             	sub    $0x8,%esp
  802885:	68 00 00 40 00       	push   $0x400000
  80288a:	6a 00                	push   $0x0
  80288c:	e8 d1 ed ff ff       	call   801662 <sys_page_unmap>
  802891:	83 c4 10             	add    $0x10,%esp
		memsz += i;
		filesz += i;
		fileoffset -= i;
	}

	for (i = 0; i < memsz; i += PGSIZE) {
  802894:	81 c6 00 10 00 00    	add    $0x1000,%esi
  80289a:	89 f7                	mov    %esi,%edi
  80289c:	3b b5 8c fd ff ff    	cmp    -0x274(%ebp),%esi
  8028a2:	0f 82 ff fe ff ff    	jb     8027a7 <spawn+0x337>
		return r;


	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  8028a8:	ff 85 7c fd ff ff    	incl   -0x284(%ebp)
  8028ae:	0f b7 85 14 fe ff ff 	movzwl -0x1ec(%ebp),%eax
  8028b5:	3b 85 7c fd ff ff    	cmp    -0x284(%ebp),%eax
  8028bb:	7e 0c                	jle    8028c9 <spawn+0x459>
  8028bd:	83 85 80 fd ff ff 20 	addl   $0x20,-0x280(%ebp)
  8028c4:	e9 54 fe ff ff       	jmp    80271d <spawn+0x2ad>
			perm |= PTE_W;
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
				     fd, ph->p_filesz, ph->p_offset, perm)) < 0)
			goto error;
	}
	close(fd);
  8028c9:	83 ec 0c             	sub    $0xc,%esp
  8028cc:	ff b5 88 fd ff ff    	pushl  -0x278(%ebp)
  8028d2:	e8 94 f4 ff ff       	call   801d6b <close>

	// Copy shared library state.
	if ((r = copy_shared_pages(child)) < 0)
		panic("copy_shared_pages: %e", r);

	if ((r = sys_env_set_trapframe(child, &child_tf)) < 0)
  8028d7:	83 c4 08             	add    $0x8,%esp
  8028da:	8d 85 a4 fd ff ff    	lea    -0x25c(%ebp),%eax
  8028e0:	50                   	push   %eax
  8028e1:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  8028e7:	e8 bc ed ff ff       	call   8016a8 <sys_env_set_trapframe>
  8028ec:	83 c4 10             	add    $0x10,%esp
  8028ef:	85 c0                	test   %eax,%eax
  8028f1:	79 15                	jns    802908 <spawn+0x498>
		panic("sys_env_set_trapframe: %e", r);
  8028f3:	50                   	push   %eax
  8028f4:	68 99 3a 80 00       	push   $0x803a99
  8028f9:	68 89 00 00 00       	push   $0x89
  8028fe:	68 70 3a 80 00       	push   $0x803a70
  802903:	e8 1c e1 ff ff       	call   800a24 <_panic>

	if ((r = sys_env_set_status(child, ENV_RUNNABLE)) < 0)
  802908:	83 ec 08             	sub    $0x8,%esp
  80290b:	6a 02                	push   $0x2
  80290d:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  802913:	e8 6d ed ff ff       	call   801685 <sys_env_set_status>
  802918:	83 c4 10             	add    $0x10,%esp
  80291b:	85 c0                	test   %eax,%eax
  80291d:	79 52                	jns    802971 <spawn+0x501>
		panic("sys_env_set_status: %e", r);
  80291f:	50                   	push   %eax
  802920:	68 b3 3a 80 00       	push   $0x803ab3
  802925:	68 8c 00 00 00       	push   $0x8c
  80292a:	68 70 3a 80 00       	push   $0x803a70
  80292f:	e8 f0 e0 ff ff       	call   800a24 <_panic>
  802934:	89 c3                	mov    %eax,%ebx
  802936:	eb 06                	jmp    80293e <spawn+0x4ce>
  802938:	89 c3                	mov    %eax,%ebx
  80293a:	eb 02                	jmp    80293e <spawn+0x4ce>
  80293c:	89 c3                	mov    %eax,%ebx

	return child;

error:
	sys_env_destroy(child);
  80293e:	83 ec 0c             	sub    $0xc,%esp
  802941:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  802947:	e8 5f ec ff ff       	call   8015ab <sys_env_destroy>
	close(fd);
  80294c:	83 c4 04             	add    $0x4,%esp
  80294f:	ff b5 88 fd ff ff    	pushl  -0x278(%ebp)
  802955:	e8 11 f4 ff ff       	call   801d6b <close>
	return r;
  80295a:	83 c4 10             	add    $0x10,%esp
  80295d:	89 9d 84 fd ff ff    	mov    %ebx,-0x27c(%ebp)
  802963:	eb 0c                	jmp    802971 <spawn+0x501>
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
		return r;
  802965:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  80296b:	89 85 84 fd ff ff    	mov    %eax,-0x27c(%ebp)

error:
	sys_env_destroy(child);
	close(fd);
	return r;
}
  802971:	8b 85 84 fd ff ff    	mov    -0x27c(%ebp),%eax
  802977:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80297a:	5b                   	pop    %ebx
  80297b:	5e                   	pop    %esi
  80297c:	5f                   	pop    %edi
  80297d:	c9                   	leave  
  80297e:	c3                   	ret    
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
		return -E_NO_MEM;
  80297f:	c7 85 84 fd ff ff fc 	movl   $0xfffffffc,-0x27c(%ebp)
  802986:	ff ff ff 
  802989:	eb e6                	jmp    802971 <spawn+0x501>

	// Allocate the single stack page at UTEMP.
	if ((r = sys_page_alloc(0, (void*) UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
		return r;
  80298b:	89 85 84 fd ff ff    	mov    %eax,-0x27c(%ebp)
  802991:	eb de                	jmp    802971 <spawn+0x501>

00802993 <spawnl>:
// Spawn, taking command-line arguments array directly on the stack.
// NOTE: Must have a sentinal of NULL at the end of the args
// (none of the args may be NULL).
int
spawnl(const char *prog, const char *arg0, ...)
{
  802993:	55                   	push   %ebp
  802994:	89 e5                	mov    %esp,%ebp
  802996:	56                   	push   %esi
  802997:	53                   	push   %ebx
  802998:	8b 75 0c             	mov    0xc(%ebp),%esi
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  80299b:	8d 45 14             	lea    0x14(%ebp),%eax
  80299e:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8029a2:	74 5f                	je     802a03 <spawnl+0x70>
{
	// We calculate argc by advancing the args until we hit NULL.
	// The contract of the function guarantees that the last
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
  8029a4:	b9 00 00 00 00       	mov    $0x0,%ecx
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
		argc++;
  8029a9:	41                   	inc    %ecx
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  8029aa:	89 c2                	mov    %eax,%edx
  8029ac:	83 c0 04             	add    $0x4,%eax
  8029af:	83 3a 00             	cmpl   $0x0,(%edx)
  8029b2:	75 f5                	jne    8029a9 <spawnl+0x16>
		argc++;
	va_end(vl);

	// Now that we have the size of the args, do a second pass
	// and store the values in a VLA, which has the format of argv
	const char *argv[argc+2];
  8029b4:	8d 04 8d 26 00 00 00 	lea    0x26(,%ecx,4),%eax
  8029bb:	83 e0 f0             	and    $0xfffffff0,%eax
  8029be:	29 c4                	sub    %eax,%esp
  8029c0:	8d 44 24 0f          	lea    0xf(%esp),%eax
  8029c4:	83 e0 f0             	and    $0xfffffff0,%eax
  8029c7:	89 c3                	mov    %eax,%ebx
	argv[0] = arg0;
  8029c9:	89 30                	mov    %esi,(%eax)
	argv[argc+1] = NULL;
  8029cb:	c7 44 88 04 00 00 00 	movl   $0x0,0x4(%eax,%ecx,4)
  8029d2:	00 

	va_start(vl, arg0);
  8029d3:	8d 55 10             	lea    0x10(%ebp),%edx
	unsigned i;
	for(i=0;i<argc;i++)
  8029d6:	89 ce                	mov    %ecx,%esi
  8029d8:	85 c9                	test   %ecx,%ecx
  8029da:	74 14                	je     8029f0 <spawnl+0x5d>
  8029dc:	b8 00 00 00 00       	mov    $0x0,%eax
		argv[i+1] = va_arg(vl, const char *);
  8029e1:	40                   	inc    %eax
  8029e2:	89 d1                	mov    %edx,%ecx
  8029e4:	83 c2 04             	add    $0x4,%edx
  8029e7:	8b 09                	mov    (%ecx),%ecx
  8029e9:	89 0c 83             	mov    %ecx,(%ebx,%eax,4)
	argv[0] = arg0;
	argv[argc+1] = NULL;

	va_start(vl, arg0);
	unsigned i;
	for(i=0;i<argc;i++)
  8029ec:	39 f0                	cmp    %esi,%eax
  8029ee:	72 f1                	jb     8029e1 <spawnl+0x4e>
		argv[i+1] = va_arg(vl, const char *);
	va_end(vl);
	return spawn(prog, argv);
  8029f0:	83 ec 08             	sub    $0x8,%esp
  8029f3:	53                   	push   %ebx
  8029f4:	ff 75 08             	pushl  0x8(%ebp)
  8029f7:	e8 74 fa ff ff       	call   802470 <spawn>
}
  8029fc:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8029ff:	5b                   	pop    %ebx
  802a00:	5e                   	pop    %esi
  802a01:	c9                   	leave  
  802a02:	c3                   	ret    
		argc++;
	va_end(vl);

	// Now that we have the size of the args, do a second pass
	// and store the values in a VLA, which has the format of argv
	const char *argv[argc+2];
  802a03:	83 ec 20             	sub    $0x20,%esp
  802a06:	8d 44 24 0f          	lea    0xf(%esp),%eax
  802a0a:	83 e0 f0             	and    $0xfffffff0,%eax
  802a0d:	89 c3                	mov    %eax,%ebx
	argv[0] = arg0;
  802a0f:	89 30                	mov    %esi,(%eax)
	argv[argc+1] = NULL;
  802a11:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
  802a18:	eb d6                	jmp    8029f0 <spawnl+0x5d>
	...

00802a1c <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  802a1c:	55                   	push   %ebp
  802a1d:	89 e5                	mov    %esp,%ebp
  802a1f:	56                   	push   %esi
  802a20:	53                   	push   %ebx
  802a21:	8b 75 0c             	mov    0xc(%ebp),%esi
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  802a24:	83 ec 0c             	sub    $0xc,%esp
  802a27:	ff 75 08             	pushl  0x8(%ebp)
  802a2a:	e8 6d f1 ff ff       	call   801b9c <fd2data>
  802a2f:	89 c3                	mov    %eax,%ebx
	strcpy(stat->st_name, "<pipe>");
  802a31:	83 c4 08             	add    $0x8,%esp
  802a34:	68 f2 3a 80 00       	push   $0x803af2
  802a39:	56                   	push   %esi
  802a3a:	e8 57 e7 ff ff       	call   801196 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  802a3f:	8b 43 04             	mov    0x4(%ebx),%eax
  802a42:	2b 03                	sub    (%ebx),%eax
  802a44:	89 86 80 00 00 00    	mov    %eax,0x80(%esi)
	stat->st_isdir = 0;
  802a4a:	c7 86 84 00 00 00 00 	movl   $0x0,0x84(%esi)
  802a51:	00 00 00 
	stat->st_dev = &devpipe;
  802a54:	c7 86 88 00 00 00 3c 	movl   $0x80403c,0x88(%esi)
  802a5b:	40 80 00 
	return 0;
}
  802a5e:	b8 00 00 00 00       	mov    $0x0,%eax
  802a63:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802a66:	5b                   	pop    %ebx
  802a67:	5e                   	pop    %esi
  802a68:	c9                   	leave  
  802a69:	c3                   	ret    

00802a6a <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  802a6a:	55                   	push   %ebp
  802a6b:	89 e5                	mov    %esp,%ebp
  802a6d:	53                   	push   %ebx
  802a6e:	83 ec 0c             	sub    $0xc,%esp
  802a71:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  802a74:	53                   	push   %ebx
  802a75:	6a 00                	push   $0x0
  802a77:	e8 e6 eb ff ff       	call   801662 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  802a7c:	89 1c 24             	mov    %ebx,(%esp)
  802a7f:	e8 18 f1 ff ff       	call   801b9c <fd2data>
  802a84:	83 c4 08             	add    $0x8,%esp
  802a87:	50                   	push   %eax
  802a88:	6a 00                	push   $0x0
  802a8a:	e8 d3 eb ff ff       	call   801662 <sys_page_unmap>
}
  802a8f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802a92:	c9                   	leave  
  802a93:	c3                   	ret    

00802a94 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  802a94:	55                   	push   %ebp
  802a95:	89 e5                	mov    %esp,%ebp
  802a97:	57                   	push   %edi
  802a98:	56                   	push   %esi
  802a99:	53                   	push   %ebx
  802a9a:	83 ec 1c             	sub    $0x1c,%esp
  802a9d:	89 c7                	mov    %eax,%edi
  802a9f:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  802aa2:	a1 24 54 80 00       	mov    0x805424,%eax
  802aa7:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  802aaa:	83 ec 0c             	sub    $0xc,%esp
  802aad:	57                   	push   %edi
  802aae:	e8 51 05 00 00       	call   803004 <pageref>
  802ab3:	89 c6                	mov    %eax,%esi
  802ab5:	83 c4 04             	add    $0x4,%esp
  802ab8:	ff 75 e4             	pushl  -0x1c(%ebp)
  802abb:	e8 44 05 00 00       	call   803004 <pageref>
  802ac0:	83 c4 10             	add    $0x10,%esp
  802ac3:	39 c6                	cmp    %eax,%esi
  802ac5:	0f 94 c0             	sete   %al
  802ac8:	0f b6 c0             	movzbl %al,%eax
		nn = thisenv->env_runs;
  802acb:	8b 15 24 54 80 00    	mov    0x805424,%edx
  802ad1:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  802ad4:	39 cb                	cmp    %ecx,%ebx
  802ad6:	75 08                	jne    802ae0 <_pipeisclosed+0x4c>
			return ret;
		if (n != nn && ret == 1)
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
	}
}
  802ad8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802adb:	5b                   	pop    %ebx
  802adc:	5e                   	pop    %esi
  802add:	5f                   	pop    %edi
  802ade:	c9                   	leave  
  802adf:	c3                   	ret    
		n = thisenv->env_runs;
		ret = pageref(fd) == pageref(p);
		nn = thisenv->env_runs;
		if (n == nn)
			return ret;
		if (n != nn && ret == 1)
  802ae0:	83 f8 01             	cmp    $0x1,%eax
  802ae3:	75 bd                	jne    802aa2 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  802ae5:	8b 42 58             	mov    0x58(%edx),%eax
  802ae8:	6a 01                	push   $0x1
  802aea:	50                   	push   %eax
  802aeb:	53                   	push   %ebx
  802aec:	68 f9 3a 80 00       	push   $0x803af9
  802af1:	e8 06 e0 ff ff       	call   800afc <cprintf>
  802af6:	83 c4 10             	add    $0x10,%esp
  802af9:	eb a7                	jmp    802aa2 <_pipeisclosed+0xe>

00802afb <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  802afb:	55                   	push   %ebp
  802afc:	89 e5                	mov    %esp,%ebp
  802afe:	57                   	push   %edi
  802aff:	56                   	push   %esi
  802b00:	53                   	push   %ebx
  802b01:	83 ec 28             	sub    $0x28,%esp
  802b04:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  802b07:	56                   	push   %esi
  802b08:	e8 8f f0 ff ff       	call   801b9c <fd2data>
  802b0d:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802b0f:	83 c4 10             	add    $0x10,%esp
  802b12:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  802b16:	75 4a                	jne    802b62 <devpipe_write+0x67>
  802b18:	bf 00 00 00 00       	mov    $0x0,%edi
  802b1d:	eb 56                	jmp    802b75 <devpipe_write+0x7a>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  802b1f:	89 da                	mov    %ebx,%edx
  802b21:	89 f0                	mov    %esi,%eax
  802b23:	e8 6c ff ff ff       	call   802a94 <_pipeisclosed>
  802b28:	85 c0                	test   %eax,%eax
  802b2a:	75 4d                	jne    802b79 <devpipe_write+0x7e>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  802b2c:	e8 c0 ea ff ff       	call   8015f1 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  802b31:	8b 43 04             	mov    0x4(%ebx),%eax
  802b34:	8b 13                	mov    (%ebx),%edx
  802b36:	83 c2 20             	add    $0x20,%edx
  802b39:	39 d0                	cmp    %edx,%eax
  802b3b:	73 e2                	jae    802b1f <devpipe_write+0x24>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  802b3d:	89 c2                	mov    %eax,%edx
  802b3f:	81 e2 1f 00 00 80    	and    $0x8000001f,%edx
  802b45:	79 05                	jns    802b4c <devpipe_write+0x51>
  802b47:	4a                   	dec    %edx
  802b48:	83 ca e0             	or     $0xffffffe0,%edx
  802b4b:	42                   	inc    %edx
  802b4c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802b4f:	8a 0c 39             	mov    (%ecx,%edi,1),%cl
  802b52:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  802b56:	40                   	inc    %eax
  802b57:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802b5a:	47                   	inc    %edi
  802b5b:	39 7d 10             	cmp    %edi,0x10(%ebp)
  802b5e:	77 07                	ja     802b67 <devpipe_write+0x6c>
  802b60:	eb 13                	jmp    802b75 <devpipe_write+0x7a>
  802b62:	bf 00 00 00 00       	mov    $0x0,%edi
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  802b67:	8b 43 04             	mov    0x4(%ebx),%eax
  802b6a:	8b 13                	mov    (%ebx),%edx
  802b6c:	83 c2 20             	add    $0x20,%edx
  802b6f:	39 d0                	cmp    %edx,%eax
  802b71:	73 ac                	jae    802b1f <devpipe_write+0x24>
  802b73:	eb c8                	jmp    802b3d <devpipe_write+0x42>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  802b75:	89 f8                	mov    %edi,%eax
  802b77:	eb 05                	jmp    802b7e <devpipe_write+0x83>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  802b79:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  802b7e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802b81:	5b                   	pop    %ebx
  802b82:	5e                   	pop    %esi
  802b83:	5f                   	pop    %edi
  802b84:	c9                   	leave  
  802b85:	c3                   	ret    

00802b86 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  802b86:	55                   	push   %ebp
  802b87:	89 e5                	mov    %esp,%ebp
  802b89:	57                   	push   %edi
  802b8a:	56                   	push   %esi
  802b8b:	53                   	push   %ebx
  802b8c:	83 ec 18             	sub    $0x18,%esp
  802b8f:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  802b92:	57                   	push   %edi
  802b93:	e8 04 f0 ff ff       	call   801b9c <fd2data>
  802b98:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802b9a:	83 c4 10             	add    $0x10,%esp
  802b9d:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  802ba1:	75 44                	jne    802be7 <devpipe_read+0x61>
  802ba3:	be 00 00 00 00       	mov    $0x0,%esi
  802ba8:	eb 4f                	jmp    802bf9 <devpipe_read+0x73>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
				return i;
  802baa:	89 f0                	mov    %esi,%eax
  802bac:	eb 54                	jmp    802c02 <devpipe_read+0x7c>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  802bae:	89 da                	mov    %ebx,%edx
  802bb0:	89 f8                	mov    %edi,%eax
  802bb2:	e8 dd fe ff ff       	call   802a94 <_pipeisclosed>
  802bb7:	85 c0                	test   %eax,%eax
  802bb9:	75 42                	jne    802bfd <devpipe_read+0x77>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  802bbb:	e8 31 ea ff ff       	call   8015f1 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  802bc0:	8b 03                	mov    (%ebx),%eax
  802bc2:	3b 43 04             	cmp    0x4(%ebx),%eax
  802bc5:	74 e7                	je     802bae <devpipe_read+0x28>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  802bc7:	25 1f 00 00 80       	and    $0x8000001f,%eax
  802bcc:	79 05                	jns    802bd3 <devpipe_read+0x4d>
  802bce:	48                   	dec    %eax
  802bcf:	83 c8 e0             	or     $0xffffffe0,%eax
  802bd2:	40                   	inc    %eax
  802bd3:	8a 44 03 08          	mov    0x8(%ebx,%eax,1),%al
  802bd7:	8b 55 0c             	mov    0xc(%ebp),%edx
  802bda:	88 04 32             	mov    %al,(%edx,%esi,1)
		p->p_rpos++;
  802bdd:	ff 03                	incl   (%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802bdf:	46                   	inc    %esi
  802be0:	39 75 10             	cmp    %esi,0x10(%ebp)
  802be3:	77 07                	ja     802bec <devpipe_read+0x66>
  802be5:	eb 12                	jmp    802bf9 <devpipe_read+0x73>
  802be7:	be 00 00 00 00       	mov    $0x0,%esi
		while (p->p_rpos == p->p_wpos) {
  802bec:	8b 03                	mov    (%ebx),%eax
  802bee:	3b 43 04             	cmp    0x4(%ebx),%eax
  802bf1:	75 d4                	jne    802bc7 <devpipe_read+0x41>
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  802bf3:	85 f6                	test   %esi,%esi
  802bf5:	75 b3                	jne    802baa <devpipe_read+0x24>
  802bf7:	eb b5                	jmp    802bae <devpipe_read+0x28>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  802bf9:	89 f0                	mov    %esi,%eax
  802bfb:	eb 05                	jmp    802c02 <devpipe_read+0x7c>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  802bfd:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  802c02:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802c05:	5b                   	pop    %ebx
  802c06:	5e                   	pop    %esi
  802c07:	5f                   	pop    %edi
  802c08:	c9                   	leave  
  802c09:	c3                   	ret    

00802c0a <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  802c0a:	55                   	push   %ebp
  802c0b:	89 e5                	mov    %esp,%ebp
  802c0d:	57                   	push   %edi
  802c0e:	56                   	push   %esi
  802c0f:	53                   	push   %ebx
  802c10:	83 ec 28             	sub    $0x28,%esp
  802c13:	8b 7d 08             	mov    0x8(%ebp),%edi
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  802c16:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  802c19:	50                   	push   %eax
  802c1a:	e8 95 ef ff ff       	call   801bb4 <fd_alloc>
  802c1f:	89 c3                	mov    %eax,%ebx
  802c21:	83 c4 10             	add    $0x10,%esp
  802c24:	85 c0                	test   %eax,%eax
  802c26:	0f 88 24 01 00 00    	js     802d50 <pipe+0x146>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802c2c:	83 ec 04             	sub    $0x4,%esp
  802c2f:	68 07 04 00 00       	push   $0x407
  802c34:	ff 75 e4             	pushl  -0x1c(%ebp)
  802c37:	6a 00                	push   $0x0
  802c39:	e8 da e9 ff ff       	call   801618 <sys_page_alloc>
  802c3e:	89 c3                	mov    %eax,%ebx
  802c40:	83 c4 10             	add    $0x10,%esp
  802c43:	85 c0                	test   %eax,%eax
  802c45:	0f 88 05 01 00 00    	js     802d50 <pipe+0x146>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  802c4b:	83 ec 0c             	sub    $0xc,%esp
  802c4e:	8d 45 e0             	lea    -0x20(%ebp),%eax
  802c51:	50                   	push   %eax
  802c52:	e8 5d ef ff ff       	call   801bb4 <fd_alloc>
  802c57:	89 c3                	mov    %eax,%ebx
  802c59:	83 c4 10             	add    $0x10,%esp
  802c5c:	85 c0                	test   %eax,%eax
  802c5e:	0f 88 dc 00 00 00    	js     802d40 <pipe+0x136>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802c64:	83 ec 04             	sub    $0x4,%esp
  802c67:	68 07 04 00 00       	push   $0x407
  802c6c:	ff 75 e0             	pushl  -0x20(%ebp)
  802c6f:	6a 00                	push   $0x0
  802c71:	e8 a2 e9 ff ff       	call   801618 <sys_page_alloc>
  802c76:	89 c3                	mov    %eax,%ebx
  802c78:	83 c4 10             	add    $0x10,%esp
  802c7b:	85 c0                	test   %eax,%eax
  802c7d:	0f 88 bd 00 00 00    	js     802d40 <pipe+0x136>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  802c83:	83 ec 0c             	sub    $0xc,%esp
  802c86:	ff 75 e4             	pushl  -0x1c(%ebp)
  802c89:	e8 0e ef ff ff       	call   801b9c <fd2data>
  802c8e:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802c90:	83 c4 0c             	add    $0xc,%esp
  802c93:	68 07 04 00 00       	push   $0x407
  802c98:	50                   	push   %eax
  802c99:	6a 00                	push   $0x0
  802c9b:	e8 78 e9 ff ff       	call   801618 <sys_page_alloc>
  802ca0:	89 c3                	mov    %eax,%ebx
  802ca2:	83 c4 10             	add    $0x10,%esp
  802ca5:	85 c0                	test   %eax,%eax
  802ca7:	0f 88 83 00 00 00    	js     802d30 <pipe+0x126>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802cad:	83 ec 0c             	sub    $0xc,%esp
  802cb0:	ff 75 e0             	pushl  -0x20(%ebp)
  802cb3:	e8 e4 ee ff ff       	call   801b9c <fd2data>
  802cb8:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  802cbf:	50                   	push   %eax
  802cc0:	6a 00                	push   $0x0
  802cc2:	56                   	push   %esi
  802cc3:	6a 00                	push   $0x0
  802cc5:	e8 72 e9 ff ff       	call   80163c <sys_page_map>
  802cca:	89 c3                	mov    %eax,%ebx
  802ccc:	83 c4 20             	add    $0x20,%esp
  802ccf:	85 c0                	test   %eax,%eax
  802cd1:	78 4f                	js     802d22 <pipe+0x118>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  802cd3:	8b 15 3c 40 80 00    	mov    0x80403c,%edx
  802cd9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802cdc:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  802cde:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802ce1:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  802ce8:	8b 15 3c 40 80 00    	mov    0x80403c,%edx
  802cee:	8b 45 e0             	mov    -0x20(%ebp),%eax
  802cf1:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  802cf3:	8b 45 e0             	mov    -0x20(%ebp),%eax
  802cf6:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  802cfd:	83 ec 0c             	sub    $0xc,%esp
  802d00:	ff 75 e4             	pushl  -0x1c(%ebp)
  802d03:	e8 84 ee ff ff       	call   801b8c <fd2num>
  802d08:	89 07                	mov    %eax,(%edi)
	pfd[1] = fd2num(fd1);
  802d0a:	83 c4 04             	add    $0x4,%esp
  802d0d:	ff 75 e0             	pushl  -0x20(%ebp)
  802d10:	e8 77 ee ff ff       	call   801b8c <fd2num>
  802d15:	89 47 04             	mov    %eax,0x4(%edi)
	return 0;
  802d18:	83 c4 10             	add    $0x10,%esp
  802d1b:	bb 00 00 00 00       	mov    $0x0,%ebx
  802d20:	eb 2e                	jmp    802d50 <pipe+0x146>

    err3:
	sys_page_unmap(0, va);
  802d22:	83 ec 08             	sub    $0x8,%esp
  802d25:	56                   	push   %esi
  802d26:	6a 00                	push   $0x0
  802d28:	e8 35 e9 ff ff       	call   801662 <sys_page_unmap>
  802d2d:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  802d30:	83 ec 08             	sub    $0x8,%esp
  802d33:	ff 75 e0             	pushl  -0x20(%ebp)
  802d36:	6a 00                	push   $0x0
  802d38:	e8 25 e9 ff ff       	call   801662 <sys_page_unmap>
  802d3d:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  802d40:	83 ec 08             	sub    $0x8,%esp
  802d43:	ff 75 e4             	pushl  -0x1c(%ebp)
  802d46:	6a 00                	push   $0x0
  802d48:	e8 15 e9 ff ff       	call   801662 <sys_page_unmap>
  802d4d:	83 c4 10             	add    $0x10,%esp
    err:
	return r;
}
  802d50:	89 d8                	mov    %ebx,%eax
  802d52:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802d55:	5b                   	pop    %ebx
  802d56:	5e                   	pop    %esi
  802d57:	5f                   	pop    %edi
  802d58:	c9                   	leave  
  802d59:	c3                   	ret    

00802d5a <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  802d5a:	55                   	push   %ebp
  802d5b:	89 e5                	mov    %esp,%ebp
  802d5d:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802d60:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802d63:	50                   	push   %eax
  802d64:	ff 75 08             	pushl  0x8(%ebp)
  802d67:	e8 bb ee ff ff       	call   801c27 <fd_lookup>
  802d6c:	83 c4 10             	add    $0x10,%esp
  802d6f:	85 c0                	test   %eax,%eax
  802d71:	78 18                	js     802d8b <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  802d73:	83 ec 0c             	sub    $0xc,%esp
  802d76:	ff 75 f4             	pushl  -0xc(%ebp)
  802d79:	e8 1e ee ff ff       	call   801b9c <fd2data>
	return _pipeisclosed(fd, p);
  802d7e:	89 c2                	mov    %eax,%edx
  802d80:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802d83:	e8 0c fd ff ff       	call   802a94 <_pipeisclosed>
  802d88:	83 c4 10             	add    $0x10,%esp
}
  802d8b:	c9                   	leave  
  802d8c:	c3                   	ret    
  802d8d:	00 00                	add    %al,(%eax)
	...

00802d90 <wait>:
#include <inc/lib.h>

// Waits until 'envid' exits.
void
wait(envid_t envid)
{
  802d90:	55                   	push   %ebp
  802d91:	89 e5                	mov    %esp,%ebp
  802d93:	57                   	push   %edi
  802d94:	56                   	push   %esi
  802d95:	53                   	push   %ebx
  802d96:	83 ec 0c             	sub    $0xc,%esp
  802d99:	8b 45 08             	mov    0x8(%ebp),%eax
	const volatile struct Env *e;

	assert(envid != 0);
  802d9c:	85 c0                	test   %eax,%eax
  802d9e:	75 16                	jne    802db6 <wait+0x26>
  802da0:	68 11 3b 80 00       	push   $0x803b11
  802da5:	68 f2 33 80 00       	push   $0x8033f2
  802daa:	6a 09                	push   $0x9
  802dac:	68 1c 3b 80 00       	push   $0x803b1c
  802db1:	e8 6e dc ff ff       	call   800a24 <_panic>
	e = &envs[ENVX(envid)];
  802db6:	89 c6                	mov    %eax,%esi
  802db8:	81 e6 ff 03 00 00    	and    $0x3ff,%esi
	while (e->env_id == envid && e->env_status != ENV_FREE)
  802dbe:	8d 0c b5 00 00 00 00 	lea    0x0(,%esi,4),%ecx
  802dc5:	89 f2                	mov    %esi,%edx
  802dc7:	c1 e2 07             	shl    $0x7,%edx
  802dca:	29 ca                	sub    %ecx,%edx
  802dcc:	81 c2 08 00 c0 ee    	add    $0xeec00008,%edx
  802dd2:	8b 7a 40             	mov    0x40(%edx),%edi
  802dd5:	39 c7                	cmp    %eax,%edi
  802dd7:	75 37                	jne    802e10 <wait+0x80>
  802dd9:	89 f0                	mov    %esi,%eax
  802ddb:	c1 e0 07             	shl    $0x7,%eax
  802dde:	29 c8                	sub    %ecx,%eax
  802de0:	05 04 00 c0 ee       	add    $0xeec00004,%eax
  802de5:	8b 40 50             	mov    0x50(%eax),%eax
  802de8:	85 c0                	test   %eax,%eax
  802dea:	74 24                	je     802e10 <wait+0x80>
  802dec:	c1 e6 07             	shl    $0x7,%esi
  802def:	29 ce                	sub    %ecx,%esi
  802df1:	8d 9e 08 00 c0 ee    	lea    -0x113ffff8(%esi),%ebx
  802df7:	81 c6 04 00 c0 ee    	add    $0xeec00004,%esi
		sys_yield();
  802dfd:	e8 ef e7 ff ff       	call   8015f1 <sys_yield>
{
	const volatile struct Env *e;

	assert(envid != 0);
	e = &envs[ENVX(envid)];
	while (e->env_id == envid && e->env_status != ENV_FREE)
  802e02:	8b 43 40             	mov    0x40(%ebx),%eax
  802e05:	39 f8                	cmp    %edi,%eax
  802e07:	75 07                	jne    802e10 <wait+0x80>
  802e09:	8b 46 50             	mov    0x50(%esi),%eax
  802e0c:	85 c0                	test   %eax,%eax
  802e0e:	75 ed                	jne    802dfd <wait+0x6d>
		sys_yield();
}
  802e10:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802e13:	5b                   	pop    %ebx
  802e14:	5e                   	pop    %esi
  802e15:	5f                   	pop    %edi
  802e16:	c9                   	leave  
  802e17:	c3                   	ret    

00802e18 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  802e18:	55                   	push   %ebp
  802e19:	89 e5                	mov    %esp,%ebp
  802e1b:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  802e1e:	83 3d 00 70 80 00 00 	cmpl   $0x0,0x807000
  802e25:	75 52                	jne    802e79 <set_pgfault_handler+0x61>
		// First time through!	
		// LAB 4: Your code here.

		//int sys_page_alloc(envid_t envid, void *va, int perm)
		r = sys_page_alloc(0, (void*)(UXSTACKTOP - PGSIZE), PTE_U | PTE_W | PTE_P);
  802e27:	83 ec 04             	sub    $0x4,%esp
  802e2a:	6a 07                	push   $0x7
  802e2c:	68 00 f0 bf ee       	push   $0xeebff000
  802e31:	6a 00                	push   $0x0
  802e33:	e8 e0 e7 ff ff       	call   801618 <sys_page_alloc>
		if (r < 0) {
  802e38:	83 c4 10             	add    $0x10,%esp
  802e3b:	85 c0                	test   %eax,%eax
  802e3d:	79 12                	jns    802e51 <set_pgfault_handler+0x39>
			panic("sys_page_alloc error : %e\n", r);
  802e3f:	50                   	push   %eax
  802e40:	68 27 3b 80 00       	push   $0x803b27
  802e45:	6a 24                	push   $0x24
  802e47:	68 42 3b 80 00       	push   $0x803b42
  802e4c:	e8 d3 db ff ff       	call   800a24 <_panic>
		}

		// how to know envid, put 0, envid2env will help us to get curenv in syscall
		r = sys_env_set_pgfault_upcall(0, _pgfault_upcall);		
  802e51:	83 ec 08             	sub    $0x8,%esp
  802e54:	68 84 2e 80 00       	push   $0x802e84
  802e59:	6a 00                	push   $0x0
  802e5b:	e8 6b e8 ff ff       	call   8016cb <sys_env_set_pgfault_upcall>
		if (r < 0) {
  802e60:	83 c4 10             	add    $0x10,%esp
  802e63:	85 c0                	test   %eax,%eax
  802e65:	79 12                	jns    802e79 <set_pgfault_handler+0x61>
			panic("sys_env_set_pgfault_upcall error : %e\n", r);
  802e67:	50                   	push   %eax
  802e68:	68 50 3b 80 00       	push   $0x803b50
  802e6d:	6a 2a                	push   $0x2a
  802e6f:	68 42 3b 80 00       	push   $0x803b42
  802e74:	e8 ab db ff ff       	call   800a24 <_panic>
		}
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  802e79:	8b 45 08             	mov    0x8(%ebp),%eax
  802e7c:	a3 00 70 80 00       	mov    %eax,0x807000
}
  802e81:	c9                   	leave  
  802e82:	c3                   	ret    
	...

00802e84 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  802e84:	54                   	push   %esp
	movl _pgfault_handler, %eax
  802e85:	a1 00 70 80 00       	mov    0x807000,%eax
	call *%eax
  802e8a:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  802e8c:	83 c4 04             	add    $0x4,%esp
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	
	// fix old esp
	movl 0x30(%esp), %eax
  802e8f:	8b 44 24 30          	mov    0x30(%esp),%eax
	subl $0x4, %eax
  802e93:	83 e8 04             	sub    $0x4,%eax
	movl %eax, 0x30(%esp)
  802e96:	89 44 24 30          	mov    %eax,0x30(%esp)

	// set trap-time %eip
	movl 0x28(%esp), %ebx
  802e9a:	8b 5c 24 28          	mov    0x28(%esp),%ebx
	movl %ebx, (%eax)
  802e9e:	89 18                	mov    %ebx,(%eax)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	addl $0x08, %esp 	// ignore err_code and fault_va
  802ea0:	83 c4 08             	add    $0x8,%esp
	popal 				// restore registers
  802ea3:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $0x04, %esp 	// ignore eip 
  802ea4:	83 c4 04             	add    $0x4,%esp
	popfl				// modify eflags
  802ea7:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp
  802ea8:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  802ea9:	c3                   	ret    
	...

00802eac <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  802eac:	55                   	push   %ebp
  802ead:	89 e5                	mov    %esp,%ebp
  802eaf:	57                   	push   %edi
  802eb0:	56                   	push   %esi
  802eb1:	53                   	push   %ebx
  802eb2:	83 ec 0c             	sub    $0xc,%esp
  802eb5:	8b 7d 08             	mov    0x8(%ebp),%edi
  802eb8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  802ebb:	8b 75 10             	mov    0x10(%ebp),%esi
	// LAB 4: Your code here.
	cprintf("0x%x 0x%x 0x%x\n", (uint32_t)from_env_store, (uint32_t)pg, (uint32_t)perm_store);
  802ebe:	56                   	push   %esi
  802ebf:	53                   	push   %ebx
  802ec0:	57                   	push   %edi
  802ec1:	68 78 3b 80 00       	push   $0x803b78
  802ec6:	e8 31 dc ff ff       	call   800afc <cprintf>
	int r;
	if (pg != NULL) {
  802ecb:	83 c4 10             	add    $0x10,%esp
  802ece:	85 db                	test   %ebx,%ebx
  802ed0:	74 28                	je     802efa <ipc_recv+0x4e>
		cprintf("BEGIN\n");
  802ed2:	83 ec 0c             	sub    $0xc,%esp
  802ed5:	68 88 3b 80 00       	push   $0x803b88
  802eda:	e8 1d dc ff ff       	call   800afc <cprintf>
		r = sys_ipc_recv(pg);
  802edf:	89 1c 24             	mov    %ebx,(%esp)
  802ee2:	e8 2c e8 ff ff       	call   801713 <sys_ipc_recv>
  802ee7:	89 c3                	mov    %eax,%ebx
		cprintf("OVER\n");
  802ee9:	c7 04 24 2c 3a 80 00 	movl   $0x803a2c,(%esp)
  802ef0:	e8 07 dc ff ff       	call   800afc <cprintf>
  802ef5:	83 c4 10             	add    $0x10,%esp
  802ef8:	eb 12                	jmp    802f0c <ipc_recv+0x60>
	} else {
		r = sys_ipc_recv((void *)UTOP);
  802efa:	83 ec 0c             	sub    $0xc,%esp
  802efd:	68 00 00 c0 ee       	push   $0xeec00000
  802f02:	e8 0c e8 ff ff       	call   801713 <sys_ipc_recv>
  802f07:	89 c3                	mov    %eax,%ebx
  802f09:	83 c4 10             	add    $0x10,%esp
	}

	if (r == 0) {
  802f0c:	85 db                	test   %ebx,%ebx
  802f0e:	75 26                	jne    802f36 <ipc_recv+0x8a>
		if (from_env_store != NULL) *from_env_store = thisenv->env_ipc_from;
  802f10:	85 ff                	test   %edi,%edi
  802f12:	74 0a                	je     802f1e <ipc_recv+0x72>
  802f14:	a1 24 54 80 00       	mov    0x805424,%eax
  802f19:	8b 40 74             	mov    0x74(%eax),%eax
  802f1c:	89 07                	mov    %eax,(%edi)
		if (perm_store != NULL) *perm_store = thisenv->env_ipc_perm;
  802f1e:	85 f6                	test   %esi,%esi
  802f20:	74 0a                	je     802f2c <ipc_recv+0x80>
  802f22:	a1 24 54 80 00       	mov    0x805424,%eax
  802f27:	8b 40 78             	mov    0x78(%eax),%eax
  802f2a:	89 06                	mov    %eax,(%esi)
		return thisenv->env_ipc_value;
  802f2c:	a1 24 54 80 00       	mov    0x805424,%eax
  802f31:	8b 58 70             	mov    0x70(%eax),%ebx
  802f34:	eb 14                	jmp    802f4a <ipc_recv+0x9e>
	} else {
		// fails;
		if (from_env_store != NULL) *from_env_store = 0;
  802f36:	85 ff                	test   %edi,%edi
  802f38:	74 06                	je     802f40 <ipc_recv+0x94>
  802f3a:	c7 07 00 00 00 00    	movl   $0x0,(%edi)
		if (perm_store != NULL) *perm_store = 0;
  802f40:	85 f6                	test   %esi,%esi
  802f42:	74 06                	je     802f4a <ipc_recv+0x9e>
  802f44:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		return r;
	}
}
  802f4a:	89 d8                	mov    %ebx,%eax
  802f4c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802f4f:	5b                   	pop    %ebx
  802f50:	5e                   	pop    %esi
  802f51:	5f                   	pop    %edi
  802f52:	c9                   	leave  
  802f53:	c3                   	ret    

00802f54 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  802f54:	55                   	push   %ebp
  802f55:	89 e5                	mov    %esp,%ebp
  802f57:	57                   	push   %edi
  802f58:	56                   	push   %esi
  802f59:	53                   	push   %ebx
  802f5a:	83 ec 0c             	sub    $0xc,%esp
  802f5d:	8b 7d 0c             	mov    0xc(%ebp),%edi
  802f60:	8b 5d 10             	mov    0x10(%ebp),%ebx
  802f63:	8b 75 14             	mov    0x14(%ebp),%esi
	// LAB 4: Your code here.
	// int sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
	int r;
	if (pg == NULL) pg = (void *)UTOP;
  802f66:	85 db                	test   %ebx,%ebx
  802f68:	75 25                	jne    802f8f <ipc_send+0x3b>
  802f6a:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
  802f6f:	eb 1e                	jmp    802f8f <ipc_send+0x3b>
	
	while ((r = sys_ipc_try_send(to_env, val, pg, perm)) != 0) {
		if (r == -E_IPC_NOT_RECV) {
  802f71:	83 f8 f9             	cmp    $0xfffffff9,%eax
  802f74:	75 07                	jne    802f7d <ipc_send+0x29>
			// cprintf("Try Again and Again....\n");
			sys_yield();
  802f76:	e8 76 e6 ff ff       	call   8015f1 <sys_yield>
  802f7b:	eb 12                	jmp    802f8f <ipc_send+0x3b>
		} else {
			panic("ipc_send error %e\n", r);
  802f7d:	50                   	push   %eax
  802f7e:	68 8f 3b 80 00       	push   $0x803b8f
  802f83:	6a 45                	push   $0x45
  802f85:	68 a2 3b 80 00       	push   $0x803ba2
  802f8a:	e8 95 da ff ff       	call   800a24 <_panic>
	// LAB 4: Your code here.
	// int sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
	int r;
	if (pg == NULL) pg = (void *)UTOP;
	
	while ((r = sys_ipc_try_send(to_env, val, pg, perm)) != 0) {
  802f8f:	56                   	push   %esi
  802f90:	53                   	push   %ebx
  802f91:	57                   	push   %edi
  802f92:	ff 75 08             	pushl  0x8(%ebp)
  802f95:	e8 54 e7 ff ff       	call   8016ee <sys_ipc_try_send>
  802f9a:	83 c4 10             	add    $0x10,%esp
  802f9d:	85 c0                	test   %eax,%eax
  802f9f:	75 d0                	jne    802f71 <ipc_send+0x1d>
		} else {
			panic("ipc_send error %e\n", r);
		}
	}
	return;
}
  802fa1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802fa4:	5b                   	pop    %ebx
  802fa5:	5e                   	pop    %esi
  802fa6:	5f                   	pop    %edi
  802fa7:	c9                   	leave  
  802fa8:	c3                   	ret    

00802fa9 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  802fa9:	55                   	push   %ebp
  802faa:	89 e5                	mov    %esp,%ebp
  802fac:	53                   	push   %ebx
  802fad:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	for (i = 0; i < NENV; i++)
		if (envs[i].env_type == type)
  802fb0:	39 1d 50 00 c0 ee    	cmp    %ebx,0xeec00050
  802fb6:	74 22                	je     802fda <ipc_find_env+0x31>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  802fb8:	b8 01 00 00 00       	mov    $0x1,%eax
		if (envs[i].env_type == type)
  802fbd:	8d 0c 85 00 00 00 00 	lea    0x0(,%eax,4),%ecx
  802fc4:	89 c2                	mov    %eax,%edx
  802fc6:	c1 e2 07             	shl    $0x7,%edx
  802fc9:	29 ca                	sub    %ecx,%edx
  802fcb:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  802fd1:	8b 52 50             	mov    0x50(%edx),%edx
  802fd4:	39 da                	cmp    %ebx,%edx
  802fd6:	75 1d                	jne    802ff5 <ipc_find_env+0x4c>
  802fd8:	eb 05                	jmp    802fdf <ipc_find_env+0x36>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  802fda:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
			return envs[i].env_id;
  802fdf:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  802fe6:	c1 e0 07             	shl    $0x7,%eax
  802fe9:	29 d0                	sub    %edx,%eax
  802feb:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  802ff0:	8b 40 40             	mov    0x40(%eax),%eax
  802ff3:	eb 0c                	jmp    803001 <ipc_find_env+0x58>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  802ff5:	40                   	inc    %eax
  802ff6:	3d 00 04 00 00       	cmp    $0x400,%eax
  802ffb:	75 c0                	jne    802fbd <ipc_find_env+0x14>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  802ffd:	66 b8 00 00          	mov    $0x0,%ax
}
  803001:	5b                   	pop    %ebx
  803002:	c9                   	leave  
  803003:	c3                   	ret    

00803004 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  803004:	55                   	push   %ebp
  803005:	89 e5                	mov    %esp,%ebp
  803007:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  80300a:	89 c2                	mov    %eax,%edx
  80300c:	c1 ea 16             	shr    $0x16,%edx
  80300f:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  803016:	f6 c2 01             	test   $0x1,%dl
  803019:	74 1e                	je     803039 <pageref+0x35>
		return 0;
	pte = uvpt[PGNUM(v)];
  80301b:	c1 e8 0c             	shr    $0xc,%eax
  80301e:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  803025:	a8 01                	test   $0x1,%al
  803027:	74 17                	je     803040 <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  803029:	c1 e8 0c             	shr    $0xc,%eax
  80302c:	66 8b 04 c5 04 00 00 	mov    -0x10fffffc(,%eax,8),%ax
  803033:	ef 
  803034:	0f b7 c0             	movzwl %ax,%eax
  803037:	eb 0c                	jmp    803045 <pageref+0x41>
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
		return 0;
  803039:	b8 00 00 00 00       	mov    $0x0,%eax
  80303e:	eb 05                	jmp    803045 <pageref+0x41>
	pte = uvpt[PGNUM(v)];
	if (!(pte & PTE_P))
		return 0;
  803040:	b8 00 00 00 00       	mov    $0x0,%eax
	return pages[PGNUM(pte)].pp_ref;
}
  803045:	c9                   	leave  
  803046:	c3                   	ret    
	...

00803048 <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  803048:	55                   	push   %ebp
  803049:	89 e5                	mov    %esp,%ebp
  80304b:	57                   	push   %edi
  80304c:	56                   	push   %esi
  80304d:	83 ec 10             	sub    $0x10,%esp
  803050:	8b 7d 08             	mov    0x8(%ebp),%edi
  803053:	8b 4d 10             	mov    0x10(%ebp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  803056:	89 7d f0             	mov    %edi,-0x10(%ebp)
  803059:	8b 75 0c             	mov    0xc(%ebp),%esi
  const DWunion dd = {.ll = d};
  80305c:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  80305f:	8b 45 14             	mov    0x14(%ebp),%eax
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  803062:	85 c0                	test   %eax,%eax
  803064:	75 2e                	jne    803094 <__udivdi3+0x4c>
    {
      if (d0 > n1)
  803066:	39 f1                	cmp    %esi,%ecx
  803068:	77 5a                	ja     8030c4 <__udivdi3+0x7c>
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  80306a:	85 c9                	test   %ecx,%ecx
  80306c:	75 0b                	jne    803079 <__udivdi3+0x31>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  80306e:	b8 01 00 00 00       	mov    $0x1,%eax
  803073:	31 d2                	xor    %edx,%edx
  803075:	f7 f1                	div    %ecx
  803077:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  803079:	31 d2                	xor    %edx,%edx
  80307b:	89 f0                	mov    %esi,%eax
  80307d:	f7 f1                	div    %ecx
  80307f:	89 c6                	mov    %eax,%esi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  803081:	89 f8                	mov    %edi,%eax
  803083:	f7 f1                	div    %ecx
  803085:	89 c7                	mov    %eax,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  803087:	89 f8                	mov    %edi,%eax
  803089:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  80308b:	83 c4 10             	add    $0x10,%esp
  80308e:	5e                   	pop    %esi
  80308f:	5f                   	pop    %edi
  803090:	c9                   	leave  
  803091:	c3                   	ret    
  803092:	66 90                	xchg   %ax,%ax
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  803094:	39 f0                	cmp    %esi,%eax
  803096:	77 1c                	ja     8030b4 <__udivdi3+0x6c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  803098:	0f bd f8             	bsr    %eax,%edi
	  if (bm == 0)
  80309b:	83 f7 1f             	xor    $0x1f,%edi
  80309e:	75 3c                	jne    8030dc <__udivdi3+0x94>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  8030a0:	39 f0                	cmp    %esi,%eax
  8030a2:	0f 82 90 00 00 00    	jb     803138 <__udivdi3+0xf0>
  8030a8:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8030ab:	39 55 f4             	cmp    %edx,-0xc(%ebp)
  8030ae:	0f 86 84 00 00 00    	jbe    803138 <__udivdi3+0xf0>
  8030b4:	31 f6                	xor    %esi,%esi
  8030b6:	31 ff                	xor    %edi,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  8030b8:	89 f8                	mov    %edi,%eax
  8030ba:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  8030bc:	83 c4 10             	add    $0x10,%esp
  8030bf:	5e                   	pop    %esi
  8030c0:	5f                   	pop    %edi
  8030c1:	c9                   	leave  
  8030c2:	c3                   	ret    
  8030c3:	90                   	nop
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  8030c4:	89 f2                	mov    %esi,%edx
  8030c6:	89 f8                	mov    %edi,%eax
  8030c8:	f7 f1                	div    %ecx
  8030ca:	89 c7                	mov    %eax,%edi
  8030cc:	31 f6                	xor    %esi,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  8030ce:	89 f8                	mov    %edi,%eax
  8030d0:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  8030d2:	83 c4 10             	add    $0x10,%esp
  8030d5:	5e                   	pop    %esi
  8030d6:	5f                   	pop    %edi
  8030d7:	c9                   	leave  
  8030d8:	c3                   	ret    
  8030d9:	8d 76 00             	lea    0x0(%esi),%esi
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  8030dc:	89 f9                	mov    %edi,%ecx
  8030de:	d3 e0                	shl    %cl,%eax
  8030e0:	89 45 e8             	mov    %eax,-0x18(%ebp)
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  8030e3:	b8 20 00 00 00       	mov    $0x20,%eax
  8030e8:	29 f8                	sub    %edi,%eax

	      d1 = (d1 << bm) | (d0 >> b);
  8030ea:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8030ed:	88 c1                	mov    %al,%cl
  8030ef:	d3 ea                	shr    %cl,%edx
  8030f1:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  8030f4:	09 ca                	or     %ecx,%edx
  8030f6:	89 55 ec             	mov    %edx,-0x14(%ebp)
	      d0 = d0 << bm;
  8030f9:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8030fc:	89 f9                	mov    %edi,%ecx
  8030fe:	d3 e2                	shl    %cl,%edx
  803100:	89 55 f4             	mov    %edx,-0xc(%ebp)
	      n2 = n1 >> b;
  803103:	89 f2                	mov    %esi,%edx
  803105:	88 c1                	mov    %al,%cl
  803107:	d3 ea                	shr    %cl,%edx
  803109:	89 55 e8             	mov    %edx,-0x18(%ebp)
	      n1 = (n1 << bm) | (n0 >> b);
  80310c:	89 f2                	mov    %esi,%edx
  80310e:	89 f9                	mov    %edi,%ecx
  803110:	d3 e2                	shl    %cl,%edx
  803112:	8b 75 f0             	mov    -0x10(%ebp),%esi
  803115:	88 c1                	mov    %al,%cl
  803117:	d3 ee                	shr    %cl,%esi
  803119:	09 d6                	or     %edx,%esi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  80311b:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  80311e:	89 f0                	mov    %esi,%eax
  803120:	89 ca                	mov    %ecx,%edx
  803122:	f7 75 ec             	divl   -0x14(%ebp)
  803125:	89 d1                	mov    %edx,%ecx
  803127:	89 c6                	mov    %eax,%esi
	      umul_ppmm (m1, m0, q0, d0);
  803129:	f7 65 f4             	mull   -0xc(%ebp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  80312c:	39 d1                	cmp    %edx,%ecx
  80312e:	72 28                	jb     803158 <__udivdi3+0x110>
  803130:	74 1a                	je     80314c <__udivdi3+0x104>
  803132:	89 f7                	mov    %esi,%edi
  803134:	31 f6                	xor    %esi,%esi
  803136:	eb 80                	jmp    8030b8 <__udivdi3+0x70>
	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  803138:	31 f6                	xor    %esi,%esi
  80313a:	bf 01 00 00 00       	mov    $0x1,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  80313f:	89 f8                	mov    %edi,%eax
  803141:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  803143:	83 c4 10             	add    $0x10,%esp
  803146:	5e                   	pop    %esi
  803147:	5f                   	pop    %edi
  803148:	c9                   	leave  
  803149:	c3                   	ret    
  80314a:	66 90                	xchg   %ax,%ax

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  80314c:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80314f:	89 f9                	mov    %edi,%ecx
  803151:	d3 e2                	shl    %cl,%edx

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  803153:	39 c2                	cmp    %eax,%edx
  803155:	73 db                	jae    803132 <__udivdi3+0xea>
  803157:	90                   	nop
		{
		  q0--;
  803158:	8d 7e ff             	lea    -0x1(%esi),%edi
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  80315b:	31 f6                	xor    %esi,%esi
  80315d:	e9 56 ff ff ff       	jmp    8030b8 <__udivdi3+0x70>
	...

00803164 <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  803164:	55                   	push   %ebp
  803165:	89 e5                	mov    %esp,%ebp
  803167:	57                   	push   %edi
  803168:	56                   	push   %esi
  803169:	83 ec 20             	sub    $0x20,%esp
  80316c:	8b 45 08             	mov    0x8(%ebp),%eax
  80316f:	8b 4d 10             	mov    0x10(%ebp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  803172:	89 45 e8             	mov    %eax,-0x18(%ebp)
  803175:	8b 75 0c             	mov    0xc(%ebp),%esi
  const DWunion dd = {.ll = d};
  803178:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  80317b:	8b 7d 14             	mov    0x14(%ebp),%edi
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  80317e:	89 45 f0             	mov    %eax,-0x10(%ebp)
  n1 = nn.s.high;
  803181:	89 f2                	mov    %esi,%edx

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  803183:	85 ff                	test   %edi,%edi
  803185:	75 15                	jne    80319c <__umoddi3+0x38>
    {
      if (d0 > n1)
  803187:	39 f1                	cmp    %esi,%ecx
  803189:	0f 86 99 00 00 00    	jbe    803228 <__umoddi3+0xc4>
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  80318f:	f7 f1                	div    %ecx

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
  803191:	89 d0                	mov    %edx,%eax
  803193:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  803195:	83 c4 20             	add    $0x20,%esp
  803198:	5e                   	pop    %esi
  803199:	5f                   	pop    %edi
  80319a:	c9                   	leave  
  80319b:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  80319c:	39 f7                	cmp    %esi,%edi
  80319e:	0f 87 a4 00 00 00    	ja     803248 <__umoddi3+0xe4>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  8031a4:	0f bd c7             	bsr    %edi,%eax
	  if (bm == 0)
  8031a7:	83 f0 1f             	xor    $0x1f,%eax
  8031aa:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8031ad:	0f 84 a1 00 00 00    	je     803254 <__umoddi3+0xf0>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  8031b3:	89 f8                	mov    %edi,%eax
  8031b5:	8a 4d ec             	mov    -0x14(%ebp),%cl
  8031b8:	d3 e0                	shl    %cl,%eax
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  8031ba:	bf 20 00 00 00       	mov    $0x20,%edi
  8031bf:	2b 7d ec             	sub    -0x14(%ebp),%edi

	      d1 = (d1 << bm) | (d0 >> b);
  8031c2:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8031c5:	89 f9                	mov    %edi,%ecx
  8031c7:	d3 ea                	shr    %cl,%edx
  8031c9:	09 c2                	or     %eax,%edx
  8031cb:	89 55 f0             	mov    %edx,-0x10(%ebp)
	      d0 = d0 << bm;
  8031ce:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8031d1:	8a 4d ec             	mov    -0x14(%ebp),%cl
  8031d4:	d3 e0                	shl    %cl,%eax
  8031d6:	89 45 f4             	mov    %eax,-0xc(%ebp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  8031d9:	89 f2                	mov    %esi,%edx
  8031db:	d3 e2                	shl    %cl,%edx
	      n0 = n0 << bm;
  8031dd:	8b 45 e8             	mov    -0x18(%ebp),%eax
  8031e0:	d3 e0                	shl    %cl,%eax
  8031e2:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  8031e5:	8b 45 e8             	mov    -0x18(%ebp),%eax
  8031e8:	89 f9                	mov    %edi,%ecx
  8031ea:	d3 e8                	shr    %cl,%eax
  8031ec:	09 d0                	or     %edx,%eax

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  8031ee:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  8031f0:	89 f2                	mov    %esi,%edx
  8031f2:	f7 75 f0             	divl   -0x10(%ebp)
  8031f5:	89 d6                	mov    %edx,%esi
	      umul_ppmm (m1, m0, q0, d0);
  8031f7:	f7 65 f4             	mull   -0xc(%ebp)
  8031fa:	89 55 e8             	mov    %edx,-0x18(%ebp)
  8031fd:	89 c1                	mov    %eax,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  8031ff:	39 d6                	cmp    %edx,%esi
  803201:	72 71                	jb     803274 <__umoddi3+0x110>
  803203:	74 7f                	je     803284 <__umoddi3+0x120>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  803205:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  803208:	29 c8                	sub    %ecx,%eax
  80320a:	19 d6                	sbb    %edx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
  80320c:	8a 4d ec             	mov    -0x14(%ebp),%cl
  80320f:	d3 e8                	shr    %cl,%eax
  803211:	89 f2                	mov    %esi,%edx
  803213:	89 f9                	mov    %edi,%ecx
  803215:	d3 e2                	shl    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
  803217:	09 d0                	or     %edx,%eax
  803219:	89 f2                	mov    %esi,%edx
  80321b:	8a 4d ec             	mov    -0x14(%ebp),%cl
  80321e:	d3 ea                	shr    %cl,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  803220:	83 c4 20             	add    $0x20,%esp
  803223:	5e                   	pop    %esi
  803224:	5f                   	pop    %edi
  803225:	c9                   	leave  
  803226:	c3                   	ret    
  803227:	90                   	nop
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  803228:	85 c9                	test   %ecx,%ecx
  80322a:	75 0b                	jne    803237 <__umoddi3+0xd3>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  80322c:	b8 01 00 00 00       	mov    $0x1,%eax
  803231:	31 d2                	xor    %edx,%edx
  803233:	f7 f1                	div    %ecx
  803235:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  803237:	89 f0                	mov    %esi,%eax
  803239:	31 d2                	xor    %edx,%edx
  80323b:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  80323d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  803240:	f7 f1                	div    %ecx
  803242:	e9 4a ff ff ff       	jmp    803191 <__umoddi3+0x2d>
  803247:	90                   	nop
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
  803248:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  80324a:	83 c4 20             	add    $0x20,%esp
  80324d:	5e                   	pop    %esi
  80324e:	5f                   	pop    %edi
  80324f:	c9                   	leave  
  803250:	c3                   	ret    
  803251:	8d 76 00             	lea    0x0(%esi),%esi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  803254:	39 f7                	cmp    %esi,%edi
  803256:	72 05                	jb     80325d <__umoddi3+0xf9>
  803258:	3b 4d f0             	cmp    -0x10(%ebp),%ecx
  80325b:	77 0c                	ja     803269 <__umoddi3+0x105>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  80325d:	89 f2                	mov    %esi,%edx
  80325f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  803262:	29 c8                	sub    %ecx,%eax
  803264:	19 fa                	sbb    %edi,%edx
  803266:	89 45 f0             	mov    %eax,-0x10(%ebp)

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
  803269:	8b 45 f0             	mov    -0x10(%ebp),%eax
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  80326c:	83 c4 20             	add    $0x20,%esp
  80326f:	5e                   	pop    %esi
  803270:	5f                   	pop    %edi
  803271:	c9                   	leave  
  803272:	c3                   	ret    
  803273:	90                   	nop
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  803274:	8b 55 e8             	mov    -0x18(%ebp),%edx
  803277:	89 c1                	mov    %eax,%ecx
  803279:	2b 4d f4             	sub    -0xc(%ebp),%ecx
  80327c:	1b 55 f0             	sbb    -0x10(%ebp),%edx
  80327f:	eb 84                	jmp    803205 <__umoddi3+0xa1>
  803281:	8d 76 00             	lea    0x0(%esi),%esi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  803284:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  803287:	72 eb                	jb     803274 <__umoddi3+0x110>
  803289:	89 f2                	mov    %esi,%edx
  80328b:	e9 75 ff ff ff       	jmp    803205 <__umoddi3+0xa1>
