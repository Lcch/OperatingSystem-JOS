
obj/user/faultevilhandler.debug:     file format elf32-i386


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
  80002c:	e8 37 00 00 00       	call   800068 <libmain>
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
  800037:	83 ec 0c             	sub    $0xc,%esp
	sys_page_alloc(0, (void*) (UXSTACKTOP - PGSIZE), PTE_P|PTE_U|PTE_W);
  80003a:	6a 07                	push   $0x7
  80003c:	68 00 f0 bf ee       	push   $0xeebff000
  800041:	6a 00                	push   $0x0
  800043:	e8 90 01 00 00       	call   8001d8 <sys_page_alloc>
	sys_env_set_pgfault_upcall(0, (void*) 0xF0100020);
  800048:	83 c4 08             	add    $0x8,%esp
  80004b:	68 20 00 10 f0       	push   $0xf0100020
  800050:	6a 00                	push   $0x0
  800052:	e8 34 02 00 00       	call   80028b <sys_env_set_pgfault_upcall>
	*(int*)0 = 0;
  800057:	c7 05 00 00 00 00 00 	movl   $0x0,0x0
  80005e:	00 00 00 
  800061:	83 c4 10             	add    $0x10,%esp
}
  800064:	c9                   	leave  
  800065:	c3                   	ret    
	...

00800068 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800068:	55                   	push   %ebp
  800069:	89 e5                	mov    %esp,%ebp
  80006b:	56                   	push   %esi
  80006c:	53                   	push   %ebx
  80006d:	8b 75 08             	mov    0x8(%ebp),%esi
  800070:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = envs + ENVX(sys_getenvid());
  800073:	e8 15 01 00 00       	call   80018d <sys_getenvid>
  800078:	25 ff 03 00 00       	and    $0x3ff,%eax
  80007d:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  800084:	c1 e0 07             	shl    $0x7,%eax
  800087:	29 d0                	sub    %edx,%eax
  800089:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80008e:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800093:	85 f6                	test   %esi,%esi
  800095:	7e 07                	jle    80009e <libmain+0x36>
		binaryname = argv[0];
  800097:	8b 03                	mov    (%ebx),%eax
  800099:	a3 00 30 80 00       	mov    %eax,0x803000
	// call user main routine
	umain(argc, argv);
  80009e:	83 ec 08             	sub    $0x8,%esp
  8000a1:	53                   	push   %ebx
  8000a2:	56                   	push   %esi
  8000a3:	e8 8c ff ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  8000a8:	e8 0b 00 00 00       	call   8000b8 <exit>
  8000ad:	83 c4 10             	add    $0x10,%esp
}
  8000b0:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000b3:	5b                   	pop    %ebx
  8000b4:	5e                   	pop    %esi
  8000b5:	c9                   	leave  
  8000b6:	c3                   	ret    
	...

008000b8 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000b8:	55                   	push   %ebp
  8000b9:	89 e5                	mov    %esp,%ebp
  8000bb:	83 ec 08             	sub    $0x8,%esp
	close_all();
  8000be:	e8 5f 04 00 00       	call   800522 <close_all>
	sys_env_destroy(0);
  8000c3:	83 ec 0c             	sub    $0xc,%esp
  8000c6:	6a 00                	push   $0x0
  8000c8:	e8 9e 00 00 00       	call   80016b <sys_env_destroy>
  8000cd:	83 c4 10             	add    $0x10,%esp
}
  8000d0:	c9                   	leave  
  8000d1:	c3                   	ret    
	...

008000d4 <syscall>:
	return ret;
}

static int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  8000d4:	55                   	push   %ebp
  8000d5:	89 e5                	mov    %esp,%ebp
  8000d7:	57                   	push   %edi
  8000d8:	56                   	push   %esi
  8000d9:	53                   	push   %ebx
  8000da:	83 ec 1c             	sub    $0x1c,%esp
  8000dd:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8000e0:	89 55 e0             	mov    %edx,-0x20(%ebp)
  8000e3:	89 ca                	mov    %ecx,%edx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000e5:	8b 75 14             	mov    0x14(%ebp),%esi
  8000e8:	8b 7d 10             	mov    0x10(%ebp),%edi
  8000eb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8000ee:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8000f1:	cd 30                	int    $0x30
  8000f3:	89 c2                	mov    %eax,%edx
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8000f5:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8000f9:	74 1c                	je     800117 <syscall+0x43>
  8000fb:	85 c0                	test   %eax,%eax
  8000fd:	7e 18                	jle    800117 <syscall+0x43>
		panic("syscall %d returned %d (> 0)", num, ret);
  8000ff:	83 ec 0c             	sub    $0xc,%esp
  800102:	50                   	push   %eax
  800103:	ff 75 e4             	pushl  -0x1c(%ebp)
  800106:	68 ea 1d 80 00       	push   $0x801dea
  80010b:	6a 42                	push   $0x42
  80010d:	68 07 1e 80 00       	push   $0x801e07
  800112:	e8 d5 0e 00 00       	call   800fec <_panic>

	return ret;
}
  800117:	89 d0                	mov    %edx,%eax
  800119:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80011c:	5b                   	pop    %ebx
  80011d:	5e                   	pop    %esi
  80011e:	5f                   	pop    %edi
  80011f:	c9                   	leave  
  800120:	c3                   	ret    

00800121 <sys_cputs>:

void
sys_cputs(const char *s, size_t len)
{	
  800121:	55                   	push   %ebp
  800122:	89 e5                	mov    %esp,%ebp
  800124:	83 ec 08             	sub    $0x8,%esp
	// my_sysenter(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
	// return;
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
  800127:	6a 00                	push   $0x0
  800129:	6a 00                	push   $0x0
  80012b:	6a 00                	push   $0x0
  80012d:	ff 75 0c             	pushl  0xc(%ebp)
  800130:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800133:	ba 00 00 00 00       	mov    $0x0,%edx
  800138:	b8 00 00 00 00       	mov    $0x0,%eax
  80013d:	e8 92 ff ff ff       	call   8000d4 <syscall>
  800142:	83 c4 10             	add    $0x10,%esp
	return;
}
  800145:	c9                   	leave  
  800146:	c3                   	ret    

00800147 <sys_cgetc>:

int
sys_cgetc(void)
{
  800147:	55                   	push   %ebp
  800148:	89 e5                	mov    %esp,%ebp
  80014a:	83 ec 08             	sub    $0x8,%esp
	// return my_sysenter(SYS_cgetc, 0, 0, 0, 0, 0, 0);
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
  80014d:	6a 00                	push   $0x0
  80014f:	6a 00                	push   $0x0
  800151:	6a 00                	push   $0x0
  800153:	6a 00                	push   $0x0
  800155:	b9 00 00 00 00       	mov    $0x0,%ecx
  80015a:	ba 00 00 00 00       	mov    $0x0,%edx
  80015f:	b8 01 00 00 00       	mov    $0x1,%eax
  800164:	e8 6b ff ff ff       	call   8000d4 <syscall>
}
  800169:	c9                   	leave  
  80016a:	c3                   	ret    

0080016b <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  80016b:	55                   	push   %ebp
  80016c:	89 e5                	mov    %esp,%ebp
  80016e:	83 ec 08             	sub    $0x8,%esp
	// return my_sysenter(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
  800171:	6a 00                	push   $0x0
  800173:	6a 00                	push   $0x0
  800175:	6a 00                	push   $0x0
  800177:	6a 00                	push   $0x0
  800179:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80017c:	ba 01 00 00 00       	mov    $0x1,%edx
  800181:	b8 03 00 00 00       	mov    $0x3,%eax
  800186:	e8 49 ff ff ff       	call   8000d4 <syscall>
}
  80018b:	c9                   	leave  
  80018c:	c3                   	ret    

0080018d <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  80018d:	55                   	push   %ebp
  80018e:	89 e5                	mov    %esp,%ebp
  800190:	83 ec 08             	sub    $0x8,%esp
	// return my_sysenter(SYS_getenvid, 0, 0, 0, 0, 0, 0);
	return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
  800193:	6a 00                	push   $0x0
  800195:	6a 00                	push   $0x0
  800197:	6a 00                	push   $0x0
  800199:	6a 00                	push   $0x0
  80019b:	b9 00 00 00 00       	mov    $0x0,%ecx
  8001a0:	ba 00 00 00 00       	mov    $0x0,%edx
  8001a5:	b8 02 00 00 00       	mov    $0x2,%eax
  8001aa:	e8 25 ff ff ff       	call   8000d4 <syscall>
}
  8001af:	c9                   	leave  
  8001b0:	c3                   	ret    

008001b1 <sys_yield>:

void
sys_yield(void)
{
  8001b1:	55                   	push   %ebp
  8001b2:	89 e5                	mov    %esp,%ebp
  8001b4:	83 ec 08             	sub    $0x8,%esp
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
  8001b7:	6a 00                	push   $0x0
  8001b9:	6a 00                	push   $0x0
  8001bb:	6a 00                	push   $0x0
  8001bd:	6a 00                	push   $0x0
  8001bf:	b9 00 00 00 00       	mov    $0x0,%ecx
  8001c4:	ba 00 00 00 00       	mov    $0x0,%edx
  8001c9:	b8 0b 00 00 00       	mov    $0xb,%eax
  8001ce:	e8 01 ff ff ff       	call   8000d4 <syscall>
  8001d3:	83 c4 10             	add    $0x10,%esp
}
  8001d6:	c9                   	leave  
  8001d7:	c3                   	ret    

008001d8 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  8001d8:	55                   	push   %ebp
  8001d9:	89 e5                	mov    %esp,%ebp
  8001db:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
  8001de:	6a 00                	push   $0x0
  8001e0:	6a 00                	push   $0x0
  8001e2:	ff 75 10             	pushl  0x10(%ebp)
  8001e5:	ff 75 0c             	pushl  0xc(%ebp)
  8001e8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8001eb:	ba 01 00 00 00       	mov    $0x1,%edx
  8001f0:	b8 04 00 00 00       	mov    $0x4,%eax
  8001f5:	e8 da fe ff ff       	call   8000d4 <syscall>
}
  8001fa:	c9                   	leave  
  8001fb:	c3                   	ret    

008001fc <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8001fc:	55                   	push   %ebp
  8001fd:	89 e5                	mov    %esp,%ebp
  8001ff:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
  800202:	ff 75 18             	pushl  0x18(%ebp)
  800205:	ff 75 14             	pushl  0x14(%ebp)
  800208:	ff 75 10             	pushl  0x10(%ebp)
  80020b:	ff 75 0c             	pushl  0xc(%ebp)
  80020e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800211:	ba 01 00 00 00       	mov    $0x1,%edx
  800216:	b8 05 00 00 00       	mov    $0x5,%eax
  80021b:	e8 b4 fe ff ff       	call   8000d4 <syscall>
}
  800220:	c9                   	leave  
  800221:	c3                   	ret    

00800222 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800222:	55                   	push   %ebp
  800223:	89 e5                	mov    %esp,%ebp
  800225:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
  800228:	6a 00                	push   $0x0
  80022a:	6a 00                	push   $0x0
  80022c:	6a 00                	push   $0x0
  80022e:	ff 75 0c             	pushl  0xc(%ebp)
  800231:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800234:	ba 01 00 00 00       	mov    $0x1,%edx
  800239:	b8 06 00 00 00       	mov    $0x6,%eax
  80023e:	e8 91 fe ff ff       	call   8000d4 <syscall>
}
  800243:	c9                   	leave  
  800244:	c3                   	ret    

00800245 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800245:	55                   	push   %ebp
  800246:	89 e5                	mov    %esp,%ebp
  800248:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
  80024b:	6a 00                	push   $0x0
  80024d:	6a 00                	push   $0x0
  80024f:	6a 00                	push   $0x0
  800251:	ff 75 0c             	pushl  0xc(%ebp)
  800254:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800257:	ba 01 00 00 00       	mov    $0x1,%edx
  80025c:	b8 08 00 00 00       	mov    $0x8,%eax
  800261:	e8 6e fe ff ff       	call   8000d4 <syscall>
}
  800266:	c9                   	leave  
  800267:	c3                   	ret    

00800268 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800268:	55                   	push   %ebp
  800269:	89 e5                	mov    %esp,%ebp
  80026b:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
  80026e:	6a 00                	push   $0x0
  800270:	6a 00                	push   $0x0
  800272:	6a 00                	push   $0x0
  800274:	ff 75 0c             	pushl  0xc(%ebp)
  800277:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80027a:	ba 01 00 00 00       	mov    $0x1,%edx
  80027f:	b8 09 00 00 00       	mov    $0x9,%eax
  800284:	e8 4b fe ff ff       	call   8000d4 <syscall>
}
  800289:	c9                   	leave  
  80028a:	c3                   	ret    

0080028b <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  80028b:	55                   	push   %ebp
  80028c:	89 e5                	mov    %esp,%ebp
  80028e:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
  800291:	6a 00                	push   $0x0
  800293:	6a 00                	push   $0x0
  800295:	6a 00                	push   $0x0
  800297:	ff 75 0c             	pushl  0xc(%ebp)
  80029a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80029d:	ba 01 00 00 00       	mov    $0x1,%edx
  8002a2:	b8 0a 00 00 00       	mov    $0xa,%eax
  8002a7:	e8 28 fe ff ff       	call   8000d4 <syscall>
}
  8002ac:	c9                   	leave  
  8002ad:	c3                   	ret    

008002ae <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8002ae:	55                   	push   %ebp
  8002af:	89 e5                	mov    %esp,%ebp
  8002b1:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
  8002b4:	6a 00                	push   $0x0
  8002b6:	ff 75 14             	pushl  0x14(%ebp)
  8002b9:	ff 75 10             	pushl  0x10(%ebp)
  8002bc:	ff 75 0c             	pushl  0xc(%ebp)
  8002bf:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8002c2:	ba 00 00 00 00       	mov    $0x0,%edx
  8002c7:	b8 0c 00 00 00       	mov    $0xc,%eax
  8002cc:	e8 03 fe ff ff       	call   8000d4 <syscall>
}
  8002d1:	c9                   	leave  
  8002d2:	c3                   	ret    

008002d3 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  8002d3:	55                   	push   %ebp
  8002d4:	89 e5                	mov    %esp,%ebp
  8002d6:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
  8002d9:	6a 00                	push   $0x0
  8002db:	6a 00                	push   $0x0
  8002dd:	6a 00                	push   $0x0
  8002df:	6a 00                	push   $0x0
  8002e1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8002e4:	ba 01 00 00 00       	mov    $0x1,%edx
  8002e9:	b8 0d 00 00 00       	mov    $0xd,%eax
  8002ee:	e8 e1 fd ff ff       	call   8000d4 <syscall>
}
  8002f3:	c9                   	leave  
  8002f4:	c3                   	ret    

008002f5 <sys_set_priority>:

int
sys_set_priority(envid_t envid, uint32_t new_priority)
{
  8002f5:	55                   	push   %ebp
  8002f6:	89 e5                	mov    %esp,%ebp
  8002f8:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_set_priority, 0, envid, new_priority, 0, 0, 0);
  8002fb:	6a 00                	push   $0x0
  8002fd:	6a 00                	push   $0x0
  8002ff:	6a 00                	push   $0x0
  800301:	ff 75 0c             	pushl  0xc(%ebp)
  800304:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800307:	ba 00 00 00 00       	mov    $0x0,%edx
  80030c:	b8 0e 00 00 00       	mov    $0xe,%eax
  800311:	e8 be fd ff ff       	call   8000d4 <syscall>
}
  800316:	c9                   	leave  
  800317:	c3                   	ret    

00800318 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800318:	55                   	push   %ebp
  800319:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80031b:	8b 45 08             	mov    0x8(%ebp),%eax
  80031e:	05 00 00 00 30       	add    $0x30000000,%eax
  800323:	c1 e8 0c             	shr    $0xc,%eax
}
  800326:	c9                   	leave  
  800327:	c3                   	ret    

00800328 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800328:	55                   	push   %ebp
  800329:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  80032b:	ff 75 08             	pushl  0x8(%ebp)
  80032e:	e8 e5 ff ff ff       	call   800318 <fd2num>
  800333:	83 c4 04             	add    $0x4,%esp
  800336:	05 20 00 0d 00       	add    $0xd0020,%eax
  80033b:	c1 e0 0c             	shl    $0xc,%eax
}
  80033e:	c9                   	leave  
  80033f:	c3                   	ret    

00800340 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800340:	55                   	push   %ebp
  800341:	89 e5                	mov    %esp,%ebp
  800343:	53                   	push   %ebx
  800344:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800347:	a1 00 dd 7b ef       	mov    0xef7bdd00,%eax
  80034c:	a8 01                	test   $0x1,%al
  80034e:	74 34                	je     800384 <fd_alloc+0x44>
  800350:	a1 00 00 74 ef       	mov    0xef740000,%eax
  800355:	a8 01                	test   $0x1,%al
  800357:	74 32                	je     80038b <fd_alloc+0x4b>
  800359:	b8 00 10 00 d0       	mov    $0xd0001000,%eax
  80035e:	89 c1                	mov    %eax,%ecx
  800360:	89 c2                	mov    %eax,%edx
  800362:	c1 ea 16             	shr    $0x16,%edx
  800365:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80036c:	f6 c2 01             	test   $0x1,%dl
  80036f:	74 1f                	je     800390 <fd_alloc+0x50>
  800371:	89 c2                	mov    %eax,%edx
  800373:	c1 ea 0c             	shr    $0xc,%edx
  800376:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80037d:	f6 c2 01             	test   $0x1,%dl
  800380:	75 17                	jne    800399 <fd_alloc+0x59>
  800382:	eb 0c                	jmp    800390 <fd_alloc+0x50>
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  800384:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
  800389:	eb 05                	jmp    800390 <fd_alloc+0x50>
  80038b:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
  800390:	89 0b                	mov    %ecx,(%ebx)
			return 0;
  800392:	b8 00 00 00 00       	mov    $0x0,%eax
  800397:	eb 17                	jmp    8003b0 <fd_alloc+0x70>
  800399:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  80039e:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8003a3:	75 b9                	jne    80035e <fd_alloc+0x1e>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8003a5:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_MAX_OPEN;
  8003ab:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8003b0:	5b                   	pop    %ebx
  8003b1:	c9                   	leave  
  8003b2:	c3                   	ret    

008003b3 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8003b3:	55                   	push   %ebp
  8003b4:	89 e5                	mov    %esp,%ebp
  8003b6:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8003b9:	83 f8 1f             	cmp    $0x1f,%eax
  8003bc:	77 36                	ja     8003f4 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8003be:	05 00 00 0d 00       	add    $0xd0000,%eax
  8003c3:	c1 e0 0c             	shl    $0xc,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8003c6:	89 c2                	mov    %eax,%edx
  8003c8:	c1 ea 16             	shr    $0x16,%edx
  8003cb:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8003d2:	f6 c2 01             	test   $0x1,%dl
  8003d5:	74 24                	je     8003fb <fd_lookup+0x48>
  8003d7:	89 c2                	mov    %eax,%edx
  8003d9:	c1 ea 0c             	shr    $0xc,%edx
  8003dc:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8003e3:	f6 c2 01             	test   $0x1,%dl
  8003e6:	74 1a                	je     800402 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8003e8:	8b 55 0c             	mov    0xc(%ebp),%edx
  8003eb:	89 02                	mov    %eax,(%edx)
	return 0;
  8003ed:	b8 00 00 00 00       	mov    $0x0,%eax
  8003f2:	eb 13                	jmp    800407 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8003f4:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8003f9:	eb 0c                	jmp    800407 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8003fb:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800400:	eb 05                	jmp    800407 <fd_lookup+0x54>
  800402:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800407:	c9                   	leave  
  800408:	c3                   	ret    

00800409 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800409:	55                   	push   %ebp
  80040a:	89 e5                	mov    %esp,%ebp
  80040c:	53                   	push   %ebx
  80040d:	83 ec 04             	sub    $0x4,%esp
  800410:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800413:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
		if (devtab[i]->dev_id == dev_id) {
  800416:	39 0d 04 30 80 00    	cmp    %ecx,0x803004
  80041c:	74 0d                	je     80042b <dev_lookup+0x22>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  80041e:	b8 00 00 00 00       	mov    $0x0,%eax
  800423:	eb 14                	jmp    800439 <dev_lookup+0x30>
		if (devtab[i]->dev_id == dev_id) {
  800425:	39 0a                	cmp    %ecx,(%edx)
  800427:	75 10                	jne    800439 <dev_lookup+0x30>
  800429:	eb 05                	jmp    800430 <dev_lookup+0x27>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  80042b:	ba 04 30 80 00       	mov    $0x803004,%edx
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
  800430:	89 13                	mov    %edx,(%ebx)
			return 0;
  800432:	b8 00 00 00 00       	mov    $0x0,%eax
  800437:	eb 31                	jmp    80046a <dev_lookup+0x61>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800439:	40                   	inc    %eax
  80043a:	8b 14 85 94 1e 80 00 	mov    0x801e94(,%eax,4),%edx
  800441:	85 d2                	test   %edx,%edx
  800443:	75 e0                	jne    800425 <dev_lookup+0x1c>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800445:	a1 04 40 80 00       	mov    0x804004,%eax
  80044a:	8b 40 48             	mov    0x48(%eax),%eax
  80044d:	83 ec 04             	sub    $0x4,%esp
  800450:	51                   	push   %ecx
  800451:	50                   	push   %eax
  800452:	68 18 1e 80 00       	push   $0x801e18
  800457:	e8 68 0c 00 00       	call   8010c4 <cprintf>
	*dev = 0;
  80045c:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_INVAL;
  800462:	83 c4 10             	add    $0x10,%esp
  800465:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  80046a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80046d:	c9                   	leave  
  80046e:	c3                   	ret    

0080046f <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  80046f:	55                   	push   %ebp
  800470:	89 e5                	mov    %esp,%ebp
  800472:	56                   	push   %esi
  800473:	53                   	push   %ebx
  800474:	83 ec 20             	sub    $0x20,%esp
  800477:	8b 75 08             	mov    0x8(%ebp),%esi
  80047a:	8a 45 0c             	mov    0xc(%ebp),%al
  80047d:	88 45 e7             	mov    %al,-0x19(%ebp)
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800480:	56                   	push   %esi
  800481:	e8 92 fe ff ff       	call   800318 <fd2num>
  800486:	8d 55 f4             	lea    -0xc(%ebp),%edx
  800489:	89 14 24             	mov    %edx,(%esp)
  80048c:	50                   	push   %eax
  80048d:	e8 21 ff ff ff       	call   8003b3 <fd_lookup>
  800492:	89 c3                	mov    %eax,%ebx
  800494:	83 c4 08             	add    $0x8,%esp
  800497:	85 c0                	test   %eax,%eax
  800499:	78 05                	js     8004a0 <fd_close+0x31>
	    || fd != fd2)
  80049b:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  80049e:	74 0d                	je     8004ad <fd_close+0x3e>
		return (must_exist ? r : 0);
  8004a0:	80 7d e7 00          	cmpb   $0x0,-0x19(%ebp)
  8004a4:	75 48                	jne    8004ee <fd_close+0x7f>
  8004a6:	bb 00 00 00 00       	mov    $0x0,%ebx
  8004ab:	eb 41                	jmp    8004ee <fd_close+0x7f>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8004ad:	83 ec 08             	sub    $0x8,%esp
  8004b0:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8004b3:	50                   	push   %eax
  8004b4:	ff 36                	pushl  (%esi)
  8004b6:	e8 4e ff ff ff       	call   800409 <dev_lookup>
  8004bb:	89 c3                	mov    %eax,%ebx
  8004bd:	83 c4 10             	add    $0x10,%esp
  8004c0:	85 c0                	test   %eax,%eax
  8004c2:	78 1c                	js     8004e0 <fd_close+0x71>
		if (dev->dev_close)
  8004c4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8004c7:	8b 40 10             	mov    0x10(%eax),%eax
  8004ca:	85 c0                	test   %eax,%eax
  8004cc:	74 0d                	je     8004db <fd_close+0x6c>
			r = (*dev->dev_close)(fd);
  8004ce:	83 ec 0c             	sub    $0xc,%esp
  8004d1:	56                   	push   %esi
  8004d2:	ff d0                	call   *%eax
  8004d4:	89 c3                	mov    %eax,%ebx
  8004d6:	83 c4 10             	add    $0x10,%esp
  8004d9:	eb 05                	jmp    8004e0 <fd_close+0x71>
		else
			r = 0;
  8004db:	bb 00 00 00 00       	mov    $0x0,%ebx
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8004e0:	83 ec 08             	sub    $0x8,%esp
  8004e3:	56                   	push   %esi
  8004e4:	6a 00                	push   $0x0
  8004e6:	e8 37 fd ff ff       	call   800222 <sys_page_unmap>
	return r;
  8004eb:	83 c4 10             	add    $0x10,%esp
}
  8004ee:	89 d8                	mov    %ebx,%eax
  8004f0:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8004f3:	5b                   	pop    %ebx
  8004f4:	5e                   	pop    %esi
  8004f5:	c9                   	leave  
  8004f6:	c3                   	ret    

008004f7 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8004f7:	55                   	push   %ebp
  8004f8:	89 e5                	mov    %esp,%ebp
  8004fa:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8004fd:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800500:	50                   	push   %eax
  800501:	ff 75 08             	pushl  0x8(%ebp)
  800504:	e8 aa fe ff ff       	call   8003b3 <fd_lookup>
  800509:	83 c4 08             	add    $0x8,%esp
  80050c:	85 c0                	test   %eax,%eax
  80050e:	78 10                	js     800520 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  800510:	83 ec 08             	sub    $0x8,%esp
  800513:	6a 01                	push   $0x1
  800515:	ff 75 f4             	pushl  -0xc(%ebp)
  800518:	e8 52 ff ff ff       	call   80046f <fd_close>
  80051d:	83 c4 10             	add    $0x10,%esp
}
  800520:	c9                   	leave  
  800521:	c3                   	ret    

00800522 <close_all>:

void
close_all(void)
{
  800522:	55                   	push   %ebp
  800523:	89 e5                	mov    %esp,%ebp
  800525:	53                   	push   %ebx
  800526:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800529:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  80052e:	83 ec 0c             	sub    $0xc,%esp
  800531:	53                   	push   %ebx
  800532:	e8 c0 ff ff ff       	call   8004f7 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  800537:	43                   	inc    %ebx
  800538:	83 c4 10             	add    $0x10,%esp
  80053b:	83 fb 20             	cmp    $0x20,%ebx
  80053e:	75 ee                	jne    80052e <close_all+0xc>
		close(i);
}
  800540:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800543:	c9                   	leave  
  800544:	c3                   	ret    

00800545 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800545:	55                   	push   %ebp
  800546:	89 e5                	mov    %esp,%ebp
  800548:	57                   	push   %edi
  800549:	56                   	push   %esi
  80054a:	53                   	push   %ebx
  80054b:	83 ec 2c             	sub    $0x2c,%esp
  80054e:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  800551:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800554:	50                   	push   %eax
  800555:	ff 75 08             	pushl  0x8(%ebp)
  800558:	e8 56 fe ff ff       	call   8003b3 <fd_lookup>
  80055d:	89 c3                	mov    %eax,%ebx
  80055f:	83 c4 08             	add    $0x8,%esp
  800562:	85 c0                	test   %eax,%eax
  800564:	0f 88 c0 00 00 00    	js     80062a <dup+0xe5>
		return r;
	close(newfdnum);
  80056a:	83 ec 0c             	sub    $0xc,%esp
  80056d:	57                   	push   %edi
  80056e:	e8 84 ff ff ff       	call   8004f7 <close>

	newfd = INDEX2FD(newfdnum);
  800573:	8d b7 00 00 0d 00    	lea    0xd0000(%edi),%esi
  800579:	c1 e6 0c             	shl    $0xc,%esi
	ova = fd2data(oldfd);
  80057c:	83 c4 04             	add    $0x4,%esp
  80057f:	ff 75 e4             	pushl  -0x1c(%ebp)
  800582:	e8 a1 fd ff ff       	call   800328 <fd2data>
  800587:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  800589:	89 34 24             	mov    %esi,(%esp)
  80058c:	e8 97 fd ff ff       	call   800328 <fd2data>
  800591:	83 c4 10             	add    $0x10,%esp
  800594:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  800597:	89 d8                	mov    %ebx,%eax
  800599:	c1 e8 16             	shr    $0x16,%eax
  80059c:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8005a3:	a8 01                	test   $0x1,%al
  8005a5:	74 37                	je     8005de <dup+0x99>
  8005a7:	89 d8                	mov    %ebx,%eax
  8005a9:	c1 e8 0c             	shr    $0xc,%eax
  8005ac:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8005b3:	f6 c2 01             	test   $0x1,%dl
  8005b6:	74 26                	je     8005de <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8005b8:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8005bf:	83 ec 0c             	sub    $0xc,%esp
  8005c2:	25 07 0e 00 00       	and    $0xe07,%eax
  8005c7:	50                   	push   %eax
  8005c8:	ff 75 d4             	pushl  -0x2c(%ebp)
  8005cb:	6a 00                	push   $0x0
  8005cd:	53                   	push   %ebx
  8005ce:	6a 00                	push   $0x0
  8005d0:	e8 27 fc ff ff       	call   8001fc <sys_page_map>
  8005d5:	89 c3                	mov    %eax,%ebx
  8005d7:	83 c4 20             	add    $0x20,%esp
  8005da:	85 c0                	test   %eax,%eax
  8005dc:	78 2d                	js     80060b <dup+0xc6>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8005de:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8005e1:	89 c2                	mov    %eax,%edx
  8005e3:	c1 ea 0c             	shr    $0xc,%edx
  8005e6:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8005ed:	83 ec 0c             	sub    $0xc,%esp
  8005f0:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  8005f6:	52                   	push   %edx
  8005f7:	56                   	push   %esi
  8005f8:	6a 00                	push   $0x0
  8005fa:	50                   	push   %eax
  8005fb:	6a 00                	push   $0x0
  8005fd:	e8 fa fb ff ff       	call   8001fc <sys_page_map>
  800602:	89 c3                	mov    %eax,%ebx
  800604:	83 c4 20             	add    $0x20,%esp
  800607:	85 c0                	test   %eax,%eax
  800609:	79 1d                	jns    800628 <dup+0xe3>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  80060b:	83 ec 08             	sub    $0x8,%esp
  80060e:	56                   	push   %esi
  80060f:	6a 00                	push   $0x0
  800611:	e8 0c fc ff ff       	call   800222 <sys_page_unmap>
	sys_page_unmap(0, nva);
  800616:	83 c4 08             	add    $0x8,%esp
  800619:	ff 75 d4             	pushl  -0x2c(%ebp)
  80061c:	6a 00                	push   $0x0
  80061e:	e8 ff fb ff ff       	call   800222 <sys_page_unmap>
	return r;
  800623:	83 c4 10             	add    $0x10,%esp
  800626:	eb 02                	jmp    80062a <dup+0xe5>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
		goto err;

	return newfdnum;
  800628:	89 fb                	mov    %edi,%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  80062a:	89 d8                	mov    %ebx,%eax
  80062c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80062f:	5b                   	pop    %ebx
  800630:	5e                   	pop    %esi
  800631:	5f                   	pop    %edi
  800632:	c9                   	leave  
  800633:	c3                   	ret    

00800634 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  800634:	55                   	push   %ebp
  800635:	89 e5                	mov    %esp,%ebp
  800637:	53                   	push   %ebx
  800638:	83 ec 14             	sub    $0x14,%esp
  80063b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80063e:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800641:	50                   	push   %eax
  800642:	53                   	push   %ebx
  800643:	e8 6b fd ff ff       	call   8003b3 <fd_lookup>
  800648:	83 c4 08             	add    $0x8,%esp
  80064b:	85 c0                	test   %eax,%eax
  80064d:	78 67                	js     8006b6 <read+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80064f:	83 ec 08             	sub    $0x8,%esp
  800652:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800655:	50                   	push   %eax
  800656:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800659:	ff 30                	pushl  (%eax)
  80065b:	e8 a9 fd ff ff       	call   800409 <dev_lookup>
  800660:	83 c4 10             	add    $0x10,%esp
  800663:	85 c0                	test   %eax,%eax
  800665:	78 4f                	js     8006b6 <read+0x82>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  800667:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80066a:	8b 50 08             	mov    0x8(%eax),%edx
  80066d:	83 e2 03             	and    $0x3,%edx
  800670:	83 fa 01             	cmp    $0x1,%edx
  800673:	75 21                	jne    800696 <read+0x62>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  800675:	a1 04 40 80 00       	mov    0x804004,%eax
  80067a:	8b 40 48             	mov    0x48(%eax),%eax
  80067d:	83 ec 04             	sub    $0x4,%esp
  800680:	53                   	push   %ebx
  800681:	50                   	push   %eax
  800682:	68 59 1e 80 00       	push   $0x801e59
  800687:	e8 38 0a 00 00       	call   8010c4 <cprintf>
		return -E_INVAL;
  80068c:	83 c4 10             	add    $0x10,%esp
  80068f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800694:	eb 20                	jmp    8006b6 <read+0x82>
	}
	if (!dev->dev_read)
  800696:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800699:	8b 52 08             	mov    0x8(%edx),%edx
  80069c:	85 d2                	test   %edx,%edx
  80069e:	74 11                	je     8006b1 <read+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8006a0:	83 ec 04             	sub    $0x4,%esp
  8006a3:	ff 75 10             	pushl  0x10(%ebp)
  8006a6:	ff 75 0c             	pushl  0xc(%ebp)
  8006a9:	50                   	push   %eax
  8006aa:	ff d2                	call   *%edx
  8006ac:	83 c4 10             	add    $0x10,%esp
  8006af:	eb 05                	jmp    8006b6 <read+0x82>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8006b1:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_read)(fd, buf, n);
}
  8006b6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8006b9:	c9                   	leave  
  8006ba:	c3                   	ret    

008006bb <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8006bb:	55                   	push   %ebp
  8006bc:	89 e5                	mov    %esp,%ebp
  8006be:	57                   	push   %edi
  8006bf:	56                   	push   %esi
  8006c0:	53                   	push   %ebx
  8006c1:	83 ec 0c             	sub    $0xc,%esp
  8006c4:	8b 7d 08             	mov    0x8(%ebp),%edi
  8006c7:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8006ca:	85 f6                	test   %esi,%esi
  8006cc:	74 31                	je     8006ff <readn+0x44>
  8006ce:	b8 00 00 00 00       	mov    $0x0,%eax
  8006d3:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = read(fdnum, (char*)buf + tot, n - tot);
  8006d8:	83 ec 04             	sub    $0x4,%esp
  8006db:	89 f2                	mov    %esi,%edx
  8006dd:	29 c2                	sub    %eax,%edx
  8006df:	52                   	push   %edx
  8006e0:	03 45 0c             	add    0xc(%ebp),%eax
  8006e3:	50                   	push   %eax
  8006e4:	57                   	push   %edi
  8006e5:	e8 4a ff ff ff       	call   800634 <read>
		if (m < 0)
  8006ea:	83 c4 10             	add    $0x10,%esp
  8006ed:	85 c0                	test   %eax,%eax
  8006ef:	78 17                	js     800708 <readn+0x4d>
			return m;
		if (m == 0)
  8006f1:	85 c0                	test   %eax,%eax
  8006f3:	74 11                	je     800706 <readn+0x4b>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8006f5:	01 c3                	add    %eax,%ebx
  8006f7:	89 d8                	mov    %ebx,%eax
  8006f9:	39 f3                	cmp    %esi,%ebx
  8006fb:	72 db                	jb     8006d8 <readn+0x1d>
  8006fd:	eb 09                	jmp    800708 <readn+0x4d>
  8006ff:	b8 00 00 00 00       	mov    $0x0,%eax
  800704:	eb 02                	jmp    800708 <readn+0x4d>
		m = read(fdnum, (char*)buf + tot, n - tot);
		if (m < 0)
			return m;
		if (m == 0)
  800706:	89 d8                	mov    %ebx,%eax
			break;
	}
	return tot;
}
  800708:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80070b:	5b                   	pop    %ebx
  80070c:	5e                   	pop    %esi
  80070d:	5f                   	pop    %edi
  80070e:	c9                   	leave  
  80070f:	c3                   	ret    

00800710 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  800710:	55                   	push   %ebp
  800711:	89 e5                	mov    %esp,%ebp
  800713:	53                   	push   %ebx
  800714:	83 ec 14             	sub    $0x14,%esp
  800717:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80071a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80071d:	50                   	push   %eax
  80071e:	53                   	push   %ebx
  80071f:	e8 8f fc ff ff       	call   8003b3 <fd_lookup>
  800724:	83 c4 08             	add    $0x8,%esp
  800727:	85 c0                	test   %eax,%eax
  800729:	78 62                	js     80078d <write+0x7d>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80072b:	83 ec 08             	sub    $0x8,%esp
  80072e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800731:	50                   	push   %eax
  800732:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800735:	ff 30                	pushl  (%eax)
  800737:	e8 cd fc ff ff       	call   800409 <dev_lookup>
  80073c:	83 c4 10             	add    $0x10,%esp
  80073f:	85 c0                	test   %eax,%eax
  800741:	78 4a                	js     80078d <write+0x7d>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800743:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800746:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80074a:	75 21                	jne    80076d <write+0x5d>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  80074c:	a1 04 40 80 00       	mov    0x804004,%eax
  800751:	8b 40 48             	mov    0x48(%eax),%eax
  800754:	83 ec 04             	sub    $0x4,%esp
  800757:	53                   	push   %ebx
  800758:	50                   	push   %eax
  800759:	68 75 1e 80 00       	push   $0x801e75
  80075e:	e8 61 09 00 00       	call   8010c4 <cprintf>
		return -E_INVAL;
  800763:	83 c4 10             	add    $0x10,%esp
  800766:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80076b:	eb 20                	jmp    80078d <write+0x7d>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80076d:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800770:	8b 52 0c             	mov    0xc(%edx),%edx
  800773:	85 d2                	test   %edx,%edx
  800775:	74 11                	je     800788 <write+0x78>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  800777:	83 ec 04             	sub    $0x4,%esp
  80077a:	ff 75 10             	pushl  0x10(%ebp)
  80077d:	ff 75 0c             	pushl  0xc(%ebp)
  800780:	50                   	push   %eax
  800781:	ff d2                	call   *%edx
  800783:	83 c4 10             	add    $0x10,%esp
  800786:	eb 05                	jmp    80078d <write+0x7d>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  800788:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  80078d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800790:	c9                   	leave  
  800791:	c3                   	ret    

00800792 <seek>:

int
seek(int fdnum, off_t offset)
{
  800792:	55                   	push   %ebp
  800793:	89 e5                	mov    %esp,%ebp
  800795:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800798:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80079b:	50                   	push   %eax
  80079c:	ff 75 08             	pushl  0x8(%ebp)
  80079f:	e8 0f fc ff ff       	call   8003b3 <fd_lookup>
  8007a4:	83 c4 08             	add    $0x8,%esp
  8007a7:	85 c0                	test   %eax,%eax
  8007a9:	78 0e                	js     8007b9 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8007ab:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8007ae:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007b1:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8007b4:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8007b9:	c9                   	leave  
  8007ba:	c3                   	ret    

008007bb <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8007bb:	55                   	push   %ebp
  8007bc:	89 e5                	mov    %esp,%ebp
  8007be:	53                   	push   %ebx
  8007bf:	83 ec 14             	sub    $0x14,%esp
  8007c2:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8007c5:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8007c8:	50                   	push   %eax
  8007c9:	53                   	push   %ebx
  8007ca:	e8 e4 fb ff ff       	call   8003b3 <fd_lookup>
  8007cf:	83 c4 08             	add    $0x8,%esp
  8007d2:	85 c0                	test   %eax,%eax
  8007d4:	78 5f                	js     800835 <ftruncate+0x7a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8007d6:	83 ec 08             	sub    $0x8,%esp
  8007d9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8007dc:	50                   	push   %eax
  8007dd:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8007e0:	ff 30                	pushl  (%eax)
  8007e2:	e8 22 fc ff ff       	call   800409 <dev_lookup>
  8007e7:	83 c4 10             	add    $0x10,%esp
  8007ea:	85 c0                	test   %eax,%eax
  8007ec:	78 47                	js     800835 <ftruncate+0x7a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8007ee:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8007f1:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8007f5:	75 21                	jne    800818 <ftruncate+0x5d>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8007f7:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8007fc:	8b 40 48             	mov    0x48(%eax),%eax
  8007ff:	83 ec 04             	sub    $0x4,%esp
  800802:	53                   	push   %ebx
  800803:	50                   	push   %eax
  800804:	68 38 1e 80 00       	push   $0x801e38
  800809:	e8 b6 08 00 00       	call   8010c4 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  80080e:	83 c4 10             	add    $0x10,%esp
  800811:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800816:	eb 1d                	jmp    800835 <ftruncate+0x7a>
	}
	if (!dev->dev_trunc)
  800818:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80081b:	8b 52 18             	mov    0x18(%edx),%edx
  80081e:	85 d2                	test   %edx,%edx
  800820:	74 0e                	je     800830 <ftruncate+0x75>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  800822:	83 ec 08             	sub    $0x8,%esp
  800825:	ff 75 0c             	pushl  0xc(%ebp)
  800828:	50                   	push   %eax
  800829:	ff d2                	call   *%edx
  80082b:	83 c4 10             	add    $0x10,%esp
  80082e:	eb 05                	jmp    800835 <ftruncate+0x7a>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  800830:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  800835:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800838:	c9                   	leave  
  800839:	c3                   	ret    

0080083a <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  80083a:	55                   	push   %ebp
  80083b:	89 e5                	mov    %esp,%ebp
  80083d:	53                   	push   %ebx
  80083e:	83 ec 14             	sub    $0x14,%esp
  800841:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800844:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800847:	50                   	push   %eax
  800848:	ff 75 08             	pushl  0x8(%ebp)
  80084b:	e8 63 fb ff ff       	call   8003b3 <fd_lookup>
  800850:	83 c4 08             	add    $0x8,%esp
  800853:	85 c0                	test   %eax,%eax
  800855:	78 52                	js     8008a9 <fstat+0x6f>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800857:	83 ec 08             	sub    $0x8,%esp
  80085a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80085d:	50                   	push   %eax
  80085e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800861:	ff 30                	pushl  (%eax)
  800863:	e8 a1 fb ff ff       	call   800409 <dev_lookup>
  800868:	83 c4 10             	add    $0x10,%esp
  80086b:	85 c0                	test   %eax,%eax
  80086d:	78 3a                	js     8008a9 <fstat+0x6f>
		return r;
	if (!dev->dev_stat)
  80086f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800872:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  800876:	74 2c                	je     8008a4 <fstat+0x6a>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  800878:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  80087b:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  800882:	00 00 00 
	stat->st_isdir = 0;
  800885:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80088c:	00 00 00 
	stat->st_dev = dev;
  80088f:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  800895:	83 ec 08             	sub    $0x8,%esp
  800898:	53                   	push   %ebx
  800899:	ff 75 f0             	pushl  -0x10(%ebp)
  80089c:	ff 50 14             	call   *0x14(%eax)
  80089f:	83 c4 10             	add    $0x10,%esp
  8008a2:	eb 05                	jmp    8008a9 <fstat+0x6f>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8008a4:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8008a9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8008ac:	c9                   	leave  
  8008ad:	c3                   	ret    

008008ae <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8008ae:	55                   	push   %ebp
  8008af:	89 e5                	mov    %esp,%ebp
  8008b1:	56                   	push   %esi
  8008b2:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8008b3:	83 ec 08             	sub    $0x8,%esp
  8008b6:	6a 00                	push   $0x0
  8008b8:	ff 75 08             	pushl  0x8(%ebp)
  8008bb:	e8 8b 01 00 00       	call   800a4b <open>
  8008c0:	89 c3                	mov    %eax,%ebx
  8008c2:	83 c4 10             	add    $0x10,%esp
  8008c5:	85 c0                	test   %eax,%eax
  8008c7:	78 1b                	js     8008e4 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8008c9:	83 ec 08             	sub    $0x8,%esp
  8008cc:	ff 75 0c             	pushl  0xc(%ebp)
  8008cf:	50                   	push   %eax
  8008d0:	e8 65 ff ff ff       	call   80083a <fstat>
  8008d5:	89 c6                	mov    %eax,%esi
	close(fd);
  8008d7:	89 1c 24             	mov    %ebx,(%esp)
  8008da:	e8 18 fc ff ff       	call   8004f7 <close>
	return r;
  8008df:	83 c4 10             	add    $0x10,%esp
  8008e2:	89 f3                	mov    %esi,%ebx
}
  8008e4:	89 d8                	mov    %ebx,%eax
  8008e6:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8008e9:	5b                   	pop    %ebx
  8008ea:	5e                   	pop    %esi
  8008eb:	c9                   	leave  
  8008ec:	c3                   	ret    
  8008ed:	00 00                	add    %al,(%eax)
	...

008008f0 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8008f0:	55                   	push   %ebp
  8008f1:	89 e5                	mov    %esp,%ebp
  8008f3:	56                   	push   %esi
  8008f4:	53                   	push   %ebx
  8008f5:	89 c3                	mov    %eax,%ebx
  8008f7:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  8008f9:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  800900:	75 12                	jne    800914 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  800902:	83 ec 0c             	sub    $0xc,%esp
  800905:	6a 01                	push   $0x1
  800907:	e8 e9 11 00 00       	call   801af5 <ipc_find_env>
  80090c:	a3 00 40 80 00       	mov    %eax,0x804000
  800911:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  800914:	6a 07                	push   $0x7
  800916:	68 00 50 80 00       	push   $0x805000
  80091b:	53                   	push   %ebx
  80091c:	ff 35 00 40 80 00    	pushl  0x804000
  800922:	e8 79 11 00 00       	call   801aa0 <ipc_send>
	
	return ipc_recv(NULL, dstva, NULL);
  800927:	83 c4 0c             	add    $0xc,%esp
  80092a:	6a 00                	push   $0x0
  80092c:	56                   	push   %esi
  80092d:	6a 00                	push   $0x0
  80092f:	e8 c4 10 00 00       	call   8019f8 <ipc_recv>
}
  800934:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800937:	5b                   	pop    %ebx
  800938:	5e                   	pop    %esi
  800939:	c9                   	leave  
  80093a:	c3                   	ret    

0080093b <devfile_stat>:
}


static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  80093b:	55                   	push   %ebp
  80093c:	89 e5                	mov    %esp,%ebp
  80093e:	53                   	push   %ebx
  80093f:	83 ec 04             	sub    $0x4,%esp
  800942:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  800945:	8b 45 08             	mov    0x8(%ebp),%eax
  800948:	8b 40 0c             	mov    0xc(%eax),%eax
  80094b:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0) {
  800950:	ba 00 00 00 00       	mov    $0x0,%edx
  800955:	b8 05 00 00 00       	mov    $0x5,%eax
  80095a:	e8 91 ff ff ff       	call   8008f0 <fsipc>
  80095f:	85 c0                	test   %eax,%eax
  800961:	78 39                	js     80099c <devfile_stat+0x61>
		return r;
	}
	cprintf("OVER\n");
  800963:	83 ec 0c             	sub    $0xc,%esp
  800966:	68 a4 1e 80 00       	push   $0x801ea4
  80096b:	e8 54 07 00 00       	call   8010c4 <cprintf>
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  800970:	83 c4 08             	add    $0x8,%esp
  800973:	68 00 50 80 00       	push   $0x805000
  800978:	53                   	push   %ebx
  800979:	e8 fc 0c 00 00       	call   80167a <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  80097e:	a1 80 50 80 00       	mov    0x805080,%eax
  800983:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  800989:	a1 84 50 80 00       	mov    0x805084,%eax
  80098e:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  800994:	83 c4 10             	add    $0x10,%esp
  800997:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80099c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80099f:	c9                   	leave  
  8009a0:	c3                   	ret    

008009a1 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8009a1:	55                   	push   %ebp
  8009a2:	89 e5                	mov    %esp,%ebp
  8009a4:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8009a7:	8b 45 08             	mov    0x8(%ebp),%eax
  8009aa:	8b 40 0c             	mov    0xc(%eax),%eax
  8009ad:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8009b2:	ba 00 00 00 00       	mov    $0x0,%edx
  8009b7:	b8 06 00 00 00       	mov    $0x6,%eax
  8009bc:	e8 2f ff ff ff       	call   8008f0 <fsipc>
}
  8009c1:	c9                   	leave  
  8009c2:	c3                   	ret    

008009c3 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  8009c3:	55                   	push   %ebp
  8009c4:	89 e5                	mov    %esp,%ebp
  8009c6:	56                   	push   %esi
  8009c7:	53                   	push   %ebx
  8009c8:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8009cb:	8b 45 08             	mov    0x8(%ebp),%eax
  8009ce:	8b 40 0c             	mov    0xc(%eax),%eax
  8009d1:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  8009d6:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8009dc:	ba 00 00 00 00       	mov    $0x0,%edx
  8009e1:	b8 03 00 00 00       	mov    $0x3,%eax
  8009e6:	e8 05 ff ff ff       	call   8008f0 <fsipc>
  8009eb:	89 c3                	mov    %eax,%ebx
  8009ed:	85 c0                	test   %eax,%eax
  8009ef:	78 51                	js     800a42 <devfile_read+0x7f>
		return r;
	assert(r <= n);
  8009f1:	39 c6                	cmp    %eax,%esi
  8009f3:	73 19                	jae    800a0e <devfile_read+0x4b>
  8009f5:	68 aa 1e 80 00       	push   $0x801eaa
  8009fa:	68 b1 1e 80 00       	push   $0x801eb1
  8009ff:	68 80 00 00 00       	push   $0x80
  800a04:	68 c6 1e 80 00       	push   $0x801ec6
  800a09:	e8 de 05 00 00       	call   800fec <_panic>
	assert(r <= PGSIZE);
  800a0e:	3d 00 10 00 00       	cmp    $0x1000,%eax
  800a13:	7e 19                	jle    800a2e <devfile_read+0x6b>
  800a15:	68 d1 1e 80 00       	push   $0x801ed1
  800a1a:	68 b1 1e 80 00       	push   $0x801eb1
  800a1f:	68 81 00 00 00       	push   $0x81
  800a24:	68 c6 1e 80 00       	push   $0x801ec6
  800a29:	e8 be 05 00 00       	call   800fec <_panic>
	memmove(buf, &fsipcbuf, r);
  800a2e:	83 ec 04             	sub    $0x4,%esp
  800a31:	50                   	push   %eax
  800a32:	68 00 50 80 00       	push   $0x805000
  800a37:	ff 75 0c             	pushl  0xc(%ebp)
  800a3a:	e8 fc 0d 00 00       	call   80183b <memmove>
	return r;
  800a3f:	83 c4 10             	add    $0x10,%esp
}
  800a42:	89 d8                	mov    %ebx,%eax
  800a44:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800a47:	5b                   	pop    %ebx
  800a48:	5e                   	pop    %esi
  800a49:	c9                   	leave  
  800a4a:	c3                   	ret    

00800a4b <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  800a4b:	55                   	push   %ebp
  800a4c:	89 e5                	mov    %esp,%ebp
  800a4e:	56                   	push   %esi
  800a4f:	53                   	push   %ebx
  800a50:	83 ec 1c             	sub    $0x1c,%esp
  800a53:	8b 75 08             	mov    0x8(%ebp),%esi
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  800a56:	56                   	push   %esi
  800a57:	e8 cc 0b 00 00       	call   801628 <strlen>
  800a5c:	83 c4 10             	add    $0x10,%esp
  800a5f:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  800a64:	7f 72                	jg     800ad8 <open+0x8d>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800a66:	83 ec 0c             	sub    $0xc,%esp
  800a69:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800a6c:	50                   	push   %eax
  800a6d:	e8 ce f8 ff ff       	call   800340 <fd_alloc>
  800a72:	89 c3                	mov    %eax,%ebx
  800a74:	83 c4 10             	add    $0x10,%esp
  800a77:	85 c0                	test   %eax,%eax
  800a79:	78 62                	js     800add <open+0x92>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  800a7b:	83 ec 08             	sub    $0x8,%esp
  800a7e:	56                   	push   %esi
  800a7f:	68 00 50 80 00       	push   $0x805000
  800a84:	e8 f1 0b 00 00       	call   80167a <strcpy>
	fsipcbuf.open.req_omode = mode;
  800a89:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a8c:	a3 00 54 80 00       	mov    %eax,0x805400



	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  800a91:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800a94:	b8 01 00 00 00       	mov    $0x1,%eax
  800a99:	e8 52 fe ff ff       	call   8008f0 <fsipc>
  800a9e:	89 c3                	mov    %eax,%ebx
  800aa0:	83 c4 10             	add    $0x10,%esp
  800aa3:	85 c0                	test   %eax,%eax
  800aa5:	79 12                	jns    800ab9 <open+0x6e>
		fd_close(fd, 0);
  800aa7:	83 ec 08             	sub    $0x8,%esp
  800aaa:	6a 00                	push   $0x0
  800aac:	ff 75 f4             	pushl  -0xc(%ebp)
  800aaf:	e8 bb f9 ff ff       	call   80046f <fd_close>
		return r;
  800ab4:	83 c4 10             	add    $0x10,%esp
  800ab7:	eb 24                	jmp    800add <open+0x92>
	}


	cprintf("OPEN\n");
  800ab9:	83 ec 0c             	sub    $0xc,%esp
  800abc:	68 dd 1e 80 00       	push   $0x801edd
  800ac1:	e8 fe 05 00 00       	call   8010c4 <cprintf>

	return fd2num(fd);
  800ac6:	83 c4 04             	add    $0x4,%esp
  800ac9:	ff 75 f4             	pushl  -0xc(%ebp)
  800acc:	e8 47 f8 ff ff       	call   800318 <fd2num>
  800ad1:	89 c3                	mov    %eax,%ebx
  800ad3:	83 c4 10             	add    $0x10,%esp
  800ad6:	eb 05                	jmp    800add <open+0x92>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  800ad8:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx


	cprintf("OPEN\n");

	return fd2num(fd);
}
  800add:	89 d8                	mov    %ebx,%eax
  800adf:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800ae2:	5b                   	pop    %ebx
  800ae3:	5e                   	pop    %esi
  800ae4:	c9                   	leave  
  800ae5:	c3                   	ret    
	...

00800ae8 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  800ae8:	55                   	push   %ebp
  800ae9:	89 e5                	mov    %esp,%ebp
  800aeb:	56                   	push   %esi
  800aec:	53                   	push   %ebx
  800aed:	8b 75 0c             	mov    0xc(%ebp),%esi
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  800af0:	83 ec 0c             	sub    $0xc,%esp
  800af3:	ff 75 08             	pushl  0x8(%ebp)
  800af6:	e8 2d f8 ff ff       	call   800328 <fd2data>
  800afb:	89 c3                	mov    %eax,%ebx
	strcpy(stat->st_name, "<pipe>");
  800afd:	83 c4 08             	add    $0x8,%esp
  800b00:	68 e3 1e 80 00       	push   $0x801ee3
  800b05:	56                   	push   %esi
  800b06:	e8 6f 0b 00 00       	call   80167a <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  800b0b:	8b 43 04             	mov    0x4(%ebx),%eax
  800b0e:	2b 03                	sub    (%ebx),%eax
  800b10:	89 86 80 00 00 00    	mov    %eax,0x80(%esi)
	stat->st_isdir = 0;
  800b16:	c7 86 84 00 00 00 00 	movl   $0x0,0x84(%esi)
  800b1d:	00 00 00 
	stat->st_dev = &devpipe;
  800b20:	c7 86 88 00 00 00 20 	movl   $0x803020,0x88(%esi)
  800b27:	30 80 00 
	return 0;
}
  800b2a:	b8 00 00 00 00       	mov    $0x0,%eax
  800b2f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800b32:	5b                   	pop    %ebx
  800b33:	5e                   	pop    %esi
  800b34:	c9                   	leave  
  800b35:	c3                   	ret    

00800b36 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  800b36:	55                   	push   %ebp
  800b37:	89 e5                	mov    %esp,%ebp
  800b39:	53                   	push   %ebx
  800b3a:	83 ec 0c             	sub    $0xc,%esp
  800b3d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  800b40:	53                   	push   %ebx
  800b41:	6a 00                	push   $0x0
  800b43:	e8 da f6 ff ff       	call   800222 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  800b48:	89 1c 24             	mov    %ebx,(%esp)
  800b4b:	e8 d8 f7 ff ff       	call   800328 <fd2data>
  800b50:	83 c4 08             	add    $0x8,%esp
  800b53:	50                   	push   %eax
  800b54:	6a 00                	push   $0x0
  800b56:	e8 c7 f6 ff ff       	call   800222 <sys_page_unmap>
}
  800b5b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800b5e:	c9                   	leave  
  800b5f:	c3                   	ret    

00800b60 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  800b60:	55                   	push   %ebp
  800b61:	89 e5                	mov    %esp,%ebp
  800b63:	57                   	push   %edi
  800b64:	56                   	push   %esi
  800b65:	53                   	push   %ebx
  800b66:	83 ec 1c             	sub    $0x1c,%esp
  800b69:	89 c7                	mov    %eax,%edi
  800b6b:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  800b6e:	a1 04 40 80 00       	mov    0x804004,%eax
  800b73:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  800b76:	83 ec 0c             	sub    $0xc,%esp
  800b79:	57                   	push   %edi
  800b7a:	e8 d1 0f 00 00       	call   801b50 <pageref>
  800b7f:	89 c6                	mov    %eax,%esi
  800b81:	83 c4 04             	add    $0x4,%esp
  800b84:	ff 75 e4             	pushl  -0x1c(%ebp)
  800b87:	e8 c4 0f 00 00       	call   801b50 <pageref>
  800b8c:	83 c4 10             	add    $0x10,%esp
  800b8f:	39 c6                	cmp    %eax,%esi
  800b91:	0f 94 c0             	sete   %al
  800b94:	0f b6 c0             	movzbl %al,%eax
		nn = thisenv->env_runs;
  800b97:	8b 15 04 40 80 00    	mov    0x804004,%edx
  800b9d:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  800ba0:	39 cb                	cmp    %ecx,%ebx
  800ba2:	75 08                	jne    800bac <_pipeisclosed+0x4c>
			return ret;
		if (n != nn && ret == 1)
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
	}
}
  800ba4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ba7:	5b                   	pop    %ebx
  800ba8:	5e                   	pop    %esi
  800ba9:	5f                   	pop    %edi
  800baa:	c9                   	leave  
  800bab:	c3                   	ret    
		n = thisenv->env_runs;
		ret = pageref(fd) == pageref(p);
		nn = thisenv->env_runs;
		if (n == nn)
			return ret;
		if (n != nn && ret == 1)
  800bac:	83 f8 01             	cmp    $0x1,%eax
  800baf:	75 bd                	jne    800b6e <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  800bb1:	8b 42 58             	mov    0x58(%edx),%eax
  800bb4:	6a 01                	push   $0x1
  800bb6:	50                   	push   %eax
  800bb7:	53                   	push   %ebx
  800bb8:	68 ea 1e 80 00       	push   $0x801eea
  800bbd:	e8 02 05 00 00       	call   8010c4 <cprintf>
  800bc2:	83 c4 10             	add    $0x10,%esp
  800bc5:	eb a7                	jmp    800b6e <_pipeisclosed+0xe>

00800bc7 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  800bc7:	55                   	push   %ebp
  800bc8:	89 e5                	mov    %esp,%ebp
  800bca:	57                   	push   %edi
  800bcb:	56                   	push   %esi
  800bcc:	53                   	push   %ebx
  800bcd:	83 ec 28             	sub    $0x28,%esp
  800bd0:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  800bd3:	56                   	push   %esi
  800bd4:	e8 4f f7 ff ff       	call   800328 <fd2data>
  800bd9:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800bdb:	83 c4 10             	add    $0x10,%esp
  800bde:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800be2:	75 4a                	jne    800c2e <devpipe_write+0x67>
  800be4:	bf 00 00 00 00       	mov    $0x0,%edi
  800be9:	eb 56                	jmp    800c41 <devpipe_write+0x7a>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  800beb:	89 da                	mov    %ebx,%edx
  800bed:	89 f0                	mov    %esi,%eax
  800bef:	e8 6c ff ff ff       	call   800b60 <_pipeisclosed>
  800bf4:	85 c0                	test   %eax,%eax
  800bf6:	75 4d                	jne    800c45 <devpipe_write+0x7e>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  800bf8:	e8 b4 f5 ff ff       	call   8001b1 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  800bfd:	8b 43 04             	mov    0x4(%ebx),%eax
  800c00:	8b 13                	mov    (%ebx),%edx
  800c02:	83 c2 20             	add    $0x20,%edx
  800c05:	39 d0                	cmp    %edx,%eax
  800c07:	73 e2                	jae    800beb <devpipe_write+0x24>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  800c09:	89 c2                	mov    %eax,%edx
  800c0b:	81 e2 1f 00 00 80    	and    $0x8000001f,%edx
  800c11:	79 05                	jns    800c18 <devpipe_write+0x51>
  800c13:	4a                   	dec    %edx
  800c14:	83 ca e0             	or     $0xffffffe0,%edx
  800c17:	42                   	inc    %edx
  800c18:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c1b:	8a 0c 39             	mov    (%ecx,%edi,1),%cl
  800c1e:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  800c22:	40                   	inc    %eax
  800c23:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800c26:	47                   	inc    %edi
  800c27:	39 7d 10             	cmp    %edi,0x10(%ebp)
  800c2a:	77 07                	ja     800c33 <devpipe_write+0x6c>
  800c2c:	eb 13                	jmp    800c41 <devpipe_write+0x7a>
  800c2e:	bf 00 00 00 00       	mov    $0x0,%edi
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  800c33:	8b 43 04             	mov    0x4(%ebx),%eax
  800c36:	8b 13                	mov    (%ebx),%edx
  800c38:	83 c2 20             	add    $0x20,%edx
  800c3b:	39 d0                	cmp    %edx,%eax
  800c3d:	73 ac                	jae    800beb <devpipe_write+0x24>
  800c3f:	eb c8                	jmp    800c09 <devpipe_write+0x42>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  800c41:	89 f8                	mov    %edi,%eax
  800c43:	eb 05                	jmp    800c4a <devpipe_write+0x83>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  800c45:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  800c4a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c4d:	5b                   	pop    %ebx
  800c4e:	5e                   	pop    %esi
  800c4f:	5f                   	pop    %edi
  800c50:	c9                   	leave  
  800c51:	c3                   	ret    

00800c52 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  800c52:	55                   	push   %ebp
  800c53:	89 e5                	mov    %esp,%ebp
  800c55:	57                   	push   %edi
  800c56:	56                   	push   %esi
  800c57:	53                   	push   %ebx
  800c58:	83 ec 18             	sub    $0x18,%esp
  800c5b:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  800c5e:	57                   	push   %edi
  800c5f:	e8 c4 f6 ff ff       	call   800328 <fd2data>
  800c64:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800c66:	83 c4 10             	add    $0x10,%esp
  800c69:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800c6d:	75 44                	jne    800cb3 <devpipe_read+0x61>
  800c6f:	be 00 00 00 00       	mov    $0x0,%esi
  800c74:	eb 4f                	jmp    800cc5 <devpipe_read+0x73>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
				return i;
  800c76:	89 f0                	mov    %esi,%eax
  800c78:	eb 54                	jmp    800cce <devpipe_read+0x7c>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  800c7a:	89 da                	mov    %ebx,%edx
  800c7c:	89 f8                	mov    %edi,%eax
  800c7e:	e8 dd fe ff ff       	call   800b60 <_pipeisclosed>
  800c83:	85 c0                	test   %eax,%eax
  800c85:	75 42                	jne    800cc9 <devpipe_read+0x77>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  800c87:	e8 25 f5 ff ff       	call   8001b1 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  800c8c:	8b 03                	mov    (%ebx),%eax
  800c8e:	3b 43 04             	cmp    0x4(%ebx),%eax
  800c91:	74 e7                	je     800c7a <devpipe_read+0x28>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  800c93:	25 1f 00 00 80       	and    $0x8000001f,%eax
  800c98:	79 05                	jns    800c9f <devpipe_read+0x4d>
  800c9a:	48                   	dec    %eax
  800c9b:	83 c8 e0             	or     $0xffffffe0,%eax
  800c9e:	40                   	inc    %eax
  800c9f:	8a 44 03 08          	mov    0x8(%ebx,%eax,1),%al
  800ca3:	8b 55 0c             	mov    0xc(%ebp),%edx
  800ca6:	88 04 32             	mov    %al,(%edx,%esi,1)
		p->p_rpos++;
  800ca9:	ff 03                	incl   (%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800cab:	46                   	inc    %esi
  800cac:	39 75 10             	cmp    %esi,0x10(%ebp)
  800caf:	77 07                	ja     800cb8 <devpipe_read+0x66>
  800cb1:	eb 12                	jmp    800cc5 <devpipe_read+0x73>
  800cb3:	be 00 00 00 00       	mov    $0x0,%esi
		while (p->p_rpos == p->p_wpos) {
  800cb8:	8b 03                	mov    (%ebx),%eax
  800cba:	3b 43 04             	cmp    0x4(%ebx),%eax
  800cbd:	75 d4                	jne    800c93 <devpipe_read+0x41>
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  800cbf:	85 f6                	test   %esi,%esi
  800cc1:	75 b3                	jne    800c76 <devpipe_read+0x24>
  800cc3:	eb b5                	jmp    800c7a <devpipe_read+0x28>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  800cc5:	89 f0                	mov    %esi,%eax
  800cc7:	eb 05                	jmp    800cce <devpipe_read+0x7c>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  800cc9:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  800cce:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cd1:	5b                   	pop    %ebx
  800cd2:	5e                   	pop    %esi
  800cd3:	5f                   	pop    %edi
  800cd4:	c9                   	leave  
  800cd5:	c3                   	ret    

00800cd6 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  800cd6:	55                   	push   %ebp
  800cd7:	89 e5                	mov    %esp,%ebp
  800cd9:	57                   	push   %edi
  800cda:	56                   	push   %esi
  800cdb:	53                   	push   %ebx
  800cdc:	83 ec 28             	sub    $0x28,%esp
  800cdf:	8b 7d 08             	mov    0x8(%ebp),%edi
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  800ce2:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800ce5:	50                   	push   %eax
  800ce6:	e8 55 f6 ff ff       	call   800340 <fd_alloc>
  800ceb:	89 c3                	mov    %eax,%ebx
  800ced:	83 c4 10             	add    $0x10,%esp
  800cf0:	85 c0                	test   %eax,%eax
  800cf2:	0f 88 24 01 00 00    	js     800e1c <pipe+0x146>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800cf8:	83 ec 04             	sub    $0x4,%esp
  800cfb:	68 07 04 00 00       	push   $0x407
  800d00:	ff 75 e4             	pushl  -0x1c(%ebp)
  800d03:	6a 00                	push   $0x0
  800d05:	e8 ce f4 ff ff       	call   8001d8 <sys_page_alloc>
  800d0a:	89 c3                	mov    %eax,%ebx
  800d0c:	83 c4 10             	add    $0x10,%esp
  800d0f:	85 c0                	test   %eax,%eax
  800d11:	0f 88 05 01 00 00    	js     800e1c <pipe+0x146>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  800d17:	83 ec 0c             	sub    $0xc,%esp
  800d1a:	8d 45 e0             	lea    -0x20(%ebp),%eax
  800d1d:	50                   	push   %eax
  800d1e:	e8 1d f6 ff ff       	call   800340 <fd_alloc>
  800d23:	89 c3                	mov    %eax,%ebx
  800d25:	83 c4 10             	add    $0x10,%esp
  800d28:	85 c0                	test   %eax,%eax
  800d2a:	0f 88 dc 00 00 00    	js     800e0c <pipe+0x136>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800d30:	83 ec 04             	sub    $0x4,%esp
  800d33:	68 07 04 00 00       	push   $0x407
  800d38:	ff 75 e0             	pushl  -0x20(%ebp)
  800d3b:	6a 00                	push   $0x0
  800d3d:	e8 96 f4 ff ff       	call   8001d8 <sys_page_alloc>
  800d42:	89 c3                	mov    %eax,%ebx
  800d44:	83 c4 10             	add    $0x10,%esp
  800d47:	85 c0                	test   %eax,%eax
  800d49:	0f 88 bd 00 00 00    	js     800e0c <pipe+0x136>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  800d4f:	83 ec 0c             	sub    $0xc,%esp
  800d52:	ff 75 e4             	pushl  -0x1c(%ebp)
  800d55:	e8 ce f5 ff ff       	call   800328 <fd2data>
  800d5a:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800d5c:	83 c4 0c             	add    $0xc,%esp
  800d5f:	68 07 04 00 00       	push   $0x407
  800d64:	50                   	push   %eax
  800d65:	6a 00                	push   $0x0
  800d67:	e8 6c f4 ff ff       	call   8001d8 <sys_page_alloc>
  800d6c:	89 c3                	mov    %eax,%ebx
  800d6e:	83 c4 10             	add    $0x10,%esp
  800d71:	85 c0                	test   %eax,%eax
  800d73:	0f 88 83 00 00 00    	js     800dfc <pipe+0x126>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800d79:	83 ec 0c             	sub    $0xc,%esp
  800d7c:	ff 75 e0             	pushl  -0x20(%ebp)
  800d7f:	e8 a4 f5 ff ff       	call   800328 <fd2data>
  800d84:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  800d8b:	50                   	push   %eax
  800d8c:	6a 00                	push   $0x0
  800d8e:	56                   	push   %esi
  800d8f:	6a 00                	push   $0x0
  800d91:	e8 66 f4 ff ff       	call   8001fc <sys_page_map>
  800d96:	89 c3                	mov    %eax,%ebx
  800d98:	83 c4 20             	add    $0x20,%esp
  800d9b:	85 c0                	test   %eax,%eax
  800d9d:	78 4f                	js     800dee <pipe+0x118>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  800d9f:	8b 15 20 30 80 00    	mov    0x803020,%edx
  800da5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800da8:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  800daa:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800dad:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  800db4:	8b 15 20 30 80 00    	mov    0x803020,%edx
  800dba:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800dbd:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  800dbf:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800dc2:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  800dc9:	83 ec 0c             	sub    $0xc,%esp
  800dcc:	ff 75 e4             	pushl  -0x1c(%ebp)
  800dcf:	e8 44 f5 ff ff       	call   800318 <fd2num>
  800dd4:	89 07                	mov    %eax,(%edi)
	pfd[1] = fd2num(fd1);
  800dd6:	83 c4 04             	add    $0x4,%esp
  800dd9:	ff 75 e0             	pushl  -0x20(%ebp)
  800ddc:	e8 37 f5 ff ff       	call   800318 <fd2num>
  800de1:	89 47 04             	mov    %eax,0x4(%edi)
	return 0;
  800de4:	83 c4 10             	add    $0x10,%esp
  800de7:	bb 00 00 00 00       	mov    $0x0,%ebx
  800dec:	eb 2e                	jmp    800e1c <pipe+0x146>

    err3:
	sys_page_unmap(0, va);
  800dee:	83 ec 08             	sub    $0x8,%esp
  800df1:	56                   	push   %esi
  800df2:	6a 00                	push   $0x0
  800df4:	e8 29 f4 ff ff       	call   800222 <sys_page_unmap>
  800df9:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  800dfc:	83 ec 08             	sub    $0x8,%esp
  800dff:	ff 75 e0             	pushl  -0x20(%ebp)
  800e02:	6a 00                	push   $0x0
  800e04:	e8 19 f4 ff ff       	call   800222 <sys_page_unmap>
  800e09:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  800e0c:	83 ec 08             	sub    $0x8,%esp
  800e0f:	ff 75 e4             	pushl  -0x1c(%ebp)
  800e12:	6a 00                	push   $0x0
  800e14:	e8 09 f4 ff ff       	call   800222 <sys_page_unmap>
  800e19:	83 c4 10             	add    $0x10,%esp
    err:
	return r;
}
  800e1c:	89 d8                	mov    %ebx,%eax
  800e1e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e21:	5b                   	pop    %ebx
  800e22:	5e                   	pop    %esi
  800e23:	5f                   	pop    %edi
  800e24:	c9                   	leave  
  800e25:	c3                   	ret    

00800e26 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  800e26:	55                   	push   %ebp
  800e27:	89 e5                	mov    %esp,%ebp
  800e29:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800e2c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800e2f:	50                   	push   %eax
  800e30:	ff 75 08             	pushl  0x8(%ebp)
  800e33:	e8 7b f5 ff ff       	call   8003b3 <fd_lookup>
  800e38:	83 c4 10             	add    $0x10,%esp
  800e3b:	85 c0                	test   %eax,%eax
  800e3d:	78 18                	js     800e57 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  800e3f:	83 ec 0c             	sub    $0xc,%esp
  800e42:	ff 75 f4             	pushl  -0xc(%ebp)
  800e45:	e8 de f4 ff ff       	call   800328 <fd2data>
	return _pipeisclosed(fd, p);
  800e4a:	89 c2                	mov    %eax,%edx
  800e4c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800e4f:	e8 0c fd ff ff       	call   800b60 <_pipeisclosed>
  800e54:	83 c4 10             	add    $0x10,%esp
}
  800e57:	c9                   	leave  
  800e58:	c3                   	ret    
  800e59:	00 00                	add    %al,(%eax)
	...

00800e5c <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  800e5c:	55                   	push   %ebp
  800e5d:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  800e5f:	b8 00 00 00 00       	mov    $0x0,%eax
  800e64:	c9                   	leave  
  800e65:	c3                   	ret    

00800e66 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  800e66:	55                   	push   %ebp
  800e67:	89 e5                	mov    %esp,%ebp
  800e69:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  800e6c:	68 02 1f 80 00       	push   $0x801f02
  800e71:	ff 75 0c             	pushl  0xc(%ebp)
  800e74:	e8 01 08 00 00       	call   80167a <strcpy>
	return 0;
}
  800e79:	b8 00 00 00 00       	mov    $0x0,%eax
  800e7e:	c9                   	leave  
  800e7f:	c3                   	ret    

00800e80 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  800e80:	55                   	push   %ebp
  800e81:	89 e5                	mov    %esp,%ebp
  800e83:	57                   	push   %edi
  800e84:	56                   	push   %esi
  800e85:	53                   	push   %ebx
  800e86:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800e8c:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800e90:	74 45                	je     800ed7 <devcons_write+0x57>
  800e92:	b8 00 00 00 00       	mov    $0x0,%eax
  800e97:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  800e9c:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  800ea2:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800ea5:	29 c3                	sub    %eax,%ebx
		if (m > sizeof(buf) - 1)
  800ea7:	83 fb 7f             	cmp    $0x7f,%ebx
  800eaa:	76 05                	jbe    800eb1 <devcons_write+0x31>
			m = sizeof(buf) - 1;
  800eac:	bb 7f 00 00 00       	mov    $0x7f,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  800eb1:	83 ec 04             	sub    $0x4,%esp
  800eb4:	53                   	push   %ebx
  800eb5:	03 45 0c             	add    0xc(%ebp),%eax
  800eb8:	50                   	push   %eax
  800eb9:	57                   	push   %edi
  800eba:	e8 7c 09 00 00       	call   80183b <memmove>
		sys_cputs(buf, m);
  800ebf:	83 c4 08             	add    $0x8,%esp
  800ec2:	53                   	push   %ebx
  800ec3:	57                   	push   %edi
  800ec4:	e8 58 f2 ff ff       	call   800121 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800ec9:	01 de                	add    %ebx,%esi
  800ecb:	89 f0                	mov    %esi,%eax
  800ecd:	83 c4 10             	add    $0x10,%esp
  800ed0:	3b 75 10             	cmp    0x10(%ebp),%esi
  800ed3:	72 cd                	jb     800ea2 <devcons_write+0x22>
  800ed5:	eb 05                	jmp    800edc <devcons_write+0x5c>
  800ed7:	be 00 00 00 00       	mov    $0x0,%esi
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  800edc:	89 f0                	mov    %esi,%eax
  800ede:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ee1:	5b                   	pop    %ebx
  800ee2:	5e                   	pop    %esi
  800ee3:	5f                   	pop    %edi
  800ee4:	c9                   	leave  
  800ee5:	c3                   	ret    

00800ee6 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  800ee6:	55                   	push   %ebp
  800ee7:	89 e5                	mov    %esp,%ebp
  800ee9:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
  800eec:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800ef0:	75 07                	jne    800ef9 <devcons_read+0x13>
  800ef2:	eb 25                	jmp    800f19 <devcons_read+0x33>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  800ef4:	e8 b8 f2 ff ff       	call   8001b1 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  800ef9:	e8 49 f2 ff ff       	call   800147 <sys_cgetc>
  800efe:	85 c0                	test   %eax,%eax
  800f00:	74 f2                	je     800ef4 <devcons_read+0xe>
  800f02:	89 c2                	mov    %eax,%edx
		sys_yield();
	if (c < 0)
  800f04:	85 c0                	test   %eax,%eax
  800f06:	78 1d                	js     800f25 <devcons_read+0x3f>
		return c;
	if (c == 0x04)	// ctl-d is eof
  800f08:	83 f8 04             	cmp    $0x4,%eax
  800f0b:	74 13                	je     800f20 <devcons_read+0x3a>
		return 0;
	*(char*)vbuf = c;
  800f0d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f10:	88 10                	mov    %dl,(%eax)
	return 1;
  800f12:	b8 01 00 00 00       	mov    $0x1,%eax
  800f17:	eb 0c                	jmp    800f25 <devcons_read+0x3f>
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
		return 0;
  800f19:	b8 00 00 00 00       	mov    $0x0,%eax
  800f1e:	eb 05                	jmp    800f25 <devcons_read+0x3f>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  800f20:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  800f25:	c9                   	leave  
  800f26:	c3                   	ret    

00800f27 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  800f27:	55                   	push   %ebp
  800f28:	89 e5                	mov    %esp,%ebp
  800f2a:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  800f2d:	8b 45 08             	mov    0x8(%ebp),%eax
  800f30:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  800f33:	6a 01                	push   $0x1
  800f35:	8d 45 f7             	lea    -0x9(%ebp),%eax
  800f38:	50                   	push   %eax
  800f39:	e8 e3 f1 ff ff       	call   800121 <sys_cputs>
  800f3e:	83 c4 10             	add    $0x10,%esp
}
  800f41:	c9                   	leave  
  800f42:	c3                   	ret    

00800f43 <getchar>:

int
getchar(void)
{
  800f43:	55                   	push   %ebp
  800f44:	89 e5                	mov    %esp,%ebp
  800f46:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  800f49:	6a 01                	push   $0x1
  800f4b:	8d 45 f7             	lea    -0x9(%ebp),%eax
  800f4e:	50                   	push   %eax
  800f4f:	6a 00                	push   $0x0
  800f51:	e8 de f6 ff ff       	call   800634 <read>
	if (r < 0)
  800f56:	83 c4 10             	add    $0x10,%esp
  800f59:	85 c0                	test   %eax,%eax
  800f5b:	78 0f                	js     800f6c <getchar+0x29>
		return r;
	if (r < 1)
  800f5d:	85 c0                	test   %eax,%eax
  800f5f:	7e 06                	jle    800f67 <getchar+0x24>
		return -E_EOF;
	return c;
  800f61:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  800f65:	eb 05                	jmp    800f6c <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  800f67:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  800f6c:	c9                   	leave  
  800f6d:	c3                   	ret    

00800f6e <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  800f6e:	55                   	push   %ebp
  800f6f:	89 e5                	mov    %esp,%ebp
  800f71:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800f74:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800f77:	50                   	push   %eax
  800f78:	ff 75 08             	pushl  0x8(%ebp)
  800f7b:	e8 33 f4 ff ff       	call   8003b3 <fd_lookup>
  800f80:	83 c4 10             	add    $0x10,%esp
  800f83:	85 c0                	test   %eax,%eax
  800f85:	78 11                	js     800f98 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  800f87:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800f8a:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  800f90:	39 10                	cmp    %edx,(%eax)
  800f92:	0f 94 c0             	sete   %al
  800f95:	0f b6 c0             	movzbl %al,%eax
}
  800f98:	c9                   	leave  
  800f99:	c3                   	ret    

00800f9a <opencons>:

int
opencons(void)
{
  800f9a:	55                   	push   %ebp
  800f9b:	89 e5                	mov    %esp,%ebp
  800f9d:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  800fa0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800fa3:	50                   	push   %eax
  800fa4:	e8 97 f3 ff ff       	call   800340 <fd_alloc>
  800fa9:	83 c4 10             	add    $0x10,%esp
  800fac:	85 c0                	test   %eax,%eax
  800fae:	78 3a                	js     800fea <opencons+0x50>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  800fb0:	83 ec 04             	sub    $0x4,%esp
  800fb3:	68 07 04 00 00       	push   $0x407
  800fb8:	ff 75 f4             	pushl  -0xc(%ebp)
  800fbb:	6a 00                	push   $0x0
  800fbd:	e8 16 f2 ff ff       	call   8001d8 <sys_page_alloc>
  800fc2:	83 c4 10             	add    $0x10,%esp
  800fc5:	85 c0                	test   %eax,%eax
  800fc7:	78 21                	js     800fea <opencons+0x50>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  800fc9:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  800fcf:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800fd2:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  800fd4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800fd7:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  800fde:	83 ec 0c             	sub    $0xc,%esp
  800fe1:	50                   	push   %eax
  800fe2:	e8 31 f3 ff ff       	call   800318 <fd2num>
  800fe7:	83 c4 10             	add    $0x10,%esp
}
  800fea:	c9                   	leave  
  800feb:	c3                   	ret    

00800fec <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800fec:	55                   	push   %ebp
  800fed:	89 e5                	mov    %esp,%ebp
  800fef:	56                   	push   %esi
  800ff0:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800ff1:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800ff4:	8b 1d 00 30 80 00    	mov    0x803000,%ebx
  800ffa:	e8 8e f1 ff ff       	call   80018d <sys_getenvid>
  800fff:	83 ec 0c             	sub    $0xc,%esp
  801002:	ff 75 0c             	pushl  0xc(%ebp)
  801005:	ff 75 08             	pushl  0x8(%ebp)
  801008:	53                   	push   %ebx
  801009:	50                   	push   %eax
  80100a:	68 10 1f 80 00       	push   $0x801f10
  80100f:	e8 b0 00 00 00       	call   8010c4 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801014:	83 c4 18             	add    $0x18,%esp
  801017:	56                   	push   %esi
  801018:	ff 75 10             	pushl  0x10(%ebp)
  80101b:	e8 53 00 00 00       	call   801073 <vcprintf>
	cprintf("\n");
  801020:	c7 04 24 e1 1e 80 00 	movl   $0x801ee1,(%esp)
  801027:	e8 98 00 00 00       	call   8010c4 <cprintf>
  80102c:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80102f:	cc                   	int3   
  801030:	eb fd                	jmp    80102f <_panic+0x43>
	...

00801034 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  801034:	55                   	push   %ebp
  801035:	89 e5                	mov    %esp,%ebp
  801037:	53                   	push   %ebx
  801038:	83 ec 04             	sub    $0x4,%esp
  80103b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80103e:	8b 03                	mov    (%ebx),%eax
  801040:	8b 55 08             	mov    0x8(%ebp),%edx
  801043:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  801047:	40                   	inc    %eax
  801048:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  80104a:	3d ff 00 00 00       	cmp    $0xff,%eax
  80104f:	75 1a                	jne    80106b <putch+0x37>
		sys_cputs(b->buf, b->idx);
  801051:	83 ec 08             	sub    $0x8,%esp
  801054:	68 ff 00 00 00       	push   $0xff
  801059:	8d 43 08             	lea    0x8(%ebx),%eax
  80105c:	50                   	push   %eax
  80105d:	e8 bf f0 ff ff       	call   800121 <sys_cputs>
		b->idx = 0;
  801062:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801068:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  80106b:	ff 43 04             	incl   0x4(%ebx)
}
  80106e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801071:	c9                   	leave  
  801072:	c3                   	ret    

00801073 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  801073:	55                   	push   %ebp
  801074:	89 e5                	mov    %esp,%ebp
  801076:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  80107c:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  801083:	00 00 00 
	b.cnt = 0;
  801086:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80108d:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  801090:	ff 75 0c             	pushl  0xc(%ebp)
  801093:	ff 75 08             	pushl  0x8(%ebp)
  801096:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80109c:	50                   	push   %eax
  80109d:	68 34 10 80 00       	push   $0x801034
  8010a2:	e8 82 01 00 00       	call   801229 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8010a7:	83 c4 08             	add    $0x8,%esp
  8010aa:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8010b0:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8010b6:	50                   	push   %eax
  8010b7:	e8 65 f0 ff ff       	call   800121 <sys_cputs>

	return b.cnt;
}
  8010bc:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8010c2:	c9                   	leave  
  8010c3:	c3                   	ret    

008010c4 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8010c4:	55                   	push   %ebp
  8010c5:	89 e5                	mov    %esp,%ebp
  8010c7:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8010ca:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8010cd:	50                   	push   %eax
  8010ce:	ff 75 08             	pushl  0x8(%ebp)
  8010d1:	e8 9d ff ff ff       	call   801073 <vcprintf>
	va_end(ap);

	return cnt;
}
  8010d6:	c9                   	leave  
  8010d7:	c3                   	ret    

008010d8 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8010d8:	55                   	push   %ebp
  8010d9:	89 e5                	mov    %esp,%ebp
  8010db:	57                   	push   %edi
  8010dc:	56                   	push   %esi
  8010dd:	53                   	push   %ebx
  8010de:	83 ec 2c             	sub    $0x2c,%esp
  8010e1:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8010e4:	89 d6                	mov    %edx,%esi
  8010e6:	8b 45 08             	mov    0x8(%ebp),%eax
  8010e9:	8b 55 0c             	mov    0xc(%ebp),%edx
  8010ec:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8010ef:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8010f2:	8b 45 10             	mov    0x10(%ebp),%eax
  8010f5:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8010f8:	8b 7d 18             	mov    0x18(%ebp),%edi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8010fb:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8010fe:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  801105:	39 55 d4             	cmp    %edx,-0x2c(%ebp)
  801108:	72 0c                	jb     801116 <printnum+0x3e>
  80110a:	3b 45 d8             	cmp    -0x28(%ebp),%eax
  80110d:	76 07                	jbe    801116 <printnum+0x3e>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80110f:	4b                   	dec    %ebx
  801110:	85 db                	test   %ebx,%ebx
  801112:	7f 31                	jg     801145 <printnum+0x6d>
  801114:	eb 3f                	jmp    801155 <printnum+0x7d>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  801116:	83 ec 0c             	sub    $0xc,%esp
  801119:	57                   	push   %edi
  80111a:	4b                   	dec    %ebx
  80111b:	53                   	push   %ebx
  80111c:	50                   	push   %eax
  80111d:	83 ec 08             	sub    $0x8,%esp
  801120:	ff 75 d4             	pushl  -0x2c(%ebp)
  801123:	ff 75 d0             	pushl  -0x30(%ebp)
  801126:	ff 75 dc             	pushl  -0x24(%ebp)
  801129:	ff 75 d8             	pushl  -0x28(%ebp)
  80112c:	e8 63 0a 00 00       	call   801b94 <__udivdi3>
  801131:	83 c4 18             	add    $0x18,%esp
  801134:	52                   	push   %edx
  801135:	50                   	push   %eax
  801136:	89 f2                	mov    %esi,%edx
  801138:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80113b:	e8 98 ff ff ff       	call   8010d8 <printnum>
  801140:	83 c4 20             	add    $0x20,%esp
  801143:	eb 10                	jmp    801155 <printnum+0x7d>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  801145:	83 ec 08             	sub    $0x8,%esp
  801148:	56                   	push   %esi
  801149:	57                   	push   %edi
  80114a:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80114d:	4b                   	dec    %ebx
  80114e:	83 c4 10             	add    $0x10,%esp
  801151:	85 db                	test   %ebx,%ebx
  801153:	7f f0                	jg     801145 <printnum+0x6d>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  801155:	83 ec 08             	sub    $0x8,%esp
  801158:	56                   	push   %esi
  801159:	83 ec 04             	sub    $0x4,%esp
  80115c:	ff 75 d4             	pushl  -0x2c(%ebp)
  80115f:	ff 75 d0             	pushl  -0x30(%ebp)
  801162:	ff 75 dc             	pushl  -0x24(%ebp)
  801165:	ff 75 d8             	pushl  -0x28(%ebp)
  801168:	e8 43 0b 00 00       	call   801cb0 <__umoddi3>
  80116d:	83 c4 14             	add    $0x14,%esp
  801170:	0f be 80 33 1f 80 00 	movsbl 0x801f33(%eax),%eax
  801177:	50                   	push   %eax
  801178:	ff 55 e4             	call   *-0x1c(%ebp)
  80117b:	83 c4 10             	add    $0x10,%esp
}
  80117e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801181:	5b                   	pop    %ebx
  801182:	5e                   	pop    %esi
  801183:	5f                   	pop    %edi
  801184:	c9                   	leave  
  801185:	c3                   	ret    

00801186 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  801186:	55                   	push   %ebp
  801187:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  801189:	83 fa 01             	cmp    $0x1,%edx
  80118c:	7e 0e                	jle    80119c <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80118e:	8b 10                	mov    (%eax),%edx
  801190:	8d 4a 08             	lea    0x8(%edx),%ecx
  801193:	89 08                	mov    %ecx,(%eax)
  801195:	8b 02                	mov    (%edx),%eax
  801197:	8b 52 04             	mov    0x4(%edx),%edx
  80119a:	eb 22                	jmp    8011be <getuint+0x38>
	else if (lflag)
  80119c:	85 d2                	test   %edx,%edx
  80119e:	74 10                	je     8011b0 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8011a0:	8b 10                	mov    (%eax),%edx
  8011a2:	8d 4a 04             	lea    0x4(%edx),%ecx
  8011a5:	89 08                	mov    %ecx,(%eax)
  8011a7:	8b 02                	mov    (%edx),%eax
  8011a9:	ba 00 00 00 00       	mov    $0x0,%edx
  8011ae:	eb 0e                	jmp    8011be <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8011b0:	8b 10                	mov    (%eax),%edx
  8011b2:	8d 4a 04             	lea    0x4(%edx),%ecx
  8011b5:	89 08                	mov    %ecx,(%eax)
  8011b7:	8b 02                	mov    (%edx),%eax
  8011b9:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8011be:	c9                   	leave  
  8011bf:	c3                   	ret    

008011c0 <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
  8011c0:	55                   	push   %ebp
  8011c1:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8011c3:	83 fa 01             	cmp    $0x1,%edx
  8011c6:	7e 0e                	jle    8011d6 <getint+0x16>
		return va_arg(*ap, long long);
  8011c8:	8b 10                	mov    (%eax),%edx
  8011ca:	8d 4a 08             	lea    0x8(%edx),%ecx
  8011cd:	89 08                	mov    %ecx,(%eax)
  8011cf:	8b 02                	mov    (%edx),%eax
  8011d1:	8b 52 04             	mov    0x4(%edx),%edx
  8011d4:	eb 1a                	jmp    8011f0 <getint+0x30>
	else if (lflag)
  8011d6:	85 d2                	test   %edx,%edx
  8011d8:	74 0c                	je     8011e6 <getint+0x26>
		return va_arg(*ap, long);
  8011da:	8b 10                	mov    (%eax),%edx
  8011dc:	8d 4a 04             	lea    0x4(%edx),%ecx
  8011df:	89 08                	mov    %ecx,(%eax)
  8011e1:	8b 02                	mov    (%edx),%eax
  8011e3:	99                   	cltd   
  8011e4:	eb 0a                	jmp    8011f0 <getint+0x30>
	else
		return va_arg(*ap, int);
  8011e6:	8b 10                	mov    (%eax),%edx
  8011e8:	8d 4a 04             	lea    0x4(%edx),%ecx
  8011eb:	89 08                	mov    %ecx,(%eax)
  8011ed:	8b 02                	mov    (%edx),%eax
  8011ef:	99                   	cltd   
}
  8011f0:	c9                   	leave  
  8011f1:	c3                   	ret    

008011f2 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8011f2:	55                   	push   %ebp
  8011f3:	89 e5                	mov    %esp,%ebp
  8011f5:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8011f8:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  8011fb:	8b 10                	mov    (%eax),%edx
  8011fd:	3b 50 04             	cmp    0x4(%eax),%edx
  801200:	73 08                	jae    80120a <sprintputch+0x18>
		*b->buf++ = ch;
  801202:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801205:	88 0a                	mov    %cl,(%edx)
  801207:	42                   	inc    %edx
  801208:	89 10                	mov    %edx,(%eax)
}
  80120a:	c9                   	leave  
  80120b:	c3                   	ret    

0080120c <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80120c:	55                   	push   %ebp
  80120d:	89 e5                	mov    %esp,%ebp
  80120f:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  801212:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  801215:	50                   	push   %eax
  801216:	ff 75 10             	pushl  0x10(%ebp)
  801219:	ff 75 0c             	pushl  0xc(%ebp)
  80121c:	ff 75 08             	pushl  0x8(%ebp)
  80121f:	e8 05 00 00 00       	call   801229 <vprintfmt>
	va_end(ap);
  801224:	83 c4 10             	add    $0x10,%esp
}
  801227:	c9                   	leave  
  801228:	c3                   	ret    

00801229 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  801229:	55                   	push   %ebp
  80122a:	89 e5                	mov    %esp,%ebp
  80122c:	57                   	push   %edi
  80122d:	56                   	push   %esi
  80122e:	53                   	push   %ebx
  80122f:	83 ec 2c             	sub    $0x2c,%esp
  801232:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801235:	8b 75 10             	mov    0x10(%ebp),%esi
  801238:	eb 13                	jmp    80124d <vprintfmt+0x24>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  80123a:	85 c0                	test   %eax,%eax
  80123c:	0f 84 6d 03 00 00    	je     8015af <vprintfmt+0x386>
				return;
			putch(ch, putdat);
  801242:	83 ec 08             	sub    $0x8,%esp
  801245:	57                   	push   %edi
  801246:	50                   	push   %eax
  801247:	ff 55 08             	call   *0x8(%ebp)
  80124a:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80124d:	0f b6 06             	movzbl (%esi),%eax
  801250:	46                   	inc    %esi
  801251:	83 f8 25             	cmp    $0x25,%eax
  801254:	75 e4                	jne    80123a <vprintfmt+0x11>
  801256:	c6 45 dc 20          	movb   $0x20,-0x24(%ebp)
  80125a:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  801261:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
  801268:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  80126f:	b9 00 00 00 00       	mov    $0x0,%ecx
  801274:	eb 28                	jmp    80129e <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801276:	89 de                	mov    %ebx,%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  801278:	c6 45 dc 2d          	movb   $0x2d,-0x24(%ebp)
  80127c:	eb 20                	jmp    80129e <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80127e:	89 de                	mov    %ebx,%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  801280:	c6 45 dc 30          	movb   $0x30,-0x24(%ebp)
  801284:	eb 18                	jmp    80129e <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801286:	89 de                	mov    %ebx,%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  801288:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  80128f:	eb 0d                	jmp    80129e <vprintfmt+0x75>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  801291:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  801294:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801297:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80129e:	8a 06                	mov    (%esi),%al
  8012a0:	0f b6 d0             	movzbl %al,%edx
  8012a3:	8d 5e 01             	lea    0x1(%esi),%ebx
  8012a6:	83 e8 23             	sub    $0x23,%eax
  8012a9:	3c 55                	cmp    $0x55,%al
  8012ab:	0f 87 e0 02 00 00    	ja     801591 <vprintfmt+0x368>
  8012b1:	0f b6 c0             	movzbl %al,%eax
  8012b4:	ff 24 85 80 20 80 00 	jmp    *0x802080(,%eax,4)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8012bb:	83 ea 30             	sub    $0x30,%edx
  8012be:	89 55 d4             	mov    %edx,-0x2c(%ebp)
				ch = *fmt;
  8012c1:	0f be 03             	movsbl (%ebx),%eax
				if (ch < '0' || ch > '9')
  8012c4:	8d 50 d0             	lea    -0x30(%eax),%edx
  8012c7:	83 fa 09             	cmp    $0x9,%edx
  8012ca:	77 44                	ja     801310 <vprintfmt+0xe7>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8012cc:	89 de                	mov    %ebx,%esi
  8012ce:	8b 55 d4             	mov    -0x2c(%ebp),%edx
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8012d1:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
  8012d2:	8d 14 92             	lea    (%edx,%edx,4),%edx
  8012d5:	8d 54 50 d0          	lea    -0x30(%eax,%edx,2),%edx
				ch = *fmt;
  8012d9:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  8012dc:	8d 58 d0             	lea    -0x30(%eax),%ebx
  8012df:	83 fb 09             	cmp    $0x9,%ebx
  8012e2:	76 ed                	jbe    8012d1 <vprintfmt+0xa8>
  8012e4:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  8012e7:	eb 29                	jmp    801312 <vprintfmt+0xe9>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8012e9:	8b 45 14             	mov    0x14(%ebp),%eax
  8012ec:	8d 50 04             	lea    0x4(%eax),%edx
  8012ef:	89 55 14             	mov    %edx,0x14(%ebp)
  8012f2:	8b 00                	mov    (%eax),%eax
  8012f4:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8012f7:	89 de                	mov    %ebx,%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8012f9:	eb 17                	jmp    801312 <vprintfmt+0xe9>

		case '.':
			if (width < 0)
  8012fb:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8012ff:	78 85                	js     801286 <vprintfmt+0x5d>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801301:	89 de                	mov    %ebx,%esi
  801303:	eb 99                	jmp    80129e <vprintfmt+0x75>
  801305:	89 de                	mov    %ebx,%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  801307:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
			goto reswitch;
  80130e:	eb 8e                	jmp    80129e <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801310:	89 de                	mov    %ebx,%esi
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  801312:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  801316:	79 86                	jns    80129e <vprintfmt+0x75>
  801318:	e9 74 ff ff ff       	jmp    801291 <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80131d:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80131e:	89 de                	mov    %ebx,%esi
  801320:	e9 79 ff ff ff       	jmp    80129e <vprintfmt+0x75>
  801325:	89 5d d8             	mov    %ebx,-0x28(%ebp)
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  801328:	8b 45 14             	mov    0x14(%ebp),%eax
  80132b:	8d 50 04             	lea    0x4(%eax),%edx
  80132e:	89 55 14             	mov    %edx,0x14(%ebp)
  801331:	83 ec 08             	sub    $0x8,%esp
  801334:	57                   	push   %edi
  801335:	ff 30                	pushl  (%eax)
  801337:	ff 55 08             	call   *0x8(%ebp)
			break;
  80133a:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80133d:	8b 75 d8             	mov    -0x28(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  801340:	e9 08 ff ff ff       	jmp    80124d <vprintfmt+0x24>
  801345:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// error message
		case 'e':
			err = va_arg(ap, int);
  801348:	8b 45 14             	mov    0x14(%ebp),%eax
  80134b:	8d 50 04             	lea    0x4(%eax),%edx
  80134e:	89 55 14             	mov    %edx,0x14(%ebp)
  801351:	8b 00                	mov    (%eax),%eax
  801353:	85 c0                	test   %eax,%eax
  801355:	79 02                	jns    801359 <vprintfmt+0x130>
  801357:	f7 d8                	neg    %eax
  801359:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80135b:	83 f8 0f             	cmp    $0xf,%eax
  80135e:	7f 0b                	jg     80136b <vprintfmt+0x142>
  801360:	8b 04 85 e0 21 80 00 	mov    0x8021e0(,%eax,4),%eax
  801367:	85 c0                	test   %eax,%eax
  801369:	75 1a                	jne    801385 <vprintfmt+0x15c>
				printfmt(putch, putdat, "error %d", err);
  80136b:	52                   	push   %edx
  80136c:	68 4b 1f 80 00       	push   $0x801f4b
  801371:	57                   	push   %edi
  801372:	ff 75 08             	pushl  0x8(%ebp)
  801375:	e8 92 fe ff ff       	call   80120c <printfmt>
  80137a:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80137d:	8b 75 d8             	mov    -0x28(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  801380:	e9 c8 fe ff ff       	jmp    80124d <vprintfmt+0x24>
			else
				printfmt(putch, putdat, "%s", p);
  801385:	50                   	push   %eax
  801386:	68 c3 1e 80 00       	push   $0x801ec3
  80138b:	57                   	push   %edi
  80138c:	ff 75 08             	pushl  0x8(%ebp)
  80138f:	e8 78 fe ff ff       	call   80120c <printfmt>
  801394:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801397:	8b 75 d8             	mov    -0x28(%ebp),%esi
  80139a:	e9 ae fe ff ff       	jmp    80124d <vprintfmt+0x24>
  80139f:	89 5d d8             	mov    %ebx,-0x28(%ebp)
  8013a2:	89 de                	mov    %ebx,%esi
  8013a4:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  8013a7:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8013aa:	8b 45 14             	mov    0x14(%ebp),%eax
  8013ad:	8d 50 04             	lea    0x4(%eax),%edx
  8013b0:	89 55 14             	mov    %edx,0x14(%ebp)
  8013b3:	8b 00                	mov    (%eax),%eax
  8013b5:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8013b8:	85 c0                	test   %eax,%eax
  8013ba:	75 07                	jne    8013c3 <vprintfmt+0x19a>
				p = "(null)";
  8013bc:	c7 45 d0 44 1f 80 00 	movl   $0x801f44,-0x30(%ebp)
			if (width > 0 && padc != '-')
  8013c3:	85 db                	test   %ebx,%ebx
  8013c5:	7e 42                	jle    801409 <vprintfmt+0x1e0>
  8013c7:	80 7d dc 2d          	cmpb   $0x2d,-0x24(%ebp)
  8013cb:	74 3c                	je     801409 <vprintfmt+0x1e0>
				for (width -= strnlen(p, precision); width > 0; width--)
  8013cd:	83 ec 08             	sub    $0x8,%esp
  8013d0:	51                   	push   %ecx
  8013d1:	ff 75 d0             	pushl  -0x30(%ebp)
  8013d4:	e8 6f 02 00 00       	call   801648 <strnlen>
  8013d9:	29 c3                	sub    %eax,%ebx
  8013db:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8013de:	83 c4 10             	add    $0x10,%esp
  8013e1:	85 db                	test   %ebx,%ebx
  8013e3:	7e 24                	jle    801409 <vprintfmt+0x1e0>
					putch(padc, putdat);
  8013e5:	0f be 5d dc          	movsbl -0x24(%ebp),%ebx
  8013e9:	89 75 dc             	mov    %esi,-0x24(%ebp)
  8013ec:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  8013ef:	83 ec 08             	sub    $0x8,%esp
  8013f2:	57                   	push   %edi
  8013f3:	53                   	push   %ebx
  8013f4:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8013f7:	4e                   	dec    %esi
  8013f8:	83 c4 10             	add    $0x10,%esp
  8013fb:	85 f6                	test   %esi,%esi
  8013fd:	7f f0                	jg     8013ef <vprintfmt+0x1c6>
  8013ff:	8b 75 dc             	mov    -0x24(%ebp),%esi
  801402:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  801409:	8b 55 d0             	mov    -0x30(%ebp),%edx
  80140c:	0f be 02             	movsbl (%edx),%eax
  80140f:	85 c0                	test   %eax,%eax
  801411:	75 47                	jne    80145a <vprintfmt+0x231>
  801413:	eb 37                	jmp    80144c <vprintfmt+0x223>
				if (altflag && (ch < ' ' || ch > '~'))
  801415:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  801419:	74 16                	je     801431 <vprintfmt+0x208>
  80141b:	8d 50 e0             	lea    -0x20(%eax),%edx
  80141e:	83 fa 5e             	cmp    $0x5e,%edx
  801421:	76 0e                	jbe    801431 <vprintfmt+0x208>
					putch('?', putdat);
  801423:	83 ec 08             	sub    $0x8,%esp
  801426:	57                   	push   %edi
  801427:	6a 3f                	push   $0x3f
  801429:	ff 55 08             	call   *0x8(%ebp)
  80142c:	83 c4 10             	add    $0x10,%esp
  80142f:	eb 0b                	jmp    80143c <vprintfmt+0x213>
				else
					putch(ch, putdat);
  801431:	83 ec 08             	sub    $0x8,%esp
  801434:	57                   	push   %edi
  801435:	50                   	push   %eax
  801436:	ff 55 08             	call   *0x8(%ebp)
  801439:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80143c:	ff 4d e4             	decl   -0x1c(%ebp)
  80143f:	0f be 03             	movsbl (%ebx),%eax
  801442:	85 c0                	test   %eax,%eax
  801444:	74 03                	je     801449 <vprintfmt+0x220>
  801446:	43                   	inc    %ebx
  801447:	eb 1b                	jmp    801464 <vprintfmt+0x23b>
  801449:	8b 75 dc             	mov    -0x24(%ebp),%esi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80144c:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  801450:	7f 1e                	jg     801470 <vprintfmt+0x247>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801452:	8b 75 d8             	mov    -0x28(%ebp),%esi
  801455:	e9 f3 fd ff ff       	jmp    80124d <vprintfmt+0x24>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80145a:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  80145d:	43                   	inc    %ebx
  80145e:	89 75 dc             	mov    %esi,-0x24(%ebp)
  801461:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  801464:	85 f6                	test   %esi,%esi
  801466:	78 ad                	js     801415 <vprintfmt+0x1ec>
  801468:	4e                   	dec    %esi
  801469:	79 aa                	jns    801415 <vprintfmt+0x1ec>
  80146b:	8b 75 dc             	mov    -0x24(%ebp),%esi
  80146e:	eb dc                	jmp    80144c <vprintfmt+0x223>
  801470:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  801473:	83 ec 08             	sub    $0x8,%esp
  801476:	57                   	push   %edi
  801477:	6a 20                	push   $0x20
  801479:	ff 55 08             	call   *0x8(%ebp)
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80147c:	4b                   	dec    %ebx
  80147d:	83 c4 10             	add    $0x10,%esp
  801480:	85 db                	test   %ebx,%ebx
  801482:	7f ef                	jg     801473 <vprintfmt+0x24a>
  801484:	e9 c4 fd ff ff       	jmp    80124d <vprintfmt+0x24>
  801489:	89 5d d8             	mov    %ebx,-0x28(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80148c:	89 ca                	mov    %ecx,%edx
  80148e:	8d 45 14             	lea    0x14(%ebp),%eax
  801491:	e8 2a fd ff ff       	call   8011c0 <getint>
  801496:	89 c3                	mov    %eax,%ebx
  801498:	89 d6                	mov    %edx,%esi
			if ((long long) num < 0) {
  80149a:	85 d2                	test   %edx,%edx
  80149c:	78 0a                	js     8014a8 <vprintfmt+0x27f>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  80149e:	b8 0a 00 00 00       	mov    $0xa,%eax
  8014a3:	e9 b0 00 00 00       	jmp    801558 <vprintfmt+0x32f>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  8014a8:	83 ec 08             	sub    $0x8,%esp
  8014ab:	57                   	push   %edi
  8014ac:	6a 2d                	push   $0x2d
  8014ae:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  8014b1:	f7 db                	neg    %ebx
  8014b3:	83 d6 00             	adc    $0x0,%esi
  8014b6:	f7 de                	neg    %esi
  8014b8:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  8014bb:	b8 0a 00 00 00       	mov    $0xa,%eax
  8014c0:	e9 93 00 00 00       	jmp    801558 <vprintfmt+0x32f>
  8014c5:	89 5d d8             	mov    %ebx,-0x28(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8014c8:	89 ca                	mov    %ecx,%edx
  8014ca:	8d 45 14             	lea    0x14(%ebp),%eax
  8014cd:	e8 b4 fc ff ff       	call   801186 <getuint>
  8014d2:	89 c3                	mov    %eax,%ebx
  8014d4:	89 d6                	mov    %edx,%esi
			base = 10;
  8014d6:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  8014db:	eb 7b                	jmp    801558 <vprintfmt+0x32f>
  8014dd:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// (unsigned) octal
		case 'o':
            // (MIT 6.828, lab1, Ex.8)  my code : 
            num = getint(&ap, lflag);
  8014e0:	89 ca                	mov    %ecx,%edx
  8014e2:	8d 45 14             	lea    0x14(%ebp),%eax
  8014e5:	e8 d6 fc ff ff       	call   8011c0 <getint>
  8014ea:	89 c3                	mov    %eax,%ebx
  8014ec:	89 d6                	mov    %edx,%esi
            if ((long long) num < 0) {
  8014ee:	85 d2                	test   %edx,%edx
  8014f0:	78 07                	js     8014f9 <vprintfmt+0x2d0>
                putch('-', putdat);
                num = -(long long) num;
            }
            base = 8;
  8014f2:	b8 08 00 00 00       	mov    $0x8,%eax
  8014f7:	eb 5f                	jmp    801558 <vprintfmt+0x32f>
		// (unsigned) octal
		case 'o':
            // (MIT 6.828, lab1, Ex.8)  my code : 
            num = getint(&ap, lflag);
            if ((long long) num < 0) {
                putch('-', putdat);
  8014f9:	83 ec 08             	sub    $0x8,%esp
  8014fc:	57                   	push   %edi
  8014fd:	6a 2d                	push   $0x2d
  8014ff:	ff 55 08             	call   *0x8(%ebp)
                num = -(long long) num;
  801502:	f7 db                	neg    %ebx
  801504:	83 d6 00             	adc    $0x0,%esi
  801507:	f7 de                	neg    %esi
  801509:	83 c4 10             	add    $0x10,%esp
            }
            base = 8;
  80150c:	b8 08 00 00 00       	mov    $0x8,%eax
  801511:	eb 45                	jmp    801558 <vprintfmt+0x32f>
  801513:	89 5d d8             	mov    %ebx,-0x28(%ebp)
            goto number;

        // pointer
		case 'p':
			putch('0', putdat);
  801516:	83 ec 08             	sub    $0x8,%esp
  801519:	57                   	push   %edi
  80151a:	6a 30                	push   $0x30
  80151c:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  80151f:	83 c4 08             	add    $0x8,%esp
  801522:	57                   	push   %edi
  801523:	6a 78                	push   $0x78
  801525:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  801528:	8b 45 14             	mov    0x14(%ebp),%eax
  80152b:	8d 50 04             	lea    0x4(%eax),%edx
  80152e:	89 55 14             	mov    %edx,0x14(%ebp)

        // pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  801531:	8b 18                	mov    (%eax),%ebx
  801533:	be 00 00 00 00       	mov    $0x0,%esi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  801538:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  80153b:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  801540:	eb 16                	jmp    801558 <vprintfmt+0x32f>
  801542:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  801545:	89 ca                	mov    %ecx,%edx
  801547:	8d 45 14             	lea    0x14(%ebp),%eax
  80154a:	e8 37 fc ff ff       	call   801186 <getuint>
  80154f:	89 c3                	mov    %eax,%ebx
  801551:	89 d6                	mov    %edx,%esi
			base = 16;
  801553:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  801558:	83 ec 0c             	sub    $0xc,%esp
  80155b:	0f be 55 dc          	movsbl -0x24(%ebp),%edx
  80155f:	52                   	push   %edx
  801560:	ff 75 e4             	pushl  -0x1c(%ebp)
  801563:	50                   	push   %eax
  801564:	56                   	push   %esi
  801565:	53                   	push   %ebx
  801566:	89 fa                	mov    %edi,%edx
  801568:	8b 45 08             	mov    0x8(%ebp),%eax
  80156b:	e8 68 fb ff ff       	call   8010d8 <printnum>
			break;
  801570:	83 c4 20             	add    $0x20,%esp
  801573:	8b 75 d8             	mov    -0x28(%ebp),%esi
  801576:	e9 d2 fc ff ff       	jmp    80124d <vprintfmt+0x24>
  80157b:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80157e:	83 ec 08             	sub    $0x8,%esp
  801581:	57                   	push   %edi
  801582:	52                   	push   %edx
  801583:	ff 55 08             	call   *0x8(%ebp)
			break;
  801586:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801589:	8b 75 d8             	mov    -0x28(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  80158c:	e9 bc fc ff ff       	jmp    80124d <vprintfmt+0x24>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  801591:	83 ec 08             	sub    $0x8,%esp
  801594:	57                   	push   %edi
  801595:	6a 25                	push   $0x25
  801597:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  80159a:	83 c4 10             	add    $0x10,%esp
  80159d:	eb 02                	jmp    8015a1 <vprintfmt+0x378>
  80159f:	89 c6                	mov    %eax,%esi
  8015a1:	8d 46 ff             	lea    -0x1(%esi),%eax
  8015a4:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  8015a8:	75 f5                	jne    80159f <vprintfmt+0x376>
  8015aa:	e9 9e fc ff ff       	jmp    80124d <vprintfmt+0x24>
				/* do nothing */;
			break;
		}
	}
}
  8015af:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8015b2:	5b                   	pop    %ebx
  8015b3:	5e                   	pop    %esi
  8015b4:	5f                   	pop    %edi
  8015b5:	c9                   	leave  
  8015b6:	c3                   	ret    

008015b7 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8015b7:	55                   	push   %ebp
  8015b8:	89 e5                	mov    %esp,%ebp
  8015ba:	83 ec 18             	sub    $0x18,%esp
  8015bd:	8b 45 08             	mov    0x8(%ebp),%eax
  8015c0:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8015c3:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8015c6:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8015ca:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8015cd:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8015d4:	85 c0                	test   %eax,%eax
  8015d6:	74 26                	je     8015fe <vsnprintf+0x47>
  8015d8:	85 d2                	test   %edx,%edx
  8015da:	7e 29                	jle    801605 <vsnprintf+0x4e>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8015dc:	ff 75 14             	pushl  0x14(%ebp)
  8015df:	ff 75 10             	pushl  0x10(%ebp)
  8015e2:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8015e5:	50                   	push   %eax
  8015e6:	68 f2 11 80 00       	push   $0x8011f2
  8015eb:	e8 39 fc ff ff       	call   801229 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8015f0:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8015f3:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8015f6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8015f9:	83 c4 10             	add    $0x10,%esp
  8015fc:	eb 0c                	jmp    80160a <vsnprintf+0x53>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8015fe:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801603:	eb 05                	jmp    80160a <vsnprintf+0x53>
  801605:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  80160a:	c9                   	leave  
  80160b:	c3                   	ret    

0080160c <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80160c:	55                   	push   %ebp
  80160d:	89 e5                	mov    %esp,%ebp
  80160f:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  801612:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  801615:	50                   	push   %eax
  801616:	ff 75 10             	pushl  0x10(%ebp)
  801619:	ff 75 0c             	pushl  0xc(%ebp)
  80161c:	ff 75 08             	pushl  0x8(%ebp)
  80161f:	e8 93 ff ff ff       	call   8015b7 <vsnprintf>
	va_end(ap);

	return rc;
}
  801624:	c9                   	leave  
  801625:	c3                   	ret    
	...

00801628 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  801628:	55                   	push   %ebp
  801629:	89 e5                	mov    %esp,%ebp
  80162b:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80162e:	80 3a 00             	cmpb   $0x0,(%edx)
  801631:	74 0e                	je     801641 <strlen+0x19>
  801633:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  801638:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  801639:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  80163d:	75 f9                	jne    801638 <strlen+0x10>
  80163f:	eb 05                	jmp    801646 <strlen+0x1e>
  801641:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  801646:	c9                   	leave  
  801647:	c3                   	ret    

00801648 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  801648:	55                   	push   %ebp
  801649:	89 e5                	mov    %esp,%ebp
  80164b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80164e:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801651:	85 d2                	test   %edx,%edx
  801653:	74 17                	je     80166c <strnlen+0x24>
  801655:	80 39 00             	cmpb   $0x0,(%ecx)
  801658:	74 19                	je     801673 <strnlen+0x2b>
  80165a:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  80165f:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801660:	39 d0                	cmp    %edx,%eax
  801662:	74 14                	je     801678 <strnlen+0x30>
  801664:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  801668:	75 f5                	jne    80165f <strnlen+0x17>
  80166a:	eb 0c                	jmp    801678 <strnlen+0x30>
  80166c:	b8 00 00 00 00       	mov    $0x0,%eax
  801671:	eb 05                	jmp    801678 <strnlen+0x30>
  801673:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  801678:	c9                   	leave  
  801679:	c3                   	ret    

0080167a <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80167a:	55                   	push   %ebp
  80167b:	89 e5                	mov    %esp,%ebp
  80167d:	53                   	push   %ebx
  80167e:	8b 45 08             	mov    0x8(%ebp),%eax
  801681:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  801684:	ba 00 00 00 00       	mov    $0x0,%edx
  801689:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  80168c:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  80168f:	42                   	inc    %edx
  801690:	84 c9                	test   %cl,%cl
  801692:	75 f5                	jne    801689 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  801694:	5b                   	pop    %ebx
  801695:	c9                   	leave  
  801696:	c3                   	ret    

00801697 <strcat>:

char *
strcat(char *dst, const char *src)
{
  801697:	55                   	push   %ebp
  801698:	89 e5                	mov    %esp,%ebp
  80169a:	53                   	push   %ebx
  80169b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80169e:	53                   	push   %ebx
  80169f:	e8 84 ff ff ff       	call   801628 <strlen>
  8016a4:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8016a7:	ff 75 0c             	pushl  0xc(%ebp)
  8016aa:	8d 04 03             	lea    (%ebx,%eax,1),%eax
  8016ad:	50                   	push   %eax
  8016ae:	e8 c7 ff ff ff       	call   80167a <strcpy>
	return dst;
}
  8016b3:	89 d8                	mov    %ebx,%eax
  8016b5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016b8:	c9                   	leave  
  8016b9:	c3                   	ret    

008016ba <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8016ba:	55                   	push   %ebp
  8016bb:	89 e5                	mov    %esp,%ebp
  8016bd:	56                   	push   %esi
  8016be:	53                   	push   %ebx
  8016bf:	8b 45 08             	mov    0x8(%ebp),%eax
  8016c2:	8b 55 0c             	mov    0xc(%ebp),%edx
  8016c5:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8016c8:	85 f6                	test   %esi,%esi
  8016ca:	74 15                	je     8016e1 <strncpy+0x27>
  8016cc:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
  8016d1:	8a 1a                	mov    (%edx),%bl
  8016d3:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8016d6:	80 3a 01             	cmpb   $0x1,(%edx)
  8016d9:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8016dc:	41                   	inc    %ecx
  8016dd:	39 ce                	cmp    %ecx,%esi
  8016df:	77 f0                	ja     8016d1 <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8016e1:	5b                   	pop    %ebx
  8016e2:	5e                   	pop    %esi
  8016e3:	c9                   	leave  
  8016e4:	c3                   	ret    

008016e5 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8016e5:	55                   	push   %ebp
  8016e6:	89 e5                	mov    %esp,%ebp
  8016e8:	57                   	push   %edi
  8016e9:	56                   	push   %esi
  8016ea:	53                   	push   %ebx
  8016eb:	8b 7d 08             	mov    0x8(%ebp),%edi
  8016ee:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8016f1:	8b 75 10             	mov    0x10(%ebp),%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8016f4:	85 f6                	test   %esi,%esi
  8016f6:	74 32                	je     80172a <strlcpy+0x45>
		while (--size > 0 && *src != '\0')
  8016f8:	83 fe 01             	cmp    $0x1,%esi
  8016fb:	74 22                	je     80171f <strlcpy+0x3a>
  8016fd:	8a 0b                	mov    (%ebx),%cl
  8016ff:	84 c9                	test   %cl,%cl
  801701:	74 20                	je     801723 <strlcpy+0x3e>
  801703:	89 f8                	mov    %edi,%eax
  801705:	ba 00 00 00 00       	mov    $0x0,%edx
	}
	return ret;
}

size_t
strlcpy(char *dst, const char *src, size_t size)
  80170a:	83 ee 02             	sub    $0x2,%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  80170d:	88 08                	mov    %cl,(%eax)
  80170f:	40                   	inc    %eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  801710:	39 f2                	cmp    %esi,%edx
  801712:	74 11                	je     801725 <strlcpy+0x40>
  801714:	8a 4c 13 01          	mov    0x1(%ebx,%edx,1),%cl
  801718:	42                   	inc    %edx
  801719:	84 c9                	test   %cl,%cl
  80171b:	75 f0                	jne    80170d <strlcpy+0x28>
  80171d:	eb 06                	jmp    801725 <strlcpy+0x40>
  80171f:	89 f8                	mov    %edi,%eax
  801721:	eb 02                	jmp    801725 <strlcpy+0x40>
  801723:	89 f8                	mov    %edi,%eax
			*dst++ = *src++;
		*dst = '\0';
  801725:	c6 00 00             	movb   $0x0,(%eax)
  801728:	eb 02                	jmp    80172c <strlcpy+0x47>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80172a:	89 f8                	mov    %edi,%eax
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
		*dst = '\0';
	}
	return dst - dst_in;
  80172c:	29 f8                	sub    %edi,%eax
}
  80172e:	5b                   	pop    %ebx
  80172f:	5e                   	pop    %esi
  801730:	5f                   	pop    %edi
  801731:	c9                   	leave  
  801732:	c3                   	ret    

00801733 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  801733:	55                   	push   %ebp
  801734:	89 e5                	mov    %esp,%ebp
  801736:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801739:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80173c:	8a 01                	mov    (%ecx),%al
  80173e:	84 c0                	test   %al,%al
  801740:	74 10                	je     801752 <strcmp+0x1f>
  801742:	3a 02                	cmp    (%edx),%al
  801744:	75 0c                	jne    801752 <strcmp+0x1f>
		p++, q++;
  801746:	41                   	inc    %ecx
  801747:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  801748:	8a 01                	mov    (%ecx),%al
  80174a:	84 c0                	test   %al,%al
  80174c:	74 04                	je     801752 <strcmp+0x1f>
  80174e:	3a 02                	cmp    (%edx),%al
  801750:	74 f4                	je     801746 <strcmp+0x13>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  801752:	0f b6 c0             	movzbl %al,%eax
  801755:	0f b6 12             	movzbl (%edx),%edx
  801758:	29 d0                	sub    %edx,%eax
}
  80175a:	c9                   	leave  
  80175b:	c3                   	ret    

0080175c <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  80175c:	55                   	push   %ebp
  80175d:	89 e5                	mov    %esp,%ebp
  80175f:	53                   	push   %ebx
  801760:	8b 55 08             	mov    0x8(%ebp),%edx
  801763:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801766:	8b 45 10             	mov    0x10(%ebp),%eax
	while (n > 0 && *p && *p == *q)
  801769:	85 c0                	test   %eax,%eax
  80176b:	74 1b                	je     801788 <strncmp+0x2c>
  80176d:	8a 1a                	mov    (%edx),%bl
  80176f:	84 db                	test   %bl,%bl
  801771:	74 24                	je     801797 <strncmp+0x3b>
  801773:	3a 19                	cmp    (%ecx),%bl
  801775:	75 20                	jne    801797 <strncmp+0x3b>
  801777:	48                   	dec    %eax
  801778:	74 15                	je     80178f <strncmp+0x33>
		n--, p++, q++;
  80177a:	42                   	inc    %edx
  80177b:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  80177c:	8a 1a                	mov    (%edx),%bl
  80177e:	84 db                	test   %bl,%bl
  801780:	74 15                	je     801797 <strncmp+0x3b>
  801782:	3a 19                	cmp    (%ecx),%bl
  801784:	74 f1                	je     801777 <strncmp+0x1b>
  801786:	eb 0f                	jmp    801797 <strncmp+0x3b>
		n--, p++, q++;
	if (n == 0)
		return 0;
  801788:	b8 00 00 00 00       	mov    $0x0,%eax
  80178d:	eb 05                	jmp    801794 <strncmp+0x38>
  80178f:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  801794:	5b                   	pop    %ebx
  801795:	c9                   	leave  
  801796:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  801797:	0f b6 02             	movzbl (%edx),%eax
  80179a:	0f b6 11             	movzbl (%ecx),%edx
  80179d:	29 d0                	sub    %edx,%eax
  80179f:	eb f3                	jmp    801794 <strncmp+0x38>

008017a1 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8017a1:	55                   	push   %ebp
  8017a2:	89 e5                	mov    %esp,%ebp
  8017a4:	8b 45 08             	mov    0x8(%ebp),%eax
  8017a7:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  8017aa:	8a 10                	mov    (%eax),%dl
  8017ac:	84 d2                	test   %dl,%dl
  8017ae:	74 18                	je     8017c8 <strchr+0x27>
		if (*s == c)
  8017b0:	38 ca                	cmp    %cl,%dl
  8017b2:	75 06                	jne    8017ba <strchr+0x19>
  8017b4:	eb 17                	jmp    8017cd <strchr+0x2c>
  8017b6:	38 ca                	cmp    %cl,%dl
  8017b8:	74 13                	je     8017cd <strchr+0x2c>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8017ba:	40                   	inc    %eax
  8017bb:	8a 10                	mov    (%eax),%dl
  8017bd:	84 d2                	test   %dl,%dl
  8017bf:	75 f5                	jne    8017b6 <strchr+0x15>
		if (*s == c)
			return (char *) s;
	return 0;
  8017c1:	b8 00 00 00 00       	mov    $0x0,%eax
  8017c6:	eb 05                	jmp    8017cd <strchr+0x2c>
  8017c8:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8017cd:	c9                   	leave  
  8017ce:	c3                   	ret    

008017cf <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8017cf:	55                   	push   %ebp
  8017d0:	89 e5                	mov    %esp,%ebp
  8017d2:	8b 45 08             	mov    0x8(%ebp),%eax
  8017d5:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  8017d8:	8a 10                	mov    (%eax),%dl
  8017da:	84 d2                	test   %dl,%dl
  8017dc:	74 11                	je     8017ef <strfind+0x20>
		if (*s == c)
  8017de:	38 ca                	cmp    %cl,%dl
  8017e0:	75 06                	jne    8017e8 <strfind+0x19>
  8017e2:	eb 0b                	jmp    8017ef <strfind+0x20>
  8017e4:	38 ca                	cmp    %cl,%dl
  8017e6:	74 07                	je     8017ef <strfind+0x20>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  8017e8:	40                   	inc    %eax
  8017e9:	8a 10                	mov    (%eax),%dl
  8017eb:	84 d2                	test   %dl,%dl
  8017ed:	75 f5                	jne    8017e4 <strfind+0x15>
		if (*s == c)
			break;
	return (char *) s;
}
  8017ef:	c9                   	leave  
  8017f0:	c3                   	ret    

008017f1 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8017f1:	55                   	push   %ebp
  8017f2:	89 e5                	mov    %esp,%ebp
  8017f4:	57                   	push   %edi
  8017f5:	56                   	push   %esi
  8017f6:	53                   	push   %ebx
  8017f7:	8b 7d 08             	mov    0x8(%ebp),%edi
  8017fa:	8b 45 0c             	mov    0xc(%ebp),%eax
  8017fd:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  801800:	85 c9                	test   %ecx,%ecx
  801802:	74 30                	je     801834 <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  801804:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80180a:	75 25                	jne    801831 <memset+0x40>
  80180c:	f6 c1 03             	test   $0x3,%cl
  80180f:	75 20                	jne    801831 <memset+0x40>
		c &= 0xFF;
  801811:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  801814:	89 d3                	mov    %edx,%ebx
  801816:	c1 e3 08             	shl    $0x8,%ebx
  801819:	89 d6                	mov    %edx,%esi
  80181b:	c1 e6 18             	shl    $0x18,%esi
  80181e:	89 d0                	mov    %edx,%eax
  801820:	c1 e0 10             	shl    $0x10,%eax
  801823:	09 f0                	or     %esi,%eax
  801825:	09 d0                	or     %edx,%eax
  801827:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  801829:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  80182c:	fc                   	cld    
  80182d:	f3 ab                	rep stos %eax,%es:(%edi)
  80182f:	eb 03                	jmp    801834 <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  801831:	fc                   	cld    
  801832:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  801834:	89 f8                	mov    %edi,%eax
  801836:	5b                   	pop    %ebx
  801837:	5e                   	pop    %esi
  801838:	5f                   	pop    %edi
  801839:	c9                   	leave  
  80183a:	c3                   	ret    

0080183b <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  80183b:	55                   	push   %ebp
  80183c:	89 e5                	mov    %esp,%ebp
  80183e:	57                   	push   %edi
  80183f:	56                   	push   %esi
  801840:	8b 45 08             	mov    0x8(%ebp),%eax
  801843:	8b 75 0c             	mov    0xc(%ebp),%esi
  801846:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  801849:	39 c6                	cmp    %eax,%esi
  80184b:	73 34                	jae    801881 <memmove+0x46>
  80184d:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  801850:	39 d0                	cmp    %edx,%eax
  801852:	73 2d                	jae    801881 <memmove+0x46>
		s += n;
		d += n;
  801854:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801857:	f6 c2 03             	test   $0x3,%dl
  80185a:	75 1b                	jne    801877 <memmove+0x3c>
  80185c:	f7 c7 03 00 00 00    	test   $0x3,%edi
  801862:	75 13                	jne    801877 <memmove+0x3c>
  801864:	f6 c1 03             	test   $0x3,%cl
  801867:	75 0e                	jne    801877 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  801869:	83 ef 04             	sub    $0x4,%edi
  80186c:	8d 72 fc             	lea    -0x4(%edx),%esi
  80186f:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  801872:	fd                   	std    
  801873:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801875:	eb 07                	jmp    80187e <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  801877:	4f                   	dec    %edi
  801878:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  80187b:	fd                   	std    
  80187c:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  80187e:	fc                   	cld    
  80187f:	eb 20                	jmp    8018a1 <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801881:	f7 c6 03 00 00 00    	test   $0x3,%esi
  801887:	75 13                	jne    80189c <memmove+0x61>
  801889:	a8 03                	test   $0x3,%al
  80188b:	75 0f                	jne    80189c <memmove+0x61>
  80188d:	f6 c1 03             	test   $0x3,%cl
  801890:	75 0a                	jne    80189c <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  801892:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  801895:	89 c7                	mov    %eax,%edi
  801897:	fc                   	cld    
  801898:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80189a:	eb 05                	jmp    8018a1 <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  80189c:	89 c7                	mov    %eax,%edi
  80189e:	fc                   	cld    
  80189f:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8018a1:	5e                   	pop    %esi
  8018a2:	5f                   	pop    %edi
  8018a3:	c9                   	leave  
  8018a4:	c3                   	ret    

008018a5 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8018a5:	55                   	push   %ebp
  8018a6:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  8018a8:	ff 75 10             	pushl  0x10(%ebp)
  8018ab:	ff 75 0c             	pushl  0xc(%ebp)
  8018ae:	ff 75 08             	pushl  0x8(%ebp)
  8018b1:	e8 85 ff ff ff       	call   80183b <memmove>
}
  8018b6:	c9                   	leave  
  8018b7:	c3                   	ret    

008018b8 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8018b8:	55                   	push   %ebp
  8018b9:	89 e5                	mov    %esp,%ebp
  8018bb:	57                   	push   %edi
  8018bc:	56                   	push   %esi
  8018bd:	53                   	push   %ebx
  8018be:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8018c1:	8b 75 0c             	mov    0xc(%ebp),%esi
  8018c4:	8b 7d 10             	mov    0x10(%ebp),%edi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8018c7:	85 ff                	test   %edi,%edi
  8018c9:	74 32                	je     8018fd <memcmp+0x45>
		if (*s1 != *s2)
  8018cb:	8a 03                	mov    (%ebx),%al
  8018cd:	8a 0e                	mov    (%esi),%cl
  8018cf:	38 c8                	cmp    %cl,%al
  8018d1:	74 19                	je     8018ec <memcmp+0x34>
  8018d3:	eb 0d                	jmp    8018e2 <memcmp+0x2a>
  8018d5:	8a 44 13 01          	mov    0x1(%ebx,%edx,1),%al
  8018d9:	8a 4c 16 01          	mov    0x1(%esi,%edx,1),%cl
  8018dd:	42                   	inc    %edx
  8018de:	38 c8                	cmp    %cl,%al
  8018e0:	74 10                	je     8018f2 <memcmp+0x3a>
			return (int) *s1 - (int) *s2;
  8018e2:	0f b6 c0             	movzbl %al,%eax
  8018e5:	0f b6 c9             	movzbl %cl,%ecx
  8018e8:	29 c8                	sub    %ecx,%eax
  8018ea:	eb 16                	jmp    801902 <memcmp+0x4a>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8018ec:	4f                   	dec    %edi
  8018ed:	ba 00 00 00 00       	mov    $0x0,%edx
  8018f2:	39 fa                	cmp    %edi,%edx
  8018f4:	75 df                	jne    8018d5 <memcmp+0x1d>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  8018f6:	b8 00 00 00 00       	mov    $0x0,%eax
  8018fb:	eb 05                	jmp    801902 <memcmp+0x4a>
  8018fd:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801902:	5b                   	pop    %ebx
  801903:	5e                   	pop    %esi
  801904:	5f                   	pop    %edi
  801905:	c9                   	leave  
  801906:	c3                   	ret    

00801907 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  801907:	55                   	push   %ebp
  801908:	89 e5                	mov    %esp,%ebp
  80190a:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  80190d:	89 c2                	mov    %eax,%edx
  80190f:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  801912:	39 d0                	cmp    %edx,%eax
  801914:	73 12                	jae    801928 <memfind+0x21>
		if (*(const unsigned char *) s == (unsigned char) c)
  801916:	8a 4d 0c             	mov    0xc(%ebp),%cl
  801919:	38 08                	cmp    %cl,(%eax)
  80191b:	75 06                	jne    801923 <memfind+0x1c>
  80191d:	eb 09                	jmp    801928 <memfind+0x21>
  80191f:	38 08                	cmp    %cl,(%eax)
  801921:	74 05                	je     801928 <memfind+0x21>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801923:	40                   	inc    %eax
  801924:	39 c2                	cmp    %eax,%edx
  801926:	77 f7                	ja     80191f <memfind+0x18>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  801928:	c9                   	leave  
  801929:	c3                   	ret    

0080192a <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  80192a:	55                   	push   %ebp
  80192b:	89 e5                	mov    %esp,%ebp
  80192d:	57                   	push   %edi
  80192e:	56                   	push   %esi
  80192f:	53                   	push   %ebx
  801930:	8b 55 08             	mov    0x8(%ebp),%edx
  801933:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801936:	eb 01                	jmp    801939 <strtol+0xf>
		s++;
  801938:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801939:	8a 02                	mov    (%edx),%al
  80193b:	3c 20                	cmp    $0x20,%al
  80193d:	74 f9                	je     801938 <strtol+0xe>
  80193f:	3c 09                	cmp    $0x9,%al
  801941:	74 f5                	je     801938 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  801943:	3c 2b                	cmp    $0x2b,%al
  801945:	75 08                	jne    80194f <strtol+0x25>
		s++;
  801947:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  801948:	bf 00 00 00 00       	mov    $0x0,%edi
  80194d:	eb 13                	jmp    801962 <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  80194f:	3c 2d                	cmp    $0x2d,%al
  801951:	75 0a                	jne    80195d <strtol+0x33>
		s++, neg = 1;
  801953:	8d 52 01             	lea    0x1(%edx),%edx
  801956:	bf 01 00 00 00       	mov    $0x1,%edi
  80195b:	eb 05                	jmp    801962 <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  80195d:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801962:	85 db                	test   %ebx,%ebx
  801964:	74 05                	je     80196b <strtol+0x41>
  801966:	83 fb 10             	cmp    $0x10,%ebx
  801969:	75 28                	jne    801993 <strtol+0x69>
  80196b:	8a 02                	mov    (%edx),%al
  80196d:	3c 30                	cmp    $0x30,%al
  80196f:	75 10                	jne    801981 <strtol+0x57>
  801971:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  801975:	75 0a                	jne    801981 <strtol+0x57>
		s += 2, base = 16;
  801977:	83 c2 02             	add    $0x2,%edx
  80197a:	bb 10 00 00 00       	mov    $0x10,%ebx
  80197f:	eb 12                	jmp    801993 <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  801981:	85 db                	test   %ebx,%ebx
  801983:	75 0e                	jne    801993 <strtol+0x69>
  801985:	3c 30                	cmp    $0x30,%al
  801987:	75 05                	jne    80198e <strtol+0x64>
		s++, base = 8;
  801989:	42                   	inc    %edx
  80198a:	b3 08                	mov    $0x8,%bl
  80198c:	eb 05                	jmp    801993 <strtol+0x69>
	else if (base == 0)
		base = 10;
  80198e:	bb 0a 00 00 00       	mov    $0xa,%ebx
  801993:	b8 00 00 00 00       	mov    $0x0,%eax
  801998:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  80199a:	8a 0a                	mov    (%edx),%cl
  80199c:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  80199f:	80 fb 09             	cmp    $0x9,%bl
  8019a2:	77 08                	ja     8019ac <strtol+0x82>
			dig = *s - '0';
  8019a4:	0f be c9             	movsbl %cl,%ecx
  8019a7:	83 e9 30             	sub    $0x30,%ecx
  8019aa:	eb 1e                	jmp    8019ca <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  8019ac:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  8019af:	80 fb 19             	cmp    $0x19,%bl
  8019b2:	77 08                	ja     8019bc <strtol+0x92>
			dig = *s - 'a' + 10;
  8019b4:	0f be c9             	movsbl %cl,%ecx
  8019b7:	83 e9 57             	sub    $0x57,%ecx
  8019ba:	eb 0e                	jmp    8019ca <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  8019bc:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  8019bf:	80 fb 19             	cmp    $0x19,%bl
  8019c2:	77 13                	ja     8019d7 <strtol+0xad>
			dig = *s - 'A' + 10;
  8019c4:	0f be c9             	movsbl %cl,%ecx
  8019c7:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  8019ca:	39 f1                	cmp    %esi,%ecx
  8019cc:	7d 0d                	jge    8019db <strtol+0xb1>
			break;
		s++, val = (val * base) + dig;
  8019ce:	42                   	inc    %edx
  8019cf:	0f af c6             	imul   %esi,%eax
  8019d2:	8d 04 01             	lea    (%ecx,%eax,1),%eax
		// we don't properly detect overflow!
	}
  8019d5:	eb c3                	jmp    80199a <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  8019d7:	89 c1                	mov    %eax,%ecx
  8019d9:	eb 02                	jmp    8019dd <strtol+0xb3>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  8019db:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  8019dd:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8019e1:	74 05                	je     8019e8 <strtol+0xbe>
		*endptr = (char *) s;
  8019e3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8019e6:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  8019e8:	85 ff                	test   %edi,%edi
  8019ea:	74 04                	je     8019f0 <strtol+0xc6>
  8019ec:	89 c8                	mov    %ecx,%eax
  8019ee:	f7 d8                	neg    %eax
}
  8019f0:	5b                   	pop    %ebx
  8019f1:	5e                   	pop    %esi
  8019f2:	5f                   	pop    %edi
  8019f3:	c9                   	leave  
  8019f4:	c3                   	ret    
  8019f5:	00 00                	add    %al,(%eax)
	...

008019f8 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8019f8:	55                   	push   %ebp
  8019f9:	89 e5                	mov    %esp,%ebp
  8019fb:	57                   	push   %edi
  8019fc:	56                   	push   %esi
  8019fd:	53                   	push   %ebx
  8019fe:	83 ec 0c             	sub    $0xc,%esp
  801a01:	8b 7d 08             	mov    0x8(%ebp),%edi
  801a04:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801a07:	8b 75 10             	mov    0x10(%ebp),%esi
	// LAB 4: Your code here.
	cprintf("0x%x 0x%x 0x%x\n", (uint32_t)from_env_store, (uint32_t)pg, (uint32_t)perm_store);
  801a0a:	56                   	push   %esi
  801a0b:	53                   	push   %ebx
  801a0c:	57                   	push   %edi
  801a0d:	68 40 22 80 00       	push   $0x802240
  801a12:	e8 ad f6 ff ff       	call   8010c4 <cprintf>
	int r;
	if (pg != NULL) {
  801a17:	83 c4 10             	add    $0x10,%esp
  801a1a:	85 db                	test   %ebx,%ebx
  801a1c:	74 28                	je     801a46 <ipc_recv+0x4e>
		cprintf("BEGIN\n");
  801a1e:	83 ec 0c             	sub    $0xc,%esp
  801a21:	68 50 22 80 00       	push   $0x802250
  801a26:	e8 99 f6 ff ff       	call   8010c4 <cprintf>
		r = sys_ipc_recv(pg);
  801a2b:	89 1c 24             	mov    %ebx,(%esp)
  801a2e:	e8 a0 e8 ff ff       	call   8002d3 <sys_ipc_recv>
  801a33:	89 c3                	mov    %eax,%ebx
		cprintf("OVER\n");
  801a35:	c7 04 24 a4 1e 80 00 	movl   $0x801ea4,(%esp)
  801a3c:	e8 83 f6 ff ff       	call   8010c4 <cprintf>
  801a41:	83 c4 10             	add    $0x10,%esp
  801a44:	eb 12                	jmp    801a58 <ipc_recv+0x60>
	} else {
		r = sys_ipc_recv((void *)UTOP);
  801a46:	83 ec 0c             	sub    $0xc,%esp
  801a49:	68 00 00 c0 ee       	push   $0xeec00000
  801a4e:	e8 80 e8 ff ff       	call   8002d3 <sys_ipc_recv>
  801a53:	89 c3                	mov    %eax,%ebx
  801a55:	83 c4 10             	add    $0x10,%esp
	}

	if (r == 0) {
  801a58:	85 db                	test   %ebx,%ebx
  801a5a:	75 26                	jne    801a82 <ipc_recv+0x8a>
		if (from_env_store != NULL) *from_env_store = thisenv->env_ipc_from;
  801a5c:	85 ff                	test   %edi,%edi
  801a5e:	74 0a                	je     801a6a <ipc_recv+0x72>
  801a60:	a1 04 40 80 00       	mov    0x804004,%eax
  801a65:	8b 40 74             	mov    0x74(%eax),%eax
  801a68:	89 07                	mov    %eax,(%edi)
		if (perm_store != NULL) *perm_store = thisenv->env_ipc_perm;
  801a6a:	85 f6                	test   %esi,%esi
  801a6c:	74 0a                	je     801a78 <ipc_recv+0x80>
  801a6e:	a1 04 40 80 00       	mov    0x804004,%eax
  801a73:	8b 40 78             	mov    0x78(%eax),%eax
  801a76:	89 06                	mov    %eax,(%esi)
		return thisenv->env_ipc_value;
  801a78:	a1 04 40 80 00       	mov    0x804004,%eax
  801a7d:	8b 58 70             	mov    0x70(%eax),%ebx
  801a80:	eb 14                	jmp    801a96 <ipc_recv+0x9e>
	} else {
		// fails;
		if (from_env_store != NULL) *from_env_store = 0;
  801a82:	85 ff                	test   %edi,%edi
  801a84:	74 06                	je     801a8c <ipc_recv+0x94>
  801a86:	c7 07 00 00 00 00    	movl   $0x0,(%edi)
		if (perm_store != NULL) *perm_store = 0;
  801a8c:	85 f6                	test   %esi,%esi
  801a8e:	74 06                	je     801a96 <ipc_recv+0x9e>
  801a90:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		return r;
	}
}
  801a96:	89 d8                	mov    %ebx,%eax
  801a98:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801a9b:	5b                   	pop    %ebx
  801a9c:	5e                   	pop    %esi
  801a9d:	5f                   	pop    %edi
  801a9e:	c9                   	leave  
  801a9f:	c3                   	ret    

00801aa0 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801aa0:	55                   	push   %ebp
  801aa1:	89 e5                	mov    %esp,%ebp
  801aa3:	57                   	push   %edi
  801aa4:	56                   	push   %esi
  801aa5:	53                   	push   %ebx
  801aa6:	83 ec 0c             	sub    $0xc,%esp
  801aa9:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801aac:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801aaf:	8b 75 14             	mov    0x14(%ebp),%esi
	// LAB 4: Your code here.
	// int sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
	int r;
	if (pg == NULL) pg = (void *)UTOP;
  801ab2:	85 db                	test   %ebx,%ebx
  801ab4:	75 25                	jne    801adb <ipc_send+0x3b>
  801ab6:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
  801abb:	eb 1e                	jmp    801adb <ipc_send+0x3b>
	
	while ((r = sys_ipc_try_send(to_env, val, pg, perm)) != 0) {
		if (r == -E_IPC_NOT_RECV) {
  801abd:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801ac0:	75 07                	jne    801ac9 <ipc_send+0x29>
			// cprintf("Try Again and Again....\n");
			sys_yield();
  801ac2:	e8 ea e6 ff ff       	call   8001b1 <sys_yield>
  801ac7:	eb 12                	jmp    801adb <ipc_send+0x3b>
		} else {
			panic("ipc_send error %e\n", r);
  801ac9:	50                   	push   %eax
  801aca:	68 57 22 80 00       	push   $0x802257
  801acf:	6a 45                	push   $0x45
  801ad1:	68 6a 22 80 00       	push   $0x80226a
  801ad6:	e8 11 f5 ff ff       	call   800fec <_panic>
	// LAB 4: Your code here.
	// int sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
	int r;
	if (pg == NULL) pg = (void *)UTOP;
	
	while ((r = sys_ipc_try_send(to_env, val, pg, perm)) != 0) {
  801adb:	56                   	push   %esi
  801adc:	53                   	push   %ebx
  801add:	57                   	push   %edi
  801ade:	ff 75 08             	pushl  0x8(%ebp)
  801ae1:	e8 c8 e7 ff ff       	call   8002ae <sys_ipc_try_send>
  801ae6:	83 c4 10             	add    $0x10,%esp
  801ae9:	85 c0                	test   %eax,%eax
  801aeb:	75 d0                	jne    801abd <ipc_send+0x1d>
		} else {
			panic("ipc_send error %e\n", r);
		}
	}
	return;
}
  801aed:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801af0:	5b                   	pop    %ebx
  801af1:	5e                   	pop    %esi
  801af2:	5f                   	pop    %edi
  801af3:	c9                   	leave  
  801af4:	c3                   	ret    

00801af5 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801af5:	55                   	push   %ebp
  801af6:	89 e5                	mov    %esp,%ebp
  801af8:	53                   	push   %ebx
  801af9:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	for (i = 0; i < NENV; i++)
		if (envs[i].env_type == type)
  801afc:	39 1d 50 00 c0 ee    	cmp    %ebx,0xeec00050
  801b02:	74 22                	je     801b26 <ipc_find_env+0x31>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801b04:	b8 01 00 00 00       	mov    $0x1,%eax
		if (envs[i].env_type == type)
  801b09:	8d 0c 85 00 00 00 00 	lea    0x0(,%eax,4),%ecx
  801b10:	89 c2                	mov    %eax,%edx
  801b12:	c1 e2 07             	shl    $0x7,%edx
  801b15:	29 ca                	sub    %ecx,%edx
  801b17:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801b1d:	8b 52 50             	mov    0x50(%edx),%edx
  801b20:	39 da                	cmp    %ebx,%edx
  801b22:	75 1d                	jne    801b41 <ipc_find_env+0x4c>
  801b24:	eb 05                	jmp    801b2b <ipc_find_env+0x36>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801b26:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
			return envs[i].env_id;
  801b2b:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  801b32:	c1 e0 07             	shl    $0x7,%eax
  801b35:	29 d0                	sub    %edx,%eax
  801b37:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  801b3c:	8b 40 40             	mov    0x40(%eax),%eax
  801b3f:	eb 0c                	jmp    801b4d <ipc_find_env+0x58>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801b41:	40                   	inc    %eax
  801b42:	3d 00 04 00 00       	cmp    $0x400,%eax
  801b47:	75 c0                	jne    801b09 <ipc_find_env+0x14>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801b49:	66 b8 00 00          	mov    $0x0,%ax
}
  801b4d:	5b                   	pop    %ebx
  801b4e:	c9                   	leave  
  801b4f:	c3                   	ret    

00801b50 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801b50:	55                   	push   %ebp
  801b51:	89 e5                	mov    %esp,%ebp
  801b53:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801b56:	89 c2                	mov    %eax,%edx
  801b58:	c1 ea 16             	shr    $0x16,%edx
  801b5b:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801b62:	f6 c2 01             	test   $0x1,%dl
  801b65:	74 1e                	je     801b85 <pageref+0x35>
		return 0;
	pte = uvpt[PGNUM(v)];
  801b67:	c1 e8 0c             	shr    $0xc,%eax
  801b6a:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  801b71:	a8 01                	test   $0x1,%al
  801b73:	74 17                	je     801b8c <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801b75:	c1 e8 0c             	shr    $0xc,%eax
  801b78:	66 8b 04 c5 04 00 00 	mov    -0x10fffffc(,%eax,8),%ax
  801b7f:	ef 
  801b80:	0f b7 c0             	movzwl %ax,%eax
  801b83:	eb 0c                	jmp    801b91 <pageref+0x41>
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
		return 0;
  801b85:	b8 00 00 00 00       	mov    $0x0,%eax
  801b8a:	eb 05                	jmp    801b91 <pageref+0x41>
	pte = uvpt[PGNUM(v)];
	if (!(pte & PTE_P))
		return 0;
  801b8c:	b8 00 00 00 00       	mov    $0x0,%eax
	return pages[PGNUM(pte)].pp_ref;
}
  801b91:	c9                   	leave  
  801b92:	c3                   	ret    
	...

00801b94 <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  801b94:	55                   	push   %ebp
  801b95:	89 e5                	mov    %esp,%ebp
  801b97:	57                   	push   %edi
  801b98:	56                   	push   %esi
  801b99:	83 ec 10             	sub    $0x10,%esp
  801b9c:	8b 7d 08             	mov    0x8(%ebp),%edi
  801b9f:	8b 4d 10             	mov    0x10(%ebp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  801ba2:	89 7d f0             	mov    %edi,-0x10(%ebp)
  801ba5:	8b 75 0c             	mov    0xc(%ebp),%esi
  const DWunion dd = {.ll = d};
  801ba8:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  801bab:	8b 45 14             	mov    0x14(%ebp),%eax
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  801bae:	85 c0                	test   %eax,%eax
  801bb0:	75 2e                	jne    801be0 <__udivdi3+0x4c>
    {
      if (d0 > n1)
  801bb2:	39 f1                	cmp    %esi,%ecx
  801bb4:	77 5a                	ja     801c10 <__udivdi3+0x7c>
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  801bb6:	85 c9                	test   %ecx,%ecx
  801bb8:	75 0b                	jne    801bc5 <__udivdi3+0x31>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  801bba:	b8 01 00 00 00       	mov    $0x1,%eax
  801bbf:	31 d2                	xor    %edx,%edx
  801bc1:	f7 f1                	div    %ecx
  801bc3:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  801bc5:	31 d2                	xor    %edx,%edx
  801bc7:	89 f0                	mov    %esi,%eax
  801bc9:	f7 f1                	div    %ecx
  801bcb:	89 c6                	mov    %eax,%esi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801bcd:	89 f8                	mov    %edi,%eax
  801bcf:	f7 f1                	div    %ecx
  801bd1:	89 c7                	mov    %eax,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  801bd3:	89 f8                	mov    %edi,%eax
  801bd5:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801bd7:	83 c4 10             	add    $0x10,%esp
  801bda:	5e                   	pop    %esi
  801bdb:	5f                   	pop    %edi
  801bdc:	c9                   	leave  
  801bdd:	c3                   	ret    
  801bde:	66 90                	xchg   %ax,%ax
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  801be0:	39 f0                	cmp    %esi,%eax
  801be2:	77 1c                	ja     801c00 <__udivdi3+0x6c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  801be4:	0f bd f8             	bsr    %eax,%edi
	  if (bm == 0)
  801be7:	83 f7 1f             	xor    $0x1f,%edi
  801bea:	75 3c                	jne    801c28 <__udivdi3+0x94>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  801bec:	39 f0                	cmp    %esi,%eax
  801bee:	0f 82 90 00 00 00    	jb     801c84 <__udivdi3+0xf0>
  801bf4:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801bf7:	39 55 f4             	cmp    %edx,-0xc(%ebp)
  801bfa:	0f 86 84 00 00 00    	jbe    801c84 <__udivdi3+0xf0>
  801c00:	31 f6                	xor    %esi,%esi
  801c02:	31 ff                	xor    %edi,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  801c04:	89 f8                	mov    %edi,%eax
  801c06:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801c08:	83 c4 10             	add    $0x10,%esp
  801c0b:	5e                   	pop    %esi
  801c0c:	5f                   	pop    %edi
  801c0d:	c9                   	leave  
  801c0e:	c3                   	ret    
  801c0f:	90                   	nop
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801c10:	89 f2                	mov    %esi,%edx
  801c12:	89 f8                	mov    %edi,%eax
  801c14:	f7 f1                	div    %ecx
  801c16:	89 c7                	mov    %eax,%edi
  801c18:	31 f6                	xor    %esi,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  801c1a:	89 f8                	mov    %edi,%eax
  801c1c:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801c1e:	83 c4 10             	add    $0x10,%esp
  801c21:	5e                   	pop    %esi
  801c22:	5f                   	pop    %edi
  801c23:	c9                   	leave  
  801c24:	c3                   	ret    
  801c25:	8d 76 00             	lea    0x0(%esi),%esi
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  801c28:	89 f9                	mov    %edi,%ecx
  801c2a:	d3 e0                	shl    %cl,%eax
  801c2c:	89 45 e8             	mov    %eax,-0x18(%ebp)
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  801c2f:	b8 20 00 00 00       	mov    $0x20,%eax
  801c34:	29 f8                	sub    %edi,%eax

	      d1 = (d1 << bm) | (d0 >> b);
  801c36:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801c39:	88 c1                	mov    %al,%cl
  801c3b:	d3 ea                	shr    %cl,%edx
  801c3d:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  801c40:	09 ca                	or     %ecx,%edx
  801c42:	89 55 ec             	mov    %edx,-0x14(%ebp)
	      d0 = d0 << bm;
  801c45:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801c48:	89 f9                	mov    %edi,%ecx
  801c4a:	d3 e2                	shl    %cl,%edx
  801c4c:	89 55 f4             	mov    %edx,-0xc(%ebp)
	      n2 = n1 >> b;
  801c4f:	89 f2                	mov    %esi,%edx
  801c51:	88 c1                	mov    %al,%cl
  801c53:	d3 ea                	shr    %cl,%edx
  801c55:	89 55 e8             	mov    %edx,-0x18(%ebp)
	      n1 = (n1 << bm) | (n0 >> b);
  801c58:	89 f2                	mov    %esi,%edx
  801c5a:	89 f9                	mov    %edi,%ecx
  801c5c:	d3 e2                	shl    %cl,%edx
  801c5e:	8b 75 f0             	mov    -0x10(%ebp),%esi
  801c61:	88 c1                	mov    %al,%cl
  801c63:	d3 ee                	shr    %cl,%esi
  801c65:	09 d6                	or     %edx,%esi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  801c67:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  801c6a:	89 f0                	mov    %esi,%eax
  801c6c:	89 ca                	mov    %ecx,%edx
  801c6e:	f7 75 ec             	divl   -0x14(%ebp)
  801c71:	89 d1                	mov    %edx,%ecx
  801c73:	89 c6                	mov    %eax,%esi
	      umul_ppmm (m1, m0, q0, d0);
  801c75:	f7 65 f4             	mull   -0xc(%ebp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801c78:	39 d1                	cmp    %edx,%ecx
  801c7a:	72 28                	jb     801ca4 <__udivdi3+0x110>
  801c7c:	74 1a                	je     801c98 <__udivdi3+0x104>
  801c7e:	89 f7                	mov    %esi,%edi
  801c80:	31 f6                	xor    %esi,%esi
  801c82:	eb 80                	jmp    801c04 <__udivdi3+0x70>
	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  801c84:	31 f6                	xor    %esi,%esi
  801c86:	bf 01 00 00 00       	mov    $0x1,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  801c8b:	89 f8                	mov    %edi,%eax
  801c8d:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801c8f:	83 c4 10             	add    $0x10,%esp
  801c92:	5e                   	pop    %esi
  801c93:	5f                   	pop    %edi
  801c94:	c9                   	leave  
  801c95:	c3                   	ret    
  801c96:	66 90                	xchg   %ax,%ax

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  801c98:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801c9b:	89 f9                	mov    %edi,%ecx
  801c9d:	d3 e2                	shl    %cl,%edx

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801c9f:	39 c2                	cmp    %eax,%edx
  801ca1:	73 db                	jae    801c7e <__udivdi3+0xea>
  801ca3:	90                   	nop
		{
		  q0--;
  801ca4:	8d 7e ff             	lea    -0x1(%esi),%edi
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  801ca7:	31 f6                	xor    %esi,%esi
  801ca9:	e9 56 ff ff ff       	jmp    801c04 <__udivdi3+0x70>
	...

00801cb0 <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  801cb0:	55                   	push   %ebp
  801cb1:	89 e5                	mov    %esp,%ebp
  801cb3:	57                   	push   %edi
  801cb4:	56                   	push   %esi
  801cb5:	83 ec 20             	sub    $0x20,%esp
  801cb8:	8b 45 08             	mov    0x8(%ebp),%eax
  801cbb:	8b 4d 10             	mov    0x10(%ebp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  801cbe:	89 45 e8             	mov    %eax,-0x18(%ebp)
  801cc1:	8b 75 0c             	mov    0xc(%ebp),%esi
  const DWunion dd = {.ll = d};
  801cc4:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  801cc7:	8b 7d 14             	mov    0x14(%ebp),%edi
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  801cca:	89 45 f0             	mov    %eax,-0x10(%ebp)
  n1 = nn.s.high;
  801ccd:	89 f2                	mov    %esi,%edx

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  801ccf:	85 ff                	test   %edi,%edi
  801cd1:	75 15                	jne    801ce8 <__umoddi3+0x38>
    {
      if (d0 > n1)
  801cd3:	39 f1                	cmp    %esi,%ecx
  801cd5:	0f 86 99 00 00 00    	jbe    801d74 <__umoddi3+0xc4>
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801cdb:	f7 f1                	div    %ecx

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
  801cdd:	89 d0                	mov    %edx,%eax
  801cdf:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  801ce1:	83 c4 20             	add    $0x20,%esp
  801ce4:	5e                   	pop    %esi
  801ce5:	5f                   	pop    %edi
  801ce6:	c9                   	leave  
  801ce7:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  801ce8:	39 f7                	cmp    %esi,%edi
  801cea:	0f 87 a4 00 00 00    	ja     801d94 <__umoddi3+0xe4>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  801cf0:	0f bd c7             	bsr    %edi,%eax
	  if (bm == 0)
  801cf3:	83 f0 1f             	xor    $0x1f,%eax
  801cf6:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801cf9:	0f 84 a1 00 00 00    	je     801da0 <__umoddi3+0xf0>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  801cff:	89 f8                	mov    %edi,%eax
  801d01:	8a 4d ec             	mov    -0x14(%ebp),%cl
  801d04:	d3 e0                	shl    %cl,%eax
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  801d06:	bf 20 00 00 00       	mov    $0x20,%edi
  801d0b:	2b 7d ec             	sub    -0x14(%ebp),%edi

	      d1 = (d1 << bm) | (d0 >> b);
  801d0e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801d11:	89 f9                	mov    %edi,%ecx
  801d13:	d3 ea                	shr    %cl,%edx
  801d15:	09 c2                	or     %eax,%edx
  801d17:	89 55 f0             	mov    %edx,-0x10(%ebp)
	      d0 = d0 << bm;
  801d1a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d1d:	8a 4d ec             	mov    -0x14(%ebp),%cl
  801d20:	d3 e0                	shl    %cl,%eax
  801d22:	89 45 f4             	mov    %eax,-0xc(%ebp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  801d25:	89 f2                	mov    %esi,%edx
  801d27:	d3 e2                	shl    %cl,%edx
	      n0 = n0 << bm;
  801d29:	8b 45 e8             	mov    -0x18(%ebp),%eax
  801d2c:	d3 e0                	shl    %cl,%eax
  801d2e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  801d31:	8b 45 e8             	mov    -0x18(%ebp),%eax
  801d34:	89 f9                	mov    %edi,%ecx
  801d36:	d3 e8                	shr    %cl,%eax
  801d38:	09 d0                	or     %edx,%eax

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  801d3a:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  801d3c:	89 f2                	mov    %esi,%edx
  801d3e:	f7 75 f0             	divl   -0x10(%ebp)
  801d41:	89 d6                	mov    %edx,%esi
	      umul_ppmm (m1, m0, q0, d0);
  801d43:	f7 65 f4             	mull   -0xc(%ebp)
  801d46:	89 55 e8             	mov    %edx,-0x18(%ebp)
  801d49:	89 c1                	mov    %eax,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801d4b:	39 d6                	cmp    %edx,%esi
  801d4d:	72 71                	jb     801dc0 <__umoddi3+0x110>
  801d4f:	74 7f                	je     801dd0 <__umoddi3+0x120>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  801d51:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801d54:	29 c8                	sub    %ecx,%eax
  801d56:	19 d6                	sbb    %edx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
  801d58:	8a 4d ec             	mov    -0x14(%ebp),%cl
  801d5b:	d3 e8                	shr    %cl,%eax
  801d5d:	89 f2                	mov    %esi,%edx
  801d5f:	89 f9                	mov    %edi,%ecx
  801d61:	d3 e2                	shl    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
  801d63:	09 d0                	or     %edx,%eax
  801d65:	89 f2                	mov    %esi,%edx
  801d67:	8a 4d ec             	mov    -0x14(%ebp),%cl
  801d6a:	d3 ea                	shr    %cl,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  801d6c:	83 c4 20             	add    $0x20,%esp
  801d6f:	5e                   	pop    %esi
  801d70:	5f                   	pop    %edi
  801d71:	c9                   	leave  
  801d72:	c3                   	ret    
  801d73:	90                   	nop
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  801d74:	85 c9                	test   %ecx,%ecx
  801d76:	75 0b                	jne    801d83 <__umoddi3+0xd3>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  801d78:	b8 01 00 00 00       	mov    $0x1,%eax
  801d7d:	31 d2                	xor    %edx,%edx
  801d7f:	f7 f1                	div    %ecx
  801d81:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  801d83:	89 f0                	mov    %esi,%eax
  801d85:	31 d2                	xor    %edx,%edx
  801d87:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801d89:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801d8c:	f7 f1                	div    %ecx
  801d8e:	e9 4a ff ff ff       	jmp    801cdd <__umoddi3+0x2d>
  801d93:	90                   	nop
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
  801d94:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  801d96:	83 c4 20             	add    $0x20,%esp
  801d99:	5e                   	pop    %esi
  801d9a:	5f                   	pop    %edi
  801d9b:	c9                   	leave  
  801d9c:	c3                   	ret    
  801d9d:	8d 76 00             	lea    0x0(%esi),%esi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  801da0:	39 f7                	cmp    %esi,%edi
  801da2:	72 05                	jb     801da9 <__umoddi3+0xf9>
  801da4:	3b 4d f0             	cmp    -0x10(%ebp),%ecx
  801da7:	77 0c                	ja     801db5 <__umoddi3+0x105>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  801da9:	89 f2                	mov    %esi,%edx
  801dab:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801dae:	29 c8                	sub    %ecx,%eax
  801db0:	19 fa                	sbb    %edi,%edx
  801db2:	89 45 f0             	mov    %eax,-0x10(%ebp)

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
  801db5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  801db8:	83 c4 20             	add    $0x20,%esp
  801dbb:	5e                   	pop    %esi
  801dbc:	5f                   	pop    %edi
  801dbd:	c9                   	leave  
  801dbe:	c3                   	ret    
  801dbf:	90                   	nop
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  801dc0:	8b 55 e8             	mov    -0x18(%ebp),%edx
  801dc3:	89 c1                	mov    %eax,%ecx
  801dc5:	2b 4d f4             	sub    -0xc(%ebp),%ecx
  801dc8:	1b 55 f0             	sbb    -0x10(%ebp),%edx
  801dcb:	eb 84                	jmp    801d51 <__umoddi3+0xa1>
  801dcd:	8d 76 00             	lea    0x0(%esi),%esi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801dd0:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  801dd3:	72 eb                	jb     801dc0 <__umoddi3+0x110>
  801dd5:	89 f2                	mov    %esi,%edx
  801dd7:	e9 75 ff ff ff       	jmp    801d51 <__umoddi3+0xa1>
