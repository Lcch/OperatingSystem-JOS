
obj/user/testfile.debug:     file format elf32-i386


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
  80002c:	e8 cf 05 00 00       	call   800600 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800034 <xopen>:

#define FVA ((struct Fd*)0xCCCCC000)

static int
xopen(const char *path, int mode)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	53                   	push   %ebx
  800038:	83 ec 0c             	sub    $0xc,%esp
  80003b:	89 d3                	mov    %edx,%ebx
	extern union Fsipc fsipcbuf;
	envid_t fsenv;
	
	strcpy(fsipcbuf.open.req_path, path);
  80003d:	50                   	push   %eax
  80003e:	68 00 50 80 00       	push   $0x805000
  800043:	e8 b2 0c 00 00       	call   800cfa <strcpy>
	fsipcbuf.open.req_omode = mode;
  800048:	89 1d 00 54 80 00    	mov    %ebx,0x805400

	fsenv = ipc_find_env(ENV_TYPE_FS);
  80004e:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800055:	e8 2c 13 00 00       	call   801386 <ipc_find_env>
	ipc_send(fsenv, FSREQ_OPEN, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  80005a:	6a 07                	push   $0x7
  80005c:	68 00 50 80 00       	push   $0x805000
  800061:	6a 01                	push   $0x1
  800063:	50                   	push   %eax
  800064:	e8 c8 12 00 00       	call   801331 <ipc_send>
	return ipc_recv(NULL, FVA, NULL);
  800069:	83 c4 1c             	add    $0x1c,%esp
  80006c:	6a 00                	push   $0x0
  80006e:	68 00 c0 cc cc       	push   $0xccccc000
  800073:	6a 00                	push   $0x0
  800075:	e8 42 12 00 00       	call   8012bc <ipc_recv>
}
  80007a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80007d:	c9                   	leave  
  80007e:	c3                   	ret    

0080007f <umain>:

void
umain(int argc, char **argv)
{
  80007f:	55                   	push   %ebp
  800080:	89 e5                	mov    %esp,%ebp
  800082:	57                   	push   %edi
  800083:	56                   	push   %esi
  800084:	53                   	push   %ebx
  800085:	81 ec bc 02 00 00    	sub    $0x2bc,%esp
	struct Fd fdcopy;
	struct Stat st;
	char buf[512];

	// We open files manually first, to avoid the FD layer
	if ((r = xopen("/not-found", O_RDONLY)) < 0 && r != -E_NOT_FOUND)
  80008b:	ba 00 00 00 00       	mov    $0x0,%edx
  800090:	b8 40 23 80 00       	mov    $0x802340,%eax
  800095:	e8 9a ff ff ff       	call   800034 <xopen>
  80009a:	85 c0                	test   %eax,%eax
  80009c:	79 17                	jns    8000b5 <umain+0x36>
  80009e:	83 f8 f5             	cmp    $0xfffffff5,%eax
  8000a1:	74 26                	je     8000c9 <umain+0x4a>
		panic("serve_open /not-found: %e", r);
  8000a3:	50                   	push   %eax
  8000a4:	68 4b 23 80 00       	push   $0x80234b
  8000a9:	6a 20                	push   $0x20
  8000ab:	68 65 23 80 00       	push   $0x802365
  8000b0:	e8 b7 05 00 00       	call   80066c <_panic>
	else if (r >= 0)
		panic("serve_open /not-found succeeded!");
  8000b5:	83 ec 04             	sub    $0x4,%esp
  8000b8:	68 00 25 80 00       	push   $0x802500
  8000bd:	6a 22                	push   $0x22
  8000bf:	68 65 23 80 00       	push   $0x802365
  8000c4:	e8 a3 05 00 00       	call   80066c <_panic>

	if ((r = xopen("/newmotd", O_RDONLY)) < 0)
  8000c9:	ba 00 00 00 00       	mov    $0x0,%edx
  8000ce:	b8 75 23 80 00       	mov    $0x802375,%eax
  8000d3:	e8 5c ff ff ff       	call   800034 <xopen>
  8000d8:	85 c0                	test   %eax,%eax
  8000da:	79 12                	jns    8000ee <umain+0x6f>
		panic("serve_open /newmotd: %e", r);
  8000dc:	50                   	push   %eax
  8000dd:	68 7e 23 80 00       	push   $0x80237e
  8000e2:	6a 25                	push   $0x25
  8000e4:	68 65 23 80 00       	push   $0x802365
  8000e9:	e8 7e 05 00 00       	call   80066c <_panic>
	if (FVA->fd_dev_id != 'f' || FVA->fd_offset != 0 || FVA->fd_omode != O_RDONLY)
  8000ee:	83 3d 00 c0 cc cc 66 	cmpl   $0x66,0xccccc000
  8000f5:	75 12                	jne    800109 <umain+0x8a>
  8000f7:	83 3d 04 c0 cc cc 00 	cmpl   $0x0,0xccccc004
  8000fe:	75 09                	jne    800109 <umain+0x8a>
  800100:	83 3d 08 c0 cc cc 00 	cmpl   $0x0,0xccccc008
  800107:	74 14                	je     80011d <umain+0x9e>
		panic("serve_open did not fill struct Fd correctly\n");
  800109:	83 ec 04             	sub    $0x4,%esp
  80010c:	68 24 25 80 00       	push   $0x802524
  800111:	6a 27                	push   $0x27
  800113:	68 65 23 80 00       	push   $0x802365
  800118:	e8 4f 05 00 00       	call   80066c <_panic>
	cprintf("serve_open is good\n");
  80011d:	83 ec 0c             	sub    $0xc,%esp
  800120:	68 96 23 80 00       	push   $0x802396
  800125:	e8 1a 06 00 00       	call   800744 <cprintf>

	if ((r = devfile.dev_stat(FVA, &st)) < 0)
  80012a:	83 c4 08             	add    $0x8,%esp
  80012d:	8d 85 4c ff ff ff    	lea    -0xb4(%ebp),%eax
  800133:	50                   	push   %eax
  800134:	68 00 c0 cc cc       	push   $0xccccc000
  800139:	ff 15 1c 30 80 00    	call   *0x80301c
  80013f:	83 c4 10             	add    $0x10,%esp
  800142:	85 c0                	test   %eax,%eax
  800144:	79 12                	jns    800158 <umain+0xd9>
		panic("file_stat: %e", r);
  800146:	50                   	push   %eax
  800147:	68 aa 23 80 00       	push   $0x8023aa
  80014c:	6a 2b                	push   $0x2b
  80014e:	68 65 23 80 00       	push   $0x802365
  800153:	e8 14 05 00 00       	call   80066c <_panic>
	if (strlen(msg) != st.st_size)
  800158:	83 ec 0c             	sub    $0xc,%esp
  80015b:	ff 35 00 30 80 00    	pushl  0x803000
  800161:	e8 42 0b 00 00       	call   800ca8 <strlen>
  800166:	83 c4 10             	add    $0x10,%esp
  800169:	3b 45 cc             	cmp    -0x34(%ebp),%eax
  80016c:	74 25                	je     800193 <umain+0x114>
		panic("file_stat returned size %d wanted %d\n", st.st_size, strlen(msg));
  80016e:	83 ec 0c             	sub    $0xc,%esp
  800171:	ff 35 00 30 80 00    	pushl  0x803000
  800177:	e8 2c 0b 00 00       	call   800ca8 <strlen>
  80017c:	89 04 24             	mov    %eax,(%esp)
  80017f:	ff 75 cc             	pushl  -0x34(%ebp)
  800182:	68 54 25 80 00       	push   $0x802554
  800187:	6a 2d                	push   $0x2d
  800189:	68 65 23 80 00       	push   $0x802365
  80018e:	e8 d9 04 00 00       	call   80066c <_panic>
	cprintf("file_stat is good\n");
  800193:	83 ec 0c             	sub    $0xc,%esp
  800196:	68 b8 23 80 00       	push   $0x8023b8
  80019b:	e8 a4 05 00 00       	call   800744 <cprintf>

	memset(buf, 0, sizeof buf);
  8001a0:	83 c4 0c             	add    $0xc,%esp
  8001a3:	68 00 02 00 00       	push   $0x200
  8001a8:	6a 00                	push   $0x0
  8001aa:	8d 9d 4c fd ff ff    	lea    -0x2b4(%ebp),%ebx
  8001b0:	53                   	push   %ebx
  8001b1:	e8 bb 0c 00 00       	call   800e71 <memset>
	if ((r = devfile.dev_read(FVA, buf, sizeof buf)) < 0)
  8001b6:	83 c4 0c             	add    $0xc,%esp
  8001b9:	68 00 02 00 00       	push   $0x200
  8001be:	53                   	push   %ebx
  8001bf:	68 00 c0 cc cc       	push   $0xccccc000
  8001c4:	ff 15 10 30 80 00    	call   *0x803010
  8001ca:	83 c4 10             	add    $0x10,%esp
  8001cd:	85 c0                	test   %eax,%eax
  8001cf:	79 12                	jns    8001e3 <umain+0x164>
		panic("file_read: %e", r);
  8001d1:	50                   	push   %eax
  8001d2:	68 cb 23 80 00       	push   $0x8023cb
  8001d7:	6a 32                	push   $0x32
  8001d9:	68 65 23 80 00       	push   $0x802365
  8001de:	e8 89 04 00 00       	call   80066c <_panic>
	if (strcmp(buf, msg) != 0)
  8001e3:	83 ec 08             	sub    $0x8,%esp
  8001e6:	ff 35 00 30 80 00    	pushl  0x803000
  8001ec:	8d 85 4c fd ff ff    	lea    -0x2b4(%ebp),%eax
  8001f2:	50                   	push   %eax
  8001f3:	e8 bb 0b 00 00       	call   800db3 <strcmp>
  8001f8:	83 c4 10             	add    $0x10,%esp
  8001fb:	85 c0                	test   %eax,%eax
  8001fd:	74 14                	je     800213 <umain+0x194>
		panic("file_read returned wrong data");
  8001ff:	83 ec 04             	sub    $0x4,%esp
  800202:	68 d9 23 80 00       	push   $0x8023d9
  800207:	6a 34                	push   $0x34
  800209:	68 65 23 80 00       	push   $0x802365
  80020e:	e8 59 04 00 00       	call   80066c <_panic>
	cprintf("file_read is good\n");
  800213:	83 ec 0c             	sub    $0xc,%esp
  800216:	68 f7 23 80 00       	push   $0x8023f7
  80021b:	e8 24 05 00 00       	call   800744 <cprintf>

	if ((r = devfile.dev_close(FVA)) < 0)
  800220:	c7 04 24 00 c0 cc cc 	movl   $0xccccc000,(%esp)
  800227:	ff 15 18 30 80 00    	call   *0x803018
  80022d:	83 c4 10             	add    $0x10,%esp
  800230:	85 c0                	test   %eax,%eax
  800232:	79 12                	jns    800246 <umain+0x1c7>
		panic("file_close: %e", r);
  800234:	50                   	push   %eax
  800235:	68 0a 24 80 00       	push   $0x80240a
  80023a:	6a 38                	push   $0x38
  80023c:	68 65 23 80 00       	push   $0x802365
  800241:	e8 26 04 00 00       	call   80066c <_panic>
	cprintf("file_close is good\n");
  800246:	83 ec 0c             	sub    $0xc,%esp
  800249:	68 19 24 80 00       	push   $0x802419
  80024e:	e8 f1 04 00 00       	call   800744 <cprintf>

	// We're about to unmap the FD, but still need a way to get
	// the stale filenum to serve_read, so we make a local copy.
	// The file server won't think it's stale until we unmap the
	// FD page.
	fdcopy = *FVA;
  800253:	be 00 c0 cc cc       	mov    $0xccccc000,%esi
  800258:	8d 7d d8             	lea    -0x28(%ebp),%edi
  80025b:	b9 04 00 00 00       	mov    $0x4,%ecx
  800260:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	sys_page_unmap(0, FVA);
  800262:	83 c4 08             	add    $0x8,%esp
  800265:	68 00 c0 cc cc       	push   $0xccccc000
  80026a:	6a 00                	push   $0x0
  80026c:	e8 55 0f 00 00       	call   8011c6 <sys_page_unmap>

	if ((r = devfile.dev_read(&fdcopy, buf, sizeof buf)) != -E_INVAL)
  800271:	83 c4 0c             	add    $0xc,%esp
  800274:	68 00 02 00 00       	push   $0x200
  800279:	8d 85 4c fd ff ff    	lea    -0x2b4(%ebp),%eax
  80027f:	50                   	push   %eax
  800280:	8d 45 d8             	lea    -0x28(%ebp),%eax
  800283:	50                   	push   %eax
  800284:	ff 15 10 30 80 00    	call   *0x803010
  80028a:	83 c4 10             	add    $0x10,%esp
  80028d:	83 f8 fd             	cmp    $0xfffffffd,%eax
  800290:	74 12                	je     8002a4 <umain+0x225>
		panic("serve_read does not handle stale fileids correctly: %e", r);
  800292:	50                   	push   %eax
  800293:	68 7c 25 80 00       	push   $0x80257c
  800298:	6a 43                	push   $0x43
  80029a:	68 65 23 80 00       	push   $0x802365
  80029f:	e8 c8 03 00 00       	call   80066c <_panic>
	cprintf("stale fileid is good\n");
  8002a4:	83 ec 0c             	sub    $0xc,%esp
  8002a7:	68 2d 24 80 00       	push   $0x80242d
  8002ac:	e8 93 04 00 00       	call   800744 <cprintf>

	// Try writing
	if ((r = xopen("/new-file", O_RDWR|O_CREAT)) < 0)
  8002b1:	ba 02 01 00 00       	mov    $0x102,%edx
  8002b6:	b8 43 24 80 00       	mov    $0x802443,%eax
  8002bb:	e8 74 fd ff ff       	call   800034 <xopen>
  8002c0:	83 c4 10             	add    $0x10,%esp
  8002c3:	85 c0                	test   %eax,%eax
  8002c5:	79 12                	jns    8002d9 <umain+0x25a>
		panic("serve_open /new-file: %e", r);
  8002c7:	50                   	push   %eax
  8002c8:	68 4d 24 80 00       	push   $0x80244d
  8002cd:	6a 48                	push   $0x48
  8002cf:	68 65 23 80 00       	push   $0x802365
  8002d4:	e8 93 03 00 00       	call   80066c <_panic>

	if ((r = devfile.dev_write(FVA, msg, strlen(msg))) != strlen(msg))
  8002d9:	8b 1d 14 30 80 00    	mov    0x803014,%ebx
  8002df:	83 ec 0c             	sub    $0xc,%esp
  8002e2:	ff 35 00 30 80 00    	pushl  0x803000
  8002e8:	e8 bb 09 00 00       	call   800ca8 <strlen>
  8002ed:	83 c4 0c             	add    $0xc,%esp
  8002f0:	50                   	push   %eax
  8002f1:	ff 35 00 30 80 00    	pushl  0x803000
  8002f7:	68 00 c0 cc cc       	push   $0xccccc000
  8002fc:	ff d3                	call   *%ebx
  8002fe:	89 c3                	mov    %eax,%ebx
  800300:	83 c4 04             	add    $0x4,%esp
  800303:	ff 35 00 30 80 00    	pushl  0x803000
  800309:	e8 9a 09 00 00       	call   800ca8 <strlen>
  80030e:	83 c4 10             	add    $0x10,%esp
  800311:	39 c3                	cmp    %eax,%ebx
  800313:	74 12                	je     800327 <umain+0x2a8>
		panic("file_write: %e", r);
  800315:	53                   	push   %ebx
  800316:	68 66 24 80 00       	push   $0x802466
  80031b:	6a 4b                	push   $0x4b
  80031d:	68 65 23 80 00       	push   $0x802365
  800322:	e8 45 03 00 00       	call   80066c <_panic>
	cprintf("file_write is good\n");
  800327:	83 ec 0c             	sub    $0xc,%esp
  80032a:	68 75 24 80 00       	push   $0x802475
  80032f:	e8 10 04 00 00       	call   800744 <cprintf>

	FVA->fd_offset = 0;
  800334:	c7 05 04 c0 cc cc 00 	movl   $0x0,0xccccc004
  80033b:	00 00 00 
	memset(buf, 0, sizeof buf);
  80033e:	83 c4 0c             	add    $0xc,%esp
  800341:	68 00 02 00 00       	push   $0x200
  800346:	6a 00                	push   $0x0
  800348:	8d 9d 4c fd ff ff    	lea    -0x2b4(%ebp),%ebx
  80034e:	53                   	push   %ebx
  80034f:	e8 1d 0b 00 00       	call   800e71 <memset>
	if ((r = devfile.dev_read(FVA, buf, sizeof buf)) < 0)
  800354:	83 c4 0c             	add    $0xc,%esp
  800357:	68 00 02 00 00       	push   $0x200
  80035c:	53                   	push   %ebx
  80035d:	68 00 c0 cc cc       	push   $0xccccc000
  800362:	ff 15 10 30 80 00    	call   *0x803010
  800368:	89 c3                	mov    %eax,%ebx
  80036a:	83 c4 10             	add    $0x10,%esp
  80036d:	85 c0                	test   %eax,%eax
  80036f:	79 12                	jns    800383 <umain+0x304>
		panic("file_read after file_write: %e", r);
  800371:	50                   	push   %eax
  800372:	68 b4 25 80 00       	push   $0x8025b4
  800377:	6a 51                	push   $0x51
  800379:	68 65 23 80 00       	push   $0x802365
  80037e:	e8 e9 02 00 00       	call   80066c <_panic>
	if (r != strlen(msg))
  800383:	83 ec 0c             	sub    $0xc,%esp
  800386:	ff 35 00 30 80 00    	pushl  0x803000
  80038c:	e8 17 09 00 00       	call   800ca8 <strlen>
  800391:	83 c4 10             	add    $0x10,%esp
  800394:	39 d8                	cmp    %ebx,%eax
  800396:	74 12                	je     8003aa <umain+0x32b>
		panic("file_read after file_write returned wrong length: %d", r);
  800398:	53                   	push   %ebx
  800399:	68 d4 25 80 00       	push   $0x8025d4
  80039e:	6a 53                	push   $0x53
  8003a0:	68 65 23 80 00       	push   $0x802365
  8003a5:	e8 c2 02 00 00       	call   80066c <_panic>
	if (strcmp(buf, msg) != 0)
  8003aa:	83 ec 08             	sub    $0x8,%esp
  8003ad:	ff 35 00 30 80 00    	pushl  0x803000
  8003b3:	8d 85 4c fd ff ff    	lea    -0x2b4(%ebp),%eax
  8003b9:	50                   	push   %eax
  8003ba:	e8 f4 09 00 00       	call   800db3 <strcmp>
  8003bf:	83 c4 10             	add    $0x10,%esp
  8003c2:	85 c0                	test   %eax,%eax
  8003c4:	74 14                	je     8003da <umain+0x35b>
		panic("file_read after file_write returned wrong data");
  8003c6:	83 ec 04             	sub    $0x4,%esp
  8003c9:	68 0c 26 80 00       	push   $0x80260c
  8003ce:	6a 55                	push   $0x55
  8003d0:	68 65 23 80 00       	push   $0x802365
  8003d5:	e8 92 02 00 00       	call   80066c <_panic>
	cprintf("file_read after file_write is good\n");
  8003da:	83 ec 0c             	sub    $0xc,%esp
  8003dd:	68 3c 26 80 00       	push   $0x80263c
  8003e2:	e8 5d 03 00 00       	call   800744 <cprintf>

	// Now we'll try out open
	if ((r = open("/not-found", O_RDONLY)) < 0 && r != -E_NOT_FOUND)
  8003e7:	83 c4 08             	add    $0x8,%esp
  8003ea:	6a 00                	push   $0x0
  8003ec:	68 40 23 80 00       	push   $0x802340
  8003f1:	e8 0e 17 00 00       	call   801b04 <open>
  8003f6:	83 c4 10             	add    $0x10,%esp
  8003f9:	85 c0                	test   %eax,%eax
  8003fb:	79 17                	jns    800414 <umain+0x395>
  8003fd:	83 f8 f5             	cmp    $0xfffffff5,%eax
  800400:	74 26                	je     800428 <umain+0x3a9>
		panic("open /not-found: %e", r);
  800402:	50                   	push   %eax
  800403:	68 51 23 80 00       	push   $0x802351
  800408:	6a 5a                	push   $0x5a
  80040a:	68 65 23 80 00       	push   $0x802365
  80040f:	e8 58 02 00 00       	call   80066c <_panic>
	else if (r >= 0)
		panic("open /not-found succeeded!");
  800414:	83 ec 04             	sub    $0x4,%esp
  800417:	68 89 24 80 00       	push   $0x802489
  80041c:	6a 5c                	push   $0x5c
  80041e:	68 65 23 80 00       	push   $0x802365
  800423:	e8 44 02 00 00       	call   80066c <_panic>

	if ((r = open("/newmotd", O_RDONLY)) < 0)
  800428:	83 ec 08             	sub    $0x8,%esp
  80042b:	6a 00                	push   $0x0
  80042d:	68 75 23 80 00       	push   $0x802375
  800432:	e8 cd 16 00 00       	call   801b04 <open>
  800437:	83 c4 10             	add    $0x10,%esp
  80043a:	85 c0                	test   %eax,%eax
  80043c:	79 12                	jns    800450 <umain+0x3d1>
		panic("open /newmotd: %e", r);
  80043e:	50                   	push   %eax
  80043f:	68 84 23 80 00       	push   $0x802384
  800444:	6a 5f                	push   $0x5f
  800446:	68 65 23 80 00       	push   $0x802365
  80044b:	e8 1c 02 00 00       	call   80066c <_panic>
	fd = (struct Fd*) (0xD0000000 + r*PGSIZE);
  800450:	05 00 00 0d 00       	add    $0xd0000,%eax
  800455:	c1 e0 0c             	shl    $0xc,%eax
	if (fd->fd_dev_id != 'f' || fd->fd_offset != 0 || fd->fd_omode != O_RDONLY)
  800458:	83 38 66             	cmpl   $0x66,(%eax)
  80045b:	75 0c                	jne    800469 <umain+0x3ea>
  80045d:	83 78 04 00          	cmpl   $0x0,0x4(%eax)
  800461:	75 06                	jne    800469 <umain+0x3ea>
  800463:	83 78 08 00          	cmpl   $0x0,0x8(%eax)
  800467:	74 14                	je     80047d <umain+0x3fe>
		panic("open did not fill struct Fd correctly\n");
  800469:	83 ec 04             	sub    $0x4,%esp
  80046c:	68 60 26 80 00       	push   $0x802660
  800471:	6a 62                	push   $0x62
  800473:	68 65 23 80 00       	push   $0x802365
  800478:	e8 ef 01 00 00       	call   80066c <_panic>
	cprintf("open is good\n");
  80047d:	83 ec 0c             	sub    $0xc,%esp
  800480:	68 9c 23 80 00       	push   $0x80239c
  800485:	e8 ba 02 00 00       	call   800744 <cprintf>

	// Try files with indirect blocks
	if ((f = open("/big", O_WRONLY|O_CREAT)) < 0)
  80048a:	83 c4 08             	add    $0x8,%esp
  80048d:	68 01 01 00 00       	push   $0x101
  800492:	68 a4 24 80 00       	push   $0x8024a4
  800497:	e8 68 16 00 00       	call   801b04 <open>
  80049c:	89 85 44 fd ff ff    	mov    %eax,-0x2bc(%ebp)
  8004a2:	83 c4 10             	add    $0x10,%esp
  8004a5:	85 c0                	test   %eax,%eax
  8004a7:	79 12                	jns    8004bb <umain+0x43c>
		panic("creat /big: %e", f);
  8004a9:	50                   	push   %eax
  8004aa:	68 a9 24 80 00       	push   $0x8024a9
  8004af:	6a 67                	push   $0x67
  8004b1:	68 65 23 80 00       	push   $0x802365
  8004b6:	e8 b1 01 00 00       	call   80066c <_panic>
	memset(buf, 0, sizeof(buf));
  8004bb:	83 ec 04             	sub    $0x4,%esp
  8004be:	68 00 02 00 00       	push   $0x200
  8004c3:	6a 00                	push   $0x0
  8004c5:	8d 85 4c fd ff ff    	lea    -0x2b4(%ebp),%eax
  8004cb:	50                   	push   %eax
  8004cc:	e8 a0 09 00 00       	call   800e71 <memset>
  8004d1:	83 c4 10             	add    $0x10,%esp
	for (i = 0; i < (NDIRECT*3)*BLKSIZE; i += sizeof(buf)) {
  8004d4:	be 00 00 00 00       	mov    $0x0,%esi
		*(int*)buf = i;
  8004d9:	8d 9d 4c fd ff ff    	lea    -0x2b4(%ebp),%ebx
  8004df:	89 df                	mov    %ebx,%edi
  8004e1:	89 33                	mov    %esi,(%ebx)
		if ((r = write(f, buf, sizeof(buf))) < 0)
  8004e3:	83 ec 04             	sub    $0x4,%esp
  8004e6:	68 00 02 00 00       	push   $0x200
  8004eb:	53                   	push   %ebx
  8004ec:	ff b5 44 fd ff ff    	pushl  -0x2bc(%ebp)
  8004f2:	e8 e5 12 00 00       	call   8017dc <write>
  8004f7:	83 c4 10             	add    $0x10,%esp
  8004fa:	85 c0                	test   %eax,%eax
  8004fc:	79 16                	jns    800514 <umain+0x495>
			panic("write /big@%d: %e", i, r);
  8004fe:	83 ec 0c             	sub    $0xc,%esp
  800501:	50                   	push   %eax
  800502:	56                   	push   %esi
  800503:	68 b8 24 80 00       	push   $0x8024b8
  800508:	6a 6c                	push   $0x6c
  80050a:	68 65 23 80 00       	push   $0x802365
  80050f:	e8 58 01 00 00       	call   80066c <_panic>
	ipc_send(fsenv, FSREQ_OPEN, &fsipcbuf, PTE_P | PTE_W | PTE_U);
	return ipc_recv(NULL, FVA, NULL);
}

void
umain(int argc, char **argv)
  800514:	8d 86 00 02 00 00    	lea    0x200(%esi),%eax
  80051a:	89 c6                	mov    %eax,%esi

	// Try files with indirect blocks
	if ((f = open("/big", O_WRONLY|O_CREAT)) < 0)
		panic("creat /big: %e", f);
	memset(buf, 0, sizeof(buf));
	for (i = 0; i < (NDIRECT*3)*BLKSIZE; i += sizeof(buf)) {
  80051c:	3d 00 e0 01 00       	cmp    $0x1e000,%eax
  800521:	75 bc                	jne    8004df <umain+0x460>
		*(int*)buf = i;
		if ((r = write(f, buf, sizeof(buf))) < 0)
			panic("write /big@%d: %e", i, r);
	}
	close(f);
  800523:	83 ec 0c             	sub    $0xc,%esp
  800526:	ff b5 44 fd ff ff    	pushl  -0x2bc(%ebp)
  80052c:	e8 92 10 00 00       	call   8015c3 <close>

	if ((f = open("/big", O_RDONLY)) < 0)
  800531:	83 c4 08             	add    $0x8,%esp
  800534:	6a 00                	push   $0x0
  800536:	68 a4 24 80 00       	push   $0x8024a4
  80053b:	e8 c4 15 00 00       	call   801b04 <open>
  800540:	89 c6                	mov    %eax,%esi
  800542:	83 c4 10             	add    $0x10,%esp
  800545:	85 c0                	test   %eax,%eax
  800547:	79 12                	jns    80055b <umain+0x4dc>
		panic("open /big: %e", f);
  800549:	50                   	push   %eax
  80054a:	68 ca 24 80 00       	push   $0x8024ca
  80054f:	6a 71                	push   $0x71
  800551:	68 65 23 80 00       	push   $0x802365
  800556:	e8 11 01 00 00       	call   80066c <_panic>
		if ((r = write(f, buf, sizeof(buf))) < 0)
			panic("write /big@%d: %e", i, r);
	}
	close(f);

	if ((f = open("/big", O_RDONLY)) < 0)
  80055b:	bb 00 00 00 00       	mov    $0x0,%ebx
		panic("open /big: %e", f);
	for (i = 0; i < (NDIRECT*3)*BLKSIZE; i += sizeof(buf)) {
		*(int*)buf = i;
  800560:	89 1f                	mov    %ebx,(%edi)
		if ((r = readn(f, buf, sizeof(buf))) < 0)
  800562:	83 ec 04             	sub    $0x4,%esp
  800565:	68 00 02 00 00       	push   $0x200
  80056a:	8d 85 4c fd ff ff    	lea    -0x2b4(%ebp),%eax
  800570:	50                   	push   %eax
  800571:	56                   	push   %esi
  800572:	e8 10 12 00 00       	call   801787 <readn>
  800577:	83 c4 10             	add    $0x10,%esp
  80057a:	85 c0                	test   %eax,%eax
  80057c:	79 16                	jns    800594 <umain+0x515>
			panic("read /big@%d: %e", i, r);
  80057e:	83 ec 0c             	sub    $0xc,%esp
  800581:	50                   	push   %eax
  800582:	53                   	push   %ebx
  800583:	68 d8 24 80 00       	push   $0x8024d8
  800588:	6a 75                	push   $0x75
  80058a:	68 65 23 80 00       	push   $0x802365
  80058f:	e8 d8 00 00 00       	call   80066c <_panic>
		if (r != sizeof(buf))
  800594:	3d 00 02 00 00       	cmp    $0x200,%eax
  800599:	74 1b                	je     8005b6 <umain+0x537>
			panic("read /big from %d returned %d < %d bytes",
  80059b:	83 ec 08             	sub    $0x8,%esp
  80059e:	68 00 02 00 00       	push   $0x200
  8005a3:	50                   	push   %eax
  8005a4:	53                   	push   %ebx
  8005a5:	68 88 26 80 00       	push   $0x802688
  8005aa:	6a 78                	push   $0x78
  8005ac:	68 65 23 80 00       	push   $0x802365
  8005b1:	e8 b6 00 00 00       	call   80066c <_panic>
			      i, r, sizeof(buf));
		if (*(int*)buf != i)
  8005b6:	8b 07                	mov    (%edi),%eax
  8005b8:	39 d8                	cmp    %ebx,%eax
  8005ba:	74 16                	je     8005d2 <umain+0x553>
			panic("read /big from %d returned bad data %d",
  8005bc:	83 ec 0c             	sub    $0xc,%esp
  8005bf:	50                   	push   %eax
  8005c0:	53                   	push   %ebx
  8005c1:	68 b4 26 80 00       	push   $0x8026b4
  8005c6:	6a 7b                	push   $0x7b
  8005c8:	68 65 23 80 00       	push   $0x802365
  8005cd:	e8 9a 00 00 00       	call   80066c <_panic>
	}
	close(f);

	if ((f = open("/big", O_RDONLY)) < 0)
		panic("open /big: %e", f);
	for (i = 0; i < (NDIRECT*3)*BLKSIZE; i += sizeof(buf)) {
  8005d2:	8d 98 00 02 00 00    	lea    0x200(%eax),%ebx
  8005d8:	81 fb ff df 01 00    	cmp    $0x1dfff,%ebx
  8005de:	7e 80                	jle    800560 <umain+0x4e1>
			      i, r, sizeof(buf));
		if (*(int*)buf != i)
			panic("read /big from %d returned bad data %d",
			      i, *(int*)buf);
	}
	close(f);
  8005e0:	83 ec 0c             	sub    $0xc,%esp
  8005e3:	56                   	push   %esi
  8005e4:	e8 da 0f 00 00       	call   8015c3 <close>
	cprintf("large file is good\n");
  8005e9:	c7 04 24 e9 24 80 00 	movl   $0x8024e9,(%esp)
  8005f0:	e8 4f 01 00 00       	call   800744 <cprintf>
  8005f5:	83 c4 10             	add    $0x10,%esp
}
  8005f8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8005fb:	5b                   	pop    %ebx
  8005fc:	5e                   	pop    %esi
  8005fd:	5f                   	pop    %edi
  8005fe:	c9                   	leave  
  8005ff:	c3                   	ret    

00800600 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800600:	55                   	push   %ebp
  800601:	89 e5                	mov    %esp,%ebp
  800603:	56                   	push   %esi
  800604:	53                   	push   %ebx
  800605:	8b 75 08             	mov    0x8(%ebp),%esi
  800608:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = envs + ENVX(sys_getenvid());
  80060b:	e8 21 0b 00 00       	call   801131 <sys_getenvid>
  800610:	25 ff 03 00 00       	and    $0x3ff,%eax
  800615:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  80061c:	c1 e0 07             	shl    $0x7,%eax
  80061f:	29 d0                	sub    %edx,%eax
  800621:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800626:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80062b:	85 f6                	test   %esi,%esi
  80062d:	7e 07                	jle    800636 <libmain+0x36>
		binaryname = argv[0];
  80062f:	8b 03                	mov    (%ebx),%eax
  800631:	a3 04 30 80 00       	mov    %eax,0x803004
	// call user main routine
	umain(argc, argv);
  800636:	83 ec 08             	sub    $0x8,%esp
  800639:	53                   	push   %ebx
  80063a:	56                   	push   %esi
  80063b:	e8 3f fa ff ff       	call   80007f <umain>

	// exit gracefully
	exit();
  800640:	e8 0b 00 00 00       	call   800650 <exit>
  800645:	83 c4 10             	add    $0x10,%esp
}
  800648:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80064b:	5b                   	pop    %ebx
  80064c:	5e                   	pop    %esi
  80064d:	c9                   	leave  
  80064e:	c3                   	ret    
	...

00800650 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800650:	55                   	push   %ebp
  800651:	89 e5                	mov    %esp,%ebp
  800653:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800656:	e8 93 0f 00 00       	call   8015ee <close_all>
	sys_env_destroy(0);
  80065b:	83 ec 0c             	sub    $0xc,%esp
  80065e:	6a 00                	push   $0x0
  800660:	e8 aa 0a 00 00       	call   80110f <sys_env_destroy>
  800665:	83 c4 10             	add    $0x10,%esp
}
  800668:	c9                   	leave  
  800669:	c3                   	ret    
	...

0080066c <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80066c:	55                   	push   %ebp
  80066d:	89 e5                	mov    %esp,%ebp
  80066f:	56                   	push   %esi
  800670:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800671:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800674:	8b 1d 04 30 80 00    	mov    0x803004,%ebx
  80067a:	e8 b2 0a 00 00       	call   801131 <sys_getenvid>
  80067f:	83 ec 0c             	sub    $0xc,%esp
  800682:	ff 75 0c             	pushl  0xc(%ebp)
  800685:	ff 75 08             	pushl  0x8(%ebp)
  800688:	53                   	push   %ebx
  800689:	50                   	push   %eax
  80068a:	68 0c 27 80 00       	push   $0x80270c
  80068f:	e8 b0 00 00 00       	call   800744 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800694:	83 c4 18             	add    $0x18,%esp
  800697:	56                   	push   %esi
  800698:	ff 75 10             	pushl  0x10(%ebp)
  80069b:	e8 53 00 00 00       	call   8006f3 <vcprintf>
	cprintf("\n");
  8006a0:	c7 04 24 63 2b 80 00 	movl   $0x802b63,(%esp)
  8006a7:	e8 98 00 00 00       	call   800744 <cprintf>
  8006ac:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8006af:	cc                   	int3   
  8006b0:	eb fd                	jmp    8006af <_panic+0x43>
	...

008006b4 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8006b4:	55                   	push   %ebp
  8006b5:	89 e5                	mov    %esp,%ebp
  8006b7:	53                   	push   %ebx
  8006b8:	83 ec 04             	sub    $0x4,%esp
  8006bb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8006be:	8b 03                	mov    (%ebx),%eax
  8006c0:	8b 55 08             	mov    0x8(%ebp),%edx
  8006c3:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  8006c7:	40                   	inc    %eax
  8006c8:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  8006ca:	3d ff 00 00 00       	cmp    $0xff,%eax
  8006cf:	75 1a                	jne    8006eb <putch+0x37>
		sys_cputs(b->buf, b->idx);
  8006d1:	83 ec 08             	sub    $0x8,%esp
  8006d4:	68 ff 00 00 00       	push   $0xff
  8006d9:	8d 43 08             	lea    0x8(%ebx),%eax
  8006dc:	50                   	push   %eax
  8006dd:	e8 e3 09 00 00       	call   8010c5 <sys_cputs>
		b->idx = 0;
  8006e2:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8006e8:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8006eb:	ff 43 04             	incl   0x4(%ebx)
}
  8006ee:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8006f1:	c9                   	leave  
  8006f2:	c3                   	ret    

008006f3 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8006f3:	55                   	push   %ebp
  8006f4:	89 e5                	mov    %esp,%ebp
  8006f6:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8006fc:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800703:	00 00 00 
	b.cnt = 0;
  800706:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80070d:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800710:	ff 75 0c             	pushl  0xc(%ebp)
  800713:	ff 75 08             	pushl  0x8(%ebp)
  800716:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80071c:	50                   	push   %eax
  80071d:	68 b4 06 80 00       	push   $0x8006b4
  800722:	e8 82 01 00 00       	call   8008a9 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800727:	83 c4 08             	add    $0x8,%esp
  80072a:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800730:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800736:	50                   	push   %eax
  800737:	e8 89 09 00 00       	call   8010c5 <sys_cputs>

	return b.cnt;
}
  80073c:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800742:	c9                   	leave  
  800743:	c3                   	ret    

00800744 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800744:	55                   	push   %ebp
  800745:	89 e5                	mov    %esp,%ebp
  800747:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80074a:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80074d:	50                   	push   %eax
  80074e:	ff 75 08             	pushl  0x8(%ebp)
  800751:	e8 9d ff ff ff       	call   8006f3 <vcprintf>
	va_end(ap);

	return cnt;
}
  800756:	c9                   	leave  
  800757:	c3                   	ret    

00800758 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800758:	55                   	push   %ebp
  800759:	89 e5                	mov    %esp,%ebp
  80075b:	57                   	push   %edi
  80075c:	56                   	push   %esi
  80075d:	53                   	push   %ebx
  80075e:	83 ec 2c             	sub    $0x2c,%esp
  800761:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800764:	89 d6                	mov    %edx,%esi
  800766:	8b 45 08             	mov    0x8(%ebp),%eax
  800769:	8b 55 0c             	mov    0xc(%ebp),%edx
  80076c:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80076f:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800772:	8b 45 10             	mov    0x10(%ebp),%eax
  800775:	8b 5d 14             	mov    0x14(%ebp),%ebx
  800778:	8b 7d 18             	mov    0x18(%ebp),%edi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80077b:	89 45 d0             	mov    %eax,-0x30(%ebp)
  80077e:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  800785:	39 55 d4             	cmp    %edx,-0x2c(%ebp)
  800788:	72 0c                	jb     800796 <printnum+0x3e>
  80078a:	3b 45 d8             	cmp    -0x28(%ebp),%eax
  80078d:	76 07                	jbe    800796 <printnum+0x3e>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80078f:	4b                   	dec    %ebx
  800790:	85 db                	test   %ebx,%ebx
  800792:	7f 31                	jg     8007c5 <printnum+0x6d>
  800794:	eb 3f                	jmp    8007d5 <printnum+0x7d>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800796:	83 ec 0c             	sub    $0xc,%esp
  800799:	57                   	push   %edi
  80079a:	4b                   	dec    %ebx
  80079b:	53                   	push   %ebx
  80079c:	50                   	push   %eax
  80079d:	83 ec 08             	sub    $0x8,%esp
  8007a0:	ff 75 d4             	pushl  -0x2c(%ebp)
  8007a3:	ff 75 d0             	pushl  -0x30(%ebp)
  8007a6:	ff 75 dc             	pushl  -0x24(%ebp)
  8007a9:	ff 75 d8             	pushl  -0x28(%ebp)
  8007ac:	e8 2b 19 00 00       	call   8020dc <__udivdi3>
  8007b1:	83 c4 18             	add    $0x18,%esp
  8007b4:	52                   	push   %edx
  8007b5:	50                   	push   %eax
  8007b6:	89 f2                	mov    %esi,%edx
  8007b8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8007bb:	e8 98 ff ff ff       	call   800758 <printnum>
  8007c0:	83 c4 20             	add    $0x20,%esp
  8007c3:	eb 10                	jmp    8007d5 <printnum+0x7d>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8007c5:	83 ec 08             	sub    $0x8,%esp
  8007c8:	56                   	push   %esi
  8007c9:	57                   	push   %edi
  8007ca:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8007cd:	4b                   	dec    %ebx
  8007ce:	83 c4 10             	add    $0x10,%esp
  8007d1:	85 db                	test   %ebx,%ebx
  8007d3:	7f f0                	jg     8007c5 <printnum+0x6d>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8007d5:	83 ec 08             	sub    $0x8,%esp
  8007d8:	56                   	push   %esi
  8007d9:	83 ec 04             	sub    $0x4,%esp
  8007dc:	ff 75 d4             	pushl  -0x2c(%ebp)
  8007df:	ff 75 d0             	pushl  -0x30(%ebp)
  8007e2:	ff 75 dc             	pushl  -0x24(%ebp)
  8007e5:	ff 75 d8             	pushl  -0x28(%ebp)
  8007e8:	e8 0b 1a 00 00       	call   8021f8 <__umoddi3>
  8007ed:	83 c4 14             	add    $0x14,%esp
  8007f0:	0f be 80 2f 27 80 00 	movsbl 0x80272f(%eax),%eax
  8007f7:	50                   	push   %eax
  8007f8:	ff 55 e4             	call   *-0x1c(%ebp)
  8007fb:	83 c4 10             	add    $0x10,%esp
}
  8007fe:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800801:	5b                   	pop    %ebx
  800802:	5e                   	pop    %esi
  800803:	5f                   	pop    %edi
  800804:	c9                   	leave  
  800805:	c3                   	ret    

00800806 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800806:	55                   	push   %ebp
  800807:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800809:	83 fa 01             	cmp    $0x1,%edx
  80080c:	7e 0e                	jle    80081c <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80080e:	8b 10                	mov    (%eax),%edx
  800810:	8d 4a 08             	lea    0x8(%edx),%ecx
  800813:	89 08                	mov    %ecx,(%eax)
  800815:	8b 02                	mov    (%edx),%eax
  800817:	8b 52 04             	mov    0x4(%edx),%edx
  80081a:	eb 22                	jmp    80083e <getuint+0x38>
	else if (lflag)
  80081c:	85 d2                	test   %edx,%edx
  80081e:	74 10                	je     800830 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800820:	8b 10                	mov    (%eax),%edx
  800822:	8d 4a 04             	lea    0x4(%edx),%ecx
  800825:	89 08                	mov    %ecx,(%eax)
  800827:	8b 02                	mov    (%edx),%eax
  800829:	ba 00 00 00 00       	mov    $0x0,%edx
  80082e:	eb 0e                	jmp    80083e <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800830:	8b 10                	mov    (%eax),%edx
  800832:	8d 4a 04             	lea    0x4(%edx),%ecx
  800835:	89 08                	mov    %ecx,(%eax)
  800837:	8b 02                	mov    (%edx),%eax
  800839:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80083e:	c9                   	leave  
  80083f:	c3                   	ret    

00800840 <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
  800840:	55                   	push   %ebp
  800841:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800843:	83 fa 01             	cmp    $0x1,%edx
  800846:	7e 0e                	jle    800856 <getint+0x16>
		return va_arg(*ap, long long);
  800848:	8b 10                	mov    (%eax),%edx
  80084a:	8d 4a 08             	lea    0x8(%edx),%ecx
  80084d:	89 08                	mov    %ecx,(%eax)
  80084f:	8b 02                	mov    (%edx),%eax
  800851:	8b 52 04             	mov    0x4(%edx),%edx
  800854:	eb 1a                	jmp    800870 <getint+0x30>
	else if (lflag)
  800856:	85 d2                	test   %edx,%edx
  800858:	74 0c                	je     800866 <getint+0x26>
		return va_arg(*ap, long);
  80085a:	8b 10                	mov    (%eax),%edx
  80085c:	8d 4a 04             	lea    0x4(%edx),%ecx
  80085f:	89 08                	mov    %ecx,(%eax)
  800861:	8b 02                	mov    (%edx),%eax
  800863:	99                   	cltd   
  800864:	eb 0a                	jmp    800870 <getint+0x30>
	else
		return va_arg(*ap, int);
  800866:	8b 10                	mov    (%eax),%edx
  800868:	8d 4a 04             	lea    0x4(%edx),%ecx
  80086b:	89 08                	mov    %ecx,(%eax)
  80086d:	8b 02                	mov    (%edx),%eax
  80086f:	99                   	cltd   
}
  800870:	c9                   	leave  
  800871:	c3                   	ret    

00800872 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800872:	55                   	push   %ebp
  800873:	89 e5                	mov    %esp,%ebp
  800875:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800878:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  80087b:	8b 10                	mov    (%eax),%edx
  80087d:	3b 50 04             	cmp    0x4(%eax),%edx
  800880:	73 08                	jae    80088a <sprintputch+0x18>
		*b->buf++ = ch;
  800882:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800885:	88 0a                	mov    %cl,(%edx)
  800887:	42                   	inc    %edx
  800888:	89 10                	mov    %edx,(%eax)
}
  80088a:	c9                   	leave  
  80088b:	c3                   	ret    

0080088c <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80088c:	55                   	push   %ebp
  80088d:	89 e5                	mov    %esp,%ebp
  80088f:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800892:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800895:	50                   	push   %eax
  800896:	ff 75 10             	pushl  0x10(%ebp)
  800899:	ff 75 0c             	pushl  0xc(%ebp)
  80089c:	ff 75 08             	pushl  0x8(%ebp)
  80089f:	e8 05 00 00 00       	call   8008a9 <vprintfmt>
	va_end(ap);
  8008a4:	83 c4 10             	add    $0x10,%esp
}
  8008a7:	c9                   	leave  
  8008a8:	c3                   	ret    

008008a9 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8008a9:	55                   	push   %ebp
  8008aa:	89 e5                	mov    %esp,%ebp
  8008ac:	57                   	push   %edi
  8008ad:	56                   	push   %esi
  8008ae:	53                   	push   %ebx
  8008af:	83 ec 2c             	sub    $0x2c,%esp
  8008b2:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8008b5:	8b 75 10             	mov    0x10(%ebp),%esi
  8008b8:	eb 13                	jmp    8008cd <vprintfmt+0x24>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8008ba:	85 c0                	test   %eax,%eax
  8008bc:	0f 84 6d 03 00 00    	je     800c2f <vprintfmt+0x386>
				return;
			putch(ch, putdat);
  8008c2:	83 ec 08             	sub    $0x8,%esp
  8008c5:	57                   	push   %edi
  8008c6:	50                   	push   %eax
  8008c7:	ff 55 08             	call   *0x8(%ebp)
  8008ca:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8008cd:	0f b6 06             	movzbl (%esi),%eax
  8008d0:	46                   	inc    %esi
  8008d1:	83 f8 25             	cmp    $0x25,%eax
  8008d4:	75 e4                	jne    8008ba <vprintfmt+0x11>
  8008d6:	c6 45 dc 20          	movb   $0x20,-0x24(%ebp)
  8008da:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  8008e1:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
  8008e8:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  8008ef:	b9 00 00 00 00       	mov    $0x0,%ecx
  8008f4:	eb 28                	jmp    80091e <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8008f6:	89 de                	mov    %ebx,%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  8008f8:	c6 45 dc 2d          	movb   $0x2d,-0x24(%ebp)
  8008fc:	eb 20                	jmp    80091e <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8008fe:	89 de                	mov    %ebx,%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800900:	c6 45 dc 30          	movb   $0x30,-0x24(%ebp)
  800904:	eb 18                	jmp    80091e <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800906:	89 de                	mov    %ebx,%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  800908:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  80090f:	eb 0d                	jmp    80091e <vprintfmt+0x75>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  800911:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  800914:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800917:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80091e:	8a 06                	mov    (%esi),%al
  800920:	0f b6 d0             	movzbl %al,%edx
  800923:	8d 5e 01             	lea    0x1(%esi),%ebx
  800926:	83 e8 23             	sub    $0x23,%eax
  800929:	3c 55                	cmp    $0x55,%al
  80092b:	0f 87 e0 02 00 00    	ja     800c11 <vprintfmt+0x368>
  800931:	0f b6 c0             	movzbl %al,%eax
  800934:	ff 24 85 80 28 80 00 	jmp    *0x802880(,%eax,4)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80093b:	83 ea 30             	sub    $0x30,%edx
  80093e:	89 55 d4             	mov    %edx,-0x2c(%ebp)
				ch = *fmt;
  800941:	0f be 03             	movsbl (%ebx),%eax
				if (ch < '0' || ch > '9')
  800944:	8d 50 d0             	lea    -0x30(%eax),%edx
  800947:	83 fa 09             	cmp    $0x9,%edx
  80094a:	77 44                	ja     800990 <vprintfmt+0xe7>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80094c:	89 de                	mov    %ebx,%esi
  80094e:	8b 55 d4             	mov    -0x2c(%ebp),%edx
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800951:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
  800952:	8d 14 92             	lea    (%edx,%edx,4),%edx
  800955:	8d 54 50 d0          	lea    -0x30(%eax,%edx,2),%edx
				ch = *fmt;
  800959:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  80095c:	8d 58 d0             	lea    -0x30(%eax),%ebx
  80095f:	83 fb 09             	cmp    $0x9,%ebx
  800962:	76 ed                	jbe    800951 <vprintfmt+0xa8>
  800964:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  800967:	eb 29                	jmp    800992 <vprintfmt+0xe9>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800969:	8b 45 14             	mov    0x14(%ebp),%eax
  80096c:	8d 50 04             	lea    0x4(%eax),%edx
  80096f:	89 55 14             	mov    %edx,0x14(%ebp)
  800972:	8b 00                	mov    (%eax),%eax
  800974:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800977:	89 de                	mov    %ebx,%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800979:	eb 17                	jmp    800992 <vprintfmt+0xe9>

		case '.':
			if (width < 0)
  80097b:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80097f:	78 85                	js     800906 <vprintfmt+0x5d>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800981:	89 de                	mov    %ebx,%esi
  800983:	eb 99                	jmp    80091e <vprintfmt+0x75>
  800985:	89 de                	mov    %ebx,%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800987:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
			goto reswitch;
  80098e:	eb 8e                	jmp    80091e <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800990:	89 de                	mov    %ebx,%esi
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  800992:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800996:	79 86                	jns    80091e <vprintfmt+0x75>
  800998:	e9 74 ff ff ff       	jmp    800911 <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80099d:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80099e:	89 de                	mov    %ebx,%esi
  8009a0:	e9 79 ff ff ff       	jmp    80091e <vprintfmt+0x75>
  8009a5:	89 5d d8             	mov    %ebx,-0x28(%ebp)
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8009a8:	8b 45 14             	mov    0x14(%ebp),%eax
  8009ab:	8d 50 04             	lea    0x4(%eax),%edx
  8009ae:	89 55 14             	mov    %edx,0x14(%ebp)
  8009b1:	83 ec 08             	sub    $0x8,%esp
  8009b4:	57                   	push   %edi
  8009b5:	ff 30                	pushl  (%eax)
  8009b7:	ff 55 08             	call   *0x8(%ebp)
			break;
  8009ba:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8009bd:	8b 75 d8             	mov    -0x28(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8009c0:	e9 08 ff ff ff       	jmp    8008cd <vprintfmt+0x24>
  8009c5:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// error message
		case 'e':
			err = va_arg(ap, int);
  8009c8:	8b 45 14             	mov    0x14(%ebp),%eax
  8009cb:	8d 50 04             	lea    0x4(%eax),%edx
  8009ce:	89 55 14             	mov    %edx,0x14(%ebp)
  8009d1:	8b 00                	mov    (%eax),%eax
  8009d3:	85 c0                	test   %eax,%eax
  8009d5:	79 02                	jns    8009d9 <vprintfmt+0x130>
  8009d7:	f7 d8                	neg    %eax
  8009d9:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8009db:	83 f8 0f             	cmp    $0xf,%eax
  8009de:	7f 0b                	jg     8009eb <vprintfmt+0x142>
  8009e0:	8b 04 85 e0 29 80 00 	mov    0x8029e0(,%eax,4),%eax
  8009e7:	85 c0                	test   %eax,%eax
  8009e9:	75 1a                	jne    800a05 <vprintfmt+0x15c>
				printfmt(putch, putdat, "error %d", err);
  8009eb:	52                   	push   %edx
  8009ec:	68 47 27 80 00       	push   $0x802747
  8009f1:	57                   	push   %edi
  8009f2:	ff 75 08             	pushl  0x8(%ebp)
  8009f5:	e8 92 fe ff ff       	call   80088c <printfmt>
  8009fa:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8009fd:	8b 75 d8             	mov    -0x28(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800a00:	e9 c8 fe ff ff       	jmp    8008cd <vprintfmt+0x24>
			else
				printfmt(putch, putdat, "%s", p);
  800a05:	50                   	push   %eax
  800a06:	68 31 2b 80 00       	push   $0x802b31
  800a0b:	57                   	push   %edi
  800a0c:	ff 75 08             	pushl  0x8(%ebp)
  800a0f:	e8 78 fe ff ff       	call   80088c <printfmt>
  800a14:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800a17:	8b 75 d8             	mov    -0x28(%ebp),%esi
  800a1a:	e9 ae fe ff ff       	jmp    8008cd <vprintfmt+0x24>
  800a1f:	89 5d d8             	mov    %ebx,-0x28(%ebp)
  800a22:	89 de                	mov    %ebx,%esi
  800a24:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  800a27:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800a2a:	8b 45 14             	mov    0x14(%ebp),%eax
  800a2d:	8d 50 04             	lea    0x4(%eax),%edx
  800a30:	89 55 14             	mov    %edx,0x14(%ebp)
  800a33:	8b 00                	mov    (%eax),%eax
  800a35:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800a38:	85 c0                	test   %eax,%eax
  800a3a:	75 07                	jne    800a43 <vprintfmt+0x19a>
				p = "(null)";
  800a3c:	c7 45 d0 40 27 80 00 	movl   $0x802740,-0x30(%ebp)
			if (width > 0 && padc != '-')
  800a43:	85 db                	test   %ebx,%ebx
  800a45:	7e 42                	jle    800a89 <vprintfmt+0x1e0>
  800a47:	80 7d dc 2d          	cmpb   $0x2d,-0x24(%ebp)
  800a4b:	74 3c                	je     800a89 <vprintfmt+0x1e0>
				for (width -= strnlen(p, precision); width > 0; width--)
  800a4d:	83 ec 08             	sub    $0x8,%esp
  800a50:	51                   	push   %ecx
  800a51:	ff 75 d0             	pushl  -0x30(%ebp)
  800a54:	e8 6f 02 00 00       	call   800cc8 <strnlen>
  800a59:	29 c3                	sub    %eax,%ebx
  800a5b:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800a5e:	83 c4 10             	add    $0x10,%esp
  800a61:	85 db                	test   %ebx,%ebx
  800a63:	7e 24                	jle    800a89 <vprintfmt+0x1e0>
					putch(padc, putdat);
  800a65:	0f be 5d dc          	movsbl -0x24(%ebp),%ebx
  800a69:	89 75 dc             	mov    %esi,-0x24(%ebp)
  800a6c:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  800a6f:	83 ec 08             	sub    $0x8,%esp
  800a72:	57                   	push   %edi
  800a73:	53                   	push   %ebx
  800a74:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800a77:	4e                   	dec    %esi
  800a78:	83 c4 10             	add    $0x10,%esp
  800a7b:	85 f6                	test   %esi,%esi
  800a7d:	7f f0                	jg     800a6f <vprintfmt+0x1c6>
  800a7f:	8b 75 dc             	mov    -0x24(%ebp),%esi
  800a82:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800a89:	8b 55 d0             	mov    -0x30(%ebp),%edx
  800a8c:	0f be 02             	movsbl (%edx),%eax
  800a8f:	85 c0                	test   %eax,%eax
  800a91:	75 47                	jne    800ada <vprintfmt+0x231>
  800a93:	eb 37                	jmp    800acc <vprintfmt+0x223>
				if (altflag && (ch < ' ' || ch > '~'))
  800a95:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800a99:	74 16                	je     800ab1 <vprintfmt+0x208>
  800a9b:	8d 50 e0             	lea    -0x20(%eax),%edx
  800a9e:	83 fa 5e             	cmp    $0x5e,%edx
  800aa1:	76 0e                	jbe    800ab1 <vprintfmt+0x208>
					putch('?', putdat);
  800aa3:	83 ec 08             	sub    $0x8,%esp
  800aa6:	57                   	push   %edi
  800aa7:	6a 3f                	push   $0x3f
  800aa9:	ff 55 08             	call   *0x8(%ebp)
  800aac:	83 c4 10             	add    $0x10,%esp
  800aaf:	eb 0b                	jmp    800abc <vprintfmt+0x213>
				else
					putch(ch, putdat);
  800ab1:	83 ec 08             	sub    $0x8,%esp
  800ab4:	57                   	push   %edi
  800ab5:	50                   	push   %eax
  800ab6:	ff 55 08             	call   *0x8(%ebp)
  800ab9:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800abc:	ff 4d e4             	decl   -0x1c(%ebp)
  800abf:	0f be 03             	movsbl (%ebx),%eax
  800ac2:	85 c0                	test   %eax,%eax
  800ac4:	74 03                	je     800ac9 <vprintfmt+0x220>
  800ac6:	43                   	inc    %ebx
  800ac7:	eb 1b                	jmp    800ae4 <vprintfmt+0x23b>
  800ac9:	8b 75 dc             	mov    -0x24(%ebp),%esi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800acc:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800ad0:	7f 1e                	jg     800af0 <vprintfmt+0x247>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800ad2:	8b 75 d8             	mov    -0x28(%ebp),%esi
  800ad5:	e9 f3 fd ff ff       	jmp    8008cd <vprintfmt+0x24>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800ada:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  800add:	43                   	inc    %ebx
  800ade:	89 75 dc             	mov    %esi,-0x24(%ebp)
  800ae1:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  800ae4:	85 f6                	test   %esi,%esi
  800ae6:	78 ad                	js     800a95 <vprintfmt+0x1ec>
  800ae8:	4e                   	dec    %esi
  800ae9:	79 aa                	jns    800a95 <vprintfmt+0x1ec>
  800aeb:	8b 75 dc             	mov    -0x24(%ebp),%esi
  800aee:	eb dc                	jmp    800acc <vprintfmt+0x223>
  800af0:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800af3:	83 ec 08             	sub    $0x8,%esp
  800af6:	57                   	push   %edi
  800af7:	6a 20                	push   $0x20
  800af9:	ff 55 08             	call   *0x8(%ebp)
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800afc:	4b                   	dec    %ebx
  800afd:	83 c4 10             	add    $0x10,%esp
  800b00:	85 db                	test   %ebx,%ebx
  800b02:	7f ef                	jg     800af3 <vprintfmt+0x24a>
  800b04:	e9 c4 fd ff ff       	jmp    8008cd <vprintfmt+0x24>
  800b09:	89 5d d8             	mov    %ebx,-0x28(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800b0c:	89 ca                	mov    %ecx,%edx
  800b0e:	8d 45 14             	lea    0x14(%ebp),%eax
  800b11:	e8 2a fd ff ff       	call   800840 <getint>
  800b16:	89 c3                	mov    %eax,%ebx
  800b18:	89 d6                	mov    %edx,%esi
			if ((long long) num < 0) {
  800b1a:	85 d2                	test   %edx,%edx
  800b1c:	78 0a                	js     800b28 <vprintfmt+0x27f>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800b1e:	b8 0a 00 00 00       	mov    $0xa,%eax
  800b23:	e9 b0 00 00 00       	jmp    800bd8 <vprintfmt+0x32f>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  800b28:	83 ec 08             	sub    $0x8,%esp
  800b2b:	57                   	push   %edi
  800b2c:	6a 2d                	push   $0x2d
  800b2e:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  800b31:	f7 db                	neg    %ebx
  800b33:	83 d6 00             	adc    $0x0,%esi
  800b36:	f7 de                	neg    %esi
  800b38:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800b3b:	b8 0a 00 00 00       	mov    $0xa,%eax
  800b40:	e9 93 00 00 00       	jmp    800bd8 <vprintfmt+0x32f>
  800b45:	89 5d d8             	mov    %ebx,-0x28(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800b48:	89 ca                	mov    %ecx,%edx
  800b4a:	8d 45 14             	lea    0x14(%ebp),%eax
  800b4d:	e8 b4 fc ff ff       	call   800806 <getuint>
  800b52:	89 c3                	mov    %eax,%ebx
  800b54:	89 d6                	mov    %edx,%esi
			base = 10;
  800b56:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  800b5b:	eb 7b                	jmp    800bd8 <vprintfmt+0x32f>
  800b5d:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// (unsigned) octal
		case 'o':
            // (MIT 6.828, lab1, Ex.8)  my code : 
            num = getint(&ap, lflag);
  800b60:	89 ca                	mov    %ecx,%edx
  800b62:	8d 45 14             	lea    0x14(%ebp),%eax
  800b65:	e8 d6 fc ff ff       	call   800840 <getint>
  800b6a:	89 c3                	mov    %eax,%ebx
  800b6c:	89 d6                	mov    %edx,%esi
            if ((long long) num < 0) {
  800b6e:	85 d2                	test   %edx,%edx
  800b70:	78 07                	js     800b79 <vprintfmt+0x2d0>
                putch('-', putdat);
                num = -(long long) num;
            }
            base = 8;
  800b72:	b8 08 00 00 00       	mov    $0x8,%eax
  800b77:	eb 5f                	jmp    800bd8 <vprintfmt+0x32f>
		// (unsigned) octal
		case 'o':
            // (MIT 6.828, lab1, Ex.8)  my code : 
            num = getint(&ap, lflag);
            if ((long long) num < 0) {
                putch('-', putdat);
  800b79:	83 ec 08             	sub    $0x8,%esp
  800b7c:	57                   	push   %edi
  800b7d:	6a 2d                	push   $0x2d
  800b7f:	ff 55 08             	call   *0x8(%ebp)
                num = -(long long) num;
  800b82:	f7 db                	neg    %ebx
  800b84:	83 d6 00             	adc    $0x0,%esi
  800b87:	f7 de                	neg    %esi
  800b89:	83 c4 10             	add    $0x10,%esp
            }
            base = 8;
  800b8c:	b8 08 00 00 00       	mov    $0x8,%eax
  800b91:	eb 45                	jmp    800bd8 <vprintfmt+0x32f>
  800b93:	89 5d d8             	mov    %ebx,-0x28(%ebp)
            goto number;

        // pointer
		case 'p':
			putch('0', putdat);
  800b96:	83 ec 08             	sub    $0x8,%esp
  800b99:	57                   	push   %edi
  800b9a:	6a 30                	push   $0x30
  800b9c:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  800b9f:	83 c4 08             	add    $0x8,%esp
  800ba2:	57                   	push   %edi
  800ba3:	6a 78                	push   $0x78
  800ba5:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800ba8:	8b 45 14             	mov    0x14(%ebp),%eax
  800bab:	8d 50 04             	lea    0x4(%eax),%edx
  800bae:	89 55 14             	mov    %edx,0x14(%ebp)

        // pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800bb1:	8b 18                	mov    (%eax),%ebx
  800bb3:	be 00 00 00 00       	mov    $0x0,%esi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800bb8:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800bbb:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  800bc0:	eb 16                	jmp    800bd8 <vprintfmt+0x32f>
  800bc2:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800bc5:	89 ca                	mov    %ecx,%edx
  800bc7:	8d 45 14             	lea    0x14(%ebp),%eax
  800bca:	e8 37 fc ff ff       	call   800806 <getuint>
  800bcf:	89 c3                	mov    %eax,%ebx
  800bd1:	89 d6                	mov    %edx,%esi
			base = 16;
  800bd3:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  800bd8:	83 ec 0c             	sub    $0xc,%esp
  800bdb:	0f be 55 dc          	movsbl -0x24(%ebp),%edx
  800bdf:	52                   	push   %edx
  800be0:	ff 75 e4             	pushl  -0x1c(%ebp)
  800be3:	50                   	push   %eax
  800be4:	56                   	push   %esi
  800be5:	53                   	push   %ebx
  800be6:	89 fa                	mov    %edi,%edx
  800be8:	8b 45 08             	mov    0x8(%ebp),%eax
  800beb:	e8 68 fb ff ff       	call   800758 <printnum>
			break;
  800bf0:	83 c4 20             	add    $0x20,%esp
  800bf3:	8b 75 d8             	mov    -0x28(%ebp),%esi
  800bf6:	e9 d2 fc ff ff       	jmp    8008cd <vprintfmt+0x24>
  800bfb:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800bfe:	83 ec 08             	sub    $0x8,%esp
  800c01:	57                   	push   %edi
  800c02:	52                   	push   %edx
  800c03:	ff 55 08             	call   *0x8(%ebp)
			break;
  800c06:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800c09:	8b 75 d8             	mov    -0x28(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800c0c:	e9 bc fc ff ff       	jmp    8008cd <vprintfmt+0x24>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800c11:	83 ec 08             	sub    $0x8,%esp
  800c14:	57                   	push   %edi
  800c15:	6a 25                	push   $0x25
  800c17:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800c1a:	83 c4 10             	add    $0x10,%esp
  800c1d:	eb 02                	jmp    800c21 <vprintfmt+0x378>
  800c1f:	89 c6                	mov    %eax,%esi
  800c21:	8d 46 ff             	lea    -0x1(%esi),%eax
  800c24:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  800c28:	75 f5                	jne    800c1f <vprintfmt+0x376>
  800c2a:	e9 9e fc ff ff       	jmp    8008cd <vprintfmt+0x24>
				/* do nothing */;
			break;
		}
	}
}
  800c2f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c32:	5b                   	pop    %ebx
  800c33:	5e                   	pop    %esi
  800c34:	5f                   	pop    %edi
  800c35:	c9                   	leave  
  800c36:	c3                   	ret    

00800c37 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800c37:	55                   	push   %ebp
  800c38:	89 e5                	mov    %esp,%ebp
  800c3a:	83 ec 18             	sub    $0x18,%esp
  800c3d:	8b 45 08             	mov    0x8(%ebp),%eax
  800c40:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800c43:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800c46:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800c4a:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800c4d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800c54:	85 c0                	test   %eax,%eax
  800c56:	74 26                	je     800c7e <vsnprintf+0x47>
  800c58:	85 d2                	test   %edx,%edx
  800c5a:	7e 29                	jle    800c85 <vsnprintf+0x4e>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800c5c:	ff 75 14             	pushl  0x14(%ebp)
  800c5f:	ff 75 10             	pushl  0x10(%ebp)
  800c62:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800c65:	50                   	push   %eax
  800c66:	68 72 08 80 00       	push   $0x800872
  800c6b:	e8 39 fc ff ff       	call   8008a9 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800c70:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800c73:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800c76:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800c79:	83 c4 10             	add    $0x10,%esp
  800c7c:	eb 0c                	jmp    800c8a <vsnprintf+0x53>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800c7e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800c83:	eb 05                	jmp    800c8a <vsnprintf+0x53>
  800c85:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800c8a:	c9                   	leave  
  800c8b:	c3                   	ret    

00800c8c <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800c8c:	55                   	push   %ebp
  800c8d:	89 e5                	mov    %esp,%ebp
  800c8f:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800c92:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800c95:	50                   	push   %eax
  800c96:	ff 75 10             	pushl  0x10(%ebp)
  800c99:	ff 75 0c             	pushl  0xc(%ebp)
  800c9c:	ff 75 08             	pushl  0x8(%ebp)
  800c9f:	e8 93 ff ff ff       	call   800c37 <vsnprintf>
	va_end(ap);

	return rc;
}
  800ca4:	c9                   	leave  
  800ca5:	c3                   	ret    
	...

00800ca8 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800ca8:	55                   	push   %ebp
  800ca9:	89 e5                	mov    %esp,%ebp
  800cab:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800cae:	80 3a 00             	cmpb   $0x0,(%edx)
  800cb1:	74 0e                	je     800cc1 <strlen+0x19>
  800cb3:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  800cb8:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800cb9:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800cbd:	75 f9                	jne    800cb8 <strlen+0x10>
  800cbf:	eb 05                	jmp    800cc6 <strlen+0x1e>
  800cc1:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  800cc6:	c9                   	leave  
  800cc7:	c3                   	ret    

00800cc8 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800cc8:	55                   	push   %ebp
  800cc9:	89 e5                	mov    %esp,%ebp
  800ccb:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800cce:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800cd1:	85 d2                	test   %edx,%edx
  800cd3:	74 17                	je     800cec <strnlen+0x24>
  800cd5:	80 39 00             	cmpb   $0x0,(%ecx)
  800cd8:	74 19                	je     800cf3 <strnlen+0x2b>
  800cda:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  800cdf:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800ce0:	39 d0                	cmp    %edx,%eax
  800ce2:	74 14                	je     800cf8 <strnlen+0x30>
  800ce4:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800ce8:	75 f5                	jne    800cdf <strnlen+0x17>
  800cea:	eb 0c                	jmp    800cf8 <strnlen+0x30>
  800cec:	b8 00 00 00 00       	mov    $0x0,%eax
  800cf1:	eb 05                	jmp    800cf8 <strnlen+0x30>
  800cf3:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  800cf8:	c9                   	leave  
  800cf9:	c3                   	ret    

00800cfa <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800cfa:	55                   	push   %ebp
  800cfb:	89 e5                	mov    %esp,%ebp
  800cfd:	53                   	push   %ebx
  800cfe:	8b 45 08             	mov    0x8(%ebp),%eax
  800d01:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800d04:	ba 00 00 00 00       	mov    $0x0,%edx
  800d09:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  800d0c:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800d0f:	42                   	inc    %edx
  800d10:	84 c9                	test   %cl,%cl
  800d12:	75 f5                	jne    800d09 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800d14:	5b                   	pop    %ebx
  800d15:	c9                   	leave  
  800d16:	c3                   	ret    

00800d17 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800d17:	55                   	push   %ebp
  800d18:	89 e5                	mov    %esp,%ebp
  800d1a:	53                   	push   %ebx
  800d1b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800d1e:	53                   	push   %ebx
  800d1f:	e8 84 ff ff ff       	call   800ca8 <strlen>
  800d24:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800d27:	ff 75 0c             	pushl  0xc(%ebp)
  800d2a:	8d 04 03             	lea    (%ebx,%eax,1),%eax
  800d2d:	50                   	push   %eax
  800d2e:	e8 c7 ff ff ff       	call   800cfa <strcpy>
	return dst;
}
  800d33:	89 d8                	mov    %ebx,%eax
  800d35:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800d38:	c9                   	leave  
  800d39:	c3                   	ret    

00800d3a <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800d3a:	55                   	push   %ebp
  800d3b:	89 e5                	mov    %esp,%ebp
  800d3d:	56                   	push   %esi
  800d3e:	53                   	push   %ebx
  800d3f:	8b 45 08             	mov    0x8(%ebp),%eax
  800d42:	8b 55 0c             	mov    0xc(%ebp),%edx
  800d45:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800d48:	85 f6                	test   %esi,%esi
  800d4a:	74 15                	je     800d61 <strncpy+0x27>
  800d4c:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
  800d51:	8a 1a                	mov    (%edx),%bl
  800d53:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800d56:	80 3a 01             	cmpb   $0x1,(%edx)
  800d59:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800d5c:	41                   	inc    %ecx
  800d5d:	39 ce                	cmp    %ecx,%esi
  800d5f:	77 f0                	ja     800d51 <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800d61:	5b                   	pop    %ebx
  800d62:	5e                   	pop    %esi
  800d63:	c9                   	leave  
  800d64:	c3                   	ret    

00800d65 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800d65:	55                   	push   %ebp
  800d66:	89 e5                	mov    %esp,%ebp
  800d68:	57                   	push   %edi
  800d69:	56                   	push   %esi
  800d6a:	53                   	push   %ebx
  800d6b:	8b 7d 08             	mov    0x8(%ebp),%edi
  800d6e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800d71:	8b 75 10             	mov    0x10(%ebp),%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800d74:	85 f6                	test   %esi,%esi
  800d76:	74 32                	je     800daa <strlcpy+0x45>
		while (--size > 0 && *src != '\0')
  800d78:	83 fe 01             	cmp    $0x1,%esi
  800d7b:	74 22                	je     800d9f <strlcpy+0x3a>
  800d7d:	8a 0b                	mov    (%ebx),%cl
  800d7f:	84 c9                	test   %cl,%cl
  800d81:	74 20                	je     800da3 <strlcpy+0x3e>
  800d83:	89 f8                	mov    %edi,%eax
  800d85:	ba 00 00 00 00       	mov    $0x0,%edx
	}
	return ret;
}

size_t
strlcpy(char *dst, const char *src, size_t size)
  800d8a:	83 ee 02             	sub    $0x2,%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800d8d:	88 08                	mov    %cl,(%eax)
  800d8f:	40                   	inc    %eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800d90:	39 f2                	cmp    %esi,%edx
  800d92:	74 11                	je     800da5 <strlcpy+0x40>
  800d94:	8a 4c 13 01          	mov    0x1(%ebx,%edx,1),%cl
  800d98:	42                   	inc    %edx
  800d99:	84 c9                	test   %cl,%cl
  800d9b:	75 f0                	jne    800d8d <strlcpy+0x28>
  800d9d:	eb 06                	jmp    800da5 <strlcpy+0x40>
  800d9f:	89 f8                	mov    %edi,%eax
  800da1:	eb 02                	jmp    800da5 <strlcpy+0x40>
  800da3:	89 f8                	mov    %edi,%eax
			*dst++ = *src++;
		*dst = '\0';
  800da5:	c6 00 00             	movb   $0x0,(%eax)
  800da8:	eb 02                	jmp    800dac <strlcpy+0x47>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800daa:	89 f8                	mov    %edi,%eax
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
		*dst = '\0';
	}
	return dst - dst_in;
  800dac:	29 f8                	sub    %edi,%eax
}
  800dae:	5b                   	pop    %ebx
  800daf:	5e                   	pop    %esi
  800db0:	5f                   	pop    %edi
  800db1:	c9                   	leave  
  800db2:	c3                   	ret    

00800db3 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800db3:	55                   	push   %ebp
  800db4:	89 e5                	mov    %esp,%ebp
  800db6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800db9:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800dbc:	8a 01                	mov    (%ecx),%al
  800dbe:	84 c0                	test   %al,%al
  800dc0:	74 10                	je     800dd2 <strcmp+0x1f>
  800dc2:	3a 02                	cmp    (%edx),%al
  800dc4:	75 0c                	jne    800dd2 <strcmp+0x1f>
		p++, q++;
  800dc6:	41                   	inc    %ecx
  800dc7:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800dc8:	8a 01                	mov    (%ecx),%al
  800dca:	84 c0                	test   %al,%al
  800dcc:	74 04                	je     800dd2 <strcmp+0x1f>
  800dce:	3a 02                	cmp    (%edx),%al
  800dd0:	74 f4                	je     800dc6 <strcmp+0x13>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800dd2:	0f b6 c0             	movzbl %al,%eax
  800dd5:	0f b6 12             	movzbl (%edx),%edx
  800dd8:	29 d0                	sub    %edx,%eax
}
  800dda:	c9                   	leave  
  800ddb:	c3                   	ret    

00800ddc <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800ddc:	55                   	push   %ebp
  800ddd:	89 e5                	mov    %esp,%ebp
  800ddf:	53                   	push   %ebx
  800de0:	8b 55 08             	mov    0x8(%ebp),%edx
  800de3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800de6:	8b 45 10             	mov    0x10(%ebp),%eax
	while (n > 0 && *p && *p == *q)
  800de9:	85 c0                	test   %eax,%eax
  800deb:	74 1b                	je     800e08 <strncmp+0x2c>
  800ded:	8a 1a                	mov    (%edx),%bl
  800def:	84 db                	test   %bl,%bl
  800df1:	74 24                	je     800e17 <strncmp+0x3b>
  800df3:	3a 19                	cmp    (%ecx),%bl
  800df5:	75 20                	jne    800e17 <strncmp+0x3b>
  800df7:	48                   	dec    %eax
  800df8:	74 15                	je     800e0f <strncmp+0x33>
		n--, p++, q++;
  800dfa:	42                   	inc    %edx
  800dfb:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800dfc:	8a 1a                	mov    (%edx),%bl
  800dfe:	84 db                	test   %bl,%bl
  800e00:	74 15                	je     800e17 <strncmp+0x3b>
  800e02:	3a 19                	cmp    (%ecx),%bl
  800e04:	74 f1                	je     800df7 <strncmp+0x1b>
  800e06:	eb 0f                	jmp    800e17 <strncmp+0x3b>
		n--, p++, q++;
	if (n == 0)
		return 0;
  800e08:	b8 00 00 00 00       	mov    $0x0,%eax
  800e0d:	eb 05                	jmp    800e14 <strncmp+0x38>
  800e0f:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800e14:	5b                   	pop    %ebx
  800e15:	c9                   	leave  
  800e16:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800e17:	0f b6 02             	movzbl (%edx),%eax
  800e1a:	0f b6 11             	movzbl (%ecx),%edx
  800e1d:	29 d0                	sub    %edx,%eax
  800e1f:	eb f3                	jmp    800e14 <strncmp+0x38>

00800e21 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800e21:	55                   	push   %ebp
  800e22:	89 e5                	mov    %esp,%ebp
  800e24:	8b 45 08             	mov    0x8(%ebp),%eax
  800e27:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800e2a:	8a 10                	mov    (%eax),%dl
  800e2c:	84 d2                	test   %dl,%dl
  800e2e:	74 18                	je     800e48 <strchr+0x27>
		if (*s == c)
  800e30:	38 ca                	cmp    %cl,%dl
  800e32:	75 06                	jne    800e3a <strchr+0x19>
  800e34:	eb 17                	jmp    800e4d <strchr+0x2c>
  800e36:	38 ca                	cmp    %cl,%dl
  800e38:	74 13                	je     800e4d <strchr+0x2c>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800e3a:	40                   	inc    %eax
  800e3b:	8a 10                	mov    (%eax),%dl
  800e3d:	84 d2                	test   %dl,%dl
  800e3f:	75 f5                	jne    800e36 <strchr+0x15>
		if (*s == c)
			return (char *) s;
	return 0;
  800e41:	b8 00 00 00 00       	mov    $0x0,%eax
  800e46:	eb 05                	jmp    800e4d <strchr+0x2c>
  800e48:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800e4d:	c9                   	leave  
  800e4e:	c3                   	ret    

00800e4f <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800e4f:	55                   	push   %ebp
  800e50:	89 e5                	mov    %esp,%ebp
  800e52:	8b 45 08             	mov    0x8(%ebp),%eax
  800e55:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800e58:	8a 10                	mov    (%eax),%dl
  800e5a:	84 d2                	test   %dl,%dl
  800e5c:	74 11                	je     800e6f <strfind+0x20>
		if (*s == c)
  800e5e:	38 ca                	cmp    %cl,%dl
  800e60:	75 06                	jne    800e68 <strfind+0x19>
  800e62:	eb 0b                	jmp    800e6f <strfind+0x20>
  800e64:	38 ca                	cmp    %cl,%dl
  800e66:	74 07                	je     800e6f <strfind+0x20>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800e68:	40                   	inc    %eax
  800e69:	8a 10                	mov    (%eax),%dl
  800e6b:	84 d2                	test   %dl,%dl
  800e6d:	75 f5                	jne    800e64 <strfind+0x15>
		if (*s == c)
			break;
	return (char *) s;
}
  800e6f:	c9                   	leave  
  800e70:	c3                   	ret    

00800e71 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800e71:	55                   	push   %ebp
  800e72:	89 e5                	mov    %esp,%ebp
  800e74:	57                   	push   %edi
  800e75:	56                   	push   %esi
  800e76:	53                   	push   %ebx
  800e77:	8b 7d 08             	mov    0x8(%ebp),%edi
  800e7a:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e7d:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800e80:	85 c9                	test   %ecx,%ecx
  800e82:	74 30                	je     800eb4 <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800e84:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800e8a:	75 25                	jne    800eb1 <memset+0x40>
  800e8c:	f6 c1 03             	test   $0x3,%cl
  800e8f:	75 20                	jne    800eb1 <memset+0x40>
		c &= 0xFF;
  800e91:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800e94:	89 d3                	mov    %edx,%ebx
  800e96:	c1 e3 08             	shl    $0x8,%ebx
  800e99:	89 d6                	mov    %edx,%esi
  800e9b:	c1 e6 18             	shl    $0x18,%esi
  800e9e:	89 d0                	mov    %edx,%eax
  800ea0:	c1 e0 10             	shl    $0x10,%eax
  800ea3:	09 f0                	or     %esi,%eax
  800ea5:	09 d0                	or     %edx,%eax
  800ea7:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800ea9:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800eac:	fc                   	cld    
  800ead:	f3 ab                	rep stos %eax,%es:(%edi)
  800eaf:	eb 03                	jmp    800eb4 <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800eb1:	fc                   	cld    
  800eb2:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800eb4:	89 f8                	mov    %edi,%eax
  800eb6:	5b                   	pop    %ebx
  800eb7:	5e                   	pop    %esi
  800eb8:	5f                   	pop    %edi
  800eb9:	c9                   	leave  
  800eba:	c3                   	ret    

00800ebb <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800ebb:	55                   	push   %ebp
  800ebc:	89 e5                	mov    %esp,%ebp
  800ebe:	57                   	push   %edi
  800ebf:	56                   	push   %esi
  800ec0:	8b 45 08             	mov    0x8(%ebp),%eax
  800ec3:	8b 75 0c             	mov    0xc(%ebp),%esi
  800ec6:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800ec9:	39 c6                	cmp    %eax,%esi
  800ecb:	73 34                	jae    800f01 <memmove+0x46>
  800ecd:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800ed0:	39 d0                	cmp    %edx,%eax
  800ed2:	73 2d                	jae    800f01 <memmove+0x46>
		s += n;
		d += n;
  800ed4:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800ed7:	f6 c2 03             	test   $0x3,%dl
  800eda:	75 1b                	jne    800ef7 <memmove+0x3c>
  800edc:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800ee2:	75 13                	jne    800ef7 <memmove+0x3c>
  800ee4:	f6 c1 03             	test   $0x3,%cl
  800ee7:	75 0e                	jne    800ef7 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800ee9:	83 ef 04             	sub    $0x4,%edi
  800eec:	8d 72 fc             	lea    -0x4(%edx),%esi
  800eef:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800ef2:	fd                   	std    
  800ef3:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800ef5:	eb 07                	jmp    800efe <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800ef7:	4f                   	dec    %edi
  800ef8:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800efb:	fd                   	std    
  800efc:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800efe:	fc                   	cld    
  800eff:	eb 20                	jmp    800f21 <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800f01:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800f07:	75 13                	jne    800f1c <memmove+0x61>
  800f09:	a8 03                	test   $0x3,%al
  800f0b:	75 0f                	jne    800f1c <memmove+0x61>
  800f0d:	f6 c1 03             	test   $0x3,%cl
  800f10:	75 0a                	jne    800f1c <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800f12:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800f15:	89 c7                	mov    %eax,%edi
  800f17:	fc                   	cld    
  800f18:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800f1a:	eb 05                	jmp    800f21 <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800f1c:	89 c7                	mov    %eax,%edi
  800f1e:	fc                   	cld    
  800f1f:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800f21:	5e                   	pop    %esi
  800f22:	5f                   	pop    %edi
  800f23:	c9                   	leave  
  800f24:	c3                   	ret    

00800f25 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800f25:	55                   	push   %ebp
  800f26:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800f28:	ff 75 10             	pushl  0x10(%ebp)
  800f2b:	ff 75 0c             	pushl  0xc(%ebp)
  800f2e:	ff 75 08             	pushl  0x8(%ebp)
  800f31:	e8 85 ff ff ff       	call   800ebb <memmove>
}
  800f36:	c9                   	leave  
  800f37:	c3                   	ret    

00800f38 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800f38:	55                   	push   %ebp
  800f39:	89 e5                	mov    %esp,%ebp
  800f3b:	57                   	push   %edi
  800f3c:	56                   	push   %esi
  800f3d:	53                   	push   %ebx
  800f3e:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800f41:	8b 75 0c             	mov    0xc(%ebp),%esi
  800f44:	8b 7d 10             	mov    0x10(%ebp),%edi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800f47:	85 ff                	test   %edi,%edi
  800f49:	74 32                	je     800f7d <memcmp+0x45>
		if (*s1 != *s2)
  800f4b:	8a 03                	mov    (%ebx),%al
  800f4d:	8a 0e                	mov    (%esi),%cl
  800f4f:	38 c8                	cmp    %cl,%al
  800f51:	74 19                	je     800f6c <memcmp+0x34>
  800f53:	eb 0d                	jmp    800f62 <memcmp+0x2a>
  800f55:	8a 44 13 01          	mov    0x1(%ebx,%edx,1),%al
  800f59:	8a 4c 16 01          	mov    0x1(%esi,%edx,1),%cl
  800f5d:	42                   	inc    %edx
  800f5e:	38 c8                	cmp    %cl,%al
  800f60:	74 10                	je     800f72 <memcmp+0x3a>
			return (int) *s1 - (int) *s2;
  800f62:	0f b6 c0             	movzbl %al,%eax
  800f65:	0f b6 c9             	movzbl %cl,%ecx
  800f68:	29 c8                	sub    %ecx,%eax
  800f6a:	eb 16                	jmp    800f82 <memcmp+0x4a>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800f6c:	4f                   	dec    %edi
  800f6d:	ba 00 00 00 00       	mov    $0x0,%edx
  800f72:	39 fa                	cmp    %edi,%edx
  800f74:	75 df                	jne    800f55 <memcmp+0x1d>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800f76:	b8 00 00 00 00       	mov    $0x0,%eax
  800f7b:	eb 05                	jmp    800f82 <memcmp+0x4a>
  800f7d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800f82:	5b                   	pop    %ebx
  800f83:	5e                   	pop    %esi
  800f84:	5f                   	pop    %edi
  800f85:	c9                   	leave  
  800f86:	c3                   	ret    

00800f87 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800f87:	55                   	push   %ebp
  800f88:	89 e5                	mov    %esp,%ebp
  800f8a:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800f8d:	89 c2                	mov    %eax,%edx
  800f8f:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800f92:	39 d0                	cmp    %edx,%eax
  800f94:	73 12                	jae    800fa8 <memfind+0x21>
		if (*(const unsigned char *) s == (unsigned char) c)
  800f96:	8a 4d 0c             	mov    0xc(%ebp),%cl
  800f99:	38 08                	cmp    %cl,(%eax)
  800f9b:	75 06                	jne    800fa3 <memfind+0x1c>
  800f9d:	eb 09                	jmp    800fa8 <memfind+0x21>
  800f9f:	38 08                	cmp    %cl,(%eax)
  800fa1:	74 05                	je     800fa8 <memfind+0x21>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800fa3:	40                   	inc    %eax
  800fa4:	39 c2                	cmp    %eax,%edx
  800fa6:	77 f7                	ja     800f9f <memfind+0x18>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800fa8:	c9                   	leave  
  800fa9:	c3                   	ret    

00800faa <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800faa:	55                   	push   %ebp
  800fab:	89 e5                	mov    %esp,%ebp
  800fad:	57                   	push   %edi
  800fae:	56                   	push   %esi
  800faf:	53                   	push   %ebx
  800fb0:	8b 55 08             	mov    0x8(%ebp),%edx
  800fb3:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800fb6:	eb 01                	jmp    800fb9 <strtol+0xf>
		s++;
  800fb8:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800fb9:	8a 02                	mov    (%edx),%al
  800fbb:	3c 20                	cmp    $0x20,%al
  800fbd:	74 f9                	je     800fb8 <strtol+0xe>
  800fbf:	3c 09                	cmp    $0x9,%al
  800fc1:	74 f5                	je     800fb8 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800fc3:	3c 2b                	cmp    $0x2b,%al
  800fc5:	75 08                	jne    800fcf <strtol+0x25>
		s++;
  800fc7:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800fc8:	bf 00 00 00 00       	mov    $0x0,%edi
  800fcd:	eb 13                	jmp    800fe2 <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800fcf:	3c 2d                	cmp    $0x2d,%al
  800fd1:	75 0a                	jne    800fdd <strtol+0x33>
		s++, neg = 1;
  800fd3:	8d 52 01             	lea    0x1(%edx),%edx
  800fd6:	bf 01 00 00 00       	mov    $0x1,%edi
  800fdb:	eb 05                	jmp    800fe2 <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800fdd:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800fe2:	85 db                	test   %ebx,%ebx
  800fe4:	74 05                	je     800feb <strtol+0x41>
  800fe6:	83 fb 10             	cmp    $0x10,%ebx
  800fe9:	75 28                	jne    801013 <strtol+0x69>
  800feb:	8a 02                	mov    (%edx),%al
  800fed:	3c 30                	cmp    $0x30,%al
  800fef:	75 10                	jne    801001 <strtol+0x57>
  800ff1:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800ff5:	75 0a                	jne    801001 <strtol+0x57>
		s += 2, base = 16;
  800ff7:	83 c2 02             	add    $0x2,%edx
  800ffa:	bb 10 00 00 00       	mov    $0x10,%ebx
  800fff:	eb 12                	jmp    801013 <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  801001:	85 db                	test   %ebx,%ebx
  801003:	75 0e                	jne    801013 <strtol+0x69>
  801005:	3c 30                	cmp    $0x30,%al
  801007:	75 05                	jne    80100e <strtol+0x64>
		s++, base = 8;
  801009:	42                   	inc    %edx
  80100a:	b3 08                	mov    $0x8,%bl
  80100c:	eb 05                	jmp    801013 <strtol+0x69>
	else if (base == 0)
		base = 10;
  80100e:	bb 0a 00 00 00       	mov    $0xa,%ebx
  801013:	b8 00 00 00 00       	mov    $0x0,%eax
  801018:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  80101a:	8a 0a                	mov    (%edx),%cl
  80101c:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  80101f:	80 fb 09             	cmp    $0x9,%bl
  801022:	77 08                	ja     80102c <strtol+0x82>
			dig = *s - '0';
  801024:	0f be c9             	movsbl %cl,%ecx
  801027:	83 e9 30             	sub    $0x30,%ecx
  80102a:	eb 1e                	jmp    80104a <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  80102c:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  80102f:	80 fb 19             	cmp    $0x19,%bl
  801032:	77 08                	ja     80103c <strtol+0x92>
			dig = *s - 'a' + 10;
  801034:	0f be c9             	movsbl %cl,%ecx
  801037:	83 e9 57             	sub    $0x57,%ecx
  80103a:	eb 0e                	jmp    80104a <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  80103c:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  80103f:	80 fb 19             	cmp    $0x19,%bl
  801042:	77 13                	ja     801057 <strtol+0xad>
			dig = *s - 'A' + 10;
  801044:	0f be c9             	movsbl %cl,%ecx
  801047:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  80104a:	39 f1                	cmp    %esi,%ecx
  80104c:	7d 0d                	jge    80105b <strtol+0xb1>
			break;
		s++, val = (val * base) + dig;
  80104e:	42                   	inc    %edx
  80104f:	0f af c6             	imul   %esi,%eax
  801052:	8d 04 01             	lea    (%ecx,%eax,1),%eax
		// we don't properly detect overflow!
	}
  801055:	eb c3                	jmp    80101a <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  801057:	89 c1                	mov    %eax,%ecx
  801059:	eb 02                	jmp    80105d <strtol+0xb3>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  80105b:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  80105d:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801061:	74 05                	je     801068 <strtol+0xbe>
		*endptr = (char *) s;
  801063:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801066:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  801068:	85 ff                	test   %edi,%edi
  80106a:	74 04                	je     801070 <strtol+0xc6>
  80106c:	89 c8                	mov    %ecx,%eax
  80106e:	f7 d8                	neg    %eax
}
  801070:	5b                   	pop    %ebx
  801071:	5e                   	pop    %esi
  801072:	5f                   	pop    %edi
  801073:	c9                   	leave  
  801074:	c3                   	ret    
  801075:	00 00                	add    %al,(%eax)
	...

00801078 <syscall>:
	return ret;
}

static int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  801078:	55                   	push   %ebp
  801079:	89 e5                	mov    %esp,%ebp
  80107b:	57                   	push   %edi
  80107c:	56                   	push   %esi
  80107d:	53                   	push   %ebx
  80107e:	83 ec 1c             	sub    $0x1c,%esp
  801081:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801084:	89 55 e0             	mov    %edx,-0x20(%ebp)
  801087:	89 ca                	mov    %ecx,%edx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801089:	8b 75 14             	mov    0x14(%ebp),%esi
  80108c:	8b 7d 10             	mov    0x10(%ebp),%edi
  80108f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801092:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801095:	cd 30                	int    $0x30
  801097:	89 c2                	mov    %eax,%edx
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  801099:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80109d:	74 1c                	je     8010bb <syscall+0x43>
  80109f:	85 c0                	test   %eax,%eax
  8010a1:	7e 18                	jle    8010bb <syscall+0x43>
		panic("syscall %d returned %d (> 0)", num, ret);
  8010a3:	83 ec 0c             	sub    $0xc,%esp
  8010a6:	50                   	push   %eax
  8010a7:	ff 75 e4             	pushl  -0x1c(%ebp)
  8010aa:	68 3f 2a 80 00       	push   $0x802a3f
  8010af:	6a 42                	push   $0x42
  8010b1:	68 5c 2a 80 00       	push   $0x802a5c
  8010b6:	e8 b1 f5 ff ff       	call   80066c <_panic>

	return ret;
}
  8010bb:	89 d0                	mov    %edx,%eax
  8010bd:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8010c0:	5b                   	pop    %ebx
  8010c1:	5e                   	pop    %esi
  8010c2:	5f                   	pop    %edi
  8010c3:	c9                   	leave  
  8010c4:	c3                   	ret    

008010c5 <sys_cputs>:

void
sys_cputs(const char *s, size_t len)
{	
  8010c5:	55                   	push   %ebp
  8010c6:	89 e5                	mov    %esp,%ebp
  8010c8:	83 ec 08             	sub    $0x8,%esp
	// my_sysenter(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
	// return;
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
  8010cb:	6a 00                	push   $0x0
  8010cd:	6a 00                	push   $0x0
  8010cf:	6a 00                	push   $0x0
  8010d1:	ff 75 0c             	pushl  0xc(%ebp)
  8010d4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8010d7:	ba 00 00 00 00       	mov    $0x0,%edx
  8010dc:	b8 00 00 00 00       	mov    $0x0,%eax
  8010e1:	e8 92 ff ff ff       	call   801078 <syscall>
  8010e6:	83 c4 10             	add    $0x10,%esp
	return;
}
  8010e9:	c9                   	leave  
  8010ea:	c3                   	ret    

008010eb <sys_cgetc>:

int
sys_cgetc(void)
{
  8010eb:	55                   	push   %ebp
  8010ec:	89 e5                	mov    %esp,%ebp
  8010ee:	83 ec 08             	sub    $0x8,%esp
	// return my_sysenter(SYS_cgetc, 0, 0, 0, 0, 0, 0);
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
  8010f1:	6a 00                	push   $0x0
  8010f3:	6a 00                	push   $0x0
  8010f5:	6a 00                	push   $0x0
  8010f7:	6a 00                	push   $0x0
  8010f9:	b9 00 00 00 00       	mov    $0x0,%ecx
  8010fe:	ba 00 00 00 00       	mov    $0x0,%edx
  801103:	b8 01 00 00 00       	mov    $0x1,%eax
  801108:	e8 6b ff ff ff       	call   801078 <syscall>
}
  80110d:	c9                   	leave  
  80110e:	c3                   	ret    

0080110f <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  80110f:	55                   	push   %ebp
  801110:	89 e5                	mov    %esp,%ebp
  801112:	83 ec 08             	sub    $0x8,%esp
	// return my_sysenter(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
  801115:	6a 00                	push   $0x0
  801117:	6a 00                	push   $0x0
  801119:	6a 00                	push   $0x0
  80111b:	6a 00                	push   $0x0
  80111d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801120:	ba 01 00 00 00       	mov    $0x1,%edx
  801125:	b8 03 00 00 00       	mov    $0x3,%eax
  80112a:	e8 49 ff ff ff       	call   801078 <syscall>
}
  80112f:	c9                   	leave  
  801130:	c3                   	ret    

00801131 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  801131:	55                   	push   %ebp
  801132:	89 e5                	mov    %esp,%ebp
  801134:	83 ec 08             	sub    $0x8,%esp
	// return my_sysenter(SYS_getenvid, 0, 0, 0, 0, 0, 0);
	return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
  801137:	6a 00                	push   $0x0
  801139:	6a 00                	push   $0x0
  80113b:	6a 00                	push   $0x0
  80113d:	6a 00                	push   $0x0
  80113f:	b9 00 00 00 00       	mov    $0x0,%ecx
  801144:	ba 00 00 00 00       	mov    $0x0,%edx
  801149:	b8 02 00 00 00       	mov    $0x2,%eax
  80114e:	e8 25 ff ff ff       	call   801078 <syscall>
}
  801153:	c9                   	leave  
  801154:	c3                   	ret    

00801155 <sys_yield>:

void
sys_yield(void)
{
  801155:	55                   	push   %ebp
  801156:	89 e5                	mov    %esp,%ebp
  801158:	83 ec 08             	sub    $0x8,%esp
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
  80115b:	6a 00                	push   $0x0
  80115d:	6a 00                	push   $0x0
  80115f:	6a 00                	push   $0x0
  801161:	6a 00                	push   $0x0
  801163:	b9 00 00 00 00       	mov    $0x0,%ecx
  801168:	ba 00 00 00 00       	mov    $0x0,%edx
  80116d:	b8 0b 00 00 00       	mov    $0xb,%eax
  801172:	e8 01 ff ff ff       	call   801078 <syscall>
  801177:	83 c4 10             	add    $0x10,%esp
}
  80117a:	c9                   	leave  
  80117b:	c3                   	ret    

0080117c <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  80117c:	55                   	push   %ebp
  80117d:	89 e5                	mov    %esp,%ebp
  80117f:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
  801182:	6a 00                	push   $0x0
  801184:	6a 00                	push   $0x0
  801186:	ff 75 10             	pushl  0x10(%ebp)
  801189:	ff 75 0c             	pushl  0xc(%ebp)
  80118c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80118f:	ba 01 00 00 00       	mov    $0x1,%edx
  801194:	b8 04 00 00 00       	mov    $0x4,%eax
  801199:	e8 da fe ff ff       	call   801078 <syscall>
}
  80119e:	c9                   	leave  
  80119f:	c3                   	ret    

008011a0 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8011a0:	55                   	push   %ebp
  8011a1:	89 e5                	mov    %esp,%ebp
  8011a3:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
  8011a6:	ff 75 18             	pushl  0x18(%ebp)
  8011a9:	ff 75 14             	pushl  0x14(%ebp)
  8011ac:	ff 75 10             	pushl  0x10(%ebp)
  8011af:	ff 75 0c             	pushl  0xc(%ebp)
  8011b2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8011b5:	ba 01 00 00 00       	mov    $0x1,%edx
  8011ba:	b8 05 00 00 00       	mov    $0x5,%eax
  8011bf:	e8 b4 fe ff ff       	call   801078 <syscall>
}
  8011c4:	c9                   	leave  
  8011c5:	c3                   	ret    

008011c6 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  8011c6:	55                   	push   %ebp
  8011c7:	89 e5                	mov    %esp,%ebp
  8011c9:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
  8011cc:	6a 00                	push   $0x0
  8011ce:	6a 00                	push   $0x0
  8011d0:	6a 00                	push   $0x0
  8011d2:	ff 75 0c             	pushl  0xc(%ebp)
  8011d5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8011d8:	ba 01 00 00 00       	mov    $0x1,%edx
  8011dd:	b8 06 00 00 00       	mov    $0x6,%eax
  8011e2:	e8 91 fe ff ff       	call   801078 <syscall>
}
  8011e7:	c9                   	leave  
  8011e8:	c3                   	ret    

008011e9 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  8011e9:	55                   	push   %ebp
  8011ea:	89 e5                	mov    %esp,%ebp
  8011ec:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
  8011ef:	6a 00                	push   $0x0
  8011f1:	6a 00                	push   $0x0
  8011f3:	6a 00                	push   $0x0
  8011f5:	ff 75 0c             	pushl  0xc(%ebp)
  8011f8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8011fb:	ba 01 00 00 00       	mov    $0x1,%edx
  801200:	b8 08 00 00 00       	mov    $0x8,%eax
  801205:	e8 6e fe ff ff       	call   801078 <syscall>
}
  80120a:	c9                   	leave  
  80120b:	c3                   	ret    

0080120c <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  80120c:	55                   	push   %ebp
  80120d:	89 e5                	mov    %esp,%ebp
  80120f:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
  801212:	6a 00                	push   $0x0
  801214:	6a 00                	push   $0x0
  801216:	6a 00                	push   $0x0
  801218:	ff 75 0c             	pushl  0xc(%ebp)
  80121b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80121e:	ba 01 00 00 00       	mov    $0x1,%edx
  801223:	b8 09 00 00 00       	mov    $0x9,%eax
  801228:	e8 4b fe ff ff       	call   801078 <syscall>
}
  80122d:	c9                   	leave  
  80122e:	c3                   	ret    

0080122f <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  80122f:	55                   	push   %ebp
  801230:	89 e5                	mov    %esp,%ebp
  801232:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
  801235:	6a 00                	push   $0x0
  801237:	6a 00                	push   $0x0
  801239:	6a 00                	push   $0x0
  80123b:	ff 75 0c             	pushl  0xc(%ebp)
  80123e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801241:	ba 01 00 00 00       	mov    $0x1,%edx
  801246:	b8 0a 00 00 00       	mov    $0xa,%eax
  80124b:	e8 28 fe ff ff       	call   801078 <syscall>
}
  801250:	c9                   	leave  
  801251:	c3                   	ret    

00801252 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  801252:	55                   	push   %ebp
  801253:	89 e5                	mov    %esp,%ebp
  801255:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
  801258:	6a 00                	push   $0x0
  80125a:	ff 75 14             	pushl  0x14(%ebp)
  80125d:	ff 75 10             	pushl  0x10(%ebp)
  801260:	ff 75 0c             	pushl  0xc(%ebp)
  801263:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801266:	ba 00 00 00 00       	mov    $0x0,%edx
  80126b:	b8 0c 00 00 00       	mov    $0xc,%eax
  801270:	e8 03 fe ff ff       	call   801078 <syscall>
}
  801275:	c9                   	leave  
  801276:	c3                   	ret    

00801277 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  801277:	55                   	push   %ebp
  801278:	89 e5                	mov    %esp,%ebp
  80127a:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
  80127d:	6a 00                	push   $0x0
  80127f:	6a 00                	push   $0x0
  801281:	6a 00                	push   $0x0
  801283:	6a 00                	push   $0x0
  801285:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801288:	ba 01 00 00 00       	mov    $0x1,%edx
  80128d:	b8 0d 00 00 00       	mov    $0xd,%eax
  801292:	e8 e1 fd ff ff       	call   801078 <syscall>
}
  801297:	c9                   	leave  
  801298:	c3                   	ret    

00801299 <sys_set_priority>:

int
sys_set_priority(envid_t envid, uint32_t new_priority)
{
  801299:	55                   	push   %ebp
  80129a:	89 e5                	mov    %esp,%ebp
  80129c:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_set_priority, 0, envid, new_priority, 0, 0, 0);
  80129f:	6a 00                	push   $0x0
  8012a1:	6a 00                	push   $0x0
  8012a3:	6a 00                	push   $0x0
  8012a5:	ff 75 0c             	pushl  0xc(%ebp)
  8012a8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8012ab:	ba 00 00 00 00       	mov    $0x0,%edx
  8012b0:	b8 0e 00 00 00       	mov    $0xe,%eax
  8012b5:	e8 be fd ff ff       	call   801078 <syscall>
}
  8012ba:	c9                   	leave  
  8012bb:	c3                   	ret    

008012bc <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8012bc:	55                   	push   %ebp
  8012bd:	89 e5                	mov    %esp,%ebp
  8012bf:	56                   	push   %esi
  8012c0:	53                   	push   %ebx
  8012c1:	8b 75 08             	mov    0x8(%ebp),%esi
  8012c4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8012c7:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// cprintf("0x%x 0x%x 0x%x\n", (uint32_t)from_env_store, (uint32_t)pg, (uint32_t)perm_store);
	int r;
	if (pg != NULL) {
  8012ca:	85 c0                	test   %eax,%eax
  8012cc:	74 0e                	je     8012dc <ipc_recv+0x20>
		r = sys_ipc_recv(pg);
  8012ce:	83 ec 0c             	sub    $0xc,%esp
  8012d1:	50                   	push   %eax
  8012d2:	e8 a0 ff ff ff       	call   801277 <sys_ipc_recv>
  8012d7:	83 c4 10             	add    $0x10,%esp
  8012da:	eb 10                	jmp    8012ec <ipc_recv+0x30>
	} else {
		r = sys_ipc_recv((void *)UTOP);
  8012dc:	83 ec 0c             	sub    $0xc,%esp
  8012df:	68 00 00 c0 ee       	push   $0xeec00000
  8012e4:	e8 8e ff ff ff       	call   801277 <sys_ipc_recv>
  8012e9:	83 c4 10             	add    $0x10,%esp
	}

	if (r == 0) {
  8012ec:	85 c0                	test   %eax,%eax
  8012ee:	75 26                	jne    801316 <ipc_recv+0x5a>
		if (from_env_store != NULL) *from_env_store = thisenv->env_ipc_from;
  8012f0:	85 f6                	test   %esi,%esi
  8012f2:	74 0a                	je     8012fe <ipc_recv+0x42>
  8012f4:	a1 04 40 80 00       	mov    0x804004,%eax
  8012f9:	8b 40 74             	mov    0x74(%eax),%eax
  8012fc:	89 06                	mov    %eax,(%esi)
		if (perm_store != NULL) *perm_store = thisenv->env_ipc_perm;
  8012fe:	85 db                	test   %ebx,%ebx
  801300:	74 0a                	je     80130c <ipc_recv+0x50>
  801302:	a1 04 40 80 00       	mov    0x804004,%eax
  801307:	8b 40 78             	mov    0x78(%eax),%eax
  80130a:	89 03                	mov    %eax,(%ebx)
		return thisenv->env_ipc_value;
  80130c:	a1 04 40 80 00       	mov    0x804004,%eax
  801311:	8b 40 70             	mov    0x70(%eax),%eax
  801314:	eb 14                	jmp    80132a <ipc_recv+0x6e>
	} else {
		// fails;
		if (from_env_store != NULL) *from_env_store = 0;
  801316:	85 f6                	test   %esi,%esi
  801318:	74 06                	je     801320 <ipc_recv+0x64>
  80131a:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		if (perm_store != NULL) *perm_store = 0;
  801320:	85 db                	test   %ebx,%ebx
  801322:	74 06                	je     80132a <ipc_recv+0x6e>
  801324:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
		return r;
	}
}
  80132a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80132d:	5b                   	pop    %ebx
  80132e:	5e                   	pop    %esi
  80132f:	c9                   	leave  
  801330:	c3                   	ret    

00801331 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801331:	55                   	push   %ebp
  801332:	89 e5                	mov    %esp,%ebp
  801334:	57                   	push   %edi
  801335:	56                   	push   %esi
  801336:	53                   	push   %ebx
  801337:	83 ec 0c             	sub    $0xc,%esp
  80133a:	8b 7d 0c             	mov    0xc(%ebp),%edi
  80133d:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801340:	8b 75 14             	mov    0x14(%ebp),%esi
	// LAB 4: Your code here.
	// int sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
	int r;
	if (pg == NULL) pg = (void *)UTOP;
  801343:	85 db                	test   %ebx,%ebx
  801345:	75 25                	jne    80136c <ipc_send+0x3b>
  801347:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
  80134c:	eb 1e                	jmp    80136c <ipc_send+0x3b>
	
	while ((r = sys_ipc_try_send(to_env, val, pg, perm)) != 0) {
		if (r == -E_IPC_NOT_RECV) {
  80134e:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801351:	75 07                	jne    80135a <ipc_send+0x29>
			// cprintf("Try Again and Again....\n");
			sys_yield();
  801353:	e8 fd fd ff ff       	call   801155 <sys_yield>
  801358:	eb 12                	jmp    80136c <ipc_send+0x3b>
		} else {
			panic("ipc_send error %e\n", r);
  80135a:	50                   	push   %eax
  80135b:	68 6a 2a 80 00       	push   $0x802a6a
  801360:	6a 43                	push   $0x43
  801362:	68 7d 2a 80 00       	push   $0x802a7d
  801367:	e8 00 f3 ff ff       	call   80066c <_panic>
	// LAB 4: Your code here.
	// int sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
	int r;
	if (pg == NULL) pg = (void *)UTOP;
	
	while ((r = sys_ipc_try_send(to_env, val, pg, perm)) != 0) {
  80136c:	56                   	push   %esi
  80136d:	53                   	push   %ebx
  80136e:	57                   	push   %edi
  80136f:	ff 75 08             	pushl  0x8(%ebp)
  801372:	e8 db fe ff ff       	call   801252 <sys_ipc_try_send>
  801377:	83 c4 10             	add    $0x10,%esp
  80137a:	85 c0                	test   %eax,%eax
  80137c:	75 d0                	jne    80134e <ipc_send+0x1d>
		} else {
			panic("ipc_send error %e\n", r);
		}
	}
	return;
}
  80137e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801381:	5b                   	pop    %ebx
  801382:	5e                   	pop    %esi
  801383:	5f                   	pop    %edi
  801384:	c9                   	leave  
  801385:	c3                   	ret    

00801386 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801386:	55                   	push   %ebp
  801387:	89 e5                	mov    %esp,%ebp
  801389:	53                   	push   %ebx
  80138a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	for (i = 0; i < NENV; i++)
		if (envs[i].env_type == type)
  80138d:	39 1d 50 00 c0 ee    	cmp    %ebx,0xeec00050
  801393:	74 22                	je     8013b7 <ipc_find_env+0x31>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801395:	b8 01 00 00 00       	mov    $0x1,%eax
		if (envs[i].env_type == type)
  80139a:	8d 0c 85 00 00 00 00 	lea    0x0(,%eax,4),%ecx
  8013a1:	89 c2                	mov    %eax,%edx
  8013a3:	c1 e2 07             	shl    $0x7,%edx
  8013a6:	29 ca                	sub    %ecx,%edx
  8013a8:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  8013ae:	8b 52 50             	mov    0x50(%edx),%edx
  8013b1:	39 da                	cmp    %ebx,%edx
  8013b3:	75 1d                	jne    8013d2 <ipc_find_env+0x4c>
  8013b5:	eb 05                	jmp    8013bc <ipc_find_env+0x36>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8013b7:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
			return envs[i].env_id;
  8013bc:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  8013c3:	c1 e0 07             	shl    $0x7,%eax
  8013c6:	29 d0                	sub    %edx,%eax
  8013c8:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  8013cd:	8b 40 40             	mov    0x40(%eax),%eax
  8013d0:	eb 0c                	jmp    8013de <ipc_find_env+0x58>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8013d2:	40                   	inc    %eax
  8013d3:	3d 00 04 00 00       	cmp    $0x400,%eax
  8013d8:	75 c0                	jne    80139a <ipc_find_env+0x14>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  8013da:	66 b8 00 00          	mov    $0x0,%ax
}
  8013de:	5b                   	pop    %ebx
  8013df:	c9                   	leave  
  8013e0:	c3                   	ret    
  8013e1:	00 00                	add    %al,(%eax)
	...

008013e4 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8013e4:	55                   	push   %ebp
  8013e5:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8013e7:	8b 45 08             	mov    0x8(%ebp),%eax
  8013ea:	05 00 00 00 30       	add    $0x30000000,%eax
  8013ef:	c1 e8 0c             	shr    $0xc,%eax
}
  8013f2:	c9                   	leave  
  8013f3:	c3                   	ret    

008013f4 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8013f4:	55                   	push   %ebp
  8013f5:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  8013f7:	ff 75 08             	pushl  0x8(%ebp)
  8013fa:	e8 e5 ff ff ff       	call   8013e4 <fd2num>
  8013ff:	83 c4 04             	add    $0x4,%esp
  801402:	05 20 00 0d 00       	add    $0xd0020,%eax
  801407:	c1 e0 0c             	shl    $0xc,%eax
}
  80140a:	c9                   	leave  
  80140b:	c3                   	ret    

0080140c <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  80140c:	55                   	push   %ebp
  80140d:	89 e5                	mov    %esp,%ebp
  80140f:	53                   	push   %ebx
  801410:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801413:	a1 00 dd 7b ef       	mov    0xef7bdd00,%eax
  801418:	a8 01                	test   $0x1,%al
  80141a:	74 34                	je     801450 <fd_alloc+0x44>
  80141c:	a1 00 00 74 ef       	mov    0xef740000,%eax
  801421:	a8 01                	test   $0x1,%al
  801423:	74 32                	je     801457 <fd_alloc+0x4b>
  801425:	b8 00 10 00 d0       	mov    $0xd0001000,%eax
  80142a:	89 c1                	mov    %eax,%ecx
  80142c:	89 c2                	mov    %eax,%edx
  80142e:	c1 ea 16             	shr    $0x16,%edx
  801431:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801438:	f6 c2 01             	test   $0x1,%dl
  80143b:	74 1f                	je     80145c <fd_alloc+0x50>
  80143d:	89 c2                	mov    %eax,%edx
  80143f:	c1 ea 0c             	shr    $0xc,%edx
  801442:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801449:	f6 c2 01             	test   $0x1,%dl
  80144c:	75 17                	jne    801465 <fd_alloc+0x59>
  80144e:	eb 0c                	jmp    80145c <fd_alloc+0x50>
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  801450:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
  801455:	eb 05                	jmp    80145c <fd_alloc+0x50>
  801457:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
  80145c:	89 0b                	mov    %ecx,(%ebx)
			return 0;
  80145e:	b8 00 00 00 00       	mov    $0x0,%eax
  801463:	eb 17                	jmp    80147c <fd_alloc+0x70>
  801465:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  80146a:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  80146f:	75 b9                	jne    80142a <fd_alloc+0x1e>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801471:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_MAX_OPEN;
  801477:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  80147c:	5b                   	pop    %ebx
  80147d:	c9                   	leave  
  80147e:	c3                   	ret    

0080147f <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  80147f:	55                   	push   %ebp
  801480:	89 e5                	mov    %esp,%ebp
  801482:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801485:	83 f8 1f             	cmp    $0x1f,%eax
  801488:	77 36                	ja     8014c0 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  80148a:	05 00 00 0d 00       	add    $0xd0000,%eax
  80148f:	c1 e0 0c             	shl    $0xc,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801492:	89 c2                	mov    %eax,%edx
  801494:	c1 ea 16             	shr    $0x16,%edx
  801497:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80149e:	f6 c2 01             	test   $0x1,%dl
  8014a1:	74 24                	je     8014c7 <fd_lookup+0x48>
  8014a3:	89 c2                	mov    %eax,%edx
  8014a5:	c1 ea 0c             	shr    $0xc,%edx
  8014a8:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8014af:	f6 c2 01             	test   $0x1,%dl
  8014b2:	74 1a                	je     8014ce <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8014b4:	8b 55 0c             	mov    0xc(%ebp),%edx
  8014b7:	89 02                	mov    %eax,(%edx)
	return 0;
  8014b9:	b8 00 00 00 00       	mov    $0x0,%eax
  8014be:	eb 13                	jmp    8014d3 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8014c0:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8014c5:	eb 0c                	jmp    8014d3 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8014c7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8014cc:	eb 05                	jmp    8014d3 <fd_lookup+0x54>
  8014ce:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  8014d3:	c9                   	leave  
  8014d4:	c3                   	ret    

008014d5 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8014d5:	55                   	push   %ebp
  8014d6:	89 e5                	mov    %esp,%ebp
  8014d8:	53                   	push   %ebx
  8014d9:	83 ec 04             	sub    $0x4,%esp
  8014dc:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8014df:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
		if (devtab[i]->dev_id == dev_id) {
  8014e2:	39 0d 08 30 80 00    	cmp    %ecx,0x803008
  8014e8:	74 0d                	je     8014f7 <dev_lookup+0x22>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8014ea:	b8 00 00 00 00       	mov    $0x0,%eax
  8014ef:	eb 14                	jmp    801505 <dev_lookup+0x30>
		if (devtab[i]->dev_id == dev_id) {
  8014f1:	39 0a                	cmp    %ecx,(%edx)
  8014f3:	75 10                	jne    801505 <dev_lookup+0x30>
  8014f5:	eb 05                	jmp    8014fc <dev_lookup+0x27>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8014f7:	ba 08 30 80 00       	mov    $0x803008,%edx
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
  8014fc:	89 13                	mov    %edx,(%ebx)
			return 0;
  8014fe:	b8 00 00 00 00       	mov    $0x0,%eax
  801503:	eb 31                	jmp    801536 <dev_lookup+0x61>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801505:	40                   	inc    %eax
  801506:	8b 14 85 08 2b 80 00 	mov    0x802b08(,%eax,4),%edx
  80150d:	85 d2                	test   %edx,%edx
  80150f:	75 e0                	jne    8014f1 <dev_lookup+0x1c>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801511:	a1 04 40 80 00       	mov    0x804004,%eax
  801516:	8b 40 48             	mov    0x48(%eax),%eax
  801519:	83 ec 04             	sub    $0x4,%esp
  80151c:	51                   	push   %ecx
  80151d:	50                   	push   %eax
  80151e:	68 88 2a 80 00       	push   $0x802a88
  801523:	e8 1c f2 ff ff       	call   800744 <cprintf>
	*dev = 0;
  801528:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_INVAL;
  80152e:	83 c4 10             	add    $0x10,%esp
  801531:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801536:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801539:	c9                   	leave  
  80153a:	c3                   	ret    

0080153b <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  80153b:	55                   	push   %ebp
  80153c:	89 e5                	mov    %esp,%ebp
  80153e:	56                   	push   %esi
  80153f:	53                   	push   %ebx
  801540:	83 ec 20             	sub    $0x20,%esp
  801543:	8b 75 08             	mov    0x8(%ebp),%esi
  801546:	8a 45 0c             	mov    0xc(%ebp),%al
  801549:	88 45 e7             	mov    %al,-0x19(%ebp)
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80154c:	56                   	push   %esi
  80154d:	e8 92 fe ff ff       	call   8013e4 <fd2num>
  801552:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801555:	89 14 24             	mov    %edx,(%esp)
  801558:	50                   	push   %eax
  801559:	e8 21 ff ff ff       	call   80147f <fd_lookup>
  80155e:	89 c3                	mov    %eax,%ebx
  801560:	83 c4 08             	add    $0x8,%esp
  801563:	85 c0                	test   %eax,%eax
  801565:	78 05                	js     80156c <fd_close+0x31>
	    || fd != fd2)
  801567:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  80156a:	74 0d                	je     801579 <fd_close+0x3e>
		return (must_exist ? r : 0);
  80156c:	80 7d e7 00          	cmpb   $0x0,-0x19(%ebp)
  801570:	75 48                	jne    8015ba <fd_close+0x7f>
  801572:	bb 00 00 00 00       	mov    $0x0,%ebx
  801577:	eb 41                	jmp    8015ba <fd_close+0x7f>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801579:	83 ec 08             	sub    $0x8,%esp
  80157c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80157f:	50                   	push   %eax
  801580:	ff 36                	pushl  (%esi)
  801582:	e8 4e ff ff ff       	call   8014d5 <dev_lookup>
  801587:	89 c3                	mov    %eax,%ebx
  801589:	83 c4 10             	add    $0x10,%esp
  80158c:	85 c0                	test   %eax,%eax
  80158e:	78 1c                	js     8015ac <fd_close+0x71>
		if (dev->dev_close)
  801590:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801593:	8b 40 10             	mov    0x10(%eax),%eax
  801596:	85 c0                	test   %eax,%eax
  801598:	74 0d                	je     8015a7 <fd_close+0x6c>
			r = (*dev->dev_close)(fd);
  80159a:	83 ec 0c             	sub    $0xc,%esp
  80159d:	56                   	push   %esi
  80159e:	ff d0                	call   *%eax
  8015a0:	89 c3                	mov    %eax,%ebx
  8015a2:	83 c4 10             	add    $0x10,%esp
  8015a5:	eb 05                	jmp    8015ac <fd_close+0x71>
		else
			r = 0;
  8015a7:	bb 00 00 00 00       	mov    $0x0,%ebx
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8015ac:	83 ec 08             	sub    $0x8,%esp
  8015af:	56                   	push   %esi
  8015b0:	6a 00                	push   $0x0
  8015b2:	e8 0f fc ff ff       	call   8011c6 <sys_page_unmap>
	return r;
  8015b7:	83 c4 10             	add    $0x10,%esp
}
  8015ba:	89 d8                	mov    %ebx,%eax
  8015bc:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8015bf:	5b                   	pop    %ebx
  8015c0:	5e                   	pop    %esi
  8015c1:	c9                   	leave  
  8015c2:	c3                   	ret    

008015c3 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8015c3:	55                   	push   %ebp
  8015c4:	89 e5                	mov    %esp,%ebp
  8015c6:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8015c9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015cc:	50                   	push   %eax
  8015cd:	ff 75 08             	pushl  0x8(%ebp)
  8015d0:	e8 aa fe ff ff       	call   80147f <fd_lookup>
  8015d5:	83 c4 08             	add    $0x8,%esp
  8015d8:	85 c0                	test   %eax,%eax
  8015da:	78 10                	js     8015ec <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  8015dc:	83 ec 08             	sub    $0x8,%esp
  8015df:	6a 01                	push   $0x1
  8015e1:	ff 75 f4             	pushl  -0xc(%ebp)
  8015e4:	e8 52 ff ff ff       	call   80153b <fd_close>
  8015e9:	83 c4 10             	add    $0x10,%esp
}
  8015ec:	c9                   	leave  
  8015ed:	c3                   	ret    

008015ee <close_all>:

void
close_all(void)
{
  8015ee:	55                   	push   %ebp
  8015ef:	89 e5                	mov    %esp,%ebp
  8015f1:	53                   	push   %ebx
  8015f2:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8015f5:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8015fa:	83 ec 0c             	sub    $0xc,%esp
  8015fd:	53                   	push   %ebx
  8015fe:	e8 c0 ff ff ff       	call   8015c3 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801603:	43                   	inc    %ebx
  801604:	83 c4 10             	add    $0x10,%esp
  801607:	83 fb 20             	cmp    $0x20,%ebx
  80160a:	75 ee                	jne    8015fa <close_all+0xc>
		close(i);
}
  80160c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80160f:	c9                   	leave  
  801610:	c3                   	ret    

00801611 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801611:	55                   	push   %ebp
  801612:	89 e5                	mov    %esp,%ebp
  801614:	57                   	push   %edi
  801615:	56                   	push   %esi
  801616:	53                   	push   %ebx
  801617:	83 ec 2c             	sub    $0x2c,%esp
  80161a:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  80161d:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801620:	50                   	push   %eax
  801621:	ff 75 08             	pushl  0x8(%ebp)
  801624:	e8 56 fe ff ff       	call   80147f <fd_lookup>
  801629:	89 c3                	mov    %eax,%ebx
  80162b:	83 c4 08             	add    $0x8,%esp
  80162e:	85 c0                	test   %eax,%eax
  801630:	0f 88 c0 00 00 00    	js     8016f6 <dup+0xe5>
		return r;
	close(newfdnum);
  801636:	83 ec 0c             	sub    $0xc,%esp
  801639:	57                   	push   %edi
  80163a:	e8 84 ff ff ff       	call   8015c3 <close>

	newfd = INDEX2FD(newfdnum);
  80163f:	8d b7 00 00 0d 00    	lea    0xd0000(%edi),%esi
  801645:	c1 e6 0c             	shl    $0xc,%esi
	ova = fd2data(oldfd);
  801648:	83 c4 04             	add    $0x4,%esp
  80164b:	ff 75 e4             	pushl  -0x1c(%ebp)
  80164e:	e8 a1 fd ff ff       	call   8013f4 <fd2data>
  801653:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  801655:	89 34 24             	mov    %esi,(%esp)
  801658:	e8 97 fd ff ff       	call   8013f4 <fd2data>
  80165d:	83 c4 10             	add    $0x10,%esp
  801660:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801663:	89 d8                	mov    %ebx,%eax
  801665:	c1 e8 16             	shr    $0x16,%eax
  801668:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80166f:	a8 01                	test   $0x1,%al
  801671:	74 37                	je     8016aa <dup+0x99>
  801673:	89 d8                	mov    %ebx,%eax
  801675:	c1 e8 0c             	shr    $0xc,%eax
  801678:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80167f:	f6 c2 01             	test   $0x1,%dl
  801682:	74 26                	je     8016aa <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801684:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80168b:	83 ec 0c             	sub    $0xc,%esp
  80168e:	25 07 0e 00 00       	and    $0xe07,%eax
  801693:	50                   	push   %eax
  801694:	ff 75 d4             	pushl  -0x2c(%ebp)
  801697:	6a 00                	push   $0x0
  801699:	53                   	push   %ebx
  80169a:	6a 00                	push   $0x0
  80169c:	e8 ff fa ff ff       	call   8011a0 <sys_page_map>
  8016a1:	89 c3                	mov    %eax,%ebx
  8016a3:	83 c4 20             	add    $0x20,%esp
  8016a6:	85 c0                	test   %eax,%eax
  8016a8:	78 2d                	js     8016d7 <dup+0xc6>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8016aa:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8016ad:	89 c2                	mov    %eax,%edx
  8016af:	c1 ea 0c             	shr    $0xc,%edx
  8016b2:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8016b9:	83 ec 0c             	sub    $0xc,%esp
  8016bc:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  8016c2:	52                   	push   %edx
  8016c3:	56                   	push   %esi
  8016c4:	6a 00                	push   $0x0
  8016c6:	50                   	push   %eax
  8016c7:	6a 00                	push   $0x0
  8016c9:	e8 d2 fa ff ff       	call   8011a0 <sys_page_map>
  8016ce:	89 c3                	mov    %eax,%ebx
  8016d0:	83 c4 20             	add    $0x20,%esp
  8016d3:	85 c0                	test   %eax,%eax
  8016d5:	79 1d                	jns    8016f4 <dup+0xe3>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8016d7:	83 ec 08             	sub    $0x8,%esp
  8016da:	56                   	push   %esi
  8016db:	6a 00                	push   $0x0
  8016dd:	e8 e4 fa ff ff       	call   8011c6 <sys_page_unmap>
	sys_page_unmap(0, nva);
  8016e2:	83 c4 08             	add    $0x8,%esp
  8016e5:	ff 75 d4             	pushl  -0x2c(%ebp)
  8016e8:	6a 00                	push   $0x0
  8016ea:	e8 d7 fa ff ff       	call   8011c6 <sys_page_unmap>
	return r;
  8016ef:	83 c4 10             	add    $0x10,%esp
  8016f2:	eb 02                	jmp    8016f6 <dup+0xe5>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
		goto err;

	return newfdnum;
  8016f4:	89 fb                	mov    %edi,%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  8016f6:	89 d8                	mov    %ebx,%eax
  8016f8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8016fb:	5b                   	pop    %ebx
  8016fc:	5e                   	pop    %esi
  8016fd:	5f                   	pop    %edi
  8016fe:	c9                   	leave  
  8016ff:	c3                   	ret    

00801700 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801700:	55                   	push   %ebp
  801701:	89 e5                	mov    %esp,%ebp
  801703:	53                   	push   %ebx
  801704:	83 ec 14             	sub    $0x14,%esp
  801707:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80170a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80170d:	50                   	push   %eax
  80170e:	53                   	push   %ebx
  80170f:	e8 6b fd ff ff       	call   80147f <fd_lookup>
  801714:	83 c4 08             	add    $0x8,%esp
  801717:	85 c0                	test   %eax,%eax
  801719:	78 67                	js     801782 <read+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80171b:	83 ec 08             	sub    $0x8,%esp
  80171e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801721:	50                   	push   %eax
  801722:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801725:	ff 30                	pushl  (%eax)
  801727:	e8 a9 fd ff ff       	call   8014d5 <dev_lookup>
  80172c:	83 c4 10             	add    $0x10,%esp
  80172f:	85 c0                	test   %eax,%eax
  801731:	78 4f                	js     801782 <read+0x82>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801733:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801736:	8b 50 08             	mov    0x8(%eax),%edx
  801739:	83 e2 03             	and    $0x3,%edx
  80173c:	83 fa 01             	cmp    $0x1,%edx
  80173f:	75 21                	jne    801762 <read+0x62>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801741:	a1 04 40 80 00       	mov    0x804004,%eax
  801746:	8b 40 48             	mov    0x48(%eax),%eax
  801749:	83 ec 04             	sub    $0x4,%esp
  80174c:	53                   	push   %ebx
  80174d:	50                   	push   %eax
  80174e:	68 cc 2a 80 00       	push   $0x802acc
  801753:	e8 ec ef ff ff       	call   800744 <cprintf>
		return -E_INVAL;
  801758:	83 c4 10             	add    $0x10,%esp
  80175b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801760:	eb 20                	jmp    801782 <read+0x82>
	}
	if (!dev->dev_read)
  801762:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801765:	8b 52 08             	mov    0x8(%edx),%edx
  801768:	85 d2                	test   %edx,%edx
  80176a:	74 11                	je     80177d <read+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  80176c:	83 ec 04             	sub    $0x4,%esp
  80176f:	ff 75 10             	pushl  0x10(%ebp)
  801772:	ff 75 0c             	pushl  0xc(%ebp)
  801775:	50                   	push   %eax
  801776:	ff d2                	call   *%edx
  801778:	83 c4 10             	add    $0x10,%esp
  80177b:	eb 05                	jmp    801782 <read+0x82>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  80177d:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_read)(fd, buf, n);
}
  801782:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801785:	c9                   	leave  
  801786:	c3                   	ret    

00801787 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801787:	55                   	push   %ebp
  801788:	89 e5                	mov    %esp,%ebp
  80178a:	57                   	push   %edi
  80178b:	56                   	push   %esi
  80178c:	53                   	push   %ebx
  80178d:	83 ec 0c             	sub    $0xc,%esp
  801790:	8b 7d 08             	mov    0x8(%ebp),%edi
  801793:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801796:	85 f6                	test   %esi,%esi
  801798:	74 31                	je     8017cb <readn+0x44>
  80179a:	b8 00 00 00 00       	mov    $0x0,%eax
  80179f:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = read(fdnum, (char*)buf + tot, n - tot);
  8017a4:	83 ec 04             	sub    $0x4,%esp
  8017a7:	89 f2                	mov    %esi,%edx
  8017a9:	29 c2                	sub    %eax,%edx
  8017ab:	52                   	push   %edx
  8017ac:	03 45 0c             	add    0xc(%ebp),%eax
  8017af:	50                   	push   %eax
  8017b0:	57                   	push   %edi
  8017b1:	e8 4a ff ff ff       	call   801700 <read>
		if (m < 0)
  8017b6:	83 c4 10             	add    $0x10,%esp
  8017b9:	85 c0                	test   %eax,%eax
  8017bb:	78 17                	js     8017d4 <readn+0x4d>
			return m;
		if (m == 0)
  8017bd:	85 c0                	test   %eax,%eax
  8017bf:	74 11                	je     8017d2 <readn+0x4b>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8017c1:	01 c3                	add    %eax,%ebx
  8017c3:	89 d8                	mov    %ebx,%eax
  8017c5:	39 f3                	cmp    %esi,%ebx
  8017c7:	72 db                	jb     8017a4 <readn+0x1d>
  8017c9:	eb 09                	jmp    8017d4 <readn+0x4d>
  8017cb:	b8 00 00 00 00       	mov    $0x0,%eax
  8017d0:	eb 02                	jmp    8017d4 <readn+0x4d>
		m = read(fdnum, (char*)buf + tot, n - tot);
		if (m < 0)
			return m;
		if (m == 0)
  8017d2:	89 d8                	mov    %ebx,%eax
			break;
	}
	return tot;
}
  8017d4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8017d7:	5b                   	pop    %ebx
  8017d8:	5e                   	pop    %esi
  8017d9:	5f                   	pop    %edi
  8017da:	c9                   	leave  
  8017db:	c3                   	ret    

008017dc <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8017dc:	55                   	push   %ebp
  8017dd:	89 e5                	mov    %esp,%ebp
  8017df:	53                   	push   %ebx
  8017e0:	83 ec 14             	sub    $0x14,%esp
  8017e3:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8017e6:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8017e9:	50                   	push   %eax
  8017ea:	53                   	push   %ebx
  8017eb:	e8 8f fc ff ff       	call   80147f <fd_lookup>
  8017f0:	83 c4 08             	add    $0x8,%esp
  8017f3:	85 c0                	test   %eax,%eax
  8017f5:	78 62                	js     801859 <write+0x7d>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8017f7:	83 ec 08             	sub    $0x8,%esp
  8017fa:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8017fd:	50                   	push   %eax
  8017fe:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801801:	ff 30                	pushl  (%eax)
  801803:	e8 cd fc ff ff       	call   8014d5 <dev_lookup>
  801808:	83 c4 10             	add    $0x10,%esp
  80180b:	85 c0                	test   %eax,%eax
  80180d:	78 4a                	js     801859 <write+0x7d>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80180f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801812:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801816:	75 21                	jne    801839 <write+0x5d>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801818:	a1 04 40 80 00       	mov    0x804004,%eax
  80181d:	8b 40 48             	mov    0x48(%eax),%eax
  801820:	83 ec 04             	sub    $0x4,%esp
  801823:	53                   	push   %ebx
  801824:	50                   	push   %eax
  801825:	68 e8 2a 80 00       	push   $0x802ae8
  80182a:	e8 15 ef ff ff       	call   800744 <cprintf>
		return -E_INVAL;
  80182f:	83 c4 10             	add    $0x10,%esp
  801832:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801837:	eb 20                	jmp    801859 <write+0x7d>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801839:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80183c:	8b 52 0c             	mov    0xc(%edx),%edx
  80183f:	85 d2                	test   %edx,%edx
  801841:	74 11                	je     801854 <write+0x78>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801843:	83 ec 04             	sub    $0x4,%esp
  801846:	ff 75 10             	pushl  0x10(%ebp)
  801849:	ff 75 0c             	pushl  0xc(%ebp)
  80184c:	50                   	push   %eax
  80184d:	ff d2                	call   *%edx
  80184f:	83 c4 10             	add    $0x10,%esp
  801852:	eb 05                	jmp    801859 <write+0x7d>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801854:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  801859:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80185c:	c9                   	leave  
  80185d:	c3                   	ret    

0080185e <seek>:

int
seek(int fdnum, off_t offset)
{
  80185e:	55                   	push   %ebp
  80185f:	89 e5                	mov    %esp,%ebp
  801861:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801864:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801867:	50                   	push   %eax
  801868:	ff 75 08             	pushl  0x8(%ebp)
  80186b:	e8 0f fc ff ff       	call   80147f <fd_lookup>
  801870:	83 c4 08             	add    $0x8,%esp
  801873:	85 c0                	test   %eax,%eax
  801875:	78 0e                	js     801885 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801877:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80187a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80187d:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801880:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801885:	c9                   	leave  
  801886:	c3                   	ret    

00801887 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801887:	55                   	push   %ebp
  801888:	89 e5                	mov    %esp,%ebp
  80188a:	53                   	push   %ebx
  80188b:	83 ec 14             	sub    $0x14,%esp
  80188e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801891:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801894:	50                   	push   %eax
  801895:	53                   	push   %ebx
  801896:	e8 e4 fb ff ff       	call   80147f <fd_lookup>
  80189b:	83 c4 08             	add    $0x8,%esp
  80189e:	85 c0                	test   %eax,%eax
  8018a0:	78 5f                	js     801901 <ftruncate+0x7a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8018a2:	83 ec 08             	sub    $0x8,%esp
  8018a5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8018a8:	50                   	push   %eax
  8018a9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8018ac:	ff 30                	pushl  (%eax)
  8018ae:	e8 22 fc ff ff       	call   8014d5 <dev_lookup>
  8018b3:	83 c4 10             	add    $0x10,%esp
  8018b6:	85 c0                	test   %eax,%eax
  8018b8:	78 47                	js     801901 <ftruncate+0x7a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8018ba:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8018bd:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8018c1:	75 21                	jne    8018e4 <ftruncate+0x5d>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8018c3:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8018c8:	8b 40 48             	mov    0x48(%eax),%eax
  8018cb:	83 ec 04             	sub    $0x4,%esp
  8018ce:	53                   	push   %ebx
  8018cf:	50                   	push   %eax
  8018d0:	68 a8 2a 80 00       	push   $0x802aa8
  8018d5:	e8 6a ee ff ff       	call   800744 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8018da:	83 c4 10             	add    $0x10,%esp
  8018dd:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8018e2:	eb 1d                	jmp    801901 <ftruncate+0x7a>
	}
	if (!dev->dev_trunc)
  8018e4:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8018e7:	8b 52 18             	mov    0x18(%edx),%edx
  8018ea:	85 d2                	test   %edx,%edx
  8018ec:	74 0e                	je     8018fc <ftruncate+0x75>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8018ee:	83 ec 08             	sub    $0x8,%esp
  8018f1:	ff 75 0c             	pushl  0xc(%ebp)
  8018f4:	50                   	push   %eax
  8018f5:	ff d2                	call   *%edx
  8018f7:	83 c4 10             	add    $0x10,%esp
  8018fa:	eb 05                	jmp    801901 <ftruncate+0x7a>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8018fc:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  801901:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801904:	c9                   	leave  
  801905:	c3                   	ret    

00801906 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801906:	55                   	push   %ebp
  801907:	89 e5                	mov    %esp,%ebp
  801909:	53                   	push   %ebx
  80190a:	83 ec 14             	sub    $0x14,%esp
  80190d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801910:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801913:	50                   	push   %eax
  801914:	ff 75 08             	pushl  0x8(%ebp)
  801917:	e8 63 fb ff ff       	call   80147f <fd_lookup>
  80191c:	83 c4 08             	add    $0x8,%esp
  80191f:	85 c0                	test   %eax,%eax
  801921:	78 52                	js     801975 <fstat+0x6f>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801923:	83 ec 08             	sub    $0x8,%esp
  801926:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801929:	50                   	push   %eax
  80192a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80192d:	ff 30                	pushl  (%eax)
  80192f:	e8 a1 fb ff ff       	call   8014d5 <dev_lookup>
  801934:	83 c4 10             	add    $0x10,%esp
  801937:	85 c0                	test   %eax,%eax
  801939:	78 3a                	js     801975 <fstat+0x6f>
		return r;
	if (!dev->dev_stat)
  80193b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80193e:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801942:	74 2c                	je     801970 <fstat+0x6a>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801944:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801947:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80194e:	00 00 00 
	stat->st_isdir = 0;
  801951:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801958:	00 00 00 
	stat->st_dev = dev;
  80195b:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801961:	83 ec 08             	sub    $0x8,%esp
  801964:	53                   	push   %ebx
  801965:	ff 75 f0             	pushl  -0x10(%ebp)
  801968:	ff 50 14             	call   *0x14(%eax)
  80196b:	83 c4 10             	add    $0x10,%esp
  80196e:	eb 05                	jmp    801975 <fstat+0x6f>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801970:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801975:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801978:	c9                   	leave  
  801979:	c3                   	ret    

0080197a <stat>:

int
stat(const char *path, struct Stat *stat)
{
  80197a:	55                   	push   %ebp
  80197b:	89 e5                	mov    %esp,%ebp
  80197d:	56                   	push   %esi
  80197e:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  80197f:	83 ec 08             	sub    $0x8,%esp
  801982:	6a 00                	push   $0x0
  801984:	ff 75 08             	pushl  0x8(%ebp)
  801987:	e8 78 01 00 00       	call   801b04 <open>
  80198c:	89 c3                	mov    %eax,%ebx
  80198e:	83 c4 10             	add    $0x10,%esp
  801991:	85 c0                	test   %eax,%eax
  801993:	78 1b                	js     8019b0 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801995:	83 ec 08             	sub    $0x8,%esp
  801998:	ff 75 0c             	pushl  0xc(%ebp)
  80199b:	50                   	push   %eax
  80199c:	e8 65 ff ff ff       	call   801906 <fstat>
  8019a1:	89 c6                	mov    %eax,%esi
	close(fd);
  8019a3:	89 1c 24             	mov    %ebx,(%esp)
  8019a6:	e8 18 fc ff ff       	call   8015c3 <close>
	return r;
  8019ab:	83 c4 10             	add    $0x10,%esp
  8019ae:	89 f3                	mov    %esi,%ebx
}
  8019b0:	89 d8                	mov    %ebx,%eax
  8019b2:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8019b5:	5b                   	pop    %ebx
  8019b6:	5e                   	pop    %esi
  8019b7:	c9                   	leave  
  8019b8:	c3                   	ret    
  8019b9:	00 00                	add    %al,(%eax)
	...

008019bc <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8019bc:	55                   	push   %ebp
  8019bd:	89 e5                	mov    %esp,%ebp
  8019bf:	56                   	push   %esi
  8019c0:	53                   	push   %ebx
  8019c1:	89 c3                	mov    %eax,%ebx
  8019c3:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  8019c5:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8019cc:	75 12                	jne    8019e0 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8019ce:	83 ec 0c             	sub    $0xc,%esp
  8019d1:	6a 01                	push   $0x1
  8019d3:	e8 ae f9 ff ff       	call   801386 <ipc_find_env>
  8019d8:	a3 00 40 80 00       	mov    %eax,0x804000
  8019dd:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8019e0:	6a 07                	push   $0x7
  8019e2:	68 00 50 80 00       	push   $0x805000
  8019e7:	53                   	push   %ebx
  8019e8:	ff 35 00 40 80 00    	pushl  0x804000
  8019ee:	e8 3e f9 ff ff       	call   801331 <ipc_send>
	
	return ipc_recv(NULL, dstva, NULL);
  8019f3:	83 c4 0c             	add    $0xc,%esp
  8019f6:	6a 00                	push   $0x0
  8019f8:	56                   	push   %esi
  8019f9:	6a 00                	push   $0x0
  8019fb:	e8 bc f8 ff ff       	call   8012bc <ipc_recv>
}
  801a00:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a03:	5b                   	pop    %ebx
  801a04:	5e                   	pop    %esi
  801a05:	c9                   	leave  
  801a06:	c3                   	ret    

00801a07 <devfile_stat>:
}


static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801a07:	55                   	push   %ebp
  801a08:	89 e5                	mov    %esp,%ebp
  801a0a:	53                   	push   %ebx
  801a0b:	83 ec 04             	sub    $0x4,%esp
  801a0e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801a11:	8b 45 08             	mov    0x8(%ebp),%eax
  801a14:	8b 40 0c             	mov    0xc(%eax),%eax
  801a17:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0) {
  801a1c:	ba 00 00 00 00       	mov    $0x0,%edx
  801a21:	b8 05 00 00 00       	mov    $0x5,%eax
  801a26:	e8 91 ff ff ff       	call   8019bc <fsipc>
  801a2b:	85 c0                	test   %eax,%eax
  801a2d:	78 2c                	js     801a5b <devfile_stat+0x54>
		return r;
	}
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801a2f:	83 ec 08             	sub    $0x8,%esp
  801a32:	68 00 50 80 00       	push   $0x805000
  801a37:	53                   	push   %ebx
  801a38:	e8 bd f2 ff ff       	call   800cfa <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801a3d:	a1 80 50 80 00       	mov    0x805080,%eax
  801a42:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801a48:	a1 84 50 80 00       	mov    0x805084,%eax
  801a4d:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801a53:	83 c4 10             	add    $0x10,%esp
  801a56:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801a5b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a5e:	c9                   	leave  
  801a5f:	c3                   	ret    

00801a60 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801a60:	55                   	push   %ebp
  801a61:	89 e5                	mov    %esp,%ebp
  801a63:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801a66:	8b 45 08             	mov    0x8(%ebp),%eax
  801a69:	8b 40 0c             	mov    0xc(%eax),%eax
  801a6c:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801a71:	ba 00 00 00 00       	mov    $0x0,%edx
  801a76:	b8 06 00 00 00       	mov    $0x6,%eax
  801a7b:	e8 3c ff ff ff       	call   8019bc <fsipc>
}
  801a80:	c9                   	leave  
  801a81:	c3                   	ret    

00801a82 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801a82:	55                   	push   %ebp
  801a83:	89 e5                	mov    %esp,%ebp
  801a85:	56                   	push   %esi
  801a86:	53                   	push   %ebx
  801a87:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801a8a:	8b 45 08             	mov    0x8(%ebp),%eax
  801a8d:	8b 40 0c             	mov    0xc(%eax),%eax
  801a90:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801a95:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801a9b:	ba 00 00 00 00       	mov    $0x0,%edx
  801aa0:	b8 03 00 00 00       	mov    $0x3,%eax
  801aa5:	e8 12 ff ff ff       	call   8019bc <fsipc>
  801aaa:	89 c3                	mov    %eax,%ebx
  801aac:	85 c0                	test   %eax,%eax
  801aae:	78 4b                	js     801afb <devfile_read+0x79>
		return r;
	assert(r <= n);
  801ab0:	39 c6                	cmp    %eax,%esi
  801ab2:	73 16                	jae    801aca <devfile_read+0x48>
  801ab4:	68 18 2b 80 00       	push   $0x802b18
  801ab9:	68 1f 2b 80 00       	push   $0x802b1f
  801abe:	6a 7d                	push   $0x7d
  801ac0:	68 34 2b 80 00       	push   $0x802b34
  801ac5:	e8 a2 eb ff ff       	call   80066c <_panic>
	assert(r <= PGSIZE);
  801aca:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801acf:	7e 16                	jle    801ae7 <devfile_read+0x65>
  801ad1:	68 3f 2b 80 00       	push   $0x802b3f
  801ad6:	68 1f 2b 80 00       	push   $0x802b1f
  801adb:	6a 7e                	push   $0x7e
  801add:	68 34 2b 80 00       	push   $0x802b34
  801ae2:	e8 85 eb ff ff       	call   80066c <_panic>
	memmove(buf, &fsipcbuf, r);
  801ae7:	83 ec 04             	sub    $0x4,%esp
  801aea:	50                   	push   %eax
  801aeb:	68 00 50 80 00       	push   $0x805000
  801af0:	ff 75 0c             	pushl  0xc(%ebp)
  801af3:	e8 c3 f3 ff ff       	call   800ebb <memmove>
	return r;
  801af8:	83 c4 10             	add    $0x10,%esp
}
  801afb:	89 d8                	mov    %ebx,%eax
  801afd:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801b00:	5b                   	pop    %ebx
  801b01:	5e                   	pop    %esi
  801b02:	c9                   	leave  
  801b03:	c3                   	ret    

00801b04 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801b04:	55                   	push   %ebp
  801b05:	89 e5                	mov    %esp,%ebp
  801b07:	56                   	push   %esi
  801b08:	53                   	push   %ebx
  801b09:	83 ec 1c             	sub    $0x1c,%esp
  801b0c:	8b 75 08             	mov    0x8(%ebp),%esi
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801b0f:	56                   	push   %esi
  801b10:	e8 93 f1 ff ff       	call   800ca8 <strlen>
  801b15:	83 c4 10             	add    $0x10,%esp
  801b18:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801b1d:	7f 65                	jg     801b84 <open+0x80>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801b1f:	83 ec 0c             	sub    $0xc,%esp
  801b22:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801b25:	50                   	push   %eax
  801b26:	e8 e1 f8 ff ff       	call   80140c <fd_alloc>
  801b2b:	89 c3                	mov    %eax,%ebx
  801b2d:	83 c4 10             	add    $0x10,%esp
  801b30:	85 c0                	test   %eax,%eax
  801b32:	78 55                	js     801b89 <open+0x85>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801b34:	83 ec 08             	sub    $0x8,%esp
  801b37:	56                   	push   %esi
  801b38:	68 00 50 80 00       	push   $0x805000
  801b3d:	e8 b8 f1 ff ff       	call   800cfa <strcpy>
	fsipcbuf.open.req_omode = mode;
  801b42:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b45:	a3 00 54 80 00       	mov    %eax,0x805400



	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801b4a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801b4d:	b8 01 00 00 00       	mov    $0x1,%eax
  801b52:	e8 65 fe ff ff       	call   8019bc <fsipc>
  801b57:	89 c3                	mov    %eax,%ebx
  801b59:	83 c4 10             	add    $0x10,%esp
  801b5c:	85 c0                	test   %eax,%eax
  801b5e:	79 12                	jns    801b72 <open+0x6e>
		fd_close(fd, 0);
  801b60:	83 ec 08             	sub    $0x8,%esp
  801b63:	6a 00                	push   $0x0
  801b65:	ff 75 f4             	pushl  -0xc(%ebp)
  801b68:	e8 ce f9 ff ff       	call   80153b <fd_close>
		return r;
  801b6d:	83 c4 10             	add    $0x10,%esp
  801b70:	eb 17                	jmp    801b89 <open+0x85>
	}

	return fd2num(fd);
  801b72:	83 ec 0c             	sub    $0xc,%esp
  801b75:	ff 75 f4             	pushl  -0xc(%ebp)
  801b78:	e8 67 f8 ff ff       	call   8013e4 <fd2num>
  801b7d:	89 c3                	mov    %eax,%ebx
  801b7f:	83 c4 10             	add    $0x10,%esp
  801b82:	eb 05                	jmp    801b89 <open+0x85>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801b84:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801b89:	89 d8                	mov    %ebx,%eax
  801b8b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801b8e:	5b                   	pop    %ebx
  801b8f:	5e                   	pop    %esi
  801b90:	c9                   	leave  
  801b91:	c3                   	ret    
	...

00801b94 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801b94:	55                   	push   %ebp
  801b95:	89 e5                	mov    %esp,%ebp
  801b97:	56                   	push   %esi
  801b98:	53                   	push   %ebx
  801b99:	8b 75 0c             	mov    0xc(%ebp),%esi
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801b9c:	83 ec 0c             	sub    $0xc,%esp
  801b9f:	ff 75 08             	pushl  0x8(%ebp)
  801ba2:	e8 4d f8 ff ff       	call   8013f4 <fd2data>
  801ba7:	89 c3                	mov    %eax,%ebx
	strcpy(stat->st_name, "<pipe>");
  801ba9:	83 c4 08             	add    $0x8,%esp
  801bac:	68 4b 2b 80 00       	push   $0x802b4b
  801bb1:	56                   	push   %esi
  801bb2:	e8 43 f1 ff ff       	call   800cfa <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801bb7:	8b 43 04             	mov    0x4(%ebx),%eax
  801bba:	2b 03                	sub    (%ebx),%eax
  801bbc:	89 86 80 00 00 00    	mov    %eax,0x80(%esi)
	stat->st_isdir = 0;
  801bc2:	c7 86 84 00 00 00 00 	movl   $0x0,0x84(%esi)
  801bc9:	00 00 00 
	stat->st_dev = &devpipe;
  801bcc:	c7 86 88 00 00 00 24 	movl   $0x803024,0x88(%esi)
  801bd3:	30 80 00 
	return 0;
}
  801bd6:	b8 00 00 00 00       	mov    $0x0,%eax
  801bdb:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801bde:	5b                   	pop    %ebx
  801bdf:	5e                   	pop    %esi
  801be0:	c9                   	leave  
  801be1:	c3                   	ret    

00801be2 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801be2:	55                   	push   %ebp
  801be3:	89 e5                	mov    %esp,%ebp
  801be5:	53                   	push   %ebx
  801be6:	83 ec 0c             	sub    $0xc,%esp
  801be9:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801bec:	53                   	push   %ebx
  801bed:	6a 00                	push   $0x0
  801bef:	e8 d2 f5 ff ff       	call   8011c6 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801bf4:	89 1c 24             	mov    %ebx,(%esp)
  801bf7:	e8 f8 f7 ff ff       	call   8013f4 <fd2data>
  801bfc:	83 c4 08             	add    $0x8,%esp
  801bff:	50                   	push   %eax
  801c00:	6a 00                	push   $0x0
  801c02:	e8 bf f5 ff ff       	call   8011c6 <sys_page_unmap>
}
  801c07:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801c0a:	c9                   	leave  
  801c0b:	c3                   	ret    

00801c0c <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801c0c:	55                   	push   %ebp
  801c0d:	89 e5                	mov    %esp,%ebp
  801c0f:	57                   	push   %edi
  801c10:	56                   	push   %esi
  801c11:	53                   	push   %ebx
  801c12:	83 ec 1c             	sub    $0x1c,%esp
  801c15:	89 c7                	mov    %eax,%edi
  801c17:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801c1a:	a1 04 40 80 00       	mov    0x804004,%eax
  801c1f:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801c22:	83 ec 0c             	sub    $0xc,%esp
  801c25:	57                   	push   %edi
  801c26:	e8 6d 04 00 00       	call   802098 <pageref>
  801c2b:	89 c6                	mov    %eax,%esi
  801c2d:	83 c4 04             	add    $0x4,%esp
  801c30:	ff 75 e4             	pushl  -0x1c(%ebp)
  801c33:	e8 60 04 00 00       	call   802098 <pageref>
  801c38:	83 c4 10             	add    $0x10,%esp
  801c3b:	39 c6                	cmp    %eax,%esi
  801c3d:	0f 94 c0             	sete   %al
  801c40:	0f b6 c0             	movzbl %al,%eax
		nn = thisenv->env_runs;
  801c43:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801c49:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801c4c:	39 cb                	cmp    %ecx,%ebx
  801c4e:	75 08                	jne    801c58 <_pipeisclosed+0x4c>
			return ret;
		if (n != nn && ret == 1)
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
	}
}
  801c50:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801c53:	5b                   	pop    %ebx
  801c54:	5e                   	pop    %esi
  801c55:	5f                   	pop    %edi
  801c56:	c9                   	leave  
  801c57:	c3                   	ret    
		n = thisenv->env_runs;
		ret = pageref(fd) == pageref(p);
		nn = thisenv->env_runs;
		if (n == nn)
			return ret;
		if (n != nn && ret == 1)
  801c58:	83 f8 01             	cmp    $0x1,%eax
  801c5b:	75 bd                	jne    801c1a <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801c5d:	8b 42 58             	mov    0x58(%edx),%eax
  801c60:	6a 01                	push   $0x1
  801c62:	50                   	push   %eax
  801c63:	53                   	push   %ebx
  801c64:	68 52 2b 80 00       	push   $0x802b52
  801c69:	e8 d6 ea ff ff       	call   800744 <cprintf>
  801c6e:	83 c4 10             	add    $0x10,%esp
  801c71:	eb a7                	jmp    801c1a <_pipeisclosed+0xe>

00801c73 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801c73:	55                   	push   %ebp
  801c74:	89 e5                	mov    %esp,%ebp
  801c76:	57                   	push   %edi
  801c77:	56                   	push   %esi
  801c78:	53                   	push   %ebx
  801c79:	83 ec 28             	sub    $0x28,%esp
  801c7c:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801c7f:	56                   	push   %esi
  801c80:	e8 6f f7 ff ff       	call   8013f4 <fd2data>
  801c85:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801c87:	83 c4 10             	add    $0x10,%esp
  801c8a:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801c8e:	75 4a                	jne    801cda <devpipe_write+0x67>
  801c90:	bf 00 00 00 00       	mov    $0x0,%edi
  801c95:	eb 56                	jmp    801ced <devpipe_write+0x7a>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801c97:	89 da                	mov    %ebx,%edx
  801c99:	89 f0                	mov    %esi,%eax
  801c9b:	e8 6c ff ff ff       	call   801c0c <_pipeisclosed>
  801ca0:	85 c0                	test   %eax,%eax
  801ca2:	75 4d                	jne    801cf1 <devpipe_write+0x7e>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801ca4:	e8 ac f4 ff ff       	call   801155 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801ca9:	8b 43 04             	mov    0x4(%ebx),%eax
  801cac:	8b 13                	mov    (%ebx),%edx
  801cae:	83 c2 20             	add    $0x20,%edx
  801cb1:	39 d0                	cmp    %edx,%eax
  801cb3:	73 e2                	jae    801c97 <devpipe_write+0x24>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801cb5:	89 c2                	mov    %eax,%edx
  801cb7:	81 e2 1f 00 00 80    	and    $0x8000001f,%edx
  801cbd:	79 05                	jns    801cc4 <devpipe_write+0x51>
  801cbf:	4a                   	dec    %edx
  801cc0:	83 ca e0             	or     $0xffffffe0,%edx
  801cc3:	42                   	inc    %edx
  801cc4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801cc7:	8a 0c 39             	mov    (%ecx,%edi,1),%cl
  801cca:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801cce:	40                   	inc    %eax
  801ccf:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801cd2:	47                   	inc    %edi
  801cd3:	39 7d 10             	cmp    %edi,0x10(%ebp)
  801cd6:	77 07                	ja     801cdf <devpipe_write+0x6c>
  801cd8:	eb 13                	jmp    801ced <devpipe_write+0x7a>
  801cda:	bf 00 00 00 00       	mov    $0x0,%edi
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801cdf:	8b 43 04             	mov    0x4(%ebx),%eax
  801ce2:	8b 13                	mov    (%ebx),%edx
  801ce4:	83 c2 20             	add    $0x20,%edx
  801ce7:	39 d0                	cmp    %edx,%eax
  801ce9:	73 ac                	jae    801c97 <devpipe_write+0x24>
  801ceb:	eb c8                	jmp    801cb5 <devpipe_write+0x42>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801ced:	89 f8                	mov    %edi,%eax
  801cef:	eb 05                	jmp    801cf6 <devpipe_write+0x83>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801cf1:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801cf6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801cf9:	5b                   	pop    %ebx
  801cfa:	5e                   	pop    %esi
  801cfb:	5f                   	pop    %edi
  801cfc:	c9                   	leave  
  801cfd:	c3                   	ret    

00801cfe <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801cfe:	55                   	push   %ebp
  801cff:	89 e5                	mov    %esp,%ebp
  801d01:	57                   	push   %edi
  801d02:	56                   	push   %esi
  801d03:	53                   	push   %ebx
  801d04:	83 ec 18             	sub    $0x18,%esp
  801d07:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801d0a:	57                   	push   %edi
  801d0b:	e8 e4 f6 ff ff       	call   8013f4 <fd2data>
  801d10:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801d12:	83 c4 10             	add    $0x10,%esp
  801d15:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801d19:	75 44                	jne    801d5f <devpipe_read+0x61>
  801d1b:	be 00 00 00 00       	mov    $0x0,%esi
  801d20:	eb 4f                	jmp    801d71 <devpipe_read+0x73>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
				return i;
  801d22:	89 f0                	mov    %esi,%eax
  801d24:	eb 54                	jmp    801d7a <devpipe_read+0x7c>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801d26:	89 da                	mov    %ebx,%edx
  801d28:	89 f8                	mov    %edi,%eax
  801d2a:	e8 dd fe ff ff       	call   801c0c <_pipeisclosed>
  801d2f:	85 c0                	test   %eax,%eax
  801d31:	75 42                	jne    801d75 <devpipe_read+0x77>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801d33:	e8 1d f4 ff ff       	call   801155 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801d38:	8b 03                	mov    (%ebx),%eax
  801d3a:	3b 43 04             	cmp    0x4(%ebx),%eax
  801d3d:	74 e7                	je     801d26 <devpipe_read+0x28>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801d3f:	25 1f 00 00 80       	and    $0x8000001f,%eax
  801d44:	79 05                	jns    801d4b <devpipe_read+0x4d>
  801d46:	48                   	dec    %eax
  801d47:	83 c8 e0             	or     $0xffffffe0,%eax
  801d4a:	40                   	inc    %eax
  801d4b:	8a 44 03 08          	mov    0x8(%ebx,%eax,1),%al
  801d4f:	8b 55 0c             	mov    0xc(%ebp),%edx
  801d52:	88 04 32             	mov    %al,(%edx,%esi,1)
		p->p_rpos++;
  801d55:	ff 03                	incl   (%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801d57:	46                   	inc    %esi
  801d58:	39 75 10             	cmp    %esi,0x10(%ebp)
  801d5b:	77 07                	ja     801d64 <devpipe_read+0x66>
  801d5d:	eb 12                	jmp    801d71 <devpipe_read+0x73>
  801d5f:	be 00 00 00 00       	mov    $0x0,%esi
		while (p->p_rpos == p->p_wpos) {
  801d64:	8b 03                	mov    (%ebx),%eax
  801d66:	3b 43 04             	cmp    0x4(%ebx),%eax
  801d69:	75 d4                	jne    801d3f <devpipe_read+0x41>
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801d6b:	85 f6                	test   %esi,%esi
  801d6d:	75 b3                	jne    801d22 <devpipe_read+0x24>
  801d6f:	eb b5                	jmp    801d26 <devpipe_read+0x28>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801d71:	89 f0                	mov    %esi,%eax
  801d73:	eb 05                	jmp    801d7a <devpipe_read+0x7c>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801d75:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801d7a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801d7d:	5b                   	pop    %ebx
  801d7e:	5e                   	pop    %esi
  801d7f:	5f                   	pop    %edi
  801d80:	c9                   	leave  
  801d81:	c3                   	ret    

00801d82 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801d82:	55                   	push   %ebp
  801d83:	89 e5                	mov    %esp,%ebp
  801d85:	57                   	push   %edi
  801d86:	56                   	push   %esi
  801d87:	53                   	push   %ebx
  801d88:	83 ec 28             	sub    $0x28,%esp
  801d8b:	8b 7d 08             	mov    0x8(%ebp),%edi
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801d8e:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801d91:	50                   	push   %eax
  801d92:	e8 75 f6 ff ff       	call   80140c <fd_alloc>
  801d97:	89 c3                	mov    %eax,%ebx
  801d99:	83 c4 10             	add    $0x10,%esp
  801d9c:	85 c0                	test   %eax,%eax
  801d9e:	0f 88 24 01 00 00    	js     801ec8 <pipe+0x146>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801da4:	83 ec 04             	sub    $0x4,%esp
  801da7:	68 07 04 00 00       	push   $0x407
  801dac:	ff 75 e4             	pushl  -0x1c(%ebp)
  801daf:	6a 00                	push   $0x0
  801db1:	e8 c6 f3 ff ff       	call   80117c <sys_page_alloc>
  801db6:	89 c3                	mov    %eax,%ebx
  801db8:	83 c4 10             	add    $0x10,%esp
  801dbb:	85 c0                	test   %eax,%eax
  801dbd:	0f 88 05 01 00 00    	js     801ec8 <pipe+0x146>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801dc3:	83 ec 0c             	sub    $0xc,%esp
  801dc6:	8d 45 e0             	lea    -0x20(%ebp),%eax
  801dc9:	50                   	push   %eax
  801dca:	e8 3d f6 ff ff       	call   80140c <fd_alloc>
  801dcf:	89 c3                	mov    %eax,%ebx
  801dd1:	83 c4 10             	add    $0x10,%esp
  801dd4:	85 c0                	test   %eax,%eax
  801dd6:	0f 88 dc 00 00 00    	js     801eb8 <pipe+0x136>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801ddc:	83 ec 04             	sub    $0x4,%esp
  801ddf:	68 07 04 00 00       	push   $0x407
  801de4:	ff 75 e0             	pushl  -0x20(%ebp)
  801de7:	6a 00                	push   $0x0
  801de9:	e8 8e f3 ff ff       	call   80117c <sys_page_alloc>
  801dee:	89 c3                	mov    %eax,%ebx
  801df0:	83 c4 10             	add    $0x10,%esp
  801df3:	85 c0                	test   %eax,%eax
  801df5:	0f 88 bd 00 00 00    	js     801eb8 <pipe+0x136>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801dfb:	83 ec 0c             	sub    $0xc,%esp
  801dfe:	ff 75 e4             	pushl  -0x1c(%ebp)
  801e01:	e8 ee f5 ff ff       	call   8013f4 <fd2data>
  801e06:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801e08:	83 c4 0c             	add    $0xc,%esp
  801e0b:	68 07 04 00 00       	push   $0x407
  801e10:	50                   	push   %eax
  801e11:	6a 00                	push   $0x0
  801e13:	e8 64 f3 ff ff       	call   80117c <sys_page_alloc>
  801e18:	89 c3                	mov    %eax,%ebx
  801e1a:	83 c4 10             	add    $0x10,%esp
  801e1d:	85 c0                	test   %eax,%eax
  801e1f:	0f 88 83 00 00 00    	js     801ea8 <pipe+0x126>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801e25:	83 ec 0c             	sub    $0xc,%esp
  801e28:	ff 75 e0             	pushl  -0x20(%ebp)
  801e2b:	e8 c4 f5 ff ff       	call   8013f4 <fd2data>
  801e30:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801e37:	50                   	push   %eax
  801e38:	6a 00                	push   $0x0
  801e3a:	56                   	push   %esi
  801e3b:	6a 00                	push   $0x0
  801e3d:	e8 5e f3 ff ff       	call   8011a0 <sys_page_map>
  801e42:	89 c3                	mov    %eax,%ebx
  801e44:	83 c4 20             	add    $0x20,%esp
  801e47:	85 c0                	test   %eax,%eax
  801e49:	78 4f                	js     801e9a <pipe+0x118>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801e4b:	8b 15 24 30 80 00    	mov    0x803024,%edx
  801e51:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801e54:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801e56:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801e59:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801e60:	8b 15 24 30 80 00    	mov    0x803024,%edx
  801e66:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801e69:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801e6b:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801e6e:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801e75:	83 ec 0c             	sub    $0xc,%esp
  801e78:	ff 75 e4             	pushl  -0x1c(%ebp)
  801e7b:	e8 64 f5 ff ff       	call   8013e4 <fd2num>
  801e80:	89 07                	mov    %eax,(%edi)
	pfd[1] = fd2num(fd1);
  801e82:	83 c4 04             	add    $0x4,%esp
  801e85:	ff 75 e0             	pushl  -0x20(%ebp)
  801e88:	e8 57 f5 ff ff       	call   8013e4 <fd2num>
  801e8d:	89 47 04             	mov    %eax,0x4(%edi)
	return 0;
  801e90:	83 c4 10             	add    $0x10,%esp
  801e93:	bb 00 00 00 00       	mov    $0x0,%ebx
  801e98:	eb 2e                	jmp    801ec8 <pipe+0x146>

    err3:
	sys_page_unmap(0, va);
  801e9a:	83 ec 08             	sub    $0x8,%esp
  801e9d:	56                   	push   %esi
  801e9e:	6a 00                	push   $0x0
  801ea0:	e8 21 f3 ff ff       	call   8011c6 <sys_page_unmap>
  801ea5:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801ea8:	83 ec 08             	sub    $0x8,%esp
  801eab:	ff 75 e0             	pushl  -0x20(%ebp)
  801eae:	6a 00                	push   $0x0
  801eb0:	e8 11 f3 ff ff       	call   8011c6 <sys_page_unmap>
  801eb5:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801eb8:	83 ec 08             	sub    $0x8,%esp
  801ebb:	ff 75 e4             	pushl  -0x1c(%ebp)
  801ebe:	6a 00                	push   $0x0
  801ec0:	e8 01 f3 ff ff       	call   8011c6 <sys_page_unmap>
  801ec5:	83 c4 10             	add    $0x10,%esp
    err:
	return r;
}
  801ec8:	89 d8                	mov    %ebx,%eax
  801eca:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801ecd:	5b                   	pop    %ebx
  801ece:	5e                   	pop    %esi
  801ecf:	5f                   	pop    %edi
  801ed0:	c9                   	leave  
  801ed1:	c3                   	ret    

00801ed2 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801ed2:	55                   	push   %ebp
  801ed3:	89 e5                	mov    %esp,%ebp
  801ed5:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801ed8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801edb:	50                   	push   %eax
  801edc:	ff 75 08             	pushl  0x8(%ebp)
  801edf:	e8 9b f5 ff ff       	call   80147f <fd_lookup>
  801ee4:	83 c4 10             	add    $0x10,%esp
  801ee7:	85 c0                	test   %eax,%eax
  801ee9:	78 18                	js     801f03 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801eeb:	83 ec 0c             	sub    $0xc,%esp
  801eee:	ff 75 f4             	pushl  -0xc(%ebp)
  801ef1:	e8 fe f4 ff ff       	call   8013f4 <fd2data>
	return _pipeisclosed(fd, p);
  801ef6:	89 c2                	mov    %eax,%edx
  801ef8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801efb:	e8 0c fd ff ff       	call   801c0c <_pipeisclosed>
  801f00:	83 c4 10             	add    $0x10,%esp
}
  801f03:	c9                   	leave  
  801f04:	c3                   	ret    
  801f05:	00 00                	add    %al,(%eax)
	...

00801f08 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801f08:	55                   	push   %ebp
  801f09:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801f0b:	b8 00 00 00 00       	mov    $0x0,%eax
  801f10:	c9                   	leave  
  801f11:	c3                   	ret    

00801f12 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801f12:	55                   	push   %ebp
  801f13:	89 e5                	mov    %esp,%ebp
  801f15:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801f18:	68 6a 2b 80 00       	push   $0x802b6a
  801f1d:	ff 75 0c             	pushl  0xc(%ebp)
  801f20:	e8 d5 ed ff ff       	call   800cfa <strcpy>
	return 0;
}
  801f25:	b8 00 00 00 00       	mov    $0x0,%eax
  801f2a:	c9                   	leave  
  801f2b:	c3                   	ret    

00801f2c <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801f2c:	55                   	push   %ebp
  801f2d:	89 e5                	mov    %esp,%ebp
  801f2f:	57                   	push   %edi
  801f30:	56                   	push   %esi
  801f31:	53                   	push   %ebx
  801f32:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801f38:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801f3c:	74 45                	je     801f83 <devcons_write+0x57>
  801f3e:	b8 00 00 00 00       	mov    $0x0,%eax
  801f43:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801f48:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801f4e:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801f51:	29 c3                	sub    %eax,%ebx
		if (m > sizeof(buf) - 1)
  801f53:	83 fb 7f             	cmp    $0x7f,%ebx
  801f56:	76 05                	jbe    801f5d <devcons_write+0x31>
			m = sizeof(buf) - 1;
  801f58:	bb 7f 00 00 00       	mov    $0x7f,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  801f5d:	83 ec 04             	sub    $0x4,%esp
  801f60:	53                   	push   %ebx
  801f61:	03 45 0c             	add    0xc(%ebp),%eax
  801f64:	50                   	push   %eax
  801f65:	57                   	push   %edi
  801f66:	e8 50 ef ff ff       	call   800ebb <memmove>
		sys_cputs(buf, m);
  801f6b:	83 c4 08             	add    $0x8,%esp
  801f6e:	53                   	push   %ebx
  801f6f:	57                   	push   %edi
  801f70:	e8 50 f1 ff ff       	call   8010c5 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801f75:	01 de                	add    %ebx,%esi
  801f77:	89 f0                	mov    %esi,%eax
  801f79:	83 c4 10             	add    $0x10,%esp
  801f7c:	3b 75 10             	cmp    0x10(%ebp),%esi
  801f7f:	72 cd                	jb     801f4e <devcons_write+0x22>
  801f81:	eb 05                	jmp    801f88 <devcons_write+0x5c>
  801f83:	be 00 00 00 00       	mov    $0x0,%esi
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801f88:	89 f0                	mov    %esi,%eax
  801f8a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801f8d:	5b                   	pop    %ebx
  801f8e:	5e                   	pop    %esi
  801f8f:	5f                   	pop    %edi
  801f90:	c9                   	leave  
  801f91:	c3                   	ret    

00801f92 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801f92:	55                   	push   %ebp
  801f93:	89 e5                	mov    %esp,%ebp
  801f95:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
  801f98:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801f9c:	75 07                	jne    801fa5 <devcons_read+0x13>
  801f9e:	eb 25                	jmp    801fc5 <devcons_read+0x33>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801fa0:	e8 b0 f1 ff ff       	call   801155 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801fa5:	e8 41 f1 ff ff       	call   8010eb <sys_cgetc>
  801faa:	85 c0                	test   %eax,%eax
  801fac:	74 f2                	je     801fa0 <devcons_read+0xe>
  801fae:	89 c2                	mov    %eax,%edx
		sys_yield();
	if (c < 0)
  801fb0:	85 c0                	test   %eax,%eax
  801fb2:	78 1d                	js     801fd1 <devcons_read+0x3f>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801fb4:	83 f8 04             	cmp    $0x4,%eax
  801fb7:	74 13                	je     801fcc <devcons_read+0x3a>
		return 0;
	*(char*)vbuf = c;
  801fb9:	8b 45 0c             	mov    0xc(%ebp),%eax
  801fbc:	88 10                	mov    %dl,(%eax)
	return 1;
  801fbe:	b8 01 00 00 00       	mov    $0x1,%eax
  801fc3:	eb 0c                	jmp    801fd1 <devcons_read+0x3f>
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
		return 0;
  801fc5:	b8 00 00 00 00       	mov    $0x0,%eax
  801fca:	eb 05                	jmp    801fd1 <devcons_read+0x3f>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801fcc:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801fd1:	c9                   	leave  
  801fd2:	c3                   	ret    

00801fd3 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801fd3:	55                   	push   %ebp
  801fd4:	89 e5                	mov    %esp,%ebp
  801fd6:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801fd9:	8b 45 08             	mov    0x8(%ebp),%eax
  801fdc:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801fdf:	6a 01                	push   $0x1
  801fe1:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801fe4:	50                   	push   %eax
  801fe5:	e8 db f0 ff ff       	call   8010c5 <sys_cputs>
  801fea:	83 c4 10             	add    $0x10,%esp
}
  801fed:	c9                   	leave  
  801fee:	c3                   	ret    

00801fef <getchar>:

int
getchar(void)
{
  801fef:	55                   	push   %ebp
  801ff0:	89 e5                	mov    %esp,%ebp
  801ff2:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801ff5:	6a 01                	push   $0x1
  801ff7:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801ffa:	50                   	push   %eax
  801ffb:	6a 00                	push   $0x0
  801ffd:	e8 fe f6 ff ff       	call   801700 <read>
	if (r < 0)
  802002:	83 c4 10             	add    $0x10,%esp
  802005:	85 c0                	test   %eax,%eax
  802007:	78 0f                	js     802018 <getchar+0x29>
		return r;
	if (r < 1)
  802009:	85 c0                	test   %eax,%eax
  80200b:	7e 06                	jle    802013 <getchar+0x24>
		return -E_EOF;
	return c;
  80200d:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  802011:	eb 05                	jmp    802018 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  802013:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  802018:	c9                   	leave  
  802019:	c3                   	ret    

0080201a <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  80201a:	55                   	push   %ebp
  80201b:	89 e5                	mov    %esp,%ebp
  80201d:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802020:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802023:	50                   	push   %eax
  802024:	ff 75 08             	pushl  0x8(%ebp)
  802027:	e8 53 f4 ff ff       	call   80147f <fd_lookup>
  80202c:	83 c4 10             	add    $0x10,%esp
  80202f:	85 c0                	test   %eax,%eax
  802031:	78 11                	js     802044 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  802033:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802036:	8b 15 40 30 80 00    	mov    0x803040,%edx
  80203c:	39 10                	cmp    %edx,(%eax)
  80203e:	0f 94 c0             	sete   %al
  802041:	0f b6 c0             	movzbl %al,%eax
}
  802044:	c9                   	leave  
  802045:	c3                   	ret    

00802046 <opencons>:

int
opencons(void)
{
  802046:	55                   	push   %ebp
  802047:	89 e5                	mov    %esp,%ebp
  802049:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  80204c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80204f:	50                   	push   %eax
  802050:	e8 b7 f3 ff ff       	call   80140c <fd_alloc>
  802055:	83 c4 10             	add    $0x10,%esp
  802058:	85 c0                	test   %eax,%eax
  80205a:	78 3a                	js     802096 <opencons+0x50>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  80205c:	83 ec 04             	sub    $0x4,%esp
  80205f:	68 07 04 00 00       	push   $0x407
  802064:	ff 75 f4             	pushl  -0xc(%ebp)
  802067:	6a 00                	push   $0x0
  802069:	e8 0e f1 ff ff       	call   80117c <sys_page_alloc>
  80206e:	83 c4 10             	add    $0x10,%esp
  802071:	85 c0                	test   %eax,%eax
  802073:	78 21                	js     802096 <opencons+0x50>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  802075:	8b 15 40 30 80 00    	mov    0x803040,%edx
  80207b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80207e:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  802080:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802083:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  80208a:	83 ec 0c             	sub    $0xc,%esp
  80208d:	50                   	push   %eax
  80208e:	e8 51 f3 ff ff       	call   8013e4 <fd2num>
  802093:	83 c4 10             	add    $0x10,%esp
}
  802096:	c9                   	leave  
  802097:	c3                   	ret    

00802098 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802098:	55                   	push   %ebp
  802099:	89 e5                	mov    %esp,%ebp
  80209b:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  80209e:	89 c2                	mov    %eax,%edx
  8020a0:	c1 ea 16             	shr    $0x16,%edx
  8020a3:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8020aa:	f6 c2 01             	test   $0x1,%dl
  8020ad:	74 1e                	je     8020cd <pageref+0x35>
		return 0;
	pte = uvpt[PGNUM(v)];
  8020af:	c1 e8 0c             	shr    $0xc,%eax
  8020b2:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  8020b9:	a8 01                	test   $0x1,%al
  8020bb:	74 17                	je     8020d4 <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  8020bd:	c1 e8 0c             	shr    $0xc,%eax
  8020c0:	66 8b 04 c5 04 00 00 	mov    -0x10fffffc(,%eax,8),%ax
  8020c7:	ef 
  8020c8:	0f b7 c0             	movzwl %ax,%eax
  8020cb:	eb 0c                	jmp    8020d9 <pageref+0x41>
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
		return 0;
  8020cd:	b8 00 00 00 00       	mov    $0x0,%eax
  8020d2:	eb 05                	jmp    8020d9 <pageref+0x41>
	pte = uvpt[PGNUM(v)];
	if (!(pte & PTE_P))
		return 0;
  8020d4:	b8 00 00 00 00       	mov    $0x0,%eax
	return pages[PGNUM(pte)].pp_ref;
}
  8020d9:	c9                   	leave  
  8020da:	c3                   	ret    
	...

008020dc <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  8020dc:	55                   	push   %ebp
  8020dd:	89 e5                	mov    %esp,%ebp
  8020df:	57                   	push   %edi
  8020e0:	56                   	push   %esi
  8020e1:	83 ec 10             	sub    $0x10,%esp
  8020e4:	8b 7d 08             	mov    0x8(%ebp),%edi
  8020e7:	8b 4d 10             	mov    0x10(%ebp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  8020ea:	89 7d f0             	mov    %edi,-0x10(%ebp)
  8020ed:	8b 75 0c             	mov    0xc(%ebp),%esi
  const DWunion dd = {.ll = d};
  8020f0:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  8020f3:	8b 45 14             	mov    0x14(%ebp),%eax
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  8020f6:	85 c0                	test   %eax,%eax
  8020f8:	75 2e                	jne    802128 <__udivdi3+0x4c>
    {
      if (d0 > n1)
  8020fa:	39 f1                	cmp    %esi,%ecx
  8020fc:	77 5a                	ja     802158 <__udivdi3+0x7c>
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  8020fe:	85 c9                	test   %ecx,%ecx
  802100:	75 0b                	jne    80210d <__udivdi3+0x31>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  802102:	b8 01 00 00 00       	mov    $0x1,%eax
  802107:	31 d2                	xor    %edx,%edx
  802109:	f7 f1                	div    %ecx
  80210b:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  80210d:	31 d2                	xor    %edx,%edx
  80210f:	89 f0                	mov    %esi,%eax
  802111:	f7 f1                	div    %ecx
  802113:	89 c6                	mov    %eax,%esi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  802115:	89 f8                	mov    %edi,%eax
  802117:	f7 f1                	div    %ecx
  802119:	89 c7                	mov    %eax,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  80211b:	89 f8                	mov    %edi,%eax
  80211d:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  80211f:	83 c4 10             	add    $0x10,%esp
  802122:	5e                   	pop    %esi
  802123:	5f                   	pop    %edi
  802124:	c9                   	leave  
  802125:	c3                   	ret    
  802126:	66 90                	xchg   %ax,%ax
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  802128:	39 f0                	cmp    %esi,%eax
  80212a:	77 1c                	ja     802148 <__udivdi3+0x6c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  80212c:	0f bd f8             	bsr    %eax,%edi
	  if (bm == 0)
  80212f:	83 f7 1f             	xor    $0x1f,%edi
  802132:	75 3c                	jne    802170 <__udivdi3+0x94>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  802134:	39 f0                	cmp    %esi,%eax
  802136:	0f 82 90 00 00 00    	jb     8021cc <__udivdi3+0xf0>
  80213c:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80213f:	39 55 f4             	cmp    %edx,-0xc(%ebp)
  802142:	0f 86 84 00 00 00    	jbe    8021cc <__udivdi3+0xf0>
  802148:	31 f6                	xor    %esi,%esi
  80214a:	31 ff                	xor    %edi,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  80214c:	89 f8                	mov    %edi,%eax
  80214e:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  802150:	83 c4 10             	add    $0x10,%esp
  802153:	5e                   	pop    %esi
  802154:	5f                   	pop    %edi
  802155:	c9                   	leave  
  802156:	c3                   	ret    
  802157:	90                   	nop
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  802158:	89 f2                	mov    %esi,%edx
  80215a:	89 f8                	mov    %edi,%eax
  80215c:	f7 f1                	div    %ecx
  80215e:	89 c7                	mov    %eax,%edi
  802160:	31 f6                	xor    %esi,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  802162:	89 f8                	mov    %edi,%eax
  802164:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  802166:	83 c4 10             	add    $0x10,%esp
  802169:	5e                   	pop    %esi
  80216a:	5f                   	pop    %edi
  80216b:	c9                   	leave  
  80216c:	c3                   	ret    
  80216d:	8d 76 00             	lea    0x0(%esi),%esi
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  802170:	89 f9                	mov    %edi,%ecx
  802172:	d3 e0                	shl    %cl,%eax
  802174:	89 45 e8             	mov    %eax,-0x18(%ebp)
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  802177:	b8 20 00 00 00       	mov    $0x20,%eax
  80217c:	29 f8                	sub    %edi,%eax

	      d1 = (d1 << bm) | (d0 >> b);
  80217e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  802181:	88 c1                	mov    %al,%cl
  802183:	d3 ea                	shr    %cl,%edx
  802185:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  802188:	09 ca                	or     %ecx,%edx
  80218a:	89 55 ec             	mov    %edx,-0x14(%ebp)
	      d0 = d0 << bm;
  80218d:	8b 55 f4             	mov    -0xc(%ebp),%edx
  802190:	89 f9                	mov    %edi,%ecx
  802192:	d3 e2                	shl    %cl,%edx
  802194:	89 55 f4             	mov    %edx,-0xc(%ebp)
	      n2 = n1 >> b;
  802197:	89 f2                	mov    %esi,%edx
  802199:	88 c1                	mov    %al,%cl
  80219b:	d3 ea                	shr    %cl,%edx
  80219d:	89 55 e8             	mov    %edx,-0x18(%ebp)
	      n1 = (n1 << bm) | (n0 >> b);
  8021a0:	89 f2                	mov    %esi,%edx
  8021a2:	89 f9                	mov    %edi,%ecx
  8021a4:	d3 e2                	shl    %cl,%edx
  8021a6:	8b 75 f0             	mov    -0x10(%ebp),%esi
  8021a9:	88 c1                	mov    %al,%cl
  8021ab:	d3 ee                	shr    %cl,%esi
  8021ad:	09 d6                	or     %edx,%esi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  8021af:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  8021b2:	89 f0                	mov    %esi,%eax
  8021b4:	89 ca                	mov    %ecx,%edx
  8021b6:	f7 75 ec             	divl   -0x14(%ebp)
  8021b9:	89 d1                	mov    %edx,%ecx
  8021bb:	89 c6                	mov    %eax,%esi
	      umul_ppmm (m1, m0, q0, d0);
  8021bd:	f7 65 f4             	mull   -0xc(%ebp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  8021c0:	39 d1                	cmp    %edx,%ecx
  8021c2:	72 28                	jb     8021ec <__udivdi3+0x110>
  8021c4:	74 1a                	je     8021e0 <__udivdi3+0x104>
  8021c6:	89 f7                	mov    %esi,%edi
  8021c8:	31 f6                	xor    %esi,%esi
  8021ca:	eb 80                	jmp    80214c <__udivdi3+0x70>
	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  8021cc:	31 f6                	xor    %esi,%esi
  8021ce:	bf 01 00 00 00       	mov    $0x1,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  8021d3:	89 f8                	mov    %edi,%eax
  8021d5:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  8021d7:	83 c4 10             	add    $0x10,%esp
  8021da:	5e                   	pop    %esi
  8021db:	5f                   	pop    %edi
  8021dc:	c9                   	leave  
  8021dd:	c3                   	ret    
  8021de:	66 90                	xchg   %ax,%ax

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  8021e0:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8021e3:	89 f9                	mov    %edi,%ecx
  8021e5:	d3 e2                	shl    %cl,%edx

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  8021e7:	39 c2                	cmp    %eax,%edx
  8021e9:	73 db                	jae    8021c6 <__udivdi3+0xea>
  8021eb:	90                   	nop
		{
		  q0--;
  8021ec:	8d 7e ff             	lea    -0x1(%esi),%edi
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  8021ef:	31 f6                	xor    %esi,%esi
  8021f1:	e9 56 ff ff ff       	jmp    80214c <__udivdi3+0x70>
	...

008021f8 <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  8021f8:	55                   	push   %ebp
  8021f9:	89 e5                	mov    %esp,%ebp
  8021fb:	57                   	push   %edi
  8021fc:	56                   	push   %esi
  8021fd:	83 ec 20             	sub    $0x20,%esp
  802200:	8b 45 08             	mov    0x8(%ebp),%eax
  802203:	8b 4d 10             	mov    0x10(%ebp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  802206:	89 45 e8             	mov    %eax,-0x18(%ebp)
  802209:	8b 75 0c             	mov    0xc(%ebp),%esi
  const DWunion dd = {.ll = d};
  80220c:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  80220f:	8b 7d 14             	mov    0x14(%ebp),%edi
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  802212:	89 45 f0             	mov    %eax,-0x10(%ebp)
  n1 = nn.s.high;
  802215:	89 f2                	mov    %esi,%edx

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  802217:	85 ff                	test   %edi,%edi
  802219:	75 15                	jne    802230 <__umoddi3+0x38>
    {
      if (d0 > n1)
  80221b:	39 f1                	cmp    %esi,%ecx
  80221d:	0f 86 99 00 00 00    	jbe    8022bc <__umoddi3+0xc4>
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  802223:	f7 f1                	div    %ecx

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
  802225:	89 d0                	mov    %edx,%eax
  802227:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  802229:	83 c4 20             	add    $0x20,%esp
  80222c:	5e                   	pop    %esi
  80222d:	5f                   	pop    %edi
  80222e:	c9                   	leave  
  80222f:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  802230:	39 f7                	cmp    %esi,%edi
  802232:	0f 87 a4 00 00 00    	ja     8022dc <__umoddi3+0xe4>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  802238:	0f bd c7             	bsr    %edi,%eax
	  if (bm == 0)
  80223b:	83 f0 1f             	xor    $0x1f,%eax
  80223e:	89 45 ec             	mov    %eax,-0x14(%ebp)
  802241:	0f 84 a1 00 00 00    	je     8022e8 <__umoddi3+0xf0>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  802247:	89 f8                	mov    %edi,%eax
  802249:	8a 4d ec             	mov    -0x14(%ebp),%cl
  80224c:	d3 e0                	shl    %cl,%eax
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  80224e:	bf 20 00 00 00       	mov    $0x20,%edi
  802253:	2b 7d ec             	sub    -0x14(%ebp),%edi

	      d1 = (d1 << bm) | (d0 >> b);
  802256:	8b 55 f4             	mov    -0xc(%ebp),%edx
  802259:	89 f9                	mov    %edi,%ecx
  80225b:	d3 ea                	shr    %cl,%edx
  80225d:	09 c2                	or     %eax,%edx
  80225f:	89 55 f0             	mov    %edx,-0x10(%ebp)
	      d0 = d0 << bm;
  802262:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802265:	8a 4d ec             	mov    -0x14(%ebp),%cl
  802268:	d3 e0                	shl    %cl,%eax
  80226a:	89 45 f4             	mov    %eax,-0xc(%ebp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  80226d:	89 f2                	mov    %esi,%edx
  80226f:	d3 e2                	shl    %cl,%edx
	      n0 = n0 << bm;
  802271:	8b 45 e8             	mov    -0x18(%ebp),%eax
  802274:	d3 e0                	shl    %cl,%eax
  802276:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  802279:	8b 45 e8             	mov    -0x18(%ebp),%eax
  80227c:	89 f9                	mov    %edi,%ecx
  80227e:	d3 e8                	shr    %cl,%eax
  802280:	09 d0                	or     %edx,%eax

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  802282:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  802284:	89 f2                	mov    %esi,%edx
  802286:	f7 75 f0             	divl   -0x10(%ebp)
  802289:	89 d6                	mov    %edx,%esi
	      umul_ppmm (m1, m0, q0, d0);
  80228b:	f7 65 f4             	mull   -0xc(%ebp)
  80228e:	89 55 e8             	mov    %edx,-0x18(%ebp)
  802291:	89 c1                	mov    %eax,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  802293:	39 d6                	cmp    %edx,%esi
  802295:	72 71                	jb     802308 <__umoddi3+0x110>
  802297:	74 7f                	je     802318 <__umoddi3+0x120>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  802299:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80229c:	29 c8                	sub    %ecx,%eax
  80229e:	19 d6                	sbb    %edx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
  8022a0:	8a 4d ec             	mov    -0x14(%ebp),%cl
  8022a3:	d3 e8                	shr    %cl,%eax
  8022a5:	89 f2                	mov    %esi,%edx
  8022a7:	89 f9                	mov    %edi,%ecx
  8022a9:	d3 e2                	shl    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
  8022ab:	09 d0                	or     %edx,%eax
  8022ad:	89 f2                	mov    %esi,%edx
  8022af:	8a 4d ec             	mov    -0x14(%ebp),%cl
  8022b2:	d3 ea                	shr    %cl,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  8022b4:	83 c4 20             	add    $0x20,%esp
  8022b7:	5e                   	pop    %esi
  8022b8:	5f                   	pop    %edi
  8022b9:	c9                   	leave  
  8022ba:	c3                   	ret    
  8022bb:	90                   	nop
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  8022bc:	85 c9                	test   %ecx,%ecx
  8022be:	75 0b                	jne    8022cb <__umoddi3+0xd3>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  8022c0:	b8 01 00 00 00       	mov    $0x1,%eax
  8022c5:	31 d2                	xor    %edx,%edx
  8022c7:	f7 f1                	div    %ecx
  8022c9:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  8022cb:	89 f0                	mov    %esi,%eax
  8022cd:	31 d2                	xor    %edx,%edx
  8022cf:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  8022d1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8022d4:	f7 f1                	div    %ecx
  8022d6:	e9 4a ff ff ff       	jmp    802225 <__umoddi3+0x2d>
  8022db:	90                   	nop
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
  8022dc:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  8022de:	83 c4 20             	add    $0x20,%esp
  8022e1:	5e                   	pop    %esi
  8022e2:	5f                   	pop    %edi
  8022e3:	c9                   	leave  
  8022e4:	c3                   	ret    
  8022e5:	8d 76 00             	lea    0x0(%esi),%esi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  8022e8:	39 f7                	cmp    %esi,%edi
  8022ea:	72 05                	jb     8022f1 <__umoddi3+0xf9>
  8022ec:	3b 4d f0             	cmp    -0x10(%ebp),%ecx
  8022ef:	77 0c                	ja     8022fd <__umoddi3+0x105>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  8022f1:	89 f2                	mov    %esi,%edx
  8022f3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8022f6:	29 c8                	sub    %ecx,%eax
  8022f8:	19 fa                	sbb    %edi,%edx
  8022fa:	89 45 f0             	mov    %eax,-0x10(%ebp)

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
  8022fd:	8b 45 f0             	mov    -0x10(%ebp),%eax
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  802300:	83 c4 20             	add    $0x20,%esp
  802303:	5e                   	pop    %esi
  802304:	5f                   	pop    %edi
  802305:	c9                   	leave  
  802306:	c3                   	ret    
  802307:	90                   	nop
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  802308:	8b 55 e8             	mov    -0x18(%ebp),%edx
  80230b:	89 c1                	mov    %eax,%ecx
  80230d:	2b 4d f4             	sub    -0xc(%ebp),%ecx
  802310:	1b 55 f0             	sbb    -0x10(%ebp),%edx
  802313:	eb 84                	jmp    802299 <__umoddi3+0xa1>
  802315:	8d 76 00             	lea    0x0(%esi),%esi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  802318:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  80231b:	72 eb                	jb     802308 <__umoddi3+0x110>
  80231d:	89 f2                	mov    %esi,%edx
  80231f:	e9 75 ff ff ff       	jmp    802299 <__umoddi3+0xa1>
