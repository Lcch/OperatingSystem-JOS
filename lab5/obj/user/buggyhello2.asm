
obj/user/buggyhello2.debug:     file format elf32-i386


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
  80003f:	ff 35 00 30 80 00    	pushl  0x803000
  800045:	e8 bf 00 00 00       	call   800109 <sys_cputs>
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
  80005b:	e8 15 01 00 00       	call   800175 <sys_getenvid>
  800060:	25 ff 03 00 00       	and    $0x3ff,%eax
  800065:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  80006c:	c1 e0 07             	shl    $0x7,%eax
  80006f:	29 d0                	sub    %edx,%eax
  800071:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800076:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80007b:	85 f6                	test   %esi,%esi
  80007d:	7e 07                	jle    800086 <libmain+0x36>
		binaryname = argv[0];
  80007f:	8b 03                	mov    (%ebx),%eax
  800081:	a3 04 30 80 00       	mov    %eax,0x803004
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
  8000a3:	83 ec 08             	sub    $0x8,%esp
	close_all();
  8000a6:	e8 5f 04 00 00       	call   80050a <close_all>
	sys_env_destroy(0);
  8000ab:	83 ec 0c             	sub    $0xc,%esp
  8000ae:	6a 00                	push   $0x0
  8000b0:	e8 9e 00 00 00       	call   800153 <sys_env_destroy>
  8000b5:	83 c4 10             	add    $0x10,%esp
}
  8000b8:	c9                   	leave  
  8000b9:	c3                   	ret    
	...

008000bc <syscall>:
	return ret;
}

static int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  8000bc:	55                   	push   %ebp
  8000bd:	89 e5                	mov    %esp,%ebp
  8000bf:	57                   	push   %edi
  8000c0:	56                   	push   %esi
  8000c1:	53                   	push   %ebx
  8000c2:	83 ec 1c             	sub    $0x1c,%esp
  8000c5:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8000c8:	89 55 e0             	mov    %edx,-0x20(%ebp)
  8000cb:	89 ca                	mov    %ecx,%edx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000cd:	8b 75 14             	mov    0x14(%ebp),%esi
  8000d0:	8b 7d 10             	mov    0x10(%ebp),%edi
  8000d3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8000d6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8000d9:	cd 30                	int    $0x30
  8000db:	89 c2                	mov    %eax,%edx
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8000dd:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8000e1:	74 1c                	je     8000ff <syscall+0x43>
  8000e3:	85 c0                	test   %eax,%eax
  8000e5:	7e 18                	jle    8000ff <syscall+0x43>
		panic("syscall %d returned %d (> 0)", num, ret);
  8000e7:	83 ec 0c             	sub    $0xc,%esp
  8000ea:	50                   	push   %eax
  8000eb:	ff 75 e4             	pushl  -0x1c(%ebp)
  8000ee:	68 98 1d 80 00       	push   $0x801d98
  8000f3:	6a 42                	push   $0x42
  8000f5:	68 b5 1d 80 00       	push   $0x801db5
  8000fa:	e8 b5 0e 00 00       	call   800fb4 <_panic>

	return ret;
}
  8000ff:	89 d0                	mov    %edx,%eax
  800101:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800104:	5b                   	pop    %ebx
  800105:	5e                   	pop    %esi
  800106:	5f                   	pop    %edi
  800107:	c9                   	leave  
  800108:	c3                   	ret    

00800109 <sys_cputs>:

void
sys_cputs(const char *s, size_t len)
{	
  800109:	55                   	push   %ebp
  80010a:	89 e5                	mov    %esp,%ebp
  80010c:	83 ec 08             	sub    $0x8,%esp
	// my_sysenter(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
	// return;
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
  80010f:	6a 00                	push   $0x0
  800111:	6a 00                	push   $0x0
  800113:	6a 00                	push   $0x0
  800115:	ff 75 0c             	pushl  0xc(%ebp)
  800118:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80011b:	ba 00 00 00 00       	mov    $0x0,%edx
  800120:	b8 00 00 00 00       	mov    $0x0,%eax
  800125:	e8 92 ff ff ff       	call   8000bc <syscall>
  80012a:	83 c4 10             	add    $0x10,%esp
	return;
}
  80012d:	c9                   	leave  
  80012e:	c3                   	ret    

0080012f <sys_cgetc>:

int
sys_cgetc(void)
{
  80012f:	55                   	push   %ebp
  800130:	89 e5                	mov    %esp,%ebp
  800132:	83 ec 08             	sub    $0x8,%esp
	// return my_sysenter(SYS_cgetc, 0, 0, 0, 0, 0, 0);
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
  800135:	6a 00                	push   $0x0
  800137:	6a 00                	push   $0x0
  800139:	6a 00                	push   $0x0
  80013b:	6a 00                	push   $0x0
  80013d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800142:	ba 00 00 00 00       	mov    $0x0,%edx
  800147:	b8 01 00 00 00       	mov    $0x1,%eax
  80014c:	e8 6b ff ff ff       	call   8000bc <syscall>
}
  800151:	c9                   	leave  
  800152:	c3                   	ret    

00800153 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800153:	55                   	push   %ebp
  800154:	89 e5                	mov    %esp,%ebp
  800156:	83 ec 08             	sub    $0x8,%esp
	// return my_sysenter(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
  800159:	6a 00                	push   $0x0
  80015b:	6a 00                	push   $0x0
  80015d:	6a 00                	push   $0x0
  80015f:	6a 00                	push   $0x0
  800161:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800164:	ba 01 00 00 00       	mov    $0x1,%edx
  800169:	b8 03 00 00 00       	mov    $0x3,%eax
  80016e:	e8 49 ff ff ff       	call   8000bc <syscall>
}
  800173:	c9                   	leave  
  800174:	c3                   	ret    

00800175 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800175:	55                   	push   %ebp
  800176:	89 e5                	mov    %esp,%ebp
  800178:	83 ec 08             	sub    $0x8,%esp
	// return my_sysenter(SYS_getenvid, 0, 0, 0, 0, 0, 0);
	return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
  80017b:	6a 00                	push   $0x0
  80017d:	6a 00                	push   $0x0
  80017f:	6a 00                	push   $0x0
  800181:	6a 00                	push   $0x0
  800183:	b9 00 00 00 00       	mov    $0x0,%ecx
  800188:	ba 00 00 00 00       	mov    $0x0,%edx
  80018d:	b8 02 00 00 00       	mov    $0x2,%eax
  800192:	e8 25 ff ff ff       	call   8000bc <syscall>
}
  800197:	c9                   	leave  
  800198:	c3                   	ret    

00800199 <sys_yield>:

void
sys_yield(void)
{
  800199:	55                   	push   %ebp
  80019a:	89 e5                	mov    %esp,%ebp
  80019c:	83 ec 08             	sub    $0x8,%esp
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
  80019f:	6a 00                	push   $0x0
  8001a1:	6a 00                	push   $0x0
  8001a3:	6a 00                	push   $0x0
  8001a5:	6a 00                	push   $0x0
  8001a7:	b9 00 00 00 00       	mov    $0x0,%ecx
  8001ac:	ba 00 00 00 00       	mov    $0x0,%edx
  8001b1:	b8 0b 00 00 00       	mov    $0xb,%eax
  8001b6:	e8 01 ff ff ff       	call   8000bc <syscall>
  8001bb:	83 c4 10             	add    $0x10,%esp
}
  8001be:	c9                   	leave  
  8001bf:	c3                   	ret    

008001c0 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  8001c0:	55                   	push   %ebp
  8001c1:	89 e5                	mov    %esp,%ebp
  8001c3:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
  8001c6:	6a 00                	push   $0x0
  8001c8:	6a 00                	push   $0x0
  8001ca:	ff 75 10             	pushl  0x10(%ebp)
  8001cd:	ff 75 0c             	pushl  0xc(%ebp)
  8001d0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8001d3:	ba 01 00 00 00       	mov    $0x1,%edx
  8001d8:	b8 04 00 00 00       	mov    $0x4,%eax
  8001dd:	e8 da fe ff ff       	call   8000bc <syscall>
}
  8001e2:	c9                   	leave  
  8001e3:	c3                   	ret    

008001e4 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8001e4:	55                   	push   %ebp
  8001e5:	89 e5                	mov    %esp,%ebp
  8001e7:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
  8001ea:	ff 75 18             	pushl  0x18(%ebp)
  8001ed:	ff 75 14             	pushl  0x14(%ebp)
  8001f0:	ff 75 10             	pushl  0x10(%ebp)
  8001f3:	ff 75 0c             	pushl  0xc(%ebp)
  8001f6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8001f9:	ba 01 00 00 00       	mov    $0x1,%edx
  8001fe:	b8 05 00 00 00       	mov    $0x5,%eax
  800203:	e8 b4 fe ff ff       	call   8000bc <syscall>
}
  800208:	c9                   	leave  
  800209:	c3                   	ret    

0080020a <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  80020a:	55                   	push   %ebp
  80020b:	89 e5                	mov    %esp,%ebp
  80020d:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
  800210:	6a 00                	push   $0x0
  800212:	6a 00                	push   $0x0
  800214:	6a 00                	push   $0x0
  800216:	ff 75 0c             	pushl  0xc(%ebp)
  800219:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80021c:	ba 01 00 00 00       	mov    $0x1,%edx
  800221:	b8 06 00 00 00       	mov    $0x6,%eax
  800226:	e8 91 fe ff ff       	call   8000bc <syscall>
}
  80022b:	c9                   	leave  
  80022c:	c3                   	ret    

0080022d <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  80022d:	55                   	push   %ebp
  80022e:	89 e5                	mov    %esp,%ebp
  800230:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
  800233:	6a 00                	push   $0x0
  800235:	6a 00                	push   $0x0
  800237:	6a 00                	push   $0x0
  800239:	ff 75 0c             	pushl  0xc(%ebp)
  80023c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80023f:	ba 01 00 00 00       	mov    $0x1,%edx
  800244:	b8 08 00 00 00       	mov    $0x8,%eax
  800249:	e8 6e fe ff ff       	call   8000bc <syscall>
}
  80024e:	c9                   	leave  
  80024f:	c3                   	ret    

00800250 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800250:	55                   	push   %ebp
  800251:	89 e5                	mov    %esp,%ebp
  800253:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
  800256:	6a 00                	push   $0x0
  800258:	6a 00                	push   $0x0
  80025a:	6a 00                	push   $0x0
  80025c:	ff 75 0c             	pushl  0xc(%ebp)
  80025f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800262:	ba 01 00 00 00       	mov    $0x1,%edx
  800267:	b8 09 00 00 00       	mov    $0x9,%eax
  80026c:	e8 4b fe ff ff       	call   8000bc <syscall>
}
  800271:	c9                   	leave  
  800272:	c3                   	ret    

00800273 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800273:	55                   	push   %ebp
  800274:	89 e5                	mov    %esp,%ebp
  800276:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
  800279:	6a 00                	push   $0x0
  80027b:	6a 00                	push   $0x0
  80027d:	6a 00                	push   $0x0
  80027f:	ff 75 0c             	pushl  0xc(%ebp)
  800282:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800285:	ba 01 00 00 00       	mov    $0x1,%edx
  80028a:	b8 0a 00 00 00       	mov    $0xa,%eax
  80028f:	e8 28 fe ff ff       	call   8000bc <syscall>
}
  800294:	c9                   	leave  
  800295:	c3                   	ret    

00800296 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800296:	55                   	push   %ebp
  800297:	89 e5                	mov    %esp,%ebp
  800299:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
  80029c:	6a 00                	push   $0x0
  80029e:	ff 75 14             	pushl  0x14(%ebp)
  8002a1:	ff 75 10             	pushl  0x10(%ebp)
  8002a4:	ff 75 0c             	pushl  0xc(%ebp)
  8002a7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8002aa:	ba 00 00 00 00       	mov    $0x0,%edx
  8002af:	b8 0c 00 00 00       	mov    $0xc,%eax
  8002b4:	e8 03 fe ff ff       	call   8000bc <syscall>
}
  8002b9:	c9                   	leave  
  8002ba:	c3                   	ret    

008002bb <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  8002bb:	55                   	push   %ebp
  8002bc:	89 e5                	mov    %esp,%ebp
  8002be:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
  8002c1:	6a 00                	push   $0x0
  8002c3:	6a 00                	push   $0x0
  8002c5:	6a 00                	push   $0x0
  8002c7:	6a 00                	push   $0x0
  8002c9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8002cc:	ba 01 00 00 00       	mov    $0x1,%edx
  8002d1:	b8 0d 00 00 00       	mov    $0xd,%eax
  8002d6:	e8 e1 fd ff ff       	call   8000bc <syscall>
}
  8002db:	c9                   	leave  
  8002dc:	c3                   	ret    

008002dd <sys_set_priority>:

int
sys_set_priority(envid_t envid, uint32_t new_priority)
{
  8002dd:	55                   	push   %ebp
  8002de:	89 e5                	mov    %esp,%ebp
  8002e0:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_set_priority, 0, envid, new_priority, 0, 0, 0);
  8002e3:	6a 00                	push   $0x0
  8002e5:	6a 00                	push   $0x0
  8002e7:	6a 00                	push   $0x0
  8002e9:	ff 75 0c             	pushl  0xc(%ebp)
  8002ec:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8002ef:	ba 00 00 00 00       	mov    $0x0,%edx
  8002f4:	b8 0e 00 00 00       	mov    $0xe,%eax
  8002f9:	e8 be fd ff ff       	call   8000bc <syscall>
}
  8002fe:	c9                   	leave  
  8002ff:	c3                   	ret    

00800300 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800300:	55                   	push   %ebp
  800301:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800303:	8b 45 08             	mov    0x8(%ebp),%eax
  800306:	05 00 00 00 30       	add    $0x30000000,%eax
  80030b:	c1 e8 0c             	shr    $0xc,%eax
}
  80030e:	c9                   	leave  
  80030f:	c3                   	ret    

00800310 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800310:	55                   	push   %ebp
  800311:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  800313:	ff 75 08             	pushl  0x8(%ebp)
  800316:	e8 e5 ff ff ff       	call   800300 <fd2num>
  80031b:	83 c4 04             	add    $0x4,%esp
  80031e:	05 20 00 0d 00       	add    $0xd0020,%eax
  800323:	c1 e0 0c             	shl    $0xc,%eax
}
  800326:	c9                   	leave  
  800327:	c3                   	ret    

00800328 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800328:	55                   	push   %ebp
  800329:	89 e5                	mov    %esp,%ebp
  80032b:	53                   	push   %ebx
  80032c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  80032f:	a1 00 dd 7b ef       	mov    0xef7bdd00,%eax
  800334:	a8 01                	test   $0x1,%al
  800336:	74 34                	je     80036c <fd_alloc+0x44>
  800338:	a1 00 00 74 ef       	mov    0xef740000,%eax
  80033d:	a8 01                	test   $0x1,%al
  80033f:	74 32                	je     800373 <fd_alloc+0x4b>
  800341:	b8 00 10 00 d0       	mov    $0xd0001000,%eax
  800346:	89 c1                	mov    %eax,%ecx
  800348:	89 c2                	mov    %eax,%edx
  80034a:	c1 ea 16             	shr    $0x16,%edx
  80034d:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800354:	f6 c2 01             	test   $0x1,%dl
  800357:	74 1f                	je     800378 <fd_alloc+0x50>
  800359:	89 c2                	mov    %eax,%edx
  80035b:	c1 ea 0c             	shr    $0xc,%edx
  80035e:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800365:	f6 c2 01             	test   $0x1,%dl
  800368:	75 17                	jne    800381 <fd_alloc+0x59>
  80036a:	eb 0c                	jmp    800378 <fd_alloc+0x50>
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  80036c:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
  800371:	eb 05                	jmp    800378 <fd_alloc+0x50>
  800373:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
  800378:	89 0b                	mov    %ecx,(%ebx)
			return 0;
  80037a:	b8 00 00 00 00       	mov    $0x0,%eax
  80037f:	eb 17                	jmp    800398 <fd_alloc+0x70>
  800381:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800386:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  80038b:	75 b9                	jne    800346 <fd_alloc+0x1e>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  80038d:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_MAX_OPEN;
  800393:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800398:	5b                   	pop    %ebx
  800399:	c9                   	leave  
  80039a:	c3                   	ret    

0080039b <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  80039b:	55                   	push   %ebp
  80039c:	89 e5                	mov    %esp,%ebp
  80039e:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8003a1:	83 f8 1f             	cmp    $0x1f,%eax
  8003a4:	77 36                	ja     8003dc <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8003a6:	05 00 00 0d 00       	add    $0xd0000,%eax
  8003ab:	c1 e0 0c             	shl    $0xc,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8003ae:	89 c2                	mov    %eax,%edx
  8003b0:	c1 ea 16             	shr    $0x16,%edx
  8003b3:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8003ba:	f6 c2 01             	test   $0x1,%dl
  8003bd:	74 24                	je     8003e3 <fd_lookup+0x48>
  8003bf:	89 c2                	mov    %eax,%edx
  8003c1:	c1 ea 0c             	shr    $0xc,%edx
  8003c4:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8003cb:	f6 c2 01             	test   $0x1,%dl
  8003ce:	74 1a                	je     8003ea <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8003d0:	8b 55 0c             	mov    0xc(%ebp),%edx
  8003d3:	89 02                	mov    %eax,(%edx)
	return 0;
  8003d5:	b8 00 00 00 00       	mov    $0x0,%eax
  8003da:	eb 13                	jmp    8003ef <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8003dc:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8003e1:	eb 0c                	jmp    8003ef <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8003e3:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8003e8:	eb 05                	jmp    8003ef <fd_lookup+0x54>
  8003ea:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  8003ef:	c9                   	leave  
  8003f0:	c3                   	ret    

008003f1 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8003f1:	55                   	push   %ebp
  8003f2:	89 e5                	mov    %esp,%ebp
  8003f4:	53                   	push   %ebx
  8003f5:	83 ec 04             	sub    $0x4,%esp
  8003f8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8003fb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
		if (devtab[i]->dev_id == dev_id) {
  8003fe:	39 0d 08 30 80 00    	cmp    %ecx,0x803008
  800404:	74 0d                	je     800413 <dev_lookup+0x22>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800406:	b8 00 00 00 00       	mov    $0x0,%eax
  80040b:	eb 14                	jmp    800421 <dev_lookup+0x30>
		if (devtab[i]->dev_id == dev_id) {
  80040d:	39 0a                	cmp    %ecx,(%edx)
  80040f:	75 10                	jne    800421 <dev_lookup+0x30>
  800411:	eb 05                	jmp    800418 <dev_lookup+0x27>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800413:	ba 08 30 80 00       	mov    $0x803008,%edx
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
  800418:	89 13                	mov    %edx,(%ebx)
			return 0;
  80041a:	b8 00 00 00 00       	mov    $0x0,%eax
  80041f:	eb 31                	jmp    800452 <dev_lookup+0x61>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800421:	40                   	inc    %eax
  800422:	8b 14 85 40 1e 80 00 	mov    0x801e40(,%eax,4),%edx
  800429:	85 d2                	test   %edx,%edx
  80042b:	75 e0                	jne    80040d <dev_lookup+0x1c>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  80042d:	a1 04 40 80 00       	mov    0x804004,%eax
  800432:	8b 40 48             	mov    0x48(%eax),%eax
  800435:	83 ec 04             	sub    $0x4,%esp
  800438:	51                   	push   %ecx
  800439:	50                   	push   %eax
  80043a:	68 c4 1d 80 00       	push   $0x801dc4
  80043f:	e8 48 0c 00 00       	call   80108c <cprintf>
	*dev = 0;
  800444:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_INVAL;
  80044a:	83 c4 10             	add    $0x10,%esp
  80044d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800452:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800455:	c9                   	leave  
  800456:	c3                   	ret    

00800457 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800457:	55                   	push   %ebp
  800458:	89 e5                	mov    %esp,%ebp
  80045a:	56                   	push   %esi
  80045b:	53                   	push   %ebx
  80045c:	83 ec 20             	sub    $0x20,%esp
  80045f:	8b 75 08             	mov    0x8(%ebp),%esi
  800462:	8a 45 0c             	mov    0xc(%ebp),%al
  800465:	88 45 e7             	mov    %al,-0x19(%ebp)
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800468:	56                   	push   %esi
  800469:	e8 92 fe ff ff       	call   800300 <fd2num>
  80046e:	8d 55 f4             	lea    -0xc(%ebp),%edx
  800471:	89 14 24             	mov    %edx,(%esp)
  800474:	50                   	push   %eax
  800475:	e8 21 ff ff ff       	call   80039b <fd_lookup>
  80047a:	89 c3                	mov    %eax,%ebx
  80047c:	83 c4 08             	add    $0x8,%esp
  80047f:	85 c0                	test   %eax,%eax
  800481:	78 05                	js     800488 <fd_close+0x31>
	    || fd != fd2)
  800483:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  800486:	74 0d                	je     800495 <fd_close+0x3e>
		return (must_exist ? r : 0);
  800488:	80 7d e7 00          	cmpb   $0x0,-0x19(%ebp)
  80048c:	75 48                	jne    8004d6 <fd_close+0x7f>
  80048e:	bb 00 00 00 00       	mov    $0x0,%ebx
  800493:	eb 41                	jmp    8004d6 <fd_close+0x7f>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800495:	83 ec 08             	sub    $0x8,%esp
  800498:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80049b:	50                   	push   %eax
  80049c:	ff 36                	pushl  (%esi)
  80049e:	e8 4e ff ff ff       	call   8003f1 <dev_lookup>
  8004a3:	89 c3                	mov    %eax,%ebx
  8004a5:	83 c4 10             	add    $0x10,%esp
  8004a8:	85 c0                	test   %eax,%eax
  8004aa:	78 1c                	js     8004c8 <fd_close+0x71>
		if (dev->dev_close)
  8004ac:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8004af:	8b 40 10             	mov    0x10(%eax),%eax
  8004b2:	85 c0                	test   %eax,%eax
  8004b4:	74 0d                	je     8004c3 <fd_close+0x6c>
			r = (*dev->dev_close)(fd);
  8004b6:	83 ec 0c             	sub    $0xc,%esp
  8004b9:	56                   	push   %esi
  8004ba:	ff d0                	call   *%eax
  8004bc:	89 c3                	mov    %eax,%ebx
  8004be:	83 c4 10             	add    $0x10,%esp
  8004c1:	eb 05                	jmp    8004c8 <fd_close+0x71>
		else
			r = 0;
  8004c3:	bb 00 00 00 00       	mov    $0x0,%ebx
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8004c8:	83 ec 08             	sub    $0x8,%esp
  8004cb:	56                   	push   %esi
  8004cc:	6a 00                	push   $0x0
  8004ce:	e8 37 fd ff ff       	call   80020a <sys_page_unmap>
	return r;
  8004d3:	83 c4 10             	add    $0x10,%esp
}
  8004d6:	89 d8                	mov    %ebx,%eax
  8004d8:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8004db:	5b                   	pop    %ebx
  8004dc:	5e                   	pop    %esi
  8004dd:	c9                   	leave  
  8004de:	c3                   	ret    

008004df <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8004df:	55                   	push   %ebp
  8004e0:	89 e5                	mov    %esp,%ebp
  8004e2:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8004e5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8004e8:	50                   	push   %eax
  8004e9:	ff 75 08             	pushl  0x8(%ebp)
  8004ec:	e8 aa fe ff ff       	call   80039b <fd_lookup>
  8004f1:	83 c4 08             	add    $0x8,%esp
  8004f4:	85 c0                	test   %eax,%eax
  8004f6:	78 10                	js     800508 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  8004f8:	83 ec 08             	sub    $0x8,%esp
  8004fb:	6a 01                	push   $0x1
  8004fd:	ff 75 f4             	pushl  -0xc(%ebp)
  800500:	e8 52 ff ff ff       	call   800457 <fd_close>
  800505:	83 c4 10             	add    $0x10,%esp
}
  800508:	c9                   	leave  
  800509:	c3                   	ret    

0080050a <close_all>:

void
close_all(void)
{
  80050a:	55                   	push   %ebp
  80050b:	89 e5                	mov    %esp,%ebp
  80050d:	53                   	push   %ebx
  80050e:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800511:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  800516:	83 ec 0c             	sub    $0xc,%esp
  800519:	53                   	push   %ebx
  80051a:	e8 c0 ff ff ff       	call   8004df <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  80051f:	43                   	inc    %ebx
  800520:	83 c4 10             	add    $0x10,%esp
  800523:	83 fb 20             	cmp    $0x20,%ebx
  800526:	75 ee                	jne    800516 <close_all+0xc>
		close(i);
}
  800528:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80052b:	c9                   	leave  
  80052c:	c3                   	ret    

0080052d <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  80052d:	55                   	push   %ebp
  80052e:	89 e5                	mov    %esp,%ebp
  800530:	57                   	push   %edi
  800531:	56                   	push   %esi
  800532:	53                   	push   %ebx
  800533:	83 ec 2c             	sub    $0x2c,%esp
  800536:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  800539:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80053c:	50                   	push   %eax
  80053d:	ff 75 08             	pushl  0x8(%ebp)
  800540:	e8 56 fe ff ff       	call   80039b <fd_lookup>
  800545:	89 c3                	mov    %eax,%ebx
  800547:	83 c4 08             	add    $0x8,%esp
  80054a:	85 c0                	test   %eax,%eax
  80054c:	0f 88 c0 00 00 00    	js     800612 <dup+0xe5>
		return r;
	close(newfdnum);
  800552:	83 ec 0c             	sub    $0xc,%esp
  800555:	57                   	push   %edi
  800556:	e8 84 ff ff ff       	call   8004df <close>

	newfd = INDEX2FD(newfdnum);
  80055b:	8d b7 00 00 0d 00    	lea    0xd0000(%edi),%esi
  800561:	c1 e6 0c             	shl    $0xc,%esi
	ova = fd2data(oldfd);
  800564:	83 c4 04             	add    $0x4,%esp
  800567:	ff 75 e4             	pushl  -0x1c(%ebp)
  80056a:	e8 a1 fd ff ff       	call   800310 <fd2data>
  80056f:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  800571:	89 34 24             	mov    %esi,(%esp)
  800574:	e8 97 fd ff ff       	call   800310 <fd2data>
  800579:	83 c4 10             	add    $0x10,%esp
  80057c:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80057f:	89 d8                	mov    %ebx,%eax
  800581:	c1 e8 16             	shr    $0x16,%eax
  800584:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80058b:	a8 01                	test   $0x1,%al
  80058d:	74 37                	je     8005c6 <dup+0x99>
  80058f:	89 d8                	mov    %ebx,%eax
  800591:	c1 e8 0c             	shr    $0xc,%eax
  800594:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80059b:	f6 c2 01             	test   $0x1,%dl
  80059e:	74 26                	je     8005c6 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8005a0:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8005a7:	83 ec 0c             	sub    $0xc,%esp
  8005aa:	25 07 0e 00 00       	and    $0xe07,%eax
  8005af:	50                   	push   %eax
  8005b0:	ff 75 d4             	pushl  -0x2c(%ebp)
  8005b3:	6a 00                	push   $0x0
  8005b5:	53                   	push   %ebx
  8005b6:	6a 00                	push   $0x0
  8005b8:	e8 27 fc ff ff       	call   8001e4 <sys_page_map>
  8005bd:	89 c3                	mov    %eax,%ebx
  8005bf:	83 c4 20             	add    $0x20,%esp
  8005c2:	85 c0                	test   %eax,%eax
  8005c4:	78 2d                	js     8005f3 <dup+0xc6>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8005c6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8005c9:	89 c2                	mov    %eax,%edx
  8005cb:	c1 ea 0c             	shr    $0xc,%edx
  8005ce:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8005d5:	83 ec 0c             	sub    $0xc,%esp
  8005d8:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  8005de:	52                   	push   %edx
  8005df:	56                   	push   %esi
  8005e0:	6a 00                	push   $0x0
  8005e2:	50                   	push   %eax
  8005e3:	6a 00                	push   $0x0
  8005e5:	e8 fa fb ff ff       	call   8001e4 <sys_page_map>
  8005ea:	89 c3                	mov    %eax,%ebx
  8005ec:	83 c4 20             	add    $0x20,%esp
  8005ef:	85 c0                	test   %eax,%eax
  8005f1:	79 1d                	jns    800610 <dup+0xe3>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8005f3:	83 ec 08             	sub    $0x8,%esp
  8005f6:	56                   	push   %esi
  8005f7:	6a 00                	push   $0x0
  8005f9:	e8 0c fc ff ff       	call   80020a <sys_page_unmap>
	sys_page_unmap(0, nva);
  8005fe:	83 c4 08             	add    $0x8,%esp
  800601:	ff 75 d4             	pushl  -0x2c(%ebp)
  800604:	6a 00                	push   $0x0
  800606:	e8 ff fb ff ff       	call   80020a <sys_page_unmap>
	return r;
  80060b:	83 c4 10             	add    $0x10,%esp
  80060e:	eb 02                	jmp    800612 <dup+0xe5>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
		goto err;

	return newfdnum;
  800610:	89 fb                	mov    %edi,%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  800612:	89 d8                	mov    %ebx,%eax
  800614:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800617:	5b                   	pop    %ebx
  800618:	5e                   	pop    %esi
  800619:	5f                   	pop    %edi
  80061a:	c9                   	leave  
  80061b:	c3                   	ret    

0080061c <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80061c:	55                   	push   %ebp
  80061d:	89 e5                	mov    %esp,%ebp
  80061f:	53                   	push   %ebx
  800620:	83 ec 14             	sub    $0x14,%esp
  800623:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800626:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800629:	50                   	push   %eax
  80062a:	53                   	push   %ebx
  80062b:	e8 6b fd ff ff       	call   80039b <fd_lookup>
  800630:	83 c4 08             	add    $0x8,%esp
  800633:	85 c0                	test   %eax,%eax
  800635:	78 67                	js     80069e <read+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800637:	83 ec 08             	sub    $0x8,%esp
  80063a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80063d:	50                   	push   %eax
  80063e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800641:	ff 30                	pushl  (%eax)
  800643:	e8 a9 fd ff ff       	call   8003f1 <dev_lookup>
  800648:	83 c4 10             	add    $0x10,%esp
  80064b:	85 c0                	test   %eax,%eax
  80064d:	78 4f                	js     80069e <read+0x82>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80064f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800652:	8b 50 08             	mov    0x8(%eax),%edx
  800655:	83 e2 03             	and    $0x3,%edx
  800658:	83 fa 01             	cmp    $0x1,%edx
  80065b:	75 21                	jne    80067e <read+0x62>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80065d:	a1 04 40 80 00       	mov    0x804004,%eax
  800662:	8b 40 48             	mov    0x48(%eax),%eax
  800665:	83 ec 04             	sub    $0x4,%esp
  800668:	53                   	push   %ebx
  800669:	50                   	push   %eax
  80066a:	68 05 1e 80 00       	push   $0x801e05
  80066f:	e8 18 0a 00 00       	call   80108c <cprintf>
		return -E_INVAL;
  800674:	83 c4 10             	add    $0x10,%esp
  800677:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80067c:	eb 20                	jmp    80069e <read+0x82>
	}
	if (!dev->dev_read)
  80067e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800681:	8b 52 08             	mov    0x8(%edx),%edx
  800684:	85 d2                	test   %edx,%edx
  800686:	74 11                	je     800699 <read+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  800688:	83 ec 04             	sub    $0x4,%esp
  80068b:	ff 75 10             	pushl  0x10(%ebp)
  80068e:	ff 75 0c             	pushl  0xc(%ebp)
  800691:	50                   	push   %eax
  800692:	ff d2                	call   *%edx
  800694:	83 c4 10             	add    $0x10,%esp
  800697:	eb 05                	jmp    80069e <read+0x82>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  800699:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_read)(fd, buf, n);
}
  80069e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8006a1:	c9                   	leave  
  8006a2:	c3                   	ret    

008006a3 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8006a3:	55                   	push   %ebp
  8006a4:	89 e5                	mov    %esp,%ebp
  8006a6:	57                   	push   %edi
  8006a7:	56                   	push   %esi
  8006a8:	53                   	push   %ebx
  8006a9:	83 ec 0c             	sub    $0xc,%esp
  8006ac:	8b 7d 08             	mov    0x8(%ebp),%edi
  8006af:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8006b2:	85 f6                	test   %esi,%esi
  8006b4:	74 31                	je     8006e7 <readn+0x44>
  8006b6:	b8 00 00 00 00       	mov    $0x0,%eax
  8006bb:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = read(fdnum, (char*)buf + tot, n - tot);
  8006c0:	83 ec 04             	sub    $0x4,%esp
  8006c3:	89 f2                	mov    %esi,%edx
  8006c5:	29 c2                	sub    %eax,%edx
  8006c7:	52                   	push   %edx
  8006c8:	03 45 0c             	add    0xc(%ebp),%eax
  8006cb:	50                   	push   %eax
  8006cc:	57                   	push   %edi
  8006cd:	e8 4a ff ff ff       	call   80061c <read>
		if (m < 0)
  8006d2:	83 c4 10             	add    $0x10,%esp
  8006d5:	85 c0                	test   %eax,%eax
  8006d7:	78 17                	js     8006f0 <readn+0x4d>
			return m;
		if (m == 0)
  8006d9:	85 c0                	test   %eax,%eax
  8006db:	74 11                	je     8006ee <readn+0x4b>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8006dd:	01 c3                	add    %eax,%ebx
  8006df:	89 d8                	mov    %ebx,%eax
  8006e1:	39 f3                	cmp    %esi,%ebx
  8006e3:	72 db                	jb     8006c0 <readn+0x1d>
  8006e5:	eb 09                	jmp    8006f0 <readn+0x4d>
  8006e7:	b8 00 00 00 00       	mov    $0x0,%eax
  8006ec:	eb 02                	jmp    8006f0 <readn+0x4d>
		m = read(fdnum, (char*)buf + tot, n - tot);
		if (m < 0)
			return m;
		if (m == 0)
  8006ee:	89 d8                	mov    %ebx,%eax
			break;
	}
	return tot;
}
  8006f0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8006f3:	5b                   	pop    %ebx
  8006f4:	5e                   	pop    %esi
  8006f5:	5f                   	pop    %edi
  8006f6:	c9                   	leave  
  8006f7:	c3                   	ret    

008006f8 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8006f8:	55                   	push   %ebp
  8006f9:	89 e5                	mov    %esp,%ebp
  8006fb:	53                   	push   %ebx
  8006fc:	83 ec 14             	sub    $0x14,%esp
  8006ff:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800702:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800705:	50                   	push   %eax
  800706:	53                   	push   %ebx
  800707:	e8 8f fc ff ff       	call   80039b <fd_lookup>
  80070c:	83 c4 08             	add    $0x8,%esp
  80070f:	85 c0                	test   %eax,%eax
  800711:	78 62                	js     800775 <write+0x7d>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800713:	83 ec 08             	sub    $0x8,%esp
  800716:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800719:	50                   	push   %eax
  80071a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80071d:	ff 30                	pushl  (%eax)
  80071f:	e8 cd fc ff ff       	call   8003f1 <dev_lookup>
  800724:	83 c4 10             	add    $0x10,%esp
  800727:	85 c0                	test   %eax,%eax
  800729:	78 4a                	js     800775 <write+0x7d>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80072b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80072e:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  800732:	75 21                	jne    800755 <write+0x5d>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  800734:	a1 04 40 80 00       	mov    0x804004,%eax
  800739:	8b 40 48             	mov    0x48(%eax),%eax
  80073c:	83 ec 04             	sub    $0x4,%esp
  80073f:	53                   	push   %ebx
  800740:	50                   	push   %eax
  800741:	68 21 1e 80 00       	push   $0x801e21
  800746:	e8 41 09 00 00       	call   80108c <cprintf>
		return -E_INVAL;
  80074b:	83 c4 10             	add    $0x10,%esp
  80074e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800753:	eb 20                	jmp    800775 <write+0x7d>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  800755:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800758:	8b 52 0c             	mov    0xc(%edx),%edx
  80075b:	85 d2                	test   %edx,%edx
  80075d:	74 11                	je     800770 <write+0x78>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80075f:	83 ec 04             	sub    $0x4,%esp
  800762:	ff 75 10             	pushl  0x10(%ebp)
  800765:	ff 75 0c             	pushl  0xc(%ebp)
  800768:	50                   	push   %eax
  800769:	ff d2                	call   *%edx
  80076b:	83 c4 10             	add    $0x10,%esp
  80076e:	eb 05                	jmp    800775 <write+0x7d>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  800770:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  800775:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800778:	c9                   	leave  
  800779:	c3                   	ret    

0080077a <seek>:

int
seek(int fdnum, off_t offset)
{
  80077a:	55                   	push   %ebp
  80077b:	89 e5                	mov    %esp,%ebp
  80077d:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800780:	8d 45 fc             	lea    -0x4(%ebp),%eax
  800783:	50                   	push   %eax
  800784:	ff 75 08             	pushl  0x8(%ebp)
  800787:	e8 0f fc ff ff       	call   80039b <fd_lookup>
  80078c:	83 c4 08             	add    $0x8,%esp
  80078f:	85 c0                	test   %eax,%eax
  800791:	78 0e                	js     8007a1 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  800793:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800796:	8b 55 0c             	mov    0xc(%ebp),%edx
  800799:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  80079c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8007a1:	c9                   	leave  
  8007a2:	c3                   	ret    

008007a3 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8007a3:	55                   	push   %ebp
  8007a4:	89 e5                	mov    %esp,%ebp
  8007a6:	53                   	push   %ebx
  8007a7:	83 ec 14             	sub    $0x14,%esp
  8007aa:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8007ad:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8007b0:	50                   	push   %eax
  8007b1:	53                   	push   %ebx
  8007b2:	e8 e4 fb ff ff       	call   80039b <fd_lookup>
  8007b7:	83 c4 08             	add    $0x8,%esp
  8007ba:	85 c0                	test   %eax,%eax
  8007bc:	78 5f                	js     80081d <ftruncate+0x7a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8007be:	83 ec 08             	sub    $0x8,%esp
  8007c1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8007c4:	50                   	push   %eax
  8007c5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8007c8:	ff 30                	pushl  (%eax)
  8007ca:	e8 22 fc ff ff       	call   8003f1 <dev_lookup>
  8007cf:	83 c4 10             	add    $0x10,%esp
  8007d2:	85 c0                	test   %eax,%eax
  8007d4:	78 47                	js     80081d <ftruncate+0x7a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8007d6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8007d9:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8007dd:	75 21                	jne    800800 <ftruncate+0x5d>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8007df:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8007e4:	8b 40 48             	mov    0x48(%eax),%eax
  8007e7:	83 ec 04             	sub    $0x4,%esp
  8007ea:	53                   	push   %ebx
  8007eb:	50                   	push   %eax
  8007ec:	68 e4 1d 80 00       	push   $0x801de4
  8007f1:	e8 96 08 00 00       	call   80108c <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8007f6:	83 c4 10             	add    $0x10,%esp
  8007f9:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8007fe:	eb 1d                	jmp    80081d <ftruncate+0x7a>
	}
	if (!dev->dev_trunc)
  800800:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800803:	8b 52 18             	mov    0x18(%edx),%edx
  800806:	85 d2                	test   %edx,%edx
  800808:	74 0e                	je     800818 <ftruncate+0x75>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80080a:	83 ec 08             	sub    $0x8,%esp
  80080d:	ff 75 0c             	pushl  0xc(%ebp)
  800810:	50                   	push   %eax
  800811:	ff d2                	call   *%edx
  800813:	83 c4 10             	add    $0x10,%esp
  800816:	eb 05                	jmp    80081d <ftruncate+0x7a>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  800818:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  80081d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800820:	c9                   	leave  
  800821:	c3                   	ret    

00800822 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  800822:	55                   	push   %ebp
  800823:	89 e5                	mov    %esp,%ebp
  800825:	53                   	push   %ebx
  800826:	83 ec 14             	sub    $0x14,%esp
  800829:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80082c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80082f:	50                   	push   %eax
  800830:	ff 75 08             	pushl  0x8(%ebp)
  800833:	e8 63 fb ff ff       	call   80039b <fd_lookup>
  800838:	83 c4 08             	add    $0x8,%esp
  80083b:	85 c0                	test   %eax,%eax
  80083d:	78 52                	js     800891 <fstat+0x6f>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80083f:	83 ec 08             	sub    $0x8,%esp
  800842:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800845:	50                   	push   %eax
  800846:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800849:	ff 30                	pushl  (%eax)
  80084b:	e8 a1 fb ff ff       	call   8003f1 <dev_lookup>
  800850:	83 c4 10             	add    $0x10,%esp
  800853:	85 c0                	test   %eax,%eax
  800855:	78 3a                	js     800891 <fstat+0x6f>
		return r;
	if (!dev->dev_stat)
  800857:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80085a:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  80085e:	74 2c                	je     80088c <fstat+0x6a>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  800860:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  800863:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80086a:	00 00 00 
	stat->st_isdir = 0;
  80086d:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  800874:	00 00 00 
	stat->st_dev = dev;
  800877:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  80087d:	83 ec 08             	sub    $0x8,%esp
  800880:	53                   	push   %ebx
  800881:	ff 75 f0             	pushl  -0x10(%ebp)
  800884:	ff 50 14             	call   *0x14(%eax)
  800887:	83 c4 10             	add    $0x10,%esp
  80088a:	eb 05                	jmp    800891 <fstat+0x6f>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  80088c:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  800891:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800894:	c9                   	leave  
  800895:	c3                   	ret    

00800896 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  800896:	55                   	push   %ebp
  800897:	89 e5                	mov    %esp,%ebp
  800899:	56                   	push   %esi
  80089a:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  80089b:	83 ec 08             	sub    $0x8,%esp
  80089e:	6a 00                	push   $0x0
  8008a0:	ff 75 08             	pushl  0x8(%ebp)
  8008a3:	e8 78 01 00 00       	call   800a20 <open>
  8008a8:	89 c3                	mov    %eax,%ebx
  8008aa:	83 c4 10             	add    $0x10,%esp
  8008ad:	85 c0                	test   %eax,%eax
  8008af:	78 1b                	js     8008cc <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8008b1:	83 ec 08             	sub    $0x8,%esp
  8008b4:	ff 75 0c             	pushl  0xc(%ebp)
  8008b7:	50                   	push   %eax
  8008b8:	e8 65 ff ff ff       	call   800822 <fstat>
  8008bd:	89 c6                	mov    %eax,%esi
	close(fd);
  8008bf:	89 1c 24             	mov    %ebx,(%esp)
  8008c2:	e8 18 fc ff ff       	call   8004df <close>
	return r;
  8008c7:	83 c4 10             	add    $0x10,%esp
  8008ca:	89 f3                	mov    %esi,%ebx
}
  8008cc:	89 d8                	mov    %ebx,%eax
  8008ce:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8008d1:	5b                   	pop    %ebx
  8008d2:	5e                   	pop    %esi
  8008d3:	c9                   	leave  
  8008d4:	c3                   	ret    
  8008d5:	00 00                	add    %al,(%eax)
	...

008008d8 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8008d8:	55                   	push   %ebp
  8008d9:	89 e5                	mov    %esp,%ebp
  8008db:	56                   	push   %esi
  8008dc:	53                   	push   %ebx
  8008dd:	89 c3                	mov    %eax,%ebx
  8008df:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  8008e1:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8008e8:	75 12                	jne    8008fc <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8008ea:	83 ec 0c             	sub    $0xc,%esp
  8008ed:	6a 01                	push   $0x1
  8008ef:	e8 96 11 00 00       	call   801a8a <ipc_find_env>
  8008f4:	a3 00 40 80 00       	mov    %eax,0x804000
  8008f9:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8008fc:	6a 07                	push   $0x7
  8008fe:	68 00 50 80 00       	push   $0x805000
  800903:	53                   	push   %ebx
  800904:	ff 35 00 40 80 00    	pushl  0x804000
  80090a:	e8 26 11 00 00       	call   801a35 <ipc_send>
	
	return ipc_recv(NULL, dstva, NULL);
  80090f:	83 c4 0c             	add    $0xc,%esp
  800912:	6a 00                	push   $0x0
  800914:	56                   	push   %esi
  800915:	6a 00                	push   $0x0
  800917:	e8 a4 10 00 00       	call   8019c0 <ipc_recv>
}
  80091c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80091f:	5b                   	pop    %ebx
  800920:	5e                   	pop    %esi
  800921:	c9                   	leave  
  800922:	c3                   	ret    

00800923 <devfile_stat>:
}


static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  800923:	55                   	push   %ebp
  800924:	89 e5                	mov    %esp,%ebp
  800926:	53                   	push   %ebx
  800927:	83 ec 04             	sub    $0x4,%esp
  80092a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  80092d:	8b 45 08             	mov    0x8(%ebp),%eax
  800930:	8b 40 0c             	mov    0xc(%eax),%eax
  800933:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0) {
  800938:	ba 00 00 00 00       	mov    $0x0,%edx
  80093d:	b8 05 00 00 00       	mov    $0x5,%eax
  800942:	e8 91 ff ff ff       	call   8008d8 <fsipc>
  800947:	85 c0                	test   %eax,%eax
  800949:	78 2c                	js     800977 <devfile_stat+0x54>
		return r;
	}
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  80094b:	83 ec 08             	sub    $0x8,%esp
  80094e:	68 00 50 80 00       	push   $0x805000
  800953:	53                   	push   %ebx
  800954:	e8 e9 0c 00 00       	call   801642 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  800959:	a1 80 50 80 00       	mov    0x805080,%eax
  80095e:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  800964:	a1 84 50 80 00       	mov    0x805084,%eax
  800969:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  80096f:	83 c4 10             	add    $0x10,%esp
  800972:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800977:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80097a:	c9                   	leave  
  80097b:	c3                   	ret    

0080097c <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  80097c:	55                   	push   %ebp
  80097d:	89 e5                	mov    %esp,%ebp
  80097f:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  800982:	8b 45 08             	mov    0x8(%ebp),%eax
  800985:	8b 40 0c             	mov    0xc(%eax),%eax
  800988:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  80098d:	ba 00 00 00 00       	mov    $0x0,%edx
  800992:	b8 06 00 00 00       	mov    $0x6,%eax
  800997:	e8 3c ff ff ff       	call   8008d8 <fsipc>
}
  80099c:	c9                   	leave  
  80099d:	c3                   	ret    

0080099e <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  80099e:	55                   	push   %ebp
  80099f:	89 e5                	mov    %esp,%ebp
  8009a1:	56                   	push   %esi
  8009a2:	53                   	push   %ebx
  8009a3:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8009a6:	8b 45 08             	mov    0x8(%ebp),%eax
  8009a9:	8b 40 0c             	mov    0xc(%eax),%eax
  8009ac:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  8009b1:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8009b7:	ba 00 00 00 00       	mov    $0x0,%edx
  8009bc:	b8 03 00 00 00       	mov    $0x3,%eax
  8009c1:	e8 12 ff ff ff       	call   8008d8 <fsipc>
  8009c6:	89 c3                	mov    %eax,%ebx
  8009c8:	85 c0                	test   %eax,%eax
  8009ca:	78 4b                	js     800a17 <devfile_read+0x79>
		return r;
	assert(r <= n);
  8009cc:	39 c6                	cmp    %eax,%esi
  8009ce:	73 16                	jae    8009e6 <devfile_read+0x48>
  8009d0:	68 50 1e 80 00       	push   $0x801e50
  8009d5:	68 57 1e 80 00       	push   $0x801e57
  8009da:	6a 7d                	push   $0x7d
  8009dc:	68 6c 1e 80 00       	push   $0x801e6c
  8009e1:	e8 ce 05 00 00       	call   800fb4 <_panic>
	assert(r <= PGSIZE);
  8009e6:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8009eb:	7e 16                	jle    800a03 <devfile_read+0x65>
  8009ed:	68 77 1e 80 00       	push   $0x801e77
  8009f2:	68 57 1e 80 00       	push   $0x801e57
  8009f7:	6a 7e                	push   $0x7e
  8009f9:	68 6c 1e 80 00       	push   $0x801e6c
  8009fe:	e8 b1 05 00 00       	call   800fb4 <_panic>
	memmove(buf, &fsipcbuf, r);
  800a03:	83 ec 04             	sub    $0x4,%esp
  800a06:	50                   	push   %eax
  800a07:	68 00 50 80 00       	push   $0x805000
  800a0c:	ff 75 0c             	pushl  0xc(%ebp)
  800a0f:	e8 ef 0d 00 00       	call   801803 <memmove>
	return r;
  800a14:	83 c4 10             	add    $0x10,%esp
}
  800a17:	89 d8                	mov    %ebx,%eax
  800a19:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800a1c:	5b                   	pop    %ebx
  800a1d:	5e                   	pop    %esi
  800a1e:	c9                   	leave  
  800a1f:	c3                   	ret    

00800a20 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  800a20:	55                   	push   %ebp
  800a21:	89 e5                	mov    %esp,%ebp
  800a23:	56                   	push   %esi
  800a24:	53                   	push   %ebx
  800a25:	83 ec 1c             	sub    $0x1c,%esp
  800a28:	8b 75 08             	mov    0x8(%ebp),%esi
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  800a2b:	56                   	push   %esi
  800a2c:	e8 bf 0b 00 00       	call   8015f0 <strlen>
  800a31:	83 c4 10             	add    $0x10,%esp
  800a34:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  800a39:	7f 65                	jg     800aa0 <open+0x80>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800a3b:	83 ec 0c             	sub    $0xc,%esp
  800a3e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800a41:	50                   	push   %eax
  800a42:	e8 e1 f8 ff ff       	call   800328 <fd_alloc>
  800a47:	89 c3                	mov    %eax,%ebx
  800a49:	83 c4 10             	add    $0x10,%esp
  800a4c:	85 c0                	test   %eax,%eax
  800a4e:	78 55                	js     800aa5 <open+0x85>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  800a50:	83 ec 08             	sub    $0x8,%esp
  800a53:	56                   	push   %esi
  800a54:	68 00 50 80 00       	push   $0x805000
  800a59:	e8 e4 0b 00 00       	call   801642 <strcpy>
	fsipcbuf.open.req_omode = mode;
  800a5e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a61:	a3 00 54 80 00       	mov    %eax,0x805400



	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  800a66:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800a69:	b8 01 00 00 00       	mov    $0x1,%eax
  800a6e:	e8 65 fe ff ff       	call   8008d8 <fsipc>
  800a73:	89 c3                	mov    %eax,%ebx
  800a75:	83 c4 10             	add    $0x10,%esp
  800a78:	85 c0                	test   %eax,%eax
  800a7a:	79 12                	jns    800a8e <open+0x6e>
		fd_close(fd, 0);
  800a7c:	83 ec 08             	sub    $0x8,%esp
  800a7f:	6a 00                	push   $0x0
  800a81:	ff 75 f4             	pushl  -0xc(%ebp)
  800a84:	e8 ce f9 ff ff       	call   800457 <fd_close>
		return r;
  800a89:	83 c4 10             	add    $0x10,%esp
  800a8c:	eb 17                	jmp    800aa5 <open+0x85>
	}

	return fd2num(fd);
  800a8e:	83 ec 0c             	sub    $0xc,%esp
  800a91:	ff 75 f4             	pushl  -0xc(%ebp)
  800a94:	e8 67 f8 ff ff       	call   800300 <fd2num>
  800a99:	89 c3                	mov    %eax,%ebx
  800a9b:	83 c4 10             	add    $0x10,%esp
  800a9e:	eb 05                	jmp    800aa5 <open+0x85>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  800aa0:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  800aa5:	89 d8                	mov    %ebx,%eax
  800aa7:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800aaa:	5b                   	pop    %ebx
  800aab:	5e                   	pop    %esi
  800aac:	c9                   	leave  
  800aad:	c3                   	ret    
	...

00800ab0 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  800ab0:	55                   	push   %ebp
  800ab1:	89 e5                	mov    %esp,%ebp
  800ab3:	56                   	push   %esi
  800ab4:	53                   	push   %ebx
  800ab5:	8b 75 0c             	mov    0xc(%ebp),%esi
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  800ab8:	83 ec 0c             	sub    $0xc,%esp
  800abb:	ff 75 08             	pushl  0x8(%ebp)
  800abe:	e8 4d f8 ff ff       	call   800310 <fd2data>
  800ac3:	89 c3                	mov    %eax,%ebx
	strcpy(stat->st_name, "<pipe>");
  800ac5:	83 c4 08             	add    $0x8,%esp
  800ac8:	68 83 1e 80 00       	push   $0x801e83
  800acd:	56                   	push   %esi
  800ace:	e8 6f 0b 00 00       	call   801642 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  800ad3:	8b 43 04             	mov    0x4(%ebx),%eax
  800ad6:	2b 03                	sub    (%ebx),%eax
  800ad8:	89 86 80 00 00 00    	mov    %eax,0x80(%esi)
	stat->st_isdir = 0;
  800ade:	c7 86 84 00 00 00 00 	movl   $0x0,0x84(%esi)
  800ae5:	00 00 00 
	stat->st_dev = &devpipe;
  800ae8:	c7 86 88 00 00 00 24 	movl   $0x803024,0x88(%esi)
  800aef:	30 80 00 
	return 0;
}
  800af2:	b8 00 00 00 00       	mov    $0x0,%eax
  800af7:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800afa:	5b                   	pop    %ebx
  800afb:	5e                   	pop    %esi
  800afc:	c9                   	leave  
  800afd:	c3                   	ret    

00800afe <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  800afe:	55                   	push   %ebp
  800aff:	89 e5                	mov    %esp,%ebp
  800b01:	53                   	push   %ebx
  800b02:	83 ec 0c             	sub    $0xc,%esp
  800b05:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  800b08:	53                   	push   %ebx
  800b09:	6a 00                	push   $0x0
  800b0b:	e8 fa f6 ff ff       	call   80020a <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  800b10:	89 1c 24             	mov    %ebx,(%esp)
  800b13:	e8 f8 f7 ff ff       	call   800310 <fd2data>
  800b18:	83 c4 08             	add    $0x8,%esp
  800b1b:	50                   	push   %eax
  800b1c:	6a 00                	push   $0x0
  800b1e:	e8 e7 f6 ff ff       	call   80020a <sys_page_unmap>
}
  800b23:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800b26:	c9                   	leave  
  800b27:	c3                   	ret    

00800b28 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  800b28:	55                   	push   %ebp
  800b29:	89 e5                	mov    %esp,%ebp
  800b2b:	57                   	push   %edi
  800b2c:	56                   	push   %esi
  800b2d:	53                   	push   %ebx
  800b2e:	83 ec 1c             	sub    $0x1c,%esp
  800b31:	89 c7                	mov    %eax,%edi
  800b33:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  800b36:	a1 04 40 80 00       	mov    0x804004,%eax
  800b3b:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  800b3e:	83 ec 0c             	sub    $0xc,%esp
  800b41:	57                   	push   %edi
  800b42:	e8 a1 0f 00 00       	call   801ae8 <pageref>
  800b47:	89 c6                	mov    %eax,%esi
  800b49:	83 c4 04             	add    $0x4,%esp
  800b4c:	ff 75 e4             	pushl  -0x1c(%ebp)
  800b4f:	e8 94 0f 00 00       	call   801ae8 <pageref>
  800b54:	83 c4 10             	add    $0x10,%esp
  800b57:	39 c6                	cmp    %eax,%esi
  800b59:	0f 94 c0             	sete   %al
  800b5c:	0f b6 c0             	movzbl %al,%eax
		nn = thisenv->env_runs;
  800b5f:	8b 15 04 40 80 00    	mov    0x804004,%edx
  800b65:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  800b68:	39 cb                	cmp    %ecx,%ebx
  800b6a:	75 08                	jne    800b74 <_pipeisclosed+0x4c>
			return ret;
		if (n != nn && ret == 1)
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
	}
}
  800b6c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b6f:	5b                   	pop    %ebx
  800b70:	5e                   	pop    %esi
  800b71:	5f                   	pop    %edi
  800b72:	c9                   	leave  
  800b73:	c3                   	ret    
		n = thisenv->env_runs;
		ret = pageref(fd) == pageref(p);
		nn = thisenv->env_runs;
		if (n == nn)
			return ret;
		if (n != nn && ret == 1)
  800b74:	83 f8 01             	cmp    $0x1,%eax
  800b77:	75 bd                	jne    800b36 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  800b79:	8b 42 58             	mov    0x58(%edx),%eax
  800b7c:	6a 01                	push   $0x1
  800b7e:	50                   	push   %eax
  800b7f:	53                   	push   %ebx
  800b80:	68 8a 1e 80 00       	push   $0x801e8a
  800b85:	e8 02 05 00 00       	call   80108c <cprintf>
  800b8a:	83 c4 10             	add    $0x10,%esp
  800b8d:	eb a7                	jmp    800b36 <_pipeisclosed+0xe>

00800b8f <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  800b8f:	55                   	push   %ebp
  800b90:	89 e5                	mov    %esp,%ebp
  800b92:	57                   	push   %edi
  800b93:	56                   	push   %esi
  800b94:	53                   	push   %ebx
  800b95:	83 ec 28             	sub    $0x28,%esp
  800b98:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  800b9b:	56                   	push   %esi
  800b9c:	e8 6f f7 ff ff       	call   800310 <fd2data>
  800ba1:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800ba3:	83 c4 10             	add    $0x10,%esp
  800ba6:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800baa:	75 4a                	jne    800bf6 <devpipe_write+0x67>
  800bac:	bf 00 00 00 00       	mov    $0x0,%edi
  800bb1:	eb 56                	jmp    800c09 <devpipe_write+0x7a>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  800bb3:	89 da                	mov    %ebx,%edx
  800bb5:	89 f0                	mov    %esi,%eax
  800bb7:	e8 6c ff ff ff       	call   800b28 <_pipeisclosed>
  800bbc:	85 c0                	test   %eax,%eax
  800bbe:	75 4d                	jne    800c0d <devpipe_write+0x7e>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  800bc0:	e8 d4 f5 ff ff       	call   800199 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  800bc5:	8b 43 04             	mov    0x4(%ebx),%eax
  800bc8:	8b 13                	mov    (%ebx),%edx
  800bca:	83 c2 20             	add    $0x20,%edx
  800bcd:	39 d0                	cmp    %edx,%eax
  800bcf:	73 e2                	jae    800bb3 <devpipe_write+0x24>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  800bd1:	89 c2                	mov    %eax,%edx
  800bd3:	81 e2 1f 00 00 80    	and    $0x8000001f,%edx
  800bd9:	79 05                	jns    800be0 <devpipe_write+0x51>
  800bdb:	4a                   	dec    %edx
  800bdc:	83 ca e0             	or     $0xffffffe0,%edx
  800bdf:	42                   	inc    %edx
  800be0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800be3:	8a 0c 39             	mov    (%ecx,%edi,1),%cl
  800be6:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  800bea:	40                   	inc    %eax
  800beb:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800bee:	47                   	inc    %edi
  800bef:	39 7d 10             	cmp    %edi,0x10(%ebp)
  800bf2:	77 07                	ja     800bfb <devpipe_write+0x6c>
  800bf4:	eb 13                	jmp    800c09 <devpipe_write+0x7a>
  800bf6:	bf 00 00 00 00       	mov    $0x0,%edi
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  800bfb:	8b 43 04             	mov    0x4(%ebx),%eax
  800bfe:	8b 13                	mov    (%ebx),%edx
  800c00:	83 c2 20             	add    $0x20,%edx
  800c03:	39 d0                	cmp    %edx,%eax
  800c05:	73 ac                	jae    800bb3 <devpipe_write+0x24>
  800c07:	eb c8                	jmp    800bd1 <devpipe_write+0x42>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  800c09:	89 f8                	mov    %edi,%eax
  800c0b:	eb 05                	jmp    800c12 <devpipe_write+0x83>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  800c0d:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  800c12:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c15:	5b                   	pop    %ebx
  800c16:	5e                   	pop    %esi
  800c17:	5f                   	pop    %edi
  800c18:	c9                   	leave  
  800c19:	c3                   	ret    

00800c1a <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  800c1a:	55                   	push   %ebp
  800c1b:	89 e5                	mov    %esp,%ebp
  800c1d:	57                   	push   %edi
  800c1e:	56                   	push   %esi
  800c1f:	53                   	push   %ebx
  800c20:	83 ec 18             	sub    $0x18,%esp
  800c23:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  800c26:	57                   	push   %edi
  800c27:	e8 e4 f6 ff ff       	call   800310 <fd2data>
  800c2c:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800c2e:	83 c4 10             	add    $0x10,%esp
  800c31:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800c35:	75 44                	jne    800c7b <devpipe_read+0x61>
  800c37:	be 00 00 00 00       	mov    $0x0,%esi
  800c3c:	eb 4f                	jmp    800c8d <devpipe_read+0x73>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
				return i;
  800c3e:	89 f0                	mov    %esi,%eax
  800c40:	eb 54                	jmp    800c96 <devpipe_read+0x7c>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  800c42:	89 da                	mov    %ebx,%edx
  800c44:	89 f8                	mov    %edi,%eax
  800c46:	e8 dd fe ff ff       	call   800b28 <_pipeisclosed>
  800c4b:	85 c0                	test   %eax,%eax
  800c4d:	75 42                	jne    800c91 <devpipe_read+0x77>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  800c4f:	e8 45 f5 ff ff       	call   800199 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  800c54:	8b 03                	mov    (%ebx),%eax
  800c56:	3b 43 04             	cmp    0x4(%ebx),%eax
  800c59:	74 e7                	je     800c42 <devpipe_read+0x28>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  800c5b:	25 1f 00 00 80       	and    $0x8000001f,%eax
  800c60:	79 05                	jns    800c67 <devpipe_read+0x4d>
  800c62:	48                   	dec    %eax
  800c63:	83 c8 e0             	or     $0xffffffe0,%eax
  800c66:	40                   	inc    %eax
  800c67:	8a 44 03 08          	mov    0x8(%ebx,%eax,1),%al
  800c6b:	8b 55 0c             	mov    0xc(%ebp),%edx
  800c6e:	88 04 32             	mov    %al,(%edx,%esi,1)
		p->p_rpos++;
  800c71:	ff 03                	incl   (%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800c73:	46                   	inc    %esi
  800c74:	39 75 10             	cmp    %esi,0x10(%ebp)
  800c77:	77 07                	ja     800c80 <devpipe_read+0x66>
  800c79:	eb 12                	jmp    800c8d <devpipe_read+0x73>
  800c7b:	be 00 00 00 00       	mov    $0x0,%esi
		while (p->p_rpos == p->p_wpos) {
  800c80:	8b 03                	mov    (%ebx),%eax
  800c82:	3b 43 04             	cmp    0x4(%ebx),%eax
  800c85:	75 d4                	jne    800c5b <devpipe_read+0x41>
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  800c87:	85 f6                	test   %esi,%esi
  800c89:	75 b3                	jne    800c3e <devpipe_read+0x24>
  800c8b:	eb b5                	jmp    800c42 <devpipe_read+0x28>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  800c8d:	89 f0                	mov    %esi,%eax
  800c8f:	eb 05                	jmp    800c96 <devpipe_read+0x7c>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  800c91:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  800c96:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c99:	5b                   	pop    %ebx
  800c9a:	5e                   	pop    %esi
  800c9b:	5f                   	pop    %edi
  800c9c:	c9                   	leave  
  800c9d:	c3                   	ret    

00800c9e <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  800c9e:	55                   	push   %ebp
  800c9f:	89 e5                	mov    %esp,%ebp
  800ca1:	57                   	push   %edi
  800ca2:	56                   	push   %esi
  800ca3:	53                   	push   %ebx
  800ca4:	83 ec 28             	sub    $0x28,%esp
  800ca7:	8b 7d 08             	mov    0x8(%ebp),%edi
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  800caa:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800cad:	50                   	push   %eax
  800cae:	e8 75 f6 ff ff       	call   800328 <fd_alloc>
  800cb3:	89 c3                	mov    %eax,%ebx
  800cb5:	83 c4 10             	add    $0x10,%esp
  800cb8:	85 c0                	test   %eax,%eax
  800cba:	0f 88 24 01 00 00    	js     800de4 <pipe+0x146>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800cc0:	83 ec 04             	sub    $0x4,%esp
  800cc3:	68 07 04 00 00       	push   $0x407
  800cc8:	ff 75 e4             	pushl  -0x1c(%ebp)
  800ccb:	6a 00                	push   $0x0
  800ccd:	e8 ee f4 ff ff       	call   8001c0 <sys_page_alloc>
  800cd2:	89 c3                	mov    %eax,%ebx
  800cd4:	83 c4 10             	add    $0x10,%esp
  800cd7:	85 c0                	test   %eax,%eax
  800cd9:	0f 88 05 01 00 00    	js     800de4 <pipe+0x146>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  800cdf:	83 ec 0c             	sub    $0xc,%esp
  800ce2:	8d 45 e0             	lea    -0x20(%ebp),%eax
  800ce5:	50                   	push   %eax
  800ce6:	e8 3d f6 ff ff       	call   800328 <fd_alloc>
  800ceb:	89 c3                	mov    %eax,%ebx
  800ced:	83 c4 10             	add    $0x10,%esp
  800cf0:	85 c0                	test   %eax,%eax
  800cf2:	0f 88 dc 00 00 00    	js     800dd4 <pipe+0x136>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800cf8:	83 ec 04             	sub    $0x4,%esp
  800cfb:	68 07 04 00 00       	push   $0x407
  800d00:	ff 75 e0             	pushl  -0x20(%ebp)
  800d03:	6a 00                	push   $0x0
  800d05:	e8 b6 f4 ff ff       	call   8001c0 <sys_page_alloc>
  800d0a:	89 c3                	mov    %eax,%ebx
  800d0c:	83 c4 10             	add    $0x10,%esp
  800d0f:	85 c0                	test   %eax,%eax
  800d11:	0f 88 bd 00 00 00    	js     800dd4 <pipe+0x136>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  800d17:	83 ec 0c             	sub    $0xc,%esp
  800d1a:	ff 75 e4             	pushl  -0x1c(%ebp)
  800d1d:	e8 ee f5 ff ff       	call   800310 <fd2data>
  800d22:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800d24:	83 c4 0c             	add    $0xc,%esp
  800d27:	68 07 04 00 00       	push   $0x407
  800d2c:	50                   	push   %eax
  800d2d:	6a 00                	push   $0x0
  800d2f:	e8 8c f4 ff ff       	call   8001c0 <sys_page_alloc>
  800d34:	89 c3                	mov    %eax,%ebx
  800d36:	83 c4 10             	add    $0x10,%esp
  800d39:	85 c0                	test   %eax,%eax
  800d3b:	0f 88 83 00 00 00    	js     800dc4 <pipe+0x126>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800d41:	83 ec 0c             	sub    $0xc,%esp
  800d44:	ff 75 e0             	pushl  -0x20(%ebp)
  800d47:	e8 c4 f5 ff ff       	call   800310 <fd2data>
  800d4c:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  800d53:	50                   	push   %eax
  800d54:	6a 00                	push   $0x0
  800d56:	56                   	push   %esi
  800d57:	6a 00                	push   $0x0
  800d59:	e8 86 f4 ff ff       	call   8001e4 <sys_page_map>
  800d5e:	89 c3                	mov    %eax,%ebx
  800d60:	83 c4 20             	add    $0x20,%esp
  800d63:	85 c0                	test   %eax,%eax
  800d65:	78 4f                	js     800db6 <pipe+0x118>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  800d67:	8b 15 24 30 80 00    	mov    0x803024,%edx
  800d6d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800d70:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  800d72:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800d75:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  800d7c:	8b 15 24 30 80 00    	mov    0x803024,%edx
  800d82:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800d85:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  800d87:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800d8a:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  800d91:	83 ec 0c             	sub    $0xc,%esp
  800d94:	ff 75 e4             	pushl  -0x1c(%ebp)
  800d97:	e8 64 f5 ff ff       	call   800300 <fd2num>
  800d9c:	89 07                	mov    %eax,(%edi)
	pfd[1] = fd2num(fd1);
  800d9e:	83 c4 04             	add    $0x4,%esp
  800da1:	ff 75 e0             	pushl  -0x20(%ebp)
  800da4:	e8 57 f5 ff ff       	call   800300 <fd2num>
  800da9:	89 47 04             	mov    %eax,0x4(%edi)
	return 0;
  800dac:	83 c4 10             	add    $0x10,%esp
  800daf:	bb 00 00 00 00       	mov    $0x0,%ebx
  800db4:	eb 2e                	jmp    800de4 <pipe+0x146>

    err3:
	sys_page_unmap(0, va);
  800db6:	83 ec 08             	sub    $0x8,%esp
  800db9:	56                   	push   %esi
  800dba:	6a 00                	push   $0x0
  800dbc:	e8 49 f4 ff ff       	call   80020a <sys_page_unmap>
  800dc1:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  800dc4:	83 ec 08             	sub    $0x8,%esp
  800dc7:	ff 75 e0             	pushl  -0x20(%ebp)
  800dca:	6a 00                	push   $0x0
  800dcc:	e8 39 f4 ff ff       	call   80020a <sys_page_unmap>
  800dd1:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  800dd4:	83 ec 08             	sub    $0x8,%esp
  800dd7:	ff 75 e4             	pushl  -0x1c(%ebp)
  800dda:	6a 00                	push   $0x0
  800ddc:	e8 29 f4 ff ff       	call   80020a <sys_page_unmap>
  800de1:	83 c4 10             	add    $0x10,%esp
    err:
	return r;
}
  800de4:	89 d8                	mov    %ebx,%eax
  800de6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800de9:	5b                   	pop    %ebx
  800dea:	5e                   	pop    %esi
  800deb:	5f                   	pop    %edi
  800dec:	c9                   	leave  
  800ded:	c3                   	ret    

00800dee <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  800dee:	55                   	push   %ebp
  800def:	89 e5                	mov    %esp,%ebp
  800df1:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800df4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800df7:	50                   	push   %eax
  800df8:	ff 75 08             	pushl  0x8(%ebp)
  800dfb:	e8 9b f5 ff ff       	call   80039b <fd_lookup>
  800e00:	83 c4 10             	add    $0x10,%esp
  800e03:	85 c0                	test   %eax,%eax
  800e05:	78 18                	js     800e1f <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  800e07:	83 ec 0c             	sub    $0xc,%esp
  800e0a:	ff 75 f4             	pushl  -0xc(%ebp)
  800e0d:	e8 fe f4 ff ff       	call   800310 <fd2data>
	return _pipeisclosed(fd, p);
  800e12:	89 c2                	mov    %eax,%edx
  800e14:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800e17:	e8 0c fd ff ff       	call   800b28 <_pipeisclosed>
  800e1c:	83 c4 10             	add    $0x10,%esp
}
  800e1f:	c9                   	leave  
  800e20:	c3                   	ret    
  800e21:	00 00                	add    %al,(%eax)
	...

00800e24 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  800e24:	55                   	push   %ebp
  800e25:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  800e27:	b8 00 00 00 00       	mov    $0x0,%eax
  800e2c:	c9                   	leave  
  800e2d:	c3                   	ret    

00800e2e <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  800e2e:	55                   	push   %ebp
  800e2f:	89 e5                	mov    %esp,%ebp
  800e31:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  800e34:	68 a2 1e 80 00       	push   $0x801ea2
  800e39:	ff 75 0c             	pushl  0xc(%ebp)
  800e3c:	e8 01 08 00 00       	call   801642 <strcpy>
	return 0;
}
  800e41:	b8 00 00 00 00       	mov    $0x0,%eax
  800e46:	c9                   	leave  
  800e47:	c3                   	ret    

00800e48 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  800e48:	55                   	push   %ebp
  800e49:	89 e5                	mov    %esp,%ebp
  800e4b:	57                   	push   %edi
  800e4c:	56                   	push   %esi
  800e4d:	53                   	push   %ebx
  800e4e:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800e54:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800e58:	74 45                	je     800e9f <devcons_write+0x57>
  800e5a:	b8 00 00 00 00       	mov    $0x0,%eax
  800e5f:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  800e64:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  800e6a:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e6d:	29 c3                	sub    %eax,%ebx
		if (m > sizeof(buf) - 1)
  800e6f:	83 fb 7f             	cmp    $0x7f,%ebx
  800e72:	76 05                	jbe    800e79 <devcons_write+0x31>
			m = sizeof(buf) - 1;
  800e74:	bb 7f 00 00 00       	mov    $0x7f,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  800e79:	83 ec 04             	sub    $0x4,%esp
  800e7c:	53                   	push   %ebx
  800e7d:	03 45 0c             	add    0xc(%ebp),%eax
  800e80:	50                   	push   %eax
  800e81:	57                   	push   %edi
  800e82:	e8 7c 09 00 00       	call   801803 <memmove>
		sys_cputs(buf, m);
  800e87:	83 c4 08             	add    $0x8,%esp
  800e8a:	53                   	push   %ebx
  800e8b:	57                   	push   %edi
  800e8c:	e8 78 f2 ff ff       	call   800109 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800e91:	01 de                	add    %ebx,%esi
  800e93:	89 f0                	mov    %esi,%eax
  800e95:	83 c4 10             	add    $0x10,%esp
  800e98:	3b 75 10             	cmp    0x10(%ebp),%esi
  800e9b:	72 cd                	jb     800e6a <devcons_write+0x22>
  800e9d:	eb 05                	jmp    800ea4 <devcons_write+0x5c>
  800e9f:	be 00 00 00 00       	mov    $0x0,%esi
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  800ea4:	89 f0                	mov    %esi,%eax
  800ea6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ea9:	5b                   	pop    %ebx
  800eaa:	5e                   	pop    %esi
  800eab:	5f                   	pop    %edi
  800eac:	c9                   	leave  
  800ead:	c3                   	ret    

00800eae <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  800eae:	55                   	push   %ebp
  800eaf:	89 e5                	mov    %esp,%ebp
  800eb1:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
  800eb4:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800eb8:	75 07                	jne    800ec1 <devcons_read+0x13>
  800eba:	eb 25                	jmp    800ee1 <devcons_read+0x33>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  800ebc:	e8 d8 f2 ff ff       	call   800199 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  800ec1:	e8 69 f2 ff ff       	call   80012f <sys_cgetc>
  800ec6:	85 c0                	test   %eax,%eax
  800ec8:	74 f2                	je     800ebc <devcons_read+0xe>
  800eca:	89 c2                	mov    %eax,%edx
		sys_yield();
	if (c < 0)
  800ecc:	85 c0                	test   %eax,%eax
  800ece:	78 1d                	js     800eed <devcons_read+0x3f>
		return c;
	if (c == 0x04)	// ctl-d is eof
  800ed0:	83 f8 04             	cmp    $0x4,%eax
  800ed3:	74 13                	je     800ee8 <devcons_read+0x3a>
		return 0;
	*(char*)vbuf = c;
  800ed5:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ed8:	88 10                	mov    %dl,(%eax)
	return 1;
  800eda:	b8 01 00 00 00       	mov    $0x1,%eax
  800edf:	eb 0c                	jmp    800eed <devcons_read+0x3f>
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
		return 0;
  800ee1:	b8 00 00 00 00       	mov    $0x0,%eax
  800ee6:	eb 05                	jmp    800eed <devcons_read+0x3f>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  800ee8:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  800eed:	c9                   	leave  
  800eee:	c3                   	ret    

00800eef <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  800eef:	55                   	push   %ebp
  800ef0:	89 e5                	mov    %esp,%ebp
  800ef2:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  800ef5:	8b 45 08             	mov    0x8(%ebp),%eax
  800ef8:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  800efb:	6a 01                	push   $0x1
  800efd:	8d 45 f7             	lea    -0x9(%ebp),%eax
  800f00:	50                   	push   %eax
  800f01:	e8 03 f2 ff ff       	call   800109 <sys_cputs>
  800f06:	83 c4 10             	add    $0x10,%esp
}
  800f09:	c9                   	leave  
  800f0a:	c3                   	ret    

00800f0b <getchar>:

int
getchar(void)
{
  800f0b:	55                   	push   %ebp
  800f0c:	89 e5                	mov    %esp,%ebp
  800f0e:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  800f11:	6a 01                	push   $0x1
  800f13:	8d 45 f7             	lea    -0x9(%ebp),%eax
  800f16:	50                   	push   %eax
  800f17:	6a 00                	push   $0x0
  800f19:	e8 fe f6 ff ff       	call   80061c <read>
	if (r < 0)
  800f1e:	83 c4 10             	add    $0x10,%esp
  800f21:	85 c0                	test   %eax,%eax
  800f23:	78 0f                	js     800f34 <getchar+0x29>
		return r;
	if (r < 1)
  800f25:	85 c0                	test   %eax,%eax
  800f27:	7e 06                	jle    800f2f <getchar+0x24>
		return -E_EOF;
	return c;
  800f29:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  800f2d:	eb 05                	jmp    800f34 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  800f2f:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  800f34:	c9                   	leave  
  800f35:	c3                   	ret    

00800f36 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  800f36:	55                   	push   %ebp
  800f37:	89 e5                	mov    %esp,%ebp
  800f39:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800f3c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800f3f:	50                   	push   %eax
  800f40:	ff 75 08             	pushl  0x8(%ebp)
  800f43:	e8 53 f4 ff ff       	call   80039b <fd_lookup>
  800f48:	83 c4 10             	add    $0x10,%esp
  800f4b:	85 c0                	test   %eax,%eax
  800f4d:	78 11                	js     800f60 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  800f4f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800f52:	8b 15 40 30 80 00    	mov    0x803040,%edx
  800f58:	39 10                	cmp    %edx,(%eax)
  800f5a:	0f 94 c0             	sete   %al
  800f5d:	0f b6 c0             	movzbl %al,%eax
}
  800f60:	c9                   	leave  
  800f61:	c3                   	ret    

00800f62 <opencons>:

int
opencons(void)
{
  800f62:	55                   	push   %ebp
  800f63:	89 e5                	mov    %esp,%ebp
  800f65:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  800f68:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800f6b:	50                   	push   %eax
  800f6c:	e8 b7 f3 ff ff       	call   800328 <fd_alloc>
  800f71:	83 c4 10             	add    $0x10,%esp
  800f74:	85 c0                	test   %eax,%eax
  800f76:	78 3a                	js     800fb2 <opencons+0x50>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  800f78:	83 ec 04             	sub    $0x4,%esp
  800f7b:	68 07 04 00 00       	push   $0x407
  800f80:	ff 75 f4             	pushl  -0xc(%ebp)
  800f83:	6a 00                	push   $0x0
  800f85:	e8 36 f2 ff ff       	call   8001c0 <sys_page_alloc>
  800f8a:	83 c4 10             	add    $0x10,%esp
  800f8d:	85 c0                	test   %eax,%eax
  800f8f:	78 21                	js     800fb2 <opencons+0x50>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  800f91:	8b 15 40 30 80 00    	mov    0x803040,%edx
  800f97:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800f9a:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  800f9c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800f9f:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  800fa6:	83 ec 0c             	sub    $0xc,%esp
  800fa9:	50                   	push   %eax
  800faa:	e8 51 f3 ff ff       	call   800300 <fd2num>
  800faf:	83 c4 10             	add    $0x10,%esp
}
  800fb2:	c9                   	leave  
  800fb3:	c3                   	ret    

00800fb4 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800fb4:	55                   	push   %ebp
  800fb5:	89 e5                	mov    %esp,%ebp
  800fb7:	56                   	push   %esi
  800fb8:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800fb9:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800fbc:	8b 1d 04 30 80 00    	mov    0x803004,%ebx
  800fc2:	e8 ae f1 ff ff       	call   800175 <sys_getenvid>
  800fc7:	83 ec 0c             	sub    $0xc,%esp
  800fca:	ff 75 0c             	pushl  0xc(%ebp)
  800fcd:	ff 75 08             	pushl  0x8(%ebp)
  800fd0:	53                   	push   %ebx
  800fd1:	50                   	push   %eax
  800fd2:	68 b0 1e 80 00       	push   $0x801eb0
  800fd7:	e8 b0 00 00 00       	call   80108c <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800fdc:	83 c4 18             	add    $0x18,%esp
  800fdf:	56                   	push   %esi
  800fe0:	ff 75 10             	pushl  0x10(%ebp)
  800fe3:	e8 53 00 00 00       	call   80103b <vcprintf>
	cprintf("\n");
  800fe8:	c7 04 24 9b 1e 80 00 	movl   $0x801e9b,(%esp)
  800fef:	e8 98 00 00 00       	call   80108c <cprintf>
  800ff4:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800ff7:	cc                   	int3   
  800ff8:	eb fd                	jmp    800ff7 <_panic+0x43>
	...

00800ffc <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800ffc:	55                   	push   %ebp
  800ffd:	89 e5                	mov    %esp,%ebp
  800fff:	53                   	push   %ebx
  801000:	83 ec 04             	sub    $0x4,%esp
  801003:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  801006:	8b 03                	mov    (%ebx),%eax
  801008:	8b 55 08             	mov    0x8(%ebp),%edx
  80100b:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  80100f:	40                   	inc    %eax
  801010:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  801012:	3d ff 00 00 00       	cmp    $0xff,%eax
  801017:	75 1a                	jne    801033 <putch+0x37>
		sys_cputs(b->buf, b->idx);
  801019:	83 ec 08             	sub    $0x8,%esp
  80101c:	68 ff 00 00 00       	push   $0xff
  801021:	8d 43 08             	lea    0x8(%ebx),%eax
  801024:	50                   	push   %eax
  801025:	e8 df f0 ff ff       	call   800109 <sys_cputs>
		b->idx = 0;
  80102a:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801030:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  801033:	ff 43 04             	incl   0x4(%ebx)
}
  801036:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801039:	c9                   	leave  
  80103a:	c3                   	ret    

0080103b <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80103b:	55                   	push   %ebp
  80103c:	89 e5                	mov    %esp,%ebp
  80103e:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  801044:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80104b:	00 00 00 
	b.cnt = 0;
  80104e:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  801055:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  801058:	ff 75 0c             	pushl  0xc(%ebp)
  80105b:	ff 75 08             	pushl  0x8(%ebp)
  80105e:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  801064:	50                   	push   %eax
  801065:	68 fc 0f 80 00       	push   $0x800ffc
  80106a:	e8 82 01 00 00       	call   8011f1 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80106f:	83 c4 08             	add    $0x8,%esp
  801072:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  801078:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80107e:	50                   	push   %eax
  80107f:	e8 85 f0 ff ff       	call   800109 <sys_cputs>

	return b.cnt;
}
  801084:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80108a:	c9                   	leave  
  80108b:	c3                   	ret    

0080108c <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80108c:	55                   	push   %ebp
  80108d:	89 e5                	mov    %esp,%ebp
  80108f:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  801092:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  801095:	50                   	push   %eax
  801096:	ff 75 08             	pushl  0x8(%ebp)
  801099:	e8 9d ff ff ff       	call   80103b <vcprintf>
	va_end(ap);

	return cnt;
}
  80109e:	c9                   	leave  
  80109f:	c3                   	ret    

008010a0 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8010a0:	55                   	push   %ebp
  8010a1:	89 e5                	mov    %esp,%ebp
  8010a3:	57                   	push   %edi
  8010a4:	56                   	push   %esi
  8010a5:	53                   	push   %ebx
  8010a6:	83 ec 2c             	sub    $0x2c,%esp
  8010a9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8010ac:	89 d6                	mov    %edx,%esi
  8010ae:	8b 45 08             	mov    0x8(%ebp),%eax
  8010b1:	8b 55 0c             	mov    0xc(%ebp),%edx
  8010b4:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8010b7:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8010ba:	8b 45 10             	mov    0x10(%ebp),%eax
  8010bd:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8010c0:	8b 7d 18             	mov    0x18(%ebp),%edi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8010c3:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8010c6:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  8010cd:	39 55 d4             	cmp    %edx,-0x2c(%ebp)
  8010d0:	72 0c                	jb     8010de <printnum+0x3e>
  8010d2:	3b 45 d8             	cmp    -0x28(%ebp),%eax
  8010d5:	76 07                	jbe    8010de <printnum+0x3e>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8010d7:	4b                   	dec    %ebx
  8010d8:	85 db                	test   %ebx,%ebx
  8010da:	7f 31                	jg     80110d <printnum+0x6d>
  8010dc:	eb 3f                	jmp    80111d <printnum+0x7d>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8010de:	83 ec 0c             	sub    $0xc,%esp
  8010e1:	57                   	push   %edi
  8010e2:	4b                   	dec    %ebx
  8010e3:	53                   	push   %ebx
  8010e4:	50                   	push   %eax
  8010e5:	83 ec 08             	sub    $0x8,%esp
  8010e8:	ff 75 d4             	pushl  -0x2c(%ebp)
  8010eb:	ff 75 d0             	pushl  -0x30(%ebp)
  8010ee:	ff 75 dc             	pushl  -0x24(%ebp)
  8010f1:	ff 75 d8             	pushl  -0x28(%ebp)
  8010f4:	e8 33 0a 00 00       	call   801b2c <__udivdi3>
  8010f9:	83 c4 18             	add    $0x18,%esp
  8010fc:	52                   	push   %edx
  8010fd:	50                   	push   %eax
  8010fe:	89 f2                	mov    %esi,%edx
  801100:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801103:	e8 98 ff ff ff       	call   8010a0 <printnum>
  801108:	83 c4 20             	add    $0x20,%esp
  80110b:	eb 10                	jmp    80111d <printnum+0x7d>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80110d:	83 ec 08             	sub    $0x8,%esp
  801110:	56                   	push   %esi
  801111:	57                   	push   %edi
  801112:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  801115:	4b                   	dec    %ebx
  801116:	83 c4 10             	add    $0x10,%esp
  801119:	85 db                	test   %ebx,%ebx
  80111b:	7f f0                	jg     80110d <printnum+0x6d>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80111d:	83 ec 08             	sub    $0x8,%esp
  801120:	56                   	push   %esi
  801121:	83 ec 04             	sub    $0x4,%esp
  801124:	ff 75 d4             	pushl  -0x2c(%ebp)
  801127:	ff 75 d0             	pushl  -0x30(%ebp)
  80112a:	ff 75 dc             	pushl  -0x24(%ebp)
  80112d:	ff 75 d8             	pushl  -0x28(%ebp)
  801130:	e8 13 0b 00 00       	call   801c48 <__umoddi3>
  801135:	83 c4 14             	add    $0x14,%esp
  801138:	0f be 80 d3 1e 80 00 	movsbl 0x801ed3(%eax),%eax
  80113f:	50                   	push   %eax
  801140:	ff 55 e4             	call   *-0x1c(%ebp)
  801143:	83 c4 10             	add    $0x10,%esp
}
  801146:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801149:	5b                   	pop    %ebx
  80114a:	5e                   	pop    %esi
  80114b:	5f                   	pop    %edi
  80114c:	c9                   	leave  
  80114d:	c3                   	ret    

0080114e <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80114e:	55                   	push   %ebp
  80114f:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  801151:	83 fa 01             	cmp    $0x1,%edx
  801154:	7e 0e                	jle    801164 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  801156:	8b 10                	mov    (%eax),%edx
  801158:	8d 4a 08             	lea    0x8(%edx),%ecx
  80115b:	89 08                	mov    %ecx,(%eax)
  80115d:	8b 02                	mov    (%edx),%eax
  80115f:	8b 52 04             	mov    0x4(%edx),%edx
  801162:	eb 22                	jmp    801186 <getuint+0x38>
	else if (lflag)
  801164:	85 d2                	test   %edx,%edx
  801166:	74 10                	je     801178 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  801168:	8b 10                	mov    (%eax),%edx
  80116a:	8d 4a 04             	lea    0x4(%edx),%ecx
  80116d:	89 08                	mov    %ecx,(%eax)
  80116f:	8b 02                	mov    (%edx),%eax
  801171:	ba 00 00 00 00       	mov    $0x0,%edx
  801176:	eb 0e                	jmp    801186 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  801178:	8b 10                	mov    (%eax),%edx
  80117a:	8d 4a 04             	lea    0x4(%edx),%ecx
  80117d:	89 08                	mov    %ecx,(%eax)
  80117f:	8b 02                	mov    (%edx),%eax
  801181:	ba 00 00 00 00       	mov    $0x0,%edx
}
  801186:	c9                   	leave  
  801187:	c3                   	ret    

00801188 <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
  801188:	55                   	push   %ebp
  801189:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80118b:	83 fa 01             	cmp    $0x1,%edx
  80118e:	7e 0e                	jle    80119e <getint+0x16>
		return va_arg(*ap, long long);
  801190:	8b 10                	mov    (%eax),%edx
  801192:	8d 4a 08             	lea    0x8(%edx),%ecx
  801195:	89 08                	mov    %ecx,(%eax)
  801197:	8b 02                	mov    (%edx),%eax
  801199:	8b 52 04             	mov    0x4(%edx),%edx
  80119c:	eb 1a                	jmp    8011b8 <getint+0x30>
	else if (lflag)
  80119e:	85 d2                	test   %edx,%edx
  8011a0:	74 0c                	je     8011ae <getint+0x26>
		return va_arg(*ap, long);
  8011a2:	8b 10                	mov    (%eax),%edx
  8011a4:	8d 4a 04             	lea    0x4(%edx),%ecx
  8011a7:	89 08                	mov    %ecx,(%eax)
  8011a9:	8b 02                	mov    (%edx),%eax
  8011ab:	99                   	cltd   
  8011ac:	eb 0a                	jmp    8011b8 <getint+0x30>
	else
		return va_arg(*ap, int);
  8011ae:	8b 10                	mov    (%eax),%edx
  8011b0:	8d 4a 04             	lea    0x4(%edx),%ecx
  8011b3:	89 08                	mov    %ecx,(%eax)
  8011b5:	8b 02                	mov    (%edx),%eax
  8011b7:	99                   	cltd   
}
  8011b8:	c9                   	leave  
  8011b9:	c3                   	ret    

008011ba <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8011ba:	55                   	push   %ebp
  8011bb:	89 e5                	mov    %esp,%ebp
  8011bd:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8011c0:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  8011c3:	8b 10                	mov    (%eax),%edx
  8011c5:	3b 50 04             	cmp    0x4(%eax),%edx
  8011c8:	73 08                	jae    8011d2 <sprintputch+0x18>
		*b->buf++ = ch;
  8011ca:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8011cd:	88 0a                	mov    %cl,(%edx)
  8011cf:	42                   	inc    %edx
  8011d0:	89 10                	mov    %edx,(%eax)
}
  8011d2:	c9                   	leave  
  8011d3:	c3                   	ret    

008011d4 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8011d4:	55                   	push   %ebp
  8011d5:	89 e5                	mov    %esp,%ebp
  8011d7:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8011da:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8011dd:	50                   	push   %eax
  8011de:	ff 75 10             	pushl  0x10(%ebp)
  8011e1:	ff 75 0c             	pushl  0xc(%ebp)
  8011e4:	ff 75 08             	pushl  0x8(%ebp)
  8011e7:	e8 05 00 00 00       	call   8011f1 <vprintfmt>
	va_end(ap);
  8011ec:	83 c4 10             	add    $0x10,%esp
}
  8011ef:	c9                   	leave  
  8011f0:	c3                   	ret    

008011f1 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8011f1:	55                   	push   %ebp
  8011f2:	89 e5                	mov    %esp,%ebp
  8011f4:	57                   	push   %edi
  8011f5:	56                   	push   %esi
  8011f6:	53                   	push   %ebx
  8011f7:	83 ec 2c             	sub    $0x2c,%esp
  8011fa:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8011fd:	8b 75 10             	mov    0x10(%ebp),%esi
  801200:	eb 13                	jmp    801215 <vprintfmt+0x24>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  801202:	85 c0                	test   %eax,%eax
  801204:	0f 84 6d 03 00 00    	je     801577 <vprintfmt+0x386>
				return;
			putch(ch, putdat);
  80120a:	83 ec 08             	sub    $0x8,%esp
  80120d:	57                   	push   %edi
  80120e:	50                   	push   %eax
  80120f:	ff 55 08             	call   *0x8(%ebp)
  801212:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  801215:	0f b6 06             	movzbl (%esi),%eax
  801218:	46                   	inc    %esi
  801219:	83 f8 25             	cmp    $0x25,%eax
  80121c:	75 e4                	jne    801202 <vprintfmt+0x11>
  80121e:	c6 45 dc 20          	movb   $0x20,-0x24(%ebp)
  801222:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  801229:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
  801230:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  801237:	b9 00 00 00 00       	mov    $0x0,%ecx
  80123c:	eb 28                	jmp    801266 <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80123e:	89 de                	mov    %ebx,%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  801240:	c6 45 dc 2d          	movb   $0x2d,-0x24(%ebp)
  801244:	eb 20                	jmp    801266 <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801246:	89 de                	mov    %ebx,%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  801248:	c6 45 dc 30          	movb   $0x30,-0x24(%ebp)
  80124c:	eb 18                	jmp    801266 <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80124e:	89 de                	mov    %ebx,%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  801250:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  801257:	eb 0d                	jmp    801266 <vprintfmt+0x75>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  801259:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80125c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80125f:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801266:	8a 06                	mov    (%esi),%al
  801268:	0f b6 d0             	movzbl %al,%edx
  80126b:	8d 5e 01             	lea    0x1(%esi),%ebx
  80126e:	83 e8 23             	sub    $0x23,%eax
  801271:	3c 55                	cmp    $0x55,%al
  801273:	0f 87 e0 02 00 00    	ja     801559 <vprintfmt+0x368>
  801279:	0f b6 c0             	movzbl %al,%eax
  80127c:	ff 24 85 20 20 80 00 	jmp    *0x802020(,%eax,4)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  801283:	83 ea 30             	sub    $0x30,%edx
  801286:	89 55 d4             	mov    %edx,-0x2c(%ebp)
				ch = *fmt;
  801289:	0f be 03             	movsbl (%ebx),%eax
				if (ch < '0' || ch > '9')
  80128c:	8d 50 d0             	lea    -0x30(%eax),%edx
  80128f:	83 fa 09             	cmp    $0x9,%edx
  801292:	77 44                	ja     8012d8 <vprintfmt+0xe7>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801294:	89 de                	mov    %ebx,%esi
  801296:	8b 55 d4             	mov    -0x2c(%ebp),%edx
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  801299:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
  80129a:	8d 14 92             	lea    (%edx,%edx,4),%edx
  80129d:	8d 54 50 d0          	lea    -0x30(%eax,%edx,2),%edx
				ch = *fmt;
  8012a1:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  8012a4:	8d 58 d0             	lea    -0x30(%eax),%ebx
  8012a7:	83 fb 09             	cmp    $0x9,%ebx
  8012aa:	76 ed                	jbe    801299 <vprintfmt+0xa8>
  8012ac:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  8012af:	eb 29                	jmp    8012da <vprintfmt+0xe9>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8012b1:	8b 45 14             	mov    0x14(%ebp),%eax
  8012b4:	8d 50 04             	lea    0x4(%eax),%edx
  8012b7:	89 55 14             	mov    %edx,0x14(%ebp)
  8012ba:	8b 00                	mov    (%eax),%eax
  8012bc:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8012bf:	89 de                	mov    %ebx,%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8012c1:	eb 17                	jmp    8012da <vprintfmt+0xe9>

		case '.':
			if (width < 0)
  8012c3:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8012c7:	78 85                	js     80124e <vprintfmt+0x5d>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8012c9:	89 de                	mov    %ebx,%esi
  8012cb:	eb 99                	jmp    801266 <vprintfmt+0x75>
  8012cd:	89 de                	mov    %ebx,%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8012cf:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
			goto reswitch;
  8012d6:	eb 8e                	jmp    801266 <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8012d8:	89 de                	mov    %ebx,%esi
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  8012da:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8012de:	79 86                	jns    801266 <vprintfmt+0x75>
  8012e0:	e9 74 ff ff ff       	jmp    801259 <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8012e5:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8012e6:	89 de                	mov    %ebx,%esi
  8012e8:	e9 79 ff ff ff       	jmp    801266 <vprintfmt+0x75>
  8012ed:	89 5d d8             	mov    %ebx,-0x28(%ebp)
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8012f0:	8b 45 14             	mov    0x14(%ebp),%eax
  8012f3:	8d 50 04             	lea    0x4(%eax),%edx
  8012f6:	89 55 14             	mov    %edx,0x14(%ebp)
  8012f9:	83 ec 08             	sub    $0x8,%esp
  8012fc:	57                   	push   %edi
  8012fd:	ff 30                	pushl  (%eax)
  8012ff:	ff 55 08             	call   *0x8(%ebp)
			break;
  801302:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801305:	8b 75 d8             	mov    -0x28(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  801308:	e9 08 ff ff ff       	jmp    801215 <vprintfmt+0x24>
  80130d:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// error message
		case 'e':
			err = va_arg(ap, int);
  801310:	8b 45 14             	mov    0x14(%ebp),%eax
  801313:	8d 50 04             	lea    0x4(%eax),%edx
  801316:	89 55 14             	mov    %edx,0x14(%ebp)
  801319:	8b 00                	mov    (%eax),%eax
  80131b:	85 c0                	test   %eax,%eax
  80131d:	79 02                	jns    801321 <vprintfmt+0x130>
  80131f:	f7 d8                	neg    %eax
  801321:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  801323:	83 f8 0f             	cmp    $0xf,%eax
  801326:	7f 0b                	jg     801333 <vprintfmt+0x142>
  801328:	8b 04 85 80 21 80 00 	mov    0x802180(,%eax,4),%eax
  80132f:	85 c0                	test   %eax,%eax
  801331:	75 1a                	jne    80134d <vprintfmt+0x15c>
				printfmt(putch, putdat, "error %d", err);
  801333:	52                   	push   %edx
  801334:	68 eb 1e 80 00       	push   $0x801eeb
  801339:	57                   	push   %edi
  80133a:	ff 75 08             	pushl  0x8(%ebp)
  80133d:	e8 92 fe ff ff       	call   8011d4 <printfmt>
  801342:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801345:	8b 75 d8             	mov    -0x28(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  801348:	e9 c8 fe ff ff       	jmp    801215 <vprintfmt+0x24>
			else
				printfmt(putch, putdat, "%s", p);
  80134d:	50                   	push   %eax
  80134e:	68 69 1e 80 00       	push   $0x801e69
  801353:	57                   	push   %edi
  801354:	ff 75 08             	pushl  0x8(%ebp)
  801357:	e8 78 fe ff ff       	call   8011d4 <printfmt>
  80135c:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80135f:	8b 75 d8             	mov    -0x28(%ebp),%esi
  801362:	e9 ae fe ff ff       	jmp    801215 <vprintfmt+0x24>
  801367:	89 5d d8             	mov    %ebx,-0x28(%ebp)
  80136a:	89 de                	mov    %ebx,%esi
  80136c:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  80136f:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  801372:	8b 45 14             	mov    0x14(%ebp),%eax
  801375:	8d 50 04             	lea    0x4(%eax),%edx
  801378:	89 55 14             	mov    %edx,0x14(%ebp)
  80137b:	8b 00                	mov    (%eax),%eax
  80137d:	89 45 d0             	mov    %eax,-0x30(%ebp)
  801380:	85 c0                	test   %eax,%eax
  801382:	75 07                	jne    80138b <vprintfmt+0x19a>
				p = "(null)";
  801384:	c7 45 d0 e4 1e 80 00 	movl   $0x801ee4,-0x30(%ebp)
			if (width > 0 && padc != '-')
  80138b:	85 db                	test   %ebx,%ebx
  80138d:	7e 42                	jle    8013d1 <vprintfmt+0x1e0>
  80138f:	80 7d dc 2d          	cmpb   $0x2d,-0x24(%ebp)
  801393:	74 3c                	je     8013d1 <vprintfmt+0x1e0>
				for (width -= strnlen(p, precision); width > 0; width--)
  801395:	83 ec 08             	sub    $0x8,%esp
  801398:	51                   	push   %ecx
  801399:	ff 75 d0             	pushl  -0x30(%ebp)
  80139c:	e8 6f 02 00 00       	call   801610 <strnlen>
  8013a1:	29 c3                	sub    %eax,%ebx
  8013a3:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8013a6:	83 c4 10             	add    $0x10,%esp
  8013a9:	85 db                	test   %ebx,%ebx
  8013ab:	7e 24                	jle    8013d1 <vprintfmt+0x1e0>
					putch(padc, putdat);
  8013ad:	0f be 5d dc          	movsbl -0x24(%ebp),%ebx
  8013b1:	89 75 dc             	mov    %esi,-0x24(%ebp)
  8013b4:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  8013b7:	83 ec 08             	sub    $0x8,%esp
  8013ba:	57                   	push   %edi
  8013bb:	53                   	push   %ebx
  8013bc:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8013bf:	4e                   	dec    %esi
  8013c0:	83 c4 10             	add    $0x10,%esp
  8013c3:	85 f6                	test   %esi,%esi
  8013c5:	7f f0                	jg     8013b7 <vprintfmt+0x1c6>
  8013c7:	8b 75 dc             	mov    -0x24(%ebp),%esi
  8013ca:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8013d1:	8b 55 d0             	mov    -0x30(%ebp),%edx
  8013d4:	0f be 02             	movsbl (%edx),%eax
  8013d7:	85 c0                	test   %eax,%eax
  8013d9:	75 47                	jne    801422 <vprintfmt+0x231>
  8013db:	eb 37                	jmp    801414 <vprintfmt+0x223>
				if (altflag && (ch < ' ' || ch > '~'))
  8013dd:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8013e1:	74 16                	je     8013f9 <vprintfmt+0x208>
  8013e3:	8d 50 e0             	lea    -0x20(%eax),%edx
  8013e6:	83 fa 5e             	cmp    $0x5e,%edx
  8013e9:	76 0e                	jbe    8013f9 <vprintfmt+0x208>
					putch('?', putdat);
  8013eb:	83 ec 08             	sub    $0x8,%esp
  8013ee:	57                   	push   %edi
  8013ef:	6a 3f                	push   $0x3f
  8013f1:	ff 55 08             	call   *0x8(%ebp)
  8013f4:	83 c4 10             	add    $0x10,%esp
  8013f7:	eb 0b                	jmp    801404 <vprintfmt+0x213>
				else
					putch(ch, putdat);
  8013f9:	83 ec 08             	sub    $0x8,%esp
  8013fc:	57                   	push   %edi
  8013fd:	50                   	push   %eax
  8013fe:	ff 55 08             	call   *0x8(%ebp)
  801401:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  801404:	ff 4d e4             	decl   -0x1c(%ebp)
  801407:	0f be 03             	movsbl (%ebx),%eax
  80140a:	85 c0                	test   %eax,%eax
  80140c:	74 03                	je     801411 <vprintfmt+0x220>
  80140e:	43                   	inc    %ebx
  80140f:	eb 1b                	jmp    80142c <vprintfmt+0x23b>
  801411:	8b 75 dc             	mov    -0x24(%ebp),%esi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  801414:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  801418:	7f 1e                	jg     801438 <vprintfmt+0x247>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80141a:	8b 75 d8             	mov    -0x28(%ebp),%esi
  80141d:	e9 f3 fd ff ff       	jmp    801215 <vprintfmt+0x24>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  801422:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  801425:	43                   	inc    %ebx
  801426:	89 75 dc             	mov    %esi,-0x24(%ebp)
  801429:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  80142c:	85 f6                	test   %esi,%esi
  80142e:	78 ad                	js     8013dd <vprintfmt+0x1ec>
  801430:	4e                   	dec    %esi
  801431:	79 aa                	jns    8013dd <vprintfmt+0x1ec>
  801433:	8b 75 dc             	mov    -0x24(%ebp),%esi
  801436:	eb dc                	jmp    801414 <vprintfmt+0x223>
  801438:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80143b:	83 ec 08             	sub    $0x8,%esp
  80143e:	57                   	push   %edi
  80143f:	6a 20                	push   $0x20
  801441:	ff 55 08             	call   *0x8(%ebp)
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  801444:	4b                   	dec    %ebx
  801445:	83 c4 10             	add    $0x10,%esp
  801448:	85 db                	test   %ebx,%ebx
  80144a:	7f ef                	jg     80143b <vprintfmt+0x24a>
  80144c:	e9 c4 fd ff ff       	jmp    801215 <vprintfmt+0x24>
  801451:	89 5d d8             	mov    %ebx,-0x28(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  801454:	89 ca                	mov    %ecx,%edx
  801456:	8d 45 14             	lea    0x14(%ebp),%eax
  801459:	e8 2a fd ff ff       	call   801188 <getint>
  80145e:	89 c3                	mov    %eax,%ebx
  801460:	89 d6                	mov    %edx,%esi
			if ((long long) num < 0) {
  801462:	85 d2                	test   %edx,%edx
  801464:	78 0a                	js     801470 <vprintfmt+0x27f>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  801466:	b8 0a 00 00 00       	mov    $0xa,%eax
  80146b:	e9 b0 00 00 00       	jmp    801520 <vprintfmt+0x32f>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  801470:	83 ec 08             	sub    $0x8,%esp
  801473:	57                   	push   %edi
  801474:	6a 2d                	push   $0x2d
  801476:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  801479:	f7 db                	neg    %ebx
  80147b:	83 d6 00             	adc    $0x0,%esi
  80147e:	f7 de                	neg    %esi
  801480:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  801483:	b8 0a 00 00 00       	mov    $0xa,%eax
  801488:	e9 93 00 00 00       	jmp    801520 <vprintfmt+0x32f>
  80148d:	89 5d d8             	mov    %ebx,-0x28(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  801490:	89 ca                	mov    %ecx,%edx
  801492:	8d 45 14             	lea    0x14(%ebp),%eax
  801495:	e8 b4 fc ff ff       	call   80114e <getuint>
  80149a:	89 c3                	mov    %eax,%ebx
  80149c:	89 d6                	mov    %edx,%esi
			base = 10;
  80149e:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  8014a3:	eb 7b                	jmp    801520 <vprintfmt+0x32f>
  8014a5:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// (unsigned) octal
		case 'o':
            // (MIT 6.828, lab1, Ex.8)  my code : 
            num = getint(&ap, lflag);
  8014a8:	89 ca                	mov    %ecx,%edx
  8014aa:	8d 45 14             	lea    0x14(%ebp),%eax
  8014ad:	e8 d6 fc ff ff       	call   801188 <getint>
  8014b2:	89 c3                	mov    %eax,%ebx
  8014b4:	89 d6                	mov    %edx,%esi
            if ((long long) num < 0) {
  8014b6:	85 d2                	test   %edx,%edx
  8014b8:	78 07                	js     8014c1 <vprintfmt+0x2d0>
                putch('-', putdat);
                num = -(long long) num;
            }
            base = 8;
  8014ba:	b8 08 00 00 00       	mov    $0x8,%eax
  8014bf:	eb 5f                	jmp    801520 <vprintfmt+0x32f>
		// (unsigned) octal
		case 'o':
            // (MIT 6.828, lab1, Ex.8)  my code : 
            num = getint(&ap, lflag);
            if ((long long) num < 0) {
                putch('-', putdat);
  8014c1:	83 ec 08             	sub    $0x8,%esp
  8014c4:	57                   	push   %edi
  8014c5:	6a 2d                	push   $0x2d
  8014c7:	ff 55 08             	call   *0x8(%ebp)
                num = -(long long) num;
  8014ca:	f7 db                	neg    %ebx
  8014cc:	83 d6 00             	adc    $0x0,%esi
  8014cf:	f7 de                	neg    %esi
  8014d1:	83 c4 10             	add    $0x10,%esp
            }
            base = 8;
  8014d4:	b8 08 00 00 00       	mov    $0x8,%eax
  8014d9:	eb 45                	jmp    801520 <vprintfmt+0x32f>
  8014db:	89 5d d8             	mov    %ebx,-0x28(%ebp)
            goto number;

        // pointer
		case 'p':
			putch('0', putdat);
  8014de:	83 ec 08             	sub    $0x8,%esp
  8014e1:	57                   	push   %edi
  8014e2:	6a 30                	push   $0x30
  8014e4:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  8014e7:	83 c4 08             	add    $0x8,%esp
  8014ea:	57                   	push   %edi
  8014eb:	6a 78                	push   $0x78
  8014ed:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8014f0:	8b 45 14             	mov    0x14(%ebp),%eax
  8014f3:	8d 50 04             	lea    0x4(%eax),%edx
  8014f6:	89 55 14             	mov    %edx,0x14(%ebp)

        // pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8014f9:	8b 18                	mov    (%eax),%ebx
  8014fb:	be 00 00 00 00       	mov    $0x0,%esi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  801500:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  801503:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  801508:	eb 16                	jmp    801520 <vprintfmt+0x32f>
  80150a:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  80150d:	89 ca                	mov    %ecx,%edx
  80150f:	8d 45 14             	lea    0x14(%ebp),%eax
  801512:	e8 37 fc ff ff       	call   80114e <getuint>
  801517:	89 c3                	mov    %eax,%ebx
  801519:	89 d6                	mov    %edx,%esi
			base = 16;
  80151b:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  801520:	83 ec 0c             	sub    $0xc,%esp
  801523:	0f be 55 dc          	movsbl -0x24(%ebp),%edx
  801527:	52                   	push   %edx
  801528:	ff 75 e4             	pushl  -0x1c(%ebp)
  80152b:	50                   	push   %eax
  80152c:	56                   	push   %esi
  80152d:	53                   	push   %ebx
  80152e:	89 fa                	mov    %edi,%edx
  801530:	8b 45 08             	mov    0x8(%ebp),%eax
  801533:	e8 68 fb ff ff       	call   8010a0 <printnum>
			break;
  801538:	83 c4 20             	add    $0x20,%esp
  80153b:	8b 75 d8             	mov    -0x28(%ebp),%esi
  80153e:	e9 d2 fc ff ff       	jmp    801215 <vprintfmt+0x24>
  801543:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  801546:	83 ec 08             	sub    $0x8,%esp
  801549:	57                   	push   %edi
  80154a:	52                   	push   %edx
  80154b:	ff 55 08             	call   *0x8(%ebp)
			break;
  80154e:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801551:	8b 75 d8             	mov    -0x28(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  801554:	e9 bc fc ff ff       	jmp    801215 <vprintfmt+0x24>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  801559:	83 ec 08             	sub    $0x8,%esp
  80155c:	57                   	push   %edi
  80155d:	6a 25                	push   $0x25
  80155f:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  801562:	83 c4 10             	add    $0x10,%esp
  801565:	eb 02                	jmp    801569 <vprintfmt+0x378>
  801567:	89 c6                	mov    %eax,%esi
  801569:	8d 46 ff             	lea    -0x1(%esi),%eax
  80156c:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  801570:	75 f5                	jne    801567 <vprintfmt+0x376>
  801572:	e9 9e fc ff ff       	jmp    801215 <vprintfmt+0x24>
				/* do nothing */;
			break;
		}
	}
}
  801577:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80157a:	5b                   	pop    %ebx
  80157b:	5e                   	pop    %esi
  80157c:	5f                   	pop    %edi
  80157d:	c9                   	leave  
  80157e:	c3                   	ret    

0080157f <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80157f:	55                   	push   %ebp
  801580:	89 e5                	mov    %esp,%ebp
  801582:	83 ec 18             	sub    $0x18,%esp
  801585:	8b 45 08             	mov    0x8(%ebp),%eax
  801588:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80158b:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80158e:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  801592:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  801595:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80159c:	85 c0                	test   %eax,%eax
  80159e:	74 26                	je     8015c6 <vsnprintf+0x47>
  8015a0:	85 d2                	test   %edx,%edx
  8015a2:	7e 29                	jle    8015cd <vsnprintf+0x4e>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8015a4:	ff 75 14             	pushl  0x14(%ebp)
  8015a7:	ff 75 10             	pushl  0x10(%ebp)
  8015aa:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8015ad:	50                   	push   %eax
  8015ae:	68 ba 11 80 00       	push   $0x8011ba
  8015b3:	e8 39 fc ff ff       	call   8011f1 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8015b8:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8015bb:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8015be:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8015c1:	83 c4 10             	add    $0x10,%esp
  8015c4:	eb 0c                	jmp    8015d2 <vsnprintf+0x53>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8015c6:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8015cb:	eb 05                	jmp    8015d2 <vsnprintf+0x53>
  8015cd:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8015d2:	c9                   	leave  
  8015d3:	c3                   	ret    

008015d4 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8015d4:	55                   	push   %ebp
  8015d5:	89 e5                	mov    %esp,%ebp
  8015d7:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8015da:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8015dd:	50                   	push   %eax
  8015de:	ff 75 10             	pushl  0x10(%ebp)
  8015e1:	ff 75 0c             	pushl  0xc(%ebp)
  8015e4:	ff 75 08             	pushl  0x8(%ebp)
  8015e7:	e8 93 ff ff ff       	call   80157f <vsnprintf>
	va_end(ap);

	return rc;
}
  8015ec:	c9                   	leave  
  8015ed:	c3                   	ret    
	...

008015f0 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8015f0:	55                   	push   %ebp
  8015f1:	89 e5                	mov    %esp,%ebp
  8015f3:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8015f6:	80 3a 00             	cmpb   $0x0,(%edx)
  8015f9:	74 0e                	je     801609 <strlen+0x19>
  8015fb:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  801600:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  801601:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  801605:	75 f9                	jne    801600 <strlen+0x10>
  801607:	eb 05                	jmp    80160e <strlen+0x1e>
  801609:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  80160e:	c9                   	leave  
  80160f:	c3                   	ret    

00801610 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  801610:	55                   	push   %ebp
  801611:	89 e5                	mov    %esp,%ebp
  801613:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801616:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801619:	85 d2                	test   %edx,%edx
  80161b:	74 17                	je     801634 <strnlen+0x24>
  80161d:	80 39 00             	cmpb   $0x0,(%ecx)
  801620:	74 19                	je     80163b <strnlen+0x2b>
  801622:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  801627:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801628:	39 d0                	cmp    %edx,%eax
  80162a:	74 14                	je     801640 <strnlen+0x30>
  80162c:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  801630:	75 f5                	jne    801627 <strnlen+0x17>
  801632:	eb 0c                	jmp    801640 <strnlen+0x30>
  801634:	b8 00 00 00 00       	mov    $0x0,%eax
  801639:	eb 05                	jmp    801640 <strnlen+0x30>
  80163b:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  801640:	c9                   	leave  
  801641:	c3                   	ret    

00801642 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  801642:	55                   	push   %ebp
  801643:	89 e5                	mov    %esp,%ebp
  801645:	53                   	push   %ebx
  801646:	8b 45 08             	mov    0x8(%ebp),%eax
  801649:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  80164c:	ba 00 00 00 00       	mov    $0x0,%edx
  801651:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  801654:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  801657:	42                   	inc    %edx
  801658:	84 c9                	test   %cl,%cl
  80165a:	75 f5                	jne    801651 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  80165c:	5b                   	pop    %ebx
  80165d:	c9                   	leave  
  80165e:	c3                   	ret    

0080165f <strcat>:

char *
strcat(char *dst, const char *src)
{
  80165f:	55                   	push   %ebp
  801660:	89 e5                	mov    %esp,%ebp
  801662:	53                   	push   %ebx
  801663:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  801666:	53                   	push   %ebx
  801667:	e8 84 ff ff ff       	call   8015f0 <strlen>
  80166c:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  80166f:	ff 75 0c             	pushl  0xc(%ebp)
  801672:	8d 04 03             	lea    (%ebx,%eax,1),%eax
  801675:	50                   	push   %eax
  801676:	e8 c7 ff ff ff       	call   801642 <strcpy>
	return dst;
}
  80167b:	89 d8                	mov    %ebx,%eax
  80167d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801680:	c9                   	leave  
  801681:	c3                   	ret    

00801682 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  801682:	55                   	push   %ebp
  801683:	89 e5                	mov    %esp,%ebp
  801685:	56                   	push   %esi
  801686:	53                   	push   %ebx
  801687:	8b 45 08             	mov    0x8(%ebp),%eax
  80168a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80168d:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801690:	85 f6                	test   %esi,%esi
  801692:	74 15                	je     8016a9 <strncpy+0x27>
  801694:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
  801699:	8a 1a                	mov    (%edx),%bl
  80169b:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80169e:	80 3a 01             	cmpb   $0x1,(%edx)
  8016a1:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8016a4:	41                   	inc    %ecx
  8016a5:	39 ce                	cmp    %ecx,%esi
  8016a7:	77 f0                	ja     801699 <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8016a9:	5b                   	pop    %ebx
  8016aa:	5e                   	pop    %esi
  8016ab:	c9                   	leave  
  8016ac:	c3                   	ret    

008016ad <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8016ad:	55                   	push   %ebp
  8016ae:	89 e5                	mov    %esp,%ebp
  8016b0:	57                   	push   %edi
  8016b1:	56                   	push   %esi
  8016b2:	53                   	push   %ebx
  8016b3:	8b 7d 08             	mov    0x8(%ebp),%edi
  8016b6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8016b9:	8b 75 10             	mov    0x10(%ebp),%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8016bc:	85 f6                	test   %esi,%esi
  8016be:	74 32                	je     8016f2 <strlcpy+0x45>
		while (--size > 0 && *src != '\0')
  8016c0:	83 fe 01             	cmp    $0x1,%esi
  8016c3:	74 22                	je     8016e7 <strlcpy+0x3a>
  8016c5:	8a 0b                	mov    (%ebx),%cl
  8016c7:	84 c9                	test   %cl,%cl
  8016c9:	74 20                	je     8016eb <strlcpy+0x3e>
  8016cb:	89 f8                	mov    %edi,%eax
  8016cd:	ba 00 00 00 00       	mov    $0x0,%edx
	}
	return ret;
}

size_t
strlcpy(char *dst, const char *src, size_t size)
  8016d2:	83 ee 02             	sub    $0x2,%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8016d5:	88 08                	mov    %cl,(%eax)
  8016d7:	40                   	inc    %eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8016d8:	39 f2                	cmp    %esi,%edx
  8016da:	74 11                	je     8016ed <strlcpy+0x40>
  8016dc:	8a 4c 13 01          	mov    0x1(%ebx,%edx,1),%cl
  8016e0:	42                   	inc    %edx
  8016e1:	84 c9                	test   %cl,%cl
  8016e3:	75 f0                	jne    8016d5 <strlcpy+0x28>
  8016e5:	eb 06                	jmp    8016ed <strlcpy+0x40>
  8016e7:	89 f8                	mov    %edi,%eax
  8016e9:	eb 02                	jmp    8016ed <strlcpy+0x40>
  8016eb:	89 f8                	mov    %edi,%eax
			*dst++ = *src++;
		*dst = '\0';
  8016ed:	c6 00 00             	movb   $0x0,(%eax)
  8016f0:	eb 02                	jmp    8016f4 <strlcpy+0x47>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8016f2:	89 f8                	mov    %edi,%eax
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
		*dst = '\0';
	}
	return dst - dst_in;
  8016f4:	29 f8                	sub    %edi,%eax
}
  8016f6:	5b                   	pop    %ebx
  8016f7:	5e                   	pop    %esi
  8016f8:	5f                   	pop    %edi
  8016f9:	c9                   	leave  
  8016fa:	c3                   	ret    

008016fb <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8016fb:	55                   	push   %ebp
  8016fc:	89 e5                	mov    %esp,%ebp
  8016fe:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801701:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  801704:	8a 01                	mov    (%ecx),%al
  801706:	84 c0                	test   %al,%al
  801708:	74 10                	je     80171a <strcmp+0x1f>
  80170a:	3a 02                	cmp    (%edx),%al
  80170c:	75 0c                	jne    80171a <strcmp+0x1f>
		p++, q++;
  80170e:	41                   	inc    %ecx
  80170f:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  801710:	8a 01                	mov    (%ecx),%al
  801712:	84 c0                	test   %al,%al
  801714:	74 04                	je     80171a <strcmp+0x1f>
  801716:	3a 02                	cmp    (%edx),%al
  801718:	74 f4                	je     80170e <strcmp+0x13>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  80171a:	0f b6 c0             	movzbl %al,%eax
  80171d:	0f b6 12             	movzbl (%edx),%edx
  801720:	29 d0                	sub    %edx,%eax
}
  801722:	c9                   	leave  
  801723:	c3                   	ret    

00801724 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  801724:	55                   	push   %ebp
  801725:	89 e5                	mov    %esp,%ebp
  801727:	53                   	push   %ebx
  801728:	8b 55 08             	mov    0x8(%ebp),%edx
  80172b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80172e:	8b 45 10             	mov    0x10(%ebp),%eax
	while (n > 0 && *p && *p == *q)
  801731:	85 c0                	test   %eax,%eax
  801733:	74 1b                	je     801750 <strncmp+0x2c>
  801735:	8a 1a                	mov    (%edx),%bl
  801737:	84 db                	test   %bl,%bl
  801739:	74 24                	je     80175f <strncmp+0x3b>
  80173b:	3a 19                	cmp    (%ecx),%bl
  80173d:	75 20                	jne    80175f <strncmp+0x3b>
  80173f:	48                   	dec    %eax
  801740:	74 15                	je     801757 <strncmp+0x33>
		n--, p++, q++;
  801742:	42                   	inc    %edx
  801743:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  801744:	8a 1a                	mov    (%edx),%bl
  801746:	84 db                	test   %bl,%bl
  801748:	74 15                	je     80175f <strncmp+0x3b>
  80174a:	3a 19                	cmp    (%ecx),%bl
  80174c:	74 f1                	je     80173f <strncmp+0x1b>
  80174e:	eb 0f                	jmp    80175f <strncmp+0x3b>
		n--, p++, q++;
	if (n == 0)
		return 0;
  801750:	b8 00 00 00 00       	mov    $0x0,%eax
  801755:	eb 05                	jmp    80175c <strncmp+0x38>
  801757:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  80175c:	5b                   	pop    %ebx
  80175d:	c9                   	leave  
  80175e:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80175f:	0f b6 02             	movzbl (%edx),%eax
  801762:	0f b6 11             	movzbl (%ecx),%edx
  801765:	29 d0                	sub    %edx,%eax
  801767:	eb f3                	jmp    80175c <strncmp+0x38>

00801769 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  801769:	55                   	push   %ebp
  80176a:	89 e5                	mov    %esp,%ebp
  80176c:	8b 45 08             	mov    0x8(%ebp),%eax
  80176f:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  801772:	8a 10                	mov    (%eax),%dl
  801774:	84 d2                	test   %dl,%dl
  801776:	74 18                	je     801790 <strchr+0x27>
		if (*s == c)
  801778:	38 ca                	cmp    %cl,%dl
  80177a:	75 06                	jne    801782 <strchr+0x19>
  80177c:	eb 17                	jmp    801795 <strchr+0x2c>
  80177e:	38 ca                	cmp    %cl,%dl
  801780:	74 13                	je     801795 <strchr+0x2c>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  801782:	40                   	inc    %eax
  801783:	8a 10                	mov    (%eax),%dl
  801785:	84 d2                	test   %dl,%dl
  801787:	75 f5                	jne    80177e <strchr+0x15>
		if (*s == c)
			return (char *) s;
	return 0;
  801789:	b8 00 00 00 00       	mov    $0x0,%eax
  80178e:	eb 05                	jmp    801795 <strchr+0x2c>
  801790:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801795:	c9                   	leave  
  801796:	c3                   	ret    

00801797 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  801797:	55                   	push   %ebp
  801798:	89 e5                	mov    %esp,%ebp
  80179a:	8b 45 08             	mov    0x8(%ebp),%eax
  80179d:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  8017a0:	8a 10                	mov    (%eax),%dl
  8017a2:	84 d2                	test   %dl,%dl
  8017a4:	74 11                	je     8017b7 <strfind+0x20>
		if (*s == c)
  8017a6:	38 ca                	cmp    %cl,%dl
  8017a8:	75 06                	jne    8017b0 <strfind+0x19>
  8017aa:	eb 0b                	jmp    8017b7 <strfind+0x20>
  8017ac:	38 ca                	cmp    %cl,%dl
  8017ae:	74 07                	je     8017b7 <strfind+0x20>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  8017b0:	40                   	inc    %eax
  8017b1:	8a 10                	mov    (%eax),%dl
  8017b3:	84 d2                	test   %dl,%dl
  8017b5:	75 f5                	jne    8017ac <strfind+0x15>
		if (*s == c)
			break;
	return (char *) s;
}
  8017b7:	c9                   	leave  
  8017b8:	c3                   	ret    

008017b9 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8017b9:	55                   	push   %ebp
  8017ba:	89 e5                	mov    %esp,%ebp
  8017bc:	57                   	push   %edi
  8017bd:	56                   	push   %esi
  8017be:	53                   	push   %ebx
  8017bf:	8b 7d 08             	mov    0x8(%ebp),%edi
  8017c2:	8b 45 0c             	mov    0xc(%ebp),%eax
  8017c5:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8017c8:	85 c9                	test   %ecx,%ecx
  8017ca:	74 30                	je     8017fc <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8017cc:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8017d2:	75 25                	jne    8017f9 <memset+0x40>
  8017d4:	f6 c1 03             	test   $0x3,%cl
  8017d7:	75 20                	jne    8017f9 <memset+0x40>
		c &= 0xFF;
  8017d9:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8017dc:	89 d3                	mov    %edx,%ebx
  8017de:	c1 e3 08             	shl    $0x8,%ebx
  8017e1:	89 d6                	mov    %edx,%esi
  8017e3:	c1 e6 18             	shl    $0x18,%esi
  8017e6:	89 d0                	mov    %edx,%eax
  8017e8:	c1 e0 10             	shl    $0x10,%eax
  8017eb:	09 f0                	or     %esi,%eax
  8017ed:	09 d0                	or     %edx,%eax
  8017ef:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  8017f1:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  8017f4:	fc                   	cld    
  8017f5:	f3 ab                	rep stos %eax,%es:(%edi)
  8017f7:	eb 03                	jmp    8017fc <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8017f9:	fc                   	cld    
  8017fa:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8017fc:	89 f8                	mov    %edi,%eax
  8017fe:	5b                   	pop    %ebx
  8017ff:	5e                   	pop    %esi
  801800:	5f                   	pop    %edi
  801801:	c9                   	leave  
  801802:	c3                   	ret    

00801803 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  801803:	55                   	push   %ebp
  801804:	89 e5                	mov    %esp,%ebp
  801806:	57                   	push   %edi
  801807:	56                   	push   %esi
  801808:	8b 45 08             	mov    0x8(%ebp),%eax
  80180b:	8b 75 0c             	mov    0xc(%ebp),%esi
  80180e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  801811:	39 c6                	cmp    %eax,%esi
  801813:	73 34                	jae    801849 <memmove+0x46>
  801815:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  801818:	39 d0                	cmp    %edx,%eax
  80181a:	73 2d                	jae    801849 <memmove+0x46>
		s += n;
		d += n;
  80181c:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80181f:	f6 c2 03             	test   $0x3,%dl
  801822:	75 1b                	jne    80183f <memmove+0x3c>
  801824:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80182a:	75 13                	jne    80183f <memmove+0x3c>
  80182c:	f6 c1 03             	test   $0x3,%cl
  80182f:	75 0e                	jne    80183f <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  801831:	83 ef 04             	sub    $0x4,%edi
  801834:	8d 72 fc             	lea    -0x4(%edx),%esi
  801837:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  80183a:	fd                   	std    
  80183b:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80183d:	eb 07                	jmp    801846 <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  80183f:	4f                   	dec    %edi
  801840:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  801843:	fd                   	std    
  801844:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  801846:	fc                   	cld    
  801847:	eb 20                	jmp    801869 <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801849:	f7 c6 03 00 00 00    	test   $0x3,%esi
  80184f:	75 13                	jne    801864 <memmove+0x61>
  801851:	a8 03                	test   $0x3,%al
  801853:	75 0f                	jne    801864 <memmove+0x61>
  801855:	f6 c1 03             	test   $0x3,%cl
  801858:	75 0a                	jne    801864 <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  80185a:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  80185d:	89 c7                	mov    %eax,%edi
  80185f:	fc                   	cld    
  801860:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801862:	eb 05                	jmp    801869 <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  801864:	89 c7                	mov    %eax,%edi
  801866:	fc                   	cld    
  801867:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  801869:	5e                   	pop    %esi
  80186a:	5f                   	pop    %edi
  80186b:	c9                   	leave  
  80186c:	c3                   	ret    

0080186d <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  80186d:	55                   	push   %ebp
  80186e:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  801870:	ff 75 10             	pushl  0x10(%ebp)
  801873:	ff 75 0c             	pushl  0xc(%ebp)
  801876:	ff 75 08             	pushl  0x8(%ebp)
  801879:	e8 85 ff ff ff       	call   801803 <memmove>
}
  80187e:	c9                   	leave  
  80187f:	c3                   	ret    

00801880 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  801880:	55                   	push   %ebp
  801881:	89 e5                	mov    %esp,%ebp
  801883:	57                   	push   %edi
  801884:	56                   	push   %esi
  801885:	53                   	push   %ebx
  801886:	8b 5d 08             	mov    0x8(%ebp),%ebx
  801889:	8b 75 0c             	mov    0xc(%ebp),%esi
  80188c:	8b 7d 10             	mov    0x10(%ebp),%edi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  80188f:	85 ff                	test   %edi,%edi
  801891:	74 32                	je     8018c5 <memcmp+0x45>
		if (*s1 != *s2)
  801893:	8a 03                	mov    (%ebx),%al
  801895:	8a 0e                	mov    (%esi),%cl
  801897:	38 c8                	cmp    %cl,%al
  801899:	74 19                	je     8018b4 <memcmp+0x34>
  80189b:	eb 0d                	jmp    8018aa <memcmp+0x2a>
  80189d:	8a 44 13 01          	mov    0x1(%ebx,%edx,1),%al
  8018a1:	8a 4c 16 01          	mov    0x1(%esi,%edx,1),%cl
  8018a5:	42                   	inc    %edx
  8018a6:	38 c8                	cmp    %cl,%al
  8018a8:	74 10                	je     8018ba <memcmp+0x3a>
			return (int) *s1 - (int) *s2;
  8018aa:	0f b6 c0             	movzbl %al,%eax
  8018ad:	0f b6 c9             	movzbl %cl,%ecx
  8018b0:	29 c8                	sub    %ecx,%eax
  8018b2:	eb 16                	jmp    8018ca <memcmp+0x4a>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8018b4:	4f                   	dec    %edi
  8018b5:	ba 00 00 00 00       	mov    $0x0,%edx
  8018ba:	39 fa                	cmp    %edi,%edx
  8018bc:	75 df                	jne    80189d <memcmp+0x1d>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  8018be:	b8 00 00 00 00       	mov    $0x0,%eax
  8018c3:	eb 05                	jmp    8018ca <memcmp+0x4a>
  8018c5:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8018ca:	5b                   	pop    %ebx
  8018cb:	5e                   	pop    %esi
  8018cc:	5f                   	pop    %edi
  8018cd:	c9                   	leave  
  8018ce:	c3                   	ret    

008018cf <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8018cf:	55                   	push   %ebp
  8018d0:	89 e5                	mov    %esp,%ebp
  8018d2:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  8018d5:	89 c2                	mov    %eax,%edx
  8018d7:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  8018da:	39 d0                	cmp    %edx,%eax
  8018dc:	73 12                	jae    8018f0 <memfind+0x21>
		if (*(const unsigned char *) s == (unsigned char) c)
  8018de:	8a 4d 0c             	mov    0xc(%ebp),%cl
  8018e1:	38 08                	cmp    %cl,(%eax)
  8018e3:	75 06                	jne    8018eb <memfind+0x1c>
  8018e5:	eb 09                	jmp    8018f0 <memfind+0x21>
  8018e7:	38 08                	cmp    %cl,(%eax)
  8018e9:	74 05                	je     8018f0 <memfind+0x21>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8018eb:	40                   	inc    %eax
  8018ec:	39 c2                	cmp    %eax,%edx
  8018ee:	77 f7                	ja     8018e7 <memfind+0x18>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  8018f0:	c9                   	leave  
  8018f1:	c3                   	ret    

008018f2 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  8018f2:	55                   	push   %ebp
  8018f3:	89 e5                	mov    %esp,%ebp
  8018f5:	57                   	push   %edi
  8018f6:	56                   	push   %esi
  8018f7:	53                   	push   %ebx
  8018f8:	8b 55 08             	mov    0x8(%ebp),%edx
  8018fb:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8018fe:	eb 01                	jmp    801901 <strtol+0xf>
		s++;
  801900:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801901:	8a 02                	mov    (%edx),%al
  801903:	3c 20                	cmp    $0x20,%al
  801905:	74 f9                	je     801900 <strtol+0xe>
  801907:	3c 09                	cmp    $0x9,%al
  801909:	74 f5                	je     801900 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  80190b:	3c 2b                	cmp    $0x2b,%al
  80190d:	75 08                	jne    801917 <strtol+0x25>
		s++;
  80190f:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  801910:	bf 00 00 00 00       	mov    $0x0,%edi
  801915:	eb 13                	jmp    80192a <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  801917:	3c 2d                	cmp    $0x2d,%al
  801919:	75 0a                	jne    801925 <strtol+0x33>
		s++, neg = 1;
  80191b:	8d 52 01             	lea    0x1(%edx),%edx
  80191e:	bf 01 00 00 00       	mov    $0x1,%edi
  801923:	eb 05                	jmp    80192a <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  801925:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  80192a:	85 db                	test   %ebx,%ebx
  80192c:	74 05                	je     801933 <strtol+0x41>
  80192e:	83 fb 10             	cmp    $0x10,%ebx
  801931:	75 28                	jne    80195b <strtol+0x69>
  801933:	8a 02                	mov    (%edx),%al
  801935:	3c 30                	cmp    $0x30,%al
  801937:	75 10                	jne    801949 <strtol+0x57>
  801939:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  80193d:	75 0a                	jne    801949 <strtol+0x57>
		s += 2, base = 16;
  80193f:	83 c2 02             	add    $0x2,%edx
  801942:	bb 10 00 00 00       	mov    $0x10,%ebx
  801947:	eb 12                	jmp    80195b <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  801949:	85 db                	test   %ebx,%ebx
  80194b:	75 0e                	jne    80195b <strtol+0x69>
  80194d:	3c 30                	cmp    $0x30,%al
  80194f:	75 05                	jne    801956 <strtol+0x64>
		s++, base = 8;
  801951:	42                   	inc    %edx
  801952:	b3 08                	mov    $0x8,%bl
  801954:	eb 05                	jmp    80195b <strtol+0x69>
	else if (base == 0)
		base = 10;
  801956:	bb 0a 00 00 00       	mov    $0xa,%ebx
  80195b:	b8 00 00 00 00       	mov    $0x0,%eax
  801960:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  801962:	8a 0a                	mov    (%edx),%cl
  801964:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  801967:	80 fb 09             	cmp    $0x9,%bl
  80196a:	77 08                	ja     801974 <strtol+0x82>
			dig = *s - '0';
  80196c:	0f be c9             	movsbl %cl,%ecx
  80196f:	83 e9 30             	sub    $0x30,%ecx
  801972:	eb 1e                	jmp    801992 <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  801974:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  801977:	80 fb 19             	cmp    $0x19,%bl
  80197a:	77 08                	ja     801984 <strtol+0x92>
			dig = *s - 'a' + 10;
  80197c:	0f be c9             	movsbl %cl,%ecx
  80197f:	83 e9 57             	sub    $0x57,%ecx
  801982:	eb 0e                	jmp    801992 <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  801984:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  801987:	80 fb 19             	cmp    $0x19,%bl
  80198a:	77 13                	ja     80199f <strtol+0xad>
			dig = *s - 'A' + 10;
  80198c:	0f be c9             	movsbl %cl,%ecx
  80198f:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  801992:	39 f1                	cmp    %esi,%ecx
  801994:	7d 0d                	jge    8019a3 <strtol+0xb1>
			break;
		s++, val = (val * base) + dig;
  801996:	42                   	inc    %edx
  801997:	0f af c6             	imul   %esi,%eax
  80199a:	8d 04 01             	lea    (%ecx,%eax,1),%eax
		// we don't properly detect overflow!
	}
  80199d:	eb c3                	jmp    801962 <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  80199f:	89 c1                	mov    %eax,%ecx
  8019a1:	eb 02                	jmp    8019a5 <strtol+0xb3>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  8019a3:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  8019a5:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8019a9:	74 05                	je     8019b0 <strtol+0xbe>
		*endptr = (char *) s;
  8019ab:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8019ae:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  8019b0:	85 ff                	test   %edi,%edi
  8019b2:	74 04                	je     8019b8 <strtol+0xc6>
  8019b4:	89 c8                	mov    %ecx,%eax
  8019b6:	f7 d8                	neg    %eax
}
  8019b8:	5b                   	pop    %ebx
  8019b9:	5e                   	pop    %esi
  8019ba:	5f                   	pop    %edi
  8019bb:	c9                   	leave  
  8019bc:	c3                   	ret    
  8019bd:	00 00                	add    %al,(%eax)
	...

008019c0 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8019c0:	55                   	push   %ebp
  8019c1:	89 e5                	mov    %esp,%ebp
  8019c3:	56                   	push   %esi
  8019c4:	53                   	push   %ebx
  8019c5:	8b 75 08             	mov    0x8(%ebp),%esi
  8019c8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8019cb:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// cprintf("0x%x 0x%x 0x%x\n", (uint32_t)from_env_store, (uint32_t)pg, (uint32_t)perm_store);
	int r;
	if (pg != NULL) {
  8019ce:	85 c0                	test   %eax,%eax
  8019d0:	74 0e                	je     8019e0 <ipc_recv+0x20>
		r = sys_ipc_recv(pg);
  8019d2:	83 ec 0c             	sub    $0xc,%esp
  8019d5:	50                   	push   %eax
  8019d6:	e8 e0 e8 ff ff       	call   8002bb <sys_ipc_recv>
  8019db:	83 c4 10             	add    $0x10,%esp
  8019de:	eb 10                	jmp    8019f0 <ipc_recv+0x30>
	} else {
		r = sys_ipc_recv((void *)UTOP);
  8019e0:	83 ec 0c             	sub    $0xc,%esp
  8019e3:	68 00 00 c0 ee       	push   $0xeec00000
  8019e8:	e8 ce e8 ff ff       	call   8002bb <sys_ipc_recv>
  8019ed:	83 c4 10             	add    $0x10,%esp
	}

	if (r == 0) {
  8019f0:	85 c0                	test   %eax,%eax
  8019f2:	75 26                	jne    801a1a <ipc_recv+0x5a>
		if (from_env_store != NULL) *from_env_store = thisenv->env_ipc_from;
  8019f4:	85 f6                	test   %esi,%esi
  8019f6:	74 0a                	je     801a02 <ipc_recv+0x42>
  8019f8:	a1 04 40 80 00       	mov    0x804004,%eax
  8019fd:	8b 40 74             	mov    0x74(%eax),%eax
  801a00:	89 06                	mov    %eax,(%esi)
		if (perm_store != NULL) *perm_store = thisenv->env_ipc_perm;
  801a02:	85 db                	test   %ebx,%ebx
  801a04:	74 0a                	je     801a10 <ipc_recv+0x50>
  801a06:	a1 04 40 80 00       	mov    0x804004,%eax
  801a0b:	8b 40 78             	mov    0x78(%eax),%eax
  801a0e:	89 03                	mov    %eax,(%ebx)
		return thisenv->env_ipc_value;
  801a10:	a1 04 40 80 00       	mov    0x804004,%eax
  801a15:	8b 40 70             	mov    0x70(%eax),%eax
  801a18:	eb 14                	jmp    801a2e <ipc_recv+0x6e>
	} else {
		// fails;
		if (from_env_store != NULL) *from_env_store = 0;
  801a1a:	85 f6                	test   %esi,%esi
  801a1c:	74 06                	je     801a24 <ipc_recv+0x64>
  801a1e:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		if (perm_store != NULL) *perm_store = 0;
  801a24:	85 db                	test   %ebx,%ebx
  801a26:	74 06                	je     801a2e <ipc_recv+0x6e>
  801a28:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
		return r;
	}
}
  801a2e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a31:	5b                   	pop    %ebx
  801a32:	5e                   	pop    %esi
  801a33:	c9                   	leave  
  801a34:	c3                   	ret    

00801a35 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801a35:	55                   	push   %ebp
  801a36:	89 e5                	mov    %esp,%ebp
  801a38:	57                   	push   %edi
  801a39:	56                   	push   %esi
  801a3a:	53                   	push   %ebx
  801a3b:	83 ec 0c             	sub    $0xc,%esp
  801a3e:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801a41:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801a44:	8b 75 14             	mov    0x14(%ebp),%esi
	// LAB 4: Your code here.
	// int sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
	int r;
	if (pg == NULL) pg = (void *)UTOP;
  801a47:	85 db                	test   %ebx,%ebx
  801a49:	75 25                	jne    801a70 <ipc_send+0x3b>
  801a4b:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
  801a50:	eb 1e                	jmp    801a70 <ipc_send+0x3b>
	
	while ((r = sys_ipc_try_send(to_env, val, pg, perm)) != 0) {
		if (r == -E_IPC_NOT_RECV) {
  801a52:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801a55:	75 07                	jne    801a5e <ipc_send+0x29>
			// cprintf("Try Again and Again....\n");
			sys_yield();
  801a57:	e8 3d e7 ff ff       	call   800199 <sys_yield>
  801a5c:	eb 12                	jmp    801a70 <ipc_send+0x3b>
		} else {
			panic("ipc_send error %e\n", r);
  801a5e:	50                   	push   %eax
  801a5f:	68 e0 21 80 00       	push   $0x8021e0
  801a64:	6a 43                	push   $0x43
  801a66:	68 f3 21 80 00       	push   $0x8021f3
  801a6b:	e8 44 f5 ff ff       	call   800fb4 <_panic>
	// LAB 4: Your code here.
	// int sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
	int r;
	if (pg == NULL) pg = (void *)UTOP;
	
	while ((r = sys_ipc_try_send(to_env, val, pg, perm)) != 0) {
  801a70:	56                   	push   %esi
  801a71:	53                   	push   %ebx
  801a72:	57                   	push   %edi
  801a73:	ff 75 08             	pushl  0x8(%ebp)
  801a76:	e8 1b e8 ff ff       	call   800296 <sys_ipc_try_send>
  801a7b:	83 c4 10             	add    $0x10,%esp
  801a7e:	85 c0                	test   %eax,%eax
  801a80:	75 d0                	jne    801a52 <ipc_send+0x1d>
		} else {
			panic("ipc_send error %e\n", r);
		}
	}
	return;
}
  801a82:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801a85:	5b                   	pop    %ebx
  801a86:	5e                   	pop    %esi
  801a87:	5f                   	pop    %edi
  801a88:	c9                   	leave  
  801a89:	c3                   	ret    

00801a8a <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801a8a:	55                   	push   %ebp
  801a8b:	89 e5                	mov    %esp,%ebp
  801a8d:	53                   	push   %ebx
  801a8e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	for (i = 0; i < NENV; i++)
		if (envs[i].env_type == type)
  801a91:	39 1d 50 00 c0 ee    	cmp    %ebx,0xeec00050
  801a97:	74 22                	je     801abb <ipc_find_env+0x31>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801a99:	b8 01 00 00 00       	mov    $0x1,%eax
		if (envs[i].env_type == type)
  801a9e:	8d 0c 85 00 00 00 00 	lea    0x0(,%eax,4),%ecx
  801aa5:	89 c2                	mov    %eax,%edx
  801aa7:	c1 e2 07             	shl    $0x7,%edx
  801aaa:	29 ca                	sub    %ecx,%edx
  801aac:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801ab2:	8b 52 50             	mov    0x50(%edx),%edx
  801ab5:	39 da                	cmp    %ebx,%edx
  801ab7:	75 1d                	jne    801ad6 <ipc_find_env+0x4c>
  801ab9:	eb 05                	jmp    801ac0 <ipc_find_env+0x36>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801abb:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
			return envs[i].env_id;
  801ac0:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  801ac7:	c1 e0 07             	shl    $0x7,%eax
  801aca:	29 d0                	sub    %edx,%eax
  801acc:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  801ad1:	8b 40 40             	mov    0x40(%eax),%eax
  801ad4:	eb 0c                	jmp    801ae2 <ipc_find_env+0x58>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801ad6:	40                   	inc    %eax
  801ad7:	3d 00 04 00 00       	cmp    $0x400,%eax
  801adc:	75 c0                	jne    801a9e <ipc_find_env+0x14>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801ade:	66 b8 00 00          	mov    $0x0,%ax
}
  801ae2:	5b                   	pop    %ebx
  801ae3:	c9                   	leave  
  801ae4:	c3                   	ret    
  801ae5:	00 00                	add    %al,(%eax)
	...

00801ae8 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801ae8:	55                   	push   %ebp
  801ae9:	89 e5                	mov    %esp,%ebp
  801aeb:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801aee:	89 c2                	mov    %eax,%edx
  801af0:	c1 ea 16             	shr    $0x16,%edx
  801af3:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801afa:	f6 c2 01             	test   $0x1,%dl
  801afd:	74 1e                	je     801b1d <pageref+0x35>
		return 0;
	pte = uvpt[PGNUM(v)];
  801aff:	c1 e8 0c             	shr    $0xc,%eax
  801b02:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  801b09:	a8 01                	test   $0x1,%al
  801b0b:	74 17                	je     801b24 <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801b0d:	c1 e8 0c             	shr    $0xc,%eax
  801b10:	66 8b 04 c5 04 00 00 	mov    -0x10fffffc(,%eax,8),%ax
  801b17:	ef 
  801b18:	0f b7 c0             	movzwl %ax,%eax
  801b1b:	eb 0c                	jmp    801b29 <pageref+0x41>
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
		return 0;
  801b1d:	b8 00 00 00 00       	mov    $0x0,%eax
  801b22:	eb 05                	jmp    801b29 <pageref+0x41>
	pte = uvpt[PGNUM(v)];
	if (!(pte & PTE_P))
		return 0;
  801b24:	b8 00 00 00 00       	mov    $0x0,%eax
	return pages[PGNUM(pte)].pp_ref;
}
  801b29:	c9                   	leave  
  801b2a:	c3                   	ret    
	...

00801b2c <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  801b2c:	55                   	push   %ebp
  801b2d:	89 e5                	mov    %esp,%ebp
  801b2f:	57                   	push   %edi
  801b30:	56                   	push   %esi
  801b31:	83 ec 10             	sub    $0x10,%esp
  801b34:	8b 7d 08             	mov    0x8(%ebp),%edi
  801b37:	8b 4d 10             	mov    0x10(%ebp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  801b3a:	89 7d f0             	mov    %edi,-0x10(%ebp)
  801b3d:	8b 75 0c             	mov    0xc(%ebp),%esi
  const DWunion dd = {.ll = d};
  801b40:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  801b43:	8b 45 14             	mov    0x14(%ebp),%eax
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  801b46:	85 c0                	test   %eax,%eax
  801b48:	75 2e                	jne    801b78 <__udivdi3+0x4c>
    {
      if (d0 > n1)
  801b4a:	39 f1                	cmp    %esi,%ecx
  801b4c:	77 5a                	ja     801ba8 <__udivdi3+0x7c>
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  801b4e:	85 c9                	test   %ecx,%ecx
  801b50:	75 0b                	jne    801b5d <__udivdi3+0x31>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  801b52:	b8 01 00 00 00       	mov    $0x1,%eax
  801b57:	31 d2                	xor    %edx,%edx
  801b59:	f7 f1                	div    %ecx
  801b5b:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  801b5d:	31 d2                	xor    %edx,%edx
  801b5f:	89 f0                	mov    %esi,%eax
  801b61:	f7 f1                	div    %ecx
  801b63:	89 c6                	mov    %eax,%esi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801b65:	89 f8                	mov    %edi,%eax
  801b67:	f7 f1                	div    %ecx
  801b69:	89 c7                	mov    %eax,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  801b6b:	89 f8                	mov    %edi,%eax
  801b6d:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801b6f:	83 c4 10             	add    $0x10,%esp
  801b72:	5e                   	pop    %esi
  801b73:	5f                   	pop    %edi
  801b74:	c9                   	leave  
  801b75:	c3                   	ret    
  801b76:	66 90                	xchg   %ax,%ax
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  801b78:	39 f0                	cmp    %esi,%eax
  801b7a:	77 1c                	ja     801b98 <__udivdi3+0x6c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  801b7c:	0f bd f8             	bsr    %eax,%edi
	  if (bm == 0)
  801b7f:	83 f7 1f             	xor    $0x1f,%edi
  801b82:	75 3c                	jne    801bc0 <__udivdi3+0x94>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  801b84:	39 f0                	cmp    %esi,%eax
  801b86:	0f 82 90 00 00 00    	jb     801c1c <__udivdi3+0xf0>
  801b8c:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801b8f:	39 55 f4             	cmp    %edx,-0xc(%ebp)
  801b92:	0f 86 84 00 00 00    	jbe    801c1c <__udivdi3+0xf0>
  801b98:	31 f6                	xor    %esi,%esi
  801b9a:	31 ff                	xor    %edi,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  801b9c:	89 f8                	mov    %edi,%eax
  801b9e:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801ba0:	83 c4 10             	add    $0x10,%esp
  801ba3:	5e                   	pop    %esi
  801ba4:	5f                   	pop    %edi
  801ba5:	c9                   	leave  
  801ba6:	c3                   	ret    
  801ba7:	90                   	nop
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801ba8:	89 f2                	mov    %esi,%edx
  801baa:	89 f8                	mov    %edi,%eax
  801bac:	f7 f1                	div    %ecx
  801bae:	89 c7                	mov    %eax,%edi
  801bb0:	31 f6                	xor    %esi,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  801bb2:	89 f8                	mov    %edi,%eax
  801bb4:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801bb6:	83 c4 10             	add    $0x10,%esp
  801bb9:	5e                   	pop    %esi
  801bba:	5f                   	pop    %edi
  801bbb:	c9                   	leave  
  801bbc:	c3                   	ret    
  801bbd:	8d 76 00             	lea    0x0(%esi),%esi
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  801bc0:	89 f9                	mov    %edi,%ecx
  801bc2:	d3 e0                	shl    %cl,%eax
  801bc4:	89 45 e8             	mov    %eax,-0x18(%ebp)
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  801bc7:	b8 20 00 00 00       	mov    $0x20,%eax
  801bcc:	29 f8                	sub    %edi,%eax

	      d1 = (d1 << bm) | (d0 >> b);
  801bce:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801bd1:	88 c1                	mov    %al,%cl
  801bd3:	d3 ea                	shr    %cl,%edx
  801bd5:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  801bd8:	09 ca                	or     %ecx,%edx
  801bda:	89 55 ec             	mov    %edx,-0x14(%ebp)
	      d0 = d0 << bm;
  801bdd:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801be0:	89 f9                	mov    %edi,%ecx
  801be2:	d3 e2                	shl    %cl,%edx
  801be4:	89 55 f4             	mov    %edx,-0xc(%ebp)
	      n2 = n1 >> b;
  801be7:	89 f2                	mov    %esi,%edx
  801be9:	88 c1                	mov    %al,%cl
  801beb:	d3 ea                	shr    %cl,%edx
  801bed:	89 55 e8             	mov    %edx,-0x18(%ebp)
	      n1 = (n1 << bm) | (n0 >> b);
  801bf0:	89 f2                	mov    %esi,%edx
  801bf2:	89 f9                	mov    %edi,%ecx
  801bf4:	d3 e2                	shl    %cl,%edx
  801bf6:	8b 75 f0             	mov    -0x10(%ebp),%esi
  801bf9:	88 c1                	mov    %al,%cl
  801bfb:	d3 ee                	shr    %cl,%esi
  801bfd:	09 d6                	or     %edx,%esi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  801bff:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  801c02:	89 f0                	mov    %esi,%eax
  801c04:	89 ca                	mov    %ecx,%edx
  801c06:	f7 75 ec             	divl   -0x14(%ebp)
  801c09:	89 d1                	mov    %edx,%ecx
  801c0b:	89 c6                	mov    %eax,%esi
	      umul_ppmm (m1, m0, q0, d0);
  801c0d:	f7 65 f4             	mull   -0xc(%ebp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801c10:	39 d1                	cmp    %edx,%ecx
  801c12:	72 28                	jb     801c3c <__udivdi3+0x110>
  801c14:	74 1a                	je     801c30 <__udivdi3+0x104>
  801c16:	89 f7                	mov    %esi,%edi
  801c18:	31 f6                	xor    %esi,%esi
  801c1a:	eb 80                	jmp    801b9c <__udivdi3+0x70>
	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  801c1c:	31 f6                	xor    %esi,%esi
  801c1e:	bf 01 00 00 00       	mov    $0x1,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  801c23:	89 f8                	mov    %edi,%eax
  801c25:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801c27:	83 c4 10             	add    $0x10,%esp
  801c2a:	5e                   	pop    %esi
  801c2b:	5f                   	pop    %edi
  801c2c:	c9                   	leave  
  801c2d:	c3                   	ret    
  801c2e:	66 90                	xchg   %ax,%ax

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  801c30:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801c33:	89 f9                	mov    %edi,%ecx
  801c35:	d3 e2                	shl    %cl,%edx

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801c37:	39 c2                	cmp    %eax,%edx
  801c39:	73 db                	jae    801c16 <__udivdi3+0xea>
  801c3b:	90                   	nop
		{
		  q0--;
  801c3c:	8d 7e ff             	lea    -0x1(%esi),%edi
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  801c3f:	31 f6                	xor    %esi,%esi
  801c41:	e9 56 ff ff ff       	jmp    801b9c <__udivdi3+0x70>
	...

00801c48 <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  801c48:	55                   	push   %ebp
  801c49:	89 e5                	mov    %esp,%ebp
  801c4b:	57                   	push   %edi
  801c4c:	56                   	push   %esi
  801c4d:	83 ec 20             	sub    $0x20,%esp
  801c50:	8b 45 08             	mov    0x8(%ebp),%eax
  801c53:	8b 4d 10             	mov    0x10(%ebp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  801c56:	89 45 e8             	mov    %eax,-0x18(%ebp)
  801c59:	8b 75 0c             	mov    0xc(%ebp),%esi
  const DWunion dd = {.ll = d};
  801c5c:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  801c5f:	8b 7d 14             	mov    0x14(%ebp),%edi
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  801c62:	89 45 f0             	mov    %eax,-0x10(%ebp)
  n1 = nn.s.high;
  801c65:	89 f2                	mov    %esi,%edx

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  801c67:	85 ff                	test   %edi,%edi
  801c69:	75 15                	jne    801c80 <__umoddi3+0x38>
    {
      if (d0 > n1)
  801c6b:	39 f1                	cmp    %esi,%ecx
  801c6d:	0f 86 99 00 00 00    	jbe    801d0c <__umoddi3+0xc4>
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801c73:	f7 f1                	div    %ecx

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
  801c75:	89 d0                	mov    %edx,%eax
  801c77:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  801c79:	83 c4 20             	add    $0x20,%esp
  801c7c:	5e                   	pop    %esi
  801c7d:	5f                   	pop    %edi
  801c7e:	c9                   	leave  
  801c7f:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  801c80:	39 f7                	cmp    %esi,%edi
  801c82:	0f 87 a4 00 00 00    	ja     801d2c <__umoddi3+0xe4>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  801c88:	0f bd c7             	bsr    %edi,%eax
	  if (bm == 0)
  801c8b:	83 f0 1f             	xor    $0x1f,%eax
  801c8e:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801c91:	0f 84 a1 00 00 00    	je     801d38 <__umoddi3+0xf0>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  801c97:	89 f8                	mov    %edi,%eax
  801c99:	8a 4d ec             	mov    -0x14(%ebp),%cl
  801c9c:	d3 e0                	shl    %cl,%eax
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  801c9e:	bf 20 00 00 00       	mov    $0x20,%edi
  801ca3:	2b 7d ec             	sub    -0x14(%ebp),%edi

	      d1 = (d1 << bm) | (d0 >> b);
  801ca6:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801ca9:	89 f9                	mov    %edi,%ecx
  801cab:	d3 ea                	shr    %cl,%edx
  801cad:	09 c2                	or     %eax,%edx
  801caf:	89 55 f0             	mov    %edx,-0x10(%ebp)
	      d0 = d0 << bm;
  801cb2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801cb5:	8a 4d ec             	mov    -0x14(%ebp),%cl
  801cb8:	d3 e0                	shl    %cl,%eax
  801cba:	89 45 f4             	mov    %eax,-0xc(%ebp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  801cbd:	89 f2                	mov    %esi,%edx
  801cbf:	d3 e2                	shl    %cl,%edx
	      n0 = n0 << bm;
  801cc1:	8b 45 e8             	mov    -0x18(%ebp),%eax
  801cc4:	d3 e0                	shl    %cl,%eax
  801cc6:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  801cc9:	8b 45 e8             	mov    -0x18(%ebp),%eax
  801ccc:	89 f9                	mov    %edi,%ecx
  801cce:	d3 e8                	shr    %cl,%eax
  801cd0:	09 d0                	or     %edx,%eax

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  801cd2:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  801cd4:	89 f2                	mov    %esi,%edx
  801cd6:	f7 75 f0             	divl   -0x10(%ebp)
  801cd9:	89 d6                	mov    %edx,%esi
	      umul_ppmm (m1, m0, q0, d0);
  801cdb:	f7 65 f4             	mull   -0xc(%ebp)
  801cde:	89 55 e8             	mov    %edx,-0x18(%ebp)
  801ce1:	89 c1                	mov    %eax,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801ce3:	39 d6                	cmp    %edx,%esi
  801ce5:	72 71                	jb     801d58 <__umoddi3+0x110>
  801ce7:	74 7f                	je     801d68 <__umoddi3+0x120>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  801ce9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801cec:	29 c8                	sub    %ecx,%eax
  801cee:	19 d6                	sbb    %edx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
  801cf0:	8a 4d ec             	mov    -0x14(%ebp),%cl
  801cf3:	d3 e8                	shr    %cl,%eax
  801cf5:	89 f2                	mov    %esi,%edx
  801cf7:	89 f9                	mov    %edi,%ecx
  801cf9:	d3 e2                	shl    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
  801cfb:	09 d0                	or     %edx,%eax
  801cfd:	89 f2                	mov    %esi,%edx
  801cff:	8a 4d ec             	mov    -0x14(%ebp),%cl
  801d02:	d3 ea                	shr    %cl,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  801d04:	83 c4 20             	add    $0x20,%esp
  801d07:	5e                   	pop    %esi
  801d08:	5f                   	pop    %edi
  801d09:	c9                   	leave  
  801d0a:	c3                   	ret    
  801d0b:	90                   	nop
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  801d0c:	85 c9                	test   %ecx,%ecx
  801d0e:	75 0b                	jne    801d1b <__umoddi3+0xd3>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  801d10:	b8 01 00 00 00       	mov    $0x1,%eax
  801d15:	31 d2                	xor    %edx,%edx
  801d17:	f7 f1                	div    %ecx
  801d19:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  801d1b:	89 f0                	mov    %esi,%eax
  801d1d:	31 d2                	xor    %edx,%edx
  801d1f:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801d21:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801d24:	f7 f1                	div    %ecx
  801d26:	e9 4a ff ff ff       	jmp    801c75 <__umoddi3+0x2d>
  801d2b:	90                   	nop
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
  801d2c:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  801d2e:	83 c4 20             	add    $0x20,%esp
  801d31:	5e                   	pop    %esi
  801d32:	5f                   	pop    %edi
  801d33:	c9                   	leave  
  801d34:	c3                   	ret    
  801d35:	8d 76 00             	lea    0x0(%esi),%esi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  801d38:	39 f7                	cmp    %esi,%edi
  801d3a:	72 05                	jb     801d41 <__umoddi3+0xf9>
  801d3c:	3b 4d f0             	cmp    -0x10(%ebp),%ecx
  801d3f:	77 0c                	ja     801d4d <__umoddi3+0x105>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  801d41:	89 f2                	mov    %esi,%edx
  801d43:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801d46:	29 c8                	sub    %ecx,%eax
  801d48:	19 fa                	sbb    %edi,%edx
  801d4a:	89 45 f0             	mov    %eax,-0x10(%ebp)

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
  801d4d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  801d50:	83 c4 20             	add    $0x20,%esp
  801d53:	5e                   	pop    %esi
  801d54:	5f                   	pop    %edi
  801d55:	c9                   	leave  
  801d56:	c3                   	ret    
  801d57:	90                   	nop
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  801d58:	8b 55 e8             	mov    -0x18(%ebp),%edx
  801d5b:	89 c1                	mov    %eax,%ecx
  801d5d:	2b 4d f4             	sub    -0xc(%ebp),%ecx
  801d60:	1b 55 f0             	sbb    -0x10(%ebp),%edx
  801d63:	eb 84                	jmp    801ce9 <__umoddi3+0xa1>
  801d65:	8d 76 00             	lea    0x0(%esi),%esi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801d68:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  801d6b:	72 eb                	jb     801d58 <__umoddi3+0x110>
  801d6d:	89 f2                	mov    %esi,%edx
  801d6f:	e9 75 ff ff ff       	jmp    801ce9 <__umoddi3+0xa1>
