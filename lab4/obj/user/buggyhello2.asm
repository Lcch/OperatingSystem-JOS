
obj/user/buggyhello2:     file format elf32-i386


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
  80002c:	e8 1f 00 00 00       	call   800050 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800034 <umain>:

const char *hello = "hello, world\n";

void
umain(int argc, char **argv)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	83 ec 10             	sub    $0x10,%esp
	sys_cputs(hello, 1024*1024);
  80003a:	68 00 00 10 00       	push   $0x100000
  80003f:	ff 35 00 20 80 00    	pushl  0x802000
  800045:	e8 b7 00 00 00       	call   800101 <sys_cputs>
  80004a:	83 c4 10             	add    $0x10,%esp
}
  80004d:	c9                   	leave  
  80004e:	c3                   	ret    
	...

00800050 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800050:	55                   	push   %ebp
  800051:	89 e5                	mov    %esp,%ebp
  800053:	56                   	push   %esi
  800054:	53                   	push   %ebx
  800055:	8b 75 08             	mov    0x8(%ebp),%esi
  800058:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = envs + ENVX(sys_getenvid());
  80005b:	e8 0d 01 00 00       	call   80016d <sys_getenvid>
  800060:	25 ff 03 00 00       	and    $0x3ff,%eax
  800065:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  80006c:	c1 e0 07             	shl    $0x7,%eax
  80006f:	29 d0                	sub    %edx,%eax
  800071:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800076:	a3 08 20 80 00       	mov    %eax,0x802008

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80007b:	85 f6                	test   %esi,%esi
  80007d:	7e 07                	jle    800086 <libmain+0x36>
		binaryname = argv[0];
  80007f:	8b 03                	mov    (%ebx),%eax
  800081:	a3 04 20 80 00       	mov    %eax,0x802004
	// call user main routine
	umain(argc, argv);
  800086:	83 ec 08             	sub    $0x8,%esp
  800089:	53                   	push   %ebx
  80008a:	56                   	push   %esi
  80008b:	e8 a4 ff ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  800090:	e8 0b 00 00 00       	call   8000a0 <exit>
  800095:	83 c4 10             	add    $0x10,%esp
}
  800098:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80009b:	5b                   	pop    %ebx
  80009c:	5e                   	pop    %esi
  80009d:	c9                   	leave  
  80009e:	c3                   	ret    
	...

008000a0 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000a0:	55                   	push   %ebp
  8000a1:	89 e5                	mov    %esp,%ebp
  8000a3:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  8000a6:	6a 00                	push   $0x0
  8000a8:	e8 9e 00 00 00       	call   80014b <sys_env_destroy>
  8000ad:	83 c4 10             	add    $0x10,%esp
}
  8000b0:	c9                   	leave  
  8000b1:	c3                   	ret    
	...

008000b4 <syscall>:
	return ret;
}

static int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  8000b4:	55                   	push   %ebp
  8000b5:	89 e5                	mov    %esp,%ebp
  8000b7:	57                   	push   %edi
  8000b8:	56                   	push   %esi
  8000b9:	53                   	push   %ebx
  8000ba:	83 ec 1c             	sub    $0x1c,%esp
  8000bd:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8000c0:	89 55 e0             	mov    %edx,-0x20(%ebp)
  8000c3:	89 ca                	mov    %ecx,%edx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000c5:	8b 75 14             	mov    0x14(%ebp),%esi
  8000c8:	8b 7d 10             	mov    0x10(%ebp),%edi
  8000cb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8000ce:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8000d1:	cd 30                	int    $0x30
  8000d3:	89 c2                	mov    %eax,%edx
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8000d5:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8000d9:	74 1c                	je     8000f7 <syscall+0x43>
  8000db:	85 c0                	test   %eax,%eax
  8000dd:	7e 18                	jle    8000f7 <syscall+0x43>
		panic("syscall %d returned %d (> 0)", num, ret);
  8000df:	83 ec 0c             	sub    $0xc,%esp
  8000e2:	50                   	push   %eax
  8000e3:	ff 75 e4             	pushl  -0x1c(%ebp)
  8000e6:	68 38 0f 80 00       	push   $0x800f38
  8000eb:	6a 42                	push   $0x42
  8000ed:	68 55 0f 80 00       	push   $0x800f55
  8000f2:	e8 bd 01 00 00       	call   8002b4 <_panic>

	return ret;
}
  8000f7:	89 d0                	mov    %edx,%eax
  8000f9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8000fc:	5b                   	pop    %ebx
  8000fd:	5e                   	pop    %esi
  8000fe:	5f                   	pop    %edi
  8000ff:	c9                   	leave  
  800100:	c3                   	ret    

00800101 <sys_cputs>:

void
sys_cputs(const char *s, size_t len)
{	
  800101:	55                   	push   %ebp
  800102:	89 e5                	mov    %esp,%ebp
  800104:	83 ec 08             	sub    $0x8,%esp
	// my_sysenter(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
	// return;
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
  800107:	6a 00                	push   $0x0
  800109:	6a 00                	push   $0x0
  80010b:	6a 00                	push   $0x0
  80010d:	ff 75 0c             	pushl  0xc(%ebp)
  800110:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800113:	ba 00 00 00 00       	mov    $0x0,%edx
  800118:	b8 00 00 00 00       	mov    $0x0,%eax
  80011d:	e8 92 ff ff ff       	call   8000b4 <syscall>
  800122:	83 c4 10             	add    $0x10,%esp
	return;
}
  800125:	c9                   	leave  
  800126:	c3                   	ret    

00800127 <sys_cgetc>:

int
sys_cgetc(void)
{
  800127:	55                   	push   %ebp
  800128:	89 e5                	mov    %esp,%ebp
  80012a:	83 ec 08             	sub    $0x8,%esp
	// return my_sysenter(SYS_cgetc, 0, 0, 0, 0, 0, 0);
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
  80012d:	6a 00                	push   $0x0
  80012f:	6a 00                	push   $0x0
  800131:	6a 00                	push   $0x0
  800133:	6a 00                	push   $0x0
  800135:	b9 00 00 00 00       	mov    $0x0,%ecx
  80013a:	ba 00 00 00 00       	mov    $0x0,%edx
  80013f:	b8 01 00 00 00       	mov    $0x1,%eax
  800144:	e8 6b ff ff ff       	call   8000b4 <syscall>
}
  800149:	c9                   	leave  
  80014a:	c3                   	ret    

0080014b <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  80014b:	55                   	push   %ebp
  80014c:	89 e5                	mov    %esp,%ebp
  80014e:	83 ec 08             	sub    $0x8,%esp
	// return my_sysenter(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
  800151:	6a 00                	push   $0x0
  800153:	6a 00                	push   $0x0
  800155:	6a 00                	push   $0x0
  800157:	6a 00                	push   $0x0
  800159:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80015c:	ba 01 00 00 00       	mov    $0x1,%edx
  800161:	b8 03 00 00 00       	mov    $0x3,%eax
  800166:	e8 49 ff ff ff       	call   8000b4 <syscall>
}
  80016b:	c9                   	leave  
  80016c:	c3                   	ret    

0080016d <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  80016d:	55                   	push   %ebp
  80016e:	89 e5                	mov    %esp,%ebp
  800170:	83 ec 08             	sub    $0x8,%esp
	// return my_sysenter(SYS_getenvid, 0, 0, 0, 0, 0, 0);
	return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
  800173:	6a 00                	push   $0x0
  800175:	6a 00                	push   $0x0
  800177:	6a 00                	push   $0x0
  800179:	6a 00                	push   $0x0
  80017b:	b9 00 00 00 00       	mov    $0x0,%ecx
  800180:	ba 00 00 00 00       	mov    $0x0,%edx
  800185:	b8 02 00 00 00       	mov    $0x2,%eax
  80018a:	e8 25 ff ff ff       	call   8000b4 <syscall>
}
  80018f:	c9                   	leave  
  800190:	c3                   	ret    

00800191 <sys_yield>:

void
sys_yield(void)
{
  800191:	55                   	push   %ebp
  800192:	89 e5                	mov    %esp,%ebp
  800194:	83 ec 08             	sub    $0x8,%esp
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
  800197:	6a 00                	push   $0x0
  800199:	6a 00                	push   $0x0
  80019b:	6a 00                	push   $0x0
  80019d:	6a 00                	push   $0x0
  80019f:	b9 00 00 00 00       	mov    $0x0,%ecx
  8001a4:	ba 00 00 00 00       	mov    $0x0,%edx
  8001a9:	b8 0a 00 00 00       	mov    $0xa,%eax
  8001ae:	e8 01 ff ff ff       	call   8000b4 <syscall>
  8001b3:	83 c4 10             	add    $0x10,%esp
}
  8001b6:	c9                   	leave  
  8001b7:	c3                   	ret    

008001b8 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  8001b8:	55                   	push   %ebp
  8001b9:	89 e5                	mov    %esp,%ebp
  8001bb:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
  8001be:	6a 00                	push   $0x0
  8001c0:	6a 00                	push   $0x0
  8001c2:	ff 75 10             	pushl  0x10(%ebp)
  8001c5:	ff 75 0c             	pushl  0xc(%ebp)
  8001c8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8001cb:	ba 01 00 00 00       	mov    $0x1,%edx
  8001d0:	b8 04 00 00 00       	mov    $0x4,%eax
  8001d5:	e8 da fe ff ff       	call   8000b4 <syscall>
}
  8001da:	c9                   	leave  
  8001db:	c3                   	ret    

008001dc <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8001dc:	55                   	push   %ebp
  8001dd:	89 e5                	mov    %esp,%ebp
  8001df:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
  8001e2:	ff 75 18             	pushl  0x18(%ebp)
  8001e5:	ff 75 14             	pushl  0x14(%ebp)
  8001e8:	ff 75 10             	pushl  0x10(%ebp)
  8001eb:	ff 75 0c             	pushl  0xc(%ebp)
  8001ee:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8001f1:	ba 01 00 00 00       	mov    $0x1,%edx
  8001f6:	b8 05 00 00 00       	mov    $0x5,%eax
  8001fb:	e8 b4 fe ff ff       	call   8000b4 <syscall>
}
  800200:	c9                   	leave  
  800201:	c3                   	ret    

00800202 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800202:	55                   	push   %ebp
  800203:	89 e5                	mov    %esp,%ebp
  800205:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
  800208:	6a 00                	push   $0x0
  80020a:	6a 00                	push   $0x0
  80020c:	6a 00                	push   $0x0
  80020e:	ff 75 0c             	pushl  0xc(%ebp)
  800211:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800214:	ba 01 00 00 00       	mov    $0x1,%edx
  800219:	b8 06 00 00 00       	mov    $0x6,%eax
  80021e:	e8 91 fe ff ff       	call   8000b4 <syscall>
}
  800223:	c9                   	leave  
  800224:	c3                   	ret    

00800225 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800225:	55                   	push   %ebp
  800226:	89 e5                	mov    %esp,%ebp
  800228:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
  80022b:	6a 00                	push   $0x0
  80022d:	6a 00                	push   $0x0
  80022f:	6a 00                	push   $0x0
  800231:	ff 75 0c             	pushl  0xc(%ebp)
  800234:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800237:	ba 01 00 00 00       	mov    $0x1,%edx
  80023c:	b8 08 00 00 00       	mov    $0x8,%eax
  800241:	e8 6e fe ff ff       	call   8000b4 <syscall>
}
  800246:	c9                   	leave  
  800247:	c3                   	ret    

00800248 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800248:	55                   	push   %ebp
  800249:	89 e5                	mov    %esp,%ebp
  80024b:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
  80024e:	6a 00                	push   $0x0
  800250:	6a 00                	push   $0x0
  800252:	6a 00                	push   $0x0
  800254:	ff 75 0c             	pushl  0xc(%ebp)
  800257:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80025a:	ba 01 00 00 00       	mov    $0x1,%edx
  80025f:	b8 09 00 00 00       	mov    $0x9,%eax
  800264:	e8 4b fe ff ff       	call   8000b4 <syscall>
}
  800269:	c9                   	leave  
  80026a:	c3                   	ret    

0080026b <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  80026b:	55                   	push   %ebp
  80026c:	89 e5                	mov    %esp,%ebp
  80026e:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
  800271:	6a 00                	push   $0x0
  800273:	ff 75 14             	pushl  0x14(%ebp)
  800276:	ff 75 10             	pushl  0x10(%ebp)
  800279:	ff 75 0c             	pushl  0xc(%ebp)
  80027c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80027f:	ba 00 00 00 00       	mov    $0x0,%edx
  800284:	b8 0b 00 00 00       	mov    $0xb,%eax
  800289:	e8 26 fe ff ff       	call   8000b4 <syscall>
}
  80028e:	c9                   	leave  
  80028f:	c3                   	ret    

00800290 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800290:	55                   	push   %ebp
  800291:	89 e5                	mov    %esp,%ebp
  800293:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
  800296:	6a 00                	push   $0x0
  800298:	6a 00                	push   $0x0
  80029a:	6a 00                	push   $0x0
  80029c:	6a 00                	push   $0x0
  80029e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8002a1:	ba 01 00 00 00       	mov    $0x1,%edx
  8002a6:	b8 0c 00 00 00       	mov    $0xc,%eax
  8002ab:	e8 04 fe ff ff       	call   8000b4 <syscall>
}
  8002b0:	c9                   	leave  
  8002b1:	c3                   	ret    
	...

008002b4 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8002b4:	55                   	push   %ebp
  8002b5:	89 e5                	mov    %esp,%ebp
  8002b7:	56                   	push   %esi
  8002b8:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  8002b9:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8002bc:	8b 1d 04 20 80 00    	mov    0x802004,%ebx
  8002c2:	e8 a6 fe ff ff       	call   80016d <sys_getenvid>
  8002c7:	83 ec 0c             	sub    $0xc,%esp
  8002ca:	ff 75 0c             	pushl  0xc(%ebp)
  8002cd:	ff 75 08             	pushl  0x8(%ebp)
  8002d0:	53                   	push   %ebx
  8002d1:	50                   	push   %eax
  8002d2:	68 64 0f 80 00       	push   $0x800f64
  8002d7:	e8 b0 00 00 00       	call   80038c <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8002dc:	83 c4 18             	add    $0x18,%esp
  8002df:	56                   	push   %esi
  8002e0:	ff 75 10             	pushl  0x10(%ebp)
  8002e3:	e8 53 00 00 00       	call   80033b <vcprintf>
	cprintf("\n");
  8002e8:	c7 04 24 2c 0f 80 00 	movl   $0x800f2c,(%esp)
  8002ef:	e8 98 00 00 00       	call   80038c <cprintf>
  8002f4:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8002f7:	cc                   	int3   
  8002f8:	eb fd                	jmp    8002f7 <_panic+0x43>
	...

008002fc <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8002fc:	55                   	push   %ebp
  8002fd:	89 e5                	mov    %esp,%ebp
  8002ff:	53                   	push   %ebx
  800300:	83 ec 04             	sub    $0x4,%esp
  800303:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800306:	8b 03                	mov    (%ebx),%eax
  800308:	8b 55 08             	mov    0x8(%ebp),%edx
  80030b:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  80030f:	40                   	inc    %eax
  800310:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  800312:	3d ff 00 00 00       	cmp    $0xff,%eax
  800317:	75 1a                	jne    800333 <putch+0x37>
		sys_cputs(b->buf, b->idx);
  800319:	83 ec 08             	sub    $0x8,%esp
  80031c:	68 ff 00 00 00       	push   $0xff
  800321:	8d 43 08             	lea    0x8(%ebx),%eax
  800324:	50                   	push   %eax
  800325:	e8 d7 fd ff ff       	call   800101 <sys_cputs>
		b->idx = 0;
  80032a:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800330:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  800333:	ff 43 04             	incl   0x4(%ebx)
}
  800336:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800339:	c9                   	leave  
  80033a:	c3                   	ret    

0080033b <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80033b:	55                   	push   %ebp
  80033c:	89 e5                	mov    %esp,%ebp
  80033e:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800344:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80034b:	00 00 00 
	b.cnt = 0;
  80034e:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800355:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800358:	ff 75 0c             	pushl  0xc(%ebp)
  80035b:	ff 75 08             	pushl  0x8(%ebp)
  80035e:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800364:	50                   	push   %eax
  800365:	68 fc 02 80 00       	push   $0x8002fc
  80036a:	e8 82 01 00 00       	call   8004f1 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80036f:	83 c4 08             	add    $0x8,%esp
  800372:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800378:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80037e:	50                   	push   %eax
  80037f:	e8 7d fd ff ff       	call   800101 <sys_cputs>

	return b.cnt;
}
  800384:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80038a:	c9                   	leave  
  80038b:	c3                   	ret    

0080038c <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80038c:	55                   	push   %ebp
  80038d:	89 e5                	mov    %esp,%ebp
  80038f:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800392:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800395:	50                   	push   %eax
  800396:	ff 75 08             	pushl  0x8(%ebp)
  800399:	e8 9d ff ff ff       	call   80033b <vcprintf>
	va_end(ap);

	return cnt;
}
  80039e:	c9                   	leave  
  80039f:	c3                   	ret    

008003a0 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8003a0:	55                   	push   %ebp
  8003a1:	89 e5                	mov    %esp,%ebp
  8003a3:	57                   	push   %edi
  8003a4:	56                   	push   %esi
  8003a5:	53                   	push   %ebx
  8003a6:	83 ec 2c             	sub    $0x2c,%esp
  8003a9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8003ac:	89 d6                	mov    %edx,%esi
  8003ae:	8b 45 08             	mov    0x8(%ebp),%eax
  8003b1:	8b 55 0c             	mov    0xc(%ebp),%edx
  8003b4:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8003b7:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8003ba:	8b 45 10             	mov    0x10(%ebp),%eax
  8003bd:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8003c0:	8b 7d 18             	mov    0x18(%ebp),%edi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8003c3:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8003c6:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  8003cd:	39 55 d4             	cmp    %edx,-0x2c(%ebp)
  8003d0:	72 0c                	jb     8003de <printnum+0x3e>
  8003d2:	3b 45 d8             	cmp    -0x28(%ebp),%eax
  8003d5:	76 07                	jbe    8003de <printnum+0x3e>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8003d7:	4b                   	dec    %ebx
  8003d8:	85 db                	test   %ebx,%ebx
  8003da:	7f 31                	jg     80040d <printnum+0x6d>
  8003dc:	eb 3f                	jmp    80041d <printnum+0x7d>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8003de:	83 ec 0c             	sub    $0xc,%esp
  8003e1:	57                   	push   %edi
  8003e2:	4b                   	dec    %ebx
  8003e3:	53                   	push   %ebx
  8003e4:	50                   	push   %eax
  8003e5:	83 ec 08             	sub    $0x8,%esp
  8003e8:	ff 75 d4             	pushl  -0x2c(%ebp)
  8003eb:	ff 75 d0             	pushl  -0x30(%ebp)
  8003ee:	ff 75 dc             	pushl  -0x24(%ebp)
  8003f1:	ff 75 d8             	pushl  -0x28(%ebp)
  8003f4:	e8 c7 08 00 00       	call   800cc0 <__udivdi3>
  8003f9:	83 c4 18             	add    $0x18,%esp
  8003fc:	52                   	push   %edx
  8003fd:	50                   	push   %eax
  8003fe:	89 f2                	mov    %esi,%edx
  800400:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800403:	e8 98 ff ff ff       	call   8003a0 <printnum>
  800408:	83 c4 20             	add    $0x20,%esp
  80040b:	eb 10                	jmp    80041d <printnum+0x7d>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80040d:	83 ec 08             	sub    $0x8,%esp
  800410:	56                   	push   %esi
  800411:	57                   	push   %edi
  800412:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800415:	4b                   	dec    %ebx
  800416:	83 c4 10             	add    $0x10,%esp
  800419:	85 db                	test   %ebx,%ebx
  80041b:	7f f0                	jg     80040d <printnum+0x6d>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80041d:	83 ec 08             	sub    $0x8,%esp
  800420:	56                   	push   %esi
  800421:	83 ec 04             	sub    $0x4,%esp
  800424:	ff 75 d4             	pushl  -0x2c(%ebp)
  800427:	ff 75 d0             	pushl  -0x30(%ebp)
  80042a:	ff 75 dc             	pushl  -0x24(%ebp)
  80042d:	ff 75 d8             	pushl  -0x28(%ebp)
  800430:	e8 a7 09 00 00       	call   800ddc <__umoddi3>
  800435:	83 c4 14             	add    $0x14,%esp
  800438:	0f be 80 88 0f 80 00 	movsbl 0x800f88(%eax),%eax
  80043f:	50                   	push   %eax
  800440:	ff 55 e4             	call   *-0x1c(%ebp)
  800443:	83 c4 10             	add    $0x10,%esp
}
  800446:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800449:	5b                   	pop    %ebx
  80044a:	5e                   	pop    %esi
  80044b:	5f                   	pop    %edi
  80044c:	c9                   	leave  
  80044d:	c3                   	ret    

0080044e <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80044e:	55                   	push   %ebp
  80044f:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800451:	83 fa 01             	cmp    $0x1,%edx
  800454:	7e 0e                	jle    800464 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800456:	8b 10                	mov    (%eax),%edx
  800458:	8d 4a 08             	lea    0x8(%edx),%ecx
  80045b:	89 08                	mov    %ecx,(%eax)
  80045d:	8b 02                	mov    (%edx),%eax
  80045f:	8b 52 04             	mov    0x4(%edx),%edx
  800462:	eb 22                	jmp    800486 <getuint+0x38>
	else if (lflag)
  800464:	85 d2                	test   %edx,%edx
  800466:	74 10                	je     800478 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800468:	8b 10                	mov    (%eax),%edx
  80046a:	8d 4a 04             	lea    0x4(%edx),%ecx
  80046d:	89 08                	mov    %ecx,(%eax)
  80046f:	8b 02                	mov    (%edx),%eax
  800471:	ba 00 00 00 00       	mov    $0x0,%edx
  800476:	eb 0e                	jmp    800486 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800478:	8b 10                	mov    (%eax),%edx
  80047a:	8d 4a 04             	lea    0x4(%edx),%ecx
  80047d:	89 08                	mov    %ecx,(%eax)
  80047f:	8b 02                	mov    (%edx),%eax
  800481:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800486:	c9                   	leave  
  800487:	c3                   	ret    

00800488 <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
  800488:	55                   	push   %ebp
  800489:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80048b:	83 fa 01             	cmp    $0x1,%edx
  80048e:	7e 0e                	jle    80049e <getint+0x16>
		return va_arg(*ap, long long);
  800490:	8b 10                	mov    (%eax),%edx
  800492:	8d 4a 08             	lea    0x8(%edx),%ecx
  800495:	89 08                	mov    %ecx,(%eax)
  800497:	8b 02                	mov    (%edx),%eax
  800499:	8b 52 04             	mov    0x4(%edx),%edx
  80049c:	eb 1a                	jmp    8004b8 <getint+0x30>
	else if (lflag)
  80049e:	85 d2                	test   %edx,%edx
  8004a0:	74 0c                	je     8004ae <getint+0x26>
		return va_arg(*ap, long);
  8004a2:	8b 10                	mov    (%eax),%edx
  8004a4:	8d 4a 04             	lea    0x4(%edx),%ecx
  8004a7:	89 08                	mov    %ecx,(%eax)
  8004a9:	8b 02                	mov    (%edx),%eax
  8004ab:	99                   	cltd   
  8004ac:	eb 0a                	jmp    8004b8 <getint+0x30>
	else
		return va_arg(*ap, int);
  8004ae:	8b 10                	mov    (%eax),%edx
  8004b0:	8d 4a 04             	lea    0x4(%edx),%ecx
  8004b3:	89 08                	mov    %ecx,(%eax)
  8004b5:	8b 02                	mov    (%edx),%eax
  8004b7:	99                   	cltd   
}
  8004b8:	c9                   	leave  
  8004b9:	c3                   	ret    

008004ba <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8004ba:	55                   	push   %ebp
  8004bb:	89 e5                	mov    %esp,%ebp
  8004bd:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8004c0:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  8004c3:	8b 10                	mov    (%eax),%edx
  8004c5:	3b 50 04             	cmp    0x4(%eax),%edx
  8004c8:	73 08                	jae    8004d2 <sprintputch+0x18>
		*b->buf++ = ch;
  8004ca:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8004cd:	88 0a                	mov    %cl,(%edx)
  8004cf:	42                   	inc    %edx
  8004d0:	89 10                	mov    %edx,(%eax)
}
  8004d2:	c9                   	leave  
  8004d3:	c3                   	ret    

008004d4 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8004d4:	55                   	push   %ebp
  8004d5:	89 e5                	mov    %esp,%ebp
  8004d7:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8004da:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8004dd:	50                   	push   %eax
  8004de:	ff 75 10             	pushl  0x10(%ebp)
  8004e1:	ff 75 0c             	pushl  0xc(%ebp)
  8004e4:	ff 75 08             	pushl  0x8(%ebp)
  8004e7:	e8 05 00 00 00       	call   8004f1 <vprintfmt>
	va_end(ap);
  8004ec:	83 c4 10             	add    $0x10,%esp
}
  8004ef:	c9                   	leave  
  8004f0:	c3                   	ret    

008004f1 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8004f1:	55                   	push   %ebp
  8004f2:	89 e5                	mov    %esp,%ebp
  8004f4:	57                   	push   %edi
  8004f5:	56                   	push   %esi
  8004f6:	53                   	push   %ebx
  8004f7:	83 ec 2c             	sub    $0x2c,%esp
  8004fa:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8004fd:	8b 75 10             	mov    0x10(%ebp),%esi
  800500:	eb 13                	jmp    800515 <vprintfmt+0x24>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800502:	85 c0                	test   %eax,%eax
  800504:	0f 84 6d 03 00 00    	je     800877 <vprintfmt+0x386>
				return;
			putch(ch, putdat);
  80050a:	83 ec 08             	sub    $0x8,%esp
  80050d:	57                   	push   %edi
  80050e:	50                   	push   %eax
  80050f:	ff 55 08             	call   *0x8(%ebp)
  800512:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800515:	0f b6 06             	movzbl (%esi),%eax
  800518:	46                   	inc    %esi
  800519:	83 f8 25             	cmp    $0x25,%eax
  80051c:	75 e4                	jne    800502 <vprintfmt+0x11>
  80051e:	c6 45 dc 20          	movb   $0x20,-0x24(%ebp)
  800522:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  800529:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
  800530:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  800537:	b9 00 00 00 00       	mov    $0x0,%ecx
  80053c:	eb 28                	jmp    800566 <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80053e:	89 de                	mov    %ebx,%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  800540:	c6 45 dc 2d          	movb   $0x2d,-0x24(%ebp)
  800544:	eb 20                	jmp    800566 <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800546:	89 de                	mov    %ebx,%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800548:	c6 45 dc 30          	movb   $0x30,-0x24(%ebp)
  80054c:	eb 18                	jmp    800566 <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80054e:	89 de                	mov    %ebx,%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  800550:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800557:	eb 0d                	jmp    800566 <vprintfmt+0x75>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  800559:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80055c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80055f:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800566:	8a 06                	mov    (%esi),%al
  800568:	0f b6 d0             	movzbl %al,%edx
  80056b:	8d 5e 01             	lea    0x1(%esi),%ebx
  80056e:	83 e8 23             	sub    $0x23,%eax
  800571:	3c 55                	cmp    $0x55,%al
  800573:	0f 87 e0 02 00 00    	ja     800859 <vprintfmt+0x368>
  800579:	0f b6 c0             	movzbl %al,%eax
  80057c:	ff 24 85 40 10 80 00 	jmp    *0x801040(,%eax,4)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800583:	83 ea 30             	sub    $0x30,%edx
  800586:	89 55 d4             	mov    %edx,-0x2c(%ebp)
				ch = *fmt;
  800589:	0f be 03             	movsbl (%ebx),%eax
				if (ch < '0' || ch > '9')
  80058c:	8d 50 d0             	lea    -0x30(%eax),%edx
  80058f:	83 fa 09             	cmp    $0x9,%edx
  800592:	77 44                	ja     8005d8 <vprintfmt+0xe7>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800594:	89 de                	mov    %ebx,%esi
  800596:	8b 55 d4             	mov    -0x2c(%ebp),%edx
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800599:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
  80059a:	8d 14 92             	lea    (%edx,%edx,4),%edx
  80059d:	8d 54 50 d0          	lea    -0x30(%eax,%edx,2),%edx
				ch = *fmt;
  8005a1:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  8005a4:	8d 58 d0             	lea    -0x30(%eax),%ebx
  8005a7:	83 fb 09             	cmp    $0x9,%ebx
  8005aa:	76 ed                	jbe    800599 <vprintfmt+0xa8>
  8005ac:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  8005af:	eb 29                	jmp    8005da <vprintfmt+0xe9>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8005b1:	8b 45 14             	mov    0x14(%ebp),%eax
  8005b4:	8d 50 04             	lea    0x4(%eax),%edx
  8005b7:	89 55 14             	mov    %edx,0x14(%ebp)
  8005ba:	8b 00                	mov    (%eax),%eax
  8005bc:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005bf:	89 de                	mov    %ebx,%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8005c1:	eb 17                	jmp    8005da <vprintfmt+0xe9>

		case '.':
			if (width < 0)
  8005c3:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8005c7:	78 85                	js     80054e <vprintfmt+0x5d>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005c9:	89 de                	mov    %ebx,%esi
  8005cb:	eb 99                	jmp    800566 <vprintfmt+0x75>
  8005cd:	89 de                	mov    %ebx,%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8005cf:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
			goto reswitch;
  8005d6:	eb 8e                	jmp    800566 <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005d8:	89 de                	mov    %ebx,%esi
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  8005da:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8005de:	79 86                	jns    800566 <vprintfmt+0x75>
  8005e0:	e9 74 ff ff ff       	jmp    800559 <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8005e5:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005e6:	89 de                	mov    %ebx,%esi
  8005e8:	e9 79 ff ff ff       	jmp    800566 <vprintfmt+0x75>
  8005ed:	89 5d d8             	mov    %ebx,-0x28(%ebp)
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8005f0:	8b 45 14             	mov    0x14(%ebp),%eax
  8005f3:	8d 50 04             	lea    0x4(%eax),%edx
  8005f6:	89 55 14             	mov    %edx,0x14(%ebp)
  8005f9:	83 ec 08             	sub    $0x8,%esp
  8005fc:	57                   	push   %edi
  8005fd:	ff 30                	pushl  (%eax)
  8005ff:	ff 55 08             	call   *0x8(%ebp)
			break;
  800602:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800605:	8b 75 d8             	mov    -0x28(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800608:	e9 08 ff ff ff       	jmp    800515 <vprintfmt+0x24>
  80060d:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// error message
		case 'e':
			err = va_arg(ap, int);
  800610:	8b 45 14             	mov    0x14(%ebp),%eax
  800613:	8d 50 04             	lea    0x4(%eax),%edx
  800616:	89 55 14             	mov    %edx,0x14(%ebp)
  800619:	8b 00                	mov    (%eax),%eax
  80061b:	85 c0                	test   %eax,%eax
  80061d:	79 02                	jns    800621 <vprintfmt+0x130>
  80061f:	f7 d8                	neg    %eax
  800621:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800623:	83 f8 08             	cmp    $0x8,%eax
  800626:	7f 0b                	jg     800633 <vprintfmt+0x142>
  800628:	8b 04 85 a0 11 80 00 	mov    0x8011a0(,%eax,4),%eax
  80062f:	85 c0                	test   %eax,%eax
  800631:	75 1a                	jne    80064d <vprintfmt+0x15c>
				printfmt(putch, putdat, "error %d", err);
  800633:	52                   	push   %edx
  800634:	68 a0 0f 80 00       	push   $0x800fa0
  800639:	57                   	push   %edi
  80063a:	ff 75 08             	pushl  0x8(%ebp)
  80063d:	e8 92 fe ff ff       	call   8004d4 <printfmt>
  800642:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800645:	8b 75 d8             	mov    -0x28(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800648:	e9 c8 fe ff ff       	jmp    800515 <vprintfmt+0x24>
			else
				printfmt(putch, putdat, "%s", p);
  80064d:	50                   	push   %eax
  80064e:	68 a9 0f 80 00       	push   $0x800fa9
  800653:	57                   	push   %edi
  800654:	ff 75 08             	pushl  0x8(%ebp)
  800657:	e8 78 fe ff ff       	call   8004d4 <printfmt>
  80065c:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80065f:	8b 75 d8             	mov    -0x28(%ebp),%esi
  800662:	e9 ae fe ff ff       	jmp    800515 <vprintfmt+0x24>
  800667:	89 5d d8             	mov    %ebx,-0x28(%ebp)
  80066a:	89 de                	mov    %ebx,%esi
  80066c:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  80066f:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800672:	8b 45 14             	mov    0x14(%ebp),%eax
  800675:	8d 50 04             	lea    0x4(%eax),%edx
  800678:	89 55 14             	mov    %edx,0x14(%ebp)
  80067b:	8b 00                	mov    (%eax),%eax
  80067d:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800680:	85 c0                	test   %eax,%eax
  800682:	75 07                	jne    80068b <vprintfmt+0x19a>
				p = "(null)";
  800684:	c7 45 d0 99 0f 80 00 	movl   $0x800f99,-0x30(%ebp)
			if (width > 0 && padc != '-')
  80068b:	85 db                	test   %ebx,%ebx
  80068d:	7e 42                	jle    8006d1 <vprintfmt+0x1e0>
  80068f:	80 7d dc 2d          	cmpb   $0x2d,-0x24(%ebp)
  800693:	74 3c                	je     8006d1 <vprintfmt+0x1e0>
				for (width -= strnlen(p, precision); width > 0; width--)
  800695:	83 ec 08             	sub    $0x8,%esp
  800698:	51                   	push   %ecx
  800699:	ff 75 d0             	pushl  -0x30(%ebp)
  80069c:	e8 6f 02 00 00       	call   800910 <strnlen>
  8006a1:	29 c3                	sub    %eax,%ebx
  8006a3:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8006a6:	83 c4 10             	add    $0x10,%esp
  8006a9:	85 db                	test   %ebx,%ebx
  8006ab:	7e 24                	jle    8006d1 <vprintfmt+0x1e0>
					putch(padc, putdat);
  8006ad:	0f be 5d dc          	movsbl -0x24(%ebp),%ebx
  8006b1:	89 75 dc             	mov    %esi,-0x24(%ebp)
  8006b4:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  8006b7:	83 ec 08             	sub    $0x8,%esp
  8006ba:	57                   	push   %edi
  8006bb:	53                   	push   %ebx
  8006bc:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8006bf:	4e                   	dec    %esi
  8006c0:	83 c4 10             	add    $0x10,%esp
  8006c3:	85 f6                	test   %esi,%esi
  8006c5:	7f f0                	jg     8006b7 <vprintfmt+0x1c6>
  8006c7:	8b 75 dc             	mov    -0x24(%ebp),%esi
  8006ca:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8006d1:	8b 55 d0             	mov    -0x30(%ebp),%edx
  8006d4:	0f be 02             	movsbl (%edx),%eax
  8006d7:	85 c0                	test   %eax,%eax
  8006d9:	75 47                	jne    800722 <vprintfmt+0x231>
  8006db:	eb 37                	jmp    800714 <vprintfmt+0x223>
				if (altflag && (ch < ' ' || ch > '~'))
  8006dd:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8006e1:	74 16                	je     8006f9 <vprintfmt+0x208>
  8006e3:	8d 50 e0             	lea    -0x20(%eax),%edx
  8006e6:	83 fa 5e             	cmp    $0x5e,%edx
  8006e9:	76 0e                	jbe    8006f9 <vprintfmt+0x208>
					putch('?', putdat);
  8006eb:	83 ec 08             	sub    $0x8,%esp
  8006ee:	57                   	push   %edi
  8006ef:	6a 3f                	push   $0x3f
  8006f1:	ff 55 08             	call   *0x8(%ebp)
  8006f4:	83 c4 10             	add    $0x10,%esp
  8006f7:	eb 0b                	jmp    800704 <vprintfmt+0x213>
				else
					putch(ch, putdat);
  8006f9:	83 ec 08             	sub    $0x8,%esp
  8006fc:	57                   	push   %edi
  8006fd:	50                   	push   %eax
  8006fe:	ff 55 08             	call   *0x8(%ebp)
  800701:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800704:	ff 4d e4             	decl   -0x1c(%ebp)
  800707:	0f be 03             	movsbl (%ebx),%eax
  80070a:	85 c0                	test   %eax,%eax
  80070c:	74 03                	je     800711 <vprintfmt+0x220>
  80070e:	43                   	inc    %ebx
  80070f:	eb 1b                	jmp    80072c <vprintfmt+0x23b>
  800711:	8b 75 dc             	mov    -0x24(%ebp),%esi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800714:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800718:	7f 1e                	jg     800738 <vprintfmt+0x247>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80071a:	8b 75 d8             	mov    -0x28(%ebp),%esi
  80071d:	e9 f3 fd ff ff       	jmp    800515 <vprintfmt+0x24>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800722:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  800725:	43                   	inc    %ebx
  800726:	89 75 dc             	mov    %esi,-0x24(%ebp)
  800729:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  80072c:	85 f6                	test   %esi,%esi
  80072e:	78 ad                	js     8006dd <vprintfmt+0x1ec>
  800730:	4e                   	dec    %esi
  800731:	79 aa                	jns    8006dd <vprintfmt+0x1ec>
  800733:	8b 75 dc             	mov    -0x24(%ebp),%esi
  800736:	eb dc                	jmp    800714 <vprintfmt+0x223>
  800738:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80073b:	83 ec 08             	sub    $0x8,%esp
  80073e:	57                   	push   %edi
  80073f:	6a 20                	push   $0x20
  800741:	ff 55 08             	call   *0x8(%ebp)
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800744:	4b                   	dec    %ebx
  800745:	83 c4 10             	add    $0x10,%esp
  800748:	85 db                	test   %ebx,%ebx
  80074a:	7f ef                	jg     80073b <vprintfmt+0x24a>
  80074c:	e9 c4 fd ff ff       	jmp    800515 <vprintfmt+0x24>
  800751:	89 5d d8             	mov    %ebx,-0x28(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800754:	89 ca                	mov    %ecx,%edx
  800756:	8d 45 14             	lea    0x14(%ebp),%eax
  800759:	e8 2a fd ff ff       	call   800488 <getint>
  80075e:	89 c3                	mov    %eax,%ebx
  800760:	89 d6                	mov    %edx,%esi
			if ((long long) num < 0) {
  800762:	85 d2                	test   %edx,%edx
  800764:	78 0a                	js     800770 <vprintfmt+0x27f>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800766:	b8 0a 00 00 00       	mov    $0xa,%eax
  80076b:	e9 b0 00 00 00       	jmp    800820 <vprintfmt+0x32f>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  800770:	83 ec 08             	sub    $0x8,%esp
  800773:	57                   	push   %edi
  800774:	6a 2d                	push   $0x2d
  800776:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  800779:	f7 db                	neg    %ebx
  80077b:	83 d6 00             	adc    $0x0,%esi
  80077e:	f7 de                	neg    %esi
  800780:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800783:	b8 0a 00 00 00       	mov    $0xa,%eax
  800788:	e9 93 00 00 00       	jmp    800820 <vprintfmt+0x32f>
  80078d:	89 5d d8             	mov    %ebx,-0x28(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800790:	89 ca                	mov    %ecx,%edx
  800792:	8d 45 14             	lea    0x14(%ebp),%eax
  800795:	e8 b4 fc ff ff       	call   80044e <getuint>
  80079a:	89 c3                	mov    %eax,%ebx
  80079c:	89 d6                	mov    %edx,%esi
			base = 10;
  80079e:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  8007a3:	eb 7b                	jmp    800820 <vprintfmt+0x32f>
  8007a5:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// (unsigned) octal
		case 'o':
            // (MIT 6.828, lab1, Ex.8)  my code : 
            num = getint(&ap, lflag);
  8007a8:	89 ca                	mov    %ecx,%edx
  8007aa:	8d 45 14             	lea    0x14(%ebp),%eax
  8007ad:	e8 d6 fc ff ff       	call   800488 <getint>
  8007b2:	89 c3                	mov    %eax,%ebx
  8007b4:	89 d6                	mov    %edx,%esi
            if ((long long) num < 0) {
  8007b6:	85 d2                	test   %edx,%edx
  8007b8:	78 07                	js     8007c1 <vprintfmt+0x2d0>
                putch('-', putdat);
                num = -(long long) num;
            }
            base = 8;
  8007ba:	b8 08 00 00 00       	mov    $0x8,%eax
  8007bf:	eb 5f                	jmp    800820 <vprintfmt+0x32f>
		// (unsigned) octal
		case 'o':
            // (MIT 6.828, lab1, Ex.8)  my code : 
            num = getint(&ap, lflag);
            if ((long long) num < 0) {
                putch('-', putdat);
  8007c1:	83 ec 08             	sub    $0x8,%esp
  8007c4:	57                   	push   %edi
  8007c5:	6a 2d                	push   $0x2d
  8007c7:	ff 55 08             	call   *0x8(%ebp)
                num = -(long long) num;
  8007ca:	f7 db                	neg    %ebx
  8007cc:	83 d6 00             	adc    $0x0,%esi
  8007cf:	f7 de                	neg    %esi
  8007d1:	83 c4 10             	add    $0x10,%esp
            }
            base = 8;
  8007d4:	b8 08 00 00 00       	mov    $0x8,%eax
  8007d9:	eb 45                	jmp    800820 <vprintfmt+0x32f>
  8007db:	89 5d d8             	mov    %ebx,-0x28(%ebp)
            goto number;

        // pointer
		case 'p':
			putch('0', putdat);
  8007de:	83 ec 08             	sub    $0x8,%esp
  8007e1:	57                   	push   %edi
  8007e2:	6a 30                	push   $0x30
  8007e4:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  8007e7:	83 c4 08             	add    $0x8,%esp
  8007ea:	57                   	push   %edi
  8007eb:	6a 78                	push   $0x78
  8007ed:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8007f0:	8b 45 14             	mov    0x14(%ebp),%eax
  8007f3:	8d 50 04             	lea    0x4(%eax),%edx
  8007f6:	89 55 14             	mov    %edx,0x14(%ebp)

        // pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8007f9:	8b 18                	mov    (%eax),%ebx
  8007fb:	be 00 00 00 00       	mov    $0x0,%esi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800800:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800803:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  800808:	eb 16                	jmp    800820 <vprintfmt+0x32f>
  80080a:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  80080d:	89 ca                	mov    %ecx,%edx
  80080f:	8d 45 14             	lea    0x14(%ebp),%eax
  800812:	e8 37 fc ff ff       	call   80044e <getuint>
  800817:	89 c3                	mov    %eax,%ebx
  800819:	89 d6                	mov    %edx,%esi
			base = 16;
  80081b:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  800820:	83 ec 0c             	sub    $0xc,%esp
  800823:	0f be 55 dc          	movsbl -0x24(%ebp),%edx
  800827:	52                   	push   %edx
  800828:	ff 75 e4             	pushl  -0x1c(%ebp)
  80082b:	50                   	push   %eax
  80082c:	56                   	push   %esi
  80082d:	53                   	push   %ebx
  80082e:	89 fa                	mov    %edi,%edx
  800830:	8b 45 08             	mov    0x8(%ebp),%eax
  800833:	e8 68 fb ff ff       	call   8003a0 <printnum>
			break;
  800838:	83 c4 20             	add    $0x20,%esp
  80083b:	8b 75 d8             	mov    -0x28(%ebp),%esi
  80083e:	e9 d2 fc ff ff       	jmp    800515 <vprintfmt+0x24>
  800843:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800846:	83 ec 08             	sub    $0x8,%esp
  800849:	57                   	push   %edi
  80084a:	52                   	push   %edx
  80084b:	ff 55 08             	call   *0x8(%ebp)
			break;
  80084e:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800851:	8b 75 d8             	mov    -0x28(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800854:	e9 bc fc ff ff       	jmp    800515 <vprintfmt+0x24>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800859:	83 ec 08             	sub    $0x8,%esp
  80085c:	57                   	push   %edi
  80085d:	6a 25                	push   $0x25
  80085f:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800862:	83 c4 10             	add    $0x10,%esp
  800865:	eb 02                	jmp    800869 <vprintfmt+0x378>
  800867:	89 c6                	mov    %eax,%esi
  800869:	8d 46 ff             	lea    -0x1(%esi),%eax
  80086c:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  800870:	75 f5                	jne    800867 <vprintfmt+0x376>
  800872:	e9 9e fc ff ff       	jmp    800515 <vprintfmt+0x24>
				/* do nothing */;
			break;
		}
	}
}
  800877:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80087a:	5b                   	pop    %ebx
  80087b:	5e                   	pop    %esi
  80087c:	5f                   	pop    %edi
  80087d:	c9                   	leave  
  80087e:	c3                   	ret    

0080087f <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80087f:	55                   	push   %ebp
  800880:	89 e5                	mov    %esp,%ebp
  800882:	83 ec 18             	sub    $0x18,%esp
  800885:	8b 45 08             	mov    0x8(%ebp),%eax
  800888:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80088b:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80088e:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800892:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800895:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80089c:	85 c0                	test   %eax,%eax
  80089e:	74 26                	je     8008c6 <vsnprintf+0x47>
  8008a0:	85 d2                	test   %edx,%edx
  8008a2:	7e 29                	jle    8008cd <vsnprintf+0x4e>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8008a4:	ff 75 14             	pushl  0x14(%ebp)
  8008a7:	ff 75 10             	pushl  0x10(%ebp)
  8008aa:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8008ad:	50                   	push   %eax
  8008ae:	68 ba 04 80 00       	push   $0x8004ba
  8008b3:	e8 39 fc ff ff       	call   8004f1 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8008b8:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8008bb:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8008be:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8008c1:	83 c4 10             	add    $0x10,%esp
  8008c4:	eb 0c                	jmp    8008d2 <vsnprintf+0x53>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8008c6:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8008cb:	eb 05                	jmp    8008d2 <vsnprintf+0x53>
  8008cd:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8008d2:	c9                   	leave  
  8008d3:	c3                   	ret    

008008d4 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8008d4:	55                   	push   %ebp
  8008d5:	89 e5                	mov    %esp,%ebp
  8008d7:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8008da:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8008dd:	50                   	push   %eax
  8008de:	ff 75 10             	pushl  0x10(%ebp)
  8008e1:	ff 75 0c             	pushl  0xc(%ebp)
  8008e4:	ff 75 08             	pushl  0x8(%ebp)
  8008e7:	e8 93 ff ff ff       	call   80087f <vsnprintf>
	va_end(ap);

	return rc;
}
  8008ec:	c9                   	leave  
  8008ed:	c3                   	ret    
	...

008008f0 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8008f0:	55                   	push   %ebp
  8008f1:	89 e5                	mov    %esp,%ebp
  8008f3:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8008f6:	80 3a 00             	cmpb   $0x0,(%edx)
  8008f9:	74 0e                	je     800909 <strlen+0x19>
  8008fb:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  800900:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800901:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800905:	75 f9                	jne    800900 <strlen+0x10>
  800907:	eb 05                	jmp    80090e <strlen+0x1e>
  800909:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  80090e:	c9                   	leave  
  80090f:	c3                   	ret    

00800910 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800910:	55                   	push   %ebp
  800911:	89 e5                	mov    %esp,%ebp
  800913:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800916:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800919:	85 d2                	test   %edx,%edx
  80091b:	74 17                	je     800934 <strnlen+0x24>
  80091d:	80 39 00             	cmpb   $0x0,(%ecx)
  800920:	74 19                	je     80093b <strnlen+0x2b>
  800922:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  800927:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800928:	39 d0                	cmp    %edx,%eax
  80092a:	74 14                	je     800940 <strnlen+0x30>
  80092c:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800930:	75 f5                	jne    800927 <strnlen+0x17>
  800932:	eb 0c                	jmp    800940 <strnlen+0x30>
  800934:	b8 00 00 00 00       	mov    $0x0,%eax
  800939:	eb 05                	jmp    800940 <strnlen+0x30>
  80093b:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  800940:	c9                   	leave  
  800941:	c3                   	ret    

00800942 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800942:	55                   	push   %ebp
  800943:	89 e5                	mov    %esp,%ebp
  800945:	53                   	push   %ebx
  800946:	8b 45 08             	mov    0x8(%ebp),%eax
  800949:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  80094c:	ba 00 00 00 00       	mov    $0x0,%edx
  800951:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  800954:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800957:	42                   	inc    %edx
  800958:	84 c9                	test   %cl,%cl
  80095a:	75 f5                	jne    800951 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  80095c:	5b                   	pop    %ebx
  80095d:	c9                   	leave  
  80095e:	c3                   	ret    

0080095f <strcat>:

char *
strcat(char *dst, const char *src)
{
  80095f:	55                   	push   %ebp
  800960:	89 e5                	mov    %esp,%ebp
  800962:	53                   	push   %ebx
  800963:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800966:	53                   	push   %ebx
  800967:	e8 84 ff ff ff       	call   8008f0 <strlen>
  80096c:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  80096f:	ff 75 0c             	pushl  0xc(%ebp)
  800972:	8d 04 03             	lea    (%ebx,%eax,1),%eax
  800975:	50                   	push   %eax
  800976:	e8 c7 ff ff ff       	call   800942 <strcpy>
	return dst;
}
  80097b:	89 d8                	mov    %ebx,%eax
  80097d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800980:	c9                   	leave  
  800981:	c3                   	ret    

00800982 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800982:	55                   	push   %ebp
  800983:	89 e5                	mov    %esp,%ebp
  800985:	56                   	push   %esi
  800986:	53                   	push   %ebx
  800987:	8b 45 08             	mov    0x8(%ebp),%eax
  80098a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80098d:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800990:	85 f6                	test   %esi,%esi
  800992:	74 15                	je     8009a9 <strncpy+0x27>
  800994:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
  800999:	8a 1a                	mov    (%edx),%bl
  80099b:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80099e:	80 3a 01             	cmpb   $0x1,(%edx)
  8009a1:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8009a4:	41                   	inc    %ecx
  8009a5:	39 ce                	cmp    %ecx,%esi
  8009a7:	77 f0                	ja     800999 <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8009a9:	5b                   	pop    %ebx
  8009aa:	5e                   	pop    %esi
  8009ab:	c9                   	leave  
  8009ac:	c3                   	ret    

008009ad <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8009ad:	55                   	push   %ebp
  8009ae:	89 e5                	mov    %esp,%ebp
  8009b0:	57                   	push   %edi
  8009b1:	56                   	push   %esi
  8009b2:	53                   	push   %ebx
  8009b3:	8b 7d 08             	mov    0x8(%ebp),%edi
  8009b6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8009b9:	8b 75 10             	mov    0x10(%ebp),%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8009bc:	85 f6                	test   %esi,%esi
  8009be:	74 32                	je     8009f2 <strlcpy+0x45>
		while (--size > 0 && *src != '\0')
  8009c0:	83 fe 01             	cmp    $0x1,%esi
  8009c3:	74 22                	je     8009e7 <strlcpy+0x3a>
  8009c5:	8a 0b                	mov    (%ebx),%cl
  8009c7:	84 c9                	test   %cl,%cl
  8009c9:	74 20                	je     8009eb <strlcpy+0x3e>
  8009cb:	89 f8                	mov    %edi,%eax
  8009cd:	ba 00 00 00 00       	mov    $0x0,%edx
	}
	return ret;
}

size_t
strlcpy(char *dst, const char *src, size_t size)
  8009d2:	83 ee 02             	sub    $0x2,%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8009d5:	88 08                	mov    %cl,(%eax)
  8009d7:	40                   	inc    %eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8009d8:	39 f2                	cmp    %esi,%edx
  8009da:	74 11                	je     8009ed <strlcpy+0x40>
  8009dc:	8a 4c 13 01          	mov    0x1(%ebx,%edx,1),%cl
  8009e0:	42                   	inc    %edx
  8009e1:	84 c9                	test   %cl,%cl
  8009e3:	75 f0                	jne    8009d5 <strlcpy+0x28>
  8009e5:	eb 06                	jmp    8009ed <strlcpy+0x40>
  8009e7:	89 f8                	mov    %edi,%eax
  8009e9:	eb 02                	jmp    8009ed <strlcpy+0x40>
  8009eb:	89 f8                	mov    %edi,%eax
			*dst++ = *src++;
		*dst = '\0';
  8009ed:	c6 00 00             	movb   $0x0,(%eax)
  8009f0:	eb 02                	jmp    8009f4 <strlcpy+0x47>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8009f2:	89 f8                	mov    %edi,%eax
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
		*dst = '\0';
	}
	return dst - dst_in;
  8009f4:	29 f8                	sub    %edi,%eax
}
  8009f6:	5b                   	pop    %ebx
  8009f7:	5e                   	pop    %esi
  8009f8:	5f                   	pop    %edi
  8009f9:	c9                   	leave  
  8009fa:	c3                   	ret    

008009fb <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8009fb:	55                   	push   %ebp
  8009fc:	89 e5                	mov    %esp,%ebp
  8009fe:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a01:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800a04:	8a 01                	mov    (%ecx),%al
  800a06:	84 c0                	test   %al,%al
  800a08:	74 10                	je     800a1a <strcmp+0x1f>
  800a0a:	3a 02                	cmp    (%edx),%al
  800a0c:	75 0c                	jne    800a1a <strcmp+0x1f>
		p++, q++;
  800a0e:	41                   	inc    %ecx
  800a0f:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800a10:	8a 01                	mov    (%ecx),%al
  800a12:	84 c0                	test   %al,%al
  800a14:	74 04                	je     800a1a <strcmp+0x1f>
  800a16:	3a 02                	cmp    (%edx),%al
  800a18:	74 f4                	je     800a0e <strcmp+0x13>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800a1a:	0f b6 c0             	movzbl %al,%eax
  800a1d:	0f b6 12             	movzbl (%edx),%edx
  800a20:	29 d0                	sub    %edx,%eax
}
  800a22:	c9                   	leave  
  800a23:	c3                   	ret    

00800a24 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800a24:	55                   	push   %ebp
  800a25:	89 e5                	mov    %esp,%ebp
  800a27:	53                   	push   %ebx
  800a28:	8b 55 08             	mov    0x8(%ebp),%edx
  800a2b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a2e:	8b 45 10             	mov    0x10(%ebp),%eax
	while (n > 0 && *p && *p == *q)
  800a31:	85 c0                	test   %eax,%eax
  800a33:	74 1b                	je     800a50 <strncmp+0x2c>
  800a35:	8a 1a                	mov    (%edx),%bl
  800a37:	84 db                	test   %bl,%bl
  800a39:	74 24                	je     800a5f <strncmp+0x3b>
  800a3b:	3a 19                	cmp    (%ecx),%bl
  800a3d:	75 20                	jne    800a5f <strncmp+0x3b>
  800a3f:	48                   	dec    %eax
  800a40:	74 15                	je     800a57 <strncmp+0x33>
		n--, p++, q++;
  800a42:	42                   	inc    %edx
  800a43:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800a44:	8a 1a                	mov    (%edx),%bl
  800a46:	84 db                	test   %bl,%bl
  800a48:	74 15                	je     800a5f <strncmp+0x3b>
  800a4a:	3a 19                	cmp    (%ecx),%bl
  800a4c:	74 f1                	je     800a3f <strncmp+0x1b>
  800a4e:	eb 0f                	jmp    800a5f <strncmp+0x3b>
		n--, p++, q++;
	if (n == 0)
		return 0;
  800a50:	b8 00 00 00 00       	mov    $0x0,%eax
  800a55:	eb 05                	jmp    800a5c <strncmp+0x38>
  800a57:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800a5c:	5b                   	pop    %ebx
  800a5d:	c9                   	leave  
  800a5e:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800a5f:	0f b6 02             	movzbl (%edx),%eax
  800a62:	0f b6 11             	movzbl (%ecx),%edx
  800a65:	29 d0                	sub    %edx,%eax
  800a67:	eb f3                	jmp    800a5c <strncmp+0x38>

00800a69 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800a69:	55                   	push   %ebp
  800a6a:	89 e5                	mov    %esp,%ebp
  800a6c:	8b 45 08             	mov    0x8(%ebp),%eax
  800a6f:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800a72:	8a 10                	mov    (%eax),%dl
  800a74:	84 d2                	test   %dl,%dl
  800a76:	74 18                	je     800a90 <strchr+0x27>
		if (*s == c)
  800a78:	38 ca                	cmp    %cl,%dl
  800a7a:	75 06                	jne    800a82 <strchr+0x19>
  800a7c:	eb 17                	jmp    800a95 <strchr+0x2c>
  800a7e:	38 ca                	cmp    %cl,%dl
  800a80:	74 13                	je     800a95 <strchr+0x2c>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800a82:	40                   	inc    %eax
  800a83:	8a 10                	mov    (%eax),%dl
  800a85:	84 d2                	test   %dl,%dl
  800a87:	75 f5                	jne    800a7e <strchr+0x15>
		if (*s == c)
			return (char *) s;
	return 0;
  800a89:	b8 00 00 00 00       	mov    $0x0,%eax
  800a8e:	eb 05                	jmp    800a95 <strchr+0x2c>
  800a90:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a95:	c9                   	leave  
  800a96:	c3                   	ret    

00800a97 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800a97:	55                   	push   %ebp
  800a98:	89 e5                	mov    %esp,%ebp
  800a9a:	8b 45 08             	mov    0x8(%ebp),%eax
  800a9d:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800aa0:	8a 10                	mov    (%eax),%dl
  800aa2:	84 d2                	test   %dl,%dl
  800aa4:	74 11                	je     800ab7 <strfind+0x20>
		if (*s == c)
  800aa6:	38 ca                	cmp    %cl,%dl
  800aa8:	75 06                	jne    800ab0 <strfind+0x19>
  800aaa:	eb 0b                	jmp    800ab7 <strfind+0x20>
  800aac:	38 ca                	cmp    %cl,%dl
  800aae:	74 07                	je     800ab7 <strfind+0x20>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800ab0:	40                   	inc    %eax
  800ab1:	8a 10                	mov    (%eax),%dl
  800ab3:	84 d2                	test   %dl,%dl
  800ab5:	75 f5                	jne    800aac <strfind+0x15>
		if (*s == c)
			break;
	return (char *) s;
}
  800ab7:	c9                   	leave  
  800ab8:	c3                   	ret    

00800ab9 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800ab9:	55                   	push   %ebp
  800aba:	89 e5                	mov    %esp,%ebp
  800abc:	57                   	push   %edi
  800abd:	56                   	push   %esi
  800abe:	53                   	push   %ebx
  800abf:	8b 7d 08             	mov    0x8(%ebp),%edi
  800ac2:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ac5:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800ac8:	85 c9                	test   %ecx,%ecx
  800aca:	74 30                	je     800afc <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800acc:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800ad2:	75 25                	jne    800af9 <memset+0x40>
  800ad4:	f6 c1 03             	test   $0x3,%cl
  800ad7:	75 20                	jne    800af9 <memset+0x40>
		c &= 0xFF;
  800ad9:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800adc:	89 d3                	mov    %edx,%ebx
  800ade:	c1 e3 08             	shl    $0x8,%ebx
  800ae1:	89 d6                	mov    %edx,%esi
  800ae3:	c1 e6 18             	shl    $0x18,%esi
  800ae6:	89 d0                	mov    %edx,%eax
  800ae8:	c1 e0 10             	shl    $0x10,%eax
  800aeb:	09 f0                	or     %esi,%eax
  800aed:	09 d0                	or     %edx,%eax
  800aef:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800af1:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800af4:	fc                   	cld    
  800af5:	f3 ab                	rep stos %eax,%es:(%edi)
  800af7:	eb 03                	jmp    800afc <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800af9:	fc                   	cld    
  800afa:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800afc:	89 f8                	mov    %edi,%eax
  800afe:	5b                   	pop    %ebx
  800aff:	5e                   	pop    %esi
  800b00:	5f                   	pop    %edi
  800b01:	c9                   	leave  
  800b02:	c3                   	ret    

00800b03 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800b03:	55                   	push   %ebp
  800b04:	89 e5                	mov    %esp,%ebp
  800b06:	57                   	push   %edi
  800b07:	56                   	push   %esi
  800b08:	8b 45 08             	mov    0x8(%ebp),%eax
  800b0b:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b0e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800b11:	39 c6                	cmp    %eax,%esi
  800b13:	73 34                	jae    800b49 <memmove+0x46>
  800b15:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800b18:	39 d0                	cmp    %edx,%eax
  800b1a:	73 2d                	jae    800b49 <memmove+0x46>
		s += n;
		d += n;
  800b1c:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b1f:	f6 c2 03             	test   $0x3,%dl
  800b22:	75 1b                	jne    800b3f <memmove+0x3c>
  800b24:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800b2a:	75 13                	jne    800b3f <memmove+0x3c>
  800b2c:	f6 c1 03             	test   $0x3,%cl
  800b2f:	75 0e                	jne    800b3f <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800b31:	83 ef 04             	sub    $0x4,%edi
  800b34:	8d 72 fc             	lea    -0x4(%edx),%esi
  800b37:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800b3a:	fd                   	std    
  800b3b:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b3d:	eb 07                	jmp    800b46 <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800b3f:	4f                   	dec    %edi
  800b40:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800b43:	fd                   	std    
  800b44:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800b46:	fc                   	cld    
  800b47:	eb 20                	jmp    800b69 <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b49:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800b4f:	75 13                	jne    800b64 <memmove+0x61>
  800b51:	a8 03                	test   $0x3,%al
  800b53:	75 0f                	jne    800b64 <memmove+0x61>
  800b55:	f6 c1 03             	test   $0x3,%cl
  800b58:	75 0a                	jne    800b64 <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800b5a:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800b5d:	89 c7                	mov    %eax,%edi
  800b5f:	fc                   	cld    
  800b60:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b62:	eb 05                	jmp    800b69 <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800b64:	89 c7                	mov    %eax,%edi
  800b66:	fc                   	cld    
  800b67:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800b69:	5e                   	pop    %esi
  800b6a:	5f                   	pop    %edi
  800b6b:	c9                   	leave  
  800b6c:	c3                   	ret    

00800b6d <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800b6d:	55                   	push   %ebp
  800b6e:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800b70:	ff 75 10             	pushl  0x10(%ebp)
  800b73:	ff 75 0c             	pushl  0xc(%ebp)
  800b76:	ff 75 08             	pushl  0x8(%ebp)
  800b79:	e8 85 ff ff ff       	call   800b03 <memmove>
}
  800b7e:	c9                   	leave  
  800b7f:	c3                   	ret    

00800b80 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800b80:	55                   	push   %ebp
  800b81:	89 e5                	mov    %esp,%ebp
  800b83:	57                   	push   %edi
  800b84:	56                   	push   %esi
  800b85:	53                   	push   %ebx
  800b86:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800b89:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b8c:	8b 7d 10             	mov    0x10(%ebp),%edi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b8f:	85 ff                	test   %edi,%edi
  800b91:	74 32                	je     800bc5 <memcmp+0x45>
		if (*s1 != *s2)
  800b93:	8a 03                	mov    (%ebx),%al
  800b95:	8a 0e                	mov    (%esi),%cl
  800b97:	38 c8                	cmp    %cl,%al
  800b99:	74 19                	je     800bb4 <memcmp+0x34>
  800b9b:	eb 0d                	jmp    800baa <memcmp+0x2a>
  800b9d:	8a 44 13 01          	mov    0x1(%ebx,%edx,1),%al
  800ba1:	8a 4c 16 01          	mov    0x1(%esi,%edx,1),%cl
  800ba5:	42                   	inc    %edx
  800ba6:	38 c8                	cmp    %cl,%al
  800ba8:	74 10                	je     800bba <memcmp+0x3a>
			return (int) *s1 - (int) *s2;
  800baa:	0f b6 c0             	movzbl %al,%eax
  800bad:	0f b6 c9             	movzbl %cl,%ecx
  800bb0:	29 c8                	sub    %ecx,%eax
  800bb2:	eb 16                	jmp    800bca <memcmp+0x4a>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800bb4:	4f                   	dec    %edi
  800bb5:	ba 00 00 00 00       	mov    $0x0,%edx
  800bba:	39 fa                	cmp    %edi,%edx
  800bbc:	75 df                	jne    800b9d <memcmp+0x1d>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800bbe:	b8 00 00 00 00       	mov    $0x0,%eax
  800bc3:	eb 05                	jmp    800bca <memcmp+0x4a>
  800bc5:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800bca:	5b                   	pop    %ebx
  800bcb:	5e                   	pop    %esi
  800bcc:	5f                   	pop    %edi
  800bcd:	c9                   	leave  
  800bce:	c3                   	ret    

00800bcf <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800bcf:	55                   	push   %ebp
  800bd0:	89 e5                	mov    %esp,%ebp
  800bd2:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800bd5:	89 c2                	mov    %eax,%edx
  800bd7:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800bda:	39 d0                	cmp    %edx,%eax
  800bdc:	73 12                	jae    800bf0 <memfind+0x21>
		if (*(const unsigned char *) s == (unsigned char) c)
  800bde:	8a 4d 0c             	mov    0xc(%ebp),%cl
  800be1:	38 08                	cmp    %cl,(%eax)
  800be3:	75 06                	jne    800beb <memfind+0x1c>
  800be5:	eb 09                	jmp    800bf0 <memfind+0x21>
  800be7:	38 08                	cmp    %cl,(%eax)
  800be9:	74 05                	je     800bf0 <memfind+0x21>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800beb:	40                   	inc    %eax
  800bec:	39 c2                	cmp    %eax,%edx
  800bee:	77 f7                	ja     800be7 <memfind+0x18>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800bf0:	c9                   	leave  
  800bf1:	c3                   	ret    

00800bf2 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800bf2:	55                   	push   %ebp
  800bf3:	89 e5                	mov    %esp,%ebp
  800bf5:	57                   	push   %edi
  800bf6:	56                   	push   %esi
  800bf7:	53                   	push   %ebx
  800bf8:	8b 55 08             	mov    0x8(%ebp),%edx
  800bfb:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800bfe:	eb 01                	jmp    800c01 <strtol+0xf>
		s++;
  800c00:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800c01:	8a 02                	mov    (%edx),%al
  800c03:	3c 20                	cmp    $0x20,%al
  800c05:	74 f9                	je     800c00 <strtol+0xe>
  800c07:	3c 09                	cmp    $0x9,%al
  800c09:	74 f5                	je     800c00 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800c0b:	3c 2b                	cmp    $0x2b,%al
  800c0d:	75 08                	jne    800c17 <strtol+0x25>
		s++;
  800c0f:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800c10:	bf 00 00 00 00       	mov    $0x0,%edi
  800c15:	eb 13                	jmp    800c2a <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800c17:	3c 2d                	cmp    $0x2d,%al
  800c19:	75 0a                	jne    800c25 <strtol+0x33>
		s++, neg = 1;
  800c1b:	8d 52 01             	lea    0x1(%edx),%edx
  800c1e:	bf 01 00 00 00       	mov    $0x1,%edi
  800c23:	eb 05                	jmp    800c2a <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800c25:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800c2a:	85 db                	test   %ebx,%ebx
  800c2c:	74 05                	je     800c33 <strtol+0x41>
  800c2e:	83 fb 10             	cmp    $0x10,%ebx
  800c31:	75 28                	jne    800c5b <strtol+0x69>
  800c33:	8a 02                	mov    (%edx),%al
  800c35:	3c 30                	cmp    $0x30,%al
  800c37:	75 10                	jne    800c49 <strtol+0x57>
  800c39:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800c3d:	75 0a                	jne    800c49 <strtol+0x57>
		s += 2, base = 16;
  800c3f:	83 c2 02             	add    $0x2,%edx
  800c42:	bb 10 00 00 00       	mov    $0x10,%ebx
  800c47:	eb 12                	jmp    800c5b <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  800c49:	85 db                	test   %ebx,%ebx
  800c4b:	75 0e                	jne    800c5b <strtol+0x69>
  800c4d:	3c 30                	cmp    $0x30,%al
  800c4f:	75 05                	jne    800c56 <strtol+0x64>
		s++, base = 8;
  800c51:	42                   	inc    %edx
  800c52:	b3 08                	mov    $0x8,%bl
  800c54:	eb 05                	jmp    800c5b <strtol+0x69>
	else if (base == 0)
		base = 10;
  800c56:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800c5b:	b8 00 00 00 00       	mov    $0x0,%eax
  800c60:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800c62:	8a 0a                	mov    (%edx),%cl
  800c64:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800c67:	80 fb 09             	cmp    $0x9,%bl
  800c6a:	77 08                	ja     800c74 <strtol+0x82>
			dig = *s - '0';
  800c6c:	0f be c9             	movsbl %cl,%ecx
  800c6f:	83 e9 30             	sub    $0x30,%ecx
  800c72:	eb 1e                	jmp    800c92 <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  800c74:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800c77:	80 fb 19             	cmp    $0x19,%bl
  800c7a:	77 08                	ja     800c84 <strtol+0x92>
			dig = *s - 'a' + 10;
  800c7c:	0f be c9             	movsbl %cl,%ecx
  800c7f:	83 e9 57             	sub    $0x57,%ecx
  800c82:	eb 0e                	jmp    800c92 <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  800c84:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800c87:	80 fb 19             	cmp    $0x19,%bl
  800c8a:	77 13                	ja     800c9f <strtol+0xad>
			dig = *s - 'A' + 10;
  800c8c:	0f be c9             	movsbl %cl,%ecx
  800c8f:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800c92:	39 f1                	cmp    %esi,%ecx
  800c94:	7d 0d                	jge    800ca3 <strtol+0xb1>
			break;
		s++, val = (val * base) + dig;
  800c96:	42                   	inc    %edx
  800c97:	0f af c6             	imul   %esi,%eax
  800c9a:	8d 04 01             	lea    (%ecx,%eax,1),%eax
		// we don't properly detect overflow!
	}
  800c9d:	eb c3                	jmp    800c62 <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800c9f:	89 c1                	mov    %eax,%ecx
  800ca1:	eb 02                	jmp    800ca5 <strtol+0xb3>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800ca3:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800ca5:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800ca9:	74 05                	je     800cb0 <strtol+0xbe>
		*endptr = (char *) s;
  800cab:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800cae:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800cb0:	85 ff                	test   %edi,%edi
  800cb2:	74 04                	je     800cb8 <strtol+0xc6>
  800cb4:	89 c8                	mov    %ecx,%eax
  800cb6:	f7 d8                	neg    %eax
}
  800cb8:	5b                   	pop    %ebx
  800cb9:	5e                   	pop    %esi
  800cba:	5f                   	pop    %edi
  800cbb:	c9                   	leave  
  800cbc:	c3                   	ret    
  800cbd:	00 00                	add    %al,(%eax)
	...

00800cc0 <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  800cc0:	55                   	push   %ebp
  800cc1:	89 e5                	mov    %esp,%ebp
  800cc3:	57                   	push   %edi
  800cc4:	56                   	push   %esi
  800cc5:	83 ec 10             	sub    $0x10,%esp
  800cc8:	8b 7d 08             	mov    0x8(%ebp),%edi
  800ccb:	8b 4d 10             	mov    0x10(%ebp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  800cce:	89 7d f0             	mov    %edi,-0x10(%ebp)
  800cd1:	8b 75 0c             	mov    0xc(%ebp),%esi
  const DWunion dd = {.ll = d};
  800cd4:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  800cd7:	8b 45 14             	mov    0x14(%ebp),%eax
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  800cda:	85 c0                	test   %eax,%eax
  800cdc:	75 2e                	jne    800d0c <__udivdi3+0x4c>
    {
      if (d0 > n1)
  800cde:	39 f1                	cmp    %esi,%ecx
  800ce0:	77 5a                	ja     800d3c <__udivdi3+0x7c>
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  800ce2:	85 c9                	test   %ecx,%ecx
  800ce4:	75 0b                	jne    800cf1 <__udivdi3+0x31>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  800ce6:	b8 01 00 00 00       	mov    $0x1,%eax
  800ceb:	31 d2                	xor    %edx,%edx
  800ced:	f7 f1                	div    %ecx
  800cef:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  800cf1:	31 d2                	xor    %edx,%edx
  800cf3:	89 f0                	mov    %esi,%eax
  800cf5:	f7 f1                	div    %ecx
  800cf7:	89 c6                	mov    %eax,%esi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800cf9:	89 f8                	mov    %edi,%eax
  800cfb:	f7 f1                	div    %ecx
  800cfd:	89 c7                	mov    %eax,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800cff:	89 f8                	mov    %edi,%eax
  800d01:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800d03:	83 c4 10             	add    $0x10,%esp
  800d06:	5e                   	pop    %esi
  800d07:	5f                   	pop    %edi
  800d08:	c9                   	leave  
  800d09:	c3                   	ret    
  800d0a:	66 90                	xchg   %ax,%ax
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  800d0c:	39 f0                	cmp    %esi,%eax
  800d0e:	77 1c                	ja     800d2c <__udivdi3+0x6c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  800d10:	0f bd f8             	bsr    %eax,%edi
	  if (bm == 0)
  800d13:	83 f7 1f             	xor    $0x1f,%edi
  800d16:	75 3c                	jne    800d54 <__udivdi3+0x94>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  800d18:	39 f0                	cmp    %esi,%eax
  800d1a:	0f 82 90 00 00 00    	jb     800db0 <__udivdi3+0xf0>
  800d20:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800d23:	39 55 f4             	cmp    %edx,-0xc(%ebp)
  800d26:	0f 86 84 00 00 00    	jbe    800db0 <__udivdi3+0xf0>
  800d2c:	31 f6                	xor    %esi,%esi
  800d2e:	31 ff                	xor    %edi,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800d30:	89 f8                	mov    %edi,%eax
  800d32:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800d34:	83 c4 10             	add    $0x10,%esp
  800d37:	5e                   	pop    %esi
  800d38:	5f                   	pop    %edi
  800d39:	c9                   	leave  
  800d3a:	c3                   	ret    
  800d3b:	90                   	nop
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800d3c:	89 f2                	mov    %esi,%edx
  800d3e:	89 f8                	mov    %edi,%eax
  800d40:	f7 f1                	div    %ecx
  800d42:	89 c7                	mov    %eax,%edi
  800d44:	31 f6                	xor    %esi,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800d46:	89 f8                	mov    %edi,%eax
  800d48:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800d4a:	83 c4 10             	add    $0x10,%esp
  800d4d:	5e                   	pop    %esi
  800d4e:	5f                   	pop    %edi
  800d4f:	c9                   	leave  
  800d50:	c3                   	ret    
  800d51:	8d 76 00             	lea    0x0(%esi),%esi
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  800d54:	89 f9                	mov    %edi,%ecx
  800d56:	d3 e0                	shl    %cl,%eax
  800d58:	89 45 e8             	mov    %eax,-0x18(%ebp)
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  800d5b:	b8 20 00 00 00       	mov    $0x20,%eax
  800d60:	29 f8                	sub    %edi,%eax

	      d1 = (d1 << bm) | (d0 >> b);
  800d62:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800d65:	88 c1                	mov    %al,%cl
  800d67:	d3 ea                	shr    %cl,%edx
  800d69:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  800d6c:	09 ca                	or     %ecx,%edx
  800d6e:	89 55 ec             	mov    %edx,-0x14(%ebp)
	      d0 = d0 << bm;
  800d71:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800d74:	89 f9                	mov    %edi,%ecx
  800d76:	d3 e2                	shl    %cl,%edx
  800d78:	89 55 f4             	mov    %edx,-0xc(%ebp)
	      n2 = n1 >> b;
  800d7b:	89 f2                	mov    %esi,%edx
  800d7d:	88 c1                	mov    %al,%cl
  800d7f:	d3 ea                	shr    %cl,%edx
  800d81:	89 55 e8             	mov    %edx,-0x18(%ebp)
	      n1 = (n1 << bm) | (n0 >> b);
  800d84:	89 f2                	mov    %esi,%edx
  800d86:	89 f9                	mov    %edi,%ecx
  800d88:	d3 e2                	shl    %cl,%edx
  800d8a:	8b 75 f0             	mov    -0x10(%ebp),%esi
  800d8d:	88 c1                	mov    %al,%cl
  800d8f:	d3 ee                	shr    %cl,%esi
  800d91:	09 d6                	or     %edx,%esi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  800d93:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  800d96:	89 f0                	mov    %esi,%eax
  800d98:	89 ca                	mov    %ecx,%edx
  800d9a:	f7 75 ec             	divl   -0x14(%ebp)
  800d9d:	89 d1                	mov    %edx,%ecx
  800d9f:	89 c6                	mov    %eax,%esi
	      umul_ppmm (m1, m0, q0, d0);
  800da1:	f7 65 f4             	mull   -0xc(%ebp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800da4:	39 d1                	cmp    %edx,%ecx
  800da6:	72 28                	jb     800dd0 <__udivdi3+0x110>
  800da8:	74 1a                	je     800dc4 <__udivdi3+0x104>
  800daa:	89 f7                	mov    %esi,%edi
  800dac:	31 f6                	xor    %esi,%esi
  800dae:	eb 80                	jmp    800d30 <__udivdi3+0x70>
	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  800db0:	31 f6                	xor    %esi,%esi
  800db2:	bf 01 00 00 00       	mov    $0x1,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800db7:	89 f8                	mov    %edi,%eax
  800db9:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800dbb:	83 c4 10             	add    $0x10,%esp
  800dbe:	5e                   	pop    %esi
  800dbf:	5f                   	pop    %edi
  800dc0:	c9                   	leave  
  800dc1:	c3                   	ret    
  800dc2:	66 90                	xchg   %ax,%ax

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  800dc4:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800dc7:	89 f9                	mov    %edi,%ecx
  800dc9:	d3 e2                	shl    %cl,%edx

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800dcb:	39 c2                	cmp    %eax,%edx
  800dcd:	73 db                	jae    800daa <__udivdi3+0xea>
  800dcf:	90                   	nop
		{
		  q0--;
  800dd0:	8d 7e ff             	lea    -0x1(%esi),%edi
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  800dd3:	31 f6                	xor    %esi,%esi
  800dd5:	e9 56 ff ff ff       	jmp    800d30 <__udivdi3+0x70>
	...

00800ddc <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  800ddc:	55                   	push   %ebp
  800ddd:	89 e5                	mov    %esp,%ebp
  800ddf:	57                   	push   %edi
  800de0:	56                   	push   %esi
  800de1:	83 ec 20             	sub    $0x20,%esp
  800de4:	8b 45 08             	mov    0x8(%ebp),%eax
  800de7:	8b 4d 10             	mov    0x10(%ebp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  800dea:	89 45 e8             	mov    %eax,-0x18(%ebp)
  800ded:	8b 75 0c             	mov    0xc(%ebp),%esi
  const DWunion dd = {.ll = d};
  800df0:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  800df3:	8b 7d 14             	mov    0x14(%ebp),%edi
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  800df6:	89 45 f0             	mov    %eax,-0x10(%ebp)
  n1 = nn.s.high;
  800df9:	89 f2                	mov    %esi,%edx

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  800dfb:	85 ff                	test   %edi,%edi
  800dfd:	75 15                	jne    800e14 <__umoddi3+0x38>
    {
      if (d0 > n1)
  800dff:	39 f1                	cmp    %esi,%ecx
  800e01:	0f 86 99 00 00 00    	jbe    800ea0 <__umoddi3+0xc4>
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800e07:	f7 f1                	div    %ecx

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
  800e09:	89 d0                	mov    %edx,%eax
  800e0b:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  800e0d:	83 c4 20             	add    $0x20,%esp
  800e10:	5e                   	pop    %esi
  800e11:	5f                   	pop    %edi
  800e12:	c9                   	leave  
  800e13:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  800e14:	39 f7                	cmp    %esi,%edi
  800e16:	0f 87 a4 00 00 00    	ja     800ec0 <__umoddi3+0xe4>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  800e1c:	0f bd c7             	bsr    %edi,%eax
	  if (bm == 0)
  800e1f:	83 f0 1f             	xor    $0x1f,%eax
  800e22:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800e25:	0f 84 a1 00 00 00    	je     800ecc <__umoddi3+0xf0>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  800e2b:	89 f8                	mov    %edi,%eax
  800e2d:	8a 4d ec             	mov    -0x14(%ebp),%cl
  800e30:	d3 e0                	shl    %cl,%eax
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  800e32:	bf 20 00 00 00       	mov    $0x20,%edi
  800e37:	2b 7d ec             	sub    -0x14(%ebp),%edi

	      d1 = (d1 << bm) | (d0 >> b);
  800e3a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800e3d:	89 f9                	mov    %edi,%ecx
  800e3f:	d3 ea                	shr    %cl,%edx
  800e41:	09 c2                	or     %eax,%edx
  800e43:	89 55 f0             	mov    %edx,-0x10(%ebp)
	      d0 = d0 << bm;
  800e46:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800e49:	8a 4d ec             	mov    -0x14(%ebp),%cl
  800e4c:	d3 e0                	shl    %cl,%eax
  800e4e:	89 45 f4             	mov    %eax,-0xc(%ebp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  800e51:	89 f2                	mov    %esi,%edx
  800e53:	d3 e2                	shl    %cl,%edx
	      n0 = n0 << bm;
  800e55:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800e58:	d3 e0                	shl    %cl,%eax
  800e5a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  800e5d:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800e60:	89 f9                	mov    %edi,%ecx
  800e62:	d3 e8                	shr    %cl,%eax
  800e64:	09 d0                	or     %edx,%eax

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  800e66:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  800e68:	89 f2                	mov    %esi,%edx
  800e6a:	f7 75 f0             	divl   -0x10(%ebp)
  800e6d:	89 d6                	mov    %edx,%esi
	      umul_ppmm (m1, m0, q0, d0);
  800e6f:	f7 65 f4             	mull   -0xc(%ebp)
  800e72:	89 55 e8             	mov    %edx,-0x18(%ebp)
  800e75:	89 c1                	mov    %eax,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800e77:	39 d6                	cmp    %edx,%esi
  800e79:	72 71                	jb     800eec <__umoddi3+0x110>
  800e7b:	74 7f                	je     800efc <__umoddi3+0x120>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  800e7d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800e80:	29 c8                	sub    %ecx,%eax
  800e82:	19 d6                	sbb    %edx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
  800e84:	8a 4d ec             	mov    -0x14(%ebp),%cl
  800e87:	d3 e8                	shr    %cl,%eax
  800e89:	89 f2                	mov    %esi,%edx
  800e8b:	89 f9                	mov    %edi,%ecx
  800e8d:	d3 e2                	shl    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
  800e8f:	09 d0                	or     %edx,%eax
  800e91:	89 f2                	mov    %esi,%edx
  800e93:	8a 4d ec             	mov    -0x14(%ebp),%cl
  800e96:	d3 ea                	shr    %cl,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  800e98:	83 c4 20             	add    $0x20,%esp
  800e9b:	5e                   	pop    %esi
  800e9c:	5f                   	pop    %edi
  800e9d:	c9                   	leave  
  800e9e:	c3                   	ret    
  800e9f:	90                   	nop
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  800ea0:	85 c9                	test   %ecx,%ecx
  800ea2:	75 0b                	jne    800eaf <__umoddi3+0xd3>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  800ea4:	b8 01 00 00 00       	mov    $0x1,%eax
  800ea9:	31 d2                	xor    %edx,%edx
  800eab:	f7 f1                	div    %ecx
  800ead:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  800eaf:	89 f0                	mov    %esi,%eax
  800eb1:	31 d2                	xor    %edx,%edx
  800eb3:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800eb5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800eb8:	f7 f1                	div    %ecx
  800eba:	e9 4a ff ff ff       	jmp    800e09 <__umoddi3+0x2d>
  800ebf:	90                   	nop
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
  800ec0:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  800ec2:	83 c4 20             	add    $0x20,%esp
  800ec5:	5e                   	pop    %esi
  800ec6:	5f                   	pop    %edi
  800ec7:	c9                   	leave  
  800ec8:	c3                   	ret    
  800ec9:	8d 76 00             	lea    0x0(%esi),%esi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  800ecc:	39 f7                	cmp    %esi,%edi
  800ece:	72 05                	jb     800ed5 <__umoddi3+0xf9>
  800ed0:	3b 4d f0             	cmp    -0x10(%ebp),%ecx
  800ed3:	77 0c                	ja     800ee1 <__umoddi3+0x105>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  800ed5:	89 f2                	mov    %esi,%edx
  800ed7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800eda:	29 c8                	sub    %ecx,%eax
  800edc:	19 fa                	sbb    %edi,%edx
  800ede:	89 45 f0             	mov    %eax,-0x10(%ebp)

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
  800ee1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  800ee4:	83 c4 20             	add    $0x20,%esp
  800ee7:	5e                   	pop    %esi
  800ee8:	5f                   	pop    %edi
  800ee9:	c9                   	leave  
  800eea:	c3                   	ret    
  800eeb:	90                   	nop
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  800eec:	8b 55 e8             	mov    -0x18(%ebp),%edx
  800eef:	89 c1                	mov    %eax,%ecx
  800ef1:	2b 4d f4             	sub    -0xc(%ebp),%ecx
  800ef4:	1b 55 f0             	sbb    -0x10(%ebp),%edx
  800ef7:	eb 84                	jmp    800e7d <__umoddi3+0xa1>
  800ef9:	8d 76 00             	lea    0x0(%esi),%esi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800efc:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  800eff:	72 eb                	jb     800eec <__umoddi3+0x110>
  800f01:	89 f2                	mov    %esi,%edx
  800f03:	e9 75 ff ff ff       	jmp    800e7d <__umoddi3+0xa1>
