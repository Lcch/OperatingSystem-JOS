
obj/user/faultbadhandler.debug:     file format elf32-i386


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
	sys_env_set_pgfault_upcall(0, (void*) 0xDeadBeef);
  800048:	83 c4 08             	add    $0x8,%esp
  80004b:	68 ef be ad de       	push   $0xdeadbeef
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
  8000be:	e8 87 04 00 00       	call   80054a <close_all>
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
  800106:	68 ca 1d 80 00       	push   $0x801dca
  80010b:	6a 42                	push   $0x42
  80010d:	68 e7 1d 80 00       	push   $0x801de7
  800112:	e8 dd 0e 00 00       	call   800ff4 <_panic>

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

00800318 <sys_exec>:

int
sys_exec(uint32_t eip, uint32_t esp, void * ph, uint32_t elf_phnum)
{
  800318:	55                   	push   %ebp
  800319:	89 e5                	mov    %esp,%ebp
  80031b:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_exec, 0, eip, esp, (uint32_t)ph, elf_phnum, 0);
  80031e:	6a 00                	push   $0x0
  800320:	ff 75 14             	pushl  0x14(%ebp)
  800323:	ff 75 10             	pushl  0x10(%ebp)
  800326:	ff 75 0c             	pushl  0xc(%ebp)
  800329:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80032c:	ba 00 00 00 00       	mov    $0x0,%edx
  800331:	b8 0f 00 00 00       	mov    $0xf,%eax
  800336:	e8 99 fd ff ff       	call   8000d4 <syscall>
  80033b:	c9                   	leave  
  80033c:	c3                   	ret    
  80033d:	00 00                	add    %al,(%eax)
	...

00800340 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800340:	55                   	push   %ebp
  800341:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800343:	8b 45 08             	mov    0x8(%ebp),%eax
  800346:	05 00 00 00 30       	add    $0x30000000,%eax
  80034b:	c1 e8 0c             	shr    $0xc,%eax
}
  80034e:	c9                   	leave  
  80034f:	c3                   	ret    

00800350 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800350:	55                   	push   %ebp
  800351:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  800353:	ff 75 08             	pushl  0x8(%ebp)
  800356:	e8 e5 ff ff ff       	call   800340 <fd2num>
  80035b:	83 c4 04             	add    $0x4,%esp
  80035e:	05 20 00 0d 00       	add    $0xd0020,%eax
  800363:	c1 e0 0c             	shl    $0xc,%eax
}
  800366:	c9                   	leave  
  800367:	c3                   	ret    

00800368 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800368:	55                   	push   %ebp
  800369:	89 e5                	mov    %esp,%ebp
  80036b:	53                   	push   %ebx
  80036c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  80036f:	a1 00 dd 7b ef       	mov    0xef7bdd00,%eax
  800374:	a8 01                	test   $0x1,%al
  800376:	74 34                	je     8003ac <fd_alloc+0x44>
  800378:	a1 00 00 74 ef       	mov    0xef740000,%eax
  80037d:	a8 01                	test   $0x1,%al
  80037f:	74 32                	je     8003b3 <fd_alloc+0x4b>
  800381:	b8 00 10 00 d0       	mov    $0xd0001000,%eax
  800386:	89 c1                	mov    %eax,%ecx
  800388:	89 c2                	mov    %eax,%edx
  80038a:	c1 ea 16             	shr    $0x16,%edx
  80038d:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800394:	f6 c2 01             	test   $0x1,%dl
  800397:	74 1f                	je     8003b8 <fd_alloc+0x50>
  800399:	89 c2                	mov    %eax,%edx
  80039b:	c1 ea 0c             	shr    $0xc,%edx
  80039e:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8003a5:	f6 c2 01             	test   $0x1,%dl
  8003a8:	75 17                	jne    8003c1 <fd_alloc+0x59>
  8003aa:	eb 0c                	jmp    8003b8 <fd_alloc+0x50>
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  8003ac:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
  8003b1:	eb 05                	jmp    8003b8 <fd_alloc+0x50>
  8003b3:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
  8003b8:	89 0b                	mov    %ecx,(%ebx)
			return 0;
  8003ba:	b8 00 00 00 00       	mov    $0x0,%eax
  8003bf:	eb 17                	jmp    8003d8 <fd_alloc+0x70>
  8003c1:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8003c6:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8003cb:	75 b9                	jne    800386 <fd_alloc+0x1e>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8003cd:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_MAX_OPEN;
  8003d3:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8003d8:	5b                   	pop    %ebx
  8003d9:	c9                   	leave  
  8003da:	c3                   	ret    

008003db <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8003db:	55                   	push   %ebp
  8003dc:	89 e5                	mov    %esp,%ebp
  8003de:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8003e1:	83 f8 1f             	cmp    $0x1f,%eax
  8003e4:	77 36                	ja     80041c <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8003e6:	05 00 00 0d 00       	add    $0xd0000,%eax
  8003eb:	c1 e0 0c             	shl    $0xc,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8003ee:	89 c2                	mov    %eax,%edx
  8003f0:	c1 ea 16             	shr    $0x16,%edx
  8003f3:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8003fa:	f6 c2 01             	test   $0x1,%dl
  8003fd:	74 24                	je     800423 <fd_lookup+0x48>
  8003ff:	89 c2                	mov    %eax,%edx
  800401:	c1 ea 0c             	shr    $0xc,%edx
  800404:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80040b:	f6 c2 01             	test   $0x1,%dl
  80040e:	74 1a                	je     80042a <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800410:	8b 55 0c             	mov    0xc(%ebp),%edx
  800413:	89 02                	mov    %eax,(%edx)
	return 0;
  800415:	b8 00 00 00 00       	mov    $0x0,%eax
  80041a:	eb 13                	jmp    80042f <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80041c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800421:	eb 0c                	jmp    80042f <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800423:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800428:	eb 05                	jmp    80042f <fd_lookup+0x54>
  80042a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  80042f:	c9                   	leave  
  800430:	c3                   	ret    

00800431 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800431:	55                   	push   %ebp
  800432:	89 e5                	mov    %esp,%ebp
  800434:	53                   	push   %ebx
  800435:	83 ec 04             	sub    $0x4,%esp
  800438:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80043b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
		if (devtab[i]->dev_id == dev_id) {
  80043e:	39 0d 04 30 80 00    	cmp    %ecx,0x803004
  800444:	74 0d                	je     800453 <dev_lookup+0x22>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800446:	b8 00 00 00 00       	mov    $0x0,%eax
  80044b:	eb 14                	jmp    800461 <dev_lookup+0x30>
		if (devtab[i]->dev_id == dev_id) {
  80044d:	39 0a                	cmp    %ecx,(%edx)
  80044f:	75 10                	jne    800461 <dev_lookup+0x30>
  800451:	eb 05                	jmp    800458 <dev_lookup+0x27>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800453:	ba 04 30 80 00       	mov    $0x803004,%edx
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
  800458:	89 13                	mov    %edx,(%ebx)
			return 0;
  80045a:	b8 00 00 00 00       	mov    $0x0,%eax
  80045f:	eb 31                	jmp    800492 <dev_lookup+0x61>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800461:	40                   	inc    %eax
  800462:	8b 14 85 74 1e 80 00 	mov    0x801e74(,%eax,4),%edx
  800469:	85 d2                	test   %edx,%edx
  80046b:	75 e0                	jne    80044d <dev_lookup+0x1c>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  80046d:	a1 04 40 80 00       	mov    0x804004,%eax
  800472:	8b 40 48             	mov    0x48(%eax),%eax
  800475:	83 ec 04             	sub    $0x4,%esp
  800478:	51                   	push   %ecx
  800479:	50                   	push   %eax
  80047a:	68 f8 1d 80 00       	push   $0x801df8
  80047f:	e8 48 0c 00 00       	call   8010cc <cprintf>
	*dev = 0;
  800484:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_INVAL;
  80048a:	83 c4 10             	add    $0x10,%esp
  80048d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800492:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800495:	c9                   	leave  
  800496:	c3                   	ret    

00800497 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800497:	55                   	push   %ebp
  800498:	89 e5                	mov    %esp,%ebp
  80049a:	56                   	push   %esi
  80049b:	53                   	push   %ebx
  80049c:	83 ec 20             	sub    $0x20,%esp
  80049f:	8b 75 08             	mov    0x8(%ebp),%esi
  8004a2:	8a 45 0c             	mov    0xc(%ebp),%al
  8004a5:	88 45 e7             	mov    %al,-0x19(%ebp)
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8004a8:	56                   	push   %esi
  8004a9:	e8 92 fe ff ff       	call   800340 <fd2num>
  8004ae:	8d 55 f4             	lea    -0xc(%ebp),%edx
  8004b1:	89 14 24             	mov    %edx,(%esp)
  8004b4:	50                   	push   %eax
  8004b5:	e8 21 ff ff ff       	call   8003db <fd_lookup>
  8004ba:	89 c3                	mov    %eax,%ebx
  8004bc:	83 c4 08             	add    $0x8,%esp
  8004bf:	85 c0                	test   %eax,%eax
  8004c1:	78 05                	js     8004c8 <fd_close+0x31>
	    || fd != fd2)
  8004c3:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8004c6:	74 0d                	je     8004d5 <fd_close+0x3e>
		return (must_exist ? r : 0);
  8004c8:	80 7d e7 00          	cmpb   $0x0,-0x19(%ebp)
  8004cc:	75 48                	jne    800516 <fd_close+0x7f>
  8004ce:	bb 00 00 00 00       	mov    $0x0,%ebx
  8004d3:	eb 41                	jmp    800516 <fd_close+0x7f>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8004d5:	83 ec 08             	sub    $0x8,%esp
  8004d8:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8004db:	50                   	push   %eax
  8004dc:	ff 36                	pushl  (%esi)
  8004de:	e8 4e ff ff ff       	call   800431 <dev_lookup>
  8004e3:	89 c3                	mov    %eax,%ebx
  8004e5:	83 c4 10             	add    $0x10,%esp
  8004e8:	85 c0                	test   %eax,%eax
  8004ea:	78 1c                	js     800508 <fd_close+0x71>
		if (dev->dev_close)
  8004ec:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8004ef:	8b 40 10             	mov    0x10(%eax),%eax
  8004f2:	85 c0                	test   %eax,%eax
  8004f4:	74 0d                	je     800503 <fd_close+0x6c>
			r = (*dev->dev_close)(fd);
  8004f6:	83 ec 0c             	sub    $0xc,%esp
  8004f9:	56                   	push   %esi
  8004fa:	ff d0                	call   *%eax
  8004fc:	89 c3                	mov    %eax,%ebx
  8004fe:	83 c4 10             	add    $0x10,%esp
  800501:	eb 05                	jmp    800508 <fd_close+0x71>
		else
			r = 0;
  800503:	bb 00 00 00 00       	mov    $0x0,%ebx
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  800508:	83 ec 08             	sub    $0x8,%esp
  80050b:	56                   	push   %esi
  80050c:	6a 00                	push   $0x0
  80050e:	e8 0f fd ff ff       	call   800222 <sys_page_unmap>
	return r;
  800513:	83 c4 10             	add    $0x10,%esp
}
  800516:	89 d8                	mov    %ebx,%eax
  800518:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80051b:	5b                   	pop    %ebx
  80051c:	5e                   	pop    %esi
  80051d:	c9                   	leave  
  80051e:	c3                   	ret    

0080051f <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  80051f:	55                   	push   %ebp
  800520:	89 e5                	mov    %esp,%ebp
  800522:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800525:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800528:	50                   	push   %eax
  800529:	ff 75 08             	pushl  0x8(%ebp)
  80052c:	e8 aa fe ff ff       	call   8003db <fd_lookup>
  800531:	83 c4 08             	add    $0x8,%esp
  800534:	85 c0                	test   %eax,%eax
  800536:	78 10                	js     800548 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  800538:	83 ec 08             	sub    $0x8,%esp
  80053b:	6a 01                	push   $0x1
  80053d:	ff 75 f4             	pushl  -0xc(%ebp)
  800540:	e8 52 ff ff ff       	call   800497 <fd_close>
  800545:	83 c4 10             	add    $0x10,%esp
}
  800548:	c9                   	leave  
  800549:	c3                   	ret    

0080054a <close_all>:

void
close_all(void)
{
  80054a:	55                   	push   %ebp
  80054b:	89 e5                	mov    %esp,%ebp
  80054d:	53                   	push   %ebx
  80054e:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800551:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  800556:	83 ec 0c             	sub    $0xc,%esp
  800559:	53                   	push   %ebx
  80055a:	e8 c0 ff ff ff       	call   80051f <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  80055f:	43                   	inc    %ebx
  800560:	83 c4 10             	add    $0x10,%esp
  800563:	83 fb 20             	cmp    $0x20,%ebx
  800566:	75 ee                	jne    800556 <close_all+0xc>
		close(i);
}
  800568:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80056b:	c9                   	leave  
  80056c:	c3                   	ret    

0080056d <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  80056d:	55                   	push   %ebp
  80056e:	89 e5                	mov    %esp,%ebp
  800570:	57                   	push   %edi
  800571:	56                   	push   %esi
  800572:	53                   	push   %ebx
  800573:	83 ec 2c             	sub    $0x2c,%esp
  800576:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  800579:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80057c:	50                   	push   %eax
  80057d:	ff 75 08             	pushl  0x8(%ebp)
  800580:	e8 56 fe ff ff       	call   8003db <fd_lookup>
  800585:	89 c3                	mov    %eax,%ebx
  800587:	83 c4 08             	add    $0x8,%esp
  80058a:	85 c0                	test   %eax,%eax
  80058c:	0f 88 c0 00 00 00    	js     800652 <dup+0xe5>
		return r;
	close(newfdnum);
  800592:	83 ec 0c             	sub    $0xc,%esp
  800595:	57                   	push   %edi
  800596:	e8 84 ff ff ff       	call   80051f <close>

	newfd = INDEX2FD(newfdnum);
  80059b:	8d b7 00 00 0d 00    	lea    0xd0000(%edi),%esi
  8005a1:	c1 e6 0c             	shl    $0xc,%esi
	ova = fd2data(oldfd);
  8005a4:	83 c4 04             	add    $0x4,%esp
  8005a7:	ff 75 e4             	pushl  -0x1c(%ebp)
  8005aa:	e8 a1 fd ff ff       	call   800350 <fd2data>
  8005af:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  8005b1:	89 34 24             	mov    %esi,(%esp)
  8005b4:	e8 97 fd ff ff       	call   800350 <fd2data>
  8005b9:	83 c4 10             	add    $0x10,%esp
  8005bc:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8005bf:	89 d8                	mov    %ebx,%eax
  8005c1:	c1 e8 16             	shr    $0x16,%eax
  8005c4:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8005cb:	a8 01                	test   $0x1,%al
  8005cd:	74 37                	je     800606 <dup+0x99>
  8005cf:	89 d8                	mov    %ebx,%eax
  8005d1:	c1 e8 0c             	shr    $0xc,%eax
  8005d4:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8005db:	f6 c2 01             	test   $0x1,%dl
  8005de:	74 26                	je     800606 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8005e0:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8005e7:	83 ec 0c             	sub    $0xc,%esp
  8005ea:	25 07 0e 00 00       	and    $0xe07,%eax
  8005ef:	50                   	push   %eax
  8005f0:	ff 75 d4             	pushl  -0x2c(%ebp)
  8005f3:	6a 00                	push   $0x0
  8005f5:	53                   	push   %ebx
  8005f6:	6a 00                	push   $0x0
  8005f8:	e8 ff fb ff ff       	call   8001fc <sys_page_map>
  8005fd:	89 c3                	mov    %eax,%ebx
  8005ff:	83 c4 20             	add    $0x20,%esp
  800602:	85 c0                	test   %eax,%eax
  800604:	78 2d                	js     800633 <dup+0xc6>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  800606:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800609:	89 c2                	mov    %eax,%edx
  80060b:	c1 ea 0c             	shr    $0xc,%edx
  80060e:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800615:	83 ec 0c             	sub    $0xc,%esp
  800618:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  80061e:	52                   	push   %edx
  80061f:	56                   	push   %esi
  800620:	6a 00                	push   $0x0
  800622:	50                   	push   %eax
  800623:	6a 00                	push   $0x0
  800625:	e8 d2 fb ff ff       	call   8001fc <sys_page_map>
  80062a:	89 c3                	mov    %eax,%ebx
  80062c:	83 c4 20             	add    $0x20,%esp
  80062f:	85 c0                	test   %eax,%eax
  800631:	79 1d                	jns    800650 <dup+0xe3>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  800633:	83 ec 08             	sub    $0x8,%esp
  800636:	56                   	push   %esi
  800637:	6a 00                	push   $0x0
  800639:	e8 e4 fb ff ff       	call   800222 <sys_page_unmap>
	sys_page_unmap(0, nva);
  80063e:	83 c4 08             	add    $0x8,%esp
  800641:	ff 75 d4             	pushl  -0x2c(%ebp)
  800644:	6a 00                	push   $0x0
  800646:	e8 d7 fb ff ff       	call   800222 <sys_page_unmap>
	return r;
  80064b:	83 c4 10             	add    $0x10,%esp
  80064e:	eb 02                	jmp    800652 <dup+0xe5>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
		goto err;

	return newfdnum;
  800650:	89 fb                	mov    %edi,%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  800652:	89 d8                	mov    %ebx,%eax
  800654:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800657:	5b                   	pop    %ebx
  800658:	5e                   	pop    %esi
  800659:	5f                   	pop    %edi
  80065a:	c9                   	leave  
  80065b:	c3                   	ret    

0080065c <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80065c:	55                   	push   %ebp
  80065d:	89 e5                	mov    %esp,%ebp
  80065f:	53                   	push   %ebx
  800660:	83 ec 14             	sub    $0x14,%esp
  800663:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800666:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800669:	50                   	push   %eax
  80066a:	53                   	push   %ebx
  80066b:	e8 6b fd ff ff       	call   8003db <fd_lookup>
  800670:	83 c4 08             	add    $0x8,%esp
  800673:	85 c0                	test   %eax,%eax
  800675:	78 67                	js     8006de <read+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800677:	83 ec 08             	sub    $0x8,%esp
  80067a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80067d:	50                   	push   %eax
  80067e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800681:	ff 30                	pushl  (%eax)
  800683:	e8 a9 fd ff ff       	call   800431 <dev_lookup>
  800688:	83 c4 10             	add    $0x10,%esp
  80068b:	85 c0                	test   %eax,%eax
  80068d:	78 4f                	js     8006de <read+0x82>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80068f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800692:	8b 50 08             	mov    0x8(%eax),%edx
  800695:	83 e2 03             	and    $0x3,%edx
  800698:	83 fa 01             	cmp    $0x1,%edx
  80069b:	75 21                	jne    8006be <read+0x62>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80069d:	a1 04 40 80 00       	mov    0x804004,%eax
  8006a2:	8b 40 48             	mov    0x48(%eax),%eax
  8006a5:	83 ec 04             	sub    $0x4,%esp
  8006a8:	53                   	push   %ebx
  8006a9:	50                   	push   %eax
  8006aa:	68 39 1e 80 00       	push   $0x801e39
  8006af:	e8 18 0a 00 00       	call   8010cc <cprintf>
		return -E_INVAL;
  8006b4:	83 c4 10             	add    $0x10,%esp
  8006b7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8006bc:	eb 20                	jmp    8006de <read+0x82>
	}
	if (!dev->dev_read)
  8006be:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8006c1:	8b 52 08             	mov    0x8(%edx),%edx
  8006c4:	85 d2                	test   %edx,%edx
  8006c6:	74 11                	je     8006d9 <read+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8006c8:	83 ec 04             	sub    $0x4,%esp
  8006cb:	ff 75 10             	pushl  0x10(%ebp)
  8006ce:	ff 75 0c             	pushl  0xc(%ebp)
  8006d1:	50                   	push   %eax
  8006d2:	ff d2                	call   *%edx
  8006d4:	83 c4 10             	add    $0x10,%esp
  8006d7:	eb 05                	jmp    8006de <read+0x82>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8006d9:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_read)(fd, buf, n);
}
  8006de:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8006e1:	c9                   	leave  
  8006e2:	c3                   	ret    

008006e3 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8006e3:	55                   	push   %ebp
  8006e4:	89 e5                	mov    %esp,%ebp
  8006e6:	57                   	push   %edi
  8006e7:	56                   	push   %esi
  8006e8:	53                   	push   %ebx
  8006e9:	83 ec 0c             	sub    $0xc,%esp
  8006ec:	8b 7d 08             	mov    0x8(%ebp),%edi
  8006ef:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8006f2:	85 f6                	test   %esi,%esi
  8006f4:	74 31                	je     800727 <readn+0x44>
  8006f6:	b8 00 00 00 00       	mov    $0x0,%eax
  8006fb:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = read(fdnum, (char*)buf + tot, n - tot);
  800700:	83 ec 04             	sub    $0x4,%esp
  800703:	89 f2                	mov    %esi,%edx
  800705:	29 c2                	sub    %eax,%edx
  800707:	52                   	push   %edx
  800708:	03 45 0c             	add    0xc(%ebp),%eax
  80070b:	50                   	push   %eax
  80070c:	57                   	push   %edi
  80070d:	e8 4a ff ff ff       	call   80065c <read>
		if (m < 0)
  800712:	83 c4 10             	add    $0x10,%esp
  800715:	85 c0                	test   %eax,%eax
  800717:	78 17                	js     800730 <readn+0x4d>
			return m;
		if (m == 0)
  800719:	85 c0                	test   %eax,%eax
  80071b:	74 11                	je     80072e <readn+0x4b>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80071d:	01 c3                	add    %eax,%ebx
  80071f:	89 d8                	mov    %ebx,%eax
  800721:	39 f3                	cmp    %esi,%ebx
  800723:	72 db                	jb     800700 <readn+0x1d>
  800725:	eb 09                	jmp    800730 <readn+0x4d>
  800727:	b8 00 00 00 00       	mov    $0x0,%eax
  80072c:	eb 02                	jmp    800730 <readn+0x4d>
		m = read(fdnum, (char*)buf + tot, n - tot);
		if (m < 0)
			return m;
		if (m == 0)
  80072e:	89 d8                	mov    %ebx,%eax
			break;
	}
	return tot;
}
  800730:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800733:	5b                   	pop    %ebx
  800734:	5e                   	pop    %esi
  800735:	5f                   	pop    %edi
  800736:	c9                   	leave  
  800737:	c3                   	ret    

00800738 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  800738:	55                   	push   %ebp
  800739:	89 e5                	mov    %esp,%ebp
  80073b:	53                   	push   %ebx
  80073c:	83 ec 14             	sub    $0x14,%esp
  80073f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800742:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800745:	50                   	push   %eax
  800746:	53                   	push   %ebx
  800747:	e8 8f fc ff ff       	call   8003db <fd_lookup>
  80074c:	83 c4 08             	add    $0x8,%esp
  80074f:	85 c0                	test   %eax,%eax
  800751:	78 62                	js     8007b5 <write+0x7d>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800753:	83 ec 08             	sub    $0x8,%esp
  800756:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800759:	50                   	push   %eax
  80075a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80075d:	ff 30                	pushl  (%eax)
  80075f:	e8 cd fc ff ff       	call   800431 <dev_lookup>
  800764:	83 c4 10             	add    $0x10,%esp
  800767:	85 c0                	test   %eax,%eax
  800769:	78 4a                	js     8007b5 <write+0x7d>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80076b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80076e:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  800772:	75 21                	jne    800795 <write+0x5d>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  800774:	a1 04 40 80 00       	mov    0x804004,%eax
  800779:	8b 40 48             	mov    0x48(%eax),%eax
  80077c:	83 ec 04             	sub    $0x4,%esp
  80077f:	53                   	push   %ebx
  800780:	50                   	push   %eax
  800781:	68 55 1e 80 00       	push   $0x801e55
  800786:	e8 41 09 00 00       	call   8010cc <cprintf>
		return -E_INVAL;
  80078b:	83 c4 10             	add    $0x10,%esp
  80078e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800793:	eb 20                	jmp    8007b5 <write+0x7d>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  800795:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800798:	8b 52 0c             	mov    0xc(%edx),%edx
  80079b:	85 d2                	test   %edx,%edx
  80079d:	74 11                	je     8007b0 <write+0x78>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80079f:	83 ec 04             	sub    $0x4,%esp
  8007a2:	ff 75 10             	pushl  0x10(%ebp)
  8007a5:	ff 75 0c             	pushl  0xc(%ebp)
  8007a8:	50                   	push   %eax
  8007a9:	ff d2                	call   *%edx
  8007ab:	83 c4 10             	add    $0x10,%esp
  8007ae:	eb 05                	jmp    8007b5 <write+0x7d>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8007b0:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  8007b5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007b8:	c9                   	leave  
  8007b9:	c3                   	ret    

008007ba <seek>:

int
seek(int fdnum, off_t offset)
{
  8007ba:	55                   	push   %ebp
  8007bb:	89 e5                	mov    %esp,%ebp
  8007bd:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8007c0:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8007c3:	50                   	push   %eax
  8007c4:	ff 75 08             	pushl  0x8(%ebp)
  8007c7:	e8 0f fc ff ff       	call   8003db <fd_lookup>
  8007cc:	83 c4 08             	add    $0x8,%esp
  8007cf:	85 c0                	test   %eax,%eax
  8007d1:	78 0e                	js     8007e1 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8007d3:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8007d6:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007d9:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8007dc:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8007e1:	c9                   	leave  
  8007e2:	c3                   	ret    

008007e3 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8007e3:	55                   	push   %ebp
  8007e4:	89 e5                	mov    %esp,%ebp
  8007e6:	53                   	push   %ebx
  8007e7:	83 ec 14             	sub    $0x14,%esp
  8007ea:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8007ed:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8007f0:	50                   	push   %eax
  8007f1:	53                   	push   %ebx
  8007f2:	e8 e4 fb ff ff       	call   8003db <fd_lookup>
  8007f7:	83 c4 08             	add    $0x8,%esp
  8007fa:	85 c0                	test   %eax,%eax
  8007fc:	78 5f                	js     80085d <ftruncate+0x7a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8007fe:	83 ec 08             	sub    $0x8,%esp
  800801:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800804:	50                   	push   %eax
  800805:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800808:	ff 30                	pushl  (%eax)
  80080a:	e8 22 fc ff ff       	call   800431 <dev_lookup>
  80080f:	83 c4 10             	add    $0x10,%esp
  800812:	85 c0                	test   %eax,%eax
  800814:	78 47                	js     80085d <ftruncate+0x7a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800816:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800819:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80081d:	75 21                	jne    800840 <ftruncate+0x5d>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  80081f:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  800824:	8b 40 48             	mov    0x48(%eax),%eax
  800827:	83 ec 04             	sub    $0x4,%esp
  80082a:	53                   	push   %ebx
  80082b:	50                   	push   %eax
  80082c:	68 18 1e 80 00       	push   $0x801e18
  800831:	e8 96 08 00 00       	call   8010cc <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  800836:	83 c4 10             	add    $0x10,%esp
  800839:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80083e:	eb 1d                	jmp    80085d <ftruncate+0x7a>
	}
	if (!dev->dev_trunc)
  800840:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800843:	8b 52 18             	mov    0x18(%edx),%edx
  800846:	85 d2                	test   %edx,%edx
  800848:	74 0e                	je     800858 <ftruncate+0x75>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80084a:	83 ec 08             	sub    $0x8,%esp
  80084d:	ff 75 0c             	pushl  0xc(%ebp)
  800850:	50                   	push   %eax
  800851:	ff d2                	call   *%edx
  800853:	83 c4 10             	add    $0x10,%esp
  800856:	eb 05                	jmp    80085d <ftruncate+0x7a>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  800858:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  80085d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800860:	c9                   	leave  
  800861:	c3                   	ret    

00800862 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  800862:	55                   	push   %ebp
  800863:	89 e5                	mov    %esp,%ebp
  800865:	53                   	push   %ebx
  800866:	83 ec 14             	sub    $0x14,%esp
  800869:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80086c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80086f:	50                   	push   %eax
  800870:	ff 75 08             	pushl  0x8(%ebp)
  800873:	e8 63 fb ff ff       	call   8003db <fd_lookup>
  800878:	83 c4 08             	add    $0x8,%esp
  80087b:	85 c0                	test   %eax,%eax
  80087d:	78 52                	js     8008d1 <fstat+0x6f>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80087f:	83 ec 08             	sub    $0x8,%esp
  800882:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800885:	50                   	push   %eax
  800886:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800889:	ff 30                	pushl  (%eax)
  80088b:	e8 a1 fb ff ff       	call   800431 <dev_lookup>
  800890:	83 c4 10             	add    $0x10,%esp
  800893:	85 c0                	test   %eax,%eax
  800895:	78 3a                	js     8008d1 <fstat+0x6f>
		return r;
	if (!dev->dev_stat)
  800897:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80089a:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  80089e:	74 2c                	je     8008cc <fstat+0x6a>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8008a0:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8008a3:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8008aa:	00 00 00 
	stat->st_isdir = 0;
  8008ad:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8008b4:	00 00 00 
	stat->st_dev = dev;
  8008b7:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8008bd:	83 ec 08             	sub    $0x8,%esp
  8008c0:	53                   	push   %ebx
  8008c1:	ff 75 f0             	pushl  -0x10(%ebp)
  8008c4:	ff 50 14             	call   *0x14(%eax)
  8008c7:	83 c4 10             	add    $0x10,%esp
  8008ca:	eb 05                	jmp    8008d1 <fstat+0x6f>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8008cc:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8008d1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8008d4:	c9                   	leave  
  8008d5:	c3                   	ret    

008008d6 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8008d6:	55                   	push   %ebp
  8008d7:	89 e5                	mov    %esp,%ebp
  8008d9:	56                   	push   %esi
  8008da:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8008db:	83 ec 08             	sub    $0x8,%esp
  8008de:	6a 00                	push   $0x0
  8008e0:	ff 75 08             	pushl  0x8(%ebp)
  8008e3:	e8 78 01 00 00       	call   800a60 <open>
  8008e8:	89 c3                	mov    %eax,%ebx
  8008ea:	83 c4 10             	add    $0x10,%esp
  8008ed:	85 c0                	test   %eax,%eax
  8008ef:	78 1b                	js     80090c <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8008f1:	83 ec 08             	sub    $0x8,%esp
  8008f4:	ff 75 0c             	pushl  0xc(%ebp)
  8008f7:	50                   	push   %eax
  8008f8:	e8 65 ff ff ff       	call   800862 <fstat>
  8008fd:	89 c6                	mov    %eax,%esi
	close(fd);
  8008ff:	89 1c 24             	mov    %ebx,(%esp)
  800902:	e8 18 fc ff ff       	call   80051f <close>
	return r;
  800907:	83 c4 10             	add    $0x10,%esp
  80090a:	89 f3                	mov    %esi,%ebx
}
  80090c:	89 d8                	mov    %ebx,%eax
  80090e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800911:	5b                   	pop    %ebx
  800912:	5e                   	pop    %esi
  800913:	c9                   	leave  
  800914:	c3                   	ret    
  800915:	00 00                	add    %al,(%eax)
	...

00800918 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  800918:	55                   	push   %ebp
  800919:	89 e5                	mov    %esp,%ebp
  80091b:	56                   	push   %esi
  80091c:	53                   	push   %ebx
  80091d:	89 c3                	mov    %eax,%ebx
  80091f:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  800921:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  800928:	75 12                	jne    80093c <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  80092a:	83 ec 0c             	sub    $0xc,%esp
  80092d:	6a 01                	push   $0x1
  80092f:	e8 96 11 00 00       	call   801aca <ipc_find_env>
  800934:	a3 00 40 80 00       	mov    %eax,0x804000
  800939:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  80093c:	6a 07                	push   $0x7
  80093e:	68 00 50 80 00       	push   $0x805000
  800943:	53                   	push   %ebx
  800944:	ff 35 00 40 80 00    	pushl  0x804000
  80094a:	e8 26 11 00 00       	call   801a75 <ipc_send>
	
	return ipc_recv(NULL, dstva, NULL);
  80094f:	83 c4 0c             	add    $0xc,%esp
  800952:	6a 00                	push   $0x0
  800954:	56                   	push   %esi
  800955:	6a 00                	push   $0x0
  800957:	e8 a4 10 00 00       	call   801a00 <ipc_recv>
}
  80095c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80095f:	5b                   	pop    %ebx
  800960:	5e                   	pop    %esi
  800961:	c9                   	leave  
  800962:	c3                   	ret    

00800963 <devfile_stat>:
}


static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  800963:	55                   	push   %ebp
  800964:	89 e5                	mov    %esp,%ebp
  800966:	53                   	push   %ebx
  800967:	83 ec 04             	sub    $0x4,%esp
  80096a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  80096d:	8b 45 08             	mov    0x8(%ebp),%eax
  800970:	8b 40 0c             	mov    0xc(%eax),%eax
  800973:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0) {
  800978:	ba 00 00 00 00       	mov    $0x0,%edx
  80097d:	b8 05 00 00 00       	mov    $0x5,%eax
  800982:	e8 91 ff ff ff       	call   800918 <fsipc>
  800987:	85 c0                	test   %eax,%eax
  800989:	78 2c                	js     8009b7 <devfile_stat+0x54>
		return r;
	}
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  80098b:	83 ec 08             	sub    $0x8,%esp
  80098e:	68 00 50 80 00       	push   $0x805000
  800993:	53                   	push   %ebx
  800994:	e8 e9 0c 00 00       	call   801682 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  800999:	a1 80 50 80 00       	mov    0x805080,%eax
  80099e:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8009a4:	a1 84 50 80 00       	mov    0x805084,%eax
  8009a9:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8009af:	83 c4 10             	add    $0x10,%esp
  8009b2:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009b7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8009ba:	c9                   	leave  
  8009bb:	c3                   	ret    

008009bc <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8009bc:	55                   	push   %ebp
  8009bd:	89 e5                	mov    %esp,%ebp
  8009bf:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8009c2:	8b 45 08             	mov    0x8(%ebp),%eax
  8009c5:	8b 40 0c             	mov    0xc(%eax),%eax
  8009c8:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8009cd:	ba 00 00 00 00       	mov    $0x0,%edx
  8009d2:	b8 06 00 00 00       	mov    $0x6,%eax
  8009d7:	e8 3c ff ff ff       	call   800918 <fsipc>
}
  8009dc:	c9                   	leave  
  8009dd:	c3                   	ret    

008009de <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  8009de:	55                   	push   %ebp
  8009df:	89 e5                	mov    %esp,%ebp
  8009e1:	56                   	push   %esi
  8009e2:	53                   	push   %ebx
  8009e3:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8009e6:	8b 45 08             	mov    0x8(%ebp),%eax
  8009e9:	8b 40 0c             	mov    0xc(%eax),%eax
  8009ec:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  8009f1:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8009f7:	ba 00 00 00 00       	mov    $0x0,%edx
  8009fc:	b8 03 00 00 00       	mov    $0x3,%eax
  800a01:	e8 12 ff ff ff       	call   800918 <fsipc>
  800a06:	89 c3                	mov    %eax,%ebx
  800a08:	85 c0                	test   %eax,%eax
  800a0a:	78 4b                	js     800a57 <devfile_read+0x79>
		return r;
	assert(r <= n);
  800a0c:	39 c6                	cmp    %eax,%esi
  800a0e:	73 16                	jae    800a26 <devfile_read+0x48>
  800a10:	68 84 1e 80 00       	push   $0x801e84
  800a15:	68 8b 1e 80 00       	push   $0x801e8b
  800a1a:	6a 7d                	push   $0x7d
  800a1c:	68 a0 1e 80 00       	push   $0x801ea0
  800a21:	e8 ce 05 00 00       	call   800ff4 <_panic>
	assert(r <= PGSIZE);
  800a26:	3d 00 10 00 00       	cmp    $0x1000,%eax
  800a2b:	7e 16                	jle    800a43 <devfile_read+0x65>
  800a2d:	68 ab 1e 80 00       	push   $0x801eab
  800a32:	68 8b 1e 80 00       	push   $0x801e8b
  800a37:	6a 7e                	push   $0x7e
  800a39:	68 a0 1e 80 00       	push   $0x801ea0
  800a3e:	e8 b1 05 00 00       	call   800ff4 <_panic>
	memmove(buf, &fsipcbuf, r);
  800a43:	83 ec 04             	sub    $0x4,%esp
  800a46:	50                   	push   %eax
  800a47:	68 00 50 80 00       	push   $0x805000
  800a4c:	ff 75 0c             	pushl  0xc(%ebp)
  800a4f:	e8 ef 0d 00 00       	call   801843 <memmove>
	return r;
  800a54:	83 c4 10             	add    $0x10,%esp
}
  800a57:	89 d8                	mov    %ebx,%eax
  800a59:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800a5c:	5b                   	pop    %ebx
  800a5d:	5e                   	pop    %esi
  800a5e:	c9                   	leave  
  800a5f:	c3                   	ret    

00800a60 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  800a60:	55                   	push   %ebp
  800a61:	89 e5                	mov    %esp,%ebp
  800a63:	56                   	push   %esi
  800a64:	53                   	push   %ebx
  800a65:	83 ec 1c             	sub    $0x1c,%esp
  800a68:	8b 75 08             	mov    0x8(%ebp),%esi
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  800a6b:	56                   	push   %esi
  800a6c:	e8 bf 0b 00 00       	call   801630 <strlen>
  800a71:	83 c4 10             	add    $0x10,%esp
  800a74:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  800a79:	7f 65                	jg     800ae0 <open+0x80>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800a7b:	83 ec 0c             	sub    $0xc,%esp
  800a7e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800a81:	50                   	push   %eax
  800a82:	e8 e1 f8 ff ff       	call   800368 <fd_alloc>
  800a87:	89 c3                	mov    %eax,%ebx
  800a89:	83 c4 10             	add    $0x10,%esp
  800a8c:	85 c0                	test   %eax,%eax
  800a8e:	78 55                	js     800ae5 <open+0x85>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  800a90:	83 ec 08             	sub    $0x8,%esp
  800a93:	56                   	push   %esi
  800a94:	68 00 50 80 00       	push   $0x805000
  800a99:	e8 e4 0b 00 00       	call   801682 <strcpy>
	fsipcbuf.open.req_omode = mode;
  800a9e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800aa1:	a3 00 54 80 00       	mov    %eax,0x805400



	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  800aa6:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800aa9:	b8 01 00 00 00       	mov    $0x1,%eax
  800aae:	e8 65 fe ff ff       	call   800918 <fsipc>
  800ab3:	89 c3                	mov    %eax,%ebx
  800ab5:	83 c4 10             	add    $0x10,%esp
  800ab8:	85 c0                	test   %eax,%eax
  800aba:	79 12                	jns    800ace <open+0x6e>
		fd_close(fd, 0);
  800abc:	83 ec 08             	sub    $0x8,%esp
  800abf:	6a 00                	push   $0x0
  800ac1:	ff 75 f4             	pushl  -0xc(%ebp)
  800ac4:	e8 ce f9 ff ff       	call   800497 <fd_close>
		return r;
  800ac9:	83 c4 10             	add    $0x10,%esp
  800acc:	eb 17                	jmp    800ae5 <open+0x85>
	}

	return fd2num(fd);
  800ace:	83 ec 0c             	sub    $0xc,%esp
  800ad1:	ff 75 f4             	pushl  -0xc(%ebp)
  800ad4:	e8 67 f8 ff ff       	call   800340 <fd2num>
  800ad9:	89 c3                	mov    %eax,%ebx
  800adb:	83 c4 10             	add    $0x10,%esp
  800ade:	eb 05                	jmp    800ae5 <open+0x85>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  800ae0:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  800ae5:	89 d8                	mov    %ebx,%eax
  800ae7:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800aea:	5b                   	pop    %ebx
  800aeb:	5e                   	pop    %esi
  800aec:	c9                   	leave  
  800aed:	c3                   	ret    
	...

00800af0 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  800af0:	55                   	push   %ebp
  800af1:	89 e5                	mov    %esp,%ebp
  800af3:	56                   	push   %esi
  800af4:	53                   	push   %ebx
  800af5:	8b 75 0c             	mov    0xc(%ebp),%esi
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  800af8:	83 ec 0c             	sub    $0xc,%esp
  800afb:	ff 75 08             	pushl  0x8(%ebp)
  800afe:	e8 4d f8 ff ff       	call   800350 <fd2data>
  800b03:	89 c3                	mov    %eax,%ebx
	strcpy(stat->st_name, "<pipe>");
  800b05:	83 c4 08             	add    $0x8,%esp
  800b08:	68 b7 1e 80 00       	push   $0x801eb7
  800b0d:	56                   	push   %esi
  800b0e:	e8 6f 0b 00 00       	call   801682 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  800b13:	8b 43 04             	mov    0x4(%ebx),%eax
  800b16:	2b 03                	sub    (%ebx),%eax
  800b18:	89 86 80 00 00 00    	mov    %eax,0x80(%esi)
	stat->st_isdir = 0;
  800b1e:	c7 86 84 00 00 00 00 	movl   $0x0,0x84(%esi)
  800b25:	00 00 00 
	stat->st_dev = &devpipe;
  800b28:	c7 86 88 00 00 00 20 	movl   $0x803020,0x88(%esi)
  800b2f:	30 80 00 
	return 0;
}
  800b32:	b8 00 00 00 00       	mov    $0x0,%eax
  800b37:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800b3a:	5b                   	pop    %ebx
  800b3b:	5e                   	pop    %esi
  800b3c:	c9                   	leave  
  800b3d:	c3                   	ret    

00800b3e <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  800b3e:	55                   	push   %ebp
  800b3f:	89 e5                	mov    %esp,%ebp
  800b41:	53                   	push   %ebx
  800b42:	83 ec 0c             	sub    $0xc,%esp
  800b45:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  800b48:	53                   	push   %ebx
  800b49:	6a 00                	push   $0x0
  800b4b:	e8 d2 f6 ff ff       	call   800222 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  800b50:	89 1c 24             	mov    %ebx,(%esp)
  800b53:	e8 f8 f7 ff ff       	call   800350 <fd2data>
  800b58:	83 c4 08             	add    $0x8,%esp
  800b5b:	50                   	push   %eax
  800b5c:	6a 00                	push   $0x0
  800b5e:	e8 bf f6 ff ff       	call   800222 <sys_page_unmap>
}
  800b63:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800b66:	c9                   	leave  
  800b67:	c3                   	ret    

00800b68 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  800b68:	55                   	push   %ebp
  800b69:	89 e5                	mov    %esp,%ebp
  800b6b:	57                   	push   %edi
  800b6c:	56                   	push   %esi
  800b6d:	53                   	push   %ebx
  800b6e:	83 ec 1c             	sub    $0x1c,%esp
  800b71:	89 c7                	mov    %eax,%edi
  800b73:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  800b76:	a1 04 40 80 00       	mov    0x804004,%eax
  800b7b:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  800b7e:	83 ec 0c             	sub    $0xc,%esp
  800b81:	57                   	push   %edi
  800b82:	e8 a1 0f 00 00       	call   801b28 <pageref>
  800b87:	89 c6                	mov    %eax,%esi
  800b89:	83 c4 04             	add    $0x4,%esp
  800b8c:	ff 75 e4             	pushl  -0x1c(%ebp)
  800b8f:	e8 94 0f 00 00       	call   801b28 <pageref>
  800b94:	83 c4 10             	add    $0x10,%esp
  800b97:	39 c6                	cmp    %eax,%esi
  800b99:	0f 94 c0             	sete   %al
  800b9c:	0f b6 c0             	movzbl %al,%eax
		nn = thisenv->env_runs;
  800b9f:	8b 15 04 40 80 00    	mov    0x804004,%edx
  800ba5:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  800ba8:	39 cb                	cmp    %ecx,%ebx
  800baa:	75 08                	jne    800bb4 <_pipeisclosed+0x4c>
			return ret;
		if (n != nn && ret == 1)
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
	}
}
  800bac:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800baf:	5b                   	pop    %ebx
  800bb0:	5e                   	pop    %esi
  800bb1:	5f                   	pop    %edi
  800bb2:	c9                   	leave  
  800bb3:	c3                   	ret    
		n = thisenv->env_runs;
		ret = pageref(fd) == pageref(p);
		nn = thisenv->env_runs;
		if (n == nn)
			return ret;
		if (n != nn && ret == 1)
  800bb4:	83 f8 01             	cmp    $0x1,%eax
  800bb7:	75 bd                	jne    800b76 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  800bb9:	8b 42 58             	mov    0x58(%edx),%eax
  800bbc:	6a 01                	push   $0x1
  800bbe:	50                   	push   %eax
  800bbf:	53                   	push   %ebx
  800bc0:	68 be 1e 80 00       	push   $0x801ebe
  800bc5:	e8 02 05 00 00       	call   8010cc <cprintf>
  800bca:	83 c4 10             	add    $0x10,%esp
  800bcd:	eb a7                	jmp    800b76 <_pipeisclosed+0xe>

00800bcf <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  800bcf:	55                   	push   %ebp
  800bd0:	89 e5                	mov    %esp,%ebp
  800bd2:	57                   	push   %edi
  800bd3:	56                   	push   %esi
  800bd4:	53                   	push   %ebx
  800bd5:	83 ec 28             	sub    $0x28,%esp
  800bd8:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  800bdb:	56                   	push   %esi
  800bdc:	e8 6f f7 ff ff       	call   800350 <fd2data>
  800be1:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800be3:	83 c4 10             	add    $0x10,%esp
  800be6:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800bea:	75 4a                	jne    800c36 <devpipe_write+0x67>
  800bec:	bf 00 00 00 00       	mov    $0x0,%edi
  800bf1:	eb 56                	jmp    800c49 <devpipe_write+0x7a>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  800bf3:	89 da                	mov    %ebx,%edx
  800bf5:	89 f0                	mov    %esi,%eax
  800bf7:	e8 6c ff ff ff       	call   800b68 <_pipeisclosed>
  800bfc:	85 c0                	test   %eax,%eax
  800bfe:	75 4d                	jne    800c4d <devpipe_write+0x7e>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  800c00:	e8 ac f5 ff ff       	call   8001b1 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  800c05:	8b 43 04             	mov    0x4(%ebx),%eax
  800c08:	8b 13                	mov    (%ebx),%edx
  800c0a:	83 c2 20             	add    $0x20,%edx
  800c0d:	39 d0                	cmp    %edx,%eax
  800c0f:	73 e2                	jae    800bf3 <devpipe_write+0x24>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  800c11:	89 c2                	mov    %eax,%edx
  800c13:	81 e2 1f 00 00 80    	and    $0x8000001f,%edx
  800c19:	79 05                	jns    800c20 <devpipe_write+0x51>
  800c1b:	4a                   	dec    %edx
  800c1c:	83 ca e0             	or     $0xffffffe0,%edx
  800c1f:	42                   	inc    %edx
  800c20:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c23:	8a 0c 39             	mov    (%ecx,%edi,1),%cl
  800c26:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  800c2a:	40                   	inc    %eax
  800c2b:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800c2e:	47                   	inc    %edi
  800c2f:	39 7d 10             	cmp    %edi,0x10(%ebp)
  800c32:	77 07                	ja     800c3b <devpipe_write+0x6c>
  800c34:	eb 13                	jmp    800c49 <devpipe_write+0x7a>
  800c36:	bf 00 00 00 00       	mov    $0x0,%edi
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  800c3b:	8b 43 04             	mov    0x4(%ebx),%eax
  800c3e:	8b 13                	mov    (%ebx),%edx
  800c40:	83 c2 20             	add    $0x20,%edx
  800c43:	39 d0                	cmp    %edx,%eax
  800c45:	73 ac                	jae    800bf3 <devpipe_write+0x24>
  800c47:	eb c8                	jmp    800c11 <devpipe_write+0x42>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  800c49:	89 f8                	mov    %edi,%eax
  800c4b:	eb 05                	jmp    800c52 <devpipe_write+0x83>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  800c4d:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  800c52:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c55:	5b                   	pop    %ebx
  800c56:	5e                   	pop    %esi
  800c57:	5f                   	pop    %edi
  800c58:	c9                   	leave  
  800c59:	c3                   	ret    

00800c5a <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  800c5a:	55                   	push   %ebp
  800c5b:	89 e5                	mov    %esp,%ebp
  800c5d:	57                   	push   %edi
  800c5e:	56                   	push   %esi
  800c5f:	53                   	push   %ebx
  800c60:	83 ec 18             	sub    $0x18,%esp
  800c63:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  800c66:	57                   	push   %edi
  800c67:	e8 e4 f6 ff ff       	call   800350 <fd2data>
  800c6c:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800c6e:	83 c4 10             	add    $0x10,%esp
  800c71:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800c75:	75 44                	jne    800cbb <devpipe_read+0x61>
  800c77:	be 00 00 00 00       	mov    $0x0,%esi
  800c7c:	eb 4f                	jmp    800ccd <devpipe_read+0x73>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
				return i;
  800c7e:	89 f0                	mov    %esi,%eax
  800c80:	eb 54                	jmp    800cd6 <devpipe_read+0x7c>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  800c82:	89 da                	mov    %ebx,%edx
  800c84:	89 f8                	mov    %edi,%eax
  800c86:	e8 dd fe ff ff       	call   800b68 <_pipeisclosed>
  800c8b:	85 c0                	test   %eax,%eax
  800c8d:	75 42                	jne    800cd1 <devpipe_read+0x77>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  800c8f:	e8 1d f5 ff ff       	call   8001b1 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  800c94:	8b 03                	mov    (%ebx),%eax
  800c96:	3b 43 04             	cmp    0x4(%ebx),%eax
  800c99:	74 e7                	je     800c82 <devpipe_read+0x28>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  800c9b:	25 1f 00 00 80       	and    $0x8000001f,%eax
  800ca0:	79 05                	jns    800ca7 <devpipe_read+0x4d>
  800ca2:	48                   	dec    %eax
  800ca3:	83 c8 e0             	or     $0xffffffe0,%eax
  800ca6:	40                   	inc    %eax
  800ca7:	8a 44 03 08          	mov    0x8(%ebx,%eax,1),%al
  800cab:	8b 55 0c             	mov    0xc(%ebp),%edx
  800cae:	88 04 32             	mov    %al,(%edx,%esi,1)
		p->p_rpos++;
  800cb1:	ff 03                	incl   (%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800cb3:	46                   	inc    %esi
  800cb4:	39 75 10             	cmp    %esi,0x10(%ebp)
  800cb7:	77 07                	ja     800cc0 <devpipe_read+0x66>
  800cb9:	eb 12                	jmp    800ccd <devpipe_read+0x73>
  800cbb:	be 00 00 00 00       	mov    $0x0,%esi
		while (p->p_rpos == p->p_wpos) {
  800cc0:	8b 03                	mov    (%ebx),%eax
  800cc2:	3b 43 04             	cmp    0x4(%ebx),%eax
  800cc5:	75 d4                	jne    800c9b <devpipe_read+0x41>
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  800cc7:	85 f6                	test   %esi,%esi
  800cc9:	75 b3                	jne    800c7e <devpipe_read+0x24>
  800ccb:	eb b5                	jmp    800c82 <devpipe_read+0x28>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  800ccd:	89 f0                	mov    %esi,%eax
  800ccf:	eb 05                	jmp    800cd6 <devpipe_read+0x7c>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  800cd1:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  800cd6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cd9:	5b                   	pop    %ebx
  800cda:	5e                   	pop    %esi
  800cdb:	5f                   	pop    %edi
  800cdc:	c9                   	leave  
  800cdd:	c3                   	ret    

00800cde <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  800cde:	55                   	push   %ebp
  800cdf:	89 e5                	mov    %esp,%ebp
  800ce1:	57                   	push   %edi
  800ce2:	56                   	push   %esi
  800ce3:	53                   	push   %ebx
  800ce4:	83 ec 28             	sub    $0x28,%esp
  800ce7:	8b 7d 08             	mov    0x8(%ebp),%edi
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  800cea:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800ced:	50                   	push   %eax
  800cee:	e8 75 f6 ff ff       	call   800368 <fd_alloc>
  800cf3:	89 c3                	mov    %eax,%ebx
  800cf5:	83 c4 10             	add    $0x10,%esp
  800cf8:	85 c0                	test   %eax,%eax
  800cfa:	0f 88 24 01 00 00    	js     800e24 <pipe+0x146>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800d00:	83 ec 04             	sub    $0x4,%esp
  800d03:	68 07 04 00 00       	push   $0x407
  800d08:	ff 75 e4             	pushl  -0x1c(%ebp)
  800d0b:	6a 00                	push   $0x0
  800d0d:	e8 c6 f4 ff ff       	call   8001d8 <sys_page_alloc>
  800d12:	89 c3                	mov    %eax,%ebx
  800d14:	83 c4 10             	add    $0x10,%esp
  800d17:	85 c0                	test   %eax,%eax
  800d19:	0f 88 05 01 00 00    	js     800e24 <pipe+0x146>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  800d1f:	83 ec 0c             	sub    $0xc,%esp
  800d22:	8d 45 e0             	lea    -0x20(%ebp),%eax
  800d25:	50                   	push   %eax
  800d26:	e8 3d f6 ff ff       	call   800368 <fd_alloc>
  800d2b:	89 c3                	mov    %eax,%ebx
  800d2d:	83 c4 10             	add    $0x10,%esp
  800d30:	85 c0                	test   %eax,%eax
  800d32:	0f 88 dc 00 00 00    	js     800e14 <pipe+0x136>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800d38:	83 ec 04             	sub    $0x4,%esp
  800d3b:	68 07 04 00 00       	push   $0x407
  800d40:	ff 75 e0             	pushl  -0x20(%ebp)
  800d43:	6a 00                	push   $0x0
  800d45:	e8 8e f4 ff ff       	call   8001d8 <sys_page_alloc>
  800d4a:	89 c3                	mov    %eax,%ebx
  800d4c:	83 c4 10             	add    $0x10,%esp
  800d4f:	85 c0                	test   %eax,%eax
  800d51:	0f 88 bd 00 00 00    	js     800e14 <pipe+0x136>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  800d57:	83 ec 0c             	sub    $0xc,%esp
  800d5a:	ff 75 e4             	pushl  -0x1c(%ebp)
  800d5d:	e8 ee f5 ff ff       	call   800350 <fd2data>
  800d62:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800d64:	83 c4 0c             	add    $0xc,%esp
  800d67:	68 07 04 00 00       	push   $0x407
  800d6c:	50                   	push   %eax
  800d6d:	6a 00                	push   $0x0
  800d6f:	e8 64 f4 ff ff       	call   8001d8 <sys_page_alloc>
  800d74:	89 c3                	mov    %eax,%ebx
  800d76:	83 c4 10             	add    $0x10,%esp
  800d79:	85 c0                	test   %eax,%eax
  800d7b:	0f 88 83 00 00 00    	js     800e04 <pipe+0x126>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800d81:	83 ec 0c             	sub    $0xc,%esp
  800d84:	ff 75 e0             	pushl  -0x20(%ebp)
  800d87:	e8 c4 f5 ff ff       	call   800350 <fd2data>
  800d8c:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  800d93:	50                   	push   %eax
  800d94:	6a 00                	push   $0x0
  800d96:	56                   	push   %esi
  800d97:	6a 00                	push   $0x0
  800d99:	e8 5e f4 ff ff       	call   8001fc <sys_page_map>
  800d9e:	89 c3                	mov    %eax,%ebx
  800da0:	83 c4 20             	add    $0x20,%esp
  800da3:	85 c0                	test   %eax,%eax
  800da5:	78 4f                	js     800df6 <pipe+0x118>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  800da7:	8b 15 20 30 80 00    	mov    0x803020,%edx
  800dad:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800db0:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  800db2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800db5:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  800dbc:	8b 15 20 30 80 00    	mov    0x803020,%edx
  800dc2:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800dc5:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  800dc7:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800dca:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  800dd1:	83 ec 0c             	sub    $0xc,%esp
  800dd4:	ff 75 e4             	pushl  -0x1c(%ebp)
  800dd7:	e8 64 f5 ff ff       	call   800340 <fd2num>
  800ddc:	89 07                	mov    %eax,(%edi)
	pfd[1] = fd2num(fd1);
  800dde:	83 c4 04             	add    $0x4,%esp
  800de1:	ff 75 e0             	pushl  -0x20(%ebp)
  800de4:	e8 57 f5 ff ff       	call   800340 <fd2num>
  800de9:	89 47 04             	mov    %eax,0x4(%edi)
	return 0;
  800dec:	83 c4 10             	add    $0x10,%esp
  800def:	bb 00 00 00 00       	mov    $0x0,%ebx
  800df4:	eb 2e                	jmp    800e24 <pipe+0x146>

    err3:
	sys_page_unmap(0, va);
  800df6:	83 ec 08             	sub    $0x8,%esp
  800df9:	56                   	push   %esi
  800dfa:	6a 00                	push   $0x0
  800dfc:	e8 21 f4 ff ff       	call   800222 <sys_page_unmap>
  800e01:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  800e04:	83 ec 08             	sub    $0x8,%esp
  800e07:	ff 75 e0             	pushl  -0x20(%ebp)
  800e0a:	6a 00                	push   $0x0
  800e0c:	e8 11 f4 ff ff       	call   800222 <sys_page_unmap>
  800e11:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  800e14:	83 ec 08             	sub    $0x8,%esp
  800e17:	ff 75 e4             	pushl  -0x1c(%ebp)
  800e1a:	6a 00                	push   $0x0
  800e1c:	e8 01 f4 ff ff       	call   800222 <sys_page_unmap>
  800e21:	83 c4 10             	add    $0x10,%esp
    err:
	return r;
}
  800e24:	89 d8                	mov    %ebx,%eax
  800e26:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e29:	5b                   	pop    %ebx
  800e2a:	5e                   	pop    %esi
  800e2b:	5f                   	pop    %edi
  800e2c:	c9                   	leave  
  800e2d:	c3                   	ret    

00800e2e <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  800e2e:	55                   	push   %ebp
  800e2f:	89 e5                	mov    %esp,%ebp
  800e31:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800e34:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800e37:	50                   	push   %eax
  800e38:	ff 75 08             	pushl  0x8(%ebp)
  800e3b:	e8 9b f5 ff ff       	call   8003db <fd_lookup>
  800e40:	83 c4 10             	add    $0x10,%esp
  800e43:	85 c0                	test   %eax,%eax
  800e45:	78 18                	js     800e5f <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  800e47:	83 ec 0c             	sub    $0xc,%esp
  800e4a:	ff 75 f4             	pushl  -0xc(%ebp)
  800e4d:	e8 fe f4 ff ff       	call   800350 <fd2data>
	return _pipeisclosed(fd, p);
  800e52:	89 c2                	mov    %eax,%edx
  800e54:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800e57:	e8 0c fd ff ff       	call   800b68 <_pipeisclosed>
  800e5c:	83 c4 10             	add    $0x10,%esp
}
  800e5f:	c9                   	leave  
  800e60:	c3                   	ret    
  800e61:	00 00                	add    %al,(%eax)
	...

00800e64 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  800e64:	55                   	push   %ebp
  800e65:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  800e67:	b8 00 00 00 00       	mov    $0x0,%eax
  800e6c:	c9                   	leave  
  800e6d:	c3                   	ret    

00800e6e <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  800e6e:	55                   	push   %ebp
  800e6f:	89 e5                	mov    %esp,%ebp
  800e71:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  800e74:	68 d6 1e 80 00       	push   $0x801ed6
  800e79:	ff 75 0c             	pushl  0xc(%ebp)
  800e7c:	e8 01 08 00 00       	call   801682 <strcpy>
	return 0;
}
  800e81:	b8 00 00 00 00       	mov    $0x0,%eax
  800e86:	c9                   	leave  
  800e87:	c3                   	ret    

00800e88 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  800e88:	55                   	push   %ebp
  800e89:	89 e5                	mov    %esp,%ebp
  800e8b:	57                   	push   %edi
  800e8c:	56                   	push   %esi
  800e8d:	53                   	push   %ebx
  800e8e:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800e94:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800e98:	74 45                	je     800edf <devcons_write+0x57>
  800e9a:	b8 00 00 00 00       	mov    $0x0,%eax
  800e9f:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  800ea4:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  800eaa:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800ead:	29 c3                	sub    %eax,%ebx
		if (m > sizeof(buf) - 1)
  800eaf:	83 fb 7f             	cmp    $0x7f,%ebx
  800eb2:	76 05                	jbe    800eb9 <devcons_write+0x31>
			m = sizeof(buf) - 1;
  800eb4:	bb 7f 00 00 00       	mov    $0x7f,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  800eb9:	83 ec 04             	sub    $0x4,%esp
  800ebc:	53                   	push   %ebx
  800ebd:	03 45 0c             	add    0xc(%ebp),%eax
  800ec0:	50                   	push   %eax
  800ec1:	57                   	push   %edi
  800ec2:	e8 7c 09 00 00       	call   801843 <memmove>
		sys_cputs(buf, m);
  800ec7:	83 c4 08             	add    $0x8,%esp
  800eca:	53                   	push   %ebx
  800ecb:	57                   	push   %edi
  800ecc:	e8 50 f2 ff ff       	call   800121 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800ed1:	01 de                	add    %ebx,%esi
  800ed3:	89 f0                	mov    %esi,%eax
  800ed5:	83 c4 10             	add    $0x10,%esp
  800ed8:	3b 75 10             	cmp    0x10(%ebp),%esi
  800edb:	72 cd                	jb     800eaa <devcons_write+0x22>
  800edd:	eb 05                	jmp    800ee4 <devcons_write+0x5c>
  800edf:	be 00 00 00 00       	mov    $0x0,%esi
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  800ee4:	89 f0                	mov    %esi,%eax
  800ee6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ee9:	5b                   	pop    %ebx
  800eea:	5e                   	pop    %esi
  800eeb:	5f                   	pop    %edi
  800eec:	c9                   	leave  
  800eed:	c3                   	ret    

00800eee <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  800eee:	55                   	push   %ebp
  800eef:	89 e5                	mov    %esp,%ebp
  800ef1:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
  800ef4:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800ef8:	75 07                	jne    800f01 <devcons_read+0x13>
  800efa:	eb 25                	jmp    800f21 <devcons_read+0x33>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  800efc:	e8 b0 f2 ff ff       	call   8001b1 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  800f01:	e8 41 f2 ff ff       	call   800147 <sys_cgetc>
  800f06:	85 c0                	test   %eax,%eax
  800f08:	74 f2                	je     800efc <devcons_read+0xe>
  800f0a:	89 c2                	mov    %eax,%edx
		sys_yield();
	if (c < 0)
  800f0c:	85 c0                	test   %eax,%eax
  800f0e:	78 1d                	js     800f2d <devcons_read+0x3f>
		return c;
	if (c == 0x04)	// ctl-d is eof
  800f10:	83 f8 04             	cmp    $0x4,%eax
  800f13:	74 13                	je     800f28 <devcons_read+0x3a>
		return 0;
	*(char*)vbuf = c;
  800f15:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f18:	88 10                	mov    %dl,(%eax)
	return 1;
  800f1a:	b8 01 00 00 00       	mov    $0x1,%eax
  800f1f:	eb 0c                	jmp    800f2d <devcons_read+0x3f>
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
		return 0;
  800f21:	b8 00 00 00 00       	mov    $0x0,%eax
  800f26:	eb 05                	jmp    800f2d <devcons_read+0x3f>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  800f28:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  800f2d:	c9                   	leave  
  800f2e:	c3                   	ret    

00800f2f <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  800f2f:	55                   	push   %ebp
  800f30:	89 e5                	mov    %esp,%ebp
  800f32:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  800f35:	8b 45 08             	mov    0x8(%ebp),%eax
  800f38:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  800f3b:	6a 01                	push   $0x1
  800f3d:	8d 45 f7             	lea    -0x9(%ebp),%eax
  800f40:	50                   	push   %eax
  800f41:	e8 db f1 ff ff       	call   800121 <sys_cputs>
  800f46:	83 c4 10             	add    $0x10,%esp
}
  800f49:	c9                   	leave  
  800f4a:	c3                   	ret    

00800f4b <getchar>:

int
getchar(void)
{
  800f4b:	55                   	push   %ebp
  800f4c:	89 e5                	mov    %esp,%ebp
  800f4e:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  800f51:	6a 01                	push   $0x1
  800f53:	8d 45 f7             	lea    -0x9(%ebp),%eax
  800f56:	50                   	push   %eax
  800f57:	6a 00                	push   $0x0
  800f59:	e8 fe f6 ff ff       	call   80065c <read>
	if (r < 0)
  800f5e:	83 c4 10             	add    $0x10,%esp
  800f61:	85 c0                	test   %eax,%eax
  800f63:	78 0f                	js     800f74 <getchar+0x29>
		return r;
	if (r < 1)
  800f65:	85 c0                	test   %eax,%eax
  800f67:	7e 06                	jle    800f6f <getchar+0x24>
		return -E_EOF;
	return c;
  800f69:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  800f6d:	eb 05                	jmp    800f74 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  800f6f:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  800f74:	c9                   	leave  
  800f75:	c3                   	ret    

00800f76 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  800f76:	55                   	push   %ebp
  800f77:	89 e5                	mov    %esp,%ebp
  800f79:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800f7c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800f7f:	50                   	push   %eax
  800f80:	ff 75 08             	pushl  0x8(%ebp)
  800f83:	e8 53 f4 ff ff       	call   8003db <fd_lookup>
  800f88:	83 c4 10             	add    $0x10,%esp
  800f8b:	85 c0                	test   %eax,%eax
  800f8d:	78 11                	js     800fa0 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  800f8f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800f92:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  800f98:	39 10                	cmp    %edx,(%eax)
  800f9a:	0f 94 c0             	sete   %al
  800f9d:	0f b6 c0             	movzbl %al,%eax
}
  800fa0:	c9                   	leave  
  800fa1:	c3                   	ret    

00800fa2 <opencons>:

int
opencons(void)
{
  800fa2:	55                   	push   %ebp
  800fa3:	89 e5                	mov    %esp,%ebp
  800fa5:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  800fa8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800fab:	50                   	push   %eax
  800fac:	e8 b7 f3 ff ff       	call   800368 <fd_alloc>
  800fb1:	83 c4 10             	add    $0x10,%esp
  800fb4:	85 c0                	test   %eax,%eax
  800fb6:	78 3a                	js     800ff2 <opencons+0x50>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  800fb8:	83 ec 04             	sub    $0x4,%esp
  800fbb:	68 07 04 00 00       	push   $0x407
  800fc0:	ff 75 f4             	pushl  -0xc(%ebp)
  800fc3:	6a 00                	push   $0x0
  800fc5:	e8 0e f2 ff ff       	call   8001d8 <sys_page_alloc>
  800fca:	83 c4 10             	add    $0x10,%esp
  800fcd:	85 c0                	test   %eax,%eax
  800fcf:	78 21                	js     800ff2 <opencons+0x50>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  800fd1:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  800fd7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800fda:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  800fdc:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800fdf:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  800fe6:	83 ec 0c             	sub    $0xc,%esp
  800fe9:	50                   	push   %eax
  800fea:	e8 51 f3 ff ff       	call   800340 <fd2num>
  800fef:	83 c4 10             	add    $0x10,%esp
}
  800ff2:	c9                   	leave  
  800ff3:	c3                   	ret    

00800ff4 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800ff4:	55                   	push   %ebp
  800ff5:	89 e5                	mov    %esp,%ebp
  800ff7:	56                   	push   %esi
  800ff8:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800ff9:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800ffc:	8b 1d 00 30 80 00    	mov    0x803000,%ebx
  801002:	e8 86 f1 ff ff       	call   80018d <sys_getenvid>
  801007:	83 ec 0c             	sub    $0xc,%esp
  80100a:	ff 75 0c             	pushl  0xc(%ebp)
  80100d:	ff 75 08             	pushl  0x8(%ebp)
  801010:	53                   	push   %ebx
  801011:	50                   	push   %eax
  801012:	68 e4 1e 80 00       	push   $0x801ee4
  801017:	e8 b0 00 00 00       	call   8010cc <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80101c:	83 c4 18             	add    $0x18,%esp
  80101f:	56                   	push   %esi
  801020:	ff 75 10             	pushl  0x10(%ebp)
  801023:	e8 53 00 00 00       	call   80107b <vcprintf>
	cprintf("\n");
  801028:	c7 04 24 cf 1e 80 00 	movl   $0x801ecf,(%esp)
  80102f:	e8 98 00 00 00       	call   8010cc <cprintf>
  801034:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801037:	cc                   	int3   
  801038:	eb fd                	jmp    801037 <_panic+0x43>
	...

0080103c <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80103c:	55                   	push   %ebp
  80103d:	89 e5                	mov    %esp,%ebp
  80103f:	53                   	push   %ebx
  801040:	83 ec 04             	sub    $0x4,%esp
  801043:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  801046:	8b 03                	mov    (%ebx),%eax
  801048:	8b 55 08             	mov    0x8(%ebp),%edx
  80104b:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  80104f:	40                   	inc    %eax
  801050:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  801052:	3d ff 00 00 00       	cmp    $0xff,%eax
  801057:	75 1a                	jne    801073 <putch+0x37>
		sys_cputs(b->buf, b->idx);
  801059:	83 ec 08             	sub    $0x8,%esp
  80105c:	68 ff 00 00 00       	push   $0xff
  801061:	8d 43 08             	lea    0x8(%ebx),%eax
  801064:	50                   	push   %eax
  801065:	e8 b7 f0 ff ff       	call   800121 <sys_cputs>
		b->idx = 0;
  80106a:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801070:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  801073:	ff 43 04             	incl   0x4(%ebx)
}
  801076:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801079:	c9                   	leave  
  80107a:	c3                   	ret    

0080107b <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80107b:	55                   	push   %ebp
  80107c:	89 e5                	mov    %esp,%ebp
  80107e:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  801084:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80108b:	00 00 00 
	b.cnt = 0;
  80108e:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  801095:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  801098:	ff 75 0c             	pushl  0xc(%ebp)
  80109b:	ff 75 08             	pushl  0x8(%ebp)
  80109e:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8010a4:	50                   	push   %eax
  8010a5:	68 3c 10 80 00       	push   $0x80103c
  8010aa:	e8 82 01 00 00       	call   801231 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8010af:	83 c4 08             	add    $0x8,%esp
  8010b2:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8010b8:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8010be:	50                   	push   %eax
  8010bf:	e8 5d f0 ff ff       	call   800121 <sys_cputs>

	return b.cnt;
}
  8010c4:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8010ca:	c9                   	leave  
  8010cb:	c3                   	ret    

008010cc <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8010cc:	55                   	push   %ebp
  8010cd:	89 e5                	mov    %esp,%ebp
  8010cf:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8010d2:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8010d5:	50                   	push   %eax
  8010d6:	ff 75 08             	pushl  0x8(%ebp)
  8010d9:	e8 9d ff ff ff       	call   80107b <vcprintf>
	va_end(ap);

	return cnt;
}
  8010de:	c9                   	leave  
  8010df:	c3                   	ret    

008010e0 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8010e0:	55                   	push   %ebp
  8010e1:	89 e5                	mov    %esp,%ebp
  8010e3:	57                   	push   %edi
  8010e4:	56                   	push   %esi
  8010e5:	53                   	push   %ebx
  8010e6:	83 ec 2c             	sub    $0x2c,%esp
  8010e9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8010ec:	89 d6                	mov    %edx,%esi
  8010ee:	8b 45 08             	mov    0x8(%ebp),%eax
  8010f1:	8b 55 0c             	mov    0xc(%ebp),%edx
  8010f4:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8010f7:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8010fa:	8b 45 10             	mov    0x10(%ebp),%eax
  8010fd:	8b 5d 14             	mov    0x14(%ebp),%ebx
  801100:	8b 7d 18             	mov    0x18(%ebp),%edi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  801103:	89 45 d0             	mov    %eax,-0x30(%ebp)
  801106:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  80110d:	39 55 d4             	cmp    %edx,-0x2c(%ebp)
  801110:	72 0c                	jb     80111e <printnum+0x3e>
  801112:	3b 45 d8             	cmp    -0x28(%ebp),%eax
  801115:	76 07                	jbe    80111e <printnum+0x3e>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  801117:	4b                   	dec    %ebx
  801118:	85 db                	test   %ebx,%ebx
  80111a:	7f 31                	jg     80114d <printnum+0x6d>
  80111c:	eb 3f                	jmp    80115d <printnum+0x7d>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80111e:	83 ec 0c             	sub    $0xc,%esp
  801121:	57                   	push   %edi
  801122:	4b                   	dec    %ebx
  801123:	53                   	push   %ebx
  801124:	50                   	push   %eax
  801125:	83 ec 08             	sub    $0x8,%esp
  801128:	ff 75 d4             	pushl  -0x2c(%ebp)
  80112b:	ff 75 d0             	pushl  -0x30(%ebp)
  80112e:	ff 75 dc             	pushl  -0x24(%ebp)
  801131:	ff 75 d8             	pushl  -0x28(%ebp)
  801134:	e8 33 0a 00 00       	call   801b6c <__udivdi3>
  801139:	83 c4 18             	add    $0x18,%esp
  80113c:	52                   	push   %edx
  80113d:	50                   	push   %eax
  80113e:	89 f2                	mov    %esi,%edx
  801140:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801143:	e8 98 ff ff ff       	call   8010e0 <printnum>
  801148:	83 c4 20             	add    $0x20,%esp
  80114b:	eb 10                	jmp    80115d <printnum+0x7d>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80114d:	83 ec 08             	sub    $0x8,%esp
  801150:	56                   	push   %esi
  801151:	57                   	push   %edi
  801152:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  801155:	4b                   	dec    %ebx
  801156:	83 c4 10             	add    $0x10,%esp
  801159:	85 db                	test   %ebx,%ebx
  80115b:	7f f0                	jg     80114d <printnum+0x6d>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80115d:	83 ec 08             	sub    $0x8,%esp
  801160:	56                   	push   %esi
  801161:	83 ec 04             	sub    $0x4,%esp
  801164:	ff 75 d4             	pushl  -0x2c(%ebp)
  801167:	ff 75 d0             	pushl  -0x30(%ebp)
  80116a:	ff 75 dc             	pushl  -0x24(%ebp)
  80116d:	ff 75 d8             	pushl  -0x28(%ebp)
  801170:	e8 13 0b 00 00       	call   801c88 <__umoddi3>
  801175:	83 c4 14             	add    $0x14,%esp
  801178:	0f be 80 07 1f 80 00 	movsbl 0x801f07(%eax),%eax
  80117f:	50                   	push   %eax
  801180:	ff 55 e4             	call   *-0x1c(%ebp)
  801183:	83 c4 10             	add    $0x10,%esp
}
  801186:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801189:	5b                   	pop    %ebx
  80118a:	5e                   	pop    %esi
  80118b:	5f                   	pop    %edi
  80118c:	c9                   	leave  
  80118d:	c3                   	ret    

0080118e <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80118e:	55                   	push   %ebp
  80118f:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  801191:	83 fa 01             	cmp    $0x1,%edx
  801194:	7e 0e                	jle    8011a4 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  801196:	8b 10                	mov    (%eax),%edx
  801198:	8d 4a 08             	lea    0x8(%edx),%ecx
  80119b:	89 08                	mov    %ecx,(%eax)
  80119d:	8b 02                	mov    (%edx),%eax
  80119f:	8b 52 04             	mov    0x4(%edx),%edx
  8011a2:	eb 22                	jmp    8011c6 <getuint+0x38>
	else if (lflag)
  8011a4:	85 d2                	test   %edx,%edx
  8011a6:	74 10                	je     8011b8 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8011a8:	8b 10                	mov    (%eax),%edx
  8011aa:	8d 4a 04             	lea    0x4(%edx),%ecx
  8011ad:	89 08                	mov    %ecx,(%eax)
  8011af:	8b 02                	mov    (%edx),%eax
  8011b1:	ba 00 00 00 00       	mov    $0x0,%edx
  8011b6:	eb 0e                	jmp    8011c6 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8011b8:	8b 10                	mov    (%eax),%edx
  8011ba:	8d 4a 04             	lea    0x4(%edx),%ecx
  8011bd:	89 08                	mov    %ecx,(%eax)
  8011bf:	8b 02                	mov    (%edx),%eax
  8011c1:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8011c6:	c9                   	leave  
  8011c7:	c3                   	ret    

008011c8 <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
  8011c8:	55                   	push   %ebp
  8011c9:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8011cb:	83 fa 01             	cmp    $0x1,%edx
  8011ce:	7e 0e                	jle    8011de <getint+0x16>
		return va_arg(*ap, long long);
  8011d0:	8b 10                	mov    (%eax),%edx
  8011d2:	8d 4a 08             	lea    0x8(%edx),%ecx
  8011d5:	89 08                	mov    %ecx,(%eax)
  8011d7:	8b 02                	mov    (%edx),%eax
  8011d9:	8b 52 04             	mov    0x4(%edx),%edx
  8011dc:	eb 1a                	jmp    8011f8 <getint+0x30>
	else if (lflag)
  8011de:	85 d2                	test   %edx,%edx
  8011e0:	74 0c                	je     8011ee <getint+0x26>
		return va_arg(*ap, long);
  8011e2:	8b 10                	mov    (%eax),%edx
  8011e4:	8d 4a 04             	lea    0x4(%edx),%ecx
  8011e7:	89 08                	mov    %ecx,(%eax)
  8011e9:	8b 02                	mov    (%edx),%eax
  8011eb:	99                   	cltd   
  8011ec:	eb 0a                	jmp    8011f8 <getint+0x30>
	else
		return va_arg(*ap, int);
  8011ee:	8b 10                	mov    (%eax),%edx
  8011f0:	8d 4a 04             	lea    0x4(%edx),%ecx
  8011f3:	89 08                	mov    %ecx,(%eax)
  8011f5:	8b 02                	mov    (%edx),%eax
  8011f7:	99                   	cltd   
}
  8011f8:	c9                   	leave  
  8011f9:	c3                   	ret    

008011fa <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8011fa:	55                   	push   %ebp
  8011fb:	89 e5                	mov    %esp,%ebp
  8011fd:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  801200:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  801203:	8b 10                	mov    (%eax),%edx
  801205:	3b 50 04             	cmp    0x4(%eax),%edx
  801208:	73 08                	jae    801212 <sprintputch+0x18>
		*b->buf++ = ch;
  80120a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80120d:	88 0a                	mov    %cl,(%edx)
  80120f:	42                   	inc    %edx
  801210:	89 10                	mov    %edx,(%eax)
}
  801212:	c9                   	leave  
  801213:	c3                   	ret    

00801214 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  801214:	55                   	push   %ebp
  801215:	89 e5                	mov    %esp,%ebp
  801217:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  80121a:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80121d:	50                   	push   %eax
  80121e:	ff 75 10             	pushl  0x10(%ebp)
  801221:	ff 75 0c             	pushl  0xc(%ebp)
  801224:	ff 75 08             	pushl  0x8(%ebp)
  801227:	e8 05 00 00 00       	call   801231 <vprintfmt>
	va_end(ap);
  80122c:	83 c4 10             	add    $0x10,%esp
}
  80122f:	c9                   	leave  
  801230:	c3                   	ret    

00801231 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  801231:	55                   	push   %ebp
  801232:	89 e5                	mov    %esp,%ebp
  801234:	57                   	push   %edi
  801235:	56                   	push   %esi
  801236:	53                   	push   %ebx
  801237:	83 ec 2c             	sub    $0x2c,%esp
  80123a:	8b 7d 0c             	mov    0xc(%ebp),%edi
  80123d:	8b 75 10             	mov    0x10(%ebp),%esi
  801240:	eb 13                	jmp    801255 <vprintfmt+0x24>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  801242:	85 c0                	test   %eax,%eax
  801244:	0f 84 6d 03 00 00    	je     8015b7 <vprintfmt+0x386>
				return;
			putch(ch, putdat);
  80124a:	83 ec 08             	sub    $0x8,%esp
  80124d:	57                   	push   %edi
  80124e:	50                   	push   %eax
  80124f:	ff 55 08             	call   *0x8(%ebp)
  801252:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  801255:	0f b6 06             	movzbl (%esi),%eax
  801258:	46                   	inc    %esi
  801259:	83 f8 25             	cmp    $0x25,%eax
  80125c:	75 e4                	jne    801242 <vprintfmt+0x11>
  80125e:	c6 45 dc 20          	movb   $0x20,-0x24(%ebp)
  801262:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  801269:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
  801270:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  801277:	b9 00 00 00 00       	mov    $0x0,%ecx
  80127c:	eb 28                	jmp    8012a6 <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80127e:	89 de                	mov    %ebx,%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  801280:	c6 45 dc 2d          	movb   $0x2d,-0x24(%ebp)
  801284:	eb 20                	jmp    8012a6 <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801286:	89 de                	mov    %ebx,%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  801288:	c6 45 dc 30          	movb   $0x30,-0x24(%ebp)
  80128c:	eb 18                	jmp    8012a6 <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80128e:	89 de                	mov    %ebx,%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  801290:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  801297:	eb 0d                	jmp    8012a6 <vprintfmt+0x75>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  801299:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80129c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80129f:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8012a6:	8a 06                	mov    (%esi),%al
  8012a8:	0f b6 d0             	movzbl %al,%edx
  8012ab:	8d 5e 01             	lea    0x1(%esi),%ebx
  8012ae:	83 e8 23             	sub    $0x23,%eax
  8012b1:	3c 55                	cmp    $0x55,%al
  8012b3:	0f 87 e0 02 00 00    	ja     801599 <vprintfmt+0x368>
  8012b9:	0f b6 c0             	movzbl %al,%eax
  8012bc:	ff 24 85 40 20 80 00 	jmp    *0x802040(,%eax,4)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8012c3:	83 ea 30             	sub    $0x30,%edx
  8012c6:	89 55 d4             	mov    %edx,-0x2c(%ebp)
				ch = *fmt;
  8012c9:	0f be 03             	movsbl (%ebx),%eax
				if (ch < '0' || ch > '9')
  8012cc:	8d 50 d0             	lea    -0x30(%eax),%edx
  8012cf:	83 fa 09             	cmp    $0x9,%edx
  8012d2:	77 44                	ja     801318 <vprintfmt+0xe7>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8012d4:	89 de                	mov    %ebx,%esi
  8012d6:	8b 55 d4             	mov    -0x2c(%ebp),%edx
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8012d9:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
  8012da:	8d 14 92             	lea    (%edx,%edx,4),%edx
  8012dd:	8d 54 50 d0          	lea    -0x30(%eax,%edx,2),%edx
				ch = *fmt;
  8012e1:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  8012e4:	8d 58 d0             	lea    -0x30(%eax),%ebx
  8012e7:	83 fb 09             	cmp    $0x9,%ebx
  8012ea:	76 ed                	jbe    8012d9 <vprintfmt+0xa8>
  8012ec:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  8012ef:	eb 29                	jmp    80131a <vprintfmt+0xe9>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8012f1:	8b 45 14             	mov    0x14(%ebp),%eax
  8012f4:	8d 50 04             	lea    0x4(%eax),%edx
  8012f7:	89 55 14             	mov    %edx,0x14(%ebp)
  8012fa:	8b 00                	mov    (%eax),%eax
  8012fc:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8012ff:	89 de                	mov    %ebx,%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  801301:	eb 17                	jmp    80131a <vprintfmt+0xe9>

		case '.':
			if (width < 0)
  801303:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  801307:	78 85                	js     80128e <vprintfmt+0x5d>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801309:	89 de                	mov    %ebx,%esi
  80130b:	eb 99                	jmp    8012a6 <vprintfmt+0x75>
  80130d:	89 de                	mov    %ebx,%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  80130f:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
			goto reswitch;
  801316:	eb 8e                	jmp    8012a6 <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801318:	89 de                	mov    %ebx,%esi
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  80131a:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80131e:	79 86                	jns    8012a6 <vprintfmt+0x75>
  801320:	e9 74 ff ff ff       	jmp    801299 <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  801325:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801326:	89 de                	mov    %ebx,%esi
  801328:	e9 79 ff ff ff       	jmp    8012a6 <vprintfmt+0x75>
  80132d:	89 5d d8             	mov    %ebx,-0x28(%ebp)
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  801330:	8b 45 14             	mov    0x14(%ebp),%eax
  801333:	8d 50 04             	lea    0x4(%eax),%edx
  801336:	89 55 14             	mov    %edx,0x14(%ebp)
  801339:	83 ec 08             	sub    $0x8,%esp
  80133c:	57                   	push   %edi
  80133d:	ff 30                	pushl  (%eax)
  80133f:	ff 55 08             	call   *0x8(%ebp)
			break;
  801342:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801345:	8b 75 d8             	mov    -0x28(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  801348:	e9 08 ff ff ff       	jmp    801255 <vprintfmt+0x24>
  80134d:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// error message
		case 'e':
			err = va_arg(ap, int);
  801350:	8b 45 14             	mov    0x14(%ebp),%eax
  801353:	8d 50 04             	lea    0x4(%eax),%edx
  801356:	89 55 14             	mov    %edx,0x14(%ebp)
  801359:	8b 00                	mov    (%eax),%eax
  80135b:	85 c0                	test   %eax,%eax
  80135d:	79 02                	jns    801361 <vprintfmt+0x130>
  80135f:	f7 d8                	neg    %eax
  801361:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  801363:	83 f8 0f             	cmp    $0xf,%eax
  801366:	7f 0b                	jg     801373 <vprintfmt+0x142>
  801368:	8b 04 85 a0 21 80 00 	mov    0x8021a0(,%eax,4),%eax
  80136f:	85 c0                	test   %eax,%eax
  801371:	75 1a                	jne    80138d <vprintfmt+0x15c>
				printfmt(putch, putdat, "error %d", err);
  801373:	52                   	push   %edx
  801374:	68 1f 1f 80 00       	push   $0x801f1f
  801379:	57                   	push   %edi
  80137a:	ff 75 08             	pushl  0x8(%ebp)
  80137d:	e8 92 fe ff ff       	call   801214 <printfmt>
  801382:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801385:	8b 75 d8             	mov    -0x28(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  801388:	e9 c8 fe ff ff       	jmp    801255 <vprintfmt+0x24>
			else
				printfmt(putch, putdat, "%s", p);
  80138d:	50                   	push   %eax
  80138e:	68 9d 1e 80 00       	push   $0x801e9d
  801393:	57                   	push   %edi
  801394:	ff 75 08             	pushl  0x8(%ebp)
  801397:	e8 78 fe ff ff       	call   801214 <printfmt>
  80139c:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80139f:	8b 75 d8             	mov    -0x28(%ebp),%esi
  8013a2:	e9 ae fe ff ff       	jmp    801255 <vprintfmt+0x24>
  8013a7:	89 5d d8             	mov    %ebx,-0x28(%ebp)
  8013aa:	89 de                	mov    %ebx,%esi
  8013ac:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  8013af:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8013b2:	8b 45 14             	mov    0x14(%ebp),%eax
  8013b5:	8d 50 04             	lea    0x4(%eax),%edx
  8013b8:	89 55 14             	mov    %edx,0x14(%ebp)
  8013bb:	8b 00                	mov    (%eax),%eax
  8013bd:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8013c0:	85 c0                	test   %eax,%eax
  8013c2:	75 07                	jne    8013cb <vprintfmt+0x19a>
				p = "(null)";
  8013c4:	c7 45 d0 18 1f 80 00 	movl   $0x801f18,-0x30(%ebp)
			if (width > 0 && padc != '-')
  8013cb:	85 db                	test   %ebx,%ebx
  8013cd:	7e 42                	jle    801411 <vprintfmt+0x1e0>
  8013cf:	80 7d dc 2d          	cmpb   $0x2d,-0x24(%ebp)
  8013d3:	74 3c                	je     801411 <vprintfmt+0x1e0>
				for (width -= strnlen(p, precision); width > 0; width--)
  8013d5:	83 ec 08             	sub    $0x8,%esp
  8013d8:	51                   	push   %ecx
  8013d9:	ff 75 d0             	pushl  -0x30(%ebp)
  8013dc:	e8 6f 02 00 00       	call   801650 <strnlen>
  8013e1:	29 c3                	sub    %eax,%ebx
  8013e3:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8013e6:	83 c4 10             	add    $0x10,%esp
  8013e9:	85 db                	test   %ebx,%ebx
  8013eb:	7e 24                	jle    801411 <vprintfmt+0x1e0>
					putch(padc, putdat);
  8013ed:	0f be 5d dc          	movsbl -0x24(%ebp),%ebx
  8013f1:	89 75 dc             	mov    %esi,-0x24(%ebp)
  8013f4:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  8013f7:	83 ec 08             	sub    $0x8,%esp
  8013fa:	57                   	push   %edi
  8013fb:	53                   	push   %ebx
  8013fc:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8013ff:	4e                   	dec    %esi
  801400:	83 c4 10             	add    $0x10,%esp
  801403:	85 f6                	test   %esi,%esi
  801405:	7f f0                	jg     8013f7 <vprintfmt+0x1c6>
  801407:	8b 75 dc             	mov    -0x24(%ebp),%esi
  80140a:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  801411:	8b 55 d0             	mov    -0x30(%ebp),%edx
  801414:	0f be 02             	movsbl (%edx),%eax
  801417:	85 c0                	test   %eax,%eax
  801419:	75 47                	jne    801462 <vprintfmt+0x231>
  80141b:	eb 37                	jmp    801454 <vprintfmt+0x223>
				if (altflag && (ch < ' ' || ch > '~'))
  80141d:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  801421:	74 16                	je     801439 <vprintfmt+0x208>
  801423:	8d 50 e0             	lea    -0x20(%eax),%edx
  801426:	83 fa 5e             	cmp    $0x5e,%edx
  801429:	76 0e                	jbe    801439 <vprintfmt+0x208>
					putch('?', putdat);
  80142b:	83 ec 08             	sub    $0x8,%esp
  80142e:	57                   	push   %edi
  80142f:	6a 3f                	push   $0x3f
  801431:	ff 55 08             	call   *0x8(%ebp)
  801434:	83 c4 10             	add    $0x10,%esp
  801437:	eb 0b                	jmp    801444 <vprintfmt+0x213>
				else
					putch(ch, putdat);
  801439:	83 ec 08             	sub    $0x8,%esp
  80143c:	57                   	push   %edi
  80143d:	50                   	push   %eax
  80143e:	ff 55 08             	call   *0x8(%ebp)
  801441:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  801444:	ff 4d e4             	decl   -0x1c(%ebp)
  801447:	0f be 03             	movsbl (%ebx),%eax
  80144a:	85 c0                	test   %eax,%eax
  80144c:	74 03                	je     801451 <vprintfmt+0x220>
  80144e:	43                   	inc    %ebx
  80144f:	eb 1b                	jmp    80146c <vprintfmt+0x23b>
  801451:	8b 75 dc             	mov    -0x24(%ebp),%esi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  801454:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  801458:	7f 1e                	jg     801478 <vprintfmt+0x247>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80145a:	8b 75 d8             	mov    -0x28(%ebp),%esi
  80145d:	e9 f3 fd ff ff       	jmp    801255 <vprintfmt+0x24>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  801462:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  801465:	43                   	inc    %ebx
  801466:	89 75 dc             	mov    %esi,-0x24(%ebp)
  801469:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  80146c:	85 f6                	test   %esi,%esi
  80146e:	78 ad                	js     80141d <vprintfmt+0x1ec>
  801470:	4e                   	dec    %esi
  801471:	79 aa                	jns    80141d <vprintfmt+0x1ec>
  801473:	8b 75 dc             	mov    -0x24(%ebp),%esi
  801476:	eb dc                	jmp    801454 <vprintfmt+0x223>
  801478:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80147b:	83 ec 08             	sub    $0x8,%esp
  80147e:	57                   	push   %edi
  80147f:	6a 20                	push   $0x20
  801481:	ff 55 08             	call   *0x8(%ebp)
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  801484:	4b                   	dec    %ebx
  801485:	83 c4 10             	add    $0x10,%esp
  801488:	85 db                	test   %ebx,%ebx
  80148a:	7f ef                	jg     80147b <vprintfmt+0x24a>
  80148c:	e9 c4 fd ff ff       	jmp    801255 <vprintfmt+0x24>
  801491:	89 5d d8             	mov    %ebx,-0x28(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  801494:	89 ca                	mov    %ecx,%edx
  801496:	8d 45 14             	lea    0x14(%ebp),%eax
  801499:	e8 2a fd ff ff       	call   8011c8 <getint>
  80149e:	89 c3                	mov    %eax,%ebx
  8014a0:	89 d6                	mov    %edx,%esi
			if ((long long) num < 0) {
  8014a2:	85 d2                	test   %edx,%edx
  8014a4:	78 0a                	js     8014b0 <vprintfmt+0x27f>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8014a6:	b8 0a 00 00 00       	mov    $0xa,%eax
  8014ab:	e9 b0 00 00 00       	jmp    801560 <vprintfmt+0x32f>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  8014b0:	83 ec 08             	sub    $0x8,%esp
  8014b3:	57                   	push   %edi
  8014b4:	6a 2d                	push   $0x2d
  8014b6:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  8014b9:	f7 db                	neg    %ebx
  8014bb:	83 d6 00             	adc    $0x0,%esi
  8014be:	f7 de                	neg    %esi
  8014c0:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  8014c3:	b8 0a 00 00 00       	mov    $0xa,%eax
  8014c8:	e9 93 00 00 00       	jmp    801560 <vprintfmt+0x32f>
  8014cd:	89 5d d8             	mov    %ebx,-0x28(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8014d0:	89 ca                	mov    %ecx,%edx
  8014d2:	8d 45 14             	lea    0x14(%ebp),%eax
  8014d5:	e8 b4 fc ff ff       	call   80118e <getuint>
  8014da:	89 c3                	mov    %eax,%ebx
  8014dc:	89 d6                	mov    %edx,%esi
			base = 10;
  8014de:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  8014e3:	eb 7b                	jmp    801560 <vprintfmt+0x32f>
  8014e5:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// (unsigned) octal
		case 'o':
            // (MIT 6.828, lab1, Ex.8)  my code : 
            num = getint(&ap, lflag);
  8014e8:	89 ca                	mov    %ecx,%edx
  8014ea:	8d 45 14             	lea    0x14(%ebp),%eax
  8014ed:	e8 d6 fc ff ff       	call   8011c8 <getint>
  8014f2:	89 c3                	mov    %eax,%ebx
  8014f4:	89 d6                	mov    %edx,%esi
            if ((long long) num < 0) {
  8014f6:	85 d2                	test   %edx,%edx
  8014f8:	78 07                	js     801501 <vprintfmt+0x2d0>
                putch('-', putdat);
                num = -(long long) num;
            }
            base = 8;
  8014fa:	b8 08 00 00 00       	mov    $0x8,%eax
  8014ff:	eb 5f                	jmp    801560 <vprintfmt+0x32f>
		// (unsigned) octal
		case 'o':
            // (MIT 6.828, lab1, Ex.8)  my code : 
            num = getint(&ap, lflag);
            if ((long long) num < 0) {
                putch('-', putdat);
  801501:	83 ec 08             	sub    $0x8,%esp
  801504:	57                   	push   %edi
  801505:	6a 2d                	push   $0x2d
  801507:	ff 55 08             	call   *0x8(%ebp)
                num = -(long long) num;
  80150a:	f7 db                	neg    %ebx
  80150c:	83 d6 00             	adc    $0x0,%esi
  80150f:	f7 de                	neg    %esi
  801511:	83 c4 10             	add    $0x10,%esp
            }
            base = 8;
  801514:	b8 08 00 00 00       	mov    $0x8,%eax
  801519:	eb 45                	jmp    801560 <vprintfmt+0x32f>
  80151b:	89 5d d8             	mov    %ebx,-0x28(%ebp)
            goto number;

        // pointer
		case 'p':
			putch('0', putdat);
  80151e:	83 ec 08             	sub    $0x8,%esp
  801521:	57                   	push   %edi
  801522:	6a 30                	push   $0x30
  801524:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  801527:	83 c4 08             	add    $0x8,%esp
  80152a:	57                   	push   %edi
  80152b:	6a 78                	push   $0x78
  80152d:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  801530:	8b 45 14             	mov    0x14(%ebp),%eax
  801533:	8d 50 04             	lea    0x4(%eax),%edx
  801536:	89 55 14             	mov    %edx,0x14(%ebp)

        // pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  801539:	8b 18                	mov    (%eax),%ebx
  80153b:	be 00 00 00 00       	mov    $0x0,%esi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  801540:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  801543:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  801548:	eb 16                	jmp    801560 <vprintfmt+0x32f>
  80154a:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  80154d:	89 ca                	mov    %ecx,%edx
  80154f:	8d 45 14             	lea    0x14(%ebp),%eax
  801552:	e8 37 fc ff ff       	call   80118e <getuint>
  801557:	89 c3                	mov    %eax,%ebx
  801559:	89 d6                	mov    %edx,%esi
			base = 16;
  80155b:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  801560:	83 ec 0c             	sub    $0xc,%esp
  801563:	0f be 55 dc          	movsbl -0x24(%ebp),%edx
  801567:	52                   	push   %edx
  801568:	ff 75 e4             	pushl  -0x1c(%ebp)
  80156b:	50                   	push   %eax
  80156c:	56                   	push   %esi
  80156d:	53                   	push   %ebx
  80156e:	89 fa                	mov    %edi,%edx
  801570:	8b 45 08             	mov    0x8(%ebp),%eax
  801573:	e8 68 fb ff ff       	call   8010e0 <printnum>
			break;
  801578:	83 c4 20             	add    $0x20,%esp
  80157b:	8b 75 d8             	mov    -0x28(%ebp),%esi
  80157e:	e9 d2 fc ff ff       	jmp    801255 <vprintfmt+0x24>
  801583:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  801586:	83 ec 08             	sub    $0x8,%esp
  801589:	57                   	push   %edi
  80158a:	52                   	push   %edx
  80158b:	ff 55 08             	call   *0x8(%ebp)
			break;
  80158e:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801591:	8b 75 d8             	mov    -0x28(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  801594:	e9 bc fc ff ff       	jmp    801255 <vprintfmt+0x24>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  801599:	83 ec 08             	sub    $0x8,%esp
  80159c:	57                   	push   %edi
  80159d:	6a 25                	push   $0x25
  80159f:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  8015a2:	83 c4 10             	add    $0x10,%esp
  8015a5:	eb 02                	jmp    8015a9 <vprintfmt+0x378>
  8015a7:	89 c6                	mov    %eax,%esi
  8015a9:	8d 46 ff             	lea    -0x1(%esi),%eax
  8015ac:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  8015b0:	75 f5                	jne    8015a7 <vprintfmt+0x376>
  8015b2:	e9 9e fc ff ff       	jmp    801255 <vprintfmt+0x24>
				/* do nothing */;
			break;
		}
	}
}
  8015b7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8015ba:	5b                   	pop    %ebx
  8015bb:	5e                   	pop    %esi
  8015bc:	5f                   	pop    %edi
  8015bd:	c9                   	leave  
  8015be:	c3                   	ret    

008015bf <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8015bf:	55                   	push   %ebp
  8015c0:	89 e5                	mov    %esp,%ebp
  8015c2:	83 ec 18             	sub    $0x18,%esp
  8015c5:	8b 45 08             	mov    0x8(%ebp),%eax
  8015c8:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8015cb:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8015ce:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8015d2:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8015d5:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8015dc:	85 c0                	test   %eax,%eax
  8015de:	74 26                	je     801606 <vsnprintf+0x47>
  8015e0:	85 d2                	test   %edx,%edx
  8015e2:	7e 29                	jle    80160d <vsnprintf+0x4e>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8015e4:	ff 75 14             	pushl  0x14(%ebp)
  8015e7:	ff 75 10             	pushl  0x10(%ebp)
  8015ea:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8015ed:	50                   	push   %eax
  8015ee:	68 fa 11 80 00       	push   $0x8011fa
  8015f3:	e8 39 fc ff ff       	call   801231 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8015f8:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8015fb:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8015fe:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801601:	83 c4 10             	add    $0x10,%esp
  801604:	eb 0c                	jmp    801612 <vsnprintf+0x53>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  801606:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80160b:	eb 05                	jmp    801612 <vsnprintf+0x53>
  80160d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  801612:	c9                   	leave  
  801613:	c3                   	ret    

00801614 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  801614:	55                   	push   %ebp
  801615:	89 e5                	mov    %esp,%ebp
  801617:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80161a:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80161d:	50                   	push   %eax
  80161e:	ff 75 10             	pushl  0x10(%ebp)
  801621:	ff 75 0c             	pushl  0xc(%ebp)
  801624:	ff 75 08             	pushl  0x8(%ebp)
  801627:	e8 93 ff ff ff       	call   8015bf <vsnprintf>
	va_end(ap);

	return rc;
}
  80162c:	c9                   	leave  
  80162d:	c3                   	ret    
	...

00801630 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  801630:	55                   	push   %ebp
  801631:	89 e5                	mov    %esp,%ebp
  801633:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  801636:	80 3a 00             	cmpb   $0x0,(%edx)
  801639:	74 0e                	je     801649 <strlen+0x19>
  80163b:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  801640:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  801641:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  801645:	75 f9                	jne    801640 <strlen+0x10>
  801647:	eb 05                	jmp    80164e <strlen+0x1e>
  801649:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  80164e:	c9                   	leave  
  80164f:	c3                   	ret    

00801650 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  801650:	55                   	push   %ebp
  801651:	89 e5                	mov    %esp,%ebp
  801653:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801656:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801659:	85 d2                	test   %edx,%edx
  80165b:	74 17                	je     801674 <strnlen+0x24>
  80165d:	80 39 00             	cmpb   $0x0,(%ecx)
  801660:	74 19                	je     80167b <strnlen+0x2b>
  801662:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  801667:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801668:	39 d0                	cmp    %edx,%eax
  80166a:	74 14                	je     801680 <strnlen+0x30>
  80166c:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  801670:	75 f5                	jne    801667 <strnlen+0x17>
  801672:	eb 0c                	jmp    801680 <strnlen+0x30>
  801674:	b8 00 00 00 00       	mov    $0x0,%eax
  801679:	eb 05                	jmp    801680 <strnlen+0x30>
  80167b:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  801680:	c9                   	leave  
  801681:	c3                   	ret    

00801682 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  801682:	55                   	push   %ebp
  801683:	89 e5                	mov    %esp,%ebp
  801685:	53                   	push   %ebx
  801686:	8b 45 08             	mov    0x8(%ebp),%eax
  801689:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  80168c:	ba 00 00 00 00       	mov    $0x0,%edx
  801691:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  801694:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  801697:	42                   	inc    %edx
  801698:	84 c9                	test   %cl,%cl
  80169a:	75 f5                	jne    801691 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  80169c:	5b                   	pop    %ebx
  80169d:	c9                   	leave  
  80169e:	c3                   	ret    

0080169f <strcat>:

char *
strcat(char *dst, const char *src)
{
  80169f:	55                   	push   %ebp
  8016a0:	89 e5                	mov    %esp,%ebp
  8016a2:	53                   	push   %ebx
  8016a3:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8016a6:	53                   	push   %ebx
  8016a7:	e8 84 ff ff ff       	call   801630 <strlen>
  8016ac:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8016af:	ff 75 0c             	pushl  0xc(%ebp)
  8016b2:	8d 04 03             	lea    (%ebx,%eax,1),%eax
  8016b5:	50                   	push   %eax
  8016b6:	e8 c7 ff ff ff       	call   801682 <strcpy>
	return dst;
}
  8016bb:	89 d8                	mov    %ebx,%eax
  8016bd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016c0:	c9                   	leave  
  8016c1:	c3                   	ret    

008016c2 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8016c2:	55                   	push   %ebp
  8016c3:	89 e5                	mov    %esp,%ebp
  8016c5:	56                   	push   %esi
  8016c6:	53                   	push   %ebx
  8016c7:	8b 45 08             	mov    0x8(%ebp),%eax
  8016ca:	8b 55 0c             	mov    0xc(%ebp),%edx
  8016cd:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8016d0:	85 f6                	test   %esi,%esi
  8016d2:	74 15                	je     8016e9 <strncpy+0x27>
  8016d4:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
  8016d9:	8a 1a                	mov    (%edx),%bl
  8016db:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8016de:	80 3a 01             	cmpb   $0x1,(%edx)
  8016e1:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8016e4:	41                   	inc    %ecx
  8016e5:	39 ce                	cmp    %ecx,%esi
  8016e7:	77 f0                	ja     8016d9 <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8016e9:	5b                   	pop    %ebx
  8016ea:	5e                   	pop    %esi
  8016eb:	c9                   	leave  
  8016ec:	c3                   	ret    

008016ed <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8016ed:	55                   	push   %ebp
  8016ee:	89 e5                	mov    %esp,%ebp
  8016f0:	57                   	push   %edi
  8016f1:	56                   	push   %esi
  8016f2:	53                   	push   %ebx
  8016f3:	8b 7d 08             	mov    0x8(%ebp),%edi
  8016f6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8016f9:	8b 75 10             	mov    0x10(%ebp),%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8016fc:	85 f6                	test   %esi,%esi
  8016fe:	74 32                	je     801732 <strlcpy+0x45>
		while (--size > 0 && *src != '\0')
  801700:	83 fe 01             	cmp    $0x1,%esi
  801703:	74 22                	je     801727 <strlcpy+0x3a>
  801705:	8a 0b                	mov    (%ebx),%cl
  801707:	84 c9                	test   %cl,%cl
  801709:	74 20                	je     80172b <strlcpy+0x3e>
  80170b:	89 f8                	mov    %edi,%eax
  80170d:	ba 00 00 00 00       	mov    $0x0,%edx
	}
	return ret;
}

size_t
strlcpy(char *dst, const char *src, size_t size)
  801712:	83 ee 02             	sub    $0x2,%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  801715:	88 08                	mov    %cl,(%eax)
  801717:	40                   	inc    %eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  801718:	39 f2                	cmp    %esi,%edx
  80171a:	74 11                	je     80172d <strlcpy+0x40>
  80171c:	8a 4c 13 01          	mov    0x1(%ebx,%edx,1),%cl
  801720:	42                   	inc    %edx
  801721:	84 c9                	test   %cl,%cl
  801723:	75 f0                	jne    801715 <strlcpy+0x28>
  801725:	eb 06                	jmp    80172d <strlcpy+0x40>
  801727:	89 f8                	mov    %edi,%eax
  801729:	eb 02                	jmp    80172d <strlcpy+0x40>
  80172b:	89 f8                	mov    %edi,%eax
			*dst++ = *src++;
		*dst = '\0';
  80172d:	c6 00 00             	movb   $0x0,(%eax)
  801730:	eb 02                	jmp    801734 <strlcpy+0x47>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  801732:	89 f8                	mov    %edi,%eax
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
		*dst = '\0';
	}
	return dst - dst_in;
  801734:	29 f8                	sub    %edi,%eax
}
  801736:	5b                   	pop    %ebx
  801737:	5e                   	pop    %esi
  801738:	5f                   	pop    %edi
  801739:	c9                   	leave  
  80173a:	c3                   	ret    

0080173b <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80173b:	55                   	push   %ebp
  80173c:	89 e5                	mov    %esp,%ebp
  80173e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801741:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  801744:	8a 01                	mov    (%ecx),%al
  801746:	84 c0                	test   %al,%al
  801748:	74 10                	je     80175a <strcmp+0x1f>
  80174a:	3a 02                	cmp    (%edx),%al
  80174c:	75 0c                	jne    80175a <strcmp+0x1f>
		p++, q++;
  80174e:	41                   	inc    %ecx
  80174f:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  801750:	8a 01                	mov    (%ecx),%al
  801752:	84 c0                	test   %al,%al
  801754:	74 04                	je     80175a <strcmp+0x1f>
  801756:	3a 02                	cmp    (%edx),%al
  801758:	74 f4                	je     80174e <strcmp+0x13>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  80175a:	0f b6 c0             	movzbl %al,%eax
  80175d:	0f b6 12             	movzbl (%edx),%edx
  801760:	29 d0                	sub    %edx,%eax
}
  801762:	c9                   	leave  
  801763:	c3                   	ret    

00801764 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  801764:	55                   	push   %ebp
  801765:	89 e5                	mov    %esp,%ebp
  801767:	53                   	push   %ebx
  801768:	8b 55 08             	mov    0x8(%ebp),%edx
  80176b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80176e:	8b 45 10             	mov    0x10(%ebp),%eax
	while (n > 0 && *p && *p == *q)
  801771:	85 c0                	test   %eax,%eax
  801773:	74 1b                	je     801790 <strncmp+0x2c>
  801775:	8a 1a                	mov    (%edx),%bl
  801777:	84 db                	test   %bl,%bl
  801779:	74 24                	je     80179f <strncmp+0x3b>
  80177b:	3a 19                	cmp    (%ecx),%bl
  80177d:	75 20                	jne    80179f <strncmp+0x3b>
  80177f:	48                   	dec    %eax
  801780:	74 15                	je     801797 <strncmp+0x33>
		n--, p++, q++;
  801782:	42                   	inc    %edx
  801783:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  801784:	8a 1a                	mov    (%edx),%bl
  801786:	84 db                	test   %bl,%bl
  801788:	74 15                	je     80179f <strncmp+0x3b>
  80178a:	3a 19                	cmp    (%ecx),%bl
  80178c:	74 f1                	je     80177f <strncmp+0x1b>
  80178e:	eb 0f                	jmp    80179f <strncmp+0x3b>
		n--, p++, q++;
	if (n == 0)
		return 0;
  801790:	b8 00 00 00 00       	mov    $0x0,%eax
  801795:	eb 05                	jmp    80179c <strncmp+0x38>
  801797:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  80179c:	5b                   	pop    %ebx
  80179d:	c9                   	leave  
  80179e:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80179f:	0f b6 02             	movzbl (%edx),%eax
  8017a2:	0f b6 11             	movzbl (%ecx),%edx
  8017a5:	29 d0                	sub    %edx,%eax
  8017a7:	eb f3                	jmp    80179c <strncmp+0x38>

008017a9 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8017a9:	55                   	push   %ebp
  8017aa:	89 e5                	mov    %esp,%ebp
  8017ac:	8b 45 08             	mov    0x8(%ebp),%eax
  8017af:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  8017b2:	8a 10                	mov    (%eax),%dl
  8017b4:	84 d2                	test   %dl,%dl
  8017b6:	74 18                	je     8017d0 <strchr+0x27>
		if (*s == c)
  8017b8:	38 ca                	cmp    %cl,%dl
  8017ba:	75 06                	jne    8017c2 <strchr+0x19>
  8017bc:	eb 17                	jmp    8017d5 <strchr+0x2c>
  8017be:	38 ca                	cmp    %cl,%dl
  8017c0:	74 13                	je     8017d5 <strchr+0x2c>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8017c2:	40                   	inc    %eax
  8017c3:	8a 10                	mov    (%eax),%dl
  8017c5:	84 d2                	test   %dl,%dl
  8017c7:	75 f5                	jne    8017be <strchr+0x15>
		if (*s == c)
			return (char *) s;
	return 0;
  8017c9:	b8 00 00 00 00       	mov    $0x0,%eax
  8017ce:	eb 05                	jmp    8017d5 <strchr+0x2c>
  8017d0:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8017d5:	c9                   	leave  
  8017d6:	c3                   	ret    

008017d7 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8017d7:	55                   	push   %ebp
  8017d8:	89 e5                	mov    %esp,%ebp
  8017da:	8b 45 08             	mov    0x8(%ebp),%eax
  8017dd:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  8017e0:	8a 10                	mov    (%eax),%dl
  8017e2:	84 d2                	test   %dl,%dl
  8017e4:	74 11                	je     8017f7 <strfind+0x20>
		if (*s == c)
  8017e6:	38 ca                	cmp    %cl,%dl
  8017e8:	75 06                	jne    8017f0 <strfind+0x19>
  8017ea:	eb 0b                	jmp    8017f7 <strfind+0x20>
  8017ec:	38 ca                	cmp    %cl,%dl
  8017ee:	74 07                	je     8017f7 <strfind+0x20>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  8017f0:	40                   	inc    %eax
  8017f1:	8a 10                	mov    (%eax),%dl
  8017f3:	84 d2                	test   %dl,%dl
  8017f5:	75 f5                	jne    8017ec <strfind+0x15>
		if (*s == c)
			break;
	return (char *) s;
}
  8017f7:	c9                   	leave  
  8017f8:	c3                   	ret    

008017f9 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8017f9:	55                   	push   %ebp
  8017fa:	89 e5                	mov    %esp,%ebp
  8017fc:	57                   	push   %edi
  8017fd:	56                   	push   %esi
  8017fe:	53                   	push   %ebx
  8017ff:	8b 7d 08             	mov    0x8(%ebp),%edi
  801802:	8b 45 0c             	mov    0xc(%ebp),%eax
  801805:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  801808:	85 c9                	test   %ecx,%ecx
  80180a:	74 30                	je     80183c <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  80180c:	f7 c7 03 00 00 00    	test   $0x3,%edi
  801812:	75 25                	jne    801839 <memset+0x40>
  801814:	f6 c1 03             	test   $0x3,%cl
  801817:	75 20                	jne    801839 <memset+0x40>
		c &= 0xFF;
  801819:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  80181c:	89 d3                	mov    %edx,%ebx
  80181e:	c1 e3 08             	shl    $0x8,%ebx
  801821:	89 d6                	mov    %edx,%esi
  801823:	c1 e6 18             	shl    $0x18,%esi
  801826:	89 d0                	mov    %edx,%eax
  801828:	c1 e0 10             	shl    $0x10,%eax
  80182b:	09 f0                	or     %esi,%eax
  80182d:	09 d0                	or     %edx,%eax
  80182f:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  801831:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  801834:	fc                   	cld    
  801835:	f3 ab                	rep stos %eax,%es:(%edi)
  801837:	eb 03                	jmp    80183c <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  801839:	fc                   	cld    
  80183a:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  80183c:	89 f8                	mov    %edi,%eax
  80183e:	5b                   	pop    %ebx
  80183f:	5e                   	pop    %esi
  801840:	5f                   	pop    %edi
  801841:	c9                   	leave  
  801842:	c3                   	ret    

00801843 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  801843:	55                   	push   %ebp
  801844:	89 e5                	mov    %esp,%ebp
  801846:	57                   	push   %edi
  801847:	56                   	push   %esi
  801848:	8b 45 08             	mov    0x8(%ebp),%eax
  80184b:	8b 75 0c             	mov    0xc(%ebp),%esi
  80184e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  801851:	39 c6                	cmp    %eax,%esi
  801853:	73 34                	jae    801889 <memmove+0x46>
  801855:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  801858:	39 d0                	cmp    %edx,%eax
  80185a:	73 2d                	jae    801889 <memmove+0x46>
		s += n;
		d += n;
  80185c:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80185f:	f6 c2 03             	test   $0x3,%dl
  801862:	75 1b                	jne    80187f <memmove+0x3c>
  801864:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80186a:	75 13                	jne    80187f <memmove+0x3c>
  80186c:	f6 c1 03             	test   $0x3,%cl
  80186f:	75 0e                	jne    80187f <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  801871:	83 ef 04             	sub    $0x4,%edi
  801874:	8d 72 fc             	lea    -0x4(%edx),%esi
  801877:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  80187a:	fd                   	std    
  80187b:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80187d:	eb 07                	jmp    801886 <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  80187f:	4f                   	dec    %edi
  801880:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  801883:	fd                   	std    
  801884:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  801886:	fc                   	cld    
  801887:	eb 20                	jmp    8018a9 <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801889:	f7 c6 03 00 00 00    	test   $0x3,%esi
  80188f:	75 13                	jne    8018a4 <memmove+0x61>
  801891:	a8 03                	test   $0x3,%al
  801893:	75 0f                	jne    8018a4 <memmove+0x61>
  801895:	f6 c1 03             	test   $0x3,%cl
  801898:	75 0a                	jne    8018a4 <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  80189a:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  80189d:	89 c7                	mov    %eax,%edi
  80189f:	fc                   	cld    
  8018a0:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8018a2:	eb 05                	jmp    8018a9 <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8018a4:	89 c7                	mov    %eax,%edi
  8018a6:	fc                   	cld    
  8018a7:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8018a9:	5e                   	pop    %esi
  8018aa:	5f                   	pop    %edi
  8018ab:	c9                   	leave  
  8018ac:	c3                   	ret    

008018ad <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8018ad:	55                   	push   %ebp
  8018ae:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  8018b0:	ff 75 10             	pushl  0x10(%ebp)
  8018b3:	ff 75 0c             	pushl  0xc(%ebp)
  8018b6:	ff 75 08             	pushl  0x8(%ebp)
  8018b9:	e8 85 ff ff ff       	call   801843 <memmove>
}
  8018be:	c9                   	leave  
  8018bf:	c3                   	ret    

008018c0 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8018c0:	55                   	push   %ebp
  8018c1:	89 e5                	mov    %esp,%ebp
  8018c3:	57                   	push   %edi
  8018c4:	56                   	push   %esi
  8018c5:	53                   	push   %ebx
  8018c6:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8018c9:	8b 75 0c             	mov    0xc(%ebp),%esi
  8018cc:	8b 7d 10             	mov    0x10(%ebp),%edi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8018cf:	85 ff                	test   %edi,%edi
  8018d1:	74 32                	je     801905 <memcmp+0x45>
		if (*s1 != *s2)
  8018d3:	8a 03                	mov    (%ebx),%al
  8018d5:	8a 0e                	mov    (%esi),%cl
  8018d7:	38 c8                	cmp    %cl,%al
  8018d9:	74 19                	je     8018f4 <memcmp+0x34>
  8018db:	eb 0d                	jmp    8018ea <memcmp+0x2a>
  8018dd:	8a 44 13 01          	mov    0x1(%ebx,%edx,1),%al
  8018e1:	8a 4c 16 01          	mov    0x1(%esi,%edx,1),%cl
  8018e5:	42                   	inc    %edx
  8018e6:	38 c8                	cmp    %cl,%al
  8018e8:	74 10                	je     8018fa <memcmp+0x3a>
			return (int) *s1 - (int) *s2;
  8018ea:	0f b6 c0             	movzbl %al,%eax
  8018ed:	0f b6 c9             	movzbl %cl,%ecx
  8018f0:	29 c8                	sub    %ecx,%eax
  8018f2:	eb 16                	jmp    80190a <memcmp+0x4a>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8018f4:	4f                   	dec    %edi
  8018f5:	ba 00 00 00 00       	mov    $0x0,%edx
  8018fa:	39 fa                	cmp    %edi,%edx
  8018fc:	75 df                	jne    8018dd <memcmp+0x1d>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  8018fe:	b8 00 00 00 00       	mov    $0x0,%eax
  801903:	eb 05                	jmp    80190a <memcmp+0x4a>
  801905:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80190a:	5b                   	pop    %ebx
  80190b:	5e                   	pop    %esi
  80190c:	5f                   	pop    %edi
  80190d:	c9                   	leave  
  80190e:	c3                   	ret    

0080190f <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  80190f:	55                   	push   %ebp
  801910:	89 e5                	mov    %esp,%ebp
  801912:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  801915:	89 c2                	mov    %eax,%edx
  801917:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  80191a:	39 d0                	cmp    %edx,%eax
  80191c:	73 12                	jae    801930 <memfind+0x21>
		if (*(const unsigned char *) s == (unsigned char) c)
  80191e:	8a 4d 0c             	mov    0xc(%ebp),%cl
  801921:	38 08                	cmp    %cl,(%eax)
  801923:	75 06                	jne    80192b <memfind+0x1c>
  801925:	eb 09                	jmp    801930 <memfind+0x21>
  801927:	38 08                	cmp    %cl,(%eax)
  801929:	74 05                	je     801930 <memfind+0x21>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  80192b:	40                   	inc    %eax
  80192c:	39 c2                	cmp    %eax,%edx
  80192e:	77 f7                	ja     801927 <memfind+0x18>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  801930:	c9                   	leave  
  801931:	c3                   	ret    

00801932 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  801932:	55                   	push   %ebp
  801933:	89 e5                	mov    %esp,%ebp
  801935:	57                   	push   %edi
  801936:	56                   	push   %esi
  801937:	53                   	push   %ebx
  801938:	8b 55 08             	mov    0x8(%ebp),%edx
  80193b:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  80193e:	eb 01                	jmp    801941 <strtol+0xf>
		s++;
  801940:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801941:	8a 02                	mov    (%edx),%al
  801943:	3c 20                	cmp    $0x20,%al
  801945:	74 f9                	je     801940 <strtol+0xe>
  801947:	3c 09                	cmp    $0x9,%al
  801949:	74 f5                	je     801940 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  80194b:	3c 2b                	cmp    $0x2b,%al
  80194d:	75 08                	jne    801957 <strtol+0x25>
		s++;
  80194f:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  801950:	bf 00 00 00 00       	mov    $0x0,%edi
  801955:	eb 13                	jmp    80196a <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  801957:	3c 2d                	cmp    $0x2d,%al
  801959:	75 0a                	jne    801965 <strtol+0x33>
		s++, neg = 1;
  80195b:	8d 52 01             	lea    0x1(%edx),%edx
  80195e:	bf 01 00 00 00       	mov    $0x1,%edi
  801963:	eb 05                	jmp    80196a <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  801965:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  80196a:	85 db                	test   %ebx,%ebx
  80196c:	74 05                	je     801973 <strtol+0x41>
  80196e:	83 fb 10             	cmp    $0x10,%ebx
  801971:	75 28                	jne    80199b <strtol+0x69>
  801973:	8a 02                	mov    (%edx),%al
  801975:	3c 30                	cmp    $0x30,%al
  801977:	75 10                	jne    801989 <strtol+0x57>
  801979:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  80197d:	75 0a                	jne    801989 <strtol+0x57>
		s += 2, base = 16;
  80197f:	83 c2 02             	add    $0x2,%edx
  801982:	bb 10 00 00 00       	mov    $0x10,%ebx
  801987:	eb 12                	jmp    80199b <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  801989:	85 db                	test   %ebx,%ebx
  80198b:	75 0e                	jne    80199b <strtol+0x69>
  80198d:	3c 30                	cmp    $0x30,%al
  80198f:	75 05                	jne    801996 <strtol+0x64>
		s++, base = 8;
  801991:	42                   	inc    %edx
  801992:	b3 08                	mov    $0x8,%bl
  801994:	eb 05                	jmp    80199b <strtol+0x69>
	else if (base == 0)
		base = 10;
  801996:	bb 0a 00 00 00       	mov    $0xa,%ebx
  80199b:	b8 00 00 00 00       	mov    $0x0,%eax
  8019a0:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  8019a2:	8a 0a                	mov    (%edx),%cl
  8019a4:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  8019a7:	80 fb 09             	cmp    $0x9,%bl
  8019aa:	77 08                	ja     8019b4 <strtol+0x82>
			dig = *s - '0';
  8019ac:	0f be c9             	movsbl %cl,%ecx
  8019af:	83 e9 30             	sub    $0x30,%ecx
  8019b2:	eb 1e                	jmp    8019d2 <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  8019b4:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  8019b7:	80 fb 19             	cmp    $0x19,%bl
  8019ba:	77 08                	ja     8019c4 <strtol+0x92>
			dig = *s - 'a' + 10;
  8019bc:	0f be c9             	movsbl %cl,%ecx
  8019bf:	83 e9 57             	sub    $0x57,%ecx
  8019c2:	eb 0e                	jmp    8019d2 <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  8019c4:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  8019c7:	80 fb 19             	cmp    $0x19,%bl
  8019ca:	77 13                	ja     8019df <strtol+0xad>
			dig = *s - 'A' + 10;
  8019cc:	0f be c9             	movsbl %cl,%ecx
  8019cf:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  8019d2:	39 f1                	cmp    %esi,%ecx
  8019d4:	7d 0d                	jge    8019e3 <strtol+0xb1>
			break;
		s++, val = (val * base) + dig;
  8019d6:	42                   	inc    %edx
  8019d7:	0f af c6             	imul   %esi,%eax
  8019da:	8d 04 01             	lea    (%ecx,%eax,1),%eax
		// we don't properly detect overflow!
	}
  8019dd:	eb c3                	jmp    8019a2 <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  8019df:	89 c1                	mov    %eax,%ecx
  8019e1:	eb 02                	jmp    8019e5 <strtol+0xb3>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  8019e3:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  8019e5:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8019e9:	74 05                	je     8019f0 <strtol+0xbe>
		*endptr = (char *) s;
  8019eb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8019ee:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  8019f0:	85 ff                	test   %edi,%edi
  8019f2:	74 04                	je     8019f8 <strtol+0xc6>
  8019f4:	89 c8                	mov    %ecx,%eax
  8019f6:	f7 d8                	neg    %eax
}
  8019f8:	5b                   	pop    %ebx
  8019f9:	5e                   	pop    %esi
  8019fa:	5f                   	pop    %edi
  8019fb:	c9                   	leave  
  8019fc:	c3                   	ret    
  8019fd:	00 00                	add    %al,(%eax)
	...

00801a00 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801a00:	55                   	push   %ebp
  801a01:	89 e5                	mov    %esp,%ebp
  801a03:	56                   	push   %esi
  801a04:	53                   	push   %ebx
  801a05:	8b 75 08             	mov    0x8(%ebp),%esi
  801a08:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a0b:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// cprintf("0x%x 0x%x 0x%x\n", (uint32_t)from_env_store, (uint32_t)pg, (uint32_t)perm_store);
	int r;
	if (pg != NULL) {
  801a0e:	85 c0                	test   %eax,%eax
  801a10:	74 0e                	je     801a20 <ipc_recv+0x20>
		r = sys_ipc_recv(pg);
  801a12:	83 ec 0c             	sub    $0xc,%esp
  801a15:	50                   	push   %eax
  801a16:	e8 b8 e8 ff ff       	call   8002d3 <sys_ipc_recv>
  801a1b:	83 c4 10             	add    $0x10,%esp
  801a1e:	eb 10                	jmp    801a30 <ipc_recv+0x30>
	} else {
		r = sys_ipc_recv((void *)UTOP);
  801a20:	83 ec 0c             	sub    $0xc,%esp
  801a23:	68 00 00 c0 ee       	push   $0xeec00000
  801a28:	e8 a6 e8 ff ff       	call   8002d3 <sys_ipc_recv>
  801a2d:	83 c4 10             	add    $0x10,%esp
	}

	if (r == 0) {
  801a30:	85 c0                	test   %eax,%eax
  801a32:	75 26                	jne    801a5a <ipc_recv+0x5a>
		if (from_env_store != NULL) *from_env_store = thisenv->env_ipc_from;
  801a34:	85 f6                	test   %esi,%esi
  801a36:	74 0a                	je     801a42 <ipc_recv+0x42>
  801a38:	a1 04 40 80 00       	mov    0x804004,%eax
  801a3d:	8b 40 74             	mov    0x74(%eax),%eax
  801a40:	89 06                	mov    %eax,(%esi)
		if (perm_store != NULL) *perm_store = thisenv->env_ipc_perm;
  801a42:	85 db                	test   %ebx,%ebx
  801a44:	74 0a                	je     801a50 <ipc_recv+0x50>
  801a46:	a1 04 40 80 00       	mov    0x804004,%eax
  801a4b:	8b 40 78             	mov    0x78(%eax),%eax
  801a4e:	89 03                	mov    %eax,(%ebx)
		return thisenv->env_ipc_value;
  801a50:	a1 04 40 80 00       	mov    0x804004,%eax
  801a55:	8b 40 70             	mov    0x70(%eax),%eax
  801a58:	eb 14                	jmp    801a6e <ipc_recv+0x6e>
	} else {
		// fails;
		if (from_env_store != NULL) *from_env_store = 0;
  801a5a:	85 f6                	test   %esi,%esi
  801a5c:	74 06                	je     801a64 <ipc_recv+0x64>
  801a5e:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		if (perm_store != NULL) *perm_store = 0;
  801a64:	85 db                	test   %ebx,%ebx
  801a66:	74 06                	je     801a6e <ipc_recv+0x6e>
  801a68:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
		return r;
	}
}
  801a6e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a71:	5b                   	pop    %ebx
  801a72:	5e                   	pop    %esi
  801a73:	c9                   	leave  
  801a74:	c3                   	ret    

00801a75 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801a75:	55                   	push   %ebp
  801a76:	89 e5                	mov    %esp,%ebp
  801a78:	57                   	push   %edi
  801a79:	56                   	push   %esi
  801a7a:	53                   	push   %ebx
  801a7b:	83 ec 0c             	sub    $0xc,%esp
  801a7e:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801a81:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801a84:	8b 75 14             	mov    0x14(%ebp),%esi
	// LAB 4: Your code here.
	// int sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
	int r;
	if (pg == NULL) pg = (void *)UTOP;
  801a87:	85 db                	test   %ebx,%ebx
  801a89:	75 25                	jne    801ab0 <ipc_send+0x3b>
  801a8b:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
  801a90:	eb 1e                	jmp    801ab0 <ipc_send+0x3b>
	
	while ((r = sys_ipc_try_send(to_env, val, pg, perm)) != 0) {
		if (r == -E_IPC_NOT_RECV) {
  801a92:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801a95:	75 07                	jne    801a9e <ipc_send+0x29>
			// cprintf("Try Again and Again....\n");
			sys_yield();
  801a97:	e8 15 e7 ff ff       	call   8001b1 <sys_yield>
  801a9c:	eb 12                	jmp    801ab0 <ipc_send+0x3b>
		} else {
			panic("ipc_send error %e\n", r);
  801a9e:	50                   	push   %eax
  801a9f:	68 00 22 80 00       	push   $0x802200
  801aa4:	6a 43                	push   $0x43
  801aa6:	68 13 22 80 00       	push   $0x802213
  801aab:	e8 44 f5 ff ff       	call   800ff4 <_panic>
	// LAB 4: Your code here.
	// int sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
	int r;
	if (pg == NULL) pg = (void *)UTOP;
	
	while ((r = sys_ipc_try_send(to_env, val, pg, perm)) != 0) {
  801ab0:	56                   	push   %esi
  801ab1:	53                   	push   %ebx
  801ab2:	57                   	push   %edi
  801ab3:	ff 75 08             	pushl  0x8(%ebp)
  801ab6:	e8 f3 e7 ff ff       	call   8002ae <sys_ipc_try_send>
  801abb:	83 c4 10             	add    $0x10,%esp
  801abe:	85 c0                	test   %eax,%eax
  801ac0:	75 d0                	jne    801a92 <ipc_send+0x1d>
		} else {
			panic("ipc_send error %e\n", r);
		}
	}
	return;
}
  801ac2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801ac5:	5b                   	pop    %ebx
  801ac6:	5e                   	pop    %esi
  801ac7:	5f                   	pop    %edi
  801ac8:	c9                   	leave  
  801ac9:	c3                   	ret    

00801aca <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801aca:	55                   	push   %ebp
  801acb:	89 e5                	mov    %esp,%ebp
  801acd:	53                   	push   %ebx
  801ace:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	for (i = 0; i < NENV; i++)
		if (envs[i].env_type == type)
  801ad1:	39 1d 50 00 c0 ee    	cmp    %ebx,0xeec00050
  801ad7:	74 22                	je     801afb <ipc_find_env+0x31>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801ad9:	b8 01 00 00 00       	mov    $0x1,%eax
		if (envs[i].env_type == type)
  801ade:	8d 0c 85 00 00 00 00 	lea    0x0(,%eax,4),%ecx
  801ae5:	89 c2                	mov    %eax,%edx
  801ae7:	c1 e2 07             	shl    $0x7,%edx
  801aea:	29 ca                	sub    %ecx,%edx
  801aec:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801af2:	8b 52 50             	mov    0x50(%edx),%edx
  801af5:	39 da                	cmp    %ebx,%edx
  801af7:	75 1d                	jne    801b16 <ipc_find_env+0x4c>
  801af9:	eb 05                	jmp    801b00 <ipc_find_env+0x36>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801afb:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
			return envs[i].env_id;
  801b00:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  801b07:	c1 e0 07             	shl    $0x7,%eax
  801b0a:	29 d0                	sub    %edx,%eax
  801b0c:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  801b11:	8b 40 40             	mov    0x40(%eax),%eax
  801b14:	eb 0c                	jmp    801b22 <ipc_find_env+0x58>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801b16:	40                   	inc    %eax
  801b17:	3d 00 04 00 00       	cmp    $0x400,%eax
  801b1c:	75 c0                	jne    801ade <ipc_find_env+0x14>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801b1e:	66 b8 00 00          	mov    $0x0,%ax
}
  801b22:	5b                   	pop    %ebx
  801b23:	c9                   	leave  
  801b24:	c3                   	ret    
  801b25:	00 00                	add    %al,(%eax)
	...

00801b28 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801b28:	55                   	push   %ebp
  801b29:	89 e5                	mov    %esp,%ebp
  801b2b:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801b2e:	89 c2                	mov    %eax,%edx
  801b30:	c1 ea 16             	shr    $0x16,%edx
  801b33:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801b3a:	f6 c2 01             	test   $0x1,%dl
  801b3d:	74 1e                	je     801b5d <pageref+0x35>
		return 0;
	pte = uvpt[PGNUM(v)];
  801b3f:	c1 e8 0c             	shr    $0xc,%eax
  801b42:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  801b49:	a8 01                	test   $0x1,%al
  801b4b:	74 17                	je     801b64 <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801b4d:	c1 e8 0c             	shr    $0xc,%eax
  801b50:	66 8b 04 c5 04 00 00 	mov    -0x10fffffc(,%eax,8),%ax
  801b57:	ef 
  801b58:	0f b7 c0             	movzwl %ax,%eax
  801b5b:	eb 0c                	jmp    801b69 <pageref+0x41>
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
		return 0;
  801b5d:	b8 00 00 00 00       	mov    $0x0,%eax
  801b62:	eb 05                	jmp    801b69 <pageref+0x41>
	pte = uvpt[PGNUM(v)];
	if (!(pte & PTE_P))
		return 0;
  801b64:	b8 00 00 00 00       	mov    $0x0,%eax
	return pages[PGNUM(pte)].pp_ref;
}
  801b69:	c9                   	leave  
  801b6a:	c3                   	ret    
	...

00801b6c <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  801b6c:	55                   	push   %ebp
  801b6d:	89 e5                	mov    %esp,%ebp
  801b6f:	57                   	push   %edi
  801b70:	56                   	push   %esi
  801b71:	83 ec 10             	sub    $0x10,%esp
  801b74:	8b 7d 08             	mov    0x8(%ebp),%edi
  801b77:	8b 4d 10             	mov    0x10(%ebp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  801b7a:	89 7d f0             	mov    %edi,-0x10(%ebp)
  801b7d:	8b 75 0c             	mov    0xc(%ebp),%esi
  const DWunion dd = {.ll = d};
  801b80:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  801b83:	8b 45 14             	mov    0x14(%ebp),%eax
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  801b86:	85 c0                	test   %eax,%eax
  801b88:	75 2e                	jne    801bb8 <__udivdi3+0x4c>
    {
      if (d0 > n1)
  801b8a:	39 f1                	cmp    %esi,%ecx
  801b8c:	77 5a                	ja     801be8 <__udivdi3+0x7c>
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  801b8e:	85 c9                	test   %ecx,%ecx
  801b90:	75 0b                	jne    801b9d <__udivdi3+0x31>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  801b92:	b8 01 00 00 00       	mov    $0x1,%eax
  801b97:	31 d2                	xor    %edx,%edx
  801b99:	f7 f1                	div    %ecx
  801b9b:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  801b9d:	31 d2                	xor    %edx,%edx
  801b9f:	89 f0                	mov    %esi,%eax
  801ba1:	f7 f1                	div    %ecx
  801ba3:	89 c6                	mov    %eax,%esi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801ba5:	89 f8                	mov    %edi,%eax
  801ba7:	f7 f1                	div    %ecx
  801ba9:	89 c7                	mov    %eax,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  801bab:	89 f8                	mov    %edi,%eax
  801bad:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801baf:	83 c4 10             	add    $0x10,%esp
  801bb2:	5e                   	pop    %esi
  801bb3:	5f                   	pop    %edi
  801bb4:	c9                   	leave  
  801bb5:	c3                   	ret    
  801bb6:	66 90                	xchg   %ax,%ax
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  801bb8:	39 f0                	cmp    %esi,%eax
  801bba:	77 1c                	ja     801bd8 <__udivdi3+0x6c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  801bbc:	0f bd f8             	bsr    %eax,%edi
	  if (bm == 0)
  801bbf:	83 f7 1f             	xor    $0x1f,%edi
  801bc2:	75 3c                	jne    801c00 <__udivdi3+0x94>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  801bc4:	39 f0                	cmp    %esi,%eax
  801bc6:	0f 82 90 00 00 00    	jb     801c5c <__udivdi3+0xf0>
  801bcc:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801bcf:	39 55 f4             	cmp    %edx,-0xc(%ebp)
  801bd2:	0f 86 84 00 00 00    	jbe    801c5c <__udivdi3+0xf0>
  801bd8:	31 f6                	xor    %esi,%esi
  801bda:	31 ff                	xor    %edi,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  801bdc:	89 f8                	mov    %edi,%eax
  801bde:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801be0:	83 c4 10             	add    $0x10,%esp
  801be3:	5e                   	pop    %esi
  801be4:	5f                   	pop    %edi
  801be5:	c9                   	leave  
  801be6:	c3                   	ret    
  801be7:	90                   	nop
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801be8:	89 f2                	mov    %esi,%edx
  801bea:	89 f8                	mov    %edi,%eax
  801bec:	f7 f1                	div    %ecx
  801bee:	89 c7                	mov    %eax,%edi
  801bf0:	31 f6                	xor    %esi,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  801bf2:	89 f8                	mov    %edi,%eax
  801bf4:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801bf6:	83 c4 10             	add    $0x10,%esp
  801bf9:	5e                   	pop    %esi
  801bfa:	5f                   	pop    %edi
  801bfb:	c9                   	leave  
  801bfc:	c3                   	ret    
  801bfd:	8d 76 00             	lea    0x0(%esi),%esi
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  801c00:	89 f9                	mov    %edi,%ecx
  801c02:	d3 e0                	shl    %cl,%eax
  801c04:	89 45 e8             	mov    %eax,-0x18(%ebp)
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  801c07:	b8 20 00 00 00       	mov    $0x20,%eax
  801c0c:	29 f8                	sub    %edi,%eax

	      d1 = (d1 << bm) | (d0 >> b);
  801c0e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801c11:	88 c1                	mov    %al,%cl
  801c13:	d3 ea                	shr    %cl,%edx
  801c15:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  801c18:	09 ca                	or     %ecx,%edx
  801c1a:	89 55 ec             	mov    %edx,-0x14(%ebp)
	      d0 = d0 << bm;
  801c1d:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801c20:	89 f9                	mov    %edi,%ecx
  801c22:	d3 e2                	shl    %cl,%edx
  801c24:	89 55 f4             	mov    %edx,-0xc(%ebp)
	      n2 = n1 >> b;
  801c27:	89 f2                	mov    %esi,%edx
  801c29:	88 c1                	mov    %al,%cl
  801c2b:	d3 ea                	shr    %cl,%edx
  801c2d:	89 55 e8             	mov    %edx,-0x18(%ebp)
	      n1 = (n1 << bm) | (n0 >> b);
  801c30:	89 f2                	mov    %esi,%edx
  801c32:	89 f9                	mov    %edi,%ecx
  801c34:	d3 e2                	shl    %cl,%edx
  801c36:	8b 75 f0             	mov    -0x10(%ebp),%esi
  801c39:	88 c1                	mov    %al,%cl
  801c3b:	d3 ee                	shr    %cl,%esi
  801c3d:	09 d6                	or     %edx,%esi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  801c3f:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  801c42:	89 f0                	mov    %esi,%eax
  801c44:	89 ca                	mov    %ecx,%edx
  801c46:	f7 75 ec             	divl   -0x14(%ebp)
  801c49:	89 d1                	mov    %edx,%ecx
  801c4b:	89 c6                	mov    %eax,%esi
	      umul_ppmm (m1, m0, q0, d0);
  801c4d:	f7 65 f4             	mull   -0xc(%ebp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801c50:	39 d1                	cmp    %edx,%ecx
  801c52:	72 28                	jb     801c7c <__udivdi3+0x110>
  801c54:	74 1a                	je     801c70 <__udivdi3+0x104>
  801c56:	89 f7                	mov    %esi,%edi
  801c58:	31 f6                	xor    %esi,%esi
  801c5a:	eb 80                	jmp    801bdc <__udivdi3+0x70>
	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  801c5c:	31 f6                	xor    %esi,%esi
  801c5e:	bf 01 00 00 00       	mov    $0x1,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  801c63:	89 f8                	mov    %edi,%eax
  801c65:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801c67:	83 c4 10             	add    $0x10,%esp
  801c6a:	5e                   	pop    %esi
  801c6b:	5f                   	pop    %edi
  801c6c:	c9                   	leave  
  801c6d:	c3                   	ret    
  801c6e:	66 90                	xchg   %ax,%ax

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  801c70:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801c73:	89 f9                	mov    %edi,%ecx
  801c75:	d3 e2                	shl    %cl,%edx

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801c77:	39 c2                	cmp    %eax,%edx
  801c79:	73 db                	jae    801c56 <__udivdi3+0xea>
  801c7b:	90                   	nop
		{
		  q0--;
  801c7c:	8d 7e ff             	lea    -0x1(%esi),%edi
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  801c7f:	31 f6                	xor    %esi,%esi
  801c81:	e9 56 ff ff ff       	jmp    801bdc <__udivdi3+0x70>
	...

00801c88 <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  801c88:	55                   	push   %ebp
  801c89:	89 e5                	mov    %esp,%ebp
  801c8b:	57                   	push   %edi
  801c8c:	56                   	push   %esi
  801c8d:	83 ec 20             	sub    $0x20,%esp
  801c90:	8b 45 08             	mov    0x8(%ebp),%eax
  801c93:	8b 4d 10             	mov    0x10(%ebp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  801c96:	89 45 e8             	mov    %eax,-0x18(%ebp)
  801c99:	8b 75 0c             	mov    0xc(%ebp),%esi
  const DWunion dd = {.ll = d};
  801c9c:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  801c9f:	8b 7d 14             	mov    0x14(%ebp),%edi
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  801ca2:	89 45 f0             	mov    %eax,-0x10(%ebp)
  n1 = nn.s.high;
  801ca5:	89 f2                	mov    %esi,%edx

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  801ca7:	85 ff                	test   %edi,%edi
  801ca9:	75 15                	jne    801cc0 <__umoddi3+0x38>
    {
      if (d0 > n1)
  801cab:	39 f1                	cmp    %esi,%ecx
  801cad:	0f 86 99 00 00 00    	jbe    801d4c <__umoddi3+0xc4>
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801cb3:	f7 f1                	div    %ecx

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
  801cb5:	89 d0                	mov    %edx,%eax
  801cb7:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  801cb9:	83 c4 20             	add    $0x20,%esp
  801cbc:	5e                   	pop    %esi
  801cbd:	5f                   	pop    %edi
  801cbe:	c9                   	leave  
  801cbf:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  801cc0:	39 f7                	cmp    %esi,%edi
  801cc2:	0f 87 a4 00 00 00    	ja     801d6c <__umoddi3+0xe4>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  801cc8:	0f bd c7             	bsr    %edi,%eax
	  if (bm == 0)
  801ccb:	83 f0 1f             	xor    $0x1f,%eax
  801cce:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801cd1:	0f 84 a1 00 00 00    	je     801d78 <__umoddi3+0xf0>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  801cd7:	89 f8                	mov    %edi,%eax
  801cd9:	8a 4d ec             	mov    -0x14(%ebp),%cl
  801cdc:	d3 e0                	shl    %cl,%eax
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  801cde:	bf 20 00 00 00       	mov    $0x20,%edi
  801ce3:	2b 7d ec             	sub    -0x14(%ebp),%edi

	      d1 = (d1 << bm) | (d0 >> b);
  801ce6:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801ce9:	89 f9                	mov    %edi,%ecx
  801ceb:	d3 ea                	shr    %cl,%edx
  801ced:	09 c2                	or     %eax,%edx
  801cef:	89 55 f0             	mov    %edx,-0x10(%ebp)
	      d0 = d0 << bm;
  801cf2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801cf5:	8a 4d ec             	mov    -0x14(%ebp),%cl
  801cf8:	d3 e0                	shl    %cl,%eax
  801cfa:	89 45 f4             	mov    %eax,-0xc(%ebp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  801cfd:	89 f2                	mov    %esi,%edx
  801cff:	d3 e2                	shl    %cl,%edx
	      n0 = n0 << bm;
  801d01:	8b 45 e8             	mov    -0x18(%ebp),%eax
  801d04:	d3 e0                	shl    %cl,%eax
  801d06:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  801d09:	8b 45 e8             	mov    -0x18(%ebp),%eax
  801d0c:	89 f9                	mov    %edi,%ecx
  801d0e:	d3 e8                	shr    %cl,%eax
  801d10:	09 d0                	or     %edx,%eax

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  801d12:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  801d14:	89 f2                	mov    %esi,%edx
  801d16:	f7 75 f0             	divl   -0x10(%ebp)
  801d19:	89 d6                	mov    %edx,%esi
	      umul_ppmm (m1, m0, q0, d0);
  801d1b:	f7 65 f4             	mull   -0xc(%ebp)
  801d1e:	89 55 e8             	mov    %edx,-0x18(%ebp)
  801d21:	89 c1                	mov    %eax,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801d23:	39 d6                	cmp    %edx,%esi
  801d25:	72 71                	jb     801d98 <__umoddi3+0x110>
  801d27:	74 7f                	je     801da8 <__umoddi3+0x120>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  801d29:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801d2c:	29 c8                	sub    %ecx,%eax
  801d2e:	19 d6                	sbb    %edx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
  801d30:	8a 4d ec             	mov    -0x14(%ebp),%cl
  801d33:	d3 e8                	shr    %cl,%eax
  801d35:	89 f2                	mov    %esi,%edx
  801d37:	89 f9                	mov    %edi,%ecx
  801d39:	d3 e2                	shl    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
  801d3b:	09 d0                	or     %edx,%eax
  801d3d:	89 f2                	mov    %esi,%edx
  801d3f:	8a 4d ec             	mov    -0x14(%ebp),%cl
  801d42:	d3 ea                	shr    %cl,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  801d44:	83 c4 20             	add    $0x20,%esp
  801d47:	5e                   	pop    %esi
  801d48:	5f                   	pop    %edi
  801d49:	c9                   	leave  
  801d4a:	c3                   	ret    
  801d4b:	90                   	nop
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  801d4c:	85 c9                	test   %ecx,%ecx
  801d4e:	75 0b                	jne    801d5b <__umoddi3+0xd3>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  801d50:	b8 01 00 00 00       	mov    $0x1,%eax
  801d55:	31 d2                	xor    %edx,%edx
  801d57:	f7 f1                	div    %ecx
  801d59:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  801d5b:	89 f0                	mov    %esi,%eax
  801d5d:	31 d2                	xor    %edx,%edx
  801d5f:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801d61:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801d64:	f7 f1                	div    %ecx
  801d66:	e9 4a ff ff ff       	jmp    801cb5 <__umoddi3+0x2d>
  801d6b:	90                   	nop
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
  801d6c:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  801d6e:	83 c4 20             	add    $0x20,%esp
  801d71:	5e                   	pop    %esi
  801d72:	5f                   	pop    %edi
  801d73:	c9                   	leave  
  801d74:	c3                   	ret    
  801d75:	8d 76 00             	lea    0x0(%esi),%esi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  801d78:	39 f7                	cmp    %esi,%edi
  801d7a:	72 05                	jb     801d81 <__umoddi3+0xf9>
  801d7c:	3b 4d f0             	cmp    -0x10(%ebp),%ecx
  801d7f:	77 0c                	ja     801d8d <__umoddi3+0x105>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  801d81:	89 f2                	mov    %esi,%edx
  801d83:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801d86:	29 c8                	sub    %ecx,%eax
  801d88:	19 fa                	sbb    %edi,%edx
  801d8a:	89 45 f0             	mov    %eax,-0x10(%ebp)

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
  801d8d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  801d90:	83 c4 20             	add    $0x20,%esp
  801d93:	5e                   	pop    %esi
  801d94:	5f                   	pop    %edi
  801d95:	c9                   	leave  
  801d96:	c3                   	ret    
  801d97:	90                   	nop
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  801d98:	8b 55 e8             	mov    -0x18(%ebp),%edx
  801d9b:	89 c1                	mov    %eax,%ecx
  801d9d:	2b 4d f4             	sub    -0xc(%ebp),%ecx
  801da0:	1b 55 f0             	sbb    -0x10(%ebp),%edx
  801da3:	eb 84                	jmp    801d29 <__umoddi3+0xa1>
  801da5:	8d 76 00             	lea    0x0(%esi),%esi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801da8:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  801dab:	72 eb                	jb     801d98 <__umoddi3+0x110>
  801dad:	89 f2                	mov    %esi,%edx
  801daf:	e9 75 ff ff ff       	jmp    801d29 <__umoddi3+0xa1>
