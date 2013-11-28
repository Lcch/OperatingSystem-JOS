
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
  800055:	e8 54 13 00 00       	call   8013ae <ipc_find_env>
	ipc_send(fsenv, FSREQ_OPEN, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  80005a:	6a 07                	push   $0x7
  80005c:	68 00 50 80 00       	push   $0x805000
  800061:	6a 01                	push   $0x1
  800063:	50                   	push   %eax
  800064:	e8 f0 12 00 00       	call   801359 <ipc_send>
	return ipc_recv(NULL, FVA, NULL);
  800069:	83 c4 1c             	add    $0x1c,%esp
  80006c:	6a 00                	push   $0x0
  80006e:	68 00 c0 cc cc       	push   $0xccccc000
  800073:	6a 00                	push   $0x0
  800075:	e8 6a 12 00 00       	call   8012e4 <ipc_recv>
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
  800090:	b8 60 23 80 00       	mov    $0x802360,%eax
  800095:	e8 9a ff ff ff       	call   800034 <xopen>
  80009a:	85 c0                	test   %eax,%eax
  80009c:	79 17                	jns    8000b5 <umain+0x36>
  80009e:	83 f8 f5             	cmp    $0xfffffff5,%eax
  8000a1:	74 26                	je     8000c9 <umain+0x4a>
		panic("serve_open /not-found: %e", r);
  8000a3:	50                   	push   %eax
  8000a4:	68 6b 23 80 00       	push   $0x80236b
  8000a9:	6a 20                	push   $0x20
  8000ab:	68 85 23 80 00       	push   $0x802385
  8000b0:	e8 b7 05 00 00       	call   80066c <_panic>
	else if (r >= 0)
		panic("serve_open /not-found succeeded!");
  8000b5:	83 ec 04             	sub    $0x4,%esp
  8000b8:	68 20 25 80 00       	push   $0x802520
  8000bd:	6a 22                	push   $0x22
  8000bf:	68 85 23 80 00       	push   $0x802385
  8000c4:	e8 a3 05 00 00       	call   80066c <_panic>

	if ((r = xopen("/newmotd", O_RDONLY)) < 0)
  8000c9:	ba 00 00 00 00       	mov    $0x0,%edx
  8000ce:	b8 95 23 80 00       	mov    $0x802395,%eax
  8000d3:	e8 5c ff ff ff       	call   800034 <xopen>
  8000d8:	85 c0                	test   %eax,%eax
  8000da:	79 12                	jns    8000ee <umain+0x6f>
		panic("serve_open /newmotd: %e", r);
  8000dc:	50                   	push   %eax
  8000dd:	68 9e 23 80 00       	push   $0x80239e
  8000e2:	6a 25                	push   $0x25
  8000e4:	68 85 23 80 00       	push   $0x802385
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
  80010c:	68 44 25 80 00       	push   $0x802544
  800111:	6a 27                	push   $0x27
  800113:	68 85 23 80 00       	push   $0x802385
  800118:	e8 4f 05 00 00       	call   80066c <_panic>
	cprintf("serve_open is good\n");
  80011d:	83 ec 0c             	sub    $0xc,%esp
  800120:	68 b6 23 80 00       	push   $0x8023b6
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
  800147:	68 ca 23 80 00       	push   $0x8023ca
  80014c:	6a 2b                	push   $0x2b
  80014e:	68 85 23 80 00       	push   $0x802385
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
  800182:	68 74 25 80 00       	push   $0x802574
  800187:	6a 2d                	push   $0x2d
  800189:	68 85 23 80 00       	push   $0x802385
  80018e:	e8 d9 04 00 00       	call   80066c <_panic>
	cprintf("file_stat is good\n");
  800193:	83 ec 0c             	sub    $0xc,%esp
  800196:	68 d8 23 80 00       	push   $0x8023d8
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
  8001d2:	68 eb 23 80 00       	push   $0x8023eb
  8001d7:	6a 32                	push   $0x32
  8001d9:	68 85 23 80 00       	push   $0x802385
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
  800202:	68 f9 23 80 00       	push   $0x8023f9
  800207:	6a 34                	push   $0x34
  800209:	68 85 23 80 00       	push   $0x802385
  80020e:	e8 59 04 00 00       	call   80066c <_panic>
	cprintf("file_read is good\n");
  800213:	83 ec 0c             	sub    $0xc,%esp
  800216:	68 17 24 80 00       	push   $0x802417
  80021b:	e8 24 05 00 00       	call   800744 <cprintf>

	if ((r = devfile.dev_close(FVA)) < 0)
  800220:	c7 04 24 00 c0 cc cc 	movl   $0xccccc000,(%esp)
  800227:	ff 15 18 30 80 00    	call   *0x803018
  80022d:	83 c4 10             	add    $0x10,%esp
  800230:	85 c0                	test   %eax,%eax
  800232:	79 12                	jns    800246 <umain+0x1c7>
		panic("file_close: %e", r);
  800234:	50                   	push   %eax
  800235:	68 2a 24 80 00       	push   $0x80242a
  80023a:	6a 38                	push   $0x38
  80023c:	68 85 23 80 00       	push   $0x802385
  800241:	e8 26 04 00 00       	call   80066c <_panic>
	cprintf("file_close is good\n");
  800246:	83 ec 0c             	sub    $0xc,%esp
  800249:	68 39 24 80 00       	push   $0x802439
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
  800293:	68 9c 25 80 00       	push   $0x80259c
  800298:	6a 43                	push   $0x43
  80029a:	68 85 23 80 00       	push   $0x802385
  80029f:	e8 c8 03 00 00       	call   80066c <_panic>
	cprintf("stale fileid is good\n");
  8002a4:	83 ec 0c             	sub    $0xc,%esp
  8002a7:	68 4d 24 80 00       	push   $0x80244d
  8002ac:	e8 93 04 00 00       	call   800744 <cprintf>

	// Try writing
	if ((r = xopen("/new-file", O_RDWR|O_CREAT)) < 0)
  8002b1:	ba 02 01 00 00       	mov    $0x102,%edx
  8002b6:	b8 63 24 80 00       	mov    $0x802463,%eax
  8002bb:	e8 74 fd ff ff       	call   800034 <xopen>
  8002c0:	83 c4 10             	add    $0x10,%esp
  8002c3:	85 c0                	test   %eax,%eax
  8002c5:	79 12                	jns    8002d9 <umain+0x25a>
		panic("serve_open /new-file: %e", r);
  8002c7:	50                   	push   %eax
  8002c8:	68 6d 24 80 00       	push   $0x80246d
  8002cd:	6a 48                	push   $0x48
  8002cf:	68 85 23 80 00       	push   $0x802385
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
  800316:	68 86 24 80 00       	push   $0x802486
  80031b:	6a 4b                	push   $0x4b
  80031d:	68 85 23 80 00       	push   $0x802385
  800322:	e8 45 03 00 00       	call   80066c <_panic>
	cprintf("file_write is good\n");
  800327:	83 ec 0c             	sub    $0xc,%esp
  80032a:	68 95 24 80 00       	push   $0x802495
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
  800372:	68 d4 25 80 00       	push   $0x8025d4
  800377:	6a 51                	push   $0x51
  800379:	68 85 23 80 00       	push   $0x802385
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
  800399:	68 f4 25 80 00       	push   $0x8025f4
  80039e:	6a 53                	push   $0x53
  8003a0:	68 85 23 80 00       	push   $0x802385
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
  8003c9:	68 2c 26 80 00       	push   $0x80262c
  8003ce:	6a 55                	push   $0x55
  8003d0:	68 85 23 80 00       	push   $0x802385
  8003d5:	e8 92 02 00 00       	call   80066c <_panic>
	cprintf("file_read after file_write is good\n");
  8003da:	83 ec 0c             	sub    $0xc,%esp
  8003dd:	68 5c 26 80 00       	push   $0x80265c
  8003e2:	e8 5d 03 00 00       	call   800744 <cprintf>

	// Now we'll try out open
	if ((r = open("/not-found", O_RDONLY)) < 0 && r != -E_NOT_FOUND)
  8003e7:	83 c4 08             	add    $0x8,%esp
  8003ea:	6a 00                	push   $0x0
  8003ec:	68 60 23 80 00       	push   $0x802360
  8003f1:	e8 36 17 00 00       	call   801b2c <open>
  8003f6:	83 c4 10             	add    $0x10,%esp
  8003f9:	85 c0                	test   %eax,%eax
  8003fb:	79 17                	jns    800414 <umain+0x395>
  8003fd:	83 f8 f5             	cmp    $0xfffffff5,%eax
  800400:	74 26                	je     800428 <umain+0x3a9>
		panic("open /not-found: %e", r);
  800402:	50                   	push   %eax
  800403:	68 71 23 80 00       	push   $0x802371
  800408:	6a 5a                	push   $0x5a
  80040a:	68 85 23 80 00       	push   $0x802385
  80040f:	e8 58 02 00 00       	call   80066c <_panic>
	else if (r >= 0)
		panic("open /not-found succeeded!");
  800414:	83 ec 04             	sub    $0x4,%esp
  800417:	68 a9 24 80 00       	push   $0x8024a9
  80041c:	6a 5c                	push   $0x5c
  80041e:	68 85 23 80 00       	push   $0x802385
  800423:	e8 44 02 00 00       	call   80066c <_panic>

	if ((r = open("/newmotd", O_RDONLY)) < 0)
  800428:	83 ec 08             	sub    $0x8,%esp
  80042b:	6a 00                	push   $0x0
  80042d:	68 95 23 80 00       	push   $0x802395
  800432:	e8 f5 16 00 00       	call   801b2c <open>
  800437:	83 c4 10             	add    $0x10,%esp
  80043a:	85 c0                	test   %eax,%eax
  80043c:	79 12                	jns    800450 <umain+0x3d1>
		panic("open /newmotd: %e", r);
  80043e:	50                   	push   %eax
  80043f:	68 a4 23 80 00       	push   $0x8023a4
  800444:	6a 5f                	push   $0x5f
  800446:	68 85 23 80 00       	push   $0x802385
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
  80046c:	68 80 26 80 00       	push   $0x802680
  800471:	6a 62                	push   $0x62
  800473:	68 85 23 80 00       	push   $0x802385
  800478:	e8 ef 01 00 00       	call   80066c <_panic>
	cprintf("open is good\n");
  80047d:	83 ec 0c             	sub    $0xc,%esp
  800480:	68 bc 23 80 00       	push   $0x8023bc
  800485:	e8 ba 02 00 00       	call   800744 <cprintf>

	// Try files with indirect blocks
	if ((f = open("/big", O_WRONLY|O_CREAT)) < 0)
  80048a:	83 c4 08             	add    $0x8,%esp
  80048d:	68 01 01 00 00       	push   $0x101
  800492:	68 c4 24 80 00       	push   $0x8024c4
  800497:	e8 90 16 00 00       	call   801b2c <open>
  80049c:	89 85 44 fd ff ff    	mov    %eax,-0x2bc(%ebp)
  8004a2:	83 c4 10             	add    $0x10,%esp
  8004a5:	85 c0                	test   %eax,%eax
  8004a7:	79 12                	jns    8004bb <umain+0x43c>
		panic("creat /big: %e", f);
  8004a9:	50                   	push   %eax
  8004aa:	68 c9 24 80 00       	push   $0x8024c9
  8004af:	6a 67                	push   $0x67
  8004b1:	68 85 23 80 00       	push   $0x802385
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
  8004f2:	e8 0d 13 00 00       	call   801804 <write>
  8004f7:	83 c4 10             	add    $0x10,%esp
  8004fa:	85 c0                	test   %eax,%eax
  8004fc:	79 16                	jns    800514 <umain+0x495>
			panic("write /big@%d: %e", i, r);
  8004fe:	83 ec 0c             	sub    $0xc,%esp
  800501:	50                   	push   %eax
  800502:	56                   	push   %esi
  800503:	68 d8 24 80 00       	push   $0x8024d8
  800508:	6a 6c                	push   $0x6c
  80050a:	68 85 23 80 00       	push   $0x802385
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
  80052c:	e8 ba 10 00 00       	call   8015eb <close>

	if ((f = open("/big", O_RDONLY)) < 0)
  800531:	83 c4 08             	add    $0x8,%esp
  800534:	6a 00                	push   $0x0
  800536:	68 c4 24 80 00       	push   $0x8024c4
  80053b:	e8 ec 15 00 00       	call   801b2c <open>
  800540:	89 c6                	mov    %eax,%esi
  800542:	83 c4 10             	add    $0x10,%esp
  800545:	85 c0                	test   %eax,%eax
  800547:	79 12                	jns    80055b <umain+0x4dc>
		panic("open /big: %e", f);
  800549:	50                   	push   %eax
  80054a:	68 ea 24 80 00       	push   $0x8024ea
  80054f:	6a 71                	push   $0x71
  800551:	68 85 23 80 00       	push   $0x802385
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
  800572:	e8 38 12 00 00       	call   8017af <readn>
  800577:	83 c4 10             	add    $0x10,%esp
  80057a:	85 c0                	test   %eax,%eax
  80057c:	79 16                	jns    800594 <umain+0x515>
			panic("read /big@%d: %e", i, r);
  80057e:	83 ec 0c             	sub    $0xc,%esp
  800581:	50                   	push   %eax
  800582:	53                   	push   %ebx
  800583:	68 f8 24 80 00       	push   $0x8024f8
  800588:	6a 75                	push   $0x75
  80058a:	68 85 23 80 00       	push   $0x802385
  80058f:	e8 d8 00 00 00       	call   80066c <_panic>
		if (r != sizeof(buf))
  800594:	3d 00 02 00 00       	cmp    $0x200,%eax
  800599:	74 1b                	je     8005b6 <umain+0x537>
			panic("read /big from %d returned %d < %d bytes",
  80059b:	83 ec 08             	sub    $0x8,%esp
  80059e:	68 00 02 00 00       	push   $0x200
  8005a3:	50                   	push   %eax
  8005a4:	53                   	push   %ebx
  8005a5:	68 a8 26 80 00       	push   $0x8026a8
  8005aa:	6a 78                	push   $0x78
  8005ac:	68 85 23 80 00       	push   $0x802385
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
  8005c1:	68 d4 26 80 00       	push   $0x8026d4
  8005c6:	6a 7b                	push   $0x7b
  8005c8:	68 85 23 80 00       	push   $0x802385
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
  8005e4:	e8 02 10 00 00       	call   8015eb <close>
	cprintf("large file is good\n");
  8005e9:	c7 04 24 09 25 80 00 	movl   $0x802509,(%esp)
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
  800656:	e8 bb 0f 00 00       	call   801616 <close_all>
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
  80068a:	68 2c 27 80 00       	push   $0x80272c
  80068f:	e8 b0 00 00 00       	call   800744 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800694:	83 c4 18             	add    $0x18,%esp
  800697:	56                   	push   %esi
  800698:	ff 75 10             	pushl  0x10(%ebp)
  80069b:	e8 53 00 00 00       	call   8006f3 <vcprintf>
	cprintf("\n");
  8006a0:	c7 04 24 83 2b 80 00 	movl   $0x802b83,(%esp)
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
  8007ac:	e8 53 19 00 00       	call   802104 <__udivdi3>
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
  8007e8:	e8 33 1a 00 00       	call   802220 <__umoddi3>
  8007ed:	83 c4 14             	add    $0x14,%esp
  8007f0:	0f be 80 4f 27 80 00 	movsbl 0x80274f(%eax),%eax
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
  800934:	ff 24 85 a0 28 80 00 	jmp    *0x8028a0(,%eax,4)
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
  8009e0:	8b 04 85 00 2a 80 00 	mov    0x802a00(,%eax,4),%eax
  8009e7:	85 c0                	test   %eax,%eax
  8009e9:	75 1a                	jne    800a05 <vprintfmt+0x15c>
				printfmt(putch, putdat, "error %d", err);
  8009eb:	52                   	push   %edx
  8009ec:	68 67 27 80 00       	push   $0x802767
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
  800a06:	68 51 2b 80 00       	push   $0x802b51
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
  800a3c:	c7 45 d0 60 27 80 00 	movl   $0x802760,-0x30(%ebp)
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
  8010aa:	68 5f 2a 80 00       	push   $0x802a5f
  8010af:	6a 42                	push   $0x42
  8010b1:	68 7c 2a 80 00       	push   $0x802a7c
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

008012bc <sys_exec>:

int
sys_exec(uint32_t eip, uint32_t esp, void * ph, uint32_t elf_phnum)
{
  8012bc:	55                   	push   %ebp
  8012bd:	89 e5                	mov    %esp,%ebp
  8012bf:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_exec, 0, eip, esp, (uint32_t)ph, elf_phnum, 0);
  8012c2:	6a 00                	push   $0x0
  8012c4:	ff 75 14             	pushl  0x14(%ebp)
  8012c7:	ff 75 10             	pushl  0x10(%ebp)
  8012ca:	ff 75 0c             	pushl  0xc(%ebp)
  8012cd:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8012d0:	ba 00 00 00 00       	mov    $0x0,%edx
  8012d5:	b8 0f 00 00 00       	mov    $0xf,%eax
  8012da:	e8 99 fd ff ff       	call   801078 <syscall>
  8012df:	c9                   	leave  
  8012e0:	c3                   	ret    
  8012e1:	00 00                	add    %al,(%eax)
	...

008012e4 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8012e4:	55                   	push   %ebp
  8012e5:	89 e5                	mov    %esp,%ebp
  8012e7:	56                   	push   %esi
  8012e8:	53                   	push   %ebx
  8012e9:	8b 75 08             	mov    0x8(%ebp),%esi
  8012ec:	8b 45 0c             	mov    0xc(%ebp),%eax
  8012ef:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// cprintf("0x%x 0x%x 0x%x\n", (uint32_t)from_env_store, (uint32_t)pg, (uint32_t)perm_store);
	int r;
	if (pg != NULL) {
  8012f2:	85 c0                	test   %eax,%eax
  8012f4:	74 0e                	je     801304 <ipc_recv+0x20>
		r = sys_ipc_recv(pg);
  8012f6:	83 ec 0c             	sub    $0xc,%esp
  8012f9:	50                   	push   %eax
  8012fa:	e8 78 ff ff ff       	call   801277 <sys_ipc_recv>
  8012ff:	83 c4 10             	add    $0x10,%esp
  801302:	eb 10                	jmp    801314 <ipc_recv+0x30>
	} else {
		r = sys_ipc_recv((void *)UTOP);
  801304:	83 ec 0c             	sub    $0xc,%esp
  801307:	68 00 00 c0 ee       	push   $0xeec00000
  80130c:	e8 66 ff ff ff       	call   801277 <sys_ipc_recv>
  801311:	83 c4 10             	add    $0x10,%esp
	}

	if (r == 0) {
  801314:	85 c0                	test   %eax,%eax
  801316:	75 26                	jne    80133e <ipc_recv+0x5a>
		if (from_env_store != NULL) *from_env_store = thisenv->env_ipc_from;
  801318:	85 f6                	test   %esi,%esi
  80131a:	74 0a                	je     801326 <ipc_recv+0x42>
  80131c:	a1 04 40 80 00       	mov    0x804004,%eax
  801321:	8b 40 74             	mov    0x74(%eax),%eax
  801324:	89 06                	mov    %eax,(%esi)
		if (perm_store != NULL) *perm_store = thisenv->env_ipc_perm;
  801326:	85 db                	test   %ebx,%ebx
  801328:	74 0a                	je     801334 <ipc_recv+0x50>
  80132a:	a1 04 40 80 00       	mov    0x804004,%eax
  80132f:	8b 40 78             	mov    0x78(%eax),%eax
  801332:	89 03                	mov    %eax,(%ebx)
		return thisenv->env_ipc_value;
  801334:	a1 04 40 80 00       	mov    0x804004,%eax
  801339:	8b 40 70             	mov    0x70(%eax),%eax
  80133c:	eb 14                	jmp    801352 <ipc_recv+0x6e>
	} else {
		// fails;
		if (from_env_store != NULL) *from_env_store = 0;
  80133e:	85 f6                	test   %esi,%esi
  801340:	74 06                	je     801348 <ipc_recv+0x64>
  801342:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		if (perm_store != NULL) *perm_store = 0;
  801348:	85 db                	test   %ebx,%ebx
  80134a:	74 06                	je     801352 <ipc_recv+0x6e>
  80134c:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
		return r;
	}
}
  801352:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801355:	5b                   	pop    %ebx
  801356:	5e                   	pop    %esi
  801357:	c9                   	leave  
  801358:	c3                   	ret    

00801359 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801359:	55                   	push   %ebp
  80135a:	89 e5                	mov    %esp,%ebp
  80135c:	57                   	push   %edi
  80135d:	56                   	push   %esi
  80135e:	53                   	push   %ebx
  80135f:	83 ec 0c             	sub    $0xc,%esp
  801362:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801365:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801368:	8b 75 14             	mov    0x14(%ebp),%esi
	// LAB 4: Your code here.
	// int sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
	int r;
	if (pg == NULL) pg = (void *)UTOP;
  80136b:	85 db                	test   %ebx,%ebx
  80136d:	75 25                	jne    801394 <ipc_send+0x3b>
  80136f:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
  801374:	eb 1e                	jmp    801394 <ipc_send+0x3b>
	
	while ((r = sys_ipc_try_send(to_env, val, pg, perm)) != 0) {
		if (r == -E_IPC_NOT_RECV) {
  801376:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801379:	75 07                	jne    801382 <ipc_send+0x29>
			// cprintf("Try Again and Again....\n");
			sys_yield();
  80137b:	e8 d5 fd ff ff       	call   801155 <sys_yield>
  801380:	eb 12                	jmp    801394 <ipc_send+0x3b>
		} else {
			panic("ipc_send error %e\n", r);
  801382:	50                   	push   %eax
  801383:	68 8a 2a 80 00       	push   $0x802a8a
  801388:	6a 43                	push   $0x43
  80138a:	68 9d 2a 80 00       	push   $0x802a9d
  80138f:	e8 d8 f2 ff ff       	call   80066c <_panic>
	// LAB 4: Your code here.
	// int sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
	int r;
	if (pg == NULL) pg = (void *)UTOP;
	
	while ((r = sys_ipc_try_send(to_env, val, pg, perm)) != 0) {
  801394:	56                   	push   %esi
  801395:	53                   	push   %ebx
  801396:	57                   	push   %edi
  801397:	ff 75 08             	pushl  0x8(%ebp)
  80139a:	e8 b3 fe ff ff       	call   801252 <sys_ipc_try_send>
  80139f:	83 c4 10             	add    $0x10,%esp
  8013a2:	85 c0                	test   %eax,%eax
  8013a4:	75 d0                	jne    801376 <ipc_send+0x1d>
		} else {
			panic("ipc_send error %e\n", r);
		}
	}
	return;
}
  8013a6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8013a9:	5b                   	pop    %ebx
  8013aa:	5e                   	pop    %esi
  8013ab:	5f                   	pop    %edi
  8013ac:	c9                   	leave  
  8013ad:	c3                   	ret    

008013ae <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  8013ae:	55                   	push   %ebp
  8013af:	89 e5                	mov    %esp,%ebp
  8013b1:	53                   	push   %ebx
  8013b2:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	for (i = 0; i < NENV; i++)
		if (envs[i].env_type == type)
  8013b5:	39 1d 50 00 c0 ee    	cmp    %ebx,0xeec00050
  8013bb:	74 22                	je     8013df <ipc_find_env+0x31>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8013bd:	b8 01 00 00 00       	mov    $0x1,%eax
		if (envs[i].env_type == type)
  8013c2:	8d 0c 85 00 00 00 00 	lea    0x0(,%eax,4),%ecx
  8013c9:	89 c2                	mov    %eax,%edx
  8013cb:	c1 e2 07             	shl    $0x7,%edx
  8013ce:	29 ca                	sub    %ecx,%edx
  8013d0:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  8013d6:	8b 52 50             	mov    0x50(%edx),%edx
  8013d9:	39 da                	cmp    %ebx,%edx
  8013db:	75 1d                	jne    8013fa <ipc_find_env+0x4c>
  8013dd:	eb 05                	jmp    8013e4 <ipc_find_env+0x36>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8013df:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
			return envs[i].env_id;
  8013e4:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  8013eb:	c1 e0 07             	shl    $0x7,%eax
  8013ee:	29 d0                	sub    %edx,%eax
  8013f0:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  8013f5:	8b 40 40             	mov    0x40(%eax),%eax
  8013f8:	eb 0c                	jmp    801406 <ipc_find_env+0x58>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8013fa:	40                   	inc    %eax
  8013fb:	3d 00 04 00 00       	cmp    $0x400,%eax
  801400:	75 c0                	jne    8013c2 <ipc_find_env+0x14>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801402:	66 b8 00 00          	mov    $0x0,%ax
}
  801406:	5b                   	pop    %ebx
  801407:	c9                   	leave  
  801408:	c3                   	ret    
  801409:	00 00                	add    %al,(%eax)
	...

0080140c <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  80140c:	55                   	push   %ebp
  80140d:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80140f:	8b 45 08             	mov    0x8(%ebp),%eax
  801412:	05 00 00 00 30       	add    $0x30000000,%eax
  801417:	c1 e8 0c             	shr    $0xc,%eax
}
  80141a:	c9                   	leave  
  80141b:	c3                   	ret    

0080141c <fd2data>:

char*
fd2data(struct Fd *fd)
{
  80141c:	55                   	push   %ebp
  80141d:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  80141f:	ff 75 08             	pushl  0x8(%ebp)
  801422:	e8 e5 ff ff ff       	call   80140c <fd2num>
  801427:	83 c4 04             	add    $0x4,%esp
  80142a:	05 20 00 0d 00       	add    $0xd0020,%eax
  80142f:	c1 e0 0c             	shl    $0xc,%eax
}
  801432:	c9                   	leave  
  801433:	c3                   	ret    

00801434 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801434:	55                   	push   %ebp
  801435:	89 e5                	mov    %esp,%ebp
  801437:	53                   	push   %ebx
  801438:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  80143b:	a1 00 dd 7b ef       	mov    0xef7bdd00,%eax
  801440:	a8 01                	test   $0x1,%al
  801442:	74 34                	je     801478 <fd_alloc+0x44>
  801444:	a1 00 00 74 ef       	mov    0xef740000,%eax
  801449:	a8 01                	test   $0x1,%al
  80144b:	74 32                	je     80147f <fd_alloc+0x4b>
  80144d:	b8 00 10 00 d0       	mov    $0xd0001000,%eax
  801452:	89 c1                	mov    %eax,%ecx
  801454:	89 c2                	mov    %eax,%edx
  801456:	c1 ea 16             	shr    $0x16,%edx
  801459:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801460:	f6 c2 01             	test   $0x1,%dl
  801463:	74 1f                	je     801484 <fd_alloc+0x50>
  801465:	89 c2                	mov    %eax,%edx
  801467:	c1 ea 0c             	shr    $0xc,%edx
  80146a:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801471:	f6 c2 01             	test   $0x1,%dl
  801474:	75 17                	jne    80148d <fd_alloc+0x59>
  801476:	eb 0c                	jmp    801484 <fd_alloc+0x50>
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  801478:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
  80147d:	eb 05                	jmp    801484 <fd_alloc+0x50>
  80147f:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
  801484:	89 0b                	mov    %ecx,(%ebx)
			return 0;
  801486:	b8 00 00 00 00       	mov    $0x0,%eax
  80148b:	eb 17                	jmp    8014a4 <fd_alloc+0x70>
  80148d:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  801492:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  801497:	75 b9                	jne    801452 <fd_alloc+0x1e>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801499:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_MAX_OPEN;
  80149f:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8014a4:	5b                   	pop    %ebx
  8014a5:	c9                   	leave  
  8014a6:	c3                   	ret    

008014a7 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8014a7:	55                   	push   %ebp
  8014a8:	89 e5                	mov    %esp,%ebp
  8014aa:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8014ad:	83 f8 1f             	cmp    $0x1f,%eax
  8014b0:	77 36                	ja     8014e8 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8014b2:	05 00 00 0d 00       	add    $0xd0000,%eax
  8014b7:	c1 e0 0c             	shl    $0xc,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8014ba:	89 c2                	mov    %eax,%edx
  8014bc:	c1 ea 16             	shr    $0x16,%edx
  8014bf:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8014c6:	f6 c2 01             	test   $0x1,%dl
  8014c9:	74 24                	je     8014ef <fd_lookup+0x48>
  8014cb:	89 c2                	mov    %eax,%edx
  8014cd:	c1 ea 0c             	shr    $0xc,%edx
  8014d0:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8014d7:	f6 c2 01             	test   $0x1,%dl
  8014da:	74 1a                	je     8014f6 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8014dc:	8b 55 0c             	mov    0xc(%ebp),%edx
  8014df:	89 02                	mov    %eax,(%edx)
	return 0;
  8014e1:	b8 00 00 00 00       	mov    $0x0,%eax
  8014e6:	eb 13                	jmp    8014fb <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8014e8:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8014ed:	eb 0c                	jmp    8014fb <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8014ef:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8014f4:	eb 05                	jmp    8014fb <fd_lookup+0x54>
  8014f6:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  8014fb:	c9                   	leave  
  8014fc:	c3                   	ret    

008014fd <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8014fd:	55                   	push   %ebp
  8014fe:	89 e5                	mov    %esp,%ebp
  801500:	53                   	push   %ebx
  801501:	83 ec 04             	sub    $0x4,%esp
  801504:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801507:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
		if (devtab[i]->dev_id == dev_id) {
  80150a:	39 0d 08 30 80 00    	cmp    %ecx,0x803008
  801510:	74 0d                	je     80151f <dev_lookup+0x22>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801512:	b8 00 00 00 00       	mov    $0x0,%eax
  801517:	eb 14                	jmp    80152d <dev_lookup+0x30>
		if (devtab[i]->dev_id == dev_id) {
  801519:	39 0a                	cmp    %ecx,(%edx)
  80151b:	75 10                	jne    80152d <dev_lookup+0x30>
  80151d:	eb 05                	jmp    801524 <dev_lookup+0x27>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  80151f:	ba 08 30 80 00       	mov    $0x803008,%edx
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
  801524:	89 13                	mov    %edx,(%ebx)
			return 0;
  801526:	b8 00 00 00 00       	mov    $0x0,%eax
  80152b:	eb 31                	jmp    80155e <dev_lookup+0x61>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  80152d:	40                   	inc    %eax
  80152e:	8b 14 85 28 2b 80 00 	mov    0x802b28(,%eax,4),%edx
  801535:	85 d2                	test   %edx,%edx
  801537:	75 e0                	jne    801519 <dev_lookup+0x1c>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801539:	a1 04 40 80 00       	mov    0x804004,%eax
  80153e:	8b 40 48             	mov    0x48(%eax),%eax
  801541:	83 ec 04             	sub    $0x4,%esp
  801544:	51                   	push   %ecx
  801545:	50                   	push   %eax
  801546:	68 a8 2a 80 00       	push   $0x802aa8
  80154b:	e8 f4 f1 ff ff       	call   800744 <cprintf>
	*dev = 0;
  801550:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_INVAL;
  801556:	83 c4 10             	add    $0x10,%esp
  801559:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  80155e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801561:	c9                   	leave  
  801562:	c3                   	ret    

00801563 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  801563:	55                   	push   %ebp
  801564:	89 e5                	mov    %esp,%ebp
  801566:	56                   	push   %esi
  801567:	53                   	push   %ebx
  801568:	83 ec 20             	sub    $0x20,%esp
  80156b:	8b 75 08             	mov    0x8(%ebp),%esi
  80156e:	8a 45 0c             	mov    0xc(%ebp),%al
  801571:	88 45 e7             	mov    %al,-0x19(%ebp)
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801574:	56                   	push   %esi
  801575:	e8 92 fe ff ff       	call   80140c <fd2num>
  80157a:	8d 55 f4             	lea    -0xc(%ebp),%edx
  80157d:	89 14 24             	mov    %edx,(%esp)
  801580:	50                   	push   %eax
  801581:	e8 21 ff ff ff       	call   8014a7 <fd_lookup>
  801586:	89 c3                	mov    %eax,%ebx
  801588:	83 c4 08             	add    $0x8,%esp
  80158b:	85 c0                	test   %eax,%eax
  80158d:	78 05                	js     801594 <fd_close+0x31>
	    || fd != fd2)
  80158f:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801592:	74 0d                	je     8015a1 <fd_close+0x3e>
		return (must_exist ? r : 0);
  801594:	80 7d e7 00          	cmpb   $0x0,-0x19(%ebp)
  801598:	75 48                	jne    8015e2 <fd_close+0x7f>
  80159a:	bb 00 00 00 00       	mov    $0x0,%ebx
  80159f:	eb 41                	jmp    8015e2 <fd_close+0x7f>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8015a1:	83 ec 08             	sub    $0x8,%esp
  8015a4:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8015a7:	50                   	push   %eax
  8015a8:	ff 36                	pushl  (%esi)
  8015aa:	e8 4e ff ff ff       	call   8014fd <dev_lookup>
  8015af:	89 c3                	mov    %eax,%ebx
  8015b1:	83 c4 10             	add    $0x10,%esp
  8015b4:	85 c0                	test   %eax,%eax
  8015b6:	78 1c                	js     8015d4 <fd_close+0x71>
		if (dev->dev_close)
  8015b8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015bb:	8b 40 10             	mov    0x10(%eax),%eax
  8015be:	85 c0                	test   %eax,%eax
  8015c0:	74 0d                	je     8015cf <fd_close+0x6c>
			r = (*dev->dev_close)(fd);
  8015c2:	83 ec 0c             	sub    $0xc,%esp
  8015c5:	56                   	push   %esi
  8015c6:	ff d0                	call   *%eax
  8015c8:	89 c3                	mov    %eax,%ebx
  8015ca:	83 c4 10             	add    $0x10,%esp
  8015cd:	eb 05                	jmp    8015d4 <fd_close+0x71>
		else
			r = 0;
  8015cf:	bb 00 00 00 00       	mov    $0x0,%ebx
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8015d4:	83 ec 08             	sub    $0x8,%esp
  8015d7:	56                   	push   %esi
  8015d8:	6a 00                	push   $0x0
  8015da:	e8 e7 fb ff ff       	call   8011c6 <sys_page_unmap>
	return r;
  8015df:	83 c4 10             	add    $0x10,%esp
}
  8015e2:	89 d8                	mov    %ebx,%eax
  8015e4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8015e7:	5b                   	pop    %ebx
  8015e8:	5e                   	pop    %esi
  8015e9:	c9                   	leave  
  8015ea:	c3                   	ret    

008015eb <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8015eb:	55                   	push   %ebp
  8015ec:	89 e5                	mov    %esp,%ebp
  8015ee:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8015f1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015f4:	50                   	push   %eax
  8015f5:	ff 75 08             	pushl  0x8(%ebp)
  8015f8:	e8 aa fe ff ff       	call   8014a7 <fd_lookup>
  8015fd:	83 c4 08             	add    $0x8,%esp
  801600:	85 c0                	test   %eax,%eax
  801602:	78 10                	js     801614 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  801604:	83 ec 08             	sub    $0x8,%esp
  801607:	6a 01                	push   $0x1
  801609:	ff 75 f4             	pushl  -0xc(%ebp)
  80160c:	e8 52 ff ff ff       	call   801563 <fd_close>
  801611:	83 c4 10             	add    $0x10,%esp
}
  801614:	c9                   	leave  
  801615:	c3                   	ret    

00801616 <close_all>:

void
close_all(void)
{
  801616:	55                   	push   %ebp
  801617:	89 e5                	mov    %esp,%ebp
  801619:	53                   	push   %ebx
  80161a:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  80161d:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801622:	83 ec 0c             	sub    $0xc,%esp
  801625:	53                   	push   %ebx
  801626:	e8 c0 ff ff ff       	call   8015eb <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  80162b:	43                   	inc    %ebx
  80162c:	83 c4 10             	add    $0x10,%esp
  80162f:	83 fb 20             	cmp    $0x20,%ebx
  801632:	75 ee                	jne    801622 <close_all+0xc>
		close(i);
}
  801634:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801637:	c9                   	leave  
  801638:	c3                   	ret    

00801639 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801639:	55                   	push   %ebp
  80163a:	89 e5                	mov    %esp,%ebp
  80163c:	57                   	push   %edi
  80163d:	56                   	push   %esi
  80163e:	53                   	push   %ebx
  80163f:	83 ec 2c             	sub    $0x2c,%esp
  801642:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801645:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801648:	50                   	push   %eax
  801649:	ff 75 08             	pushl  0x8(%ebp)
  80164c:	e8 56 fe ff ff       	call   8014a7 <fd_lookup>
  801651:	89 c3                	mov    %eax,%ebx
  801653:	83 c4 08             	add    $0x8,%esp
  801656:	85 c0                	test   %eax,%eax
  801658:	0f 88 c0 00 00 00    	js     80171e <dup+0xe5>
		return r;
	close(newfdnum);
  80165e:	83 ec 0c             	sub    $0xc,%esp
  801661:	57                   	push   %edi
  801662:	e8 84 ff ff ff       	call   8015eb <close>

	newfd = INDEX2FD(newfdnum);
  801667:	8d b7 00 00 0d 00    	lea    0xd0000(%edi),%esi
  80166d:	c1 e6 0c             	shl    $0xc,%esi
	ova = fd2data(oldfd);
  801670:	83 c4 04             	add    $0x4,%esp
  801673:	ff 75 e4             	pushl  -0x1c(%ebp)
  801676:	e8 a1 fd ff ff       	call   80141c <fd2data>
  80167b:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  80167d:	89 34 24             	mov    %esi,(%esp)
  801680:	e8 97 fd ff ff       	call   80141c <fd2data>
  801685:	83 c4 10             	add    $0x10,%esp
  801688:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80168b:	89 d8                	mov    %ebx,%eax
  80168d:	c1 e8 16             	shr    $0x16,%eax
  801690:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801697:	a8 01                	test   $0x1,%al
  801699:	74 37                	je     8016d2 <dup+0x99>
  80169b:	89 d8                	mov    %ebx,%eax
  80169d:	c1 e8 0c             	shr    $0xc,%eax
  8016a0:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8016a7:	f6 c2 01             	test   $0x1,%dl
  8016aa:	74 26                	je     8016d2 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8016ac:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8016b3:	83 ec 0c             	sub    $0xc,%esp
  8016b6:	25 07 0e 00 00       	and    $0xe07,%eax
  8016bb:	50                   	push   %eax
  8016bc:	ff 75 d4             	pushl  -0x2c(%ebp)
  8016bf:	6a 00                	push   $0x0
  8016c1:	53                   	push   %ebx
  8016c2:	6a 00                	push   $0x0
  8016c4:	e8 d7 fa ff ff       	call   8011a0 <sys_page_map>
  8016c9:	89 c3                	mov    %eax,%ebx
  8016cb:	83 c4 20             	add    $0x20,%esp
  8016ce:	85 c0                	test   %eax,%eax
  8016d0:	78 2d                	js     8016ff <dup+0xc6>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8016d2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8016d5:	89 c2                	mov    %eax,%edx
  8016d7:	c1 ea 0c             	shr    $0xc,%edx
  8016da:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8016e1:	83 ec 0c             	sub    $0xc,%esp
  8016e4:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  8016ea:	52                   	push   %edx
  8016eb:	56                   	push   %esi
  8016ec:	6a 00                	push   $0x0
  8016ee:	50                   	push   %eax
  8016ef:	6a 00                	push   $0x0
  8016f1:	e8 aa fa ff ff       	call   8011a0 <sys_page_map>
  8016f6:	89 c3                	mov    %eax,%ebx
  8016f8:	83 c4 20             	add    $0x20,%esp
  8016fb:	85 c0                	test   %eax,%eax
  8016fd:	79 1d                	jns    80171c <dup+0xe3>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8016ff:	83 ec 08             	sub    $0x8,%esp
  801702:	56                   	push   %esi
  801703:	6a 00                	push   $0x0
  801705:	e8 bc fa ff ff       	call   8011c6 <sys_page_unmap>
	sys_page_unmap(0, nva);
  80170a:	83 c4 08             	add    $0x8,%esp
  80170d:	ff 75 d4             	pushl  -0x2c(%ebp)
  801710:	6a 00                	push   $0x0
  801712:	e8 af fa ff ff       	call   8011c6 <sys_page_unmap>
	return r;
  801717:	83 c4 10             	add    $0x10,%esp
  80171a:	eb 02                	jmp    80171e <dup+0xe5>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
		goto err;

	return newfdnum;
  80171c:	89 fb                	mov    %edi,%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  80171e:	89 d8                	mov    %ebx,%eax
  801720:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801723:	5b                   	pop    %ebx
  801724:	5e                   	pop    %esi
  801725:	5f                   	pop    %edi
  801726:	c9                   	leave  
  801727:	c3                   	ret    

00801728 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801728:	55                   	push   %ebp
  801729:	89 e5                	mov    %esp,%ebp
  80172b:	53                   	push   %ebx
  80172c:	83 ec 14             	sub    $0x14,%esp
  80172f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801732:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801735:	50                   	push   %eax
  801736:	53                   	push   %ebx
  801737:	e8 6b fd ff ff       	call   8014a7 <fd_lookup>
  80173c:	83 c4 08             	add    $0x8,%esp
  80173f:	85 c0                	test   %eax,%eax
  801741:	78 67                	js     8017aa <read+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801743:	83 ec 08             	sub    $0x8,%esp
  801746:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801749:	50                   	push   %eax
  80174a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80174d:	ff 30                	pushl  (%eax)
  80174f:	e8 a9 fd ff ff       	call   8014fd <dev_lookup>
  801754:	83 c4 10             	add    $0x10,%esp
  801757:	85 c0                	test   %eax,%eax
  801759:	78 4f                	js     8017aa <read+0x82>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80175b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80175e:	8b 50 08             	mov    0x8(%eax),%edx
  801761:	83 e2 03             	and    $0x3,%edx
  801764:	83 fa 01             	cmp    $0x1,%edx
  801767:	75 21                	jne    80178a <read+0x62>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801769:	a1 04 40 80 00       	mov    0x804004,%eax
  80176e:	8b 40 48             	mov    0x48(%eax),%eax
  801771:	83 ec 04             	sub    $0x4,%esp
  801774:	53                   	push   %ebx
  801775:	50                   	push   %eax
  801776:	68 ec 2a 80 00       	push   $0x802aec
  80177b:	e8 c4 ef ff ff       	call   800744 <cprintf>
		return -E_INVAL;
  801780:	83 c4 10             	add    $0x10,%esp
  801783:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801788:	eb 20                	jmp    8017aa <read+0x82>
	}
	if (!dev->dev_read)
  80178a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80178d:	8b 52 08             	mov    0x8(%edx),%edx
  801790:	85 d2                	test   %edx,%edx
  801792:	74 11                	je     8017a5 <read+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801794:	83 ec 04             	sub    $0x4,%esp
  801797:	ff 75 10             	pushl  0x10(%ebp)
  80179a:	ff 75 0c             	pushl  0xc(%ebp)
  80179d:	50                   	push   %eax
  80179e:	ff d2                	call   *%edx
  8017a0:	83 c4 10             	add    $0x10,%esp
  8017a3:	eb 05                	jmp    8017aa <read+0x82>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8017a5:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_read)(fd, buf, n);
}
  8017aa:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8017ad:	c9                   	leave  
  8017ae:	c3                   	ret    

008017af <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8017af:	55                   	push   %ebp
  8017b0:	89 e5                	mov    %esp,%ebp
  8017b2:	57                   	push   %edi
  8017b3:	56                   	push   %esi
  8017b4:	53                   	push   %ebx
  8017b5:	83 ec 0c             	sub    $0xc,%esp
  8017b8:	8b 7d 08             	mov    0x8(%ebp),%edi
  8017bb:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8017be:	85 f6                	test   %esi,%esi
  8017c0:	74 31                	je     8017f3 <readn+0x44>
  8017c2:	b8 00 00 00 00       	mov    $0x0,%eax
  8017c7:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = read(fdnum, (char*)buf + tot, n - tot);
  8017cc:	83 ec 04             	sub    $0x4,%esp
  8017cf:	89 f2                	mov    %esi,%edx
  8017d1:	29 c2                	sub    %eax,%edx
  8017d3:	52                   	push   %edx
  8017d4:	03 45 0c             	add    0xc(%ebp),%eax
  8017d7:	50                   	push   %eax
  8017d8:	57                   	push   %edi
  8017d9:	e8 4a ff ff ff       	call   801728 <read>
		if (m < 0)
  8017de:	83 c4 10             	add    $0x10,%esp
  8017e1:	85 c0                	test   %eax,%eax
  8017e3:	78 17                	js     8017fc <readn+0x4d>
			return m;
		if (m == 0)
  8017e5:	85 c0                	test   %eax,%eax
  8017e7:	74 11                	je     8017fa <readn+0x4b>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8017e9:	01 c3                	add    %eax,%ebx
  8017eb:	89 d8                	mov    %ebx,%eax
  8017ed:	39 f3                	cmp    %esi,%ebx
  8017ef:	72 db                	jb     8017cc <readn+0x1d>
  8017f1:	eb 09                	jmp    8017fc <readn+0x4d>
  8017f3:	b8 00 00 00 00       	mov    $0x0,%eax
  8017f8:	eb 02                	jmp    8017fc <readn+0x4d>
		m = read(fdnum, (char*)buf + tot, n - tot);
		if (m < 0)
			return m;
		if (m == 0)
  8017fa:	89 d8                	mov    %ebx,%eax
			break;
	}
	return tot;
}
  8017fc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8017ff:	5b                   	pop    %ebx
  801800:	5e                   	pop    %esi
  801801:	5f                   	pop    %edi
  801802:	c9                   	leave  
  801803:	c3                   	ret    

00801804 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801804:	55                   	push   %ebp
  801805:	89 e5                	mov    %esp,%ebp
  801807:	53                   	push   %ebx
  801808:	83 ec 14             	sub    $0x14,%esp
  80180b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80180e:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801811:	50                   	push   %eax
  801812:	53                   	push   %ebx
  801813:	e8 8f fc ff ff       	call   8014a7 <fd_lookup>
  801818:	83 c4 08             	add    $0x8,%esp
  80181b:	85 c0                	test   %eax,%eax
  80181d:	78 62                	js     801881 <write+0x7d>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80181f:	83 ec 08             	sub    $0x8,%esp
  801822:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801825:	50                   	push   %eax
  801826:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801829:	ff 30                	pushl  (%eax)
  80182b:	e8 cd fc ff ff       	call   8014fd <dev_lookup>
  801830:	83 c4 10             	add    $0x10,%esp
  801833:	85 c0                	test   %eax,%eax
  801835:	78 4a                	js     801881 <write+0x7d>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801837:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80183a:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80183e:	75 21                	jne    801861 <write+0x5d>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801840:	a1 04 40 80 00       	mov    0x804004,%eax
  801845:	8b 40 48             	mov    0x48(%eax),%eax
  801848:	83 ec 04             	sub    $0x4,%esp
  80184b:	53                   	push   %ebx
  80184c:	50                   	push   %eax
  80184d:	68 08 2b 80 00       	push   $0x802b08
  801852:	e8 ed ee ff ff       	call   800744 <cprintf>
		return -E_INVAL;
  801857:	83 c4 10             	add    $0x10,%esp
  80185a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80185f:	eb 20                	jmp    801881 <write+0x7d>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801861:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801864:	8b 52 0c             	mov    0xc(%edx),%edx
  801867:	85 d2                	test   %edx,%edx
  801869:	74 11                	je     80187c <write+0x78>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80186b:	83 ec 04             	sub    $0x4,%esp
  80186e:	ff 75 10             	pushl  0x10(%ebp)
  801871:	ff 75 0c             	pushl  0xc(%ebp)
  801874:	50                   	push   %eax
  801875:	ff d2                	call   *%edx
  801877:	83 c4 10             	add    $0x10,%esp
  80187a:	eb 05                	jmp    801881 <write+0x7d>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  80187c:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  801881:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801884:	c9                   	leave  
  801885:	c3                   	ret    

00801886 <seek>:

int
seek(int fdnum, off_t offset)
{
  801886:	55                   	push   %ebp
  801887:	89 e5                	mov    %esp,%ebp
  801889:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80188c:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80188f:	50                   	push   %eax
  801890:	ff 75 08             	pushl  0x8(%ebp)
  801893:	e8 0f fc ff ff       	call   8014a7 <fd_lookup>
  801898:	83 c4 08             	add    $0x8,%esp
  80189b:	85 c0                	test   %eax,%eax
  80189d:	78 0e                	js     8018ad <seek+0x27>
		return r;
	fd->fd_offset = offset;
  80189f:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8018a2:	8b 55 0c             	mov    0xc(%ebp),%edx
  8018a5:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8018a8:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8018ad:	c9                   	leave  
  8018ae:	c3                   	ret    

008018af <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8018af:	55                   	push   %ebp
  8018b0:	89 e5                	mov    %esp,%ebp
  8018b2:	53                   	push   %ebx
  8018b3:	83 ec 14             	sub    $0x14,%esp
  8018b6:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8018b9:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8018bc:	50                   	push   %eax
  8018bd:	53                   	push   %ebx
  8018be:	e8 e4 fb ff ff       	call   8014a7 <fd_lookup>
  8018c3:	83 c4 08             	add    $0x8,%esp
  8018c6:	85 c0                	test   %eax,%eax
  8018c8:	78 5f                	js     801929 <ftruncate+0x7a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8018ca:	83 ec 08             	sub    $0x8,%esp
  8018cd:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8018d0:	50                   	push   %eax
  8018d1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8018d4:	ff 30                	pushl  (%eax)
  8018d6:	e8 22 fc ff ff       	call   8014fd <dev_lookup>
  8018db:	83 c4 10             	add    $0x10,%esp
  8018de:	85 c0                	test   %eax,%eax
  8018e0:	78 47                	js     801929 <ftruncate+0x7a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8018e2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8018e5:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8018e9:	75 21                	jne    80190c <ftruncate+0x5d>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8018eb:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8018f0:	8b 40 48             	mov    0x48(%eax),%eax
  8018f3:	83 ec 04             	sub    $0x4,%esp
  8018f6:	53                   	push   %ebx
  8018f7:	50                   	push   %eax
  8018f8:	68 c8 2a 80 00       	push   $0x802ac8
  8018fd:	e8 42 ee ff ff       	call   800744 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801902:	83 c4 10             	add    $0x10,%esp
  801905:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80190a:	eb 1d                	jmp    801929 <ftruncate+0x7a>
	}
	if (!dev->dev_trunc)
  80190c:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80190f:	8b 52 18             	mov    0x18(%edx),%edx
  801912:	85 d2                	test   %edx,%edx
  801914:	74 0e                	je     801924 <ftruncate+0x75>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801916:	83 ec 08             	sub    $0x8,%esp
  801919:	ff 75 0c             	pushl  0xc(%ebp)
  80191c:	50                   	push   %eax
  80191d:	ff d2                	call   *%edx
  80191f:	83 c4 10             	add    $0x10,%esp
  801922:	eb 05                	jmp    801929 <ftruncate+0x7a>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801924:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  801929:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80192c:	c9                   	leave  
  80192d:	c3                   	ret    

0080192e <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  80192e:	55                   	push   %ebp
  80192f:	89 e5                	mov    %esp,%ebp
  801931:	53                   	push   %ebx
  801932:	83 ec 14             	sub    $0x14,%esp
  801935:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801938:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80193b:	50                   	push   %eax
  80193c:	ff 75 08             	pushl  0x8(%ebp)
  80193f:	e8 63 fb ff ff       	call   8014a7 <fd_lookup>
  801944:	83 c4 08             	add    $0x8,%esp
  801947:	85 c0                	test   %eax,%eax
  801949:	78 52                	js     80199d <fstat+0x6f>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80194b:	83 ec 08             	sub    $0x8,%esp
  80194e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801951:	50                   	push   %eax
  801952:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801955:	ff 30                	pushl  (%eax)
  801957:	e8 a1 fb ff ff       	call   8014fd <dev_lookup>
  80195c:	83 c4 10             	add    $0x10,%esp
  80195f:	85 c0                	test   %eax,%eax
  801961:	78 3a                	js     80199d <fstat+0x6f>
		return r;
	if (!dev->dev_stat)
  801963:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801966:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  80196a:	74 2c                	je     801998 <fstat+0x6a>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  80196c:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  80196f:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801976:	00 00 00 
	stat->st_isdir = 0;
  801979:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801980:	00 00 00 
	stat->st_dev = dev;
  801983:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801989:	83 ec 08             	sub    $0x8,%esp
  80198c:	53                   	push   %ebx
  80198d:	ff 75 f0             	pushl  -0x10(%ebp)
  801990:	ff 50 14             	call   *0x14(%eax)
  801993:	83 c4 10             	add    $0x10,%esp
  801996:	eb 05                	jmp    80199d <fstat+0x6f>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801998:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  80199d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8019a0:	c9                   	leave  
  8019a1:	c3                   	ret    

008019a2 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8019a2:	55                   	push   %ebp
  8019a3:	89 e5                	mov    %esp,%ebp
  8019a5:	56                   	push   %esi
  8019a6:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8019a7:	83 ec 08             	sub    $0x8,%esp
  8019aa:	6a 00                	push   $0x0
  8019ac:	ff 75 08             	pushl  0x8(%ebp)
  8019af:	e8 78 01 00 00       	call   801b2c <open>
  8019b4:	89 c3                	mov    %eax,%ebx
  8019b6:	83 c4 10             	add    $0x10,%esp
  8019b9:	85 c0                	test   %eax,%eax
  8019bb:	78 1b                	js     8019d8 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8019bd:	83 ec 08             	sub    $0x8,%esp
  8019c0:	ff 75 0c             	pushl  0xc(%ebp)
  8019c3:	50                   	push   %eax
  8019c4:	e8 65 ff ff ff       	call   80192e <fstat>
  8019c9:	89 c6                	mov    %eax,%esi
	close(fd);
  8019cb:	89 1c 24             	mov    %ebx,(%esp)
  8019ce:	e8 18 fc ff ff       	call   8015eb <close>
	return r;
  8019d3:	83 c4 10             	add    $0x10,%esp
  8019d6:	89 f3                	mov    %esi,%ebx
}
  8019d8:	89 d8                	mov    %ebx,%eax
  8019da:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8019dd:	5b                   	pop    %ebx
  8019de:	5e                   	pop    %esi
  8019df:	c9                   	leave  
  8019e0:	c3                   	ret    
  8019e1:	00 00                	add    %al,(%eax)
	...

008019e4 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8019e4:	55                   	push   %ebp
  8019e5:	89 e5                	mov    %esp,%ebp
  8019e7:	56                   	push   %esi
  8019e8:	53                   	push   %ebx
  8019e9:	89 c3                	mov    %eax,%ebx
  8019eb:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  8019ed:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8019f4:	75 12                	jne    801a08 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8019f6:	83 ec 0c             	sub    $0xc,%esp
  8019f9:	6a 01                	push   $0x1
  8019fb:	e8 ae f9 ff ff       	call   8013ae <ipc_find_env>
  801a00:	a3 00 40 80 00       	mov    %eax,0x804000
  801a05:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801a08:	6a 07                	push   $0x7
  801a0a:	68 00 50 80 00       	push   $0x805000
  801a0f:	53                   	push   %ebx
  801a10:	ff 35 00 40 80 00    	pushl  0x804000
  801a16:	e8 3e f9 ff ff       	call   801359 <ipc_send>
	
	return ipc_recv(NULL, dstva, NULL);
  801a1b:	83 c4 0c             	add    $0xc,%esp
  801a1e:	6a 00                	push   $0x0
  801a20:	56                   	push   %esi
  801a21:	6a 00                	push   $0x0
  801a23:	e8 bc f8 ff ff       	call   8012e4 <ipc_recv>
}
  801a28:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a2b:	5b                   	pop    %ebx
  801a2c:	5e                   	pop    %esi
  801a2d:	c9                   	leave  
  801a2e:	c3                   	ret    

00801a2f <devfile_stat>:
}


static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801a2f:	55                   	push   %ebp
  801a30:	89 e5                	mov    %esp,%ebp
  801a32:	53                   	push   %ebx
  801a33:	83 ec 04             	sub    $0x4,%esp
  801a36:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801a39:	8b 45 08             	mov    0x8(%ebp),%eax
  801a3c:	8b 40 0c             	mov    0xc(%eax),%eax
  801a3f:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0) {
  801a44:	ba 00 00 00 00       	mov    $0x0,%edx
  801a49:	b8 05 00 00 00       	mov    $0x5,%eax
  801a4e:	e8 91 ff ff ff       	call   8019e4 <fsipc>
  801a53:	85 c0                	test   %eax,%eax
  801a55:	78 2c                	js     801a83 <devfile_stat+0x54>
		return r;
	}
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801a57:	83 ec 08             	sub    $0x8,%esp
  801a5a:	68 00 50 80 00       	push   $0x805000
  801a5f:	53                   	push   %ebx
  801a60:	e8 95 f2 ff ff       	call   800cfa <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801a65:	a1 80 50 80 00       	mov    0x805080,%eax
  801a6a:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801a70:	a1 84 50 80 00       	mov    0x805084,%eax
  801a75:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801a7b:	83 c4 10             	add    $0x10,%esp
  801a7e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801a83:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a86:	c9                   	leave  
  801a87:	c3                   	ret    

00801a88 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801a88:	55                   	push   %ebp
  801a89:	89 e5                	mov    %esp,%ebp
  801a8b:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801a8e:	8b 45 08             	mov    0x8(%ebp),%eax
  801a91:	8b 40 0c             	mov    0xc(%eax),%eax
  801a94:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801a99:	ba 00 00 00 00       	mov    $0x0,%edx
  801a9e:	b8 06 00 00 00       	mov    $0x6,%eax
  801aa3:	e8 3c ff ff ff       	call   8019e4 <fsipc>
}
  801aa8:	c9                   	leave  
  801aa9:	c3                   	ret    

00801aaa <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801aaa:	55                   	push   %ebp
  801aab:	89 e5                	mov    %esp,%ebp
  801aad:	56                   	push   %esi
  801aae:	53                   	push   %ebx
  801aaf:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801ab2:	8b 45 08             	mov    0x8(%ebp),%eax
  801ab5:	8b 40 0c             	mov    0xc(%eax),%eax
  801ab8:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801abd:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801ac3:	ba 00 00 00 00       	mov    $0x0,%edx
  801ac8:	b8 03 00 00 00       	mov    $0x3,%eax
  801acd:	e8 12 ff ff ff       	call   8019e4 <fsipc>
  801ad2:	89 c3                	mov    %eax,%ebx
  801ad4:	85 c0                	test   %eax,%eax
  801ad6:	78 4b                	js     801b23 <devfile_read+0x79>
		return r;
	assert(r <= n);
  801ad8:	39 c6                	cmp    %eax,%esi
  801ada:	73 16                	jae    801af2 <devfile_read+0x48>
  801adc:	68 38 2b 80 00       	push   $0x802b38
  801ae1:	68 3f 2b 80 00       	push   $0x802b3f
  801ae6:	6a 7d                	push   $0x7d
  801ae8:	68 54 2b 80 00       	push   $0x802b54
  801aed:	e8 7a eb ff ff       	call   80066c <_panic>
	assert(r <= PGSIZE);
  801af2:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801af7:	7e 16                	jle    801b0f <devfile_read+0x65>
  801af9:	68 5f 2b 80 00       	push   $0x802b5f
  801afe:	68 3f 2b 80 00       	push   $0x802b3f
  801b03:	6a 7e                	push   $0x7e
  801b05:	68 54 2b 80 00       	push   $0x802b54
  801b0a:	e8 5d eb ff ff       	call   80066c <_panic>
	memmove(buf, &fsipcbuf, r);
  801b0f:	83 ec 04             	sub    $0x4,%esp
  801b12:	50                   	push   %eax
  801b13:	68 00 50 80 00       	push   $0x805000
  801b18:	ff 75 0c             	pushl  0xc(%ebp)
  801b1b:	e8 9b f3 ff ff       	call   800ebb <memmove>
	return r;
  801b20:	83 c4 10             	add    $0x10,%esp
}
  801b23:	89 d8                	mov    %ebx,%eax
  801b25:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801b28:	5b                   	pop    %ebx
  801b29:	5e                   	pop    %esi
  801b2a:	c9                   	leave  
  801b2b:	c3                   	ret    

00801b2c <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801b2c:	55                   	push   %ebp
  801b2d:	89 e5                	mov    %esp,%ebp
  801b2f:	56                   	push   %esi
  801b30:	53                   	push   %ebx
  801b31:	83 ec 1c             	sub    $0x1c,%esp
  801b34:	8b 75 08             	mov    0x8(%ebp),%esi
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801b37:	56                   	push   %esi
  801b38:	e8 6b f1 ff ff       	call   800ca8 <strlen>
  801b3d:	83 c4 10             	add    $0x10,%esp
  801b40:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801b45:	7f 65                	jg     801bac <open+0x80>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801b47:	83 ec 0c             	sub    $0xc,%esp
  801b4a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801b4d:	50                   	push   %eax
  801b4e:	e8 e1 f8 ff ff       	call   801434 <fd_alloc>
  801b53:	89 c3                	mov    %eax,%ebx
  801b55:	83 c4 10             	add    $0x10,%esp
  801b58:	85 c0                	test   %eax,%eax
  801b5a:	78 55                	js     801bb1 <open+0x85>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801b5c:	83 ec 08             	sub    $0x8,%esp
  801b5f:	56                   	push   %esi
  801b60:	68 00 50 80 00       	push   $0x805000
  801b65:	e8 90 f1 ff ff       	call   800cfa <strcpy>
	fsipcbuf.open.req_omode = mode;
  801b6a:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b6d:	a3 00 54 80 00       	mov    %eax,0x805400



	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801b72:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801b75:	b8 01 00 00 00       	mov    $0x1,%eax
  801b7a:	e8 65 fe ff ff       	call   8019e4 <fsipc>
  801b7f:	89 c3                	mov    %eax,%ebx
  801b81:	83 c4 10             	add    $0x10,%esp
  801b84:	85 c0                	test   %eax,%eax
  801b86:	79 12                	jns    801b9a <open+0x6e>
		fd_close(fd, 0);
  801b88:	83 ec 08             	sub    $0x8,%esp
  801b8b:	6a 00                	push   $0x0
  801b8d:	ff 75 f4             	pushl  -0xc(%ebp)
  801b90:	e8 ce f9 ff ff       	call   801563 <fd_close>
		return r;
  801b95:	83 c4 10             	add    $0x10,%esp
  801b98:	eb 17                	jmp    801bb1 <open+0x85>
	}

	return fd2num(fd);
  801b9a:	83 ec 0c             	sub    $0xc,%esp
  801b9d:	ff 75 f4             	pushl  -0xc(%ebp)
  801ba0:	e8 67 f8 ff ff       	call   80140c <fd2num>
  801ba5:	89 c3                	mov    %eax,%ebx
  801ba7:	83 c4 10             	add    $0x10,%esp
  801baa:	eb 05                	jmp    801bb1 <open+0x85>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801bac:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801bb1:	89 d8                	mov    %ebx,%eax
  801bb3:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801bb6:	5b                   	pop    %ebx
  801bb7:	5e                   	pop    %esi
  801bb8:	c9                   	leave  
  801bb9:	c3                   	ret    
	...

00801bbc <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801bbc:	55                   	push   %ebp
  801bbd:	89 e5                	mov    %esp,%ebp
  801bbf:	56                   	push   %esi
  801bc0:	53                   	push   %ebx
  801bc1:	8b 75 0c             	mov    0xc(%ebp),%esi
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801bc4:	83 ec 0c             	sub    $0xc,%esp
  801bc7:	ff 75 08             	pushl  0x8(%ebp)
  801bca:	e8 4d f8 ff ff       	call   80141c <fd2data>
  801bcf:	89 c3                	mov    %eax,%ebx
	strcpy(stat->st_name, "<pipe>");
  801bd1:	83 c4 08             	add    $0x8,%esp
  801bd4:	68 6b 2b 80 00       	push   $0x802b6b
  801bd9:	56                   	push   %esi
  801bda:	e8 1b f1 ff ff       	call   800cfa <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801bdf:	8b 43 04             	mov    0x4(%ebx),%eax
  801be2:	2b 03                	sub    (%ebx),%eax
  801be4:	89 86 80 00 00 00    	mov    %eax,0x80(%esi)
	stat->st_isdir = 0;
  801bea:	c7 86 84 00 00 00 00 	movl   $0x0,0x84(%esi)
  801bf1:	00 00 00 
	stat->st_dev = &devpipe;
  801bf4:	c7 86 88 00 00 00 24 	movl   $0x803024,0x88(%esi)
  801bfb:	30 80 00 
	return 0;
}
  801bfe:	b8 00 00 00 00       	mov    $0x0,%eax
  801c03:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801c06:	5b                   	pop    %ebx
  801c07:	5e                   	pop    %esi
  801c08:	c9                   	leave  
  801c09:	c3                   	ret    

00801c0a <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801c0a:	55                   	push   %ebp
  801c0b:	89 e5                	mov    %esp,%ebp
  801c0d:	53                   	push   %ebx
  801c0e:	83 ec 0c             	sub    $0xc,%esp
  801c11:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801c14:	53                   	push   %ebx
  801c15:	6a 00                	push   $0x0
  801c17:	e8 aa f5 ff ff       	call   8011c6 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801c1c:	89 1c 24             	mov    %ebx,(%esp)
  801c1f:	e8 f8 f7 ff ff       	call   80141c <fd2data>
  801c24:	83 c4 08             	add    $0x8,%esp
  801c27:	50                   	push   %eax
  801c28:	6a 00                	push   $0x0
  801c2a:	e8 97 f5 ff ff       	call   8011c6 <sys_page_unmap>
}
  801c2f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801c32:	c9                   	leave  
  801c33:	c3                   	ret    

00801c34 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801c34:	55                   	push   %ebp
  801c35:	89 e5                	mov    %esp,%ebp
  801c37:	57                   	push   %edi
  801c38:	56                   	push   %esi
  801c39:	53                   	push   %ebx
  801c3a:	83 ec 1c             	sub    $0x1c,%esp
  801c3d:	89 c7                	mov    %eax,%edi
  801c3f:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801c42:	a1 04 40 80 00       	mov    0x804004,%eax
  801c47:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801c4a:	83 ec 0c             	sub    $0xc,%esp
  801c4d:	57                   	push   %edi
  801c4e:	e8 6d 04 00 00       	call   8020c0 <pageref>
  801c53:	89 c6                	mov    %eax,%esi
  801c55:	83 c4 04             	add    $0x4,%esp
  801c58:	ff 75 e4             	pushl  -0x1c(%ebp)
  801c5b:	e8 60 04 00 00       	call   8020c0 <pageref>
  801c60:	83 c4 10             	add    $0x10,%esp
  801c63:	39 c6                	cmp    %eax,%esi
  801c65:	0f 94 c0             	sete   %al
  801c68:	0f b6 c0             	movzbl %al,%eax
		nn = thisenv->env_runs;
  801c6b:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801c71:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801c74:	39 cb                	cmp    %ecx,%ebx
  801c76:	75 08                	jne    801c80 <_pipeisclosed+0x4c>
			return ret;
		if (n != nn && ret == 1)
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
	}
}
  801c78:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801c7b:	5b                   	pop    %ebx
  801c7c:	5e                   	pop    %esi
  801c7d:	5f                   	pop    %edi
  801c7e:	c9                   	leave  
  801c7f:	c3                   	ret    
		n = thisenv->env_runs;
		ret = pageref(fd) == pageref(p);
		nn = thisenv->env_runs;
		if (n == nn)
			return ret;
		if (n != nn && ret == 1)
  801c80:	83 f8 01             	cmp    $0x1,%eax
  801c83:	75 bd                	jne    801c42 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801c85:	8b 42 58             	mov    0x58(%edx),%eax
  801c88:	6a 01                	push   $0x1
  801c8a:	50                   	push   %eax
  801c8b:	53                   	push   %ebx
  801c8c:	68 72 2b 80 00       	push   $0x802b72
  801c91:	e8 ae ea ff ff       	call   800744 <cprintf>
  801c96:	83 c4 10             	add    $0x10,%esp
  801c99:	eb a7                	jmp    801c42 <_pipeisclosed+0xe>

00801c9b <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801c9b:	55                   	push   %ebp
  801c9c:	89 e5                	mov    %esp,%ebp
  801c9e:	57                   	push   %edi
  801c9f:	56                   	push   %esi
  801ca0:	53                   	push   %ebx
  801ca1:	83 ec 28             	sub    $0x28,%esp
  801ca4:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801ca7:	56                   	push   %esi
  801ca8:	e8 6f f7 ff ff       	call   80141c <fd2data>
  801cad:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801caf:	83 c4 10             	add    $0x10,%esp
  801cb2:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801cb6:	75 4a                	jne    801d02 <devpipe_write+0x67>
  801cb8:	bf 00 00 00 00       	mov    $0x0,%edi
  801cbd:	eb 56                	jmp    801d15 <devpipe_write+0x7a>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801cbf:	89 da                	mov    %ebx,%edx
  801cc1:	89 f0                	mov    %esi,%eax
  801cc3:	e8 6c ff ff ff       	call   801c34 <_pipeisclosed>
  801cc8:	85 c0                	test   %eax,%eax
  801cca:	75 4d                	jne    801d19 <devpipe_write+0x7e>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801ccc:	e8 84 f4 ff ff       	call   801155 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801cd1:	8b 43 04             	mov    0x4(%ebx),%eax
  801cd4:	8b 13                	mov    (%ebx),%edx
  801cd6:	83 c2 20             	add    $0x20,%edx
  801cd9:	39 d0                	cmp    %edx,%eax
  801cdb:	73 e2                	jae    801cbf <devpipe_write+0x24>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801cdd:	89 c2                	mov    %eax,%edx
  801cdf:	81 e2 1f 00 00 80    	and    $0x8000001f,%edx
  801ce5:	79 05                	jns    801cec <devpipe_write+0x51>
  801ce7:	4a                   	dec    %edx
  801ce8:	83 ca e0             	or     $0xffffffe0,%edx
  801ceb:	42                   	inc    %edx
  801cec:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801cef:	8a 0c 39             	mov    (%ecx,%edi,1),%cl
  801cf2:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801cf6:	40                   	inc    %eax
  801cf7:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801cfa:	47                   	inc    %edi
  801cfb:	39 7d 10             	cmp    %edi,0x10(%ebp)
  801cfe:	77 07                	ja     801d07 <devpipe_write+0x6c>
  801d00:	eb 13                	jmp    801d15 <devpipe_write+0x7a>
  801d02:	bf 00 00 00 00       	mov    $0x0,%edi
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801d07:	8b 43 04             	mov    0x4(%ebx),%eax
  801d0a:	8b 13                	mov    (%ebx),%edx
  801d0c:	83 c2 20             	add    $0x20,%edx
  801d0f:	39 d0                	cmp    %edx,%eax
  801d11:	73 ac                	jae    801cbf <devpipe_write+0x24>
  801d13:	eb c8                	jmp    801cdd <devpipe_write+0x42>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801d15:	89 f8                	mov    %edi,%eax
  801d17:	eb 05                	jmp    801d1e <devpipe_write+0x83>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801d19:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801d1e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801d21:	5b                   	pop    %ebx
  801d22:	5e                   	pop    %esi
  801d23:	5f                   	pop    %edi
  801d24:	c9                   	leave  
  801d25:	c3                   	ret    

00801d26 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801d26:	55                   	push   %ebp
  801d27:	89 e5                	mov    %esp,%ebp
  801d29:	57                   	push   %edi
  801d2a:	56                   	push   %esi
  801d2b:	53                   	push   %ebx
  801d2c:	83 ec 18             	sub    $0x18,%esp
  801d2f:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801d32:	57                   	push   %edi
  801d33:	e8 e4 f6 ff ff       	call   80141c <fd2data>
  801d38:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801d3a:	83 c4 10             	add    $0x10,%esp
  801d3d:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801d41:	75 44                	jne    801d87 <devpipe_read+0x61>
  801d43:	be 00 00 00 00       	mov    $0x0,%esi
  801d48:	eb 4f                	jmp    801d99 <devpipe_read+0x73>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
				return i;
  801d4a:	89 f0                	mov    %esi,%eax
  801d4c:	eb 54                	jmp    801da2 <devpipe_read+0x7c>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801d4e:	89 da                	mov    %ebx,%edx
  801d50:	89 f8                	mov    %edi,%eax
  801d52:	e8 dd fe ff ff       	call   801c34 <_pipeisclosed>
  801d57:	85 c0                	test   %eax,%eax
  801d59:	75 42                	jne    801d9d <devpipe_read+0x77>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801d5b:	e8 f5 f3 ff ff       	call   801155 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801d60:	8b 03                	mov    (%ebx),%eax
  801d62:	3b 43 04             	cmp    0x4(%ebx),%eax
  801d65:	74 e7                	je     801d4e <devpipe_read+0x28>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801d67:	25 1f 00 00 80       	and    $0x8000001f,%eax
  801d6c:	79 05                	jns    801d73 <devpipe_read+0x4d>
  801d6e:	48                   	dec    %eax
  801d6f:	83 c8 e0             	or     $0xffffffe0,%eax
  801d72:	40                   	inc    %eax
  801d73:	8a 44 03 08          	mov    0x8(%ebx,%eax,1),%al
  801d77:	8b 55 0c             	mov    0xc(%ebp),%edx
  801d7a:	88 04 32             	mov    %al,(%edx,%esi,1)
		p->p_rpos++;
  801d7d:	ff 03                	incl   (%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801d7f:	46                   	inc    %esi
  801d80:	39 75 10             	cmp    %esi,0x10(%ebp)
  801d83:	77 07                	ja     801d8c <devpipe_read+0x66>
  801d85:	eb 12                	jmp    801d99 <devpipe_read+0x73>
  801d87:	be 00 00 00 00       	mov    $0x0,%esi
		while (p->p_rpos == p->p_wpos) {
  801d8c:	8b 03                	mov    (%ebx),%eax
  801d8e:	3b 43 04             	cmp    0x4(%ebx),%eax
  801d91:	75 d4                	jne    801d67 <devpipe_read+0x41>
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801d93:	85 f6                	test   %esi,%esi
  801d95:	75 b3                	jne    801d4a <devpipe_read+0x24>
  801d97:	eb b5                	jmp    801d4e <devpipe_read+0x28>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801d99:	89 f0                	mov    %esi,%eax
  801d9b:	eb 05                	jmp    801da2 <devpipe_read+0x7c>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801d9d:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801da2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801da5:	5b                   	pop    %ebx
  801da6:	5e                   	pop    %esi
  801da7:	5f                   	pop    %edi
  801da8:	c9                   	leave  
  801da9:	c3                   	ret    

00801daa <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801daa:	55                   	push   %ebp
  801dab:	89 e5                	mov    %esp,%ebp
  801dad:	57                   	push   %edi
  801dae:	56                   	push   %esi
  801daf:	53                   	push   %ebx
  801db0:	83 ec 28             	sub    $0x28,%esp
  801db3:	8b 7d 08             	mov    0x8(%ebp),%edi
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801db6:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801db9:	50                   	push   %eax
  801dba:	e8 75 f6 ff ff       	call   801434 <fd_alloc>
  801dbf:	89 c3                	mov    %eax,%ebx
  801dc1:	83 c4 10             	add    $0x10,%esp
  801dc4:	85 c0                	test   %eax,%eax
  801dc6:	0f 88 24 01 00 00    	js     801ef0 <pipe+0x146>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801dcc:	83 ec 04             	sub    $0x4,%esp
  801dcf:	68 07 04 00 00       	push   $0x407
  801dd4:	ff 75 e4             	pushl  -0x1c(%ebp)
  801dd7:	6a 00                	push   $0x0
  801dd9:	e8 9e f3 ff ff       	call   80117c <sys_page_alloc>
  801dde:	89 c3                	mov    %eax,%ebx
  801de0:	83 c4 10             	add    $0x10,%esp
  801de3:	85 c0                	test   %eax,%eax
  801de5:	0f 88 05 01 00 00    	js     801ef0 <pipe+0x146>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801deb:	83 ec 0c             	sub    $0xc,%esp
  801dee:	8d 45 e0             	lea    -0x20(%ebp),%eax
  801df1:	50                   	push   %eax
  801df2:	e8 3d f6 ff ff       	call   801434 <fd_alloc>
  801df7:	89 c3                	mov    %eax,%ebx
  801df9:	83 c4 10             	add    $0x10,%esp
  801dfc:	85 c0                	test   %eax,%eax
  801dfe:	0f 88 dc 00 00 00    	js     801ee0 <pipe+0x136>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801e04:	83 ec 04             	sub    $0x4,%esp
  801e07:	68 07 04 00 00       	push   $0x407
  801e0c:	ff 75 e0             	pushl  -0x20(%ebp)
  801e0f:	6a 00                	push   $0x0
  801e11:	e8 66 f3 ff ff       	call   80117c <sys_page_alloc>
  801e16:	89 c3                	mov    %eax,%ebx
  801e18:	83 c4 10             	add    $0x10,%esp
  801e1b:	85 c0                	test   %eax,%eax
  801e1d:	0f 88 bd 00 00 00    	js     801ee0 <pipe+0x136>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801e23:	83 ec 0c             	sub    $0xc,%esp
  801e26:	ff 75 e4             	pushl  -0x1c(%ebp)
  801e29:	e8 ee f5 ff ff       	call   80141c <fd2data>
  801e2e:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801e30:	83 c4 0c             	add    $0xc,%esp
  801e33:	68 07 04 00 00       	push   $0x407
  801e38:	50                   	push   %eax
  801e39:	6a 00                	push   $0x0
  801e3b:	e8 3c f3 ff ff       	call   80117c <sys_page_alloc>
  801e40:	89 c3                	mov    %eax,%ebx
  801e42:	83 c4 10             	add    $0x10,%esp
  801e45:	85 c0                	test   %eax,%eax
  801e47:	0f 88 83 00 00 00    	js     801ed0 <pipe+0x126>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801e4d:	83 ec 0c             	sub    $0xc,%esp
  801e50:	ff 75 e0             	pushl  -0x20(%ebp)
  801e53:	e8 c4 f5 ff ff       	call   80141c <fd2data>
  801e58:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801e5f:	50                   	push   %eax
  801e60:	6a 00                	push   $0x0
  801e62:	56                   	push   %esi
  801e63:	6a 00                	push   $0x0
  801e65:	e8 36 f3 ff ff       	call   8011a0 <sys_page_map>
  801e6a:	89 c3                	mov    %eax,%ebx
  801e6c:	83 c4 20             	add    $0x20,%esp
  801e6f:	85 c0                	test   %eax,%eax
  801e71:	78 4f                	js     801ec2 <pipe+0x118>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801e73:	8b 15 24 30 80 00    	mov    0x803024,%edx
  801e79:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801e7c:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801e7e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801e81:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801e88:	8b 15 24 30 80 00    	mov    0x803024,%edx
  801e8e:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801e91:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801e93:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801e96:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801e9d:	83 ec 0c             	sub    $0xc,%esp
  801ea0:	ff 75 e4             	pushl  -0x1c(%ebp)
  801ea3:	e8 64 f5 ff ff       	call   80140c <fd2num>
  801ea8:	89 07                	mov    %eax,(%edi)
	pfd[1] = fd2num(fd1);
  801eaa:	83 c4 04             	add    $0x4,%esp
  801ead:	ff 75 e0             	pushl  -0x20(%ebp)
  801eb0:	e8 57 f5 ff ff       	call   80140c <fd2num>
  801eb5:	89 47 04             	mov    %eax,0x4(%edi)
	return 0;
  801eb8:	83 c4 10             	add    $0x10,%esp
  801ebb:	bb 00 00 00 00       	mov    $0x0,%ebx
  801ec0:	eb 2e                	jmp    801ef0 <pipe+0x146>

    err3:
	sys_page_unmap(0, va);
  801ec2:	83 ec 08             	sub    $0x8,%esp
  801ec5:	56                   	push   %esi
  801ec6:	6a 00                	push   $0x0
  801ec8:	e8 f9 f2 ff ff       	call   8011c6 <sys_page_unmap>
  801ecd:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801ed0:	83 ec 08             	sub    $0x8,%esp
  801ed3:	ff 75 e0             	pushl  -0x20(%ebp)
  801ed6:	6a 00                	push   $0x0
  801ed8:	e8 e9 f2 ff ff       	call   8011c6 <sys_page_unmap>
  801edd:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801ee0:	83 ec 08             	sub    $0x8,%esp
  801ee3:	ff 75 e4             	pushl  -0x1c(%ebp)
  801ee6:	6a 00                	push   $0x0
  801ee8:	e8 d9 f2 ff ff       	call   8011c6 <sys_page_unmap>
  801eed:	83 c4 10             	add    $0x10,%esp
    err:
	return r;
}
  801ef0:	89 d8                	mov    %ebx,%eax
  801ef2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801ef5:	5b                   	pop    %ebx
  801ef6:	5e                   	pop    %esi
  801ef7:	5f                   	pop    %edi
  801ef8:	c9                   	leave  
  801ef9:	c3                   	ret    

00801efa <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801efa:	55                   	push   %ebp
  801efb:	89 e5                	mov    %esp,%ebp
  801efd:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801f00:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801f03:	50                   	push   %eax
  801f04:	ff 75 08             	pushl  0x8(%ebp)
  801f07:	e8 9b f5 ff ff       	call   8014a7 <fd_lookup>
  801f0c:	83 c4 10             	add    $0x10,%esp
  801f0f:	85 c0                	test   %eax,%eax
  801f11:	78 18                	js     801f2b <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801f13:	83 ec 0c             	sub    $0xc,%esp
  801f16:	ff 75 f4             	pushl  -0xc(%ebp)
  801f19:	e8 fe f4 ff ff       	call   80141c <fd2data>
	return _pipeisclosed(fd, p);
  801f1e:	89 c2                	mov    %eax,%edx
  801f20:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f23:	e8 0c fd ff ff       	call   801c34 <_pipeisclosed>
  801f28:	83 c4 10             	add    $0x10,%esp
}
  801f2b:	c9                   	leave  
  801f2c:	c3                   	ret    
  801f2d:	00 00                	add    %al,(%eax)
	...

00801f30 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801f30:	55                   	push   %ebp
  801f31:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801f33:	b8 00 00 00 00       	mov    $0x0,%eax
  801f38:	c9                   	leave  
  801f39:	c3                   	ret    

00801f3a <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801f3a:	55                   	push   %ebp
  801f3b:	89 e5                	mov    %esp,%ebp
  801f3d:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801f40:	68 8a 2b 80 00       	push   $0x802b8a
  801f45:	ff 75 0c             	pushl  0xc(%ebp)
  801f48:	e8 ad ed ff ff       	call   800cfa <strcpy>
	return 0;
}
  801f4d:	b8 00 00 00 00       	mov    $0x0,%eax
  801f52:	c9                   	leave  
  801f53:	c3                   	ret    

00801f54 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801f54:	55                   	push   %ebp
  801f55:	89 e5                	mov    %esp,%ebp
  801f57:	57                   	push   %edi
  801f58:	56                   	push   %esi
  801f59:	53                   	push   %ebx
  801f5a:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801f60:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801f64:	74 45                	je     801fab <devcons_write+0x57>
  801f66:	b8 00 00 00 00       	mov    $0x0,%eax
  801f6b:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801f70:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801f76:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801f79:	29 c3                	sub    %eax,%ebx
		if (m > sizeof(buf) - 1)
  801f7b:	83 fb 7f             	cmp    $0x7f,%ebx
  801f7e:	76 05                	jbe    801f85 <devcons_write+0x31>
			m = sizeof(buf) - 1;
  801f80:	bb 7f 00 00 00       	mov    $0x7f,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  801f85:	83 ec 04             	sub    $0x4,%esp
  801f88:	53                   	push   %ebx
  801f89:	03 45 0c             	add    0xc(%ebp),%eax
  801f8c:	50                   	push   %eax
  801f8d:	57                   	push   %edi
  801f8e:	e8 28 ef ff ff       	call   800ebb <memmove>
		sys_cputs(buf, m);
  801f93:	83 c4 08             	add    $0x8,%esp
  801f96:	53                   	push   %ebx
  801f97:	57                   	push   %edi
  801f98:	e8 28 f1 ff ff       	call   8010c5 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801f9d:	01 de                	add    %ebx,%esi
  801f9f:	89 f0                	mov    %esi,%eax
  801fa1:	83 c4 10             	add    $0x10,%esp
  801fa4:	3b 75 10             	cmp    0x10(%ebp),%esi
  801fa7:	72 cd                	jb     801f76 <devcons_write+0x22>
  801fa9:	eb 05                	jmp    801fb0 <devcons_write+0x5c>
  801fab:	be 00 00 00 00       	mov    $0x0,%esi
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801fb0:	89 f0                	mov    %esi,%eax
  801fb2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801fb5:	5b                   	pop    %ebx
  801fb6:	5e                   	pop    %esi
  801fb7:	5f                   	pop    %edi
  801fb8:	c9                   	leave  
  801fb9:	c3                   	ret    

00801fba <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801fba:	55                   	push   %ebp
  801fbb:	89 e5                	mov    %esp,%ebp
  801fbd:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
  801fc0:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801fc4:	75 07                	jne    801fcd <devcons_read+0x13>
  801fc6:	eb 25                	jmp    801fed <devcons_read+0x33>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801fc8:	e8 88 f1 ff ff       	call   801155 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801fcd:	e8 19 f1 ff ff       	call   8010eb <sys_cgetc>
  801fd2:	85 c0                	test   %eax,%eax
  801fd4:	74 f2                	je     801fc8 <devcons_read+0xe>
  801fd6:	89 c2                	mov    %eax,%edx
		sys_yield();
	if (c < 0)
  801fd8:	85 c0                	test   %eax,%eax
  801fda:	78 1d                	js     801ff9 <devcons_read+0x3f>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801fdc:	83 f8 04             	cmp    $0x4,%eax
  801fdf:	74 13                	je     801ff4 <devcons_read+0x3a>
		return 0;
	*(char*)vbuf = c;
  801fe1:	8b 45 0c             	mov    0xc(%ebp),%eax
  801fe4:	88 10                	mov    %dl,(%eax)
	return 1;
  801fe6:	b8 01 00 00 00       	mov    $0x1,%eax
  801feb:	eb 0c                	jmp    801ff9 <devcons_read+0x3f>
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
		return 0;
  801fed:	b8 00 00 00 00       	mov    $0x0,%eax
  801ff2:	eb 05                	jmp    801ff9 <devcons_read+0x3f>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801ff4:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801ff9:	c9                   	leave  
  801ffa:	c3                   	ret    

00801ffb <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801ffb:	55                   	push   %ebp
  801ffc:	89 e5                	mov    %esp,%ebp
  801ffe:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  802001:	8b 45 08             	mov    0x8(%ebp),%eax
  802004:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  802007:	6a 01                	push   $0x1
  802009:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80200c:	50                   	push   %eax
  80200d:	e8 b3 f0 ff ff       	call   8010c5 <sys_cputs>
  802012:	83 c4 10             	add    $0x10,%esp
}
  802015:	c9                   	leave  
  802016:	c3                   	ret    

00802017 <getchar>:

int
getchar(void)
{
  802017:	55                   	push   %ebp
  802018:	89 e5                	mov    %esp,%ebp
  80201a:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  80201d:	6a 01                	push   $0x1
  80201f:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802022:	50                   	push   %eax
  802023:	6a 00                	push   $0x0
  802025:	e8 fe f6 ff ff       	call   801728 <read>
	if (r < 0)
  80202a:	83 c4 10             	add    $0x10,%esp
  80202d:	85 c0                	test   %eax,%eax
  80202f:	78 0f                	js     802040 <getchar+0x29>
		return r;
	if (r < 1)
  802031:	85 c0                	test   %eax,%eax
  802033:	7e 06                	jle    80203b <getchar+0x24>
		return -E_EOF;
	return c;
  802035:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  802039:	eb 05                	jmp    802040 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  80203b:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  802040:	c9                   	leave  
  802041:	c3                   	ret    

00802042 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  802042:	55                   	push   %ebp
  802043:	89 e5                	mov    %esp,%ebp
  802045:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802048:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80204b:	50                   	push   %eax
  80204c:	ff 75 08             	pushl  0x8(%ebp)
  80204f:	e8 53 f4 ff ff       	call   8014a7 <fd_lookup>
  802054:	83 c4 10             	add    $0x10,%esp
  802057:	85 c0                	test   %eax,%eax
  802059:	78 11                	js     80206c <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  80205b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80205e:	8b 15 40 30 80 00    	mov    0x803040,%edx
  802064:	39 10                	cmp    %edx,(%eax)
  802066:	0f 94 c0             	sete   %al
  802069:	0f b6 c0             	movzbl %al,%eax
}
  80206c:	c9                   	leave  
  80206d:	c3                   	ret    

0080206e <opencons>:

int
opencons(void)
{
  80206e:	55                   	push   %ebp
  80206f:	89 e5                	mov    %esp,%ebp
  802071:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  802074:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802077:	50                   	push   %eax
  802078:	e8 b7 f3 ff ff       	call   801434 <fd_alloc>
  80207d:	83 c4 10             	add    $0x10,%esp
  802080:	85 c0                	test   %eax,%eax
  802082:	78 3a                	js     8020be <opencons+0x50>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  802084:	83 ec 04             	sub    $0x4,%esp
  802087:	68 07 04 00 00       	push   $0x407
  80208c:	ff 75 f4             	pushl  -0xc(%ebp)
  80208f:	6a 00                	push   $0x0
  802091:	e8 e6 f0 ff ff       	call   80117c <sys_page_alloc>
  802096:	83 c4 10             	add    $0x10,%esp
  802099:	85 c0                	test   %eax,%eax
  80209b:	78 21                	js     8020be <opencons+0x50>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  80209d:	8b 15 40 30 80 00    	mov    0x803040,%edx
  8020a3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8020a6:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  8020a8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8020ab:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  8020b2:	83 ec 0c             	sub    $0xc,%esp
  8020b5:	50                   	push   %eax
  8020b6:	e8 51 f3 ff ff       	call   80140c <fd2num>
  8020bb:	83 c4 10             	add    $0x10,%esp
}
  8020be:	c9                   	leave  
  8020bf:	c3                   	ret    

008020c0 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  8020c0:	55                   	push   %ebp
  8020c1:	89 e5                	mov    %esp,%ebp
  8020c3:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8020c6:	89 c2                	mov    %eax,%edx
  8020c8:	c1 ea 16             	shr    $0x16,%edx
  8020cb:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8020d2:	f6 c2 01             	test   $0x1,%dl
  8020d5:	74 1e                	je     8020f5 <pageref+0x35>
		return 0;
	pte = uvpt[PGNUM(v)];
  8020d7:	c1 e8 0c             	shr    $0xc,%eax
  8020da:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  8020e1:	a8 01                	test   $0x1,%al
  8020e3:	74 17                	je     8020fc <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  8020e5:	c1 e8 0c             	shr    $0xc,%eax
  8020e8:	66 8b 04 c5 04 00 00 	mov    -0x10fffffc(,%eax,8),%ax
  8020ef:	ef 
  8020f0:	0f b7 c0             	movzwl %ax,%eax
  8020f3:	eb 0c                	jmp    802101 <pageref+0x41>
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
		return 0;
  8020f5:	b8 00 00 00 00       	mov    $0x0,%eax
  8020fa:	eb 05                	jmp    802101 <pageref+0x41>
	pte = uvpt[PGNUM(v)];
	if (!(pte & PTE_P))
		return 0;
  8020fc:	b8 00 00 00 00       	mov    $0x0,%eax
	return pages[PGNUM(pte)].pp_ref;
}
  802101:	c9                   	leave  
  802102:	c3                   	ret    
	...

00802104 <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  802104:	55                   	push   %ebp
  802105:	89 e5                	mov    %esp,%ebp
  802107:	57                   	push   %edi
  802108:	56                   	push   %esi
  802109:	83 ec 10             	sub    $0x10,%esp
  80210c:	8b 7d 08             	mov    0x8(%ebp),%edi
  80210f:	8b 4d 10             	mov    0x10(%ebp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  802112:	89 7d f0             	mov    %edi,-0x10(%ebp)
  802115:	8b 75 0c             	mov    0xc(%ebp),%esi
  const DWunion dd = {.ll = d};
  802118:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  80211b:	8b 45 14             	mov    0x14(%ebp),%eax
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  80211e:	85 c0                	test   %eax,%eax
  802120:	75 2e                	jne    802150 <__udivdi3+0x4c>
    {
      if (d0 > n1)
  802122:	39 f1                	cmp    %esi,%ecx
  802124:	77 5a                	ja     802180 <__udivdi3+0x7c>
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  802126:	85 c9                	test   %ecx,%ecx
  802128:	75 0b                	jne    802135 <__udivdi3+0x31>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  80212a:	b8 01 00 00 00       	mov    $0x1,%eax
  80212f:	31 d2                	xor    %edx,%edx
  802131:	f7 f1                	div    %ecx
  802133:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  802135:	31 d2                	xor    %edx,%edx
  802137:	89 f0                	mov    %esi,%eax
  802139:	f7 f1                	div    %ecx
  80213b:	89 c6                	mov    %eax,%esi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  80213d:	89 f8                	mov    %edi,%eax
  80213f:	f7 f1                	div    %ecx
  802141:	89 c7                	mov    %eax,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  802143:	89 f8                	mov    %edi,%eax
  802145:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  802147:	83 c4 10             	add    $0x10,%esp
  80214a:	5e                   	pop    %esi
  80214b:	5f                   	pop    %edi
  80214c:	c9                   	leave  
  80214d:	c3                   	ret    
  80214e:	66 90                	xchg   %ax,%ax
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  802150:	39 f0                	cmp    %esi,%eax
  802152:	77 1c                	ja     802170 <__udivdi3+0x6c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  802154:	0f bd f8             	bsr    %eax,%edi
	  if (bm == 0)
  802157:	83 f7 1f             	xor    $0x1f,%edi
  80215a:	75 3c                	jne    802198 <__udivdi3+0x94>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  80215c:	39 f0                	cmp    %esi,%eax
  80215e:	0f 82 90 00 00 00    	jb     8021f4 <__udivdi3+0xf0>
  802164:	8b 55 f0             	mov    -0x10(%ebp),%edx
  802167:	39 55 f4             	cmp    %edx,-0xc(%ebp)
  80216a:	0f 86 84 00 00 00    	jbe    8021f4 <__udivdi3+0xf0>
  802170:	31 f6                	xor    %esi,%esi
  802172:	31 ff                	xor    %edi,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  802174:	89 f8                	mov    %edi,%eax
  802176:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  802178:	83 c4 10             	add    $0x10,%esp
  80217b:	5e                   	pop    %esi
  80217c:	5f                   	pop    %edi
  80217d:	c9                   	leave  
  80217e:	c3                   	ret    
  80217f:	90                   	nop
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  802180:	89 f2                	mov    %esi,%edx
  802182:	89 f8                	mov    %edi,%eax
  802184:	f7 f1                	div    %ecx
  802186:	89 c7                	mov    %eax,%edi
  802188:	31 f6                	xor    %esi,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  80218a:	89 f8                	mov    %edi,%eax
  80218c:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  80218e:	83 c4 10             	add    $0x10,%esp
  802191:	5e                   	pop    %esi
  802192:	5f                   	pop    %edi
  802193:	c9                   	leave  
  802194:	c3                   	ret    
  802195:	8d 76 00             	lea    0x0(%esi),%esi
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  802198:	89 f9                	mov    %edi,%ecx
  80219a:	d3 e0                	shl    %cl,%eax
  80219c:	89 45 e8             	mov    %eax,-0x18(%ebp)
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  80219f:	b8 20 00 00 00       	mov    $0x20,%eax
  8021a4:	29 f8                	sub    %edi,%eax

	      d1 = (d1 << bm) | (d0 >> b);
  8021a6:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8021a9:	88 c1                	mov    %al,%cl
  8021ab:	d3 ea                	shr    %cl,%edx
  8021ad:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  8021b0:	09 ca                	or     %ecx,%edx
  8021b2:	89 55 ec             	mov    %edx,-0x14(%ebp)
	      d0 = d0 << bm;
  8021b5:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8021b8:	89 f9                	mov    %edi,%ecx
  8021ba:	d3 e2                	shl    %cl,%edx
  8021bc:	89 55 f4             	mov    %edx,-0xc(%ebp)
	      n2 = n1 >> b;
  8021bf:	89 f2                	mov    %esi,%edx
  8021c1:	88 c1                	mov    %al,%cl
  8021c3:	d3 ea                	shr    %cl,%edx
  8021c5:	89 55 e8             	mov    %edx,-0x18(%ebp)
	      n1 = (n1 << bm) | (n0 >> b);
  8021c8:	89 f2                	mov    %esi,%edx
  8021ca:	89 f9                	mov    %edi,%ecx
  8021cc:	d3 e2                	shl    %cl,%edx
  8021ce:	8b 75 f0             	mov    -0x10(%ebp),%esi
  8021d1:	88 c1                	mov    %al,%cl
  8021d3:	d3 ee                	shr    %cl,%esi
  8021d5:	09 d6                	or     %edx,%esi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  8021d7:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  8021da:	89 f0                	mov    %esi,%eax
  8021dc:	89 ca                	mov    %ecx,%edx
  8021de:	f7 75 ec             	divl   -0x14(%ebp)
  8021e1:	89 d1                	mov    %edx,%ecx
  8021e3:	89 c6                	mov    %eax,%esi
	      umul_ppmm (m1, m0, q0, d0);
  8021e5:	f7 65 f4             	mull   -0xc(%ebp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  8021e8:	39 d1                	cmp    %edx,%ecx
  8021ea:	72 28                	jb     802214 <__udivdi3+0x110>
  8021ec:	74 1a                	je     802208 <__udivdi3+0x104>
  8021ee:	89 f7                	mov    %esi,%edi
  8021f0:	31 f6                	xor    %esi,%esi
  8021f2:	eb 80                	jmp    802174 <__udivdi3+0x70>
	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  8021f4:	31 f6                	xor    %esi,%esi
  8021f6:	bf 01 00 00 00       	mov    $0x1,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  8021fb:	89 f8                	mov    %edi,%eax
  8021fd:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  8021ff:	83 c4 10             	add    $0x10,%esp
  802202:	5e                   	pop    %esi
  802203:	5f                   	pop    %edi
  802204:	c9                   	leave  
  802205:	c3                   	ret    
  802206:	66 90                	xchg   %ax,%ax

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  802208:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80220b:	89 f9                	mov    %edi,%ecx
  80220d:	d3 e2                	shl    %cl,%edx

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  80220f:	39 c2                	cmp    %eax,%edx
  802211:	73 db                	jae    8021ee <__udivdi3+0xea>
  802213:	90                   	nop
		{
		  q0--;
  802214:	8d 7e ff             	lea    -0x1(%esi),%edi
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  802217:	31 f6                	xor    %esi,%esi
  802219:	e9 56 ff ff ff       	jmp    802174 <__udivdi3+0x70>
	...

00802220 <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  802220:	55                   	push   %ebp
  802221:	89 e5                	mov    %esp,%ebp
  802223:	57                   	push   %edi
  802224:	56                   	push   %esi
  802225:	83 ec 20             	sub    $0x20,%esp
  802228:	8b 45 08             	mov    0x8(%ebp),%eax
  80222b:	8b 4d 10             	mov    0x10(%ebp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  80222e:	89 45 e8             	mov    %eax,-0x18(%ebp)
  802231:	8b 75 0c             	mov    0xc(%ebp),%esi
  const DWunion dd = {.ll = d};
  802234:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  802237:	8b 7d 14             	mov    0x14(%ebp),%edi
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  80223a:	89 45 f0             	mov    %eax,-0x10(%ebp)
  n1 = nn.s.high;
  80223d:	89 f2                	mov    %esi,%edx

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  80223f:	85 ff                	test   %edi,%edi
  802241:	75 15                	jne    802258 <__umoddi3+0x38>
    {
      if (d0 > n1)
  802243:	39 f1                	cmp    %esi,%ecx
  802245:	0f 86 99 00 00 00    	jbe    8022e4 <__umoddi3+0xc4>
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  80224b:	f7 f1                	div    %ecx

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
  80224d:	89 d0                	mov    %edx,%eax
  80224f:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  802251:	83 c4 20             	add    $0x20,%esp
  802254:	5e                   	pop    %esi
  802255:	5f                   	pop    %edi
  802256:	c9                   	leave  
  802257:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  802258:	39 f7                	cmp    %esi,%edi
  80225a:	0f 87 a4 00 00 00    	ja     802304 <__umoddi3+0xe4>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  802260:	0f bd c7             	bsr    %edi,%eax
	  if (bm == 0)
  802263:	83 f0 1f             	xor    $0x1f,%eax
  802266:	89 45 ec             	mov    %eax,-0x14(%ebp)
  802269:	0f 84 a1 00 00 00    	je     802310 <__umoddi3+0xf0>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  80226f:	89 f8                	mov    %edi,%eax
  802271:	8a 4d ec             	mov    -0x14(%ebp),%cl
  802274:	d3 e0                	shl    %cl,%eax
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  802276:	bf 20 00 00 00       	mov    $0x20,%edi
  80227b:	2b 7d ec             	sub    -0x14(%ebp),%edi

	      d1 = (d1 << bm) | (d0 >> b);
  80227e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  802281:	89 f9                	mov    %edi,%ecx
  802283:	d3 ea                	shr    %cl,%edx
  802285:	09 c2                	or     %eax,%edx
  802287:	89 55 f0             	mov    %edx,-0x10(%ebp)
	      d0 = d0 << bm;
  80228a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80228d:	8a 4d ec             	mov    -0x14(%ebp),%cl
  802290:	d3 e0                	shl    %cl,%eax
  802292:	89 45 f4             	mov    %eax,-0xc(%ebp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  802295:	89 f2                	mov    %esi,%edx
  802297:	d3 e2                	shl    %cl,%edx
	      n0 = n0 << bm;
  802299:	8b 45 e8             	mov    -0x18(%ebp),%eax
  80229c:	d3 e0                	shl    %cl,%eax
  80229e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  8022a1:	8b 45 e8             	mov    -0x18(%ebp),%eax
  8022a4:	89 f9                	mov    %edi,%ecx
  8022a6:	d3 e8                	shr    %cl,%eax
  8022a8:	09 d0                	or     %edx,%eax

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  8022aa:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  8022ac:	89 f2                	mov    %esi,%edx
  8022ae:	f7 75 f0             	divl   -0x10(%ebp)
  8022b1:	89 d6                	mov    %edx,%esi
	      umul_ppmm (m1, m0, q0, d0);
  8022b3:	f7 65 f4             	mull   -0xc(%ebp)
  8022b6:	89 55 e8             	mov    %edx,-0x18(%ebp)
  8022b9:	89 c1                	mov    %eax,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  8022bb:	39 d6                	cmp    %edx,%esi
  8022bd:	72 71                	jb     802330 <__umoddi3+0x110>
  8022bf:	74 7f                	je     802340 <__umoddi3+0x120>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  8022c1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8022c4:	29 c8                	sub    %ecx,%eax
  8022c6:	19 d6                	sbb    %edx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
  8022c8:	8a 4d ec             	mov    -0x14(%ebp),%cl
  8022cb:	d3 e8                	shr    %cl,%eax
  8022cd:	89 f2                	mov    %esi,%edx
  8022cf:	89 f9                	mov    %edi,%ecx
  8022d1:	d3 e2                	shl    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
  8022d3:	09 d0                	or     %edx,%eax
  8022d5:	89 f2                	mov    %esi,%edx
  8022d7:	8a 4d ec             	mov    -0x14(%ebp),%cl
  8022da:	d3 ea                	shr    %cl,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  8022dc:	83 c4 20             	add    $0x20,%esp
  8022df:	5e                   	pop    %esi
  8022e0:	5f                   	pop    %edi
  8022e1:	c9                   	leave  
  8022e2:	c3                   	ret    
  8022e3:	90                   	nop
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  8022e4:	85 c9                	test   %ecx,%ecx
  8022e6:	75 0b                	jne    8022f3 <__umoddi3+0xd3>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  8022e8:	b8 01 00 00 00       	mov    $0x1,%eax
  8022ed:	31 d2                	xor    %edx,%edx
  8022ef:	f7 f1                	div    %ecx
  8022f1:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  8022f3:	89 f0                	mov    %esi,%eax
  8022f5:	31 d2                	xor    %edx,%edx
  8022f7:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  8022f9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8022fc:	f7 f1                	div    %ecx
  8022fe:	e9 4a ff ff ff       	jmp    80224d <__umoddi3+0x2d>
  802303:	90                   	nop
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
  802304:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  802306:	83 c4 20             	add    $0x20,%esp
  802309:	5e                   	pop    %esi
  80230a:	5f                   	pop    %edi
  80230b:	c9                   	leave  
  80230c:	c3                   	ret    
  80230d:	8d 76 00             	lea    0x0(%esi),%esi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  802310:	39 f7                	cmp    %esi,%edi
  802312:	72 05                	jb     802319 <__umoddi3+0xf9>
  802314:	3b 4d f0             	cmp    -0x10(%ebp),%ecx
  802317:	77 0c                	ja     802325 <__umoddi3+0x105>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  802319:	89 f2                	mov    %esi,%edx
  80231b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80231e:	29 c8                	sub    %ecx,%eax
  802320:	19 fa                	sbb    %edi,%edx
  802322:	89 45 f0             	mov    %eax,-0x10(%ebp)

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
  802325:	8b 45 f0             	mov    -0x10(%ebp),%eax
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  802328:	83 c4 20             	add    $0x20,%esp
  80232b:	5e                   	pop    %esi
  80232c:	5f                   	pop    %edi
  80232d:	c9                   	leave  
  80232e:	c3                   	ret    
  80232f:	90                   	nop
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  802330:	8b 55 e8             	mov    -0x18(%ebp),%edx
  802333:	89 c1                	mov    %eax,%ecx
  802335:	2b 4d f4             	sub    -0xc(%ebp),%ecx
  802338:	1b 55 f0             	sbb    -0x10(%ebp),%edx
  80233b:	eb 84                	jmp    8022c1 <__umoddi3+0xa1>
  80233d:	8d 76 00             	lea    0x0(%esi),%esi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  802340:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  802343:	72 eb                	jb     802330 <__umoddi3+0x110>
  802345:	89 f2                	mov    %esi,%edx
  802347:	e9 75 ff ff ff       	jmp    8022c1 <__umoddi3+0xa1>
