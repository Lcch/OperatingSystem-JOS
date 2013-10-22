
obj/user/faultregs:     file format elf32-i386


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
  800045:	68 b1 14 80 00       	push   $0x8014b1
  80004a:	68 80 14 80 00       	push   $0x801480
  80004f:	e8 08 06 00 00       	call   80065c <cprintf>
			cprintf("MISMATCH\n");				\
			mismatch = 1;					\
		}							\
	} while (0)

	CHECK(edi, regs.reg_edi);
  800054:	ff 36                	pushl  (%esi)
  800056:	ff 33                	pushl  (%ebx)
  800058:	68 90 14 80 00       	push   $0x801490
  80005d:	68 94 14 80 00       	push   $0x801494
  800062:	e8 f5 05 00 00       	call   80065c <cprintf>
  800067:	83 c4 20             	add    $0x20,%esp
  80006a:	8b 06                	mov    (%esi),%eax
  80006c:	39 03                	cmp    %eax,(%ebx)
  80006e:	75 17                	jne    800087 <check_regs+0x53>
  800070:	83 ec 0c             	sub    $0xc,%esp
  800073:	68 a4 14 80 00       	push   $0x8014a4
  800078:	e8 df 05 00 00       	call   80065c <cprintf>
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
  80008a:	68 a8 14 80 00       	push   $0x8014a8
  80008f:	e8 c8 05 00 00       	call   80065c <cprintf>
  800094:	83 c4 10             	add    $0x10,%esp
  800097:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(esi, regs.reg_esi);
  80009c:	ff 76 04             	pushl  0x4(%esi)
  80009f:	ff 73 04             	pushl  0x4(%ebx)
  8000a2:	68 b2 14 80 00       	push   $0x8014b2
  8000a7:	68 94 14 80 00       	push   $0x801494
  8000ac:	e8 ab 05 00 00       	call   80065c <cprintf>
  8000b1:	83 c4 10             	add    $0x10,%esp
  8000b4:	8b 46 04             	mov    0x4(%esi),%eax
  8000b7:	39 43 04             	cmp    %eax,0x4(%ebx)
  8000ba:	75 12                	jne    8000ce <check_regs+0x9a>
  8000bc:	83 ec 0c             	sub    $0xc,%esp
  8000bf:	68 a4 14 80 00       	push   $0x8014a4
  8000c4:	e8 93 05 00 00       	call   80065c <cprintf>
  8000c9:	83 c4 10             	add    $0x10,%esp
  8000cc:	eb 15                	jmp    8000e3 <check_regs+0xaf>
  8000ce:	83 ec 0c             	sub    $0xc,%esp
  8000d1:	68 a8 14 80 00       	push   $0x8014a8
  8000d6:	e8 81 05 00 00       	call   80065c <cprintf>
  8000db:	83 c4 10             	add    $0x10,%esp
  8000de:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(ebp, regs.reg_ebp);
  8000e3:	ff 76 08             	pushl  0x8(%esi)
  8000e6:	ff 73 08             	pushl  0x8(%ebx)
  8000e9:	68 b6 14 80 00       	push   $0x8014b6
  8000ee:	68 94 14 80 00       	push   $0x801494
  8000f3:	e8 64 05 00 00       	call   80065c <cprintf>
  8000f8:	83 c4 10             	add    $0x10,%esp
  8000fb:	8b 46 08             	mov    0x8(%esi),%eax
  8000fe:	39 43 08             	cmp    %eax,0x8(%ebx)
  800101:	75 12                	jne    800115 <check_regs+0xe1>
  800103:	83 ec 0c             	sub    $0xc,%esp
  800106:	68 a4 14 80 00       	push   $0x8014a4
  80010b:	e8 4c 05 00 00       	call   80065c <cprintf>
  800110:	83 c4 10             	add    $0x10,%esp
  800113:	eb 15                	jmp    80012a <check_regs+0xf6>
  800115:	83 ec 0c             	sub    $0xc,%esp
  800118:	68 a8 14 80 00       	push   $0x8014a8
  80011d:	e8 3a 05 00 00       	call   80065c <cprintf>
  800122:	83 c4 10             	add    $0x10,%esp
  800125:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(ebx, regs.reg_ebx);
  80012a:	ff 76 10             	pushl  0x10(%esi)
  80012d:	ff 73 10             	pushl  0x10(%ebx)
  800130:	68 ba 14 80 00       	push   $0x8014ba
  800135:	68 94 14 80 00       	push   $0x801494
  80013a:	e8 1d 05 00 00       	call   80065c <cprintf>
  80013f:	83 c4 10             	add    $0x10,%esp
  800142:	8b 46 10             	mov    0x10(%esi),%eax
  800145:	39 43 10             	cmp    %eax,0x10(%ebx)
  800148:	75 12                	jne    80015c <check_regs+0x128>
  80014a:	83 ec 0c             	sub    $0xc,%esp
  80014d:	68 a4 14 80 00       	push   $0x8014a4
  800152:	e8 05 05 00 00       	call   80065c <cprintf>
  800157:	83 c4 10             	add    $0x10,%esp
  80015a:	eb 15                	jmp    800171 <check_regs+0x13d>
  80015c:	83 ec 0c             	sub    $0xc,%esp
  80015f:	68 a8 14 80 00       	push   $0x8014a8
  800164:	e8 f3 04 00 00       	call   80065c <cprintf>
  800169:	83 c4 10             	add    $0x10,%esp
  80016c:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(edx, regs.reg_edx);
  800171:	ff 76 14             	pushl  0x14(%esi)
  800174:	ff 73 14             	pushl  0x14(%ebx)
  800177:	68 be 14 80 00       	push   $0x8014be
  80017c:	68 94 14 80 00       	push   $0x801494
  800181:	e8 d6 04 00 00       	call   80065c <cprintf>
  800186:	83 c4 10             	add    $0x10,%esp
  800189:	8b 46 14             	mov    0x14(%esi),%eax
  80018c:	39 43 14             	cmp    %eax,0x14(%ebx)
  80018f:	75 12                	jne    8001a3 <check_regs+0x16f>
  800191:	83 ec 0c             	sub    $0xc,%esp
  800194:	68 a4 14 80 00       	push   $0x8014a4
  800199:	e8 be 04 00 00       	call   80065c <cprintf>
  80019e:	83 c4 10             	add    $0x10,%esp
  8001a1:	eb 15                	jmp    8001b8 <check_regs+0x184>
  8001a3:	83 ec 0c             	sub    $0xc,%esp
  8001a6:	68 a8 14 80 00       	push   $0x8014a8
  8001ab:	e8 ac 04 00 00       	call   80065c <cprintf>
  8001b0:	83 c4 10             	add    $0x10,%esp
  8001b3:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(ecx, regs.reg_ecx);
  8001b8:	ff 76 18             	pushl  0x18(%esi)
  8001bb:	ff 73 18             	pushl  0x18(%ebx)
  8001be:	68 c2 14 80 00       	push   $0x8014c2
  8001c3:	68 94 14 80 00       	push   $0x801494
  8001c8:	e8 8f 04 00 00       	call   80065c <cprintf>
  8001cd:	83 c4 10             	add    $0x10,%esp
  8001d0:	8b 46 18             	mov    0x18(%esi),%eax
  8001d3:	39 43 18             	cmp    %eax,0x18(%ebx)
  8001d6:	75 12                	jne    8001ea <check_regs+0x1b6>
  8001d8:	83 ec 0c             	sub    $0xc,%esp
  8001db:	68 a4 14 80 00       	push   $0x8014a4
  8001e0:	e8 77 04 00 00       	call   80065c <cprintf>
  8001e5:	83 c4 10             	add    $0x10,%esp
  8001e8:	eb 15                	jmp    8001ff <check_regs+0x1cb>
  8001ea:	83 ec 0c             	sub    $0xc,%esp
  8001ed:	68 a8 14 80 00       	push   $0x8014a8
  8001f2:	e8 65 04 00 00       	call   80065c <cprintf>
  8001f7:	83 c4 10             	add    $0x10,%esp
  8001fa:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(eax, regs.reg_eax);
  8001ff:	ff 76 1c             	pushl  0x1c(%esi)
  800202:	ff 73 1c             	pushl  0x1c(%ebx)
  800205:	68 c6 14 80 00       	push   $0x8014c6
  80020a:	68 94 14 80 00       	push   $0x801494
  80020f:	e8 48 04 00 00       	call   80065c <cprintf>
  800214:	83 c4 10             	add    $0x10,%esp
  800217:	8b 46 1c             	mov    0x1c(%esi),%eax
  80021a:	39 43 1c             	cmp    %eax,0x1c(%ebx)
  80021d:	75 12                	jne    800231 <check_regs+0x1fd>
  80021f:	83 ec 0c             	sub    $0xc,%esp
  800222:	68 a4 14 80 00       	push   $0x8014a4
  800227:	e8 30 04 00 00       	call   80065c <cprintf>
  80022c:	83 c4 10             	add    $0x10,%esp
  80022f:	eb 15                	jmp    800246 <check_regs+0x212>
  800231:	83 ec 0c             	sub    $0xc,%esp
  800234:	68 a8 14 80 00       	push   $0x8014a8
  800239:	e8 1e 04 00 00       	call   80065c <cprintf>
  80023e:	83 c4 10             	add    $0x10,%esp
  800241:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(eip, eip);
  800246:	ff 76 20             	pushl  0x20(%esi)
  800249:	ff 73 20             	pushl  0x20(%ebx)
  80024c:	68 ca 14 80 00       	push   $0x8014ca
  800251:	68 94 14 80 00       	push   $0x801494
  800256:	e8 01 04 00 00       	call   80065c <cprintf>
  80025b:	83 c4 10             	add    $0x10,%esp
  80025e:	8b 46 20             	mov    0x20(%esi),%eax
  800261:	39 43 20             	cmp    %eax,0x20(%ebx)
  800264:	75 12                	jne    800278 <check_regs+0x244>
  800266:	83 ec 0c             	sub    $0xc,%esp
  800269:	68 a4 14 80 00       	push   $0x8014a4
  80026e:	e8 e9 03 00 00       	call   80065c <cprintf>
  800273:	83 c4 10             	add    $0x10,%esp
  800276:	eb 15                	jmp    80028d <check_regs+0x259>
  800278:	83 ec 0c             	sub    $0xc,%esp
  80027b:	68 a8 14 80 00       	push   $0x8014a8
  800280:	e8 d7 03 00 00       	call   80065c <cprintf>
  800285:	83 c4 10             	add    $0x10,%esp
  800288:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(eflags, eflags);
  80028d:	ff 76 24             	pushl  0x24(%esi)
  800290:	ff 73 24             	pushl  0x24(%ebx)
  800293:	68 ce 14 80 00       	push   $0x8014ce
  800298:	68 94 14 80 00       	push   $0x801494
  80029d:	e8 ba 03 00 00       	call   80065c <cprintf>
  8002a2:	83 c4 10             	add    $0x10,%esp
  8002a5:	8b 46 24             	mov    0x24(%esi),%eax
  8002a8:	39 43 24             	cmp    %eax,0x24(%ebx)
  8002ab:	75 12                	jne    8002bf <check_regs+0x28b>
  8002ad:	83 ec 0c             	sub    $0xc,%esp
  8002b0:	68 a4 14 80 00       	push   $0x8014a4
  8002b5:	e8 a2 03 00 00       	call   80065c <cprintf>
  8002ba:	83 c4 10             	add    $0x10,%esp
  8002bd:	eb 15                	jmp    8002d4 <check_regs+0x2a0>
  8002bf:	83 ec 0c             	sub    $0xc,%esp
  8002c2:	68 a8 14 80 00       	push   $0x8014a8
  8002c7:	e8 90 03 00 00       	call   80065c <cprintf>
  8002cc:	83 c4 10             	add    $0x10,%esp
  8002cf:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(esp, esp);
  8002d4:	ff 76 28             	pushl  0x28(%esi)
  8002d7:	ff 73 28             	pushl  0x28(%ebx)
  8002da:	68 d5 14 80 00       	push   $0x8014d5
  8002df:	68 94 14 80 00       	push   $0x801494
  8002e4:	e8 73 03 00 00       	call   80065c <cprintf>
  8002e9:	83 c4 10             	add    $0x10,%esp
  8002ec:	8b 46 28             	mov    0x28(%esi),%eax
  8002ef:	39 43 28             	cmp    %eax,0x28(%ebx)
  8002f2:	75 26                	jne    80031a <check_regs+0x2e6>
  8002f4:	83 ec 0c             	sub    $0xc,%esp
  8002f7:	68 a4 14 80 00       	push   $0x8014a4
  8002fc:	e8 5b 03 00 00       	call   80065c <cprintf>

#undef CHECK

	cprintf("Registers %s ", testname);
  800301:	83 c4 08             	add    $0x8,%esp
  800304:	ff 75 0c             	pushl  0xc(%ebp)
  800307:	68 d9 14 80 00       	push   $0x8014d9
  80030c:	e8 4b 03 00 00       	call   80065c <cprintf>
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
  80031d:	68 a8 14 80 00       	push   $0x8014a8
  800322:	e8 35 03 00 00       	call   80065c <cprintf>

#undef CHECK

	cprintf("Registers %s ", testname);
  800327:	83 c4 08             	add    $0x8,%esp
  80032a:	ff 75 0c             	pushl  0xc(%ebp)
  80032d:	68 d9 14 80 00       	push   $0x8014d9
  800332:	e8 25 03 00 00       	call   80065c <cprintf>
  800337:	83 c4 10             	add    $0x10,%esp
  80033a:	eb 12                	jmp    80034e <check_regs+0x31a>
	if (!mismatch)
		cprintf("OK\n");
  80033c:	83 ec 0c             	sub    $0xc,%esp
  80033f:	68 a4 14 80 00       	push   $0x8014a4
  800344:	e8 13 03 00 00       	call   80065c <cprintf>
  800349:	83 c4 10             	add    $0x10,%esp
  80034c:	eb 10                	jmp    80035e <check_regs+0x32a>
	else
		cprintf("MISMATCH\n");
  80034e:	83 ec 0c             	sub    $0xc,%esp
  800351:	68 a8 14 80 00       	push   $0x8014a8
  800356:	e8 01 03 00 00       	call   80065c <cprintf>
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
  80037f:	68 40 15 80 00       	push   $0x801540
  800384:	6a 51                	push   $0x51
  800386:	68 e7 14 80 00       	push   $0x8014e7
  80038b:	e8 f4 01 00 00       	call   800584 <_panic>
		      utf->utf_fault_va, utf->utf_eip);

	// Check registers in UTrapframe
	during.regs = utf->utf_regs;
  800390:	bf a0 20 80 00       	mov    $0x8020a0,%edi
  800395:	8d 70 08             	lea    0x8(%eax),%esi
  800398:	b9 08 00 00 00       	mov    $0x8,%ecx
  80039d:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	during.eip = utf->utf_eip;
  80039f:	8b 50 28             	mov    0x28(%eax),%edx
  8003a2:	89 17                	mov    %edx,(%edi)
	during.eflags = utf->utf_eflags;
  8003a4:	8b 50 2c             	mov    0x2c(%eax),%edx
  8003a7:	89 15 c4 20 80 00    	mov    %edx,0x8020c4
	during.esp = utf->utf_esp;
  8003ad:	8b 40 30             	mov    0x30(%eax),%eax
  8003b0:	a3 c8 20 80 00       	mov    %eax,0x8020c8
	check_regs(&before, "before", &during, "during", "in UTrapframe");
  8003b5:	83 ec 08             	sub    $0x8,%esp
  8003b8:	68 ff 14 80 00       	push   $0x8014ff
  8003bd:	68 0d 15 80 00       	push   $0x80150d
  8003c2:	b9 a0 20 80 00       	mov    $0x8020a0,%ecx
  8003c7:	ba f8 14 80 00       	mov    $0x8014f8,%edx
  8003cc:	b8 20 20 80 00       	mov    $0x802020,%eax
  8003d1:	e8 5e fc ff ff       	call   800034 <check_regs>

	// Map UTEMP so the write succeeds
	if ((r = sys_page_alloc(0, UTEMP, PTE_U|PTE_P|PTE_W)) < 0)
  8003d6:	83 c4 0c             	add    $0xc,%esp
  8003d9:	6a 07                	push   $0x7
  8003db:	68 00 00 40 00       	push   $0x400000
  8003e0:	6a 00                	push   $0x0
  8003e2:	e8 ad 0c 00 00       	call   801094 <sys_page_alloc>
  8003e7:	83 c4 10             	add    $0x10,%esp
  8003ea:	85 c0                	test   %eax,%eax
  8003ec:	79 12                	jns    800400 <pgfault+0x9a>
		panic("sys_page_alloc: %e", r);
  8003ee:	50                   	push   %eax
  8003ef:	68 14 15 80 00       	push   $0x801514
  8003f4:	6a 5c                	push   $0x5c
  8003f6:	68 e7 14 80 00       	push   $0x8014e7
  8003fb:	e8 84 01 00 00       	call   800584 <_panic>
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
  800412:	e8 79 0d 00 00       	call   801190 <set_pgfault_handler>

	__asm __volatile(
  800417:	50                   	push   %eax
  800418:	9c                   	pushf  
  800419:	58                   	pop    %eax
  80041a:	0d d5 08 00 00       	or     $0x8d5,%eax
  80041f:	50                   	push   %eax
  800420:	9d                   	popf   
  800421:	a3 44 20 80 00       	mov    %eax,0x802044
  800426:	8d 05 61 04 80 00    	lea    0x800461,%eax
  80042c:	a3 40 20 80 00       	mov    %eax,0x802040
  800431:	58                   	pop    %eax
  800432:	89 3d 20 20 80 00    	mov    %edi,0x802020
  800438:	89 35 24 20 80 00    	mov    %esi,0x802024
  80043e:	89 2d 28 20 80 00    	mov    %ebp,0x802028
  800444:	89 1d 30 20 80 00    	mov    %ebx,0x802030
  80044a:	89 15 34 20 80 00    	mov    %edx,0x802034
  800450:	89 0d 38 20 80 00    	mov    %ecx,0x802038
  800456:	a3 3c 20 80 00       	mov    %eax,0x80203c
  80045b:	89 25 48 20 80 00    	mov    %esp,0x802048
  800461:	c7 05 00 00 40 00 2a 	movl   $0x2a,0x400000
  800468:	00 00 00 
  80046b:	89 3d 60 20 80 00    	mov    %edi,0x802060
  800471:	89 35 64 20 80 00    	mov    %esi,0x802064
  800477:	89 2d 68 20 80 00    	mov    %ebp,0x802068
  80047d:	89 1d 70 20 80 00    	mov    %ebx,0x802070
  800483:	89 15 74 20 80 00    	mov    %edx,0x802074
  800489:	89 0d 78 20 80 00    	mov    %ecx,0x802078
  80048f:	a3 7c 20 80 00       	mov    %eax,0x80207c
  800494:	89 25 88 20 80 00    	mov    %esp,0x802088
  80049a:	8b 3d 20 20 80 00    	mov    0x802020,%edi
  8004a0:	8b 35 24 20 80 00    	mov    0x802024,%esi
  8004a6:	8b 2d 28 20 80 00    	mov    0x802028,%ebp
  8004ac:	8b 1d 30 20 80 00    	mov    0x802030,%ebx
  8004b2:	8b 15 34 20 80 00    	mov    0x802034,%edx
  8004b8:	8b 0d 38 20 80 00    	mov    0x802038,%ecx
  8004be:	a1 3c 20 80 00       	mov    0x80203c,%eax
  8004c3:	8b 25 48 20 80 00    	mov    0x802048,%esp
  8004c9:	50                   	push   %eax
  8004ca:	9c                   	pushf  
  8004cb:	58                   	pop    %eax
  8004cc:	a3 84 20 80 00       	mov    %eax,0x802084
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
  8004e1:	68 74 15 80 00       	push   $0x801574
  8004e6:	e8 71 01 00 00       	call   80065c <cprintf>
  8004eb:	83 c4 10             	add    $0x10,%esp
	after.eip = before.eip;
  8004ee:	a1 40 20 80 00       	mov    0x802040,%eax
  8004f3:	a3 80 20 80 00       	mov    %eax,0x802080

	check_regs(&before, "before", &after, "after", "after page-fault");
  8004f8:	83 ec 08             	sub    $0x8,%esp
  8004fb:	68 27 15 80 00       	push   $0x801527
  800500:	68 38 15 80 00       	push   $0x801538
  800505:	b9 60 20 80 00       	mov    $0x802060,%ecx
  80050a:	ba f8 14 80 00       	mov    $0x8014f8,%edx
  80050f:	b8 20 20 80 00       	mov    $0x802020,%eax
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
  80052b:	e8 19 0b 00 00       	call   801049 <sys_getenvid>
  800530:	25 ff 03 00 00       	and    $0x3ff,%eax
  800535:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  80053c:	c1 e0 07             	shl    $0x7,%eax
  80053f:	29 d0                	sub    %edx,%eax
  800541:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800546:	a3 cc 20 80 00       	mov    %eax,0x8020cc

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80054b:	85 f6                	test   %esi,%esi
  80054d:	7e 07                	jle    800556 <libmain+0x36>
		binaryname = argv[0];
  80054f:	8b 03                	mov    (%ebx),%eax
  800551:	a3 00 20 80 00       	mov    %eax,0x802000
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
  800573:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  800576:	6a 00                	push   $0x0
  800578:	e8 aa 0a 00 00       	call   801027 <sys_env_destroy>
  80057d:	83 c4 10             	add    $0x10,%esp
}
  800580:	c9                   	leave  
  800581:	c3                   	ret    
	...

00800584 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800584:	55                   	push   %ebp
  800585:	89 e5                	mov    %esp,%ebp
  800587:	56                   	push   %esi
  800588:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800589:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80058c:	8b 1d 00 20 80 00    	mov    0x802000,%ebx
  800592:	e8 b2 0a 00 00       	call   801049 <sys_getenvid>
  800597:	83 ec 0c             	sub    $0xc,%esp
  80059a:	ff 75 0c             	pushl  0xc(%ebp)
  80059d:	ff 75 08             	pushl  0x8(%ebp)
  8005a0:	53                   	push   %ebx
  8005a1:	50                   	push   %eax
  8005a2:	68 a0 15 80 00       	push   $0x8015a0
  8005a7:	e8 b0 00 00 00       	call   80065c <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8005ac:	83 c4 18             	add    $0x18,%esp
  8005af:	56                   	push   %esi
  8005b0:	ff 75 10             	pushl  0x10(%ebp)
  8005b3:	e8 53 00 00 00       	call   80060b <vcprintf>
	cprintf("\n");
  8005b8:	c7 04 24 b0 14 80 00 	movl   $0x8014b0,(%esp)
  8005bf:	e8 98 00 00 00       	call   80065c <cprintf>
  8005c4:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8005c7:	cc                   	int3   
  8005c8:	eb fd                	jmp    8005c7 <_panic+0x43>
	...

008005cc <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8005cc:	55                   	push   %ebp
  8005cd:	89 e5                	mov    %esp,%ebp
  8005cf:	53                   	push   %ebx
  8005d0:	83 ec 04             	sub    $0x4,%esp
  8005d3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8005d6:	8b 03                	mov    (%ebx),%eax
  8005d8:	8b 55 08             	mov    0x8(%ebp),%edx
  8005db:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  8005df:	40                   	inc    %eax
  8005e0:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  8005e2:	3d ff 00 00 00       	cmp    $0xff,%eax
  8005e7:	75 1a                	jne    800603 <putch+0x37>
		sys_cputs(b->buf, b->idx);
  8005e9:	83 ec 08             	sub    $0x8,%esp
  8005ec:	68 ff 00 00 00       	push   $0xff
  8005f1:	8d 43 08             	lea    0x8(%ebx),%eax
  8005f4:	50                   	push   %eax
  8005f5:	e8 e3 09 00 00       	call   800fdd <sys_cputs>
		b->idx = 0;
  8005fa:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800600:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  800603:	ff 43 04             	incl   0x4(%ebx)
}
  800606:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800609:	c9                   	leave  
  80060a:	c3                   	ret    

0080060b <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80060b:	55                   	push   %ebp
  80060c:	89 e5                	mov    %esp,%ebp
  80060e:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800614:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80061b:	00 00 00 
	b.cnt = 0;
  80061e:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800625:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800628:	ff 75 0c             	pushl  0xc(%ebp)
  80062b:	ff 75 08             	pushl  0x8(%ebp)
  80062e:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800634:	50                   	push   %eax
  800635:	68 cc 05 80 00       	push   $0x8005cc
  80063a:	e8 82 01 00 00       	call   8007c1 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80063f:	83 c4 08             	add    $0x8,%esp
  800642:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800648:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80064e:	50                   	push   %eax
  80064f:	e8 89 09 00 00       	call   800fdd <sys_cputs>

	return b.cnt;
}
  800654:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80065a:	c9                   	leave  
  80065b:	c3                   	ret    

0080065c <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80065c:	55                   	push   %ebp
  80065d:	89 e5                	mov    %esp,%ebp
  80065f:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800662:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800665:	50                   	push   %eax
  800666:	ff 75 08             	pushl  0x8(%ebp)
  800669:	e8 9d ff ff ff       	call   80060b <vcprintf>
	va_end(ap);

	return cnt;
}
  80066e:	c9                   	leave  
  80066f:	c3                   	ret    

00800670 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800670:	55                   	push   %ebp
  800671:	89 e5                	mov    %esp,%ebp
  800673:	57                   	push   %edi
  800674:	56                   	push   %esi
  800675:	53                   	push   %ebx
  800676:	83 ec 2c             	sub    $0x2c,%esp
  800679:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80067c:	89 d6                	mov    %edx,%esi
  80067e:	8b 45 08             	mov    0x8(%ebp),%eax
  800681:	8b 55 0c             	mov    0xc(%ebp),%edx
  800684:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800687:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80068a:	8b 45 10             	mov    0x10(%ebp),%eax
  80068d:	8b 5d 14             	mov    0x14(%ebp),%ebx
  800690:	8b 7d 18             	mov    0x18(%ebp),%edi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800693:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800696:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  80069d:	39 55 d4             	cmp    %edx,-0x2c(%ebp)
  8006a0:	72 0c                	jb     8006ae <printnum+0x3e>
  8006a2:	3b 45 d8             	cmp    -0x28(%ebp),%eax
  8006a5:	76 07                	jbe    8006ae <printnum+0x3e>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8006a7:	4b                   	dec    %ebx
  8006a8:	85 db                	test   %ebx,%ebx
  8006aa:	7f 31                	jg     8006dd <printnum+0x6d>
  8006ac:	eb 3f                	jmp    8006ed <printnum+0x7d>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8006ae:	83 ec 0c             	sub    $0xc,%esp
  8006b1:	57                   	push   %edi
  8006b2:	4b                   	dec    %ebx
  8006b3:	53                   	push   %ebx
  8006b4:	50                   	push   %eax
  8006b5:	83 ec 08             	sub    $0x8,%esp
  8006b8:	ff 75 d4             	pushl  -0x2c(%ebp)
  8006bb:	ff 75 d0             	pushl  -0x30(%ebp)
  8006be:	ff 75 dc             	pushl  -0x24(%ebp)
  8006c1:	ff 75 d8             	pushl  -0x28(%ebp)
  8006c4:	e8 5b 0b 00 00       	call   801224 <__udivdi3>
  8006c9:	83 c4 18             	add    $0x18,%esp
  8006cc:	52                   	push   %edx
  8006cd:	50                   	push   %eax
  8006ce:	89 f2                	mov    %esi,%edx
  8006d0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8006d3:	e8 98 ff ff ff       	call   800670 <printnum>
  8006d8:	83 c4 20             	add    $0x20,%esp
  8006db:	eb 10                	jmp    8006ed <printnum+0x7d>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8006dd:	83 ec 08             	sub    $0x8,%esp
  8006e0:	56                   	push   %esi
  8006e1:	57                   	push   %edi
  8006e2:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8006e5:	4b                   	dec    %ebx
  8006e6:	83 c4 10             	add    $0x10,%esp
  8006e9:	85 db                	test   %ebx,%ebx
  8006eb:	7f f0                	jg     8006dd <printnum+0x6d>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8006ed:	83 ec 08             	sub    $0x8,%esp
  8006f0:	56                   	push   %esi
  8006f1:	83 ec 04             	sub    $0x4,%esp
  8006f4:	ff 75 d4             	pushl  -0x2c(%ebp)
  8006f7:	ff 75 d0             	pushl  -0x30(%ebp)
  8006fa:	ff 75 dc             	pushl  -0x24(%ebp)
  8006fd:	ff 75 d8             	pushl  -0x28(%ebp)
  800700:	e8 3b 0c 00 00       	call   801340 <__umoddi3>
  800705:	83 c4 14             	add    $0x14,%esp
  800708:	0f be 80 c3 15 80 00 	movsbl 0x8015c3(%eax),%eax
  80070f:	50                   	push   %eax
  800710:	ff 55 e4             	call   *-0x1c(%ebp)
  800713:	83 c4 10             	add    $0x10,%esp
}
  800716:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800719:	5b                   	pop    %ebx
  80071a:	5e                   	pop    %esi
  80071b:	5f                   	pop    %edi
  80071c:	c9                   	leave  
  80071d:	c3                   	ret    

0080071e <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80071e:	55                   	push   %ebp
  80071f:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800721:	83 fa 01             	cmp    $0x1,%edx
  800724:	7e 0e                	jle    800734 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800726:	8b 10                	mov    (%eax),%edx
  800728:	8d 4a 08             	lea    0x8(%edx),%ecx
  80072b:	89 08                	mov    %ecx,(%eax)
  80072d:	8b 02                	mov    (%edx),%eax
  80072f:	8b 52 04             	mov    0x4(%edx),%edx
  800732:	eb 22                	jmp    800756 <getuint+0x38>
	else if (lflag)
  800734:	85 d2                	test   %edx,%edx
  800736:	74 10                	je     800748 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800738:	8b 10                	mov    (%eax),%edx
  80073a:	8d 4a 04             	lea    0x4(%edx),%ecx
  80073d:	89 08                	mov    %ecx,(%eax)
  80073f:	8b 02                	mov    (%edx),%eax
  800741:	ba 00 00 00 00       	mov    $0x0,%edx
  800746:	eb 0e                	jmp    800756 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800748:	8b 10                	mov    (%eax),%edx
  80074a:	8d 4a 04             	lea    0x4(%edx),%ecx
  80074d:	89 08                	mov    %ecx,(%eax)
  80074f:	8b 02                	mov    (%edx),%eax
  800751:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800756:	c9                   	leave  
  800757:	c3                   	ret    

00800758 <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
  800758:	55                   	push   %ebp
  800759:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80075b:	83 fa 01             	cmp    $0x1,%edx
  80075e:	7e 0e                	jle    80076e <getint+0x16>
		return va_arg(*ap, long long);
  800760:	8b 10                	mov    (%eax),%edx
  800762:	8d 4a 08             	lea    0x8(%edx),%ecx
  800765:	89 08                	mov    %ecx,(%eax)
  800767:	8b 02                	mov    (%edx),%eax
  800769:	8b 52 04             	mov    0x4(%edx),%edx
  80076c:	eb 1a                	jmp    800788 <getint+0x30>
	else if (lflag)
  80076e:	85 d2                	test   %edx,%edx
  800770:	74 0c                	je     80077e <getint+0x26>
		return va_arg(*ap, long);
  800772:	8b 10                	mov    (%eax),%edx
  800774:	8d 4a 04             	lea    0x4(%edx),%ecx
  800777:	89 08                	mov    %ecx,(%eax)
  800779:	8b 02                	mov    (%edx),%eax
  80077b:	99                   	cltd   
  80077c:	eb 0a                	jmp    800788 <getint+0x30>
	else
		return va_arg(*ap, int);
  80077e:	8b 10                	mov    (%eax),%edx
  800780:	8d 4a 04             	lea    0x4(%edx),%ecx
  800783:	89 08                	mov    %ecx,(%eax)
  800785:	8b 02                	mov    (%edx),%eax
  800787:	99                   	cltd   
}
  800788:	c9                   	leave  
  800789:	c3                   	ret    

0080078a <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80078a:	55                   	push   %ebp
  80078b:	89 e5                	mov    %esp,%ebp
  80078d:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800790:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  800793:	8b 10                	mov    (%eax),%edx
  800795:	3b 50 04             	cmp    0x4(%eax),%edx
  800798:	73 08                	jae    8007a2 <sprintputch+0x18>
		*b->buf++ = ch;
  80079a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80079d:	88 0a                	mov    %cl,(%edx)
  80079f:	42                   	inc    %edx
  8007a0:	89 10                	mov    %edx,(%eax)
}
  8007a2:	c9                   	leave  
  8007a3:	c3                   	ret    

008007a4 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8007a4:	55                   	push   %ebp
  8007a5:	89 e5                	mov    %esp,%ebp
  8007a7:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8007aa:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8007ad:	50                   	push   %eax
  8007ae:	ff 75 10             	pushl  0x10(%ebp)
  8007b1:	ff 75 0c             	pushl  0xc(%ebp)
  8007b4:	ff 75 08             	pushl  0x8(%ebp)
  8007b7:	e8 05 00 00 00       	call   8007c1 <vprintfmt>
	va_end(ap);
  8007bc:	83 c4 10             	add    $0x10,%esp
}
  8007bf:	c9                   	leave  
  8007c0:	c3                   	ret    

008007c1 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8007c1:	55                   	push   %ebp
  8007c2:	89 e5                	mov    %esp,%ebp
  8007c4:	57                   	push   %edi
  8007c5:	56                   	push   %esi
  8007c6:	53                   	push   %ebx
  8007c7:	83 ec 2c             	sub    $0x2c,%esp
  8007ca:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8007cd:	8b 75 10             	mov    0x10(%ebp),%esi
  8007d0:	eb 13                	jmp    8007e5 <vprintfmt+0x24>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8007d2:	85 c0                	test   %eax,%eax
  8007d4:	0f 84 6d 03 00 00    	je     800b47 <vprintfmt+0x386>
				return;
			putch(ch, putdat);
  8007da:	83 ec 08             	sub    $0x8,%esp
  8007dd:	57                   	push   %edi
  8007de:	50                   	push   %eax
  8007df:	ff 55 08             	call   *0x8(%ebp)
  8007e2:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8007e5:	0f b6 06             	movzbl (%esi),%eax
  8007e8:	46                   	inc    %esi
  8007e9:	83 f8 25             	cmp    $0x25,%eax
  8007ec:	75 e4                	jne    8007d2 <vprintfmt+0x11>
  8007ee:	c6 45 dc 20          	movb   $0x20,-0x24(%ebp)
  8007f2:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  8007f9:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
  800800:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  800807:	b9 00 00 00 00       	mov    $0x0,%ecx
  80080c:	eb 28                	jmp    800836 <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80080e:	89 de                	mov    %ebx,%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  800810:	c6 45 dc 2d          	movb   $0x2d,-0x24(%ebp)
  800814:	eb 20                	jmp    800836 <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800816:	89 de                	mov    %ebx,%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800818:	c6 45 dc 30          	movb   $0x30,-0x24(%ebp)
  80081c:	eb 18                	jmp    800836 <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80081e:	89 de                	mov    %ebx,%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  800820:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800827:	eb 0d                	jmp    800836 <vprintfmt+0x75>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  800829:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80082c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80082f:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800836:	8a 06                	mov    (%esi),%al
  800838:	0f b6 d0             	movzbl %al,%edx
  80083b:	8d 5e 01             	lea    0x1(%esi),%ebx
  80083e:	83 e8 23             	sub    $0x23,%eax
  800841:	3c 55                	cmp    $0x55,%al
  800843:	0f 87 e0 02 00 00    	ja     800b29 <vprintfmt+0x368>
  800849:	0f b6 c0             	movzbl %al,%eax
  80084c:	ff 24 85 80 16 80 00 	jmp    *0x801680(,%eax,4)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800853:	83 ea 30             	sub    $0x30,%edx
  800856:	89 55 d4             	mov    %edx,-0x2c(%ebp)
				ch = *fmt;
  800859:	0f be 03             	movsbl (%ebx),%eax
				if (ch < '0' || ch > '9')
  80085c:	8d 50 d0             	lea    -0x30(%eax),%edx
  80085f:	83 fa 09             	cmp    $0x9,%edx
  800862:	77 44                	ja     8008a8 <vprintfmt+0xe7>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800864:	89 de                	mov    %ebx,%esi
  800866:	8b 55 d4             	mov    -0x2c(%ebp),%edx
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800869:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
  80086a:	8d 14 92             	lea    (%edx,%edx,4),%edx
  80086d:	8d 54 50 d0          	lea    -0x30(%eax,%edx,2),%edx
				ch = *fmt;
  800871:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  800874:	8d 58 d0             	lea    -0x30(%eax),%ebx
  800877:	83 fb 09             	cmp    $0x9,%ebx
  80087a:	76 ed                	jbe    800869 <vprintfmt+0xa8>
  80087c:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  80087f:	eb 29                	jmp    8008aa <vprintfmt+0xe9>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800881:	8b 45 14             	mov    0x14(%ebp),%eax
  800884:	8d 50 04             	lea    0x4(%eax),%edx
  800887:	89 55 14             	mov    %edx,0x14(%ebp)
  80088a:	8b 00                	mov    (%eax),%eax
  80088c:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80088f:	89 de                	mov    %ebx,%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800891:	eb 17                	jmp    8008aa <vprintfmt+0xe9>

		case '.':
			if (width < 0)
  800893:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800897:	78 85                	js     80081e <vprintfmt+0x5d>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800899:	89 de                	mov    %ebx,%esi
  80089b:	eb 99                	jmp    800836 <vprintfmt+0x75>
  80089d:	89 de                	mov    %ebx,%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  80089f:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
			goto reswitch;
  8008a6:	eb 8e                	jmp    800836 <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8008a8:	89 de                	mov    %ebx,%esi
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  8008aa:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8008ae:	79 86                	jns    800836 <vprintfmt+0x75>
  8008b0:	e9 74 ff ff ff       	jmp    800829 <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8008b5:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8008b6:	89 de                	mov    %ebx,%esi
  8008b8:	e9 79 ff ff ff       	jmp    800836 <vprintfmt+0x75>
  8008bd:	89 5d d8             	mov    %ebx,-0x28(%ebp)
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8008c0:	8b 45 14             	mov    0x14(%ebp),%eax
  8008c3:	8d 50 04             	lea    0x4(%eax),%edx
  8008c6:	89 55 14             	mov    %edx,0x14(%ebp)
  8008c9:	83 ec 08             	sub    $0x8,%esp
  8008cc:	57                   	push   %edi
  8008cd:	ff 30                	pushl  (%eax)
  8008cf:	ff 55 08             	call   *0x8(%ebp)
			break;
  8008d2:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8008d5:	8b 75 d8             	mov    -0x28(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8008d8:	e9 08 ff ff ff       	jmp    8007e5 <vprintfmt+0x24>
  8008dd:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// error message
		case 'e':
			err = va_arg(ap, int);
  8008e0:	8b 45 14             	mov    0x14(%ebp),%eax
  8008e3:	8d 50 04             	lea    0x4(%eax),%edx
  8008e6:	89 55 14             	mov    %edx,0x14(%ebp)
  8008e9:	8b 00                	mov    (%eax),%eax
  8008eb:	85 c0                	test   %eax,%eax
  8008ed:	79 02                	jns    8008f1 <vprintfmt+0x130>
  8008ef:	f7 d8                	neg    %eax
  8008f1:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8008f3:	83 f8 08             	cmp    $0x8,%eax
  8008f6:	7f 0b                	jg     800903 <vprintfmt+0x142>
  8008f8:	8b 04 85 e0 17 80 00 	mov    0x8017e0(,%eax,4),%eax
  8008ff:	85 c0                	test   %eax,%eax
  800901:	75 1a                	jne    80091d <vprintfmt+0x15c>
				printfmt(putch, putdat, "error %d", err);
  800903:	52                   	push   %edx
  800904:	68 db 15 80 00       	push   $0x8015db
  800909:	57                   	push   %edi
  80090a:	ff 75 08             	pushl  0x8(%ebp)
  80090d:	e8 92 fe ff ff       	call   8007a4 <printfmt>
  800912:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800915:	8b 75 d8             	mov    -0x28(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800918:	e9 c8 fe ff ff       	jmp    8007e5 <vprintfmt+0x24>
			else
				printfmt(putch, putdat, "%s", p);
  80091d:	50                   	push   %eax
  80091e:	68 e4 15 80 00       	push   $0x8015e4
  800923:	57                   	push   %edi
  800924:	ff 75 08             	pushl  0x8(%ebp)
  800927:	e8 78 fe ff ff       	call   8007a4 <printfmt>
  80092c:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80092f:	8b 75 d8             	mov    -0x28(%ebp),%esi
  800932:	e9 ae fe ff ff       	jmp    8007e5 <vprintfmt+0x24>
  800937:	89 5d d8             	mov    %ebx,-0x28(%ebp)
  80093a:	89 de                	mov    %ebx,%esi
  80093c:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  80093f:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800942:	8b 45 14             	mov    0x14(%ebp),%eax
  800945:	8d 50 04             	lea    0x4(%eax),%edx
  800948:	89 55 14             	mov    %edx,0x14(%ebp)
  80094b:	8b 00                	mov    (%eax),%eax
  80094d:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800950:	85 c0                	test   %eax,%eax
  800952:	75 07                	jne    80095b <vprintfmt+0x19a>
				p = "(null)";
  800954:	c7 45 d0 d4 15 80 00 	movl   $0x8015d4,-0x30(%ebp)
			if (width > 0 && padc != '-')
  80095b:	85 db                	test   %ebx,%ebx
  80095d:	7e 42                	jle    8009a1 <vprintfmt+0x1e0>
  80095f:	80 7d dc 2d          	cmpb   $0x2d,-0x24(%ebp)
  800963:	74 3c                	je     8009a1 <vprintfmt+0x1e0>
				for (width -= strnlen(p, precision); width > 0; width--)
  800965:	83 ec 08             	sub    $0x8,%esp
  800968:	51                   	push   %ecx
  800969:	ff 75 d0             	pushl  -0x30(%ebp)
  80096c:	e8 6f 02 00 00       	call   800be0 <strnlen>
  800971:	29 c3                	sub    %eax,%ebx
  800973:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800976:	83 c4 10             	add    $0x10,%esp
  800979:	85 db                	test   %ebx,%ebx
  80097b:	7e 24                	jle    8009a1 <vprintfmt+0x1e0>
					putch(padc, putdat);
  80097d:	0f be 5d dc          	movsbl -0x24(%ebp),%ebx
  800981:	89 75 dc             	mov    %esi,-0x24(%ebp)
  800984:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  800987:	83 ec 08             	sub    $0x8,%esp
  80098a:	57                   	push   %edi
  80098b:	53                   	push   %ebx
  80098c:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80098f:	4e                   	dec    %esi
  800990:	83 c4 10             	add    $0x10,%esp
  800993:	85 f6                	test   %esi,%esi
  800995:	7f f0                	jg     800987 <vprintfmt+0x1c6>
  800997:	8b 75 dc             	mov    -0x24(%ebp),%esi
  80099a:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8009a1:	8b 55 d0             	mov    -0x30(%ebp),%edx
  8009a4:	0f be 02             	movsbl (%edx),%eax
  8009a7:	85 c0                	test   %eax,%eax
  8009a9:	75 47                	jne    8009f2 <vprintfmt+0x231>
  8009ab:	eb 37                	jmp    8009e4 <vprintfmt+0x223>
				if (altflag && (ch < ' ' || ch > '~'))
  8009ad:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8009b1:	74 16                	je     8009c9 <vprintfmt+0x208>
  8009b3:	8d 50 e0             	lea    -0x20(%eax),%edx
  8009b6:	83 fa 5e             	cmp    $0x5e,%edx
  8009b9:	76 0e                	jbe    8009c9 <vprintfmt+0x208>
					putch('?', putdat);
  8009bb:	83 ec 08             	sub    $0x8,%esp
  8009be:	57                   	push   %edi
  8009bf:	6a 3f                	push   $0x3f
  8009c1:	ff 55 08             	call   *0x8(%ebp)
  8009c4:	83 c4 10             	add    $0x10,%esp
  8009c7:	eb 0b                	jmp    8009d4 <vprintfmt+0x213>
				else
					putch(ch, putdat);
  8009c9:	83 ec 08             	sub    $0x8,%esp
  8009cc:	57                   	push   %edi
  8009cd:	50                   	push   %eax
  8009ce:	ff 55 08             	call   *0x8(%ebp)
  8009d1:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8009d4:	ff 4d e4             	decl   -0x1c(%ebp)
  8009d7:	0f be 03             	movsbl (%ebx),%eax
  8009da:	85 c0                	test   %eax,%eax
  8009dc:	74 03                	je     8009e1 <vprintfmt+0x220>
  8009de:	43                   	inc    %ebx
  8009df:	eb 1b                	jmp    8009fc <vprintfmt+0x23b>
  8009e1:	8b 75 dc             	mov    -0x24(%ebp),%esi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8009e4:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8009e8:	7f 1e                	jg     800a08 <vprintfmt+0x247>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8009ea:	8b 75 d8             	mov    -0x28(%ebp),%esi
  8009ed:	e9 f3 fd ff ff       	jmp    8007e5 <vprintfmt+0x24>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8009f2:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  8009f5:	43                   	inc    %ebx
  8009f6:	89 75 dc             	mov    %esi,-0x24(%ebp)
  8009f9:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  8009fc:	85 f6                	test   %esi,%esi
  8009fe:	78 ad                	js     8009ad <vprintfmt+0x1ec>
  800a00:	4e                   	dec    %esi
  800a01:	79 aa                	jns    8009ad <vprintfmt+0x1ec>
  800a03:	8b 75 dc             	mov    -0x24(%ebp),%esi
  800a06:	eb dc                	jmp    8009e4 <vprintfmt+0x223>
  800a08:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800a0b:	83 ec 08             	sub    $0x8,%esp
  800a0e:	57                   	push   %edi
  800a0f:	6a 20                	push   $0x20
  800a11:	ff 55 08             	call   *0x8(%ebp)
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800a14:	4b                   	dec    %ebx
  800a15:	83 c4 10             	add    $0x10,%esp
  800a18:	85 db                	test   %ebx,%ebx
  800a1a:	7f ef                	jg     800a0b <vprintfmt+0x24a>
  800a1c:	e9 c4 fd ff ff       	jmp    8007e5 <vprintfmt+0x24>
  800a21:	89 5d d8             	mov    %ebx,-0x28(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800a24:	89 ca                	mov    %ecx,%edx
  800a26:	8d 45 14             	lea    0x14(%ebp),%eax
  800a29:	e8 2a fd ff ff       	call   800758 <getint>
  800a2e:	89 c3                	mov    %eax,%ebx
  800a30:	89 d6                	mov    %edx,%esi
			if ((long long) num < 0) {
  800a32:	85 d2                	test   %edx,%edx
  800a34:	78 0a                	js     800a40 <vprintfmt+0x27f>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800a36:	b8 0a 00 00 00       	mov    $0xa,%eax
  800a3b:	e9 b0 00 00 00       	jmp    800af0 <vprintfmt+0x32f>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  800a40:	83 ec 08             	sub    $0x8,%esp
  800a43:	57                   	push   %edi
  800a44:	6a 2d                	push   $0x2d
  800a46:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  800a49:	f7 db                	neg    %ebx
  800a4b:	83 d6 00             	adc    $0x0,%esi
  800a4e:	f7 de                	neg    %esi
  800a50:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800a53:	b8 0a 00 00 00       	mov    $0xa,%eax
  800a58:	e9 93 00 00 00       	jmp    800af0 <vprintfmt+0x32f>
  800a5d:	89 5d d8             	mov    %ebx,-0x28(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800a60:	89 ca                	mov    %ecx,%edx
  800a62:	8d 45 14             	lea    0x14(%ebp),%eax
  800a65:	e8 b4 fc ff ff       	call   80071e <getuint>
  800a6a:	89 c3                	mov    %eax,%ebx
  800a6c:	89 d6                	mov    %edx,%esi
			base = 10;
  800a6e:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  800a73:	eb 7b                	jmp    800af0 <vprintfmt+0x32f>
  800a75:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// (unsigned) octal
		case 'o':
            // (MIT 6.828, lab1, Ex.8)  my code : 
            num = getint(&ap, lflag);
  800a78:	89 ca                	mov    %ecx,%edx
  800a7a:	8d 45 14             	lea    0x14(%ebp),%eax
  800a7d:	e8 d6 fc ff ff       	call   800758 <getint>
  800a82:	89 c3                	mov    %eax,%ebx
  800a84:	89 d6                	mov    %edx,%esi
            if ((long long) num < 0) {
  800a86:	85 d2                	test   %edx,%edx
  800a88:	78 07                	js     800a91 <vprintfmt+0x2d0>
                putch('-', putdat);
                num = -(long long) num;
            }
            base = 8;
  800a8a:	b8 08 00 00 00       	mov    $0x8,%eax
  800a8f:	eb 5f                	jmp    800af0 <vprintfmt+0x32f>
		// (unsigned) octal
		case 'o':
            // (MIT 6.828, lab1, Ex.8)  my code : 
            num = getint(&ap, lflag);
            if ((long long) num < 0) {
                putch('-', putdat);
  800a91:	83 ec 08             	sub    $0x8,%esp
  800a94:	57                   	push   %edi
  800a95:	6a 2d                	push   $0x2d
  800a97:	ff 55 08             	call   *0x8(%ebp)
                num = -(long long) num;
  800a9a:	f7 db                	neg    %ebx
  800a9c:	83 d6 00             	adc    $0x0,%esi
  800a9f:	f7 de                	neg    %esi
  800aa1:	83 c4 10             	add    $0x10,%esp
            }
            base = 8;
  800aa4:	b8 08 00 00 00       	mov    $0x8,%eax
  800aa9:	eb 45                	jmp    800af0 <vprintfmt+0x32f>
  800aab:	89 5d d8             	mov    %ebx,-0x28(%ebp)
            goto number;

        // pointer
		case 'p':
			putch('0', putdat);
  800aae:	83 ec 08             	sub    $0x8,%esp
  800ab1:	57                   	push   %edi
  800ab2:	6a 30                	push   $0x30
  800ab4:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  800ab7:	83 c4 08             	add    $0x8,%esp
  800aba:	57                   	push   %edi
  800abb:	6a 78                	push   $0x78
  800abd:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800ac0:	8b 45 14             	mov    0x14(%ebp),%eax
  800ac3:	8d 50 04             	lea    0x4(%eax),%edx
  800ac6:	89 55 14             	mov    %edx,0x14(%ebp)

        // pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800ac9:	8b 18                	mov    (%eax),%ebx
  800acb:	be 00 00 00 00       	mov    $0x0,%esi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800ad0:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800ad3:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  800ad8:	eb 16                	jmp    800af0 <vprintfmt+0x32f>
  800ada:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800add:	89 ca                	mov    %ecx,%edx
  800adf:	8d 45 14             	lea    0x14(%ebp),%eax
  800ae2:	e8 37 fc ff ff       	call   80071e <getuint>
  800ae7:	89 c3                	mov    %eax,%ebx
  800ae9:	89 d6                	mov    %edx,%esi
			base = 16;
  800aeb:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  800af0:	83 ec 0c             	sub    $0xc,%esp
  800af3:	0f be 55 dc          	movsbl -0x24(%ebp),%edx
  800af7:	52                   	push   %edx
  800af8:	ff 75 e4             	pushl  -0x1c(%ebp)
  800afb:	50                   	push   %eax
  800afc:	56                   	push   %esi
  800afd:	53                   	push   %ebx
  800afe:	89 fa                	mov    %edi,%edx
  800b00:	8b 45 08             	mov    0x8(%ebp),%eax
  800b03:	e8 68 fb ff ff       	call   800670 <printnum>
			break;
  800b08:	83 c4 20             	add    $0x20,%esp
  800b0b:	8b 75 d8             	mov    -0x28(%ebp),%esi
  800b0e:	e9 d2 fc ff ff       	jmp    8007e5 <vprintfmt+0x24>
  800b13:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800b16:	83 ec 08             	sub    $0x8,%esp
  800b19:	57                   	push   %edi
  800b1a:	52                   	push   %edx
  800b1b:	ff 55 08             	call   *0x8(%ebp)
			break;
  800b1e:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800b21:	8b 75 d8             	mov    -0x28(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800b24:	e9 bc fc ff ff       	jmp    8007e5 <vprintfmt+0x24>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800b29:	83 ec 08             	sub    $0x8,%esp
  800b2c:	57                   	push   %edi
  800b2d:	6a 25                	push   $0x25
  800b2f:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800b32:	83 c4 10             	add    $0x10,%esp
  800b35:	eb 02                	jmp    800b39 <vprintfmt+0x378>
  800b37:	89 c6                	mov    %eax,%esi
  800b39:	8d 46 ff             	lea    -0x1(%esi),%eax
  800b3c:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  800b40:	75 f5                	jne    800b37 <vprintfmt+0x376>
  800b42:	e9 9e fc ff ff       	jmp    8007e5 <vprintfmt+0x24>
				/* do nothing */;
			break;
		}
	}
}
  800b47:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b4a:	5b                   	pop    %ebx
  800b4b:	5e                   	pop    %esi
  800b4c:	5f                   	pop    %edi
  800b4d:	c9                   	leave  
  800b4e:	c3                   	ret    

00800b4f <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800b4f:	55                   	push   %ebp
  800b50:	89 e5                	mov    %esp,%ebp
  800b52:	83 ec 18             	sub    $0x18,%esp
  800b55:	8b 45 08             	mov    0x8(%ebp),%eax
  800b58:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800b5b:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800b5e:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800b62:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800b65:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800b6c:	85 c0                	test   %eax,%eax
  800b6e:	74 26                	je     800b96 <vsnprintf+0x47>
  800b70:	85 d2                	test   %edx,%edx
  800b72:	7e 29                	jle    800b9d <vsnprintf+0x4e>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800b74:	ff 75 14             	pushl  0x14(%ebp)
  800b77:	ff 75 10             	pushl  0x10(%ebp)
  800b7a:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800b7d:	50                   	push   %eax
  800b7e:	68 8a 07 80 00       	push   $0x80078a
  800b83:	e8 39 fc ff ff       	call   8007c1 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800b88:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800b8b:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800b8e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800b91:	83 c4 10             	add    $0x10,%esp
  800b94:	eb 0c                	jmp    800ba2 <vsnprintf+0x53>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800b96:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800b9b:	eb 05                	jmp    800ba2 <vsnprintf+0x53>
  800b9d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800ba2:	c9                   	leave  
  800ba3:	c3                   	ret    

00800ba4 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800ba4:	55                   	push   %ebp
  800ba5:	89 e5                	mov    %esp,%ebp
  800ba7:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800baa:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800bad:	50                   	push   %eax
  800bae:	ff 75 10             	pushl  0x10(%ebp)
  800bb1:	ff 75 0c             	pushl  0xc(%ebp)
  800bb4:	ff 75 08             	pushl  0x8(%ebp)
  800bb7:	e8 93 ff ff ff       	call   800b4f <vsnprintf>
	va_end(ap);

	return rc;
}
  800bbc:	c9                   	leave  
  800bbd:	c3                   	ret    
	...

00800bc0 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800bc0:	55                   	push   %ebp
  800bc1:	89 e5                	mov    %esp,%ebp
  800bc3:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800bc6:	80 3a 00             	cmpb   $0x0,(%edx)
  800bc9:	74 0e                	je     800bd9 <strlen+0x19>
  800bcb:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  800bd0:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800bd1:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800bd5:	75 f9                	jne    800bd0 <strlen+0x10>
  800bd7:	eb 05                	jmp    800bde <strlen+0x1e>
  800bd9:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  800bde:	c9                   	leave  
  800bdf:	c3                   	ret    

00800be0 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800be0:	55                   	push   %ebp
  800be1:	89 e5                	mov    %esp,%ebp
  800be3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800be6:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800be9:	85 d2                	test   %edx,%edx
  800beb:	74 17                	je     800c04 <strnlen+0x24>
  800bed:	80 39 00             	cmpb   $0x0,(%ecx)
  800bf0:	74 19                	je     800c0b <strnlen+0x2b>
  800bf2:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  800bf7:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800bf8:	39 d0                	cmp    %edx,%eax
  800bfa:	74 14                	je     800c10 <strnlen+0x30>
  800bfc:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800c00:	75 f5                	jne    800bf7 <strnlen+0x17>
  800c02:	eb 0c                	jmp    800c10 <strnlen+0x30>
  800c04:	b8 00 00 00 00       	mov    $0x0,%eax
  800c09:	eb 05                	jmp    800c10 <strnlen+0x30>
  800c0b:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  800c10:	c9                   	leave  
  800c11:	c3                   	ret    

00800c12 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800c12:	55                   	push   %ebp
  800c13:	89 e5                	mov    %esp,%ebp
  800c15:	53                   	push   %ebx
  800c16:	8b 45 08             	mov    0x8(%ebp),%eax
  800c19:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800c1c:	ba 00 00 00 00       	mov    $0x0,%edx
  800c21:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  800c24:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800c27:	42                   	inc    %edx
  800c28:	84 c9                	test   %cl,%cl
  800c2a:	75 f5                	jne    800c21 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800c2c:	5b                   	pop    %ebx
  800c2d:	c9                   	leave  
  800c2e:	c3                   	ret    

00800c2f <strcat>:

char *
strcat(char *dst, const char *src)
{
  800c2f:	55                   	push   %ebp
  800c30:	89 e5                	mov    %esp,%ebp
  800c32:	53                   	push   %ebx
  800c33:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800c36:	53                   	push   %ebx
  800c37:	e8 84 ff ff ff       	call   800bc0 <strlen>
  800c3c:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800c3f:	ff 75 0c             	pushl  0xc(%ebp)
  800c42:	8d 04 03             	lea    (%ebx,%eax,1),%eax
  800c45:	50                   	push   %eax
  800c46:	e8 c7 ff ff ff       	call   800c12 <strcpy>
	return dst;
}
  800c4b:	89 d8                	mov    %ebx,%eax
  800c4d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800c50:	c9                   	leave  
  800c51:	c3                   	ret    

00800c52 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800c52:	55                   	push   %ebp
  800c53:	89 e5                	mov    %esp,%ebp
  800c55:	56                   	push   %esi
  800c56:	53                   	push   %ebx
  800c57:	8b 45 08             	mov    0x8(%ebp),%eax
  800c5a:	8b 55 0c             	mov    0xc(%ebp),%edx
  800c5d:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800c60:	85 f6                	test   %esi,%esi
  800c62:	74 15                	je     800c79 <strncpy+0x27>
  800c64:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
  800c69:	8a 1a                	mov    (%edx),%bl
  800c6b:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800c6e:	80 3a 01             	cmpb   $0x1,(%edx)
  800c71:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800c74:	41                   	inc    %ecx
  800c75:	39 ce                	cmp    %ecx,%esi
  800c77:	77 f0                	ja     800c69 <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800c79:	5b                   	pop    %ebx
  800c7a:	5e                   	pop    %esi
  800c7b:	c9                   	leave  
  800c7c:	c3                   	ret    

00800c7d <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800c7d:	55                   	push   %ebp
  800c7e:	89 e5                	mov    %esp,%ebp
  800c80:	57                   	push   %edi
  800c81:	56                   	push   %esi
  800c82:	53                   	push   %ebx
  800c83:	8b 7d 08             	mov    0x8(%ebp),%edi
  800c86:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800c89:	8b 75 10             	mov    0x10(%ebp),%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800c8c:	85 f6                	test   %esi,%esi
  800c8e:	74 32                	je     800cc2 <strlcpy+0x45>
		while (--size > 0 && *src != '\0')
  800c90:	83 fe 01             	cmp    $0x1,%esi
  800c93:	74 22                	je     800cb7 <strlcpy+0x3a>
  800c95:	8a 0b                	mov    (%ebx),%cl
  800c97:	84 c9                	test   %cl,%cl
  800c99:	74 20                	je     800cbb <strlcpy+0x3e>
  800c9b:	89 f8                	mov    %edi,%eax
  800c9d:	ba 00 00 00 00       	mov    $0x0,%edx
	}
	return ret;
}

size_t
strlcpy(char *dst, const char *src, size_t size)
  800ca2:	83 ee 02             	sub    $0x2,%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800ca5:	88 08                	mov    %cl,(%eax)
  800ca7:	40                   	inc    %eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800ca8:	39 f2                	cmp    %esi,%edx
  800caa:	74 11                	je     800cbd <strlcpy+0x40>
  800cac:	8a 4c 13 01          	mov    0x1(%ebx,%edx,1),%cl
  800cb0:	42                   	inc    %edx
  800cb1:	84 c9                	test   %cl,%cl
  800cb3:	75 f0                	jne    800ca5 <strlcpy+0x28>
  800cb5:	eb 06                	jmp    800cbd <strlcpy+0x40>
  800cb7:	89 f8                	mov    %edi,%eax
  800cb9:	eb 02                	jmp    800cbd <strlcpy+0x40>
  800cbb:	89 f8                	mov    %edi,%eax
			*dst++ = *src++;
		*dst = '\0';
  800cbd:	c6 00 00             	movb   $0x0,(%eax)
  800cc0:	eb 02                	jmp    800cc4 <strlcpy+0x47>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800cc2:	89 f8                	mov    %edi,%eax
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
		*dst = '\0';
	}
	return dst - dst_in;
  800cc4:	29 f8                	sub    %edi,%eax
}
  800cc6:	5b                   	pop    %ebx
  800cc7:	5e                   	pop    %esi
  800cc8:	5f                   	pop    %edi
  800cc9:	c9                   	leave  
  800cca:	c3                   	ret    

00800ccb <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800ccb:	55                   	push   %ebp
  800ccc:	89 e5                	mov    %esp,%ebp
  800cce:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800cd1:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800cd4:	8a 01                	mov    (%ecx),%al
  800cd6:	84 c0                	test   %al,%al
  800cd8:	74 10                	je     800cea <strcmp+0x1f>
  800cda:	3a 02                	cmp    (%edx),%al
  800cdc:	75 0c                	jne    800cea <strcmp+0x1f>
		p++, q++;
  800cde:	41                   	inc    %ecx
  800cdf:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800ce0:	8a 01                	mov    (%ecx),%al
  800ce2:	84 c0                	test   %al,%al
  800ce4:	74 04                	je     800cea <strcmp+0x1f>
  800ce6:	3a 02                	cmp    (%edx),%al
  800ce8:	74 f4                	je     800cde <strcmp+0x13>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800cea:	0f b6 c0             	movzbl %al,%eax
  800ced:	0f b6 12             	movzbl (%edx),%edx
  800cf0:	29 d0                	sub    %edx,%eax
}
  800cf2:	c9                   	leave  
  800cf3:	c3                   	ret    

00800cf4 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800cf4:	55                   	push   %ebp
  800cf5:	89 e5                	mov    %esp,%ebp
  800cf7:	53                   	push   %ebx
  800cf8:	8b 55 08             	mov    0x8(%ebp),%edx
  800cfb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cfe:	8b 45 10             	mov    0x10(%ebp),%eax
	while (n > 0 && *p && *p == *q)
  800d01:	85 c0                	test   %eax,%eax
  800d03:	74 1b                	je     800d20 <strncmp+0x2c>
  800d05:	8a 1a                	mov    (%edx),%bl
  800d07:	84 db                	test   %bl,%bl
  800d09:	74 24                	je     800d2f <strncmp+0x3b>
  800d0b:	3a 19                	cmp    (%ecx),%bl
  800d0d:	75 20                	jne    800d2f <strncmp+0x3b>
  800d0f:	48                   	dec    %eax
  800d10:	74 15                	je     800d27 <strncmp+0x33>
		n--, p++, q++;
  800d12:	42                   	inc    %edx
  800d13:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800d14:	8a 1a                	mov    (%edx),%bl
  800d16:	84 db                	test   %bl,%bl
  800d18:	74 15                	je     800d2f <strncmp+0x3b>
  800d1a:	3a 19                	cmp    (%ecx),%bl
  800d1c:	74 f1                	je     800d0f <strncmp+0x1b>
  800d1e:	eb 0f                	jmp    800d2f <strncmp+0x3b>
		n--, p++, q++;
	if (n == 0)
		return 0;
  800d20:	b8 00 00 00 00       	mov    $0x0,%eax
  800d25:	eb 05                	jmp    800d2c <strncmp+0x38>
  800d27:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800d2c:	5b                   	pop    %ebx
  800d2d:	c9                   	leave  
  800d2e:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800d2f:	0f b6 02             	movzbl (%edx),%eax
  800d32:	0f b6 11             	movzbl (%ecx),%edx
  800d35:	29 d0                	sub    %edx,%eax
  800d37:	eb f3                	jmp    800d2c <strncmp+0x38>

00800d39 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800d39:	55                   	push   %ebp
  800d3a:	89 e5                	mov    %esp,%ebp
  800d3c:	8b 45 08             	mov    0x8(%ebp),%eax
  800d3f:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800d42:	8a 10                	mov    (%eax),%dl
  800d44:	84 d2                	test   %dl,%dl
  800d46:	74 18                	je     800d60 <strchr+0x27>
		if (*s == c)
  800d48:	38 ca                	cmp    %cl,%dl
  800d4a:	75 06                	jne    800d52 <strchr+0x19>
  800d4c:	eb 17                	jmp    800d65 <strchr+0x2c>
  800d4e:	38 ca                	cmp    %cl,%dl
  800d50:	74 13                	je     800d65 <strchr+0x2c>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800d52:	40                   	inc    %eax
  800d53:	8a 10                	mov    (%eax),%dl
  800d55:	84 d2                	test   %dl,%dl
  800d57:	75 f5                	jne    800d4e <strchr+0x15>
		if (*s == c)
			return (char *) s;
	return 0;
  800d59:	b8 00 00 00 00       	mov    $0x0,%eax
  800d5e:	eb 05                	jmp    800d65 <strchr+0x2c>
  800d60:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800d65:	c9                   	leave  
  800d66:	c3                   	ret    

00800d67 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800d67:	55                   	push   %ebp
  800d68:	89 e5                	mov    %esp,%ebp
  800d6a:	8b 45 08             	mov    0x8(%ebp),%eax
  800d6d:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800d70:	8a 10                	mov    (%eax),%dl
  800d72:	84 d2                	test   %dl,%dl
  800d74:	74 11                	je     800d87 <strfind+0x20>
		if (*s == c)
  800d76:	38 ca                	cmp    %cl,%dl
  800d78:	75 06                	jne    800d80 <strfind+0x19>
  800d7a:	eb 0b                	jmp    800d87 <strfind+0x20>
  800d7c:	38 ca                	cmp    %cl,%dl
  800d7e:	74 07                	je     800d87 <strfind+0x20>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800d80:	40                   	inc    %eax
  800d81:	8a 10                	mov    (%eax),%dl
  800d83:	84 d2                	test   %dl,%dl
  800d85:	75 f5                	jne    800d7c <strfind+0x15>
		if (*s == c)
			break;
	return (char *) s;
}
  800d87:	c9                   	leave  
  800d88:	c3                   	ret    

00800d89 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800d89:	55                   	push   %ebp
  800d8a:	89 e5                	mov    %esp,%ebp
  800d8c:	57                   	push   %edi
  800d8d:	56                   	push   %esi
  800d8e:	53                   	push   %ebx
  800d8f:	8b 7d 08             	mov    0x8(%ebp),%edi
  800d92:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d95:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800d98:	85 c9                	test   %ecx,%ecx
  800d9a:	74 30                	je     800dcc <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800d9c:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800da2:	75 25                	jne    800dc9 <memset+0x40>
  800da4:	f6 c1 03             	test   $0x3,%cl
  800da7:	75 20                	jne    800dc9 <memset+0x40>
		c &= 0xFF;
  800da9:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800dac:	89 d3                	mov    %edx,%ebx
  800dae:	c1 e3 08             	shl    $0x8,%ebx
  800db1:	89 d6                	mov    %edx,%esi
  800db3:	c1 e6 18             	shl    $0x18,%esi
  800db6:	89 d0                	mov    %edx,%eax
  800db8:	c1 e0 10             	shl    $0x10,%eax
  800dbb:	09 f0                	or     %esi,%eax
  800dbd:	09 d0                	or     %edx,%eax
  800dbf:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800dc1:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800dc4:	fc                   	cld    
  800dc5:	f3 ab                	rep stos %eax,%es:(%edi)
  800dc7:	eb 03                	jmp    800dcc <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800dc9:	fc                   	cld    
  800dca:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800dcc:	89 f8                	mov    %edi,%eax
  800dce:	5b                   	pop    %ebx
  800dcf:	5e                   	pop    %esi
  800dd0:	5f                   	pop    %edi
  800dd1:	c9                   	leave  
  800dd2:	c3                   	ret    

00800dd3 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800dd3:	55                   	push   %ebp
  800dd4:	89 e5                	mov    %esp,%ebp
  800dd6:	57                   	push   %edi
  800dd7:	56                   	push   %esi
  800dd8:	8b 45 08             	mov    0x8(%ebp),%eax
  800ddb:	8b 75 0c             	mov    0xc(%ebp),%esi
  800dde:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800de1:	39 c6                	cmp    %eax,%esi
  800de3:	73 34                	jae    800e19 <memmove+0x46>
  800de5:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800de8:	39 d0                	cmp    %edx,%eax
  800dea:	73 2d                	jae    800e19 <memmove+0x46>
		s += n;
		d += n;
  800dec:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800def:	f6 c2 03             	test   $0x3,%dl
  800df2:	75 1b                	jne    800e0f <memmove+0x3c>
  800df4:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800dfa:	75 13                	jne    800e0f <memmove+0x3c>
  800dfc:	f6 c1 03             	test   $0x3,%cl
  800dff:	75 0e                	jne    800e0f <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800e01:	83 ef 04             	sub    $0x4,%edi
  800e04:	8d 72 fc             	lea    -0x4(%edx),%esi
  800e07:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800e0a:	fd                   	std    
  800e0b:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800e0d:	eb 07                	jmp    800e16 <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800e0f:	4f                   	dec    %edi
  800e10:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800e13:	fd                   	std    
  800e14:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800e16:	fc                   	cld    
  800e17:	eb 20                	jmp    800e39 <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800e19:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800e1f:	75 13                	jne    800e34 <memmove+0x61>
  800e21:	a8 03                	test   $0x3,%al
  800e23:	75 0f                	jne    800e34 <memmove+0x61>
  800e25:	f6 c1 03             	test   $0x3,%cl
  800e28:	75 0a                	jne    800e34 <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800e2a:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800e2d:	89 c7                	mov    %eax,%edi
  800e2f:	fc                   	cld    
  800e30:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800e32:	eb 05                	jmp    800e39 <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800e34:	89 c7                	mov    %eax,%edi
  800e36:	fc                   	cld    
  800e37:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800e39:	5e                   	pop    %esi
  800e3a:	5f                   	pop    %edi
  800e3b:	c9                   	leave  
  800e3c:	c3                   	ret    

00800e3d <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800e3d:	55                   	push   %ebp
  800e3e:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800e40:	ff 75 10             	pushl  0x10(%ebp)
  800e43:	ff 75 0c             	pushl  0xc(%ebp)
  800e46:	ff 75 08             	pushl  0x8(%ebp)
  800e49:	e8 85 ff ff ff       	call   800dd3 <memmove>
}
  800e4e:	c9                   	leave  
  800e4f:	c3                   	ret    

00800e50 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800e50:	55                   	push   %ebp
  800e51:	89 e5                	mov    %esp,%ebp
  800e53:	57                   	push   %edi
  800e54:	56                   	push   %esi
  800e55:	53                   	push   %ebx
  800e56:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800e59:	8b 75 0c             	mov    0xc(%ebp),%esi
  800e5c:	8b 7d 10             	mov    0x10(%ebp),%edi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800e5f:	85 ff                	test   %edi,%edi
  800e61:	74 32                	je     800e95 <memcmp+0x45>
		if (*s1 != *s2)
  800e63:	8a 03                	mov    (%ebx),%al
  800e65:	8a 0e                	mov    (%esi),%cl
  800e67:	38 c8                	cmp    %cl,%al
  800e69:	74 19                	je     800e84 <memcmp+0x34>
  800e6b:	eb 0d                	jmp    800e7a <memcmp+0x2a>
  800e6d:	8a 44 13 01          	mov    0x1(%ebx,%edx,1),%al
  800e71:	8a 4c 16 01          	mov    0x1(%esi,%edx,1),%cl
  800e75:	42                   	inc    %edx
  800e76:	38 c8                	cmp    %cl,%al
  800e78:	74 10                	je     800e8a <memcmp+0x3a>
			return (int) *s1 - (int) *s2;
  800e7a:	0f b6 c0             	movzbl %al,%eax
  800e7d:	0f b6 c9             	movzbl %cl,%ecx
  800e80:	29 c8                	sub    %ecx,%eax
  800e82:	eb 16                	jmp    800e9a <memcmp+0x4a>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800e84:	4f                   	dec    %edi
  800e85:	ba 00 00 00 00       	mov    $0x0,%edx
  800e8a:	39 fa                	cmp    %edi,%edx
  800e8c:	75 df                	jne    800e6d <memcmp+0x1d>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800e8e:	b8 00 00 00 00       	mov    $0x0,%eax
  800e93:	eb 05                	jmp    800e9a <memcmp+0x4a>
  800e95:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800e9a:	5b                   	pop    %ebx
  800e9b:	5e                   	pop    %esi
  800e9c:	5f                   	pop    %edi
  800e9d:	c9                   	leave  
  800e9e:	c3                   	ret    

00800e9f <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800e9f:	55                   	push   %ebp
  800ea0:	89 e5                	mov    %esp,%ebp
  800ea2:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800ea5:	89 c2                	mov    %eax,%edx
  800ea7:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800eaa:	39 d0                	cmp    %edx,%eax
  800eac:	73 12                	jae    800ec0 <memfind+0x21>
		if (*(const unsigned char *) s == (unsigned char) c)
  800eae:	8a 4d 0c             	mov    0xc(%ebp),%cl
  800eb1:	38 08                	cmp    %cl,(%eax)
  800eb3:	75 06                	jne    800ebb <memfind+0x1c>
  800eb5:	eb 09                	jmp    800ec0 <memfind+0x21>
  800eb7:	38 08                	cmp    %cl,(%eax)
  800eb9:	74 05                	je     800ec0 <memfind+0x21>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800ebb:	40                   	inc    %eax
  800ebc:	39 c2                	cmp    %eax,%edx
  800ebe:	77 f7                	ja     800eb7 <memfind+0x18>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800ec0:	c9                   	leave  
  800ec1:	c3                   	ret    

00800ec2 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800ec2:	55                   	push   %ebp
  800ec3:	89 e5                	mov    %esp,%ebp
  800ec5:	57                   	push   %edi
  800ec6:	56                   	push   %esi
  800ec7:	53                   	push   %ebx
  800ec8:	8b 55 08             	mov    0x8(%ebp),%edx
  800ecb:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800ece:	eb 01                	jmp    800ed1 <strtol+0xf>
		s++;
  800ed0:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800ed1:	8a 02                	mov    (%edx),%al
  800ed3:	3c 20                	cmp    $0x20,%al
  800ed5:	74 f9                	je     800ed0 <strtol+0xe>
  800ed7:	3c 09                	cmp    $0x9,%al
  800ed9:	74 f5                	je     800ed0 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800edb:	3c 2b                	cmp    $0x2b,%al
  800edd:	75 08                	jne    800ee7 <strtol+0x25>
		s++;
  800edf:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800ee0:	bf 00 00 00 00       	mov    $0x0,%edi
  800ee5:	eb 13                	jmp    800efa <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800ee7:	3c 2d                	cmp    $0x2d,%al
  800ee9:	75 0a                	jne    800ef5 <strtol+0x33>
		s++, neg = 1;
  800eeb:	8d 52 01             	lea    0x1(%edx),%edx
  800eee:	bf 01 00 00 00       	mov    $0x1,%edi
  800ef3:	eb 05                	jmp    800efa <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800ef5:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800efa:	85 db                	test   %ebx,%ebx
  800efc:	74 05                	je     800f03 <strtol+0x41>
  800efe:	83 fb 10             	cmp    $0x10,%ebx
  800f01:	75 28                	jne    800f2b <strtol+0x69>
  800f03:	8a 02                	mov    (%edx),%al
  800f05:	3c 30                	cmp    $0x30,%al
  800f07:	75 10                	jne    800f19 <strtol+0x57>
  800f09:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800f0d:	75 0a                	jne    800f19 <strtol+0x57>
		s += 2, base = 16;
  800f0f:	83 c2 02             	add    $0x2,%edx
  800f12:	bb 10 00 00 00       	mov    $0x10,%ebx
  800f17:	eb 12                	jmp    800f2b <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  800f19:	85 db                	test   %ebx,%ebx
  800f1b:	75 0e                	jne    800f2b <strtol+0x69>
  800f1d:	3c 30                	cmp    $0x30,%al
  800f1f:	75 05                	jne    800f26 <strtol+0x64>
		s++, base = 8;
  800f21:	42                   	inc    %edx
  800f22:	b3 08                	mov    $0x8,%bl
  800f24:	eb 05                	jmp    800f2b <strtol+0x69>
	else if (base == 0)
		base = 10;
  800f26:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800f2b:	b8 00 00 00 00       	mov    $0x0,%eax
  800f30:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800f32:	8a 0a                	mov    (%edx),%cl
  800f34:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800f37:	80 fb 09             	cmp    $0x9,%bl
  800f3a:	77 08                	ja     800f44 <strtol+0x82>
			dig = *s - '0';
  800f3c:	0f be c9             	movsbl %cl,%ecx
  800f3f:	83 e9 30             	sub    $0x30,%ecx
  800f42:	eb 1e                	jmp    800f62 <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  800f44:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800f47:	80 fb 19             	cmp    $0x19,%bl
  800f4a:	77 08                	ja     800f54 <strtol+0x92>
			dig = *s - 'a' + 10;
  800f4c:	0f be c9             	movsbl %cl,%ecx
  800f4f:	83 e9 57             	sub    $0x57,%ecx
  800f52:	eb 0e                	jmp    800f62 <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  800f54:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800f57:	80 fb 19             	cmp    $0x19,%bl
  800f5a:	77 13                	ja     800f6f <strtol+0xad>
			dig = *s - 'A' + 10;
  800f5c:	0f be c9             	movsbl %cl,%ecx
  800f5f:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800f62:	39 f1                	cmp    %esi,%ecx
  800f64:	7d 0d                	jge    800f73 <strtol+0xb1>
			break;
		s++, val = (val * base) + dig;
  800f66:	42                   	inc    %edx
  800f67:	0f af c6             	imul   %esi,%eax
  800f6a:	8d 04 01             	lea    (%ecx,%eax,1),%eax
		// we don't properly detect overflow!
	}
  800f6d:	eb c3                	jmp    800f32 <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800f6f:	89 c1                	mov    %eax,%ecx
  800f71:	eb 02                	jmp    800f75 <strtol+0xb3>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800f73:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800f75:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800f79:	74 05                	je     800f80 <strtol+0xbe>
		*endptr = (char *) s;
  800f7b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800f7e:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800f80:	85 ff                	test   %edi,%edi
  800f82:	74 04                	je     800f88 <strtol+0xc6>
  800f84:	89 c8                	mov    %ecx,%eax
  800f86:	f7 d8                	neg    %eax
}
  800f88:	5b                   	pop    %ebx
  800f89:	5e                   	pop    %esi
  800f8a:	5f                   	pop    %edi
  800f8b:	c9                   	leave  
  800f8c:	c3                   	ret    
  800f8d:	00 00                	add    %al,(%eax)
	...

00800f90 <syscall>:
	return ret;
}

static int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  800f90:	55                   	push   %ebp
  800f91:	89 e5                	mov    %esp,%ebp
  800f93:	57                   	push   %edi
  800f94:	56                   	push   %esi
  800f95:	53                   	push   %ebx
  800f96:	83 ec 1c             	sub    $0x1c,%esp
  800f99:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800f9c:	89 55 e0             	mov    %edx,-0x20(%ebp)
  800f9f:	89 ca                	mov    %ecx,%edx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800fa1:	8b 75 14             	mov    0x14(%ebp),%esi
  800fa4:	8b 7d 10             	mov    0x10(%ebp),%edi
  800fa7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800faa:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800fad:	cd 30                	int    $0x30
  800faf:	89 c2                	mov    %eax,%edx
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800fb1:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800fb5:	74 1c                	je     800fd3 <syscall+0x43>
  800fb7:	85 c0                	test   %eax,%eax
  800fb9:	7e 18                	jle    800fd3 <syscall+0x43>
		panic("syscall %d returned %d (> 0)", num, ret);
  800fbb:	83 ec 0c             	sub    $0xc,%esp
  800fbe:	50                   	push   %eax
  800fbf:	ff 75 e4             	pushl  -0x1c(%ebp)
  800fc2:	68 04 18 80 00       	push   $0x801804
  800fc7:	6a 42                	push   $0x42
  800fc9:	68 21 18 80 00       	push   $0x801821
  800fce:	e8 b1 f5 ff ff       	call   800584 <_panic>

	return ret;
}
  800fd3:	89 d0                	mov    %edx,%eax
  800fd5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800fd8:	5b                   	pop    %ebx
  800fd9:	5e                   	pop    %esi
  800fda:	5f                   	pop    %edi
  800fdb:	c9                   	leave  
  800fdc:	c3                   	ret    

00800fdd <sys_cputs>:

void
sys_cputs(const char *s, size_t len)
{	
  800fdd:	55                   	push   %ebp
  800fde:	89 e5                	mov    %esp,%ebp
  800fe0:	83 ec 08             	sub    $0x8,%esp
	// my_sysenter(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
	// return;
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
  800fe3:	6a 00                	push   $0x0
  800fe5:	6a 00                	push   $0x0
  800fe7:	6a 00                	push   $0x0
  800fe9:	ff 75 0c             	pushl  0xc(%ebp)
  800fec:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800fef:	ba 00 00 00 00       	mov    $0x0,%edx
  800ff4:	b8 00 00 00 00       	mov    $0x0,%eax
  800ff9:	e8 92 ff ff ff       	call   800f90 <syscall>
  800ffe:	83 c4 10             	add    $0x10,%esp
	return;
}
  801001:	c9                   	leave  
  801002:	c3                   	ret    

00801003 <sys_cgetc>:

int
sys_cgetc(void)
{
  801003:	55                   	push   %ebp
  801004:	89 e5                	mov    %esp,%ebp
  801006:	83 ec 08             	sub    $0x8,%esp
	// return my_sysenter(SYS_cgetc, 0, 0, 0, 0, 0, 0);
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
  801009:	6a 00                	push   $0x0
  80100b:	6a 00                	push   $0x0
  80100d:	6a 00                	push   $0x0
  80100f:	6a 00                	push   $0x0
  801011:	b9 00 00 00 00       	mov    $0x0,%ecx
  801016:	ba 00 00 00 00       	mov    $0x0,%edx
  80101b:	b8 01 00 00 00       	mov    $0x1,%eax
  801020:	e8 6b ff ff ff       	call   800f90 <syscall>
}
  801025:	c9                   	leave  
  801026:	c3                   	ret    

00801027 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  801027:	55                   	push   %ebp
  801028:	89 e5                	mov    %esp,%ebp
  80102a:	83 ec 08             	sub    $0x8,%esp
	// return my_sysenter(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
  80102d:	6a 00                	push   $0x0
  80102f:	6a 00                	push   $0x0
  801031:	6a 00                	push   $0x0
  801033:	6a 00                	push   $0x0
  801035:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801038:	ba 01 00 00 00       	mov    $0x1,%edx
  80103d:	b8 03 00 00 00       	mov    $0x3,%eax
  801042:	e8 49 ff ff ff       	call   800f90 <syscall>
}
  801047:	c9                   	leave  
  801048:	c3                   	ret    

00801049 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  801049:	55                   	push   %ebp
  80104a:	89 e5                	mov    %esp,%ebp
  80104c:	83 ec 08             	sub    $0x8,%esp
	// return my_sysenter(SYS_getenvid, 0, 0, 0, 0, 0, 0);
	return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
  80104f:	6a 00                	push   $0x0
  801051:	6a 00                	push   $0x0
  801053:	6a 00                	push   $0x0
  801055:	6a 00                	push   $0x0
  801057:	b9 00 00 00 00       	mov    $0x0,%ecx
  80105c:	ba 00 00 00 00       	mov    $0x0,%edx
  801061:	b8 02 00 00 00       	mov    $0x2,%eax
  801066:	e8 25 ff ff ff       	call   800f90 <syscall>
}
  80106b:	c9                   	leave  
  80106c:	c3                   	ret    

0080106d <sys_yield>:

void
sys_yield(void)
{
  80106d:	55                   	push   %ebp
  80106e:	89 e5                	mov    %esp,%ebp
  801070:	83 ec 08             	sub    $0x8,%esp
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
  801073:	6a 00                	push   $0x0
  801075:	6a 00                	push   $0x0
  801077:	6a 00                	push   $0x0
  801079:	6a 00                	push   $0x0
  80107b:	b9 00 00 00 00       	mov    $0x0,%ecx
  801080:	ba 00 00 00 00       	mov    $0x0,%edx
  801085:	b8 0a 00 00 00       	mov    $0xa,%eax
  80108a:	e8 01 ff ff ff       	call   800f90 <syscall>
  80108f:	83 c4 10             	add    $0x10,%esp
}
  801092:	c9                   	leave  
  801093:	c3                   	ret    

00801094 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  801094:	55                   	push   %ebp
  801095:	89 e5                	mov    %esp,%ebp
  801097:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
  80109a:	6a 00                	push   $0x0
  80109c:	6a 00                	push   $0x0
  80109e:	ff 75 10             	pushl  0x10(%ebp)
  8010a1:	ff 75 0c             	pushl  0xc(%ebp)
  8010a4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8010a7:	ba 01 00 00 00       	mov    $0x1,%edx
  8010ac:	b8 04 00 00 00       	mov    $0x4,%eax
  8010b1:	e8 da fe ff ff       	call   800f90 <syscall>
}
  8010b6:	c9                   	leave  
  8010b7:	c3                   	ret    

008010b8 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8010b8:	55                   	push   %ebp
  8010b9:	89 e5                	mov    %esp,%ebp
  8010bb:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
  8010be:	ff 75 18             	pushl  0x18(%ebp)
  8010c1:	ff 75 14             	pushl  0x14(%ebp)
  8010c4:	ff 75 10             	pushl  0x10(%ebp)
  8010c7:	ff 75 0c             	pushl  0xc(%ebp)
  8010ca:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8010cd:	ba 01 00 00 00       	mov    $0x1,%edx
  8010d2:	b8 05 00 00 00       	mov    $0x5,%eax
  8010d7:	e8 b4 fe ff ff       	call   800f90 <syscall>
}
  8010dc:	c9                   	leave  
  8010dd:	c3                   	ret    

008010de <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  8010de:	55                   	push   %ebp
  8010df:	89 e5                	mov    %esp,%ebp
  8010e1:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
  8010e4:	6a 00                	push   $0x0
  8010e6:	6a 00                	push   $0x0
  8010e8:	6a 00                	push   $0x0
  8010ea:	ff 75 0c             	pushl  0xc(%ebp)
  8010ed:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8010f0:	ba 01 00 00 00       	mov    $0x1,%edx
  8010f5:	b8 06 00 00 00       	mov    $0x6,%eax
  8010fa:	e8 91 fe ff ff       	call   800f90 <syscall>
}
  8010ff:	c9                   	leave  
  801100:	c3                   	ret    

00801101 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  801101:	55                   	push   %ebp
  801102:	89 e5                	mov    %esp,%ebp
  801104:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
  801107:	6a 00                	push   $0x0
  801109:	6a 00                	push   $0x0
  80110b:	6a 00                	push   $0x0
  80110d:	ff 75 0c             	pushl  0xc(%ebp)
  801110:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801113:	ba 01 00 00 00       	mov    $0x1,%edx
  801118:	b8 08 00 00 00       	mov    $0x8,%eax
  80111d:	e8 6e fe ff ff       	call   800f90 <syscall>
}
  801122:	c9                   	leave  
  801123:	c3                   	ret    

00801124 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  801124:	55                   	push   %ebp
  801125:	89 e5                	mov    %esp,%ebp
  801127:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
  80112a:	6a 00                	push   $0x0
  80112c:	6a 00                	push   $0x0
  80112e:	6a 00                	push   $0x0
  801130:	ff 75 0c             	pushl  0xc(%ebp)
  801133:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801136:	ba 01 00 00 00       	mov    $0x1,%edx
  80113b:	b8 09 00 00 00       	mov    $0x9,%eax
  801140:	e8 4b fe ff ff       	call   800f90 <syscall>
}
  801145:	c9                   	leave  
  801146:	c3                   	ret    

00801147 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  801147:	55                   	push   %ebp
  801148:	89 e5                	mov    %esp,%ebp
  80114a:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
  80114d:	6a 00                	push   $0x0
  80114f:	ff 75 14             	pushl  0x14(%ebp)
  801152:	ff 75 10             	pushl  0x10(%ebp)
  801155:	ff 75 0c             	pushl  0xc(%ebp)
  801158:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80115b:	ba 00 00 00 00       	mov    $0x0,%edx
  801160:	b8 0b 00 00 00       	mov    $0xb,%eax
  801165:	e8 26 fe ff ff       	call   800f90 <syscall>
}
  80116a:	c9                   	leave  
  80116b:	c3                   	ret    

0080116c <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  80116c:	55                   	push   %ebp
  80116d:	89 e5                	mov    %esp,%ebp
  80116f:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
  801172:	6a 00                	push   $0x0
  801174:	6a 00                	push   $0x0
  801176:	6a 00                	push   $0x0
  801178:	6a 00                	push   $0x0
  80117a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80117d:	ba 01 00 00 00       	mov    $0x1,%edx
  801182:	b8 0c 00 00 00       	mov    $0xc,%eax
  801187:	e8 04 fe ff ff       	call   800f90 <syscall>
}
  80118c:	c9                   	leave  
  80118d:	c3                   	ret    
	...

00801190 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801190:	55                   	push   %ebp
  801191:	89 e5                	mov    %esp,%ebp
  801193:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  801196:	83 3d d0 20 80 00 00 	cmpl   $0x0,0x8020d0
  80119d:	75 52                	jne    8011f1 <set_pgfault_handler+0x61>
		// First time through!	
		// LAB 4: Your code here.

		//int sys_page_alloc(envid_t envid, void *va, int perm)
		r = sys_page_alloc(0, (void*)(UXSTACKTOP - PGSIZE), PTE_U | PTE_W | PTE_P);
  80119f:	83 ec 04             	sub    $0x4,%esp
  8011a2:	6a 07                	push   $0x7
  8011a4:	68 00 f0 bf ee       	push   $0xeebff000
  8011a9:	6a 00                	push   $0x0
  8011ab:	e8 e4 fe ff ff       	call   801094 <sys_page_alloc>
		if (r < 0) {
  8011b0:	83 c4 10             	add    $0x10,%esp
  8011b3:	85 c0                	test   %eax,%eax
  8011b5:	79 12                	jns    8011c9 <set_pgfault_handler+0x39>
			panic("sys_page_alloc error : %e\n", r);
  8011b7:	50                   	push   %eax
  8011b8:	68 2f 18 80 00       	push   $0x80182f
  8011bd:	6a 24                	push   $0x24
  8011bf:	68 4a 18 80 00       	push   $0x80184a
  8011c4:	e8 bb f3 ff ff       	call   800584 <_panic>
		}

		// how to know envid, put 0, envid2env will help us to get curenv in syscall
		r = sys_env_set_pgfault_upcall(0, _pgfault_upcall);		
  8011c9:	83 ec 08             	sub    $0x8,%esp
  8011cc:	68 fc 11 80 00       	push   $0x8011fc
  8011d1:	6a 00                	push   $0x0
  8011d3:	e8 4c ff ff ff       	call   801124 <sys_env_set_pgfault_upcall>
		if (r < 0) {
  8011d8:	83 c4 10             	add    $0x10,%esp
  8011db:	85 c0                	test   %eax,%eax
  8011dd:	79 12                	jns    8011f1 <set_pgfault_handler+0x61>
			panic("sys_env_set_pgfault_upcall error : %e\n", r);
  8011df:	50                   	push   %eax
  8011e0:	68 58 18 80 00       	push   $0x801858
  8011e5:	6a 2a                	push   $0x2a
  8011e7:	68 4a 18 80 00       	push   $0x80184a
  8011ec:	e8 93 f3 ff ff       	call   800584 <_panic>
		}
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  8011f1:	8b 45 08             	mov    0x8(%ebp),%eax
  8011f4:	a3 d0 20 80 00       	mov    %eax,0x8020d0
}
  8011f9:	c9                   	leave  
  8011fa:	c3                   	ret    
	...

008011fc <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  8011fc:	54                   	push   %esp
	movl _pgfault_handler, %eax
  8011fd:	a1 d0 20 80 00       	mov    0x8020d0,%eax
	call *%eax
  801202:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  801204:	83 c4 04             	add    $0x4,%esp
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	
	// fix old esp
	movl 0x30(%esp), %eax
  801207:	8b 44 24 30          	mov    0x30(%esp),%eax
	subl $0x4, %eax
  80120b:	83 e8 04             	sub    $0x4,%eax
	movl %eax, 0x30(%esp)
  80120e:	89 44 24 30          	mov    %eax,0x30(%esp)

	// set trap-time %eip
	movl 0x28(%esp), %ebx
  801212:	8b 5c 24 28          	mov    0x28(%esp),%ebx
	movl %ebx, (%eax)
  801216:	89 18                	mov    %ebx,(%eax)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	addl $0x08, %esp 	// ignore err_code and fault_va
  801218:	83 c4 08             	add    $0x8,%esp
	popal 				// restore registers
  80121b:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $0x04, %esp 	// ignore eip 
  80121c:	83 c4 04             	add    $0x4,%esp
	popfl				// modify eflags
  80121f:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp
  801220:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  801221:	c3                   	ret    
	...

00801224 <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  801224:	55                   	push   %ebp
  801225:	89 e5                	mov    %esp,%ebp
  801227:	57                   	push   %edi
  801228:	56                   	push   %esi
  801229:	83 ec 10             	sub    $0x10,%esp
  80122c:	8b 7d 08             	mov    0x8(%ebp),%edi
  80122f:	8b 4d 10             	mov    0x10(%ebp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  801232:	89 7d f0             	mov    %edi,-0x10(%ebp)
  801235:	8b 75 0c             	mov    0xc(%ebp),%esi
  const DWunion dd = {.ll = d};
  801238:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  80123b:	8b 45 14             	mov    0x14(%ebp),%eax
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  80123e:	85 c0                	test   %eax,%eax
  801240:	75 2e                	jne    801270 <__udivdi3+0x4c>
    {
      if (d0 > n1)
  801242:	39 f1                	cmp    %esi,%ecx
  801244:	77 5a                	ja     8012a0 <__udivdi3+0x7c>
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  801246:	85 c9                	test   %ecx,%ecx
  801248:	75 0b                	jne    801255 <__udivdi3+0x31>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  80124a:	b8 01 00 00 00       	mov    $0x1,%eax
  80124f:	31 d2                	xor    %edx,%edx
  801251:	f7 f1                	div    %ecx
  801253:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  801255:	31 d2                	xor    %edx,%edx
  801257:	89 f0                	mov    %esi,%eax
  801259:	f7 f1                	div    %ecx
  80125b:	89 c6                	mov    %eax,%esi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  80125d:	89 f8                	mov    %edi,%eax
  80125f:	f7 f1                	div    %ecx
  801261:	89 c7                	mov    %eax,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  801263:	89 f8                	mov    %edi,%eax
  801265:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801267:	83 c4 10             	add    $0x10,%esp
  80126a:	5e                   	pop    %esi
  80126b:	5f                   	pop    %edi
  80126c:	c9                   	leave  
  80126d:	c3                   	ret    
  80126e:	66 90                	xchg   %ax,%ax
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  801270:	39 f0                	cmp    %esi,%eax
  801272:	77 1c                	ja     801290 <__udivdi3+0x6c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  801274:	0f bd f8             	bsr    %eax,%edi
	  if (bm == 0)
  801277:	83 f7 1f             	xor    $0x1f,%edi
  80127a:	75 3c                	jne    8012b8 <__udivdi3+0x94>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  80127c:	39 f0                	cmp    %esi,%eax
  80127e:	0f 82 90 00 00 00    	jb     801314 <__udivdi3+0xf0>
  801284:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801287:	39 55 f4             	cmp    %edx,-0xc(%ebp)
  80128a:	0f 86 84 00 00 00    	jbe    801314 <__udivdi3+0xf0>
  801290:	31 f6                	xor    %esi,%esi
  801292:	31 ff                	xor    %edi,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  801294:	89 f8                	mov    %edi,%eax
  801296:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801298:	83 c4 10             	add    $0x10,%esp
  80129b:	5e                   	pop    %esi
  80129c:	5f                   	pop    %edi
  80129d:	c9                   	leave  
  80129e:	c3                   	ret    
  80129f:	90                   	nop
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  8012a0:	89 f2                	mov    %esi,%edx
  8012a2:	89 f8                	mov    %edi,%eax
  8012a4:	f7 f1                	div    %ecx
  8012a6:	89 c7                	mov    %eax,%edi
  8012a8:	31 f6                	xor    %esi,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  8012aa:	89 f8                	mov    %edi,%eax
  8012ac:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  8012ae:	83 c4 10             	add    $0x10,%esp
  8012b1:	5e                   	pop    %esi
  8012b2:	5f                   	pop    %edi
  8012b3:	c9                   	leave  
  8012b4:	c3                   	ret    
  8012b5:	8d 76 00             	lea    0x0(%esi),%esi
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  8012b8:	89 f9                	mov    %edi,%ecx
  8012ba:	d3 e0                	shl    %cl,%eax
  8012bc:	89 45 e8             	mov    %eax,-0x18(%ebp)
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  8012bf:	b8 20 00 00 00       	mov    $0x20,%eax
  8012c4:	29 f8                	sub    %edi,%eax

	      d1 = (d1 << bm) | (d0 >> b);
  8012c6:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8012c9:	88 c1                	mov    %al,%cl
  8012cb:	d3 ea                	shr    %cl,%edx
  8012cd:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  8012d0:	09 ca                	or     %ecx,%edx
  8012d2:	89 55 ec             	mov    %edx,-0x14(%ebp)
	      d0 = d0 << bm;
  8012d5:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8012d8:	89 f9                	mov    %edi,%ecx
  8012da:	d3 e2                	shl    %cl,%edx
  8012dc:	89 55 f4             	mov    %edx,-0xc(%ebp)
	      n2 = n1 >> b;
  8012df:	89 f2                	mov    %esi,%edx
  8012e1:	88 c1                	mov    %al,%cl
  8012e3:	d3 ea                	shr    %cl,%edx
  8012e5:	89 55 e8             	mov    %edx,-0x18(%ebp)
	      n1 = (n1 << bm) | (n0 >> b);
  8012e8:	89 f2                	mov    %esi,%edx
  8012ea:	89 f9                	mov    %edi,%ecx
  8012ec:	d3 e2                	shl    %cl,%edx
  8012ee:	8b 75 f0             	mov    -0x10(%ebp),%esi
  8012f1:	88 c1                	mov    %al,%cl
  8012f3:	d3 ee                	shr    %cl,%esi
  8012f5:	09 d6                	or     %edx,%esi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  8012f7:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  8012fa:	89 f0                	mov    %esi,%eax
  8012fc:	89 ca                	mov    %ecx,%edx
  8012fe:	f7 75 ec             	divl   -0x14(%ebp)
  801301:	89 d1                	mov    %edx,%ecx
  801303:	89 c6                	mov    %eax,%esi
	      umul_ppmm (m1, m0, q0, d0);
  801305:	f7 65 f4             	mull   -0xc(%ebp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801308:	39 d1                	cmp    %edx,%ecx
  80130a:	72 28                	jb     801334 <__udivdi3+0x110>
  80130c:	74 1a                	je     801328 <__udivdi3+0x104>
  80130e:	89 f7                	mov    %esi,%edi
  801310:	31 f6                	xor    %esi,%esi
  801312:	eb 80                	jmp    801294 <__udivdi3+0x70>
	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  801314:	31 f6                	xor    %esi,%esi
  801316:	bf 01 00 00 00       	mov    $0x1,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  80131b:	89 f8                	mov    %edi,%eax
  80131d:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  80131f:	83 c4 10             	add    $0x10,%esp
  801322:	5e                   	pop    %esi
  801323:	5f                   	pop    %edi
  801324:	c9                   	leave  
  801325:	c3                   	ret    
  801326:	66 90                	xchg   %ax,%ax

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  801328:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80132b:	89 f9                	mov    %edi,%ecx
  80132d:	d3 e2                	shl    %cl,%edx

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  80132f:	39 c2                	cmp    %eax,%edx
  801331:	73 db                	jae    80130e <__udivdi3+0xea>
  801333:	90                   	nop
		{
		  q0--;
  801334:	8d 7e ff             	lea    -0x1(%esi),%edi
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  801337:	31 f6                	xor    %esi,%esi
  801339:	e9 56 ff ff ff       	jmp    801294 <__udivdi3+0x70>
	...

00801340 <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  801340:	55                   	push   %ebp
  801341:	89 e5                	mov    %esp,%ebp
  801343:	57                   	push   %edi
  801344:	56                   	push   %esi
  801345:	83 ec 20             	sub    $0x20,%esp
  801348:	8b 45 08             	mov    0x8(%ebp),%eax
  80134b:	8b 4d 10             	mov    0x10(%ebp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  80134e:	89 45 e8             	mov    %eax,-0x18(%ebp)
  801351:	8b 75 0c             	mov    0xc(%ebp),%esi
  const DWunion dd = {.ll = d};
  801354:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  801357:	8b 7d 14             	mov    0x14(%ebp),%edi
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  80135a:	89 45 f0             	mov    %eax,-0x10(%ebp)
  n1 = nn.s.high;
  80135d:	89 f2                	mov    %esi,%edx

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  80135f:	85 ff                	test   %edi,%edi
  801361:	75 15                	jne    801378 <__umoddi3+0x38>
    {
      if (d0 > n1)
  801363:	39 f1                	cmp    %esi,%ecx
  801365:	0f 86 99 00 00 00    	jbe    801404 <__umoddi3+0xc4>
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  80136b:	f7 f1                	div    %ecx

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
  80136d:	89 d0                	mov    %edx,%eax
  80136f:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  801371:	83 c4 20             	add    $0x20,%esp
  801374:	5e                   	pop    %esi
  801375:	5f                   	pop    %edi
  801376:	c9                   	leave  
  801377:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  801378:	39 f7                	cmp    %esi,%edi
  80137a:	0f 87 a4 00 00 00    	ja     801424 <__umoddi3+0xe4>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  801380:	0f bd c7             	bsr    %edi,%eax
	  if (bm == 0)
  801383:	83 f0 1f             	xor    $0x1f,%eax
  801386:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801389:	0f 84 a1 00 00 00    	je     801430 <__umoddi3+0xf0>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  80138f:	89 f8                	mov    %edi,%eax
  801391:	8a 4d ec             	mov    -0x14(%ebp),%cl
  801394:	d3 e0                	shl    %cl,%eax
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  801396:	bf 20 00 00 00       	mov    $0x20,%edi
  80139b:	2b 7d ec             	sub    -0x14(%ebp),%edi

	      d1 = (d1 << bm) | (d0 >> b);
  80139e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8013a1:	89 f9                	mov    %edi,%ecx
  8013a3:	d3 ea                	shr    %cl,%edx
  8013a5:	09 c2                	or     %eax,%edx
  8013a7:	89 55 f0             	mov    %edx,-0x10(%ebp)
	      d0 = d0 << bm;
  8013aa:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8013ad:	8a 4d ec             	mov    -0x14(%ebp),%cl
  8013b0:	d3 e0                	shl    %cl,%eax
  8013b2:	89 45 f4             	mov    %eax,-0xc(%ebp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  8013b5:	89 f2                	mov    %esi,%edx
  8013b7:	d3 e2                	shl    %cl,%edx
	      n0 = n0 << bm;
  8013b9:	8b 45 e8             	mov    -0x18(%ebp),%eax
  8013bc:	d3 e0                	shl    %cl,%eax
  8013be:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  8013c1:	8b 45 e8             	mov    -0x18(%ebp),%eax
  8013c4:	89 f9                	mov    %edi,%ecx
  8013c6:	d3 e8                	shr    %cl,%eax
  8013c8:	09 d0                	or     %edx,%eax

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  8013ca:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  8013cc:	89 f2                	mov    %esi,%edx
  8013ce:	f7 75 f0             	divl   -0x10(%ebp)
  8013d1:	89 d6                	mov    %edx,%esi
	      umul_ppmm (m1, m0, q0, d0);
  8013d3:	f7 65 f4             	mull   -0xc(%ebp)
  8013d6:	89 55 e8             	mov    %edx,-0x18(%ebp)
  8013d9:	89 c1                	mov    %eax,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  8013db:	39 d6                	cmp    %edx,%esi
  8013dd:	72 71                	jb     801450 <__umoddi3+0x110>
  8013df:	74 7f                	je     801460 <__umoddi3+0x120>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  8013e1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8013e4:	29 c8                	sub    %ecx,%eax
  8013e6:	19 d6                	sbb    %edx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
  8013e8:	8a 4d ec             	mov    -0x14(%ebp),%cl
  8013eb:	d3 e8                	shr    %cl,%eax
  8013ed:	89 f2                	mov    %esi,%edx
  8013ef:	89 f9                	mov    %edi,%ecx
  8013f1:	d3 e2                	shl    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
  8013f3:	09 d0                	or     %edx,%eax
  8013f5:	89 f2                	mov    %esi,%edx
  8013f7:	8a 4d ec             	mov    -0x14(%ebp),%cl
  8013fa:	d3 ea                	shr    %cl,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  8013fc:	83 c4 20             	add    $0x20,%esp
  8013ff:	5e                   	pop    %esi
  801400:	5f                   	pop    %edi
  801401:	c9                   	leave  
  801402:	c3                   	ret    
  801403:	90                   	nop
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  801404:	85 c9                	test   %ecx,%ecx
  801406:	75 0b                	jne    801413 <__umoddi3+0xd3>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  801408:	b8 01 00 00 00       	mov    $0x1,%eax
  80140d:	31 d2                	xor    %edx,%edx
  80140f:	f7 f1                	div    %ecx
  801411:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  801413:	89 f0                	mov    %esi,%eax
  801415:	31 d2                	xor    %edx,%edx
  801417:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801419:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80141c:	f7 f1                	div    %ecx
  80141e:	e9 4a ff ff ff       	jmp    80136d <__umoddi3+0x2d>
  801423:	90                   	nop
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
  801424:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  801426:	83 c4 20             	add    $0x20,%esp
  801429:	5e                   	pop    %esi
  80142a:	5f                   	pop    %edi
  80142b:	c9                   	leave  
  80142c:	c3                   	ret    
  80142d:	8d 76 00             	lea    0x0(%esi),%esi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  801430:	39 f7                	cmp    %esi,%edi
  801432:	72 05                	jb     801439 <__umoddi3+0xf9>
  801434:	3b 4d f0             	cmp    -0x10(%ebp),%ecx
  801437:	77 0c                	ja     801445 <__umoddi3+0x105>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  801439:	89 f2                	mov    %esi,%edx
  80143b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80143e:	29 c8                	sub    %ecx,%eax
  801440:	19 fa                	sbb    %edi,%edx
  801442:	89 45 f0             	mov    %eax,-0x10(%ebp)

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
  801445:	8b 45 f0             	mov    -0x10(%ebp),%eax
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  801448:	83 c4 20             	add    $0x20,%esp
  80144b:	5e                   	pop    %esi
  80144c:	5f                   	pop    %edi
  80144d:	c9                   	leave  
  80144e:	c3                   	ret    
  80144f:	90                   	nop
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  801450:	8b 55 e8             	mov    -0x18(%ebp),%edx
  801453:	89 c1                	mov    %eax,%ecx
  801455:	2b 4d f4             	sub    -0xc(%ebp),%ecx
  801458:	1b 55 f0             	sbb    -0x10(%ebp),%edx
  80145b:	eb 84                	jmp    8013e1 <__umoddi3+0xa1>
  80145d:	8d 76 00             	lea    0x0(%esi),%esi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801460:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  801463:	72 eb                	jb     801450 <__umoddi3+0x110>
  801465:	89 f2                	mov    %esi,%edx
  801467:	e9 75 ff ff ff       	jmp    8013e1 <__umoddi3+0xa1>
