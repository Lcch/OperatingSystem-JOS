
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
  8000da:	68 ca 1d 80 00       	push   $0x801dca
  8000df:	6a 42                	push   $0x42
  8000e1:	68 e7 1d 80 00       	push   $0x801de7
  8000e6:	e8 d5 0e 00 00       	call   800fc0 <_panic>

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
  80040e:	8b 14 85 74 1e 80 00 	mov    0x801e74(,%eax,4),%edx
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
  800426:	68 f8 1d 80 00       	push   $0x801df8
  80042b:	e8 68 0c 00 00       	call   801098 <cprintf>
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
  800656:	68 39 1e 80 00       	push   $0x801e39
  80065b:	e8 38 0a 00 00       	call   801098 <cprintf>
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
  80072d:	68 55 1e 80 00       	push   $0x801e55
  800732:	e8 61 09 00 00       	call   801098 <cprintf>
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
  8007d8:	68 18 1e 80 00       	push   $0x801e18
  8007dd:	e8 b6 08 00 00       	call   801098 <cprintf>
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
  80088f:	e8 8b 01 00 00       	call   800a1f <open>
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
  8008db:	e8 e9 11 00 00       	call   801ac9 <ipc_find_env>
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
  8008f6:	e8 79 11 00 00       	call   801a74 <ipc_send>
	
	return ipc_recv(NULL, dstva, NULL);
  8008fb:	83 c4 0c             	add    $0xc,%esp
  8008fe:	6a 00                	push   $0x0
  800900:	56                   	push   %esi
  800901:	6a 00                	push   $0x0
  800903:	e8 c4 10 00 00       	call   8019cc <ipc_recv>
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
  800935:	78 39                	js     800970 <devfile_stat+0x61>
		return r;
	}
	cprintf("OVER\n");
  800937:	83 ec 0c             	sub    $0xc,%esp
  80093a:	68 84 1e 80 00       	push   $0x801e84
  80093f:	e8 54 07 00 00       	call   801098 <cprintf>
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  800944:	83 c4 08             	add    $0x8,%esp
  800947:	68 00 50 80 00       	push   $0x805000
  80094c:	53                   	push   %ebx
  80094d:	e8 fc 0c 00 00       	call   80164e <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  800952:	a1 80 50 80 00       	mov    0x805080,%eax
  800957:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  80095d:	a1 84 50 80 00       	mov    0x805084,%eax
  800962:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  800968:	83 c4 10             	add    $0x10,%esp
  80096b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800970:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800973:	c9                   	leave  
  800974:	c3                   	ret    

00800975 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  800975:	55                   	push   %ebp
  800976:	89 e5                	mov    %esp,%ebp
  800978:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  80097b:	8b 45 08             	mov    0x8(%ebp),%eax
  80097e:	8b 40 0c             	mov    0xc(%eax),%eax
  800981:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  800986:	ba 00 00 00 00       	mov    $0x0,%edx
  80098b:	b8 06 00 00 00       	mov    $0x6,%eax
  800990:	e8 2f ff ff ff       	call   8008c4 <fsipc>
}
  800995:	c9                   	leave  
  800996:	c3                   	ret    

00800997 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  800997:	55                   	push   %ebp
  800998:	89 e5                	mov    %esp,%ebp
  80099a:	56                   	push   %esi
  80099b:	53                   	push   %ebx
  80099c:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  80099f:	8b 45 08             	mov    0x8(%ebp),%eax
  8009a2:	8b 40 0c             	mov    0xc(%eax),%eax
  8009a5:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  8009aa:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8009b0:	ba 00 00 00 00       	mov    $0x0,%edx
  8009b5:	b8 03 00 00 00       	mov    $0x3,%eax
  8009ba:	e8 05 ff ff ff       	call   8008c4 <fsipc>
  8009bf:	89 c3                	mov    %eax,%ebx
  8009c1:	85 c0                	test   %eax,%eax
  8009c3:	78 51                	js     800a16 <devfile_read+0x7f>
		return r;
	assert(r <= n);
  8009c5:	39 c6                	cmp    %eax,%esi
  8009c7:	73 19                	jae    8009e2 <devfile_read+0x4b>
  8009c9:	68 8a 1e 80 00       	push   $0x801e8a
  8009ce:	68 91 1e 80 00       	push   $0x801e91
  8009d3:	68 80 00 00 00       	push   $0x80
  8009d8:	68 a6 1e 80 00       	push   $0x801ea6
  8009dd:	e8 de 05 00 00       	call   800fc0 <_panic>
	assert(r <= PGSIZE);
  8009e2:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8009e7:	7e 19                	jle    800a02 <devfile_read+0x6b>
  8009e9:	68 b1 1e 80 00       	push   $0x801eb1
  8009ee:	68 91 1e 80 00       	push   $0x801e91
  8009f3:	68 81 00 00 00       	push   $0x81
  8009f8:	68 a6 1e 80 00       	push   $0x801ea6
  8009fd:	e8 be 05 00 00       	call   800fc0 <_panic>
	memmove(buf, &fsipcbuf, r);
  800a02:	83 ec 04             	sub    $0x4,%esp
  800a05:	50                   	push   %eax
  800a06:	68 00 50 80 00       	push   $0x805000
  800a0b:	ff 75 0c             	pushl  0xc(%ebp)
  800a0e:	e8 fc 0d 00 00       	call   80180f <memmove>
	return r;
  800a13:	83 c4 10             	add    $0x10,%esp
}
  800a16:	89 d8                	mov    %ebx,%eax
  800a18:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800a1b:	5b                   	pop    %ebx
  800a1c:	5e                   	pop    %esi
  800a1d:	c9                   	leave  
  800a1e:	c3                   	ret    

00800a1f <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  800a1f:	55                   	push   %ebp
  800a20:	89 e5                	mov    %esp,%ebp
  800a22:	56                   	push   %esi
  800a23:	53                   	push   %ebx
  800a24:	83 ec 1c             	sub    $0x1c,%esp
  800a27:	8b 75 08             	mov    0x8(%ebp),%esi
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  800a2a:	56                   	push   %esi
  800a2b:	e8 cc 0b 00 00       	call   8015fc <strlen>
  800a30:	83 c4 10             	add    $0x10,%esp
  800a33:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  800a38:	7f 72                	jg     800aac <open+0x8d>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800a3a:	83 ec 0c             	sub    $0xc,%esp
  800a3d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800a40:	50                   	push   %eax
  800a41:	e8 ce f8 ff ff       	call   800314 <fd_alloc>
  800a46:	89 c3                	mov    %eax,%ebx
  800a48:	83 c4 10             	add    $0x10,%esp
  800a4b:	85 c0                	test   %eax,%eax
  800a4d:	78 62                	js     800ab1 <open+0x92>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  800a4f:	83 ec 08             	sub    $0x8,%esp
  800a52:	56                   	push   %esi
  800a53:	68 00 50 80 00       	push   $0x805000
  800a58:	e8 f1 0b 00 00       	call   80164e <strcpy>
	fsipcbuf.open.req_omode = mode;
  800a5d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a60:	a3 00 54 80 00       	mov    %eax,0x805400



	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  800a65:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800a68:	b8 01 00 00 00       	mov    $0x1,%eax
  800a6d:	e8 52 fe ff ff       	call   8008c4 <fsipc>
  800a72:	89 c3                	mov    %eax,%ebx
  800a74:	83 c4 10             	add    $0x10,%esp
  800a77:	85 c0                	test   %eax,%eax
  800a79:	79 12                	jns    800a8d <open+0x6e>
		fd_close(fd, 0);
  800a7b:	83 ec 08             	sub    $0x8,%esp
  800a7e:	6a 00                	push   $0x0
  800a80:	ff 75 f4             	pushl  -0xc(%ebp)
  800a83:	e8 bb f9 ff ff       	call   800443 <fd_close>
		return r;
  800a88:	83 c4 10             	add    $0x10,%esp
  800a8b:	eb 24                	jmp    800ab1 <open+0x92>
	}


	cprintf("OPEN\n");
  800a8d:	83 ec 0c             	sub    $0xc,%esp
  800a90:	68 bd 1e 80 00       	push   $0x801ebd
  800a95:	e8 fe 05 00 00       	call   801098 <cprintf>

	return fd2num(fd);
  800a9a:	83 c4 04             	add    $0x4,%esp
  800a9d:	ff 75 f4             	pushl  -0xc(%ebp)
  800aa0:	e8 47 f8 ff ff       	call   8002ec <fd2num>
  800aa5:	89 c3                	mov    %eax,%ebx
  800aa7:	83 c4 10             	add    $0x10,%esp
  800aaa:	eb 05                	jmp    800ab1 <open+0x92>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  800aac:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx


	cprintf("OPEN\n");

	return fd2num(fd);
}
  800ab1:	89 d8                	mov    %ebx,%eax
  800ab3:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800ab6:	5b                   	pop    %ebx
  800ab7:	5e                   	pop    %esi
  800ab8:	c9                   	leave  
  800ab9:	c3                   	ret    
	...

00800abc <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  800abc:	55                   	push   %ebp
  800abd:	89 e5                	mov    %esp,%ebp
  800abf:	56                   	push   %esi
  800ac0:	53                   	push   %ebx
  800ac1:	8b 75 0c             	mov    0xc(%ebp),%esi
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  800ac4:	83 ec 0c             	sub    $0xc,%esp
  800ac7:	ff 75 08             	pushl  0x8(%ebp)
  800aca:	e8 2d f8 ff ff       	call   8002fc <fd2data>
  800acf:	89 c3                	mov    %eax,%ebx
	strcpy(stat->st_name, "<pipe>");
  800ad1:	83 c4 08             	add    $0x8,%esp
  800ad4:	68 c3 1e 80 00       	push   $0x801ec3
  800ad9:	56                   	push   %esi
  800ada:	e8 6f 0b 00 00       	call   80164e <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  800adf:	8b 43 04             	mov    0x4(%ebx),%eax
  800ae2:	2b 03                	sub    (%ebx),%eax
  800ae4:	89 86 80 00 00 00    	mov    %eax,0x80(%esi)
	stat->st_isdir = 0;
  800aea:	c7 86 84 00 00 00 00 	movl   $0x0,0x84(%esi)
  800af1:	00 00 00 
	stat->st_dev = &devpipe;
  800af4:	c7 86 88 00 00 00 20 	movl   $0x803020,0x88(%esi)
  800afb:	30 80 00 
	return 0;
}
  800afe:	b8 00 00 00 00       	mov    $0x0,%eax
  800b03:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800b06:	5b                   	pop    %ebx
  800b07:	5e                   	pop    %esi
  800b08:	c9                   	leave  
  800b09:	c3                   	ret    

00800b0a <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  800b0a:	55                   	push   %ebp
  800b0b:	89 e5                	mov    %esp,%ebp
  800b0d:	53                   	push   %ebx
  800b0e:	83 ec 0c             	sub    $0xc,%esp
  800b11:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  800b14:	53                   	push   %ebx
  800b15:	6a 00                	push   $0x0
  800b17:	e8 da f6 ff ff       	call   8001f6 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  800b1c:	89 1c 24             	mov    %ebx,(%esp)
  800b1f:	e8 d8 f7 ff ff       	call   8002fc <fd2data>
  800b24:	83 c4 08             	add    $0x8,%esp
  800b27:	50                   	push   %eax
  800b28:	6a 00                	push   $0x0
  800b2a:	e8 c7 f6 ff ff       	call   8001f6 <sys_page_unmap>
}
  800b2f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800b32:	c9                   	leave  
  800b33:	c3                   	ret    

00800b34 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  800b34:	55                   	push   %ebp
  800b35:	89 e5                	mov    %esp,%ebp
  800b37:	57                   	push   %edi
  800b38:	56                   	push   %esi
  800b39:	53                   	push   %ebx
  800b3a:	83 ec 1c             	sub    $0x1c,%esp
  800b3d:	89 c7                	mov    %eax,%edi
  800b3f:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  800b42:	a1 04 40 80 00       	mov    0x804004,%eax
  800b47:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  800b4a:	83 ec 0c             	sub    $0xc,%esp
  800b4d:	57                   	push   %edi
  800b4e:	e8 d1 0f 00 00       	call   801b24 <pageref>
  800b53:	89 c6                	mov    %eax,%esi
  800b55:	83 c4 04             	add    $0x4,%esp
  800b58:	ff 75 e4             	pushl  -0x1c(%ebp)
  800b5b:	e8 c4 0f 00 00       	call   801b24 <pageref>
  800b60:	83 c4 10             	add    $0x10,%esp
  800b63:	39 c6                	cmp    %eax,%esi
  800b65:	0f 94 c0             	sete   %al
  800b68:	0f b6 c0             	movzbl %al,%eax
		nn = thisenv->env_runs;
  800b6b:	8b 15 04 40 80 00    	mov    0x804004,%edx
  800b71:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  800b74:	39 cb                	cmp    %ecx,%ebx
  800b76:	75 08                	jne    800b80 <_pipeisclosed+0x4c>
			return ret;
		if (n != nn && ret == 1)
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
	}
}
  800b78:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b7b:	5b                   	pop    %ebx
  800b7c:	5e                   	pop    %esi
  800b7d:	5f                   	pop    %edi
  800b7e:	c9                   	leave  
  800b7f:	c3                   	ret    
		n = thisenv->env_runs;
		ret = pageref(fd) == pageref(p);
		nn = thisenv->env_runs;
		if (n == nn)
			return ret;
		if (n != nn && ret == 1)
  800b80:	83 f8 01             	cmp    $0x1,%eax
  800b83:	75 bd                	jne    800b42 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  800b85:	8b 42 58             	mov    0x58(%edx),%eax
  800b88:	6a 01                	push   $0x1
  800b8a:	50                   	push   %eax
  800b8b:	53                   	push   %ebx
  800b8c:	68 ca 1e 80 00       	push   $0x801eca
  800b91:	e8 02 05 00 00       	call   801098 <cprintf>
  800b96:	83 c4 10             	add    $0x10,%esp
  800b99:	eb a7                	jmp    800b42 <_pipeisclosed+0xe>

00800b9b <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  800b9b:	55                   	push   %ebp
  800b9c:	89 e5                	mov    %esp,%ebp
  800b9e:	57                   	push   %edi
  800b9f:	56                   	push   %esi
  800ba0:	53                   	push   %ebx
  800ba1:	83 ec 28             	sub    $0x28,%esp
  800ba4:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  800ba7:	56                   	push   %esi
  800ba8:	e8 4f f7 ff ff       	call   8002fc <fd2data>
  800bad:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800baf:	83 c4 10             	add    $0x10,%esp
  800bb2:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800bb6:	75 4a                	jne    800c02 <devpipe_write+0x67>
  800bb8:	bf 00 00 00 00       	mov    $0x0,%edi
  800bbd:	eb 56                	jmp    800c15 <devpipe_write+0x7a>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  800bbf:	89 da                	mov    %ebx,%edx
  800bc1:	89 f0                	mov    %esi,%eax
  800bc3:	e8 6c ff ff ff       	call   800b34 <_pipeisclosed>
  800bc8:	85 c0                	test   %eax,%eax
  800bca:	75 4d                	jne    800c19 <devpipe_write+0x7e>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  800bcc:	e8 b4 f5 ff ff       	call   800185 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  800bd1:	8b 43 04             	mov    0x4(%ebx),%eax
  800bd4:	8b 13                	mov    (%ebx),%edx
  800bd6:	83 c2 20             	add    $0x20,%edx
  800bd9:	39 d0                	cmp    %edx,%eax
  800bdb:	73 e2                	jae    800bbf <devpipe_write+0x24>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  800bdd:	89 c2                	mov    %eax,%edx
  800bdf:	81 e2 1f 00 00 80    	and    $0x8000001f,%edx
  800be5:	79 05                	jns    800bec <devpipe_write+0x51>
  800be7:	4a                   	dec    %edx
  800be8:	83 ca e0             	or     $0xffffffe0,%edx
  800beb:	42                   	inc    %edx
  800bec:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bef:	8a 0c 39             	mov    (%ecx,%edi,1),%cl
  800bf2:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  800bf6:	40                   	inc    %eax
  800bf7:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800bfa:	47                   	inc    %edi
  800bfb:	39 7d 10             	cmp    %edi,0x10(%ebp)
  800bfe:	77 07                	ja     800c07 <devpipe_write+0x6c>
  800c00:	eb 13                	jmp    800c15 <devpipe_write+0x7a>
  800c02:	bf 00 00 00 00       	mov    $0x0,%edi
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  800c07:	8b 43 04             	mov    0x4(%ebx),%eax
  800c0a:	8b 13                	mov    (%ebx),%edx
  800c0c:	83 c2 20             	add    $0x20,%edx
  800c0f:	39 d0                	cmp    %edx,%eax
  800c11:	73 ac                	jae    800bbf <devpipe_write+0x24>
  800c13:	eb c8                	jmp    800bdd <devpipe_write+0x42>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  800c15:	89 f8                	mov    %edi,%eax
  800c17:	eb 05                	jmp    800c1e <devpipe_write+0x83>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  800c19:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  800c1e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c21:	5b                   	pop    %ebx
  800c22:	5e                   	pop    %esi
  800c23:	5f                   	pop    %edi
  800c24:	c9                   	leave  
  800c25:	c3                   	ret    

00800c26 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  800c26:	55                   	push   %ebp
  800c27:	89 e5                	mov    %esp,%ebp
  800c29:	57                   	push   %edi
  800c2a:	56                   	push   %esi
  800c2b:	53                   	push   %ebx
  800c2c:	83 ec 18             	sub    $0x18,%esp
  800c2f:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  800c32:	57                   	push   %edi
  800c33:	e8 c4 f6 ff ff       	call   8002fc <fd2data>
  800c38:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800c3a:	83 c4 10             	add    $0x10,%esp
  800c3d:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800c41:	75 44                	jne    800c87 <devpipe_read+0x61>
  800c43:	be 00 00 00 00       	mov    $0x0,%esi
  800c48:	eb 4f                	jmp    800c99 <devpipe_read+0x73>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
				return i;
  800c4a:	89 f0                	mov    %esi,%eax
  800c4c:	eb 54                	jmp    800ca2 <devpipe_read+0x7c>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  800c4e:	89 da                	mov    %ebx,%edx
  800c50:	89 f8                	mov    %edi,%eax
  800c52:	e8 dd fe ff ff       	call   800b34 <_pipeisclosed>
  800c57:	85 c0                	test   %eax,%eax
  800c59:	75 42                	jne    800c9d <devpipe_read+0x77>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  800c5b:	e8 25 f5 ff ff       	call   800185 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  800c60:	8b 03                	mov    (%ebx),%eax
  800c62:	3b 43 04             	cmp    0x4(%ebx),%eax
  800c65:	74 e7                	je     800c4e <devpipe_read+0x28>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  800c67:	25 1f 00 00 80       	and    $0x8000001f,%eax
  800c6c:	79 05                	jns    800c73 <devpipe_read+0x4d>
  800c6e:	48                   	dec    %eax
  800c6f:	83 c8 e0             	or     $0xffffffe0,%eax
  800c72:	40                   	inc    %eax
  800c73:	8a 44 03 08          	mov    0x8(%ebx,%eax,1),%al
  800c77:	8b 55 0c             	mov    0xc(%ebp),%edx
  800c7a:	88 04 32             	mov    %al,(%edx,%esi,1)
		p->p_rpos++;
  800c7d:	ff 03                	incl   (%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800c7f:	46                   	inc    %esi
  800c80:	39 75 10             	cmp    %esi,0x10(%ebp)
  800c83:	77 07                	ja     800c8c <devpipe_read+0x66>
  800c85:	eb 12                	jmp    800c99 <devpipe_read+0x73>
  800c87:	be 00 00 00 00       	mov    $0x0,%esi
		while (p->p_rpos == p->p_wpos) {
  800c8c:	8b 03                	mov    (%ebx),%eax
  800c8e:	3b 43 04             	cmp    0x4(%ebx),%eax
  800c91:	75 d4                	jne    800c67 <devpipe_read+0x41>
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  800c93:	85 f6                	test   %esi,%esi
  800c95:	75 b3                	jne    800c4a <devpipe_read+0x24>
  800c97:	eb b5                	jmp    800c4e <devpipe_read+0x28>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  800c99:	89 f0                	mov    %esi,%eax
  800c9b:	eb 05                	jmp    800ca2 <devpipe_read+0x7c>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  800c9d:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  800ca2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ca5:	5b                   	pop    %ebx
  800ca6:	5e                   	pop    %esi
  800ca7:	5f                   	pop    %edi
  800ca8:	c9                   	leave  
  800ca9:	c3                   	ret    

00800caa <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  800caa:	55                   	push   %ebp
  800cab:	89 e5                	mov    %esp,%ebp
  800cad:	57                   	push   %edi
  800cae:	56                   	push   %esi
  800caf:	53                   	push   %ebx
  800cb0:	83 ec 28             	sub    $0x28,%esp
  800cb3:	8b 7d 08             	mov    0x8(%ebp),%edi
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  800cb6:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800cb9:	50                   	push   %eax
  800cba:	e8 55 f6 ff ff       	call   800314 <fd_alloc>
  800cbf:	89 c3                	mov    %eax,%ebx
  800cc1:	83 c4 10             	add    $0x10,%esp
  800cc4:	85 c0                	test   %eax,%eax
  800cc6:	0f 88 24 01 00 00    	js     800df0 <pipe+0x146>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800ccc:	83 ec 04             	sub    $0x4,%esp
  800ccf:	68 07 04 00 00       	push   $0x407
  800cd4:	ff 75 e4             	pushl  -0x1c(%ebp)
  800cd7:	6a 00                	push   $0x0
  800cd9:	e8 ce f4 ff ff       	call   8001ac <sys_page_alloc>
  800cde:	89 c3                	mov    %eax,%ebx
  800ce0:	83 c4 10             	add    $0x10,%esp
  800ce3:	85 c0                	test   %eax,%eax
  800ce5:	0f 88 05 01 00 00    	js     800df0 <pipe+0x146>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  800ceb:	83 ec 0c             	sub    $0xc,%esp
  800cee:	8d 45 e0             	lea    -0x20(%ebp),%eax
  800cf1:	50                   	push   %eax
  800cf2:	e8 1d f6 ff ff       	call   800314 <fd_alloc>
  800cf7:	89 c3                	mov    %eax,%ebx
  800cf9:	83 c4 10             	add    $0x10,%esp
  800cfc:	85 c0                	test   %eax,%eax
  800cfe:	0f 88 dc 00 00 00    	js     800de0 <pipe+0x136>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800d04:	83 ec 04             	sub    $0x4,%esp
  800d07:	68 07 04 00 00       	push   $0x407
  800d0c:	ff 75 e0             	pushl  -0x20(%ebp)
  800d0f:	6a 00                	push   $0x0
  800d11:	e8 96 f4 ff ff       	call   8001ac <sys_page_alloc>
  800d16:	89 c3                	mov    %eax,%ebx
  800d18:	83 c4 10             	add    $0x10,%esp
  800d1b:	85 c0                	test   %eax,%eax
  800d1d:	0f 88 bd 00 00 00    	js     800de0 <pipe+0x136>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  800d23:	83 ec 0c             	sub    $0xc,%esp
  800d26:	ff 75 e4             	pushl  -0x1c(%ebp)
  800d29:	e8 ce f5 ff ff       	call   8002fc <fd2data>
  800d2e:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800d30:	83 c4 0c             	add    $0xc,%esp
  800d33:	68 07 04 00 00       	push   $0x407
  800d38:	50                   	push   %eax
  800d39:	6a 00                	push   $0x0
  800d3b:	e8 6c f4 ff ff       	call   8001ac <sys_page_alloc>
  800d40:	89 c3                	mov    %eax,%ebx
  800d42:	83 c4 10             	add    $0x10,%esp
  800d45:	85 c0                	test   %eax,%eax
  800d47:	0f 88 83 00 00 00    	js     800dd0 <pipe+0x126>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800d4d:	83 ec 0c             	sub    $0xc,%esp
  800d50:	ff 75 e0             	pushl  -0x20(%ebp)
  800d53:	e8 a4 f5 ff ff       	call   8002fc <fd2data>
  800d58:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  800d5f:	50                   	push   %eax
  800d60:	6a 00                	push   $0x0
  800d62:	56                   	push   %esi
  800d63:	6a 00                	push   $0x0
  800d65:	e8 66 f4 ff ff       	call   8001d0 <sys_page_map>
  800d6a:	89 c3                	mov    %eax,%ebx
  800d6c:	83 c4 20             	add    $0x20,%esp
  800d6f:	85 c0                	test   %eax,%eax
  800d71:	78 4f                	js     800dc2 <pipe+0x118>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  800d73:	8b 15 20 30 80 00    	mov    0x803020,%edx
  800d79:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800d7c:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  800d7e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800d81:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  800d88:	8b 15 20 30 80 00    	mov    0x803020,%edx
  800d8e:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800d91:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  800d93:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800d96:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  800d9d:	83 ec 0c             	sub    $0xc,%esp
  800da0:	ff 75 e4             	pushl  -0x1c(%ebp)
  800da3:	e8 44 f5 ff ff       	call   8002ec <fd2num>
  800da8:	89 07                	mov    %eax,(%edi)
	pfd[1] = fd2num(fd1);
  800daa:	83 c4 04             	add    $0x4,%esp
  800dad:	ff 75 e0             	pushl  -0x20(%ebp)
  800db0:	e8 37 f5 ff ff       	call   8002ec <fd2num>
  800db5:	89 47 04             	mov    %eax,0x4(%edi)
	return 0;
  800db8:	83 c4 10             	add    $0x10,%esp
  800dbb:	bb 00 00 00 00       	mov    $0x0,%ebx
  800dc0:	eb 2e                	jmp    800df0 <pipe+0x146>

    err3:
	sys_page_unmap(0, va);
  800dc2:	83 ec 08             	sub    $0x8,%esp
  800dc5:	56                   	push   %esi
  800dc6:	6a 00                	push   $0x0
  800dc8:	e8 29 f4 ff ff       	call   8001f6 <sys_page_unmap>
  800dcd:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  800dd0:	83 ec 08             	sub    $0x8,%esp
  800dd3:	ff 75 e0             	pushl  -0x20(%ebp)
  800dd6:	6a 00                	push   $0x0
  800dd8:	e8 19 f4 ff ff       	call   8001f6 <sys_page_unmap>
  800ddd:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  800de0:	83 ec 08             	sub    $0x8,%esp
  800de3:	ff 75 e4             	pushl  -0x1c(%ebp)
  800de6:	6a 00                	push   $0x0
  800de8:	e8 09 f4 ff ff       	call   8001f6 <sys_page_unmap>
  800ded:	83 c4 10             	add    $0x10,%esp
    err:
	return r;
}
  800df0:	89 d8                	mov    %ebx,%eax
  800df2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800df5:	5b                   	pop    %ebx
  800df6:	5e                   	pop    %esi
  800df7:	5f                   	pop    %edi
  800df8:	c9                   	leave  
  800df9:	c3                   	ret    

00800dfa <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  800dfa:	55                   	push   %ebp
  800dfb:	89 e5                	mov    %esp,%ebp
  800dfd:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800e00:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800e03:	50                   	push   %eax
  800e04:	ff 75 08             	pushl  0x8(%ebp)
  800e07:	e8 7b f5 ff ff       	call   800387 <fd_lookup>
  800e0c:	83 c4 10             	add    $0x10,%esp
  800e0f:	85 c0                	test   %eax,%eax
  800e11:	78 18                	js     800e2b <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  800e13:	83 ec 0c             	sub    $0xc,%esp
  800e16:	ff 75 f4             	pushl  -0xc(%ebp)
  800e19:	e8 de f4 ff ff       	call   8002fc <fd2data>
	return _pipeisclosed(fd, p);
  800e1e:	89 c2                	mov    %eax,%edx
  800e20:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800e23:	e8 0c fd ff ff       	call   800b34 <_pipeisclosed>
  800e28:	83 c4 10             	add    $0x10,%esp
}
  800e2b:	c9                   	leave  
  800e2c:	c3                   	ret    
  800e2d:	00 00                	add    %al,(%eax)
	...

00800e30 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  800e30:	55                   	push   %ebp
  800e31:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  800e33:	b8 00 00 00 00       	mov    $0x0,%eax
  800e38:	c9                   	leave  
  800e39:	c3                   	ret    

00800e3a <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  800e3a:	55                   	push   %ebp
  800e3b:	89 e5                	mov    %esp,%ebp
  800e3d:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  800e40:	68 e2 1e 80 00       	push   $0x801ee2
  800e45:	ff 75 0c             	pushl  0xc(%ebp)
  800e48:	e8 01 08 00 00       	call   80164e <strcpy>
	return 0;
}
  800e4d:	b8 00 00 00 00       	mov    $0x0,%eax
  800e52:	c9                   	leave  
  800e53:	c3                   	ret    

00800e54 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  800e54:	55                   	push   %ebp
  800e55:	89 e5                	mov    %esp,%ebp
  800e57:	57                   	push   %edi
  800e58:	56                   	push   %esi
  800e59:	53                   	push   %ebx
  800e5a:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800e60:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800e64:	74 45                	je     800eab <devcons_write+0x57>
  800e66:	b8 00 00 00 00       	mov    $0x0,%eax
  800e6b:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  800e70:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  800e76:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e79:	29 c3                	sub    %eax,%ebx
		if (m > sizeof(buf) - 1)
  800e7b:	83 fb 7f             	cmp    $0x7f,%ebx
  800e7e:	76 05                	jbe    800e85 <devcons_write+0x31>
			m = sizeof(buf) - 1;
  800e80:	bb 7f 00 00 00       	mov    $0x7f,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  800e85:	83 ec 04             	sub    $0x4,%esp
  800e88:	53                   	push   %ebx
  800e89:	03 45 0c             	add    0xc(%ebp),%eax
  800e8c:	50                   	push   %eax
  800e8d:	57                   	push   %edi
  800e8e:	e8 7c 09 00 00       	call   80180f <memmove>
		sys_cputs(buf, m);
  800e93:	83 c4 08             	add    $0x8,%esp
  800e96:	53                   	push   %ebx
  800e97:	57                   	push   %edi
  800e98:	e8 58 f2 ff ff       	call   8000f5 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800e9d:	01 de                	add    %ebx,%esi
  800e9f:	89 f0                	mov    %esi,%eax
  800ea1:	83 c4 10             	add    $0x10,%esp
  800ea4:	3b 75 10             	cmp    0x10(%ebp),%esi
  800ea7:	72 cd                	jb     800e76 <devcons_write+0x22>
  800ea9:	eb 05                	jmp    800eb0 <devcons_write+0x5c>
  800eab:	be 00 00 00 00       	mov    $0x0,%esi
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  800eb0:	89 f0                	mov    %esi,%eax
  800eb2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800eb5:	5b                   	pop    %ebx
  800eb6:	5e                   	pop    %esi
  800eb7:	5f                   	pop    %edi
  800eb8:	c9                   	leave  
  800eb9:	c3                   	ret    

00800eba <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  800eba:	55                   	push   %ebp
  800ebb:	89 e5                	mov    %esp,%ebp
  800ebd:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
  800ec0:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800ec4:	75 07                	jne    800ecd <devcons_read+0x13>
  800ec6:	eb 25                	jmp    800eed <devcons_read+0x33>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  800ec8:	e8 b8 f2 ff ff       	call   800185 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  800ecd:	e8 49 f2 ff ff       	call   80011b <sys_cgetc>
  800ed2:	85 c0                	test   %eax,%eax
  800ed4:	74 f2                	je     800ec8 <devcons_read+0xe>
  800ed6:	89 c2                	mov    %eax,%edx
		sys_yield();
	if (c < 0)
  800ed8:	85 c0                	test   %eax,%eax
  800eda:	78 1d                	js     800ef9 <devcons_read+0x3f>
		return c;
	if (c == 0x04)	// ctl-d is eof
  800edc:	83 f8 04             	cmp    $0x4,%eax
  800edf:	74 13                	je     800ef4 <devcons_read+0x3a>
		return 0;
	*(char*)vbuf = c;
  800ee1:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ee4:	88 10                	mov    %dl,(%eax)
	return 1;
  800ee6:	b8 01 00 00 00       	mov    $0x1,%eax
  800eeb:	eb 0c                	jmp    800ef9 <devcons_read+0x3f>
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
		return 0;
  800eed:	b8 00 00 00 00       	mov    $0x0,%eax
  800ef2:	eb 05                	jmp    800ef9 <devcons_read+0x3f>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  800ef4:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  800ef9:	c9                   	leave  
  800efa:	c3                   	ret    

00800efb <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  800efb:	55                   	push   %ebp
  800efc:	89 e5                	mov    %esp,%ebp
  800efe:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  800f01:	8b 45 08             	mov    0x8(%ebp),%eax
  800f04:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  800f07:	6a 01                	push   $0x1
  800f09:	8d 45 f7             	lea    -0x9(%ebp),%eax
  800f0c:	50                   	push   %eax
  800f0d:	e8 e3 f1 ff ff       	call   8000f5 <sys_cputs>
  800f12:	83 c4 10             	add    $0x10,%esp
}
  800f15:	c9                   	leave  
  800f16:	c3                   	ret    

00800f17 <getchar>:

int
getchar(void)
{
  800f17:	55                   	push   %ebp
  800f18:	89 e5                	mov    %esp,%ebp
  800f1a:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  800f1d:	6a 01                	push   $0x1
  800f1f:	8d 45 f7             	lea    -0x9(%ebp),%eax
  800f22:	50                   	push   %eax
  800f23:	6a 00                	push   $0x0
  800f25:	e8 de f6 ff ff       	call   800608 <read>
	if (r < 0)
  800f2a:	83 c4 10             	add    $0x10,%esp
  800f2d:	85 c0                	test   %eax,%eax
  800f2f:	78 0f                	js     800f40 <getchar+0x29>
		return r;
	if (r < 1)
  800f31:	85 c0                	test   %eax,%eax
  800f33:	7e 06                	jle    800f3b <getchar+0x24>
		return -E_EOF;
	return c;
  800f35:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  800f39:	eb 05                	jmp    800f40 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  800f3b:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  800f40:	c9                   	leave  
  800f41:	c3                   	ret    

00800f42 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  800f42:	55                   	push   %ebp
  800f43:	89 e5                	mov    %esp,%ebp
  800f45:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800f48:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800f4b:	50                   	push   %eax
  800f4c:	ff 75 08             	pushl  0x8(%ebp)
  800f4f:	e8 33 f4 ff ff       	call   800387 <fd_lookup>
  800f54:	83 c4 10             	add    $0x10,%esp
  800f57:	85 c0                	test   %eax,%eax
  800f59:	78 11                	js     800f6c <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  800f5b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800f5e:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  800f64:	39 10                	cmp    %edx,(%eax)
  800f66:	0f 94 c0             	sete   %al
  800f69:	0f b6 c0             	movzbl %al,%eax
}
  800f6c:	c9                   	leave  
  800f6d:	c3                   	ret    

00800f6e <opencons>:

int
opencons(void)
{
  800f6e:	55                   	push   %ebp
  800f6f:	89 e5                	mov    %esp,%ebp
  800f71:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  800f74:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800f77:	50                   	push   %eax
  800f78:	e8 97 f3 ff ff       	call   800314 <fd_alloc>
  800f7d:	83 c4 10             	add    $0x10,%esp
  800f80:	85 c0                	test   %eax,%eax
  800f82:	78 3a                	js     800fbe <opencons+0x50>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  800f84:	83 ec 04             	sub    $0x4,%esp
  800f87:	68 07 04 00 00       	push   $0x407
  800f8c:	ff 75 f4             	pushl  -0xc(%ebp)
  800f8f:	6a 00                	push   $0x0
  800f91:	e8 16 f2 ff ff       	call   8001ac <sys_page_alloc>
  800f96:	83 c4 10             	add    $0x10,%esp
  800f99:	85 c0                	test   %eax,%eax
  800f9b:	78 21                	js     800fbe <opencons+0x50>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  800f9d:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  800fa3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800fa6:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  800fa8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800fab:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  800fb2:	83 ec 0c             	sub    $0xc,%esp
  800fb5:	50                   	push   %eax
  800fb6:	e8 31 f3 ff ff       	call   8002ec <fd2num>
  800fbb:	83 c4 10             	add    $0x10,%esp
}
  800fbe:	c9                   	leave  
  800fbf:	c3                   	ret    

00800fc0 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800fc0:	55                   	push   %ebp
  800fc1:	89 e5                	mov    %esp,%ebp
  800fc3:	56                   	push   %esi
  800fc4:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800fc5:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800fc8:	8b 1d 00 30 80 00    	mov    0x803000,%ebx
  800fce:	e8 8e f1 ff ff       	call   800161 <sys_getenvid>
  800fd3:	83 ec 0c             	sub    $0xc,%esp
  800fd6:	ff 75 0c             	pushl  0xc(%ebp)
  800fd9:	ff 75 08             	pushl  0x8(%ebp)
  800fdc:	53                   	push   %ebx
  800fdd:	50                   	push   %eax
  800fde:	68 f0 1e 80 00       	push   $0x801ef0
  800fe3:	e8 b0 00 00 00       	call   801098 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800fe8:	83 c4 18             	add    $0x18,%esp
  800feb:	56                   	push   %esi
  800fec:	ff 75 10             	pushl  0x10(%ebp)
  800fef:	e8 53 00 00 00       	call   801047 <vcprintf>
	cprintf("\n");
  800ff4:	c7 04 24 c1 1e 80 00 	movl   $0x801ec1,(%esp)
  800ffb:	e8 98 00 00 00       	call   801098 <cprintf>
  801000:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801003:	cc                   	int3   
  801004:	eb fd                	jmp    801003 <_panic+0x43>
	...

00801008 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  801008:	55                   	push   %ebp
  801009:	89 e5                	mov    %esp,%ebp
  80100b:	53                   	push   %ebx
  80100c:	83 ec 04             	sub    $0x4,%esp
  80100f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  801012:	8b 03                	mov    (%ebx),%eax
  801014:	8b 55 08             	mov    0x8(%ebp),%edx
  801017:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  80101b:	40                   	inc    %eax
  80101c:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  80101e:	3d ff 00 00 00       	cmp    $0xff,%eax
  801023:	75 1a                	jne    80103f <putch+0x37>
		sys_cputs(b->buf, b->idx);
  801025:	83 ec 08             	sub    $0x8,%esp
  801028:	68 ff 00 00 00       	push   $0xff
  80102d:	8d 43 08             	lea    0x8(%ebx),%eax
  801030:	50                   	push   %eax
  801031:	e8 bf f0 ff ff       	call   8000f5 <sys_cputs>
		b->idx = 0;
  801036:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80103c:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  80103f:	ff 43 04             	incl   0x4(%ebx)
}
  801042:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801045:	c9                   	leave  
  801046:	c3                   	ret    

00801047 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  801047:	55                   	push   %ebp
  801048:	89 e5                	mov    %esp,%ebp
  80104a:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  801050:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  801057:	00 00 00 
	b.cnt = 0;
  80105a:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  801061:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  801064:	ff 75 0c             	pushl  0xc(%ebp)
  801067:	ff 75 08             	pushl  0x8(%ebp)
  80106a:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  801070:	50                   	push   %eax
  801071:	68 08 10 80 00       	push   $0x801008
  801076:	e8 82 01 00 00       	call   8011fd <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80107b:	83 c4 08             	add    $0x8,%esp
  80107e:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  801084:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80108a:	50                   	push   %eax
  80108b:	e8 65 f0 ff ff       	call   8000f5 <sys_cputs>

	return b.cnt;
}
  801090:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  801096:	c9                   	leave  
  801097:	c3                   	ret    

00801098 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  801098:	55                   	push   %ebp
  801099:	89 e5                	mov    %esp,%ebp
  80109b:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80109e:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8010a1:	50                   	push   %eax
  8010a2:	ff 75 08             	pushl  0x8(%ebp)
  8010a5:	e8 9d ff ff ff       	call   801047 <vcprintf>
	va_end(ap);

	return cnt;
}
  8010aa:	c9                   	leave  
  8010ab:	c3                   	ret    

008010ac <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8010ac:	55                   	push   %ebp
  8010ad:	89 e5                	mov    %esp,%ebp
  8010af:	57                   	push   %edi
  8010b0:	56                   	push   %esi
  8010b1:	53                   	push   %ebx
  8010b2:	83 ec 2c             	sub    $0x2c,%esp
  8010b5:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8010b8:	89 d6                	mov    %edx,%esi
  8010ba:	8b 45 08             	mov    0x8(%ebp),%eax
  8010bd:	8b 55 0c             	mov    0xc(%ebp),%edx
  8010c0:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8010c3:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8010c6:	8b 45 10             	mov    0x10(%ebp),%eax
  8010c9:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8010cc:	8b 7d 18             	mov    0x18(%ebp),%edi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8010cf:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8010d2:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  8010d9:	39 55 d4             	cmp    %edx,-0x2c(%ebp)
  8010dc:	72 0c                	jb     8010ea <printnum+0x3e>
  8010de:	3b 45 d8             	cmp    -0x28(%ebp),%eax
  8010e1:	76 07                	jbe    8010ea <printnum+0x3e>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8010e3:	4b                   	dec    %ebx
  8010e4:	85 db                	test   %ebx,%ebx
  8010e6:	7f 31                	jg     801119 <printnum+0x6d>
  8010e8:	eb 3f                	jmp    801129 <printnum+0x7d>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8010ea:	83 ec 0c             	sub    $0xc,%esp
  8010ed:	57                   	push   %edi
  8010ee:	4b                   	dec    %ebx
  8010ef:	53                   	push   %ebx
  8010f0:	50                   	push   %eax
  8010f1:	83 ec 08             	sub    $0x8,%esp
  8010f4:	ff 75 d4             	pushl  -0x2c(%ebp)
  8010f7:	ff 75 d0             	pushl  -0x30(%ebp)
  8010fa:	ff 75 dc             	pushl  -0x24(%ebp)
  8010fd:	ff 75 d8             	pushl  -0x28(%ebp)
  801100:	e8 63 0a 00 00       	call   801b68 <__udivdi3>
  801105:	83 c4 18             	add    $0x18,%esp
  801108:	52                   	push   %edx
  801109:	50                   	push   %eax
  80110a:	89 f2                	mov    %esi,%edx
  80110c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80110f:	e8 98 ff ff ff       	call   8010ac <printnum>
  801114:	83 c4 20             	add    $0x20,%esp
  801117:	eb 10                	jmp    801129 <printnum+0x7d>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  801119:	83 ec 08             	sub    $0x8,%esp
  80111c:	56                   	push   %esi
  80111d:	57                   	push   %edi
  80111e:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  801121:	4b                   	dec    %ebx
  801122:	83 c4 10             	add    $0x10,%esp
  801125:	85 db                	test   %ebx,%ebx
  801127:	7f f0                	jg     801119 <printnum+0x6d>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  801129:	83 ec 08             	sub    $0x8,%esp
  80112c:	56                   	push   %esi
  80112d:	83 ec 04             	sub    $0x4,%esp
  801130:	ff 75 d4             	pushl  -0x2c(%ebp)
  801133:	ff 75 d0             	pushl  -0x30(%ebp)
  801136:	ff 75 dc             	pushl  -0x24(%ebp)
  801139:	ff 75 d8             	pushl  -0x28(%ebp)
  80113c:	e8 43 0b 00 00       	call   801c84 <__umoddi3>
  801141:	83 c4 14             	add    $0x14,%esp
  801144:	0f be 80 13 1f 80 00 	movsbl 0x801f13(%eax),%eax
  80114b:	50                   	push   %eax
  80114c:	ff 55 e4             	call   *-0x1c(%ebp)
  80114f:	83 c4 10             	add    $0x10,%esp
}
  801152:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801155:	5b                   	pop    %ebx
  801156:	5e                   	pop    %esi
  801157:	5f                   	pop    %edi
  801158:	c9                   	leave  
  801159:	c3                   	ret    

0080115a <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80115a:	55                   	push   %ebp
  80115b:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80115d:	83 fa 01             	cmp    $0x1,%edx
  801160:	7e 0e                	jle    801170 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  801162:	8b 10                	mov    (%eax),%edx
  801164:	8d 4a 08             	lea    0x8(%edx),%ecx
  801167:	89 08                	mov    %ecx,(%eax)
  801169:	8b 02                	mov    (%edx),%eax
  80116b:	8b 52 04             	mov    0x4(%edx),%edx
  80116e:	eb 22                	jmp    801192 <getuint+0x38>
	else if (lflag)
  801170:	85 d2                	test   %edx,%edx
  801172:	74 10                	je     801184 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  801174:	8b 10                	mov    (%eax),%edx
  801176:	8d 4a 04             	lea    0x4(%edx),%ecx
  801179:	89 08                	mov    %ecx,(%eax)
  80117b:	8b 02                	mov    (%edx),%eax
  80117d:	ba 00 00 00 00       	mov    $0x0,%edx
  801182:	eb 0e                	jmp    801192 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  801184:	8b 10                	mov    (%eax),%edx
  801186:	8d 4a 04             	lea    0x4(%edx),%ecx
  801189:	89 08                	mov    %ecx,(%eax)
  80118b:	8b 02                	mov    (%edx),%eax
  80118d:	ba 00 00 00 00       	mov    $0x0,%edx
}
  801192:	c9                   	leave  
  801193:	c3                   	ret    

00801194 <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
  801194:	55                   	push   %ebp
  801195:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  801197:	83 fa 01             	cmp    $0x1,%edx
  80119a:	7e 0e                	jle    8011aa <getint+0x16>
		return va_arg(*ap, long long);
  80119c:	8b 10                	mov    (%eax),%edx
  80119e:	8d 4a 08             	lea    0x8(%edx),%ecx
  8011a1:	89 08                	mov    %ecx,(%eax)
  8011a3:	8b 02                	mov    (%edx),%eax
  8011a5:	8b 52 04             	mov    0x4(%edx),%edx
  8011a8:	eb 1a                	jmp    8011c4 <getint+0x30>
	else if (lflag)
  8011aa:	85 d2                	test   %edx,%edx
  8011ac:	74 0c                	je     8011ba <getint+0x26>
		return va_arg(*ap, long);
  8011ae:	8b 10                	mov    (%eax),%edx
  8011b0:	8d 4a 04             	lea    0x4(%edx),%ecx
  8011b3:	89 08                	mov    %ecx,(%eax)
  8011b5:	8b 02                	mov    (%edx),%eax
  8011b7:	99                   	cltd   
  8011b8:	eb 0a                	jmp    8011c4 <getint+0x30>
	else
		return va_arg(*ap, int);
  8011ba:	8b 10                	mov    (%eax),%edx
  8011bc:	8d 4a 04             	lea    0x4(%edx),%ecx
  8011bf:	89 08                	mov    %ecx,(%eax)
  8011c1:	8b 02                	mov    (%edx),%eax
  8011c3:	99                   	cltd   
}
  8011c4:	c9                   	leave  
  8011c5:	c3                   	ret    

008011c6 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8011c6:	55                   	push   %ebp
  8011c7:	89 e5                	mov    %esp,%ebp
  8011c9:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8011cc:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  8011cf:	8b 10                	mov    (%eax),%edx
  8011d1:	3b 50 04             	cmp    0x4(%eax),%edx
  8011d4:	73 08                	jae    8011de <sprintputch+0x18>
		*b->buf++ = ch;
  8011d6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8011d9:	88 0a                	mov    %cl,(%edx)
  8011db:	42                   	inc    %edx
  8011dc:	89 10                	mov    %edx,(%eax)
}
  8011de:	c9                   	leave  
  8011df:	c3                   	ret    

008011e0 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8011e0:	55                   	push   %ebp
  8011e1:	89 e5                	mov    %esp,%ebp
  8011e3:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8011e6:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8011e9:	50                   	push   %eax
  8011ea:	ff 75 10             	pushl  0x10(%ebp)
  8011ed:	ff 75 0c             	pushl  0xc(%ebp)
  8011f0:	ff 75 08             	pushl  0x8(%ebp)
  8011f3:	e8 05 00 00 00       	call   8011fd <vprintfmt>
	va_end(ap);
  8011f8:	83 c4 10             	add    $0x10,%esp
}
  8011fb:	c9                   	leave  
  8011fc:	c3                   	ret    

008011fd <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8011fd:	55                   	push   %ebp
  8011fe:	89 e5                	mov    %esp,%ebp
  801200:	57                   	push   %edi
  801201:	56                   	push   %esi
  801202:	53                   	push   %ebx
  801203:	83 ec 2c             	sub    $0x2c,%esp
  801206:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801209:	8b 75 10             	mov    0x10(%ebp),%esi
  80120c:	eb 13                	jmp    801221 <vprintfmt+0x24>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  80120e:	85 c0                	test   %eax,%eax
  801210:	0f 84 6d 03 00 00    	je     801583 <vprintfmt+0x386>
				return;
			putch(ch, putdat);
  801216:	83 ec 08             	sub    $0x8,%esp
  801219:	57                   	push   %edi
  80121a:	50                   	push   %eax
  80121b:	ff 55 08             	call   *0x8(%ebp)
  80121e:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  801221:	0f b6 06             	movzbl (%esi),%eax
  801224:	46                   	inc    %esi
  801225:	83 f8 25             	cmp    $0x25,%eax
  801228:	75 e4                	jne    80120e <vprintfmt+0x11>
  80122a:	c6 45 dc 20          	movb   $0x20,-0x24(%ebp)
  80122e:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  801235:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
  80123c:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  801243:	b9 00 00 00 00       	mov    $0x0,%ecx
  801248:	eb 28                	jmp    801272 <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80124a:	89 de                	mov    %ebx,%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  80124c:	c6 45 dc 2d          	movb   $0x2d,-0x24(%ebp)
  801250:	eb 20                	jmp    801272 <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801252:	89 de                	mov    %ebx,%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  801254:	c6 45 dc 30          	movb   $0x30,-0x24(%ebp)
  801258:	eb 18                	jmp    801272 <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80125a:	89 de                	mov    %ebx,%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  80125c:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  801263:	eb 0d                	jmp    801272 <vprintfmt+0x75>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  801265:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  801268:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80126b:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801272:	8a 06                	mov    (%esi),%al
  801274:	0f b6 d0             	movzbl %al,%edx
  801277:	8d 5e 01             	lea    0x1(%esi),%ebx
  80127a:	83 e8 23             	sub    $0x23,%eax
  80127d:	3c 55                	cmp    $0x55,%al
  80127f:	0f 87 e0 02 00 00    	ja     801565 <vprintfmt+0x368>
  801285:	0f b6 c0             	movzbl %al,%eax
  801288:	ff 24 85 60 20 80 00 	jmp    *0x802060(,%eax,4)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80128f:	83 ea 30             	sub    $0x30,%edx
  801292:	89 55 d4             	mov    %edx,-0x2c(%ebp)
				ch = *fmt;
  801295:	0f be 03             	movsbl (%ebx),%eax
				if (ch < '0' || ch > '9')
  801298:	8d 50 d0             	lea    -0x30(%eax),%edx
  80129b:	83 fa 09             	cmp    $0x9,%edx
  80129e:	77 44                	ja     8012e4 <vprintfmt+0xe7>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8012a0:	89 de                	mov    %ebx,%esi
  8012a2:	8b 55 d4             	mov    -0x2c(%ebp),%edx
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8012a5:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
  8012a6:	8d 14 92             	lea    (%edx,%edx,4),%edx
  8012a9:	8d 54 50 d0          	lea    -0x30(%eax,%edx,2),%edx
				ch = *fmt;
  8012ad:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  8012b0:	8d 58 d0             	lea    -0x30(%eax),%ebx
  8012b3:	83 fb 09             	cmp    $0x9,%ebx
  8012b6:	76 ed                	jbe    8012a5 <vprintfmt+0xa8>
  8012b8:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  8012bb:	eb 29                	jmp    8012e6 <vprintfmt+0xe9>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8012bd:	8b 45 14             	mov    0x14(%ebp),%eax
  8012c0:	8d 50 04             	lea    0x4(%eax),%edx
  8012c3:	89 55 14             	mov    %edx,0x14(%ebp)
  8012c6:	8b 00                	mov    (%eax),%eax
  8012c8:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8012cb:	89 de                	mov    %ebx,%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8012cd:	eb 17                	jmp    8012e6 <vprintfmt+0xe9>

		case '.':
			if (width < 0)
  8012cf:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8012d3:	78 85                	js     80125a <vprintfmt+0x5d>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8012d5:	89 de                	mov    %ebx,%esi
  8012d7:	eb 99                	jmp    801272 <vprintfmt+0x75>
  8012d9:	89 de                	mov    %ebx,%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8012db:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
			goto reswitch;
  8012e2:	eb 8e                	jmp    801272 <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8012e4:	89 de                	mov    %ebx,%esi
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  8012e6:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8012ea:	79 86                	jns    801272 <vprintfmt+0x75>
  8012ec:	e9 74 ff ff ff       	jmp    801265 <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8012f1:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8012f2:	89 de                	mov    %ebx,%esi
  8012f4:	e9 79 ff ff ff       	jmp    801272 <vprintfmt+0x75>
  8012f9:	89 5d d8             	mov    %ebx,-0x28(%ebp)
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8012fc:	8b 45 14             	mov    0x14(%ebp),%eax
  8012ff:	8d 50 04             	lea    0x4(%eax),%edx
  801302:	89 55 14             	mov    %edx,0x14(%ebp)
  801305:	83 ec 08             	sub    $0x8,%esp
  801308:	57                   	push   %edi
  801309:	ff 30                	pushl  (%eax)
  80130b:	ff 55 08             	call   *0x8(%ebp)
			break;
  80130e:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801311:	8b 75 d8             	mov    -0x28(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  801314:	e9 08 ff ff ff       	jmp    801221 <vprintfmt+0x24>
  801319:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// error message
		case 'e':
			err = va_arg(ap, int);
  80131c:	8b 45 14             	mov    0x14(%ebp),%eax
  80131f:	8d 50 04             	lea    0x4(%eax),%edx
  801322:	89 55 14             	mov    %edx,0x14(%ebp)
  801325:	8b 00                	mov    (%eax),%eax
  801327:	85 c0                	test   %eax,%eax
  801329:	79 02                	jns    80132d <vprintfmt+0x130>
  80132b:	f7 d8                	neg    %eax
  80132d:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80132f:	83 f8 0f             	cmp    $0xf,%eax
  801332:	7f 0b                	jg     80133f <vprintfmt+0x142>
  801334:	8b 04 85 c0 21 80 00 	mov    0x8021c0(,%eax,4),%eax
  80133b:	85 c0                	test   %eax,%eax
  80133d:	75 1a                	jne    801359 <vprintfmt+0x15c>
				printfmt(putch, putdat, "error %d", err);
  80133f:	52                   	push   %edx
  801340:	68 2b 1f 80 00       	push   $0x801f2b
  801345:	57                   	push   %edi
  801346:	ff 75 08             	pushl  0x8(%ebp)
  801349:	e8 92 fe ff ff       	call   8011e0 <printfmt>
  80134e:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801351:	8b 75 d8             	mov    -0x28(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  801354:	e9 c8 fe ff ff       	jmp    801221 <vprintfmt+0x24>
			else
				printfmt(putch, putdat, "%s", p);
  801359:	50                   	push   %eax
  80135a:	68 a3 1e 80 00       	push   $0x801ea3
  80135f:	57                   	push   %edi
  801360:	ff 75 08             	pushl  0x8(%ebp)
  801363:	e8 78 fe ff ff       	call   8011e0 <printfmt>
  801368:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80136b:	8b 75 d8             	mov    -0x28(%ebp),%esi
  80136e:	e9 ae fe ff ff       	jmp    801221 <vprintfmt+0x24>
  801373:	89 5d d8             	mov    %ebx,-0x28(%ebp)
  801376:	89 de                	mov    %ebx,%esi
  801378:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  80137b:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80137e:	8b 45 14             	mov    0x14(%ebp),%eax
  801381:	8d 50 04             	lea    0x4(%eax),%edx
  801384:	89 55 14             	mov    %edx,0x14(%ebp)
  801387:	8b 00                	mov    (%eax),%eax
  801389:	89 45 d0             	mov    %eax,-0x30(%ebp)
  80138c:	85 c0                	test   %eax,%eax
  80138e:	75 07                	jne    801397 <vprintfmt+0x19a>
				p = "(null)";
  801390:	c7 45 d0 24 1f 80 00 	movl   $0x801f24,-0x30(%ebp)
			if (width > 0 && padc != '-')
  801397:	85 db                	test   %ebx,%ebx
  801399:	7e 42                	jle    8013dd <vprintfmt+0x1e0>
  80139b:	80 7d dc 2d          	cmpb   $0x2d,-0x24(%ebp)
  80139f:	74 3c                	je     8013dd <vprintfmt+0x1e0>
				for (width -= strnlen(p, precision); width > 0; width--)
  8013a1:	83 ec 08             	sub    $0x8,%esp
  8013a4:	51                   	push   %ecx
  8013a5:	ff 75 d0             	pushl  -0x30(%ebp)
  8013a8:	e8 6f 02 00 00       	call   80161c <strnlen>
  8013ad:	29 c3                	sub    %eax,%ebx
  8013af:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8013b2:	83 c4 10             	add    $0x10,%esp
  8013b5:	85 db                	test   %ebx,%ebx
  8013b7:	7e 24                	jle    8013dd <vprintfmt+0x1e0>
					putch(padc, putdat);
  8013b9:	0f be 5d dc          	movsbl -0x24(%ebp),%ebx
  8013bd:	89 75 dc             	mov    %esi,-0x24(%ebp)
  8013c0:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  8013c3:	83 ec 08             	sub    $0x8,%esp
  8013c6:	57                   	push   %edi
  8013c7:	53                   	push   %ebx
  8013c8:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8013cb:	4e                   	dec    %esi
  8013cc:	83 c4 10             	add    $0x10,%esp
  8013cf:	85 f6                	test   %esi,%esi
  8013d1:	7f f0                	jg     8013c3 <vprintfmt+0x1c6>
  8013d3:	8b 75 dc             	mov    -0x24(%ebp),%esi
  8013d6:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8013dd:	8b 55 d0             	mov    -0x30(%ebp),%edx
  8013e0:	0f be 02             	movsbl (%edx),%eax
  8013e3:	85 c0                	test   %eax,%eax
  8013e5:	75 47                	jne    80142e <vprintfmt+0x231>
  8013e7:	eb 37                	jmp    801420 <vprintfmt+0x223>
				if (altflag && (ch < ' ' || ch > '~'))
  8013e9:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8013ed:	74 16                	je     801405 <vprintfmt+0x208>
  8013ef:	8d 50 e0             	lea    -0x20(%eax),%edx
  8013f2:	83 fa 5e             	cmp    $0x5e,%edx
  8013f5:	76 0e                	jbe    801405 <vprintfmt+0x208>
					putch('?', putdat);
  8013f7:	83 ec 08             	sub    $0x8,%esp
  8013fa:	57                   	push   %edi
  8013fb:	6a 3f                	push   $0x3f
  8013fd:	ff 55 08             	call   *0x8(%ebp)
  801400:	83 c4 10             	add    $0x10,%esp
  801403:	eb 0b                	jmp    801410 <vprintfmt+0x213>
				else
					putch(ch, putdat);
  801405:	83 ec 08             	sub    $0x8,%esp
  801408:	57                   	push   %edi
  801409:	50                   	push   %eax
  80140a:	ff 55 08             	call   *0x8(%ebp)
  80140d:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  801410:	ff 4d e4             	decl   -0x1c(%ebp)
  801413:	0f be 03             	movsbl (%ebx),%eax
  801416:	85 c0                	test   %eax,%eax
  801418:	74 03                	je     80141d <vprintfmt+0x220>
  80141a:	43                   	inc    %ebx
  80141b:	eb 1b                	jmp    801438 <vprintfmt+0x23b>
  80141d:	8b 75 dc             	mov    -0x24(%ebp),%esi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  801420:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  801424:	7f 1e                	jg     801444 <vprintfmt+0x247>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801426:	8b 75 d8             	mov    -0x28(%ebp),%esi
  801429:	e9 f3 fd ff ff       	jmp    801221 <vprintfmt+0x24>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80142e:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  801431:	43                   	inc    %ebx
  801432:	89 75 dc             	mov    %esi,-0x24(%ebp)
  801435:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  801438:	85 f6                	test   %esi,%esi
  80143a:	78 ad                	js     8013e9 <vprintfmt+0x1ec>
  80143c:	4e                   	dec    %esi
  80143d:	79 aa                	jns    8013e9 <vprintfmt+0x1ec>
  80143f:	8b 75 dc             	mov    -0x24(%ebp),%esi
  801442:	eb dc                	jmp    801420 <vprintfmt+0x223>
  801444:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  801447:	83 ec 08             	sub    $0x8,%esp
  80144a:	57                   	push   %edi
  80144b:	6a 20                	push   $0x20
  80144d:	ff 55 08             	call   *0x8(%ebp)
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  801450:	4b                   	dec    %ebx
  801451:	83 c4 10             	add    $0x10,%esp
  801454:	85 db                	test   %ebx,%ebx
  801456:	7f ef                	jg     801447 <vprintfmt+0x24a>
  801458:	e9 c4 fd ff ff       	jmp    801221 <vprintfmt+0x24>
  80145d:	89 5d d8             	mov    %ebx,-0x28(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  801460:	89 ca                	mov    %ecx,%edx
  801462:	8d 45 14             	lea    0x14(%ebp),%eax
  801465:	e8 2a fd ff ff       	call   801194 <getint>
  80146a:	89 c3                	mov    %eax,%ebx
  80146c:	89 d6                	mov    %edx,%esi
			if ((long long) num < 0) {
  80146e:	85 d2                	test   %edx,%edx
  801470:	78 0a                	js     80147c <vprintfmt+0x27f>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  801472:	b8 0a 00 00 00       	mov    $0xa,%eax
  801477:	e9 b0 00 00 00       	jmp    80152c <vprintfmt+0x32f>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  80147c:	83 ec 08             	sub    $0x8,%esp
  80147f:	57                   	push   %edi
  801480:	6a 2d                	push   $0x2d
  801482:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  801485:	f7 db                	neg    %ebx
  801487:	83 d6 00             	adc    $0x0,%esi
  80148a:	f7 de                	neg    %esi
  80148c:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  80148f:	b8 0a 00 00 00       	mov    $0xa,%eax
  801494:	e9 93 00 00 00       	jmp    80152c <vprintfmt+0x32f>
  801499:	89 5d d8             	mov    %ebx,-0x28(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  80149c:	89 ca                	mov    %ecx,%edx
  80149e:	8d 45 14             	lea    0x14(%ebp),%eax
  8014a1:	e8 b4 fc ff ff       	call   80115a <getuint>
  8014a6:	89 c3                	mov    %eax,%ebx
  8014a8:	89 d6                	mov    %edx,%esi
			base = 10;
  8014aa:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  8014af:	eb 7b                	jmp    80152c <vprintfmt+0x32f>
  8014b1:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// (unsigned) octal
		case 'o':
            // (MIT 6.828, lab1, Ex.8)  my code : 
            num = getint(&ap, lflag);
  8014b4:	89 ca                	mov    %ecx,%edx
  8014b6:	8d 45 14             	lea    0x14(%ebp),%eax
  8014b9:	e8 d6 fc ff ff       	call   801194 <getint>
  8014be:	89 c3                	mov    %eax,%ebx
  8014c0:	89 d6                	mov    %edx,%esi
            if ((long long) num < 0) {
  8014c2:	85 d2                	test   %edx,%edx
  8014c4:	78 07                	js     8014cd <vprintfmt+0x2d0>
                putch('-', putdat);
                num = -(long long) num;
            }
            base = 8;
  8014c6:	b8 08 00 00 00       	mov    $0x8,%eax
  8014cb:	eb 5f                	jmp    80152c <vprintfmt+0x32f>
		// (unsigned) octal
		case 'o':
            // (MIT 6.828, lab1, Ex.8)  my code : 
            num = getint(&ap, lflag);
            if ((long long) num < 0) {
                putch('-', putdat);
  8014cd:	83 ec 08             	sub    $0x8,%esp
  8014d0:	57                   	push   %edi
  8014d1:	6a 2d                	push   $0x2d
  8014d3:	ff 55 08             	call   *0x8(%ebp)
                num = -(long long) num;
  8014d6:	f7 db                	neg    %ebx
  8014d8:	83 d6 00             	adc    $0x0,%esi
  8014db:	f7 de                	neg    %esi
  8014dd:	83 c4 10             	add    $0x10,%esp
            }
            base = 8;
  8014e0:	b8 08 00 00 00       	mov    $0x8,%eax
  8014e5:	eb 45                	jmp    80152c <vprintfmt+0x32f>
  8014e7:	89 5d d8             	mov    %ebx,-0x28(%ebp)
            goto number;

        // pointer
		case 'p':
			putch('0', putdat);
  8014ea:	83 ec 08             	sub    $0x8,%esp
  8014ed:	57                   	push   %edi
  8014ee:	6a 30                	push   $0x30
  8014f0:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  8014f3:	83 c4 08             	add    $0x8,%esp
  8014f6:	57                   	push   %edi
  8014f7:	6a 78                	push   $0x78
  8014f9:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8014fc:	8b 45 14             	mov    0x14(%ebp),%eax
  8014ff:	8d 50 04             	lea    0x4(%eax),%edx
  801502:	89 55 14             	mov    %edx,0x14(%ebp)

        // pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  801505:	8b 18                	mov    (%eax),%ebx
  801507:	be 00 00 00 00       	mov    $0x0,%esi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  80150c:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  80150f:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  801514:	eb 16                	jmp    80152c <vprintfmt+0x32f>
  801516:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  801519:	89 ca                	mov    %ecx,%edx
  80151b:	8d 45 14             	lea    0x14(%ebp),%eax
  80151e:	e8 37 fc ff ff       	call   80115a <getuint>
  801523:	89 c3                	mov    %eax,%ebx
  801525:	89 d6                	mov    %edx,%esi
			base = 16;
  801527:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  80152c:	83 ec 0c             	sub    $0xc,%esp
  80152f:	0f be 55 dc          	movsbl -0x24(%ebp),%edx
  801533:	52                   	push   %edx
  801534:	ff 75 e4             	pushl  -0x1c(%ebp)
  801537:	50                   	push   %eax
  801538:	56                   	push   %esi
  801539:	53                   	push   %ebx
  80153a:	89 fa                	mov    %edi,%edx
  80153c:	8b 45 08             	mov    0x8(%ebp),%eax
  80153f:	e8 68 fb ff ff       	call   8010ac <printnum>
			break;
  801544:	83 c4 20             	add    $0x20,%esp
  801547:	8b 75 d8             	mov    -0x28(%ebp),%esi
  80154a:	e9 d2 fc ff ff       	jmp    801221 <vprintfmt+0x24>
  80154f:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  801552:	83 ec 08             	sub    $0x8,%esp
  801555:	57                   	push   %edi
  801556:	52                   	push   %edx
  801557:	ff 55 08             	call   *0x8(%ebp)
			break;
  80155a:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80155d:	8b 75 d8             	mov    -0x28(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  801560:	e9 bc fc ff ff       	jmp    801221 <vprintfmt+0x24>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  801565:	83 ec 08             	sub    $0x8,%esp
  801568:	57                   	push   %edi
  801569:	6a 25                	push   $0x25
  80156b:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  80156e:	83 c4 10             	add    $0x10,%esp
  801571:	eb 02                	jmp    801575 <vprintfmt+0x378>
  801573:	89 c6                	mov    %eax,%esi
  801575:	8d 46 ff             	lea    -0x1(%esi),%eax
  801578:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  80157c:	75 f5                	jne    801573 <vprintfmt+0x376>
  80157e:	e9 9e fc ff ff       	jmp    801221 <vprintfmt+0x24>
				/* do nothing */;
			break;
		}
	}
}
  801583:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801586:	5b                   	pop    %ebx
  801587:	5e                   	pop    %esi
  801588:	5f                   	pop    %edi
  801589:	c9                   	leave  
  80158a:	c3                   	ret    

0080158b <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80158b:	55                   	push   %ebp
  80158c:	89 e5                	mov    %esp,%ebp
  80158e:	83 ec 18             	sub    $0x18,%esp
  801591:	8b 45 08             	mov    0x8(%ebp),%eax
  801594:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  801597:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80159a:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80159e:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8015a1:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8015a8:	85 c0                	test   %eax,%eax
  8015aa:	74 26                	je     8015d2 <vsnprintf+0x47>
  8015ac:	85 d2                	test   %edx,%edx
  8015ae:	7e 29                	jle    8015d9 <vsnprintf+0x4e>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8015b0:	ff 75 14             	pushl  0x14(%ebp)
  8015b3:	ff 75 10             	pushl  0x10(%ebp)
  8015b6:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8015b9:	50                   	push   %eax
  8015ba:	68 c6 11 80 00       	push   $0x8011c6
  8015bf:	e8 39 fc ff ff       	call   8011fd <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8015c4:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8015c7:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8015ca:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8015cd:	83 c4 10             	add    $0x10,%esp
  8015d0:	eb 0c                	jmp    8015de <vsnprintf+0x53>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8015d2:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8015d7:	eb 05                	jmp    8015de <vsnprintf+0x53>
  8015d9:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8015de:	c9                   	leave  
  8015df:	c3                   	ret    

008015e0 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8015e0:	55                   	push   %ebp
  8015e1:	89 e5                	mov    %esp,%ebp
  8015e3:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8015e6:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8015e9:	50                   	push   %eax
  8015ea:	ff 75 10             	pushl  0x10(%ebp)
  8015ed:	ff 75 0c             	pushl  0xc(%ebp)
  8015f0:	ff 75 08             	pushl  0x8(%ebp)
  8015f3:	e8 93 ff ff ff       	call   80158b <vsnprintf>
	va_end(ap);

	return rc;
}
  8015f8:	c9                   	leave  
  8015f9:	c3                   	ret    
	...

008015fc <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8015fc:	55                   	push   %ebp
  8015fd:	89 e5                	mov    %esp,%ebp
  8015ff:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  801602:	80 3a 00             	cmpb   $0x0,(%edx)
  801605:	74 0e                	je     801615 <strlen+0x19>
  801607:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  80160c:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  80160d:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  801611:	75 f9                	jne    80160c <strlen+0x10>
  801613:	eb 05                	jmp    80161a <strlen+0x1e>
  801615:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  80161a:	c9                   	leave  
  80161b:	c3                   	ret    

0080161c <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80161c:	55                   	push   %ebp
  80161d:	89 e5                	mov    %esp,%ebp
  80161f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801622:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801625:	85 d2                	test   %edx,%edx
  801627:	74 17                	je     801640 <strnlen+0x24>
  801629:	80 39 00             	cmpb   $0x0,(%ecx)
  80162c:	74 19                	je     801647 <strnlen+0x2b>
  80162e:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  801633:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801634:	39 d0                	cmp    %edx,%eax
  801636:	74 14                	je     80164c <strnlen+0x30>
  801638:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  80163c:	75 f5                	jne    801633 <strnlen+0x17>
  80163e:	eb 0c                	jmp    80164c <strnlen+0x30>
  801640:	b8 00 00 00 00       	mov    $0x0,%eax
  801645:	eb 05                	jmp    80164c <strnlen+0x30>
  801647:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  80164c:	c9                   	leave  
  80164d:	c3                   	ret    

0080164e <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80164e:	55                   	push   %ebp
  80164f:	89 e5                	mov    %esp,%ebp
  801651:	53                   	push   %ebx
  801652:	8b 45 08             	mov    0x8(%ebp),%eax
  801655:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  801658:	ba 00 00 00 00       	mov    $0x0,%edx
  80165d:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  801660:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  801663:	42                   	inc    %edx
  801664:	84 c9                	test   %cl,%cl
  801666:	75 f5                	jne    80165d <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  801668:	5b                   	pop    %ebx
  801669:	c9                   	leave  
  80166a:	c3                   	ret    

0080166b <strcat>:

char *
strcat(char *dst, const char *src)
{
  80166b:	55                   	push   %ebp
  80166c:	89 e5                	mov    %esp,%ebp
  80166e:	53                   	push   %ebx
  80166f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  801672:	53                   	push   %ebx
  801673:	e8 84 ff ff ff       	call   8015fc <strlen>
  801678:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  80167b:	ff 75 0c             	pushl  0xc(%ebp)
  80167e:	8d 04 03             	lea    (%ebx,%eax,1),%eax
  801681:	50                   	push   %eax
  801682:	e8 c7 ff ff ff       	call   80164e <strcpy>
	return dst;
}
  801687:	89 d8                	mov    %ebx,%eax
  801689:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80168c:	c9                   	leave  
  80168d:	c3                   	ret    

0080168e <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80168e:	55                   	push   %ebp
  80168f:	89 e5                	mov    %esp,%ebp
  801691:	56                   	push   %esi
  801692:	53                   	push   %ebx
  801693:	8b 45 08             	mov    0x8(%ebp),%eax
  801696:	8b 55 0c             	mov    0xc(%ebp),%edx
  801699:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80169c:	85 f6                	test   %esi,%esi
  80169e:	74 15                	je     8016b5 <strncpy+0x27>
  8016a0:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
  8016a5:	8a 1a                	mov    (%edx),%bl
  8016a7:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8016aa:	80 3a 01             	cmpb   $0x1,(%edx)
  8016ad:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8016b0:	41                   	inc    %ecx
  8016b1:	39 ce                	cmp    %ecx,%esi
  8016b3:	77 f0                	ja     8016a5 <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8016b5:	5b                   	pop    %ebx
  8016b6:	5e                   	pop    %esi
  8016b7:	c9                   	leave  
  8016b8:	c3                   	ret    

008016b9 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8016b9:	55                   	push   %ebp
  8016ba:	89 e5                	mov    %esp,%ebp
  8016bc:	57                   	push   %edi
  8016bd:	56                   	push   %esi
  8016be:	53                   	push   %ebx
  8016bf:	8b 7d 08             	mov    0x8(%ebp),%edi
  8016c2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8016c5:	8b 75 10             	mov    0x10(%ebp),%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8016c8:	85 f6                	test   %esi,%esi
  8016ca:	74 32                	je     8016fe <strlcpy+0x45>
		while (--size > 0 && *src != '\0')
  8016cc:	83 fe 01             	cmp    $0x1,%esi
  8016cf:	74 22                	je     8016f3 <strlcpy+0x3a>
  8016d1:	8a 0b                	mov    (%ebx),%cl
  8016d3:	84 c9                	test   %cl,%cl
  8016d5:	74 20                	je     8016f7 <strlcpy+0x3e>
  8016d7:	89 f8                	mov    %edi,%eax
  8016d9:	ba 00 00 00 00       	mov    $0x0,%edx
	}
	return ret;
}

size_t
strlcpy(char *dst, const char *src, size_t size)
  8016de:	83 ee 02             	sub    $0x2,%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8016e1:	88 08                	mov    %cl,(%eax)
  8016e3:	40                   	inc    %eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8016e4:	39 f2                	cmp    %esi,%edx
  8016e6:	74 11                	je     8016f9 <strlcpy+0x40>
  8016e8:	8a 4c 13 01          	mov    0x1(%ebx,%edx,1),%cl
  8016ec:	42                   	inc    %edx
  8016ed:	84 c9                	test   %cl,%cl
  8016ef:	75 f0                	jne    8016e1 <strlcpy+0x28>
  8016f1:	eb 06                	jmp    8016f9 <strlcpy+0x40>
  8016f3:	89 f8                	mov    %edi,%eax
  8016f5:	eb 02                	jmp    8016f9 <strlcpy+0x40>
  8016f7:	89 f8                	mov    %edi,%eax
			*dst++ = *src++;
		*dst = '\0';
  8016f9:	c6 00 00             	movb   $0x0,(%eax)
  8016fc:	eb 02                	jmp    801700 <strlcpy+0x47>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8016fe:	89 f8                	mov    %edi,%eax
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
		*dst = '\0';
	}
	return dst - dst_in;
  801700:	29 f8                	sub    %edi,%eax
}
  801702:	5b                   	pop    %ebx
  801703:	5e                   	pop    %esi
  801704:	5f                   	pop    %edi
  801705:	c9                   	leave  
  801706:	c3                   	ret    

00801707 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  801707:	55                   	push   %ebp
  801708:	89 e5                	mov    %esp,%ebp
  80170a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80170d:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  801710:	8a 01                	mov    (%ecx),%al
  801712:	84 c0                	test   %al,%al
  801714:	74 10                	je     801726 <strcmp+0x1f>
  801716:	3a 02                	cmp    (%edx),%al
  801718:	75 0c                	jne    801726 <strcmp+0x1f>
		p++, q++;
  80171a:	41                   	inc    %ecx
  80171b:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  80171c:	8a 01                	mov    (%ecx),%al
  80171e:	84 c0                	test   %al,%al
  801720:	74 04                	je     801726 <strcmp+0x1f>
  801722:	3a 02                	cmp    (%edx),%al
  801724:	74 f4                	je     80171a <strcmp+0x13>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  801726:	0f b6 c0             	movzbl %al,%eax
  801729:	0f b6 12             	movzbl (%edx),%edx
  80172c:	29 d0                	sub    %edx,%eax
}
  80172e:	c9                   	leave  
  80172f:	c3                   	ret    

00801730 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  801730:	55                   	push   %ebp
  801731:	89 e5                	mov    %esp,%ebp
  801733:	53                   	push   %ebx
  801734:	8b 55 08             	mov    0x8(%ebp),%edx
  801737:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80173a:	8b 45 10             	mov    0x10(%ebp),%eax
	while (n > 0 && *p && *p == *q)
  80173d:	85 c0                	test   %eax,%eax
  80173f:	74 1b                	je     80175c <strncmp+0x2c>
  801741:	8a 1a                	mov    (%edx),%bl
  801743:	84 db                	test   %bl,%bl
  801745:	74 24                	je     80176b <strncmp+0x3b>
  801747:	3a 19                	cmp    (%ecx),%bl
  801749:	75 20                	jne    80176b <strncmp+0x3b>
  80174b:	48                   	dec    %eax
  80174c:	74 15                	je     801763 <strncmp+0x33>
		n--, p++, q++;
  80174e:	42                   	inc    %edx
  80174f:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  801750:	8a 1a                	mov    (%edx),%bl
  801752:	84 db                	test   %bl,%bl
  801754:	74 15                	je     80176b <strncmp+0x3b>
  801756:	3a 19                	cmp    (%ecx),%bl
  801758:	74 f1                	je     80174b <strncmp+0x1b>
  80175a:	eb 0f                	jmp    80176b <strncmp+0x3b>
		n--, p++, q++;
	if (n == 0)
		return 0;
  80175c:	b8 00 00 00 00       	mov    $0x0,%eax
  801761:	eb 05                	jmp    801768 <strncmp+0x38>
  801763:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  801768:	5b                   	pop    %ebx
  801769:	c9                   	leave  
  80176a:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80176b:	0f b6 02             	movzbl (%edx),%eax
  80176e:	0f b6 11             	movzbl (%ecx),%edx
  801771:	29 d0                	sub    %edx,%eax
  801773:	eb f3                	jmp    801768 <strncmp+0x38>

00801775 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  801775:	55                   	push   %ebp
  801776:	89 e5                	mov    %esp,%ebp
  801778:	8b 45 08             	mov    0x8(%ebp),%eax
  80177b:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  80177e:	8a 10                	mov    (%eax),%dl
  801780:	84 d2                	test   %dl,%dl
  801782:	74 18                	je     80179c <strchr+0x27>
		if (*s == c)
  801784:	38 ca                	cmp    %cl,%dl
  801786:	75 06                	jne    80178e <strchr+0x19>
  801788:	eb 17                	jmp    8017a1 <strchr+0x2c>
  80178a:	38 ca                	cmp    %cl,%dl
  80178c:	74 13                	je     8017a1 <strchr+0x2c>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  80178e:	40                   	inc    %eax
  80178f:	8a 10                	mov    (%eax),%dl
  801791:	84 d2                	test   %dl,%dl
  801793:	75 f5                	jne    80178a <strchr+0x15>
		if (*s == c)
			return (char *) s;
	return 0;
  801795:	b8 00 00 00 00       	mov    $0x0,%eax
  80179a:	eb 05                	jmp    8017a1 <strchr+0x2c>
  80179c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8017a1:	c9                   	leave  
  8017a2:	c3                   	ret    

008017a3 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8017a3:	55                   	push   %ebp
  8017a4:	89 e5                	mov    %esp,%ebp
  8017a6:	8b 45 08             	mov    0x8(%ebp),%eax
  8017a9:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  8017ac:	8a 10                	mov    (%eax),%dl
  8017ae:	84 d2                	test   %dl,%dl
  8017b0:	74 11                	je     8017c3 <strfind+0x20>
		if (*s == c)
  8017b2:	38 ca                	cmp    %cl,%dl
  8017b4:	75 06                	jne    8017bc <strfind+0x19>
  8017b6:	eb 0b                	jmp    8017c3 <strfind+0x20>
  8017b8:	38 ca                	cmp    %cl,%dl
  8017ba:	74 07                	je     8017c3 <strfind+0x20>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  8017bc:	40                   	inc    %eax
  8017bd:	8a 10                	mov    (%eax),%dl
  8017bf:	84 d2                	test   %dl,%dl
  8017c1:	75 f5                	jne    8017b8 <strfind+0x15>
		if (*s == c)
			break;
	return (char *) s;
}
  8017c3:	c9                   	leave  
  8017c4:	c3                   	ret    

008017c5 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8017c5:	55                   	push   %ebp
  8017c6:	89 e5                	mov    %esp,%ebp
  8017c8:	57                   	push   %edi
  8017c9:	56                   	push   %esi
  8017ca:	53                   	push   %ebx
  8017cb:	8b 7d 08             	mov    0x8(%ebp),%edi
  8017ce:	8b 45 0c             	mov    0xc(%ebp),%eax
  8017d1:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8017d4:	85 c9                	test   %ecx,%ecx
  8017d6:	74 30                	je     801808 <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8017d8:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8017de:	75 25                	jne    801805 <memset+0x40>
  8017e0:	f6 c1 03             	test   $0x3,%cl
  8017e3:	75 20                	jne    801805 <memset+0x40>
		c &= 0xFF;
  8017e5:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8017e8:	89 d3                	mov    %edx,%ebx
  8017ea:	c1 e3 08             	shl    $0x8,%ebx
  8017ed:	89 d6                	mov    %edx,%esi
  8017ef:	c1 e6 18             	shl    $0x18,%esi
  8017f2:	89 d0                	mov    %edx,%eax
  8017f4:	c1 e0 10             	shl    $0x10,%eax
  8017f7:	09 f0                	or     %esi,%eax
  8017f9:	09 d0                	or     %edx,%eax
  8017fb:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  8017fd:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  801800:	fc                   	cld    
  801801:	f3 ab                	rep stos %eax,%es:(%edi)
  801803:	eb 03                	jmp    801808 <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  801805:	fc                   	cld    
  801806:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  801808:	89 f8                	mov    %edi,%eax
  80180a:	5b                   	pop    %ebx
  80180b:	5e                   	pop    %esi
  80180c:	5f                   	pop    %edi
  80180d:	c9                   	leave  
  80180e:	c3                   	ret    

0080180f <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  80180f:	55                   	push   %ebp
  801810:	89 e5                	mov    %esp,%ebp
  801812:	57                   	push   %edi
  801813:	56                   	push   %esi
  801814:	8b 45 08             	mov    0x8(%ebp),%eax
  801817:	8b 75 0c             	mov    0xc(%ebp),%esi
  80181a:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  80181d:	39 c6                	cmp    %eax,%esi
  80181f:	73 34                	jae    801855 <memmove+0x46>
  801821:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  801824:	39 d0                	cmp    %edx,%eax
  801826:	73 2d                	jae    801855 <memmove+0x46>
		s += n;
		d += n;
  801828:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80182b:	f6 c2 03             	test   $0x3,%dl
  80182e:	75 1b                	jne    80184b <memmove+0x3c>
  801830:	f7 c7 03 00 00 00    	test   $0x3,%edi
  801836:	75 13                	jne    80184b <memmove+0x3c>
  801838:	f6 c1 03             	test   $0x3,%cl
  80183b:	75 0e                	jne    80184b <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  80183d:	83 ef 04             	sub    $0x4,%edi
  801840:	8d 72 fc             	lea    -0x4(%edx),%esi
  801843:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  801846:	fd                   	std    
  801847:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801849:	eb 07                	jmp    801852 <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  80184b:	4f                   	dec    %edi
  80184c:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  80184f:	fd                   	std    
  801850:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  801852:	fc                   	cld    
  801853:	eb 20                	jmp    801875 <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801855:	f7 c6 03 00 00 00    	test   $0x3,%esi
  80185b:	75 13                	jne    801870 <memmove+0x61>
  80185d:	a8 03                	test   $0x3,%al
  80185f:	75 0f                	jne    801870 <memmove+0x61>
  801861:	f6 c1 03             	test   $0x3,%cl
  801864:	75 0a                	jne    801870 <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  801866:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  801869:	89 c7                	mov    %eax,%edi
  80186b:	fc                   	cld    
  80186c:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80186e:	eb 05                	jmp    801875 <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  801870:	89 c7                	mov    %eax,%edi
  801872:	fc                   	cld    
  801873:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  801875:	5e                   	pop    %esi
  801876:	5f                   	pop    %edi
  801877:	c9                   	leave  
  801878:	c3                   	ret    

00801879 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  801879:	55                   	push   %ebp
  80187a:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  80187c:	ff 75 10             	pushl  0x10(%ebp)
  80187f:	ff 75 0c             	pushl  0xc(%ebp)
  801882:	ff 75 08             	pushl  0x8(%ebp)
  801885:	e8 85 ff ff ff       	call   80180f <memmove>
}
  80188a:	c9                   	leave  
  80188b:	c3                   	ret    

0080188c <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  80188c:	55                   	push   %ebp
  80188d:	89 e5                	mov    %esp,%ebp
  80188f:	57                   	push   %edi
  801890:	56                   	push   %esi
  801891:	53                   	push   %ebx
  801892:	8b 5d 08             	mov    0x8(%ebp),%ebx
  801895:	8b 75 0c             	mov    0xc(%ebp),%esi
  801898:	8b 7d 10             	mov    0x10(%ebp),%edi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  80189b:	85 ff                	test   %edi,%edi
  80189d:	74 32                	je     8018d1 <memcmp+0x45>
		if (*s1 != *s2)
  80189f:	8a 03                	mov    (%ebx),%al
  8018a1:	8a 0e                	mov    (%esi),%cl
  8018a3:	38 c8                	cmp    %cl,%al
  8018a5:	74 19                	je     8018c0 <memcmp+0x34>
  8018a7:	eb 0d                	jmp    8018b6 <memcmp+0x2a>
  8018a9:	8a 44 13 01          	mov    0x1(%ebx,%edx,1),%al
  8018ad:	8a 4c 16 01          	mov    0x1(%esi,%edx,1),%cl
  8018b1:	42                   	inc    %edx
  8018b2:	38 c8                	cmp    %cl,%al
  8018b4:	74 10                	je     8018c6 <memcmp+0x3a>
			return (int) *s1 - (int) *s2;
  8018b6:	0f b6 c0             	movzbl %al,%eax
  8018b9:	0f b6 c9             	movzbl %cl,%ecx
  8018bc:	29 c8                	sub    %ecx,%eax
  8018be:	eb 16                	jmp    8018d6 <memcmp+0x4a>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8018c0:	4f                   	dec    %edi
  8018c1:	ba 00 00 00 00       	mov    $0x0,%edx
  8018c6:	39 fa                	cmp    %edi,%edx
  8018c8:	75 df                	jne    8018a9 <memcmp+0x1d>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  8018ca:	b8 00 00 00 00       	mov    $0x0,%eax
  8018cf:	eb 05                	jmp    8018d6 <memcmp+0x4a>
  8018d1:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8018d6:	5b                   	pop    %ebx
  8018d7:	5e                   	pop    %esi
  8018d8:	5f                   	pop    %edi
  8018d9:	c9                   	leave  
  8018da:	c3                   	ret    

008018db <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8018db:	55                   	push   %ebp
  8018dc:	89 e5                	mov    %esp,%ebp
  8018de:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  8018e1:	89 c2                	mov    %eax,%edx
  8018e3:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  8018e6:	39 d0                	cmp    %edx,%eax
  8018e8:	73 12                	jae    8018fc <memfind+0x21>
		if (*(const unsigned char *) s == (unsigned char) c)
  8018ea:	8a 4d 0c             	mov    0xc(%ebp),%cl
  8018ed:	38 08                	cmp    %cl,(%eax)
  8018ef:	75 06                	jne    8018f7 <memfind+0x1c>
  8018f1:	eb 09                	jmp    8018fc <memfind+0x21>
  8018f3:	38 08                	cmp    %cl,(%eax)
  8018f5:	74 05                	je     8018fc <memfind+0x21>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8018f7:	40                   	inc    %eax
  8018f8:	39 c2                	cmp    %eax,%edx
  8018fa:	77 f7                	ja     8018f3 <memfind+0x18>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  8018fc:	c9                   	leave  
  8018fd:	c3                   	ret    

008018fe <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  8018fe:	55                   	push   %ebp
  8018ff:	89 e5                	mov    %esp,%ebp
  801901:	57                   	push   %edi
  801902:	56                   	push   %esi
  801903:	53                   	push   %ebx
  801904:	8b 55 08             	mov    0x8(%ebp),%edx
  801907:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  80190a:	eb 01                	jmp    80190d <strtol+0xf>
		s++;
  80190c:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  80190d:	8a 02                	mov    (%edx),%al
  80190f:	3c 20                	cmp    $0x20,%al
  801911:	74 f9                	je     80190c <strtol+0xe>
  801913:	3c 09                	cmp    $0x9,%al
  801915:	74 f5                	je     80190c <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  801917:	3c 2b                	cmp    $0x2b,%al
  801919:	75 08                	jne    801923 <strtol+0x25>
		s++;
  80191b:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  80191c:	bf 00 00 00 00       	mov    $0x0,%edi
  801921:	eb 13                	jmp    801936 <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  801923:	3c 2d                	cmp    $0x2d,%al
  801925:	75 0a                	jne    801931 <strtol+0x33>
		s++, neg = 1;
  801927:	8d 52 01             	lea    0x1(%edx),%edx
  80192a:	bf 01 00 00 00       	mov    $0x1,%edi
  80192f:	eb 05                	jmp    801936 <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  801931:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801936:	85 db                	test   %ebx,%ebx
  801938:	74 05                	je     80193f <strtol+0x41>
  80193a:	83 fb 10             	cmp    $0x10,%ebx
  80193d:	75 28                	jne    801967 <strtol+0x69>
  80193f:	8a 02                	mov    (%edx),%al
  801941:	3c 30                	cmp    $0x30,%al
  801943:	75 10                	jne    801955 <strtol+0x57>
  801945:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  801949:	75 0a                	jne    801955 <strtol+0x57>
		s += 2, base = 16;
  80194b:	83 c2 02             	add    $0x2,%edx
  80194e:	bb 10 00 00 00       	mov    $0x10,%ebx
  801953:	eb 12                	jmp    801967 <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  801955:	85 db                	test   %ebx,%ebx
  801957:	75 0e                	jne    801967 <strtol+0x69>
  801959:	3c 30                	cmp    $0x30,%al
  80195b:	75 05                	jne    801962 <strtol+0x64>
		s++, base = 8;
  80195d:	42                   	inc    %edx
  80195e:	b3 08                	mov    $0x8,%bl
  801960:	eb 05                	jmp    801967 <strtol+0x69>
	else if (base == 0)
		base = 10;
  801962:	bb 0a 00 00 00       	mov    $0xa,%ebx
  801967:	b8 00 00 00 00       	mov    $0x0,%eax
  80196c:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  80196e:	8a 0a                	mov    (%edx),%cl
  801970:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  801973:	80 fb 09             	cmp    $0x9,%bl
  801976:	77 08                	ja     801980 <strtol+0x82>
			dig = *s - '0';
  801978:	0f be c9             	movsbl %cl,%ecx
  80197b:	83 e9 30             	sub    $0x30,%ecx
  80197e:	eb 1e                	jmp    80199e <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  801980:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  801983:	80 fb 19             	cmp    $0x19,%bl
  801986:	77 08                	ja     801990 <strtol+0x92>
			dig = *s - 'a' + 10;
  801988:	0f be c9             	movsbl %cl,%ecx
  80198b:	83 e9 57             	sub    $0x57,%ecx
  80198e:	eb 0e                	jmp    80199e <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  801990:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  801993:	80 fb 19             	cmp    $0x19,%bl
  801996:	77 13                	ja     8019ab <strtol+0xad>
			dig = *s - 'A' + 10;
  801998:	0f be c9             	movsbl %cl,%ecx
  80199b:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  80199e:	39 f1                	cmp    %esi,%ecx
  8019a0:	7d 0d                	jge    8019af <strtol+0xb1>
			break;
		s++, val = (val * base) + dig;
  8019a2:	42                   	inc    %edx
  8019a3:	0f af c6             	imul   %esi,%eax
  8019a6:	8d 04 01             	lea    (%ecx,%eax,1),%eax
		// we don't properly detect overflow!
	}
  8019a9:	eb c3                	jmp    80196e <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  8019ab:	89 c1                	mov    %eax,%ecx
  8019ad:	eb 02                	jmp    8019b1 <strtol+0xb3>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  8019af:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  8019b1:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8019b5:	74 05                	je     8019bc <strtol+0xbe>
		*endptr = (char *) s;
  8019b7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8019ba:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  8019bc:	85 ff                	test   %edi,%edi
  8019be:	74 04                	je     8019c4 <strtol+0xc6>
  8019c0:	89 c8                	mov    %ecx,%eax
  8019c2:	f7 d8                	neg    %eax
}
  8019c4:	5b                   	pop    %ebx
  8019c5:	5e                   	pop    %esi
  8019c6:	5f                   	pop    %edi
  8019c7:	c9                   	leave  
  8019c8:	c3                   	ret    
  8019c9:	00 00                	add    %al,(%eax)
	...

008019cc <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8019cc:	55                   	push   %ebp
  8019cd:	89 e5                	mov    %esp,%ebp
  8019cf:	57                   	push   %edi
  8019d0:	56                   	push   %esi
  8019d1:	53                   	push   %ebx
  8019d2:	83 ec 0c             	sub    $0xc,%esp
  8019d5:	8b 7d 08             	mov    0x8(%ebp),%edi
  8019d8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8019db:	8b 75 10             	mov    0x10(%ebp),%esi
	// LAB 4: Your code here.
	cprintf("0x%x 0x%x 0x%x\n", (uint32_t)from_env_store, (uint32_t)pg, (uint32_t)perm_store);
  8019de:	56                   	push   %esi
  8019df:	53                   	push   %ebx
  8019e0:	57                   	push   %edi
  8019e1:	68 20 22 80 00       	push   $0x802220
  8019e6:	e8 ad f6 ff ff       	call   801098 <cprintf>
	int r;
	if (pg != NULL) {
  8019eb:	83 c4 10             	add    $0x10,%esp
  8019ee:	85 db                	test   %ebx,%ebx
  8019f0:	74 28                	je     801a1a <ipc_recv+0x4e>
		cprintf("BEGIN\n");
  8019f2:	83 ec 0c             	sub    $0xc,%esp
  8019f5:	68 30 22 80 00       	push   $0x802230
  8019fa:	e8 99 f6 ff ff       	call   801098 <cprintf>
		r = sys_ipc_recv(pg);
  8019ff:	89 1c 24             	mov    %ebx,(%esp)
  801a02:	e8 a0 e8 ff ff       	call   8002a7 <sys_ipc_recv>
  801a07:	89 c3                	mov    %eax,%ebx
		cprintf("OVER\n");
  801a09:	c7 04 24 84 1e 80 00 	movl   $0x801e84,(%esp)
  801a10:	e8 83 f6 ff ff       	call   801098 <cprintf>
  801a15:	83 c4 10             	add    $0x10,%esp
  801a18:	eb 12                	jmp    801a2c <ipc_recv+0x60>
	} else {
		r = sys_ipc_recv((void *)UTOP);
  801a1a:	83 ec 0c             	sub    $0xc,%esp
  801a1d:	68 00 00 c0 ee       	push   $0xeec00000
  801a22:	e8 80 e8 ff ff       	call   8002a7 <sys_ipc_recv>
  801a27:	89 c3                	mov    %eax,%ebx
  801a29:	83 c4 10             	add    $0x10,%esp
	}

	if (r == 0) {
  801a2c:	85 db                	test   %ebx,%ebx
  801a2e:	75 26                	jne    801a56 <ipc_recv+0x8a>
		if (from_env_store != NULL) *from_env_store = thisenv->env_ipc_from;
  801a30:	85 ff                	test   %edi,%edi
  801a32:	74 0a                	je     801a3e <ipc_recv+0x72>
  801a34:	a1 04 40 80 00       	mov    0x804004,%eax
  801a39:	8b 40 74             	mov    0x74(%eax),%eax
  801a3c:	89 07                	mov    %eax,(%edi)
		if (perm_store != NULL) *perm_store = thisenv->env_ipc_perm;
  801a3e:	85 f6                	test   %esi,%esi
  801a40:	74 0a                	je     801a4c <ipc_recv+0x80>
  801a42:	a1 04 40 80 00       	mov    0x804004,%eax
  801a47:	8b 40 78             	mov    0x78(%eax),%eax
  801a4a:	89 06                	mov    %eax,(%esi)
		return thisenv->env_ipc_value;
  801a4c:	a1 04 40 80 00       	mov    0x804004,%eax
  801a51:	8b 58 70             	mov    0x70(%eax),%ebx
  801a54:	eb 14                	jmp    801a6a <ipc_recv+0x9e>
	} else {
		// fails;
		if (from_env_store != NULL) *from_env_store = 0;
  801a56:	85 ff                	test   %edi,%edi
  801a58:	74 06                	je     801a60 <ipc_recv+0x94>
  801a5a:	c7 07 00 00 00 00    	movl   $0x0,(%edi)
		if (perm_store != NULL) *perm_store = 0;
  801a60:	85 f6                	test   %esi,%esi
  801a62:	74 06                	je     801a6a <ipc_recv+0x9e>
  801a64:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		return r;
	}
}
  801a6a:	89 d8                	mov    %ebx,%eax
  801a6c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801a6f:	5b                   	pop    %ebx
  801a70:	5e                   	pop    %esi
  801a71:	5f                   	pop    %edi
  801a72:	c9                   	leave  
  801a73:	c3                   	ret    

00801a74 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801a74:	55                   	push   %ebp
  801a75:	89 e5                	mov    %esp,%ebp
  801a77:	57                   	push   %edi
  801a78:	56                   	push   %esi
  801a79:	53                   	push   %ebx
  801a7a:	83 ec 0c             	sub    $0xc,%esp
  801a7d:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801a80:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801a83:	8b 75 14             	mov    0x14(%ebp),%esi
	// LAB 4: Your code here.
	// int sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
	int r;
	if (pg == NULL) pg = (void *)UTOP;
  801a86:	85 db                	test   %ebx,%ebx
  801a88:	75 25                	jne    801aaf <ipc_send+0x3b>
  801a8a:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
  801a8f:	eb 1e                	jmp    801aaf <ipc_send+0x3b>
	
	while ((r = sys_ipc_try_send(to_env, val, pg, perm)) != 0) {
		if (r == -E_IPC_NOT_RECV) {
  801a91:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801a94:	75 07                	jne    801a9d <ipc_send+0x29>
			// cprintf("Try Again and Again....\n");
			sys_yield();
  801a96:	e8 ea e6 ff ff       	call   800185 <sys_yield>
  801a9b:	eb 12                	jmp    801aaf <ipc_send+0x3b>
		} else {
			panic("ipc_send error %e\n", r);
  801a9d:	50                   	push   %eax
  801a9e:	68 37 22 80 00       	push   $0x802237
  801aa3:	6a 45                	push   $0x45
  801aa5:	68 4a 22 80 00       	push   $0x80224a
  801aaa:	e8 11 f5 ff ff       	call   800fc0 <_panic>
	// LAB 4: Your code here.
	// int sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
	int r;
	if (pg == NULL) pg = (void *)UTOP;
	
	while ((r = sys_ipc_try_send(to_env, val, pg, perm)) != 0) {
  801aaf:	56                   	push   %esi
  801ab0:	53                   	push   %ebx
  801ab1:	57                   	push   %edi
  801ab2:	ff 75 08             	pushl  0x8(%ebp)
  801ab5:	e8 c8 e7 ff ff       	call   800282 <sys_ipc_try_send>
  801aba:	83 c4 10             	add    $0x10,%esp
  801abd:	85 c0                	test   %eax,%eax
  801abf:	75 d0                	jne    801a91 <ipc_send+0x1d>
		} else {
			panic("ipc_send error %e\n", r);
		}
	}
	return;
}
  801ac1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801ac4:	5b                   	pop    %ebx
  801ac5:	5e                   	pop    %esi
  801ac6:	5f                   	pop    %edi
  801ac7:	c9                   	leave  
  801ac8:	c3                   	ret    

00801ac9 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801ac9:	55                   	push   %ebp
  801aca:	89 e5                	mov    %esp,%ebp
  801acc:	53                   	push   %ebx
  801acd:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	for (i = 0; i < NENV; i++)
		if (envs[i].env_type == type)
  801ad0:	39 1d 50 00 c0 ee    	cmp    %ebx,0xeec00050
  801ad6:	74 22                	je     801afa <ipc_find_env+0x31>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801ad8:	b8 01 00 00 00       	mov    $0x1,%eax
		if (envs[i].env_type == type)
  801add:	8d 0c 85 00 00 00 00 	lea    0x0(,%eax,4),%ecx
  801ae4:	89 c2                	mov    %eax,%edx
  801ae6:	c1 e2 07             	shl    $0x7,%edx
  801ae9:	29 ca                	sub    %ecx,%edx
  801aeb:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801af1:	8b 52 50             	mov    0x50(%edx),%edx
  801af4:	39 da                	cmp    %ebx,%edx
  801af6:	75 1d                	jne    801b15 <ipc_find_env+0x4c>
  801af8:	eb 05                	jmp    801aff <ipc_find_env+0x36>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801afa:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
			return envs[i].env_id;
  801aff:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  801b06:	c1 e0 07             	shl    $0x7,%eax
  801b09:	29 d0                	sub    %edx,%eax
  801b0b:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  801b10:	8b 40 40             	mov    0x40(%eax),%eax
  801b13:	eb 0c                	jmp    801b21 <ipc_find_env+0x58>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801b15:	40                   	inc    %eax
  801b16:	3d 00 04 00 00       	cmp    $0x400,%eax
  801b1b:	75 c0                	jne    801add <ipc_find_env+0x14>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801b1d:	66 b8 00 00          	mov    $0x0,%ax
}
  801b21:	5b                   	pop    %ebx
  801b22:	c9                   	leave  
  801b23:	c3                   	ret    

00801b24 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801b24:	55                   	push   %ebp
  801b25:	89 e5                	mov    %esp,%ebp
  801b27:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801b2a:	89 c2                	mov    %eax,%edx
  801b2c:	c1 ea 16             	shr    $0x16,%edx
  801b2f:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801b36:	f6 c2 01             	test   $0x1,%dl
  801b39:	74 1e                	je     801b59 <pageref+0x35>
		return 0;
	pte = uvpt[PGNUM(v)];
  801b3b:	c1 e8 0c             	shr    $0xc,%eax
  801b3e:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  801b45:	a8 01                	test   $0x1,%al
  801b47:	74 17                	je     801b60 <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801b49:	c1 e8 0c             	shr    $0xc,%eax
  801b4c:	66 8b 04 c5 04 00 00 	mov    -0x10fffffc(,%eax,8),%ax
  801b53:	ef 
  801b54:	0f b7 c0             	movzwl %ax,%eax
  801b57:	eb 0c                	jmp    801b65 <pageref+0x41>
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
		return 0;
  801b59:	b8 00 00 00 00       	mov    $0x0,%eax
  801b5e:	eb 05                	jmp    801b65 <pageref+0x41>
	pte = uvpt[PGNUM(v)];
	if (!(pte & PTE_P))
		return 0;
  801b60:	b8 00 00 00 00       	mov    $0x0,%eax
	return pages[PGNUM(pte)].pp_ref;
}
  801b65:	c9                   	leave  
  801b66:	c3                   	ret    
	...

00801b68 <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  801b68:	55                   	push   %ebp
  801b69:	89 e5                	mov    %esp,%ebp
  801b6b:	57                   	push   %edi
  801b6c:	56                   	push   %esi
  801b6d:	83 ec 10             	sub    $0x10,%esp
  801b70:	8b 7d 08             	mov    0x8(%ebp),%edi
  801b73:	8b 4d 10             	mov    0x10(%ebp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  801b76:	89 7d f0             	mov    %edi,-0x10(%ebp)
  801b79:	8b 75 0c             	mov    0xc(%ebp),%esi
  const DWunion dd = {.ll = d};
  801b7c:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  801b7f:	8b 45 14             	mov    0x14(%ebp),%eax
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  801b82:	85 c0                	test   %eax,%eax
  801b84:	75 2e                	jne    801bb4 <__udivdi3+0x4c>
    {
      if (d0 > n1)
  801b86:	39 f1                	cmp    %esi,%ecx
  801b88:	77 5a                	ja     801be4 <__udivdi3+0x7c>
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  801b8a:	85 c9                	test   %ecx,%ecx
  801b8c:	75 0b                	jne    801b99 <__udivdi3+0x31>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  801b8e:	b8 01 00 00 00       	mov    $0x1,%eax
  801b93:	31 d2                	xor    %edx,%edx
  801b95:	f7 f1                	div    %ecx
  801b97:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  801b99:	31 d2                	xor    %edx,%edx
  801b9b:	89 f0                	mov    %esi,%eax
  801b9d:	f7 f1                	div    %ecx
  801b9f:	89 c6                	mov    %eax,%esi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801ba1:	89 f8                	mov    %edi,%eax
  801ba3:	f7 f1                	div    %ecx
  801ba5:	89 c7                	mov    %eax,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  801ba7:	89 f8                	mov    %edi,%eax
  801ba9:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801bab:	83 c4 10             	add    $0x10,%esp
  801bae:	5e                   	pop    %esi
  801baf:	5f                   	pop    %edi
  801bb0:	c9                   	leave  
  801bb1:	c3                   	ret    
  801bb2:	66 90                	xchg   %ax,%ax
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  801bb4:	39 f0                	cmp    %esi,%eax
  801bb6:	77 1c                	ja     801bd4 <__udivdi3+0x6c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  801bb8:	0f bd f8             	bsr    %eax,%edi
	  if (bm == 0)
  801bbb:	83 f7 1f             	xor    $0x1f,%edi
  801bbe:	75 3c                	jne    801bfc <__udivdi3+0x94>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  801bc0:	39 f0                	cmp    %esi,%eax
  801bc2:	0f 82 90 00 00 00    	jb     801c58 <__udivdi3+0xf0>
  801bc8:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801bcb:	39 55 f4             	cmp    %edx,-0xc(%ebp)
  801bce:	0f 86 84 00 00 00    	jbe    801c58 <__udivdi3+0xf0>
  801bd4:	31 f6                	xor    %esi,%esi
  801bd6:	31 ff                	xor    %edi,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  801bd8:	89 f8                	mov    %edi,%eax
  801bda:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801bdc:	83 c4 10             	add    $0x10,%esp
  801bdf:	5e                   	pop    %esi
  801be0:	5f                   	pop    %edi
  801be1:	c9                   	leave  
  801be2:	c3                   	ret    
  801be3:	90                   	nop
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801be4:	89 f2                	mov    %esi,%edx
  801be6:	89 f8                	mov    %edi,%eax
  801be8:	f7 f1                	div    %ecx
  801bea:	89 c7                	mov    %eax,%edi
  801bec:	31 f6                	xor    %esi,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  801bee:	89 f8                	mov    %edi,%eax
  801bf0:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801bf2:	83 c4 10             	add    $0x10,%esp
  801bf5:	5e                   	pop    %esi
  801bf6:	5f                   	pop    %edi
  801bf7:	c9                   	leave  
  801bf8:	c3                   	ret    
  801bf9:	8d 76 00             	lea    0x0(%esi),%esi
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  801bfc:	89 f9                	mov    %edi,%ecx
  801bfe:	d3 e0                	shl    %cl,%eax
  801c00:	89 45 e8             	mov    %eax,-0x18(%ebp)
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  801c03:	b8 20 00 00 00       	mov    $0x20,%eax
  801c08:	29 f8                	sub    %edi,%eax

	      d1 = (d1 << bm) | (d0 >> b);
  801c0a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801c0d:	88 c1                	mov    %al,%cl
  801c0f:	d3 ea                	shr    %cl,%edx
  801c11:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  801c14:	09 ca                	or     %ecx,%edx
  801c16:	89 55 ec             	mov    %edx,-0x14(%ebp)
	      d0 = d0 << bm;
  801c19:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801c1c:	89 f9                	mov    %edi,%ecx
  801c1e:	d3 e2                	shl    %cl,%edx
  801c20:	89 55 f4             	mov    %edx,-0xc(%ebp)
	      n2 = n1 >> b;
  801c23:	89 f2                	mov    %esi,%edx
  801c25:	88 c1                	mov    %al,%cl
  801c27:	d3 ea                	shr    %cl,%edx
  801c29:	89 55 e8             	mov    %edx,-0x18(%ebp)
	      n1 = (n1 << bm) | (n0 >> b);
  801c2c:	89 f2                	mov    %esi,%edx
  801c2e:	89 f9                	mov    %edi,%ecx
  801c30:	d3 e2                	shl    %cl,%edx
  801c32:	8b 75 f0             	mov    -0x10(%ebp),%esi
  801c35:	88 c1                	mov    %al,%cl
  801c37:	d3 ee                	shr    %cl,%esi
  801c39:	09 d6                	or     %edx,%esi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  801c3b:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  801c3e:	89 f0                	mov    %esi,%eax
  801c40:	89 ca                	mov    %ecx,%edx
  801c42:	f7 75 ec             	divl   -0x14(%ebp)
  801c45:	89 d1                	mov    %edx,%ecx
  801c47:	89 c6                	mov    %eax,%esi
	      umul_ppmm (m1, m0, q0, d0);
  801c49:	f7 65 f4             	mull   -0xc(%ebp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801c4c:	39 d1                	cmp    %edx,%ecx
  801c4e:	72 28                	jb     801c78 <__udivdi3+0x110>
  801c50:	74 1a                	je     801c6c <__udivdi3+0x104>
  801c52:	89 f7                	mov    %esi,%edi
  801c54:	31 f6                	xor    %esi,%esi
  801c56:	eb 80                	jmp    801bd8 <__udivdi3+0x70>
	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  801c58:	31 f6                	xor    %esi,%esi
  801c5a:	bf 01 00 00 00       	mov    $0x1,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  801c5f:	89 f8                	mov    %edi,%eax
  801c61:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801c63:	83 c4 10             	add    $0x10,%esp
  801c66:	5e                   	pop    %esi
  801c67:	5f                   	pop    %edi
  801c68:	c9                   	leave  
  801c69:	c3                   	ret    
  801c6a:	66 90                	xchg   %ax,%ax

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  801c6c:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801c6f:	89 f9                	mov    %edi,%ecx
  801c71:	d3 e2                	shl    %cl,%edx

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801c73:	39 c2                	cmp    %eax,%edx
  801c75:	73 db                	jae    801c52 <__udivdi3+0xea>
  801c77:	90                   	nop
		{
		  q0--;
  801c78:	8d 7e ff             	lea    -0x1(%esi),%edi
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  801c7b:	31 f6                	xor    %esi,%esi
  801c7d:	e9 56 ff ff ff       	jmp    801bd8 <__udivdi3+0x70>
	...

00801c84 <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  801c84:	55                   	push   %ebp
  801c85:	89 e5                	mov    %esp,%ebp
  801c87:	57                   	push   %edi
  801c88:	56                   	push   %esi
  801c89:	83 ec 20             	sub    $0x20,%esp
  801c8c:	8b 45 08             	mov    0x8(%ebp),%eax
  801c8f:	8b 4d 10             	mov    0x10(%ebp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  801c92:	89 45 e8             	mov    %eax,-0x18(%ebp)
  801c95:	8b 75 0c             	mov    0xc(%ebp),%esi
  const DWunion dd = {.ll = d};
  801c98:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  801c9b:	8b 7d 14             	mov    0x14(%ebp),%edi
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  801c9e:	89 45 f0             	mov    %eax,-0x10(%ebp)
  n1 = nn.s.high;
  801ca1:	89 f2                	mov    %esi,%edx

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  801ca3:	85 ff                	test   %edi,%edi
  801ca5:	75 15                	jne    801cbc <__umoddi3+0x38>
    {
      if (d0 > n1)
  801ca7:	39 f1                	cmp    %esi,%ecx
  801ca9:	0f 86 99 00 00 00    	jbe    801d48 <__umoddi3+0xc4>
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801caf:	f7 f1                	div    %ecx

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
  801cb1:	89 d0                	mov    %edx,%eax
  801cb3:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  801cb5:	83 c4 20             	add    $0x20,%esp
  801cb8:	5e                   	pop    %esi
  801cb9:	5f                   	pop    %edi
  801cba:	c9                   	leave  
  801cbb:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  801cbc:	39 f7                	cmp    %esi,%edi
  801cbe:	0f 87 a4 00 00 00    	ja     801d68 <__umoddi3+0xe4>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  801cc4:	0f bd c7             	bsr    %edi,%eax
	  if (bm == 0)
  801cc7:	83 f0 1f             	xor    $0x1f,%eax
  801cca:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801ccd:	0f 84 a1 00 00 00    	je     801d74 <__umoddi3+0xf0>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  801cd3:	89 f8                	mov    %edi,%eax
  801cd5:	8a 4d ec             	mov    -0x14(%ebp),%cl
  801cd8:	d3 e0                	shl    %cl,%eax
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  801cda:	bf 20 00 00 00       	mov    $0x20,%edi
  801cdf:	2b 7d ec             	sub    -0x14(%ebp),%edi

	      d1 = (d1 << bm) | (d0 >> b);
  801ce2:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801ce5:	89 f9                	mov    %edi,%ecx
  801ce7:	d3 ea                	shr    %cl,%edx
  801ce9:	09 c2                	or     %eax,%edx
  801ceb:	89 55 f0             	mov    %edx,-0x10(%ebp)
	      d0 = d0 << bm;
  801cee:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801cf1:	8a 4d ec             	mov    -0x14(%ebp),%cl
  801cf4:	d3 e0                	shl    %cl,%eax
  801cf6:	89 45 f4             	mov    %eax,-0xc(%ebp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  801cf9:	89 f2                	mov    %esi,%edx
  801cfb:	d3 e2                	shl    %cl,%edx
	      n0 = n0 << bm;
  801cfd:	8b 45 e8             	mov    -0x18(%ebp),%eax
  801d00:	d3 e0                	shl    %cl,%eax
  801d02:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  801d05:	8b 45 e8             	mov    -0x18(%ebp),%eax
  801d08:	89 f9                	mov    %edi,%ecx
  801d0a:	d3 e8                	shr    %cl,%eax
  801d0c:	09 d0                	or     %edx,%eax

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  801d0e:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  801d10:	89 f2                	mov    %esi,%edx
  801d12:	f7 75 f0             	divl   -0x10(%ebp)
  801d15:	89 d6                	mov    %edx,%esi
	      umul_ppmm (m1, m0, q0, d0);
  801d17:	f7 65 f4             	mull   -0xc(%ebp)
  801d1a:	89 55 e8             	mov    %edx,-0x18(%ebp)
  801d1d:	89 c1                	mov    %eax,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801d1f:	39 d6                	cmp    %edx,%esi
  801d21:	72 71                	jb     801d94 <__umoddi3+0x110>
  801d23:	74 7f                	je     801da4 <__umoddi3+0x120>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  801d25:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801d28:	29 c8                	sub    %ecx,%eax
  801d2a:	19 d6                	sbb    %edx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
  801d2c:	8a 4d ec             	mov    -0x14(%ebp),%cl
  801d2f:	d3 e8                	shr    %cl,%eax
  801d31:	89 f2                	mov    %esi,%edx
  801d33:	89 f9                	mov    %edi,%ecx
  801d35:	d3 e2                	shl    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
  801d37:	09 d0                	or     %edx,%eax
  801d39:	89 f2                	mov    %esi,%edx
  801d3b:	8a 4d ec             	mov    -0x14(%ebp),%cl
  801d3e:	d3 ea                	shr    %cl,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  801d40:	83 c4 20             	add    $0x20,%esp
  801d43:	5e                   	pop    %esi
  801d44:	5f                   	pop    %edi
  801d45:	c9                   	leave  
  801d46:	c3                   	ret    
  801d47:	90                   	nop
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  801d48:	85 c9                	test   %ecx,%ecx
  801d4a:	75 0b                	jne    801d57 <__umoddi3+0xd3>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  801d4c:	b8 01 00 00 00       	mov    $0x1,%eax
  801d51:	31 d2                	xor    %edx,%edx
  801d53:	f7 f1                	div    %ecx
  801d55:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  801d57:	89 f0                	mov    %esi,%eax
  801d59:	31 d2                	xor    %edx,%edx
  801d5b:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801d5d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801d60:	f7 f1                	div    %ecx
  801d62:	e9 4a ff ff ff       	jmp    801cb1 <__umoddi3+0x2d>
  801d67:	90                   	nop
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
  801d68:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  801d6a:	83 c4 20             	add    $0x20,%esp
  801d6d:	5e                   	pop    %esi
  801d6e:	5f                   	pop    %edi
  801d6f:	c9                   	leave  
  801d70:	c3                   	ret    
  801d71:	8d 76 00             	lea    0x0(%esi),%esi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  801d74:	39 f7                	cmp    %esi,%edi
  801d76:	72 05                	jb     801d7d <__umoddi3+0xf9>
  801d78:	3b 4d f0             	cmp    -0x10(%ebp),%ecx
  801d7b:	77 0c                	ja     801d89 <__umoddi3+0x105>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  801d7d:	89 f2                	mov    %esi,%edx
  801d7f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801d82:	29 c8                	sub    %ecx,%eax
  801d84:	19 fa                	sbb    %edi,%edx
  801d86:	89 45 f0             	mov    %eax,-0x10(%ebp)

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
  801d89:	8b 45 f0             	mov    -0x10(%ebp),%eax
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  801d8c:	83 c4 20             	add    $0x20,%esp
  801d8f:	5e                   	pop    %esi
  801d90:	5f                   	pop    %edi
  801d91:	c9                   	leave  
  801d92:	c3                   	ret    
  801d93:	90                   	nop
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  801d94:	8b 55 e8             	mov    -0x18(%ebp),%edx
  801d97:	89 c1                	mov    %eax,%ecx
  801d99:	2b 4d f4             	sub    -0xc(%ebp),%ecx
  801d9c:	1b 55 f0             	sbb    -0x10(%ebp),%edx
  801d9f:	eb 84                	jmp    801d25 <__umoddi3+0xa1>
  801da1:	8d 76 00             	lea    0x0(%esi),%esi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801da4:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  801da7:	72 eb                	jb     801d94 <__umoddi3+0x110>
  801da9:	89 f2                	mov    %esi,%edx
  801dab:	e9 75 ff ff ff       	jmp    801d25 <__umoddi3+0xa1>
