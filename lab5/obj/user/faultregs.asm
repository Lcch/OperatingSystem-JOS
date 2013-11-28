
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
  800045:	68 31 23 80 00       	push   $0x802331
  80004a:	68 00 23 80 00       	push   $0x802300
  80004f:	e8 10 06 00 00       	call   800664 <cprintf>
			cprintf("MISMATCH\n");				\
			mismatch = 1;					\
		}							\
	} while (0)

	CHECK(edi, regs.reg_edi);
  800054:	ff 36                	pushl  (%esi)
  800056:	ff 33                	pushl  (%ebx)
  800058:	68 10 23 80 00       	push   $0x802310
  80005d:	68 14 23 80 00       	push   $0x802314
  800062:	e8 fd 05 00 00       	call   800664 <cprintf>
  800067:	83 c4 20             	add    $0x20,%esp
  80006a:	8b 06                	mov    (%esi),%eax
  80006c:	39 03                	cmp    %eax,(%ebx)
  80006e:	75 17                	jne    800087 <check_regs+0x53>
  800070:	83 ec 0c             	sub    $0xc,%esp
  800073:	68 24 23 80 00       	push   $0x802324
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
  80008a:	68 28 23 80 00       	push   $0x802328
  80008f:	e8 d0 05 00 00       	call   800664 <cprintf>
  800094:	83 c4 10             	add    $0x10,%esp
  800097:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(esi, regs.reg_esi);
  80009c:	ff 76 04             	pushl  0x4(%esi)
  80009f:	ff 73 04             	pushl  0x4(%ebx)
  8000a2:	68 32 23 80 00       	push   $0x802332
  8000a7:	68 14 23 80 00       	push   $0x802314
  8000ac:	e8 b3 05 00 00       	call   800664 <cprintf>
  8000b1:	83 c4 10             	add    $0x10,%esp
  8000b4:	8b 46 04             	mov    0x4(%esi),%eax
  8000b7:	39 43 04             	cmp    %eax,0x4(%ebx)
  8000ba:	75 12                	jne    8000ce <check_regs+0x9a>
  8000bc:	83 ec 0c             	sub    $0xc,%esp
  8000bf:	68 24 23 80 00       	push   $0x802324
  8000c4:	e8 9b 05 00 00       	call   800664 <cprintf>
  8000c9:	83 c4 10             	add    $0x10,%esp
  8000cc:	eb 15                	jmp    8000e3 <check_regs+0xaf>
  8000ce:	83 ec 0c             	sub    $0xc,%esp
  8000d1:	68 28 23 80 00       	push   $0x802328
  8000d6:	e8 89 05 00 00       	call   800664 <cprintf>
  8000db:	83 c4 10             	add    $0x10,%esp
  8000de:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(ebp, regs.reg_ebp);
  8000e3:	ff 76 08             	pushl  0x8(%esi)
  8000e6:	ff 73 08             	pushl  0x8(%ebx)
  8000e9:	68 36 23 80 00       	push   $0x802336
  8000ee:	68 14 23 80 00       	push   $0x802314
  8000f3:	e8 6c 05 00 00       	call   800664 <cprintf>
  8000f8:	83 c4 10             	add    $0x10,%esp
  8000fb:	8b 46 08             	mov    0x8(%esi),%eax
  8000fe:	39 43 08             	cmp    %eax,0x8(%ebx)
  800101:	75 12                	jne    800115 <check_regs+0xe1>
  800103:	83 ec 0c             	sub    $0xc,%esp
  800106:	68 24 23 80 00       	push   $0x802324
  80010b:	e8 54 05 00 00       	call   800664 <cprintf>
  800110:	83 c4 10             	add    $0x10,%esp
  800113:	eb 15                	jmp    80012a <check_regs+0xf6>
  800115:	83 ec 0c             	sub    $0xc,%esp
  800118:	68 28 23 80 00       	push   $0x802328
  80011d:	e8 42 05 00 00       	call   800664 <cprintf>
  800122:	83 c4 10             	add    $0x10,%esp
  800125:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(ebx, regs.reg_ebx);
  80012a:	ff 76 10             	pushl  0x10(%esi)
  80012d:	ff 73 10             	pushl  0x10(%ebx)
  800130:	68 3a 23 80 00       	push   $0x80233a
  800135:	68 14 23 80 00       	push   $0x802314
  80013a:	e8 25 05 00 00       	call   800664 <cprintf>
  80013f:	83 c4 10             	add    $0x10,%esp
  800142:	8b 46 10             	mov    0x10(%esi),%eax
  800145:	39 43 10             	cmp    %eax,0x10(%ebx)
  800148:	75 12                	jne    80015c <check_regs+0x128>
  80014a:	83 ec 0c             	sub    $0xc,%esp
  80014d:	68 24 23 80 00       	push   $0x802324
  800152:	e8 0d 05 00 00       	call   800664 <cprintf>
  800157:	83 c4 10             	add    $0x10,%esp
  80015a:	eb 15                	jmp    800171 <check_regs+0x13d>
  80015c:	83 ec 0c             	sub    $0xc,%esp
  80015f:	68 28 23 80 00       	push   $0x802328
  800164:	e8 fb 04 00 00       	call   800664 <cprintf>
  800169:	83 c4 10             	add    $0x10,%esp
  80016c:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(edx, regs.reg_edx);
  800171:	ff 76 14             	pushl  0x14(%esi)
  800174:	ff 73 14             	pushl  0x14(%ebx)
  800177:	68 3e 23 80 00       	push   $0x80233e
  80017c:	68 14 23 80 00       	push   $0x802314
  800181:	e8 de 04 00 00       	call   800664 <cprintf>
  800186:	83 c4 10             	add    $0x10,%esp
  800189:	8b 46 14             	mov    0x14(%esi),%eax
  80018c:	39 43 14             	cmp    %eax,0x14(%ebx)
  80018f:	75 12                	jne    8001a3 <check_regs+0x16f>
  800191:	83 ec 0c             	sub    $0xc,%esp
  800194:	68 24 23 80 00       	push   $0x802324
  800199:	e8 c6 04 00 00       	call   800664 <cprintf>
  80019e:	83 c4 10             	add    $0x10,%esp
  8001a1:	eb 15                	jmp    8001b8 <check_regs+0x184>
  8001a3:	83 ec 0c             	sub    $0xc,%esp
  8001a6:	68 28 23 80 00       	push   $0x802328
  8001ab:	e8 b4 04 00 00       	call   800664 <cprintf>
  8001b0:	83 c4 10             	add    $0x10,%esp
  8001b3:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(ecx, regs.reg_ecx);
  8001b8:	ff 76 18             	pushl  0x18(%esi)
  8001bb:	ff 73 18             	pushl  0x18(%ebx)
  8001be:	68 42 23 80 00       	push   $0x802342
  8001c3:	68 14 23 80 00       	push   $0x802314
  8001c8:	e8 97 04 00 00       	call   800664 <cprintf>
  8001cd:	83 c4 10             	add    $0x10,%esp
  8001d0:	8b 46 18             	mov    0x18(%esi),%eax
  8001d3:	39 43 18             	cmp    %eax,0x18(%ebx)
  8001d6:	75 12                	jne    8001ea <check_regs+0x1b6>
  8001d8:	83 ec 0c             	sub    $0xc,%esp
  8001db:	68 24 23 80 00       	push   $0x802324
  8001e0:	e8 7f 04 00 00       	call   800664 <cprintf>
  8001e5:	83 c4 10             	add    $0x10,%esp
  8001e8:	eb 15                	jmp    8001ff <check_regs+0x1cb>
  8001ea:	83 ec 0c             	sub    $0xc,%esp
  8001ed:	68 28 23 80 00       	push   $0x802328
  8001f2:	e8 6d 04 00 00       	call   800664 <cprintf>
  8001f7:	83 c4 10             	add    $0x10,%esp
  8001fa:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(eax, regs.reg_eax);
  8001ff:	ff 76 1c             	pushl  0x1c(%esi)
  800202:	ff 73 1c             	pushl  0x1c(%ebx)
  800205:	68 46 23 80 00       	push   $0x802346
  80020a:	68 14 23 80 00       	push   $0x802314
  80020f:	e8 50 04 00 00       	call   800664 <cprintf>
  800214:	83 c4 10             	add    $0x10,%esp
  800217:	8b 46 1c             	mov    0x1c(%esi),%eax
  80021a:	39 43 1c             	cmp    %eax,0x1c(%ebx)
  80021d:	75 12                	jne    800231 <check_regs+0x1fd>
  80021f:	83 ec 0c             	sub    $0xc,%esp
  800222:	68 24 23 80 00       	push   $0x802324
  800227:	e8 38 04 00 00       	call   800664 <cprintf>
  80022c:	83 c4 10             	add    $0x10,%esp
  80022f:	eb 15                	jmp    800246 <check_regs+0x212>
  800231:	83 ec 0c             	sub    $0xc,%esp
  800234:	68 28 23 80 00       	push   $0x802328
  800239:	e8 26 04 00 00       	call   800664 <cprintf>
  80023e:	83 c4 10             	add    $0x10,%esp
  800241:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(eip, eip);
  800246:	ff 76 20             	pushl  0x20(%esi)
  800249:	ff 73 20             	pushl  0x20(%ebx)
  80024c:	68 4a 23 80 00       	push   $0x80234a
  800251:	68 14 23 80 00       	push   $0x802314
  800256:	e8 09 04 00 00       	call   800664 <cprintf>
  80025b:	83 c4 10             	add    $0x10,%esp
  80025e:	8b 46 20             	mov    0x20(%esi),%eax
  800261:	39 43 20             	cmp    %eax,0x20(%ebx)
  800264:	75 12                	jne    800278 <check_regs+0x244>
  800266:	83 ec 0c             	sub    $0xc,%esp
  800269:	68 24 23 80 00       	push   $0x802324
  80026e:	e8 f1 03 00 00       	call   800664 <cprintf>
  800273:	83 c4 10             	add    $0x10,%esp
  800276:	eb 15                	jmp    80028d <check_regs+0x259>
  800278:	83 ec 0c             	sub    $0xc,%esp
  80027b:	68 28 23 80 00       	push   $0x802328
  800280:	e8 df 03 00 00       	call   800664 <cprintf>
  800285:	83 c4 10             	add    $0x10,%esp
  800288:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(eflags, eflags);
  80028d:	ff 76 24             	pushl  0x24(%esi)
  800290:	ff 73 24             	pushl  0x24(%ebx)
  800293:	68 4e 23 80 00       	push   $0x80234e
  800298:	68 14 23 80 00       	push   $0x802314
  80029d:	e8 c2 03 00 00       	call   800664 <cprintf>
  8002a2:	83 c4 10             	add    $0x10,%esp
  8002a5:	8b 46 24             	mov    0x24(%esi),%eax
  8002a8:	39 43 24             	cmp    %eax,0x24(%ebx)
  8002ab:	75 12                	jne    8002bf <check_regs+0x28b>
  8002ad:	83 ec 0c             	sub    $0xc,%esp
  8002b0:	68 24 23 80 00       	push   $0x802324
  8002b5:	e8 aa 03 00 00       	call   800664 <cprintf>
  8002ba:	83 c4 10             	add    $0x10,%esp
  8002bd:	eb 15                	jmp    8002d4 <check_regs+0x2a0>
  8002bf:	83 ec 0c             	sub    $0xc,%esp
  8002c2:	68 28 23 80 00       	push   $0x802328
  8002c7:	e8 98 03 00 00       	call   800664 <cprintf>
  8002cc:	83 c4 10             	add    $0x10,%esp
  8002cf:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(esp, esp);
  8002d4:	ff 76 28             	pushl  0x28(%esi)
  8002d7:	ff 73 28             	pushl  0x28(%ebx)
  8002da:	68 55 23 80 00       	push   $0x802355
  8002df:	68 14 23 80 00       	push   $0x802314
  8002e4:	e8 7b 03 00 00       	call   800664 <cprintf>
  8002e9:	83 c4 10             	add    $0x10,%esp
  8002ec:	8b 46 28             	mov    0x28(%esi),%eax
  8002ef:	39 43 28             	cmp    %eax,0x28(%ebx)
  8002f2:	75 26                	jne    80031a <check_regs+0x2e6>
  8002f4:	83 ec 0c             	sub    $0xc,%esp
  8002f7:	68 24 23 80 00       	push   $0x802324
  8002fc:	e8 63 03 00 00       	call   800664 <cprintf>

#undef CHECK

	cprintf("Registers %s ", testname);
  800301:	83 c4 08             	add    $0x8,%esp
  800304:	ff 75 0c             	pushl  0xc(%ebp)
  800307:	68 59 23 80 00       	push   $0x802359
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
  80031d:	68 28 23 80 00       	push   $0x802328
  800322:	e8 3d 03 00 00       	call   800664 <cprintf>

#undef CHECK

	cprintf("Registers %s ", testname);
  800327:	83 c4 08             	add    $0x8,%esp
  80032a:	ff 75 0c             	pushl  0xc(%ebp)
  80032d:	68 59 23 80 00       	push   $0x802359
  800332:	e8 2d 03 00 00       	call   800664 <cprintf>
  800337:	83 c4 10             	add    $0x10,%esp
  80033a:	eb 12                	jmp    80034e <check_regs+0x31a>
	if (!mismatch)
		cprintf("OK\n");
  80033c:	83 ec 0c             	sub    $0xc,%esp
  80033f:	68 24 23 80 00       	push   $0x802324
  800344:	e8 1b 03 00 00       	call   800664 <cprintf>
  800349:	83 c4 10             	add    $0x10,%esp
  80034c:	eb 10                	jmp    80035e <check_regs+0x32a>
	else
		cprintf("MISMATCH\n");
  80034e:	83 ec 0c             	sub    $0xc,%esp
  800351:	68 28 23 80 00       	push   $0x802328
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
  80037f:	68 c0 23 80 00       	push   $0x8023c0
  800384:	6a 51                	push   $0x51
  800386:	68 67 23 80 00       	push   $0x802367
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
  8003b8:	68 7f 23 80 00       	push   $0x80237f
  8003bd:	68 8d 23 80 00       	push   $0x80238d
  8003c2:	b9 80 40 80 00       	mov    $0x804080,%ecx
  8003c7:	ba 78 23 80 00       	mov    $0x802378,%edx
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
  8003ef:	68 94 23 80 00       	push   $0x802394
  8003f4:	6a 5c                	push   $0x5c
  8003f6:	68 67 23 80 00       	push   $0x802367
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
  800412:	e8 ed 0d 00 00       	call   801204 <set_pgfault_handler>

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
  8004e1:	68 f4 23 80 00       	push   $0x8023f4
  8004e6:	e8 79 01 00 00       	call   800664 <cprintf>
  8004eb:	83 c4 10             	add    $0x10,%esp
	after.eip = before.eip;
  8004ee:	a1 20 40 80 00       	mov    0x804020,%eax
  8004f3:	a3 60 40 80 00       	mov    %eax,0x804060

	check_regs(&before, "before", &after, "after", "after page-fault");
  8004f8:	83 ec 08             	sub    $0x8,%esp
  8004fb:	68 a7 23 80 00       	push   $0x8023a7
  800500:	68 b8 23 80 00       	push   $0x8023b8
  800505:	b9 40 40 80 00       	mov    $0x804040,%ecx
  80050a:	ba 78 23 80 00       	mov    $0x802378,%edx
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
  800576:	e8 27 0f 00 00       	call   8014a2 <close_all>
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
  8005aa:	68 20 24 80 00       	push   $0x802420
  8005af:	e8 b0 00 00 00       	call   800664 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8005b4:	83 c4 18             	add    $0x18,%esp
  8005b7:	56                   	push   %esi
  8005b8:	ff 75 10             	pushl  0x10(%ebp)
  8005bb:	e8 53 00 00 00       	call   800613 <vcprintf>
	cprintf("\n");
  8005c0:	c7 04 24 30 23 80 00 	movl   $0x802330,(%esp)
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
  8006cc:	e8 e7 19 00 00       	call   8020b8 <__udivdi3>
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
  800708:	e8 c7 1a 00 00       	call   8021d4 <__umoddi3>
  80070d:	83 c4 14             	add    $0x14,%esp
  800710:	0f be 80 43 24 80 00 	movsbl 0x802443(%eax),%eax
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
  800854:	ff 24 85 80 25 80 00 	jmp    *0x802580(,%eax,4)
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
  800900:	8b 04 85 e0 26 80 00 	mov    0x8026e0(,%eax,4),%eax
  800907:	85 c0                	test   %eax,%eax
  800909:	75 1a                	jne    800925 <vprintfmt+0x15c>
				printfmt(putch, putdat, "error %d", err);
  80090b:	52                   	push   %edx
  80090c:	68 5b 24 80 00       	push   $0x80245b
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
  800926:	68 65 28 80 00       	push   $0x802865
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
  80095c:	c7 45 d0 54 24 80 00 	movl   $0x802454,-0x30(%ebp)
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
  800fca:	68 3f 27 80 00       	push   $0x80273f
  800fcf:	6a 42                	push   $0x42
  800fd1:	68 5c 27 80 00       	push   $0x80275c
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

008011dc <sys_exec>:

int
sys_exec(uint32_t eip, uint32_t esp, void * ph, uint32_t elf_phnum)
{
  8011dc:	55                   	push   %ebp
  8011dd:	89 e5                	mov    %esp,%ebp
  8011df:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_exec, 0, eip, esp, (uint32_t)ph, elf_phnum, 0);
  8011e2:	6a 00                	push   $0x0
  8011e4:	ff 75 14             	pushl  0x14(%ebp)
  8011e7:	ff 75 10             	pushl  0x10(%ebp)
  8011ea:	ff 75 0c             	pushl  0xc(%ebp)
  8011ed:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8011f0:	ba 00 00 00 00       	mov    $0x0,%edx
  8011f5:	b8 0f 00 00 00       	mov    $0xf,%eax
  8011fa:	e8 99 fd ff ff       	call   800f98 <syscall>
  8011ff:	c9                   	leave  
  801200:	c3                   	ret    
  801201:	00 00                	add    %al,(%eax)
	...

00801204 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801204:	55                   	push   %ebp
  801205:	89 e5                	mov    %esp,%ebp
  801207:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  80120a:	83 3d b4 40 80 00 00 	cmpl   $0x0,0x8040b4
  801211:	75 52                	jne    801265 <set_pgfault_handler+0x61>
		// First time through!	
		// LAB 4: Your code here.

		//int sys_page_alloc(envid_t envid, void *va, int perm)
		r = sys_page_alloc(0, (void*)(UXSTACKTOP - PGSIZE), PTE_U | PTE_W | PTE_P);
  801213:	83 ec 04             	sub    $0x4,%esp
  801216:	6a 07                	push   $0x7
  801218:	68 00 f0 bf ee       	push   $0xeebff000
  80121d:	6a 00                	push   $0x0
  80121f:	e8 78 fe ff ff       	call   80109c <sys_page_alloc>
		if (r < 0) {
  801224:	83 c4 10             	add    $0x10,%esp
  801227:	85 c0                	test   %eax,%eax
  801229:	79 12                	jns    80123d <set_pgfault_handler+0x39>
			panic("sys_page_alloc error : %e\n", r);
  80122b:	50                   	push   %eax
  80122c:	68 6a 27 80 00       	push   $0x80276a
  801231:	6a 24                	push   $0x24
  801233:	68 85 27 80 00       	push   $0x802785
  801238:	e8 4f f3 ff ff       	call   80058c <_panic>
		}

		// how to know envid, put 0, envid2env will help us to get curenv in syscall
		r = sys_env_set_pgfault_upcall(0, _pgfault_upcall);		
  80123d:	83 ec 08             	sub    $0x8,%esp
  801240:	68 70 12 80 00       	push   $0x801270
  801245:	6a 00                	push   $0x0
  801247:	e8 03 ff ff ff       	call   80114f <sys_env_set_pgfault_upcall>
		if (r < 0) {
  80124c:	83 c4 10             	add    $0x10,%esp
  80124f:	85 c0                	test   %eax,%eax
  801251:	79 12                	jns    801265 <set_pgfault_handler+0x61>
			panic("sys_env_set_pgfault_upcall error : %e\n", r);
  801253:	50                   	push   %eax
  801254:	68 94 27 80 00       	push   $0x802794
  801259:	6a 2a                	push   $0x2a
  80125b:	68 85 27 80 00       	push   $0x802785
  801260:	e8 27 f3 ff ff       	call   80058c <_panic>
		}
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801265:	8b 45 08             	mov    0x8(%ebp),%eax
  801268:	a3 b4 40 80 00       	mov    %eax,0x8040b4
}
  80126d:	c9                   	leave  
  80126e:	c3                   	ret    
	...

00801270 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  801270:	54                   	push   %esp
	movl _pgfault_handler, %eax
  801271:	a1 b4 40 80 00       	mov    0x8040b4,%eax
	call *%eax
  801276:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  801278:	83 c4 04             	add    $0x4,%esp
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	
	// fix old esp
	movl 0x30(%esp), %eax
  80127b:	8b 44 24 30          	mov    0x30(%esp),%eax
	subl $0x4, %eax
  80127f:	83 e8 04             	sub    $0x4,%eax
	movl %eax, 0x30(%esp)
  801282:	89 44 24 30          	mov    %eax,0x30(%esp)

	// set trap-time %eip
	movl 0x28(%esp), %ebx
  801286:	8b 5c 24 28          	mov    0x28(%esp),%ebx
	movl %ebx, (%eax)
  80128a:	89 18                	mov    %ebx,(%eax)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	addl $0x08, %esp 	// ignore err_code and fault_va
  80128c:	83 c4 08             	add    $0x8,%esp
	popal 				// restore registers
  80128f:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $0x04, %esp 	// ignore eip 
  801290:	83 c4 04             	add    $0x4,%esp
	popfl				// modify eflags
  801293:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp
  801294:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  801295:	c3                   	ret    
	...

00801298 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801298:	55                   	push   %ebp
  801299:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80129b:	8b 45 08             	mov    0x8(%ebp),%eax
  80129e:	05 00 00 00 30       	add    $0x30000000,%eax
  8012a3:	c1 e8 0c             	shr    $0xc,%eax
}
  8012a6:	c9                   	leave  
  8012a7:	c3                   	ret    

008012a8 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8012a8:	55                   	push   %ebp
  8012a9:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  8012ab:	ff 75 08             	pushl  0x8(%ebp)
  8012ae:	e8 e5 ff ff ff       	call   801298 <fd2num>
  8012b3:	83 c4 04             	add    $0x4,%esp
  8012b6:	05 20 00 0d 00       	add    $0xd0020,%eax
  8012bb:	c1 e0 0c             	shl    $0xc,%eax
}
  8012be:	c9                   	leave  
  8012bf:	c3                   	ret    

008012c0 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8012c0:	55                   	push   %ebp
  8012c1:	89 e5                	mov    %esp,%ebp
  8012c3:	53                   	push   %ebx
  8012c4:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8012c7:	a1 00 dd 7b ef       	mov    0xef7bdd00,%eax
  8012cc:	a8 01                	test   $0x1,%al
  8012ce:	74 34                	je     801304 <fd_alloc+0x44>
  8012d0:	a1 00 00 74 ef       	mov    0xef740000,%eax
  8012d5:	a8 01                	test   $0x1,%al
  8012d7:	74 32                	je     80130b <fd_alloc+0x4b>
  8012d9:	b8 00 10 00 d0       	mov    $0xd0001000,%eax
  8012de:	89 c1                	mov    %eax,%ecx
  8012e0:	89 c2                	mov    %eax,%edx
  8012e2:	c1 ea 16             	shr    $0x16,%edx
  8012e5:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8012ec:	f6 c2 01             	test   $0x1,%dl
  8012ef:	74 1f                	je     801310 <fd_alloc+0x50>
  8012f1:	89 c2                	mov    %eax,%edx
  8012f3:	c1 ea 0c             	shr    $0xc,%edx
  8012f6:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8012fd:	f6 c2 01             	test   $0x1,%dl
  801300:	75 17                	jne    801319 <fd_alloc+0x59>
  801302:	eb 0c                	jmp    801310 <fd_alloc+0x50>
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  801304:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
  801309:	eb 05                	jmp    801310 <fd_alloc+0x50>
  80130b:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
  801310:	89 0b                	mov    %ecx,(%ebx)
			return 0;
  801312:	b8 00 00 00 00       	mov    $0x0,%eax
  801317:	eb 17                	jmp    801330 <fd_alloc+0x70>
  801319:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  80131e:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  801323:	75 b9                	jne    8012de <fd_alloc+0x1e>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801325:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_MAX_OPEN;
  80132b:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  801330:	5b                   	pop    %ebx
  801331:	c9                   	leave  
  801332:	c3                   	ret    

00801333 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  801333:	55                   	push   %ebp
  801334:	89 e5                	mov    %esp,%ebp
  801336:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801339:	83 f8 1f             	cmp    $0x1f,%eax
  80133c:	77 36                	ja     801374 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  80133e:	05 00 00 0d 00       	add    $0xd0000,%eax
  801343:	c1 e0 0c             	shl    $0xc,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801346:	89 c2                	mov    %eax,%edx
  801348:	c1 ea 16             	shr    $0x16,%edx
  80134b:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801352:	f6 c2 01             	test   $0x1,%dl
  801355:	74 24                	je     80137b <fd_lookup+0x48>
  801357:	89 c2                	mov    %eax,%edx
  801359:	c1 ea 0c             	shr    $0xc,%edx
  80135c:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801363:	f6 c2 01             	test   $0x1,%dl
  801366:	74 1a                	je     801382 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  801368:	8b 55 0c             	mov    0xc(%ebp),%edx
  80136b:	89 02                	mov    %eax,(%edx)
	return 0;
  80136d:	b8 00 00 00 00       	mov    $0x0,%eax
  801372:	eb 13                	jmp    801387 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801374:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801379:	eb 0c                	jmp    801387 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80137b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801380:	eb 05                	jmp    801387 <fd_lookup+0x54>
  801382:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  801387:	c9                   	leave  
  801388:	c3                   	ret    

00801389 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801389:	55                   	push   %ebp
  80138a:	89 e5                	mov    %esp,%ebp
  80138c:	53                   	push   %ebx
  80138d:	83 ec 04             	sub    $0x4,%esp
  801390:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801393:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
		if (devtab[i]->dev_id == dev_id) {
  801396:	39 0d 04 30 80 00    	cmp    %ecx,0x803004
  80139c:	74 0d                	je     8013ab <dev_lookup+0x22>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  80139e:	b8 00 00 00 00       	mov    $0x0,%eax
  8013a3:	eb 14                	jmp    8013b9 <dev_lookup+0x30>
		if (devtab[i]->dev_id == dev_id) {
  8013a5:	39 0a                	cmp    %ecx,(%edx)
  8013a7:	75 10                	jne    8013b9 <dev_lookup+0x30>
  8013a9:	eb 05                	jmp    8013b0 <dev_lookup+0x27>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8013ab:	ba 04 30 80 00       	mov    $0x803004,%edx
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
  8013b0:	89 13                	mov    %edx,(%ebx)
			return 0;
  8013b2:	b8 00 00 00 00       	mov    $0x0,%eax
  8013b7:	eb 31                	jmp    8013ea <dev_lookup+0x61>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8013b9:	40                   	inc    %eax
  8013ba:	8b 14 85 3c 28 80 00 	mov    0x80283c(,%eax,4),%edx
  8013c1:	85 d2                	test   %edx,%edx
  8013c3:	75 e0                	jne    8013a5 <dev_lookup+0x1c>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8013c5:	a1 b0 40 80 00       	mov    0x8040b0,%eax
  8013ca:	8b 40 48             	mov    0x48(%eax),%eax
  8013cd:	83 ec 04             	sub    $0x4,%esp
  8013d0:	51                   	push   %ecx
  8013d1:	50                   	push   %eax
  8013d2:	68 bc 27 80 00       	push   $0x8027bc
  8013d7:	e8 88 f2 ff ff       	call   800664 <cprintf>
	*dev = 0;
  8013dc:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_INVAL;
  8013e2:	83 c4 10             	add    $0x10,%esp
  8013e5:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8013ea:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8013ed:	c9                   	leave  
  8013ee:	c3                   	ret    

008013ef <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8013ef:	55                   	push   %ebp
  8013f0:	89 e5                	mov    %esp,%ebp
  8013f2:	56                   	push   %esi
  8013f3:	53                   	push   %ebx
  8013f4:	83 ec 20             	sub    $0x20,%esp
  8013f7:	8b 75 08             	mov    0x8(%ebp),%esi
  8013fa:	8a 45 0c             	mov    0xc(%ebp),%al
  8013fd:	88 45 e7             	mov    %al,-0x19(%ebp)
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801400:	56                   	push   %esi
  801401:	e8 92 fe ff ff       	call   801298 <fd2num>
  801406:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801409:	89 14 24             	mov    %edx,(%esp)
  80140c:	50                   	push   %eax
  80140d:	e8 21 ff ff ff       	call   801333 <fd_lookup>
  801412:	89 c3                	mov    %eax,%ebx
  801414:	83 c4 08             	add    $0x8,%esp
  801417:	85 c0                	test   %eax,%eax
  801419:	78 05                	js     801420 <fd_close+0x31>
	    || fd != fd2)
  80141b:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  80141e:	74 0d                	je     80142d <fd_close+0x3e>
		return (must_exist ? r : 0);
  801420:	80 7d e7 00          	cmpb   $0x0,-0x19(%ebp)
  801424:	75 48                	jne    80146e <fd_close+0x7f>
  801426:	bb 00 00 00 00       	mov    $0x0,%ebx
  80142b:	eb 41                	jmp    80146e <fd_close+0x7f>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  80142d:	83 ec 08             	sub    $0x8,%esp
  801430:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801433:	50                   	push   %eax
  801434:	ff 36                	pushl  (%esi)
  801436:	e8 4e ff ff ff       	call   801389 <dev_lookup>
  80143b:	89 c3                	mov    %eax,%ebx
  80143d:	83 c4 10             	add    $0x10,%esp
  801440:	85 c0                	test   %eax,%eax
  801442:	78 1c                	js     801460 <fd_close+0x71>
		if (dev->dev_close)
  801444:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801447:	8b 40 10             	mov    0x10(%eax),%eax
  80144a:	85 c0                	test   %eax,%eax
  80144c:	74 0d                	je     80145b <fd_close+0x6c>
			r = (*dev->dev_close)(fd);
  80144e:	83 ec 0c             	sub    $0xc,%esp
  801451:	56                   	push   %esi
  801452:	ff d0                	call   *%eax
  801454:	89 c3                	mov    %eax,%ebx
  801456:	83 c4 10             	add    $0x10,%esp
  801459:	eb 05                	jmp    801460 <fd_close+0x71>
		else
			r = 0;
  80145b:	bb 00 00 00 00       	mov    $0x0,%ebx
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801460:	83 ec 08             	sub    $0x8,%esp
  801463:	56                   	push   %esi
  801464:	6a 00                	push   $0x0
  801466:	e8 7b fc ff ff       	call   8010e6 <sys_page_unmap>
	return r;
  80146b:	83 c4 10             	add    $0x10,%esp
}
  80146e:	89 d8                	mov    %ebx,%eax
  801470:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801473:	5b                   	pop    %ebx
  801474:	5e                   	pop    %esi
  801475:	c9                   	leave  
  801476:	c3                   	ret    

00801477 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801477:	55                   	push   %ebp
  801478:	89 e5                	mov    %esp,%ebp
  80147a:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80147d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801480:	50                   	push   %eax
  801481:	ff 75 08             	pushl  0x8(%ebp)
  801484:	e8 aa fe ff ff       	call   801333 <fd_lookup>
  801489:	83 c4 08             	add    $0x8,%esp
  80148c:	85 c0                	test   %eax,%eax
  80148e:	78 10                	js     8014a0 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  801490:	83 ec 08             	sub    $0x8,%esp
  801493:	6a 01                	push   $0x1
  801495:	ff 75 f4             	pushl  -0xc(%ebp)
  801498:	e8 52 ff ff ff       	call   8013ef <fd_close>
  80149d:	83 c4 10             	add    $0x10,%esp
}
  8014a0:	c9                   	leave  
  8014a1:	c3                   	ret    

008014a2 <close_all>:

void
close_all(void)
{
  8014a2:	55                   	push   %ebp
  8014a3:	89 e5                	mov    %esp,%ebp
  8014a5:	53                   	push   %ebx
  8014a6:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8014a9:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8014ae:	83 ec 0c             	sub    $0xc,%esp
  8014b1:	53                   	push   %ebx
  8014b2:	e8 c0 ff ff ff       	call   801477 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  8014b7:	43                   	inc    %ebx
  8014b8:	83 c4 10             	add    $0x10,%esp
  8014bb:	83 fb 20             	cmp    $0x20,%ebx
  8014be:	75 ee                	jne    8014ae <close_all+0xc>
		close(i);
}
  8014c0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8014c3:	c9                   	leave  
  8014c4:	c3                   	ret    

008014c5 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8014c5:	55                   	push   %ebp
  8014c6:	89 e5                	mov    %esp,%ebp
  8014c8:	57                   	push   %edi
  8014c9:	56                   	push   %esi
  8014ca:	53                   	push   %ebx
  8014cb:	83 ec 2c             	sub    $0x2c,%esp
  8014ce:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8014d1:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8014d4:	50                   	push   %eax
  8014d5:	ff 75 08             	pushl  0x8(%ebp)
  8014d8:	e8 56 fe ff ff       	call   801333 <fd_lookup>
  8014dd:	89 c3                	mov    %eax,%ebx
  8014df:	83 c4 08             	add    $0x8,%esp
  8014e2:	85 c0                	test   %eax,%eax
  8014e4:	0f 88 c0 00 00 00    	js     8015aa <dup+0xe5>
		return r;
	close(newfdnum);
  8014ea:	83 ec 0c             	sub    $0xc,%esp
  8014ed:	57                   	push   %edi
  8014ee:	e8 84 ff ff ff       	call   801477 <close>

	newfd = INDEX2FD(newfdnum);
  8014f3:	8d b7 00 00 0d 00    	lea    0xd0000(%edi),%esi
  8014f9:	c1 e6 0c             	shl    $0xc,%esi
	ova = fd2data(oldfd);
  8014fc:	83 c4 04             	add    $0x4,%esp
  8014ff:	ff 75 e4             	pushl  -0x1c(%ebp)
  801502:	e8 a1 fd ff ff       	call   8012a8 <fd2data>
  801507:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  801509:	89 34 24             	mov    %esi,(%esp)
  80150c:	e8 97 fd ff ff       	call   8012a8 <fd2data>
  801511:	83 c4 10             	add    $0x10,%esp
  801514:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801517:	89 d8                	mov    %ebx,%eax
  801519:	c1 e8 16             	shr    $0x16,%eax
  80151c:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801523:	a8 01                	test   $0x1,%al
  801525:	74 37                	je     80155e <dup+0x99>
  801527:	89 d8                	mov    %ebx,%eax
  801529:	c1 e8 0c             	shr    $0xc,%eax
  80152c:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801533:	f6 c2 01             	test   $0x1,%dl
  801536:	74 26                	je     80155e <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801538:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80153f:	83 ec 0c             	sub    $0xc,%esp
  801542:	25 07 0e 00 00       	and    $0xe07,%eax
  801547:	50                   	push   %eax
  801548:	ff 75 d4             	pushl  -0x2c(%ebp)
  80154b:	6a 00                	push   $0x0
  80154d:	53                   	push   %ebx
  80154e:	6a 00                	push   $0x0
  801550:	e8 6b fb ff ff       	call   8010c0 <sys_page_map>
  801555:	89 c3                	mov    %eax,%ebx
  801557:	83 c4 20             	add    $0x20,%esp
  80155a:	85 c0                	test   %eax,%eax
  80155c:	78 2d                	js     80158b <dup+0xc6>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80155e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801561:	89 c2                	mov    %eax,%edx
  801563:	c1 ea 0c             	shr    $0xc,%edx
  801566:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80156d:	83 ec 0c             	sub    $0xc,%esp
  801570:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  801576:	52                   	push   %edx
  801577:	56                   	push   %esi
  801578:	6a 00                	push   $0x0
  80157a:	50                   	push   %eax
  80157b:	6a 00                	push   $0x0
  80157d:	e8 3e fb ff ff       	call   8010c0 <sys_page_map>
  801582:	89 c3                	mov    %eax,%ebx
  801584:	83 c4 20             	add    $0x20,%esp
  801587:	85 c0                	test   %eax,%eax
  801589:	79 1d                	jns    8015a8 <dup+0xe3>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  80158b:	83 ec 08             	sub    $0x8,%esp
  80158e:	56                   	push   %esi
  80158f:	6a 00                	push   $0x0
  801591:	e8 50 fb ff ff       	call   8010e6 <sys_page_unmap>
	sys_page_unmap(0, nva);
  801596:	83 c4 08             	add    $0x8,%esp
  801599:	ff 75 d4             	pushl  -0x2c(%ebp)
  80159c:	6a 00                	push   $0x0
  80159e:	e8 43 fb ff ff       	call   8010e6 <sys_page_unmap>
	return r;
  8015a3:	83 c4 10             	add    $0x10,%esp
  8015a6:	eb 02                	jmp    8015aa <dup+0xe5>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
		goto err;

	return newfdnum;
  8015a8:	89 fb                	mov    %edi,%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  8015aa:	89 d8                	mov    %ebx,%eax
  8015ac:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8015af:	5b                   	pop    %ebx
  8015b0:	5e                   	pop    %esi
  8015b1:	5f                   	pop    %edi
  8015b2:	c9                   	leave  
  8015b3:	c3                   	ret    

008015b4 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8015b4:	55                   	push   %ebp
  8015b5:	89 e5                	mov    %esp,%ebp
  8015b7:	53                   	push   %ebx
  8015b8:	83 ec 14             	sub    $0x14,%esp
  8015bb:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8015be:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8015c1:	50                   	push   %eax
  8015c2:	53                   	push   %ebx
  8015c3:	e8 6b fd ff ff       	call   801333 <fd_lookup>
  8015c8:	83 c4 08             	add    $0x8,%esp
  8015cb:	85 c0                	test   %eax,%eax
  8015cd:	78 67                	js     801636 <read+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015cf:	83 ec 08             	sub    $0x8,%esp
  8015d2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015d5:	50                   	push   %eax
  8015d6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015d9:	ff 30                	pushl  (%eax)
  8015db:	e8 a9 fd ff ff       	call   801389 <dev_lookup>
  8015e0:	83 c4 10             	add    $0x10,%esp
  8015e3:	85 c0                	test   %eax,%eax
  8015e5:	78 4f                	js     801636 <read+0x82>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8015e7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015ea:	8b 50 08             	mov    0x8(%eax),%edx
  8015ed:	83 e2 03             	and    $0x3,%edx
  8015f0:	83 fa 01             	cmp    $0x1,%edx
  8015f3:	75 21                	jne    801616 <read+0x62>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8015f5:	a1 b0 40 80 00       	mov    0x8040b0,%eax
  8015fa:	8b 40 48             	mov    0x48(%eax),%eax
  8015fd:	83 ec 04             	sub    $0x4,%esp
  801600:	53                   	push   %ebx
  801601:	50                   	push   %eax
  801602:	68 00 28 80 00       	push   $0x802800
  801607:	e8 58 f0 ff ff       	call   800664 <cprintf>
		return -E_INVAL;
  80160c:	83 c4 10             	add    $0x10,%esp
  80160f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801614:	eb 20                	jmp    801636 <read+0x82>
	}
	if (!dev->dev_read)
  801616:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801619:	8b 52 08             	mov    0x8(%edx),%edx
  80161c:	85 d2                	test   %edx,%edx
  80161e:	74 11                	je     801631 <read+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801620:	83 ec 04             	sub    $0x4,%esp
  801623:	ff 75 10             	pushl  0x10(%ebp)
  801626:	ff 75 0c             	pushl  0xc(%ebp)
  801629:	50                   	push   %eax
  80162a:	ff d2                	call   *%edx
  80162c:	83 c4 10             	add    $0x10,%esp
  80162f:	eb 05                	jmp    801636 <read+0x82>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801631:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_read)(fd, buf, n);
}
  801636:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801639:	c9                   	leave  
  80163a:	c3                   	ret    

0080163b <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  80163b:	55                   	push   %ebp
  80163c:	89 e5                	mov    %esp,%ebp
  80163e:	57                   	push   %edi
  80163f:	56                   	push   %esi
  801640:	53                   	push   %ebx
  801641:	83 ec 0c             	sub    $0xc,%esp
  801644:	8b 7d 08             	mov    0x8(%ebp),%edi
  801647:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80164a:	85 f6                	test   %esi,%esi
  80164c:	74 31                	je     80167f <readn+0x44>
  80164e:	b8 00 00 00 00       	mov    $0x0,%eax
  801653:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = read(fdnum, (char*)buf + tot, n - tot);
  801658:	83 ec 04             	sub    $0x4,%esp
  80165b:	89 f2                	mov    %esi,%edx
  80165d:	29 c2                	sub    %eax,%edx
  80165f:	52                   	push   %edx
  801660:	03 45 0c             	add    0xc(%ebp),%eax
  801663:	50                   	push   %eax
  801664:	57                   	push   %edi
  801665:	e8 4a ff ff ff       	call   8015b4 <read>
		if (m < 0)
  80166a:	83 c4 10             	add    $0x10,%esp
  80166d:	85 c0                	test   %eax,%eax
  80166f:	78 17                	js     801688 <readn+0x4d>
			return m;
		if (m == 0)
  801671:	85 c0                	test   %eax,%eax
  801673:	74 11                	je     801686 <readn+0x4b>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801675:	01 c3                	add    %eax,%ebx
  801677:	89 d8                	mov    %ebx,%eax
  801679:	39 f3                	cmp    %esi,%ebx
  80167b:	72 db                	jb     801658 <readn+0x1d>
  80167d:	eb 09                	jmp    801688 <readn+0x4d>
  80167f:	b8 00 00 00 00       	mov    $0x0,%eax
  801684:	eb 02                	jmp    801688 <readn+0x4d>
		m = read(fdnum, (char*)buf + tot, n - tot);
		if (m < 0)
			return m;
		if (m == 0)
  801686:	89 d8                	mov    %ebx,%eax
			break;
	}
	return tot;
}
  801688:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80168b:	5b                   	pop    %ebx
  80168c:	5e                   	pop    %esi
  80168d:	5f                   	pop    %edi
  80168e:	c9                   	leave  
  80168f:	c3                   	ret    

00801690 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801690:	55                   	push   %ebp
  801691:	89 e5                	mov    %esp,%ebp
  801693:	53                   	push   %ebx
  801694:	83 ec 14             	sub    $0x14,%esp
  801697:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80169a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80169d:	50                   	push   %eax
  80169e:	53                   	push   %ebx
  80169f:	e8 8f fc ff ff       	call   801333 <fd_lookup>
  8016a4:	83 c4 08             	add    $0x8,%esp
  8016a7:	85 c0                	test   %eax,%eax
  8016a9:	78 62                	js     80170d <write+0x7d>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016ab:	83 ec 08             	sub    $0x8,%esp
  8016ae:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016b1:	50                   	push   %eax
  8016b2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016b5:	ff 30                	pushl  (%eax)
  8016b7:	e8 cd fc ff ff       	call   801389 <dev_lookup>
  8016bc:	83 c4 10             	add    $0x10,%esp
  8016bf:	85 c0                	test   %eax,%eax
  8016c1:	78 4a                	js     80170d <write+0x7d>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8016c3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016c6:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8016ca:	75 21                	jne    8016ed <write+0x5d>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8016cc:	a1 b0 40 80 00       	mov    0x8040b0,%eax
  8016d1:	8b 40 48             	mov    0x48(%eax),%eax
  8016d4:	83 ec 04             	sub    $0x4,%esp
  8016d7:	53                   	push   %ebx
  8016d8:	50                   	push   %eax
  8016d9:	68 1c 28 80 00       	push   $0x80281c
  8016de:	e8 81 ef ff ff       	call   800664 <cprintf>
		return -E_INVAL;
  8016e3:	83 c4 10             	add    $0x10,%esp
  8016e6:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8016eb:	eb 20                	jmp    80170d <write+0x7d>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8016ed:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8016f0:	8b 52 0c             	mov    0xc(%edx),%edx
  8016f3:	85 d2                	test   %edx,%edx
  8016f5:	74 11                	je     801708 <write+0x78>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8016f7:	83 ec 04             	sub    $0x4,%esp
  8016fa:	ff 75 10             	pushl  0x10(%ebp)
  8016fd:	ff 75 0c             	pushl  0xc(%ebp)
  801700:	50                   	push   %eax
  801701:	ff d2                	call   *%edx
  801703:	83 c4 10             	add    $0x10,%esp
  801706:	eb 05                	jmp    80170d <write+0x7d>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801708:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  80170d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801710:	c9                   	leave  
  801711:	c3                   	ret    

00801712 <seek>:

int
seek(int fdnum, off_t offset)
{
  801712:	55                   	push   %ebp
  801713:	89 e5                	mov    %esp,%ebp
  801715:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801718:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80171b:	50                   	push   %eax
  80171c:	ff 75 08             	pushl  0x8(%ebp)
  80171f:	e8 0f fc ff ff       	call   801333 <fd_lookup>
  801724:	83 c4 08             	add    $0x8,%esp
  801727:	85 c0                	test   %eax,%eax
  801729:	78 0e                	js     801739 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  80172b:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80172e:	8b 55 0c             	mov    0xc(%ebp),%edx
  801731:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801734:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801739:	c9                   	leave  
  80173a:	c3                   	ret    

0080173b <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  80173b:	55                   	push   %ebp
  80173c:	89 e5                	mov    %esp,%ebp
  80173e:	53                   	push   %ebx
  80173f:	83 ec 14             	sub    $0x14,%esp
  801742:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801745:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801748:	50                   	push   %eax
  801749:	53                   	push   %ebx
  80174a:	e8 e4 fb ff ff       	call   801333 <fd_lookup>
  80174f:	83 c4 08             	add    $0x8,%esp
  801752:	85 c0                	test   %eax,%eax
  801754:	78 5f                	js     8017b5 <ftruncate+0x7a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801756:	83 ec 08             	sub    $0x8,%esp
  801759:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80175c:	50                   	push   %eax
  80175d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801760:	ff 30                	pushl  (%eax)
  801762:	e8 22 fc ff ff       	call   801389 <dev_lookup>
  801767:	83 c4 10             	add    $0x10,%esp
  80176a:	85 c0                	test   %eax,%eax
  80176c:	78 47                	js     8017b5 <ftruncate+0x7a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80176e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801771:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801775:	75 21                	jne    801798 <ftruncate+0x5d>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801777:	a1 b0 40 80 00       	mov    0x8040b0,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  80177c:	8b 40 48             	mov    0x48(%eax),%eax
  80177f:	83 ec 04             	sub    $0x4,%esp
  801782:	53                   	push   %ebx
  801783:	50                   	push   %eax
  801784:	68 dc 27 80 00       	push   $0x8027dc
  801789:	e8 d6 ee ff ff       	call   800664 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  80178e:	83 c4 10             	add    $0x10,%esp
  801791:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801796:	eb 1d                	jmp    8017b5 <ftruncate+0x7a>
	}
	if (!dev->dev_trunc)
  801798:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80179b:	8b 52 18             	mov    0x18(%edx),%edx
  80179e:	85 d2                	test   %edx,%edx
  8017a0:	74 0e                	je     8017b0 <ftruncate+0x75>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8017a2:	83 ec 08             	sub    $0x8,%esp
  8017a5:	ff 75 0c             	pushl  0xc(%ebp)
  8017a8:	50                   	push   %eax
  8017a9:	ff d2                	call   *%edx
  8017ab:	83 c4 10             	add    $0x10,%esp
  8017ae:	eb 05                	jmp    8017b5 <ftruncate+0x7a>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8017b0:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  8017b5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8017b8:	c9                   	leave  
  8017b9:	c3                   	ret    

008017ba <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8017ba:	55                   	push   %ebp
  8017bb:	89 e5                	mov    %esp,%ebp
  8017bd:	53                   	push   %ebx
  8017be:	83 ec 14             	sub    $0x14,%esp
  8017c1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8017c4:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8017c7:	50                   	push   %eax
  8017c8:	ff 75 08             	pushl  0x8(%ebp)
  8017cb:	e8 63 fb ff ff       	call   801333 <fd_lookup>
  8017d0:	83 c4 08             	add    $0x8,%esp
  8017d3:	85 c0                	test   %eax,%eax
  8017d5:	78 52                	js     801829 <fstat+0x6f>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8017d7:	83 ec 08             	sub    $0x8,%esp
  8017da:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8017dd:	50                   	push   %eax
  8017de:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8017e1:	ff 30                	pushl  (%eax)
  8017e3:	e8 a1 fb ff ff       	call   801389 <dev_lookup>
  8017e8:	83 c4 10             	add    $0x10,%esp
  8017eb:	85 c0                	test   %eax,%eax
  8017ed:	78 3a                	js     801829 <fstat+0x6f>
		return r;
	if (!dev->dev_stat)
  8017ef:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8017f2:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8017f6:	74 2c                	je     801824 <fstat+0x6a>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8017f8:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8017fb:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801802:	00 00 00 
	stat->st_isdir = 0;
  801805:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80180c:	00 00 00 
	stat->st_dev = dev;
  80180f:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801815:	83 ec 08             	sub    $0x8,%esp
  801818:	53                   	push   %ebx
  801819:	ff 75 f0             	pushl  -0x10(%ebp)
  80181c:	ff 50 14             	call   *0x14(%eax)
  80181f:	83 c4 10             	add    $0x10,%esp
  801822:	eb 05                	jmp    801829 <fstat+0x6f>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801824:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801829:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80182c:	c9                   	leave  
  80182d:	c3                   	ret    

0080182e <stat>:

int
stat(const char *path, struct Stat *stat)
{
  80182e:	55                   	push   %ebp
  80182f:	89 e5                	mov    %esp,%ebp
  801831:	56                   	push   %esi
  801832:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801833:	83 ec 08             	sub    $0x8,%esp
  801836:	6a 00                	push   $0x0
  801838:	ff 75 08             	pushl  0x8(%ebp)
  80183b:	e8 78 01 00 00       	call   8019b8 <open>
  801840:	89 c3                	mov    %eax,%ebx
  801842:	83 c4 10             	add    $0x10,%esp
  801845:	85 c0                	test   %eax,%eax
  801847:	78 1b                	js     801864 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801849:	83 ec 08             	sub    $0x8,%esp
  80184c:	ff 75 0c             	pushl  0xc(%ebp)
  80184f:	50                   	push   %eax
  801850:	e8 65 ff ff ff       	call   8017ba <fstat>
  801855:	89 c6                	mov    %eax,%esi
	close(fd);
  801857:	89 1c 24             	mov    %ebx,(%esp)
  80185a:	e8 18 fc ff ff       	call   801477 <close>
	return r;
  80185f:	83 c4 10             	add    $0x10,%esp
  801862:	89 f3                	mov    %esi,%ebx
}
  801864:	89 d8                	mov    %ebx,%eax
  801866:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801869:	5b                   	pop    %ebx
  80186a:	5e                   	pop    %esi
  80186b:	c9                   	leave  
  80186c:	c3                   	ret    
  80186d:	00 00                	add    %al,(%eax)
	...

00801870 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801870:	55                   	push   %ebp
  801871:	89 e5                	mov    %esp,%ebp
  801873:	56                   	push   %esi
  801874:	53                   	push   %ebx
  801875:	89 c3                	mov    %eax,%ebx
  801877:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  801879:	83 3d ac 40 80 00 00 	cmpl   $0x0,0x8040ac
  801880:	75 12                	jne    801894 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801882:	83 ec 0c             	sub    $0xc,%esp
  801885:	6a 01                	push   $0x1
  801887:	e8 8a 07 00 00       	call   802016 <ipc_find_env>
  80188c:	a3 ac 40 80 00       	mov    %eax,0x8040ac
  801891:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801894:	6a 07                	push   $0x7
  801896:	68 00 50 80 00       	push   $0x805000
  80189b:	53                   	push   %ebx
  80189c:	ff 35 ac 40 80 00    	pushl  0x8040ac
  8018a2:	e8 1a 07 00 00       	call   801fc1 <ipc_send>
	
	return ipc_recv(NULL, dstva, NULL);
  8018a7:	83 c4 0c             	add    $0xc,%esp
  8018aa:	6a 00                	push   $0x0
  8018ac:	56                   	push   %esi
  8018ad:	6a 00                	push   $0x0
  8018af:	e8 98 06 00 00       	call   801f4c <ipc_recv>
}
  8018b4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8018b7:	5b                   	pop    %ebx
  8018b8:	5e                   	pop    %esi
  8018b9:	c9                   	leave  
  8018ba:	c3                   	ret    

008018bb <devfile_stat>:
}


static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8018bb:	55                   	push   %ebp
  8018bc:	89 e5                	mov    %esp,%ebp
  8018be:	53                   	push   %ebx
  8018bf:	83 ec 04             	sub    $0x4,%esp
  8018c2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8018c5:	8b 45 08             	mov    0x8(%ebp),%eax
  8018c8:	8b 40 0c             	mov    0xc(%eax),%eax
  8018cb:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0) {
  8018d0:	ba 00 00 00 00       	mov    $0x0,%edx
  8018d5:	b8 05 00 00 00       	mov    $0x5,%eax
  8018da:	e8 91 ff ff ff       	call   801870 <fsipc>
  8018df:	85 c0                	test   %eax,%eax
  8018e1:	78 2c                	js     80190f <devfile_stat+0x54>
		return r;
	}
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8018e3:	83 ec 08             	sub    $0x8,%esp
  8018e6:	68 00 50 80 00       	push   $0x805000
  8018eb:	53                   	push   %ebx
  8018ec:	e8 29 f3 ff ff       	call   800c1a <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8018f1:	a1 80 50 80 00       	mov    0x805080,%eax
  8018f6:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8018fc:	a1 84 50 80 00       	mov    0x805084,%eax
  801901:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801907:	83 c4 10             	add    $0x10,%esp
  80190a:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80190f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801912:	c9                   	leave  
  801913:	c3                   	ret    

00801914 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801914:	55                   	push   %ebp
  801915:	89 e5                	mov    %esp,%ebp
  801917:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  80191a:	8b 45 08             	mov    0x8(%ebp),%eax
  80191d:	8b 40 0c             	mov    0xc(%eax),%eax
  801920:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801925:	ba 00 00 00 00       	mov    $0x0,%edx
  80192a:	b8 06 00 00 00       	mov    $0x6,%eax
  80192f:	e8 3c ff ff ff       	call   801870 <fsipc>
}
  801934:	c9                   	leave  
  801935:	c3                   	ret    

00801936 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801936:	55                   	push   %ebp
  801937:	89 e5                	mov    %esp,%ebp
  801939:	56                   	push   %esi
  80193a:	53                   	push   %ebx
  80193b:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  80193e:	8b 45 08             	mov    0x8(%ebp),%eax
  801941:	8b 40 0c             	mov    0xc(%eax),%eax
  801944:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801949:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  80194f:	ba 00 00 00 00       	mov    $0x0,%edx
  801954:	b8 03 00 00 00       	mov    $0x3,%eax
  801959:	e8 12 ff ff ff       	call   801870 <fsipc>
  80195e:	89 c3                	mov    %eax,%ebx
  801960:	85 c0                	test   %eax,%eax
  801962:	78 4b                	js     8019af <devfile_read+0x79>
		return r;
	assert(r <= n);
  801964:	39 c6                	cmp    %eax,%esi
  801966:	73 16                	jae    80197e <devfile_read+0x48>
  801968:	68 4c 28 80 00       	push   $0x80284c
  80196d:	68 53 28 80 00       	push   $0x802853
  801972:	6a 7d                	push   $0x7d
  801974:	68 68 28 80 00       	push   $0x802868
  801979:	e8 0e ec ff ff       	call   80058c <_panic>
	assert(r <= PGSIZE);
  80197e:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801983:	7e 16                	jle    80199b <devfile_read+0x65>
  801985:	68 73 28 80 00       	push   $0x802873
  80198a:	68 53 28 80 00       	push   $0x802853
  80198f:	6a 7e                	push   $0x7e
  801991:	68 68 28 80 00       	push   $0x802868
  801996:	e8 f1 eb ff ff       	call   80058c <_panic>
	memmove(buf, &fsipcbuf, r);
  80199b:	83 ec 04             	sub    $0x4,%esp
  80199e:	50                   	push   %eax
  80199f:	68 00 50 80 00       	push   $0x805000
  8019a4:	ff 75 0c             	pushl  0xc(%ebp)
  8019a7:	e8 2f f4 ff ff       	call   800ddb <memmove>
	return r;
  8019ac:	83 c4 10             	add    $0x10,%esp
}
  8019af:	89 d8                	mov    %ebx,%eax
  8019b1:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8019b4:	5b                   	pop    %ebx
  8019b5:	5e                   	pop    %esi
  8019b6:	c9                   	leave  
  8019b7:	c3                   	ret    

008019b8 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  8019b8:	55                   	push   %ebp
  8019b9:	89 e5                	mov    %esp,%ebp
  8019bb:	56                   	push   %esi
  8019bc:	53                   	push   %ebx
  8019bd:	83 ec 1c             	sub    $0x1c,%esp
  8019c0:	8b 75 08             	mov    0x8(%ebp),%esi
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  8019c3:	56                   	push   %esi
  8019c4:	e8 ff f1 ff ff       	call   800bc8 <strlen>
  8019c9:	83 c4 10             	add    $0x10,%esp
  8019cc:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8019d1:	7f 65                	jg     801a38 <open+0x80>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8019d3:	83 ec 0c             	sub    $0xc,%esp
  8019d6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8019d9:	50                   	push   %eax
  8019da:	e8 e1 f8 ff ff       	call   8012c0 <fd_alloc>
  8019df:	89 c3                	mov    %eax,%ebx
  8019e1:	83 c4 10             	add    $0x10,%esp
  8019e4:	85 c0                	test   %eax,%eax
  8019e6:	78 55                	js     801a3d <open+0x85>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  8019e8:	83 ec 08             	sub    $0x8,%esp
  8019eb:	56                   	push   %esi
  8019ec:	68 00 50 80 00       	push   $0x805000
  8019f1:	e8 24 f2 ff ff       	call   800c1a <strcpy>
	fsipcbuf.open.req_omode = mode;
  8019f6:	8b 45 0c             	mov    0xc(%ebp),%eax
  8019f9:	a3 00 54 80 00       	mov    %eax,0x805400



	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8019fe:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801a01:	b8 01 00 00 00       	mov    $0x1,%eax
  801a06:	e8 65 fe ff ff       	call   801870 <fsipc>
  801a0b:	89 c3                	mov    %eax,%ebx
  801a0d:	83 c4 10             	add    $0x10,%esp
  801a10:	85 c0                	test   %eax,%eax
  801a12:	79 12                	jns    801a26 <open+0x6e>
		fd_close(fd, 0);
  801a14:	83 ec 08             	sub    $0x8,%esp
  801a17:	6a 00                	push   $0x0
  801a19:	ff 75 f4             	pushl  -0xc(%ebp)
  801a1c:	e8 ce f9 ff ff       	call   8013ef <fd_close>
		return r;
  801a21:	83 c4 10             	add    $0x10,%esp
  801a24:	eb 17                	jmp    801a3d <open+0x85>
	}

	return fd2num(fd);
  801a26:	83 ec 0c             	sub    $0xc,%esp
  801a29:	ff 75 f4             	pushl  -0xc(%ebp)
  801a2c:	e8 67 f8 ff ff       	call   801298 <fd2num>
  801a31:	89 c3                	mov    %eax,%ebx
  801a33:	83 c4 10             	add    $0x10,%esp
  801a36:	eb 05                	jmp    801a3d <open+0x85>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801a38:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801a3d:	89 d8                	mov    %ebx,%eax
  801a3f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a42:	5b                   	pop    %ebx
  801a43:	5e                   	pop    %esi
  801a44:	c9                   	leave  
  801a45:	c3                   	ret    
	...

00801a48 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801a48:	55                   	push   %ebp
  801a49:	89 e5                	mov    %esp,%ebp
  801a4b:	56                   	push   %esi
  801a4c:	53                   	push   %ebx
  801a4d:	8b 75 0c             	mov    0xc(%ebp),%esi
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801a50:	83 ec 0c             	sub    $0xc,%esp
  801a53:	ff 75 08             	pushl  0x8(%ebp)
  801a56:	e8 4d f8 ff ff       	call   8012a8 <fd2data>
  801a5b:	89 c3                	mov    %eax,%ebx
	strcpy(stat->st_name, "<pipe>");
  801a5d:	83 c4 08             	add    $0x8,%esp
  801a60:	68 7f 28 80 00       	push   $0x80287f
  801a65:	56                   	push   %esi
  801a66:	e8 af f1 ff ff       	call   800c1a <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801a6b:	8b 43 04             	mov    0x4(%ebx),%eax
  801a6e:	2b 03                	sub    (%ebx),%eax
  801a70:	89 86 80 00 00 00    	mov    %eax,0x80(%esi)
	stat->st_isdir = 0;
  801a76:	c7 86 84 00 00 00 00 	movl   $0x0,0x84(%esi)
  801a7d:	00 00 00 
	stat->st_dev = &devpipe;
  801a80:	c7 86 88 00 00 00 20 	movl   $0x803020,0x88(%esi)
  801a87:	30 80 00 
	return 0;
}
  801a8a:	b8 00 00 00 00       	mov    $0x0,%eax
  801a8f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a92:	5b                   	pop    %ebx
  801a93:	5e                   	pop    %esi
  801a94:	c9                   	leave  
  801a95:	c3                   	ret    

00801a96 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801a96:	55                   	push   %ebp
  801a97:	89 e5                	mov    %esp,%ebp
  801a99:	53                   	push   %ebx
  801a9a:	83 ec 0c             	sub    $0xc,%esp
  801a9d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801aa0:	53                   	push   %ebx
  801aa1:	6a 00                	push   $0x0
  801aa3:	e8 3e f6 ff ff       	call   8010e6 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801aa8:	89 1c 24             	mov    %ebx,(%esp)
  801aab:	e8 f8 f7 ff ff       	call   8012a8 <fd2data>
  801ab0:	83 c4 08             	add    $0x8,%esp
  801ab3:	50                   	push   %eax
  801ab4:	6a 00                	push   $0x0
  801ab6:	e8 2b f6 ff ff       	call   8010e6 <sys_page_unmap>
}
  801abb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801abe:	c9                   	leave  
  801abf:	c3                   	ret    

00801ac0 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801ac0:	55                   	push   %ebp
  801ac1:	89 e5                	mov    %esp,%ebp
  801ac3:	57                   	push   %edi
  801ac4:	56                   	push   %esi
  801ac5:	53                   	push   %ebx
  801ac6:	83 ec 1c             	sub    $0x1c,%esp
  801ac9:	89 c7                	mov    %eax,%edi
  801acb:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801ace:	a1 b0 40 80 00       	mov    0x8040b0,%eax
  801ad3:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801ad6:	83 ec 0c             	sub    $0xc,%esp
  801ad9:	57                   	push   %edi
  801ada:	e8 95 05 00 00       	call   802074 <pageref>
  801adf:	89 c6                	mov    %eax,%esi
  801ae1:	83 c4 04             	add    $0x4,%esp
  801ae4:	ff 75 e4             	pushl  -0x1c(%ebp)
  801ae7:	e8 88 05 00 00       	call   802074 <pageref>
  801aec:	83 c4 10             	add    $0x10,%esp
  801aef:	39 c6                	cmp    %eax,%esi
  801af1:	0f 94 c0             	sete   %al
  801af4:	0f b6 c0             	movzbl %al,%eax
		nn = thisenv->env_runs;
  801af7:	8b 15 b0 40 80 00    	mov    0x8040b0,%edx
  801afd:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801b00:	39 cb                	cmp    %ecx,%ebx
  801b02:	75 08                	jne    801b0c <_pipeisclosed+0x4c>
			return ret;
		if (n != nn && ret == 1)
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
	}
}
  801b04:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b07:	5b                   	pop    %ebx
  801b08:	5e                   	pop    %esi
  801b09:	5f                   	pop    %edi
  801b0a:	c9                   	leave  
  801b0b:	c3                   	ret    
		n = thisenv->env_runs;
		ret = pageref(fd) == pageref(p);
		nn = thisenv->env_runs;
		if (n == nn)
			return ret;
		if (n != nn && ret == 1)
  801b0c:	83 f8 01             	cmp    $0x1,%eax
  801b0f:	75 bd                	jne    801ace <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801b11:	8b 42 58             	mov    0x58(%edx),%eax
  801b14:	6a 01                	push   $0x1
  801b16:	50                   	push   %eax
  801b17:	53                   	push   %ebx
  801b18:	68 86 28 80 00       	push   $0x802886
  801b1d:	e8 42 eb ff ff       	call   800664 <cprintf>
  801b22:	83 c4 10             	add    $0x10,%esp
  801b25:	eb a7                	jmp    801ace <_pipeisclosed+0xe>

00801b27 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801b27:	55                   	push   %ebp
  801b28:	89 e5                	mov    %esp,%ebp
  801b2a:	57                   	push   %edi
  801b2b:	56                   	push   %esi
  801b2c:	53                   	push   %ebx
  801b2d:	83 ec 28             	sub    $0x28,%esp
  801b30:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801b33:	56                   	push   %esi
  801b34:	e8 6f f7 ff ff       	call   8012a8 <fd2data>
  801b39:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801b3b:	83 c4 10             	add    $0x10,%esp
  801b3e:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801b42:	75 4a                	jne    801b8e <devpipe_write+0x67>
  801b44:	bf 00 00 00 00       	mov    $0x0,%edi
  801b49:	eb 56                	jmp    801ba1 <devpipe_write+0x7a>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801b4b:	89 da                	mov    %ebx,%edx
  801b4d:	89 f0                	mov    %esi,%eax
  801b4f:	e8 6c ff ff ff       	call   801ac0 <_pipeisclosed>
  801b54:	85 c0                	test   %eax,%eax
  801b56:	75 4d                	jne    801ba5 <devpipe_write+0x7e>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801b58:	e8 18 f5 ff ff       	call   801075 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801b5d:	8b 43 04             	mov    0x4(%ebx),%eax
  801b60:	8b 13                	mov    (%ebx),%edx
  801b62:	83 c2 20             	add    $0x20,%edx
  801b65:	39 d0                	cmp    %edx,%eax
  801b67:	73 e2                	jae    801b4b <devpipe_write+0x24>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801b69:	89 c2                	mov    %eax,%edx
  801b6b:	81 e2 1f 00 00 80    	and    $0x8000001f,%edx
  801b71:	79 05                	jns    801b78 <devpipe_write+0x51>
  801b73:	4a                   	dec    %edx
  801b74:	83 ca e0             	or     $0xffffffe0,%edx
  801b77:	42                   	inc    %edx
  801b78:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801b7b:	8a 0c 39             	mov    (%ecx,%edi,1),%cl
  801b7e:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801b82:	40                   	inc    %eax
  801b83:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801b86:	47                   	inc    %edi
  801b87:	39 7d 10             	cmp    %edi,0x10(%ebp)
  801b8a:	77 07                	ja     801b93 <devpipe_write+0x6c>
  801b8c:	eb 13                	jmp    801ba1 <devpipe_write+0x7a>
  801b8e:	bf 00 00 00 00       	mov    $0x0,%edi
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801b93:	8b 43 04             	mov    0x4(%ebx),%eax
  801b96:	8b 13                	mov    (%ebx),%edx
  801b98:	83 c2 20             	add    $0x20,%edx
  801b9b:	39 d0                	cmp    %edx,%eax
  801b9d:	73 ac                	jae    801b4b <devpipe_write+0x24>
  801b9f:	eb c8                	jmp    801b69 <devpipe_write+0x42>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801ba1:	89 f8                	mov    %edi,%eax
  801ba3:	eb 05                	jmp    801baa <devpipe_write+0x83>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801ba5:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801baa:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801bad:	5b                   	pop    %ebx
  801bae:	5e                   	pop    %esi
  801baf:	5f                   	pop    %edi
  801bb0:	c9                   	leave  
  801bb1:	c3                   	ret    

00801bb2 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801bb2:	55                   	push   %ebp
  801bb3:	89 e5                	mov    %esp,%ebp
  801bb5:	57                   	push   %edi
  801bb6:	56                   	push   %esi
  801bb7:	53                   	push   %ebx
  801bb8:	83 ec 18             	sub    $0x18,%esp
  801bbb:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801bbe:	57                   	push   %edi
  801bbf:	e8 e4 f6 ff ff       	call   8012a8 <fd2data>
  801bc4:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801bc6:	83 c4 10             	add    $0x10,%esp
  801bc9:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801bcd:	75 44                	jne    801c13 <devpipe_read+0x61>
  801bcf:	be 00 00 00 00       	mov    $0x0,%esi
  801bd4:	eb 4f                	jmp    801c25 <devpipe_read+0x73>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
				return i;
  801bd6:	89 f0                	mov    %esi,%eax
  801bd8:	eb 54                	jmp    801c2e <devpipe_read+0x7c>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801bda:	89 da                	mov    %ebx,%edx
  801bdc:	89 f8                	mov    %edi,%eax
  801bde:	e8 dd fe ff ff       	call   801ac0 <_pipeisclosed>
  801be3:	85 c0                	test   %eax,%eax
  801be5:	75 42                	jne    801c29 <devpipe_read+0x77>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801be7:	e8 89 f4 ff ff       	call   801075 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801bec:	8b 03                	mov    (%ebx),%eax
  801bee:	3b 43 04             	cmp    0x4(%ebx),%eax
  801bf1:	74 e7                	je     801bda <devpipe_read+0x28>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801bf3:	25 1f 00 00 80       	and    $0x8000001f,%eax
  801bf8:	79 05                	jns    801bff <devpipe_read+0x4d>
  801bfa:	48                   	dec    %eax
  801bfb:	83 c8 e0             	or     $0xffffffe0,%eax
  801bfe:	40                   	inc    %eax
  801bff:	8a 44 03 08          	mov    0x8(%ebx,%eax,1),%al
  801c03:	8b 55 0c             	mov    0xc(%ebp),%edx
  801c06:	88 04 32             	mov    %al,(%edx,%esi,1)
		p->p_rpos++;
  801c09:	ff 03                	incl   (%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801c0b:	46                   	inc    %esi
  801c0c:	39 75 10             	cmp    %esi,0x10(%ebp)
  801c0f:	77 07                	ja     801c18 <devpipe_read+0x66>
  801c11:	eb 12                	jmp    801c25 <devpipe_read+0x73>
  801c13:	be 00 00 00 00       	mov    $0x0,%esi
		while (p->p_rpos == p->p_wpos) {
  801c18:	8b 03                	mov    (%ebx),%eax
  801c1a:	3b 43 04             	cmp    0x4(%ebx),%eax
  801c1d:	75 d4                	jne    801bf3 <devpipe_read+0x41>
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801c1f:	85 f6                	test   %esi,%esi
  801c21:	75 b3                	jne    801bd6 <devpipe_read+0x24>
  801c23:	eb b5                	jmp    801bda <devpipe_read+0x28>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801c25:	89 f0                	mov    %esi,%eax
  801c27:	eb 05                	jmp    801c2e <devpipe_read+0x7c>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801c29:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801c2e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801c31:	5b                   	pop    %ebx
  801c32:	5e                   	pop    %esi
  801c33:	5f                   	pop    %edi
  801c34:	c9                   	leave  
  801c35:	c3                   	ret    

00801c36 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801c36:	55                   	push   %ebp
  801c37:	89 e5                	mov    %esp,%ebp
  801c39:	57                   	push   %edi
  801c3a:	56                   	push   %esi
  801c3b:	53                   	push   %ebx
  801c3c:	83 ec 28             	sub    $0x28,%esp
  801c3f:	8b 7d 08             	mov    0x8(%ebp),%edi
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801c42:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801c45:	50                   	push   %eax
  801c46:	e8 75 f6 ff ff       	call   8012c0 <fd_alloc>
  801c4b:	89 c3                	mov    %eax,%ebx
  801c4d:	83 c4 10             	add    $0x10,%esp
  801c50:	85 c0                	test   %eax,%eax
  801c52:	0f 88 24 01 00 00    	js     801d7c <pipe+0x146>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c58:	83 ec 04             	sub    $0x4,%esp
  801c5b:	68 07 04 00 00       	push   $0x407
  801c60:	ff 75 e4             	pushl  -0x1c(%ebp)
  801c63:	6a 00                	push   $0x0
  801c65:	e8 32 f4 ff ff       	call   80109c <sys_page_alloc>
  801c6a:	89 c3                	mov    %eax,%ebx
  801c6c:	83 c4 10             	add    $0x10,%esp
  801c6f:	85 c0                	test   %eax,%eax
  801c71:	0f 88 05 01 00 00    	js     801d7c <pipe+0x146>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801c77:	83 ec 0c             	sub    $0xc,%esp
  801c7a:	8d 45 e0             	lea    -0x20(%ebp),%eax
  801c7d:	50                   	push   %eax
  801c7e:	e8 3d f6 ff ff       	call   8012c0 <fd_alloc>
  801c83:	89 c3                	mov    %eax,%ebx
  801c85:	83 c4 10             	add    $0x10,%esp
  801c88:	85 c0                	test   %eax,%eax
  801c8a:	0f 88 dc 00 00 00    	js     801d6c <pipe+0x136>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c90:	83 ec 04             	sub    $0x4,%esp
  801c93:	68 07 04 00 00       	push   $0x407
  801c98:	ff 75 e0             	pushl  -0x20(%ebp)
  801c9b:	6a 00                	push   $0x0
  801c9d:	e8 fa f3 ff ff       	call   80109c <sys_page_alloc>
  801ca2:	89 c3                	mov    %eax,%ebx
  801ca4:	83 c4 10             	add    $0x10,%esp
  801ca7:	85 c0                	test   %eax,%eax
  801ca9:	0f 88 bd 00 00 00    	js     801d6c <pipe+0x136>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801caf:	83 ec 0c             	sub    $0xc,%esp
  801cb2:	ff 75 e4             	pushl  -0x1c(%ebp)
  801cb5:	e8 ee f5 ff ff       	call   8012a8 <fd2data>
  801cba:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801cbc:	83 c4 0c             	add    $0xc,%esp
  801cbf:	68 07 04 00 00       	push   $0x407
  801cc4:	50                   	push   %eax
  801cc5:	6a 00                	push   $0x0
  801cc7:	e8 d0 f3 ff ff       	call   80109c <sys_page_alloc>
  801ccc:	89 c3                	mov    %eax,%ebx
  801cce:	83 c4 10             	add    $0x10,%esp
  801cd1:	85 c0                	test   %eax,%eax
  801cd3:	0f 88 83 00 00 00    	js     801d5c <pipe+0x126>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801cd9:	83 ec 0c             	sub    $0xc,%esp
  801cdc:	ff 75 e0             	pushl  -0x20(%ebp)
  801cdf:	e8 c4 f5 ff ff       	call   8012a8 <fd2data>
  801ce4:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801ceb:	50                   	push   %eax
  801cec:	6a 00                	push   $0x0
  801cee:	56                   	push   %esi
  801cef:	6a 00                	push   $0x0
  801cf1:	e8 ca f3 ff ff       	call   8010c0 <sys_page_map>
  801cf6:	89 c3                	mov    %eax,%ebx
  801cf8:	83 c4 20             	add    $0x20,%esp
  801cfb:	85 c0                	test   %eax,%eax
  801cfd:	78 4f                	js     801d4e <pipe+0x118>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801cff:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801d05:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801d08:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801d0a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801d0d:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801d14:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801d1a:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801d1d:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801d1f:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801d22:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801d29:	83 ec 0c             	sub    $0xc,%esp
  801d2c:	ff 75 e4             	pushl  -0x1c(%ebp)
  801d2f:	e8 64 f5 ff ff       	call   801298 <fd2num>
  801d34:	89 07                	mov    %eax,(%edi)
	pfd[1] = fd2num(fd1);
  801d36:	83 c4 04             	add    $0x4,%esp
  801d39:	ff 75 e0             	pushl  -0x20(%ebp)
  801d3c:	e8 57 f5 ff ff       	call   801298 <fd2num>
  801d41:	89 47 04             	mov    %eax,0x4(%edi)
	return 0;
  801d44:	83 c4 10             	add    $0x10,%esp
  801d47:	bb 00 00 00 00       	mov    $0x0,%ebx
  801d4c:	eb 2e                	jmp    801d7c <pipe+0x146>

    err3:
	sys_page_unmap(0, va);
  801d4e:	83 ec 08             	sub    $0x8,%esp
  801d51:	56                   	push   %esi
  801d52:	6a 00                	push   $0x0
  801d54:	e8 8d f3 ff ff       	call   8010e6 <sys_page_unmap>
  801d59:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801d5c:	83 ec 08             	sub    $0x8,%esp
  801d5f:	ff 75 e0             	pushl  -0x20(%ebp)
  801d62:	6a 00                	push   $0x0
  801d64:	e8 7d f3 ff ff       	call   8010e6 <sys_page_unmap>
  801d69:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801d6c:	83 ec 08             	sub    $0x8,%esp
  801d6f:	ff 75 e4             	pushl  -0x1c(%ebp)
  801d72:	6a 00                	push   $0x0
  801d74:	e8 6d f3 ff ff       	call   8010e6 <sys_page_unmap>
  801d79:	83 c4 10             	add    $0x10,%esp
    err:
	return r;
}
  801d7c:	89 d8                	mov    %ebx,%eax
  801d7e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801d81:	5b                   	pop    %ebx
  801d82:	5e                   	pop    %esi
  801d83:	5f                   	pop    %edi
  801d84:	c9                   	leave  
  801d85:	c3                   	ret    

00801d86 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801d86:	55                   	push   %ebp
  801d87:	89 e5                	mov    %esp,%ebp
  801d89:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801d8c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801d8f:	50                   	push   %eax
  801d90:	ff 75 08             	pushl  0x8(%ebp)
  801d93:	e8 9b f5 ff ff       	call   801333 <fd_lookup>
  801d98:	83 c4 10             	add    $0x10,%esp
  801d9b:	85 c0                	test   %eax,%eax
  801d9d:	78 18                	js     801db7 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801d9f:	83 ec 0c             	sub    $0xc,%esp
  801da2:	ff 75 f4             	pushl  -0xc(%ebp)
  801da5:	e8 fe f4 ff ff       	call   8012a8 <fd2data>
	return _pipeisclosed(fd, p);
  801daa:	89 c2                	mov    %eax,%edx
  801dac:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801daf:	e8 0c fd ff ff       	call   801ac0 <_pipeisclosed>
  801db4:	83 c4 10             	add    $0x10,%esp
}
  801db7:	c9                   	leave  
  801db8:	c3                   	ret    
  801db9:	00 00                	add    %al,(%eax)
	...

00801dbc <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801dbc:	55                   	push   %ebp
  801dbd:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801dbf:	b8 00 00 00 00       	mov    $0x0,%eax
  801dc4:	c9                   	leave  
  801dc5:	c3                   	ret    

00801dc6 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801dc6:	55                   	push   %ebp
  801dc7:	89 e5                	mov    %esp,%ebp
  801dc9:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801dcc:	68 9e 28 80 00       	push   $0x80289e
  801dd1:	ff 75 0c             	pushl  0xc(%ebp)
  801dd4:	e8 41 ee ff ff       	call   800c1a <strcpy>
	return 0;
}
  801dd9:	b8 00 00 00 00       	mov    $0x0,%eax
  801dde:	c9                   	leave  
  801ddf:	c3                   	ret    

00801de0 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801de0:	55                   	push   %ebp
  801de1:	89 e5                	mov    %esp,%ebp
  801de3:	57                   	push   %edi
  801de4:	56                   	push   %esi
  801de5:	53                   	push   %ebx
  801de6:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801dec:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801df0:	74 45                	je     801e37 <devcons_write+0x57>
  801df2:	b8 00 00 00 00       	mov    $0x0,%eax
  801df7:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801dfc:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801e02:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801e05:	29 c3                	sub    %eax,%ebx
		if (m > sizeof(buf) - 1)
  801e07:	83 fb 7f             	cmp    $0x7f,%ebx
  801e0a:	76 05                	jbe    801e11 <devcons_write+0x31>
			m = sizeof(buf) - 1;
  801e0c:	bb 7f 00 00 00       	mov    $0x7f,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  801e11:	83 ec 04             	sub    $0x4,%esp
  801e14:	53                   	push   %ebx
  801e15:	03 45 0c             	add    0xc(%ebp),%eax
  801e18:	50                   	push   %eax
  801e19:	57                   	push   %edi
  801e1a:	e8 bc ef ff ff       	call   800ddb <memmove>
		sys_cputs(buf, m);
  801e1f:	83 c4 08             	add    $0x8,%esp
  801e22:	53                   	push   %ebx
  801e23:	57                   	push   %edi
  801e24:	e8 bc f1 ff ff       	call   800fe5 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801e29:	01 de                	add    %ebx,%esi
  801e2b:	89 f0                	mov    %esi,%eax
  801e2d:	83 c4 10             	add    $0x10,%esp
  801e30:	3b 75 10             	cmp    0x10(%ebp),%esi
  801e33:	72 cd                	jb     801e02 <devcons_write+0x22>
  801e35:	eb 05                	jmp    801e3c <devcons_write+0x5c>
  801e37:	be 00 00 00 00       	mov    $0x0,%esi
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801e3c:	89 f0                	mov    %esi,%eax
  801e3e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801e41:	5b                   	pop    %ebx
  801e42:	5e                   	pop    %esi
  801e43:	5f                   	pop    %edi
  801e44:	c9                   	leave  
  801e45:	c3                   	ret    

00801e46 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801e46:	55                   	push   %ebp
  801e47:	89 e5                	mov    %esp,%ebp
  801e49:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
  801e4c:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801e50:	75 07                	jne    801e59 <devcons_read+0x13>
  801e52:	eb 25                	jmp    801e79 <devcons_read+0x33>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801e54:	e8 1c f2 ff ff       	call   801075 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801e59:	e8 ad f1 ff ff       	call   80100b <sys_cgetc>
  801e5e:	85 c0                	test   %eax,%eax
  801e60:	74 f2                	je     801e54 <devcons_read+0xe>
  801e62:	89 c2                	mov    %eax,%edx
		sys_yield();
	if (c < 0)
  801e64:	85 c0                	test   %eax,%eax
  801e66:	78 1d                	js     801e85 <devcons_read+0x3f>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801e68:	83 f8 04             	cmp    $0x4,%eax
  801e6b:	74 13                	je     801e80 <devcons_read+0x3a>
		return 0;
	*(char*)vbuf = c;
  801e6d:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e70:	88 10                	mov    %dl,(%eax)
	return 1;
  801e72:	b8 01 00 00 00       	mov    $0x1,%eax
  801e77:	eb 0c                	jmp    801e85 <devcons_read+0x3f>
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
		return 0;
  801e79:	b8 00 00 00 00       	mov    $0x0,%eax
  801e7e:	eb 05                	jmp    801e85 <devcons_read+0x3f>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801e80:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801e85:	c9                   	leave  
  801e86:	c3                   	ret    

00801e87 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801e87:	55                   	push   %ebp
  801e88:	89 e5                	mov    %esp,%ebp
  801e8a:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801e8d:	8b 45 08             	mov    0x8(%ebp),%eax
  801e90:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801e93:	6a 01                	push   $0x1
  801e95:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801e98:	50                   	push   %eax
  801e99:	e8 47 f1 ff ff       	call   800fe5 <sys_cputs>
  801e9e:	83 c4 10             	add    $0x10,%esp
}
  801ea1:	c9                   	leave  
  801ea2:	c3                   	ret    

00801ea3 <getchar>:

int
getchar(void)
{
  801ea3:	55                   	push   %ebp
  801ea4:	89 e5                	mov    %esp,%ebp
  801ea6:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801ea9:	6a 01                	push   $0x1
  801eab:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801eae:	50                   	push   %eax
  801eaf:	6a 00                	push   $0x0
  801eb1:	e8 fe f6 ff ff       	call   8015b4 <read>
	if (r < 0)
  801eb6:	83 c4 10             	add    $0x10,%esp
  801eb9:	85 c0                	test   %eax,%eax
  801ebb:	78 0f                	js     801ecc <getchar+0x29>
		return r;
	if (r < 1)
  801ebd:	85 c0                	test   %eax,%eax
  801ebf:	7e 06                	jle    801ec7 <getchar+0x24>
		return -E_EOF;
	return c;
  801ec1:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801ec5:	eb 05                	jmp    801ecc <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801ec7:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801ecc:	c9                   	leave  
  801ecd:	c3                   	ret    

00801ece <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801ece:	55                   	push   %ebp
  801ecf:	89 e5                	mov    %esp,%ebp
  801ed1:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801ed4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801ed7:	50                   	push   %eax
  801ed8:	ff 75 08             	pushl  0x8(%ebp)
  801edb:	e8 53 f4 ff ff       	call   801333 <fd_lookup>
  801ee0:	83 c4 10             	add    $0x10,%esp
  801ee3:	85 c0                	test   %eax,%eax
  801ee5:	78 11                	js     801ef8 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801ee7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801eea:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801ef0:	39 10                	cmp    %edx,(%eax)
  801ef2:	0f 94 c0             	sete   %al
  801ef5:	0f b6 c0             	movzbl %al,%eax
}
  801ef8:	c9                   	leave  
  801ef9:	c3                   	ret    

00801efa <opencons>:

int
opencons(void)
{
  801efa:	55                   	push   %ebp
  801efb:	89 e5                	mov    %esp,%ebp
  801efd:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801f00:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801f03:	50                   	push   %eax
  801f04:	e8 b7 f3 ff ff       	call   8012c0 <fd_alloc>
  801f09:	83 c4 10             	add    $0x10,%esp
  801f0c:	85 c0                	test   %eax,%eax
  801f0e:	78 3a                	js     801f4a <opencons+0x50>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801f10:	83 ec 04             	sub    $0x4,%esp
  801f13:	68 07 04 00 00       	push   $0x407
  801f18:	ff 75 f4             	pushl  -0xc(%ebp)
  801f1b:	6a 00                	push   $0x0
  801f1d:	e8 7a f1 ff ff       	call   80109c <sys_page_alloc>
  801f22:	83 c4 10             	add    $0x10,%esp
  801f25:	85 c0                	test   %eax,%eax
  801f27:	78 21                	js     801f4a <opencons+0x50>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801f29:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801f2f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f32:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801f34:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f37:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801f3e:	83 ec 0c             	sub    $0xc,%esp
  801f41:	50                   	push   %eax
  801f42:	e8 51 f3 ff ff       	call   801298 <fd2num>
  801f47:	83 c4 10             	add    $0x10,%esp
}
  801f4a:	c9                   	leave  
  801f4b:	c3                   	ret    

00801f4c <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801f4c:	55                   	push   %ebp
  801f4d:	89 e5                	mov    %esp,%ebp
  801f4f:	56                   	push   %esi
  801f50:	53                   	push   %ebx
  801f51:	8b 75 08             	mov    0x8(%ebp),%esi
  801f54:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f57:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// cprintf("0x%x 0x%x 0x%x\n", (uint32_t)from_env_store, (uint32_t)pg, (uint32_t)perm_store);
	int r;
	if (pg != NULL) {
  801f5a:	85 c0                	test   %eax,%eax
  801f5c:	74 0e                	je     801f6c <ipc_recv+0x20>
		r = sys_ipc_recv(pg);
  801f5e:	83 ec 0c             	sub    $0xc,%esp
  801f61:	50                   	push   %eax
  801f62:	e8 30 f2 ff ff       	call   801197 <sys_ipc_recv>
  801f67:	83 c4 10             	add    $0x10,%esp
  801f6a:	eb 10                	jmp    801f7c <ipc_recv+0x30>
	} else {
		r = sys_ipc_recv((void *)UTOP);
  801f6c:	83 ec 0c             	sub    $0xc,%esp
  801f6f:	68 00 00 c0 ee       	push   $0xeec00000
  801f74:	e8 1e f2 ff ff       	call   801197 <sys_ipc_recv>
  801f79:	83 c4 10             	add    $0x10,%esp
	}

	if (r == 0) {
  801f7c:	85 c0                	test   %eax,%eax
  801f7e:	75 26                	jne    801fa6 <ipc_recv+0x5a>
		if (from_env_store != NULL) *from_env_store = thisenv->env_ipc_from;
  801f80:	85 f6                	test   %esi,%esi
  801f82:	74 0a                	je     801f8e <ipc_recv+0x42>
  801f84:	a1 b0 40 80 00       	mov    0x8040b0,%eax
  801f89:	8b 40 74             	mov    0x74(%eax),%eax
  801f8c:	89 06                	mov    %eax,(%esi)
		if (perm_store != NULL) *perm_store = thisenv->env_ipc_perm;
  801f8e:	85 db                	test   %ebx,%ebx
  801f90:	74 0a                	je     801f9c <ipc_recv+0x50>
  801f92:	a1 b0 40 80 00       	mov    0x8040b0,%eax
  801f97:	8b 40 78             	mov    0x78(%eax),%eax
  801f9a:	89 03                	mov    %eax,(%ebx)
		return thisenv->env_ipc_value;
  801f9c:	a1 b0 40 80 00       	mov    0x8040b0,%eax
  801fa1:	8b 40 70             	mov    0x70(%eax),%eax
  801fa4:	eb 14                	jmp    801fba <ipc_recv+0x6e>
	} else {
		// fails;
		if (from_env_store != NULL) *from_env_store = 0;
  801fa6:	85 f6                	test   %esi,%esi
  801fa8:	74 06                	je     801fb0 <ipc_recv+0x64>
  801faa:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		if (perm_store != NULL) *perm_store = 0;
  801fb0:	85 db                	test   %ebx,%ebx
  801fb2:	74 06                	je     801fba <ipc_recv+0x6e>
  801fb4:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
		return r;
	}
}
  801fba:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801fbd:	5b                   	pop    %ebx
  801fbe:	5e                   	pop    %esi
  801fbf:	c9                   	leave  
  801fc0:	c3                   	ret    

00801fc1 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801fc1:	55                   	push   %ebp
  801fc2:	89 e5                	mov    %esp,%ebp
  801fc4:	57                   	push   %edi
  801fc5:	56                   	push   %esi
  801fc6:	53                   	push   %ebx
  801fc7:	83 ec 0c             	sub    $0xc,%esp
  801fca:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801fcd:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801fd0:	8b 75 14             	mov    0x14(%ebp),%esi
	// LAB 4: Your code here.
	// int sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
	int r;
	if (pg == NULL) pg = (void *)UTOP;
  801fd3:	85 db                	test   %ebx,%ebx
  801fd5:	75 25                	jne    801ffc <ipc_send+0x3b>
  801fd7:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
  801fdc:	eb 1e                	jmp    801ffc <ipc_send+0x3b>
	
	while ((r = sys_ipc_try_send(to_env, val, pg, perm)) != 0) {
		if (r == -E_IPC_NOT_RECV) {
  801fde:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801fe1:	75 07                	jne    801fea <ipc_send+0x29>
			// cprintf("Try Again and Again....\n");
			sys_yield();
  801fe3:	e8 8d f0 ff ff       	call   801075 <sys_yield>
  801fe8:	eb 12                	jmp    801ffc <ipc_send+0x3b>
		} else {
			panic("ipc_send error %e\n", r);
  801fea:	50                   	push   %eax
  801feb:	68 aa 28 80 00       	push   $0x8028aa
  801ff0:	6a 43                	push   $0x43
  801ff2:	68 bd 28 80 00       	push   $0x8028bd
  801ff7:	e8 90 e5 ff ff       	call   80058c <_panic>
	// LAB 4: Your code here.
	// int sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
	int r;
	if (pg == NULL) pg = (void *)UTOP;
	
	while ((r = sys_ipc_try_send(to_env, val, pg, perm)) != 0) {
  801ffc:	56                   	push   %esi
  801ffd:	53                   	push   %ebx
  801ffe:	57                   	push   %edi
  801fff:	ff 75 08             	pushl  0x8(%ebp)
  802002:	e8 6b f1 ff ff       	call   801172 <sys_ipc_try_send>
  802007:	83 c4 10             	add    $0x10,%esp
  80200a:	85 c0                	test   %eax,%eax
  80200c:	75 d0                	jne    801fde <ipc_send+0x1d>
		} else {
			panic("ipc_send error %e\n", r);
		}
	}
	return;
}
  80200e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802011:	5b                   	pop    %ebx
  802012:	5e                   	pop    %esi
  802013:	5f                   	pop    %edi
  802014:	c9                   	leave  
  802015:	c3                   	ret    

00802016 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  802016:	55                   	push   %ebp
  802017:	89 e5                	mov    %esp,%ebp
  802019:	53                   	push   %ebx
  80201a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	for (i = 0; i < NENV; i++)
		if (envs[i].env_type == type)
  80201d:	39 1d 50 00 c0 ee    	cmp    %ebx,0xeec00050
  802023:	74 22                	je     802047 <ipc_find_env+0x31>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  802025:	b8 01 00 00 00       	mov    $0x1,%eax
		if (envs[i].env_type == type)
  80202a:	8d 0c 85 00 00 00 00 	lea    0x0(,%eax,4),%ecx
  802031:	89 c2                	mov    %eax,%edx
  802033:	c1 e2 07             	shl    $0x7,%edx
  802036:	29 ca                	sub    %ecx,%edx
  802038:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  80203e:	8b 52 50             	mov    0x50(%edx),%edx
  802041:	39 da                	cmp    %ebx,%edx
  802043:	75 1d                	jne    802062 <ipc_find_env+0x4c>
  802045:	eb 05                	jmp    80204c <ipc_find_env+0x36>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  802047:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
			return envs[i].env_id;
  80204c:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  802053:	c1 e0 07             	shl    $0x7,%eax
  802056:	29 d0                	sub    %edx,%eax
  802058:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  80205d:	8b 40 40             	mov    0x40(%eax),%eax
  802060:	eb 0c                	jmp    80206e <ipc_find_env+0x58>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  802062:	40                   	inc    %eax
  802063:	3d 00 04 00 00       	cmp    $0x400,%eax
  802068:	75 c0                	jne    80202a <ipc_find_env+0x14>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  80206a:	66 b8 00 00          	mov    $0x0,%ax
}
  80206e:	5b                   	pop    %ebx
  80206f:	c9                   	leave  
  802070:	c3                   	ret    
  802071:	00 00                	add    %al,(%eax)
	...

00802074 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802074:	55                   	push   %ebp
  802075:	89 e5                	mov    %esp,%ebp
  802077:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  80207a:	89 c2                	mov    %eax,%edx
  80207c:	c1 ea 16             	shr    $0x16,%edx
  80207f:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  802086:	f6 c2 01             	test   $0x1,%dl
  802089:	74 1e                	je     8020a9 <pageref+0x35>
		return 0;
	pte = uvpt[PGNUM(v)];
  80208b:	c1 e8 0c             	shr    $0xc,%eax
  80208e:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  802095:	a8 01                	test   $0x1,%al
  802097:	74 17                	je     8020b0 <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802099:	c1 e8 0c             	shr    $0xc,%eax
  80209c:	66 8b 04 c5 04 00 00 	mov    -0x10fffffc(,%eax,8),%ax
  8020a3:	ef 
  8020a4:	0f b7 c0             	movzwl %ax,%eax
  8020a7:	eb 0c                	jmp    8020b5 <pageref+0x41>
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
		return 0;
  8020a9:	b8 00 00 00 00       	mov    $0x0,%eax
  8020ae:	eb 05                	jmp    8020b5 <pageref+0x41>
	pte = uvpt[PGNUM(v)];
	if (!(pte & PTE_P))
		return 0;
  8020b0:	b8 00 00 00 00       	mov    $0x0,%eax
	return pages[PGNUM(pte)].pp_ref;
}
  8020b5:	c9                   	leave  
  8020b6:	c3                   	ret    
	...

008020b8 <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  8020b8:	55                   	push   %ebp
  8020b9:	89 e5                	mov    %esp,%ebp
  8020bb:	57                   	push   %edi
  8020bc:	56                   	push   %esi
  8020bd:	83 ec 10             	sub    $0x10,%esp
  8020c0:	8b 7d 08             	mov    0x8(%ebp),%edi
  8020c3:	8b 4d 10             	mov    0x10(%ebp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  8020c6:	89 7d f0             	mov    %edi,-0x10(%ebp)
  8020c9:	8b 75 0c             	mov    0xc(%ebp),%esi
  const DWunion dd = {.ll = d};
  8020cc:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  8020cf:	8b 45 14             	mov    0x14(%ebp),%eax
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  8020d2:	85 c0                	test   %eax,%eax
  8020d4:	75 2e                	jne    802104 <__udivdi3+0x4c>
    {
      if (d0 > n1)
  8020d6:	39 f1                	cmp    %esi,%ecx
  8020d8:	77 5a                	ja     802134 <__udivdi3+0x7c>
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  8020da:	85 c9                	test   %ecx,%ecx
  8020dc:	75 0b                	jne    8020e9 <__udivdi3+0x31>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  8020de:	b8 01 00 00 00       	mov    $0x1,%eax
  8020e3:	31 d2                	xor    %edx,%edx
  8020e5:	f7 f1                	div    %ecx
  8020e7:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  8020e9:	31 d2                	xor    %edx,%edx
  8020eb:	89 f0                	mov    %esi,%eax
  8020ed:	f7 f1                	div    %ecx
  8020ef:	89 c6                	mov    %eax,%esi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  8020f1:	89 f8                	mov    %edi,%eax
  8020f3:	f7 f1                	div    %ecx
  8020f5:	89 c7                	mov    %eax,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  8020f7:	89 f8                	mov    %edi,%eax
  8020f9:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  8020fb:	83 c4 10             	add    $0x10,%esp
  8020fe:	5e                   	pop    %esi
  8020ff:	5f                   	pop    %edi
  802100:	c9                   	leave  
  802101:	c3                   	ret    
  802102:	66 90                	xchg   %ax,%ax
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  802104:	39 f0                	cmp    %esi,%eax
  802106:	77 1c                	ja     802124 <__udivdi3+0x6c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  802108:	0f bd f8             	bsr    %eax,%edi
	  if (bm == 0)
  80210b:	83 f7 1f             	xor    $0x1f,%edi
  80210e:	75 3c                	jne    80214c <__udivdi3+0x94>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  802110:	39 f0                	cmp    %esi,%eax
  802112:	0f 82 90 00 00 00    	jb     8021a8 <__udivdi3+0xf0>
  802118:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80211b:	39 55 f4             	cmp    %edx,-0xc(%ebp)
  80211e:	0f 86 84 00 00 00    	jbe    8021a8 <__udivdi3+0xf0>
  802124:	31 f6                	xor    %esi,%esi
  802126:	31 ff                	xor    %edi,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  802128:	89 f8                	mov    %edi,%eax
  80212a:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  80212c:	83 c4 10             	add    $0x10,%esp
  80212f:	5e                   	pop    %esi
  802130:	5f                   	pop    %edi
  802131:	c9                   	leave  
  802132:	c3                   	ret    
  802133:	90                   	nop
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  802134:	89 f2                	mov    %esi,%edx
  802136:	89 f8                	mov    %edi,%eax
  802138:	f7 f1                	div    %ecx
  80213a:	89 c7                	mov    %eax,%edi
  80213c:	31 f6                	xor    %esi,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  80213e:	89 f8                	mov    %edi,%eax
  802140:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  802142:	83 c4 10             	add    $0x10,%esp
  802145:	5e                   	pop    %esi
  802146:	5f                   	pop    %edi
  802147:	c9                   	leave  
  802148:	c3                   	ret    
  802149:	8d 76 00             	lea    0x0(%esi),%esi
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  80214c:	89 f9                	mov    %edi,%ecx
  80214e:	d3 e0                	shl    %cl,%eax
  802150:	89 45 e8             	mov    %eax,-0x18(%ebp)
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  802153:	b8 20 00 00 00       	mov    $0x20,%eax
  802158:	29 f8                	sub    %edi,%eax

	      d1 = (d1 << bm) | (d0 >> b);
  80215a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80215d:	88 c1                	mov    %al,%cl
  80215f:	d3 ea                	shr    %cl,%edx
  802161:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  802164:	09 ca                	or     %ecx,%edx
  802166:	89 55 ec             	mov    %edx,-0x14(%ebp)
	      d0 = d0 << bm;
  802169:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80216c:	89 f9                	mov    %edi,%ecx
  80216e:	d3 e2                	shl    %cl,%edx
  802170:	89 55 f4             	mov    %edx,-0xc(%ebp)
	      n2 = n1 >> b;
  802173:	89 f2                	mov    %esi,%edx
  802175:	88 c1                	mov    %al,%cl
  802177:	d3 ea                	shr    %cl,%edx
  802179:	89 55 e8             	mov    %edx,-0x18(%ebp)
	      n1 = (n1 << bm) | (n0 >> b);
  80217c:	89 f2                	mov    %esi,%edx
  80217e:	89 f9                	mov    %edi,%ecx
  802180:	d3 e2                	shl    %cl,%edx
  802182:	8b 75 f0             	mov    -0x10(%ebp),%esi
  802185:	88 c1                	mov    %al,%cl
  802187:	d3 ee                	shr    %cl,%esi
  802189:	09 d6                	or     %edx,%esi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  80218b:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  80218e:	89 f0                	mov    %esi,%eax
  802190:	89 ca                	mov    %ecx,%edx
  802192:	f7 75 ec             	divl   -0x14(%ebp)
  802195:	89 d1                	mov    %edx,%ecx
  802197:	89 c6                	mov    %eax,%esi
	      umul_ppmm (m1, m0, q0, d0);
  802199:	f7 65 f4             	mull   -0xc(%ebp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  80219c:	39 d1                	cmp    %edx,%ecx
  80219e:	72 28                	jb     8021c8 <__udivdi3+0x110>
  8021a0:	74 1a                	je     8021bc <__udivdi3+0x104>
  8021a2:	89 f7                	mov    %esi,%edi
  8021a4:	31 f6                	xor    %esi,%esi
  8021a6:	eb 80                	jmp    802128 <__udivdi3+0x70>
	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  8021a8:	31 f6                	xor    %esi,%esi
  8021aa:	bf 01 00 00 00       	mov    $0x1,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  8021af:	89 f8                	mov    %edi,%eax
  8021b1:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  8021b3:	83 c4 10             	add    $0x10,%esp
  8021b6:	5e                   	pop    %esi
  8021b7:	5f                   	pop    %edi
  8021b8:	c9                   	leave  
  8021b9:	c3                   	ret    
  8021ba:	66 90                	xchg   %ax,%ax

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  8021bc:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8021bf:	89 f9                	mov    %edi,%ecx
  8021c1:	d3 e2                	shl    %cl,%edx

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  8021c3:	39 c2                	cmp    %eax,%edx
  8021c5:	73 db                	jae    8021a2 <__udivdi3+0xea>
  8021c7:	90                   	nop
		{
		  q0--;
  8021c8:	8d 7e ff             	lea    -0x1(%esi),%edi
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  8021cb:	31 f6                	xor    %esi,%esi
  8021cd:	e9 56 ff ff ff       	jmp    802128 <__udivdi3+0x70>
	...

008021d4 <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  8021d4:	55                   	push   %ebp
  8021d5:	89 e5                	mov    %esp,%ebp
  8021d7:	57                   	push   %edi
  8021d8:	56                   	push   %esi
  8021d9:	83 ec 20             	sub    $0x20,%esp
  8021dc:	8b 45 08             	mov    0x8(%ebp),%eax
  8021df:	8b 4d 10             	mov    0x10(%ebp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  8021e2:	89 45 e8             	mov    %eax,-0x18(%ebp)
  8021e5:	8b 75 0c             	mov    0xc(%ebp),%esi
  const DWunion dd = {.ll = d};
  8021e8:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  8021eb:	8b 7d 14             	mov    0x14(%ebp),%edi
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  8021ee:	89 45 f0             	mov    %eax,-0x10(%ebp)
  n1 = nn.s.high;
  8021f1:	89 f2                	mov    %esi,%edx

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  8021f3:	85 ff                	test   %edi,%edi
  8021f5:	75 15                	jne    80220c <__umoddi3+0x38>
    {
      if (d0 > n1)
  8021f7:	39 f1                	cmp    %esi,%ecx
  8021f9:	0f 86 99 00 00 00    	jbe    802298 <__umoddi3+0xc4>
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  8021ff:	f7 f1                	div    %ecx

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
  802201:	89 d0                	mov    %edx,%eax
  802203:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  802205:	83 c4 20             	add    $0x20,%esp
  802208:	5e                   	pop    %esi
  802209:	5f                   	pop    %edi
  80220a:	c9                   	leave  
  80220b:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  80220c:	39 f7                	cmp    %esi,%edi
  80220e:	0f 87 a4 00 00 00    	ja     8022b8 <__umoddi3+0xe4>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  802214:	0f bd c7             	bsr    %edi,%eax
	  if (bm == 0)
  802217:	83 f0 1f             	xor    $0x1f,%eax
  80221a:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80221d:	0f 84 a1 00 00 00    	je     8022c4 <__umoddi3+0xf0>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  802223:	89 f8                	mov    %edi,%eax
  802225:	8a 4d ec             	mov    -0x14(%ebp),%cl
  802228:	d3 e0                	shl    %cl,%eax
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  80222a:	bf 20 00 00 00       	mov    $0x20,%edi
  80222f:	2b 7d ec             	sub    -0x14(%ebp),%edi

	      d1 = (d1 << bm) | (d0 >> b);
  802232:	8b 55 f4             	mov    -0xc(%ebp),%edx
  802235:	89 f9                	mov    %edi,%ecx
  802237:	d3 ea                	shr    %cl,%edx
  802239:	09 c2                	or     %eax,%edx
  80223b:	89 55 f0             	mov    %edx,-0x10(%ebp)
	      d0 = d0 << bm;
  80223e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802241:	8a 4d ec             	mov    -0x14(%ebp),%cl
  802244:	d3 e0                	shl    %cl,%eax
  802246:	89 45 f4             	mov    %eax,-0xc(%ebp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  802249:	89 f2                	mov    %esi,%edx
  80224b:	d3 e2                	shl    %cl,%edx
	      n0 = n0 << bm;
  80224d:	8b 45 e8             	mov    -0x18(%ebp),%eax
  802250:	d3 e0                	shl    %cl,%eax
  802252:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  802255:	8b 45 e8             	mov    -0x18(%ebp),%eax
  802258:	89 f9                	mov    %edi,%ecx
  80225a:	d3 e8                	shr    %cl,%eax
  80225c:	09 d0                	or     %edx,%eax

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  80225e:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  802260:	89 f2                	mov    %esi,%edx
  802262:	f7 75 f0             	divl   -0x10(%ebp)
  802265:	89 d6                	mov    %edx,%esi
	      umul_ppmm (m1, m0, q0, d0);
  802267:	f7 65 f4             	mull   -0xc(%ebp)
  80226a:	89 55 e8             	mov    %edx,-0x18(%ebp)
  80226d:	89 c1                	mov    %eax,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  80226f:	39 d6                	cmp    %edx,%esi
  802271:	72 71                	jb     8022e4 <__umoddi3+0x110>
  802273:	74 7f                	je     8022f4 <__umoddi3+0x120>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  802275:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802278:	29 c8                	sub    %ecx,%eax
  80227a:	19 d6                	sbb    %edx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
  80227c:	8a 4d ec             	mov    -0x14(%ebp),%cl
  80227f:	d3 e8                	shr    %cl,%eax
  802281:	89 f2                	mov    %esi,%edx
  802283:	89 f9                	mov    %edi,%ecx
  802285:	d3 e2                	shl    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
  802287:	09 d0                	or     %edx,%eax
  802289:	89 f2                	mov    %esi,%edx
  80228b:	8a 4d ec             	mov    -0x14(%ebp),%cl
  80228e:	d3 ea                	shr    %cl,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  802290:	83 c4 20             	add    $0x20,%esp
  802293:	5e                   	pop    %esi
  802294:	5f                   	pop    %edi
  802295:	c9                   	leave  
  802296:	c3                   	ret    
  802297:	90                   	nop
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  802298:	85 c9                	test   %ecx,%ecx
  80229a:	75 0b                	jne    8022a7 <__umoddi3+0xd3>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  80229c:	b8 01 00 00 00       	mov    $0x1,%eax
  8022a1:	31 d2                	xor    %edx,%edx
  8022a3:	f7 f1                	div    %ecx
  8022a5:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  8022a7:	89 f0                	mov    %esi,%eax
  8022a9:	31 d2                	xor    %edx,%edx
  8022ab:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  8022ad:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8022b0:	f7 f1                	div    %ecx
  8022b2:	e9 4a ff ff ff       	jmp    802201 <__umoddi3+0x2d>
  8022b7:	90                   	nop
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
  8022b8:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  8022ba:	83 c4 20             	add    $0x20,%esp
  8022bd:	5e                   	pop    %esi
  8022be:	5f                   	pop    %edi
  8022bf:	c9                   	leave  
  8022c0:	c3                   	ret    
  8022c1:	8d 76 00             	lea    0x0(%esi),%esi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  8022c4:	39 f7                	cmp    %esi,%edi
  8022c6:	72 05                	jb     8022cd <__umoddi3+0xf9>
  8022c8:	3b 4d f0             	cmp    -0x10(%ebp),%ecx
  8022cb:	77 0c                	ja     8022d9 <__umoddi3+0x105>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  8022cd:	89 f2                	mov    %esi,%edx
  8022cf:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8022d2:	29 c8                	sub    %ecx,%eax
  8022d4:	19 fa                	sbb    %edi,%edx
  8022d6:	89 45 f0             	mov    %eax,-0x10(%ebp)

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
  8022d9:	8b 45 f0             	mov    -0x10(%ebp),%eax
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
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  8022e4:	8b 55 e8             	mov    -0x18(%ebp),%edx
  8022e7:	89 c1                	mov    %eax,%ecx
  8022e9:	2b 4d f4             	sub    -0xc(%ebp),%ecx
  8022ec:	1b 55 f0             	sbb    -0x10(%ebp),%edx
  8022ef:	eb 84                	jmp    802275 <__umoddi3+0xa1>
  8022f1:	8d 76 00             	lea    0x0(%esi),%esi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  8022f4:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  8022f7:	72 eb                	jb     8022e4 <__umoddi3+0x110>
  8022f9:	89 f2                	mov    %esi,%edx
  8022fb:	e9 75 ff ff ff       	jmp    802275 <__umoddi3+0xa1>
