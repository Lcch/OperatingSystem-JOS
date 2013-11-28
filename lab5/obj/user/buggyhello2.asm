
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
  8000a6:	e8 87 04 00 00       	call   800532 <close_all>
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
  8000ee:	68 b8 1d 80 00       	push   $0x801db8
  8000f3:	6a 42                	push   $0x42
  8000f5:	68 d5 1d 80 00       	push   $0x801dd5
  8000fa:	e8 dd 0e 00 00       	call   800fdc <_panic>

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

00800300 <sys_exec>:

int
sys_exec(uint32_t eip, uint32_t esp, void * ph, uint32_t elf_phnum)
{
  800300:	55                   	push   %ebp
  800301:	89 e5                	mov    %esp,%ebp
  800303:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_exec, 0, eip, esp, (uint32_t)ph, elf_phnum, 0);
  800306:	6a 00                	push   $0x0
  800308:	ff 75 14             	pushl  0x14(%ebp)
  80030b:	ff 75 10             	pushl  0x10(%ebp)
  80030e:	ff 75 0c             	pushl  0xc(%ebp)
  800311:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800314:	ba 00 00 00 00       	mov    $0x0,%edx
  800319:	b8 0f 00 00 00       	mov    $0xf,%eax
  80031e:	e8 99 fd ff ff       	call   8000bc <syscall>
  800323:	c9                   	leave  
  800324:	c3                   	ret    
  800325:	00 00                	add    %al,(%eax)
	...

00800328 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800328:	55                   	push   %ebp
  800329:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80032b:	8b 45 08             	mov    0x8(%ebp),%eax
  80032e:	05 00 00 00 30       	add    $0x30000000,%eax
  800333:	c1 e8 0c             	shr    $0xc,%eax
}
  800336:	c9                   	leave  
  800337:	c3                   	ret    

00800338 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800338:	55                   	push   %ebp
  800339:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  80033b:	ff 75 08             	pushl  0x8(%ebp)
  80033e:	e8 e5 ff ff ff       	call   800328 <fd2num>
  800343:	83 c4 04             	add    $0x4,%esp
  800346:	05 20 00 0d 00       	add    $0xd0020,%eax
  80034b:	c1 e0 0c             	shl    $0xc,%eax
}
  80034e:	c9                   	leave  
  80034f:	c3                   	ret    

00800350 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800350:	55                   	push   %ebp
  800351:	89 e5                	mov    %esp,%ebp
  800353:	53                   	push   %ebx
  800354:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800357:	a1 00 dd 7b ef       	mov    0xef7bdd00,%eax
  80035c:	a8 01                	test   $0x1,%al
  80035e:	74 34                	je     800394 <fd_alloc+0x44>
  800360:	a1 00 00 74 ef       	mov    0xef740000,%eax
  800365:	a8 01                	test   $0x1,%al
  800367:	74 32                	je     80039b <fd_alloc+0x4b>
  800369:	b8 00 10 00 d0       	mov    $0xd0001000,%eax
  80036e:	89 c1                	mov    %eax,%ecx
  800370:	89 c2                	mov    %eax,%edx
  800372:	c1 ea 16             	shr    $0x16,%edx
  800375:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80037c:	f6 c2 01             	test   $0x1,%dl
  80037f:	74 1f                	je     8003a0 <fd_alloc+0x50>
  800381:	89 c2                	mov    %eax,%edx
  800383:	c1 ea 0c             	shr    $0xc,%edx
  800386:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80038d:	f6 c2 01             	test   $0x1,%dl
  800390:	75 17                	jne    8003a9 <fd_alloc+0x59>
  800392:	eb 0c                	jmp    8003a0 <fd_alloc+0x50>
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  800394:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
  800399:	eb 05                	jmp    8003a0 <fd_alloc+0x50>
  80039b:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
  8003a0:	89 0b                	mov    %ecx,(%ebx)
			return 0;
  8003a2:	b8 00 00 00 00       	mov    $0x0,%eax
  8003a7:	eb 17                	jmp    8003c0 <fd_alloc+0x70>
  8003a9:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8003ae:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8003b3:	75 b9                	jne    80036e <fd_alloc+0x1e>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8003b5:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_MAX_OPEN;
  8003bb:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8003c0:	5b                   	pop    %ebx
  8003c1:	c9                   	leave  
  8003c2:	c3                   	ret    

008003c3 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8003c3:	55                   	push   %ebp
  8003c4:	89 e5                	mov    %esp,%ebp
  8003c6:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8003c9:	83 f8 1f             	cmp    $0x1f,%eax
  8003cc:	77 36                	ja     800404 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8003ce:	05 00 00 0d 00       	add    $0xd0000,%eax
  8003d3:	c1 e0 0c             	shl    $0xc,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8003d6:	89 c2                	mov    %eax,%edx
  8003d8:	c1 ea 16             	shr    $0x16,%edx
  8003db:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8003e2:	f6 c2 01             	test   $0x1,%dl
  8003e5:	74 24                	je     80040b <fd_lookup+0x48>
  8003e7:	89 c2                	mov    %eax,%edx
  8003e9:	c1 ea 0c             	shr    $0xc,%edx
  8003ec:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8003f3:	f6 c2 01             	test   $0x1,%dl
  8003f6:	74 1a                	je     800412 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8003f8:	8b 55 0c             	mov    0xc(%ebp),%edx
  8003fb:	89 02                	mov    %eax,(%edx)
	return 0;
  8003fd:	b8 00 00 00 00       	mov    $0x0,%eax
  800402:	eb 13                	jmp    800417 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800404:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800409:	eb 0c                	jmp    800417 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80040b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800410:	eb 05                	jmp    800417 <fd_lookup+0x54>
  800412:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800417:	c9                   	leave  
  800418:	c3                   	ret    

00800419 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800419:	55                   	push   %ebp
  80041a:	89 e5                	mov    %esp,%ebp
  80041c:	53                   	push   %ebx
  80041d:	83 ec 04             	sub    $0x4,%esp
  800420:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800423:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
		if (devtab[i]->dev_id == dev_id) {
  800426:	39 0d 08 30 80 00    	cmp    %ecx,0x803008
  80042c:	74 0d                	je     80043b <dev_lookup+0x22>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  80042e:	b8 00 00 00 00       	mov    $0x0,%eax
  800433:	eb 14                	jmp    800449 <dev_lookup+0x30>
		if (devtab[i]->dev_id == dev_id) {
  800435:	39 0a                	cmp    %ecx,(%edx)
  800437:	75 10                	jne    800449 <dev_lookup+0x30>
  800439:	eb 05                	jmp    800440 <dev_lookup+0x27>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  80043b:	ba 08 30 80 00       	mov    $0x803008,%edx
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
  800440:	89 13                	mov    %edx,(%ebx)
			return 0;
  800442:	b8 00 00 00 00       	mov    $0x0,%eax
  800447:	eb 31                	jmp    80047a <dev_lookup+0x61>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800449:	40                   	inc    %eax
  80044a:	8b 14 85 60 1e 80 00 	mov    0x801e60(,%eax,4),%edx
  800451:	85 d2                	test   %edx,%edx
  800453:	75 e0                	jne    800435 <dev_lookup+0x1c>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800455:	a1 04 40 80 00       	mov    0x804004,%eax
  80045a:	8b 40 48             	mov    0x48(%eax),%eax
  80045d:	83 ec 04             	sub    $0x4,%esp
  800460:	51                   	push   %ecx
  800461:	50                   	push   %eax
  800462:	68 e4 1d 80 00       	push   $0x801de4
  800467:	e8 48 0c 00 00       	call   8010b4 <cprintf>
	*dev = 0;
  80046c:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_INVAL;
  800472:	83 c4 10             	add    $0x10,%esp
  800475:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  80047a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80047d:	c9                   	leave  
  80047e:	c3                   	ret    

0080047f <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  80047f:	55                   	push   %ebp
  800480:	89 e5                	mov    %esp,%ebp
  800482:	56                   	push   %esi
  800483:	53                   	push   %ebx
  800484:	83 ec 20             	sub    $0x20,%esp
  800487:	8b 75 08             	mov    0x8(%ebp),%esi
  80048a:	8a 45 0c             	mov    0xc(%ebp),%al
  80048d:	88 45 e7             	mov    %al,-0x19(%ebp)
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800490:	56                   	push   %esi
  800491:	e8 92 fe ff ff       	call   800328 <fd2num>
  800496:	8d 55 f4             	lea    -0xc(%ebp),%edx
  800499:	89 14 24             	mov    %edx,(%esp)
  80049c:	50                   	push   %eax
  80049d:	e8 21 ff ff ff       	call   8003c3 <fd_lookup>
  8004a2:	89 c3                	mov    %eax,%ebx
  8004a4:	83 c4 08             	add    $0x8,%esp
  8004a7:	85 c0                	test   %eax,%eax
  8004a9:	78 05                	js     8004b0 <fd_close+0x31>
	    || fd != fd2)
  8004ab:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8004ae:	74 0d                	je     8004bd <fd_close+0x3e>
		return (must_exist ? r : 0);
  8004b0:	80 7d e7 00          	cmpb   $0x0,-0x19(%ebp)
  8004b4:	75 48                	jne    8004fe <fd_close+0x7f>
  8004b6:	bb 00 00 00 00       	mov    $0x0,%ebx
  8004bb:	eb 41                	jmp    8004fe <fd_close+0x7f>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8004bd:	83 ec 08             	sub    $0x8,%esp
  8004c0:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8004c3:	50                   	push   %eax
  8004c4:	ff 36                	pushl  (%esi)
  8004c6:	e8 4e ff ff ff       	call   800419 <dev_lookup>
  8004cb:	89 c3                	mov    %eax,%ebx
  8004cd:	83 c4 10             	add    $0x10,%esp
  8004d0:	85 c0                	test   %eax,%eax
  8004d2:	78 1c                	js     8004f0 <fd_close+0x71>
		if (dev->dev_close)
  8004d4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8004d7:	8b 40 10             	mov    0x10(%eax),%eax
  8004da:	85 c0                	test   %eax,%eax
  8004dc:	74 0d                	je     8004eb <fd_close+0x6c>
			r = (*dev->dev_close)(fd);
  8004de:	83 ec 0c             	sub    $0xc,%esp
  8004e1:	56                   	push   %esi
  8004e2:	ff d0                	call   *%eax
  8004e4:	89 c3                	mov    %eax,%ebx
  8004e6:	83 c4 10             	add    $0x10,%esp
  8004e9:	eb 05                	jmp    8004f0 <fd_close+0x71>
		else
			r = 0;
  8004eb:	bb 00 00 00 00       	mov    $0x0,%ebx
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8004f0:	83 ec 08             	sub    $0x8,%esp
  8004f3:	56                   	push   %esi
  8004f4:	6a 00                	push   $0x0
  8004f6:	e8 0f fd ff ff       	call   80020a <sys_page_unmap>
	return r;
  8004fb:	83 c4 10             	add    $0x10,%esp
}
  8004fe:	89 d8                	mov    %ebx,%eax
  800500:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800503:	5b                   	pop    %ebx
  800504:	5e                   	pop    %esi
  800505:	c9                   	leave  
  800506:	c3                   	ret    

00800507 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  800507:	55                   	push   %ebp
  800508:	89 e5                	mov    %esp,%ebp
  80050a:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80050d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800510:	50                   	push   %eax
  800511:	ff 75 08             	pushl  0x8(%ebp)
  800514:	e8 aa fe ff ff       	call   8003c3 <fd_lookup>
  800519:	83 c4 08             	add    $0x8,%esp
  80051c:	85 c0                	test   %eax,%eax
  80051e:	78 10                	js     800530 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  800520:	83 ec 08             	sub    $0x8,%esp
  800523:	6a 01                	push   $0x1
  800525:	ff 75 f4             	pushl  -0xc(%ebp)
  800528:	e8 52 ff ff ff       	call   80047f <fd_close>
  80052d:	83 c4 10             	add    $0x10,%esp
}
  800530:	c9                   	leave  
  800531:	c3                   	ret    

00800532 <close_all>:

void
close_all(void)
{
  800532:	55                   	push   %ebp
  800533:	89 e5                	mov    %esp,%ebp
  800535:	53                   	push   %ebx
  800536:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800539:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  80053e:	83 ec 0c             	sub    $0xc,%esp
  800541:	53                   	push   %ebx
  800542:	e8 c0 ff ff ff       	call   800507 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  800547:	43                   	inc    %ebx
  800548:	83 c4 10             	add    $0x10,%esp
  80054b:	83 fb 20             	cmp    $0x20,%ebx
  80054e:	75 ee                	jne    80053e <close_all+0xc>
		close(i);
}
  800550:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800553:	c9                   	leave  
  800554:	c3                   	ret    

00800555 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800555:	55                   	push   %ebp
  800556:	89 e5                	mov    %esp,%ebp
  800558:	57                   	push   %edi
  800559:	56                   	push   %esi
  80055a:	53                   	push   %ebx
  80055b:	83 ec 2c             	sub    $0x2c,%esp
  80055e:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  800561:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800564:	50                   	push   %eax
  800565:	ff 75 08             	pushl  0x8(%ebp)
  800568:	e8 56 fe ff ff       	call   8003c3 <fd_lookup>
  80056d:	89 c3                	mov    %eax,%ebx
  80056f:	83 c4 08             	add    $0x8,%esp
  800572:	85 c0                	test   %eax,%eax
  800574:	0f 88 c0 00 00 00    	js     80063a <dup+0xe5>
		return r;
	close(newfdnum);
  80057a:	83 ec 0c             	sub    $0xc,%esp
  80057d:	57                   	push   %edi
  80057e:	e8 84 ff ff ff       	call   800507 <close>

	newfd = INDEX2FD(newfdnum);
  800583:	8d b7 00 00 0d 00    	lea    0xd0000(%edi),%esi
  800589:	c1 e6 0c             	shl    $0xc,%esi
	ova = fd2data(oldfd);
  80058c:	83 c4 04             	add    $0x4,%esp
  80058f:	ff 75 e4             	pushl  -0x1c(%ebp)
  800592:	e8 a1 fd ff ff       	call   800338 <fd2data>
  800597:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  800599:	89 34 24             	mov    %esi,(%esp)
  80059c:	e8 97 fd ff ff       	call   800338 <fd2data>
  8005a1:	83 c4 10             	add    $0x10,%esp
  8005a4:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8005a7:	89 d8                	mov    %ebx,%eax
  8005a9:	c1 e8 16             	shr    $0x16,%eax
  8005ac:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8005b3:	a8 01                	test   $0x1,%al
  8005b5:	74 37                	je     8005ee <dup+0x99>
  8005b7:	89 d8                	mov    %ebx,%eax
  8005b9:	c1 e8 0c             	shr    $0xc,%eax
  8005bc:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8005c3:	f6 c2 01             	test   $0x1,%dl
  8005c6:	74 26                	je     8005ee <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8005c8:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8005cf:	83 ec 0c             	sub    $0xc,%esp
  8005d2:	25 07 0e 00 00       	and    $0xe07,%eax
  8005d7:	50                   	push   %eax
  8005d8:	ff 75 d4             	pushl  -0x2c(%ebp)
  8005db:	6a 00                	push   $0x0
  8005dd:	53                   	push   %ebx
  8005de:	6a 00                	push   $0x0
  8005e0:	e8 ff fb ff ff       	call   8001e4 <sys_page_map>
  8005e5:	89 c3                	mov    %eax,%ebx
  8005e7:	83 c4 20             	add    $0x20,%esp
  8005ea:	85 c0                	test   %eax,%eax
  8005ec:	78 2d                	js     80061b <dup+0xc6>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8005ee:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8005f1:	89 c2                	mov    %eax,%edx
  8005f3:	c1 ea 0c             	shr    $0xc,%edx
  8005f6:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8005fd:	83 ec 0c             	sub    $0xc,%esp
  800600:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  800606:	52                   	push   %edx
  800607:	56                   	push   %esi
  800608:	6a 00                	push   $0x0
  80060a:	50                   	push   %eax
  80060b:	6a 00                	push   $0x0
  80060d:	e8 d2 fb ff ff       	call   8001e4 <sys_page_map>
  800612:	89 c3                	mov    %eax,%ebx
  800614:	83 c4 20             	add    $0x20,%esp
  800617:	85 c0                	test   %eax,%eax
  800619:	79 1d                	jns    800638 <dup+0xe3>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  80061b:	83 ec 08             	sub    $0x8,%esp
  80061e:	56                   	push   %esi
  80061f:	6a 00                	push   $0x0
  800621:	e8 e4 fb ff ff       	call   80020a <sys_page_unmap>
	sys_page_unmap(0, nva);
  800626:	83 c4 08             	add    $0x8,%esp
  800629:	ff 75 d4             	pushl  -0x2c(%ebp)
  80062c:	6a 00                	push   $0x0
  80062e:	e8 d7 fb ff ff       	call   80020a <sys_page_unmap>
	return r;
  800633:	83 c4 10             	add    $0x10,%esp
  800636:	eb 02                	jmp    80063a <dup+0xe5>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
		goto err;

	return newfdnum;
  800638:	89 fb                	mov    %edi,%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  80063a:	89 d8                	mov    %ebx,%eax
  80063c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80063f:	5b                   	pop    %ebx
  800640:	5e                   	pop    %esi
  800641:	5f                   	pop    %edi
  800642:	c9                   	leave  
  800643:	c3                   	ret    

00800644 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  800644:	55                   	push   %ebp
  800645:	89 e5                	mov    %esp,%ebp
  800647:	53                   	push   %ebx
  800648:	83 ec 14             	sub    $0x14,%esp
  80064b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80064e:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800651:	50                   	push   %eax
  800652:	53                   	push   %ebx
  800653:	e8 6b fd ff ff       	call   8003c3 <fd_lookup>
  800658:	83 c4 08             	add    $0x8,%esp
  80065b:	85 c0                	test   %eax,%eax
  80065d:	78 67                	js     8006c6 <read+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80065f:	83 ec 08             	sub    $0x8,%esp
  800662:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800665:	50                   	push   %eax
  800666:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800669:	ff 30                	pushl  (%eax)
  80066b:	e8 a9 fd ff ff       	call   800419 <dev_lookup>
  800670:	83 c4 10             	add    $0x10,%esp
  800673:	85 c0                	test   %eax,%eax
  800675:	78 4f                	js     8006c6 <read+0x82>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  800677:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80067a:	8b 50 08             	mov    0x8(%eax),%edx
  80067d:	83 e2 03             	and    $0x3,%edx
  800680:	83 fa 01             	cmp    $0x1,%edx
  800683:	75 21                	jne    8006a6 <read+0x62>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  800685:	a1 04 40 80 00       	mov    0x804004,%eax
  80068a:	8b 40 48             	mov    0x48(%eax),%eax
  80068d:	83 ec 04             	sub    $0x4,%esp
  800690:	53                   	push   %ebx
  800691:	50                   	push   %eax
  800692:	68 25 1e 80 00       	push   $0x801e25
  800697:	e8 18 0a 00 00       	call   8010b4 <cprintf>
		return -E_INVAL;
  80069c:	83 c4 10             	add    $0x10,%esp
  80069f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8006a4:	eb 20                	jmp    8006c6 <read+0x82>
	}
	if (!dev->dev_read)
  8006a6:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8006a9:	8b 52 08             	mov    0x8(%edx),%edx
  8006ac:	85 d2                	test   %edx,%edx
  8006ae:	74 11                	je     8006c1 <read+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8006b0:	83 ec 04             	sub    $0x4,%esp
  8006b3:	ff 75 10             	pushl  0x10(%ebp)
  8006b6:	ff 75 0c             	pushl  0xc(%ebp)
  8006b9:	50                   	push   %eax
  8006ba:	ff d2                	call   *%edx
  8006bc:	83 c4 10             	add    $0x10,%esp
  8006bf:	eb 05                	jmp    8006c6 <read+0x82>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8006c1:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_read)(fd, buf, n);
}
  8006c6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8006c9:	c9                   	leave  
  8006ca:	c3                   	ret    

008006cb <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8006cb:	55                   	push   %ebp
  8006cc:	89 e5                	mov    %esp,%ebp
  8006ce:	57                   	push   %edi
  8006cf:	56                   	push   %esi
  8006d0:	53                   	push   %ebx
  8006d1:	83 ec 0c             	sub    $0xc,%esp
  8006d4:	8b 7d 08             	mov    0x8(%ebp),%edi
  8006d7:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8006da:	85 f6                	test   %esi,%esi
  8006dc:	74 31                	je     80070f <readn+0x44>
  8006de:	b8 00 00 00 00       	mov    $0x0,%eax
  8006e3:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = read(fdnum, (char*)buf + tot, n - tot);
  8006e8:	83 ec 04             	sub    $0x4,%esp
  8006eb:	89 f2                	mov    %esi,%edx
  8006ed:	29 c2                	sub    %eax,%edx
  8006ef:	52                   	push   %edx
  8006f0:	03 45 0c             	add    0xc(%ebp),%eax
  8006f3:	50                   	push   %eax
  8006f4:	57                   	push   %edi
  8006f5:	e8 4a ff ff ff       	call   800644 <read>
		if (m < 0)
  8006fa:	83 c4 10             	add    $0x10,%esp
  8006fd:	85 c0                	test   %eax,%eax
  8006ff:	78 17                	js     800718 <readn+0x4d>
			return m;
		if (m == 0)
  800701:	85 c0                	test   %eax,%eax
  800703:	74 11                	je     800716 <readn+0x4b>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  800705:	01 c3                	add    %eax,%ebx
  800707:	89 d8                	mov    %ebx,%eax
  800709:	39 f3                	cmp    %esi,%ebx
  80070b:	72 db                	jb     8006e8 <readn+0x1d>
  80070d:	eb 09                	jmp    800718 <readn+0x4d>
  80070f:	b8 00 00 00 00       	mov    $0x0,%eax
  800714:	eb 02                	jmp    800718 <readn+0x4d>
		m = read(fdnum, (char*)buf + tot, n - tot);
		if (m < 0)
			return m;
		if (m == 0)
  800716:	89 d8                	mov    %ebx,%eax
			break;
	}
	return tot;
}
  800718:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80071b:	5b                   	pop    %ebx
  80071c:	5e                   	pop    %esi
  80071d:	5f                   	pop    %edi
  80071e:	c9                   	leave  
  80071f:	c3                   	ret    

00800720 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  800720:	55                   	push   %ebp
  800721:	89 e5                	mov    %esp,%ebp
  800723:	53                   	push   %ebx
  800724:	83 ec 14             	sub    $0x14,%esp
  800727:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80072a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80072d:	50                   	push   %eax
  80072e:	53                   	push   %ebx
  80072f:	e8 8f fc ff ff       	call   8003c3 <fd_lookup>
  800734:	83 c4 08             	add    $0x8,%esp
  800737:	85 c0                	test   %eax,%eax
  800739:	78 62                	js     80079d <write+0x7d>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80073b:	83 ec 08             	sub    $0x8,%esp
  80073e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800741:	50                   	push   %eax
  800742:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800745:	ff 30                	pushl  (%eax)
  800747:	e8 cd fc ff ff       	call   800419 <dev_lookup>
  80074c:	83 c4 10             	add    $0x10,%esp
  80074f:	85 c0                	test   %eax,%eax
  800751:	78 4a                	js     80079d <write+0x7d>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800753:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800756:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80075a:	75 21                	jne    80077d <write+0x5d>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  80075c:	a1 04 40 80 00       	mov    0x804004,%eax
  800761:	8b 40 48             	mov    0x48(%eax),%eax
  800764:	83 ec 04             	sub    $0x4,%esp
  800767:	53                   	push   %ebx
  800768:	50                   	push   %eax
  800769:	68 41 1e 80 00       	push   $0x801e41
  80076e:	e8 41 09 00 00       	call   8010b4 <cprintf>
		return -E_INVAL;
  800773:	83 c4 10             	add    $0x10,%esp
  800776:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80077b:	eb 20                	jmp    80079d <write+0x7d>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80077d:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800780:	8b 52 0c             	mov    0xc(%edx),%edx
  800783:	85 d2                	test   %edx,%edx
  800785:	74 11                	je     800798 <write+0x78>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  800787:	83 ec 04             	sub    $0x4,%esp
  80078a:	ff 75 10             	pushl  0x10(%ebp)
  80078d:	ff 75 0c             	pushl  0xc(%ebp)
  800790:	50                   	push   %eax
  800791:	ff d2                	call   *%edx
  800793:	83 c4 10             	add    $0x10,%esp
  800796:	eb 05                	jmp    80079d <write+0x7d>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  800798:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  80079d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007a0:	c9                   	leave  
  8007a1:	c3                   	ret    

008007a2 <seek>:

int
seek(int fdnum, off_t offset)
{
  8007a2:	55                   	push   %ebp
  8007a3:	89 e5                	mov    %esp,%ebp
  8007a5:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8007a8:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8007ab:	50                   	push   %eax
  8007ac:	ff 75 08             	pushl  0x8(%ebp)
  8007af:	e8 0f fc ff ff       	call   8003c3 <fd_lookup>
  8007b4:	83 c4 08             	add    $0x8,%esp
  8007b7:	85 c0                	test   %eax,%eax
  8007b9:	78 0e                	js     8007c9 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8007bb:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8007be:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007c1:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8007c4:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8007c9:	c9                   	leave  
  8007ca:	c3                   	ret    

008007cb <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8007cb:	55                   	push   %ebp
  8007cc:	89 e5                	mov    %esp,%ebp
  8007ce:	53                   	push   %ebx
  8007cf:	83 ec 14             	sub    $0x14,%esp
  8007d2:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8007d5:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8007d8:	50                   	push   %eax
  8007d9:	53                   	push   %ebx
  8007da:	e8 e4 fb ff ff       	call   8003c3 <fd_lookup>
  8007df:	83 c4 08             	add    $0x8,%esp
  8007e2:	85 c0                	test   %eax,%eax
  8007e4:	78 5f                	js     800845 <ftruncate+0x7a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8007e6:	83 ec 08             	sub    $0x8,%esp
  8007e9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8007ec:	50                   	push   %eax
  8007ed:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8007f0:	ff 30                	pushl  (%eax)
  8007f2:	e8 22 fc ff ff       	call   800419 <dev_lookup>
  8007f7:	83 c4 10             	add    $0x10,%esp
  8007fa:	85 c0                	test   %eax,%eax
  8007fc:	78 47                	js     800845 <ftruncate+0x7a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8007fe:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800801:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  800805:	75 21                	jne    800828 <ftruncate+0x5d>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  800807:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  80080c:	8b 40 48             	mov    0x48(%eax),%eax
  80080f:	83 ec 04             	sub    $0x4,%esp
  800812:	53                   	push   %ebx
  800813:	50                   	push   %eax
  800814:	68 04 1e 80 00       	push   $0x801e04
  800819:	e8 96 08 00 00       	call   8010b4 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  80081e:	83 c4 10             	add    $0x10,%esp
  800821:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800826:	eb 1d                	jmp    800845 <ftruncate+0x7a>
	}
	if (!dev->dev_trunc)
  800828:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80082b:	8b 52 18             	mov    0x18(%edx),%edx
  80082e:	85 d2                	test   %edx,%edx
  800830:	74 0e                	je     800840 <ftruncate+0x75>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  800832:	83 ec 08             	sub    $0x8,%esp
  800835:	ff 75 0c             	pushl  0xc(%ebp)
  800838:	50                   	push   %eax
  800839:	ff d2                	call   *%edx
  80083b:	83 c4 10             	add    $0x10,%esp
  80083e:	eb 05                	jmp    800845 <ftruncate+0x7a>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  800840:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  800845:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800848:	c9                   	leave  
  800849:	c3                   	ret    

0080084a <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  80084a:	55                   	push   %ebp
  80084b:	89 e5                	mov    %esp,%ebp
  80084d:	53                   	push   %ebx
  80084e:	83 ec 14             	sub    $0x14,%esp
  800851:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800854:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800857:	50                   	push   %eax
  800858:	ff 75 08             	pushl  0x8(%ebp)
  80085b:	e8 63 fb ff ff       	call   8003c3 <fd_lookup>
  800860:	83 c4 08             	add    $0x8,%esp
  800863:	85 c0                	test   %eax,%eax
  800865:	78 52                	js     8008b9 <fstat+0x6f>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800867:	83 ec 08             	sub    $0x8,%esp
  80086a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80086d:	50                   	push   %eax
  80086e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800871:	ff 30                	pushl  (%eax)
  800873:	e8 a1 fb ff ff       	call   800419 <dev_lookup>
  800878:	83 c4 10             	add    $0x10,%esp
  80087b:	85 c0                	test   %eax,%eax
  80087d:	78 3a                	js     8008b9 <fstat+0x6f>
		return r;
	if (!dev->dev_stat)
  80087f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800882:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  800886:	74 2c                	je     8008b4 <fstat+0x6a>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  800888:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  80088b:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  800892:	00 00 00 
	stat->st_isdir = 0;
  800895:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80089c:	00 00 00 
	stat->st_dev = dev;
  80089f:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8008a5:	83 ec 08             	sub    $0x8,%esp
  8008a8:	53                   	push   %ebx
  8008a9:	ff 75 f0             	pushl  -0x10(%ebp)
  8008ac:	ff 50 14             	call   *0x14(%eax)
  8008af:	83 c4 10             	add    $0x10,%esp
  8008b2:	eb 05                	jmp    8008b9 <fstat+0x6f>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8008b4:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8008b9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8008bc:	c9                   	leave  
  8008bd:	c3                   	ret    

008008be <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8008be:	55                   	push   %ebp
  8008bf:	89 e5                	mov    %esp,%ebp
  8008c1:	56                   	push   %esi
  8008c2:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8008c3:	83 ec 08             	sub    $0x8,%esp
  8008c6:	6a 00                	push   $0x0
  8008c8:	ff 75 08             	pushl  0x8(%ebp)
  8008cb:	e8 78 01 00 00       	call   800a48 <open>
  8008d0:	89 c3                	mov    %eax,%ebx
  8008d2:	83 c4 10             	add    $0x10,%esp
  8008d5:	85 c0                	test   %eax,%eax
  8008d7:	78 1b                	js     8008f4 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8008d9:	83 ec 08             	sub    $0x8,%esp
  8008dc:	ff 75 0c             	pushl  0xc(%ebp)
  8008df:	50                   	push   %eax
  8008e0:	e8 65 ff ff ff       	call   80084a <fstat>
  8008e5:	89 c6                	mov    %eax,%esi
	close(fd);
  8008e7:	89 1c 24             	mov    %ebx,(%esp)
  8008ea:	e8 18 fc ff ff       	call   800507 <close>
	return r;
  8008ef:	83 c4 10             	add    $0x10,%esp
  8008f2:	89 f3                	mov    %esi,%ebx
}
  8008f4:	89 d8                	mov    %ebx,%eax
  8008f6:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8008f9:	5b                   	pop    %ebx
  8008fa:	5e                   	pop    %esi
  8008fb:	c9                   	leave  
  8008fc:	c3                   	ret    
  8008fd:	00 00                	add    %al,(%eax)
	...

00800900 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  800900:	55                   	push   %ebp
  800901:	89 e5                	mov    %esp,%ebp
  800903:	56                   	push   %esi
  800904:	53                   	push   %ebx
  800905:	89 c3                	mov    %eax,%ebx
  800907:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  800909:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  800910:	75 12                	jne    800924 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  800912:	83 ec 0c             	sub    $0xc,%esp
  800915:	6a 01                	push   $0x1
  800917:	e8 96 11 00 00       	call   801ab2 <ipc_find_env>
  80091c:	a3 00 40 80 00       	mov    %eax,0x804000
  800921:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  800924:	6a 07                	push   $0x7
  800926:	68 00 50 80 00       	push   $0x805000
  80092b:	53                   	push   %ebx
  80092c:	ff 35 00 40 80 00    	pushl  0x804000
  800932:	e8 26 11 00 00       	call   801a5d <ipc_send>
	
	return ipc_recv(NULL, dstva, NULL);
  800937:	83 c4 0c             	add    $0xc,%esp
  80093a:	6a 00                	push   $0x0
  80093c:	56                   	push   %esi
  80093d:	6a 00                	push   $0x0
  80093f:	e8 a4 10 00 00       	call   8019e8 <ipc_recv>
}
  800944:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800947:	5b                   	pop    %ebx
  800948:	5e                   	pop    %esi
  800949:	c9                   	leave  
  80094a:	c3                   	ret    

0080094b <devfile_stat>:
}


static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  80094b:	55                   	push   %ebp
  80094c:	89 e5                	mov    %esp,%ebp
  80094e:	53                   	push   %ebx
  80094f:	83 ec 04             	sub    $0x4,%esp
  800952:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  800955:	8b 45 08             	mov    0x8(%ebp),%eax
  800958:	8b 40 0c             	mov    0xc(%eax),%eax
  80095b:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0) {
  800960:	ba 00 00 00 00       	mov    $0x0,%edx
  800965:	b8 05 00 00 00       	mov    $0x5,%eax
  80096a:	e8 91 ff ff ff       	call   800900 <fsipc>
  80096f:	85 c0                	test   %eax,%eax
  800971:	78 2c                	js     80099f <devfile_stat+0x54>
		return r;
	}
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  800973:	83 ec 08             	sub    $0x8,%esp
  800976:	68 00 50 80 00       	push   $0x805000
  80097b:	53                   	push   %ebx
  80097c:	e8 e9 0c 00 00       	call   80166a <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  800981:	a1 80 50 80 00       	mov    0x805080,%eax
  800986:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  80098c:	a1 84 50 80 00       	mov    0x805084,%eax
  800991:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  800997:	83 c4 10             	add    $0x10,%esp
  80099a:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80099f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8009a2:	c9                   	leave  
  8009a3:	c3                   	ret    

008009a4 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8009a4:	55                   	push   %ebp
  8009a5:	89 e5                	mov    %esp,%ebp
  8009a7:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8009aa:	8b 45 08             	mov    0x8(%ebp),%eax
  8009ad:	8b 40 0c             	mov    0xc(%eax),%eax
  8009b0:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8009b5:	ba 00 00 00 00       	mov    $0x0,%edx
  8009ba:	b8 06 00 00 00       	mov    $0x6,%eax
  8009bf:	e8 3c ff ff ff       	call   800900 <fsipc>
}
  8009c4:	c9                   	leave  
  8009c5:	c3                   	ret    

008009c6 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  8009c6:	55                   	push   %ebp
  8009c7:	89 e5                	mov    %esp,%ebp
  8009c9:	56                   	push   %esi
  8009ca:	53                   	push   %ebx
  8009cb:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8009ce:	8b 45 08             	mov    0x8(%ebp),%eax
  8009d1:	8b 40 0c             	mov    0xc(%eax),%eax
  8009d4:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  8009d9:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8009df:	ba 00 00 00 00       	mov    $0x0,%edx
  8009e4:	b8 03 00 00 00       	mov    $0x3,%eax
  8009e9:	e8 12 ff ff ff       	call   800900 <fsipc>
  8009ee:	89 c3                	mov    %eax,%ebx
  8009f0:	85 c0                	test   %eax,%eax
  8009f2:	78 4b                	js     800a3f <devfile_read+0x79>
		return r;
	assert(r <= n);
  8009f4:	39 c6                	cmp    %eax,%esi
  8009f6:	73 16                	jae    800a0e <devfile_read+0x48>
  8009f8:	68 70 1e 80 00       	push   $0x801e70
  8009fd:	68 77 1e 80 00       	push   $0x801e77
  800a02:	6a 7d                	push   $0x7d
  800a04:	68 8c 1e 80 00       	push   $0x801e8c
  800a09:	e8 ce 05 00 00       	call   800fdc <_panic>
	assert(r <= PGSIZE);
  800a0e:	3d 00 10 00 00       	cmp    $0x1000,%eax
  800a13:	7e 16                	jle    800a2b <devfile_read+0x65>
  800a15:	68 97 1e 80 00       	push   $0x801e97
  800a1a:	68 77 1e 80 00       	push   $0x801e77
  800a1f:	6a 7e                	push   $0x7e
  800a21:	68 8c 1e 80 00       	push   $0x801e8c
  800a26:	e8 b1 05 00 00       	call   800fdc <_panic>
	memmove(buf, &fsipcbuf, r);
  800a2b:	83 ec 04             	sub    $0x4,%esp
  800a2e:	50                   	push   %eax
  800a2f:	68 00 50 80 00       	push   $0x805000
  800a34:	ff 75 0c             	pushl  0xc(%ebp)
  800a37:	e8 ef 0d 00 00       	call   80182b <memmove>
	return r;
  800a3c:	83 c4 10             	add    $0x10,%esp
}
  800a3f:	89 d8                	mov    %ebx,%eax
  800a41:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800a44:	5b                   	pop    %ebx
  800a45:	5e                   	pop    %esi
  800a46:	c9                   	leave  
  800a47:	c3                   	ret    

00800a48 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  800a48:	55                   	push   %ebp
  800a49:	89 e5                	mov    %esp,%ebp
  800a4b:	56                   	push   %esi
  800a4c:	53                   	push   %ebx
  800a4d:	83 ec 1c             	sub    $0x1c,%esp
  800a50:	8b 75 08             	mov    0x8(%ebp),%esi
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  800a53:	56                   	push   %esi
  800a54:	e8 bf 0b 00 00       	call   801618 <strlen>
  800a59:	83 c4 10             	add    $0x10,%esp
  800a5c:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  800a61:	7f 65                	jg     800ac8 <open+0x80>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800a63:	83 ec 0c             	sub    $0xc,%esp
  800a66:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800a69:	50                   	push   %eax
  800a6a:	e8 e1 f8 ff ff       	call   800350 <fd_alloc>
  800a6f:	89 c3                	mov    %eax,%ebx
  800a71:	83 c4 10             	add    $0x10,%esp
  800a74:	85 c0                	test   %eax,%eax
  800a76:	78 55                	js     800acd <open+0x85>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  800a78:	83 ec 08             	sub    $0x8,%esp
  800a7b:	56                   	push   %esi
  800a7c:	68 00 50 80 00       	push   $0x805000
  800a81:	e8 e4 0b 00 00       	call   80166a <strcpy>
	fsipcbuf.open.req_omode = mode;
  800a86:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a89:	a3 00 54 80 00       	mov    %eax,0x805400



	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  800a8e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800a91:	b8 01 00 00 00       	mov    $0x1,%eax
  800a96:	e8 65 fe ff ff       	call   800900 <fsipc>
  800a9b:	89 c3                	mov    %eax,%ebx
  800a9d:	83 c4 10             	add    $0x10,%esp
  800aa0:	85 c0                	test   %eax,%eax
  800aa2:	79 12                	jns    800ab6 <open+0x6e>
		fd_close(fd, 0);
  800aa4:	83 ec 08             	sub    $0x8,%esp
  800aa7:	6a 00                	push   $0x0
  800aa9:	ff 75 f4             	pushl  -0xc(%ebp)
  800aac:	e8 ce f9 ff ff       	call   80047f <fd_close>
		return r;
  800ab1:	83 c4 10             	add    $0x10,%esp
  800ab4:	eb 17                	jmp    800acd <open+0x85>
	}

	return fd2num(fd);
  800ab6:	83 ec 0c             	sub    $0xc,%esp
  800ab9:	ff 75 f4             	pushl  -0xc(%ebp)
  800abc:	e8 67 f8 ff ff       	call   800328 <fd2num>
  800ac1:	89 c3                	mov    %eax,%ebx
  800ac3:	83 c4 10             	add    $0x10,%esp
  800ac6:	eb 05                	jmp    800acd <open+0x85>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  800ac8:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  800acd:	89 d8                	mov    %ebx,%eax
  800acf:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800ad2:	5b                   	pop    %ebx
  800ad3:	5e                   	pop    %esi
  800ad4:	c9                   	leave  
  800ad5:	c3                   	ret    
	...

00800ad8 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  800ad8:	55                   	push   %ebp
  800ad9:	89 e5                	mov    %esp,%ebp
  800adb:	56                   	push   %esi
  800adc:	53                   	push   %ebx
  800add:	8b 75 0c             	mov    0xc(%ebp),%esi
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  800ae0:	83 ec 0c             	sub    $0xc,%esp
  800ae3:	ff 75 08             	pushl  0x8(%ebp)
  800ae6:	e8 4d f8 ff ff       	call   800338 <fd2data>
  800aeb:	89 c3                	mov    %eax,%ebx
	strcpy(stat->st_name, "<pipe>");
  800aed:	83 c4 08             	add    $0x8,%esp
  800af0:	68 a3 1e 80 00       	push   $0x801ea3
  800af5:	56                   	push   %esi
  800af6:	e8 6f 0b 00 00       	call   80166a <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  800afb:	8b 43 04             	mov    0x4(%ebx),%eax
  800afe:	2b 03                	sub    (%ebx),%eax
  800b00:	89 86 80 00 00 00    	mov    %eax,0x80(%esi)
	stat->st_isdir = 0;
  800b06:	c7 86 84 00 00 00 00 	movl   $0x0,0x84(%esi)
  800b0d:	00 00 00 
	stat->st_dev = &devpipe;
  800b10:	c7 86 88 00 00 00 24 	movl   $0x803024,0x88(%esi)
  800b17:	30 80 00 
	return 0;
}
  800b1a:	b8 00 00 00 00       	mov    $0x0,%eax
  800b1f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800b22:	5b                   	pop    %ebx
  800b23:	5e                   	pop    %esi
  800b24:	c9                   	leave  
  800b25:	c3                   	ret    

00800b26 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  800b26:	55                   	push   %ebp
  800b27:	89 e5                	mov    %esp,%ebp
  800b29:	53                   	push   %ebx
  800b2a:	83 ec 0c             	sub    $0xc,%esp
  800b2d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  800b30:	53                   	push   %ebx
  800b31:	6a 00                	push   $0x0
  800b33:	e8 d2 f6 ff ff       	call   80020a <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  800b38:	89 1c 24             	mov    %ebx,(%esp)
  800b3b:	e8 f8 f7 ff ff       	call   800338 <fd2data>
  800b40:	83 c4 08             	add    $0x8,%esp
  800b43:	50                   	push   %eax
  800b44:	6a 00                	push   $0x0
  800b46:	e8 bf f6 ff ff       	call   80020a <sys_page_unmap>
}
  800b4b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800b4e:	c9                   	leave  
  800b4f:	c3                   	ret    

00800b50 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  800b50:	55                   	push   %ebp
  800b51:	89 e5                	mov    %esp,%ebp
  800b53:	57                   	push   %edi
  800b54:	56                   	push   %esi
  800b55:	53                   	push   %ebx
  800b56:	83 ec 1c             	sub    $0x1c,%esp
  800b59:	89 c7                	mov    %eax,%edi
  800b5b:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  800b5e:	a1 04 40 80 00       	mov    0x804004,%eax
  800b63:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  800b66:	83 ec 0c             	sub    $0xc,%esp
  800b69:	57                   	push   %edi
  800b6a:	e8 a1 0f 00 00       	call   801b10 <pageref>
  800b6f:	89 c6                	mov    %eax,%esi
  800b71:	83 c4 04             	add    $0x4,%esp
  800b74:	ff 75 e4             	pushl  -0x1c(%ebp)
  800b77:	e8 94 0f 00 00       	call   801b10 <pageref>
  800b7c:	83 c4 10             	add    $0x10,%esp
  800b7f:	39 c6                	cmp    %eax,%esi
  800b81:	0f 94 c0             	sete   %al
  800b84:	0f b6 c0             	movzbl %al,%eax
		nn = thisenv->env_runs;
  800b87:	8b 15 04 40 80 00    	mov    0x804004,%edx
  800b8d:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  800b90:	39 cb                	cmp    %ecx,%ebx
  800b92:	75 08                	jne    800b9c <_pipeisclosed+0x4c>
			return ret;
		if (n != nn && ret == 1)
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
	}
}
  800b94:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b97:	5b                   	pop    %ebx
  800b98:	5e                   	pop    %esi
  800b99:	5f                   	pop    %edi
  800b9a:	c9                   	leave  
  800b9b:	c3                   	ret    
		n = thisenv->env_runs;
		ret = pageref(fd) == pageref(p);
		nn = thisenv->env_runs;
		if (n == nn)
			return ret;
		if (n != nn && ret == 1)
  800b9c:	83 f8 01             	cmp    $0x1,%eax
  800b9f:	75 bd                	jne    800b5e <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  800ba1:	8b 42 58             	mov    0x58(%edx),%eax
  800ba4:	6a 01                	push   $0x1
  800ba6:	50                   	push   %eax
  800ba7:	53                   	push   %ebx
  800ba8:	68 aa 1e 80 00       	push   $0x801eaa
  800bad:	e8 02 05 00 00       	call   8010b4 <cprintf>
  800bb2:	83 c4 10             	add    $0x10,%esp
  800bb5:	eb a7                	jmp    800b5e <_pipeisclosed+0xe>

00800bb7 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  800bb7:	55                   	push   %ebp
  800bb8:	89 e5                	mov    %esp,%ebp
  800bba:	57                   	push   %edi
  800bbb:	56                   	push   %esi
  800bbc:	53                   	push   %ebx
  800bbd:	83 ec 28             	sub    $0x28,%esp
  800bc0:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  800bc3:	56                   	push   %esi
  800bc4:	e8 6f f7 ff ff       	call   800338 <fd2data>
  800bc9:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800bcb:	83 c4 10             	add    $0x10,%esp
  800bce:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800bd2:	75 4a                	jne    800c1e <devpipe_write+0x67>
  800bd4:	bf 00 00 00 00       	mov    $0x0,%edi
  800bd9:	eb 56                	jmp    800c31 <devpipe_write+0x7a>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  800bdb:	89 da                	mov    %ebx,%edx
  800bdd:	89 f0                	mov    %esi,%eax
  800bdf:	e8 6c ff ff ff       	call   800b50 <_pipeisclosed>
  800be4:	85 c0                	test   %eax,%eax
  800be6:	75 4d                	jne    800c35 <devpipe_write+0x7e>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  800be8:	e8 ac f5 ff ff       	call   800199 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  800bed:	8b 43 04             	mov    0x4(%ebx),%eax
  800bf0:	8b 13                	mov    (%ebx),%edx
  800bf2:	83 c2 20             	add    $0x20,%edx
  800bf5:	39 d0                	cmp    %edx,%eax
  800bf7:	73 e2                	jae    800bdb <devpipe_write+0x24>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  800bf9:	89 c2                	mov    %eax,%edx
  800bfb:	81 e2 1f 00 00 80    	and    $0x8000001f,%edx
  800c01:	79 05                	jns    800c08 <devpipe_write+0x51>
  800c03:	4a                   	dec    %edx
  800c04:	83 ca e0             	or     $0xffffffe0,%edx
  800c07:	42                   	inc    %edx
  800c08:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c0b:	8a 0c 39             	mov    (%ecx,%edi,1),%cl
  800c0e:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  800c12:	40                   	inc    %eax
  800c13:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800c16:	47                   	inc    %edi
  800c17:	39 7d 10             	cmp    %edi,0x10(%ebp)
  800c1a:	77 07                	ja     800c23 <devpipe_write+0x6c>
  800c1c:	eb 13                	jmp    800c31 <devpipe_write+0x7a>
  800c1e:	bf 00 00 00 00       	mov    $0x0,%edi
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  800c23:	8b 43 04             	mov    0x4(%ebx),%eax
  800c26:	8b 13                	mov    (%ebx),%edx
  800c28:	83 c2 20             	add    $0x20,%edx
  800c2b:	39 d0                	cmp    %edx,%eax
  800c2d:	73 ac                	jae    800bdb <devpipe_write+0x24>
  800c2f:	eb c8                	jmp    800bf9 <devpipe_write+0x42>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  800c31:	89 f8                	mov    %edi,%eax
  800c33:	eb 05                	jmp    800c3a <devpipe_write+0x83>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  800c35:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  800c3a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c3d:	5b                   	pop    %ebx
  800c3e:	5e                   	pop    %esi
  800c3f:	5f                   	pop    %edi
  800c40:	c9                   	leave  
  800c41:	c3                   	ret    

00800c42 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  800c42:	55                   	push   %ebp
  800c43:	89 e5                	mov    %esp,%ebp
  800c45:	57                   	push   %edi
  800c46:	56                   	push   %esi
  800c47:	53                   	push   %ebx
  800c48:	83 ec 18             	sub    $0x18,%esp
  800c4b:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  800c4e:	57                   	push   %edi
  800c4f:	e8 e4 f6 ff ff       	call   800338 <fd2data>
  800c54:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800c56:	83 c4 10             	add    $0x10,%esp
  800c59:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800c5d:	75 44                	jne    800ca3 <devpipe_read+0x61>
  800c5f:	be 00 00 00 00       	mov    $0x0,%esi
  800c64:	eb 4f                	jmp    800cb5 <devpipe_read+0x73>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
				return i;
  800c66:	89 f0                	mov    %esi,%eax
  800c68:	eb 54                	jmp    800cbe <devpipe_read+0x7c>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  800c6a:	89 da                	mov    %ebx,%edx
  800c6c:	89 f8                	mov    %edi,%eax
  800c6e:	e8 dd fe ff ff       	call   800b50 <_pipeisclosed>
  800c73:	85 c0                	test   %eax,%eax
  800c75:	75 42                	jne    800cb9 <devpipe_read+0x77>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  800c77:	e8 1d f5 ff ff       	call   800199 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  800c7c:	8b 03                	mov    (%ebx),%eax
  800c7e:	3b 43 04             	cmp    0x4(%ebx),%eax
  800c81:	74 e7                	je     800c6a <devpipe_read+0x28>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  800c83:	25 1f 00 00 80       	and    $0x8000001f,%eax
  800c88:	79 05                	jns    800c8f <devpipe_read+0x4d>
  800c8a:	48                   	dec    %eax
  800c8b:	83 c8 e0             	or     $0xffffffe0,%eax
  800c8e:	40                   	inc    %eax
  800c8f:	8a 44 03 08          	mov    0x8(%ebx,%eax,1),%al
  800c93:	8b 55 0c             	mov    0xc(%ebp),%edx
  800c96:	88 04 32             	mov    %al,(%edx,%esi,1)
		p->p_rpos++;
  800c99:	ff 03                	incl   (%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800c9b:	46                   	inc    %esi
  800c9c:	39 75 10             	cmp    %esi,0x10(%ebp)
  800c9f:	77 07                	ja     800ca8 <devpipe_read+0x66>
  800ca1:	eb 12                	jmp    800cb5 <devpipe_read+0x73>
  800ca3:	be 00 00 00 00       	mov    $0x0,%esi
		while (p->p_rpos == p->p_wpos) {
  800ca8:	8b 03                	mov    (%ebx),%eax
  800caa:	3b 43 04             	cmp    0x4(%ebx),%eax
  800cad:	75 d4                	jne    800c83 <devpipe_read+0x41>
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  800caf:	85 f6                	test   %esi,%esi
  800cb1:	75 b3                	jne    800c66 <devpipe_read+0x24>
  800cb3:	eb b5                	jmp    800c6a <devpipe_read+0x28>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  800cb5:	89 f0                	mov    %esi,%eax
  800cb7:	eb 05                	jmp    800cbe <devpipe_read+0x7c>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  800cb9:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  800cbe:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cc1:	5b                   	pop    %ebx
  800cc2:	5e                   	pop    %esi
  800cc3:	5f                   	pop    %edi
  800cc4:	c9                   	leave  
  800cc5:	c3                   	ret    

00800cc6 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  800cc6:	55                   	push   %ebp
  800cc7:	89 e5                	mov    %esp,%ebp
  800cc9:	57                   	push   %edi
  800cca:	56                   	push   %esi
  800ccb:	53                   	push   %ebx
  800ccc:	83 ec 28             	sub    $0x28,%esp
  800ccf:	8b 7d 08             	mov    0x8(%ebp),%edi
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  800cd2:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800cd5:	50                   	push   %eax
  800cd6:	e8 75 f6 ff ff       	call   800350 <fd_alloc>
  800cdb:	89 c3                	mov    %eax,%ebx
  800cdd:	83 c4 10             	add    $0x10,%esp
  800ce0:	85 c0                	test   %eax,%eax
  800ce2:	0f 88 24 01 00 00    	js     800e0c <pipe+0x146>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800ce8:	83 ec 04             	sub    $0x4,%esp
  800ceb:	68 07 04 00 00       	push   $0x407
  800cf0:	ff 75 e4             	pushl  -0x1c(%ebp)
  800cf3:	6a 00                	push   $0x0
  800cf5:	e8 c6 f4 ff ff       	call   8001c0 <sys_page_alloc>
  800cfa:	89 c3                	mov    %eax,%ebx
  800cfc:	83 c4 10             	add    $0x10,%esp
  800cff:	85 c0                	test   %eax,%eax
  800d01:	0f 88 05 01 00 00    	js     800e0c <pipe+0x146>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  800d07:	83 ec 0c             	sub    $0xc,%esp
  800d0a:	8d 45 e0             	lea    -0x20(%ebp),%eax
  800d0d:	50                   	push   %eax
  800d0e:	e8 3d f6 ff ff       	call   800350 <fd_alloc>
  800d13:	89 c3                	mov    %eax,%ebx
  800d15:	83 c4 10             	add    $0x10,%esp
  800d18:	85 c0                	test   %eax,%eax
  800d1a:	0f 88 dc 00 00 00    	js     800dfc <pipe+0x136>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800d20:	83 ec 04             	sub    $0x4,%esp
  800d23:	68 07 04 00 00       	push   $0x407
  800d28:	ff 75 e0             	pushl  -0x20(%ebp)
  800d2b:	6a 00                	push   $0x0
  800d2d:	e8 8e f4 ff ff       	call   8001c0 <sys_page_alloc>
  800d32:	89 c3                	mov    %eax,%ebx
  800d34:	83 c4 10             	add    $0x10,%esp
  800d37:	85 c0                	test   %eax,%eax
  800d39:	0f 88 bd 00 00 00    	js     800dfc <pipe+0x136>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  800d3f:	83 ec 0c             	sub    $0xc,%esp
  800d42:	ff 75 e4             	pushl  -0x1c(%ebp)
  800d45:	e8 ee f5 ff ff       	call   800338 <fd2data>
  800d4a:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800d4c:	83 c4 0c             	add    $0xc,%esp
  800d4f:	68 07 04 00 00       	push   $0x407
  800d54:	50                   	push   %eax
  800d55:	6a 00                	push   $0x0
  800d57:	e8 64 f4 ff ff       	call   8001c0 <sys_page_alloc>
  800d5c:	89 c3                	mov    %eax,%ebx
  800d5e:	83 c4 10             	add    $0x10,%esp
  800d61:	85 c0                	test   %eax,%eax
  800d63:	0f 88 83 00 00 00    	js     800dec <pipe+0x126>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800d69:	83 ec 0c             	sub    $0xc,%esp
  800d6c:	ff 75 e0             	pushl  -0x20(%ebp)
  800d6f:	e8 c4 f5 ff ff       	call   800338 <fd2data>
  800d74:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  800d7b:	50                   	push   %eax
  800d7c:	6a 00                	push   $0x0
  800d7e:	56                   	push   %esi
  800d7f:	6a 00                	push   $0x0
  800d81:	e8 5e f4 ff ff       	call   8001e4 <sys_page_map>
  800d86:	89 c3                	mov    %eax,%ebx
  800d88:	83 c4 20             	add    $0x20,%esp
  800d8b:	85 c0                	test   %eax,%eax
  800d8d:	78 4f                	js     800dde <pipe+0x118>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  800d8f:	8b 15 24 30 80 00    	mov    0x803024,%edx
  800d95:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800d98:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  800d9a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800d9d:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  800da4:	8b 15 24 30 80 00    	mov    0x803024,%edx
  800daa:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800dad:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  800daf:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800db2:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  800db9:	83 ec 0c             	sub    $0xc,%esp
  800dbc:	ff 75 e4             	pushl  -0x1c(%ebp)
  800dbf:	e8 64 f5 ff ff       	call   800328 <fd2num>
  800dc4:	89 07                	mov    %eax,(%edi)
	pfd[1] = fd2num(fd1);
  800dc6:	83 c4 04             	add    $0x4,%esp
  800dc9:	ff 75 e0             	pushl  -0x20(%ebp)
  800dcc:	e8 57 f5 ff ff       	call   800328 <fd2num>
  800dd1:	89 47 04             	mov    %eax,0x4(%edi)
	return 0;
  800dd4:	83 c4 10             	add    $0x10,%esp
  800dd7:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ddc:	eb 2e                	jmp    800e0c <pipe+0x146>

    err3:
	sys_page_unmap(0, va);
  800dde:	83 ec 08             	sub    $0x8,%esp
  800de1:	56                   	push   %esi
  800de2:	6a 00                	push   $0x0
  800de4:	e8 21 f4 ff ff       	call   80020a <sys_page_unmap>
  800de9:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  800dec:	83 ec 08             	sub    $0x8,%esp
  800def:	ff 75 e0             	pushl  -0x20(%ebp)
  800df2:	6a 00                	push   $0x0
  800df4:	e8 11 f4 ff ff       	call   80020a <sys_page_unmap>
  800df9:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  800dfc:	83 ec 08             	sub    $0x8,%esp
  800dff:	ff 75 e4             	pushl  -0x1c(%ebp)
  800e02:	6a 00                	push   $0x0
  800e04:	e8 01 f4 ff ff       	call   80020a <sys_page_unmap>
  800e09:	83 c4 10             	add    $0x10,%esp
    err:
	return r;
}
  800e0c:	89 d8                	mov    %ebx,%eax
  800e0e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e11:	5b                   	pop    %ebx
  800e12:	5e                   	pop    %esi
  800e13:	5f                   	pop    %edi
  800e14:	c9                   	leave  
  800e15:	c3                   	ret    

00800e16 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  800e16:	55                   	push   %ebp
  800e17:	89 e5                	mov    %esp,%ebp
  800e19:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800e1c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800e1f:	50                   	push   %eax
  800e20:	ff 75 08             	pushl  0x8(%ebp)
  800e23:	e8 9b f5 ff ff       	call   8003c3 <fd_lookup>
  800e28:	83 c4 10             	add    $0x10,%esp
  800e2b:	85 c0                	test   %eax,%eax
  800e2d:	78 18                	js     800e47 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  800e2f:	83 ec 0c             	sub    $0xc,%esp
  800e32:	ff 75 f4             	pushl  -0xc(%ebp)
  800e35:	e8 fe f4 ff ff       	call   800338 <fd2data>
	return _pipeisclosed(fd, p);
  800e3a:	89 c2                	mov    %eax,%edx
  800e3c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800e3f:	e8 0c fd ff ff       	call   800b50 <_pipeisclosed>
  800e44:	83 c4 10             	add    $0x10,%esp
}
  800e47:	c9                   	leave  
  800e48:	c3                   	ret    
  800e49:	00 00                	add    %al,(%eax)
	...

00800e4c <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  800e4c:	55                   	push   %ebp
  800e4d:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  800e4f:	b8 00 00 00 00       	mov    $0x0,%eax
  800e54:	c9                   	leave  
  800e55:	c3                   	ret    

00800e56 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  800e56:	55                   	push   %ebp
  800e57:	89 e5                	mov    %esp,%ebp
  800e59:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  800e5c:	68 c2 1e 80 00       	push   $0x801ec2
  800e61:	ff 75 0c             	pushl  0xc(%ebp)
  800e64:	e8 01 08 00 00       	call   80166a <strcpy>
	return 0;
}
  800e69:	b8 00 00 00 00       	mov    $0x0,%eax
  800e6e:	c9                   	leave  
  800e6f:	c3                   	ret    

00800e70 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  800e70:	55                   	push   %ebp
  800e71:	89 e5                	mov    %esp,%ebp
  800e73:	57                   	push   %edi
  800e74:	56                   	push   %esi
  800e75:	53                   	push   %ebx
  800e76:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800e7c:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800e80:	74 45                	je     800ec7 <devcons_write+0x57>
  800e82:	b8 00 00 00 00       	mov    $0x0,%eax
  800e87:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  800e8c:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  800e92:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e95:	29 c3                	sub    %eax,%ebx
		if (m > sizeof(buf) - 1)
  800e97:	83 fb 7f             	cmp    $0x7f,%ebx
  800e9a:	76 05                	jbe    800ea1 <devcons_write+0x31>
			m = sizeof(buf) - 1;
  800e9c:	bb 7f 00 00 00       	mov    $0x7f,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  800ea1:	83 ec 04             	sub    $0x4,%esp
  800ea4:	53                   	push   %ebx
  800ea5:	03 45 0c             	add    0xc(%ebp),%eax
  800ea8:	50                   	push   %eax
  800ea9:	57                   	push   %edi
  800eaa:	e8 7c 09 00 00       	call   80182b <memmove>
		sys_cputs(buf, m);
  800eaf:	83 c4 08             	add    $0x8,%esp
  800eb2:	53                   	push   %ebx
  800eb3:	57                   	push   %edi
  800eb4:	e8 50 f2 ff ff       	call   800109 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800eb9:	01 de                	add    %ebx,%esi
  800ebb:	89 f0                	mov    %esi,%eax
  800ebd:	83 c4 10             	add    $0x10,%esp
  800ec0:	3b 75 10             	cmp    0x10(%ebp),%esi
  800ec3:	72 cd                	jb     800e92 <devcons_write+0x22>
  800ec5:	eb 05                	jmp    800ecc <devcons_write+0x5c>
  800ec7:	be 00 00 00 00       	mov    $0x0,%esi
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  800ecc:	89 f0                	mov    %esi,%eax
  800ece:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ed1:	5b                   	pop    %ebx
  800ed2:	5e                   	pop    %esi
  800ed3:	5f                   	pop    %edi
  800ed4:	c9                   	leave  
  800ed5:	c3                   	ret    

00800ed6 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  800ed6:	55                   	push   %ebp
  800ed7:	89 e5                	mov    %esp,%ebp
  800ed9:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
  800edc:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800ee0:	75 07                	jne    800ee9 <devcons_read+0x13>
  800ee2:	eb 25                	jmp    800f09 <devcons_read+0x33>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  800ee4:	e8 b0 f2 ff ff       	call   800199 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  800ee9:	e8 41 f2 ff ff       	call   80012f <sys_cgetc>
  800eee:	85 c0                	test   %eax,%eax
  800ef0:	74 f2                	je     800ee4 <devcons_read+0xe>
  800ef2:	89 c2                	mov    %eax,%edx
		sys_yield();
	if (c < 0)
  800ef4:	85 c0                	test   %eax,%eax
  800ef6:	78 1d                	js     800f15 <devcons_read+0x3f>
		return c;
	if (c == 0x04)	// ctl-d is eof
  800ef8:	83 f8 04             	cmp    $0x4,%eax
  800efb:	74 13                	je     800f10 <devcons_read+0x3a>
		return 0;
	*(char*)vbuf = c;
  800efd:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f00:	88 10                	mov    %dl,(%eax)
	return 1;
  800f02:	b8 01 00 00 00       	mov    $0x1,%eax
  800f07:	eb 0c                	jmp    800f15 <devcons_read+0x3f>
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
		return 0;
  800f09:	b8 00 00 00 00       	mov    $0x0,%eax
  800f0e:	eb 05                	jmp    800f15 <devcons_read+0x3f>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  800f10:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  800f15:	c9                   	leave  
  800f16:	c3                   	ret    

00800f17 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  800f17:	55                   	push   %ebp
  800f18:	89 e5                	mov    %esp,%ebp
  800f1a:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  800f1d:	8b 45 08             	mov    0x8(%ebp),%eax
  800f20:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  800f23:	6a 01                	push   $0x1
  800f25:	8d 45 f7             	lea    -0x9(%ebp),%eax
  800f28:	50                   	push   %eax
  800f29:	e8 db f1 ff ff       	call   800109 <sys_cputs>
  800f2e:	83 c4 10             	add    $0x10,%esp
}
  800f31:	c9                   	leave  
  800f32:	c3                   	ret    

00800f33 <getchar>:

int
getchar(void)
{
  800f33:	55                   	push   %ebp
  800f34:	89 e5                	mov    %esp,%ebp
  800f36:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  800f39:	6a 01                	push   $0x1
  800f3b:	8d 45 f7             	lea    -0x9(%ebp),%eax
  800f3e:	50                   	push   %eax
  800f3f:	6a 00                	push   $0x0
  800f41:	e8 fe f6 ff ff       	call   800644 <read>
	if (r < 0)
  800f46:	83 c4 10             	add    $0x10,%esp
  800f49:	85 c0                	test   %eax,%eax
  800f4b:	78 0f                	js     800f5c <getchar+0x29>
		return r;
	if (r < 1)
  800f4d:	85 c0                	test   %eax,%eax
  800f4f:	7e 06                	jle    800f57 <getchar+0x24>
		return -E_EOF;
	return c;
  800f51:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  800f55:	eb 05                	jmp    800f5c <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  800f57:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  800f5c:	c9                   	leave  
  800f5d:	c3                   	ret    

00800f5e <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  800f5e:	55                   	push   %ebp
  800f5f:	89 e5                	mov    %esp,%ebp
  800f61:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800f64:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800f67:	50                   	push   %eax
  800f68:	ff 75 08             	pushl  0x8(%ebp)
  800f6b:	e8 53 f4 ff ff       	call   8003c3 <fd_lookup>
  800f70:	83 c4 10             	add    $0x10,%esp
  800f73:	85 c0                	test   %eax,%eax
  800f75:	78 11                	js     800f88 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  800f77:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800f7a:	8b 15 40 30 80 00    	mov    0x803040,%edx
  800f80:	39 10                	cmp    %edx,(%eax)
  800f82:	0f 94 c0             	sete   %al
  800f85:	0f b6 c0             	movzbl %al,%eax
}
  800f88:	c9                   	leave  
  800f89:	c3                   	ret    

00800f8a <opencons>:

int
opencons(void)
{
  800f8a:	55                   	push   %ebp
  800f8b:	89 e5                	mov    %esp,%ebp
  800f8d:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  800f90:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800f93:	50                   	push   %eax
  800f94:	e8 b7 f3 ff ff       	call   800350 <fd_alloc>
  800f99:	83 c4 10             	add    $0x10,%esp
  800f9c:	85 c0                	test   %eax,%eax
  800f9e:	78 3a                	js     800fda <opencons+0x50>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  800fa0:	83 ec 04             	sub    $0x4,%esp
  800fa3:	68 07 04 00 00       	push   $0x407
  800fa8:	ff 75 f4             	pushl  -0xc(%ebp)
  800fab:	6a 00                	push   $0x0
  800fad:	e8 0e f2 ff ff       	call   8001c0 <sys_page_alloc>
  800fb2:	83 c4 10             	add    $0x10,%esp
  800fb5:	85 c0                	test   %eax,%eax
  800fb7:	78 21                	js     800fda <opencons+0x50>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  800fb9:	8b 15 40 30 80 00    	mov    0x803040,%edx
  800fbf:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800fc2:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  800fc4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800fc7:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  800fce:	83 ec 0c             	sub    $0xc,%esp
  800fd1:	50                   	push   %eax
  800fd2:	e8 51 f3 ff ff       	call   800328 <fd2num>
  800fd7:	83 c4 10             	add    $0x10,%esp
}
  800fda:	c9                   	leave  
  800fdb:	c3                   	ret    

00800fdc <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800fdc:	55                   	push   %ebp
  800fdd:	89 e5                	mov    %esp,%ebp
  800fdf:	56                   	push   %esi
  800fe0:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800fe1:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800fe4:	8b 1d 04 30 80 00    	mov    0x803004,%ebx
  800fea:	e8 86 f1 ff ff       	call   800175 <sys_getenvid>
  800fef:	83 ec 0c             	sub    $0xc,%esp
  800ff2:	ff 75 0c             	pushl  0xc(%ebp)
  800ff5:	ff 75 08             	pushl  0x8(%ebp)
  800ff8:	53                   	push   %ebx
  800ff9:	50                   	push   %eax
  800ffa:	68 d0 1e 80 00       	push   $0x801ed0
  800fff:	e8 b0 00 00 00       	call   8010b4 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801004:	83 c4 18             	add    $0x18,%esp
  801007:	56                   	push   %esi
  801008:	ff 75 10             	pushl  0x10(%ebp)
  80100b:	e8 53 00 00 00       	call   801063 <vcprintf>
	cprintf("\n");
  801010:	c7 04 24 bb 1e 80 00 	movl   $0x801ebb,(%esp)
  801017:	e8 98 00 00 00       	call   8010b4 <cprintf>
  80101c:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80101f:	cc                   	int3   
  801020:	eb fd                	jmp    80101f <_panic+0x43>
	...

00801024 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  801024:	55                   	push   %ebp
  801025:	89 e5                	mov    %esp,%ebp
  801027:	53                   	push   %ebx
  801028:	83 ec 04             	sub    $0x4,%esp
  80102b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80102e:	8b 03                	mov    (%ebx),%eax
  801030:	8b 55 08             	mov    0x8(%ebp),%edx
  801033:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  801037:	40                   	inc    %eax
  801038:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  80103a:	3d ff 00 00 00       	cmp    $0xff,%eax
  80103f:	75 1a                	jne    80105b <putch+0x37>
		sys_cputs(b->buf, b->idx);
  801041:	83 ec 08             	sub    $0x8,%esp
  801044:	68 ff 00 00 00       	push   $0xff
  801049:	8d 43 08             	lea    0x8(%ebx),%eax
  80104c:	50                   	push   %eax
  80104d:	e8 b7 f0 ff ff       	call   800109 <sys_cputs>
		b->idx = 0;
  801052:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801058:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  80105b:	ff 43 04             	incl   0x4(%ebx)
}
  80105e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801061:	c9                   	leave  
  801062:	c3                   	ret    

00801063 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  801063:	55                   	push   %ebp
  801064:	89 e5                	mov    %esp,%ebp
  801066:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  80106c:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  801073:	00 00 00 
	b.cnt = 0;
  801076:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80107d:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  801080:	ff 75 0c             	pushl  0xc(%ebp)
  801083:	ff 75 08             	pushl  0x8(%ebp)
  801086:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80108c:	50                   	push   %eax
  80108d:	68 24 10 80 00       	push   $0x801024
  801092:	e8 82 01 00 00       	call   801219 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  801097:	83 c4 08             	add    $0x8,%esp
  80109a:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8010a0:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8010a6:	50                   	push   %eax
  8010a7:	e8 5d f0 ff ff       	call   800109 <sys_cputs>

	return b.cnt;
}
  8010ac:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8010b2:	c9                   	leave  
  8010b3:	c3                   	ret    

008010b4 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8010b4:	55                   	push   %ebp
  8010b5:	89 e5                	mov    %esp,%ebp
  8010b7:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8010ba:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8010bd:	50                   	push   %eax
  8010be:	ff 75 08             	pushl  0x8(%ebp)
  8010c1:	e8 9d ff ff ff       	call   801063 <vcprintf>
	va_end(ap);

	return cnt;
}
  8010c6:	c9                   	leave  
  8010c7:	c3                   	ret    

008010c8 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8010c8:	55                   	push   %ebp
  8010c9:	89 e5                	mov    %esp,%ebp
  8010cb:	57                   	push   %edi
  8010cc:	56                   	push   %esi
  8010cd:	53                   	push   %ebx
  8010ce:	83 ec 2c             	sub    $0x2c,%esp
  8010d1:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8010d4:	89 d6                	mov    %edx,%esi
  8010d6:	8b 45 08             	mov    0x8(%ebp),%eax
  8010d9:	8b 55 0c             	mov    0xc(%ebp),%edx
  8010dc:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8010df:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8010e2:	8b 45 10             	mov    0x10(%ebp),%eax
  8010e5:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8010e8:	8b 7d 18             	mov    0x18(%ebp),%edi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8010eb:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8010ee:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  8010f5:	39 55 d4             	cmp    %edx,-0x2c(%ebp)
  8010f8:	72 0c                	jb     801106 <printnum+0x3e>
  8010fa:	3b 45 d8             	cmp    -0x28(%ebp),%eax
  8010fd:	76 07                	jbe    801106 <printnum+0x3e>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8010ff:	4b                   	dec    %ebx
  801100:	85 db                	test   %ebx,%ebx
  801102:	7f 31                	jg     801135 <printnum+0x6d>
  801104:	eb 3f                	jmp    801145 <printnum+0x7d>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  801106:	83 ec 0c             	sub    $0xc,%esp
  801109:	57                   	push   %edi
  80110a:	4b                   	dec    %ebx
  80110b:	53                   	push   %ebx
  80110c:	50                   	push   %eax
  80110d:	83 ec 08             	sub    $0x8,%esp
  801110:	ff 75 d4             	pushl  -0x2c(%ebp)
  801113:	ff 75 d0             	pushl  -0x30(%ebp)
  801116:	ff 75 dc             	pushl  -0x24(%ebp)
  801119:	ff 75 d8             	pushl  -0x28(%ebp)
  80111c:	e8 33 0a 00 00       	call   801b54 <__udivdi3>
  801121:	83 c4 18             	add    $0x18,%esp
  801124:	52                   	push   %edx
  801125:	50                   	push   %eax
  801126:	89 f2                	mov    %esi,%edx
  801128:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80112b:	e8 98 ff ff ff       	call   8010c8 <printnum>
  801130:	83 c4 20             	add    $0x20,%esp
  801133:	eb 10                	jmp    801145 <printnum+0x7d>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  801135:	83 ec 08             	sub    $0x8,%esp
  801138:	56                   	push   %esi
  801139:	57                   	push   %edi
  80113a:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80113d:	4b                   	dec    %ebx
  80113e:	83 c4 10             	add    $0x10,%esp
  801141:	85 db                	test   %ebx,%ebx
  801143:	7f f0                	jg     801135 <printnum+0x6d>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  801145:	83 ec 08             	sub    $0x8,%esp
  801148:	56                   	push   %esi
  801149:	83 ec 04             	sub    $0x4,%esp
  80114c:	ff 75 d4             	pushl  -0x2c(%ebp)
  80114f:	ff 75 d0             	pushl  -0x30(%ebp)
  801152:	ff 75 dc             	pushl  -0x24(%ebp)
  801155:	ff 75 d8             	pushl  -0x28(%ebp)
  801158:	e8 13 0b 00 00       	call   801c70 <__umoddi3>
  80115d:	83 c4 14             	add    $0x14,%esp
  801160:	0f be 80 f3 1e 80 00 	movsbl 0x801ef3(%eax),%eax
  801167:	50                   	push   %eax
  801168:	ff 55 e4             	call   *-0x1c(%ebp)
  80116b:	83 c4 10             	add    $0x10,%esp
}
  80116e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801171:	5b                   	pop    %ebx
  801172:	5e                   	pop    %esi
  801173:	5f                   	pop    %edi
  801174:	c9                   	leave  
  801175:	c3                   	ret    

00801176 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  801176:	55                   	push   %ebp
  801177:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  801179:	83 fa 01             	cmp    $0x1,%edx
  80117c:	7e 0e                	jle    80118c <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80117e:	8b 10                	mov    (%eax),%edx
  801180:	8d 4a 08             	lea    0x8(%edx),%ecx
  801183:	89 08                	mov    %ecx,(%eax)
  801185:	8b 02                	mov    (%edx),%eax
  801187:	8b 52 04             	mov    0x4(%edx),%edx
  80118a:	eb 22                	jmp    8011ae <getuint+0x38>
	else if (lflag)
  80118c:	85 d2                	test   %edx,%edx
  80118e:	74 10                	je     8011a0 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  801190:	8b 10                	mov    (%eax),%edx
  801192:	8d 4a 04             	lea    0x4(%edx),%ecx
  801195:	89 08                	mov    %ecx,(%eax)
  801197:	8b 02                	mov    (%edx),%eax
  801199:	ba 00 00 00 00       	mov    $0x0,%edx
  80119e:	eb 0e                	jmp    8011ae <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8011a0:	8b 10                	mov    (%eax),%edx
  8011a2:	8d 4a 04             	lea    0x4(%edx),%ecx
  8011a5:	89 08                	mov    %ecx,(%eax)
  8011a7:	8b 02                	mov    (%edx),%eax
  8011a9:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8011ae:	c9                   	leave  
  8011af:	c3                   	ret    

008011b0 <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
  8011b0:	55                   	push   %ebp
  8011b1:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8011b3:	83 fa 01             	cmp    $0x1,%edx
  8011b6:	7e 0e                	jle    8011c6 <getint+0x16>
		return va_arg(*ap, long long);
  8011b8:	8b 10                	mov    (%eax),%edx
  8011ba:	8d 4a 08             	lea    0x8(%edx),%ecx
  8011bd:	89 08                	mov    %ecx,(%eax)
  8011bf:	8b 02                	mov    (%edx),%eax
  8011c1:	8b 52 04             	mov    0x4(%edx),%edx
  8011c4:	eb 1a                	jmp    8011e0 <getint+0x30>
	else if (lflag)
  8011c6:	85 d2                	test   %edx,%edx
  8011c8:	74 0c                	je     8011d6 <getint+0x26>
		return va_arg(*ap, long);
  8011ca:	8b 10                	mov    (%eax),%edx
  8011cc:	8d 4a 04             	lea    0x4(%edx),%ecx
  8011cf:	89 08                	mov    %ecx,(%eax)
  8011d1:	8b 02                	mov    (%edx),%eax
  8011d3:	99                   	cltd   
  8011d4:	eb 0a                	jmp    8011e0 <getint+0x30>
	else
		return va_arg(*ap, int);
  8011d6:	8b 10                	mov    (%eax),%edx
  8011d8:	8d 4a 04             	lea    0x4(%edx),%ecx
  8011db:	89 08                	mov    %ecx,(%eax)
  8011dd:	8b 02                	mov    (%edx),%eax
  8011df:	99                   	cltd   
}
  8011e0:	c9                   	leave  
  8011e1:	c3                   	ret    

008011e2 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8011e2:	55                   	push   %ebp
  8011e3:	89 e5                	mov    %esp,%ebp
  8011e5:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8011e8:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  8011eb:	8b 10                	mov    (%eax),%edx
  8011ed:	3b 50 04             	cmp    0x4(%eax),%edx
  8011f0:	73 08                	jae    8011fa <sprintputch+0x18>
		*b->buf++ = ch;
  8011f2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8011f5:	88 0a                	mov    %cl,(%edx)
  8011f7:	42                   	inc    %edx
  8011f8:	89 10                	mov    %edx,(%eax)
}
  8011fa:	c9                   	leave  
  8011fb:	c3                   	ret    

008011fc <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8011fc:	55                   	push   %ebp
  8011fd:	89 e5                	mov    %esp,%ebp
  8011ff:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  801202:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  801205:	50                   	push   %eax
  801206:	ff 75 10             	pushl  0x10(%ebp)
  801209:	ff 75 0c             	pushl  0xc(%ebp)
  80120c:	ff 75 08             	pushl  0x8(%ebp)
  80120f:	e8 05 00 00 00       	call   801219 <vprintfmt>
	va_end(ap);
  801214:	83 c4 10             	add    $0x10,%esp
}
  801217:	c9                   	leave  
  801218:	c3                   	ret    

00801219 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  801219:	55                   	push   %ebp
  80121a:	89 e5                	mov    %esp,%ebp
  80121c:	57                   	push   %edi
  80121d:	56                   	push   %esi
  80121e:	53                   	push   %ebx
  80121f:	83 ec 2c             	sub    $0x2c,%esp
  801222:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801225:	8b 75 10             	mov    0x10(%ebp),%esi
  801228:	eb 13                	jmp    80123d <vprintfmt+0x24>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  80122a:	85 c0                	test   %eax,%eax
  80122c:	0f 84 6d 03 00 00    	je     80159f <vprintfmt+0x386>
				return;
			putch(ch, putdat);
  801232:	83 ec 08             	sub    $0x8,%esp
  801235:	57                   	push   %edi
  801236:	50                   	push   %eax
  801237:	ff 55 08             	call   *0x8(%ebp)
  80123a:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80123d:	0f b6 06             	movzbl (%esi),%eax
  801240:	46                   	inc    %esi
  801241:	83 f8 25             	cmp    $0x25,%eax
  801244:	75 e4                	jne    80122a <vprintfmt+0x11>
  801246:	c6 45 dc 20          	movb   $0x20,-0x24(%ebp)
  80124a:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  801251:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
  801258:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  80125f:	b9 00 00 00 00       	mov    $0x0,%ecx
  801264:	eb 28                	jmp    80128e <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801266:	89 de                	mov    %ebx,%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  801268:	c6 45 dc 2d          	movb   $0x2d,-0x24(%ebp)
  80126c:	eb 20                	jmp    80128e <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80126e:	89 de                	mov    %ebx,%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  801270:	c6 45 dc 30          	movb   $0x30,-0x24(%ebp)
  801274:	eb 18                	jmp    80128e <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801276:	89 de                	mov    %ebx,%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  801278:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  80127f:	eb 0d                	jmp    80128e <vprintfmt+0x75>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  801281:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  801284:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801287:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80128e:	8a 06                	mov    (%esi),%al
  801290:	0f b6 d0             	movzbl %al,%edx
  801293:	8d 5e 01             	lea    0x1(%esi),%ebx
  801296:	83 e8 23             	sub    $0x23,%eax
  801299:	3c 55                	cmp    $0x55,%al
  80129b:	0f 87 e0 02 00 00    	ja     801581 <vprintfmt+0x368>
  8012a1:	0f b6 c0             	movzbl %al,%eax
  8012a4:	ff 24 85 40 20 80 00 	jmp    *0x802040(,%eax,4)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8012ab:	83 ea 30             	sub    $0x30,%edx
  8012ae:	89 55 d4             	mov    %edx,-0x2c(%ebp)
				ch = *fmt;
  8012b1:	0f be 03             	movsbl (%ebx),%eax
				if (ch < '0' || ch > '9')
  8012b4:	8d 50 d0             	lea    -0x30(%eax),%edx
  8012b7:	83 fa 09             	cmp    $0x9,%edx
  8012ba:	77 44                	ja     801300 <vprintfmt+0xe7>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8012bc:	89 de                	mov    %ebx,%esi
  8012be:	8b 55 d4             	mov    -0x2c(%ebp),%edx
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8012c1:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
  8012c2:	8d 14 92             	lea    (%edx,%edx,4),%edx
  8012c5:	8d 54 50 d0          	lea    -0x30(%eax,%edx,2),%edx
				ch = *fmt;
  8012c9:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  8012cc:	8d 58 d0             	lea    -0x30(%eax),%ebx
  8012cf:	83 fb 09             	cmp    $0x9,%ebx
  8012d2:	76 ed                	jbe    8012c1 <vprintfmt+0xa8>
  8012d4:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  8012d7:	eb 29                	jmp    801302 <vprintfmt+0xe9>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8012d9:	8b 45 14             	mov    0x14(%ebp),%eax
  8012dc:	8d 50 04             	lea    0x4(%eax),%edx
  8012df:	89 55 14             	mov    %edx,0x14(%ebp)
  8012e2:	8b 00                	mov    (%eax),%eax
  8012e4:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8012e7:	89 de                	mov    %ebx,%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8012e9:	eb 17                	jmp    801302 <vprintfmt+0xe9>

		case '.':
			if (width < 0)
  8012eb:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8012ef:	78 85                	js     801276 <vprintfmt+0x5d>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8012f1:	89 de                	mov    %ebx,%esi
  8012f3:	eb 99                	jmp    80128e <vprintfmt+0x75>
  8012f5:	89 de                	mov    %ebx,%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8012f7:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
			goto reswitch;
  8012fe:	eb 8e                	jmp    80128e <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801300:	89 de                	mov    %ebx,%esi
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  801302:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  801306:	79 86                	jns    80128e <vprintfmt+0x75>
  801308:	e9 74 ff ff ff       	jmp    801281 <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80130d:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80130e:	89 de                	mov    %ebx,%esi
  801310:	e9 79 ff ff ff       	jmp    80128e <vprintfmt+0x75>
  801315:	89 5d d8             	mov    %ebx,-0x28(%ebp)
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  801318:	8b 45 14             	mov    0x14(%ebp),%eax
  80131b:	8d 50 04             	lea    0x4(%eax),%edx
  80131e:	89 55 14             	mov    %edx,0x14(%ebp)
  801321:	83 ec 08             	sub    $0x8,%esp
  801324:	57                   	push   %edi
  801325:	ff 30                	pushl  (%eax)
  801327:	ff 55 08             	call   *0x8(%ebp)
			break;
  80132a:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80132d:	8b 75 d8             	mov    -0x28(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  801330:	e9 08 ff ff ff       	jmp    80123d <vprintfmt+0x24>
  801335:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// error message
		case 'e':
			err = va_arg(ap, int);
  801338:	8b 45 14             	mov    0x14(%ebp),%eax
  80133b:	8d 50 04             	lea    0x4(%eax),%edx
  80133e:	89 55 14             	mov    %edx,0x14(%ebp)
  801341:	8b 00                	mov    (%eax),%eax
  801343:	85 c0                	test   %eax,%eax
  801345:	79 02                	jns    801349 <vprintfmt+0x130>
  801347:	f7 d8                	neg    %eax
  801349:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80134b:	83 f8 0f             	cmp    $0xf,%eax
  80134e:	7f 0b                	jg     80135b <vprintfmt+0x142>
  801350:	8b 04 85 a0 21 80 00 	mov    0x8021a0(,%eax,4),%eax
  801357:	85 c0                	test   %eax,%eax
  801359:	75 1a                	jne    801375 <vprintfmt+0x15c>
				printfmt(putch, putdat, "error %d", err);
  80135b:	52                   	push   %edx
  80135c:	68 0b 1f 80 00       	push   $0x801f0b
  801361:	57                   	push   %edi
  801362:	ff 75 08             	pushl  0x8(%ebp)
  801365:	e8 92 fe ff ff       	call   8011fc <printfmt>
  80136a:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80136d:	8b 75 d8             	mov    -0x28(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  801370:	e9 c8 fe ff ff       	jmp    80123d <vprintfmt+0x24>
			else
				printfmt(putch, putdat, "%s", p);
  801375:	50                   	push   %eax
  801376:	68 89 1e 80 00       	push   $0x801e89
  80137b:	57                   	push   %edi
  80137c:	ff 75 08             	pushl  0x8(%ebp)
  80137f:	e8 78 fe ff ff       	call   8011fc <printfmt>
  801384:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801387:	8b 75 d8             	mov    -0x28(%ebp),%esi
  80138a:	e9 ae fe ff ff       	jmp    80123d <vprintfmt+0x24>
  80138f:	89 5d d8             	mov    %ebx,-0x28(%ebp)
  801392:	89 de                	mov    %ebx,%esi
  801394:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  801397:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80139a:	8b 45 14             	mov    0x14(%ebp),%eax
  80139d:	8d 50 04             	lea    0x4(%eax),%edx
  8013a0:	89 55 14             	mov    %edx,0x14(%ebp)
  8013a3:	8b 00                	mov    (%eax),%eax
  8013a5:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8013a8:	85 c0                	test   %eax,%eax
  8013aa:	75 07                	jne    8013b3 <vprintfmt+0x19a>
				p = "(null)";
  8013ac:	c7 45 d0 04 1f 80 00 	movl   $0x801f04,-0x30(%ebp)
			if (width > 0 && padc != '-')
  8013b3:	85 db                	test   %ebx,%ebx
  8013b5:	7e 42                	jle    8013f9 <vprintfmt+0x1e0>
  8013b7:	80 7d dc 2d          	cmpb   $0x2d,-0x24(%ebp)
  8013bb:	74 3c                	je     8013f9 <vprintfmt+0x1e0>
				for (width -= strnlen(p, precision); width > 0; width--)
  8013bd:	83 ec 08             	sub    $0x8,%esp
  8013c0:	51                   	push   %ecx
  8013c1:	ff 75 d0             	pushl  -0x30(%ebp)
  8013c4:	e8 6f 02 00 00       	call   801638 <strnlen>
  8013c9:	29 c3                	sub    %eax,%ebx
  8013cb:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8013ce:	83 c4 10             	add    $0x10,%esp
  8013d1:	85 db                	test   %ebx,%ebx
  8013d3:	7e 24                	jle    8013f9 <vprintfmt+0x1e0>
					putch(padc, putdat);
  8013d5:	0f be 5d dc          	movsbl -0x24(%ebp),%ebx
  8013d9:	89 75 dc             	mov    %esi,-0x24(%ebp)
  8013dc:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  8013df:	83 ec 08             	sub    $0x8,%esp
  8013e2:	57                   	push   %edi
  8013e3:	53                   	push   %ebx
  8013e4:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8013e7:	4e                   	dec    %esi
  8013e8:	83 c4 10             	add    $0x10,%esp
  8013eb:	85 f6                	test   %esi,%esi
  8013ed:	7f f0                	jg     8013df <vprintfmt+0x1c6>
  8013ef:	8b 75 dc             	mov    -0x24(%ebp),%esi
  8013f2:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8013f9:	8b 55 d0             	mov    -0x30(%ebp),%edx
  8013fc:	0f be 02             	movsbl (%edx),%eax
  8013ff:	85 c0                	test   %eax,%eax
  801401:	75 47                	jne    80144a <vprintfmt+0x231>
  801403:	eb 37                	jmp    80143c <vprintfmt+0x223>
				if (altflag && (ch < ' ' || ch > '~'))
  801405:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  801409:	74 16                	je     801421 <vprintfmt+0x208>
  80140b:	8d 50 e0             	lea    -0x20(%eax),%edx
  80140e:	83 fa 5e             	cmp    $0x5e,%edx
  801411:	76 0e                	jbe    801421 <vprintfmt+0x208>
					putch('?', putdat);
  801413:	83 ec 08             	sub    $0x8,%esp
  801416:	57                   	push   %edi
  801417:	6a 3f                	push   $0x3f
  801419:	ff 55 08             	call   *0x8(%ebp)
  80141c:	83 c4 10             	add    $0x10,%esp
  80141f:	eb 0b                	jmp    80142c <vprintfmt+0x213>
				else
					putch(ch, putdat);
  801421:	83 ec 08             	sub    $0x8,%esp
  801424:	57                   	push   %edi
  801425:	50                   	push   %eax
  801426:	ff 55 08             	call   *0x8(%ebp)
  801429:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80142c:	ff 4d e4             	decl   -0x1c(%ebp)
  80142f:	0f be 03             	movsbl (%ebx),%eax
  801432:	85 c0                	test   %eax,%eax
  801434:	74 03                	je     801439 <vprintfmt+0x220>
  801436:	43                   	inc    %ebx
  801437:	eb 1b                	jmp    801454 <vprintfmt+0x23b>
  801439:	8b 75 dc             	mov    -0x24(%ebp),%esi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80143c:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  801440:	7f 1e                	jg     801460 <vprintfmt+0x247>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801442:	8b 75 d8             	mov    -0x28(%ebp),%esi
  801445:	e9 f3 fd ff ff       	jmp    80123d <vprintfmt+0x24>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80144a:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  80144d:	43                   	inc    %ebx
  80144e:	89 75 dc             	mov    %esi,-0x24(%ebp)
  801451:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  801454:	85 f6                	test   %esi,%esi
  801456:	78 ad                	js     801405 <vprintfmt+0x1ec>
  801458:	4e                   	dec    %esi
  801459:	79 aa                	jns    801405 <vprintfmt+0x1ec>
  80145b:	8b 75 dc             	mov    -0x24(%ebp),%esi
  80145e:	eb dc                	jmp    80143c <vprintfmt+0x223>
  801460:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  801463:	83 ec 08             	sub    $0x8,%esp
  801466:	57                   	push   %edi
  801467:	6a 20                	push   $0x20
  801469:	ff 55 08             	call   *0x8(%ebp)
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80146c:	4b                   	dec    %ebx
  80146d:	83 c4 10             	add    $0x10,%esp
  801470:	85 db                	test   %ebx,%ebx
  801472:	7f ef                	jg     801463 <vprintfmt+0x24a>
  801474:	e9 c4 fd ff ff       	jmp    80123d <vprintfmt+0x24>
  801479:	89 5d d8             	mov    %ebx,-0x28(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80147c:	89 ca                	mov    %ecx,%edx
  80147e:	8d 45 14             	lea    0x14(%ebp),%eax
  801481:	e8 2a fd ff ff       	call   8011b0 <getint>
  801486:	89 c3                	mov    %eax,%ebx
  801488:	89 d6                	mov    %edx,%esi
			if ((long long) num < 0) {
  80148a:	85 d2                	test   %edx,%edx
  80148c:	78 0a                	js     801498 <vprintfmt+0x27f>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  80148e:	b8 0a 00 00 00       	mov    $0xa,%eax
  801493:	e9 b0 00 00 00       	jmp    801548 <vprintfmt+0x32f>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  801498:	83 ec 08             	sub    $0x8,%esp
  80149b:	57                   	push   %edi
  80149c:	6a 2d                	push   $0x2d
  80149e:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  8014a1:	f7 db                	neg    %ebx
  8014a3:	83 d6 00             	adc    $0x0,%esi
  8014a6:	f7 de                	neg    %esi
  8014a8:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  8014ab:	b8 0a 00 00 00       	mov    $0xa,%eax
  8014b0:	e9 93 00 00 00       	jmp    801548 <vprintfmt+0x32f>
  8014b5:	89 5d d8             	mov    %ebx,-0x28(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8014b8:	89 ca                	mov    %ecx,%edx
  8014ba:	8d 45 14             	lea    0x14(%ebp),%eax
  8014bd:	e8 b4 fc ff ff       	call   801176 <getuint>
  8014c2:	89 c3                	mov    %eax,%ebx
  8014c4:	89 d6                	mov    %edx,%esi
			base = 10;
  8014c6:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  8014cb:	eb 7b                	jmp    801548 <vprintfmt+0x32f>
  8014cd:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// (unsigned) octal
		case 'o':
            // (MIT 6.828, lab1, Ex.8)  my code : 
            num = getint(&ap, lflag);
  8014d0:	89 ca                	mov    %ecx,%edx
  8014d2:	8d 45 14             	lea    0x14(%ebp),%eax
  8014d5:	e8 d6 fc ff ff       	call   8011b0 <getint>
  8014da:	89 c3                	mov    %eax,%ebx
  8014dc:	89 d6                	mov    %edx,%esi
            if ((long long) num < 0) {
  8014de:	85 d2                	test   %edx,%edx
  8014e0:	78 07                	js     8014e9 <vprintfmt+0x2d0>
                putch('-', putdat);
                num = -(long long) num;
            }
            base = 8;
  8014e2:	b8 08 00 00 00       	mov    $0x8,%eax
  8014e7:	eb 5f                	jmp    801548 <vprintfmt+0x32f>
		// (unsigned) octal
		case 'o':
            // (MIT 6.828, lab1, Ex.8)  my code : 
            num = getint(&ap, lflag);
            if ((long long) num < 0) {
                putch('-', putdat);
  8014e9:	83 ec 08             	sub    $0x8,%esp
  8014ec:	57                   	push   %edi
  8014ed:	6a 2d                	push   $0x2d
  8014ef:	ff 55 08             	call   *0x8(%ebp)
                num = -(long long) num;
  8014f2:	f7 db                	neg    %ebx
  8014f4:	83 d6 00             	adc    $0x0,%esi
  8014f7:	f7 de                	neg    %esi
  8014f9:	83 c4 10             	add    $0x10,%esp
            }
            base = 8;
  8014fc:	b8 08 00 00 00       	mov    $0x8,%eax
  801501:	eb 45                	jmp    801548 <vprintfmt+0x32f>
  801503:	89 5d d8             	mov    %ebx,-0x28(%ebp)
            goto number;

        // pointer
		case 'p':
			putch('0', putdat);
  801506:	83 ec 08             	sub    $0x8,%esp
  801509:	57                   	push   %edi
  80150a:	6a 30                	push   $0x30
  80150c:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  80150f:	83 c4 08             	add    $0x8,%esp
  801512:	57                   	push   %edi
  801513:	6a 78                	push   $0x78
  801515:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  801518:	8b 45 14             	mov    0x14(%ebp),%eax
  80151b:	8d 50 04             	lea    0x4(%eax),%edx
  80151e:	89 55 14             	mov    %edx,0x14(%ebp)

        // pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  801521:	8b 18                	mov    (%eax),%ebx
  801523:	be 00 00 00 00       	mov    $0x0,%esi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  801528:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  80152b:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  801530:	eb 16                	jmp    801548 <vprintfmt+0x32f>
  801532:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  801535:	89 ca                	mov    %ecx,%edx
  801537:	8d 45 14             	lea    0x14(%ebp),%eax
  80153a:	e8 37 fc ff ff       	call   801176 <getuint>
  80153f:	89 c3                	mov    %eax,%ebx
  801541:	89 d6                	mov    %edx,%esi
			base = 16;
  801543:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  801548:	83 ec 0c             	sub    $0xc,%esp
  80154b:	0f be 55 dc          	movsbl -0x24(%ebp),%edx
  80154f:	52                   	push   %edx
  801550:	ff 75 e4             	pushl  -0x1c(%ebp)
  801553:	50                   	push   %eax
  801554:	56                   	push   %esi
  801555:	53                   	push   %ebx
  801556:	89 fa                	mov    %edi,%edx
  801558:	8b 45 08             	mov    0x8(%ebp),%eax
  80155b:	e8 68 fb ff ff       	call   8010c8 <printnum>
			break;
  801560:	83 c4 20             	add    $0x20,%esp
  801563:	8b 75 d8             	mov    -0x28(%ebp),%esi
  801566:	e9 d2 fc ff ff       	jmp    80123d <vprintfmt+0x24>
  80156b:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80156e:	83 ec 08             	sub    $0x8,%esp
  801571:	57                   	push   %edi
  801572:	52                   	push   %edx
  801573:	ff 55 08             	call   *0x8(%ebp)
			break;
  801576:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801579:	8b 75 d8             	mov    -0x28(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  80157c:	e9 bc fc ff ff       	jmp    80123d <vprintfmt+0x24>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  801581:	83 ec 08             	sub    $0x8,%esp
  801584:	57                   	push   %edi
  801585:	6a 25                	push   $0x25
  801587:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  80158a:	83 c4 10             	add    $0x10,%esp
  80158d:	eb 02                	jmp    801591 <vprintfmt+0x378>
  80158f:	89 c6                	mov    %eax,%esi
  801591:	8d 46 ff             	lea    -0x1(%esi),%eax
  801594:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  801598:	75 f5                	jne    80158f <vprintfmt+0x376>
  80159a:	e9 9e fc ff ff       	jmp    80123d <vprintfmt+0x24>
				/* do nothing */;
			break;
		}
	}
}
  80159f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8015a2:	5b                   	pop    %ebx
  8015a3:	5e                   	pop    %esi
  8015a4:	5f                   	pop    %edi
  8015a5:	c9                   	leave  
  8015a6:	c3                   	ret    

008015a7 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8015a7:	55                   	push   %ebp
  8015a8:	89 e5                	mov    %esp,%ebp
  8015aa:	83 ec 18             	sub    $0x18,%esp
  8015ad:	8b 45 08             	mov    0x8(%ebp),%eax
  8015b0:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8015b3:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8015b6:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8015ba:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8015bd:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8015c4:	85 c0                	test   %eax,%eax
  8015c6:	74 26                	je     8015ee <vsnprintf+0x47>
  8015c8:	85 d2                	test   %edx,%edx
  8015ca:	7e 29                	jle    8015f5 <vsnprintf+0x4e>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8015cc:	ff 75 14             	pushl  0x14(%ebp)
  8015cf:	ff 75 10             	pushl  0x10(%ebp)
  8015d2:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8015d5:	50                   	push   %eax
  8015d6:	68 e2 11 80 00       	push   $0x8011e2
  8015db:	e8 39 fc ff ff       	call   801219 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8015e0:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8015e3:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8015e6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8015e9:	83 c4 10             	add    $0x10,%esp
  8015ec:	eb 0c                	jmp    8015fa <vsnprintf+0x53>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8015ee:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8015f3:	eb 05                	jmp    8015fa <vsnprintf+0x53>
  8015f5:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8015fa:	c9                   	leave  
  8015fb:	c3                   	ret    

008015fc <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8015fc:	55                   	push   %ebp
  8015fd:	89 e5                	mov    %esp,%ebp
  8015ff:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  801602:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  801605:	50                   	push   %eax
  801606:	ff 75 10             	pushl  0x10(%ebp)
  801609:	ff 75 0c             	pushl  0xc(%ebp)
  80160c:	ff 75 08             	pushl  0x8(%ebp)
  80160f:	e8 93 ff ff ff       	call   8015a7 <vsnprintf>
	va_end(ap);

	return rc;
}
  801614:	c9                   	leave  
  801615:	c3                   	ret    
	...

00801618 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  801618:	55                   	push   %ebp
  801619:	89 e5                	mov    %esp,%ebp
  80161b:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80161e:	80 3a 00             	cmpb   $0x0,(%edx)
  801621:	74 0e                	je     801631 <strlen+0x19>
  801623:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  801628:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  801629:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  80162d:	75 f9                	jne    801628 <strlen+0x10>
  80162f:	eb 05                	jmp    801636 <strlen+0x1e>
  801631:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  801636:	c9                   	leave  
  801637:	c3                   	ret    

00801638 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  801638:	55                   	push   %ebp
  801639:	89 e5                	mov    %esp,%ebp
  80163b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80163e:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801641:	85 d2                	test   %edx,%edx
  801643:	74 17                	je     80165c <strnlen+0x24>
  801645:	80 39 00             	cmpb   $0x0,(%ecx)
  801648:	74 19                	je     801663 <strnlen+0x2b>
  80164a:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  80164f:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801650:	39 d0                	cmp    %edx,%eax
  801652:	74 14                	je     801668 <strnlen+0x30>
  801654:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  801658:	75 f5                	jne    80164f <strnlen+0x17>
  80165a:	eb 0c                	jmp    801668 <strnlen+0x30>
  80165c:	b8 00 00 00 00       	mov    $0x0,%eax
  801661:	eb 05                	jmp    801668 <strnlen+0x30>
  801663:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  801668:	c9                   	leave  
  801669:	c3                   	ret    

0080166a <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80166a:	55                   	push   %ebp
  80166b:	89 e5                	mov    %esp,%ebp
  80166d:	53                   	push   %ebx
  80166e:	8b 45 08             	mov    0x8(%ebp),%eax
  801671:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  801674:	ba 00 00 00 00       	mov    $0x0,%edx
  801679:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  80167c:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  80167f:	42                   	inc    %edx
  801680:	84 c9                	test   %cl,%cl
  801682:	75 f5                	jne    801679 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  801684:	5b                   	pop    %ebx
  801685:	c9                   	leave  
  801686:	c3                   	ret    

00801687 <strcat>:

char *
strcat(char *dst, const char *src)
{
  801687:	55                   	push   %ebp
  801688:	89 e5                	mov    %esp,%ebp
  80168a:	53                   	push   %ebx
  80168b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80168e:	53                   	push   %ebx
  80168f:	e8 84 ff ff ff       	call   801618 <strlen>
  801694:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  801697:	ff 75 0c             	pushl  0xc(%ebp)
  80169a:	8d 04 03             	lea    (%ebx,%eax,1),%eax
  80169d:	50                   	push   %eax
  80169e:	e8 c7 ff ff ff       	call   80166a <strcpy>
	return dst;
}
  8016a3:	89 d8                	mov    %ebx,%eax
  8016a5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016a8:	c9                   	leave  
  8016a9:	c3                   	ret    

008016aa <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8016aa:	55                   	push   %ebp
  8016ab:	89 e5                	mov    %esp,%ebp
  8016ad:	56                   	push   %esi
  8016ae:	53                   	push   %ebx
  8016af:	8b 45 08             	mov    0x8(%ebp),%eax
  8016b2:	8b 55 0c             	mov    0xc(%ebp),%edx
  8016b5:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8016b8:	85 f6                	test   %esi,%esi
  8016ba:	74 15                	je     8016d1 <strncpy+0x27>
  8016bc:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
  8016c1:	8a 1a                	mov    (%edx),%bl
  8016c3:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8016c6:	80 3a 01             	cmpb   $0x1,(%edx)
  8016c9:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8016cc:	41                   	inc    %ecx
  8016cd:	39 ce                	cmp    %ecx,%esi
  8016cf:	77 f0                	ja     8016c1 <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8016d1:	5b                   	pop    %ebx
  8016d2:	5e                   	pop    %esi
  8016d3:	c9                   	leave  
  8016d4:	c3                   	ret    

008016d5 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8016d5:	55                   	push   %ebp
  8016d6:	89 e5                	mov    %esp,%ebp
  8016d8:	57                   	push   %edi
  8016d9:	56                   	push   %esi
  8016da:	53                   	push   %ebx
  8016db:	8b 7d 08             	mov    0x8(%ebp),%edi
  8016de:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8016e1:	8b 75 10             	mov    0x10(%ebp),%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8016e4:	85 f6                	test   %esi,%esi
  8016e6:	74 32                	je     80171a <strlcpy+0x45>
		while (--size > 0 && *src != '\0')
  8016e8:	83 fe 01             	cmp    $0x1,%esi
  8016eb:	74 22                	je     80170f <strlcpy+0x3a>
  8016ed:	8a 0b                	mov    (%ebx),%cl
  8016ef:	84 c9                	test   %cl,%cl
  8016f1:	74 20                	je     801713 <strlcpy+0x3e>
  8016f3:	89 f8                	mov    %edi,%eax
  8016f5:	ba 00 00 00 00       	mov    $0x0,%edx
	}
	return ret;
}

size_t
strlcpy(char *dst, const char *src, size_t size)
  8016fa:	83 ee 02             	sub    $0x2,%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8016fd:	88 08                	mov    %cl,(%eax)
  8016ff:	40                   	inc    %eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  801700:	39 f2                	cmp    %esi,%edx
  801702:	74 11                	je     801715 <strlcpy+0x40>
  801704:	8a 4c 13 01          	mov    0x1(%ebx,%edx,1),%cl
  801708:	42                   	inc    %edx
  801709:	84 c9                	test   %cl,%cl
  80170b:	75 f0                	jne    8016fd <strlcpy+0x28>
  80170d:	eb 06                	jmp    801715 <strlcpy+0x40>
  80170f:	89 f8                	mov    %edi,%eax
  801711:	eb 02                	jmp    801715 <strlcpy+0x40>
  801713:	89 f8                	mov    %edi,%eax
			*dst++ = *src++;
		*dst = '\0';
  801715:	c6 00 00             	movb   $0x0,(%eax)
  801718:	eb 02                	jmp    80171c <strlcpy+0x47>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80171a:	89 f8                	mov    %edi,%eax
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
		*dst = '\0';
	}
	return dst - dst_in;
  80171c:	29 f8                	sub    %edi,%eax
}
  80171e:	5b                   	pop    %ebx
  80171f:	5e                   	pop    %esi
  801720:	5f                   	pop    %edi
  801721:	c9                   	leave  
  801722:	c3                   	ret    

00801723 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  801723:	55                   	push   %ebp
  801724:	89 e5                	mov    %esp,%ebp
  801726:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801729:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80172c:	8a 01                	mov    (%ecx),%al
  80172e:	84 c0                	test   %al,%al
  801730:	74 10                	je     801742 <strcmp+0x1f>
  801732:	3a 02                	cmp    (%edx),%al
  801734:	75 0c                	jne    801742 <strcmp+0x1f>
		p++, q++;
  801736:	41                   	inc    %ecx
  801737:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  801738:	8a 01                	mov    (%ecx),%al
  80173a:	84 c0                	test   %al,%al
  80173c:	74 04                	je     801742 <strcmp+0x1f>
  80173e:	3a 02                	cmp    (%edx),%al
  801740:	74 f4                	je     801736 <strcmp+0x13>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  801742:	0f b6 c0             	movzbl %al,%eax
  801745:	0f b6 12             	movzbl (%edx),%edx
  801748:	29 d0                	sub    %edx,%eax
}
  80174a:	c9                   	leave  
  80174b:	c3                   	ret    

0080174c <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  80174c:	55                   	push   %ebp
  80174d:	89 e5                	mov    %esp,%ebp
  80174f:	53                   	push   %ebx
  801750:	8b 55 08             	mov    0x8(%ebp),%edx
  801753:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801756:	8b 45 10             	mov    0x10(%ebp),%eax
	while (n > 0 && *p && *p == *q)
  801759:	85 c0                	test   %eax,%eax
  80175b:	74 1b                	je     801778 <strncmp+0x2c>
  80175d:	8a 1a                	mov    (%edx),%bl
  80175f:	84 db                	test   %bl,%bl
  801761:	74 24                	je     801787 <strncmp+0x3b>
  801763:	3a 19                	cmp    (%ecx),%bl
  801765:	75 20                	jne    801787 <strncmp+0x3b>
  801767:	48                   	dec    %eax
  801768:	74 15                	je     80177f <strncmp+0x33>
		n--, p++, q++;
  80176a:	42                   	inc    %edx
  80176b:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  80176c:	8a 1a                	mov    (%edx),%bl
  80176e:	84 db                	test   %bl,%bl
  801770:	74 15                	je     801787 <strncmp+0x3b>
  801772:	3a 19                	cmp    (%ecx),%bl
  801774:	74 f1                	je     801767 <strncmp+0x1b>
  801776:	eb 0f                	jmp    801787 <strncmp+0x3b>
		n--, p++, q++;
	if (n == 0)
		return 0;
  801778:	b8 00 00 00 00       	mov    $0x0,%eax
  80177d:	eb 05                	jmp    801784 <strncmp+0x38>
  80177f:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  801784:	5b                   	pop    %ebx
  801785:	c9                   	leave  
  801786:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  801787:	0f b6 02             	movzbl (%edx),%eax
  80178a:	0f b6 11             	movzbl (%ecx),%edx
  80178d:	29 d0                	sub    %edx,%eax
  80178f:	eb f3                	jmp    801784 <strncmp+0x38>

00801791 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  801791:	55                   	push   %ebp
  801792:	89 e5                	mov    %esp,%ebp
  801794:	8b 45 08             	mov    0x8(%ebp),%eax
  801797:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  80179a:	8a 10                	mov    (%eax),%dl
  80179c:	84 d2                	test   %dl,%dl
  80179e:	74 18                	je     8017b8 <strchr+0x27>
		if (*s == c)
  8017a0:	38 ca                	cmp    %cl,%dl
  8017a2:	75 06                	jne    8017aa <strchr+0x19>
  8017a4:	eb 17                	jmp    8017bd <strchr+0x2c>
  8017a6:	38 ca                	cmp    %cl,%dl
  8017a8:	74 13                	je     8017bd <strchr+0x2c>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8017aa:	40                   	inc    %eax
  8017ab:	8a 10                	mov    (%eax),%dl
  8017ad:	84 d2                	test   %dl,%dl
  8017af:	75 f5                	jne    8017a6 <strchr+0x15>
		if (*s == c)
			return (char *) s;
	return 0;
  8017b1:	b8 00 00 00 00       	mov    $0x0,%eax
  8017b6:	eb 05                	jmp    8017bd <strchr+0x2c>
  8017b8:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8017bd:	c9                   	leave  
  8017be:	c3                   	ret    

008017bf <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8017bf:	55                   	push   %ebp
  8017c0:	89 e5                	mov    %esp,%ebp
  8017c2:	8b 45 08             	mov    0x8(%ebp),%eax
  8017c5:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  8017c8:	8a 10                	mov    (%eax),%dl
  8017ca:	84 d2                	test   %dl,%dl
  8017cc:	74 11                	je     8017df <strfind+0x20>
		if (*s == c)
  8017ce:	38 ca                	cmp    %cl,%dl
  8017d0:	75 06                	jne    8017d8 <strfind+0x19>
  8017d2:	eb 0b                	jmp    8017df <strfind+0x20>
  8017d4:	38 ca                	cmp    %cl,%dl
  8017d6:	74 07                	je     8017df <strfind+0x20>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  8017d8:	40                   	inc    %eax
  8017d9:	8a 10                	mov    (%eax),%dl
  8017db:	84 d2                	test   %dl,%dl
  8017dd:	75 f5                	jne    8017d4 <strfind+0x15>
		if (*s == c)
			break;
	return (char *) s;
}
  8017df:	c9                   	leave  
  8017e0:	c3                   	ret    

008017e1 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8017e1:	55                   	push   %ebp
  8017e2:	89 e5                	mov    %esp,%ebp
  8017e4:	57                   	push   %edi
  8017e5:	56                   	push   %esi
  8017e6:	53                   	push   %ebx
  8017e7:	8b 7d 08             	mov    0x8(%ebp),%edi
  8017ea:	8b 45 0c             	mov    0xc(%ebp),%eax
  8017ed:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8017f0:	85 c9                	test   %ecx,%ecx
  8017f2:	74 30                	je     801824 <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8017f4:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8017fa:	75 25                	jne    801821 <memset+0x40>
  8017fc:	f6 c1 03             	test   $0x3,%cl
  8017ff:	75 20                	jne    801821 <memset+0x40>
		c &= 0xFF;
  801801:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  801804:	89 d3                	mov    %edx,%ebx
  801806:	c1 e3 08             	shl    $0x8,%ebx
  801809:	89 d6                	mov    %edx,%esi
  80180b:	c1 e6 18             	shl    $0x18,%esi
  80180e:	89 d0                	mov    %edx,%eax
  801810:	c1 e0 10             	shl    $0x10,%eax
  801813:	09 f0                	or     %esi,%eax
  801815:	09 d0                	or     %edx,%eax
  801817:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  801819:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  80181c:	fc                   	cld    
  80181d:	f3 ab                	rep stos %eax,%es:(%edi)
  80181f:	eb 03                	jmp    801824 <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  801821:	fc                   	cld    
  801822:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  801824:	89 f8                	mov    %edi,%eax
  801826:	5b                   	pop    %ebx
  801827:	5e                   	pop    %esi
  801828:	5f                   	pop    %edi
  801829:	c9                   	leave  
  80182a:	c3                   	ret    

0080182b <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  80182b:	55                   	push   %ebp
  80182c:	89 e5                	mov    %esp,%ebp
  80182e:	57                   	push   %edi
  80182f:	56                   	push   %esi
  801830:	8b 45 08             	mov    0x8(%ebp),%eax
  801833:	8b 75 0c             	mov    0xc(%ebp),%esi
  801836:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  801839:	39 c6                	cmp    %eax,%esi
  80183b:	73 34                	jae    801871 <memmove+0x46>
  80183d:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  801840:	39 d0                	cmp    %edx,%eax
  801842:	73 2d                	jae    801871 <memmove+0x46>
		s += n;
		d += n;
  801844:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801847:	f6 c2 03             	test   $0x3,%dl
  80184a:	75 1b                	jne    801867 <memmove+0x3c>
  80184c:	f7 c7 03 00 00 00    	test   $0x3,%edi
  801852:	75 13                	jne    801867 <memmove+0x3c>
  801854:	f6 c1 03             	test   $0x3,%cl
  801857:	75 0e                	jne    801867 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  801859:	83 ef 04             	sub    $0x4,%edi
  80185c:	8d 72 fc             	lea    -0x4(%edx),%esi
  80185f:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  801862:	fd                   	std    
  801863:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801865:	eb 07                	jmp    80186e <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  801867:	4f                   	dec    %edi
  801868:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  80186b:	fd                   	std    
  80186c:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  80186e:	fc                   	cld    
  80186f:	eb 20                	jmp    801891 <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801871:	f7 c6 03 00 00 00    	test   $0x3,%esi
  801877:	75 13                	jne    80188c <memmove+0x61>
  801879:	a8 03                	test   $0x3,%al
  80187b:	75 0f                	jne    80188c <memmove+0x61>
  80187d:	f6 c1 03             	test   $0x3,%cl
  801880:	75 0a                	jne    80188c <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  801882:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  801885:	89 c7                	mov    %eax,%edi
  801887:	fc                   	cld    
  801888:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80188a:	eb 05                	jmp    801891 <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  80188c:	89 c7                	mov    %eax,%edi
  80188e:	fc                   	cld    
  80188f:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  801891:	5e                   	pop    %esi
  801892:	5f                   	pop    %edi
  801893:	c9                   	leave  
  801894:	c3                   	ret    

00801895 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  801895:	55                   	push   %ebp
  801896:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  801898:	ff 75 10             	pushl  0x10(%ebp)
  80189b:	ff 75 0c             	pushl  0xc(%ebp)
  80189e:	ff 75 08             	pushl  0x8(%ebp)
  8018a1:	e8 85 ff ff ff       	call   80182b <memmove>
}
  8018a6:	c9                   	leave  
  8018a7:	c3                   	ret    

008018a8 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8018a8:	55                   	push   %ebp
  8018a9:	89 e5                	mov    %esp,%ebp
  8018ab:	57                   	push   %edi
  8018ac:	56                   	push   %esi
  8018ad:	53                   	push   %ebx
  8018ae:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8018b1:	8b 75 0c             	mov    0xc(%ebp),%esi
  8018b4:	8b 7d 10             	mov    0x10(%ebp),%edi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8018b7:	85 ff                	test   %edi,%edi
  8018b9:	74 32                	je     8018ed <memcmp+0x45>
		if (*s1 != *s2)
  8018bb:	8a 03                	mov    (%ebx),%al
  8018bd:	8a 0e                	mov    (%esi),%cl
  8018bf:	38 c8                	cmp    %cl,%al
  8018c1:	74 19                	je     8018dc <memcmp+0x34>
  8018c3:	eb 0d                	jmp    8018d2 <memcmp+0x2a>
  8018c5:	8a 44 13 01          	mov    0x1(%ebx,%edx,1),%al
  8018c9:	8a 4c 16 01          	mov    0x1(%esi,%edx,1),%cl
  8018cd:	42                   	inc    %edx
  8018ce:	38 c8                	cmp    %cl,%al
  8018d0:	74 10                	je     8018e2 <memcmp+0x3a>
			return (int) *s1 - (int) *s2;
  8018d2:	0f b6 c0             	movzbl %al,%eax
  8018d5:	0f b6 c9             	movzbl %cl,%ecx
  8018d8:	29 c8                	sub    %ecx,%eax
  8018da:	eb 16                	jmp    8018f2 <memcmp+0x4a>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8018dc:	4f                   	dec    %edi
  8018dd:	ba 00 00 00 00       	mov    $0x0,%edx
  8018e2:	39 fa                	cmp    %edi,%edx
  8018e4:	75 df                	jne    8018c5 <memcmp+0x1d>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  8018e6:	b8 00 00 00 00       	mov    $0x0,%eax
  8018eb:	eb 05                	jmp    8018f2 <memcmp+0x4a>
  8018ed:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8018f2:	5b                   	pop    %ebx
  8018f3:	5e                   	pop    %esi
  8018f4:	5f                   	pop    %edi
  8018f5:	c9                   	leave  
  8018f6:	c3                   	ret    

008018f7 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8018f7:	55                   	push   %ebp
  8018f8:	89 e5                	mov    %esp,%ebp
  8018fa:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  8018fd:	89 c2                	mov    %eax,%edx
  8018ff:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  801902:	39 d0                	cmp    %edx,%eax
  801904:	73 12                	jae    801918 <memfind+0x21>
		if (*(const unsigned char *) s == (unsigned char) c)
  801906:	8a 4d 0c             	mov    0xc(%ebp),%cl
  801909:	38 08                	cmp    %cl,(%eax)
  80190b:	75 06                	jne    801913 <memfind+0x1c>
  80190d:	eb 09                	jmp    801918 <memfind+0x21>
  80190f:	38 08                	cmp    %cl,(%eax)
  801911:	74 05                	je     801918 <memfind+0x21>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801913:	40                   	inc    %eax
  801914:	39 c2                	cmp    %eax,%edx
  801916:	77 f7                	ja     80190f <memfind+0x18>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  801918:	c9                   	leave  
  801919:	c3                   	ret    

0080191a <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  80191a:	55                   	push   %ebp
  80191b:	89 e5                	mov    %esp,%ebp
  80191d:	57                   	push   %edi
  80191e:	56                   	push   %esi
  80191f:	53                   	push   %ebx
  801920:	8b 55 08             	mov    0x8(%ebp),%edx
  801923:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801926:	eb 01                	jmp    801929 <strtol+0xf>
		s++;
  801928:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801929:	8a 02                	mov    (%edx),%al
  80192b:	3c 20                	cmp    $0x20,%al
  80192d:	74 f9                	je     801928 <strtol+0xe>
  80192f:	3c 09                	cmp    $0x9,%al
  801931:	74 f5                	je     801928 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  801933:	3c 2b                	cmp    $0x2b,%al
  801935:	75 08                	jne    80193f <strtol+0x25>
		s++;
  801937:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  801938:	bf 00 00 00 00       	mov    $0x0,%edi
  80193d:	eb 13                	jmp    801952 <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  80193f:	3c 2d                	cmp    $0x2d,%al
  801941:	75 0a                	jne    80194d <strtol+0x33>
		s++, neg = 1;
  801943:	8d 52 01             	lea    0x1(%edx),%edx
  801946:	bf 01 00 00 00       	mov    $0x1,%edi
  80194b:	eb 05                	jmp    801952 <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  80194d:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801952:	85 db                	test   %ebx,%ebx
  801954:	74 05                	je     80195b <strtol+0x41>
  801956:	83 fb 10             	cmp    $0x10,%ebx
  801959:	75 28                	jne    801983 <strtol+0x69>
  80195b:	8a 02                	mov    (%edx),%al
  80195d:	3c 30                	cmp    $0x30,%al
  80195f:	75 10                	jne    801971 <strtol+0x57>
  801961:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  801965:	75 0a                	jne    801971 <strtol+0x57>
		s += 2, base = 16;
  801967:	83 c2 02             	add    $0x2,%edx
  80196a:	bb 10 00 00 00       	mov    $0x10,%ebx
  80196f:	eb 12                	jmp    801983 <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  801971:	85 db                	test   %ebx,%ebx
  801973:	75 0e                	jne    801983 <strtol+0x69>
  801975:	3c 30                	cmp    $0x30,%al
  801977:	75 05                	jne    80197e <strtol+0x64>
		s++, base = 8;
  801979:	42                   	inc    %edx
  80197a:	b3 08                	mov    $0x8,%bl
  80197c:	eb 05                	jmp    801983 <strtol+0x69>
	else if (base == 0)
		base = 10;
  80197e:	bb 0a 00 00 00       	mov    $0xa,%ebx
  801983:	b8 00 00 00 00       	mov    $0x0,%eax
  801988:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  80198a:	8a 0a                	mov    (%edx),%cl
  80198c:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  80198f:	80 fb 09             	cmp    $0x9,%bl
  801992:	77 08                	ja     80199c <strtol+0x82>
			dig = *s - '0';
  801994:	0f be c9             	movsbl %cl,%ecx
  801997:	83 e9 30             	sub    $0x30,%ecx
  80199a:	eb 1e                	jmp    8019ba <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  80199c:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  80199f:	80 fb 19             	cmp    $0x19,%bl
  8019a2:	77 08                	ja     8019ac <strtol+0x92>
			dig = *s - 'a' + 10;
  8019a4:	0f be c9             	movsbl %cl,%ecx
  8019a7:	83 e9 57             	sub    $0x57,%ecx
  8019aa:	eb 0e                	jmp    8019ba <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  8019ac:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  8019af:	80 fb 19             	cmp    $0x19,%bl
  8019b2:	77 13                	ja     8019c7 <strtol+0xad>
			dig = *s - 'A' + 10;
  8019b4:	0f be c9             	movsbl %cl,%ecx
  8019b7:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  8019ba:	39 f1                	cmp    %esi,%ecx
  8019bc:	7d 0d                	jge    8019cb <strtol+0xb1>
			break;
		s++, val = (val * base) + dig;
  8019be:	42                   	inc    %edx
  8019bf:	0f af c6             	imul   %esi,%eax
  8019c2:	8d 04 01             	lea    (%ecx,%eax,1),%eax
		// we don't properly detect overflow!
	}
  8019c5:	eb c3                	jmp    80198a <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  8019c7:	89 c1                	mov    %eax,%ecx
  8019c9:	eb 02                	jmp    8019cd <strtol+0xb3>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  8019cb:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  8019cd:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8019d1:	74 05                	je     8019d8 <strtol+0xbe>
		*endptr = (char *) s;
  8019d3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8019d6:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  8019d8:	85 ff                	test   %edi,%edi
  8019da:	74 04                	je     8019e0 <strtol+0xc6>
  8019dc:	89 c8                	mov    %ecx,%eax
  8019de:	f7 d8                	neg    %eax
}
  8019e0:	5b                   	pop    %ebx
  8019e1:	5e                   	pop    %esi
  8019e2:	5f                   	pop    %edi
  8019e3:	c9                   	leave  
  8019e4:	c3                   	ret    
  8019e5:	00 00                	add    %al,(%eax)
	...

008019e8 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8019e8:	55                   	push   %ebp
  8019e9:	89 e5                	mov    %esp,%ebp
  8019eb:	56                   	push   %esi
  8019ec:	53                   	push   %ebx
  8019ed:	8b 75 08             	mov    0x8(%ebp),%esi
  8019f0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8019f3:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// cprintf("0x%x 0x%x 0x%x\n", (uint32_t)from_env_store, (uint32_t)pg, (uint32_t)perm_store);
	int r;
	if (pg != NULL) {
  8019f6:	85 c0                	test   %eax,%eax
  8019f8:	74 0e                	je     801a08 <ipc_recv+0x20>
		r = sys_ipc_recv(pg);
  8019fa:	83 ec 0c             	sub    $0xc,%esp
  8019fd:	50                   	push   %eax
  8019fe:	e8 b8 e8 ff ff       	call   8002bb <sys_ipc_recv>
  801a03:	83 c4 10             	add    $0x10,%esp
  801a06:	eb 10                	jmp    801a18 <ipc_recv+0x30>
	} else {
		r = sys_ipc_recv((void *)UTOP);
  801a08:	83 ec 0c             	sub    $0xc,%esp
  801a0b:	68 00 00 c0 ee       	push   $0xeec00000
  801a10:	e8 a6 e8 ff ff       	call   8002bb <sys_ipc_recv>
  801a15:	83 c4 10             	add    $0x10,%esp
	}

	if (r == 0) {
  801a18:	85 c0                	test   %eax,%eax
  801a1a:	75 26                	jne    801a42 <ipc_recv+0x5a>
		if (from_env_store != NULL) *from_env_store = thisenv->env_ipc_from;
  801a1c:	85 f6                	test   %esi,%esi
  801a1e:	74 0a                	je     801a2a <ipc_recv+0x42>
  801a20:	a1 04 40 80 00       	mov    0x804004,%eax
  801a25:	8b 40 74             	mov    0x74(%eax),%eax
  801a28:	89 06                	mov    %eax,(%esi)
		if (perm_store != NULL) *perm_store = thisenv->env_ipc_perm;
  801a2a:	85 db                	test   %ebx,%ebx
  801a2c:	74 0a                	je     801a38 <ipc_recv+0x50>
  801a2e:	a1 04 40 80 00       	mov    0x804004,%eax
  801a33:	8b 40 78             	mov    0x78(%eax),%eax
  801a36:	89 03                	mov    %eax,(%ebx)
		return thisenv->env_ipc_value;
  801a38:	a1 04 40 80 00       	mov    0x804004,%eax
  801a3d:	8b 40 70             	mov    0x70(%eax),%eax
  801a40:	eb 14                	jmp    801a56 <ipc_recv+0x6e>
	} else {
		// fails;
		if (from_env_store != NULL) *from_env_store = 0;
  801a42:	85 f6                	test   %esi,%esi
  801a44:	74 06                	je     801a4c <ipc_recv+0x64>
  801a46:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		if (perm_store != NULL) *perm_store = 0;
  801a4c:	85 db                	test   %ebx,%ebx
  801a4e:	74 06                	je     801a56 <ipc_recv+0x6e>
  801a50:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
		return r;
	}
}
  801a56:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a59:	5b                   	pop    %ebx
  801a5a:	5e                   	pop    %esi
  801a5b:	c9                   	leave  
  801a5c:	c3                   	ret    

00801a5d <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801a5d:	55                   	push   %ebp
  801a5e:	89 e5                	mov    %esp,%ebp
  801a60:	57                   	push   %edi
  801a61:	56                   	push   %esi
  801a62:	53                   	push   %ebx
  801a63:	83 ec 0c             	sub    $0xc,%esp
  801a66:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801a69:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801a6c:	8b 75 14             	mov    0x14(%ebp),%esi
	// LAB 4: Your code here.
	// int sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
	int r;
	if (pg == NULL) pg = (void *)UTOP;
  801a6f:	85 db                	test   %ebx,%ebx
  801a71:	75 25                	jne    801a98 <ipc_send+0x3b>
  801a73:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
  801a78:	eb 1e                	jmp    801a98 <ipc_send+0x3b>
	
	while ((r = sys_ipc_try_send(to_env, val, pg, perm)) != 0) {
		if (r == -E_IPC_NOT_RECV) {
  801a7a:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801a7d:	75 07                	jne    801a86 <ipc_send+0x29>
			// cprintf("Try Again and Again....\n");
			sys_yield();
  801a7f:	e8 15 e7 ff ff       	call   800199 <sys_yield>
  801a84:	eb 12                	jmp    801a98 <ipc_send+0x3b>
		} else {
			panic("ipc_send error %e\n", r);
  801a86:	50                   	push   %eax
  801a87:	68 00 22 80 00       	push   $0x802200
  801a8c:	6a 43                	push   $0x43
  801a8e:	68 13 22 80 00       	push   $0x802213
  801a93:	e8 44 f5 ff ff       	call   800fdc <_panic>
	// LAB 4: Your code here.
	// int sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
	int r;
	if (pg == NULL) pg = (void *)UTOP;
	
	while ((r = sys_ipc_try_send(to_env, val, pg, perm)) != 0) {
  801a98:	56                   	push   %esi
  801a99:	53                   	push   %ebx
  801a9a:	57                   	push   %edi
  801a9b:	ff 75 08             	pushl  0x8(%ebp)
  801a9e:	e8 f3 e7 ff ff       	call   800296 <sys_ipc_try_send>
  801aa3:	83 c4 10             	add    $0x10,%esp
  801aa6:	85 c0                	test   %eax,%eax
  801aa8:	75 d0                	jne    801a7a <ipc_send+0x1d>
		} else {
			panic("ipc_send error %e\n", r);
		}
	}
	return;
}
  801aaa:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801aad:	5b                   	pop    %ebx
  801aae:	5e                   	pop    %esi
  801aaf:	5f                   	pop    %edi
  801ab0:	c9                   	leave  
  801ab1:	c3                   	ret    

00801ab2 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801ab2:	55                   	push   %ebp
  801ab3:	89 e5                	mov    %esp,%ebp
  801ab5:	53                   	push   %ebx
  801ab6:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	for (i = 0; i < NENV; i++)
		if (envs[i].env_type == type)
  801ab9:	39 1d 50 00 c0 ee    	cmp    %ebx,0xeec00050
  801abf:	74 22                	je     801ae3 <ipc_find_env+0x31>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801ac1:	b8 01 00 00 00       	mov    $0x1,%eax
		if (envs[i].env_type == type)
  801ac6:	8d 0c 85 00 00 00 00 	lea    0x0(,%eax,4),%ecx
  801acd:	89 c2                	mov    %eax,%edx
  801acf:	c1 e2 07             	shl    $0x7,%edx
  801ad2:	29 ca                	sub    %ecx,%edx
  801ad4:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801ada:	8b 52 50             	mov    0x50(%edx),%edx
  801add:	39 da                	cmp    %ebx,%edx
  801adf:	75 1d                	jne    801afe <ipc_find_env+0x4c>
  801ae1:	eb 05                	jmp    801ae8 <ipc_find_env+0x36>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801ae3:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
			return envs[i].env_id;
  801ae8:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  801aef:	c1 e0 07             	shl    $0x7,%eax
  801af2:	29 d0                	sub    %edx,%eax
  801af4:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  801af9:	8b 40 40             	mov    0x40(%eax),%eax
  801afc:	eb 0c                	jmp    801b0a <ipc_find_env+0x58>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801afe:	40                   	inc    %eax
  801aff:	3d 00 04 00 00       	cmp    $0x400,%eax
  801b04:	75 c0                	jne    801ac6 <ipc_find_env+0x14>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801b06:	66 b8 00 00          	mov    $0x0,%ax
}
  801b0a:	5b                   	pop    %ebx
  801b0b:	c9                   	leave  
  801b0c:	c3                   	ret    
  801b0d:	00 00                	add    %al,(%eax)
	...

00801b10 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801b10:	55                   	push   %ebp
  801b11:	89 e5                	mov    %esp,%ebp
  801b13:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801b16:	89 c2                	mov    %eax,%edx
  801b18:	c1 ea 16             	shr    $0x16,%edx
  801b1b:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801b22:	f6 c2 01             	test   $0x1,%dl
  801b25:	74 1e                	je     801b45 <pageref+0x35>
		return 0;
	pte = uvpt[PGNUM(v)];
  801b27:	c1 e8 0c             	shr    $0xc,%eax
  801b2a:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  801b31:	a8 01                	test   $0x1,%al
  801b33:	74 17                	je     801b4c <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801b35:	c1 e8 0c             	shr    $0xc,%eax
  801b38:	66 8b 04 c5 04 00 00 	mov    -0x10fffffc(,%eax,8),%ax
  801b3f:	ef 
  801b40:	0f b7 c0             	movzwl %ax,%eax
  801b43:	eb 0c                	jmp    801b51 <pageref+0x41>
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
		return 0;
  801b45:	b8 00 00 00 00       	mov    $0x0,%eax
  801b4a:	eb 05                	jmp    801b51 <pageref+0x41>
	pte = uvpt[PGNUM(v)];
	if (!(pte & PTE_P))
		return 0;
  801b4c:	b8 00 00 00 00       	mov    $0x0,%eax
	return pages[PGNUM(pte)].pp_ref;
}
  801b51:	c9                   	leave  
  801b52:	c3                   	ret    
	...

00801b54 <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  801b54:	55                   	push   %ebp
  801b55:	89 e5                	mov    %esp,%ebp
  801b57:	57                   	push   %edi
  801b58:	56                   	push   %esi
  801b59:	83 ec 10             	sub    $0x10,%esp
  801b5c:	8b 7d 08             	mov    0x8(%ebp),%edi
  801b5f:	8b 4d 10             	mov    0x10(%ebp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  801b62:	89 7d f0             	mov    %edi,-0x10(%ebp)
  801b65:	8b 75 0c             	mov    0xc(%ebp),%esi
  const DWunion dd = {.ll = d};
  801b68:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  801b6b:	8b 45 14             	mov    0x14(%ebp),%eax
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  801b6e:	85 c0                	test   %eax,%eax
  801b70:	75 2e                	jne    801ba0 <__udivdi3+0x4c>
    {
      if (d0 > n1)
  801b72:	39 f1                	cmp    %esi,%ecx
  801b74:	77 5a                	ja     801bd0 <__udivdi3+0x7c>
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  801b76:	85 c9                	test   %ecx,%ecx
  801b78:	75 0b                	jne    801b85 <__udivdi3+0x31>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  801b7a:	b8 01 00 00 00       	mov    $0x1,%eax
  801b7f:	31 d2                	xor    %edx,%edx
  801b81:	f7 f1                	div    %ecx
  801b83:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  801b85:	31 d2                	xor    %edx,%edx
  801b87:	89 f0                	mov    %esi,%eax
  801b89:	f7 f1                	div    %ecx
  801b8b:	89 c6                	mov    %eax,%esi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801b8d:	89 f8                	mov    %edi,%eax
  801b8f:	f7 f1                	div    %ecx
  801b91:	89 c7                	mov    %eax,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  801b93:	89 f8                	mov    %edi,%eax
  801b95:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801b97:	83 c4 10             	add    $0x10,%esp
  801b9a:	5e                   	pop    %esi
  801b9b:	5f                   	pop    %edi
  801b9c:	c9                   	leave  
  801b9d:	c3                   	ret    
  801b9e:	66 90                	xchg   %ax,%ax
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  801ba0:	39 f0                	cmp    %esi,%eax
  801ba2:	77 1c                	ja     801bc0 <__udivdi3+0x6c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  801ba4:	0f bd f8             	bsr    %eax,%edi
	  if (bm == 0)
  801ba7:	83 f7 1f             	xor    $0x1f,%edi
  801baa:	75 3c                	jne    801be8 <__udivdi3+0x94>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  801bac:	39 f0                	cmp    %esi,%eax
  801bae:	0f 82 90 00 00 00    	jb     801c44 <__udivdi3+0xf0>
  801bb4:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801bb7:	39 55 f4             	cmp    %edx,-0xc(%ebp)
  801bba:	0f 86 84 00 00 00    	jbe    801c44 <__udivdi3+0xf0>
  801bc0:	31 f6                	xor    %esi,%esi
  801bc2:	31 ff                	xor    %edi,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  801bc4:	89 f8                	mov    %edi,%eax
  801bc6:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801bc8:	83 c4 10             	add    $0x10,%esp
  801bcb:	5e                   	pop    %esi
  801bcc:	5f                   	pop    %edi
  801bcd:	c9                   	leave  
  801bce:	c3                   	ret    
  801bcf:	90                   	nop
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801bd0:	89 f2                	mov    %esi,%edx
  801bd2:	89 f8                	mov    %edi,%eax
  801bd4:	f7 f1                	div    %ecx
  801bd6:	89 c7                	mov    %eax,%edi
  801bd8:	31 f6                	xor    %esi,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  801bda:	89 f8                	mov    %edi,%eax
  801bdc:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801bde:	83 c4 10             	add    $0x10,%esp
  801be1:	5e                   	pop    %esi
  801be2:	5f                   	pop    %edi
  801be3:	c9                   	leave  
  801be4:	c3                   	ret    
  801be5:	8d 76 00             	lea    0x0(%esi),%esi
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  801be8:	89 f9                	mov    %edi,%ecx
  801bea:	d3 e0                	shl    %cl,%eax
  801bec:	89 45 e8             	mov    %eax,-0x18(%ebp)
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  801bef:	b8 20 00 00 00       	mov    $0x20,%eax
  801bf4:	29 f8                	sub    %edi,%eax

	      d1 = (d1 << bm) | (d0 >> b);
  801bf6:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801bf9:	88 c1                	mov    %al,%cl
  801bfb:	d3 ea                	shr    %cl,%edx
  801bfd:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  801c00:	09 ca                	or     %ecx,%edx
  801c02:	89 55 ec             	mov    %edx,-0x14(%ebp)
	      d0 = d0 << bm;
  801c05:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801c08:	89 f9                	mov    %edi,%ecx
  801c0a:	d3 e2                	shl    %cl,%edx
  801c0c:	89 55 f4             	mov    %edx,-0xc(%ebp)
	      n2 = n1 >> b;
  801c0f:	89 f2                	mov    %esi,%edx
  801c11:	88 c1                	mov    %al,%cl
  801c13:	d3 ea                	shr    %cl,%edx
  801c15:	89 55 e8             	mov    %edx,-0x18(%ebp)
	      n1 = (n1 << bm) | (n0 >> b);
  801c18:	89 f2                	mov    %esi,%edx
  801c1a:	89 f9                	mov    %edi,%ecx
  801c1c:	d3 e2                	shl    %cl,%edx
  801c1e:	8b 75 f0             	mov    -0x10(%ebp),%esi
  801c21:	88 c1                	mov    %al,%cl
  801c23:	d3 ee                	shr    %cl,%esi
  801c25:	09 d6                	or     %edx,%esi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  801c27:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  801c2a:	89 f0                	mov    %esi,%eax
  801c2c:	89 ca                	mov    %ecx,%edx
  801c2e:	f7 75 ec             	divl   -0x14(%ebp)
  801c31:	89 d1                	mov    %edx,%ecx
  801c33:	89 c6                	mov    %eax,%esi
	      umul_ppmm (m1, m0, q0, d0);
  801c35:	f7 65 f4             	mull   -0xc(%ebp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801c38:	39 d1                	cmp    %edx,%ecx
  801c3a:	72 28                	jb     801c64 <__udivdi3+0x110>
  801c3c:	74 1a                	je     801c58 <__udivdi3+0x104>
  801c3e:	89 f7                	mov    %esi,%edi
  801c40:	31 f6                	xor    %esi,%esi
  801c42:	eb 80                	jmp    801bc4 <__udivdi3+0x70>
	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  801c44:	31 f6                	xor    %esi,%esi
  801c46:	bf 01 00 00 00       	mov    $0x1,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  801c4b:	89 f8                	mov    %edi,%eax
  801c4d:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801c4f:	83 c4 10             	add    $0x10,%esp
  801c52:	5e                   	pop    %esi
  801c53:	5f                   	pop    %edi
  801c54:	c9                   	leave  
  801c55:	c3                   	ret    
  801c56:	66 90                	xchg   %ax,%ax

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  801c58:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801c5b:	89 f9                	mov    %edi,%ecx
  801c5d:	d3 e2                	shl    %cl,%edx

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801c5f:	39 c2                	cmp    %eax,%edx
  801c61:	73 db                	jae    801c3e <__udivdi3+0xea>
  801c63:	90                   	nop
		{
		  q0--;
  801c64:	8d 7e ff             	lea    -0x1(%esi),%edi
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  801c67:	31 f6                	xor    %esi,%esi
  801c69:	e9 56 ff ff ff       	jmp    801bc4 <__udivdi3+0x70>
	...

00801c70 <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  801c70:	55                   	push   %ebp
  801c71:	89 e5                	mov    %esp,%ebp
  801c73:	57                   	push   %edi
  801c74:	56                   	push   %esi
  801c75:	83 ec 20             	sub    $0x20,%esp
  801c78:	8b 45 08             	mov    0x8(%ebp),%eax
  801c7b:	8b 4d 10             	mov    0x10(%ebp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  801c7e:	89 45 e8             	mov    %eax,-0x18(%ebp)
  801c81:	8b 75 0c             	mov    0xc(%ebp),%esi
  const DWunion dd = {.ll = d};
  801c84:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  801c87:	8b 7d 14             	mov    0x14(%ebp),%edi
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  801c8a:	89 45 f0             	mov    %eax,-0x10(%ebp)
  n1 = nn.s.high;
  801c8d:	89 f2                	mov    %esi,%edx

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  801c8f:	85 ff                	test   %edi,%edi
  801c91:	75 15                	jne    801ca8 <__umoddi3+0x38>
    {
      if (d0 > n1)
  801c93:	39 f1                	cmp    %esi,%ecx
  801c95:	0f 86 99 00 00 00    	jbe    801d34 <__umoddi3+0xc4>
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801c9b:	f7 f1                	div    %ecx

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
  801c9d:	89 d0                	mov    %edx,%eax
  801c9f:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  801ca1:	83 c4 20             	add    $0x20,%esp
  801ca4:	5e                   	pop    %esi
  801ca5:	5f                   	pop    %edi
  801ca6:	c9                   	leave  
  801ca7:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  801ca8:	39 f7                	cmp    %esi,%edi
  801caa:	0f 87 a4 00 00 00    	ja     801d54 <__umoddi3+0xe4>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  801cb0:	0f bd c7             	bsr    %edi,%eax
	  if (bm == 0)
  801cb3:	83 f0 1f             	xor    $0x1f,%eax
  801cb6:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801cb9:	0f 84 a1 00 00 00    	je     801d60 <__umoddi3+0xf0>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  801cbf:	89 f8                	mov    %edi,%eax
  801cc1:	8a 4d ec             	mov    -0x14(%ebp),%cl
  801cc4:	d3 e0                	shl    %cl,%eax
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  801cc6:	bf 20 00 00 00       	mov    $0x20,%edi
  801ccb:	2b 7d ec             	sub    -0x14(%ebp),%edi

	      d1 = (d1 << bm) | (d0 >> b);
  801cce:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801cd1:	89 f9                	mov    %edi,%ecx
  801cd3:	d3 ea                	shr    %cl,%edx
  801cd5:	09 c2                	or     %eax,%edx
  801cd7:	89 55 f0             	mov    %edx,-0x10(%ebp)
	      d0 = d0 << bm;
  801cda:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801cdd:	8a 4d ec             	mov    -0x14(%ebp),%cl
  801ce0:	d3 e0                	shl    %cl,%eax
  801ce2:	89 45 f4             	mov    %eax,-0xc(%ebp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  801ce5:	89 f2                	mov    %esi,%edx
  801ce7:	d3 e2                	shl    %cl,%edx
	      n0 = n0 << bm;
  801ce9:	8b 45 e8             	mov    -0x18(%ebp),%eax
  801cec:	d3 e0                	shl    %cl,%eax
  801cee:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  801cf1:	8b 45 e8             	mov    -0x18(%ebp),%eax
  801cf4:	89 f9                	mov    %edi,%ecx
  801cf6:	d3 e8                	shr    %cl,%eax
  801cf8:	09 d0                	or     %edx,%eax

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  801cfa:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  801cfc:	89 f2                	mov    %esi,%edx
  801cfe:	f7 75 f0             	divl   -0x10(%ebp)
  801d01:	89 d6                	mov    %edx,%esi
	      umul_ppmm (m1, m0, q0, d0);
  801d03:	f7 65 f4             	mull   -0xc(%ebp)
  801d06:	89 55 e8             	mov    %edx,-0x18(%ebp)
  801d09:	89 c1                	mov    %eax,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801d0b:	39 d6                	cmp    %edx,%esi
  801d0d:	72 71                	jb     801d80 <__umoddi3+0x110>
  801d0f:	74 7f                	je     801d90 <__umoddi3+0x120>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  801d11:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801d14:	29 c8                	sub    %ecx,%eax
  801d16:	19 d6                	sbb    %edx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
  801d18:	8a 4d ec             	mov    -0x14(%ebp),%cl
  801d1b:	d3 e8                	shr    %cl,%eax
  801d1d:	89 f2                	mov    %esi,%edx
  801d1f:	89 f9                	mov    %edi,%ecx
  801d21:	d3 e2                	shl    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
  801d23:	09 d0                	or     %edx,%eax
  801d25:	89 f2                	mov    %esi,%edx
  801d27:	8a 4d ec             	mov    -0x14(%ebp),%cl
  801d2a:	d3 ea                	shr    %cl,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  801d2c:	83 c4 20             	add    $0x20,%esp
  801d2f:	5e                   	pop    %esi
  801d30:	5f                   	pop    %edi
  801d31:	c9                   	leave  
  801d32:	c3                   	ret    
  801d33:	90                   	nop
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  801d34:	85 c9                	test   %ecx,%ecx
  801d36:	75 0b                	jne    801d43 <__umoddi3+0xd3>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  801d38:	b8 01 00 00 00       	mov    $0x1,%eax
  801d3d:	31 d2                	xor    %edx,%edx
  801d3f:	f7 f1                	div    %ecx
  801d41:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  801d43:	89 f0                	mov    %esi,%eax
  801d45:	31 d2                	xor    %edx,%edx
  801d47:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801d49:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801d4c:	f7 f1                	div    %ecx
  801d4e:	e9 4a ff ff ff       	jmp    801c9d <__umoddi3+0x2d>
  801d53:	90                   	nop
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
  801d54:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  801d56:	83 c4 20             	add    $0x20,%esp
  801d59:	5e                   	pop    %esi
  801d5a:	5f                   	pop    %edi
  801d5b:	c9                   	leave  
  801d5c:	c3                   	ret    
  801d5d:	8d 76 00             	lea    0x0(%esi),%esi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  801d60:	39 f7                	cmp    %esi,%edi
  801d62:	72 05                	jb     801d69 <__umoddi3+0xf9>
  801d64:	3b 4d f0             	cmp    -0x10(%ebp),%ecx
  801d67:	77 0c                	ja     801d75 <__umoddi3+0x105>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  801d69:	89 f2                	mov    %esi,%edx
  801d6b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801d6e:	29 c8                	sub    %ecx,%eax
  801d70:	19 fa                	sbb    %edi,%edx
  801d72:	89 45 f0             	mov    %eax,-0x10(%ebp)

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
  801d75:	8b 45 f0             	mov    -0x10(%ebp),%eax
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  801d78:	83 c4 20             	add    $0x20,%esp
  801d7b:	5e                   	pop    %esi
  801d7c:	5f                   	pop    %edi
  801d7d:	c9                   	leave  
  801d7e:	c3                   	ret    
  801d7f:	90                   	nop
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  801d80:	8b 55 e8             	mov    -0x18(%ebp),%edx
  801d83:	89 c1                	mov    %eax,%ecx
  801d85:	2b 4d f4             	sub    -0xc(%ebp),%ecx
  801d88:	1b 55 f0             	sbb    -0x10(%ebp),%edx
  801d8b:	eb 84                	jmp    801d11 <__umoddi3+0xa1>
  801d8d:	8d 76 00             	lea    0x0(%esi),%esi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801d90:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  801d93:	72 eb                	jb     801d80 <__umoddi3+0x110>
  801d95:	89 f2                	mov    %esi,%edx
  801d97:	e9 75 ff ff ff       	jmp    801d11 <__umoddi3+0xa1>
