
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
  800055:	e8 5f 13 00 00       	call   8013b9 <ipc_find_env>
	ipc_send(fsenv, FSREQ_OPEN, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  80005a:	6a 07                	push   $0x7
  80005c:	68 00 50 80 00       	push   $0x805000
  800061:	6a 01                	push   $0x1
  800063:	50                   	push   %eax
  800064:	e8 fb 12 00 00       	call   801364 <ipc_send>
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
  800090:	b8 80 23 80 00       	mov    $0x802380,%eax
  800095:	e8 9a ff ff ff       	call   800034 <xopen>
  80009a:	85 c0                	test   %eax,%eax
  80009c:	79 17                	jns    8000b5 <umain+0x36>
  80009e:	83 f8 f5             	cmp    $0xfffffff5,%eax
  8000a1:	74 26                	je     8000c9 <umain+0x4a>
		panic("serve_open /not-found: %e", r);
  8000a3:	50                   	push   %eax
  8000a4:	68 8b 23 80 00       	push   $0x80238b
  8000a9:	6a 20                	push   $0x20
  8000ab:	68 a5 23 80 00       	push   $0x8023a5
  8000b0:	e8 b7 05 00 00       	call   80066c <_panic>
	else if (r >= 0)
		panic("serve_open /not-found succeeded!");
  8000b5:	83 ec 04             	sub    $0x4,%esp
  8000b8:	68 40 25 80 00       	push   $0x802540
  8000bd:	6a 22                	push   $0x22
  8000bf:	68 a5 23 80 00       	push   $0x8023a5
  8000c4:	e8 a3 05 00 00       	call   80066c <_panic>

	if ((r = xopen("/newmotd", O_RDONLY)) < 0)
  8000c9:	ba 00 00 00 00       	mov    $0x0,%edx
  8000ce:	b8 b5 23 80 00       	mov    $0x8023b5,%eax
  8000d3:	e8 5c ff ff ff       	call   800034 <xopen>
  8000d8:	85 c0                	test   %eax,%eax
  8000da:	79 12                	jns    8000ee <umain+0x6f>
		panic("serve_open /newmotd: %e", r);
  8000dc:	50                   	push   %eax
  8000dd:	68 be 23 80 00       	push   $0x8023be
  8000e2:	6a 25                	push   $0x25
  8000e4:	68 a5 23 80 00       	push   $0x8023a5
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
  80010c:	68 64 25 80 00       	push   $0x802564
  800111:	6a 27                	push   $0x27
  800113:	68 a5 23 80 00       	push   $0x8023a5
  800118:	e8 4f 05 00 00       	call   80066c <_panic>
	cprintf("serve_open is good\n");
  80011d:	83 ec 0c             	sub    $0xc,%esp
  800120:	68 d6 23 80 00       	push   $0x8023d6
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
  800147:	68 ea 23 80 00       	push   $0x8023ea
  80014c:	6a 2b                	push   $0x2b
  80014e:	68 a5 23 80 00       	push   $0x8023a5
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
  800182:	68 94 25 80 00       	push   $0x802594
  800187:	6a 2d                	push   $0x2d
  800189:	68 a5 23 80 00       	push   $0x8023a5
  80018e:	e8 d9 04 00 00       	call   80066c <_panic>
	cprintf("file_stat is good\n");
  800193:	83 ec 0c             	sub    $0xc,%esp
  800196:	68 f8 23 80 00       	push   $0x8023f8
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
  8001d2:	68 0b 24 80 00       	push   $0x80240b
  8001d7:	6a 32                	push   $0x32
  8001d9:	68 a5 23 80 00       	push   $0x8023a5
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
  800202:	68 19 24 80 00       	push   $0x802419
  800207:	6a 34                	push   $0x34
  800209:	68 a5 23 80 00       	push   $0x8023a5
  80020e:	e8 59 04 00 00       	call   80066c <_panic>
	cprintf("file_read is good\n");
  800213:	83 ec 0c             	sub    $0xc,%esp
  800216:	68 37 24 80 00       	push   $0x802437
  80021b:	e8 24 05 00 00       	call   800744 <cprintf>

	if ((r = devfile.dev_close(FVA)) < 0)
  800220:	c7 04 24 00 c0 cc cc 	movl   $0xccccc000,(%esp)
  800227:	ff 15 18 30 80 00    	call   *0x803018
  80022d:	83 c4 10             	add    $0x10,%esp
  800230:	85 c0                	test   %eax,%eax
  800232:	79 12                	jns    800246 <umain+0x1c7>
		panic("file_close: %e", r);
  800234:	50                   	push   %eax
  800235:	68 4a 24 80 00       	push   $0x80244a
  80023a:	6a 38                	push   $0x38
  80023c:	68 a5 23 80 00       	push   $0x8023a5
  800241:	e8 26 04 00 00       	call   80066c <_panic>
	cprintf("file_close is good\n");
  800246:	83 ec 0c             	sub    $0xc,%esp
  800249:	68 59 24 80 00       	push   $0x802459
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
  800293:	68 bc 25 80 00       	push   $0x8025bc
  800298:	6a 43                	push   $0x43
  80029a:	68 a5 23 80 00       	push   $0x8023a5
  80029f:	e8 c8 03 00 00       	call   80066c <_panic>
	cprintf("stale fileid is good\n");
  8002a4:	83 ec 0c             	sub    $0xc,%esp
  8002a7:	68 6d 24 80 00       	push   $0x80246d
  8002ac:	e8 93 04 00 00       	call   800744 <cprintf>

	// Try writing
	if ((r = xopen("/new-file", O_RDWR|O_CREAT)) < 0)
  8002b1:	ba 02 01 00 00       	mov    $0x102,%edx
  8002b6:	b8 83 24 80 00       	mov    $0x802483,%eax
  8002bb:	e8 74 fd ff ff       	call   800034 <xopen>
  8002c0:	83 c4 10             	add    $0x10,%esp
  8002c3:	85 c0                	test   %eax,%eax
  8002c5:	79 12                	jns    8002d9 <umain+0x25a>
		panic("serve_open /new-file: %e", r);
  8002c7:	50                   	push   %eax
  8002c8:	68 8d 24 80 00       	push   $0x80248d
  8002cd:	6a 48                	push   $0x48
  8002cf:	68 a5 23 80 00       	push   $0x8023a5
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
  800316:	68 a6 24 80 00       	push   $0x8024a6
  80031b:	6a 4b                	push   $0x4b
  80031d:	68 a5 23 80 00       	push   $0x8023a5
  800322:	e8 45 03 00 00       	call   80066c <_panic>
	cprintf("file_write is good\n");
  800327:	83 ec 0c             	sub    $0xc,%esp
  80032a:	68 b5 24 80 00       	push   $0x8024b5
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
  800372:	68 f4 25 80 00       	push   $0x8025f4
  800377:	6a 51                	push   $0x51
  800379:	68 a5 23 80 00       	push   $0x8023a5
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
  800399:	68 14 26 80 00       	push   $0x802614
  80039e:	6a 53                	push   $0x53
  8003a0:	68 a5 23 80 00       	push   $0x8023a5
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
  8003c9:	68 4c 26 80 00       	push   $0x80264c
  8003ce:	6a 55                	push   $0x55
  8003d0:	68 a5 23 80 00       	push   $0x8023a5
  8003d5:	e8 92 02 00 00       	call   80066c <_panic>
	cprintf("file_read after file_write is good\n");
  8003da:	83 ec 0c             	sub    $0xc,%esp
  8003dd:	68 7c 26 80 00       	push   $0x80267c
  8003e2:	e8 5d 03 00 00       	call   800744 <cprintf>

	// Now we'll try out open
	if ((r = open("/not-found", O_RDONLY)) < 0 && r != -E_NOT_FOUND)
  8003e7:	83 c4 08             	add    $0x8,%esp
  8003ea:	6a 00                	push   $0x0
  8003ec:	68 80 23 80 00       	push   $0x802380
  8003f1:	e8 51 17 00 00       	call   801b47 <open>
  8003f6:	83 c4 10             	add    $0x10,%esp
  8003f9:	85 c0                	test   %eax,%eax
  8003fb:	79 17                	jns    800414 <umain+0x395>
  8003fd:	83 f8 f5             	cmp    $0xfffffff5,%eax
  800400:	74 26                	je     800428 <umain+0x3a9>
		panic("open /not-found: %e", r);
  800402:	50                   	push   %eax
  800403:	68 91 23 80 00       	push   $0x802391
  800408:	6a 5a                	push   $0x5a
  80040a:	68 a5 23 80 00       	push   $0x8023a5
  80040f:	e8 58 02 00 00       	call   80066c <_panic>
	else if (r >= 0)
		panic("open /not-found succeeded!");
  800414:	83 ec 04             	sub    $0x4,%esp
  800417:	68 c9 24 80 00       	push   $0x8024c9
  80041c:	6a 5c                	push   $0x5c
  80041e:	68 a5 23 80 00       	push   $0x8023a5
  800423:	e8 44 02 00 00       	call   80066c <_panic>

	if ((r = open("/newmotd", O_RDONLY)) < 0)
  800428:	83 ec 08             	sub    $0x8,%esp
  80042b:	6a 00                	push   $0x0
  80042d:	68 b5 23 80 00       	push   $0x8023b5
  800432:	e8 10 17 00 00       	call   801b47 <open>
  800437:	83 c4 10             	add    $0x10,%esp
  80043a:	85 c0                	test   %eax,%eax
  80043c:	79 12                	jns    800450 <umain+0x3d1>
		panic("open /newmotd: %e", r);
  80043e:	50                   	push   %eax
  80043f:	68 c4 23 80 00       	push   $0x8023c4
  800444:	6a 5f                	push   $0x5f
  800446:	68 a5 23 80 00       	push   $0x8023a5
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
  80046c:	68 a0 26 80 00       	push   $0x8026a0
  800471:	6a 62                	push   $0x62
  800473:	68 a5 23 80 00       	push   $0x8023a5
  800478:	e8 ef 01 00 00       	call   80066c <_panic>
	cprintf("open is good\n");
  80047d:	83 ec 0c             	sub    $0xc,%esp
  800480:	68 dc 23 80 00       	push   $0x8023dc
  800485:	e8 ba 02 00 00       	call   800744 <cprintf>

	// Try files with indirect blocks
	if ((f = open("/big", O_WRONLY|O_CREAT)) < 0)
  80048a:	83 c4 08             	add    $0x8,%esp
  80048d:	68 01 01 00 00       	push   $0x101
  800492:	68 e4 24 80 00       	push   $0x8024e4
  800497:	e8 ab 16 00 00       	call   801b47 <open>
  80049c:	89 85 44 fd ff ff    	mov    %eax,-0x2bc(%ebp)
  8004a2:	83 c4 10             	add    $0x10,%esp
  8004a5:	85 c0                	test   %eax,%eax
  8004a7:	79 12                	jns    8004bb <umain+0x43c>
		panic("creat /big: %e", f);
  8004a9:	50                   	push   %eax
  8004aa:	68 e9 24 80 00       	push   $0x8024e9
  8004af:	6a 67                	push   $0x67
  8004b1:	68 a5 23 80 00       	push   $0x8023a5
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
  8004f2:	e8 15 13 00 00       	call   80180c <write>
  8004f7:	83 c4 10             	add    $0x10,%esp
  8004fa:	85 c0                	test   %eax,%eax
  8004fc:	79 16                	jns    800514 <umain+0x495>
			panic("write /big@%d: %e", i, r);
  8004fe:	83 ec 0c             	sub    $0xc,%esp
  800501:	50                   	push   %eax
  800502:	56                   	push   %esi
  800503:	68 f8 24 80 00       	push   $0x8024f8
  800508:	6a 6c                	push   $0x6c
  80050a:	68 a5 23 80 00       	push   $0x8023a5
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
  80052c:	e8 c2 10 00 00       	call   8015f3 <close>

	if ((f = open("/big", O_RDONLY)) < 0)
  800531:	83 c4 08             	add    $0x8,%esp
  800534:	6a 00                	push   $0x0
  800536:	68 e4 24 80 00       	push   $0x8024e4
  80053b:	e8 07 16 00 00       	call   801b47 <open>
  800540:	89 c6                	mov    %eax,%esi
  800542:	83 c4 10             	add    $0x10,%esp
  800545:	85 c0                	test   %eax,%eax
  800547:	79 12                	jns    80055b <umain+0x4dc>
		panic("open /big: %e", f);
  800549:	50                   	push   %eax
  80054a:	68 0a 25 80 00       	push   $0x80250a
  80054f:	6a 71                	push   $0x71
  800551:	68 a5 23 80 00       	push   $0x8023a5
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
  800572:	e8 40 12 00 00       	call   8017b7 <readn>
  800577:	83 c4 10             	add    $0x10,%esp
  80057a:	85 c0                	test   %eax,%eax
  80057c:	79 16                	jns    800594 <umain+0x515>
			panic("read /big@%d: %e", i, r);
  80057e:	83 ec 0c             	sub    $0xc,%esp
  800581:	50                   	push   %eax
  800582:	53                   	push   %ebx
  800583:	68 18 25 80 00       	push   $0x802518
  800588:	6a 75                	push   $0x75
  80058a:	68 a5 23 80 00       	push   $0x8023a5
  80058f:	e8 d8 00 00 00       	call   80066c <_panic>
		if (r != sizeof(buf))
  800594:	3d 00 02 00 00       	cmp    $0x200,%eax
  800599:	74 1b                	je     8005b6 <umain+0x537>
			panic("read /big from %d returned %d < %d bytes",
  80059b:	83 ec 08             	sub    $0x8,%esp
  80059e:	68 00 02 00 00       	push   $0x200
  8005a3:	50                   	push   %eax
  8005a4:	53                   	push   %ebx
  8005a5:	68 c8 26 80 00       	push   $0x8026c8
  8005aa:	6a 78                	push   $0x78
  8005ac:	68 a5 23 80 00       	push   $0x8023a5
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
  8005c1:	68 f4 26 80 00       	push   $0x8026f4
  8005c6:	6a 7b                	push   $0x7b
  8005c8:	68 a5 23 80 00       	push   $0x8023a5
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
  8005e4:	e8 0a 10 00 00       	call   8015f3 <close>
	cprintf("large file is good\n");
  8005e9:	c7 04 24 29 25 80 00 	movl   $0x802529,(%esp)
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
  800656:	e8 c3 0f 00 00       	call   80161e <close_all>
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
  80068a:	68 4c 27 80 00       	push   $0x80274c
  80068f:	e8 b0 00 00 00       	call   800744 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800694:	83 c4 18             	add    $0x18,%esp
  800697:	56                   	push   %esi
  800698:	ff 75 10             	pushl  0x10(%ebp)
  80069b:	e8 53 00 00 00       	call   8006f3 <vcprintf>
	cprintf("\n");
  8006a0:	c7 04 24 ab 2b 80 00 	movl   $0x802bab,(%esp)
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
  8007ac:	e8 7b 19 00 00       	call   80212c <__udivdi3>
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
  8007e8:	e8 5b 1a 00 00       	call   802248 <__umoddi3>
  8007ed:	83 c4 14             	add    $0x14,%esp
  8007f0:	0f be 80 6f 27 80 00 	movsbl 0x80276f(%eax),%eax
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
  800934:	ff 24 85 c0 28 80 00 	jmp    *0x8028c0(,%eax,4)
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
  8009e0:	8b 04 85 20 2a 80 00 	mov    0x802a20(,%eax,4),%eax
  8009e7:	85 c0                	test   %eax,%eax
  8009e9:	75 1a                	jne    800a05 <vprintfmt+0x15c>
				printfmt(putch, putdat, "error %d", err);
  8009eb:	52                   	push   %edx
  8009ec:	68 87 27 80 00       	push   $0x802787
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
  800a06:	68 8d 2b 80 00       	push   $0x802b8d
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
  800a3c:	c7 45 d0 80 27 80 00 	movl   $0x802780,-0x30(%ebp)
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
  8010aa:	68 7f 2a 80 00       	push   $0x802a7f
  8010af:	6a 42                	push   $0x42
  8010b1:	68 9c 2a 80 00       	push   $0x802a9c
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
  8012bf:	57                   	push   %edi
  8012c0:	56                   	push   %esi
  8012c1:	53                   	push   %ebx
  8012c2:	83 ec 0c             	sub    $0xc,%esp
  8012c5:	8b 7d 08             	mov    0x8(%ebp),%edi
  8012c8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8012cb:	8b 75 10             	mov    0x10(%ebp),%esi
	// LAB 4: Your code here.
	cprintf("0x%x 0x%x 0x%x\n", (uint32_t)from_env_store, (uint32_t)pg, (uint32_t)perm_store);
  8012ce:	56                   	push   %esi
  8012cf:	53                   	push   %ebx
  8012d0:	57                   	push   %edi
  8012d1:	68 aa 2a 80 00       	push   $0x802aaa
  8012d6:	e8 69 f4 ff ff       	call   800744 <cprintf>
	int r;
	if (pg != NULL) {
  8012db:	83 c4 10             	add    $0x10,%esp
  8012de:	85 db                	test   %ebx,%ebx
  8012e0:	74 28                	je     80130a <ipc_recv+0x4e>
		cprintf("BEGIN\n");
  8012e2:	83 ec 0c             	sub    $0xc,%esp
  8012e5:	68 ba 2a 80 00       	push   $0x802aba
  8012ea:	e8 55 f4 ff ff       	call   800744 <cprintf>
		r = sys_ipc_recv(pg);
  8012ef:	89 1c 24             	mov    %ebx,(%esp)
  8012f2:	e8 80 ff ff ff       	call   801277 <sys_ipc_recv>
  8012f7:	89 c3                	mov    %eax,%ebx
		cprintf("OVER\n");
  8012f9:	c7 04 24 c1 2a 80 00 	movl   $0x802ac1,(%esp)
  801300:	e8 3f f4 ff ff       	call   800744 <cprintf>
  801305:	83 c4 10             	add    $0x10,%esp
  801308:	eb 12                	jmp    80131c <ipc_recv+0x60>
	} else {
		r = sys_ipc_recv((void *)UTOP);
  80130a:	83 ec 0c             	sub    $0xc,%esp
  80130d:	68 00 00 c0 ee       	push   $0xeec00000
  801312:	e8 60 ff ff ff       	call   801277 <sys_ipc_recv>
  801317:	89 c3                	mov    %eax,%ebx
  801319:	83 c4 10             	add    $0x10,%esp
	}

	if (r == 0) {
  80131c:	85 db                	test   %ebx,%ebx
  80131e:	75 26                	jne    801346 <ipc_recv+0x8a>
		if (from_env_store != NULL) *from_env_store = thisenv->env_ipc_from;
  801320:	85 ff                	test   %edi,%edi
  801322:	74 0a                	je     80132e <ipc_recv+0x72>
  801324:	a1 04 40 80 00       	mov    0x804004,%eax
  801329:	8b 40 74             	mov    0x74(%eax),%eax
  80132c:	89 07                	mov    %eax,(%edi)
		if (perm_store != NULL) *perm_store = thisenv->env_ipc_perm;
  80132e:	85 f6                	test   %esi,%esi
  801330:	74 0a                	je     80133c <ipc_recv+0x80>
  801332:	a1 04 40 80 00       	mov    0x804004,%eax
  801337:	8b 40 78             	mov    0x78(%eax),%eax
  80133a:	89 06                	mov    %eax,(%esi)
		return thisenv->env_ipc_value;
  80133c:	a1 04 40 80 00       	mov    0x804004,%eax
  801341:	8b 58 70             	mov    0x70(%eax),%ebx
  801344:	eb 14                	jmp    80135a <ipc_recv+0x9e>
	} else {
		// fails;
		if (from_env_store != NULL) *from_env_store = 0;
  801346:	85 ff                	test   %edi,%edi
  801348:	74 06                	je     801350 <ipc_recv+0x94>
  80134a:	c7 07 00 00 00 00    	movl   $0x0,(%edi)
		if (perm_store != NULL) *perm_store = 0;
  801350:	85 f6                	test   %esi,%esi
  801352:	74 06                	je     80135a <ipc_recv+0x9e>
  801354:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		return r;
	}
}
  80135a:	89 d8                	mov    %ebx,%eax
  80135c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80135f:	5b                   	pop    %ebx
  801360:	5e                   	pop    %esi
  801361:	5f                   	pop    %edi
  801362:	c9                   	leave  
  801363:	c3                   	ret    

00801364 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801364:	55                   	push   %ebp
  801365:	89 e5                	mov    %esp,%ebp
  801367:	57                   	push   %edi
  801368:	56                   	push   %esi
  801369:	53                   	push   %ebx
  80136a:	83 ec 0c             	sub    $0xc,%esp
  80136d:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801370:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801373:	8b 75 14             	mov    0x14(%ebp),%esi
	// LAB 4: Your code here.
	// int sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
	int r;
	if (pg == NULL) pg = (void *)UTOP;
  801376:	85 db                	test   %ebx,%ebx
  801378:	75 25                	jne    80139f <ipc_send+0x3b>
  80137a:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
  80137f:	eb 1e                	jmp    80139f <ipc_send+0x3b>
	
	while ((r = sys_ipc_try_send(to_env, val, pg, perm)) != 0) {
		if (r == -E_IPC_NOT_RECV) {
  801381:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801384:	75 07                	jne    80138d <ipc_send+0x29>
			// cprintf("Try Again and Again....\n");
			sys_yield();
  801386:	e8 ca fd ff ff       	call   801155 <sys_yield>
  80138b:	eb 12                	jmp    80139f <ipc_send+0x3b>
		} else {
			panic("ipc_send error %e\n", r);
  80138d:	50                   	push   %eax
  80138e:	68 c7 2a 80 00       	push   $0x802ac7
  801393:	6a 45                	push   $0x45
  801395:	68 da 2a 80 00       	push   $0x802ada
  80139a:	e8 cd f2 ff ff       	call   80066c <_panic>
	// LAB 4: Your code here.
	// int sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
	int r;
	if (pg == NULL) pg = (void *)UTOP;
	
	while ((r = sys_ipc_try_send(to_env, val, pg, perm)) != 0) {
  80139f:	56                   	push   %esi
  8013a0:	53                   	push   %ebx
  8013a1:	57                   	push   %edi
  8013a2:	ff 75 08             	pushl  0x8(%ebp)
  8013a5:	e8 a8 fe ff ff       	call   801252 <sys_ipc_try_send>
  8013aa:	83 c4 10             	add    $0x10,%esp
  8013ad:	85 c0                	test   %eax,%eax
  8013af:	75 d0                	jne    801381 <ipc_send+0x1d>
		} else {
			panic("ipc_send error %e\n", r);
		}
	}
	return;
}
  8013b1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8013b4:	5b                   	pop    %ebx
  8013b5:	5e                   	pop    %esi
  8013b6:	5f                   	pop    %edi
  8013b7:	c9                   	leave  
  8013b8:	c3                   	ret    

008013b9 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  8013b9:	55                   	push   %ebp
  8013ba:	89 e5                	mov    %esp,%ebp
  8013bc:	53                   	push   %ebx
  8013bd:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	for (i = 0; i < NENV; i++)
		if (envs[i].env_type == type)
  8013c0:	39 1d 50 00 c0 ee    	cmp    %ebx,0xeec00050
  8013c6:	74 22                	je     8013ea <ipc_find_env+0x31>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8013c8:	b8 01 00 00 00       	mov    $0x1,%eax
		if (envs[i].env_type == type)
  8013cd:	8d 0c 85 00 00 00 00 	lea    0x0(,%eax,4),%ecx
  8013d4:	89 c2                	mov    %eax,%edx
  8013d6:	c1 e2 07             	shl    $0x7,%edx
  8013d9:	29 ca                	sub    %ecx,%edx
  8013db:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  8013e1:	8b 52 50             	mov    0x50(%edx),%edx
  8013e4:	39 da                	cmp    %ebx,%edx
  8013e6:	75 1d                	jne    801405 <ipc_find_env+0x4c>
  8013e8:	eb 05                	jmp    8013ef <ipc_find_env+0x36>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8013ea:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
			return envs[i].env_id;
  8013ef:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  8013f6:	c1 e0 07             	shl    $0x7,%eax
  8013f9:	29 d0                	sub    %edx,%eax
  8013fb:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  801400:	8b 40 40             	mov    0x40(%eax),%eax
  801403:	eb 0c                	jmp    801411 <ipc_find_env+0x58>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801405:	40                   	inc    %eax
  801406:	3d 00 04 00 00       	cmp    $0x400,%eax
  80140b:	75 c0                	jne    8013cd <ipc_find_env+0x14>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  80140d:	66 b8 00 00          	mov    $0x0,%ax
}
  801411:	5b                   	pop    %ebx
  801412:	c9                   	leave  
  801413:	c3                   	ret    

00801414 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801414:	55                   	push   %ebp
  801415:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801417:	8b 45 08             	mov    0x8(%ebp),%eax
  80141a:	05 00 00 00 30       	add    $0x30000000,%eax
  80141f:	c1 e8 0c             	shr    $0xc,%eax
}
  801422:	c9                   	leave  
  801423:	c3                   	ret    

00801424 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801424:	55                   	push   %ebp
  801425:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  801427:	ff 75 08             	pushl  0x8(%ebp)
  80142a:	e8 e5 ff ff ff       	call   801414 <fd2num>
  80142f:	83 c4 04             	add    $0x4,%esp
  801432:	05 20 00 0d 00       	add    $0xd0020,%eax
  801437:	c1 e0 0c             	shl    $0xc,%eax
}
  80143a:	c9                   	leave  
  80143b:	c3                   	ret    

0080143c <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  80143c:	55                   	push   %ebp
  80143d:	89 e5                	mov    %esp,%ebp
  80143f:	53                   	push   %ebx
  801440:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801443:	a1 00 dd 7b ef       	mov    0xef7bdd00,%eax
  801448:	a8 01                	test   $0x1,%al
  80144a:	74 34                	je     801480 <fd_alloc+0x44>
  80144c:	a1 00 00 74 ef       	mov    0xef740000,%eax
  801451:	a8 01                	test   $0x1,%al
  801453:	74 32                	je     801487 <fd_alloc+0x4b>
  801455:	b8 00 10 00 d0       	mov    $0xd0001000,%eax
  80145a:	89 c1                	mov    %eax,%ecx
  80145c:	89 c2                	mov    %eax,%edx
  80145e:	c1 ea 16             	shr    $0x16,%edx
  801461:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801468:	f6 c2 01             	test   $0x1,%dl
  80146b:	74 1f                	je     80148c <fd_alloc+0x50>
  80146d:	89 c2                	mov    %eax,%edx
  80146f:	c1 ea 0c             	shr    $0xc,%edx
  801472:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801479:	f6 c2 01             	test   $0x1,%dl
  80147c:	75 17                	jne    801495 <fd_alloc+0x59>
  80147e:	eb 0c                	jmp    80148c <fd_alloc+0x50>
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  801480:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
  801485:	eb 05                	jmp    80148c <fd_alloc+0x50>
  801487:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
  80148c:	89 0b                	mov    %ecx,(%ebx)
			return 0;
  80148e:	b8 00 00 00 00       	mov    $0x0,%eax
  801493:	eb 17                	jmp    8014ac <fd_alloc+0x70>
  801495:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  80149a:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  80149f:	75 b9                	jne    80145a <fd_alloc+0x1e>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8014a1:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_MAX_OPEN;
  8014a7:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8014ac:	5b                   	pop    %ebx
  8014ad:	c9                   	leave  
  8014ae:	c3                   	ret    

008014af <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8014af:	55                   	push   %ebp
  8014b0:	89 e5                	mov    %esp,%ebp
  8014b2:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8014b5:	83 f8 1f             	cmp    $0x1f,%eax
  8014b8:	77 36                	ja     8014f0 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8014ba:	05 00 00 0d 00       	add    $0xd0000,%eax
  8014bf:	c1 e0 0c             	shl    $0xc,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8014c2:	89 c2                	mov    %eax,%edx
  8014c4:	c1 ea 16             	shr    $0x16,%edx
  8014c7:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8014ce:	f6 c2 01             	test   $0x1,%dl
  8014d1:	74 24                	je     8014f7 <fd_lookup+0x48>
  8014d3:	89 c2                	mov    %eax,%edx
  8014d5:	c1 ea 0c             	shr    $0xc,%edx
  8014d8:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8014df:	f6 c2 01             	test   $0x1,%dl
  8014e2:	74 1a                	je     8014fe <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8014e4:	8b 55 0c             	mov    0xc(%ebp),%edx
  8014e7:	89 02                	mov    %eax,(%edx)
	return 0;
  8014e9:	b8 00 00 00 00       	mov    $0x0,%eax
  8014ee:	eb 13                	jmp    801503 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8014f0:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8014f5:	eb 0c                	jmp    801503 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8014f7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8014fc:	eb 05                	jmp    801503 <fd_lookup+0x54>
  8014fe:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  801503:	c9                   	leave  
  801504:	c3                   	ret    

00801505 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801505:	55                   	push   %ebp
  801506:	89 e5                	mov    %esp,%ebp
  801508:	53                   	push   %ebx
  801509:	83 ec 04             	sub    $0x4,%esp
  80150c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80150f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
		if (devtab[i]->dev_id == dev_id) {
  801512:	39 0d 08 30 80 00    	cmp    %ecx,0x803008
  801518:	74 0d                	je     801527 <dev_lookup+0x22>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  80151a:	b8 00 00 00 00       	mov    $0x0,%eax
  80151f:	eb 14                	jmp    801535 <dev_lookup+0x30>
		if (devtab[i]->dev_id == dev_id) {
  801521:	39 0a                	cmp    %ecx,(%edx)
  801523:	75 10                	jne    801535 <dev_lookup+0x30>
  801525:	eb 05                	jmp    80152c <dev_lookup+0x27>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801527:	ba 08 30 80 00       	mov    $0x803008,%edx
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
  80152c:	89 13                	mov    %edx,(%ebx)
			return 0;
  80152e:	b8 00 00 00 00       	mov    $0x0,%eax
  801533:	eb 31                	jmp    801566 <dev_lookup+0x61>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801535:	40                   	inc    %eax
  801536:	8b 14 85 64 2b 80 00 	mov    0x802b64(,%eax,4),%edx
  80153d:	85 d2                	test   %edx,%edx
  80153f:	75 e0                	jne    801521 <dev_lookup+0x1c>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801541:	a1 04 40 80 00       	mov    0x804004,%eax
  801546:	8b 40 48             	mov    0x48(%eax),%eax
  801549:	83 ec 04             	sub    $0x4,%esp
  80154c:	51                   	push   %ecx
  80154d:	50                   	push   %eax
  80154e:	68 e4 2a 80 00       	push   $0x802ae4
  801553:	e8 ec f1 ff ff       	call   800744 <cprintf>
	*dev = 0;
  801558:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_INVAL;
  80155e:	83 c4 10             	add    $0x10,%esp
  801561:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801566:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801569:	c9                   	leave  
  80156a:	c3                   	ret    

0080156b <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  80156b:	55                   	push   %ebp
  80156c:	89 e5                	mov    %esp,%ebp
  80156e:	56                   	push   %esi
  80156f:	53                   	push   %ebx
  801570:	83 ec 20             	sub    $0x20,%esp
  801573:	8b 75 08             	mov    0x8(%ebp),%esi
  801576:	8a 45 0c             	mov    0xc(%ebp),%al
  801579:	88 45 e7             	mov    %al,-0x19(%ebp)
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80157c:	56                   	push   %esi
  80157d:	e8 92 fe ff ff       	call   801414 <fd2num>
  801582:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801585:	89 14 24             	mov    %edx,(%esp)
  801588:	50                   	push   %eax
  801589:	e8 21 ff ff ff       	call   8014af <fd_lookup>
  80158e:	89 c3                	mov    %eax,%ebx
  801590:	83 c4 08             	add    $0x8,%esp
  801593:	85 c0                	test   %eax,%eax
  801595:	78 05                	js     80159c <fd_close+0x31>
	    || fd != fd2)
  801597:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  80159a:	74 0d                	je     8015a9 <fd_close+0x3e>
		return (must_exist ? r : 0);
  80159c:	80 7d e7 00          	cmpb   $0x0,-0x19(%ebp)
  8015a0:	75 48                	jne    8015ea <fd_close+0x7f>
  8015a2:	bb 00 00 00 00       	mov    $0x0,%ebx
  8015a7:	eb 41                	jmp    8015ea <fd_close+0x7f>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8015a9:	83 ec 08             	sub    $0x8,%esp
  8015ac:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8015af:	50                   	push   %eax
  8015b0:	ff 36                	pushl  (%esi)
  8015b2:	e8 4e ff ff ff       	call   801505 <dev_lookup>
  8015b7:	89 c3                	mov    %eax,%ebx
  8015b9:	83 c4 10             	add    $0x10,%esp
  8015bc:	85 c0                	test   %eax,%eax
  8015be:	78 1c                	js     8015dc <fd_close+0x71>
		if (dev->dev_close)
  8015c0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015c3:	8b 40 10             	mov    0x10(%eax),%eax
  8015c6:	85 c0                	test   %eax,%eax
  8015c8:	74 0d                	je     8015d7 <fd_close+0x6c>
			r = (*dev->dev_close)(fd);
  8015ca:	83 ec 0c             	sub    $0xc,%esp
  8015cd:	56                   	push   %esi
  8015ce:	ff d0                	call   *%eax
  8015d0:	89 c3                	mov    %eax,%ebx
  8015d2:	83 c4 10             	add    $0x10,%esp
  8015d5:	eb 05                	jmp    8015dc <fd_close+0x71>
		else
			r = 0;
  8015d7:	bb 00 00 00 00       	mov    $0x0,%ebx
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8015dc:	83 ec 08             	sub    $0x8,%esp
  8015df:	56                   	push   %esi
  8015e0:	6a 00                	push   $0x0
  8015e2:	e8 df fb ff ff       	call   8011c6 <sys_page_unmap>
	return r;
  8015e7:	83 c4 10             	add    $0x10,%esp
}
  8015ea:	89 d8                	mov    %ebx,%eax
  8015ec:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8015ef:	5b                   	pop    %ebx
  8015f0:	5e                   	pop    %esi
  8015f1:	c9                   	leave  
  8015f2:	c3                   	ret    

008015f3 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8015f3:	55                   	push   %ebp
  8015f4:	89 e5                	mov    %esp,%ebp
  8015f6:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8015f9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015fc:	50                   	push   %eax
  8015fd:	ff 75 08             	pushl  0x8(%ebp)
  801600:	e8 aa fe ff ff       	call   8014af <fd_lookup>
  801605:	83 c4 08             	add    $0x8,%esp
  801608:	85 c0                	test   %eax,%eax
  80160a:	78 10                	js     80161c <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  80160c:	83 ec 08             	sub    $0x8,%esp
  80160f:	6a 01                	push   $0x1
  801611:	ff 75 f4             	pushl  -0xc(%ebp)
  801614:	e8 52 ff ff ff       	call   80156b <fd_close>
  801619:	83 c4 10             	add    $0x10,%esp
}
  80161c:	c9                   	leave  
  80161d:	c3                   	ret    

0080161e <close_all>:

void
close_all(void)
{
  80161e:	55                   	push   %ebp
  80161f:	89 e5                	mov    %esp,%ebp
  801621:	53                   	push   %ebx
  801622:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801625:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  80162a:	83 ec 0c             	sub    $0xc,%esp
  80162d:	53                   	push   %ebx
  80162e:	e8 c0 ff ff ff       	call   8015f3 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801633:	43                   	inc    %ebx
  801634:	83 c4 10             	add    $0x10,%esp
  801637:	83 fb 20             	cmp    $0x20,%ebx
  80163a:	75 ee                	jne    80162a <close_all+0xc>
		close(i);
}
  80163c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80163f:	c9                   	leave  
  801640:	c3                   	ret    

00801641 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801641:	55                   	push   %ebp
  801642:	89 e5                	mov    %esp,%ebp
  801644:	57                   	push   %edi
  801645:	56                   	push   %esi
  801646:	53                   	push   %ebx
  801647:	83 ec 2c             	sub    $0x2c,%esp
  80164a:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  80164d:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801650:	50                   	push   %eax
  801651:	ff 75 08             	pushl  0x8(%ebp)
  801654:	e8 56 fe ff ff       	call   8014af <fd_lookup>
  801659:	89 c3                	mov    %eax,%ebx
  80165b:	83 c4 08             	add    $0x8,%esp
  80165e:	85 c0                	test   %eax,%eax
  801660:	0f 88 c0 00 00 00    	js     801726 <dup+0xe5>
		return r;
	close(newfdnum);
  801666:	83 ec 0c             	sub    $0xc,%esp
  801669:	57                   	push   %edi
  80166a:	e8 84 ff ff ff       	call   8015f3 <close>

	newfd = INDEX2FD(newfdnum);
  80166f:	8d b7 00 00 0d 00    	lea    0xd0000(%edi),%esi
  801675:	c1 e6 0c             	shl    $0xc,%esi
	ova = fd2data(oldfd);
  801678:	83 c4 04             	add    $0x4,%esp
  80167b:	ff 75 e4             	pushl  -0x1c(%ebp)
  80167e:	e8 a1 fd ff ff       	call   801424 <fd2data>
  801683:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  801685:	89 34 24             	mov    %esi,(%esp)
  801688:	e8 97 fd ff ff       	call   801424 <fd2data>
  80168d:	83 c4 10             	add    $0x10,%esp
  801690:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801693:	89 d8                	mov    %ebx,%eax
  801695:	c1 e8 16             	shr    $0x16,%eax
  801698:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80169f:	a8 01                	test   $0x1,%al
  8016a1:	74 37                	je     8016da <dup+0x99>
  8016a3:	89 d8                	mov    %ebx,%eax
  8016a5:	c1 e8 0c             	shr    $0xc,%eax
  8016a8:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8016af:	f6 c2 01             	test   $0x1,%dl
  8016b2:	74 26                	je     8016da <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8016b4:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8016bb:	83 ec 0c             	sub    $0xc,%esp
  8016be:	25 07 0e 00 00       	and    $0xe07,%eax
  8016c3:	50                   	push   %eax
  8016c4:	ff 75 d4             	pushl  -0x2c(%ebp)
  8016c7:	6a 00                	push   $0x0
  8016c9:	53                   	push   %ebx
  8016ca:	6a 00                	push   $0x0
  8016cc:	e8 cf fa ff ff       	call   8011a0 <sys_page_map>
  8016d1:	89 c3                	mov    %eax,%ebx
  8016d3:	83 c4 20             	add    $0x20,%esp
  8016d6:	85 c0                	test   %eax,%eax
  8016d8:	78 2d                	js     801707 <dup+0xc6>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8016da:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8016dd:	89 c2                	mov    %eax,%edx
  8016df:	c1 ea 0c             	shr    $0xc,%edx
  8016e2:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8016e9:	83 ec 0c             	sub    $0xc,%esp
  8016ec:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  8016f2:	52                   	push   %edx
  8016f3:	56                   	push   %esi
  8016f4:	6a 00                	push   $0x0
  8016f6:	50                   	push   %eax
  8016f7:	6a 00                	push   $0x0
  8016f9:	e8 a2 fa ff ff       	call   8011a0 <sys_page_map>
  8016fe:	89 c3                	mov    %eax,%ebx
  801700:	83 c4 20             	add    $0x20,%esp
  801703:	85 c0                	test   %eax,%eax
  801705:	79 1d                	jns    801724 <dup+0xe3>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801707:	83 ec 08             	sub    $0x8,%esp
  80170a:	56                   	push   %esi
  80170b:	6a 00                	push   $0x0
  80170d:	e8 b4 fa ff ff       	call   8011c6 <sys_page_unmap>
	sys_page_unmap(0, nva);
  801712:	83 c4 08             	add    $0x8,%esp
  801715:	ff 75 d4             	pushl  -0x2c(%ebp)
  801718:	6a 00                	push   $0x0
  80171a:	e8 a7 fa ff ff       	call   8011c6 <sys_page_unmap>
	return r;
  80171f:	83 c4 10             	add    $0x10,%esp
  801722:	eb 02                	jmp    801726 <dup+0xe5>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
		goto err;

	return newfdnum;
  801724:	89 fb                	mov    %edi,%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  801726:	89 d8                	mov    %ebx,%eax
  801728:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80172b:	5b                   	pop    %ebx
  80172c:	5e                   	pop    %esi
  80172d:	5f                   	pop    %edi
  80172e:	c9                   	leave  
  80172f:	c3                   	ret    

00801730 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801730:	55                   	push   %ebp
  801731:	89 e5                	mov    %esp,%ebp
  801733:	53                   	push   %ebx
  801734:	83 ec 14             	sub    $0x14,%esp
  801737:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80173a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80173d:	50                   	push   %eax
  80173e:	53                   	push   %ebx
  80173f:	e8 6b fd ff ff       	call   8014af <fd_lookup>
  801744:	83 c4 08             	add    $0x8,%esp
  801747:	85 c0                	test   %eax,%eax
  801749:	78 67                	js     8017b2 <read+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80174b:	83 ec 08             	sub    $0x8,%esp
  80174e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801751:	50                   	push   %eax
  801752:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801755:	ff 30                	pushl  (%eax)
  801757:	e8 a9 fd ff ff       	call   801505 <dev_lookup>
  80175c:	83 c4 10             	add    $0x10,%esp
  80175f:	85 c0                	test   %eax,%eax
  801761:	78 4f                	js     8017b2 <read+0x82>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801763:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801766:	8b 50 08             	mov    0x8(%eax),%edx
  801769:	83 e2 03             	and    $0x3,%edx
  80176c:	83 fa 01             	cmp    $0x1,%edx
  80176f:	75 21                	jne    801792 <read+0x62>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801771:	a1 04 40 80 00       	mov    0x804004,%eax
  801776:	8b 40 48             	mov    0x48(%eax),%eax
  801779:	83 ec 04             	sub    $0x4,%esp
  80177c:	53                   	push   %ebx
  80177d:	50                   	push   %eax
  80177e:	68 28 2b 80 00       	push   $0x802b28
  801783:	e8 bc ef ff ff       	call   800744 <cprintf>
		return -E_INVAL;
  801788:	83 c4 10             	add    $0x10,%esp
  80178b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801790:	eb 20                	jmp    8017b2 <read+0x82>
	}
	if (!dev->dev_read)
  801792:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801795:	8b 52 08             	mov    0x8(%edx),%edx
  801798:	85 d2                	test   %edx,%edx
  80179a:	74 11                	je     8017ad <read+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  80179c:	83 ec 04             	sub    $0x4,%esp
  80179f:	ff 75 10             	pushl  0x10(%ebp)
  8017a2:	ff 75 0c             	pushl  0xc(%ebp)
  8017a5:	50                   	push   %eax
  8017a6:	ff d2                	call   *%edx
  8017a8:	83 c4 10             	add    $0x10,%esp
  8017ab:	eb 05                	jmp    8017b2 <read+0x82>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8017ad:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_read)(fd, buf, n);
}
  8017b2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8017b5:	c9                   	leave  
  8017b6:	c3                   	ret    

008017b7 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8017b7:	55                   	push   %ebp
  8017b8:	89 e5                	mov    %esp,%ebp
  8017ba:	57                   	push   %edi
  8017bb:	56                   	push   %esi
  8017bc:	53                   	push   %ebx
  8017bd:	83 ec 0c             	sub    $0xc,%esp
  8017c0:	8b 7d 08             	mov    0x8(%ebp),%edi
  8017c3:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8017c6:	85 f6                	test   %esi,%esi
  8017c8:	74 31                	je     8017fb <readn+0x44>
  8017ca:	b8 00 00 00 00       	mov    $0x0,%eax
  8017cf:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = read(fdnum, (char*)buf + tot, n - tot);
  8017d4:	83 ec 04             	sub    $0x4,%esp
  8017d7:	89 f2                	mov    %esi,%edx
  8017d9:	29 c2                	sub    %eax,%edx
  8017db:	52                   	push   %edx
  8017dc:	03 45 0c             	add    0xc(%ebp),%eax
  8017df:	50                   	push   %eax
  8017e0:	57                   	push   %edi
  8017e1:	e8 4a ff ff ff       	call   801730 <read>
		if (m < 0)
  8017e6:	83 c4 10             	add    $0x10,%esp
  8017e9:	85 c0                	test   %eax,%eax
  8017eb:	78 17                	js     801804 <readn+0x4d>
			return m;
		if (m == 0)
  8017ed:	85 c0                	test   %eax,%eax
  8017ef:	74 11                	je     801802 <readn+0x4b>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8017f1:	01 c3                	add    %eax,%ebx
  8017f3:	89 d8                	mov    %ebx,%eax
  8017f5:	39 f3                	cmp    %esi,%ebx
  8017f7:	72 db                	jb     8017d4 <readn+0x1d>
  8017f9:	eb 09                	jmp    801804 <readn+0x4d>
  8017fb:	b8 00 00 00 00       	mov    $0x0,%eax
  801800:	eb 02                	jmp    801804 <readn+0x4d>
		m = read(fdnum, (char*)buf + tot, n - tot);
		if (m < 0)
			return m;
		if (m == 0)
  801802:	89 d8                	mov    %ebx,%eax
			break;
	}
	return tot;
}
  801804:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801807:	5b                   	pop    %ebx
  801808:	5e                   	pop    %esi
  801809:	5f                   	pop    %edi
  80180a:	c9                   	leave  
  80180b:	c3                   	ret    

0080180c <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80180c:	55                   	push   %ebp
  80180d:	89 e5                	mov    %esp,%ebp
  80180f:	53                   	push   %ebx
  801810:	83 ec 14             	sub    $0x14,%esp
  801813:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801816:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801819:	50                   	push   %eax
  80181a:	53                   	push   %ebx
  80181b:	e8 8f fc ff ff       	call   8014af <fd_lookup>
  801820:	83 c4 08             	add    $0x8,%esp
  801823:	85 c0                	test   %eax,%eax
  801825:	78 62                	js     801889 <write+0x7d>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801827:	83 ec 08             	sub    $0x8,%esp
  80182a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80182d:	50                   	push   %eax
  80182e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801831:	ff 30                	pushl  (%eax)
  801833:	e8 cd fc ff ff       	call   801505 <dev_lookup>
  801838:	83 c4 10             	add    $0x10,%esp
  80183b:	85 c0                	test   %eax,%eax
  80183d:	78 4a                	js     801889 <write+0x7d>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80183f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801842:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801846:	75 21                	jne    801869 <write+0x5d>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801848:	a1 04 40 80 00       	mov    0x804004,%eax
  80184d:	8b 40 48             	mov    0x48(%eax),%eax
  801850:	83 ec 04             	sub    $0x4,%esp
  801853:	53                   	push   %ebx
  801854:	50                   	push   %eax
  801855:	68 44 2b 80 00       	push   $0x802b44
  80185a:	e8 e5 ee ff ff       	call   800744 <cprintf>
		return -E_INVAL;
  80185f:	83 c4 10             	add    $0x10,%esp
  801862:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801867:	eb 20                	jmp    801889 <write+0x7d>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801869:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80186c:	8b 52 0c             	mov    0xc(%edx),%edx
  80186f:	85 d2                	test   %edx,%edx
  801871:	74 11                	je     801884 <write+0x78>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801873:	83 ec 04             	sub    $0x4,%esp
  801876:	ff 75 10             	pushl  0x10(%ebp)
  801879:	ff 75 0c             	pushl  0xc(%ebp)
  80187c:	50                   	push   %eax
  80187d:	ff d2                	call   *%edx
  80187f:	83 c4 10             	add    $0x10,%esp
  801882:	eb 05                	jmp    801889 <write+0x7d>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801884:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  801889:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80188c:	c9                   	leave  
  80188d:	c3                   	ret    

0080188e <seek>:

int
seek(int fdnum, off_t offset)
{
  80188e:	55                   	push   %ebp
  80188f:	89 e5                	mov    %esp,%ebp
  801891:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801894:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801897:	50                   	push   %eax
  801898:	ff 75 08             	pushl  0x8(%ebp)
  80189b:	e8 0f fc ff ff       	call   8014af <fd_lookup>
  8018a0:	83 c4 08             	add    $0x8,%esp
  8018a3:	85 c0                	test   %eax,%eax
  8018a5:	78 0e                	js     8018b5 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8018a7:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8018aa:	8b 55 0c             	mov    0xc(%ebp),%edx
  8018ad:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8018b0:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8018b5:	c9                   	leave  
  8018b6:	c3                   	ret    

008018b7 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8018b7:	55                   	push   %ebp
  8018b8:	89 e5                	mov    %esp,%ebp
  8018ba:	53                   	push   %ebx
  8018bb:	83 ec 14             	sub    $0x14,%esp
  8018be:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8018c1:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8018c4:	50                   	push   %eax
  8018c5:	53                   	push   %ebx
  8018c6:	e8 e4 fb ff ff       	call   8014af <fd_lookup>
  8018cb:	83 c4 08             	add    $0x8,%esp
  8018ce:	85 c0                	test   %eax,%eax
  8018d0:	78 5f                	js     801931 <ftruncate+0x7a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8018d2:	83 ec 08             	sub    $0x8,%esp
  8018d5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8018d8:	50                   	push   %eax
  8018d9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8018dc:	ff 30                	pushl  (%eax)
  8018de:	e8 22 fc ff ff       	call   801505 <dev_lookup>
  8018e3:	83 c4 10             	add    $0x10,%esp
  8018e6:	85 c0                	test   %eax,%eax
  8018e8:	78 47                	js     801931 <ftruncate+0x7a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8018ea:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8018ed:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8018f1:	75 21                	jne    801914 <ftruncate+0x5d>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8018f3:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8018f8:	8b 40 48             	mov    0x48(%eax),%eax
  8018fb:	83 ec 04             	sub    $0x4,%esp
  8018fe:	53                   	push   %ebx
  8018ff:	50                   	push   %eax
  801900:	68 04 2b 80 00       	push   $0x802b04
  801905:	e8 3a ee ff ff       	call   800744 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  80190a:	83 c4 10             	add    $0x10,%esp
  80190d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801912:	eb 1d                	jmp    801931 <ftruncate+0x7a>
	}
	if (!dev->dev_trunc)
  801914:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801917:	8b 52 18             	mov    0x18(%edx),%edx
  80191a:	85 d2                	test   %edx,%edx
  80191c:	74 0e                	je     80192c <ftruncate+0x75>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80191e:	83 ec 08             	sub    $0x8,%esp
  801921:	ff 75 0c             	pushl  0xc(%ebp)
  801924:	50                   	push   %eax
  801925:	ff d2                	call   *%edx
  801927:	83 c4 10             	add    $0x10,%esp
  80192a:	eb 05                	jmp    801931 <ftruncate+0x7a>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  80192c:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  801931:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801934:	c9                   	leave  
  801935:	c3                   	ret    

00801936 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801936:	55                   	push   %ebp
  801937:	89 e5                	mov    %esp,%ebp
  801939:	53                   	push   %ebx
  80193a:	83 ec 14             	sub    $0x14,%esp
  80193d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801940:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801943:	50                   	push   %eax
  801944:	ff 75 08             	pushl  0x8(%ebp)
  801947:	e8 63 fb ff ff       	call   8014af <fd_lookup>
  80194c:	83 c4 08             	add    $0x8,%esp
  80194f:	85 c0                	test   %eax,%eax
  801951:	78 52                	js     8019a5 <fstat+0x6f>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801953:	83 ec 08             	sub    $0x8,%esp
  801956:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801959:	50                   	push   %eax
  80195a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80195d:	ff 30                	pushl  (%eax)
  80195f:	e8 a1 fb ff ff       	call   801505 <dev_lookup>
  801964:	83 c4 10             	add    $0x10,%esp
  801967:	85 c0                	test   %eax,%eax
  801969:	78 3a                	js     8019a5 <fstat+0x6f>
		return r;
	if (!dev->dev_stat)
  80196b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80196e:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801972:	74 2c                	je     8019a0 <fstat+0x6a>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801974:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801977:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80197e:	00 00 00 
	stat->st_isdir = 0;
  801981:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801988:	00 00 00 
	stat->st_dev = dev;
  80198b:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801991:	83 ec 08             	sub    $0x8,%esp
  801994:	53                   	push   %ebx
  801995:	ff 75 f0             	pushl  -0x10(%ebp)
  801998:	ff 50 14             	call   *0x14(%eax)
  80199b:	83 c4 10             	add    $0x10,%esp
  80199e:	eb 05                	jmp    8019a5 <fstat+0x6f>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8019a0:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8019a5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8019a8:	c9                   	leave  
  8019a9:	c3                   	ret    

008019aa <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8019aa:	55                   	push   %ebp
  8019ab:	89 e5                	mov    %esp,%ebp
  8019ad:	56                   	push   %esi
  8019ae:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8019af:	83 ec 08             	sub    $0x8,%esp
  8019b2:	6a 00                	push   $0x0
  8019b4:	ff 75 08             	pushl  0x8(%ebp)
  8019b7:	e8 8b 01 00 00       	call   801b47 <open>
  8019bc:	89 c3                	mov    %eax,%ebx
  8019be:	83 c4 10             	add    $0x10,%esp
  8019c1:	85 c0                	test   %eax,%eax
  8019c3:	78 1b                	js     8019e0 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8019c5:	83 ec 08             	sub    $0x8,%esp
  8019c8:	ff 75 0c             	pushl  0xc(%ebp)
  8019cb:	50                   	push   %eax
  8019cc:	e8 65 ff ff ff       	call   801936 <fstat>
  8019d1:	89 c6                	mov    %eax,%esi
	close(fd);
  8019d3:	89 1c 24             	mov    %ebx,(%esp)
  8019d6:	e8 18 fc ff ff       	call   8015f3 <close>
	return r;
  8019db:	83 c4 10             	add    $0x10,%esp
  8019de:	89 f3                	mov    %esi,%ebx
}
  8019e0:	89 d8                	mov    %ebx,%eax
  8019e2:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8019e5:	5b                   	pop    %ebx
  8019e6:	5e                   	pop    %esi
  8019e7:	c9                   	leave  
  8019e8:	c3                   	ret    
  8019e9:	00 00                	add    %al,(%eax)
	...

008019ec <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8019ec:	55                   	push   %ebp
  8019ed:	89 e5                	mov    %esp,%ebp
  8019ef:	56                   	push   %esi
  8019f0:	53                   	push   %ebx
  8019f1:	89 c3                	mov    %eax,%ebx
  8019f3:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  8019f5:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8019fc:	75 12                	jne    801a10 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8019fe:	83 ec 0c             	sub    $0xc,%esp
  801a01:	6a 01                	push   $0x1
  801a03:	e8 b1 f9 ff ff       	call   8013b9 <ipc_find_env>
  801a08:	a3 00 40 80 00       	mov    %eax,0x804000
  801a0d:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801a10:	6a 07                	push   $0x7
  801a12:	68 00 50 80 00       	push   $0x805000
  801a17:	53                   	push   %ebx
  801a18:	ff 35 00 40 80 00    	pushl  0x804000
  801a1e:	e8 41 f9 ff ff       	call   801364 <ipc_send>
	
	return ipc_recv(NULL, dstva, NULL);
  801a23:	83 c4 0c             	add    $0xc,%esp
  801a26:	6a 00                	push   $0x0
  801a28:	56                   	push   %esi
  801a29:	6a 00                	push   $0x0
  801a2b:	e8 8c f8 ff ff       	call   8012bc <ipc_recv>
}
  801a30:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a33:	5b                   	pop    %ebx
  801a34:	5e                   	pop    %esi
  801a35:	c9                   	leave  
  801a36:	c3                   	ret    

00801a37 <devfile_stat>:
}


static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801a37:	55                   	push   %ebp
  801a38:	89 e5                	mov    %esp,%ebp
  801a3a:	53                   	push   %ebx
  801a3b:	83 ec 04             	sub    $0x4,%esp
  801a3e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801a41:	8b 45 08             	mov    0x8(%ebp),%eax
  801a44:	8b 40 0c             	mov    0xc(%eax),%eax
  801a47:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0) {
  801a4c:	ba 00 00 00 00       	mov    $0x0,%edx
  801a51:	b8 05 00 00 00       	mov    $0x5,%eax
  801a56:	e8 91 ff ff ff       	call   8019ec <fsipc>
  801a5b:	85 c0                	test   %eax,%eax
  801a5d:	78 39                	js     801a98 <devfile_stat+0x61>
		return r;
	}
	cprintf("OVER\n");
  801a5f:	83 ec 0c             	sub    $0xc,%esp
  801a62:	68 c1 2a 80 00       	push   $0x802ac1
  801a67:	e8 d8 ec ff ff       	call   800744 <cprintf>
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801a6c:	83 c4 08             	add    $0x8,%esp
  801a6f:	68 00 50 80 00       	push   $0x805000
  801a74:	53                   	push   %ebx
  801a75:	e8 80 f2 ff ff       	call   800cfa <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801a7a:	a1 80 50 80 00       	mov    0x805080,%eax
  801a7f:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801a85:	a1 84 50 80 00       	mov    0x805084,%eax
  801a8a:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801a90:	83 c4 10             	add    $0x10,%esp
  801a93:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801a98:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a9b:	c9                   	leave  
  801a9c:	c3                   	ret    

00801a9d <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801a9d:	55                   	push   %ebp
  801a9e:	89 e5                	mov    %esp,%ebp
  801aa0:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801aa3:	8b 45 08             	mov    0x8(%ebp),%eax
  801aa6:	8b 40 0c             	mov    0xc(%eax),%eax
  801aa9:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801aae:	ba 00 00 00 00       	mov    $0x0,%edx
  801ab3:	b8 06 00 00 00       	mov    $0x6,%eax
  801ab8:	e8 2f ff ff ff       	call   8019ec <fsipc>
}
  801abd:	c9                   	leave  
  801abe:	c3                   	ret    

00801abf <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801abf:	55                   	push   %ebp
  801ac0:	89 e5                	mov    %esp,%ebp
  801ac2:	56                   	push   %esi
  801ac3:	53                   	push   %ebx
  801ac4:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801ac7:	8b 45 08             	mov    0x8(%ebp),%eax
  801aca:	8b 40 0c             	mov    0xc(%eax),%eax
  801acd:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801ad2:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801ad8:	ba 00 00 00 00       	mov    $0x0,%edx
  801add:	b8 03 00 00 00       	mov    $0x3,%eax
  801ae2:	e8 05 ff ff ff       	call   8019ec <fsipc>
  801ae7:	89 c3                	mov    %eax,%ebx
  801ae9:	85 c0                	test   %eax,%eax
  801aeb:	78 51                	js     801b3e <devfile_read+0x7f>
		return r;
	assert(r <= n);
  801aed:	39 c6                	cmp    %eax,%esi
  801aef:	73 19                	jae    801b0a <devfile_read+0x4b>
  801af1:	68 74 2b 80 00       	push   $0x802b74
  801af6:	68 7b 2b 80 00       	push   $0x802b7b
  801afb:	68 80 00 00 00       	push   $0x80
  801b00:	68 90 2b 80 00       	push   $0x802b90
  801b05:	e8 62 eb ff ff       	call   80066c <_panic>
	assert(r <= PGSIZE);
  801b0a:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801b0f:	7e 19                	jle    801b2a <devfile_read+0x6b>
  801b11:	68 9b 2b 80 00       	push   $0x802b9b
  801b16:	68 7b 2b 80 00       	push   $0x802b7b
  801b1b:	68 81 00 00 00       	push   $0x81
  801b20:	68 90 2b 80 00       	push   $0x802b90
  801b25:	e8 42 eb ff ff       	call   80066c <_panic>
	memmove(buf, &fsipcbuf, r);
  801b2a:	83 ec 04             	sub    $0x4,%esp
  801b2d:	50                   	push   %eax
  801b2e:	68 00 50 80 00       	push   $0x805000
  801b33:	ff 75 0c             	pushl  0xc(%ebp)
  801b36:	e8 80 f3 ff ff       	call   800ebb <memmove>
	return r;
  801b3b:	83 c4 10             	add    $0x10,%esp
}
  801b3e:	89 d8                	mov    %ebx,%eax
  801b40:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801b43:	5b                   	pop    %ebx
  801b44:	5e                   	pop    %esi
  801b45:	c9                   	leave  
  801b46:	c3                   	ret    

00801b47 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801b47:	55                   	push   %ebp
  801b48:	89 e5                	mov    %esp,%ebp
  801b4a:	56                   	push   %esi
  801b4b:	53                   	push   %ebx
  801b4c:	83 ec 1c             	sub    $0x1c,%esp
  801b4f:	8b 75 08             	mov    0x8(%ebp),%esi
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801b52:	56                   	push   %esi
  801b53:	e8 50 f1 ff ff       	call   800ca8 <strlen>
  801b58:	83 c4 10             	add    $0x10,%esp
  801b5b:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801b60:	7f 72                	jg     801bd4 <open+0x8d>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801b62:	83 ec 0c             	sub    $0xc,%esp
  801b65:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801b68:	50                   	push   %eax
  801b69:	e8 ce f8 ff ff       	call   80143c <fd_alloc>
  801b6e:	89 c3                	mov    %eax,%ebx
  801b70:	83 c4 10             	add    $0x10,%esp
  801b73:	85 c0                	test   %eax,%eax
  801b75:	78 62                	js     801bd9 <open+0x92>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801b77:	83 ec 08             	sub    $0x8,%esp
  801b7a:	56                   	push   %esi
  801b7b:	68 00 50 80 00       	push   $0x805000
  801b80:	e8 75 f1 ff ff       	call   800cfa <strcpy>
	fsipcbuf.open.req_omode = mode;
  801b85:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b88:	a3 00 54 80 00       	mov    %eax,0x805400



	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801b8d:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801b90:	b8 01 00 00 00       	mov    $0x1,%eax
  801b95:	e8 52 fe ff ff       	call   8019ec <fsipc>
  801b9a:	89 c3                	mov    %eax,%ebx
  801b9c:	83 c4 10             	add    $0x10,%esp
  801b9f:	85 c0                	test   %eax,%eax
  801ba1:	79 12                	jns    801bb5 <open+0x6e>
		fd_close(fd, 0);
  801ba3:	83 ec 08             	sub    $0x8,%esp
  801ba6:	6a 00                	push   $0x0
  801ba8:	ff 75 f4             	pushl  -0xc(%ebp)
  801bab:	e8 bb f9 ff ff       	call   80156b <fd_close>
		return r;
  801bb0:	83 c4 10             	add    $0x10,%esp
  801bb3:	eb 24                	jmp    801bd9 <open+0x92>
	}


	cprintf("OPEN\n");
  801bb5:	83 ec 0c             	sub    $0xc,%esp
  801bb8:	68 a7 2b 80 00       	push   $0x802ba7
  801bbd:	e8 82 eb ff ff       	call   800744 <cprintf>

	return fd2num(fd);
  801bc2:	83 c4 04             	add    $0x4,%esp
  801bc5:	ff 75 f4             	pushl  -0xc(%ebp)
  801bc8:	e8 47 f8 ff ff       	call   801414 <fd2num>
  801bcd:	89 c3                	mov    %eax,%ebx
  801bcf:	83 c4 10             	add    $0x10,%esp
  801bd2:	eb 05                	jmp    801bd9 <open+0x92>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801bd4:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx


	cprintf("OPEN\n");

	return fd2num(fd);
}
  801bd9:	89 d8                	mov    %ebx,%eax
  801bdb:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801bde:	5b                   	pop    %ebx
  801bdf:	5e                   	pop    %esi
  801be0:	c9                   	leave  
  801be1:	c3                   	ret    
	...

00801be4 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801be4:	55                   	push   %ebp
  801be5:	89 e5                	mov    %esp,%ebp
  801be7:	56                   	push   %esi
  801be8:	53                   	push   %ebx
  801be9:	8b 75 0c             	mov    0xc(%ebp),%esi
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801bec:	83 ec 0c             	sub    $0xc,%esp
  801bef:	ff 75 08             	pushl  0x8(%ebp)
  801bf2:	e8 2d f8 ff ff       	call   801424 <fd2data>
  801bf7:	89 c3                	mov    %eax,%ebx
	strcpy(stat->st_name, "<pipe>");
  801bf9:	83 c4 08             	add    $0x8,%esp
  801bfc:	68 ad 2b 80 00       	push   $0x802bad
  801c01:	56                   	push   %esi
  801c02:	e8 f3 f0 ff ff       	call   800cfa <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801c07:	8b 43 04             	mov    0x4(%ebx),%eax
  801c0a:	2b 03                	sub    (%ebx),%eax
  801c0c:	89 86 80 00 00 00    	mov    %eax,0x80(%esi)
	stat->st_isdir = 0;
  801c12:	c7 86 84 00 00 00 00 	movl   $0x0,0x84(%esi)
  801c19:	00 00 00 
	stat->st_dev = &devpipe;
  801c1c:	c7 86 88 00 00 00 24 	movl   $0x803024,0x88(%esi)
  801c23:	30 80 00 
	return 0;
}
  801c26:	b8 00 00 00 00       	mov    $0x0,%eax
  801c2b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801c2e:	5b                   	pop    %ebx
  801c2f:	5e                   	pop    %esi
  801c30:	c9                   	leave  
  801c31:	c3                   	ret    

00801c32 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801c32:	55                   	push   %ebp
  801c33:	89 e5                	mov    %esp,%ebp
  801c35:	53                   	push   %ebx
  801c36:	83 ec 0c             	sub    $0xc,%esp
  801c39:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801c3c:	53                   	push   %ebx
  801c3d:	6a 00                	push   $0x0
  801c3f:	e8 82 f5 ff ff       	call   8011c6 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801c44:	89 1c 24             	mov    %ebx,(%esp)
  801c47:	e8 d8 f7 ff ff       	call   801424 <fd2data>
  801c4c:	83 c4 08             	add    $0x8,%esp
  801c4f:	50                   	push   %eax
  801c50:	6a 00                	push   $0x0
  801c52:	e8 6f f5 ff ff       	call   8011c6 <sys_page_unmap>
}
  801c57:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801c5a:	c9                   	leave  
  801c5b:	c3                   	ret    

00801c5c <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801c5c:	55                   	push   %ebp
  801c5d:	89 e5                	mov    %esp,%ebp
  801c5f:	57                   	push   %edi
  801c60:	56                   	push   %esi
  801c61:	53                   	push   %ebx
  801c62:	83 ec 1c             	sub    $0x1c,%esp
  801c65:	89 c7                	mov    %eax,%edi
  801c67:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801c6a:	a1 04 40 80 00       	mov    0x804004,%eax
  801c6f:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801c72:	83 ec 0c             	sub    $0xc,%esp
  801c75:	57                   	push   %edi
  801c76:	e8 6d 04 00 00       	call   8020e8 <pageref>
  801c7b:	89 c6                	mov    %eax,%esi
  801c7d:	83 c4 04             	add    $0x4,%esp
  801c80:	ff 75 e4             	pushl  -0x1c(%ebp)
  801c83:	e8 60 04 00 00       	call   8020e8 <pageref>
  801c88:	83 c4 10             	add    $0x10,%esp
  801c8b:	39 c6                	cmp    %eax,%esi
  801c8d:	0f 94 c0             	sete   %al
  801c90:	0f b6 c0             	movzbl %al,%eax
		nn = thisenv->env_runs;
  801c93:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801c99:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801c9c:	39 cb                	cmp    %ecx,%ebx
  801c9e:	75 08                	jne    801ca8 <_pipeisclosed+0x4c>
			return ret;
		if (n != nn && ret == 1)
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
	}
}
  801ca0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801ca3:	5b                   	pop    %ebx
  801ca4:	5e                   	pop    %esi
  801ca5:	5f                   	pop    %edi
  801ca6:	c9                   	leave  
  801ca7:	c3                   	ret    
		n = thisenv->env_runs;
		ret = pageref(fd) == pageref(p);
		nn = thisenv->env_runs;
		if (n == nn)
			return ret;
		if (n != nn && ret == 1)
  801ca8:	83 f8 01             	cmp    $0x1,%eax
  801cab:	75 bd                	jne    801c6a <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801cad:	8b 42 58             	mov    0x58(%edx),%eax
  801cb0:	6a 01                	push   $0x1
  801cb2:	50                   	push   %eax
  801cb3:	53                   	push   %ebx
  801cb4:	68 b4 2b 80 00       	push   $0x802bb4
  801cb9:	e8 86 ea ff ff       	call   800744 <cprintf>
  801cbe:	83 c4 10             	add    $0x10,%esp
  801cc1:	eb a7                	jmp    801c6a <_pipeisclosed+0xe>

00801cc3 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801cc3:	55                   	push   %ebp
  801cc4:	89 e5                	mov    %esp,%ebp
  801cc6:	57                   	push   %edi
  801cc7:	56                   	push   %esi
  801cc8:	53                   	push   %ebx
  801cc9:	83 ec 28             	sub    $0x28,%esp
  801ccc:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801ccf:	56                   	push   %esi
  801cd0:	e8 4f f7 ff ff       	call   801424 <fd2data>
  801cd5:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801cd7:	83 c4 10             	add    $0x10,%esp
  801cda:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801cde:	75 4a                	jne    801d2a <devpipe_write+0x67>
  801ce0:	bf 00 00 00 00       	mov    $0x0,%edi
  801ce5:	eb 56                	jmp    801d3d <devpipe_write+0x7a>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801ce7:	89 da                	mov    %ebx,%edx
  801ce9:	89 f0                	mov    %esi,%eax
  801ceb:	e8 6c ff ff ff       	call   801c5c <_pipeisclosed>
  801cf0:	85 c0                	test   %eax,%eax
  801cf2:	75 4d                	jne    801d41 <devpipe_write+0x7e>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801cf4:	e8 5c f4 ff ff       	call   801155 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801cf9:	8b 43 04             	mov    0x4(%ebx),%eax
  801cfc:	8b 13                	mov    (%ebx),%edx
  801cfe:	83 c2 20             	add    $0x20,%edx
  801d01:	39 d0                	cmp    %edx,%eax
  801d03:	73 e2                	jae    801ce7 <devpipe_write+0x24>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801d05:	89 c2                	mov    %eax,%edx
  801d07:	81 e2 1f 00 00 80    	and    $0x8000001f,%edx
  801d0d:	79 05                	jns    801d14 <devpipe_write+0x51>
  801d0f:	4a                   	dec    %edx
  801d10:	83 ca e0             	or     $0xffffffe0,%edx
  801d13:	42                   	inc    %edx
  801d14:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801d17:	8a 0c 39             	mov    (%ecx,%edi,1),%cl
  801d1a:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801d1e:	40                   	inc    %eax
  801d1f:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801d22:	47                   	inc    %edi
  801d23:	39 7d 10             	cmp    %edi,0x10(%ebp)
  801d26:	77 07                	ja     801d2f <devpipe_write+0x6c>
  801d28:	eb 13                	jmp    801d3d <devpipe_write+0x7a>
  801d2a:	bf 00 00 00 00       	mov    $0x0,%edi
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801d2f:	8b 43 04             	mov    0x4(%ebx),%eax
  801d32:	8b 13                	mov    (%ebx),%edx
  801d34:	83 c2 20             	add    $0x20,%edx
  801d37:	39 d0                	cmp    %edx,%eax
  801d39:	73 ac                	jae    801ce7 <devpipe_write+0x24>
  801d3b:	eb c8                	jmp    801d05 <devpipe_write+0x42>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801d3d:	89 f8                	mov    %edi,%eax
  801d3f:	eb 05                	jmp    801d46 <devpipe_write+0x83>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801d41:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801d46:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801d49:	5b                   	pop    %ebx
  801d4a:	5e                   	pop    %esi
  801d4b:	5f                   	pop    %edi
  801d4c:	c9                   	leave  
  801d4d:	c3                   	ret    

00801d4e <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801d4e:	55                   	push   %ebp
  801d4f:	89 e5                	mov    %esp,%ebp
  801d51:	57                   	push   %edi
  801d52:	56                   	push   %esi
  801d53:	53                   	push   %ebx
  801d54:	83 ec 18             	sub    $0x18,%esp
  801d57:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801d5a:	57                   	push   %edi
  801d5b:	e8 c4 f6 ff ff       	call   801424 <fd2data>
  801d60:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801d62:	83 c4 10             	add    $0x10,%esp
  801d65:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801d69:	75 44                	jne    801daf <devpipe_read+0x61>
  801d6b:	be 00 00 00 00       	mov    $0x0,%esi
  801d70:	eb 4f                	jmp    801dc1 <devpipe_read+0x73>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
				return i;
  801d72:	89 f0                	mov    %esi,%eax
  801d74:	eb 54                	jmp    801dca <devpipe_read+0x7c>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801d76:	89 da                	mov    %ebx,%edx
  801d78:	89 f8                	mov    %edi,%eax
  801d7a:	e8 dd fe ff ff       	call   801c5c <_pipeisclosed>
  801d7f:	85 c0                	test   %eax,%eax
  801d81:	75 42                	jne    801dc5 <devpipe_read+0x77>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801d83:	e8 cd f3 ff ff       	call   801155 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801d88:	8b 03                	mov    (%ebx),%eax
  801d8a:	3b 43 04             	cmp    0x4(%ebx),%eax
  801d8d:	74 e7                	je     801d76 <devpipe_read+0x28>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801d8f:	25 1f 00 00 80       	and    $0x8000001f,%eax
  801d94:	79 05                	jns    801d9b <devpipe_read+0x4d>
  801d96:	48                   	dec    %eax
  801d97:	83 c8 e0             	or     $0xffffffe0,%eax
  801d9a:	40                   	inc    %eax
  801d9b:	8a 44 03 08          	mov    0x8(%ebx,%eax,1),%al
  801d9f:	8b 55 0c             	mov    0xc(%ebp),%edx
  801da2:	88 04 32             	mov    %al,(%edx,%esi,1)
		p->p_rpos++;
  801da5:	ff 03                	incl   (%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801da7:	46                   	inc    %esi
  801da8:	39 75 10             	cmp    %esi,0x10(%ebp)
  801dab:	77 07                	ja     801db4 <devpipe_read+0x66>
  801dad:	eb 12                	jmp    801dc1 <devpipe_read+0x73>
  801daf:	be 00 00 00 00       	mov    $0x0,%esi
		while (p->p_rpos == p->p_wpos) {
  801db4:	8b 03                	mov    (%ebx),%eax
  801db6:	3b 43 04             	cmp    0x4(%ebx),%eax
  801db9:	75 d4                	jne    801d8f <devpipe_read+0x41>
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801dbb:	85 f6                	test   %esi,%esi
  801dbd:	75 b3                	jne    801d72 <devpipe_read+0x24>
  801dbf:	eb b5                	jmp    801d76 <devpipe_read+0x28>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801dc1:	89 f0                	mov    %esi,%eax
  801dc3:	eb 05                	jmp    801dca <devpipe_read+0x7c>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801dc5:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801dca:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801dcd:	5b                   	pop    %ebx
  801dce:	5e                   	pop    %esi
  801dcf:	5f                   	pop    %edi
  801dd0:	c9                   	leave  
  801dd1:	c3                   	ret    

00801dd2 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801dd2:	55                   	push   %ebp
  801dd3:	89 e5                	mov    %esp,%ebp
  801dd5:	57                   	push   %edi
  801dd6:	56                   	push   %esi
  801dd7:	53                   	push   %ebx
  801dd8:	83 ec 28             	sub    $0x28,%esp
  801ddb:	8b 7d 08             	mov    0x8(%ebp),%edi
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801dde:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801de1:	50                   	push   %eax
  801de2:	e8 55 f6 ff ff       	call   80143c <fd_alloc>
  801de7:	89 c3                	mov    %eax,%ebx
  801de9:	83 c4 10             	add    $0x10,%esp
  801dec:	85 c0                	test   %eax,%eax
  801dee:	0f 88 24 01 00 00    	js     801f18 <pipe+0x146>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801df4:	83 ec 04             	sub    $0x4,%esp
  801df7:	68 07 04 00 00       	push   $0x407
  801dfc:	ff 75 e4             	pushl  -0x1c(%ebp)
  801dff:	6a 00                	push   $0x0
  801e01:	e8 76 f3 ff ff       	call   80117c <sys_page_alloc>
  801e06:	89 c3                	mov    %eax,%ebx
  801e08:	83 c4 10             	add    $0x10,%esp
  801e0b:	85 c0                	test   %eax,%eax
  801e0d:	0f 88 05 01 00 00    	js     801f18 <pipe+0x146>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801e13:	83 ec 0c             	sub    $0xc,%esp
  801e16:	8d 45 e0             	lea    -0x20(%ebp),%eax
  801e19:	50                   	push   %eax
  801e1a:	e8 1d f6 ff ff       	call   80143c <fd_alloc>
  801e1f:	89 c3                	mov    %eax,%ebx
  801e21:	83 c4 10             	add    $0x10,%esp
  801e24:	85 c0                	test   %eax,%eax
  801e26:	0f 88 dc 00 00 00    	js     801f08 <pipe+0x136>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801e2c:	83 ec 04             	sub    $0x4,%esp
  801e2f:	68 07 04 00 00       	push   $0x407
  801e34:	ff 75 e0             	pushl  -0x20(%ebp)
  801e37:	6a 00                	push   $0x0
  801e39:	e8 3e f3 ff ff       	call   80117c <sys_page_alloc>
  801e3e:	89 c3                	mov    %eax,%ebx
  801e40:	83 c4 10             	add    $0x10,%esp
  801e43:	85 c0                	test   %eax,%eax
  801e45:	0f 88 bd 00 00 00    	js     801f08 <pipe+0x136>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801e4b:	83 ec 0c             	sub    $0xc,%esp
  801e4e:	ff 75 e4             	pushl  -0x1c(%ebp)
  801e51:	e8 ce f5 ff ff       	call   801424 <fd2data>
  801e56:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801e58:	83 c4 0c             	add    $0xc,%esp
  801e5b:	68 07 04 00 00       	push   $0x407
  801e60:	50                   	push   %eax
  801e61:	6a 00                	push   $0x0
  801e63:	e8 14 f3 ff ff       	call   80117c <sys_page_alloc>
  801e68:	89 c3                	mov    %eax,%ebx
  801e6a:	83 c4 10             	add    $0x10,%esp
  801e6d:	85 c0                	test   %eax,%eax
  801e6f:	0f 88 83 00 00 00    	js     801ef8 <pipe+0x126>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801e75:	83 ec 0c             	sub    $0xc,%esp
  801e78:	ff 75 e0             	pushl  -0x20(%ebp)
  801e7b:	e8 a4 f5 ff ff       	call   801424 <fd2data>
  801e80:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801e87:	50                   	push   %eax
  801e88:	6a 00                	push   $0x0
  801e8a:	56                   	push   %esi
  801e8b:	6a 00                	push   $0x0
  801e8d:	e8 0e f3 ff ff       	call   8011a0 <sys_page_map>
  801e92:	89 c3                	mov    %eax,%ebx
  801e94:	83 c4 20             	add    $0x20,%esp
  801e97:	85 c0                	test   %eax,%eax
  801e99:	78 4f                	js     801eea <pipe+0x118>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801e9b:	8b 15 24 30 80 00    	mov    0x803024,%edx
  801ea1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801ea4:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801ea6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801ea9:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801eb0:	8b 15 24 30 80 00    	mov    0x803024,%edx
  801eb6:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801eb9:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801ebb:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801ebe:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801ec5:	83 ec 0c             	sub    $0xc,%esp
  801ec8:	ff 75 e4             	pushl  -0x1c(%ebp)
  801ecb:	e8 44 f5 ff ff       	call   801414 <fd2num>
  801ed0:	89 07                	mov    %eax,(%edi)
	pfd[1] = fd2num(fd1);
  801ed2:	83 c4 04             	add    $0x4,%esp
  801ed5:	ff 75 e0             	pushl  -0x20(%ebp)
  801ed8:	e8 37 f5 ff ff       	call   801414 <fd2num>
  801edd:	89 47 04             	mov    %eax,0x4(%edi)
	return 0;
  801ee0:	83 c4 10             	add    $0x10,%esp
  801ee3:	bb 00 00 00 00       	mov    $0x0,%ebx
  801ee8:	eb 2e                	jmp    801f18 <pipe+0x146>

    err3:
	sys_page_unmap(0, va);
  801eea:	83 ec 08             	sub    $0x8,%esp
  801eed:	56                   	push   %esi
  801eee:	6a 00                	push   $0x0
  801ef0:	e8 d1 f2 ff ff       	call   8011c6 <sys_page_unmap>
  801ef5:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801ef8:	83 ec 08             	sub    $0x8,%esp
  801efb:	ff 75 e0             	pushl  -0x20(%ebp)
  801efe:	6a 00                	push   $0x0
  801f00:	e8 c1 f2 ff ff       	call   8011c6 <sys_page_unmap>
  801f05:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801f08:	83 ec 08             	sub    $0x8,%esp
  801f0b:	ff 75 e4             	pushl  -0x1c(%ebp)
  801f0e:	6a 00                	push   $0x0
  801f10:	e8 b1 f2 ff ff       	call   8011c6 <sys_page_unmap>
  801f15:	83 c4 10             	add    $0x10,%esp
    err:
	return r;
}
  801f18:	89 d8                	mov    %ebx,%eax
  801f1a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801f1d:	5b                   	pop    %ebx
  801f1e:	5e                   	pop    %esi
  801f1f:	5f                   	pop    %edi
  801f20:	c9                   	leave  
  801f21:	c3                   	ret    

00801f22 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801f22:	55                   	push   %ebp
  801f23:	89 e5                	mov    %esp,%ebp
  801f25:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801f28:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801f2b:	50                   	push   %eax
  801f2c:	ff 75 08             	pushl  0x8(%ebp)
  801f2f:	e8 7b f5 ff ff       	call   8014af <fd_lookup>
  801f34:	83 c4 10             	add    $0x10,%esp
  801f37:	85 c0                	test   %eax,%eax
  801f39:	78 18                	js     801f53 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801f3b:	83 ec 0c             	sub    $0xc,%esp
  801f3e:	ff 75 f4             	pushl  -0xc(%ebp)
  801f41:	e8 de f4 ff ff       	call   801424 <fd2data>
	return _pipeisclosed(fd, p);
  801f46:	89 c2                	mov    %eax,%edx
  801f48:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f4b:	e8 0c fd ff ff       	call   801c5c <_pipeisclosed>
  801f50:	83 c4 10             	add    $0x10,%esp
}
  801f53:	c9                   	leave  
  801f54:	c3                   	ret    
  801f55:	00 00                	add    %al,(%eax)
	...

00801f58 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801f58:	55                   	push   %ebp
  801f59:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801f5b:	b8 00 00 00 00       	mov    $0x0,%eax
  801f60:	c9                   	leave  
  801f61:	c3                   	ret    

00801f62 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801f62:	55                   	push   %ebp
  801f63:	89 e5                	mov    %esp,%ebp
  801f65:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801f68:	68 cc 2b 80 00       	push   $0x802bcc
  801f6d:	ff 75 0c             	pushl  0xc(%ebp)
  801f70:	e8 85 ed ff ff       	call   800cfa <strcpy>
	return 0;
}
  801f75:	b8 00 00 00 00       	mov    $0x0,%eax
  801f7a:	c9                   	leave  
  801f7b:	c3                   	ret    

00801f7c <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801f7c:	55                   	push   %ebp
  801f7d:	89 e5                	mov    %esp,%ebp
  801f7f:	57                   	push   %edi
  801f80:	56                   	push   %esi
  801f81:	53                   	push   %ebx
  801f82:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801f88:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801f8c:	74 45                	je     801fd3 <devcons_write+0x57>
  801f8e:	b8 00 00 00 00       	mov    $0x0,%eax
  801f93:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801f98:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801f9e:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801fa1:	29 c3                	sub    %eax,%ebx
		if (m > sizeof(buf) - 1)
  801fa3:	83 fb 7f             	cmp    $0x7f,%ebx
  801fa6:	76 05                	jbe    801fad <devcons_write+0x31>
			m = sizeof(buf) - 1;
  801fa8:	bb 7f 00 00 00       	mov    $0x7f,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  801fad:	83 ec 04             	sub    $0x4,%esp
  801fb0:	53                   	push   %ebx
  801fb1:	03 45 0c             	add    0xc(%ebp),%eax
  801fb4:	50                   	push   %eax
  801fb5:	57                   	push   %edi
  801fb6:	e8 00 ef ff ff       	call   800ebb <memmove>
		sys_cputs(buf, m);
  801fbb:	83 c4 08             	add    $0x8,%esp
  801fbe:	53                   	push   %ebx
  801fbf:	57                   	push   %edi
  801fc0:	e8 00 f1 ff ff       	call   8010c5 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801fc5:	01 de                	add    %ebx,%esi
  801fc7:	89 f0                	mov    %esi,%eax
  801fc9:	83 c4 10             	add    $0x10,%esp
  801fcc:	3b 75 10             	cmp    0x10(%ebp),%esi
  801fcf:	72 cd                	jb     801f9e <devcons_write+0x22>
  801fd1:	eb 05                	jmp    801fd8 <devcons_write+0x5c>
  801fd3:	be 00 00 00 00       	mov    $0x0,%esi
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801fd8:	89 f0                	mov    %esi,%eax
  801fda:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801fdd:	5b                   	pop    %ebx
  801fde:	5e                   	pop    %esi
  801fdf:	5f                   	pop    %edi
  801fe0:	c9                   	leave  
  801fe1:	c3                   	ret    

00801fe2 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801fe2:	55                   	push   %ebp
  801fe3:	89 e5                	mov    %esp,%ebp
  801fe5:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
  801fe8:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801fec:	75 07                	jne    801ff5 <devcons_read+0x13>
  801fee:	eb 25                	jmp    802015 <devcons_read+0x33>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801ff0:	e8 60 f1 ff ff       	call   801155 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801ff5:	e8 f1 f0 ff ff       	call   8010eb <sys_cgetc>
  801ffa:	85 c0                	test   %eax,%eax
  801ffc:	74 f2                	je     801ff0 <devcons_read+0xe>
  801ffe:	89 c2                	mov    %eax,%edx
		sys_yield();
	if (c < 0)
  802000:	85 c0                	test   %eax,%eax
  802002:	78 1d                	js     802021 <devcons_read+0x3f>
		return c;
	if (c == 0x04)	// ctl-d is eof
  802004:	83 f8 04             	cmp    $0x4,%eax
  802007:	74 13                	je     80201c <devcons_read+0x3a>
		return 0;
	*(char*)vbuf = c;
  802009:	8b 45 0c             	mov    0xc(%ebp),%eax
  80200c:	88 10                	mov    %dl,(%eax)
	return 1;
  80200e:	b8 01 00 00 00       	mov    $0x1,%eax
  802013:	eb 0c                	jmp    802021 <devcons_read+0x3f>
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
		return 0;
  802015:	b8 00 00 00 00       	mov    $0x0,%eax
  80201a:	eb 05                	jmp    802021 <devcons_read+0x3f>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  80201c:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  802021:	c9                   	leave  
  802022:	c3                   	ret    

00802023 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  802023:	55                   	push   %ebp
  802024:	89 e5                	mov    %esp,%ebp
  802026:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  802029:	8b 45 08             	mov    0x8(%ebp),%eax
  80202c:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  80202f:	6a 01                	push   $0x1
  802031:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802034:	50                   	push   %eax
  802035:	e8 8b f0 ff ff       	call   8010c5 <sys_cputs>
  80203a:	83 c4 10             	add    $0x10,%esp
}
  80203d:	c9                   	leave  
  80203e:	c3                   	ret    

0080203f <getchar>:

int
getchar(void)
{
  80203f:	55                   	push   %ebp
  802040:	89 e5                	mov    %esp,%ebp
  802042:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  802045:	6a 01                	push   $0x1
  802047:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80204a:	50                   	push   %eax
  80204b:	6a 00                	push   $0x0
  80204d:	e8 de f6 ff ff       	call   801730 <read>
	if (r < 0)
  802052:	83 c4 10             	add    $0x10,%esp
  802055:	85 c0                	test   %eax,%eax
  802057:	78 0f                	js     802068 <getchar+0x29>
		return r;
	if (r < 1)
  802059:	85 c0                	test   %eax,%eax
  80205b:	7e 06                	jle    802063 <getchar+0x24>
		return -E_EOF;
	return c;
  80205d:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  802061:	eb 05                	jmp    802068 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  802063:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  802068:	c9                   	leave  
  802069:	c3                   	ret    

0080206a <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  80206a:	55                   	push   %ebp
  80206b:	89 e5                	mov    %esp,%ebp
  80206d:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802070:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802073:	50                   	push   %eax
  802074:	ff 75 08             	pushl  0x8(%ebp)
  802077:	e8 33 f4 ff ff       	call   8014af <fd_lookup>
  80207c:	83 c4 10             	add    $0x10,%esp
  80207f:	85 c0                	test   %eax,%eax
  802081:	78 11                	js     802094 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  802083:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802086:	8b 15 40 30 80 00    	mov    0x803040,%edx
  80208c:	39 10                	cmp    %edx,(%eax)
  80208e:	0f 94 c0             	sete   %al
  802091:	0f b6 c0             	movzbl %al,%eax
}
  802094:	c9                   	leave  
  802095:	c3                   	ret    

00802096 <opencons>:

int
opencons(void)
{
  802096:	55                   	push   %ebp
  802097:	89 e5                	mov    %esp,%ebp
  802099:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  80209c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80209f:	50                   	push   %eax
  8020a0:	e8 97 f3 ff ff       	call   80143c <fd_alloc>
  8020a5:	83 c4 10             	add    $0x10,%esp
  8020a8:	85 c0                	test   %eax,%eax
  8020aa:	78 3a                	js     8020e6 <opencons+0x50>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8020ac:	83 ec 04             	sub    $0x4,%esp
  8020af:	68 07 04 00 00       	push   $0x407
  8020b4:	ff 75 f4             	pushl  -0xc(%ebp)
  8020b7:	6a 00                	push   $0x0
  8020b9:	e8 be f0 ff ff       	call   80117c <sys_page_alloc>
  8020be:	83 c4 10             	add    $0x10,%esp
  8020c1:	85 c0                	test   %eax,%eax
  8020c3:	78 21                	js     8020e6 <opencons+0x50>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  8020c5:	8b 15 40 30 80 00    	mov    0x803040,%edx
  8020cb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8020ce:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  8020d0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8020d3:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  8020da:	83 ec 0c             	sub    $0xc,%esp
  8020dd:	50                   	push   %eax
  8020de:	e8 31 f3 ff ff       	call   801414 <fd2num>
  8020e3:	83 c4 10             	add    $0x10,%esp
}
  8020e6:	c9                   	leave  
  8020e7:	c3                   	ret    

008020e8 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  8020e8:	55                   	push   %ebp
  8020e9:	89 e5                	mov    %esp,%ebp
  8020eb:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8020ee:	89 c2                	mov    %eax,%edx
  8020f0:	c1 ea 16             	shr    $0x16,%edx
  8020f3:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8020fa:	f6 c2 01             	test   $0x1,%dl
  8020fd:	74 1e                	je     80211d <pageref+0x35>
		return 0;
	pte = uvpt[PGNUM(v)];
  8020ff:	c1 e8 0c             	shr    $0xc,%eax
  802102:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  802109:	a8 01                	test   $0x1,%al
  80210b:	74 17                	je     802124 <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  80210d:	c1 e8 0c             	shr    $0xc,%eax
  802110:	66 8b 04 c5 04 00 00 	mov    -0x10fffffc(,%eax,8),%ax
  802117:	ef 
  802118:	0f b7 c0             	movzwl %ax,%eax
  80211b:	eb 0c                	jmp    802129 <pageref+0x41>
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
		return 0;
  80211d:	b8 00 00 00 00       	mov    $0x0,%eax
  802122:	eb 05                	jmp    802129 <pageref+0x41>
	pte = uvpt[PGNUM(v)];
	if (!(pte & PTE_P))
		return 0;
  802124:	b8 00 00 00 00       	mov    $0x0,%eax
	return pages[PGNUM(pte)].pp_ref;
}
  802129:	c9                   	leave  
  80212a:	c3                   	ret    
	...

0080212c <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  80212c:	55                   	push   %ebp
  80212d:	89 e5                	mov    %esp,%ebp
  80212f:	57                   	push   %edi
  802130:	56                   	push   %esi
  802131:	83 ec 10             	sub    $0x10,%esp
  802134:	8b 7d 08             	mov    0x8(%ebp),%edi
  802137:	8b 4d 10             	mov    0x10(%ebp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  80213a:	89 7d f0             	mov    %edi,-0x10(%ebp)
  80213d:	8b 75 0c             	mov    0xc(%ebp),%esi
  const DWunion dd = {.ll = d};
  802140:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  802143:	8b 45 14             	mov    0x14(%ebp),%eax
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  802146:	85 c0                	test   %eax,%eax
  802148:	75 2e                	jne    802178 <__udivdi3+0x4c>
    {
      if (d0 > n1)
  80214a:	39 f1                	cmp    %esi,%ecx
  80214c:	77 5a                	ja     8021a8 <__udivdi3+0x7c>
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  80214e:	85 c9                	test   %ecx,%ecx
  802150:	75 0b                	jne    80215d <__udivdi3+0x31>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  802152:	b8 01 00 00 00       	mov    $0x1,%eax
  802157:	31 d2                	xor    %edx,%edx
  802159:	f7 f1                	div    %ecx
  80215b:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  80215d:	31 d2                	xor    %edx,%edx
  80215f:	89 f0                	mov    %esi,%eax
  802161:	f7 f1                	div    %ecx
  802163:	89 c6                	mov    %eax,%esi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  802165:	89 f8                	mov    %edi,%eax
  802167:	f7 f1                	div    %ecx
  802169:	89 c7                	mov    %eax,%edi
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
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  802178:	39 f0                	cmp    %esi,%eax
  80217a:	77 1c                	ja     802198 <__udivdi3+0x6c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  80217c:	0f bd f8             	bsr    %eax,%edi
	  if (bm == 0)
  80217f:	83 f7 1f             	xor    $0x1f,%edi
  802182:	75 3c                	jne    8021c0 <__udivdi3+0x94>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  802184:	39 f0                	cmp    %esi,%eax
  802186:	0f 82 90 00 00 00    	jb     80221c <__udivdi3+0xf0>
  80218c:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80218f:	39 55 f4             	cmp    %edx,-0xc(%ebp)
  802192:	0f 86 84 00 00 00    	jbe    80221c <__udivdi3+0xf0>
  802198:	31 f6                	xor    %esi,%esi
  80219a:	31 ff                	xor    %edi,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  80219c:	89 f8                	mov    %edi,%eax
  80219e:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  8021a0:	83 c4 10             	add    $0x10,%esp
  8021a3:	5e                   	pop    %esi
  8021a4:	5f                   	pop    %edi
  8021a5:	c9                   	leave  
  8021a6:	c3                   	ret    
  8021a7:	90                   	nop
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  8021a8:	89 f2                	mov    %esi,%edx
  8021aa:	89 f8                	mov    %edi,%eax
  8021ac:	f7 f1                	div    %ecx
  8021ae:	89 c7                	mov    %eax,%edi
  8021b0:	31 f6                	xor    %esi,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  8021b2:	89 f8                	mov    %edi,%eax
  8021b4:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  8021b6:	83 c4 10             	add    $0x10,%esp
  8021b9:	5e                   	pop    %esi
  8021ba:	5f                   	pop    %edi
  8021bb:	c9                   	leave  
  8021bc:	c3                   	ret    
  8021bd:	8d 76 00             	lea    0x0(%esi),%esi
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  8021c0:	89 f9                	mov    %edi,%ecx
  8021c2:	d3 e0                	shl    %cl,%eax
  8021c4:	89 45 e8             	mov    %eax,-0x18(%ebp)
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  8021c7:	b8 20 00 00 00       	mov    $0x20,%eax
  8021cc:	29 f8                	sub    %edi,%eax

	      d1 = (d1 << bm) | (d0 >> b);
  8021ce:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8021d1:	88 c1                	mov    %al,%cl
  8021d3:	d3 ea                	shr    %cl,%edx
  8021d5:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  8021d8:	09 ca                	or     %ecx,%edx
  8021da:	89 55 ec             	mov    %edx,-0x14(%ebp)
	      d0 = d0 << bm;
  8021dd:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8021e0:	89 f9                	mov    %edi,%ecx
  8021e2:	d3 e2                	shl    %cl,%edx
  8021e4:	89 55 f4             	mov    %edx,-0xc(%ebp)
	      n2 = n1 >> b;
  8021e7:	89 f2                	mov    %esi,%edx
  8021e9:	88 c1                	mov    %al,%cl
  8021eb:	d3 ea                	shr    %cl,%edx
  8021ed:	89 55 e8             	mov    %edx,-0x18(%ebp)
	      n1 = (n1 << bm) | (n0 >> b);
  8021f0:	89 f2                	mov    %esi,%edx
  8021f2:	89 f9                	mov    %edi,%ecx
  8021f4:	d3 e2                	shl    %cl,%edx
  8021f6:	8b 75 f0             	mov    -0x10(%ebp),%esi
  8021f9:	88 c1                	mov    %al,%cl
  8021fb:	d3 ee                	shr    %cl,%esi
  8021fd:	09 d6                	or     %edx,%esi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  8021ff:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  802202:	89 f0                	mov    %esi,%eax
  802204:	89 ca                	mov    %ecx,%edx
  802206:	f7 75 ec             	divl   -0x14(%ebp)
  802209:	89 d1                	mov    %edx,%ecx
  80220b:	89 c6                	mov    %eax,%esi
	      umul_ppmm (m1, m0, q0, d0);
  80220d:	f7 65 f4             	mull   -0xc(%ebp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  802210:	39 d1                	cmp    %edx,%ecx
  802212:	72 28                	jb     80223c <__udivdi3+0x110>
  802214:	74 1a                	je     802230 <__udivdi3+0x104>
  802216:	89 f7                	mov    %esi,%edi
  802218:	31 f6                	xor    %esi,%esi
  80221a:	eb 80                	jmp    80219c <__udivdi3+0x70>
	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  80221c:	31 f6                	xor    %esi,%esi
  80221e:	bf 01 00 00 00       	mov    $0x1,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  802223:	89 f8                	mov    %edi,%eax
  802225:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  802227:	83 c4 10             	add    $0x10,%esp
  80222a:	5e                   	pop    %esi
  80222b:	5f                   	pop    %edi
  80222c:	c9                   	leave  
  80222d:	c3                   	ret    
  80222e:	66 90                	xchg   %ax,%ax

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  802230:	8b 55 f0             	mov    -0x10(%ebp),%edx
  802233:	89 f9                	mov    %edi,%ecx
  802235:	d3 e2                	shl    %cl,%edx

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  802237:	39 c2                	cmp    %eax,%edx
  802239:	73 db                	jae    802216 <__udivdi3+0xea>
  80223b:	90                   	nop
		{
		  q0--;
  80223c:	8d 7e ff             	lea    -0x1(%esi),%edi
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  80223f:	31 f6                	xor    %esi,%esi
  802241:	e9 56 ff ff ff       	jmp    80219c <__udivdi3+0x70>
	...

00802248 <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  802248:	55                   	push   %ebp
  802249:	89 e5                	mov    %esp,%ebp
  80224b:	57                   	push   %edi
  80224c:	56                   	push   %esi
  80224d:	83 ec 20             	sub    $0x20,%esp
  802250:	8b 45 08             	mov    0x8(%ebp),%eax
  802253:	8b 4d 10             	mov    0x10(%ebp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  802256:	89 45 e8             	mov    %eax,-0x18(%ebp)
  802259:	8b 75 0c             	mov    0xc(%ebp),%esi
  const DWunion dd = {.ll = d};
  80225c:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  80225f:	8b 7d 14             	mov    0x14(%ebp),%edi
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  802262:	89 45 f0             	mov    %eax,-0x10(%ebp)
  n1 = nn.s.high;
  802265:	89 f2                	mov    %esi,%edx

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  802267:	85 ff                	test   %edi,%edi
  802269:	75 15                	jne    802280 <__umoddi3+0x38>
    {
      if (d0 > n1)
  80226b:	39 f1                	cmp    %esi,%ecx
  80226d:	0f 86 99 00 00 00    	jbe    80230c <__umoddi3+0xc4>
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  802273:	f7 f1                	div    %ecx

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
  802275:	89 d0                	mov    %edx,%eax
  802277:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  802279:	83 c4 20             	add    $0x20,%esp
  80227c:	5e                   	pop    %esi
  80227d:	5f                   	pop    %edi
  80227e:	c9                   	leave  
  80227f:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  802280:	39 f7                	cmp    %esi,%edi
  802282:	0f 87 a4 00 00 00    	ja     80232c <__umoddi3+0xe4>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  802288:	0f bd c7             	bsr    %edi,%eax
	  if (bm == 0)
  80228b:	83 f0 1f             	xor    $0x1f,%eax
  80228e:	89 45 ec             	mov    %eax,-0x14(%ebp)
  802291:	0f 84 a1 00 00 00    	je     802338 <__umoddi3+0xf0>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  802297:	89 f8                	mov    %edi,%eax
  802299:	8a 4d ec             	mov    -0x14(%ebp),%cl
  80229c:	d3 e0                	shl    %cl,%eax
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  80229e:	bf 20 00 00 00       	mov    $0x20,%edi
  8022a3:	2b 7d ec             	sub    -0x14(%ebp),%edi

	      d1 = (d1 << bm) | (d0 >> b);
  8022a6:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8022a9:	89 f9                	mov    %edi,%ecx
  8022ab:	d3 ea                	shr    %cl,%edx
  8022ad:	09 c2                	or     %eax,%edx
  8022af:	89 55 f0             	mov    %edx,-0x10(%ebp)
	      d0 = d0 << bm;
  8022b2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8022b5:	8a 4d ec             	mov    -0x14(%ebp),%cl
  8022b8:	d3 e0                	shl    %cl,%eax
  8022ba:	89 45 f4             	mov    %eax,-0xc(%ebp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  8022bd:	89 f2                	mov    %esi,%edx
  8022bf:	d3 e2                	shl    %cl,%edx
	      n0 = n0 << bm;
  8022c1:	8b 45 e8             	mov    -0x18(%ebp),%eax
  8022c4:	d3 e0                	shl    %cl,%eax
  8022c6:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  8022c9:	8b 45 e8             	mov    -0x18(%ebp),%eax
  8022cc:	89 f9                	mov    %edi,%ecx
  8022ce:	d3 e8                	shr    %cl,%eax
  8022d0:	09 d0                	or     %edx,%eax

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  8022d2:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  8022d4:	89 f2                	mov    %esi,%edx
  8022d6:	f7 75 f0             	divl   -0x10(%ebp)
  8022d9:	89 d6                	mov    %edx,%esi
	      umul_ppmm (m1, m0, q0, d0);
  8022db:	f7 65 f4             	mull   -0xc(%ebp)
  8022de:	89 55 e8             	mov    %edx,-0x18(%ebp)
  8022e1:	89 c1                	mov    %eax,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  8022e3:	39 d6                	cmp    %edx,%esi
  8022e5:	72 71                	jb     802358 <__umoddi3+0x110>
  8022e7:	74 7f                	je     802368 <__umoddi3+0x120>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  8022e9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8022ec:	29 c8                	sub    %ecx,%eax
  8022ee:	19 d6                	sbb    %edx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
  8022f0:	8a 4d ec             	mov    -0x14(%ebp),%cl
  8022f3:	d3 e8                	shr    %cl,%eax
  8022f5:	89 f2                	mov    %esi,%edx
  8022f7:	89 f9                	mov    %edi,%ecx
  8022f9:	d3 e2                	shl    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
  8022fb:	09 d0                	or     %edx,%eax
  8022fd:	89 f2                	mov    %esi,%edx
  8022ff:	8a 4d ec             	mov    -0x14(%ebp),%cl
  802302:	d3 ea                	shr    %cl,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  802304:	83 c4 20             	add    $0x20,%esp
  802307:	5e                   	pop    %esi
  802308:	5f                   	pop    %edi
  802309:	c9                   	leave  
  80230a:	c3                   	ret    
  80230b:	90                   	nop
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  80230c:	85 c9                	test   %ecx,%ecx
  80230e:	75 0b                	jne    80231b <__umoddi3+0xd3>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  802310:	b8 01 00 00 00       	mov    $0x1,%eax
  802315:	31 d2                	xor    %edx,%edx
  802317:	f7 f1                	div    %ecx
  802319:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  80231b:	89 f0                	mov    %esi,%eax
  80231d:	31 d2                	xor    %edx,%edx
  80231f:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  802321:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802324:	f7 f1                	div    %ecx
  802326:	e9 4a ff ff ff       	jmp    802275 <__umoddi3+0x2d>
  80232b:	90                   	nop
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
  80232c:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  80232e:	83 c4 20             	add    $0x20,%esp
  802331:	5e                   	pop    %esi
  802332:	5f                   	pop    %edi
  802333:	c9                   	leave  
  802334:	c3                   	ret    
  802335:	8d 76 00             	lea    0x0(%esi),%esi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  802338:	39 f7                	cmp    %esi,%edi
  80233a:	72 05                	jb     802341 <__umoddi3+0xf9>
  80233c:	3b 4d f0             	cmp    -0x10(%ebp),%ecx
  80233f:	77 0c                	ja     80234d <__umoddi3+0x105>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  802341:	89 f2                	mov    %esi,%edx
  802343:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802346:	29 c8                	sub    %ecx,%eax
  802348:	19 fa                	sbb    %edi,%edx
  80234a:	89 45 f0             	mov    %eax,-0x10(%ebp)

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
  80234d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  802350:	83 c4 20             	add    $0x20,%esp
  802353:	5e                   	pop    %esi
  802354:	5f                   	pop    %edi
  802355:	c9                   	leave  
  802356:	c3                   	ret    
  802357:	90                   	nop
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  802358:	8b 55 e8             	mov    -0x18(%ebp),%edx
  80235b:	89 c1                	mov    %eax,%ecx
  80235d:	2b 4d f4             	sub    -0xc(%ebp),%ecx
  802360:	1b 55 f0             	sbb    -0x10(%ebp),%edx
  802363:	eb 84                	jmp    8022e9 <__umoddi3+0xa1>
  802365:	8d 76 00             	lea    0x0(%esi),%esi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  802368:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  80236b:	72 eb                	jb     802358 <__umoddi3+0x110>
  80236d:	89 f2                	mov    %esi,%edx
  80236f:	e9 75 ff ff ff       	jmp    8022e9 <__umoddi3+0xa1>
