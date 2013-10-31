
obj/user/faultregs.debug:     file format elf32-i386


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
  80002c:	e8 ef 04 00 00       	call   800520 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800034 <check_regs>:
static struct regs before, during, after;

static void
check_regs(struct regs* a, const char *an, struct regs* b, const char *bn,
	   const char *testname)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	57                   	push   %edi
  800038:	56                   	push   %esi
  800039:	53                   	push   %ebx
  80003a:	83 ec 0c             	sub    $0xc,%esp
  80003d:	89 c3                	mov    %eax,%ebx
  80003f:	89 ce                	mov    %ecx,%esi
	int mismatch = 0;

	cprintf("%-6s %-8s %-8s\n", "", an, bn);
  800041:	ff 75 08             	pushl  0x8(%ebp)
  800044:	52                   	push   %edx
  800045:	68 11 23 80 00       	push   $0x802311
  80004a:	68 e0 22 80 00       	push   $0x8022e0
  80004f:	e8 10 06 00 00       	call   800664 <cprintf>
			cprintf("MISMATCH\n");				\
			mismatch = 1;					\
		}							\
	} while (0)

	CHECK(edi, regs.reg_edi);
  800054:	ff 36                	pushl  (%esi)
  800056:	ff 33                	pushl  (%ebx)
  800058:	68 f0 22 80 00       	push   $0x8022f0
  80005d:	68 f4 22 80 00       	push   $0x8022f4
  800062:	e8 fd 05 00 00       	call   800664 <cprintf>
  800067:	83 c4 20             	add    $0x20,%esp
  80006a:	8b 06                	mov    (%esi),%eax
  80006c:	39 03                	cmp    %eax,(%ebx)
  80006e:	75 17                	jne    800087 <check_regs+0x53>
  800070:	83 ec 0c             	sub    $0xc,%esp
  800073:	68 04 23 80 00       	push   $0x802304
  800078:	e8 e7 05 00 00       	call   800664 <cprintf>
  80007d:	83 c4 10             	add    $0x10,%esp

static void
check_regs(struct regs* a, const char *an, struct regs* b, const char *bn,
	   const char *testname)
{
	int mismatch = 0;
  800080:	bf 00 00 00 00       	mov    $0x0,%edi
  800085:	eb 15                	jmp    80009c <check_regs+0x68>
			cprintf("MISMATCH\n");				\
			mismatch = 1;					\
		}							\
	} while (0)

	CHECK(edi, regs.reg_edi);
  800087:	83 ec 0c             	sub    $0xc,%esp
  80008a:	68 08 23 80 00       	push   $0x802308
  80008f:	e8 d0 05 00 00       	call   800664 <cprintf>
  800094:	83 c4 10             	add    $0x10,%esp
  800097:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(esi, regs.reg_esi);
  80009c:	ff 76 04             	pushl  0x4(%esi)
  80009f:	ff 73 04             	pushl  0x4(%ebx)
  8000a2:	68 12 23 80 00       	push   $0x802312
  8000a7:	68 f4 22 80 00       	push   $0x8022f4
  8000ac:	e8 b3 05 00 00       	call   800664 <cprintf>
  8000b1:	83 c4 10             	add    $0x10,%esp
  8000b4:	8b 46 04             	mov    0x4(%esi),%eax
  8000b7:	39 43 04             	cmp    %eax,0x4(%ebx)
  8000ba:	75 12                	jne    8000ce <check_regs+0x9a>
  8000bc:	83 ec 0c             	sub    $0xc,%esp
  8000bf:	68 04 23 80 00       	push   $0x802304
  8000c4:	e8 9b 05 00 00       	call   800664 <cprintf>
  8000c9:	83 c4 10             	add    $0x10,%esp
  8000cc:	eb 15                	jmp    8000e3 <check_regs+0xaf>
  8000ce:	83 ec 0c             	sub    $0xc,%esp
  8000d1:	68 08 23 80 00       	push   $0x802308
  8000d6:	e8 89 05 00 00       	call   800664 <cprintf>
  8000db:	83 c4 10             	add    $0x10,%esp
  8000de:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(ebp, regs.reg_ebp);
  8000e3:	ff 76 08             	pushl  0x8(%esi)
  8000e6:	ff 73 08             	pushl  0x8(%ebx)
  8000e9:	68 16 23 80 00       	push   $0x802316
  8000ee:	68 f4 22 80 00       	push   $0x8022f4
  8000f3:	e8 6c 05 00 00       	call   800664 <cprintf>
  8000f8:	83 c4 10             	add    $0x10,%esp
  8000fb:	8b 46 08             	mov    0x8(%esi),%eax
  8000fe:	39 43 08             	cmp    %eax,0x8(%ebx)
  800101:	75 12                	jne    800115 <check_regs+0xe1>
  800103:	83 ec 0c             	sub    $0xc,%esp
  800106:	68 04 23 80 00       	push   $0x802304
  80010b:	e8 54 05 00 00       	call   800664 <cprintf>
  800110:	83 c4 10             	add    $0x10,%esp
  800113:	eb 15                	jmp    80012a <check_regs+0xf6>
  800115:	83 ec 0c             	sub    $0xc,%esp
  800118:	68 08 23 80 00       	push   $0x802308
  80011d:	e8 42 05 00 00       	call   800664 <cprintf>
  800122:	83 c4 10             	add    $0x10,%esp
  800125:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(ebx, regs.reg_ebx);
  80012a:	ff 76 10             	pushl  0x10(%esi)
  80012d:	ff 73 10             	pushl  0x10(%ebx)
  800130:	68 1a 23 80 00       	push   $0x80231a
  800135:	68 f4 22 80 00       	push   $0x8022f4
  80013a:	e8 25 05 00 00       	call   800664 <cprintf>
  80013f:	83 c4 10             	add    $0x10,%esp
  800142:	8b 46 10             	mov    0x10(%esi),%eax
  800145:	39 43 10             	cmp    %eax,0x10(%ebx)
  800148:	75 12                	jne    80015c <check_regs+0x128>
  80014a:	83 ec 0c             	sub    $0xc,%esp
  80014d:	68 04 23 80 00       	push   $0x802304
  800152:	e8 0d 05 00 00       	call   800664 <cprintf>
  800157:	83 c4 10             	add    $0x10,%esp
  80015a:	eb 15                	jmp    800171 <check_regs+0x13d>
  80015c:	83 ec 0c             	sub    $0xc,%esp
  80015f:	68 08 23 80 00       	push   $0x802308
  800164:	e8 fb 04 00 00       	call   800664 <cprintf>
  800169:	83 c4 10             	add    $0x10,%esp
  80016c:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(edx, regs.reg_edx);
  800171:	ff 76 14             	pushl  0x14(%esi)
  800174:	ff 73 14             	pushl  0x14(%ebx)
  800177:	68 1e 23 80 00       	push   $0x80231e
  80017c:	68 f4 22 80 00       	push   $0x8022f4
  800181:	e8 de 04 00 00       	call   800664 <cprintf>
  800186:	83 c4 10             	add    $0x10,%esp
  800189:	8b 46 14             	mov    0x14(%esi),%eax
  80018c:	39 43 14             	cmp    %eax,0x14(%ebx)
  80018f:	75 12                	jne    8001a3 <check_regs+0x16f>
  800191:	83 ec 0c             	sub    $0xc,%esp
  800194:	68 04 23 80 00       	push   $0x802304
  800199:	e8 c6 04 00 00       	call   800664 <cprintf>
  80019e:	83 c4 10             	add    $0x10,%esp
  8001a1:	eb 15                	jmp    8001b8 <check_regs+0x184>
  8001a3:	83 ec 0c             	sub    $0xc,%esp
  8001a6:	68 08 23 80 00       	push   $0x802308
  8001ab:	e8 b4 04 00 00       	call   800664 <cprintf>
  8001b0:	83 c4 10             	add    $0x10,%esp
  8001b3:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(ecx, regs.reg_ecx);
  8001b8:	ff 76 18             	pushl  0x18(%esi)
  8001bb:	ff 73 18             	pushl  0x18(%ebx)
  8001be:	68 22 23 80 00       	push   $0x802322
  8001c3:	68 f4 22 80 00       	push   $0x8022f4
  8001c8:	e8 97 04 00 00       	call   800664 <cprintf>
  8001cd:	83 c4 10             	add    $0x10,%esp
  8001d0:	8b 46 18             	mov    0x18(%esi),%eax
  8001d3:	39 43 18             	cmp    %eax,0x18(%ebx)
  8001d6:	75 12                	jne    8001ea <check_regs+0x1b6>
  8001d8:	83 ec 0c             	sub    $0xc,%esp
  8001db:	68 04 23 80 00       	push   $0x802304
  8001e0:	e8 7f 04 00 00       	call   800664 <cprintf>
  8001e5:	83 c4 10             	add    $0x10,%esp
  8001e8:	eb 15                	jmp    8001ff <check_regs+0x1cb>
  8001ea:	83 ec 0c             	sub    $0xc,%esp
  8001ed:	68 08 23 80 00       	push   $0x802308
  8001f2:	e8 6d 04 00 00       	call   800664 <cprintf>
  8001f7:	83 c4 10             	add    $0x10,%esp
  8001fa:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(eax, regs.reg_eax);
  8001ff:	ff 76 1c             	pushl  0x1c(%esi)
  800202:	ff 73 1c             	pushl  0x1c(%ebx)
  800205:	68 26 23 80 00       	push   $0x802326
  80020a:	68 f4 22 80 00       	push   $0x8022f4
  80020f:	e8 50 04 00 00       	call   800664 <cprintf>
  800214:	83 c4 10             	add    $0x10,%esp
  800217:	8b 46 1c             	mov    0x1c(%esi),%eax
  80021a:	39 43 1c             	cmp    %eax,0x1c(%ebx)
  80021d:	75 12                	jne    800231 <check_regs+0x1fd>
  80021f:	83 ec 0c             	sub    $0xc,%esp
  800222:	68 04 23 80 00       	push   $0x802304
  800227:	e8 38 04 00 00       	call   800664 <cprintf>
  80022c:	83 c4 10             	add    $0x10,%esp
  80022f:	eb 15                	jmp    800246 <check_regs+0x212>
  800231:	83 ec 0c             	sub    $0xc,%esp
  800234:	68 08 23 80 00       	push   $0x802308
  800239:	e8 26 04 00 00       	call   800664 <cprintf>
  80023e:	83 c4 10             	add    $0x10,%esp
  800241:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(eip, eip);
  800246:	ff 76 20             	pushl  0x20(%esi)
  800249:	ff 73 20             	pushl  0x20(%ebx)
  80024c:	68 2a 23 80 00       	push   $0x80232a
  800251:	68 f4 22 80 00       	push   $0x8022f4
  800256:	e8 09 04 00 00       	call   800664 <cprintf>
  80025b:	83 c4 10             	add    $0x10,%esp
  80025e:	8b 46 20             	mov    0x20(%esi),%eax
  800261:	39 43 20             	cmp    %eax,0x20(%ebx)
  800264:	75 12                	jne    800278 <check_regs+0x244>
  800266:	83 ec 0c             	sub    $0xc,%esp
  800269:	68 04 23 80 00       	push   $0x802304
  80026e:	e8 f1 03 00 00       	call   800664 <cprintf>
  800273:	83 c4 10             	add    $0x10,%esp
  800276:	eb 15                	jmp    80028d <check_regs+0x259>
  800278:	83 ec 0c             	sub    $0xc,%esp
  80027b:	68 08 23 80 00       	push   $0x802308
  800280:	e8 df 03 00 00       	call   800664 <cprintf>
  800285:	83 c4 10             	add    $0x10,%esp
  800288:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(eflags, eflags);
  80028d:	ff 76 24             	pushl  0x24(%esi)
  800290:	ff 73 24             	pushl  0x24(%ebx)
  800293:	68 2e 23 80 00       	push   $0x80232e
  800298:	68 f4 22 80 00       	push   $0x8022f4
  80029d:	e8 c2 03 00 00       	call   800664 <cprintf>
  8002a2:	83 c4 10             	add    $0x10,%esp
  8002a5:	8b 46 24             	mov    0x24(%esi),%eax
  8002a8:	39 43 24             	cmp    %eax,0x24(%ebx)
  8002ab:	75 12                	jne    8002bf <check_regs+0x28b>
  8002ad:	83 ec 0c             	sub    $0xc,%esp
  8002b0:	68 04 23 80 00       	push   $0x802304
  8002b5:	e8 aa 03 00 00       	call   800664 <cprintf>
  8002ba:	83 c4 10             	add    $0x10,%esp
  8002bd:	eb 15                	jmp    8002d4 <check_regs+0x2a0>
  8002bf:	83 ec 0c             	sub    $0xc,%esp
  8002c2:	68 08 23 80 00       	push   $0x802308
  8002c7:	e8 98 03 00 00       	call   800664 <cprintf>
  8002cc:	83 c4 10             	add    $0x10,%esp
  8002cf:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(esp, esp);
  8002d4:	ff 76 28             	pushl  0x28(%esi)
  8002d7:	ff 73 28             	pushl  0x28(%ebx)
  8002da:	68 35 23 80 00       	push   $0x802335
  8002df:	68 f4 22 80 00       	push   $0x8022f4
  8002e4:	e8 7b 03 00 00       	call   800664 <cprintf>
  8002e9:	83 c4 10             	add    $0x10,%esp
  8002ec:	8b 46 28             	mov    0x28(%esi),%eax
  8002ef:	39 43 28             	cmp    %eax,0x28(%ebx)
  8002f2:	75 26                	jne    80031a <check_regs+0x2e6>
  8002f4:	83 ec 0c             	sub    $0xc,%esp
  8002f7:	68 04 23 80 00       	push   $0x802304
  8002fc:	e8 63 03 00 00       	call   800664 <cprintf>

#undef CHECK

	cprintf("Registers %s ", testname);
  800301:	83 c4 08             	add    $0x8,%esp
  800304:	ff 75 0c             	pushl  0xc(%ebp)
  800307:	68 39 23 80 00       	push   $0x802339
  80030c:	e8 53 03 00 00       	call   800664 <cprintf>
	if (!mismatch)
  800311:	83 c4 10             	add    $0x10,%esp
  800314:	85 ff                	test   %edi,%edi
  800316:	74 24                	je     80033c <check_regs+0x308>
  800318:	eb 34                	jmp    80034e <check_regs+0x31a>
	CHECK(edx, regs.reg_edx);
	CHECK(ecx, regs.reg_ecx);
	CHECK(eax, regs.reg_eax);
	CHECK(eip, eip);
	CHECK(eflags, eflags);
	CHECK(esp, esp);
  80031a:	83 ec 0c             	sub    $0xc,%esp
  80031d:	68 08 23 80 00       	push   $0x802308
  800322:	e8 3d 03 00 00       	call   800664 <cprintf>

#undef CHECK

	cprintf("Registers %s ", testname);
  800327:	83 c4 08             	add    $0x8,%esp
  80032a:	ff 75 0c             	pushl  0xc(%ebp)
  80032d:	68 39 23 80 00       	push   $0x802339
  800332:	e8 2d 03 00 00       	call   800664 <cprintf>
  800337:	83 c4 10             	add    $0x10,%esp
  80033a:	eb 12                	jmp    80034e <check_regs+0x31a>
	if (!mismatch)
		cprintf("OK\n");
  80033c:	83 ec 0c             	sub    $0xc,%esp
  80033f:	68 04 23 80 00       	push   $0x802304
  800344:	e8 1b 03 00 00       	call   800664 <cprintf>
  800349:	83 c4 10             	add    $0x10,%esp
  80034c:	eb 10                	jmp    80035e <check_regs+0x32a>
	else
		cprintf("MISMATCH\n");
  80034e:	83 ec 0c             	sub    $0xc,%esp
  800351:	68 08 23 80 00       	push   $0x802308
  800356:	e8 09 03 00 00       	call   800664 <cprintf>
  80035b:	83 c4 10             	add    $0x10,%esp
}
  80035e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800361:	5b                   	pop    %ebx
  800362:	5e                   	pop    %esi
  800363:	5f                   	pop    %edi
  800364:	c9                   	leave  
  800365:	c3                   	ret    

00800366 <pgfault>:

static void
pgfault(struct UTrapframe *utf)
{
  800366:	55                   	push   %ebp
  800367:	89 e5                	mov    %esp,%ebp
  800369:	57                   	push   %edi
  80036a:	56                   	push   %esi
  80036b:	8b 45 08             	mov    0x8(%ebp),%eax
	int r;

	if (utf->utf_fault_va != (uint32_t)UTEMP)
  80036e:	8b 10                	mov    (%eax),%edx
  800370:	81 fa 00 00 40 00    	cmp    $0x400000,%edx
  800376:	74 18                	je     800390 <pgfault+0x2a>
		panic("pgfault expected at UTEMP, got 0x%08x (eip %08x)",
  800378:	83 ec 0c             	sub    $0xc,%esp
  80037b:	ff 70 28             	pushl  0x28(%eax)
  80037e:	52                   	push   %edx
  80037f:	68 a0 23 80 00       	push   $0x8023a0
  800384:	6a 51                	push   $0x51
  800386:	68 47 23 80 00       	push   $0x802347
  80038b:	e8 fc 01 00 00       	call   80058c <_panic>
		      utf->utf_fault_va, utf->utf_eip);

	// Check registers in UTrapframe
	during.regs = utf->utf_regs;
  800390:	bf 80 40 80 00       	mov    $0x804080,%edi
  800395:	8d 70 08             	lea    0x8(%eax),%esi
  800398:	b9 08 00 00 00       	mov    $0x8,%ecx
  80039d:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	during.eip = utf->utf_eip;
  80039f:	8b 50 28             	mov    0x28(%eax),%edx
  8003a2:	89 17                	mov    %edx,(%edi)
	during.eflags = utf->utf_eflags;
  8003a4:	8b 50 2c             	mov    0x2c(%eax),%edx
  8003a7:	89 15 a4 40 80 00    	mov    %edx,0x8040a4
	during.esp = utf->utf_esp;
  8003ad:	8b 40 30             	mov    0x30(%eax),%eax
  8003b0:	a3 a8 40 80 00       	mov    %eax,0x8040a8
	check_regs(&before, "before", &during, "during", "in UTrapframe");
  8003b5:	83 ec 08             	sub    $0x8,%esp
  8003b8:	68 5f 23 80 00       	push   $0x80235f
  8003bd:	68 6d 23 80 00       	push   $0x80236d
  8003c2:	b9 80 40 80 00       	mov    $0x804080,%ecx
  8003c7:	ba 58 23 80 00       	mov    $0x802358,%edx
  8003cc:	b8 00 40 80 00       	mov    $0x804000,%eax
  8003d1:	e8 5e fc ff ff       	call   800034 <check_regs>

	// Map UTEMP so the write succeeds
	if ((r = sys_page_alloc(0, UTEMP, PTE_U|PTE_P|PTE_W)) < 0)
  8003d6:	83 c4 0c             	add    $0xc,%esp
  8003d9:	6a 07                	push   $0x7
  8003db:	68 00 00 40 00       	push   $0x400000
  8003e0:	6a 00                	push   $0x0
  8003e2:	e8 b5 0c 00 00       	call   80109c <sys_page_alloc>
  8003e7:	83 c4 10             	add    $0x10,%esp
  8003ea:	85 c0                	test   %eax,%eax
  8003ec:	79 12                	jns    800400 <pgfault+0x9a>
		panic("sys_page_alloc: %e", r);
  8003ee:	50                   	push   %eax
  8003ef:	68 74 23 80 00       	push   $0x802374
  8003f4:	6a 5c                	push   $0x5c
  8003f6:	68 47 23 80 00       	push   $0x802347
  8003fb:	e8 8c 01 00 00       	call   80058c <_panic>
}
  800400:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800403:	5e                   	pop    %esi
  800404:	5f                   	pop    %edi
  800405:	c9                   	leave  
  800406:	c3                   	ret    

00800407 <umain>:

void
umain(int argc, char **argv)
{
  800407:	55                   	push   %ebp
  800408:	89 e5                	mov    %esp,%ebp
  80040a:	83 ec 14             	sub    $0x14,%esp
	set_pgfault_handler(pgfault);
  80040d:	68 66 03 80 00       	push   $0x800366
  800412:	e8 c5 0d 00 00       	call   8011dc <set_pgfault_handler>

	__asm __volatile(
  800417:	50                   	push   %eax
  800418:	9c                   	pushf  
  800419:	58                   	pop    %eax
  80041a:	0d d5 08 00 00       	or     $0x8d5,%eax
  80041f:	50                   	push   %eax
  800420:	9d                   	popf   
  800421:	a3 24 40 80 00       	mov    %eax,0x804024
  800426:	8d 05 61 04 80 00    	lea    0x800461,%eax
  80042c:	a3 20 40 80 00       	mov    %eax,0x804020
  800431:	58                   	pop    %eax
  800432:	89 3d 00 40 80 00    	mov    %edi,0x804000
  800438:	89 35 04 40 80 00    	mov    %esi,0x804004
  80043e:	89 2d 08 40 80 00    	mov    %ebp,0x804008
  800444:	89 1d 10 40 80 00    	mov    %ebx,0x804010
  80044a:	89 15 14 40 80 00    	mov    %edx,0x804014
  800450:	89 0d 18 40 80 00    	mov    %ecx,0x804018
  800456:	a3 1c 40 80 00       	mov    %eax,0x80401c
  80045b:	89 25 28 40 80 00    	mov    %esp,0x804028
  800461:	c7 05 00 00 40 00 2a 	movl   $0x2a,0x400000
  800468:	00 00 00 
  80046b:	89 3d 40 40 80 00    	mov    %edi,0x804040
  800471:	89 35 44 40 80 00    	mov    %esi,0x804044
  800477:	89 2d 48 40 80 00    	mov    %ebp,0x804048
  80047d:	89 1d 50 40 80 00    	mov    %ebx,0x804050
  800483:	89 15 54 40 80 00    	mov    %edx,0x804054
  800489:	89 0d 58 40 80 00    	mov    %ecx,0x804058
  80048f:	a3 5c 40 80 00       	mov    %eax,0x80405c
  800494:	89 25 68 40 80 00    	mov    %esp,0x804068
  80049a:	8b 3d 00 40 80 00    	mov    0x804000,%edi
  8004a0:	8b 35 04 40 80 00    	mov    0x804004,%esi
  8004a6:	8b 2d 08 40 80 00    	mov    0x804008,%ebp
  8004ac:	8b 1d 10 40 80 00    	mov    0x804010,%ebx
  8004b2:	8b 15 14 40 80 00    	mov    0x804014,%edx
  8004b8:	8b 0d 18 40 80 00    	mov    0x804018,%ecx
  8004be:	a1 1c 40 80 00       	mov    0x80401c,%eax
  8004c3:	8b 25 28 40 80 00    	mov    0x804028,%esp
  8004c9:	50                   	push   %eax
  8004ca:	9c                   	pushf  
  8004cb:	58                   	pop    %eax
  8004cc:	a3 64 40 80 00       	mov    %eax,0x804064
  8004d1:	58                   	pop    %eax
		: : "m" (before), "m" (after) : "memory", "cc");

	// Check UTEMP to roughly determine that EIP was restored
	// correctly (of course, we probably wouldn't get this far if
	// it weren't)
	if (*(int*)UTEMP != 42)
  8004d2:	83 c4 10             	add    $0x10,%esp
  8004d5:	83 3d 00 00 40 00 2a 	cmpl   $0x2a,0x400000
  8004dc:	74 10                	je     8004ee <umain+0xe7>
		cprintf("EIP after page-fault MISMATCH\n");
  8004de:	83 ec 0c             	sub    $0xc,%esp
  8004e1:	68 d4 23 80 00       	push   $0x8023d4
  8004e6:	e8 79 01 00 00       	call   800664 <cprintf>
  8004eb:	83 c4 10             	add    $0x10,%esp
	after.eip = before.eip;
  8004ee:	a1 20 40 80 00       	mov    0x804020,%eax
  8004f3:	a3 60 40 80 00       	mov    %eax,0x804060

	check_regs(&before, "before", &after, "after", "after page-fault");
  8004f8:	83 ec 08             	sub    $0x8,%esp
  8004fb:	68 87 23 80 00       	push   $0x802387
  800500:	68 98 23 80 00       	push   $0x802398
  800505:	b9 40 40 80 00       	mov    $0x804040,%ecx
  80050a:	ba 58 23 80 00       	mov    $0x802358,%edx
  80050f:	b8 00 40 80 00       	mov    $0x804000,%eax
  800514:	e8 1b fb ff ff       	call   800034 <check_regs>
  800519:	83 c4 10             	add    $0x10,%esp
}
  80051c:	c9                   	leave  
  80051d:	c3                   	ret    
	...

00800520 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800520:	55                   	push   %ebp
  800521:	89 e5                	mov    %esp,%ebp
  800523:	56                   	push   %esi
  800524:	53                   	push   %ebx
  800525:	8b 75 08             	mov    0x8(%ebp),%esi
  800528:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = envs + ENVX(sys_getenvid());
  80052b:	e8 21 0b 00 00       	call   801051 <sys_getenvid>
  800530:	25 ff 03 00 00       	and    $0x3ff,%eax
  800535:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  80053c:	c1 e0 07             	shl    $0x7,%eax
  80053f:	29 d0                	sub    %edx,%eax
  800541:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800546:	a3 b0 40 80 00       	mov    %eax,0x8040b0

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80054b:	85 f6                	test   %esi,%esi
  80054d:	7e 07                	jle    800556 <libmain+0x36>
		binaryname = argv[0];
  80054f:	8b 03                	mov    (%ebx),%eax
  800551:	a3 00 30 80 00       	mov    %eax,0x803000
	// call user main routine
	umain(argc, argv);
  800556:	83 ec 08             	sub    $0x8,%esp
  800559:	53                   	push   %ebx
  80055a:	56                   	push   %esi
  80055b:	e8 a7 fe ff ff       	call   800407 <umain>

	// exit gracefully
	exit();
  800560:	e8 0b 00 00 00       	call   800570 <exit>
  800565:	83 c4 10             	add    $0x10,%esp
}
  800568:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80056b:	5b                   	pop    %ebx
  80056c:	5e                   	pop    %esi
  80056d:	c9                   	leave  
  80056e:	c3                   	ret    
	...

00800570 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800570:	55                   	push   %ebp
  800571:	89 e5                	mov    %esp,%ebp
  800573:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800576:	e8 ff 0e 00 00       	call   80147a <close_all>
	sys_env_destroy(0);
  80057b:	83 ec 0c             	sub    $0xc,%esp
  80057e:	6a 00                	push   $0x0
  800580:	e8 aa 0a 00 00       	call   80102f <sys_env_destroy>
  800585:	83 c4 10             	add    $0x10,%esp
}
  800588:	c9                   	leave  
  800589:	c3                   	ret    
	...

0080058c <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80058c:	55                   	push   %ebp
  80058d:	89 e5                	mov    %esp,%ebp
  80058f:	56                   	push   %esi
  800590:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800591:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800594:	8b 1d 00 30 80 00    	mov    0x803000,%ebx
  80059a:	e8 b2 0a 00 00       	call   801051 <sys_getenvid>
  80059f:	83 ec 0c             	sub    $0xc,%esp
  8005a2:	ff 75 0c             	pushl  0xc(%ebp)
  8005a5:	ff 75 08             	pushl  0x8(%ebp)
  8005a8:	53                   	push   %ebx
  8005a9:	50                   	push   %eax
  8005aa:	68 00 24 80 00       	push   $0x802400
  8005af:	e8 b0 00 00 00       	call   800664 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8005b4:	83 c4 18             	add    $0x18,%esp
  8005b7:	56                   	push   %esi
  8005b8:	ff 75 10             	pushl  0x10(%ebp)
  8005bb:	e8 53 00 00 00       	call   800613 <vcprintf>
	cprintf("\n");
  8005c0:	c7 04 24 10 23 80 00 	movl   $0x802310,(%esp)
  8005c7:	e8 98 00 00 00       	call   800664 <cprintf>
  8005cc:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8005cf:	cc                   	int3   
  8005d0:	eb fd                	jmp    8005cf <_panic+0x43>
	...

008005d4 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8005d4:	55                   	push   %ebp
  8005d5:	89 e5                	mov    %esp,%ebp
  8005d7:	53                   	push   %ebx
  8005d8:	83 ec 04             	sub    $0x4,%esp
  8005db:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8005de:	8b 03                	mov    (%ebx),%eax
  8005e0:	8b 55 08             	mov    0x8(%ebp),%edx
  8005e3:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  8005e7:	40                   	inc    %eax
  8005e8:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  8005ea:	3d ff 00 00 00       	cmp    $0xff,%eax
  8005ef:	75 1a                	jne    80060b <putch+0x37>
		sys_cputs(b->buf, b->idx);
  8005f1:	83 ec 08             	sub    $0x8,%esp
  8005f4:	68 ff 00 00 00       	push   $0xff
  8005f9:	8d 43 08             	lea    0x8(%ebx),%eax
  8005fc:	50                   	push   %eax
  8005fd:	e8 e3 09 00 00       	call   800fe5 <sys_cputs>
		b->idx = 0;
  800602:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800608:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  80060b:	ff 43 04             	incl   0x4(%ebx)
}
  80060e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800611:	c9                   	leave  
  800612:	c3                   	ret    

00800613 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800613:	55                   	push   %ebp
  800614:	89 e5                	mov    %esp,%ebp
  800616:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  80061c:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800623:	00 00 00 
	b.cnt = 0;
  800626:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80062d:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800630:	ff 75 0c             	pushl  0xc(%ebp)
  800633:	ff 75 08             	pushl  0x8(%ebp)
  800636:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80063c:	50                   	push   %eax
  80063d:	68 d4 05 80 00       	push   $0x8005d4
  800642:	e8 82 01 00 00       	call   8007c9 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800647:	83 c4 08             	add    $0x8,%esp
  80064a:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800650:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800656:	50                   	push   %eax
  800657:	e8 89 09 00 00       	call   800fe5 <sys_cputs>

	return b.cnt;
}
  80065c:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800662:	c9                   	leave  
  800663:	c3                   	ret    

00800664 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800664:	55                   	push   %ebp
  800665:	89 e5                	mov    %esp,%ebp
  800667:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80066a:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80066d:	50                   	push   %eax
  80066e:	ff 75 08             	pushl  0x8(%ebp)
  800671:	e8 9d ff ff ff       	call   800613 <vcprintf>
	va_end(ap);

	return cnt;
}
  800676:	c9                   	leave  
  800677:	c3                   	ret    

00800678 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800678:	55                   	push   %ebp
  800679:	89 e5                	mov    %esp,%ebp
  80067b:	57                   	push   %edi
  80067c:	56                   	push   %esi
  80067d:	53                   	push   %ebx
  80067e:	83 ec 2c             	sub    $0x2c,%esp
  800681:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800684:	89 d6                	mov    %edx,%esi
  800686:	8b 45 08             	mov    0x8(%ebp),%eax
  800689:	8b 55 0c             	mov    0xc(%ebp),%edx
  80068c:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80068f:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800692:	8b 45 10             	mov    0x10(%ebp),%eax
  800695:	8b 5d 14             	mov    0x14(%ebp),%ebx
  800698:	8b 7d 18             	mov    0x18(%ebp),%edi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80069b:	89 45 d0             	mov    %eax,-0x30(%ebp)
  80069e:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  8006a5:	39 55 d4             	cmp    %edx,-0x2c(%ebp)
  8006a8:	72 0c                	jb     8006b6 <printnum+0x3e>
  8006aa:	3b 45 d8             	cmp    -0x28(%ebp),%eax
  8006ad:	76 07                	jbe    8006b6 <printnum+0x3e>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8006af:	4b                   	dec    %ebx
  8006b0:	85 db                	test   %ebx,%ebx
  8006b2:	7f 31                	jg     8006e5 <printnum+0x6d>
  8006b4:	eb 3f                	jmp    8006f5 <printnum+0x7d>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8006b6:	83 ec 0c             	sub    $0xc,%esp
  8006b9:	57                   	push   %edi
  8006ba:	4b                   	dec    %ebx
  8006bb:	53                   	push   %ebx
  8006bc:	50                   	push   %eax
  8006bd:	83 ec 08             	sub    $0x8,%esp
  8006c0:	ff 75 d4             	pushl  -0x2c(%ebp)
  8006c3:	ff 75 d0             	pushl  -0x30(%ebp)
  8006c6:	ff 75 dc             	pushl  -0x24(%ebp)
  8006c9:	ff 75 d8             	pushl  -0x28(%ebp)
  8006cc:	e8 bf 19 00 00       	call   802090 <__udivdi3>
  8006d1:	83 c4 18             	add    $0x18,%esp
  8006d4:	52                   	push   %edx
  8006d5:	50                   	push   %eax
  8006d6:	89 f2                	mov    %esi,%edx
  8006d8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8006db:	e8 98 ff ff ff       	call   800678 <printnum>
  8006e0:	83 c4 20             	add    $0x20,%esp
  8006e3:	eb 10                	jmp    8006f5 <printnum+0x7d>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8006e5:	83 ec 08             	sub    $0x8,%esp
  8006e8:	56                   	push   %esi
  8006e9:	57                   	push   %edi
  8006ea:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8006ed:	4b                   	dec    %ebx
  8006ee:	83 c4 10             	add    $0x10,%esp
  8006f1:	85 db                	test   %ebx,%ebx
  8006f3:	7f f0                	jg     8006e5 <printnum+0x6d>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8006f5:	83 ec 08             	sub    $0x8,%esp
  8006f8:	56                   	push   %esi
  8006f9:	83 ec 04             	sub    $0x4,%esp
  8006fc:	ff 75 d4             	pushl  -0x2c(%ebp)
  8006ff:	ff 75 d0             	pushl  -0x30(%ebp)
  800702:	ff 75 dc             	pushl  -0x24(%ebp)
  800705:	ff 75 d8             	pushl  -0x28(%ebp)
  800708:	e8 9f 1a 00 00       	call   8021ac <__umoddi3>
  80070d:	83 c4 14             	add    $0x14,%esp
  800710:	0f be 80 23 24 80 00 	movsbl 0x802423(%eax),%eax
  800717:	50                   	push   %eax
  800718:	ff 55 e4             	call   *-0x1c(%ebp)
  80071b:	83 c4 10             	add    $0x10,%esp
}
  80071e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800721:	5b                   	pop    %ebx
  800722:	5e                   	pop    %esi
  800723:	5f                   	pop    %edi
  800724:	c9                   	leave  
  800725:	c3                   	ret    

00800726 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800726:	55                   	push   %ebp
  800727:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800729:	83 fa 01             	cmp    $0x1,%edx
  80072c:	7e 0e                	jle    80073c <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80072e:	8b 10                	mov    (%eax),%edx
  800730:	8d 4a 08             	lea    0x8(%edx),%ecx
  800733:	89 08                	mov    %ecx,(%eax)
  800735:	8b 02                	mov    (%edx),%eax
  800737:	8b 52 04             	mov    0x4(%edx),%edx
  80073a:	eb 22                	jmp    80075e <getuint+0x38>
	else if (lflag)
  80073c:	85 d2                	test   %edx,%edx
  80073e:	74 10                	je     800750 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800740:	8b 10                	mov    (%eax),%edx
  800742:	8d 4a 04             	lea    0x4(%edx),%ecx
  800745:	89 08                	mov    %ecx,(%eax)
  800747:	8b 02                	mov    (%edx),%eax
  800749:	ba 00 00 00 00       	mov    $0x0,%edx
  80074e:	eb 0e                	jmp    80075e <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800750:	8b 10                	mov    (%eax),%edx
  800752:	8d 4a 04             	lea    0x4(%edx),%ecx
  800755:	89 08                	mov    %ecx,(%eax)
  800757:	8b 02                	mov    (%edx),%eax
  800759:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80075e:	c9                   	leave  
  80075f:	c3                   	ret    

00800760 <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
  800760:	55                   	push   %ebp
  800761:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800763:	83 fa 01             	cmp    $0x1,%edx
  800766:	7e 0e                	jle    800776 <getint+0x16>
		return va_arg(*ap, long long);
  800768:	8b 10                	mov    (%eax),%edx
  80076a:	8d 4a 08             	lea    0x8(%edx),%ecx
  80076d:	89 08                	mov    %ecx,(%eax)
  80076f:	8b 02                	mov    (%edx),%eax
  800771:	8b 52 04             	mov    0x4(%edx),%edx
  800774:	eb 1a                	jmp    800790 <getint+0x30>
	else if (lflag)
  800776:	85 d2                	test   %edx,%edx
  800778:	74 0c                	je     800786 <getint+0x26>
		return va_arg(*ap, long);
  80077a:	8b 10                	mov    (%eax),%edx
  80077c:	8d 4a 04             	lea    0x4(%edx),%ecx
  80077f:	89 08                	mov    %ecx,(%eax)
  800781:	8b 02                	mov    (%edx),%eax
  800783:	99                   	cltd   
  800784:	eb 0a                	jmp    800790 <getint+0x30>
	else
		return va_arg(*ap, int);
  800786:	8b 10                	mov    (%eax),%edx
  800788:	8d 4a 04             	lea    0x4(%edx),%ecx
  80078b:	89 08                	mov    %ecx,(%eax)
  80078d:	8b 02                	mov    (%edx),%eax
  80078f:	99                   	cltd   
}
  800790:	c9                   	leave  
  800791:	c3                   	ret    

00800792 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800792:	55                   	push   %ebp
  800793:	89 e5                	mov    %esp,%ebp
  800795:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800798:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  80079b:	8b 10                	mov    (%eax),%edx
  80079d:	3b 50 04             	cmp    0x4(%eax),%edx
  8007a0:	73 08                	jae    8007aa <sprintputch+0x18>
		*b->buf++ = ch;
  8007a2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007a5:	88 0a                	mov    %cl,(%edx)
  8007a7:	42                   	inc    %edx
  8007a8:	89 10                	mov    %edx,(%eax)
}
  8007aa:	c9                   	leave  
  8007ab:	c3                   	ret    

008007ac <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8007ac:	55                   	push   %ebp
  8007ad:	89 e5                	mov    %esp,%ebp
  8007af:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8007b2:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8007b5:	50                   	push   %eax
  8007b6:	ff 75 10             	pushl  0x10(%ebp)
  8007b9:	ff 75 0c             	pushl  0xc(%ebp)
  8007bc:	ff 75 08             	pushl  0x8(%ebp)
  8007bf:	e8 05 00 00 00       	call   8007c9 <vprintfmt>
	va_end(ap);
  8007c4:	83 c4 10             	add    $0x10,%esp
}
  8007c7:	c9                   	leave  
  8007c8:	c3                   	ret    

008007c9 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8007c9:	55                   	push   %ebp
  8007ca:	89 e5                	mov    %esp,%ebp
  8007cc:	57                   	push   %edi
  8007cd:	56                   	push   %esi
  8007ce:	53                   	push   %ebx
  8007cf:	83 ec 2c             	sub    $0x2c,%esp
  8007d2:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8007d5:	8b 75 10             	mov    0x10(%ebp),%esi
  8007d8:	eb 13                	jmp    8007ed <vprintfmt+0x24>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8007da:	85 c0                	test   %eax,%eax
  8007dc:	0f 84 6d 03 00 00    	je     800b4f <vprintfmt+0x386>
				return;
			putch(ch, putdat);
  8007e2:	83 ec 08             	sub    $0x8,%esp
  8007e5:	57                   	push   %edi
  8007e6:	50                   	push   %eax
  8007e7:	ff 55 08             	call   *0x8(%ebp)
  8007ea:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8007ed:	0f b6 06             	movzbl (%esi),%eax
  8007f0:	46                   	inc    %esi
  8007f1:	83 f8 25             	cmp    $0x25,%eax
  8007f4:	75 e4                	jne    8007da <vprintfmt+0x11>
  8007f6:	c6 45 dc 20          	movb   $0x20,-0x24(%ebp)
  8007fa:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  800801:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
  800808:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  80080f:	b9 00 00 00 00       	mov    $0x0,%ecx
  800814:	eb 28                	jmp    80083e <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800816:	89 de                	mov    %ebx,%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  800818:	c6 45 dc 2d          	movb   $0x2d,-0x24(%ebp)
  80081c:	eb 20                	jmp    80083e <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80081e:	89 de                	mov    %ebx,%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800820:	c6 45 dc 30          	movb   $0x30,-0x24(%ebp)
  800824:	eb 18                	jmp    80083e <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800826:	89 de                	mov    %ebx,%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  800828:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  80082f:	eb 0d                	jmp    80083e <vprintfmt+0x75>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  800831:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  800834:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800837:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80083e:	8a 06                	mov    (%esi),%al
  800840:	0f b6 d0             	movzbl %al,%edx
  800843:	8d 5e 01             	lea    0x1(%esi),%ebx
  800846:	83 e8 23             	sub    $0x23,%eax
  800849:	3c 55                	cmp    $0x55,%al
  80084b:	0f 87 e0 02 00 00    	ja     800b31 <vprintfmt+0x368>
  800851:	0f b6 c0             	movzbl %al,%eax
  800854:	ff 24 85 60 25 80 00 	jmp    *0x802560(,%eax,4)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80085b:	83 ea 30             	sub    $0x30,%edx
  80085e:	89 55 d4             	mov    %edx,-0x2c(%ebp)
				ch = *fmt;
  800861:	0f be 03             	movsbl (%ebx),%eax
				if (ch < '0' || ch > '9')
  800864:	8d 50 d0             	lea    -0x30(%eax),%edx
  800867:	83 fa 09             	cmp    $0x9,%edx
  80086a:	77 44                	ja     8008b0 <vprintfmt+0xe7>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80086c:	89 de                	mov    %ebx,%esi
  80086e:	8b 55 d4             	mov    -0x2c(%ebp),%edx
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800871:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
  800872:	8d 14 92             	lea    (%edx,%edx,4),%edx
  800875:	8d 54 50 d0          	lea    -0x30(%eax,%edx,2),%edx
				ch = *fmt;
  800879:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  80087c:	8d 58 d0             	lea    -0x30(%eax),%ebx
  80087f:	83 fb 09             	cmp    $0x9,%ebx
  800882:	76 ed                	jbe    800871 <vprintfmt+0xa8>
  800884:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  800887:	eb 29                	jmp    8008b2 <vprintfmt+0xe9>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800889:	8b 45 14             	mov    0x14(%ebp),%eax
  80088c:	8d 50 04             	lea    0x4(%eax),%edx
  80088f:	89 55 14             	mov    %edx,0x14(%ebp)
  800892:	8b 00                	mov    (%eax),%eax
  800894:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800897:	89 de                	mov    %ebx,%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800899:	eb 17                	jmp    8008b2 <vprintfmt+0xe9>

		case '.':
			if (width < 0)
  80089b:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80089f:	78 85                	js     800826 <vprintfmt+0x5d>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8008a1:	89 de                	mov    %ebx,%esi
  8008a3:	eb 99                	jmp    80083e <vprintfmt+0x75>
  8008a5:	89 de                	mov    %ebx,%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8008a7:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
			goto reswitch;
  8008ae:	eb 8e                	jmp    80083e <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8008b0:	89 de                	mov    %ebx,%esi
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  8008b2:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8008b6:	79 86                	jns    80083e <vprintfmt+0x75>
  8008b8:	e9 74 ff ff ff       	jmp    800831 <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8008bd:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8008be:	89 de                	mov    %ebx,%esi
  8008c0:	e9 79 ff ff ff       	jmp    80083e <vprintfmt+0x75>
  8008c5:	89 5d d8             	mov    %ebx,-0x28(%ebp)
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8008c8:	8b 45 14             	mov    0x14(%ebp),%eax
  8008cb:	8d 50 04             	lea    0x4(%eax),%edx
  8008ce:	89 55 14             	mov    %edx,0x14(%ebp)
  8008d1:	83 ec 08             	sub    $0x8,%esp
  8008d4:	57                   	push   %edi
  8008d5:	ff 30                	pushl  (%eax)
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
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8008e0:	e9 08 ff ff ff       	jmp    8007ed <vprintfmt+0x24>
  8008e5:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// error message
		case 'e':
			err = va_arg(ap, int);
  8008e8:	8b 45 14             	mov    0x14(%ebp),%eax
  8008eb:	8d 50 04             	lea    0x4(%eax),%edx
  8008ee:	89 55 14             	mov    %edx,0x14(%ebp)
  8008f1:	8b 00                	mov    (%eax),%eax
  8008f3:	85 c0                	test   %eax,%eax
  8008f5:	79 02                	jns    8008f9 <vprintfmt+0x130>
  8008f7:	f7 d8                	neg    %eax
  8008f9:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8008fb:	83 f8 0f             	cmp    $0xf,%eax
  8008fe:	7f 0b                	jg     80090b <vprintfmt+0x142>
  800900:	8b 04 85 c0 26 80 00 	mov    0x8026c0(,%eax,4),%eax
  800907:	85 c0                	test   %eax,%eax
  800909:	75 1a                	jne    800925 <vprintfmt+0x15c>
				printfmt(putch, putdat, "error %d", err);
  80090b:	52                   	push   %edx
  80090c:	68 3b 24 80 00       	push   $0x80243b
  800911:	57                   	push   %edi
  800912:	ff 75 08             	pushl  0x8(%ebp)
  800915:	e8 92 fe ff ff       	call   8007ac <printfmt>
  80091a:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80091d:	8b 75 d8             	mov    -0x28(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800920:	e9 c8 fe ff ff       	jmp    8007ed <vprintfmt+0x24>
			else
				printfmt(putch, putdat, "%s", p);
  800925:	50                   	push   %eax
  800926:	68 45 28 80 00       	push   $0x802845
  80092b:	57                   	push   %edi
  80092c:	ff 75 08             	pushl  0x8(%ebp)
  80092f:	e8 78 fe ff ff       	call   8007ac <printfmt>
  800934:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800937:	8b 75 d8             	mov    -0x28(%ebp),%esi
  80093a:	e9 ae fe ff ff       	jmp    8007ed <vprintfmt+0x24>
  80093f:	89 5d d8             	mov    %ebx,-0x28(%ebp)
  800942:	89 de                	mov    %ebx,%esi
  800944:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  800947:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80094a:	8b 45 14             	mov    0x14(%ebp),%eax
  80094d:	8d 50 04             	lea    0x4(%eax),%edx
  800950:	89 55 14             	mov    %edx,0x14(%ebp)
  800953:	8b 00                	mov    (%eax),%eax
  800955:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800958:	85 c0                	test   %eax,%eax
  80095a:	75 07                	jne    800963 <vprintfmt+0x19a>
				p = "(null)";
  80095c:	c7 45 d0 34 24 80 00 	movl   $0x802434,-0x30(%ebp)
			if (width > 0 && padc != '-')
  800963:	85 db                	test   %ebx,%ebx
  800965:	7e 42                	jle    8009a9 <vprintfmt+0x1e0>
  800967:	80 7d dc 2d          	cmpb   $0x2d,-0x24(%ebp)
  80096b:	74 3c                	je     8009a9 <vprintfmt+0x1e0>
				for (width -= strnlen(p, precision); width > 0; width--)
  80096d:	83 ec 08             	sub    $0x8,%esp
  800970:	51                   	push   %ecx
  800971:	ff 75 d0             	pushl  -0x30(%ebp)
  800974:	e8 6f 02 00 00       	call   800be8 <strnlen>
  800979:	29 c3                	sub    %eax,%ebx
  80097b:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  80097e:	83 c4 10             	add    $0x10,%esp
  800981:	85 db                	test   %ebx,%ebx
  800983:	7e 24                	jle    8009a9 <vprintfmt+0x1e0>
					putch(padc, putdat);
  800985:	0f be 5d dc          	movsbl -0x24(%ebp),%ebx
  800989:	89 75 dc             	mov    %esi,-0x24(%ebp)
  80098c:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  80098f:	83 ec 08             	sub    $0x8,%esp
  800992:	57                   	push   %edi
  800993:	53                   	push   %ebx
  800994:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800997:	4e                   	dec    %esi
  800998:	83 c4 10             	add    $0x10,%esp
  80099b:	85 f6                	test   %esi,%esi
  80099d:	7f f0                	jg     80098f <vprintfmt+0x1c6>
  80099f:	8b 75 dc             	mov    -0x24(%ebp),%esi
  8009a2:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8009a9:	8b 55 d0             	mov    -0x30(%ebp),%edx
  8009ac:	0f be 02             	movsbl (%edx),%eax
  8009af:	85 c0                	test   %eax,%eax
  8009b1:	75 47                	jne    8009fa <vprintfmt+0x231>
  8009b3:	eb 37                	jmp    8009ec <vprintfmt+0x223>
				if (altflag && (ch < ' ' || ch > '~'))
  8009b5:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8009b9:	74 16                	je     8009d1 <vprintfmt+0x208>
  8009bb:	8d 50 e0             	lea    -0x20(%eax),%edx
  8009be:	83 fa 5e             	cmp    $0x5e,%edx
  8009c1:	76 0e                	jbe    8009d1 <vprintfmt+0x208>
					putch('?', putdat);
  8009c3:	83 ec 08             	sub    $0x8,%esp
  8009c6:	57                   	push   %edi
  8009c7:	6a 3f                	push   $0x3f
  8009c9:	ff 55 08             	call   *0x8(%ebp)
  8009cc:	83 c4 10             	add    $0x10,%esp
  8009cf:	eb 0b                	jmp    8009dc <vprintfmt+0x213>
				else
					putch(ch, putdat);
  8009d1:	83 ec 08             	sub    $0x8,%esp
  8009d4:	57                   	push   %edi
  8009d5:	50                   	push   %eax
  8009d6:	ff 55 08             	call   *0x8(%ebp)
  8009d9:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8009dc:	ff 4d e4             	decl   -0x1c(%ebp)
  8009df:	0f be 03             	movsbl (%ebx),%eax
  8009e2:	85 c0                	test   %eax,%eax
  8009e4:	74 03                	je     8009e9 <vprintfmt+0x220>
  8009e6:	43                   	inc    %ebx
  8009e7:	eb 1b                	jmp    800a04 <vprintfmt+0x23b>
  8009e9:	8b 75 dc             	mov    -0x24(%ebp),%esi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8009ec:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8009f0:	7f 1e                	jg     800a10 <vprintfmt+0x247>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8009f2:	8b 75 d8             	mov    -0x28(%ebp),%esi
  8009f5:	e9 f3 fd ff ff       	jmp    8007ed <vprintfmt+0x24>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8009fa:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  8009fd:	43                   	inc    %ebx
  8009fe:	89 75 dc             	mov    %esi,-0x24(%ebp)
  800a01:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  800a04:	85 f6                	test   %esi,%esi
  800a06:	78 ad                	js     8009b5 <vprintfmt+0x1ec>
  800a08:	4e                   	dec    %esi
  800a09:	79 aa                	jns    8009b5 <vprintfmt+0x1ec>
  800a0b:	8b 75 dc             	mov    -0x24(%ebp),%esi
  800a0e:	eb dc                	jmp    8009ec <vprintfmt+0x223>
  800a10:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800a13:	83 ec 08             	sub    $0x8,%esp
  800a16:	57                   	push   %edi
  800a17:	6a 20                	push   $0x20
  800a19:	ff 55 08             	call   *0x8(%ebp)
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800a1c:	4b                   	dec    %ebx
  800a1d:	83 c4 10             	add    $0x10,%esp
  800a20:	85 db                	test   %ebx,%ebx
  800a22:	7f ef                	jg     800a13 <vprintfmt+0x24a>
  800a24:	e9 c4 fd ff ff       	jmp    8007ed <vprintfmt+0x24>
  800a29:	89 5d d8             	mov    %ebx,-0x28(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800a2c:	89 ca                	mov    %ecx,%edx
  800a2e:	8d 45 14             	lea    0x14(%ebp),%eax
  800a31:	e8 2a fd ff ff       	call   800760 <getint>
  800a36:	89 c3                	mov    %eax,%ebx
  800a38:	89 d6                	mov    %edx,%esi
			if ((long long) num < 0) {
  800a3a:	85 d2                	test   %edx,%edx
  800a3c:	78 0a                	js     800a48 <vprintfmt+0x27f>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800a3e:	b8 0a 00 00 00       	mov    $0xa,%eax
  800a43:	e9 b0 00 00 00       	jmp    800af8 <vprintfmt+0x32f>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  800a48:	83 ec 08             	sub    $0x8,%esp
  800a4b:	57                   	push   %edi
  800a4c:	6a 2d                	push   $0x2d
  800a4e:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  800a51:	f7 db                	neg    %ebx
  800a53:	83 d6 00             	adc    $0x0,%esi
  800a56:	f7 de                	neg    %esi
  800a58:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800a5b:	b8 0a 00 00 00       	mov    $0xa,%eax
  800a60:	e9 93 00 00 00       	jmp    800af8 <vprintfmt+0x32f>
  800a65:	89 5d d8             	mov    %ebx,-0x28(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800a68:	89 ca                	mov    %ecx,%edx
  800a6a:	8d 45 14             	lea    0x14(%ebp),%eax
  800a6d:	e8 b4 fc ff ff       	call   800726 <getuint>
  800a72:	89 c3                	mov    %eax,%ebx
  800a74:	89 d6                	mov    %edx,%esi
			base = 10;
  800a76:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  800a7b:	eb 7b                	jmp    800af8 <vprintfmt+0x32f>
  800a7d:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// (unsigned) octal
		case 'o':
            // (MIT 6.828, lab1, Ex.8)  my code : 
            num = getint(&ap, lflag);
  800a80:	89 ca                	mov    %ecx,%edx
  800a82:	8d 45 14             	lea    0x14(%ebp),%eax
  800a85:	e8 d6 fc ff ff       	call   800760 <getint>
  800a8a:	89 c3                	mov    %eax,%ebx
  800a8c:	89 d6                	mov    %edx,%esi
            if ((long long) num < 0) {
  800a8e:	85 d2                	test   %edx,%edx
  800a90:	78 07                	js     800a99 <vprintfmt+0x2d0>
                putch('-', putdat);
                num = -(long long) num;
            }
            base = 8;
  800a92:	b8 08 00 00 00       	mov    $0x8,%eax
  800a97:	eb 5f                	jmp    800af8 <vprintfmt+0x32f>
		// (unsigned) octal
		case 'o':
            // (MIT 6.828, lab1, Ex.8)  my code : 
            num = getint(&ap, lflag);
            if ((long long) num < 0) {
                putch('-', putdat);
  800a99:	83 ec 08             	sub    $0x8,%esp
  800a9c:	57                   	push   %edi
  800a9d:	6a 2d                	push   $0x2d
  800a9f:	ff 55 08             	call   *0x8(%ebp)
                num = -(long long) num;
  800aa2:	f7 db                	neg    %ebx
  800aa4:	83 d6 00             	adc    $0x0,%esi
  800aa7:	f7 de                	neg    %esi
  800aa9:	83 c4 10             	add    $0x10,%esp
            }
            base = 8;
  800aac:	b8 08 00 00 00       	mov    $0x8,%eax
  800ab1:	eb 45                	jmp    800af8 <vprintfmt+0x32f>
  800ab3:	89 5d d8             	mov    %ebx,-0x28(%ebp)
            goto number;

        // pointer
		case 'p':
			putch('0', putdat);
  800ab6:	83 ec 08             	sub    $0x8,%esp
  800ab9:	57                   	push   %edi
  800aba:	6a 30                	push   $0x30
  800abc:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  800abf:	83 c4 08             	add    $0x8,%esp
  800ac2:	57                   	push   %edi
  800ac3:	6a 78                	push   $0x78
  800ac5:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800ac8:	8b 45 14             	mov    0x14(%ebp),%eax
  800acb:	8d 50 04             	lea    0x4(%eax),%edx
  800ace:	89 55 14             	mov    %edx,0x14(%ebp)

        // pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800ad1:	8b 18                	mov    (%eax),%ebx
  800ad3:	be 00 00 00 00       	mov    $0x0,%esi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800ad8:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800adb:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  800ae0:	eb 16                	jmp    800af8 <vprintfmt+0x32f>
  800ae2:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800ae5:	89 ca                	mov    %ecx,%edx
  800ae7:	8d 45 14             	lea    0x14(%ebp),%eax
  800aea:	e8 37 fc ff ff       	call   800726 <getuint>
  800aef:	89 c3                	mov    %eax,%ebx
  800af1:	89 d6                	mov    %edx,%esi
			base = 16;
  800af3:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  800af8:	83 ec 0c             	sub    $0xc,%esp
  800afb:	0f be 55 dc          	movsbl -0x24(%ebp),%edx
  800aff:	52                   	push   %edx
  800b00:	ff 75 e4             	pushl  -0x1c(%ebp)
  800b03:	50                   	push   %eax
  800b04:	56                   	push   %esi
  800b05:	53                   	push   %ebx
  800b06:	89 fa                	mov    %edi,%edx
  800b08:	8b 45 08             	mov    0x8(%ebp),%eax
  800b0b:	e8 68 fb ff ff       	call   800678 <printnum>
			break;
  800b10:	83 c4 20             	add    $0x20,%esp
  800b13:	8b 75 d8             	mov    -0x28(%ebp),%esi
  800b16:	e9 d2 fc ff ff       	jmp    8007ed <vprintfmt+0x24>
  800b1b:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800b1e:	83 ec 08             	sub    $0x8,%esp
  800b21:	57                   	push   %edi
  800b22:	52                   	push   %edx
  800b23:	ff 55 08             	call   *0x8(%ebp)
			break;
  800b26:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800b29:	8b 75 d8             	mov    -0x28(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800b2c:	e9 bc fc ff ff       	jmp    8007ed <vprintfmt+0x24>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800b31:	83 ec 08             	sub    $0x8,%esp
  800b34:	57                   	push   %edi
  800b35:	6a 25                	push   $0x25
  800b37:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800b3a:	83 c4 10             	add    $0x10,%esp
  800b3d:	eb 02                	jmp    800b41 <vprintfmt+0x378>
  800b3f:	89 c6                	mov    %eax,%esi
  800b41:	8d 46 ff             	lea    -0x1(%esi),%eax
  800b44:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  800b48:	75 f5                	jne    800b3f <vprintfmt+0x376>
  800b4a:	e9 9e fc ff ff       	jmp    8007ed <vprintfmt+0x24>
				/* do nothing */;
			break;
		}
	}
}
  800b4f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b52:	5b                   	pop    %ebx
  800b53:	5e                   	pop    %esi
  800b54:	5f                   	pop    %edi
  800b55:	c9                   	leave  
  800b56:	c3                   	ret    

00800b57 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800b57:	55                   	push   %ebp
  800b58:	89 e5                	mov    %esp,%ebp
  800b5a:	83 ec 18             	sub    $0x18,%esp
  800b5d:	8b 45 08             	mov    0x8(%ebp),%eax
  800b60:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800b63:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800b66:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800b6a:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800b6d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800b74:	85 c0                	test   %eax,%eax
  800b76:	74 26                	je     800b9e <vsnprintf+0x47>
  800b78:	85 d2                	test   %edx,%edx
  800b7a:	7e 29                	jle    800ba5 <vsnprintf+0x4e>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800b7c:	ff 75 14             	pushl  0x14(%ebp)
  800b7f:	ff 75 10             	pushl  0x10(%ebp)
  800b82:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800b85:	50                   	push   %eax
  800b86:	68 92 07 80 00       	push   $0x800792
  800b8b:	e8 39 fc ff ff       	call   8007c9 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800b90:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800b93:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800b96:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800b99:	83 c4 10             	add    $0x10,%esp
  800b9c:	eb 0c                	jmp    800baa <vsnprintf+0x53>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800b9e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800ba3:	eb 05                	jmp    800baa <vsnprintf+0x53>
  800ba5:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800baa:	c9                   	leave  
  800bab:	c3                   	ret    

00800bac <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800bac:	55                   	push   %ebp
  800bad:	89 e5                	mov    %esp,%ebp
  800baf:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800bb2:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800bb5:	50                   	push   %eax
  800bb6:	ff 75 10             	pushl  0x10(%ebp)
  800bb9:	ff 75 0c             	pushl  0xc(%ebp)
  800bbc:	ff 75 08             	pushl  0x8(%ebp)
  800bbf:	e8 93 ff ff ff       	call   800b57 <vsnprintf>
	va_end(ap);

	return rc;
}
  800bc4:	c9                   	leave  
  800bc5:	c3                   	ret    
	...

00800bc8 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800bc8:	55                   	push   %ebp
  800bc9:	89 e5                	mov    %esp,%ebp
  800bcb:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800bce:	80 3a 00             	cmpb   $0x0,(%edx)
  800bd1:	74 0e                	je     800be1 <strlen+0x19>
  800bd3:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  800bd8:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800bd9:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800bdd:	75 f9                	jne    800bd8 <strlen+0x10>
  800bdf:	eb 05                	jmp    800be6 <strlen+0x1e>
  800be1:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  800be6:	c9                   	leave  
  800be7:	c3                   	ret    

00800be8 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800be8:	55                   	push   %ebp
  800be9:	89 e5                	mov    %esp,%ebp
  800beb:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800bee:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800bf1:	85 d2                	test   %edx,%edx
  800bf3:	74 17                	je     800c0c <strnlen+0x24>
  800bf5:	80 39 00             	cmpb   $0x0,(%ecx)
  800bf8:	74 19                	je     800c13 <strnlen+0x2b>
  800bfa:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  800bff:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800c00:	39 d0                	cmp    %edx,%eax
  800c02:	74 14                	je     800c18 <strnlen+0x30>
  800c04:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800c08:	75 f5                	jne    800bff <strnlen+0x17>
  800c0a:	eb 0c                	jmp    800c18 <strnlen+0x30>
  800c0c:	b8 00 00 00 00       	mov    $0x0,%eax
  800c11:	eb 05                	jmp    800c18 <strnlen+0x30>
  800c13:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  800c18:	c9                   	leave  
  800c19:	c3                   	ret    

00800c1a <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800c1a:	55                   	push   %ebp
  800c1b:	89 e5                	mov    %esp,%ebp
  800c1d:	53                   	push   %ebx
  800c1e:	8b 45 08             	mov    0x8(%ebp),%eax
  800c21:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800c24:	ba 00 00 00 00       	mov    $0x0,%edx
  800c29:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  800c2c:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800c2f:	42                   	inc    %edx
  800c30:	84 c9                	test   %cl,%cl
  800c32:	75 f5                	jne    800c29 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800c34:	5b                   	pop    %ebx
  800c35:	c9                   	leave  
  800c36:	c3                   	ret    

00800c37 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800c37:	55                   	push   %ebp
  800c38:	89 e5                	mov    %esp,%ebp
  800c3a:	53                   	push   %ebx
  800c3b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800c3e:	53                   	push   %ebx
  800c3f:	e8 84 ff ff ff       	call   800bc8 <strlen>
  800c44:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800c47:	ff 75 0c             	pushl  0xc(%ebp)
  800c4a:	8d 04 03             	lea    (%ebx,%eax,1),%eax
  800c4d:	50                   	push   %eax
  800c4e:	e8 c7 ff ff ff       	call   800c1a <strcpy>
	return dst;
}
  800c53:	89 d8                	mov    %ebx,%eax
  800c55:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800c58:	c9                   	leave  
  800c59:	c3                   	ret    

00800c5a <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800c5a:	55                   	push   %ebp
  800c5b:	89 e5                	mov    %esp,%ebp
  800c5d:	56                   	push   %esi
  800c5e:	53                   	push   %ebx
  800c5f:	8b 45 08             	mov    0x8(%ebp),%eax
  800c62:	8b 55 0c             	mov    0xc(%ebp),%edx
  800c65:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800c68:	85 f6                	test   %esi,%esi
  800c6a:	74 15                	je     800c81 <strncpy+0x27>
  800c6c:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
  800c71:	8a 1a                	mov    (%edx),%bl
  800c73:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800c76:	80 3a 01             	cmpb   $0x1,(%edx)
  800c79:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800c7c:	41                   	inc    %ecx
  800c7d:	39 ce                	cmp    %ecx,%esi
  800c7f:	77 f0                	ja     800c71 <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800c81:	5b                   	pop    %ebx
  800c82:	5e                   	pop    %esi
  800c83:	c9                   	leave  
  800c84:	c3                   	ret    

00800c85 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800c85:	55                   	push   %ebp
  800c86:	89 e5                	mov    %esp,%ebp
  800c88:	57                   	push   %edi
  800c89:	56                   	push   %esi
  800c8a:	53                   	push   %ebx
  800c8b:	8b 7d 08             	mov    0x8(%ebp),%edi
  800c8e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800c91:	8b 75 10             	mov    0x10(%ebp),%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800c94:	85 f6                	test   %esi,%esi
  800c96:	74 32                	je     800cca <strlcpy+0x45>
		while (--size > 0 && *src != '\0')
  800c98:	83 fe 01             	cmp    $0x1,%esi
  800c9b:	74 22                	je     800cbf <strlcpy+0x3a>
  800c9d:	8a 0b                	mov    (%ebx),%cl
  800c9f:	84 c9                	test   %cl,%cl
  800ca1:	74 20                	je     800cc3 <strlcpy+0x3e>
  800ca3:	89 f8                	mov    %edi,%eax
  800ca5:	ba 00 00 00 00       	mov    $0x0,%edx
	}
	return ret;
}

size_t
strlcpy(char *dst, const char *src, size_t size)
  800caa:	83 ee 02             	sub    $0x2,%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800cad:	88 08                	mov    %cl,(%eax)
  800caf:	40                   	inc    %eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800cb0:	39 f2                	cmp    %esi,%edx
  800cb2:	74 11                	je     800cc5 <strlcpy+0x40>
  800cb4:	8a 4c 13 01          	mov    0x1(%ebx,%edx,1),%cl
  800cb8:	42                   	inc    %edx
  800cb9:	84 c9                	test   %cl,%cl
  800cbb:	75 f0                	jne    800cad <strlcpy+0x28>
  800cbd:	eb 06                	jmp    800cc5 <strlcpy+0x40>
  800cbf:	89 f8                	mov    %edi,%eax
  800cc1:	eb 02                	jmp    800cc5 <strlcpy+0x40>
  800cc3:	89 f8                	mov    %edi,%eax
			*dst++ = *src++;
		*dst = '\0';
  800cc5:	c6 00 00             	movb   $0x0,(%eax)
  800cc8:	eb 02                	jmp    800ccc <strlcpy+0x47>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800cca:	89 f8                	mov    %edi,%eax
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
		*dst = '\0';
	}
	return dst - dst_in;
  800ccc:	29 f8                	sub    %edi,%eax
}
  800cce:	5b                   	pop    %ebx
  800ccf:	5e                   	pop    %esi
  800cd0:	5f                   	pop    %edi
  800cd1:	c9                   	leave  
  800cd2:	c3                   	ret    

00800cd3 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800cd3:	55                   	push   %ebp
  800cd4:	89 e5                	mov    %esp,%ebp
  800cd6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800cd9:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800cdc:	8a 01                	mov    (%ecx),%al
  800cde:	84 c0                	test   %al,%al
  800ce0:	74 10                	je     800cf2 <strcmp+0x1f>
  800ce2:	3a 02                	cmp    (%edx),%al
  800ce4:	75 0c                	jne    800cf2 <strcmp+0x1f>
		p++, q++;
  800ce6:	41                   	inc    %ecx
  800ce7:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800ce8:	8a 01                	mov    (%ecx),%al
  800cea:	84 c0                	test   %al,%al
  800cec:	74 04                	je     800cf2 <strcmp+0x1f>
  800cee:	3a 02                	cmp    (%edx),%al
  800cf0:	74 f4                	je     800ce6 <strcmp+0x13>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800cf2:	0f b6 c0             	movzbl %al,%eax
  800cf5:	0f b6 12             	movzbl (%edx),%edx
  800cf8:	29 d0                	sub    %edx,%eax
}
  800cfa:	c9                   	leave  
  800cfb:	c3                   	ret    

00800cfc <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800cfc:	55                   	push   %ebp
  800cfd:	89 e5                	mov    %esp,%ebp
  800cff:	53                   	push   %ebx
  800d00:	8b 55 08             	mov    0x8(%ebp),%edx
  800d03:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d06:	8b 45 10             	mov    0x10(%ebp),%eax
	while (n > 0 && *p && *p == *q)
  800d09:	85 c0                	test   %eax,%eax
  800d0b:	74 1b                	je     800d28 <strncmp+0x2c>
  800d0d:	8a 1a                	mov    (%edx),%bl
  800d0f:	84 db                	test   %bl,%bl
  800d11:	74 24                	je     800d37 <strncmp+0x3b>
  800d13:	3a 19                	cmp    (%ecx),%bl
  800d15:	75 20                	jne    800d37 <strncmp+0x3b>
  800d17:	48                   	dec    %eax
  800d18:	74 15                	je     800d2f <strncmp+0x33>
		n--, p++, q++;
  800d1a:	42                   	inc    %edx
  800d1b:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800d1c:	8a 1a                	mov    (%edx),%bl
  800d1e:	84 db                	test   %bl,%bl
  800d20:	74 15                	je     800d37 <strncmp+0x3b>
  800d22:	3a 19                	cmp    (%ecx),%bl
  800d24:	74 f1                	je     800d17 <strncmp+0x1b>
  800d26:	eb 0f                	jmp    800d37 <strncmp+0x3b>
		n--, p++, q++;
	if (n == 0)
		return 0;
  800d28:	b8 00 00 00 00       	mov    $0x0,%eax
  800d2d:	eb 05                	jmp    800d34 <strncmp+0x38>
  800d2f:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800d34:	5b                   	pop    %ebx
  800d35:	c9                   	leave  
  800d36:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800d37:	0f b6 02             	movzbl (%edx),%eax
  800d3a:	0f b6 11             	movzbl (%ecx),%edx
  800d3d:	29 d0                	sub    %edx,%eax
  800d3f:	eb f3                	jmp    800d34 <strncmp+0x38>

00800d41 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800d41:	55                   	push   %ebp
  800d42:	89 e5                	mov    %esp,%ebp
  800d44:	8b 45 08             	mov    0x8(%ebp),%eax
  800d47:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800d4a:	8a 10                	mov    (%eax),%dl
  800d4c:	84 d2                	test   %dl,%dl
  800d4e:	74 18                	je     800d68 <strchr+0x27>
		if (*s == c)
  800d50:	38 ca                	cmp    %cl,%dl
  800d52:	75 06                	jne    800d5a <strchr+0x19>
  800d54:	eb 17                	jmp    800d6d <strchr+0x2c>
  800d56:	38 ca                	cmp    %cl,%dl
  800d58:	74 13                	je     800d6d <strchr+0x2c>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800d5a:	40                   	inc    %eax
  800d5b:	8a 10                	mov    (%eax),%dl
  800d5d:	84 d2                	test   %dl,%dl
  800d5f:	75 f5                	jne    800d56 <strchr+0x15>
		if (*s == c)
			return (char *) s;
	return 0;
  800d61:	b8 00 00 00 00       	mov    $0x0,%eax
  800d66:	eb 05                	jmp    800d6d <strchr+0x2c>
  800d68:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800d6d:	c9                   	leave  
  800d6e:	c3                   	ret    

00800d6f <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800d6f:	55                   	push   %ebp
  800d70:	89 e5                	mov    %esp,%ebp
  800d72:	8b 45 08             	mov    0x8(%ebp),%eax
  800d75:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800d78:	8a 10                	mov    (%eax),%dl
  800d7a:	84 d2                	test   %dl,%dl
  800d7c:	74 11                	je     800d8f <strfind+0x20>
		if (*s == c)
  800d7e:	38 ca                	cmp    %cl,%dl
  800d80:	75 06                	jne    800d88 <strfind+0x19>
  800d82:	eb 0b                	jmp    800d8f <strfind+0x20>
  800d84:	38 ca                	cmp    %cl,%dl
  800d86:	74 07                	je     800d8f <strfind+0x20>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800d88:	40                   	inc    %eax
  800d89:	8a 10                	mov    (%eax),%dl
  800d8b:	84 d2                	test   %dl,%dl
  800d8d:	75 f5                	jne    800d84 <strfind+0x15>
		if (*s == c)
			break;
	return (char *) s;
}
  800d8f:	c9                   	leave  
  800d90:	c3                   	ret    

00800d91 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800d91:	55                   	push   %ebp
  800d92:	89 e5                	mov    %esp,%ebp
  800d94:	57                   	push   %edi
  800d95:	56                   	push   %esi
  800d96:	53                   	push   %ebx
  800d97:	8b 7d 08             	mov    0x8(%ebp),%edi
  800d9a:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d9d:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800da0:	85 c9                	test   %ecx,%ecx
  800da2:	74 30                	je     800dd4 <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800da4:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800daa:	75 25                	jne    800dd1 <memset+0x40>
  800dac:	f6 c1 03             	test   $0x3,%cl
  800daf:	75 20                	jne    800dd1 <memset+0x40>
		c &= 0xFF;
  800db1:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800db4:	89 d3                	mov    %edx,%ebx
  800db6:	c1 e3 08             	shl    $0x8,%ebx
  800db9:	89 d6                	mov    %edx,%esi
  800dbb:	c1 e6 18             	shl    $0x18,%esi
  800dbe:	89 d0                	mov    %edx,%eax
  800dc0:	c1 e0 10             	shl    $0x10,%eax
  800dc3:	09 f0                	or     %esi,%eax
  800dc5:	09 d0                	or     %edx,%eax
  800dc7:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800dc9:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800dcc:	fc                   	cld    
  800dcd:	f3 ab                	rep stos %eax,%es:(%edi)
  800dcf:	eb 03                	jmp    800dd4 <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800dd1:	fc                   	cld    
  800dd2:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800dd4:	89 f8                	mov    %edi,%eax
  800dd6:	5b                   	pop    %ebx
  800dd7:	5e                   	pop    %esi
  800dd8:	5f                   	pop    %edi
  800dd9:	c9                   	leave  
  800dda:	c3                   	ret    

00800ddb <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800ddb:	55                   	push   %ebp
  800ddc:	89 e5                	mov    %esp,%ebp
  800dde:	57                   	push   %edi
  800ddf:	56                   	push   %esi
  800de0:	8b 45 08             	mov    0x8(%ebp),%eax
  800de3:	8b 75 0c             	mov    0xc(%ebp),%esi
  800de6:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800de9:	39 c6                	cmp    %eax,%esi
  800deb:	73 34                	jae    800e21 <memmove+0x46>
  800ded:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800df0:	39 d0                	cmp    %edx,%eax
  800df2:	73 2d                	jae    800e21 <memmove+0x46>
		s += n;
		d += n;
  800df4:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800df7:	f6 c2 03             	test   $0x3,%dl
  800dfa:	75 1b                	jne    800e17 <memmove+0x3c>
  800dfc:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800e02:	75 13                	jne    800e17 <memmove+0x3c>
  800e04:	f6 c1 03             	test   $0x3,%cl
  800e07:	75 0e                	jne    800e17 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800e09:	83 ef 04             	sub    $0x4,%edi
  800e0c:	8d 72 fc             	lea    -0x4(%edx),%esi
  800e0f:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800e12:	fd                   	std    
  800e13:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800e15:	eb 07                	jmp    800e1e <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800e17:	4f                   	dec    %edi
  800e18:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800e1b:	fd                   	std    
  800e1c:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800e1e:	fc                   	cld    
  800e1f:	eb 20                	jmp    800e41 <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800e21:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800e27:	75 13                	jne    800e3c <memmove+0x61>
  800e29:	a8 03                	test   $0x3,%al
  800e2b:	75 0f                	jne    800e3c <memmove+0x61>
  800e2d:	f6 c1 03             	test   $0x3,%cl
  800e30:	75 0a                	jne    800e3c <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800e32:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800e35:	89 c7                	mov    %eax,%edi
  800e37:	fc                   	cld    
  800e38:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800e3a:	eb 05                	jmp    800e41 <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800e3c:	89 c7                	mov    %eax,%edi
  800e3e:	fc                   	cld    
  800e3f:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800e41:	5e                   	pop    %esi
  800e42:	5f                   	pop    %edi
  800e43:	c9                   	leave  
  800e44:	c3                   	ret    

00800e45 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800e45:	55                   	push   %ebp
  800e46:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800e48:	ff 75 10             	pushl  0x10(%ebp)
  800e4b:	ff 75 0c             	pushl  0xc(%ebp)
  800e4e:	ff 75 08             	pushl  0x8(%ebp)
  800e51:	e8 85 ff ff ff       	call   800ddb <memmove>
}
  800e56:	c9                   	leave  
  800e57:	c3                   	ret    

00800e58 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800e58:	55                   	push   %ebp
  800e59:	89 e5                	mov    %esp,%ebp
  800e5b:	57                   	push   %edi
  800e5c:	56                   	push   %esi
  800e5d:	53                   	push   %ebx
  800e5e:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800e61:	8b 75 0c             	mov    0xc(%ebp),%esi
  800e64:	8b 7d 10             	mov    0x10(%ebp),%edi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800e67:	85 ff                	test   %edi,%edi
  800e69:	74 32                	je     800e9d <memcmp+0x45>
		if (*s1 != *s2)
  800e6b:	8a 03                	mov    (%ebx),%al
  800e6d:	8a 0e                	mov    (%esi),%cl
  800e6f:	38 c8                	cmp    %cl,%al
  800e71:	74 19                	je     800e8c <memcmp+0x34>
  800e73:	eb 0d                	jmp    800e82 <memcmp+0x2a>
  800e75:	8a 44 13 01          	mov    0x1(%ebx,%edx,1),%al
  800e79:	8a 4c 16 01          	mov    0x1(%esi,%edx,1),%cl
  800e7d:	42                   	inc    %edx
  800e7e:	38 c8                	cmp    %cl,%al
  800e80:	74 10                	je     800e92 <memcmp+0x3a>
			return (int) *s1 - (int) *s2;
  800e82:	0f b6 c0             	movzbl %al,%eax
  800e85:	0f b6 c9             	movzbl %cl,%ecx
  800e88:	29 c8                	sub    %ecx,%eax
  800e8a:	eb 16                	jmp    800ea2 <memcmp+0x4a>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800e8c:	4f                   	dec    %edi
  800e8d:	ba 00 00 00 00       	mov    $0x0,%edx
  800e92:	39 fa                	cmp    %edi,%edx
  800e94:	75 df                	jne    800e75 <memcmp+0x1d>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800e96:	b8 00 00 00 00       	mov    $0x0,%eax
  800e9b:	eb 05                	jmp    800ea2 <memcmp+0x4a>
  800e9d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800ea2:	5b                   	pop    %ebx
  800ea3:	5e                   	pop    %esi
  800ea4:	5f                   	pop    %edi
  800ea5:	c9                   	leave  
  800ea6:	c3                   	ret    

00800ea7 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800ea7:	55                   	push   %ebp
  800ea8:	89 e5                	mov    %esp,%ebp
  800eaa:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800ead:	89 c2                	mov    %eax,%edx
  800eaf:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800eb2:	39 d0                	cmp    %edx,%eax
  800eb4:	73 12                	jae    800ec8 <memfind+0x21>
		if (*(const unsigned char *) s == (unsigned char) c)
  800eb6:	8a 4d 0c             	mov    0xc(%ebp),%cl
  800eb9:	38 08                	cmp    %cl,(%eax)
  800ebb:	75 06                	jne    800ec3 <memfind+0x1c>
  800ebd:	eb 09                	jmp    800ec8 <memfind+0x21>
  800ebf:	38 08                	cmp    %cl,(%eax)
  800ec1:	74 05                	je     800ec8 <memfind+0x21>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800ec3:	40                   	inc    %eax
  800ec4:	39 c2                	cmp    %eax,%edx
  800ec6:	77 f7                	ja     800ebf <memfind+0x18>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800ec8:	c9                   	leave  
  800ec9:	c3                   	ret    

00800eca <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800eca:	55                   	push   %ebp
  800ecb:	89 e5                	mov    %esp,%ebp
  800ecd:	57                   	push   %edi
  800ece:	56                   	push   %esi
  800ecf:	53                   	push   %ebx
  800ed0:	8b 55 08             	mov    0x8(%ebp),%edx
  800ed3:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800ed6:	eb 01                	jmp    800ed9 <strtol+0xf>
		s++;
  800ed8:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800ed9:	8a 02                	mov    (%edx),%al
  800edb:	3c 20                	cmp    $0x20,%al
  800edd:	74 f9                	je     800ed8 <strtol+0xe>
  800edf:	3c 09                	cmp    $0x9,%al
  800ee1:	74 f5                	je     800ed8 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800ee3:	3c 2b                	cmp    $0x2b,%al
  800ee5:	75 08                	jne    800eef <strtol+0x25>
		s++;
  800ee7:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800ee8:	bf 00 00 00 00       	mov    $0x0,%edi
  800eed:	eb 13                	jmp    800f02 <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800eef:	3c 2d                	cmp    $0x2d,%al
  800ef1:	75 0a                	jne    800efd <strtol+0x33>
		s++, neg = 1;
  800ef3:	8d 52 01             	lea    0x1(%edx),%edx
  800ef6:	bf 01 00 00 00       	mov    $0x1,%edi
  800efb:	eb 05                	jmp    800f02 <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800efd:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800f02:	85 db                	test   %ebx,%ebx
  800f04:	74 05                	je     800f0b <strtol+0x41>
  800f06:	83 fb 10             	cmp    $0x10,%ebx
  800f09:	75 28                	jne    800f33 <strtol+0x69>
  800f0b:	8a 02                	mov    (%edx),%al
  800f0d:	3c 30                	cmp    $0x30,%al
  800f0f:	75 10                	jne    800f21 <strtol+0x57>
  800f11:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800f15:	75 0a                	jne    800f21 <strtol+0x57>
		s += 2, base = 16;
  800f17:	83 c2 02             	add    $0x2,%edx
  800f1a:	bb 10 00 00 00       	mov    $0x10,%ebx
  800f1f:	eb 12                	jmp    800f33 <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  800f21:	85 db                	test   %ebx,%ebx
  800f23:	75 0e                	jne    800f33 <strtol+0x69>
  800f25:	3c 30                	cmp    $0x30,%al
  800f27:	75 05                	jne    800f2e <strtol+0x64>
		s++, base = 8;
  800f29:	42                   	inc    %edx
  800f2a:	b3 08                	mov    $0x8,%bl
  800f2c:	eb 05                	jmp    800f33 <strtol+0x69>
	else if (base == 0)
		base = 10;
  800f2e:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800f33:	b8 00 00 00 00       	mov    $0x0,%eax
  800f38:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800f3a:	8a 0a                	mov    (%edx),%cl
  800f3c:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800f3f:	80 fb 09             	cmp    $0x9,%bl
  800f42:	77 08                	ja     800f4c <strtol+0x82>
			dig = *s - '0';
  800f44:	0f be c9             	movsbl %cl,%ecx
  800f47:	83 e9 30             	sub    $0x30,%ecx
  800f4a:	eb 1e                	jmp    800f6a <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  800f4c:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800f4f:	80 fb 19             	cmp    $0x19,%bl
  800f52:	77 08                	ja     800f5c <strtol+0x92>
			dig = *s - 'a' + 10;
  800f54:	0f be c9             	movsbl %cl,%ecx
  800f57:	83 e9 57             	sub    $0x57,%ecx
  800f5a:	eb 0e                	jmp    800f6a <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  800f5c:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800f5f:	80 fb 19             	cmp    $0x19,%bl
  800f62:	77 13                	ja     800f77 <strtol+0xad>
			dig = *s - 'A' + 10;
  800f64:	0f be c9             	movsbl %cl,%ecx
  800f67:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800f6a:	39 f1                	cmp    %esi,%ecx
  800f6c:	7d 0d                	jge    800f7b <strtol+0xb1>
			break;
		s++, val = (val * base) + dig;
  800f6e:	42                   	inc    %edx
  800f6f:	0f af c6             	imul   %esi,%eax
  800f72:	8d 04 01             	lea    (%ecx,%eax,1),%eax
		// we don't properly detect overflow!
	}
  800f75:	eb c3                	jmp    800f3a <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800f77:	89 c1                	mov    %eax,%ecx
  800f79:	eb 02                	jmp    800f7d <strtol+0xb3>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800f7b:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800f7d:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800f81:	74 05                	je     800f88 <strtol+0xbe>
		*endptr = (char *) s;
  800f83:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800f86:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800f88:	85 ff                	test   %edi,%edi
  800f8a:	74 04                	je     800f90 <strtol+0xc6>
  800f8c:	89 c8                	mov    %ecx,%eax
  800f8e:	f7 d8                	neg    %eax
}
  800f90:	5b                   	pop    %ebx
  800f91:	5e                   	pop    %esi
  800f92:	5f                   	pop    %edi
  800f93:	c9                   	leave  
  800f94:	c3                   	ret    
  800f95:	00 00                	add    %al,(%eax)
	...

00800f98 <syscall>:
	return ret;
}

static int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  800f98:	55                   	push   %ebp
  800f99:	89 e5                	mov    %esp,%ebp
  800f9b:	57                   	push   %edi
  800f9c:	56                   	push   %esi
  800f9d:	53                   	push   %ebx
  800f9e:	83 ec 1c             	sub    $0x1c,%esp
  800fa1:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800fa4:	89 55 e0             	mov    %edx,-0x20(%ebp)
  800fa7:	89 ca                	mov    %ecx,%edx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800fa9:	8b 75 14             	mov    0x14(%ebp),%esi
  800fac:	8b 7d 10             	mov    0x10(%ebp),%edi
  800faf:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800fb2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800fb5:	cd 30                	int    $0x30
  800fb7:	89 c2                	mov    %eax,%edx
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800fb9:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800fbd:	74 1c                	je     800fdb <syscall+0x43>
  800fbf:	85 c0                	test   %eax,%eax
  800fc1:	7e 18                	jle    800fdb <syscall+0x43>
		panic("syscall %d returned %d (> 0)", num, ret);
  800fc3:	83 ec 0c             	sub    $0xc,%esp
  800fc6:	50                   	push   %eax
  800fc7:	ff 75 e4             	pushl  -0x1c(%ebp)
  800fca:	68 1f 27 80 00       	push   $0x80271f
  800fcf:	6a 42                	push   $0x42
  800fd1:	68 3c 27 80 00       	push   $0x80273c
  800fd6:	e8 b1 f5 ff ff       	call   80058c <_panic>

	return ret;
}
  800fdb:	89 d0                	mov    %edx,%eax
  800fdd:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800fe0:	5b                   	pop    %ebx
  800fe1:	5e                   	pop    %esi
  800fe2:	5f                   	pop    %edi
  800fe3:	c9                   	leave  
  800fe4:	c3                   	ret    

00800fe5 <sys_cputs>:

void
sys_cputs(const char *s, size_t len)
{	
  800fe5:	55                   	push   %ebp
  800fe6:	89 e5                	mov    %esp,%ebp
  800fe8:	83 ec 08             	sub    $0x8,%esp
	// my_sysenter(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
	// return;
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
  800feb:	6a 00                	push   $0x0
  800fed:	6a 00                	push   $0x0
  800fef:	6a 00                	push   $0x0
  800ff1:	ff 75 0c             	pushl  0xc(%ebp)
  800ff4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ff7:	ba 00 00 00 00       	mov    $0x0,%edx
  800ffc:	b8 00 00 00 00       	mov    $0x0,%eax
  801001:	e8 92 ff ff ff       	call   800f98 <syscall>
  801006:	83 c4 10             	add    $0x10,%esp
	return;
}
  801009:	c9                   	leave  
  80100a:	c3                   	ret    

0080100b <sys_cgetc>:

int
sys_cgetc(void)
{
  80100b:	55                   	push   %ebp
  80100c:	89 e5                	mov    %esp,%ebp
  80100e:	83 ec 08             	sub    $0x8,%esp
	// return my_sysenter(SYS_cgetc, 0, 0, 0, 0, 0, 0);
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
  801011:	6a 00                	push   $0x0
  801013:	6a 00                	push   $0x0
  801015:	6a 00                	push   $0x0
  801017:	6a 00                	push   $0x0
  801019:	b9 00 00 00 00       	mov    $0x0,%ecx
  80101e:	ba 00 00 00 00       	mov    $0x0,%edx
  801023:	b8 01 00 00 00       	mov    $0x1,%eax
  801028:	e8 6b ff ff ff       	call   800f98 <syscall>
}
  80102d:	c9                   	leave  
  80102e:	c3                   	ret    

0080102f <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  80102f:	55                   	push   %ebp
  801030:	89 e5                	mov    %esp,%ebp
  801032:	83 ec 08             	sub    $0x8,%esp
	// return my_sysenter(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
  801035:	6a 00                	push   $0x0
  801037:	6a 00                	push   $0x0
  801039:	6a 00                	push   $0x0
  80103b:	6a 00                	push   $0x0
  80103d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801040:	ba 01 00 00 00       	mov    $0x1,%edx
  801045:	b8 03 00 00 00       	mov    $0x3,%eax
  80104a:	e8 49 ff ff ff       	call   800f98 <syscall>
}
  80104f:	c9                   	leave  
  801050:	c3                   	ret    

00801051 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  801051:	55                   	push   %ebp
  801052:	89 e5                	mov    %esp,%ebp
  801054:	83 ec 08             	sub    $0x8,%esp
	// return my_sysenter(SYS_getenvid, 0, 0, 0, 0, 0, 0);
	return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
  801057:	6a 00                	push   $0x0
  801059:	6a 00                	push   $0x0
  80105b:	6a 00                	push   $0x0
  80105d:	6a 00                	push   $0x0
  80105f:	b9 00 00 00 00       	mov    $0x0,%ecx
  801064:	ba 00 00 00 00       	mov    $0x0,%edx
  801069:	b8 02 00 00 00       	mov    $0x2,%eax
  80106e:	e8 25 ff ff ff       	call   800f98 <syscall>
}
  801073:	c9                   	leave  
  801074:	c3                   	ret    

00801075 <sys_yield>:

void
sys_yield(void)
{
  801075:	55                   	push   %ebp
  801076:	89 e5                	mov    %esp,%ebp
  801078:	83 ec 08             	sub    $0x8,%esp
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
  80107b:	6a 00                	push   $0x0
  80107d:	6a 00                	push   $0x0
  80107f:	6a 00                	push   $0x0
  801081:	6a 00                	push   $0x0
  801083:	b9 00 00 00 00       	mov    $0x0,%ecx
  801088:	ba 00 00 00 00       	mov    $0x0,%edx
  80108d:	b8 0b 00 00 00       	mov    $0xb,%eax
  801092:	e8 01 ff ff ff       	call   800f98 <syscall>
  801097:	83 c4 10             	add    $0x10,%esp
}
  80109a:	c9                   	leave  
  80109b:	c3                   	ret    

0080109c <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  80109c:	55                   	push   %ebp
  80109d:	89 e5                	mov    %esp,%ebp
  80109f:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
  8010a2:	6a 00                	push   $0x0
  8010a4:	6a 00                	push   $0x0
  8010a6:	ff 75 10             	pushl  0x10(%ebp)
  8010a9:	ff 75 0c             	pushl  0xc(%ebp)
  8010ac:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8010af:	ba 01 00 00 00       	mov    $0x1,%edx
  8010b4:	b8 04 00 00 00       	mov    $0x4,%eax
  8010b9:	e8 da fe ff ff       	call   800f98 <syscall>
}
  8010be:	c9                   	leave  
  8010bf:	c3                   	ret    

008010c0 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8010c0:	55                   	push   %ebp
  8010c1:	89 e5                	mov    %esp,%ebp
  8010c3:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
  8010c6:	ff 75 18             	pushl  0x18(%ebp)
  8010c9:	ff 75 14             	pushl  0x14(%ebp)
  8010cc:	ff 75 10             	pushl  0x10(%ebp)
  8010cf:	ff 75 0c             	pushl  0xc(%ebp)
  8010d2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8010d5:	ba 01 00 00 00       	mov    $0x1,%edx
  8010da:	b8 05 00 00 00       	mov    $0x5,%eax
  8010df:	e8 b4 fe ff ff       	call   800f98 <syscall>
}
  8010e4:	c9                   	leave  
  8010e5:	c3                   	ret    

008010e6 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  8010e6:	55                   	push   %ebp
  8010e7:	89 e5                	mov    %esp,%ebp
  8010e9:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
  8010ec:	6a 00                	push   $0x0
  8010ee:	6a 00                	push   $0x0
  8010f0:	6a 00                	push   $0x0
  8010f2:	ff 75 0c             	pushl  0xc(%ebp)
  8010f5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8010f8:	ba 01 00 00 00       	mov    $0x1,%edx
  8010fd:	b8 06 00 00 00       	mov    $0x6,%eax
  801102:	e8 91 fe ff ff       	call   800f98 <syscall>
}
  801107:	c9                   	leave  
  801108:	c3                   	ret    

00801109 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  801109:	55                   	push   %ebp
  80110a:	89 e5                	mov    %esp,%ebp
  80110c:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
  80110f:	6a 00                	push   $0x0
  801111:	6a 00                	push   $0x0
  801113:	6a 00                	push   $0x0
  801115:	ff 75 0c             	pushl  0xc(%ebp)
  801118:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80111b:	ba 01 00 00 00       	mov    $0x1,%edx
  801120:	b8 08 00 00 00       	mov    $0x8,%eax
  801125:	e8 6e fe ff ff       	call   800f98 <syscall>
}
  80112a:	c9                   	leave  
  80112b:	c3                   	ret    

0080112c <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  80112c:	55                   	push   %ebp
  80112d:	89 e5                	mov    %esp,%ebp
  80112f:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
  801132:	6a 00                	push   $0x0
  801134:	6a 00                	push   $0x0
  801136:	6a 00                	push   $0x0
  801138:	ff 75 0c             	pushl  0xc(%ebp)
  80113b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80113e:	ba 01 00 00 00       	mov    $0x1,%edx
  801143:	b8 09 00 00 00       	mov    $0x9,%eax
  801148:	e8 4b fe ff ff       	call   800f98 <syscall>
}
  80114d:	c9                   	leave  
  80114e:	c3                   	ret    

0080114f <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  80114f:	55                   	push   %ebp
  801150:	89 e5                	mov    %esp,%ebp
  801152:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
  801155:	6a 00                	push   $0x0
  801157:	6a 00                	push   $0x0
  801159:	6a 00                	push   $0x0
  80115b:	ff 75 0c             	pushl  0xc(%ebp)
  80115e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801161:	ba 01 00 00 00       	mov    $0x1,%edx
  801166:	b8 0a 00 00 00       	mov    $0xa,%eax
  80116b:	e8 28 fe ff ff       	call   800f98 <syscall>
}
  801170:	c9                   	leave  
  801171:	c3                   	ret    

00801172 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  801172:	55                   	push   %ebp
  801173:	89 e5                	mov    %esp,%ebp
  801175:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
  801178:	6a 00                	push   $0x0
  80117a:	ff 75 14             	pushl  0x14(%ebp)
  80117d:	ff 75 10             	pushl  0x10(%ebp)
  801180:	ff 75 0c             	pushl  0xc(%ebp)
  801183:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801186:	ba 00 00 00 00       	mov    $0x0,%edx
  80118b:	b8 0c 00 00 00       	mov    $0xc,%eax
  801190:	e8 03 fe ff ff       	call   800f98 <syscall>
}
  801195:	c9                   	leave  
  801196:	c3                   	ret    

00801197 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  801197:	55                   	push   %ebp
  801198:	89 e5                	mov    %esp,%ebp
  80119a:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
  80119d:	6a 00                	push   $0x0
  80119f:	6a 00                	push   $0x0
  8011a1:	6a 00                	push   $0x0
  8011a3:	6a 00                	push   $0x0
  8011a5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8011a8:	ba 01 00 00 00       	mov    $0x1,%edx
  8011ad:	b8 0d 00 00 00       	mov    $0xd,%eax
  8011b2:	e8 e1 fd ff ff       	call   800f98 <syscall>
}
  8011b7:	c9                   	leave  
  8011b8:	c3                   	ret    

008011b9 <sys_set_priority>:

int
sys_set_priority(envid_t envid, uint32_t new_priority)
{
  8011b9:	55                   	push   %ebp
  8011ba:	89 e5                	mov    %esp,%ebp
  8011bc:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_set_priority, 0, envid, new_priority, 0, 0, 0);
  8011bf:	6a 00                	push   $0x0
  8011c1:	6a 00                	push   $0x0
  8011c3:	6a 00                	push   $0x0
  8011c5:	ff 75 0c             	pushl  0xc(%ebp)
  8011c8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8011cb:	ba 00 00 00 00       	mov    $0x0,%edx
  8011d0:	b8 0e 00 00 00       	mov    $0xe,%eax
  8011d5:	e8 be fd ff ff       	call   800f98 <syscall>
}
  8011da:	c9                   	leave  
  8011db:	c3                   	ret    

008011dc <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  8011dc:	55                   	push   %ebp
  8011dd:	89 e5                	mov    %esp,%ebp
  8011df:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  8011e2:	83 3d b4 40 80 00 00 	cmpl   $0x0,0x8040b4
  8011e9:	75 52                	jne    80123d <set_pgfault_handler+0x61>
		// First time through!	
		// LAB 4: Your code here.

		//int sys_page_alloc(envid_t envid, void *va, int perm)
		r = sys_page_alloc(0, (void*)(UXSTACKTOP - PGSIZE), PTE_U | PTE_W | PTE_P);
  8011eb:	83 ec 04             	sub    $0x4,%esp
  8011ee:	6a 07                	push   $0x7
  8011f0:	68 00 f0 bf ee       	push   $0xeebff000
  8011f5:	6a 00                	push   $0x0
  8011f7:	e8 a0 fe ff ff       	call   80109c <sys_page_alloc>
		if (r < 0) {
  8011fc:	83 c4 10             	add    $0x10,%esp
  8011ff:	85 c0                	test   %eax,%eax
  801201:	79 12                	jns    801215 <set_pgfault_handler+0x39>
			panic("sys_page_alloc error : %e\n", r);
  801203:	50                   	push   %eax
  801204:	68 4a 27 80 00       	push   $0x80274a
  801209:	6a 24                	push   $0x24
  80120b:	68 65 27 80 00       	push   $0x802765
  801210:	e8 77 f3 ff ff       	call   80058c <_panic>
		}

		// how to know envid, put 0, envid2env will help us to get curenv in syscall
		r = sys_env_set_pgfault_upcall(0, _pgfault_upcall);		
  801215:	83 ec 08             	sub    $0x8,%esp
  801218:	68 48 12 80 00       	push   $0x801248
  80121d:	6a 00                	push   $0x0
  80121f:	e8 2b ff ff ff       	call   80114f <sys_env_set_pgfault_upcall>
		if (r < 0) {
  801224:	83 c4 10             	add    $0x10,%esp
  801227:	85 c0                	test   %eax,%eax
  801229:	79 12                	jns    80123d <set_pgfault_handler+0x61>
			panic("sys_env_set_pgfault_upcall error : %e\n", r);
  80122b:	50                   	push   %eax
  80122c:	68 74 27 80 00       	push   $0x802774
  801231:	6a 2a                	push   $0x2a
  801233:	68 65 27 80 00       	push   $0x802765
  801238:	e8 4f f3 ff ff       	call   80058c <_panic>
		}
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  80123d:	8b 45 08             	mov    0x8(%ebp),%eax
  801240:	a3 b4 40 80 00       	mov    %eax,0x8040b4
}
  801245:	c9                   	leave  
  801246:	c3                   	ret    
	...

00801248 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  801248:	54                   	push   %esp
	movl _pgfault_handler, %eax
  801249:	a1 b4 40 80 00       	mov    0x8040b4,%eax
	call *%eax
  80124e:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  801250:	83 c4 04             	add    $0x4,%esp
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	
	// fix old esp
	movl 0x30(%esp), %eax
  801253:	8b 44 24 30          	mov    0x30(%esp),%eax
	subl $0x4, %eax
  801257:	83 e8 04             	sub    $0x4,%eax
	movl %eax, 0x30(%esp)
  80125a:	89 44 24 30          	mov    %eax,0x30(%esp)

	// set trap-time %eip
	movl 0x28(%esp), %ebx
  80125e:	8b 5c 24 28          	mov    0x28(%esp),%ebx
	movl %ebx, (%eax)
  801262:	89 18                	mov    %ebx,(%eax)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	addl $0x08, %esp 	// ignore err_code and fault_va
  801264:	83 c4 08             	add    $0x8,%esp
	popal 				// restore registers
  801267:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $0x04, %esp 	// ignore eip 
  801268:	83 c4 04             	add    $0x4,%esp
	popfl				// modify eflags
  80126b:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp
  80126c:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  80126d:	c3                   	ret    
	...

00801270 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801270:	55                   	push   %ebp
  801271:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801273:	8b 45 08             	mov    0x8(%ebp),%eax
  801276:	05 00 00 00 30       	add    $0x30000000,%eax
  80127b:	c1 e8 0c             	shr    $0xc,%eax
}
  80127e:	c9                   	leave  
  80127f:	c3                   	ret    

00801280 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801280:	55                   	push   %ebp
  801281:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  801283:	ff 75 08             	pushl  0x8(%ebp)
  801286:	e8 e5 ff ff ff       	call   801270 <fd2num>
  80128b:	83 c4 04             	add    $0x4,%esp
  80128e:	05 20 00 0d 00       	add    $0xd0020,%eax
  801293:	c1 e0 0c             	shl    $0xc,%eax
}
  801296:	c9                   	leave  
  801297:	c3                   	ret    

00801298 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801298:	55                   	push   %ebp
  801299:	89 e5                	mov    %esp,%ebp
  80129b:	53                   	push   %ebx
  80129c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  80129f:	a1 00 dd 7b ef       	mov    0xef7bdd00,%eax
  8012a4:	a8 01                	test   $0x1,%al
  8012a6:	74 34                	je     8012dc <fd_alloc+0x44>
  8012a8:	a1 00 00 74 ef       	mov    0xef740000,%eax
  8012ad:	a8 01                	test   $0x1,%al
  8012af:	74 32                	je     8012e3 <fd_alloc+0x4b>
  8012b1:	b8 00 10 00 d0       	mov    $0xd0001000,%eax
  8012b6:	89 c1                	mov    %eax,%ecx
  8012b8:	89 c2                	mov    %eax,%edx
  8012ba:	c1 ea 16             	shr    $0x16,%edx
  8012bd:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8012c4:	f6 c2 01             	test   $0x1,%dl
  8012c7:	74 1f                	je     8012e8 <fd_alloc+0x50>
  8012c9:	89 c2                	mov    %eax,%edx
  8012cb:	c1 ea 0c             	shr    $0xc,%edx
  8012ce:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8012d5:	f6 c2 01             	test   $0x1,%dl
  8012d8:	75 17                	jne    8012f1 <fd_alloc+0x59>
  8012da:	eb 0c                	jmp    8012e8 <fd_alloc+0x50>
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  8012dc:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
  8012e1:	eb 05                	jmp    8012e8 <fd_alloc+0x50>
  8012e3:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
  8012e8:	89 0b                	mov    %ecx,(%ebx)
			return 0;
  8012ea:	b8 00 00 00 00       	mov    $0x0,%eax
  8012ef:	eb 17                	jmp    801308 <fd_alloc+0x70>
  8012f1:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8012f6:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8012fb:	75 b9                	jne    8012b6 <fd_alloc+0x1e>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8012fd:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_MAX_OPEN;
  801303:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  801308:	5b                   	pop    %ebx
  801309:	c9                   	leave  
  80130a:	c3                   	ret    

0080130b <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  80130b:	55                   	push   %ebp
  80130c:	89 e5                	mov    %esp,%ebp
  80130e:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801311:	83 f8 1f             	cmp    $0x1f,%eax
  801314:	77 36                	ja     80134c <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801316:	05 00 00 0d 00       	add    $0xd0000,%eax
  80131b:	c1 e0 0c             	shl    $0xc,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  80131e:	89 c2                	mov    %eax,%edx
  801320:	c1 ea 16             	shr    $0x16,%edx
  801323:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80132a:	f6 c2 01             	test   $0x1,%dl
  80132d:	74 24                	je     801353 <fd_lookup+0x48>
  80132f:	89 c2                	mov    %eax,%edx
  801331:	c1 ea 0c             	shr    $0xc,%edx
  801334:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80133b:	f6 c2 01             	test   $0x1,%dl
  80133e:	74 1a                	je     80135a <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  801340:	8b 55 0c             	mov    0xc(%ebp),%edx
  801343:	89 02                	mov    %eax,(%edx)
	return 0;
  801345:	b8 00 00 00 00       	mov    $0x0,%eax
  80134a:	eb 13                	jmp    80135f <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80134c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801351:	eb 0c                	jmp    80135f <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801353:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801358:	eb 05                	jmp    80135f <fd_lookup+0x54>
  80135a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  80135f:	c9                   	leave  
  801360:	c3                   	ret    

00801361 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801361:	55                   	push   %ebp
  801362:	89 e5                	mov    %esp,%ebp
  801364:	53                   	push   %ebx
  801365:	83 ec 04             	sub    $0x4,%esp
  801368:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80136b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
		if (devtab[i]->dev_id == dev_id) {
  80136e:	39 0d 04 30 80 00    	cmp    %ecx,0x803004
  801374:	74 0d                	je     801383 <dev_lookup+0x22>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801376:	b8 00 00 00 00       	mov    $0x0,%eax
  80137b:	eb 14                	jmp    801391 <dev_lookup+0x30>
		if (devtab[i]->dev_id == dev_id) {
  80137d:	39 0a                	cmp    %ecx,(%edx)
  80137f:	75 10                	jne    801391 <dev_lookup+0x30>
  801381:	eb 05                	jmp    801388 <dev_lookup+0x27>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801383:	ba 04 30 80 00       	mov    $0x803004,%edx
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
  801388:	89 13                	mov    %edx,(%ebx)
			return 0;
  80138a:	b8 00 00 00 00       	mov    $0x0,%eax
  80138f:	eb 31                	jmp    8013c2 <dev_lookup+0x61>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801391:	40                   	inc    %eax
  801392:	8b 14 85 1c 28 80 00 	mov    0x80281c(,%eax,4),%edx
  801399:	85 d2                	test   %edx,%edx
  80139b:	75 e0                	jne    80137d <dev_lookup+0x1c>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  80139d:	a1 b0 40 80 00       	mov    0x8040b0,%eax
  8013a2:	8b 40 48             	mov    0x48(%eax),%eax
  8013a5:	83 ec 04             	sub    $0x4,%esp
  8013a8:	51                   	push   %ecx
  8013a9:	50                   	push   %eax
  8013aa:	68 9c 27 80 00       	push   $0x80279c
  8013af:	e8 b0 f2 ff ff       	call   800664 <cprintf>
	*dev = 0;
  8013b4:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_INVAL;
  8013ba:	83 c4 10             	add    $0x10,%esp
  8013bd:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8013c2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8013c5:	c9                   	leave  
  8013c6:	c3                   	ret    

008013c7 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8013c7:	55                   	push   %ebp
  8013c8:	89 e5                	mov    %esp,%ebp
  8013ca:	56                   	push   %esi
  8013cb:	53                   	push   %ebx
  8013cc:	83 ec 20             	sub    $0x20,%esp
  8013cf:	8b 75 08             	mov    0x8(%ebp),%esi
  8013d2:	8a 45 0c             	mov    0xc(%ebp),%al
  8013d5:	88 45 e7             	mov    %al,-0x19(%ebp)
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8013d8:	56                   	push   %esi
  8013d9:	e8 92 fe ff ff       	call   801270 <fd2num>
  8013de:	8d 55 f4             	lea    -0xc(%ebp),%edx
  8013e1:	89 14 24             	mov    %edx,(%esp)
  8013e4:	50                   	push   %eax
  8013e5:	e8 21 ff ff ff       	call   80130b <fd_lookup>
  8013ea:	89 c3                	mov    %eax,%ebx
  8013ec:	83 c4 08             	add    $0x8,%esp
  8013ef:	85 c0                	test   %eax,%eax
  8013f1:	78 05                	js     8013f8 <fd_close+0x31>
	    || fd != fd2)
  8013f3:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8013f6:	74 0d                	je     801405 <fd_close+0x3e>
		return (must_exist ? r : 0);
  8013f8:	80 7d e7 00          	cmpb   $0x0,-0x19(%ebp)
  8013fc:	75 48                	jne    801446 <fd_close+0x7f>
  8013fe:	bb 00 00 00 00       	mov    $0x0,%ebx
  801403:	eb 41                	jmp    801446 <fd_close+0x7f>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801405:	83 ec 08             	sub    $0x8,%esp
  801408:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80140b:	50                   	push   %eax
  80140c:	ff 36                	pushl  (%esi)
  80140e:	e8 4e ff ff ff       	call   801361 <dev_lookup>
  801413:	89 c3                	mov    %eax,%ebx
  801415:	83 c4 10             	add    $0x10,%esp
  801418:	85 c0                	test   %eax,%eax
  80141a:	78 1c                	js     801438 <fd_close+0x71>
		if (dev->dev_close)
  80141c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80141f:	8b 40 10             	mov    0x10(%eax),%eax
  801422:	85 c0                	test   %eax,%eax
  801424:	74 0d                	je     801433 <fd_close+0x6c>
			r = (*dev->dev_close)(fd);
  801426:	83 ec 0c             	sub    $0xc,%esp
  801429:	56                   	push   %esi
  80142a:	ff d0                	call   *%eax
  80142c:	89 c3                	mov    %eax,%ebx
  80142e:	83 c4 10             	add    $0x10,%esp
  801431:	eb 05                	jmp    801438 <fd_close+0x71>
		else
			r = 0;
  801433:	bb 00 00 00 00       	mov    $0x0,%ebx
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801438:	83 ec 08             	sub    $0x8,%esp
  80143b:	56                   	push   %esi
  80143c:	6a 00                	push   $0x0
  80143e:	e8 a3 fc ff ff       	call   8010e6 <sys_page_unmap>
	return r;
  801443:	83 c4 10             	add    $0x10,%esp
}
  801446:	89 d8                	mov    %ebx,%eax
  801448:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80144b:	5b                   	pop    %ebx
  80144c:	5e                   	pop    %esi
  80144d:	c9                   	leave  
  80144e:	c3                   	ret    

0080144f <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  80144f:	55                   	push   %ebp
  801450:	89 e5                	mov    %esp,%ebp
  801452:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801455:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801458:	50                   	push   %eax
  801459:	ff 75 08             	pushl  0x8(%ebp)
  80145c:	e8 aa fe ff ff       	call   80130b <fd_lookup>
  801461:	83 c4 08             	add    $0x8,%esp
  801464:	85 c0                	test   %eax,%eax
  801466:	78 10                	js     801478 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  801468:	83 ec 08             	sub    $0x8,%esp
  80146b:	6a 01                	push   $0x1
  80146d:	ff 75 f4             	pushl  -0xc(%ebp)
  801470:	e8 52 ff ff ff       	call   8013c7 <fd_close>
  801475:	83 c4 10             	add    $0x10,%esp
}
  801478:	c9                   	leave  
  801479:	c3                   	ret    

0080147a <close_all>:

void
close_all(void)
{
  80147a:	55                   	push   %ebp
  80147b:	89 e5                	mov    %esp,%ebp
  80147d:	53                   	push   %ebx
  80147e:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801481:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801486:	83 ec 0c             	sub    $0xc,%esp
  801489:	53                   	push   %ebx
  80148a:	e8 c0 ff ff ff       	call   80144f <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  80148f:	43                   	inc    %ebx
  801490:	83 c4 10             	add    $0x10,%esp
  801493:	83 fb 20             	cmp    $0x20,%ebx
  801496:	75 ee                	jne    801486 <close_all+0xc>
		close(i);
}
  801498:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80149b:	c9                   	leave  
  80149c:	c3                   	ret    

0080149d <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  80149d:	55                   	push   %ebp
  80149e:	89 e5                	mov    %esp,%ebp
  8014a0:	57                   	push   %edi
  8014a1:	56                   	push   %esi
  8014a2:	53                   	push   %ebx
  8014a3:	83 ec 2c             	sub    $0x2c,%esp
  8014a6:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8014a9:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8014ac:	50                   	push   %eax
  8014ad:	ff 75 08             	pushl  0x8(%ebp)
  8014b0:	e8 56 fe ff ff       	call   80130b <fd_lookup>
  8014b5:	89 c3                	mov    %eax,%ebx
  8014b7:	83 c4 08             	add    $0x8,%esp
  8014ba:	85 c0                	test   %eax,%eax
  8014bc:	0f 88 c0 00 00 00    	js     801582 <dup+0xe5>
		return r;
	close(newfdnum);
  8014c2:	83 ec 0c             	sub    $0xc,%esp
  8014c5:	57                   	push   %edi
  8014c6:	e8 84 ff ff ff       	call   80144f <close>

	newfd = INDEX2FD(newfdnum);
  8014cb:	8d b7 00 00 0d 00    	lea    0xd0000(%edi),%esi
  8014d1:	c1 e6 0c             	shl    $0xc,%esi
	ova = fd2data(oldfd);
  8014d4:	83 c4 04             	add    $0x4,%esp
  8014d7:	ff 75 e4             	pushl  -0x1c(%ebp)
  8014da:	e8 a1 fd ff ff       	call   801280 <fd2data>
  8014df:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  8014e1:	89 34 24             	mov    %esi,(%esp)
  8014e4:	e8 97 fd ff ff       	call   801280 <fd2data>
  8014e9:	83 c4 10             	add    $0x10,%esp
  8014ec:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8014ef:	89 d8                	mov    %ebx,%eax
  8014f1:	c1 e8 16             	shr    $0x16,%eax
  8014f4:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8014fb:	a8 01                	test   $0x1,%al
  8014fd:	74 37                	je     801536 <dup+0x99>
  8014ff:	89 d8                	mov    %ebx,%eax
  801501:	c1 e8 0c             	shr    $0xc,%eax
  801504:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80150b:	f6 c2 01             	test   $0x1,%dl
  80150e:	74 26                	je     801536 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801510:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801517:	83 ec 0c             	sub    $0xc,%esp
  80151a:	25 07 0e 00 00       	and    $0xe07,%eax
  80151f:	50                   	push   %eax
  801520:	ff 75 d4             	pushl  -0x2c(%ebp)
  801523:	6a 00                	push   $0x0
  801525:	53                   	push   %ebx
  801526:	6a 00                	push   $0x0
  801528:	e8 93 fb ff ff       	call   8010c0 <sys_page_map>
  80152d:	89 c3                	mov    %eax,%ebx
  80152f:	83 c4 20             	add    $0x20,%esp
  801532:	85 c0                	test   %eax,%eax
  801534:	78 2d                	js     801563 <dup+0xc6>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801536:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801539:	89 c2                	mov    %eax,%edx
  80153b:	c1 ea 0c             	shr    $0xc,%edx
  80153e:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801545:	83 ec 0c             	sub    $0xc,%esp
  801548:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  80154e:	52                   	push   %edx
  80154f:	56                   	push   %esi
  801550:	6a 00                	push   $0x0
  801552:	50                   	push   %eax
  801553:	6a 00                	push   $0x0
  801555:	e8 66 fb ff ff       	call   8010c0 <sys_page_map>
  80155a:	89 c3                	mov    %eax,%ebx
  80155c:	83 c4 20             	add    $0x20,%esp
  80155f:	85 c0                	test   %eax,%eax
  801561:	79 1d                	jns    801580 <dup+0xe3>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801563:	83 ec 08             	sub    $0x8,%esp
  801566:	56                   	push   %esi
  801567:	6a 00                	push   $0x0
  801569:	e8 78 fb ff ff       	call   8010e6 <sys_page_unmap>
	sys_page_unmap(0, nva);
  80156e:	83 c4 08             	add    $0x8,%esp
  801571:	ff 75 d4             	pushl  -0x2c(%ebp)
  801574:	6a 00                	push   $0x0
  801576:	e8 6b fb ff ff       	call   8010e6 <sys_page_unmap>
	return r;
  80157b:	83 c4 10             	add    $0x10,%esp
  80157e:	eb 02                	jmp    801582 <dup+0xe5>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
		goto err;

	return newfdnum;
  801580:	89 fb                	mov    %edi,%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  801582:	89 d8                	mov    %ebx,%eax
  801584:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801587:	5b                   	pop    %ebx
  801588:	5e                   	pop    %esi
  801589:	5f                   	pop    %edi
  80158a:	c9                   	leave  
  80158b:	c3                   	ret    

0080158c <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80158c:	55                   	push   %ebp
  80158d:	89 e5                	mov    %esp,%ebp
  80158f:	53                   	push   %ebx
  801590:	83 ec 14             	sub    $0x14,%esp
  801593:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801596:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801599:	50                   	push   %eax
  80159a:	53                   	push   %ebx
  80159b:	e8 6b fd ff ff       	call   80130b <fd_lookup>
  8015a0:	83 c4 08             	add    $0x8,%esp
  8015a3:	85 c0                	test   %eax,%eax
  8015a5:	78 67                	js     80160e <read+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015a7:	83 ec 08             	sub    $0x8,%esp
  8015aa:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015ad:	50                   	push   %eax
  8015ae:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015b1:	ff 30                	pushl  (%eax)
  8015b3:	e8 a9 fd ff ff       	call   801361 <dev_lookup>
  8015b8:	83 c4 10             	add    $0x10,%esp
  8015bb:	85 c0                	test   %eax,%eax
  8015bd:	78 4f                	js     80160e <read+0x82>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8015bf:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015c2:	8b 50 08             	mov    0x8(%eax),%edx
  8015c5:	83 e2 03             	and    $0x3,%edx
  8015c8:	83 fa 01             	cmp    $0x1,%edx
  8015cb:	75 21                	jne    8015ee <read+0x62>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8015cd:	a1 b0 40 80 00       	mov    0x8040b0,%eax
  8015d2:	8b 40 48             	mov    0x48(%eax),%eax
  8015d5:	83 ec 04             	sub    $0x4,%esp
  8015d8:	53                   	push   %ebx
  8015d9:	50                   	push   %eax
  8015da:	68 e0 27 80 00       	push   $0x8027e0
  8015df:	e8 80 f0 ff ff       	call   800664 <cprintf>
		return -E_INVAL;
  8015e4:	83 c4 10             	add    $0x10,%esp
  8015e7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8015ec:	eb 20                	jmp    80160e <read+0x82>
	}
	if (!dev->dev_read)
  8015ee:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8015f1:	8b 52 08             	mov    0x8(%edx),%edx
  8015f4:	85 d2                	test   %edx,%edx
  8015f6:	74 11                	je     801609 <read+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8015f8:	83 ec 04             	sub    $0x4,%esp
  8015fb:	ff 75 10             	pushl  0x10(%ebp)
  8015fe:	ff 75 0c             	pushl  0xc(%ebp)
  801601:	50                   	push   %eax
  801602:	ff d2                	call   *%edx
  801604:	83 c4 10             	add    $0x10,%esp
  801607:	eb 05                	jmp    80160e <read+0x82>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801609:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_read)(fd, buf, n);
}
  80160e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801611:	c9                   	leave  
  801612:	c3                   	ret    

00801613 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801613:	55                   	push   %ebp
  801614:	89 e5                	mov    %esp,%ebp
  801616:	57                   	push   %edi
  801617:	56                   	push   %esi
  801618:	53                   	push   %ebx
  801619:	83 ec 0c             	sub    $0xc,%esp
  80161c:	8b 7d 08             	mov    0x8(%ebp),%edi
  80161f:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801622:	85 f6                	test   %esi,%esi
  801624:	74 31                	je     801657 <readn+0x44>
  801626:	b8 00 00 00 00       	mov    $0x0,%eax
  80162b:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = read(fdnum, (char*)buf + tot, n - tot);
  801630:	83 ec 04             	sub    $0x4,%esp
  801633:	89 f2                	mov    %esi,%edx
  801635:	29 c2                	sub    %eax,%edx
  801637:	52                   	push   %edx
  801638:	03 45 0c             	add    0xc(%ebp),%eax
  80163b:	50                   	push   %eax
  80163c:	57                   	push   %edi
  80163d:	e8 4a ff ff ff       	call   80158c <read>
		if (m < 0)
  801642:	83 c4 10             	add    $0x10,%esp
  801645:	85 c0                	test   %eax,%eax
  801647:	78 17                	js     801660 <readn+0x4d>
			return m;
		if (m == 0)
  801649:	85 c0                	test   %eax,%eax
  80164b:	74 11                	je     80165e <readn+0x4b>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80164d:	01 c3                	add    %eax,%ebx
  80164f:	89 d8                	mov    %ebx,%eax
  801651:	39 f3                	cmp    %esi,%ebx
  801653:	72 db                	jb     801630 <readn+0x1d>
  801655:	eb 09                	jmp    801660 <readn+0x4d>
  801657:	b8 00 00 00 00       	mov    $0x0,%eax
  80165c:	eb 02                	jmp    801660 <readn+0x4d>
		m = read(fdnum, (char*)buf + tot, n - tot);
		if (m < 0)
			return m;
		if (m == 0)
  80165e:	89 d8                	mov    %ebx,%eax
			break;
	}
	return tot;
}
  801660:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801663:	5b                   	pop    %ebx
  801664:	5e                   	pop    %esi
  801665:	5f                   	pop    %edi
  801666:	c9                   	leave  
  801667:	c3                   	ret    

00801668 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801668:	55                   	push   %ebp
  801669:	89 e5                	mov    %esp,%ebp
  80166b:	53                   	push   %ebx
  80166c:	83 ec 14             	sub    $0x14,%esp
  80166f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801672:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801675:	50                   	push   %eax
  801676:	53                   	push   %ebx
  801677:	e8 8f fc ff ff       	call   80130b <fd_lookup>
  80167c:	83 c4 08             	add    $0x8,%esp
  80167f:	85 c0                	test   %eax,%eax
  801681:	78 62                	js     8016e5 <write+0x7d>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801683:	83 ec 08             	sub    $0x8,%esp
  801686:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801689:	50                   	push   %eax
  80168a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80168d:	ff 30                	pushl  (%eax)
  80168f:	e8 cd fc ff ff       	call   801361 <dev_lookup>
  801694:	83 c4 10             	add    $0x10,%esp
  801697:	85 c0                	test   %eax,%eax
  801699:	78 4a                	js     8016e5 <write+0x7d>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80169b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80169e:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8016a2:	75 21                	jne    8016c5 <write+0x5d>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8016a4:	a1 b0 40 80 00       	mov    0x8040b0,%eax
  8016a9:	8b 40 48             	mov    0x48(%eax),%eax
  8016ac:	83 ec 04             	sub    $0x4,%esp
  8016af:	53                   	push   %ebx
  8016b0:	50                   	push   %eax
  8016b1:	68 fc 27 80 00       	push   $0x8027fc
  8016b6:	e8 a9 ef ff ff       	call   800664 <cprintf>
		return -E_INVAL;
  8016bb:	83 c4 10             	add    $0x10,%esp
  8016be:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8016c3:	eb 20                	jmp    8016e5 <write+0x7d>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8016c5:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8016c8:	8b 52 0c             	mov    0xc(%edx),%edx
  8016cb:	85 d2                	test   %edx,%edx
  8016cd:	74 11                	je     8016e0 <write+0x78>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8016cf:	83 ec 04             	sub    $0x4,%esp
  8016d2:	ff 75 10             	pushl  0x10(%ebp)
  8016d5:	ff 75 0c             	pushl  0xc(%ebp)
  8016d8:	50                   	push   %eax
  8016d9:	ff d2                	call   *%edx
  8016db:	83 c4 10             	add    $0x10,%esp
  8016de:	eb 05                	jmp    8016e5 <write+0x7d>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8016e0:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  8016e5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016e8:	c9                   	leave  
  8016e9:	c3                   	ret    

008016ea <seek>:

int
seek(int fdnum, off_t offset)
{
  8016ea:	55                   	push   %ebp
  8016eb:	89 e5                	mov    %esp,%ebp
  8016ed:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8016f0:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8016f3:	50                   	push   %eax
  8016f4:	ff 75 08             	pushl  0x8(%ebp)
  8016f7:	e8 0f fc ff ff       	call   80130b <fd_lookup>
  8016fc:	83 c4 08             	add    $0x8,%esp
  8016ff:	85 c0                	test   %eax,%eax
  801701:	78 0e                	js     801711 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801703:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801706:	8b 55 0c             	mov    0xc(%ebp),%edx
  801709:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  80170c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801711:	c9                   	leave  
  801712:	c3                   	ret    

00801713 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801713:	55                   	push   %ebp
  801714:	89 e5                	mov    %esp,%ebp
  801716:	53                   	push   %ebx
  801717:	83 ec 14             	sub    $0x14,%esp
  80171a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80171d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801720:	50                   	push   %eax
  801721:	53                   	push   %ebx
  801722:	e8 e4 fb ff ff       	call   80130b <fd_lookup>
  801727:	83 c4 08             	add    $0x8,%esp
  80172a:	85 c0                	test   %eax,%eax
  80172c:	78 5f                	js     80178d <ftruncate+0x7a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80172e:	83 ec 08             	sub    $0x8,%esp
  801731:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801734:	50                   	push   %eax
  801735:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801738:	ff 30                	pushl  (%eax)
  80173a:	e8 22 fc ff ff       	call   801361 <dev_lookup>
  80173f:	83 c4 10             	add    $0x10,%esp
  801742:	85 c0                	test   %eax,%eax
  801744:	78 47                	js     80178d <ftruncate+0x7a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801746:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801749:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80174d:	75 21                	jne    801770 <ftruncate+0x5d>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  80174f:	a1 b0 40 80 00       	mov    0x8040b0,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801754:	8b 40 48             	mov    0x48(%eax),%eax
  801757:	83 ec 04             	sub    $0x4,%esp
  80175a:	53                   	push   %ebx
  80175b:	50                   	push   %eax
  80175c:	68 bc 27 80 00       	push   $0x8027bc
  801761:	e8 fe ee ff ff       	call   800664 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801766:	83 c4 10             	add    $0x10,%esp
  801769:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80176e:	eb 1d                	jmp    80178d <ftruncate+0x7a>
	}
	if (!dev->dev_trunc)
  801770:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801773:	8b 52 18             	mov    0x18(%edx),%edx
  801776:	85 d2                	test   %edx,%edx
  801778:	74 0e                	je     801788 <ftruncate+0x75>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80177a:	83 ec 08             	sub    $0x8,%esp
  80177d:	ff 75 0c             	pushl  0xc(%ebp)
  801780:	50                   	push   %eax
  801781:	ff d2                	call   *%edx
  801783:	83 c4 10             	add    $0x10,%esp
  801786:	eb 05                	jmp    80178d <ftruncate+0x7a>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801788:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  80178d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801790:	c9                   	leave  
  801791:	c3                   	ret    

00801792 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801792:	55                   	push   %ebp
  801793:	89 e5                	mov    %esp,%ebp
  801795:	53                   	push   %ebx
  801796:	83 ec 14             	sub    $0x14,%esp
  801799:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80179c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80179f:	50                   	push   %eax
  8017a0:	ff 75 08             	pushl  0x8(%ebp)
  8017a3:	e8 63 fb ff ff       	call   80130b <fd_lookup>
  8017a8:	83 c4 08             	add    $0x8,%esp
  8017ab:	85 c0                	test   %eax,%eax
  8017ad:	78 52                	js     801801 <fstat+0x6f>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8017af:	83 ec 08             	sub    $0x8,%esp
  8017b2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8017b5:	50                   	push   %eax
  8017b6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8017b9:	ff 30                	pushl  (%eax)
  8017bb:	e8 a1 fb ff ff       	call   801361 <dev_lookup>
  8017c0:	83 c4 10             	add    $0x10,%esp
  8017c3:	85 c0                	test   %eax,%eax
  8017c5:	78 3a                	js     801801 <fstat+0x6f>
		return r;
	if (!dev->dev_stat)
  8017c7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8017ca:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8017ce:	74 2c                	je     8017fc <fstat+0x6a>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8017d0:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8017d3:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8017da:	00 00 00 
	stat->st_isdir = 0;
  8017dd:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8017e4:	00 00 00 
	stat->st_dev = dev;
  8017e7:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8017ed:	83 ec 08             	sub    $0x8,%esp
  8017f0:	53                   	push   %ebx
  8017f1:	ff 75 f0             	pushl  -0x10(%ebp)
  8017f4:	ff 50 14             	call   *0x14(%eax)
  8017f7:	83 c4 10             	add    $0x10,%esp
  8017fa:	eb 05                	jmp    801801 <fstat+0x6f>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8017fc:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801801:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801804:	c9                   	leave  
  801805:	c3                   	ret    

00801806 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801806:	55                   	push   %ebp
  801807:	89 e5                	mov    %esp,%ebp
  801809:	56                   	push   %esi
  80180a:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  80180b:	83 ec 08             	sub    $0x8,%esp
  80180e:	6a 00                	push   $0x0
  801810:	ff 75 08             	pushl  0x8(%ebp)
  801813:	e8 78 01 00 00       	call   801990 <open>
  801818:	89 c3                	mov    %eax,%ebx
  80181a:	83 c4 10             	add    $0x10,%esp
  80181d:	85 c0                	test   %eax,%eax
  80181f:	78 1b                	js     80183c <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801821:	83 ec 08             	sub    $0x8,%esp
  801824:	ff 75 0c             	pushl  0xc(%ebp)
  801827:	50                   	push   %eax
  801828:	e8 65 ff ff ff       	call   801792 <fstat>
  80182d:	89 c6                	mov    %eax,%esi
	close(fd);
  80182f:	89 1c 24             	mov    %ebx,(%esp)
  801832:	e8 18 fc ff ff       	call   80144f <close>
	return r;
  801837:	83 c4 10             	add    $0x10,%esp
  80183a:	89 f3                	mov    %esi,%ebx
}
  80183c:	89 d8                	mov    %ebx,%eax
  80183e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801841:	5b                   	pop    %ebx
  801842:	5e                   	pop    %esi
  801843:	c9                   	leave  
  801844:	c3                   	ret    
  801845:	00 00                	add    %al,(%eax)
	...

00801848 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801848:	55                   	push   %ebp
  801849:	89 e5                	mov    %esp,%ebp
  80184b:	56                   	push   %esi
  80184c:	53                   	push   %ebx
  80184d:	89 c3                	mov    %eax,%ebx
  80184f:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  801851:	83 3d ac 40 80 00 00 	cmpl   $0x0,0x8040ac
  801858:	75 12                	jne    80186c <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  80185a:	83 ec 0c             	sub    $0xc,%esp
  80185d:	6a 01                	push   $0x1
  80185f:	e8 8a 07 00 00       	call   801fee <ipc_find_env>
  801864:	a3 ac 40 80 00       	mov    %eax,0x8040ac
  801869:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  80186c:	6a 07                	push   $0x7
  80186e:	68 00 50 80 00       	push   $0x805000
  801873:	53                   	push   %ebx
  801874:	ff 35 ac 40 80 00    	pushl  0x8040ac
  80187a:	e8 1a 07 00 00       	call   801f99 <ipc_send>
	
	return ipc_recv(NULL, dstva, NULL);
  80187f:	83 c4 0c             	add    $0xc,%esp
  801882:	6a 00                	push   $0x0
  801884:	56                   	push   %esi
  801885:	6a 00                	push   $0x0
  801887:	e8 98 06 00 00       	call   801f24 <ipc_recv>
}
  80188c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80188f:	5b                   	pop    %ebx
  801890:	5e                   	pop    %esi
  801891:	c9                   	leave  
  801892:	c3                   	ret    

00801893 <devfile_stat>:
}


static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801893:	55                   	push   %ebp
  801894:	89 e5                	mov    %esp,%ebp
  801896:	53                   	push   %ebx
  801897:	83 ec 04             	sub    $0x4,%esp
  80189a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  80189d:	8b 45 08             	mov    0x8(%ebp),%eax
  8018a0:	8b 40 0c             	mov    0xc(%eax),%eax
  8018a3:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0) {
  8018a8:	ba 00 00 00 00       	mov    $0x0,%edx
  8018ad:	b8 05 00 00 00       	mov    $0x5,%eax
  8018b2:	e8 91 ff ff ff       	call   801848 <fsipc>
  8018b7:	85 c0                	test   %eax,%eax
  8018b9:	78 2c                	js     8018e7 <devfile_stat+0x54>
		return r;
	}
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8018bb:	83 ec 08             	sub    $0x8,%esp
  8018be:	68 00 50 80 00       	push   $0x805000
  8018c3:	53                   	push   %ebx
  8018c4:	e8 51 f3 ff ff       	call   800c1a <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8018c9:	a1 80 50 80 00       	mov    0x805080,%eax
  8018ce:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8018d4:	a1 84 50 80 00       	mov    0x805084,%eax
  8018d9:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8018df:	83 c4 10             	add    $0x10,%esp
  8018e2:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8018e7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8018ea:	c9                   	leave  
  8018eb:	c3                   	ret    

008018ec <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8018ec:	55                   	push   %ebp
  8018ed:	89 e5                	mov    %esp,%ebp
  8018ef:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8018f2:	8b 45 08             	mov    0x8(%ebp),%eax
  8018f5:	8b 40 0c             	mov    0xc(%eax),%eax
  8018f8:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8018fd:	ba 00 00 00 00       	mov    $0x0,%edx
  801902:	b8 06 00 00 00       	mov    $0x6,%eax
  801907:	e8 3c ff ff ff       	call   801848 <fsipc>
}
  80190c:	c9                   	leave  
  80190d:	c3                   	ret    

0080190e <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  80190e:	55                   	push   %ebp
  80190f:	89 e5                	mov    %esp,%ebp
  801911:	56                   	push   %esi
  801912:	53                   	push   %ebx
  801913:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801916:	8b 45 08             	mov    0x8(%ebp),%eax
  801919:	8b 40 0c             	mov    0xc(%eax),%eax
  80191c:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801921:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801927:	ba 00 00 00 00       	mov    $0x0,%edx
  80192c:	b8 03 00 00 00       	mov    $0x3,%eax
  801931:	e8 12 ff ff ff       	call   801848 <fsipc>
  801936:	89 c3                	mov    %eax,%ebx
  801938:	85 c0                	test   %eax,%eax
  80193a:	78 4b                	js     801987 <devfile_read+0x79>
		return r;
	assert(r <= n);
  80193c:	39 c6                	cmp    %eax,%esi
  80193e:	73 16                	jae    801956 <devfile_read+0x48>
  801940:	68 2c 28 80 00       	push   $0x80282c
  801945:	68 33 28 80 00       	push   $0x802833
  80194a:	6a 7d                	push   $0x7d
  80194c:	68 48 28 80 00       	push   $0x802848
  801951:	e8 36 ec ff ff       	call   80058c <_panic>
	assert(r <= PGSIZE);
  801956:	3d 00 10 00 00       	cmp    $0x1000,%eax
  80195b:	7e 16                	jle    801973 <devfile_read+0x65>
  80195d:	68 53 28 80 00       	push   $0x802853
  801962:	68 33 28 80 00       	push   $0x802833
  801967:	6a 7e                	push   $0x7e
  801969:	68 48 28 80 00       	push   $0x802848
  80196e:	e8 19 ec ff ff       	call   80058c <_panic>
	memmove(buf, &fsipcbuf, r);
  801973:	83 ec 04             	sub    $0x4,%esp
  801976:	50                   	push   %eax
  801977:	68 00 50 80 00       	push   $0x805000
  80197c:	ff 75 0c             	pushl  0xc(%ebp)
  80197f:	e8 57 f4 ff ff       	call   800ddb <memmove>
	return r;
  801984:	83 c4 10             	add    $0x10,%esp
}
  801987:	89 d8                	mov    %ebx,%eax
  801989:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80198c:	5b                   	pop    %ebx
  80198d:	5e                   	pop    %esi
  80198e:	c9                   	leave  
  80198f:	c3                   	ret    

00801990 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801990:	55                   	push   %ebp
  801991:	89 e5                	mov    %esp,%ebp
  801993:	56                   	push   %esi
  801994:	53                   	push   %ebx
  801995:	83 ec 1c             	sub    $0x1c,%esp
  801998:	8b 75 08             	mov    0x8(%ebp),%esi
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  80199b:	56                   	push   %esi
  80199c:	e8 27 f2 ff ff       	call   800bc8 <strlen>
  8019a1:	83 c4 10             	add    $0x10,%esp
  8019a4:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8019a9:	7f 65                	jg     801a10 <open+0x80>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8019ab:	83 ec 0c             	sub    $0xc,%esp
  8019ae:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8019b1:	50                   	push   %eax
  8019b2:	e8 e1 f8 ff ff       	call   801298 <fd_alloc>
  8019b7:	89 c3                	mov    %eax,%ebx
  8019b9:	83 c4 10             	add    $0x10,%esp
  8019bc:	85 c0                	test   %eax,%eax
  8019be:	78 55                	js     801a15 <open+0x85>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  8019c0:	83 ec 08             	sub    $0x8,%esp
  8019c3:	56                   	push   %esi
  8019c4:	68 00 50 80 00       	push   $0x805000
  8019c9:	e8 4c f2 ff ff       	call   800c1a <strcpy>
	fsipcbuf.open.req_omode = mode;
  8019ce:	8b 45 0c             	mov    0xc(%ebp),%eax
  8019d1:	a3 00 54 80 00       	mov    %eax,0x805400



	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8019d6:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8019d9:	b8 01 00 00 00       	mov    $0x1,%eax
  8019de:	e8 65 fe ff ff       	call   801848 <fsipc>
  8019e3:	89 c3                	mov    %eax,%ebx
  8019e5:	83 c4 10             	add    $0x10,%esp
  8019e8:	85 c0                	test   %eax,%eax
  8019ea:	79 12                	jns    8019fe <open+0x6e>
		fd_close(fd, 0);
  8019ec:	83 ec 08             	sub    $0x8,%esp
  8019ef:	6a 00                	push   $0x0
  8019f1:	ff 75 f4             	pushl  -0xc(%ebp)
  8019f4:	e8 ce f9 ff ff       	call   8013c7 <fd_close>
		return r;
  8019f9:	83 c4 10             	add    $0x10,%esp
  8019fc:	eb 17                	jmp    801a15 <open+0x85>
	}

	return fd2num(fd);
  8019fe:	83 ec 0c             	sub    $0xc,%esp
  801a01:	ff 75 f4             	pushl  -0xc(%ebp)
  801a04:	e8 67 f8 ff ff       	call   801270 <fd2num>
  801a09:	89 c3                	mov    %eax,%ebx
  801a0b:	83 c4 10             	add    $0x10,%esp
  801a0e:	eb 05                	jmp    801a15 <open+0x85>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801a10:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801a15:	89 d8                	mov    %ebx,%eax
  801a17:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a1a:	5b                   	pop    %ebx
  801a1b:	5e                   	pop    %esi
  801a1c:	c9                   	leave  
  801a1d:	c3                   	ret    
	...

00801a20 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801a20:	55                   	push   %ebp
  801a21:	89 e5                	mov    %esp,%ebp
  801a23:	56                   	push   %esi
  801a24:	53                   	push   %ebx
  801a25:	8b 75 0c             	mov    0xc(%ebp),%esi
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801a28:	83 ec 0c             	sub    $0xc,%esp
  801a2b:	ff 75 08             	pushl  0x8(%ebp)
  801a2e:	e8 4d f8 ff ff       	call   801280 <fd2data>
  801a33:	89 c3                	mov    %eax,%ebx
	strcpy(stat->st_name, "<pipe>");
  801a35:	83 c4 08             	add    $0x8,%esp
  801a38:	68 5f 28 80 00       	push   $0x80285f
  801a3d:	56                   	push   %esi
  801a3e:	e8 d7 f1 ff ff       	call   800c1a <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801a43:	8b 43 04             	mov    0x4(%ebx),%eax
  801a46:	2b 03                	sub    (%ebx),%eax
  801a48:	89 86 80 00 00 00    	mov    %eax,0x80(%esi)
	stat->st_isdir = 0;
  801a4e:	c7 86 84 00 00 00 00 	movl   $0x0,0x84(%esi)
  801a55:	00 00 00 
	stat->st_dev = &devpipe;
  801a58:	c7 86 88 00 00 00 20 	movl   $0x803020,0x88(%esi)
  801a5f:	30 80 00 
	return 0;
}
  801a62:	b8 00 00 00 00       	mov    $0x0,%eax
  801a67:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a6a:	5b                   	pop    %ebx
  801a6b:	5e                   	pop    %esi
  801a6c:	c9                   	leave  
  801a6d:	c3                   	ret    

00801a6e <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801a6e:	55                   	push   %ebp
  801a6f:	89 e5                	mov    %esp,%ebp
  801a71:	53                   	push   %ebx
  801a72:	83 ec 0c             	sub    $0xc,%esp
  801a75:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801a78:	53                   	push   %ebx
  801a79:	6a 00                	push   $0x0
  801a7b:	e8 66 f6 ff ff       	call   8010e6 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801a80:	89 1c 24             	mov    %ebx,(%esp)
  801a83:	e8 f8 f7 ff ff       	call   801280 <fd2data>
  801a88:	83 c4 08             	add    $0x8,%esp
  801a8b:	50                   	push   %eax
  801a8c:	6a 00                	push   $0x0
  801a8e:	e8 53 f6 ff ff       	call   8010e6 <sys_page_unmap>
}
  801a93:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a96:	c9                   	leave  
  801a97:	c3                   	ret    

00801a98 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801a98:	55                   	push   %ebp
  801a99:	89 e5                	mov    %esp,%ebp
  801a9b:	57                   	push   %edi
  801a9c:	56                   	push   %esi
  801a9d:	53                   	push   %ebx
  801a9e:	83 ec 1c             	sub    $0x1c,%esp
  801aa1:	89 c7                	mov    %eax,%edi
  801aa3:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801aa6:	a1 b0 40 80 00       	mov    0x8040b0,%eax
  801aab:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801aae:	83 ec 0c             	sub    $0xc,%esp
  801ab1:	57                   	push   %edi
  801ab2:	e8 95 05 00 00       	call   80204c <pageref>
  801ab7:	89 c6                	mov    %eax,%esi
  801ab9:	83 c4 04             	add    $0x4,%esp
  801abc:	ff 75 e4             	pushl  -0x1c(%ebp)
  801abf:	e8 88 05 00 00       	call   80204c <pageref>
  801ac4:	83 c4 10             	add    $0x10,%esp
  801ac7:	39 c6                	cmp    %eax,%esi
  801ac9:	0f 94 c0             	sete   %al
  801acc:	0f b6 c0             	movzbl %al,%eax
		nn = thisenv->env_runs;
  801acf:	8b 15 b0 40 80 00    	mov    0x8040b0,%edx
  801ad5:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801ad8:	39 cb                	cmp    %ecx,%ebx
  801ada:	75 08                	jne    801ae4 <_pipeisclosed+0x4c>
			return ret;
		if (n != nn && ret == 1)
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
	}
}
  801adc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801adf:	5b                   	pop    %ebx
  801ae0:	5e                   	pop    %esi
  801ae1:	5f                   	pop    %edi
  801ae2:	c9                   	leave  
  801ae3:	c3                   	ret    
		n = thisenv->env_runs;
		ret = pageref(fd) == pageref(p);
		nn = thisenv->env_runs;
		if (n == nn)
			return ret;
		if (n != nn && ret == 1)
  801ae4:	83 f8 01             	cmp    $0x1,%eax
  801ae7:	75 bd                	jne    801aa6 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801ae9:	8b 42 58             	mov    0x58(%edx),%eax
  801aec:	6a 01                	push   $0x1
  801aee:	50                   	push   %eax
  801aef:	53                   	push   %ebx
  801af0:	68 66 28 80 00       	push   $0x802866
  801af5:	e8 6a eb ff ff       	call   800664 <cprintf>
  801afa:	83 c4 10             	add    $0x10,%esp
  801afd:	eb a7                	jmp    801aa6 <_pipeisclosed+0xe>

00801aff <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801aff:	55                   	push   %ebp
  801b00:	89 e5                	mov    %esp,%ebp
  801b02:	57                   	push   %edi
  801b03:	56                   	push   %esi
  801b04:	53                   	push   %ebx
  801b05:	83 ec 28             	sub    $0x28,%esp
  801b08:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801b0b:	56                   	push   %esi
  801b0c:	e8 6f f7 ff ff       	call   801280 <fd2data>
  801b11:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801b13:	83 c4 10             	add    $0x10,%esp
  801b16:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801b1a:	75 4a                	jne    801b66 <devpipe_write+0x67>
  801b1c:	bf 00 00 00 00       	mov    $0x0,%edi
  801b21:	eb 56                	jmp    801b79 <devpipe_write+0x7a>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801b23:	89 da                	mov    %ebx,%edx
  801b25:	89 f0                	mov    %esi,%eax
  801b27:	e8 6c ff ff ff       	call   801a98 <_pipeisclosed>
  801b2c:	85 c0                	test   %eax,%eax
  801b2e:	75 4d                	jne    801b7d <devpipe_write+0x7e>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801b30:	e8 40 f5 ff ff       	call   801075 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801b35:	8b 43 04             	mov    0x4(%ebx),%eax
  801b38:	8b 13                	mov    (%ebx),%edx
  801b3a:	83 c2 20             	add    $0x20,%edx
  801b3d:	39 d0                	cmp    %edx,%eax
  801b3f:	73 e2                	jae    801b23 <devpipe_write+0x24>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801b41:	89 c2                	mov    %eax,%edx
  801b43:	81 e2 1f 00 00 80    	and    $0x8000001f,%edx
  801b49:	79 05                	jns    801b50 <devpipe_write+0x51>
  801b4b:	4a                   	dec    %edx
  801b4c:	83 ca e0             	or     $0xffffffe0,%edx
  801b4f:	42                   	inc    %edx
  801b50:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801b53:	8a 0c 39             	mov    (%ecx,%edi,1),%cl
  801b56:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801b5a:	40                   	inc    %eax
  801b5b:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801b5e:	47                   	inc    %edi
  801b5f:	39 7d 10             	cmp    %edi,0x10(%ebp)
  801b62:	77 07                	ja     801b6b <devpipe_write+0x6c>
  801b64:	eb 13                	jmp    801b79 <devpipe_write+0x7a>
  801b66:	bf 00 00 00 00       	mov    $0x0,%edi
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801b6b:	8b 43 04             	mov    0x4(%ebx),%eax
  801b6e:	8b 13                	mov    (%ebx),%edx
  801b70:	83 c2 20             	add    $0x20,%edx
  801b73:	39 d0                	cmp    %edx,%eax
  801b75:	73 ac                	jae    801b23 <devpipe_write+0x24>
  801b77:	eb c8                	jmp    801b41 <devpipe_write+0x42>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801b79:	89 f8                	mov    %edi,%eax
  801b7b:	eb 05                	jmp    801b82 <devpipe_write+0x83>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801b7d:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801b82:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b85:	5b                   	pop    %ebx
  801b86:	5e                   	pop    %esi
  801b87:	5f                   	pop    %edi
  801b88:	c9                   	leave  
  801b89:	c3                   	ret    

00801b8a <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801b8a:	55                   	push   %ebp
  801b8b:	89 e5                	mov    %esp,%ebp
  801b8d:	57                   	push   %edi
  801b8e:	56                   	push   %esi
  801b8f:	53                   	push   %ebx
  801b90:	83 ec 18             	sub    $0x18,%esp
  801b93:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801b96:	57                   	push   %edi
  801b97:	e8 e4 f6 ff ff       	call   801280 <fd2data>
  801b9c:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801b9e:	83 c4 10             	add    $0x10,%esp
  801ba1:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801ba5:	75 44                	jne    801beb <devpipe_read+0x61>
  801ba7:	be 00 00 00 00       	mov    $0x0,%esi
  801bac:	eb 4f                	jmp    801bfd <devpipe_read+0x73>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
				return i;
  801bae:	89 f0                	mov    %esi,%eax
  801bb0:	eb 54                	jmp    801c06 <devpipe_read+0x7c>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801bb2:	89 da                	mov    %ebx,%edx
  801bb4:	89 f8                	mov    %edi,%eax
  801bb6:	e8 dd fe ff ff       	call   801a98 <_pipeisclosed>
  801bbb:	85 c0                	test   %eax,%eax
  801bbd:	75 42                	jne    801c01 <devpipe_read+0x77>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801bbf:	e8 b1 f4 ff ff       	call   801075 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801bc4:	8b 03                	mov    (%ebx),%eax
  801bc6:	3b 43 04             	cmp    0x4(%ebx),%eax
  801bc9:	74 e7                	je     801bb2 <devpipe_read+0x28>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801bcb:	25 1f 00 00 80       	and    $0x8000001f,%eax
  801bd0:	79 05                	jns    801bd7 <devpipe_read+0x4d>
  801bd2:	48                   	dec    %eax
  801bd3:	83 c8 e0             	or     $0xffffffe0,%eax
  801bd6:	40                   	inc    %eax
  801bd7:	8a 44 03 08          	mov    0x8(%ebx,%eax,1),%al
  801bdb:	8b 55 0c             	mov    0xc(%ebp),%edx
  801bde:	88 04 32             	mov    %al,(%edx,%esi,1)
		p->p_rpos++;
  801be1:	ff 03                	incl   (%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801be3:	46                   	inc    %esi
  801be4:	39 75 10             	cmp    %esi,0x10(%ebp)
  801be7:	77 07                	ja     801bf0 <devpipe_read+0x66>
  801be9:	eb 12                	jmp    801bfd <devpipe_read+0x73>
  801beb:	be 00 00 00 00       	mov    $0x0,%esi
		while (p->p_rpos == p->p_wpos) {
  801bf0:	8b 03                	mov    (%ebx),%eax
  801bf2:	3b 43 04             	cmp    0x4(%ebx),%eax
  801bf5:	75 d4                	jne    801bcb <devpipe_read+0x41>
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801bf7:	85 f6                	test   %esi,%esi
  801bf9:	75 b3                	jne    801bae <devpipe_read+0x24>
  801bfb:	eb b5                	jmp    801bb2 <devpipe_read+0x28>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801bfd:	89 f0                	mov    %esi,%eax
  801bff:	eb 05                	jmp    801c06 <devpipe_read+0x7c>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801c01:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801c06:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801c09:	5b                   	pop    %ebx
  801c0a:	5e                   	pop    %esi
  801c0b:	5f                   	pop    %edi
  801c0c:	c9                   	leave  
  801c0d:	c3                   	ret    

00801c0e <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801c0e:	55                   	push   %ebp
  801c0f:	89 e5                	mov    %esp,%ebp
  801c11:	57                   	push   %edi
  801c12:	56                   	push   %esi
  801c13:	53                   	push   %ebx
  801c14:	83 ec 28             	sub    $0x28,%esp
  801c17:	8b 7d 08             	mov    0x8(%ebp),%edi
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801c1a:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801c1d:	50                   	push   %eax
  801c1e:	e8 75 f6 ff ff       	call   801298 <fd_alloc>
  801c23:	89 c3                	mov    %eax,%ebx
  801c25:	83 c4 10             	add    $0x10,%esp
  801c28:	85 c0                	test   %eax,%eax
  801c2a:	0f 88 24 01 00 00    	js     801d54 <pipe+0x146>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c30:	83 ec 04             	sub    $0x4,%esp
  801c33:	68 07 04 00 00       	push   $0x407
  801c38:	ff 75 e4             	pushl  -0x1c(%ebp)
  801c3b:	6a 00                	push   $0x0
  801c3d:	e8 5a f4 ff ff       	call   80109c <sys_page_alloc>
  801c42:	89 c3                	mov    %eax,%ebx
  801c44:	83 c4 10             	add    $0x10,%esp
  801c47:	85 c0                	test   %eax,%eax
  801c49:	0f 88 05 01 00 00    	js     801d54 <pipe+0x146>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801c4f:	83 ec 0c             	sub    $0xc,%esp
  801c52:	8d 45 e0             	lea    -0x20(%ebp),%eax
  801c55:	50                   	push   %eax
  801c56:	e8 3d f6 ff ff       	call   801298 <fd_alloc>
  801c5b:	89 c3                	mov    %eax,%ebx
  801c5d:	83 c4 10             	add    $0x10,%esp
  801c60:	85 c0                	test   %eax,%eax
  801c62:	0f 88 dc 00 00 00    	js     801d44 <pipe+0x136>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c68:	83 ec 04             	sub    $0x4,%esp
  801c6b:	68 07 04 00 00       	push   $0x407
  801c70:	ff 75 e0             	pushl  -0x20(%ebp)
  801c73:	6a 00                	push   $0x0
  801c75:	e8 22 f4 ff ff       	call   80109c <sys_page_alloc>
  801c7a:	89 c3                	mov    %eax,%ebx
  801c7c:	83 c4 10             	add    $0x10,%esp
  801c7f:	85 c0                	test   %eax,%eax
  801c81:	0f 88 bd 00 00 00    	js     801d44 <pipe+0x136>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801c87:	83 ec 0c             	sub    $0xc,%esp
  801c8a:	ff 75 e4             	pushl  -0x1c(%ebp)
  801c8d:	e8 ee f5 ff ff       	call   801280 <fd2data>
  801c92:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c94:	83 c4 0c             	add    $0xc,%esp
  801c97:	68 07 04 00 00       	push   $0x407
  801c9c:	50                   	push   %eax
  801c9d:	6a 00                	push   $0x0
  801c9f:	e8 f8 f3 ff ff       	call   80109c <sys_page_alloc>
  801ca4:	89 c3                	mov    %eax,%ebx
  801ca6:	83 c4 10             	add    $0x10,%esp
  801ca9:	85 c0                	test   %eax,%eax
  801cab:	0f 88 83 00 00 00    	js     801d34 <pipe+0x126>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801cb1:	83 ec 0c             	sub    $0xc,%esp
  801cb4:	ff 75 e0             	pushl  -0x20(%ebp)
  801cb7:	e8 c4 f5 ff ff       	call   801280 <fd2data>
  801cbc:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801cc3:	50                   	push   %eax
  801cc4:	6a 00                	push   $0x0
  801cc6:	56                   	push   %esi
  801cc7:	6a 00                	push   $0x0
  801cc9:	e8 f2 f3 ff ff       	call   8010c0 <sys_page_map>
  801cce:	89 c3                	mov    %eax,%ebx
  801cd0:	83 c4 20             	add    $0x20,%esp
  801cd3:	85 c0                	test   %eax,%eax
  801cd5:	78 4f                	js     801d26 <pipe+0x118>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801cd7:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801cdd:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801ce0:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801ce2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801ce5:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801cec:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801cf2:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801cf5:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801cf7:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801cfa:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801d01:	83 ec 0c             	sub    $0xc,%esp
  801d04:	ff 75 e4             	pushl  -0x1c(%ebp)
  801d07:	e8 64 f5 ff ff       	call   801270 <fd2num>
  801d0c:	89 07                	mov    %eax,(%edi)
	pfd[1] = fd2num(fd1);
  801d0e:	83 c4 04             	add    $0x4,%esp
  801d11:	ff 75 e0             	pushl  -0x20(%ebp)
  801d14:	e8 57 f5 ff ff       	call   801270 <fd2num>
  801d19:	89 47 04             	mov    %eax,0x4(%edi)
	return 0;
  801d1c:	83 c4 10             	add    $0x10,%esp
  801d1f:	bb 00 00 00 00       	mov    $0x0,%ebx
  801d24:	eb 2e                	jmp    801d54 <pipe+0x146>

    err3:
	sys_page_unmap(0, va);
  801d26:	83 ec 08             	sub    $0x8,%esp
  801d29:	56                   	push   %esi
  801d2a:	6a 00                	push   $0x0
  801d2c:	e8 b5 f3 ff ff       	call   8010e6 <sys_page_unmap>
  801d31:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801d34:	83 ec 08             	sub    $0x8,%esp
  801d37:	ff 75 e0             	pushl  -0x20(%ebp)
  801d3a:	6a 00                	push   $0x0
  801d3c:	e8 a5 f3 ff ff       	call   8010e6 <sys_page_unmap>
  801d41:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801d44:	83 ec 08             	sub    $0x8,%esp
  801d47:	ff 75 e4             	pushl  -0x1c(%ebp)
  801d4a:	6a 00                	push   $0x0
  801d4c:	e8 95 f3 ff ff       	call   8010e6 <sys_page_unmap>
  801d51:	83 c4 10             	add    $0x10,%esp
    err:
	return r;
}
  801d54:	89 d8                	mov    %ebx,%eax
  801d56:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801d59:	5b                   	pop    %ebx
  801d5a:	5e                   	pop    %esi
  801d5b:	5f                   	pop    %edi
  801d5c:	c9                   	leave  
  801d5d:	c3                   	ret    

00801d5e <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801d5e:	55                   	push   %ebp
  801d5f:	89 e5                	mov    %esp,%ebp
  801d61:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801d64:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801d67:	50                   	push   %eax
  801d68:	ff 75 08             	pushl  0x8(%ebp)
  801d6b:	e8 9b f5 ff ff       	call   80130b <fd_lookup>
  801d70:	83 c4 10             	add    $0x10,%esp
  801d73:	85 c0                	test   %eax,%eax
  801d75:	78 18                	js     801d8f <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801d77:	83 ec 0c             	sub    $0xc,%esp
  801d7a:	ff 75 f4             	pushl  -0xc(%ebp)
  801d7d:	e8 fe f4 ff ff       	call   801280 <fd2data>
	return _pipeisclosed(fd, p);
  801d82:	89 c2                	mov    %eax,%edx
  801d84:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d87:	e8 0c fd ff ff       	call   801a98 <_pipeisclosed>
  801d8c:	83 c4 10             	add    $0x10,%esp
}
  801d8f:	c9                   	leave  
  801d90:	c3                   	ret    
  801d91:	00 00                	add    %al,(%eax)
	...

00801d94 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801d94:	55                   	push   %ebp
  801d95:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801d97:	b8 00 00 00 00       	mov    $0x0,%eax
  801d9c:	c9                   	leave  
  801d9d:	c3                   	ret    

00801d9e <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801d9e:	55                   	push   %ebp
  801d9f:	89 e5                	mov    %esp,%ebp
  801da1:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801da4:	68 7e 28 80 00       	push   $0x80287e
  801da9:	ff 75 0c             	pushl  0xc(%ebp)
  801dac:	e8 69 ee ff ff       	call   800c1a <strcpy>
	return 0;
}
  801db1:	b8 00 00 00 00       	mov    $0x0,%eax
  801db6:	c9                   	leave  
  801db7:	c3                   	ret    

00801db8 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801db8:	55                   	push   %ebp
  801db9:	89 e5                	mov    %esp,%ebp
  801dbb:	57                   	push   %edi
  801dbc:	56                   	push   %esi
  801dbd:	53                   	push   %ebx
  801dbe:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801dc4:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801dc8:	74 45                	je     801e0f <devcons_write+0x57>
  801dca:	b8 00 00 00 00       	mov    $0x0,%eax
  801dcf:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801dd4:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801dda:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801ddd:	29 c3                	sub    %eax,%ebx
		if (m > sizeof(buf) - 1)
  801ddf:	83 fb 7f             	cmp    $0x7f,%ebx
  801de2:	76 05                	jbe    801de9 <devcons_write+0x31>
			m = sizeof(buf) - 1;
  801de4:	bb 7f 00 00 00       	mov    $0x7f,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  801de9:	83 ec 04             	sub    $0x4,%esp
  801dec:	53                   	push   %ebx
  801ded:	03 45 0c             	add    0xc(%ebp),%eax
  801df0:	50                   	push   %eax
  801df1:	57                   	push   %edi
  801df2:	e8 e4 ef ff ff       	call   800ddb <memmove>
		sys_cputs(buf, m);
  801df7:	83 c4 08             	add    $0x8,%esp
  801dfa:	53                   	push   %ebx
  801dfb:	57                   	push   %edi
  801dfc:	e8 e4 f1 ff ff       	call   800fe5 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801e01:	01 de                	add    %ebx,%esi
  801e03:	89 f0                	mov    %esi,%eax
  801e05:	83 c4 10             	add    $0x10,%esp
  801e08:	3b 75 10             	cmp    0x10(%ebp),%esi
  801e0b:	72 cd                	jb     801dda <devcons_write+0x22>
  801e0d:	eb 05                	jmp    801e14 <devcons_write+0x5c>
  801e0f:	be 00 00 00 00       	mov    $0x0,%esi
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801e14:	89 f0                	mov    %esi,%eax
  801e16:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801e19:	5b                   	pop    %ebx
  801e1a:	5e                   	pop    %esi
  801e1b:	5f                   	pop    %edi
  801e1c:	c9                   	leave  
  801e1d:	c3                   	ret    

00801e1e <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801e1e:	55                   	push   %ebp
  801e1f:	89 e5                	mov    %esp,%ebp
  801e21:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
  801e24:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801e28:	75 07                	jne    801e31 <devcons_read+0x13>
  801e2a:	eb 25                	jmp    801e51 <devcons_read+0x33>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801e2c:	e8 44 f2 ff ff       	call   801075 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801e31:	e8 d5 f1 ff ff       	call   80100b <sys_cgetc>
  801e36:	85 c0                	test   %eax,%eax
  801e38:	74 f2                	je     801e2c <devcons_read+0xe>
  801e3a:	89 c2                	mov    %eax,%edx
		sys_yield();
	if (c < 0)
  801e3c:	85 c0                	test   %eax,%eax
  801e3e:	78 1d                	js     801e5d <devcons_read+0x3f>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801e40:	83 f8 04             	cmp    $0x4,%eax
  801e43:	74 13                	je     801e58 <devcons_read+0x3a>
		return 0;
	*(char*)vbuf = c;
  801e45:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e48:	88 10                	mov    %dl,(%eax)
	return 1;
  801e4a:	b8 01 00 00 00       	mov    $0x1,%eax
  801e4f:	eb 0c                	jmp    801e5d <devcons_read+0x3f>
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
		return 0;
  801e51:	b8 00 00 00 00       	mov    $0x0,%eax
  801e56:	eb 05                	jmp    801e5d <devcons_read+0x3f>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801e58:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801e5d:	c9                   	leave  
  801e5e:	c3                   	ret    

00801e5f <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801e5f:	55                   	push   %ebp
  801e60:	89 e5                	mov    %esp,%ebp
  801e62:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801e65:	8b 45 08             	mov    0x8(%ebp),%eax
  801e68:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801e6b:	6a 01                	push   $0x1
  801e6d:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801e70:	50                   	push   %eax
  801e71:	e8 6f f1 ff ff       	call   800fe5 <sys_cputs>
  801e76:	83 c4 10             	add    $0x10,%esp
}
  801e79:	c9                   	leave  
  801e7a:	c3                   	ret    

00801e7b <getchar>:

int
getchar(void)
{
  801e7b:	55                   	push   %ebp
  801e7c:	89 e5                	mov    %esp,%ebp
  801e7e:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801e81:	6a 01                	push   $0x1
  801e83:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801e86:	50                   	push   %eax
  801e87:	6a 00                	push   $0x0
  801e89:	e8 fe f6 ff ff       	call   80158c <read>
	if (r < 0)
  801e8e:	83 c4 10             	add    $0x10,%esp
  801e91:	85 c0                	test   %eax,%eax
  801e93:	78 0f                	js     801ea4 <getchar+0x29>
		return r;
	if (r < 1)
  801e95:	85 c0                	test   %eax,%eax
  801e97:	7e 06                	jle    801e9f <getchar+0x24>
		return -E_EOF;
	return c;
  801e99:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801e9d:	eb 05                	jmp    801ea4 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801e9f:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801ea4:	c9                   	leave  
  801ea5:	c3                   	ret    

00801ea6 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801ea6:	55                   	push   %ebp
  801ea7:	89 e5                	mov    %esp,%ebp
  801ea9:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801eac:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801eaf:	50                   	push   %eax
  801eb0:	ff 75 08             	pushl  0x8(%ebp)
  801eb3:	e8 53 f4 ff ff       	call   80130b <fd_lookup>
  801eb8:	83 c4 10             	add    $0x10,%esp
  801ebb:	85 c0                	test   %eax,%eax
  801ebd:	78 11                	js     801ed0 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801ebf:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ec2:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801ec8:	39 10                	cmp    %edx,(%eax)
  801eca:	0f 94 c0             	sete   %al
  801ecd:	0f b6 c0             	movzbl %al,%eax
}
  801ed0:	c9                   	leave  
  801ed1:	c3                   	ret    

00801ed2 <opencons>:

int
opencons(void)
{
  801ed2:	55                   	push   %ebp
  801ed3:	89 e5                	mov    %esp,%ebp
  801ed5:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801ed8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801edb:	50                   	push   %eax
  801edc:	e8 b7 f3 ff ff       	call   801298 <fd_alloc>
  801ee1:	83 c4 10             	add    $0x10,%esp
  801ee4:	85 c0                	test   %eax,%eax
  801ee6:	78 3a                	js     801f22 <opencons+0x50>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801ee8:	83 ec 04             	sub    $0x4,%esp
  801eeb:	68 07 04 00 00       	push   $0x407
  801ef0:	ff 75 f4             	pushl  -0xc(%ebp)
  801ef3:	6a 00                	push   $0x0
  801ef5:	e8 a2 f1 ff ff       	call   80109c <sys_page_alloc>
  801efa:	83 c4 10             	add    $0x10,%esp
  801efd:	85 c0                	test   %eax,%eax
  801eff:	78 21                	js     801f22 <opencons+0x50>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801f01:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801f07:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f0a:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801f0c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f0f:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801f16:	83 ec 0c             	sub    $0xc,%esp
  801f19:	50                   	push   %eax
  801f1a:	e8 51 f3 ff ff       	call   801270 <fd2num>
  801f1f:	83 c4 10             	add    $0x10,%esp
}
  801f22:	c9                   	leave  
  801f23:	c3                   	ret    

00801f24 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801f24:	55                   	push   %ebp
  801f25:	89 e5                	mov    %esp,%ebp
  801f27:	56                   	push   %esi
  801f28:	53                   	push   %ebx
  801f29:	8b 75 08             	mov    0x8(%ebp),%esi
  801f2c:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f2f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// cprintf("0x%x 0x%x 0x%x\n", (uint32_t)from_env_store, (uint32_t)pg, (uint32_t)perm_store);
	int r;
	if (pg != NULL) {
  801f32:	85 c0                	test   %eax,%eax
  801f34:	74 0e                	je     801f44 <ipc_recv+0x20>
		r = sys_ipc_recv(pg);
  801f36:	83 ec 0c             	sub    $0xc,%esp
  801f39:	50                   	push   %eax
  801f3a:	e8 58 f2 ff ff       	call   801197 <sys_ipc_recv>
  801f3f:	83 c4 10             	add    $0x10,%esp
  801f42:	eb 10                	jmp    801f54 <ipc_recv+0x30>
	} else {
		r = sys_ipc_recv((void *)UTOP);
  801f44:	83 ec 0c             	sub    $0xc,%esp
  801f47:	68 00 00 c0 ee       	push   $0xeec00000
  801f4c:	e8 46 f2 ff ff       	call   801197 <sys_ipc_recv>
  801f51:	83 c4 10             	add    $0x10,%esp
	}

	if (r == 0) {
  801f54:	85 c0                	test   %eax,%eax
  801f56:	75 26                	jne    801f7e <ipc_recv+0x5a>
		if (from_env_store != NULL) *from_env_store = thisenv->env_ipc_from;
  801f58:	85 f6                	test   %esi,%esi
  801f5a:	74 0a                	je     801f66 <ipc_recv+0x42>
  801f5c:	a1 b0 40 80 00       	mov    0x8040b0,%eax
  801f61:	8b 40 74             	mov    0x74(%eax),%eax
  801f64:	89 06                	mov    %eax,(%esi)
		if (perm_store != NULL) *perm_store = thisenv->env_ipc_perm;
  801f66:	85 db                	test   %ebx,%ebx
  801f68:	74 0a                	je     801f74 <ipc_recv+0x50>
  801f6a:	a1 b0 40 80 00       	mov    0x8040b0,%eax
  801f6f:	8b 40 78             	mov    0x78(%eax),%eax
  801f72:	89 03                	mov    %eax,(%ebx)
		return thisenv->env_ipc_value;
  801f74:	a1 b0 40 80 00       	mov    0x8040b0,%eax
  801f79:	8b 40 70             	mov    0x70(%eax),%eax
  801f7c:	eb 14                	jmp    801f92 <ipc_recv+0x6e>
	} else {
		// fails;
		if (from_env_store != NULL) *from_env_store = 0;
  801f7e:	85 f6                	test   %esi,%esi
  801f80:	74 06                	je     801f88 <ipc_recv+0x64>
  801f82:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		if (perm_store != NULL) *perm_store = 0;
  801f88:	85 db                	test   %ebx,%ebx
  801f8a:	74 06                	je     801f92 <ipc_recv+0x6e>
  801f8c:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
		return r;
	}
}
  801f92:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801f95:	5b                   	pop    %ebx
  801f96:	5e                   	pop    %esi
  801f97:	c9                   	leave  
  801f98:	c3                   	ret    

00801f99 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801f99:	55                   	push   %ebp
  801f9a:	89 e5                	mov    %esp,%ebp
  801f9c:	57                   	push   %edi
  801f9d:	56                   	push   %esi
  801f9e:	53                   	push   %ebx
  801f9f:	83 ec 0c             	sub    $0xc,%esp
  801fa2:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801fa5:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801fa8:	8b 75 14             	mov    0x14(%ebp),%esi
	// LAB 4: Your code here.
	// int sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
	int r;
	if (pg == NULL) pg = (void *)UTOP;
  801fab:	85 db                	test   %ebx,%ebx
  801fad:	75 25                	jne    801fd4 <ipc_send+0x3b>
  801faf:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
  801fb4:	eb 1e                	jmp    801fd4 <ipc_send+0x3b>
	
	while ((r = sys_ipc_try_send(to_env, val, pg, perm)) != 0) {
		if (r == -E_IPC_NOT_RECV) {
  801fb6:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801fb9:	75 07                	jne    801fc2 <ipc_send+0x29>
			// cprintf("Try Again and Again....\n");
			sys_yield();
  801fbb:	e8 b5 f0 ff ff       	call   801075 <sys_yield>
  801fc0:	eb 12                	jmp    801fd4 <ipc_send+0x3b>
		} else {
			panic("ipc_send error %e\n", r);
  801fc2:	50                   	push   %eax
  801fc3:	68 8a 28 80 00       	push   $0x80288a
  801fc8:	6a 43                	push   $0x43
  801fca:	68 9d 28 80 00       	push   $0x80289d
  801fcf:	e8 b8 e5 ff ff       	call   80058c <_panic>
	// LAB 4: Your code here.
	// int sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
	int r;
	if (pg == NULL) pg = (void *)UTOP;
	
	while ((r = sys_ipc_try_send(to_env, val, pg, perm)) != 0) {
  801fd4:	56                   	push   %esi
  801fd5:	53                   	push   %ebx
  801fd6:	57                   	push   %edi
  801fd7:	ff 75 08             	pushl  0x8(%ebp)
  801fda:	e8 93 f1 ff ff       	call   801172 <sys_ipc_try_send>
  801fdf:	83 c4 10             	add    $0x10,%esp
  801fe2:	85 c0                	test   %eax,%eax
  801fe4:	75 d0                	jne    801fb6 <ipc_send+0x1d>
		} else {
			panic("ipc_send error %e\n", r);
		}
	}
	return;
}
  801fe6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801fe9:	5b                   	pop    %ebx
  801fea:	5e                   	pop    %esi
  801feb:	5f                   	pop    %edi
  801fec:	c9                   	leave  
  801fed:	c3                   	ret    

00801fee <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801fee:	55                   	push   %ebp
  801fef:	89 e5                	mov    %esp,%ebp
  801ff1:	53                   	push   %ebx
  801ff2:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	for (i = 0; i < NENV; i++)
		if (envs[i].env_type == type)
  801ff5:	39 1d 50 00 c0 ee    	cmp    %ebx,0xeec00050
  801ffb:	74 22                	je     80201f <ipc_find_env+0x31>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801ffd:	b8 01 00 00 00       	mov    $0x1,%eax
		if (envs[i].env_type == type)
  802002:	8d 0c 85 00 00 00 00 	lea    0x0(,%eax,4),%ecx
  802009:	89 c2                	mov    %eax,%edx
  80200b:	c1 e2 07             	shl    $0x7,%edx
  80200e:	29 ca                	sub    %ecx,%edx
  802010:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  802016:	8b 52 50             	mov    0x50(%edx),%edx
  802019:	39 da                	cmp    %ebx,%edx
  80201b:	75 1d                	jne    80203a <ipc_find_env+0x4c>
  80201d:	eb 05                	jmp    802024 <ipc_find_env+0x36>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  80201f:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
			return envs[i].env_id;
  802024:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  80202b:	c1 e0 07             	shl    $0x7,%eax
  80202e:	29 d0                	sub    %edx,%eax
  802030:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  802035:	8b 40 40             	mov    0x40(%eax),%eax
  802038:	eb 0c                	jmp    802046 <ipc_find_env+0x58>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  80203a:	40                   	inc    %eax
  80203b:	3d 00 04 00 00       	cmp    $0x400,%eax
  802040:	75 c0                	jne    802002 <ipc_find_env+0x14>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  802042:	66 b8 00 00          	mov    $0x0,%ax
}
  802046:	5b                   	pop    %ebx
  802047:	c9                   	leave  
  802048:	c3                   	ret    
  802049:	00 00                	add    %al,(%eax)
	...

0080204c <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  80204c:	55                   	push   %ebp
  80204d:	89 e5                	mov    %esp,%ebp
  80204f:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802052:	89 c2                	mov    %eax,%edx
  802054:	c1 ea 16             	shr    $0x16,%edx
  802057:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80205e:	f6 c2 01             	test   $0x1,%dl
  802061:	74 1e                	je     802081 <pageref+0x35>
		return 0;
	pte = uvpt[PGNUM(v)];
  802063:	c1 e8 0c             	shr    $0xc,%eax
  802066:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  80206d:	a8 01                	test   $0x1,%al
  80206f:	74 17                	je     802088 <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802071:	c1 e8 0c             	shr    $0xc,%eax
  802074:	66 8b 04 c5 04 00 00 	mov    -0x10fffffc(,%eax,8),%ax
  80207b:	ef 
  80207c:	0f b7 c0             	movzwl %ax,%eax
  80207f:	eb 0c                	jmp    80208d <pageref+0x41>
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
		return 0;
  802081:	b8 00 00 00 00       	mov    $0x0,%eax
  802086:	eb 05                	jmp    80208d <pageref+0x41>
	pte = uvpt[PGNUM(v)];
	if (!(pte & PTE_P))
		return 0;
  802088:	b8 00 00 00 00       	mov    $0x0,%eax
	return pages[PGNUM(pte)].pp_ref;
}
  80208d:	c9                   	leave  
  80208e:	c3                   	ret    
	...

00802090 <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  802090:	55                   	push   %ebp
  802091:	89 e5                	mov    %esp,%ebp
  802093:	57                   	push   %edi
  802094:	56                   	push   %esi
  802095:	83 ec 10             	sub    $0x10,%esp
  802098:	8b 7d 08             	mov    0x8(%ebp),%edi
  80209b:	8b 4d 10             	mov    0x10(%ebp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  80209e:	89 7d f0             	mov    %edi,-0x10(%ebp)
  8020a1:	8b 75 0c             	mov    0xc(%ebp),%esi
  const DWunion dd = {.ll = d};
  8020a4:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  8020a7:	8b 45 14             	mov    0x14(%ebp),%eax
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  8020aa:	85 c0                	test   %eax,%eax
  8020ac:	75 2e                	jne    8020dc <__udivdi3+0x4c>
    {
      if (d0 > n1)
  8020ae:	39 f1                	cmp    %esi,%ecx
  8020b0:	77 5a                	ja     80210c <__udivdi3+0x7c>
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  8020b2:	85 c9                	test   %ecx,%ecx
  8020b4:	75 0b                	jne    8020c1 <__udivdi3+0x31>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  8020b6:	b8 01 00 00 00       	mov    $0x1,%eax
  8020bb:	31 d2                	xor    %edx,%edx
  8020bd:	f7 f1                	div    %ecx
  8020bf:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  8020c1:	31 d2                	xor    %edx,%edx
  8020c3:	89 f0                	mov    %esi,%eax
  8020c5:	f7 f1                	div    %ecx
  8020c7:	89 c6                	mov    %eax,%esi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  8020c9:	89 f8                	mov    %edi,%eax
  8020cb:	f7 f1                	div    %ecx
  8020cd:	89 c7                	mov    %eax,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  8020cf:	89 f8                	mov    %edi,%eax
  8020d1:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  8020d3:	83 c4 10             	add    $0x10,%esp
  8020d6:	5e                   	pop    %esi
  8020d7:	5f                   	pop    %edi
  8020d8:	c9                   	leave  
  8020d9:	c3                   	ret    
  8020da:	66 90                	xchg   %ax,%ax
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  8020dc:	39 f0                	cmp    %esi,%eax
  8020de:	77 1c                	ja     8020fc <__udivdi3+0x6c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  8020e0:	0f bd f8             	bsr    %eax,%edi
	  if (bm == 0)
  8020e3:	83 f7 1f             	xor    $0x1f,%edi
  8020e6:	75 3c                	jne    802124 <__udivdi3+0x94>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  8020e8:	39 f0                	cmp    %esi,%eax
  8020ea:	0f 82 90 00 00 00    	jb     802180 <__udivdi3+0xf0>
  8020f0:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8020f3:	39 55 f4             	cmp    %edx,-0xc(%ebp)
  8020f6:	0f 86 84 00 00 00    	jbe    802180 <__udivdi3+0xf0>
  8020fc:	31 f6                	xor    %esi,%esi
  8020fe:	31 ff                	xor    %edi,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  802100:	89 f8                	mov    %edi,%eax
  802102:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  802104:	83 c4 10             	add    $0x10,%esp
  802107:	5e                   	pop    %esi
  802108:	5f                   	pop    %edi
  802109:	c9                   	leave  
  80210a:	c3                   	ret    
  80210b:	90                   	nop
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  80210c:	89 f2                	mov    %esi,%edx
  80210e:	89 f8                	mov    %edi,%eax
  802110:	f7 f1                	div    %ecx
  802112:	89 c7                	mov    %eax,%edi
  802114:	31 f6                	xor    %esi,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  802116:	89 f8                	mov    %edi,%eax
  802118:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  80211a:	83 c4 10             	add    $0x10,%esp
  80211d:	5e                   	pop    %esi
  80211e:	5f                   	pop    %edi
  80211f:	c9                   	leave  
  802120:	c3                   	ret    
  802121:	8d 76 00             	lea    0x0(%esi),%esi
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  802124:	89 f9                	mov    %edi,%ecx
  802126:	d3 e0                	shl    %cl,%eax
  802128:	89 45 e8             	mov    %eax,-0x18(%ebp)
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  80212b:	b8 20 00 00 00       	mov    $0x20,%eax
  802130:	29 f8                	sub    %edi,%eax

	      d1 = (d1 << bm) | (d0 >> b);
  802132:	8b 55 f4             	mov    -0xc(%ebp),%edx
  802135:	88 c1                	mov    %al,%cl
  802137:	d3 ea                	shr    %cl,%edx
  802139:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  80213c:	09 ca                	or     %ecx,%edx
  80213e:	89 55 ec             	mov    %edx,-0x14(%ebp)
	      d0 = d0 << bm;
  802141:	8b 55 f4             	mov    -0xc(%ebp),%edx
  802144:	89 f9                	mov    %edi,%ecx
  802146:	d3 e2                	shl    %cl,%edx
  802148:	89 55 f4             	mov    %edx,-0xc(%ebp)
	      n2 = n1 >> b;
  80214b:	89 f2                	mov    %esi,%edx
  80214d:	88 c1                	mov    %al,%cl
  80214f:	d3 ea                	shr    %cl,%edx
  802151:	89 55 e8             	mov    %edx,-0x18(%ebp)
	      n1 = (n1 << bm) | (n0 >> b);
  802154:	89 f2                	mov    %esi,%edx
  802156:	89 f9                	mov    %edi,%ecx
  802158:	d3 e2                	shl    %cl,%edx
  80215a:	8b 75 f0             	mov    -0x10(%ebp),%esi
  80215d:	88 c1                	mov    %al,%cl
  80215f:	d3 ee                	shr    %cl,%esi
  802161:	09 d6                	or     %edx,%esi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  802163:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  802166:	89 f0                	mov    %esi,%eax
  802168:	89 ca                	mov    %ecx,%edx
  80216a:	f7 75 ec             	divl   -0x14(%ebp)
  80216d:	89 d1                	mov    %edx,%ecx
  80216f:	89 c6                	mov    %eax,%esi
	      umul_ppmm (m1, m0, q0, d0);
  802171:	f7 65 f4             	mull   -0xc(%ebp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  802174:	39 d1                	cmp    %edx,%ecx
  802176:	72 28                	jb     8021a0 <__udivdi3+0x110>
  802178:	74 1a                	je     802194 <__udivdi3+0x104>
  80217a:	89 f7                	mov    %esi,%edi
  80217c:	31 f6                	xor    %esi,%esi
  80217e:	eb 80                	jmp    802100 <__udivdi3+0x70>
	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  802180:	31 f6                	xor    %esi,%esi
  802182:	bf 01 00 00 00       	mov    $0x1,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  802187:	89 f8                	mov    %edi,%eax
  802189:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  80218b:	83 c4 10             	add    $0x10,%esp
  80218e:	5e                   	pop    %esi
  80218f:	5f                   	pop    %edi
  802190:	c9                   	leave  
  802191:	c3                   	ret    
  802192:	66 90                	xchg   %ax,%ax

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  802194:	8b 55 f0             	mov    -0x10(%ebp),%edx
  802197:	89 f9                	mov    %edi,%ecx
  802199:	d3 e2                	shl    %cl,%edx

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  80219b:	39 c2                	cmp    %eax,%edx
  80219d:	73 db                	jae    80217a <__udivdi3+0xea>
  80219f:	90                   	nop
		{
		  q0--;
  8021a0:	8d 7e ff             	lea    -0x1(%esi),%edi
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  8021a3:	31 f6                	xor    %esi,%esi
  8021a5:	e9 56 ff ff ff       	jmp    802100 <__udivdi3+0x70>
	...

008021ac <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  8021ac:	55                   	push   %ebp
  8021ad:	89 e5                	mov    %esp,%ebp
  8021af:	57                   	push   %edi
  8021b0:	56                   	push   %esi
  8021b1:	83 ec 20             	sub    $0x20,%esp
  8021b4:	8b 45 08             	mov    0x8(%ebp),%eax
  8021b7:	8b 4d 10             	mov    0x10(%ebp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  8021ba:	89 45 e8             	mov    %eax,-0x18(%ebp)
  8021bd:	8b 75 0c             	mov    0xc(%ebp),%esi
  const DWunion dd = {.ll = d};
  8021c0:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  8021c3:	8b 7d 14             	mov    0x14(%ebp),%edi
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  8021c6:	89 45 f0             	mov    %eax,-0x10(%ebp)
  n1 = nn.s.high;
  8021c9:	89 f2                	mov    %esi,%edx

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  8021cb:	85 ff                	test   %edi,%edi
  8021cd:	75 15                	jne    8021e4 <__umoddi3+0x38>
    {
      if (d0 > n1)
  8021cf:	39 f1                	cmp    %esi,%ecx
  8021d1:	0f 86 99 00 00 00    	jbe    802270 <__umoddi3+0xc4>
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  8021d7:	f7 f1                	div    %ecx

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
  8021d9:	89 d0                	mov    %edx,%eax
  8021db:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  8021dd:	83 c4 20             	add    $0x20,%esp
  8021e0:	5e                   	pop    %esi
  8021e1:	5f                   	pop    %edi
  8021e2:	c9                   	leave  
  8021e3:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  8021e4:	39 f7                	cmp    %esi,%edi
  8021e6:	0f 87 a4 00 00 00    	ja     802290 <__umoddi3+0xe4>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  8021ec:	0f bd c7             	bsr    %edi,%eax
	  if (bm == 0)
  8021ef:	83 f0 1f             	xor    $0x1f,%eax
  8021f2:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8021f5:	0f 84 a1 00 00 00    	je     80229c <__umoddi3+0xf0>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  8021fb:	89 f8                	mov    %edi,%eax
  8021fd:	8a 4d ec             	mov    -0x14(%ebp),%cl
  802200:	d3 e0                	shl    %cl,%eax
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  802202:	bf 20 00 00 00       	mov    $0x20,%edi
  802207:	2b 7d ec             	sub    -0x14(%ebp),%edi

	      d1 = (d1 << bm) | (d0 >> b);
  80220a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80220d:	89 f9                	mov    %edi,%ecx
  80220f:	d3 ea                	shr    %cl,%edx
  802211:	09 c2                	or     %eax,%edx
  802213:	89 55 f0             	mov    %edx,-0x10(%ebp)
	      d0 = d0 << bm;
  802216:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802219:	8a 4d ec             	mov    -0x14(%ebp),%cl
  80221c:	d3 e0                	shl    %cl,%eax
  80221e:	89 45 f4             	mov    %eax,-0xc(%ebp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  802221:	89 f2                	mov    %esi,%edx
  802223:	d3 e2                	shl    %cl,%edx
	      n0 = n0 << bm;
  802225:	8b 45 e8             	mov    -0x18(%ebp),%eax
  802228:	d3 e0                	shl    %cl,%eax
  80222a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  80222d:	8b 45 e8             	mov    -0x18(%ebp),%eax
  802230:	89 f9                	mov    %edi,%ecx
  802232:	d3 e8                	shr    %cl,%eax
  802234:	09 d0                	or     %edx,%eax

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  802236:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  802238:	89 f2                	mov    %esi,%edx
  80223a:	f7 75 f0             	divl   -0x10(%ebp)
  80223d:	89 d6                	mov    %edx,%esi
	      umul_ppmm (m1, m0, q0, d0);
  80223f:	f7 65 f4             	mull   -0xc(%ebp)
  802242:	89 55 e8             	mov    %edx,-0x18(%ebp)
  802245:	89 c1                	mov    %eax,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  802247:	39 d6                	cmp    %edx,%esi
  802249:	72 71                	jb     8022bc <__umoddi3+0x110>
  80224b:	74 7f                	je     8022cc <__umoddi3+0x120>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  80224d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802250:	29 c8                	sub    %ecx,%eax
  802252:	19 d6                	sbb    %edx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
  802254:	8a 4d ec             	mov    -0x14(%ebp),%cl
  802257:	d3 e8                	shr    %cl,%eax
  802259:	89 f2                	mov    %esi,%edx
  80225b:	89 f9                	mov    %edi,%ecx
  80225d:	d3 e2                	shl    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
  80225f:	09 d0                	or     %edx,%eax
  802261:	89 f2                	mov    %esi,%edx
  802263:	8a 4d ec             	mov    -0x14(%ebp),%cl
  802266:	d3 ea                	shr    %cl,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  802268:	83 c4 20             	add    $0x20,%esp
  80226b:	5e                   	pop    %esi
  80226c:	5f                   	pop    %edi
  80226d:	c9                   	leave  
  80226e:	c3                   	ret    
  80226f:	90                   	nop
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  802270:	85 c9                	test   %ecx,%ecx
  802272:	75 0b                	jne    80227f <__umoddi3+0xd3>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  802274:	b8 01 00 00 00       	mov    $0x1,%eax
  802279:	31 d2                	xor    %edx,%edx
  80227b:	f7 f1                	div    %ecx
  80227d:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  80227f:	89 f0                	mov    %esi,%eax
  802281:	31 d2                	xor    %edx,%edx
  802283:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  802285:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802288:	f7 f1                	div    %ecx
  80228a:	e9 4a ff ff ff       	jmp    8021d9 <__umoddi3+0x2d>
  80228f:	90                   	nop
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
  802290:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  802292:	83 c4 20             	add    $0x20,%esp
  802295:	5e                   	pop    %esi
  802296:	5f                   	pop    %edi
  802297:	c9                   	leave  
  802298:	c3                   	ret    
  802299:	8d 76 00             	lea    0x0(%esi),%esi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  80229c:	39 f7                	cmp    %esi,%edi
  80229e:	72 05                	jb     8022a5 <__umoddi3+0xf9>
  8022a0:	3b 4d f0             	cmp    -0x10(%ebp),%ecx
  8022a3:	77 0c                	ja     8022b1 <__umoddi3+0x105>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  8022a5:	89 f2                	mov    %esi,%edx
  8022a7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8022aa:	29 c8                	sub    %ecx,%eax
  8022ac:	19 fa                	sbb    %edi,%edx
  8022ae:	89 45 f0             	mov    %eax,-0x10(%ebp)

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
  8022b1:	8b 45 f0             	mov    -0x10(%ebp),%eax
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
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  8022bc:	8b 55 e8             	mov    -0x18(%ebp),%edx
  8022bf:	89 c1                	mov    %eax,%ecx
  8022c1:	2b 4d f4             	sub    -0xc(%ebp),%ecx
  8022c4:	1b 55 f0             	sbb    -0x10(%ebp),%edx
  8022c7:	eb 84                	jmp    80224d <__umoddi3+0xa1>
  8022c9:	8d 76 00             	lea    0x0(%esi),%esi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  8022cc:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  8022cf:	72 eb                	jb     8022bc <__umoddi3+0x110>
  8022d1:	89 f2                	mov    %esi,%edx
  8022d3:	e9 75 ff ff ff       	jmp    80224d <__umoddi3+0xa1>
