
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
  800106:	68 aa 1d 80 00       	push   $0x801daa
  80010b:	6a 42                	push   $0x42
  80010d:	68 c7 1d 80 00       	push   $0x801dc7
  800112:	e8 b5 0e 00 00       	call   800fcc <_panic>

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
  80043a:	8b 14 85 54 1e 80 00 	mov    0x801e54(,%eax,4),%edx
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
  800452:	68 d8 1d 80 00       	push   $0x801dd8
  800457:	e8 48 0c 00 00       	call   8010a4 <cprintf>
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
  800682:	68 19 1e 80 00       	push   $0x801e19
  800687:	e8 18 0a 00 00       	call   8010a4 <cprintf>
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
  800759:	68 35 1e 80 00       	push   $0x801e35
  80075e:	e8 41 09 00 00       	call   8010a4 <cprintf>
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
  800804:	68 f8 1d 80 00       	push   $0x801df8
  800809:	e8 96 08 00 00       	call   8010a4 <cprintf>
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
  8008bb:	e8 78 01 00 00       	call   800a38 <open>
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
  800907:	e8 96 11 00 00       	call   801aa2 <ipc_find_env>
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
  800922:	e8 26 11 00 00       	call   801a4d <ipc_send>
	
	return ipc_recv(NULL, dstva, NULL);
  800927:	83 c4 0c             	add    $0xc,%esp
  80092a:	6a 00                	push   $0x0
  80092c:	56                   	push   %esi
  80092d:	6a 00                	push   $0x0
  80092f:	e8 a4 10 00 00       	call   8019d8 <ipc_recv>
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
  800961:	78 2c                	js     80098f <devfile_stat+0x54>
		return r;
	}
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  800963:	83 ec 08             	sub    $0x8,%esp
  800966:	68 00 50 80 00       	push   $0x805000
  80096b:	53                   	push   %ebx
  80096c:	e8 e9 0c 00 00       	call   80165a <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  800971:	a1 80 50 80 00       	mov    0x805080,%eax
  800976:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  80097c:	a1 84 50 80 00       	mov    0x805084,%eax
  800981:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  800987:	83 c4 10             	add    $0x10,%esp
  80098a:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80098f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800992:	c9                   	leave  
  800993:	c3                   	ret    

00800994 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  800994:	55                   	push   %ebp
  800995:	89 e5                	mov    %esp,%ebp
  800997:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  80099a:	8b 45 08             	mov    0x8(%ebp),%eax
  80099d:	8b 40 0c             	mov    0xc(%eax),%eax
  8009a0:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8009a5:	ba 00 00 00 00       	mov    $0x0,%edx
  8009aa:	b8 06 00 00 00       	mov    $0x6,%eax
  8009af:	e8 3c ff ff ff       	call   8008f0 <fsipc>
}
  8009b4:	c9                   	leave  
  8009b5:	c3                   	ret    

008009b6 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  8009b6:	55                   	push   %ebp
  8009b7:	89 e5                	mov    %esp,%ebp
  8009b9:	56                   	push   %esi
  8009ba:	53                   	push   %ebx
  8009bb:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8009be:	8b 45 08             	mov    0x8(%ebp),%eax
  8009c1:	8b 40 0c             	mov    0xc(%eax),%eax
  8009c4:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  8009c9:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8009cf:	ba 00 00 00 00       	mov    $0x0,%edx
  8009d4:	b8 03 00 00 00       	mov    $0x3,%eax
  8009d9:	e8 12 ff ff ff       	call   8008f0 <fsipc>
  8009de:	89 c3                	mov    %eax,%ebx
  8009e0:	85 c0                	test   %eax,%eax
  8009e2:	78 4b                	js     800a2f <devfile_read+0x79>
		return r;
	assert(r <= n);
  8009e4:	39 c6                	cmp    %eax,%esi
  8009e6:	73 16                	jae    8009fe <devfile_read+0x48>
  8009e8:	68 64 1e 80 00       	push   $0x801e64
  8009ed:	68 6b 1e 80 00       	push   $0x801e6b
  8009f2:	6a 7d                	push   $0x7d
  8009f4:	68 80 1e 80 00       	push   $0x801e80
  8009f9:	e8 ce 05 00 00       	call   800fcc <_panic>
	assert(r <= PGSIZE);
  8009fe:	3d 00 10 00 00       	cmp    $0x1000,%eax
  800a03:	7e 16                	jle    800a1b <devfile_read+0x65>
  800a05:	68 8b 1e 80 00       	push   $0x801e8b
  800a0a:	68 6b 1e 80 00       	push   $0x801e6b
  800a0f:	6a 7e                	push   $0x7e
  800a11:	68 80 1e 80 00       	push   $0x801e80
  800a16:	e8 b1 05 00 00       	call   800fcc <_panic>
	memmove(buf, &fsipcbuf, r);
  800a1b:	83 ec 04             	sub    $0x4,%esp
  800a1e:	50                   	push   %eax
  800a1f:	68 00 50 80 00       	push   $0x805000
  800a24:	ff 75 0c             	pushl  0xc(%ebp)
  800a27:	e8 ef 0d 00 00       	call   80181b <memmove>
	return r;
  800a2c:	83 c4 10             	add    $0x10,%esp
}
  800a2f:	89 d8                	mov    %ebx,%eax
  800a31:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800a34:	5b                   	pop    %ebx
  800a35:	5e                   	pop    %esi
  800a36:	c9                   	leave  
  800a37:	c3                   	ret    

00800a38 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  800a38:	55                   	push   %ebp
  800a39:	89 e5                	mov    %esp,%ebp
  800a3b:	56                   	push   %esi
  800a3c:	53                   	push   %ebx
  800a3d:	83 ec 1c             	sub    $0x1c,%esp
  800a40:	8b 75 08             	mov    0x8(%ebp),%esi
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  800a43:	56                   	push   %esi
  800a44:	e8 bf 0b 00 00       	call   801608 <strlen>
  800a49:	83 c4 10             	add    $0x10,%esp
  800a4c:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  800a51:	7f 65                	jg     800ab8 <open+0x80>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800a53:	83 ec 0c             	sub    $0xc,%esp
  800a56:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800a59:	50                   	push   %eax
  800a5a:	e8 e1 f8 ff ff       	call   800340 <fd_alloc>
  800a5f:	89 c3                	mov    %eax,%ebx
  800a61:	83 c4 10             	add    $0x10,%esp
  800a64:	85 c0                	test   %eax,%eax
  800a66:	78 55                	js     800abd <open+0x85>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  800a68:	83 ec 08             	sub    $0x8,%esp
  800a6b:	56                   	push   %esi
  800a6c:	68 00 50 80 00       	push   $0x805000
  800a71:	e8 e4 0b 00 00       	call   80165a <strcpy>
	fsipcbuf.open.req_omode = mode;
  800a76:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a79:	a3 00 54 80 00       	mov    %eax,0x805400



	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  800a7e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800a81:	b8 01 00 00 00       	mov    $0x1,%eax
  800a86:	e8 65 fe ff ff       	call   8008f0 <fsipc>
  800a8b:	89 c3                	mov    %eax,%ebx
  800a8d:	83 c4 10             	add    $0x10,%esp
  800a90:	85 c0                	test   %eax,%eax
  800a92:	79 12                	jns    800aa6 <open+0x6e>
		fd_close(fd, 0);
  800a94:	83 ec 08             	sub    $0x8,%esp
  800a97:	6a 00                	push   $0x0
  800a99:	ff 75 f4             	pushl  -0xc(%ebp)
  800a9c:	e8 ce f9 ff ff       	call   80046f <fd_close>
		return r;
  800aa1:	83 c4 10             	add    $0x10,%esp
  800aa4:	eb 17                	jmp    800abd <open+0x85>
	}

	return fd2num(fd);
  800aa6:	83 ec 0c             	sub    $0xc,%esp
  800aa9:	ff 75 f4             	pushl  -0xc(%ebp)
  800aac:	e8 67 f8 ff ff       	call   800318 <fd2num>
  800ab1:	89 c3                	mov    %eax,%ebx
  800ab3:	83 c4 10             	add    $0x10,%esp
  800ab6:	eb 05                	jmp    800abd <open+0x85>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  800ab8:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  800abd:	89 d8                	mov    %ebx,%eax
  800abf:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800ac2:	5b                   	pop    %ebx
  800ac3:	5e                   	pop    %esi
  800ac4:	c9                   	leave  
  800ac5:	c3                   	ret    
	...

00800ac8 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  800ac8:	55                   	push   %ebp
  800ac9:	89 e5                	mov    %esp,%ebp
  800acb:	56                   	push   %esi
  800acc:	53                   	push   %ebx
  800acd:	8b 75 0c             	mov    0xc(%ebp),%esi
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  800ad0:	83 ec 0c             	sub    $0xc,%esp
  800ad3:	ff 75 08             	pushl  0x8(%ebp)
  800ad6:	e8 4d f8 ff ff       	call   800328 <fd2data>
  800adb:	89 c3                	mov    %eax,%ebx
	strcpy(stat->st_name, "<pipe>");
  800add:	83 c4 08             	add    $0x8,%esp
  800ae0:	68 97 1e 80 00       	push   $0x801e97
  800ae5:	56                   	push   %esi
  800ae6:	e8 6f 0b 00 00       	call   80165a <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  800aeb:	8b 43 04             	mov    0x4(%ebx),%eax
  800aee:	2b 03                	sub    (%ebx),%eax
  800af0:	89 86 80 00 00 00    	mov    %eax,0x80(%esi)
	stat->st_isdir = 0;
  800af6:	c7 86 84 00 00 00 00 	movl   $0x0,0x84(%esi)
  800afd:	00 00 00 
	stat->st_dev = &devpipe;
  800b00:	c7 86 88 00 00 00 20 	movl   $0x803020,0x88(%esi)
  800b07:	30 80 00 
	return 0;
}
  800b0a:	b8 00 00 00 00       	mov    $0x0,%eax
  800b0f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800b12:	5b                   	pop    %ebx
  800b13:	5e                   	pop    %esi
  800b14:	c9                   	leave  
  800b15:	c3                   	ret    

00800b16 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  800b16:	55                   	push   %ebp
  800b17:	89 e5                	mov    %esp,%ebp
  800b19:	53                   	push   %ebx
  800b1a:	83 ec 0c             	sub    $0xc,%esp
  800b1d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  800b20:	53                   	push   %ebx
  800b21:	6a 00                	push   $0x0
  800b23:	e8 fa f6 ff ff       	call   800222 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  800b28:	89 1c 24             	mov    %ebx,(%esp)
  800b2b:	e8 f8 f7 ff ff       	call   800328 <fd2data>
  800b30:	83 c4 08             	add    $0x8,%esp
  800b33:	50                   	push   %eax
  800b34:	6a 00                	push   $0x0
  800b36:	e8 e7 f6 ff ff       	call   800222 <sys_page_unmap>
}
  800b3b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800b3e:	c9                   	leave  
  800b3f:	c3                   	ret    

00800b40 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  800b40:	55                   	push   %ebp
  800b41:	89 e5                	mov    %esp,%ebp
  800b43:	57                   	push   %edi
  800b44:	56                   	push   %esi
  800b45:	53                   	push   %ebx
  800b46:	83 ec 1c             	sub    $0x1c,%esp
  800b49:	89 c7                	mov    %eax,%edi
  800b4b:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  800b4e:	a1 04 40 80 00       	mov    0x804004,%eax
  800b53:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  800b56:	83 ec 0c             	sub    $0xc,%esp
  800b59:	57                   	push   %edi
  800b5a:	e8 a1 0f 00 00       	call   801b00 <pageref>
  800b5f:	89 c6                	mov    %eax,%esi
  800b61:	83 c4 04             	add    $0x4,%esp
  800b64:	ff 75 e4             	pushl  -0x1c(%ebp)
  800b67:	e8 94 0f 00 00       	call   801b00 <pageref>
  800b6c:	83 c4 10             	add    $0x10,%esp
  800b6f:	39 c6                	cmp    %eax,%esi
  800b71:	0f 94 c0             	sete   %al
  800b74:	0f b6 c0             	movzbl %al,%eax
		nn = thisenv->env_runs;
  800b77:	8b 15 04 40 80 00    	mov    0x804004,%edx
  800b7d:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  800b80:	39 cb                	cmp    %ecx,%ebx
  800b82:	75 08                	jne    800b8c <_pipeisclosed+0x4c>
			return ret;
		if (n != nn && ret == 1)
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
	}
}
  800b84:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b87:	5b                   	pop    %ebx
  800b88:	5e                   	pop    %esi
  800b89:	5f                   	pop    %edi
  800b8a:	c9                   	leave  
  800b8b:	c3                   	ret    
		n = thisenv->env_runs;
		ret = pageref(fd) == pageref(p);
		nn = thisenv->env_runs;
		if (n == nn)
			return ret;
		if (n != nn && ret == 1)
  800b8c:	83 f8 01             	cmp    $0x1,%eax
  800b8f:	75 bd                	jne    800b4e <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  800b91:	8b 42 58             	mov    0x58(%edx),%eax
  800b94:	6a 01                	push   $0x1
  800b96:	50                   	push   %eax
  800b97:	53                   	push   %ebx
  800b98:	68 9e 1e 80 00       	push   $0x801e9e
  800b9d:	e8 02 05 00 00       	call   8010a4 <cprintf>
  800ba2:	83 c4 10             	add    $0x10,%esp
  800ba5:	eb a7                	jmp    800b4e <_pipeisclosed+0xe>

00800ba7 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  800ba7:	55                   	push   %ebp
  800ba8:	89 e5                	mov    %esp,%ebp
  800baa:	57                   	push   %edi
  800bab:	56                   	push   %esi
  800bac:	53                   	push   %ebx
  800bad:	83 ec 28             	sub    $0x28,%esp
  800bb0:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  800bb3:	56                   	push   %esi
  800bb4:	e8 6f f7 ff ff       	call   800328 <fd2data>
  800bb9:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800bbb:	83 c4 10             	add    $0x10,%esp
  800bbe:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800bc2:	75 4a                	jne    800c0e <devpipe_write+0x67>
  800bc4:	bf 00 00 00 00       	mov    $0x0,%edi
  800bc9:	eb 56                	jmp    800c21 <devpipe_write+0x7a>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  800bcb:	89 da                	mov    %ebx,%edx
  800bcd:	89 f0                	mov    %esi,%eax
  800bcf:	e8 6c ff ff ff       	call   800b40 <_pipeisclosed>
  800bd4:	85 c0                	test   %eax,%eax
  800bd6:	75 4d                	jne    800c25 <devpipe_write+0x7e>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  800bd8:	e8 d4 f5 ff ff       	call   8001b1 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  800bdd:	8b 43 04             	mov    0x4(%ebx),%eax
  800be0:	8b 13                	mov    (%ebx),%edx
  800be2:	83 c2 20             	add    $0x20,%edx
  800be5:	39 d0                	cmp    %edx,%eax
  800be7:	73 e2                	jae    800bcb <devpipe_write+0x24>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  800be9:	89 c2                	mov    %eax,%edx
  800beb:	81 e2 1f 00 00 80    	and    $0x8000001f,%edx
  800bf1:	79 05                	jns    800bf8 <devpipe_write+0x51>
  800bf3:	4a                   	dec    %edx
  800bf4:	83 ca e0             	or     $0xffffffe0,%edx
  800bf7:	42                   	inc    %edx
  800bf8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bfb:	8a 0c 39             	mov    (%ecx,%edi,1),%cl
  800bfe:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  800c02:	40                   	inc    %eax
  800c03:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800c06:	47                   	inc    %edi
  800c07:	39 7d 10             	cmp    %edi,0x10(%ebp)
  800c0a:	77 07                	ja     800c13 <devpipe_write+0x6c>
  800c0c:	eb 13                	jmp    800c21 <devpipe_write+0x7a>
  800c0e:	bf 00 00 00 00       	mov    $0x0,%edi
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  800c13:	8b 43 04             	mov    0x4(%ebx),%eax
  800c16:	8b 13                	mov    (%ebx),%edx
  800c18:	83 c2 20             	add    $0x20,%edx
  800c1b:	39 d0                	cmp    %edx,%eax
  800c1d:	73 ac                	jae    800bcb <devpipe_write+0x24>
  800c1f:	eb c8                	jmp    800be9 <devpipe_write+0x42>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  800c21:	89 f8                	mov    %edi,%eax
  800c23:	eb 05                	jmp    800c2a <devpipe_write+0x83>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  800c25:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  800c2a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c2d:	5b                   	pop    %ebx
  800c2e:	5e                   	pop    %esi
  800c2f:	5f                   	pop    %edi
  800c30:	c9                   	leave  
  800c31:	c3                   	ret    

00800c32 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  800c32:	55                   	push   %ebp
  800c33:	89 e5                	mov    %esp,%ebp
  800c35:	57                   	push   %edi
  800c36:	56                   	push   %esi
  800c37:	53                   	push   %ebx
  800c38:	83 ec 18             	sub    $0x18,%esp
  800c3b:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  800c3e:	57                   	push   %edi
  800c3f:	e8 e4 f6 ff ff       	call   800328 <fd2data>
  800c44:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800c46:	83 c4 10             	add    $0x10,%esp
  800c49:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800c4d:	75 44                	jne    800c93 <devpipe_read+0x61>
  800c4f:	be 00 00 00 00       	mov    $0x0,%esi
  800c54:	eb 4f                	jmp    800ca5 <devpipe_read+0x73>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
				return i;
  800c56:	89 f0                	mov    %esi,%eax
  800c58:	eb 54                	jmp    800cae <devpipe_read+0x7c>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  800c5a:	89 da                	mov    %ebx,%edx
  800c5c:	89 f8                	mov    %edi,%eax
  800c5e:	e8 dd fe ff ff       	call   800b40 <_pipeisclosed>
  800c63:	85 c0                	test   %eax,%eax
  800c65:	75 42                	jne    800ca9 <devpipe_read+0x77>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  800c67:	e8 45 f5 ff ff       	call   8001b1 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  800c6c:	8b 03                	mov    (%ebx),%eax
  800c6e:	3b 43 04             	cmp    0x4(%ebx),%eax
  800c71:	74 e7                	je     800c5a <devpipe_read+0x28>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  800c73:	25 1f 00 00 80       	and    $0x8000001f,%eax
  800c78:	79 05                	jns    800c7f <devpipe_read+0x4d>
  800c7a:	48                   	dec    %eax
  800c7b:	83 c8 e0             	or     $0xffffffe0,%eax
  800c7e:	40                   	inc    %eax
  800c7f:	8a 44 03 08          	mov    0x8(%ebx,%eax,1),%al
  800c83:	8b 55 0c             	mov    0xc(%ebp),%edx
  800c86:	88 04 32             	mov    %al,(%edx,%esi,1)
		p->p_rpos++;
  800c89:	ff 03                	incl   (%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800c8b:	46                   	inc    %esi
  800c8c:	39 75 10             	cmp    %esi,0x10(%ebp)
  800c8f:	77 07                	ja     800c98 <devpipe_read+0x66>
  800c91:	eb 12                	jmp    800ca5 <devpipe_read+0x73>
  800c93:	be 00 00 00 00       	mov    $0x0,%esi
		while (p->p_rpos == p->p_wpos) {
  800c98:	8b 03                	mov    (%ebx),%eax
  800c9a:	3b 43 04             	cmp    0x4(%ebx),%eax
  800c9d:	75 d4                	jne    800c73 <devpipe_read+0x41>
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  800c9f:	85 f6                	test   %esi,%esi
  800ca1:	75 b3                	jne    800c56 <devpipe_read+0x24>
  800ca3:	eb b5                	jmp    800c5a <devpipe_read+0x28>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  800ca5:	89 f0                	mov    %esi,%eax
  800ca7:	eb 05                	jmp    800cae <devpipe_read+0x7c>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  800ca9:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  800cae:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cb1:	5b                   	pop    %ebx
  800cb2:	5e                   	pop    %esi
  800cb3:	5f                   	pop    %edi
  800cb4:	c9                   	leave  
  800cb5:	c3                   	ret    

00800cb6 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  800cb6:	55                   	push   %ebp
  800cb7:	89 e5                	mov    %esp,%ebp
  800cb9:	57                   	push   %edi
  800cba:	56                   	push   %esi
  800cbb:	53                   	push   %ebx
  800cbc:	83 ec 28             	sub    $0x28,%esp
  800cbf:	8b 7d 08             	mov    0x8(%ebp),%edi
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  800cc2:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800cc5:	50                   	push   %eax
  800cc6:	e8 75 f6 ff ff       	call   800340 <fd_alloc>
  800ccb:	89 c3                	mov    %eax,%ebx
  800ccd:	83 c4 10             	add    $0x10,%esp
  800cd0:	85 c0                	test   %eax,%eax
  800cd2:	0f 88 24 01 00 00    	js     800dfc <pipe+0x146>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800cd8:	83 ec 04             	sub    $0x4,%esp
  800cdb:	68 07 04 00 00       	push   $0x407
  800ce0:	ff 75 e4             	pushl  -0x1c(%ebp)
  800ce3:	6a 00                	push   $0x0
  800ce5:	e8 ee f4 ff ff       	call   8001d8 <sys_page_alloc>
  800cea:	89 c3                	mov    %eax,%ebx
  800cec:	83 c4 10             	add    $0x10,%esp
  800cef:	85 c0                	test   %eax,%eax
  800cf1:	0f 88 05 01 00 00    	js     800dfc <pipe+0x146>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  800cf7:	83 ec 0c             	sub    $0xc,%esp
  800cfa:	8d 45 e0             	lea    -0x20(%ebp),%eax
  800cfd:	50                   	push   %eax
  800cfe:	e8 3d f6 ff ff       	call   800340 <fd_alloc>
  800d03:	89 c3                	mov    %eax,%ebx
  800d05:	83 c4 10             	add    $0x10,%esp
  800d08:	85 c0                	test   %eax,%eax
  800d0a:	0f 88 dc 00 00 00    	js     800dec <pipe+0x136>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800d10:	83 ec 04             	sub    $0x4,%esp
  800d13:	68 07 04 00 00       	push   $0x407
  800d18:	ff 75 e0             	pushl  -0x20(%ebp)
  800d1b:	6a 00                	push   $0x0
  800d1d:	e8 b6 f4 ff ff       	call   8001d8 <sys_page_alloc>
  800d22:	89 c3                	mov    %eax,%ebx
  800d24:	83 c4 10             	add    $0x10,%esp
  800d27:	85 c0                	test   %eax,%eax
  800d29:	0f 88 bd 00 00 00    	js     800dec <pipe+0x136>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  800d2f:	83 ec 0c             	sub    $0xc,%esp
  800d32:	ff 75 e4             	pushl  -0x1c(%ebp)
  800d35:	e8 ee f5 ff ff       	call   800328 <fd2data>
  800d3a:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800d3c:	83 c4 0c             	add    $0xc,%esp
  800d3f:	68 07 04 00 00       	push   $0x407
  800d44:	50                   	push   %eax
  800d45:	6a 00                	push   $0x0
  800d47:	e8 8c f4 ff ff       	call   8001d8 <sys_page_alloc>
  800d4c:	89 c3                	mov    %eax,%ebx
  800d4e:	83 c4 10             	add    $0x10,%esp
  800d51:	85 c0                	test   %eax,%eax
  800d53:	0f 88 83 00 00 00    	js     800ddc <pipe+0x126>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800d59:	83 ec 0c             	sub    $0xc,%esp
  800d5c:	ff 75 e0             	pushl  -0x20(%ebp)
  800d5f:	e8 c4 f5 ff ff       	call   800328 <fd2data>
  800d64:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  800d6b:	50                   	push   %eax
  800d6c:	6a 00                	push   $0x0
  800d6e:	56                   	push   %esi
  800d6f:	6a 00                	push   $0x0
  800d71:	e8 86 f4 ff ff       	call   8001fc <sys_page_map>
  800d76:	89 c3                	mov    %eax,%ebx
  800d78:	83 c4 20             	add    $0x20,%esp
  800d7b:	85 c0                	test   %eax,%eax
  800d7d:	78 4f                	js     800dce <pipe+0x118>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  800d7f:	8b 15 20 30 80 00    	mov    0x803020,%edx
  800d85:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800d88:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  800d8a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800d8d:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  800d94:	8b 15 20 30 80 00    	mov    0x803020,%edx
  800d9a:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800d9d:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  800d9f:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800da2:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  800da9:	83 ec 0c             	sub    $0xc,%esp
  800dac:	ff 75 e4             	pushl  -0x1c(%ebp)
  800daf:	e8 64 f5 ff ff       	call   800318 <fd2num>
  800db4:	89 07                	mov    %eax,(%edi)
	pfd[1] = fd2num(fd1);
  800db6:	83 c4 04             	add    $0x4,%esp
  800db9:	ff 75 e0             	pushl  -0x20(%ebp)
  800dbc:	e8 57 f5 ff ff       	call   800318 <fd2num>
  800dc1:	89 47 04             	mov    %eax,0x4(%edi)
	return 0;
  800dc4:	83 c4 10             	add    $0x10,%esp
  800dc7:	bb 00 00 00 00       	mov    $0x0,%ebx
  800dcc:	eb 2e                	jmp    800dfc <pipe+0x146>

    err3:
	sys_page_unmap(0, va);
  800dce:	83 ec 08             	sub    $0x8,%esp
  800dd1:	56                   	push   %esi
  800dd2:	6a 00                	push   $0x0
  800dd4:	e8 49 f4 ff ff       	call   800222 <sys_page_unmap>
  800dd9:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  800ddc:	83 ec 08             	sub    $0x8,%esp
  800ddf:	ff 75 e0             	pushl  -0x20(%ebp)
  800de2:	6a 00                	push   $0x0
  800de4:	e8 39 f4 ff ff       	call   800222 <sys_page_unmap>
  800de9:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  800dec:	83 ec 08             	sub    $0x8,%esp
  800def:	ff 75 e4             	pushl  -0x1c(%ebp)
  800df2:	6a 00                	push   $0x0
  800df4:	e8 29 f4 ff ff       	call   800222 <sys_page_unmap>
  800df9:	83 c4 10             	add    $0x10,%esp
    err:
	return r;
}
  800dfc:	89 d8                	mov    %ebx,%eax
  800dfe:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e01:	5b                   	pop    %ebx
  800e02:	5e                   	pop    %esi
  800e03:	5f                   	pop    %edi
  800e04:	c9                   	leave  
  800e05:	c3                   	ret    

00800e06 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  800e06:	55                   	push   %ebp
  800e07:	89 e5                	mov    %esp,%ebp
  800e09:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800e0c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800e0f:	50                   	push   %eax
  800e10:	ff 75 08             	pushl  0x8(%ebp)
  800e13:	e8 9b f5 ff ff       	call   8003b3 <fd_lookup>
  800e18:	83 c4 10             	add    $0x10,%esp
  800e1b:	85 c0                	test   %eax,%eax
  800e1d:	78 18                	js     800e37 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  800e1f:	83 ec 0c             	sub    $0xc,%esp
  800e22:	ff 75 f4             	pushl  -0xc(%ebp)
  800e25:	e8 fe f4 ff ff       	call   800328 <fd2data>
	return _pipeisclosed(fd, p);
  800e2a:	89 c2                	mov    %eax,%edx
  800e2c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800e2f:	e8 0c fd ff ff       	call   800b40 <_pipeisclosed>
  800e34:	83 c4 10             	add    $0x10,%esp
}
  800e37:	c9                   	leave  
  800e38:	c3                   	ret    
  800e39:	00 00                	add    %al,(%eax)
	...

00800e3c <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  800e3c:	55                   	push   %ebp
  800e3d:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  800e3f:	b8 00 00 00 00       	mov    $0x0,%eax
  800e44:	c9                   	leave  
  800e45:	c3                   	ret    

00800e46 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  800e46:	55                   	push   %ebp
  800e47:	89 e5                	mov    %esp,%ebp
  800e49:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  800e4c:	68 b6 1e 80 00       	push   $0x801eb6
  800e51:	ff 75 0c             	pushl  0xc(%ebp)
  800e54:	e8 01 08 00 00       	call   80165a <strcpy>
	return 0;
}
  800e59:	b8 00 00 00 00       	mov    $0x0,%eax
  800e5e:	c9                   	leave  
  800e5f:	c3                   	ret    

00800e60 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  800e60:	55                   	push   %ebp
  800e61:	89 e5                	mov    %esp,%ebp
  800e63:	57                   	push   %edi
  800e64:	56                   	push   %esi
  800e65:	53                   	push   %ebx
  800e66:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800e6c:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800e70:	74 45                	je     800eb7 <devcons_write+0x57>
  800e72:	b8 00 00 00 00       	mov    $0x0,%eax
  800e77:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  800e7c:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  800e82:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e85:	29 c3                	sub    %eax,%ebx
		if (m > sizeof(buf) - 1)
  800e87:	83 fb 7f             	cmp    $0x7f,%ebx
  800e8a:	76 05                	jbe    800e91 <devcons_write+0x31>
			m = sizeof(buf) - 1;
  800e8c:	bb 7f 00 00 00       	mov    $0x7f,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  800e91:	83 ec 04             	sub    $0x4,%esp
  800e94:	53                   	push   %ebx
  800e95:	03 45 0c             	add    0xc(%ebp),%eax
  800e98:	50                   	push   %eax
  800e99:	57                   	push   %edi
  800e9a:	e8 7c 09 00 00       	call   80181b <memmove>
		sys_cputs(buf, m);
  800e9f:	83 c4 08             	add    $0x8,%esp
  800ea2:	53                   	push   %ebx
  800ea3:	57                   	push   %edi
  800ea4:	e8 78 f2 ff ff       	call   800121 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800ea9:	01 de                	add    %ebx,%esi
  800eab:	89 f0                	mov    %esi,%eax
  800ead:	83 c4 10             	add    $0x10,%esp
  800eb0:	3b 75 10             	cmp    0x10(%ebp),%esi
  800eb3:	72 cd                	jb     800e82 <devcons_write+0x22>
  800eb5:	eb 05                	jmp    800ebc <devcons_write+0x5c>
  800eb7:	be 00 00 00 00       	mov    $0x0,%esi
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  800ebc:	89 f0                	mov    %esi,%eax
  800ebe:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ec1:	5b                   	pop    %ebx
  800ec2:	5e                   	pop    %esi
  800ec3:	5f                   	pop    %edi
  800ec4:	c9                   	leave  
  800ec5:	c3                   	ret    

00800ec6 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  800ec6:	55                   	push   %ebp
  800ec7:	89 e5                	mov    %esp,%ebp
  800ec9:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
  800ecc:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800ed0:	75 07                	jne    800ed9 <devcons_read+0x13>
  800ed2:	eb 25                	jmp    800ef9 <devcons_read+0x33>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  800ed4:	e8 d8 f2 ff ff       	call   8001b1 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  800ed9:	e8 69 f2 ff ff       	call   800147 <sys_cgetc>
  800ede:	85 c0                	test   %eax,%eax
  800ee0:	74 f2                	je     800ed4 <devcons_read+0xe>
  800ee2:	89 c2                	mov    %eax,%edx
		sys_yield();
	if (c < 0)
  800ee4:	85 c0                	test   %eax,%eax
  800ee6:	78 1d                	js     800f05 <devcons_read+0x3f>
		return c;
	if (c == 0x04)	// ctl-d is eof
  800ee8:	83 f8 04             	cmp    $0x4,%eax
  800eeb:	74 13                	je     800f00 <devcons_read+0x3a>
		return 0;
	*(char*)vbuf = c;
  800eed:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ef0:	88 10                	mov    %dl,(%eax)
	return 1;
  800ef2:	b8 01 00 00 00       	mov    $0x1,%eax
  800ef7:	eb 0c                	jmp    800f05 <devcons_read+0x3f>
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
		return 0;
  800ef9:	b8 00 00 00 00       	mov    $0x0,%eax
  800efe:	eb 05                	jmp    800f05 <devcons_read+0x3f>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  800f00:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  800f05:	c9                   	leave  
  800f06:	c3                   	ret    

00800f07 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  800f07:	55                   	push   %ebp
  800f08:	89 e5                	mov    %esp,%ebp
  800f0a:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  800f0d:	8b 45 08             	mov    0x8(%ebp),%eax
  800f10:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  800f13:	6a 01                	push   $0x1
  800f15:	8d 45 f7             	lea    -0x9(%ebp),%eax
  800f18:	50                   	push   %eax
  800f19:	e8 03 f2 ff ff       	call   800121 <sys_cputs>
  800f1e:	83 c4 10             	add    $0x10,%esp
}
  800f21:	c9                   	leave  
  800f22:	c3                   	ret    

00800f23 <getchar>:

int
getchar(void)
{
  800f23:	55                   	push   %ebp
  800f24:	89 e5                	mov    %esp,%ebp
  800f26:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  800f29:	6a 01                	push   $0x1
  800f2b:	8d 45 f7             	lea    -0x9(%ebp),%eax
  800f2e:	50                   	push   %eax
  800f2f:	6a 00                	push   $0x0
  800f31:	e8 fe f6 ff ff       	call   800634 <read>
	if (r < 0)
  800f36:	83 c4 10             	add    $0x10,%esp
  800f39:	85 c0                	test   %eax,%eax
  800f3b:	78 0f                	js     800f4c <getchar+0x29>
		return r;
	if (r < 1)
  800f3d:	85 c0                	test   %eax,%eax
  800f3f:	7e 06                	jle    800f47 <getchar+0x24>
		return -E_EOF;
	return c;
  800f41:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  800f45:	eb 05                	jmp    800f4c <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  800f47:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  800f4c:	c9                   	leave  
  800f4d:	c3                   	ret    

00800f4e <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  800f4e:	55                   	push   %ebp
  800f4f:	89 e5                	mov    %esp,%ebp
  800f51:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800f54:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800f57:	50                   	push   %eax
  800f58:	ff 75 08             	pushl  0x8(%ebp)
  800f5b:	e8 53 f4 ff ff       	call   8003b3 <fd_lookup>
  800f60:	83 c4 10             	add    $0x10,%esp
  800f63:	85 c0                	test   %eax,%eax
  800f65:	78 11                	js     800f78 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  800f67:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800f6a:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  800f70:	39 10                	cmp    %edx,(%eax)
  800f72:	0f 94 c0             	sete   %al
  800f75:	0f b6 c0             	movzbl %al,%eax
}
  800f78:	c9                   	leave  
  800f79:	c3                   	ret    

00800f7a <opencons>:

int
opencons(void)
{
  800f7a:	55                   	push   %ebp
  800f7b:	89 e5                	mov    %esp,%ebp
  800f7d:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  800f80:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800f83:	50                   	push   %eax
  800f84:	e8 b7 f3 ff ff       	call   800340 <fd_alloc>
  800f89:	83 c4 10             	add    $0x10,%esp
  800f8c:	85 c0                	test   %eax,%eax
  800f8e:	78 3a                	js     800fca <opencons+0x50>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  800f90:	83 ec 04             	sub    $0x4,%esp
  800f93:	68 07 04 00 00       	push   $0x407
  800f98:	ff 75 f4             	pushl  -0xc(%ebp)
  800f9b:	6a 00                	push   $0x0
  800f9d:	e8 36 f2 ff ff       	call   8001d8 <sys_page_alloc>
  800fa2:	83 c4 10             	add    $0x10,%esp
  800fa5:	85 c0                	test   %eax,%eax
  800fa7:	78 21                	js     800fca <opencons+0x50>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  800fa9:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  800faf:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800fb2:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  800fb4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800fb7:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  800fbe:	83 ec 0c             	sub    $0xc,%esp
  800fc1:	50                   	push   %eax
  800fc2:	e8 51 f3 ff ff       	call   800318 <fd2num>
  800fc7:	83 c4 10             	add    $0x10,%esp
}
  800fca:	c9                   	leave  
  800fcb:	c3                   	ret    

00800fcc <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800fcc:	55                   	push   %ebp
  800fcd:	89 e5                	mov    %esp,%ebp
  800fcf:	56                   	push   %esi
  800fd0:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800fd1:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800fd4:	8b 1d 00 30 80 00    	mov    0x803000,%ebx
  800fda:	e8 ae f1 ff ff       	call   80018d <sys_getenvid>
  800fdf:	83 ec 0c             	sub    $0xc,%esp
  800fe2:	ff 75 0c             	pushl  0xc(%ebp)
  800fe5:	ff 75 08             	pushl  0x8(%ebp)
  800fe8:	53                   	push   %ebx
  800fe9:	50                   	push   %eax
  800fea:	68 c4 1e 80 00       	push   $0x801ec4
  800fef:	e8 b0 00 00 00       	call   8010a4 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800ff4:	83 c4 18             	add    $0x18,%esp
  800ff7:	56                   	push   %esi
  800ff8:	ff 75 10             	pushl  0x10(%ebp)
  800ffb:	e8 53 00 00 00       	call   801053 <vcprintf>
	cprintf("\n");
  801000:	c7 04 24 af 1e 80 00 	movl   $0x801eaf,(%esp)
  801007:	e8 98 00 00 00       	call   8010a4 <cprintf>
  80100c:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80100f:	cc                   	int3   
  801010:	eb fd                	jmp    80100f <_panic+0x43>
	...

00801014 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  801014:	55                   	push   %ebp
  801015:	89 e5                	mov    %esp,%ebp
  801017:	53                   	push   %ebx
  801018:	83 ec 04             	sub    $0x4,%esp
  80101b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80101e:	8b 03                	mov    (%ebx),%eax
  801020:	8b 55 08             	mov    0x8(%ebp),%edx
  801023:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  801027:	40                   	inc    %eax
  801028:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  80102a:	3d ff 00 00 00       	cmp    $0xff,%eax
  80102f:	75 1a                	jne    80104b <putch+0x37>
		sys_cputs(b->buf, b->idx);
  801031:	83 ec 08             	sub    $0x8,%esp
  801034:	68 ff 00 00 00       	push   $0xff
  801039:	8d 43 08             	lea    0x8(%ebx),%eax
  80103c:	50                   	push   %eax
  80103d:	e8 df f0 ff ff       	call   800121 <sys_cputs>
		b->idx = 0;
  801042:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801048:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  80104b:	ff 43 04             	incl   0x4(%ebx)
}
  80104e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801051:	c9                   	leave  
  801052:	c3                   	ret    

00801053 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  801053:	55                   	push   %ebp
  801054:	89 e5                	mov    %esp,%ebp
  801056:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  80105c:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  801063:	00 00 00 
	b.cnt = 0;
  801066:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80106d:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  801070:	ff 75 0c             	pushl  0xc(%ebp)
  801073:	ff 75 08             	pushl  0x8(%ebp)
  801076:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80107c:	50                   	push   %eax
  80107d:	68 14 10 80 00       	push   $0x801014
  801082:	e8 82 01 00 00       	call   801209 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  801087:	83 c4 08             	add    $0x8,%esp
  80108a:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  801090:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  801096:	50                   	push   %eax
  801097:	e8 85 f0 ff ff       	call   800121 <sys_cputs>

	return b.cnt;
}
  80109c:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8010a2:	c9                   	leave  
  8010a3:	c3                   	ret    

008010a4 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8010a4:	55                   	push   %ebp
  8010a5:	89 e5                	mov    %esp,%ebp
  8010a7:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8010aa:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8010ad:	50                   	push   %eax
  8010ae:	ff 75 08             	pushl  0x8(%ebp)
  8010b1:	e8 9d ff ff ff       	call   801053 <vcprintf>
	va_end(ap);

	return cnt;
}
  8010b6:	c9                   	leave  
  8010b7:	c3                   	ret    

008010b8 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8010b8:	55                   	push   %ebp
  8010b9:	89 e5                	mov    %esp,%ebp
  8010bb:	57                   	push   %edi
  8010bc:	56                   	push   %esi
  8010bd:	53                   	push   %ebx
  8010be:	83 ec 2c             	sub    $0x2c,%esp
  8010c1:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8010c4:	89 d6                	mov    %edx,%esi
  8010c6:	8b 45 08             	mov    0x8(%ebp),%eax
  8010c9:	8b 55 0c             	mov    0xc(%ebp),%edx
  8010cc:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8010cf:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8010d2:	8b 45 10             	mov    0x10(%ebp),%eax
  8010d5:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8010d8:	8b 7d 18             	mov    0x18(%ebp),%edi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8010db:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8010de:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  8010e5:	39 55 d4             	cmp    %edx,-0x2c(%ebp)
  8010e8:	72 0c                	jb     8010f6 <printnum+0x3e>
  8010ea:	3b 45 d8             	cmp    -0x28(%ebp),%eax
  8010ed:	76 07                	jbe    8010f6 <printnum+0x3e>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8010ef:	4b                   	dec    %ebx
  8010f0:	85 db                	test   %ebx,%ebx
  8010f2:	7f 31                	jg     801125 <printnum+0x6d>
  8010f4:	eb 3f                	jmp    801135 <printnum+0x7d>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8010f6:	83 ec 0c             	sub    $0xc,%esp
  8010f9:	57                   	push   %edi
  8010fa:	4b                   	dec    %ebx
  8010fb:	53                   	push   %ebx
  8010fc:	50                   	push   %eax
  8010fd:	83 ec 08             	sub    $0x8,%esp
  801100:	ff 75 d4             	pushl  -0x2c(%ebp)
  801103:	ff 75 d0             	pushl  -0x30(%ebp)
  801106:	ff 75 dc             	pushl  -0x24(%ebp)
  801109:	ff 75 d8             	pushl  -0x28(%ebp)
  80110c:	e8 33 0a 00 00       	call   801b44 <__udivdi3>
  801111:	83 c4 18             	add    $0x18,%esp
  801114:	52                   	push   %edx
  801115:	50                   	push   %eax
  801116:	89 f2                	mov    %esi,%edx
  801118:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80111b:	e8 98 ff ff ff       	call   8010b8 <printnum>
  801120:	83 c4 20             	add    $0x20,%esp
  801123:	eb 10                	jmp    801135 <printnum+0x7d>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  801125:	83 ec 08             	sub    $0x8,%esp
  801128:	56                   	push   %esi
  801129:	57                   	push   %edi
  80112a:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80112d:	4b                   	dec    %ebx
  80112e:	83 c4 10             	add    $0x10,%esp
  801131:	85 db                	test   %ebx,%ebx
  801133:	7f f0                	jg     801125 <printnum+0x6d>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  801135:	83 ec 08             	sub    $0x8,%esp
  801138:	56                   	push   %esi
  801139:	83 ec 04             	sub    $0x4,%esp
  80113c:	ff 75 d4             	pushl  -0x2c(%ebp)
  80113f:	ff 75 d0             	pushl  -0x30(%ebp)
  801142:	ff 75 dc             	pushl  -0x24(%ebp)
  801145:	ff 75 d8             	pushl  -0x28(%ebp)
  801148:	e8 13 0b 00 00       	call   801c60 <__umoddi3>
  80114d:	83 c4 14             	add    $0x14,%esp
  801150:	0f be 80 e7 1e 80 00 	movsbl 0x801ee7(%eax),%eax
  801157:	50                   	push   %eax
  801158:	ff 55 e4             	call   *-0x1c(%ebp)
  80115b:	83 c4 10             	add    $0x10,%esp
}
  80115e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801161:	5b                   	pop    %ebx
  801162:	5e                   	pop    %esi
  801163:	5f                   	pop    %edi
  801164:	c9                   	leave  
  801165:	c3                   	ret    

00801166 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  801166:	55                   	push   %ebp
  801167:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  801169:	83 fa 01             	cmp    $0x1,%edx
  80116c:	7e 0e                	jle    80117c <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80116e:	8b 10                	mov    (%eax),%edx
  801170:	8d 4a 08             	lea    0x8(%edx),%ecx
  801173:	89 08                	mov    %ecx,(%eax)
  801175:	8b 02                	mov    (%edx),%eax
  801177:	8b 52 04             	mov    0x4(%edx),%edx
  80117a:	eb 22                	jmp    80119e <getuint+0x38>
	else if (lflag)
  80117c:	85 d2                	test   %edx,%edx
  80117e:	74 10                	je     801190 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  801180:	8b 10                	mov    (%eax),%edx
  801182:	8d 4a 04             	lea    0x4(%edx),%ecx
  801185:	89 08                	mov    %ecx,(%eax)
  801187:	8b 02                	mov    (%edx),%eax
  801189:	ba 00 00 00 00       	mov    $0x0,%edx
  80118e:	eb 0e                	jmp    80119e <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  801190:	8b 10                	mov    (%eax),%edx
  801192:	8d 4a 04             	lea    0x4(%edx),%ecx
  801195:	89 08                	mov    %ecx,(%eax)
  801197:	8b 02                	mov    (%edx),%eax
  801199:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80119e:	c9                   	leave  
  80119f:	c3                   	ret    

008011a0 <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
  8011a0:	55                   	push   %ebp
  8011a1:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8011a3:	83 fa 01             	cmp    $0x1,%edx
  8011a6:	7e 0e                	jle    8011b6 <getint+0x16>
		return va_arg(*ap, long long);
  8011a8:	8b 10                	mov    (%eax),%edx
  8011aa:	8d 4a 08             	lea    0x8(%edx),%ecx
  8011ad:	89 08                	mov    %ecx,(%eax)
  8011af:	8b 02                	mov    (%edx),%eax
  8011b1:	8b 52 04             	mov    0x4(%edx),%edx
  8011b4:	eb 1a                	jmp    8011d0 <getint+0x30>
	else if (lflag)
  8011b6:	85 d2                	test   %edx,%edx
  8011b8:	74 0c                	je     8011c6 <getint+0x26>
		return va_arg(*ap, long);
  8011ba:	8b 10                	mov    (%eax),%edx
  8011bc:	8d 4a 04             	lea    0x4(%edx),%ecx
  8011bf:	89 08                	mov    %ecx,(%eax)
  8011c1:	8b 02                	mov    (%edx),%eax
  8011c3:	99                   	cltd   
  8011c4:	eb 0a                	jmp    8011d0 <getint+0x30>
	else
		return va_arg(*ap, int);
  8011c6:	8b 10                	mov    (%eax),%edx
  8011c8:	8d 4a 04             	lea    0x4(%edx),%ecx
  8011cb:	89 08                	mov    %ecx,(%eax)
  8011cd:	8b 02                	mov    (%edx),%eax
  8011cf:	99                   	cltd   
}
  8011d0:	c9                   	leave  
  8011d1:	c3                   	ret    

008011d2 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8011d2:	55                   	push   %ebp
  8011d3:	89 e5                	mov    %esp,%ebp
  8011d5:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8011d8:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  8011db:	8b 10                	mov    (%eax),%edx
  8011dd:	3b 50 04             	cmp    0x4(%eax),%edx
  8011e0:	73 08                	jae    8011ea <sprintputch+0x18>
		*b->buf++ = ch;
  8011e2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8011e5:	88 0a                	mov    %cl,(%edx)
  8011e7:	42                   	inc    %edx
  8011e8:	89 10                	mov    %edx,(%eax)
}
  8011ea:	c9                   	leave  
  8011eb:	c3                   	ret    

008011ec <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8011ec:	55                   	push   %ebp
  8011ed:	89 e5                	mov    %esp,%ebp
  8011ef:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8011f2:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8011f5:	50                   	push   %eax
  8011f6:	ff 75 10             	pushl  0x10(%ebp)
  8011f9:	ff 75 0c             	pushl  0xc(%ebp)
  8011fc:	ff 75 08             	pushl  0x8(%ebp)
  8011ff:	e8 05 00 00 00       	call   801209 <vprintfmt>
	va_end(ap);
  801204:	83 c4 10             	add    $0x10,%esp
}
  801207:	c9                   	leave  
  801208:	c3                   	ret    

00801209 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  801209:	55                   	push   %ebp
  80120a:	89 e5                	mov    %esp,%ebp
  80120c:	57                   	push   %edi
  80120d:	56                   	push   %esi
  80120e:	53                   	push   %ebx
  80120f:	83 ec 2c             	sub    $0x2c,%esp
  801212:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801215:	8b 75 10             	mov    0x10(%ebp),%esi
  801218:	eb 13                	jmp    80122d <vprintfmt+0x24>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  80121a:	85 c0                	test   %eax,%eax
  80121c:	0f 84 6d 03 00 00    	je     80158f <vprintfmt+0x386>
				return;
			putch(ch, putdat);
  801222:	83 ec 08             	sub    $0x8,%esp
  801225:	57                   	push   %edi
  801226:	50                   	push   %eax
  801227:	ff 55 08             	call   *0x8(%ebp)
  80122a:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80122d:	0f b6 06             	movzbl (%esi),%eax
  801230:	46                   	inc    %esi
  801231:	83 f8 25             	cmp    $0x25,%eax
  801234:	75 e4                	jne    80121a <vprintfmt+0x11>
  801236:	c6 45 dc 20          	movb   $0x20,-0x24(%ebp)
  80123a:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  801241:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
  801248:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  80124f:	b9 00 00 00 00       	mov    $0x0,%ecx
  801254:	eb 28                	jmp    80127e <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801256:	89 de                	mov    %ebx,%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  801258:	c6 45 dc 2d          	movb   $0x2d,-0x24(%ebp)
  80125c:	eb 20                	jmp    80127e <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80125e:	89 de                	mov    %ebx,%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  801260:	c6 45 dc 30          	movb   $0x30,-0x24(%ebp)
  801264:	eb 18                	jmp    80127e <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801266:	89 de                	mov    %ebx,%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  801268:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  80126f:	eb 0d                	jmp    80127e <vprintfmt+0x75>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  801271:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  801274:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801277:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80127e:	8a 06                	mov    (%esi),%al
  801280:	0f b6 d0             	movzbl %al,%edx
  801283:	8d 5e 01             	lea    0x1(%esi),%ebx
  801286:	83 e8 23             	sub    $0x23,%eax
  801289:	3c 55                	cmp    $0x55,%al
  80128b:	0f 87 e0 02 00 00    	ja     801571 <vprintfmt+0x368>
  801291:	0f b6 c0             	movzbl %al,%eax
  801294:	ff 24 85 20 20 80 00 	jmp    *0x802020(,%eax,4)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80129b:	83 ea 30             	sub    $0x30,%edx
  80129e:	89 55 d4             	mov    %edx,-0x2c(%ebp)
				ch = *fmt;
  8012a1:	0f be 03             	movsbl (%ebx),%eax
				if (ch < '0' || ch > '9')
  8012a4:	8d 50 d0             	lea    -0x30(%eax),%edx
  8012a7:	83 fa 09             	cmp    $0x9,%edx
  8012aa:	77 44                	ja     8012f0 <vprintfmt+0xe7>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8012ac:	89 de                	mov    %ebx,%esi
  8012ae:	8b 55 d4             	mov    -0x2c(%ebp),%edx
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8012b1:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
  8012b2:	8d 14 92             	lea    (%edx,%edx,4),%edx
  8012b5:	8d 54 50 d0          	lea    -0x30(%eax,%edx,2),%edx
				ch = *fmt;
  8012b9:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  8012bc:	8d 58 d0             	lea    -0x30(%eax),%ebx
  8012bf:	83 fb 09             	cmp    $0x9,%ebx
  8012c2:	76 ed                	jbe    8012b1 <vprintfmt+0xa8>
  8012c4:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  8012c7:	eb 29                	jmp    8012f2 <vprintfmt+0xe9>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8012c9:	8b 45 14             	mov    0x14(%ebp),%eax
  8012cc:	8d 50 04             	lea    0x4(%eax),%edx
  8012cf:	89 55 14             	mov    %edx,0x14(%ebp)
  8012d2:	8b 00                	mov    (%eax),%eax
  8012d4:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8012d7:	89 de                	mov    %ebx,%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8012d9:	eb 17                	jmp    8012f2 <vprintfmt+0xe9>

		case '.':
			if (width < 0)
  8012db:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8012df:	78 85                	js     801266 <vprintfmt+0x5d>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8012e1:	89 de                	mov    %ebx,%esi
  8012e3:	eb 99                	jmp    80127e <vprintfmt+0x75>
  8012e5:	89 de                	mov    %ebx,%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8012e7:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
			goto reswitch;
  8012ee:	eb 8e                	jmp    80127e <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8012f0:	89 de                	mov    %ebx,%esi
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  8012f2:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8012f6:	79 86                	jns    80127e <vprintfmt+0x75>
  8012f8:	e9 74 ff ff ff       	jmp    801271 <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8012fd:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8012fe:	89 de                	mov    %ebx,%esi
  801300:	e9 79 ff ff ff       	jmp    80127e <vprintfmt+0x75>
  801305:	89 5d d8             	mov    %ebx,-0x28(%ebp)
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  801308:	8b 45 14             	mov    0x14(%ebp),%eax
  80130b:	8d 50 04             	lea    0x4(%eax),%edx
  80130e:	89 55 14             	mov    %edx,0x14(%ebp)
  801311:	83 ec 08             	sub    $0x8,%esp
  801314:	57                   	push   %edi
  801315:	ff 30                	pushl  (%eax)
  801317:	ff 55 08             	call   *0x8(%ebp)
			break;
  80131a:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80131d:	8b 75 d8             	mov    -0x28(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  801320:	e9 08 ff ff ff       	jmp    80122d <vprintfmt+0x24>
  801325:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// error message
		case 'e':
			err = va_arg(ap, int);
  801328:	8b 45 14             	mov    0x14(%ebp),%eax
  80132b:	8d 50 04             	lea    0x4(%eax),%edx
  80132e:	89 55 14             	mov    %edx,0x14(%ebp)
  801331:	8b 00                	mov    (%eax),%eax
  801333:	85 c0                	test   %eax,%eax
  801335:	79 02                	jns    801339 <vprintfmt+0x130>
  801337:	f7 d8                	neg    %eax
  801339:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80133b:	83 f8 0f             	cmp    $0xf,%eax
  80133e:	7f 0b                	jg     80134b <vprintfmt+0x142>
  801340:	8b 04 85 80 21 80 00 	mov    0x802180(,%eax,4),%eax
  801347:	85 c0                	test   %eax,%eax
  801349:	75 1a                	jne    801365 <vprintfmt+0x15c>
				printfmt(putch, putdat, "error %d", err);
  80134b:	52                   	push   %edx
  80134c:	68 ff 1e 80 00       	push   $0x801eff
  801351:	57                   	push   %edi
  801352:	ff 75 08             	pushl  0x8(%ebp)
  801355:	e8 92 fe ff ff       	call   8011ec <printfmt>
  80135a:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80135d:	8b 75 d8             	mov    -0x28(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  801360:	e9 c8 fe ff ff       	jmp    80122d <vprintfmt+0x24>
			else
				printfmt(putch, putdat, "%s", p);
  801365:	50                   	push   %eax
  801366:	68 7d 1e 80 00       	push   $0x801e7d
  80136b:	57                   	push   %edi
  80136c:	ff 75 08             	pushl  0x8(%ebp)
  80136f:	e8 78 fe ff ff       	call   8011ec <printfmt>
  801374:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801377:	8b 75 d8             	mov    -0x28(%ebp),%esi
  80137a:	e9 ae fe ff ff       	jmp    80122d <vprintfmt+0x24>
  80137f:	89 5d d8             	mov    %ebx,-0x28(%ebp)
  801382:	89 de                	mov    %ebx,%esi
  801384:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  801387:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80138a:	8b 45 14             	mov    0x14(%ebp),%eax
  80138d:	8d 50 04             	lea    0x4(%eax),%edx
  801390:	89 55 14             	mov    %edx,0x14(%ebp)
  801393:	8b 00                	mov    (%eax),%eax
  801395:	89 45 d0             	mov    %eax,-0x30(%ebp)
  801398:	85 c0                	test   %eax,%eax
  80139a:	75 07                	jne    8013a3 <vprintfmt+0x19a>
				p = "(null)";
  80139c:	c7 45 d0 f8 1e 80 00 	movl   $0x801ef8,-0x30(%ebp)
			if (width > 0 && padc != '-')
  8013a3:	85 db                	test   %ebx,%ebx
  8013a5:	7e 42                	jle    8013e9 <vprintfmt+0x1e0>
  8013a7:	80 7d dc 2d          	cmpb   $0x2d,-0x24(%ebp)
  8013ab:	74 3c                	je     8013e9 <vprintfmt+0x1e0>
				for (width -= strnlen(p, precision); width > 0; width--)
  8013ad:	83 ec 08             	sub    $0x8,%esp
  8013b0:	51                   	push   %ecx
  8013b1:	ff 75 d0             	pushl  -0x30(%ebp)
  8013b4:	e8 6f 02 00 00       	call   801628 <strnlen>
  8013b9:	29 c3                	sub    %eax,%ebx
  8013bb:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8013be:	83 c4 10             	add    $0x10,%esp
  8013c1:	85 db                	test   %ebx,%ebx
  8013c3:	7e 24                	jle    8013e9 <vprintfmt+0x1e0>
					putch(padc, putdat);
  8013c5:	0f be 5d dc          	movsbl -0x24(%ebp),%ebx
  8013c9:	89 75 dc             	mov    %esi,-0x24(%ebp)
  8013cc:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  8013cf:	83 ec 08             	sub    $0x8,%esp
  8013d2:	57                   	push   %edi
  8013d3:	53                   	push   %ebx
  8013d4:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8013d7:	4e                   	dec    %esi
  8013d8:	83 c4 10             	add    $0x10,%esp
  8013db:	85 f6                	test   %esi,%esi
  8013dd:	7f f0                	jg     8013cf <vprintfmt+0x1c6>
  8013df:	8b 75 dc             	mov    -0x24(%ebp),%esi
  8013e2:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8013e9:	8b 55 d0             	mov    -0x30(%ebp),%edx
  8013ec:	0f be 02             	movsbl (%edx),%eax
  8013ef:	85 c0                	test   %eax,%eax
  8013f1:	75 47                	jne    80143a <vprintfmt+0x231>
  8013f3:	eb 37                	jmp    80142c <vprintfmt+0x223>
				if (altflag && (ch < ' ' || ch > '~'))
  8013f5:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8013f9:	74 16                	je     801411 <vprintfmt+0x208>
  8013fb:	8d 50 e0             	lea    -0x20(%eax),%edx
  8013fe:	83 fa 5e             	cmp    $0x5e,%edx
  801401:	76 0e                	jbe    801411 <vprintfmt+0x208>
					putch('?', putdat);
  801403:	83 ec 08             	sub    $0x8,%esp
  801406:	57                   	push   %edi
  801407:	6a 3f                	push   $0x3f
  801409:	ff 55 08             	call   *0x8(%ebp)
  80140c:	83 c4 10             	add    $0x10,%esp
  80140f:	eb 0b                	jmp    80141c <vprintfmt+0x213>
				else
					putch(ch, putdat);
  801411:	83 ec 08             	sub    $0x8,%esp
  801414:	57                   	push   %edi
  801415:	50                   	push   %eax
  801416:	ff 55 08             	call   *0x8(%ebp)
  801419:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80141c:	ff 4d e4             	decl   -0x1c(%ebp)
  80141f:	0f be 03             	movsbl (%ebx),%eax
  801422:	85 c0                	test   %eax,%eax
  801424:	74 03                	je     801429 <vprintfmt+0x220>
  801426:	43                   	inc    %ebx
  801427:	eb 1b                	jmp    801444 <vprintfmt+0x23b>
  801429:	8b 75 dc             	mov    -0x24(%ebp),%esi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80142c:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  801430:	7f 1e                	jg     801450 <vprintfmt+0x247>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801432:	8b 75 d8             	mov    -0x28(%ebp),%esi
  801435:	e9 f3 fd ff ff       	jmp    80122d <vprintfmt+0x24>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80143a:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  80143d:	43                   	inc    %ebx
  80143e:	89 75 dc             	mov    %esi,-0x24(%ebp)
  801441:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  801444:	85 f6                	test   %esi,%esi
  801446:	78 ad                	js     8013f5 <vprintfmt+0x1ec>
  801448:	4e                   	dec    %esi
  801449:	79 aa                	jns    8013f5 <vprintfmt+0x1ec>
  80144b:	8b 75 dc             	mov    -0x24(%ebp),%esi
  80144e:	eb dc                	jmp    80142c <vprintfmt+0x223>
  801450:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  801453:	83 ec 08             	sub    $0x8,%esp
  801456:	57                   	push   %edi
  801457:	6a 20                	push   $0x20
  801459:	ff 55 08             	call   *0x8(%ebp)
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80145c:	4b                   	dec    %ebx
  80145d:	83 c4 10             	add    $0x10,%esp
  801460:	85 db                	test   %ebx,%ebx
  801462:	7f ef                	jg     801453 <vprintfmt+0x24a>
  801464:	e9 c4 fd ff ff       	jmp    80122d <vprintfmt+0x24>
  801469:	89 5d d8             	mov    %ebx,-0x28(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80146c:	89 ca                	mov    %ecx,%edx
  80146e:	8d 45 14             	lea    0x14(%ebp),%eax
  801471:	e8 2a fd ff ff       	call   8011a0 <getint>
  801476:	89 c3                	mov    %eax,%ebx
  801478:	89 d6                	mov    %edx,%esi
			if ((long long) num < 0) {
  80147a:	85 d2                	test   %edx,%edx
  80147c:	78 0a                	js     801488 <vprintfmt+0x27f>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  80147e:	b8 0a 00 00 00       	mov    $0xa,%eax
  801483:	e9 b0 00 00 00       	jmp    801538 <vprintfmt+0x32f>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  801488:	83 ec 08             	sub    $0x8,%esp
  80148b:	57                   	push   %edi
  80148c:	6a 2d                	push   $0x2d
  80148e:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  801491:	f7 db                	neg    %ebx
  801493:	83 d6 00             	adc    $0x0,%esi
  801496:	f7 de                	neg    %esi
  801498:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  80149b:	b8 0a 00 00 00       	mov    $0xa,%eax
  8014a0:	e9 93 00 00 00       	jmp    801538 <vprintfmt+0x32f>
  8014a5:	89 5d d8             	mov    %ebx,-0x28(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8014a8:	89 ca                	mov    %ecx,%edx
  8014aa:	8d 45 14             	lea    0x14(%ebp),%eax
  8014ad:	e8 b4 fc ff ff       	call   801166 <getuint>
  8014b2:	89 c3                	mov    %eax,%ebx
  8014b4:	89 d6                	mov    %edx,%esi
			base = 10;
  8014b6:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  8014bb:	eb 7b                	jmp    801538 <vprintfmt+0x32f>
  8014bd:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// (unsigned) octal
		case 'o':
            // (MIT 6.828, lab1, Ex.8)  my code : 
            num = getint(&ap, lflag);
  8014c0:	89 ca                	mov    %ecx,%edx
  8014c2:	8d 45 14             	lea    0x14(%ebp),%eax
  8014c5:	e8 d6 fc ff ff       	call   8011a0 <getint>
  8014ca:	89 c3                	mov    %eax,%ebx
  8014cc:	89 d6                	mov    %edx,%esi
            if ((long long) num < 0) {
  8014ce:	85 d2                	test   %edx,%edx
  8014d0:	78 07                	js     8014d9 <vprintfmt+0x2d0>
                putch('-', putdat);
                num = -(long long) num;
            }
            base = 8;
  8014d2:	b8 08 00 00 00       	mov    $0x8,%eax
  8014d7:	eb 5f                	jmp    801538 <vprintfmt+0x32f>
		// (unsigned) octal
		case 'o':
            // (MIT 6.828, lab1, Ex.8)  my code : 
            num = getint(&ap, lflag);
            if ((long long) num < 0) {
                putch('-', putdat);
  8014d9:	83 ec 08             	sub    $0x8,%esp
  8014dc:	57                   	push   %edi
  8014dd:	6a 2d                	push   $0x2d
  8014df:	ff 55 08             	call   *0x8(%ebp)
                num = -(long long) num;
  8014e2:	f7 db                	neg    %ebx
  8014e4:	83 d6 00             	adc    $0x0,%esi
  8014e7:	f7 de                	neg    %esi
  8014e9:	83 c4 10             	add    $0x10,%esp
            }
            base = 8;
  8014ec:	b8 08 00 00 00       	mov    $0x8,%eax
  8014f1:	eb 45                	jmp    801538 <vprintfmt+0x32f>
  8014f3:	89 5d d8             	mov    %ebx,-0x28(%ebp)
            goto number;

        // pointer
		case 'p':
			putch('0', putdat);
  8014f6:	83 ec 08             	sub    $0x8,%esp
  8014f9:	57                   	push   %edi
  8014fa:	6a 30                	push   $0x30
  8014fc:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  8014ff:	83 c4 08             	add    $0x8,%esp
  801502:	57                   	push   %edi
  801503:	6a 78                	push   $0x78
  801505:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  801508:	8b 45 14             	mov    0x14(%ebp),%eax
  80150b:	8d 50 04             	lea    0x4(%eax),%edx
  80150e:	89 55 14             	mov    %edx,0x14(%ebp)

        // pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  801511:	8b 18                	mov    (%eax),%ebx
  801513:	be 00 00 00 00       	mov    $0x0,%esi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  801518:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  80151b:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  801520:	eb 16                	jmp    801538 <vprintfmt+0x32f>
  801522:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  801525:	89 ca                	mov    %ecx,%edx
  801527:	8d 45 14             	lea    0x14(%ebp),%eax
  80152a:	e8 37 fc ff ff       	call   801166 <getuint>
  80152f:	89 c3                	mov    %eax,%ebx
  801531:	89 d6                	mov    %edx,%esi
			base = 16;
  801533:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  801538:	83 ec 0c             	sub    $0xc,%esp
  80153b:	0f be 55 dc          	movsbl -0x24(%ebp),%edx
  80153f:	52                   	push   %edx
  801540:	ff 75 e4             	pushl  -0x1c(%ebp)
  801543:	50                   	push   %eax
  801544:	56                   	push   %esi
  801545:	53                   	push   %ebx
  801546:	89 fa                	mov    %edi,%edx
  801548:	8b 45 08             	mov    0x8(%ebp),%eax
  80154b:	e8 68 fb ff ff       	call   8010b8 <printnum>
			break;
  801550:	83 c4 20             	add    $0x20,%esp
  801553:	8b 75 d8             	mov    -0x28(%ebp),%esi
  801556:	e9 d2 fc ff ff       	jmp    80122d <vprintfmt+0x24>
  80155b:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80155e:	83 ec 08             	sub    $0x8,%esp
  801561:	57                   	push   %edi
  801562:	52                   	push   %edx
  801563:	ff 55 08             	call   *0x8(%ebp)
			break;
  801566:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801569:	8b 75 d8             	mov    -0x28(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  80156c:	e9 bc fc ff ff       	jmp    80122d <vprintfmt+0x24>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  801571:	83 ec 08             	sub    $0x8,%esp
  801574:	57                   	push   %edi
  801575:	6a 25                	push   $0x25
  801577:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  80157a:	83 c4 10             	add    $0x10,%esp
  80157d:	eb 02                	jmp    801581 <vprintfmt+0x378>
  80157f:	89 c6                	mov    %eax,%esi
  801581:	8d 46 ff             	lea    -0x1(%esi),%eax
  801584:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  801588:	75 f5                	jne    80157f <vprintfmt+0x376>
  80158a:	e9 9e fc ff ff       	jmp    80122d <vprintfmt+0x24>
				/* do nothing */;
			break;
		}
	}
}
  80158f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801592:	5b                   	pop    %ebx
  801593:	5e                   	pop    %esi
  801594:	5f                   	pop    %edi
  801595:	c9                   	leave  
  801596:	c3                   	ret    

00801597 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  801597:	55                   	push   %ebp
  801598:	89 e5                	mov    %esp,%ebp
  80159a:	83 ec 18             	sub    $0x18,%esp
  80159d:	8b 45 08             	mov    0x8(%ebp),%eax
  8015a0:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8015a3:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8015a6:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8015aa:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8015ad:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8015b4:	85 c0                	test   %eax,%eax
  8015b6:	74 26                	je     8015de <vsnprintf+0x47>
  8015b8:	85 d2                	test   %edx,%edx
  8015ba:	7e 29                	jle    8015e5 <vsnprintf+0x4e>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8015bc:	ff 75 14             	pushl  0x14(%ebp)
  8015bf:	ff 75 10             	pushl  0x10(%ebp)
  8015c2:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8015c5:	50                   	push   %eax
  8015c6:	68 d2 11 80 00       	push   $0x8011d2
  8015cb:	e8 39 fc ff ff       	call   801209 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8015d0:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8015d3:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8015d6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8015d9:	83 c4 10             	add    $0x10,%esp
  8015dc:	eb 0c                	jmp    8015ea <vsnprintf+0x53>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8015de:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8015e3:	eb 05                	jmp    8015ea <vsnprintf+0x53>
  8015e5:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8015ea:	c9                   	leave  
  8015eb:	c3                   	ret    

008015ec <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8015ec:	55                   	push   %ebp
  8015ed:	89 e5                	mov    %esp,%ebp
  8015ef:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8015f2:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8015f5:	50                   	push   %eax
  8015f6:	ff 75 10             	pushl  0x10(%ebp)
  8015f9:	ff 75 0c             	pushl  0xc(%ebp)
  8015fc:	ff 75 08             	pushl  0x8(%ebp)
  8015ff:	e8 93 ff ff ff       	call   801597 <vsnprintf>
	va_end(ap);

	return rc;
}
  801604:	c9                   	leave  
  801605:	c3                   	ret    
	...

00801608 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  801608:	55                   	push   %ebp
  801609:	89 e5                	mov    %esp,%ebp
  80160b:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80160e:	80 3a 00             	cmpb   $0x0,(%edx)
  801611:	74 0e                	je     801621 <strlen+0x19>
  801613:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  801618:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  801619:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  80161d:	75 f9                	jne    801618 <strlen+0x10>
  80161f:	eb 05                	jmp    801626 <strlen+0x1e>
  801621:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  801626:	c9                   	leave  
  801627:	c3                   	ret    

00801628 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  801628:	55                   	push   %ebp
  801629:	89 e5                	mov    %esp,%ebp
  80162b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80162e:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801631:	85 d2                	test   %edx,%edx
  801633:	74 17                	je     80164c <strnlen+0x24>
  801635:	80 39 00             	cmpb   $0x0,(%ecx)
  801638:	74 19                	je     801653 <strnlen+0x2b>
  80163a:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  80163f:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801640:	39 d0                	cmp    %edx,%eax
  801642:	74 14                	je     801658 <strnlen+0x30>
  801644:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  801648:	75 f5                	jne    80163f <strnlen+0x17>
  80164a:	eb 0c                	jmp    801658 <strnlen+0x30>
  80164c:	b8 00 00 00 00       	mov    $0x0,%eax
  801651:	eb 05                	jmp    801658 <strnlen+0x30>
  801653:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  801658:	c9                   	leave  
  801659:	c3                   	ret    

0080165a <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80165a:	55                   	push   %ebp
  80165b:	89 e5                	mov    %esp,%ebp
  80165d:	53                   	push   %ebx
  80165e:	8b 45 08             	mov    0x8(%ebp),%eax
  801661:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  801664:	ba 00 00 00 00       	mov    $0x0,%edx
  801669:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  80166c:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  80166f:	42                   	inc    %edx
  801670:	84 c9                	test   %cl,%cl
  801672:	75 f5                	jne    801669 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  801674:	5b                   	pop    %ebx
  801675:	c9                   	leave  
  801676:	c3                   	ret    

00801677 <strcat>:

char *
strcat(char *dst, const char *src)
{
  801677:	55                   	push   %ebp
  801678:	89 e5                	mov    %esp,%ebp
  80167a:	53                   	push   %ebx
  80167b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80167e:	53                   	push   %ebx
  80167f:	e8 84 ff ff ff       	call   801608 <strlen>
  801684:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  801687:	ff 75 0c             	pushl  0xc(%ebp)
  80168a:	8d 04 03             	lea    (%ebx,%eax,1),%eax
  80168d:	50                   	push   %eax
  80168e:	e8 c7 ff ff ff       	call   80165a <strcpy>
	return dst;
}
  801693:	89 d8                	mov    %ebx,%eax
  801695:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801698:	c9                   	leave  
  801699:	c3                   	ret    

0080169a <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80169a:	55                   	push   %ebp
  80169b:	89 e5                	mov    %esp,%ebp
  80169d:	56                   	push   %esi
  80169e:	53                   	push   %ebx
  80169f:	8b 45 08             	mov    0x8(%ebp),%eax
  8016a2:	8b 55 0c             	mov    0xc(%ebp),%edx
  8016a5:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8016a8:	85 f6                	test   %esi,%esi
  8016aa:	74 15                	je     8016c1 <strncpy+0x27>
  8016ac:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
  8016b1:	8a 1a                	mov    (%edx),%bl
  8016b3:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8016b6:	80 3a 01             	cmpb   $0x1,(%edx)
  8016b9:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8016bc:	41                   	inc    %ecx
  8016bd:	39 ce                	cmp    %ecx,%esi
  8016bf:	77 f0                	ja     8016b1 <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8016c1:	5b                   	pop    %ebx
  8016c2:	5e                   	pop    %esi
  8016c3:	c9                   	leave  
  8016c4:	c3                   	ret    

008016c5 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8016c5:	55                   	push   %ebp
  8016c6:	89 e5                	mov    %esp,%ebp
  8016c8:	57                   	push   %edi
  8016c9:	56                   	push   %esi
  8016ca:	53                   	push   %ebx
  8016cb:	8b 7d 08             	mov    0x8(%ebp),%edi
  8016ce:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8016d1:	8b 75 10             	mov    0x10(%ebp),%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8016d4:	85 f6                	test   %esi,%esi
  8016d6:	74 32                	je     80170a <strlcpy+0x45>
		while (--size > 0 && *src != '\0')
  8016d8:	83 fe 01             	cmp    $0x1,%esi
  8016db:	74 22                	je     8016ff <strlcpy+0x3a>
  8016dd:	8a 0b                	mov    (%ebx),%cl
  8016df:	84 c9                	test   %cl,%cl
  8016e1:	74 20                	je     801703 <strlcpy+0x3e>
  8016e3:	89 f8                	mov    %edi,%eax
  8016e5:	ba 00 00 00 00       	mov    $0x0,%edx
	}
	return ret;
}

size_t
strlcpy(char *dst, const char *src, size_t size)
  8016ea:	83 ee 02             	sub    $0x2,%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8016ed:	88 08                	mov    %cl,(%eax)
  8016ef:	40                   	inc    %eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8016f0:	39 f2                	cmp    %esi,%edx
  8016f2:	74 11                	je     801705 <strlcpy+0x40>
  8016f4:	8a 4c 13 01          	mov    0x1(%ebx,%edx,1),%cl
  8016f8:	42                   	inc    %edx
  8016f9:	84 c9                	test   %cl,%cl
  8016fb:	75 f0                	jne    8016ed <strlcpy+0x28>
  8016fd:	eb 06                	jmp    801705 <strlcpy+0x40>
  8016ff:	89 f8                	mov    %edi,%eax
  801701:	eb 02                	jmp    801705 <strlcpy+0x40>
  801703:	89 f8                	mov    %edi,%eax
			*dst++ = *src++;
		*dst = '\0';
  801705:	c6 00 00             	movb   $0x0,(%eax)
  801708:	eb 02                	jmp    80170c <strlcpy+0x47>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80170a:	89 f8                	mov    %edi,%eax
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
		*dst = '\0';
	}
	return dst - dst_in;
  80170c:	29 f8                	sub    %edi,%eax
}
  80170e:	5b                   	pop    %ebx
  80170f:	5e                   	pop    %esi
  801710:	5f                   	pop    %edi
  801711:	c9                   	leave  
  801712:	c3                   	ret    

00801713 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  801713:	55                   	push   %ebp
  801714:	89 e5                	mov    %esp,%ebp
  801716:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801719:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80171c:	8a 01                	mov    (%ecx),%al
  80171e:	84 c0                	test   %al,%al
  801720:	74 10                	je     801732 <strcmp+0x1f>
  801722:	3a 02                	cmp    (%edx),%al
  801724:	75 0c                	jne    801732 <strcmp+0x1f>
		p++, q++;
  801726:	41                   	inc    %ecx
  801727:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  801728:	8a 01                	mov    (%ecx),%al
  80172a:	84 c0                	test   %al,%al
  80172c:	74 04                	je     801732 <strcmp+0x1f>
  80172e:	3a 02                	cmp    (%edx),%al
  801730:	74 f4                	je     801726 <strcmp+0x13>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  801732:	0f b6 c0             	movzbl %al,%eax
  801735:	0f b6 12             	movzbl (%edx),%edx
  801738:	29 d0                	sub    %edx,%eax
}
  80173a:	c9                   	leave  
  80173b:	c3                   	ret    

0080173c <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  80173c:	55                   	push   %ebp
  80173d:	89 e5                	mov    %esp,%ebp
  80173f:	53                   	push   %ebx
  801740:	8b 55 08             	mov    0x8(%ebp),%edx
  801743:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801746:	8b 45 10             	mov    0x10(%ebp),%eax
	while (n > 0 && *p && *p == *q)
  801749:	85 c0                	test   %eax,%eax
  80174b:	74 1b                	je     801768 <strncmp+0x2c>
  80174d:	8a 1a                	mov    (%edx),%bl
  80174f:	84 db                	test   %bl,%bl
  801751:	74 24                	je     801777 <strncmp+0x3b>
  801753:	3a 19                	cmp    (%ecx),%bl
  801755:	75 20                	jne    801777 <strncmp+0x3b>
  801757:	48                   	dec    %eax
  801758:	74 15                	je     80176f <strncmp+0x33>
		n--, p++, q++;
  80175a:	42                   	inc    %edx
  80175b:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  80175c:	8a 1a                	mov    (%edx),%bl
  80175e:	84 db                	test   %bl,%bl
  801760:	74 15                	je     801777 <strncmp+0x3b>
  801762:	3a 19                	cmp    (%ecx),%bl
  801764:	74 f1                	je     801757 <strncmp+0x1b>
  801766:	eb 0f                	jmp    801777 <strncmp+0x3b>
		n--, p++, q++;
	if (n == 0)
		return 0;
  801768:	b8 00 00 00 00       	mov    $0x0,%eax
  80176d:	eb 05                	jmp    801774 <strncmp+0x38>
  80176f:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  801774:	5b                   	pop    %ebx
  801775:	c9                   	leave  
  801776:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  801777:	0f b6 02             	movzbl (%edx),%eax
  80177a:	0f b6 11             	movzbl (%ecx),%edx
  80177d:	29 d0                	sub    %edx,%eax
  80177f:	eb f3                	jmp    801774 <strncmp+0x38>

00801781 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  801781:	55                   	push   %ebp
  801782:	89 e5                	mov    %esp,%ebp
  801784:	8b 45 08             	mov    0x8(%ebp),%eax
  801787:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  80178a:	8a 10                	mov    (%eax),%dl
  80178c:	84 d2                	test   %dl,%dl
  80178e:	74 18                	je     8017a8 <strchr+0x27>
		if (*s == c)
  801790:	38 ca                	cmp    %cl,%dl
  801792:	75 06                	jne    80179a <strchr+0x19>
  801794:	eb 17                	jmp    8017ad <strchr+0x2c>
  801796:	38 ca                	cmp    %cl,%dl
  801798:	74 13                	je     8017ad <strchr+0x2c>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  80179a:	40                   	inc    %eax
  80179b:	8a 10                	mov    (%eax),%dl
  80179d:	84 d2                	test   %dl,%dl
  80179f:	75 f5                	jne    801796 <strchr+0x15>
		if (*s == c)
			return (char *) s;
	return 0;
  8017a1:	b8 00 00 00 00       	mov    $0x0,%eax
  8017a6:	eb 05                	jmp    8017ad <strchr+0x2c>
  8017a8:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8017ad:	c9                   	leave  
  8017ae:	c3                   	ret    

008017af <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8017af:	55                   	push   %ebp
  8017b0:	89 e5                	mov    %esp,%ebp
  8017b2:	8b 45 08             	mov    0x8(%ebp),%eax
  8017b5:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  8017b8:	8a 10                	mov    (%eax),%dl
  8017ba:	84 d2                	test   %dl,%dl
  8017bc:	74 11                	je     8017cf <strfind+0x20>
		if (*s == c)
  8017be:	38 ca                	cmp    %cl,%dl
  8017c0:	75 06                	jne    8017c8 <strfind+0x19>
  8017c2:	eb 0b                	jmp    8017cf <strfind+0x20>
  8017c4:	38 ca                	cmp    %cl,%dl
  8017c6:	74 07                	je     8017cf <strfind+0x20>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  8017c8:	40                   	inc    %eax
  8017c9:	8a 10                	mov    (%eax),%dl
  8017cb:	84 d2                	test   %dl,%dl
  8017cd:	75 f5                	jne    8017c4 <strfind+0x15>
		if (*s == c)
			break;
	return (char *) s;
}
  8017cf:	c9                   	leave  
  8017d0:	c3                   	ret    

008017d1 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8017d1:	55                   	push   %ebp
  8017d2:	89 e5                	mov    %esp,%ebp
  8017d4:	57                   	push   %edi
  8017d5:	56                   	push   %esi
  8017d6:	53                   	push   %ebx
  8017d7:	8b 7d 08             	mov    0x8(%ebp),%edi
  8017da:	8b 45 0c             	mov    0xc(%ebp),%eax
  8017dd:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8017e0:	85 c9                	test   %ecx,%ecx
  8017e2:	74 30                	je     801814 <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8017e4:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8017ea:	75 25                	jne    801811 <memset+0x40>
  8017ec:	f6 c1 03             	test   $0x3,%cl
  8017ef:	75 20                	jne    801811 <memset+0x40>
		c &= 0xFF;
  8017f1:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8017f4:	89 d3                	mov    %edx,%ebx
  8017f6:	c1 e3 08             	shl    $0x8,%ebx
  8017f9:	89 d6                	mov    %edx,%esi
  8017fb:	c1 e6 18             	shl    $0x18,%esi
  8017fe:	89 d0                	mov    %edx,%eax
  801800:	c1 e0 10             	shl    $0x10,%eax
  801803:	09 f0                	or     %esi,%eax
  801805:	09 d0                	or     %edx,%eax
  801807:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  801809:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  80180c:	fc                   	cld    
  80180d:	f3 ab                	rep stos %eax,%es:(%edi)
  80180f:	eb 03                	jmp    801814 <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  801811:	fc                   	cld    
  801812:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  801814:	89 f8                	mov    %edi,%eax
  801816:	5b                   	pop    %ebx
  801817:	5e                   	pop    %esi
  801818:	5f                   	pop    %edi
  801819:	c9                   	leave  
  80181a:	c3                   	ret    

0080181b <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  80181b:	55                   	push   %ebp
  80181c:	89 e5                	mov    %esp,%ebp
  80181e:	57                   	push   %edi
  80181f:	56                   	push   %esi
  801820:	8b 45 08             	mov    0x8(%ebp),%eax
  801823:	8b 75 0c             	mov    0xc(%ebp),%esi
  801826:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  801829:	39 c6                	cmp    %eax,%esi
  80182b:	73 34                	jae    801861 <memmove+0x46>
  80182d:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  801830:	39 d0                	cmp    %edx,%eax
  801832:	73 2d                	jae    801861 <memmove+0x46>
		s += n;
		d += n;
  801834:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801837:	f6 c2 03             	test   $0x3,%dl
  80183a:	75 1b                	jne    801857 <memmove+0x3c>
  80183c:	f7 c7 03 00 00 00    	test   $0x3,%edi
  801842:	75 13                	jne    801857 <memmove+0x3c>
  801844:	f6 c1 03             	test   $0x3,%cl
  801847:	75 0e                	jne    801857 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  801849:	83 ef 04             	sub    $0x4,%edi
  80184c:	8d 72 fc             	lea    -0x4(%edx),%esi
  80184f:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  801852:	fd                   	std    
  801853:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801855:	eb 07                	jmp    80185e <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  801857:	4f                   	dec    %edi
  801858:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  80185b:	fd                   	std    
  80185c:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  80185e:	fc                   	cld    
  80185f:	eb 20                	jmp    801881 <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801861:	f7 c6 03 00 00 00    	test   $0x3,%esi
  801867:	75 13                	jne    80187c <memmove+0x61>
  801869:	a8 03                	test   $0x3,%al
  80186b:	75 0f                	jne    80187c <memmove+0x61>
  80186d:	f6 c1 03             	test   $0x3,%cl
  801870:	75 0a                	jne    80187c <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  801872:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  801875:	89 c7                	mov    %eax,%edi
  801877:	fc                   	cld    
  801878:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80187a:	eb 05                	jmp    801881 <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  80187c:	89 c7                	mov    %eax,%edi
  80187e:	fc                   	cld    
  80187f:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  801881:	5e                   	pop    %esi
  801882:	5f                   	pop    %edi
  801883:	c9                   	leave  
  801884:	c3                   	ret    

00801885 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  801885:	55                   	push   %ebp
  801886:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  801888:	ff 75 10             	pushl  0x10(%ebp)
  80188b:	ff 75 0c             	pushl  0xc(%ebp)
  80188e:	ff 75 08             	pushl  0x8(%ebp)
  801891:	e8 85 ff ff ff       	call   80181b <memmove>
}
  801896:	c9                   	leave  
  801897:	c3                   	ret    

00801898 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  801898:	55                   	push   %ebp
  801899:	89 e5                	mov    %esp,%ebp
  80189b:	57                   	push   %edi
  80189c:	56                   	push   %esi
  80189d:	53                   	push   %ebx
  80189e:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8018a1:	8b 75 0c             	mov    0xc(%ebp),%esi
  8018a4:	8b 7d 10             	mov    0x10(%ebp),%edi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8018a7:	85 ff                	test   %edi,%edi
  8018a9:	74 32                	je     8018dd <memcmp+0x45>
		if (*s1 != *s2)
  8018ab:	8a 03                	mov    (%ebx),%al
  8018ad:	8a 0e                	mov    (%esi),%cl
  8018af:	38 c8                	cmp    %cl,%al
  8018b1:	74 19                	je     8018cc <memcmp+0x34>
  8018b3:	eb 0d                	jmp    8018c2 <memcmp+0x2a>
  8018b5:	8a 44 13 01          	mov    0x1(%ebx,%edx,1),%al
  8018b9:	8a 4c 16 01          	mov    0x1(%esi,%edx,1),%cl
  8018bd:	42                   	inc    %edx
  8018be:	38 c8                	cmp    %cl,%al
  8018c0:	74 10                	je     8018d2 <memcmp+0x3a>
			return (int) *s1 - (int) *s2;
  8018c2:	0f b6 c0             	movzbl %al,%eax
  8018c5:	0f b6 c9             	movzbl %cl,%ecx
  8018c8:	29 c8                	sub    %ecx,%eax
  8018ca:	eb 16                	jmp    8018e2 <memcmp+0x4a>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8018cc:	4f                   	dec    %edi
  8018cd:	ba 00 00 00 00       	mov    $0x0,%edx
  8018d2:	39 fa                	cmp    %edi,%edx
  8018d4:	75 df                	jne    8018b5 <memcmp+0x1d>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  8018d6:	b8 00 00 00 00       	mov    $0x0,%eax
  8018db:	eb 05                	jmp    8018e2 <memcmp+0x4a>
  8018dd:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8018e2:	5b                   	pop    %ebx
  8018e3:	5e                   	pop    %esi
  8018e4:	5f                   	pop    %edi
  8018e5:	c9                   	leave  
  8018e6:	c3                   	ret    

008018e7 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8018e7:	55                   	push   %ebp
  8018e8:	89 e5                	mov    %esp,%ebp
  8018ea:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  8018ed:	89 c2                	mov    %eax,%edx
  8018ef:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  8018f2:	39 d0                	cmp    %edx,%eax
  8018f4:	73 12                	jae    801908 <memfind+0x21>
		if (*(const unsigned char *) s == (unsigned char) c)
  8018f6:	8a 4d 0c             	mov    0xc(%ebp),%cl
  8018f9:	38 08                	cmp    %cl,(%eax)
  8018fb:	75 06                	jne    801903 <memfind+0x1c>
  8018fd:	eb 09                	jmp    801908 <memfind+0x21>
  8018ff:	38 08                	cmp    %cl,(%eax)
  801901:	74 05                	je     801908 <memfind+0x21>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801903:	40                   	inc    %eax
  801904:	39 c2                	cmp    %eax,%edx
  801906:	77 f7                	ja     8018ff <memfind+0x18>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  801908:	c9                   	leave  
  801909:	c3                   	ret    

0080190a <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  80190a:	55                   	push   %ebp
  80190b:	89 e5                	mov    %esp,%ebp
  80190d:	57                   	push   %edi
  80190e:	56                   	push   %esi
  80190f:	53                   	push   %ebx
  801910:	8b 55 08             	mov    0x8(%ebp),%edx
  801913:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801916:	eb 01                	jmp    801919 <strtol+0xf>
		s++;
  801918:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801919:	8a 02                	mov    (%edx),%al
  80191b:	3c 20                	cmp    $0x20,%al
  80191d:	74 f9                	je     801918 <strtol+0xe>
  80191f:	3c 09                	cmp    $0x9,%al
  801921:	74 f5                	je     801918 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  801923:	3c 2b                	cmp    $0x2b,%al
  801925:	75 08                	jne    80192f <strtol+0x25>
		s++;
  801927:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  801928:	bf 00 00 00 00       	mov    $0x0,%edi
  80192d:	eb 13                	jmp    801942 <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  80192f:	3c 2d                	cmp    $0x2d,%al
  801931:	75 0a                	jne    80193d <strtol+0x33>
		s++, neg = 1;
  801933:	8d 52 01             	lea    0x1(%edx),%edx
  801936:	bf 01 00 00 00       	mov    $0x1,%edi
  80193b:	eb 05                	jmp    801942 <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  80193d:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801942:	85 db                	test   %ebx,%ebx
  801944:	74 05                	je     80194b <strtol+0x41>
  801946:	83 fb 10             	cmp    $0x10,%ebx
  801949:	75 28                	jne    801973 <strtol+0x69>
  80194b:	8a 02                	mov    (%edx),%al
  80194d:	3c 30                	cmp    $0x30,%al
  80194f:	75 10                	jne    801961 <strtol+0x57>
  801951:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  801955:	75 0a                	jne    801961 <strtol+0x57>
		s += 2, base = 16;
  801957:	83 c2 02             	add    $0x2,%edx
  80195a:	bb 10 00 00 00       	mov    $0x10,%ebx
  80195f:	eb 12                	jmp    801973 <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  801961:	85 db                	test   %ebx,%ebx
  801963:	75 0e                	jne    801973 <strtol+0x69>
  801965:	3c 30                	cmp    $0x30,%al
  801967:	75 05                	jne    80196e <strtol+0x64>
		s++, base = 8;
  801969:	42                   	inc    %edx
  80196a:	b3 08                	mov    $0x8,%bl
  80196c:	eb 05                	jmp    801973 <strtol+0x69>
	else if (base == 0)
		base = 10;
  80196e:	bb 0a 00 00 00       	mov    $0xa,%ebx
  801973:	b8 00 00 00 00       	mov    $0x0,%eax
  801978:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  80197a:	8a 0a                	mov    (%edx),%cl
  80197c:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  80197f:	80 fb 09             	cmp    $0x9,%bl
  801982:	77 08                	ja     80198c <strtol+0x82>
			dig = *s - '0';
  801984:	0f be c9             	movsbl %cl,%ecx
  801987:	83 e9 30             	sub    $0x30,%ecx
  80198a:	eb 1e                	jmp    8019aa <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  80198c:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  80198f:	80 fb 19             	cmp    $0x19,%bl
  801992:	77 08                	ja     80199c <strtol+0x92>
			dig = *s - 'a' + 10;
  801994:	0f be c9             	movsbl %cl,%ecx
  801997:	83 e9 57             	sub    $0x57,%ecx
  80199a:	eb 0e                	jmp    8019aa <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  80199c:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  80199f:	80 fb 19             	cmp    $0x19,%bl
  8019a2:	77 13                	ja     8019b7 <strtol+0xad>
			dig = *s - 'A' + 10;
  8019a4:	0f be c9             	movsbl %cl,%ecx
  8019a7:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  8019aa:	39 f1                	cmp    %esi,%ecx
  8019ac:	7d 0d                	jge    8019bb <strtol+0xb1>
			break;
		s++, val = (val * base) + dig;
  8019ae:	42                   	inc    %edx
  8019af:	0f af c6             	imul   %esi,%eax
  8019b2:	8d 04 01             	lea    (%ecx,%eax,1),%eax
		// we don't properly detect overflow!
	}
  8019b5:	eb c3                	jmp    80197a <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  8019b7:	89 c1                	mov    %eax,%ecx
  8019b9:	eb 02                	jmp    8019bd <strtol+0xb3>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  8019bb:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  8019bd:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8019c1:	74 05                	je     8019c8 <strtol+0xbe>
		*endptr = (char *) s;
  8019c3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8019c6:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  8019c8:	85 ff                	test   %edi,%edi
  8019ca:	74 04                	je     8019d0 <strtol+0xc6>
  8019cc:	89 c8                	mov    %ecx,%eax
  8019ce:	f7 d8                	neg    %eax
}
  8019d0:	5b                   	pop    %ebx
  8019d1:	5e                   	pop    %esi
  8019d2:	5f                   	pop    %edi
  8019d3:	c9                   	leave  
  8019d4:	c3                   	ret    
  8019d5:	00 00                	add    %al,(%eax)
	...

008019d8 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8019d8:	55                   	push   %ebp
  8019d9:	89 e5                	mov    %esp,%ebp
  8019db:	56                   	push   %esi
  8019dc:	53                   	push   %ebx
  8019dd:	8b 75 08             	mov    0x8(%ebp),%esi
  8019e0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8019e3:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// cprintf("0x%x 0x%x 0x%x\n", (uint32_t)from_env_store, (uint32_t)pg, (uint32_t)perm_store);
	int r;
	if (pg != NULL) {
  8019e6:	85 c0                	test   %eax,%eax
  8019e8:	74 0e                	je     8019f8 <ipc_recv+0x20>
		r = sys_ipc_recv(pg);
  8019ea:	83 ec 0c             	sub    $0xc,%esp
  8019ed:	50                   	push   %eax
  8019ee:	e8 e0 e8 ff ff       	call   8002d3 <sys_ipc_recv>
  8019f3:	83 c4 10             	add    $0x10,%esp
  8019f6:	eb 10                	jmp    801a08 <ipc_recv+0x30>
	} else {
		r = sys_ipc_recv((void *)UTOP);
  8019f8:	83 ec 0c             	sub    $0xc,%esp
  8019fb:	68 00 00 c0 ee       	push   $0xeec00000
  801a00:	e8 ce e8 ff ff       	call   8002d3 <sys_ipc_recv>
  801a05:	83 c4 10             	add    $0x10,%esp
	}

	if (r == 0) {
  801a08:	85 c0                	test   %eax,%eax
  801a0a:	75 26                	jne    801a32 <ipc_recv+0x5a>
		if (from_env_store != NULL) *from_env_store = thisenv->env_ipc_from;
  801a0c:	85 f6                	test   %esi,%esi
  801a0e:	74 0a                	je     801a1a <ipc_recv+0x42>
  801a10:	a1 04 40 80 00       	mov    0x804004,%eax
  801a15:	8b 40 74             	mov    0x74(%eax),%eax
  801a18:	89 06                	mov    %eax,(%esi)
		if (perm_store != NULL) *perm_store = thisenv->env_ipc_perm;
  801a1a:	85 db                	test   %ebx,%ebx
  801a1c:	74 0a                	je     801a28 <ipc_recv+0x50>
  801a1e:	a1 04 40 80 00       	mov    0x804004,%eax
  801a23:	8b 40 78             	mov    0x78(%eax),%eax
  801a26:	89 03                	mov    %eax,(%ebx)
		return thisenv->env_ipc_value;
  801a28:	a1 04 40 80 00       	mov    0x804004,%eax
  801a2d:	8b 40 70             	mov    0x70(%eax),%eax
  801a30:	eb 14                	jmp    801a46 <ipc_recv+0x6e>
	} else {
		// fails;
		if (from_env_store != NULL) *from_env_store = 0;
  801a32:	85 f6                	test   %esi,%esi
  801a34:	74 06                	je     801a3c <ipc_recv+0x64>
  801a36:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		if (perm_store != NULL) *perm_store = 0;
  801a3c:	85 db                	test   %ebx,%ebx
  801a3e:	74 06                	je     801a46 <ipc_recv+0x6e>
  801a40:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
		return r;
	}
}
  801a46:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a49:	5b                   	pop    %ebx
  801a4a:	5e                   	pop    %esi
  801a4b:	c9                   	leave  
  801a4c:	c3                   	ret    

00801a4d <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801a4d:	55                   	push   %ebp
  801a4e:	89 e5                	mov    %esp,%ebp
  801a50:	57                   	push   %edi
  801a51:	56                   	push   %esi
  801a52:	53                   	push   %ebx
  801a53:	83 ec 0c             	sub    $0xc,%esp
  801a56:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801a59:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801a5c:	8b 75 14             	mov    0x14(%ebp),%esi
	// LAB 4: Your code here.
	// int sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
	int r;
	if (pg == NULL) pg = (void *)UTOP;
  801a5f:	85 db                	test   %ebx,%ebx
  801a61:	75 25                	jne    801a88 <ipc_send+0x3b>
  801a63:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
  801a68:	eb 1e                	jmp    801a88 <ipc_send+0x3b>
	
	while ((r = sys_ipc_try_send(to_env, val, pg, perm)) != 0) {
		if (r == -E_IPC_NOT_RECV) {
  801a6a:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801a6d:	75 07                	jne    801a76 <ipc_send+0x29>
			// cprintf("Try Again and Again....\n");
			sys_yield();
  801a6f:	e8 3d e7 ff ff       	call   8001b1 <sys_yield>
  801a74:	eb 12                	jmp    801a88 <ipc_send+0x3b>
		} else {
			panic("ipc_send error %e\n", r);
  801a76:	50                   	push   %eax
  801a77:	68 e0 21 80 00       	push   $0x8021e0
  801a7c:	6a 43                	push   $0x43
  801a7e:	68 f3 21 80 00       	push   $0x8021f3
  801a83:	e8 44 f5 ff ff       	call   800fcc <_panic>
	// LAB 4: Your code here.
	// int sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
	int r;
	if (pg == NULL) pg = (void *)UTOP;
	
	while ((r = sys_ipc_try_send(to_env, val, pg, perm)) != 0) {
  801a88:	56                   	push   %esi
  801a89:	53                   	push   %ebx
  801a8a:	57                   	push   %edi
  801a8b:	ff 75 08             	pushl  0x8(%ebp)
  801a8e:	e8 1b e8 ff ff       	call   8002ae <sys_ipc_try_send>
  801a93:	83 c4 10             	add    $0x10,%esp
  801a96:	85 c0                	test   %eax,%eax
  801a98:	75 d0                	jne    801a6a <ipc_send+0x1d>
		} else {
			panic("ipc_send error %e\n", r);
		}
	}
	return;
}
  801a9a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801a9d:	5b                   	pop    %ebx
  801a9e:	5e                   	pop    %esi
  801a9f:	5f                   	pop    %edi
  801aa0:	c9                   	leave  
  801aa1:	c3                   	ret    

00801aa2 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801aa2:	55                   	push   %ebp
  801aa3:	89 e5                	mov    %esp,%ebp
  801aa5:	53                   	push   %ebx
  801aa6:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	for (i = 0; i < NENV; i++)
		if (envs[i].env_type == type)
  801aa9:	39 1d 50 00 c0 ee    	cmp    %ebx,0xeec00050
  801aaf:	74 22                	je     801ad3 <ipc_find_env+0x31>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801ab1:	b8 01 00 00 00       	mov    $0x1,%eax
		if (envs[i].env_type == type)
  801ab6:	8d 0c 85 00 00 00 00 	lea    0x0(,%eax,4),%ecx
  801abd:	89 c2                	mov    %eax,%edx
  801abf:	c1 e2 07             	shl    $0x7,%edx
  801ac2:	29 ca                	sub    %ecx,%edx
  801ac4:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801aca:	8b 52 50             	mov    0x50(%edx),%edx
  801acd:	39 da                	cmp    %ebx,%edx
  801acf:	75 1d                	jne    801aee <ipc_find_env+0x4c>
  801ad1:	eb 05                	jmp    801ad8 <ipc_find_env+0x36>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801ad3:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
			return envs[i].env_id;
  801ad8:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  801adf:	c1 e0 07             	shl    $0x7,%eax
  801ae2:	29 d0                	sub    %edx,%eax
  801ae4:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  801ae9:	8b 40 40             	mov    0x40(%eax),%eax
  801aec:	eb 0c                	jmp    801afa <ipc_find_env+0x58>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801aee:	40                   	inc    %eax
  801aef:	3d 00 04 00 00       	cmp    $0x400,%eax
  801af4:	75 c0                	jne    801ab6 <ipc_find_env+0x14>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801af6:	66 b8 00 00          	mov    $0x0,%ax
}
  801afa:	5b                   	pop    %ebx
  801afb:	c9                   	leave  
  801afc:	c3                   	ret    
  801afd:	00 00                	add    %al,(%eax)
	...

00801b00 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801b00:	55                   	push   %ebp
  801b01:	89 e5                	mov    %esp,%ebp
  801b03:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801b06:	89 c2                	mov    %eax,%edx
  801b08:	c1 ea 16             	shr    $0x16,%edx
  801b0b:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801b12:	f6 c2 01             	test   $0x1,%dl
  801b15:	74 1e                	je     801b35 <pageref+0x35>
		return 0;
	pte = uvpt[PGNUM(v)];
  801b17:	c1 e8 0c             	shr    $0xc,%eax
  801b1a:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  801b21:	a8 01                	test   $0x1,%al
  801b23:	74 17                	je     801b3c <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801b25:	c1 e8 0c             	shr    $0xc,%eax
  801b28:	66 8b 04 c5 04 00 00 	mov    -0x10fffffc(,%eax,8),%ax
  801b2f:	ef 
  801b30:	0f b7 c0             	movzwl %ax,%eax
  801b33:	eb 0c                	jmp    801b41 <pageref+0x41>
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
		return 0;
  801b35:	b8 00 00 00 00       	mov    $0x0,%eax
  801b3a:	eb 05                	jmp    801b41 <pageref+0x41>
	pte = uvpt[PGNUM(v)];
	if (!(pte & PTE_P))
		return 0;
  801b3c:	b8 00 00 00 00       	mov    $0x0,%eax
	return pages[PGNUM(pte)].pp_ref;
}
  801b41:	c9                   	leave  
  801b42:	c3                   	ret    
	...

00801b44 <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  801b44:	55                   	push   %ebp
  801b45:	89 e5                	mov    %esp,%ebp
  801b47:	57                   	push   %edi
  801b48:	56                   	push   %esi
  801b49:	83 ec 10             	sub    $0x10,%esp
  801b4c:	8b 7d 08             	mov    0x8(%ebp),%edi
  801b4f:	8b 4d 10             	mov    0x10(%ebp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  801b52:	89 7d f0             	mov    %edi,-0x10(%ebp)
  801b55:	8b 75 0c             	mov    0xc(%ebp),%esi
  const DWunion dd = {.ll = d};
  801b58:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  801b5b:	8b 45 14             	mov    0x14(%ebp),%eax
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  801b5e:	85 c0                	test   %eax,%eax
  801b60:	75 2e                	jne    801b90 <__udivdi3+0x4c>
    {
      if (d0 > n1)
  801b62:	39 f1                	cmp    %esi,%ecx
  801b64:	77 5a                	ja     801bc0 <__udivdi3+0x7c>
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  801b66:	85 c9                	test   %ecx,%ecx
  801b68:	75 0b                	jne    801b75 <__udivdi3+0x31>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  801b6a:	b8 01 00 00 00       	mov    $0x1,%eax
  801b6f:	31 d2                	xor    %edx,%edx
  801b71:	f7 f1                	div    %ecx
  801b73:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  801b75:	31 d2                	xor    %edx,%edx
  801b77:	89 f0                	mov    %esi,%eax
  801b79:	f7 f1                	div    %ecx
  801b7b:	89 c6                	mov    %eax,%esi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801b7d:	89 f8                	mov    %edi,%eax
  801b7f:	f7 f1                	div    %ecx
  801b81:	89 c7                	mov    %eax,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  801b83:	89 f8                	mov    %edi,%eax
  801b85:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801b87:	83 c4 10             	add    $0x10,%esp
  801b8a:	5e                   	pop    %esi
  801b8b:	5f                   	pop    %edi
  801b8c:	c9                   	leave  
  801b8d:	c3                   	ret    
  801b8e:	66 90                	xchg   %ax,%ax
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  801b90:	39 f0                	cmp    %esi,%eax
  801b92:	77 1c                	ja     801bb0 <__udivdi3+0x6c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  801b94:	0f bd f8             	bsr    %eax,%edi
	  if (bm == 0)
  801b97:	83 f7 1f             	xor    $0x1f,%edi
  801b9a:	75 3c                	jne    801bd8 <__udivdi3+0x94>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  801b9c:	39 f0                	cmp    %esi,%eax
  801b9e:	0f 82 90 00 00 00    	jb     801c34 <__udivdi3+0xf0>
  801ba4:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801ba7:	39 55 f4             	cmp    %edx,-0xc(%ebp)
  801baa:	0f 86 84 00 00 00    	jbe    801c34 <__udivdi3+0xf0>
  801bb0:	31 f6                	xor    %esi,%esi
  801bb2:	31 ff                	xor    %edi,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  801bb4:	89 f8                	mov    %edi,%eax
  801bb6:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801bb8:	83 c4 10             	add    $0x10,%esp
  801bbb:	5e                   	pop    %esi
  801bbc:	5f                   	pop    %edi
  801bbd:	c9                   	leave  
  801bbe:	c3                   	ret    
  801bbf:	90                   	nop
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801bc0:	89 f2                	mov    %esi,%edx
  801bc2:	89 f8                	mov    %edi,%eax
  801bc4:	f7 f1                	div    %ecx
  801bc6:	89 c7                	mov    %eax,%edi
  801bc8:	31 f6                	xor    %esi,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  801bca:	89 f8                	mov    %edi,%eax
  801bcc:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801bce:	83 c4 10             	add    $0x10,%esp
  801bd1:	5e                   	pop    %esi
  801bd2:	5f                   	pop    %edi
  801bd3:	c9                   	leave  
  801bd4:	c3                   	ret    
  801bd5:	8d 76 00             	lea    0x0(%esi),%esi
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  801bd8:	89 f9                	mov    %edi,%ecx
  801bda:	d3 e0                	shl    %cl,%eax
  801bdc:	89 45 e8             	mov    %eax,-0x18(%ebp)
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  801bdf:	b8 20 00 00 00       	mov    $0x20,%eax
  801be4:	29 f8                	sub    %edi,%eax

	      d1 = (d1 << bm) | (d0 >> b);
  801be6:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801be9:	88 c1                	mov    %al,%cl
  801beb:	d3 ea                	shr    %cl,%edx
  801bed:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  801bf0:	09 ca                	or     %ecx,%edx
  801bf2:	89 55 ec             	mov    %edx,-0x14(%ebp)
	      d0 = d0 << bm;
  801bf5:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801bf8:	89 f9                	mov    %edi,%ecx
  801bfa:	d3 e2                	shl    %cl,%edx
  801bfc:	89 55 f4             	mov    %edx,-0xc(%ebp)
	      n2 = n1 >> b;
  801bff:	89 f2                	mov    %esi,%edx
  801c01:	88 c1                	mov    %al,%cl
  801c03:	d3 ea                	shr    %cl,%edx
  801c05:	89 55 e8             	mov    %edx,-0x18(%ebp)
	      n1 = (n1 << bm) | (n0 >> b);
  801c08:	89 f2                	mov    %esi,%edx
  801c0a:	89 f9                	mov    %edi,%ecx
  801c0c:	d3 e2                	shl    %cl,%edx
  801c0e:	8b 75 f0             	mov    -0x10(%ebp),%esi
  801c11:	88 c1                	mov    %al,%cl
  801c13:	d3 ee                	shr    %cl,%esi
  801c15:	09 d6                	or     %edx,%esi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  801c17:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  801c1a:	89 f0                	mov    %esi,%eax
  801c1c:	89 ca                	mov    %ecx,%edx
  801c1e:	f7 75 ec             	divl   -0x14(%ebp)
  801c21:	89 d1                	mov    %edx,%ecx
  801c23:	89 c6                	mov    %eax,%esi
	      umul_ppmm (m1, m0, q0, d0);
  801c25:	f7 65 f4             	mull   -0xc(%ebp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801c28:	39 d1                	cmp    %edx,%ecx
  801c2a:	72 28                	jb     801c54 <__udivdi3+0x110>
  801c2c:	74 1a                	je     801c48 <__udivdi3+0x104>
  801c2e:	89 f7                	mov    %esi,%edi
  801c30:	31 f6                	xor    %esi,%esi
  801c32:	eb 80                	jmp    801bb4 <__udivdi3+0x70>
	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  801c34:	31 f6                	xor    %esi,%esi
  801c36:	bf 01 00 00 00       	mov    $0x1,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  801c3b:	89 f8                	mov    %edi,%eax
  801c3d:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801c3f:	83 c4 10             	add    $0x10,%esp
  801c42:	5e                   	pop    %esi
  801c43:	5f                   	pop    %edi
  801c44:	c9                   	leave  
  801c45:	c3                   	ret    
  801c46:	66 90                	xchg   %ax,%ax

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  801c48:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801c4b:	89 f9                	mov    %edi,%ecx
  801c4d:	d3 e2                	shl    %cl,%edx

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801c4f:	39 c2                	cmp    %eax,%edx
  801c51:	73 db                	jae    801c2e <__udivdi3+0xea>
  801c53:	90                   	nop
		{
		  q0--;
  801c54:	8d 7e ff             	lea    -0x1(%esi),%edi
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  801c57:	31 f6                	xor    %esi,%esi
  801c59:	e9 56 ff ff ff       	jmp    801bb4 <__udivdi3+0x70>
	...

00801c60 <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  801c60:	55                   	push   %ebp
  801c61:	89 e5                	mov    %esp,%ebp
  801c63:	57                   	push   %edi
  801c64:	56                   	push   %esi
  801c65:	83 ec 20             	sub    $0x20,%esp
  801c68:	8b 45 08             	mov    0x8(%ebp),%eax
  801c6b:	8b 4d 10             	mov    0x10(%ebp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  801c6e:	89 45 e8             	mov    %eax,-0x18(%ebp)
  801c71:	8b 75 0c             	mov    0xc(%ebp),%esi
  const DWunion dd = {.ll = d};
  801c74:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  801c77:	8b 7d 14             	mov    0x14(%ebp),%edi
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  801c7a:	89 45 f0             	mov    %eax,-0x10(%ebp)
  n1 = nn.s.high;
  801c7d:	89 f2                	mov    %esi,%edx

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  801c7f:	85 ff                	test   %edi,%edi
  801c81:	75 15                	jne    801c98 <__umoddi3+0x38>
    {
      if (d0 > n1)
  801c83:	39 f1                	cmp    %esi,%ecx
  801c85:	0f 86 99 00 00 00    	jbe    801d24 <__umoddi3+0xc4>
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801c8b:	f7 f1                	div    %ecx

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
  801c8d:	89 d0                	mov    %edx,%eax
  801c8f:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  801c91:	83 c4 20             	add    $0x20,%esp
  801c94:	5e                   	pop    %esi
  801c95:	5f                   	pop    %edi
  801c96:	c9                   	leave  
  801c97:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  801c98:	39 f7                	cmp    %esi,%edi
  801c9a:	0f 87 a4 00 00 00    	ja     801d44 <__umoddi3+0xe4>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  801ca0:	0f bd c7             	bsr    %edi,%eax
	  if (bm == 0)
  801ca3:	83 f0 1f             	xor    $0x1f,%eax
  801ca6:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801ca9:	0f 84 a1 00 00 00    	je     801d50 <__umoddi3+0xf0>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  801caf:	89 f8                	mov    %edi,%eax
  801cb1:	8a 4d ec             	mov    -0x14(%ebp),%cl
  801cb4:	d3 e0                	shl    %cl,%eax
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  801cb6:	bf 20 00 00 00       	mov    $0x20,%edi
  801cbb:	2b 7d ec             	sub    -0x14(%ebp),%edi

	      d1 = (d1 << bm) | (d0 >> b);
  801cbe:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801cc1:	89 f9                	mov    %edi,%ecx
  801cc3:	d3 ea                	shr    %cl,%edx
  801cc5:	09 c2                	or     %eax,%edx
  801cc7:	89 55 f0             	mov    %edx,-0x10(%ebp)
	      d0 = d0 << bm;
  801cca:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ccd:	8a 4d ec             	mov    -0x14(%ebp),%cl
  801cd0:	d3 e0                	shl    %cl,%eax
  801cd2:	89 45 f4             	mov    %eax,-0xc(%ebp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  801cd5:	89 f2                	mov    %esi,%edx
  801cd7:	d3 e2                	shl    %cl,%edx
	      n0 = n0 << bm;
  801cd9:	8b 45 e8             	mov    -0x18(%ebp),%eax
  801cdc:	d3 e0                	shl    %cl,%eax
  801cde:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  801ce1:	8b 45 e8             	mov    -0x18(%ebp),%eax
  801ce4:	89 f9                	mov    %edi,%ecx
  801ce6:	d3 e8                	shr    %cl,%eax
  801ce8:	09 d0                	or     %edx,%eax

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  801cea:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  801cec:	89 f2                	mov    %esi,%edx
  801cee:	f7 75 f0             	divl   -0x10(%ebp)
  801cf1:	89 d6                	mov    %edx,%esi
	      umul_ppmm (m1, m0, q0, d0);
  801cf3:	f7 65 f4             	mull   -0xc(%ebp)
  801cf6:	89 55 e8             	mov    %edx,-0x18(%ebp)
  801cf9:	89 c1                	mov    %eax,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801cfb:	39 d6                	cmp    %edx,%esi
  801cfd:	72 71                	jb     801d70 <__umoddi3+0x110>
  801cff:	74 7f                	je     801d80 <__umoddi3+0x120>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  801d01:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801d04:	29 c8                	sub    %ecx,%eax
  801d06:	19 d6                	sbb    %edx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
  801d08:	8a 4d ec             	mov    -0x14(%ebp),%cl
  801d0b:	d3 e8                	shr    %cl,%eax
  801d0d:	89 f2                	mov    %esi,%edx
  801d0f:	89 f9                	mov    %edi,%ecx
  801d11:	d3 e2                	shl    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
  801d13:	09 d0                	or     %edx,%eax
  801d15:	89 f2                	mov    %esi,%edx
  801d17:	8a 4d ec             	mov    -0x14(%ebp),%cl
  801d1a:	d3 ea                	shr    %cl,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  801d1c:	83 c4 20             	add    $0x20,%esp
  801d1f:	5e                   	pop    %esi
  801d20:	5f                   	pop    %edi
  801d21:	c9                   	leave  
  801d22:	c3                   	ret    
  801d23:	90                   	nop
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  801d24:	85 c9                	test   %ecx,%ecx
  801d26:	75 0b                	jne    801d33 <__umoddi3+0xd3>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  801d28:	b8 01 00 00 00       	mov    $0x1,%eax
  801d2d:	31 d2                	xor    %edx,%edx
  801d2f:	f7 f1                	div    %ecx
  801d31:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  801d33:	89 f0                	mov    %esi,%eax
  801d35:	31 d2                	xor    %edx,%edx
  801d37:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801d39:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801d3c:	f7 f1                	div    %ecx
  801d3e:	e9 4a ff ff ff       	jmp    801c8d <__umoddi3+0x2d>
  801d43:	90                   	nop
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
  801d44:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  801d46:	83 c4 20             	add    $0x20,%esp
  801d49:	5e                   	pop    %esi
  801d4a:	5f                   	pop    %edi
  801d4b:	c9                   	leave  
  801d4c:	c3                   	ret    
  801d4d:	8d 76 00             	lea    0x0(%esi),%esi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  801d50:	39 f7                	cmp    %esi,%edi
  801d52:	72 05                	jb     801d59 <__umoddi3+0xf9>
  801d54:	3b 4d f0             	cmp    -0x10(%ebp),%ecx
  801d57:	77 0c                	ja     801d65 <__umoddi3+0x105>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  801d59:	89 f2                	mov    %esi,%edx
  801d5b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801d5e:	29 c8                	sub    %ecx,%eax
  801d60:	19 fa                	sbb    %edi,%edx
  801d62:	89 45 f0             	mov    %eax,-0x10(%ebp)

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
  801d65:	8b 45 f0             	mov    -0x10(%ebp),%eax
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  801d68:	83 c4 20             	add    $0x20,%esp
  801d6b:	5e                   	pop    %esi
  801d6c:	5f                   	pop    %edi
  801d6d:	c9                   	leave  
  801d6e:	c3                   	ret    
  801d6f:	90                   	nop
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  801d70:	8b 55 e8             	mov    -0x18(%ebp),%edx
  801d73:	89 c1                	mov    %eax,%ecx
  801d75:	2b 4d f4             	sub    -0xc(%ebp),%ecx
  801d78:	1b 55 f0             	sbb    -0x10(%ebp),%edx
  801d7b:	eb 84                	jmp    801d01 <__umoddi3+0xa1>
  801d7d:	8d 76 00             	lea    0x0(%esi),%esi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801d80:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  801d83:	72 eb                	jb     801d70 <__umoddi3+0x110>
  801d85:	89 f2                	mov    %esi,%edx
  801d87:	e9 75 ff ff ff       	jmp    801d01 <__umoddi3+0xa1>
