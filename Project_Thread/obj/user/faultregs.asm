
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
  800045:	68 71 23 80 00       	push   $0x802371
  80004a:	68 40 23 80 00       	push   $0x802340
  80004f:	e8 0c 06 00 00       	call   800660 <cprintf>
			cprintf("MISMATCH\n");				\
			mismatch = 1;					\
		}							\
	} while (0)

	CHECK(edi, regs.reg_edi);
  800054:	ff 36                	pushl  (%esi)
  800056:	ff 33                	pushl  (%ebx)
  800058:	68 50 23 80 00       	push   $0x802350
  80005d:	68 54 23 80 00       	push   $0x802354
  800062:	e8 f9 05 00 00       	call   800660 <cprintf>
  800067:	83 c4 20             	add    $0x20,%esp
  80006a:	8b 06                	mov    (%esi),%eax
  80006c:	39 03                	cmp    %eax,(%ebx)
  80006e:	75 17                	jne    800087 <check_regs+0x53>
  800070:	83 ec 0c             	sub    $0xc,%esp
  800073:	68 64 23 80 00       	push   $0x802364
  800078:	e8 e3 05 00 00       	call   800660 <cprintf>
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
  80008a:	68 68 23 80 00       	push   $0x802368
  80008f:	e8 cc 05 00 00       	call   800660 <cprintf>
  800094:	83 c4 10             	add    $0x10,%esp
  800097:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(esi, regs.reg_esi);
  80009c:	ff 76 04             	pushl  0x4(%esi)
  80009f:	ff 73 04             	pushl  0x4(%ebx)
  8000a2:	68 72 23 80 00       	push   $0x802372
  8000a7:	68 54 23 80 00       	push   $0x802354
  8000ac:	e8 af 05 00 00       	call   800660 <cprintf>
  8000b1:	83 c4 10             	add    $0x10,%esp
  8000b4:	8b 46 04             	mov    0x4(%esi),%eax
  8000b7:	39 43 04             	cmp    %eax,0x4(%ebx)
  8000ba:	75 12                	jne    8000ce <check_regs+0x9a>
  8000bc:	83 ec 0c             	sub    $0xc,%esp
  8000bf:	68 64 23 80 00       	push   $0x802364
  8000c4:	e8 97 05 00 00       	call   800660 <cprintf>
  8000c9:	83 c4 10             	add    $0x10,%esp
  8000cc:	eb 15                	jmp    8000e3 <check_regs+0xaf>
  8000ce:	83 ec 0c             	sub    $0xc,%esp
  8000d1:	68 68 23 80 00       	push   $0x802368
  8000d6:	e8 85 05 00 00       	call   800660 <cprintf>
  8000db:	83 c4 10             	add    $0x10,%esp
  8000de:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(ebp, regs.reg_ebp);
  8000e3:	ff 76 08             	pushl  0x8(%esi)
  8000e6:	ff 73 08             	pushl  0x8(%ebx)
  8000e9:	68 76 23 80 00       	push   $0x802376
  8000ee:	68 54 23 80 00       	push   $0x802354
  8000f3:	e8 68 05 00 00       	call   800660 <cprintf>
  8000f8:	83 c4 10             	add    $0x10,%esp
  8000fb:	8b 46 08             	mov    0x8(%esi),%eax
  8000fe:	39 43 08             	cmp    %eax,0x8(%ebx)
  800101:	75 12                	jne    800115 <check_regs+0xe1>
  800103:	83 ec 0c             	sub    $0xc,%esp
  800106:	68 64 23 80 00       	push   $0x802364
  80010b:	e8 50 05 00 00       	call   800660 <cprintf>
  800110:	83 c4 10             	add    $0x10,%esp
  800113:	eb 15                	jmp    80012a <check_regs+0xf6>
  800115:	83 ec 0c             	sub    $0xc,%esp
  800118:	68 68 23 80 00       	push   $0x802368
  80011d:	e8 3e 05 00 00       	call   800660 <cprintf>
  800122:	83 c4 10             	add    $0x10,%esp
  800125:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(ebx, regs.reg_ebx);
  80012a:	ff 76 10             	pushl  0x10(%esi)
  80012d:	ff 73 10             	pushl  0x10(%ebx)
  800130:	68 7a 23 80 00       	push   $0x80237a
  800135:	68 54 23 80 00       	push   $0x802354
  80013a:	e8 21 05 00 00       	call   800660 <cprintf>
  80013f:	83 c4 10             	add    $0x10,%esp
  800142:	8b 46 10             	mov    0x10(%esi),%eax
  800145:	39 43 10             	cmp    %eax,0x10(%ebx)
  800148:	75 12                	jne    80015c <check_regs+0x128>
  80014a:	83 ec 0c             	sub    $0xc,%esp
  80014d:	68 64 23 80 00       	push   $0x802364
  800152:	e8 09 05 00 00       	call   800660 <cprintf>
  800157:	83 c4 10             	add    $0x10,%esp
  80015a:	eb 15                	jmp    800171 <check_regs+0x13d>
  80015c:	83 ec 0c             	sub    $0xc,%esp
  80015f:	68 68 23 80 00       	push   $0x802368
  800164:	e8 f7 04 00 00       	call   800660 <cprintf>
  800169:	83 c4 10             	add    $0x10,%esp
  80016c:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(edx, regs.reg_edx);
  800171:	ff 76 14             	pushl  0x14(%esi)
  800174:	ff 73 14             	pushl  0x14(%ebx)
  800177:	68 7e 23 80 00       	push   $0x80237e
  80017c:	68 54 23 80 00       	push   $0x802354
  800181:	e8 da 04 00 00       	call   800660 <cprintf>
  800186:	83 c4 10             	add    $0x10,%esp
  800189:	8b 46 14             	mov    0x14(%esi),%eax
  80018c:	39 43 14             	cmp    %eax,0x14(%ebx)
  80018f:	75 12                	jne    8001a3 <check_regs+0x16f>
  800191:	83 ec 0c             	sub    $0xc,%esp
  800194:	68 64 23 80 00       	push   $0x802364
  800199:	e8 c2 04 00 00       	call   800660 <cprintf>
  80019e:	83 c4 10             	add    $0x10,%esp
  8001a1:	eb 15                	jmp    8001b8 <check_regs+0x184>
  8001a3:	83 ec 0c             	sub    $0xc,%esp
  8001a6:	68 68 23 80 00       	push   $0x802368
  8001ab:	e8 b0 04 00 00       	call   800660 <cprintf>
  8001b0:	83 c4 10             	add    $0x10,%esp
  8001b3:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(ecx, regs.reg_ecx);
  8001b8:	ff 76 18             	pushl  0x18(%esi)
  8001bb:	ff 73 18             	pushl  0x18(%ebx)
  8001be:	68 82 23 80 00       	push   $0x802382
  8001c3:	68 54 23 80 00       	push   $0x802354
  8001c8:	e8 93 04 00 00       	call   800660 <cprintf>
  8001cd:	83 c4 10             	add    $0x10,%esp
  8001d0:	8b 46 18             	mov    0x18(%esi),%eax
  8001d3:	39 43 18             	cmp    %eax,0x18(%ebx)
  8001d6:	75 12                	jne    8001ea <check_regs+0x1b6>
  8001d8:	83 ec 0c             	sub    $0xc,%esp
  8001db:	68 64 23 80 00       	push   $0x802364
  8001e0:	e8 7b 04 00 00       	call   800660 <cprintf>
  8001e5:	83 c4 10             	add    $0x10,%esp
  8001e8:	eb 15                	jmp    8001ff <check_regs+0x1cb>
  8001ea:	83 ec 0c             	sub    $0xc,%esp
  8001ed:	68 68 23 80 00       	push   $0x802368
  8001f2:	e8 69 04 00 00       	call   800660 <cprintf>
  8001f7:	83 c4 10             	add    $0x10,%esp
  8001fa:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(eax, regs.reg_eax);
  8001ff:	ff 76 1c             	pushl  0x1c(%esi)
  800202:	ff 73 1c             	pushl  0x1c(%ebx)
  800205:	68 86 23 80 00       	push   $0x802386
  80020a:	68 54 23 80 00       	push   $0x802354
  80020f:	e8 4c 04 00 00       	call   800660 <cprintf>
  800214:	83 c4 10             	add    $0x10,%esp
  800217:	8b 46 1c             	mov    0x1c(%esi),%eax
  80021a:	39 43 1c             	cmp    %eax,0x1c(%ebx)
  80021d:	75 12                	jne    800231 <check_regs+0x1fd>
  80021f:	83 ec 0c             	sub    $0xc,%esp
  800222:	68 64 23 80 00       	push   $0x802364
  800227:	e8 34 04 00 00       	call   800660 <cprintf>
  80022c:	83 c4 10             	add    $0x10,%esp
  80022f:	eb 15                	jmp    800246 <check_regs+0x212>
  800231:	83 ec 0c             	sub    $0xc,%esp
  800234:	68 68 23 80 00       	push   $0x802368
  800239:	e8 22 04 00 00       	call   800660 <cprintf>
  80023e:	83 c4 10             	add    $0x10,%esp
  800241:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(eip, eip);
  800246:	ff 76 20             	pushl  0x20(%esi)
  800249:	ff 73 20             	pushl  0x20(%ebx)
  80024c:	68 8a 23 80 00       	push   $0x80238a
  800251:	68 54 23 80 00       	push   $0x802354
  800256:	e8 05 04 00 00       	call   800660 <cprintf>
  80025b:	83 c4 10             	add    $0x10,%esp
  80025e:	8b 46 20             	mov    0x20(%esi),%eax
  800261:	39 43 20             	cmp    %eax,0x20(%ebx)
  800264:	75 12                	jne    800278 <check_regs+0x244>
  800266:	83 ec 0c             	sub    $0xc,%esp
  800269:	68 64 23 80 00       	push   $0x802364
  80026e:	e8 ed 03 00 00       	call   800660 <cprintf>
  800273:	83 c4 10             	add    $0x10,%esp
  800276:	eb 15                	jmp    80028d <check_regs+0x259>
  800278:	83 ec 0c             	sub    $0xc,%esp
  80027b:	68 68 23 80 00       	push   $0x802368
  800280:	e8 db 03 00 00       	call   800660 <cprintf>
  800285:	83 c4 10             	add    $0x10,%esp
  800288:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(eflags, eflags);
  80028d:	ff 76 24             	pushl  0x24(%esi)
  800290:	ff 73 24             	pushl  0x24(%ebx)
  800293:	68 8e 23 80 00       	push   $0x80238e
  800298:	68 54 23 80 00       	push   $0x802354
  80029d:	e8 be 03 00 00       	call   800660 <cprintf>
  8002a2:	83 c4 10             	add    $0x10,%esp
  8002a5:	8b 46 24             	mov    0x24(%esi),%eax
  8002a8:	39 43 24             	cmp    %eax,0x24(%ebx)
  8002ab:	75 12                	jne    8002bf <check_regs+0x28b>
  8002ad:	83 ec 0c             	sub    $0xc,%esp
  8002b0:	68 64 23 80 00       	push   $0x802364
  8002b5:	e8 a6 03 00 00       	call   800660 <cprintf>
  8002ba:	83 c4 10             	add    $0x10,%esp
  8002bd:	eb 15                	jmp    8002d4 <check_regs+0x2a0>
  8002bf:	83 ec 0c             	sub    $0xc,%esp
  8002c2:	68 68 23 80 00       	push   $0x802368
  8002c7:	e8 94 03 00 00       	call   800660 <cprintf>
  8002cc:	83 c4 10             	add    $0x10,%esp
  8002cf:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(esp, esp);
  8002d4:	ff 76 28             	pushl  0x28(%esi)
  8002d7:	ff 73 28             	pushl  0x28(%ebx)
  8002da:	68 95 23 80 00       	push   $0x802395
  8002df:	68 54 23 80 00       	push   $0x802354
  8002e4:	e8 77 03 00 00       	call   800660 <cprintf>
  8002e9:	83 c4 10             	add    $0x10,%esp
  8002ec:	8b 46 28             	mov    0x28(%esi),%eax
  8002ef:	39 43 28             	cmp    %eax,0x28(%ebx)
  8002f2:	75 26                	jne    80031a <check_regs+0x2e6>
  8002f4:	83 ec 0c             	sub    $0xc,%esp
  8002f7:	68 64 23 80 00       	push   $0x802364
  8002fc:	e8 5f 03 00 00       	call   800660 <cprintf>

#undef CHECK

	cprintf("Registers %s ", testname);
  800301:	83 c4 08             	add    $0x8,%esp
  800304:	ff 75 0c             	pushl  0xc(%ebp)
  800307:	68 99 23 80 00       	push   $0x802399
  80030c:	e8 4f 03 00 00       	call   800660 <cprintf>
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
  80031d:	68 68 23 80 00       	push   $0x802368
  800322:	e8 39 03 00 00       	call   800660 <cprintf>

#undef CHECK

	cprintf("Registers %s ", testname);
  800327:	83 c4 08             	add    $0x8,%esp
  80032a:	ff 75 0c             	pushl  0xc(%ebp)
  80032d:	68 99 23 80 00       	push   $0x802399
  800332:	e8 29 03 00 00       	call   800660 <cprintf>
  800337:	83 c4 10             	add    $0x10,%esp
  80033a:	eb 12                	jmp    80034e <check_regs+0x31a>
	if (!mismatch)
		cprintf("OK\n");
  80033c:	83 ec 0c             	sub    $0xc,%esp
  80033f:	68 64 23 80 00       	push   $0x802364
  800344:	e8 17 03 00 00       	call   800660 <cprintf>
  800349:	83 c4 10             	add    $0x10,%esp
  80034c:	eb 10                	jmp    80035e <check_regs+0x32a>
	else
		cprintf("MISMATCH\n");
  80034e:	83 ec 0c             	sub    $0xc,%esp
  800351:	68 68 23 80 00       	push   $0x802368
  800356:	e8 05 03 00 00       	call   800660 <cprintf>
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
  80037f:	68 00 24 80 00       	push   $0x802400
  800384:	6a 51                	push   $0x51
  800386:	68 a7 23 80 00       	push   $0x8023a7
  80038b:	e8 f8 01 00 00       	call   800588 <_panic>
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
  8003b8:	68 bf 23 80 00       	push   $0x8023bf
  8003bd:	68 cd 23 80 00       	push   $0x8023cd
  8003c2:	b9 80 40 80 00       	mov    $0x804080,%ecx
  8003c7:	ba b8 23 80 00       	mov    $0x8023b8,%edx
  8003cc:	b8 00 40 80 00       	mov    $0x804000,%eax
  8003d1:	e8 5e fc ff ff       	call   800034 <check_regs>

	// Map UTEMP so the write succeeds
	if ((r = sys_page_alloc(0, UTEMP, PTE_U|PTE_P|PTE_W)) < 0)
  8003d6:	83 c4 0c             	add    $0xc,%esp
  8003d9:	6a 07                	push   $0x7
  8003db:	68 00 00 40 00       	push   $0x400000
  8003e0:	6a 00                	push   $0x0
  8003e2:	e8 b1 0c 00 00       	call   801098 <sys_page_alloc>
  8003e7:	83 c4 10             	add    $0x10,%esp
  8003ea:	85 c0                	test   %eax,%eax
  8003ec:	79 12                	jns    800400 <pgfault+0x9a>
		panic("sys_page_alloc: %e", r);
  8003ee:	50                   	push   %eax
  8003ef:	68 d4 23 80 00       	push   $0x8023d4
  8003f4:	6a 5c                	push   $0x5c
  8003f6:	68 a7 23 80 00       	push   $0x8023a7
  8003fb:	e8 88 01 00 00       	call   800588 <_panic>
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
  800412:	e8 2d 0e 00 00       	call   801244 <set_pgfault_handler>

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
  8004e1:	68 34 24 80 00       	push   $0x802434
  8004e6:	e8 75 01 00 00       	call   800660 <cprintf>
  8004eb:	83 c4 10             	add    $0x10,%esp
	after.eip = before.eip;
  8004ee:	a1 20 40 80 00       	mov    0x804020,%eax
  8004f3:	a3 60 40 80 00       	mov    %eax,0x804060

	check_regs(&before, "before", &after, "after", "after page-fault");
  8004f8:	83 ec 08             	sub    $0x8,%esp
  8004fb:	68 e7 23 80 00       	push   $0x8023e7
  800500:	68 f8 23 80 00       	push   $0x8023f8
  800505:	b9 40 40 80 00       	mov    $0x804040,%ecx
  80050a:	ba b8 23 80 00       	mov    $0x8023b8,%edx
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
  80052b:	e8 1d 0b 00 00       	call   80104d <sys_getenvid>
  800530:	25 ff 03 00 00       	and    $0x3ff,%eax
  800535:	89 c2                	mov    %eax,%edx
  800537:	c1 e2 07             	shl    $0x7,%edx
  80053a:	8d 84 82 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,4),%eax
  800541:	a3 b0 40 80 00       	mov    %eax,0x8040b0

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800546:	85 f6                	test   %esi,%esi
  800548:	7e 07                	jle    800551 <libmain+0x31>
		binaryname = argv[0];
  80054a:	8b 03                	mov    (%ebx),%eax
  80054c:	a3 00 30 80 00       	mov    %eax,0x803000
	// call user main routine
	umain(argc, argv);
  800551:	83 ec 08             	sub    $0x8,%esp
  800554:	53                   	push   %ebx
  800555:	56                   	push   %esi
  800556:	e8 ac fe ff ff       	call   800407 <umain>

	// exit gracefully
	exit();
  80055b:	e8 0c 00 00 00       	call   80056c <exit>
  800560:	83 c4 10             	add    $0x10,%esp
}
  800563:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800566:	5b                   	pop    %ebx
  800567:	5e                   	pop    %esi
  800568:	c9                   	leave  
  800569:	c3                   	ret    
	...

0080056c <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80056c:	55                   	push   %ebp
  80056d:	89 e5                	mov    %esp,%ebp
  80056f:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800572:	e8 6b 0f 00 00       	call   8014e2 <close_all>
	sys_env_destroy(0);
  800577:	83 ec 0c             	sub    $0xc,%esp
  80057a:	6a 00                	push   $0x0
  80057c:	e8 aa 0a 00 00       	call   80102b <sys_env_destroy>
  800581:	83 c4 10             	add    $0x10,%esp
}
  800584:	c9                   	leave  
  800585:	c3                   	ret    
	...

00800588 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800588:	55                   	push   %ebp
  800589:	89 e5                	mov    %esp,%ebp
  80058b:	56                   	push   %esi
  80058c:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  80058d:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800590:	8b 1d 00 30 80 00    	mov    0x803000,%ebx
  800596:	e8 b2 0a 00 00       	call   80104d <sys_getenvid>
  80059b:	83 ec 0c             	sub    $0xc,%esp
  80059e:	ff 75 0c             	pushl  0xc(%ebp)
  8005a1:	ff 75 08             	pushl  0x8(%ebp)
  8005a4:	53                   	push   %ebx
  8005a5:	50                   	push   %eax
  8005a6:	68 60 24 80 00       	push   $0x802460
  8005ab:	e8 b0 00 00 00       	call   800660 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8005b0:	83 c4 18             	add    $0x18,%esp
  8005b3:	56                   	push   %esi
  8005b4:	ff 75 10             	pushl  0x10(%ebp)
  8005b7:	e8 53 00 00 00       	call   80060f <vcprintf>
	cprintf("\n");
  8005bc:	c7 04 24 70 23 80 00 	movl   $0x802370,(%esp)
  8005c3:	e8 98 00 00 00       	call   800660 <cprintf>
  8005c8:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8005cb:	cc                   	int3   
  8005cc:	eb fd                	jmp    8005cb <_panic+0x43>
	...

008005d0 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8005d0:	55                   	push   %ebp
  8005d1:	89 e5                	mov    %esp,%ebp
  8005d3:	53                   	push   %ebx
  8005d4:	83 ec 04             	sub    $0x4,%esp
  8005d7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8005da:	8b 03                	mov    (%ebx),%eax
  8005dc:	8b 55 08             	mov    0x8(%ebp),%edx
  8005df:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  8005e3:	40                   	inc    %eax
  8005e4:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  8005e6:	3d ff 00 00 00       	cmp    $0xff,%eax
  8005eb:	75 1a                	jne    800607 <putch+0x37>
		sys_cputs(b->buf, b->idx);
  8005ed:	83 ec 08             	sub    $0x8,%esp
  8005f0:	68 ff 00 00 00       	push   $0xff
  8005f5:	8d 43 08             	lea    0x8(%ebx),%eax
  8005f8:	50                   	push   %eax
  8005f9:	e8 e3 09 00 00       	call   800fe1 <sys_cputs>
		b->idx = 0;
  8005fe:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800604:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  800607:	ff 43 04             	incl   0x4(%ebx)
}
  80060a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80060d:	c9                   	leave  
  80060e:	c3                   	ret    

0080060f <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80060f:	55                   	push   %ebp
  800610:	89 e5                	mov    %esp,%ebp
  800612:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800618:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80061f:	00 00 00 
	b.cnt = 0;
  800622:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800629:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80062c:	ff 75 0c             	pushl  0xc(%ebp)
  80062f:	ff 75 08             	pushl  0x8(%ebp)
  800632:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800638:	50                   	push   %eax
  800639:	68 d0 05 80 00       	push   $0x8005d0
  80063e:	e8 82 01 00 00       	call   8007c5 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800643:	83 c4 08             	add    $0x8,%esp
  800646:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  80064c:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800652:	50                   	push   %eax
  800653:	e8 89 09 00 00       	call   800fe1 <sys_cputs>

	return b.cnt;
}
  800658:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80065e:	c9                   	leave  
  80065f:	c3                   	ret    

00800660 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800660:	55                   	push   %ebp
  800661:	89 e5                	mov    %esp,%ebp
  800663:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800666:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800669:	50                   	push   %eax
  80066a:	ff 75 08             	pushl  0x8(%ebp)
  80066d:	e8 9d ff ff ff       	call   80060f <vcprintf>
	va_end(ap);

	return cnt;
}
  800672:	c9                   	leave  
  800673:	c3                   	ret    

00800674 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800674:	55                   	push   %ebp
  800675:	89 e5                	mov    %esp,%ebp
  800677:	57                   	push   %edi
  800678:	56                   	push   %esi
  800679:	53                   	push   %ebx
  80067a:	83 ec 2c             	sub    $0x2c,%esp
  80067d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800680:	89 d6                	mov    %edx,%esi
  800682:	8b 45 08             	mov    0x8(%ebp),%eax
  800685:	8b 55 0c             	mov    0xc(%ebp),%edx
  800688:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80068b:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80068e:	8b 45 10             	mov    0x10(%ebp),%eax
  800691:	8b 5d 14             	mov    0x14(%ebp),%ebx
  800694:	8b 7d 18             	mov    0x18(%ebp),%edi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800697:	89 45 d0             	mov    %eax,-0x30(%ebp)
  80069a:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  8006a1:	39 55 d4             	cmp    %edx,-0x2c(%ebp)
  8006a4:	72 0c                	jb     8006b2 <printnum+0x3e>
  8006a6:	3b 45 d8             	cmp    -0x28(%ebp),%eax
  8006a9:	76 07                	jbe    8006b2 <printnum+0x3e>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8006ab:	4b                   	dec    %ebx
  8006ac:	85 db                	test   %ebx,%ebx
  8006ae:	7f 31                	jg     8006e1 <printnum+0x6d>
  8006b0:	eb 3f                	jmp    8006f1 <printnum+0x7d>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8006b2:	83 ec 0c             	sub    $0xc,%esp
  8006b5:	57                   	push   %edi
  8006b6:	4b                   	dec    %ebx
  8006b7:	53                   	push   %ebx
  8006b8:	50                   	push   %eax
  8006b9:	83 ec 08             	sub    $0x8,%esp
  8006bc:	ff 75 d4             	pushl  -0x2c(%ebp)
  8006bf:	ff 75 d0             	pushl  -0x30(%ebp)
  8006c2:	ff 75 dc             	pushl  -0x24(%ebp)
  8006c5:	ff 75 d8             	pushl  -0x28(%ebp)
  8006c8:	e8 1b 1a 00 00       	call   8020e8 <__udivdi3>
  8006cd:	83 c4 18             	add    $0x18,%esp
  8006d0:	52                   	push   %edx
  8006d1:	50                   	push   %eax
  8006d2:	89 f2                	mov    %esi,%edx
  8006d4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8006d7:	e8 98 ff ff ff       	call   800674 <printnum>
  8006dc:	83 c4 20             	add    $0x20,%esp
  8006df:	eb 10                	jmp    8006f1 <printnum+0x7d>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8006e1:	83 ec 08             	sub    $0x8,%esp
  8006e4:	56                   	push   %esi
  8006e5:	57                   	push   %edi
  8006e6:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8006e9:	4b                   	dec    %ebx
  8006ea:	83 c4 10             	add    $0x10,%esp
  8006ed:	85 db                	test   %ebx,%ebx
  8006ef:	7f f0                	jg     8006e1 <printnum+0x6d>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8006f1:	83 ec 08             	sub    $0x8,%esp
  8006f4:	56                   	push   %esi
  8006f5:	83 ec 04             	sub    $0x4,%esp
  8006f8:	ff 75 d4             	pushl  -0x2c(%ebp)
  8006fb:	ff 75 d0             	pushl  -0x30(%ebp)
  8006fe:	ff 75 dc             	pushl  -0x24(%ebp)
  800701:	ff 75 d8             	pushl  -0x28(%ebp)
  800704:	e8 fb 1a 00 00       	call   802204 <__umoddi3>
  800709:	83 c4 14             	add    $0x14,%esp
  80070c:	0f be 80 83 24 80 00 	movsbl 0x802483(%eax),%eax
  800713:	50                   	push   %eax
  800714:	ff 55 e4             	call   *-0x1c(%ebp)
  800717:	83 c4 10             	add    $0x10,%esp
}
  80071a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80071d:	5b                   	pop    %ebx
  80071e:	5e                   	pop    %esi
  80071f:	5f                   	pop    %edi
  800720:	c9                   	leave  
  800721:	c3                   	ret    

00800722 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800722:	55                   	push   %ebp
  800723:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800725:	83 fa 01             	cmp    $0x1,%edx
  800728:	7e 0e                	jle    800738 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80072a:	8b 10                	mov    (%eax),%edx
  80072c:	8d 4a 08             	lea    0x8(%edx),%ecx
  80072f:	89 08                	mov    %ecx,(%eax)
  800731:	8b 02                	mov    (%edx),%eax
  800733:	8b 52 04             	mov    0x4(%edx),%edx
  800736:	eb 22                	jmp    80075a <getuint+0x38>
	else if (lflag)
  800738:	85 d2                	test   %edx,%edx
  80073a:	74 10                	je     80074c <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  80073c:	8b 10                	mov    (%eax),%edx
  80073e:	8d 4a 04             	lea    0x4(%edx),%ecx
  800741:	89 08                	mov    %ecx,(%eax)
  800743:	8b 02                	mov    (%edx),%eax
  800745:	ba 00 00 00 00       	mov    $0x0,%edx
  80074a:	eb 0e                	jmp    80075a <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  80074c:	8b 10                	mov    (%eax),%edx
  80074e:	8d 4a 04             	lea    0x4(%edx),%ecx
  800751:	89 08                	mov    %ecx,(%eax)
  800753:	8b 02                	mov    (%edx),%eax
  800755:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80075a:	c9                   	leave  
  80075b:	c3                   	ret    

0080075c <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
  80075c:	55                   	push   %ebp
  80075d:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80075f:	83 fa 01             	cmp    $0x1,%edx
  800762:	7e 0e                	jle    800772 <getint+0x16>
		return va_arg(*ap, long long);
  800764:	8b 10                	mov    (%eax),%edx
  800766:	8d 4a 08             	lea    0x8(%edx),%ecx
  800769:	89 08                	mov    %ecx,(%eax)
  80076b:	8b 02                	mov    (%edx),%eax
  80076d:	8b 52 04             	mov    0x4(%edx),%edx
  800770:	eb 1a                	jmp    80078c <getint+0x30>
	else if (lflag)
  800772:	85 d2                	test   %edx,%edx
  800774:	74 0c                	je     800782 <getint+0x26>
		return va_arg(*ap, long);
  800776:	8b 10                	mov    (%eax),%edx
  800778:	8d 4a 04             	lea    0x4(%edx),%ecx
  80077b:	89 08                	mov    %ecx,(%eax)
  80077d:	8b 02                	mov    (%edx),%eax
  80077f:	99                   	cltd   
  800780:	eb 0a                	jmp    80078c <getint+0x30>
	else
		return va_arg(*ap, int);
  800782:	8b 10                	mov    (%eax),%edx
  800784:	8d 4a 04             	lea    0x4(%edx),%ecx
  800787:	89 08                	mov    %ecx,(%eax)
  800789:	8b 02                	mov    (%edx),%eax
  80078b:	99                   	cltd   
}
  80078c:	c9                   	leave  
  80078d:	c3                   	ret    

0080078e <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80078e:	55                   	push   %ebp
  80078f:	89 e5                	mov    %esp,%ebp
  800791:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800794:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  800797:	8b 10                	mov    (%eax),%edx
  800799:	3b 50 04             	cmp    0x4(%eax),%edx
  80079c:	73 08                	jae    8007a6 <sprintputch+0x18>
		*b->buf++ = ch;
  80079e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007a1:	88 0a                	mov    %cl,(%edx)
  8007a3:	42                   	inc    %edx
  8007a4:	89 10                	mov    %edx,(%eax)
}
  8007a6:	c9                   	leave  
  8007a7:	c3                   	ret    

008007a8 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8007a8:	55                   	push   %ebp
  8007a9:	89 e5                	mov    %esp,%ebp
  8007ab:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8007ae:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8007b1:	50                   	push   %eax
  8007b2:	ff 75 10             	pushl  0x10(%ebp)
  8007b5:	ff 75 0c             	pushl  0xc(%ebp)
  8007b8:	ff 75 08             	pushl  0x8(%ebp)
  8007bb:	e8 05 00 00 00       	call   8007c5 <vprintfmt>
	va_end(ap);
  8007c0:	83 c4 10             	add    $0x10,%esp
}
  8007c3:	c9                   	leave  
  8007c4:	c3                   	ret    

008007c5 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8007c5:	55                   	push   %ebp
  8007c6:	89 e5                	mov    %esp,%ebp
  8007c8:	57                   	push   %edi
  8007c9:	56                   	push   %esi
  8007ca:	53                   	push   %ebx
  8007cb:	83 ec 2c             	sub    $0x2c,%esp
  8007ce:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8007d1:	8b 75 10             	mov    0x10(%ebp),%esi
  8007d4:	eb 13                	jmp    8007e9 <vprintfmt+0x24>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8007d6:	85 c0                	test   %eax,%eax
  8007d8:	0f 84 6d 03 00 00    	je     800b4b <vprintfmt+0x386>
				return;
			putch(ch, putdat);
  8007de:	83 ec 08             	sub    $0x8,%esp
  8007e1:	57                   	push   %edi
  8007e2:	50                   	push   %eax
  8007e3:	ff 55 08             	call   *0x8(%ebp)
  8007e6:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8007e9:	0f b6 06             	movzbl (%esi),%eax
  8007ec:	46                   	inc    %esi
  8007ed:	83 f8 25             	cmp    $0x25,%eax
  8007f0:	75 e4                	jne    8007d6 <vprintfmt+0x11>
  8007f2:	c6 45 dc 20          	movb   $0x20,-0x24(%ebp)
  8007f6:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  8007fd:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
  800804:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  80080b:	b9 00 00 00 00       	mov    $0x0,%ecx
  800810:	eb 28                	jmp    80083a <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800812:	89 de                	mov    %ebx,%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  800814:	c6 45 dc 2d          	movb   $0x2d,-0x24(%ebp)
  800818:	eb 20                	jmp    80083a <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80081a:	89 de                	mov    %ebx,%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  80081c:	c6 45 dc 30          	movb   $0x30,-0x24(%ebp)
  800820:	eb 18                	jmp    80083a <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800822:	89 de                	mov    %ebx,%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  800824:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  80082b:	eb 0d                	jmp    80083a <vprintfmt+0x75>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  80082d:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  800830:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800833:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80083a:	8a 06                	mov    (%esi),%al
  80083c:	0f b6 d0             	movzbl %al,%edx
  80083f:	8d 5e 01             	lea    0x1(%esi),%ebx
  800842:	83 e8 23             	sub    $0x23,%eax
  800845:	3c 55                	cmp    $0x55,%al
  800847:	0f 87 e0 02 00 00    	ja     800b2d <vprintfmt+0x368>
  80084d:	0f b6 c0             	movzbl %al,%eax
  800850:	ff 24 85 c0 25 80 00 	jmp    *0x8025c0(,%eax,4)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800857:	83 ea 30             	sub    $0x30,%edx
  80085a:	89 55 d4             	mov    %edx,-0x2c(%ebp)
				ch = *fmt;
  80085d:	0f be 03             	movsbl (%ebx),%eax
				if (ch < '0' || ch > '9')
  800860:	8d 50 d0             	lea    -0x30(%eax),%edx
  800863:	83 fa 09             	cmp    $0x9,%edx
  800866:	77 44                	ja     8008ac <vprintfmt+0xe7>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800868:	89 de                	mov    %ebx,%esi
  80086a:	8b 55 d4             	mov    -0x2c(%ebp),%edx
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80086d:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
  80086e:	8d 14 92             	lea    (%edx,%edx,4),%edx
  800871:	8d 54 50 d0          	lea    -0x30(%eax,%edx,2),%edx
				ch = *fmt;
  800875:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  800878:	8d 58 d0             	lea    -0x30(%eax),%ebx
  80087b:	83 fb 09             	cmp    $0x9,%ebx
  80087e:	76 ed                	jbe    80086d <vprintfmt+0xa8>
  800880:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  800883:	eb 29                	jmp    8008ae <vprintfmt+0xe9>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800885:	8b 45 14             	mov    0x14(%ebp),%eax
  800888:	8d 50 04             	lea    0x4(%eax),%edx
  80088b:	89 55 14             	mov    %edx,0x14(%ebp)
  80088e:	8b 00                	mov    (%eax),%eax
  800890:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800893:	89 de                	mov    %ebx,%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800895:	eb 17                	jmp    8008ae <vprintfmt+0xe9>

		case '.':
			if (width < 0)
  800897:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80089b:	78 85                	js     800822 <vprintfmt+0x5d>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80089d:	89 de                	mov    %ebx,%esi
  80089f:	eb 99                	jmp    80083a <vprintfmt+0x75>
  8008a1:	89 de                	mov    %ebx,%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8008a3:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
			goto reswitch;
  8008aa:	eb 8e                	jmp    80083a <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8008ac:	89 de                	mov    %ebx,%esi
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  8008ae:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8008b2:	79 86                	jns    80083a <vprintfmt+0x75>
  8008b4:	e9 74 ff ff ff       	jmp    80082d <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8008b9:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8008ba:	89 de                	mov    %ebx,%esi
  8008bc:	e9 79 ff ff ff       	jmp    80083a <vprintfmt+0x75>
  8008c1:	89 5d d8             	mov    %ebx,-0x28(%ebp)
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8008c4:	8b 45 14             	mov    0x14(%ebp),%eax
  8008c7:	8d 50 04             	lea    0x4(%eax),%edx
  8008ca:	89 55 14             	mov    %edx,0x14(%ebp)
  8008cd:	83 ec 08             	sub    $0x8,%esp
  8008d0:	57                   	push   %edi
  8008d1:	ff 30                	pushl  (%eax)
  8008d3:	ff 55 08             	call   *0x8(%ebp)
			break;
  8008d6:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8008d9:	8b 75 d8             	mov    -0x28(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8008dc:	e9 08 ff ff ff       	jmp    8007e9 <vprintfmt+0x24>
  8008e1:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// error message
		case 'e':
			err = va_arg(ap, int);
  8008e4:	8b 45 14             	mov    0x14(%ebp),%eax
  8008e7:	8d 50 04             	lea    0x4(%eax),%edx
  8008ea:	89 55 14             	mov    %edx,0x14(%ebp)
  8008ed:	8b 00                	mov    (%eax),%eax
  8008ef:	85 c0                	test   %eax,%eax
  8008f1:	79 02                	jns    8008f5 <vprintfmt+0x130>
  8008f3:	f7 d8                	neg    %eax
  8008f5:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8008f7:	83 f8 0f             	cmp    $0xf,%eax
  8008fa:	7f 0b                	jg     800907 <vprintfmt+0x142>
  8008fc:	8b 04 85 20 27 80 00 	mov    0x802720(,%eax,4),%eax
  800903:	85 c0                	test   %eax,%eax
  800905:	75 1a                	jne    800921 <vprintfmt+0x15c>
				printfmt(putch, putdat, "error %d", err);
  800907:	52                   	push   %edx
  800908:	68 9b 24 80 00       	push   $0x80249b
  80090d:	57                   	push   %edi
  80090e:	ff 75 08             	pushl  0x8(%ebp)
  800911:	e8 92 fe ff ff       	call   8007a8 <printfmt>
  800916:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800919:	8b 75 d8             	mov    -0x28(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  80091c:	e9 c8 fe ff ff       	jmp    8007e9 <vprintfmt+0x24>
			else
				printfmt(putch, putdat, "%s", p);
  800921:	50                   	push   %eax
  800922:	68 a5 28 80 00       	push   $0x8028a5
  800927:	57                   	push   %edi
  800928:	ff 75 08             	pushl  0x8(%ebp)
  80092b:	e8 78 fe ff ff       	call   8007a8 <printfmt>
  800930:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800933:	8b 75 d8             	mov    -0x28(%ebp),%esi
  800936:	e9 ae fe ff ff       	jmp    8007e9 <vprintfmt+0x24>
  80093b:	89 5d d8             	mov    %ebx,-0x28(%ebp)
  80093e:	89 de                	mov    %ebx,%esi
  800940:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  800943:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800946:	8b 45 14             	mov    0x14(%ebp),%eax
  800949:	8d 50 04             	lea    0x4(%eax),%edx
  80094c:	89 55 14             	mov    %edx,0x14(%ebp)
  80094f:	8b 00                	mov    (%eax),%eax
  800951:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800954:	85 c0                	test   %eax,%eax
  800956:	75 07                	jne    80095f <vprintfmt+0x19a>
				p = "(null)";
  800958:	c7 45 d0 94 24 80 00 	movl   $0x802494,-0x30(%ebp)
			if (width > 0 && padc != '-')
  80095f:	85 db                	test   %ebx,%ebx
  800961:	7e 42                	jle    8009a5 <vprintfmt+0x1e0>
  800963:	80 7d dc 2d          	cmpb   $0x2d,-0x24(%ebp)
  800967:	74 3c                	je     8009a5 <vprintfmt+0x1e0>
				for (width -= strnlen(p, precision); width > 0; width--)
  800969:	83 ec 08             	sub    $0x8,%esp
  80096c:	51                   	push   %ecx
  80096d:	ff 75 d0             	pushl  -0x30(%ebp)
  800970:	e8 6f 02 00 00       	call   800be4 <strnlen>
  800975:	29 c3                	sub    %eax,%ebx
  800977:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  80097a:	83 c4 10             	add    $0x10,%esp
  80097d:	85 db                	test   %ebx,%ebx
  80097f:	7e 24                	jle    8009a5 <vprintfmt+0x1e0>
					putch(padc, putdat);
  800981:	0f be 5d dc          	movsbl -0x24(%ebp),%ebx
  800985:	89 75 dc             	mov    %esi,-0x24(%ebp)
  800988:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  80098b:	83 ec 08             	sub    $0x8,%esp
  80098e:	57                   	push   %edi
  80098f:	53                   	push   %ebx
  800990:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800993:	4e                   	dec    %esi
  800994:	83 c4 10             	add    $0x10,%esp
  800997:	85 f6                	test   %esi,%esi
  800999:	7f f0                	jg     80098b <vprintfmt+0x1c6>
  80099b:	8b 75 dc             	mov    -0x24(%ebp),%esi
  80099e:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8009a5:	8b 55 d0             	mov    -0x30(%ebp),%edx
  8009a8:	0f be 02             	movsbl (%edx),%eax
  8009ab:	85 c0                	test   %eax,%eax
  8009ad:	75 47                	jne    8009f6 <vprintfmt+0x231>
  8009af:	eb 37                	jmp    8009e8 <vprintfmt+0x223>
				if (altflag && (ch < ' ' || ch > '~'))
  8009b1:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8009b5:	74 16                	je     8009cd <vprintfmt+0x208>
  8009b7:	8d 50 e0             	lea    -0x20(%eax),%edx
  8009ba:	83 fa 5e             	cmp    $0x5e,%edx
  8009bd:	76 0e                	jbe    8009cd <vprintfmt+0x208>
					putch('?', putdat);
  8009bf:	83 ec 08             	sub    $0x8,%esp
  8009c2:	57                   	push   %edi
  8009c3:	6a 3f                	push   $0x3f
  8009c5:	ff 55 08             	call   *0x8(%ebp)
  8009c8:	83 c4 10             	add    $0x10,%esp
  8009cb:	eb 0b                	jmp    8009d8 <vprintfmt+0x213>
				else
					putch(ch, putdat);
  8009cd:	83 ec 08             	sub    $0x8,%esp
  8009d0:	57                   	push   %edi
  8009d1:	50                   	push   %eax
  8009d2:	ff 55 08             	call   *0x8(%ebp)
  8009d5:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8009d8:	ff 4d e4             	decl   -0x1c(%ebp)
  8009db:	0f be 03             	movsbl (%ebx),%eax
  8009de:	85 c0                	test   %eax,%eax
  8009e0:	74 03                	je     8009e5 <vprintfmt+0x220>
  8009e2:	43                   	inc    %ebx
  8009e3:	eb 1b                	jmp    800a00 <vprintfmt+0x23b>
  8009e5:	8b 75 dc             	mov    -0x24(%ebp),%esi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8009e8:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8009ec:	7f 1e                	jg     800a0c <vprintfmt+0x247>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8009ee:	8b 75 d8             	mov    -0x28(%ebp),%esi
  8009f1:	e9 f3 fd ff ff       	jmp    8007e9 <vprintfmt+0x24>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8009f6:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  8009f9:	43                   	inc    %ebx
  8009fa:	89 75 dc             	mov    %esi,-0x24(%ebp)
  8009fd:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  800a00:	85 f6                	test   %esi,%esi
  800a02:	78 ad                	js     8009b1 <vprintfmt+0x1ec>
  800a04:	4e                   	dec    %esi
  800a05:	79 aa                	jns    8009b1 <vprintfmt+0x1ec>
  800a07:	8b 75 dc             	mov    -0x24(%ebp),%esi
  800a0a:	eb dc                	jmp    8009e8 <vprintfmt+0x223>
  800a0c:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800a0f:	83 ec 08             	sub    $0x8,%esp
  800a12:	57                   	push   %edi
  800a13:	6a 20                	push   $0x20
  800a15:	ff 55 08             	call   *0x8(%ebp)
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800a18:	4b                   	dec    %ebx
  800a19:	83 c4 10             	add    $0x10,%esp
  800a1c:	85 db                	test   %ebx,%ebx
  800a1e:	7f ef                	jg     800a0f <vprintfmt+0x24a>
  800a20:	e9 c4 fd ff ff       	jmp    8007e9 <vprintfmt+0x24>
  800a25:	89 5d d8             	mov    %ebx,-0x28(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800a28:	89 ca                	mov    %ecx,%edx
  800a2a:	8d 45 14             	lea    0x14(%ebp),%eax
  800a2d:	e8 2a fd ff ff       	call   80075c <getint>
  800a32:	89 c3                	mov    %eax,%ebx
  800a34:	89 d6                	mov    %edx,%esi
			if ((long long) num < 0) {
  800a36:	85 d2                	test   %edx,%edx
  800a38:	78 0a                	js     800a44 <vprintfmt+0x27f>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800a3a:	b8 0a 00 00 00       	mov    $0xa,%eax
  800a3f:	e9 b0 00 00 00       	jmp    800af4 <vprintfmt+0x32f>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  800a44:	83 ec 08             	sub    $0x8,%esp
  800a47:	57                   	push   %edi
  800a48:	6a 2d                	push   $0x2d
  800a4a:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  800a4d:	f7 db                	neg    %ebx
  800a4f:	83 d6 00             	adc    $0x0,%esi
  800a52:	f7 de                	neg    %esi
  800a54:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800a57:	b8 0a 00 00 00       	mov    $0xa,%eax
  800a5c:	e9 93 00 00 00       	jmp    800af4 <vprintfmt+0x32f>
  800a61:	89 5d d8             	mov    %ebx,-0x28(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800a64:	89 ca                	mov    %ecx,%edx
  800a66:	8d 45 14             	lea    0x14(%ebp),%eax
  800a69:	e8 b4 fc ff ff       	call   800722 <getuint>
  800a6e:	89 c3                	mov    %eax,%ebx
  800a70:	89 d6                	mov    %edx,%esi
			base = 10;
  800a72:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  800a77:	eb 7b                	jmp    800af4 <vprintfmt+0x32f>
  800a79:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// (unsigned) octal
		case 'o':
            // (MIT 6.828, lab1, Ex.8)  my code : 
            num = getint(&ap, lflag);
  800a7c:	89 ca                	mov    %ecx,%edx
  800a7e:	8d 45 14             	lea    0x14(%ebp),%eax
  800a81:	e8 d6 fc ff ff       	call   80075c <getint>
  800a86:	89 c3                	mov    %eax,%ebx
  800a88:	89 d6                	mov    %edx,%esi
            if ((long long) num < 0) {
  800a8a:	85 d2                	test   %edx,%edx
  800a8c:	78 07                	js     800a95 <vprintfmt+0x2d0>
                putch('-', putdat);
                num = -(long long) num;
            }
            base = 8;
  800a8e:	b8 08 00 00 00       	mov    $0x8,%eax
  800a93:	eb 5f                	jmp    800af4 <vprintfmt+0x32f>
		// (unsigned) octal
		case 'o':
            // (MIT 6.828, lab1, Ex.8)  my code : 
            num = getint(&ap, lflag);
            if ((long long) num < 0) {
                putch('-', putdat);
  800a95:	83 ec 08             	sub    $0x8,%esp
  800a98:	57                   	push   %edi
  800a99:	6a 2d                	push   $0x2d
  800a9b:	ff 55 08             	call   *0x8(%ebp)
                num = -(long long) num;
  800a9e:	f7 db                	neg    %ebx
  800aa0:	83 d6 00             	adc    $0x0,%esi
  800aa3:	f7 de                	neg    %esi
  800aa5:	83 c4 10             	add    $0x10,%esp
            }
            base = 8;
  800aa8:	b8 08 00 00 00       	mov    $0x8,%eax
  800aad:	eb 45                	jmp    800af4 <vprintfmt+0x32f>
  800aaf:	89 5d d8             	mov    %ebx,-0x28(%ebp)
            goto number;

        // pointer
		case 'p':
			putch('0', putdat);
  800ab2:	83 ec 08             	sub    $0x8,%esp
  800ab5:	57                   	push   %edi
  800ab6:	6a 30                	push   $0x30
  800ab8:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  800abb:	83 c4 08             	add    $0x8,%esp
  800abe:	57                   	push   %edi
  800abf:	6a 78                	push   $0x78
  800ac1:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800ac4:	8b 45 14             	mov    0x14(%ebp),%eax
  800ac7:	8d 50 04             	lea    0x4(%eax),%edx
  800aca:	89 55 14             	mov    %edx,0x14(%ebp)

        // pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800acd:	8b 18                	mov    (%eax),%ebx
  800acf:	be 00 00 00 00       	mov    $0x0,%esi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800ad4:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800ad7:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  800adc:	eb 16                	jmp    800af4 <vprintfmt+0x32f>
  800ade:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800ae1:	89 ca                	mov    %ecx,%edx
  800ae3:	8d 45 14             	lea    0x14(%ebp),%eax
  800ae6:	e8 37 fc ff ff       	call   800722 <getuint>
  800aeb:	89 c3                	mov    %eax,%ebx
  800aed:	89 d6                	mov    %edx,%esi
			base = 16;
  800aef:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  800af4:	83 ec 0c             	sub    $0xc,%esp
  800af7:	0f be 55 dc          	movsbl -0x24(%ebp),%edx
  800afb:	52                   	push   %edx
  800afc:	ff 75 e4             	pushl  -0x1c(%ebp)
  800aff:	50                   	push   %eax
  800b00:	56                   	push   %esi
  800b01:	53                   	push   %ebx
  800b02:	89 fa                	mov    %edi,%edx
  800b04:	8b 45 08             	mov    0x8(%ebp),%eax
  800b07:	e8 68 fb ff ff       	call   800674 <printnum>
			break;
  800b0c:	83 c4 20             	add    $0x20,%esp
  800b0f:	8b 75 d8             	mov    -0x28(%ebp),%esi
  800b12:	e9 d2 fc ff ff       	jmp    8007e9 <vprintfmt+0x24>
  800b17:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800b1a:	83 ec 08             	sub    $0x8,%esp
  800b1d:	57                   	push   %edi
  800b1e:	52                   	push   %edx
  800b1f:	ff 55 08             	call   *0x8(%ebp)
			break;
  800b22:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800b25:	8b 75 d8             	mov    -0x28(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800b28:	e9 bc fc ff ff       	jmp    8007e9 <vprintfmt+0x24>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800b2d:	83 ec 08             	sub    $0x8,%esp
  800b30:	57                   	push   %edi
  800b31:	6a 25                	push   $0x25
  800b33:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800b36:	83 c4 10             	add    $0x10,%esp
  800b39:	eb 02                	jmp    800b3d <vprintfmt+0x378>
  800b3b:	89 c6                	mov    %eax,%esi
  800b3d:	8d 46 ff             	lea    -0x1(%esi),%eax
  800b40:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  800b44:	75 f5                	jne    800b3b <vprintfmt+0x376>
  800b46:	e9 9e fc ff ff       	jmp    8007e9 <vprintfmt+0x24>
				/* do nothing */;
			break;
		}
	}
}
  800b4b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b4e:	5b                   	pop    %ebx
  800b4f:	5e                   	pop    %esi
  800b50:	5f                   	pop    %edi
  800b51:	c9                   	leave  
  800b52:	c3                   	ret    

00800b53 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800b53:	55                   	push   %ebp
  800b54:	89 e5                	mov    %esp,%ebp
  800b56:	83 ec 18             	sub    $0x18,%esp
  800b59:	8b 45 08             	mov    0x8(%ebp),%eax
  800b5c:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800b5f:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800b62:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800b66:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800b69:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800b70:	85 c0                	test   %eax,%eax
  800b72:	74 26                	je     800b9a <vsnprintf+0x47>
  800b74:	85 d2                	test   %edx,%edx
  800b76:	7e 29                	jle    800ba1 <vsnprintf+0x4e>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800b78:	ff 75 14             	pushl  0x14(%ebp)
  800b7b:	ff 75 10             	pushl  0x10(%ebp)
  800b7e:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800b81:	50                   	push   %eax
  800b82:	68 8e 07 80 00       	push   $0x80078e
  800b87:	e8 39 fc ff ff       	call   8007c5 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800b8c:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800b8f:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800b92:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800b95:	83 c4 10             	add    $0x10,%esp
  800b98:	eb 0c                	jmp    800ba6 <vsnprintf+0x53>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800b9a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800b9f:	eb 05                	jmp    800ba6 <vsnprintf+0x53>
  800ba1:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800ba6:	c9                   	leave  
  800ba7:	c3                   	ret    

00800ba8 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800ba8:	55                   	push   %ebp
  800ba9:	89 e5                	mov    %esp,%ebp
  800bab:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800bae:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800bb1:	50                   	push   %eax
  800bb2:	ff 75 10             	pushl  0x10(%ebp)
  800bb5:	ff 75 0c             	pushl  0xc(%ebp)
  800bb8:	ff 75 08             	pushl  0x8(%ebp)
  800bbb:	e8 93 ff ff ff       	call   800b53 <vsnprintf>
	va_end(ap);

	return rc;
}
  800bc0:	c9                   	leave  
  800bc1:	c3                   	ret    
	...

00800bc4 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800bc4:	55                   	push   %ebp
  800bc5:	89 e5                	mov    %esp,%ebp
  800bc7:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800bca:	80 3a 00             	cmpb   $0x0,(%edx)
  800bcd:	74 0e                	je     800bdd <strlen+0x19>
  800bcf:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  800bd4:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800bd5:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800bd9:	75 f9                	jne    800bd4 <strlen+0x10>
  800bdb:	eb 05                	jmp    800be2 <strlen+0x1e>
  800bdd:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  800be2:	c9                   	leave  
  800be3:	c3                   	ret    

00800be4 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800be4:	55                   	push   %ebp
  800be5:	89 e5                	mov    %esp,%ebp
  800be7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800bea:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800bed:	85 d2                	test   %edx,%edx
  800bef:	74 17                	je     800c08 <strnlen+0x24>
  800bf1:	80 39 00             	cmpb   $0x0,(%ecx)
  800bf4:	74 19                	je     800c0f <strnlen+0x2b>
  800bf6:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  800bfb:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800bfc:	39 d0                	cmp    %edx,%eax
  800bfe:	74 14                	je     800c14 <strnlen+0x30>
  800c00:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800c04:	75 f5                	jne    800bfb <strnlen+0x17>
  800c06:	eb 0c                	jmp    800c14 <strnlen+0x30>
  800c08:	b8 00 00 00 00       	mov    $0x0,%eax
  800c0d:	eb 05                	jmp    800c14 <strnlen+0x30>
  800c0f:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  800c14:	c9                   	leave  
  800c15:	c3                   	ret    

00800c16 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800c16:	55                   	push   %ebp
  800c17:	89 e5                	mov    %esp,%ebp
  800c19:	53                   	push   %ebx
  800c1a:	8b 45 08             	mov    0x8(%ebp),%eax
  800c1d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800c20:	ba 00 00 00 00       	mov    $0x0,%edx
  800c25:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  800c28:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800c2b:	42                   	inc    %edx
  800c2c:	84 c9                	test   %cl,%cl
  800c2e:	75 f5                	jne    800c25 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800c30:	5b                   	pop    %ebx
  800c31:	c9                   	leave  
  800c32:	c3                   	ret    

00800c33 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800c33:	55                   	push   %ebp
  800c34:	89 e5                	mov    %esp,%ebp
  800c36:	53                   	push   %ebx
  800c37:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800c3a:	53                   	push   %ebx
  800c3b:	e8 84 ff ff ff       	call   800bc4 <strlen>
  800c40:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800c43:	ff 75 0c             	pushl  0xc(%ebp)
  800c46:	8d 04 03             	lea    (%ebx,%eax,1),%eax
  800c49:	50                   	push   %eax
  800c4a:	e8 c7 ff ff ff       	call   800c16 <strcpy>
	return dst;
}
  800c4f:	89 d8                	mov    %ebx,%eax
  800c51:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800c54:	c9                   	leave  
  800c55:	c3                   	ret    

00800c56 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800c56:	55                   	push   %ebp
  800c57:	89 e5                	mov    %esp,%ebp
  800c59:	56                   	push   %esi
  800c5a:	53                   	push   %ebx
  800c5b:	8b 45 08             	mov    0x8(%ebp),%eax
  800c5e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800c61:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800c64:	85 f6                	test   %esi,%esi
  800c66:	74 15                	je     800c7d <strncpy+0x27>
  800c68:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
  800c6d:	8a 1a                	mov    (%edx),%bl
  800c6f:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800c72:	80 3a 01             	cmpb   $0x1,(%edx)
  800c75:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800c78:	41                   	inc    %ecx
  800c79:	39 ce                	cmp    %ecx,%esi
  800c7b:	77 f0                	ja     800c6d <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800c7d:	5b                   	pop    %ebx
  800c7e:	5e                   	pop    %esi
  800c7f:	c9                   	leave  
  800c80:	c3                   	ret    

00800c81 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800c81:	55                   	push   %ebp
  800c82:	89 e5                	mov    %esp,%ebp
  800c84:	57                   	push   %edi
  800c85:	56                   	push   %esi
  800c86:	53                   	push   %ebx
  800c87:	8b 7d 08             	mov    0x8(%ebp),%edi
  800c8a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800c8d:	8b 75 10             	mov    0x10(%ebp),%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800c90:	85 f6                	test   %esi,%esi
  800c92:	74 32                	je     800cc6 <strlcpy+0x45>
		while (--size > 0 && *src != '\0')
  800c94:	83 fe 01             	cmp    $0x1,%esi
  800c97:	74 22                	je     800cbb <strlcpy+0x3a>
  800c99:	8a 0b                	mov    (%ebx),%cl
  800c9b:	84 c9                	test   %cl,%cl
  800c9d:	74 20                	je     800cbf <strlcpy+0x3e>
  800c9f:	89 f8                	mov    %edi,%eax
  800ca1:	ba 00 00 00 00       	mov    $0x0,%edx
	}
	return ret;
}

size_t
strlcpy(char *dst, const char *src, size_t size)
  800ca6:	83 ee 02             	sub    $0x2,%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800ca9:	88 08                	mov    %cl,(%eax)
  800cab:	40                   	inc    %eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800cac:	39 f2                	cmp    %esi,%edx
  800cae:	74 11                	je     800cc1 <strlcpy+0x40>
  800cb0:	8a 4c 13 01          	mov    0x1(%ebx,%edx,1),%cl
  800cb4:	42                   	inc    %edx
  800cb5:	84 c9                	test   %cl,%cl
  800cb7:	75 f0                	jne    800ca9 <strlcpy+0x28>
  800cb9:	eb 06                	jmp    800cc1 <strlcpy+0x40>
  800cbb:	89 f8                	mov    %edi,%eax
  800cbd:	eb 02                	jmp    800cc1 <strlcpy+0x40>
  800cbf:	89 f8                	mov    %edi,%eax
			*dst++ = *src++;
		*dst = '\0';
  800cc1:	c6 00 00             	movb   $0x0,(%eax)
  800cc4:	eb 02                	jmp    800cc8 <strlcpy+0x47>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800cc6:	89 f8                	mov    %edi,%eax
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
		*dst = '\0';
	}
	return dst - dst_in;
  800cc8:	29 f8                	sub    %edi,%eax
}
  800cca:	5b                   	pop    %ebx
  800ccb:	5e                   	pop    %esi
  800ccc:	5f                   	pop    %edi
  800ccd:	c9                   	leave  
  800cce:	c3                   	ret    

00800ccf <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800ccf:	55                   	push   %ebp
  800cd0:	89 e5                	mov    %esp,%ebp
  800cd2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800cd5:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800cd8:	8a 01                	mov    (%ecx),%al
  800cda:	84 c0                	test   %al,%al
  800cdc:	74 10                	je     800cee <strcmp+0x1f>
  800cde:	3a 02                	cmp    (%edx),%al
  800ce0:	75 0c                	jne    800cee <strcmp+0x1f>
		p++, q++;
  800ce2:	41                   	inc    %ecx
  800ce3:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800ce4:	8a 01                	mov    (%ecx),%al
  800ce6:	84 c0                	test   %al,%al
  800ce8:	74 04                	je     800cee <strcmp+0x1f>
  800cea:	3a 02                	cmp    (%edx),%al
  800cec:	74 f4                	je     800ce2 <strcmp+0x13>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800cee:	0f b6 c0             	movzbl %al,%eax
  800cf1:	0f b6 12             	movzbl (%edx),%edx
  800cf4:	29 d0                	sub    %edx,%eax
}
  800cf6:	c9                   	leave  
  800cf7:	c3                   	ret    

00800cf8 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800cf8:	55                   	push   %ebp
  800cf9:	89 e5                	mov    %esp,%ebp
  800cfb:	53                   	push   %ebx
  800cfc:	8b 55 08             	mov    0x8(%ebp),%edx
  800cff:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d02:	8b 45 10             	mov    0x10(%ebp),%eax
	while (n > 0 && *p && *p == *q)
  800d05:	85 c0                	test   %eax,%eax
  800d07:	74 1b                	je     800d24 <strncmp+0x2c>
  800d09:	8a 1a                	mov    (%edx),%bl
  800d0b:	84 db                	test   %bl,%bl
  800d0d:	74 24                	je     800d33 <strncmp+0x3b>
  800d0f:	3a 19                	cmp    (%ecx),%bl
  800d11:	75 20                	jne    800d33 <strncmp+0x3b>
  800d13:	48                   	dec    %eax
  800d14:	74 15                	je     800d2b <strncmp+0x33>
		n--, p++, q++;
  800d16:	42                   	inc    %edx
  800d17:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800d18:	8a 1a                	mov    (%edx),%bl
  800d1a:	84 db                	test   %bl,%bl
  800d1c:	74 15                	je     800d33 <strncmp+0x3b>
  800d1e:	3a 19                	cmp    (%ecx),%bl
  800d20:	74 f1                	je     800d13 <strncmp+0x1b>
  800d22:	eb 0f                	jmp    800d33 <strncmp+0x3b>
		n--, p++, q++;
	if (n == 0)
		return 0;
  800d24:	b8 00 00 00 00       	mov    $0x0,%eax
  800d29:	eb 05                	jmp    800d30 <strncmp+0x38>
  800d2b:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800d30:	5b                   	pop    %ebx
  800d31:	c9                   	leave  
  800d32:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800d33:	0f b6 02             	movzbl (%edx),%eax
  800d36:	0f b6 11             	movzbl (%ecx),%edx
  800d39:	29 d0                	sub    %edx,%eax
  800d3b:	eb f3                	jmp    800d30 <strncmp+0x38>

00800d3d <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800d3d:	55                   	push   %ebp
  800d3e:	89 e5                	mov    %esp,%ebp
  800d40:	8b 45 08             	mov    0x8(%ebp),%eax
  800d43:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800d46:	8a 10                	mov    (%eax),%dl
  800d48:	84 d2                	test   %dl,%dl
  800d4a:	74 18                	je     800d64 <strchr+0x27>
		if (*s == c)
  800d4c:	38 ca                	cmp    %cl,%dl
  800d4e:	75 06                	jne    800d56 <strchr+0x19>
  800d50:	eb 17                	jmp    800d69 <strchr+0x2c>
  800d52:	38 ca                	cmp    %cl,%dl
  800d54:	74 13                	je     800d69 <strchr+0x2c>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800d56:	40                   	inc    %eax
  800d57:	8a 10                	mov    (%eax),%dl
  800d59:	84 d2                	test   %dl,%dl
  800d5b:	75 f5                	jne    800d52 <strchr+0x15>
		if (*s == c)
			return (char *) s;
	return 0;
  800d5d:	b8 00 00 00 00       	mov    $0x0,%eax
  800d62:	eb 05                	jmp    800d69 <strchr+0x2c>
  800d64:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800d69:	c9                   	leave  
  800d6a:	c3                   	ret    

00800d6b <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800d6b:	55                   	push   %ebp
  800d6c:	89 e5                	mov    %esp,%ebp
  800d6e:	8b 45 08             	mov    0x8(%ebp),%eax
  800d71:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800d74:	8a 10                	mov    (%eax),%dl
  800d76:	84 d2                	test   %dl,%dl
  800d78:	74 11                	je     800d8b <strfind+0x20>
		if (*s == c)
  800d7a:	38 ca                	cmp    %cl,%dl
  800d7c:	75 06                	jne    800d84 <strfind+0x19>
  800d7e:	eb 0b                	jmp    800d8b <strfind+0x20>
  800d80:	38 ca                	cmp    %cl,%dl
  800d82:	74 07                	je     800d8b <strfind+0x20>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800d84:	40                   	inc    %eax
  800d85:	8a 10                	mov    (%eax),%dl
  800d87:	84 d2                	test   %dl,%dl
  800d89:	75 f5                	jne    800d80 <strfind+0x15>
		if (*s == c)
			break;
	return (char *) s;
}
  800d8b:	c9                   	leave  
  800d8c:	c3                   	ret    

00800d8d <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800d8d:	55                   	push   %ebp
  800d8e:	89 e5                	mov    %esp,%ebp
  800d90:	57                   	push   %edi
  800d91:	56                   	push   %esi
  800d92:	53                   	push   %ebx
  800d93:	8b 7d 08             	mov    0x8(%ebp),%edi
  800d96:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d99:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800d9c:	85 c9                	test   %ecx,%ecx
  800d9e:	74 30                	je     800dd0 <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800da0:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800da6:	75 25                	jne    800dcd <memset+0x40>
  800da8:	f6 c1 03             	test   $0x3,%cl
  800dab:	75 20                	jne    800dcd <memset+0x40>
		c &= 0xFF;
  800dad:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800db0:	89 d3                	mov    %edx,%ebx
  800db2:	c1 e3 08             	shl    $0x8,%ebx
  800db5:	89 d6                	mov    %edx,%esi
  800db7:	c1 e6 18             	shl    $0x18,%esi
  800dba:	89 d0                	mov    %edx,%eax
  800dbc:	c1 e0 10             	shl    $0x10,%eax
  800dbf:	09 f0                	or     %esi,%eax
  800dc1:	09 d0                	or     %edx,%eax
  800dc3:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800dc5:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800dc8:	fc                   	cld    
  800dc9:	f3 ab                	rep stos %eax,%es:(%edi)
  800dcb:	eb 03                	jmp    800dd0 <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800dcd:	fc                   	cld    
  800dce:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800dd0:	89 f8                	mov    %edi,%eax
  800dd2:	5b                   	pop    %ebx
  800dd3:	5e                   	pop    %esi
  800dd4:	5f                   	pop    %edi
  800dd5:	c9                   	leave  
  800dd6:	c3                   	ret    

00800dd7 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800dd7:	55                   	push   %ebp
  800dd8:	89 e5                	mov    %esp,%ebp
  800dda:	57                   	push   %edi
  800ddb:	56                   	push   %esi
  800ddc:	8b 45 08             	mov    0x8(%ebp),%eax
  800ddf:	8b 75 0c             	mov    0xc(%ebp),%esi
  800de2:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800de5:	39 c6                	cmp    %eax,%esi
  800de7:	73 34                	jae    800e1d <memmove+0x46>
  800de9:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800dec:	39 d0                	cmp    %edx,%eax
  800dee:	73 2d                	jae    800e1d <memmove+0x46>
		s += n;
		d += n;
  800df0:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800df3:	f6 c2 03             	test   $0x3,%dl
  800df6:	75 1b                	jne    800e13 <memmove+0x3c>
  800df8:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800dfe:	75 13                	jne    800e13 <memmove+0x3c>
  800e00:	f6 c1 03             	test   $0x3,%cl
  800e03:	75 0e                	jne    800e13 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800e05:	83 ef 04             	sub    $0x4,%edi
  800e08:	8d 72 fc             	lea    -0x4(%edx),%esi
  800e0b:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800e0e:	fd                   	std    
  800e0f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800e11:	eb 07                	jmp    800e1a <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800e13:	4f                   	dec    %edi
  800e14:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800e17:	fd                   	std    
  800e18:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800e1a:	fc                   	cld    
  800e1b:	eb 20                	jmp    800e3d <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800e1d:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800e23:	75 13                	jne    800e38 <memmove+0x61>
  800e25:	a8 03                	test   $0x3,%al
  800e27:	75 0f                	jne    800e38 <memmove+0x61>
  800e29:	f6 c1 03             	test   $0x3,%cl
  800e2c:	75 0a                	jne    800e38 <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800e2e:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800e31:	89 c7                	mov    %eax,%edi
  800e33:	fc                   	cld    
  800e34:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800e36:	eb 05                	jmp    800e3d <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800e38:	89 c7                	mov    %eax,%edi
  800e3a:	fc                   	cld    
  800e3b:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800e3d:	5e                   	pop    %esi
  800e3e:	5f                   	pop    %edi
  800e3f:	c9                   	leave  
  800e40:	c3                   	ret    

00800e41 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800e41:	55                   	push   %ebp
  800e42:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800e44:	ff 75 10             	pushl  0x10(%ebp)
  800e47:	ff 75 0c             	pushl  0xc(%ebp)
  800e4a:	ff 75 08             	pushl  0x8(%ebp)
  800e4d:	e8 85 ff ff ff       	call   800dd7 <memmove>
}
  800e52:	c9                   	leave  
  800e53:	c3                   	ret    

00800e54 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800e54:	55                   	push   %ebp
  800e55:	89 e5                	mov    %esp,%ebp
  800e57:	57                   	push   %edi
  800e58:	56                   	push   %esi
  800e59:	53                   	push   %ebx
  800e5a:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800e5d:	8b 75 0c             	mov    0xc(%ebp),%esi
  800e60:	8b 7d 10             	mov    0x10(%ebp),%edi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800e63:	85 ff                	test   %edi,%edi
  800e65:	74 32                	je     800e99 <memcmp+0x45>
		if (*s1 != *s2)
  800e67:	8a 03                	mov    (%ebx),%al
  800e69:	8a 0e                	mov    (%esi),%cl
  800e6b:	38 c8                	cmp    %cl,%al
  800e6d:	74 19                	je     800e88 <memcmp+0x34>
  800e6f:	eb 0d                	jmp    800e7e <memcmp+0x2a>
  800e71:	8a 44 13 01          	mov    0x1(%ebx,%edx,1),%al
  800e75:	8a 4c 16 01          	mov    0x1(%esi,%edx,1),%cl
  800e79:	42                   	inc    %edx
  800e7a:	38 c8                	cmp    %cl,%al
  800e7c:	74 10                	je     800e8e <memcmp+0x3a>
			return (int) *s1 - (int) *s2;
  800e7e:	0f b6 c0             	movzbl %al,%eax
  800e81:	0f b6 c9             	movzbl %cl,%ecx
  800e84:	29 c8                	sub    %ecx,%eax
  800e86:	eb 16                	jmp    800e9e <memcmp+0x4a>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800e88:	4f                   	dec    %edi
  800e89:	ba 00 00 00 00       	mov    $0x0,%edx
  800e8e:	39 fa                	cmp    %edi,%edx
  800e90:	75 df                	jne    800e71 <memcmp+0x1d>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800e92:	b8 00 00 00 00       	mov    $0x0,%eax
  800e97:	eb 05                	jmp    800e9e <memcmp+0x4a>
  800e99:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800e9e:	5b                   	pop    %ebx
  800e9f:	5e                   	pop    %esi
  800ea0:	5f                   	pop    %edi
  800ea1:	c9                   	leave  
  800ea2:	c3                   	ret    

00800ea3 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800ea3:	55                   	push   %ebp
  800ea4:	89 e5                	mov    %esp,%ebp
  800ea6:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800ea9:	89 c2                	mov    %eax,%edx
  800eab:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800eae:	39 d0                	cmp    %edx,%eax
  800eb0:	73 12                	jae    800ec4 <memfind+0x21>
		if (*(const unsigned char *) s == (unsigned char) c)
  800eb2:	8a 4d 0c             	mov    0xc(%ebp),%cl
  800eb5:	38 08                	cmp    %cl,(%eax)
  800eb7:	75 06                	jne    800ebf <memfind+0x1c>
  800eb9:	eb 09                	jmp    800ec4 <memfind+0x21>
  800ebb:	38 08                	cmp    %cl,(%eax)
  800ebd:	74 05                	je     800ec4 <memfind+0x21>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800ebf:	40                   	inc    %eax
  800ec0:	39 c2                	cmp    %eax,%edx
  800ec2:	77 f7                	ja     800ebb <memfind+0x18>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800ec4:	c9                   	leave  
  800ec5:	c3                   	ret    

00800ec6 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800ec6:	55                   	push   %ebp
  800ec7:	89 e5                	mov    %esp,%ebp
  800ec9:	57                   	push   %edi
  800eca:	56                   	push   %esi
  800ecb:	53                   	push   %ebx
  800ecc:	8b 55 08             	mov    0x8(%ebp),%edx
  800ecf:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800ed2:	eb 01                	jmp    800ed5 <strtol+0xf>
		s++;
  800ed4:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800ed5:	8a 02                	mov    (%edx),%al
  800ed7:	3c 20                	cmp    $0x20,%al
  800ed9:	74 f9                	je     800ed4 <strtol+0xe>
  800edb:	3c 09                	cmp    $0x9,%al
  800edd:	74 f5                	je     800ed4 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800edf:	3c 2b                	cmp    $0x2b,%al
  800ee1:	75 08                	jne    800eeb <strtol+0x25>
		s++;
  800ee3:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800ee4:	bf 00 00 00 00       	mov    $0x0,%edi
  800ee9:	eb 13                	jmp    800efe <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800eeb:	3c 2d                	cmp    $0x2d,%al
  800eed:	75 0a                	jne    800ef9 <strtol+0x33>
		s++, neg = 1;
  800eef:	8d 52 01             	lea    0x1(%edx),%edx
  800ef2:	bf 01 00 00 00       	mov    $0x1,%edi
  800ef7:	eb 05                	jmp    800efe <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800ef9:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800efe:	85 db                	test   %ebx,%ebx
  800f00:	74 05                	je     800f07 <strtol+0x41>
  800f02:	83 fb 10             	cmp    $0x10,%ebx
  800f05:	75 28                	jne    800f2f <strtol+0x69>
  800f07:	8a 02                	mov    (%edx),%al
  800f09:	3c 30                	cmp    $0x30,%al
  800f0b:	75 10                	jne    800f1d <strtol+0x57>
  800f0d:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800f11:	75 0a                	jne    800f1d <strtol+0x57>
		s += 2, base = 16;
  800f13:	83 c2 02             	add    $0x2,%edx
  800f16:	bb 10 00 00 00       	mov    $0x10,%ebx
  800f1b:	eb 12                	jmp    800f2f <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  800f1d:	85 db                	test   %ebx,%ebx
  800f1f:	75 0e                	jne    800f2f <strtol+0x69>
  800f21:	3c 30                	cmp    $0x30,%al
  800f23:	75 05                	jne    800f2a <strtol+0x64>
		s++, base = 8;
  800f25:	42                   	inc    %edx
  800f26:	b3 08                	mov    $0x8,%bl
  800f28:	eb 05                	jmp    800f2f <strtol+0x69>
	else if (base == 0)
		base = 10;
  800f2a:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800f2f:	b8 00 00 00 00       	mov    $0x0,%eax
  800f34:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800f36:	8a 0a                	mov    (%edx),%cl
  800f38:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800f3b:	80 fb 09             	cmp    $0x9,%bl
  800f3e:	77 08                	ja     800f48 <strtol+0x82>
			dig = *s - '0';
  800f40:	0f be c9             	movsbl %cl,%ecx
  800f43:	83 e9 30             	sub    $0x30,%ecx
  800f46:	eb 1e                	jmp    800f66 <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  800f48:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800f4b:	80 fb 19             	cmp    $0x19,%bl
  800f4e:	77 08                	ja     800f58 <strtol+0x92>
			dig = *s - 'a' + 10;
  800f50:	0f be c9             	movsbl %cl,%ecx
  800f53:	83 e9 57             	sub    $0x57,%ecx
  800f56:	eb 0e                	jmp    800f66 <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  800f58:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800f5b:	80 fb 19             	cmp    $0x19,%bl
  800f5e:	77 13                	ja     800f73 <strtol+0xad>
			dig = *s - 'A' + 10;
  800f60:	0f be c9             	movsbl %cl,%ecx
  800f63:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800f66:	39 f1                	cmp    %esi,%ecx
  800f68:	7d 0d                	jge    800f77 <strtol+0xb1>
			break;
		s++, val = (val * base) + dig;
  800f6a:	42                   	inc    %edx
  800f6b:	0f af c6             	imul   %esi,%eax
  800f6e:	8d 04 01             	lea    (%ecx,%eax,1),%eax
		// we don't properly detect overflow!
	}
  800f71:	eb c3                	jmp    800f36 <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800f73:	89 c1                	mov    %eax,%ecx
  800f75:	eb 02                	jmp    800f79 <strtol+0xb3>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800f77:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800f79:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800f7d:	74 05                	je     800f84 <strtol+0xbe>
		*endptr = (char *) s;
  800f7f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800f82:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800f84:	85 ff                	test   %edi,%edi
  800f86:	74 04                	je     800f8c <strtol+0xc6>
  800f88:	89 c8                	mov    %ecx,%eax
  800f8a:	f7 d8                	neg    %eax
}
  800f8c:	5b                   	pop    %ebx
  800f8d:	5e                   	pop    %esi
  800f8e:	5f                   	pop    %edi
  800f8f:	c9                   	leave  
  800f90:	c3                   	ret    
  800f91:	00 00                	add    %al,(%eax)
	...

00800f94 <syscall>:
	return ret;
}

static int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  800f94:	55                   	push   %ebp
  800f95:	89 e5                	mov    %esp,%ebp
  800f97:	57                   	push   %edi
  800f98:	56                   	push   %esi
  800f99:	53                   	push   %ebx
  800f9a:	83 ec 1c             	sub    $0x1c,%esp
  800f9d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800fa0:	89 55 e0             	mov    %edx,-0x20(%ebp)
  800fa3:	89 ca                	mov    %ecx,%edx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800fa5:	8b 75 14             	mov    0x14(%ebp),%esi
  800fa8:	8b 7d 10             	mov    0x10(%ebp),%edi
  800fab:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800fae:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800fb1:	cd 30                	int    $0x30
  800fb3:	89 c2                	mov    %eax,%edx
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800fb5:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800fb9:	74 1c                	je     800fd7 <syscall+0x43>
  800fbb:	85 c0                	test   %eax,%eax
  800fbd:	7e 18                	jle    800fd7 <syscall+0x43>
		panic("syscall %d returned %d (> 0)", num, ret);
  800fbf:	83 ec 0c             	sub    $0xc,%esp
  800fc2:	50                   	push   %eax
  800fc3:	ff 75 e4             	pushl  -0x1c(%ebp)
  800fc6:	68 7f 27 80 00       	push   $0x80277f
  800fcb:	6a 42                	push   $0x42
  800fcd:	68 9c 27 80 00       	push   $0x80279c
  800fd2:	e8 b1 f5 ff ff       	call   800588 <_panic>

	return ret;
}
  800fd7:	89 d0                	mov    %edx,%eax
  800fd9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800fdc:	5b                   	pop    %ebx
  800fdd:	5e                   	pop    %esi
  800fde:	5f                   	pop    %edi
  800fdf:	c9                   	leave  
  800fe0:	c3                   	ret    

00800fe1 <sys_cputs>:

void
sys_cputs(const char *s, size_t len)
{	
  800fe1:	55                   	push   %ebp
  800fe2:	89 e5                	mov    %esp,%ebp
  800fe4:	83 ec 08             	sub    $0x8,%esp
	// my_sysenter(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
	// return;
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
  800fe7:	6a 00                	push   $0x0
  800fe9:	6a 00                	push   $0x0
  800feb:	6a 00                	push   $0x0
  800fed:	ff 75 0c             	pushl  0xc(%ebp)
  800ff0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ff3:	ba 00 00 00 00       	mov    $0x0,%edx
  800ff8:	b8 00 00 00 00       	mov    $0x0,%eax
  800ffd:	e8 92 ff ff ff       	call   800f94 <syscall>
  801002:	83 c4 10             	add    $0x10,%esp
	return;
}
  801005:	c9                   	leave  
  801006:	c3                   	ret    

00801007 <sys_cgetc>:

int
sys_cgetc(void)
{
  801007:	55                   	push   %ebp
  801008:	89 e5                	mov    %esp,%ebp
  80100a:	83 ec 08             	sub    $0x8,%esp
	// return my_sysenter(SYS_cgetc, 0, 0, 0, 0, 0, 0);
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
  80100d:	6a 00                	push   $0x0
  80100f:	6a 00                	push   $0x0
  801011:	6a 00                	push   $0x0
  801013:	6a 00                	push   $0x0
  801015:	b9 00 00 00 00       	mov    $0x0,%ecx
  80101a:	ba 00 00 00 00       	mov    $0x0,%edx
  80101f:	b8 01 00 00 00       	mov    $0x1,%eax
  801024:	e8 6b ff ff ff       	call   800f94 <syscall>
}
  801029:	c9                   	leave  
  80102a:	c3                   	ret    

0080102b <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  80102b:	55                   	push   %ebp
  80102c:	89 e5                	mov    %esp,%ebp
  80102e:	83 ec 08             	sub    $0x8,%esp
	// return my_sysenter(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
  801031:	6a 00                	push   $0x0
  801033:	6a 00                	push   $0x0
  801035:	6a 00                	push   $0x0
  801037:	6a 00                	push   $0x0
  801039:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80103c:	ba 01 00 00 00       	mov    $0x1,%edx
  801041:	b8 03 00 00 00       	mov    $0x3,%eax
  801046:	e8 49 ff ff ff       	call   800f94 <syscall>
}
  80104b:	c9                   	leave  
  80104c:	c3                   	ret    

0080104d <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  80104d:	55                   	push   %ebp
  80104e:	89 e5                	mov    %esp,%ebp
  801050:	83 ec 08             	sub    $0x8,%esp
	// return my_sysenter(SYS_getenvid, 0, 0, 0, 0, 0, 0);
	return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
  801053:	6a 00                	push   $0x0
  801055:	6a 00                	push   $0x0
  801057:	6a 00                	push   $0x0
  801059:	6a 00                	push   $0x0
  80105b:	b9 00 00 00 00       	mov    $0x0,%ecx
  801060:	ba 00 00 00 00       	mov    $0x0,%edx
  801065:	b8 02 00 00 00       	mov    $0x2,%eax
  80106a:	e8 25 ff ff ff       	call   800f94 <syscall>
}
  80106f:	c9                   	leave  
  801070:	c3                   	ret    

00801071 <sys_yield>:

void
sys_yield(void)
{
  801071:	55                   	push   %ebp
  801072:	89 e5                	mov    %esp,%ebp
  801074:	83 ec 08             	sub    $0x8,%esp
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
  801077:	6a 00                	push   $0x0
  801079:	6a 00                	push   $0x0
  80107b:	6a 00                	push   $0x0
  80107d:	6a 00                	push   $0x0
  80107f:	b9 00 00 00 00       	mov    $0x0,%ecx
  801084:	ba 00 00 00 00       	mov    $0x0,%edx
  801089:	b8 0b 00 00 00       	mov    $0xb,%eax
  80108e:	e8 01 ff ff ff       	call   800f94 <syscall>
  801093:	83 c4 10             	add    $0x10,%esp
}
  801096:	c9                   	leave  
  801097:	c3                   	ret    

00801098 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  801098:	55                   	push   %ebp
  801099:	89 e5                	mov    %esp,%ebp
  80109b:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
  80109e:	6a 00                	push   $0x0
  8010a0:	6a 00                	push   $0x0
  8010a2:	ff 75 10             	pushl  0x10(%ebp)
  8010a5:	ff 75 0c             	pushl  0xc(%ebp)
  8010a8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8010ab:	ba 01 00 00 00       	mov    $0x1,%edx
  8010b0:	b8 04 00 00 00       	mov    $0x4,%eax
  8010b5:	e8 da fe ff ff       	call   800f94 <syscall>
}
  8010ba:	c9                   	leave  
  8010bb:	c3                   	ret    

008010bc <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8010bc:	55                   	push   %ebp
  8010bd:	89 e5                	mov    %esp,%ebp
  8010bf:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
  8010c2:	ff 75 18             	pushl  0x18(%ebp)
  8010c5:	ff 75 14             	pushl  0x14(%ebp)
  8010c8:	ff 75 10             	pushl  0x10(%ebp)
  8010cb:	ff 75 0c             	pushl  0xc(%ebp)
  8010ce:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8010d1:	ba 01 00 00 00       	mov    $0x1,%edx
  8010d6:	b8 05 00 00 00       	mov    $0x5,%eax
  8010db:	e8 b4 fe ff ff       	call   800f94 <syscall>
}
  8010e0:	c9                   	leave  
  8010e1:	c3                   	ret    

008010e2 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  8010e2:	55                   	push   %ebp
  8010e3:	89 e5                	mov    %esp,%ebp
  8010e5:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
  8010e8:	6a 00                	push   $0x0
  8010ea:	6a 00                	push   $0x0
  8010ec:	6a 00                	push   $0x0
  8010ee:	ff 75 0c             	pushl  0xc(%ebp)
  8010f1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8010f4:	ba 01 00 00 00       	mov    $0x1,%edx
  8010f9:	b8 06 00 00 00       	mov    $0x6,%eax
  8010fe:	e8 91 fe ff ff       	call   800f94 <syscall>
}
  801103:	c9                   	leave  
  801104:	c3                   	ret    

00801105 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  801105:	55                   	push   %ebp
  801106:	89 e5                	mov    %esp,%ebp
  801108:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
  80110b:	6a 00                	push   $0x0
  80110d:	6a 00                	push   $0x0
  80110f:	6a 00                	push   $0x0
  801111:	ff 75 0c             	pushl  0xc(%ebp)
  801114:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801117:	ba 01 00 00 00       	mov    $0x1,%edx
  80111c:	b8 08 00 00 00       	mov    $0x8,%eax
  801121:	e8 6e fe ff ff       	call   800f94 <syscall>
}
  801126:	c9                   	leave  
  801127:	c3                   	ret    

00801128 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  801128:	55                   	push   %ebp
  801129:	89 e5                	mov    %esp,%ebp
  80112b:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
  80112e:	6a 00                	push   $0x0
  801130:	6a 00                	push   $0x0
  801132:	6a 00                	push   $0x0
  801134:	ff 75 0c             	pushl  0xc(%ebp)
  801137:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80113a:	ba 01 00 00 00       	mov    $0x1,%edx
  80113f:	b8 09 00 00 00       	mov    $0x9,%eax
  801144:	e8 4b fe ff ff       	call   800f94 <syscall>
}
  801149:	c9                   	leave  
  80114a:	c3                   	ret    

0080114b <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  80114b:	55                   	push   %ebp
  80114c:	89 e5                	mov    %esp,%ebp
  80114e:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
  801151:	6a 00                	push   $0x0
  801153:	6a 00                	push   $0x0
  801155:	6a 00                	push   $0x0
  801157:	ff 75 0c             	pushl  0xc(%ebp)
  80115a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80115d:	ba 01 00 00 00       	mov    $0x1,%edx
  801162:	b8 0a 00 00 00       	mov    $0xa,%eax
  801167:	e8 28 fe ff ff       	call   800f94 <syscall>
}
  80116c:	c9                   	leave  
  80116d:	c3                   	ret    

0080116e <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  80116e:	55                   	push   %ebp
  80116f:	89 e5                	mov    %esp,%ebp
  801171:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
  801174:	6a 00                	push   $0x0
  801176:	ff 75 14             	pushl  0x14(%ebp)
  801179:	ff 75 10             	pushl  0x10(%ebp)
  80117c:	ff 75 0c             	pushl  0xc(%ebp)
  80117f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801182:	ba 00 00 00 00       	mov    $0x0,%edx
  801187:	b8 0c 00 00 00       	mov    $0xc,%eax
  80118c:	e8 03 fe ff ff       	call   800f94 <syscall>
}
  801191:	c9                   	leave  
  801192:	c3                   	ret    

00801193 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  801193:	55                   	push   %ebp
  801194:	89 e5                	mov    %esp,%ebp
  801196:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
  801199:	6a 00                	push   $0x0
  80119b:	6a 00                	push   $0x0
  80119d:	6a 00                	push   $0x0
  80119f:	6a 00                	push   $0x0
  8011a1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8011a4:	ba 01 00 00 00       	mov    $0x1,%edx
  8011a9:	b8 0d 00 00 00       	mov    $0xd,%eax
  8011ae:	e8 e1 fd ff ff       	call   800f94 <syscall>
}
  8011b3:	c9                   	leave  
  8011b4:	c3                   	ret    

008011b5 <sys_set_priority>:

int
sys_set_priority(envid_t envid, uint32_t new_priority)
{
  8011b5:	55                   	push   %ebp
  8011b6:	89 e5                	mov    %esp,%ebp
  8011b8:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_set_priority, 0, envid, new_priority, 0, 0, 0);
  8011bb:	6a 00                	push   $0x0
  8011bd:	6a 00                	push   $0x0
  8011bf:	6a 00                	push   $0x0
  8011c1:	ff 75 0c             	pushl  0xc(%ebp)
  8011c4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8011c7:	ba 00 00 00 00       	mov    $0x0,%edx
  8011cc:	b8 0e 00 00 00       	mov    $0xe,%eax
  8011d1:	e8 be fd ff ff       	call   800f94 <syscall>
}
  8011d6:	c9                   	leave  
  8011d7:	c3                   	ret    

008011d8 <sys_exec>:

int
sys_exec(uint32_t eip, uint32_t esp, void * ph, uint32_t elf_phnum)
{
  8011d8:	55                   	push   %ebp
  8011d9:	89 e5                	mov    %esp,%ebp
  8011db:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_exec, 0, eip, esp, (uint32_t)ph, elf_phnum, 0);
  8011de:	6a 00                	push   $0x0
  8011e0:	ff 75 14             	pushl  0x14(%ebp)
  8011e3:	ff 75 10             	pushl  0x10(%ebp)
  8011e6:	ff 75 0c             	pushl  0xc(%ebp)
  8011e9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8011ec:	ba 00 00 00 00       	mov    $0x0,%edx
  8011f1:	b8 0f 00 00 00       	mov    $0xf,%eax
  8011f6:	e8 99 fd ff ff       	call   800f94 <syscall>
} 
  8011fb:	c9                   	leave  
  8011fc:	c3                   	ret    

008011fd <sys_join>:

// thread:
int
sys_join(envid_t envid)
{
  8011fd:	55                   	push   %ebp
  8011fe:	89 e5                	mov    %esp,%ebp
  801200:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_join, 0, envid, 0, 0, 0, 0);
  801203:	6a 00                	push   $0x0
  801205:	6a 00                	push   $0x0
  801207:	6a 00                	push   $0x0
  801209:	6a 00                	push   $0x0
  80120b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80120e:	ba 00 00 00 00       	mov    $0x0,%edx
  801213:	b8 11 00 00 00       	mov    $0x11,%eax
  801218:	e8 77 fd ff ff       	call   800f94 <syscall>
}
  80121d:	c9                   	leave  
  80121e:	c3                   	ret    

0080121f <sys_getpid>:

envid_t
sys_getpid(void)
{
  80121f:	55                   	push   %ebp
  801220:	89 e5                	mov    %esp,%ebp
  801222:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_getpid, 0, 0, 0, 0, 0, 0);
  801225:	6a 00                	push   $0x0
  801227:	6a 00                	push   $0x0
  801229:	6a 00                	push   $0x0
  80122b:	6a 00                	push   $0x0
  80122d:	b9 00 00 00 00       	mov    $0x0,%ecx
  801232:	ba 00 00 00 00       	mov    $0x0,%edx
  801237:	b8 10 00 00 00       	mov    $0x10,%eax
  80123c:	e8 53 fd ff ff       	call   800f94 <syscall>
  801241:	c9                   	leave  
  801242:	c3                   	ret    
	...

00801244 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801244:	55                   	push   %ebp
  801245:	89 e5                	mov    %esp,%ebp
  801247:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  80124a:	83 3d b4 40 80 00 00 	cmpl   $0x0,0x8040b4
  801251:	75 52                	jne    8012a5 <set_pgfault_handler+0x61>
		// First time through!	
		// LAB 4: Your code here.

		//int sys_page_alloc(envid_t envid, void *va, int perm)
		r = sys_page_alloc(0, (void*)(UXSTACKTOP - PGSIZE), PTE_U | PTE_W | PTE_P);
  801253:	83 ec 04             	sub    $0x4,%esp
  801256:	6a 07                	push   $0x7
  801258:	68 00 f0 bf ee       	push   $0xeebff000
  80125d:	6a 00                	push   $0x0
  80125f:	e8 34 fe ff ff       	call   801098 <sys_page_alloc>
		if (r < 0) {
  801264:	83 c4 10             	add    $0x10,%esp
  801267:	85 c0                	test   %eax,%eax
  801269:	79 12                	jns    80127d <set_pgfault_handler+0x39>
			panic("sys_page_alloc error : %e\n", r);
  80126b:	50                   	push   %eax
  80126c:	68 aa 27 80 00       	push   $0x8027aa
  801271:	6a 24                	push   $0x24
  801273:	68 c5 27 80 00       	push   $0x8027c5
  801278:	e8 0b f3 ff ff       	call   800588 <_panic>
		}

		// how to know envid, put 0, envid2env will help us to get curenv in syscall
		r = sys_env_set_pgfault_upcall(0, _pgfault_upcall);		
  80127d:	83 ec 08             	sub    $0x8,%esp
  801280:	68 b0 12 80 00       	push   $0x8012b0
  801285:	6a 00                	push   $0x0
  801287:	e8 bf fe ff ff       	call   80114b <sys_env_set_pgfault_upcall>
		if (r < 0) {
  80128c:	83 c4 10             	add    $0x10,%esp
  80128f:	85 c0                	test   %eax,%eax
  801291:	79 12                	jns    8012a5 <set_pgfault_handler+0x61>
			panic("sys_env_set_pgfault_upcall error : %e\n", r);
  801293:	50                   	push   %eax
  801294:	68 d4 27 80 00       	push   $0x8027d4
  801299:	6a 2a                	push   $0x2a
  80129b:	68 c5 27 80 00       	push   $0x8027c5
  8012a0:	e8 e3 f2 ff ff       	call   800588 <_panic>
		}
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  8012a5:	8b 45 08             	mov    0x8(%ebp),%eax
  8012a8:	a3 b4 40 80 00       	mov    %eax,0x8040b4
}
  8012ad:	c9                   	leave  
  8012ae:	c3                   	ret    
	...

008012b0 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  8012b0:	54                   	push   %esp
	movl _pgfault_handler, %eax
  8012b1:	a1 b4 40 80 00       	mov    0x8040b4,%eax
	call *%eax
  8012b6:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  8012b8:	83 c4 04             	add    $0x4,%esp
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	
	// fix old esp
	movl 0x30(%esp), %eax
  8012bb:	8b 44 24 30          	mov    0x30(%esp),%eax
	subl $0x4, %eax
  8012bf:	83 e8 04             	sub    $0x4,%eax
	movl %eax, 0x30(%esp)
  8012c2:	89 44 24 30          	mov    %eax,0x30(%esp)

	// set trap-time %eip
	movl 0x28(%esp), %ebx
  8012c6:	8b 5c 24 28          	mov    0x28(%esp),%ebx
	movl %ebx, (%eax)
  8012ca:	89 18                	mov    %ebx,(%eax)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	addl $0x08, %esp 	// ignore err_code and fault_va
  8012cc:	83 c4 08             	add    $0x8,%esp
	popal 				// restore registers
  8012cf:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $0x04, %esp 	// ignore eip 
  8012d0:	83 c4 04             	add    $0x4,%esp
	popfl				// modify eflags
  8012d3:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp
  8012d4:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  8012d5:	c3                   	ret    
	...

008012d8 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8012d8:	55                   	push   %ebp
  8012d9:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8012db:	8b 45 08             	mov    0x8(%ebp),%eax
  8012de:	05 00 00 00 30       	add    $0x30000000,%eax
  8012e3:	c1 e8 0c             	shr    $0xc,%eax
}
  8012e6:	c9                   	leave  
  8012e7:	c3                   	ret    

008012e8 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8012e8:	55                   	push   %ebp
  8012e9:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  8012eb:	ff 75 08             	pushl  0x8(%ebp)
  8012ee:	e8 e5 ff ff ff       	call   8012d8 <fd2num>
  8012f3:	83 c4 04             	add    $0x4,%esp
  8012f6:	05 20 00 0d 00       	add    $0xd0020,%eax
  8012fb:	c1 e0 0c             	shl    $0xc,%eax
}
  8012fe:	c9                   	leave  
  8012ff:	c3                   	ret    

00801300 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801300:	55                   	push   %ebp
  801301:	89 e5                	mov    %esp,%ebp
  801303:	53                   	push   %ebx
  801304:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801307:	a1 00 dd 7b ef       	mov    0xef7bdd00,%eax
  80130c:	a8 01                	test   $0x1,%al
  80130e:	74 34                	je     801344 <fd_alloc+0x44>
  801310:	a1 00 00 74 ef       	mov    0xef740000,%eax
  801315:	a8 01                	test   $0x1,%al
  801317:	74 32                	je     80134b <fd_alloc+0x4b>
  801319:	b8 00 10 00 d0       	mov    $0xd0001000,%eax
  80131e:	89 c1                	mov    %eax,%ecx
  801320:	89 c2                	mov    %eax,%edx
  801322:	c1 ea 16             	shr    $0x16,%edx
  801325:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80132c:	f6 c2 01             	test   $0x1,%dl
  80132f:	74 1f                	je     801350 <fd_alloc+0x50>
  801331:	89 c2                	mov    %eax,%edx
  801333:	c1 ea 0c             	shr    $0xc,%edx
  801336:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80133d:	f6 c2 01             	test   $0x1,%dl
  801340:	75 17                	jne    801359 <fd_alloc+0x59>
  801342:	eb 0c                	jmp    801350 <fd_alloc+0x50>
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  801344:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
  801349:	eb 05                	jmp    801350 <fd_alloc+0x50>
  80134b:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
  801350:	89 0b                	mov    %ecx,(%ebx)
			return 0;
  801352:	b8 00 00 00 00       	mov    $0x0,%eax
  801357:	eb 17                	jmp    801370 <fd_alloc+0x70>
  801359:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  80135e:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  801363:	75 b9                	jne    80131e <fd_alloc+0x1e>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801365:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_MAX_OPEN;
  80136b:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  801370:	5b                   	pop    %ebx
  801371:	c9                   	leave  
  801372:	c3                   	ret    

00801373 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  801373:	55                   	push   %ebp
  801374:	89 e5                	mov    %esp,%ebp
  801376:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801379:	83 f8 1f             	cmp    $0x1f,%eax
  80137c:	77 36                	ja     8013b4 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  80137e:	05 00 00 0d 00       	add    $0xd0000,%eax
  801383:	c1 e0 0c             	shl    $0xc,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801386:	89 c2                	mov    %eax,%edx
  801388:	c1 ea 16             	shr    $0x16,%edx
  80138b:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801392:	f6 c2 01             	test   $0x1,%dl
  801395:	74 24                	je     8013bb <fd_lookup+0x48>
  801397:	89 c2                	mov    %eax,%edx
  801399:	c1 ea 0c             	shr    $0xc,%edx
  80139c:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8013a3:	f6 c2 01             	test   $0x1,%dl
  8013a6:	74 1a                	je     8013c2 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8013a8:	8b 55 0c             	mov    0xc(%ebp),%edx
  8013ab:	89 02                	mov    %eax,(%edx)
	return 0;
  8013ad:	b8 00 00 00 00       	mov    $0x0,%eax
  8013b2:	eb 13                	jmp    8013c7 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8013b4:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8013b9:	eb 0c                	jmp    8013c7 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8013bb:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8013c0:	eb 05                	jmp    8013c7 <fd_lookup+0x54>
  8013c2:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  8013c7:	c9                   	leave  
  8013c8:	c3                   	ret    

008013c9 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8013c9:	55                   	push   %ebp
  8013ca:	89 e5                	mov    %esp,%ebp
  8013cc:	53                   	push   %ebx
  8013cd:	83 ec 04             	sub    $0x4,%esp
  8013d0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8013d3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
		if (devtab[i]->dev_id == dev_id) {
  8013d6:	39 0d 04 30 80 00    	cmp    %ecx,0x803004
  8013dc:	74 0d                	je     8013eb <dev_lookup+0x22>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8013de:	b8 00 00 00 00       	mov    $0x0,%eax
  8013e3:	eb 14                	jmp    8013f9 <dev_lookup+0x30>
		if (devtab[i]->dev_id == dev_id) {
  8013e5:	39 0a                	cmp    %ecx,(%edx)
  8013e7:	75 10                	jne    8013f9 <dev_lookup+0x30>
  8013e9:	eb 05                	jmp    8013f0 <dev_lookup+0x27>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8013eb:	ba 04 30 80 00       	mov    $0x803004,%edx
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
  8013f0:	89 13                	mov    %edx,(%ebx)
			return 0;
  8013f2:	b8 00 00 00 00       	mov    $0x0,%eax
  8013f7:	eb 31                	jmp    80142a <dev_lookup+0x61>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8013f9:	40                   	inc    %eax
  8013fa:	8b 14 85 7c 28 80 00 	mov    0x80287c(,%eax,4),%edx
  801401:	85 d2                	test   %edx,%edx
  801403:	75 e0                	jne    8013e5 <dev_lookup+0x1c>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801405:	a1 b0 40 80 00       	mov    0x8040b0,%eax
  80140a:	8b 40 48             	mov    0x48(%eax),%eax
  80140d:	83 ec 04             	sub    $0x4,%esp
  801410:	51                   	push   %ecx
  801411:	50                   	push   %eax
  801412:	68 fc 27 80 00       	push   $0x8027fc
  801417:	e8 44 f2 ff ff       	call   800660 <cprintf>
	*dev = 0;
  80141c:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_INVAL;
  801422:	83 c4 10             	add    $0x10,%esp
  801425:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  80142a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80142d:	c9                   	leave  
  80142e:	c3                   	ret    

0080142f <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  80142f:	55                   	push   %ebp
  801430:	89 e5                	mov    %esp,%ebp
  801432:	56                   	push   %esi
  801433:	53                   	push   %ebx
  801434:	83 ec 20             	sub    $0x20,%esp
  801437:	8b 75 08             	mov    0x8(%ebp),%esi
  80143a:	8a 45 0c             	mov    0xc(%ebp),%al
  80143d:	88 45 e7             	mov    %al,-0x19(%ebp)
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801440:	56                   	push   %esi
  801441:	e8 92 fe ff ff       	call   8012d8 <fd2num>
  801446:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801449:	89 14 24             	mov    %edx,(%esp)
  80144c:	50                   	push   %eax
  80144d:	e8 21 ff ff ff       	call   801373 <fd_lookup>
  801452:	89 c3                	mov    %eax,%ebx
  801454:	83 c4 08             	add    $0x8,%esp
  801457:	85 c0                	test   %eax,%eax
  801459:	78 05                	js     801460 <fd_close+0x31>
	    || fd != fd2)
  80145b:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  80145e:	74 0d                	je     80146d <fd_close+0x3e>
		return (must_exist ? r : 0);
  801460:	80 7d e7 00          	cmpb   $0x0,-0x19(%ebp)
  801464:	75 48                	jne    8014ae <fd_close+0x7f>
  801466:	bb 00 00 00 00       	mov    $0x0,%ebx
  80146b:	eb 41                	jmp    8014ae <fd_close+0x7f>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  80146d:	83 ec 08             	sub    $0x8,%esp
  801470:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801473:	50                   	push   %eax
  801474:	ff 36                	pushl  (%esi)
  801476:	e8 4e ff ff ff       	call   8013c9 <dev_lookup>
  80147b:	89 c3                	mov    %eax,%ebx
  80147d:	83 c4 10             	add    $0x10,%esp
  801480:	85 c0                	test   %eax,%eax
  801482:	78 1c                	js     8014a0 <fd_close+0x71>
		if (dev->dev_close)
  801484:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801487:	8b 40 10             	mov    0x10(%eax),%eax
  80148a:	85 c0                	test   %eax,%eax
  80148c:	74 0d                	je     80149b <fd_close+0x6c>
			r = (*dev->dev_close)(fd);
  80148e:	83 ec 0c             	sub    $0xc,%esp
  801491:	56                   	push   %esi
  801492:	ff d0                	call   *%eax
  801494:	89 c3                	mov    %eax,%ebx
  801496:	83 c4 10             	add    $0x10,%esp
  801499:	eb 05                	jmp    8014a0 <fd_close+0x71>
		else
			r = 0;
  80149b:	bb 00 00 00 00       	mov    $0x0,%ebx
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8014a0:	83 ec 08             	sub    $0x8,%esp
  8014a3:	56                   	push   %esi
  8014a4:	6a 00                	push   $0x0
  8014a6:	e8 37 fc ff ff       	call   8010e2 <sys_page_unmap>
	return r;
  8014ab:	83 c4 10             	add    $0x10,%esp
}
  8014ae:	89 d8                	mov    %ebx,%eax
  8014b0:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8014b3:	5b                   	pop    %ebx
  8014b4:	5e                   	pop    %esi
  8014b5:	c9                   	leave  
  8014b6:	c3                   	ret    

008014b7 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8014b7:	55                   	push   %ebp
  8014b8:	89 e5                	mov    %esp,%ebp
  8014ba:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8014bd:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014c0:	50                   	push   %eax
  8014c1:	ff 75 08             	pushl  0x8(%ebp)
  8014c4:	e8 aa fe ff ff       	call   801373 <fd_lookup>
  8014c9:	83 c4 08             	add    $0x8,%esp
  8014cc:	85 c0                	test   %eax,%eax
  8014ce:	78 10                	js     8014e0 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  8014d0:	83 ec 08             	sub    $0x8,%esp
  8014d3:	6a 01                	push   $0x1
  8014d5:	ff 75 f4             	pushl  -0xc(%ebp)
  8014d8:	e8 52 ff ff ff       	call   80142f <fd_close>
  8014dd:	83 c4 10             	add    $0x10,%esp
}
  8014e0:	c9                   	leave  
  8014e1:	c3                   	ret    

008014e2 <close_all>:

void
close_all(void)
{
  8014e2:	55                   	push   %ebp
  8014e3:	89 e5                	mov    %esp,%ebp
  8014e5:	53                   	push   %ebx
  8014e6:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8014e9:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8014ee:	83 ec 0c             	sub    $0xc,%esp
  8014f1:	53                   	push   %ebx
  8014f2:	e8 c0 ff ff ff       	call   8014b7 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  8014f7:	43                   	inc    %ebx
  8014f8:	83 c4 10             	add    $0x10,%esp
  8014fb:	83 fb 20             	cmp    $0x20,%ebx
  8014fe:	75 ee                	jne    8014ee <close_all+0xc>
		close(i);
}
  801500:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801503:	c9                   	leave  
  801504:	c3                   	ret    

00801505 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801505:	55                   	push   %ebp
  801506:	89 e5                	mov    %esp,%ebp
  801508:	57                   	push   %edi
  801509:	56                   	push   %esi
  80150a:	53                   	push   %ebx
  80150b:	83 ec 2c             	sub    $0x2c,%esp
  80150e:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801511:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801514:	50                   	push   %eax
  801515:	ff 75 08             	pushl  0x8(%ebp)
  801518:	e8 56 fe ff ff       	call   801373 <fd_lookup>
  80151d:	89 c3                	mov    %eax,%ebx
  80151f:	83 c4 08             	add    $0x8,%esp
  801522:	85 c0                	test   %eax,%eax
  801524:	0f 88 c0 00 00 00    	js     8015ea <dup+0xe5>
		return r;
	close(newfdnum);
  80152a:	83 ec 0c             	sub    $0xc,%esp
  80152d:	57                   	push   %edi
  80152e:	e8 84 ff ff ff       	call   8014b7 <close>

	newfd = INDEX2FD(newfdnum);
  801533:	8d b7 00 00 0d 00    	lea    0xd0000(%edi),%esi
  801539:	c1 e6 0c             	shl    $0xc,%esi
	ova = fd2data(oldfd);
  80153c:	83 c4 04             	add    $0x4,%esp
  80153f:	ff 75 e4             	pushl  -0x1c(%ebp)
  801542:	e8 a1 fd ff ff       	call   8012e8 <fd2data>
  801547:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  801549:	89 34 24             	mov    %esi,(%esp)
  80154c:	e8 97 fd ff ff       	call   8012e8 <fd2data>
  801551:	83 c4 10             	add    $0x10,%esp
  801554:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801557:	89 d8                	mov    %ebx,%eax
  801559:	c1 e8 16             	shr    $0x16,%eax
  80155c:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801563:	a8 01                	test   $0x1,%al
  801565:	74 37                	je     80159e <dup+0x99>
  801567:	89 d8                	mov    %ebx,%eax
  801569:	c1 e8 0c             	shr    $0xc,%eax
  80156c:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801573:	f6 c2 01             	test   $0x1,%dl
  801576:	74 26                	je     80159e <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801578:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80157f:	83 ec 0c             	sub    $0xc,%esp
  801582:	25 07 0e 00 00       	and    $0xe07,%eax
  801587:	50                   	push   %eax
  801588:	ff 75 d4             	pushl  -0x2c(%ebp)
  80158b:	6a 00                	push   $0x0
  80158d:	53                   	push   %ebx
  80158e:	6a 00                	push   $0x0
  801590:	e8 27 fb ff ff       	call   8010bc <sys_page_map>
  801595:	89 c3                	mov    %eax,%ebx
  801597:	83 c4 20             	add    $0x20,%esp
  80159a:	85 c0                	test   %eax,%eax
  80159c:	78 2d                	js     8015cb <dup+0xc6>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80159e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8015a1:	89 c2                	mov    %eax,%edx
  8015a3:	c1 ea 0c             	shr    $0xc,%edx
  8015a6:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8015ad:	83 ec 0c             	sub    $0xc,%esp
  8015b0:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  8015b6:	52                   	push   %edx
  8015b7:	56                   	push   %esi
  8015b8:	6a 00                	push   $0x0
  8015ba:	50                   	push   %eax
  8015bb:	6a 00                	push   $0x0
  8015bd:	e8 fa fa ff ff       	call   8010bc <sys_page_map>
  8015c2:	89 c3                	mov    %eax,%ebx
  8015c4:	83 c4 20             	add    $0x20,%esp
  8015c7:	85 c0                	test   %eax,%eax
  8015c9:	79 1d                	jns    8015e8 <dup+0xe3>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8015cb:	83 ec 08             	sub    $0x8,%esp
  8015ce:	56                   	push   %esi
  8015cf:	6a 00                	push   $0x0
  8015d1:	e8 0c fb ff ff       	call   8010e2 <sys_page_unmap>
	sys_page_unmap(0, nva);
  8015d6:	83 c4 08             	add    $0x8,%esp
  8015d9:	ff 75 d4             	pushl  -0x2c(%ebp)
  8015dc:	6a 00                	push   $0x0
  8015de:	e8 ff fa ff ff       	call   8010e2 <sys_page_unmap>
	return r;
  8015e3:	83 c4 10             	add    $0x10,%esp
  8015e6:	eb 02                	jmp    8015ea <dup+0xe5>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
		goto err;

	return newfdnum;
  8015e8:	89 fb                	mov    %edi,%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  8015ea:	89 d8                	mov    %ebx,%eax
  8015ec:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8015ef:	5b                   	pop    %ebx
  8015f0:	5e                   	pop    %esi
  8015f1:	5f                   	pop    %edi
  8015f2:	c9                   	leave  
  8015f3:	c3                   	ret    

008015f4 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8015f4:	55                   	push   %ebp
  8015f5:	89 e5                	mov    %esp,%ebp
  8015f7:	53                   	push   %ebx
  8015f8:	83 ec 14             	sub    $0x14,%esp
  8015fb:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8015fe:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801601:	50                   	push   %eax
  801602:	53                   	push   %ebx
  801603:	e8 6b fd ff ff       	call   801373 <fd_lookup>
  801608:	83 c4 08             	add    $0x8,%esp
  80160b:	85 c0                	test   %eax,%eax
  80160d:	78 67                	js     801676 <read+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80160f:	83 ec 08             	sub    $0x8,%esp
  801612:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801615:	50                   	push   %eax
  801616:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801619:	ff 30                	pushl  (%eax)
  80161b:	e8 a9 fd ff ff       	call   8013c9 <dev_lookup>
  801620:	83 c4 10             	add    $0x10,%esp
  801623:	85 c0                	test   %eax,%eax
  801625:	78 4f                	js     801676 <read+0x82>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801627:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80162a:	8b 50 08             	mov    0x8(%eax),%edx
  80162d:	83 e2 03             	and    $0x3,%edx
  801630:	83 fa 01             	cmp    $0x1,%edx
  801633:	75 21                	jne    801656 <read+0x62>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801635:	a1 b0 40 80 00       	mov    0x8040b0,%eax
  80163a:	8b 40 48             	mov    0x48(%eax),%eax
  80163d:	83 ec 04             	sub    $0x4,%esp
  801640:	53                   	push   %ebx
  801641:	50                   	push   %eax
  801642:	68 40 28 80 00       	push   $0x802840
  801647:	e8 14 f0 ff ff       	call   800660 <cprintf>
		return -E_INVAL;
  80164c:	83 c4 10             	add    $0x10,%esp
  80164f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801654:	eb 20                	jmp    801676 <read+0x82>
	}
	if (!dev->dev_read)
  801656:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801659:	8b 52 08             	mov    0x8(%edx),%edx
  80165c:	85 d2                	test   %edx,%edx
  80165e:	74 11                	je     801671 <read+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801660:	83 ec 04             	sub    $0x4,%esp
  801663:	ff 75 10             	pushl  0x10(%ebp)
  801666:	ff 75 0c             	pushl  0xc(%ebp)
  801669:	50                   	push   %eax
  80166a:	ff d2                	call   *%edx
  80166c:	83 c4 10             	add    $0x10,%esp
  80166f:	eb 05                	jmp    801676 <read+0x82>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801671:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_read)(fd, buf, n);
}
  801676:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801679:	c9                   	leave  
  80167a:	c3                   	ret    

0080167b <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  80167b:	55                   	push   %ebp
  80167c:	89 e5                	mov    %esp,%ebp
  80167e:	57                   	push   %edi
  80167f:	56                   	push   %esi
  801680:	53                   	push   %ebx
  801681:	83 ec 0c             	sub    $0xc,%esp
  801684:	8b 7d 08             	mov    0x8(%ebp),%edi
  801687:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80168a:	85 f6                	test   %esi,%esi
  80168c:	74 31                	je     8016bf <readn+0x44>
  80168e:	b8 00 00 00 00       	mov    $0x0,%eax
  801693:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = read(fdnum, (char*)buf + tot, n - tot);
  801698:	83 ec 04             	sub    $0x4,%esp
  80169b:	89 f2                	mov    %esi,%edx
  80169d:	29 c2                	sub    %eax,%edx
  80169f:	52                   	push   %edx
  8016a0:	03 45 0c             	add    0xc(%ebp),%eax
  8016a3:	50                   	push   %eax
  8016a4:	57                   	push   %edi
  8016a5:	e8 4a ff ff ff       	call   8015f4 <read>
		if (m < 0)
  8016aa:	83 c4 10             	add    $0x10,%esp
  8016ad:	85 c0                	test   %eax,%eax
  8016af:	78 17                	js     8016c8 <readn+0x4d>
			return m;
		if (m == 0)
  8016b1:	85 c0                	test   %eax,%eax
  8016b3:	74 11                	je     8016c6 <readn+0x4b>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8016b5:	01 c3                	add    %eax,%ebx
  8016b7:	89 d8                	mov    %ebx,%eax
  8016b9:	39 f3                	cmp    %esi,%ebx
  8016bb:	72 db                	jb     801698 <readn+0x1d>
  8016bd:	eb 09                	jmp    8016c8 <readn+0x4d>
  8016bf:	b8 00 00 00 00       	mov    $0x0,%eax
  8016c4:	eb 02                	jmp    8016c8 <readn+0x4d>
		m = read(fdnum, (char*)buf + tot, n - tot);
		if (m < 0)
			return m;
		if (m == 0)
  8016c6:	89 d8                	mov    %ebx,%eax
			break;
	}
	return tot;
}
  8016c8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8016cb:	5b                   	pop    %ebx
  8016cc:	5e                   	pop    %esi
  8016cd:	5f                   	pop    %edi
  8016ce:	c9                   	leave  
  8016cf:	c3                   	ret    

008016d0 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8016d0:	55                   	push   %ebp
  8016d1:	89 e5                	mov    %esp,%ebp
  8016d3:	53                   	push   %ebx
  8016d4:	83 ec 14             	sub    $0x14,%esp
  8016d7:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8016da:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8016dd:	50                   	push   %eax
  8016de:	53                   	push   %ebx
  8016df:	e8 8f fc ff ff       	call   801373 <fd_lookup>
  8016e4:	83 c4 08             	add    $0x8,%esp
  8016e7:	85 c0                	test   %eax,%eax
  8016e9:	78 62                	js     80174d <write+0x7d>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016eb:	83 ec 08             	sub    $0x8,%esp
  8016ee:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016f1:	50                   	push   %eax
  8016f2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016f5:	ff 30                	pushl  (%eax)
  8016f7:	e8 cd fc ff ff       	call   8013c9 <dev_lookup>
  8016fc:	83 c4 10             	add    $0x10,%esp
  8016ff:	85 c0                	test   %eax,%eax
  801701:	78 4a                	js     80174d <write+0x7d>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801703:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801706:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80170a:	75 21                	jne    80172d <write+0x5d>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  80170c:	a1 b0 40 80 00       	mov    0x8040b0,%eax
  801711:	8b 40 48             	mov    0x48(%eax),%eax
  801714:	83 ec 04             	sub    $0x4,%esp
  801717:	53                   	push   %ebx
  801718:	50                   	push   %eax
  801719:	68 5c 28 80 00       	push   $0x80285c
  80171e:	e8 3d ef ff ff       	call   800660 <cprintf>
		return -E_INVAL;
  801723:	83 c4 10             	add    $0x10,%esp
  801726:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80172b:	eb 20                	jmp    80174d <write+0x7d>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80172d:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801730:	8b 52 0c             	mov    0xc(%edx),%edx
  801733:	85 d2                	test   %edx,%edx
  801735:	74 11                	je     801748 <write+0x78>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801737:	83 ec 04             	sub    $0x4,%esp
  80173a:	ff 75 10             	pushl  0x10(%ebp)
  80173d:	ff 75 0c             	pushl  0xc(%ebp)
  801740:	50                   	push   %eax
  801741:	ff d2                	call   *%edx
  801743:	83 c4 10             	add    $0x10,%esp
  801746:	eb 05                	jmp    80174d <write+0x7d>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801748:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  80174d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801750:	c9                   	leave  
  801751:	c3                   	ret    

00801752 <seek>:

int
seek(int fdnum, off_t offset)
{
  801752:	55                   	push   %ebp
  801753:	89 e5                	mov    %esp,%ebp
  801755:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801758:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80175b:	50                   	push   %eax
  80175c:	ff 75 08             	pushl  0x8(%ebp)
  80175f:	e8 0f fc ff ff       	call   801373 <fd_lookup>
  801764:	83 c4 08             	add    $0x8,%esp
  801767:	85 c0                	test   %eax,%eax
  801769:	78 0e                	js     801779 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  80176b:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80176e:	8b 55 0c             	mov    0xc(%ebp),%edx
  801771:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801774:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801779:	c9                   	leave  
  80177a:	c3                   	ret    

0080177b <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  80177b:	55                   	push   %ebp
  80177c:	89 e5                	mov    %esp,%ebp
  80177e:	53                   	push   %ebx
  80177f:	83 ec 14             	sub    $0x14,%esp
  801782:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801785:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801788:	50                   	push   %eax
  801789:	53                   	push   %ebx
  80178a:	e8 e4 fb ff ff       	call   801373 <fd_lookup>
  80178f:	83 c4 08             	add    $0x8,%esp
  801792:	85 c0                	test   %eax,%eax
  801794:	78 5f                	js     8017f5 <ftruncate+0x7a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801796:	83 ec 08             	sub    $0x8,%esp
  801799:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80179c:	50                   	push   %eax
  80179d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8017a0:	ff 30                	pushl  (%eax)
  8017a2:	e8 22 fc ff ff       	call   8013c9 <dev_lookup>
  8017a7:	83 c4 10             	add    $0x10,%esp
  8017aa:	85 c0                	test   %eax,%eax
  8017ac:	78 47                	js     8017f5 <ftruncate+0x7a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8017ae:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8017b1:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8017b5:	75 21                	jne    8017d8 <ftruncate+0x5d>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8017b7:	a1 b0 40 80 00       	mov    0x8040b0,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8017bc:	8b 40 48             	mov    0x48(%eax),%eax
  8017bf:	83 ec 04             	sub    $0x4,%esp
  8017c2:	53                   	push   %ebx
  8017c3:	50                   	push   %eax
  8017c4:	68 1c 28 80 00       	push   $0x80281c
  8017c9:	e8 92 ee ff ff       	call   800660 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8017ce:	83 c4 10             	add    $0x10,%esp
  8017d1:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8017d6:	eb 1d                	jmp    8017f5 <ftruncate+0x7a>
	}
	if (!dev->dev_trunc)
  8017d8:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8017db:	8b 52 18             	mov    0x18(%edx),%edx
  8017de:	85 d2                	test   %edx,%edx
  8017e0:	74 0e                	je     8017f0 <ftruncate+0x75>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8017e2:	83 ec 08             	sub    $0x8,%esp
  8017e5:	ff 75 0c             	pushl  0xc(%ebp)
  8017e8:	50                   	push   %eax
  8017e9:	ff d2                	call   *%edx
  8017eb:	83 c4 10             	add    $0x10,%esp
  8017ee:	eb 05                	jmp    8017f5 <ftruncate+0x7a>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8017f0:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  8017f5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8017f8:	c9                   	leave  
  8017f9:	c3                   	ret    

008017fa <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8017fa:	55                   	push   %ebp
  8017fb:	89 e5                	mov    %esp,%ebp
  8017fd:	53                   	push   %ebx
  8017fe:	83 ec 14             	sub    $0x14,%esp
  801801:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801804:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801807:	50                   	push   %eax
  801808:	ff 75 08             	pushl  0x8(%ebp)
  80180b:	e8 63 fb ff ff       	call   801373 <fd_lookup>
  801810:	83 c4 08             	add    $0x8,%esp
  801813:	85 c0                	test   %eax,%eax
  801815:	78 52                	js     801869 <fstat+0x6f>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801817:	83 ec 08             	sub    $0x8,%esp
  80181a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80181d:	50                   	push   %eax
  80181e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801821:	ff 30                	pushl  (%eax)
  801823:	e8 a1 fb ff ff       	call   8013c9 <dev_lookup>
  801828:	83 c4 10             	add    $0x10,%esp
  80182b:	85 c0                	test   %eax,%eax
  80182d:	78 3a                	js     801869 <fstat+0x6f>
		return r;
	if (!dev->dev_stat)
  80182f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801832:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801836:	74 2c                	je     801864 <fstat+0x6a>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801838:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  80183b:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801842:	00 00 00 
	stat->st_isdir = 0;
  801845:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80184c:	00 00 00 
	stat->st_dev = dev;
  80184f:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801855:	83 ec 08             	sub    $0x8,%esp
  801858:	53                   	push   %ebx
  801859:	ff 75 f0             	pushl  -0x10(%ebp)
  80185c:	ff 50 14             	call   *0x14(%eax)
  80185f:	83 c4 10             	add    $0x10,%esp
  801862:	eb 05                	jmp    801869 <fstat+0x6f>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801864:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801869:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80186c:	c9                   	leave  
  80186d:	c3                   	ret    

0080186e <stat>:

int
stat(const char *path, struct Stat *stat)
{
  80186e:	55                   	push   %ebp
  80186f:	89 e5                	mov    %esp,%ebp
  801871:	56                   	push   %esi
  801872:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801873:	83 ec 08             	sub    $0x8,%esp
  801876:	6a 00                	push   $0x0
  801878:	ff 75 08             	pushl  0x8(%ebp)
  80187b:	e8 78 01 00 00       	call   8019f8 <open>
  801880:	89 c3                	mov    %eax,%ebx
  801882:	83 c4 10             	add    $0x10,%esp
  801885:	85 c0                	test   %eax,%eax
  801887:	78 1b                	js     8018a4 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801889:	83 ec 08             	sub    $0x8,%esp
  80188c:	ff 75 0c             	pushl  0xc(%ebp)
  80188f:	50                   	push   %eax
  801890:	e8 65 ff ff ff       	call   8017fa <fstat>
  801895:	89 c6                	mov    %eax,%esi
	close(fd);
  801897:	89 1c 24             	mov    %ebx,(%esp)
  80189a:	e8 18 fc ff ff       	call   8014b7 <close>
	return r;
  80189f:	83 c4 10             	add    $0x10,%esp
  8018a2:	89 f3                	mov    %esi,%ebx
}
  8018a4:	89 d8                	mov    %ebx,%eax
  8018a6:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8018a9:	5b                   	pop    %ebx
  8018aa:	5e                   	pop    %esi
  8018ab:	c9                   	leave  
  8018ac:	c3                   	ret    
  8018ad:	00 00                	add    %al,(%eax)
	...

008018b0 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8018b0:	55                   	push   %ebp
  8018b1:	89 e5                	mov    %esp,%ebp
  8018b3:	56                   	push   %esi
  8018b4:	53                   	push   %ebx
  8018b5:	89 c3                	mov    %eax,%ebx
  8018b7:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  8018b9:	83 3d ac 40 80 00 00 	cmpl   $0x0,0x8040ac
  8018c0:	75 12                	jne    8018d4 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8018c2:	83 ec 0c             	sub    $0xc,%esp
  8018c5:	6a 01                	push   $0x1
  8018c7:	e8 8a 07 00 00       	call   802056 <ipc_find_env>
  8018cc:	a3 ac 40 80 00       	mov    %eax,0x8040ac
  8018d1:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8018d4:	6a 07                	push   $0x7
  8018d6:	68 00 50 80 00       	push   $0x805000
  8018db:	53                   	push   %ebx
  8018dc:	ff 35 ac 40 80 00    	pushl  0x8040ac
  8018e2:	e8 1a 07 00 00       	call   802001 <ipc_send>
	
	return ipc_recv(NULL, dstva, NULL);
  8018e7:	83 c4 0c             	add    $0xc,%esp
  8018ea:	6a 00                	push   $0x0
  8018ec:	56                   	push   %esi
  8018ed:	6a 00                	push   $0x0
  8018ef:	e8 98 06 00 00       	call   801f8c <ipc_recv>
}
  8018f4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8018f7:	5b                   	pop    %ebx
  8018f8:	5e                   	pop    %esi
  8018f9:	c9                   	leave  
  8018fa:	c3                   	ret    

008018fb <devfile_stat>:
}


static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8018fb:	55                   	push   %ebp
  8018fc:	89 e5                	mov    %esp,%ebp
  8018fe:	53                   	push   %ebx
  8018ff:	83 ec 04             	sub    $0x4,%esp
  801902:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801905:	8b 45 08             	mov    0x8(%ebp),%eax
  801908:	8b 40 0c             	mov    0xc(%eax),%eax
  80190b:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0) {
  801910:	ba 00 00 00 00       	mov    $0x0,%edx
  801915:	b8 05 00 00 00       	mov    $0x5,%eax
  80191a:	e8 91 ff ff ff       	call   8018b0 <fsipc>
  80191f:	85 c0                	test   %eax,%eax
  801921:	78 2c                	js     80194f <devfile_stat+0x54>
		return r;
	}
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801923:	83 ec 08             	sub    $0x8,%esp
  801926:	68 00 50 80 00       	push   $0x805000
  80192b:	53                   	push   %ebx
  80192c:	e8 e5 f2 ff ff       	call   800c16 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801931:	a1 80 50 80 00       	mov    0x805080,%eax
  801936:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  80193c:	a1 84 50 80 00       	mov    0x805084,%eax
  801941:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801947:	83 c4 10             	add    $0x10,%esp
  80194a:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80194f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801952:	c9                   	leave  
  801953:	c3                   	ret    

00801954 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801954:	55                   	push   %ebp
  801955:	89 e5                	mov    %esp,%ebp
  801957:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  80195a:	8b 45 08             	mov    0x8(%ebp),%eax
  80195d:	8b 40 0c             	mov    0xc(%eax),%eax
  801960:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801965:	ba 00 00 00 00       	mov    $0x0,%edx
  80196a:	b8 06 00 00 00       	mov    $0x6,%eax
  80196f:	e8 3c ff ff ff       	call   8018b0 <fsipc>
}
  801974:	c9                   	leave  
  801975:	c3                   	ret    

00801976 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801976:	55                   	push   %ebp
  801977:	89 e5                	mov    %esp,%ebp
  801979:	56                   	push   %esi
  80197a:	53                   	push   %ebx
  80197b:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  80197e:	8b 45 08             	mov    0x8(%ebp),%eax
  801981:	8b 40 0c             	mov    0xc(%eax),%eax
  801984:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801989:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  80198f:	ba 00 00 00 00       	mov    $0x0,%edx
  801994:	b8 03 00 00 00       	mov    $0x3,%eax
  801999:	e8 12 ff ff ff       	call   8018b0 <fsipc>
  80199e:	89 c3                	mov    %eax,%ebx
  8019a0:	85 c0                	test   %eax,%eax
  8019a2:	78 4b                	js     8019ef <devfile_read+0x79>
		return r;
	assert(r <= n);
  8019a4:	39 c6                	cmp    %eax,%esi
  8019a6:	73 16                	jae    8019be <devfile_read+0x48>
  8019a8:	68 8c 28 80 00       	push   $0x80288c
  8019ad:	68 93 28 80 00       	push   $0x802893
  8019b2:	6a 7d                	push   $0x7d
  8019b4:	68 a8 28 80 00       	push   $0x8028a8
  8019b9:	e8 ca eb ff ff       	call   800588 <_panic>
	assert(r <= PGSIZE);
  8019be:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8019c3:	7e 16                	jle    8019db <devfile_read+0x65>
  8019c5:	68 b3 28 80 00       	push   $0x8028b3
  8019ca:	68 93 28 80 00       	push   $0x802893
  8019cf:	6a 7e                	push   $0x7e
  8019d1:	68 a8 28 80 00       	push   $0x8028a8
  8019d6:	e8 ad eb ff ff       	call   800588 <_panic>
	memmove(buf, &fsipcbuf, r);
  8019db:	83 ec 04             	sub    $0x4,%esp
  8019de:	50                   	push   %eax
  8019df:	68 00 50 80 00       	push   $0x805000
  8019e4:	ff 75 0c             	pushl  0xc(%ebp)
  8019e7:	e8 eb f3 ff ff       	call   800dd7 <memmove>
	return r;
  8019ec:	83 c4 10             	add    $0x10,%esp
}
  8019ef:	89 d8                	mov    %ebx,%eax
  8019f1:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8019f4:	5b                   	pop    %ebx
  8019f5:	5e                   	pop    %esi
  8019f6:	c9                   	leave  
  8019f7:	c3                   	ret    

008019f8 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  8019f8:	55                   	push   %ebp
  8019f9:	89 e5                	mov    %esp,%ebp
  8019fb:	56                   	push   %esi
  8019fc:	53                   	push   %ebx
  8019fd:	83 ec 1c             	sub    $0x1c,%esp
  801a00:	8b 75 08             	mov    0x8(%ebp),%esi
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801a03:	56                   	push   %esi
  801a04:	e8 bb f1 ff ff       	call   800bc4 <strlen>
  801a09:	83 c4 10             	add    $0x10,%esp
  801a0c:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801a11:	7f 65                	jg     801a78 <open+0x80>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801a13:	83 ec 0c             	sub    $0xc,%esp
  801a16:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a19:	50                   	push   %eax
  801a1a:	e8 e1 f8 ff ff       	call   801300 <fd_alloc>
  801a1f:	89 c3                	mov    %eax,%ebx
  801a21:	83 c4 10             	add    $0x10,%esp
  801a24:	85 c0                	test   %eax,%eax
  801a26:	78 55                	js     801a7d <open+0x85>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801a28:	83 ec 08             	sub    $0x8,%esp
  801a2b:	56                   	push   %esi
  801a2c:	68 00 50 80 00       	push   $0x805000
  801a31:	e8 e0 f1 ff ff       	call   800c16 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801a36:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a39:	a3 00 54 80 00       	mov    %eax,0x805400



	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801a3e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801a41:	b8 01 00 00 00       	mov    $0x1,%eax
  801a46:	e8 65 fe ff ff       	call   8018b0 <fsipc>
  801a4b:	89 c3                	mov    %eax,%ebx
  801a4d:	83 c4 10             	add    $0x10,%esp
  801a50:	85 c0                	test   %eax,%eax
  801a52:	79 12                	jns    801a66 <open+0x6e>
		fd_close(fd, 0);
  801a54:	83 ec 08             	sub    $0x8,%esp
  801a57:	6a 00                	push   $0x0
  801a59:	ff 75 f4             	pushl  -0xc(%ebp)
  801a5c:	e8 ce f9 ff ff       	call   80142f <fd_close>
		return r;
  801a61:	83 c4 10             	add    $0x10,%esp
  801a64:	eb 17                	jmp    801a7d <open+0x85>
	}

	return fd2num(fd);
  801a66:	83 ec 0c             	sub    $0xc,%esp
  801a69:	ff 75 f4             	pushl  -0xc(%ebp)
  801a6c:	e8 67 f8 ff ff       	call   8012d8 <fd2num>
  801a71:	89 c3                	mov    %eax,%ebx
  801a73:	83 c4 10             	add    $0x10,%esp
  801a76:	eb 05                	jmp    801a7d <open+0x85>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801a78:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801a7d:	89 d8                	mov    %ebx,%eax
  801a7f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a82:	5b                   	pop    %ebx
  801a83:	5e                   	pop    %esi
  801a84:	c9                   	leave  
  801a85:	c3                   	ret    
	...

00801a88 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801a88:	55                   	push   %ebp
  801a89:	89 e5                	mov    %esp,%ebp
  801a8b:	56                   	push   %esi
  801a8c:	53                   	push   %ebx
  801a8d:	8b 75 0c             	mov    0xc(%ebp),%esi
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801a90:	83 ec 0c             	sub    $0xc,%esp
  801a93:	ff 75 08             	pushl  0x8(%ebp)
  801a96:	e8 4d f8 ff ff       	call   8012e8 <fd2data>
  801a9b:	89 c3                	mov    %eax,%ebx
	strcpy(stat->st_name, "<pipe>");
  801a9d:	83 c4 08             	add    $0x8,%esp
  801aa0:	68 bf 28 80 00       	push   $0x8028bf
  801aa5:	56                   	push   %esi
  801aa6:	e8 6b f1 ff ff       	call   800c16 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801aab:	8b 43 04             	mov    0x4(%ebx),%eax
  801aae:	2b 03                	sub    (%ebx),%eax
  801ab0:	89 86 80 00 00 00    	mov    %eax,0x80(%esi)
	stat->st_isdir = 0;
  801ab6:	c7 86 84 00 00 00 00 	movl   $0x0,0x84(%esi)
  801abd:	00 00 00 
	stat->st_dev = &devpipe;
  801ac0:	c7 86 88 00 00 00 20 	movl   $0x803020,0x88(%esi)
  801ac7:	30 80 00 
	return 0;
}
  801aca:	b8 00 00 00 00       	mov    $0x0,%eax
  801acf:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801ad2:	5b                   	pop    %ebx
  801ad3:	5e                   	pop    %esi
  801ad4:	c9                   	leave  
  801ad5:	c3                   	ret    

00801ad6 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801ad6:	55                   	push   %ebp
  801ad7:	89 e5                	mov    %esp,%ebp
  801ad9:	53                   	push   %ebx
  801ada:	83 ec 0c             	sub    $0xc,%esp
  801add:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801ae0:	53                   	push   %ebx
  801ae1:	6a 00                	push   $0x0
  801ae3:	e8 fa f5 ff ff       	call   8010e2 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801ae8:	89 1c 24             	mov    %ebx,(%esp)
  801aeb:	e8 f8 f7 ff ff       	call   8012e8 <fd2data>
  801af0:	83 c4 08             	add    $0x8,%esp
  801af3:	50                   	push   %eax
  801af4:	6a 00                	push   $0x0
  801af6:	e8 e7 f5 ff ff       	call   8010e2 <sys_page_unmap>
}
  801afb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801afe:	c9                   	leave  
  801aff:	c3                   	ret    

00801b00 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801b00:	55                   	push   %ebp
  801b01:	89 e5                	mov    %esp,%ebp
  801b03:	57                   	push   %edi
  801b04:	56                   	push   %esi
  801b05:	53                   	push   %ebx
  801b06:	83 ec 1c             	sub    $0x1c,%esp
  801b09:	89 c7                	mov    %eax,%edi
  801b0b:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801b0e:	a1 b0 40 80 00       	mov    0x8040b0,%eax
  801b13:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801b16:	83 ec 0c             	sub    $0xc,%esp
  801b19:	57                   	push   %edi
  801b1a:	e8 85 05 00 00       	call   8020a4 <pageref>
  801b1f:	89 c6                	mov    %eax,%esi
  801b21:	83 c4 04             	add    $0x4,%esp
  801b24:	ff 75 e4             	pushl  -0x1c(%ebp)
  801b27:	e8 78 05 00 00       	call   8020a4 <pageref>
  801b2c:	83 c4 10             	add    $0x10,%esp
  801b2f:	39 c6                	cmp    %eax,%esi
  801b31:	0f 94 c0             	sete   %al
  801b34:	0f b6 c0             	movzbl %al,%eax
		nn = thisenv->env_runs;
  801b37:	8b 15 b0 40 80 00    	mov    0x8040b0,%edx
  801b3d:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801b40:	39 cb                	cmp    %ecx,%ebx
  801b42:	75 08                	jne    801b4c <_pipeisclosed+0x4c>
			return ret;
		if (n != nn && ret == 1)
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
	}
}
  801b44:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b47:	5b                   	pop    %ebx
  801b48:	5e                   	pop    %esi
  801b49:	5f                   	pop    %edi
  801b4a:	c9                   	leave  
  801b4b:	c3                   	ret    
		n = thisenv->env_runs;
		ret = pageref(fd) == pageref(p);
		nn = thisenv->env_runs;
		if (n == nn)
			return ret;
		if (n != nn && ret == 1)
  801b4c:	83 f8 01             	cmp    $0x1,%eax
  801b4f:	75 bd                	jne    801b0e <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801b51:	8b 42 58             	mov    0x58(%edx),%eax
  801b54:	6a 01                	push   $0x1
  801b56:	50                   	push   %eax
  801b57:	53                   	push   %ebx
  801b58:	68 c6 28 80 00       	push   $0x8028c6
  801b5d:	e8 fe ea ff ff       	call   800660 <cprintf>
  801b62:	83 c4 10             	add    $0x10,%esp
  801b65:	eb a7                	jmp    801b0e <_pipeisclosed+0xe>

00801b67 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801b67:	55                   	push   %ebp
  801b68:	89 e5                	mov    %esp,%ebp
  801b6a:	57                   	push   %edi
  801b6b:	56                   	push   %esi
  801b6c:	53                   	push   %ebx
  801b6d:	83 ec 28             	sub    $0x28,%esp
  801b70:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801b73:	56                   	push   %esi
  801b74:	e8 6f f7 ff ff       	call   8012e8 <fd2data>
  801b79:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801b7b:	83 c4 10             	add    $0x10,%esp
  801b7e:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801b82:	75 4a                	jne    801bce <devpipe_write+0x67>
  801b84:	bf 00 00 00 00       	mov    $0x0,%edi
  801b89:	eb 56                	jmp    801be1 <devpipe_write+0x7a>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801b8b:	89 da                	mov    %ebx,%edx
  801b8d:	89 f0                	mov    %esi,%eax
  801b8f:	e8 6c ff ff ff       	call   801b00 <_pipeisclosed>
  801b94:	85 c0                	test   %eax,%eax
  801b96:	75 4d                	jne    801be5 <devpipe_write+0x7e>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801b98:	e8 d4 f4 ff ff       	call   801071 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801b9d:	8b 43 04             	mov    0x4(%ebx),%eax
  801ba0:	8b 13                	mov    (%ebx),%edx
  801ba2:	83 c2 20             	add    $0x20,%edx
  801ba5:	39 d0                	cmp    %edx,%eax
  801ba7:	73 e2                	jae    801b8b <devpipe_write+0x24>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801ba9:	89 c2                	mov    %eax,%edx
  801bab:	81 e2 1f 00 00 80    	and    $0x8000001f,%edx
  801bb1:	79 05                	jns    801bb8 <devpipe_write+0x51>
  801bb3:	4a                   	dec    %edx
  801bb4:	83 ca e0             	or     $0xffffffe0,%edx
  801bb7:	42                   	inc    %edx
  801bb8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801bbb:	8a 0c 39             	mov    (%ecx,%edi,1),%cl
  801bbe:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801bc2:	40                   	inc    %eax
  801bc3:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801bc6:	47                   	inc    %edi
  801bc7:	39 7d 10             	cmp    %edi,0x10(%ebp)
  801bca:	77 07                	ja     801bd3 <devpipe_write+0x6c>
  801bcc:	eb 13                	jmp    801be1 <devpipe_write+0x7a>
  801bce:	bf 00 00 00 00       	mov    $0x0,%edi
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801bd3:	8b 43 04             	mov    0x4(%ebx),%eax
  801bd6:	8b 13                	mov    (%ebx),%edx
  801bd8:	83 c2 20             	add    $0x20,%edx
  801bdb:	39 d0                	cmp    %edx,%eax
  801bdd:	73 ac                	jae    801b8b <devpipe_write+0x24>
  801bdf:	eb c8                	jmp    801ba9 <devpipe_write+0x42>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801be1:	89 f8                	mov    %edi,%eax
  801be3:	eb 05                	jmp    801bea <devpipe_write+0x83>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801be5:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801bea:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801bed:	5b                   	pop    %ebx
  801bee:	5e                   	pop    %esi
  801bef:	5f                   	pop    %edi
  801bf0:	c9                   	leave  
  801bf1:	c3                   	ret    

00801bf2 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801bf2:	55                   	push   %ebp
  801bf3:	89 e5                	mov    %esp,%ebp
  801bf5:	57                   	push   %edi
  801bf6:	56                   	push   %esi
  801bf7:	53                   	push   %ebx
  801bf8:	83 ec 18             	sub    $0x18,%esp
  801bfb:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801bfe:	57                   	push   %edi
  801bff:	e8 e4 f6 ff ff       	call   8012e8 <fd2data>
  801c04:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801c06:	83 c4 10             	add    $0x10,%esp
  801c09:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801c0d:	75 44                	jne    801c53 <devpipe_read+0x61>
  801c0f:	be 00 00 00 00       	mov    $0x0,%esi
  801c14:	eb 4f                	jmp    801c65 <devpipe_read+0x73>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
				return i;
  801c16:	89 f0                	mov    %esi,%eax
  801c18:	eb 54                	jmp    801c6e <devpipe_read+0x7c>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801c1a:	89 da                	mov    %ebx,%edx
  801c1c:	89 f8                	mov    %edi,%eax
  801c1e:	e8 dd fe ff ff       	call   801b00 <_pipeisclosed>
  801c23:	85 c0                	test   %eax,%eax
  801c25:	75 42                	jne    801c69 <devpipe_read+0x77>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801c27:	e8 45 f4 ff ff       	call   801071 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801c2c:	8b 03                	mov    (%ebx),%eax
  801c2e:	3b 43 04             	cmp    0x4(%ebx),%eax
  801c31:	74 e7                	je     801c1a <devpipe_read+0x28>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801c33:	25 1f 00 00 80       	and    $0x8000001f,%eax
  801c38:	79 05                	jns    801c3f <devpipe_read+0x4d>
  801c3a:	48                   	dec    %eax
  801c3b:	83 c8 e0             	or     $0xffffffe0,%eax
  801c3e:	40                   	inc    %eax
  801c3f:	8a 44 03 08          	mov    0x8(%ebx,%eax,1),%al
  801c43:	8b 55 0c             	mov    0xc(%ebp),%edx
  801c46:	88 04 32             	mov    %al,(%edx,%esi,1)
		p->p_rpos++;
  801c49:	ff 03                	incl   (%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801c4b:	46                   	inc    %esi
  801c4c:	39 75 10             	cmp    %esi,0x10(%ebp)
  801c4f:	77 07                	ja     801c58 <devpipe_read+0x66>
  801c51:	eb 12                	jmp    801c65 <devpipe_read+0x73>
  801c53:	be 00 00 00 00       	mov    $0x0,%esi
		while (p->p_rpos == p->p_wpos) {
  801c58:	8b 03                	mov    (%ebx),%eax
  801c5a:	3b 43 04             	cmp    0x4(%ebx),%eax
  801c5d:	75 d4                	jne    801c33 <devpipe_read+0x41>
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801c5f:	85 f6                	test   %esi,%esi
  801c61:	75 b3                	jne    801c16 <devpipe_read+0x24>
  801c63:	eb b5                	jmp    801c1a <devpipe_read+0x28>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801c65:	89 f0                	mov    %esi,%eax
  801c67:	eb 05                	jmp    801c6e <devpipe_read+0x7c>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801c69:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801c6e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801c71:	5b                   	pop    %ebx
  801c72:	5e                   	pop    %esi
  801c73:	5f                   	pop    %edi
  801c74:	c9                   	leave  
  801c75:	c3                   	ret    

00801c76 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801c76:	55                   	push   %ebp
  801c77:	89 e5                	mov    %esp,%ebp
  801c79:	57                   	push   %edi
  801c7a:	56                   	push   %esi
  801c7b:	53                   	push   %ebx
  801c7c:	83 ec 28             	sub    $0x28,%esp
  801c7f:	8b 7d 08             	mov    0x8(%ebp),%edi
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801c82:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801c85:	50                   	push   %eax
  801c86:	e8 75 f6 ff ff       	call   801300 <fd_alloc>
  801c8b:	89 c3                	mov    %eax,%ebx
  801c8d:	83 c4 10             	add    $0x10,%esp
  801c90:	85 c0                	test   %eax,%eax
  801c92:	0f 88 24 01 00 00    	js     801dbc <pipe+0x146>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c98:	83 ec 04             	sub    $0x4,%esp
  801c9b:	68 07 04 00 00       	push   $0x407
  801ca0:	ff 75 e4             	pushl  -0x1c(%ebp)
  801ca3:	6a 00                	push   $0x0
  801ca5:	e8 ee f3 ff ff       	call   801098 <sys_page_alloc>
  801caa:	89 c3                	mov    %eax,%ebx
  801cac:	83 c4 10             	add    $0x10,%esp
  801caf:	85 c0                	test   %eax,%eax
  801cb1:	0f 88 05 01 00 00    	js     801dbc <pipe+0x146>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801cb7:	83 ec 0c             	sub    $0xc,%esp
  801cba:	8d 45 e0             	lea    -0x20(%ebp),%eax
  801cbd:	50                   	push   %eax
  801cbe:	e8 3d f6 ff ff       	call   801300 <fd_alloc>
  801cc3:	89 c3                	mov    %eax,%ebx
  801cc5:	83 c4 10             	add    $0x10,%esp
  801cc8:	85 c0                	test   %eax,%eax
  801cca:	0f 88 dc 00 00 00    	js     801dac <pipe+0x136>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801cd0:	83 ec 04             	sub    $0x4,%esp
  801cd3:	68 07 04 00 00       	push   $0x407
  801cd8:	ff 75 e0             	pushl  -0x20(%ebp)
  801cdb:	6a 00                	push   $0x0
  801cdd:	e8 b6 f3 ff ff       	call   801098 <sys_page_alloc>
  801ce2:	89 c3                	mov    %eax,%ebx
  801ce4:	83 c4 10             	add    $0x10,%esp
  801ce7:	85 c0                	test   %eax,%eax
  801ce9:	0f 88 bd 00 00 00    	js     801dac <pipe+0x136>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801cef:	83 ec 0c             	sub    $0xc,%esp
  801cf2:	ff 75 e4             	pushl  -0x1c(%ebp)
  801cf5:	e8 ee f5 ff ff       	call   8012e8 <fd2data>
  801cfa:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801cfc:	83 c4 0c             	add    $0xc,%esp
  801cff:	68 07 04 00 00       	push   $0x407
  801d04:	50                   	push   %eax
  801d05:	6a 00                	push   $0x0
  801d07:	e8 8c f3 ff ff       	call   801098 <sys_page_alloc>
  801d0c:	89 c3                	mov    %eax,%ebx
  801d0e:	83 c4 10             	add    $0x10,%esp
  801d11:	85 c0                	test   %eax,%eax
  801d13:	0f 88 83 00 00 00    	js     801d9c <pipe+0x126>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801d19:	83 ec 0c             	sub    $0xc,%esp
  801d1c:	ff 75 e0             	pushl  -0x20(%ebp)
  801d1f:	e8 c4 f5 ff ff       	call   8012e8 <fd2data>
  801d24:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801d2b:	50                   	push   %eax
  801d2c:	6a 00                	push   $0x0
  801d2e:	56                   	push   %esi
  801d2f:	6a 00                	push   $0x0
  801d31:	e8 86 f3 ff ff       	call   8010bc <sys_page_map>
  801d36:	89 c3                	mov    %eax,%ebx
  801d38:	83 c4 20             	add    $0x20,%esp
  801d3b:	85 c0                	test   %eax,%eax
  801d3d:	78 4f                	js     801d8e <pipe+0x118>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801d3f:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801d45:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801d48:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801d4a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801d4d:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801d54:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801d5a:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801d5d:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801d5f:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801d62:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801d69:	83 ec 0c             	sub    $0xc,%esp
  801d6c:	ff 75 e4             	pushl  -0x1c(%ebp)
  801d6f:	e8 64 f5 ff ff       	call   8012d8 <fd2num>
  801d74:	89 07                	mov    %eax,(%edi)
	pfd[1] = fd2num(fd1);
  801d76:	83 c4 04             	add    $0x4,%esp
  801d79:	ff 75 e0             	pushl  -0x20(%ebp)
  801d7c:	e8 57 f5 ff ff       	call   8012d8 <fd2num>
  801d81:	89 47 04             	mov    %eax,0x4(%edi)
	return 0;
  801d84:	83 c4 10             	add    $0x10,%esp
  801d87:	bb 00 00 00 00       	mov    $0x0,%ebx
  801d8c:	eb 2e                	jmp    801dbc <pipe+0x146>

    err3:
	sys_page_unmap(0, va);
  801d8e:	83 ec 08             	sub    $0x8,%esp
  801d91:	56                   	push   %esi
  801d92:	6a 00                	push   $0x0
  801d94:	e8 49 f3 ff ff       	call   8010e2 <sys_page_unmap>
  801d99:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801d9c:	83 ec 08             	sub    $0x8,%esp
  801d9f:	ff 75 e0             	pushl  -0x20(%ebp)
  801da2:	6a 00                	push   $0x0
  801da4:	e8 39 f3 ff ff       	call   8010e2 <sys_page_unmap>
  801da9:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801dac:	83 ec 08             	sub    $0x8,%esp
  801daf:	ff 75 e4             	pushl  -0x1c(%ebp)
  801db2:	6a 00                	push   $0x0
  801db4:	e8 29 f3 ff ff       	call   8010e2 <sys_page_unmap>
  801db9:	83 c4 10             	add    $0x10,%esp
    err:
	return r;
}
  801dbc:	89 d8                	mov    %ebx,%eax
  801dbe:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801dc1:	5b                   	pop    %ebx
  801dc2:	5e                   	pop    %esi
  801dc3:	5f                   	pop    %edi
  801dc4:	c9                   	leave  
  801dc5:	c3                   	ret    

00801dc6 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801dc6:	55                   	push   %ebp
  801dc7:	89 e5                	mov    %esp,%ebp
  801dc9:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801dcc:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801dcf:	50                   	push   %eax
  801dd0:	ff 75 08             	pushl  0x8(%ebp)
  801dd3:	e8 9b f5 ff ff       	call   801373 <fd_lookup>
  801dd8:	83 c4 10             	add    $0x10,%esp
  801ddb:	85 c0                	test   %eax,%eax
  801ddd:	78 18                	js     801df7 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801ddf:	83 ec 0c             	sub    $0xc,%esp
  801de2:	ff 75 f4             	pushl  -0xc(%ebp)
  801de5:	e8 fe f4 ff ff       	call   8012e8 <fd2data>
	return _pipeisclosed(fd, p);
  801dea:	89 c2                	mov    %eax,%edx
  801dec:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801def:	e8 0c fd ff ff       	call   801b00 <_pipeisclosed>
  801df4:	83 c4 10             	add    $0x10,%esp
}
  801df7:	c9                   	leave  
  801df8:	c3                   	ret    
  801df9:	00 00                	add    %al,(%eax)
	...

00801dfc <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801dfc:	55                   	push   %ebp
  801dfd:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801dff:	b8 00 00 00 00       	mov    $0x0,%eax
  801e04:	c9                   	leave  
  801e05:	c3                   	ret    

00801e06 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801e06:	55                   	push   %ebp
  801e07:	89 e5                	mov    %esp,%ebp
  801e09:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801e0c:	68 de 28 80 00       	push   $0x8028de
  801e11:	ff 75 0c             	pushl  0xc(%ebp)
  801e14:	e8 fd ed ff ff       	call   800c16 <strcpy>
	return 0;
}
  801e19:	b8 00 00 00 00       	mov    $0x0,%eax
  801e1e:	c9                   	leave  
  801e1f:	c3                   	ret    

00801e20 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801e20:	55                   	push   %ebp
  801e21:	89 e5                	mov    %esp,%ebp
  801e23:	57                   	push   %edi
  801e24:	56                   	push   %esi
  801e25:	53                   	push   %ebx
  801e26:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801e2c:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801e30:	74 45                	je     801e77 <devcons_write+0x57>
  801e32:	b8 00 00 00 00       	mov    $0x0,%eax
  801e37:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801e3c:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801e42:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801e45:	29 c3                	sub    %eax,%ebx
		if (m > sizeof(buf) - 1)
  801e47:	83 fb 7f             	cmp    $0x7f,%ebx
  801e4a:	76 05                	jbe    801e51 <devcons_write+0x31>
			m = sizeof(buf) - 1;
  801e4c:	bb 7f 00 00 00       	mov    $0x7f,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  801e51:	83 ec 04             	sub    $0x4,%esp
  801e54:	53                   	push   %ebx
  801e55:	03 45 0c             	add    0xc(%ebp),%eax
  801e58:	50                   	push   %eax
  801e59:	57                   	push   %edi
  801e5a:	e8 78 ef ff ff       	call   800dd7 <memmove>
		sys_cputs(buf, m);
  801e5f:	83 c4 08             	add    $0x8,%esp
  801e62:	53                   	push   %ebx
  801e63:	57                   	push   %edi
  801e64:	e8 78 f1 ff ff       	call   800fe1 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801e69:	01 de                	add    %ebx,%esi
  801e6b:	89 f0                	mov    %esi,%eax
  801e6d:	83 c4 10             	add    $0x10,%esp
  801e70:	3b 75 10             	cmp    0x10(%ebp),%esi
  801e73:	72 cd                	jb     801e42 <devcons_write+0x22>
  801e75:	eb 05                	jmp    801e7c <devcons_write+0x5c>
  801e77:	be 00 00 00 00       	mov    $0x0,%esi
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801e7c:	89 f0                	mov    %esi,%eax
  801e7e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801e81:	5b                   	pop    %ebx
  801e82:	5e                   	pop    %esi
  801e83:	5f                   	pop    %edi
  801e84:	c9                   	leave  
  801e85:	c3                   	ret    

00801e86 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801e86:	55                   	push   %ebp
  801e87:	89 e5                	mov    %esp,%ebp
  801e89:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
  801e8c:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801e90:	75 07                	jne    801e99 <devcons_read+0x13>
  801e92:	eb 25                	jmp    801eb9 <devcons_read+0x33>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801e94:	e8 d8 f1 ff ff       	call   801071 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801e99:	e8 69 f1 ff ff       	call   801007 <sys_cgetc>
  801e9e:	85 c0                	test   %eax,%eax
  801ea0:	74 f2                	je     801e94 <devcons_read+0xe>
  801ea2:	89 c2                	mov    %eax,%edx
		sys_yield();
	if (c < 0)
  801ea4:	85 c0                	test   %eax,%eax
  801ea6:	78 1d                	js     801ec5 <devcons_read+0x3f>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801ea8:	83 f8 04             	cmp    $0x4,%eax
  801eab:	74 13                	je     801ec0 <devcons_read+0x3a>
		return 0;
	*(char*)vbuf = c;
  801ead:	8b 45 0c             	mov    0xc(%ebp),%eax
  801eb0:	88 10                	mov    %dl,(%eax)
	return 1;
  801eb2:	b8 01 00 00 00       	mov    $0x1,%eax
  801eb7:	eb 0c                	jmp    801ec5 <devcons_read+0x3f>
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
		return 0;
  801eb9:	b8 00 00 00 00       	mov    $0x0,%eax
  801ebe:	eb 05                	jmp    801ec5 <devcons_read+0x3f>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801ec0:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801ec5:	c9                   	leave  
  801ec6:	c3                   	ret    

00801ec7 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801ec7:	55                   	push   %ebp
  801ec8:	89 e5                	mov    %esp,%ebp
  801eca:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801ecd:	8b 45 08             	mov    0x8(%ebp),%eax
  801ed0:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801ed3:	6a 01                	push   $0x1
  801ed5:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801ed8:	50                   	push   %eax
  801ed9:	e8 03 f1 ff ff       	call   800fe1 <sys_cputs>
  801ede:	83 c4 10             	add    $0x10,%esp
}
  801ee1:	c9                   	leave  
  801ee2:	c3                   	ret    

00801ee3 <getchar>:

int
getchar(void)
{
  801ee3:	55                   	push   %ebp
  801ee4:	89 e5                	mov    %esp,%ebp
  801ee6:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801ee9:	6a 01                	push   $0x1
  801eeb:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801eee:	50                   	push   %eax
  801eef:	6a 00                	push   $0x0
  801ef1:	e8 fe f6 ff ff       	call   8015f4 <read>
	if (r < 0)
  801ef6:	83 c4 10             	add    $0x10,%esp
  801ef9:	85 c0                	test   %eax,%eax
  801efb:	78 0f                	js     801f0c <getchar+0x29>
		return r;
	if (r < 1)
  801efd:	85 c0                	test   %eax,%eax
  801eff:	7e 06                	jle    801f07 <getchar+0x24>
		return -E_EOF;
	return c;
  801f01:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801f05:	eb 05                	jmp    801f0c <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801f07:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801f0c:	c9                   	leave  
  801f0d:	c3                   	ret    

00801f0e <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801f0e:	55                   	push   %ebp
  801f0f:	89 e5                	mov    %esp,%ebp
  801f11:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801f14:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801f17:	50                   	push   %eax
  801f18:	ff 75 08             	pushl  0x8(%ebp)
  801f1b:	e8 53 f4 ff ff       	call   801373 <fd_lookup>
  801f20:	83 c4 10             	add    $0x10,%esp
  801f23:	85 c0                	test   %eax,%eax
  801f25:	78 11                	js     801f38 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801f27:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f2a:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801f30:	39 10                	cmp    %edx,(%eax)
  801f32:	0f 94 c0             	sete   %al
  801f35:	0f b6 c0             	movzbl %al,%eax
}
  801f38:	c9                   	leave  
  801f39:	c3                   	ret    

00801f3a <opencons>:

int
opencons(void)
{
  801f3a:	55                   	push   %ebp
  801f3b:	89 e5                	mov    %esp,%ebp
  801f3d:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801f40:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801f43:	50                   	push   %eax
  801f44:	e8 b7 f3 ff ff       	call   801300 <fd_alloc>
  801f49:	83 c4 10             	add    $0x10,%esp
  801f4c:	85 c0                	test   %eax,%eax
  801f4e:	78 3a                	js     801f8a <opencons+0x50>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801f50:	83 ec 04             	sub    $0x4,%esp
  801f53:	68 07 04 00 00       	push   $0x407
  801f58:	ff 75 f4             	pushl  -0xc(%ebp)
  801f5b:	6a 00                	push   $0x0
  801f5d:	e8 36 f1 ff ff       	call   801098 <sys_page_alloc>
  801f62:	83 c4 10             	add    $0x10,%esp
  801f65:	85 c0                	test   %eax,%eax
  801f67:	78 21                	js     801f8a <opencons+0x50>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801f69:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801f6f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f72:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801f74:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f77:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801f7e:	83 ec 0c             	sub    $0xc,%esp
  801f81:	50                   	push   %eax
  801f82:	e8 51 f3 ff ff       	call   8012d8 <fd2num>
  801f87:	83 c4 10             	add    $0x10,%esp
}
  801f8a:	c9                   	leave  
  801f8b:	c3                   	ret    

00801f8c <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801f8c:	55                   	push   %ebp
  801f8d:	89 e5                	mov    %esp,%ebp
  801f8f:	56                   	push   %esi
  801f90:	53                   	push   %ebx
  801f91:	8b 75 08             	mov    0x8(%ebp),%esi
  801f94:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f97:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// cprintf("0x%x 0x%x 0x%x\n", (uint32_t)from_env_store, (uint32_t)pg, (uint32_t)perm_store);
	int r;
	if (pg != NULL) {
  801f9a:	85 c0                	test   %eax,%eax
  801f9c:	74 0e                	je     801fac <ipc_recv+0x20>
		r = sys_ipc_recv(pg);
  801f9e:	83 ec 0c             	sub    $0xc,%esp
  801fa1:	50                   	push   %eax
  801fa2:	e8 ec f1 ff ff       	call   801193 <sys_ipc_recv>
  801fa7:	83 c4 10             	add    $0x10,%esp
  801faa:	eb 10                	jmp    801fbc <ipc_recv+0x30>
	} else {
		r = sys_ipc_recv((void *)UTOP);
  801fac:	83 ec 0c             	sub    $0xc,%esp
  801faf:	68 00 00 c0 ee       	push   $0xeec00000
  801fb4:	e8 da f1 ff ff       	call   801193 <sys_ipc_recv>
  801fb9:	83 c4 10             	add    $0x10,%esp
	}

	if (r == 0) {
  801fbc:	85 c0                	test   %eax,%eax
  801fbe:	75 26                	jne    801fe6 <ipc_recv+0x5a>
		if (from_env_store != NULL) *from_env_store = thisenv->env_ipc_from;
  801fc0:	85 f6                	test   %esi,%esi
  801fc2:	74 0a                	je     801fce <ipc_recv+0x42>
  801fc4:	a1 b0 40 80 00       	mov    0x8040b0,%eax
  801fc9:	8b 40 74             	mov    0x74(%eax),%eax
  801fcc:	89 06                	mov    %eax,(%esi)
		if (perm_store != NULL) *perm_store = thisenv->env_ipc_perm;
  801fce:	85 db                	test   %ebx,%ebx
  801fd0:	74 0a                	je     801fdc <ipc_recv+0x50>
  801fd2:	a1 b0 40 80 00       	mov    0x8040b0,%eax
  801fd7:	8b 40 78             	mov    0x78(%eax),%eax
  801fda:	89 03                	mov    %eax,(%ebx)
		return thisenv->env_ipc_value;
  801fdc:	a1 b0 40 80 00       	mov    0x8040b0,%eax
  801fe1:	8b 40 70             	mov    0x70(%eax),%eax
  801fe4:	eb 14                	jmp    801ffa <ipc_recv+0x6e>
	} else {
		// fails;
		if (from_env_store != NULL) *from_env_store = 0;
  801fe6:	85 f6                	test   %esi,%esi
  801fe8:	74 06                	je     801ff0 <ipc_recv+0x64>
  801fea:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		if (perm_store != NULL) *perm_store = 0;
  801ff0:	85 db                	test   %ebx,%ebx
  801ff2:	74 06                	je     801ffa <ipc_recv+0x6e>
  801ff4:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
		return r;
	}
}
  801ffa:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801ffd:	5b                   	pop    %ebx
  801ffe:	5e                   	pop    %esi
  801fff:	c9                   	leave  
  802000:	c3                   	ret    

00802001 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  802001:	55                   	push   %ebp
  802002:	89 e5                	mov    %esp,%ebp
  802004:	57                   	push   %edi
  802005:	56                   	push   %esi
  802006:	53                   	push   %ebx
  802007:	83 ec 0c             	sub    $0xc,%esp
  80200a:	8b 7d 0c             	mov    0xc(%ebp),%edi
  80200d:	8b 5d 10             	mov    0x10(%ebp),%ebx
  802010:	8b 75 14             	mov    0x14(%ebp),%esi
	// LAB 4: Your code here.
	// int sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
	int r;
	if (pg == NULL) pg = (void *)UTOP;
  802013:	85 db                	test   %ebx,%ebx
  802015:	75 25                	jne    80203c <ipc_send+0x3b>
  802017:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
  80201c:	eb 1e                	jmp    80203c <ipc_send+0x3b>
	
	while ((r = sys_ipc_try_send(to_env, val, pg, perm)) != 0) {
		if (r == -E_IPC_NOT_RECV) {
  80201e:	83 f8 f9             	cmp    $0xfffffff9,%eax
  802021:	75 07                	jne    80202a <ipc_send+0x29>
			// cprintf("Try Again and Again....\n");
			sys_yield();
  802023:	e8 49 f0 ff ff       	call   801071 <sys_yield>
  802028:	eb 12                	jmp    80203c <ipc_send+0x3b>
		} else {
			panic("ipc_send error %e\n", r);
  80202a:	50                   	push   %eax
  80202b:	68 ea 28 80 00       	push   $0x8028ea
  802030:	6a 43                	push   $0x43
  802032:	68 fd 28 80 00       	push   $0x8028fd
  802037:	e8 4c e5 ff ff       	call   800588 <_panic>
	// LAB 4: Your code here.
	// int sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
	int r;
	if (pg == NULL) pg = (void *)UTOP;
	
	while ((r = sys_ipc_try_send(to_env, val, pg, perm)) != 0) {
  80203c:	56                   	push   %esi
  80203d:	53                   	push   %ebx
  80203e:	57                   	push   %edi
  80203f:	ff 75 08             	pushl  0x8(%ebp)
  802042:	e8 27 f1 ff ff       	call   80116e <sys_ipc_try_send>
  802047:	83 c4 10             	add    $0x10,%esp
  80204a:	85 c0                	test   %eax,%eax
  80204c:	75 d0                	jne    80201e <ipc_send+0x1d>
		} else {
			panic("ipc_send error %e\n", r);
		}
	}
	return;
}
  80204e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802051:	5b                   	pop    %ebx
  802052:	5e                   	pop    %esi
  802053:	5f                   	pop    %edi
  802054:	c9                   	leave  
  802055:	c3                   	ret    

00802056 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  802056:	55                   	push   %ebp
  802057:	89 e5                	mov    %esp,%ebp
  802059:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
		if (envs[i].env_type == type)
  80205c:	39 0d 50 00 c0 ee    	cmp    %ecx,0xeec00050
  802062:	74 1a                	je     80207e <ipc_find_env+0x28>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  802064:	b8 01 00 00 00       	mov    $0x1,%eax
		if (envs[i].env_type == type)
  802069:	89 c2                	mov    %eax,%edx
  80206b:	c1 e2 07             	shl    $0x7,%edx
  80206e:	8d 94 82 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,4),%edx
  802075:	8b 52 50             	mov    0x50(%edx),%edx
  802078:	39 ca                	cmp    %ecx,%edx
  80207a:	75 18                	jne    802094 <ipc_find_env+0x3e>
  80207c:	eb 05                	jmp    802083 <ipc_find_env+0x2d>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  80207e:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
			return envs[i].env_id;
  802083:	89 c2                	mov    %eax,%edx
  802085:	c1 e2 07             	shl    $0x7,%edx
  802088:	8d 84 82 08 00 c0 ee 	lea    -0x113ffff8(%edx,%eax,4),%eax
  80208f:	8b 40 40             	mov    0x40(%eax),%eax
  802092:	eb 0c                	jmp    8020a0 <ipc_find_env+0x4a>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  802094:	40                   	inc    %eax
  802095:	3d 00 04 00 00       	cmp    $0x400,%eax
  80209a:	75 cd                	jne    802069 <ipc_find_env+0x13>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  80209c:	66 b8 00 00          	mov    $0x0,%ax
}
  8020a0:	c9                   	leave  
  8020a1:	c3                   	ret    
	...

008020a4 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  8020a4:	55                   	push   %ebp
  8020a5:	89 e5                	mov    %esp,%ebp
  8020a7:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8020aa:	89 c2                	mov    %eax,%edx
  8020ac:	c1 ea 16             	shr    $0x16,%edx
  8020af:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8020b6:	f6 c2 01             	test   $0x1,%dl
  8020b9:	74 1e                	je     8020d9 <pageref+0x35>
		return 0;
	pte = uvpt[PGNUM(v)];
  8020bb:	c1 e8 0c             	shr    $0xc,%eax
  8020be:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  8020c5:	a8 01                	test   $0x1,%al
  8020c7:	74 17                	je     8020e0 <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  8020c9:	c1 e8 0c             	shr    $0xc,%eax
  8020cc:	66 8b 04 c5 04 00 00 	mov    -0x10fffffc(,%eax,8),%ax
  8020d3:	ef 
  8020d4:	0f b7 c0             	movzwl %ax,%eax
  8020d7:	eb 0c                	jmp    8020e5 <pageref+0x41>
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
		return 0;
  8020d9:	b8 00 00 00 00       	mov    $0x0,%eax
  8020de:	eb 05                	jmp    8020e5 <pageref+0x41>
	pte = uvpt[PGNUM(v)];
	if (!(pte & PTE_P))
		return 0;
  8020e0:	b8 00 00 00 00       	mov    $0x0,%eax
	return pages[PGNUM(pte)].pp_ref;
}
  8020e5:	c9                   	leave  
  8020e6:	c3                   	ret    
	...

008020e8 <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  8020e8:	55                   	push   %ebp
  8020e9:	89 e5                	mov    %esp,%ebp
  8020eb:	57                   	push   %edi
  8020ec:	56                   	push   %esi
  8020ed:	83 ec 10             	sub    $0x10,%esp
  8020f0:	8b 7d 08             	mov    0x8(%ebp),%edi
  8020f3:	8b 4d 10             	mov    0x10(%ebp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  8020f6:	89 7d f0             	mov    %edi,-0x10(%ebp)
  8020f9:	8b 75 0c             	mov    0xc(%ebp),%esi
  const DWunion dd = {.ll = d};
  8020fc:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  8020ff:	8b 45 14             	mov    0x14(%ebp),%eax
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  802102:	85 c0                	test   %eax,%eax
  802104:	75 2e                	jne    802134 <__udivdi3+0x4c>
    {
      if (d0 > n1)
  802106:	39 f1                	cmp    %esi,%ecx
  802108:	77 5a                	ja     802164 <__udivdi3+0x7c>
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  80210a:	85 c9                	test   %ecx,%ecx
  80210c:	75 0b                	jne    802119 <__udivdi3+0x31>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  80210e:	b8 01 00 00 00       	mov    $0x1,%eax
  802113:	31 d2                	xor    %edx,%edx
  802115:	f7 f1                	div    %ecx
  802117:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  802119:	31 d2                	xor    %edx,%edx
  80211b:	89 f0                	mov    %esi,%eax
  80211d:	f7 f1                	div    %ecx
  80211f:	89 c6                	mov    %eax,%esi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  802121:	89 f8                	mov    %edi,%eax
  802123:	f7 f1                	div    %ecx
  802125:	89 c7                	mov    %eax,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  802127:	89 f8                	mov    %edi,%eax
  802129:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  80212b:	83 c4 10             	add    $0x10,%esp
  80212e:	5e                   	pop    %esi
  80212f:	5f                   	pop    %edi
  802130:	c9                   	leave  
  802131:	c3                   	ret    
  802132:	66 90                	xchg   %ax,%ax
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  802134:	39 f0                	cmp    %esi,%eax
  802136:	77 1c                	ja     802154 <__udivdi3+0x6c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  802138:	0f bd f8             	bsr    %eax,%edi
	  if (bm == 0)
  80213b:	83 f7 1f             	xor    $0x1f,%edi
  80213e:	75 3c                	jne    80217c <__udivdi3+0x94>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  802140:	39 f0                	cmp    %esi,%eax
  802142:	0f 82 90 00 00 00    	jb     8021d8 <__udivdi3+0xf0>
  802148:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80214b:	39 55 f4             	cmp    %edx,-0xc(%ebp)
  80214e:	0f 86 84 00 00 00    	jbe    8021d8 <__udivdi3+0xf0>
  802154:	31 f6                	xor    %esi,%esi
  802156:	31 ff                	xor    %edi,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  802158:	89 f8                	mov    %edi,%eax
  80215a:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  80215c:	83 c4 10             	add    $0x10,%esp
  80215f:	5e                   	pop    %esi
  802160:	5f                   	pop    %edi
  802161:	c9                   	leave  
  802162:	c3                   	ret    
  802163:	90                   	nop
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  802164:	89 f2                	mov    %esi,%edx
  802166:	89 f8                	mov    %edi,%eax
  802168:	f7 f1                	div    %ecx
  80216a:	89 c7                	mov    %eax,%edi
  80216c:	31 f6                	xor    %esi,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  80216e:	89 f8                	mov    %edi,%eax
  802170:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  802172:	83 c4 10             	add    $0x10,%esp
  802175:	5e                   	pop    %esi
  802176:	5f                   	pop    %edi
  802177:	c9                   	leave  
  802178:	c3                   	ret    
  802179:	8d 76 00             	lea    0x0(%esi),%esi
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  80217c:	89 f9                	mov    %edi,%ecx
  80217e:	d3 e0                	shl    %cl,%eax
  802180:	89 45 e8             	mov    %eax,-0x18(%ebp)
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  802183:	b8 20 00 00 00       	mov    $0x20,%eax
  802188:	29 f8                	sub    %edi,%eax

	      d1 = (d1 << bm) | (d0 >> b);
  80218a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80218d:	88 c1                	mov    %al,%cl
  80218f:	d3 ea                	shr    %cl,%edx
  802191:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  802194:	09 ca                	or     %ecx,%edx
  802196:	89 55 ec             	mov    %edx,-0x14(%ebp)
	      d0 = d0 << bm;
  802199:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80219c:	89 f9                	mov    %edi,%ecx
  80219e:	d3 e2                	shl    %cl,%edx
  8021a0:	89 55 f4             	mov    %edx,-0xc(%ebp)
	      n2 = n1 >> b;
  8021a3:	89 f2                	mov    %esi,%edx
  8021a5:	88 c1                	mov    %al,%cl
  8021a7:	d3 ea                	shr    %cl,%edx
  8021a9:	89 55 e8             	mov    %edx,-0x18(%ebp)
	      n1 = (n1 << bm) | (n0 >> b);
  8021ac:	89 f2                	mov    %esi,%edx
  8021ae:	89 f9                	mov    %edi,%ecx
  8021b0:	d3 e2                	shl    %cl,%edx
  8021b2:	8b 75 f0             	mov    -0x10(%ebp),%esi
  8021b5:	88 c1                	mov    %al,%cl
  8021b7:	d3 ee                	shr    %cl,%esi
  8021b9:	09 d6                	or     %edx,%esi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  8021bb:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  8021be:	89 f0                	mov    %esi,%eax
  8021c0:	89 ca                	mov    %ecx,%edx
  8021c2:	f7 75 ec             	divl   -0x14(%ebp)
  8021c5:	89 d1                	mov    %edx,%ecx
  8021c7:	89 c6                	mov    %eax,%esi
	      umul_ppmm (m1, m0, q0, d0);
  8021c9:	f7 65 f4             	mull   -0xc(%ebp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  8021cc:	39 d1                	cmp    %edx,%ecx
  8021ce:	72 28                	jb     8021f8 <__udivdi3+0x110>
  8021d0:	74 1a                	je     8021ec <__udivdi3+0x104>
  8021d2:	89 f7                	mov    %esi,%edi
  8021d4:	31 f6                	xor    %esi,%esi
  8021d6:	eb 80                	jmp    802158 <__udivdi3+0x70>
	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  8021d8:	31 f6                	xor    %esi,%esi
  8021da:	bf 01 00 00 00       	mov    $0x1,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  8021df:	89 f8                	mov    %edi,%eax
  8021e1:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  8021e3:	83 c4 10             	add    $0x10,%esp
  8021e6:	5e                   	pop    %esi
  8021e7:	5f                   	pop    %edi
  8021e8:	c9                   	leave  
  8021e9:	c3                   	ret    
  8021ea:	66 90                	xchg   %ax,%ax

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  8021ec:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8021ef:	89 f9                	mov    %edi,%ecx
  8021f1:	d3 e2                	shl    %cl,%edx

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  8021f3:	39 c2                	cmp    %eax,%edx
  8021f5:	73 db                	jae    8021d2 <__udivdi3+0xea>
  8021f7:	90                   	nop
		{
		  q0--;
  8021f8:	8d 7e ff             	lea    -0x1(%esi),%edi
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  8021fb:	31 f6                	xor    %esi,%esi
  8021fd:	e9 56 ff ff ff       	jmp    802158 <__udivdi3+0x70>
	...

00802204 <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  802204:	55                   	push   %ebp
  802205:	89 e5                	mov    %esp,%ebp
  802207:	57                   	push   %edi
  802208:	56                   	push   %esi
  802209:	83 ec 20             	sub    $0x20,%esp
  80220c:	8b 45 08             	mov    0x8(%ebp),%eax
  80220f:	8b 4d 10             	mov    0x10(%ebp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  802212:	89 45 e8             	mov    %eax,-0x18(%ebp)
  802215:	8b 75 0c             	mov    0xc(%ebp),%esi
  const DWunion dd = {.ll = d};
  802218:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  80221b:	8b 7d 14             	mov    0x14(%ebp),%edi
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  80221e:	89 45 f0             	mov    %eax,-0x10(%ebp)
  n1 = nn.s.high;
  802221:	89 f2                	mov    %esi,%edx

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  802223:	85 ff                	test   %edi,%edi
  802225:	75 15                	jne    80223c <__umoddi3+0x38>
    {
      if (d0 > n1)
  802227:	39 f1                	cmp    %esi,%ecx
  802229:	0f 86 99 00 00 00    	jbe    8022c8 <__umoddi3+0xc4>
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  80222f:	f7 f1                	div    %ecx

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
  802231:	89 d0                	mov    %edx,%eax
  802233:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  802235:	83 c4 20             	add    $0x20,%esp
  802238:	5e                   	pop    %esi
  802239:	5f                   	pop    %edi
  80223a:	c9                   	leave  
  80223b:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  80223c:	39 f7                	cmp    %esi,%edi
  80223e:	0f 87 a4 00 00 00    	ja     8022e8 <__umoddi3+0xe4>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  802244:	0f bd c7             	bsr    %edi,%eax
	  if (bm == 0)
  802247:	83 f0 1f             	xor    $0x1f,%eax
  80224a:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80224d:	0f 84 a1 00 00 00    	je     8022f4 <__umoddi3+0xf0>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  802253:	89 f8                	mov    %edi,%eax
  802255:	8a 4d ec             	mov    -0x14(%ebp),%cl
  802258:	d3 e0                	shl    %cl,%eax
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  80225a:	bf 20 00 00 00       	mov    $0x20,%edi
  80225f:	2b 7d ec             	sub    -0x14(%ebp),%edi

	      d1 = (d1 << bm) | (d0 >> b);
  802262:	8b 55 f4             	mov    -0xc(%ebp),%edx
  802265:	89 f9                	mov    %edi,%ecx
  802267:	d3 ea                	shr    %cl,%edx
  802269:	09 c2                	or     %eax,%edx
  80226b:	89 55 f0             	mov    %edx,-0x10(%ebp)
	      d0 = d0 << bm;
  80226e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802271:	8a 4d ec             	mov    -0x14(%ebp),%cl
  802274:	d3 e0                	shl    %cl,%eax
  802276:	89 45 f4             	mov    %eax,-0xc(%ebp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  802279:	89 f2                	mov    %esi,%edx
  80227b:	d3 e2                	shl    %cl,%edx
	      n0 = n0 << bm;
  80227d:	8b 45 e8             	mov    -0x18(%ebp),%eax
  802280:	d3 e0                	shl    %cl,%eax
  802282:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  802285:	8b 45 e8             	mov    -0x18(%ebp),%eax
  802288:	89 f9                	mov    %edi,%ecx
  80228a:	d3 e8                	shr    %cl,%eax
  80228c:	09 d0                	or     %edx,%eax

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  80228e:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  802290:	89 f2                	mov    %esi,%edx
  802292:	f7 75 f0             	divl   -0x10(%ebp)
  802295:	89 d6                	mov    %edx,%esi
	      umul_ppmm (m1, m0, q0, d0);
  802297:	f7 65 f4             	mull   -0xc(%ebp)
  80229a:	89 55 e8             	mov    %edx,-0x18(%ebp)
  80229d:	89 c1                	mov    %eax,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  80229f:	39 d6                	cmp    %edx,%esi
  8022a1:	72 71                	jb     802314 <__umoddi3+0x110>
  8022a3:	74 7f                	je     802324 <__umoddi3+0x120>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  8022a5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8022a8:	29 c8                	sub    %ecx,%eax
  8022aa:	19 d6                	sbb    %edx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
  8022ac:	8a 4d ec             	mov    -0x14(%ebp),%cl
  8022af:	d3 e8                	shr    %cl,%eax
  8022b1:	89 f2                	mov    %esi,%edx
  8022b3:	89 f9                	mov    %edi,%ecx
  8022b5:	d3 e2                	shl    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
  8022b7:	09 d0                	or     %edx,%eax
  8022b9:	89 f2                	mov    %esi,%edx
  8022bb:	8a 4d ec             	mov    -0x14(%ebp),%cl
  8022be:	d3 ea                	shr    %cl,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  8022c0:	83 c4 20             	add    $0x20,%esp
  8022c3:	5e                   	pop    %esi
  8022c4:	5f                   	pop    %edi
  8022c5:	c9                   	leave  
  8022c6:	c3                   	ret    
  8022c7:	90                   	nop
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  8022c8:	85 c9                	test   %ecx,%ecx
  8022ca:	75 0b                	jne    8022d7 <__umoddi3+0xd3>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  8022cc:	b8 01 00 00 00       	mov    $0x1,%eax
  8022d1:	31 d2                	xor    %edx,%edx
  8022d3:	f7 f1                	div    %ecx
  8022d5:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  8022d7:	89 f0                	mov    %esi,%eax
  8022d9:	31 d2                	xor    %edx,%edx
  8022db:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  8022dd:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8022e0:	f7 f1                	div    %ecx
  8022e2:	e9 4a ff ff ff       	jmp    802231 <__umoddi3+0x2d>
  8022e7:	90                   	nop
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
  8022e8:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  8022ea:	83 c4 20             	add    $0x20,%esp
  8022ed:	5e                   	pop    %esi
  8022ee:	5f                   	pop    %edi
  8022ef:	c9                   	leave  
  8022f0:	c3                   	ret    
  8022f1:	8d 76 00             	lea    0x0(%esi),%esi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  8022f4:	39 f7                	cmp    %esi,%edi
  8022f6:	72 05                	jb     8022fd <__umoddi3+0xf9>
  8022f8:	3b 4d f0             	cmp    -0x10(%ebp),%ecx
  8022fb:	77 0c                	ja     802309 <__umoddi3+0x105>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  8022fd:	89 f2                	mov    %esi,%edx
  8022ff:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802302:	29 c8                	sub    %ecx,%eax
  802304:	19 fa                	sbb    %edi,%edx
  802306:	89 45 f0             	mov    %eax,-0x10(%ebp)

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
  802309:	8b 45 f0             	mov    -0x10(%ebp),%eax
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
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  802314:	8b 55 e8             	mov    -0x18(%ebp),%edx
  802317:	89 c1                	mov    %eax,%ecx
  802319:	2b 4d f4             	sub    -0xc(%ebp),%ecx
  80231c:	1b 55 f0             	sbb    -0x10(%ebp),%edx
  80231f:	eb 84                	jmp    8022a5 <__umoddi3+0xa1>
  802321:	8d 76 00             	lea    0x0(%esi),%esi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  802324:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  802327:	72 eb                	jb     802314 <__umoddi3+0x110>
  802329:	89 f2                	mov    %esi,%edx
  80232b:	e9 75 ff ff ff       	jmp    8022a5 <__umoddi3+0xa1>
