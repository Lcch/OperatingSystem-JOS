
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
  800045:	68 d1 14 80 00       	push   $0x8014d1
  80004a:	68 a0 14 80 00       	push   $0x8014a0
  80004f:	e8 00 06 00 00       	call   800654 <cprintf>
			cprintf("MISMATCH\n");				\
			mismatch = 1;					\
		}							\
	} while (0)

	CHECK(edi, regs.reg_edi);
  800054:	ff 36                	pushl  (%esi)
  800056:	ff 33                	pushl  (%ebx)
  800058:	68 b0 14 80 00       	push   $0x8014b0
  80005d:	68 b4 14 80 00       	push   $0x8014b4
  800062:	e8 ed 05 00 00       	call   800654 <cprintf>
  800067:	83 c4 20             	add    $0x20,%esp
  80006a:	8b 06                	mov    (%esi),%eax
  80006c:	39 03                	cmp    %eax,(%ebx)
  80006e:	75 17                	jne    800087 <check_regs+0x53>
  800070:	83 ec 0c             	sub    $0xc,%esp
  800073:	68 c4 14 80 00       	push   $0x8014c4
  800078:	e8 d7 05 00 00       	call   800654 <cprintf>
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
  80008a:	68 c8 14 80 00       	push   $0x8014c8
  80008f:	e8 c0 05 00 00       	call   800654 <cprintf>
  800094:	83 c4 10             	add    $0x10,%esp
  800097:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(esi, regs.reg_esi);
  80009c:	ff 76 04             	pushl  0x4(%esi)
  80009f:	ff 73 04             	pushl  0x4(%ebx)
  8000a2:	68 d2 14 80 00       	push   $0x8014d2
  8000a7:	68 b4 14 80 00       	push   $0x8014b4
  8000ac:	e8 a3 05 00 00       	call   800654 <cprintf>
  8000b1:	83 c4 10             	add    $0x10,%esp
  8000b4:	8b 46 04             	mov    0x4(%esi),%eax
  8000b7:	39 43 04             	cmp    %eax,0x4(%ebx)
  8000ba:	75 12                	jne    8000ce <check_regs+0x9a>
  8000bc:	83 ec 0c             	sub    $0xc,%esp
  8000bf:	68 c4 14 80 00       	push   $0x8014c4
  8000c4:	e8 8b 05 00 00       	call   800654 <cprintf>
  8000c9:	83 c4 10             	add    $0x10,%esp
  8000cc:	eb 15                	jmp    8000e3 <check_regs+0xaf>
  8000ce:	83 ec 0c             	sub    $0xc,%esp
  8000d1:	68 c8 14 80 00       	push   $0x8014c8
  8000d6:	e8 79 05 00 00       	call   800654 <cprintf>
  8000db:	83 c4 10             	add    $0x10,%esp
  8000de:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(ebp, regs.reg_ebp);
  8000e3:	ff 76 08             	pushl  0x8(%esi)
  8000e6:	ff 73 08             	pushl  0x8(%ebx)
  8000e9:	68 d6 14 80 00       	push   $0x8014d6
  8000ee:	68 b4 14 80 00       	push   $0x8014b4
  8000f3:	e8 5c 05 00 00       	call   800654 <cprintf>
  8000f8:	83 c4 10             	add    $0x10,%esp
  8000fb:	8b 46 08             	mov    0x8(%esi),%eax
  8000fe:	39 43 08             	cmp    %eax,0x8(%ebx)
  800101:	75 12                	jne    800115 <check_regs+0xe1>
  800103:	83 ec 0c             	sub    $0xc,%esp
  800106:	68 c4 14 80 00       	push   $0x8014c4
  80010b:	e8 44 05 00 00       	call   800654 <cprintf>
  800110:	83 c4 10             	add    $0x10,%esp
  800113:	eb 15                	jmp    80012a <check_regs+0xf6>
  800115:	83 ec 0c             	sub    $0xc,%esp
  800118:	68 c8 14 80 00       	push   $0x8014c8
  80011d:	e8 32 05 00 00       	call   800654 <cprintf>
  800122:	83 c4 10             	add    $0x10,%esp
  800125:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(ebx, regs.reg_ebx);
  80012a:	ff 76 10             	pushl  0x10(%esi)
  80012d:	ff 73 10             	pushl  0x10(%ebx)
  800130:	68 da 14 80 00       	push   $0x8014da
  800135:	68 b4 14 80 00       	push   $0x8014b4
  80013a:	e8 15 05 00 00       	call   800654 <cprintf>
  80013f:	83 c4 10             	add    $0x10,%esp
  800142:	8b 46 10             	mov    0x10(%esi),%eax
  800145:	39 43 10             	cmp    %eax,0x10(%ebx)
  800148:	75 12                	jne    80015c <check_regs+0x128>
  80014a:	83 ec 0c             	sub    $0xc,%esp
  80014d:	68 c4 14 80 00       	push   $0x8014c4
  800152:	e8 fd 04 00 00       	call   800654 <cprintf>
  800157:	83 c4 10             	add    $0x10,%esp
  80015a:	eb 15                	jmp    800171 <check_regs+0x13d>
  80015c:	83 ec 0c             	sub    $0xc,%esp
  80015f:	68 c8 14 80 00       	push   $0x8014c8
  800164:	e8 eb 04 00 00       	call   800654 <cprintf>
  800169:	83 c4 10             	add    $0x10,%esp
  80016c:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(edx, regs.reg_edx);
  800171:	ff 76 14             	pushl  0x14(%esi)
  800174:	ff 73 14             	pushl  0x14(%ebx)
  800177:	68 de 14 80 00       	push   $0x8014de
  80017c:	68 b4 14 80 00       	push   $0x8014b4
  800181:	e8 ce 04 00 00       	call   800654 <cprintf>
  800186:	83 c4 10             	add    $0x10,%esp
  800189:	8b 46 14             	mov    0x14(%esi),%eax
  80018c:	39 43 14             	cmp    %eax,0x14(%ebx)
  80018f:	75 12                	jne    8001a3 <check_regs+0x16f>
  800191:	83 ec 0c             	sub    $0xc,%esp
  800194:	68 c4 14 80 00       	push   $0x8014c4
  800199:	e8 b6 04 00 00       	call   800654 <cprintf>
  80019e:	83 c4 10             	add    $0x10,%esp
  8001a1:	eb 15                	jmp    8001b8 <check_regs+0x184>
  8001a3:	83 ec 0c             	sub    $0xc,%esp
  8001a6:	68 c8 14 80 00       	push   $0x8014c8
  8001ab:	e8 a4 04 00 00       	call   800654 <cprintf>
  8001b0:	83 c4 10             	add    $0x10,%esp
  8001b3:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(ecx, regs.reg_ecx);
  8001b8:	ff 76 18             	pushl  0x18(%esi)
  8001bb:	ff 73 18             	pushl  0x18(%ebx)
  8001be:	68 e2 14 80 00       	push   $0x8014e2
  8001c3:	68 b4 14 80 00       	push   $0x8014b4
  8001c8:	e8 87 04 00 00       	call   800654 <cprintf>
  8001cd:	83 c4 10             	add    $0x10,%esp
  8001d0:	8b 46 18             	mov    0x18(%esi),%eax
  8001d3:	39 43 18             	cmp    %eax,0x18(%ebx)
  8001d6:	75 12                	jne    8001ea <check_regs+0x1b6>
  8001d8:	83 ec 0c             	sub    $0xc,%esp
  8001db:	68 c4 14 80 00       	push   $0x8014c4
  8001e0:	e8 6f 04 00 00       	call   800654 <cprintf>
  8001e5:	83 c4 10             	add    $0x10,%esp
  8001e8:	eb 15                	jmp    8001ff <check_regs+0x1cb>
  8001ea:	83 ec 0c             	sub    $0xc,%esp
  8001ed:	68 c8 14 80 00       	push   $0x8014c8
  8001f2:	e8 5d 04 00 00       	call   800654 <cprintf>
  8001f7:	83 c4 10             	add    $0x10,%esp
  8001fa:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(eax, regs.reg_eax);
  8001ff:	ff 76 1c             	pushl  0x1c(%esi)
  800202:	ff 73 1c             	pushl  0x1c(%ebx)
  800205:	68 e6 14 80 00       	push   $0x8014e6
  80020a:	68 b4 14 80 00       	push   $0x8014b4
  80020f:	e8 40 04 00 00       	call   800654 <cprintf>
  800214:	83 c4 10             	add    $0x10,%esp
  800217:	8b 46 1c             	mov    0x1c(%esi),%eax
  80021a:	39 43 1c             	cmp    %eax,0x1c(%ebx)
  80021d:	75 12                	jne    800231 <check_regs+0x1fd>
  80021f:	83 ec 0c             	sub    $0xc,%esp
  800222:	68 c4 14 80 00       	push   $0x8014c4
  800227:	e8 28 04 00 00       	call   800654 <cprintf>
  80022c:	83 c4 10             	add    $0x10,%esp
  80022f:	eb 15                	jmp    800246 <check_regs+0x212>
  800231:	83 ec 0c             	sub    $0xc,%esp
  800234:	68 c8 14 80 00       	push   $0x8014c8
  800239:	e8 16 04 00 00       	call   800654 <cprintf>
  80023e:	83 c4 10             	add    $0x10,%esp
  800241:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(eip, eip);
  800246:	ff 76 20             	pushl  0x20(%esi)
  800249:	ff 73 20             	pushl  0x20(%ebx)
  80024c:	68 ea 14 80 00       	push   $0x8014ea
  800251:	68 b4 14 80 00       	push   $0x8014b4
  800256:	e8 f9 03 00 00       	call   800654 <cprintf>
  80025b:	83 c4 10             	add    $0x10,%esp
  80025e:	8b 46 20             	mov    0x20(%esi),%eax
  800261:	39 43 20             	cmp    %eax,0x20(%ebx)
  800264:	75 12                	jne    800278 <check_regs+0x244>
  800266:	83 ec 0c             	sub    $0xc,%esp
  800269:	68 c4 14 80 00       	push   $0x8014c4
  80026e:	e8 e1 03 00 00       	call   800654 <cprintf>
  800273:	83 c4 10             	add    $0x10,%esp
  800276:	eb 15                	jmp    80028d <check_regs+0x259>
  800278:	83 ec 0c             	sub    $0xc,%esp
  80027b:	68 c8 14 80 00       	push   $0x8014c8
  800280:	e8 cf 03 00 00       	call   800654 <cprintf>
  800285:	83 c4 10             	add    $0x10,%esp
  800288:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(eflags, eflags);
  80028d:	ff 76 24             	pushl  0x24(%esi)
  800290:	ff 73 24             	pushl  0x24(%ebx)
  800293:	68 ee 14 80 00       	push   $0x8014ee
  800298:	68 b4 14 80 00       	push   $0x8014b4
  80029d:	e8 b2 03 00 00       	call   800654 <cprintf>
  8002a2:	83 c4 10             	add    $0x10,%esp
  8002a5:	8b 46 24             	mov    0x24(%esi),%eax
  8002a8:	39 43 24             	cmp    %eax,0x24(%ebx)
  8002ab:	75 12                	jne    8002bf <check_regs+0x28b>
  8002ad:	83 ec 0c             	sub    $0xc,%esp
  8002b0:	68 c4 14 80 00       	push   $0x8014c4
  8002b5:	e8 9a 03 00 00       	call   800654 <cprintf>
  8002ba:	83 c4 10             	add    $0x10,%esp
  8002bd:	eb 15                	jmp    8002d4 <check_regs+0x2a0>
  8002bf:	83 ec 0c             	sub    $0xc,%esp
  8002c2:	68 c8 14 80 00       	push   $0x8014c8
  8002c7:	e8 88 03 00 00       	call   800654 <cprintf>
  8002cc:	83 c4 10             	add    $0x10,%esp
  8002cf:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(esp, esp);
  8002d4:	ff 76 28             	pushl  0x28(%esi)
  8002d7:	ff 73 28             	pushl  0x28(%ebx)
  8002da:	68 f5 14 80 00       	push   $0x8014f5
  8002df:	68 b4 14 80 00       	push   $0x8014b4
  8002e4:	e8 6b 03 00 00       	call   800654 <cprintf>
  8002e9:	83 c4 10             	add    $0x10,%esp
  8002ec:	8b 46 28             	mov    0x28(%esi),%eax
  8002ef:	39 43 28             	cmp    %eax,0x28(%ebx)
  8002f2:	75 26                	jne    80031a <check_regs+0x2e6>
  8002f4:	83 ec 0c             	sub    $0xc,%esp
  8002f7:	68 c4 14 80 00       	push   $0x8014c4
  8002fc:	e8 53 03 00 00       	call   800654 <cprintf>

#undef CHECK

	cprintf("Registers %s ", testname);
  800301:	83 c4 08             	add    $0x8,%esp
  800304:	ff 75 0c             	pushl  0xc(%ebp)
  800307:	68 f9 14 80 00       	push   $0x8014f9
  80030c:	e8 43 03 00 00       	call   800654 <cprintf>
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
  80031d:	68 c8 14 80 00       	push   $0x8014c8
  800322:	e8 2d 03 00 00       	call   800654 <cprintf>

#undef CHECK

	cprintf("Registers %s ", testname);
  800327:	83 c4 08             	add    $0x8,%esp
  80032a:	ff 75 0c             	pushl  0xc(%ebp)
  80032d:	68 f9 14 80 00       	push   $0x8014f9
  800332:	e8 1d 03 00 00       	call   800654 <cprintf>
  800337:	83 c4 10             	add    $0x10,%esp
  80033a:	eb 12                	jmp    80034e <check_regs+0x31a>
	if (!mismatch)
		cprintf("OK\n");
  80033c:	83 ec 0c             	sub    $0xc,%esp
  80033f:	68 c4 14 80 00       	push   $0x8014c4
  800344:	e8 0b 03 00 00       	call   800654 <cprintf>
  800349:	83 c4 10             	add    $0x10,%esp
  80034c:	eb 10                	jmp    80035e <check_regs+0x32a>
	else
		cprintf("MISMATCH\n");
  80034e:	83 ec 0c             	sub    $0xc,%esp
  800351:	68 c8 14 80 00       	push   $0x8014c8
  800356:	e8 f9 02 00 00       	call   800654 <cprintf>
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
  80037f:	68 60 15 80 00       	push   $0x801560
  800384:	6a 51                	push   $0x51
  800386:	68 07 15 80 00       	push   $0x801507
  80038b:	e8 ec 01 00 00       	call   80057c <_panic>
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
  8003b8:	68 1f 15 80 00       	push   $0x80151f
  8003bd:	68 2d 15 80 00       	push   $0x80152d
  8003c2:	b9 a0 20 80 00       	mov    $0x8020a0,%ecx
  8003c7:	ba 18 15 80 00       	mov    $0x801518,%edx
  8003cc:	b8 20 20 80 00       	mov    $0x802020,%eax
  8003d1:	e8 5e fc ff ff       	call   800034 <check_regs>

	// Map UTEMP so the write succeeds
	if ((r = sys_page_alloc(0, UTEMP, PTE_U|PTE_P|PTE_W)) < 0)
  8003d6:	83 c4 0c             	add    $0xc,%esp
  8003d9:	6a 07                	push   $0x7
  8003db:	68 00 00 40 00       	push   $0x400000
  8003e0:	6a 00                	push   $0x0
  8003e2:	e8 a5 0c 00 00       	call   80108c <sys_page_alloc>
  8003e7:	83 c4 10             	add    $0x10,%esp
  8003ea:	85 c0                	test   %eax,%eax
  8003ec:	79 12                	jns    800400 <pgfault+0x9a>
		panic("sys_page_alloc: %e", r);
  8003ee:	50                   	push   %eax
  8003ef:	68 34 15 80 00       	push   $0x801534
  8003f4:	6a 5c                	push   $0x5c
  8003f6:	68 07 15 80 00       	push   $0x801507
  8003fb:	e8 7c 01 00 00       	call   80057c <_panic>
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
  800412:	e8 95 0d 00 00       	call   8011ac <set_pgfault_handler>

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
  8004e1:	68 94 15 80 00       	push   $0x801594
  8004e6:	e8 69 01 00 00       	call   800654 <cprintf>
  8004eb:	83 c4 10             	add    $0x10,%esp
	after.eip = before.eip;
  8004ee:	a1 40 20 80 00       	mov    0x802040,%eax
  8004f3:	a3 80 20 80 00       	mov    %eax,0x802080

	check_regs(&before, "before", &after, "after", "after page-fault");
  8004f8:	83 ec 08             	sub    $0x8,%esp
  8004fb:	68 47 15 80 00       	push   $0x801547
  800500:	68 58 15 80 00       	push   $0x801558
  800505:	b9 60 20 80 00       	mov    $0x802060,%ecx
  80050a:	ba 18 15 80 00       	mov    $0x801518,%edx
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
  80052b:	e8 11 0b 00 00       	call   801041 <sys_getenvid>
  800530:	25 ff 03 00 00       	and    $0x3ff,%eax
  800535:	c1 e0 07             	shl    $0x7,%eax
  800538:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80053d:	a3 cc 20 80 00       	mov    %eax,0x8020cc

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800542:	85 f6                	test   %esi,%esi
  800544:	7e 07                	jle    80054d <libmain+0x2d>
		binaryname = argv[0];
  800546:	8b 03                	mov    (%ebx),%eax
  800548:	a3 00 20 80 00       	mov    %eax,0x802000
	// call user main routine
	umain(argc, argv);
  80054d:	83 ec 08             	sub    $0x8,%esp
  800550:	53                   	push   %ebx
  800551:	56                   	push   %esi
  800552:	e8 b0 fe ff ff       	call   800407 <umain>

	// exit gracefully
	exit();
  800557:	e8 0c 00 00 00       	call   800568 <exit>
  80055c:	83 c4 10             	add    $0x10,%esp
}
  80055f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800562:	5b                   	pop    %ebx
  800563:	5e                   	pop    %esi
  800564:	c9                   	leave  
  800565:	c3                   	ret    
	...

00800568 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800568:	55                   	push   %ebp
  800569:	89 e5                	mov    %esp,%ebp
  80056b:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  80056e:	6a 00                	push   $0x0
  800570:	e8 aa 0a 00 00       	call   80101f <sys_env_destroy>
  800575:	83 c4 10             	add    $0x10,%esp
}
  800578:	c9                   	leave  
  800579:	c3                   	ret    
	...

0080057c <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80057c:	55                   	push   %ebp
  80057d:	89 e5                	mov    %esp,%ebp
  80057f:	56                   	push   %esi
  800580:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800581:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800584:	8b 1d 00 20 80 00    	mov    0x802000,%ebx
  80058a:	e8 b2 0a 00 00       	call   801041 <sys_getenvid>
  80058f:	83 ec 0c             	sub    $0xc,%esp
  800592:	ff 75 0c             	pushl  0xc(%ebp)
  800595:	ff 75 08             	pushl  0x8(%ebp)
  800598:	53                   	push   %ebx
  800599:	50                   	push   %eax
  80059a:	68 c0 15 80 00       	push   $0x8015c0
  80059f:	e8 b0 00 00 00       	call   800654 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8005a4:	83 c4 18             	add    $0x18,%esp
  8005a7:	56                   	push   %esi
  8005a8:	ff 75 10             	pushl  0x10(%ebp)
  8005ab:	e8 53 00 00 00       	call   800603 <vcprintf>
	cprintf("\n");
  8005b0:	c7 04 24 d0 14 80 00 	movl   $0x8014d0,(%esp)
  8005b7:	e8 98 00 00 00       	call   800654 <cprintf>
  8005bc:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8005bf:	cc                   	int3   
  8005c0:	eb fd                	jmp    8005bf <_panic+0x43>
	...

008005c4 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8005c4:	55                   	push   %ebp
  8005c5:	89 e5                	mov    %esp,%ebp
  8005c7:	53                   	push   %ebx
  8005c8:	83 ec 04             	sub    $0x4,%esp
  8005cb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8005ce:	8b 03                	mov    (%ebx),%eax
  8005d0:	8b 55 08             	mov    0x8(%ebp),%edx
  8005d3:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  8005d7:	40                   	inc    %eax
  8005d8:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  8005da:	3d ff 00 00 00       	cmp    $0xff,%eax
  8005df:	75 1a                	jne    8005fb <putch+0x37>
		sys_cputs(b->buf, b->idx);
  8005e1:	83 ec 08             	sub    $0x8,%esp
  8005e4:	68 ff 00 00 00       	push   $0xff
  8005e9:	8d 43 08             	lea    0x8(%ebx),%eax
  8005ec:	50                   	push   %eax
  8005ed:	e8 e3 09 00 00       	call   800fd5 <sys_cputs>
		b->idx = 0;
  8005f2:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8005f8:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8005fb:	ff 43 04             	incl   0x4(%ebx)
}
  8005fe:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800601:	c9                   	leave  
  800602:	c3                   	ret    

00800603 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800603:	55                   	push   %ebp
  800604:	89 e5                	mov    %esp,%ebp
  800606:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  80060c:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800613:	00 00 00 
	b.cnt = 0;
  800616:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80061d:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800620:	ff 75 0c             	pushl  0xc(%ebp)
  800623:	ff 75 08             	pushl  0x8(%ebp)
  800626:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80062c:	50                   	push   %eax
  80062d:	68 c4 05 80 00       	push   $0x8005c4
  800632:	e8 82 01 00 00       	call   8007b9 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800637:	83 c4 08             	add    $0x8,%esp
  80063a:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800640:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800646:	50                   	push   %eax
  800647:	e8 89 09 00 00       	call   800fd5 <sys_cputs>

	return b.cnt;
}
  80064c:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800652:	c9                   	leave  
  800653:	c3                   	ret    

00800654 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800654:	55                   	push   %ebp
  800655:	89 e5                	mov    %esp,%ebp
  800657:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80065a:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80065d:	50                   	push   %eax
  80065e:	ff 75 08             	pushl  0x8(%ebp)
  800661:	e8 9d ff ff ff       	call   800603 <vcprintf>
	va_end(ap);

	return cnt;
}
  800666:	c9                   	leave  
  800667:	c3                   	ret    

00800668 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800668:	55                   	push   %ebp
  800669:	89 e5                	mov    %esp,%ebp
  80066b:	57                   	push   %edi
  80066c:	56                   	push   %esi
  80066d:	53                   	push   %ebx
  80066e:	83 ec 2c             	sub    $0x2c,%esp
  800671:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800674:	89 d6                	mov    %edx,%esi
  800676:	8b 45 08             	mov    0x8(%ebp),%eax
  800679:	8b 55 0c             	mov    0xc(%ebp),%edx
  80067c:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80067f:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800682:	8b 45 10             	mov    0x10(%ebp),%eax
  800685:	8b 5d 14             	mov    0x14(%ebp),%ebx
  800688:	8b 7d 18             	mov    0x18(%ebp),%edi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80068b:	89 45 d0             	mov    %eax,-0x30(%ebp)
  80068e:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  800695:	39 55 d4             	cmp    %edx,-0x2c(%ebp)
  800698:	72 0c                	jb     8006a6 <printnum+0x3e>
  80069a:	3b 45 d8             	cmp    -0x28(%ebp),%eax
  80069d:	76 07                	jbe    8006a6 <printnum+0x3e>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80069f:	4b                   	dec    %ebx
  8006a0:	85 db                	test   %ebx,%ebx
  8006a2:	7f 31                	jg     8006d5 <printnum+0x6d>
  8006a4:	eb 3f                	jmp    8006e5 <printnum+0x7d>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8006a6:	83 ec 0c             	sub    $0xc,%esp
  8006a9:	57                   	push   %edi
  8006aa:	4b                   	dec    %ebx
  8006ab:	53                   	push   %ebx
  8006ac:	50                   	push   %eax
  8006ad:	83 ec 08             	sub    $0x8,%esp
  8006b0:	ff 75 d4             	pushl  -0x2c(%ebp)
  8006b3:	ff 75 d0             	pushl  -0x30(%ebp)
  8006b6:	ff 75 dc             	pushl  -0x24(%ebp)
  8006b9:	ff 75 d8             	pushl  -0x28(%ebp)
  8006bc:	e8 7f 0b 00 00       	call   801240 <__udivdi3>
  8006c1:	83 c4 18             	add    $0x18,%esp
  8006c4:	52                   	push   %edx
  8006c5:	50                   	push   %eax
  8006c6:	89 f2                	mov    %esi,%edx
  8006c8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8006cb:	e8 98 ff ff ff       	call   800668 <printnum>
  8006d0:	83 c4 20             	add    $0x20,%esp
  8006d3:	eb 10                	jmp    8006e5 <printnum+0x7d>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8006d5:	83 ec 08             	sub    $0x8,%esp
  8006d8:	56                   	push   %esi
  8006d9:	57                   	push   %edi
  8006da:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8006dd:	4b                   	dec    %ebx
  8006de:	83 c4 10             	add    $0x10,%esp
  8006e1:	85 db                	test   %ebx,%ebx
  8006e3:	7f f0                	jg     8006d5 <printnum+0x6d>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8006e5:	83 ec 08             	sub    $0x8,%esp
  8006e8:	56                   	push   %esi
  8006e9:	83 ec 04             	sub    $0x4,%esp
  8006ec:	ff 75 d4             	pushl  -0x2c(%ebp)
  8006ef:	ff 75 d0             	pushl  -0x30(%ebp)
  8006f2:	ff 75 dc             	pushl  -0x24(%ebp)
  8006f5:	ff 75 d8             	pushl  -0x28(%ebp)
  8006f8:	e8 5f 0c 00 00       	call   80135c <__umoddi3>
  8006fd:	83 c4 14             	add    $0x14,%esp
  800700:	0f be 80 e3 15 80 00 	movsbl 0x8015e3(%eax),%eax
  800707:	50                   	push   %eax
  800708:	ff 55 e4             	call   *-0x1c(%ebp)
  80070b:	83 c4 10             	add    $0x10,%esp
}
  80070e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800711:	5b                   	pop    %ebx
  800712:	5e                   	pop    %esi
  800713:	5f                   	pop    %edi
  800714:	c9                   	leave  
  800715:	c3                   	ret    

00800716 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800716:	55                   	push   %ebp
  800717:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800719:	83 fa 01             	cmp    $0x1,%edx
  80071c:	7e 0e                	jle    80072c <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80071e:	8b 10                	mov    (%eax),%edx
  800720:	8d 4a 08             	lea    0x8(%edx),%ecx
  800723:	89 08                	mov    %ecx,(%eax)
  800725:	8b 02                	mov    (%edx),%eax
  800727:	8b 52 04             	mov    0x4(%edx),%edx
  80072a:	eb 22                	jmp    80074e <getuint+0x38>
	else if (lflag)
  80072c:	85 d2                	test   %edx,%edx
  80072e:	74 10                	je     800740 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800730:	8b 10                	mov    (%eax),%edx
  800732:	8d 4a 04             	lea    0x4(%edx),%ecx
  800735:	89 08                	mov    %ecx,(%eax)
  800737:	8b 02                	mov    (%edx),%eax
  800739:	ba 00 00 00 00       	mov    $0x0,%edx
  80073e:	eb 0e                	jmp    80074e <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800740:	8b 10                	mov    (%eax),%edx
  800742:	8d 4a 04             	lea    0x4(%edx),%ecx
  800745:	89 08                	mov    %ecx,(%eax)
  800747:	8b 02                	mov    (%edx),%eax
  800749:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80074e:	c9                   	leave  
  80074f:	c3                   	ret    

00800750 <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
  800750:	55                   	push   %ebp
  800751:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800753:	83 fa 01             	cmp    $0x1,%edx
  800756:	7e 0e                	jle    800766 <getint+0x16>
		return va_arg(*ap, long long);
  800758:	8b 10                	mov    (%eax),%edx
  80075a:	8d 4a 08             	lea    0x8(%edx),%ecx
  80075d:	89 08                	mov    %ecx,(%eax)
  80075f:	8b 02                	mov    (%edx),%eax
  800761:	8b 52 04             	mov    0x4(%edx),%edx
  800764:	eb 1a                	jmp    800780 <getint+0x30>
	else if (lflag)
  800766:	85 d2                	test   %edx,%edx
  800768:	74 0c                	je     800776 <getint+0x26>
		return va_arg(*ap, long);
  80076a:	8b 10                	mov    (%eax),%edx
  80076c:	8d 4a 04             	lea    0x4(%edx),%ecx
  80076f:	89 08                	mov    %ecx,(%eax)
  800771:	8b 02                	mov    (%edx),%eax
  800773:	99                   	cltd   
  800774:	eb 0a                	jmp    800780 <getint+0x30>
	else
		return va_arg(*ap, int);
  800776:	8b 10                	mov    (%eax),%edx
  800778:	8d 4a 04             	lea    0x4(%edx),%ecx
  80077b:	89 08                	mov    %ecx,(%eax)
  80077d:	8b 02                	mov    (%edx),%eax
  80077f:	99                   	cltd   
}
  800780:	c9                   	leave  
  800781:	c3                   	ret    

00800782 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800782:	55                   	push   %ebp
  800783:	89 e5                	mov    %esp,%ebp
  800785:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800788:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  80078b:	8b 10                	mov    (%eax),%edx
  80078d:	3b 50 04             	cmp    0x4(%eax),%edx
  800790:	73 08                	jae    80079a <sprintputch+0x18>
		*b->buf++ = ch;
  800792:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800795:	88 0a                	mov    %cl,(%edx)
  800797:	42                   	inc    %edx
  800798:	89 10                	mov    %edx,(%eax)
}
  80079a:	c9                   	leave  
  80079b:	c3                   	ret    

0080079c <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80079c:	55                   	push   %ebp
  80079d:	89 e5                	mov    %esp,%ebp
  80079f:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8007a2:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8007a5:	50                   	push   %eax
  8007a6:	ff 75 10             	pushl  0x10(%ebp)
  8007a9:	ff 75 0c             	pushl  0xc(%ebp)
  8007ac:	ff 75 08             	pushl  0x8(%ebp)
  8007af:	e8 05 00 00 00       	call   8007b9 <vprintfmt>
	va_end(ap);
  8007b4:	83 c4 10             	add    $0x10,%esp
}
  8007b7:	c9                   	leave  
  8007b8:	c3                   	ret    

008007b9 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8007b9:	55                   	push   %ebp
  8007ba:	89 e5                	mov    %esp,%ebp
  8007bc:	57                   	push   %edi
  8007bd:	56                   	push   %esi
  8007be:	53                   	push   %ebx
  8007bf:	83 ec 2c             	sub    $0x2c,%esp
  8007c2:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8007c5:	8b 75 10             	mov    0x10(%ebp),%esi
  8007c8:	eb 13                	jmp    8007dd <vprintfmt+0x24>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8007ca:	85 c0                	test   %eax,%eax
  8007cc:	0f 84 6d 03 00 00    	je     800b3f <vprintfmt+0x386>
				return;
			putch(ch, putdat);
  8007d2:	83 ec 08             	sub    $0x8,%esp
  8007d5:	57                   	push   %edi
  8007d6:	50                   	push   %eax
  8007d7:	ff 55 08             	call   *0x8(%ebp)
  8007da:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8007dd:	0f b6 06             	movzbl (%esi),%eax
  8007e0:	46                   	inc    %esi
  8007e1:	83 f8 25             	cmp    $0x25,%eax
  8007e4:	75 e4                	jne    8007ca <vprintfmt+0x11>
  8007e6:	c6 45 dc 20          	movb   $0x20,-0x24(%ebp)
  8007ea:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  8007f1:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
  8007f8:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  8007ff:	b9 00 00 00 00       	mov    $0x0,%ecx
  800804:	eb 28                	jmp    80082e <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800806:	89 de                	mov    %ebx,%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  800808:	c6 45 dc 2d          	movb   $0x2d,-0x24(%ebp)
  80080c:	eb 20                	jmp    80082e <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80080e:	89 de                	mov    %ebx,%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800810:	c6 45 dc 30          	movb   $0x30,-0x24(%ebp)
  800814:	eb 18                	jmp    80082e <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800816:	89 de                	mov    %ebx,%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  800818:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  80081f:	eb 0d                	jmp    80082e <vprintfmt+0x75>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  800821:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  800824:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800827:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80082e:	8a 06                	mov    (%esi),%al
  800830:	0f b6 d0             	movzbl %al,%edx
  800833:	8d 5e 01             	lea    0x1(%esi),%ebx
  800836:	83 e8 23             	sub    $0x23,%eax
  800839:	3c 55                	cmp    $0x55,%al
  80083b:	0f 87 e0 02 00 00    	ja     800b21 <vprintfmt+0x368>
  800841:	0f b6 c0             	movzbl %al,%eax
  800844:	ff 24 85 a0 16 80 00 	jmp    *0x8016a0(,%eax,4)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80084b:	83 ea 30             	sub    $0x30,%edx
  80084e:	89 55 d4             	mov    %edx,-0x2c(%ebp)
				ch = *fmt;
  800851:	0f be 03             	movsbl (%ebx),%eax
				if (ch < '0' || ch > '9')
  800854:	8d 50 d0             	lea    -0x30(%eax),%edx
  800857:	83 fa 09             	cmp    $0x9,%edx
  80085a:	77 44                	ja     8008a0 <vprintfmt+0xe7>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80085c:	89 de                	mov    %ebx,%esi
  80085e:	8b 55 d4             	mov    -0x2c(%ebp),%edx
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800861:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
  800862:	8d 14 92             	lea    (%edx,%edx,4),%edx
  800865:	8d 54 50 d0          	lea    -0x30(%eax,%edx,2),%edx
				ch = *fmt;
  800869:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  80086c:	8d 58 d0             	lea    -0x30(%eax),%ebx
  80086f:	83 fb 09             	cmp    $0x9,%ebx
  800872:	76 ed                	jbe    800861 <vprintfmt+0xa8>
  800874:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  800877:	eb 29                	jmp    8008a2 <vprintfmt+0xe9>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800879:	8b 45 14             	mov    0x14(%ebp),%eax
  80087c:	8d 50 04             	lea    0x4(%eax),%edx
  80087f:	89 55 14             	mov    %edx,0x14(%ebp)
  800882:	8b 00                	mov    (%eax),%eax
  800884:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800887:	89 de                	mov    %ebx,%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800889:	eb 17                	jmp    8008a2 <vprintfmt+0xe9>

		case '.':
			if (width < 0)
  80088b:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80088f:	78 85                	js     800816 <vprintfmt+0x5d>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800891:	89 de                	mov    %ebx,%esi
  800893:	eb 99                	jmp    80082e <vprintfmt+0x75>
  800895:	89 de                	mov    %ebx,%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800897:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
			goto reswitch;
  80089e:	eb 8e                	jmp    80082e <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8008a0:	89 de                	mov    %ebx,%esi
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  8008a2:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8008a6:	79 86                	jns    80082e <vprintfmt+0x75>
  8008a8:	e9 74 ff ff ff       	jmp    800821 <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8008ad:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8008ae:	89 de                	mov    %ebx,%esi
  8008b0:	e9 79 ff ff ff       	jmp    80082e <vprintfmt+0x75>
  8008b5:	89 5d d8             	mov    %ebx,-0x28(%ebp)
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8008b8:	8b 45 14             	mov    0x14(%ebp),%eax
  8008bb:	8d 50 04             	lea    0x4(%eax),%edx
  8008be:	89 55 14             	mov    %edx,0x14(%ebp)
  8008c1:	83 ec 08             	sub    $0x8,%esp
  8008c4:	57                   	push   %edi
  8008c5:	ff 30                	pushl  (%eax)
  8008c7:	ff 55 08             	call   *0x8(%ebp)
			break;
  8008ca:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8008cd:	8b 75 d8             	mov    -0x28(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8008d0:	e9 08 ff ff ff       	jmp    8007dd <vprintfmt+0x24>
  8008d5:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// error message
		case 'e':
			err = va_arg(ap, int);
  8008d8:	8b 45 14             	mov    0x14(%ebp),%eax
  8008db:	8d 50 04             	lea    0x4(%eax),%edx
  8008de:	89 55 14             	mov    %edx,0x14(%ebp)
  8008e1:	8b 00                	mov    (%eax),%eax
  8008e3:	85 c0                	test   %eax,%eax
  8008e5:	79 02                	jns    8008e9 <vprintfmt+0x130>
  8008e7:	f7 d8                	neg    %eax
  8008e9:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8008eb:	83 f8 08             	cmp    $0x8,%eax
  8008ee:	7f 0b                	jg     8008fb <vprintfmt+0x142>
  8008f0:	8b 04 85 00 18 80 00 	mov    0x801800(,%eax,4),%eax
  8008f7:	85 c0                	test   %eax,%eax
  8008f9:	75 1a                	jne    800915 <vprintfmt+0x15c>
				printfmt(putch, putdat, "error %d", err);
  8008fb:	52                   	push   %edx
  8008fc:	68 fb 15 80 00       	push   $0x8015fb
  800901:	57                   	push   %edi
  800902:	ff 75 08             	pushl  0x8(%ebp)
  800905:	e8 92 fe ff ff       	call   80079c <printfmt>
  80090a:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80090d:	8b 75 d8             	mov    -0x28(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800910:	e9 c8 fe ff ff       	jmp    8007dd <vprintfmt+0x24>
			else
				printfmt(putch, putdat, "%s", p);
  800915:	50                   	push   %eax
  800916:	68 04 16 80 00       	push   $0x801604
  80091b:	57                   	push   %edi
  80091c:	ff 75 08             	pushl  0x8(%ebp)
  80091f:	e8 78 fe ff ff       	call   80079c <printfmt>
  800924:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800927:	8b 75 d8             	mov    -0x28(%ebp),%esi
  80092a:	e9 ae fe ff ff       	jmp    8007dd <vprintfmt+0x24>
  80092f:	89 5d d8             	mov    %ebx,-0x28(%ebp)
  800932:	89 de                	mov    %ebx,%esi
  800934:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  800937:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80093a:	8b 45 14             	mov    0x14(%ebp),%eax
  80093d:	8d 50 04             	lea    0x4(%eax),%edx
  800940:	89 55 14             	mov    %edx,0x14(%ebp)
  800943:	8b 00                	mov    (%eax),%eax
  800945:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800948:	85 c0                	test   %eax,%eax
  80094a:	75 07                	jne    800953 <vprintfmt+0x19a>
				p = "(null)";
  80094c:	c7 45 d0 f4 15 80 00 	movl   $0x8015f4,-0x30(%ebp)
			if (width > 0 && padc != '-')
  800953:	85 db                	test   %ebx,%ebx
  800955:	7e 42                	jle    800999 <vprintfmt+0x1e0>
  800957:	80 7d dc 2d          	cmpb   $0x2d,-0x24(%ebp)
  80095b:	74 3c                	je     800999 <vprintfmt+0x1e0>
				for (width -= strnlen(p, precision); width > 0; width--)
  80095d:	83 ec 08             	sub    $0x8,%esp
  800960:	51                   	push   %ecx
  800961:	ff 75 d0             	pushl  -0x30(%ebp)
  800964:	e8 6f 02 00 00       	call   800bd8 <strnlen>
  800969:	29 c3                	sub    %eax,%ebx
  80096b:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  80096e:	83 c4 10             	add    $0x10,%esp
  800971:	85 db                	test   %ebx,%ebx
  800973:	7e 24                	jle    800999 <vprintfmt+0x1e0>
					putch(padc, putdat);
  800975:	0f be 5d dc          	movsbl -0x24(%ebp),%ebx
  800979:	89 75 dc             	mov    %esi,-0x24(%ebp)
  80097c:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  80097f:	83 ec 08             	sub    $0x8,%esp
  800982:	57                   	push   %edi
  800983:	53                   	push   %ebx
  800984:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800987:	4e                   	dec    %esi
  800988:	83 c4 10             	add    $0x10,%esp
  80098b:	85 f6                	test   %esi,%esi
  80098d:	7f f0                	jg     80097f <vprintfmt+0x1c6>
  80098f:	8b 75 dc             	mov    -0x24(%ebp),%esi
  800992:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800999:	8b 55 d0             	mov    -0x30(%ebp),%edx
  80099c:	0f be 02             	movsbl (%edx),%eax
  80099f:	85 c0                	test   %eax,%eax
  8009a1:	75 47                	jne    8009ea <vprintfmt+0x231>
  8009a3:	eb 37                	jmp    8009dc <vprintfmt+0x223>
				if (altflag && (ch < ' ' || ch > '~'))
  8009a5:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8009a9:	74 16                	je     8009c1 <vprintfmt+0x208>
  8009ab:	8d 50 e0             	lea    -0x20(%eax),%edx
  8009ae:	83 fa 5e             	cmp    $0x5e,%edx
  8009b1:	76 0e                	jbe    8009c1 <vprintfmt+0x208>
					putch('?', putdat);
  8009b3:	83 ec 08             	sub    $0x8,%esp
  8009b6:	57                   	push   %edi
  8009b7:	6a 3f                	push   $0x3f
  8009b9:	ff 55 08             	call   *0x8(%ebp)
  8009bc:	83 c4 10             	add    $0x10,%esp
  8009bf:	eb 0b                	jmp    8009cc <vprintfmt+0x213>
				else
					putch(ch, putdat);
  8009c1:	83 ec 08             	sub    $0x8,%esp
  8009c4:	57                   	push   %edi
  8009c5:	50                   	push   %eax
  8009c6:	ff 55 08             	call   *0x8(%ebp)
  8009c9:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8009cc:	ff 4d e4             	decl   -0x1c(%ebp)
  8009cf:	0f be 03             	movsbl (%ebx),%eax
  8009d2:	85 c0                	test   %eax,%eax
  8009d4:	74 03                	je     8009d9 <vprintfmt+0x220>
  8009d6:	43                   	inc    %ebx
  8009d7:	eb 1b                	jmp    8009f4 <vprintfmt+0x23b>
  8009d9:	8b 75 dc             	mov    -0x24(%ebp),%esi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8009dc:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8009e0:	7f 1e                	jg     800a00 <vprintfmt+0x247>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8009e2:	8b 75 d8             	mov    -0x28(%ebp),%esi
  8009e5:	e9 f3 fd ff ff       	jmp    8007dd <vprintfmt+0x24>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8009ea:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  8009ed:	43                   	inc    %ebx
  8009ee:	89 75 dc             	mov    %esi,-0x24(%ebp)
  8009f1:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  8009f4:	85 f6                	test   %esi,%esi
  8009f6:	78 ad                	js     8009a5 <vprintfmt+0x1ec>
  8009f8:	4e                   	dec    %esi
  8009f9:	79 aa                	jns    8009a5 <vprintfmt+0x1ec>
  8009fb:	8b 75 dc             	mov    -0x24(%ebp),%esi
  8009fe:	eb dc                	jmp    8009dc <vprintfmt+0x223>
  800a00:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800a03:	83 ec 08             	sub    $0x8,%esp
  800a06:	57                   	push   %edi
  800a07:	6a 20                	push   $0x20
  800a09:	ff 55 08             	call   *0x8(%ebp)
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800a0c:	4b                   	dec    %ebx
  800a0d:	83 c4 10             	add    $0x10,%esp
  800a10:	85 db                	test   %ebx,%ebx
  800a12:	7f ef                	jg     800a03 <vprintfmt+0x24a>
  800a14:	e9 c4 fd ff ff       	jmp    8007dd <vprintfmt+0x24>
  800a19:	89 5d d8             	mov    %ebx,-0x28(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800a1c:	89 ca                	mov    %ecx,%edx
  800a1e:	8d 45 14             	lea    0x14(%ebp),%eax
  800a21:	e8 2a fd ff ff       	call   800750 <getint>
  800a26:	89 c3                	mov    %eax,%ebx
  800a28:	89 d6                	mov    %edx,%esi
			if ((long long) num < 0) {
  800a2a:	85 d2                	test   %edx,%edx
  800a2c:	78 0a                	js     800a38 <vprintfmt+0x27f>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800a2e:	b8 0a 00 00 00       	mov    $0xa,%eax
  800a33:	e9 b0 00 00 00       	jmp    800ae8 <vprintfmt+0x32f>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  800a38:	83 ec 08             	sub    $0x8,%esp
  800a3b:	57                   	push   %edi
  800a3c:	6a 2d                	push   $0x2d
  800a3e:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  800a41:	f7 db                	neg    %ebx
  800a43:	83 d6 00             	adc    $0x0,%esi
  800a46:	f7 de                	neg    %esi
  800a48:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800a4b:	b8 0a 00 00 00       	mov    $0xa,%eax
  800a50:	e9 93 00 00 00       	jmp    800ae8 <vprintfmt+0x32f>
  800a55:	89 5d d8             	mov    %ebx,-0x28(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800a58:	89 ca                	mov    %ecx,%edx
  800a5a:	8d 45 14             	lea    0x14(%ebp),%eax
  800a5d:	e8 b4 fc ff ff       	call   800716 <getuint>
  800a62:	89 c3                	mov    %eax,%ebx
  800a64:	89 d6                	mov    %edx,%esi
			base = 10;
  800a66:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  800a6b:	eb 7b                	jmp    800ae8 <vprintfmt+0x32f>
  800a6d:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// (unsigned) octal
		case 'o':
            // (MIT 6.828, lab1, Ex.8)  my code : 
            num = getint(&ap, lflag);
  800a70:	89 ca                	mov    %ecx,%edx
  800a72:	8d 45 14             	lea    0x14(%ebp),%eax
  800a75:	e8 d6 fc ff ff       	call   800750 <getint>
  800a7a:	89 c3                	mov    %eax,%ebx
  800a7c:	89 d6                	mov    %edx,%esi
            if ((long long) num < 0) {
  800a7e:	85 d2                	test   %edx,%edx
  800a80:	78 07                	js     800a89 <vprintfmt+0x2d0>
                putch('-', putdat);
                num = -(long long) num;
            }
            base = 8;
  800a82:	b8 08 00 00 00       	mov    $0x8,%eax
  800a87:	eb 5f                	jmp    800ae8 <vprintfmt+0x32f>
		// (unsigned) octal
		case 'o':
            // (MIT 6.828, lab1, Ex.8)  my code : 
            num = getint(&ap, lflag);
            if ((long long) num < 0) {
                putch('-', putdat);
  800a89:	83 ec 08             	sub    $0x8,%esp
  800a8c:	57                   	push   %edi
  800a8d:	6a 2d                	push   $0x2d
  800a8f:	ff 55 08             	call   *0x8(%ebp)
                num = -(long long) num;
  800a92:	f7 db                	neg    %ebx
  800a94:	83 d6 00             	adc    $0x0,%esi
  800a97:	f7 de                	neg    %esi
  800a99:	83 c4 10             	add    $0x10,%esp
            }
            base = 8;
  800a9c:	b8 08 00 00 00       	mov    $0x8,%eax
  800aa1:	eb 45                	jmp    800ae8 <vprintfmt+0x32f>
  800aa3:	89 5d d8             	mov    %ebx,-0x28(%ebp)
            goto number;

        // pointer
		case 'p':
			putch('0', putdat);
  800aa6:	83 ec 08             	sub    $0x8,%esp
  800aa9:	57                   	push   %edi
  800aaa:	6a 30                	push   $0x30
  800aac:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  800aaf:	83 c4 08             	add    $0x8,%esp
  800ab2:	57                   	push   %edi
  800ab3:	6a 78                	push   $0x78
  800ab5:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800ab8:	8b 45 14             	mov    0x14(%ebp),%eax
  800abb:	8d 50 04             	lea    0x4(%eax),%edx
  800abe:	89 55 14             	mov    %edx,0x14(%ebp)

        // pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800ac1:	8b 18                	mov    (%eax),%ebx
  800ac3:	be 00 00 00 00       	mov    $0x0,%esi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800ac8:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800acb:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  800ad0:	eb 16                	jmp    800ae8 <vprintfmt+0x32f>
  800ad2:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800ad5:	89 ca                	mov    %ecx,%edx
  800ad7:	8d 45 14             	lea    0x14(%ebp),%eax
  800ada:	e8 37 fc ff ff       	call   800716 <getuint>
  800adf:	89 c3                	mov    %eax,%ebx
  800ae1:	89 d6                	mov    %edx,%esi
			base = 16;
  800ae3:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  800ae8:	83 ec 0c             	sub    $0xc,%esp
  800aeb:	0f be 55 dc          	movsbl -0x24(%ebp),%edx
  800aef:	52                   	push   %edx
  800af0:	ff 75 e4             	pushl  -0x1c(%ebp)
  800af3:	50                   	push   %eax
  800af4:	56                   	push   %esi
  800af5:	53                   	push   %ebx
  800af6:	89 fa                	mov    %edi,%edx
  800af8:	8b 45 08             	mov    0x8(%ebp),%eax
  800afb:	e8 68 fb ff ff       	call   800668 <printnum>
			break;
  800b00:	83 c4 20             	add    $0x20,%esp
  800b03:	8b 75 d8             	mov    -0x28(%ebp),%esi
  800b06:	e9 d2 fc ff ff       	jmp    8007dd <vprintfmt+0x24>
  800b0b:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800b0e:	83 ec 08             	sub    $0x8,%esp
  800b11:	57                   	push   %edi
  800b12:	52                   	push   %edx
  800b13:	ff 55 08             	call   *0x8(%ebp)
			break;
  800b16:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800b19:	8b 75 d8             	mov    -0x28(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800b1c:	e9 bc fc ff ff       	jmp    8007dd <vprintfmt+0x24>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800b21:	83 ec 08             	sub    $0x8,%esp
  800b24:	57                   	push   %edi
  800b25:	6a 25                	push   $0x25
  800b27:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800b2a:	83 c4 10             	add    $0x10,%esp
  800b2d:	eb 02                	jmp    800b31 <vprintfmt+0x378>
  800b2f:	89 c6                	mov    %eax,%esi
  800b31:	8d 46 ff             	lea    -0x1(%esi),%eax
  800b34:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  800b38:	75 f5                	jne    800b2f <vprintfmt+0x376>
  800b3a:	e9 9e fc ff ff       	jmp    8007dd <vprintfmt+0x24>
				/* do nothing */;
			break;
		}
	}
}
  800b3f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b42:	5b                   	pop    %ebx
  800b43:	5e                   	pop    %esi
  800b44:	5f                   	pop    %edi
  800b45:	c9                   	leave  
  800b46:	c3                   	ret    

00800b47 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800b47:	55                   	push   %ebp
  800b48:	89 e5                	mov    %esp,%ebp
  800b4a:	83 ec 18             	sub    $0x18,%esp
  800b4d:	8b 45 08             	mov    0x8(%ebp),%eax
  800b50:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800b53:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800b56:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800b5a:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800b5d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800b64:	85 c0                	test   %eax,%eax
  800b66:	74 26                	je     800b8e <vsnprintf+0x47>
  800b68:	85 d2                	test   %edx,%edx
  800b6a:	7e 29                	jle    800b95 <vsnprintf+0x4e>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800b6c:	ff 75 14             	pushl  0x14(%ebp)
  800b6f:	ff 75 10             	pushl  0x10(%ebp)
  800b72:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800b75:	50                   	push   %eax
  800b76:	68 82 07 80 00       	push   $0x800782
  800b7b:	e8 39 fc ff ff       	call   8007b9 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800b80:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800b83:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800b86:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800b89:	83 c4 10             	add    $0x10,%esp
  800b8c:	eb 0c                	jmp    800b9a <vsnprintf+0x53>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800b8e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800b93:	eb 05                	jmp    800b9a <vsnprintf+0x53>
  800b95:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800b9a:	c9                   	leave  
  800b9b:	c3                   	ret    

00800b9c <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800b9c:	55                   	push   %ebp
  800b9d:	89 e5                	mov    %esp,%ebp
  800b9f:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800ba2:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800ba5:	50                   	push   %eax
  800ba6:	ff 75 10             	pushl  0x10(%ebp)
  800ba9:	ff 75 0c             	pushl  0xc(%ebp)
  800bac:	ff 75 08             	pushl  0x8(%ebp)
  800baf:	e8 93 ff ff ff       	call   800b47 <vsnprintf>
	va_end(ap);

	return rc;
}
  800bb4:	c9                   	leave  
  800bb5:	c3                   	ret    
	...

00800bb8 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800bb8:	55                   	push   %ebp
  800bb9:	89 e5                	mov    %esp,%ebp
  800bbb:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800bbe:	80 3a 00             	cmpb   $0x0,(%edx)
  800bc1:	74 0e                	je     800bd1 <strlen+0x19>
  800bc3:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  800bc8:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800bc9:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800bcd:	75 f9                	jne    800bc8 <strlen+0x10>
  800bcf:	eb 05                	jmp    800bd6 <strlen+0x1e>
  800bd1:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  800bd6:	c9                   	leave  
  800bd7:	c3                   	ret    

00800bd8 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800bd8:	55                   	push   %ebp
  800bd9:	89 e5                	mov    %esp,%ebp
  800bdb:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800bde:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800be1:	85 d2                	test   %edx,%edx
  800be3:	74 17                	je     800bfc <strnlen+0x24>
  800be5:	80 39 00             	cmpb   $0x0,(%ecx)
  800be8:	74 19                	je     800c03 <strnlen+0x2b>
  800bea:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  800bef:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800bf0:	39 d0                	cmp    %edx,%eax
  800bf2:	74 14                	je     800c08 <strnlen+0x30>
  800bf4:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800bf8:	75 f5                	jne    800bef <strnlen+0x17>
  800bfa:	eb 0c                	jmp    800c08 <strnlen+0x30>
  800bfc:	b8 00 00 00 00       	mov    $0x0,%eax
  800c01:	eb 05                	jmp    800c08 <strnlen+0x30>
  800c03:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  800c08:	c9                   	leave  
  800c09:	c3                   	ret    

00800c0a <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800c0a:	55                   	push   %ebp
  800c0b:	89 e5                	mov    %esp,%ebp
  800c0d:	53                   	push   %ebx
  800c0e:	8b 45 08             	mov    0x8(%ebp),%eax
  800c11:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800c14:	ba 00 00 00 00       	mov    $0x0,%edx
  800c19:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  800c1c:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800c1f:	42                   	inc    %edx
  800c20:	84 c9                	test   %cl,%cl
  800c22:	75 f5                	jne    800c19 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800c24:	5b                   	pop    %ebx
  800c25:	c9                   	leave  
  800c26:	c3                   	ret    

00800c27 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800c27:	55                   	push   %ebp
  800c28:	89 e5                	mov    %esp,%ebp
  800c2a:	53                   	push   %ebx
  800c2b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800c2e:	53                   	push   %ebx
  800c2f:	e8 84 ff ff ff       	call   800bb8 <strlen>
  800c34:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800c37:	ff 75 0c             	pushl  0xc(%ebp)
  800c3a:	8d 04 03             	lea    (%ebx,%eax,1),%eax
  800c3d:	50                   	push   %eax
  800c3e:	e8 c7 ff ff ff       	call   800c0a <strcpy>
	return dst;
}
  800c43:	89 d8                	mov    %ebx,%eax
  800c45:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800c48:	c9                   	leave  
  800c49:	c3                   	ret    

00800c4a <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800c4a:	55                   	push   %ebp
  800c4b:	89 e5                	mov    %esp,%ebp
  800c4d:	56                   	push   %esi
  800c4e:	53                   	push   %ebx
  800c4f:	8b 45 08             	mov    0x8(%ebp),%eax
  800c52:	8b 55 0c             	mov    0xc(%ebp),%edx
  800c55:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800c58:	85 f6                	test   %esi,%esi
  800c5a:	74 15                	je     800c71 <strncpy+0x27>
  800c5c:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
  800c61:	8a 1a                	mov    (%edx),%bl
  800c63:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800c66:	80 3a 01             	cmpb   $0x1,(%edx)
  800c69:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800c6c:	41                   	inc    %ecx
  800c6d:	39 ce                	cmp    %ecx,%esi
  800c6f:	77 f0                	ja     800c61 <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800c71:	5b                   	pop    %ebx
  800c72:	5e                   	pop    %esi
  800c73:	c9                   	leave  
  800c74:	c3                   	ret    

00800c75 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800c75:	55                   	push   %ebp
  800c76:	89 e5                	mov    %esp,%ebp
  800c78:	57                   	push   %edi
  800c79:	56                   	push   %esi
  800c7a:	53                   	push   %ebx
  800c7b:	8b 7d 08             	mov    0x8(%ebp),%edi
  800c7e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800c81:	8b 75 10             	mov    0x10(%ebp),%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800c84:	85 f6                	test   %esi,%esi
  800c86:	74 32                	je     800cba <strlcpy+0x45>
		while (--size > 0 && *src != '\0')
  800c88:	83 fe 01             	cmp    $0x1,%esi
  800c8b:	74 22                	je     800caf <strlcpy+0x3a>
  800c8d:	8a 0b                	mov    (%ebx),%cl
  800c8f:	84 c9                	test   %cl,%cl
  800c91:	74 20                	je     800cb3 <strlcpy+0x3e>
  800c93:	89 f8                	mov    %edi,%eax
  800c95:	ba 00 00 00 00       	mov    $0x0,%edx
	}
	return ret;
}

size_t
strlcpy(char *dst, const char *src, size_t size)
  800c9a:	83 ee 02             	sub    $0x2,%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800c9d:	88 08                	mov    %cl,(%eax)
  800c9f:	40                   	inc    %eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800ca0:	39 f2                	cmp    %esi,%edx
  800ca2:	74 11                	je     800cb5 <strlcpy+0x40>
  800ca4:	8a 4c 13 01          	mov    0x1(%ebx,%edx,1),%cl
  800ca8:	42                   	inc    %edx
  800ca9:	84 c9                	test   %cl,%cl
  800cab:	75 f0                	jne    800c9d <strlcpy+0x28>
  800cad:	eb 06                	jmp    800cb5 <strlcpy+0x40>
  800caf:	89 f8                	mov    %edi,%eax
  800cb1:	eb 02                	jmp    800cb5 <strlcpy+0x40>
  800cb3:	89 f8                	mov    %edi,%eax
			*dst++ = *src++;
		*dst = '\0';
  800cb5:	c6 00 00             	movb   $0x0,(%eax)
  800cb8:	eb 02                	jmp    800cbc <strlcpy+0x47>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800cba:	89 f8                	mov    %edi,%eax
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
		*dst = '\0';
	}
	return dst - dst_in;
  800cbc:	29 f8                	sub    %edi,%eax
}
  800cbe:	5b                   	pop    %ebx
  800cbf:	5e                   	pop    %esi
  800cc0:	5f                   	pop    %edi
  800cc1:	c9                   	leave  
  800cc2:	c3                   	ret    

00800cc3 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800cc3:	55                   	push   %ebp
  800cc4:	89 e5                	mov    %esp,%ebp
  800cc6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800cc9:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800ccc:	8a 01                	mov    (%ecx),%al
  800cce:	84 c0                	test   %al,%al
  800cd0:	74 10                	je     800ce2 <strcmp+0x1f>
  800cd2:	3a 02                	cmp    (%edx),%al
  800cd4:	75 0c                	jne    800ce2 <strcmp+0x1f>
		p++, q++;
  800cd6:	41                   	inc    %ecx
  800cd7:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800cd8:	8a 01                	mov    (%ecx),%al
  800cda:	84 c0                	test   %al,%al
  800cdc:	74 04                	je     800ce2 <strcmp+0x1f>
  800cde:	3a 02                	cmp    (%edx),%al
  800ce0:	74 f4                	je     800cd6 <strcmp+0x13>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800ce2:	0f b6 c0             	movzbl %al,%eax
  800ce5:	0f b6 12             	movzbl (%edx),%edx
  800ce8:	29 d0                	sub    %edx,%eax
}
  800cea:	c9                   	leave  
  800ceb:	c3                   	ret    

00800cec <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800cec:	55                   	push   %ebp
  800ced:	89 e5                	mov    %esp,%ebp
  800cef:	53                   	push   %ebx
  800cf0:	8b 55 08             	mov    0x8(%ebp),%edx
  800cf3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cf6:	8b 45 10             	mov    0x10(%ebp),%eax
	while (n > 0 && *p && *p == *q)
  800cf9:	85 c0                	test   %eax,%eax
  800cfb:	74 1b                	je     800d18 <strncmp+0x2c>
  800cfd:	8a 1a                	mov    (%edx),%bl
  800cff:	84 db                	test   %bl,%bl
  800d01:	74 24                	je     800d27 <strncmp+0x3b>
  800d03:	3a 19                	cmp    (%ecx),%bl
  800d05:	75 20                	jne    800d27 <strncmp+0x3b>
  800d07:	48                   	dec    %eax
  800d08:	74 15                	je     800d1f <strncmp+0x33>
		n--, p++, q++;
  800d0a:	42                   	inc    %edx
  800d0b:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800d0c:	8a 1a                	mov    (%edx),%bl
  800d0e:	84 db                	test   %bl,%bl
  800d10:	74 15                	je     800d27 <strncmp+0x3b>
  800d12:	3a 19                	cmp    (%ecx),%bl
  800d14:	74 f1                	je     800d07 <strncmp+0x1b>
  800d16:	eb 0f                	jmp    800d27 <strncmp+0x3b>
		n--, p++, q++;
	if (n == 0)
		return 0;
  800d18:	b8 00 00 00 00       	mov    $0x0,%eax
  800d1d:	eb 05                	jmp    800d24 <strncmp+0x38>
  800d1f:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800d24:	5b                   	pop    %ebx
  800d25:	c9                   	leave  
  800d26:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800d27:	0f b6 02             	movzbl (%edx),%eax
  800d2a:	0f b6 11             	movzbl (%ecx),%edx
  800d2d:	29 d0                	sub    %edx,%eax
  800d2f:	eb f3                	jmp    800d24 <strncmp+0x38>

00800d31 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800d31:	55                   	push   %ebp
  800d32:	89 e5                	mov    %esp,%ebp
  800d34:	8b 45 08             	mov    0x8(%ebp),%eax
  800d37:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800d3a:	8a 10                	mov    (%eax),%dl
  800d3c:	84 d2                	test   %dl,%dl
  800d3e:	74 18                	je     800d58 <strchr+0x27>
		if (*s == c)
  800d40:	38 ca                	cmp    %cl,%dl
  800d42:	75 06                	jne    800d4a <strchr+0x19>
  800d44:	eb 17                	jmp    800d5d <strchr+0x2c>
  800d46:	38 ca                	cmp    %cl,%dl
  800d48:	74 13                	je     800d5d <strchr+0x2c>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800d4a:	40                   	inc    %eax
  800d4b:	8a 10                	mov    (%eax),%dl
  800d4d:	84 d2                	test   %dl,%dl
  800d4f:	75 f5                	jne    800d46 <strchr+0x15>
		if (*s == c)
			return (char *) s;
	return 0;
  800d51:	b8 00 00 00 00       	mov    $0x0,%eax
  800d56:	eb 05                	jmp    800d5d <strchr+0x2c>
  800d58:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800d5d:	c9                   	leave  
  800d5e:	c3                   	ret    

00800d5f <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800d5f:	55                   	push   %ebp
  800d60:	89 e5                	mov    %esp,%ebp
  800d62:	8b 45 08             	mov    0x8(%ebp),%eax
  800d65:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800d68:	8a 10                	mov    (%eax),%dl
  800d6a:	84 d2                	test   %dl,%dl
  800d6c:	74 11                	je     800d7f <strfind+0x20>
		if (*s == c)
  800d6e:	38 ca                	cmp    %cl,%dl
  800d70:	75 06                	jne    800d78 <strfind+0x19>
  800d72:	eb 0b                	jmp    800d7f <strfind+0x20>
  800d74:	38 ca                	cmp    %cl,%dl
  800d76:	74 07                	je     800d7f <strfind+0x20>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800d78:	40                   	inc    %eax
  800d79:	8a 10                	mov    (%eax),%dl
  800d7b:	84 d2                	test   %dl,%dl
  800d7d:	75 f5                	jne    800d74 <strfind+0x15>
		if (*s == c)
			break;
	return (char *) s;
}
  800d7f:	c9                   	leave  
  800d80:	c3                   	ret    

00800d81 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800d81:	55                   	push   %ebp
  800d82:	89 e5                	mov    %esp,%ebp
  800d84:	57                   	push   %edi
  800d85:	56                   	push   %esi
  800d86:	53                   	push   %ebx
  800d87:	8b 7d 08             	mov    0x8(%ebp),%edi
  800d8a:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d8d:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800d90:	85 c9                	test   %ecx,%ecx
  800d92:	74 30                	je     800dc4 <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800d94:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800d9a:	75 25                	jne    800dc1 <memset+0x40>
  800d9c:	f6 c1 03             	test   $0x3,%cl
  800d9f:	75 20                	jne    800dc1 <memset+0x40>
		c &= 0xFF;
  800da1:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800da4:	89 d3                	mov    %edx,%ebx
  800da6:	c1 e3 08             	shl    $0x8,%ebx
  800da9:	89 d6                	mov    %edx,%esi
  800dab:	c1 e6 18             	shl    $0x18,%esi
  800dae:	89 d0                	mov    %edx,%eax
  800db0:	c1 e0 10             	shl    $0x10,%eax
  800db3:	09 f0                	or     %esi,%eax
  800db5:	09 d0                	or     %edx,%eax
  800db7:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800db9:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800dbc:	fc                   	cld    
  800dbd:	f3 ab                	rep stos %eax,%es:(%edi)
  800dbf:	eb 03                	jmp    800dc4 <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800dc1:	fc                   	cld    
  800dc2:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800dc4:	89 f8                	mov    %edi,%eax
  800dc6:	5b                   	pop    %ebx
  800dc7:	5e                   	pop    %esi
  800dc8:	5f                   	pop    %edi
  800dc9:	c9                   	leave  
  800dca:	c3                   	ret    

00800dcb <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800dcb:	55                   	push   %ebp
  800dcc:	89 e5                	mov    %esp,%ebp
  800dce:	57                   	push   %edi
  800dcf:	56                   	push   %esi
  800dd0:	8b 45 08             	mov    0x8(%ebp),%eax
  800dd3:	8b 75 0c             	mov    0xc(%ebp),%esi
  800dd6:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800dd9:	39 c6                	cmp    %eax,%esi
  800ddb:	73 34                	jae    800e11 <memmove+0x46>
  800ddd:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800de0:	39 d0                	cmp    %edx,%eax
  800de2:	73 2d                	jae    800e11 <memmove+0x46>
		s += n;
		d += n;
  800de4:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800de7:	f6 c2 03             	test   $0x3,%dl
  800dea:	75 1b                	jne    800e07 <memmove+0x3c>
  800dec:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800df2:	75 13                	jne    800e07 <memmove+0x3c>
  800df4:	f6 c1 03             	test   $0x3,%cl
  800df7:	75 0e                	jne    800e07 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800df9:	83 ef 04             	sub    $0x4,%edi
  800dfc:	8d 72 fc             	lea    -0x4(%edx),%esi
  800dff:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800e02:	fd                   	std    
  800e03:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800e05:	eb 07                	jmp    800e0e <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800e07:	4f                   	dec    %edi
  800e08:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800e0b:	fd                   	std    
  800e0c:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800e0e:	fc                   	cld    
  800e0f:	eb 20                	jmp    800e31 <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800e11:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800e17:	75 13                	jne    800e2c <memmove+0x61>
  800e19:	a8 03                	test   $0x3,%al
  800e1b:	75 0f                	jne    800e2c <memmove+0x61>
  800e1d:	f6 c1 03             	test   $0x3,%cl
  800e20:	75 0a                	jne    800e2c <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800e22:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800e25:	89 c7                	mov    %eax,%edi
  800e27:	fc                   	cld    
  800e28:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800e2a:	eb 05                	jmp    800e31 <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800e2c:	89 c7                	mov    %eax,%edi
  800e2e:	fc                   	cld    
  800e2f:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800e31:	5e                   	pop    %esi
  800e32:	5f                   	pop    %edi
  800e33:	c9                   	leave  
  800e34:	c3                   	ret    

00800e35 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800e35:	55                   	push   %ebp
  800e36:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800e38:	ff 75 10             	pushl  0x10(%ebp)
  800e3b:	ff 75 0c             	pushl  0xc(%ebp)
  800e3e:	ff 75 08             	pushl  0x8(%ebp)
  800e41:	e8 85 ff ff ff       	call   800dcb <memmove>
}
  800e46:	c9                   	leave  
  800e47:	c3                   	ret    

00800e48 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800e48:	55                   	push   %ebp
  800e49:	89 e5                	mov    %esp,%ebp
  800e4b:	57                   	push   %edi
  800e4c:	56                   	push   %esi
  800e4d:	53                   	push   %ebx
  800e4e:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800e51:	8b 75 0c             	mov    0xc(%ebp),%esi
  800e54:	8b 7d 10             	mov    0x10(%ebp),%edi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800e57:	85 ff                	test   %edi,%edi
  800e59:	74 32                	je     800e8d <memcmp+0x45>
		if (*s1 != *s2)
  800e5b:	8a 03                	mov    (%ebx),%al
  800e5d:	8a 0e                	mov    (%esi),%cl
  800e5f:	38 c8                	cmp    %cl,%al
  800e61:	74 19                	je     800e7c <memcmp+0x34>
  800e63:	eb 0d                	jmp    800e72 <memcmp+0x2a>
  800e65:	8a 44 13 01          	mov    0x1(%ebx,%edx,1),%al
  800e69:	8a 4c 16 01          	mov    0x1(%esi,%edx,1),%cl
  800e6d:	42                   	inc    %edx
  800e6e:	38 c8                	cmp    %cl,%al
  800e70:	74 10                	je     800e82 <memcmp+0x3a>
			return (int) *s1 - (int) *s2;
  800e72:	0f b6 c0             	movzbl %al,%eax
  800e75:	0f b6 c9             	movzbl %cl,%ecx
  800e78:	29 c8                	sub    %ecx,%eax
  800e7a:	eb 16                	jmp    800e92 <memcmp+0x4a>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800e7c:	4f                   	dec    %edi
  800e7d:	ba 00 00 00 00       	mov    $0x0,%edx
  800e82:	39 fa                	cmp    %edi,%edx
  800e84:	75 df                	jne    800e65 <memcmp+0x1d>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800e86:	b8 00 00 00 00       	mov    $0x0,%eax
  800e8b:	eb 05                	jmp    800e92 <memcmp+0x4a>
  800e8d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800e92:	5b                   	pop    %ebx
  800e93:	5e                   	pop    %esi
  800e94:	5f                   	pop    %edi
  800e95:	c9                   	leave  
  800e96:	c3                   	ret    

00800e97 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800e97:	55                   	push   %ebp
  800e98:	89 e5                	mov    %esp,%ebp
  800e9a:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800e9d:	89 c2                	mov    %eax,%edx
  800e9f:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800ea2:	39 d0                	cmp    %edx,%eax
  800ea4:	73 12                	jae    800eb8 <memfind+0x21>
		if (*(const unsigned char *) s == (unsigned char) c)
  800ea6:	8a 4d 0c             	mov    0xc(%ebp),%cl
  800ea9:	38 08                	cmp    %cl,(%eax)
  800eab:	75 06                	jne    800eb3 <memfind+0x1c>
  800ead:	eb 09                	jmp    800eb8 <memfind+0x21>
  800eaf:	38 08                	cmp    %cl,(%eax)
  800eb1:	74 05                	je     800eb8 <memfind+0x21>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800eb3:	40                   	inc    %eax
  800eb4:	39 c2                	cmp    %eax,%edx
  800eb6:	77 f7                	ja     800eaf <memfind+0x18>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800eb8:	c9                   	leave  
  800eb9:	c3                   	ret    

00800eba <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800eba:	55                   	push   %ebp
  800ebb:	89 e5                	mov    %esp,%ebp
  800ebd:	57                   	push   %edi
  800ebe:	56                   	push   %esi
  800ebf:	53                   	push   %ebx
  800ec0:	8b 55 08             	mov    0x8(%ebp),%edx
  800ec3:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800ec6:	eb 01                	jmp    800ec9 <strtol+0xf>
		s++;
  800ec8:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800ec9:	8a 02                	mov    (%edx),%al
  800ecb:	3c 20                	cmp    $0x20,%al
  800ecd:	74 f9                	je     800ec8 <strtol+0xe>
  800ecf:	3c 09                	cmp    $0x9,%al
  800ed1:	74 f5                	je     800ec8 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800ed3:	3c 2b                	cmp    $0x2b,%al
  800ed5:	75 08                	jne    800edf <strtol+0x25>
		s++;
  800ed7:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800ed8:	bf 00 00 00 00       	mov    $0x0,%edi
  800edd:	eb 13                	jmp    800ef2 <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800edf:	3c 2d                	cmp    $0x2d,%al
  800ee1:	75 0a                	jne    800eed <strtol+0x33>
		s++, neg = 1;
  800ee3:	8d 52 01             	lea    0x1(%edx),%edx
  800ee6:	bf 01 00 00 00       	mov    $0x1,%edi
  800eeb:	eb 05                	jmp    800ef2 <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800eed:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800ef2:	85 db                	test   %ebx,%ebx
  800ef4:	74 05                	je     800efb <strtol+0x41>
  800ef6:	83 fb 10             	cmp    $0x10,%ebx
  800ef9:	75 28                	jne    800f23 <strtol+0x69>
  800efb:	8a 02                	mov    (%edx),%al
  800efd:	3c 30                	cmp    $0x30,%al
  800eff:	75 10                	jne    800f11 <strtol+0x57>
  800f01:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800f05:	75 0a                	jne    800f11 <strtol+0x57>
		s += 2, base = 16;
  800f07:	83 c2 02             	add    $0x2,%edx
  800f0a:	bb 10 00 00 00       	mov    $0x10,%ebx
  800f0f:	eb 12                	jmp    800f23 <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  800f11:	85 db                	test   %ebx,%ebx
  800f13:	75 0e                	jne    800f23 <strtol+0x69>
  800f15:	3c 30                	cmp    $0x30,%al
  800f17:	75 05                	jne    800f1e <strtol+0x64>
		s++, base = 8;
  800f19:	42                   	inc    %edx
  800f1a:	b3 08                	mov    $0x8,%bl
  800f1c:	eb 05                	jmp    800f23 <strtol+0x69>
	else if (base == 0)
		base = 10;
  800f1e:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800f23:	b8 00 00 00 00       	mov    $0x0,%eax
  800f28:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800f2a:	8a 0a                	mov    (%edx),%cl
  800f2c:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800f2f:	80 fb 09             	cmp    $0x9,%bl
  800f32:	77 08                	ja     800f3c <strtol+0x82>
			dig = *s - '0';
  800f34:	0f be c9             	movsbl %cl,%ecx
  800f37:	83 e9 30             	sub    $0x30,%ecx
  800f3a:	eb 1e                	jmp    800f5a <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  800f3c:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800f3f:	80 fb 19             	cmp    $0x19,%bl
  800f42:	77 08                	ja     800f4c <strtol+0x92>
			dig = *s - 'a' + 10;
  800f44:	0f be c9             	movsbl %cl,%ecx
  800f47:	83 e9 57             	sub    $0x57,%ecx
  800f4a:	eb 0e                	jmp    800f5a <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  800f4c:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800f4f:	80 fb 19             	cmp    $0x19,%bl
  800f52:	77 13                	ja     800f67 <strtol+0xad>
			dig = *s - 'A' + 10;
  800f54:	0f be c9             	movsbl %cl,%ecx
  800f57:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800f5a:	39 f1                	cmp    %esi,%ecx
  800f5c:	7d 0d                	jge    800f6b <strtol+0xb1>
			break;
		s++, val = (val * base) + dig;
  800f5e:	42                   	inc    %edx
  800f5f:	0f af c6             	imul   %esi,%eax
  800f62:	8d 04 01             	lea    (%ecx,%eax,1),%eax
		// we don't properly detect overflow!
	}
  800f65:	eb c3                	jmp    800f2a <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800f67:	89 c1                	mov    %eax,%ecx
  800f69:	eb 02                	jmp    800f6d <strtol+0xb3>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800f6b:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800f6d:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800f71:	74 05                	je     800f78 <strtol+0xbe>
		*endptr = (char *) s;
  800f73:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800f76:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800f78:	85 ff                	test   %edi,%edi
  800f7a:	74 04                	je     800f80 <strtol+0xc6>
  800f7c:	89 c8                	mov    %ecx,%eax
  800f7e:	f7 d8                	neg    %eax
}
  800f80:	5b                   	pop    %ebx
  800f81:	5e                   	pop    %esi
  800f82:	5f                   	pop    %edi
  800f83:	c9                   	leave  
  800f84:	c3                   	ret    
  800f85:	00 00                	add    %al,(%eax)
	...

00800f88 <syscall>:
	return ret;
}

static int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  800f88:	55                   	push   %ebp
  800f89:	89 e5                	mov    %esp,%ebp
  800f8b:	57                   	push   %edi
  800f8c:	56                   	push   %esi
  800f8d:	53                   	push   %ebx
  800f8e:	83 ec 1c             	sub    $0x1c,%esp
  800f91:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800f94:	89 55 e0             	mov    %edx,-0x20(%ebp)
  800f97:	89 ca                	mov    %ecx,%edx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f99:	8b 75 14             	mov    0x14(%ebp),%esi
  800f9c:	8b 7d 10             	mov    0x10(%ebp),%edi
  800f9f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800fa2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800fa5:	cd 30                	int    $0x30
  800fa7:	89 c2                	mov    %eax,%edx
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800fa9:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800fad:	74 1c                	je     800fcb <syscall+0x43>
  800faf:	85 c0                	test   %eax,%eax
  800fb1:	7e 18                	jle    800fcb <syscall+0x43>
		panic("syscall %d returned %d (> 0)", num, ret);
  800fb3:	83 ec 0c             	sub    $0xc,%esp
  800fb6:	50                   	push   %eax
  800fb7:	ff 75 e4             	pushl  -0x1c(%ebp)
  800fba:	68 24 18 80 00       	push   $0x801824
  800fbf:	6a 42                	push   $0x42
  800fc1:	68 41 18 80 00       	push   $0x801841
  800fc6:	e8 b1 f5 ff ff       	call   80057c <_panic>

	return ret;
}
  800fcb:	89 d0                	mov    %edx,%eax
  800fcd:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800fd0:	5b                   	pop    %ebx
  800fd1:	5e                   	pop    %esi
  800fd2:	5f                   	pop    %edi
  800fd3:	c9                   	leave  
  800fd4:	c3                   	ret    

00800fd5 <sys_cputs>:

void
sys_cputs(const char *s, size_t len)
{	
  800fd5:	55                   	push   %ebp
  800fd6:	89 e5                	mov    %esp,%ebp
  800fd8:	83 ec 08             	sub    $0x8,%esp
	// my_sysenter(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
	// return;
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
  800fdb:	6a 00                	push   $0x0
  800fdd:	6a 00                	push   $0x0
  800fdf:	6a 00                	push   $0x0
  800fe1:	ff 75 0c             	pushl  0xc(%ebp)
  800fe4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800fe7:	ba 00 00 00 00       	mov    $0x0,%edx
  800fec:	b8 00 00 00 00       	mov    $0x0,%eax
  800ff1:	e8 92 ff ff ff       	call   800f88 <syscall>
  800ff6:	83 c4 10             	add    $0x10,%esp
	return;
}
  800ff9:	c9                   	leave  
  800ffa:	c3                   	ret    

00800ffb <sys_cgetc>:

int
sys_cgetc(void)
{
  800ffb:	55                   	push   %ebp
  800ffc:	89 e5                	mov    %esp,%ebp
  800ffe:	83 ec 08             	sub    $0x8,%esp
	// return my_sysenter(SYS_cgetc, 0, 0, 0, 0, 0, 0);
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
  801001:	6a 00                	push   $0x0
  801003:	6a 00                	push   $0x0
  801005:	6a 00                	push   $0x0
  801007:	6a 00                	push   $0x0
  801009:	b9 00 00 00 00       	mov    $0x0,%ecx
  80100e:	ba 00 00 00 00       	mov    $0x0,%edx
  801013:	b8 01 00 00 00       	mov    $0x1,%eax
  801018:	e8 6b ff ff ff       	call   800f88 <syscall>
}
  80101d:	c9                   	leave  
  80101e:	c3                   	ret    

0080101f <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  80101f:	55                   	push   %ebp
  801020:	89 e5                	mov    %esp,%ebp
  801022:	83 ec 08             	sub    $0x8,%esp
	// return my_sysenter(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
  801025:	6a 00                	push   $0x0
  801027:	6a 00                	push   $0x0
  801029:	6a 00                	push   $0x0
  80102b:	6a 00                	push   $0x0
  80102d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801030:	ba 01 00 00 00       	mov    $0x1,%edx
  801035:	b8 03 00 00 00       	mov    $0x3,%eax
  80103a:	e8 49 ff ff ff       	call   800f88 <syscall>
}
  80103f:	c9                   	leave  
  801040:	c3                   	ret    

00801041 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  801041:	55                   	push   %ebp
  801042:	89 e5                	mov    %esp,%ebp
  801044:	83 ec 08             	sub    $0x8,%esp
	// return my_sysenter(SYS_getenvid, 0, 0, 0, 0, 0, 0);
	return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
  801047:	6a 00                	push   $0x0
  801049:	6a 00                	push   $0x0
  80104b:	6a 00                	push   $0x0
  80104d:	6a 00                	push   $0x0
  80104f:	b9 00 00 00 00       	mov    $0x0,%ecx
  801054:	ba 00 00 00 00       	mov    $0x0,%edx
  801059:	b8 02 00 00 00       	mov    $0x2,%eax
  80105e:	e8 25 ff ff ff       	call   800f88 <syscall>
}
  801063:	c9                   	leave  
  801064:	c3                   	ret    

00801065 <sys_yield>:

void
sys_yield(void)
{
  801065:	55                   	push   %ebp
  801066:	89 e5                	mov    %esp,%ebp
  801068:	83 ec 08             	sub    $0x8,%esp
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
  80106b:	6a 00                	push   $0x0
  80106d:	6a 00                	push   $0x0
  80106f:	6a 00                	push   $0x0
  801071:	6a 00                	push   $0x0
  801073:	b9 00 00 00 00       	mov    $0x0,%ecx
  801078:	ba 00 00 00 00       	mov    $0x0,%edx
  80107d:	b8 0a 00 00 00       	mov    $0xa,%eax
  801082:	e8 01 ff ff ff       	call   800f88 <syscall>
  801087:	83 c4 10             	add    $0x10,%esp
}
  80108a:	c9                   	leave  
  80108b:	c3                   	ret    

0080108c <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  80108c:	55                   	push   %ebp
  80108d:	89 e5                	mov    %esp,%ebp
  80108f:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
  801092:	6a 00                	push   $0x0
  801094:	6a 00                	push   $0x0
  801096:	ff 75 10             	pushl  0x10(%ebp)
  801099:	ff 75 0c             	pushl  0xc(%ebp)
  80109c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80109f:	ba 01 00 00 00       	mov    $0x1,%edx
  8010a4:	b8 04 00 00 00       	mov    $0x4,%eax
  8010a9:	e8 da fe ff ff       	call   800f88 <syscall>
}
  8010ae:	c9                   	leave  
  8010af:	c3                   	ret    

008010b0 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8010b0:	55                   	push   %ebp
  8010b1:	89 e5                	mov    %esp,%ebp
  8010b3:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
  8010b6:	ff 75 18             	pushl  0x18(%ebp)
  8010b9:	ff 75 14             	pushl  0x14(%ebp)
  8010bc:	ff 75 10             	pushl  0x10(%ebp)
  8010bf:	ff 75 0c             	pushl  0xc(%ebp)
  8010c2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8010c5:	ba 01 00 00 00       	mov    $0x1,%edx
  8010ca:	b8 05 00 00 00       	mov    $0x5,%eax
  8010cf:	e8 b4 fe ff ff       	call   800f88 <syscall>
}
  8010d4:	c9                   	leave  
  8010d5:	c3                   	ret    

008010d6 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  8010d6:	55                   	push   %ebp
  8010d7:	89 e5                	mov    %esp,%ebp
  8010d9:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
  8010dc:	6a 00                	push   $0x0
  8010de:	6a 00                	push   $0x0
  8010e0:	6a 00                	push   $0x0
  8010e2:	ff 75 0c             	pushl  0xc(%ebp)
  8010e5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8010e8:	ba 01 00 00 00       	mov    $0x1,%edx
  8010ed:	b8 06 00 00 00       	mov    $0x6,%eax
  8010f2:	e8 91 fe ff ff       	call   800f88 <syscall>
}
  8010f7:	c9                   	leave  
  8010f8:	c3                   	ret    

008010f9 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  8010f9:	55                   	push   %ebp
  8010fa:	89 e5                	mov    %esp,%ebp
  8010fc:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
  8010ff:	6a 00                	push   $0x0
  801101:	6a 00                	push   $0x0
  801103:	6a 00                	push   $0x0
  801105:	ff 75 0c             	pushl  0xc(%ebp)
  801108:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80110b:	ba 01 00 00 00       	mov    $0x1,%edx
  801110:	b8 08 00 00 00       	mov    $0x8,%eax
  801115:	e8 6e fe ff ff       	call   800f88 <syscall>
}
  80111a:	c9                   	leave  
  80111b:	c3                   	ret    

0080111c <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  80111c:	55                   	push   %ebp
  80111d:	89 e5                	mov    %esp,%ebp
  80111f:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
  801122:	6a 00                	push   $0x0
  801124:	6a 00                	push   $0x0
  801126:	6a 00                	push   $0x0
  801128:	ff 75 0c             	pushl  0xc(%ebp)
  80112b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80112e:	ba 01 00 00 00       	mov    $0x1,%edx
  801133:	b8 09 00 00 00       	mov    $0x9,%eax
  801138:	e8 4b fe ff ff       	call   800f88 <syscall>
}
  80113d:	c9                   	leave  
  80113e:	c3                   	ret    

0080113f <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  80113f:	55                   	push   %ebp
  801140:	89 e5                	mov    %esp,%ebp
  801142:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
  801145:	6a 00                	push   $0x0
  801147:	ff 75 14             	pushl  0x14(%ebp)
  80114a:	ff 75 10             	pushl  0x10(%ebp)
  80114d:	ff 75 0c             	pushl  0xc(%ebp)
  801150:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801153:	ba 00 00 00 00       	mov    $0x0,%edx
  801158:	b8 0b 00 00 00       	mov    $0xb,%eax
  80115d:	e8 26 fe ff ff       	call   800f88 <syscall>
}
  801162:	c9                   	leave  
  801163:	c3                   	ret    

00801164 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  801164:	55                   	push   %ebp
  801165:	89 e5                	mov    %esp,%ebp
  801167:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
  80116a:	6a 00                	push   $0x0
  80116c:	6a 00                	push   $0x0
  80116e:	6a 00                	push   $0x0
  801170:	6a 00                	push   $0x0
  801172:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801175:	ba 01 00 00 00       	mov    $0x1,%edx
  80117a:	b8 0c 00 00 00       	mov    $0xc,%eax
  80117f:	e8 04 fe ff ff       	call   800f88 <syscall>
}
  801184:	c9                   	leave  
  801185:	c3                   	ret    

00801186 <sys_set_priority>:

int
sys_set_priority(envid_t envid, uint32_t new_priority)
{
  801186:	55                   	push   %ebp
  801187:	89 e5                	mov    %esp,%ebp
  801189:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_set_priority, 0, envid, new_priority, 0, 0, 0);
  80118c:	6a 00                	push   $0x0
  80118e:	6a 00                	push   $0x0
  801190:	6a 00                	push   $0x0
  801192:	ff 75 0c             	pushl  0xc(%ebp)
  801195:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801198:	ba 00 00 00 00       	mov    $0x0,%edx
  80119d:	b8 0d 00 00 00       	mov    $0xd,%eax
  8011a2:	e8 e1 fd ff ff       	call   800f88 <syscall>
}
  8011a7:	c9                   	leave  
  8011a8:	c3                   	ret    
  8011a9:	00 00                	add    %al,(%eax)
	...

008011ac <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  8011ac:	55                   	push   %ebp
  8011ad:	89 e5                	mov    %esp,%ebp
  8011af:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  8011b2:	83 3d d0 20 80 00 00 	cmpl   $0x0,0x8020d0
  8011b9:	75 52                	jne    80120d <set_pgfault_handler+0x61>
		// First time through!	
		// LAB 4: Your code here.

		//int sys_page_alloc(envid_t envid, void *va, int perm)
		r = sys_page_alloc(0, (void*)(UXSTACKTOP - PGSIZE), PTE_U | PTE_W | PTE_P);
  8011bb:	83 ec 04             	sub    $0x4,%esp
  8011be:	6a 07                	push   $0x7
  8011c0:	68 00 f0 bf ee       	push   $0xeebff000
  8011c5:	6a 00                	push   $0x0
  8011c7:	e8 c0 fe ff ff       	call   80108c <sys_page_alloc>
		if (r < 0) {
  8011cc:	83 c4 10             	add    $0x10,%esp
  8011cf:	85 c0                	test   %eax,%eax
  8011d1:	79 12                	jns    8011e5 <set_pgfault_handler+0x39>
			panic("sys_page_alloc error : %e\n", r);
  8011d3:	50                   	push   %eax
  8011d4:	68 4f 18 80 00       	push   $0x80184f
  8011d9:	6a 24                	push   $0x24
  8011db:	68 6a 18 80 00       	push   $0x80186a
  8011e0:	e8 97 f3 ff ff       	call   80057c <_panic>
		}

		// how to know envid, put 0, envid2env will help us to get curenv in syscall
		r = sys_env_set_pgfault_upcall(0, _pgfault_upcall);		
  8011e5:	83 ec 08             	sub    $0x8,%esp
  8011e8:	68 18 12 80 00       	push   $0x801218
  8011ed:	6a 00                	push   $0x0
  8011ef:	e8 28 ff ff ff       	call   80111c <sys_env_set_pgfault_upcall>
		if (r < 0) {
  8011f4:	83 c4 10             	add    $0x10,%esp
  8011f7:	85 c0                	test   %eax,%eax
  8011f9:	79 12                	jns    80120d <set_pgfault_handler+0x61>
			panic("sys_env_set_pgfault_upcall error : %e\n", r);
  8011fb:	50                   	push   %eax
  8011fc:	68 78 18 80 00       	push   $0x801878
  801201:	6a 2a                	push   $0x2a
  801203:	68 6a 18 80 00       	push   $0x80186a
  801208:	e8 6f f3 ff ff       	call   80057c <_panic>
		}
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  80120d:	8b 45 08             	mov    0x8(%ebp),%eax
  801210:	a3 d0 20 80 00       	mov    %eax,0x8020d0
}
  801215:	c9                   	leave  
  801216:	c3                   	ret    
	...

00801218 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  801218:	54                   	push   %esp
	movl _pgfault_handler, %eax
  801219:	a1 d0 20 80 00       	mov    0x8020d0,%eax
	call *%eax
  80121e:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  801220:	83 c4 04             	add    $0x4,%esp
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	
	// fix old esp
	movl 0x30(%esp), %eax
  801223:	8b 44 24 30          	mov    0x30(%esp),%eax
	subl $0x4, %eax
  801227:	83 e8 04             	sub    $0x4,%eax
	movl %eax, 0x30(%esp)
  80122a:	89 44 24 30          	mov    %eax,0x30(%esp)

	// set trap-time %eip
	movl 0x28(%esp), %ebx
  80122e:	8b 5c 24 28          	mov    0x28(%esp),%ebx
	movl %ebx, (%eax)
  801232:	89 18                	mov    %ebx,(%eax)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	addl $0x08, %esp 	// ignore err_code and fault_va
  801234:	83 c4 08             	add    $0x8,%esp
	popal 				// restore registers
  801237:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $0x04, %esp 	// ignore eip 
  801238:	83 c4 04             	add    $0x4,%esp
	popfl				// modify eflags
  80123b:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp
  80123c:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  80123d:	c3                   	ret    
	...

00801240 <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  801240:	55                   	push   %ebp
  801241:	89 e5                	mov    %esp,%ebp
  801243:	57                   	push   %edi
  801244:	56                   	push   %esi
  801245:	83 ec 10             	sub    $0x10,%esp
  801248:	8b 7d 08             	mov    0x8(%ebp),%edi
  80124b:	8b 4d 10             	mov    0x10(%ebp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  80124e:	89 7d f0             	mov    %edi,-0x10(%ebp)
  801251:	8b 75 0c             	mov    0xc(%ebp),%esi
  const DWunion dd = {.ll = d};
  801254:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  801257:	8b 45 14             	mov    0x14(%ebp),%eax
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  80125a:	85 c0                	test   %eax,%eax
  80125c:	75 2e                	jne    80128c <__udivdi3+0x4c>
    {
      if (d0 > n1)
  80125e:	39 f1                	cmp    %esi,%ecx
  801260:	77 5a                	ja     8012bc <__udivdi3+0x7c>
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  801262:	85 c9                	test   %ecx,%ecx
  801264:	75 0b                	jne    801271 <__udivdi3+0x31>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  801266:	b8 01 00 00 00       	mov    $0x1,%eax
  80126b:	31 d2                	xor    %edx,%edx
  80126d:	f7 f1                	div    %ecx
  80126f:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  801271:	31 d2                	xor    %edx,%edx
  801273:	89 f0                	mov    %esi,%eax
  801275:	f7 f1                	div    %ecx
  801277:	89 c6                	mov    %eax,%esi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801279:	89 f8                	mov    %edi,%eax
  80127b:	f7 f1                	div    %ecx
  80127d:	89 c7                	mov    %eax,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  80127f:	89 f8                	mov    %edi,%eax
  801281:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801283:	83 c4 10             	add    $0x10,%esp
  801286:	5e                   	pop    %esi
  801287:	5f                   	pop    %edi
  801288:	c9                   	leave  
  801289:	c3                   	ret    
  80128a:	66 90                	xchg   %ax,%ax
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  80128c:	39 f0                	cmp    %esi,%eax
  80128e:	77 1c                	ja     8012ac <__udivdi3+0x6c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  801290:	0f bd f8             	bsr    %eax,%edi
	  if (bm == 0)
  801293:	83 f7 1f             	xor    $0x1f,%edi
  801296:	75 3c                	jne    8012d4 <__udivdi3+0x94>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  801298:	39 f0                	cmp    %esi,%eax
  80129a:	0f 82 90 00 00 00    	jb     801330 <__udivdi3+0xf0>
  8012a0:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8012a3:	39 55 f4             	cmp    %edx,-0xc(%ebp)
  8012a6:	0f 86 84 00 00 00    	jbe    801330 <__udivdi3+0xf0>
  8012ac:	31 f6                	xor    %esi,%esi
  8012ae:	31 ff                	xor    %edi,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  8012b0:	89 f8                	mov    %edi,%eax
  8012b2:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  8012b4:	83 c4 10             	add    $0x10,%esp
  8012b7:	5e                   	pop    %esi
  8012b8:	5f                   	pop    %edi
  8012b9:	c9                   	leave  
  8012ba:	c3                   	ret    
  8012bb:	90                   	nop
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  8012bc:	89 f2                	mov    %esi,%edx
  8012be:	89 f8                	mov    %edi,%eax
  8012c0:	f7 f1                	div    %ecx
  8012c2:	89 c7                	mov    %eax,%edi
  8012c4:	31 f6                	xor    %esi,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  8012c6:	89 f8                	mov    %edi,%eax
  8012c8:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  8012ca:	83 c4 10             	add    $0x10,%esp
  8012cd:	5e                   	pop    %esi
  8012ce:	5f                   	pop    %edi
  8012cf:	c9                   	leave  
  8012d0:	c3                   	ret    
  8012d1:	8d 76 00             	lea    0x0(%esi),%esi
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  8012d4:	89 f9                	mov    %edi,%ecx
  8012d6:	d3 e0                	shl    %cl,%eax
  8012d8:	89 45 e8             	mov    %eax,-0x18(%ebp)
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  8012db:	b8 20 00 00 00       	mov    $0x20,%eax
  8012e0:	29 f8                	sub    %edi,%eax

	      d1 = (d1 << bm) | (d0 >> b);
  8012e2:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8012e5:	88 c1                	mov    %al,%cl
  8012e7:	d3 ea                	shr    %cl,%edx
  8012e9:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  8012ec:	09 ca                	or     %ecx,%edx
  8012ee:	89 55 ec             	mov    %edx,-0x14(%ebp)
	      d0 = d0 << bm;
  8012f1:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8012f4:	89 f9                	mov    %edi,%ecx
  8012f6:	d3 e2                	shl    %cl,%edx
  8012f8:	89 55 f4             	mov    %edx,-0xc(%ebp)
	      n2 = n1 >> b;
  8012fb:	89 f2                	mov    %esi,%edx
  8012fd:	88 c1                	mov    %al,%cl
  8012ff:	d3 ea                	shr    %cl,%edx
  801301:	89 55 e8             	mov    %edx,-0x18(%ebp)
	      n1 = (n1 << bm) | (n0 >> b);
  801304:	89 f2                	mov    %esi,%edx
  801306:	89 f9                	mov    %edi,%ecx
  801308:	d3 e2                	shl    %cl,%edx
  80130a:	8b 75 f0             	mov    -0x10(%ebp),%esi
  80130d:	88 c1                	mov    %al,%cl
  80130f:	d3 ee                	shr    %cl,%esi
  801311:	09 d6                	or     %edx,%esi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  801313:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  801316:	89 f0                	mov    %esi,%eax
  801318:	89 ca                	mov    %ecx,%edx
  80131a:	f7 75 ec             	divl   -0x14(%ebp)
  80131d:	89 d1                	mov    %edx,%ecx
  80131f:	89 c6                	mov    %eax,%esi
	      umul_ppmm (m1, m0, q0, d0);
  801321:	f7 65 f4             	mull   -0xc(%ebp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801324:	39 d1                	cmp    %edx,%ecx
  801326:	72 28                	jb     801350 <__udivdi3+0x110>
  801328:	74 1a                	je     801344 <__udivdi3+0x104>
  80132a:	89 f7                	mov    %esi,%edi
  80132c:	31 f6                	xor    %esi,%esi
  80132e:	eb 80                	jmp    8012b0 <__udivdi3+0x70>
	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  801330:	31 f6                	xor    %esi,%esi
  801332:	bf 01 00 00 00       	mov    $0x1,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  801337:	89 f8                	mov    %edi,%eax
  801339:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  80133b:	83 c4 10             	add    $0x10,%esp
  80133e:	5e                   	pop    %esi
  80133f:	5f                   	pop    %edi
  801340:	c9                   	leave  
  801341:	c3                   	ret    
  801342:	66 90                	xchg   %ax,%ax

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  801344:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801347:	89 f9                	mov    %edi,%ecx
  801349:	d3 e2                	shl    %cl,%edx

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  80134b:	39 c2                	cmp    %eax,%edx
  80134d:	73 db                	jae    80132a <__udivdi3+0xea>
  80134f:	90                   	nop
		{
		  q0--;
  801350:	8d 7e ff             	lea    -0x1(%esi),%edi
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  801353:	31 f6                	xor    %esi,%esi
  801355:	e9 56 ff ff ff       	jmp    8012b0 <__udivdi3+0x70>
	...

0080135c <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  80135c:	55                   	push   %ebp
  80135d:	89 e5                	mov    %esp,%ebp
  80135f:	57                   	push   %edi
  801360:	56                   	push   %esi
  801361:	83 ec 20             	sub    $0x20,%esp
  801364:	8b 45 08             	mov    0x8(%ebp),%eax
  801367:	8b 4d 10             	mov    0x10(%ebp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  80136a:	89 45 e8             	mov    %eax,-0x18(%ebp)
  80136d:	8b 75 0c             	mov    0xc(%ebp),%esi
  const DWunion dd = {.ll = d};
  801370:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  801373:	8b 7d 14             	mov    0x14(%ebp),%edi
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  801376:	89 45 f0             	mov    %eax,-0x10(%ebp)
  n1 = nn.s.high;
  801379:	89 f2                	mov    %esi,%edx

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  80137b:	85 ff                	test   %edi,%edi
  80137d:	75 15                	jne    801394 <__umoddi3+0x38>
    {
      if (d0 > n1)
  80137f:	39 f1                	cmp    %esi,%ecx
  801381:	0f 86 99 00 00 00    	jbe    801420 <__umoddi3+0xc4>
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801387:	f7 f1                	div    %ecx

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
  801389:	89 d0                	mov    %edx,%eax
  80138b:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  80138d:	83 c4 20             	add    $0x20,%esp
  801390:	5e                   	pop    %esi
  801391:	5f                   	pop    %edi
  801392:	c9                   	leave  
  801393:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  801394:	39 f7                	cmp    %esi,%edi
  801396:	0f 87 a4 00 00 00    	ja     801440 <__umoddi3+0xe4>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  80139c:	0f bd c7             	bsr    %edi,%eax
	  if (bm == 0)
  80139f:	83 f0 1f             	xor    $0x1f,%eax
  8013a2:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8013a5:	0f 84 a1 00 00 00    	je     80144c <__umoddi3+0xf0>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  8013ab:	89 f8                	mov    %edi,%eax
  8013ad:	8a 4d ec             	mov    -0x14(%ebp),%cl
  8013b0:	d3 e0                	shl    %cl,%eax
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  8013b2:	bf 20 00 00 00       	mov    $0x20,%edi
  8013b7:	2b 7d ec             	sub    -0x14(%ebp),%edi

	      d1 = (d1 << bm) | (d0 >> b);
  8013ba:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8013bd:	89 f9                	mov    %edi,%ecx
  8013bf:	d3 ea                	shr    %cl,%edx
  8013c1:	09 c2                	or     %eax,%edx
  8013c3:	89 55 f0             	mov    %edx,-0x10(%ebp)
	      d0 = d0 << bm;
  8013c6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8013c9:	8a 4d ec             	mov    -0x14(%ebp),%cl
  8013cc:	d3 e0                	shl    %cl,%eax
  8013ce:	89 45 f4             	mov    %eax,-0xc(%ebp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  8013d1:	89 f2                	mov    %esi,%edx
  8013d3:	d3 e2                	shl    %cl,%edx
	      n0 = n0 << bm;
  8013d5:	8b 45 e8             	mov    -0x18(%ebp),%eax
  8013d8:	d3 e0                	shl    %cl,%eax
  8013da:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  8013dd:	8b 45 e8             	mov    -0x18(%ebp),%eax
  8013e0:	89 f9                	mov    %edi,%ecx
  8013e2:	d3 e8                	shr    %cl,%eax
  8013e4:	09 d0                	or     %edx,%eax

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  8013e6:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  8013e8:	89 f2                	mov    %esi,%edx
  8013ea:	f7 75 f0             	divl   -0x10(%ebp)
  8013ed:	89 d6                	mov    %edx,%esi
	      umul_ppmm (m1, m0, q0, d0);
  8013ef:	f7 65 f4             	mull   -0xc(%ebp)
  8013f2:	89 55 e8             	mov    %edx,-0x18(%ebp)
  8013f5:	89 c1                	mov    %eax,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  8013f7:	39 d6                	cmp    %edx,%esi
  8013f9:	72 71                	jb     80146c <__umoddi3+0x110>
  8013fb:	74 7f                	je     80147c <__umoddi3+0x120>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  8013fd:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801400:	29 c8                	sub    %ecx,%eax
  801402:	19 d6                	sbb    %edx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
  801404:	8a 4d ec             	mov    -0x14(%ebp),%cl
  801407:	d3 e8                	shr    %cl,%eax
  801409:	89 f2                	mov    %esi,%edx
  80140b:	89 f9                	mov    %edi,%ecx
  80140d:	d3 e2                	shl    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
  80140f:	09 d0                	or     %edx,%eax
  801411:	89 f2                	mov    %esi,%edx
  801413:	8a 4d ec             	mov    -0x14(%ebp),%cl
  801416:	d3 ea                	shr    %cl,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  801418:	83 c4 20             	add    $0x20,%esp
  80141b:	5e                   	pop    %esi
  80141c:	5f                   	pop    %edi
  80141d:	c9                   	leave  
  80141e:	c3                   	ret    
  80141f:	90                   	nop
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  801420:	85 c9                	test   %ecx,%ecx
  801422:	75 0b                	jne    80142f <__umoddi3+0xd3>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  801424:	b8 01 00 00 00       	mov    $0x1,%eax
  801429:	31 d2                	xor    %edx,%edx
  80142b:	f7 f1                	div    %ecx
  80142d:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  80142f:	89 f0                	mov    %esi,%eax
  801431:	31 d2                	xor    %edx,%edx
  801433:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801435:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801438:	f7 f1                	div    %ecx
  80143a:	e9 4a ff ff ff       	jmp    801389 <__umoddi3+0x2d>
  80143f:	90                   	nop
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
  801440:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  801442:	83 c4 20             	add    $0x20,%esp
  801445:	5e                   	pop    %esi
  801446:	5f                   	pop    %edi
  801447:	c9                   	leave  
  801448:	c3                   	ret    
  801449:	8d 76 00             	lea    0x0(%esi),%esi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  80144c:	39 f7                	cmp    %esi,%edi
  80144e:	72 05                	jb     801455 <__umoddi3+0xf9>
  801450:	3b 4d f0             	cmp    -0x10(%ebp),%ecx
  801453:	77 0c                	ja     801461 <__umoddi3+0x105>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  801455:	89 f2                	mov    %esi,%edx
  801457:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80145a:	29 c8                	sub    %ecx,%eax
  80145c:	19 fa                	sbb    %edi,%edx
  80145e:	89 45 f0             	mov    %eax,-0x10(%ebp)

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
  801461:	8b 45 f0             	mov    -0x10(%ebp),%eax
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  801464:	83 c4 20             	add    $0x20,%esp
  801467:	5e                   	pop    %esi
  801468:	5f                   	pop    %edi
  801469:	c9                   	leave  
  80146a:	c3                   	ret    
  80146b:	90                   	nop
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  80146c:	8b 55 e8             	mov    -0x18(%ebp),%edx
  80146f:	89 c1                	mov    %eax,%ecx
  801471:	2b 4d f4             	sub    -0xc(%ebp),%ecx
  801474:	1b 55 f0             	sbb    -0x10(%ebp),%edx
  801477:	eb 84                	jmp    8013fd <__umoddi3+0xa1>
  801479:	8d 76 00             	lea    0x0(%esi),%esi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  80147c:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  80147f:	72 eb                	jb     80146c <__umoddi3+0x110>
  801481:	89 f2                	mov    %esi,%edx
  801483:	e9 75 ff ff ff       	jmp    8013fd <__umoddi3+0xa1>
