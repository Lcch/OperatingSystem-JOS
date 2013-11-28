
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
  800092:	e8 87 04 00 00       	call   80051e <close_all>
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
  8000da:	68 aa 1d 80 00       	push   $0x801daa
  8000df:	6a 42                	push   $0x42
  8000e1:	68 c7 1d 80 00       	push   $0x801dc7
  8000e6:	e8 dd 0e 00 00       	call   800fc8 <_panic>

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

008002ec <sys_exec>:

int
sys_exec(uint32_t eip, uint32_t esp, void * ph, uint32_t elf_phnum)
{
  8002ec:	55                   	push   %ebp
  8002ed:	89 e5                	mov    %esp,%ebp
  8002ef:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_exec, 0, eip, esp, (uint32_t)ph, elf_phnum, 0);
  8002f2:	6a 00                	push   $0x0
  8002f4:	ff 75 14             	pushl  0x14(%ebp)
  8002f7:	ff 75 10             	pushl  0x10(%ebp)
  8002fa:	ff 75 0c             	pushl  0xc(%ebp)
  8002fd:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800300:	ba 00 00 00 00       	mov    $0x0,%edx
  800305:	b8 0f 00 00 00       	mov    $0xf,%eax
  80030a:	e8 99 fd ff ff       	call   8000a8 <syscall>
  80030f:	c9                   	leave  
  800310:	c3                   	ret    
  800311:	00 00                	add    %al,(%eax)
	...

00800314 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800314:	55                   	push   %ebp
  800315:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800317:	8b 45 08             	mov    0x8(%ebp),%eax
  80031a:	05 00 00 00 30       	add    $0x30000000,%eax
  80031f:	c1 e8 0c             	shr    $0xc,%eax
}
  800322:	c9                   	leave  
  800323:	c3                   	ret    

00800324 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800324:	55                   	push   %ebp
  800325:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  800327:	ff 75 08             	pushl  0x8(%ebp)
  80032a:	e8 e5 ff ff ff       	call   800314 <fd2num>
  80032f:	83 c4 04             	add    $0x4,%esp
  800332:	05 20 00 0d 00       	add    $0xd0020,%eax
  800337:	c1 e0 0c             	shl    $0xc,%eax
}
  80033a:	c9                   	leave  
  80033b:	c3                   	ret    

0080033c <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  80033c:	55                   	push   %ebp
  80033d:	89 e5                	mov    %esp,%ebp
  80033f:	53                   	push   %ebx
  800340:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800343:	a1 00 dd 7b ef       	mov    0xef7bdd00,%eax
  800348:	a8 01                	test   $0x1,%al
  80034a:	74 34                	je     800380 <fd_alloc+0x44>
  80034c:	a1 00 00 74 ef       	mov    0xef740000,%eax
  800351:	a8 01                	test   $0x1,%al
  800353:	74 32                	je     800387 <fd_alloc+0x4b>
  800355:	b8 00 10 00 d0       	mov    $0xd0001000,%eax
  80035a:	89 c1                	mov    %eax,%ecx
  80035c:	89 c2                	mov    %eax,%edx
  80035e:	c1 ea 16             	shr    $0x16,%edx
  800361:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800368:	f6 c2 01             	test   $0x1,%dl
  80036b:	74 1f                	je     80038c <fd_alloc+0x50>
  80036d:	89 c2                	mov    %eax,%edx
  80036f:	c1 ea 0c             	shr    $0xc,%edx
  800372:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800379:	f6 c2 01             	test   $0x1,%dl
  80037c:	75 17                	jne    800395 <fd_alloc+0x59>
  80037e:	eb 0c                	jmp    80038c <fd_alloc+0x50>
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  800380:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
  800385:	eb 05                	jmp    80038c <fd_alloc+0x50>
  800387:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
  80038c:	89 0b                	mov    %ecx,(%ebx)
			return 0;
  80038e:	b8 00 00 00 00       	mov    $0x0,%eax
  800393:	eb 17                	jmp    8003ac <fd_alloc+0x70>
  800395:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  80039a:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  80039f:	75 b9                	jne    80035a <fd_alloc+0x1e>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8003a1:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_MAX_OPEN;
  8003a7:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8003ac:	5b                   	pop    %ebx
  8003ad:	c9                   	leave  
  8003ae:	c3                   	ret    

008003af <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8003af:	55                   	push   %ebp
  8003b0:	89 e5                	mov    %esp,%ebp
  8003b2:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8003b5:	83 f8 1f             	cmp    $0x1f,%eax
  8003b8:	77 36                	ja     8003f0 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8003ba:	05 00 00 0d 00       	add    $0xd0000,%eax
  8003bf:	c1 e0 0c             	shl    $0xc,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8003c2:	89 c2                	mov    %eax,%edx
  8003c4:	c1 ea 16             	shr    $0x16,%edx
  8003c7:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8003ce:	f6 c2 01             	test   $0x1,%dl
  8003d1:	74 24                	je     8003f7 <fd_lookup+0x48>
  8003d3:	89 c2                	mov    %eax,%edx
  8003d5:	c1 ea 0c             	shr    $0xc,%edx
  8003d8:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8003df:	f6 c2 01             	test   $0x1,%dl
  8003e2:	74 1a                	je     8003fe <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8003e4:	8b 55 0c             	mov    0xc(%ebp),%edx
  8003e7:	89 02                	mov    %eax,(%edx)
	return 0;
  8003e9:	b8 00 00 00 00       	mov    $0x0,%eax
  8003ee:	eb 13                	jmp    800403 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8003f0:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8003f5:	eb 0c                	jmp    800403 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8003f7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8003fc:	eb 05                	jmp    800403 <fd_lookup+0x54>
  8003fe:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800403:	c9                   	leave  
  800404:	c3                   	ret    

00800405 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800405:	55                   	push   %ebp
  800406:	89 e5                	mov    %esp,%ebp
  800408:	53                   	push   %ebx
  800409:	83 ec 04             	sub    $0x4,%esp
  80040c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80040f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
		if (devtab[i]->dev_id == dev_id) {
  800412:	39 0d 04 30 80 00    	cmp    %ecx,0x803004
  800418:	74 0d                	je     800427 <dev_lookup+0x22>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  80041a:	b8 00 00 00 00       	mov    $0x0,%eax
  80041f:	eb 14                	jmp    800435 <dev_lookup+0x30>
		if (devtab[i]->dev_id == dev_id) {
  800421:	39 0a                	cmp    %ecx,(%edx)
  800423:	75 10                	jne    800435 <dev_lookup+0x30>
  800425:	eb 05                	jmp    80042c <dev_lookup+0x27>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800427:	ba 04 30 80 00       	mov    $0x803004,%edx
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
  80042c:	89 13                	mov    %edx,(%ebx)
			return 0;
  80042e:	b8 00 00 00 00       	mov    $0x0,%eax
  800433:	eb 31                	jmp    800466 <dev_lookup+0x61>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800435:	40                   	inc    %eax
  800436:	8b 14 85 54 1e 80 00 	mov    0x801e54(,%eax,4),%edx
  80043d:	85 d2                	test   %edx,%edx
  80043f:	75 e0                	jne    800421 <dev_lookup+0x1c>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800441:	a1 04 40 80 00       	mov    0x804004,%eax
  800446:	8b 40 48             	mov    0x48(%eax),%eax
  800449:	83 ec 04             	sub    $0x4,%esp
  80044c:	51                   	push   %ecx
  80044d:	50                   	push   %eax
  80044e:	68 d8 1d 80 00       	push   $0x801dd8
  800453:	e8 48 0c 00 00       	call   8010a0 <cprintf>
	*dev = 0;
  800458:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_INVAL;
  80045e:	83 c4 10             	add    $0x10,%esp
  800461:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800466:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800469:	c9                   	leave  
  80046a:	c3                   	ret    

0080046b <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  80046b:	55                   	push   %ebp
  80046c:	89 e5                	mov    %esp,%ebp
  80046e:	56                   	push   %esi
  80046f:	53                   	push   %ebx
  800470:	83 ec 20             	sub    $0x20,%esp
  800473:	8b 75 08             	mov    0x8(%ebp),%esi
  800476:	8a 45 0c             	mov    0xc(%ebp),%al
  800479:	88 45 e7             	mov    %al,-0x19(%ebp)
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80047c:	56                   	push   %esi
  80047d:	e8 92 fe ff ff       	call   800314 <fd2num>
  800482:	8d 55 f4             	lea    -0xc(%ebp),%edx
  800485:	89 14 24             	mov    %edx,(%esp)
  800488:	50                   	push   %eax
  800489:	e8 21 ff ff ff       	call   8003af <fd_lookup>
  80048e:	89 c3                	mov    %eax,%ebx
  800490:	83 c4 08             	add    $0x8,%esp
  800493:	85 c0                	test   %eax,%eax
  800495:	78 05                	js     80049c <fd_close+0x31>
	    || fd != fd2)
  800497:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  80049a:	74 0d                	je     8004a9 <fd_close+0x3e>
		return (must_exist ? r : 0);
  80049c:	80 7d e7 00          	cmpb   $0x0,-0x19(%ebp)
  8004a0:	75 48                	jne    8004ea <fd_close+0x7f>
  8004a2:	bb 00 00 00 00       	mov    $0x0,%ebx
  8004a7:	eb 41                	jmp    8004ea <fd_close+0x7f>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8004a9:	83 ec 08             	sub    $0x8,%esp
  8004ac:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8004af:	50                   	push   %eax
  8004b0:	ff 36                	pushl  (%esi)
  8004b2:	e8 4e ff ff ff       	call   800405 <dev_lookup>
  8004b7:	89 c3                	mov    %eax,%ebx
  8004b9:	83 c4 10             	add    $0x10,%esp
  8004bc:	85 c0                	test   %eax,%eax
  8004be:	78 1c                	js     8004dc <fd_close+0x71>
		if (dev->dev_close)
  8004c0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8004c3:	8b 40 10             	mov    0x10(%eax),%eax
  8004c6:	85 c0                	test   %eax,%eax
  8004c8:	74 0d                	je     8004d7 <fd_close+0x6c>
			r = (*dev->dev_close)(fd);
  8004ca:	83 ec 0c             	sub    $0xc,%esp
  8004cd:	56                   	push   %esi
  8004ce:	ff d0                	call   *%eax
  8004d0:	89 c3                	mov    %eax,%ebx
  8004d2:	83 c4 10             	add    $0x10,%esp
  8004d5:	eb 05                	jmp    8004dc <fd_close+0x71>
		else
			r = 0;
  8004d7:	bb 00 00 00 00       	mov    $0x0,%ebx
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8004dc:	83 ec 08             	sub    $0x8,%esp
  8004df:	56                   	push   %esi
  8004e0:	6a 00                	push   $0x0
  8004e2:	e8 0f fd ff ff       	call   8001f6 <sys_page_unmap>
	return r;
  8004e7:	83 c4 10             	add    $0x10,%esp
}
  8004ea:	89 d8                	mov    %ebx,%eax
  8004ec:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8004ef:	5b                   	pop    %ebx
  8004f0:	5e                   	pop    %esi
  8004f1:	c9                   	leave  
  8004f2:	c3                   	ret    

008004f3 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8004f3:	55                   	push   %ebp
  8004f4:	89 e5                	mov    %esp,%ebp
  8004f6:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8004f9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8004fc:	50                   	push   %eax
  8004fd:	ff 75 08             	pushl  0x8(%ebp)
  800500:	e8 aa fe ff ff       	call   8003af <fd_lookup>
  800505:	83 c4 08             	add    $0x8,%esp
  800508:	85 c0                	test   %eax,%eax
  80050a:	78 10                	js     80051c <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  80050c:	83 ec 08             	sub    $0x8,%esp
  80050f:	6a 01                	push   $0x1
  800511:	ff 75 f4             	pushl  -0xc(%ebp)
  800514:	e8 52 ff ff ff       	call   80046b <fd_close>
  800519:	83 c4 10             	add    $0x10,%esp
}
  80051c:	c9                   	leave  
  80051d:	c3                   	ret    

0080051e <close_all>:

void
close_all(void)
{
  80051e:	55                   	push   %ebp
  80051f:	89 e5                	mov    %esp,%ebp
  800521:	53                   	push   %ebx
  800522:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800525:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  80052a:	83 ec 0c             	sub    $0xc,%esp
  80052d:	53                   	push   %ebx
  80052e:	e8 c0 ff ff ff       	call   8004f3 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  800533:	43                   	inc    %ebx
  800534:	83 c4 10             	add    $0x10,%esp
  800537:	83 fb 20             	cmp    $0x20,%ebx
  80053a:	75 ee                	jne    80052a <close_all+0xc>
		close(i);
}
  80053c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80053f:	c9                   	leave  
  800540:	c3                   	ret    

00800541 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800541:	55                   	push   %ebp
  800542:	89 e5                	mov    %esp,%ebp
  800544:	57                   	push   %edi
  800545:	56                   	push   %esi
  800546:	53                   	push   %ebx
  800547:	83 ec 2c             	sub    $0x2c,%esp
  80054a:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  80054d:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800550:	50                   	push   %eax
  800551:	ff 75 08             	pushl  0x8(%ebp)
  800554:	e8 56 fe ff ff       	call   8003af <fd_lookup>
  800559:	89 c3                	mov    %eax,%ebx
  80055b:	83 c4 08             	add    $0x8,%esp
  80055e:	85 c0                	test   %eax,%eax
  800560:	0f 88 c0 00 00 00    	js     800626 <dup+0xe5>
		return r;
	close(newfdnum);
  800566:	83 ec 0c             	sub    $0xc,%esp
  800569:	57                   	push   %edi
  80056a:	e8 84 ff ff ff       	call   8004f3 <close>

	newfd = INDEX2FD(newfdnum);
  80056f:	8d b7 00 00 0d 00    	lea    0xd0000(%edi),%esi
  800575:	c1 e6 0c             	shl    $0xc,%esi
	ova = fd2data(oldfd);
  800578:	83 c4 04             	add    $0x4,%esp
  80057b:	ff 75 e4             	pushl  -0x1c(%ebp)
  80057e:	e8 a1 fd ff ff       	call   800324 <fd2data>
  800583:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  800585:	89 34 24             	mov    %esi,(%esp)
  800588:	e8 97 fd ff ff       	call   800324 <fd2data>
  80058d:	83 c4 10             	add    $0x10,%esp
  800590:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  800593:	89 d8                	mov    %ebx,%eax
  800595:	c1 e8 16             	shr    $0x16,%eax
  800598:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80059f:	a8 01                	test   $0x1,%al
  8005a1:	74 37                	je     8005da <dup+0x99>
  8005a3:	89 d8                	mov    %ebx,%eax
  8005a5:	c1 e8 0c             	shr    $0xc,%eax
  8005a8:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8005af:	f6 c2 01             	test   $0x1,%dl
  8005b2:	74 26                	je     8005da <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8005b4:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8005bb:	83 ec 0c             	sub    $0xc,%esp
  8005be:	25 07 0e 00 00       	and    $0xe07,%eax
  8005c3:	50                   	push   %eax
  8005c4:	ff 75 d4             	pushl  -0x2c(%ebp)
  8005c7:	6a 00                	push   $0x0
  8005c9:	53                   	push   %ebx
  8005ca:	6a 00                	push   $0x0
  8005cc:	e8 ff fb ff ff       	call   8001d0 <sys_page_map>
  8005d1:	89 c3                	mov    %eax,%ebx
  8005d3:	83 c4 20             	add    $0x20,%esp
  8005d6:	85 c0                	test   %eax,%eax
  8005d8:	78 2d                	js     800607 <dup+0xc6>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8005da:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8005dd:	89 c2                	mov    %eax,%edx
  8005df:	c1 ea 0c             	shr    $0xc,%edx
  8005e2:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8005e9:	83 ec 0c             	sub    $0xc,%esp
  8005ec:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  8005f2:	52                   	push   %edx
  8005f3:	56                   	push   %esi
  8005f4:	6a 00                	push   $0x0
  8005f6:	50                   	push   %eax
  8005f7:	6a 00                	push   $0x0
  8005f9:	e8 d2 fb ff ff       	call   8001d0 <sys_page_map>
  8005fe:	89 c3                	mov    %eax,%ebx
  800600:	83 c4 20             	add    $0x20,%esp
  800603:	85 c0                	test   %eax,%eax
  800605:	79 1d                	jns    800624 <dup+0xe3>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  800607:	83 ec 08             	sub    $0x8,%esp
  80060a:	56                   	push   %esi
  80060b:	6a 00                	push   $0x0
  80060d:	e8 e4 fb ff ff       	call   8001f6 <sys_page_unmap>
	sys_page_unmap(0, nva);
  800612:	83 c4 08             	add    $0x8,%esp
  800615:	ff 75 d4             	pushl  -0x2c(%ebp)
  800618:	6a 00                	push   $0x0
  80061a:	e8 d7 fb ff ff       	call   8001f6 <sys_page_unmap>
	return r;
  80061f:	83 c4 10             	add    $0x10,%esp
  800622:	eb 02                	jmp    800626 <dup+0xe5>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
		goto err;

	return newfdnum;
  800624:	89 fb                	mov    %edi,%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  800626:	89 d8                	mov    %ebx,%eax
  800628:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80062b:	5b                   	pop    %ebx
  80062c:	5e                   	pop    %esi
  80062d:	5f                   	pop    %edi
  80062e:	c9                   	leave  
  80062f:	c3                   	ret    

00800630 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  800630:	55                   	push   %ebp
  800631:	89 e5                	mov    %esp,%ebp
  800633:	53                   	push   %ebx
  800634:	83 ec 14             	sub    $0x14,%esp
  800637:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80063a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80063d:	50                   	push   %eax
  80063e:	53                   	push   %ebx
  80063f:	e8 6b fd ff ff       	call   8003af <fd_lookup>
  800644:	83 c4 08             	add    $0x8,%esp
  800647:	85 c0                	test   %eax,%eax
  800649:	78 67                	js     8006b2 <read+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80064b:	83 ec 08             	sub    $0x8,%esp
  80064e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800651:	50                   	push   %eax
  800652:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800655:	ff 30                	pushl  (%eax)
  800657:	e8 a9 fd ff ff       	call   800405 <dev_lookup>
  80065c:	83 c4 10             	add    $0x10,%esp
  80065f:	85 c0                	test   %eax,%eax
  800661:	78 4f                	js     8006b2 <read+0x82>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  800663:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800666:	8b 50 08             	mov    0x8(%eax),%edx
  800669:	83 e2 03             	and    $0x3,%edx
  80066c:	83 fa 01             	cmp    $0x1,%edx
  80066f:	75 21                	jne    800692 <read+0x62>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  800671:	a1 04 40 80 00       	mov    0x804004,%eax
  800676:	8b 40 48             	mov    0x48(%eax),%eax
  800679:	83 ec 04             	sub    $0x4,%esp
  80067c:	53                   	push   %ebx
  80067d:	50                   	push   %eax
  80067e:	68 19 1e 80 00       	push   $0x801e19
  800683:	e8 18 0a 00 00       	call   8010a0 <cprintf>
		return -E_INVAL;
  800688:	83 c4 10             	add    $0x10,%esp
  80068b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800690:	eb 20                	jmp    8006b2 <read+0x82>
	}
	if (!dev->dev_read)
  800692:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800695:	8b 52 08             	mov    0x8(%edx),%edx
  800698:	85 d2                	test   %edx,%edx
  80069a:	74 11                	je     8006ad <read+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  80069c:	83 ec 04             	sub    $0x4,%esp
  80069f:	ff 75 10             	pushl  0x10(%ebp)
  8006a2:	ff 75 0c             	pushl  0xc(%ebp)
  8006a5:	50                   	push   %eax
  8006a6:	ff d2                	call   *%edx
  8006a8:	83 c4 10             	add    $0x10,%esp
  8006ab:	eb 05                	jmp    8006b2 <read+0x82>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8006ad:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_read)(fd, buf, n);
}
  8006b2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8006b5:	c9                   	leave  
  8006b6:	c3                   	ret    

008006b7 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8006b7:	55                   	push   %ebp
  8006b8:	89 e5                	mov    %esp,%ebp
  8006ba:	57                   	push   %edi
  8006bb:	56                   	push   %esi
  8006bc:	53                   	push   %ebx
  8006bd:	83 ec 0c             	sub    $0xc,%esp
  8006c0:	8b 7d 08             	mov    0x8(%ebp),%edi
  8006c3:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8006c6:	85 f6                	test   %esi,%esi
  8006c8:	74 31                	je     8006fb <readn+0x44>
  8006ca:	b8 00 00 00 00       	mov    $0x0,%eax
  8006cf:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = read(fdnum, (char*)buf + tot, n - tot);
  8006d4:	83 ec 04             	sub    $0x4,%esp
  8006d7:	89 f2                	mov    %esi,%edx
  8006d9:	29 c2                	sub    %eax,%edx
  8006db:	52                   	push   %edx
  8006dc:	03 45 0c             	add    0xc(%ebp),%eax
  8006df:	50                   	push   %eax
  8006e0:	57                   	push   %edi
  8006e1:	e8 4a ff ff ff       	call   800630 <read>
		if (m < 0)
  8006e6:	83 c4 10             	add    $0x10,%esp
  8006e9:	85 c0                	test   %eax,%eax
  8006eb:	78 17                	js     800704 <readn+0x4d>
			return m;
		if (m == 0)
  8006ed:	85 c0                	test   %eax,%eax
  8006ef:	74 11                	je     800702 <readn+0x4b>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8006f1:	01 c3                	add    %eax,%ebx
  8006f3:	89 d8                	mov    %ebx,%eax
  8006f5:	39 f3                	cmp    %esi,%ebx
  8006f7:	72 db                	jb     8006d4 <readn+0x1d>
  8006f9:	eb 09                	jmp    800704 <readn+0x4d>
  8006fb:	b8 00 00 00 00       	mov    $0x0,%eax
  800700:	eb 02                	jmp    800704 <readn+0x4d>
		m = read(fdnum, (char*)buf + tot, n - tot);
		if (m < 0)
			return m;
		if (m == 0)
  800702:	89 d8                	mov    %ebx,%eax
			break;
	}
	return tot;
}
  800704:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800707:	5b                   	pop    %ebx
  800708:	5e                   	pop    %esi
  800709:	5f                   	pop    %edi
  80070a:	c9                   	leave  
  80070b:	c3                   	ret    

0080070c <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80070c:	55                   	push   %ebp
  80070d:	89 e5                	mov    %esp,%ebp
  80070f:	53                   	push   %ebx
  800710:	83 ec 14             	sub    $0x14,%esp
  800713:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800716:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800719:	50                   	push   %eax
  80071a:	53                   	push   %ebx
  80071b:	e8 8f fc ff ff       	call   8003af <fd_lookup>
  800720:	83 c4 08             	add    $0x8,%esp
  800723:	85 c0                	test   %eax,%eax
  800725:	78 62                	js     800789 <write+0x7d>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800727:	83 ec 08             	sub    $0x8,%esp
  80072a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80072d:	50                   	push   %eax
  80072e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800731:	ff 30                	pushl  (%eax)
  800733:	e8 cd fc ff ff       	call   800405 <dev_lookup>
  800738:	83 c4 10             	add    $0x10,%esp
  80073b:	85 c0                	test   %eax,%eax
  80073d:	78 4a                	js     800789 <write+0x7d>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80073f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800742:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  800746:	75 21                	jne    800769 <write+0x5d>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  800748:	a1 04 40 80 00       	mov    0x804004,%eax
  80074d:	8b 40 48             	mov    0x48(%eax),%eax
  800750:	83 ec 04             	sub    $0x4,%esp
  800753:	53                   	push   %ebx
  800754:	50                   	push   %eax
  800755:	68 35 1e 80 00       	push   $0x801e35
  80075a:	e8 41 09 00 00       	call   8010a0 <cprintf>
		return -E_INVAL;
  80075f:	83 c4 10             	add    $0x10,%esp
  800762:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800767:	eb 20                	jmp    800789 <write+0x7d>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  800769:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80076c:	8b 52 0c             	mov    0xc(%edx),%edx
  80076f:	85 d2                	test   %edx,%edx
  800771:	74 11                	je     800784 <write+0x78>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  800773:	83 ec 04             	sub    $0x4,%esp
  800776:	ff 75 10             	pushl  0x10(%ebp)
  800779:	ff 75 0c             	pushl  0xc(%ebp)
  80077c:	50                   	push   %eax
  80077d:	ff d2                	call   *%edx
  80077f:	83 c4 10             	add    $0x10,%esp
  800782:	eb 05                	jmp    800789 <write+0x7d>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  800784:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  800789:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80078c:	c9                   	leave  
  80078d:	c3                   	ret    

0080078e <seek>:

int
seek(int fdnum, off_t offset)
{
  80078e:	55                   	push   %ebp
  80078f:	89 e5                	mov    %esp,%ebp
  800791:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800794:	8d 45 fc             	lea    -0x4(%ebp),%eax
  800797:	50                   	push   %eax
  800798:	ff 75 08             	pushl  0x8(%ebp)
  80079b:	e8 0f fc ff ff       	call   8003af <fd_lookup>
  8007a0:	83 c4 08             	add    $0x8,%esp
  8007a3:	85 c0                	test   %eax,%eax
  8007a5:	78 0e                	js     8007b5 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8007a7:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8007aa:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007ad:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8007b0:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8007b5:	c9                   	leave  
  8007b6:	c3                   	ret    

008007b7 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8007b7:	55                   	push   %ebp
  8007b8:	89 e5                	mov    %esp,%ebp
  8007ba:	53                   	push   %ebx
  8007bb:	83 ec 14             	sub    $0x14,%esp
  8007be:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8007c1:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8007c4:	50                   	push   %eax
  8007c5:	53                   	push   %ebx
  8007c6:	e8 e4 fb ff ff       	call   8003af <fd_lookup>
  8007cb:	83 c4 08             	add    $0x8,%esp
  8007ce:	85 c0                	test   %eax,%eax
  8007d0:	78 5f                	js     800831 <ftruncate+0x7a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8007d2:	83 ec 08             	sub    $0x8,%esp
  8007d5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8007d8:	50                   	push   %eax
  8007d9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8007dc:	ff 30                	pushl  (%eax)
  8007de:	e8 22 fc ff ff       	call   800405 <dev_lookup>
  8007e3:	83 c4 10             	add    $0x10,%esp
  8007e6:	85 c0                	test   %eax,%eax
  8007e8:	78 47                	js     800831 <ftruncate+0x7a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8007ea:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8007ed:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8007f1:	75 21                	jne    800814 <ftruncate+0x5d>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8007f3:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8007f8:	8b 40 48             	mov    0x48(%eax),%eax
  8007fb:	83 ec 04             	sub    $0x4,%esp
  8007fe:	53                   	push   %ebx
  8007ff:	50                   	push   %eax
  800800:	68 f8 1d 80 00       	push   $0x801df8
  800805:	e8 96 08 00 00       	call   8010a0 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  80080a:	83 c4 10             	add    $0x10,%esp
  80080d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800812:	eb 1d                	jmp    800831 <ftruncate+0x7a>
	}
	if (!dev->dev_trunc)
  800814:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800817:	8b 52 18             	mov    0x18(%edx),%edx
  80081a:	85 d2                	test   %edx,%edx
  80081c:	74 0e                	je     80082c <ftruncate+0x75>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80081e:	83 ec 08             	sub    $0x8,%esp
  800821:	ff 75 0c             	pushl  0xc(%ebp)
  800824:	50                   	push   %eax
  800825:	ff d2                	call   *%edx
  800827:	83 c4 10             	add    $0x10,%esp
  80082a:	eb 05                	jmp    800831 <ftruncate+0x7a>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  80082c:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  800831:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800834:	c9                   	leave  
  800835:	c3                   	ret    

00800836 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  800836:	55                   	push   %ebp
  800837:	89 e5                	mov    %esp,%ebp
  800839:	53                   	push   %ebx
  80083a:	83 ec 14             	sub    $0x14,%esp
  80083d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800840:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800843:	50                   	push   %eax
  800844:	ff 75 08             	pushl  0x8(%ebp)
  800847:	e8 63 fb ff ff       	call   8003af <fd_lookup>
  80084c:	83 c4 08             	add    $0x8,%esp
  80084f:	85 c0                	test   %eax,%eax
  800851:	78 52                	js     8008a5 <fstat+0x6f>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800853:	83 ec 08             	sub    $0x8,%esp
  800856:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800859:	50                   	push   %eax
  80085a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80085d:	ff 30                	pushl  (%eax)
  80085f:	e8 a1 fb ff ff       	call   800405 <dev_lookup>
  800864:	83 c4 10             	add    $0x10,%esp
  800867:	85 c0                	test   %eax,%eax
  800869:	78 3a                	js     8008a5 <fstat+0x6f>
		return r;
	if (!dev->dev_stat)
  80086b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80086e:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  800872:	74 2c                	je     8008a0 <fstat+0x6a>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  800874:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  800877:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80087e:	00 00 00 
	stat->st_isdir = 0;
  800881:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  800888:	00 00 00 
	stat->st_dev = dev;
  80088b:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  800891:	83 ec 08             	sub    $0x8,%esp
  800894:	53                   	push   %ebx
  800895:	ff 75 f0             	pushl  -0x10(%ebp)
  800898:	ff 50 14             	call   *0x14(%eax)
  80089b:	83 c4 10             	add    $0x10,%esp
  80089e:	eb 05                	jmp    8008a5 <fstat+0x6f>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8008a0:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8008a5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8008a8:	c9                   	leave  
  8008a9:	c3                   	ret    

008008aa <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8008aa:	55                   	push   %ebp
  8008ab:	89 e5                	mov    %esp,%ebp
  8008ad:	56                   	push   %esi
  8008ae:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8008af:	83 ec 08             	sub    $0x8,%esp
  8008b2:	6a 00                	push   $0x0
  8008b4:	ff 75 08             	pushl  0x8(%ebp)
  8008b7:	e8 78 01 00 00       	call   800a34 <open>
  8008bc:	89 c3                	mov    %eax,%ebx
  8008be:	83 c4 10             	add    $0x10,%esp
  8008c1:	85 c0                	test   %eax,%eax
  8008c3:	78 1b                	js     8008e0 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8008c5:	83 ec 08             	sub    $0x8,%esp
  8008c8:	ff 75 0c             	pushl  0xc(%ebp)
  8008cb:	50                   	push   %eax
  8008cc:	e8 65 ff ff ff       	call   800836 <fstat>
  8008d1:	89 c6                	mov    %eax,%esi
	close(fd);
  8008d3:	89 1c 24             	mov    %ebx,(%esp)
  8008d6:	e8 18 fc ff ff       	call   8004f3 <close>
	return r;
  8008db:	83 c4 10             	add    $0x10,%esp
  8008de:	89 f3                	mov    %esi,%ebx
}
  8008e0:	89 d8                	mov    %ebx,%eax
  8008e2:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8008e5:	5b                   	pop    %ebx
  8008e6:	5e                   	pop    %esi
  8008e7:	c9                   	leave  
  8008e8:	c3                   	ret    
  8008e9:	00 00                	add    %al,(%eax)
	...

008008ec <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8008ec:	55                   	push   %ebp
  8008ed:	89 e5                	mov    %esp,%ebp
  8008ef:	56                   	push   %esi
  8008f0:	53                   	push   %ebx
  8008f1:	89 c3                	mov    %eax,%ebx
  8008f3:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  8008f5:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8008fc:	75 12                	jne    800910 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8008fe:	83 ec 0c             	sub    $0xc,%esp
  800901:	6a 01                	push   $0x1
  800903:	e8 96 11 00 00       	call   801a9e <ipc_find_env>
  800908:	a3 00 40 80 00       	mov    %eax,0x804000
  80090d:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  800910:	6a 07                	push   $0x7
  800912:	68 00 50 80 00       	push   $0x805000
  800917:	53                   	push   %ebx
  800918:	ff 35 00 40 80 00    	pushl  0x804000
  80091e:	e8 26 11 00 00       	call   801a49 <ipc_send>
	
	return ipc_recv(NULL, dstva, NULL);
  800923:	83 c4 0c             	add    $0xc,%esp
  800926:	6a 00                	push   $0x0
  800928:	56                   	push   %esi
  800929:	6a 00                	push   $0x0
  80092b:	e8 a4 10 00 00       	call   8019d4 <ipc_recv>
}
  800930:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800933:	5b                   	pop    %ebx
  800934:	5e                   	pop    %esi
  800935:	c9                   	leave  
  800936:	c3                   	ret    

00800937 <devfile_stat>:
}


static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  800937:	55                   	push   %ebp
  800938:	89 e5                	mov    %esp,%ebp
  80093a:	53                   	push   %ebx
  80093b:	83 ec 04             	sub    $0x4,%esp
  80093e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  800941:	8b 45 08             	mov    0x8(%ebp),%eax
  800944:	8b 40 0c             	mov    0xc(%eax),%eax
  800947:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0) {
  80094c:	ba 00 00 00 00       	mov    $0x0,%edx
  800951:	b8 05 00 00 00       	mov    $0x5,%eax
  800956:	e8 91 ff ff ff       	call   8008ec <fsipc>
  80095b:	85 c0                	test   %eax,%eax
  80095d:	78 2c                	js     80098b <devfile_stat+0x54>
		return r;
	}
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  80095f:	83 ec 08             	sub    $0x8,%esp
  800962:	68 00 50 80 00       	push   $0x805000
  800967:	53                   	push   %ebx
  800968:	e8 e9 0c 00 00       	call   801656 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  80096d:	a1 80 50 80 00       	mov    0x805080,%eax
  800972:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  800978:	a1 84 50 80 00       	mov    0x805084,%eax
  80097d:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  800983:	83 c4 10             	add    $0x10,%esp
  800986:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80098b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80098e:	c9                   	leave  
  80098f:	c3                   	ret    

00800990 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  800990:	55                   	push   %ebp
  800991:	89 e5                	mov    %esp,%ebp
  800993:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  800996:	8b 45 08             	mov    0x8(%ebp),%eax
  800999:	8b 40 0c             	mov    0xc(%eax),%eax
  80099c:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8009a1:	ba 00 00 00 00       	mov    $0x0,%edx
  8009a6:	b8 06 00 00 00       	mov    $0x6,%eax
  8009ab:	e8 3c ff ff ff       	call   8008ec <fsipc>
}
  8009b0:	c9                   	leave  
  8009b1:	c3                   	ret    

008009b2 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  8009b2:	55                   	push   %ebp
  8009b3:	89 e5                	mov    %esp,%ebp
  8009b5:	56                   	push   %esi
  8009b6:	53                   	push   %ebx
  8009b7:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8009ba:	8b 45 08             	mov    0x8(%ebp),%eax
  8009bd:	8b 40 0c             	mov    0xc(%eax),%eax
  8009c0:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  8009c5:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8009cb:	ba 00 00 00 00       	mov    $0x0,%edx
  8009d0:	b8 03 00 00 00       	mov    $0x3,%eax
  8009d5:	e8 12 ff ff ff       	call   8008ec <fsipc>
  8009da:	89 c3                	mov    %eax,%ebx
  8009dc:	85 c0                	test   %eax,%eax
  8009de:	78 4b                	js     800a2b <devfile_read+0x79>
		return r;
	assert(r <= n);
  8009e0:	39 c6                	cmp    %eax,%esi
  8009e2:	73 16                	jae    8009fa <devfile_read+0x48>
  8009e4:	68 64 1e 80 00       	push   $0x801e64
  8009e9:	68 6b 1e 80 00       	push   $0x801e6b
  8009ee:	6a 7d                	push   $0x7d
  8009f0:	68 80 1e 80 00       	push   $0x801e80
  8009f5:	e8 ce 05 00 00       	call   800fc8 <_panic>
	assert(r <= PGSIZE);
  8009fa:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8009ff:	7e 16                	jle    800a17 <devfile_read+0x65>
  800a01:	68 8b 1e 80 00       	push   $0x801e8b
  800a06:	68 6b 1e 80 00       	push   $0x801e6b
  800a0b:	6a 7e                	push   $0x7e
  800a0d:	68 80 1e 80 00       	push   $0x801e80
  800a12:	e8 b1 05 00 00       	call   800fc8 <_panic>
	memmove(buf, &fsipcbuf, r);
  800a17:	83 ec 04             	sub    $0x4,%esp
  800a1a:	50                   	push   %eax
  800a1b:	68 00 50 80 00       	push   $0x805000
  800a20:	ff 75 0c             	pushl  0xc(%ebp)
  800a23:	e8 ef 0d 00 00       	call   801817 <memmove>
	return r;
  800a28:	83 c4 10             	add    $0x10,%esp
}
  800a2b:	89 d8                	mov    %ebx,%eax
  800a2d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800a30:	5b                   	pop    %ebx
  800a31:	5e                   	pop    %esi
  800a32:	c9                   	leave  
  800a33:	c3                   	ret    

00800a34 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  800a34:	55                   	push   %ebp
  800a35:	89 e5                	mov    %esp,%ebp
  800a37:	56                   	push   %esi
  800a38:	53                   	push   %ebx
  800a39:	83 ec 1c             	sub    $0x1c,%esp
  800a3c:	8b 75 08             	mov    0x8(%ebp),%esi
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  800a3f:	56                   	push   %esi
  800a40:	e8 bf 0b 00 00       	call   801604 <strlen>
  800a45:	83 c4 10             	add    $0x10,%esp
  800a48:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  800a4d:	7f 65                	jg     800ab4 <open+0x80>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800a4f:	83 ec 0c             	sub    $0xc,%esp
  800a52:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800a55:	50                   	push   %eax
  800a56:	e8 e1 f8 ff ff       	call   80033c <fd_alloc>
  800a5b:	89 c3                	mov    %eax,%ebx
  800a5d:	83 c4 10             	add    $0x10,%esp
  800a60:	85 c0                	test   %eax,%eax
  800a62:	78 55                	js     800ab9 <open+0x85>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  800a64:	83 ec 08             	sub    $0x8,%esp
  800a67:	56                   	push   %esi
  800a68:	68 00 50 80 00       	push   $0x805000
  800a6d:	e8 e4 0b 00 00       	call   801656 <strcpy>
	fsipcbuf.open.req_omode = mode;
  800a72:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a75:	a3 00 54 80 00       	mov    %eax,0x805400



	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  800a7a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800a7d:	b8 01 00 00 00       	mov    $0x1,%eax
  800a82:	e8 65 fe ff ff       	call   8008ec <fsipc>
  800a87:	89 c3                	mov    %eax,%ebx
  800a89:	83 c4 10             	add    $0x10,%esp
  800a8c:	85 c0                	test   %eax,%eax
  800a8e:	79 12                	jns    800aa2 <open+0x6e>
		fd_close(fd, 0);
  800a90:	83 ec 08             	sub    $0x8,%esp
  800a93:	6a 00                	push   $0x0
  800a95:	ff 75 f4             	pushl  -0xc(%ebp)
  800a98:	e8 ce f9 ff ff       	call   80046b <fd_close>
		return r;
  800a9d:	83 c4 10             	add    $0x10,%esp
  800aa0:	eb 17                	jmp    800ab9 <open+0x85>
	}

	return fd2num(fd);
  800aa2:	83 ec 0c             	sub    $0xc,%esp
  800aa5:	ff 75 f4             	pushl  -0xc(%ebp)
  800aa8:	e8 67 f8 ff ff       	call   800314 <fd2num>
  800aad:	89 c3                	mov    %eax,%ebx
  800aaf:	83 c4 10             	add    $0x10,%esp
  800ab2:	eb 05                	jmp    800ab9 <open+0x85>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  800ab4:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  800ab9:	89 d8                	mov    %ebx,%eax
  800abb:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800abe:	5b                   	pop    %ebx
  800abf:	5e                   	pop    %esi
  800ac0:	c9                   	leave  
  800ac1:	c3                   	ret    
	...

00800ac4 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  800ac4:	55                   	push   %ebp
  800ac5:	89 e5                	mov    %esp,%ebp
  800ac7:	56                   	push   %esi
  800ac8:	53                   	push   %ebx
  800ac9:	8b 75 0c             	mov    0xc(%ebp),%esi
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  800acc:	83 ec 0c             	sub    $0xc,%esp
  800acf:	ff 75 08             	pushl  0x8(%ebp)
  800ad2:	e8 4d f8 ff ff       	call   800324 <fd2data>
  800ad7:	89 c3                	mov    %eax,%ebx
	strcpy(stat->st_name, "<pipe>");
  800ad9:	83 c4 08             	add    $0x8,%esp
  800adc:	68 97 1e 80 00       	push   $0x801e97
  800ae1:	56                   	push   %esi
  800ae2:	e8 6f 0b 00 00       	call   801656 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  800ae7:	8b 43 04             	mov    0x4(%ebx),%eax
  800aea:	2b 03                	sub    (%ebx),%eax
  800aec:	89 86 80 00 00 00    	mov    %eax,0x80(%esi)
	stat->st_isdir = 0;
  800af2:	c7 86 84 00 00 00 00 	movl   $0x0,0x84(%esi)
  800af9:	00 00 00 
	stat->st_dev = &devpipe;
  800afc:	c7 86 88 00 00 00 20 	movl   $0x803020,0x88(%esi)
  800b03:	30 80 00 
	return 0;
}
  800b06:	b8 00 00 00 00       	mov    $0x0,%eax
  800b0b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800b0e:	5b                   	pop    %ebx
  800b0f:	5e                   	pop    %esi
  800b10:	c9                   	leave  
  800b11:	c3                   	ret    

00800b12 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  800b12:	55                   	push   %ebp
  800b13:	89 e5                	mov    %esp,%ebp
  800b15:	53                   	push   %ebx
  800b16:	83 ec 0c             	sub    $0xc,%esp
  800b19:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  800b1c:	53                   	push   %ebx
  800b1d:	6a 00                	push   $0x0
  800b1f:	e8 d2 f6 ff ff       	call   8001f6 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  800b24:	89 1c 24             	mov    %ebx,(%esp)
  800b27:	e8 f8 f7 ff ff       	call   800324 <fd2data>
  800b2c:	83 c4 08             	add    $0x8,%esp
  800b2f:	50                   	push   %eax
  800b30:	6a 00                	push   $0x0
  800b32:	e8 bf f6 ff ff       	call   8001f6 <sys_page_unmap>
}
  800b37:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800b3a:	c9                   	leave  
  800b3b:	c3                   	ret    

00800b3c <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  800b3c:	55                   	push   %ebp
  800b3d:	89 e5                	mov    %esp,%ebp
  800b3f:	57                   	push   %edi
  800b40:	56                   	push   %esi
  800b41:	53                   	push   %ebx
  800b42:	83 ec 1c             	sub    $0x1c,%esp
  800b45:	89 c7                	mov    %eax,%edi
  800b47:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  800b4a:	a1 04 40 80 00       	mov    0x804004,%eax
  800b4f:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  800b52:	83 ec 0c             	sub    $0xc,%esp
  800b55:	57                   	push   %edi
  800b56:	e8 a1 0f 00 00       	call   801afc <pageref>
  800b5b:	89 c6                	mov    %eax,%esi
  800b5d:	83 c4 04             	add    $0x4,%esp
  800b60:	ff 75 e4             	pushl  -0x1c(%ebp)
  800b63:	e8 94 0f 00 00       	call   801afc <pageref>
  800b68:	83 c4 10             	add    $0x10,%esp
  800b6b:	39 c6                	cmp    %eax,%esi
  800b6d:	0f 94 c0             	sete   %al
  800b70:	0f b6 c0             	movzbl %al,%eax
		nn = thisenv->env_runs;
  800b73:	8b 15 04 40 80 00    	mov    0x804004,%edx
  800b79:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  800b7c:	39 cb                	cmp    %ecx,%ebx
  800b7e:	75 08                	jne    800b88 <_pipeisclosed+0x4c>
			return ret;
		if (n != nn && ret == 1)
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
	}
}
  800b80:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b83:	5b                   	pop    %ebx
  800b84:	5e                   	pop    %esi
  800b85:	5f                   	pop    %edi
  800b86:	c9                   	leave  
  800b87:	c3                   	ret    
		n = thisenv->env_runs;
		ret = pageref(fd) == pageref(p);
		nn = thisenv->env_runs;
		if (n == nn)
			return ret;
		if (n != nn && ret == 1)
  800b88:	83 f8 01             	cmp    $0x1,%eax
  800b8b:	75 bd                	jne    800b4a <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  800b8d:	8b 42 58             	mov    0x58(%edx),%eax
  800b90:	6a 01                	push   $0x1
  800b92:	50                   	push   %eax
  800b93:	53                   	push   %ebx
  800b94:	68 9e 1e 80 00       	push   $0x801e9e
  800b99:	e8 02 05 00 00       	call   8010a0 <cprintf>
  800b9e:	83 c4 10             	add    $0x10,%esp
  800ba1:	eb a7                	jmp    800b4a <_pipeisclosed+0xe>

00800ba3 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  800ba3:	55                   	push   %ebp
  800ba4:	89 e5                	mov    %esp,%ebp
  800ba6:	57                   	push   %edi
  800ba7:	56                   	push   %esi
  800ba8:	53                   	push   %ebx
  800ba9:	83 ec 28             	sub    $0x28,%esp
  800bac:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  800baf:	56                   	push   %esi
  800bb0:	e8 6f f7 ff ff       	call   800324 <fd2data>
  800bb5:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800bb7:	83 c4 10             	add    $0x10,%esp
  800bba:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800bbe:	75 4a                	jne    800c0a <devpipe_write+0x67>
  800bc0:	bf 00 00 00 00       	mov    $0x0,%edi
  800bc5:	eb 56                	jmp    800c1d <devpipe_write+0x7a>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  800bc7:	89 da                	mov    %ebx,%edx
  800bc9:	89 f0                	mov    %esi,%eax
  800bcb:	e8 6c ff ff ff       	call   800b3c <_pipeisclosed>
  800bd0:	85 c0                	test   %eax,%eax
  800bd2:	75 4d                	jne    800c21 <devpipe_write+0x7e>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  800bd4:	e8 ac f5 ff ff       	call   800185 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  800bd9:	8b 43 04             	mov    0x4(%ebx),%eax
  800bdc:	8b 13                	mov    (%ebx),%edx
  800bde:	83 c2 20             	add    $0x20,%edx
  800be1:	39 d0                	cmp    %edx,%eax
  800be3:	73 e2                	jae    800bc7 <devpipe_write+0x24>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  800be5:	89 c2                	mov    %eax,%edx
  800be7:	81 e2 1f 00 00 80    	and    $0x8000001f,%edx
  800bed:	79 05                	jns    800bf4 <devpipe_write+0x51>
  800bef:	4a                   	dec    %edx
  800bf0:	83 ca e0             	or     $0xffffffe0,%edx
  800bf3:	42                   	inc    %edx
  800bf4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bf7:	8a 0c 39             	mov    (%ecx,%edi,1),%cl
  800bfa:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  800bfe:	40                   	inc    %eax
  800bff:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800c02:	47                   	inc    %edi
  800c03:	39 7d 10             	cmp    %edi,0x10(%ebp)
  800c06:	77 07                	ja     800c0f <devpipe_write+0x6c>
  800c08:	eb 13                	jmp    800c1d <devpipe_write+0x7a>
  800c0a:	bf 00 00 00 00       	mov    $0x0,%edi
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  800c0f:	8b 43 04             	mov    0x4(%ebx),%eax
  800c12:	8b 13                	mov    (%ebx),%edx
  800c14:	83 c2 20             	add    $0x20,%edx
  800c17:	39 d0                	cmp    %edx,%eax
  800c19:	73 ac                	jae    800bc7 <devpipe_write+0x24>
  800c1b:	eb c8                	jmp    800be5 <devpipe_write+0x42>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  800c1d:	89 f8                	mov    %edi,%eax
  800c1f:	eb 05                	jmp    800c26 <devpipe_write+0x83>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  800c21:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  800c26:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c29:	5b                   	pop    %ebx
  800c2a:	5e                   	pop    %esi
  800c2b:	5f                   	pop    %edi
  800c2c:	c9                   	leave  
  800c2d:	c3                   	ret    

00800c2e <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  800c2e:	55                   	push   %ebp
  800c2f:	89 e5                	mov    %esp,%ebp
  800c31:	57                   	push   %edi
  800c32:	56                   	push   %esi
  800c33:	53                   	push   %ebx
  800c34:	83 ec 18             	sub    $0x18,%esp
  800c37:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  800c3a:	57                   	push   %edi
  800c3b:	e8 e4 f6 ff ff       	call   800324 <fd2data>
  800c40:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800c42:	83 c4 10             	add    $0x10,%esp
  800c45:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800c49:	75 44                	jne    800c8f <devpipe_read+0x61>
  800c4b:	be 00 00 00 00       	mov    $0x0,%esi
  800c50:	eb 4f                	jmp    800ca1 <devpipe_read+0x73>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
				return i;
  800c52:	89 f0                	mov    %esi,%eax
  800c54:	eb 54                	jmp    800caa <devpipe_read+0x7c>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  800c56:	89 da                	mov    %ebx,%edx
  800c58:	89 f8                	mov    %edi,%eax
  800c5a:	e8 dd fe ff ff       	call   800b3c <_pipeisclosed>
  800c5f:	85 c0                	test   %eax,%eax
  800c61:	75 42                	jne    800ca5 <devpipe_read+0x77>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  800c63:	e8 1d f5 ff ff       	call   800185 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  800c68:	8b 03                	mov    (%ebx),%eax
  800c6a:	3b 43 04             	cmp    0x4(%ebx),%eax
  800c6d:	74 e7                	je     800c56 <devpipe_read+0x28>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  800c6f:	25 1f 00 00 80       	and    $0x8000001f,%eax
  800c74:	79 05                	jns    800c7b <devpipe_read+0x4d>
  800c76:	48                   	dec    %eax
  800c77:	83 c8 e0             	or     $0xffffffe0,%eax
  800c7a:	40                   	inc    %eax
  800c7b:	8a 44 03 08          	mov    0x8(%ebx,%eax,1),%al
  800c7f:	8b 55 0c             	mov    0xc(%ebp),%edx
  800c82:	88 04 32             	mov    %al,(%edx,%esi,1)
		p->p_rpos++;
  800c85:	ff 03                	incl   (%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800c87:	46                   	inc    %esi
  800c88:	39 75 10             	cmp    %esi,0x10(%ebp)
  800c8b:	77 07                	ja     800c94 <devpipe_read+0x66>
  800c8d:	eb 12                	jmp    800ca1 <devpipe_read+0x73>
  800c8f:	be 00 00 00 00       	mov    $0x0,%esi
		while (p->p_rpos == p->p_wpos) {
  800c94:	8b 03                	mov    (%ebx),%eax
  800c96:	3b 43 04             	cmp    0x4(%ebx),%eax
  800c99:	75 d4                	jne    800c6f <devpipe_read+0x41>
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  800c9b:	85 f6                	test   %esi,%esi
  800c9d:	75 b3                	jne    800c52 <devpipe_read+0x24>
  800c9f:	eb b5                	jmp    800c56 <devpipe_read+0x28>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  800ca1:	89 f0                	mov    %esi,%eax
  800ca3:	eb 05                	jmp    800caa <devpipe_read+0x7c>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  800ca5:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  800caa:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cad:	5b                   	pop    %ebx
  800cae:	5e                   	pop    %esi
  800caf:	5f                   	pop    %edi
  800cb0:	c9                   	leave  
  800cb1:	c3                   	ret    

00800cb2 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  800cb2:	55                   	push   %ebp
  800cb3:	89 e5                	mov    %esp,%ebp
  800cb5:	57                   	push   %edi
  800cb6:	56                   	push   %esi
  800cb7:	53                   	push   %ebx
  800cb8:	83 ec 28             	sub    $0x28,%esp
  800cbb:	8b 7d 08             	mov    0x8(%ebp),%edi
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  800cbe:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800cc1:	50                   	push   %eax
  800cc2:	e8 75 f6 ff ff       	call   80033c <fd_alloc>
  800cc7:	89 c3                	mov    %eax,%ebx
  800cc9:	83 c4 10             	add    $0x10,%esp
  800ccc:	85 c0                	test   %eax,%eax
  800cce:	0f 88 24 01 00 00    	js     800df8 <pipe+0x146>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800cd4:	83 ec 04             	sub    $0x4,%esp
  800cd7:	68 07 04 00 00       	push   $0x407
  800cdc:	ff 75 e4             	pushl  -0x1c(%ebp)
  800cdf:	6a 00                	push   $0x0
  800ce1:	e8 c6 f4 ff ff       	call   8001ac <sys_page_alloc>
  800ce6:	89 c3                	mov    %eax,%ebx
  800ce8:	83 c4 10             	add    $0x10,%esp
  800ceb:	85 c0                	test   %eax,%eax
  800ced:	0f 88 05 01 00 00    	js     800df8 <pipe+0x146>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  800cf3:	83 ec 0c             	sub    $0xc,%esp
  800cf6:	8d 45 e0             	lea    -0x20(%ebp),%eax
  800cf9:	50                   	push   %eax
  800cfa:	e8 3d f6 ff ff       	call   80033c <fd_alloc>
  800cff:	89 c3                	mov    %eax,%ebx
  800d01:	83 c4 10             	add    $0x10,%esp
  800d04:	85 c0                	test   %eax,%eax
  800d06:	0f 88 dc 00 00 00    	js     800de8 <pipe+0x136>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800d0c:	83 ec 04             	sub    $0x4,%esp
  800d0f:	68 07 04 00 00       	push   $0x407
  800d14:	ff 75 e0             	pushl  -0x20(%ebp)
  800d17:	6a 00                	push   $0x0
  800d19:	e8 8e f4 ff ff       	call   8001ac <sys_page_alloc>
  800d1e:	89 c3                	mov    %eax,%ebx
  800d20:	83 c4 10             	add    $0x10,%esp
  800d23:	85 c0                	test   %eax,%eax
  800d25:	0f 88 bd 00 00 00    	js     800de8 <pipe+0x136>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  800d2b:	83 ec 0c             	sub    $0xc,%esp
  800d2e:	ff 75 e4             	pushl  -0x1c(%ebp)
  800d31:	e8 ee f5 ff ff       	call   800324 <fd2data>
  800d36:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800d38:	83 c4 0c             	add    $0xc,%esp
  800d3b:	68 07 04 00 00       	push   $0x407
  800d40:	50                   	push   %eax
  800d41:	6a 00                	push   $0x0
  800d43:	e8 64 f4 ff ff       	call   8001ac <sys_page_alloc>
  800d48:	89 c3                	mov    %eax,%ebx
  800d4a:	83 c4 10             	add    $0x10,%esp
  800d4d:	85 c0                	test   %eax,%eax
  800d4f:	0f 88 83 00 00 00    	js     800dd8 <pipe+0x126>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800d55:	83 ec 0c             	sub    $0xc,%esp
  800d58:	ff 75 e0             	pushl  -0x20(%ebp)
  800d5b:	e8 c4 f5 ff ff       	call   800324 <fd2data>
  800d60:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  800d67:	50                   	push   %eax
  800d68:	6a 00                	push   $0x0
  800d6a:	56                   	push   %esi
  800d6b:	6a 00                	push   $0x0
  800d6d:	e8 5e f4 ff ff       	call   8001d0 <sys_page_map>
  800d72:	89 c3                	mov    %eax,%ebx
  800d74:	83 c4 20             	add    $0x20,%esp
  800d77:	85 c0                	test   %eax,%eax
  800d79:	78 4f                	js     800dca <pipe+0x118>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  800d7b:	8b 15 20 30 80 00    	mov    0x803020,%edx
  800d81:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800d84:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  800d86:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800d89:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  800d90:	8b 15 20 30 80 00    	mov    0x803020,%edx
  800d96:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800d99:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  800d9b:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800d9e:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  800da5:	83 ec 0c             	sub    $0xc,%esp
  800da8:	ff 75 e4             	pushl  -0x1c(%ebp)
  800dab:	e8 64 f5 ff ff       	call   800314 <fd2num>
  800db0:	89 07                	mov    %eax,(%edi)
	pfd[1] = fd2num(fd1);
  800db2:	83 c4 04             	add    $0x4,%esp
  800db5:	ff 75 e0             	pushl  -0x20(%ebp)
  800db8:	e8 57 f5 ff ff       	call   800314 <fd2num>
  800dbd:	89 47 04             	mov    %eax,0x4(%edi)
	return 0;
  800dc0:	83 c4 10             	add    $0x10,%esp
  800dc3:	bb 00 00 00 00       	mov    $0x0,%ebx
  800dc8:	eb 2e                	jmp    800df8 <pipe+0x146>

    err3:
	sys_page_unmap(0, va);
  800dca:	83 ec 08             	sub    $0x8,%esp
  800dcd:	56                   	push   %esi
  800dce:	6a 00                	push   $0x0
  800dd0:	e8 21 f4 ff ff       	call   8001f6 <sys_page_unmap>
  800dd5:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  800dd8:	83 ec 08             	sub    $0x8,%esp
  800ddb:	ff 75 e0             	pushl  -0x20(%ebp)
  800dde:	6a 00                	push   $0x0
  800de0:	e8 11 f4 ff ff       	call   8001f6 <sys_page_unmap>
  800de5:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  800de8:	83 ec 08             	sub    $0x8,%esp
  800deb:	ff 75 e4             	pushl  -0x1c(%ebp)
  800dee:	6a 00                	push   $0x0
  800df0:	e8 01 f4 ff ff       	call   8001f6 <sys_page_unmap>
  800df5:	83 c4 10             	add    $0x10,%esp
    err:
	return r;
}
  800df8:	89 d8                	mov    %ebx,%eax
  800dfa:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800dfd:	5b                   	pop    %ebx
  800dfe:	5e                   	pop    %esi
  800dff:	5f                   	pop    %edi
  800e00:	c9                   	leave  
  800e01:	c3                   	ret    

00800e02 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  800e02:	55                   	push   %ebp
  800e03:	89 e5                	mov    %esp,%ebp
  800e05:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800e08:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800e0b:	50                   	push   %eax
  800e0c:	ff 75 08             	pushl  0x8(%ebp)
  800e0f:	e8 9b f5 ff ff       	call   8003af <fd_lookup>
  800e14:	83 c4 10             	add    $0x10,%esp
  800e17:	85 c0                	test   %eax,%eax
  800e19:	78 18                	js     800e33 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  800e1b:	83 ec 0c             	sub    $0xc,%esp
  800e1e:	ff 75 f4             	pushl  -0xc(%ebp)
  800e21:	e8 fe f4 ff ff       	call   800324 <fd2data>
	return _pipeisclosed(fd, p);
  800e26:	89 c2                	mov    %eax,%edx
  800e28:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800e2b:	e8 0c fd ff ff       	call   800b3c <_pipeisclosed>
  800e30:	83 c4 10             	add    $0x10,%esp
}
  800e33:	c9                   	leave  
  800e34:	c3                   	ret    
  800e35:	00 00                	add    %al,(%eax)
	...

00800e38 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  800e38:	55                   	push   %ebp
  800e39:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  800e3b:	b8 00 00 00 00       	mov    $0x0,%eax
  800e40:	c9                   	leave  
  800e41:	c3                   	ret    

00800e42 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  800e42:	55                   	push   %ebp
  800e43:	89 e5                	mov    %esp,%ebp
  800e45:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  800e48:	68 b6 1e 80 00       	push   $0x801eb6
  800e4d:	ff 75 0c             	pushl  0xc(%ebp)
  800e50:	e8 01 08 00 00       	call   801656 <strcpy>
	return 0;
}
  800e55:	b8 00 00 00 00       	mov    $0x0,%eax
  800e5a:	c9                   	leave  
  800e5b:	c3                   	ret    

00800e5c <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  800e5c:	55                   	push   %ebp
  800e5d:	89 e5                	mov    %esp,%ebp
  800e5f:	57                   	push   %edi
  800e60:	56                   	push   %esi
  800e61:	53                   	push   %ebx
  800e62:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800e68:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800e6c:	74 45                	je     800eb3 <devcons_write+0x57>
  800e6e:	b8 00 00 00 00       	mov    $0x0,%eax
  800e73:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  800e78:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  800e7e:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e81:	29 c3                	sub    %eax,%ebx
		if (m > sizeof(buf) - 1)
  800e83:	83 fb 7f             	cmp    $0x7f,%ebx
  800e86:	76 05                	jbe    800e8d <devcons_write+0x31>
			m = sizeof(buf) - 1;
  800e88:	bb 7f 00 00 00       	mov    $0x7f,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  800e8d:	83 ec 04             	sub    $0x4,%esp
  800e90:	53                   	push   %ebx
  800e91:	03 45 0c             	add    0xc(%ebp),%eax
  800e94:	50                   	push   %eax
  800e95:	57                   	push   %edi
  800e96:	e8 7c 09 00 00       	call   801817 <memmove>
		sys_cputs(buf, m);
  800e9b:	83 c4 08             	add    $0x8,%esp
  800e9e:	53                   	push   %ebx
  800e9f:	57                   	push   %edi
  800ea0:	e8 50 f2 ff ff       	call   8000f5 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800ea5:	01 de                	add    %ebx,%esi
  800ea7:	89 f0                	mov    %esi,%eax
  800ea9:	83 c4 10             	add    $0x10,%esp
  800eac:	3b 75 10             	cmp    0x10(%ebp),%esi
  800eaf:	72 cd                	jb     800e7e <devcons_write+0x22>
  800eb1:	eb 05                	jmp    800eb8 <devcons_write+0x5c>
  800eb3:	be 00 00 00 00       	mov    $0x0,%esi
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  800eb8:	89 f0                	mov    %esi,%eax
  800eba:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ebd:	5b                   	pop    %ebx
  800ebe:	5e                   	pop    %esi
  800ebf:	5f                   	pop    %edi
  800ec0:	c9                   	leave  
  800ec1:	c3                   	ret    

00800ec2 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  800ec2:	55                   	push   %ebp
  800ec3:	89 e5                	mov    %esp,%ebp
  800ec5:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
  800ec8:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800ecc:	75 07                	jne    800ed5 <devcons_read+0x13>
  800ece:	eb 25                	jmp    800ef5 <devcons_read+0x33>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  800ed0:	e8 b0 f2 ff ff       	call   800185 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  800ed5:	e8 41 f2 ff ff       	call   80011b <sys_cgetc>
  800eda:	85 c0                	test   %eax,%eax
  800edc:	74 f2                	je     800ed0 <devcons_read+0xe>
  800ede:	89 c2                	mov    %eax,%edx
		sys_yield();
	if (c < 0)
  800ee0:	85 c0                	test   %eax,%eax
  800ee2:	78 1d                	js     800f01 <devcons_read+0x3f>
		return c;
	if (c == 0x04)	// ctl-d is eof
  800ee4:	83 f8 04             	cmp    $0x4,%eax
  800ee7:	74 13                	je     800efc <devcons_read+0x3a>
		return 0;
	*(char*)vbuf = c;
  800ee9:	8b 45 0c             	mov    0xc(%ebp),%eax
  800eec:	88 10                	mov    %dl,(%eax)
	return 1;
  800eee:	b8 01 00 00 00       	mov    $0x1,%eax
  800ef3:	eb 0c                	jmp    800f01 <devcons_read+0x3f>
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
		return 0;
  800ef5:	b8 00 00 00 00       	mov    $0x0,%eax
  800efa:	eb 05                	jmp    800f01 <devcons_read+0x3f>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  800efc:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  800f01:	c9                   	leave  
  800f02:	c3                   	ret    

00800f03 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  800f03:	55                   	push   %ebp
  800f04:	89 e5                	mov    %esp,%ebp
  800f06:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  800f09:	8b 45 08             	mov    0x8(%ebp),%eax
  800f0c:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  800f0f:	6a 01                	push   $0x1
  800f11:	8d 45 f7             	lea    -0x9(%ebp),%eax
  800f14:	50                   	push   %eax
  800f15:	e8 db f1 ff ff       	call   8000f5 <sys_cputs>
  800f1a:	83 c4 10             	add    $0x10,%esp
}
  800f1d:	c9                   	leave  
  800f1e:	c3                   	ret    

00800f1f <getchar>:

int
getchar(void)
{
  800f1f:	55                   	push   %ebp
  800f20:	89 e5                	mov    %esp,%ebp
  800f22:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  800f25:	6a 01                	push   $0x1
  800f27:	8d 45 f7             	lea    -0x9(%ebp),%eax
  800f2a:	50                   	push   %eax
  800f2b:	6a 00                	push   $0x0
  800f2d:	e8 fe f6 ff ff       	call   800630 <read>
	if (r < 0)
  800f32:	83 c4 10             	add    $0x10,%esp
  800f35:	85 c0                	test   %eax,%eax
  800f37:	78 0f                	js     800f48 <getchar+0x29>
		return r;
	if (r < 1)
  800f39:	85 c0                	test   %eax,%eax
  800f3b:	7e 06                	jle    800f43 <getchar+0x24>
		return -E_EOF;
	return c;
  800f3d:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  800f41:	eb 05                	jmp    800f48 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  800f43:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  800f48:	c9                   	leave  
  800f49:	c3                   	ret    

00800f4a <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  800f4a:	55                   	push   %ebp
  800f4b:	89 e5                	mov    %esp,%ebp
  800f4d:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800f50:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800f53:	50                   	push   %eax
  800f54:	ff 75 08             	pushl  0x8(%ebp)
  800f57:	e8 53 f4 ff ff       	call   8003af <fd_lookup>
  800f5c:	83 c4 10             	add    $0x10,%esp
  800f5f:	85 c0                	test   %eax,%eax
  800f61:	78 11                	js     800f74 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  800f63:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800f66:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  800f6c:	39 10                	cmp    %edx,(%eax)
  800f6e:	0f 94 c0             	sete   %al
  800f71:	0f b6 c0             	movzbl %al,%eax
}
  800f74:	c9                   	leave  
  800f75:	c3                   	ret    

00800f76 <opencons>:

int
opencons(void)
{
  800f76:	55                   	push   %ebp
  800f77:	89 e5                	mov    %esp,%ebp
  800f79:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  800f7c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800f7f:	50                   	push   %eax
  800f80:	e8 b7 f3 ff ff       	call   80033c <fd_alloc>
  800f85:	83 c4 10             	add    $0x10,%esp
  800f88:	85 c0                	test   %eax,%eax
  800f8a:	78 3a                	js     800fc6 <opencons+0x50>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  800f8c:	83 ec 04             	sub    $0x4,%esp
  800f8f:	68 07 04 00 00       	push   $0x407
  800f94:	ff 75 f4             	pushl  -0xc(%ebp)
  800f97:	6a 00                	push   $0x0
  800f99:	e8 0e f2 ff ff       	call   8001ac <sys_page_alloc>
  800f9e:	83 c4 10             	add    $0x10,%esp
  800fa1:	85 c0                	test   %eax,%eax
  800fa3:	78 21                	js     800fc6 <opencons+0x50>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  800fa5:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  800fab:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800fae:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  800fb0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800fb3:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  800fba:	83 ec 0c             	sub    $0xc,%esp
  800fbd:	50                   	push   %eax
  800fbe:	e8 51 f3 ff ff       	call   800314 <fd2num>
  800fc3:	83 c4 10             	add    $0x10,%esp
}
  800fc6:	c9                   	leave  
  800fc7:	c3                   	ret    

00800fc8 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800fc8:	55                   	push   %ebp
  800fc9:	89 e5                	mov    %esp,%ebp
  800fcb:	56                   	push   %esi
  800fcc:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800fcd:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800fd0:	8b 1d 00 30 80 00    	mov    0x803000,%ebx
  800fd6:	e8 86 f1 ff ff       	call   800161 <sys_getenvid>
  800fdb:	83 ec 0c             	sub    $0xc,%esp
  800fde:	ff 75 0c             	pushl  0xc(%ebp)
  800fe1:	ff 75 08             	pushl  0x8(%ebp)
  800fe4:	53                   	push   %ebx
  800fe5:	50                   	push   %eax
  800fe6:	68 c4 1e 80 00       	push   $0x801ec4
  800feb:	e8 b0 00 00 00       	call   8010a0 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800ff0:	83 c4 18             	add    $0x18,%esp
  800ff3:	56                   	push   %esi
  800ff4:	ff 75 10             	pushl  0x10(%ebp)
  800ff7:	e8 53 00 00 00       	call   80104f <vcprintf>
	cprintf("\n");
  800ffc:	c7 04 24 af 1e 80 00 	movl   $0x801eaf,(%esp)
  801003:	e8 98 00 00 00       	call   8010a0 <cprintf>
  801008:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80100b:	cc                   	int3   
  80100c:	eb fd                	jmp    80100b <_panic+0x43>
	...

00801010 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  801010:	55                   	push   %ebp
  801011:	89 e5                	mov    %esp,%ebp
  801013:	53                   	push   %ebx
  801014:	83 ec 04             	sub    $0x4,%esp
  801017:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80101a:	8b 03                	mov    (%ebx),%eax
  80101c:	8b 55 08             	mov    0x8(%ebp),%edx
  80101f:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  801023:	40                   	inc    %eax
  801024:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  801026:	3d ff 00 00 00       	cmp    $0xff,%eax
  80102b:	75 1a                	jne    801047 <putch+0x37>
		sys_cputs(b->buf, b->idx);
  80102d:	83 ec 08             	sub    $0x8,%esp
  801030:	68 ff 00 00 00       	push   $0xff
  801035:	8d 43 08             	lea    0x8(%ebx),%eax
  801038:	50                   	push   %eax
  801039:	e8 b7 f0 ff ff       	call   8000f5 <sys_cputs>
		b->idx = 0;
  80103e:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801044:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  801047:	ff 43 04             	incl   0x4(%ebx)
}
  80104a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80104d:	c9                   	leave  
  80104e:	c3                   	ret    

0080104f <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80104f:	55                   	push   %ebp
  801050:	89 e5                	mov    %esp,%ebp
  801052:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  801058:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80105f:	00 00 00 
	b.cnt = 0;
  801062:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  801069:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80106c:	ff 75 0c             	pushl  0xc(%ebp)
  80106f:	ff 75 08             	pushl  0x8(%ebp)
  801072:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  801078:	50                   	push   %eax
  801079:	68 10 10 80 00       	push   $0x801010
  80107e:	e8 82 01 00 00       	call   801205 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  801083:	83 c4 08             	add    $0x8,%esp
  801086:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  80108c:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  801092:	50                   	push   %eax
  801093:	e8 5d f0 ff ff       	call   8000f5 <sys_cputs>

	return b.cnt;
}
  801098:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80109e:	c9                   	leave  
  80109f:	c3                   	ret    

008010a0 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8010a0:	55                   	push   %ebp
  8010a1:	89 e5                	mov    %esp,%ebp
  8010a3:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8010a6:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8010a9:	50                   	push   %eax
  8010aa:	ff 75 08             	pushl  0x8(%ebp)
  8010ad:	e8 9d ff ff ff       	call   80104f <vcprintf>
	va_end(ap);

	return cnt;
}
  8010b2:	c9                   	leave  
  8010b3:	c3                   	ret    

008010b4 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8010b4:	55                   	push   %ebp
  8010b5:	89 e5                	mov    %esp,%ebp
  8010b7:	57                   	push   %edi
  8010b8:	56                   	push   %esi
  8010b9:	53                   	push   %ebx
  8010ba:	83 ec 2c             	sub    $0x2c,%esp
  8010bd:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8010c0:	89 d6                	mov    %edx,%esi
  8010c2:	8b 45 08             	mov    0x8(%ebp),%eax
  8010c5:	8b 55 0c             	mov    0xc(%ebp),%edx
  8010c8:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8010cb:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8010ce:	8b 45 10             	mov    0x10(%ebp),%eax
  8010d1:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8010d4:	8b 7d 18             	mov    0x18(%ebp),%edi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8010d7:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8010da:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  8010e1:	39 55 d4             	cmp    %edx,-0x2c(%ebp)
  8010e4:	72 0c                	jb     8010f2 <printnum+0x3e>
  8010e6:	3b 45 d8             	cmp    -0x28(%ebp),%eax
  8010e9:	76 07                	jbe    8010f2 <printnum+0x3e>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8010eb:	4b                   	dec    %ebx
  8010ec:	85 db                	test   %ebx,%ebx
  8010ee:	7f 31                	jg     801121 <printnum+0x6d>
  8010f0:	eb 3f                	jmp    801131 <printnum+0x7d>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8010f2:	83 ec 0c             	sub    $0xc,%esp
  8010f5:	57                   	push   %edi
  8010f6:	4b                   	dec    %ebx
  8010f7:	53                   	push   %ebx
  8010f8:	50                   	push   %eax
  8010f9:	83 ec 08             	sub    $0x8,%esp
  8010fc:	ff 75 d4             	pushl  -0x2c(%ebp)
  8010ff:	ff 75 d0             	pushl  -0x30(%ebp)
  801102:	ff 75 dc             	pushl  -0x24(%ebp)
  801105:	ff 75 d8             	pushl  -0x28(%ebp)
  801108:	e8 33 0a 00 00       	call   801b40 <__udivdi3>
  80110d:	83 c4 18             	add    $0x18,%esp
  801110:	52                   	push   %edx
  801111:	50                   	push   %eax
  801112:	89 f2                	mov    %esi,%edx
  801114:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801117:	e8 98 ff ff ff       	call   8010b4 <printnum>
  80111c:	83 c4 20             	add    $0x20,%esp
  80111f:	eb 10                	jmp    801131 <printnum+0x7d>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  801121:	83 ec 08             	sub    $0x8,%esp
  801124:	56                   	push   %esi
  801125:	57                   	push   %edi
  801126:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  801129:	4b                   	dec    %ebx
  80112a:	83 c4 10             	add    $0x10,%esp
  80112d:	85 db                	test   %ebx,%ebx
  80112f:	7f f0                	jg     801121 <printnum+0x6d>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  801131:	83 ec 08             	sub    $0x8,%esp
  801134:	56                   	push   %esi
  801135:	83 ec 04             	sub    $0x4,%esp
  801138:	ff 75 d4             	pushl  -0x2c(%ebp)
  80113b:	ff 75 d0             	pushl  -0x30(%ebp)
  80113e:	ff 75 dc             	pushl  -0x24(%ebp)
  801141:	ff 75 d8             	pushl  -0x28(%ebp)
  801144:	e8 13 0b 00 00       	call   801c5c <__umoddi3>
  801149:	83 c4 14             	add    $0x14,%esp
  80114c:	0f be 80 e7 1e 80 00 	movsbl 0x801ee7(%eax),%eax
  801153:	50                   	push   %eax
  801154:	ff 55 e4             	call   *-0x1c(%ebp)
  801157:	83 c4 10             	add    $0x10,%esp
}
  80115a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80115d:	5b                   	pop    %ebx
  80115e:	5e                   	pop    %esi
  80115f:	5f                   	pop    %edi
  801160:	c9                   	leave  
  801161:	c3                   	ret    

00801162 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  801162:	55                   	push   %ebp
  801163:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  801165:	83 fa 01             	cmp    $0x1,%edx
  801168:	7e 0e                	jle    801178 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80116a:	8b 10                	mov    (%eax),%edx
  80116c:	8d 4a 08             	lea    0x8(%edx),%ecx
  80116f:	89 08                	mov    %ecx,(%eax)
  801171:	8b 02                	mov    (%edx),%eax
  801173:	8b 52 04             	mov    0x4(%edx),%edx
  801176:	eb 22                	jmp    80119a <getuint+0x38>
	else if (lflag)
  801178:	85 d2                	test   %edx,%edx
  80117a:	74 10                	je     80118c <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  80117c:	8b 10                	mov    (%eax),%edx
  80117e:	8d 4a 04             	lea    0x4(%edx),%ecx
  801181:	89 08                	mov    %ecx,(%eax)
  801183:	8b 02                	mov    (%edx),%eax
  801185:	ba 00 00 00 00       	mov    $0x0,%edx
  80118a:	eb 0e                	jmp    80119a <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  80118c:	8b 10                	mov    (%eax),%edx
  80118e:	8d 4a 04             	lea    0x4(%edx),%ecx
  801191:	89 08                	mov    %ecx,(%eax)
  801193:	8b 02                	mov    (%edx),%eax
  801195:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80119a:	c9                   	leave  
  80119b:	c3                   	ret    

0080119c <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
  80119c:	55                   	push   %ebp
  80119d:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80119f:	83 fa 01             	cmp    $0x1,%edx
  8011a2:	7e 0e                	jle    8011b2 <getint+0x16>
		return va_arg(*ap, long long);
  8011a4:	8b 10                	mov    (%eax),%edx
  8011a6:	8d 4a 08             	lea    0x8(%edx),%ecx
  8011a9:	89 08                	mov    %ecx,(%eax)
  8011ab:	8b 02                	mov    (%edx),%eax
  8011ad:	8b 52 04             	mov    0x4(%edx),%edx
  8011b0:	eb 1a                	jmp    8011cc <getint+0x30>
	else if (lflag)
  8011b2:	85 d2                	test   %edx,%edx
  8011b4:	74 0c                	je     8011c2 <getint+0x26>
		return va_arg(*ap, long);
  8011b6:	8b 10                	mov    (%eax),%edx
  8011b8:	8d 4a 04             	lea    0x4(%edx),%ecx
  8011bb:	89 08                	mov    %ecx,(%eax)
  8011bd:	8b 02                	mov    (%edx),%eax
  8011bf:	99                   	cltd   
  8011c0:	eb 0a                	jmp    8011cc <getint+0x30>
	else
		return va_arg(*ap, int);
  8011c2:	8b 10                	mov    (%eax),%edx
  8011c4:	8d 4a 04             	lea    0x4(%edx),%ecx
  8011c7:	89 08                	mov    %ecx,(%eax)
  8011c9:	8b 02                	mov    (%edx),%eax
  8011cb:	99                   	cltd   
}
  8011cc:	c9                   	leave  
  8011cd:	c3                   	ret    

008011ce <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8011ce:	55                   	push   %ebp
  8011cf:	89 e5                	mov    %esp,%ebp
  8011d1:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8011d4:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  8011d7:	8b 10                	mov    (%eax),%edx
  8011d9:	3b 50 04             	cmp    0x4(%eax),%edx
  8011dc:	73 08                	jae    8011e6 <sprintputch+0x18>
		*b->buf++ = ch;
  8011de:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8011e1:	88 0a                	mov    %cl,(%edx)
  8011e3:	42                   	inc    %edx
  8011e4:	89 10                	mov    %edx,(%eax)
}
  8011e6:	c9                   	leave  
  8011e7:	c3                   	ret    

008011e8 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8011e8:	55                   	push   %ebp
  8011e9:	89 e5                	mov    %esp,%ebp
  8011eb:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8011ee:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8011f1:	50                   	push   %eax
  8011f2:	ff 75 10             	pushl  0x10(%ebp)
  8011f5:	ff 75 0c             	pushl  0xc(%ebp)
  8011f8:	ff 75 08             	pushl  0x8(%ebp)
  8011fb:	e8 05 00 00 00       	call   801205 <vprintfmt>
	va_end(ap);
  801200:	83 c4 10             	add    $0x10,%esp
}
  801203:	c9                   	leave  
  801204:	c3                   	ret    

00801205 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  801205:	55                   	push   %ebp
  801206:	89 e5                	mov    %esp,%ebp
  801208:	57                   	push   %edi
  801209:	56                   	push   %esi
  80120a:	53                   	push   %ebx
  80120b:	83 ec 2c             	sub    $0x2c,%esp
  80120e:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801211:	8b 75 10             	mov    0x10(%ebp),%esi
  801214:	eb 13                	jmp    801229 <vprintfmt+0x24>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  801216:	85 c0                	test   %eax,%eax
  801218:	0f 84 6d 03 00 00    	je     80158b <vprintfmt+0x386>
				return;
			putch(ch, putdat);
  80121e:	83 ec 08             	sub    $0x8,%esp
  801221:	57                   	push   %edi
  801222:	50                   	push   %eax
  801223:	ff 55 08             	call   *0x8(%ebp)
  801226:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  801229:	0f b6 06             	movzbl (%esi),%eax
  80122c:	46                   	inc    %esi
  80122d:	83 f8 25             	cmp    $0x25,%eax
  801230:	75 e4                	jne    801216 <vprintfmt+0x11>
  801232:	c6 45 dc 20          	movb   $0x20,-0x24(%ebp)
  801236:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  80123d:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
  801244:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  80124b:	b9 00 00 00 00       	mov    $0x0,%ecx
  801250:	eb 28                	jmp    80127a <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801252:	89 de                	mov    %ebx,%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  801254:	c6 45 dc 2d          	movb   $0x2d,-0x24(%ebp)
  801258:	eb 20                	jmp    80127a <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80125a:	89 de                	mov    %ebx,%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  80125c:	c6 45 dc 30          	movb   $0x30,-0x24(%ebp)
  801260:	eb 18                	jmp    80127a <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801262:	89 de                	mov    %ebx,%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  801264:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  80126b:	eb 0d                	jmp    80127a <vprintfmt+0x75>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  80126d:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  801270:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801273:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80127a:	8a 06                	mov    (%esi),%al
  80127c:	0f b6 d0             	movzbl %al,%edx
  80127f:	8d 5e 01             	lea    0x1(%esi),%ebx
  801282:	83 e8 23             	sub    $0x23,%eax
  801285:	3c 55                	cmp    $0x55,%al
  801287:	0f 87 e0 02 00 00    	ja     80156d <vprintfmt+0x368>
  80128d:	0f b6 c0             	movzbl %al,%eax
  801290:	ff 24 85 20 20 80 00 	jmp    *0x802020(,%eax,4)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  801297:	83 ea 30             	sub    $0x30,%edx
  80129a:	89 55 d4             	mov    %edx,-0x2c(%ebp)
				ch = *fmt;
  80129d:	0f be 03             	movsbl (%ebx),%eax
				if (ch < '0' || ch > '9')
  8012a0:	8d 50 d0             	lea    -0x30(%eax),%edx
  8012a3:	83 fa 09             	cmp    $0x9,%edx
  8012a6:	77 44                	ja     8012ec <vprintfmt+0xe7>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8012a8:	89 de                	mov    %ebx,%esi
  8012aa:	8b 55 d4             	mov    -0x2c(%ebp),%edx
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8012ad:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
  8012ae:	8d 14 92             	lea    (%edx,%edx,4),%edx
  8012b1:	8d 54 50 d0          	lea    -0x30(%eax,%edx,2),%edx
				ch = *fmt;
  8012b5:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  8012b8:	8d 58 d0             	lea    -0x30(%eax),%ebx
  8012bb:	83 fb 09             	cmp    $0x9,%ebx
  8012be:	76 ed                	jbe    8012ad <vprintfmt+0xa8>
  8012c0:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  8012c3:	eb 29                	jmp    8012ee <vprintfmt+0xe9>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8012c5:	8b 45 14             	mov    0x14(%ebp),%eax
  8012c8:	8d 50 04             	lea    0x4(%eax),%edx
  8012cb:	89 55 14             	mov    %edx,0x14(%ebp)
  8012ce:	8b 00                	mov    (%eax),%eax
  8012d0:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8012d3:	89 de                	mov    %ebx,%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8012d5:	eb 17                	jmp    8012ee <vprintfmt+0xe9>

		case '.':
			if (width < 0)
  8012d7:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8012db:	78 85                	js     801262 <vprintfmt+0x5d>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8012dd:	89 de                	mov    %ebx,%esi
  8012df:	eb 99                	jmp    80127a <vprintfmt+0x75>
  8012e1:	89 de                	mov    %ebx,%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8012e3:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
			goto reswitch;
  8012ea:	eb 8e                	jmp    80127a <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8012ec:	89 de                	mov    %ebx,%esi
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  8012ee:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8012f2:	79 86                	jns    80127a <vprintfmt+0x75>
  8012f4:	e9 74 ff ff ff       	jmp    80126d <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8012f9:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8012fa:	89 de                	mov    %ebx,%esi
  8012fc:	e9 79 ff ff ff       	jmp    80127a <vprintfmt+0x75>
  801301:	89 5d d8             	mov    %ebx,-0x28(%ebp)
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  801304:	8b 45 14             	mov    0x14(%ebp),%eax
  801307:	8d 50 04             	lea    0x4(%eax),%edx
  80130a:	89 55 14             	mov    %edx,0x14(%ebp)
  80130d:	83 ec 08             	sub    $0x8,%esp
  801310:	57                   	push   %edi
  801311:	ff 30                	pushl  (%eax)
  801313:	ff 55 08             	call   *0x8(%ebp)
			break;
  801316:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801319:	8b 75 d8             	mov    -0x28(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  80131c:	e9 08 ff ff ff       	jmp    801229 <vprintfmt+0x24>
  801321:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// error message
		case 'e':
			err = va_arg(ap, int);
  801324:	8b 45 14             	mov    0x14(%ebp),%eax
  801327:	8d 50 04             	lea    0x4(%eax),%edx
  80132a:	89 55 14             	mov    %edx,0x14(%ebp)
  80132d:	8b 00                	mov    (%eax),%eax
  80132f:	85 c0                	test   %eax,%eax
  801331:	79 02                	jns    801335 <vprintfmt+0x130>
  801333:	f7 d8                	neg    %eax
  801335:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  801337:	83 f8 0f             	cmp    $0xf,%eax
  80133a:	7f 0b                	jg     801347 <vprintfmt+0x142>
  80133c:	8b 04 85 80 21 80 00 	mov    0x802180(,%eax,4),%eax
  801343:	85 c0                	test   %eax,%eax
  801345:	75 1a                	jne    801361 <vprintfmt+0x15c>
				printfmt(putch, putdat, "error %d", err);
  801347:	52                   	push   %edx
  801348:	68 ff 1e 80 00       	push   $0x801eff
  80134d:	57                   	push   %edi
  80134e:	ff 75 08             	pushl  0x8(%ebp)
  801351:	e8 92 fe ff ff       	call   8011e8 <printfmt>
  801356:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801359:	8b 75 d8             	mov    -0x28(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  80135c:	e9 c8 fe ff ff       	jmp    801229 <vprintfmt+0x24>
			else
				printfmt(putch, putdat, "%s", p);
  801361:	50                   	push   %eax
  801362:	68 7d 1e 80 00       	push   $0x801e7d
  801367:	57                   	push   %edi
  801368:	ff 75 08             	pushl  0x8(%ebp)
  80136b:	e8 78 fe ff ff       	call   8011e8 <printfmt>
  801370:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801373:	8b 75 d8             	mov    -0x28(%ebp),%esi
  801376:	e9 ae fe ff ff       	jmp    801229 <vprintfmt+0x24>
  80137b:	89 5d d8             	mov    %ebx,-0x28(%ebp)
  80137e:	89 de                	mov    %ebx,%esi
  801380:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  801383:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  801386:	8b 45 14             	mov    0x14(%ebp),%eax
  801389:	8d 50 04             	lea    0x4(%eax),%edx
  80138c:	89 55 14             	mov    %edx,0x14(%ebp)
  80138f:	8b 00                	mov    (%eax),%eax
  801391:	89 45 d0             	mov    %eax,-0x30(%ebp)
  801394:	85 c0                	test   %eax,%eax
  801396:	75 07                	jne    80139f <vprintfmt+0x19a>
				p = "(null)";
  801398:	c7 45 d0 f8 1e 80 00 	movl   $0x801ef8,-0x30(%ebp)
			if (width > 0 && padc != '-')
  80139f:	85 db                	test   %ebx,%ebx
  8013a1:	7e 42                	jle    8013e5 <vprintfmt+0x1e0>
  8013a3:	80 7d dc 2d          	cmpb   $0x2d,-0x24(%ebp)
  8013a7:	74 3c                	je     8013e5 <vprintfmt+0x1e0>
				for (width -= strnlen(p, precision); width > 0; width--)
  8013a9:	83 ec 08             	sub    $0x8,%esp
  8013ac:	51                   	push   %ecx
  8013ad:	ff 75 d0             	pushl  -0x30(%ebp)
  8013b0:	e8 6f 02 00 00       	call   801624 <strnlen>
  8013b5:	29 c3                	sub    %eax,%ebx
  8013b7:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8013ba:	83 c4 10             	add    $0x10,%esp
  8013bd:	85 db                	test   %ebx,%ebx
  8013bf:	7e 24                	jle    8013e5 <vprintfmt+0x1e0>
					putch(padc, putdat);
  8013c1:	0f be 5d dc          	movsbl -0x24(%ebp),%ebx
  8013c5:	89 75 dc             	mov    %esi,-0x24(%ebp)
  8013c8:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  8013cb:	83 ec 08             	sub    $0x8,%esp
  8013ce:	57                   	push   %edi
  8013cf:	53                   	push   %ebx
  8013d0:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8013d3:	4e                   	dec    %esi
  8013d4:	83 c4 10             	add    $0x10,%esp
  8013d7:	85 f6                	test   %esi,%esi
  8013d9:	7f f0                	jg     8013cb <vprintfmt+0x1c6>
  8013db:	8b 75 dc             	mov    -0x24(%ebp),%esi
  8013de:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8013e5:	8b 55 d0             	mov    -0x30(%ebp),%edx
  8013e8:	0f be 02             	movsbl (%edx),%eax
  8013eb:	85 c0                	test   %eax,%eax
  8013ed:	75 47                	jne    801436 <vprintfmt+0x231>
  8013ef:	eb 37                	jmp    801428 <vprintfmt+0x223>
				if (altflag && (ch < ' ' || ch > '~'))
  8013f1:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8013f5:	74 16                	je     80140d <vprintfmt+0x208>
  8013f7:	8d 50 e0             	lea    -0x20(%eax),%edx
  8013fa:	83 fa 5e             	cmp    $0x5e,%edx
  8013fd:	76 0e                	jbe    80140d <vprintfmt+0x208>
					putch('?', putdat);
  8013ff:	83 ec 08             	sub    $0x8,%esp
  801402:	57                   	push   %edi
  801403:	6a 3f                	push   $0x3f
  801405:	ff 55 08             	call   *0x8(%ebp)
  801408:	83 c4 10             	add    $0x10,%esp
  80140b:	eb 0b                	jmp    801418 <vprintfmt+0x213>
				else
					putch(ch, putdat);
  80140d:	83 ec 08             	sub    $0x8,%esp
  801410:	57                   	push   %edi
  801411:	50                   	push   %eax
  801412:	ff 55 08             	call   *0x8(%ebp)
  801415:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  801418:	ff 4d e4             	decl   -0x1c(%ebp)
  80141b:	0f be 03             	movsbl (%ebx),%eax
  80141e:	85 c0                	test   %eax,%eax
  801420:	74 03                	je     801425 <vprintfmt+0x220>
  801422:	43                   	inc    %ebx
  801423:	eb 1b                	jmp    801440 <vprintfmt+0x23b>
  801425:	8b 75 dc             	mov    -0x24(%ebp),%esi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  801428:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80142c:	7f 1e                	jg     80144c <vprintfmt+0x247>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80142e:	8b 75 d8             	mov    -0x28(%ebp),%esi
  801431:	e9 f3 fd ff ff       	jmp    801229 <vprintfmt+0x24>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  801436:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  801439:	43                   	inc    %ebx
  80143a:	89 75 dc             	mov    %esi,-0x24(%ebp)
  80143d:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  801440:	85 f6                	test   %esi,%esi
  801442:	78 ad                	js     8013f1 <vprintfmt+0x1ec>
  801444:	4e                   	dec    %esi
  801445:	79 aa                	jns    8013f1 <vprintfmt+0x1ec>
  801447:	8b 75 dc             	mov    -0x24(%ebp),%esi
  80144a:	eb dc                	jmp    801428 <vprintfmt+0x223>
  80144c:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80144f:	83 ec 08             	sub    $0x8,%esp
  801452:	57                   	push   %edi
  801453:	6a 20                	push   $0x20
  801455:	ff 55 08             	call   *0x8(%ebp)
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  801458:	4b                   	dec    %ebx
  801459:	83 c4 10             	add    $0x10,%esp
  80145c:	85 db                	test   %ebx,%ebx
  80145e:	7f ef                	jg     80144f <vprintfmt+0x24a>
  801460:	e9 c4 fd ff ff       	jmp    801229 <vprintfmt+0x24>
  801465:	89 5d d8             	mov    %ebx,-0x28(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  801468:	89 ca                	mov    %ecx,%edx
  80146a:	8d 45 14             	lea    0x14(%ebp),%eax
  80146d:	e8 2a fd ff ff       	call   80119c <getint>
  801472:	89 c3                	mov    %eax,%ebx
  801474:	89 d6                	mov    %edx,%esi
			if ((long long) num < 0) {
  801476:	85 d2                	test   %edx,%edx
  801478:	78 0a                	js     801484 <vprintfmt+0x27f>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  80147a:	b8 0a 00 00 00       	mov    $0xa,%eax
  80147f:	e9 b0 00 00 00       	jmp    801534 <vprintfmt+0x32f>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  801484:	83 ec 08             	sub    $0x8,%esp
  801487:	57                   	push   %edi
  801488:	6a 2d                	push   $0x2d
  80148a:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  80148d:	f7 db                	neg    %ebx
  80148f:	83 d6 00             	adc    $0x0,%esi
  801492:	f7 de                	neg    %esi
  801494:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  801497:	b8 0a 00 00 00       	mov    $0xa,%eax
  80149c:	e9 93 00 00 00       	jmp    801534 <vprintfmt+0x32f>
  8014a1:	89 5d d8             	mov    %ebx,-0x28(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8014a4:	89 ca                	mov    %ecx,%edx
  8014a6:	8d 45 14             	lea    0x14(%ebp),%eax
  8014a9:	e8 b4 fc ff ff       	call   801162 <getuint>
  8014ae:	89 c3                	mov    %eax,%ebx
  8014b0:	89 d6                	mov    %edx,%esi
			base = 10;
  8014b2:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  8014b7:	eb 7b                	jmp    801534 <vprintfmt+0x32f>
  8014b9:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// (unsigned) octal
		case 'o':
            // (MIT 6.828, lab1, Ex.8)  my code : 
            num = getint(&ap, lflag);
  8014bc:	89 ca                	mov    %ecx,%edx
  8014be:	8d 45 14             	lea    0x14(%ebp),%eax
  8014c1:	e8 d6 fc ff ff       	call   80119c <getint>
  8014c6:	89 c3                	mov    %eax,%ebx
  8014c8:	89 d6                	mov    %edx,%esi
            if ((long long) num < 0) {
  8014ca:	85 d2                	test   %edx,%edx
  8014cc:	78 07                	js     8014d5 <vprintfmt+0x2d0>
                putch('-', putdat);
                num = -(long long) num;
            }
            base = 8;
  8014ce:	b8 08 00 00 00       	mov    $0x8,%eax
  8014d3:	eb 5f                	jmp    801534 <vprintfmt+0x32f>
		// (unsigned) octal
		case 'o':
            // (MIT 6.828, lab1, Ex.8)  my code : 
            num = getint(&ap, lflag);
            if ((long long) num < 0) {
                putch('-', putdat);
  8014d5:	83 ec 08             	sub    $0x8,%esp
  8014d8:	57                   	push   %edi
  8014d9:	6a 2d                	push   $0x2d
  8014db:	ff 55 08             	call   *0x8(%ebp)
                num = -(long long) num;
  8014de:	f7 db                	neg    %ebx
  8014e0:	83 d6 00             	adc    $0x0,%esi
  8014e3:	f7 de                	neg    %esi
  8014e5:	83 c4 10             	add    $0x10,%esp
            }
            base = 8;
  8014e8:	b8 08 00 00 00       	mov    $0x8,%eax
  8014ed:	eb 45                	jmp    801534 <vprintfmt+0x32f>
  8014ef:	89 5d d8             	mov    %ebx,-0x28(%ebp)
            goto number;

        // pointer
		case 'p':
			putch('0', putdat);
  8014f2:	83 ec 08             	sub    $0x8,%esp
  8014f5:	57                   	push   %edi
  8014f6:	6a 30                	push   $0x30
  8014f8:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  8014fb:	83 c4 08             	add    $0x8,%esp
  8014fe:	57                   	push   %edi
  8014ff:	6a 78                	push   $0x78
  801501:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  801504:	8b 45 14             	mov    0x14(%ebp),%eax
  801507:	8d 50 04             	lea    0x4(%eax),%edx
  80150a:	89 55 14             	mov    %edx,0x14(%ebp)

        // pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  80150d:	8b 18                	mov    (%eax),%ebx
  80150f:	be 00 00 00 00       	mov    $0x0,%esi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  801514:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  801517:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  80151c:	eb 16                	jmp    801534 <vprintfmt+0x32f>
  80151e:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  801521:	89 ca                	mov    %ecx,%edx
  801523:	8d 45 14             	lea    0x14(%ebp),%eax
  801526:	e8 37 fc ff ff       	call   801162 <getuint>
  80152b:	89 c3                	mov    %eax,%ebx
  80152d:	89 d6                	mov    %edx,%esi
			base = 16;
  80152f:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  801534:	83 ec 0c             	sub    $0xc,%esp
  801537:	0f be 55 dc          	movsbl -0x24(%ebp),%edx
  80153b:	52                   	push   %edx
  80153c:	ff 75 e4             	pushl  -0x1c(%ebp)
  80153f:	50                   	push   %eax
  801540:	56                   	push   %esi
  801541:	53                   	push   %ebx
  801542:	89 fa                	mov    %edi,%edx
  801544:	8b 45 08             	mov    0x8(%ebp),%eax
  801547:	e8 68 fb ff ff       	call   8010b4 <printnum>
			break;
  80154c:	83 c4 20             	add    $0x20,%esp
  80154f:	8b 75 d8             	mov    -0x28(%ebp),%esi
  801552:	e9 d2 fc ff ff       	jmp    801229 <vprintfmt+0x24>
  801557:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80155a:	83 ec 08             	sub    $0x8,%esp
  80155d:	57                   	push   %edi
  80155e:	52                   	push   %edx
  80155f:	ff 55 08             	call   *0x8(%ebp)
			break;
  801562:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801565:	8b 75 d8             	mov    -0x28(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  801568:	e9 bc fc ff ff       	jmp    801229 <vprintfmt+0x24>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80156d:	83 ec 08             	sub    $0x8,%esp
  801570:	57                   	push   %edi
  801571:	6a 25                	push   $0x25
  801573:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  801576:	83 c4 10             	add    $0x10,%esp
  801579:	eb 02                	jmp    80157d <vprintfmt+0x378>
  80157b:	89 c6                	mov    %eax,%esi
  80157d:	8d 46 ff             	lea    -0x1(%esi),%eax
  801580:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  801584:	75 f5                	jne    80157b <vprintfmt+0x376>
  801586:	e9 9e fc ff ff       	jmp    801229 <vprintfmt+0x24>
				/* do nothing */;
			break;
		}
	}
}
  80158b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80158e:	5b                   	pop    %ebx
  80158f:	5e                   	pop    %esi
  801590:	5f                   	pop    %edi
  801591:	c9                   	leave  
  801592:	c3                   	ret    

00801593 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  801593:	55                   	push   %ebp
  801594:	89 e5                	mov    %esp,%ebp
  801596:	83 ec 18             	sub    $0x18,%esp
  801599:	8b 45 08             	mov    0x8(%ebp),%eax
  80159c:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80159f:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8015a2:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8015a6:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8015a9:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8015b0:	85 c0                	test   %eax,%eax
  8015b2:	74 26                	je     8015da <vsnprintf+0x47>
  8015b4:	85 d2                	test   %edx,%edx
  8015b6:	7e 29                	jle    8015e1 <vsnprintf+0x4e>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8015b8:	ff 75 14             	pushl  0x14(%ebp)
  8015bb:	ff 75 10             	pushl  0x10(%ebp)
  8015be:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8015c1:	50                   	push   %eax
  8015c2:	68 ce 11 80 00       	push   $0x8011ce
  8015c7:	e8 39 fc ff ff       	call   801205 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8015cc:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8015cf:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8015d2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8015d5:	83 c4 10             	add    $0x10,%esp
  8015d8:	eb 0c                	jmp    8015e6 <vsnprintf+0x53>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8015da:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8015df:	eb 05                	jmp    8015e6 <vsnprintf+0x53>
  8015e1:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8015e6:	c9                   	leave  
  8015e7:	c3                   	ret    

008015e8 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8015e8:	55                   	push   %ebp
  8015e9:	89 e5                	mov    %esp,%ebp
  8015eb:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8015ee:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8015f1:	50                   	push   %eax
  8015f2:	ff 75 10             	pushl  0x10(%ebp)
  8015f5:	ff 75 0c             	pushl  0xc(%ebp)
  8015f8:	ff 75 08             	pushl  0x8(%ebp)
  8015fb:	e8 93 ff ff ff       	call   801593 <vsnprintf>
	va_end(ap);

	return rc;
}
  801600:	c9                   	leave  
  801601:	c3                   	ret    
	...

00801604 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  801604:	55                   	push   %ebp
  801605:	89 e5                	mov    %esp,%ebp
  801607:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80160a:	80 3a 00             	cmpb   $0x0,(%edx)
  80160d:	74 0e                	je     80161d <strlen+0x19>
  80160f:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  801614:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  801615:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  801619:	75 f9                	jne    801614 <strlen+0x10>
  80161b:	eb 05                	jmp    801622 <strlen+0x1e>
  80161d:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  801622:	c9                   	leave  
  801623:	c3                   	ret    

00801624 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  801624:	55                   	push   %ebp
  801625:	89 e5                	mov    %esp,%ebp
  801627:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80162a:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80162d:	85 d2                	test   %edx,%edx
  80162f:	74 17                	je     801648 <strnlen+0x24>
  801631:	80 39 00             	cmpb   $0x0,(%ecx)
  801634:	74 19                	je     80164f <strnlen+0x2b>
  801636:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  80163b:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80163c:	39 d0                	cmp    %edx,%eax
  80163e:	74 14                	je     801654 <strnlen+0x30>
  801640:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  801644:	75 f5                	jne    80163b <strnlen+0x17>
  801646:	eb 0c                	jmp    801654 <strnlen+0x30>
  801648:	b8 00 00 00 00       	mov    $0x0,%eax
  80164d:	eb 05                	jmp    801654 <strnlen+0x30>
  80164f:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  801654:	c9                   	leave  
  801655:	c3                   	ret    

00801656 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  801656:	55                   	push   %ebp
  801657:	89 e5                	mov    %esp,%ebp
  801659:	53                   	push   %ebx
  80165a:	8b 45 08             	mov    0x8(%ebp),%eax
  80165d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  801660:	ba 00 00 00 00       	mov    $0x0,%edx
  801665:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  801668:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  80166b:	42                   	inc    %edx
  80166c:	84 c9                	test   %cl,%cl
  80166e:	75 f5                	jne    801665 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  801670:	5b                   	pop    %ebx
  801671:	c9                   	leave  
  801672:	c3                   	ret    

00801673 <strcat>:

char *
strcat(char *dst, const char *src)
{
  801673:	55                   	push   %ebp
  801674:	89 e5                	mov    %esp,%ebp
  801676:	53                   	push   %ebx
  801677:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80167a:	53                   	push   %ebx
  80167b:	e8 84 ff ff ff       	call   801604 <strlen>
  801680:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  801683:	ff 75 0c             	pushl  0xc(%ebp)
  801686:	8d 04 03             	lea    (%ebx,%eax,1),%eax
  801689:	50                   	push   %eax
  80168a:	e8 c7 ff ff ff       	call   801656 <strcpy>
	return dst;
}
  80168f:	89 d8                	mov    %ebx,%eax
  801691:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801694:	c9                   	leave  
  801695:	c3                   	ret    

00801696 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  801696:	55                   	push   %ebp
  801697:	89 e5                	mov    %esp,%ebp
  801699:	56                   	push   %esi
  80169a:	53                   	push   %ebx
  80169b:	8b 45 08             	mov    0x8(%ebp),%eax
  80169e:	8b 55 0c             	mov    0xc(%ebp),%edx
  8016a1:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8016a4:	85 f6                	test   %esi,%esi
  8016a6:	74 15                	je     8016bd <strncpy+0x27>
  8016a8:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
  8016ad:	8a 1a                	mov    (%edx),%bl
  8016af:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8016b2:	80 3a 01             	cmpb   $0x1,(%edx)
  8016b5:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8016b8:	41                   	inc    %ecx
  8016b9:	39 ce                	cmp    %ecx,%esi
  8016bb:	77 f0                	ja     8016ad <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8016bd:	5b                   	pop    %ebx
  8016be:	5e                   	pop    %esi
  8016bf:	c9                   	leave  
  8016c0:	c3                   	ret    

008016c1 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8016c1:	55                   	push   %ebp
  8016c2:	89 e5                	mov    %esp,%ebp
  8016c4:	57                   	push   %edi
  8016c5:	56                   	push   %esi
  8016c6:	53                   	push   %ebx
  8016c7:	8b 7d 08             	mov    0x8(%ebp),%edi
  8016ca:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8016cd:	8b 75 10             	mov    0x10(%ebp),%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8016d0:	85 f6                	test   %esi,%esi
  8016d2:	74 32                	je     801706 <strlcpy+0x45>
		while (--size > 0 && *src != '\0')
  8016d4:	83 fe 01             	cmp    $0x1,%esi
  8016d7:	74 22                	je     8016fb <strlcpy+0x3a>
  8016d9:	8a 0b                	mov    (%ebx),%cl
  8016db:	84 c9                	test   %cl,%cl
  8016dd:	74 20                	je     8016ff <strlcpy+0x3e>
  8016df:	89 f8                	mov    %edi,%eax
  8016e1:	ba 00 00 00 00       	mov    $0x0,%edx
	}
	return ret;
}

size_t
strlcpy(char *dst, const char *src, size_t size)
  8016e6:	83 ee 02             	sub    $0x2,%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8016e9:	88 08                	mov    %cl,(%eax)
  8016eb:	40                   	inc    %eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8016ec:	39 f2                	cmp    %esi,%edx
  8016ee:	74 11                	je     801701 <strlcpy+0x40>
  8016f0:	8a 4c 13 01          	mov    0x1(%ebx,%edx,1),%cl
  8016f4:	42                   	inc    %edx
  8016f5:	84 c9                	test   %cl,%cl
  8016f7:	75 f0                	jne    8016e9 <strlcpy+0x28>
  8016f9:	eb 06                	jmp    801701 <strlcpy+0x40>
  8016fb:	89 f8                	mov    %edi,%eax
  8016fd:	eb 02                	jmp    801701 <strlcpy+0x40>
  8016ff:	89 f8                	mov    %edi,%eax
			*dst++ = *src++;
		*dst = '\0';
  801701:	c6 00 00             	movb   $0x0,(%eax)
  801704:	eb 02                	jmp    801708 <strlcpy+0x47>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  801706:	89 f8                	mov    %edi,%eax
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
		*dst = '\0';
	}
	return dst - dst_in;
  801708:	29 f8                	sub    %edi,%eax
}
  80170a:	5b                   	pop    %ebx
  80170b:	5e                   	pop    %esi
  80170c:	5f                   	pop    %edi
  80170d:	c9                   	leave  
  80170e:	c3                   	ret    

0080170f <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80170f:	55                   	push   %ebp
  801710:	89 e5                	mov    %esp,%ebp
  801712:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801715:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  801718:	8a 01                	mov    (%ecx),%al
  80171a:	84 c0                	test   %al,%al
  80171c:	74 10                	je     80172e <strcmp+0x1f>
  80171e:	3a 02                	cmp    (%edx),%al
  801720:	75 0c                	jne    80172e <strcmp+0x1f>
		p++, q++;
  801722:	41                   	inc    %ecx
  801723:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  801724:	8a 01                	mov    (%ecx),%al
  801726:	84 c0                	test   %al,%al
  801728:	74 04                	je     80172e <strcmp+0x1f>
  80172a:	3a 02                	cmp    (%edx),%al
  80172c:	74 f4                	je     801722 <strcmp+0x13>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  80172e:	0f b6 c0             	movzbl %al,%eax
  801731:	0f b6 12             	movzbl (%edx),%edx
  801734:	29 d0                	sub    %edx,%eax
}
  801736:	c9                   	leave  
  801737:	c3                   	ret    

00801738 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  801738:	55                   	push   %ebp
  801739:	89 e5                	mov    %esp,%ebp
  80173b:	53                   	push   %ebx
  80173c:	8b 55 08             	mov    0x8(%ebp),%edx
  80173f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801742:	8b 45 10             	mov    0x10(%ebp),%eax
	while (n > 0 && *p && *p == *q)
  801745:	85 c0                	test   %eax,%eax
  801747:	74 1b                	je     801764 <strncmp+0x2c>
  801749:	8a 1a                	mov    (%edx),%bl
  80174b:	84 db                	test   %bl,%bl
  80174d:	74 24                	je     801773 <strncmp+0x3b>
  80174f:	3a 19                	cmp    (%ecx),%bl
  801751:	75 20                	jne    801773 <strncmp+0x3b>
  801753:	48                   	dec    %eax
  801754:	74 15                	je     80176b <strncmp+0x33>
		n--, p++, q++;
  801756:	42                   	inc    %edx
  801757:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  801758:	8a 1a                	mov    (%edx),%bl
  80175a:	84 db                	test   %bl,%bl
  80175c:	74 15                	je     801773 <strncmp+0x3b>
  80175e:	3a 19                	cmp    (%ecx),%bl
  801760:	74 f1                	je     801753 <strncmp+0x1b>
  801762:	eb 0f                	jmp    801773 <strncmp+0x3b>
		n--, p++, q++;
	if (n == 0)
		return 0;
  801764:	b8 00 00 00 00       	mov    $0x0,%eax
  801769:	eb 05                	jmp    801770 <strncmp+0x38>
  80176b:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  801770:	5b                   	pop    %ebx
  801771:	c9                   	leave  
  801772:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  801773:	0f b6 02             	movzbl (%edx),%eax
  801776:	0f b6 11             	movzbl (%ecx),%edx
  801779:	29 d0                	sub    %edx,%eax
  80177b:	eb f3                	jmp    801770 <strncmp+0x38>

0080177d <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80177d:	55                   	push   %ebp
  80177e:	89 e5                	mov    %esp,%ebp
  801780:	8b 45 08             	mov    0x8(%ebp),%eax
  801783:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  801786:	8a 10                	mov    (%eax),%dl
  801788:	84 d2                	test   %dl,%dl
  80178a:	74 18                	je     8017a4 <strchr+0x27>
		if (*s == c)
  80178c:	38 ca                	cmp    %cl,%dl
  80178e:	75 06                	jne    801796 <strchr+0x19>
  801790:	eb 17                	jmp    8017a9 <strchr+0x2c>
  801792:	38 ca                	cmp    %cl,%dl
  801794:	74 13                	je     8017a9 <strchr+0x2c>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  801796:	40                   	inc    %eax
  801797:	8a 10                	mov    (%eax),%dl
  801799:	84 d2                	test   %dl,%dl
  80179b:	75 f5                	jne    801792 <strchr+0x15>
		if (*s == c)
			return (char *) s;
	return 0;
  80179d:	b8 00 00 00 00       	mov    $0x0,%eax
  8017a2:	eb 05                	jmp    8017a9 <strchr+0x2c>
  8017a4:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8017a9:	c9                   	leave  
  8017aa:	c3                   	ret    

008017ab <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8017ab:	55                   	push   %ebp
  8017ac:	89 e5                	mov    %esp,%ebp
  8017ae:	8b 45 08             	mov    0x8(%ebp),%eax
  8017b1:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  8017b4:	8a 10                	mov    (%eax),%dl
  8017b6:	84 d2                	test   %dl,%dl
  8017b8:	74 11                	je     8017cb <strfind+0x20>
		if (*s == c)
  8017ba:	38 ca                	cmp    %cl,%dl
  8017bc:	75 06                	jne    8017c4 <strfind+0x19>
  8017be:	eb 0b                	jmp    8017cb <strfind+0x20>
  8017c0:	38 ca                	cmp    %cl,%dl
  8017c2:	74 07                	je     8017cb <strfind+0x20>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  8017c4:	40                   	inc    %eax
  8017c5:	8a 10                	mov    (%eax),%dl
  8017c7:	84 d2                	test   %dl,%dl
  8017c9:	75 f5                	jne    8017c0 <strfind+0x15>
		if (*s == c)
			break;
	return (char *) s;
}
  8017cb:	c9                   	leave  
  8017cc:	c3                   	ret    

008017cd <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8017cd:	55                   	push   %ebp
  8017ce:	89 e5                	mov    %esp,%ebp
  8017d0:	57                   	push   %edi
  8017d1:	56                   	push   %esi
  8017d2:	53                   	push   %ebx
  8017d3:	8b 7d 08             	mov    0x8(%ebp),%edi
  8017d6:	8b 45 0c             	mov    0xc(%ebp),%eax
  8017d9:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8017dc:	85 c9                	test   %ecx,%ecx
  8017de:	74 30                	je     801810 <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8017e0:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8017e6:	75 25                	jne    80180d <memset+0x40>
  8017e8:	f6 c1 03             	test   $0x3,%cl
  8017eb:	75 20                	jne    80180d <memset+0x40>
		c &= 0xFF;
  8017ed:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8017f0:	89 d3                	mov    %edx,%ebx
  8017f2:	c1 e3 08             	shl    $0x8,%ebx
  8017f5:	89 d6                	mov    %edx,%esi
  8017f7:	c1 e6 18             	shl    $0x18,%esi
  8017fa:	89 d0                	mov    %edx,%eax
  8017fc:	c1 e0 10             	shl    $0x10,%eax
  8017ff:	09 f0                	or     %esi,%eax
  801801:	09 d0                	or     %edx,%eax
  801803:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  801805:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  801808:	fc                   	cld    
  801809:	f3 ab                	rep stos %eax,%es:(%edi)
  80180b:	eb 03                	jmp    801810 <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  80180d:	fc                   	cld    
  80180e:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  801810:	89 f8                	mov    %edi,%eax
  801812:	5b                   	pop    %ebx
  801813:	5e                   	pop    %esi
  801814:	5f                   	pop    %edi
  801815:	c9                   	leave  
  801816:	c3                   	ret    

00801817 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  801817:	55                   	push   %ebp
  801818:	89 e5                	mov    %esp,%ebp
  80181a:	57                   	push   %edi
  80181b:	56                   	push   %esi
  80181c:	8b 45 08             	mov    0x8(%ebp),%eax
  80181f:	8b 75 0c             	mov    0xc(%ebp),%esi
  801822:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  801825:	39 c6                	cmp    %eax,%esi
  801827:	73 34                	jae    80185d <memmove+0x46>
  801829:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  80182c:	39 d0                	cmp    %edx,%eax
  80182e:	73 2d                	jae    80185d <memmove+0x46>
		s += n;
		d += n;
  801830:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801833:	f6 c2 03             	test   $0x3,%dl
  801836:	75 1b                	jne    801853 <memmove+0x3c>
  801838:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80183e:	75 13                	jne    801853 <memmove+0x3c>
  801840:	f6 c1 03             	test   $0x3,%cl
  801843:	75 0e                	jne    801853 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  801845:	83 ef 04             	sub    $0x4,%edi
  801848:	8d 72 fc             	lea    -0x4(%edx),%esi
  80184b:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  80184e:	fd                   	std    
  80184f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801851:	eb 07                	jmp    80185a <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  801853:	4f                   	dec    %edi
  801854:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  801857:	fd                   	std    
  801858:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  80185a:	fc                   	cld    
  80185b:	eb 20                	jmp    80187d <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80185d:	f7 c6 03 00 00 00    	test   $0x3,%esi
  801863:	75 13                	jne    801878 <memmove+0x61>
  801865:	a8 03                	test   $0x3,%al
  801867:	75 0f                	jne    801878 <memmove+0x61>
  801869:	f6 c1 03             	test   $0x3,%cl
  80186c:	75 0a                	jne    801878 <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  80186e:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  801871:	89 c7                	mov    %eax,%edi
  801873:	fc                   	cld    
  801874:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801876:	eb 05                	jmp    80187d <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  801878:	89 c7                	mov    %eax,%edi
  80187a:	fc                   	cld    
  80187b:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  80187d:	5e                   	pop    %esi
  80187e:	5f                   	pop    %edi
  80187f:	c9                   	leave  
  801880:	c3                   	ret    

00801881 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  801881:	55                   	push   %ebp
  801882:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  801884:	ff 75 10             	pushl  0x10(%ebp)
  801887:	ff 75 0c             	pushl  0xc(%ebp)
  80188a:	ff 75 08             	pushl  0x8(%ebp)
  80188d:	e8 85 ff ff ff       	call   801817 <memmove>
}
  801892:	c9                   	leave  
  801893:	c3                   	ret    

00801894 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  801894:	55                   	push   %ebp
  801895:	89 e5                	mov    %esp,%ebp
  801897:	57                   	push   %edi
  801898:	56                   	push   %esi
  801899:	53                   	push   %ebx
  80189a:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80189d:	8b 75 0c             	mov    0xc(%ebp),%esi
  8018a0:	8b 7d 10             	mov    0x10(%ebp),%edi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8018a3:	85 ff                	test   %edi,%edi
  8018a5:	74 32                	je     8018d9 <memcmp+0x45>
		if (*s1 != *s2)
  8018a7:	8a 03                	mov    (%ebx),%al
  8018a9:	8a 0e                	mov    (%esi),%cl
  8018ab:	38 c8                	cmp    %cl,%al
  8018ad:	74 19                	je     8018c8 <memcmp+0x34>
  8018af:	eb 0d                	jmp    8018be <memcmp+0x2a>
  8018b1:	8a 44 13 01          	mov    0x1(%ebx,%edx,1),%al
  8018b5:	8a 4c 16 01          	mov    0x1(%esi,%edx,1),%cl
  8018b9:	42                   	inc    %edx
  8018ba:	38 c8                	cmp    %cl,%al
  8018bc:	74 10                	je     8018ce <memcmp+0x3a>
			return (int) *s1 - (int) *s2;
  8018be:	0f b6 c0             	movzbl %al,%eax
  8018c1:	0f b6 c9             	movzbl %cl,%ecx
  8018c4:	29 c8                	sub    %ecx,%eax
  8018c6:	eb 16                	jmp    8018de <memcmp+0x4a>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8018c8:	4f                   	dec    %edi
  8018c9:	ba 00 00 00 00       	mov    $0x0,%edx
  8018ce:	39 fa                	cmp    %edi,%edx
  8018d0:	75 df                	jne    8018b1 <memcmp+0x1d>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  8018d2:	b8 00 00 00 00       	mov    $0x0,%eax
  8018d7:	eb 05                	jmp    8018de <memcmp+0x4a>
  8018d9:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8018de:	5b                   	pop    %ebx
  8018df:	5e                   	pop    %esi
  8018e0:	5f                   	pop    %edi
  8018e1:	c9                   	leave  
  8018e2:	c3                   	ret    

008018e3 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8018e3:	55                   	push   %ebp
  8018e4:	89 e5                	mov    %esp,%ebp
  8018e6:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  8018e9:	89 c2                	mov    %eax,%edx
  8018eb:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  8018ee:	39 d0                	cmp    %edx,%eax
  8018f0:	73 12                	jae    801904 <memfind+0x21>
		if (*(const unsigned char *) s == (unsigned char) c)
  8018f2:	8a 4d 0c             	mov    0xc(%ebp),%cl
  8018f5:	38 08                	cmp    %cl,(%eax)
  8018f7:	75 06                	jne    8018ff <memfind+0x1c>
  8018f9:	eb 09                	jmp    801904 <memfind+0x21>
  8018fb:	38 08                	cmp    %cl,(%eax)
  8018fd:	74 05                	je     801904 <memfind+0x21>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8018ff:	40                   	inc    %eax
  801900:	39 c2                	cmp    %eax,%edx
  801902:	77 f7                	ja     8018fb <memfind+0x18>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  801904:	c9                   	leave  
  801905:	c3                   	ret    

00801906 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  801906:	55                   	push   %ebp
  801907:	89 e5                	mov    %esp,%ebp
  801909:	57                   	push   %edi
  80190a:	56                   	push   %esi
  80190b:	53                   	push   %ebx
  80190c:	8b 55 08             	mov    0x8(%ebp),%edx
  80190f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801912:	eb 01                	jmp    801915 <strtol+0xf>
		s++;
  801914:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801915:	8a 02                	mov    (%edx),%al
  801917:	3c 20                	cmp    $0x20,%al
  801919:	74 f9                	je     801914 <strtol+0xe>
  80191b:	3c 09                	cmp    $0x9,%al
  80191d:	74 f5                	je     801914 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  80191f:	3c 2b                	cmp    $0x2b,%al
  801921:	75 08                	jne    80192b <strtol+0x25>
		s++;
  801923:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  801924:	bf 00 00 00 00       	mov    $0x0,%edi
  801929:	eb 13                	jmp    80193e <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  80192b:	3c 2d                	cmp    $0x2d,%al
  80192d:	75 0a                	jne    801939 <strtol+0x33>
		s++, neg = 1;
  80192f:	8d 52 01             	lea    0x1(%edx),%edx
  801932:	bf 01 00 00 00       	mov    $0x1,%edi
  801937:	eb 05                	jmp    80193e <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  801939:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  80193e:	85 db                	test   %ebx,%ebx
  801940:	74 05                	je     801947 <strtol+0x41>
  801942:	83 fb 10             	cmp    $0x10,%ebx
  801945:	75 28                	jne    80196f <strtol+0x69>
  801947:	8a 02                	mov    (%edx),%al
  801949:	3c 30                	cmp    $0x30,%al
  80194b:	75 10                	jne    80195d <strtol+0x57>
  80194d:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  801951:	75 0a                	jne    80195d <strtol+0x57>
		s += 2, base = 16;
  801953:	83 c2 02             	add    $0x2,%edx
  801956:	bb 10 00 00 00       	mov    $0x10,%ebx
  80195b:	eb 12                	jmp    80196f <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  80195d:	85 db                	test   %ebx,%ebx
  80195f:	75 0e                	jne    80196f <strtol+0x69>
  801961:	3c 30                	cmp    $0x30,%al
  801963:	75 05                	jne    80196a <strtol+0x64>
		s++, base = 8;
  801965:	42                   	inc    %edx
  801966:	b3 08                	mov    $0x8,%bl
  801968:	eb 05                	jmp    80196f <strtol+0x69>
	else if (base == 0)
		base = 10;
  80196a:	bb 0a 00 00 00       	mov    $0xa,%ebx
  80196f:	b8 00 00 00 00       	mov    $0x0,%eax
  801974:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  801976:	8a 0a                	mov    (%edx),%cl
  801978:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  80197b:	80 fb 09             	cmp    $0x9,%bl
  80197e:	77 08                	ja     801988 <strtol+0x82>
			dig = *s - '0';
  801980:	0f be c9             	movsbl %cl,%ecx
  801983:	83 e9 30             	sub    $0x30,%ecx
  801986:	eb 1e                	jmp    8019a6 <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  801988:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  80198b:	80 fb 19             	cmp    $0x19,%bl
  80198e:	77 08                	ja     801998 <strtol+0x92>
			dig = *s - 'a' + 10;
  801990:	0f be c9             	movsbl %cl,%ecx
  801993:	83 e9 57             	sub    $0x57,%ecx
  801996:	eb 0e                	jmp    8019a6 <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  801998:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  80199b:	80 fb 19             	cmp    $0x19,%bl
  80199e:	77 13                	ja     8019b3 <strtol+0xad>
			dig = *s - 'A' + 10;
  8019a0:	0f be c9             	movsbl %cl,%ecx
  8019a3:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  8019a6:	39 f1                	cmp    %esi,%ecx
  8019a8:	7d 0d                	jge    8019b7 <strtol+0xb1>
			break;
		s++, val = (val * base) + dig;
  8019aa:	42                   	inc    %edx
  8019ab:	0f af c6             	imul   %esi,%eax
  8019ae:	8d 04 01             	lea    (%ecx,%eax,1),%eax
		// we don't properly detect overflow!
	}
  8019b1:	eb c3                	jmp    801976 <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  8019b3:	89 c1                	mov    %eax,%ecx
  8019b5:	eb 02                	jmp    8019b9 <strtol+0xb3>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  8019b7:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  8019b9:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8019bd:	74 05                	je     8019c4 <strtol+0xbe>
		*endptr = (char *) s;
  8019bf:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8019c2:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  8019c4:	85 ff                	test   %edi,%edi
  8019c6:	74 04                	je     8019cc <strtol+0xc6>
  8019c8:	89 c8                	mov    %ecx,%eax
  8019ca:	f7 d8                	neg    %eax
}
  8019cc:	5b                   	pop    %ebx
  8019cd:	5e                   	pop    %esi
  8019ce:	5f                   	pop    %edi
  8019cf:	c9                   	leave  
  8019d0:	c3                   	ret    
  8019d1:	00 00                	add    %al,(%eax)
	...

008019d4 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8019d4:	55                   	push   %ebp
  8019d5:	89 e5                	mov    %esp,%ebp
  8019d7:	56                   	push   %esi
  8019d8:	53                   	push   %ebx
  8019d9:	8b 75 08             	mov    0x8(%ebp),%esi
  8019dc:	8b 45 0c             	mov    0xc(%ebp),%eax
  8019df:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// cprintf("0x%x 0x%x 0x%x\n", (uint32_t)from_env_store, (uint32_t)pg, (uint32_t)perm_store);
	int r;
	if (pg != NULL) {
  8019e2:	85 c0                	test   %eax,%eax
  8019e4:	74 0e                	je     8019f4 <ipc_recv+0x20>
		r = sys_ipc_recv(pg);
  8019e6:	83 ec 0c             	sub    $0xc,%esp
  8019e9:	50                   	push   %eax
  8019ea:	e8 b8 e8 ff ff       	call   8002a7 <sys_ipc_recv>
  8019ef:	83 c4 10             	add    $0x10,%esp
  8019f2:	eb 10                	jmp    801a04 <ipc_recv+0x30>
	} else {
		r = sys_ipc_recv((void *)UTOP);
  8019f4:	83 ec 0c             	sub    $0xc,%esp
  8019f7:	68 00 00 c0 ee       	push   $0xeec00000
  8019fc:	e8 a6 e8 ff ff       	call   8002a7 <sys_ipc_recv>
  801a01:	83 c4 10             	add    $0x10,%esp
	}

	if (r == 0) {
  801a04:	85 c0                	test   %eax,%eax
  801a06:	75 26                	jne    801a2e <ipc_recv+0x5a>
		if (from_env_store != NULL) *from_env_store = thisenv->env_ipc_from;
  801a08:	85 f6                	test   %esi,%esi
  801a0a:	74 0a                	je     801a16 <ipc_recv+0x42>
  801a0c:	a1 04 40 80 00       	mov    0x804004,%eax
  801a11:	8b 40 74             	mov    0x74(%eax),%eax
  801a14:	89 06                	mov    %eax,(%esi)
		if (perm_store != NULL) *perm_store = thisenv->env_ipc_perm;
  801a16:	85 db                	test   %ebx,%ebx
  801a18:	74 0a                	je     801a24 <ipc_recv+0x50>
  801a1a:	a1 04 40 80 00       	mov    0x804004,%eax
  801a1f:	8b 40 78             	mov    0x78(%eax),%eax
  801a22:	89 03                	mov    %eax,(%ebx)
		return thisenv->env_ipc_value;
  801a24:	a1 04 40 80 00       	mov    0x804004,%eax
  801a29:	8b 40 70             	mov    0x70(%eax),%eax
  801a2c:	eb 14                	jmp    801a42 <ipc_recv+0x6e>
	} else {
		// fails;
		if (from_env_store != NULL) *from_env_store = 0;
  801a2e:	85 f6                	test   %esi,%esi
  801a30:	74 06                	je     801a38 <ipc_recv+0x64>
  801a32:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		if (perm_store != NULL) *perm_store = 0;
  801a38:	85 db                	test   %ebx,%ebx
  801a3a:	74 06                	je     801a42 <ipc_recv+0x6e>
  801a3c:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
		return r;
	}
}
  801a42:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a45:	5b                   	pop    %ebx
  801a46:	5e                   	pop    %esi
  801a47:	c9                   	leave  
  801a48:	c3                   	ret    

00801a49 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801a49:	55                   	push   %ebp
  801a4a:	89 e5                	mov    %esp,%ebp
  801a4c:	57                   	push   %edi
  801a4d:	56                   	push   %esi
  801a4e:	53                   	push   %ebx
  801a4f:	83 ec 0c             	sub    $0xc,%esp
  801a52:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801a55:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801a58:	8b 75 14             	mov    0x14(%ebp),%esi
	// LAB 4: Your code here.
	// int sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
	int r;
	if (pg == NULL) pg = (void *)UTOP;
  801a5b:	85 db                	test   %ebx,%ebx
  801a5d:	75 25                	jne    801a84 <ipc_send+0x3b>
  801a5f:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
  801a64:	eb 1e                	jmp    801a84 <ipc_send+0x3b>
	
	while ((r = sys_ipc_try_send(to_env, val, pg, perm)) != 0) {
		if (r == -E_IPC_NOT_RECV) {
  801a66:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801a69:	75 07                	jne    801a72 <ipc_send+0x29>
			// cprintf("Try Again and Again....\n");
			sys_yield();
  801a6b:	e8 15 e7 ff ff       	call   800185 <sys_yield>
  801a70:	eb 12                	jmp    801a84 <ipc_send+0x3b>
		} else {
			panic("ipc_send error %e\n", r);
  801a72:	50                   	push   %eax
  801a73:	68 e0 21 80 00       	push   $0x8021e0
  801a78:	6a 43                	push   $0x43
  801a7a:	68 f3 21 80 00       	push   $0x8021f3
  801a7f:	e8 44 f5 ff ff       	call   800fc8 <_panic>
	// LAB 4: Your code here.
	// int sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
	int r;
	if (pg == NULL) pg = (void *)UTOP;
	
	while ((r = sys_ipc_try_send(to_env, val, pg, perm)) != 0) {
  801a84:	56                   	push   %esi
  801a85:	53                   	push   %ebx
  801a86:	57                   	push   %edi
  801a87:	ff 75 08             	pushl  0x8(%ebp)
  801a8a:	e8 f3 e7 ff ff       	call   800282 <sys_ipc_try_send>
  801a8f:	83 c4 10             	add    $0x10,%esp
  801a92:	85 c0                	test   %eax,%eax
  801a94:	75 d0                	jne    801a66 <ipc_send+0x1d>
		} else {
			panic("ipc_send error %e\n", r);
		}
	}
	return;
}
  801a96:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801a99:	5b                   	pop    %ebx
  801a9a:	5e                   	pop    %esi
  801a9b:	5f                   	pop    %edi
  801a9c:	c9                   	leave  
  801a9d:	c3                   	ret    

00801a9e <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801a9e:	55                   	push   %ebp
  801a9f:	89 e5                	mov    %esp,%ebp
  801aa1:	53                   	push   %ebx
  801aa2:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	for (i = 0; i < NENV; i++)
		if (envs[i].env_type == type)
  801aa5:	39 1d 50 00 c0 ee    	cmp    %ebx,0xeec00050
  801aab:	74 22                	je     801acf <ipc_find_env+0x31>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801aad:	b8 01 00 00 00       	mov    $0x1,%eax
		if (envs[i].env_type == type)
  801ab2:	8d 0c 85 00 00 00 00 	lea    0x0(,%eax,4),%ecx
  801ab9:	89 c2                	mov    %eax,%edx
  801abb:	c1 e2 07             	shl    $0x7,%edx
  801abe:	29 ca                	sub    %ecx,%edx
  801ac0:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801ac6:	8b 52 50             	mov    0x50(%edx),%edx
  801ac9:	39 da                	cmp    %ebx,%edx
  801acb:	75 1d                	jne    801aea <ipc_find_env+0x4c>
  801acd:	eb 05                	jmp    801ad4 <ipc_find_env+0x36>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801acf:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
			return envs[i].env_id;
  801ad4:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  801adb:	c1 e0 07             	shl    $0x7,%eax
  801ade:	29 d0                	sub    %edx,%eax
  801ae0:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  801ae5:	8b 40 40             	mov    0x40(%eax),%eax
  801ae8:	eb 0c                	jmp    801af6 <ipc_find_env+0x58>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801aea:	40                   	inc    %eax
  801aeb:	3d 00 04 00 00       	cmp    $0x400,%eax
  801af0:	75 c0                	jne    801ab2 <ipc_find_env+0x14>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801af2:	66 b8 00 00          	mov    $0x0,%ax
}
  801af6:	5b                   	pop    %ebx
  801af7:	c9                   	leave  
  801af8:	c3                   	ret    
  801af9:	00 00                	add    %al,(%eax)
	...

00801afc <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801afc:	55                   	push   %ebp
  801afd:	89 e5                	mov    %esp,%ebp
  801aff:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801b02:	89 c2                	mov    %eax,%edx
  801b04:	c1 ea 16             	shr    $0x16,%edx
  801b07:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801b0e:	f6 c2 01             	test   $0x1,%dl
  801b11:	74 1e                	je     801b31 <pageref+0x35>
		return 0;
	pte = uvpt[PGNUM(v)];
  801b13:	c1 e8 0c             	shr    $0xc,%eax
  801b16:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  801b1d:	a8 01                	test   $0x1,%al
  801b1f:	74 17                	je     801b38 <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801b21:	c1 e8 0c             	shr    $0xc,%eax
  801b24:	66 8b 04 c5 04 00 00 	mov    -0x10fffffc(,%eax,8),%ax
  801b2b:	ef 
  801b2c:	0f b7 c0             	movzwl %ax,%eax
  801b2f:	eb 0c                	jmp    801b3d <pageref+0x41>
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
		return 0;
  801b31:	b8 00 00 00 00       	mov    $0x0,%eax
  801b36:	eb 05                	jmp    801b3d <pageref+0x41>
	pte = uvpt[PGNUM(v)];
	if (!(pte & PTE_P))
		return 0;
  801b38:	b8 00 00 00 00       	mov    $0x0,%eax
	return pages[PGNUM(pte)].pp_ref;
}
  801b3d:	c9                   	leave  
  801b3e:	c3                   	ret    
	...

00801b40 <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  801b40:	55                   	push   %ebp
  801b41:	89 e5                	mov    %esp,%ebp
  801b43:	57                   	push   %edi
  801b44:	56                   	push   %esi
  801b45:	83 ec 10             	sub    $0x10,%esp
  801b48:	8b 7d 08             	mov    0x8(%ebp),%edi
  801b4b:	8b 4d 10             	mov    0x10(%ebp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  801b4e:	89 7d f0             	mov    %edi,-0x10(%ebp)
  801b51:	8b 75 0c             	mov    0xc(%ebp),%esi
  const DWunion dd = {.ll = d};
  801b54:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  801b57:	8b 45 14             	mov    0x14(%ebp),%eax
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  801b5a:	85 c0                	test   %eax,%eax
  801b5c:	75 2e                	jne    801b8c <__udivdi3+0x4c>
    {
      if (d0 > n1)
  801b5e:	39 f1                	cmp    %esi,%ecx
  801b60:	77 5a                	ja     801bbc <__udivdi3+0x7c>
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  801b62:	85 c9                	test   %ecx,%ecx
  801b64:	75 0b                	jne    801b71 <__udivdi3+0x31>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  801b66:	b8 01 00 00 00       	mov    $0x1,%eax
  801b6b:	31 d2                	xor    %edx,%edx
  801b6d:	f7 f1                	div    %ecx
  801b6f:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  801b71:	31 d2                	xor    %edx,%edx
  801b73:	89 f0                	mov    %esi,%eax
  801b75:	f7 f1                	div    %ecx
  801b77:	89 c6                	mov    %eax,%esi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801b79:	89 f8                	mov    %edi,%eax
  801b7b:	f7 f1                	div    %ecx
  801b7d:	89 c7                	mov    %eax,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  801b7f:	89 f8                	mov    %edi,%eax
  801b81:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801b83:	83 c4 10             	add    $0x10,%esp
  801b86:	5e                   	pop    %esi
  801b87:	5f                   	pop    %edi
  801b88:	c9                   	leave  
  801b89:	c3                   	ret    
  801b8a:	66 90                	xchg   %ax,%ax
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  801b8c:	39 f0                	cmp    %esi,%eax
  801b8e:	77 1c                	ja     801bac <__udivdi3+0x6c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  801b90:	0f bd f8             	bsr    %eax,%edi
	  if (bm == 0)
  801b93:	83 f7 1f             	xor    $0x1f,%edi
  801b96:	75 3c                	jne    801bd4 <__udivdi3+0x94>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  801b98:	39 f0                	cmp    %esi,%eax
  801b9a:	0f 82 90 00 00 00    	jb     801c30 <__udivdi3+0xf0>
  801ba0:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801ba3:	39 55 f4             	cmp    %edx,-0xc(%ebp)
  801ba6:	0f 86 84 00 00 00    	jbe    801c30 <__udivdi3+0xf0>
  801bac:	31 f6                	xor    %esi,%esi
  801bae:	31 ff                	xor    %edi,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  801bb0:	89 f8                	mov    %edi,%eax
  801bb2:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801bb4:	83 c4 10             	add    $0x10,%esp
  801bb7:	5e                   	pop    %esi
  801bb8:	5f                   	pop    %edi
  801bb9:	c9                   	leave  
  801bba:	c3                   	ret    
  801bbb:	90                   	nop
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801bbc:	89 f2                	mov    %esi,%edx
  801bbe:	89 f8                	mov    %edi,%eax
  801bc0:	f7 f1                	div    %ecx
  801bc2:	89 c7                	mov    %eax,%edi
  801bc4:	31 f6                	xor    %esi,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  801bc6:	89 f8                	mov    %edi,%eax
  801bc8:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801bca:	83 c4 10             	add    $0x10,%esp
  801bcd:	5e                   	pop    %esi
  801bce:	5f                   	pop    %edi
  801bcf:	c9                   	leave  
  801bd0:	c3                   	ret    
  801bd1:	8d 76 00             	lea    0x0(%esi),%esi
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  801bd4:	89 f9                	mov    %edi,%ecx
  801bd6:	d3 e0                	shl    %cl,%eax
  801bd8:	89 45 e8             	mov    %eax,-0x18(%ebp)
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  801bdb:	b8 20 00 00 00       	mov    $0x20,%eax
  801be0:	29 f8                	sub    %edi,%eax

	      d1 = (d1 << bm) | (d0 >> b);
  801be2:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801be5:	88 c1                	mov    %al,%cl
  801be7:	d3 ea                	shr    %cl,%edx
  801be9:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  801bec:	09 ca                	or     %ecx,%edx
  801bee:	89 55 ec             	mov    %edx,-0x14(%ebp)
	      d0 = d0 << bm;
  801bf1:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801bf4:	89 f9                	mov    %edi,%ecx
  801bf6:	d3 e2                	shl    %cl,%edx
  801bf8:	89 55 f4             	mov    %edx,-0xc(%ebp)
	      n2 = n1 >> b;
  801bfb:	89 f2                	mov    %esi,%edx
  801bfd:	88 c1                	mov    %al,%cl
  801bff:	d3 ea                	shr    %cl,%edx
  801c01:	89 55 e8             	mov    %edx,-0x18(%ebp)
	      n1 = (n1 << bm) | (n0 >> b);
  801c04:	89 f2                	mov    %esi,%edx
  801c06:	89 f9                	mov    %edi,%ecx
  801c08:	d3 e2                	shl    %cl,%edx
  801c0a:	8b 75 f0             	mov    -0x10(%ebp),%esi
  801c0d:	88 c1                	mov    %al,%cl
  801c0f:	d3 ee                	shr    %cl,%esi
  801c11:	09 d6                	or     %edx,%esi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  801c13:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  801c16:	89 f0                	mov    %esi,%eax
  801c18:	89 ca                	mov    %ecx,%edx
  801c1a:	f7 75 ec             	divl   -0x14(%ebp)
  801c1d:	89 d1                	mov    %edx,%ecx
  801c1f:	89 c6                	mov    %eax,%esi
	      umul_ppmm (m1, m0, q0, d0);
  801c21:	f7 65 f4             	mull   -0xc(%ebp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801c24:	39 d1                	cmp    %edx,%ecx
  801c26:	72 28                	jb     801c50 <__udivdi3+0x110>
  801c28:	74 1a                	je     801c44 <__udivdi3+0x104>
  801c2a:	89 f7                	mov    %esi,%edi
  801c2c:	31 f6                	xor    %esi,%esi
  801c2e:	eb 80                	jmp    801bb0 <__udivdi3+0x70>
	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  801c30:	31 f6                	xor    %esi,%esi
  801c32:	bf 01 00 00 00       	mov    $0x1,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  801c37:	89 f8                	mov    %edi,%eax
  801c39:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801c3b:	83 c4 10             	add    $0x10,%esp
  801c3e:	5e                   	pop    %esi
  801c3f:	5f                   	pop    %edi
  801c40:	c9                   	leave  
  801c41:	c3                   	ret    
  801c42:	66 90                	xchg   %ax,%ax

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  801c44:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801c47:	89 f9                	mov    %edi,%ecx
  801c49:	d3 e2                	shl    %cl,%edx

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801c4b:	39 c2                	cmp    %eax,%edx
  801c4d:	73 db                	jae    801c2a <__udivdi3+0xea>
  801c4f:	90                   	nop
		{
		  q0--;
  801c50:	8d 7e ff             	lea    -0x1(%esi),%edi
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  801c53:	31 f6                	xor    %esi,%esi
  801c55:	e9 56 ff ff ff       	jmp    801bb0 <__udivdi3+0x70>
	...

00801c5c <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  801c5c:	55                   	push   %ebp
  801c5d:	89 e5                	mov    %esp,%ebp
  801c5f:	57                   	push   %edi
  801c60:	56                   	push   %esi
  801c61:	83 ec 20             	sub    $0x20,%esp
  801c64:	8b 45 08             	mov    0x8(%ebp),%eax
  801c67:	8b 4d 10             	mov    0x10(%ebp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  801c6a:	89 45 e8             	mov    %eax,-0x18(%ebp)
  801c6d:	8b 75 0c             	mov    0xc(%ebp),%esi
  const DWunion dd = {.ll = d};
  801c70:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  801c73:	8b 7d 14             	mov    0x14(%ebp),%edi
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  801c76:	89 45 f0             	mov    %eax,-0x10(%ebp)
  n1 = nn.s.high;
  801c79:	89 f2                	mov    %esi,%edx

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  801c7b:	85 ff                	test   %edi,%edi
  801c7d:	75 15                	jne    801c94 <__umoddi3+0x38>
    {
      if (d0 > n1)
  801c7f:	39 f1                	cmp    %esi,%ecx
  801c81:	0f 86 99 00 00 00    	jbe    801d20 <__umoddi3+0xc4>
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801c87:	f7 f1                	div    %ecx

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
  801c89:	89 d0                	mov    %edx,%eax
  801c8b:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  801c8d:	83 c4 20             	add    $0x20,%esp
  801c90:	5e                   	pop    %esi
  801c91:	5f                   	pop    %edi
  801c92:	c9                   	leave  
  801c93:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  801c94:	39 f7                	cmp    %esi,%edi
  801c96:	0f 87 a4 00 00 00    	ja     801d40 <__umoddi3+0xe4>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  801c9c:	0f bd c7             	bsr    %edi,%eax
	  if (bm == 0)
  801c9f:	83 f0 1f             	xor    $0x1f,%eax
  801ca2:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801ca5:	0f 84 a1 00 00 00    	je     801d4c <__umoddi3+0xf0>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  801cab:	89 f8                	mov    %edi,%eax
  801cad:	8a 4d ec             	mov    -0x14(%ebp),%cl
  801cb0:	d3 e0                	shl    %cl,%eax
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  801cb2:	bf 20 00 00 00       	mov    $0x20,%edi
  801cb7:	2b 7d ec             	sub    -0x14(%ebp),%edi

	      d1 = (d1 << bm) | (d0 >> b);
  801cba:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801cbd:	89 f9                	mov    %edi,%ecx
  801cbf:	d3 ea                	shr    %cl,%edx
  801cc1:	09 c2                	or     %eax,%edx
  801cc3:	89 55 f0             	mov    %edx,-0x10(%ebp)
	      d0 = d0 << bm;
  801cc6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801cc9:	8a 4d ec             	mov    -0x14(%ebp),%cl
  801ccc:	d3 e0                	shl    %cl,%eax
  801cce:	89 45 f4             	mov    %eax,-0xc(%ebp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  801cd1:	89 f2                	mov    %esi,%edx
  801cd3:	d3 e2                	shl    %cl,%edx
	      n0 = n0 << bm;
  801cd5:	8b 45 e8             	mov    -0x18(%ebp),%eax
  801cd8:	d3 e0                	shl    %cl,%eax
  801cda:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  801cdd:	8b 45 e8             	mov    -0x18(%ebp),%eax
  801ce0:	89 f9                	mov    %edi,%ecx
  801ce2:	d3 e8                	shr    %cl,%eax
  801ce4:	09 d0                	or     %edx,%eax

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  801ce6:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  801ce8:	89 f2                	mov    %esi,%edx
  801cea:	f7 75 f0             	divl   -0x10(%ebp)
  801ced:	89 d6                	mov    %edx,%esi
	      umul_ppmm (m1, m0, q0, d0);
  801cef:	f7 65 f4             	mull   -0xc(%ebp)
  801cf2:	89 55 e8             	mov    %edx,-0x18(%ebp)
  801cf5:	89 c1                	mov    %eax,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801cf7:	39 d6                	cmp    %edx,%esi
  801cf9:	72 71                	jb     801d6c <__umoddi3+0x110>
  801cfb:	74 7f                	je     801d7c <__umoddi3+0x120>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  801cfd:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801d00:	29 c8                	sub    %ecx,%eax
  801d02:	19 d6                	sbb    %edx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
  801d04:	8a 4d ec             	mov    -0x14(%ebp),%cl
  801d07:	d3 e8                	shr    %cl,%eax
  801d09:	89 f2                	mov    %esi,%edx
  801d0b:	89 f9                	mov    %edi,%ecx
  801d0d:	d3 e2                	shl    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
  801d0f:	09 d0                	or     %edx,%eax
  801d11:	89 f2                	mov    %esi,%edx
  801d13:	8a 4d ec             	mov    -0x14(%ebp),%cl
  801d16:	d3 ea                	shr    %cl,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  801d18:	83 c4 20             	add    $0x20,%esp
  801d1b:	5e                   	pop    %esi
  801d1c:	5f                   	pop    %edi
  801d1d:	c9                   	leave  
  801d1e:	c3                   	ret    
  801d1f:	90                   	nop
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  801d20:	85 c9                	test   %ecx,%ecx
  801d22:	75 0b                	jne    801d2f <__umoddi3+0xd3>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  801d24:	b8 01 00 00 00       	mov    $0x1,%eax
  801d29:	31 d2                	xor    %edx,%edx
  801d2b:	f7 f1                	div    %ecx
  801d2d:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  801d2f:	89 f0                	mov    %esi,%eax
  801d31:	31 d2                	xor    %edx,%edx
  801d33:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801d35:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801d38:	f7 f1                	div    %ecx
  801d3a:	e9 4a ff ff ff       	jmp    801c89 <__umoddi3+0x2d>
  801d3f:	90                   	nop
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
  801d40:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  801d42:	83 c4 20             	add    $0x20,%esp
  801d45:	5e                   	pop    %esi
  801d46:	5f                   	pop    %edi
  801d47:	c9                   	leave  
  801d48:	c3                   	ret    
  801d49:	8d 76 00             	lea    0x0(%esi),%esi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  801d4c:	39 f7                	cmp    %esi,%edi
  801d4e:	72 05                	jb     801d55 <__umoddi3+0xf9>
  801d50:	3b 4d f0             	cmp    -0x10(%ebp),%ecx
  801d53:	77 0c                	ja     801d61 <__umoddi3+0x105>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  801d55:	89 f2                	mov    %esi,%edx
  801d57:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801d5a:	29 c8                	sub    %ecx,%eax
  801d5c:	19 fa                	sbb    %edi,%edx
  801d5e:	89 45 f0             	mov    %eax,-0x10(%ebp)

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
  801d61:	8b 45 f0             	mov    -0x10(%ebp),%eax
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  801d64:	83 c4 20             	add    $0x20,%esp
  801d67:	5e                   	pop    %esi
  801d68:	5f                   	pop    %edi
  801d69:	c9                   	leave  
  801d6a:	c3                   	ret    
  801d6b:	90                   	nop
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  801d6c:	8b 55 e8             	mov    -0x18(%ebp),%edx
  801d6f:	89 c1                	mov    %eax,%ecx
  801d71:	2b 4d f4             	sub    -0xc(%ebp),%ecx
  801d74:	1b 55 f0             	sbb    -0x10(%ebp),%edx
  801d77:	eb 84                	jmp    801cfd <__umoddi3+0xa1>
  801d79:	8d 76 00             	lea    0x0(%esi),%esi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801d7c:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  801d7f:	72 eb                	jb     801d6c <__umoddi3+0x110>
  801d81:	89 f2                	mov    %esi,%edx
  801d83:	e9 75 ff ff ff       	jmp    801cfd <__umoddi3+0xa1>
