
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
  80005e:	68 c2 22 80 00       	push   $0x8022c2
  800063:	e8 54 19 00 00       	call   8019bc <printf>
  800068:	83 c4 10             	add    $0x10,%esp
	if(prefix) {
  80006b:	85 db                	test   %ebx,%ebx
  80006d:	74 3d                	je     8000ac <ls1+0x78>
		if (prefix[0] && prefix[strlen(prefix)-1] != '/')
  80006f:	80 3b 00             	cmpb   $0x0,(%ebx)
  800072:	74 1a                	je     80008e <ls1+0x5a>
  800074:	83 ec 0c             	sub    $0xc,%esp
  800077:	53                   	push   %ebx
  800078:	e8 03 09 00 00       	call   800980 <strlen>
  80007d:	83 c4 10             	add    $0x10,%esp
  800080:	80 7c 03 ff 2f       	cmpb   $0x2f,-0x1(%ebx,%eax,1)
  800085:	74 0e                	je     800095 <ls1+0x61>
			sep = "/";
  800087:	b8 c0 22 80 00       	mov    $0x8022c0,%eax
  80008c:	eb 0c                	jmp    80009a <ls1+0x66>
		else
			sep = "";
  80008e:	b8 7a 27 80 00       	mov    $0x80277a,%eax
  800093:	eb 05                	jmp    80009a <ls1+0x66>
  800095:	b8 7a 27 80 00       	mov    $0x80277a,%eax
		printf("%s%s", prefix, sep);
  80009a:	83 ec 04             	sub    $0x4,%esp
  80009d:	50                   	push   %eax
  80009e:	53                   	push   %ebx
  80009f:	68 cb 22 80 00       	push   $0x8022cb
  8000a4:	e8 13 19 00 00       	call   8019bc <printf>
  8000a9:	83 c4 10             	add    $0x10,%esp
	}
	printf("%s", name);
  8000ac:	83 ec 08             	sub    $0x8,%esp
  8000af:	ff 75 14             	pushl  0x14(%ebp)
  8000b2:	68 5b 27 80 00       	push   $0x80275b
  8000b7:	e8 00 19 00 00       	call   8019bc <printf>
	if(flag['F'] && isdir)
  8000bc:	83 c4 10             	add    $0x10,%esp
  8000bf:	83 3d 38 41 80 00 00 	cmpl   $0x0,0x804138
  8000c6:	74 16                	je     8000de <ls1+0xaa>
  8000c8:	80 7d f7 00          	cmpb   $0x0,-0x9(%ebp)
  8000cc:	74 10                	je     8000de <ls1+0xaa>
		printf("/");
  8000ce:	83 ec 0c             	sub    $0xc,%esp
  8000d1:	68 c0 22 80 00       	push   $0x8022c0
  8000d6:	e8 e1 18 00 00       	call   8019bc <printf>
  8000db:	83 c4 10             	add    $0x10,%esp
	printf("\n");
  8000de:	83 ec 0c             	sub    $0xc,%esp
  8000e1:	68 79 27 80 00       	push   $0x802779
  8000e6:	e8 d1 18 00 00       	call   8019bc <printf>
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
  800107:	e8 17 17 00 00       	call   801823 <open>
  80010c:	89 c6                	mov    %eax,%esi
  80010e:	83 c4 10             	add    $0x10,%esp
  800111:	85 c0                	test   %eax,%eax
  800113:	79 41                	jns    800156 <lsdir+0x63>
		panic("open %s: %e", path, fd);
  800115:	83 ec 0c             	sub    $0xc,%esp
  800118:	50                   	push   %eax
  800119:	ff 75 08             	pushl  0x8(%ebp)
  80011c:	68 d0 22 80 00       	push   $0x8022d0
  800121:	6a 1d                	push   $0x1d
  800123:	68 dc 22 80 00       	push   $0x8022dc
  800128:	e8 17 02 00 00       	call   800344 <_panic>
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
  800166:	e8 28 13 00 00       	call   801493 <readn>
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
  80017c:	68 e6 22 80 00       	push   $0x8022e6
  800181:	6a 22                	push   $0x22
  800183:	68 dc 22 80 00       	push   $0x8022dc
  800188:	e8 b7 01 00 00       	call   800344 <_panic>
	if (n < 0)
  80018d:	85 c0                	test   %eax,%eax
  80018f:	79 18                	jns    8001a9 <lsdir+0xb6>
		panic("error reading directory %s: %e", path, n);
  800191:	83 ec 0c             	sub    $0xc,%esp
  800194:	50                   	push   %eax
  800195:	ff 75 08             	pushl  0x8(%ebp)
  800198:	68 2c 23 80 00       	push   $0x80232c
  80019d:	6a 24                	push   $0x24
  80019f:	68 dc 22 80 00       	push   $0x8022dc
  8001a4:	e8 9b 01 00 00       	call   800344 <_panic>
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
  8001c6:	e8 bb 14 00 00       	call   801686 <stat>
  8001cb:	83 c4 10             	add    $0x10,%esp
  8001ce:	85 c0                	test   %eax,%eax
  8001d0:	79 16                	jns    8001e8 <ls+0x37>
		panic("stat %s: %e", path, r);
  8001d2:	83 ec 0c             	sub    $0xc,%esp
  8001d5:	50                   	push   %eax
  8001d6:	53                   	push   %ebx
  8001d7:	68 01 23 80 00       	push   $0x802301
  8001dc:	6a 0f                	push   $0xf
  8001de:	68 dc 22 80 00       	push   $0x8022dc
  8001e3:	e8 5c 01 00 00       	call   800344 <_panic>
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
  80022b:	68 0d 23 80 00       	push   $0x80230d
  800230:	e8 87 17 00 00       	call   8019bc <printf>
	exit();
  800235:	e8 ee 00 00 00       	call   800328 <exit>
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
  800253:	e8 3c 0d 00 00       	call   800f94 <argstart>
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
  800281:	e8 47 0d 00 00       	call   800fcd <argnext>
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
  80029f:	68 7a 27 80 00       	push   $0x80277a
  8002a4:	68 c0 22 80 00       	push   $0x8022c0
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
  8002e3:	e8 21 0b 00 00       	call   800e09 <sys_getenvid>
  8002e8:	25 ff 03 00 00       	and    $0x3ff,%eax
  8002ed:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  8002f4:	c1 e0 07             	shl    $0x7,%eax
  8002f7:	29 d0                	sub    %edx,%eax
  8002f9:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8002fe:	a3 20 44 80 00       	mov    %eax,0x804420

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800303:	85 f6                	test   %esi,%esi
  800305:	7e 07                	jle    80030e <libmain+0x36>
		binaryname = argv[0];
  800307:	8b 03                	mov    (%ebx),%eax
  800309:	a3 00 30 80 00       	mov    %eax,0x803000
	// call user main routine
	umain(argc, argv);
  80030e:	83 ec 08             	sub    $0x8,%esp
  800311:	53                   	push   %ebx
  800312:	56                   	push   %esi
  800313:	e8 27 ff ff ff       	call   80023f <umain>

	// exit gracefully
	exit();
  800318:	e8 0b 00 00 00       	call   800328 <exit>
  80031d:	83 c4 10             	add    $0x10,%esp
}
  800320:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800323:	5b                   	pop    %ebx
  800324:	5e                   	pop    %esi
  800325:	c9                   	leave  
  800326:	c3                   	ret    
	...

00800328 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800328:	55                   	push   %ebp
  800329:	89 e5                	mov    %esp,%ebp
  80032b:	83 ec 08             	sub    $0x8,%esp
	close_all();
  80032e:	e8 c7 0f 00 00       	call   8012fa <close_all>
	sys_env_destroy(0);
  800333:	83 ec 0c             	sub    $0xc,%esp
  800336:	6a 00                	push   $0x0
  800338:	e8 aa 0a 00 00       	call   800de7 <sys_env_destroy>
  80033d:	83 c4 10             	add    $0x10,%esp
}
  800340:	c9                   	leave  
  800341:	c3                   	ret    
	...

00800344 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800344:	55                   	push   %ebp
  800345:	89 e5                	mov    %esp,%ebp
  800347:	56                   	push   %esi
  800348:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800349:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80034c:	8b 1d 00 30 80 00    	mov    0x803000,%ebx
  800352:	e8 b2 0a 00 00       	call   800e09 <sys_getenvid>
  800357:	83 ec 0c             	sub    $0xc,%esp
  80035a:	ff 75 0c             	pushl  0xc(%ebp)
  80035d:	ff 75 08             	pushl  0x8(%ebp)
  800360:	53                   	push   %ebx
  800361:	50                   	push   %eax
  800362:	68 58 23 80 00       	push   $0x802358
  800367:	e8 b0 00 00 00       	call   80041c <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80036c:	83 c4 18             	add    $0x18,%esp
  80036f:	56                   	push   %esi
  800370:	ff 75 10             	pushl  0x10(%ebp)
  800373:	e8 53 00 00 00       	call   8003cb <vcprintf>
	cprintf("\n");
  800378:	c7 04 24 79 27 80 00 	movl   $0x802779,(%esp)
  80037f:	e8 98 00 00 00       	call   80041c <cprintf>
  800384:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800387:	cc                   	int3   
  800388:	eb fd                	jmp    800387 <_panic+0x43>
	...

0080038c <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80038c:	55                   	push   %ebp
  80038d:	89 e5                	mov    %esp,%ebp
  80038f:	53                   	push   %ebx
  800390:	83 ec 04             	sub    $0x4,%esp
  800393:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800396:	8b 03                	mov    (%ebx),%eax
  800398:	8b 55 08             	mov    0x8(%ebp),%edx
  80039b:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  80039f:	40                   	inc    %eax
  8003a0:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  8003a2:	3d ff 00 00 00       	cmp    $0xff,%eax
  8003a7:	75 1a                	jne    8003c3 <putch+0x37>
		sys_cputs(b->buf, b->idx);
  8003a9:	83 ec 08             	sub    $0x8,%esp
  8003ac:	68 ff 00 00 00       	push   $0xff
  8003b1:	8d 43 08             	lea    0x8(%ebx),%eax
  8003b4:	50                   	push   %eax
  8003b5:	e8 e3 09 00 00       	call   800d9d <sys_cputs>
		b->idx = 0;
  8003ba:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8003c0:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8003c3:	ff 43 04             	incl   0x4(%ebx)
}
  8003c6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8003c9:	c9                   	leave  
  8003ca:	c3                   	ret    

008003cb <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8003cb:	55                   	push   %ebp
  8003cc:	89 e5                	mov    %esp,%ebp
  8003ce:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8003d4:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8003db:	00 00 00 
	b.cnt = 0;
  8003de:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8003e5:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8003e8:	ff 75 0c             	pushl  0xc(%ebp)
  8003eb:	ff 75 08             	pushl  0x8(%ebp)
  8003ee:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8003f4:	50                   	push   %eax
  8003f5:	68 8c 03 80 00       	push   $0x80038c
  8003fa:	e8 82 01 00 00       	call   800581 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8003ff:	83 c4 08             	add    $0x8,%esp
  800402:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800408:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80040e:	50                   	push   %eax
  80040f:	e8 89 09 00 00       	call   800d9d <sys_cputs>

	return b.cnt;
}
  800414:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80041a:	c9                   	leave  
  80041b:	c3                   	ret    

0080041c <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80041c:	55                   	push   %ebp
  80041d:	89 e5                	mov    %esp,%ebp
  80041f:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800422:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800425:	50                   	push   %eax
  800426:	ff 75 08             	pushl  0x8(%ebp)
  800429:	e8 9d ff ff ff       	call   8003cb <vcprintf>
	va_end(ap);

	return cnt;
}
  80042e:	c9                   	leave  
  80042f:	c3                   	ret    

00800430 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800430:	55                   	push   %ebp
  800431:	89 e5                	mov    %esp,%ebp
  800433:	57                   	push   %edi
  800434:	56                   	push   %esi
  800435:	53                   	push   %ebx
  800436:	83 ec 2c             	sub    $0x2c,%esp
  800439:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80043c:	89 d6                	mov    %edx,%esi
  80043e:	8b 45 08             	mov    0x8(%ebp),%eax
  800441:	8b 55 0c             	mov    0xc(%ebp),%edx
  800444:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800447:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80044a:	8b 45 10             	mov    0x10(%ebp),%eax
  80044d:	8b 5d 14             	mov    0x14(%ebp),%ebx
  800450:	8b 7d 18             	mov    0x18(%ebp),%edi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800453:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800456:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  80045d:	39 55 d4             	cmp    %edx,-0x2c(%ebp)
  800460:	72 0c                	jb     80046e <printnum+0x3e>
  800462:	3b 45 d8             	cmp    -0x28(%ebp),%eax
  800465:	76 07                	jbe    80046e <printnum+0x3e>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800467:	4b                   	dec    %ebx
  800468:	85 db                	test   %ebx,%ebx
  80046a:	7f 31                	jg     80049d <printnum+0x6d>
  80046c:	eb 3f                	jmp    8004ad <printnum+0x7d>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80046e:	83 ec 0c             	sub    $0xc,%esp
  800471:	57                   	push   %edi
  800472:	4b                   	dec    %ebx
  800473:	53                   	push   %ebx
  800474:	50                   	push   %eax
  800475:	83 ec 08             	sub    $0x8,%esp
  800478:	ff 75 d4             	pushl  -0x2c(%ebp)
  80047b:	ff 75 d0             	pushl  -0x30(%ebp)
  80047e:	ff 75 dc             	pushl  -0x24(%ebp)
  800481:	ff 75 d8             	pushl  -0x28(%ebp)
  800484:	e8 eb 1b 00 00       	call   802074 <__udivdi3>
  800489:	83 c4 18             	add    $0x18,%esp
  80048c:	52                   	push   %edx
  80048d:	50                   	push   %eax
  80048e:	89 f2                	mov    %esi,%edx
  800490:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800493:	e8 98 ff ff ff       	call   800430 <printnum>
  800498:	83 c4 20             	add    $0x20,%esp
  80049b:	eb 10                	jmp    8004ad <printnum+0x7d>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80049d:	83 ec 08             	sub    $0x8,%esp
  8004a0:	56                   	push   %esi
  8004a1:	57                   	push   %edi
  8004a2:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8004a5:	4b                   	dec    %ebx
  8004a6:	83 c4 10             	add    $0x10,%esp
  8004a9:	85 db                	test   %ebx,%ebx
  8004ab:	7f f0                	jg     80049d <printnum+0x6d>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8004ad:	83 ec 08             	sub    $0x8,%esp
  8004b0:	56                   	push   %esi
  8004b1:	83 ec 04             	sub    $0x4,%esp
  8004b4:	ff 75 d4             	pushl  -0x2c(%ebp)
  8004b7:	ff 75 d0             	pushl  -0x30(%ebp)
  8004ba:	ff 75 dc             	pushl  -0x24(%ebp)
  8004bd:	ff 75 d8             	pushl  -0x28(%ebp)
  8004c0:	e8 cb 1c 00 00       	call   802190 <__umoddi3>
  8004c5:	83 c4 14             	add    $0x14,%esp
  8004c8:	0f be 80 7b 23 80 00 	movsbl 0x80237b(%eax),%eax
  8004cf:	50                   	push   %eax
  8004d0:	ff 55 e4             	call   *-0x1c(%ebp)
  8004d3:	83 c4 10             	add    $0x10,%esp
}
  8004d6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8004d9:	5b                   	pop    %ebx
  8004da:	5e                   	pop    %esi
  8004db:	5f                   	pop    %edi
  8004dc:	c9                   	leave  
  8004dd:	c3                   	ret    

008004de <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8004de:	55                   	push   %ebp
  8004df:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8004e1:	83 fa 01             	cmp    $0x1,%edx
  8004e4:	7e 0e                	jle    8004f4 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8004e6:	8b 10                	mov    (%eax),%edx
  8004e8:	8d 4a 08             	lea    0x8(%edx),%ecx
  8004eb:	89 08                	mov    %ecx,(%eax)
  8004ed:	8b 02                	mov    (%edx),%eax
  8004ef:	8b 52 04             	mov    0x4(%edx),%edx
  8004f2:	eb 22                	jmp    800516 <getuint+0x38>
	else if (lflag)
  8004f4:	85 d2                	test   %edx,%edx
  8004f6:	74 10                	je     800508 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8004f8:	8b 10                	mov    (%eax),%edx
  8004fa:	8d 4a 04             	lea    0x4(%edx),%ecx
  8004fd:	89 08                	mov    %ecx,(%eax)
  8004ff:	8b 02                	mov    (%edx),%eax
  800501:	ba 00 00 00 00       	mov    $0x0,%edx
  800506:	eb 0e                	jmp    800516 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800508:	8b 10                	mov    (%eax),%edx
  80050a:	8d 4a 04             	lea    0x4(%edx),%ecx
  80050d:	89 08                	mov    %ecx,(%eax)
  80050f:	8b 02                	mov    (%edx),%eax
  800511:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800516:	c9                   	leave  
  800517:	c3                   	ret    

00800518 <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
  800518:	55                   	push   %ebp
  800519:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80051b:	83 fa 01             	cmp    $0x1,%edx
  80051e:	7e 0e                	jle    80052e <getint+0x16>
		return va_arg(*ap, long long);
  800520:	8b 10                	mov    (%eax),%edx
  800522:	8d 4a 08             	lea    0x8(%edx),%ecx
  800525:	89 08                	mov    %ecx,(%eax)
  800527:	8b 02                	mov    (%edx),%eax
  800529:	8b 52 04             	mov    0x4(%edx),%edx
  80052c:	eb 1a                	jmp    800548 <getint+0x30>
	else if (lflag)
  80052e:	85 d2                	test   %edx,%edx
  800530:	74 0c                	je     80053e <getint+0x26>
		return va_arg(*ap, long);
  800532:	8b 10                	mov    (%eax),%edx
  800534:	8d 4a 04             	lea    0x4(%edx),%ecx
  800537:	89 08                	mov    %ecx,(%eax)
  800539:	8b 02                	mov    (%edx),%eax
  80053b:	99                   	cltd   
  80053c:	eb 0a                	jmp    800548 <getint+0x30>
	else
		return va_arg(*ap, int);
  80053e:	8b 10                	mov    (%eax),%edx
  800540:	8d 4a 04             	lea    0x4(%edx),%ecx
  800543:	89 08                	mov    %ecx,(%eax)
  800545:	8b 02                	mov    (%edx),%eax
  800547:	99                   	cltd   
}
  800548:	c9                   	leave  
  800549:	c3                   	ret    

0080054a <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80054a:	55                   	push   %ebp
  80054b:	89 e5                	mov    %esp,%ebp
  80054d:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800550:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  800553:	8b 10                	mov    (%eax),%edx
  800555:	3b 50 04             	cmp    0x4(%eax),%edx
  800558:	73 08                	jae    800562 <sprintputch+0x18>
		*b->buf++ = ch;
  80055a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80055d:	88 0a                	mov    %cl,(%edx)
  80055f:	42                   	inc    %edx
  800560:	89 10                	mov    %edx,(%eax)
}
  800562:	c9                   	leave  
  800563:	c3                   	ret    

00800564 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800564:	55                   	push   %ebp
  800565:	89 e5                	mov    %esp,%ebp
  800567:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  80056a:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80056d:	50                   	push   %eax
  80056e:	ff 75 10             	pushl  0x10(%ebp)
  800571:	ff 75 0c             	pushl  0xc(%ebp)
  800574:	ff 75 08             	pushl  0x8(%ebp)
  800577:	e8 05 00 00 00       	call   800581 <vprintfmt>
	va_end(ap);
  80057c:	83 c4 10             	add    $0x10,%esp
}
  80057f:	c9                   	leave  
  800580:	c3                   	ret    

00800581 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800581:	55                   	push   %ebp
  800582:	89 e5                	mov    %esp,%ebp
  800584:	57                   	push   %edi
  800585:	56                   	push   %esi
  800586:	53                   	push   %ebx
  800587:	83 ec 2c             	sub    $0x2c,%esp
  80058a:	8b 7d 0c             	mov    0xc(%ebp),%edi
  80058d:	8b 75 10             	mov    0x10(%ebp),%esi
  800590:	eb 13                	jmp    8005a5 <vprintfmt+0x24>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800592:	85 c0                	test   %eax,%eax
  800594:	0f 84 6d 03 00 00    	je     800907 <vprintfmt+0x386>
				return;
			putch(ch, putdat);
  80059a:	83 ec 08             	sub    $0x8,%esp
  80059d:	57                   	push   %edi
  80059e:	50                   	push   %eax
  80059f:	ff 55 08             	call   *0x8(%ebp)
  8005a2:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8005a5:	0f b6 06             	movzbl (%esi),%eax
  8005a8:	46                   	inc    %esi
  8005a9:	83 f8 25             	cmp    $0x25,%eax
  8005ac:	75 e4                	jne    800592 <vprintfmt+0x11>
  8005ae:	c6 45 dc 20          	movb   $0x20,-0x24(%ebp)
  8005b2:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  8005b9:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
  8005c0:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  8005c7:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005cc:	eb 28                	jmp    8005f6 <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005ce:	89 de                	mov    %ebx,%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  8005d0:	c6 45 dc 2d          	movb   $0x2d,-0x24(%ebp)
  8005d4:	eb 20                	jmp    8005f6 <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005d6:	89 de                	mov    %ebx,%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8005d8:	c6 45 dc 30          	movb   $0x30,-0x24(%ebp)
  8005dc:	eb 18                	jmp    8005f6 <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005de:	89 de                	mov    %ebx,%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  8005e0:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  8005e7:	eb 0d                	jmp    8005f6 <vprintfmt+0x75>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  8005e9:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8005ec:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8005ef:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005f6:	8a 06                	mov    (%esi),%al
  8005f8:	0f b6 d0             	movzbl %al,%edx
  8005fb:	8d 5e 01             	lea    0x1(%esi),%ebx
  8005fe:	83 e8 23             	sub    $0x23,%eax
  800601:	3c 55                	cmp    $0x55,%al
  800603:	0f 87 e0 02 00 00    	ja     8008e9 <vprintfmt+0x368>
  800609:	0f b6 c0             	movzbl %al,%eax
  80060c:	ff 24 85 c0 24 80 00 	jmp    *0x8024c0(,%eax,4)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800613:	83 ea 30             	sub    $0x30,%edx
  800616:	89 55 d4             	mov    %edx,-0x2c(%ebp)
				ch = *fmt;
  800619:	0f be 03             	movsbl (%ebx),%eax
				if (ch < '0' || ch > '9')
  80061c:	8d 50 d0             	lea    -0x30(%eax),%edx
  80061f:	83 fa 09             	cmp    $0x9,%edx
  800622:	77 44                	ja     800668 <vprintfmt+0xe7>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800624:	89 de                	mov    %ebx,%esi
  800626:	8b 55 d4             	mov    -0x2c(%ebp),%edx
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800629:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
  80062a:	8d 14 92             	lea    (%edx,%edx,4),%edx
  80062d:	8d 54 50 d0          	lea    -0x30(%eax,%edx,2),%edx
				ch = *fmt;
  800631:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  800634:	8d 58 d0             	lea    -0x30(%eax),%ebx
  800637:	83 fb 09             	cmp    $0x9,%ebx
  80063a:	76 ed                	jbe    800629 <vprintfmt+0xa8>
  80063c:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  80063f:	eb 29                	jmp    80066a <vprintfmt+0xe9>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800641:	8b 45 14             	mov    0x14(%ebp),%eax
  800644:	8d 50 04             	lea    0x4(%eax),%edx
  800647:	89 55 14             	mov    %edx,0x14(%ebp)
  80064a:	8b 00                	mov    (%eax),%eax
  80064c:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80064f:	89 de                	mov    %ebx,%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800651:	eb 17                	jmp    80066a <vprintfmt+0xe9>

		case '.':
			if (width < 0)
  800653:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800657:	78 85                	js     8005de <vprintfmt+0x5d>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800659:	89 de                	mov    %ebx,%esi
  80065b:	eb 99                	jmp    8005f6 <vprintfmt+0x75>
  80065d:	89 de                	mov    %ebx,%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  80065f:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
			goto reswitch;
  800666:	eb 8e                	jmp    8005f6 <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800668:	89 de                	mov    %ebx,%esi
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  80066a:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80066e:	79 86                	jns    8005f6 <vprintfmt+0x75>
  800670:	e9 74 ff ff ff       	jmp    8005e9 <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800675:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800676:	89 de                	mov    %ebx,%esi
  800678:	e9 79 ff ff ff       	jmp    8005f6 <vprintfmt+0x75>
  80067d:	89 5d d8             	mov    %ebx,-0x28(%ebp)
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800680:	8b 45 14             	mov    0x14(%ebp),%eax
  800683:	8d 50 04             	lea    0x4(%eax),%edx
  800686:	89 55 14             	mov    %edx,0x14(%ebp)
  800689:	83 ec 08             	sub    $0x8,%esp
  80068c:	57                   	push   %edi
  80068d:	ff 30                	pushl  (%eax)
  80068f:	ff 55 08             	call   *0x8(%ebp)
			break;
  800692:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800695:	8b 75 d8             	mov    -0x28(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800698:	e9 08 ff ff ff       	jmp    8005a5 <vprintfmt+0x24>
  80069d:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// error message
		case 'e':
			err = va_arg(ap, int);
  8006a0:	8b 45 14             	mov    0x14(%ebp),%eax
  8006a3:	8d 50 04             	lea    0x4(%eax),%edx
  8006a6:	89 55 14             	mov    %edx,0x14(%ebp)
  8006a9:	8b 00                	mov    (%eax),%eax
  8006ab:	85 c0                	test   %eax,%eax
  8006ad:	79 02                	jns    8006b1 <vprintfmt+0x130>
  8006af:	f7 d8                	neg    %eax
  8006b1:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8006b3:	83 f8 0f             	cmp    $0xf,%eax
  8006b6:	7f 0b                	jg     8006c3 <vprintfmt+0x142>
  8006b8:	8b 04 85 20 26 80 00 	mov    0x802620(,%eax,4),%eax
  8006bf:	85 c0                	test   %eax,%eax
  8006c1:	75 1a                	jne    8006dd <vprintfmt+0x15c>
				printfmt(putch, putdat, "error %d", err);
  8006c3:	52                   	push   %edx
  8006c4:	68 93 23 80 00       	push   $0x802393
  8006c9:	57                   	push   %edi
  8006ca:	ff 75 08             	pushl  0x8(%ebp)
  8006cd:	e8 92 fe ff ff       	call   800564 <printfmt>
  8006d2:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006d5:	8b 75 d8             	mov    -0x28(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8006d8:	e9 c8 fe ff ff       	jmp    8005a5 <vprintfmt+0x24>
			else
				printfmt(putch, putdat, "%s", p);
  8006dd:	50                   	push   %eax
  8006de:	68 5b 27 80 00       	push   $0x80275b
  8006e3:	57                   	push   %edi
  8006e4:	ff 75 08             	pushl  0x8(%ebp)
  8006e7:	e8 78 fe ff ff       	call   800564 <printfmt>
  8006ec:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006ef:	8b 75 d8             	mov    -0x28(%ebp),%esi
  8006f2:	e9 ae fe ff ff       	jmp    8005a5 <vprintfmt+0x24>
  8006f7:	89 5d d8             	mov    %ebx,-0x28(%ebp)
  8006fa:	89 de                	mov    %ebx,%esi
  8006fc:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  8006ff:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800702:	8b 45 14             	mov    0x14(%ebp),%eax
  800705:	8d 50 04             	lea    0x4(%eax),%edx
  800708:	89 55 14             	mov    %edx,0x14(%ebp)
  80070b:	8b 00                	mov    (%eax),%eax
  80070d:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800710:	85 c0                	test   %eax,%eax
  800712:	75 07                	jne    80071b <vprintfmt+0x19a>
				p = "(null)";
  800714:	c7 45 d0 8c 23 80 00 	movl   $0x80238c,-0x30(%ebp)
			if (width > 0 && padc != '-')
  80071b:	85 db                	test   %ebx,%ebx
  80071d:	7e 42                	jle    800761 <vprintfmt+0x1e0>
  80071f:	80 7d dc 2d          	cmpb   $0x2d,-0x24(%ebp)
  800723:	74 3c                	je     800761 <vprintfmt+0x1e0>
				for (width -= strnlen(p, precision); width > 0; width--)
  800725:	83 ec 08             	sub    $0x8,%esp
  800728:	51                   	push   %ecx
  800729:	ff 75 d0             	pushl  -0x30(%ebp)
  80072c:	e8 6f 02 00 00       	call   8009a0 <strnlen>
  800731:	29 c3                	sub    %eax,%ebx
  800733:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800736:	83 c4 10             	add    $0x10,%esp
  800739:	85 db                	test   %ebx,%ebx
  80073b:	7e 24                	jle    800761 <vprintfmt+0x1e0>
					putch(padc, putdat);
  80073d:	0f be 5d dc          	movsbl -0x24(%ebp),%ebx
  800741:	89 75 dc             	mov    %esi,-0x24(%ebp)
  800744:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  800747:	83 ec 08             	sub    $0x8,%esp
  80074a:	57                   	push   %edi
  80074b:	53                   	push   %ebx
  80074c:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80074f:	4e                   	dec    %esi
  800750:	83 c4 10             	add    $0x10,%esp
  800753:	85 f6                	test   %esi,%esi
  800755:	7f f0                	jg     800747 <vprintfmt+0x1c6>
  800757:	8b 75 dc             	mov    -0x24(%ebp),%esi
  80075a:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800761:	8b 55 d0             	mov    -0x30(%ebp),%edx
  800764:	0f be 02             	movsbl (%edx),%eax
  800767:	85 c0                	test   %eax,%eax
  800769:	75 47                	jne    8007b2 <vprintfmt+0x231>
  80076b:	eb 37                	jmp    8007a4 <vprintfmt+0x223>
				if (altflag && (ch < ' ' || ch > '~'))
  80076d:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800771:	74 16                	je     800789 <vprintfmt+0x208>
  800773:	8d 50 e0             	lea    -0x20(%eax),%edx
  800776:	83 fa 5e             	cmp    $0x5e,%edx
  800779:	76 0e                	jbe    800789 <vprintfmt+0x208>
					putch('?', putdat);
  80077b:	83 ec 08             	sub    $0x8,%esp
  80077e:	57                   	push   %edi
  80077f:	6a 3f                	push   $0x3f
  800781:	ff 55 08             	call   *0x8(%ebp)
  800784:	83 c4 10             	add    $0x10,%esp
  800787:	eb 0b                	jmp    800794 <vprintfmt+0x213>
				else
					putch(ch, putdat);
  800789:	83 ec 08             	sub    $0x8,%esp
  80078c:	57                   	push   %edi
  80078d:	50                   	push   %eax
  80078e:	ff 55 08             	call   *0x8(%ebp)
  800791:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800794:	ff 4d e4             	decl   -0x1c(%ebp)
  800797:	0f be 03             	movsbl (%ebx),%eax
  80079a:	85 c0                	test   %eax,%eax
  80079c:	74 03                	je     8007a1 <vprintfmt+0x220>
  80079e:	43                   	inc    %ebx
  80079f:	eb 1b                	jmp    8007bc <vprintfmt+0x23b>
  8007a1:	8b 75 dc             	mov    -0x24(%ebp),%esi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8007a4:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8007a8:	7f 1e                	jg     8007c8 <vprintfmt+0x247>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007aa:	8b 75 d8             	mov    -0x28(%ebp),%esi
  8007ad:	e9 f3 fd ff ff       	jmp    8005a5 <vprintfmt+0x24>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8007b2:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  8007b5:	43                   	inc    %ebx
  8007b6:	89 75 dc             	mov    %esi,-0x24(%ebp)
  8007b9:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  8007bc:	85 f6                	test   %esi,%esi
  8007be:	78 ad                	js     80076d <vprintfmt+0x1ec>
  8007c0:	4e                   	dec    %esi
  8007c1:	79 aa                	jns    80076d <vprintfmt+0x1ec>
  8007c3:	8b 75 dc             	mov    -0x24(%ebp),%esi
  8007c6:	eb dc                	jmp    8007a4 <vprintfmt+0x223>
  8007c8:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8007cb:	83 ec 08             	sub    $0x8,%esp
  8007ce:	57                   	push   %edi
  8007cf:	6a 20                	push   $0x20
  8007d1:	ff 55 08             	call   *0x8(%ebp)
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8007d4:	4b                   	dec    %ebx
  8007d5:	83 c4 10             	add    $0x10,%esp
  8007d8:	85 db                	test   %ebx,%ebx
  8007da:	7f ef                	jg     8007cb <vprintfmt+0x24a>
  8007dc:	e9 c4 fd ff ff       	jmp    8005a5 <vprintfmt+0x24>
  8007e1:	89 5d d8             	mov    %ebx,-0x28(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8007e4:	89 ca                	mov    %ecx,%edx
  8007e6:	8d 45 14             	lea    0x14(%ebp),%eax
  8007e9:	e8 2a fd ff ff       	call   800518 <getint>
  8007ee:	89 c3                	mov    %eax,%ebx
  8007f0:	89 d6                	mov    %edx,%esi
			if ((long long) num < 0) {
  8007f2:	85 d2                	test   %edx,%edx
  8007f4:	78 0a                	js     800800 <vprintfmt+0x27f>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8007f6:	b8 0a 00 00 00       	mov    $0xa,%eax
  8007fb:	e9 b0 00 00 00       	jmp    8008b0 <vprintfmt+0x32f>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  800800:	83 ec 08             	sub    $0x8,%esp
  800803:	57                   	push   %edi
  800804:	6a 2d                	push   $0x2d
  800806:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  800809:	f7 db                	neg    %ebx
  80080b:	83 d6 00             	adc    $0x0,%esi
  80080e:	f7 de                	neg    %esi
  800810:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800813:	b8 0a 00 00 00       	mov    $0xa,%eax
  800818:	e9 93 00 00 00       	jmp    8008b0 <vprintfmt+0x32f>
  80081d:	89 5d d8             	mov    %ebx,-0x28(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800820:	89 ca                	mov    %ecx,%edx
  800822:	8d 45 14             	lea    0x14(%ebp),%eax
  800825:	e8 b4 fc ff ff       	call   8004de <getuint>
  80082a:	89 c3                	mov    %eax,%ebx
  80082c:	89 d6                	mov    %edx,%esi
			base = 10;
  80082e:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  800833:	eb 7b                	jmp    8008b0 <vprintfmt+0x32f>
  800835:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// (unsigned) octal
		case 'o':
            // (MIT 6.828, lab1, Ex.8)  my code : 
            num = getint(&ap, lflag);
  800838:	89 ca                	mov    %ecx,%edx
  80083a:	8d 45 14             	lea    0x14(%ebp),%eax
  80083d:	e8 d6 fc ff ff       	call   800518 <getint>
  800842:	89 c3                	mov    %eax,%ebx
  800844:	89 d6                	mov    %edx,%esi
            if ((long long) num < 0) {
  800846:	85 d2                	test   %edx,%edx
  800848:	78 07                	js     800851 <vprintfmt+0x2d0>
                putch('-', putdat);
                num = -(long long) num;
            }
            base = 8;
  80084a:	b8 08 00 00 00       	mov    $0x8,%eax
  80084f:	eb 5f                	jmp    8008b0 <vprintfmt+0x32f>
		// (unsigned) octal
		case 'o':
            // (MIT 6.828, lab1, Ex.8)  my code : 
            num = getint(&ap, lflag);
            if ((long long) num < 0) {
                putch('-', putdat);
  800851:	83 ec 08             	sub    $0x8,%esp
  800854:	57                   	push   %edi
  800855:	6a 2d                	push   $0x2d
  800857:	ff 55 08             	call   *0x8(%ebp)
                num = -(long long) num;
  80085a:	f7 db                	neg    %ebx
  80085c:	83 d6 00             	adc    $0x0,%esi
  80085f:	f7 de                	neg    %esi
  800861:	83 c4 10             	add    $0x10,%esp
            }
            base = 8;
  800864:	b8 08 00 00 00       	mov    $0x8,%eax
  800869:	eb 45                	jmp    8008b0 <vprintfmt+0x32f>
  80086b:	89 5d d8             	mov    %ebx,-0x28(%ebp)
            goto number;

        // pointer
		case 'p':
			putch('0', putdat);
  80086e:	83 ec 08             	sub    $0x8,%esp
  800871:	57                   	push   %edi
  800872:	6a 30                	push   $0x30
  800874:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  800877:	83 c4 08             	add    $0x8,%esp
  80087a:	57                   	push   %edi
  80087b:	6a 78                	push   $0x78
  80087d:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800880:	8b 45 14             	mov    0x14(%ebp),%eax
  800883:	8d 50 04             	lea    0x4(%eax),%edx
  800886:	89 55 14             	mov    %edx,0x14(%ebp)

        // pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800889:	8b 18                	mov    (%eax),%ebx
  80088b:	be 00 00 00 00       	mov    $0x0,%esi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800890:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800893:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  800898:	eb 16                	jmp    8008b0 <vprintfmt+0x32f>
  80089a:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  80089d:	89 ca                	mov    %ecx,%edx
  80089f:	8d 45 14             	lea    0x14(%ebp),%eax
  8008a2:	e8 37 fc ff ff       	call   8004de <getuint>
  8008a7:	89 c3                	mov    %eax,%ebx
  8008a9:	89 d6                	mov    %edx,%esi
			base = 16;
  8008ab:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  8008b0:	83 ec 0c             	sub    $0xc,%esp
  8008b3:	0f be 55 dc          	movsbl -0x24(%ebp),%edx
  8008b7:	52                   	push   %edx
  8008b8:	ff 75 e4             	pushl  -0x1c(%ebp)
  8008bb:	50                   	push   %eax
  8008bc:	56                   	push   %esi
  8008bd:	53                   	push   %ebx
  8008be:	89 fa                	mov    %edi,%edx
  8008c0:	8b 45 08             	mov    0x8(%ebp),%eax
  8008c3:	e8 68 fb ff ff       	call   800430 <printnum>
			break;
  8008c8:	83 c4 20             	add    $0x20,%esp
  8008cb:	8b 75 d8             	mov    -0x28(%ebp),%esi
  8008ce:	e9 d2 fc ff ff       	jmp    8005a5 <vprintfmt+0x24>
  8008d3:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8008d6:	83 ec 08             	sub    $0x8,%esp
  8008d9:	57                   	push   %edi
  8008da:	52                   	push   %edx
  8008db:	ff 55 08             	call   *0x8(%ebp)
			break;
  8008de:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8008e1:	8b 75 d8             	mov    -0x28(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8008e4:	e9 bc fc ff ff       	jmp    8005a5 <vprintfmt+0x24>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8008e9:	83 ec 08             	sub    $0x8,%esp
  8008ec:	57                   	push   %edi
  8008ed:	6a 25                	push   $0x25
  8008ef:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  8008f2:	83 c4 10             	add    $0x10,%esp
  8008f5:	eb 02                	jmp    8008f9 <vprintfmt+0x378>
  8008f7:	89 c6                	mov    %eax,%esi
  8008f9:	8d 46 ff             	lea    -0x1(%esi),%eax
  8008fc:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  800900:	75 f5                	jne    8008f7 <vprintfmt+0x376>
  800902:	e9 9e fc ff ff       	jmp    8005a5 <vprintfmt+0x24>
				/* do nothing */;
			break;
		}
	}
}
  800907:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80090a:	5b                   	pop    %ebx
  80090b:	5e                   	pop    %esi
  80090c:	5f                   	pop    %edi
  80090d:	c9                   	leave  
  80090e:	c3                   	ret    

0080090f <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80090f:	55                   	push   %ebp
  800910:	89 e5                	mov    %esp,%ebp
  800912:	83 ec 18             	sub    $0x18,%esp
  800915:	8b 45 08             	mov    0x8(%ebp),%eax
  800918:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80091b:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80091e:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800922:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800925:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80092c:	85 c0                	test   %eax,%eax
  80092e:	74 26                	je     800956 <vsnprintf+0x47>
  800930:	85 d2                	test   %edx,%edx
  800932:	7e 29                	jle    80095d <vsnprintf+0x4e>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800934:	ff 75 14             	pushl  0x14(%ebp)
  800937:	ff 75 10             	pushl  0x10(%ebp)
  80093a:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80093d:	50                   	push   %eax
  80093e:	68 4a 05 80 00       	push   $0x80054a
  800943:	e8 39 fc ff ff       	call   800581 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800948:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80094b:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80094e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800951:	83 c4 10             	add    $0x10,%esp
  800954:	eb 0c                	jmp    800962 <vsnprintf+0x53>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800956:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80095b:	eb 05                	jmp    800962 <vsnprintf+0x53>
  80095d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800962:	c9                   	leave  
  800963:	c3                   	ret    

00800964 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800964:	55                   	push   %ebp
  800965:	89 e5                	mov    %esp,%ebp
  800967:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80096a:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80096d:	50                   	push   %eax
  80096e:	ff 75 10             	pushl  0x10(%ebp)
  800971:	ff 75 0c             	pushl  0xc(%ebp)
  800974:	ff 75 08             	pushl  0x8(%ebp)
  800977:	e8 93 ff ff ff       	call   80090f <vsnprintf>
	va_end(ap);

	return rc;
}
  80097c:	c9                   	leave  
  80097d:	c3                   	ret    
	...

00800980 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800980:	55                   	push   %ebp
  800981:	89 e5                	mov    %esp,%ebp
  800983:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800986:	80 3a 00             	cmpb   $0x0,(%edx)
  800989:	74 0e                	je     800999 <strlen+0x19>
  80098b:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  800990:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800991:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800995:	75 f9                	jne    800990 <strlen+0x10>
  800997:	eb 05                	jmp    80099e <strlen+0x1e>
  800999:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  80099e:	c9                   	leave  
  80099f:	c3                   	ret    

008009a0 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8009a0:	55                   	push   %ebp
  8009a1:	89 e5                	mov    %esp,%ebp
  8009a3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009a6:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8009a9:	85 d2                	test   %edx,%edx
  8009ab:	74 17                	je     8009c4 <strnlen+0x24>
  8009ad:	80 39 00             	cmpb   $0x0,(%ecx)
  8009b0:	74 19                	je     8009cb <strnlen+0x2b>
  8009b2:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  8009b7:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8009b8:	39 d0                	cmp    %edx,%eax
  8009ba:	74 14                	je     8009d0 <strnlen+0x30>
  8009bc:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8009c0:	75 f5                	jne    8009b7 <strnlen+0x17>
  8009c2:	eb 0c                	jmp    8009d0 <strnlen+0x30>
  8009c4:	b8 00 00 00 00       	mov    $0x0,%eax
  8009c9:	eb 05                	jmp    8009d0 <strnlen+0x30>
  8009cb:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  8009d0:	c9                   	leave  
  8009d1:	c3                   	ret    

008009d2 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8009d2:	55                   	push   %ebp
  8009d3:	89 e5                	mov    %esp,%ebp
  8009d5:	53                   	push   %ebx
  8009d6:	8b 45 08             	mov    0x8(%ebp),%eax
  8009d9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8009dc:	ba 00 00 00 00       	mov    $0x0,%edx
  8009e1:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  8009e4:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  8009e7:	42                   	inc    %edx
  8009e8:	84 c9                	test   %cl,%cl
  8009ea:	75 f5                	jne    8009e1 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  8009ec:	5b                   	pop    %ebx
  8009ed:	c9                   	leave  
  8009ee:	c3                   	ret    

008009ef <strcat>:

char *
strcat(char *dst, const char *src)
{
  8009ef:	55                   	push   %ebp
  8009f0:	89 e5                	mov    %esp,%ebp
  8009f2:	53                   	push   %ebx
  8009f3:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8009f6:	53                   	push   %ebx
  8009f7:	e8 84 ff ff ff       	call   800980 <strlen>
  8009fc:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8009ff:	ff 75 0c             	pushl  0xc(%ebp)
  800a02:	8d 04 03             	lea    (%ebx,%eax,1),%eax
  800a05:	50                   	push   %eax
  800a06:	e8 c7 ff ff ff       	call   8009d2 <strcpy>
	return dst;
}
  800a0b:	89 d8                	mov    %ebx,%eax
  800a0d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800a10:	c9                   	leave  
  800a11:	c3                   	ret    

00800a12 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800a12:	55                   	push   %ebp
  800a13:	89 e5                	mov    %esp,%ebp
  800a15:	56                   	push   %esi
  800a16:	53                   	push   %ebx
  800a17:	8b 45 08             	mov    0x8(%ebp),%eax
  800a1a:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a1d:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800a20:	85 f6                	test   %esi,%esi
  800a22:	74 15                	je     800a39 <strncpy+0x27>
  800a24:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
  800a29:	8a 1a                	mov    (%edx),%bl
  800a2b:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800a2e:	80 3a 01             	cmpb   $0x1,(%edx)
  800a31:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800a34:	41                   	inc    %ecx
  800a35:	39 ce                	cmp    %ecx,%esi
  800a37:	77 f0                	ja     800a29 <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800a39:	5b                   	pop    %ebx
  800a3a:	5e                   	pop    %esi
  800a3b:	c9                   	leave  
  800a3c:	c3                   	ret    

00800a3d <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800a3d:	55                   	push   %ebp
  800a3e:	89 e5                	mov    %esp,%ebp
  800a40:	57                   	push   %edi
  800a41:	56                   	push   %esi
  800a42:	53                   	push   %ebx
  800a43:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a46:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800a49:	8b 75 10             	mov    0x10(%ebp),%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800a4c:	85 f6                	test   %esi,%esi
  800a4e:	74 32                	je     800a82 <strlcpy+0x45>
		while (--size > 0 && *src != '\0')
  800a50:	83 fe 01             	cmp    $0x1,%esi
  800a53:	74 22                	je     800a77 <strlcpy+0x3a>
  800a55:	8a 0b                	mov    (%ebx),%cl
  800a57:	84 c9                	test   %cl,%cl
  800a59:	74 20                	je     800a7b <strlcpy+0x3e>
  800a5b:	89 f8                	mov    %edi,%eax
  800a5d:	ba 00 00 00 00       	mov    $0x0,%edx
	}
	return ret;
}

size_t
strlcpy(char *dst, const char *src, size_t size)
  800a62:	83 ee 02             	sub    $0x2,%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800a65:	88 08                	mov    %cl,(%eax)
  800a67:	40                   	inc    %eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800a68:	39 f2                	cmp    %esi,%edx
  800a6a:	74 11                	je     800a7d <strlcpy+0x40>
  800a6c:	8a 4c 13 01          	mov    0x1(%ebx,%edx,1),%cl
  800a70:	42                   	inc    %edx
  800a71:	84 c9                	test   %cl,%cl
  800a73:	75 f0                	jne    800a65 <strlcpy+0x28>
  800a75:	eb 06                	jmp    800a7d <strlcpy+0x40>
  800a77:	89 f8                	mov    %edi,%eax
  800a79:	eb 02                	jmp    800a7d <strlcpy+0x40>
  800a7b:	89 f8                	mov    %edi,%eax
			*dst++ = *src++;
		*dst = '\0';
  800a7d:	c6 00 00             	movb   $0x0,(%eax)
  800a80:	eb 02                	jmp    800a84 <strlcpy+0x47>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800a82:	89 f8                	mov    %edi,%eax
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
		*dst = '\0';
	}
	return dst - dst_in;
  800a84:	29 f8                	sub    %edi,%eax
}
  800a86:	5b                   	pop    %ebx
  800a87:	5e                   	pop    %esi
  800a88:	5f                   	pop    %edi
  800a89:	c9                   	leave  
  800a8a:	c3                   	ret    

00800a8b <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800a8b:	55                   	push   %ebp
  800a8c:	89 e5                	mov    %esp,%ebp
  800a8e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a91:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800a94:	8a 01                	mov    (%ecx),%al
  800a96:	84 c0                	test   %al,%al
  800a98:	74 10                	je     800aaa <strcmp+0x1f>
  800a9a:	3a 02                	cmp    (%edx),%al
  800a9c:	75 0c                	jne    800aaa <strcmp+0x1f>
		p++, q++;
  800a9e:	41                   	inc    %ecx
  800a9f:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800aa0:	8a 01                	mov    (%ecx),%al
  800aa2:	84 c0                	test   %al,%al
  800aa4:	74 04                	je     800aaa <strcmp+0x1f>
  800aa6:	3a 02                	cmp    (%edx),%al
  800aa8:	74 f4                	je     800a9e <strcmp+0x13>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800aaa:	0f b6 c0             	movzbl %al,%eax
  800aad:	0f b6 12             	movzbl (%edx),%edx
  800ab0:	29 d0                	sub    %edx,%eax
}
  800ab2:	c9                   	leave  
  800ab3:	c3                   	ret    

00800ab4 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800ab4:	55                   	push   %ebp
  800ab5:	89 e5                	mov    %esp,%ebp
  800ab7:	53                   	push   %ebx
  800ab8:	8b 55 08             	mov    0x8(%ebp),%edx
  800abb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800abe:	8b 45 10             	mov    0x10(%ebp),%eax
	while (n > 0 && *p && *p == *q)
  800ac1:	85 c0                	test   %eax,%eax
  800ac3:	74 1b                	je     800ae0 <strncmp+0x2c>
  800ac5:	8a 1a                	mov    (%edx),%bl
  800ac7:	84 db                	test   %bl,%bl
  800ac9:	74 24                	je     800aef <strncmp+0x3b>
  800acb:	3a 19                	cmp    (%ecx),%bl
  800acd:	75 20                	jne    800aef <strncmp+0x3b>
  800acf:	48                   	dec    %eax
  800ad0:	74 15                	je     800ae7 <strncmp+0x33>
		n--, p++, q++;
  800ad2:	42                   	inc    %edx
  800ad3:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800ad4:	8a 1a                	mov    (%edx),%bl
  800ad6:	84 db                	test   %bl,%bl
  800ad8:	74 15                	je     800aef <strncmp+0x3b>
  800ada:	3a 19                	cmp    (%ecx),%bl
  800adc:	74 f1                	je     800acf <strncmp+0x1b>
  800ade:	eb 0f                	jmp    800aef <strncmp+0x3b>
		n--, p++, q++;
	if (n == 0)
		return 0;
  800ae0:	b8 00 00 00 00       	mov    $0x0,%eax
  800ae5:	eb 05                	jmp    800aec <strncmp+0x38>
  800ae7:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800aec:	5b                   	pop    %ebx
  800aed:	c9                   	leave  
  800aee:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800aef:	0f b6 02             	movzbl (%edx),%eax
  800af2:	0f b6 11             	movzbl (%ecx),%edx
  800af5:	29 d0                	sub    %edx,%eax
  800af7:	eb f3                	jmp    800aec <strncmp+0x38>

00800af9 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800af9:	55                   	push   %ebp
  800afa:	89 e5                	mov    %esp,%ebp
  800afc:	8b 45 08             	mov    0x8(%ebp),%eax
  800aff:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800b02:	8a 10                	mov    (%eax),%dl
  800b04:	84 d2                	test   %dl,%dl
  800b06:	74 18                	je     800b20 <strchr+0x27>
		if (*s == c)
  800b08:	38 ca                	cmp    %cl,%dl
  800b0a:	75 06                	jne    800b12 <strchr+0x19>
  800b0c:	eb 17                	jmp    800b25 <strchr+0x2c>
  800b0e:	38 ca                	cmp    %cl,%dl
  800b10:	74 13                	je     800b25 <strchr+0x2c>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800b12:	40                   	inc    %eax
  800b13:	8a 10                	mov    (%eax),%dl
  800b15:	84 d2                	test   %dl,%dl
  800b17:	75 f5                	jne    800b0e <strchr+0x15>
		if (*s == c)
			return (char *) s;
	return 0;
  800b19:	b8 00 00 00 00       	mov    $0x0,%eax
  800b1e:	eb 05                	jmp    800b25 <strchr+0x2c>
  800b20:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b25:	c9                   	leave  
  800b26:	c3                   	ret    

00800b27 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800b27:	55                   	push   %ebp
  800b28:	89 e5                	mov    %esp,%ebp
  800b2a:	8b 45 08             	mov    0x8(%ebp),%eax
  800b2d:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800b30:	8a 10                	mov    (%eax),%dl
  800b32:	84 d2                	test   %dl,%dl
  800b34:	74 11                	je     800b47 <strfind+0x20>
		if (*s == c)
  800b36:	38 ca                	cmp    %cl,%dl
  800b38:	75 06                	jne    800b40 <strfind+0x19>
  800b3a:	eb 0b                	jmp    800b47 <strfind+0x20>
  800b3c:	38 ca                	cmp    %cl,%dl
  800b3e:	74 07                	je     800b47 <strfind+0x20>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800b40:	40                   	inc    %eax
  800b41:	8a 10                	mov    (%eax),%dl
  800b43:	84 d2                	test   %dl,%dl
  800b45:	75 f5                	jne    800b3c <strfind+0x15>
		if (*s == c)
			break;
	return (char *) s;
}
  800b47:	c9                   	leave  
  800b48:	c3                   	ret    

00800b49 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800b49:	55                   	push   %ebp
  800b4a:	89 e5                	mov    %esp,%ebp
  800b4c:	57                   	push   %edi
  800b4d:	56                   	push   %esi
  800b4e:	53                   	push   %ebx
  800b4f:	8b 7d 08             	mov    0x8(%ebp),%edi
  800b52:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b55:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800b58:	85 c9                	test   %ecx,%ecx
  800b5a:	74 30                	je     800b8c <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800b5c:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800b62:	75 25                	jne    800b89 <memset+0x40>
  800b64:	f6 c1 03             	test   $0x3,%cl
  800b67:	75 20                	jne    800b89 <memset+0x40>
		c &= 0xFF;
  800b69:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800b6c:	89 d3                	mov    %edx,%ebx
  800b6e:	c1 e3 08             	shl    $0x8,%ebx
  800b71:	89 d6                	mov    %edx,%esi
  800b73:	c1 e6 18             	shl    $0x18,%esi
  800b76:	89 d0                	mov    %edx,%eax
  800b78:	c1 e0 10             	shl    $0x10,%eax
  800b7b:	09 f0                	or     %esi,%eax
  800b7d:	09 d0                	or     %edx,%eax
  800b7f:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800b81:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800b84:	fc                   	cld    
  800b85:	f3 ab                	rep stos %eax,%es:(%edi)
  800b87:	eb 03                	jmp    800b8c <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800b89:	fc                   	cld    
  800b8a:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800b8c:	89 f8                	mov    %edi,%eax
  800b8e:	5b                   	pop    %ebx
  800b8f:	5e                   	pop    %esi
  800b90:	5f                   	pop    %edi
  800b91:	c9                   	leave  
  800b92:	c3                   	ret    

00800b93 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800b93:	55                   	push   %ebp
  800b94:	89 e5                	mov    %esp,%ebp
  800b96:	57                   	push   %edi
  800b97:	56                   	push   %esi
  800b98:	8b 45 08             	mov    0x8(%ebp),%eax
  800b9b:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b9e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800ba1:	39 c6                	cmp    %eax,%esi
  800ba3:	73 34                	jae    800bd9 <memmove+0x46>
  800ba5:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800ba8:	39 d0                	cmp    %edx,%eax
  800baa:	73 2d                	jae    800bd9 <memmove+0x46>
		s += n;
		d += n;
  800bac:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800baf:	f6 c2 03             	test   $0x3,%dl
  800bb2:	75 1b                	jne    800bcf <memmove+0x3c>
  800bb4:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800bba:	75 13                	jne    800bcf <memmove+0x3c>
  800bbc:	f6 c1 03             	test   $0x3,%cl
  800bbf:	75 0e                	jne    800bcf <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800bc1:	83 ef 04             	sub    $0x4,%edi
  800bc4:	8d 72 fc             	lea    -0x4(%edx),%esi
  800bc7:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800bca:	fd                   	std    
  800bcb:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800bcd:	eb 07                	jmp    800bd6 <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800bcf:	4f                   	dec    %edi
  800bd0:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800bd3:	fd                   	std    
  800bd4:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800bd6:	fc                   	cld    
  800bd7:	eb 20                	jmp    800bf9 <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800bd9:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800bdf:	75 13                	jne    800bf4 <memmove+0x61>
  800be1:	a8 03                	test   $0x3,%al
  800be3:	75 0f                	jne    800bf4 <memmove+0x61>
  800be5:	f6 c1 03             	test   $0x3,%cl
  800be8:	75 0a                	jne    800bf4 <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800bea:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800bed:	89 c7                	mov    %eax,%edi
  800bef:	fc                   	cld    
  800bf0:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800bf2:	eb 05                	jmp    800bf9 <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800bf4:	89 c7                	mov    %eax,%edi
  800bf6:	fc                   	cld    
  800bf7:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800bf9:	5e                   	pop    %esi
  800bfa:	5f                   	pop    %edi
  800bfb:	c9                   	leave  
  800bfc:	c3                   	ret    

00800bfd <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800bfd:	55                   	push   %ebp
  800bfe:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800c00:	ff 75 10             	pushl  0x10(%ebp)
  800c03:	ff 75 0c             	pushl  0xc(%ebp)
  800c06:	ff 75 08             	pushl  0x8(%ebp)
  800c09:	e8 85 ff ff ff       	call   800b93 <memmove>
}
  800c0e:	c9                   	leave  
  800c0f:	c3                   	ret    

00800c10 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800c10:	55                   	push   %ebp
  800c11:	89 e5                	mov    %esp,%ebp
  800c13:	57                   	push   %edi
  800c14:	56                   	push   %esi
  800c15:	53                   	push   %ebx
  800c16:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800c19:	8b 75 0c             	mov    0xc(%ebp),%esi
  800c1c:	8b 7d 10             	mov    0x10(%ebp),%edi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800c1f:	85 ff                	test   %edi,%edi
  800c21:	74 32                	je     800c55 <memcmp+0x45>
		if (*s1 != *s2)
  800c23:	8a 03                	mov    (%ebx),%al
  800c25:	8a 0e                	mov    (%esi),%cl
  800c27:	38 c8                	cmp    %cl,%al
  800c29:	74 19                	je     800c44 <memcmp+0x34>
  800c2b:	eb 0d                	jmp    800c3a <memcmp+0x2a>
  800c2d:	8a 44 13 01          	mov    0x1(%ebx,%edx,1),%al
  800c31:	8a 4c 16 01          	mov    0x1(%esi,%edx,1),%cl
  800c35:	42                   	inc    %edx
  800c36:	38 c8                	cmp    %cl,%al
  800c38:	74 10                	je     800c4a <memcmp+0x3a>
			return (int) *s1 - (int) *s2;
  800c3a:	0f b6 c0             	movzbl %al,%eax
  800c3d:	0f b6 c9             	movzbl %cl,%ecx
  800c40:	29 c8                	sub    %ecx,%eax
  800c42:	eb 16                	jmp    800c5a <memcmp+0x4a>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800c44:	4f                   	dec    %edi
  800c45:	ba 00 00 00 00       	mov    $0x0,%edx
  800c4a:	39 fa                	cmp    %edi,%edx
  800c4c:	75 df                	jne    800c2d <memcmp+0x1d>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800c4e:	b8 00 00 00 00       	mov    $0x0,%eax
  800c53:	eb 05                	jmp    800c5a <memcmp+0x4a>
  800c55:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800c5a:	5b                   	pop    %ebx
  800c5b:	5e                   	pop    %esi
  800c5c:	5f                   	pop    %edi
  800c5d:	c9                   	leave  
  800c5e:	c3                   	ret    

00800c5f <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800c5f:	55                   	push   %ebp
  800c60:	89 e5                	mov    %esp,%ebp
  800c62:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800c65:	89 c2                	mov    %eax,%edx
  800c67:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800c6a:	39 d0                	cmp    %edx,%eax
  800c6c:	73 12                	jae    800c80 <memfind+0x21>
		if (*(const unsigned char *) s == (unsigned char) c)
  800c6e:	8a 4d 0c             	mov    0xc(%ebp),%cl
  800c71:	38 08                	cmp    %cl,(%eax)
  800c73:	75 06                	jne    800c7b <memfind+0x1c>
  800c75:	eb 09                	jmp    800c80 <memfind+0x21>
  800c77:	38 08                	cmp    %cl,(%eax)
  800c79:	74 05                	je     800c80 <memfind+0x21>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800c7b:	40                   	inc    %eax
  800c7c:	39 c2                	cmp    %eax,%edx
  800c7e:	77 f7                	ja     800c77 <memfind+0x18>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800c80:	c9                   	leave  
  800c81:	c3                   	ret    

00800c82 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800c82:	55                   	push   %ebp
  800c83:	89 e5                	mov    %esp,%ebp
  800c85:	57                   	push   %edi
  800c86:	56                   	push   %esi
  800c87:	53                   	push   %ebx
  800c88:	8b 55 08             	mov    0x8(%ebp),%edx
  800c8b:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800c8e:	eb 01                	jmp    800c91 <strtol+0xf>
		s++;
  800c90:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800c91:	8a 02                	mov    (%edx),%al
  800c93:	3c 20                	cmp    $0x20,%al
  800c95:	74 f9                	je     800c90 <strtol+0xe>
  800c97:	3c 09                	cmp    $0x9,%al
  800c99:	74 f5                	je     800c90 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800c9b:	3c 2b                	cmp    $0x2b,%al
  800c9d:	75 08                	jne    800ca7 <strtol+0x25>
		s++;
  800c9f:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800ca0:	bf 00 00 00 00       	mov    $0x0,%edi
  800ca5:	eb 13                	jmp    800cba <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800ca7:	3c 2d                	cmp    $0x2d,%al
  800ca9:	75 0a                	jne    800cb5 <strtol+0x33>
		s++, neg = 1;
  800cab:	8d 52 01             	lea    0x1(%edx),%edx
  800cae:	bf 01 00 00 00       	mov    $0x1,%edi
  800cb3:	eb 05                	jmp    800cba <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800cb5:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800cba:	85 db                	test   %ebx,%ebx
  800cbc:	74 05                	je     800cc3 <strtol+0x41>
  800cbe:	83 fb 10             	cmp    $0x10,%ebx
  800cc1:	75 28                	jne    800ceb <strtol+0x69>
  800cc3:	8a 02                	mov    (%edx),%al
  800cc5:	3c 30                	cmp    $0x30,%al
  800cc7:	75 10                	jne    800cd9 <strtol+0x57>
  800cc9:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800ccd:	75 0a                	jne    800cd9 <strtol+0x57>
		s += 2, base = 16;
  800ccf:	83 c2 02             	add    $0x2,%edx
  800cd2:	bb 10 00 00 00       	mov    $0x10,%ebx
  800cd7:	eb 12                	jmp    800ceb <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  800cd9:	85 db                	test   %ebx,%ebx
  800cdb:	75 0e                	jne    800ceb <strtol+0x69>
  800cdd:	3c 30                	cmp    $0x30,%al
  800cdf:	75 05                	jne    800ce6 <strtol+0x64>
		s++, base = 8;
  800ce1:	42                   	inc    %edx
  800ce2:	b3 08                	mov    $0x8,%bl
  800ce4:	eb 05                	jmp    800ceb <strtol+0x69>
	else if (base == 0)
		base = 10;
  800ce6:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800ceb:	b8 00 00 00 00       	mov    $0x0,%eax
  800cf0:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800cf2:	8a 0a                	mov    (%edx),%cl
  800cf4:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800cf7:	80 fb 09             	cmp    $0x9,%bl
  800cfa:	77 08                	ja     800d04 <strtol+0x82>
			dig = *s - '0';
  800cfc:	0f be c9             	movsbl %cl,%ecx
  800cff:	83 e9 30             	sub    $0x30,%ecx
  800d02:	eb 1e                	jmp    800d22 <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  800d04:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800d07:	80 fb 19             	cmp    $0x19,%bl
  800d0a:	77 08                	ja     800d14 <strtol+0x92>
			dig = *s - 'a' + 10;
  800d0c:	0f be c9             	movsbl %cl,%ecx
  800d0f:	83 e9 57             	sub    $0x57,%ecx
  800d12:	eb 0e                	jmp    800d22 <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  800d14:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800d17:	80 fb 19             	cmp    $0x19,%bl
  800d1a:	77 13                	ja     800d2f <strtol+0xad>
			dig = *s - 'A' + 10;
  800d1c:	0f be c9             	movsbl %cl,%ecx
  800d1f:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800d22:	39 f1                	cmp    %esi,%ecx
  800d24:	7d 0d                	jge    800d33 <strtol+0xb1>
			break;
		s++, val = (val * base) + dig;
  800d26:	42                   	inc    %edx
  800d27:	0f af c6             	imul   %esi,%eax
  800d2a:	8d 04 01             	lea    (%ecx,%eax,1),%eax
		// we don't properly detect overflow!
	}
  800d2d:	eb c3                	jmp    800cf2 <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800d2f:	89 c1                	mov    %eax,%ecx
  800d31:	eb 02                	jmp    800d35 <strtol+0xb3>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800d33:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800d35:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800d39:	74 05                	je     800d40 <strtol+0xbe>
		*endptr = (char *) s;
  800d3b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800d3e:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800d40:	85 ff                	test   %edi,%edi
  800d42:	74 04                	je     800d48 <strtol+0xc6>
  800d44:	89 c8                	mov    %ecx,%eax
  800d46:	f7 d8                	neg    %eax
}
  800d48:	5b                   	pop    %ebx
  800d49:	5e                   	pop    %esi
  800d4a:	5f                   	pop    %edi
  800d4b:	c9                   	leave  
  800d4c:	c3                   	ret    
  800d4d:	00 00                	add    %al,(%eax)
	...

00800d50 <syscall>:
	return ret;
}

static int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  800d50:	55                   	push   %ebp
  800d51:	89 e5                	mov    %esp,%ebp
  800d53:	57                   	push   %edi
  800d54:	56                   	push   %esi
  800d55:	53                   	push   %ebx
  800d56:	83 ec 1c             	sub    $0x1c,%esp
  800d59:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800d5c:	89 55 e0             	mov    %edx,-0x20(%ebp)
  800d5f:	89 ca                	mov    %ecx,%edx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d61:	8b 75 14             	mov    0x14(%ebp),%esi
  800d64:	8b 7d 10             	mov    0x10(%ebp),%edi
  800d67:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800d6a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d6d:	cd 30                	int    $0x30
  800d6f:	89 c2                	mov    %eax,%edx
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d71:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800d75:	74 1c                	je     800d93 <syscall+0x43>
  800d77:	85 c0                	test   %eax,%eax
  800d79:	7e 18                	jle    800d93 <syscall+0x43>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d7b:	83 ec 0c             	sub    $0xc,%esp
  800d7e:	50                   	push   %eax
  800d7f:	ff 75 e4             	pushl  -0x1c(%ebp)
  800d82:	68 7f 26 80 00       	push   $0x80267f
  800d87:	6a 42                	push   $0x42
  800d89:	68 9c 26 80 00       	push   $0x80269c
  800d8e:	e8 b1 f5 ff ff       	call   800344 <_panic>

	return ret;
}
  800d93:	89 d0                	mov    %edx,%eax
  800d95:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d98:	5b                   	pop    %ebx
  800d99:	5e                   	pop    %esi
  800d9a:	5f                   	pop    %edi
  800d9b:	c9                   	leave  
  800d9c:	c3                   	ret    

00800d9d <sys_cputs>:

void
sys_cputs(const char *s, size_t len)
{	
  800d9d:	55                   	push   %ebp
  800d9e:	89 e5                	mov    %esp,%ebp
  800da0:	83 ec 08             	sub    $0x8,%esp
	// my_sysenter(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
	// return;
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
  800da3:	6a 00                	push   $0x0
  800da5:	6a 00                	push   $0x0
  800da7:	6a 00                	push   $0x0
  800da9:	ff 75 0c             	pushl  0xc(%ebp)
  800dac:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800daf:	ba 00 00 00 00       	mov    $0x0,%edx
  800db4:	b8 00 00 00 00       	mov    $0x0,%eax
  800db9:	e8 92 ff ff ff       	call   800d50 <syscall>
  800dbe:	83 c4 10             	add    $0x10,%esp
	return;
}
  800dc1:	c9                   	leave  
  800dc2:	c3                   	ret    

00800dc3 <sys_cgetc>:

int
sys_cgetc(void)
{
  800dc3:	55                   	push   %ebp
  800dc4:	89 e5                	mov    %esp,%ebp
  800dc6:	83 ec 08             	sub    $0x8,%esp
	// return my_sysenter(SYS_cgetc, 0, 0, 0, 0, 0, 0);
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
  800dc9:	6a 00                	push   $0x0
  800dcb:	6a 00                	push   $0x0
  800dcd:	6a 00                	push   $0x0
  800dcf:	6a 00                	push   $0x0
  800dd1:	b9 00 00 00 00       	mov    $0x0,%ecx
  800dd6:	ba 00 00 00 00       	mov    $0x0,%edx
  800ddb:	b8 01 00 00 00       	mov    $0x1,%eax
  800de0:	e8 6b ff ff ff       	call   800d50 <syscall>
}
  800de5:	c9                   	leave  
  800de6:	c3                   	ret    

00800de7 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800de7:	55                   	push   %ebp
  800de8:	89 e5                	mov    %esp,%ebp
  800dea:	83 ec 08             	sub    $0x8,%esp
	// return my_sysenter(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
  800ded:	6a 00                	push   $0x0
  800def:	6a 00                	push   $0x0
  800df1:	6a 00                	push   $0x0
  800df3:	6a 00                	push   $0x0
  800df5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800df8:	ba 01 00 00 00       	mov    $0x1,%edx
  800dfd:	b8 03 00 00 00       	mov    $0x3,%eax
  800e02:	e8 49 ff ff ff       	call   800d50 <syscall>
}
  800e07:	c9                   	leave  
  800e08:	c3                   	ret    

00800e09 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800e09:	55                   	push   %ebp
  800e0a:	89 e5                	mov    %esp,%ebp
  800e0c:	83 ec 08             	sub    $0x8,%esp
	// return my_sysenter(SYS_getenvid, 0, 0, 0, 0, 0, 0);
	return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
  800e0f:	6a 00                	push   $0x0
  800e11:	6a 00                	push   $0x0
  800e13:	6a 00                	push   $0x0
  800e15:	6a 00                	push   $0x0
  800e17:	b9 00 00 00 00       	mov    $0x0,%ecx
  800e1c:	ba 00 00 00 00       	mov    $0x0,%edx
  800e21:	b8 02 00 00 00       	mov    $0x2,%eax
  800e26:	e8 25 ff ff ff       	call   800d50 <syscall>
}
  800e2b:	c9                   	leave  
  800e2c:	c3                   	ret    

00800e2d <sys_yield>:

void
sys_yield(void)
{
  800e2d:	55                   	push   %ebp
  800e2e:	89 e5                	mov    %esp,%ebp
  800e30:	83 ec 08             	sub    $0x8,%esp
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
  800e33:	6a 00                	push   $0x0
  800e35:	6a 00                	push   $0x0
  800e37:	6a 00                	push   $0x0
  800e39:	6a 00                	push   $0x0
  800e3b:	b9 00 00 00 00       	mov    $0x0,%ecx
  800e40:	ba 00 00 00 00       	mov    $0x0,%edx
  800e45:	b8 0b 00 00 00       	mov    $0xb,%eax
  800e4a:	e8 01 ff ff ff       	call   800d50 <syscall>
  800e4f:	83 c4 10             	add    $0x10,%esp
}
  800e52:	c9                   	leave  
  800e53:	c3                   	ret    

00800e54 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800e54:	55                   	push   %ebp
  800e55:	89 e5                	mov    %esp,%ebp
  800e57:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
  800e5a:	6a 00                	push   $0x0
  800e5c:	6a 00                	push   $0x0
  800e5e:	ff 75 10             	pushl  0x10(%ebp)
  800e61:	ff 75 0c             	pushl  0xc(%ebp)
  800e64:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e67:	ba 01 00 00 00       	mov    $0x1,%edx
  800e6c:	b8 04 00 00 00       	mov    $0x4,%eax
  800e71:	e8 da fe ff ff       	call   800d50 <syscall>
}
  800e76:	c9                   	leave  
  800e77:	c3                   	ret    

00800e78 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800e78:	55                   	push   %ebp
  800e79:	89 e5                	mov    %esp,%ebp
  800e7b:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
  800e7e:	ff 75 18             	pushl  0x18(%ebp)
  800e81:	ff 75 14             	pushl  0x14(%ebp)
  800e84:	ff 75 10             	pushl  0x10(%ebp)
  800e87:	ff 75 0c             	pushl  0xc(%ebp)
  800e8a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e8d:	ba 01 00 00 00       	mov    $0x1,%edx
  800e92:	b8 05 00 00 00       	mov    $0x5,%eax
  800e97:	e8 b4 fe ff ff       	call   800d50 <syscall>
}
  800e9c:	c9                   	leave  
  800e9d:	c3                   	ret    

00800e9e <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800e9e:	55                   	push   %ebp
  800e9f:	89 e5                	mov    %esp,%ebp
  800ea1:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
  800ea4:	6a 00                	push   $0x0
  800ea6:	6a 00                	push   $0x0
  800ea8:	6a 00                	push   $0x0
  800eaa:	ff 75 0c             	pushl  0xc(%ebp)
  800ead:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800eb0:	ba 01 00 00 00       	mov    $0x1,%edx
  800eb5:	b8 06 00 00 00       	mov    $0x6,%eax
  800eba:	e8 91 fe ff ff       	call   800d50 <syscall>
}
  800ebf:	c9                   	leave  
  800ec0:	c3                   	ret    

00800ec1 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800ec1:	55                   	push   %ebp
  800ec2:	89 e5                	mov    %esp,%ebp
  800ec4:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
  800ec7:	6a 00                	push   $0x0
  800ec9:	6a 00                	push   $0x0
  800ecb:	6a 00                	push   $0x0
  800ecd:	ff 75 0c             	pushl  0xc(%ebp)
  800ed0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ed3:	ba 01 00 00 00       	mov    $0x1,%edx
  800ed8:	b8 08 00 00 00       	mov    $0x8,%eax
  800edd:	e8 6e fe ff ff       	call   800d50 <syscall>
}
  800ee2:	c9                   	leave  
  800ee3:	c3                   	ret    

00800ee4 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800ee4:	55                   	push   %ebp
  800ee5:	89 e5                	mov    %esp,%ebp
  800ee7:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
  800eea:	6a 00                	push   $0x0
  800eec:	6a 00                	push   $0x0
  800eee:	6a 00                	push   $0x0
  800ef0:	ff 75 0c             	pushl  0xc(%ebp)
  800ef3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ef6:	ba 01 00 00 00       	mov    $0x1,%edx
  800efb:	b8 09 00 00 00       	mov    $0x9,%eax
  800f00:	e8 4b fe ff ff       	call   800d50 <syscall>
}
  800f05:	c9                   	leave  
  800f06:	c3                   	ret    

00800f07 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800f07:	55                   	push   %ebp
  800f08:	89 e5                	mov    %esp,%ebp
  800f0a:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
  800f0d:	6a 00                	push   $0x0
  800f0f:	6a 00                	push   $0x0
  800f11:	6a 00                	push   $0x0
  800f13:	ff 75 0c             	pushl  0xc(%ebp)
  800f16:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800f19:	ba 01 00 00 00       	mov    $0x1,%edx
  800f1e:	b8 0a 00 00 00       	mov    $0xa,%eax
  800f23:	e8 28 fe ff ff       	call   800d50 <syscall>
}
  800f28:	c9                   	leave  
  800f29:	c3                   	ret    

00800f2a <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800f2a:	55                   	push   %ebp
  800f2b:	89 e5                	mov    %esp,%ebp
  800f2d:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
  800f30:	6a 00                	push   $0x0
  800f32:	ff 75 14             	pushl  0x14(%ebp)
  800f35:	ff 75 10             	pushl  0x10(%ebp)
  800f38:	ff 75 0c             	pushl  0xc(%ebp)
  800f3b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800f3e:	ba 00 00 00 00       	mov    $0x0,%edx
  800f43:	b8 0c 00 00 00       	mov    $0xc,%eax
  800f48:	e8 03 fe ff ff       	call   800d50 <syscall>
}
  800f4d:	c9                   	leave  
  800f4e:	c3                   	ret    

00800f4f <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800f4f:	55                   	push   %ebp
  800f50:	89 e5                	mov    %esp,%ebp
  800f52:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
  800f55:	6a 00                	push   $0x0
  800f57:	6a 00                	push   $0x0
  800f59:	6a 00                	push   $0x0
  800f5b:	6a 00                	push   $0x0
  800f5d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800f60:	ba 01 00 00 00       	mov    $0x1,%edx
  800f65:	b8 0d 00 00 00       	mov    $0xd,%eax
  800f6a:	e8 e1 fd ff ff       	call   800d50 <syscall>
}
  800f6f:	c9                   	leave  
  800f70:	c3                   	ret    

00800f71 <sys_set_priority>:

int
sys_set_priority(envid_t envid, uint32_t new_priority)
{
  800f71:	55                   	push   %ebp
  800f72:	89 e5                	mov    %esp,%ebp
  800f74:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_set_priority, 0, envid, new_priority, 0, 0, 0);
  800f77:	6a 00                	push   $0x0
  800f79:	6a 00                	push   $0x0
  800f7b:	6a 00                	push   $0x0
  800f7d:	ff 75 0c             	pushl  0xc(%ebp)
  800f80:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800f83:	ba 00 00 00 00       	mov    $0x0,%edx
  800f88:	b8 0e 00 00 00       	mov    $0xe,%eax
  800f8d:	e8 be fd ff ff       	call   800d50 <syscall>
}
  800f92:	c9                   	leave  
  800f93:	c3                   	ret    

00800f94 <argstart>:
#include <inc/args.h>
#include <inc/string.h>

void
argstart(int *argc, char **argv, struct Argstate *args)
{
  800f94:	55                   	push   %ebp
  800f95:	89 e5                	mov    %esp,%ebp
  800f97:	8b 55 08             	mov    0x8(%ebp),%edx
  800f9a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f9d:	8b 45 10             	mov    0x10(%ebp),%eax
	args->argc = argc;
  800fa0:	89 10                	mov    %edx,(%eax)
	args->argv = (const char **) argv;
  800fa2:	89 48 04             	mov    %ecx,0x4(%eax)
	args->curarg = (*argc > 1 && argv ? "" : 0);
  800fa5:	83 3a 01             	cmpl   $0x1,(%edx)
  800fa8:	7e 0b                	jle    800fb5 <argstart+0x21>
  800faa:	85 c9                	test   %ecx,%ecx
  800fac:	75 0e                	jne    800fbc <argstart+0x28>
  800fae:	ba 00 00 00 00       	mov    $0x0,%edx
  800fb3:	eb 0c                	jmp    800fc1 <argstart+0x2d>
  800fb5:	ba 00 00 00 00       	mov    $0x0,%edx
  800fba:	eb 05                	jmp    800fc1 <argstart+0x2d>
  800fbc:	ba 7a 27 80 00       	mov    $0x80277a,%edx
  800fc1:	89 50 08             	mov    %edx,0x8(%eax)
	args->argvalue = 0;
  800fc4:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
}
  800fcb:	c9                   	leave  
  800fcc:	c3                   	ret    

00800fcd <argnext>:

int
argnext(struct Argstate *args)
{
  800fcd:	55                   	push   %ebp
  800fce:	89 e5                	mov    %esp,%ebp
  800fd0:	57                   	push   %edi
  800fd1:	56                   	push   %esi
  800fd2:	53                   	push   %ebx
  800fd3:	83 ec 0c             	sub    $0xc,%esp
  800fd6:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int arg;

	args->argvalue = 0;
  800fd9:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)

	// Done processing arguments if args->curarg == 0
	if (args->curarg == 0)
  800fe0:	8b 43 08             	mov    0x8(%ebx),%eax
  800fe3:	85 c0                	test   %eax,%eax
  800fe5:	74 6c                	je     801053 <argnext+0x86>
		return -1;

	if (!*args->curarg) {
  800fe7:	80 38 00             	cmpb   $0x0,(%eax)
  800fea:	75 4d                	jne    801039 <argnext+0x6c>
		// Need to process the next argument
		// Check for end of argument list
		if (*args->argc == 1
  800fec:	8b 0b                	mov    (%ebx),%ecx
  800fee:	83 39 01             	cmpl   $0x1,(%ecx)
  800ff1:	74 52                	je     801045 <argnext+0x78>
		    || args->argv[1][0] != '-'
  800ff3:	8b 43 04             	mov    0x4(%ebx),%eax
  800ff6:	8d 70 04             	lea    0x4(%eax),%esi
  800ff9:	8b 50 04             	mov    0x4(%eax),%edx
  800ffc:	80 3a 2d             	cmpb   $0x2d,(%edx)
  800fff:	75 44                	jne    801045 <argnext+0x78>
		    || args->argv[1][1] == '\0')
  801001:	8d 7a 01             	lea    0x1(%edx),%edi
  801004:	80 7a 01 00          	cmpb   $0x0,0x1(%edx)
  801008:	74 3b                	je     801045 <argnext+0x78>
			goto endofargs;
		// Shift arguments down one
		args->curarg = args->argv[1] + 1;
  80100a:	89 7b 08             	mov    %edi,0x8(%ebx)
		memmove(args->argv + 1, args->argv + 2, sizeof(const char *) * (*args->argc - 1));
  80100d:	83 ec 04             	sub    $0x4,%esp
  801010:	8b 11                	mov    (%ecx),%edx
  801012:	8d 14 95 fc ff ff ff 	lea    -0x4(,%edx,4),%edx
  801019:	52                   	push   %edx
  80101a:	83 c0 08             	add    $0x8,%eax
  80101d:	50                   	push   %eax
  80101e:	56                   	push   %esi
  80101f:	e8 6f fb ff ff       	call   800b93 <memmove>
		(*args->argc)--;
  801024:	8b 03                	mov    (%ebx),%eax
  801026:	ff 08                	decl   (%eax)
		// Check for "--": end of argument list
		if (args->curarg[0] == '-' && args->curarg[1] == '\0')
  801028:	8b 43 08             	mov    0x8(%ebx),%eax
  80102b:	83 c4 10             	add    $0x10,%esp
  80102e:	80 38 2d             	cmpb   $0x2d,(%eax)
  801031:	75 06                	jne    801039 <argnext+0x6c>
  801033:	80 78 01 00          	cmpb   $0x0,0x1(%eax)
  801037:	74 0c                	je     801045 <argnext+0x78>
			goto endofargs;
	}

	arg = (unsigned char) *args->curarg;
  801039:	8b 53 08             	mov    0x8(%ebx),%edx
  80103c:	0f b6 02             	movzbl (%edx),%eax
	args->curarg++;
  80103f:	42                   	inc    %edx
  801040:	89 53 08             	mov    %edx,0x8(%ebx)
	return arg;
  801043:	eb 13                	jmp    801058 <argnext+0x8b>

    endofargs:
	args->curarg = 0;
  801045:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
	return -1;
  80104c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  801051:	eb 05                	jmp    801058 <argnext+0x8b>

	args->argvalue = 0;

	// Done processing arguments if args->curarg == 0
	if (args->curarg == 0)
		return -1;
  801053:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	return arg;

    endofargs:
	args->curarg = 0;
	return -1;
}
  801058:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80105b:	5b                   	pop    %ebx
  80105c:	5e                   	pop    %esi
  80105d:	5f                   	pop    %edi
  80105e:	c9                   	leave  
  80105f:	c3                   	ret    

00801060 <argnextvalue>:
	return (char*) (args->argvalue ? args->argvalue : argnextvalue(args));
}

char *
argnextvalue(struct Argstate *args)
{
  801060:	55                   	push   %ebp
  801061:	89 e5                	mov    %esp,%ebp
  801063:	56                   	push   %esi
  801064:	53                   	push   %ebx
  801065:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (!args->curarg)
  801068:	8b 43 08             	mov    0x8(%ebx),%eax
  80106b:	85 c0                	test   %eax,%eax
  80106d:	74 57                	je     8010c6 <argnextvalue+0x66>
		return 0;
	if (*args->curarg) {
  80106f:	80 38 00             	cmpb   $0x0,(%eax)
  801072:	74 0c                	je     801080 <argnextvalue+0x20>
		args->argvalue = args->curarg;
  801074:	89 43 0c             	mov    %eax,0xc(%ebx)
		args->curarg = "";
  801077:	c7 43 08 7a 27 80 00 	movl   $0x80277a,0x8(%ebx)
  80107e:	eb 41                	jmp    8010c1 <argnextvalue+0x61>
	} else if (*args->argc > 1) {
  801080:	8b 03                	mov    (%ebx),%eax
  801082:	83 38 01             	cmpl   $0x1,(%eax)
  801085:	7e 2c                	jle    8010b3 <argnextvalue+0x53>
		args->argvalue = args->argv[1];
  801087:	8b 53 04             	mov    0x4(%ebx),%edx
  80108a:	8d 4a 04             	lea    0x4(%edx),%ecx
  80108d:	8b 72 04             	mov    0x4(%edx),%esi
  801090:	89 73 0c             	mov    %esi,0xc(%ebx)
		memmove(args->argv + 1, args->argv + 2, sizeof(const char *) * (*args->argc - 1));
  801093:	83 ec 04             	sub    $0x4,%esp
  801096:	8b 00                	mov    (%eax),%eax
  801098:	8d 04 85 fc ff ff ff 	lea    -0x4(,%eax,4),%eax
  80109f:	50                   	push   %eax
  8010a0:	83 c2 08             	add    $0x8,%edx
  8010a3:	52                   	push   %edx
  8010a4:	51                   	push   %ecx
  8010a5:	e8 e9 fa ff ff       	call   800b93 <memmove>
		(*args->argc)--;
  8010aa:	8b 03                	mov    (%ebx),%eax
  8010ac:	ff 08                	decl   (%eax)
  8010ae:	83 c4 10             	add    $0x10,%esp
  8010b1:	eb 0e                	jmp    8010c1 <argnextvalue+0x61>
	} else {
		args->argvalue = 0;
  8010b3:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)
		args->curarg = 0;
  8010ba:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
	}
	return (char*) args->argvalue;
  8010c1:	8b 43 0c             	mov    0xc(%ebx),%eax
  8010c4:	eb 05                	jmp    8010cb <argnextvalue+0x6b>

char *
argnextvalue(struct Argstate *args)
{
	if (!args->curarg)
		return 0;
  8010c6:	b8 00 00 00 00       	mov    $0x0,%eax
	} else {
		args->argvalue = 0;
		args->curarg = 0;
	}
	return (char*) args->argvalue;
}
  8010cb:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8010ce:	5b                   	pop    %ebx
  8010cf:	5e                   	pop    %esi
  8010d0:	c9                   	leave  
  8010d1:	c3                   	ret    

008010d2 <argvalue>:
	return -1;
}

char *
argvalue(struct Argstate *args)
{
  8010d2:	55                   	push   %ebp
  8010d3:	89 e5                	mov    %esp,%ebp
  8010d5:	83 ec 08             	sub    $0x8,%esp
  8010d8:	8b 55 08             	mov    0x8(%ebp),%edx
	return (char*) (args->argvalue ? args->argvalue : argnextvalue(args));
  8010db:	8b 42 0c             	mov    0xc(%edx),%eax
  8010de:	85 c0                	test   %eax,%eax
  8010e0:	75 0c                	jne    8010ee <argvalue+0x1c>
  8010e2:	83 ec 0c             	sub    $0xc,%esp
  8010e5:	52                   	push   %edx
  8010e6:	e8 75 ff ff ff       	call   801060 <argnextvalue>
  8010eb:	83 c4 10             	add    $0x10,%esp
}
  8010ee:	c9                   	leave  
  8010ef:	c3                   	ret    

008010f0 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8010f0:	55                   	push   %ebp
  8010f1:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8010f3:	8b 45 08             	mov    0x8(%ebp),%eax
  8010f6:	05 00 00 00 30       	add    $0x30000000,%eax
  8010fb:	c1 e8 0c             	shr    $0xc,%eax
}
  8010fe:	c9                   	leave  
  8010ff:	c3                   	ret    

00801100 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801100:	55                   	push   %ebp
  801101:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  801103:	ff 75 08             	pushl  0x8(%ebp)
  801106:	e8 e5 ff ff ff       	call   8010f0 <fd2num>
  80110b:	83 c4 04             	add    $0x4,%esp
  80110e:	05 20 00 0d 00       	add    $0xd0020,%eax
  801113:	c1 e0 0c             	shl    $0xc,%eax
}
  801116:	c9                   	leave  
  801117:	c3                   	ret    

00801118 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801118:	55                   	push   %ebp
  801119:	89 e5                	mov    %esp,%ebp
  80111b:	53                   	push   %ebx
  80111c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  80111f:	a1 00 dd 7b ef       	mov    0xef7bdd00,%eax
  801124:	a8 01                	test   $0x1,%al
  801126:	74 34                	je     80115c <fd_alloc+0x44>
  801128:	a1 00 00 74 ef       	mov    0xef740000,%eax
  80112d:	a8 01                	test   $0x1,%al
  80112f:	74 32                	je     801163 <fd_alloc+0x4b>
  801131:	b8 00 10 00 d0       	mov    $0xd0001000,%eax
  801136:	89 c1                	mov    %eax,%ecx
  801138:	89 c2                	mov    %eax,%edx
  80113a:	c1 ea 16             	shr    $0x16,%edx
  80113d:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801144:	f6 c2 01             	test   $0x1,%dl
  801147:	74 1f                	je     801168 <fd_alloc+0x50>
  801149:	89 c2                	mov    %eax,%edx
  80114b:	c1 ea 0c             	shr    $0xc,%edx
  80114e:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801155:	f6 c2 01             	test   $0x1,%dl
  801158:	75 17                	jne    801171 <fd_alloc+0x59>
  80115a:	eb 0c                	jmp    801168 <fd_alloc+0x50>
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  80115c:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
  801161:	eb 05                	jmp    801168 <fd_alloc+0x50>
  801163:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
  801168:	89 0b                	mov    %ecx,(%ebx)
			return 0;
  80116a:	b8 00 00 00 00       	mov    $0x0,%eax
  80116f:	eb 17                	jmp    801188 <fd_alloc+0x70>
  801171:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  801176:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  80117b:	75 b9                	jne    801136 <fd_alloc+0x1e>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  80117d:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_MAX_OPEN;
  801183:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  801188:	5b                   	pop    %ebx
  801189:	c9                   	leave  
  80118a:	c3                   	ret    

0080118b <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  80118b:	55                   	push   %ebp
  80118c:	89 e5                	mov    %esp,%ebp
  80118e:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801191:	83 f8 1f             	cmp    $0x1f,%eax
  801194:	77 36                	ja     8011cc <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801196:	05 00 00 0d 00       	add    $0xd0000,%eax
  80119b:	c1 e0 0c             	shl    $0xc,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  80119e:	89 c2                	mov    %eax,%edx
  8011a0:	c1 ea 16             	shr    $0x16,%edx
  8011a3:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8011aa:	f6 c2 01             	test   $0x1,%dl
  8011ad:	74 24                	je     8011d3 <fd_lookup+0x48>
  8011af:	89 c2                	mov    %eax,%edx
  8011b1:	c1 ea 0c             	shr    $0xc,%edx
  8011b4:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8011bb:	f6 c2 01             	test   $0x1,%dl
  8011be:	74 1a                	je     8011da <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8011c0:	8b 55 0c             	mov    0xc(%ebp),%edx
  8011c3:	89 02                	mov    %eax,(%edx)
	return 0;
  8011c5:	b8 00 00 00 00       	mov    $0x0,%eax
  8011ca:	eb 13                	jmp    8011df <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8011cc:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8011d1:	eb 0c                	jmp    8011df <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8011d3:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8011d8:	eb 05                	jmp    8011df <fd_lookup+0x54>
  8011da:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  8011df:	c9                   	leave  
  8011e0:	c3                   	ret    

008011e1 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8011e1:	55                   	push   %ebp
  8011e2:	89 e5                	mov    %esp,%ebp
  8011e4:	53                   	push   %ebx
  8011e5:	83 ec 04             	sub    $0x4,%esp
  8011e8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8011eb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
		if (devtab[i]->dev_id == dev_id) {
  8011ee:	39 0d 04 30 80 00    	cmp    %ecx,0x803004
  8011f4:	74 0d                	je     801203 <dev_lookup+0x22>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8011f6:	b8 00 00 00 00       	mov    $0x0,%eax
  8011fb:	eb 14                	jmp    801211 <dev_lookup+0x30>
		if (devtab[i]->dev_id == dev_id) {
  8011fd:	39 0a                	cmp    %ecx,(%edx)
  8011ff:	75 10                	jne    801211 <dev_lookup+0x30>
  801201:	eb 05                	jmp    801208 <dev_lookup+0x27>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801203:	ba 04 30 80 00       	mov    $0x803004,%edx
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
  801208:	89 13                	mov    %edx,(%ebx)
			return 0;
  80120a:	b8 00 00 00 00       	mov    $0x0,%eax
  80120f:	eb 31                	jmp    801242 <dev_lookup+0x61>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801211:	40                   	inc    %eax
  801212:	8b 14 85 2c 27 80 00 	mov    0x80272c(,%eax,4),%edx
  801219:	85 d2                	test   %edx,%edx
  80121b:	75 e0                	jne    8011fd <dev_lookup+0x1c>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  80121d:	a1 20 44 80 00       	mov    0x804420,%eax
  801222:	8b 40 48             	mov    0x48(%eax),%eax
  801225:	83 ec 04             	sub    $0x4,%esp
  801228:	51                   	push   %ecx
  801229:	50                   	push   %eax
  80122a:	68 ac 26 80 00       	push   $0x8026ac
  80122f:	e8 e8 f1 ff ff       	call   80041c <cprintf>
	*dev = 0;
  801234:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_INVAL;
  80123a:	83 c4 10             	add    $0x10,%esp
  80123d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801242:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801245:	c9                   	leave  
  801246:	c3                   	ret    

00801247 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  801247:	55                   	push   %ebp
  801248:	89 e5                	mov    %esp,%ebp
  80124a:	56                   	push   %esi
  80124b:	53                   	push   %ebx
  80124c:	83 ec 20             	sub    $0x20,%esp
  80124f:	8b 75 08             	mov    0x8(%ebp),%esi
  801252:	8a 45 0c             	mov    0xc(%ebp),%al
  801255:	88 45 e7             	mov    %al,-0x19(%ebp)
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801258:	56                   	push   %esi
  801259:	e8 92 fe ff ff       	call   8010f0 <fd2num>
  80125e:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801261:	89 14 24             	mov    %edx,(%esp)
  801264:	50                   	push   %eax
  801265:	e8 21 ff ff ff       	call   80118b <fd_lookup>
  80126a:	89 c3                	mov    %eax,%ebx
  80126c:	83 c4 08             	add    $0x8,%esp
  80126f:	85 c0                	test   %eax,%eax
  801271:	78 05                	js     801278 <fd_close+0x31>
	    || fd != fd2)
  801273:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801276:	74 0d                	je     801285 <fd_close+0x3e>
		return (must_exist ? r : 0);
  801278:	80 7d e7 00          	cmpb   $0x0,-0x19(%ebp)
  80127c:	75 48                	jne    8012c6 <fd_close+0x7f>
  80127e:	bb 00 00 00 00       	mov    $0x0,%ebx
  801283:	eb 41                	jmp    8012c6 <fd_close+0x7f>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801285:	83 ec 08             	sub    $0x8,%esp
  801288:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80128b:	50                   	push   %eax
  80128c:	ff 36                	pushl  (%esi)
  80128e:	e8 4e ff ff ff       	call   8011e1 <dev_lookup>
  801293:	89 c3                	mov    %eax,%ebx
  801295:	83 c4 10             	add    $0x10,%esp
  801298:	85 c0                	test   %eax,%eax
  80129a:	78 1c                	js     8012b8 <fd_close+0x71>
		if (dev->dev_close)
  80129c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80129f:	8b 40 10             	mov    0x10(%eax),%eax
  8012a2:	85 c0                	test   %eax,%eax
  8012a4:	74 0d                	je     8012b3 <fd_close+0x6c>
			r = (*dev->dev_close)(fd);
  8012a6:	83 ec 0c             	sub    $0xc,%esp
  8012a9:	56                   	push   %esi
  8012aa:	ff d0                	call   *%eax
  8012ac:	89 c3                	mov    %eax,%ebx
  8012ae:	83 c4 10             	add    $0x10,%esp
  8012b1:	eb 05                	jmp    8012b8 <fd_close+0x71>
		else
			r = 0;
  8012b3:	bb 00 00 00 00       	mov    $0x0,%ebx
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8012b8:	83 ec 08             	sub    $0x8,%esp
  8012bb:	56                   	push   %esi
  8012bc:	6a 00                	push   $0x0
  8012be:	e8 db fb ff ff       	call   800e9e <sys_page_unmap>
	return r;
  8012c3:	83 c4 10             	add    $0x10,%esp
}
  8012c6:	89 d8                	mov    %ebx,%eax
  8012c8:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8012cb:	5b                   	pop    %ebx
  8012cc:	5e                   	pop    %esi
  8012cd:	c9                   	leave  
  8012ce:	c3                   	ret    

008012cf <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8012cf:	55                   	push   %ebp
  8012d0:	89 e5                	mov    %esp,%ebp
  8012d2:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8012d5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012d8:	50                   	push   %eax
  8012d9:	ff 75 08             	pushl  0x8(%ebp)
  8012dc:	e8 aa fe ff ff       	call   80118b <fd_lookup>
  8012e1:	83 c4 08             	add    $0x8,%esp
  8012e4:	85 c0                	test   %eax,%eax
  8012e6:	78 10                	js     8012f8 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  8012e8:	83 ec 08             	sub    $0x8,%esp
  8012eb:	6a 01                	push   $0x1
  8012ed:	ff 75 f4             	pushl  -0xc(%ebp)
  8012f0:	e8 52 ff ff ff       	call   801247 <fd_close>
  8012f5:	83 c4 10             	add    $0x10,%esp
}
  8012f8:	c9                   	leave  
  8012f9:	c3                   	ret    

008012fa <close_all>:

void
close_all(void)
{
  8012fa:	55                   	push   %ebp
  8012fb:	89 e5                	mov    %esp,%ebp
  8012fd:	53                   	push   %ebx
  8012fe:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801301:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801306:	83 ec 0c             	sub    $0xc,%esp
  801309:	53                   	push   %ebx
  80130a:	e8 c0 ff ff ff       	call   8012cf <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  80130f:	43                   	inc    %ebx
  801310:	83 c4 10             	add    $0x10,%esp
  801313:	83 fb 20             	cmp    $0x20,%ebx
  801316:	75 ee                	jne    801306 <close_all+0xc>
		close(i);
}
  801318:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80131b:	c9                   	leave  
  80131c:	c3                   	ret    

0080131d <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  80131d:	55                   	push   %ebp
  80131e:	89 e5                	mov    %esp,%ebp
  801320:	57                   	push   %edi
  801321:	56                   	push   %esi
  801322:	53                   	push   %ebx
  801323:	83 ec 2c             	sub    $0x2c,%esp
  801326:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801329:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80132c:	50                   	push   %eax
  80132d:	ff 75 08             	pushl  0x8(%ebp)
  801330:	e8 56 fe ff ff       	call   80118b <fd_lookup>
  801335:	89 c3                	mov    %eax,%ebx
  801337:	83 c4 08             	add    $0x8,%esp
  80133a:	85 c0                	test   %eax,%eax
  80133c:	0f 88 c0 00 00 00    	js     801402 <dup+0xe5>
		return r;
	close(newfdnum);
  801342:	83 ec 0c             	sub    $0xc,%esp
  801345:	57                   	push   %edi
  801346:	e8 84 ff ff ff       	call   8012cf <close>

	newfd = INDEX2FD(newfdnum);
  80134b:	8d b7 00 00 0d 00    	lea    0xd0000(%edi),%esi
  801351:	c1 e6 0c             	shl    $0xc,%esi
	ova = fd2data(oldfd);
  801354:	83 c4 04             	add    $0x4,%esp
  801357:	ff 75 e4             	pushl  -0x1c(%ebp)
  80135a:	e8 a1 fd ff ff       	call   801100 <fd2data>
  80135f:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  801361:	89 34 24             	mov    %esi,(%esp)
  801364:	e8 97 fd ff ff       	call   801100 <fd2data>
  801369:	83 c4 10             	add    $0x10,%esp
  80136c:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80136f:	89 d8                	mov    %ebx,%eax
  801371:	c1 e8 16             	shr    $0x16,%eax
  801374:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80137b:	a8 01                	test   $0x1,%al
  80137d:	74 37                	je     8013b6 <dup+0x99>
  80137f:	89 d8                	mov    %ebx,%eax
  801381:	c1 e8 0c             	shr    $0xc,%eax
  801384:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80138b:	f6 c2 01             	test   $0x1,%dl
  80138e:	74 26                	je     8013b6 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801390:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801397:	83 ec 0c             	sub    $0xc,%esp
  80139a:	25 07 0e 00 00       	and    $0xe07,%eax
  80139f:	50                   	push   %eax
  8013a0:	ff 75 d4             	pushl  -0x2c(%ebp)
  8013a3:	6a 00                	push   $0x0
  8013a5:	53                   	push   %ebx
  8013a6:	6a 00                	push   $0x0
  8013a8:	e8 cb fa ff ff       	call   800e78 <sys_page_map>
  8013ad:	89 c3                	mov    %eax,%ebx
  8013af:	83 c4 20             	add    $0x20,%esp
  8013b2:	85 c0                	test   %eax,%eax
  8013b4:	78 2d                	js     8013e3 <dup+0xc6>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8013b6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8013b9:	89 c2                	mov    %eax,%edx
  8013bb:	c1 ea 0c             	shr    $0xc,%edx
  8013be:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8013c5:	83 ec 0c             	sub    $0xc,%esp
  8013c8:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  8013ce:	52                   	push   %edx
  8013cf:	56                   	push   %esi
  8013d0:	6a 00                	push   $0x0
  8013d2:	50                   	push   %eax
  8013d3:	6a 00                	push   $0x0
  8013d5:	e8 9e fa ff ff       	call   800e78 <sys_page_map>
  8013da:	89 c3                	mov    %eax,%ebx
  8013dc:	83 c4 20             	add    $0x20,%esp
  8013df:	85 c0                	test   %eax,%eax
  8013e1:	79 1d                	jns    801400 <dup+0xe3>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8013e3:	83 ec 08             	sub    $0x8,%esp
  8013e6:	56                   	push   %esi
  8013e7:	6a 00                	push   $0x0
  8013e9:	e8 b0 fa ff ff       	call   800e9e <sys_page_unmap>
	sys_page_unmap(0, nva);
  8013ee:	83 c4 08             	add    $0x8,%esp
  8013f1:	ff 75 d4             	pushl  -0x2c(%ebp)
  8013f4:	6a 00                	push   $0x0
  8013f6:	e8 a3 fa ff ff       	call   800e9e <sys_page_unmap>
	return r;
  8013fb:	83 c4 10             	add    $0x10,%esp
  8013fe:	eb 02                	jmp    801402 <dup+0xe5>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
		goto err;

	return newfdnum;
  801400:	89 fb                	mov    %edi,%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  801402:	89 d8                	mov    %ebx,%eax
  801404:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801407:	5b                   	pop    %ebx
  801408:	5e                   	pop    %esi
  801409:	5f                   	pop    %edi
  80140a:	c9                   	leave  
  80140b:	c3                   	ret    

0080140c <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80140c:	55                   	push   %ebp
  80140d:	89 e5                	mov    %esp,%ebp
  80140f:	53                   	push   %ebx
  801410:	83 ec 14             	sub    $0x14,%esp
  801413:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801416:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801419:	50                   	push   %eax
  80141a:	53                   	push   %ebx
  80141b:	e8 6b fd ff ff       	call   80118b <fd_lookup>
  801420:	83 c4 08             	add    $0x8,%esp
  801423:	85 c0                	test   %eax,%eax
  801425:	78 67                	js     80148e <read+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801427:	83 ec 08             	sub    $0x8,%esp
  80142a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80142d:	50                   	push   %eax
  80142e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801431:	ff 30                	pushl  (%eax)
  801433:	e8 a9 fd ff ff       	call   8011e1 <dev_lookup>
  801438:	83 c4 10             	add    $0x10,%esp
  80143b:	85 c0                	test   %eax,%eax
  80143d:	78 4f                	js     80148e <read+0x82>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80143f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801442:	8b 50 08             	mov    0x8(%eax),%edx
  801445:	83 e2 03             	and    $0x3,%edx
  801448:	83 fa 01             	cmp    $0x1,%edx
  80144b:	75 21                	jne    80146e <read+0x62>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80144d:	a1 20 44 80 00       	mov    0x804420,%eax
  801452:	8b 40 48             	mov    0x48(%eax),%eax
  801455:	83 ec 04             	sub    $0x4,%esp
  801458:	53                   	push   %ebx
  801459:	50                   	push   %eax
  80145a:	68 f0 26 80 00       	push   $0x8026f0
  80145f:	e8 b8 ef ff ff       	call   80041c <cprintf>
		return -E_INVAL;
  801464:	83 c4 10             	add    $0x10,%esp
  801467:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80146c:	eb 20                	jmp    80148e <read+0x82>
	}
	if (!dev->dev_read)
  80146e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801471:	8b 52 08             	mov    0x8(%edx),%edx
  801474:	85 d2                	test   %edx,%edx
  801476:	74 11                	je     801489 <read+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801478:	83 ec 04             	sub    $0x4,%esp
  80147b:	ff 75 10             	pushl  0x10(%ebp)
  80147e:	ff 75 0c             	pushl  0xc(%ebp)
  801481:	50                   	push   %eax
  801482:	ff d2                	call   *%edx
  801484:	83 c4 10             	add    $0x10,%esp
  801487:	eb 05                	jmp    80148e <read+0x82>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801489:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_read)(fd, buf, n);
}
  80148e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801491:	c9                   	leave  
  801492:	c3                   	ret    

00801493 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801493:	55                   	push   %ebp
  801494:	89 e5                	mov    %esp,%ebp
  801496:	57                   	push   %edi
  801497:	56                   	push   %esi
  801498:	53                   	push   %ebx
  801499:	83 ec 0c             	sub    $0xc,%esp
  80149c:	8b 7d 08             	mov    0x8(%ebp),%edi
  80149f:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8014a2:	85 f6                	test   %esi,%esi
  8014a4:	74 31                	je     8014d7 <readn+0x44>
  8014a6:	b8 00 00 00 00       	mov    $0x0,%eax
  8014ab:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = read(fdnum, (char*)buf + tot, n - tot);
  8014b0:	83 ec 04             	sub    $0x4,%esp
  8014b3:	89 f2                	mov    %esi,%edx
  8014b5:	29 c2                	sub    %eax,%edx
  8014b7:	52                   	push   %edx
  8014b8:	03 45 0c             	add    0xc(%ebp),%eax
  8014bb:	50                   	push   %eax
  8014bc:	57                   	push   %edi
  8014bd:	e8 4a ff ff ff       	call   80140c <read>
		if (m < 0)
  8014c2:	83 c4 10             	add    $0x10,%esp
  8014c5:	85 c0                	test   %eax,%eax
  8014c7:	78 17                	js     8014e0 <readn+0x4d>
			return m;
		if (m == 0)
  8014c9:	85 c0                	test   %eax,%eax
  8014cb:	74 11                	je     8014de <readn+0x4b>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8014cd:	01 c3                	add    %eax,%ebx
  8014cf:	89 d8                	mov    %ebx,%eax
  8014d1:	39 f3                	cmp    %esi,%ebx
  8014d3:	72 db                	jb     8014b0 <readn+0x1d>
  8014d5:	eb 09                	jmp    8014e0 <readn+0x4d>
  8014d7:	b8 00 00 00 00       	mov    $0x0,%eax
  8014dc:	eb 02                	jmp    8014e0 <readn+0x4d>
		m = read(fdnum, (char*)buf + tot, n - tot);
		if (m < 0)
			return m;
		if (m == 0)
  8014de:	89 d8                	mov    %ebx,%eax
			break;
	}
	return tot;
}
  8014e0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8014e3:	5b                   	pop    %ebx
  8014e4:	5e                   	pop    %esi
  8014e5:	5f                   	pop    %edi
  8014e6:	c9                   	leave  
  8014e7:	c3                   	ret    

008014e8 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8014e8:	55                   	push   %ebp
  8014e9:	89 e5                	mov    %esp,%ebp
  8014eb:	53                   	push   %ebx
  8014ec:	83 ec 14             	sub    $0x14,%esp
  8014ef:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8014f2:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8014f5:	50                   	push   %eax
  8014f6:	53                   	push   %ebx
  8014f7:	e8 8f fc ff ff       	call   80118b <fd_lookup>
  8014fc:	83 c4 08             	add    $0x8,%esp
  8014ff:	85 c0                	test   %eax,%eax
  801501:	78 62                	js     801565 <write+0x7d>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801503:	83 ec 08             	sub    $0x8,%esp
  801506:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801509:	50                   	push   %eax
  80150a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80150d:	ff 30                	pushl  (%eax)
  80150f:	e8 cd fc ff ff       	call   8011e1 <dev_lookup>
  801514:	83 c4 10             	add    $0x10,%esp
  801517:	85 c0                	test   %eax,%eax
  801519:	78 4a                	js     801565 <write+0x7d>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80151b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80151e:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801522:	75 21                	jne    801545 <write+0x5d>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801524:	a1 20 44 80 00       	mov    0x804420,%eax
  801529:	8b 40 48             	mov    0x48(%eax),%eax
  80152c:	83 ec 04             	sub    $0x4,%esp
  80152f:	53                   	push   %ebx
  801530:	50                   	push   %eax
  801531:	68 0c 27 80 00       	push   $0x80270c
  801536:	e8 e1 ee ff ff       	call   80041c <cprintf>
		return -E_INVAL;
  80153b:	83 c4 10             	add    $0x10,%esp
  80153e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801543:	eb 20                	jmp    801565 <write+0x7d>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801545:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801548:	8b 52 0c             	mov    0xc(%edx),%edx
  80154b:	85 d2                	test   %edx,%edx
  80154d:	74 11                	je     801560 <write+0x78>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80154f:	83 ec 04             	sub    $0x4,%esp
  801552:	ff 75 10             	pushl  0x10(%ebp)
  801555:	ff 75 0c             	pushl  0xc(%ebp)
  801558:	50                   	push   %eax
  801559:	ff d2                	call   *%edx
  80155b:	83 c4 10             	add    $0x10,%esp
  80155e:	eb 05                	jmp    801565 <write+0x7d>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801560:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  801565:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801568:	c9                   	leave  
  801569:	c3                   	ret    

0080156a <seek>:

int
seek(int fdnum, off_t offset)
{
  80156a:	55                   	push   %ebp
  80156b:	89 e5                	mov    %esp,%ebp
  80156d:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801570:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801573:	50                   	push   %eax
  801574:	ff 75 08             	pushl  0x8(%ebp)
  801577:	e8 0f fc ff ff       	call   80118b <fd_lookup>
  80157c:	83 c4 08             	add    $0x8,%esp
  80157f:	85 c0                	test   %eax,%eax
  801581:	78 0e                	js     801591 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801583:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801586:	8b 55 0c             	mov    0xc(%ebp),%edx
  801589:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  80158c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801591:	c9                   	leave  
  801592:	c3                   	ret    

00801593 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801593:	55                   	push   %ebp
  801594:	89 e5                	mov    %esp,%ebp
  801596:	53                   	push   %ebx
  801597:	83 ec 14             	sub    $0x14,%esp
  80159a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80159d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8015a0:	50                   	push   %eax
  8015a1:	53                   	push   %ebx
  8015a2:	e8 e4 fb ff ff       	call   80118b <fd_lookup>
  8015a7:	83 c4 08             	add    $0x8,%esp
  8015aa:	85 c0                	test   %eax,%eax
  8015ac:	78 5f                	js     80160d <ftruncate+0x7a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015ae:	83 ec 08             	sub    $0x8,%esp
  8015b1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015b4:	50                   	push   %eax
  8015b5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015b8:	ff 30                	pushl  (%eax)
  8015ba:	e8 22 fc ff ff       	call   8011e1 <dev_lookup>
  8015bf:	83 c4 10             	add    $0x10,%esp
  8015c2:	85 c0                	test   %eax,%eax
  8015c4:	78 47                	js     80160d <ftruncate+0x7a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8015c6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015c9:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8015cd:	75 21                	jne    8015f0 <ftruncate+0x5d>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8015cf:	a1 20 44 80 00       	mov    0x804420,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8015d4:	8b 40 48             	mov    0x48(%eax),%eax
  8015d7:	83 ec 04             	sub    $0x4,%esp
  8015da:	53                   	push   %ebx
  8015db:	50                   	push   %eax
  8015dc:	68 cc 26 80 00       	push   $0x8026cc
  8015e1:	e8 36 ee ff ff       	call   80041c <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8015e6:	83 c4 10             	add    $0x10,%esp
  8015e9:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8015ee:	eb 1d                	jmp    80160d <ftruncate+0x7a>
	}
	if (!dev->dev_trunc)
  8015f0:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8015f3:	8b 52 18             	mov    0x18(%edx),%edx
  8015f6:	85 d2                	test   %edx,%edx
  8015f8:	74 0e                	je     801608 <ftruncate+0x75>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8015fa:	83 ec 08             	sub    $0x8,%esp
  8015fd:	ff 75 0c             	pushl  0xc(%ebp)
  801600:	50                   	push   %eax
  801601:	ff d2                	call   *%edx
  801603:	83 c4 10             	add    $0x10,%esp
  801606:	eb 05                	jmp    80160d <ftruncate+0x7a>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801608:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  80160d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801610:	c9                   	leave  
  801611:	c3                   	ret    

00801612 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801612:	55                   	push   %ebp
  801613:	89 e5                	mov    %esp,%ebp
  801615:	53                   	push   %ebx
  801616:	83 ec 14             	sub    $0x14,%esp
  801619:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80161c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80161f:	50                   	push   %eax
  801620:	ff 75 08             	pushl  0x8(%ebp)
  801623:	e8 63 fb ff ff       	call   80118b <fd_lookup>
  801628:	83 c4 08             	add    $0x8,%esp
  80162b:	85 c0                	test   %eax,%eax
  80162d:	78 52                	js     801681 <fstat+0x6f>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80162f:	83 ec 08             	sub    $0x8,%esp
  801632:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801635:	50                   	push   %eax
  801636:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801639:	ff 30                	pushl  (%eax)
  80163b:	e8 a1 fb ff ff       	call   8011e1 <dev_lookup>
  801640:	83 c4 10             	add    $0x10,%esp
  801643:	85 c0                	test   %eax,%eax
  801645:	78 3a                	js     801681 <fstat+0x6f>
		return r;
	if (!dev->dev_stat)
  801647:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80164a:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  80164e:	74 2c                	je     80167c <fstat+0x6a>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801650:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801653:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80165a:	00 00 00 
	stat->st_isdir = 0;
  80165d:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801664:	00 00 00 
	stat->st_dev = dev;
  801667:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  80166d:	83 ec 08             	sub    $0x8,%esp
  801670:	53                   	push   %ebx
  801671:	ff 75 f0             	pushl  -0x10(%ebp)
  801674:	ff 50 14             	call   *0x14(%eax)
  801677:	83 c4 10             	add    $0x10,%esp
  80167a:	eb 05                	jmp    801681 <fstat+0x6f>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  80167c:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801681:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801684:	c9                   	leave  
  801685:	c3                   	ret    

00801686 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801686:	55                   	push   %ebp
  801687:	89 e5                	mov    %esp,%ebp
  801689:	56                   	push   %esi
  80168a:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  80168b:	83 ec 08             	sub    $0x8,%esp
  80168e:	6a 00                	push   $0x0
  801690:	ff 75 08             	pushl  0x8(%ebp)
  801693:	e8 8b 01 00 00       	call   801823 <open>
  801698:	89 c3                	mov    %eax,%ebx
  80169a:	83 c4 10             	add    $0x10,%esp
  80169d:	85 c0                	test   %eax,%eax
  80169f:	78 1b                	js     8016bc <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8016a1:	83 ec 08             	sub    $0x8,%esp
  8016a4:	ff 75 0c             	pushl  0xc(%ebp)
  8016a7:	50                   	push   %eax
  8016a8:	e8 65 ff ff ff       	call   801612 <fstat>
  8016ad:	89 c6                	mov    %eax,%esi
	close(fd);
  8016af:	89 1c 24             	mov    %ebx,(%esp)
  8016b2:	e8 18 fc ff ff       	call   8012cf <close>
	return r;
  8016b7:	83 c4 10             	add    $0x10,%esp
  8016ba:	89 f3                	mov    %esi,%ebx
}
  8016bc:	89 d8                	mov    %ebx,%eax
  8016be:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8016c1:	5b                   	pop    %ebx
  8016c2:	5e                   	pop    %esi
  8016c3:	c9                   	leave  
  8016c4:	c3                   	ret    
  8016c5:	00 00                	add    %al,(%eax)
	...

008016c8 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8016c8:	55                   	push   %ebp
  8016c9:	89 e5                	mov    %esp,%ebp
  8016cb:	56                   	push   %esi
  8016cc:	53                   	push   %ebx
  8016cd:	89 c3                	mov    %eax,%ebx
  8016cf:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  8016d1:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8016d8:	75 12                	jne    8016ec <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8016da:	83 ec 0c             	sub    $0xc,%esp
  8016dd:	6a 01                	push   $0x1
  8016df:	e8 f1 08 00 00       	call   801fd5 <ipc_find_env>
  8016e4:	a3 00 40 80 00       	mov    %eax,0x804000
  8016e9:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8016ec:	6a 07                	push   $0x7
  8016ee:	68 00 50 80 00       	push   $0x805000
  8016f3:	53                   	push   %ebx
  8016f4:	ff 35 00 40 80 00    	pushl  0x804000
  8016fa:	e8 81 08 00 00       	call   801f80 <ipc_send>
	
	return ipc_recv(NULL, dstva, NULL);
  8016ff:	83 c4 0c             	add    $0xc,%esp
  801702:	6a 00                	push   $0x0
  801704:	56                   	push   %esi
  801705:	6a 00                	push   $0x0
  801707:	e8 cc 07 00 00       	call   801ed8 <ipc_recv>
}
  80170c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80170f:	5b                   	pop    %ebx
  801710:	5e                   	pop    %esi
  801711:	c9                   	leave  
  801712:	c3                   	ret    

00801713 <devfile_stat>:
}


static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801713:	55                   	push   %ebp
  801714:	89 e5                	mov    %esp,%ebp
  801716:	53                   	push   %ebx
  801717:	83 ec 04             	sub    $0x4,%esp
  80171a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  80171d:	8b 45 08             	mov    0x8(%ebp),%eax
  801720:	8b 40 0c             	mov    0xc(%eax),%eax
  801723:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0) {
  801728:	ba 00 00 00 00       	mov    $0x0,%edx
  80172d:	b8 05 00 00 00       	mov    $0x5,%eax
  801732:	e8 91 ff ff ff       	call   8016c8 <fsipc>
  801737:	85 c0                	test   %eax,%eax
  801739:	78 39                	js     801774 <devfile_stat+0x61>
		return r;
	}
	cprintf("OVER\n");
  80173b:	83 ec 0c             	sub    $0xc,%esp
  80173e:	68 3c 27 80 00       	push   $0x80273c
  801743:	e8 d4 ec ff ff       	call   80041c <cprintf>
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801748:	83 c4 08             	add    $0x8,%esp
  80174b:	68 00 50 80 00       	push   $0x805000
  801750:	53                   	push   %ebx
  801751:	e8 7c f2 ff ff       	call   8009d2 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801756:	a1 80 50 80 00       	mov    0x805080,%eax
  80175b:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801761:	a1 84 50 80 00       	mov    0x805084,%eax
  801766:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  80176c:	83 c4 10             	add    $0x10,%esp
  80176f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801774:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801777:	c9                   	leave  
  801778:	c3                   	ret    

00801779 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801779:	55                   	push   %ebp
  80177a:	89 e5                	mov    %esp,%ebp
  80177c:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  80177f:	8b 45 08             	mov    0x8(%ebp),%eax
  801782:	8b 40 0c             	mov    0xc(%eax),%eax
  801785:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  80178a:	ba 00 00 00 00       	mov    $0x0,%edx
  80178f:	b8 06 00 00 00       	mov    $0x6,%eax
  801794:	e8 2f ff ff ff       	call   8016c8 <fsipc>
}
  801799:	c9                   	leave  
  80179a:	c3                   	ret    

0080179b <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  80179b:	55                   	push   %ebp
  80179c:	89 e5                	mov    %esp,%ebp
  80179e:	56                   	push   %esi
  80179f:	53                   	push   %ebx
  8017a0:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8017a3:	8b 45 08             	mov    0x8(%ebp),%eax
  8017a6:	8b 40 0c             	mov    0xc(%eax),%eax
  8017a9:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  8017ae:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8017b4:	ba 00 00 00 00       	mov    $0x0,%edx
  8017b9:	b8 03 00 00 00       	mov    $0x3,%eax
  8017be:	e8 05 ff ff ff       	call   8016c8 <fsipc>
  8017c3:	89 c3                	mov    %eax,%ebx
  8017c5:	85 c0                	test   %eax,%eax
  8017c7:	78 51                	js     80181a <devfile_read+0x7f>
		return r;
	assert(r <= n);
  8017c9:	39 c6                	cmp    %eax,%esi
  8017cb:	73 19                	jae    8017e6 <devfile_read+0x4b>
  8017cd:	68 42 27 80 00       	push   $0x802742
  8017d2:	68 49 27 80 00       	push   $0x802749
  8017d7:	68 80 00 00 00       	push   $0x80
  8017dc:	68 5e 27 80 00       	push   $0x80275e
  8017e1:	e8 5e eb ff ff       	call   800344 <_panic>
	assert(r <= PGSIZE);
  8017e6:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8017eb:	7e 19                	jle    801806 <devfile_read+0x6b>
  8017ed:	68 69 27 80 00       	push   $0x802769
  8017f2:	68 49 27 80 00       	push   $0x802749
  8017f7:	68 81 00 00 00       	push   $0x81
  8017fc:	68 5e 27 80 00       	push   $0x80275e
  801801:	e8 3e eb ff ff       	call   800344 <_panic>
	memmove(buf, &fsipcbuf, r);
  801806:	83 ec 04             	sub    $0x4,%esp
  801809:	50                   	push   %eax
  80180a:	68 00 50 80 00       	push   $0x805000
  80180f:	ff 75 0c             	pushl  0xc(%ebp)
  801812:	e8 7c f3 ff ff       	call   800b93 <memmove>
	return r;
  801817:	83 c4 10             	add    $0x10,%esp
}
  80181a:	89 d8                	mov    %ebx,%eax
  80181c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80181f:	5b                   	pop    %ebx
  801820:	5e                   	pop    %esi
  801821:	c9                   	leave  
  801822:	c3                   	ret    

00801823 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801823:	55                   	push   %ebp
  801824:	89 e5                	mov    %esp,%ebp
  801826:	56                   	push   %esi
  801827:	53                   	push   %ebx
  801828:	83 ec 1c             	sub    $0x1c,%esp
  80182b:	8b 75 08             	mov    0x8(%ebp),%esi
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  80182e:	56                   	push   %esi
  80182f:	e8 4c f1 ff ff       	call   800980 <strlen>
  801834:	83 c4 10             	add    $0x10,%esp
  801837:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  80183c:	7f 72                	jg     8018b0 <open+0x8d>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  80183e:	83 ec 0c             	sub    $0xc,%esp
  801841:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801844:	50                   	push   %eax
  801845:	e8 ce f8 ff ff       	call   801118 <fd_alloc>
  80184a:	89 c3                	mov    %eax,%ebx
  80184c:	83 c4 10             	add    $0x10,%esp
  80184f:	85 c0                	test   %eax,%eax
  801851:	78 62                	js     8018b5 <open+0x92>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801853:	83 ec 08             	sub    $0x8,%esp
  801856:	56                   	push   %esi
  801857:	68 00 50 80 00       	push   $0x805000
  80185c:	e8 71 f1 ff ff       	call   8009d2 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801861:	8b 45 0c             	mov    0xc(%ebp),%eax
  801864:	a3 00 54 80 00       	mov    %eax,0x805400



	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801869:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80186c:	b8 01 00 00 00       	mov    $0x1,%eax
  801871:	e8 52 fe ff ff       	call   8016c8 <fsipc>
  801876:	89 c3                	mov    %eax,%ebx
  801878:	83 c4 10             	add    $0x10,%esp
  80187b:	85 c0                	test   %eax,%eax
  80187d:	79 12                	jns    801891 <open+0x6e>
		fd_close(fd, 0);
  80187f:	83 ec 08             	sub    $0x8,%esp
  801882:	6a 00                	push   $0x0
  801884:	ff 75 f4             	pushl  -0xc(%ebp)
  801887:	e8 bb f9 ff ff       	call   801247 <fd_close>
		return r;
  80188c:	83 c4 10             	add    $0x10,%esp
  80188f:	eb 24                	jmp    8018b5 <open+0x92>
	}


	cprintf("OPEN\n");
  801891:	83 ec 0c             	sub    $0xc,%esp
  801894:	68 75 27 80 00       	push   $0x802775
  801899:	e8 7e eb ff ff       	call   80041c <cprintf>

	return fd2num(fd);
  80189e:	83 c4 04             	add    $0x4,%esp
  8018a1:	ff 75 f4             	pushl  -0xc(%ebp)
  8018a4:	e8 47 f8 ff ff       	call   8010f0 <fd2num>
  8018a9:	89 c3                	mov    %eax,%ebx
  8018ab:	83 c4 10             	add    $0x10,%esp
  8018ae:	eb 05                	jmp    8018b5 <open+0x92>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  8018b0:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx


	cprintf("OPEN\n");

	return fd2num(fd);
}
  8018b5:	89 d8                	mov    %ebx,%eax
  8018b7:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8018ba:	5b                   	pop    %ebx
  8018bb:	5e                   	pop    %esi
  8018bc:	c9                   	leave  
  8018bd:	c3                   	ret    
	...

008018c0 <writebuf>:
};


static void
writebuf(struct printbuf *b)
{
  8018c0:	55                   	push   %ebp
  8018c1:	89 e5                	mov    %esp,%ebp
  8018c3:	53                   	push   %ebx
  8018c4:	83 ec 04             	sub    $0x4,%esp
  8018c7:	89 c3                	mov    %eax,%ebx
	if (b->error > 0) {
  8018c9:	83 78 0c 00          	cmpl   $0x0,0xc(%eax)
  8018cd:	7e 2e                	jle    8018fd <writebuf+0x3d>
		ssize_t result = write(b->fd, b->buf, b->idx);
  8018cf:	83 ec 04             	sub    $0x4,%esp
  8018d2:	ff 70 04             	pushl  0x4(%eax)
  8018d5:	8d 40 10             	lea    0x10(%eax),%eax
  8018d8:	50                   	push   %eax
  8018d9:	ff 33                	pushl  (%ebx)
  8018db:	e8 08 fc ff ff       	call   8014e8 <write>
		if (result > 0)
  8018e0:	83 c4 10             	add    $0x10,%esp
  8018e3:	85 c0                	test   %eax,%eax
  8018e5:	7e 03                	jle    8018ea <writebuf+0x2a>
			b->result += result;
  8018e7:	01 43 08             	add    %eax,0x8(%ebx)
		if (result != b->idx) // error, or wrote less than supplied
  8018ea:	39 43 04             	cmp    %eax,0x4(%ebx)
  8018ed:	74 0e                	je     8018fd <writebuf+0x3d>
			b->error = (result < 0 ? result : 0);
  8018ef:	89 c2                	mov    %eax,%edx
  8018f1:	85 c0                	test   %eax,%eax
  8018f3:	7e 05                	jle    8018fa <writebuf+0x3a>
  8018f5:	ba 00 00 00 00       	mov    $0x0,%edx
  8018fa:	89 53 0c             	mov    %edx,0xc(%ebx)
	}
}
  8018fd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801900:	c9                   	leave  
  801901:	c3                   	ret    

00801902 <putch>:

static void
putch(int ch, void *thunk)
{
  801902:	55                   	push   %ebp
  801903:	89 e5                	mov    %esp,%ebp
  801905:	53                   	push   %ebx
  801906:	83 ec 04             	sub    $0x4,%esp
  801909:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct printbuf *b = (struct printbuf *) thunk;
	b->buf[b->idx++] = ch;
  80190c:	8b 43 04             	mov    0x4(%ebx),%eax
  80190f:	8b 55 08             	mov    0x8(%ebp),%edx
  801912:	88 54 03 10          	mov    %dl,0x10(%ebx,%eax,1)
  801916:	40                   	inc    %eax
  801917:	89 43 04             	mov    %eax,0x4(%ebx)
	if (b->idx == 256) {
  80191a:	3d 00 01 00 00       	cmp    $0x100,%eax
  80191f:	75 0e                	jne    80192f <putch+0x2d>
		writebuf(b);
  801921:	89 d8                	mov    %ebx,%eax
  801923:	e8 98 ff ff ff       	call   8018c0 <writebuf>
		b->idx = 0;
  801928:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	}
}
  80192f:	83 c4 04             	add    $0x4,%esp
  801932:	5b                   	pop    %ebx
  801933:	c9                   	leave  
  801934:	c3                   	ret    

00801935 <vfprintf>:

int
vfprintf(int fd, const char *fmt, va_list ap)
{
  801935:	55                   	push   %ebp
  801936:	89 e5                	mov    %esp,%ebp
  801938:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.fd = fd;
  80193e:	8b 45 08             	mov    0x8(%ebp),%eax
  801941:	89 85 e8 fe ff ff    	mov    %eax,-0x118(%ebp)
	b.idx = 0;
  801947:	c7 85 ec fe ff ff 00 	movl   $0x0,-0x114(%ebp)
  80194e:	00 00 00 
	b.result = 0;
  801951:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  801958:	00 00 00 
	b.error = 1;
  80195b:	c7 85 f4 fe ff ff 01 	movl   $0x1,-0x10c(%ebp)
  801962:	00 00 00 
	vprintfmt(putch, &b, fmt, ap);
  801965:	ff 75 10             	pushl  0x10(%ebp)
  801968:	ff 75 0c             	pushl  0xc(%ebp)
  80196b:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  801971:	50                   	push   %eax
  801972:	68 02 19 80 00       	push   $0x801902
  801977:	e8 05 ec ff ff       	call   800581 <vprintfmt>
	if (b.idx > 0)
  80197c:	83 c4 10             	add    $0x10,%esp
  80197f:	83 bd ec fe ff ff 00 	cmpl   $0x0,-0x114(%ebp)
  801986:	7e 0b                	jle    801993 <vfprintf+0x5e>
		writebuf(&b);
  801988:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  80198e:	e8 2d ff ff ff       	call   8018c0 <writebuf>

	return (b.result ? b.result : b.error);
  801993:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  801999:	85 c0                	test   %eax,%eax
  80199b:	75 06                	jne    8019a3 <vfprintf+0x6e>
  80199d:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
}
  8019a3:	c9                   	leave  
  8019a4:	c3                   	ret    

008019a5 <fprintf>:

int
fprintf(int fd, const char *fmt, ...)
{
  8019a5:	55                   	push   %ebp
  8019a6:	89 e5                	mov    %esp,%ebp
  8019a8:	83 ec 0c             	sub    $0xc,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8019ab:	8d 45 10             	lea    0x10(%ebp),%eax
	cnt = vfprintf(fd, fmt, ap);
  8019ae:	50                   	push   %eax
  8019af:	ff 75 0c             	pushl  0xc(%ebp)
  8019b2:	ff 75 08             	pushl  0x8(%ebp)
  8019b5:	e8 7b ff ff ff       	call   801935 <vfprintf>
	va_end(ap);

	return cnt;
}
  8019ba:	c9                   	leave  
  8019bb:	c3                   	ret    

008019bc <printf>:

int
printf(const char *fmt, ...)
{
  8019bc:	55                   	push   %ebp
  8019bd:	89 e5                	mov    %esp,%ebp
  8019bf:	83 ec 0c             	sub    $0xc,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8019c2:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vfprintf(1, fmt, ap);
  8019c5:	50                   	push   %eax
  8019c6:	ff 75 08             	pushl  0x8(%ebp)
  8019c9:	6a 01                	push   $0x1
  8019cb:	e8 65 ff ff ff       	call   801935 <vfprintf>
	va_end(ap);

	return cnt;
}
  8019d0:	c9                   	leave  
  8019d1:	c3                   	ret    
	...

008019d4 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  8019d4:	55                   	push   %ebp
  8019d5:	89 e5                	mov    %esp,%ebp
  8019d7:	56                   	push   %esi
  8019d8:	53                   	push   %ebx
  8019d9:	8b 75 0c             	mov    0xc(%ebp),%esi
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  8019dc:	83 ec 0c             	sub    $0xc,%esp
  8019df:	ff 75 08             	pushl  0x8(%ebp)
  8019e2:	e8 19 f7 ff ff       	call   801100 <fd2data>
  8019e7:	89 c3                	mov    %eax,%ebx
	strcpy(stat->st_name, "<pipe>");
  8019e9:	83 c4 08             	add    $0x8,%esp
  8019ec:	68 7b 27 80 00       	push   $0x80277b
  8019f1:	56                   	push   %esi
  8019f2:	e8 db ef ff ff       	call   8009d2 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  8019f7:	8b 43 04             	mov    0x4(%ebx),%eax
  8019fa:	2b 03                	sub    (%ebx),%eax
  8019fc:	89 86 80 00 00 00    	mov    %eax,0x80(%esi)
	stat->st_isdir = 0;
  801a02:	c7 86 84 00 00 00 00 	movl   $0x0,0x84(%esi)
  801a09:	00 00 00 
	stat->st_dev = &devpipe;
  801a0c:	c7 86 88 00 00 00 20 	movl   $0x803020,0x88(%esi)
  801a13:	30 80 00 
	return 0;
}
  801a16:	b8 00 00 00 00       	mov    $0x0,%eax
  801a1b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a1e:	5b                   	pop    %ebx
  801a1f:	5e                   	pop    %esi
  801a20:	c9                   	leave  
  801a21:	c3                   	ret    

00801a22 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801a22:	55                   	push   %ebp
  801a23:	89 e5                	mov    %esp,%ebp
  801a25:	53                   	push   %ebx
  801a26:	83 ec 0c             	sub    $0xc,%esp
  801a29:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801a2c:	53                   	push   %ebx
  801a2d:	6a 00                	push   $0x0
  801a2f:	e8 6a f4 ff ff       	call   800e9e <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801a34:	89 1c 24             	mov    %ebx,(%esp)
  801a37:	e8 c4 f6 ff ff       	call   801100 <fd2data>
  801a3c:	83 c4 08             	add    $0x8,%esp
  801a3f:	50                   	push   %eax
  801a40:	6a 00                	push   $0x0
  801a42:	e8 57 f4 ff ff       	call   800e9e <sys_page_unmap>
}
  801a47:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a4a:	c9                   	leave  
  801a4b:	c3                   	ret    

00801a4c <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801a4c:	55                   	push   %ebp
  801a4d:	89 e5                	mov    %esp,%ebp
  801a4f:	57                   	push   %edi
  801a50:	56                   	push   %esi
  801a51:	53                   	push   %ebx
  801a52:	83 ec 1c             	sub    $0x1c,%esp
  801a55:	89 c7                	mov    %eax,%edi
  801a57:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801a5a:	a1 20 44 80 00       	mov    0x804420,%eax
  801a5f:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801a62:	83 ec 0c             	sub    $0xc,%esp
  801a65:	57                   	push   %edi
  801a66:	e8 c5 05 00 00       	call   802030 <pageref>
  801a6b:	89 c6                	mov    %eax,%esi
  801a6d:	83 c4 04             	add    $0x4,%esp
  801a70:	ff 75 e4             	pushl  -0x1c(%ebp)
  801a73:	e8 b8 05 00 00       	call   802030 <pageref>
  801a78:	83 c4 10             	add    $0x10,%esp
  801a7b:	39 c6                	cmp    %eax,%esi
  801a7d:	0f 94 c0             	sete   %al
  801a80:	0f b6 c0             	movzbl %al,%eax
		nn = thisenv->env_runs;
  801a83:	8b 15 20 44 80 00    	mov    0x804420,%edx
  801a89:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801a8c:	39 cb                	cmp    %ecx,%ebx
  801a8e:	75 08                	jne    801a98 <_pipeisclosed+0x4c>
			return ret;
		if (n != nn && ret == 1)
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
	}
}
  801a90:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801a93:	5b                   	pop    %ebx
  801a94:	5e                   	pop    %esi
  801a95:	5f                   	pop    %edi
  801a96:	c9                   	leave  
  801a97:	c3                   	ret    
		n = thisenv->env_runs;
		ret = pageref(fd) == pageref(p);
		nn = thisenv->env_runs;
		if (n == nn)
			return ret;
		if (n != nn && ret == 1)
  801a98:	83 f8 01             	cmp    $0x1,%eax
  801a9b:	75 bd                	jne    801a5a <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801a9d:	8b 42 58             	mov    0x58(%edx),%eax
  801aa0:	6a 01                	push   $0x1
  801aa2:	50                   	push   %eax
  801aa3:	53                   	push   %ebx
  801aa4:	68 82 27 80 00       	push   $0x802782
  801aa9:	e8 6e e9 ff ff       	call   80041c <cprintf>
  801aae:	83 c4 10             	add    $0x10,%esp
  801ab1:	eb a7                	jmp    801a5a <_pipeisclosed+0xe>

00801ab3 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801ab3:	55                   	push   %ebp
  801ab4:	89 e5                	mov    %esp,%ebp
  801ab6:	57                   	push   %edi
  801ab7:	56                   	push   %esi
  801ab8:	53                   	push   %ebx
  801ab9:	83 ec 28             	sub    $0x28,%esp
  801abc:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801abf:	56                   	push   %esi
  801ac0:	e8 3b f6 ff ff       	call   801100 <fd2data>
  801ac5:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801ac7:	83 c4 10             	add    $0x10,%esp
  801aca:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801ace:	75 4a                	jne    801b1a <devpipe_write+0x67>
  801ad0:	bf 00 00 00 00       	mov    $0x0,%edi
  801ad5:	eb 56                	jmp    801b2d <devpipe_write+0x7a>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801ad7:	89 da                	mov    %ebx,%edx
  801ad9:	89 f0                	mov    %esi,%eax
  801adb:	e8 6c ff ff ff       	call   801a4c <_pipeisclosed>
  801ae0:	85 c0                	test   %eax,%eax
  801ae2:	75 4d                	jne    801b31 <devpipe_write+0x7e>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801ae4:	e8 44 f3 ff ff       	call   800e2d <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801ae9:	8b 43 04             	mov    0x4(%ebx),%eax
  801aec:	8b 13                	mov    (%ebx),%edx
  801aee:	83 c2 20             	add    $0x20,%edx
  801af1:	39 d0                	cmp    %edx,%eax
  801af3:	73 e2                	jae    801ad7 <devpipe_write+0x24>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801af5:	89 c2                	mov    %eax,%edx
  801af7:	81 e2 1f 00 00 80    	and    $0x8000001f,%edx
  801afd:	79 05                	jns    801b04 <devpipe_write+0x51>
  801aff:	4a                   	dec    %edx
  801b00:	83 ca e0             	or     $0xffffffe0,%edx
  801b03:	42                   	inc    %edx
  801b04:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801b07:	8a 0c 39             	mov    (%ecx,%edi,1),%cl
  801b0a:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801b0e:	40                   	inc    %eax
  801b0f:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801b12:	47                   	inc    %edi
  801b13:	39 7d 10             	cmp    %edi,0x10(%ebp)
  801b16:	77 07                	ja     801b1f <devpipe_write+0x6c>
  801b18:	eb 13                	jmp    801b2d <devpipe_write+0x7a>
  801b1a:	bf 00 00 00 00       	mov    $0x0,%edi
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801b1f:	8b 43 04             	mov    0x4(%ebx),%eax
  801b22:	8b 13                	mov    (%ebx),%edx
  801b24:	83 c2 20             	add    $0x20,%edx
  801b27:	39 d0                	cmp    %edx,%eax
  801b29:	73 ac                	jae    801ad7 <devpipe_write+0x24>
  801b2b:	eb c8                	jmp    801af5 <devpipe_write+0x42>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801b2d:	89 f8                	mov    %edi,%eax
  801b2f:	eb 05                	jmp    801b36 <devpipe_write+0x83>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801b31:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801b36:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b39:	5b                   	pop    %ebx
  801b3a:	5e                   	pop    %esi
  801b3b:	5f                   	pop    %edi
  801b3c:	c9                   	leave  
  801b3d:	c3                   	ret    

00801b3e <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801b3e:	55                   	push   %ebp
  801b3f:	89 e5                	mov    %esp,%ebp
  801b41:	57                   	push   %edi
  801b42:	56                   	push   %esi
  801b43:	53                   	push   %ebx
  801b44:	83 ec 18             	sub    $0x18,%esp
  801b47:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801b4a:	57                   	push   %edi
  801b4b:	e8 b0 f5 ff ff       	call   801100 <fd2data>
  801b50:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801b52:	83 c4 10             	add    $0x10,%esp
  801b55:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801b59:	75 44                	jne    801b9f <devpipe_read+0x61>
  801b5b:	be 00 00 00 00       	mov    $0x0,%esi
  801b60:	eb 4f                	jmp    801bb1 <devpipe_read+0x73>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
				return i;
  801b62:	89 f0                	mov    %esi,%eax
  801b64:	eb 54                	jmp    801bba <devpipe_read+0x7c>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801b66:	89 da                	mov    %ebx,%edx
  801b68:	89 f8                	mov    %edi,%eax
  801b6a:	e8 dd fe ff ff       	call   801a4c <_pipeisclosed>
  801b6f:	85 c0                	test   %eax,%eax
  801b71:	75 42                	jne    801bb5 <devpipe_read+0x77>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801b73:	e8 b5 f2 ff ff       	call   800e2d <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801b78:	8b 03                	mov    (%ebx),%eax
  801b7a:	3b 43 04             	cmp    0x4(%ebx),%eax
  801b7d:	74 e7                	je     801b66 <devpipe_read+0x28>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801b7f:	25 1f 00 00 80       	and    $0x8000001f,%eax
  801b84:	79 05                	jns    801b8b <devpipe_read+0x4d>
  801b86:	48                   	dec    %eax
  801b87:	83 c8 e0             	or     $0xffffffe0,%eax
  801b8a:	40                   	inc    %eax
  801b8b:	8a 44 03 08          	mov    0x8(%ebx,%eax,1),%al
  801b8f:	8b 55 0c             	mov    0xc(%ebp),%edx
  801b92:	88 04 32             	mov    %al,(%edx,%esi,1)
		p->p_rpos++;
  801b95:	ff 03                	incl   (%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801b97:	46                   	inc    %esi
  801b98:	39 75 10             	cmp    %esi,0x10(%ebp)
  801b9b:	77 07                	ja     801ba4 <devpipe_read+0x66>
  801b9d:	eb 12                	jmp    801bb1 <devpipe_read+0x73>
  801b9f:	be 00 00 00 00       	mov    $0x0,%esi
		while (p->p_rpos == p->p_wpos) {
  801ba4:	8b 03                	mov    (%ebx),%eax
  801ba6:	3b 43 04             	cmp    0x4(%ebx),%eax
  801ba9:	75 d4                	jne    801b7f <devpipe_read+0x41>
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801bab:	85 f6                	test   %esi,%esi
  801bad:	75 b3                	jne    801b62 <devpipe_read+0x24>
  801baf:	eb b5                	jmp    801b66 <devpipe_read+0x28>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801bb1:	89 f0                	mov    %esi,%eax
  801bb3:	eb 05                	jmp    801bba <devpipe_read+0x7c>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801bb5:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801bba:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801bbd:	5b                   	pop    %ebx
  801bbe:	5e                   	pop    %esi
  801bbf:	5f                   	pop    %edi
  801bc0:	c9                   	leave  
  801bc1:	c3                   	ret    

00801bc2 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801bc2:	55                   	push   %ebp
  801bc3:	89 e5                	mov    %esp,%ebp
  801bc5:	57                   	push   %edi
  801bc6:	56                   	push   %esi
  801bc7:	53                   	push   %ebx
  801bc8:	83 ec 28             	sub    $0x28,%esp
  801bcb:	8b 7d 08             	mov    0x8(%ebp),%edi
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801bce:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801bd1:	50                   	push   %eax
  801bd2:	e8 41 f5 ff ff       	call   801118 <fd_alloc>
  801bd7:	89 c3                	mov    %eax,%ebx
  801bd9:	83 c4 10             	add    $0x10,%esp
  801bdc:	85 c0                	test   %eax,%eax
  801bde:	0f 88 24 01 00 00    	js     801d08 <pipe+0x146>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801be4:	83 ec 04             	sub    $0x4,%esp
  801be7:	68 07 04 00 00       	push   $0x407
  801bec:	ff 75 e4             	pushl  -0x1c(%ebp)
  801bef:	6a 00                	push   $0x0
  801bf1:	e8 5e f2 ff ff       	call   800e54 <sys_page_alloc>
  801bf6:	89 c3                	mov    %eax,%ebx
  801bf8:	83 c4 10             	add    $0x10,%esp
  801bfb:	85 c0                	test   %eax,%eax
  801bfd:	0f 88 05 01 00 00    	js     801d08 <pipe+0x146>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801c03:	83 ec 0c             	sub    $0xc,%esp
  801c06:	8d 45 e0             	lea    -0x20(%ebp),%eax
  801c09:	50                   	push   %eax
  801c0a:	e8 09 f5 ff ff       	call   801118 <fd_alloc>
  801c0f:	89 c3                	mov    %eax,%ebx
  801c11:	83 c4 10             	add    $0x10,%esp
  801c14:	85 c0                	test   %eax,%eax
  801c16:	0f 88 dc 00 00 00    	js     801cf8 <pipe+0x136>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c1c:	83 ec 04             	sub    $0x4,%esp
  801c1f:	68 07 04 00 00       	push   $0x407
  801c24:	ff 75 e0             	pushl  -0x20(%ebp)
  801c27:	6a 00                	push   $0x0
  801c29:	e8 26 f2 ff ff       	call   800e54 <sys_page_alloc>
  801c2e:	89 c3                	mov    %eax,%ebx
  801c30:	83 c4 10             	add    $0x10,%esp
  801c33:	85 c0                	test   %eax,%eax
  801c35:	0f 88 bd 00 00 00    	js     801cf8 <pipe+0x136>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801c3b:	83 ec 0c             	sub    $0xc,%esp
  801c3e:	ff 75 e4             	pushl  -0x1c(%ebp)
  801c41:	e8 ba f4 ff ff       	call   801100 <fd2data>
  801c46:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c48:	83 c4 0c             	add    $0xc,%esp
  801c4b:	68 07 04 00 00       	push   $0x407
  801c50:	50                   	push   %eax
  801c51:	6a 00                	push   $0x0
  801c53:	e8 fc f1 ff ff       	call   800e54 <sys_page_alloc>
  801c58:	89 c3                	mov    %eax,%ebx
  801c5a:	83 c4 10             	add    $0x10,%esp
  801c5d:	85 c0                	test   %eax,%eax
  801c5f:	0f 88 83 00 00 00    	js     801ce8 <pipe+0x126>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c65:	83 ec 0c             	sub    $0xc,%esp
  801c68:	ff 75 e0             	pushl  -0x20(%ebp)
  801c6b:	e8 90 f4 ff ff       	call   801100 <fd2data>
  801c70:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801c77:	50                   	push   %eax
  801c78:	6a 00                	push   $0x0
  801c7a:	56                   	push   %esi
  801c7b:	6a 00                	push   $0x0
  801c7d:	e8 f6 f1 ff ff       	call   800e78 <sys_page_map>
  801c82:	89 c3                	mov    %eax,%ebx
  801c84:	83 c4 20             	add    $0x20,%esp
  801c87:	85 c0                	test   %eax,%eax
  801c89:	78 4f                	js     801cda <pipe+0x118>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801c8b:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801c91:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801c94:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801c96:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801c99:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801ca0:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801ca6:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801ca9:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801cab:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801cae:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801cb5:	83 ec 0c             	sub    $0xc,%esp
  801cb8:	ff 75 e4             	pushl  -0x1c(%ebp)
  801cbb:	e8 30 f4 ff ff       	call   8010f0 <fd2num>
  801cc0:	89 07                	mov    %eax,(%edi)
	pfd[1] = fd2num(fd1);
  801cc2:	83 c4 04             	add    $0x4,%esp
  801cc5:	ff 75 e0             	pushl  -0x20(%ebp)
  801cc8:	e8 23 f4 ff ff       	call   8010f0 <fd2num>
  801ccd:	89 47 04             	mov    %eax,0x4(%edi)
	return 0;
  801cd0:	83 c4 10             	add    $0x10,%esp
  801cd3:	bb 00 00 00 00       	mov    $0x0,%ebx
  801cd8:	eb 2e                	jmp    801d08 <pipe+0x146>

    err3:
	sys_page_unmap(0, va);
  801cda:	83 ec 08             	sub    $0x8,%esp
  801cdd:	56                   	push   %esi
  801cde:	6a 00                	push   $0x0
  801ce0:	e8 b9 f1 ff ff       	call   800e9e <sys_page_unmap>
  801ce5:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801ce8:	83 ec 08             	sub    $0x8,%esp
  801ceb:	ff 75 e0             	pushl  -0x20(%ebp)
  801cee:	6a 00                	push   $0x0
  801cf0:	e8 a9 f1 ff ff       	call   800e9e <sys_page_unmap>
  801cf5:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801cf8:	83 ec 08             	sub    $0x8,%esp
  801cfb:	ff 75 e4             	pushl  -0x1c(%ebp)
  801cfe:	6a 00                	push   $0x0
  801d00:	e8 99 f1 ff ff       	call   800e9e <sys_page_unmap>
  801d05:	83 c4 10             	add    $0x10,%esp
    err:
	return r;
}
  801d08:	89 d8                	mov    %ebx,%eax
  801d0a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801d0d:	5b                   	pop    %ebx
  801d0e:	5e                   	pop    %esi
  801d0f:	5f                   	pop    %edi
  801d10:	c9                   	leave  
  801d11:	c3                   	ret    

00801d12 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801d12:	55                   	push   %ebp
  801d13:	89 e5                	mov    %esp,%ebp
  801d15:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801d18:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801d1b:	50                   	push   %eax
  801d1c:	ff 75 08             	pushl  0x8(%ebp)
  801d1f:	e8 67 f4 ff ff       	call   80118b <fd_lookup>
  801d24:	83 c4 10             	add    $0x10,%esp
  801d27:	85 c0                	test   %eax,%eax
  801d29:	78 18                	js     801d43 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801d2b:	83 ec 0c             	sub    $0xc,%esp
  801d2e:	ff 75 f4             	pushl  -0xc(%ebp)
  801d31:	e8 ca f3 ff ff       	call   801100 <fd2data>
	return _pipeisclosed(fd, p);
  801d36:	89 c2                	mov    %eax,%edx
  801d38:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d3b:	e8 0c fd ff ff       	call   801a4c <_pipeisclosed>
  801d40:	83 c4 10             	add    $0x10,%esp
}
  801d43:	c9                   	leave  
  801d44:	c3                   	ret    
  801d45:	00 00                	add    %al,(%eax)
	...

00801d48 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801d48:	55                   	push   %ebp
  801d49:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801d4b:	b8 00 00 00 00       	mov    $0x0,%eax
  801d50:	c9                   	leave  
  801d51:	c3                   	ret    

00801d52 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801d52:	55                   	push   %ebp
  801d53:	89 e5                	mov    %esp,%ebp
  801d55:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801d58:	68 9a 27 80 00       	push   $0x80279a
  801d5d:	ff 75 0c             	pushl  0xc(%ebp)
  801d60:	e8 6d ec ff ff       	call   8009d2 <strcpy>
	return 0;
}
  801d65:	b8 00 00 00 00       	mov    $0x0,%eax
  801d6a:	c9                   	leave  
  801d6b:	c3                   	ret    

00801d6c <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801d6c:	55                   	push   %ebp
  801d6d:	89 e5                	mov    %esp,%ebp
  801d6f:	57                   	push   %edi
  801d70:	56                   	push   %esi
  801d71:	53                   	push   %ebx
  801d72:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801d78:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801d7c:	74 45                	je     801dc3 <devcons_write+0x57>
  801d7e:	b8 00 00 00 00       	mov    $0x0,%eax
  801d83:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801d88:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801d8e:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801d91:	29 c3                	sub    %eax,%ebx
		if (m > sizeof(buf) - 1)
  801d93:	83 fb 7f             	cmp    $0x7f,%ebx
  801d96:	76 05                	jbe    801d9d <devcons_write+0x31>
			m = sizeof(buf) - 1;
  801d98:	bb 7f 00 00 00       	mov    $0x7f,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  801d9d:	83 ec 04             	sub    $0x4,%esp
  801da0:	53                   	push   %ebx
  801da1:	03 45 0c             	add    0xc(%ebp),%eax
  801da4:	50                   	push   %eax
  801da5:	57                   	push   %edi
  801da6:	e8 e8 ed ff ff       	call   800b93 <memmove>
		sys_cputs(buf, m);
  801dab:	83 c4 08             	add    $0x8,%esp
  801dae:	53                   	push   %ebx
  801daf:	57                   	push   %edi
  801db0:	e8 e8 ef ff ff       	call   800d9d <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801db5:	01 de                	add    %ebx,%esi
  801db7:	89 f0                	mov    %esi,%eax
  801db9:	83 c4 10             	add    $0x10,%esp
  801dbc:	3b 75 10             	cmp    0x10(%ebp),%esi
  801dbf:	72 cd                	jb     801d8e <devcons_write+0x22>
  801dc1:	eb 05                	jmp    801dc8 <devcons_write+0x5c>
  801dc3:	be 00 00 00 00       	mov    $0x0,%esi
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801dc8:	89 f0                	mov    %esi,%eax
  801dca:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801dcd:	5b                   	pop    %ebx
  801dce:	5e                   	pop    %esi
  801dcf:	5f                   	pop    %edi
  801dd0:	c9                   	leave  
  801dd1:	c3                   	ret    

00801dd2 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801dd2:	55                   	push   %ebp
  801dd3:	89 e5                	mov    %esp,%ebp
  801dd5:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
  801dd8:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801ddc:	75 07                	jne    801de5 <devcons_read+0x13>
  801dde:	eb 25                	jmp    801e05 <devcons_read+0x33>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801de0:	e8 48 f0 ff ff       	call   800e2d <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801de5:	e8 d9 ef ff ff       	call   800dc3 <sys_cgetc>
  801dea:	85 c0                	test   %eax,%eax
  801dec:	74 f2                	je     801de0 <devcons_read+0xe>
  801dee:	89 c2                	mov    %eax,%edx
		sys_yield();
	if (c < 0)
  801df0:	85 c0                	test   %eax,%eax
  801df2:	78 1d                	js     801e11 <devcons_read+0x3f>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801df4:	83 f8 04             	cmp    $0x4,%eax
  801df7:	74 13                	je     801e0c <devcons_read+0x3a>
		return 0;
	*(char*)vbuf = c;
  801df9:	8b 45 0c             	mov    0xc(%ebp),%eax
  801dfc:	88 10                	mov    %dl,(%eax)
	return 1;
  801dfe:	b8 01 00 00 00       	mov    $0x1,%eax
  801e03:	eb 0c                	jmp    801e11 <devcons_read+0x3f>
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
		return 0;
  801e05:	b8 00 00 00 00       	mov    $0x0,%eax
  801e0a:	eb 05                	jmp    801e11 <devcons_read+0x3f>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801e0c:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801e11:	c9                   	leave  
  801e12:	c3                   	ret    

00801e13 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801e13:	55                   	push   %ebp
  801e14:	89 e5                	mov    %esp,%ebp
  801e16:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801e19:	8b 45 08             	mov    0x8(%ebp),%eax
  801e1c:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801e1f:	6a 01                	push   $0x1
  801e21:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801e24:	50                   	push   %eax
  801e25:	e8 73 ef ff ff       	call   800d9d <sys_cputs>
  801e2a:	83 c4 10             	add    $0x10,%esp
}
  801e2d:	c9                   	leave  
  801e2e:	c3                   	ret    

00801e2f <getchar>:

int
getchar(void)
{
  801e2f:	55                   	push   %ebp
  801e30:	89 e5                	mov    %esp,%ebp
  801e32:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801e35:	6a 01                	push   $0x1
  801e37:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801e3a:	50                   	push   %eax
  801e3b:	6a 00                	push   $0x0
  801e3d:	e8 ca f5 ff ff       	call   80140c <read>
	if (r < 0)
  801e42:	83 c4 10             	add    $0x10,%esp
  801e45:	85 c0                	test   %eax,%eax
  801e47:	78 0f                	js     801e58 <getchar+0x29>
		return r;
	if (r < 1)
  801e49:	85 c0                	test   %eax,%eax
  801e4b:	7e 06                	jle    801e53 <getchar+0x24>
		return -E_EOF;
	return c;
  801e4d:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801e51:	eb 05                	jmp    801e58 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801e53:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801e58:	c9                   	leave  
  801e59:	c3                   	ret    

00801e5a <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801e5a:	55                   	push   %ebp
  801e5b:	89 e5                	mov    %esp,%ebp
  801e5d:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801e60:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e63:	50                   	push   %eax
  801e64:	ff 75 08             	pushl  0x8(%ebp)
  801e67:	e8 1f f3 ff ff       	call   80118b <fd_lookup>
  801e6c:	83 c4 10             	add    $0x10,%esp
  801e6f:	85 c0                	test   %eax,%eax
  801e71:	78 11                	js     801e84 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801e73:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e76:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801e7c:	39 10                	cmp    %edx,(%eax)
  801e7e:	0f 94 c0             	sete   %al
  801e81:	0f b6 c0             	movzbl %al,%eax
}
  801e84:	c9                   	leave  
  801e85:	c3                   	ret    

00801e86 <opencons>:

int
opencons(void)
{
  801e86:	55                   	push   %ebp
  801e87:	89 e5                	mov    %esp,%ebp
  801e89:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801e8c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e8f:	50                   	push   %eax
  801e90:	e8 83 f2 ff ff       	call   801118 <fd_alloc>
  801e95:	83 c4 10             	add    $0x10,%esp
  801e98:	85 c0                	test   %eax,%eax
  801e9a:	78 3a                	js     801ed6 <opencons+0x50>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801e9c:	83 ec 04             	sub    $0x4,%esp
  801e9f:	68 07 04 00 00       	push   $0x407
  801ea4:	ff 75 f4             	pushl  -0xc(%ebp)
  801ea7:	6a 00                	push   $0x0
  801ea9:	e8 a6 ef ff ff       	call   800e54 <sys_page_alloc>
  801eae:	83 c4 10             	add    $0x10,%esp
  801eb1:	85 c0                	test   %eax,%eax
  801eb3:	78 21                	js     801ed6 <opencons+0x50>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801eb5:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801ebb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ebe:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801ec0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ec3:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801eca:	83 ec 0c             	sub    $0xc,%esp
  801ecd:	50                   	push   %eax
  801ece:	e8 1d f2 ff ff       	call   8010f0 <fd2num>
  801ed3:	83 c4 10             	add    $0x10,%esp
}
  801ed6:	c9                   	leave  
  801ed7:	c3                   	ret    

00801ed8 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801ed8:	55                   	push   %ebp
  801ed9:	89 e5                	mov    %esp,%ebp
  801edb:	57                   	push   %edi
  801edc:	56                   	push   %esi
  801edd:	53                   	push   %ebx
  801ede:	83 ec 0c             	sub    $0xc,%esp
  801ee1:	8b 7d 08             	mov    0x8(%ebp),%edi
  801ee4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801ee7:	8b 75 10             	mov    0x10(%ebp),%esi
	// LAB 4: Your code here.
	cprintf("0x%x 0x%x 0x%x\n", (uint32_t)from_env_store, (uint32_t)pg, (uint32_t)perm_store);
  801eea:	56                   	push   %esi
  801eeb:	53                   	push   %ebx
  801eec:	57                   	push   %edi
  801eed:	68 a6 27 80 00       	push   $0x8027a6
  801ef2:	e8 25 e5 ff ff       	call   80041c <cprintf>
	int r;
	if (pg != NULL) {
  801ef7:	83 c4 10             	add    $0x10,%esp
  801efa:	85 db                	test   %ebx,%ebx
  801efc:	74 28                	je     801f26 <ipc_recv+0x4e>
		cprintf("BEGIN\n");
  801efe:	83 ec 0c             	sub    $0xc,%esp
  801f01:	68 b6 27 80 00       	push   $0x8027b6
  801f06:	e8 11 e5 ff ff       	call   80041c <cprintf>
		r = sys_ipc_recv(pg);
  801f0b:	89 1c 24             	mov    %ebx,(%esp)
  801f0e:	e8 3c f0 ff ff       	call   800f4f <sys_ipc_recv>
  801f13:	89 c3                	mov    %eax,%ebx
		cprintf("OVER\n");
  801f15:	c7 04 24 3c 27 80 00 	movl   $0x80273c,(%esp)
  801f1c:	e8 fb e4 ff ff       	call   80041c <cprintf>
  801f21:	83 c4 10             	add    $0x10,%esp
  801f24:	eb 12                	jmp    801f38 <ipc_recv+0x60>
	} else {
		r = sys_ipc_recv((void *)UTOP);
  801f26:	83 ec 0c             	sub    $0xc,%esp
  801f29:	68 00 00 c0 ee       	push   $0xeec00000
  801f2e:	e8 1c f0 ff ff       	call   800f4f <sys_ipc_recv>
  801f33:	89 c3                	mov    %eax,%ebx
  801f35:	83 c4 10             	add    $0x10,%esp
	}

	if (r == 0) {
  801f38:	85 db                	test   %ebx,%ebx
  801f3a:	75 26                	jne    801f62 <ipc_recv+0x8a>
		if (from_env_store != NULL) *from_env_store = thisenv->env_ipc_from;
  801f3c:	85 ff                	test   %edi,%edi
  801f3e:	74 0a                	je     801f4a <ipc_recv+0x72>
  801f40:	a1 20 44 80 00       	mov    0x804420,%eax
  801f45:	8b 40 74             	mov    0x74(%eax),%eax
  801f48:	89 07                	mov    %eax,(%edi)
		if (perm_store != NULL) *perm_store = thisenv->env_ipc_perm;
  801f4a:	85 f6                	test   %esi,%esi
  801f4c:	74 0a                	je     801f58 <ipc_recv+0x80>
  801f4e:	a1 20 44 80 00       	mov    0x804420,%eax
  801f53:	8b 40 78             	mov    0x78(%eax),%eax
  801f56:	89 06                	mov    %eax,(%esi)
		return thisenv->env_ipc_value;
  801f58:	a1 20 44 80 00       	mov    0x804420,%eax
  801f5d:	8b 58 70             	mov    0x70(%eax),%ebx
  801f60:	eb 14                	jmp    801f76 <ipc_recv+0x9e>
	} else {
		// fails;
		if (from_env_store != NULL) *from_env_store = 0;
  801f62:	85 ff                	test   %edi,%edi
  801f64:	74 06                	je     801f6c <ipc_recv+0x94>
  801f66:	c7 07 00 00 00 00    	movl   $0x0,(%edi)
		if (perm_store != NULL) *perm_store = 0;
  801f6c:	85 f6                	test   %esi,%esi
  801f6e:	74 06                	je     801f76 <ipc_recv+0x9e>
  801f70:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		return r;
	}
}
  801f76:	89 d8                	mov    %ebx,%eax
  801f78:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801f7b:	5b                   	pop    %ebx
  801f7c:	5e                   	pop    %esi
  801f7d:	5f                   	pop    %edi
  801f7e:	c9                   	leave  
  801f7f:	c3                   	ret    

00801f80 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801f80:	55                   	push   %ebp
  801f81:	89 e5                	mov    %esp,%ebp
  801f83:	57                   	push   %edi
  801f84:	56                   	push   %esi
  801f85:	53                   	push   %ebx
  801f86:	83 ec 0c             	sub    $0xc,%esp
  801f89:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801f8c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801f8f:	8b 75 14             	mov    0x14(%ebp),%esi
	// LAB 4: Your code here.
	// int sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
	int r;
	if (pg == NULL) pg = (void *)UTOP;
  801f92:	85 db                	test   %ebx,%ebx
  801f94:	75 25                	jne    801fbb <ipc_send+0x3b>
  801f96:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
  801f9b:	eb 1e                	jmp    801fbb <ipc_send+0x3b>
	
	while ((r = sys_ipc_try_send(to_env, val, pg, perm)) != 0) {
		if (r == -E_IPC_NOT_RECV) {
  801f9d:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801fa0:	75 07                	jne    801fa9 <ipc_send+0x29>
			// cprintf("Try Again and Again....\n");
			sys_yield();
  801fa2:	e8 86 ee ff ff       	call   800e2d <sys_yield>
  801fa7:	eb 12                	jmp    801fbb <ipc_send+0x3b>
		} else {
			panic("ipc_send error %e\n", r);
  801fa9:	50                   	push   %eax
  801faa:	68 bd 27 80 00       	push   $0x8027bd
  801faf:	6a 45                	push   $0x45
  801fb1:	68 d0 27 80 00       	push   $0x8027d0
  801fb6:	e8 89 e3 ff ff       	call   800344 <_panic>
	// LAB 4: Your code here.
	// int sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
	int r;
	if (pg == NULL) pg = (void *)UTOP;
	
	while ((r = sys_ipc_try_send(to_env, val, pg, perm)) != 0) {
  801fbb:	56                   	push   %esi
  801fbc:	53                   	push   %ebx
  801fbd:	57                   	push   %edi
  801fbe:	ff 75 08             	pushl  0x8(%ebp)
  801fc1:	e8 64 ef ff ff       	call   800f2a <sys_ipc_try_send>
  801fc6:	83 c4 10             	add    $0x10,%esp
  801fc9:	85 c0                	test   %eax,%eax
  801fcb:	75 d0                	jne    801f9d <ipc_send+0x1d>
		} else {
			panic("ipc_send error %e\n", r);
		}
	}
	return;
}
  801fcd:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801fd0:	5b                   	pop    %ebx
  801fd1:	5e                   	pop    %esi
  801fd2:	5f                   	pop    %edi
  801fd3:	c9                   	leave  
  801fd4:	c3                   	ret    

00801fd5 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801fd5:	55                   	push   %ebp
  801fd6:	89 e5                	mov    %esp,%ebp
  801fd8:	53                   	push   %ebx
  801fd9:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	for (i = 0; i < NENV; i++)
		if (envs[i].env_type == type)
  801fdc:	39 1d 50 00 c0 ee    	cmp    %ebx,0xeec00050
  801fe2:	74 22                	je     802006 <ipc_find_env+0x31>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801fe4:	b8 01 00 00 00       	mov    $0x1,%eax
		if (envs[i].env_type == type)
  801fe9:	8d 0c 85 00 00 00 00 	lea    0x0(,%eax,4),%ecx
  801ff0:	89 c2                	mov    %eax,%edx
  801ff2:	c1 e2 07             	shl    $0x7,%edx
  801ff5:	29 ca                	sub    %ecx,%edx
  801ff7:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801ffd:	8b 52 50             	mov    0x50(%edx),%edx
  802000:	39 da                	cmp    %ebx,%edx
  802002:	75 1d                	jne    802021 <ipc_find_env+0x4c>
  802004:	eb 05                	jmp    80200b <ipc_find_env+0x36>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  802006:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
			return envs[i].env_id;
  80200b:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  802012:	c1 e0 07             	shl    $0x7,%eax
  802015:	29 d0                	sub    %edx,%eax
  802017:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  80201c:	8b 40 40             	mov    0x40(%eax),%eax
  80201f:	eb 0c                	jmp    80202d <ipc_find_env+0x58>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  802021:	40                   	inc    %eax
  802022:	3d 00 04 00 00       	cmp    $0x400,%eax
  802027:	75 c0                	jne    801fe9 <ipc_find_env+0x14>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  802029:	66 b8 00 00          	mov    $0x0,%ax
}
  80202d:	5b                   	pop    %ebx
  80202e:	c9                   	leave  
  80202f:	c3                   	ret    

00802030 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802030:	55                   	push   %ebp
  802031:	89 e5                	mov    %esp,%ebp
  802033:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802036:	89 c2                	mov    %eax,%edx
  802038:	c1 ea 16             	shr    $0x16,%edx
  80203b:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  802042:	f6 c2 01             	test   $0x1,%dl
  802045:	74 1e                	je     802065 <pageref+0x35>
		return 0;
	pte = uvpt[PGNUM(v)];
  802047:	c1 e8 0c             	shr    $0xc,%eax
  80204a:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  802051:	a8 01                	test   $0x1,%al
  802053:	74 17                	je     80206c <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802055:	c1 e8 0c             	shr    $0xc,%eax
  802058:	66 8b 04 c5 04 00 00 	mov    -0x10fffffc(,%eax,8),%ax
  80205f:	ef 
  802060:	0f b7 c0             	movzwl %ax,%eax
  802063:	eb 0c                	jmp    802071 <pageref+0x41>
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
		return 0;
  802065:	b8 00 00 00 00       	mov    $0x0,%eax
  80206a:	eb 05                	jmp    802071 <pageref+0x41>
	pte = uvpt[PGNUM(v)];
	if (!(pte & PTE_P))
		return 0;
  80206c:	b8 00 00 00 00       	mov    $0x0,%eax
	return pages[PGNUM(pte)].pp_ref;
}
  802071:	c9                   	leave  
  802072:	c3                   	ret    
	...

00802074 <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  802074:	55                   	push   %ebp
  802075:	89 e5                	mov    %esp,%ebp
  802077:	57                   	push   %edi
  802078:	56                   	push   %esi
  802079:	83 ec 10             	sub    $0x10,%esp
  80207c:	8b 7d 08             	mov    0x8(%ebp),%edi
  80207f:	8b 4d 10             	mov    0x10(%ebp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  802082:	89 7d f0             	mov    %edi,-0x10(%ebp)
  802085:	8b 75 0c             	mov    0xc(%ebp),%esi
  const DWunion dd = {.ll = d};
  802088:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  80208b:	8b 45 14             	mov    0x14(%ebp),%eax
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  80208e:	85 c0                	test   %eax,%eax
  802090:	75 2e                	jne    8020c0 <__udivdi3+0x4c>
    {
      if (d0 > n1)
  802092:	39 f1                	cmp    %esi,%ecx
  802094:	77 5a                	ja     8020f0 <__udivdi3+0x7c>
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  802096:	85 c9                	test   %ecx,%ecx
  802098:	75 0b                	jne    8020a5 <__udivdi3+0x31>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  80209a:	b8 01 00 00 00       	mov    $0x1,%eax
  80209f:	31 d2                	xor    %edx,%edx
  8020a1:	f7 f1                	div    %ecx
  8020a3:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  8020a5:	31 d2                	xor    %edx,%edx
  8020a7:	89 f0                	mov    %esi,%eax
  8020a9:	f7 f1                	div    %ecx
  8020ab:	89 c6                	mov    %eax,%esi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  8020ad:	89 f8                	mov    %edi,%eax
  8020af:	f7 f1                	div    %ecx
  8020b1:	89 c7                	mov    %eax,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  8020b3:	89 f8                	mov    %edi,%eax
  8020b5:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  8020b7:	83 c4 10             	add    $0x10,%esp
  8020ba:	5e                   	pop    %esi
  8020bb:	5f                   	pop    %edi
  8020bc:	c9                   	leave  
  8020bd:	c3                   	ret    
  8020be:	66 90                	xchg   %ax,%ax
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  8020c0:	39 f0                	cmp    %esi,%eax
  8020c2:	77 1c                	ja     8020e0 <__udivdi3+0x6c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  8020c4:	0f bd f8             	bsr    %eax,%edi
	  if (bm == 0)
  8020c7:	83 f7 1f             	xor    $0x1f,%edi
  8020ca:	75 3c                	jne    802108 <__udivdi3+0x94>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  8020cc:	39 f0                	cmp    %esi,%eax
  8020ce:	0f 82 90 00 00 00    	jb     802164 <__udivdi3+0xf0>
  8020d4:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8020d7:	39 55 f4             	cmp    %edx,-0xc(%ebp)
  8020da:	0f 86 84 00 00 00    	jbe    802164 <__udivdi3+0xf0>
  8020e0:	31 f6                	xor    %esi,%esi
  8020e2:	31 ff                	xor    %edi,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  8020e4:	89 f8                	mov    %edi,%eax
  8020e6:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  8020e8:	83 c4 10             	add    $0x10,%esp
  8020eb:	5e                   	pop    %esi
  8020ec:	5f                   	pop    %edi
  8020ed:	c9                   	leave  
  8020ee:	c3                   	ret    
  8020ef:	90                   	nop
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  8020f0:	89 f2                	mov    %esi,%edx
  8020f2:	89 f8                	mov    %edi,%eax
  8020f4:	f7 f1                	div    %ecx
  8020f6:	89 c7                	mov    %eax,%edi
  8020f8:	31 f6                	xor    %esi,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  8020fa:	89 f8                	mov    %edi,%eax
  8020fc:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  8020fe:	83 c4 10             	add    $0x10,%esp
  802101:	5e                   	pop    %esi
  802102:	5f                   	pop    %edi
  802103:	c9                   	leave  
  802104:	c3                   	ret    
  802105:	8d 76 00             	lea    0x0(%esi),%esi
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  802108:	89 f9                	mov    %edi,%ecx
  80210a:	d3 e0                	shl    %cl,%eax
  80210c:	89 45 e8             	mov    %eax,-0x18(%ebp)
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  80210f:	b8 20 00 00 00       	mov    $0x20,%eax
  802114:	29 f8                	sub    %edi,%eax

	      d1 = (d1 << bm) | (d0 >> b);
  802116:	8b 55 f4             	mov    -0xc(%ebp),%edx
  802119:	88 c1                	mov    %al,%cl
  80211b:	d3 ea                	shr    %cl,%edx
  80211d:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  802120:	09 ca                	or     %ecx,%edx
  802122:	89 55 ec             	mov    %edx,-0x14(%ebp)
	      d0 = d0 << bm;
  802125:	8b 55 f4             	mov    -0xc(%ebp),%edx
  802128:	89 f9                	mov    %edi,%ecx
  80212a:	d3 e2                	shl    %cl,%edx
  80212c:	89 55 f4             	mov    %edx,-0xc(%ebp)
	      n2 = n1 >> b;
  80212f:	89 f2                	mov    %esi,%edx
  802131:	88 c1                	mov    %al,%cl
  802133:	d3 ea                	shr    %cl,%edx
  802135:	89 55 e8             	mov    %edx,-0x18(%ebp)
	      n1 = (n1 << bm) | (n0 >> b);
  802138:	89 f2                	mov    %esi,%edx
  80213a:	89 f9                	mov    %edi,%ecx
  80213c:	d3 e2                	shl    %cl,%edx
  80213e:	8b 75 f0             	mov    -0x10(%ebp),%esi
  802141:	88 c1                	mov    %al,%cl
  802143:	d3 ee                	shr    %cl,%esi
  802145:	09 d6                	or     %edx,%esi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  802147:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  80214a:	89 f0                	mov    %esi,%eax
  80214c:	89 ca                	mov    %ecx,%edx
  80214e:	f7 75 ec             	divl   -0x14(%ebp)
  802151:	89 d1                	mov    %edx,%ecx
  802153:	89 c6                	mov    %eax,%esi
	      umul_ppmm (m1, m0, q0, d0);
  802155:	f7 65 f4             	mull   -0xc(%ebp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  802158:	39 d1                	cmp    %edx,%ecx
  80215a:	72 28                	jb     802184 <__udivdi3+0x110>
  80215c:	74 1a                	je     802178 <__udivdi3+0x104>
  80215e:	89 f7                	mov    %esi,%edi
  802160:	31 f6                	xor    %esi,%esi
  802162:	eb 80                	jmp    8020e4 <__udivdi3+0x70>
	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  802164:	31 f6                	xor    %esi,%esi
  802166:	bf 01 00 00 00       	mov    $0x1,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  80216b:	89 f8                	mov    %edi,%eax
  80216d:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  80216f:	83 c4 10             	add    $0x10,%esp
  802172:	5e                   	pop    %esi
  802173:	5f                   	pop    %edi
  802174:	c9                   	leave  
  802175:	c3                   	ret    
  802176:	66 90                	xchg   %ax,%ax

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  802178:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80217b:	89 f9                	mov    %edi,%ecx
  80217d:	d3 e2                	shl    %cl,%edx

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  80217f:	39 c2                	cmp    %eax,%edx
  802181:	73 db                	jae    80215e <__udivdi3+0xea>
  802183:	90                   	nop
		{
		  q0--;
  802184:	8d 7e ff             	lea    -0x1(%esi),%edi
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  802187:	31 f6                	xor    %esi,%esi
  802189:	e9 56 ff ff ff       	jmp    8020e4 <__udivdi3+0x70>
	...

00802190 <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  802190:	55                   	push   %ebp
  802191:	89 e5                	mov    %esp,%ebp
  802193:	57                   	push   %edi
  802194:	56                   	push   %esi
  802195:	83 ec 20             	sub    $0x20,%esp
  802198:	8b 45 08             	mov    0x8(%ebp),%eax
  80219b:	8b 4d 10             	mov    0x10(%ebp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  80219e:	89 45 e8             	mov    %eax,-0x18(%ebp)
  8021a1:	8b 75 0c             	mov    0xc(%ebp),%esi
  const DWunion dd = {.ll = d};
  8021a4:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  8021a7:	8b 7d 14             	mov    0x14(%ebp),%edi
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  8021aa:	89 45 f0             	mov    %eax,-0x10(%ebp)
  n1 = nn.s.high;
  8021ad:	89 f2                	mov    %esi,%edx

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  8021af:	85 ff                	test   %edi,%edi
  8021b1:	75 15                	jne    8021c8 <__umoddi3+0x38>
    {
      if (d0 > n1)
  8021b3:	39 f1                	cmp    %esi,%ecx
  8021b5:	0f 86 99 00 00 00    	jbe    802254 <__umoddi3+0xc4>
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  8021bb:	f7 f1                	div    %ecx

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
  8021bd:	89 d0                	mov    %edx,%eax
  8021bf:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  8021c1:	83 c4 20             	add    $0x20,%esp
  8021c4:	5e                   	pop    %esi
  8021c5:	5f                   	pop    %edi
  8021c6:	c9                   	leave  
  8021c7:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  8021c8:	39 f7                	cmp    %esi,%edi
  8021ca:	0f 87 a4 00 00 00    	ja     802274 <__umoddi3+0xe4>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  8021d0:	0f bd c7             	bsr    %edi,%eax
	  if (bm == 0)
  8021d3:	83 f0 1f             	xor    $0x1f,%eax
  8021d6:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8021d9:	0f 84 a1 00 00 00    	je     802280 <__umoddi3+0xf0>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  8021df:	89 f8                	mov    %edi,%eax
  8021e1:	8a 4d ec             	mov    -0x14(%ebp),%cl
  8021e4:	d3 e0                	shl    %cl,%eax
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  8021e6:	bf 20 00 00 00       	mov    $0x20,%edi
  8021eb:	2b 7d ec             	sub    -0x14(%ebp),%edi

	      d1 = (d1 << bm) | (d0 >> b);
  8021ee:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8021f1:	89 f9                	mov    %edi,%ecx
  8021f3:	d3 ea                	shr    %cl,%edx
  8021f5:	09 c2                	or     %eax,%edx
  8021f7:	89 55 f0             	mov    %edx,-0x10(%ebp)
	      d0 = d0 << bm;
  8021fa:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8021fd:	8a 4d ec             	mov    -0x14(%ebp),%cl
  802200:	d3 e0                	shl    %cl,%eax
  802202:	89 45 f4             	mov    %eax,-0xc(%ebp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  802205:	89 f2                	mov    %esi,%edx
  802207:	d3 e2                	shl    %cl,%edx
	      n0 = n0 << bm;
  802209:	8b 45 e8             	mov    -0x18(%ebp),%eax
  80220c:	d3 e0                	shl    %cl,%eax
  80220e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  802211:	8b 45 e8             	mov    -0x18(%ebp),%eax
  802214:	89 f9                	mov    %edi,%ecx
  802216:	d3 e8                	shr    %cl,%eax
  802218:	09 d0                	or     %edx,%eax

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  80221a:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  80221c:	89 f2                	mov    %esi,%edx
  80221e:	f7 75 f0             	divl   -0x10(%ebp)
  802221:	89 d6                	mov    %edx,%esi
	      umul_ppmm (m1, m0, q0, d0);
  802223:	f7 65 f4             	mull   -0xc(%ebp)
  802226:	89 55 e8             	mov    %edx,-0x18(%ebp)
  802229:	89 c1                	mov    %eax,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  80222b:	39 d6                	cmp    %edx,%esi
  80222d:	72 71                	jb     8022a0 <__umoddi3+0x110>
  80222f:	74 7f                	je     8022b0 <__umoddi3+0x120>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  802231:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802234:	29 c8                	sub    %ecx,%eax
  802236:	19 d6                	sbb    %edx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
  802238:	8a 4d ec             	mov    -0x14(%ebp),%cl
  80223b:	d3 e8                	shr    %cl,%eax
  80223d:	89 f2                	mov    %esi,%edx
  80223f:	89 f9                	mov    %edi,%ecx
  802241:	d3 e2                	shl    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
  802243:	09 d0                	or     %edx,%eax
  802245:	89 f2                	mov    %esi,%edx
  802247:	8a 4d ec             	mov    -0x14(%ebp),%cl
  80224a:	d3 ea                	shr    %cl,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  80224c:	83 c4 20             	add    $0x20,%esp
  80224f:	5e                   	pop    %esi
  802250:	5f                   	pop    %edi
  802251:	c9                   	leave  
  802252:	c3                   	ret    
  802253:	90                   	nop
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  802254:	85 c9                	test   %ecx,%ecx
  802256:	75 0b                	jne    802263 <__umoddi3+0xd3>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  802258:	b8 01 00 00 00       	mov    $0x1,%eax
  80225d:	31 d2                	xor    %edx,%edx
  80225f:	f7 f1                	div    %ecx
  802261:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  802263:	89 f0                	mov    %esi,%eax
  802265:	31 d2                	xor    %edx,%edx
  802267:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  802269:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80226c:	f7 f1                	div    %ecx
  80226e:	e9 4a ff ff ff       	jmp    8021bd <__umoddi3+0x2d>
  802273:	90                   	nop
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
  802274:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  802276:	83 c4 20             	add    $0x20,%esp
  802279:	5e                   	pop    %esi
  80227a:	5f                   	pop    %edi
  80227b:	c9                   	leave  
  80227c:	c3                   	ret    
  80227d:	8d 76 00             	lea    0x0(%esi),%esi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  802280:	39 f7                	cmp    %esi,%edi
  802282:	72 05                	jb     802289 <__umoddi3+0xf9>
  802284:	3b 4d f0             	cmp    -0x10(%ebp),%ecx
  802287:	77 0c                	ja     802295 <__umoddi3+0x105>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  802289:	89 f2                	mov    %esi,%edx
  80228b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80228e:	29 c8                	sub    %ecx,%eax
  802290:	19 fa                	sbb    %edi,%edx
  802292:	89 45 f0             	mov    %eax,-0x10(%ebp)

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
  802295:	8b 45 f0             	mov    -0x10(%ebp),%eax
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  802298:	83 c4 20             	add    $0x20,%esp
  80229b:	5e                   	pop    %esi
  80229c:	5f                   	pop    %edi
  80229d:	c9                   	leave  
  80229e:	c3                   	ret    
  80229f:	90                   	nop
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  8022a0:	8b 55 e8             	mov    -0x18(%ebp),%edx
  8022a3:	89 c1                	mov    %eax,%ecx
  8022a5:	2b 4d f4             	sub    -0xc(%ebp),%ecx
  8022a8:	1b 55 f0             	sbb    -0x10(%ebp),%edx
  8022ab:	eb 84                	jmp    802231 <__umoddi3+0xa1>
  8022ad:	8d 76 00             	lea    0x0(%esi),%esi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  8022b0:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  8022b3:	72 eb                	jb     8022a0 <__umoddi3+0x110>
  8022b5:	89 f2                	mov    %esi,%edx
  8022b7:	e9 75 ff ff ff       	jmp    802231 <__umoddi3+0xa1>
