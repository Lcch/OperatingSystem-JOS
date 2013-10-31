
obj/user/softint.debug:     file format elf32-i386


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
  80002c:	e8 0b 00 00 00       	call   80003c <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800034 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
	asm volatile("int $14");	// page fault
  800037:	cd 0e                	int    $0xe
}
  800039:	c9                   	leave  
  80003a:	c3                   	ret    
	...

0080003c <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80003c:	55                   	push   %ebp
  80003d:	89 e5                	mov    %esp,%ebp
  80003f:	56                   	push   %esi
  800040:	53                   	push   %ebx
  800041:	8b 75 08             	mov    0x8(%ebp),%esi
  800044:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = envs + ENVX(sys_getenvid());
  800047:	e8 15 01 00 00       	call   800161 <sys_getenvid>
  80004c:	25 ff 03 00 00       	and    $0x3ff,%eax
  800051:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  800058:	c1 e0 07             	shl    $0x7,%eax
  80005b:	29 d0                	sub    %edx,%eax
  80005d:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800062:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800067:	85 f6                	test   %esi,%esi
  800069:	7e 07                	jle    800072 <libmain+0x36>
		binaryname = argv[0];
  80006b:	8b 03                	mov    (%ebx),%eax
  80006d:	a3 00 30 80 00       	mov    %eax,0x803000
	// call user main routine
	umain(argc, argv);
  800072:	83 ec 08             	sub    $0x8,%esp
  800075:	53                   	push   %ebx
  800076:	56                   	push   %esi
  800077:	e8 b8 ff ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  80007c:	e8 0b 00 00 00       	call   80008c <exit>
  800081:	83 c4 10             	add    $0x10,%esp
}
  800084:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800087:	5b                   	pop    %ebx
  800088:	5e                   	pop    %esi
  800089:	c9                   	leave  
  80008a:	c3                   	ret    
	...

0080008c <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80008c:	55                   	push   %ebp
  80008d:	89 e5                	mov    %esp,%ebp
  80008f:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800092:	e8 5f 04 00 00       	call   8004f6 <close_all>
	sys_env_destroy(0);
  800097:	83 ec 0c             	sub    $0xc,%esp
  80009a:	6a 00                	push   $0x0
  80009c:	e8 9e 00 00 00       	call   80013f <sys_env_destroy>
  8000a1:	83 c4 10             	add    $0x10,%esp
}
  8000a4:	c9                   	leave  
  8000a5:	c3                   	ret    
	...

008000a8 <syscall>:
	return ret;
}

static int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  8000a8:	55                   	push   %ebp
  8000a9:	89 e5                	mov    %esp,%ebp
  8000ab:	57                   	push   %edi
  8000ac:	56                   	push   %esi
  8000ad:	53                   	push   %ebx
  8000ae:	83 ec 1c             	sub    $0x1c,%esp
  8000b1:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8000b4:	89 55 e0             	mov    %edx,-0x20(%ebp)
  8000b7:	89 ca                	mov    %ecx,%edx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000b9:	8b 75 14             	mov    0x14(%ebp),%esi
  8000bc:	8b 7d 10             	mov    0x10(%ebp),%edi
  8000bf:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8000c2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8000c5:	cd 30                	int    $0x30
  8000c7:	89 c2                	mov    %eax,%edx
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8000c9:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8000cd:	74 1c                	je     8000eb <syscall+0x43>
  8000cf:	85 c0                	test   %eax,%eax
  8000d1:	7e 18                	jle    8000eb <syscall+0x43>
		panic("syscall %d returned %d (> 0)", num, ret);
  8000d3:	83 ec 0c             	sub    $0xc,%esp
  8000d6:	50                   	push   %eax
  8000d7:	ff 75 e4             	pushl  -0x1c(%ebp)
  8000da:	68 6a 1d 80 00       	push   $0x801d6a
  8000df:	6a 42                	push   $0x42
  8000e1:	68 87 1d 80 00       	push   $0x801d87
  8000e6:	e8 b5 0e 00 00       	call   800fa0 <_panic>

	return ret;
}
  8000eb:	89 d0                	mov    %edx,%eax
  8000ed:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8000f0:	5b                   	pop    %ebx
  8000f1:	5e                   	pop    %esi
  8000f2:	5f                   	pop    %edi
  8000f3:	c9                   	leave  
  8000f4:	c3                   	ret    

008000f5 <sys_cputs>:

void
sys_cputs(const char *s, size_t len)
{	
  8000f5:	55                   	push   %ebp
  8000f6:	89 e5                	mov    %esp,%ebp
  8000f8:	83 ec 08             	sub    $0x8,%esp
	// my_sysenter(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
	// return;
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
  8000fb:	6a 00                	push   $0x0
  8000fd:	6a 00                	push   $0x0
  8000ff:	6a 00                	push   $0x0
  800101:	ff 75 0c             	pushl  0xc(%ebp)
  800104:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800107:	ba 00 00 00 00       	mov    $0x0,%edx
  80010c:	b8 00 00 00 00       	mov    $0x0,%eax
  800111:	e8 92 ff ff ff       	call   8000a8 <syscall>
  800116:	83 c4 10             	add    $0x10,%esp
	return;
}
  800119:	c9                   	leave  
  80011a:	c3                   	ret    

0080011b <sys_cgetc>:

int
sys_cgetc(void)
{
  80011b:	55                   	push   %ebp
  80011c:	89 e5                	mov    %esp,%ebp
  80011e:	83 ec 08             	sub    $0x8,%esp
	// return my_sysenter(SYS_cgetc, 0, 0, 0, 0, 0, 0);
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
  800121:	6a 00                	push   $0x0
  800123:	6a 00                	push   $0x0
  800125:	6a 00                	push   $0x0
  800127:	6a 00                	push   $0x0
  800129:	b9 00 00 00 00       	mov    $0x0,%ecx
  80012e:	ba 00 00 00 00       	mov    $0x0,%edx
  800133:	b8 01 00 00 00       	mov    $0x1,%eax
  800138:	e8 6b ff ff ff       	call   8000a8 <syscall>
}
  80013d:	c9                   	leave  
  80013e:	c3                   	ret    

0080013f <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  80013f:	55                   	push   %ebp
  800140:	89 e5                	mov    %esp,%ebp
  800142:	83 ec 08             	sub    $0x8,%esp
	// return my_sysenter(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
  800145:	6a 00                	push   $0x0
  800147:	6a 00                	push   $0x0
  800149:	6a 00                	push   $0x0
  80014b:	6a 00                	push   $0x0
  80014d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800150:	ba 01 00 00 00       	mov    $0x1,%edx
  800155:	b8 03 00 00 00       	mov    $0x3,%eax
  80015a:	e8 49 ff ff ff       	call   8000a8 <syscall>
}
  80015f:	c9                   	leave  
  800160:	c3                   	ret    

00800161 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800161:	55                   	push   %ebp
  800162:	89 e5                	mov    %esp,%ebp
  800164:	83 ec 08             	sub    $0x8,%esp
	// return my_sysenter(SYS_getenvid, 0, 0, 0, 0, 0, 0);
	return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
  800167:	6a 00                	push   $0x0
  800169:	6a 00                	push   $0x0
  80016b:	6a 00                	push   $0x0
  80016d:	6a 00                	push   $0x0
  80016f:	b9 00 00 00 00       	mov    $0x0,%ecx
  800174:	ba 00 00 00 00       	mov    $0x0,%edx
  800179:	b8 02 00 00 00       	mov    $0x2,%eax
  80017e:	e8 25 ff ff ff       	call   8000a8 <syscall>
}
  800183:	c9                   	leave  
  800184:	c3                   	ret    

00800185 <sys_yield>:

void
sys_yield(void)
{
  800185:	55                   	push   %ebp
  800186:	89 e5                	mov    %esp,%ebp
  800188:	83 ec 08             	sub    $0x8,%esp
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
  80018b:	6a 00                	push   $0x0
  80018d:	6a 00                	push   $0x0
  80018f:	6a 00                	push   $0x0
  800191:	6a 00                	push   $0x0
  800193:	b9 00 00 00 00       	mov    $0x0,%ecx
  800198:	ba 00 00 00 00       	mov    $0x0,%edx
  80019d:	b8 0b 00 00 00       	mov    $0xb,%eax
  8001a2:	e8 01 ff ff ff       	call   8000a8 <syscall>
  8001a7:	83 c4 10             	add    $0x10,%esp
}
  8001aa:	c9                   	leave  
  8001ab:	c3                   	ret    

008001ac <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  8001ac:	55                   	push   %ebp
  8001ad:	89 e5                	mov    %esp,%ebp
  8001af:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
  8001b2:	6a 00                	push   $0x0
  8001b4:	6a 00                	push   $0x0
  8001b6:	ff 75 10             	pushl  0x10(%ebp)
  8001b9:	ff 75 0c             	pushl  0xc(%ebp)
  8001bc:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8001bf:	ba 01 00 00 00       	mov    $0x1,%edx
  8001c4:	b8 04 00 00 00       	mov    $0x4,%eax
  8001c9:	e8 da fe ff ff       	call   8000a8 <syscall>
}
  8001ce:	c9                   	leave  
  8001cf:	c3                   	ret    

008001d0 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8001d0:	55                   	push   %ebp
  8001d1:	89 e5                	mov    %esp,%ebp
  8001d3:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
  8001d6:	ff 75 18             	pushl  0x18(%ebp)
  8001d9:	ff 75 14             	pushl  0x14(%ebp)
  8001dc:	ff 75 10             	pushl  0x10(%ebp)
  8001df:	ff 75 0c             	pushl  0xc(%ebp)
  8001e2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8001e5:	ba 01 00 00 00       	mov    $0x1,%edx
  8001ea:	b8 05 00 00 00       	mov    $0x5,%eax
  8001ef:	e8 b4 fe ff ff       	call   8000a8 <syscall>
}
  8001f4:	c9                   	leave  
  8001f5:	c3                   	ret    

008001f6 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  8001f6:	55                   	push   %ebp
  8001f7:	89 e5                	mov    %esp,%ebp
  8001f9:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
  8001fc:	6a 00                	push   $0x0
  8001fe:	6a 00                	push   $0x0
  800200:	6a 00                	push   $0x0
  800202:	ff 75 0c             	pushl  0xc(%ebp)
  800205:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800208:	ba 01 00 00 00       	mov    $0x1,%edx
  80020d:	b8 06 00 00 00       	mov    $0x6,%eax
  800212:	e8 91 fe ff ff       	call   8000a8 <syscall>
}
  800217:	c9                   	leave  
  800218:	c3                   	ret    

00800219 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800219:	55                   	push   %ebp
  80021a:	89 e5                	mov    %esp,%ebp
  80021c:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
  80021f:	6a 00                	push   $0x0
  800221:	6a 00                	push   $0x0
  800223:	6a 00                	push   $0x0
  800225:	ff 75 0c             	pushl  0xc(%ebp)
  800228:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80022b:	ba 01 00 00 00       	mov    $0x1,%edx
  800230:	b8 08 00 00 00       	mov    $0x8,%eax
  800235:	e8 6e fe ff ff       	call   8000a8 <syscall>
}
  80023a:	c9                   	leave  
  80023b:	c3                   	ret    

0080023c <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  80023c:	55                   	push   %ebp
  80023d:	89 e5                	mov    %esp,%ebp
  80023f:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
  800242:	6a 00                	push   $0x0
  800244:	6a 00                	push   $0x0
  800246:	6a 00                	push   $0x0
  800248:	ff 75 0c             	pushl  0xc(%ebp)
  80024b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80024e:	ba 01 00 00 00       	mov    $0x1,%edx
  800253:	b8 09 00 00 00       	mov    $0x9,%eax
  800258:	e8 4b fe ff ff       	call   8000a8 <syscall>
}
  80025d:	c9                   	leave  
  80025e:	c3                   	ret    

0080025f <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  80025f:	55                   	push   %ebp
  800260:	89 e5                	mov    %esp,%ebp
  800262:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
  800265:	6a 00                	push   $0x0
  800267:	6a 00                	push   $0x0
  800269:	6a 00                	push   $0x0
  80026b:	ff 75 0c             	pushl  0xc(%ebp)
  80026e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800271:	ba 01 00 00 00       	mov    $0x1,%edx
  800276:	b8 0a 00 00 00       	mov    $0xa,%eax
  80027b:	e8 28 fe ff ff       	call   8000a8 <syscall>
}
  800280:	c9                   	leave  
  800281:	c3                   	ret    

00800282 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800282:	55                   	push   %ebp
  800283:	89 e5                	mov    %esp,%ebp
  800285:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
  800288:	6a 00                	push   $0x0
  80028a:	ff 75 14             	pushl  0x14(%ebp)
  80028d:	ff 75 10             	pushl  0x10(%ebp)
  800290:	ff 75 0c             	pushl  0xc(%ebp)
  800293:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800296:	ba 00 00 00 00       	mov    $0x0,%edx
  80029b:	b8 0c 00 00 00       	mov    $0xc,%eax
  8002a0:	e8 03 fe ff ff       	call   8000a8 <syscall>
}
  8002a5:	c9                   	leave  
  8002a6:	c3                   	ret    

008002a7 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  8002a7:	55                   	push   %ebp
  8002a8:	89 e5                	mov    %esp,%ebp
  8002aa:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
  8002ad:	6a 00                	push   $0x0
  8002af:	6a 00                	push   $0x0
  8002b1:	6a 00                	push   $0x0
  8002b3:	6a 00                	push   $0x0
  8002b5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8002b8:	ba 01 00 00 00       	mov    $0x1,%edx
  8002bd:	b8 0d 00 00 00       	mov    $0xd,%eax
  8002c2:	e8 e1 fd ff ff       	call   8000a8 <syscall>
}
  8002c7:	c9                   	leave  
  8002c8:	c3                   	ret    

008002c9 <sys_set_priority>:

int
sys_set_priority(envid_t envid, uint32_t new_priority)
{
  8002c9:	55                   	push   %ebp
  8002ca:	89 e5                	mov    %esp,%ebp
  8002cc:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_set_priority, 0, envid, new_priority, 0, 0, 0);
  8002cf:	6a 00                	push   $0x0
  8002d1:	6a 00                	push   $0x0
  8002d3:	6a 00                	push   $0x0
  8002d5:	ff 75 0c             	pushl  0xc(%ebp)
  8002d8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8002db:	ba 00 00 00 00       	mov    $0x0,%edx
  8002e0:	b8 0e 00 00 00       	mov    $0xe,%eax
  8002e5:	e8 be fd ff ff       	call   8000a8 <syscall>
}
  8002ea:	c9                   	leave  
  8002eb:	c3                   	ret    

008002ec <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8002ec:	55                   	push   %ebp
  8002ed:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8002ef:	8b 45 08             	mov    0x8(%ebp),%eax
  8002f2:	05 00 00 00 30       	add    $0x30000000,%eax
  8002f7:	c1 e8 0c             	shr    $0xc,%eax
}
  8002fa:	c9                   	leave  
  8002fb:	c3                   	ret    

008002fc <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8002fc:	55                   	push   %ebp
  8002fd:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  8002ff:	ff 75 08             	pushl  0x8(%ebp)
  800302:	e8 e5 ff ff ff       	call   8002ec <fd2num>
  800307:	83 c4 04             	add    $0x4,%esp
  80030a:	05 20 00 0d 00       	add    $0xd0020,%eax
  80030f:	c1 e0 0c             	shl    $0xc,%eax
}
  800312:	c9                   	leave  
  800313:	c3                   	ret    

00800314 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800314:	55                   	push   %ebp
  800315:	89 e5                	mov    %esp,%ebp
  800317:	53                   	push   %ebx
  800318:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  80031b:	a1 00 dd 7b ef       	mov    0xef7bdd00,%eax
  800320:	a8 01                	test   $0x1,%al
  800322:	74 34                	je     800358 <fd_alloc+0x44>
  800324:	a1 00 00 74 ef       	mov    0xef740000,%eax
  800329:	a8 01                	test   $0x1,%al
  80032b:	74 32                	je     80035f <fd_alloc+0x4b>
  80032d:	b8 00 10 00 d0       	mov    $0xd0001000,%eax
  800332:	89 c1                	mov    %eax,%ecx
  800334:	89 c2                	mov    %eax,%edx
  800336:	c1 ea 16             	shr    $0x16,%edx
  800339:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800340:	f6 c2 01             	test   $0x1,%dl
  800343:	74 1f                	je     800364 <fd_alloc+0x50>
  800345:	89 c2                	mov    %eax,%edx
  800347:	c1 ea 0c             	shr    $0xc,%edx
  80034a:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800351:	f6 c2 01             	test   $0x1,%dl
  800354:	75 17                	jne    80036d <fd_alloc+0x59>
  800356:	eb 0c                	jmp    800364 <fd_alloc+0x50>
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  800358:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
  80035d:	eb 05                	jmp    800364 <fd_alloc+0x50>
  80035f:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
  800364:	89 0b                	mov    %ecx,(%ebx)
			return 0;
  800366:	b8 00 00 00 00       	mov    $0x0,%eax
  80036b:	eb 17                	jmp    800384 <fd_alloc+0x70>
  80036d:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800372:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800377:	75 b9                	jne    800332 <fd_alloc+0x1e>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800379:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_MAX_OPEN;
  80037f:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800384:	5b                   	pop    %ebx
  800385:	c9                   	leave  
  800386:	c3                   	ret    

00800387 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800387:	55                   	push   %ebp
  800388:	89 e5                	mov    %esp,%ebp
  80038a:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  80038d:	83 f8 1f             	cmp    $0x1f,%eax
  800390:	77 36                	ja     8003c8 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800392:	05 00 00 0d 00       	add    $0xd0000,%eax
  800397:	c1 e0 0c             	shl    $0xc,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  80039a:	89 c2                	mov    %eax,%edx
  80039c:	c1 ea 16             	shr    $0x16,%edx
  80039f:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8003a6:	f6 c2 01             	test   $0x1,%dl
  8003a9:	74 24                	je     8003cf <fd_lookup+0x48>
  8003ab:	89 c2                	mov    %eax,%edx
  8003ad:	c1 ea 0c             	shr    $0xc,%edx
  8003b0:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8003b7:	f6 c2 01             	test   $0x1,%dl
  8003ba:	74 1a                	je     8003d6 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8003bc:	8b 55 0c             	mov    0xc(%ebp),%edx
  8003bf:	89 02                	mov    %eax,(%edx)
	return 0;
  8003c1:	b8 00 00 00 00       	mov    $0x0,%eax
  8003c6:	eb 13                	jmp    8003db <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8003c8:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8003cd:	eb 0c                	jmp    8003db <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8003cf:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8003d4:	eb 05                	jmp    8003db <fd_lookup+0x54>
  8003d6:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  8003db:	c9                   	leave  
  8003dc:	c3                   	ret    

008003dd <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8003dd:	55                   	push   %ebp
  8003de:	89 e5                	mov    %esp,%ebp
  8003e0:	53                   	push   %ebx
  8003e1:	83 ec 04             	sub    $0x4,%esp
  8003e4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8003e7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
		if (devtab[i]->dev_id == dev_id) {
  8003ea:	39 0d 04 30 80 00    	cmp    %ecx,0x803004
  8003f0:	74 0d                	je     8003ff <dev_lookup+0x22>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8003f2:	b8 00 00 00 00       	mov    $0x0,%eax
  8003f7:	eb 14                	jmp    80040d <dev_lookup+0x30>
		if (devtab[i]->dev_id == dev_id) {
  8003f9:	39 0a                	cmp    %ecx,(%edx)
  8003fb:	75 10                	jne    80040d <dev_lookup+0x30>
  8003fd:	eb 05                	jmp    800404 <dev_lookup+0x27>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8003ff:	ba 04 30 80 00       	mov    $0x803004,%edx
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
  800404:	89 13                	mov    %edx,(%ebx)
			return 0;
  800406:	b8 00 00 00 00       	mov    $0x0,%eax
  80040b:	eb 31                	jmp    80043e <dev_lookup+0x61>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  80040d:	40                   	inc    %eax
  80040e:	8b 14 85 14 1e 80 00 	mov    0x801e14(,%eax,4),%edx
  800415:	85 d2                	test   %edx,%edx
  800417:	75 e0                	jne    8003f9 <dev_lookup+0x1c>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800419:	a1 04 40 80 00       	mov    0x804004,%eax
  80041e:	8b 40 48             	mov    0x48(%eax),%eax
  800421:	83 ec 04             	sub    $0x4,%esp
  800424:	51                   	push   %ecx
  800425:	50                   	push   %eax
  800426:	68 98 1d 80 00       	push   $0x801d98
  80042b:	e8 48 0c 00 00       	call   801078 <cprintf>
	*dev = 0;
  800430:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_INVAL;
  800436:	83 c4 10             	add    $0x10,%esp
  800439:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  80043e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800441:	c9                   	leave  
  800442:	c3                   	ret    

00800443 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800443:	55                   	push   %ebp
  800444:	89 e5                	mov    %esp,%ebp
  800446:	56                   	push   %esi
  800447:	53                   	push   %ebx
  800448:	83 ec 20             	sub    $0x20,%esp
  80044b:	8b 75 08             	mov    0x8(%ebp),%esi
  80044e:	8a 45 0c             	mov    0xc(%ebp),%al
  800451:	88 45 e7             	mov    %al,-0x19(%ebp)
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800454:	56                   	push   %esi
  800455:	e8 92 fe ff ff       	call   8002ec <fd2num>
  80045a:	8d 55 f4             	lea    -0xc(%ebp),%edx
  80045d:	89 14 24             	mov    %edx,(%esp)
  800460:	50                   	push   %eax
  800461:	e8 21 ff ff ff       	call   800387 <fd_lookup>
  800466:	89 c3                	mov    %eax,%ebx
  800468:	83 c4 08             	add    $0x8,%esp
  80046b:	85 c0                	test   %eax,%eax
  80046d:	78 05                	js     800474 <fd_close+0x31>
	    || fd != fd2)
  80046f:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  800472:	74 0d                	je     800481 <fd_close+0x3e>
		return (must_exist ? r : 0);
  800474:	80 7d e7 00          	cmpb   $0x0,-0x19(%ebp)
  800478:	75 48                	jne    8004c2 <fd_close+0x7f>
  80047a:	bb 00 00 00 00       	mov    $0x0,%ebx
  80047f:	eb 41                	jmp    8004c2 <fd_close+0x7f>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800481:	83 ec 08             	sub    $0x8,%esp
  800484:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800487:	50                   	push   %eax
  800488:	ff 36                	pushl  (%esi)
  80048a:	e8 4e ff ff ff       	call   8003dd <dev_lookup>
  80048f:	89 c3                	mov    %eax,%ebx
  800491:	83 c4 10             	add    $0x10,%esp
  800494:	85 c0                	test   %eax,%eax
  800496:	78 1c                	js     8004b4 <fd_close+0x71>
		if (dev->dev_close)
  800498:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80049b:	8b 40 10             	mov    0x10(%eax),%eax
  80049e:	85 c0                	test   %eax,%eax
  8004a0:	74 0d                	je     8004af <fd_close+0x6c>
			r = (*dev->dev_close)(fd);
  8004a2:	83 ec 0c             	sub    $0xc,%esp
  8004a5:	56                   	push   %esi
  8004a6:	ff d0                	call   *%eax
  8004a8:	89 c3                	mov    %eax,%ebx
  8004aa:	83 c4 10             	add    $0x10,%esp
  8004ad:	eb 05                	jmp    8004b4 <fd_close+0x71>
		else
			r = 0;
  8004af:	bb 00 00 00 00       	mov    $0x0,%ebx
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8004b4:	83 ec 08             	sub    $0x8,%esp
  8004b7:	56                   	push   %esi
  8004b8:	6a 00                	push   $0x0
  8004ba:	e8 37 fd ff ff       	call   8001f6 <sys_page_unmap>
	return r;
  8004bf:	83 c4 10             	add    $0x10,%esp
}
  8004c2:	89 d8                	mov    %ebx,%eax
  8004c4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8004c7:	5b                   	pop    %ebx
  8004c8:	5e                   	pop    %esi
  8004c9:	c9                   	leave  
  8004ca:	c3                   	ret    

008004cb <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8004cb:	55                   	push   %ebp
  8004cc:	89 e5                	mov    %esp,%ebp
  8004ce:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8004d1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8004d4:	50                   	push   %eax
  8004d5:	ff 75 08             	pushl  0x8(%ebp)
  8004d8:	e8 aa fe ff ff       	call   800387 <fd_lookup>
  8004dd:	83 c4 08             	add    $0x8,%esp
  8004e0:	85 c0                	test   %eax,%eax
  8004e2:	78 10                	js     8004f4 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  8004e4:	83 ec 08             	sub    $0x8,%esp
  8004e7:	6a 01                	push   $0x1
  8004e9:	ff 75 f4             	pushl  -0xc(%ebp)
  8004ec:	e8 52 ff ff ff       	call   800443 <fd_close>
  8004f1:	83 c4 10             	add    $0x10,%esp
}
  8004f4:	c9                   	leave  
  8004f5:	c3                   	ret    

008004f6 <close_all>:

void
close_all(void)
{
  8004f6:	55                   	push   %ebp
  8004f7:	89 e5                	mov    %esp,%ebp
  8004f9:	53                   	push   %ebx
  8004fa:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8004fd:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  800502:	83 ec 0c             	sub    $0xc,%esp
  800505:	53                   	push   %ebx
  800506:	e8 c0 ff ff ff       	call   8004cb <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  80050b:	43                   	inc    %ebx
  80050c:	83 c4 10             	add    $0x10,%esp
  80050f:	83 fb 20             	cmp    $0x20,%ebx
  800512:	75 ee                	jne    800502 <close_all+0xc>
		close(i);
}
  800514:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800517:	c9                   	leave  
  800518:	c3                   	ret    

00800519 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800519:	55                   	push   %ebp
  80051a:	89 e5                	mov    %esp,%ebp
  80051c:	57                   	push   %edi
  80051d:	56                   	push   %esi
  80051e:	53                   	push   %ebx
  80051f:	83 ec 2c             	sub    $0x2c,%esp
  800522:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  800525:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800528:	50                   	push   %eax
  800529:	ff 75 08             	pushl  0x8(%ebp)
  80052c:	e8 56 fe ff ff       	call   800387 <fd_lookup>
  800531:	89 c3                	mov    %eax,%ebx
  800533:	83 c4 08             	add    $0x8,%esp
  800536:	85 c0                	test   %eax,%eax
  800538:	0f 88 c0 00 00 00    	js     8005fe <dup+0xe5>
		return r;
	close(newfdnum);
  80053e:	83 ec 0c             	sub    $0xc,%esp
  800541:	57                   	push   %edi
  800542:	e8 84 ff ff ff       	call   8004cb <close>

	newfd = INDEX2FD(newfdnum);
  800547:	8d b7 00 00 0d 00    	lea    0xd0000(%edi),%esi
  80054d:	c1 e6 0c             	shl    $0xc,%esi
	ova = fd2data(oldfd);
  800550:	83 c4 04             	add    $0x4,%esp
  800553:	ff 75 e4             	pushl  -0x1c(%ebp)
  800556:	e8 a1 fd ff ff       	call   8002fc <fd2data>
  80055b:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  80055d:	89 34 24             	mov    %esi,(%esp)
  800560:	e8 97 fd ff ff       	call   8002fc <fd2data>
  800565:	83 c4 10             	add    $0x10,%esp
  800568:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80056b:	89 d8                	mov    %ebx,%eax
  80056d:	c1 e8 16             	shr    $0x16,%eax
  800570:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800577:	a8 01                	test   $0x1,%al
  800579:	74 37                	je     8005b2 <dup+0x99>
  80057b:	89 d8                	mov    %ebx,%eax
  80057d:	c1 e8 0c             	shr    $0xc,%eax
  800580:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800587:	f6 c2 01             	test   $0x1,%dl
  80058a:	74 26                	je     8005b2 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  80058c:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800593:	83 ec 0c             	sub    $0xc,%esp
  800596:	25 07 0e 00 00       	and    $0xe07,%eax
  80059b:	50                   	push   %eax
  80059c:	ff 75 d4             	pushl  -0x2c(%ebp)
  80059f:	6a 00                	push   $0x0
  8005a1:	53                   	push   %ebx
  8005a2:	6a 00                	push   $0x0
  8005a4:	e8 27 fc ff ff       	call   8001d0 <sys_page_map>
  8005a9:	89 c3                	mov    %eax,%ebx
  8005ab:	83 c4 20             	add    $0x20,%esp
  8005ae:	85 c0                	test   %eax,%eax
  8005b0:	78 2d                	js     8005df <dup+0xc6>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8005b2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8005b5:	89 c2                	mov    %eax,%edx
  8005b7:	c1 ea 0c             	shr    $0xc,%edx
  8005ba:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8005c1:	83 ec 0c             	sub    $0xc,%esp
  8005c4:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  8005ca:	52                   	push   %edx
  8005cb:	56                   	push   %esi
  8005cc:	6a 00                	push   $0x0
  8005ce:	50                   	push   %eax
  8005cf:	6a 00                	push   $0x0
  8005d1:	e8 fa fb ff ff       	call   8001d0 <sys_page_map>
  8005d6:	89 c3                	mov    %eax,%ebx
  8005d8:	83 c4 20             	add    $0x20,%esp
  8005db:	85 c0                	test   %eax,%eax
  8005dd:	79 1d                	jns    8005fc <dup+0xe3>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8005df:	83 ec 08             	sub    $0x8,%esp
  8005e2:	56                   	push   %esi
  8005e3:	6a 00                	push   $0x0
  8005e5:	e8 0c fc ff ff       	call   8001f6 <sys_page_unmap>
	sys_page_unmap(0, nva);
  8005ea:	83 c4 08             	add    $0x8,%esp
  8005ed:	ff 75 d4             	pushl  -0x2c(%ebp)
  8005f0:	6a 00                	push   $0x0
  8005f2:	e8 ff fb ff ff       	call   8001f6 <sys_page_unmap>
	return r;
  8005f7:	83 c4 10             	add    $0x10,%esp
  8005fa:	eb 02                	jmp    8005fe <dup+0xe5>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
		goto err;

	return newfdnum;
  8005fc:	89 fb                	mov    %edi,%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  8005fe:	89 d8                	mov    %ebx,%eax
  800600:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800603:	5b                   	pop    %ebx
  800604:	5e                   	pop    %esi
  800605:	5f                   	pop    %edi
  800606:	c9                   	leave  
  800607:	c3                   	ret    

00800608 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  800608:	55                   	push   %ebp
  800609:	89 e5                	mov    %esp,%ebp
  80060b:	53                   	push   %ebx
  80060c:	83 ec 14             	sub    $0x14,%esp
  80060f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800612:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800615:	50                   	push   %eax
  800616:	53                   	push   %ebx
  800617:	e8 6b fd ff ff       	call   800387 <fd_lookup>
  80061c:	83 c4 08             	add    $0x8,%esp
  80061f:	85 c0                	test   %eax,%eax
  800621:	78 67                	js     80068a <read+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800623:	83 ec 08             	sub    $0x8,%esp
  800626:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800629:	50                   	push   %eax
  80062a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80062d:	ff 30                	pushl  (%eax)
  80062f:	e8 a9 fd ff ff       	call   8003dd <dev_lookup>
  800634:	83 c4 10             	add    $0x10,%esp
  800637:	85 c0                	test   %eax,%eax
  800639:	78 4f                	js     80068a <read+0x82>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80063b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80063e:	8b 50 08             	mov    0x8(%eax),%edx
  800641:	83 e2 03             	and    $0x3,%edx
  800644:	83 fa 01             	cmp    $0x1,%edx
  800647:	75 21                	jne    80066a <read+0x62>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  800649:	a1 04 40 80 00       	mov    0x804004,%eax
  80064e:	8b 40 48             	mov    0x48(%eax),%eax
  800651:	83 ec 04             	sub    $0x4,%esp
  800654:	53                   	push   %ebx
  800655:	50                   	push   %eax
  800656:	68 d9 1d 80 00       	push   $0x801dd9
  80065b:	e8 18 0a 00 00       	call   801078 <cprintf>
		return -E_INVAL;
  800660:	83 c4 10             	add    $0x10,%esp
  800663:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800668:	eb 20                	jmp    80068a <read+0x82>
	}
	if (!dev->dev_read)
  80066a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80066d:	8b 52 08             	mov    0x8(%edx),%edx
  800670:	85 d2                	test   %edx,%edx
  800672:	74 11                	je     800685 <read+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  800674:	83 ec 04             	sub    $0x4,%esp
  800677:	ff 75 10             	pushl  0x10(%ebp)
  80067a:	ff 75 0c             	pushl  0xc(%ebp)
  80067d:	50                   	push   %eax
  80067e:	ff d2                	call   *%edx
  800680:	83 c4 10             	add    $0x10,%esp
  800683:	eb 05                	jmp    80068a <read+0x82>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  800685:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_read)(fd, buf, n);
}
  80068a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80068d:	c9                   	leave  
  80068e:	c3                   	ret    

0080068f <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  80068f:	55                   	push   %ebp
  800690:	89 e5                	mov    %esp,%ebp
  800692:	57                   	push   %edi
  800693:	56                   	push   %esi
  800694:	53                   	push   %ebx
  800695:	83 ec 0c             	sub    $0xc,%esp
  800698:	8b 7d 08             	mov    0x8(%ebp),%edi
  80069b:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80069e:	85 f6                	test   %esi,%esi
  8006a0:	74 31                	je     8006d3 <readn+0x44>
  8006a2:	b8 00 00 00 00       	mov    $0x0,%eax
  8006a7:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = read(fdnum, (char*)buf + tot, n - tot);
  8006ac:	83 ec 04             	sub    $0x4,%esp
  8006af:	89 f2                	mov    %esi,%edx
  8006b1:	29 c2                	sub    %eax,%edx
  8006b3:	52                   	push   %edx
  8006b4:	03 45 0c             	add    0xc(%ebp),%eax
  8006b7:	50                   	push   %eax
  8006b8:	57                   	push   %edi
  8006b9:	e8 4a ff ff ff       	call   800608 <read>
		if (m < 0)
  8006be:	83 c4 10             	add    $0x10,%esp
  8006c1:	85 c0                	test   %eax,%eax
  8006c3:	78 17                	js     8006dc <readn+0x4d>
			return m;
		if (m == 0)
  8006c5:	85 c0                	test   %eax,%eax
  8006c7:	74 11                	je     8006da <readn+0x4b>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8006c9:	01 c3                	add    %eax,%ebx
  8006cb:	89 d8                	mov    %ebx,%eax
  8006cd:	39 f3                	cmp    %esi,%ebx
  8006cf:	72 db                	jb     8006ac <readn+0x1d>
  8006d1:	eb 09                	jmp    8006dc <readn+0x4d>
  8006d3:	b8 00 00 00 00       	mov    $0x0,%eax
  8006d8:	eb 02                	jmp    8006dc <readn+0x4d>
		m = read(fdnum, (char*)buf + tot, n - tot);
		if (m < 0)
			return m;
		if (m == 0)
  8006da:	89 d8                	mov    %ebx,%eax
			break;
	}
	return tot;
}
  8006dc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8006df:	5b                   	pop    %ebx
  8006e0:	5e                   	pop    %esi
  8006e1:	5f                   	pop    %edi
  8006e2:	c9                   	leave  
  8006e3:	c3                   	ret    

008006e4 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8006e4:	55                   	push   %ebp
  8006e5:	89 e5                	mov    %esp,%ebp
  8006e7:	53                   	push   %ebx
  8006e8:	83 ec 14             	sub    $0x14,%esp
  8006eb:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8006ee:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8006f1:	50                   	push   %eax
  8006f2:	53                   	push   %ebx
  8006f3:	e8 8f fc ff ff       	call   800387 <fd_lookup>
  8006f8:	83 c4 08             	add    $0x8,%esp
  8006fb:	85 c0                	test   %eax,%eax
  8006fd:	78 62                	js     800761 <write+0x7d>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8006ff:	83 ec 08             	sub    $0x8,%esp
  800702:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800705:	50                   	push   %eax
  800706:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800709:	ff 30                	pushl  (%eax)
  80070b:	e8 cd fc ff ff       	call   8003dd <dev_lookup>
  800710:	83 c4 10             	add    $0x10,%esp
  800713:	85 c0                	test   %eax,%eax
  800715:	78 4a                	js     800761 <write+0x7d>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800717:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80071a:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80071e:	75 21                	jne    800741 <write+0x5d>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  800720:	a1 04 40 80 00       	mov    0x804004,%eax
  800725:	8b 40 48             	mov    0x48(%eax),%eax
  800728:	83 ec 04             	sub    $0x4,%esp
  80072b:	53                   	push   %ebx
  80072c:	50                   	push   %eax
  80072d:	68 f5 1d 80 00       	push   $0x801df5
  800732:	e8 41 09 00 00       	call   801078 <cprintf>
		return -E_INVAL;
  800737:	83 c4 10             	add    $0x10,%esp
  80073a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80073f:	eb 20                	jmp    800761 <write+0x7d>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  800741:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800744:	8b 52 0c             	mov    0xc(%edx),%edx
  800747:	85 d2                	test   %edx,%edx
  800749:	74 11                	je     80075c <write+0x78>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80074b:	83 ec 04             	sub    $0x4,%esp
  80074e:	ff 75 10             	pushl  0x10(%ebp)
  800751:	ff 75 0c             	pushl  0xc(%ebp)
  800754:	50                   	push   %eax
  800755:	ff d2                	call   *%edx
  800757:	83 c4 10             	add    $0x10,%esp
  80075a:	eb 05                	jmp    800761 <write+0x7d>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  80075c:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  800761:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800764:	c9                   	leave  
  800765:	c3                   	ret    

00800766 <seek>:

int
seek(int fdnum, off_t offset)
{
  800766:	55                   	push   %ebp
  800767:	89 e5                	mov    %esp,%ebp
  800769:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80076c:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80076f:	50                   	push   %eax
  800770:	ff 75 08             	pushl  0x8(%ebp)
  800773:	e8 0f fc ff ff       	call   800387 <fd_lookup>
  800778:	83 c4 08             	add    $0x8,%esp
  80077b:	85 c0                	test   %eax,%eax
  80077d:	78 0e                	js     80078d <seek+0x27>
		return r;
	fd->fd_offset = offset;
  80077f:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800782:	8b 55 0c             	mov    0xc(%ebp),%edx
  800785:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  800788:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80078d:	c9                   	leave  
  80078e:	c3                   	ret    

0080078f <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  80078f:	55                   	push   %ebp
  800790:	89 e5                	mov    %esp,%ebp
  800792:	53                   	push   %ebx
  800793:	83 ec 14             	sub    $0x14,%esp
  800796:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  800799:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80079c:	50                   	push   %eax
  80079d:	53                   	push   %ebx
  80079e:	e8 e4 fb ff ff       	call   800387 <fd_lookup>
  8007a3:	83 c4 08             	add    $0x8,%esp
  8007a6:	85 c0                	test   %eax,%eax
  8007a8:	78 5f                	js     800809 <ftruncate+0x7a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8007aa:	83 ec 08             	sub    $0x8,%esp
  8007ad:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8007b0:	50                   	push   %eax
  8007b1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8007b4:	ff 30                	pushl  (%eax)
  8007b6:	e8 22 fc ff ff       	call   8003dd <dev_lookup>
  8007bb:	83 c4 10             	add    $0x10,%esp
  8007be:	85 c0                	test   %eax,%eax
  8007c0:	78 47                	js     800809 <ftruncate+0x7a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8007c2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8007c5:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8007c9:	75 21                	jne    8007ec <ftruncate+0x5d>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8007cb:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8007d0:	8b 40 48             	mov    0x48(%eax),%eax
  8007d3:	83 ec 04             	sub    $0x4,%esp
  8007d6:	53                   	push   %ebx
  8007d7:	50                   	push   %eax
  8007d8:	68 b8 1d 80 00       	push   $0x801db8
  8007dd:	e8 96 08 00 00       	call   801078 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8007e2:	83 c4 10             	add    $0x10,%esp
  8007e5:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8007ea:	eb 1d                	jmp    800809 <ftruncate+0x7a>
	}
	if (!dev->dev_trunc)
  8007ec:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8007ef:	8b 52 18             	mov    0x18(%edx),%edx
  8007f2:	85 d2                	test   %edx,%edx
  8007f4:	74 0e                	je     800804 <ftruncate+0x75>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8007f6:	83 ec 08             	sub    $0x8,%esp
  8007f9:	ff 75 0c             	pushl  0xc(%ebp)
  8007fc:	50                   	push   %eax
  8007fd:	ff d2                	call   *%edx
  8007ff:	83 c4 10             	add    $0x10,%esp
  800802:	eb 05                	jmp    800809 <ftruncate+0x7a>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  800804:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  800809:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80080c:	c9                   	leave  
  80080d:	c3                   	ret    

0080080e <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  80080e:	55                   	push   %ebp
  80080f:	89 e5                	mov    %esp,%ebp
  800811:	53                   	push   %ebx
  800812:	83 ec 14             	sub    $0x14,%esp
  800815:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800818:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80081b:	50                   	push   %eax
  80081c:	ff 75 08             	pushl  0x8(%ebp)
  80081f:	e8 63 fb ff ff       	call   800387 <fd_lookup>
  800824:	83 c4 08             	add    $0x8,%esp
  800827:	85 c0                	test   %eax,%eax
  800829:	78 52                	js     80087d <fstat+0x6f>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80082b:	83 ec 08             	sub    $0x8,%esp
  80082e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800831:	50                   	push   %eax
  800832:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800835:	ff 30                	pushl  (%eax)
  800837:	e8 a1 fb ff ff       	call   8003dd <dev_lookup>
  80083c:	83 c4 10             	add    $0x10,%esp
  80083f:	85 c0                	test   %eax,%eax
  800841:	78 3a                	js     80087d <fstat+0x6f>
		return r;
	if (!dev->dev_stat)
  800843:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800846:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  80084a:	74 2c                	je     800878 <fstat+0x6a>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  80084c:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  80084f:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  800856:	00 00 00 
	stat->st_isdir = 0;
  800859:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  800860:	00 00 00 
	stat->st_dev = dev;
  800863:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  800869:	83 ec 08             	sub    $0x8,%esp
  80086c:	53                   	push   %ebx
  80086d:	ff 75 f0             	pushl  -0x10(%ebp)
  800870:	ff 50 14             	call   *0x14(%eax)
  800873:	83 c4 10             	add    $0x10,%esp
  800876:	eb 05                	jmp    80087d <fstat+0x6f>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  800878:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  80087d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800880:	c9                   	leave  
  800881:	c3                   	ret    

00800882 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  800882:	55                   	push   %ebp
  800883:	89 e5                	mov    %esp,%ebp
  800885:	56                   	push   %esi
  800886:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  800887:	83 ec 08             	sub    $0x8,%esp
  80088a:	6a 00                	push   $0x0
  80088c:	ff 75 08             	pushl  0x8(%ebp)
  80088f:	e8 78 01 00 00       	call   800a0c <open>
  800894:	89 c3                	mov    %eax,%ebx
  800896:	83 c4 10             	add    $0x10,%esp
  800899:	85 c0                	test   %eax,%eax
  80089b:	78 1b                	js     8008b8 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  80089d:	83 ec 08             	sub    $0x8,%esp
  8008a0:	ff 75 0c             	pushl  0xc(%ebp)
  8008a3:	50                   	push   %eax
  8008a4:	e8 65 ff ff ff       	call   80080e <fstat>
  8008a9:	89 c6                	mov    %eax,%esi
	close(fd);
  8008ab:	89 1c 24             	mov    %ebx,(%esp)
  8008ae:	e8 18 fc ff ff       	call   8004cb <close>
	return r;
  8008b3:	83 c4 10             	add    $0x10,%esp
  8008b6:	89 f3                	mov    %esi,%ebx
}
  8008b8:	89 d8                	mov    %ebx,%eax
  8008ba:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8008bd:	5b                   	pop    %ebx
  8008be:	5e                   	pop    %esi
  8008bf:	c9                   	leave  
  8008c0:	c3                   	ret    
  8008c1:	00 00                	add    %al,(%eax)
	...

008008c4 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8008c4:	55                   	push   %ebp
  8008c5:	89 e5                	mov    %esp,%ebp
  8008c7:	56                   	push   %esi
  8008c8:	53                   	push   %ebx
  8008c9:	89 c3                	mov    %eax,%ebx
  8008cb:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  8008cd:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8008d4:	75 12                	jne    8008e8 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8008d6:	83 ec 0c             	sub    $0xc,%esp
  8008d9:	6a 01                	push   $0x1
  8008db:	e8 96 11 00 00       	call   801a76 <ipc_find_env>
  8008e0:	a3 00 40 80 00       	mov    %eax,0x804000
  8008e5:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8008e8:	6a 07                	push   $0x7
  8008ea:	68 00 50 80 00       	push   $0x805000
  8008ef:	53                   	push   %ebx
  8008f0:	ff 35 00 40 80 00    	pushl  0x804000
  8008f6:	e8 26 11 00 00       	call   801a21 <ipc_send>
	
	return ipc_recv(NULL, dstva, NULL);
  8008fb:	83 c4 0c             	add    $0xc,%esp
  8008fe:	6a 00                	push   $0x0
  800900:	56                   	push   %esi
  800901:	6a 00                	push   $0x0
  800903:	e8 a4 10 00 00       	call   8019ac <ipc_recv>
}
  800908:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80090b:	5b                   	pop    %ebx
  80090c:	5e                   	pop    %esi
  80090d:	c9                   	leave  
  80090e:	c3                   	ret    

0080090f <devfile_stat>:
}


static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  80090f:	55                   	push   %ebp
  800910:	89 e5                	mov    %esp,%ebp
  800912:	53                   	push   %ebx
  800913:	83 ec 04             	sub    $0x4,%esp
  800916:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  800919:	8b 45 08             	mov    0x8(%ebp),%eax
  80091c:	8b 40 0c             	mov    0xc(%eax),%eax
  80091f:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0) {
  800924:	ba 00 00 00 00       	mov    $0x0,%edx
  800929:	b8 05 00 00 00       	mov    $0x5,%eax
  80092e:	e8 91 ff ff ff       	call   8008c4 <fsipc>
  800933:	85 c0                	test   %eax,%eax
  800935:	78 2c                	js     800963 <devfile_stat+0x54>
		return r;
	}
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  800937:	83 ec 08             	sub    $0x8,%esp
  80093a:	68 00 50 80 00       	push   $0x805000
  80093f:	53                   	push   %ebx
  800940:	e8 e9 0c 00 00       	call   80162e <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  800945:	a1 80 50 80 00       	mov    0x805080,%eax
  80094a:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  800950:	a1 84 50 80 00       	mov    0x805084,%eax
  800955:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  80095b:	83 c4 10             	add    $0x10,%esp
  80095e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800963:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800966:	c9                   	leave  
  800967:	c3                   	ret    

00800968 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  800968:	55                   	push   %ebp
  800969:	89 e5                	mov    %esp,%ebp
  80096b:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  80096e:	8b 45 08             	mov    0x8(%ebp),%eax
  800971:	8b 40 0c             	mov    0xc(%eax),%eax
  800974:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  800979:	ba 00 00 00 00       	mov    $0x0,%edx
  80097e:	b8 06 00 00 00       	mov    $0x6,%eax
  800983:	e8 3c ff ff ff       	call   8008c4 <fsipc>
}
  800988:	c9                   	leave  
  800989:	c3                   	ret    

0080098a <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  80098a:	55                   	push   %ebp
  80098b:	89 e5                	mov    %esp,%ebp
  80098d:	56                   	push   %esi
  80098e:	53                   	push   %ebx
  80098f:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  800992:	8b 45 08             	mov    0x8(%ebp),%eax
  800995:	8b 40 0c             	mov    0xc(%eax),%eax
  800998:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  80099d:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8009a3:	ba 00 00 00 00       	mov    $0x0,%edx
  8009a8:	b8 03 00 00 00       	mov    $0x3,%eax
  8009ad:	e8 12 ff ff ff       	call   8008c4 <fsipc>
  8009b2:	89 c3                	mov    %eax,%ebx
  8009b4:	85 c0                	test   %eax,%eax
  8009b6:	78 4b                	js     800a03 <devfile_read+0x79>
		return r;
	assert(r <= n);
  8009b8:	39 c6                	cmp    %eax,%esi
  8009ba:	73 16                	jae    8009d2 <devfile_read+0x48>
  8009bc:	68 24 1e 80 00       	push   $0x801e24
  8009c1:	68 2b 1e 80 00       	push   $0x801e2b
  8009c6:	6a 7d                	push   $0x7d
  8009c8:	68 40 1e 80 00       	push   $0x801e40
  8009cd:	e8 ce 05 00 00       	call   800fa0 <_panic>
	assert(r <= PGSIZE);
  8009d2:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8009d7:	7e 16                	jle    8009ef <devfile_read+0x65>
  8009d9:	68 4b 1e 80 00       	push   $0x801e4b
  8009de:	68 2b 1e 80 00       	push   $0x801e2b
  8009e3:	6a 7e                	push   $0x7e
  8009e5:	68 40 1e 80 00       	push   $0x801e40
  8009ea:	e8 b1 05 00 00       	call   800fa0 <_panic>
	memmove(buf, &fsipcbuf, r);
  8009ef:	83 ec 04             	sub    $0x4,%esp
  8009f2:	50                   	push   %eax
  8009f3:	68 00 50 80 00       	push   $0x805000
  8009f8:	ff 75 0c             	pushl  0xc(%ebp)
  8009fb:	e8 ef 0d 00 00       	call   8017ef <memmove>
	return r;
  800a00:	83 c4 10             	add    $0x10,%esp
}
  800a03:	89 d8                	mov    %ebx,%eax
  800a05:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800a08:	5b                   	pop    %ebx
  800a09:	5e                   	pop    %esi
  800a0a:	c9                   	leave  
  800a0b:	c3                   	ret    

00800a0c <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  800a0c:	55                   	push   %ebp
  800a0d:	89 e5                	mov    %esp,%ebp
  800a0f:	56                   	push   %esi
  800a10:	53                   	push   %ebx
  800a11:	83 ec 1c             	sub    $0x1c,%esp
  800a14:	8b 75 08             	mov    0x8(%ebp),%esi
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  800a17:	56                   	push   %esi
  800a18:	e8 bf 0b 00 00       	call   8015dc <strlen>
  800a1d:	83 c4 10             	add    $0x10,%esp
  800a20:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  800a25:	7f 65                	jg     800a8c <open+0x80>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800a27:	83 ec 0c             	sub    $0xc,%esp
  800a2a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800a2d:	50                   	push   %eax
  800a2e:	e8 e1 f8 ff ff       	call   800314 <fd_alloc>
  800a33:	89 c3                	mov    %eax,%ebx
  800a35:	83 c4 10             	add    $0x10,%esp
  800a38:	85 c0                	test   %eax,%eax
  800a3a:	78 55                	js     800a91 <open+0x85>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  800a3c:	83 ec 08             	sub    $0x8,%esp
  800a3f:	56                   	push   %esi
  800a40:	68 00 50 80 00       	push   $0x805000
  800a45:	e8 e4 0b 00 00       	call   80162e <strcpy>
	fsipcbuf.open.req_omode = mode;
  800a4a:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a4d:	a3 00 54 80 00       	mov    %eax,0x805400



	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  800a52:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800a55:	b8 01 00 00 00       	mov    $0x1,%eax
  800a5a:	e8 65 fe ff ff       	call   8008c4 <fsipc>
  800a5f:	89 c3                	mov    %eax,%ebx
  800a61:	83 c4 10             	add    $0x10,%esp
  800a64:	85 c0                	test   %eax,%eax
  800a66:	79 12                	jns    800a7a <open+0x6e>
		fd_close(fd, 0);
  800a68:	83 ec 08             	sub    $0x8,%esp
  800a6b:	6a 00                	push   $0x0
  800a6d:	ff 75 f4             	pushl  -0xc(%ebp)
  800a70:	e8 ce f9 ff ff       	call   800443 <fd_close>
		return r;
  800a75:	83 c4 10             	add    $0x10,%esp
  800a78:	eb 17                	jmp    800a91 <open+0x85>
	}

	return fd2num(fd);
  800a7a:	83 ec 0c             	sub    $0xc,%esp
  800a7d:	ff 75 f4             	pushl  -0xc(%ebp)
  800a80:	e8 67 f8 ff ff       	call   8002ec <fd2num>
  800a85:	89 c3                	mov    %eax,%ebx
  800a87:	83 c4 10             	add    $0x10,%esp
  800a8a:	eb 05                	jmp    800a91 <open+0x85>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  800a8c:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  800a91:	89 d8                	mov    %ebx,%eax
  800a93:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800a96:	5b                   	pop    %ebx
  800a97:	5e                   	pop    %esi
  800a98:	c9                   	leave  
  800a99:	c3                   	ret    
	...

00800a9c <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  800a9c:	55                   	push   %ebp
  800a9d:	89 e5                	mov    %esp,%ebp
  800a9f:	56                   	push   %esi
  800aa0:	53                   	push   %ebx
  800aa1:	8b 75 0c             	mov    0xc(%ebp),%esi
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  800aa4:	83 ec 0c             	sub    $0xc,%esp
  800aa7:	ff 75 08             	pushl  0x8(%ebp)
  800aaa:	e8 4d f8 ff ff       	call   8002fc <fd2data>
  800aaf:	89 c3                	mov    %eax,%ebx
	strcpy(stat->st_name, "<pipe>");
  800ab1:	83 c4 08             	add    $0x8,%esp
  800ab4:	68 57 1e 80 00       	push   $0x801e57
  800ab9:	56                   	push   %esi
  800aba:	e8 6f 0b 00 00       	call   80162e <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  800abf:	8b 43 04             	mov    0x4(%ebx),%eax
  800ac2:	2b 03                	sub    (%ebx),%eax
  800ac4:	89 86 80 00 00 00    	mov    %eax,0x80(%esi)
	stat->st_isdir = 0;
  800aca:	c7 86 84 00 00 00 00 	movl   $0x0,0x84(%esi)
  800ad1:	00 00 00 
	stat->st_dev = &devpipe;
  800ad4:	c7 86 88 00 00 00 20 	movl   $0x803020,0x88(%esi)
  800adb:	30 80 00 
	return 0;
}
  800ade:	b8 00 00 00 00       	mov    $0x0,%eax
  800ae3:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800ae6:	5b                   	pop    %ebx
  800ae7:	5e                   	pop    %esi
  800ae8:	c9                   	leave  
  800ae9:	c3                   	ret    

00800aea <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  800aea:	55                   	push   %ebp
  800aeb:	89 e5                	mov    %esp,%ebp
  800aed:	53                   	push   %ebx
  800aee:	83 ec 0c             	sub    $0xc,%esp
  800af1:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  800af4:	53                   	push   %ebx
  800af5:	6a 00                	push   $0x0
  800af7:	e8 fa f6 ff ff       	call   8001f6 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  800afc:	89 1c 24             	mov    %ebx,(%esp)
  800aff:	e8 f8 f7 ff ff       	call   8002fc <fd2data>
  800b04:	83 c4 08             	add    $0x8,%esp
  800b07:	50                   	push   %eax
  800b08:	6a 00                	push   $0x0
  800b0a:	e8 e7 f6 ff ff       	call   8001f6 <sys_page_unmap>
}
  800b0f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800b12:	c9                   	leave  
  800b13:	c3                   	ret    

00800b14 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  800b14:	55                   	push   %ebp
  800b15:	89 e5                	mov    %esp,%ebp
  800b17:	57                   	push   %edi
  800b18:	56                   	push   %esi
  800b19:	53                   	push   %ebx
  800b1a:	83 ec 1c             	sub    $0x1c,%esp
  800b1d:	89 c7                	mov    %eax,%edi
  800b1f:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  800b22:	a1 04 40 80 00       	mov    0x804004,%eax
  800b27:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  800b2a:	83 ec 0c             	sub    $0xc,%esp
  800b2d:	57                   	push   %edi
  800b2e:	e8 a1 0f 00 00       	call   801ad4 <pageref>
  800b33:	89 c6                	mov    %eax,%esi
  800b35:	83 c4 04             	add    $0x4,%esp
  800b38:	ff 75 e4             	pushl  -0x1c(%ebp)
  800b3b:	e8 94 0f 00 00       	call   801ad4 <pageref>
  800b40:	83 c4 10             	add    $0x10,%esp
  800b43:	39 c6                	cmp    %eax,%esi
  800b45:	0f 94 c0             	sete   %al
  800b48:	0f b6 c0             	movzbl %al,%eax
		nn = thisenv->env_runs;
  800b4b:	8b 15 04 40 80 00    	mov    0x804004,%edx
  800b51:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  800b54:	39 cb                	cmp    %ecx,%ebx
  800b56:	75 08                	jne    800b60 <_pipeisclosed+0x4c>
			return ret;
		if (n != nn && ret == 1)
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
	}
}
  800b58:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b5b:	5b                   	pop    %ebx
  800b5c:	5e                   	pop    %esi
  800b5d:	5f                   	pop    %edi
  800b5e:	c9                   	leave  
  800b5f:	c3                   	ret    
		n = thisenv->env_runs;
		ret = pageref(fd) == pageref(p);
		nn = thisenv->env_runs;
		if (n == nn)
			return ret;
		if (n != nn && ret == 1)
  800b60:	83 f8 01             	cmp    $0x1,%eax
  800b63:	75 bd                	jne    800b22 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  800b65:	8b 42 58             	mov    0x58(%edx),%eax
  800b68:	6a 01                	push   $0x1
  800b6a:	50                   	push   %eax
  800b6b:	53                   	push   %ebx
  800b6c:	68 5e 1e 80 00       	push   $0x801e5e
  800b71:	e8 02 05 00 00       	call   801078 <cprintf>
  800b76:	83 c4 10             	add    $0x10,%esp
  800b79:	eb a7                	jmp    800b22 <_pipeisclosed+0xe>

00800b7b <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  800b7b:	55                   	push   %ebp
  800b7c:	89 e5                	mov    %esp,%ebp
  800b7e:	57                   	push   %edi
  800b7f:	56                   	push   %esi
  800b80:	53                   	push   %ebx
  800b81:	83 ec 28             	sub    $0x28,%esp
  800b84:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  800b87:	56                   	push   %esi
  800b88:	e8 6f f7 ff ff       	call   8002fc <fd2data>
  800b8d:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800b8f:	83 c4 10             	add    $0x10,%esp
  800b92:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800b96:	75 4a                	jne    800be2 <devpipe_write+0x67>
  800b98:	bf 00 00 00 00       	mov    $0x0,%edi
  800b9d:	eb 56                	jmp    800bf5 <devpipe_write+0x7a>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  800b9f:	89 da                	mov    %ebx,%edx
  800ba1:	89 f0                	mov    %esi,%eax
  800ba3:	e8 6c ff ff ff       	call   800b14 <_pipeisclosed>
  800ba8:	85 c0                	test   %eax,%eax
  800baa:	75 4d                	jne    800bf9 <devpipe_write+0x7e>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  800bac:	e8 d4 f5 ff ff       	call   800185 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  800bb1:	8b 43 04             	mov    0x4(%ebx),%eax
  800bb4:	8b 13                	mov    (%ebx),%edx
  800bb6:	83 c2 20             	add    $0x20,%edx
  800bb9:	39 d0                	cmp    %edx,%eax
  800bbb:	73 e2                	jae    800b9f <devpipe_write+0x24>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  800bbd:	89 c2                	mov    %eax,%edx
  800bbf:	81 e2 1f 00 00 80    	and    $0x8000001f,%edx
  800bc5:	79 05                	jns    800bcc <devpipe_write+0x51>
  800bc7:	4a                   	dec    %edx
  800bc8:	83 ca e0             	or     $0xffffffe0,%edx
  800bcb:	42                   	inc    %edx
  800bcc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bcf:	8a 0c 39             	mov    (%ecx,%edi,1),%cl
  800bd2:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  800bd6:	40                   	inc    %eax
  800bd7:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800bda:	47                   	inc    %edi
  800bdb:	39 7d 10             	cmp    %edi,0x10(%ebp)
  800bde:	77 07                	ja     800be7 <devpipe_write+0x6c>
  800be0:	eb 13                	jmp    800bf5 <devpipe_write+0x7a>
  800be2:	bf 00 00 00 00       	mov    $0x0,%edi
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  800be7:	8b 43 04             	mov    0x4(%ebx),%eax
  800bea:	8b 13                	mov    (%ebx),%edx
  800bec:	83 c2 20             	add    $0x20,%edx
  800bef:	39 d0                	cmp    %edx,%eax
  800bf1:	73 ac                	jae    800b9f <devpipe_write+0x24>
  800bf3:	eb c8                	jmp    800bbd <devpipe_write+0x42>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  800bf5:	89 f8                	mov    %edi,%eax
  800bf7:	eb 05                	jmp    800bfe <devpipe_write+0x83>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  800bf9:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  800bfe:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c01:	5b                   	pop    %ebx
  800c02:	5e                   	pop    %esi
  800c03:	5f                   	pop    %edi
  800c04:	c9                   	leave  
  800c05:	c3                   	ret    

00800c06 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  800c06:	55                   	push   %ebp
  800c07:	89 e5                	mov    %esp,%ebp
  800c09:	57                   	push   %edi
  800c0a:	56                   	push   %esi
  800c0b:	53                   	push   %ebx
  800c0c:	83 ec 18             	sub    $0x18,%esp
  800c0f:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  800c12:	57                   	push   %edi
  800c13:	e8 e4 f6 ff ff       	call   8002fc <fd2data>
  800c18:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800c1a:	83 c4 10             	add    $0x10,%esp
  800c1d:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800c21:	75 44                	jne    800c67 <devpipe_read+0x61>
  800c23:	be 00 00 00 00       	mov    $0x0,%esi
  800c28:	eb 4f                	jmp    800c79 <devpipe_read+0x73>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
				return i;
  800c2a:	89 f0                	mov    %esi,%eax
  800c2c:	eb 54                	jmp    800c82 <devpipe_read+0x7c>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  800c2e:	89 da                	mov    %ebx,%edx
  800c30:	89 f8                	mov    %edi,%eax
  800c32:	e8 dd fe ff ff       	call   800b14 <_pipeisclosed>
  800c37:	85 c0                	test   %eax,%eax
  800c39:	75 42                	jne    800c7d <devpipe_read+0x77>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  800c3b:	e8 45 f5 ff ff       	call   800185 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  800c40:	8b 03                	mov    (%ebx),%eax
  800c42:	3b 43 04             	cmp    0x4(%ebx),%eax
  800c45:	74 e7                	je     800c2e <devpipe_read+0x28>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  800c47:	25 1f 00 00 80       	and    $0x8000001f,%eax
  800c4c:	79 05                	jns    800c53 <devpipe_read+0x4d>
  800c4e:	48                   	dec    %eax
  800c4f:	83 c8 e0             	or     $0xffffffe0,%eax
  800c52:	40                   	inc    %eax
  800c53:	8a 44 03 08          	mov    0x8(%ebx,%eax,1),%al
  800c57:	8b 55 0c             	mov    0xc(%ebp),%edx
  800c5a:	88 04 32             	mov    %al,(%edx,%esi,1)
		p->p_rpos++;
  800c5d:	ff 03                	incl   (%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800c5f:	46                   	inc    %esi
  800c60:	39 75 10             	cmp    %esi,0x10(%ebp)
  800c63:	77 07                	ja     800c6c <devpipe_read+0x66>
  800c65:	eb 12                	jmp    800c79 <devpipe_read+0x73>
  800c67:	be 00 00 00 00       	mov    $0x0,%esi
		while (p->p_rpos == p->p_wpos) {
  800c6c:	8b 03                	mov    (%ebx),%eax
  800c6e:	3b 43 04             	cmp    0x4(%ebx),%eax
  800c71:	75 d4                	jne    800c47 <devpipe_read+0x41>
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  800c73:	85 f6                	test   %esi,%esi
  800c75:	75 b3                	jne    800c2a <devpipe_read+0x24>
  800c77:	eb b5                	jmp    800c2e <devpipe_read+0x28>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  800c79:	89 f0                	mov    %esi,%eax
  800c7b:	eb 05                	jmp    800c82 <devpipe_read+0x7c>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  800c7d:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  800c82:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c85:	5b                   	pop    %ebx
  800c86:	5e                   	pop    %esi
  800c87:	5f                   	pop    %edi
  800c88:	c9                   	leave  
  800c89:	c3                   	ret    

00800c8a <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  800c8a:	55                   	push   %ebp
  800c8b:	89 e5                	mov    %esp,%ebp
  800c8d:	57                   	push   %edi
  800c8e:	56                   	push   %esi
  800c8f:	53                   	push   %ebx
  800c90:	83 ec 28             	sub    $0x28,%esp
  800c93:	8b 7d 08             	mov    0x8(%ebp),%edi
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  800c96:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800c99:	50                   	push   %eax
  800c9a:	e8 75 f6 ff ff       	call   800314 <fd_alloc>
  800c9f:	89 c3                	mov    %eax,%ebx
  800ca1:	83 c4 10             	add    $0x10,%esp
  800ca4:	85 c0                	test   %eax,%eax
  800ca6:	0f 88 24 01 00 00    	js     800dd0 <pipe+0x146>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800cac:	83 ec 04             	sub    $0x4,%esp
  800caf:	68 07 04 00 00       	push   $0x407
  800cb4:	ff 75 e4             	pushl  -0x1c(%ebp)
  800cb7:	6a 00                	push   $0x0
  800cb9:	e8 ee f4 ff ff       	call   8001ac <sys_page_alloc>
  800cbe:	89 c3                	mov    %eax,%ebx
  800cc0:	83 c4 10             	add    $0x10,%esp
  800cc3:	85 c0                	test   %eax,%eax
  800cc5:	0f 88 05 01 00 00    	js     800dd0 <pipe+0x146>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  800ccb:	83 ec 0c             	sub    $0xc,%esp
  800cce:	8d 45 e0             	lea    -0x20(%ebp),%eax
  800cd1:	50                   	push   %eax
  800cd2:	e8 3d f6 ff ff       	call   800314 <fd_alloc>
  800cd7:	89 c3                	mov    %eax,%ebx
  800cd9:	83 c4 10             	add    $0x10,%esp
  800cdc:	85 c0                	test   %eax,%eax
  800cde:	0f 88 dc 00 00 00    	js     800dc0 <pipe+0x136>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800ce4:	83 ec 04             	sub    $0x4,%esp
  800ce7:	68 07 04 00 00       	push   $0x407
  800cec:	ff 75 e0             	pushl  -0x20(%ebp)
  800cef:	6a 00                	push   $0x0
  800cf1:	e8 b6 f4 ff ff       	call   8001ac <sys_page_alloc>
  800cf6:	89 c3                	mov    %eax,%ebx
  800cf8:	83 c4 10             	add    $0x10,%esp
  800cfb:	85 c0                	test   %eax,%eax
  800cfd:	0f 88 bd 00 00 00    	js     800dc0 <pipe+0x136>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  800d03:	83 ec 0c             	sub    $0xc,%esp
  800d06:	ff 75 e4             	pushl  -0x1c(%ebp)
  800d09:	e8 ee f5 ff ff       	call   8002fc <fd2data>
  800d0e:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800d10:	83 c4 0c             	add    $0xc,%esp
  800d13:	68 07 04 00 00       	push   $0x407
  800d18:	50                   	push   %eax
  800d19:	6a 00                	push   $0x0
  800d1b:	e8 8c f4 ff ff       	call   8001ac <sys_page_alloc>
  800d20:	89 c3                	mov    %eax,%ebx
  800d22:	83 c4 10             	add    $0x10,%esp
  800d25:	85 c0                	test   %eax,%eax
  800d27:	0f 88 83 00 00 00    	js     800db0 <pipe+0x126>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800d2d:	83 ec 0c             	sub    $0xc,%esp
  800d30:	ff 75 e0             	pushl  -0x20(%ebp)
  800d33:	e8 c4 f5 ff ff       	call   8002fc <fd2data>
  800d38:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  800d3f:	50                   	push   %eax
  800d40:	6a 00                	push   $0x0
  800d42:	56                   	push   %esi
  800d43:	6a 00                	push   $0x0
  800d45:	e8 86 f4 ff ff       	call   8001d0 <sys_page_map>
  800d4a:	89 c3                	mov    %eax,%ebx
  800d4c:	83 c4 20             	add    $0x20,%esp
  800d4f:	85 c0                	test   %eax,%eax
  800d51:	78 4f                	js     800da2 <pipe+0x118>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  800d53:	8b 15 20 30 80 00    	mov    0x803020,%edx
  800d59:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800d5c:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  800d5e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800d61:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  800d68:	8b 15 20 30 80 00    	mov    0x803020,%edx
  800d6e:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800d71:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  800d73:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800d76:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  800d7d:	83 ec 0c             	sub    $0xc,%esp
  800d80:	ff 75 e4             	pushl  -0x1c(%ebp)
  800d83:	e8 64 f5 ff ff       	call   8002ec <fd2num>
  800d88:	89 07                	mov    %eax,(%edi)
	pfd[1] = fd2num(fd1);
  800d8a:	83 c4 04             	add    $0x4,%esp
  800d8d:	ff 75 e0             	pushl  -0x20(%ebp)
  800d90:	e8 57 f5 ff ff       	call   8002ec <fd2num>
  800d95:	89 47 04             	mov    %eax,0x4(%edi)
	return 0;
  800d98:	83 c4 10             	add    $0x10,%esp
  800d9b:	bb 00 00 00 00       	mov    $0x0,%ebx
  800da0:	eb 2e                	jmp    800dd0 <pipe+0x146>

    err3:
	sys_page_unmap(0, va);
  800da2:	83 ec 08             	sub    $0x8,%esp
  800da5:	56                   	push   %esi
  800da6:	6a 00                	push   $0x0
  800da8:	e8 49 f4 ff ff       	call   8001f6 <sys_page_unmap>
  800dad:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  800db0:	83 ec 08             	sub    $0x8,%esp
  800db3:	ff 75 e0             	pushl  -0x20(%ebp)
  800db6:	6a 00                	push   $0x0
  800db8:	e8 39 f4 ff ff       	call   8001f6 <sys_page_unmap>
  800dbd:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  800dc0:	83 ec 08             	sub    $0x8,%esp
  800dc3:	ff 75 e4             	pushl  -0x1c(%ebp)
  800dc6:	6a 00                	push   $0x0
  800dc8:	e8 29 f4 ff ff       	call   8001f6 <sys_page_unmap>
  800dcd:	83 c4 10             	add    $0x10,%esp
    err:
	return r;
}
  800dd0:	89 d8                	mov    %ebx,%eax
  800dd2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800dd5:	5b                   	pop    %ebx
  800dd6:	5e                   	pop    %esi
  800dd7:	5f                   	pop    %edi
  800dd8:	c9                   	leave  
  800dd9:	c3                   	ret    

00800dda <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  800dda:	55                   	push   %ebp
  800ddb:	89 e5                	mov    %esp,%ebp
  800ddd:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800de0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800de3:	50                   	push   %eax
  800de4:	ff 75 08             	pushl  0x8(%ebp)
  800de7:	e8 9b f5 ff ff       	call   800387 <fd_lookup>
  800dec:	83 c4 10             	add    $0x10,%esp
  800def:	85 c0                	test   %eax,%eax
  800df1:	78 18                	js     800e0b <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  800df3:	83 ec 0c             	sub    $0xc,%esp
  800df6:	ff 75 f4             	pushl  -0xc(%ebp)
  800df9:	e8 fe f4 ff ff       	call   8002fc <fd2data>
	return _pipeisclosed(fd, p);
  800dfe:	89 c2                	mov    %eax,%edx
  800e00:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800e03:	e8 0c fd ff ff       	call   800b14 <_pipeisclosed>
  800e08:	83 c4 10             	add    $0x10,%esp
}
  800e0b:	c9                   	leave  
  800e0c:	c3                   	ret    
  800e0d:	00 00                	add    %al,(%eax)
	...

00800e10 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  800e10:	55                   	push   %ebp
  800e11:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  800e13:	b8 00 00 00 00       	mov    $0x0,%eax
  800e18:	c9                   	leave  
  800e19:	c3                   	ret    

00800e1a <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  800e1a:	55                   	push   %ebp
  800e1b:	89 e5                	mov    %esp,%ebp
  800e1d:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  800e20:	68 76 1e 80 00       	push   $0x801e76
  800e25:	ff 75 0c             	pushl  0xc(%ebp)
  800e28:	e8 01 08 00 00       	call   80162e <strcpy>
	return 0;
}
  800e2d:	b8 00 00 00 00       	mov    $0x0,%eax
  800e32:	c9                   	leave  
  800e33:	c3                   	ret    

00800e34 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  800e34:	55                   	push   %ebp
  800e35:	89 e5                	mov    %esp,%ebp
  800e37:	57                   	push   %edi
  800e38:	56                   	push   %esi
  800e39:	53                   	push   %ebx
  800e3a:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800e40:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800e44:	74 45                	je     800e8b <devcons_write+0x57>
  800e46:	b8 00 00 00 00       	mov    $0x0,%eax
  800e4b:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  800e50:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  800e56:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e59:	29 c3                	sub    %eax,%ebx
		if (m > sizeof(buf) - 1)
  800e5b:	83 fb 7f             	cmp    $0x7f,%ebx
  800e5e:	76 05                	jbe    800e65 <devcons_write+0x31>
			m = sizeof(buf) - 1;
  800e60:	bb 7f 00 00 00       	mov    $0x7f,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  800e65:	83 ec 04             	sub    $0x4,%esp
  800e68:	53                   	push   %ebx
  800e69:	03 45 0c             	add    0xc(%ebp),%eax
  800e6c:	50                   	push   %eax
  800e6d:	57                   	push   %edi
  800e6e:	e8 7c 09 00 00       	call   8017ef <memmove>
		sys_cputs(buf, m);
  800e73:	83 c4 08             	add    $0x8,%esp
  800e76:	53                   	push   %ebx
  800e77:	57                   	push   %edi
  800e78:	e8 78 f2 ff ff       	call   8000f5 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800e7d:	01 de                	add    %ebx,%esi
  800e7f:	89 f0                	mov    %esi,%eax
  800e81:	83 c4 10             	add    $0x10,%esp
  800e84:	3b 75 10             	cmp    0x10(%ebp),%esi
  800e87:	72 cd                	jb     800e56 <devcons_write+0x22>
  800e89:	eb 05                	jmp    800e90 <devcons_write+0x5c>
  800e8b:	be 00 00 00 00       	mov    $0x0,%esi
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  800e90:	89 f0                	mov    %esi,%eax
  800e92:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e95:	5b                   	pop    %ebx
  800e96:	5e                   	pop    %esi
  800e97:	5f                   	pop    %edi
  800e98:	c9                   	leave  
  800e99:	c3                   	ret    

00800e9a <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  800e9a:	55                   	push   %ebp
  800e9b:	89 e5                	mov    %esp,%ebp
  800e9d:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
  800ea0:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800ea4:	75 07                	jne    800ead <devcons_read+0x13>
  800ea6:	eb 25                	jmp    800ecd <devcons_read+0x33>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  800ea8:	e8 d8 f2 ff ff       	call   800185 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  800ead:	e8 69 f2 ff ff       	call   80011b <sys_cgetc>
  800eb2:	85 c0                	test   %eax,%eax
  800eb4:	74 f2                	je     800ea8 <devcons_read+0xe>
  800eb6:	89 c2                	mov    %eax,%edx
		sys_yield();
	if (c < 0)
  800eb8:	85 c0                	test   %eax,%eax
  800eba:	78 1d                	js     800ed9 <devcons_read+0x3f>
		return c;
	if (c == 0x04)	// ctl-d is eof
  800ebc:	83 f8 04             	cmp    $0x4,%eax
  800ebf:	74 13                	je     800ed4 <devcons_read+0x3a>
		return 0;
	*(char*)vbuf = c;
  800ec1:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ec4:	88 10                	mov    %dl,(%eax)
	return 1;
  800ec6:	b8 01 00 00 00       	mov    $0x1,%eax
  800ecb:	eb 0c                	jmp    800ed9 <devcons_read+0x3f>
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
		return 0;
  800ecd:	b8 00 00 00 00       	mov    $0x0,%eax
  800ed2:	eb 05                	jmp    800ed9 <devcons_read+0x3f>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  800ed4:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  800ed9:	c9                   	leave  
  800eda:	c3                   	ret    

00800edb <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  800edb:	55                   	push   %ebp
  800edc:	89 e5                	mov    %esp,%ebp
  800ede:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  800ee1:	8b 45 08             	mov    0x8(%ebp),%eax
  800ee4:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  800ee7:	6a 01                	push   $0x1
  800ee9:	8d 45 f7             	lea    -0x9(%ebp),%eax
  800eec:	50                   	push   %eax
  800eed:	e8 03 f2 ff ff       	call   8000f5 <sys_cputs>
  800ef2:	83 c4 10             	add    $0x10,%esp
}
  800ef5:	c9                   	leave  
  800ef6:	c3                   	ret    

00800ef7 <getchar>:

int
getchar(void)
{
  800ef7:	55                   	push   %ebp
  800ef8:	89 e5                	mov    %esp,%ebp
  800efa:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  800efd:	6a 01                	push   $0x1
  800eff:	8d 45 f7             	lea    -0x9(%ebp),%eax
  800f02:	50                   	push   %eax
  800f03:	6a 00                	push   $0x0
  800f05:	e8 fe f6 ff ff       	call   800608 <read>
	if (r < 0)
  800f0a:	83 c4 10             	add    $0x10,%esp
  800f0d:	85 c0                	test   %eax,%eax
  800f0f:	78 0f                	js     800f20 <getchar+0x29>
		return r;
	if (r < 1)
  800f11:	85 c0                	test   %eax,%eax
  800f13:	7e 06                	jle    800f1b <getchar+0x24>
		return -E_EOF;
	return c;
  800f15:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  800f19:	eb 05                	jmp    800f20 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  800f1b:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  800f20:	c9                   	leave  
  800f21:	c3                   	ret    

00800f22 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  800f22:	55                   	push   %ebp
  800f23:	89 e5                	mov    %esp,%ebp
  800f25:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800f28:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800f2b:	50                   	push   %eax
  800f2c:	ff 75 08             	pushl  0x8(%ebp)
  800f2f:	e8 53 f4 ff ff       	call   800387 <fd_lookup>
  800f34:	83 c4 10             	add    $0x10,%esp
  800f37:	85 c0                	test   %eax,%eax
  800f39:	78 11                	js     800f4c <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  800f3b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800f3e:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  800f44:	39 10                	cmp    %edx,(%eax)
  800f46:	0f 94 c0             	sete   %al
  800f49:	0f b6 c0             	movzbl %al,%eax
}
  800f4c:	c9                   	leave  
  800f4d:	c3                   	ret    

00800f4e <opencons>:

int
opencons(void)
{
  800f4e:	55                   	push   %ebp
  800f4f:	89 e5                	mov    %esp,%ebp
  800f51:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  800f54:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800f57:	50                   	push   %eax
  800f58:	e8 b7 f3 ff ff       	call   800314 <fd_alloc>
  800f5d:	83 c4 10             	add    $0x10,%esp
  800f60:	85 c0                	test   %eax,%eax
  800f62:	78 3a                	js     800f9e <opencons+0x50>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  800f64:	83 ec 04             	sub    $0x4,%esp
  800f67:	68 07 04 00 00       	push   $0x407
  800f6c:	ff 75 f4             	pushl  -0xc(%ebp)
  800f6f:	6a 00                	push   $0x0
  800f71:	e8 36 f2 ff ff       	call   8001ac <sys_page_alloc>
  800f76:	83 c4 10             	add    $0x10,%esp
  800f79:	85 c0                	test   %eax,%eax
  800f7b:	78 21                	js     800f9e <opencons+0x50>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  800f7d:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  800f83:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800f86:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  800f88:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800f8b:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  800f92:	83 ec 0c             	sub    $0xc,%esp
  800f95:	50                   	push   %eax
  800f96:	e8 51 f3 ff ff       	call   8002ec <fd2num>
  800f9b:	83 c4 10             	add    $0x10,%esp
}
  800f9e:	c9                   	leave  
  800f9f:	c3                   	ret    

00800fa0 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800fa0:	55                   	push   %ebp
  800fa1:	89 e5                	mov    %esp,%ebp
  800fa3:	56                   	push   %esi
  800fa4:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800fa5:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800fa8:	8b 1d 00 30 80 00    	mov    0x803000,%ebx
  800fae:	e8 ae f1 ff ff       	call   800161 <sys_getenvid>
  800fb3:	83 ec 0c             	sub    $0xc,%esp
  800fb6:	ff 75 0c             	pushl  0xc(%ebp)
  800fb9:	ff 75 08             	pushl  0x8(%ebp)
  800fbc:	53                   	push   %ebx
  800fbd:	50                   	push   %eax
  800fbe:	68 84 1e 80 00       	push   $0x801e84
  800fc3:	e8 b0 00 00 00       	call   801078 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800fc8:	83 c4 18             	add    $0x18,%esp
  800fcb:	56                   	push   %esi
  800fcc:	ff 75 10             	pushl  0x10(%ebp)
  800fcf:	e8 53 00 00 00       	call   801027 <vcprintf>
	cprintf("\n");
  800fd4:	c7 04 24 6f 1e 80 00 	movl   $0x801e6f,(%esp)
  800fdb:	e8 98 00 00 00       	call   801078 <cprintf>
  800fe0:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800fe3:	cc                   	int3   
  800fe4:	eb fd                	jmp    800fe3 <_panic+0x43>
	...

00800fe8 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800fe8:	55                   	push   %ebp
  800fe9:	89 e5                	mov    %esp,%ebp
  800feb:	53                   	push   %ebx
  800fec:	83 ec 04             	sub    $0x4,%esp
  800fef:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800ff2:	8b 03                	mov    (%ebx),%eax
  800ff4:	8b 55 08             	mov    0x8(%ebp),%edx
  800ff7:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  800ffb:	40                   	inc    %eax
  800ffc:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  800ffe:	3d ff 00 00 00       	cmp    $0xff,%eax
  801003:	75 1a                	jne    80101f <putch+0x37>
		sys_cputs(b->buf, b->idx);
  801005:	83 ec 08             	sub    $0x8,%esp
  801008:	68 ff 00 00 00       	push   $0xff
  80100d:	8d 43 08             	lea    0x8(%ebx),%eax
  801010:	50                   	push   %eax
  801011:	e8 df f0 ff ff       	call   8000f5 <sys_cputs>
		b->idx = 0;
  801016:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80101c:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  80101f:	ff 43 04             	incl   0x4(%ebx)
}
  801022:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801025:	c9                   	leave  
  801026:	c3                   	ret    

00801027 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  801027:	55                   	push   %ebp
  801028:	89 e5                	mov    %esp,%ebp
  80102a:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  801030:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  801037:	00 00 00 
	b.cnt = 0;
  80103a:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  801041:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  801044:	ff 75 0c             	pushl  0xc(%ebp)
  801047:	ff 75 08             	pushl  0x8(%ebp)
  80104a:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  801050:	50                   	push   %eax
  801051:	68 e8 0f 80 00       	push   $0x800fe8
  801056:	e8 82 01 00 00       	call   8011dd <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80105b:	83 c4 08             	add    $0x8,%esp
  80105e:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  801064:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80106a:	50                   	push   %eax
  80106b:	e8 85 f0 ff ff       	call   8000f5 <sys_cputs>

	return b.cnt;
}
  801070:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  801076:	c9                   	leave  
  801077:	c3                   	ret    

00801078 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  801078:	55                   	push   %ebp
  801079:	89 e5                	mov    %esp,%ebp
  80107b:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80107e:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  801081:	50                   	push   %eax
  801082:	ff 75 08             	pushl  0x8(%ebp)
  801085:	e8 9d ff ff ff       	call   801027 <vcprintf>
	va_end(ap);

	return cnt;
}
  80108a:	c9                   	leave  
  80108b:	c3                   	ret    

0080108c <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80108c:	55                   	push   %ebp
  80108d:	89 e5                	mov    %esp,%ebp
  80108f:	57                   	push   %edi
  801090:	56                   	push   %esi
  801091:	53                   	push   %ebx
  801092:	83 ec 2c             	sub    $0x2c,%esp
  801095:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801098:	89 d6                	mov    %edx,%esi
  80109a:	8b 45 08             	mov    0x8(%ebp),%eax
  80109d:	8b 55 0c             	mov    0xc(%ebp),%edx
  8010a0:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8010a3:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8010a6:	8b 45 10             	mov    0x10(%ebp),%eax
  8010a9:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8010ac:	8b 7d 18             	mov    0x18(%ebp),%edi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8010af:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8010b2:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  8010b9:	39 55 d4             	cmp    %edx,-0x2c(%ebp)
  8010bc:	72 0c                	jb     8010ca <printnum+0x3e>
  8010be:	3b 45 d8             	cmp    -0x28(%ebp),%eax
  8010c1:	76 07                	jbe    8010ca <printnum+0x3e>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8010c3:	4b                   	dec    %ebx
  8010c4:	85 db                	test   %ebx,%ebx
  8010c6:	7f 31                	jg     8010f9 <printnum+0x6d>
  8010c8:	eb 3f                	jmp    801109 <printnum+0x7d>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8010ca:	83 ec 0c             	sub    $0xc,%esp
  8010cd:	57                   	push   %edi
  8010ce:	4b                   	dec    %ebx
  8010cf:	53                   	push   %ebx
  8010d0:	50                   	push   %eax
  8010d1:	83 ec 08             	sub    $0x8,%esp
  8010d4:	ff 75 d4             	pushl  -0x2c(%ebp)
  8010d7:	ff 75 d0             	pushl  -0x30(%ebp)
  8010da:	ff 75 dc             	pushl  -0x24(%ebp)
  8010dd:	ff 75 d8             	pushl  -0x28(%ebp)
  8010e0:	e8 33 0a 00 00       	call   801b18 <__udivdi3>
  8010e5:	83 c4 18             	add    $0x18,%esp
  8010e8:	52                   	push   %edx
  8010e9:	50                   	push   %eax
  8010ea:	89 f2                	mov    %esi,%edx
  8010ec:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8010ef:	e8 98 ff ff ff       	call   80108c <printnum>
  8010f4:	83 c4 20             	add    $0x20,%esp
  8010f7:	eb 10                	jmp    801109 <printnum+0x7d>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8010f9:	83 ec 08             	sub    $0x8,%esp
  8010fc:	56                   	push   %esi
  8010fd:	57                   	push   %edi
  8010fe:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  801101:	4b                   	dec    %ebx
  801102:	83 c4 10             	add    $0x10,%esp
  801105:	85 db                	test   %ebx,%ebx
  801107:	7f f0                	jg     8010f9 <printnum+0x6d>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  801109:	83 ec 08             	sub    $0x8,%esp
  80110c:	56                   	push   %esi
  80110d:	83 ec 04             	sub    $0x4,%esp
  801110:	ff 75 d4             	pushl  -0x2c(%ebp)
  801113:	ff 75 d0             	pushl  -0x30(%ebp)
  801116:	ff 75 dc             	pushl  -0x24(%ebp)
  801119:	ff 75 d8             	pushl  -0x28(%ebp)
  80111c:	e8 13 0b 00 00       	call   801c34 <__umoddi3>
  801121:	83 c4 14             	add    $0x14,%esp
  801124:	0f be 80 a7 1e 80 00 	movsbl 0x801ea7(%eax),%eax
  80112b:	50                   	push   %eax
  80112c:	ff 55 e4             	call   *-0x1c(%ebp)
  80112f:	83 c4 10             	add    $0x10,%esp
}
  801132:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801135:	5b                   	pop    %ebx
  801136:	5e                   	pop    %esi
  801137:	5f                   	pop    %edi
  801138:	c9                   	leave  
  801139:	c3                   	ret    

0080113a <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80113a:	55                   	push   %ebp
  80113b:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80113d:	83 fa 01             	cmp    $0x1,%edx
  801140:	7e 0e                	jle    801150 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  801142:	8b 10                	mov    (%eax),%edx
  801144:	8d 4a 08             	lea    0x8(%edx),%ecx
  801147:	89 08                	mov    %ecx,(%eax)
  801149:	8b 02                	mov    (%edx),%eax
  80114b:	8b 52 04             	mov    0x4(%edx),%edx
  80114e:	eb 22                	jmp    801172 <getuint+0x38>
	else if (lflag)
  801150:	85 d2                	test   %edx,%edx
  801152:	74 10                	je     801164 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  801154:	8b 10                	mov    (%eax),%edx
  801156:	8d 4a 04             	lea    0x4(%edx),%ecx
  801159:	89 08                	mov    %ecx,(%eax)
  80115b:	8b 02                	mov    (%edx),%eax
  80115d:	ba 00 00 00 00       	mov    $0x0,%edx
  801162:	eb 0e                	jmp    801172 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  801164:	8b 10                	mov    (%eax),%edx
  801166:	8d 4a 04             	lea    0x4(%edx),%ecx
  801169:	89 08                	mov    %ecx,(%eax)
  80116b:	8b 02                	mov    (%edx),%eax
  80116d:	ba 00 00 00 00       	mov    $0x0,%edx
}
  801172:	c9                   	leave  
  801173:	c3                   	ret    

00801174 <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
  801174:	55                   	push   %ebp
  801175:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  801177:	83 fa 01             	cmp    $0x1,%edx
  80117a:	7e 0e                	jle    80118a <getint+0x16>
		return va_arg(*ap, long long);
  80117c:	8b 10                	mov    (%eax),%edx
  80117e:	8d 4a 08             	lea    0x8(%edx),%ecx
  801181:	89 08                	mov    %ecx,(%eax)
  801183:	8b 02                	mov    (%edx),%eax
  801185:	8b 52 04             	mov    0x4(%edx),%edx
  801188:	eb 1a                	jmp    8011a4 <getint+0x30>
	else if (lflag)
  80118a:	85 d2                	test   %edx,%edx
  80118c:	74 0c                	je     80119a <getint+0x26>
		return va_arg(*ap, long);
  80118e:	8b 10                	mov    (%eax),%edx
  801190:	8d 4a 04             	lea    0x4(%edx),%ecx
  801193:	89 08                	mov    %ecx,(%eax)
  801195:	8b 02                	mov    (%edx),%eax
  801197:	99                   	cltd   
  801198:	eb 0a                	jmp    8011a4 <getint+0x30>
	else
		return va_arg(*ap, int);
  80119a:	8b 10                	mov    (%eax),%edx
  80119c:	8d 4a 04             	lea    0x4(%edx),%ecx
  80119f:	89 08                	mov    %ecx,(%eax)
  8011a1:	8b 02                	mov    (%edx),%eax
  8011a3:	99                   	cltd   
}
  8011a4:	c9                   	leave  
  8011a5:	c3                   	ret    

008011a6 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8011a6:	55                   	push   %ebp
  8011a7:	89 e5                	mov    %esp,%ebp
  8011a9:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8011ac:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  8011af:	8b 10                	mov    (%eax),%edx
  8011b1:	3b 50 04             	cmp    0x4(%eax),%edx
  8011b4:	73 08                	jae    8011be <sprintputch+0x18>
		*b->buf++ = ch;
  8011b6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8011b9:	88 0a                	mov    %cl,(%edx)
  8011bb:	42                   	inc    %edx
  8011bc:	89 10                	mov    %edx,(%eax)
}
  8011be:	c9                   	leave  
  8011bf:	c3                   	ret    

008011c0 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8011c0:	55                   	push   %ebp
  8011c1:	89 e5                	mov    %esp,%ebp
  8011c3:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8011c6:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8011c9:	50                   	push   %eax
  8011ca:	ff 75 10             	pushl  0x10(%ebp)
  8011cd:	ff 75 0c             	pushl  0xc(%ebp)
  8011d0:	ff 75 08             	pushl  0x8(%ebp)
  8011d3:	e8 05 00 00 00       	call   8011dd <vprintfmt>
	va_end(ap);
  8011d8:	83 c4 10             	add    $0x10,%esp
}
  8011db:	c9                   	leave  
  8011dc:	c3                   	ret    

008011dd <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8011dd:	55                   	push   %ebp
  8011de:	89 e5                	mov    %esp,%ebp
  8011e0:	57                   	push   %edi
  8011e1:	56                   	push   %esi
  8011e2:	53                   	push   %ebx
  8011e3:	83 ec 2c             	sub    $0x2c,%esp
  8011e6:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8011e9:	8b 75 10             	mov    0x10(%ebp),%esi
  8011ec:	eb 13                	jmp    801201 <vprintfmt+0x24>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8011ee:	85 c0                	test   %eax,%eax
  8011f0:	0f 84 6d 03 00 00    	je     801563 <vprintfmt+0x386>
				return;
			putch(ch, putdat);
  8011f6:	83 ec 08             	sub    $0x8,%esp
  8011f9:	57                   	push   %edi
  8011fa:	50                   	push   %eax
  8011fb:	ff 55 08             	call   *0x8(%ebp)
  8011fe:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  801201:	0f b6 06             	movzbl (%esi),%eax
  801204:	46                   	inc    %esi
  801205:	83 f8 25             	cmp    $0x25,%eax
  801208:	75 e4                	jne    8011ee <vprintfmt+0x11>
  80120a:	c6 45 dc 20          	movb   $0x20,-0x24(%ebp)
  80120e:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  801215:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
  80121c:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  801223:	b9 00 00 00 00       	mov    $0x0,%ecx
  801228:	eb 28                	jmp    801252 <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80122a:	89 de                	mov    %ebx,%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  80122c:	c6 45 dc 2d          	movb   $0x2d,-0x24(%ebp)
  801230:	eb 20                	jmp    801252 <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801232:	89 de                	mov    %ebx,%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  801234:	c6 45 dc 30          	movb   $0x30,-0x24(%ebp)
  801238:	eb 18                	jmp    801252 <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80123a:	89 de                	mov    %ebx,%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  80123c:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  801243:	eb 0d                	jmp    801252 <vprintfmt+0x75>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  801245:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  801248:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80124b:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801252:	8a 06                	mov    (%esi),%al
  801254:	0f b6 d0             	movzbl %al,%edx
  801257:	8d 5e 01             	lea    0x1(%esi),%ebx
  80125a:	83 e8 23             	sub    $0x23,%eax
  80125d:	3c 55                	cmp    $0x55,%al
  80125f:	0f 87 e0 02 00 00    	ja     801545 <vprintfmt+0x368>
  801265:	0f b6 c0             	movzbl %al,%eax
  801268:	ff 24 85 e0 1f 80 00 	jmp    *0x801fe0(,%eax,4)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80126f:	83 ea 30             	sub    $0x30,%edx
  801272:	89 55 d4             	mov    %edx,-0x2c(%ebp)
				ch = *fmt;
  801275:	0f be 03             	movsbl (%ebx),%eax
				if (ch < '0' || ch > '9')
  801278:	8d 50 d0             	lea    -0x30(%eax),%edx
  80127b:	83 fa 09             	cmp    $0x9,%edx
  80127e:	77 44                	ja     8012c4 <vprintfmt+0xe7>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801280:	89 de                	mov    %ebx,%esi
  801282:	8b 55 d4             	mov    -0x2c(%ebp),%edx
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  801285:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
  801286:	8d 14 92             	lea    (%edx,%edx,4),%edx
  801289:	8d 54 50 d0          	lea    -0x30(%eax,%edx,2),%edx
				ch = *fmt;
  80128d:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  801290:	8d 58 d0             	lea    -0x30(%eax),%ebx
  801293:	83 fb 09             	cmp    $0x9,%ebx
  801296:	76 ed                	jbe    801285 <vprintfmt+0xa8>
  801298:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  80129b:	eb 29                	jmp    8012c6 <vprintfmt+0xe9>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  80129d:	8b 45 14             	mov    0x14(%ebp),%eax
  8012a0:	8d 50 04             	lea    0x4(%eax),%edx
  8012a3:	89 55 14             	mov    %edx,0x14(%ebp)
  8012a6:	8b 00                	mov    (%eax),%eax
  8012a8:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8012ab:	89 de                	mov    %ebx,%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8012ad:	eb 17                	jmp    8012c6 <vprintfmt+0xe9>

		case '.':
			if (width < 0)
  8012af:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8012b3:	78 85                	js     80123a <vprintfmt+0x5d>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8012b5:	89 de                	mov    %ebx,%esi
  8012b7:	eb 99                	jmp    801252 <vprintfmt+0x75>
  8012b9:	89 de                	mov    %ebx,%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8012bb:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
			goto reswitch;
  8012c2:	eb 8e                	jmp    801252 <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8012c4:	89 de                	mov    %ebx,%esi
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  8012c6:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8012ca:	79 86                	jns    801252 <vprintfmt+0x75>
  8012cc:	e9 74 ff ff ff       	jmp    801245 <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8012d1:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8012d2:	89 de                	mov    %ebx,%esi
  8012d4:	e9 79 ff ff ff       	jmp    801252 <vprintfmt+0x75>
  8012d9:	89 5d d8             	mov    %ebx,-0x28(%ebp)
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8012dc:	8b 45 14             	mov    0x14(%ebp),%eax
  8012df:	8d 50 04             	lea    0x4(%eax),%edx
  8012e2:	89 55 14             	mov    %edx,0x14(%ebp)
  8012e5:	83 ec 08             	sub    $0x8,%esp
  8012e8:	57                   	push   %edi
  8012e9:	ff 30                	pushl  (%eax)
  8012eb:	ff 55 08             	call   *0x8(%ebp)
			break;
  8012ee:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8012f1:	8b 75 d8             	mov    -0x28(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8012f4:	e9 08 ff ff ff       	jmp    801201 <vprintfmt+0x24>
  8012f9:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// error message
		case 'e':
			err = va_arg(ap, int);
  8012fc:	8b 45 14             	mov    0x14(%ebp),%eax
  8012ff:	8d 50 04             	lea    0x4(%eax),%edx
  801302:	89 55 14             	mov    %edx,0x14(%ebp)
  801305:	8b 00                	mov    (%eax),%eax
  801307:	85 c0                	test   %eax,%eax
  801309:	79 02                	jns    80130d <vprintfmt+0x130>
  80130b:	f7 d8                	neg    %eax
  80130d:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80130f:	83 f8 0f             	cmp    $0xf,%eax
  801312:	7f 0b                	jg     80131f <vprintfmt+0x142>
  801314:	8b 04 85 40 21 80 00 	mov    0x802140(,%eax,4),%eax
  80131b:	85 c0                	test   %eax,%eax
  80131d:	75 1a                	jne    801339 <vprintfmt+0x15c>
				printfmt(putch, putdat, "error %d", err);
  80131f:	52                   	push   %edx
  801320:	68 bf 1e 80 00       	push   $0x801ebf
  801325:	57                   	push   %edi
  801326:	ff 75 08             	pushl  0x8(%ebp)
  801329:	e8 92 fe ff ff       	call   8011c0 <printfmt>
  80132e:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801331:	8b 75 d8             	mov    -0x28(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  801334:	e9 c8 fe ff ff       	jmp    801201 <vprintfmt+0x24>
			else
				printfmt(putch, putdat, "%s", p);
  801339:	50                   	push   %eax
  80133a:	68 3d 1e 80 00       	push   $0x801e3d
  80133f:	57                   	push   %edi
  801340:	ff 75 08             	pushl  0x8(%ebp)
  801343:	e8 78 fe ff ff       	call   8011c0 <printfmt>
  801348:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80134b:	8b 75 d8             	mov    -0x28(%ebp),%esi
  80134e:	e9 ae fe ff ff       	jmp    801201 <vprintfmt+0x24>
  801353:	89 5d d8             	mov    %ebx,-0x28(%ebp)
  801356:	89 de                	mov    %ebx,%esi
  801358:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  80135b:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80135e:	8b 45 14             	mov    0x14(%ebp),%eax
  801361:	8d 50 04             	lea    0x4(%eax),%edx
  801364:	89 55 14             	mov    %edx,0x14(%ebp)
  801367:	8b 00                	mov    (%eax),%eax
  801369:	89 45 d0             	mov    %eax,-0x30(%ebp)
  80136c:	85 c0                	test   %eax,%eax
  80136e:	75 07                	jne    801377 <vprintfmt+0x19a>
				p = "(null)";
  801370:	c7 45 d0 b8 1e 80 00 	movl   $0x801eb8,-0x30(%ebp)
			if (width > 0 && padc != '-')
  801377:	85 db                	test   %ebx,%ebx
  801379:	7e 42                	jle    8013bd <vprintfmt+0x1e0>
  80137b:	80 7d dc 2d          	cmpb   $0x2d,-0x24(%ebp)
  80137f:	74 3c                	je     8013bd <vprintfmt+0x1e0>
				for (width -= strnlen(p, precision); width > 0; width--)
  801381:	83 ec 08             	sub    $0x8,%esp
  801384:	51                   	push   %ecx
  801385:	ff 75 d0             	pushl  -0x30(%ebp)
  801388:	e8 6f 02 00 00       	call   8015fc <strnlen>
  80138d:	29 c3                	sub    %eax,%ebx
  80138f:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  801392:	83 c4 10             	add    $0x10,%esp
  801395:	85 db                	test   %ebx,%ebx
  801397:	7e 24                	jle    8013bd <vprintfmt+0x1e0>
					putch(padc, putdat);
  801399:	0f be 5d dc          	movsbl -0x24(%ebp),%ebx
  80139d:	89 75 dc             	mov    %esi,-0x24(%ebp)
  8013a0:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  8013a3:	83 ec 08             	sub    $0x8,%esp
  8013a6:	57                   	push   %edi
  8013a7:	53                   	push   %ebx
  8013a8:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8013ab:	4e                   	dec    %esi
  8013ac:	83 c4 10             	add    $0x10,%esp
  8013af:	85 f6                	test   %esi,%esi
  8013b1:	7f f0                	jg     8013a3 <vprintfmt+0x1c6>
  8013b3:	8b 75 dc             	mov    -0x24(%ebp),%esi
  8013b6:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8013bd:	8b 55 d0             	mov    -0x30(%ebp),%edx
  8013c0:	0f be 02             	movsbl (%edx),%eax
  8013c3:	85 c0                	test   %eax,%eax
  8013c5:	75 47                	jne    80140e <vprintfmt+0x231>
  8013c7:	eb 37                	jmp    801400 <vprintfmt+0x223>
				if (altflag && (ch < ' ' || ch > '~'))
  8013c9:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8013cd:	74 16                	je     8013e5 <vprintfmt+0x208>
  8013cf:	8d 50 e0             	lea    -0x20(%eax),%edx
  8013d2:	83 fa 5e             	cmp    $0x5e,%edx
  8013d5:	76 0e                	jbe    8013e5 <vprintfmt+0x208>
					putch('?', putdat);
  8013d7:	83 ec 08             	sub    $0x8,%esp
  8013da:	57                   	push   %edi
  8013db:	6a 3f                	push   $0x3f
  8013dd:	ff 55 08             	call   *0x8(%ebp)
  8013e0:	83 c4 10             	add    $0x10,%esp
  8013e3:	eb 0b                	jmp    8013f0 <vprintfmt+0x213>
				else
					putch(ch, putdat);
  8013e5:	83 ec 08             	sub    $0x8,%esp
  8013e8:	57                   	push   %edi
  8013e9:	50                   	push   %eax
  8013ea:	ff 55 08             	call   *0x8(%ebp)
  8013ed:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8013f0:	ff 4d e4             	decl   -0x1c(%ebp)
  8013f3:	0f be 03             	movsbl (%ebx),%eax
  8013f6:	85 c0                	test   %eax,%eax
  8013f8:	74 03                	je     8013fd <vprintfmt+0x220>
  8013fa:	43                   	inc    %ebx
  8013fb:	eb 1b                	jmp    801418 <vprintfmt+0x23b>
  8013fd:	8b 75 dc             	mov    -0x24(%ebp),%esi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  801400:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  801404:	7f 1e                	jg     801424 <vprintfmt+0x247>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801406:	8b 75 d8             	mov    -0x28(%ebp),%esi
  801409:	e9 f3 fd ff ff       	jmp    801201 <vprintfmt+0x24>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80140e:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  801411:	43                   	inc    %ebx
  801412:	89 75 dc             	mov    %esi,-0x24(%ebp)
  801415:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  801418:	85 f6                	test   %esi,%esi
  80141a:	78 ad                	js     8013c9 <vprintfmt+0x1ec>
  80141c:	4e                   	dec    %esi
  80141d:	79 aa                	jns    8013c9 <vprintfmt+0x1ec>
  80141f:	8b 75 dc             	mov    -0x24(%ebp),%esi
  801422:	eb dc                	jmp    801400 <vprintfmt+0x223>
  801424:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  801427:	83 ec 08             	sub    $0x8,%esp
  80142a:	57                   	push   %edi
  80142b:	6a 20                	push   $0x20
  80142d:	ff 55 08             	call   *0x8(%ebp)
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  801430:	4b                   	dec    %ebx
  801431:	83 c4 10             	add    $0x10,%esp
  801434:	85 db                	test   %ebx,%ebx
  801436:	7f ef                	jg     801427 <vprintfmt+0x24a>
  801438:	e9 c4 fd ff ff       	jmp    801201 <vprintfmt+0x24>
  80143d:	89 5d d8             	mov    %ebx,-0x28(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  801440:	89 ca                	mov    %ecx,%edx
  801442:	8d 45 14             	lea    0x14(%ebp),%eax
  801445:	e8 2a fd ff ff       	call   801174 <getint>
  80144a:	89 c3                	mov    %eax,%ebx
  80144c:	89 d6                	mov    %edx,%esi
			if ((long long) num < 0) {
  80144e:	85 d2                	test   %edx,%edx
  801450:	78 0a                	js     80145c <vprintfmt+0x27f>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  801452:	b8 0a 00 00 00       	mov    $0xa,%eax
  801457:	e9 b0 00 00 00       	jmp    80150c <vprintfmt+0x32f>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  80145c:	83 ec 08             	sub    $0x8,%esp
  80145f:	57                   	push   %edi
  801460:	6a 2d                	push   $0x2d
  801462:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  801465:	f7 db                	neg    %ebx
  801467:	83 d6 00             	adc    $0x0,%esi
  80146a:	f7 de                	neg    %esi
  80146c:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  80146f:	b8 0a 00 00 00       	mov    $0xa,%eax
  801474:	e9 93 00 00 00       	jmp    80150c <vprintfmt+0x32f>
  801479:	89 5d d8             	mov    %ebx,-0x28(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  80147c:	89 ca                	mov    %ecx,%edx
  80147e:	8d 45 14             	lea    0x14(%ebp),%eax
  801481:	e8 b4 fc ff ff       	call   80113a <getuint>
  801486:	89 c3                	mov    %eax,%ebx
  801488:	89 d6                	mov    %edx,%esi
			base = 10;
  80148a:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  80148f:	eb 7b                	jmp    80150c <vprintfmt+0x32f>
  801491:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// (unsigned) octal
		case 'o':
            // (MIT 6.828, lab1, Ex.8)  my code : 
            num = getint(&ap, lflag);
  801494:	89 ca                	mov    %ecx,%edx
  801496:	8d 45 14             	lea    0x14(%ebp),%eax
  801499:	e8 d6 fc ff ff       	call   801174 <getint>
  80149e:	89 c3                	mov    %eax,%ebx
  8014a0:	89 d6                	mov    %edx,%esi
            if ((long long) num < 0) {
  8014a2:	85 d2                	test   %edx,%edx
  8014a4:	78 07                	js     8014ad <vprintfmt+0x2d0>
                putch('-', putdat);
                num = -(long long) num;
            }
            base = 8;
  8014a6:	b8 08 00 00 00       	mov    $0x8,%eax
  8014ab:	eb 5f                	jmp    80150c <vprintfmt+0x32f>
		// (unsigned) octal
		case 'o':
            // (MIT 6.828, lab1, Ex.8)  my code : 
            num = getint(&ap, lflag);
            if ((long long) num < 0) {
                putch('-', putdat);
  8014ad:	83 ec 08             	sub    $0x8,%esp
  8014b0:	57                   	push   %edi
  8014b1:	6a 2d                	push   $0x2d
  8014b3:	ff 55 08             	call   *0x8(%ebp)
                num = -(long long) num;
  8014b6:	f7 db                	neg    %ebx
  8014b8:	83 d6 00             	adc    $0x0,%esi
  8014bb:	f7 de                	neg    %esi
  8014bd:	83 c4 10             	add    $0x10,%esp
            }
            base = 8;
  8014c0:	b8 08 00 00 00       	mov    $0x8,%eax
  8014c5:	eb 45                	jmp    80150c <vprintfmt+0x32f>
  8014c7:	89 5d d8             	mov    %ebx,-0x28(%ebp)
            goto number;

        // pointer
		case 'p':
			putch('0', putdat);
  8014ca:	83 ec 08             	sub    $0x8,%esp
  8014cd:	57                   	push   %edi
  8014ce:	6a 30                	push   $0x30
  8014d0:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  8014d3:	83 c4 08             	add    $0x8,%esp
  8014d6:	57                   	push   %edi
  8014d7:	6a 78                	push   $0x78
  8014d9:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8014dc:	8b 45 14             	mov    0x14(%ebp),%eax
  8014df:	8d 50 04             	lea    0x4(%eax),%edx
  8014e2:	89 55 14             	mov    %edx,0x14(%ebp)

        // pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8014e5:	8b 18                	mov    (%eax),%ebx
  8014e7:	be 00 00 00 00       	mov    $0x0,%esi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8014ec:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8014ef:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  8014f4:	eb 16                	jmp    80150c <vprintfmt+0x32f>
  8014f6:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8014f9:	89 ca                	mov    %ecx,%edx
  8014fb:	8d 45 14             	lea    0x14(%ebp),%eax
  8014fe:	e8 37 fc ff ff       	call   80113a <getuint>
  801503:	89 c3                	mov    %eax,%ebx
  801505:	89 d6                	mov    %edx,%esi
			base = 16;
  801507:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  80150c:	83 ec 0c             	sub    $0xc,%esp
  80150f:	0f be 55 dc          	movsbl -0x24(%ebp),%edx
  801513:	52                   	push   %edx
  801514:	ff 75 e4             	pushl  -0x1c(%ebp)
  801517:	50                   	push   %eax
  801518:	56                   	push   %esi
  801519:	53                   	push   %ebx
  80151a:	89 fa                	mov    %edi,%edx
  80151c:	8b 45 08             	mov    0x8(%ebp),%eax
  80151f:	e8 68 fb ff ff       	call   80108c <printnum>
			break;
  801524:	83 c4 20             	add    $0x20,%esp
  801527:	8b 75 d8             	mov    -0x28(%ebp),%esi
  80152a:	e9 d2 fc ff ff       	jmp    801201 <vprintfmt+0x24>
  80152f:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  801532:	83 ec 08             	sub    $0x8,%esp
  801535:	57                   	push   %edi
  801536:	52                   	push   %edx
  801537:	ff 55 08             	call   *0x8(%ebp)
			break;
  80153a:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80153d:	8b 75 d8             	mov    -0x28(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  801540:	e9 bc fc ff ff       	jmp    801201 <vprintfmt+0x24>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  801545:	83 ec 08             	sub    $0x8,%esp
  801548:	57                   	push   %edi
  801549:	6a 25                	push   $0x25
  80154b:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  80154e:	83 c4 10             	add    $0x10,%esp
  801551:	eb 02                	jmp    801555 <vprintfmt+0x378>
  801553:	89 c6                	mov    %eax,%esi
  801555:	8d 46 ff             	lea    -0x1(%esi),%eax
  801558:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  80155c:	75 f5                	jne    801553 <vprintfmt+0x376>
  80155e:	e9 9e fc ff ff       	jmp    801201 <vprintfmt+0x24>
				/* do nothing */;
			break;
		}
	}
}
  801563:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801566:	5b                   	pop    %ebx
  801567:	5e                   	pop    %esi
  801568:	5f                   	pop    %edi
  801569:	c9                   	leave  
  80156a:	c3                   	ret    

0080156b <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80156b:	55                   	push   %ebp
  80156c:	89 e5                	mov    %esp,%ebp
  80156e:	83 ec 18             	sub    $0x18,%esp
  801571:	8b 45 08             	mov    0x8(%ebp),%eax
  801574:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  801577:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80157a:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80157e:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  801581:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  801588:	85 c0                	test   %eax,%eax
  80158a:	74 26                	je     8015b2 <vsnprintf+0x47>
  80158c:	85 d2                	test   %edx,%edx
  80158e:	7e 29                	jle    8015b9 <vsnprintf+0x4e>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  801590:	ff 75 14             	pushl  0x14(%ebp)
  801593:	ff 75 10             	pushl  0x10(%ebp)
  801596:	8d 45 ec             	lea    -0x14(%ebp),%eax
  801599:	50                   	push   %eax
  80159a:	68 a6 11 80 00       	push   $0x8011a6
  80159f:	e8 39 fc ff ff       	call   8011dd <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8015a4:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8015a7:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8015aa:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8015ad:	83 c4 10             	add    $0x10,%esp
  8015b0:	eb 0c                	jmp    8015be <vsnprintf+0x53>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8015b2:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8015b7:	eb 05                	jmp    8015be <vsnprintf+0x53>
  8015b9:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8015be:	c9                   	leave  
  8015bf:	c3                   	ret    

008015c0 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8015c0:	55                   	push   %ebp
  8015c1:	89 e5                	mov    %esp,%ebp
  8015c3:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8015c6:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8015c9:	50                   	push   %eax
  8015ca:	ff 75 10             	pushl  0x10(%ebp)
  8015cd:	ff 75 0c             	pushl  0xc(%ebp)
  8015d0:	ff 75 08             	pushl  0x8(%ebp)
  8015d3:	e8 93 ff ff ff       	call   80156b <vsnprintf>
	va_end(ap);

	return rc;
}
  8015d8:	c9                   	leave  
  8015d9:	c3                   	ret    
	...

008015dc <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8015dc:	55                   	push   %ebp
  8015dd:	89 e5                	mov    %esp,%ebp
  8015df:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8015e2:	80 3a 00             	cmpb   $0x0,(%edx)
  8015e5:	74 0e                	je     8015f5 <strlen+0x19>
  8015e7:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  8015ec:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8015ed:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8015f1:	75 f9                	jne    8015ec <strlen+0x10>
  8015f3:	eb 05                	jmp    8015fa <strlen+0x1e>
  8015f5:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  8015fa:	c9                   	leave  
  8015fb:	c3                   	ret    

008015fc <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8015fc:	55                   	push   %ebp
  8015fd:	89 e5                	mov    %esp,%ebp
  8015ff:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801602:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801605:	85 d2                	test   %edx,%edx
  801607:	74 17                	je     801620 <strnlen+0x24>
  801609:	80 39 00             	cmpb   $0x0,(%ecx)
  80160c:	74 19                	je     801627 <strnlen+0x2b>
  80160e:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  801613:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801614:	39 d0                	cmp    %edx,%eax
  801616:	74 14                	je     80162c <strnlen+0x30>
  801618:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  80161c:	75 f5                	jne    801613 <strnlen+0x17>
  80161e:	eb 0c                	jmp    80162c <strnlen+0x30>
  801620:	b8 00 00 00 00       	mov    $0x0,%eax
  801625:	eb 05                	jmp    80162c <strnlen+0x30>
  801627:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  80162c:	c9                   	leave  
  80162d:	c3                   	ret    

0080162e <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80162e:	55                   	push   %ebp
  80162f:	89 e5                	mov    %esp,%ebp
  801631:	53                   	push   %ebx
  801632:	8b 45 08             	mov    0x8(%ebp),%eax
  801635:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  801638:	ba 00 00 00 00       	mov    $0x0,%edx
  80163d:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  801640:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  801643:	42                   	inc    %edx
  801644:	84 c9                	test   %cl,%cl
  801646:	75 f5                	jne    80163d <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  801648:	5b                   	pop    %ebx
  801649:	c9                   	leave  
  80164a:	c3                   	ret    

0080164b <strcat>:

char *
strcat(char *dst, const char *src)
{
  80164b:	55                   	push   %ebp
  80164c:	89 e5                	mov    %esp,%ebp
  80164e:	53                   	push   %ebx
  80164f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  801652:	53                   	push   %ebx
  801653:	e8 84 ff ff ff       	call   8015dc <strlen>
  801658:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  80165b:	ff 75 0c             	pushl  0xc(%ebp)
  80165e:	8d 04 03             	lea    (%ebx,%eax,1),%eax
  801661:	50                   	push   %eax
  801662:	e8 c7 ff ff ff       	call   80162e <strcpy>
	return dst;
}
  801667:	89 d8                	mov    %ebx,%eax
  801669:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80166c:	c9                   	leave  
  80166d:	c3                   	ret    

0080166e <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80166e:	55                   	push   %ebp
  80166f:	89 e5                	mov    %esp,%ebp
  801671:	56                   	push   %esi
  801672:	53                   	push   %ebx
  801673:	8b 45 08             	mov    0x8(%ebp),%eax
  801676:	8b 55 0c             	mov    0xc(%ebp),%edx
  801679:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80167c:	85 f6                	test   %esi,%esi
  80167e:	74 15                	je     801695 <strncpy+0x27>
  801680:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
  801685:	8a 1a                	mov    (%edx),%bl
  801687:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80168a:	80 3a 01             	cmpb   $0x1,(%edx)
  80168d:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801690:	41                   	inc    %ecx
  801691:	39 ce                	cmp    %ecx,%esi
  801693:	77 f0                	ja     801685 <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  801695:	5b                   	pop    %ebx
  801696:	5e                   	pop    %esi
  801697:	c9                   	leave  
  801698:	c3                   	ret    

00801699 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  801699:	55                   	push   %ebp
  80169a:	89 e5                	mov    %esp,%ebp
  80169c:	57                   	push   %edi
  80169d:	56                   	push   %esi
  80169e:	53                   	push   %ebx
  80169f:	8b 7d 08             	mov    0x8(%ebp),%edi
  8016a2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8016a5:	8b 75 10             	mov    0x10(%ebp),%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8016a8:	85 f6                	test   %esi,%esi
  8016aa:	74 32                	je     8016de <strlcpy+0x45>
		while (--size > 0 && *src != '\0')
  8016ac:	83 fe 01             	cmp    $0x1,%esi
  8016af:	74 22                	je     8016d3 <strlcpy+0x3a>
  8016b1:	8a 0b                	mov    (%ebx),%cl
  8016b3:	84 c9                	test   %cl,%cl
  8016b5:	74 20                	je     8016d7 <strlcpy+0x3e>
  8016b7:	89 f8                	mov    %edi,%eax
  8016b9:	ba 00 00 00 00       	mov    $0x0,%edx
	}
	return ret;
}

size_t
strlcpy(char *dst, const char *src, size_t size)
  8016be:	83 ee 02             	sub    $0x2,%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8016c1:	88 08                	mov    %cl,(%eax)
  8016c3:	40                   	inc    %eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8016c4:	39 f2                	cmp    %esi,%edx
  8016c6:	74 11                	je     8016d9 <strlcpy+0x40>
  8016c8:	8a 4c 13 01          	mov    0x1(%ebx,%edx,1),%cl
  8016cc:	42                   	inc    %edx
  8016cd:	84 c9                	test   %cl,%cl
  8016cf:	75 f0                	jne    8016c1 <strlcpy+0x28>
  8016d1:	eb 06                	jmp    8016d9 <strlcpy+0x40>
  8016d3:	89 f8                	mov    %edi,%eax
  8016d5:	eb 02                	jmp    8016d9 <strlcpy+0x40>
  8016d7:	89 f8                	mov    %edi,%eax
			*dst++ = *src++;
		*dst = '\0';
  8016d9:	c6 00 00             	movb   $0x0,(%eax)
  8016dc:	eb 02                	jmp    8016e0 <strlcpy+0x47>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8016de:	89 f8                	mov    %edi,%eax
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
		*dst = '\0';
	}
	return dst - dst_in;
  8016e0:	29 f8                	sub    %edi,%eax
}
  8016e2:	5b                   	pop    %ebx
  8016e3:	5e                   	pop    %esi
  8016e4:	5f                   	pop    %edi
  8016e5:	c9                   	leave  
  8016e6:	c3                   	ret    

008016e7 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8016e7:	55                   	push   %ebp
  8016e8:	89 e5                	mov    %esp,%ebp
  8016ea:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8016ed:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8016f0:	8a 01                	mov    (%ecx),%al
  8016f2:	84 c0                	test   %al,%al
  8016f4:	74 10                	je     801706 <strcmp+0x1f>
  8016f6:	3a 02                	cmp    (%edx),%al
  8016f8:	75 0c                	jne    801706 <strcmp+0x1f>
		p++, q++;
  8016fa:	41                   	inc    %ecx
  8016fb:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8016fc:	8a 01                	mov    (%ecx),%al
  8016fe:	84 c0                	test   %al,%al
  801700:	74 04                	je     801706 <strcmp+0x1f>
  801702:	3a 02                	cmp    (%edx),%al
  801704:	74 f4                	je     8016fa <strcmp+0x13>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  801706:	0f b6 c0             	movzbl %al,%eax
  801709:	0f b6 12             	movzbl (%edx),%edx
  80170c:	29 d0                	sub    %edx,%eax
}
  80170e:	c9                   	leave  
  80170f:	c3                   	ret    

00801710 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  801710:	55                   	push   %ebp
  801711:	89 e5                	mov    %esp,%ebp
  801713:	53                   	push   %ebx
  801714:	8b 55 08             	mov    0x8(%ebp),%edx
  801717:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80171a:	8b 45 10             	mov    0x10(%ebp),%eax
	while (n > 0 && *p && *p == *q)
  80171d:	85 c0                	test   %eax,%eax
  80171f:	74 1b                	je     80173c <strncmp+0x2c>
  801721:	8a 1a                	mov    (%edx),%bl
  801723:	84 db                	test   %bl,%bl
  801725:	74 24                	je     80174b <strncmp+0x3b>
  801727:	3a 19                	cmp    (%ecx),%bl
  801729:	75 20                	jne    80174b <strncmp+0x3b>
  80172b:	48                   	dec    %eax
  80172c:	74 15                	je     801743 <strncmp+0x33>
		n--, p++, q++;
  80172e:	42                   	inc    %edx
  80172f:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  801730:	8a 1a                	mov    (%edx),%bl
  801732:	84 db                	test   %bl,%bl
  801734:	74 15                	je     80174b <strncmp+0x3b>
  801736:	3a 19                	cmp    (%ecx),%bl
  801738:	74 f1                	je     80172b <strncmp+0x1b>
  80173a:	eb 0f                	jmp    80174b <strncmp+0x3b>
		n--, p++, q++;
	if (n == 0)
		return 0;
  80173c:	b8 00 00 00 00       	mov    $0x0,%eax
  801741:	eb 05                	jmp    801748 <strncmp+0x38>
  801743:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  801748:	5b                   	pop    %ebx
  801749:	c9                   	leave  
  80174a:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80174b:	0f b6 02             	movzbl (%edx),%eax
  80174e:	0f b6 11             	movzbl (%ecx),%edx
  801751:	29 d0                	sub    %edx,%eax
  801753:	eb f3                	jmp    801748 <strncmp+0x38>

00801755 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  801755:	55                   	push   %ebp
  801756:	89 e5                	mov    %esp,%ebp
  801758:	8b 45 08             	mov    0x8(%ebp),%eax
  80175b:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  80175e:	8a 10                	mov    (%eax),%dl
  801760:	84 d2                	test   %dl,%dl
  801762:	74 18                	je     80177c <strchr+0x27>
		if (*s == c)
  801764:	38 ca                	cmp    %cl,%dl
  801766:	75 06                	jne    80176e <strchr+0x19>
  801768:	eb 17                	jmp    801781 <strchr+0x2c>
  80176a:	38 ca                	cmp    %cl,%dl
  80176c:	74 13                	je     801781 <strchr+0x2c>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  80176e:	40                   	inc    %eax
  80176f:	8a 10                	mov    (%eax),%dl
  801771:	84 d2                	test   %dl,%dl
  801773:	75 f5                	jne    80176a <strchr+0x15>
		if (*s == c)
			return (char *) s;
	return 0;
  801775:	b8 00 00 00 00       	mov    $0x0,%eax
  80177a:	eb 05                	jmp    801781 <strchr+0x2c>
  80177c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801781:	c9                   	leave  
  801782:	c3                   	ret    

00801783 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  801783:	55                   	push   %ebp
  801784:	89 e5                	mov    %esp,%ebp
  801786:	8b 45 08             	mov    0x8(%ebp),%eax
  801789:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  80178c:	8a 10                	mov    (%eax),%dl
  80178e:	84 d2                	test   %dl,%dl
  801790:	74 11                	je     8017a3 <strfind+0x20>
		if (*s == c)
  801792:	38 ca                	cmp    %cl,%dl
  801794:	75 06                	jne    80179c <strfind+0x19>
  801796:	eb 0b                	jmp    8017a3 <strfind+0x20>
  801798:	38 ca                	cmp    %cl,%dl
  80179a:	74 07                	je     8017a3 <strfind+0x20>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  80179c:	40                   	inc    %eax
  80179d:	8a 10                	mov    (%eax),%dl
  80179f:	84 d2                	test   %dl,%dl
  8017a1:	75 f5                	jne    801798 <strfind+0x15>
		if (*s == c)
			break;
	return (char *) s;
}
  8017a3:	c9                   	leave  
  8017a4:	c3                   	ret    

008017a5 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8017a5:	55                   	push   %ebp
  8017a6:	89 e5                	mov    %esp,%ebp
  8017a8:	57                   	push   %edi
  8017a9:	56                   	push   %esi
  8017aa:	53                   	push   %ebx
  8017ab:	8b 7d 08             	mov    0x8(%ebp),%edi
  8017ae:	8b 45 0c             	mov    0xc(%ebp),%eax
  8017b1:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8017b4:	85 c9                	test   %ecx,%ecx
  8017b6:	74 30                	je     8017e8 <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8017b8:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8017be:	75 25                	jne    8017e5 <memset+0x40>
  8017c0:	f6 c1 03             	test   $0x3,%cl
  8017c3:	75 20                	jne    8017e5 <memset+0x40>
		c &= 0xFF;
  8017c5:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8017c8:	89 d3                	mov    %edx,%ebx
  8017ca:	c1 e3 08             	shl    $0x8,%ebx
  8017cd:	89 d6                	mov    %edx,%esi
  8017cf:	c1 e6 18             	shl    $0x18,%esi
  8017d2:	89 d0                	mov    %edx,%eax
  8017d4:	c1 e0 10             	shl    $0x10,%eax
  8017d7:	09 f0                	or     %esi,%eax
  8017d9:	09 d0                	or     %edx,%eax
  8017db:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  8017dd:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  8017e0:	fc                   	cld    
  8017e1:	f3 ab                	rep stos %eax,%es:(%edi)
  8017e3:	eb 03                	jmp    8017e8 <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8017e5:	fc                   	cld    
  8017e6:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8017e8:	89 f8                	mov    %edi,%eax
  8017ea:	5b                   	pop    %ebx
  8017eb:	5e                   	pop    %esi
  8017ec:	5f                   	pop    %edi
  8017ed:	c9                   	leave  
  8017ee:	c3                   	ret    

008017ef <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8017ef:	55                   	push   %ebp
  8017f0:	89 e5                	mov    %esp,%ebp
  8017f2:	57                   	push   %edi
  8017f3:	56                   	push   %esi
  8017f4:	8b 45 08             	mov    0x8(%ebp),%eax
  8017f7:	8b 75 0c             	mov    0xc(%ebp),%esi
  8017fa:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8017fd:	39 c6                	cmp    %eax,%esi
  8017ff:	73 34                	jae    801835 <memmove+0x46>
  801801:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  801804:	39 d0                	cmp    %edx,%eax
  801806:	73 2d                	jae    801835 <memmove+0x46>
		s += n;
		d += n;
  801808:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80180b:	f6 c2 03             	test   $0x3,%dl
  80180e:	75 1b                	jne    80182b <memmove+0x3c>
  801810:	f7 c7 03 00 00 00    	test   $0x3,%edi
  801816:	75 13                	jne    80182b <memmove+0x3c>
  801818:	f6 c1 03             	test   $0x3,%cl
  80181b:	75 0e                	jne    80182b <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  80181d:	83 ef 04             	sub    $0x4,%edi
  801820:	8d 72 fc             	lea    -0x4(%edx),%esi
  801823:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  801826:	fd                   	std    
  801827:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801829:	eb 07                	jmp    801832 <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  80182b:	4f                   	dec    %edi
  80182c:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  80182f:	fd                   	std    
  801830:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  801832:	fc                   	cld    
  801833:	eb 20                	jmp    801855 <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801835:	f7 c6 03 00 00 00    	test   $0x3,%esi
  80183b:	75 13                	jne    801850 <memmove+0x61>
  80183d:	a8 03                	test   $0x3,%al
  80183f:	75 0f                	jne    801850 <memmove+0x61>
  801841:	f6 c1 03             	test   $0x3,%cl
  801844:	75 0a                	jne    801850 <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  801846:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  801849:	89 c7                	mov    %eax,%edi
  80184b:	fc                   	cld    
  80184c:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80184e:	eb 05                	jmp    801855 <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  801850:	89 c7                	mov    %eax,%edi
  801852:	fc                   	cld    
  801853:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  801855:	5e                   	pop    %esi
  801856:	5f                   	pop    %edi
  801857:	c9                   	leave  
  801858:	c3                   	ret    

00801859 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  801859:	55                   	push   %ebp
  80185a:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  80185c:	ff 75 10             	pushl  0x10(%ebp)
  80185f:	ff 75 0c             	pushl  0xc(%ebp)
  801862:	ff 75 08             	pushl  0x8(%ebp)
  801865:	e8 85 ff ff ff       	call   8017ef <memmove>
}
  80186a:	c9                   	leave  
  80186b:	c3                   	ret    

0080186c <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  80186c:	55                   	push   %ebp
  80186d:	89 e5                	mov    %esp,%ebp
  80186f:	57                   	push   %edi
  801870:	56                   	push   %esi
  801871:	53                   	push   %ebx
  801872:	8b 5d 08             	mov    0x8(%ebp),%ebx
  801875:	8b 75 0c             	mov    0xc(%ebp),%esi
  801878:	8b 7d 10             	mov    0x10(%ebp),%edi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  80187b:	85 ff                	test   %edi,%edi
  80187d:	74 32                	je     8018b1 <memcmp+0x45>
		if (*s1 != *s2)
  80187f:	8a 03                	mov    (%ebx),%al
  801881:	8a 0e                	mov    (%esi),%cl
  801883:	38 c8                	cmp    %cl,%al
  801885:	74 19                	je     8018a0 <memcmp+0x34>
  801887:	eb 0d                	jmp    801896 <memcmp+0x2a>
  801889:	8a 44 13 01          	mov    0x1(%ebx,%edx,1),%al
  80188d:	8a 4c 16 01          	mov    0x1(%esi,%edx,1),%cl
  801891:	42                   	inc    %edx
  801892:	38 c8                	cmp    %cl,%al
  801894:	74 10                	je     8018a6 <memcmp+0x3a>
			return (int) *s1 - (int) *s2;
  801896:	0f b6 c0             	movzbl %al,%eax
  801899:	0f b6 c9             	movzbl %cl,%ecx
  80189c:	29 c8                	sub    %ecx,%eax
  80189e:	eb 16                	jmp    8018b6 <memcmp+0x4a>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8018a0:	4f                   	dec    %edi
  8018a1:	ba 00 00 00 00       	mov    $0x0,%edx
  8018a6:	39 fa                	cmp    %edi,%edx
  8018a8:	75 df                	jne    801889 <memcmp+0x1d>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  8018aa:	b8 00 00 00 00       	mov    $0x0,%eax
  8018af:	eb 05                	jmp    8018b6 <memcmp+0x4a>
  8018b1:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8018b6:	5b                   	pop    %ebx
  8018b7:	5e                   	pop    %esi
  8018b8:	5f                   	pop    %edi
  8018b9:	c9                   	leave  
  8018ba:	c3                   	ret    

008018bb <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8018bb:	55                   	push   %ebp
  8018bc:	89 e5                	mov    %esp,%ebp
  8018be:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  8018c1:	89 c2                	mov    %eax,%edx
  8018c3:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  8018c6:	39 d0                	cmp    %edx,%eax
  8018c8:	73 12                	jae    8018dc <memfind+0x21>
		if (*(const unsigned char *) s == (unsigned char) c)
  8018ca:	8a 4d 0c             	mov    0xc(%ebp),%cl
  8018cd:	38 08                	cmp    %cl,(%eax)
  8018cf:	75 06                	jne    8018d7 <memfind+0x1c>
  8018d1:	eb 09                	jmp    8018dc <memfind+0x21>
  8018d3:	38 08                	cmp    %cl,(%eax)
  8018d5:	74 05                	je     8018dc <memfind+0x21>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8018d7:	40                   	inc    %eax
  8018d8:	39 c2                	cmp    %eax,%edx
  8018da:	77 f7                	ja     8018d3 <memfind+0x18>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  8018dc:	c9                   	leave  
  8018dd:	c3                   	ret    

008018de <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  8018de:	55                   	push   %ebp
  8018df:	89 e5                	mov    %esp,%ebp
  8018e1:	57                   	push   %edi
  8018e2:	56                   	push   %esi
  8018e3:	53                   	push   %ebx
  8018e4:	8b 55 08             	mov    0x8(%ebp),%edx
  8018e7:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8018ea:	eb 01                	jmp    8018ed <strtol+0xf>
		s++;
  8018ec:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8018ed:	8a 02                	mov    (%edx),%al
  8018ef:	3c 20                	cmp    $0x20,%al
  8018f1:	74 f9                	je     8018ec <strtol+0xe>
  8018f3:	3c 09                	cmp    $0x9,%al
  8018f5:	74 f5                	je     8018ec <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  8018f7:	3c 2b                	cmp    $0x2b,%al
  8018f9:	75 08                	jne    801903 <strtol+0x25>
		s++;
  8018fb:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  8018fc:	bf 00 00 00 00       	mov    $0x0,%edi
  801901:	eb 13                	jmp    801916 <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  801903:	3c 2d                	cmp    $0x2d,%al
  801905:	75 0a                	jne    801911 <strtol+0x33>
		s++, neg = 1;
  801907:	8d 52 01             	lea    0x1(%edx),%edx
  80190a:	bf 01 00 00 00       	mov    $0x1,%edi
  80190f:	eb 05                	jmp    801916 <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  801911:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801916:	85 db                	test   %ebx,%ebx
  801918:	74 05                	je     80191f <strtol+0x41>
  80191a:	83 fb 10             	cmp    $0x10,%ebx
  80191d:	75 28                	jne    801947 <strtol+0x69>
  80191f:	8a 02                	mov    (%edx),%al
  801921:	3c 30                	cmp    $0x30,%al
  801923:	75 10                	jne    801935 <strtol+0x57>
  801925:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  801929:	75 0a                	jne    801935 <strtol+0x57>
		s += 2, base = 16;
  80192b:	83 c2 02             	add    $0x2,%edx
  80192e:	bb 10 00 00 00       	mov    $0x10,%ebx
  801933:	eb 12                	jmp    801947 <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  801935:	85 db                	test   %ebx,%ebx
  801937:	75 0e                	jne    801947 <strtol+0x69>
  801939:	3c 30                	cmp    $0x30,%al
  80193b:	75 05                	jne    801942 <strtol+0x64>
		s++, base = 8;
  80193d:	42                   	inc    %edx
  80193e:	b3 08                	mov    $0x8,%bl
  801940:	eb 05                	jmp    801947 <strtol+0x69>
	else if (base == 0)
		base = 10;
  801942:	bb 0a 00 00 00       	mov    $0xa,%ebx
  801947:	b8 00 00 00 00       	mov    $0x0,%eax
  80194c:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  80194e:	8a 0a                	mov    (%edx),%cl
  801950:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  801953:	80 fb 09             	cmp    $0x9,%bl
  801956:	77 08                	ja     801960 <strtol+0x82>
			dig = *s - '0';
  801958:	0f be c9             	movsbl %cl,%ecx
  80195b:	83 e9 30             	sub    $0x30,%ecx
  80195e:	eb 1e                	jmp    80197e <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  801960:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  801963:	80 fb 19             	cmp    $0x19,%bl
  801966:	77 08                	ja     801970 <strtol+0x92>
			dig = *s - 'a' + 10;
  801968:	0f be c9             	movsbl %cl,%ecx
  80196b:	83 e9 57             	sub    $0x57,%ecx
  80196e:	eb 0e                	jmp    80197e <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  801970:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  801973:	80 fb 19             	cmp    $0x19,%bl
  801976:	77 13                	ja     80198b <strtol+0xad>
			dig = *s - 'A' + 10;
  801978:	0f be c9             	movsbl %cl,%ecx
  80197b:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  80197e:	39 f1                	cmp    %esi,%ecx
  801980:	7d 0d                	jge    80198f <strtol+0xb1>
			break;
		s++, val = (val * base) + dig;
  801982:	42                   	inc    %edx
  801983:	0f af c6             	imul   %esi,%eax
  801986:	8d 04 01             	lea    (%ecx,%eax,1),%eax
		// we don't properly detect overflow!
	}
  801989:	eb c3                	jmp    80194e <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  80198b:	89 c1                	mov    %eax,%ecx
  80198d:	eb 02                	jmp    801991 <strtol+0xb3>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  80198f:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  801991:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801995:	74 05                	je     80199c <strtol+0xbe>
		*endptr = (char *) s;
  801997:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80199a:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  80199c:	85 ff                	test   %edi,%edi
  80199e:	74 04                	je     8019a4 <strtol+0xc6>
  8019a0:	89 c8                	mov    %ecx,%eax
  8019a2:	f7 d8                	neg    %eax
}
  8019a4:	5b                   	pop    %ebx
  8019a5:	5e                   	pop    %esi
  8019a6:	5f                   	pop    %edi
  8019a7:	c9                   	leave  
  8019a8:	c3                   	ret    
  8019a9:	00 00                	add    %al,(%eax)
	...

008019ac <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8019ac:	55                   	push   %ebp
  8019ad:	89 e5                	mov    %esp,%ebp
  8019af:	56                   	push   %esi
  8019b0:	53                   	push   %ebx
  8019b1:	8b 75 08             	mov    0x8(%ebp),%esi
  8019b4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8019b7:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// cprintf("0x%x 0x%x 0x%x\n", (uint32_t)from_env_store, (uint32_t)pg, (uint32_t)perm_store);
	int r;
	if (pg != NULL) {
  8019ba:	85 c0                	test   %eax,%eax
  8019bc:	74 0e                	je     8019cc <ipc_recv+0x20>
		r = sys_ipc_recv(pg);
  8019be:	83 ec 0c             	sub    $0xc,%esp
  8019c1:	50                   	push   %eax
  8019c2:	e8 e0 e8 ff ff       	call   8002a7 <sys_ipc_recv>
  8019c7:	83 c4 10             	add    $0x10,%esp
  8019ca:	eb 10                	jmp    8019dc <ipc_recv+0x30>
	} else {
		r = sys_ipc_recv((void *)UTOP);
  8019cc:	83 ec 0c             	sub    $0xc,%esp
  8019cf:	68 00 00 c0 ee       	push   $0xeec00000
  8019d4:	e8 ce e8 ff ff       	call   8002a7 <sys_ipc_recv>
  8019d9:	83 c4 10             	add    $0x10,%esp
	}

	if (r == 0) {
  8019dc:	85 c0                	test   %eax,%eax
  8019de:	75 26                	jne    801a06 <ipc_recv+0x5a>
		if (from_env_store != NULL) *from_env_store = thisenv->env_ipc_from;
  8019e0:	85 f6                	test   %esi,%esi
  8019e2:	74 0a                	je     8019ee <ipc_recv+0x42>
  8019e4:	a1 04 40 80 00       	mov    0x804004,%eax
  8019e9:	8b 40 74             	mov    0x74(%eax),%eax
  8019ec:	89 06                	mov    %eax,(%esi)
		if (perm_store != NULL) *perm_store = thisenv->env_ipc_perm;
  8019ee:	85 db                	test   %ebx,%ebx
  8019f0:	74 0a                	je     8019fc <ipc_recv+0x50>
  8019f2:	a1 04 40 80 00       	mov    0x804004,%eax
  8019f7:	8b 40 78             	mov    0x78(%eax),%eax
  8019fa:	89 03                	mov    %eax,(%ebx)
		return thisenv->env_ipc_value;
  8019fc:	a1 04 40 80 00       	mov    0x804004,%eax
  801a01:	8b 40 70             	mov    0x70(%eax),%eax
  801a04:	eb 14                	jmp    801a1a <ipc_recv+0x6e>
	} else {
		// fails;
		if (from_env_store != NULL) *from_env_store = 0;
  801a06:	85 f6                	test   %esi,%esi
  801a08:	74 06                	je     801a10 <ipc_recv+0x64>
  801a0a:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		if (perm_store != NULL) *perm_store = 0;
  801a10:	85 db                	test   %ebx,%ebx
  801a12:	74 06                	je     801a1a <ipc_recv+0x6e>
  801a14:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
		return r;
	}
}
  801a1a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a1d:	5b                   	pop    %ebx
  801a1e:	5e                   	pop    %esi
  801a1f:	c9                   	leave  
  801a20:	c3                   	ret    

00801a21 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801a21:	55                   	push   %ebp
  801a22:	89 e5                	mov    %esp,%ebp
  801a24:	57                   	push   %edi
  801a25:	56                   	push   %esi
  801a26:	53                   	push   %ebx
  801a27:	83 ec 0c             	sub    $0xc,%esp
  801a2a:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801a2d:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801a30:	8b 75 14             	mov    0x14(%ebp),%esi
	// LAB 4: Your code here.
	// int sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
	int r;
	if (pg == NULL) pg = (void *)UTOP;
  801a33:	85 db                	test   %ebx,%ebx
  801a35:	75 25                	jne    801a5c <ipc_send+0x3b>
  801a37:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
  801a3c:	eb 1e                	jmp    801a5c <ipc_send+0x3b>
	
	while ((r = sys_ipc_try_send(to_env, val, pg, perm)) != 0) {
		if (r == -E_IPC_NOT_RECV) {
  801a3e:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801a41:	75 07                	jne    801a4a <ipc_send+0x29>
			// cprintf("Try Again and Again....\n");
			sys_yield();
  801a43:	e8 3d e7 ff ff       	call   800185 <sys_yield>
  801a48:	eb 12                	jmp    801a5c <ipc_send+0x3b>
		} else {
			panic("ipc_send error %e\n", r);
  801a4a:	50                   	push   %eax
  801a4b:	68 a0 21 80 00       	push   $0x8021a0
  801a50:	6a 43                	push   $0x43
  801a52:	68 b3 21 80 00       	push   $0x8021b3
  801a57:	e8 44 f5 ff ff       	call   800fa0 <_panic>
	// LAB 4: Your code here.
	// int sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
	int r;
	if (pg == NULL) pg = (void *)UTOP;
	
	while ((r = sys_ipc_try_send(to_env, val, pg, perm)) != 0) {
  801a5c:	56                   	push   %esi
  801a5d:	53                   	push   %ebx
  801a5e:	57                   	push   %edi
  801a5f:	ff 75 08             	pushl  0x8(%ebp)
  801a62:	e8 1b e8 ff ff       	call   800282 <sys_ipc_try_send>
  801a67:	83 c4 10             	add    $0x10,%esp
  801a6a:	85 c0                	test   %eax,%eax
  801a6c:	75 d0                	jne    801a3e <ipc_send+0x1d>
		} else {
			panic("ipc_send error %e\n", r);
		}
	}
	return;
}
  801a6e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801a71:	5b                   	pop    %ebx
  801a72:	5e                   	pop    %esi
  801a73:	5f                   	pop    %edi
  801a74:	c9                   	leave  
  801a75:	c3                   	ret    

00801a76 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801a76:	55                   	push   %ebp
  801a77:	89 e5                	mov    %esp,%ebp
  801a79:	53                   	push   %ebx
  801a7a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	for (i = 0; i < NENV; i++)
		if (envs[i].env_type == type)
  801a7d:	39 1d 50 00 c0 ee    	cmp    %ebx,0xeec00050
  801a83:	74 22                	je     801aa7 <ipc_find_env+0x31>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801a85:	b8 01 00 00 00       	mov    $0x1,%eax
		if (envs[i].env_type == type)
  801a8a:	8d 0c 85 00 00 00 00 	lea    0x0(,%eax,4),%ecx
  801a91:	89 c2                	mov    %eax,%edx
  801a93:	c1 e2 07             	shl    $0x7,%edx
  801a96:	29 ca                	sub    %ecx,%edx
  801a98:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801a9e:	8b 52 50             	mov    0x50(%edx),%edx
  801aa1:	39 da                	cmp    %ebx,%edx
  801aa3:	75 1d                	jne    801ac2 <ipc_find_env+0x4c>
  801aa5:	eb 05                	jmp    801aac <ipc_find_env+0x36>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801aa7:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
			return envs[i].env_id;
  801aac:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  801ab3:	c1 e0 07             	shl    $0x7,%eax
  801ab6:	29 d0                	sub    %edx,%eax
  801ab8:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  801abd:	8b 40 40             	mov    0x40(%eax),%eax
  801ac0:	eb 0c                	jmp    801ace <ipc_find_env+0x58>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801ac2:	40                   	inc    %eax
  801ac3:	3d 00 04 00 00       	cmp    $0x400,%eax
  801ac8:	75 c0                	jne    801a8a <ipc_find_env+0x14>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801aca:	66 b8 00 00          	mov    $0x0,%ax
}
  801ace:	5b                   	pop    %ebx
  801acf:	c9                   	leave  
  801ad0:	c3                   	ret    
  801ad1:	00 00                	add    %al,(%eax)
	...

00801ad4 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801ad4:	55                   	push   %ebp
  801ad5:	89 e5                	mov    %esp,%ebp
  801ad7:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801ada:	89 c2                	mov    %eax,%edx
  801adc:	c1 ea 16             	shr    $0x16,%edx
  801adf:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801ae6:	f6 c2 01             	test   $0x1,%dl
  801ae9:	74 1e                	je     801b09 <pageref+0x35>
		return 0;
	pte = uvpt[PGNUM(v)];
  801aeb:	c1 e8 0c             	shr    $0xc,%eax
  801aee:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  801af5:	a8 01                	test   $0x1,%al
  801af7:	74 17                	je     801b10 <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801af9:	c1 e8 0c             	shr    $0xc,%eax
  801afc:	66 8b 04 c5 04 00 00 	mov    -0x10fffffc(,%eax,8),%ax
  801b03:	ef 
  801b04:	0f b7 c0             	movzwl %ax,%eax
  801b07:	eb 0c                	jmp    801b15 <pageref+0x41>
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
		return 0;
  801b09:	b8 00 00 00 00       	mov    $0x0,%eax
  801b0e:	eb 05                	jmp    801b15 <pageref+0x41>
	pte = uvpt[PGNUM(v)];
	if (!(pte & PTE_P))
		return 0;
  801b10:	b8 00 00 00 00       	mov    $0x0,%eax
	return pages[PGNUM(pte)].pp_ref;
}
  801b15:	c9                   	leave  
  801b16:	c3                   	ret    
	...

00801b18 <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  801b18:	55                   	push   %ebp
  801b19:	89 e5                	mov    %esp,%ebp
  801b1b:	57                   	push   %edi
  801b1c:	56                   	push   %esi
  801b1d:	83 ec 10             	sub    $0x10,%esp
  801b20:	8b 7d 08             	mov    0x8(%ebp),%edi
  801b23:	8b 4d 10             	mov    0x10(%ebp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  801b26:	89 7d f0             	mov    %edi,-0x10(%ebp)
  801b29:	8b 75 0c             	mov    0xc(%ebp),%esi
  const DWunion dd = {.ll = d};
  801b2c:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  801b2f:	8b 45 14             	mov    0x14(%ebp),%eax
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  801b32:	85 c0                	test   %eax,%eax
  801b34:	75 2e                	jne    801b64 <__udivdi3+0x4c>
    {
      if (d0 > n1)
  801b36:	39 f1                	cmp    %esi,%ecx
  801b38:	77 5a                	ja     801b94 <__udivdi3+0x7c>
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  801b3a:	85 c9                	test   %ecx,%ecx
  801b3c:	75 0b                	jne    801b49 <__udivdi3+0x31>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  801b3e:	b8 01 00 00 00       	mov    $0x1,%eax
  801b43:	31 d2                	xor    %edx,%edx
  801b45:	f7 f1                	div    %ecx
  801b47:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  801b49:	31 d2                	xor    %edx,%edx
  801b4b:	89 f0                	mov    %esi,%eax
  801b4d:	f7 f1                	div    %ecx
  801b4f:	89 c6                	mov    %eax,%esi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801b51:	89 f8                	mov    %edi,%eax
  801b53:	f7 f1                	div    %ecx
  801b55:	89 c7                	mov    %eax,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  801b57:	89 f8                	mov    %edi,%eax
  801b59:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801b5b:	83 c4 10             	add    $0x10,%esp
  801b5e:	5e                   	pop    %esi
  801b5f:	5f                   	pop    %edi
  801b60:	c9                   	leave  
  801b61:	c3                   	ret    
  801b62:	66 90                	xchg   %ax,%ax
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  801b64:	39 f0                	cmp    %esi,%eax
  801b66:	77 1c                	ja     801b84 <__udivdi3+0x6c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  801b68:	0f bd f8             	bsr    %eax,%edi
	  if (bm == 0)
  801b6b:	83 f7 1f             	xor    $0x1f,%edi
  801b6e:	75 3c                	jne    801bac <__udivdi3+0x94>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  801b70:	39 f0                	cmp    %esi,%eax
  801b72:	0f 82 90 00 00 00    	jb     801c08 <__udivdi3+0xf0>
  801b78:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801b7b:	39 55 f4             	cmp    %edx,-0xc(%ebp)
  801b7e:	0f 86 84 00 00 00    	jbe    801c08 <__udivdi3+0xf0>
  801b84:	31 f6                	xor    %esi,%esi
  801b86:	31 ff                	xor    %edi,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  801b88:	89 f8                	mov    %edi,%eax
  801b8a:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801b8c:	83 c4 10             	add    $0x10,%esp
  801b8f:	5e                   	pop    %esi
  801b90:	5f                   	pop    %edi
  801b91:	c9                   	leave  
  801b92:	c3                   	ret    
  801b93:	90                   	nop
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801b94:	89 f2                	mov    %esi,%edx
  801b96:	89 f8                	mov    %edi,%eax
  801b98:	f7 f1                	div    %ecx
  801b9a:	89 c7                	mov    %eax,%edi
  801b9c:	31 f6                	xor    %esi,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  801b9e:	89 f8                	mov    %edi,%eax
  801ba0:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801ba2:	83 c4 10             	add    $0x10,%esp
  801ba5:	5e                   	pop    %esi
  801ba6:	5f                   	pop    %edi
  801ba7:	c9                   	leave  
  801ba8:	c3                   	ret    
  801ba9:	8d 76 00             	lea    0x0(%esi),%esi
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  801bac:	89 f9                	mov    %edi,%ecx
  801bae:	d3 e0                	shl    %cl,%eax
  801bb0:	89 45 e8             	mov    %eax,-0x18(%ebp)
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  801bb3:	b8 20 00 00 00       	mov    $0x20,%eax
  801bb8:	29 f8                	sub    %edi,%eax

	      d1 = (d1 << bm) | (d0 >> b);
  801bba:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801bbd:	88 c1                	mov    %al,%cl
  801bbf:	d3 ea                	shr    %cl,%edx
  801bc1:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  801bc4:	09 ca                	or     %ecx,%edx
  801bc6:	89 55 ec             	mov    %edx,-0x14(%ebp)
	      d0 = d0 << bm;
  801bc9:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801bcc:	89 f9                	mov    %edi,%ecx
  801bce:	d3 e2                	shl    %cl,%edx
  801bd0:	89 55 f4             	mov    %edx,-0xc(%ebp)
	      n2 = n1 >> b;
  801bd3:	89 f2                	mov    %esi,%edx
  801bd5:	88 c1                	mov    %al,%cl
  801bd7:	d3 ea                	shr    %cl,%edx
  801bd9:	89 55 e8             	mov    %edx,-0x18(%ebp)
	      n1 = (n1 << bm) | (n0 >> b);
  801bdc:	89 f2                	mov    %esi,%edx
  801bde:	89 f9                	mov    %edi,%ecx
  801be0:	d3 e2                	shl    %cl,%edx
  801be2:	8b 75 f0             	mov    -0x10(%ebp),%esi
  801be5:	88 c1                	mov    %al,%cl
  801be7:	d3 ee                	shr    %cl,%esi
  801be9:	09 d6                	or     %edx,%esi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  801beb:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  801bee:	89 f0                	mov    %esi,%eax
  801bf0:	89 ca                	mov    %ecx,%edx
  801bf2:	f7 75 ec             	divl   -0x14(%ebp)
  801bf5:	89 d1                	mov    %edx,%ecx
  801bf7:	89 c6                	mov    %eax,%esi
	      umul_ppmm (m1, m0, q0, d0);
  801bf9:	f7 65 f4             	mull   -0xc(%ebp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801bfc:	39 d1                	cmp    %edx,%ecx
  801bfe:	72 28                	jb     801c28 <__udivdi3+0x110>
  801c00:	74 1a                	je     801c1c <__udivdi3+0x104>
  801c02:	89 f7                	mov    %esi,%edi
  801c04:	31 f6                	xor    %esi,%esi
  801c06:	eb 80                	jmp    801b88 <__udivdi3+0x70>
	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  801c08:	31 f6                	xor    %esi,%esi
  801c0a:	bf 01 00 00 00       	mov    $0x1,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  801c0f:	89 f8                	mov    %edi,%eax
  801c11:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801c13:	83 c4 10             	add    $0x10,%esp
  801c16:	5e                   	pop    %esi
  801c17:	5f                   	pop    %edi
  801c18:	c9                   	leave  
  801c19:	c3                   	ret    
  801c1a:	66 90                	xchg   %ax,%ax

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  801c1c:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801c1f:	89 f9                	mov    %edi,%ecx
  801c21:	d3 e2                	shl    %cl,%edx

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801c23:	39 c2                	cmp    %eax,%edx
  801c25:	73 db                	jae    801c02 <__udivdi3+0xea>
  801c27:	90                   	nop
		{
		  q0--;
  801c28:	8d 7e ff             	lea    -0x1(%esi),%edi
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  801c2b:	31 f6                	xor    %esi,%esi
  801c2d:	e9 56 ff ff ff       	jmp    801b88 <__udivdi3+0x70>
	...

00801c34 <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  801c34:	55                   	push   %ebp
  801c35:	89 e5                	mov    %esp,%ebp
  801c37:	57                   	push   %edi
  801c38:	56                   	push   %esi
  801c39:	83 ec 20             	sub    $0x20,%esp
  801c3c:	8b 45 08             	mov    0x8(%ebp),%eax
  801c3f:	8b 4d 10             	mov    0x10(%ebp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  801c42:	89 45 e8             	mov    %eax,-0x18(%ebp)
  801c45:	8b 75 0c             	mov    0xc(%ebp),%esi
  const DWunion dd = {.ll = d};
  801c48:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  801c4b:	8b 7d 14             	mov    0x14(%ebp),%edi
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  801c4e:	89 45 f0             	mov    %eax,-0x10(%ebp)
  n1 = nn.s.high;
  801c51:	89 f2                	mov    %esi,%edx

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  801c53:	85 ff                	test   %edi,%edi
  801c55:	75 15                	jne    801c6c <__umoddi3+0x38>
    {
      if (d0 > n1)
  801c57:	39 f1                	cmp    %esi,%ecx
  801c59:	0f 86 99 00 00 00    	jbe    801cf8 <__umoddi3+0xc4>
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801c5f:	f7 f1                	div    %ecx

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
  801c61:	89 d0                	mov    %edx,%eax
  801c63:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  801c65:	83 c4 20             	add    $0x20,%esp
  801c68:	5e                   	pop    %esi
  801c69:	5f                   	pop    %edi
  801c6a:	c9                   	leave  
  801c6b:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  801c6c:	39 f7                	cmp    %esi,%edi
  801c6e:	0f 87 a4 00 00 00    	ja     801d18 <__umoddi3+0xe4>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  801c74:	0f bd c7             	bsr    %edi,%eax
	  if (bm == 0)
  801c77:	83 f0 1f             	xor    $0x1f,%eax
  801c7a:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801c7d:	0f 84 a1 00 00 00    	je     801d24 <__umoddi3+0xf0>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  801c83:	89 f8                	mov    %edi,%eax
  801c85:	8a 4d ec             	mov    -0x14(%ebp),%cl
  801c88:	d3 e0                	shl    %cl,%eax
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  801c8a:	bf 20 00 00 00       	mov    $0x20,%edi
  801c8f:	2b 7d ec             	sub    -0x14(%ebp),%edi

	      d1 = (d1 << bm) | (d0 >> b);
  801c92:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801c95:	89 f9                	mov    %edi,%ecx
  801c97:	d3 ea                	shr    %cl,%edx
  801c99:	09 c2                	or     %eax,%edx
  801c9b:	89 55 f0             	mov    %edx,-0x10(%ebp)
	      d0 = d0 << bm;
  801c9e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ca1:	8a 4d ec             	mov    -0x14(%ebp),%cl
  801ca4:	d3 e0                	shl    %cl,%eax
  801ca6:	89 45 f4             	mov    %eax,-0xc(%ebp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  801ca9:	89 f2                	mov    %esi,%edx
  801cab:	d3 e2                	shl    %cl,%edx
	      n0 = n0 << bm;
  801cad:	8b 45 e8             	mov    -0x18(%ebp),%eax
  801cb0:	d3 e0                	shl    %cl,%eax
  801cb2:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  801cb5:	8b 45 e8             	mov    -0x18(%ebp),%eax
  801cb8:	89 f9                	mov    %edi,%ecx
  801cba:	d3 e8                	shr    %cl,%eax
  801cbc:	09 d0                	or     %edx,%eax

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  801cbe:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  801cc0:	89 f2                	mov    %esi,%edx
  801cc2:	f7 75 f0             	divl   -0x10(%ebp)
  801cc5:	89 d6                	mov    %edx,%esi
	      umul_ppmm (m1, m0, q0, d0);
  801cc7:	f7 65 f4             	mull   -0xc(%ebp)
  801cca:	89 55 e8             	mov    %edx,-0x18(%ebp)
  801ccd:	89 c1                	mov    %eax,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801ccf:	39 d6                	cmp    %edx,%esi
  801cd1:	72 71                	jb     801d44 <__umoddi3+0x110>
  801cd3:	74 7f                	je     801d54 <__umoddi3+0x120>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  801cd5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801cd8:	29 c8                	sub    %ecx,%eax
  801cda:	19 d6                	sbb    %edx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
  801cdc:	8a 4d ec             	mov    -0x14(%ebp),%cl
  801cdf:	d3 e8                	shr    %cl,%eax
  801ce1:	89 f2                	mov    %esi,%edx
  801ce3:	89 f9                	mov    %edi,%ecx
  801ce5:	d3 e2                	shl    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
  801ce7:	09 d0                	or     %edx,%eax
  801ce9:	89 f2                	mov    %esi,%edx
  801ceb:	8a 4d ec             	mov    -0x14(%ebp),%cl
  801cee:	d3 ea                	shr    %cl,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  801cf0:	83 c4 20             	add    $0x20,%esp
  801cf3:	5e                   	pop    %esi
  801cf4:	5f                   	pop    %edi
  801cf5:	c9                   	leave  
  801cf6:	c3                   	ret    
  801cf7:	90                   	nop
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  801cf8:	85 c9                	test   %ecx,%ecx
  801cfa:	75 0b                	jne    801d07 <__umoddi3+0xd3>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  801cfc:	b8 01 00 00 00       	mov    $0x1,%eax
  801d01:	31 d2                	xor    %edx,%edx
  801d03:	f7 f1                	div    %ecx
  801d05:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  801d07:	89 f0                	mov    %esi,%eax
  801d09:	31 d2                	xor    %edx,%edx
  801d0b:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801d0d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801d10:	f7 f1                	div    %ecx
  801d12:	e9 4a ff ff ff       	jmp    801c61 <__umoddi3+0x2d>
  801d17:	90                   	nop
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
  801d18:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  801d1a:	83 c4 20             	add    $0x20,%esp
  801d1d:	5e                   	pop    %esi
  801d1e:	5f                   	pop    %edi
  801d1f:	c9                   	leave  
  801d20:	c3                   	ret    
  801d21:	8d 76 00             	lea    0x0(%esi),%esi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  801d24:	39 f7                	cmp    %esi,%edi
  801d26:	72 05                	jb     801d2d <__umoddi3+0xf9>
  801d28:	3b 4d f0             	cmp    -0x10(%ebp),%ecx
  801d2b:	77 0c                	ja     801d39 <__umoddi3+0x105>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  801d2d:	89 f2                	mov    %esi,%edx
  801d2f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801d32:	29 c8                	sub    %ecx,%eax
  801d34:	19 fa                	sbb    %edi,%edx
  801d36:	89 45 f0             	mov    %eax,-0x10(%ebp)

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
  801d39:	8b 45 f0             	mov    -0x10(%ebp),%eax
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  801d3c:	83 c4 20             	add    $0x20,%esp
  801d3f:	5e                   	pop    %esi
  801d40:	5f                   	pop    %edi
  801d41:	c9                   	leave  
  801d42:	c3                   	ret    
  801d43:	90                   	nop
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  801d44:	8b 55 e8             	mov    -0x18(%ebp),%edx
  801d47:	89 c1                	mov    %eax,%ecx
  801d49:	2b 4d f4             	sub    -0xc(%ebp),%ecx
  801d4c:	1b 55 f0             	sbb    -0x10(%ebp),%edx
  801d4f:	eb 84                	jmp    801cd5 <__umoddi3+0xa1>
  801d51:	8d 76 00             	lea    0x0(%esi),%esi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801d54:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  801d57:	72 eb                	jb     801d44 <__umoddi3+0x110>
  801d59:	89 f2                	mov    %esi,%edx
  801d5b:	e9 75 ff ff ff       	jmp    801cd5 <__umoddi3+0xa1>
