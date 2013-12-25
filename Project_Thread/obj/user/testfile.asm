
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
  800043:	e8 ae 0c 00 00       	call   800cf6 <strcpy>
	fsipcbuf.open.req_omode = mode;
  800048:	89 1d 00 54 80 00    	mov    %ebx,0x805400

	fsenv = ipc_find_env(ENV_TYPE_FS);
  80004e:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800055:	e8 94 13 00 00       	call   8013ee <ipc_find_env>
	ipc_send(fsenv, FSREQ_OPEN, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  80005a:	6a 07                	push   $0x7
  80005c:	68 00 50 80 00       	push   $0x805000
  800061:	6a 01                	push   $0x1
  800063:	50                   	push   %eax
  800064:	e8 30 13 00 00       	call   801399 <ipc_send>
	return ipc_recv(NULL, FVA, NULL);
  800069:	83 c4 1c             	add    $0x1c,%esp
  80006c:	6a 00                	push   $0x0
  80006e:	68 00 c0 cc cc       	push   $0xccccc000
  800073:	6a 00                	push   $0x0
  800075:	e8 aa 12 00 00       	call   801324 <ipc_recv>
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
  8000b0:	e8 b3 05 00 00       	call   800668 <_panic>
	else if (r >= 0)
		panic("serve_open /not-found succeeded!");
  8000b5:	83 ec 04             	sub    $0x4,%esp
  8000b8:	68 40 25 80 00       	push   $0x802540
  8000bd:	6a 22                	push   $0x22
  8000bf:	68 a5 23 80 00       	push   $0x8023a5
  8000c4:	e8 9f 05 00 00       	call   800668 <_panic>

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
  8000e9:	e8 7a 05 00 00       	call   800668 <_panic>
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
  800118:	e8 4b 05 00 00       	call   800668 <_panic>
	cprintf("serve_open is good\n");
  80011d:	83 ec 0c             	sub    $0xc,%esp
  800120:	68 d6 23 80 00       	push   $0x8023d6
  800125:	e8 16 06 00 00       	call   800740 <cprintf>

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
  800153:	e8 10 05 00 00       	call   800668 <_panic>
	if (strlen(msg) != st.st_size)
  800158:	83 ec 0c             	sub    $0xc,%esp
  80015b:	ff 35 00 30 80 00    	pushl  0x803000
  800161:	e8 3e 0b 00 00       	call   800ca4 <strlen>
  800166:	83 c4 10             	add    $0x10,%esp
  800169:	3b 45 cc             	cmp    -0x34(%ebp),%eax
  80016c:	74 25                	je     800193 <umain+0x114>
		panic("file_stat returned size %d wanted %d\n", st.st_size, strlen(msg));
  80016e:	83 ec 0c             	sub    $0xc,%esp
  800171:	ff 35 00 30 80 00    	pushl  0x803000
  800177:	e8 28 0b 00 00       	call   800ca4 <strlen>
  80017c:	89 04 24             	mov    %eax,(%esp)
  80017f:	ff 75 cc             	pushl  -0x34(%ebp)
  800182:	68 94 25 80 00       	push   $0x802594
  800187:	6a 2d                	push   $0x2d
  800189:	68 a5 23 80 00       	push   $0x8023a5
  80018e:	e8 d5 04 00 00       	call   800668 <_panic>
	cprintf("file_stat is good\n");
  800193:	83 ec 0c             	sub    $0xc,%esp
  800196:	68 f8 23 80 00       	push   $0x8023f8
  80019b:	e8 a0 05 00 00       	call   800740 <cprintf>

	memset(buf, 0, sizeof buf);
  8001a0:	83 c4 0c             	add    $0xc,%esp
  8001a3:	68 00 02 00 00       	push   $0x200
  8001a8:	6a 00                	push   $0x0
  8001aa:	8d 9d 4c fd ff ff    	lea    -0x2b4(%ebp),%ebx
  8001b0:	53                   	push   %ebx
  8001b1:	e8 b7 0c 00 00       	call   800e6d <memset>
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
  8001de:	e8 85 04 00 00       	call   800668 <_panic>
	if (strcmp(buf, msg) != 0)
  8001e3:	83 ec 08             	sub    $0x8,%esp
  8001e6:	ff 35 00 30 80 00    	pushl  0x803000
  8001ec:	8d 85 4c fd ff ff    	lea    -0x2b4(%ebp),%eax
  8001f2:	50                   	push   %eax
  8001f3:	e8 b7 0b 00 00       	call   800daf <strcmp>
  8001f8:	83 c4 10             	add    $0x10,%esp
  8001fb:	85 c0                	test   %eax,%eax
  8001fd:	74 14                	je     800213 <umain+0x194>
		panic("file_read returned wrong data");
  8001ff:	83 ec 04             	sub    $0x4,%esp
  800202:	68 19 24 80 00       	push   $0x802419
  800207:	6a 34                	push   $0x34
  800209:	68 a5 23 80 00       	push   $0x8023a5
  80020e:	e8 55 04 00 00       	call   800668 <_panic>
	cprintf("file_read is good\n");
  800213:	83 ec 0c             	sub    $0xc,%esp
  800216:	68 37 24 80 00       	push   $0x802437
  80021b:	e8 20 05 00 00       	call   800740 <cprintf>

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
  800241:	e8 22 04 00 00       	call   800668 <_panic>
	cprintf("file_close is good\n");
  800246:	83 ec 0c             	sub    $0xc,%esp
  800249:	68 59 24 80 00       	push   $0x802459
  80024e:	e8 ed 04 00 00       	call   800740 <cprintf>

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
  80026c:	e8 51 0f 00 00       	call   8011c2 <sys_page_unmap>

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
  80029f:	e8 c4 03 00 00       	call   800668 <_panic>
	cprintf("stale fileid is good\n");
  8002a4:	83 ec 0c             	sub    $0xc,%esp
  8002a7:	68 6d 24 80 00       	push   $0x80246d
  8002ac:	e8 8f 04 00 00       	call   800740 <cprintf>

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
  8002d4:	e8 8f 03 00 00       	call   800668 <_panic>

	if ((r = devfile.dev_write(FVA, msg, strlen(msg))) != strlen(msg))
  8002d9:	8b 1d 14 30 80 00    	mov    0x803014,%ebx
  8002df:	83 ec 0c             	sub    $0xc,%esp
  8002e2:	ff 35 00 30 80 00    	pushl  0x803000
  8002e8:	e8 b7 09 00 00       	call   800ca4 <strlen>
  8002ed:	83 c4 0c             	add    $0xc,%esp
  8002f0:	50                   	push   %eax
  8002f1:	ff 35 00 30 80 00    	pushl  0x803000
  8002f7:	68 00 c0 cc cc       	push   $0xccccc000
  8002fc:	ff d3                	call   *%ebx
  8002fe:	89 c3                	mov    %eax,%ebx
  800300:	83 c4 04             	add    $0x4,%esp
  800303:	ff 35 00 30 80 00    	pushl  0x803000
  800309:	e8 96 09 00 00       	call   800ca4 <strlen>
  80030e:	83 c4 10             	add    $0x10,%esp
  800311:	39 c3                	cmp    %eax,%ebx
  800313:	74 12                	je     800327 <umain+0x2a8>
		panic("file_write: %e", r);
  800315:	53                   	push   %ebx
  800316:	68 a6 24 80 00       	push   $0x8024a6
  80031b:	6a 4b                	push   $0x4b
  80031d:	68 a5 23 80 00       	push   $0x8023a5
  800322:	e8 41 03 00 00       	call   800668 <_panic>
	cprintf("file_write is good\n");
  800327:	83 ec 0c             	sub    $0xc,%esp
  80032a:	68 b5 24 80 00       	push   $0x8024b5
  80032f:	e8 0c 04 00 00       	call   800740 <cprintf>

	FVA->fd_offset = 0;
  800334:	c7 05 04 c0 cc cc 00 	movl   $0x0,0xccccc004
  80033b:	00 00 00 
	memset(buf, 0, sizeof buf);
  80033e:	83 c4 0c             	add    $0xc,%esp
  800341:	68 00 02 00 00       	push   $0x200
  800346:	6a 00                	push   $0x0
  800348:	8d 9d 4c fd ff ff    	lea    -0x2b4(%ebp),%ebx
  80034e:	53                   	push   %ebx
  80034f:	e8 19 0b 00 00       	call   800e6d <memset>
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
  80037e:	e8 e5 02 00 00       	call   800668 <_panic>
	if (r != strlen(msg))
  800383:	83 ec 0c             	sub    $0xc,%esp
  800386:	ff 35 00 30 80 00    	pushl  0x803000
  80038c:	e8 13 09 00 00       	call   800ca4 <strlen>
  800391:	83 c4 10             	add    $0x10,%esp
  800394:	39 d8                	cmp    %ebx,%eax
  800396:	74 12                	je     8003aa <umain+0x32b>
		panic("file_read after file_write returned wrong length: %d", r);
  800398:	53                   	push   %ebx
  800399:	68 14 26 80 00       	push   $0x802614
  80039e:	6a 53                	push   $0x53
  8003a0:	68 a5 23 80 00       	push   $0x8023a5
  8003a5:	e8 be 02 00 00       	call   800668 <_panic>
	if (strcmp(buf, msg) != 0)
  8003aa:	83 ec 08             	sub    $0x8,%esp
  8003ad:	ff 35 00 30 80 00    	pushl  0x803000
  8003b3:	8d 85 4c fd ff ff    	lea    -0x2b4(%ebp),%eax
  8003b9:	50                   	push   %eax
  8003ba:	e8 f0 09 00 00       	call   800daf <strcmp>
  8003bf:	83 c4 10             	add    $0x10,%esp
  8003c2:	85 c0                	test   %eax,%eax
  8003c4:	74 14                	je     8003da <umain+0x35b>
		panic("file_read after file_write returned wrong data");
  8003c6:	83 ec 04             	sub    $0x4,%esp
  8003c9:	68 4c 26 80 00       	push   $0x80264c
  8003ce:	6a 55                	push   $0x55
  8003d0:	68 a5 23 80 00       	push   $0x8023a5
  8003d5:	e8 8e 02 00 00       	call   800668 <_panic>
	cprintf("file_read after file_write is good\n");
  8003da:	83 ec 0c             	sub    $0xc,%esp
  8003dd:	68 7c 26 80 00       	push   $0x80267c
  8003e2:	e8 59 03 00 00       	call   800740 <cprintf>

	// Now we'll try out open
	if ((r = open("/not-found", O_RDONLY)) < 0 && r != -E_NOT_FOUND)
  8003e7:	83 c4 08             	add    $0x8,%esp
  8003ea:	6a 00                	push   $0x0
  8003ec:	68 80 23 80 00       	push   $0x802380
  8003f1:	e8 66 17 00 00       	call   801b5c <open>
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
  80040f:	e8 54 02 00 00       	call   800668 <_panic>
	else if (r >= 0)
		panic("open /not-found succeeded!");
  800414:	83 ec 04             	sub    $0x4,%esp
  800417:	68 c9 24 80 00       	push   $0x8024c9
  80041c:	6a 5c                	push   $0x5c
  80041e:	68 a5 23 80 00       	push   $0x8023a5
  800423:	e8 40 02 00 00       	call   800668 <_panic>

	if ((r = open("/newmotd", O_RDONLY)) < 0)
  800428:	83 ec 08             	sub    $0x8,%esp
  80042b:	6a 00                	push   $0x0
  80042d:	68 b5 23 80 00       	push   $0x8023b5
  800432:	e8 25 17 00 00       	call   801b5c <open>
  800437:	83 c4 10             	add    $0x10,%esp
  80043a:	85 c0                	test   %eax,%eax
  80043c:	79 12                	jns    800450 <umain+0x3d1>
		panic("open /newmotd: %e", r);
  80043e:	50                   	push   %eax
  80043f:	68 c4 23 80 00       	push   $0x8023c4
  800444:	6a 5f                	push   $0x5f
  800446:	68 a5 23 80 00       	push   $0x8023a5
  80044b:	e8 18 02 00 00       	call   800668 <_panic>
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
  800478:	e8 eb 01 00 00       	call   800668 <_panic>
	cprintf("open is good\n");
  80047d:	83 ec 0c             	sub    $0xc,%esp
  800480:	68 dc 23 80 00       	push   $0x8023dc
  800485:	e8 b6 02 00 00       	call   800740 <cprintf>

	// Try files with indirect blocks
	if ((f = open("/big", O_WRONLY|O_CREAT)) < 0)
  80048a:	83 c4 08             	add    $0x8,%esp
  80048d:	68 01 01 00 00       	push   $0x101
  800492:	68 e4 24 80 00       	push   $0x8024e4
  800497:	e8 c0 16 00 00       	call   801b5c <open>
  80049c:	89 85 44 fd ff ff    	mov    %eax,-0x2bc(%ebp)
  8004a2:	83 c4 10             	add    $0x10,%esp
  8004a5:	85 c0                	test   %eax,%eax
  8004a7:	79 12                	jns    8004bb <umain+0x43c>
		panic("creat /big: %e", f);
  8004a9:	50                   	push   %eax
  8004aa:	68 e9 24 80 00       	push   $0x8024e9
  8004af:	6a 67                	push   $0x67
  8004b1:	68 a5 23 80 00       	push   $0x8023a5
  8004b6:	e8 ad 01 00 00       	call   800668 <_panic>
	memset(buf, 0, sizeof(buf));
  8004bb:	83 ec 04             	sub    $0x4,%esp
  8004be:	68 00 02 00 00       	push   $0x200
  8004c3:	6a 00                	push   $0x0
  8004c5:	8d 85 4c fd ff ff    	lea    -0x2b4(%ebp),%eax
  8004cb:	50                   	push   %eax
  8004cc:	e8 9c 09 00 00       	call   800e6d <memset>
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
  8004f2:	e8 3d 13 00 00       	call   801834 <write>
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
  80050f:	e8 54 01 00 00       	call   800668 <_panic>
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
  80052c:	e8 ea 10 00 00       	call   80161b <close>

	if ((f = open("/big", O_RDONLY)) < 0)
  800531:	83 c4 08             	add    $0x8,%esp
  800534:	6a 00                	push   $0x0
  800536:	68 e4 24 80 00       	push   $0x8024e4
  80053b:	e8 1c 16 00 00       	call   801b5c <open>
  800540:	89 c6                	mov    %eax,%esi
  800542:	83 c4 10             	add    $0x10,%esp
  800545:	85 c0                	test   %eax,%eax
  800547:	79 12                	jns    80055b <umain+0x4dc>
		panic("open /big: %e", f);
  800549:	50                   	push   %eax
  80054a:	68 0a 25 80 00       	push   $0x80250a
  80054f:	6a 71                	push   $0x71
  800551:	68 a5 23 80 00       	push   $0x8023a5
  800556:	e8 0d 01 00 00       	call   800668 <_panic>
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
  800572:	e8 68 12 00 00       	call   8017df <readn>
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
  80058f:	e8 d4 00 00 00       	call   800668 <_panic>
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
  8005b1:	e8 b2 00 00 00       	call   800668 <_panic>
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
  8005cd:	e8 96 00 00 00       	call   800668 <_panic>
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
  8005e4:	e8 32 10 00 00       	call   80161b <close>
	cprintf("large file is good\n");
  8005e9:	c7 04 24 29 25 80 00 	movl   $0x802529,(%esp)
  8005f0:	e8 4b 01 00 00       	call   800740 <cprintf>
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
  80060b:	e8 1d 0b 00 00       	call   80112d <sys_getenvid>
  800610:	25 ff 03 00 00       	and    $0x3ff,%eax
  800615:	89 c2                	mov    %eax,%edx
  800617:	c1 e2 07             	shl    $0x7,%edx
  80061a:	8d 84 82 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,4),%eax
  800621:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800626:	85 f6                	test   %esi,%esi
  800628:	7e 07                	jle    800631 <libmain+0x31>
		binaryname = argv[0];
  80062a:	8b 03                	mov    (%ebx),%eax
  80062c:	a3 04 30 80 00       	mov    %eax,0x803004
	// call user main routine
	umain(argc, argv);
  800631:	83 ec 08             	sub    $0x8,%esp
  800634:	53                   	push   %ebx
  800635:	56                   	push   %esi
  800636:	e8 44 fa ff ff       	call   80007f <umain>

	// exit gracefully
	exit();
  80063b:	e8 0c 00 00 00       	call   80064c <exit>
  800640:	83 c4 10             	add    $0x10,%esp
}
  800643:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800646:	5b                   	pop    %ebx
  800647:	5e                   	pop    %esi
  800648:	c9                   	leave  
  800649:	c3                   	ret    
	...

0080064c <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80064c:	55                   	push   %ebp
  80064d:	89 e5                	mov    %esp,%ebp
  80064f:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800652:	e8 ef 0f 00 00       	call   801646 <close_all>
	sys_env_destroy(0);
  800657:	83 ec 0c             	sub    $0xc,%esp
  80065a:	6a 00                	push   $0x0
  80065c:	e8 aa 0a 00 00       	call   80110b <sys_env_destroy>
  800661:	83 c4 10             	add    $0x10,%esp
}
  800664:	c9                   	leave  
  800665:	c3                   	ret    
	...

00800668 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800668:	55                   	push   %ebp
  800669:	89 e5                	mov    %esp,%ebp
  80066b:	56                   	push   %esi
  80066c:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  80066d:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800670:	8b 1d 04 30 80 00    	mov    0x803004,%ebx
  800676:	e8 b2 0a 00 00       	call   80112d <sys_getenvid>
  80067b:	83 ec 0c             	sub    $0xc,%esp
  80067e:	ff 75 0c             	pushl  0xc(%ebp)
  800681:	ff 75 08             	pushl  0x8(%ebp)
  800684:	53                   	push   %ebx
  800685:	50                   	push   %eax
  800686:	68 4c 27 80 00       	push   $0x80274c
  80068b:	e8 b0 00 00 00       	call   800740 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800690:	83 c4 18             	add    $0x18,%esp
  800693:	56                   	push   %esi
  800694:	ff 75 10             	pushl  0x10(%ebp)
  800697:	e8 53 00 00 00       	call   8006ef <vcprintf>
	cprintf("\n");
  80069c:	c7 04 24 a3 2b 80 00 	movl   $0x802ba3,(%esp)
  8006a3:	e8 98 00 00 00       	call   800740 <cprintf>
  8006a8:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8006ab:	cc                   	int3   
  8006ac:	eb fd                	jmp    8006ab <_panic+0x43>
	...

008006b0 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8006b0:	55                   	push   %ebp
  8006b1:	89 e5                	mov    %esp,%ebp
  8006b3:	53                   	push   %ebx
  8006b4:	83 ec 04             	sub    $0x4,%esp
  8006b7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8006ba:	8b 03                	mov    (%ebx),%eax
  8006bc:	8b 55 08             	mov    0x8(%ebp),%edx
  8006bf:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  8006c3:	40                   	inc    %eax
  8006c4:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  8006c6:	3d ff 00 00 00       	cmp    $0xff,%eax
  8006cb:	75 1a                	jne    8006e7 <putch+0x37>
		sys_cputs(b->buf, b->idx);
  8006cd:	83 ec 08             	sub    $0x8,%esp
  8006d0:	68 ff 00 00 00       	push   $0xff
  8006d5:	8d 43 08             	lea    0x8(%ebx),%eax
  8006d8:	50                   	push   %eax
  8006d9:	e8 e3 09 00 00       	call   8010c1 <sys_cputs>
		b->idx = 0;
  8006de:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8006e4:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8006e7:	ff 43 04             	incl   0x4(%ebx)
}
  8006ea:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8006ed:	c9                   	leave  
  8006ee:	c3                   	ret    

008006ef <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8006ef:	55                   	push   %ebp
  8006f0:	89 e5                	mov    %esp,%ebp
  8006f2:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8006f8:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8006ff:	00 00 00 
	b.cnt = 0;
  800702:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800709:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80070c:	ff 75 0c             	pushl  0xc(%ebp)
  80070f:	ff 75 08             	pushl  0x8(%ebp)
  800712:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800718:	50                   	push   %eax
  800719:	68 b0 06 80 00       	push   $0x8006b0
  80071e:	e8 82 01 00 00       	call   8008a5 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800723:	83 c4 08             	add    $0x8,%esp
  800726:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  80072c:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800732:	50                   	push   %eax
  800733:	e8 89 09 00 00       	call   8010c1 <sys_cputs>

	return b.cnt;
}
  800738:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80073e:	c9                   	leave  
  80073f:	c3                   	ret    

00800740 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800740:	55                   	push   %ebp
  800741:	89 e5                	mov    %esp,%ebp
  800743:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800746:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800749:	50                   	push   %eax
  80074a:	ff 75 08             	pushl  0x8(%ebp)
  80074d:	e8 9d ff ff ff       	call   8006ef <vcprintf>
	va_end(ap);

	return cnt;
}
  800752:	c9                   	leave  
  800753:	c3                   	ret    

00800754 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800754:	55                   	push   %ebp
  800755:	89 e5                	mov    %esp,%ebp
  800757:	57                   	push   %edi
  800758:	56                   	push   %esi
  800759:	53                   	push   %ebx
  80075a:	83 ec 2c             	sub    $0x2c,%esp
  80075d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800760:	89 d6                	mov    %edx,%esi
  800762:	8b 45 08             	mov    0x8(%ebp),%eax
  800765:	8b 55 0c             	mov    0xc(%ebp),%edx
  800768:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80076b:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80076e:	8b 45 10             	mov    0x10(%ebp),%eax
  800771:	8b 5d 14             	mov    0x14(%ebp),%ebx
  800774:	8b 7d 18             	mov    0x18(%ebp),%edi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800777:	89 45 d0             	mov    %eax,-0x30(%ebp)
  80077a:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  800781:	39 55 d4             	cmp    %edx,-0x2c(%ebp)
  800784:	72 0c                	jb     800792 <printnum+0x3e>
  800786:	3b 45 d8             	cmp    -0x28(%ebp),%eax
  800789:	76 07                	jbe    800792 <printnum+0x3e>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80078b:	4b                   	dec    %ebx
  80078c:	85 db                	test   %ebx,%ebx
  80078e:	7f 31                	jg     8007c1 <printnum+0x6d>
  800790:	eb 3f                	jmp    8007d1 <printnum+0x7d>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800792:	83 ec 0c             	sub    $0xc,%esp
  800795:	57                   	push   %edi
  800796:	4b                   	dec    %ebx
  800797:	53                   	push   %ebx
  800798:	50                   	push   %eax
  800799:	83 ec 08             	sub    $0x8,%esp
  80079c:	ff 75 d4             	pushl  -0x2c(%ebp)
  80079f:	ff 75 d0             	pushl  -0x30(%ebp)
  8007a2:	ff 75 dc             	pushl  -0x24(%ebp)
  8007a5:	ff 75 d8             	pushl  -0x28(%ebp)
  8007a8:	e8 87 19 00 00       	call   802134 <__udivdi3>
  8007ad:	83 c4 18             	add    $0x18,%esp
  8007b0:	52                   	push   %edx
  8007b1:	50                   	push   %eax
  8007b2:	89 f2                	mov    %esi,%edx
  8007b4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8007b7:	e8 98 ff ff ff       	call   800754 <printnum>
  8007bc:	83 c4 20             	add    $0x20,%esp
  8007bf:	eb 10                	jmp    8007d1 <printnum+0x7d>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8007c1:	83 ec 08             	sub    $0x8,%esp
  8007c4:	56                   	push   %esi
  8007c5:	57                   	push   %edi
  8007c6:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8007c9:	4b                   	dec    %ebx
  8007ca:	83 c4 10             	add    $0x10,%esp
  8007cd:	85 db                	test   %ebx,%ebx
  8007cf:	7f f0                	jg     8007c1 <printnum+0x6d>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8007d1:	83 ec 08             	sub    $0x8,%esp
  8007d4:	56                   	push   %esi
  8007d5:	83 ec 04             	sub    $0x4,%esp
  8007d8:	ff 75 d4             	pushl  -0x2c(%ebp)
  8007db:	ff 75 d0             	pushl  -0x30(%ebp)
  8007de:	ff 75 dc             	pushl  -0x24(%ebp)
  8007e1:	ff 75 d8             	pushl  -0x28(%ebp)
  8007e4:	e8 67 1a 00 00       	call   802250 <__umoddi3>
  8007e9:	83 c4 14             	add    $0x14,%esp
  8007ec:	0f be 80 6f 27 80 00 	movsbl 0x80276f(%eax),%eax
  8007f3:	50                   	push   %eax
  8007f4:	ff 55 e4             	call   *-0x1c(%ebp)
  8007f7:	83 c4 10             	add    $0x10,%esp
}
  8007fa:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8007fd:	5b                   	pop    %ebx
  8007fe:	5e                   	pop    %esi
  8007ff:	5f                   	pop    %edi
  800800:	c9                   	leave  
  800801:	c3                   	ret    

00800802 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800802:	55                   	push   %ebp
  800803:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800805:	83 fa 01             	cmp    $0x1,%edx
  800808:	7e 0e                	jle    800818 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80080a:	8b 10                	mov    (%eax),%edx
  80080c:	8d 4a 08             	lea    0x8(%edx),%ecx
  80080f:	89 08                	mov    %ecx,(%eax)
  800811:	8b 02                	mov    (%edx),%eax
  800813:	8b 52 04             	mov    0x4(%edx),%edx
  800816:	eb 22                	jmp    80083a <getuint+0x38>
	else if (lflag)
  800818:	85 d2                	test   %edx,%edx
  80081a:	74 10                	je     80082c <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  80081c:	8b 10                	mov    (%eax),%edx
  80081e:	8d 4a 04             	lea    0x4(%edx),%ecx
  800821:	89 08                	mov    %ecx,(%eax)
  800823:	8b 02                	mov    (%edx),%eax
  800825:	ba 00 00 00 00       	mov    $0x0,%edx
  80082a:	eb 0e                	jmp    80083a <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  80082c:	8b 10                	mov    (%eax),%edx
  80082e:	8d 4a 04             	lea    0x4(%edx),%ecx
  800831:	89 08                	mov    %ecx,(%eax)
  800833:	8b 02                	mov    (%edx),%eax
  800835:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80083a:	c9                   	leave  
  80083b:	c3                   	ret    

0080083c <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
  80083c:	55                   	push   %ebp
  80083d:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80083f:	83 fa 01             	cmp    $0x1,%edx
  800842:	7e 0e                	jle    800852 <getint+0x16>
		return va_arg(*ap, long long);
  800844:	8b 10                	mov    (%eax),%edx
  800846:	8d 4a 08             	lea    0x8(%edx),%ecx
  800849:	89 08                	mov    %ecx,(%eax)
  80084b:	8b 02                	mov    (%edx),%eax
  80084d:	8b 52 04             	mov    0x4(%edx),%edx
  800850:	eb 1a                	jmp    80086c <getint+0x30>
	else if (lflag)
  800852:	85 d2                	test   %edx,%edx
  800854:	74 0c                	je     800862 <getint+0x26>
		return va_arg(*ap, long);
  800856:	8b 10                	mov    (%eax),%edx
  800858:	8d 4a 04             	lea    0x4(%edx),%ecx
  80085b:	89 08                	mov    %ecx,(%eax)
  80085d:	8b 02                	mov    (%edx),%eax
  80085f:	99                   	cltd   
  800860:	eb 0a                	jmp    80086c <getint+0x30>
	else
		return va_arg(*ap, int);
  800862:	8b 10                	mov    (%eax),%edx
  800864:	8d 4a 04             	lea    0x4(%edx),%ecx
  800867:	89 08                	mov    %ecx,(%eax)
  800869:	8b 02                	mov    (%edx),%eax
  80086b:	99                   	cltd   
}
  80086c:	c9                   	leave  
  80086d:	c3                   	ret    

0080086e <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80086e:	55                   	push   %ebp
  80086f:	89 e5                	mov    %esp,%ebp
  800871:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800874:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  800877:	8b 10                	mov    (%eax),%edx
  800879:	3b 50 04             	cmp    0x4(%eax),%edx
  80087c:	73 08                	jae    800886 <sprintputch+0x18>
		*b->buf++ = ch;
  80087e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800881:	88 0a                	mov    %cl,(%edx)
  800883:	42                   	inc    %edx
  800884:	89 10                	mov    %edx,(%eax)
}
  800886:	c9                   	leave  
  800887:	c3                   	ret    

00800888 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800888:	55                   	push   %ebp
  800889:	89 e5                	mov    %esp,%ebp
  80088b:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  80088e:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800891:	50                   	push   %eax
  800892:	ff 75 10             	pushl  0x10(%ebp)
  800895:	ff 75 0c             	pushl  0xc(%ebp)
  800898:	ff 75 08             	pushl  0x8(%ebp)
  80089b:	e8 05 00 00 00       	call   8008a5 <vprintfmt>
	va_end(ap);
  8008a0:	83 c4 10             	add    $0x10,%esp
}
  8008a3:	c9                   	leave  
  8008a4:	c3                   	ret    

008008a5 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8008a5:	55                   	push   %ebp
  8008a6:	89 e5                	mov    %esp,%ebp
  8008a8:	57                   	push   %edi
  8008a9:	56                   	push   %esi
  8008aa:	53                   	push   %ebx
  8008ab:	83 ec 2c             	sub    $0x2c,%esp
  8008ae:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8008b1:	8b 75 10             	mov    0x10(%ebp),%esi
  8008b4:	eb 13                	jmp    8008c9 <vprintfmt+0x24>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8008b6:	85 c0                	test   %eax,%eax
  8008b8:	0f 84 6d 03 00 00    	je     800c2b <vprintfmt+0x386>
				return;
			putch(ch, putdat);
  8008be:	83 ec 08             	sub    $0x8,%esp
  8008c1:	57                   	push   %edi
  8008c2:	50                   	push   %eax
  8008c3:	ff 55 08             	call   *0x8(%ebp)
  8008c6:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8008c9:	0f b6 06             	movzbl (%esi),%eax
  8008cc:	46                   	inc    %esi
  8008cd:	83 f8 25             	cmp    $0x25,%eax
  8008d0:	75 e4                	jne    8008b6 <vprintfmt+0x11>
  8008d2:	c6 45 dc 20          	movb   $0x20,-0x24(%ebp)
  8008d6:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  8008dd:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
  8008e4:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  8008eb:	b9 00 00 00 00       	mov    $0x0,%ecx
  8008f0:	eb 28                	jmp    80091a <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8008f2:	89 de                	mov    %ebx,%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  8008f4:	c6 45 dc 2d          	movb   $0x2d,-0x24(%ebp)
  8008f8:	eb 20                	jmp    80091a <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8008fa:	89 de                	mov    %ebx,%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8008fc:	c6 45 dc 30          	movb   $0x30,-0x24(%ebp)
  800900:	eb 18                	jmp    80091a <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800902:	89 de                	mov    %ebx,%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  800904:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  80090b:	eb 0d                	jmp    80091a <vprintfmt+0x75>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  80090d:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  800910:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800913:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80091a:	8a 06                	mov    (%esi),%al
  80091c:	0f b6 d0             	movzbl %al,%edx
  80091f:	8d 5e 01             	lea    0x1(%esi),%ebx
  800922:	83 e8 23             	sub    $0x23,%eax
  800925:	3c 55                	cmp    $0x55,%al
  800927:	0f 87 e0 02 00 00    	ja     800c0d <vprintfmt+0x368>
  80092d:	0f b6 c0             	movzbl %al,%eax
  800930:	ff 24 85 c0 28 80 00 	jmp    *0x8028c0(,%eax,4)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800937:	83 ea 30             	sub    $0x30,%edx
  80093a:	89 55 d4             	mov    %edx,-0x2c(%ebp)
				ch = *fmt;
  80093d:	0f be 03             	movsbl (%ebx),%eax
				if (ch < '0' || ch > '9')
  800940:	8d 50 d0             	lea    -0x30(%eax),%edx
  800943:	83 fa 09             	cmp    $0x9,%edx
  800946:	77 44                	ja     80098c <vprintfmt+0xe7>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800948:	89 de                	mov    %ebx,%esi
  80094a:	8b 55 d4             	mov    -0x2c(%ebp),%edx
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80094d:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
  80094e:	8d 14 92             	lea    (%edx,%edx,4),%edx
  800951:	8d 54 50 d0          	lea    -0x30(%eax,%edx,2),%edx
				ch = *fmt;
  800955:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  800958:	8d 58 d0             	lea    -0x30(%eax),%ebx
  80095b:	83 fb 09             	cmp    $0x9,%ebx
  80095e:	76 ed                	jbe    80094d <vprintfmt+0xa8>
  800960:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  800963:	eb 29                	jmp    80098e <vprintfmt+0xe9>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800965:	8b 45 14             	mov    0x14(%ebp),%eax
  800968:	8d 50 04             	lea    0x4(%eax),%edx
  80096b:	89 55 14             	mov    %edx,0x14(%ebp)
  80096e:	8b 00                	mov    (%eax),%eax
  800970:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800973:	89 de                	mov    %ebx,%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800975:	eb 17                	jmp    80098e <vprintfmt+0xe9>

		case '.':
			if (width < 0)
  800977:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80097b:	78 85                	js     800902 <vprintfmt+0x5d>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80097d:	89 de                	mov    %ebx,%esi
  80097f:	eb 99                	jmp    80091a <vprintfmt+0x75>
  800981:	89 de                	mov    %ebx,%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800983:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
			goto reswitch;
  80098a:	eb 8e                	jmp    80091a <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80098c:	89 de                	mov    %ebx,%esi
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  80098e:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800992:	79 86                	jns    80091a <vprintfmt+0x75>
  800994:	e9 74 ff ff ff       	jmp    80090d <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800999:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80099a:	89 de                	mov    %ebx,%esi
  80099c:	e9 79 ff ff ff       	jmp    80091a <vprintfmt+0x75>
  8009a1:	89 5d d8             	mov    %ebx,-0x28(%ebp)
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8009a4:	8b 45 14             	mov    0x14(%ebp),%eax
  8009a7:	8d 50 04             	lea    0x4(%eax),%edx
  8009aa:	89 55 14             	mov    %edx,0x14(%ebp)
  8009ad:	83 ec 08             	sub    $0x8,%esp
  8009b0:	57                   	push   %edi
  8009b1:	ff 30                	pushl  (%eax)
  8009b3:	ff 55 08             	call   *0x8(%ebp)
			break;
  8009b6:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8009b9:	8b 75 d8             	mov    -0x28(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8009bc:	e9 08 ff ff ff       	jmp    8008c9 <vprintfmt+0x24>
  8009c1:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// error message
		case 'e':
			err = va_arg(ap, int);
  8009c4:	8b 45 14             	mov    0x14(%ebp),%eax
  8009c7:	8d 50 04             	lea    0x4(%eax),%edx
  8009ca:	89 55 14             	mov    %edx,0x14(%ebp)
  8009cd:	8b 00                	mov    (%eax),%eax
  8009cf:	85 c0                	test   %eax,%eax
  8009d1:	79 02                	jns    8009d5 <vprintfmt+0x130>
  8009d3:	f7 d8                	neg    %eax
  8009d5:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8009d7:	83 f8 0f             	cmp    $0xf,%eax
  8009da:	7f 0b                	jg     8009e7 <vprintfmt+0x142>
  8009dc:	8b 04 85 20 2a 80 00 	mov    0x802a20(,%eax,4),%eax
  8009e3:	85 c0                	test   %eax,%eax
  8009e5:	75 1a                	jne    800a01 <vprintfmt+0x15c>
				printfmt(putch, putdat, "error %d", err);
  8009e7:	52                   	push   %edx
  8009e8:	68 87 27 80 00       	push   $0x802787
  8009ed:	57                   	push   %edi
  8009ee:	ff 75 08             	pushl  0x8(%ebp)
  8009f1:	e8 92 fe ff ff       	call   800888 <printfmt>
  8009f6:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8009f9:	8b 75 d8             	mov    -0x28(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8009fc:	e9 c8 fe ff ff       	jmp    8008c9 <vprintfmt+0x24>
			else
				printfmt(putch, putdat, "%s", p);
  800a01:	50                   	push   %eax
  800a02:	68 71 2b 80 00       	push   $0x802b71
  800a07:	57                   	push   %edi
  800a08:	ff 75 08             	pushl  0x8(%ebp)
  800a0b:	e8 78 fe ff ff       	call   800888 <printfmt>
  800a10:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800a13:	8b 75 d8             	mov    -0x28(%ebp),%esi
  800a16:	e9 ae fe ff ff       	jmp    8008c9 <vprintfmt+0x24>
  800a1b:	89 5d d8             	mov    %ebx,-0x28(%ebp)
  800a1e:	89 de                	mov    %ebx,%esi
  800a20:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  800a23:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800a26:	8b 45 14             	mov    0x14(%ebp),%eax
  800a29:	8d 50 04             	lea    0x4(%eax),%edx
  800a2c:	89 55 14             	mov    %edx,0x14(%ebp)
  800a2f:	8b 00                	mov    (%eax),%eax
  800a31:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800a34:	85 c0                	test   %eax,%eax
  800a36:	75 07                	jne    800a3f <vprintfmt+0x19a>
				p = "(null)";
  800a38:	c7 45 d0 80 27 80 00 	movl   $0x802780,-0x30(%ebp)
			if (width > 0 && padc != '-')
  800a3f:	85 db                	test   %ebx,%ebx
  800a41:	7e 42                	jle    800a85 <vprintfmt+0x1e0>
  800a43:	80 7d dc 2d          	cmpb   $0x2d,-0x24(%ebp)
  800a47:	74 3c                	je     800a85 <vprintfmt+0x1e0>
				for (width -= strnlen(p, precision); width > 0; width--)
  800a49:	83 ec 08             	sub    $0x8,%esp
  800a4c:	51                   	push   %ecx
  800a4d:	ff 75 d0             	pushl  -0x30(%ebp)
  800a50:	e8 6f 02 00 00       	call   800cc4 <strnlen>
  800a55:	29 c3                	sub    %eax,%ebx
  800a57:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800a5a:	83 c4 10             	add    $0x10,%esp
  800a5d:	85 db                	test   %ebx,%ebx
  800a5f:	7e 24                	jle    800a85 <vprintfmt+0x1e0>
					putch(padc, putdat);
  800a61:	0f be 5d dc          	movsbl -0x24(%ebp),%ebx
  800a65:	89 75 dc             	mov    %esi,-0x24(%ebp)
  800a68:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  800a6b:	83 ec 08             	sub    $0x8,%esp
  800a6e:	57                   	push   %edi
  800a6f:	53                   	push   %ebx
  800a70:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800a73:	4e                   	dec    %esi
  800a74:	83 c4 10             	add    $0x10,%esp
  800a77:	85 f6                	test   %esi,%esi
  800a79:	7f f0                	jg     800a6b <vprintfmt+0x1c6>
  800a7b:	8b 75 dc             	mov    -0x24(%ebp),%esi
  800a7e:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800a85:	8b 55 d0             	mov    -0x30(%ebp),%edx
  800a88:	0f be 02             	movsbl (%edx),%eax
  800a8b:	85 c0                	test   %eax,%eax
  800a8d:	75 47                	jne    800ad6 <vprintfmt+0x231>
  800a8f:	eb 37                	jmp    800ac8 <vprintfmt+0x223>
				if (altflag && (ch < ' ' || ch > '~'))
  800a91:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800a95:	74 16                	je     800aad <vprintfmt+0x208>
  800a97:	8d 50 e0             	lea    -0x20(%eax),%edx
  800a9a:	83 fa 5e             	cmp    $0x5e,%edx
  800a9d:	76 0e                	jbe    800aad <vprintfmt+0x208>
					putch('?', putdat);
  800a9f:	83 ec 08             	sub    $0x8,%esp
  800aa2:	57                   	push   %edi
  800aa3:	6a 3f                	push   $0x3f
  800aa5:	ff 55 08             	call   *0x8(%ebp)
  800aa8:	83 c4 10             	add    $0x10,%esp
  800aab:	eb 0b                	jmp    800ab8 <vprintfmt+0x213>
				else
					putch(ch, putdat);
  800aad:	83 ec 08             	sub    $0x8,%esp
  800ab0:	57                   	push   %edi
  800ab1:	50                   	push   %eax
  800ab2:	ff 55 08             	call   *0x8(%ebp)
  800ab5:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800ab8:	ff 4d e4             	decl   -0x1c(%ebp)
  800abb:	0f be 03             	movsbl (%ebx),%eax
  800abe:	85 c0                	test   %eax,%eax
  800ac0:	74 03                	je     800ac5 <vprintfmt+0x220>
  800ac2:	43                   	inc    %ebx
  800ac3:	eb 1b                	jmp    800ae0 <vprintfmt+0x23b>
  800ac5:	8b 75 dc             	mov    -0x24(%ebp),%esi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800ac8:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800acc:	7f 1e                	jg     800aec <vprintfmt+0x247>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800ace:	8b 75 d8             	mov    -0x28(%ebp),%esi
  800ad1:	e9 f3 fd ff ff       	jmp    8008c9 <vprintfmt+0x24>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800ad6:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  800ad9:	43                   	inc    %ebx
  800ada:	89 75 dc             	mov    %esi,-0x24(%ebp)
  800add:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  800ae0:	85 f6                	test   %esi,%esi
  800ae2:	78 ad                	js     800a91 <vprintfmt+0x1ec>
  800ae4:	4e                   	dec    %esi
  800ae5:	79 aa                	jns    800a91 <vprintfmt+0x1ec>
  800ae7:	8b 75 dc             	mov    -0x24(%ebp),%esi
  800aea:	eb dc                	jmp    800ac8 <vprintfmt+0x223>
  800aec:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800aef:	83 ec 08             	sub    $0x8,%esp
  800af2:	57                   	push   %edi
  800af3:	6a 20                	push   $0x20
  800af5:	ff 55 08             	call   *0x8(%ebp)
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800af8:	4b                   	dec    %ebx
  800af9:	83 c4 10             	add    $0x10,%esp
  800afc:	85 db                	test   %ebx,%ebx
  800afe:	7f ef                	jg     800aef <vprintfmt+0x24a>
  800b00:	e9 c4 fd ff ff       	jmp    8008c9 <vprintfmt+0x24>
  800b05:	89 5d d8             	mov    %ebx,-0x28(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800b08:	89 ca                	mov    %ecx,%edx
  800b0a:	8d 45 14             	lea    0x14(%ebp),%eax
  800b0d:	e8 2a fd ff ff       	call   80083c <getint>
  800b12:	89 c3                	mov    %eax,%ebx
  800b14:	89 d6                	mov    %edx,%esi
			if ((long long) num < 0) {
  800b16:	85 d2                	test   %edx,%edx
  800b18:	78 0a                	js     800b24 <vprintfmt+0x27f>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800b1a:	b8 0a 00 00 00       	mov    $0xa,%eax
  800b1f:	e9 b0 00 00 00       	jmp    800bd4 <vprintfmt+0x32f>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  800b24:	83 ec 08             	sub    $0x8,%esp
  800b27:	57                   	push   %edi
  800b28:	6a 2d                	push   $0x2d
  800b2a:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  800b2d:	f7 db                	neg    %ebx
  800b2f:	83 d6 00             	adc    $0x0,%esi
  800b32:	f7 de                	neg    %esi
  800b34:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800b37:	b8 0a 00 00 00       	mov    $0xa,%eax
  800b3c:	e9 93 00 00 00       	jmp    800bd4 <vprintfmt+0x32f>
  800b41:	89 5d d8             	mov    %ebx,-0x28(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800b44:	89 ca                	mov    %ecx,%edx
  800b46:	8d 45 14             	lea    0x14(%ebp),%eax
  800b49:	e8 b4 fc ff ff       	call   800802 <getuint>
  800b4e:	89 c3                	mov    %eax,%ebx
  800b50:	89 d6                	mov    %edx,%esi
			base = 10;
  800b52:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  800b57:	eb 7b                	jmp    800bd4 <vprintfmt+0x32f>
  800b59:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// (unsigned) octal
		case 'o':
            // (MIT 6.828, lab1, Ex.8)  my code : 
            num = getint(&ap, lflag);
  800b5c:	89 ca                	mov    %ecx,%edx
  800b5e:	8d 45 14             	lea    0x14(%ebp),%eax
  800b61:	e8 d6 fc ff ff       	call   80083c <getint>
  800b66:	89 c3                	mov    %eax,%ebx
  800b68:	89 d6                	mov    %edx,%esi
            if ((long long) num < 0) {
  800b6a:	85 d2                	test   %edx,%edx
  800b6c:	78 07                	js     800b75 <vprintfmt+0x2d0>
                putch('-', putdat);
                num = -(long long) num;
            }
            base = 8;
  800b6e:	b8 08 00 00 00       	mov    $0x8,%eax
  800b73:	eb 5f                	jmp    800bd4 <vprintfmt+0x32f>
		// (unsigned) octal
		case 'o':
            // (MIT 6.828, lab1, Ex.8)  my code : 
            num = getint(&ap, lflag);
            if ((long long) num < 0) {
                putch('-', putdat);
  800b75:	83 ec 08             	sub    $0x8,%esp
  800b78:	57                   	push   %edi
  800b79:	6a 2d                	push   $0x2d
  800b7b:	ff 55 08             	call   *0x8(%ebp)
                num = -(long long) num;
  800b7e:	f7 db                	neg    %ebx
  800b80:	83 d6 00             	adc    $0x0,%esi
  800b83:	f7 de                	neg    %esi
  800b85:	83 c4 10             	add    $0x10,%esp
            }
            base = 8;
  800b88:	b8 08 00 00 00       	mov    $0x8,%eax
  800b8d:	eb 45                	jmp    800bd4 <vprintfmt+0x32f>
  800b8f:	89 5d d8             	mov    %ebx,-0x28(%ebp)
            goto number;

        // pointer
		case 'p':
			putch('0', putdat);
  800b92:	83 ec 08             	sub    $0x8,%esp
  800b95:	57                   	push   %edi
  800b96:	6a 30                	push   $0x30
  800b98:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  800b9b:	83 c4 08             	add    $0x8,%esp
  800b9e:	57                   	push   %edi
  800b9f:	6a 78                	push   $0x78
  800ba1:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800ba4:	8b 45 14             	mov    0x14(%ebp),%eax
  800ba7:	8d 50 04             	lea    0x4(%eax),%edx
  800baa:	89 55 14             	mov    %edx,0x14(%ebp)

        // pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800bad:	8b 18                	mov    (%eax),%ebx
  800baf:	be 00 00 00 00       	mov    $0x0,%esi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800bb4:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800bb7:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  800bbc:	eb 16                	jmp    800bd4 <vprintfmt+0x32f>
  800bbe:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800bc1:	89 ca                	mov    %ecx,%edx
  800bc3:	8d 45 14             	lea    0x14(%ebp),%eax
  800bc6:	e8 37 fc ff ff       	call   800802 <getuint>
  800bcb:	89 c3                	mov    %eax,%ebx
  800bcd:	89 d6                	mov    %edx,%esi
			base = 16;
  800bcf:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  800bd4:	83 ec 0c             	sub    $0xc,%esp
  800bd7:	0f be 55 dc          	movsbl -0x24(%ebp),%edx
  800bdb:	52                   	push   %edx
  800bdc:	ff 75 e4             	pushl  -0x1c(%ebp)
  800bdf:	50                   	push   %eax
  800be0:	56                   	push   %esi
  800be1:	53                   	push   %ebx
  800be2:	89 fa                	mov    %edi,%edx
  800be4:	8b 45 08             	mov    0x8(%ebp),%eax
  800be7:	e8 68 fb ff ff       	call   800754 <printnum>
			break;
  800bec:	83 c4 20             	add    $0x20,%esp
  800bef:	8b 75 d8             	mov    -0x28(%ebp),%esi
  800bf2:	e9 d2 fc ff ff       	jmp    8008c9 <vprintfmt+0x24>
  800bf7:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800bfa:	83 ec 08             	sub    $0x8,%esp
  800bfd:	57                   	push   %edi
  800bfe:	52                   	push   %edx
  800bff:	ff 55 08             	call   *0x8(%ebp)
			break;
  800c02:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800c05:	8b 75 d8             	mov    -0x28(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800c08:	e9 bc fc ff ff       	jmp    8008c9 <vprintfmt+0x24>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800c0d:	83 ec 08             	sub    $0x8,%esp
  800c10:	57                   	push   %edi
  800c11:	6a 25                	push   $0x25
  800c13:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800c16:	83 c4 10             	add    $0x10,%esp
  800c19:	eb 02                	jmp    800c1d <vprintfmt+0x378>
  800c1b:	89 c6                	mov    %eax,%esi
  800c1d:	8d 46 ff             	lea    -0x1(%esi),%eax
  800c20:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  800c24:	75 f5                	jne    800c1b <vprintfmt+0x376>
  800c26:	e9 9e fc ff ff       	jmp    8008c9 <vprintfmt+0x24>
				/* do nothing */;
			break;
		}
	}
}
  800c2b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c2e:	5b                   	pop    %ebx
  800c2f:	5e                   	pop    %esi
  800c30:	5f                   	pop    %edi
  800c31:	c9                   	leave  
  800c32:	c3                   	ret    

00800c33 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800c33:	55                   	push   %ebp
  800c34:	89 e5                	mov    %esp,%ebp
  800c36:	83 ec 18             	sub    $0x18,%esp
  800c39:	8b 45 08             	mov    0x8(%ebp),%eax
  800c3c:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800c3f:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800c42:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800c46:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800c49:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800c50:	85 c0                	test   %eax,%eax
  800c52:	74 26                	je     800c7a <vsnprintf+0x47>
  800c54:	85 d2                	test   %edx,%edx
  800c56:	7e 29                	jle    800c81 <vsnprintf+0x4e>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800c58:	ff 75 14             	pushl  0x14(%ebp)
  800c5b:	ff 75 10             	pushl  0x10(%ebp)
  800c5e:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800c61:	50                   	push   %eax
  800c62:	68 6e 08 80 00       	push   $0x80086e
  800c67:	e8 39 fc ff ff       	call   8008a5 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800c6c:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800c6f:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800c72:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800c75:	83 c4 10             	add    $0x10,%esp
  800c78:	eb 0c                	jmp    800c86 <vsnprintf+0x53>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800c7a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800c7f:	eb 05                	jmp    800c86 <vsnprintf+0x53>
  800c81:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800c86:	c9                   	leave  
  800c87:	c3                   	ret    

00800c88 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800c88:	55                   	push   %ebp
  800c89:	89 e5                	mov    %esp,%ebp
  800c8b:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800c8e:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800c91:	50                   	push   %eax
  800c92:	ff 75 10             	pushl  0x10(%ebp)
  800c95:	ff 75 0c             	pushl  0xc(%ebp)
  800c98:	ff 75 08             	pushl  0x8(%ebp)
  800c9b:	e8 93 ff ff ff       	call   800c33 <vsnprintf>
	va_end(ap);

	return rc;
}
  800ca0:	c9                   	leave  
  800ca1:	c3                   	ret    
	...

00800ca4 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800ca4:	55                   	push   %ebp
  800ca5:	89 e5                	mov    %esp,%ebp
  800ca7:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800caa:	80 3a 00             	cmpb   $0x0,(%edx)
  800cad:	74 0e                	je     800cbd <strlen+0x19>
  800caf:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  800cb4:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800cb5:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800cb9:	75 f9                	jne    800cb4 <strlen+0x10>
  800cbb:	eb 05                	jmp    800cc2 <strlen+0x1e>
  800cbd:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  800cc2:	c9                   	leave  
  800cc3:	c3                   	ret    

00800cc4 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800cc4:	55                   	push   %ebp
  800cc5:	89 e5                	mov    %esp,%ebp
  800cc7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800cca:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800ccd:	85 d2                	test   %edx,%edx
  800ccf:	74 17                	je     800ce8 <strnlen+0x24>
  800cd1:	80 39 00             	cmpb   $0x0,(%ecx)
  800cd4:	74 19                	je     800cef <strnlen+0x2b>
  800cd6:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  800cdb:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800cdc:	39 d0                	cmp    %edx,%eax
  800cde:	74 14                	je     800cf4 <strnlen+0x30>
  800ce0:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800ce4:	75 f5                	jne    800cdb <strnlen+0x17>
  800ce6:	eb 0c                	jmp    800cf4 <strnlen+0x30>
  800ce8:	b8 00 00 00 00       	mov    $0x0,%eax
  800ced:	eb 05                	jmp    800cf4 <strnlen+0x30>
  800cef:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  800cf4:	c9                   	leave  
  800cf5:	c3                   	ret    

00800cf6 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800cf6:	55                   	push   %ebp
  800cf7:	89 e5                	mov    %esp,%ebp
  800cf9:	53                   	push   %ebx
  800cfa:	8b 45 08             	mov    0x8(%ebp),%eax
  800cfd:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800d00:	ba 00 00 00 00       	mov    $0x0,%edx
  800d05:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  800d08:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800d0b:	42                   	inc    %edx
  800d0c:	84 c9                	test   %cl,%cl
  800d0e:	75 f5                	jne    800d05 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800d10:	5b                   	pop    %ebx
  800d11:	c9                   	leave  
  800d12:	c3                   	ret    

00800d13 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800d13:	55                   	push   %ebp
  800d14:	89 e5                	mov    %esp,%ebp
  800d16:	53                   	push   %ebx
  800d17:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800d1a:	53                   	push   %ebx
  800d1b:	e8 84 ff ff ff       	call   800ca4 <strlen>
  800d20:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800d23:	ff 75 0c             	pushl  0xc(%ebp)
  800d26:	8d 04 03             	lea    (%ebx,%eax,1),%eax
  800d29:	50                   	push   %eax
  800d2a:	e8 c7 ff ff ff       	call   800cf6 <strcpy>
	return dst;
}
  800d2f:	89 d8                	mov    %ebx,%eax
  800d31:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800d34:	c9                   	leave  
  800d35:	c3                   	ret    

00800d36 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800d36:	55                   	push   %ebp
  800d37:	89 e5                	mov    %esp,%ebp
  800d39:	56                   	push   %esi
  800d3a:	53                   	push   %ebx
  800d3b:	8b 45 08             	mov    0x8(%ebp),%eax
  800d3e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800d41:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800d44:	85 f6                	test   %esi,%esi
  800d46:	74 15                	je     800d5d <strncpy+0x27>
  800d48:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
  800d4d:	8a 1a                	mov    (%edx),%bl
  800d4f:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800d52:	80 3a 01             	cmpb   $0x1,(%edx)
  800d55:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800d58:	41                   	inc    %ecx
  800d59:	39 ce                	cmp    %ecx,%esi
  800d5b:	77 f0                	ja     800d4d <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800d5d:	5b                   	pop    %ebx
  800d5e:	5e                   	pop    %esi
  800d5f:	c9                   	leave  
  800d60:	c3                   	ret    

00800d61 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800d61:	55                   	push   %ebp
  800d62:	89 e5                	mov    %esp,%ebp
  800d64:	57                   	push   %edi
  800d65:	56                   	push   %esi
  800d66:	53                   	push   %ebx
  800d67:	8b 7d 08             	mov    0x8(%ebp),%edi
  800d6a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800d6d:	8b 75 10             	mov    0x10(%ebp),%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800d70:	85 f6                	test   %esi,%esi
  800d72:	74 32                	je     800da6 <strlcpy+0x45>
		while (--size > 0 && *src != '\0')
  800d74:	83 fe 01             	cmp    $0x1,%esi
  800d77:	74 22                	je     800d9b <strlcpy+0x3a>
  800d79:	8a 0b                	mov    (%ebx),%cl
  800d7b:	84 c9                	test   %cl,%cl
  800d7d:	74 20                	je     800d9f <strlcpy+0x3e>
  800d7f:	89 f8                	mov    %edi,%eax
  800d81:	ba 00 00 00 00       	mov    $0x0,%edx
	}
	return ret;
}

size_t
strlcpy(char *dst, const char *src, size_t size)
  800d86:	83 ee 02             	sub    $0x2,%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800d89:	88 08                	mov    %cl,(%eax)
  800d8b:	40                   	inc    %eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800d8c:	39 f2                	cmp    %esi,%edx
  800d8e:	74 11                	je     800da1 <strlcpy+0x40>
  800d90:	8a 4c 13 01          	mov    0x1(%ebx,%edx,1),%cl
  800d94:	42                   	inc    %edx
  800d95:	84 c9                	test   %cl,%cl
  800d97:	75 f0                	jne    800d89 <strlcpy+0x28>
  800d99:	eb 06                	jmp    800da1 <strlcpy+0x40>
  800d9b:	89 f8                	mov    %edi,%eax
  800d9d:	eb 02                	jmp    800da1 <strlcpy+0x40>
  800d9f:	89 f8                	mov    %edi,%eax
			*dst++ = *src++;
		*dst = '\0';
  800da1:	c6 00 00             	movb   $0x0,(%eax)
  800da4:	eb 02                	jmp    800da8 <strlcpy+0x47>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800da6:	89 f8                	mov    %edi,%eax
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
		*dst = '\0';
	}
	return dst - dst_in;
  800da8:	29 f8                	sub    %edi,%eax
}
  800daa:	5b                   	pop    %ebx
  800dab:	5e                   	pop    %esi
  800dac:	5f                   	pop    %edi
  800dad:	c9                   	leave  
  800dae:	c3                   	ret    

00800daf <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800daf:	55                   	push   %ebp
  800db0:	89 e5                	mov    %esp,%ebp
  800db2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800db5:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800db8:	8a 01                	mov    (%ecx),%al
  800dba:	84 c0                	test   %al,%al
  800dbc:	74 10                	je     800dce <strcmp+0x1f>
  800dbe:	3a 02                	cmp    (%edx),%al
  800dc0:	75 0c                	jne    800dce <strcmp+0x1f>
		p++, q++;
  800dc2:	41                   	inc    %ecx
  800dc3:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800dc4:	8a 01                	mov    (%ecx),%al
  800dc6:	84 c0                	test   %al,%al
  800dc8:	74 04                	je     800dce <strcmp+0x1f>
  800dca:	3a 02                	cmp    (%edx),%al
  800dcc:	74 f4                	je     800dc2 <strcmp+0x13>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800dce:	0f b6 c0             	movzbl %al,%eax
  800dd1:	0f b6 12             	movzbl (%edx),%edx
  800dd4:	29 d0                	sub    %edx,%eax
}
  800dd6:	c9                   	leave  
  800dd7:	c3                   	ret    

00800dd8 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800dd8:	55                   	push   %ebp
  800dd9:	89 e5                	mov    %esp,%ebp
  800ddb:	53                   	push   %ebx
  800ddc:	8b 55 08             	mov    0x8(%ebp),%edx
  800ddf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800de2:	8b 45 10             	mov    0x10(%ebp),%eax
	while (n > 0 && *p && *p == *q)
  800de5:	85 c0                	test   %eax,%eax
  800de7:	74 1b                	je     800e04 <strncmp+0x2c>
  800de9:	8a 1a                	mov    (%edx),%bl
  800deb:	84 db                	test   %bl,%bl
  800ded:	74 24                	je     800e13 <strncmp+0x3b>
  800def:	3a 19                	cmp    (%ecx),%bl
  800df1:	75 20                	jne    800e13 <strncmp+0x3b>
  800df3:	48                   	dec    %eax
  800df4:	74 15                	je     800e0b <strncmp+0x33>
		n--, p++, q++;
  800df6:	42                   	inc    %edx
  800df7:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800df8:	8a 1a                	mov    (%edx),%bl
  800dfa:	84 db                	test   %bl,%bl
  800dfc:	74 15                	je     800e13 <strncmp+0x3b>
  800dfe:	3a 19                	cmp    (%ecx),%bl
  800e00:	74 f1                	je     800df3 <strncmp+0x1b>
  800e02:	eb 0f                	jmp    800e13 <strncmp+0x3b>
		n--, p++, q++;
	if (n == 0)
		return 0;
  800e04:	b8 00 00 00 00       	mov    $0x0,%eax
  800e09:	eb 05                	jmp    800e10 <strncmp+0x38>
  800e0b:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800e10:	5b                   	pop    %ebx
  800e11:	c9                   	leave  
  800e12:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800e13:	0f b6 02             	movzbl (%edx),%eax
  800e16:	0f b6 11             	movzbl (%ecx),%edx
  800e19:	29 d0                	sub    %edx,%eax
  800e1b:	eb f3                	jmp    800e10 <strncmp+0x38>

00800e1d <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800e1d:	55                   	push   %ebp
  800e1e:	89 e5                	mov    %esp,%ebp
  800e20:	8b 45 08             	mov    0x8(%ebp),%eax
  800e23:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800e26:	8a 10                	mov    (%eax),%dl
  800e28:	84 d2                	test   %dl,%dl
  800e2a:	74 18                	je     800e44 <strchr+0x27>
		if (*s == c)
  800e2c:	38 ca                	cmp    %cl,%dl
  800e2e:	75 06                	jne    800e36 <strchr+0x19>
  800e30:	eb 17                	jmp    800e49 <strchr+0x2c>
  800e32:	38 ca                	cmp    %cl,%dl
  800e34:	74 13                	je     800e49 <strchr+0x2c>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800e36:	40                   	inc    %eax
  800e37:	8a 10                	mov    (%eax),%dl
  800e39:	84 d2                	test   %dl,%dl
  800e3b:	75 f5                	jne    800e32 <strchr+0x15>
		if (*s == c)
			return (char *) s;
	return 0;
  800e3d:	b8 00 00 00 00       	mov    $0x0,%eax
  800e42:	eb 05                	jmp    800e49 <strchr+0x2c>
  800e44:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800e49:	c9                   	leave  
  800e4a:	c3                   	ret    

00800e4b <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800e4b:	55                   	push   %ebp
  800e4c:	89 e5                	mov    %esp,%ebp
  800e4e:	8b 45 08             	mov    0x8(%ebp),%eax
  800e51:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800e54:	8a 10                	mov    (%eax),%dl
  800e56:	84 d2                	test   %dl,%dl
  800e58:	74 11                	je     800e6b <strfind+0x20>
		if (*s == c)
  800e5a:	38 ca                	cmp    %cl,%dl
  800e5c:	75 06                	jne    800e64 <strfind+0x19>
  800e5e:	eb 0b                	jmp    800e6b <strfind+0x20>
  800e60:	38 ca                	cmp    %cl,%dl
  800e62:	74 07                	je     800e6b <strfind+0x20>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800e64:	40                   	inc    %eax
  800e65:	8a 10                	mov    (%eax),%dl
  800e67:	84 d2                	test   %dl,%dl
  800e69:	75 f5                	jne    800e60 <strfind+0x15>
		if (*s == c)
			break;
	return (char *) s;
}
  800e6b:	c9                   	leave  
  800e6c:	c3                   	ret    

00800e6d <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800e6d:	55                   	push   %ebp
  800e6e:	89 e5                	mov    %esp,%ebp
  800e70:	57                   	push   %edi
  800e71:	56                   	push   %esi
  800e72:	53                   	push   %ebx
  800e73:	8b 7d 08             	mov    0x8(%ebp),%edi
  800e76:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e79:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800e7c:	85 c9                	test   %ecx,%ecx
  800e7e:	74 30                	je     800eb0 <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800e80:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800e86:	75 25                	jne    800ead <memset+0x40>
  800e88:	f6 c1 03             	test   $0x3,%cl
  800e8b:	75 20                	jne    800ead <memset+0x40>
		c &= 0xFF;
  800e8d:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800e90:	89 d3                	mov    %edx,%ebx
  800e92:	c1 e3 08             	shl    $0x8,%ebx
  800e95:	89 d6                	mov    %edx,%esi
  800e97:	c1 e6 18             	shl    $0x18,%esi
  800e9a:	89 d0                	mov    %edx,%eax
  800e9c:	c1 e0 10             	shl    $0x10,%eax
  800e9f:	09 f0                	or     %esi,%eax
  800ea1:	09 d0                	or     %edx,%eax
  800ea3:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800ea5:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800ea8:	fc                   	cld    
  800ea9:	f3 ab                	rep stos %eax,%es:(%edi)
  800eab:	eb 03                	jmp    800eb0 <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800ead:	fc                   	cld    
  800eae:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800eb0:	89 f8                	mov    %edi,%eax
  800eb2:	5b                   	pop    %ebx
  800eb3:	5e                   	pop    %esi
  800eb4:	5f                   	pop    %edi
  800eb5:	c9                   	leave  
  800eb6:	c3                   	ret    

00800eb7 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800eb7:	55                   	push   %ebp
  800eb8:	89 e5                	mov    %esp,%ebp
  800eba:	57                   	push   %edi
  800ebb:	56                   	push   %esi
  800ebc:	8b 45 08             	mov    0x8(%ebp),%eax
  800ebf:	8b 75 0c             	mov    0xc(%ebp),%esi
  800ec2:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800ec5:	39 c6                	cmp    %eax,%esi
  800ec7:	73 34                	jae    800efd <memmove+0x46>
  800ec9:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800ecc:	39 d0                	cmp    %edx,%eax
  800ece:	73 2d                	jae    800efd <memmove+0x46>
		s += n;
		d += n;
  800ed0:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800ed3:	f6 c2 03             	test   $0x3,%dl
  800ed6:	75 1b                	jne    800ef3 <memmove+0x3c>
  800ed8:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800ede:	75 13                	jne    800ef3 <memmove+0x3c>
  800ee0:	f6 c1 03             	test   $0x3,%cl
  800ee3:	75 0e                	jne    800ef3 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800ee5:	83 ef 04             	sub    $0x4,%edi
  800ee8:	8d 72 fc             	lea    -0x4(%edx),%esi
  800eeb:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800eee:	fd                   	std    
  800eef:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800ef1:	eb 07                	jmp    800efa <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800ef3:	4f                   	dec    %edi
  800ef4:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800ef7:	fd                   	std    
  800ef8:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800efa:	fc                   	cld    
  800efb:	eb 20                	jmp    800f1d <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800efd:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800f03:	75 13                	jne    800f18 <memmove+0x61>
  800f05:	a8 03                	test   $0x3,%al
  800f07:	75 0f                	jne    800f18 <memmove+0x61>
  800f09:	f6 c1 03             	test   $0x3,%cl
  800f0c:	75 0a                	jne    800f18 <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800f0e:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800f11:	89 c7                	mov    %eax,%edi
  800f13:	fc                   	cld    
  800f14:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800f16:	eb 05                	jmp    800f1d <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800f18:	89 c7                	mov    %eax,%edi
  800f1a:	fc                   	cld    
  800f1b:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800f1d:	5e                   	pop    %esi
  800f1e:	5f                   	pop    %edi
  800f1f:	c9                   	leave  
  800f20:	c3                   	ret    

00800f21 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800f21:	55                   	push   %ebp
  800f22:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800f24:	ff 75 10             	pushl  0x10(%ebp)
  800f27:	ff 75 0c             	pushl  0xc(%ebp)
  800f2a:	ff 75 08             	pushl  0x8(%ebp)
  800f2d:	e8 85 ff ff ff       	call   800eb7 <memmove>
}
  800f32:	c9                   	leave  
  800f33:	c3                   	ret    

00800f34 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800f34:	55                   	push   %ebp
  800f35:	89 e5                	mov    %esp,%ebp
  800f37:	57                   	push   %edi
  800f38:	56                   	push   %esi
  800f39:	53                   	push   %ebx
  800f3a:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800f3d:	8b 75 0c             	mov    0xc(%ebp),%esi
  800f40:	8b 7d 10             	mov    0x10(%ebp),%edi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800f43:	85 ff                	test   %edi,%edi
  800f45:	74 32                	je     800f79 <memcmp+0x45>
		if (*s1 != *s2)
  800f47:	8a 03                	mov    (%ebx),%al
  800f49:	8a 0e                	mov    (%esi),%cl
  800f4b:	38 c8                	cmp    %cl,%al
  800f4d:	74 19                	je     800f68 <memcmp+0x34>
  800f4f:	eb 0d                	jmp    800f5e <memcmp+0x2a>
  800f51:	8a 44 13 01          	mov    0x1(%ebx,%edx,1),%al
  800f55:	8a 4c 16 01          	mov    0x1(%esi,%edx,1),%cl
  800f59:	42                   	inc    %edx
  800f5a:	38 c8                	cmp    %cl,%al
  800f5c:	74 10                	je     800f6e <memcmp+0x3a>
			return (int) *s1 - (int) *s2;
  800f5e:	0f b6 c0             	movzbl %al,%eax
  800f61:	0f b6 c9             	movzbl %cl,%ecx
  800f64:	29 c8                	sub    %ecx,%eax
  800f66:	eb 16                	jmp    800f7e <memcmp+0x4a>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800f68:	4f                   	dec    %edi
  800f69:	ba 00 00 00 00       	mov    $0x0,%edx
  800f6e:	39 fa                	cmp    %edi,%edx
  800f70:	75 df                	jne    800f51 <memcmp+0x1d>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800f72:	b8 00 00 00 00       	mov    $0x0,%eax
  800f77:	eb 05                	jmp    800f7e <memcmp+0x4a>
  800f79:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800f7e:	5b                   	pop    %ebx
  800f7f:	5e                   	pop    %esi
  800f80:	5f                   	pop    %edi
  800f81:	c9                   	leave  
  800f82:	c3                   	ret    

00800f83 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800f83:	55                   	push   %ebp
  800f84:	89 e5                	mov    %esp,%ebp
  800f86:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800f89:	89 c2                	mov    %eax,%edx
  800f8b:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800f8e:	39 d0                	cmp    %edx,%eax
  800f90:	73 12                	jae    800fa4 <memfind+0x21>
		if (*(const unsigned char *) s == (unsigned char) c)
  800f92:	8a 4d 0c             	mov    0xc(%ebp),%cl
  800f95:	38 08                	cmp    %cl,(%eax)
  800f97:	75 06                	jne    800f9f <memfind+0x1c>
  800f99:	eb 09                	jmp    800fa4 <memfind+0x21>
  800f9b:	38 08                	cmp    %cl,(%eax)
  800f9d:	74 05                	je     800fa4 <memfind+0x21>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800f9f:	40                   	inc    %eax
  800fa0:	39 c2                	cmp    %eax,%edx
  800fa2:	77 f7                	ja     800f9b <memfind+0x18>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800fa4:	c9                   	leave  
  800fa5:	c3                   	ret    

00800fa6 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800fa6:	55                   	push   %ebp
  800fa7:	89 e5                	mov    %esp,%ebp
  800fa9:	57                   	push   %edi
  800faa:	56                   	push   %esi
  800fab:	53                   	push   %ebx
  800fac:	8b 55 08             	mov    0x8(%ebp),%edx
  800faf:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800fb2:	eb 01                	jmp    800fb5 <strtol+0xf>
		s++;
  800fb4:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800fb5:	8a 02                	mov    (%edx),%al
  800fb7:	3c 20                	cmp    $0x20,%al
  800fb9:	74 f9                	je     800fb4 <strtol+0xe>
  800fbb:	3c 09                	cmp    $0x9,%al
  800fbd:	74 f5                	je     800fb4 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800fbf:	3c 2b                	cmp    $0x2b,%al
  800fc1:	75 08                	jne    800fcb <strtol+0x25>
		s++;
  800fc3:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800fc4:	bf 00 00 00 00       	mov    $0x0,%edi
  800fc9:	eb 13                	jmp    800fde <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800fcb:	3c 2d                	cmp    $0x2d,%al
  800fcd:	75 0a                	jne    800fd9 <strtol+0x33>
		s++, neg = 1;
  800fcf:	8d 52 01             	lea    0x1(%edx),%edx
  800fd2:	bf 01 00 00 00       	mov    $0x1,%edi
  800fd7:	eb 05                	jmp    800fde <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800fd9:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800fde:	85 db                	test   %ebx,%ebx
  800fe0:	74 05                	je     800fe7 <strtol+0x41>
  800fe2:	83 fb 10             	cmp    $0x10,%ebx
  800fe5:	75 28                	jne    80100f <strtol+0x69>
  800fe7:	8a 02                	mov    (%edx),%al
  800fe9:	3c 30                	cmp    $0x30,%al
  800feb:	75 10                	jne    800ffd <strtol+0x57>
  800fed:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800ff1:	75 0a                	jne    800ffd <strtol+0x57>
		s += 2, base = 16;
  800ff3:	83 c2 02             	add    $0x2,%edx
  800ff6:	bb 10 00 00 00       	mov    $0x10,%ebx
  800ffb:	eb 12                	jmp    80100f <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  800ffd:	85 db                	test   %ebx,%ebx
  800fff:	75 0e                	jne    80100f <strtol+0x69>
  801001:	3c 30                	cmp    $0x30,%al
  801003:	75 05                	jne    80100a <strtol+0x64>
		s++, base = 8;
  801005:	42                   	inc    %edx
  801006:	b3 08                	mov    $0x8,%bl
  801008:	eb 05                	jmp    80100f <strtol+0x69>
	else if (base == 0)
		base = 10;
  80100a:	bb 0a 00 00 00       	mov    $0xa,%ebx
  80100f:	b8 00 00 00 00       	mov    $0x0,%eax
  801014:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  801016:	8a 0a                	mov    (%edx),%cl
  801018:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  80101b:	80 fb 09             	cmp    $0x9,%bl
  80101e:	77 08                	ja     801028 <strtol+0x82>
			dig = *s - '0';
  801020:	0f be c9             	movsbl %cl,%ecx
  801023:	83 e9 30             	sub    $0x30,%ecx
  801026:	eb 1e                	jmp    801046 <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  801028:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  80102b:	80 fb 19             	cmp    $0x19,%bl
  80102e:	77 08                	ja     801038 <strtol+0x92>
			dig = *s - 'a' + 10;
  801030:	0f be c9             	movsbl %cl,%ecx
  801033:	83 e9 57             	sub    $0x57,%ecx
  801036:	eb 0e                	jmp    801046 <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  801038:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  80103b:	80 fb 19             	cmp    $0x19,%bl
  80103e:	77 13                	ja     801053 <strtol+0xad>
			dig = *s - 'A' + 10;
  801040:	0f be c9             	movsbl %cl,%ecx
  801043:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  801046:	39 f1                	cmp    %esi,%ecx
  801048:	7d 0d                	jge    801057 <strtol+0xb1>
			break;
		s++, val = (val * base) + dig;
  80104a:	42                   	inc    %edx
  80104b:	0f af c6             	imul   %esi,%eax
  80104e:	8d 04 01             	lea    (%ecx,%eax,1),%eax
		// we don't properly detect overflow!
	}
  801051:	eb c3                	jmp    801016 <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  801053:	89 c1                	mov    %eax,%ecx
  801055:	eb 02                	jmp    801059 <strtol+0xb3>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  801057:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  801059:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  80105d:	74 05                	je     801064 <strtol+0xbe>
		*endptr = (char *) s;
  80105f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801062:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  801064:	85 ff                	test   %edi,%edi
  801066:	74 04                	je     80106c <strtol+0xc6>
  801068:	89 c8                	mov    %ecx,%eax
  80106a:	f7 d8                	neg    %eax
}
  80106c:	5b                   	pop    %ebx
  80106d:	5e                   	pop    %esi
  80106e:	5f                   	pop    %edi
  80106f:	c9                   	leave  
  801070:	c3                   	ret    
  801071:	00 00                	add    %al,(%eax)
	...

00801074 <syscall>:
	return ret;
}

static int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  801074:	55                   	push   %ebp
  801075:	89 e5                	mov    %esp,%ebp
  801077:	57                   	push   %edi
  801078:	56                   	push   %esi
  801079:	53                   	push   %ebx
  80107a:	83 ec 1c             	sub    $0x1c,%esp
  80107d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801080:	89 55 e0             	mov    %edx,-0x20(%ebp)
  801083:	89 ca                	mov    %ecx,%edx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801085:	8b 75 14             	mov    0x14(%ebp),%esi
  801088:	8b 7d 10             	mov    0x10(%ebp),%edi
  80108b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80108e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801091:	cd 30                	int    $0x30
  801093:	89 c2                	mov    %eax,%edx
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  801095:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  801099:	74 1c                	je     8010b7 <syscall+0x43>
  80109b:	85 c0                	test   %eax,%eax
  80109d:	7e 18                	jle    8010b7 <syscall+0x43>
		panic("syscall %d returned %d (> 0)", num, ret);
  80109f:	83 ec 0c             	sub    $0xc,%esp
  8010a2:	50                   	push   %eax
  8010a3:	ff 75 e4             	pushl  -0x1c(%ebp)
  8010a6:	68 7f 2a 80 00       	push   $0x802a7f
  8010ab:	6a 42                	push   $0x42
  8010ad:	68 9c 2a 80 00       	push   $0x802a9c
  8010b2:	e8 b1 f5 ff ff       	call   800668 <_panic>

	return ret;
}
  8010b7:	89 d0                	mov    %edx,%eax
  8010b9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8010bc:	5b                   	pop    %ebx
  8010bd:	5e                   	pop    %esi
  8010be:	5f                   	pop    %edi
  8010bf:	c9                   	leave  
  8010c0:	c3                   	ret    

008010c1 <sys_cputs>:

void
sys_cputs(const char *s, size_t len)
{	
  8010c1:	55                   	push   %ebp
  8010c2:	89 e5                	mov    %esp,%ebp
  8010c4:	83 ec 08             	sub    $0x8,%esp
	// my_sysenter(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
	// return;
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
  8010c7:	6a 00                	push   $0x0
  8010c9:	6a 00                	push   $0x0
  8010cb:	6a 00                	push   $0x0
  8010cd:	ff 75 0c             	pushl  0xc(%ebp)
  8010d0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8010d3:	ba 00 00 00 00       	mov    $0x0,%edx
  8010d8:	b8 00 00 00 00       	mov    $0x0,%eax
  8010dd:	e8 92 ff ff ff       	call   801074 <syscall>
  8010e2:	83 c4 10             	add    $0x10,%esp
	return;
}
  8010e5:	c9                   	leave  
  8010e6:	c3                   	ret    

008010e7 <sys_cgetc>:

int
sys_cgetc(void)
{
  8010e7:	55                   	push   %ebp
  8010e8:	89 e5                	mov    %esp,%ebp
  8010ea:	83 ec 08             	sub    $0x8,%esp
	// return my_sysenter(SYS_cgetc, 0, 0, 0, 0, 0, 0);
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
  8010ed:	6a 00                	push   $0x0
  8010ef:	6a 00                	push   $0x0
  8010f1:	6a 00                	push   $0x0
  8010f3:	6a 00                	push   $0x0
  8010f5:	b9 00 00 00 00       	mov    $0x0,%ecx
  8010fa:	ba 00 00 00 00       	mov    $0x0,%edx
  8010ff:	b8 01 00 00 00       	mov    $0x1,%eax
  801104:	e8 6b ff ff ff       	call   801074 <syscall>
}
  801109:	c9                   	leave  
  80110a:	c3                   	ret    

0080110b <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  80110b:	55                   	push   %ebp
  80110c:	89 e5                	mov    %esp,%ebp
  80110e:	83 ec 08             	sub    $0x8,%esp
	// return my_sysenter(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
  801111:	6a 00                	push   $0x0
  801113:	6a 00                	push   $0x0
  801115:	6a 00                	push   $0x0
  801117:	6a 00                	push   $0x0
  801119:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80111c:	ba 01 00 00 00       	mov    $0x1,%edx
  801121:	b8 03 00 00 00       	mov    $0x3,%eax
  801126:	e8 49 ff ff ff       	call   801074 <syscall>
}
  80112b:	c9                   	leave  
  80112c:	c3                   	ret    

0080112d <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  80112d:	55                   	push   %ebp
  80112e:	89 e5                	mov    %esp,%ebp
  801130:	83 ec 08             	sub    $0x8,%esp
	// return my_sysenter(SYS_getenvid, 0, 0, 0, 0, 0, 0);
	return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
  801133:	6a 00                	push   $0x0
  801135:	6a 00                	push   $0x0
  801137:	6a 00                	push   $0x0
  801139:	6a 00                	push   $0x0
  80113b:	b9 00 00 00 00       	mov    $0x0,%ecx
  801140:	ba 00 00 00 00       	mov    $0x0,%edx
  801145:	b8 02 00 00 00       	mov    $0x2,%eax
  80114a:	e8 25 ff ff ff       	call   801074 <syscall>
}
  80114f:	c9                   	leave  
  801150:	c3                   	ret    

00801151 <sys_yield>:

void
sys_yield(void)
{
  801151:	55                   	push   %ebp
  801152:	89 e5                	mov    %esp,%ebp
  801154:	83 ec 08             	sub    $0x8,%esp
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
  801157:	6a 00                	push   $0x0
  801159:	6a 00                	push   $0x0
  80115b:	6a 00                	push   $0x0
  80115d:	6a 00                	push   $0x0
  80115f:	b9 00 00 00 00       	mov    $0x0,%ecx
  801164:	ba 00 00 00 00       	mov    $0x0,%edx
  801169:	b8 0b 00 00 00       	mov    $0xb,%eax
  80116e:	e8 01 ff ff ff       	call   801074 <syscall>
  801173:	83 c4 10             	add    $0x10,%esp
}
  801176:	c9                   	leave  
  801177:	c3                   	ret    

00801178 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  801178:	55                   	push   %ebp
  801179:	89 e5                	mov    %esp,%ebp
  80117b:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
  80117e:	6a 00                	push   $0x0
  801180:	6a 00                	push   $0x0
  801182:	ff 75 10             	pushl  0x10(%ebp)
  801185:	ff 75 0c             	pushl  0xc(%ebp)
  801188:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80118b:	ba 01 00 00 00       	mov    $0x1,%edx
  801190:	b8 04 00 00 00       	mov    $0x4,%eax
  801195:	e8 da fe ff ff       	call   801074 <syscall>
}
  80119a:	c9                   	leave  
  80119b:	c3                   	ret    

0080119c <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  80119c:	55                   	push   %ebp
  80119d:	89 e5                	mov    %esp,%ebp
  80119f:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
  8011a2:	ff 75 18             	pushl  0x18(%ebp)
  8011a5:	ff 75 14             	pushl  0x14(%ebp)
  8011a8:	ff 75 10             	pushl  0x10(%ebp)
  8011ab:	ff 75 0c             	pushl  0xc(%ebp)
  8011ae:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8011b1:	ba 01 00 00 00       	mov    $0x1,%edx
  8011b6:	b8 05 00 00 00       	mov    $0x5,%eax
  8011bb:	e8 b4 fe ff ff       	call   801074 <syscall>
}
  8011c0:	c9                   	leave  
  8011c1:	c3                   	ret    

008011c2 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  8011c2:	55                   	push   %ebp
  8011c3:	89 e5                	mov    %esp,%ebp
  8011c5:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
  8011c8:	6a 00                	push   $0x0
  8011ca:	6a 00                	push   $0x0
  8011cc:	6a 00                	push   $0x0
  8011ce:	ff 75 0c             	pushl  0xc(%ebp)
  8011d1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8011d4:	ba 01 00 00 00       	mov    $0x1,%edx
  8011d9:	b8 06 00 00 00       	mov    $0x6,%eax
  8011de:	e8 91 fe ff ff       	call   801074 <syscall>
}
  8011e3:	c9                   	leave  
  8011e4:	c3                   	ret    

008011e5 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  8011e5:	55                   	push   %ebp
  8011e6:	89 e5                	mov    %esp,%ebp
  8011e8:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
  8011eb:	6a 00                	push   $0x0
  8011ed:	6a 00                	push   $0x0
  8011ef:	6a 00                	push   $0x0
  8011f1:	ff 75 0c             	pushl  0xc(%ebp)
  8011f4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8011f7:	ba 01 00 00 00       	mov    $0x1,%edx
  8011fc:	b8 08 00 00 00       	mov    $0x8,%eax
  801201:	e8 6e fe ff ff       	call   801074 <syscall>
}
  801206:	c9                   	leave  
  801207:	c3                   	ret    

00801208 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  801208:	55                   	push   %ebp
  801209:	89 e5                	mov    %esp,%ebp
  80120b:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
  80120e:	6a 00                	push   $0x0
  801210:	6a 00                	push   $0x0
  801212:	6a 00                	push   $0x0
  801214:	ff 75 0c             	pushl  0xc(%ebp)
  801217:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80121a:	ba 01 00 00 00       	mov    $0x1,%edx
  80121f:	b8 09 00 00 00       	mov    $0x9,%eax
  801224:	e8 4b fe ff ff       	call   801074 <syscall>
}
  801229:	c9                   	leave  
  80122a:	c3                   	ret    

0080122b <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  80122b:	55                   	push   %ebp
  80122c:	89 e5                	mov    %esp,%ebp
  80122e:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
  801231:	6a 00                	push   $0x0
  801233:	6a 00                	push   $0x0
  801235:	6a 00                	push   $0x0
  801237:	ff 75 0c             	pushl  0xc(%ebp)
  80123a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80123d:	ba 01 00 00 00       	mov    $0x1,%edx
  801242:	b8 0a 00 00 00       	mov    $0xa,%eax
  801247:	e8 28 fe ff ff       	call   801074 <syscall>
}
  80124c:	c9                   	leave  
  80124d:	c3                   	ret    

0080124e <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  80124e:	55                   	push   %ebp
  80124f:	89 e5                	mov    %esp,%ebp
  801251:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
  801254:	6a 00                	push   $0x0
  801256:	ff 75 14             	pushl  0x14(%ebp)
  801259:	ff 75 10             	pushl  0x10(%ebp)
  80125c:	ff 75 0c             	pushl  0xc(%ebp)
  80125f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801262:	ba 00 00 00 00       	mov    $0x0,%edx
  801267:	b8 0c 00 00 00       	mov    $0xc,%eax
  80126c:	e8 03 fe ff ff       	call   801074 <syscall>
}
  801271:	c9                   	leave  
  801272:	c3                   	ret    

00801273 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  801273:	55                   	push   %ebp
  801274:	89 e5                	mov    %esp,%ebp
  801276:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
  801279:	6a 00                	push   $0x0
  80127b:	6a 00                	push   $0x0
  80127d:	6a 00                	push   $0x0
  80127f:	6a 00                	push   $0x0
  801281:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801284:	ba 01 00 00 00       	mov    $0x1,%edx
  801289:	b8 0d 00 00 00       	mov    $0xd,%eax
  80128e:	e8 e1 fd ff ff       	call   801074 <syscall>
}
  801293:	c9                   	leave  
  801294:	c3                   	ret    

00801295 <sys_set_priority>:

int
sys_set_priority(envid_t envid, uint32_t new_priority)
{
  801295:	55                   	push   %ebp
  801296:	89 e5                	mov    %esp,%ebp
  801298:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_set_priority, 0, envid, new_priority, 0, 0, 0);
  80129b:	6a 00                	push   $0x0
  80129d:	6a 00                	push   $0x0
  80129f:	6a 00                	push   $0x0
  8012a1:	ff 75 0c             	pushl  0xc(%ebp)
  8012a4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8012a7:	ba 00 00 00 00       	mov    $0x0,%edx
  8012ac:	b8 0e 00 00 00       	mov    $0xe,%eax
  8012b1:	e8 be fd ff ff       	call   801074 <syscall>
}
  8012b6:	c9                   	leave  
  8012b7:	c3                   	ret    

008012b8 <sys_exec>:

int
sys_exec(uint32_t eip, uint32_t esp, void * ph, uint32_t elf_phnum)
{
  8012b8:	55                   	push   %ebp
  8012b9:	89 e5                	mov    %esp,%ebp
  8012bb:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_exec, 0, eip, esp, (uint32_t)ph, elf_phnum, 0);
  8012be:	6a 00                	push   $0x0
  8012c0:	ff 75 14             	pushl  0x14(%ebp)
  8012c3:	ff 75 10             	pushl  0x10(%ebp)
  8012c6:	ff 75 0c             	pushl  0xc(%ebp)
  8012c9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8012cc:	ba 00 00 00 00       	mov    $0x0,%edx
  8012d1:	b8 0f 00 00 00       	mov    $0xf,%eax
  8012d6:	e8 99 fd ff ff       	call   801074 <syscall>
} 
  8012db:	c9                   	leave  
  8012dc:	c3                   	ret    

008012dd <sys_join>:

// thread:
int
sys_join(envid_t envid)
{
  8012dd:	55                   	push   %ebp
  8012de:	89 e5                	mov    %esp,%ebp
  8012e0:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_join, 0, envid, 0, 0, 0, 0);
  8012e3:	6a 00                	push   $0x0
  8012e5:	6a 00                	push   $0x0
  8012e7:	6a 00                	push   $0x0
  8012e9:	6a 00                	push   $0x0
  8012eb:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8012ee:	ba 00 00 00 00       	mov    $0x0,%edx
  8012f3:	b8 11 00 00 00       	mov    $0x11,%eax
  8012f8:	e8 77 fd ff ff       	call   801074 <syscall>
}
  8012fd:	c9                   	leave  
  8012fe:	c3                   	ret    

008012ff <sys_getpid>:

envid_t
sys_getpid(void)
{
  8012ff:	55                   	push   %ebp
  801300:	89 e5                	mov    %esp,%ebp
  801302:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_getpid, 0, 0, 0, 0, 0, 0);
  801305:	6a 00                	push   $0x0
  801307:	6a 00                	push   $0x0
  801309:	6a 00                	push   $0x0
  80130b:	6a 00                	push   $0x0
  80130d:	b9 00 00 00 00       	mov    $0x0,%ecx
  801312:	ba 00 00 00 00       	mov    $0x0,%edx
  801317:	b8 10 00 00 00       	mov    $0x10,%eax
  80131c:	e8 53 fd ff ff       	call   801074 <syscall>
  801321:	c9                   	leave  
  801322:	c3                   	ret    
	...

00801324 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801324:	55                   	push   %ebp
  801325:	89 e5                	mov    %esp,%ebp
  801327:	56                   	push   %esi
  801328:	53                   	push   %ebx
  801329:	8b 75 08             	mov    0x8(%ebp),%esi
  80132c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80132f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// cprintf("0x%x 0x%x 0x%x\n", (uint32_t)from_env_store, (uint32_t)pg, (uint32_t)perm_store);
	int r;
	if (pg != NULL) {
  801332:	85 c0                	test   %eax,%eax
  801334:	74 0e                	je     801344 <ipc_recv+0x20>
		r = sys_ipc_recv(pg);
  801336:	83 ec 0c             	sub    $0xc,%esp
  801339:	50                   	push   %eax
  80133a:	e8 34 ff ff ff       	call   801273 <sys_ipc_recv>
  80133f:	83 c4 10             	add    $0x10,%esp
  801342:	eb 10                	jmp    801354 <ipc_recv+0x30>
	} else {
		r = sys_ipc_recv((void *)UTOP);
  801344:	83 ec 0c             	sub    $0xc,%esp
  801347:	68 00 00 c0 ee       	push   $0xeec00000
  80134c:	e8 22 ff ff ff       	call   801273 <sys_ipc_recv>
  801351:	83 c4 10             	add    $0x10,%esp
	}

	if (r == 0) {
  801354:	85 c0                	test   %eax,%eax
  801356:	75 26                	jne    80137e <ipc_recv+0x5a>
		if (from_env_store != NULL) *from_env_store = thisenv->env_ipc_from;
  801358:	85 f6                	test   %esi,%esi
  80135a:	74 0a                	je     801366 <ipc_recv+0x42>
  80135c:	a1 04 40 80 00       	mov    0x804004,%eax
  801361:	8b 40 74             	mov    0x74(%eax),%eax
  801364:	89 06                	mov    %eax,(%esi)
		if (perm_store != NULL) *perm_store = thisenv->env_ipc_perm;
  801366:	85 db                	test   %ebx,%ebx
  801368:	74 0a                	je     801374 <ipc_recv+0x50>
  80136a:	a1 04 40 80 00       	mov    0x804004,%eax
  80136f:	8b 40 78             	mov    0x78(%eax),%eax
  801372:	89 03                	mov    %eax,(%ebx)
		return thisenv->env_ipc_value;
  801374:	a1 04 40 80 00       	mov    0x804004,%eax
  801379:	8b 40 70             	mov    0x70(%eax),%eax
  80137c:	eb 14                	jmp    801392 <ipc_recv+0x6e>
	} else {
		// fails;
		if (from_env_store != NULL) *from_env_store = 0;
  80137e:	85 f6                	test   %esi,%esi
  801380:	74 06                	je     801388 <ipc_recv+0x64>
  801382:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		if (perm_store != NULL) *perm_store = 0;
  801388:	85 db                	test   %ebx,%ebx
  80138a:	74 06                	je     801392 <ipc_recv+0x6e>
  80138c:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
		return r;
	}
}
  801392:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801395:	5b                   	pop    %ebx
  801396:	5e                   	pop    %esi
  801397:	c9                   	leave  
  801398:	c3                   	ret    

00801399 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801399:	55                   	push   %ebp
  80139a:	89 e5                	mov    %esp,%ebp
  80139c:	57                   	push   %edi
  80139d:	56                   	push   %esi
  80139e:	53                   	push   %ebx
  80139f:	83 ec 0c             	sub    $0xc,%esp
  8013a2:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8013a5:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8013a8:	8b 75 14             	mov    0x14(%ebp),%esi
	// LAB 4: Your code here.
	// int sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
	int r;
	if (pg == NULL) pg = (void *)UTOP;
  8013ab:	85 db                	test   %ebx,%ebx
  8013ad:	75 25                	jne    8013d4 <ipc_send+0x3b>
  8013af:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
  8013b4:	eb 1e                	jmp    8013d4 <ipc_send+0x3b>
	
	while ((r = sys_ipc_try_send(to_env, val, pg, perm)) != 0) {
		if (r == -E_IPC_NOT_RECV) {
  8013b6:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8013b9:	75 07                	jne    8013c2 <ipc_send+0x29>
			// cprintf("Try Again and Again....\n");
			sys_yield();
  8013bb:	e8 91 fd ff ff       	call   801151 <sys_yield>
  8013c0:	eb 12                	jmp    8013d4 <ipc_send+0x3b>
		} else {
			panic("ipc_send error %e\n", r);
  8013c2:	50                   	push   %eax
  8013c3:	68 aa 2a 80 00       	push   $0x802aaa
  8013c8:	6a 43                	push   $0x43
  8013ca:	68 bd 2a 80 00       	push   $0x802abd
  8013cf:	e8 94 f2 ff ff       	call   800668 <_panic>
	// LAB 4: Your code here.
	// int sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
	int r;
	if (pg == NULL) pg = (void *)UTOP;
	
	while ((r = sys_ipc_try_send(to_env, val, pg, perm)) != 0) {
  8013d4:	56                   	push   %esi
  8013d5:	53                   	push   %ebx
  8013d6:	57                   	push   %edi
  8013d7:	ff 75 08             	pushl  0x8(%ebp)
  8013da:	e8 6f fe ff ff       	call   80124e <sys_ipc_try_send>
  8013df:	83 c4 10             	add    $0x10,%esp
  8013e2:	85 c0                	test   %eax,%eax
  8013e4:	75 d0                	jne    8013b6 <ipc_send+0x1d>
		} else {
			panic("ipc_send error %e\n", r);
		}
	}
	return;
}
  8013e6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8013e9:	5b                   	pop    %ebx
  8013ea:	5e                   	pop    %esi
  8013eb:	5f                   	pop    %edi
  8013ec:	c9                   	leave  
  8013ed:	c3                   	ret    

008013ee <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  8013ee:	55                   	push   %ebp
  8013ef:	89 e5                	mov    %esp,%ebp
  8013f1:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
		if (envs[i].env_type == type)
  8013f4:	39 0d 50 00 c0 ee    	cmp    %ecx,0xeec00050
  8013fa:	74 1a                	je     801416 <ipc_find_env+0x28>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8013fc:	b8 01 00 00 00       	mov    $0x1,%eax
		if (envs[i].env_type == type)
  801401:	89 c2                	mov    %eax,%edx
  801403:	c1 e2 07             	shl    $0x7,%edx
  801406:	8d 94 82 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,4),%edx
  80140d:	8b 52 50             	mov    0x50(%edx),%edx
  801410:	39 ca                	cmp    %ecx,%edx
  801412:	75 18                	jne    80142c <ipc_find_env+0x3e>
  801414:	eb 05                	jmp    80141b <ipc_find_env+0x2d>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801416:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
			return envs[i].env_id;
  80141b:	89 c2                	mov    %eax,%edx
  80141d:	c1 e2 07             	shl    $0x7,%edx
  801420:	8d 84 82 08 00 c0 ee 	lea    -0x113ffff8(%edx,%eax,4),%eax
  801427:	8b 40 40             	mov    0x40(%eax),%eax
  80142a:	eb 0c                	jmp    801438 <ipc_find_env+0x4a>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  80142c:	40                   	inc    %eax
  80142d:	3d 00 04 00 00       	cmp    $0x400,%eax
  801432:	75 cd                	jne    801401 <ipc_find_env+0x13>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801434:	66 b8 00 00          	mov    $0x0,%ax
}
  801438:	c9                   	leave  
  801439:	c3                   	ret    
	...

0080143c <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  80143c:	55                   	push   %ebp
  80143d:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80143f:	8b 45 08             	mov    0x8(%ebp),%eax
  801442:	05 00 00 00 30       	add    $0x30000000,%eax
  801447:	c1 e8 0c             	shr    $0xc,%eax
}
  80144a:	c9                   	leave  
  80144b:	c3                   	ret    

0080144c <fd2data>:

char*
fd2data(struct Fd *fd)
{
  80144c:	55                   	push   %ebp
  80144d:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  80144f:	ff 75 08             	pushl  0x8(%ebp)
  801452:	e8 e5 ff ff ff       	call   80143c <fd2num>
  801457:	83 c4 04             	add    $0x4,%esp
  80145a:	05 20 00 0d 00       	add    $0xd0020,%eax
  80145f:	c1 e0 0c             	shl    $0xc,%eax
}
  801462:	c9                   	leave  
  801463:	c3                   	ret    

00801464 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801464:	55                   	push   %ebp
  801465:	89 e5                	mov    %esp,%ebp
  801467:	53                   	push   %ebx
  801468:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  80146b:	a1 00 dd 7b ef       	mov    0xef7bdd00,%eax
  801470:	a8 01                	test   $0x1,%al
  801472:	74 34                	je     8014a8 <fd_alloc+0x44>
  801474:	a1 00 00 74 ef       	mov    0xef740000,%eax
  801479:	a8 01                	test   $0x1,%al
  80147b:	74 32                	je     8014af <fd_alloc+0x4b>
  80147d:	b8 00 10 00 d0       	mov    $0xd0001000,%eax
  801482:	89 c1                	mov    %eax,%ecx
  801484:	89 c2                	mov    %eax,%edx
  801486:	c1 ea 16             	shr    $0x16,%edx
  801489:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801490:	f6 c2 01             	test   $0x1,%dl
  801493:	74 1f                	je     8014b4 <fd_alloc+0x50>
  801495:	89 c2                	mov    %eax,%edx
  801497:	c1 ea 0c             	shr    $0xc,%edx
  80149a:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8014a1:	f6 c2 01             	test   $0x1,%dl
  8014a4:	75 17                	jne    8014bd <fd_alloc+0x59>
  8014a6:	eb 0c                	jmp    8014b4 <fd_alloc+0x50>
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  8014a8:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
  8014ad:	eb 05                	jmp    8014b4 <fd_alloc+0x50>
  8014af:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
  8014b4:	89 0b                	mov    %ecx,(%ebx)
			return 0;
  8014b6:	b8 00 00 00 00       	mov    $0x0,%eax
  8014bb:	eb 17                	jmp    8014d4 <fd_alloc+0x70>
  8014bd:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8014c2:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8014c7:	75 b9                	jne    801482 <fd_alloc+0x1e>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8014c9:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_MAX_OPEN;
  8014cf:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8014d4:	5b                   	pop    %ebx
  8014d5:	c9                   	leave  
  8014d6:	c3                   	ret    

008014d7 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8014d7:	55                   	push   %ebp
  8014d8:	89 e5                	mov    %esp,%ebp
  8014da:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8014dd:	83 f8 1f             	cmp    $0x1f,%eax
  8014e0:	77 36                	ja     801518 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8014e2:	05 00 00 0d 00       	add    $0xd0000,%eax
  8014e7:	c1 e0 0c             	shl    $0xc,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8014ea:	89 c2                	mov    %eax,%edx
  8014ec:	c1 ea 16             	shr    $0x16,%edx
  8014ef:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8014f6:	f6 c2 01             	test   $0x1,%dl
  8014f9:	74 24                	je     80151f <fd_lookup+0x48>
  8014fb:	89 c2                	mov    %eax,%edx
  8014fd:	c1 ea 0c             	shr    $0xc,%edx
  801500:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801507:	f6 c2 01             	test   $0x1,%dl
  80150a:	74 1a                	je     801526 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  80150c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80150f:	89 02                	mov    %eax,(%edx)
	return 0;
  801511:	b8 00 00 00 00       	mov    $0x0,%eax
  801516:	eb 13                	jmp    80152b <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801518:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80151d:	eb 0c                	jmp    80152b <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80151f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801524:	eb 05                	jmp    80152b <fd_lookup+0x54>
  801526:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  80152b:	c9                   	leave  
  80152c:	c3                   	ret    

0080152d <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  80152d:	55                   	push   %ebp
  80152e:	89 e5                	mov    %esp,%ebp
  801530:	53                   	push   %ebx
  801531:	83 ec 04             	sub    $0x4,%esp
  801534:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801537:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
		if (devtab[i]->dev_id == dev_id) {
  80153a:	39 0d 08 30 80 00    	cmp    %ecx,0x803008
  801540:	74 0d                	je     80154f <dev_lookup+0x22>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801542:	b8 00 00 00 00       	mov    $0x0,%eax
  801547:	eb 14                	jmp    80155d <dev_lookup+0x30>
		if (devtab[i]->dev_id == dev_id) {
  801549:	39 0a                	cmp    %ecx,(%edx)
  80154b:	75 10                	jne    80155d <dev_lookup+0x30>
  80154d:	eb 05                	jmp    801554 <dev_lookup+0x27>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  80154f:	ba 08 30 80 00       	mov    $0x803008,%edx
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
  801554:	89 13                	mov    %edx,(%ebx)
			return 0;
  801556:	b8 00 00 00 00       	mov    $0x0,%eax
  80155b:	eb 31                	jmp    80158e <dev_lookup+0x61>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  80155d:	40                   	inc    %eax
  80155e:	8b 14 85 48 2b 80 00 	mov    0x802b48(,%eax,4),%edx
  801565:	85 d2                	test   %edx,%edx
  801567:	75 e0                	jne    801549 <dev_lookup+0x1c>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801569:	a1 04 40 80 00       	mov    0x804004,%eax
  80156e:	8b 40 48             	mov    0x48(%eax),%eax
  801571:	83 ec 04             	sub    $0x4,%esp
  801574:	51                   	push   %ecx
  801575:	50                   	push   %eax
  801576:	68 c8 2a 80 00       	push   $0x802ac8
  80157b:	e8 c0 f1 ff ff       	call   800740 <cprintf>
	*dev = 0;
  801580:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_INVAL;
  801586:	83 c4 10             	add    $0x10,%esp
  801589:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  80158e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801591:	c9                   	leave  
  801592:	c3                   	ret    

00801593 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  801593:	55                   	push   %ebp
  801594:	89 e5                	mov    %esp,%ebp
  801596:	56                   	push   %esi
  801597:	53                   	push   %ebx
  801598:	83 ec 20             	sub    $0x20,%esp
  80159b:	8b 75 08             	mov    0x8(%ebp),%esi
  80159e:	8a 45 0c             	mov    0xc(%ebp),%al
  8015a1:	88 45 e7             	mov    %al,-0x19(%ebp)
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8015a4:	56                   	push   %esi
  8015a5:	e8 92 fe ff ff       	call   80143c <fd2num>
  8015aa:	8d 55 f4             	lea    -0xc(%ebp),%edx
  8015ad:	89 14 24             	mov    %edx,(%esp)
  8015b0:	50                   	push   %eax
  8015b1:	e8 21 ff ff ff       	call   8014d7 <fd_lookup>
  8015b6:	89 c3                	mov    %eax,%ebx
  8015b8:	83 c4 08             	add    $0x8,%esp
  8015bb:	85 c0                	test   %eax,%eax
  8015bd:	78 05                	js     8015c4 <fd_close+0x31>
	    || fd != fd2)
  8015bf:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8015c2:	74 0d                	je     8015d1 <fd_close+0x3e>
		return (must_exist ? r : 0);
  8015c4:	80 7d e7 00          	cmpb   $0x0,-0x19(%ebp)
  8015c8:	75 48                	jne    801612 <fd_close+0x7f>
  8015ca:	bb 00 00 00 00       	mov    $0x0,%ebx
  8015cf:	eb 41                	jmp    801612 <fd_close+0x7f>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8015d1:	83 ec 08             	sub    $0x8,%esp
  8015d4:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8015d7:	50                   	push   %eax
  8015d8:	ff 36                	pushl  (%esi)
  8015da:	e8 4e ff ff ff       	call   80152d <dev_lookup>
  8015df:	89 c3                	mov    %eax,%ebx
  8015e1:	83 c4 10             	add    $0x10,%esp
  8015e4:	85 c0                	test   %eax,%eax
  8015e6:	78 1c                	js     801604 <fd_close+0x71>
		if (dev->dev_close)
  8015e8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015eb:	8b 40 10             	mov    0x10(%eax),%eax
  8015ee:	85 c0                	test   %eax,%eax
  8015f0:	74 0d                	je     8015ff <fd_close+0x6c>
			r = (*dev->dev_close)(fd);
  8015f2:	83 ec 0c             	sub    $0xc,%esp
  8015f5:	56                   	push   %esi
  8015f6:	ff d0                	call   *%eax
  8015f8:	89 c3                	mov    %eax,%ebx
  8015fa:	83 c4 10             	add    $0x10,%esp
  8015fd:	eb 05                	jmp    801604 <fd_close+0x71>
		else
			r = 0;
  8015ff:	bb 00 00 00 00       	mov    $0x0,%ebx
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801604:	83 ec 08             	sub    $0x8,%esp
  801607:	56                   	push   %esi
  801608:	6a 00                	push   $0x0
  80160a:	e8 b3 fb ff ff       	call   8011c2 <sys_page_unmap>
	return r;
  80160f:	83 c4 10             	add    $0x10,%esp
}
  801612:	89 d8                	mov    %ebx,%eax
  801614:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801617:	5b                   	pop    %ebx
  801618:	5e                   	pop    %esi
  801619:	c9                   	leave  
  80161a:	c3                   	ret    

0080161b <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  80161b:	55                   	push   %ebp
  80161c:	89 e5                	mov    %esp,%ebp
  80161e:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801621:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801624:	50                   	push   %eax
  801625:	ff 75 08             	pushl  0x8(%ebp)
  801628:	e8 aa fe ff ff       	call   8014d7 <fd_lookup>
  80162d:	83 c4 08             	add    $0x8,%esp
  801630:	85 c0                	test   %eax,%eax
  801632:	78 10                	js     801644 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  801634:	83 ec 08             	sub    $0x8,%esp
  801637:	6a 01                	push   $0x1
  801639:	ff 75 f4             	pushl  -0xc(%ebp)
  80163c:	e8 52 ff ff ff       	call   801593 <fd_close>
  801641:	83 c4 10             	add    $0x10,%esp
}
  801644:	c9                   	leave  
  801645:	c3                   	ret    

00801646 <close_all>:

void
close_all(void)
{
  801646:	55                   	push   %ebp
  801647:	89 e5                	mov    %esp,%ebp
  801649:	53                   	push   %ebx
  80164a:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  80164d:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801652:	83 ec 0c             	sub    $0xc,%esp
  801655:	53                   	push   %ebx
  801656:	e8 c0 ff ff ff       	call   80161b <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  80165b:	43                   	inc    %ebx
  80165c:	83 c4 10             	add    $0x10,%esp
  80165f:	83 fb 20             	cmp    $0x20,%ebx
  801662:	75 ee                	jne    801652 <close_all+0xc>
		close(i);
}
  801664:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801667:	c9                   	leave  
  801668:	c3                   	ret    

00801669 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801669:	55                   	push   %ebp
  80166a:	89 e5                	mov    %esp,%ebp
  80166c:	57                   	push   %edi
  80166d:	56                   	push   %esi
  80166e:	53                   	push   %ebx
  80166f:	83 ec 2c             	sub    $0x2c,%esp
  801672:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801675:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801678:	50                   	push   %eax
  801679:	ff 75 08             	pushl  0x8(%ebp)
  80167c:	e8 56 fe ff ff       	call   8014d7 <fd_lookup>
  801681:	89 c3                	mov    %eax,%ebx
  801683:	83 c4 08             	add    $0x8,%esp
  801686:	85 c0                	test   %eax,%eax
  801688:	0f 88 c0 00 00 00    	js     80174e <dup+0xe5>
		return r;
	close(newfdnum);
  80168e:	83 ec 0c             	sub    $0xc,%esp
  801691:	57                   	push   %edi
  801692:	e8 84 ff ff ff       	call   80161b <close>

	newfd = INDEX2FD(newfdnum);
  801697:	8d b7 00 00 0d 00    	lea    0xd0000(%edi),%esi
  80169d:	c1 e6 0c             	shl    $0xc,%esi
	ova = fd2data(oldfd);
  8016a0:	83 c4 04             	add    $0x4,%esp
  8016a3:	ff 75 e4             	pushl  -0x1c(%ebp)
  8016a6:	e8 a1 fd ff ff       	call   80144c <fd2data>
  8016ab:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  8016ad:	89 34 24             	mov    %esi,(%esp)
  8016b0:	e8 97 fd ff ff       	call   80144c <fd2data>
  8016b5:	83 c4 10             	add    $0x10,%esp
  8016b8:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8016bb:	89 d8                	mov    %ebx,%eax
  8016bd:	c1 e8 16             	shr    $0x16,%eax
  8016c0:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8016c7:	a8 01                	test   $0x1,%al
  8016c9:	74 37                	je     801702 <dup+0x99>
  8016cb:	89 d8                	mov    %ebx,%eax
  8016cd:	c1 e8 0c             	shr    $0xc,%eax
  8016d0:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8016d7:	f6 c2 01             	test   $0x1,%dl
  8016da:	74 26                	je     801702 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8016dc:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8016e3:	83 ec 0c             	sub    $0xc,%esp
  8016e6:	25 07 0e 00 00       	and    $0xe07,%eax
  8016eb:	50                   	push   %eax
  8016ec:	ff 75 d4             	pushl  -0x2c(%ebp)
  8016ef:	6a 00                	push   $0x0
  8016f1:	53                   	push   %ebx
  8016f2:	6a 00                	push   $0x0
  8016f4:	e8 a3 fa ff ff       	call   80119c <sys_page_map>
  8016f9:	89 c3                	mov    %eax,%ebx
  8016fb:	83 c4 20             	add    $0x20,%esp
  8016fe:	85 c0                	test   %eax,%eax
  801700:	78 2d                	js     80172f <dup+0xc6>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801702:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801705:	89 c2                	mov    %eax,%edx
  801707:	c1 ea 0c             	shr    $0xc,%edx
  80170a:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801711:	83 ec 0c             	sub    $0xc,%esp
  801714:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  80171a:	52                   	push   %edx
  80171b:	56                   	push   %esi
  80171c:	6a 00                	push   $0x0
  80171e:	50                   	push   %eax
  80171f:	6a 00                	push   $0x0
  801721:	e8 76 fa ff ff       	call   80119c <sys_page_map>
  801726:	89 c3                	mov    %eax,%ebx
  801728:	83 c4 20             	add    $0x20,%esp
  80172b:	85 c0                	test   %eax,%eax
  80172d:	79 1d                	jns    80174c <dup+0xe3>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  80172f:	83 ec 08             	sub    $0x8,%esp
  801732:	56                   	push   %esi
  801733:	6a 00                	push   $0x0
  801735:	e8 88 fa ff ff       	call   8011c2 <sys_page_unmap>
	sys_page_unmap(0, nva);
  80173a:	83 c4 08             	add    $0x8,%esp
  80173d:	ff 75 d4             	pushl  -0x2c(%ebp)
  801740:	6a 00                	push   $0x0
  801742:	e8 7b fa ff ff       	call   8011c2 <sys_page_unmap>
	return r;
  801747:	83 c4 10             	add    $0x10,%esp
  80174a:	eb 02                	jmp    80174e <dup+0xe5>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
		goto err;

	return newfdnum;
  80174c:	89 fb                	mov    %edi,%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  80174e:	89 d8                	mov    %ebx,%eax
  801750:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801753:	5b                   	pop    %ebx
  801754:	5e                   	pop    %esi
  801755:	5f                   	pop    %edi
  801756:	c9                   	leave  
  801757:	c3                   	ret    

00801758 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801758:	55                   	push   %ebp
  801759:	89 e5                	mov    %esp,%ebp
  80175b:	53                   	push   %ebx
  80175c:	83 ec 14             	sub    $0x14,%esp
  80175f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801762:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801765:	50                   	push   %eax
  801766:	53                   	push   %ebx
  801767:	e8 6b fd ff ff       	call   8014d7 <fd_lookup>
  80176c:	83 c4 08             	add    $0x8,%esp
  80176f:	85 c0                	test   %eax,%eax
  801771:	78 67                	js     8017da <read+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801773:	83 ec 08             	sub    $0x8,%esp
  801776:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801779:	50                   	push   %eax
  80177a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80177d:	ff 30                	pushl  (%eax)
  80177f:	e8 a9 fd ff ff       	call   80152d <dev_lookup>
  801784:	83 c4 10             	add    $0x10,%esp
  801787:	85 c0                	test   %eax,%eax
  801789:	78 4f                	js     8017da <read+0x82>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80178b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80178e:	8b 50 08             	mov    0x8(%eax),%edx
  801791:	83 e2 03             	and    $0x3,%edx
  801794:	83 fa 01             	cmp    $0x1,%edx
  801797:	75 21                	jne    8017ba <read+0x62>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801799:	a1 04 40 80 00       	mov    0x804004,%eax
  80179e:	8b 40 48             	mov    0x48(%eax),%eax
  8017a1:	83 ec 04             	sub    $0x4,%esp
  8017a4:	53                   	push   %ebx
  8017a5:	50                   	push   %eax
  8017a6:	68 0c 2b 80 00       	push   $0x802b0c
  8017ab:	e8 90 ef ff ff       	call   800740 <cprintf>
		return -E_INVAL;
  8017b0:	83 c4 10             	add    $0x10,%esp
  8017b3:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8017b8:	eb 20                	jmp    8017da <read+0x82>
	}
	if (!dev->dev_read)
  8017ba:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8017bd:	8b 52 08             	mov    0x8(%edx),%edx
  8017c0:	85 d2                	test   %edx,%edx
  8017c2:	74 11                	je     8017d5 <read+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8017c4:	83 ec 04             	sub    $0x4,%esp
  8017c7:	ff 75 10             	pushl  0x10(%ebp)
  8017ca:	ff 75 0c             	pushl  0xc(%ebp)
  8017cd:	50                   	push   %eax
  8017ce:	ff d2                	call   *%edx
  8017d0:	83 c4 10             	add    $0x10,%esp
  8017d3:	eb 05                	jmp    8017da <read+0x82>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8017d5:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_read)(fd, buf, n);
}
  8017da:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8017dd:	c9                   	leave  
  8017de:	c3                   	ret    

008017df <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8017df:	55                   	push   %ebp
  8017e0:	89 e5                	mov    %esp,%ebp
  8017e2:	57                   	push   %edi
  8017e3:	56                   	push   %esi
  8017e4:	53                   	push   %ebx
  8017e5:	83 ec 0c             	sub    $0xc,%esp
  8017e8:	8b 7d 08             	mov    0x8(%ebp),%edi
  8017eb:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8017ee:	85 f6                	test   %esi,%esi
  8017f0:	74 31                	je     801823 <readn+0x44>
  8017f2:	b8 00 00 00 00       	mov    $0x0,%eax
  8017f7:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = read(fdnum, (char*)buf + tot, n - tot);
  8017fc:	83 ec 04             	sub    $0x4,%esp
  8017ff:	89 f2                	mov    %esi,%edx
  801801:	29 c2                	sub    %eax,%edx
  801803:	52                   	push   %edx
  801804:	03 45 0c             	add    0xc(%ebp),%eax
  801807:	50                   	push   %eax
  801808:	57                   	push   %edi
  801809:	e8 4a ff ff ff       	call   801758 <read>
		if (m < 0)
  80180e:	83 c4 10             	add    $0x10,%esp
  801811:	85 c0                	test   %eax,%eax
  801813:	78 17                	js     80182c <readn+0x4d>
			return m;
		if (m == 0)
  801815:	85 c0                	test   %eax,%eax
  801817:	74 11                	je     80182a <readn+0x4b>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801819:	01 c3                	add    %eax,%ebx
  80181b:	89 d8                	mov    %ebx,%eax
  80181d:	39 f3                	cmp    %esi,%ebx
  80181f:	72 db                	jb     8017fc <readn+0x1d>
  801821:	eb 09                	jmp    80182c <readn+0x4d>
  801823:	b8 00 00 00 00       	mov    $0x0,%eax
  801828:	eb 02                	jmp    80182c <readn+0x4d>
		m = read(fdnum, (char*)buf + tot, n - tot);
		if (m < 0)
			return m;
		if (m == 0)
  80182a:	89 d8                	mov    %ebx,%eax
			break;
	}
	return tot;
}
  80182c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80182f:	5b                   	pop    %ebx
  801830:	5e                   	pop    %esi
  801831:	5f                   	pop    %edi
  801832:	c9                   	leave  
  801833:	c3                   	ret    

00801834 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801834:	55                   	push   %ebp
  801835:	89 e5                	mov    %esp,%ebp
  801837:	53                   	push   %ebx
  801838:	83 ec 14             	sub    $0x14,%esp
  80183b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80183e:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801841:	50                   	push   %eax
  801842:	53                   	push   %ebx
  801843:	e8 8f fc ff ff       	call   8014d7 <fd_lookup>
  801848:	83 c4 08             	add    $0x8,%esp
  80184b:	85 c0                	test   %eax,%eax
  80184d:	78 62                	js     8018b1 <write+0x7d>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80184f:	83 ec 08             	sub    $0x8,%esp
  801852:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801855:	50                   	push   %eax
  801856:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801859:	ff 30                	pushl  (%eax)
  80185b:	e8 cd fc ff ff       	call   80152d <dev_lookup>
  801860:	83 c4 10             	add    $0x10,%esp
  801863:	85 c0                	test   %eax,%eax
  801865:	78 4a                	js     8018b1 <write+0x7d>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801867:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80186a:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80186e:	75 21                	jne    801891 <write+0x5d>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801870:	a1 04 40 80 00       	mov    0x804004,%eax
  801875:	8b 40 48             	mov    0x48(%eax),%eax
  801878:	83 ec 04             	sub    $0x4,%esp
  80187b:	53                   	push   %ebx
  80187c:	50                   	push   %eax
  80187d:	68 28 2b 80 00       	push   $0x802b28
  801882:	e8 b9 ee ff ff       	call   800740 <cprintf>
		return -E_INVAL;
  801887:	83 c4 10             	add    $0x10,%esp
  80188a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80188f:	eb 20                	jmp    8018b1 <write+0x7d>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801891:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801894:	8b 52 0c             	mov    0xc(%edx),%edx
  801897:	85 d2                	test   %edx,%edx
  801899:	74 11                	je     8018ac <write+0x78>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80189b:	83 ec 04             	sub    $0x4,%esp
  80189e:	ff 75 10             	pushl  0x10(%ebp)
  8018a1:	ff 75 0c             	pushl  0xc(%ebp)
  8018a4:	50                   	push   %eax
  8018a5:	ff d2                	call   *%edx
  8018a7:	83 c4 10             	add    $0x10,%esp
  8018aa:	eb 05                	jmp    8018b1 <write+0x7d>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8018ac:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  8018b1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8018b4:	c9                   	leave  
  8018b5:	c3                   	ret    

008018b6 <seek>:

int
seek(int fdnum, off_t offset)
{
  8018b6:	55                   	push   %ebp
  8018b7:	89 e5                	mov    %esp,%ebp
  8018b9:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8018bc:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8018bf:	50                   	push   %eax
  8018c0:	ff 75 08             	pushl  0x8(%ebp)
  8018c3:	e8 0f fc ff ff       	call   8014d7 <fd_lookup>
  8018c8:	83 c4 08             	add    $0x8,%esp
  8018cb:	85 c0                	test   %eax,%eax
  8018cd:	78 0e                	js     8018dd <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8018cf:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8018d2:	8b 55 0c             	mov    0xc(%ebp),%edx
  8018d5:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8018d8:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8018dd:	c9                   	leave  
  8018de:	c3                   	ret    

008018df <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8018df:	55                   	push   %ebp
  8018e0:	89 e5                	mov    %esp,%ebp
  8018e2:	53                   	push   %ebx
  8018e3:	83 ec 14             	sub    $0x14,%esp
  8018e6:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8018e9:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8018ec:	50                   	push   %eax
  8018ed:	53                   	push   %ebx
  8018ee:	e8 e4 fb ff ff       	call   8014d7 <fd_lookup>
  8018f3:	83 c4 08             	add    $0x8,%esp
  8018f6:	85 c0                	test   %eax,%eax
  8018f8:	78 5f                	js     801959 <ftruncate+0x7a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8018fa:	83 ec 08             	sub    $0x8,%esp
  8018fd:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801900:	50                   	push   %eax
  801901:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801904:	ff 30                	pushl  (%eax)
  801906:	e8 22 fc ff ff       	call   80152d <dev_lookup>
  80190b:	83 c4 10             	add    $0x10,%esp
  80190e:	85 c0                	test   %eax,%eax
  801910:	78 47                	js     801959 <ftruncate+0x7a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801912:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801915:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801919:	75 21                	jne    80193c <ftruncate+0x5d>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  80191b:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801920:	8b 40 48             	mov    0x48(%eax),%eax
  801923:	83 ec 04             	sub    $0x4,%esp
  801926:	53                   	push   %ebx
  801927:	50                   	push   %eax
  801928:	68 e8 2a 80 00       	push   $0x802ae8
  80192d:	e8 0e ee ff ff       	call   800740 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801932:	83 c4 10             	add    $0x10,%esp
  801935:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80193a:	eb 1d                	jmp    801959 <ftruncate+0x7a>
	}
	if (!dev->dev_trunc)
  80193c:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80193f:	8b 52 18             	mov    0x18(%edx),%edx
  801942:	85 d2                	test   %edx,%edx
  801944:	74 0e                	je     801954 <ftruncate+0x75>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801946:	83 ec 08             	sub    $0x8,%esp
  801949:	ff 75 0c             	pushl  0xc(%ebp)
  80194c:	50                   	push   %eax
  80194d:	ff d2                	call   *%edx
  80194f:	83 c4 10             	add    $0x10,%esp
  801952:	eb 05                	jmp    801959 <ftruncate+0x7a>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801954:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  801959:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80195c:	c9                   	leave  
  80195d:	c3                   	ret    

0080195e <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  80195e:	55                   	push   %ebp
  80195f:	89 e5                	mov    %esp,%ebp
  801961:	53                   	push   %ebx
  801962:	83 ec 14             	sub    $0x14,%esp
  801965:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801968:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80196b:	50                   	push   %eax
  80196c:	ff 75 08             	pushl  0x8(%ebp)
  80196f:	e8 63 fb ff ff       	call   8014d7 <fd_lookup>
  801974:	83 c4 08             	add    $0x8,%esp
  801977:	85 c0                	test   %eax,%eax
  801979:	78 52                	js     8019cd <fstat+0x6f>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80197b:	83 ec 08             	sub    $0x8,%esp
  80197e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801981:	50                   	push   %eax
  801982:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801985:	ff 30                	pushl  (%eax)
  801987:	e8 a1 fb ff ff       	call   80152d <dev_lookup>
  80198c:	83 c4 10             	add    $0x10,%esp
  80198f:	85 c0                	test   %eax,%eax
  801991:	78 3a                	js     8019cd <fstat+0x6f>
		return r;
	if (!dev->dev_stat)
  801993:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801996:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  80199a:	74 2c                	je     8019c8 <fstat+0x6a>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  80199c:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  80199f:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8019a6:	00 00 00 
	stat->st_isdir = 0;
  8019a9:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8019b0:	00 00 00 
	stat->st_dev = dev;
  8019b3:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8019b9:	83 ec 08             	sub    $0x8,%esp
  8019bc:	53                   	push   %ebx
  8019bd:	ff 75 f0             	pushl  -0x10(%ebp)
  8019c0:	ff 50 14             	call   *0x14(%eax)
  8019c3:	83 c4 10             	add    $0x10,%esp
  8019c6:	eb 05                	jmp    8019cd <fstat+0x6f>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8019c8:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8019cd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8019d0:	c9                   	leave  
  8019d1:	c3                   	ret    

008019d2 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8019d2:	55                   	push   %ebp
  8019d3:	89 e5                	mov    %esp,%ebp
  8019d5:	56                   	push   %esi
  8019d6:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8019d7:	83 ec 08             	sub    $0x8,%esp
  8019da:	6a 00                	push   $0x0
  8019dc:	ff 75 08             	pushl  0x8(%ebp)
  8019df:	e8 78 01 00 00       	call   801b5c <open>
  8019e4:	89 c3                	mov    %eax,%ebx
  8019e6:	83 c4 10             	add    $0x10,%esp
  8019e9:	85 c0                	test   %eax,%eax
  8019eb:	78 1b                	js     801a08 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8019ed:	83 ec 08             	sub    $0x8,%esp
  8019f0:	ff 75 0c             	pushl  0xc(%ebp)
  8019f3:	50                   	push   %eax
  8019f4:	e8 65 ff ff ff       	call   80195e <fstat>
  8019f9:	89 c6                	mov    %eax,%esi
	close(fd);
  8019fb:	89 1c 24             	mov    %ebx,(%esp)
  8019fe:	e8 18 fc ff ff       	call   80161b <close>
	return r;
  801a03:	83 c4 10             	add    $0x10,%esp
  801a06:	89 f3                	mov    %esi,%ebx
}
  801a08:	89 d8                	mov    %ebx,%eax
  801a0a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a0d:	5b                   	pop    %ebx
  801a0e:	5e                   	pop    %esi
  801a0f:	c9                   	leave  
  801a10:	c3                   	ret    
  801a11:	00 00                	add    %al,(%eax)
	...

00801a14 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801a14:	55                   	push   %ebp
  801a15:	89 e5                	mov    %esp,%ebp
  801a17:	56                   	push   %esi
  801a18:	53                   	push   %ebx
  801a19:	89 c3                	mov    %eax,%ebx
  801a1b:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  801a1d:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801a24:	75 12                	jne    801a38 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801a26:	83 ec 0c             	sub    $0xc,%esp
  801a29:	6a 01                	push   $0x1
  801a2b:	e8 be f9 ff ff       	call   8013ee <ipc_find_env>
  801a30:	a3 00 40 80 00       	mov    %eax,0x804000
  801a35:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801a38:	6a 07                	push   $0x7
  801a3a:	68 00 50 80 00       	push   $0x805000
  801a3f:	53                   	push   %ebx
  801a40:	ff 35 00 40 80 00    	pushl  0x804000
  801a46:	e8 4e f9 ff ff       	call   801399 <ipc_send>
	
	return ipc_recv(NULL, dstva, NULL);
  801a4b:	83 c4 0c             	add    $0xc,%esp
  801a4e:	6a 00                	push   $0x0
  801a50:	56                   	push   %esi
  801a51:	6a 00                	push   $0x0
  801a53:	e8 cc f8 ff ff       	call   801324 <ipc_recv>
}
  801a58:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a5b:	5b                   	pop    %ebx
  801a5c:	5e                   	pop    %esi
  801a5d:	c9                   	leave  
  801a5e:	c3                   	ret    

00801a5f <devfile_stat>:
}


static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801a5f:	55                   	push   %ebp
  801a60:	89 e5                	mov    %esp,%ebp
  801a62:	53                   	push   %ebx
  801a63:	83 ec 04             	sub    $0x4,%esp
  801a66:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801a69:	8b 45 08             	mov    0x8(%ebp),%eax
  801a6c:	8b 40 0c             	mov    0xc(%eax),%eax
  801a6f:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0) {
  801a74:	ba 00 00 00 00       	mov    $0x0,%edx
  801a79:	b8 05 00 00 00       	mov    $0x5,%eax
  801a7e:	e8 91 ff ff ff       	call   801a14 <fsipc>
  801a83:	85 c0                	test   %eax,%eax
  801a85:	78 2c                	js     801ab3 <devfile_stat+0x54>
		return r;
	}
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801a87:	83 ec 08             	sub    $0x8,%esp
  801a8a:	68 00 50 80 00       	push   $0x805000
  801a8f:	53                   	push   %ebx
  801a90:	e8 61 f2 ff ff       	call   800cf6 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801a95:	a1 80 50 80 00       	mov    0x805080,%eax
  801a9a:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801aa0:	a1 84 50 80 00       	mov    0x805084,%eax
  801aa5:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801aab:	83 c4 10             	add    $0x10,%esp
  801aae:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801ab3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801ab6:	c9                   	leave  
  801ab7:	c3                   	ret    

00801ab8 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801ab8:	55                   	push   %ebp
  801ab9:	89 e5                	mov    %esp,%ebp
  801abb:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801abe:	8b 45 08             	mov    0x8(%ebp),%eax
  801ac1:	8b 40 0c             	mov    0xc(%eax),%eax
  801ac4:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801ac9:	ba 00 00 00 00       	mov    $0x0,%edx
  801ace:	b8 06 00 00 00       	mov    $0x6,%eax
  801ad3:	e8 3c ff ff ff       	call   801a14 <fsipc>
}
  801ad8:	c9                   	leave  
  801ad9:	c3                   	ret    

00801ada <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801ada:	55                   	push   %ebp
  801adb:	89 e5                	mov    %esp,%ebp
  801add:	56                   	push   %esi
  801ade:	53                   	push   %ebx
  801adf:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801ae2:	8b 45 08             	mov    0x8(%ebp),%eax
  801ae5:	8b 40 0c             	mov    0xc(%eax),%eax
  801ae8:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801aed:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801af3:	ba 00 00 00 00       	mov    $0x0,%edx
  801af8:	b8 03 00 00 00       	mov    $0x3,%eax
  801afd:	e8 12 ff ff ff       	call   801a14 <fsipc>
  801b02:	89 c3                	mov    %eax,%ebx
  801b04:	85 c0                	test   %eax,%eax
  801b06:	78 4b                	js     801b53 <devfile_read+0x79>
		return r;
	assert(r <= n);
  801b08:	39 c6                	cmp    %eax,%esi
  801b0a:	73 16                	jae    801b22 <devfile_read+0x48>
  801b0c:	68 58 2b 80 00       	push   $0x802b58
  801b11:	68 5f 2b 80 00       	push   $0x802b5f
  801b16:	6a 7d                	push   $0x7d
  801b18:	68 74 2b 80 00       	push   $0x802b74
  801b1d:	e8 46 eb ff ff       	call   800668 <_panic>
	assert(r <= PGSIZE);
  801b22:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801b27:	7e 16                	jle    801b3f <devfile_read+0x65>
  801b29:	68 7f 2b 80 00       	push   $0x802b7f
  801b2e:	68 5f 2b 80 00       	push   $0x802b5f
  801b33:	6a 7e                	push   $0x7e
  801b35:	68 74 2b 80 00       	push   $0x802b74
  801b3a:	e8 29 eb ff ff       	call   800668 <_panic>
	memmove(buf, &fsipcbuf, r);
  801b3f:	83 ec 04             	sub    $0x4,%esp
  801b42:	50                   	push   %eax
  801b43:	68 00 50 80 00       	push   $0x805000
  801b48:	ff 75 0c             	pushl  0xc(%ebp)
  801b4b:	e8 67 f3 ff ff       	call   800eb7 <memmove>
	return r;
  801b50:	83 c4 10             	add    $0x10,%esp
}
  801b53:	89 d8                	mov    %ebx,%eax
  801b55:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801b58:	5b                   	pop    %ebx
  801b59:	5e                   	pop    %esi
  801b5a:	c9                   	leave  
  801b5b:	c3                   	ret    

00801b5c <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801b5c:	55                   	push   %ebp
  801b5d:	89 e5                	mov    %esp,%ebp
  801b5f:	56                   	push   %esi
  801b60:	53                   	push   %ebx
  801b61:	83 ec 1c             	sub    $0x1c,%esp
  801b64:	8b 75 08             	mov    0x8(%ebp),%esi
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801b67:	56                   	push   %esi
  801b68:	e8 37 f1 ff ff       	call   800ca4 <strlen>
  801b6d:	83 c4 10             	add    $0x10,%esp
  801b70:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801b75:	7f 65                	jg     801bdc <open+0x80>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801b77:	83 ec 0c             	sub    $0xc,%esp
  801b7a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801b7d:	50                   	push   %eax
  801b7e:	e8 e1 f8 ff ff       	call   801464 <fd_alloc>
  801b83:	89 c3                	mov    %eax,%ebx
  801b85:	83 c4 10             	add    $0x10,%esp
  801b88:	85 c0                	test   %eax,%eax
  801b8a:	78 55                	js     801be1 <open+0x85>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801b8c:	83 ec 08             	sub    $0x8,%esp
  801b8f:	56                   	push   %esi
  801b90:	68 00 50 80 00       	push   $0x805000
  801b95:	e8 5c f1 ff ff       	call   800cf6 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801b9a:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b9d:	a3 00 54 80 00       	mov    %eax,0x805400



	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801ba2:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801ba5:	b8 01 00 00 00       	mov    $0x1,%eax
  801baa:	e8 65 fe ff ff       	call   801a14 <fsipc>
  801baf:	89 c3                	mov    %eax,%ebx
  801bb1:	83 c4 10             	add    $0x10,%esp
  801bb4:	85 c0                	test   %eax,%eax
  801bb6:	79 12                	jns    801bca <open+0x6e>
		fd_close(fd, 0);
  801bb8:	83 ec 08             	sub    $0x8,%esp
  801bbb:	6a 00                	push   $0x0
  801bbd:	ff 75 f4             	pushl  -0xc(%ebp)
  801bc0:	e8 ce f9 ff ff       	call   801593 <fd_close>
		return r;
  801bc5:	83 c4 10             	add    $0x10,%esp
  801bc8:	eb 17                	jmp    801be1 <open+0x85>
	}

	return fd2num(fd);
  801bca:	83 ec 0c             	sub    $0xc,%esp
  801bcd:	ff 75 f4             	pushl  -0xc(%ebp)
  801bd0:	e8 67 f8 ff ff       	call   80143c <fd2num>
  801bd5:	89 c3                	mov    %eax,%ebx
  801bd7:	83 c4 10             	add    $0x10,%esp
  801bda:	eb 05                	jmp    801be1 <open+0x85>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801bdc:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801be1:	89 d8                	mov    %ebx,%eax
  801be3:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801be6:	5b                   	pop    %ebx
  801be7:	5e                   	pop    %esi
  801be8:	c9                   	leave  
  801be9:	c3                   	ret    
	...

00801bec <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801bec:	55                   	push   %ebp
  801bed:	89 e5                	mov    %esp,%ebp
  801bef:	56                   	push   %esi
  801bf0:	53                   	push   %ebx
  801bf1:	8b 75 0c             	mov    0xc(%ebp),%esi
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801bf4:	83 ec 0c             	sub    $0xc,%esp
  801bf7:	ff 75 08             	pushl  0x8(%ebp)
  801bfa:	e8 4d f8 ff ff       	call   80144c <fd2data>
  801bff:	89 c3                	mov    %eax,%ebx
	strcpy(stat->st_name, "<pipe>");
  801c01:	83 c4 08             	add    $0x8,%esp
  801c04:	68 8b 2b 80 00       	push   $0x802b8b
  801c09:	56                   	push   %esi
  801c0a:	e8 e7 f0 ff ff       	call   800cf6 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801c0f:	8b 43 04             	mov    0x4(%ebx),%eax
  801c12:	2b 03                	sub    (%ebx),%eax
  801c14:	89 86 80 00 00 00    	mov    %eax,0x80(%esi)
	stat->st_isdir = 0;
  801c1a:	c7 86 84 00 00 00 00 	movl   $0x0,0x84(%esi)
  801c21:	00 00 00 
	stat->st_dev = &devpipe;
  801c24:	c7 86 88 00 00 00 24 	movl   $0x803024,0x88(%esi)
  801c2b:	30 80 00 
	return 0;
}
  801c2e:	b8 00 00 00 00       	mov    $0x0,%eax
  801c33:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801c36:	5b                   	pop    %ebx
  801c37:	5e                   	pop    %esi
  801c38:	c9                   	leave  
  801c39:	c3                   	ret    

00801c3a <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801c3a:	55                   	push   %ebp
  801c3b:	89 e5                	mov    %esp,%ebp
  801c3d:	53                   	push   %ebx
  801c3e:	83 ec 0c             	sub    $0xc,%esp
  801c41:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801c44:	53                   	push   %ebx
  801c45:	6a 00                	push   $0x0
  801c47:	e8 76 f5 ff ff       	call   8011c2 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801c4c:	89 1c 24             	mov    %ebx,(%esp)
  801c4f:	e8 f8 f7 ff ff       	call   80144c <fd2data>
  801c54:	83 c4 08             	add    $0x8,%esp
  801c57:	50                   	push   %eax
  801c58:	6a 00                	push   $0x0
  801c5a:	e8 63 f5 ff ff       	call   8011c2 <sys_page_unmap>
}
  801c5f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801c62:	c9                   	leave  
  801c63:	c3                   	ret    

00801c64 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801c64:	55                   	push   %ebp
  801c65:	89 e5                	mov    %esp,%ebp
  801c67:	57                   	push   %edi
  801c68:	56                   	push   %esi
  801c69:	53                   	push   %ebx
  801c6a:	83 ec 1c             	sub    $0x1c,%esp
  801c6d:	89 c7                	mov    %eax,%edi
  801c6f:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801c72:	a1 04 40 80 00       	mov    0x804004,%eax
  801c77:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801c7a:	83 ec 0c             	sub    $0xc,%esp
  801c7d:	57                   	push   %edi
  801c7e:	e8 6d 04 00 00       	call   8020f0 <pageref>
  801c83:	89 c6                	mov    %eax,%esi
  801c85:	83 c4 04             	add    $0x4,%esp
  801c88:	ff 75 e4             	pushl  -0x1c(%ebp)
  801c8b:	e8 60 04 00 00       	call   8020f0 <pageref>
  801c90:	83 c4 10             	add    $0x10,%esp
  801c93:	39 c6                	cmp    %eax,%esi
  801c95:	0f 94 c0             	sete   %al
  801c98:	0f b6 c0             	movzbl %al,%eax
		nn = thisenv->env_runs;
  801c9b:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801ca1:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801ca4:	39 cb                	cmp    %ecx,%ebx
  801ca6:	75 08                	jne    801cb0 <_pipeisclosed+0x4c>
			return ret;
		if (n != nn && ret == 1)
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
	}
}
  801ca8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801cab:	5b                   	pop    %ebx
  801cac:	5e                   	pop    %esi
  801cad:	5f                   	pop    %edi
  801cae:	c9                   	leave  
  801caf:	c3                   	ret    
		n = thisenv->env_runs;
		ret = pageref(fd) == pageref(p);
		nn = thisenv->env_runs;
		if (n == nn)
			return ret;
		if (n != nn && ret == 1)
  801cb0:	83 f8 01             	cmp    $0x1,%eax
  801cb3:	75 bd                	jne    801c72 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801cb5:	8b 42 58             	mov    0x58(%edx),%eax
  801cb8:	6a 01                	push   $0x1
  801cba:	50                   	push   %eax
  801cbb:	53                   	push   %ebx
  801cbc:	68 92 2b 80 00       	push   $0x802b92
  801cc1:	e8 7a ea ff ff       	call   800740 <cprintf>
  801cc6:	83 c4 10             	add    $0x10,%esp
  801cc9:	eb a7                	jmp    801c72 <_pipeisclosed+0xe>

00801ccb <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801ccb:	55                   	push   %ebp
  801ccc:	89 e5                	mov    %esp,%ebp
  801cce:	57                   	push   %edi
  801ccf:	56                   	push   %esi
  801cd0:	53                   	push   %ebx
  801cd1:	83 ec 28             	sub    $0x28,%esp
  801cd4:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801cd7:	56                   	push   %esi
  801cd8:	e8 6f f7 ff ff       	call   80144c <fd2data>
  801cdd:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801cdf:	83 c4 10             	add    $0x10,%esp
  801ce2:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801ce6:	75 4a                	jne    801d32 <devpipe_write+0x67>
  801ce8:	bf 00 00 00 00       	mov    $0x0,%edi
  801ced:	eb 56                	jmp    801d45 <devpipe_write+0x7a>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801cef:	89 da                	mov    %ebx,%edx
  801cf1:	89 f0                	mov    %esi,%eax
  801cf3:	e8 6c ff ff ff       	call   801c64 <_pipeisclosed>
  801cf8:	85 c0                	test   %eax,%eax
  801cfa:	75 4d                	jne    801d49 <devpipe_write+0x7e>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801cfc:	e8 50 f4 ff ff       	call   801151 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801d01:	8b 43 04             	mov    0x4(%ebx),%eax
  801d04:	8b 13                	mov    (%ebx),%edx
  801d06:	83 c2 20             	add    $0x20,%edx
  801d09:	39 d0                	cmp    %edx,%eax
  801d0b:	73 e2                	jae    801cef <devpipe_write+0x24>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801d0d:	89 c2                	mov    %eax,%edx
  801d0f:	81 e2 1f 00 00 80    	and    $0x8000001f,%edx
  801d15:	79 05                	jns    801d1c <devpipe_write+0x51>
  801d17:	4a                   	dec    %edx
  801d18:	83 ca e0             	or     $0xffffffe0,%edx
  801d1b:	42                   	inc    %edx
  801d1c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801d1f:	8a 0c 39             	mov    (%ecx,%edi,1),%cl
  801d22:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801d26:	40                   	inc    %eax
  801d27:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801d2a:	47                   	inc    %edi
  801d2b:	39 7d 10             	cmp    %edi,0x10(%ebp)
  801d2e:	77 07                	ja     801d37 <devpipe_write+0x6c>
  801d30:	eb 13                	jmp    801d45 <devpipe_write+0x7a>
  801d32:	bf 00 00 00 00       	mov    $0x0,%edi
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801d37:	8b 43 04             	mov    0x4(%ebx),%eax
  801d3a:	8b 13                	mov    (%ebx),%edx
  801d3c:	83 c2 20             	add    $0x20,%edx
  801d3f:	39 d0                	cmp    %edx,%eax
  801d41:	73 ac                	jae    801cef <devpipe_write+0x24>
  801d43:	eb c8                	jmp    801d0d <devpipe_write+0x42>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801d45:	89 f8                	mov    %edi,%eax
  801d47:	eb 05                	jmp    801d4e <devpipe_write+0x83>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801d49:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801d4e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801d51:	5b                   	pop    %ebx
  801d52:	5e                   	pop    %esi
  801d53:	5f                   	pop    %edi
  801d54:	c9                   	leave  
  801d55:	c3                   	ret    

00801d56 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801d56:	55                   	push   %ebp
  801d57:	89 e5                	mov    %esp,%ebp
  801d59:	57                   	push   %edi
  801d5a:	56                   	push   %esi
  801d5b:	53                   	push   %ebx
  801d5c:	83 ec 18             	sub    $0x18,%esp
  801d5f:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801d62:	57                   	push   %edi
  801d63:	e8 e4 f6 ff ff       	call   80144c <fd2data>
  801d68:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801d6a:	83 c4 10             	add    $0x10,%esp
  801d6d:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801d71:	75 44                	jne    801db7 <devpipe_read+0x61>
  801d73:	be 00 00 00 00       	mov    $0x0,%esi
  801d78:	eb 4f                	jmp    801dc9 <devpipe_read+0x73>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
				return i;
  801d7a:	89 f0                	mov    %esi,%eax
  801d7c:	eb 54                	jmp    801dd2 <devpipe_read+0x7c>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801d7e:	89 da                	mov    %ebx,%edx
  801d80:	89 f8                	mov    %edi,%eax
  801d82:	e8 dd fe ff ff       	call   801c64 <_pipeisclosed>
  801d87:	85 c0                	test   %eax,%eax
  801d89:	75 42                	jne    801dcd <devpipe_read+0x77>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801d8b:	e8 c1 f3 ff ff       	call   801151 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801d90:	8b 03                	mov    (%ebx),%eax
  801d92:	3b 43 04             	cmp    0x4(%ebx),%eax
  801d95:	74 e7                	je     801d7e <devpipe_read+0x28>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801d97:	25 1f 00 00 80       	and    $0x8000001f,%eax
  801d9c:	79 05                	jns    801da3 <devpipe_read+0x4d>
  801d9e:	48                   	dec    %eax
  801d9f:	83 c8 e0             	or     $0xffffffe0,%eax
  801da2:	40                   	inc    %eax
  801da3:	8a 44 03 08          	mov    0x8(%ebx,%eax,1),%al
  801da7:	8b 55 0c             	mov    0xc(%ebp),%edx
  801daa:	88 04 32             	mov    %al,(%edx,%esi,1)
		p->p_rpos++;
  801dad:	ff 03                	incl   (%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801daf:	46                   	inc    %esi
  801db0:	39 75 10             	cmp    %esi,0x10(%ebp)
  801db3:	77 07                	ja     801dbc <devpipe_read+0x66>
  801db5:	eb 12                	jmp    801dc9 <devpipe_read+0x73>
  801db7:	be 00 00 00 00       	mov    $0x0,%esi
		while (p->p_rpos == p->p_wpos) {
  801dbc:	8b 03                	mov    (%ebx),%eax
  801dbe:	3b 43 04             	cmp    0x4(%ebx),%eax
  801dc1:	75 d4                	jne    801d97 <devpipe_read+0x41>
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801dc3:	85 f6                	test   %esi,%esi
  801dc5:	75 b3                	jne    801d7a <devpipe_read+0x24>
  801dc7:	eb b5                	jmp    801d7e <devpipe_read+0x28>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801dc9:	89 f0                	mov    %esi,%eax
  801dcb:	eb 05                	jmp    801dd2 <devpipe_read+0x7c>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801dcd:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801dd2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801dd5:	5b                   	pop    %ebx
  801dd6:	5e                   	pop    %esi
  801dd7:	5f                   	pop    %edi
  801dd8:	c9                   	leave  
  801dd9:	c3                   	ret    

00801dda <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801dda:	55                   	push   %ebp
  801ddb:	89 e5                	mov    %esp,%ebp
  801ddd:	57                   	push   %edi
  801dde:	56                   	push   %esi
  801ddf:	53                   	push   %ebx
  801de0:	83 ec 28             	sub    $0x28,%esp
  801de3:	8b 7d 08             	mov    0x8(%ebp),%edi
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801de6:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801de9:	50                   	push   %eax
  801dea:	e8 75 f6 ff ff       	call   801464 <fd_alloc>
  801def:	89 c3                	mov    %eax,%ebx
  801df1:	83 c4 10             	add    $0x10,%esp
  801df4:	85 c0                	test   %eax,%eax
  801df6:	0f 88 24 01 00 00    	js     801f20 <pipe+0x146>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801dfc:	83 ec 04             	sub    $0x4,%esp
  801dff:	68 07 04 00 00       	push   $0x407
  801e04:	ff 75 e4             	pushl  -0x1c(%ebp)
  801e07:	6a 00                	push   $0x0
  801e09:	e8 6a f3 ff ff       	call   801178 <sys_page_alloc>
  801e0e:	89 c3                	mov    %eax,%ebx
  801e10:	83 c4 10             	add    $0x10,%esp
  801e13:	85 c0                	test   %eax,%eax
  801e15:	0f 88 05 01 00 00    	js     801f20 <pipe+0x146>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801e1b:	83 ec 0c             	sub    $0xc,%esp
  801e1e:	8d 45 e0             	lea    -0x20(%ebp),%eax
  801e21:	50                   	push   %eax
  801e22:	e8 3d f6 ff ff       	call   801464 <fd_alloc>
  801e27:	89 c3                	mov    %eax,%ebx
  801e29:	83 c4 10             	add    $0x10,%esp
  801e2c:	85 c0                	test   %eax,%eax
  801e2e:	0f 88 dc 00 00 00    	js     801f10 <pipe+0x136>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801e34:	83 ec 04             	sub    $0x4,%esp
  801e37:	68 07 04 00 00       	push   $0x407
  801e3c:	ff 75 e0             	pushl  -0x20(%ebp)
  801e3f:	6a 00                	push   $0x0
  801e41:	e8 32 f3 ff ff       	call   801178 <sys_page_alloc>
  801e46:	89 c3                	mov    %eax,%ebx
  801e48:	83 c4 10             	add    $0x10,%esp
  801e4b:	85 c0                	test   %eax,%eax
  801e4d:	0f 88 bd 00 00 00    	js     801f10 <pipe+0x136>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801e53:	83 ec 0c             	sub    $0xc,%esp
  801e56:	ff 75 e4             	pushl  -0x1c(%ebp)
  801e59:	e8 ee f5 ff ff       	call   80144c <fd2data>
  801e5e:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801e60:	83 c4 0c             	add    $0xc,%esp
  801e63:	68 07 04 00 00       	push   $0x407
  801e68:	50                   	push   %eax
  801e69:	6a 00                	push   $0x0
  801e6b:	e8 08 f3 ff ff       	call   801178 <sys_page_alloc>
  801e70:	89 c3                	mov    %eax,%ebx
  801e72:	83 c4 10             	add    $0x10,%esp
  801e75:	85 c0                	test   %eax,%eax
  801e77:	0f 88 83 00 00 00    	js     801f00 <pipe+0x126>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801e7d:	83 ec 0c             	sub    $0xc,%esp
  801e80:	ff 75 e0             	pushl  -0x20(%ebp)
  801e83:	e8 c4 f5 ff ff       	call   80144c <fd2data>
  801e88:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801e8f:	50                   	push   %eax
  801e90:	6a 00                	push   $0x0
  801e92:	56                   	push   %esi
  801e93:	6a 00                	push   $0x0
  801e95:	e8 02 f3 ff ff       	call   80119c <sys_page_map>
  801e9a:	89 c3                	mov    %eax,%ebx
  801e9c:	83 c4 20             	add    $0x20,%esp
  801e9f:	85 c0                	test   %eax,%eax
  801ea1:	78 4f                	js     801ef2 <pipe+0x118>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801ea3:	8b 15 24 30 80 00    	mov    0x803024,%edx
  801ea9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801eac:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801eae:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801eb1:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801eb8:	8b 15 24 30 80 00    	mov    0x803024,%edx
  801ebe:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801ec1:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801ec3:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801ec6:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801ecd:	83 ec 0c             	sub    $0xc,%esp
  801ed0:	ff 75 e4             	pushl  -0x1c(%ebp)
  801ed3:	e8 64 f5 ff ff       	call   80143c <fd2num>
  801ed8:	89 07                	mov    %eax,(%edi)
	pfd[1] = fd2num(fd1);
  801eda:	83 c4 04             	add    $0x4,%esp
  801edd:	ff 75 e0             	pushl  -0x20(%ebp)
  801ee0:	e8 57 f5 ff ff       	call   80143c <fd2num>
  801ee5:	89 47 04             	mov    %eax,0x4(%edi)
	return 0;
  801ee8:	83 c4 10             	add    $0x10,%esp
  801eeb:	bb 00 00 00 00       	mov    $0x0,%ebx
  801ef0:	eb 2e                	jmp    801f20 <pipe+0x146>

    err3:
	sys_page_unmap(0, va);
  801ef2:	83 ec 08             	sub    $0x8,%esp
  801ef5:	56                   	push   %esi
  801ef6:	6a 00                	push   $0x0
  801ef8:	e8 c5 f2 ff ff       	call   8011c2 <sys_page_unmap>
  801efd:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801f00:	83 ec 08             	sub    $0x8,%esp
  801f03:	ff 75 e0             	pushl  -0x20(%ebp)
  801f06:	6a 00                	push   $0x0
  801f08:	e8 b5 f2 ff ff       	call   8011c2 <sys_page_unmap>
  801f0d:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801f10:	83 ec 08             	sub    $0x8,%esp
  801f13:	ff 75 e4             	pushl  -0x1c(%ebp)
  801f16:	6a 00                	push   $0x0
  801f18:	e8 a5 f2 ff ff       	call   8011c2 <sys_page_unmap>
  801f1d:	83 c4 10             	add    $0x10,%esp
    err:
	return r;
}
  801f20:	89 d8                	mov    %ebx,%eax
  801f22:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801f25:	5b                   	pop    %ebx
  801f26:	5e                   	pop    %esi
  801f27:	5f                   	pop    %edi
  801f28:	c9                   	leave  
  801f29:	c3                   	ret    

00801f2a <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801f2a:	55                   	push   %ebp
  801f2b:	89 e5                	mov    %esp,%ebp
  801f2d:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801f30:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801f33:	50                   	push   %eax
  801f34:	ff 75 08             	pushl  0x8(%ebp)
  801f37:	e8 9b f5 ff ff       	call   8014d7 <fd_lookup>
  801f3c:	83 c4 10             	add    $0x10,%esp
  801f3f:	85 c0                	test   %eax,%eax
  801f41:	78 18                	js     801f5b <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801f43:	83 ec 0c             	sub    $0xc,%esp
  801f46:	ff 75 f4             	pushl  -0xc(%ebp)
  801f49:	e8 fe f4 ff ff       	call   80144c <fd2data>
	return _pipeisclosed(fd, p);
  801f4e:	89 c2                	mov    %eax,%edx
  801f50:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f53:	e8 0c fd ff ff       	call   801c64 <_pipeisclosed>
  801f58:	83 c4 10             	add    $0x10,%esp
}
  801f5b:	c9                   	leave  
  801f5c:	c3                   	ret    
  801f5d:	00 00                	add    %al,(%eax)
	...

00801f60 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801f60:	55                   	push   %ebp
  801f61:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801f63:	b8 00 00 00 00       	mov    $0x0,%eax
  801f68:	c9                   	leave  
  801f69:	c3                   	ret    

00801f6a <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801f6a:	55                   	push   %ebp
  801f6b:	89 e5                	mov    %esp,%ebp
  801f6d:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801f70:	68 aa 2b 80 00       	push   $0x802baa
  801f75:	ff 75 0c             	pushl  0xc(%ebp)
  801f78:	e8 79 ed ff ff       	call   800cf6 <strcpy>
	return 0;
}
  801f7d:	b8 00 00 00 00       	mov    $0x0,%eax
  801f82:	c9                   	leave  
  801f83:	c3                   	ret    

00801f84 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801f84:	55                   	push   %ebp
  801f85:	89 e5                	mov    %esp,%ebp
  801f87:	57                   	push   %edi
  801f88:	56                   	push   %esi
  801f89:	53                   	push   %ebx
  801f8a:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801f90:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801f94:	74 45                	je     801fdb <devcons_write+0x57>
  801f96:	b8 00 00 00 00       	mov    $0x0,%eax
  801f9b:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801fa0:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801fa6:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801fa9:	29 c3                	sub    %eax,%ebx
		if (m > sizeof(buf) - 1)
  801fab:	83 fb 7f             	cmp    $0x7f,%ebx
  801fae:	76 05                	jbe    801fb5 <devcons_write+0x31>
			m = sizeof(buf) - 1;
  801fb0:	bb 7f 00 00 00       	mov    $0x7f,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  801fb5:	83 ec 04             	sub    $0x4,%esp
  801fb8:	53                   	push   %ebx
  801fb9:	03 45 0c             	add    0xc(%ebp),%eax
  801fbc:	50                   	push   %eax
  801fbd:	57                   	push   %edi
  801fbe:	e8 f4 ee ff ff       	call   800eb7 <memmove>
		sys_cputs(buf, m);
  801fc3:	83 c4 08             	add    $0x8,%esp
  801fc6:	53                   	push   %ebx
  801fc7:	57                   	push   %edi
  801fc8:	e8 f4 f0 ff ff       	call   8010c1 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801fcd:	01 de                	add    %ebx,%esi
  801fcf:	89 f0                	mov    %esi,%eax
  801fd1:	83 c4 10             	add    $0x10,%esp
  801fd4:	3b 75 10             	cmp    0x10(%ebp),%esi
  801fd7:	72 cd                	jb     801fa6 <devcons_write+0x22>
  801fd9:	eb 05                	jmp    801fe0 <devcons_write+0x5c>
  801fdb:	be 00 00 00 00       	mov    $0x0,%esi
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801fe0:	89 f0                	mov    %esi,%eax
  801fe2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801fe5:	5b                   	pop    %ebx
  801fe6:	5e                   	pop    %esi
  801fe7:	5f                   	pop    %edi
  801fe8:	c9                   	leave  
  801fe9:	c3                   	ret    

00801fea <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801fea:	55                   	push   %ebp
  801feb:	89 e5                	mov    %esp,%ebp
  801fed:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
  801ff0:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801ff4:	75 07                	jne    801ffd <devcons_read+0x13>
  801ff6:	eb 25                	jmp    80201d <devcons_read+0x33>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801ff8:	e8 54 f1 ff ff       	call   801151 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801ffd:	e8 e5 f0 ff ff       	call   8010e7 <sys_cgetc>
  802002:	85 c0                	test   %eax,%eax
  802004:	74 f2                	je     801ff8 <devcons_read+0xe>
  802006:	89 c2                	mov    %eax,%edx
		sys_yield();
	if (c < 0)
  802008:	85 c0                	test   %eax,%eax
  80200a:	78 1d                	js     802029 <devcons_read+0x3f>
		return c;
	if (c == 0x04)	// ctl-d is eof
  80200c:	83 f8 04             	cmp    $0x4,%eax
  80200f:	74 13                	je     802024 <devcons_read+0x3a>
		return 0;
	*(char*)vbuf = c;
  802011:	8b 45 0c             	mov    0xc(%ebp),%eax
  802014:	88 10                	mov    %dl,(%eax)
	return 1;
  802016:	b8 01 00 00 00       	mov    $0x1,%eax
  80201b:	eb 0c                	jmp    802029 <devcons_read+0x3f>
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
		return 0;
  80201d:	b8 00 00 00 00       	mov    $0x0,%eax
  802022:	eb 05                	jmp    802029 <devcons_read+0x3f>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  802024:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  802029:	c9                   	leave  
  80202a:	c3                   	ret    

0080202b <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  80202b:	55                   	push   %ebp
  80202c:	89 e5                	mov    %esp,%ebp
  80202e:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  802031:	8b 45 08             	mov    0x8(%ebp),%eax
  802034:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  802037:	6a 01                	push   $0x1
  802039:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80203c:	50                   	push   %eax
  80203d:	e8 7f f0 ff ff       	call   8010c1 <sys_cputs>
  802042:	83 c4 10             	add    $0x10,%esp
}
  802045:	c9                   	leave  
  802046:	c3                   	ret    

00802047 <getchar>:

int
getchar(void)
{
  802047:	55                   	push   %ebp
  802048:	89 e5                	mov    %esp,%ebp
  80204a:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  80204d:	6a 01                	push   $0x1
  80204f:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802052:	50                   	push   %eax
  802053:	6a 00                	push   $0x0
  802055:	e8 fe f6 ff ff       	call   801758 <read>
	if (r < 0)
  80205a:	83 c4 10             	add    $0x10,%esp
  80205d:	85 c0                	test   %eax,%eax
  80205f:	78 0f                	js     802070 <getchar+0x29>
		return r;
	if (r < 1)
  802061:	85 c0                	test   %eax,%eax
  802063:	7e 06                	jle    80206b <getchar+0x24>
		return -E_EOF;
	return c;
  802065:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  802069:	eb 05                	jmp    802070 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  80206b:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  802070:	c9                   	leave  
  802071:	c3                   	ret    

00802072 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  802072:	55                   	push   %ebp
  802073:	89 e5                	mov    %esp,%ebp
  802075:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802078:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80207b:	50                   	push   %eax
  80207c:	ff 75 08             	pushl  0x8(%ebp)
  80207f:	e8 53 f4 ff ff       	call   8014d7 <fd_lookup>
  802084:	83 c4 10             	add    $0x10,%esp
  802087:	85 c0                	test   %eax,%eax
  802089:	78 11                	js     80209c <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  80208b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80208e:	8b 15 40 30 80 00    	mov    0x803040,%edx
  802094:	39 10                	cmp    %edx,(%eax)
  802096:	0f 94 c0             	sete   %al
  802099:	0f b6 c0             	movzbl %al,%eax
}
  80209c:	c9                   	leave  
  80209d:	c3                   	ret    

0080209e <opencons>:

int
opencons(void)
{
  80209e:	55                   	push   %ebp
  80209f:	89 e5                	mov    %esp,%ebp
  8020a1:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8020a4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8020a7:	50                   	push   %eax
  8020a8:	e8 b7 f3 ff ff       	call   801464 <fd_alloc>
  8020ad:	83 c4 10             	add    $0x10,%esp
  8020b0:	85 c0                	test   %eax,%eax
  8020b2:	78 3a                	js     8020ee <opencons+0x50>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8020b4:	83 ec 04             	sub    $0x4,%esp
  8020b7:	68 07 04 00 00       	push   $0x407
  8020bc:	ff 75 f4             	pushl  -0xc(%ebp)
  8020bf:	6a 00                	push   $0x0
  8020c1:	e8 b2 f0 ff ff       	call   801178 <sys_page_alloc>
  8020c6:	83 c4 10             	add    $0x10,%esp
  8020c9:	85 c0                	test   %eax,%eax
  8020cb:	78 21                	js     8020ee <opencons+0x50>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  8020cd:	8b 15 40 30 80 00    	mov    0x803040,%edx
  8020d3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8020d6:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  8020d8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8020db:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  8020e2:	83 ec 0c             	sub    $0xc,%esp
  8020e5:	50                   	push   %eax
  8020e6:	e8 51 f3 ff ff       	call   80143c <fd2num>
  8020eb:	83 c4 10             	add    $0x10,%esp
}
  8020ee:	c9                   	leave  
  8020ef:	c3                   	ret    

008020f0 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  8020f0:	55                   	push   %ebp
  8020f1:	89 e5                	mov    %esp,%ebp
  8020f3:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8020f6:	89 c2                	mov    %eax,%edx
  8020f8:	c1 ea 16             	shr    $0x16,%edx
  8020fb:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  802102:	f6 c2 01             	test   $0x1,%dl
  802105:	74 1e                	je     802125 <pageref+0x35>
		return 0;
	pte = uvpt[PGNUM(v)];
  802107:	c1 e8 0c             	shr    $0xc,%eax
  80210a:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  802111:	a8 01                	test   $0x1,%al
  802113:	74 17                	je     80212c <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802115:	c1 e8 0c             	shr    $0xc,%eax
  802118:	66 8b 04 c5 04 00 00 	mov    -0x10fffffc(,%eax,8),%ax
  80211f:	ef 
  802120:	0f b7 c0             	movzwl %ax,%eax
  802123:	eb 0c                	jmp    802131 <pageref+0x41>
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
		return 0;
  802125:	b8 00 00 00 00       	mov    $0x0,%eax
  80212a:	eb 05                	jmp    802131 <pageref+0x41>
	pte = uvpt[PGNUM(v)];
	if (!(pte & PTE_P))
		return 0;
  80212c:	b8 00 00 00 00       	mov    $0x0,%eax
	return pages[PGNUM(pte)].pp_ref;
}
  802131:	c9                   	leave  
  802132:	c3                   	ret    
	...

00802134 <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  802134:	55                   	push   %ebp
  802135:	89 e5                	mov    %esp,%ebp
  802137:	57                   	push   %edi
  802138:	56                   	push   %esi
  802139:	83 ec 10             	sub    $0x10,%esp
  80213c:	8b 7d 08             	mov    0x8(%ebp),%edi
  80213f:	8b 4d 10             	mov    0x10(%ebp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  802142:	89 7d f0             	mov    %edi,-0x10(%ebp)
  802145:	8b 75 0c             	mov    0xc(%ebp),%esi
  const DWunion dd = {.ll = d};
  802148:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  80214b:	8b 45 14             	mov    0x14(%ebp),%eax
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  80214e:	85 c0                	test   %eax,%eax
  802150:	75 2e                	jne    802180 <__udivdi3+0x4c>
    {
      if (d0 > n1)
  802152:	39 f1                	cmp    %esi,%ecx
  802154:	77 5a                	ja     8021b0 <__udivdi3+0x7c>
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  802156:	85 c9                	test   %ecx,%ecx
  802158:	75 0b                	jne    802165 <__udivdi3+0x31>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  80215a:	b8 01 00 00 00       	mov    $0x1,%eax
  80215f:	31 d2                	xor    %edx,%edx
  802161:	f7 f1                	div    %ecx
  802163:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  802165:	31 d2                	xor    %edx,%edx
  802167:	89 f0                	mov    %esi,%eax
  802169:	f7 f1                	div    %ecx
  80216b:	89 c6                	mov    %eax,%esi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  80216d:	89 f8                	mov    %edi,%eax
  80216f:	f7 f1                	div    %ecx
  802171:	89 c7                	mov    %eax,%edi
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
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  802180:	39 f0                	cmp    %esi,%eax
  802182:	77 1c                	ja     8021a0 <__udivdi3+0x6c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  802184:	0f bd f8             	bsr    %eax,%edi
	  if (bm == 0)
  802187:	83 f7 1f             	xor    $0x1f,%edi
  80218a:	75 3c                	jne    8021c8 <__udivdi3+0x94>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  80218c:	39 f0                	cmp    %esi,%eax
  80218e:	0f 82 90 00 00 00    	jb     802224 <__udivdi3+0xf0>
  802194:	8b 55 f0             	mov    -0x10(%ebp),%edx
  802197:	39 55 f4             	cmp    %edx,-0xc(%ebp)
  80219a:	0f 86 84 00 00 00    	jbe    802224 <__udivdi3+0xf0>
  8021a0:	31 f6                	xor    %esi,%esi
  8021a2:	31 ff                	xor    %edi,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  8021a4:	89 f8                	mov    %edi,%eax
  8021a6:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  8021a8:	83 c4 10             	add    $0x10,%esp
  8021ab:	5e                   	pop    %esi
  8021ac:	5f                   	pop    %edi
  8021ad:	c9                   	leave  
  8021ae:	c3                   	ret    
  8021af:	90                   	nop
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  8021b0:	89 f2                	mov    %esi,%edx
  8021b2:	89 f8                	mov    %edi,%eax
  8021b4:	f7 f1                	div    %ecx
  8021b6:	89 c7                	mov    %eax,%edi
  8021b8:	31 f6                	xor    %esi,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  8021ba:	89 f8                	mov    %edi,%eax
  8021bc:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  8021be:	83 c4 10             	add    $0x10,%esp
  8021c1:	5e                   	pop    %esi
  8021c2:	5f                   	pop    %edi
  8021c3:	c9                   	leave  
  8021c4:	c3                   	ret    
  8021c5:	8d 76 00             	lea    0x0(%esi),%esi
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  8021c8:	89 f9                	mov    %edi,%ecx
  8021ca:	d3 e0                	shl    %cl,%eax
  8021cc:	89 45 e8             	mov    %eax,-0x18(%ebp)
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  8021cf:	b8 20 00 00 00       	mov    $0x20,%eax
  8021d4:	29 f8                	sub    %edi,%eax

	      d1 = (d1 << bm) | (d0 >> b);
  8021d6:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8021d9:	88 c1                	mov    %al,%cl
  8021db:	d3 ea                	shr    %cl,%edx
  8021dd:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  8021e0:	09 ca                	or     %ecx,%edx
  8021e2:	89 55 ec             	mov    %edx,-0x14(%ebp)
	      d0 = d0 << bm;
  8021e5:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8021e8:	89 f9                	mov    %edi,%ecx
  8021ea:	d3 e2                	shl    %cl,%edx
  8021ec:	89 55 f4             	mov    %edx,-0xc(%ebp)
	      n2 = n1 >> b;
  8021ef:	89 f2                	mov    %esi,%edx
  8021f1:	88 c1                	mov    %al,%cl
  8021f3:	d3 ea                	shr    %cl,%edx
  8021f5:	89 55 e8             	mov    %edx,-0x18(%ebp)
	      n1 = (n1 << bm) | (n0 >> b);
  8021f8:	89 f2                	mov    %esi,%edx
  8021fa:	89 f9                	mov    %edi,%ecx
  8021fc:	d3 e2                	shl    %cl,%edx
  8021fe:	8b 75 f0             	mov    -0x10(%ebp),%esi
  802201:	88 c1                	mov    %al,%cl
  802203:	d3 ee                	shr    %cl,%esi
  802205:	09 d6                	or     %edx,%esi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  802207:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  80220a:	89 f0                	mov    %esi,%eax
  80220c:	89 ca                	mov    %ecx,%edx
  80220e:	f7 75 ec             	divl   -0x14(%ebp)
  802211:	89 d1                	mov    %edx,%ecx
  802213:	89 c6                	mov    %eax,%esi
	      umul_ppmm (m1, m0, q0, d0);
  802215:	f7 65 f4             	mull   -0xc(%ebp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  802218:	39 d1                	cmp    %edx,%ecx
  80221a:	72 28                	jb     802244 <__udivdi3+0x110>
  80221c:	74 1a                	je     802238 <__udivdi3+0x104>
  80221e:	89 f7                	mov    %esi,%edi
  802220:	31 f6                	xor    %esi,%esi
  802222:	eb 80                	jmp    8021a4 <__udivdi3+0x70>
	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  802224:	31 f6                	xor    %esi,%esi
  802226:	bf 01 00 00 00       	mov    $0x1,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  80222b:	89 f8                	mov    %edi,%eax
  80222d:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  80222f:	83 c4 10             	add    $0x10,%esp
  802232:	5e                   	pop    %esi
  802233:	5f                   	pop    %edi
  802234:	c9                   	leave  
  802235:	c3                   	ret    
  802236:	66 90                	xchg   %ax,%ax

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  802238:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80223b:	89 f9                	mov    %edi,%ecx
  80223d:	d3 e2                	shl    %cl,%edx

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  80223f:	39 c2                	cmp    %eax,%edx
  802241:	73 db                	jae    80221e <__udivdi3+0xea>
  802243:	90                   	nop
		{
		  q0--;
  802244:	8d 7e ff             	lea    -0x1(%esi),%edi
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  802247:	31 f6                	xor    %esi,%esi
  802249:	e9 56 ff ff ff       	jmp    8021a4 <__udivdi3+0x70>
	...

00802250 <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  802250:	55                   	push   %ebp
  802251:	89 e5                	mov    %esp,%ebp
  802253:	57                   	push   %edi
  802254:	56                   	push   %esi
  802255:	83 ec 20             	sub    $0x20,%esp
  802258:	8b 45 08             	mov    0x8(%ebp),%eax
  80225b:	8b 4d 10             	mov    0x10(%ebp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  80225e:	89 45 e8             	mov    %eax,-0x18(%ebp)
  802261:	8b 75 0c             	mov    0xc(%ebp),%esi
  const DWunion dd = {.ll = d};
  802264:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  802267:	8b 7d 14             	mov    0x14(%ebp),%edi
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  80226a:	89 45 f0             	mov    %eax,-0x10(%ebp)
  n1 = nn.s.high;
  80226d:	89 f2                	mov    %esi,%edx

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  80226f:	85 ff                	test   %edi,%edi
  802271:	75 15                	jne    802288 <__umoddi3+0x38>
    {
      if (d0 > n1)
  802273:	39 f1                	cmp    %esi,%ecx
  802275:	0f 86 99 00 00 00    	jbe    802314 <__umoddi3+0xc4>
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  80227b:	f7 f1                	div    %ecx

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
  80227d:	89 d0                	mov    %edx,%eax
  80227f:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  802281:	83 c4 20             	add    $0x20,%esp
  802284:	5e                   	pop    %esi
  802285:	5f                   	pop    %edi
  802286:	c9                   	leave  
  802287:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  802288:	39 f7                	cmp    %esi,%edi
  80228a:	0f 87 a4 00 00 00    	ja     802334 <__umoddi3+0xe4>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  802290:	0f bd c7             	bsr    %edi,%eax
	  if (bm == 0)
  802293:	83 f0 1f             	xor    $0x1f,%eax
  802296:	89 45 ec             	mov    %eax,-0x14(%ebp)
  802299:	0f 84 a1 00 00 00    	je     802340 <__umoddi3+0xf0>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  80229f:	89 f8                	mov    %edi,%eax
  8022a1:	8a 4d ec             	mov    -0x14(%ebp),%cl
  8022a4:	d3 e0                	shl    %cl,%eax
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  8022a6:	bf 20 00 00 00       	mov    $0x20,%edi
  8022ab:	2b 7d ec             	sub    -0x14(%ebp),%edi

	      d1 = (d1 << bm) | (d0 >> b);
  8022ae:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8022b1:	89 f9                	mov    %edi,%ecx
  8022b3:	d3 ea                	shr    %cl,%edx
  8022b5:	09 c2                	or     %eax,%edx
  8022b7:	89 55 f0             	mov    %edx,-0x10(%ebp)
	      d0 = d0 << bm;
  8022ba:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8022bd:	8a 4d ec             	mov    -0x14(%ebp),%cl
  8022c0:	d3 e0                	shl    %cl,%eax
  8022c2:	89 45 f4             	mov    %eax,-0xc(%ebp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  8022c5:	89 f2                	mov    %esi,%edx
  8022c7:	d3 e2                	shl    %cl,%edx
	      n0 = n0 << bm;
  8022c9:	8b 45 e8             	mov    -0x18(%ebp),%eax
  8022cc:	d3 e0                	shl    %cl,%eax
  8022ce:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  8022d1:	8b 45 e8             	mov    -0x18(%ebp),%eax
  8022d4:	89 f9                	mov    %edi,%ecx
  8022d6:	d3 e8                	shr    %cl,%eax
  8022d8:	09 d0                	or     %edx,%eax

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  8022da:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  8022dc:	89 f2                	mov    %esi,%edx
  8022de:	f7 75 f0             	divl   -0x10(%ebp)
  8022e1:	89 d6                	mov    %edx,%esi
	      umul_ppmm (m1, m0, q0, d0);
  8022e3:	f7 65 f4             	mull   -0xc(%ebp)
  8022e6:	89 55 e8             	mov    %edx,-0x18(%ebp)
  8022e9:	89 c1                	mov    %eax,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  8022eb:	39 d6                	cmp    %edx,%esi
  8022ed:	72 71                	jb     802360 <__umoddi3+0x110>
  8022ef:	74 7f                	je     802370 <__umoddi3+0x120>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  8022f1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8022f4:	29 c8                	sub    %ecx,%eax
  8022f6:	19 d6                	sbb    %edx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
  8022f8:	8a 4d ec             	mov    -0x14(%ebp),%cl
  8022fb:	d3 e8                	shr    %cl,%eax
  8022fd:	89 f2                	mov    %esi,%edx
  8022ff:	89 f9                	mov    %edi,%ecx
  802301:	d3 e2                	shl    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
  802303:	09 d0                	or     %edx,%eax
  802305:	89 f2                	mov    %esi,%edx
  802307:	8a 4d ec             	mov    -0x14(%ebp),%cl
  80230a:	d3 ea                	shr    %cl,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  80230c:	83 c4 20             	add    $0x20,%esp
  80230f:	5e                   	pop    %esi
  802310:	5f                   	pop    %edi
  802311:	c9                   	leave  
  802312:	c3                   	ret    
  802313:	90                   	nop
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  802314:	85 c9                	test   %ecx,%ecx
  802316:	75 0b                	jne    802323 <__umoddi3+0xd3>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  802318:	b8 01 00 00 00       	mov    $0x1,%eax
  80231d:	31 d2                	xor    %edx,%edx
  80231f:	f7 f1                	div    %ecx
  802321:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  802323:	89 f0                	mov    %esi,%eax
  802325:	31 d2                	xor    %edx,%edx
  802327:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  802329:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80232c:	f7 f1                	div    %ecx
  80232e:	e9 4a ff ff ff       	jmp    80227d <__umoddi3+0x2d>
  802333:	90                   	nop
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
  802334:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  802336:	83 c4 20             	add    $0x20,%esp
  802339:	5e                   	pop    %esi
  80233a:	5f                   	pop    %edi
  80233b:	c9                   	leave  
  80233c:	c3                   	ret    
  80233d:	8d 76 00             	lea    0x0(%esi),%esi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  802340:	39 f7                	cmp    %esi,%edi
  802342:	72 05                	jb     802349 <__umoddi3+0xf9>
  802344:	3b 4d f0             	cmp    -0x10(%ebp),%ecx
  802347:	77 0c                	ja     802355 <__umoddi3+0x105>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  802349:	89 f2                	mov    %esi,%edx
  80234b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80234e:	29 c8                	sub    %ecx,%eax
  802350:	19 fa                	sbb    %edi,%edx
  802352:	89 45 f0             	mov    %eax,-0x10(%ebp)

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
  802355:	8b 45 f0             	mov    -0x10(%ebp),%eax
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  802358:	83 c4 20             	add    $0x20,%esp
  80235b:	5e                   	pop    %esi
  80235c:	5f                   	pop    %edi
  80235d:	c9                   	leave  
  80235e:	c3                   	ret    
  80235f:	90                   	nop
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  802360:	8b 55 e8             	mov    -0x18(%ebp),%edx
  802363:	89 c1                	mov    %eax,%ecx
  802365:	2b 4d f4             	sub    -0xc(%ebp),%ecx
  802368:	1b 55 f0             	sbb    -0x10(%ebp),%edx
  80236b:	eb 84                	jmp    8022f1 <__umoddi3+0xa1>
  80236d:	8d 76 00             	lea    0x0(%esi),%esi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  802370:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  802373:	72 eb                	jb     802360 <__umoddi3+0x110>
  802375:	89 f2                	mov    %esi,%edx
  802377:	e9 75 ff ff ff       	jmp    8022f1 <__umoddi3+0xa1>
