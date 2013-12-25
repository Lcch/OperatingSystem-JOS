
obj/user/ls.debug:     file format elf32-i386


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
  80002c:	e8 a7 02 00 00       	call   8002d8 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800034 <ls1>:
		panic("error reading directory %s: %e", path, n);
}

void
ls1(const char *prefix, bool isdir, off_t size, const char *name)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	53                   	push   %ebx
  800038:	83 ec 14             	sub    $0x14,%esp
  80003b:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80003e:	8a 45 0c             	mov    0xc(%ebp),%al
  800041:	88 45 f7             	mov    %al,-0x9(%ebp)
	const char *sep;

	if(flag['l'])
  800044:	83 3d d0 41 80 00 00 	cmpl   $0x0,0x8041d0
  80004b:	74 1e                	je     80006b <ls1+0x37>
		printf("%11d %c ", size, isdir ? 'd' : '-');
  80004d:	3c 01                	cmp    $0x1,%al
  80004f:	19 c0                	sbb    %eax,%eax
  800051:	83 e0 c9             	and    $0xffffffc9,%eax
  800054:	83 c0 64             	add    $0x64,%eax
  800057:	83 ec 04             	sub    $0x4,%esp
  80005a:	50                   	push   %eax
  80005b:	ff 75 10             	pushl  0x10(%ebp)
  80005e:	68 e2 22 80 00       	push   $0x8022e2
  800063:	e8 9c 19 00 00       	call   801a04 <printf>
  800068:	83 c4 10             	add    $0x10,%esp
	if(prefix) {
  80006b:	85 db                	test   %ebx,%ebx
  80006d:	74 3d                	je     8000ac <ls1+0x78>
		if (prefix[0] && prefix[strlen(prefix)-1] != '/')
  80006f:	80 3b 00             	cmpb   $0x0,(%ebx)
  800072:	74 1a                	je     80008e <ls1+0x5a>
  800074:	83 ec 0c             	sub    $0xc,%esp
  800077:	53                   	push   %ebx
  800078:	e8 ff 08 00 00       	call   80097c <strlen>
  80007d:	83 c4 10             	add    $0x10,%esp
  800080:	80 7c 03 ff 2f       	cmpb   $0x2f,-0x1(%ebx,%eax,1)
  800085:	74 0e                	je     800095 <ls1+0x61>
			sep = "/";
  800087:	b8 e0 22 80 00       	mov    $0x8022e0,%eax
  80008c:	eb 0c                	jmp    80009a <ls1+0x66>
		else
			sep = "";
  80008e:	b8 48 23 80 00       	mov    $0x802348,%eax
  800093:	eb 05                	jmp    80009a <ls1+0x66>
  800095:	b8 48 23 80 00       	mov    $0x802348,%eax
		printf("%s%s", prefix, sep);
  80009a:	83 ec 04             	sub    $0x4,%esp
  80009d:	50                   	push   %eax
  80009e:	53                   	push   %ebx
  80009f:	68 eb 22 80 00       	push   $0x8022eb
  8000a4:	e8 5b 19 00 00       	call   801a04 <printf>
  8000a9:	83 c4 10             	add    $0x10,%esp
	}
	printf("%s", name);
  8000ac:	83 ec 08             	sub    $0x8,%esp
  8000af:	ff 75 14             	pushl  0x14(%ebp)
  8000b2:	68 75 27 80 00       	push   $0x802775
  8000b7:	e8 48 19 00 00       	call   801a04 <printf>
	if(flag['F'] && isdir)
  8000bc:	83 c4 10             	add    $0x10,%esp
  8000bf:	83 3d 38 41 80 00 00 	cmpl   $0x0,0x804138
  8000c6:	74 16                	je     8000de <ls1+0xaa>
  8000c8:	80 7d f7 00          	cmpb   $0x0,-0x9(%ebp)
  8000cc:	74 10                	je     8000de <ls1+0xaa>
		printf("/");
  8000ce:	83 ec 0c             	sub    $0xc,%esp
  8000d1:	68 e0 22 80 00       	push   $0x8022e0
  8000d6:	e8 29 19 00 00       	call   801a04 <printf>
  8000db:	83 c4 10             	add    $0x10,%esp
	printf("\n");
  8000de:	83 ec 0c             	sub    $0xc,%esp
  8000e1:	68 47 23 80 00       	push   $0x802347
  8000e6:	e8 19 19 00 00       	call   801a04 <printf>
  8000eb:	83 c4 10             	add    $0x10,%esp
}
  8000ee:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8000f1:	c9                   	leave  
  8000f2:	c3                   	ret    

008000f3 <lsdir>:
		ls1(0, st.st_isdir, st.st_size, path);
}

void
lsdir(const char *path, const char *prefix)
{
  8000f3:	55                   	push   %ebp
  8000f4:	89 e5                	mov    %esp,%ebp
  8000f6:	57                   	push   %edi
  8000f7:	56                   	push   %esi
  8000f8:	53                   	push   %ebx
  8000f9:	81 ec 14 01 00 00    	sub    $0x114,%esp
  8000ff:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int fd, n;
	struct File f;

	if ((fd = open(path, O_RDONLY)) < 0)
  800102:	6a 00                	push   $0x0
  800104:	ff 75 08             	pushl  0x8(%ebp)
  800107:	e8 6c 17 00 00       	call   801878 <open>
  80010c:	89 c6                	mov    %eax,%esi
  80010e:	83 c4 10             	add    $0x10,%esp
  800111:	85 c0                	test   %eax,%eax
  800113:	79 41                	jns    800156 <lsdir+0x63>
		panic("open %s: %e", path, fd);
  800115:	83 ec 0c             	sub    $0xc,%esp
  800118:	50                   	push   %eax
  800119:	ff 75 08             	pushl  0x8(%ebp)
  80011c:	68 f0 22 80 00       	push   $0x8022f0
  800121:	6a 1d                	push   $0x1d
  800123:	68 fc 22 80 00       	push   $0x8022fc
  800128:	e8 13 02 00 00       	call   800340 <_panic>
	while ((n = readn(fd, &f, sizeof f)) == sizeof f)
		if (f.f_name[0])
  80012d:	80 bd e8 fe ff ff 00 	cmpb   $0x0,-0x118(%ebp)
  800134:	74 26                	je     80015c <lsdir+0x69>
			ls1(prefix, f.f_type==FTYPE_DIR, f.f_size, f.f_name);
  800136:	53                   	push   %ebx
  800137:	ff b5 68 ff ff ff    	pushl  -0x98(%ebp)
  80013d:	83 bd 6c ff ff ff 01 	cmpl   $0x1,-0x94(%ebp)
  800144:	0f 94 c0             	sete   %al
  800147:	0f b6 c0             	movzbl %al,%eax
  80014a:	50                   	push   %eax
  80014b:	57                   	push   %edi
  80014c:	e8 e3 fe ff ff       	call   800034 <ls1>
  800151:	83 c4 10             	add    $0x10,%esp
  800154:	eb 06                	jmp    80015c <lsdir+0x69>
	int fd, n;
	struct File f;

	if ((fd = open(path, O_RDONLY)) < 0)
		panic("open %s: %e", path, fd);
	while ((n = readn(fd, &f, sizeof f)) == sizeof f)
  800156:	8d 9d e8 fe ff ff    	lea    -0x118(%ebp),%ebx
  80015c:	83 ec 04             	sub    $0x4,%esp
  80015f:	68 00 01 00 00       	push   $0x100
  800164:	53                   	push   %ebx
  800165:	56                   	push   %esi
  800166:	e8 90 13 00 00       	call   8014fb <readn>
  80016b:	83 c4 10             	add    $0x10,%esp
  80016e:	3d 00 01 00 00       	cmp    $0x100,%eax
  800173:	74 b8                	je     80012d <lsdir+0x3a>
		if (f.f_name[0])
			ls1(prefix, f.f_type==FTYPE_DIR, f.f_size, f.f_name);
	if (n > 0)
  800175:	85 c0                	test   %eax,%eax
  800177:	7e 14                	jle    80018d <lsdir+0x9a>
		panic("short read in directory %s", path);
  800179:	ff 75 08             	pushl  0x8(%ebp)
  80017c:	68 06 23 80 00       	push   $0x802306
  800181:	6a 22                	push   $0x22
  800183:	68 fc 22 80 00       	push   $0x8022fc
  800188:	e8 b3 01 00 00       	call   800340 <_panic>
	if (n < 0)
  80018d:	85 c0                	test   %eax,%eax
  80018f:	79 18                	jns    8001a9 <lsdir+0xb6>
		panic("error reading directory %s: %e", path, n);
  800191:	83 ec 0c             	sub    $0xc,%esp
  800194:	50                   	push   %eax
  800195:	ff 75 08             	pushl  0x8(%ebp)
  800198:	68 4c 23 80 00       	push   $0x80234c
  80019d:	6a 24                	push   $0x24
  80019f:	68 fc 22 80 00       	push   $0x8022fc
  8001a4:	e8 97 01 00 00       	call   800340 <_panic>
}
  8001a9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001ac:	5b                   	pop    %ebx
  8001ad:	5e                   	pop    %esi
  8001ae:	5f                   	pop    %edi
  8001af:	c9                   	leave  
  8001b0:	c3                   	ret    

008001b1 <ls>:
void lsdir(const char*, const char*);
void ls1(const char*, bool, off_t, const char*);

void
ls(const char *path, const char *prefix)
{
  8001b1:	55                   	push   %ebp
  8001b2:	89 e5                	mov    %esp,%ebp
  8001b4:	53                   	push   %ebx
  8001b5:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
  8001bb:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Stat st;

	if ((r = stat(path, &st)) < 0)
  8001be:	8d 85 6c ff ff ff    	lea    -0x94(%ebp),%eax
  8001c4:	50                   	push   %eax
  8001c5:	53                   	push   %ebx
  8001c6:	e8 23 15 00 00       	call   8016ee <stat>
  8001cb:	83 c4 10             	add    $0x10,%esp
  8001ce:	85 c0                	test   %eax,%eax
  8001d0:	79 16                	jns    8001e8 <ls+0x37>
		panic("stat %s: %e", path, r);
  8001d2:	83 ec 0c             	sub    $0xc,%esp
  8001d5:	50                   	push   %eax
  8001d6:	53                   	push   %ebx
  8001d7:	68 21 23 80 00       	push   $0x802321
  8001dc:	6a 0f                	push   $0xf
  8001de:	68 fc 22 80 00       	push   $0x8022fc
  8001e3:	e8 58 01 00 00       	call   800340 <_panic>
	if (st.st_isdir && !flag['d'])
  8001e8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8001eb:	85 c0                	test   %eax,%eax
  8001ed:	74 1a                	je     800209 <ls+0x58>
  8001ef:	83 3d b0 41 80 00 00 	cmpl   $0x0,0x8041b0
  8001f6:	75 11                	jne    800209 <ls+0x58>
		lsdir(path, prefix);
  8001f8:	83 ec 08             	sub    $0x8,%esp
  8001fb:	ff 75 0c             	pushl  0xc(%ebp)
  8001fe:	53                   	push   %ebx
  8001ff:	e8 ef fe ff ff       	call   8000f3 <lsdir>
  800204:	83 c4 10             	add    $0x10,%esp
  800207:	eb 17                	jmp    800220 <ls+0x6f>
	else
		ls1(0, st.st_isdir, st.st_size, path);
  800209:	53                   	push   %ebx
  80020a:	ff 75 ec             	pushl  -0x14(%ebp)
  80020d:	85 c0                	test   %eax,%eax
  80020f:	0f 95 c0             	setne  %al
  800212:	0f b6 c0             	movzbl %al,%eax
  800215:	50                   	push   %eax
  800216:	6a 00                	push   $0x0
  800218:	e8 17 fe ff ff       	call   800034 <ls1>
  80021d:	83 c4 10             	add    $0x10,%esp
}
  800220:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800223:	c9                   	leave  
  800224:	c3                   	ret    

00800225 <usage>:
	printf("\n");
}

void
usage(void)
{
  800225:	55                   	push   %ebp
  800226:	89 e5                	mov    %esp,%ebp
  800228:	83 ec 14             	sub    $0x14,%esp
	printf("usage: ls [-dFl] [file...]\n");
  80022b:	68 2d 23 80 00       	push   $0x80232d
  800230:	e8 cf 17 00 00       	call   801a04 <printf>
	exit();
  800235:	e8 ea 00 00 00       	call   800324 <exit>
  80023a:	83 c4 10             	add    $0x10,%esp
}
  80023d:	c9                   	leave  
  80023e:	c3                   	ret    

0080023f <umain>:

void
umain(int argc, char **argv)
{
  80023f:	55                   	push   %ebp
  800240:	89 e5                	mov    %esp,%ebp
  800242:	56                   	push   %esi
  800243:	53                   	push   %ebx
  800244:	83 ec 14             	sub    $0x14,%esp
  800247:	8b 75 0c             	mov    0xc(%ebp),%esi
	int i;
	struct Argstate args;

	argstart(&argc, argv, &args);
  80024a:	8d 45 e8             	lea    -0x18(%ebp),%eax
  80024d:	50                   	push   %eax
  80024e:	56                   	push   %esi
  80024f:	8d 45 08             	lea    0x8(%ebp),%eax
  800252:	50                   	push   %eax
  800253:	e8 a4 0d 00 00       	call   800ffc <argstart>
	while ((i = argnext(&args)) >= 0)
  800258:	83 c4 10             	add    $0x10,%esp
  80025b:	8d 5d e8             	lea    -0x18(%ebp),%ebx
  80025e:	eb 1d                	jmp    80027d <umain+0x3e>
		switch (i) {
  800260:	83 f8 64             	cmp    $0x64,%eax
  800263:	74 0a                	je     80026f <umain+0x30>
  800265:	83 f8 6c             	cmp    $0x6c,%eax
  800268:	74 05                	je     80026f <umain+0x30>
  80026a:	83 f8 46             	cmp    $0x46,%eax
  80026d:	75 09                	jne    800278 <umain+0x39>
		case 'd':
		case 'F':
		case 'l':
			flag[i]++;
  80026f:	ff 04 85 20 40 80 00 	incl   0x804020(,%eax,4)
			break;
  800276:	eb 05                	jmp    80027d <umain+0x3e>
		default:
			usage();
  800278:	e8 a8 ff ff ff       	call   800225 <usage>
{
	int i;
	struct Argstate args;

	argstart(&argc, argv, &args);
	while ((i = argnext(&args)) >= 0)
  80027d:	83 ec 0c             	sub    $0xc,%esp
  800280:	53                   	push   %ebx
  800281:	e8 af 0d 00 00       	call   801035 <argnext>
  800286:	83 c4 10             	add    $0x10,%esp
  800289:	85 c0                	test   %eax,%eax
  80028b:	79 d3                	jns    800260 <umain+0x21>
			break;
		default:
			usage();
		}

	if (argc == 1)
  80028d:	8b 45 08             	mov    0x8(%ebp),%eax
  800290:	83 f8 01             	cmp    $0x1,%eax
  800293:	74 07                	je     80029c <umain+0x5d>
		ls("/", "");
	else {
		for (i = 1; i < argc; i++)
  800295:	83 f8 01             	cmp    $0x1,%eax
  800298:	7f 19                	jg     8002b3 <umain+0x74>
  80029a:	eb 32                	jmp    8002ce <umain+0x8f>
		default:
			usage();
		}

	if (argc == 1)
		ls("/", "");
  80029c:	83 ec 08             	sub    $0x8,%esp
  80029f:	68 48 23 80 00       	push   $0x802348
  8002a4:	68 e0 22 80 00       	push   $0x8022e0
  8002a9:	e8 03 ff ff ff       	call   8001b1 <ls>
  8002ae:	83 c4 10             	add    $0x10,%esp
  8002b1:	eb 1b                	jmp    8002ce <umain+0x8f>
	else {
		for (i = 1; i < argc; i++)
  8002b3:	bb 01 00 00 00       	mov    $0x1,%ebx
			ls(argv[i], argv[i]);
  8002b8:	8b 04 9e             	mov    (%esi,%ebx,4),%eax
  8002bb:	83 ec 08             	sub    $0x8,%esp
  8002be:	50                   	push   %eax
  8002bf:	50                   	push   %eax
  8002c0:	e8 ec fe ff ff       	call   8001b1 <ls>
		}

	if (argc == 1)
		ls("/", "");
	else {
		for (i = 1; i < argc; i++)
  8002c5:	43                   	inc    %ebx
  8002c6:	83 c4 10             	add    $0x10,%esp
  8002c9:	39 5d 08             	cmp    %ebx,0x8(%ebp)
  8002cc:	7f ea                	jg     8002b8 <umain+0x79>
			ls(argv[i], argv[i]);
	}
}
  8002ce:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8002d1:	5b                   	pop    %ebx
  8002d2:	5e                   	pop    %esi
  8002d3:	c9                   	leave  
  8002d4:	c3                   	ret    
  8002d5:	00 00                	add    %al,(%eax)
	...

008002d8 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8002d8:	55                   	push   %ebp
  8002d9:	89 e5                	mov    %esp,%ebp
  8002db:	56                   	push   %esi
  8002dc:	53                   	push   %ebx
  8002dd:	8b 75 08             	mov    0x8(%ebp),%esi
  8002e0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = envs + ENVX(sys_getenvid());
  8002e3:	e8 1d 0b 00 00       	call   800e05 <sys_getenvid>
  8002e8:	25 ff 03 00 00       	and    $0x3ff,%eax
  8002ed:	89 c2                	mov    %eax,%edx
  8002ef:	c1 e2 07             	shl    $0x7,%edx
  8002f2:	8d 84 82 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,4),%eax
  8002f9:	a3 20 44 80 00       	mov    %eax,0x804420

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8002fe:	85 f6                	test   %esi,%esi
  800300:	7e 07                	jle    800309 <libmain+0x31>
		binaryname = argv[0];
  800302:	8b 03                	mov    (%ebx),%eax
  800304:	a3 00 30 80 00       	mov    %eax,0x803000
	// call user main routine
	umain(argc, argv);
  800309:	83 ec 08             	sub    $0x8,%esp
  80030c:	53                   	push   %ebx
  80030d:	56                   	push   %esi
  80030e:	e8 2c ff ff ff       	call   80023f <umain>

	// exit gracefully
	exit();
  800313:	e8 0c 00 00 00       	call   800324 <exit>
  800318:	83 c4 10             	add    $0x10,%esp
}
  80031b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80031e:	5b                   	pop    %ebx
  80031f:	5e                   	pop    %esi
  800320:	c9                   	leave  
  800321:	c3                   	ret    
	...

00800324 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800324:	55                   	push   %ebp
  800325:	89 e5                	mov    %esp,%ebp
  800327:	83 ec 08             	sub    $0x8,%esp
	close_all();
  80032a:	e8 33 10 00 00       	call   801362 <close_all>
	sys_env_destroy(0);
  80032f:	83 ec 0c             	sub    $0xc,%esp
  800332:	6a 00                	push   $0x0
  800334:	e8 aa 0a 00 00       	call   800de3 <sys_env_destroy>
  800339:	83 c4 10             	add    $0x10,%esp
}
  80033c:	c9                   	leave  
  80033d:	c3                   	ret    
	...

00800340 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800340:	55                   	push   %ebp
  800341:	89 e5                	mov    %esp,%ebp
  800343:	56                   	push   %esi
  800344:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800345:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800348:	8b 1d 00 30 80 00    	mov    0x803000,%ebx
  80034e:	e8 b2 0a 00 00       	call   800e05 <sys_getenvid>
  800353:	83 ec 0c             	sub    $0xc,%esp
  800356:	ff 75 0c             	pushl  0xc(%ebp)
  800359:	ff 75 08             	pushl  0x8(%ebp)
  80035c:	53                   	push   %ebx
  80035d:	50                   	push   %eax
  80035e:	68 78 23 80 00       	push   $0x802378
  800363:	e8 b0 00 00 00       	call   800418 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800368:	83 c4 18             	add    $0x18,%esp
  80036b:	56                   	push   %esi
  80036c:	ff 75 10             	pushl  0x10(%ebp)
  80036f:	e8 53 00 00 00       	call   8003c7 <vcprintf>
	cprintf("\n");
  800374:	c7 04 24 47 23 80 00 	movl   $0x802347,(%esp)
  80037b:	e8 98 00 00 00       	call   800418 <cprintf>
  800380:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800383:	cc                   	int3   
  800384:	eb fd                	jmp    800383 <_panic+0x43>
	...

00800388 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800388:	55                   	push   %ebp
  800389:	89 e5                	mov    %esp,%ebp
  80038b:	53                   	push   %ebx
  80038c:	83 ec 04             	sub    $0x4,%esp
  80038f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800392:	8b 03                	mov    (%ebx),%eax
  800394:	8b 55 08             	mov    0x8(%ebp),%edx
  800397:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  80039b:	40                   	inc    %eax
  80039c:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  80039e:	3d ff 00 00 00       	cmp    $0xff,%eax
  8003a3:	75 1a                	jne    8003bf <putch+0x37>
		sys_cputs(b->buf, b->idx);
  8003a5:	83 ec 08             	sub    $0x8,%esp
  8003a8:	68 ff 00 00 00       	push   $0xff
  8003ad:	8d 43 08             	lea    0x8(%ebx),%eax
  8003b0:	50                   	push   %eax
  8003b1:	e8 e3 09 00 00       	call   800d99 <sys_cputs>
		b->idx = 0;
  8003b6:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8003bc:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8003bf:	ff 43 04             	incl   0x4(%ebx)
}
  8003c2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8003c5:	c9                   	leave  
  8003c6:	c3                   	ret    

008003c7 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8003c7:	55                   	push   %ebp
  8003c8:	89 e5                	mov    %esp,%ebp
  8003ca:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8003d0:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8003d7:	00 00 00 
	b.cnt = 0;
  8003da:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8003e1:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8003e4:	ff 75 0c             	pushl  0xc(%ebp)
  8003e7:	ff 75 08             	pushl  0x8(%ebp)
  8003ea:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8003f0:	50                   	push   %eax
  8003f1:	68 88 03 80 00       	push   $0x800388
  8003f6:	e8 82 01 00 00       	call   80057d <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8003fb:	83 c4 08             	add    $0x8,%esp
  8003fe:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800404:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80040a:	50                   	push   %eax
  80040b:	e8 89 09 00 00       	call   800d99 <sys_cputs>

	return b.cnt;
}
  800410:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800416:	c9                   	leave  
  800417:	c3                   	ret    

00800418 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800418:	55                   	push   %ebp
  800419:	89 e5                	mov    %esp,%ebp
  80041b:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80041e:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800421:	50                   	push   %eax
  800422:	ff 75 08             	pushl  0x8(%ebp)
  800425:	e8 9d ff ff ff       	call   8003c7 <vcprintf>
	va_end(ap);

	return cnt;
}
  80042a:	c9                   	leave  
  80042b:	c3                   	ret    

0080042c <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80042c:	55                   	push   %ebp
  80042d:	89 e5                	mov    %esp,%ebp
  80042f:	57                   	push   %edi
  800430:	56                   	push   %esi
  800431:	53                   	push   %ebx
  800432:	83 ec 2c             	sub    $0x2c,%esp
  800435:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800438:	89 d6                	mov    %edx,%esi
  80043a:	8b 45 08             	mov    0x8(%ebp),%eax
  80043d:	8b 55 0c             	mov    0xc(%ebp),%edx
  800440:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800443:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800446:	8b 45 10             	mov    0x10(%ebp),%eax
  800449:	8b 5d 14             	mov    0x14(%ebp),%ebx
  80044c:	8b 7d 18             	mov    0x18(%ebp),%edi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80044f:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800452:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  800459:	39 55 d4             	cmp    %edx,-0x2c(%ebp)
  80045c:	72 0c                	jb     80046a <printnum+0x3e>
  80045e:	3b 45 d8             	cmp    -0x28(%ebp),%eax
  800461:	76 07                	jbe    80046a <printnum+0x3e>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800463:	4b                   	dec    %ebx
  800464:	85 db                	test   %ebx,%ebx
  800466:	7f 31                	jg     800499 <printnum+0x6d>
  800468:	eb 3f                	jmp    8004a9 <printnum+0x7d>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80046a:	83 ec 0c             	sub    $0xc,%esp
  80046d:	57                   	push   %edi
  80046e:	4b                   	dec    %ebx
  80046f:	53                   	push   %ebx
  800470:	50                   	push   %eax
  800471:	83 ec 08             	sub    $0x8,%esp
  800474:	ff 75 d4             	pushl  -0x2c(%ebp)
  800477:	ff 75 d0             	pushl  -0x30(%ebp)
  80047a:	ff 75 dc             	pushl  -0x24(%ebp)
  80047d:	ff 75 d8             	pushl  -0x28(%ebp)
  800480:	e8 f7 1b 00 00       	call   80207c <__udivdi3>
  800485:	83 c4 18             	add    $0x18,%esp
  800488:	52                   	push   %edx
  800489:	50                   	push   %eax
  80048a:	89 f2                	mov    %esi,%edx
  80048c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80048f:	e8 98 ff ff ff       	call   80042c <printnum>
  800494:	83 c4 20             	add    $0x20,%esp
  800497:	eb 10                	jmp    8004a9 <printnum+0x7d>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800499:	83 ec 08             	sub    $0x8,%esp
  80049c:	56                   	push   %esi
  80049d:	57                   	push   %edi
  80049e:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8004a1:	4b                   	dec    %ebx
  8004a2:	83 c4 10             	add    $0x10,%esp
  8004a5:	85 db                	test   %ebx,%ebx
  8004a7:	7f f0                	jg     800499 <printnum+0x6d>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8004a9:	83 ec 08             	sub    $0x8,%esp
  8004ac:	56                   	push   %esi
  8004ad:	83 ec 04             	sub    $0x4,%esp
  8004b0:	ff 75 d4             	pushl  -0x2c(%ebp)
  8004b3:	ff 75 d0             	pushl  -0x30(%ebp)
  8004b6:	ff 75 dc             	pushl  -0x24(%ebp)
  8004b9:	ff 75 d8             	pushl  -0x28(%ebp)
  8004bc:	e8 d7 1c 00 00       	call   802198 <__umoddi3>
  8004c1:	83 c4 14             	add    $0x14,%esp
  8004c4:	0f be 80 9b 23 80 00 	movsbl 0x80239b(%eax),%eax
  8004cb:	50                   	push   %eax
  8004cc:	ff 55 e4             	call   *-0x1c(%ebp)
  8004cf:	83 c4 10             	add    $0x10,%esp
}
  8004d2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8004d5:	5b                   	pop    %ebx
  8004d6:	5e                   	pop    %esi
  8004d7:	5f                   	pop    %edi
  8004d8:	c9                   	leave  
  8004d9:	c3                   	ret    

008004da <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8004da:	55                   	push   %ebp
  8004db:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8004dd:	83 fa 01             	cmp    $0x1,%edx
  8004e0:	7e 0e                	jle    8004f0 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8004e2:	8b 10                	mov    (%eax),%edx
  8004e4:	8d 4a 08             	lea    0x8(%edx),%ecx
  8004e7:	89 08                	mov    %ecx,(%eax)
  8004e9:	8b 02                	mov    (%edx),%eax
  8004eb:	8b 52 04             	mov    0x4(%edx),%edx
  8004ee:	eb 22                	jmp    800512 <getuint+0x38>
	else if (lflag)
  8004f0:	85 d2                	test   %edx,%edx
  8004f2:	74 10                	je     800504 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8004f4:	8b 10                	mov    (%eax),%edx
  8004f6:	8d 4a 04             	lea    0x4(%edx),%ecx
  8004f9:	89 08                	mov    %ecx,(%eax)
  8004fb:	8b 02                	mov    (%edx),%eax
  8004fd:	ba 00 00 00 00       	mov    $0x0,%edx
  800502:	eb 0e                	jmp    800512 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800504:	8b 10                	mov    (%eax),%edx
  800506:	8d 4a 04             	lea    0x4(%edx),%ecx
  800509:	89 08                	mov    %ecx,(%eax)
  80050b:	8b 02                	mov    (%edx),%eax
  80050d:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800512:	c9                   	leave  
  800513:	c3                   	ret    

00800514 <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
  800514:	55                   	push   %ebp
  800515:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800517:	83 fa 01             	cmp    $0x1,%edx
  80051a:	7e 0e                	jle    80052a <getint+0x16>
		return va_arg(*ap, long long);
  80051c:	8b 10                	mov    (%eax),%edx
  80051e:	8d 4a 08             	lea    0x8(%edx),%ecx
  800521:	89 08                	mov    %ecx,(%eax)
  800523:	8b 02                	mov    (%edx),%eax
  800525:	8b 52 04             	mov    0x4(%edx),%edx
  800528:	eb 1a                	jmp    800544 <getint+0x30>
	else if (lflag)
  80052a:	85 d2                	test   %edx,%edx
  80052c:	74 0c                	je     80053a <getint+0x26>
		return va_arg(*ap, long);
  80052e:	8b 10                	mov    (%eax),%edx
  800530:	8d 4a 04             	lea    0x4(%edx),%ecx
  800533:	89 08                	mov    %ecx,(%eax)
  800535:	8b 02                	mov    (%edx),%eax
  800537:	99                   	cltd   
  800538:	eb 0a                	jmp    800544 <getint+0x30>
	else
		return va_arg(*ap, int);
  80053a:	8b 10                	mov    (%eax),%edx
  80053c:	8d 4a 04             	lea    0x4(%edx),%ecx
  80053f:	89 08                	mov    %ecx,(%eax)
  800541:	8b 02                	mov    (%edx),%eax
  800543:	99                   	cltd   
}
  800544:	c9                   	leave  
  800545:	c3                   	ret    

00800546 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800546:	55                   	push   %ebp
  800547:	89 e5                	mov    %esp,%ebp
  800549:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80054c:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  80054f:	8b 10                	mov    (%eax),%edx
  800551:	3b 50 04             	cmp    0x4(%eax),%edx
  800554:	73 08                	jae    80055e <sprintputch+0x18>
		*b->buf++ = ch;
  800556:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800559:	88 0a                	mov    %cl,(%edx)
  80055b:	42                   	inc    %edx
  80055c:	89 10                	mov    %edx,(%eax)
}
  80055e:	c9                   	leave  
  80055f:	c3                   	ret    

00800560 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800560:	55                   	push   %ebp
  800561:	89 e5                	mov    %esp,%ebp
  800563:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800566:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800569:	50                   	push   %eax
  80056a:	ff 75 10             	pushl  0x10(%ebp)
  80056d:	ff 75 0c             	pushl  0xc(%ebp)
  800570:	ff 75 08             	pushl  0x8(%ebp)
  800573:	e8 05 00 00 00       	call   80057d <vprintfmt>
	va_end(ap);
  800578:	83 c4 10             	add    $0x10,%esp
}
  80057b:	c9                   	leave  
  80057c:	c3                   	ret    

0080057d <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80057d:	55                   	push   %ebp
  80057e:	89 e5                	mov    %esp,%ebp
  800580:	57                   	push   %edi
  800581:	56                   	push   %esi
  800582:	53                   	push   %ebx
  800583:	83 ec 2c             	sub    $0x2c,%esp
  800586:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800589:	8b 75 10             	mov    0x10(%ebp),%esi
  80058c:	eb 13                	jmp    8005a1 <vprintfmt+0x24>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  80058e:	85 c0                	test   %eax,%eax
  800590:	0f 84 6d 03 00 00    	je     800903 <vprintfmt+0x386>
				return;
			putch(ch, putdat);
  800596:	83 ec 08             	sub    $0x8,%esp
  800599:	57                   	push   %edi
  80059a:	50                   	push   %eax
  80059b:	ff 55 08             	call   *0x8(%ebp)
  80059e:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8005a1:	0f b6 06             	movzbl (%esi),%eax
  8005a4:	46                   	inc    %esi
  8005a5:	83 f8 25             	cmp    $0x25,%eax
  8005a8:	75 e4                	jne    80058e <vprintfmt+0x11>
  8005aa:	c6 45 dc 20          	movb   $0x20,-0x24(%ebp)
  8005ae:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  8005b5:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
  8005bc:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  8005c3:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005c8:	eb 28                	jmp    8005f2 <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005ca:	89 de                	mov    %ebx,%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  8005cc:	c6 45 dc 2d          	movb   $0x2d,-0x24(%ebp)
  8005d0:	eb 20                	jmp    8005f2 <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005d2:	89 de                	mov    %ebx,%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8005d4:	c6 45 dc 30          	movb   $0x30,-0x24(%ebp)
  8005d8:	eb 18                	jmp    8005f2 <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005da:	89 de                	mov    %ebx,%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  8005dc:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  8005e3:	eb 0d                	jmp    8005f2 <vprintfmt+0x75>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  8005e5:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8005e8:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8005eb:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005f2:	8a 06                	mov    (%esi),%al
  8005f4:	0f b6 d0             	movzbl %al,%edx
  8005f7:	8d 5e 01             	lea    0x1(%esi),%ebx
  8005fa:	83 e8 23             	sub    $0x23,%eax
  8005fd:	3c 55                	cmp    $0x55,%al
  8005ff:	0f 87 e0 02 00 00    	ja     8008e5 <vprintfmt+0x368>
  800605:	0f b6 c0             	movzbl %al,%eax
  800608:	ff 24 85 e0 24 80 00 	jmp    *0x8024e0(,%eax,4)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80060f:	83 ea 30             	sub    $0x30,%edx
  800612:	89 55 d4             	mov    %edx,-0x2c(%ebp)
				ch = *fmt;
  800615:	0f be 03             	movsbl (%ebx),%eax
				if (ch < '0' || ch > '9')
  800618:	8d 50 d0             	lea    -0x30(%eax),%edx
  80061b:	83 fa 09             	cmp    $0x9,%edx
  80061e:	77 44                	ja     800664 <vprintfmt+0xe7>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800620:	89 de                	mov    %ebx,%esi
  800622:	8b 55 d4             	mov    -0x2c(%ebp),%edx
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800625:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
  800626:	8d 14 92             	lea    (%edx,%edx,4),%edx
  800629:	8d 54 50 d0          	lea    -0x30(%eax,%edx,2),%edx
				ch = *fmt;
  80062d:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  800630:	8d 58 d0             	lea    -0x30(%eax),%ebx
  800633:	83 fb 09             	cmp    $0x9,%ebx
  800636:	76 ed                	jbe    800625 <vprintfmt+0xa8>
  800638:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  80063b:	eb 29                	jmp    800666 <vprintfmt+0xe9>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  80063d:	8b 45 14             	mov    0x14(%ebp),%eax
  800640:	8d 50 04             	lea    0x4(%eax),%edx
  800643:	89 55 14             	mov    %edx,0x14(%ebp)
  800646:	8b 00                	mov    (%eax),%eax
  800648:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80064b:	89 de                	mov    %ebx,%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  80064d:	eb 17                	jmp    800666 <vprintfmt+0xe9>

		case '.':
			if (width < 0)
  80064f:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800653:	78 85                	js     8005da <vprintfmt+0x5d>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800655:	89 de                	mov    %ebx,%esi
  800657:	eb 99                	jmp    8005f2 <vprintfmt+0x75>
  800659:	89 de                	mov    %ebx,%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  80065b:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
			goto reswitch;
  800662:	eb 8e                	jmp    8005f2 <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800664:	89 de                	mov    %ebx,%esi
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  800666:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80066a:	79 86                	jns    8005f2 <vprintfmt+0x75>
  80066c:	e9 74 ff ff ff       	jmp    8005e5 <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800671:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800672:	89 de                	mov    %ebx,%esi
  800674:	e9 79 ff ff ff       	jmp    8005f2 <vprintfmt+0x75>
  800679:	89 5d d8             	mov    %ebx,-0x28(%ebp)
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80067c:	8b 45 14             	mov    0x14(%ebp),%eax
  80067f:	8d 50 04             	lea    0x4(%eax),%edx
  800682:	89 55 14             	mov    %edx,0x14(%ebp)
  800685:	83 ec 08             	sub    $0x8,%esp
  800688:	57                   	push   %edi
  800689:	ff 30                	pushl  (%eax)
  80068b:	ff 55 08             	call   *0x8(%ebp)
			break;
  80068e:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800691:	8b 75 d8             	mov    -0x28(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800694:	e9 08 ff ff ff       	jmp    8005a1 <vprintfmt+0x24>
  800699:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// error message
		case 'e':
			err = va_arg(ap, int);
  80069c:	8b 45 14             	mov    0x14(%ebp),%eax
  80069f:	8d 50 04             	lea    0x4(%eax),%edx
  8006a2:	89 55 14             	mov    %edx,0x14(%ebp)
  8006a5:	8b 00                	mov    (%eax),%eax
  8006a7:	85 c0                	test   %eax,%eax
  8006a9:	79 02                	jns    8006ad <vprintfmt+0x130>
  8006ab:	f7 d8                	neg    %eax
  8006ad:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8006af:	83 f8 0f             	cmp    $0xf,%eax
  8006b2:	7f 0b                	jg     8006bf <vprintfmt+0x142>
  8006b4:	8b 04 85 40 26 80 00 	mov    0x802640(,%eax,4),%eax
  8006bb:	85 c0                	test   %eax,%eax
  8006bd:	75 1a                	jne    8006d9 <vprintfmt+0x15c>
				printfmt(putch, putdat, "error %d", err);
  8006bf:	52                   	push   %edx
  8006c0:	68 b3 23 80 00       	push   $0x8023b3
  8006c5:	57                   	push   %edi
  8006c6:	ff 75 08             	pushl  0x8(%ebp)
  8006c9:	e8 92 fe ff ff       	call   800560 <printfmt>
  8006ce:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006d1:	8b 75 d8             	mov    -0x28(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8006d4:	e9 c8 fe ff ff       	jmp    8005a1 <vprintfmt+0x24>
			else
				printfmt(putch, putdat, "%s", p);
  8006d9:	50                   	push   %eax
  8006da:	68 75 27 80 00       	push   $0x802775
  8006df:	57                   	push   %edi
  8006e0:	ff 75 08             	pushl  0x8(%ebp)
  8006e3:	e8 78 fe ff ff       	call   800560 <printfmt>
  8006e8:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006eb:	8b 75 d8             	mov    -0x28(%ebp),%esi
  8006ee:	e9 ae fe ff ff       	jmp    8005a1 <vprintfmt+0x24>
  8006f3:	89 5d d8             	mov    %ebx,-0x28(%ebp)
  8006f6:	89 de                	mov    %ebx,%esi
  8006f8:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  8006fb:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8006fe:	8b 45 14             	mov    0x14(%ebp),%eax
  800701:	8d 50 04             	lea    0x4(%eax),%edx
  800704:	89 55 14             	mov    %edx,0x14(%ebp)
  800707:	8b 00                	mov    (%eax),%eax
  800709:	89 45 d0             	mov    %eax,-0x30(%ebp)
  80070c:	85 c0                	test   %eax,%eax
  80070e:	75 07                	jne    800717 <vprintfmt+0x19a>
				p = "(null)";
  800710:	c7 45 d0 ac 23 80 00 	movl   $0x8023ac,-0x30(%ebp)
			if (width > 0 && padc != '-')
  800717:	85 db                	test   %ebx,%ebx
  800719:	7e 42                	jle    80075d <vprintfmt+0x1e0>
  80071b:	80 7d dc 2d          	cmpb   $0x2d,-0x24(%ebp)
  80071f:	74 3c                	je     80075d <vprintfmt+0x1e0>
				for (width -= strnlen(p, precision); width > 0; width--)
  800721:	83 ec 08             	sub    $0x8,%esp
  800724:	51                   	push   %ecx
  800725:	ff 75 d0             	pushl  -0x30(%ebp)
  800728:	e8 6f 02 00 00       	call   80099c <strnlen>
  80072d:	29 c3                	sub    %eax,%ebx
  80072f:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800732:	83 c4 10             	add    $0x10,%esp
  800735:	85 db                	test   %ebx,%ebx
  800737:	7e 24                	jle    80075d <vprintfmt+0x1e0>
					putch(padc, putdat);
  800739:	0f be 5d dc          	movsbl -0x24(%ebp),%ebx
  80073d:	89 75 dc             	mov    %esi,-0x24(%ebp)
  800740:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  800743:	83 ec 08             	sub    $0x8,%esp
  800746:	57                   	push   %edi
  800747:	53                   	push   %ebx
  800748:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80074b:	4e                   	dec    %esi
  80074c:	83 c4 10             	add    $0x10,%esp
  80074f:	85 f6                	test   %esi,%esi
  800751:	7f f0                	jg     800743 <vprintfmt+0x1c6>
  800753:	8b 75 dc             	mov    -0x24(%ebp),%esi
  800756:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80075d:	8b 55 d0             	mov    -0x30(%ebp),%edx
  800760:	0f be 02             	movsbl (%edx),%eax
  800763:	85 c0                	test   %eax,%eax
  800765:	75 47                	jne    8007ae <vprintfmt+0x231>
  800767:	eb 37                	jmp    8007a0 <vprintfmt+0x223>
				if (altflag && (ch < ' ' || ch > '~'))
  800769:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80076d:	74 16                	je     800785 <vprintfmt+0x208>
  80076f:	8d 50 e0             	lea    -0x20(%eax),%edx
  800772:	83 fa 5e             	cmp    $0x5e,%edx
  800775:	76 0e                	jbe    800785 <vprintfmt+0x208>
					putch('?', putdat);
  800777:	83 ec 08             	sub    $0x8,%esp
  80077a:	57                   	push   %edi
  80077b:	6a 3f                	push   $0x3f
  80077d:	ff 55 08             	call   *0x8(%ebp)
  800780:	83 c4 10             	add    $0x10,%esp
  800783:	eb 0b                	jmp    800790 <vprintfmt+0x213>
				else
					putch(ch, putdat);
  800785:	83 ec 08             	sub    $0x8,%esp
  800788:	57                   	push   %edi
  800789:	50                   	push   %eax
  80078a:	ff 55 08             	call   *0x8(%ebp)
  80078d:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800790:	ff 4d e4             	decl   -0x1c(%ebp)
  800793:	0f be 03             	movsbl (%ebx),%eax
  800796:	85 c0                	test   %eax,%eax
  800798:	74 03                	je     80079d <vprintfmt+0x220>
  80079a:	43                   	inc    %ebx
  80079b:	eb 1b                	jmp    8007b8 <vprintfmt+0x23b>
  80079d:	8b 75 dc             	mov    -0x24(%ebp),%esi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8007a0:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8007a4:	7f 1e                	jg     8007c4 <vprintfmt+0x247>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007a6:	8b 75 d8             	mov    -0x28(%ebp),%esi
  8007a9:	e9 f3 fd ff ff       	jmp    8005a1 <vprintfmt+0x24>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8007ae:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  8007b1:	43                   	inc    %ebx
  8007b2:	89 75 dc             	mov    %esi,-0x24(%ebp)
  8007b5:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  8007b8:	85 f6                	test   %esi,%esi
  8007ba:	78 ad                	js     800769 <vprintfmt+0x1ec>
  8007bc:	4e                   	dec    %esi
  8007bd:	79 aa                	jns    800769 <vprintfmt+0x1ec>
  8007bf:	8b 75 dc             	mov    -0x24(%ebp),%esi
  8007c2:	eb dc                	jmp    8007a0 <vprintfmt+0x223>
  8007c4:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8007c7:	83 ec 08             	sub    $0x8,%esp
  8007ca:	57                   	push   %edi
  8007cb:	6a 20                	push   $0x20
  8007cd:	ff 55 08             	call   *0x8(%ebp)
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8007d0:	4b                   	dec    %ebx
  8007d1:	83 c4 10             	add    $0x10,%esp
  8007d4:	85 db                	test   %ebx,%ebx
  8007d6:	7f ef                	jg     8007c7 <vprintfmt+0x24a>
  8007d8:	e9 c4 fd ff ff       	jmp    8005a1 <vprintfmt+0x24>
  8007dd:	89 5d d8             	mov    %ebx,-0x28(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8007e0:	89 ca                	mov    %ecx,%edx
  8007e2:	8d 45 14             	lea    0x14(%ebp),%eax
  8007e5:	e8 2a fd ff ff       	call   800514 <getint>
  8007ea:	89 c3                	mov    %eax,%ebx
  8007ec:	89 d6                	mov    %edx,%esi
			if ((long long) num < 0) {
  8007ee:	85 d2                	test   %edx,%edx
  8007f0:	78 0a                	js     8007fc <vprintfmt+0x27f>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8007f2:	b8 0a 00 00 00       	mov    $0xa,%eax
  8007f7:	e9 b0 00 00 00       	jmp    8008ac <vprintfmt+0x32f>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  8007fc:	83 ec 08             	sub    $0x8,%esp
  8007ff:	57                   	push   %edi
  800800:	6a 2d                	push   $0x2d
  800802:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  800805:	f7 db                	neg    %ebx
  800807:	83 d6 00             	adc    $0x0,%esi
  80080a:	f7 de                	neg    %esi
  80080c:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  80080f:	b8 0a 00 00 00       	mov    $0xa,%eax
  800814:	e9 93 00 00 00       	jmp    8008ac <vprintfmt+0x32f>
  800819:	89 5d d8             	mov    %ebx,-0x28(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  80081c:	89 ca                	mov    %ecx,%edx
  80081e:	8d 45 14             	lea    0x14(%ebp),%eax
  800821:	e8 b4 fc ff ff       	call   8004da <getuint>
  800826:	89 c3                	mov    %eax,%ebx
  800828:	89 d6                	mov    %edx,%esi
			base = 10;
  80082a:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  80082f:	eb 7b                	jmp    8008ac <vprintfmt+0x32f>
  800831:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// (unsigned) octal
		case 'o':
            // (MIT 6.828, lab1, Ex.8)  my code : 
            num = getint(&ap, lflag);
  800834:	89 ca                	mov    %ecx,%edx
  800836:	8d 45 14             	lea    0x14(%ebp),%eax
  800839:	e8 d6 fc ff ff       	call   800514 <getint>
  80083e:	89 c3                	mov    %eax,%ebx
  800840:	89 d6                	mov    %edx,%esi
            if ((long long) num < 0) {
  800842:	85 d2                	test   %edx,%edx
  800844:	78 07                	js     80084d <vprintfmt+0x2d0>
                putch('-', putdat);
                num = -(long long) num;
            }
            base = 8;
  800846:	b8 08 00 00 00       	mov    $0x8,%eax
  80084b:	eb 5f                	jmp    8008ac <vprintfmt+0x32f>
		// (unsigned) octal
		case 'o':
            // (MIT 6.828, lab1, Ex.8)  my code : 
            num = getint(&ap, lflag);
            if ((long long) num < 0) {
                putch('-', putdat);
  80084d:	83 ec 08             	sub    $0x8,%esp
  800850:	57                   	push   %edi
  800851:	6a 2d                	push   $0x2d
  800853:	ff 55 08             	call   *0x8(%ebp)
                num = -(long long) num;
  800856:	f7 db                	neg    %ebx
  800858:	83 d6 00             	adc    $0x0,%esi
  80085b:	f7 de                	neg    %esi
  80085d:	83 c4 10             	add    $0x10,%esp
            }
            base = 8;
  800860:	b8 08 00 00 00       	mov    $0x8,%eax
  800865:	eb 45                	jmp    8008ac <vprintfmt+0x32f>
  800867:	89 5d d8             	mov    %ebx,-0x28(%ebp)
            goto number;

        // pointer
		case 'p':
			putch('0', putdat);
  80086a:	83 ec 08             	sub    $0x8,%esp
  80086d:	57                   	push   %edi
  80086e:	6a 30                	push   $0x30
  800870:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  800873:	83 c4 08             	add    $0x8,%esp
  800876:	57                   	push   %edi
  800877:	6a 78                	push   $0x78
  800879:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  80087c:	8b 45 14             	mov    0x14(%ebp),%eax
  80087f:	8d 50 04             	lea    0x4(%eax),%edx
  800882:	89 55 14             	mov    %edx,0x14(%ebp)

        // pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800885:	8b 18                	mov    (%eax),%ebx
  800887:	be 00 00 00 00       	mov    $0x0,%esi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  80088c:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  80088f:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  800894:	eb 16                	jmp    8008ac <vprintfmt+0x32f>
  800896:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800899:	89 ca                	mov    %ecx,%edx
  80089b:	8d 45 14             	lea    0x14(%ebp),%eax
  80089e:	e8 37 fc ff ff       	call   8004da <getuint>
  8008a3:	89 c3                	mov    %eax,%ebx
  8008a5:	89 d6                	mov    %edx,%esi
			base = 16;
  8008a7:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  8008ac:	83 ec 0c             	sub    $0xc,%esp
  8008af:	0f be 55 dc          	movsbl -0x24(%ebp),%edx
  8008b3:	52                   	push   %edx
  8008b4:	ff 75 e4             	pushl  -0x1c(%ebp)
  8008b7:	50                   	push   %eax
  8008b8:	56                   	push   %esi
  8008b9:	53                   	push   %ebx
  8008ba:	89 fa                	mov    %edi,%edx
  8008bc:	8b 45 08             	mov    0x8(%ebp),%eax
  8008bf:	e8 68 fb ff ff       	call   80042c <printnum>
			break;
  8008c4:	83 c4 20             	add    $0x20,%esp
  8008c7:	8b 75 d8             	mov    -0x28(%ebp),%esi
  8008ca:	e9 d2 fc ff ff       	jmp    8005a1 <vprintfmt+0x24>
  8008cf:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8008d2:	83 ec 08             	sub    $0x8,%esp
  8008d5:	57                   	push   %edi
  8008d6:	52                   	push   %edx
  8008d7:	ff 55 08             	call   *0x8(%ebp)
			break;
  8008da:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8008dd:	8b 75 d8             	mov    -0x28(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8008e0:	e9 bc fc ff ff       	jmp    8005a1 <vprintfmt+0x24>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8008e5:	83 ec 08             	sub    $0x8,%esp
  8008e8:	57                   	push   %edi
  8008e9:	6a 25                	push   $0x25
  8008eb:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  8008ee:	83 c4 10             	add    $0x10,%esp
  8008f1:	eb 02                	jmp    8008f5 <vprintfmt+0x378>
  8008f3:	89 c6                	mov    %eax,%esi
  8008f5:	8d 46 ff             	lea    -0x1(%esi),%eax
  8008f8:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  8008fc:	75 f5                	jne    8008f3 <vprintfmt+0x376>
  8008fe:	e9 9e fc ff ff       	jmp    8005a1 <vprintfmt+0x24>
				/* do nothing */;
			break;
		}
	}
}
  800903:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800906:	5b                   	pop    %ebx
  800907:	5e                   	pop    %esi
  800908:	5f                   	pop    %edi
  800909:	c9                   	leave  
  80090a:	c3                   	ret    

0080090b <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80090b:	55                   	push   %ebp
  80090c:	89 e5                	mov    %esp,%ebp
  80090e:	83 ec 18             	sub    $0x18,%esp
  800911:	8b 45 08             	mov    0x8(%ebp),%eax
  800914:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800917:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80091a:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80091e:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800921:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800928:	85 c0                	test   %eax,%eax
  80092a:	74 26                	je     800952 <vsnprintf+0x47>
  80092c:	85 d2                	test   %edx,%edx
  80092e:	7e 29                	jle    800959 <vsnprintf+0x4e>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800930:	ff 75 14             	pushl  0x14(%ebp)
  800933:	ff 75 10             	pushl  0x10(%ebp)
  800936:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800939:	50                   	push   %eax
  80093a:	68 46 05 80 00       	push   $0x800546
  80093f:	e8 39 fc ff ff       	call   80057d <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800944:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800947:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80094a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80094d:	83 c4 10             	add    $0x10,%esp
  800950:	eb 0c                	jmp    80095e <vsnprintf+0x53>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800952:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800957:	eb 05                	jmp    80095e <vsnprintf+0x53>
  800959:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  80095e:	c9                   	leave  
  80095f:	c3                   	ret    

00800960 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800960:	55                   	push   %ebp
  800961:	89 e5                	mov    %esp,%ebp
  800963:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800966:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800969:	50                   	push   %eax
  80096a:	ff 75 10             	pushl  0x10(%ebp)
  80096d:	ff 75 0c             	pushl  0xc(%ebp)
  800970:	ff 75 08             	pushl  0x8(%ebp)
  800973:	e8 93 ff ff ff       	call   80090b <vsnprintf>
	va_end(ap);

	return rc;
}
  800978:	c9                   	leave  
  800979:	c3                   	ret    
	...

0080097c <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80097c:	55                   	push   %ebp
  80097d:	89 e5                	mov    %esp,%ebp
  80097f:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800982:	80 3a 00             	cmpb   $0x0,(%edx)
  800985:	74 0e                	je     800995 <strlen+0x19>
  800987:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  80098c:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  80098d:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800991:	75 f9                	jne    80098c <strlen+0x10>
  800993:	eb 05                	jmp    80099a <strlen+0x1e>
  800995:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  80099a:	c9                   	leave  
  80099b:	c3                   	ret    

0080099c <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80099c:	55                   	push   %ebp
  80099d:	89 e5                	mov    %esp,%ebp
  80099f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009a2:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8009a5:	85 d2                	test   %edx,%edx
  8009a7:	74 17                	je     8009c0 <strnlen+0x24>
  8009a9:	80 39 00             	cmpb   $0x0,(%ecx)
  8009ac:	74 19                	je     8009c7 <strnlen+0x2b>
  8009ae:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  8009b3:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8009b4:	39 d0                	cmp    %edx,%eax
  8009b6:	74 14                	je     8009cc <strnlen+0x30>
  8009b8:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8009bc:	75 f5                	jne    8009b3 <strnlen+0x17>
  8009be:	eb 0c                	jmp    8009cc <strnlen+0x30>
  8009c0:	b8 00 00 00 00       	mov    $0x0,%eax
  8009c5:	eb 05                	jmp    8009cc <strnlen+0x30>
  8009c7:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  8009cc:	c9                   	leave  
  8009cd:	c3                   	ret    

008009ce <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8009ce:	55                   	push   %ebp
  8009cf:	89 e5                	mov    %esp,%ebp
  8009d1:	53                   	push   %ebx
  8009d2:	8b 45 08             	mov    0x8(%ebp),%eax
  8009d5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8009d8:	ba 00 00 00 00       	mov    $0x0,%edx
  8009dd:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  8009e0:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  8009e3:	42                   	inc    %edx
  8009e4:	84 c9                	test   %cl,%cl
  8009e6:	75 f5                	jne    8009dd <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  8009e8:	5b                   	pop    %ebx
  8009e9:	c9                   	leave  
  8009ea:	c3                   	ret    

008009eb <strcat>:

char *
strcat(char *dst, const char *src)
{
  8009eb:	55                   	push   %ebp
  8009ec:	89 e5                	mov    %esp,%ebp
  8009ee:	53                   	push   %ebx
  8009ef:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8009f2:	53                   	push   %ebx
  8009f3:	e8 84 ff ff ff       	call   80097c <strlen>
  8009f8:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8009fb:	ff 75 0c             	pushl  0xc(%ebp)
  8009fe:	8d 04 03             	lea    (%ebx,%eax,1),%eax
  800a01:	50                   	push   %eax
  800a02:	e8 c7 ff ff ff       	call   8009ce <strcpy>
	return dst;
}
  800a07:	89 d8                	mov    %ebx,%eax
  800a09:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800a0c:	c9                   	leave  
  800a0d:	c3                   	ret    

00800a0e <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800a0e:	55                   	push   %ebp
  800a0f:	89 e5                	mov    %esp,%ebp
  800a11:	56                   	push   %esi
  800a12:	53                   	push   %ebx
  800a13:	8b 45 08             	mov    0x8(%ebp),%eax
  800a16:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a19:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800a1c:	85 f6                	test   %esi,%esi
  800a1e:	74 15                	je     800a35 <strncpy+0x27>
  800a20:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
  800a25:	8a 1a                	mov    (%edx),%bl
  800a27:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800a2a:	80 3a 01             	cmpb   $0x1,(%edx)
  800a2d:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800a30:	41                   	inc    %ecx
  800a31:	39 ce                	cmp    %ecx,%esi
  800a33:	77 f0                	ja     800a25 <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800a35:	5b                   	pop    %ebx
  800a36:	5e                   	pop    %esi
  800a37:	c9                   	leave  
  800a38:	c3                   	ret    

00800a39 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800a39:	55                   	push   %ebp
  800a3a:	89 e5                	mov    %esp,%ebp
  800a3c:	57                   	push   %edi
  800a3d:	56                   	push   %esi
  800a3e:	53                   	push   %ebx
  800a3f:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a42:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800a45:	8b 75 10             	mov    0x10(%ebp),%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800a48:	85 f6                	test   %esi,%esi
  800a4a:	74 32                	je     800a7e <strlcpy+0x45>
		while (--size > 0 && *src != '\0')
  800a4c:	83 fe 01             	cmp    $0x1,%esi
  800a4f:	74 22                	je     800a73 <strlcpy+0x3a>
  800a51:	8a 0b                	mov    (%ebx),%cl
  800a53:	84 c9                	test   %cl,%cl
  800a55:	74 20                	je     800a77 <strlcpy+0x3e>
  800a57:	89 f8                	mov    %edi,%eax
  800a59:	ba 00 00 00 00       	mov    $0x0,%edx
	}
	return ret;
}

size_t
strlcpy(char *dst, const char *src, size_t size)
  800a5e:	83 ee 02             	sub    $0x2,%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800a61:	88 08                	mov    %cl,(%eax)
  800a63:	40                   	inc    %eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800a64:	39 f2                	cmp    %esi,%edx
  800a66:	74 11                	je     800a79 <strlcpy+0x40>
  800a68:	8a 4c 13 01          	mov    0x1(%ebx,%edx,1),%cl
  800a6c:	42                   	inc    %edx
  800a6d:	84 c9                	test   %cl,%cl
  800a6f:	75 f0                	jne    800a61 <strlcpy+0x28>
  800a71:	eb 06                	jmp    800a79 <strlcpy+0x40>
  800a73:	89 f8                	mov    %edi,%eax
  800a75:	eb 02                	jmp    800a79 <strlcpy+0x40>
  800a77:	89 f8                	mov    %edi,%eax
			*dst++ = *src++;
		*dst = '\0';
  800a79:	c6 00 00             	movb   $0x0,(%eax)
  800a7c:	eb 02                	jmp    800a80 <strlcpy+0x47>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800a7e:	89 f8                	mov    %edi,%eax
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
		*dst = '\0';
	}
	return dst - dst_in;
  800a80:	29 f8                	sub    %edi,%eax
}
  800a82:	5b                   	pop    %ebx
  800a83:	5e                   	pop    %esi
  800a84:	5f                   	pop    %edi
  800a85:	c9                   	leave  
  800a86:	c3                   	ret    

00800a87 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800a87:	55                   	push   %ebp
  800a88:	89 e5                	mov    %esp,%ebp
  800a8a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a8d:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800a90:	8a 01                	mov    (%ecx),%al
  800a92:	84 c0                	test   %al,%al
  800a94:	74 10                	je     800aa6 <strcmp+0x1f>
  800a96:	3a 02                	cmp    (%edx),%al
  800a98:	75 0c                	jne    800aa6 <strcmp+0x1f>
		p++, q++;
  800a9a:	41                   	inc    %ecx
  800a9b:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800a9c:	8a 01                	mov    (%ecx),%al
  800a9e:	84 c0                	test   %al,%al
  800aa0:	74 04                	je     800aa6 <strcmp+0x1f>
  800aa2:	3a 02                	cmp    (%edx),%al
  800aa4:	74 f4                	je     800a9a <strcmp+0x13>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800aa6:	0f b6 c0             	movzbl %al,%eax
  800aa9:	0f b6 12             	movzbl (%edx),%edx
  800aac:	29 d0                	sub    %edx,%eax
}
  800aae:	c9                   	leave  
  800aaf:	c3                   	ret    

00800ab0 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800ab0:	55                   	push   %ebp
  800ab1:	89 e5                	mov    %esp,%ebp
  800ab3:	53                   	push   %ebx
  800ab4:	8b 55 08             	mov    0x8(%ebp),%edx
  800ab7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800aba:	8b 45 10             	mov    0x10(%ebp),%eax
	while (n > 0 && *p && *p == *q)
  800abd:	85 c0                	test   %eax,%eax
  800abf:	74 1b                	je     800adc <strncmp+0x2c>
  800ac1:	8a 1a                	mov    (%edx),%bl
  800ac3:	84 db                	test   %bl,%bl
  800ac5:	74 24                	je     800aeb <strncmp+0x3b>
  800ac7:	3a 19                	cmp    (%ecx),%bl
  800ac9:	75 20                	jne    800aeb <strncmp+0x3b>
  800acb:	48                   	dec    %eax
  800acc:	74 15                	je     800ae3 <strncmp+0x33>
		n--, p++, q++;
  800ace:	42                   	inc    %edx
  800acf:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800ad0:	8a 1a                	mov    (%edx),%bl
  800ad2:	84 db                	test   %bl,%bl
  800ad4:	74 15                	je     800aeb <strncmp+0x3b>
  800ad6:	3a 19                	cmp    (%ecx),%bl
  800ad8:	74 f1                	je     800acb <strncmp+0x1b>
  800ada:	eb 0f                	jmp    800aeb <strncmp+0x3b>
		n--, p++, q++;
	if (n == 0)
		return 0;
  800adc:	b8 00 00 00 00       	mov    $0x0,%eax
  800ae1:	eb 05                	jmp    800ae8 <strncmp+0x38>
  800ae3:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800ae8:	5b                   	pop    %ebx
  800ae9:	c9                   	leave  
  800aea:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800aeb:	0f b6 02             	movzbl (%edx),%eax
  800aee:	0f b6 11             	movzbl (%ecx),%edx
  800af1:	29 d0                	sub    %edx,%eax
  800af3:	eb f3                	jmp    800ae8 <strncmp+0x38>

00800af5 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800af5:	55                   	push   %ebp
  800af6:	89 e5                	mov    %esp,%ebp
  800af8:	8b 45 08             	mov    0x8(%ebp),%eax
  800afb:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800afe:	8a 10                	mov    (%eax),%dl
  800b00:	84 d2                	test   %dl,%dl
  800b02:	74 18                	je     800b1c <strchr+0x27>
		if (*s == c)
  800b04:	38 ca                	cmp    %cl,%dl
  800b06:	75 06                	jne    800b0e <strchr+0x19>
  800b08:	eb 17                	jmp    800b21 <strchr+0x2c>
  800b0a:	38 ca                	cmp    %cl,%dl
  800b0c:	74 13                	je     800b21 <strchr+0x2c>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800b0e:	40                   	inc    %eax
  800b0f:	8a 10                	mov    (%eax),%dl
  800b11:	84 d2                	test   %dl,%dl
  800b13:	75 f5                	jne    800b0a <strchr+0x15>
		if (*s == c)
			return (char *) s;
	return 0;
  800b15:	b8 00 00 00 00       	mov    $0x0,%eax
  800b1a:	eb 05                	jmp    800b21 <strchr+0x2c>
  800b1c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b21:	c9                   	leave  
  800b22:	c3                   	ret    

00800b23 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800b23:	55                   	push   %ebp
  800b24:	89 e5                	mov    %esp,%ebp
  800b26:	8b 45 08             	mov    0x8(%ebp),%eax
  800b29:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800b2c:	8a 10                	mov    (%eax),%dl
  800b2e:	84 d2                	test   %dl,%dl
  800b30:	74 11                	je     800b43 <strfind+0x20>
		if (*s == c)
  800b32:	38 ca                	cmp    %cl,%dl
  800b34:	75 06                	jne    800b3c <strfind+0x19>
  800b36:	eb 0b                	jmp    800b43 <strfind+0x20>
  800b38:	38 ca                	cmp    %cl,%dl
  800b3a:	74 07                	je     800b43 <strfind+0x20>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800b3c:	40                   	inc    %eax
  800b3d:	8a 10                	mov    (%eax),%dl
  800b3f:	84 d2                	test   %dl,%dl
  800b41:	75 f5                	jne    800b38 <strfind+0x15>
		if (*s == c)
			break;
	return (char *) s;
}
  800b43:	c9                   	leave  
  800b44:	c3                   	ret    

00800b45 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800b45:	55                   	push   %ebp
  800b46:	89 e5                	mov    %esp,%ebp
  800b48:	57                   	push   %edi
  800b49:	56                   	push   %esi
  800b4a:	53                   	push   %ebx
  800b4b:	8b 7d 08             	mov    0x8(%ebp),%edi
  800b4e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b51:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800b54:	85 c9                	test   %ecx,%ecx
  800b56:	74 30                	je     800b88 <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800b58:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800b5e:	75 25                	jne    800b85 <memset+0x40>
  800b60:	f6 c1 03             	test   $0x3,%cl
  800b63:	75 20                	jne    800b85 <memset+0x40>
		c &= 0xFF;
  800b65:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800b68:	89 d3                	mov    %edx,%ebx
  800b6a:	c1 e3 08             	shl    $0x8,%ebx
  800b6d:	89 d6                	mov    %edx,%esi
  800b6f:	c1 e6 18             	shl    $0x18,%esi
  800b72:	89 d0                	mov    %edx,%eax
  800b74:	c1 e0 10             	shl    $0x10,%eax
  800b77:	09 f0                	or     %esi,%eax
  800b79:	09 d0                	or     %edx,%eax
  800b7b:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800b7d:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800b80:	fc                   	cld    
  800b81:	f3 ab                	rep stos %eax,%es:(%edi)
  800b83:	eb 03                	jmp    800b88 <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800b85:	fc                   	cld    
  800b86:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800b88:	89 f8                	mov    %edi,%eax
  800b8a:	5b                   	pop    %ebx
  800b8b:	5e                   	pop    %esi
  800b8c:	5f                   	pop    %edi
  800b8d:	c9                   	leave  
  800b8e:	c3                   	ret    

00800b8f <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800b8f:	55                   	push   %ebp
  800b90:	89 e5                	mov    %esp,%ebp
  800b92:	57                   	push   %edi
  800b93:	56                   	push   %esi
  800b94:	8b 45 08             	mov    0x8(%ebp),%eax
  800b97:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b9a:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800b9d:	39 c6                	cmp    %eax,%esi
  800b9f:	73 34                	jae    800bd5 <memmove+0x46>
  800ba1:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800ba4:	39 d0                	cmp    %edx,%eax
  800ba6:	73 2d                	jae    800bd5 <memmove+0x46>
		s += n;
		d += n;
  800ba8:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800bab:	f6 c2 03             	test   $0x3,%dl
  800bae:	75 1b                	jne    800bcb <memmove+0x3c>
  800bb0:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800bb6:	75 13                	jne    800bcb <memmove+0x3c>
  800bb8:	f6 c1 03             	test   $0x3,%cl
  800bbb:	75 0e                	jne    800bcb <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800bbd:	83 ef 04             	sub    $0x4,%edi
  800bc0:	8d 72 fc             	lea    -0x4(%edx),%esi
  800bc3:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800bc6:	fd                   	std    
  800bc7:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800bc9:	eb 07                	jmp    800bd2 <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800bcb:	4f                   	dec    %edi
  800bcc:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800bcf:	fd                   	std    
  800bd0:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800bd2:	fc                   	cld    
  800bd3:	eb 20                	jmp    800bf5 <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800bd5:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800bdb:	75 13                	jne    800bf0 <memmove+0x61>
  800bdd:	a8 03                	test   $0x3,%al
  800bdf:	75 0f                	jne    800bf0 <memmove+0x61>
  800be1:	f6 c1 03             	test   $0x3,%cl
  800be4:	75 0a                	jne    800bf0 <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800be6:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800be9:	89 c7                	mov    %eax,%edi
  800beb:	fc                   	cld    
  800bec:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800bee:	eb 05                	jmp    800bf5 <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800bf0:	89 c7                	mov    %eax,%edi
  800bf2:	fc                   	cld    
  800bf3:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800bf5:	5e                   	pop    %esi
  800bf6:	5f                   	pop    %edi
  800bf7:	c9                   	leave  
  800bf8:	c3                   	ret    

00800bf9 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800bf9:	55                   	push   %ebp
  800bfa:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800bfc:	ff 75 10             	pushl  0x10(%ebp)
  800bff:	ff 75 0c             	pushl  0xc(%ebp)
  800c02:	ff 75 08             	pushl  0x8(%ebp)
  800c05:	e8 85 ff ff ff       	call   800b8f <memmove>
}
  800c0a:	c9                   	leave  
  800c0b:	c3                   	ret    

00800c0c <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800c0c:	55                   	push   %ebp
  800c0d:	89 e5                	mov    %esp,%ebp
  800c0f:	57                   	push   %edi
  800c10:	56                   	push   %esi
  800c11:	53                   	push   %ebx
  800c12:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800c15:	8b 75 0c             	mov    0xc(%ebp),%esi
  800c18:	8b 7d 10             	mov    0x10(%ebp),%edi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800c1b:	85 ff                	test   %edi,%edi
  800c1d:	74 32                	je     800c51 <memcmp+0x45>
		if (*s1 != *s2)
  800c1f:	8a 03                	mov    (%ebx),%al
  800c21:	8a 0e                	mov    (%esi),%cl
  800c23:	38 c8                	cmp    %cl,%al
  800c25:	74 19                	je     800c40 <memcmp+0x34>
  800c27:	eb 0d                	jmp    800c36 <memcmp+0x2a>
  800c29:	8a 44 13 01          	mov    0x1(%ebx,%edx,1),%al
  800c2d:	8a 4c 16 01          	mov    0x1(%esi,%edx,1),%cl
  800c31:	42                   	inc    %edx
  800c32:	38 c8                	cmp    %cl,%al
  800c34:	74 10                	je     800c46 <memcmp+0x3a>
			return (int) *s1 - (int) *s2;
  800c36:	0f b6 c0             	movzbl %al,%eax
  800c39:	0f b6 c9             	movzbl %cl,%ecx
  800c3c:	29 c8                	sub    %ecx,%eax
  800c3e:	eb 16                	jmp    800c56 <memcmp+0x4a>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800c40:	4f                   	dec    %edi
  800c41:	ba 00 00 00 00       	mov    $0x0,%edx
  800c46:	39 fa                	cmp    %edi,%edx
  800c48:	75 df                	jne    800c29 <memcmp+0x1d>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800c4a:	b8 00 00 00 00       	mov    $0x0,%eax
  800c4f:	eb 05                	jmp    800c56 <memcmp+0x4a>
  800c51:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800c56:	5b                   	pop    %ebx
  800c57:	5e                   	pop    %esi
  800c58:	5f                   	pop    %edi
  800c59:	c9                   	leave  
  800c5a:	c3                   	ret    

00800c5b <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800c5b:	55                   	push   %ebp
  800c5c:	89 e5                	mov    %esp,%ebp
  800c5e:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800c61:	89 c2                	mov    %eax,%edx
  800c63:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800c66:	39 d0                	cmp    %edx,%eax
  800c68:	73 12                	jae    800c7c <memfind+0x21>
		if (*(const unsigned char *) s == (unsigned char) c)
  800c6a:	8a 4d 0c             	mov    0xc(%ebp),%cl
  800c6d:	38 08                	cmp    %cl,(%eax)
  800c6f:	75 06                	jne    800c77 <memfind+0x1c>
  800c71:	eb 09                	jmp    800c7c <memfind+0x21>
  800c73:	38 08                	cmp    %cl,(%eax)
  800c75:	74 05                	je     800c7c <memfind+0x21>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800c77:	40                   	inc    %eax
  800c78:	39 c2                	cmp    %eax,%edx
  800c7a:	77 f7                	ja     800c73 <memfind+0x18>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800c7c:	c9                   	leave  
  800c7d:	c3                   	ret    

00800c7e <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800c7e:	55                   	push   %ebp
  800c7f:	89 e5                	mov    %esp,%ebp
  800c81:	57                   	push   %edi
  800c82:	56                   	push   %esi
  800c83:	53                   	push   %ebx
  800c84:	8b 55 08             	mov    0x8(%ebp),%edx
  800c87:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800c8a:	eb 01                	jmp    800c8d <strtol+0xf>
		s++;
  800c8c:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800c8d:	8a 02                	mov    (%edx),%al
  800c8f:	3c 20                	cmp    $0x20,%al
  800c91:	74 f9                	je     800c8c <strtol+0xe>
  800c93:	3c 09                	cmp    $0x9,%al
  800c95:	74 f5                	je     800c8c <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800c97:	3c 2b                	cmp    $0x2b,%al
  800c99:	75 08                	jne    800ca3 <strtol+0x25>
		s++;
  800c9b:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800c9c:	bf 00 00 00 00       	mov    $0x0,%edi
  800ca1:	eb 13                	jmp    800cb6 <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800ca3:	3c 2d                	cmp    $0x2d,%al
  800ca5:	75 0a                	jne    800cb1 <strtol+0x33>
		s++, neg = 1;
  800ca7:	8d 52 01             	lea    0x1(%edx),%edx
  800caa:	bf 01 00 00 00       	mov    $0x1,%edi
  800caf:	eb 05                	jmp    800cb6 <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800cb1:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800cb6:	85 db                	test   %ebx,%ebx
  800cb8:	74 05                	je     800cbf <strtol+0x41>
  800cba:	83 fb 10             	cmp    $0x10,%ebx
  800cbd:	75 28                	jne    800ce7 <strtol+0x69>
  800cbf:	8a 02                	mov    (%edx),%al
  800cc1:	3c 30                	cmp    $0x30,%al
  800cc3:	75 10                	jne    800cd5 <strtol+0x57>
  800cc5:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800cc9:	75 0a                	jne    800cd5 <strtol+0x57>
		s += 2, base = 16;
  800ccb:	83 c2 02             	add    $0x2,%edx
  800cce:	bb 10 00 00 00       	mov    $0x10,%ebx
  800cd3:	eb 12                	jmp    800ce7 <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  800cd5:	85 db                	test   %ebx,%ebx
  800cd7:	75 0e                	jne    800ce7 <strtol+0x69>
  800cd9:	3c 30                	cmp    $0x30,%al
  800cdb:	75 05                	jne    800ce2 <strtol+0x64>
		s++, base = 8;
  800cdd:	42                   	inc    %edx
  800cde:	b3 08                	mov    $0x8,%bl
  800ce0:	eb 05                	jmp    800ce7 <strtol+0x69>
	else if (base == 0)
		base = 10;
  800ce2:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800ce7:	b8 00 00 00 00       	mov    $0x0,%eax
  800cec:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800cee:	8a 0a                	mov    (%edx),%cl
  800cf0:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800cf3:	80 fb 09             	cmp    $0x9,%bl
  800cf6:	77 08                	ja     800d00 <strtol+0x82>
			dig = *s - '0';
  800cf8:	0f be c9             	movsbl %cl,%ecx
  800cfb:	83 e9 30             	sub    $0x30,%ecx
  800cfe:	eb 1e                	jmp    800d1e <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  800d00:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800d03:	80 fb 19             	cmp    $0x19,%bl
  800d06:	77 08                	ja     800d10 <strtol+0x92>
			dig = *s - 'a' + 10;
  800d08:	0f be c9             	movsbl %cl,%ecx
  800d0b:	83 e9 57             	sub    $0x57,%ecx
  800d0e:	eb 0e                	jmp    800d1e <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  800d10:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800d13:	80 fb 19             	cmp    $0x19,%bl
  800d16:	77 13                	ja     800d2b <strtol+0xad>
			dig = *s - 'A' + 10;
  800d18:	0f be c9             	movsbl %cl,%ecx
  800d1b:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800d1e:	39 f1                	cmp    %esi,%ecx
  800d20:	7d 0d                	jge    800d2f <strtol+0xb1>
			break;
		s++, val = (val * base) + dig;
  800d22:	42                   	inc    %edx
  800d23:	0f af c6             	imul   %esi,%eax
  800d26:	8d 04 01             	lea    (%ecx,%eax,1),%eax
		// we don't properly detect overflow!
	}
  800d29:	eb c3                	jmp    800cee <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800d2b:	89 c1                	mov    %eax,%ecx
  800d2d:	eb 02                	jmp    800d31 <strtol+0xb3>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800d2f:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800d31:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800d35:	74 05                	je     800d3c <strtol+0xbe>
		*endptr = (char *) s;
  800d37:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800d3a:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800d3c:	85 ff                	test   %edi,%edi
  800d3e:	74 04                	je     800d44 <strtol+0xc6>
  800d40:	89 c8                	mov    %ecx,%eax
  800d42:	f7 d8                	neg    %eax
}
  800d44:	5b                   	pop    %ebx
  800d45:	5e                   	pop    %esi
  800d46:	5f                   	pop    %edi
  800d47:	c9                   	leave  
  800d48:	c3                   	ret    
  800d49:	00 00                	add    %al,(%eax)
	...

00800d4c <syscall>:
	return ret;
}

static int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  800d4c:	55                   	push   %ebp
  800d4d:	89 e5                	mov    %esp,%ebp
  800d4f:	57                   	push   %edi
  800d50:	56                   	push   %esi
  800d51:	53                   	push   %ebx
  800d52:	83 ec 1c             	sub    $0x1c,%esp
  800d55:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800d58:	89 55 e0             	mov    %edx,-0x20(%ebp)
  800d5b:	89 ca                	mov    %ecx,%edx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d5d:	8b 75 14             	mov    0x14(%ebp),%esi
  800d60:	8b 7d 10             	mov    0x10(%ebp),%edi
  800d63:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800d66:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d69:	cd 30                	int    $0x30
  800d6b:	89 c2                	mov    %eax,%edx
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d6d:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800d71:	74 1c                	je     800d8f <syscall+0x43>
  800d73:	85 c0                	test   %eax,%eax
  800d75:	7e 18                	jle    800d8f <syscall+0x43>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d77:	83 ec 0c             	sub    $0xc,%esp
  800d7a:	50                   	push   %eax
  800d7b:	ff 75 e4             	pushl  -0x1c(%ebp)
  800d7e:	68 9f 26 80 00       	push   $0x80269f
  800d83:	6a 42                	push   $0x42
  800d85:	68 bc 26 80 00       	push   $0x8026bc
  800d8a:	e8 b1 f5 ff ff       	call   800340 <_panic>

	return ret;
}
  800d8f:	89 d0                	mov    %edx,%eax
  800d91:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d94:	5b                   	pop    %ebx
  800d95:	5e                   	pop    %esi
  800d96:	5f                   	pop    %edi
  800d97:	c9                   	leave  
  800d98:	c3                   	ret    

00800d99 <sys_cputs>:

void
sys_cputs(const char *s, size_t len)
{	
  800d99:	55                   	push   %ebp
  800d9a:	89 e5                	mov    %esp,%ebp
  800d9c:	83 ec 08             	sub    $0x8,%esp
	// my_sysenter(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
	// return;
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
  800d9f:	6a 00                	push   $0x0
  800da1:	6a 00                	push   $0x0
  800da3:	6a 00                	push   $0x0
  800da5:	ff 75 0c             	pushl  0xc(%ebp)
  800da8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800dab:	ba 00 00 00 00       	mov    $0x0,%edx
  800db0:	b8 00 00 00 00       	mov    $0x0,%eax
  800db5:	e8 92 ff ff ff       	call   800d4c <syscall>
  800dba:	83 c4 10             	add    $0x10,%esp
	return;
}
  800dbd:	c9                   	leave  
  800dbe:	c3                   	ret    

00800dbf <sys_cgetc>:

int
sys_cgetc(void)
{
  800dbf:	55                   	push   %ebp
  800dc0:	89 e5                	mov    %esp,%ebp
  800dc2:	83 ec 08             	sub    $0x8,%esp
	// return my_sysenter(SYS_cgetc, 0, 0, 0, 0, 0, 0);
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
  800dc5:	6a 00                	push   $0x0
  800dc7:	6a 00                	push   $0x0
  800dc9:	6a 00                	push   $0x0
  800dcb:	6a 00                	push   $0x0
  800dcd:	b9 00 00 00 00       	mov    $0x0,%ecx
  800dd2:	ba 00 00 00 00       	mov    $0x0,%edx
  800dd7:	b8 01 00 00 00       	mov    $0x1,%eax
  800ddc:	e8 6b ff ff ff       	call   800d4c <syscall>
}
  800de1:	c9                   	leave  
  800de2:	c3                   	ret    

00800de3 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800de3:	55                   	push   %ebp
  800de4:	89 e5                	mov    %esp,%ebp
  800de6:	83 ec 08             	sub    $0x8,%esp
	// return my_sysenter(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
  800de9:	6a 00                	push   $0x0
  800deb:	6a 00                	push   $0x0
  800ded:	6a 00                	push   $0x0
  800def:	6a 00                	push   $0x0
  800df1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800df4:	ba 01 00 00 00       	mov    $0x1,%edx
  800df9:	b8 03 00 00 00       	mov    $0x3,%eax
  800dfe:	e8 49 ff ff ff       	call   800d4c <syscall>
}
  800e03:	c9                   	leave  
  800e04:	c3                   	ret    

00800e05 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800e05:	55                   	push   %ebp
  800e06:	89 e5                	mov    %esp,%ebp
  800e08:	83 ec 08             	sub    $0x8,%esp
	// return my_sysenter(SYS_getenvid, 0, 0, 0, 0, 0, 0);
	return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
  800e0b:	6a 00                	push   $0x0
  800e0d:	6a 00                	push   $0x0
  800e0f:	6a 00                	push   $0x0
  800e11:	6a 00                	push   $0x0
  800e13:	b9 00 00 00 00       	mov    $0x0,%ecx
  800e18:	ba 00 00 00 00       	mov    $0x0,%edx
  800e1d:	b8 02 00 00 00       	mov    $0x2,%eax
  800e22:	e8 25 ff ff ff       	call   800d4c <syscall>
}
  800e27:	c9                   	leave  
  800e28:	c3                   	ret    

00800e29 <sys_yield>:

void
sys_yield(void)
{
  800e29:	55                   	push   %ebp
  800e2a:	89 e5                	mov    %esp,%ebp
  800e2c:	83 ec 08             	sub    $0x8,%esp
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
  800e2f:	6a 00                	push   $0x0
  800e31:	6a 00                	push   $0x0
  800e33:	6a 00                	push   $0x0
  800e35:	6a 00                	push   $0x0
  800e37:	b9 00 00 00 00       	mov    $0x0,%ecx
  800e3c:	ba 00 00 00 00       	mov    $0x0,%edx
  800e41:	b8 0b 00 00 00       	mov    $0xb,%eax
  800e46:	e8 01 ff ff ff       	call   800d4c <syscall>
  800e4b:	83 c4 10             	add    $0x10,%esp
}
  800e4e:	c9                   	leave  
  800e4f:	c3                   	ret    

00800e50 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800e50:	55                   	push   %ebp
  800e51:	89 e5                	mov    %esp,%ebp
  800e53:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
  800e56:	6a 00                	push   $0x0
  800e58:	6a 00                	push   $0x0
  800e5a:	ff 75 10             	pushl  0x10(%ebp)
  800e5d:	ff 75 0c             	pushl  0xc(%ebp)
  800e60:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e63:	ba 01 00 00 00       	mov    $0x1,%edx
  800e68:	b8 04 00 00 00       	mov    $0x4,%eax
  800e6d:	e8 da fe ff ff       	call   800d4c <syscall>
}
  800e72:	c9                   	leave  
  800e73:	c3                   	ret    

00800e74 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800e74:	55                   	push   %ebp
  800e75:	89 e5                	mov    %esp,%ebp
  800e77:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
  800e7a:	ff 75 18             	pushl  0x18(%ebp)
  800e7d:	ff 75 14             	pushl  0x14(%ebp)
  800e80:	ff 75 10             	pushl  0x10(%ebp)
  800e83:	ff 75 0c             	pushl  0xc(%ebp)
  800e86:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e89:	ba 01 00 00 00       	mov    $0x1,%edx
  800e8e:	b8 05 00 00 00       	mov    $0x5,%eax
  800e93:	e8 b4 fe ff ff       	call   800d4c <syscall>
}
  800e98:	c9                   	leave  
  800e99:	c3                   	ret    

00800e9a <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800e9a:	55                   	push   %ebp
  800e9b:	89 e5                	mov    %esp,%ebp
  800e9d:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
  800ea0:	6a 00                	push   $0x0
  800ea2:	6a 00                	push   $0x0
  800ea4:	6a 00                	push   $0x0
  800ea6:	ff 75 0c             	pushl  0xc(%ebp)
  800ea9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800eac:	ba 01 00 00 00       	mov    $0x1,%edx
  800eb1:	b8 06 00 00 00       	mov    $0x6,%eax
  800eb6:	e8 91 fe ff ff       	call   800d4c <syscall>
}
  800ebb:	c9                   	leave  
  800ebc:	c3                   	ret    

00800ebd <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800ebd:	55                   	push   %ebp
  800ebe:	89 e5                	mov    %esp,%ebp
  800ec0:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
  800ec3:	6a 00                	push   $0x0
  800ec5:	6a 00                	push   $0x0
  800ec7:	6a 00                	push   $0x0
  800ec9:	ff 75 0c             	pushl  0xc(%ebp)
  800ecc:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ecf:	ba 01 00 00 00       	mov    $0x1,%edx
  800ed4:	b8 08 00 00 00       	mov    $0x8,%eax
  800ed9:	e8 6e fe ff ff       	call   800d4c <syscall>
}
  800ede:	c9                   	leave  
  800edf:	c3                   	ret    

00800ee0 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800ee0:	55                   	push   %ebp
  800ee1:	89 e5                	mov    %esp,%ebp
  800ee3:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
  800ee6:	6a 00                	push   $0x0
  800ee8:	6a 00                	push   $0x0
  800eea:	6a 00                	push   $0x0
  800eec:	ff 75 0c             	pushl  0xc(%ebp)
  800eef:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ef2:	ba 01 00 00 00       	mov    $0x1,%edx
  800ef7:	b8 09 00 00 00       	mov    $0x9,%eax
  800efc:	e8 4b fe ff ff       	call   800d4c <syscall>
}
  800f01:	c9                   	leave  
  800f02:	c3                   	ret    

00800f03 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800f03:	55                   	push   %ebp
  800f04:	89 e5                	mov    %esp,%ebp
  800f06:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
  800f09:	6a 00                	push   $0x0
  800f0b:	6a 00                	push   $0x0
  800f0d:	6a 00                	push   $0x0
  800f0f:	ff 75 0c             	pushl  0xc(%ebp)
  800f12:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800f15:	ba 01 00 00 00       	mov    $0x1,%edx
  800f1a:	b8 0a 00 00 00       	mov    $0xa,%eax
  800f1f:	e8 28 fe ff ff       	call   800d4c <syscall>
}
  800f24:	c9                   	leave  
  800f25:	c3                   	ret    

00800f26 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800f26:	55                   	push   %ebp
  800f27:	89 e5                	mov    %esp,%ebp
  800f29:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
  800f2c:	6a 00                	push   $0x0
  800f2e:	ff 75 14             	pushl  0x14(%ebp)
  800f31:	ff 75 10             	pushl  0x10(%ebp)
  800f34:	ff 75 0c             	pushl  0xc(%ebp)
  800f37:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800f3a:	ba 00 00 00 00       	mov    $0x0,%edx
  800f3f:	b8 0c 00 00 00       	mov    $0xc,%eax
  800f44:	e8 03 fe ff ff       	call   800d4c <syscall>
}
  800f49:	c9                   	leave  
  800f4a:	c3                   	ret    

00800f4b <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800f4b:	55                   	push   %ebp
  800f4c:	89 e5                	mov    %esp,%ebp
  800f4e:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
  800f51:	6a 00                	push   $0x0
  800f53:	6a 00                	push   $0x0
  800f55:	6a 00                	push   $0x0
  800f57:	6a 00                	push   $0x0
  800f59:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800f5c:	ba 01 00 00 00       	mov    $0x1,%edx
  800f61:	b8 0d 00 00 00       	mov    $0xd,%eax
  800f66:	e8 e1 fd ff ff       	call   800d4c <syscall>
}
  800f6b:	c9                   	leave  
  800f6c:	c3                   	ret    

00800f6d <sys_set_priority>:

int
sys_set_priority(envid_t envid, uint32_t new_priority)
{
  800f6d:	55                   	push   %ebp
  800f6e:	89 e5                	mov    %esp,%ebp
  800f70:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_set_priority, 0, envid, new_priority, 0, 0, 0);
  800f73:	6a 00                	push   $0x0
  800f75:	6a 00                	push   $0x0
  800f77:	6a 00                	push   $0x0
  800f79:	ff 75 0c             	pushl  0xc(%ebp)
  800f7c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800f7f:	ba 00 00 00 00       	mov    $0x0,%edx
  800f84:	b8 0e 00 00 00       	mov    $0xe,%eax
  800f89:	e8 be fd ff ff       	call   800d4c <syscall>
}
  800f8e:	c9                   	leave  
  800f8f:	c3                   	ret    

00800f90 <sys_exec>:

int
sys_exec(uint32_t eip, uint32_t esp, void * ph, uint32_t elf_phnum)
{
  800f90:	55                   	push   %ebp
  800f91:	89 e5                	mov    %esp,%ebp
  800f93:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_exec, 0, eip, esp, (uint32_t)ph, elf_phnum, 0);
  800f96:	6a 00                	push   $0x0
  800f98:	ff 75 14             	pushl  0x14(%ebp)
  800f9b:	ff 75 10             	pushl  0x10(%ebp)
  800f9e:	ff 75 0c             	pushl  0xc(%ebp)
  800fa1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800fa4:	ba 00 00 00 00       	mov    $0x0,%edx
  800fa9:	b8 0f 00 00 00       	mov    $0xf,%eax
  800fae:	e8 99 fd ff ff       	call   800d4c <syscall>
} 
  800fb3:	c9                   	leave  
  800fb4:	c3                   	ret    

00800fb5 <sys_join>:

// thread:
int
sys_join(envid_t envid)
{
  800fb5:	55                   	push   %ebp
  800fb6:	89 e5                	mov    %esp,%ebp
  800fb8:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_join, 0, envid, 0, 0, 0, 0);
  800fbb:	6a 00                	push   $0x0
  800fbd:	6a 00                	push   $0x0
  800fbf:	6a 00                	push   $0x0
  800fc1:	6a 00                	push   $0x0
  800fc3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800fc6:	ba 00 00 00 00       	mov    $0x0,%edx
  800fcb:	b8 11 00 00 00       	mov    $0x11,%eax
  800fd0:	e8 77 fd ff ff       	call   800d4c <syscall>
}
  800fd5:	c9                   	leave  
  800fd6:	c3                   	ret    

00800fd7 <sys_getpid>:

envid_t
sys_getpid(void)
{
  800fd7:	55                   	push   %ebp
  800fd8:	89 e5                	mov    %esp,%ebp
  800fda:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_getpid, 0, 0, 0, 0, 0, 0);
  800fdd:	6a 00                	push   $0x0
  800fdf:	6a 00                	push   $0x0
  800fe1:	6a 00                	push   $0x0
  800fe3:	6a 00                	push   $0x0
  800fe5:	b9 00 00 00 00       	mov    $0x0,%ecx
  800fea:	ba 00 00 00 00       	mov    $0x0,%edx
  800fef:	b8 10 00 00 00       	mov    $0x10,%eax
  800ff4:	e8 53 fd ff ff       	call   800d4c <syscall>
  800ff9:	c9                   	leave  
  800ffa:	c3                   	ret    
	...

00800ffc <argstart>:
#include <inc/args.h>
#include <inc/string.h>

void
argstart(int *argc, char **argv, struct Argstate *args)
{
  800ffc:	55                   	push   %ebp
  800ffd:	89 e5                	mov    %esp,%ebp
  800fff:	8b 55 08             	mov    0x8(%ebp),%edx
  801002:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801005:	8b 45 10             	mov    0x10(%ebp),%eax
	args->argc = argc;
  801008:	89 10                	mov    %edx,(%eax)
	args->argv = (const char **) argv;
  80100a:	89 48 04             	mov    %ecx,0x4(%eax)
	args->curarg = (*argc > 1 && argv ? "" : 0);
  80100d:	83 3a 01             	cmpl   $0x1,(%edx)
  801010:	7e 0b                	jle    80101d <argstart+0x21>
  801012:	85 c9                	test   %ecx,%ecx
  801014:	75 0e                	jne    801024 <argstart+0x28>
  801016:	ba 00 00 00 00       	mov    $0x0,%edx
  80101b:	eb 0c                	jmp    801029 <argstart+0x2d>
  80101d:	ba 00 00 00 00       	mov    $0x0,%edx
  801022:	eb 05                	jmp    801029 <argstart+0x2d>
  801024:	ba 48 23 80 00       	mov    $0x802348,%edx
  801029:	89 50 08             	mov    %edx,0x8(%eax)
	args->argvalue = 0;
  80102c:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
}
  801033:	c9                   	leave  
  801034:	c3                   	ret    

00801035 <argnext>:

int
argnext(struct Argstate *args)
{
  801035:	55                   	push   %ebp
  801036:	89 e5                	mov    %esp,%ebp
  801038:	57                   	push   %edi
  801039:	56                   	push   %esi
  80103a:	53                   	push   %ebx
  80103b:	83 ec 0c             	sub    $0xc,%esp
  80103e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int arg;

	args->argvalue = 0;
  801041:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)

	// Done processing arguments if args->curarg == 0
	if (args->curarg == 0)
  801048:	8b 43 08             	mov    0x8(%ebx),%eax
  80104b:	85 c0                	test   %eax,%eax
  80104d:	74 6c                	je     8010bb <argnext+0x86>
		return -1;

	if (!*args->curarg) {
  80104f:	80 38 00             	cmpb   $0x0,(%eax)
  801052:	75 4d                	jne    8010a1 <argnext+0x6c>
		// Need to process the next argument
		// Check for end of argument list
		if (*args->argc == 1
  801054:	8b 0b                	mov    (%ebx),%ecx
  801056:	83 39 01             	cmpl   $0x1,(%ecx)
  801059:	74 52                	je     8010ad <argnext+0x78>
		    || args->argv[1][0] != '-'
  80105b:	8b 43 04             	mov    0x4(%ebx),%eax
  80105e:	8d 70 04             	lea    0x4(%eax),%esi
  801061:	8b 50 04             	mov    0x4(%eax),%edx
  801064:	80 3a 2d             	cmpb   $0x2d,(%edx)
  801067:	75 44                	jne    8010ad <argnext+0x78>
		    || args->argv[1][1] == '\0')
  801069:	8d 7a 01             	lea    0x1(%edx),%edi
  80106c:	80 7a 01 00          	cmpb   $0x0,0x1(%edx)
  801070:	74 3b                	je     8010ad <argnext+0x78>
			goto endofargs;
		// Shift arguments down one
		args->curarg = args->argv[1] + 1;
  801072:	89 7b 08             	mov    %edi,0x8(%ebx)
		memmove(args->argv + 1, args->argv + 2, sizeof(const char *) * (*args->argc - 1));
  801075:	83 ec 04             	sub    $0x4,%esp
  801078:	8b 11                	mov    (%ecx),%edx
  80107a:	8d 14 95 fc ff ff ff 	lea    -0x4(,%edx,4),%edx
  801081:	52                   	push   %edx
  801082:	83 c0 08             	add    $0x8,%eax
  801085:	50                   	push   %eax
  801086:	56                   	push   %esi
  801087:	e8 03 fb ff ff       	call   800b8f <memmove>
		(*args->argc)--;
  80108c:	8b 03                	mov    (%ebx),%eax
  80108e:	ff 08                	decl   (%eax)
		// Check for "--": end of argument list
		if (args->curarg[0] == '-' && args->curarg[1] == '\0')
  801090:	8b 43 08             	mov    0x8(%ebx),%eax
  801093:	83 c4 10             	add    $0x10,%esp
  801096:	80 38 2d             	cmpb   $0x2d,(%eax)
  801099:	75 06                	jne    8010a1 <argnext+0x6c>
  80109b:	80 78 01 00          	cmpb   $0x0,0x1(%eax)
  80109f:	74 0c                	je     8010ad <argnext+0x78>
			goto endofargs;
	}

	arg = (unsigned char) *args->curarg;
  8010a1:	8b 53 08             	mov    0x8(%ebx),%edx
  8010a4:	0f b6 02             	movzbl (%edx),%eax
	args->curarg++;
  8010a7:	42                   	inc    %edx
  8010a8:	89 53 08             	mov    %edx,0x8(%ebx)
	return arg;
  8010ab:	eb 13                	jmp    8010c0 <argnext+0x8b>

    endofargs:
	args->curarg = 0;
  8010ad:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
	return -1;
  8010b4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  8010b9:	eb 05                	jmp    8010c0 <argnext+0x8b>

	args->argvalue = 0;

	// Done processing arguments if args->curarg == 0
	if (args->curarg == 0)
		return -1;
  8010bb:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	return arg;

    endofargs:
	args->curarg = 0;
	return -1;
}
  8010c0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8010c3:	5b                   	pop    %ebx
  8010c4:	5e                   	pop    %esi
  8010c5:	5f                   	pop    %edi
  8010c6:	c9                   	leave  
  8010c7:	c3                   	ret    

008010c8 <argnextvalue>:
	return (char*) (args->argvalue ? args->argvalue : argnextvalue(args));
}

char *
argnextvalue(struct Argstate *args)
{
  8010c8:	55                   	push   %ebp
  8010c9:	89 e5                	mov    %esp,%ebp
  8010cb:	56                   	push   %esi
  8010cc:	53                   	push   %ebx
  8010cd:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (!args->curarg)
  8010d0:	8b 43 08             	mov    0x8(%ebx),%eax
  8010d3:	85 c0                	test   %eax,%eax
  8010d5:	74 57                	je     80112e <argnextvalue+0x66>
		return 0;
	if (*args->curarg) {
  8010d7:	80 38 00             	cmpb   $0x0,(%eax)
  8010da:	74 0c                	je     8010e8 <argnextvalue+0x20>
		args->argvalue = args->curarg;
  8010dc:	89 43 0c             	mov    %eax,0xc(%ebx)
		args->curarg = "";
  8010df:	c7 43 08 48 23 80 00 	movl   $0x802348,0x8(%ebx)
  8010e6:	eb 41                	jmp    801129 <argnextvalue+0x61>
	} else if (*args->argc > 1) {
  8010e8:	8b 03                	mov    (%ebx),%eax
  8010ea:	83 38 01             	cmpl   $0x1,(%eax)
  8010ed:	7e 2c                	jle    80111b <argnextvalue+0x53>
		args->argvalue = args->argv[1];
  8010ef:	8b 53 04             	mov    0x4(%ebx),%edx
  8010f2:	8d 4a 04             	lea    0x4(%edx),%ecx
  8010f5:	8b 72 04             	mov    0x4(%edx),%esi
  8010f8:	89 73 0c             	mov    %esi,0xc(%ebx)
		memmove(args->argv + 1, args->argv + 2, sizeof(const char *) * (*args->argc - 1));
  8010fb:	83 ec 04             	sub    $0x4,%esp
  8010fe:	8b 00                	mov    (%eax),%eax
  801100:	8d 04 85 fc ff ff ff 	lea    -0x4(,%eax,4),%eax
  801107:	50                   	push   %eax
  801108:	83 c2 08             	add    $0x8,%edx
  80110b:	52                   	push   %edx
  80110c:	51                   	push   %ecx
  80110d:	e8 7d fa ff ff       	call   800b8f <memmove>
		(*args->argc)--;
  801112:	8b 03                	mov    (%ebx),%eax
  801114:	ff 08                	decl   (%eax)
  801116:	83 c4 10             	add    $0x10,%esp
  801119:	eb 0e                	jmp    801129 <argnextvalue+0x61>
	} else {
		args->argvalue = 0;
  80111b:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)
		args->curarg = 0;
  801122:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
	}
	return (char*) args->argvalue;
  801129:	8b 43 0c             	mov    0xc(%ebx),%eax
  80112c:	eb 05                	jmp    801133 <argnextvalue+0x6b>

char *
argnextvalue(struct Argstate *args)
{
	if (!args->curarg)
		return 0;
  80112e:	b8 00 00 00 00       	mov    $0x0,%eax
	} else {
		args->argvalue = 0;
		args->curarg = 0;
	}
	return (char*) args->argvalue;
}
  801133:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801136:	5b                   	pop    %ebx
  801137:	5e                   	pop    %esi
  801138:	c9                   	leave  
  801139:	c3                   	ret    

0080113a <argvalue>:
	return -1;
}

char *
argvalue(struct Argstate *args)
{
  80113a:	55                   	push   %ebp
  80113b:	89 e5                	mov    %esp,%ebp
  80113d:	83 ec 08             	sub    $0x8,%esp
  801140:	8b 55 08             	mov    0x8(%ebp),%edx
	return (char*) (args->argvalue ? args->argvalue : argnextvalue(args));
  801143:	8b 42 0c             	mov    0xc(%edx),%eax
  801146:	85 c0                	test   %eax,%eax
  801148:	75 0c                	jne    801156 <argvalue+0x1c>
  80114a:	83 ec 0c             	sub    $0xc,%esp
  80114d:	52                   	push   %edx
  80114e:	e8 75 ff ff ff       	call   8010c8 <argnextvalue>
  801153:	83 c4 10             	add    $0x10,%esp
}
  801156:	c9                   	leave  
  801157:	c3                   	ret    

00801158 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801158:	55                   	push   %ebp
  801159:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80115b:	8b 45 08             	mov    0x8(%ebp),%eax
  80115e:	05 00 00 00 30       	add    $0x30000000,%eax
  801163:	c1 e8 0c             	shr    $0xc,%eax
}
  801166:	c9                   	leave  
  801167:	c3                   	ret    

00801168 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801168:	55                   	push   %ebp
  801169:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  80116b:	ff 75 08             	pushl  0x8(%ebp)
  80116e:	e8 e5 ff ff ff       	call   801158 <fd2num>
  801173:	83 c4 04             	add    $0x4,%esp
  801176:	05 20 00 0d 00       	add    $0xd0020,%eax
  80117b:	c1 e0 0c             	shl    $0xc,%eax
}
  80117e:	c9                   	leave  
  80117f:	c3                   	ret    

00801180 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801180:	55                   	push   %ebp
  801181:	89 e5                	mov    %esp,%ebp
  801183:	53                   	push   %ebx
  801184:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801187:	a1 00 dd 7b ef       	mov    0xef7bdd00,%eax
  80118c:	a8 01                	test   $0x1,%al
  80118e:	74 34                	je     8011c4 <fd_alloc+0x44>
  801190:	a1 00 00 74 ef       	mov    0xef740000,%eax
  801195:	a8 01                	test   $0x1,%al
  801197:	74 32                	je     8011cb <fd_alloc+0x4b>
  801199:	b8 00 10 00 d0       	mov    $0xd0001000,%eax
  80119e:	89 c1                	mov    %eax,%ecx
  8011a0:	89 c2                	mov    %eax,%edx
  8011a2:	c1 ea 16             	shr    $0x16,%edx
  8011a5:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8011ac:	f6 c2 01             	test   $0x1,%dl
  8011af:	74 1f                	je     8011d0 <fd_alloc+0x50>
  8011b1:	89 c2                	mov    %eax,%edx
  8011b3:	c1 ea 0c             	shr    $0xc,%edx
  8011b6:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8011bd:	f6 c2 01             	test   $0x1,%dl
  8011c0:	75 17                	jne    8011d9 <fd_alloc+0x59>
  8011c2:	eb 0c                	jmp    8011d0 <fd_alloc+0x50>
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  8011c4:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
  8011c9:	eb 05                	jmp    8011d0 <fd_alloc+0x50>
  8011cb:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
  8011d0:	89 0b                	mov    %ecx,(%ebx)
			return 0;
  8011d2:	b8 00 00 00 00       	mov    $0x0,%eax
  8011d7:	eb 17                	jmp    8011f0 <fd_alloc+0x70>
  8011d9:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8011de:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8011e3:	75 b9                	jne    80119e <fd_alloc+0x1e>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8011e5:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_MAX_OPEN;
  8011eb:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8011f0:	5b                   	pop    %ebx
  8011f1:	c9                   	leave  
  8011f2:	c3                   	ret    

008011f3 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8011f3:	55                   	push   %ebp
  8011f4:	89 e5                	mov    %esp,%ebp
  8011f6:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8011f9:	83 f8 1f             	cmp    $0x1f,%eax
  8011fc:	77 36                	ja     801234 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8011fe:	05 00 00 0d 00       	add    $0xd0000,%eax
  801203:	c1 e0 0c             	shl    $0xc,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801206:	89 c2                	mov    %eax,%edx
  801208:	c1 ea 16             	shr    $0x16,%edx
  80120b:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801212:	f6 c2 01             	test   $0x1,%dl
  801215:	74 24                	je     80123b <fd_lookup+0x48>
  801217:	89 c2                	mov    %eax,%edx
  801219:	c1 ea 0c             	shr    $0xc,%edx
  80121c:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801223:	f6 c2 01             	test   $0x1,%dl
  801226:	74 1a                	je     801242 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  801228:	8b 55 0c             	mov    0xc(%ebp),%edx
  80122b:	89 02                	mov    %eax,(%edx)
	return 0;
  80122d:	b8 00 00 00 00       	mov    $0x0,%eax
  801232:	eb 13                	jmp    801247 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801234:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801239:	eb 0c                	jmp    801247 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80123b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801240:	eb 05                	jmp    801247 <fd_lookup+0x54>
  801242:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  801247:	c9                   	leave  
  801248:	c3                   	ret    

00801249 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801249:	55                   	push   %ebp
  80124a:	89 e5                	mov    %esp,%ebp
  80124c:	53                   	push   %ebx
  80124d:	83 ec 04             	sub    $0x4,%esp
  801250:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801253:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
		if (devtab[i]->dev_id == dev_id) {
  801256:	39 0d 04 30 80 00    	cmp    %ecx,0x803004
  80125c:	74 0d                	je     80126b <dev_lookup+0x22>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  80125e:	b8 00 00 00 00       	mov    $0x0,%eax
  801263:	eb 14                	jmp    801279 <dev_lookup+0x30>
		if (devtab[i]->dev_id == dev_id) {
  801265:	39 0a                	cmp    %ecx,(%edx)
  801267:	75 10                	jne    801279 <dev_lookup+0x30>
  801269:	eb 05                	jmp    801270 <dev_lookup+0x27>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  80126b:	ba 04 30 80 00       	mov    $0x803004,%edx
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
  801270:	89 13                	mov    %edx,(%ebx)
			return 0;
  801272:	b8 00 00 00 00       	mov    $0x0,%eax
  801277:	eb 31                	jmp    8012aa <dev_lookup+0x61>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801279:	40                   	inc    %eax
  80127a:	8b 14 85 4c 27 80 00 	mov    0x80274c(,%eax,4),%edx
  801281:	85 d2                	test   %edx,%edx
  801283:	75 e0                	jne    801265 <dev_lookup+0x1c>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801285:	a1 20 44 80 00       	mov    0x804420,%eax
  80128a:	8b 40 48             	mov    0x48(%eax),%eax
  80128d:	83 ec 04             	sub    $0x4,%esp
  801290:	51                   	push   %ecx
  801291:	50                   	push   %eax
  801292:	68 cc 26 80 00       	push   $0x8026cc
  801297:	e8 7c f1 ff ff       	call   800418 <cprintf>
	*dev = 0;
  80129c:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_INVAL;
  8012a2:	83 c4 10             	add    $0x10,%esp
  8012a5:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8012aa:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8012ad:	c9                   	leave  
  8012ae:	c3                   	ret    

008012af <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8012af:	55                   	push   %ebp
  8012b0:	89 e5                	mov    %esp,%ebp
  8012b2:	56                   	push   %esi
  8012b3:	53                   	push   %ebx
  8012b4:	83 ec 20             	sub    $0x20,%esp
  8012b7:	8b 75 08             	mov    0x8(%ebp),%esi
  8012ba:	8a 45 0c             	mov    0xc(%ebp),%al
  8012bd:	88 45 e7             	mov    %al,-0x19(%ebp)
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8012c0:	56                   	push   %esi
  8012c1:	e8 92 fe ff ff       	call   801158 <fd2num>
  8012c6:	8d 55 f4             	lea    -0xc(%ebp),%edx
  8012c9:	89 14 24             	mov    %edx,(%esp)
  8012cc:	50                   	push   %eax
  8012cd:	e8 21 ff ff ff       	call   8011f3 <fd_lookup>
  8012d2:	89 c3                	mov    %eax,%ebx
  8012d4:	83 c4 08             	add    $0x8,%esp
  8012d7:	85 c0                	test   %eax,%eax
  8012d9:	78 05                	js     8012e0 <fd_close+0x31>
	    || fd != fd2)
  8012db:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8012de:	74 0d                	je     8012ed <fd_close+0x3e>
		return (must_exist ? r : 0);
  8012e0:	80 7d e7 00          	cmpb   $0x0,-0x19(%ebp)
  8012e4:	75 48                	jne    80132e <fd_close+0x7f>
  8012e6:	bb 00 00 00 00       	mov    $0x0,%ebx
  8012eb:	eb 41                	jmp    80132e <fd_close+0x7f>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8012ed:	83 ec 08             	sub    $0x8,%esp
  8012f0:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8012f3:	50                   	push   %eax
  8012f4:	ff 36                	pushl  (%esi)
  8012f6:	e8 4e ff ff ff       	call   801249 <dev_lookup>
  8012fb:	89 c3                	mov    %eax,%ebx
  8012fd:	83 c4 10             	add    $0x10,%esp
  801300:	85 c0                	test   %eax,%eax
  801302:	78 1c                	js     801320 <fd_close+0x71>
		if (dev->dev_close)
  801304:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801307:	8b 40 10             	mov    0x10(%eax),%eax
  80130a:	85 c0                	test   %eax,%eax
  80130c:	74 0d                	je     80131b <fd_close+0x6c>
			r = (*dev->dev_close)(fd);
  80130e:	83 ec 0c             	sub    $0xc,%esp
  801311:	56                   	push   %esi
  801312:	ff d0                	call   *%eax
  801314:	89 c3                	mov    %eax,%ebx
  801316:	83 c4 10             	add    $0x10,%esp
  801319:	eb 05                	jmp    801320 <fd_close+0x71>
		else
			r = 0;
  80131b:	bb 00 00 00 00       	mov    $0x0,%ebx
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801320:	83 ec 08             	sub    $0x8,%esp
  801323:	56                   	push   %esi
  801324:	6a 00                	push   $0x0
  801326:	e8 6f fb ff ff       	call   800e9a <sys_page_unmap>
	return r;
  80132b:	83 c4 10             	add    $0x10,%esp
}
  80132e:	89 d8                	mov    %ebx,%eax
  801330:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801333:	5b                   	pop    %ebx
  801334:	5e                   	pop    %esi
  801335:	c9                   	leave  
  801336:	c3                   	ret    

00801337 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801337:	55                   	push   %ebp
  801338:	89 e5                	mov    %esp,%ebp
  80133a:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80133d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801340:	50                   	push   %eax
  801341:	ff 75 08             	pushl  0x8(%ebp)
  801344:	e8 aa fe ff ff       	call   8011f3 <fd_lookup>
  801349:	83 c4 08             	add    $0x8,%esp
  80134c:	85 c0                	test   %eax,%eax
  80134e:	78 10                	js     801360 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  801350:	83 ec 08             	sub    $0x8,%esp
  801353:	6a 01                	push   $0x1
  801355:	ff 75 f4             	pushl  -0xc(%ebp)
  801358:	e8 52 ff ff ff       	call   8012af <fd_close>
  80135d:	83 c4 10             	add    $0x10,%esp
}
  801360:	c9                   	leave  
  801361:	c3                   	ret    

00801362 <close_all>:

void
close_all(void)
{
  801362:	55                   	push   %ebp
  801363:	89 e5                	mov    %esp,%ebp
  801365:	53                   	push   %ebx
  801366:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801369:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  80136e:	83 ec 0c             	sub    $0xc,%esp
  801371:	53                   	push   %ebx
  801372:	e8 c0 ff ff ff       	call   801337 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801377:	43                   	inc    %ebx
  801378:	83 c4 10             	add    $0x10,%esp
  80137b:	83 fb 20             	cmp    $0x20,%ebx
  80137e:	75 ee                	jne    80136e <close_all+0xc>
		close(i);
}
  801380:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801383:	c9                   	leave  
  801384:	c3                   	ret    

00801385 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801385:	55                   	push   %ebp
  801386:	89 e5                	mov    %esp,%ebp
  801388:	57                   	push   %edi
  801389:	56                   	push   %esi
  80138a:	53                   	push   %ebx
  80138b:	83 ec 2c             	sub    $0x2c,%esp
  80138e:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801391:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801394:	50                   	push   %eax
  801395:	ff 75 08             	pushl  0x8(%ebp)
  801398:	e8 56 fe ff ff       	call   8011f3 <fd_lookup>
  80139d:	89 c3                	mov    %eax,%ebx
  80139f:	83 c4 08             	add    $0x8,%esp
  8013a2:	85 c0                	test   %eax,%eax
  8013a4:	0f 88 c0 00 00 00    	js     80146a <dup+0xe5>
		return r;
	close(newfdnum);
  8013aa:	83 ec 0c             	sub    $0xc,%esp
  8013ad:	57                   	push   %edi
  8013ae:	e8 84 ff ff ff       	call   801337 <close>

	newfd = INDEX2FD(newfdnum);
  8013b3:	8d b7 00 00 0d 00    	lea    0xd0000(%edi),%esi
  8013b9:	c1 e6 0c             	shl    $0xc,%esi
	ova = fd2data(oldfd);
  8013bc:	83 c4 04             	add    $0x4,%esp
  8013bf:	ff 75 e4             	pushl  -0x1c(%ebp)
  8013c2:	e8 a1 fd ff ff       	call   801168 <fd2data>
  8013c7:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  8013c9:	89 34 24             	mov    %esi,(%esp)
  8013cc:	e8 97 fd ff ff       	call   801168 <fd2data>
  8013d1:	83 c4 10             	add    $0x10,%esp
  8013d4:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8013d7:	89 d8                	mov    %ebx,%eax
  8013d9:	c1 e8 16             	shr    $0x16,%eax
  8013dc:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8013e3:	a8 01                	test   $0x1,%al
  8013e5:	74 37                	je     80141e <dup+0x99>
  8013e7:	89 d8                	mov    %ebx,%eax
  8013e9:	c1 e8 0c             	shr    $0xc,%eax
  8013ec:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8013f3:	f6 c2 01             	test   $0x1,%dl
  8013f6:	74 26                	je     80141e <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8013f8:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8013ff:	83 ec 0c             	sub    $0xc,%esp
  801402:	25 07 0e 00 00       	and    $0xe07,%eax
  801407:	50                   	push   %eax
  801408:	ff 75 d4             	pushl  -0x2c(%ebp)
  80140b:	6a 00                	push   $0x0
  80140d:	53                   	push   %ebx
  80140e:	6a 00                	push   $0x0
  801410:	e8 5f fa ff ff       	call   800e74 <sys_page_map>
  801415:	89 c3                	mov    %eax,%ebx
  801417:	83 c4 20             	add    $0x20,%esp
  80141a:	85 c0                	test   %eax,%eax
  80141c:	78 2d                	js     80144b <dup+0xc6>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80141e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801421:	89 c2                	mov    %eax,%edx
  801423:	c1 ea 0c             	shr    $0xc,%edx
  801426:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80142d:	83 ec 0c             	sub    $0xc,%esp
  801430:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  801436:	52                   	push   %edx
  801437:	56                   	push   %esi
  801438:	6a 00                	push   $0x0
  80143a:	50                   	push   %eax
  80143b:	6a 00                	push   $0x0
  80143d:	e8 32 fa ff ff       	call   800e74 <sys_page_map>
  801442:	89 c3                	mov    %eax,%ebx
  801444:	83 c4 20             	add    $0x20,%esp
  801447:	85 c0                	test   %eax,%eax
  801449:	79 1d                	jns    801468 <dup+0xe3>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  80144b:	83 ec 08             	sub    $0x8,%esp
  80144e:	56                   	push   %esi
  80144f:	6a 00                	push   $0x0
  801451:	e8 44 fa ff ff       	call   800e9a <sys_page_unmap>
	sys_page_unmap(0, nva);
  801456:	83 c4 08             	add    $0x8,%esp
  801459:	ff 75 d4             	pushl  -0x2c(%ebp)
  80145c:	6a 00                	push   $0x0
  80145e:	e8 37 fa ff ff       	call   800e9a <sys_page_unmap>
	return r;
  801463:	83 c4 10             	add    $0x10,%esp
  801466:	eb 02                	jmp    80146a <dup+0xe5>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
		goto err;

	return newfdnum;
  801468:	89 fb                	mov    %edi,%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  80146a:	89 d8                	mov    %ebx,%eax
  80146c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80146f:	5b                   	pop    %ebx
  801470:	5e                   	pop    %esi
  801471:	5f                   	pop    %edi
  801472:	c9                   	leave  
  801473:	c3                   	ret    

00801474 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801474:	55                   	push   %ebp
  801475:	89 e5                	mov    %esp,%ebp
  801477:	53                   	push   %ebx
  801478:	83 ec 14             	sub    $0x14,%esp
  80147b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80147e:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801481:	50                   	push   %eax
  801482:	53                   	push   %ebx
  801483:	e8 6b fd ff ff       	call   8011f3 <fd_lookup>
  801488:	83 c4 08             	add    $0x8,%esp
  80148b:	85 c0                	test   %eax,%eax
  80148d:	78 67                	js     8014f6 <read+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80148f:	83 ec 08             	sub    $0x8,%esp
  801492:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801495:	50                   	push   %eax
  801496:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801499:	ff 30                	pushl  (%eax)
  80149b:	e8 a9 fd ff ff       	call   801249 <dev_lookup>
  8014a0:	83 c4 10             	add    $0x10,%esp
  8014a3:	85 c0                	test   %eax,%eax
  8014a5:	78 4f                	js     8014f6 <read+0x82>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8014a7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014aa:	8b 50 08             	mov    0x8(%eax),%edx
  8014ad:	83 e2 03             	and    $0x3,%edx
  8014b0:	83 fa 01             	cmp    $0x1,%edx
  8014b3:	75 21                	jne    8014d6 <read+0x62>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8014b5:	a1 20 44 80 00       	mov    0x804420,%eax
  8014ba:	8b 40 48             	mov    0x48(%eax),%eax
  8014bd:	83 ec 04             	sub    $0x4,%esp
  8014c0:	53                   	push   %ebx
  8014c1:	50                   	push   %eax
  8014c2:	68 10 27 80 00       	push   $0x802710
  8014c7:	e8 4c ef ff ff       	call   800418 <cprintf>
		return -E_INVAL;
  8014cc:	83 c4 10             	add    $0x10,%esp
  8014cf:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8014d4:	eb 20                	jmp    8014f6 <read+0x82>
	}
	if (!dev->dev_read)
  8014d6:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8014d9:	8b 52 08             	mov    0x8(%edx),%edx
  8014dc:	85 d2                	test   %edx,%edx
  8014de:	74 11                	je     8014f1 <read+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8014e0:	83 ec 04             	sub    $0x4,%esp
  8014e3:	ff 75 10             	pushl  0x10(%ebp)
  8014e6:	ff 75 0c             	pushl  0xc(%ebp)
  8014e9:	50                   	push   %eax
  8014ea:	ff d2                	call   *%edx
  8014ec:	83 c4 10             	add    $0x10,%esp
  8014ef:	eb 05                	jmp    8014f6 <read+0x82>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8014f1:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_read)(fd, buf, n);
}
  8014f6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8014f9:	c9                   	leave  
  8014fa:	c3                   	ret    

008014fb <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8014fb:	55                   	push   %ebp
  8014fc:	89 e5                	mov    %esp,%ebp
  8014fe:	57                   	push   %edi
  8014ff:	56                   	push   %esi
  801500:	53                   	push   %ebx
  801501:	83 ec 0c             	sub    $0xc,%esp
  801504:	8b 7d 08             	mov    0x8(%ebp),%edi
  801507:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80150a:	85 f6                	test   %esi,%esi
  80150c:	74 31                	je     80153f <readn+0x44>
  80150e:	b8 00 00 00 00       	mov    $0x0,%eax
  801513:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = read(fdnum, (char*)buf + tot, n - tot);
  801518:	83 ec 04             	sub    $0x4,%esp
  80151b:	89 f2                	mov    %esi,%edx
  80151d:	29 c2                	sub    %eax,%edx
  80151f:	52                   	push   %edx
  801520:	03 45 0c             	add    0xc(%ebp),%eax
  801523:	50                   	push   %eax
  801524:	57                   	push   %edi
  801525:	e8 4a ff ff ff       	call   801474 <read>
		if (m < 0)
  80152a:	83 c4 10             	add    $0x10,%esp
  80152d:	85 c0                	test   %eax,%eax
  80152f:	78 17                	js     801548 <readn+0x4d>
			return m;
		if (m == 0)
  801531:	85 c0                	test   %eax,%eax
  801533:	74 11                	je     801546 <readn+0x4b>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801535:	01 c3                	add    %eax,%ebx
  801537:	89 d8                	mov    %ebx,%eax
  801539:	39 f3                	cmp    %esi,%ebx
  80153b:	72 db                	jb     801518 <readn+0x1d>
  80153d:	eb 09                	jmp    801548 <readn+0x4d>
  80153f:	b8 00 00 00 00       	mov    $0x0,%eax
  801544:	eb 02                	jmp    801548 <readn+0x4d>
		m = read(fdnum, (char*)buf + tot, n - tot);
		if (m < 0)
			return m;
		if (m == 0)
  801546:	89 d8                	mov    %ebx,%eax
			break;
	}
	return tot;
}
  801548:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80154b:	5b                   	pop    %ebx
  80154c:	5e                   	pop    %esi
  80154d:	5f                   	pop    %edi
  80154e:	c9                   	leave  
  80154f:	c3                   	ret    

00801550 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801550:	55                   	push   %ebp
  801551:	89 e5                	mov    %esp,%ebp
  801553:	53                   	push   %ebx
  801554:	83 ec 14             	sub    $0x14,%esp
  801557:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80155a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80155d:	50                   	push   %eax
  80155e:	53                   	push   %ebx
  80155f:	e8 8f fc ff ff       	call   8011f3 <fd_lookup>
  801564:	83 c4 08             	add    $0x8,%esp
  801567:	85 c0                	test   %eax,%eax
  801569:	78 62                	js     8015cd <write+0x7d>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80156b:	83 ec 08             	sub    $0x8,%esp
  80156e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801571:	50                   	push   %eax
  801572:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801575:	ff 30                	pushl  (%eax)
  801577:	e8 cd fc ff ff       	call   801249 <dev_lookup>
  80157c:	83 c4 10             	add    $0x10,%esp
  80157f:	85 c0                	test   %eax,%eax
  801581:	78 4a                	js     8015cd <write+0x7d>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801583:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801586:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80158a:	75 21                	jne    8015ad <write+0x5d>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  80158c:	a1 20 44 80 00       	mov    0x804420,%eax
  801591:	8b 40 48             	mov    0x48(%eax),%eax
  801594:	83 ec 04             	sub    $0x4,%esp
  801597:	53                   	push   %ebx
  801598:	50                   	push   %eax
  801599:	68 2c 27 80 00       	push   $0x80272c
  80159e:	e8 75 ee ff ff       	call   800418 <cprintf>
		return -E_INVAL;
  8015a3:	83 c4 10             	add    $0x10,%esp
  8015a6:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8015ab:	eb 20                	jmp    8015cd <write+0x7d>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8015ad:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8015b0:	8b 52 0c             	mov    0xc(%edx),%edx
  8015b3:	85 d2                	test   %edx,%edx
  8015b5:	74 11                	je     8015c8 <write+0x78>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8015b7:	83 ec 04             	sub    $0x4,%esp
  8015ba:	ff 75 10             	pushl  0x10(%ebp)
  8015bd:	ff 75 0c             	pushl  0xc(%ebp)
  8015c0:	50                   	push   %eax
  8015c1:	ff d2                	call   *%edx
  8015c3:	83 c4 10             	add    $0x10,%esp
  8015c6:	eb 05                	jmp    8015cd <write+0x7d>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8015c8:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  8015cd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015d0:	c9                   	leave  
  8015d1:	c3                   	ret    

008015d2 <seek>:

int
seek(int fdnum, off_t offset)
{
  8015d2:	55                   	push   %ebp
  8015d3:	89 e5                	mov    %esp,%ebp
  8015d5:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8015d8:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8015db:	50                   	push   %eax
  8015dc:	ff 75 08             	pushl  0x8(%ebp)
  8015df:	e8 0f fc ff ff       	call   8011f3 <fd_lookup>
  8015e4:	83 c4 08             	add    $0x8,%esp
  8015e7:	85 c0                	test   %eax,%eax
  8015e9:	78 0e                	js     8015f9 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8015eb:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8015ee:	8b 55 0c             	mov    0xc(%ebp),%edx
  8015f1:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8015f4:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8015f9:	c9                   	leave  
  8015fa:	c3                   	ret    

008015fb <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8015fb:	55                   	push   %ebp
  8015fc:	89 e5                	mov    %esp,%ebp
  8015fe:	53                   	push   %ebx
  8015ff:	83 ec 14             	sub    $0x14,%esp
  801602:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801605:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801608:	50                   	push   %eax
  801609:	53                   	push   %ebx
  80160a:	e8 e4 fb ff ff       	call   8011f3 <fd_lookup>
  80160f:	83 c4 08             	add    $0x8,%esp
  801612:	85 c0                	test   %eax,%eax
  801614:	78 5f                	js     801675 <ftruncate+0x7a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801616:	83 ec 08             	sub    $0x8,%esp
  801619:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80161c:	50                   	push   %eax
  80161d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801620:	ff 30                	pushl  (%eax)
  801622:	e8 22 fc ff ff       	call   801249 <dev_lookup>
  801627:	83 c4 10             	add    $0x10,%esp
  80162a:	85 c0                	test   %eax,%eax
  80162c:	78 47                	js     801675 <ftruncate+0x7a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80162e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801631:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801635:	75 21                	jne    801658 <ftruncate+0x5d>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801637:	a1 20 44 80 00       	mov    0x804420,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  80163c:	8b 40 48             	mov    0x48(%eax),%eax
  80163f:	83 ec 04             	sub    $0x4,%esp
  801642:	53                   	push   %ebx
  801643:	50                   	push   %eax
  801644:	68 ec 26 80 00       	push   $0x8026ec
  801649:	e8 ca ed ff ff       	call   800418 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  80164e:	83 c4 10             	add    $0x10,%esp
  801651:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801656:	eb 1d                	jmp    801675 <ftruncate+0x7a>
	}
	if (!dev->dev_trunc)
  801658:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80165b:	8b 52 18             	mov    0x18(%edx),%edx
  80165e:	85 d2                	test   %edx,%edx
  801660:	74 0e                	je     801670 <ftruncate+0x75>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801662:	83 ec 08             	sub    $0x8,%esp
  801665:	ff 75 0c             	pushl  0xc(%ebp)
  801668:	50                   	push   %eax
  801669:	ff d2                	call   *%edx
  80166b:	83 c4 10             	add    $0x10,%esp
  80166e:	eb 05                	jmp    801675 <ftruncate+0x7a>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801670:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  801675:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801678:	c9                   	leave  
  801679:	c3                   	ret    

0080167a <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  80167a:	55                   	push   %ebp
  80167b:	89 e5                	mov    %esp,%ebp
  80167d:	53                   	push   %ebx
  80167e:	83 ec 14             	sub    $0x14,%esp
  801681:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801684:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801687:	50                   	push   %eax
  801688:	ff 75 08             	pushl  0x8(%ebp)
  80168b:	e8 63 fb ff ff       	call   8011f3 <fd_lookup>
  801690:	83 c4 08             	add    $0x8,%esp
  801693:	85 c0                	test   %eax,%eax
  801695:	78 52                	js     8016e9 <fstat+0x6f>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801697:	83 ec 08             	sub    $0x8,%esp
  80169a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80169d:	50                   	push   %eax
  80169e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016a1:	ff 30                	pushl  (%eax)
  8016a3:	e8 a1 fb ff ff       	call   801249 <dev_lookup>
  8016a8:	83 c4 10             	add    $0x10,%esp
  8016ab:	85 c0                	test   %eax,%eax
  8016ad:	78 3a                	js     8016e9 <fstat+0x6f>
		return r;
	if (!dev->dev_stat)
  8016af:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8016b2:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8016b6:	74 2c                	je     8016e4 <fstat+0x6a>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8016b8:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8016bb:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8016c2:	00 00 00 
	stat->st_isdir = 0;
  8016c5:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8016cc:	00 00 00 
	stat->st_dev = dev;
  8016cf:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8016d5:	83 ec 08             	sub    $0x8,%esp
  8016d8:	53                   	push   %ebx
  8016d9:	ff 75 f0             	pushl  -0x10(%ebp)
  8016dc:	ff 50 14             	call   *0x14(%eax)
  8016df:	83 c4 10             	add    $0x10,%esp
  8016e2:	eb 05                	jmp    8016e9 <fstat+0x6f>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8016e4:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8016e9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016ec:	c9                   	leave  
  8016ed:	c3                   	ret    

008016ee <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8016ee:	55                   	push   %ebp
  8016ef:	89 e5                	mov    %esp,%ebp
  8016f1:	56                   	push   %esi
  8016f2:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8016f3:	83 ec 08             	sub    $0x8,%esp
  8016f6:	6a 00                	push   $0x0
  8016f8:	ff 75 08             	pushl  0x8(%ebp)
  8016fb:	e8 78 01 00 00       	call   801878 <open>
  801700:	89 c3                	mov    %eax,%ebx
  801702:	83 c4 10             	add    $0x10,%esp
  801705:	85 c0                	test   %eax,%eax
  801707:	78 1b                	js     801724 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801709:	83 ec 08             	sub    $0x8,%esp
  80170c:	ff 75 0c             	pushl  0xc(%ebp)
  80170f:	50                   	push   %eax
  801710:	e8 65 ff ff ff       	call   80167a <fstat>
  801715:	89 c6                	mov    %eax,%esi
	close(fd);
  801717:	89 1c 24             	mov    %ebx,(%esp)
  80171a:	e8 18 fc ff ff       	call   801337 <close>
	return r;
  80171f:	83 c4 10             	add    $0x10,%esp
  801722:	89 f3                	mov    %esi,%ebx
}
  801724:	89 d8                	mov    %ebx,%eax
  801726:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801729:	5b                   	pop    %ebx
  80172a:	5e                   	pop    %esi
  80172b:	c9                   	leave  
  80172c:	c3                   	ret    
  80172d:	00 00                	add    %al,(%eax)
	...

00801730 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801730:	55                   	push   %ebp
  801731:	89 e5                	mov    %esp,%ebp
  801733:	56                   	push   %esi
  801734:	53                   	push   %ebx
  801735:	89 c3                	mov    %eax,%ebx
  801737:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  801739:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801740:	75 12                	jne    801754 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801742:	83 ec 0c             	sub    $0xc,%esp
  801745:	6a 01                	push   $0x1
  801747:	e8 9e 08 00 00       	call   801fea <ipc_find_env>
  80174c:	a3 00 40 80 00       	mov    %eax,0x804000
  801751:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801754:	6a 07                	push   $0x7
  801756:	68 00 50 80 00       	push   $0x805000
  80175b:	53                   	push   %ebx
  80175c:	ff 35 00 40 80 00    	pushl  0x804000
  801762:	e8 2e 08 00 00       	call   801f95 <ipc_send>
	
	return ipc_recv(NULL, dstva, NULL);
  801767:	83 c4 0c             	add    $0xc,%esp
  80176a:	6a 00                	push   $0x0
  80176c:	56                   	push   %esi
  80176d:	6a 00                	push   $0x0
  80176f:	e8 ac 07 00 00       	call   801f20 <ipc_recv>
}
  801774:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801777:	5b                   	pop    %ebx
  801778:	5e                   	pop    %esi
  801779:	c9                   	leave  
  80177a:	c3                   	ret    

0080177b <devfile_stat>:
}


static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  80177b:	55                   	push   %ebp
  80177c:	89 e5                	mov    %esp,%ebp
  80177e:	53                   	push   %ebx
  80177f:	83 ec 04             	sub    $0x4,%esp
  801782:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801785:	8b 45 08             	mov    0x8(%ebp),%eax
  801788:	8b 40 0c             	mov    0xc(%eax),%eax
  80178b:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0) {
  801790:	ba 00 00 00 00       	mov    $0x0,%edx
  801795:	b8 05 00 00 00       	mov    $0x5,%eax
  80179a:	e8 91 ff ff ff       	call   801730 <fsipc>
  80179f:	85 c0                	test   %eax,%eax
  8017a1:	78 2c                	js     8017cf <devfile_stat+0x54>
		return r;
	}
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8017a3:	83 ec 08             	sub    $0x8,%esp
  8017a6:	68 00 50 80 00       	push   $0x805000
  8017ab:	53                   	push   %ebx
  8017ac:	e8 1d f2 ff ff       	call   8009ce <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8017b1:	a1 80 50 80 00       	mov    0x805080,%eax
  8017b6:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8017bc:	a1 84 50 80 00       	mov    0x805084,%eax
  8017c1:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8017c7:	83 c4 10             	add    $0x10,%esp
  8017ca:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8017cf:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8017d2:	c9                   	leave  
  8017d3:	c3                   	ret    

008017d4 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8017d4:	55                   	push   %ebp
  8017d5:	89 e5                	mov    %esp,%ebp
  8017d7:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8017da:	8b 45 08             	mov    0x8(%ebp),%eax
  8017dd:	8b 40 0c             	mov    0xc(%eax),%eax
  8017e0:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8017e5:	ba 00 00 00 00       	mov    $0x0,%edx
  8017ea:	b8 06 00 00 00       	mov    $0x6,%eax
  8017ef:	e8 3c ff ff ff       	call   801730 <fsipc>
}
  8017f4:	c9                   	leave  
  8017f5:	c3                   	ret    

008017f6 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  8017f6:	55                   	push   %ebp
  8017f7:	89 e5                	mov    %esp,%ebp
  8017f9:	56                   	push   %esi
  8017fa:	53                   	push   %ebx
  8017fb:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8017fe:	8b 45 08             	mov    0x8(%ebp),%eax
  801801:	8b 40 0c             	mov    0xc(%eax),%eax
  801804:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801809:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  80180f:	ba 00 00 00 00       	mov    $0x0,%edx
  801814:	b8 03 00 00 00       	mov    $0x3,%eax
  801819:	e8 12 ff ff ff       	call   801730 <fsipc>
  80181e:	89 c3                	mov    %eax,%ebx
  801820:	85 c0                	test   %eax,%eax
  801822:	78 4b                	js     80186f <devfile_read+0x79>
		return r;
	assert(r <= n);
  801824:	39 c6                	cmp    %eax,%esi
  801826:	73 16                	jae    80183e <devfile_read+0x48>
  801828:	68 5c 27 80 00       	push   $0x80275c
  80182d:	68 63 27 80 00       	push   $0x802763
  801832:	6a 7d                	push   $0x7d
  801834:	68 78 27 80 00       	push   $0x802778
  801839:	e8 02 eb ff ff       	call   800340 <_panic>
	assert(r <= PGSIZE);
  80183e:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801843:	7e 16                	jle    80185b <devfile_read+0x65>
  801845:	68 83 27 80 00       	push   $0x802783
  80184a:	68 63 27 80 00       	push   $0x802763
  80184f:	6a 7e                	push   $0x7e
  801851:	68 78 27 80 00       	push   $0x802778
  801856:	e8 e5 ea ff ff       	call   800340 <_panic>
	memmove(buf, &fsipcbuf, r);
  80185b:	83 ec 04             	sub    $0x4,%esp
  80185e:	50                   	push   %eax
  80185f:	68 00 50 80 00       	push   $0x805000
  801864:	ff 75 0c             	pushl  0xc(%ebp)
  801867:	e8 23 f3 ff ff       	call   800b8f <memmove>
	return r;
  80186c:	83 c4 10             	add    $0x10,%esp
}
  80186f:	89 d8                	mov    %ebx,%eax
  801871:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801874:	5b                   	pop    %ebx
  801875:	5e                   	pop    %esi
  801876:	c9                   	leave  
  801877:	c3                   	ret    

00801878 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801878:	55                   	push   %ebp
  801879:	89 e5                	mov    %esp,%ebp
  80187b:	56                   	push   %esi
  80187c:	53                   	push   %ebx
  80187d:	83 ec 1c             	sub    $0x1c,%esp
  801880:	8b 75 08             	mov    0x8(%ebp),%esi
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801883:	56                   	push   %esi
  801884:	e8 f3 f0 ff ff       	call   80097c <strlen>
  801889:	83 c4 10             	add    $0x10,%esp
  80188c:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801891:	7f 65                	jg     8018f8 <open+0x80>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801893:	83 ec 0c             	sub    $0xc,%esp
  801896:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801899:	50                   	push   %eax
  80189a:	e8 e1 f8 ff ff       	call   801180 <fd_alloc>
  80189f:	89 c3                	mov    %eax,%ebx
  8018a1:	83 c4 10             	add    $0x10,%esp
  8018a4:	85 c0                	test   %eax,%eax
  8018a6:	78 55                	js     8018fd <open+0x85>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  8018a8:	83 ec 08             	sub    $0x8,%esp
  8018ab:	56                   	push   %esi
  8018ac:	68 00 50 80 00       	push   $0x805000
  8018b1:	e8 18 f1 ff ff       	call   8009ce <strcpy>
	fsipcbuf.open.req_omode = mode;
  8018b6:	8b 45 0c             	mov    0xc(%ebp),%eax
  8018b9:	a3 00 54 80 00       	mov    %eax,0x805400



	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8018be:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8018c1:	b8 01 00 00 00       	mov    $0x1,%eax
  8018c6:	e8 65 fe ff ff       	call   801730 <fsipc>
  8018cb:	89 c3                	mov    %eax,%ebx
  8018cd:	83 c4 10             	add    $0x10,%esp
  8018d0:	85 c0                	test   %eax,%eax
  8018d2:	79 12                	jns    8018e6 <open+0x6e>
		fd_close(fd, 0);
  8018d4:	83 ec 08             	sub    $0x8,%esp
  8018d7:	6a 00                	push   $0x0
  8018d9:	ff 75 f4             	pushl  -0xc(%ebp)
  8018dc:	e8 ce f9 ff ff       	call   8012af <fd_close>
		return r;
  8018e1:	83 c4 10             	add    $0x10,%esp
  8018e4:	eb 17                	jmp    8018fd <open+0x85>
	}

	return fd2num(fd);
  8018e6:	83 ec 0c             	sub    $0xc,%esp
  8018e9:	ff 75 f4             	pushl  -0xc(%ebp)
  8018ec:	e8 67 f8 ff ff       	call   801158 <fd2num>
  8018f1:	89 c3                	mov    %eax,%ebx
  8018f3:	83 c4 10             	add    $0x10,%esp
  8018f6:	eb 05                	jmp    8018fd <open+0x85>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  8018f8:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  8018fd:	89 d8                	mov    %ebx,%eax
  8018ff:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801902:	5b                   	pop    %ebx
  801903:	5e                   	pop    %esi
  801904:	c9                   	leave  
  801905:	c3                   	ret    
	...

00801908 <writebuf>:
};


static void
writebuf(struct printbuf *b)
{
  801908:	55                   	push   %ebp
  801909:	89 e5                	mov    %esp,%ebp
  80190b:	53                   	push   %ebx
  80190c:	83 ec 04             	sub    $0x4,%esp
  80190f:	89 c3                	mov    %eax,%ebx
	if (b->error > 0) {
  801911:	83 78 0c 00          	cmpl   $0x0,0xc(%eax)
  801915:	7e 2e                	jle    801945 <writebuf+0x3d>
		ssize_t result = write(b->fd, b->buf, b->idx);
  801917:	83 ec 04             	sub    $0x4,%esp
  80191a:	ff 70 04             	pushl  0x4(%eax)
  80191d:	8d 40 10             	lea    0x10(%eax),%eax
  801920:	50                   	push   %eax
  801921:	ff 33                	pushl  (%ebx)
  801923:	e8 28 fc ff ff       	call   801550 <write>
		if (result > 0)
  801928:	83 c4 10             	add    $0x10,%esp
  80192b:	85 c0                	test   %eax,%eax
  80192d:	7e 03                	jle    801932 <writebuf+0x2a>
			b->result += result;
  80192f:	01 43 08             	add    %eax,0x8(%ebx)
		if (result != b->idx) // error, or wrote less than supplied
  801932:	39 43 04             	cmp    %eax,0x4(%ebx)
  801935:	74 0e                	je     801945 <writebuf+0x3d>
			b->error = (result < 0 ? result : 0);
  801937:	89 c2                	mov    %eax,%edx
  801939:	85 c0                	test   %eax,%eax
  80193b:	7e 05                	jle    801942 <writebuf+0x3a>
  80193d:	ba 00 00 00 00       	mov    $0x0,%edx
  801942:	89 53 0c             	mov    %edx,0xc(%ebx)
	}
}
  801945:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801948:	c9                   	leave  
  801949:	c3                   	ret    

0080194a <putch>:

static void
putch(int ch, void *thunk)
{
  80194a:	55                   	push   %ebp
  80194b:	89 e5                	mov    %esp,%ebp
  80194d:	53                   	push   %ebx
  80194e:	83 ec 04             	sub    $0x4,%esp
  801951:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct printbuf *b = (struct printbuf *) thunk;
	b->buf[b->idx++] = ch;
  801954:	8b 43 04             	mov    0x4(%ebx),%eax
  801957:	8b 55 08             	mov    0x8(%ebp),%edx
  80195a:	88 54 03 10          	mov    %dl,0x10(%ebx,%eax,1)
  80195e:	40                   	inc    %eax
  80195f:	89 43 04             	mov    %eax,0x4(%ebx)
	if (b->idx == 256) {
  801962:	3d 00 01 00 00       	cmp    $0x100,%eax
  801967:	75 0e                	jne    801977 <putch+0x2d>
		writebuf(b);
  801969:	89 d8                	mov    %ebx,%eax
  80196b:	e8 98 ff ff ff       	call   801908 <writebuf>
		b->idx = 0;
  801970:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	}
}
  801977:	83 c4 04             	add    $0x4,%esp
  80197a:	5b                   	pop    %ebx
  80197b:	c9                   	leave  
  80197c:	c3                   	ret    

0080197d <vfprintf>:

int
vfprintf(int fd, const char *fmt, va_list ap)
{
  80197d:	55                   	push   %ebp
  80197e:	89 e5                	mov    %esp,%ebp
  801980:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.fd = fd;
  801986:	8b 45 08             	mov    0x8(%ebp),%eax
  801989:	89 85 e8 fe ff ff    	mov    %eax,-0x118(%ebp)
	b.idx = 0;
  80198f:	c7 85 ec fe ff ff 00 	movl   $0x0,-0x114(%ebp)
  801996:	00 00 00 
	b.result = 0;
  801999:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8019a0:	00 00 00 
	b.error = 1;
  8019a3:	c7 85 f4 fe ff ff 01 	movl   $0x1,-0x10c(%ebp)
  8019aa:	00 00 00 
	vprintfmt(putch, &b, fmt, ap);
  8019ad:	ff 75 10             	pushl  0x10(%ebp)
  8019b0:	ff 75 0c             	pushl  0xc(%ebp)
  8019b3:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  8019b9:	50                   	push   %eax
  8019ba:	68 4a 19 80 00       	push   $0x80194a
  8019bf:	e8 b9 eb ff ff       	call   80057d <vprintfmt>
	if (b.idx > 0)
  8019c4:	83 c4 10             	add    $0x10,%esp
  8019c7:	83 bd ec fe ff ff 00 	cmpl   $0x0,-0x114(%ebp)
  8019ce:	7e 0b                	jle    8019db <vfprintf+0x5e>
		writebuf(&b);
  8019d0:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  8019d6:	e8 2d ff ff ff       	call   801908 <writebuf>

	return (b.result ? b.result : b.error);
  8019db:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  8019e1:	85 c0                	test   %eax,%eax
  8019e3:	75 06                	jne    8019eb <vfprintf+0x6e>
  8019e5:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
}
  8019eb:	c9                   	leave  
  8019ec:	c3                   	ret    

008019ed <fprintf>:

int
fprintf(int fd, const char *fmt, ...)
{
  8019ed:	55                   	push   %ebp
  8019ee:	89 e5                	mov    %esp,%ebp
  8019f0:	83 ec 0c             	sub    $0xc,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8019f3:	8d 45 10             	lea    0x10(%ebp),%eax
	cnt = vfprintf(fd, fmt, ap);
  8019f6:	50                   	push   %eax
  8019f7:	ff 75 0c             	pushl  0xc(%ebp)
  8019fa:	ff 75 08             	pushl  0x8(%ebp)
  8019fd:	e8 7b ff ff ff       	call   80197d <vfprintf>
	va_end(ap);

	return cnt;
}
  801a02:	c9                   	leave  
  801a03:	c3                   	ret    

00801a04 <printf>:

int
printf(const char *fmt, ...)
{
  801a04:	55                   	push   %ebp
  801a05:	89 e5                	mov    %esp,%ebp
  801a07:	83 ec 0c             	sub    $0xc,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  801a0a:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vfprintf(1, fmt, ap);
  801a0d:	50                   	push   %eax
  801a0e:	ff 75 08             	pushl  0x8(%ebp)
  801a11:	6a 01                	push   $0x1
  801a13:	e8 65 ff ff ff       	call   80197d <vfprintf>
	va_end(ap);

	return cnt;
}
  801a18:	c9                   	leave  
  801a19:	c3                   	ret    
	...

00801a1c <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801a1c:	55                   	push   %ebp
  801a1d:	89 e5                	mov    %esp,%ebp
  801a1f:	56                   	push   %esi
  801a20:	53                   	push   %ebx
  801a21:	8b 75 0c             	mov    0xc(%ebp),%esi
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801a24:	83 ec 0c             	sub    $0xc,%esp
  801a27:	ff 75 08             	pushl  0x8(%ebp)
  801a2a:	e8 39 f7 ff ff       	call   801168 <fd2data>
  801a2f:	89 c3                	mov    %eax,%ebx
	strcpy(stat->st_name, "<pipe>");
  801a31:	83 c4 08             	add    $0x8,%esp
  801a34:	68 8f 27 80 00       	push   $0x80278f
  801a39:	56                   	push   %esi
  801a3a:	e8 8f ef ff ff       	call   8009ce <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801a3f:	8b 43 04             	mov    0x4(%ebx),%eax
  801a42:	2b 03                	sub    (%ebx),%eax
  801a44:	89 86 80 00 00 00    	mov    %eax,0x80(%esi)
	stat->st_isdir = 0;
  801a4a:	c7 86 84 00 00 00 00 	movl   $0x0,0x84(%esi)
  801a51:	00 00 00 
	stat->st_dev = &devpipe;
  801a54:	c7 86 88 00 00 00 20 	movl   $0x803020,0x88(%esi)
  801a5b:	30 80 00 
	return 0;
}
  801a5e:	b8 00 00 00 00       	mov    $0x0,%eax
  801a63:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a66:	5b                   	pop    %ebx
  801a67:	5e                   	pop    %esi
  801a68:	c9                   	leave  
  801a69:	c3                   	ret    

00801a6a <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801a6a:	55                   	push   %ebp
  801a6b:	89 e5                	mov    %esp,%ebp
  801a6d:	53                   	push   %ebx
  801a6e:	83 ec 0c             	sub    $0xc,%esp
  801a71:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801a74:	53                   	push   %ebx
  801a75:	6a 00                	push   $0x0
  801a77:	e8 1e f4 ff ff       	call   800e9a <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801a7c:	89 1c 24             	mov    %ebx,(%esp)
  801a7f:	e8 e4 f6 ff ff       	call   801168 <fd2data>
  801a84:	83 c4 08             	add    $0x8,%esp
  801a87:	50                   	push   %eax
  801a88:	6a 00                	push   $0x0
  801a8a:	e8 0b f4 ff ff       	call   800e9a <sys_page_unmap>
}
  801a8f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a92:	c9                   	leave  
  801a93:	c3                   	ret    

00801a94 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801a94:	55                   	push   %ebp
  801a95:	89 e5                	mov    %esp,%ebp
  801a97:	57                   	push   %edi
  801a98:	56                   	push   %esi
  801a99:	53                   	push   %ebx
  801a9a:	83 ec 1c             	sub    $0x1c,%esp
  801a9d:	89 c7                	mov    %eax,%edi
  801a9f:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801aa2:	a1 20 44 80 00       	mov    0x804420,%eax
  801aa7:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801aaa:	83 ec 0c             	sub    $0xc,%esp
  801aad:	57                   	push   %edi
  801aae:	e8 85 05 00 00       	call   802038 <pageref>
  801ab3:	89 c6                	mov    %eax,%esi
  801ab5:	83 c4 04             	add    $0x4,%esp
  801ab8:	ff 75 e4             	pushl  -0x1c(%ebp)
  801abb:	e8 78 05 00 00       	call   802038 <pageref>
  801ac0:	83 c4 10             	add    $0x10,%esp
  801ac3:	39 c6                	cmp    %eax,%esi
  801ac5:	0f 94 c0             	sete   %al
  801ac8:	0f b6 c0             	movzbl %al,%eax
		nn = thisenv->env_runs;
  801acb:	8b 15 20 44 80 00    	mov    0x804420,%edx
  801ad1:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801ad4:	39 cb                	cmp    %ecx,%ebx
  801ad6:	75 08                	jne    801ae0 <_pipeisclosed+0x4c>
			return ret;
		if (n != nn && ret == 1)
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
	}
}
  801ad8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801adb:	5b                   	pop    %ebx
  801adc:	5e                   	pop    %esi
  801add:	5f                   	pop    %edi
  801ade:	c9                   	leave  
  801adf:	c3                   	ret    
		n = thisenv->env_runs;
		ret = pageref(fd) == pageref(p);
		nn = thisenv->env_runs;
		if (n == nn)
			return ret;
		if (n != nn && ret == 1)
  801ae0:	83 f8 01             	cmp    $0x1,%eax
  801ae3:	75 bd                	jne    801aa2 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801ae5:	8b 42 58             	mov    0x58(%edx),%eax
  801ae8:	6a 01                	push   $0x1
  801aea:	50                   	push   %eax
  801aeb:	53                   	push   %ebx
  801aec:	68 96 27 80 00       	push   $0x802796
  801af1:	e8 22 e9 ff ff       	call   800418 <cprintf>
  801af6:	83 c4 10             	add    $0x10,%esp
  801af9:	eb a7                	jmp    801aa2 <_pipeisclosed+0xe>

00801afb <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801afb:	55                   	push   %ebp
  801afc:	89 e5                	mov    %esp,%ebp
  801afe:	57                   	push   %edi
  801aff:	56                   	push   %esi
  801b00:	53                   	push   %ebx
  801b01:	83 ec 28             	sub    $0x28,%esp
  801b04:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801b07:	56                   	push   %esi
  801b08:	e8 5b f6 ff ff       	call   801168 <fd2data>
  801b0d:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801b0f:	83 c4 10             	add    $0x10,%esp
  801b12:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801b16:	75 4a                	jne    801b62 <devpipe_write+0x67>
  801b18:	bf 00 00 00 00       	mov    $0x0,%edi
  801b1d:	eb 56                	jmp    801b75 <devpipe_write+0x7a>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801b1f:	89 da                	mov    %ebx,%edx
  801b21:	89 f0                	mov    %esi,%eax
  801b23:	e8 6c ff ff ff       	call   801a94 <_pipeisclosed>
  801b28:	85 c0                	test   %eax,%eax
  801b2a:	75 4d                	jne    801b79 <devpipe_write+0x7e>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801b2c:	e8 f8 f2 ff ff       	call   800e29 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801b31:	8b 43 04             	mov    0x4(%ebx),%eax
  801b34:	8b 13                	mov    (%ebx),%edx
  801b36:	83 c2 20             	add    $0x20,%edx
  801b39:	39 d0                	cmp    %edx,%eax
  801b3b:	73 e2                	jae    801b1f <devpipe_write+0x24>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801b3d:	89 c2                	mov    %eax,%edx
  801b3f:	81 e2 1f 00 00 80    	and    $0x8000001f,%edx
  801b45:	79 05                	jns    801b4c <devpipe_write+0x51>
  801b47:	4a                   	dec    %edx
  801b48:	83 ca e0             	or     $0xffffffe0,%edx
  801b4b:	42                   	inc    %edx
  801b4c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801b4f:	8a 0c 39             	mov    (%ecx,%edi,1),%cl
  801b52:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801b56:	40                   	inc    %eax
  801b57:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801b5a:	47                   	inc    %edi
  801b5b:	39 7d 10             	cmp    %edi,0x10(%ebp)
  801b5e:	77 07                	ja     801b67 <devpipe_write+0x6c>
  801b60:	eb 13                	jmp    801b75 <devpipe_write+0x7a>
  801b62:	bf 00 00 00 00       	mov    $0x0,%edi
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801b67:	8b 43 04             	mov    0x4(%ebx),%eax
  801b6a:	8b 13                	mov    (%ebx),%edx
  801b6c:	83 c2 20             	add    $0x20,%edx
  801b6f:	39 d0                	cmp    %edx,%eax
  801b71:	73 ac                	jae    801b1f <devpipe_write+0x24>
  801b73:	eb c8                	jmp    801b3d <devpipe_write+0x42>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801b75:	89 f8                	mov    %edi,%eax
  801b77:	eb 05                	jmp    801b7e <devpipe_write+0x83>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801b79:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801b7e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b81:	5b                   	pop    %ebx
  801b82:	5e                   	pop    %esi
  801b83:	5f                   	pop    %edi
  801b84:	c9                   	leave  
  801b85:	c3                   	ret    

00801b86 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801b86:	55                   	push   %ebp
  801b87:	89 e5                	mov    %esp,%ebp
  801b89:	57                   	push   %edi
  801b8a:	56                   	push   %esi
  801b8b:	53                   	push   %ebx
  801b8c:	83 ec 18             	sub    $0x18,%esp
  801b8f:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801b92:	57                   	push   %edi
  801b93:	e8 d0 f5 ff ff       	call   801168 <fd2data>
  801b98:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801b9a:	83 c4 10             	add    $0x10,%esp
  801b9d:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801ba1:	75 44                	jne    801be7 <devpipe_read+0x61>
  801ba3:	be 00 00 00 00       	mov    $0x0,%esi
  801ba8:	eb 4f                	jmp    801bf9 <devpipe_read+0x73>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
				return i;
  801baa:	89 f0                	mov    %esi,%eax
  801bac:	eb 54                	jmp    801c02 <devpipe_read+0x7c>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801bae:	89 da                	mov    %ebx,%edx
  801bb0:	89 f8                	mov    %edi,%eax
  801bb2:	e8 dd fe ff ff       	call   801a94 <_pipeisclosed>
  801bb7:	85 c0                	test   %eax,%eax
  801bb9:	75 42                	jne    801bfd <devpipe_read+0x77>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801bbb:	e8 69 f2 ff ff       	call   800e29 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801bc0:	8b 03                	mov    (%ebx),%eax
  801bc2:	3b 43 04             	cmp    0x4(%ebx),%eax
  801bc5:	74 e7                	je     801bae <devpipe_read+0x28>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801bc7:	25 1f 00 00 80       	and    $0x8000001f,%eax
  801bcc:	79 05                	jns    801bd3 <devpipe_read+0x4d>
  801bce:	48                   	dec    %eax
  801bcf:	83 c8 e0             	or     $0xffffffe0,%eax
  801bd2:	40                   	inc    %eax
  801bd3:	8a 44 03 08          	mov    0x8(%ebx,%eax,1),%al
  801bd7:	8b 55 0c             	mov    0xc(%ebp),%edx
  801bda:	88 04 32             	mov    %al,(%edx,%esi,1)
		p->p_rpos++;
  801bdd:	ff 03                	incl   (%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801bdf:	46                   	inc    %esi
  801be0:	39 75 10             	cmp    %esi,0x10(%ebp)
  801be3:	77 07                	ja     801bec <devpipe_read+0x66>
  801be5:	eb 12                	jmp    801bf9 <devpipe_read+0x73>
  801be7:	be 00 00 00 00       	mov    $0x0,%esi
		while (p->p_rpos == p->p_wpos) {
  801bec:	8b 03                	mov    (%ebx),%eax
  801bee:	3b 43 04             	cmp    0x4(%ebx),%eax
  801bf1:	75 d4                	jne    801bc7 <devpipe_read+0x41>
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801bf3:	85 f6                	test   %esi,%esi
  801bf5:	75 b3                	jne    801baa <devpipe_read+0x24>
  801bf7:	eb b5                	jmp    801bae <devpipe_read+0x28>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801bf9:	89 f0                	mov    %esi,%eax
  801bfb:	eb 05                	jmp    801c02 <devpipe_read+0x7c>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801bfd:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801c02:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801c05:	5b                   	pop    %ebx
  801c06:	5e                   	pop    %esi
  801c07:	5f                   	pop    %edi
  801c08:	c9                   	leave  
  801c09:	c3                   	ret    

00801c0a <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801c0a:	55                   	push   %ebp
  801c0b:	89 e5                	mov    %esp,%ebp
  801c0d:	57                   	push   %edi
  801c0e:	56                   	push   %esi
  801c0f:	53                   	push   %ebx
  801c10:	83 ec 28             	sub    $0x28,%esp
  801c13:	8b 7d 08             	mov    0x8(%ebp),%edi
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801c16:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801c19:	50                   	push   %eax
  801c1a:	e8 61 f5 ff ff       	call   801180 <fd_alloc>
  801c1f:	89 c3                	mov    %eax,%ebx
  801c21:	83 c4 10             	add    $0x10,%esp
  801c24:	85 c0                	test   %eax,%eax
  801c26:	0f 88 24 01 00 00    	js     801d50 <pipe+0x146>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c2c:	83 ec 04             	sub    $0x4,%esp
  801c2f:	68 07 04 00 00       	push   $0x407
  801c34:	ff 75 e4             	pushl  -0x1c(%ebp)
  801c37:	6a 00                	push   $0x0
  801c39:	e8 12 f2 ff ff       	call   800e50 <sys_page_alloc>
  801c3e:	89 c3                	mov    %eax,%ebx
  801c40:	83 c4 10             	add    $0x10,%esp
  801c43:	85 c0                	test   %eax,%eax
  801c45:	0f 88 05 01 00 00    	js     801d50 <pipe+0x146>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801c4b:	83 ec 0c             	sub    $0xc,%esp
  801c4e:	8d 45 e0             	lea    -0x20(%ebp),%eax
  801c51:	50                   	push   %eax
  801c52:	e8 29 f5 ff ff       	call   801180 <fd_alloc>
  801c57:	89 c3                	mov    %eax,%ebx
  801c59:	83 c4 10             	add    $0x10,%esp
  801c5c:	85 c0                	test   %eax,%eax
  801c5e:	0f 88 dc 00 00 00    	js     801d40 <pipe+0x136>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c64:	83 ec 04             	sub    $0x4,%esp
  801c67:	68 07 04 00 00       	push   $0x407
  801c6c:	ff 75 e0             	pushl  -0x20(%ebp)
  801c6f:	6a 00                	push   $0x0
  801c71:	e8 da f1 ff ff       	call   800e50 <sys_page_alloc>
  801c76:	89 c3                	mov    %eax,%ebx
  801c78:	83 c4 10             	add    $0x10,%esp
  801c7b:	85 c0                	test   %eax,%eax
  801c7d:	0f 88 bd 00 00 00    	js     801d40 <pipe+0x136>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801c83:	83 ec 0c             	sub    $0xc,%esp
  801c86:	ff 75 e4             	pushl  -0x1c(%ebp)
  801c89:	e8 da f4 ff ff       	call   801168 <fd2data>
  801c8e:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c90:	83 c4 0c             	add    $0xc,%esp
  801c93:	68 07 04 00 00       	push   $0x407
  801c98:	50                   	push   %eax
  801c99:	6a 00                	push   $0x0
  801c9b:	e8 b0 f1 ff ff       	call   800e50 <sys_page_alloc>
  801ca0:	89 c3                	mov    %eax,%ebx
  801ca2:	83 c4 10             	add    $0x10,%esp
  801ca5:	85 c0                	test   %eax,%eax
  801ca7:	0f 88 83 00 00 00    	js     801d30 <pipe+0x126>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801cad:	83 ec 0c             	sub    $0xc,%esp
  801cb0:	ff 75 e0             	pushl  -0x20(%ebp)
  801cb3:	e8 b0 f4 ff ff       	call   801168 <fd2data>
  801cb8:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801cbf:	50                   	push   %eax
  801cc0:	6a 00                	push   $0x0
  801cc2:	56                   	push   %esi
  801cc3:	6a 00                	push   $0x0
  801cc5:	e8 aa f1 ff ff       	call   800e74 <sys_page_map>
  801cca:	89 c3                	mov    %eax,%ebx
  801ccc:	83 c4 20             	add    $0x20,%esp
  801ccf:	85 c0                	test   %eax,%eax
  801cd1:	78 4f                	js     801d22 <pipe+0x118>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801cd3:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801cd9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801cdc:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801cde:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801ce1:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801ce8:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801cee:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801cf1:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801cf3:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801cf6:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801cfd:	83 ec 0c             	sub    $0xc,%esp
  801d00:	ff 75 e4             	pushl  -0x1c(%ebp)
  801d03:	e8 50 f4 ff ff       	call   801158 <fd2num>
  801d08:	89 07                	mov    %eax,(%edi)
	pfd[1] = fd2num(fd1);
  801d0a:	83 c4 04             	add    $0x4,%esp
  801d0d:	ff 75 e0             	pushl  -0x20(%ebp)
  801d10:	e8 43 f4 ff ff       	call   801158 <fd2num>
  801d15:	89 47 04             	mov    %eax,0x4(%edi)
	return 0;
  801d18:	83 c4 10             	add    $0x10,%esp
  801d1b:	bb 00 00 00 00       	mov    $0x0,%ebx
  801d20:	eb 2e                	jmp    801d50 <pipe+0x146>

    err3:
	sys_page_unmap(0, va);
  801d22:	83 ec 08             	sub    $0x8,%esp
  801d25:	56                   	push   %esi
  801d26:	6a 00                	push   $0x0
  801d28:	e8 6d f1 ff ff       	call   800e9a <sys_page_unmap>
  801d2d:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801d30:	83 ec 08             	sub    $0x8,%esp
  801d33:	ff 75 e0             	pushl  -0x20(%ebp)
  801d36:	6a 00                	push   $0x0
  801d38:	e8 5d f1 ff ff       	call   800e9a <sys_page_unmap>
  801d3d:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801d40:	83 ec 08             	sub    $0x8,%esp
  801d43:	ff 75 e4             	pushl  -0x1c(%ebp)
  801d46:	6a 00                	push   $0x0
  801d48:	e8 4d f1 ff ff       	call   800e9a <sys_page_unmap>
  801d4d:	83 c4 10             	add    $0x10,%esp
    err:
	return r;
}
  801d50:	89 d8                	mov    %ebx,%eax
  801d52:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801d55:	5b                   	pop    %ebx
  801d56:	5e                   	pop    %esi
  801d57:	5f                   	pop    %edi
  801d58:	c9                   	leave  
  801d59:	c3                   	ret    

00801d5a <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801d5a:	55                   	push   %ebp
  801d5b:	89 e5                	mov    %esp,%ebp
  801d5d:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801d60:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801d63:	50                   	push   %eax
  801d64:	ff 75 08             	pushl  0x8(%ebp)
  801d67:	e8 87 f4 ff ff       	call   8011f3 <fd_lookup>
  801d6c:	83 c4 10             	add    $0x10,%esp
  801d6f:	85 c0                	test   %eax,%eax
  801d71:	78 18                	js     801d8b <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801d73:	83 ec 0c             	sub    $0xc,%esp
  801d76:	ff 75 f4             	pushl  -0xc(%ebp)
  801d79:	e8 ea f3 ff ff       	call   801168 <fd2data>
	return _pipeisclosed(fd, p);
  801d7e:	89 c2                	mov    %eax,%edx
  801d80:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d83:	e8 0c fd ff ff       	call   801a94 <_pipeisclosed>
  801d88:	83 c4 10             	add    $0x10,%esp
}
  801d8b:	c9                   	leave  
  801d8c:	c3                   	ret    
  801d8d:	00 00                	add    %al,(%eax)
	...

00801d90 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801d90:	55                   	push   %ebp
  801d91:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801d93:	b8 00 00 00 00       	mov    $0x0,%eax
  801d98:	c9                   	leave  
  801d99:	c3                   	ret    

00801d9a <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801d9a:	55                   	push   %ebp
  801d9b:	89 e5                	mov    %esp,%ebp
  801d9d:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801da0:	68 ae 27 80 00       	push   $0x8027ae
  801da5:	ff 75 0c             	pushl  0xc(%ebp)
  801da8:	e8 21 ec ff ff       	call   8009ce <strcpy>
	return 0;
}
  801dad:	b8 00 00 00 00       	mov    $0x0,%eax
  801db2:	c9                   	leave  
  801db3:	c3                   	ret    

00801db4 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801db4:	55                   	push   %ebp
  801db5:	89 e5                	mov    %esp,%ebp
  801db7:	57                   	push   %edi
  801db8:	56                   	push   %esi
  801db9:	53                   	push   %ebx
  801dba:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801dc0:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801dc4:	74 45                	je     801e0b <devcons_write+0x57>
  801dc6:	b8 00 00 00 00       	mov    $0x0,%eax
  801dcb:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801dd0:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801dd6:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801dd9:	29 c3                	sub    %eax,%ebx
		if (m > sizeof(buf) - 1)
  801ddb:	83 fb 7f             	cmp    $0x7f,%ebx
  801dde:	76 05                	jbe    801de5 <devcons_write+0x31>
			m = sizeof(buf) - 1;
  801de0:	bb 7f 00 00 00       	mov    $0x7f,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  801de5:	83 ec 04             	sub    $0x4,%esp
  801de8:	53                   	push   %ebx
  801de9:	03 45 0c             	add    0xc(%ebp),%eax
  801dec:	50                   	push   %eax
  801ded:	57                   	push   %edi
  801dee:	e8 9c ed ff ff       	call   800b8f <memmove>
		sys_cputs(buf, m);
  801df3:	83 c4 08             	add    $0x8,%esp
  801df6:	53                   	push   %ebx
  801df7:	57                   	push   %edi
  801df8:	e8 9c ef ff ff       	call   800d99 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801dfd:	01 de                	add    %ebx,%esi
  801dff:	89 f0                	mov    %esi,%eax
  801e01:	83 c4 10             	add    $0x10,%esp
  801e04:	3b 75 10             	cmp    0x10(%ebp),%esi
  801e07:	72 cd                	jb     801dd6 <devcons_write+0x22>
  801e09:	eb 05                	jmp    801e10 <devcons_write+0x5c>
  801e0b:	be 00 00 00 00       	mov    $0x0,%esi
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801e10:	89 f0                	mov    %esi,%eax
  801e12:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801e15:	5b                   	pop    %ebx
  801e16:	5e                   	pop    %esi
  801e17:	5f                   	pop    %edi
  801e18:	c9                   	leave  
  801e19:	c3                   	ret    

00801e1a <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801e1a:	55                   	push   %ebp
  801e1b:	89 e5                	mov    %esp,%ebp
  801e1d:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
  801e20:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801e24:	75 07                	jne    801e2d <devcons_read+0x13>
  801e26:	eb 25                	jmp    801e4d <devcons_read+0x33>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801e28:	e8 fc ef ff ff       	call   800e29 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801e2d:	e8 8d ef ff ff       	call   800dbf <sys_cgetc>
  801e32:	85 c0                	test   %eax,%eax
  801e34:	74 f2                	je     801e28 <devcons_read+0xe>
  801e36:	89 c2                	mov    %eax,%edx
		sys_yield();
	if (c < 0)
  801e38:	85 c0                	test   %eax,%eax
  801e3a:	78 1d                	js     801e59 <devcons_read+0x3f>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801e3c:	83 f8 04             	cmp    $0x4,%eax
  801e3f:	74 13                	je     801e54 <devcons_read+0x3a>
		return 0;
	*(char*)vbuf = c;
  801e41:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e44:	88 10                	mov    %dl,(%eax)
	return 1;
  801e46:	b8 01 00 00 00       	mov    $0x1,%eax
  801e4b:	eb 0c                	jmp    801e59 <devcons_read+0x3f>
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
		return 0;
  801e4d:	b8 00 00 00 00       	mov    $0x0,%eax
  801e52:	eb 05                	jmp    801e59 <devcons_read+0x3f>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801e54:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801e59:	c9                   	leave  
  801e5a:	c3                   	ret    

00801e5b <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801e5b:	55                   	push   %ebp
  801e5c:	89 e5                	mov    %esp,%ebp
  801e5e:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801e61:	8b 45 08             	mov    0x8(%ebp),%eax
  801e64:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801e67:	6a 01                	push   $0x1
  801e69:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801e6c:	50                   	push   %eax
  801e6d:	e8 27 ef ff ff       	call   800d99 <sys_cputs>
  801e72:	83 c4 10             	add    $0x10,%esp
}
  801e75:	c9                   	leave  
  801e76:	c3                   	ret    

00801e77 <getchar>:

int
getchar(void)
{
  801e77:	55                   	push   %ebp
  801e78:	89 e5                	mov    %esp,%ebp
  801e7a:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801e7d:	6a 01                	push   $0x1
  801e7f:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801e82:	50                   	push   %eax
  801e83:	6a 00                	push   $0x0
  801e85:	e8 ea f5 ff ff       	call   801474 <read>
	if (r < 0)
  801e8a:	83 c4 10             	add    $0x10,%esp
  801e8d:	85 c0                	test   %eax,%eax
  801e8f:	78 0f                	js     801ea0 <getchar+0x29>
		return r;
	if (r < 1)
  801e91:	85 c0                	test   %eax,%eax
  801e93:	7e 06                	jle    801e9b <getchar+0x24>
		return -E_EOF;
	return c;
  801e95:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801e99:	eb 05                	jmp    801ea0 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801e9b:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801ea0:	c9                   	leave  
  801ea1:	c3                   	ret    

00801ea2 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801ea2:	55                   	push   %ebp
  801ea3:	89 e5                	mov    %esp,%ebp
  801ea5:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801ea8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801eab:	50                   	push   %eax
  801eac:	ff 75 08             	pushl  0x8(%ebp)
  801eaf:	e8 3f f3 ff ff       	call   8011f3 <fd_lookup>
  801eb4:	83 c4 10             	add    $0x10,%esp
  801eb7:	85 c0                	test   %eax,%eax
  801eb9:	78 11                	js     801ecc <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801ebb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ebe:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801ec4:	39 10                	cmp    %edx,(%eax)
  801ec6:	0f 94 c0             	sete   %al
  801ec9:	0f b6 c0             	movzbl %al,%eax
}
  801ecc:	c9                   	leave  
  801ecd:	c3                   	ret    

00801ece <opencons>:

int
opencons(void)
{
  801ece:	55                   	push   %ebp
  801ecf:	89 e5                	mov    %esp,%ebp
  801ed1:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801ed4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801ed7:	50                   	push   %eax
  801ed8:	e8 a3 f2 ff ff       	call   801180 <fd_alloc>
  801edd:	83 c4 10             	add    $0x10,%esp
  801ee0:	85 c0                	test   %eax,%eax
  801ee2:	78 3a                	js     801f1e <opencons+0x50>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801ee4:	83 ec 04             	sub    $0x4,%esp
  801ee7:	68 07 04 00 00       	push   $0x407
  801eec:	ff 75 f4             	pushl  -0xc(%ebp)
  801eef:	6a 00                	push   $0x0
  801ef1:	e8 5a ef ff ff       	call   800e50 <sys_page_alloc>
  801ef6:	83 c4 10             	add    $0x10,%esp
  801ef9:	85 c0                	test   %eax,%eax
  801efb:	78 21                	js     801f1e <opencons+0x50>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801efd:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801f03:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f06:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801f08:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f0b:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801f12:	83 ec 0c             	sub    $0xc,%esp
  801f15:	50                   	push   %eax
  801f16:	e8 3d f2 ff ff       	call   801158 <fd2num>
  801f1b:	83 c4 10             	add    $0x10,%esp
}
  801f1e:	c9                   	leave  
  801f1f:	c3                   	ret    

00801f20 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801f20:	55                   	push   %ebp
  801f21:	89 e5                	mov    %esp,%ebp
  801f23:	56                   	push   %esi
  801f24:	53                   	push   %ebx
  801f25:	8b 75 08             	mov    0x8(%ebp),%esi
  801f28:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f2b:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// cprintf("0x%x 0x%x 0x%x\n", (uint32_t)from_env_store, (uint32_t)pg, (uint32_t)perm_store);
	int r;
	if (pg != NULL) {
  801f2e:	85 c0                	test   %eax,%eax
  801f30:	74 0e                	je     801f40 <ipc_recv+0x20>
		r = sys_ipc_recv(pg);
  801f32:	83 ec 0c             	sub    $0xc,%esp
  801f35:	50                   	push   %eax
  801f36:	e8 10 f0 ff ff       	call   800f4b <sys_ipc_recv>
  801f3b:	83 c4 10             	add    $0x10,%esp
  801f3e:	eb 10                	jmp    801f50 <ipc_recv+0x30>
	} else {
		r = sys_ipc_recv((void *)UTOP);
  801f40:	83 ec 0c             	sub    $0xc,%esp
  801f43:	68 00 00 c0 ee       	push   $0xeec00000
  801f48:	e8 fe ef ff ff       	call   800f4b <sys_ipc_recv>
  801f4d:	83 c4 10             	add    $0x10,%esp
	}

	if (r == 0) {
  801f50:	85 c0                	test   %eax,%eax
  801f52:	75 26                	jne    801f7a <ipc_recv+0x5a>
		if (from_env_store != NULL) *from_env_store = thisenv->env_ipc_from;
  801f54:	85 f6                	test   %esi,%esi
  801f56:	74 0a                	je     801f62 <ipc_recv+0x42>
  801f58:	a1 20 44 80 00       	mov    0x804420,%eax
  801f5d:	8b 40 74             	mov    0x74(%eax),%eax
  801f60:	89 06                	mov    %eax,(%esi)
		if (perm_store != NULL) *perm_store = thisenv->env_ipc_perm;
  801f62:	85 db                	test   %ebx,%ebx
  801f64:	74 0a                	je     801f70 <ipc_recv+0x50>
  801f66:	a1 20 44 80 00       	mov    0x804420,%eax
  801f6b:	8b 40 78             	mov    0x78(%eax),%eax
  801f6e:	89 03                	mov    %eax,(%ebx)
		return thisenv->env_ipc_value;
  801f70:	a1 20 44 80 00       	mov    0x804420,%eax
  801f75:	8b 40 70             	mov    0x70(%eax),%eax
  801f78:	eb 14                	jmp    801f8e <ipc_recv+0x6e>
	} else {
		// fails;
		if (from_env_store != NULL) *from_env_store = 0;
  801f7a:	85 f6                	test   %esi,%esi
  801f7c:	74 06                	je     801f84 <ipc_recv+0x64>
  801f7e:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		if (perm_store != NULL) *perm_store = 0;
  801f84:	85 db                	test   %ebx,%ebx
  801f86:	74 06                	je     801f8e <ipc_recv+0x6e>
  801f88:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
		return r;
	}
}
  801f8e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801f91:	5b                   	pop    %ebx
  801f92:	5e                   	pop    %esi
  801f93:	c9                   	leave  
  801f94:	c3                   	ret    

00801f95 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801f95:	55                   	push   %ebp
  801f96:	89 e5                	mov    %esp,%ebp
  801f98:	57                   	push   %edi
  801f99:	56                   	push   %esi
  801f9a:	53                   	push   %ebx
  801f9b:	83 ec 0c             	sub    $0xc,%esp
  801f9e:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801fa1:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801fa4:	8b 75 14             	mov    0x14(%ebp),%esi
	// LAB 4: Your code here.
	// int sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
	int r;
	if (pg == NULL) pg = (void *)UTOP;
  801fa7:	85 db                	test   %ebx,%ebx
  801fa9:	75 25                	jne    801fd0 <ipc_send+0x3b>
  801fab:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
  801fb0:	eb 1e                	jmp    801fd0 <ipc_send+0x3b>
	
	while ((r = sys_ipc_try_send(to_env, val, pg, perm)) != 0) {
		if (r == -E_IPC_NOT_RECV) {
  801fb2:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801fb5:	75 07                	jne    801fbe <ipc_send+0x29>
			// cprintf("Try Again and Again....\n");
			sys_yield();
  801fb7:	e8 6d ee ff ff       	call   800e29 <sys_yield>
  801fbc:	eb 12                	jmp    801fd0 <ipc_send+0x3b>
		} else {
			panic("ipc_send error %e\n", r);
  801fbe:	50                   	push   %eax
  801fbf:	68 ba 27 80 00       	push   $0x8027ba
  801fc4:	6a 43                	push   $0x43
  801fc6:	68 cd 27 80 00       	push   $0x8027cd
  801fcb:	e8 70 e3 ff ff       	call   800340 <_panic>
	// LAB 4: Your code here.
	// int sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
	int r;
	if (pg == NULL) pg = (void *)UTOP;
	
	while ((r = sys_ipc_try_send(to_env, val, pg, perm)) != 0) {
  801fd0:	56                   	push   %esi
  801fd1:	53                   	push   %ebx
  801fd2:	57                   	push   %edi
  801fd3:	ff 75 08             	pushl  0x8(%ebp)
  801fd6:	e8 4b ef ff ff       	call   800f26 <sys_ipc_try_send>
  801fdb:	83 c4 10             	add    $0x10,%esp
  801fde:	85 c0                	test   %eax,%eax
  801fe0:	75 d0                	jne    801fb2 <ipc_send+0x1d>
		} else {
			panic("ipc_send error %e\n", r);
		}
	}
	return;
}
  801fe2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801fe5:	5b                   	pop    %ebx
  801fe6:	5e                   	pop    %esi
  801fe7:	5f                   	pop    %edi
  801fe8:	c9                   	leave  
  801fe9:	c3                   	ret    

00801fea <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801fea:	55                   	push   %ebp
  801feb:	89 e5                	mov    %esp,%ebp
  801fed:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
		if (envs[i].env_type == type)
  801ff0:	39 0d 50 00 c0 ee    	cmp    %ecx,0xeec00050
  801ff6:	74 1a                	je     802012 <ipc_find_env+0x28>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801ff8:	b8 01 00 00 00       	mov    $0x1,%eax
		if (envs[i].env_type == type)
  801ffd:	89 c2                	mov    %eax,%edx
  801fff:	c1 e2 07             	shl    $0x7,%edx
  802002:	8d 94 82 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,4),%edx
  802009:	8b 52 50             	mov    0x50(%edx),%edx
  80200c:	39 ca                	cmp    %ecx,%edx
  80200e:	75 18                	jne    802028 <ipc_find_env+0x3e>
  802010:	eb 05                	jmp    802017 <ipc_find_env+0x2d>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  802012:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
			return envs[i].env_id;
  802017:	89 c2                	mov    %eax,%edx
  802019:	c1 e2 07             	shl    $0x7,%edx
  80201c:	8d 84 82 08 00 c0 ee 	lea    -0x113ffff8(%edx,%eax,4),%eax
  802023:	8b 40 40             	mov    0x40(%eax),%eax
  802026:	eb 0c                	jmp    802034 <ipc_find_env+0x4a>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  802028:	40                   	inc    %eax
  802029:	3d 00 04 00 00       	cmp    $0x400,%eax
  80202e:	75 cd                	jne    801ffd <ipc_find_env+0x13>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  802030:	66 b8 00 00          	mov    $0x0,%ax
}
  802034:	c9                   	leave  
  802035:	c3                   	ret    
	...

00802038 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802038:	55                   	push   %ebp
  802039:	89 e5                	mov    %esp,%ebp
  80203b:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  80203e:	89 c2                	mov    %eax,%edx
  802040:	c1 ea 16             	shr    $0x16,%edx
  802043:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80204a:	f6 c2 01             	test   $0x1,%dl
  80204d:	74 1e                	je     80206d <pageref+0x35>
		return 0;
	pte = uvpt[PGNUM(v)];
  80204f:	c1 e8 0c             	shr    $0xc,%eax
  802052:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  802059:	a8 01                	test   $0x1,%al
  80205b:	74 17                	je     802074 <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  80205d:	c1 e8 0c             	shr    $0xc,%eax
  802060:	66 8b 04 c5 04 00 00 	mov    -0x10fffffc(,%eax,8),%ax
  802067:	ef 
  802068:	0f b7 c0             	movzwl %ax,%eax
  80206b:	eb 0c                	jmp    802079 <pageref+0x41>
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
		return 0;
  80206d:	b8 00 00 00 00       	mov    $0x0,%eax
  802072:	eb 05                	jmp    802079 <pageref+0x41>
	pte = uvpt[PGNUM(v)];
	if (!(pte & PTE_P))
		return 0;
  802074:	b8 00 00 00 00       	mov    $0x0,%eax
	return pages[PGNUM(pte)].pp_ref;
}
  802079:	c9                   	leave  
  80207a:	c3                   	ret    
	...

0080207c <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  80207c:	55                   	push   %ebp
  80207d:	89 e5                	mov    %esp,%ebp
  80207f:	57                   	push   %edi
  802080:	56                   	push   %esi
  802081:	83 ec 10             	sub    $0x10,%esp
  802084:	8b 7d 08             	mov    0x8(%ebp),%edi
  802087:	8b 4d 10             	mov    0x10(%ebp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  80208a:	89 7d f0             	mov    %edi,-0x10(%ebp)
  80208d:	8b 75 0c             	mov    0xc(%ebp),%esi
  const DWunion dd = {.ll = d};
  802090:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  802093:	8b 45 14             	mov    0x14(%ebp),%eax
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  802096:	85 c0                	test   %eax,%eax
  802098:	75 2e                	jne    8020c8 <__udivdi3+0x4c>
    {
      if (d0 > n1)
  80209a:	39 f1                	cmp    %esi,%ecx
  80209c:	77 5a                	ja     8020f8 <__udivdi3+0x7c>
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  80209e:	85 c9                	test   %ecx,%ecx
  8020a0:	75 0b                	jne    8020ad <__udivdi3+0x31>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  8020a2:	b8 01 00 00 00       	mov    $0x1,%eax
  8020a7:	31 d2                	xor    %edx,%edx
  8020a9:	f7 f1                	div    %ecx
  8020ab:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  8020ad:	31 d2                	xor    %edx,%edx
  8020af:	89 f0                	mov    %esi,%eax
  8020b1:	f7 f1                	div    %ecx
  8020b3:	89 c6                	mov    %eax,%esi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  8020b5:	89 f8                	mov    %edi,%eax
  8020b7:	f7 f1                	div    %ecx
  8020b9:	89 c7                	mov    %eax,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  8020bb:	89 f8                	mov    %edi,%eax
  8020bd:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  8020bf:	83 c4 10             	add    $0x10,%esp
  8020c2:	5e                   	pop    %esi
  8020c3:	5f                   	pop    %edi
  8020c4:	c9                   	leave  
  8020c5:	c3                   	ret    
  8020c6:	66 90                	xchg   %ax,%ax
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  8020c8:	39 f0                	cmp    %esi,%eax
  8020ca:	77 1c                	ja     8020e8 <__udivdi3+0x6c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  8020cc:	0f bd f8             	bsr    %eax,%edi
	  if (bm == 0)
  8020cf:	83 f7 1f             	xor    $0x1f,%edi
  8020d2:	75 3c                	jne    802110 <__udivdi3+0x94>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  8020d4:	39 f0                	cmp    %esi,%eax
  8020d6:	0f 82 90 00 00 00    	jb     80216c <__udivdi3+0xf0>
  8020dc:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8020df:	39 55 f4             	cmp    %edx,-0xc(%ebp)
  8020e2:	0f 86 84 00 00 00    	jbe    80216c <__udivdi3+0xf0>
  8020e8:	31 f6                	xor    %esi,%esi
  8020ea:	31 ff                	xor    %edi,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  8020ec:	89 f8                	mov    %edi,%eax
  8020ee:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  8020f0:	83 c4 10             	add    $0x10,%esp
  8020f3:	5e                   	pop    %esi
  8020f4:	5f                   	pop    %edi
  8020f5:	c9                   	leave  
  8020f6:	c3                   	ret    
  8020f7:	90                   	nop
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  8020f8:	89 f2                	mov    %esi,%edx
  8020fa:	89 f8                	mov    %edi,%eax
  8020fc:	f7 f1                	div    %ecx
  8020fe:	89 c7                	mov    %eax,%edi
  802100:	31 f6                	xor    %esi,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  802102:	89 f8                	mov    %edi,%eax
  802104:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  802106:	83 c4 10             	add    $0x10,%esp
  802109:	5e                   	pop    %esi
  80210a:	5f                   	pop    %edi
  80210b:	c9                   	leave  
  80210c:	c3                   	ret    
  80210d:	8d 76 00             	lea    0x0(%esi),%esi
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  802110:	89 f9                	mov    %edi,%ecx
  802112:	d3 e0                	shl    %cl,%eax
  802114:	89 45 e8             	mov    %eax,-0x18(%ebp)
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  802117:	b8 20 00 00 00       	mov    $0x20,%eax
  80211c:	29 f8                	sub    %edi,%eax

	      d1 = (d1 << bm) | (d0 >> b);
  80211e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  802121:	88 c1                	mov    %al,%cl
  802123:	d3 ea                	shr    %cl,%edx
  802125:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  802128:	09 ca                	or     %ecx,%edx
  80212a:	89 55 ec             	mov    %edx,-0x14(%ebp)
	      d0 = d0 << bm;
  80212d:	8b 55 f4             	mov    -0xc(%ebp),%edx
  802130:	89 f9                	mov    %edi,%ecx
  802132:	d3 e2                	shl    %cl,%edx
  802134:	89 55 f4             	mov    %edx,-0xc(%ebp)
	      n2 = n1 >> b;
  802137:	89 f2                	mov    %esi,%edx
  802139:	88 c1                	mov    %al,%cl
  80213b:	d3 ea                	shr    %cl,%edx
  80213d:	89 55 e8             	mov    %edx,-0x18(%ebp)
	      n1 = (n1 << bm) | (n0 >> b);
  802140:	89 f2                	mov    %esi,%edx
  802142:	89 f9                	mov    %edi,%ecx
  802144:	d3 e2                	shl    %cl,%edx
  802146:	8b 75 f0             	mov    -0x10(%ebp),%esi
  802149:	88 c1                	mov    %al,%cl
  80214b:	d3 ee                	shr    %cl,%esi
  80214d:	09 d6                	or     %edx,%esi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  80214f:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  802152:	89 f0                	mov    %esi,%eax
  802154:	89 ca                	mov    %ecx,%edx
  802156:	f7 75 ec             	divl   -0x14(%ebp)
  802159:	89 d1                	mov    %edx,%ecx
  80215b:	89 c6                	mov    %eax,%esi
	      umul_ppmm (m1, m0, q0, d0);
  80215d:	f7 65 f4             	mull   -0xc(%ebp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  802160:	39 d1                	cmp    %edx,%ecx
  802162:	72 28                	jb     80218c <__udivdi3+0x110>
  802164:	74 1a                	je     802180 <__udivdi3+0x104>
  802166:	89 f7                	mov    %esi,%edi
  802168:	31 f6                	xor    %esi,%esi
  80216a:	eb 80                	jmp    8020ec <__udivdi3+0x70>
	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  80216c:	31 f6                	xor    %esi,%esi
  80216e:	bf 01 00 00 00       	mov    $0x1,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  802173:	89 f8                	mov    %edi,%eax
  802175:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  802177:	83 c4 10             	add    $0x10,%esp
  80217a:	5e                   	pop    %esi
  80217b:	5f                   	pop    %edi
  80217c:	c9                   	leave  
  80217d:	c3                   	ret    
  80217e:	66 90                	xchg   %ax,%ax

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  802180:	8b 55 f0             	mov    -0x10(%ebp),%edx
  802183:	89 f9                	mov    %edi,%ecx
  802185:	d3 e2                	shl    %cl,%edx

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  802187:	39 c2                	cmp    %eax,%edx
  802189:	73 db                	jae    802166 <__udivdi3+0xea>
  80218b:	90                   	nop
		{
		  q0--;
  80218c:	8d 7e ff             	lea    -0x1(%esi),%edi
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  80218f:	31 f6                	xor    %esi,%esi
  802191:	e9 56 ff ff ff       	jmp    8020ec <__udivdi3+0x70>
	...

00802198 <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  802198:	55                   	push   %ebp
  802199:	89 e5                	mov    %esp,%ebp
  80219b:	57                   	push   %edi
  80219c:	56                   	push   %esi
  80219d:	83 ec 20             	sub    $0x20,%esp
  8021a0:	8b 45 08             	mov    0x8(%ebp),%eax
  8021a3:	8b 4d 10             	mov    0x10(%ebp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  8021a6:	89 45 e8             	mov    %eax,-0x18(%ebp)
  8021a9:	8b 75 0c             	mov    0xc(%ebp),%esi
  const DWunion dd = {.ll = d};
  8021ac:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  8021af:	8b 7d 14             	mov    0x14(%ebp),%edi
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  8021b2:	89 45 f0             	mov    %eax,-0x10(%ebp)
  n1 = nn.s.high;
  8021b5:	89 f2                	mov    %esi,%edx

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  8021b7:	85 ff                	test   %edi,%edi
  8021b9:	75 15                	jne    8021d0 <__umoddi3+0x38>
    {
      if (d0 > n1)
  8021bb:	39 f1                	cmp    %esi,%ecx
  8021bd:	0f 86 99 00 00 00    	jbe    80225c <__umoddi3+0xc4>
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  8021c3:	f7 f1                	div    %ecx

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
  8021c5:	89 d0                	mov    %edx,%eax
  8021c7:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  8021c9:	83 c4 20             	add    $0x20,%esp
  8021cc:	5e                   	pop    %esi
  8021cd:	5f                   	pop    %edi
  8021ce:	c9                   	leave  
  8021cf:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  8021d0:	39 f7                	cmp    %esi,%edi
  8021d2:	0f 87 a4 00 00 00    	ja     80227c <__umoddi3+0xe4>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  8021d8:	0f bd c7             	bsr    %edi,%eax
	  if (bm == 0)
  8021db:	83 f0 1f             	xor    $0x1f,%eax
  8021de:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8021e1:	0f 84 a1 00 00 00    	je     802288 <__umoddi3+0xf0>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  8021e7:	89 f8                	mov    %edi,%eax
  8021e9:	8a 4d ec             	mov    -0x14(%ebp),%cl
  8021ec:	d3 e0                	shl    %cl,%eax
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  8021ee:	bf 20 00 00 00       	mov    $0x20,%edi
  8021f3:	2b 7d ec             	sub    -0x14(%ebp),%edi

	      d1 = (d1 << bm) | (d0 >> b);
  8021f6:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8021f9:	89 f9                	mov    %edi,%ecx
  8021fb:	d3 ea                	shr    %cl,%edx
  8021fd:	09 c2                	or     %eax,%edx
  8021ff:	89 55 f0             	mov    %edx,-0x10(%ebp)
	      d0 = d0 << bm;
  802202:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802205:	8a 4d ec             	mov    -0x14(%ebp),%cl
  802208:	d3 e0                	shl    %cl,%eax
  80220a:	89 45 f4             	mov    %eax,-0xc(%ebp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  80220d:	89 f2                	mov    %esi,%edx
  80220f:	d3 e2                	shl    %cl,%edx
	      n0 = n0 << bm;
  802211:	8b 45 e8             	mov    -0x18(%ebp),%eax
  802214:	d3 e0                	shl    %cl,%eax
  802216:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  802219:	8b 45 e8             	mov    -0x18(%ebp),%eax
  80221c:	89 f9                	mov    %edi,%ecx
  80221e:	d3 e8                	shr    %cl,%eax
  802220:	09 d0                	or     %edx,%eax

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  802222:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  802224:	89 f2                	mov    %esi,%edx
  802226:	f7 75 f0             	divl   -0x10(%ebp)
  802229:	89 d6                	mov    %edx,%esi
	      umul_ppmm (m1, m0, q0, d0);
  80222b:	f7 65 f4             	mull   -0xc(%ebp)
  80222e:	89 55 e8             	mov    %edx,-0x18(%ebp)
  802231:	89 c1                	mov    %eax,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  802233:	39 d6                	cmp    %edx,%esi
  802235:	72 71                	jb     8022a8 <__umoddi3+0x110>
  802237:	74 7f                	je     8022b8 <__umoddi3+0x120>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  802239:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80223c:	29 c8                	sub    %ecx,%eax
  80223e:	19 d6                	sbb    %edx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
  802240:	8a 4d ec             	mov    -0x14(%ebp),%cl
  802243:	d3 e8                	shr    %cl,%eax
  802245:	89 f2                	mov    %esi,%edx
  802247:	89 f9                	mov    %edi,%ecx
  802249:	d3 e2                	shl    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
  80224b:	09 d0                	or     %edx,%eax
  80224d:	89 f2                	mov    %esi,%edx
  80224f:	8a 4d ec             	mov    -0x14(%ebp),%cl
  802252:	d3 ea                	shr    %cl,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  802254:	83 c4 20             	add    $0x20,%esp
  802257:	5e                   	pop    %esi
  802258:	5f                   	pop    %edi
  802259:	c9                   	leave  
  80225a:	c3                   	ret    
  80225b:	90                   	nop
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  80225c:	85 c9                	test   %ecx,%ecx
  80225e:	75 0b                	jne    80226b <__umoddi3+0xd3>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  802260:	b8 01 00 00 00       	mov    $0x1,%eax
  802265:	31 d2                	xor    %edx,%edx
  802267:	f7 f1                	div    %ecx
  802269:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  80226b:	89 f0                	mov    %esi,%eax
  80226d:	31 d2                	xor    %edx,%edx
  80226f:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  802271:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802274:	f7 f1                	div    %ecx
  802276:	e9 4a ff ff ff       	jmp    8021c5 <__umoddi3+0x2d>
  80227b:	90                   	nop
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
  80227c:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  80227e:	83 c4 20             	add    $0x20,%esp
  802281:	5e                   	pop    %esi
  802282:	5f                   	pop    %edi
  802283:	c9                   	leave  
  802284:	c3                   	ret    
  802285:	8d 76 00             	lea    0x0(%esi),%esi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  802288:	39 f7                	cmp    %esi,%edi
  80228a:	72 05                	jb     802291 <__umoddi3+0xf9>
  80228c:	3b 4d f0             	cmp    -0x10(%ebp),%ecx
  80228f:	77 0c                	ja     80229d <__umoddi3+0x105>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  802291:	89 f2                	mov    %esi,%edx
  802293:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802296:	29 c8                	sub    %ecx,%eax
  802298:	19 fa                	sbb    %edi,%edx
  80229a:	89 45 f0             	mov    %eax,-0x10(%ebp)

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
  80229d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  8022a0:	83 c4 20             	add    $0x20,%esp
  8022a3:	5e                   	pop    %esi
  8022a4:	5f                   	pop    %edi
  8022a5:	c9                   	leave  
  8022a6:	c3                   	ret    
  8022a7:	90                   	nop
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  8022a8:	8b 55 e8             	mov    -0x18(%ebp),%edx
  8022ab:	89 c1                	mov    %eax,%ecx
  8022ad:	2b 4d f4             	sub    -0xc(%ebp),%ecx
  8022b0:	1b 55 f0             	sbb    -0x10(%ebp),%edx
  8022b3:	eb 84                	jmp    802239 <__umoddi3+0xa1>
  8022b5:	8d 76 00             	lea    0x0(%esi),%esi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  8022b8:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  8022bb:	72 eb                	jb     8022a8 <__umoddi3+0x110>
  8022bd:	89 f2                	mov    %esi,%edx
  8022bf:	e9 75 ff ff ff       	jmp    802239 <__umoddi3+0xa1>
