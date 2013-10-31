
obj/user/faultwritekernel.debug:     file format elf32-i386


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
  80002c:	e8 13 00 00 00       	call   800044 <libmain>
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
	*(unsigned*)0xf0100000 = 0;
  800037:	c7 05 00 00 10 f0 00 	movl   $0x0,0xf0100000
  80003e:	00 00 00 
}
  800041:	c9                   	leave  
  800042:	c3                   	ret    
	...

00800044 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800044:	55                   	push   %ebp
  800045:	89 e5                	mov    %esp,%ebp
  800047:	56                   	push   %esi
  800048:	53                   	push   %ebx
  800049:	8b 75 08             	mov    0x8(%ebp),%esi
  80004c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = envs + ENVX(sys_getenvid());
  80004f:	e8 15 01 00 00       	call   800169 <sys_getenvid>
  800054:	25 ff 03 00 00       	and    $0x3ff,%eax
  800059:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  800060:	c1 e0 07             	shl    $0x7,%eax
  800063:	29 d0                	sub    %edx,%eax
  800065:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80006a:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80006f:	85 f6                	test   %esi,%esi
  800071:	7e 07                	jle    80007a <libmain+0x36>
		binaryname = argv[0];
  800073:	8b 03                	mov    (%ebx),%eax
  800075:	a3 00 30 80 00       	mov    %eax,0x803000
	// call user main routine
	umain(argc, argv);
  80007a:	83 ec 08             	sub    $0x8,%esp
  80007d:	53                   	push   %ebx
  80007e:	56                   	push   %esi
  80007f:	e8 b0 ff ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  800084:	e8 0b 00 00 00       	call   800094 <exit>
  800089:	83 c4 10             	add    $0x10,%esp
}
  80008c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80008f:	5b                   	pop    %ebx
  800090:	5e                   	pop    %esi
  800091:	c9                   	leave  
  800092:	c3                   	ret    
	...

00800094 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800094:	55                   	push   %ebp
  800095:	89 e5                	mov    %esp,%ebp
  800097:	83 ec 08             	sub    $0x8,%esp
	close_all();
  80009a:	e8 5f 04 00 00       	call   8004fe <close_all>
	sys_env_destroy(0);
  80009f:	83 ec 0c             	sub    $0xc,%esp
  8000a2:	6a 00                	push   $0x0
  8000a4:	e8 9e 00 00 00       	call   800147 <sys_env_destroy>
  8000a9:	83 c4 10             	add    $0x10,%esp
}
  8000ac:	c9                   	leave  
  8000ad:	c3                   	ret    
	...

008000b0 <syscall>:
	return ret;
}

static int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  8000b0:	55                   	push   %ebp
  8000b1:	89 e5                	mov    %esp,%ebp
  8000b3:	57                   	push   %edi
  8000b4:	56                   	push   %esi
  8000b5:	53                   	push   %ebx
  8000b6:	83 ec 1c             	sub    $0x1c,%esp
  8000b9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8000bc:	89 55 e0             	mov    %edx,-0x20(%ebp)
  8000bf:	89 ca                	mov    %ecx,%edx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000c1:	8b 75 14             	mov    0x14(%ebp),%esi
  8000c4:	8b 7d 10             	mov    0x10(%ebp),%edi
  8000c7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8000ca:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8000cd:	cd 30                	int    $0x30
  8000cf:	89 c2                	mov    %eax,%edx
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8000d1:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8000d5:	74 1c                	je     8000f3 <syscall+0x43>
  8000d7:	85 c0                	test   %eax,%eax
  8000d9:	7e 18                	jle    8000f3 <syscall+0x43>
		panic("syscall %d returned %d (> 0)", num, ret);
  8000db:	83 ec 0c             	sub    $0xc,%esp
  8000de:	50                   	push   %eax
  8000df:	ff 75 e4             	pushl  -0x1c(%ebp)
  8000e2:	68 8a 1d 80 00       	push   $0x801d8a
  8000e7:	6a 42                	push   $0x42
  8000e9:	68 a7 1d 80 00       	push   $0x801da7
  8000ee:	e8 b5 0e 00 00       	call   800fa8 <_panic>

	return ret;
}
  8000f3:	89 d0                	mov    %edx,%eax
  8000f5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8000f8:	5b                   	pop    %ebx
  8000f9:	5e                   	pop    %esi
  8000fa:	5f                   	pop    %edi
  8000fb:	c9                   	leave  
  8000fc:	c3                   	ret    

008000fd <sys_cputs>:

void
sys_cputs(const char *s, size_t len)
{	
  8000fd:	55                   	push   %ebp
  8000fe:	89 e5                	mov    %esp,%ebp
  800100:	83 ec 08             	sub    $0x8,%esp
	// my_sysenter(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
	// return;
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
  800103:	6a 00                	push   $0x0
  800105:	6a 00                	push   $0x0
  800107:	6a 00                	push   $0x0
  800109:	ff 75 0c             	pushl  0xc(%ebp)
  80010c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80010f:	ba 00 00 00 00       	mov    $0x0,%edx
  800114:	b8 00 00 00 00       	mov    $0x0,%eax
  800119:	e8 92 ff ff ff       	call   8000b0 <syscall>
  80011e:	83 c4 10             	add    $0x10,%esp
	return;
}
  800121:	c9                   	leave  
  800122:	c3                   	ret    

00800123 <sys_cgetc>:

int
sys_cgetc(void)
{
  800123:	55                   	push   %ebp
  800124:	89 e5                	mov    %esp,%ebp
  800126:	83 ec 08             	sub    $0x8,%esp
	// return my_sysenter(SYS_cgetc, 0, 0, 0, 0, 0, 0);
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
  800129:	6a 00                	push   $0x0
  80012b:	6a 00                	push   $0x0
  80012d:	6a 00                	push   $0x0
  80012f:	6a 00                	push   $0x0
  800131:	b9 00 00 00 00       	mov    $0x0,%ecx
  800136:	ba 00 00 00 00       	mov    $0x0,%edx
  80013b:	b8 01 00 00 00       	mov    $0x1,%eax
  800140:	e8 6b ff ff ff       	call   8000b0 <syscall>
}
  800145:	c9                   	leave  
  800146:	c3                   	ret    

00800147 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800147:	55                   	push   %ebp
  800148:	89 e5                	mov    %esp,%ebp
  80014a:	83 ec 08             	sub    $0x8,%esp
	// return my_sysenter(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
  80014d:	6a 00                	push   $0x0
  80014f:	6a 00                	push   $0x0
  800151:	6a 00                	push   $0x0
  800153:	6a 00                	push   $0x0
  800155:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800158:	ba 01 00 00 00       	mov    $0x1,%edx
  80015d:	b8 03 00 00 00       	mov    $0x3,%eax
  800162:	e8 49 ff ff ff       	call   8000b0 <syscall>
}
  800167:	c9                   	leave  
  800168:	c3                   	ret    

00800169 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800169:	55                   	push   %ebp
  80016a:	89 e5                	mov    %esp,%ebp
  80016c:	83 ec 08             	sub    $0x8,%esp
	// return my_sysenter(SYS_getenvid, 0, 0, 0, 0, 0, 0);
	return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
  80016f:	6a 00                	push   $0x0
  800171:	6a 00                	push   $0x0
  800173:	6a 00                	push   $0x0
  800175:	6a 00                	push   $0x0
  800177:	b9 00 00 00 00       	mov    $0x0,%ecx
  80017c:	ba 00 00 00 00       	mov    $0x0,%edx
  800181:	b8 02 00 00 00       	mov    $0x2,%eax
  800186:	e8 25 ff ff ff       	call   8000b0 <syscall>
}
  80018b:	c9                   	leave  
  80018c:	c3                   	ret    

0080018d <sys_yield>:

void
sys_yield(void)
{
  80018d:	55                   	push   %ebp
  80018e:	89 e5                	mov    %esp,%ebp
  800190:	83 ec 08             	sub    $0x8,%esp
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
  800193:	6a 00                	push   $0x0
  800195:	6a 00                	push   $0x0
  800197:	6a 00                	push   $0x0
  800199:	6a 00                	push   $0x0
  80019b:	b9 00 00 00 00       	mov    $0x0,%ecx
  8001a0:	ba 00 00 00 00       	mov    $0x0,%edx
  8001a5:	b8 0b 00 00 00       	mov    $0xb,%eax
  8001aa:	e8 01 ff ff ff       	call   8000b0 <syscall>
  8001af:	83 c4 10             	add    $0x10,%esp
}
  8001b2:	c9                   	leave  
  8001b3:	c3                   	ret    

008001b4 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  8001b4:	55                   	push   %ebp
  8001b5:	89 e5                	mov    %esp,%ebp
  8001b7:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
  8001ba:	6a 00                	push   $0x0
  8001bc:	6a 00                	push   $0x0
  8001be:	ff 75 10             	pushl  0x10(%ebp)
  8001c1:	ff 75 0c             	pushl  0xc(%ebp)
  8001c4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8001c7:	ba 01 00 00 00       	mov    $0x1,%edx
  8001cc:	b8 04 00 00 00       	mov    $0x4,%eax
  8001d1:	e8 da fe ff ff       	call   8000b0 <syscall>
}
  8001d6:	c9                   	leave  
  8001d7:	c3                   	ret    

008001d8 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8001d8:	55                   	push   %ebp
  8001d9:	89 e5                	mov    %esp,%ebp
  8001db:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
  8001de:	ff 75 18             	pushl  0x18(%ebp)
  8001e1:	ff 75 14             	pushl  0x14(%ebp)
  8001e4:	ff 75 10             	pushl  0x10(%ebp)
  8001e7:	ff 75 0c             	pushl  0xc(%ebp)
  8001ea:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8001ed:	ba 01 00 00 00       	mov    $0x1,%edx
  8001f2:	b8 05 00 00 00       	mov    $0x5,%eax
  8001f7:	e8 b4 fe ff ff       	call   8000b0 <syscall>
}
  8001fc:	c9                   	leave  
  8001fd:	c3                   	ret    

008001fe <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  8001fe:	55                   	push   %ebp
  8001ff:	89 e5                	mov    %esp,%ebp
  800201:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
  800204:	6a 00                	push   $0x0
  800206:	6a 00                	push   $0x0
  800208:	6a 00                	push   $0x0
  80020a:	ff 75 0c             	pushl  0xc(%ebp)
  80020d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800210:	ba 01 00 00 00       	mov    $0x1,%edx
  800215:	b8 06 00 00 00       	mov    $0x6,%eax
  80021a:	e8 91 fe ff ff       	call   8000b0 <syscall>
}
  80021f:	c9                   	leave  
  800220:	c3                   	ret    

00800221 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800221:	55                   	push   %ebp
  800222:	89 e5                	mov    %esp,%ebp
  800224:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
  800227:	6a 00                	push   $0x0
  800229:	6a 00                	push   $0x0
  80022b:	6a 00                	push   $0x0
  80022d:	ff 75 0c             	pushl  0xc(%ebp)
  800230:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800233:	ba 01 00 00 00       	mov    $0x1,%edx
  800238:	b8 08 00 00 00       	mov    $0x8,%eax
  80023d:	e8 6e fe ff ff       	call   8000b0 <syscall>
}
  800242:	c9                   	leave  
  800243:	c3                   	ret    

00800244 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800244:	55                   	push   %ebp
  800245:	89 e5                	mov    %esp,%ebp
  800247:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
  80024a:	6a 00                	push   $0x0
  80024c:	6a 00                	push   $0x0
  80024e:	6a 00                	push   $0x0
  800250:	ff 75 0c             	pushl  0xc(%ebp)
  800253:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800256:	ba 01 00 00 00       	mov    $0x1,%edx
  80025b:	b8 09 00 00 00       	mov    $0x9,%eax
  800260:	e8 4b fe ff ff       	call   8000b0 <syscall>
}
  800265:	c9                   	leave  
  800266:	c3                   	ret    

00800267 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800267:	55                   	push   %ebp
  800268:	89 e5                	mov    %esp,%ebp
  80026a:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
  80026d:	6a 00                	push   $0x0
  80026f:	6a 00                	push   $0x0
  800271:	6a 00                	push   $0x0
  800273:	ff 75 0c             	pushl  0xc(%ebp)
  800276:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800279:	ba 01 00 00 00       	mov    $0x1,%edx
  80027e:	b8 0a 00 00 00       	mov    $0xa,%eax
  800283:	e8 28 fe ff ff       	call   8000b0 <syscall>
}
  800288:	c9                   	leave  
  800289:	c3                   	ret    

0080028a <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  80028a:	55                   	push   %ebp
  80028b:	89 e5                	mov    %esp,%ebp
  80028d:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
  800290:	6a 00                	push   $0x0
  800292:	ff 75 14             	pushl  0x14(%ebp)
  800295:	ff 75 10             	pushl  0x10(%ebp)
  800298:	ff 75 0c             	pushl  0xc(%ebp)
  80029b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80029e:	ba 00 00 00 00       	mov    $0x0,%edx
  8002a3:	b8 0c 00 00 00       	mov    $0xc,%eax
  8002a8:	e8 03 fe ff ff       	call   8000b0 <syscall>
}
  8002ad:	c9                   	leave  
  8002ae:	c3                   	ret    

008002af <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  8002af:	55                   	push   %ebp
  8002b0:	89 e5                	mov    %esp,%ebp
  8002b2:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
  8002b5:	6a 00                	push   $0x0
  8002b7:	6a 00                	push   $0x0
  8002b9:	6a 00                	push   $0x0
  8002bb:	6a 00                	push   $0x0
  8002bd:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8002c0:	ba 01 00 00 00       	mov    $0x1,%edx
  8002c5:	b8 0d 00 00 00       	mov    $0xd,%eax
  8002ca:	e8 e1 fd ff ff       	call   8000b0 <syscall>
}
  8002cf:	c9                   	leave  
  8002d0:	c3                   	ret    

008002d1 <sys_set_priority>:

int
sys_set_priority(envid_t envid, uint32_t new_priority)
{
  8002d1:	55                   	push   %ebp
  8002d2:	89 e5                	mov    %esp,%ebp
  8002d4:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_set_priority, 0, envid, new_priority, 0, 0, 0);
  8002d7:	6a 00                	push   $0x0
  8002d9:	6a 00                	push   $0x0
  8002db:	6a 00                	push   $0x0
  8002dd:	ff 75 0c             	pushl  0xc(%ebp)
  8002e0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8002e3:	ba 00 00 00 00       	mov    $0x0,%edx
  8002e8:	b8 0e 00 00 00       	mov    $0xe,%eax
  8002ed:	e8 be fd ff ff       	call   8000b0 <syscall>
}
  8002f2:	c9                   	leave  
  8002f3:	c3                   	ret    

008002f4 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8002f4:	55                   	push   %ebp
  8002f5:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8002f7:	8b 45 08             	mov    0x8(%ebp),%eax
  8002fa:	05 00 00 00 30       	add    $0x30000000,%eax
  8002ff:	c1 e8 0c             	shr    $0xc,%eax
}
  800302:	c9                   	leave  
  800303:	c3                   	ret    

00800304 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800304:	55                   	push   %ebp
  800305:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  800307:	ff 75 08             	pushl  0x8(%ebp)
  80030a:	e8 e5 ff ff ff       	call   8002f4 <fd2num>
  80030f:	83 c4 04             	add    $0x4,%esp
  800312:	05 20 00 0d 00       	add    $0xd0020,%eax
  800317:	c1 e0 0c             	shl    $0xc,%eax
}
  80031a:	c9                   	leave  
  80031b:	c3                   	ret    

0080031c <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  80031c:	55                   	push   %ebp
  80031d:	89 e5                	mov    %esp,%ebp
  80031f:	53                   	push   %ebx
  800320:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800323:	a1 00 dd 7b ef       	mov    0xef7bdd00,%eax
  800328:	a8 01                	test   $0x1,%al
  80032a:	74 34                	je     800360 <fd_alloc+0x44>
  80032c:	a1 00 00 74 ef       	mov    0xef740000,%eax
  800331:	a8 01                	test   $0x1,%al
  800333:	74 32                	je     800367 <fd_alloc+0x4b>
  800335:	b8 00 10 00 d0       	mov    $0xd0001000,%eax
  80033a:	89 c1                	mov    %eax,%ecx
  80033c:	89 c2                	mov    %eax,%edx
  80033e:	c1 ea 16             	shr    $0x16,%edx
  800341:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800348:	f6 c2 01             	test   $0x1,%dl
  80034b:	74 1f                	je     80036c <fd_alloc+0x50>
  80034d:	89 c2                	mov    %eax,%edx
  80034f:	c1 ea 0c             	shr    $0xc,%edx
  800352:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800359:	f6 c2 01             	test   $0x1,%dl
  80035c:	75 17                	jne    800375 <fd_alloc+0x59>
  80035e:	eb 0c                	jmp    80036c <fd_alloc+0x50>
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  800360:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
  800365:	eb 05                	jmp    80036c <fd_alloc+0x50>
  800367:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
  80036c:	89 0b                	mov    %ecx,(%ebx)
			return 0;
  80036e:	b8 00 00 00 00       	mov    $0x0,%eax
  800373:	eb 17                	jmp    80038c <fd_alloc+0x70>
  800375:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  80037a:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  80037f:	75 b9                	jne    80033a <fd_alloc+0x1e>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800381:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_MAX_OPEN;
  800387:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  80038c:	5b                   	pop    %ebx
  80038d:	c9                   	leave  
  80038e:	c3                   	ret    

0080038f <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  80038f:	55                   	push   %ebp
  800390:	89 e5                	mov    %esp,%ebp
  800392:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800395:	83 f8 1f             	cmp    $0x1f,%eax
  800398:	77 36                	ja     8003d0 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  80039a:	05 00 00 0d 00       	add    $0xd0000,%eax
  80039f:	c1 e0 0c             	shl    $0xc,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8003a2:	89 c2                	mov    %eax,%edx
  8003a4:	c1 ea 16             	shr    $0x16,%edx
  8003a7:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8003ae:	f6 c2 01             	test   $0x1,%dl
  8003b1:	74 24                	je     8003d7 <fd_lookup+0x48>
  8003b3:	89 c2                	mov    %eax,%edx
  8003b5:	c1 ea 0c             	shr    $0xc,%edx
  8003b8:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8003bf:	f6 c2 01             	test   $0x1,%dl
  8003c2:	74 1a                	je     8003de <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8003c4:	8b 55 0c             	mov    0xc(%ebp),%edx
  8003c7:	89 02                	mov    %eax,(%edx)
	return 0;
  8003c9:	b8 00 00 00 00       	mov    $0x0,%eax
  8003ce:	eb 13                	jmp    8003e3 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8003d0:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8003d5:	eb 0c                	jmp    8003e3 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8003d7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8003dc:	eb 05                	jmp    8003e3 <fd_lookup+0x54>
  8003de:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  8003e3:	c9                   	leave  
  8003e4:	c3                   	ret    

008003e5 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8003e5:	55                   	push   %ebp
  8003e6:	89 e5                	mov    %esp,%ebp
  8003e8:	53                   	push   %ebx
  8003e9:	83 ec 04             	sub    $0x4,%esp
  8003ec:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8003ef:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
		if (devtab[i]->dev_id == dev_id) {
  8003f2:	39 0d 04 30 80 00    	cmp    %ecx,0x803004
  8003f8:	74 0d                	je     800407 <dev_lookup+0x22>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8003fa:	b8 00 00 00 00       	mov    $0x0,%eax
  8003ff:	eb 14                	jmp    800415 <dev_lookup+0x30>
		if (devtab[i]->dev_id == dev_id) {
  800401:	39 0a                	cmp    %ecx,(%edx)
  800403:	75 10                	jne    800415 <dev_lookup+0x30>
  800405:	eb 05                	jmp    80040c <dev_lookup+0x27>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800407:	ba 04 30 80 00       	mov    $0x803004,%edx
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
  80040c:	89 13                	mov    %edx,(%ebx)
			return 0;
  80040e:	b8 00 00 00 00       	mov    $0x0,%eax
  800413:	eb 31                	jmp    800446 <dev_lookup+0x61>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800415:	40                   	inc    %eax
  800416:	8b 14 85 34 1e 80 00 	mov    0x801e34(,%eax,4),%edx
  80041d:	85 d2                	test   %edx,%edx
  80041f:	75 e0                	jne    800401 <dev_lookup+0x1c>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800421:	a1 04 40 80 00       	mov    0x804004,%eax
  800426:	8b 40 48             	mov    0x48(%eax),%eax
  800429:	83 ec 04             	sub    $0x4,%esp
  80042c:	51                   	push   %ecx
  80042d:	50                   	push   %eax
  80042e:	68 b8 1d 80 00       	push   $0x801db8
  800433:	e8 48 0c 00 00       	call   801080 <cprintf>
	*dev = 0;
  800438:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_INVAL;
  80043e:	83 c4 10             	add    $0x10,%esp
  800441:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800446:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800449:	c9                   	leave  
  80044a:	c3                   	ret    

0080044b <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  80044b:	55                   	push   %ebp
  80044c:	89 e5                	mov    %esp,%ebp
  80044e:	56                   	push   %esi
  80044f:	53                   	push   %ebx
  800450:	83 ec 20             	sub    $0x20,%esp
  800453:	8b 75 08             	mov    0x8(%ebp),%esi
  800456:	8a 45 0c             	mov    0xc(%ebp),%al
  800459:	88 45 e7             	mov    %al,-0x19(%ebp)
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80045c:	56                   	push   %esi
  80045d:	e8 92 fe ff ff       	call   8002f4 <fd2num>
  800462:	8d 55 f4             	lea    -0xc(%ebp),%edx
  800465:	89 14 24             	mov    %edx,(%esp)
  800468:	50                   	push   %eax
  800469:	e8 21 ff ff ff       	call   80038f <fd_lookup>
  80046e:	89 c3                	mov    %eax,%ebx
  800470:	83 c4 08             	add    $0x8,%esp
  800473:	85 c0                	test   %eax,%eax
  800475:	78 05                	js     80047c <fd_close+0x31>
	    || fd != fd2)
  800477:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  80047a:	74 0d                	je     800489 <fd_close+0x3e>
		return (must_exist ? r : 0);
  80047c:	80 7d e7 00          	cmpb   $0x0,-0x19(%ebp)
  800480:	75 48                	jne    8004ca <fd_close+0x7f>
  800482:	bb 00 00 00 00       	mov    $0x0,%ebx
  800487:	eb 41                	jmp    8004ca <fd_close+0x7f>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800489:	83 ec 08             	sub    $0x8,%esp
  80048c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80048f:	50                   	push   %eax
  800490:	ff 36                	pushl  (%esi)
  800492:	e8 4e ff ff ff       	call   8003e5 <dev_lookup>
  800497:	89 c3                	mov    %eax,%ebx
  800499:	83 c4 10             	add    $0x10,%esp
  80049c:	85 c0                	test   %eax,%eax
  80049e:	78 1c                	js     8004bc <fd_close+0x71>
		if (dev->dev_close)
  8004a0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8004a3:	8b 40 10             	mov    0x10(%eax),%eax
  8004a6:	85 c0                	test   %eax,%eax
  8004a8:	74 0d                	je     8004b7 <fd_close+0x6c>
			r = (*dev->dev_close)(fd);
  8004aa:	83 ec 0c             	sub    $0xc,%esp
  8004ad:	56                   	push   %esi
  8004ae:	ff d0                	call   *%eax
  8004b0:	89 c3                	mov    %eax,%ebx
  8004b2:	83 c4 10             	add    $0x10,%esp
  8004b5:	eb 05                	jmp    8004bc <fd_close+0x71>
		else
			r = 0;
  8004b7:	bb 00 00 00 00       	mov    $0x0,%ebx
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8004bc:	83 ec 08             	sub    $0x8,%esp
  8004bf:	56                   	push   %esi
  8004c0:	6a 00                	push   $0x0
  8004c2:	e8 37 fd ff ff       	call   8001fe <sys_page_unmap>
	return r;
  8004c7:	83 c4 10             	add    $0x10,%esp
}
  8004ca:	89 d8                	mov    %ebx,%eax
  8004cc:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8004cf:	5b                   	pop    %ebx
  8004d0:	5e                   	pop    %esi
  8004d1:	c9                   	leave  
  8004d2:	c3                   	ret    

008004d3 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8004d3:	55                   	push   %ebp
  8004d4:	89 e5                	mov    %esp,%ebp
  8004d6:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8004d9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8004dc:	50                   	push   %eax
  8004dd:	ff 75 08             	pushl  0x8(%ebp)
  8004e0:	e8 aa fe ff ff       	call   80038f <fd_lookup>
  8004e5:	83 c4 08             	add    $0x8,%esp
  8004e8:	85 c0                	test   %eax,%eax
  8004ea:	78 10                	js     8004fc <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  8004ec:	83 ec 08             	sub    $0x8,%esp
  8004ef:	6a 01                	push   $0x1
  8004f1:	ff 75 f4             	pushl  -0xc(%ebp)
  8004f4:	e8 52 ff ff ff       	call   80044b <fd_close>
  8004f9:	83 c4 10             	add    $0x10,%esp
}
  8004fc:	c9                   	leave  
  8004fd:	c3                   	ret    

008004fe <close_all>:

void
close_all(void)
{
  8004fe:	55                   	push   %ebp
  8004ff:	89 e5                	mov    %esp,%ebp
  800501:	53                   	push   %ebx
  800502:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800505:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  80050a:	83 ec 0c             	sub    $0xc,%esp
  80050d:	53                   	push   %ebx
  80050e:	e8 c0 ff ff ff       	call   8004d3 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  800513:	43                   	inc    %ebx
  800514:	83 c4 10             	add    $0x10,%esp
  800517:	83 fb 20             	cmp    $0x20,%ebx
  80051a:	75 ee                	jne    80050a <close_all+0xc>
		close(i);
}
  80051c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80051f:	c9                   	leave  
  800520:	c3                   	ret    

00800521 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800521:	55                   	push   %ebp
  800522:	89 e5                	mov    %esp,%ebp
  800524:	57                   	push   %edi
  800525:	56                   	push   %esi
  800526:	53                   	push   %ebx
  800527:	83 ec 2c             	sub    $0x2c,%esp
  80052a:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  80052d:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800530:	50                   	push   %eax
  800531:	ff 75 08             	pushl  0x8(%ebp)
  800534:	e8 56 fe ff ff       	call   80038f <fd_lookup>
  800539:	89 c3                	mov    %eax,%ebx
  80053b:	83 c4 08             	add    $0x8,%esp
  80053e:	85 c0                	test   %eax,%eax
  800540:	0f 88 c0 00 00 00    	js     800606 <dup+0xe5>
		return r;
	close(newfdnum);
  800546:	83 ec 0c             	sub    $0xc,%esp
  800549:	57                   	push   %edi
  80054a:	e8 84 ff ff ff       	call   8004d3 <close>

	newfd = INDEX2FD(newfdnum);
  80054f:	8d b7 00 00 0d 00    	lea    0xd0000(%edi),%esi
  800555:	c1 e6 0c             	shl    $0xc,%esi
	ova = fd2data(oldfd);
  800558:	83 c4 04             	add    $0x4,%esp
  80055b:	ff 75 e4             	pushl  -0x1c(%ebp)
  80055e:	e8 a1 fd ff ff       	call   800304 <fd2data>
  800563:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  800565:	89 34 24             	mov    %esi,(%esp)
  800568:	e8 97 fd ff ff       	call   800304 <fd2data>
  80056d:	83 c4 10             	add    $0x10,%esp
  800570:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  800573:	89 d8                	mov    %ebx,%eax
  800575:	c1 e8 16             	shr    $0x16,%eax
  800578:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80057f:	a8 01                	test   $0x1,%al
  800581:	74 37                	je     8005ba <dup+0x99>
  800583:	89 d8                	mov    %ebx,%eax
  800585:	c1 e8 0c             	shr    $0xc,%eax
  800588:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80058f:	f6 c2 01             	test   $0x1,%dl
  800592:	74 26                	je     8005ba <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  800594:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80059b:	83 ec 0c             	sub    $0xc,%esp
  80059e:	25 07 0e 00 00       	and    $0xe07,%eax
  8005a3:	50                   	push   %eax
  8005a4:	ff 75 d4             	pushl  -0x2c(%ebp)
  8005a7:	6a 00                	push   $0x0
  8005a9:	53                   	push   %ebx
  8005aa:	6a 00                	push   $0x0
  8005ac:	e8 27 fc ff ff       	call   8001d8 <sys_page_map>
  8005b1:	89 c3                	mov    %eax,%ebx
  8005b3:	83 c4 20             	add    $0x20,%esp
  8005b6:	85 c0                	test   %eax,%eax
  8005b8:	78 2d                	js     8005e7 <dup+0xc6>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8005ba:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8005bd:	89 c2                	mov    %eax,%edx
  8005bf:	c1 ea 0c             	shr    $0xc,%edx
  8005c2:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8005c9:	83 ec 0c             	sub    $0xc,%esp
  8005cc:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  8005d2:	52                   	push   %edx
  8005d3:	56                   	push   %esi
  8005d4:	6a 00                	push   $0x0
  8005d6:	50                   	push   %eax
  8005d7:	6a 00                	push   $0x0
  8005d9:	e8 fa fb ff ff       	call   8001d8 <sys_page_map>
  8005de:	89 c3                	mov    %eax,%ebx
  8005e0:	83 c4 20             	add    $0x20,%esp
  8005e3:	85 c0                	test   %eax,%eax
  8005e5:	79 1d                	jns    800604 <dup+0xe3>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8005e7:	83 ec 08             	sub    $0x8,%esp
  8005ea:	56                   	push   %esi
  8005eb:	6a 00                	push   $0x0
  8005ed:	e8 0c fc ff ff       	call   8001fe <sys_page_unmap>
	sys_page_unmap(0, nva);
  8005f2:	83 c4 08             	add    $0x8,%esp
  8005f5:	ff 75 d4             	pushl  -0x2c(%ebp)
  8005f8:	6a 00                	push   $0x0
  8005fa:	e8 ff fb ff ff       	call   8001fe <sys_page_unmap>
	return r;
  8005ff:	83 c4 10             	add    $0x10,%esp
  800602:	eb 02                	jmp    800606 <dup+0xe5>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
		goto err;

	return newfdnum;
  800604:	89 fb                	mov    %edi,%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  800606:	89 d8                	mov    %ebx,%eax
  800608:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80060b:	5b                   	pop    %ebx
  80060c:	5e                   	pop    %esi
  80060d:	5f                   	pop    %edi
  80060e:	c9                   	leave  
  80060f:	c3                   	ret    

00800610 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  800610:	55                   	push   %ebp
  800611:	89 e5                	mov    %esp,%ebp
  800613:	53                   	push   %ebx
  800614:	83 ec 14             	sub    $0x14,%esp
  800617:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80061a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80061d:	50                   	push   %eax
  80061e:	53                   	push   %ebx
  80061f:	e8 6b fd ff ff       	call   80038f <fd_lookup>
  800624:	83 c4 08             	add    $0x8,%esp
  800627:	85 c0                	test   %eax,%eax
  800629:	78 67                	js     800692 <read+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80062b:	83 ec 08             	sub    $0x8,%esp
  80062e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800631:	50                   	push   %eax
  800632:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800635:	ff 30                	pushl  (%eax)
  800637:	e8 a9 fd ff ff       	call   8003e5 <dev_lookup>
  80063c:	83 c4 10             	add    $0x10,%esp
  80063f:	85 c0                	test   %eax,%eax
  800641:	78 4f                	js     800692 <read+0x82>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  800643:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800646:	8b 50 08             	mov    0x8(%eax),%edx
  800649:	83 e2 03             	and    $0x3,%edx
  80064c:	83 fa 01             	cmp    $0x1,%edx
  80064f:	75 21                	jne    800672 <read+0x62>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  800651:	a1 04 40 80 00       	mov    0x804004,%eax
  800656:	8b 40 48             	mov    0x48(%eax),%eax
  800659:	83 ec 04             	sub    $0x4,%esp
  80065c:	53                   	push   %ebx
  80065d:	50                   	push   %eax
  80065e:	68 f9 1d 80 00       	push   $0x801df9
  800663:	e8 18 0a 00 00       	call   801080 <cprintf>
		return -E_INVAL;
  800668:	83 c4 10             	add    $0x10,%esp
  80066b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800670:	eb 20                	jmp    800692 <read+0x82>
	}
	if (!dev->dev_read)
  800672:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800675:	8b 52 08             	mov    0x8(%edx),%edx
  800678:	85 d2                	test   %edx,%edx
  80067a:	74 11                	je     80068d <read+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  80067c:	83 ec 04             	sub    $0x4,%esp
  80067f:	ff 75 10             	pushl  0x10(%ebp)
  800682:	ff 75 0c             	pushl  0xc(%ebp)
  800685:	50                   	push   %eax
  800686:	ff d2                	call   *%edx
  800688:	83 c4 10             	add    $0x10,%esp
  80068b:	eb 05                	jmp    800692 <read+0x82>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  80068d:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_read)(fd, buf, n);
}
  800692:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800695:	c9                   	leave  
  800696:	c3                   	ret    

00800697 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  800697:	55                   	push   %ebp
  800698:	89 e5                	mov    %esp,%ebp
  80069a:	57                   	push   %edi
  80069b:	56                   	push   %esi
  80069c:	53                   	push   %ebx
  80069d:	83 ec 0c             	sub    $0xc,%esp
  8006a0:	8b 7d 08             	mov    0x8(%ebp),%edi
  8006a3:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8006a6:	85 f6                	test   %esi,%esi
  8006a8:	74 31                	je     8006db <readn+0x44>
  8006aa:	b8 00 00 00 00       	mov    $0x0,%eax
  8006af:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = read(fdnum, (char*)buf + tot, n - tot);
  8006b4:	83 ec 04             	sub    $0x4,%esp
  8006b7:	89 f2                	mov    %esi,%edx
  8006b9:	29 c2                	sub    %eax,%edx
  8006bb:	52                   	push   %edx
  8006bc:	03 45 0c             	add    0xc(%ebp),%eax
  8006bf:	50                   	push   %eax
  8006c0:	57                   	push   %edi
  8006c1:	e8 4a ff ff ff       	call   800610 <read>
		if (m < 0)
  8006c6:	83 c4 10             	add    $0x10,%esp
  8006c9:	85 c0                	test   %eax,%eax
  8006cb:	78 17                	js     8006e4 <readn+0x4d>
			return m;
		if (m == 0)
  8006cd:	85 c0                	test   %eax,%eax
  8006cf:	74 11                	je     8006e2 <readn+0x4b>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8006d1:	01 c3                	add    %eax,%ebx
  8006d3:	89 d8                	mov    %ebx,%eax
  8006d5:	39 f3                	cmp    %esi,%ebx
  8006d7:	72 db                	jb     8006b4 <readn+0x1d>
  8006d9:	eb 09                	jmp    8006e4 <readn+0x4d>
  8006db:	b8 00 00 00 00       	mov    $0x0,%eax
  8006e0:	eb 02                	jmp    8006e4 <readn+0x4d>
		m = read(fdnum, (char*)buf + tot, n - tot);
		if (m < 0)
			return m;
		if (m == 0)
  8006e2:	89 d8                	mov    %ebx,%eax
			break;
	}
	return tot;
}
  8006e4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8006e7:	5b                   	pop    %ebx
  8006e8:	5e                   	pop    %esi
  8006e9:	5f                   	pop    %edi
  8006ea:	c9                   	leave  
  8006eb:	c3                   	ret    

008006ec <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8006ec:	55                   	push   %ebp
  8006ed:	89 e5                	mov    %esp,%ebp
  8006ef:	53                   	push   %ebx
  8006f0:	83 ec 14             	sub    $0x14,%esp
  8006f3:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8006f6:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8006f9:	50                   	push   %eax
  8006fa:	53                   	push   %ebx
  8006fb:	e8 8f fc ff ff       	call   80038f <fd_lookup>
  800700:	83 c4 08             	add    $0x8,%esp
  800703:	85 c0                	test   %eax,%eax
  800705:	78 62                	js     800769 <write+0x7d>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800707:	83 ec 08             	sub    $0x8,%esp
  80070a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80070d:	50                   	push   %eax
  80070e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800711:	ff 30                	pushl  (%eax)
  800713:	e8 cd fc ff ff       	call   8003e5 <dev_lookup>
  800718:	83 c4 10             	add    $0x10,%esp
  80071b:	85 c0                	test   %eax,%eax
  80071d:	78 4a                	js     800769 <write+0x7d>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80071f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800722:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  800726:	75 21                	jne    800749 <write+0x5d>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  800728:	a1 04 40 80 00       	mov    0x804004,%eax
  80072d:	8b 40 48             	mov    0x48(%eax),%eax
  800730:	83 ec 04             	sub    $0x4,%esp
  800733:	53                   	push   %ebx
  800734:	50                   	push   %eax
  800735:	68 15 1e 80 00       	push   $0x801e15
  80073a:	e8 41 09 00 00       	call   801080 <cprintf>
		return -E_INVAL;
  80073f:	83 c4 10             	add    $0x10,%esp
  800742:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800747:	eb 20                	jmp    800769 <write+0x7d>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  800749:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80074c:	8b 52 0c             	mov    0xc(%edx),%edx
  80074f:	85 d2                	test   %edx,%edx
  800751:	74 11                	je     800764 <write+0x78>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  800753:	83 ec 04             	sub    $0x4,%esp
  800756:	ff 75 10             	pushl  0x10(%ebp)
  800759:	ff 75 0c             	pushl  0xc(%ebp)
  80075c:	50                   	push   %eax
  80075d:	ff d2                	call   *%edx
  80075f:	83 c4 10             	add    $0x10,%esp
  800762:	eb 05                	jmp    800769 <write+0x7d>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  800764:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  800769:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80076c:	c9                   	leave  
  80076d:	c3                   	ret    

0080076e <seek>:

int
seek(int fdnum, off_t offset)
{
  80076e:	55                   	push   %ebp
  80076f:	89 e5                	mov    %esp,%ebp
  800771:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800774:	8d 45 fc             	lea    -0x4(%ebp),%eax
  800777:	50                   	push   %eax
  800778:	ff 75 08             	pushl  0x8(%ebp)
  80077b:	e8 0f fc ff ff       	call   80038f <fd_lookup>
  800780:	83 c4 08             	add    $0x8,%esp
  800783:	85 c0                	test   %eax,%eax
  800785:	78 0e                	js     800795 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  800787:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80078a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80078d:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  800790:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800795:	c9                   	leave  
  800796:	c3                   	ret    

00800797 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  800797:	55                   	push   %ebp
  800798:	89 e5                	mov    %esp,%ebp
  80079a:	53                   	push   %ebx
  80079b:	83 ec 14             	sub    $0x14,%esp
  80079e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8007a1:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8007a4:	50                   	push   %eax
  8007a5:	53                   	push   %ebx
  8007a6:	e8 e4 fb ff ff       	call   80038f <fd_lookup>
  8007ab:	83 c4 08             	add    $0x8,%esp
  8007ae:	85 c0                	test   %eax,%eax
  8007b0:	78 5f                	js     800811 <ftruncate+0x7a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8007b2:	83 ec 08             	sub    $0x8,%esp
  8007b5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8007b8:	50                   	push   %eax
  8007b9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8007bc:	ff 30                	pushl  (%eax)
  8007be:	e8 22 fc ff ff       	call   8003e5 <dev_lookup>
  8007c3:	83 c4 10             	add    $0x10,%esp
  8007c6:	85 c0                	test   %eax,%eax
  8007c8:	78 47                	js     800811 <ftruncate+0x7a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8007ca:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8007cd:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8007d1:	75 21                	jne    8007f4 <ftruncate+0x5d>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8007d3:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8007d8:	8b 40 48             	mov    0x48(%eax),%eax
  8007db:	83 ec 04             	sub    $0x4,%esp
  8007de:	53                   	push   %ebx
  8007df:	50                   	push   %eax
  8007e0:	68 d8 1d 80 00       	push   $0x801dd8
  8007e5:	e8 96 08 00 00       	call   801080 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8007ea:	83 c4 10             	add    $0x10,%esp
  8007ed:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8007f2:	eb 1d                	jmp    800811 <ftruncate+0x7a>
	}
	if (!dev->dev_trunc)
  8007f4:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8007f7:	8b 52 18             	mov    0x18(%edx),%edx
  8007fa:	85 d2                	test   %edx,%edx
  8007fc:	74 0e                	je     80080c <ftruncate+0x75>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8007fe:	83 ec 08             	sub    $0x8,%esp
  800801:	ff 75 0c             	pushl  0xc(%ebp)
  800804:	50                   	push   %eax
  800805:	ff d2                	call   *%edx
  800807:	83 c4 10             	add    $0x10,%esp
  80080a:	eb 05                	jmp    800811 <ftruncate+0x7a>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  80080c:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  800811:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800814:	c9                   	leave  
  800815:	c3                   	ret    

00800816 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  800816:	55                   	push   %ebp
  800817:	89 e5                	mov    %esp,%ebp
  800819:	53                   	push   %ebx
  80081a:	83 ec 14             	sub    $0x14,%esp
  80081d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800820:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800823:	50                   	push   %eax
  800824:	ff 75 08             	pushl  0x8(%ebp)
  800827:	e8 63 fb ff ff       	call   80038f <fd_lookup>
  80082c:	83 c4 08             	add    $0x8,%esp
  80082f:	85 c0                	test   %eax,%eax
  800831:	78 52                	js     800885 <fstat+0x6f>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800833:	83 ec 08             	sub    $0x8,%esp
  800836:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800839:	50                   	push   %eax
  80083a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80083d:	ff 30                	pushl  (%eax)
  80083f:	e8 a1 fb ff ff       	call   8003e5 <dev_lookup>
  800844:	83 c4 10             	add    $0x10,%esp
  800847:	85 c0                	test   %eax,%eax
  800849:	78 3a                	js     800885 <fstat+0x6f>
		return r;
	if (!dev->dev_stat)
  80084b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80084e:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  800852:	74 2c                	je     800880 <fstat+0x6a>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  800854:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  800857:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80085e:	00 00 00 
	stat->st_isdir = 0;
  800861:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  800868:	00 00 00 
	stat->st_dev = dev;
  80086b:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  800871:	83 ec 08             	sub    $0x8,%esp
  800874:	53                   	push   %ebx
  800875:	ff 75 f0             	pushl  -0x10(%ebp)
  800878:	ff 50 14             	call   *0x14(%eax)
  80087b:	83 c4 10             	add    $0x10,%esp
  80087e:	eb 05                	jmp    800885 <fstat+0x6f>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  800880:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  800885:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800888:	c9                   	leave  
  800889:	c3                   	ret    

0080088a <stat>:

int
stat(const char *path, struct Stat *stat)
{
  80088a:	55                   	push   %ebp
  80088b:	89 e5                	mov    %esp,%ebp
  80088d:	56                   	push   %esi
  80088e:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  80088f:	83 ec 08             	sub    $0x8,%esp
  800892:	6a 00                	push   $0x0
  800894:	ff 75 08             	pushl  0x8(%ebp)
  800897:	e8 78 01 00 00       	call   800a14 <open>
  80089c:	89 c3                	mov    %eax,%ebx
  80089e:	83 c4 10             	add    $0x10,%esp
  8008a1:	85 c0                	test   %eax,%eax
  8008a3:	78 1b                	js     8008c0 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8008a5:	83 ec 08             	sub    $0x8,%esp
  8008a8:	ff 75 0c             	pushl  0xc(%ebp)
  8008ab:	50                   	push   %eax
  8008ac:	e8 65 ff ff ff       	call   800816 <fstat>
  8008b1:	89 c6                	mov    %eax,%esi
	close(fd);
  8008b3:	89 1c 24             	mov    %ebx,(%esp)
  8008b6:	e8 18 fc ff ff       	call   8004d3 <close>
	return r;
  8008bb:	83 c4 10             	add    $0x10,%esp
  8008be:	89 f3                	mov    %esi,%ebx
}
  8008c0:	89 d8                	mov    %ebx,%eax
  8008c2:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8008c5:	5b                   	pop    %ebx
  8008c6:	5e                   	pop    %esi
  8008c7:	c9                   	leave  
  8008c8:	c3                   	ret    
  8008c9:	00 00                	add    %al,(%eax)
	...

008008cc <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8008cc:	55                   	push   %ebp
  8008cd:	89 e5                	mov    %esp,%ebp
  8008cf:	56                   	push   %esi
  8008d0:	53                   	push   %ebx
  8008d1:	89 c3                	mov    %eax,%ebx
  8008d3:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  8008d5:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8008dc:	75 12                	jne    8008f0 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8008de:	83 ec 0c             	sub    $0xc,%esp
  8008e1:	6a 01                	push   $0x1
  8008e3:	e8 96 11 00 00       	call   801a7e <ipc_find_env>
  8008e8:	a3 00 40 80 00       	mov    %eax,0x804000
  8008ed:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8008f0:	6a 07                	push   $0x7
  8008f2:	68 00 50 80 00       	push   $0x805000
  8008f7:	53                   	push   %ebx
  8008f8:	ff 35 00 40 80 00    	pushl  0x804000
  8008fe:	e8 26 11 00 00       	call   801a29 <ipc_send>
	
	return ipc_recv(NULL, dstva, NULL);
  800903:	83 c4 0c             	add    $0xc,%esp
  800906:	6a 00                	push   $0x0
  800908:	56                   	push   %esi
  800909:	6a 00                	push   $0x0
  80090b:	e8 a4 10 00 00       	call   8019b4 <ipc_recv>
}
  800910:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800913:	5b                   	pop    %ebx
  800914:	5e                   	pop    %esi
  800915:	c9                   	leave  
  800916:	c3                   	ret    

00800917 <devfile_stat>:
}


static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  800917:	55                   	push   %ebp
  800918:	89 e5                	mov    %esp,%ebp
  80091a:	53                   	push   %ebx
  80091b:	83 ec 04             	sub    $0x4,%esp
  80091e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  800921:	8b 45 08             	mov    0x8(%ebp),%eax
  800924:	8b 40 0c             	mov    0xc(%eax),%eax
  800927:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0) {
  80092c:	ba 00 00 00 00       	mov    $0x0,%edx
  800931:	b8 05 00 00 00       	mov    $0x5,%eax
  800936:	e8 91 ff ff ff       	call   8008cc <fsipc>
  80093b:	85 c0                	test   %eax,%eax
  80093d:	78 2c                	js     80096b <devfile_stat+0x54>
		return r;
	}
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  80093f:	83 ec 08             	sub    $0x8,%esp
  800942:	68 00 50 80 00       	push   $0x805000
  800947:	53                   	push   %ebx
  800948:	e8 e9 0c 00 00       	call   801636 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  80094d:	a1 80 50 80 00       	mov    0x805080,%eax
  800952:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  800958:	a1 84 50 80 00       	mov    0x805084,%eax
  80095d:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  800963:	83 c4 10             	add    $0x10,%esp
  800966:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80096b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80096e:	c9                   	leave  
  80096f:	c3                   	ret    

00800970 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  800970:	55                   	push   %ebp
  800971:	89 e5                	mov    %esp,%ebp
  800973:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  800976:	8b 45 08             	mov    0x8(%ebp),%eax
  800979:	8b 40 0c             	mov    0xc(%eax),%eax
  80097c:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  800981:	ba 00 00 00 00       	mov    $0x0,%edx
  800986:	b8 06 00 00 00       	mov    $0x6,%eax
  80098b:	e8 3c ff ff ff       	call   8008cc <fsipc>
}
  800990:	c9                   	leave  
  800991:	c3                   	ret    

00800992 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  800992:	55                   	push   %ebp
  800993:	89 e5                	mov    %esp,%ebp
  800995:	56                   	push   %esi
  800996:	53                   	push   %ebx
  800997:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  80099a:	8b 45 08             	mov    0x8(%ebp),%eax
  80099d:	8b 40 0c             	mov    0xc(%eax),%eax
  8009a0:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  8009a5:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8009ab:	ba 00 00 00 00       	mov    $0x0,%edx
  8009b0:	b8 03 00 00 00       	mov    $0x3,%eax
  8009b5:	e8 12 ff ff ff       	call   8008cc <fsipc>
  8009ba:	89 c3                	mov    %eax,%ebx
  8009bc:	85 c0                	test   %eax,%eax
  8009be:	78 4b                	js     800a0b <devfile_read+0x79>
		return r;
	assert(r <= n);
  8009c0:	39 c6                	cmp    %eax,%esi
  8009c2:	73 16                	jae    8009da <devfile_read+0x48>
  8009c4:	68 44 1e 80 00       	push   $0x801e44
  8009c9:	68 4b 1e 80 00       	push   $0x801e4b
  8009ce:	6a 7d                	push   $0x7d
  8009d0:	68 60 1e 80 00       	push   $0x801e60
  8009d5:	e8 ce 05 00 00       	call   800fa8 <_panic>
	assert(r <= PGSIZE);
  8009da:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8009df:	7e 16                	jle    8009f7 <devfile_read+0x65>
  8009e1:	68 6b 1e 80 00       	push   $0x801e6b
  8009e6:	68 4b 1e 80 00       	push   $0x801e4b
  8009eb:	6a 7e                	push   $0x7e
  8009ed:	68 60 1e 80 00       	push   $0x801e60
  8009f2:	e8 b1 05 00 00       	call   800fa8 <_panic>
	memmove(buf, &fsipcbuf, r);
  8009f7:	83 ec 04             	sub    $0x4,%esp
  8009fa:	50                   	push   %eax
  8009fb:	68 00 50 80 00       	push   $0x805000
  800a00:	ff 75 0c             	pushl  0xc(%ebp)
  800a03:	e8 ef 0d 00 00       	call   8017f7 <memmove>
	return r;
  800a08:	83 c4 10             	add    $0x10,%esp
}
  800a0b:	89 d8                	mov    %ebx,%eax
  800a0d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800a10:	5b                   	pop    %ebx
  800a11:	5e                   	pop    %esi
  800a12:	c9                   	leave  
  800a13:	c3                   	ret    

00800a14 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  800a14:	55                   	push   %ebp
  800a15:	89 e5                	mov    %esp,%ebp
  800a17:	56                   	push   %esi
  800a18:	53                   	push   %ebx
  800a19:	83 ec 1c             	sub    $0x1c,%esp
  800a1c:	8b 75 08             	mov    0x8(%ebp),%esi
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  800a1f:	56                   	push   %esi
  800a20:	e8 bf 0b 00 00       	call   8015e4 <strlen>
  800a25:	83 c4 10             	add    $0x10,%esp
  800a28:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  800a2d:	7f 65                	jg     800a94 <open+0x80>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800a2f:	83 ec 0c             	sub    $0xc,%esp
  800a32:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800a35:	50                   	push   %eax
  800a36:	e8 e1 f8 ff ff       	call   80031c <fd_alloc>
  800a3b:	89 c3                	mov    %eax,%ebx
  800a3d:	83 c4 10             	add    $0x10,%esp
  800a40:	85 c0                	test   %eax,%eax
  800a42:	78 55                	js     800a99 <open+0x85>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  800a44:	83 ec 08             	sub    $0x8,%esp
  800a47:	56                   	push   %esi
  800a48:	68 00 50 80 00       	push   $0x805000
  800a4d:	e8 e4 0b 00 00       	call   801636 <strcpy>
	fsipcbuf.open.req_omode = mode;
  800a52:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a55:	a3 00 54 80 00       	mov    %eax,0x805400



	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  800a5a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800a5d:	b8 01 00 00 00       	mov    $0x1,%eax
  800a62:	e8 65 fe ff ff       	call   8008cc <fsipc>
  800a67:	89 c3                	mov    %eax,%ebx
  800a69:	83 c4 10             	add    $0x10,%esp
  800a6c:	85 c0                	test   %eax,%eax
  800a6e:	79 12                	jns    800a82 <open+0x6e>
		fd_close(fd, 0);
  800a70:	83 ec 08             	sub    $0x8,%esp
  800a73:	6a 00                	push   $0x0
  800a75:	ff 75 f4             	pushl  -0xc(%ebp)
  800a78:	e8 ce f9 ff ff       	call   80044b <fd_close>
		return r;
  800a7d:	83 c4 10             	add    $0x10,%esp
  800a80:	eb 17                	jmp    800a99 <open+0x85>
	}

	return fd2num(fd);
  800a82:	83 ec 0c             	sub    $0xc,%esp
  800a85:	ff 75 f4             	pushl  -0xc(%ebp)
  800a88:	e8 67 f8 ff ff       	call   8002f4 <fd2num>
  800a8d:	89 c3                	mov    %eax,%ebx
  800a8f:	83 c4 10             	add    $0x10,%esp
  800a92:	eb 05                	jmp    800a99 <open+0x85>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  800a94:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  800a99:	89 d8                	mov    %ebx,%eax
  800a9b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800a9e:	5b                   	pop    %ebx
  800a9f:	5e                   	pop    %esi
  800aa0:	c9                   	leave  
  800aa1:	c3                   	ret    
	...

00800aa4 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  800aa4:	55                   	push   %ebp
  800aa5:	89 e5                	mov    %esp,%ebp
  800aa7:	56                   	push   %esi
  800aa8:	53                   	push   %ebx
  800aa9:	8b 75 0c             	mov    0xc(%ebp),%esi
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  800aac:	83 ec 0c             	sub    $0xc,%esp
  800aaf:	ff 75 08             	pushl  0x8(%ebp)
  800ab2:	e8 4d f8 ff ff       	call   800304 <fd2data>
  800ab7:	89 c3                	mov    %eax,%ebx
	strcpy(stat->st_name, "<pipe>");
  800ab9:	83 c4 08             	add    $0x8,%esp
  800abc:	68 77 1e 80 00       	push   $0x801e77
  800ac1:	56                   	push   %esi
  800ac2:	e8 6f 0b 00 00       	call   801636 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  800ac7:	8b 43 04             	mov    0x4(%ebx),%eax
  800aca:	2b 03                	sub    (%ebx),%eax
  800acc:	89 86 80 00 00 00    	mov    %eax,0x80(%esi)
	stat->st_isdir = 0;
  800ad2:	c7 86 84 00 00 00 00 	movl   $0x0,0x84(%esi)
  800ad9:	00 00 00 
	stat->st_dev = &devpipe;
  800adc:	c7 86 88 00 00 00 20 	movl   $0x803020,0x88(%esi)
  800ae3:	30 80 00 
	return 0;
}
  800ae6:	b8 00 00 00 00       	mov    $0x0,%eax
  800aeb:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800aee:	5b                   	pop    %ebx
  800aef:	5e                   	pop    %esi
  800af0:	c9                   	leave  
  800af1:	c3                   	ret    

00800af2 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  800af2:	55                   	push   %ebp
  800af3:	89 e5                	mov    %esp,%ebp
  800af5:	53                   	push   %ebx
  800af6:	83 ec 0c             	sub    $0xc,%esp
  800af9:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  800afc:	53                   	push   %ebx
  800afd:	6a 00                	push   $0x0
  800aff:	e8 fa f6 ff ff       	call   8001fe <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  800b04:	89 1c 24             	mov    %ebx,(%esp)
  800b07:	e8 f8 f7 ff ff       	call   800304 <fd2data>
  800b0c:	83 c4 08             	add    $0x8,%esp
  800b0f:	50                   	push   %eax
  800b10:	6a 00                	push   $0x0
  800b12:	e8 e7 f6 ff ff       	call   8001fe <sys_page_unmap>
}
  800b17:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800b1a:	c9                   	leave  
  800b1b:	c3                   	ret    

00800b1c <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  800b1c:	55                   	push   %ebp
  800b1d:	89 e5                	mov    %esp,%ebp
  800b1f:	57                   	push   %edi
  800b20:	56                   	push   %esi
  800b21:	53                   	push   %ebx
  800b22:	83 ec 1c             	sub    $0x1c,%esp
  800b25:	89 c7                	mov    %eax,%edi
  800b27:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  800b2a:	a1 04 40 80 00       	mov    0x804004,%eax
  800b2f:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  800b32:	83 ec 0c             	sub    $0xc,%esp
  800b35:	57                   	push   %edi
  800b36:	e8 a1 0f 00 00       	call   801adc <pageref>
  800b3b:	89 c6                	mov    %eax,%esi
  800b3d:	83 c4 04             	add    $0x4,%esp
  800b40:	ff 75 e4             	pushl  -0x1c(%ebp)
  800b43:	e8 94 0f 00 00       	call   801adc <pageref>
  800b48:	83 c4 10             	add    $0x10,%esp
  800b4b:	39 c6                	cmp    %eax,%esi
  800b4d:	0f 94 c0             	sete   %al
  800b50:	0f b6 c0             	movzbl %al,%eax
		nn = thisenv->env_runs;
  800b53:	8b 15 04 40 80 00    	mov    0x804004,%edx
  800b59:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  800b5c:	39 cb                	cmp    %ecx,%ebx
  800b5e:	75 08                	jne    800b68 <_pipeisclosed+0x4c>
			return ret;
		if (n != nn && ret == 1)
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
	}
}
  800b60:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b63:	5b                   	pop    %ebx
  800b64:	5e                   	pop    %esi
  800b65:	5f                   	pop    %edi
  800b66:	c9                   	leave  
  800b67:	c3                   	ret    
		n = thisenv->env_runs;
		ret = pageref(fd) == pageref(p);
		nn = thisenv->env_runs;
		if (n == nn)
			return ret;
		if (n != nn && ret == 1)
  800b68:	83 f8 01             	cmp    $0x1,%eax
  800b6b:	75 bd                	jne    800b2a <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  800b6d:	8b 42 58             	mov    0x58(%edx),%eax
  800b70:	6a 01                	push   $0x1
  800b72:	50                   	push   %eax
  800b73:	53                   	push   %ebx
  800b74:	68 7e 1e 80 00       	push   $0x801e7e
  800b79:	e8 02 05 00 00       	call   801080 <cprintf>
  800b7e:	83 c4 10             	add    $0x10,%esp
  800b81:	eb a7                	jmp    800b2a <_pipeisclosed+0xe>

00800b83 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  800b83:	55                   	push   %ebp
  800b84:	89 e5                	mov    %esp,%ebp
  800b86:	57                   	push   %edi
  800b87:	56                   	push   %esi
  800b88:	53                   	push   %ebx
  800b89:	83 ec 28             	sub    $0x28,%esp
  800b8c:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  800b8f:	56                   	push   %esi
  800b90:	e8 6f f7 ff ff       	call   800304 <fd2data>
  800b95:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800b97:	83 c4 10             	add    $0x10,%esp
  800b9a:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800b9e:	75 4a                	jne    800bea <devpipe_write+0x67>
  800ba0:	bf 00 00 00 00       	mov    $0x0,%edi
  800ba5:	eb 56                	jmp    800bfd <devpipe_write+0x7a>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  800ba7:	89 da                	mov    %ebx,%edx
  800ba9:	89 f0                	mov    %esi,%eax
  800bab:	e8 6c ff ff ff       	call   800b1c <_pipeisclosed>
  800bb0:	85 c0                	test   %eax,%eax
  800bb2:	75 4d                	jne    800c01 <devpipe_write+0x7e>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  800bb4:	e8 d4 f5 ff ff       	call   80018d <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  800bb9:	8b 43 04             	mov    0x4(%ebx),%eax
  800bbc:	8b 13                	mov    (%ebx),%edx
  800bbe:	83 c2 20             	add    $0x20,%edx
  800bc1:	39 d0                	cmp    %edx,%eax
  800bc3:	73 e2                	jae    800ba7 <devpipe_write+0x24>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  800bc5:	89 c2                	mov    %eax,%edx
  800bc7:	81 e2 1f 00 00 80    	and    $0x8000001f,%edx
  800bcd:	79 05                	jns    800bd4 <devpipe_write+0x51>
  800bcf:	4a                   	dec    %edx
  800bd0:	83 ca e0             	or     $0xffffffe0,%edx
  800bd3:	42                   	inc    %edx
  800bd4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bd7:	8a 0c 39             	mov    (%ecx,%edi,1),%cl
  800bda:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  800bde:	40                   	inc    %eax
  800bdf:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800be2:	47                   	inc    %edi
  800be3:	39 7d 10             	cmp    %edi,0x10(%ebp)
  800be6:	77 07                	ja     800bef <devpipe_write+0x6c>
  800be8:	eb 13                	jmp    800bfd <devpipe_write+0x7a>
  800bea:	bf 00 00 00 00       	mov    $0x0,%edi
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  800bef:	8b 43 04             	mov    0x4(%ebx),%eax
  800bf2:	8b 13                	mov    (%ebx),%edx
  800bf4:	83 c2 20             	add    $0x20,%edx
  800bf7:	39 d0                	cmp    %edx,%eax
  800bf9:	73 ac                	jae    800ba7 <devpipe_write+0x24>
  800bfb:	eb c8                	jmp    800bc5 <devpipe_write+0x42>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  800bfd:	89 f8                	mov    %edi,%eax
  800bff:	eb 05                	jmp    800c06 <devpipe_write+0x83>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  800c01:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  800c06:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c09:	5b                   	pop    %ebx
  800c0a:	5e                   	pop    %esi
  800c0b:	5f                   	pop    %edi
  800c0c:	c9                   	leave  
  800c0d:	c3                   	ret    

00800c0e <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  800c0e:	55                   	push   %ebp
  800c0f:	89 e5                	mov    %esp,%ebp
  800c11:	57                   	push   %edi
  800c12:	56                   	push   %esi
  800c13:	53                   	push   %ebx
  800c14:	83 ec 18             	sub    $0x18,%esp
  800c17:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  800c1a:	57                   	push   %edi
  800c1b:	e8 e4 f6 ff ff       	call   800304 <fd2data>
  800c20:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800c22:	83 c4 10             	add    $0x10,%esp
  800c25:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800c29:	75 44                	jne    800c6f <devpipe_read+0x61>
  800c2b:	be 00 00 00 00       	mov    $0x0,%esi
  800c30:	eb 4f                	jmp    800c81 <devpipe_read+0x73>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
				return i;
  800c32:	89 f0                	mov    %esi,%eax
  800c34:	eb 54                	jmp    800c8a <devpipe_read+0x7c>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  800c36:	89 da                	mov    %ebx,%edx
  800c38:	89 f8                	mov    %edi,%eax
  800c3a:	e8 dd fe ff ff       	call   800b1c <_pipeisclosed>
  800c3f:	85 c0                	test   %eax,%eax
  800c41:	75 42                	jne    800c85 <devpipe_read+0x77>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  800c43:	e8 45 f5 ff ff       	call   80018d <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  800c48:	8b 03                	mov    (%ebx),%eax
  800c4a:	3b 43 04             	cmp    0x4(%ebx),%eax
  800c4d:	74 e7                	je     800c36 <devpipe_read+0x28>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  800c4f:	25 1f 00 00 80       	and    $0x8000001f,%eax
  800c54:	79 05                	jns    800c5b <devpipe_read+0x4d>
  800c56:	48                   	dec    %eax
  800c57:	83 c8 e0             	or     $0xffffffe0,%eax
  800c5a:	40                   	inc    %eax
  800c5b:	8a 44 03 08          	mov    0x8(%ebx,%eax,1),%al
  800c5f:	8b 55 0c             	mov    0xc(%ebp),%edx
  800c62:	88 04 32             	mov    %al,(%edx,%esi,1)
		p->p_rpos++;
  800c65:	ff 03                	incl   (%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800c67:	46                   	inc    %esi
  800c68:	39 75 10             	cmp    %esi,0x10(%ebp)
  800c6b:	77 07                	ja     800c74 <devpipe_read+0x66>
  800c6d:	eb 12                	jmp    800c81 <devpipe_read+0x73>
  800c6f:	be 00 00 00 00       	mov    $0x0,%esi
		while (p->p_rpos == p->p_wpos) {
  800c74:	8b 03                	mov    (%ebx),%eax
  800c76:	3b 43 04             	cmp    0x4(%ebx),%eax
  800c79:	75 d4                	jne    800c4f <devpipe_read+0x41>
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  800c7b:	85 f6                	test   %esi,%esi
  800c7d:	75 b3                	jne    800c32 <devpipe_read+0x24>
  800c7f:	eb b5                	jmp    800c36 <devpipe_read+0x28>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  800c81:	89 f0                	mov    %esi,%eax
  800c83:	eb 05                	jmp    800c8a <devpipe_read+0x7c>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  800c85:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  800c8a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c8d:	5b                   	pop    %ebx
  800c8e:	5e                   	pop    %esi
  800c8f:	5f                   	pop    %edi
  800c90:	c9                   	leave  
  800c91:	c3                   	ret    

00800c92 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  800c92:	55                   	push   %ebp
  800c93:	89 e5                	mov    %esp,%ebp
  800c95:	57                   	push   %edi
  800c96:	56                   	push   %esi
  800c97:	53                   	push   %ebx
  800c98:	83 ec 28             	sub    $0x28,%esp
  800c9b:	8b 7d 08             	mov    0x8(%ebp),%edi
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  800c9e:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800ca1:	50                   	push   %eax
  800ca2:	e8 75 f6 ff ff       	call   80031c <fd_alloc>
  800ca7:	89 c3                	mov    %eax,%ebx
  800ca9:	83 c4 10             	add    $0x10,%esp
  800cac:	85 c0                	test   %eax,%eax
  800cae:	0f 88 24 01 00 00    	js     800dd8 <pipe+0x146>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800cb4:	83 ec 04             	sub    $0x4,%esp
  800cb7:	68 07 04 00 00       	push   $0x407
  800cbc:	ff 75 e4             	pushl  -0x1c(%ebp)
  800cbf:	6a 00                	push   $0x0
  800cc1:	e8 ee f4 ff ff       	call   8001b4 <sys_page_alloc>
  800cc6:	89 c3                	mov    %eax,%ebx
  800cc8:	83 c4 10             	add    $0x10,%esp
  800ccb:	85 c0                	test   %eax,%eax
  800ccd:	0f 88 05 01 00 00    	js     800dd8 <pipe+0x146>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  800cd3:	83 ec 0c             	sub    $0xc,%esp
  800cd6:	8d 45 e0             	lea    -0x20(%ebp),%eax
  800cd9:	50                   	push   %eax
  800cda:	e8 3d f6 ff ff       	call   80031c <fd_alloc>
  800cdf:	89 c3                	mov    %eax,%ebx
  800ce1:	83 c4 10             	add    $0x10,%esp
  800ce4:	85 c0                	test   %eax,%eax
  800ce6:	0f 88 dc 00 00 00    	js     800dc8 <pipe+0x136>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800cec:	83 ec 04             	sub    $0x4,%esp
  800cef:	68 07 04 00 00       	push   $0x407
  800cf4:	ff 75 e0             	pushl  -0x20(%ebp)
  800cf7:	6a 00                	push   $0x0
  800cf9:	e8 b6 f4 ff ff       	call   8001b4 <sys_page_alloc>
  800cfe:	89 c3                	mov    %eax,%ebx
  800d00:	83 c4 10             	add    $0x10,%esp
  800d03:	85 c0                	test   %eax,%eax
  800d05:	0f 88 bd 00 00 00    	js     800dc8 <pipe+0x136>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  800d0b:	83 ec 0c             	sub    $0xc,%esp
  800d0e:	ff 75 e4             	pushl  -0x1c(%ebp)
  800d11:	e8 ee f5 ff ff       	call   800304 <fd2data>
  800d16:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800d18:	83 c4 0c             	add    $0xc,%esp
  800d1b:	68 07 04 00 00       	push   $0x407
  800d20:	50                   	push   %eax
  800d21:	6a 00                	push   $0x0
  800d23:	e8 8c f4 ff ff       	call   8001b4 <sys_page_alloc>
  800d28:	89 c3                	mov    %eax,%ebx
  800d2a:	83 c4 10             	add    $0x10,%esp
  800d2d:	85 c0                	test   %eax,%eax
  800d2f:	0f 88 83 00 00 00    	js     800db8 <pipe+0x126>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800d35:	83 ec 0c             	sub    $0xc,%esp
  800d38:	ff 75 e0             	pushl  -0x20(%ebp)
  800d3b:	e8 c4 f5 ff ff       	call   800304 <fd2data>
  800d40:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  800d47:	50                   	push   %eax
  800d48:	6a 00                	push   $0x0
  800d4a:	56                   	push   %esi
  800d4b:	6a 00                	push   $0x0
  800d4d:	e8 86 f4 ff ff       	call   8001d8 <sys_page_map>
  800d52:	89 c3                	mov    %eax,%ebx
  800d54:	83 c4 20             	add    $0x20,%esp
  800d57:	85 c0                	test   %eax,%eax
  800d59:	78 4f                	js     800daa <pipe+0x118>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  800d5b:	8b 15 20 30 80 00    	mov    0x803020,%edx
  800d61:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800d64:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  800d66:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800d69:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  800d70:	8b 15 20 30 80 00    	mov    0x803020,%edx
  800d76:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800d79:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  800d7b:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800d7e:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  800d85:	83 ec 0c             	sub    $0xc,%esp
  800d88:	ff 75 e4             	pushl  -0x1c(%ebp)
  800d8b:	e8 64 f5 ff ff       	call   8002f4 <fd2num>
  800d90:	89 07                	mov    %eax,(%edi)
	pfd[1] = fd2num(fd1);
  800d92:	83 c4 04             	add    $0x4,%esp
  800d95:	ff 75 e0             	pushl  -0x20(%ebp)
  800d98:	e8 57 f5 ff ff       	call   8002f4 <fd2num>
  800d9d:	89 47 04             	mov    %eax,0x4(%edi)
	return 0;
  800da0:	83 c4 10             	add    $0x10,%esp
  800da3:	bb 00 00 00 00       	mov    $0x0,%ebx
  800da8:	eb 2e                	jmp    800dd8 <pipe+0x146>

    err3:
	sys_page_unmap(0, va);
  800daa:	83 ec 08             	sub    $0x8,%esp
  800dad:	56                   	push   %esi
  800dae:	6a 00                	push   $0x0
  800db0:	e8 49 f4 ff ff       	call   8001fe <sys_page_unmap>
  800db5:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  800db8:	83 ec 08             	sub    $0x8,%esp
  800dbb:	ff 75 e0             	pushl  -0x20(%ebp)
  800dbe:	6a 00                	push   $0x0
  800dc0:	e8 39 f4 ff ff       	call   8001fe <sys_page_unmap>
  800dc5:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  800dc8:	83 ec 08             	sub    $0x8,%esp
  800dcb:	ff 75 e4             	pushl  -0x1c(%ebp)
  800dce:	6a 00                	push   $0x0
  800dd0:	e8 29 f4 ff ff       	call   8001fe <sys_page_unmap>
  800dd5:	83 c4 10             	add    $0x10,%esp
    err:
	return r;
}
  800dd8:	89 d8                	mov    %ebx,%eax
  800dda:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ddd:	5b                   	pop    %ebx
  800dde:	5e                   	pop    %esi
  800ddf:	5f                   	pop    %edi
  800de0:	c9                   	leave  
  800de1:	c3                   	ret    

00800de2 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  800de2:	55                   	push   %ebp
  800de3:	89 e5                	mov    %esp,%ebp
  800de5:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800de8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800deb:	50                   	push   %eax
  800dec:	ff 75 08             	pushl  0x8(%ebp)
  800def:	e8 9b f5 ff ff       	call   80038f <fd_lookup>
  800df4:	83 c4 10             	add    $0x10,%esp
  800df7:	85 c0                	test   %eax,%eax
  800df9:	78 18                	js     800e13 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  800dfb:	83 ec 0c             	sub    $0xc,%esp
  800dfe:	ff 75 f4             	pushl  -0xc(%ebp)
  800e01:	e8 fe f4 ff ff       	call   800304 <fd2data>
	return _pipeisclosed(fd, p);
  800e06:	89 c2                	mov    %eax,%edx
  800e08:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800e0b:	e8 0c fd ff ff       	call   800b1c <_pipeisclosed>
  800e10:	83 c4 10             	add    $0x10,%esp
}
  800e13:	c9                   	leave  
  800e14:	c3                   	ret    
  800e15:	00 00                	add    %al,(%eax)
	...

00800e18 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  800e18:	55                   	push   %ebp
  800e19:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  800e1b:	b8 00 00 00 00       	mov    $0x0,%eax
  800e20:	c9                   	leave  
  800e21:	c3                   	ret    

00800e22 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  800e22:	55                   	push   %ebp
  800e23:	89 e5                	mov    %esp,%ebp
  800e25:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  800e28:	68 96 1e 80 00       	push   $0x801e96
  800e2d:	ff 75 0c             	pushl  0xc(%ebp)
  800e30:	e8 01 08 00 00       	call   801636 <strcpy>
	return 0;
}
  800e35:	b8 00 00 00 00       	mov    $0x0,%eax
  800e3a:	c9                   	leave  
  800e3b:	c3                   	ret    

00800e3c <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  800e3c:	55                   	push   %ebp
  800e3d:	89 e5                	mov    %esp,%ebp
  800e3f:	57                   	push   %edi
  800e40:	56                   	push   %esi
  800e41:	53                   	push   %ebx
  800e42:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800e48:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800e4c:	74 45                	je     800e93 <devcons_write+0x57>
  800e4e:	b8 00 00 00 00       	mov    $0x0,%eax
  800e53:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  800e58:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  800e5e:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e61:	29 c3                	sub    %eax,%ebx
		if (m > sizeof(buf) - 1)
  800e63:	83 fb 7f             	cmp    $0x7f,%ebx
  800e66:	76 05                	jbe    800e6d <devcons_write+0x31>
			m = sizeof(buf) - 1;
  800e68:	bb 7f 00 00 00       	mov    $0x7f,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  800e6d:	83 ec 04             	sub    $0x4,%esp
  800e70:	53                   	push   %ebx
  800e71:	03 45 0c             	add    0xc(%ebp),%eax
  800e74:	50                   	push   %eax
  800e75:	57                   	push   %edi
  800e76:	e8 7c 09 00 00       	call   8017f7 <memmove>
		sys_cputs(buf, m);
  800e7b:	83 c4 08             	add    $0x8,%esp
  800e7e:	53                   	push   %ebx
  800e7f:	57                   	push   %edi
  800e80:	e8 78 f2 ff ff       	call   8000fd <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800e85:	01 de                	add    %ebx,%esi
  800e87:	89 f0                	mov    %esi,%eax
  800e89:	83 c4 10             	add    $0x10,%esp
  800e8c:	3b 75 10             	cmp    0x10(%ebp),%esi
  800e8f:	72 cd                	jb     800e5e <devcons_write+0x22>
  800e91:	eb 05                	jmp    800e98 <devcons_write+0x5c>
  800e93:	be 00 00 00 00       	mov    $0x0,%esi
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  800e98:	89 f0                	mov    %esi,%eax
  800e9a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e9d:	5b                   	pop    %ebx
  800e9e:	5e                   	pop    %esi
  800e9f:	5f                   	pop    %edi
  800ea0:	c9                   	leave  
  800ea1:	c3                   	ret    

00800ea2 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  800ea2:	55                   	push   %ebp
  800ea3:	89 e5                	mov    %esp,%ebp
  800ea5:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
  800ea8:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800eac:	75 07                	jne    800eb5 <devcons_read+0x13>
  800eae:	eb 25                	jmp    800ed5 <devcons_read+0x33>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  800eb0:	e8 d8 f2 ff ff       	call   80018d <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  800eb5:	e8 69 f2 ff ff       	call   800123 <sys_cgetc>
  800eba:	85 c0                	test   %eax,%eax
  800ebc:	74 f2                	je     800eb0 <devcons_read+0xe>
  800ebe:	89 c2                	mov    %eax,%edx
		sys_yield();
	if (c < 0)
  800ec0:	85 c0                	test   %eax,%eax
  800ec2:	78 1d                	js     800ee1 <devcons_read+0x3f>
		return c;
	if (c == 0x04)	// ctl-d is eof
  800ec4:	83 f8 04             	cmp    $0x4,%eax
  800ec7:	74 13                	je     800edc <devcons_read+0x3a>
		return 0;
	*(char*)vbuf = c;
  800ec9:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ecc:	88 10                	mov    %dl,(%eax)
	return 1;
  800ece:	b8 01 00 00 00       	mov    $0x1,%eax
  800ed3:	eb 0c                	jmp    800ee1 <devcons_read+0x3f>
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
		return 0;
  800ed5:	b8 00 00 00 00       	mov    $0x0,%eax
  800eda:	eb 05                	jmp    800ee1 <devcons_read+0x3f>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  800edc:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  800ee1:	c9                   	leave  
  800ee2:	c3                   	ret    

00800ee3 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  800ee3:	55                   	push   %ebp
  800ee4:	89 e5                	mov    %esp,%ebp
  800ee6:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  800ee9:	8b 45 08             	mov    0x8(%ebp),%eax
  800eec:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  800eef:	6a 01                	push   $0x1
  800ef1:	8d 45 f7             	lea    -0x9(%ebp),%eax
  800ef4:	50                   	push   %eax
  800ef5:	e8 03 f2 ff ff       	call   8000fd <sys_cputs>
  800efa:	83 c4 10             	add    $0x10,%esp
}
  800efd:	c9                   	leave  
  800efe:	c3                   	ret    

00800eff <getchar>:

int
getchar(void)
{
  800eff:	55                   	push   %ebp
  800f00:	89 e5                	mov    %esp,%ebp
  800f02:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  800f05:	6a 01                	push   $0x1
  800f07:	8d 45 f7             	lea    -0x9(%ebp),%eax
  800f0a:	50                   	push   %eax
  800f0b:	6a 00                	push   $0x0
  800f0d:	e8 fe f6 ff ff       	call   800610 <read>
	if (r < 0)
  800f12:	83 c4 10             	add    $0x10,%esp
  800f15:	85 c0                	test   %eax,%eax
  800f17:	78 0f                	js     800f28 <getchar+0x29>
		return r;
	if (r < 1)
  800f19:	85 c0                	test   %eax,%eax
  800f1b:	7e 06                	jle    800f23 <getchar+0x24>
		return -E_EOF;
	return c;
  800f1d:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  800f21:	eb 05                	jmp    800f28 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  800f23:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  800f28:	c9                   	leave  
  800f29:	c3                   	ret    

00800f2a <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  800f2a:	55                   	push   %ebp
  800f2b:	89 e5                	mov    %esp,%ebp
  800f2d:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800f30:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800f33:	50                   	push   %eax
  800f34:	ff 75 08             	pushl  0x8(%ebp)
  800f37:	e8 53 f4 ff ff       	call   80038f <fd_lookup>
  800f3c:	83 c4 10             	add    $0x10,%esp
  800f3f:	85 c0                	test   %eax,%eax
  800f41:	78 11                	js     800f54 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  800f43:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800f46:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  800f4c:	39 10                	cmp    %edx,(%eax)
  800f4e:	0f 94 c0             	sete   %al
  800f51:	0f b6 c0             	movzbl %al,%eax
}
  800f54:	c9                   	leave  
  800f55:	c3                   	ret    

00800f56 <opencons>:

int
opencons(void)
{
  800f56:	55                   	push   %ebp
  800f57:	89 e5                	mov    %esp,%ebp
  800f59:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  800f5c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800f5f:	50                   	push   %eax
  800f60:	e8 b7 f3 ff ff       	call   80031c <fd_alloc>
  800f65:	83 c4 10             	add    $0x10,%esp
  800f68:	85 c0                	test   %eax,%eax
  800f6a:	78 3a                	js     800fa6 <opencons+0x50>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  800f6c:	83 ec 04             	sub    $0x4,%esp
  800f6f:	68 07 04 00 00       	push   $0x407
  800f74:	ff 75 f4             	pushl  -0xc(%ebp)
  800f77:	6a 00                	push   $0x0
  800f79:	e8 36 f2 ff ff       	call   8001b4 <sys_page_alloc>
  800f7e:	83 c4 10             	add    $0x10,%esp
  800f81:	85 c0                	test   %eax,%eax
  800f83:	78 21                	js     800fa6 <opencons+0x50>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  800f85:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  800f8b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800f8e:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  800f90:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800f93:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  800f9a:	83 ec 0c             	sub    $0xc,%esp
  800f9d:	50                   	push   %eax
  800f9e:	e8 51 f3 ff ff       	call   8002f4 <fd2num>
  800fa3:	83 c4 10             	add    $0x10,%esp
}
  800fa6:	c9                   	leave  
  800fa7:	c3                   	ret    

00800fa8 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800fa8:	55                   	push   %ebp
  800fa9:	89 e5                	mov    %esp,%ebp
  800fab:	56                   	push   %esi
  800fac:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800fad:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800fb0:	8b 1d 00 30 80 00    	mov    0x803000,%ebx
  800fb6:	e8 ae f1 ff ff       	call   800169 <sys_getenvid>
  800fbb:	83 ec 0c             	sub    $0xc,%esp
  800fbe:	ff 75 0c             	pushl  0xc(%ebp)
  800fc1:	ff 75 08             	pushl  0x8(%ebp)
  800fc4:	53                   	push   %ebx
  800fc5:	50                   	push   %eax
  800fc6:	68 a4 1e 80 00       	push   $0x801ea4
  800fcb:	e8 b0 00 00 00       	call   801080 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800fd0:	83 c4 18             	add    $0x18,%esp
  800fd3:	56                   	push   %esi
  800fd4:	ff 75 10             	pushl  0x10(%ebp)
  800fd7:	e8 53 00 00 00       	call   80102f <vcprintf>
	cprintf("\n");
  800fdc:	c7 04 24 8f 1e 80 00 	movl   $0x801e8f,(%esp)
  800fe3:	e8 98 00 00 00       	call   801080 <cprintf>
  800fe8:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800feb:	cc                   	int3   
  800fec:	eb fd                	jmp    800feb <_panic+0x43>
	...

00800ff0 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800ff0:	55                   	push   %ebp
  800ff1:	89 e5                	mov    %esp,%ebp
  800ff3:	53                   	push   %ebx
  800ff4:	83 ec 04             	sub    $0x4,%esp
  800ff7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800ffa:	8b 03                	mov    (%ebx),%eax
  800ffc:	8b 55 08             	mov    0x8(%ebp),%edx
  800fff:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  801003:	40                   	inc    %eax
  801004:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  801006:	3d ff 00 00 00       	cmp    $0xff,%eax
  80100b:	75 1a                	jne    801027 <putch+0x37>
		sys_cputs(b->buf, b->idx);
  80100d:	83 ec 08             	sub    $0x8,%esp
  801010:	68 ff 00 00 00       	push   $0xff
  801015:	8d 43 08             	lea    0x8(%ebx),%eax
  801018:	50                   	push   %eax
  801019:	e8 df f0 ff ff       	call   8000fd <sys_cputs>
		b->idx = 0;
  80101e:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801024:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  801027:	ff 43 04             	incl   0x4(%ebx)
}
  80102a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80102d:	c9                   	leave  
  80102e:	c3                   	ret    

0080102f <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80102f:	55                   	push   %ebp
  801030:	89 e5                	mov    %esp,%ebp
  801032:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  801038:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80103f:	00 00 00 
	b.cnt = 0;
  801042:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  801049:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80104c:	ff 75 0c             	pushl  0xc(%ebp)
  80104f:	ff 75 08             	pushl  0x8(%ebp)
  801052:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  801058:	50                   	push   %eax
  801059:	68 f0 0f 80 00       	push   $0x800ff0
  80105e:	e8 82 01 00 00       	call   8011e5 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  801063:	83 c4 08             	add    $0x8,%esp
  801066:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  80106c:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  801072:	50                   	push   %eax
  801073:	e8 85 f0 ff ff       	call   8000fd <sys_cputs>

	return b.cnt;
}
  801078:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80107e:	c9                   	leave  
  80107f:	c3                   	ret    

00801080 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  801080:	55                   	push   %ebp
  801081:	89 e5                	mov    %esp,%ebp
  801083:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  801086:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  801089:	50                   	push   %eax
  80108a:	ff 75 08             	pushl  0x8(%ebp)
  80108d:	e8 9d ff ff ff       	call   80102f <vcprintf>
	va_end(ap);

	return cnt;
}
  801092:	c9                   	leave  
  801093:	c3                   	ret    

00801094 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  801094:	55                   	push   %ebp
  801095:	89 e5                	mov    %esp,%ebp
  801097:	57                   	push   %edi
  801098:	56                   	push   %esi
  801099:	53                   	push   %ebx
  80109a:	83 ec 2c             	sub    $0x2c,%esp
  80109d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8010a0:	89 d6                	mov    %edx,%esi
  8010a2:	8b 45 08             	mov    0x8(%ebp),%eax
  8010a5:	8b 55 0c             	mov    0xc(%ebp),%edx
  8010a8:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8010ab:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8010ae:	8b 45 10             	mov    0x10(%ebp),%eax
  8010b1:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8010b4:	8b 7d 18             	mov    0x18(%ebp),%edi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8010b7:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8010ba:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  8010c1:	39 55 d4             	cmp    %edx,-0x2c(%ebp)
  8010c4:	72 0c                	jb     8010d2 <printnum+0x3e>
  8010c6:	3b 45 d8             	cmp    -0x28(%ebp),%eax
  8010c9:	76 07                	jbe    8010d2 <printnum+0x3e>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8010cb:	4b                   	dec    %ebx
  8010cc:	85 db                	test   %ebx,%ebx
  8010ce:	7f 31                	jg     801101 <printnum+0x6d>
  8010d0:	eb 3f                	jmp    801111 <printnum+0x7d>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8010d2:	83 ec 0c             	sub    $0xc,%esp
  8010d5:	57                   	push   %edi
  8010d6:	4b                   	dec    %ebx
  8010d7:	53                   	push   %ebx
  8010d8:	50                   	push   %eax
  8010d9:	83 ec 08             	sub    $0x8,%esp
  8010dc:	ff 75 d4             	pushl  -0x2c(%ebp)
  8010df:	ff 75 d0             	pushl  -0x30(%ebp)
  8010e2:	ff 75 dc             	pushl  -0x24(%ebp)
  8010e5:	ff 75 d8             	pushl  -0x28(%ebp)
  8010e8:	e8 33 0a 00 00       	call   801b20 <__udivdi3>
  8010ed:	83 c4 18             	add    $0x18,%esp
  8010f0:	52                   	push   %edx
  8010f1:	50                   	push   %eax
  8010f2:	89 f2                	mov    %esi,%edx
  8010f4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8010f7:	e8 98 ff ff ff       	call   801094 <printnum>
  8010fc:	83 c4 20             	add    $0x20,%esp
  8010ff:	eb 10                	jmp    801111 <printnum+0x7d>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  801101:	83 ec 08             	sub    $0x8,%esp
  801104:	56                   	push   %esi
  801105:	57                   	push   %edi
  801106:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  801109:	4b                   	dec    %ebx
  80110a:	83 c4 10             	add    $0x10,%esp
  80110d:	85 db                	test   %ebx,%ebx
  80110f:	7f f0                	jg     801101 <printnum+0x6d>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  801111:	83 ec 08             	sub    $0x8,%esp
  801114:	56                   	push   %esi
  801115:	83 ec 04             	sub    $0x4,%esp
  801118:	ff 75 d4             	pushl  -0x2c(%ebp)
  80111b:	ff 75 d0             	pushl  -0x30(%ebp)
  80111e:	ff 75 dc             	pushl  -0x24(%ebp)
  801121:	ff 75 d8             	pushl  -0x28(%ebp)
  801124:	e8 13 0b 00 00       	call   801c3c <__umoddi3>
  801129:	83 c4 14             	add    $0x14,%esp
  80112c:	0f be 80 c7 1e 80 00 	movsbl 0x801ec7(%eax),%eax
  801133:	50                   	push   %eax
  801134:	ff 55 e4             	call   *-0x1c(%ebp)
  801137:	83 c4 10             	add    $0x10,%esp
}
  80113a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80113d:	5b                   	pop    %ebx
  80113e:	5e                   	pop    %esi
  80113f:	5f                   	pop    %edi
  801140:	c9                   	leave  
  801141:	c3                   	ret    

00801142 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  801142:	55                   	push   %ebp
  801143:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  801145:	83 fa 01             	cmp    $0x1,%edx
  801148:	7e 0e                	jle    801158 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80114a:	8b 10                	mov    (%eax),%edx
  80114c:	8d 4a 08             	lea    0x8(%edx),%ecx
  80114f:	89 08                	mov    %ecx,(%eax)
  801151:	8b 02                	mov    (%edx),%eax
  801153:	8b 52 04             	mov    0x4(%edx),%edx
  801156:	eb 22                	jmp    80117a <getuint+0x38>
	else if (lflag)
  801158:	85 d2                	test   %edx,%edx
  80115a:	74 10                	je     80116c <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  80115c:	8b 10                	mov    (%eax),%edx
  80115e:	8d 4a 04             	lea    0x4(%edx),%ecx
  801161:	89 08                	mov    %ecx,(%eax)
  801163:	8b 02                	mov    (%edx),%eax
  801165:	ba 00 00 00 00       	mov    $0x0,%edx
  80116a:	eb 0e                	jmp    80117a <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  80116c:	8b 10                	mov    (%eax),%edx
  80116e:	8d 4a 04             	lea    0x4(%edx),%ecx
  801171:	89 08                	mov    %ecx,(%eax)
  801173:	8b 02                	mov    (%edx),%eax
  801175:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80117a:	c9                   	leave  
  80117b:	c3                   	ret    

0080117c <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
  80117c:	55                   	push   %ebp
  80117d:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80117f:	83 fa 01             	cmp    $0x1,%edx
  801182:	7e 0e                	jle    801192 <getint+0x16>
		return va_arg(*ap, long long);
  801184:	8b 10                	mov    (%eax),%edx
  801186:	8d 4a 08             	lea    0x8(%edx),%ecx
  801189:	89 08                	mov    %ecx,(%eax)
  80118b:	8b 02                	mov    (%edx),%eax
  80118d:	8b 52 04             	mov    0x4(%edx),%edx
  801190:	eb 1a                	jmp    8011ac <getint+0x30>
	else if (lflag)
  801192:	85 d2                	test   %edx,%edx
  801194:	74 0c                	je     8011a2 <getint+0x26>
		return va_arg(*ap, long);
  801196:	8b 10                	mov    (%eax),%edx
  801198:	8d 4a 04             	lea    0x4(%edx),%ecx
  80119b:	89 08                	mov    %ecx,(%eax)
  80119d:	8b 02                	mov    (%edx),%eax
  80119f:	99                   	cltd   
  8011a0:	eb 0a                	jmp    8011ac <getint+0x30>
	else
		return va_arg(*ap, int);
  8011a2:	8b 10                	mov    (%eax),%edx
  8011a4:	8d 4a 04             	lea    0x4(%edx),%ecx
  8011a7:	89 08                	mov    %ecx,(%eax)
  8011a9:	8b 02                	mov    (%edx),%eax
  8011ab:	99                   	cltd   
}
  8011ac:	c9                   	leave  
  8011ad:	c3                   	ret    

008011ae <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8011ae:	55                   	push   %ebp
  8011af:	89 e5                	mov    %esp,%ebp
  8011b1:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8011b4:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  8011b7:	8b 10                	mov    (%eax),%edx
  8011b9:	3b 50 04             	cmp    0x4(%eax),%edx
  8011bc:	73 08                	jae    8011c6 <sprintputch+0x18>
		*b->buf++ = ch;
  8011be:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8011c1:	88 0a                	mov    %cl,(%edx)
  8011c3:	42                   	inc    %edx
  8011c4:	89 10                	mov    %edx,(%eax)
}
  8011c6:	c9                   	leave  
  8011c7:	c3                   	ret    

008011c8 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8011c8:	55                   	push   %ebp
  8011c9:	89 e5                	mov    %esp,%ebp
  8011cb:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8011ce:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8011d1:	50                   	push   %eax
  8011d2:	ff 75 10             	pushl  0x10(%ebp)
  8011d5:	ff 75 0c             	pushl  0xc(%ebp)
  8011d8:	ff 75 08             	pushl  0x8(%ebp)
  8011db:	e8 05 00 00 00       	call   8011e5 <vprintfmt>
	va_end(ap);
  8011e0:	83 c4 10             	add    $0x10,%esp
}
  8011e3:	c9                   	leave  
  8011e4:	c3                   	ret    

008011e5 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8011e5:	55                   	push   %ebp
  8011e6:	89 e5                	mov    %esp,%ebp
  8011e8:	57                   	push   %edi
  8011e9:	56                   	push   %esi
  8011ea:	53                   	push   %ebx
  8011eb:	83 ec 2c             	sub    $0x2c,%esp
  8011ee:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8011f1:	8b 75 10             	mov    0x10(%ebp),%esi
  8011f4:	eb 13                	jmp    801209 <vprintfmt+0x24>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8011f6:	85 c0                	test   %eax,%eax
  8011f8:	0f 84 6d 03 00 00    	je     80156b <vprintfmt+0x386>
				return;
			putch(ch, putdat);
  8011fe:	83 ec 08             	sub    $0x8,%esp
  801201:	57                   	push   %edi
  801202:	50                   	push   %eax
  801203:	ff 55 08             	call   *0x8(%ebp)
  801206:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  801209:	0f b6 06             	movzbl (%esi),%eax
  80120c:	46                   	inc    %esi
  80120d:	83 f8 25             	cmp    $0x25,%eax
  801210:	75 e4                	jne    8011f6 <vprintfmt+0x11>
  801212:	c6 45 dc 20          	movb   $0x20,-0x24(%ebp)
  801216:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  80121d:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
  801224:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  80122b:	b9 00 00 00 00       	mov    $0x0,%ecx
  801230:	eb 28                	jmp    80125a <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801232:	89 de                	mov    %ebx,%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  801234:	c6 45 dc 2d          	movb   $0x2d,-0x24(%ebp)
  801238:	eb 20                	jmp    80125a <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80123a:	89 de                	mov    %ebx,%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  80123c:	c6 45 dc 30          	movb   $0x30,-0x24(%ebp)
  801240:	eb 18                	jmp    80125a <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801242:	89 de                	mov    %ebx,%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  801244:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  80124b:	eb 0d                	jmp    80125a <vprintfmt+0x75>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  80124d:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  801250:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801253:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80125a:	8a 06                	mov    (%esi),%al
  80125c:	0f b6 d0             	movzbl %al,%edx
  80125f:	8d 5e 01             	lea    0x1(%esi),%ebx
  801262:	83 e8 23             	sub    $0x23,%eax
  801265:	3c 55                	cmp    $0x55,%al
  801267:	0f 87 e0 02 00 00    	ja     80154d <vprintfmt+0x368>
  80126d:	0f b6 c0             	movzbl %al,%eax
  801270:	ff 24 85 00 20 80 00 	jmp    *0x802000(,%eax,4)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  801277:	83 ea 30             	sub    $0x30,%edx
  80127a:	89 55 d4             	mov    %edx,-0x2c(%ebp)
				ch = *fmt;
  80127d:	0f be 03             	movsbl (%ebx),%eax
				if (ch < '0' || ch > '9')
  801280:	8d 50 d0             	lea    -0x30(%eax),%edx
  801283:	83 fa 09             	cmp    $0x9,%edx
  801286:	77 44                	ja     8012cc <vprintfmt+0xe7>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801288:	89 de                	mov    %ebx,%esi
  80128a:	8b 55 d4             	mov    -0x2c(%ebp),%edx
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80128d:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
  80128e:	8d 14 92             	lea    (%edx,%edx,4),%edx
  801291:	8d 54 50 d0          	lea    -0x30(%eax,%edx,2),%edx
				ch = *fmt;
  801295:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  801298:	8d 58 d0             	lea    -0x30(%eax),%ebx
  80129b:	83 fb 09             	cmp    $0x9,%ebx
  80129e:	76 ed                	jbe    80128d <vprintfmt+0xa8>
  8012a0:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  8012a3:	eb 29                	jmp    8012ce <vprintfmt+0xe9>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8012a5:	8b 45 14             	mov    0x14(%ebp),%eax
  8012a8:	8d 50 04             	lea    0x4(%eax),%edx
  8012ab:	89 55 14             	mov    %edx,0x14(%ebp)
  8012ae:	8b 00                	mov    (%eax),%eax
  8012b0:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8012b3:	89 de                	mov    %ebx,%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8012b5:	eb 17                	jmp    8012ce <vprintfmt+0xe9>

		case '.':
			if (width < 0)
  8012b7:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8012bb:	78 85                	js     801242 <vprintfmt+0x5d>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8012bd:	89 de                	mov    %ebx,%esi
  8012bf:	eb 99                	jmp    80125a <vprintfmt+0x75>
  8012c1:	89 de                	mov    %ebx,%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8012c3:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
			goto reswitch;
  8012ca:	eb 8e                	jmp    80125a <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8012cc:	89 de                	mov    %ebx,%esi
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  8012ce:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8012d2:	79 86                	jns    80125a <vprintfmt+0x75>
  8012d4:	e9 74 ff ff ff       	jmp    80124d <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8012d9:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8012da:	89 de                	mov    %ebx,%esi
  8012dc:	e9 79 ff ff ff       	jmp    80125a <vprintfmt+0x75>
  8012e1:	89 5d d8             	mov    %ebx,-0x28(%ebp)
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8012e4:	8b 45 14             	mov    0x14(%ebp),%eax
  8012e7:	8d 50 04             	lea    0x4(%eax),%edx
  8012ea:	89 55 14             	mov    %edx,0x14(%ebp)
  8012ed:	83 ec 08             	sub    $0x8,%esp
  8012f0:	57                   	push   %edi
  8012f1:	ff 30                	pushl  (%eax)
  8012f3:	ff 55 08             	call   *0x8(%ebp)
			break;
  8012f6:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8012f9:	8b 75 d8             	mov    -0x28(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8012fc:	e9 08 ff ff ff       	jmp    801209 <vprintfmt+0x24>
  801301:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// error message
		case 'e':
			err = va_arg(ap, int);
  801304:	8b 45 14             	mov    0x14(%ebp),%eax
  801307:	8d 50 04             	lea    0x4(%eax),%edx
  80130a:	89 55 14             	mov    %edx,0x14(%ebp)
  80130d:	8b 00                	mov    (%eax),%eax
  80130f:	85 c0                	test   %eax,%eax
  801311:	79 02                	jns    801315 <vprintfmt+0x130>
  801313:	f7 d8                	neg    %eax
  801315:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  801317:	83 f8 0f             	cmp    $0xf,%eax
  80131a:	7f 0b                	jg     801327 <vprintfmt+0x142>
  80131c:	8b 04 85 60 21 80 00 	mov    0x802160(,%eax,4),%eax
  801323:	85 c0                	test   %eax,%eax
  801325:	75 1a                	jne    801341 <vprintfmt+0x15c>
				printfmt(putch, putdat, "error %d", err);
  801327:	52                   	push   %edx
  801328:	68 df 1e 80 00       	push   $0x801edf
  80132d:	57                   	push   %edi
  80132e:	ff 75 08             	pushl  0x8(%ebp)
  801331:	e8 92 fe ff ff       	call   8011c8 <printfmt>
  801336:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801339:	8b 75 d8             	mov    -0x28(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  80133c:	e9 c8 fe ff ff       	jmp    801209 <vprintfmt+0x24>
			else
				printfmt(putch, putdat, "%s", p);
  801341:	50                   	push   %eax
  801342:	68 5d 1e 80 00       	push   $0x801e5d
  801347:	57                   	push   %edi
  801348:	ff 75 08             	pushl  0x8(%ebp)
  80134b:	e8 78 fe ff ff       	call   8011c8 <printfmt>
  801350:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801353:	8b 75 d8             	mov    -0x28(%ebp),%esi
  801356:	e9 ae fe ff ff       	jmp    801209 <vprintfmt+0x24>
  80135b:	89 5d d8             	mov    %ebx,-0x28(%ebp)
  80135e:	89 de                	mov    %ebx,%esi
  801360:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  801363:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  801366:	8b 45 14             	mov    0x14(%ebp),%eax
  801369:	8d 50 04             	lea    0x4(%eax),%edx
  80136c:	89 55 14             	mov    %edx,0x14(%ebp)
  80136f:	8b 00                	mov    (%eax),%eax
  801371:	89 45 d0             	mov    %eax,-0x30(%ebp)
  801374:	85 c0                	test   %eax,%eax
  801376:	75 07                	jne    80137f <vprintfmt+0x19a>
				p = "(null)";
  801378:	c7 45 d0 d8 1e 80 00 	movl   $0x801ed8,-0x30(%ebp)
			if (width > 0 && padc != '-')
  80137f:	85 db                	test   %ebx,%ebx
  801381:	7e 42                	jle    8013c5 <vprintfmt+0x1e0>
  801383:	80 7d dc 2d          	cmpb   $0x2d,-0x24(%ebp)
  801387:	74 3c                	je     8013c5 <vprintfmt+0x1e0>
				for (width -= strnlen(p, precision); width > 0; width--)
  801389:	83 ec 08             	sub    $0x8,%esp
  80138c:	51                   	push   %ecx
  80138d:	ff 75 d0             	pushl  -0x30(%ebp)
  801390:	e8 6f 02 00 00       	call   801604 <strnlen>
  801395:	29 c3                	sub    %eax,%ebx
  801397:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  80139a:	83 c4 10             	add    $0x10,%esp
  80139d:	85 db                	test   %ebx,%ebx
  80139f:	7e 24                	jle    8013c5 <vprintfmt+0x1e0>
					putch(padc, putdat);
  8013a1:	0f be 5d dc          	movsbl -0x24(%ebp),%ebx
  8013a5:	89 75 dc             	mov    %esi,-0x24(%ebp)
  8013a8:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  8013ab:	83 ec 08             	sub    $0x8,%esp
  8013ae:	57                   	push   %edi
  8013af:	53                   	push   %ebx
  8013b0:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8013b3:	4e                   	dec    %esi
  8013b4:	83 c4 10             	add    $0x10,%esp
  8013b7:	85 f6                	test   %esi,%esi
  8013b9:	7f f0                	jg     8013ab <vprintfmt+0x1c6>
  8013bb:	8b 75 dc             	mov    -0x24(%ebp),%esi
  8013be:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8013c5:	8b 55 d0             	mov    -0x30(%ebp),%edx
  8013c8:	0f be 02             	movsbl (%edx),%eax
  8013cb:	85 c0                	test   %eax,%eax
  8013cd:	75 47                	jne    801416 <vprintfmt+0x231>
  8013cf:	eb 37                	jmp    801408 <vprintfmt+0x223>
				if (altflag && (ch < ' ' || ch > '~'))
  8013d1:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8013d5:	74 16                	je     8013ed <vprintfmt+0x208>
  8013d7:	8d 50 e0             	lea    -0x20(%eax),%edx
  8013da:	83 fa 5e             	cmp    $0x5e,%edx
  8013dd:	76 0e                	jbe    8013ed <vprintfmt+0x208>
					putch('?', putdat);
  8013df:	83 ec 08             	sub    $0x8,%esp
  8013e2:	57                   	push   %edi
  8013e3:	6a 3f                	push   $0x3f
  8013e5:	ff 55 08             	call   *0x8(%ebp)
  8013e8:	83 c4 10             	add    $0x10,%esp
  8013eb:	eb 0b                	jmp    8013f8 <vprintfmt+0x213>
				else
					putch(ch, putdat);
  8013ed:	83 ec 08             	sub    $0x8,%esp
  8013f0:	57                   	push   %edi
  8013f1:	50                   	push   %eax
  8013f2:	ff 55 08             	call   *0x8(%ebp)
  8013f5:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8013f8:	ff 4d e4             	decl   -0x1c(%ebp)
  8013fb:	0f be 03             	movsbl (%ebx),%eax
  8013fe:	85 c0                	test   %eax,%eax
  801400:	74 03                	je     801405 <vprintfmt+0x220>
  801402:	43                   	inc    %ebx
  801403:	eb 1b                	jmp    801420 <vprintfmt+0x23b>
  801405:	8b 75 dc             	mov    -0x24(%ebp),%esi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  801408:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80140c:	7f 1e                	jg     80142c <vprintfmt+0x247>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80140e:	8b 75 d8             	mov    -0x28(%ebp),%esi
  801411:	e9 f3 fd ff ff       	jmp    801209 <vprintfmt+0x24>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  801416:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  801419:	43                   	inc    %ebx
  80141a:	89 75 dc             	mov    %esi,-0x24(%ebp)
  80141d:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  801420:	85 f6                	test   %esi,%esi
  801422:	78 ad                	js     8013d1 <vprintfmt+0x1ec>
  801424:	4e                   	dec    %esi
  801425:	79 aa                	jns    8013d1 <vprintfmt+0x1ec>
  801427:	8b 75 dc             	mov    -0x24(%ebp),%esi
  80142a:	eb dc                	jmp    801408 <vprintfmt+0x223>
  80142c:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80142f:	83 ec 08             	sub    $0x8,%esp
  801432:	57                   	push   %edi
  801433:	6a 20                	push   $0x20
  801435:	ff 55 08             	call   *0x8(%ebp)
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  801438:	4b                   	dec    %ebx
  801439:	83 c4 10             	add    $0x10,%esp
  80143c:	85 db                	test   %ebx,%ebx
  80143e:	7f ef                	jg     80142f <vprintfmt+0x24a>
  801440:	e9 c4 fd ff ff       	jmp    801209 <vprintfmt+0x24>
  801445:	89 5d d8             	mov    %ebx,-0x28(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  801448:	89 ca                	mov    %ecx,%edx
  80144a:	8d 45 14             	lea    0x14(%ebp),%eax
  80144d:	e8 2a fd ff ff       	call   80117c <getint>
  801452:	89 c3                	mov    %eax,%ebx
  801454:	89 d6                	mov    %edx,%esi
			if ((long long) num < 0) {
  801456:	85 d2                	test   %edx,%edx
  801458:	78 0a                	js     801464 <vprintfmt+0x27f>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  80145a:	b8 0a 00 00 00       	mov    $0xa,%eax
  80145f:	e9 b0 00 00 00       	jmp    801514 <vprintfmt+0x32f>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  801464:	83 ec 08             	sub    $0x8,%esp
  801467:	57                   	push   %edi
  801468:	6a 2d                	push   $0x2d
  80146a:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  80146d:	f7 db                	neg    %ebx
  80146f:	83 d6 00             	adc    $0x0,%esi
  801472:	f7 de                	neg    %esi
  801474:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  801477:	b8 0a 00 00 00       	mov    $0xa,%eax
  80147c:	e9 93 00 00 00       	jmp    801514 <vprintfmt+0x32f>
  801481:	89 5d d8             	mov    %ebx,-0x28(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  801484:	89 ca                	mov    %ecx,%edx
  801486:	8d 45 14             	lea    0x14(%ebp),%eax
  801489:	e8 b4 fc ff ff       	call   801142 <getuint>
  80148e:	89 c3                	mov    %eax,%ebx
  801490:	89 d6                	mov    %edx,%esi
			base = 10;
  801492:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  801497:	eb 7b                	jmp    801514 <vprintfmt+0x32f>
  801499:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// (unsigned) octal
		case 'o':
            // (MIT 6.828, lab1, Ex.8)  my code : 
            num = getint(&ap, lflag);
  80149c:	89 ca                	mov    %ecx,%edx
  80149e:	8d 45 14             	lea    0x14(%ebp),%eax
  8014a1:	e8 d6 fc ff ff       	call   80117c <getint>
  8014a6:	89 c3                	mov    %eax,%ebx
  8014a8:	89 d6                	mov    %edx,%esi
            if ((long long) num < 0) {
  8014aa:	85 d2                	test   %edx,%edx
  8014ac:	78 07                	js     8014b5 <vprintfmt+0x2d0>
                putch('-', putdat);
                num = -(long long) num;
            }
            base = 8;
  8014ae:	b8 08 00 00 00       	mov    $0x8,%eax
  8014b3:	eb 5f                	jmp    801514 <vprintfmt+0x32f>
		// (unsigned) octal
		case 'o':
            // (MIT 6.828, lab1, Ex.8)  my code : 
            num = getint(&ap, lflag);
            if ((long long) num < 0) {
                putch('-', putdat);
  8014b5:	83 ec 08             	sub    $0x8,%esp
  8014b8:	57                   	push   %edi
  8014b9:	6a 2d                	push   $0x2d
  8014bb:	ff 55 08             	call   *0x8(%ebp)
                num = -(long long) num;
  8014be:	f7 db                	neg    %ebx
  8014c0:	83 d6 00             	adc    $0x0,%esi
  8014c3:	f7 de                	neg    %esi
  8014c5:	83 c4 10             	add    $0x10,%esp
            }
            base = 8;
  8014c8:	b8 08 00 00 00       	mov    $0x8,%eax
  8014cd:	eb 45                	jmp    801514 <vprintfmt+0x32f>
  8014cf:	89 5d d8             	mov    %ebx,-0x28(%ebp)
            goto number;

        // pointer
		case 'p':
			putch('0', putdat);
  8014d2:	83 ec 08             	sub    $0x8,%esp
  8014d5:	57                   	push   %edi
  8014d6:	6a 30                	push   $0x30
  8014d8:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  8014db:	83 c4 08             	add    $0x8,%esp
  8014de:	57                   	push   %edi
  8014df:	6a 78                	push   $0x78
  8014e1:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8014e4:	8b 45 14             	mov    0x14(%ebp),%eax
  8014e7:	8d 50 04             	lea    0x4(%eax),%edx
  8014ea:	89 55 14             	mov    %edx,0x14(%ebp)

        // pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8014ed:	8b 18                	mov    (%eax),%ebx
  8014ef:	be 00 00 00 00       	mov    $0x0,%esi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8014f4:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8014f7:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  8014fc:	eb 16                	jmp    801514 <vprintfmt+0x32f>
  8014fe:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  801501:	89 ca                	mov    %ecx,%edx
  801503:	8d 45 14             	lea    0x14(%ebp),%eax
  801506:	e8 37 fc ff ff       	call   801142 <getuint>
  80150b:	89 c3                	mov    %eax,%ebx
  80150d:	89 d6                	mov    %edx,%esi
			base = 16;
  80150f:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  801514:	83 ec 0c             	sub    $0xc,%esp
  801517:	0f be 55 dc          	movsbl -0x24(%ebp),%edx
  80151b:	52                   	push   %edx
  80151c:	ff 75 e4             	pushl  -0x1c(%ebp)
  80151f:	50                   	push   %eax
  801520:	56                   	push   %esi
  801521:	53                   	push   %ebx
  801522:	89 fa                	mov    %edi,%edx
  801524:	8b 45 08             	mov    0x8(%ebp),%eax
  801527:	e8 68 fb ff ff       	call   801094 <printnum>
			break;
  80152c:	83 c4 20             	add    $0x20,%esp
  80152f:	8b 75 d8             	mov    -0x28(%ebp),%esi
  801532:	e9 d2 fc ff ff       	jmp    801209 <vprintfmt+0x24>
  801537:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80153a:	83 ec 08             	sub    $0x8,%esp
  80153d:	57                   	push   %edi
  80153e:	52                   	push   %edx
  80153f:	ff 55 08             	call   *0x8(%ebp)
			break;
  801542:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801545:	8b 75 d8             	mov    -0x28(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  801548:	e9 bc fc ff ff       	jmp    801209 <vprintfmt+0x24>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80154d:	83 ec 08             	sub    $0x8,%esp
  801550:	57                   	push   %edi
  801551:	6a 25                	push   $0x25
  801553:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  801556:	83 c4 10             	add    $0x10,%esp
  801559:	eb 02                	jmp    80155d <vprintfmt+0x378>
  80155b:	89 c6                	mov    %eax,%esi
  80155d:	8d 46 ff             	lea    -0x1(%esi),%eax
  801560:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  801564:	75 f5                	jne    80155b <vprintfmt+0x376>
  801566:	e9 9e fc ff ff       	jmp    801209 <vprintfmt+0x24>
				/* do nothing */;
			break;
		}
	}
}
  80156b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80156e:	5b                   	pop    %ebx
  80156f:	5e                   	pop    %esi
  801570:	5f                   	pop    %edi
  801571:	c9                   	leave  
  801572:	c3                   	ret    

00801573 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  801573:	55                   	push   %ebp
  801574:	89 e5                	mov    %esp,%ebp
  801576:	83 ec 18             	sub    $0x18,%esp
  801579:	8b 45 08             	mov    0x8(%ebp),%eax
  80157c:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80157f:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801582:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  801586:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  801589:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  801590:	85 c0                	test   %eax,%eax
  801592:	74 26                	je     8015ba <vsnprintf+0x47>
  801594:	85 d2                	test   %edx,%edx
  801596:	7e 29                	jle    8015c1 <vsnprintf+0x4e>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  801598:	ff 75 14             	pushl  0x14(%ebp)
  80159b:	ff 75 10             	pushl  0x10(%ebp)
  80159e:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8015a1:	50                   	push   %eax
  8015a2:	68 ae 11 80 00       	push   $0x8011ae
  8015a7:	e8 39 fc ff ff       	call   8011e5 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8015ac:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8015af:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8015b2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8015b5:	83 c4 10             	add    $0x10,%esp
  8015b8:	eb 0c                	jmp    8015c6 <vsnprintf+0x53>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8015ba:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8015bf:	eb 05                	jmp    8015c6 <vsnprintf+0x53>
  8015c1:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8015c6:	c9                   	leave  
  8015c7:	c3                   	ret    

008015c8 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8015c8:	55                   	push   %ebp
  8015c9:	89 e5                	mov    %esp,%ebp
  8015cb:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8015ce:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8015d1:	50                   	push   %eax
  8015d2:	ff 75 10             	pushl  0x10(%ebp)
  8015d5:	ff 75 0c             	pushl  0xc(%ebp)
  8015d8:	ff 75 08             	pushl  0x8(%ebp)
  8015db:	e8 93 ff ff ff       	call   801573 <vsnprintf>
	va_end(ap);

	return rc;
}
  8015e0:	c9                   	leave  
  8015e1:	c3                   	ret    
	...

008015e4 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8015e4:	55                   	push   %ebp
  8015e5:	89 e5                	mov    %esp,%ebp
  8015e7:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8015ea:	80 3a 00             	cmpb   $0x0,(%edx)
  8015ed:	74 0e                	je     8015fd <strlen+0x19>
  8015ef:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  8015f4:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8015f5:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8015f9:	75 f9                	jne    8015f4 <strlen+0x10>
  8015fb:	eb 05                	jmp    801602 <strlen+0x1e>
  8015fd:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  801602:	c9                   	leave  
  801603:	c3                   	ret    

00801604 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  801604:	55                   	push   %ebp
  801605:	89 e5                	mov    %esp,%ebp
  801607:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80160a:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80160d:	85 d2                	test   %edx,%edx
  80160f:	74 17                	je     801628 <strnlen+0x24>
  801611:	80 39 00             	cmpb   $0x0,(%ecx)
  801614:	74 19                	je     80162f <strnlen+0x2b>
  801616:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  80161b:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80161c:	39 d0                	cmp    %edx,%eax
  80161e:	74 14                	je     801634 <strnlen+0x30>
  801620:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  801624:	75 f5                	jne    80161b <strnlen+0x17>
  801626:	eb 0c                	jmp    801634 <strnlen+0x30>
  801628:	b8 00 00 00 00       	mov    $0x0,%eax
  80162d:	eb 05                	jmp    801634 <strnlen+0x30>
  80162f:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  801634:	c9                   	leave  
  801635:	c3                   	ret    

00801636 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  801636:	55                   	push   %ebp
  801637:	89 e5                	mov    %esp,%ebp
  801639:	53                   	push   %ebx
  80163a:	8b 45 08             	mov    0x8(%ebp),%eax
  80163d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  801640:	ba 00 00 00 00       	mov    $0x0,%edx
  801645:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  801648:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  80164b:	42                   	inc    %edx
  80164c:	84 c9                	test   %cl,%cl
  80164e:	75 f5                	jne    801645 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  801650:	5b                   	pop    %ebx
  801651:	c9                   	leave  
  801652:	c3                   	ret    

00801653 <strcat>:

char *
strcat(char *dst, const char *src)
{
  801653:	55                   	push   %ebp
  801654:	89 e5                	mov    %esp,%ebp
  801656:	53                   	push   %ebx
  801657:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80165a:	53                   	push   %ebx
  80165b:	e8 84 ff ff ff       	call   8015e4 <strlen>
  801660:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  801663:	ff 75 0c             	pushl  0xc(%ebp)
  801666:	8d 04 03             	lea    (%ebx,%eax,1),%eax
  801669:	50                   	push   %eax
  80166a:	e8 c7 ff ff ff       	call   801636 <strcpy>
	return dst;
}
  80166f:	89 d8                	mov    %ebx,%eax
  801671:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801674:	c9                   	leave  
  801675:	c3                   	ret    

00801676 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  801676:	55                   	push   %ebp
  801677:	89 e5                	mov    %esp,%ebp
  801679:	56                   	push   %esi
  80167a:	53                   	push   %ebx
  80167b:	8b 45 08             	mov    0x8(%ebp),%eax
  80167e:	8b 55 0c             	mov    0xc(%ebp),%edx
  801681:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801684:	85 f6                	test   %esi,%esi
  801686:	74 15                	je     80169d <strncpy+0x27>
  801688:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
  80168d:	8a 1a                	mov    (%edx),%bl
  80168f:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  801692:	80 3a 01             	cmpb   $0x1,(%edx)
  801695:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801698:	41                   	inc    %ecx
  801699:	39 ce                	cmp    %ecx,%esi
  80169b:	77 f0                	ja     80168d <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  80169d:	5b                   	pop    %ebx
  80169e:	5e                   	pop    %esi
  80169f:	c9                   	leave  
  8016a0:	c3                   	ret    

008016a1 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8016a1:	55                   	push   %ebp
  8016a2:	89 e5                	mov    %esp,%ebp
  8016a4:	57                   	push   %edi
  8016a5:	56                   	push   %esi
  8016a6:	53                   	push   %ebx
  8016a7:	8b 7d 08             	mov    0x8(%ebp),%edi
  8016aa:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8016ad:	8b 75 10             	mov    0x10(%ebp),%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8016b0:	85 f6                	test   %esi,%esi
  8016b2:	74 32                	je     8016e6 <strlcpy+0x45>
		while (--size > 0 && *src != '\0')
  8016b4:	83 fe 01             	cmp    $0x1,%esi
  8016b7:	74 22                	je     8016db <strlcpy+0x3a>
  8016b9:	8a 0b                	mov    (%ebx),%cl
  8016bb:	84 c9                	test   %cl,%cl
  8016bd:	74 20                	je     8016df <strlcpy+0x3e>
  8016bf:	89 f8                	mov    %edi,%eax
  8016c1:	ba 00 00 00 00       	mov    $0x0,%edx
	}
	return ret;
}

size_t
strlcpy(char *dst, const char *src, size_t size)
  8016c6:	83 ee 02             	sub    $0x2,%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8016c9:	88 08                	mov    %cl,(%eax)
  8016cb:	40                   	inc    %eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8016cc:	39 f2                	cmp    %esi,%edx
  8016ce:	74 11                	je     8016e1 <strlcpy+0x40>
  8016d0:	8a 4c 13 01          	mov    0x1(%ebx,%edx,1),%cl
  8016d4:	42                   	inc    %edx
  8016d5:	84 c9                	test   %cl,%cl
  8016d7:	75 f0                	jne    8016c9 <strlcpy+0x28>
  8016d9:	eb 06                	jmp    8016e1 <strlcpy+0x40>
  8016db:	89 f8                	mov    %edi,%eax
  8016dd:	eb 02                	jmp    8016e1 <strlcpy+0x40>
  8016df:	89 f8                	mov    %edi,%eax
			*dst++ = *src++;
		*dst = '\0';
  8016e1:	c6 00 00             	movb   $0x0,(%eax)
  8016e4:	eb 02                	jmp    8016e8 <strlcpy+0x47>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8016e6:	89 f8                	mov    %edi,%eax
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
		*dst = '\0';
	}
	return dst - dst_in;
  8016e8:	29 f8                	sub    %edi,%eax
}
  8016ea:	5b                   	pop    %ebx
  8016eb:	5e                   	pop    %esi
  8016ec:	5f                   	pop    %edi
  8016ed:	c9                   	leave  
  8016ee:	c3                   	ret    

008016ef <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8016ef:	55                   	push   %ebp
  8016f0:	89 e5                	mov    %esp,%ebp
  8016f2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8016f5:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8016f8:	8a 01                	mov    (%ecx),%al
  8016fa:	84 c0                	test   %al,%al
  8016fc:	74 10                	je     80170e <strcmp+0x1f>
  8016fe:	3a 02                	cmp    (%edx),%al
  801700:	75 0c                	jne    80170e <strcmp+0x1f>
		p++, q++;
  801702:	41                   	inc    %ecx
  801703:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  801704:	8a 01                	mov    (%ecx),%al
  801706:	84 c0                	test   %al,%al
  801708:	74 04                	je     80170e <strcmp+0x1f>
  80170a:	3a 02                	cmp    (%edx),%al
  80170c:	74 f4                	je     801702 <strcmp+0x13>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  80170e:	0f b6 c0             	movzbl %al,%eax
  801711:	0f b6 12             	movzbl (%edx),%edx
  801714:	29 d0                	sub    %edx,%eax
}
  801716:	c9                   	leave  
  801717:	c3                   	ret    

00801718 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  801718:	55                   	push   %ebp
  801719:	89 e5                	mov    %esp,%ebp
  80171b:	53                   	push   %ebx
  80171c:	8b 55 08             	mov    0x8(%ebp),%edx
  80171f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801722:	8b 45 10             	mov    0x10(%ebp),%eax
	while (n > 0 && *p && *p == *q)
  801725:	85 c0                	test   %eax,%eax
  801727:	74 1b                	je     801744 <strncmp+0x2c>
  801729:	8a 1a                	mov    (%edx),%bl
  80172b:	84 db                	test   %bl,%bl
  80172d:	74 24                	je     801753 <strncmp+0x3b>
  80172f:	3a 19                	cmp    (%ecx),%bl
  801731:	75 20                	jne    801753 <strncmp+0x3b>
  801733:	48                   	dec    %eax
  801734:	74 15                	je     80174b <strncmp+0x33>
		n--, p++, q++;
  801736:	42                   	inc    %edx
  801737:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  801738:	8a 1a                	mov    (%edx),%bl
  80173a:	84 db                	test   %bl,%bl
  80173c:	74 15                	je     801753 <strncmp+0x3b>
  80173e:	3a 19                	cmp    (%ecx),%bl
  801740:	74 f1                	je     801733 <strncmp+0x1b>
  801742:	eb 0f                	jmp    801753 <strncmp+0x3b>
		n--, p++, q++;
	if (n == 0)
		return 0;
  801744:	b8 00 00 00 00       	mov    $0x0,%eax
  801749:	eb 05                	jmp    801750 <strncmp+0x38>
  80174b:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  801750:	5b                   	pop    %ebx
  801751:	c9                   	leave  
  801752:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  801753:	0f b6 02             	movzbl (%edx),%eax
  801756:	0f b6 11             	movzbl (%ecx),%edx
  801759:	29 d0                	sub    %edx,%eax
  80175b:	eb f3                	jmp    801750 <strncmp+0x38>

0080175d <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80175d:	55                   	push   %ebp
  80175e:	89 e5                	mov    %esp,%ebp
  801760:	8b 45 08             	mov    0x8(%ebp),%eax
  801763:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  801766:	8a 10                	mov    (%eax),%dl
  801768:	84 d2                	test   %dl,%dl
  80176a:	74 18                	je     801784 <strchr+0x27>
		if (*s == c)
  80176c:	38 ca                	cmp    %cl,%dl
  80176e:	75 06                	jne    801776 <strchr+0x19>
  801770:	eb 17                	jmp    801789 <strchr+0x2c>
  801772:	38 ca                	cmp    %cl,%dl
  801774:	74 13                	je     801789 <strchr+0x2c>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  801776:	40                   	inc    %eax
  801777:	8a 10                	mov    (%eax),%dl
  801779:	84 d2                	test   %dl,%dl
  80177b:	75 f5                	jne    801772 <strchr+0x15>
		if (*s == c)
			return (char *) s;
	return 0;
  80177d:	b8 00 00 00 00       	mov    $0x0,%eax
  801782:	eb 05                	jmp    801789 <strchr+0x2c>
  801784:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801789:	c9                   	leave  
  80178a:	c3                   	ret    

0080178b <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80178b:	55                   	push   %ebp
  80178c:	89 e5                	mov    %esp,%ebp
  80178e:	8b 45 08             	mov    0x8(%ebp),%eax
  801791:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  801794:	8a 10                	mov    (%eax),%dl
  801796:	84 d2                	test   %dl,%dl
  801798:	74 11                	je     8017ab <strfind+0x20>
		if (*s == c)
  80179a:	38 ca                	cmp    %cl,%dl
  80179c:	75 06                	jne    8017a4 <strfind+0x19>
  80179e:	eb 0b                	jmp    8017ab <strfind+0x20>
  8017a0:	38 ca                	cmp    %cl,%dl
  8017a2:	74 07                	je     8017ab <strfind+0x20>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  8017a4:	40                   	inc    %eax
  8017a5:	8a 10                	mov    (%eax),%dl
  8017a7:	84 d2                	test   %dl,%dl
  8017a9:	75 f5                	jne    8017a0 <strfind+0x15>
		if (*s == c)
			break;
	return (char *) s;
}
  8017ab:	c9                   	leave  
  8017ac:	c3                   	ret    

008017ad <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8017ad:	55                   	push   %ebp
  8017ae:	89 e5                	mov    %esp,%ebp
  8017b0:	57                   	push   %edi
  8017b1:	56                   	push   %esi
  8017b2:	53                   	push   %ebx
  8017b3:	8b 7d 08             	mov    0x8(%ebp),%edi
  8017b6:	8b 45 0c             	mov    0xc(%ebp),%eax
  8017b9:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8017bc:	85 c9                	test   %ecx,%ecx
  8017be:	74 30                	je     8017f0 <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8017c0:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8017c6:	75 25                	jne    8017ed <memset+0x40>
  8017c8:	f6 c1 03             	test   $0x3,%cl
  8017cb:	75 20                	jne    8017ed <memset+0x40>
		c &= 0xFF;
  8017cd:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8017d0:	89 d3                	mov    %edx,%ebx
  8017d2:	c1 e3 08             	shl    $0x8,%ebx
  8017d5:	89 d6                	mov    %edx,%esi
  8017d7:	c1 e6 18             	shl    $0x18,%esi
  8017da:	89 d0                	mov    %edx,%eax
  8017dc:	c1 e0 10             	shl    $0x10,%eax
  8017df:	09 f0                	or     %esi,%eax
  8017e1:	09 d0                	or     %edx,%eax
  8017e3:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  8017e5:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  8017e8:	fc                   	cld    
  8017e9:	f3 ab                	rep stos %eax,%es:(%edi)
  8017eb:	eb 03                	jmp    8017f0 <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8017ed:	fc                   	cld    
  8017ee:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8017f0:	89 f8                	mov    %edi,%eax
  8017f2:	5b                   	pop    %ebx
  8017f3:	5e                   	pop    %esi
  8017f4:	5f                   	pop    %edi
  8017f5:	c9                   	leave  
  8017f6:	c3                   	ret    

008017f7 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8017f7:	55                   	push   %ebp
  8017f8:	89 e5                	mov    %esp,%ebp
  8017fa:	57                   	push   %edi
  8017fb:	56                   	push   %esi
  8017fc:	8b 45 08             	mov    0x8(%ebp),%eax
  8017ff:	8b 75 0c             	mov    0xc(%ebp),%esi
  801802:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  801805:	39 c6                	cmp    %eax,%esi
  801807:	73 34                	jae    80183d <memmove+0x46>
  801809:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  80180c:	39 d0                	cmp    %edx,%eax
  80180e:	73 2d                	jae    80183d <memmove+0x46>
		s += n;
		d += n;
  801810:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801813:	f6 c2 03             	test   $0x3,%dl
  801816:	75 1b                	jne    801833 <memmove+0x3c>
  801818:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80181e:	75 13                	jne    801833 <memmove+0x3c>
  801820:	f6 c1 03             	test   $0x3,%cl
  801823:	75 0e                	jne    801833 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  801825:	83 ef 04             	sub    $0x4,%edi
  801828:	8d 72 fc             	lea    -0x4(%edx),%esi
  80182b:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  80182e:	fd                   	std    
  80182f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801831:	eb 07                	jmp    80183a <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  801833:	4f                   	dec    %edi
  801834:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  801837:	fd                   	std    
  801838:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  80183a:	fc                   	cld    
  80183b:	eb 20                	jmp    80185d <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80183d:	f7 c6 03 00 00 00    	test   $0x3,%esi
  801843:	75 13                	jne    801858 <memmove+0x61>
  801845:	a8 03                	test   $0x3,%al
  801847:	75 0f                	jne    801858 <memmove+0x61>
  801849:	f6 c1 03             	test   $0x3,%cl
  80184c:	75 0a                	jne    801858 <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  80184e:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  801851:	89 c7                	mov    %eax,%edi
  801853:	fc                   	cld    
  801854:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801856:	eb 05                	jmp    80185d <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  801858:	89 c7                	mov    %eax,%edi
  80185a:	fc                   	cld    
  80185b:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  80185d:	5e                   	pop    %esi
  80185e:	5f                   	pop    %edi
  80185f:	c9                   	leave  
  801860:	c3                   	ret    

00801861 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  801861:	55                   	push   %ebp
  801862:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  801864:	ff 75 10             	pushl  0x10(%ebp)
  801867:	ff 75 0c             	pushl  0xc(%ebp)
  80186a:	ff 75 08             	pushl  0x8(%ebp)
  80186d:	e8 85 ff ff ff       	call   8017f7 <memmove>
}
  801872:	c9                   	leave  
  801873:	c3                   	ret    

00801874 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  801874:	55                   	push   %ebp
  801875:	89 e5                	mov    %esp,%ebp
  801877:	57                   	push   %edi
  801878:	56                   	push   %esi
  801879:	53                   	push   %ebx
  80187a:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80187d:	8b 75 0c             	mov    0xc(%ebp),%esi
  801880:	8b 7d 10             	mov    0x10(%ebp),%edi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801883:	85 ff                	test   %edi,%edi
  801885:	74 32                	je     8018b9 <memcmp+0x45>
		if (*s1 != *s2)
  801887:	8a 03                	mov    (%ebx),%al
  801889:	8a 0e                	mov    (%esi),%cl
  80188b:	38 c8                	cmp    %cl,%al
  80188d:	74 19                	je     8018a8 <memcmp+0x34>
  80188f:	eb 0d                	jmp    80189e <memcmp+0x2a>
  801891:	8a 44 13 01          	mov    0x1(%ebx,%edx,1),%al
  801895:	8a 4c 16 01          	mov    0x1(%esi,%edx,1),%cl
  801899:	42                   	inc    %edx
  80189a:	38 c8                	cmp    %cl,%al
  80189c:	74 10                	je     8018ae <memcmp+0x3a>
			return (int) *s1 - (int) *s2;
  80189e:	0f b6 c0             	movzbl %al,%eax
  8018a1:	0f b6 c9             	movzbl %cl,%ecx
  8018a4:	29 c8                	sub    %ecx,%eax
  8018a6:	eb 16                	jmp    8018be <memcmp+0x4a>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8018a8:	4f                   	dec    %edi
  8018a9:	ba 00 00 00 00       	mov    $0x0,%edx
  8018ae:	39 fa                	cmp    %edi,%edx
  8018b0:	75 df                	jne    801891 <memcmp+0x1d>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  8018b2:	b8 00 00 00 00       	mov    $0x0,%eax
  8018b7:	eb 05                	jmp    8018be <memcmp+0x4a>
  8018b9:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8018be:	5b                   	pop    %ebx
  8018bf:	5e                   	pop    %esi
  8018c0:	5f                   	pop    %edi
  8018c1:	c9                   	leave  
  8018c2:	c3                   	ret    

008018c3 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8018c3:	55                   	push   %ebp
  8018c4:	89 e5                	mov    %esp,%ebp
  8018c6:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  8018c9:	89 c2                	mov    %eax,%edx
  8018cb:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  8018ce:	39 d0                	cmp    %edx,%eax
  8018d0:	73 12                	jae    8018e4 <memfind+0x21>
		if (*(const unsigned char *) s == (unsigned char) c)
  8018d2:	8a 4d 0c             	mov    0xc(%ebp),%cl
  8018d5:	38 08                	cmp    %cl,(%eax)
  8018d7:	75 06                	jne    8018df <memfind+0x1c>
  8018d9:	eb 09                	jmp    8018e4 <memfind+0x21>
  8018db:	38 08                	cmp    %cl,(%eax)
  8018dd:	74 05                	je     8018e4 <memfind+0x21>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8018df:	40                   	inc    %eax
  8018e0:	39 c2                	cmp    %eax,%edx
  8018e2:	77 f7                	ja     8018db <memfind+0x18>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  8018e4:	c9                   	leave  
  8018e5:	c3                   	ret    

008018e6 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  8018e6:	55                   	push   %ebp
  8018e7:	89 e5                	mov    %esp,%ebp
  8018e9:	57                   	push   %edi
  8018ea:	56                   	push   %esi
  8018eb:	53                   	push   %ebx
  8018ec:	8b 55 08             	mov    0x8(%ebp),%edx
  8018ef:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8018f2:	eb 01                	jmp    8018f5 <strtol+0xf>
		s++;
  8018f4:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8018f5:	8a 02                	mov    (%edx),%al
  8018f7:	3c 20                	cmp    $0x20,%al
  8018f9:	74 f9                	je     8018f4 <strtol+0xe>
  8018fb:	3c 09                	cmp    $0x9,%al
  8018fd:	74 f5                	je     8018f4 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  8018ff:	3c 2b                	cmp    $0x2b,%al
  801901:	75 08                	jne    80190b <strtol+0x25>
		s++;
  801903:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  801904:	bf 00 00 00 00       	mov    $0x0,%edi
  801909:	eb 13                	jmp    80191e <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  80190b:	3c 2d                	cmp    $0x2d,%al
  80190d:	75 0a                	jne    801919 <strtol+0x33>
		s++, neg = 1;
  80190f:	8d 52 01             	lea    0x1(%edx),%edx
  801912:	bf 01 00 00 00       	mov    $0x1,%edi
  801917:	eb 05                	jmp    80191e <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  801919:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  80191e:	85 db                	test   %ebx,%ebx
  801920:	74 05                	je     801927 <strtol+0x41>
  801922:	83 fb 10             	cmp    $0x10,%ebx
  801925:	75 28                	jne    80194f <strtol+0x69>
  801927:	8a 02                	mov    (%edx),%al
  801929:	3c 30                	cmp    $0x30,%al
  80192b:	75 10                	jne    80193d <strtol+0x57>
  80192d:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  801931:	75 0a                	jne    80193d <strtol+0x57>
		s += 2, base = 16;
  801933:	83 c2 02             	add    $0x2,%edx
  801936:	bb 10 00 00 00       	mov    $0x10,%ebx
  80193b:	eb 12                	jmp    80194f <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  80193d:	85 db                	test   %ebx,%ebx
  80193f:	75 0e                	jne    80194f <strtol+0x69>
  801941:	3c 30                	cmp    $0x30,%al
  801943:	75 05                	jne    80194a <strtol+0x64>
		s++, base = 8;
  801945:	42                   	inc    %edx
  801946:	b3 08                	mov    $0x8,%bl
  801948:	eb 05                	jmp    80194f <strtol+0x69>
	else if (base == 0)
		base = 10;
  80194a:	bb 0a 00 00 00       	mov    $0xa,%ebx
  80194f:	b8 00 00 00 00       	mov    $0x0,%eax
  801954:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  801956:	8a 0a                	mov    (%edx),%cl
  801958:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  80195b:	80 fb 09             	cmp    $0x9,%bl
  80195e:	77 08                	ja     801968 <strtol+0x82>
			dig = *s - '0';
  801960:	0f be c9             	movsbl %cl,%ecx
  801963:	83 e9 30             	sub    $0x30,%ecx
  801966:	eb 1e                	jmp    801986 <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  801968:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  80196b:	80 fb 19             	cmp    $0x19,%bl
  80196e:	77 08                	ja     801978 <strtol+0x92>
			dig = *s - 'a' + 10;
  801970:	0f be c9             	movsbl %cl,%ecx
  801973:	83 e9 57             	sub    $0x57,%ecx
  801976:	eb 0e                	jmp    801986 <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  801978:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  80197b:	80 fb 19             	cmp    $0x19,%bl
  80197e:	77 13                	ja     801993 <strtol+0xad>
			dig = *s - 'A' + 10;
  801980:	0f be c9             	movsbl %cl,%ecx
  801983:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  801986:	39 f1                	cmp    %esi,%ecx
  801988:	7d 0d                	jge    801997 <strtol+0xb1>
			break;
		s++, val = (val * base) + dig;
  80198a:	42                   	inc    %edx
  80198b:	0f af c6             	imul   %esi,%eax
  80198e:	8d 04 01             	lea    (%ecx,%eax,1),%eax
		// we don't properly detect overflow!
	}
  801991:	eb c3                	jmp    801956 <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  801993:	89 c1                	mov    %eax,%ecx
  801995:	eb 02                	jmp    801999 <strtol+0xb3>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  801997:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  801999:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  80199d:	74 05                	je     8019a4 <strtol+0xbe>
		*endptr = (char *) s;
  80199f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8019a2:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  8019a4:	85 ff                	test   %edi,%edi
  8019a6:	74 04                	je     8019ac <strtol+0xc6>
  8019a8:	89 c8                	mov    %ecx,%eax
  8019aa:	f7 d8                	neg    %eax
}
  8019ac:	5b                   	pop    %ebx
  8019ad:	5e                   	pop    %esi
  8019ae:	5f                   	pop    %edi
  8019af:	c9                   	leave  
  8019b0:	c3                   	ret    
  8019b1:	00 00                	add    %al,(%eax)
	...

008019b4 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8019b4:	55                   	push   %ebp
  8019b5:	89 e5                	mov    %esp,%ebp
  8019b7:	56                   	push   %esi
  8019b8:	53                   	push   %ebx
  8019b9:	8b 75 08             	mov    0x8(%ebp),%esi
  8019bc:	8b 45 0c             	mov    0xc(%ebp),%eax
  8019bf:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// cprintf("0x%x 0x%x 0x%x\n", (uint32_t)from_env_store, (uint32_t)pg, (uint32_t)perm_store);
	int r;
	if (pg != NULL) {
  8019c2:	85 c0                	test   %eax,%eax
  8019c4:	74 0e                	je     8019d4 <ipc_recv+0x20>
		r = sys_ipc_recv(pg);
  8019c6:	83 ec 0c             	sub    $0xc,%esp
  8019c9:	50                   	push   %eax
  8019ca:	e8 e0 e8 ff ff       	call   8002af <sys_ipc_recv>
  8019cf:	83 c4 10             	add    $0x10,%esp
  8019d2:	eb 10                	jmp    8019e4 <ipc_recv+0x30>
	} else {
		r = sys_ipc_recv((void *)UTOP);
  8019d4:	83 ec 0c             	sub    $0xc,%esp
  8019d7:	68 00 00 c0 ee       	push   $0xeec00000
  8019dc:	e8 ce e8 ff ff       	call   8002af <sys_ipc_recv>
  8019e1:	83 c4 10             	add    $0x10,%esp
	}

	if (r == 0) {
  8019e4:	85 c0                	test   %eax,%eax
  8019e6:	75 26                	jne    801a0e <ipc_recv+0x5a>
		if (from_env_store != NULL) *from_env_store = thisenv->env_ipc_from;
  8019e8:	85 f6                	test   %esi,%esi
  8019ea:	74 0a                	je     8019f6 <ipc_recv+0x42>
  8019ec:	a1 04 40 80 00       	mov    0x804004,%eax
  8019f1:	8b 40 74             	mov    0x74(%eax),%eax
  8019f4:	89 06                	mov    %eax,(%esi)
		if (perm_store != NULL) *perm_store = thisenv->env_ipc_perm;
  8019f6:	85 db                	test   %ebx,%ebx
  8019f8:	74 0a                	je     801a04 <ipc_recv+0x50>
  8019fa:	a1 04 40 80 00       	mov    0x804004,%eax
  8019ff:	8b 40 78             	mov    0x78(%eax),%eax
  801a02:	89 03                	mov    %eax,(%ebx)
		return thisenv->env_ipc_value;
  801a04:	a1 04 40 80 00       	mov    0x804004,%eax
  801a09:	8b 40 70             	mov    0x70(%eax),%eax
  801a0c:	eb 14                	jmp    801a22 <ipc_recv+0x6e>
	} else {
		// fails;
		if (from_env_store != NULL) *from_env_store = 0;
  801a0e:	85 f6                	test   %esi,%esi
  801a10:	74 06                	je     801a18 <ipc_recv+0x64>
  801a12:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		if (perm_store != NULL) *perm_store = 0;
  801a18:	85 db                	test   %ebx,%ebx
  801a1a:	74 06                	je     801a22 <ipc_recv+0x6e>
  801a1c:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
		return r;
	}
}
  801a22:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a25:	5b                   	pop    %ebx
  801a26:	5e                   	pop    %esi
  801a27:	c9                   	leave  
  801a28:	c3                   	ret    

00801a29 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801a29:	55                   	push   %ebp
  801a2a:	89 e5                	mov    %esp,%ebp
  801a2c:	57                   	push   %edi
  801a2d:	56                   	push   %esi
  801a2e:	53                   	push   %ebx
  801a2f:	83 ec 0c             	sub    $0xc,%esp
  801a32:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801a35:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801a38:	8b 75 14             	mov    0x14(%ebp),%esi
	// LAB 4: Your code here.
	// int sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
	int r;
	if (pg == NULL) pg = (void *)UTOP;
  801a3b:	85 db                	test   %ebx,%ebx
  801a3d:	75 25                	jne    801a64 <ipc_send+0x3b>
  801a3f:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
  801a44:	eb 1e                	jmp    801a64 <ipc_send+0x3b>
	
	while ((r = sys_ipc_try_send(to_env, val, pg, perm)) != 0) {
		if (r == -E_IPC_NOT_RECV) {
  801a46:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801a49:	75 07                	jne    801a52 <ipc_send+0x29>
			// cprintf("Try Again and Again....\n");
			sys_yield();
  801a4b:	e8 3d e7 ff ff       	call   80018d <sys_yield>
  801a50:	eb 12                	jmp    801a64 <ipc_send+0x3b>
		} else {
			panic("ipc_send error %e\n", r);
  801a52:	50                   	push   %eax
  801a53:	68 c0 21 80 00       	push   $0x8021c0
  801a58:	6a 43                	push   $0x43
  801a5a:	68 d3 21 80 00       	push   $0x8021d3
  801a5f:	e8 44 f5 ff ff       	call   800fa8 <_panic>
	// LAB 4: Your code here.
	// int sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
	int r;
	if (pg == NULL) pg = (void *)UTOP;
	
	while ((r = sys_ipc_try_send(to_env, val, pg, perm)) != 0) {
  801a64:	56                   	push   %esi
  801a65:	53                   	push   %ebx
  801a66:	57                   	push   %edi
  801a67:	ff 75 08             	pushl  0x8(%ebp)
  801a6a:	e8 1b e8 ff ff       	call   80028a <sys_ipc_try_send>
  801a6f:	83 c4 10             	add    $0x10,%esp
  801a72:	85 c0                	test   %eax,%eax
  801a74:	75 d0                	jne    801a46 <ipc_send+0x1d>
		} else {
			panic("ipc_send error %e\n", r);
		}
	}
	return;
}
  801a76:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801a79:	5b                   	pop    %ebx
  801a7a:	5e                   	pop    %esi
  801a7b:	5f                   	pop    %edi
  801a7c:	c9                   	leave  
  801a7d:	c3                   	ret    

00801a7e <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801a7e:	55                   	push   %ebp
  801a7f:	89 e5                	mov    %esp,%ebp
  801a81:	53                   	push   %ebx
  801a82:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	for (i = 0; i < NENV; i++)
		if (envs[i].env_type == type)
  801a85:	39 1d 50 00 c0 ee    	cmp    %ebx,0xeec00050
  801a8b:	74 22                	je     801aaf <ipc_find_env+0x31>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801a8d:	b8 01 00 00 00       	mov    $0x1,%eax
		if (envs[i].env_type == type)
  801a92:	8d 0c 85 00 00 00 00 	lea    0x0(,%eax,4),%ecx
  801a99:	89 c2                	mov    %eax,%edx
  801a9b:	c1 e2 07             	shl    $0x7,%edx
  801a9e:	29 ca                	sub    %ecx,%edx
  801aa0:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801aa6:	8b 52 50             	mov    0x50(%edx),%edx
  801aa9:	39 da                	cmp    %ebx,%edx
  801aab:	75 1d                	jne    801aca <ipc_find_env+0x4c>
  801aad:	eb 05                	jmp    801ab4 <ipc_find_env+0x36>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801aaf:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
			return envs[i].env_id;
  801ab4:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  801abb:	c1 e0 07             	shl    $0x7,%eax
  801abe:	29 d0                	sub    %edx,%eax
  801ac0:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  801ac5:	8b 40 40             	mov    0x40(%eax),%eax
  801ac8:	eb 0c                	jmp    801ad6 <ipc_find_env+0x58>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801aca:	40                   	inc    %eax
  801acb:	3d 00 04 00 00       	cmp    $0x400,%eax
  801ad0:	75 c0                	jne    801a92 <ipc_find_env+0x14>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801ad2:	66 b8 00 00          	mov    $0x0,%ax
}
  801ad6:	5b                   	pop    %ebx
  801ad7:	c9                   	leave  
  801ad8:	c3                   	ret    
  801ad9:	00 00                	add    %al,(%eax)
	...

00801adc <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801adc:	55                   	push   %ebp
  801add:	89 e5                	mov    %esp,%ebp
  801adf:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801ae2:	89 c2                	mov    %eax,%edx
  801ae4:	c1 ea 16             	shr    $0x16,%edx
  801ae7:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801aee:	f6 c2 01             	test   $0x1,%dl
  801af1:	74 1e                	je     801b11 <pageref+0x35>
		return 0;
	pte = uvpt[PGNUM(v)];
  801af3:	c1 e8 0c             	shr    $0xc,%eax
  801af6:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  801afd:	a8 01                	test   $0x1,%al
  801aff:	74 17                	je     801b18 <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801b01:	c1 e8 0c             	shr    $0xc,%eax
  801b04:	66 8b 04 c5 04 00 00 	mov    -0x10fffffc(,%eax,8),%ax
  801b0b:	ef 
  801b0c:	0f b7 c0             	movzwl %ax,%eax
  801b0f:	eb 0c                	jmp    801b1d <pageref+0x41>
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
		return 0;
  801b11:	b8 00 00 00 00       	mov    $0x0,%eax
  801b16:	eb 05                	jmp    801b1d <pageref+0x41>
	pte = uvpt[PGNUM(v)];
	if (!(pte & PTE_P))
		return 0;
  801b18:	b8 00 00 00 00       	mov    $0x0,%eax
	return pages[PGNUM(pte)].pp_ref;
}
  801b1d:	c9                   	leave  
  801b1e:	c3                   	ret    
	...

00801b20 <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  801b20:	55                   	push   %ebp
  801b21:	89 e5                	mov    %esp,%ebp
  801b23:	57                   	push   %edi
  801b24:	56                   	push   %esi
  801b25:	83 ec 10             	sub    $0x10,%esp
  801b28:	8b 7d 08             	mov    0x8(%ebp),%edi
  801b2b:	8b 4d 10             	mov    0x10(%ebp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  801b2e:	89 7d f0             	mov    %edi,-0x10(%ebp)
  801b31:	8b 75 0c             	mov    0xc(%ebp),%esi
  const DWunion dd = {.ll = d};
  801b34:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  801b37:	8b 45 14             	mov    0x14(%ebp),%eax
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  801b3a:	85 c0                	test   %eax,%eax
  801b3c:	75 2e                	jne    801b6c <__udivdi3+0x4c>
    {
      if (d0 > n1)
  801b3e:	39 f1                	cmp    %esi,%ecx
  801b40:	77 5a                	ja     801b9c <__udivdi3+0x7c>
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  801b42:	85 c9                	test   %ecx,%ecx
  801b44:	75 0b                	jne    801b51 <__udivdi3+0x31>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  801b46:	b8 01 00 00 00       	mov    $0x1,%eax
  801b4b:	31 d2                	xor    %edx,%edx
  801b4d:	f7 f1                	div    %ecx
  801b4f:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  801b51:	31 d2                	xor    %edx,%edx
  801b53:	89 f0                	mov    %esi,%eax
  801b55:	f7 f1                	div    %ecx
  801b57:	89 c6                	mov    %eax,%esi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801b59:	89 f8                	mov    %edi,%eax
  801b5b:	f7 f1                	div    %ecx
  801b5d:	89 c7                	mov    %eax,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  801b5f:	89 f8                	mov    %edi,%eax
  801b61:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801b63:	83 c4 10             	add    $0x10,%esp
  801b66:	5e                   	pop    %esi
  801b67:	5f                   	pop    %edi
  801b68:	c9                   	leave  
  801b69:	c3                   	ret    
  801b6a:	66 90                	xchg   %ax,%ax
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  801b6c:	39 f0                	cmp    %esi,%eax
  801b6e:	77 1c                	ja     801b8c <__udivdi3+0x6c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  801b70:	0f bd f8             	bsr    %eax,%edi
	  if (bm == 0)
  801b73:	83 f7 1f             	xor    $0x1f,%edi
  801b76:	75 3c                	jne    801bb4 <__udivdi3+0x94>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  801b78:	39 f0                	cmp    %esi,%eax
  801b7a:	0f 82 90 00 00 00    	jb     801c10 <__udivdi3+0xf0>
  801b80:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801b83:	39 55 f4             	cmp    %edx,-0xc(%ebp)
  801b86:	0f 86 84 00 00 00    	jbe    801c10 <__udivdi3+0xf0>
  801b8c:	31 f6                	xor    %esi,%esi
  801b8e:	31 ff                	xor    %edi,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  801b90:	89 f8                	mov    %edi,%eax
  801b92:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801b94:	83 c4 10             	add    $0x10,%esp
  801b97:	5e                   	pop    %esi
  801b98:	5f                   	pop    %edi
  801b99:	c9                   	leave  
  801b9a:	c3                   	ret    
  801b9b:	90                   	nop
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801b9c:	89 f2                	mov    %esi,%edx
  801b9e:	89 f8                	mov    %edi,%eax
  801ba0:	f7 f1                	div    %ecx
  801ba2:	89 c7                	mov    %eax,%edi
  801ba4:	31 f6                	xor    %esi,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  801ba6:	89 f8                	mov    %edi,%eax
  801ba8:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801baa:	83 c4 10             	add    $0x10,%esp
  801bad:	5e                   	pop    %esi
  801bae:	5f                   	pop    %edi
  801baf:	c9                   	leave  
  801bb0:	c3                   	ret    
  801bb1:	8d 76 00             	lea    0x0(%esi),%esi
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  801bb4:	89 f9                	mov    %edi,%ecx
  801bb6:	d3 e0                	shl    %cl,%eax
  801bb8:	89 45 e8             	mov    %eax,-0x18(%ebp)
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  801bbb:	b8 20 00 00 00       	mov    $0x20,%eax
  801bc0:	29 f8                	sub    %edi,%eax

	      d1 = (d1 << bm) | (d0 >> b);
  801bc2:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801bc5:	88 c1                	mov    %al,%cl
  801bc7:	d3 ea                	shr    %cl,%edx
  801bc9:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  801bcc:	09 ca                	or     %ecx,%edx
  801bce:	89 55 ec             	mov    %edx,-0x14(%ebp)
	      d0 = d0 << bm;
  801bd1:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801bd4:	89 f9                	mov    %edi,%ecx
  801bd6:	d3 e2                	shl    %cl,%edx
  801bd8:	89 55 f4             	mov    %edx,-0xc(%ebp)
	      n2 = n1 >> b;
  801bdb:	89 f2                	mov    %esi,%edx
  801bdd:	88 c1                	mov    %al,%cl
  801bdf:	d3 ea                	shr    %cl,%edx
  801be1:	89 55 e8             	mov    %edx,-0x18(%ebp)
	      n1 = (n1 << bm) | (n0 >> b);
  801be4:	89 f2                	mov    %esi,%edx
  801be6:	89 f9                	mov    %edi,%ecx
  801be8:	d3 e2                	shl    %cl,%edx
  801bea:	8b 75 f0             	mov    -0x10(%ebp),%esi
  801bed:	88 c1                	mov    %al,%cl
  801bef:	d3 ee                	shr    %cl,%esi
  801bf1:	09 d6                	or     %edx,%esi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  801bf3:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  801bf6:	89 f0                	mov    %esi,%eax
  801bf8:	89 ca                	mov    %ecx,%edx
  801bfa:	f7 75 ec             	divl   -0x14(%ebp)
  801bfd:	89 d1                	mov    %edx,%ecx
  801bff:	89 c6                	mov    %eax,%esi
	      umul_ppmm (m1, m0, q0, d0);
  801c01:	f7 65 f4             	mull   -0xc(%ebp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801c04:	39 d1                	cmp    %edx,%ecx
  801c06:	72 28                	jb     801c30 <__udivdi3+0x110>
  801c08:	74 1a                	je     801c24 <__udivdi3+0x104>
  801c0a:	89 f7                	mov    %esi,%edi
  801c0c:	31 f6                	xor    %esi,%esi
  801c0e:	eb 80                	jmp    801b90 <__udivdi3+0x70>
	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  801c10:	31 f6                	xor    %esi,%esi
  801c12:	bf 01 00 00 00       	mov    $0x1,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  801c17:	89 f8                	mov    %edi,%eax
  801c19:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801c1b:	83 c4 10             	add    $0x10,%esp
  801c1e:	5e                   	pop    %esi
  801c1f:	5f                   	pop    %edi
  801c20:	c9                   	leave  
  801c21:	c3                   	ret    
  801c22:	66 90                	xchg   %ax,%ax

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  801c24:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801c27:	89 f9                	mov    %edi,%ecx
  801c29:	d3 e2                	shl    %cl,%edx

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801c2b:	39 c2                	cmp    %eax,%edx
  801c2d:	73 db                	jae    801c0a <__udivdi3+0xea>
  801c2f:	90                   	nop
		{
		  q0--;
  801c30:	8d 7e ff             	lea    -0x1(%esi),%edi
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  801c33:	31 f6                	xor    %esi,%esi
  801c35:	e9 56 ff ff ff       	jmp    801b90 <__udivdi3+0x70>
	...

00801c3c <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  801c3c:	55                   	push   %ebp
  801c3d:	89 e5                	mov    %esp,%ebp
  801c3f:	57                   	push   %edi
  801c40:	56                   	push   %esi
  801c41:	83 ec 20             	sub    $0x20,%esp
  801c44:	8b 45 08             	mov    0x8(%ebp),%eax
  801c47:	8b 4d 10             	mov    0x10(%ebp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  801c4a:	89 45 e8             	mov    %eax,-0x18(%ebp)
  801c4d:	8b 75 0c             	mov    0xc(%ebp),%esi
  const DWunion dd = {.ll = d};
  801c50:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  801c53:	8b 7d 14             	mov    0x14(%ebp),%edi
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  801c56:	89 45 f0             	mov    %eax,-0x10(%ebp)
  n1 = nn.s.high;
  801c59:	89 f2                	mov    %esi,%edx

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  801c5b:	85 ff                	test   %edi,%edi
  801c5d:	75 15                	jne    801c74 <__umoddi3+0x38>
    {
      if (d0 > n1)
  801c5f:	39 f1                	cmp    %esi,%ecx
  801c61:	0f 86 99 00 00 00    	jbe    801d00 <__umoddi3+0xc4>
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801c67:	f7 f1                	div    %ecx

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
  801c69:	89 d0                	mov    %edx,%eax
  801c6b:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  801c6d:	83 c4 20             	add    $0x20,%esp
  801c70:	5e                   	pop    %esi
  801c71:	5f                   	pop    %edi
  801c72:	c9                   	leave  
  801c73:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  801c74:	39 f7                	cmp    %esi,%edi
  801c76:	0f 87 a4 00 00 00    	ja     801d20 <__umoddi3+0xe4>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  801c7c:	0f bd c7             	bsr    %edi,%eax
	  if (bm == 0)
  801c7f:	83 f0 1f             	xor    $0x1f,%eax
  801c82:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801c85:	0f 84 a1 00 00 00    	je     801d2c <__umoddi3+0xf0>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  801c8b:	89 f8                	mov    %edi,%eax
  801c8d:	8a 4d ec             	mov    -0x14(%ebp),%cl
  801c90:	d3 e0                	shl    %cl,%eax
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  801c92:	bf 20 00 00 00       	mov    $0x20,%edi
  801c97:	2b 7d ec             	sub    -0x14(%ebp),%edi

	      d1 = (d1 << bm) | (d0 >> b);
  801c9a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801c9d:	89 f9                	mov    %edi,%ecx
  801c9f:	d3 ea                	shr    %cl,%edx
  801ca1:	09 c2                	or     %eax,%edx
  801ca3:	89 55 f0             	mov    %edx,-0x10(%ebp)
	      d0 = d0 << bm;
  801ca6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ca9:	8a 4d ec             	mov    -0x14(%ebp),%cl
  801cac:	d3 e0                	shl    %cl,%eax
  801cae:	89 45 f4             	mov    %eax,-0xc(%ebp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  801cb1:	89 f2                	mov    %esi,%edx
  801cb3:	d3 e2                	shl    %cl,%edx
	      n0 = n0 << bm;
  801cb5:	8b 45 e8             	mov    -0x18(%ebp),%eax
  801cb8:	d3 e0                	shl    %cl,%eax
  801cba:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  801cbd:	8b 45 e8             	mov    -0x18(%ebp),%eax
  801cc0:	89 f9                	mov    %edi,%ecx
  801cc2:	d3 e8                	shr    %cl,%eax
  801cc4:	09 d0                	or     %edx,%eax

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  801cc6:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  801cc8:	89 f2                	mov    %esi,%edx
  801cca:	f7 75 f0             	divl   -0x10(%ebp)
  801ccd:	89 d6                	mov    %edx,%esi
	      umul_ppmm (m1, m0, q0, d0);
  801ccf:	f7 65 f4             	mull   -0xc(%ebp)
  801cd2:	89 55 e8             	mov    %edx,-0x18(%ebp)
  801cd5:	89 c1                	mov    %eax,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801cd7:	39 d6                	cmp    %edx,%esi
  801cd9:	72 71                	jb     801d4c <__umoddi3+0x110>
  801cdb:	74 7f                	je     801d5c <__umoddi3+0x120>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  801cdd:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801ce0:	29 c8                	sub    %ecx,%eax
  801ce2:	19 d6                	sbb    %edx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
  801ce4:	8a 4d ec             	mov    -0x14(%ebp),%cl
  801ce7:	d3 e8                	shr    %cl,%eax
  801ce9:	89 f2                	mov    %esi,%edx
  801ceb:	89 f9                	mov    %edi,%ecx
  801ced:	d3 e2                	shl    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
  801cef:	09 d0                	or     %edx,%eax
  801cf1:	89 f2                	mov    %esi,%edx
  801cf3:	8a 4d ec             	mov    -0x14(%ebp),%cl
  801cf6:	d3 ea                	shr    %cl,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  801cf8:	83 c4 20             	add    $0x20,%esp
  801cfb:	5e                   	pop    %esi
  801cfc:	5f                   	pop    %edi
  801cfd:	c9                   	leave  
  801cfe:	c3                   	ret    
  801cff:	90                   	nop
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  801d00:	85 c9                	test   %ecx,%ecx
  801d02:	75 0b                	jne    801d0f <__umoddi3+0xd3>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  801d04:	b8 01 00 00 00       	mov    $0x1,%eax
  801d09:	31 d2                	xor    %edx,%edx
  801d0b:	f7 f1                	div    %ecx
  801d0d:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  801d0f:	89 f0                	mov    %esi,%eax
  801d11:	31 d2                	xor    %edx,%edx
  801d13:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801d15:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801d18:	f7 f1                	div    %ecx
  801d1a:	e9 4a ff ff ff       	jmp    801c69 <__umoddi3+0x2d>
  801d1f:	90                   	nop
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
  801d20:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  801d22:	83 c4 20             	add    $0x20,%esp
  801d25:	5e                   	pop    %esi
  801d26:	5f                   	pop    %edi
  801d27:	c9                   	leave  
  801d28:	c3                   	ret    
  801d29:	8d 76 00             	lea    0x0(%esi),%esi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  801d2c:	39 f7                	cmp    %esi,%edi
  801d2e:	72 05                	jb     801d35 <__umoddi3+0xf9>
  801d30:	3b 4d f0             	cmp    -0x10(%ebp),%ecx
  801d33:	77 0c                	ja     801d41 <__umoddi3+0x105>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  801d35:	89 f2                	mov    %esi,%edx
  801d37:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801d3a:	29 c8                	sub    %ecx,%eax
  801d3c:	19 fa                	sbb    %edi,%edx
  801d3e:	89 45 f0             	mov    %eax,-0x10(%ebp)

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
  801d41:	8b 45 f0             	mov    -0x10(%ebp),%eax
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
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  801d4c:	8b 55 e8             	mov    -0x18(%ebp),%edx
  801d4f:	89 c1                	mov    %eax,%ecx
  801d51:	2b 4d f4             	sub    -0xc(%ebp),%ecx
  801d54:	1b 55 f0             	sbb    -0x10(%ebp),%edx
  801d57:	eb 84                	jmp    801cdd <__umoddi3+0xa1>
  801d59:	8d 76 00             	lea    0x0(%esi),%esi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801d5c:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  801d5f:	72 eb                	jb     801d4c <__umoddi3+0x110>
  801d61:	89 f2                	mov    %esi,%edx
  801d63:	e9 75 ff ff ff       	jmp    801cdd <__umoddi3+0xa1>
