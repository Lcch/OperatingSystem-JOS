
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
  80009a:	e8 87 04 00 00       	call   800526 <close_all>
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
  8000e2:	68 aa 1d 80 00       	push   $0x801daa
  8000e7:	6a 42                	push   $0x42
  8000e9:	68 c7 1d 80 00       	push   $0x801dc7
  8000ee:	e8 dd 0e 00 00       	call   800fd0 <_panic>

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

008002f4 <sys_exec>:

int
sys_exec(uint32_t eip, uint32_t esp, void * ph, uint32_t elf_phnum)
{
  8002f4:	55                   	push   %ebp
  8002f5:	89 e5                	mov    %esp,%ebp
  8002f7:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_exec, 0, eip, esp, (uint32_t)ph, elf_phnum, 0);
  8002fa:	6a 00                	push   $0x0
  8002fc:	ff 75 14             	pushl  0x14(%ebp)
  8002ff:	ff 75 10             	pushl  0x10(%ebp)
  800302:	ff 75 0c             	pushl  0xc(%ebp)
  800305:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800308:	ba 00 00 00 00       	mov    $0x0,%edx
  80030d:	b8 0f 00 00 00       	mov    $0xf,%eax
  800312:	e8 99 fd ff ff       	call   8000b0 <syscall>
  800317:	c9                   	leave  
  800318:	c3                   	ret    
  800319:	00 00                	add    %al,(%eax)
	...

0080031c <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  80031c:	55                   	push   %ebp
  80031d:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80031f:	8b 45 08             	mov    0x8(%ebp),%eax
  800322:	05 00 00 00 30       	add    $0x30000000,%eax
  800327:	c1 e8 0c             	shr    $0xc,%eax
}
  80032a:	c9                   	leave  
  80032b:	c3                   	ret    

0080032c <fd2data>:

char*
fd2data(struct Fd *fd)
{
  80032c:	55                   	push   %ebp
  80032d:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  80032f:	ff 75 08             	pushl  0x8(%ebp)
  800332:	e8 e5 ff ff ff       	call   80031c <fd2num>
  800337:	83 c4 04             	add    $0x4,%esp
  80033a:	05 20 00 0d 00       	add    $0xd0020,%eax
  80033f:	c1 e0 0c             	shl    $0xc,%eax
}
  800342:	c9                   	leave  
  800343:	c3                   	ret    

00800344 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800344:	55                   	push   %ebp
  800345:	89 e5                	mov    %esp,%ebp
  800347:	53                   	push   %ebx
  800348:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  80034b:	a1 00 dd 7b ef       	mov    0xef7bdd00,%eax
  800350:	a8 01                	test   $0x1,%al
  800352:	74 34                	je     800388 <fd_alloc+0x44>
  800354:	a1 00 00 74 ef       	mov    0xef740000,%eax
  800359:	a8 01                	test   $0x1,%al
  80035b:	74 32                	je     80038f <fd_alloc+0x4b>
  80035d:	b8 00 10 00 d0       	mov    $0xd0001000,%eax
  800362:	89 c1                	mov    %eax,%ecx
  800364:	89 c2                	mov    %eax,%edx
  800366:	c1 ea 16             	shr    $0x16,%edx
  800369:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800370:	f6 c2 01             	test   $0x1,%dl
  800373:	74 1f                	je     800394 <fd_alloc+0x50>
  800375:	89 c2                	mov    %eax,%edx
  800377:	c1 ea 0c             	shr    $0xc,%edx
  80037a:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800381:	f6 c2 01             	test   $0x1,%dl
  800384:	75 17                	jne    80039d <fd_alloc+0x59>
  800386:	eb 0c                	jmp    800394 <fd_alloc+0x50>
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  800388:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
  80038d:	eb 05                	jmp    800394 <fd_alloc+0x50>
  80038f:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
  800394:	89 0b                	mov    %ecx,(%ebx)
			return 0;
  800396:	b8 00 00 00 00       	mov    $0x0,%eax
  80039b:	eb 17                	jmp    8003b4 <fd_alloc+0x70>
  80039d:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8003a2:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8003a7:	75 b9                	jne    800362 <fd_alloc+0x1e>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8003a9:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_MAX_OPEN;
  8003af:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8003b4:	5b                   	pop    %ebx
  8003b5:	c9                   	leave  
  8003b6:	c3                   	ret    

008003b7 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8003b7:	55                   	push   %ebp
  8003b8:	89 e5                	mov    %esp,%ebp
  8003ba:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8003bd:	83 f8 1f             	cmp    $0x1f,%eax
  8003c0:	77 36                	ja     8003f8 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8003c2:	05 00 00 0d 00       	add    $0xd0000,%eax
  8003c7:	c1 e0 0c             	shl    $0xc,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8003ca:	89 c2                	mov    %eax,%edx
  8003cc:	c1 ea 16             	shr    $0x16,%edx
  8003cf:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8003d6:	f6 c2 01             	test   $0x1,%dl
  8003d9:	74 24                	je     8003ff <fd_lookup+0x48>
  8003db:	89 c2                	mov    %eax,%edx
  8003dd:	c1 ea 0c             	shr    $0xc,%edx
  8003e0:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8003e7:	f6 c2 01             	test   $0x1,%dl
  8003ea:	74 1a                	je     800406 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8003ec:	8b 55 0c             	mov    0xc(%ebp),%edx
  8003ef:	89 02                	mov    %eax,(%edx)
	return 0;
  8003f1:	b8 00 00 00 00       	mov    $0x0,%eax
  8003f6:	eb 13                	jmp    80040b <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8003f8:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8003fd:	eb 0c                	jmp    80040b <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8003ff:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800404:	eb 05                	jmp    80040b <fd_lookup+0x54>
  800406:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  80040b:	c9                   	leave  
  80040c:	c3                   	ret    

0080040d <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  80040d:	55                   	push   %ebp
  80040e:	89 e5                	mov    %esp,%ebp
  800410:	53                   	push   %ebx
  800411:	83 ec 04             	sub    $0x4,%esp
  800414:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800417:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
		if (devtab[i]->dev_id == dev_id) {
  80041a:	39 0d 04 30 80 00    	cmp    %ecx,0x803004
  800420:	74 0d                	je     80042f <dev_lookup+0x22>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800422:	b8 00 00 00 00       	mov    $0x0,%eax
  800427:	eb 14                	jmp    80043d <dev_lookup+0x30>
		if (devtab[i]->dev_id == dev_id) {
  800429:	39 0a                	cmp    %ecx,(%edx)
  80042b:	75 10                	jne    80043d <dev_lookup+0x30>
  80042d:	eb 05                	jmp    800434 <dev_lookup+0x27>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  80042f:	ba 04 30 80 00       	mov    $0x803004,%edx
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
  800434:	89 13                	mov    %edx,(%ebx)
			return 0;
  800436:	b8 00 00 00 00       	mov    $0x0,%eax
  80043b:	eb 31                	jmp    80046e <dev_lookup+0x61>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  80043d:	40                   	inc    %eax
  80043e:	8b 14 85 54 1e 80 00 	mov    0x801e54(,%eax,4),%edx
  800445:	85 d2                	test   %edx,%edx
  800447:	75 e0                	jne    800429 <dev_lookup+0x1c>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800449:	a1 04 40 80 00       	mov    0x804004,%eax
  80044e:	8b 40 48             	mov    0x48(%eax),%eax
  800451:	83 ec 04             	sub    $0x4,%esp
  800454:	51                   	push   %ecx
  800455:	50                   	push   %eax
  800456:	68 d8 1d 80 00       	push   $0x801dd8
  80045b:	e8 48 0c 00 00       	call   8010a8 <cprintf>
	*dev = 0;
  800460:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_INVAL;
  800466:	83 c4 10             	add    $0x10,%esp
  800469:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  80046e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800471:	c9                   	leave  
  800472:	c3                   	ret    

00800473 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800473:	55                   	push   %ebp
  800474:	89 e5                	mov    %esp,%ebp
  800476:	56                   	push   %esi
  800477:	53                   	push   %ebx
  800478:	83 ec 20             	sub    $0x20,%esp
  80047b:	8b 75 08             	mov    0x8(%ebp),%esi
  80047e:	8a 45 0c             	mov    0xc(%ebp),%al
  800481:	88 45 e7             	mov    %al,-0x19(%ebp)
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800484:	56                   	push   %esi
  800485:	e8 92 fe ff ff       	call   80031c <fd2num>
  80048a:	8d 55 f4             	lea    -0xc(%ebp),%edx
  80048d:	89 14 24             	mov    %edx,(%esp)
  800490:	50                   	push   %eax
  800491:	e8 21 ff ff ff       	call   8003b7 <fd_lookup>
  800496:	89 c3                	mov    %eax,%ebx
  800498:	83 c4 08             	add    $0x8,%esp
  80049b:	85 c0                	test   %eax,%eax
  80049d:	78 05                	js     8004a4 <fd_close+0x31>
	    || fd != fd2)
  80049f:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8004a2:	74 0d                	je     8004b1 <fd_close+0x3e>
		return (must_exist ? r : 0);
  8004a4:	80 7d e7 00          	cmpb   $0x0,-0x19(%ebp)
  8004a8:	75 48                	jne    8004f2 <fd_close+0x7f>
  8004aa:	bb 00 00 00 00       	mov    $0x0,%ebx
  8004af:	eb 41                	jmp    8004f2 <fd_close+0x7f>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8004b1:	83 ec 08             	sub    $0x8,%esp
  8004b4:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8004b7:	50                   	push   %eax
  8004b8:	ff 36                	pushl  (%esi)
  8004ba:	e8 4e ff ff ff       	call   80040d <dev_lookup>
  8004bf:	89 c3                	mov    %eax,%ebx
  8004c1:	83 c4 10             	add    $0x10,%esp
  8004c4:	85 c0                	test   %eax,%eax
  8004c6:	78 1c                	js     8004e4 <fd_close+0x71>
		if (dev->dev_close)
  8004c8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8004cb:	8b 40 10             	mov    0x10(%eax),%eax
  8004ce:	85 c0                	test   %eax,%eax
  8004d0:	74 0d                	je     8004df <fd_close+0x6c>
			r = (*dev->dev_close)(fd);
  8004d2:	83 ec 0c             	sub    $0xc,%esp
  8004d5:	56                   	push   %esi
  8004d6:	ff d0                	call   *%eax
  8004d8:	89 c3                	mov    %eax,%ebx
  8004da:	83 c4 10             	add    $0x10,%esp
  8004dd:	eb 05                	jmp    8004e4 <fd_close+0x71>
		else
			r = 0;
  8004df:	bb 00 00 00 00       	mov    $0x0,%ebx
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8004e4:	83 ec 08             	sub    $0x8,%esp
  8004e7:	56                   	push   %esi
  8004e8:	6a 00                	push   $0x0
  8004ea:	e8 0f fd ff ff       	call   8001fe <sys_page_unmap>
	return r;
  8004ef:	83 c4 10             	add    $0x10,%esp
}
  8004f2:	89 d8                	mov    %ebx,%eax
  8004f4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8004f7:	5b                   	pop    %ebx
  8004f8:	5e                   	pop    %esi
  8004f9:	c9                   	leave  
  8004fa:	c3                   	ret    

008004fb <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8004fb:	55                   	push   %ebp
  8004fc:	89 e5                	mov    %esp,%ebp
  8004fe:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800501:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800504:	50                   	push   %eax
  800505:	ff 75 08             	pushl  0x8(%ebp)
  800508:	e8 aa fe ff ff       	call   8003b7 <fd_lookup>
  80050d:	83 c4 08             	add    $0x8,%esp
  800510:	85 c0                	test   %eax,%eax
  800512:	78 10                	js     800524 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  800514:	83 ec 08             	sub    $0x8,%esp
  800517:	6a 01                	push   $0x1
  800519:	ff 75 f4             	pushl  -0xc(%ebp)
  80051c:	e8 52 ff ff ff       	call   800473 <fd_close>
  800521:	83 c4 10             	add    $0x10,%esp
}
  800524:	c9                   	leave  
  800525:	c3                   	ret    

00800526 <close_all>:

void
close_all(void)
{
  800526:	55                   	push   %ebp
  800527:	89 e5                	mov    %esp,%ebp
  800529:	53                   	push   %ebx
  80052a:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  80052d:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  800532:	83 ec 0c             	sub    $0xc,%esp
  800535:	53                   	push   %ebx
  800536:	e8 c0 ff ff ff       	call   8004fb <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  80053b:	43                   	inc    %ebx
  80053c:	83 c4 10             	add    $0x10,%esp
  80053f:	83 fb 20             	cmp    $0x20,%ebx
  800542:	75 ee                	jne    800532 <close_all+0xc>
		close(i);
}
  800544:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800547:	c9                   	leave  
  800548:	c3                   	ret    

00800549 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800549:	55                   	push   %ebp
  80054a:	89 e5                	mov    %esp,%ebp
  80054c:	57                   	push   %edi
  80054d:	56                   	push   %esi
  80054e:	53                   	push   %ebx
  80054f:	83 ec 2c             	sub    $0x2c,%esp
  800552:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  800555:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800558:	50                   	push   %eax
  800559:	ff 75 08             	pushl  0x8(%ebp)
  80055c:	e8 56 fe ff ff       	call   8003b7 <fd_lookup>
  800561:	89 c3                	mov    %eax,%ebx
  800563:	83 c4 08             	add    $0x8,%esp
  800566:	85 c0                	test   %eax,%eax
  800568:	0f 88 c0 00 00 00    	js     80062e <dup+0xe5>
		return r;
	close(newfdnum);
  80056e:	83 ec 0c             	sub    $0xc,%esp
  800571:	57                   	push   %edi
  800572:	e8 84 ff ff ff       	call   8004fb <close>

	newfd = INDEX2FD(newfdnum);
  800577:	8d b7 00 00 0d 00    	lea    0xd0000(%edi),%esi
  80057d:	c1 e6 0c             	shl    $0xc,%esi
	ova = fd2data(oldfd);
  800580:	83 c4 04             	add    $0x4,%esp
  800583:	ff 75 e4             	pushl  -0x1c(%ebp)
  800586:	e8 a1 fd ff ff       	call   80032c <fd2data>
  80058b:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  80058d:	89 34 24             	mov    %esi,(%esp)
  800590:	e8 97 fd ff ff       	call   80032c <fd2data>
  800595:	83 c4 10             	add    $0x10,%esp
  800598:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80059b:	89 d8                	mov    %ebx,%eax
  80059d:	c1 e8 16             	shr    $0x16,%eax
  8005a0:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8005a7:	a8 01                	test   $0x1,%al
  8005a9:	74 37                	je     8005e2 <dup+0x99>
  8005ab:	89 d8                	mov    %ebx,%eax
  8005ad:	c1 e8 0c             	shr    $0xc,%eax
  8005b0:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8005b7:	f6 c2 01             	test   $0x1,%dl
  8005ba:	74 26                	je     8005e2 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8005bc:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8005c3:	83 ec 0c             	sub    $0xc,%esp
  8005c6:	25 07 0e 00 00       	and    $0xe07,%eax
  8005cb:	50                   	push   %eax
  8005cc:	ff 75 d4             	pushl  -0x2c(%ebp)
  8005cf:	6a 00                	push   $0x0
  8005d1:	53                   	push   %ebx
  8005d2:	6a 00                	push   $0x0
  8005d4:	e8 ff fb ff ff       	call   8001d8 <sys_page_map>
  8005d9:	89 c3                	mov    %eax,%ebx
  8005db:	83 c4 20             	add    $0x20,%esp
  8005de:	85 c0                	test   %eax,%eax
  8005e0:	78 2d                	js     80060f <dup+0xc6>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8005e2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8005e5:	89 c2                	mov    %eax,%edx
  8005e7:	c1 ea 0c             	shr    $0xc,%edx
  8005ea:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8005f1:	83 ec 0c             	sub    $0xc,%esp
  8005f4:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  8005fa:	52                   	push   %edx
  8005fb:	56                   	push   %esi
  8005fc:	6a 00                	push   $0x0
  8005fe:	50                   	push   %eax
  8005ff:	6a 00                	push   $0x0
  800601:	e8 d2 fb ff ff       	call   8001d8 <sys_page_map>
  800606:	89 c3                	mov    %eax,%ebx
  800608:	83 c4 20             	add    $0x20,%esp
  80060b:	85 c0                	test   %eax,%eax
  80060d:	79 1d                	jns    80062c <dup+0xe3>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  80060f:	83 ec 08             	sub    $0x8,%esp
  800612:	56                   	push   %esi
  800613:	6a 00                	push   $0x0
  800615:	e8 e4 fb ff ff       	call   8001fe <sys_page_unmap>
	sys_page_unmap(0, nva);
  80061a:	83 c4 08             	add    $0x8,%esp
  80061d:	ff 75 d4             	pushl  -0x2c(%ebp)
  800620:	6a 00                	push   $0x0
  800622:	e8 d7 fb ff ff       	call   8001fe <sys_page_unmap>
	return r;
  800627:	83 c4 10             	add    $0x10,%esp
  80062a:	eb 02                	jmp    80062e <dup+0xe5>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
		goto err;

	return newfdnum;
  80062c:	89 fb                	mov    %edi,%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  80062e:	89 d8                	mov    %ebx,%eax
  800630:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800633:	5b                   	pop    %ebx
  800634:	5e                   	pop    %esi
  800635:	5f                   	pop    %edi
  800636:	c9                   	leave  
  800637:	c3                   	ret    

00800638 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  800638:	55                   	push   %ebp
  800639:	89 e5                	mov    %esp,%ebp
  80063b:	53                   	push   %ebx
  80063c:	83 ec 14             	sub    $0x14,%esp
  80063f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800642:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800645:	50                   	push   %eax
  800646:	53                   	push   %ebx
  800647:	e8 6b fd ff ff       	call   8003b7 <fd_lookup>
  80064c:	83 c4 08             	add    $0x8,%esp
  80064f:	85 c0                	test   %eax,%eax
  800651:	78 67                	js     8006ba <read+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800653:	83 ec 08             	sub    $0x8,%esp
  800656:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800659:	50                   	push   %eax
  80065a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80065d:	ff 30                	pushl  (%eax)
  80065f:	e8 a9 fd ff ff       	call   80040d <dev_lookup>
  800664:	83 c4 10             	add    $0x10,%esp
  800667:	85 c0                	test   %eax,%eax
  800669:	78 4f                	js     8006ba <read+0x82>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80066b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80066e:	8b 50 08             	mov    0x8(%eax),%edx
  800671:	83 e2 03             	and    $0x3,%edx
  800674:	83 fa 01             	cmp    $0x1,%edx
  800677:	75 21                	jne    80069a <read+0x62>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  800679:	a1 04 40 80 00       	mov    0x804004,%eax
  80067e:	8b 40 48             	mov    0x48(%eax),%eax
  800681:	83 ec 04             	sub    $0x4,%esp
  800684:	53                   	push   %ebx
  800685:	50                   	push   %eax
  800686:	68 19 1e 80 00       	push   $0x801e19
  80068b:	e8 18 0a 00 00       	call   8010a8 <cprintf>
		return -E_INVAL;
  800690:	83 c4 10             	add    $0x10,%esp
  800693:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800698:	eb 20                	jmp    8006ba <read+0x82>
	}
	if (!dev->dev_read)
  80069a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80069d:	8b 52 08             	mov    0x8(%edx),%edx
  8006a0:	85 d2                	test   %edx,%edx
  8006a2:	74 11                	je     8006b5 <read+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8006a4:	83 ec 04             	sub    $0x4,%esp
  8006a7:	ff 75 10             	pushl  0x10(%ebp)
  8006aa:	ff 75 0c             	pushl  0xc(%ebp)
  8006ad:	50                   	push   %eax
  8006ae:	ff d2                	call   *%edx
  8006b0:	83 c4 10             	add    $0x10,%esp
  8006b3:	eb 05                	jmp    8006ba <read+0x82>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8006b5:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_read)(fd, buf, n);
}
  8006ba:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8006bd:	c9                   	leave  
  8006be:	c3                   	ret    

008006bf <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8006bf:	55                   	push   %ebp
  8006c0:	89 e5                	mov    %esp,%ebp
  8006c2:	57                   	push   %edi
  8006c3:	56                   	push   %esi
  8006c4:	53                   	push   %ebx
  8006c5:	83 ec 0c             	sub    $0xc,%esp
  8006c8:	8b 7d 08             	mov    0x8(%ebp),%edi
  8006cb:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8006ce:	85 f6                	test   %esi,%esi
  8006d0:	74 31                	je     800703 <readn+0x44>
  8006d2:	b8 00 00 00 00       	mov    $0x0,%eax
  8006d7:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = read(fdnum, (char*)buf + tot, n - tot);
  8006dc:	83 ec 04             	sub    $0x4,%esp
  8006df:	89 f2                	mov    %esi,%edx
  8006e1:	29 c2                	sub    %eax,%edx
  8006e3:	52                   	push   %edx
  8006e4:	03 45 0c             	add    0xc(%ebp),%eax
  8006e7:	50                   	push   %eax
  8006e8:	57                   	push   %edi
  8006e9:	e8 4a ff ff ff       	call   800638 <read>
		if (m < 0)
  8006ee:	83 c4 10             	add    $0x10,%esp
  8006f1:	85 c0                	test   %eax,%eax
  8006f3:	78 17                	js     80070c <readn+0x4d>
			return m;
		if (m == 0)
  8006f5:	85 c0                	test   %eax,%eax
  8006f7:	74 11                	je     80070a <readn+0x4b>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8006f9:	01 c3                	add    %eax,%ebx
  8006fb:	89 d8                	mov    %ebx,%eax
  8006fd:	39 f3                	cmp    %esi,%ebx
  8006ff:	72 db                	jb     8006dc <readn+0x1d>
  800701:	eb 09                	jmp    80070c <readn+0x4d>
  800703:	b8 00 00 00 00       	mov    $0x0,%eax
  800708:	eb 02                	jmp    80070c <readn+0x4d>
		m = read(fdnum, (char*)buf + tot, n - tot);
		if (m < 0)
			return m;
		if (m == 0)
  80070a:	89 d8                	mov    %ebx,%eax
			break;
	}
	return tot;
}
  80070c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80070f:	5b                   	pop    %ebx
  800710:	5e                   	pop    %esi
  800711:	5f                   	pop    %edi
  800712:	c9                   	leave  
  800713:	c3                   	ret    

00800714 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  800714:	55                   	push   %ebp
  800715:	89 e5                	mov    %esp,%ebp
  800717:	53                   	push   %ebx
  800718:	83 ec 14             	sub    $0x14,%esp
  80071b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80071e:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800721:	50                   	push   %eax
  800722:	53                   	push   %ebx
  800723:	e8 8f fc ff ff       	call   8003b7 <fd_lookup>
  800728:	83 c4 08             	add    $0x8,%esp
  80072b:	85 c0                	test   %eax,%eax
  80072d:	78 62                	js     800791 <write+0x7d>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80072f:	83 ec 08             	sub    $0x8,%esp
  800732:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800735:	50                   	push   %eax
  800736:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800739:	ff 30                	pushl  (%eax)
  80073b:	e8 cd fc ff ff       	call   80040d <dev_lookup>
  800740:	83 c4 10             	add    $0x10,%esp
  800743:	85 c0                	test   %eax,%eax
  800745:	78 4a                	js     800791 <write+0x7d>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800747:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80074a:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80074e:	75 21                	jne    800771 <write+0x5d>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  800750:	a1 04 40 80 00       	mov    0x804004,%eax
  800755:	8b 40 48             	mov    0x48(%eax),%eax
  800758:	83 ec 04             	sub    $0x4,%esp
  80075b:	53                   	push   %ebx
  80075c:	50                   	push   %eax
  80075d:	68 35 1e 80 00       	push   $0x801e35
  800762:	e8 41 09 00 00       	call   8010a8 <cprintf>
		return -E_INVAL;
  800767:	83 c4 10             	add    $0x10,%esp
  80076a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80076f:	eb 20                	jmp    800791 <write+0x7d>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  800771:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800774:	8b 52 0c             	mov    0xc(%edx),%edx
  800777:	85 d2                	test   %edx,%edx
  800779:	74 11                	je     80078c <write+0x78>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80077b:	83 ec 04             	sub    $0x4,%esp
  80077e:	ff 75 10             	pushl  0x10(%ebp)
  800781:	ff 75 0c             	pushl  0xc(%ebp)
  800784:	50                   	push   %eax
  800785:	ff d2                	call   *%edx
  800787:	83 c4 10             	add    $0x10,%esp
  80078a:	eb 05                	jmp    800791 <write+0x7d>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  80078c:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  800791:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800794:	c9                   	leave  
  800795:	c3                   	ret    

00800796 <seek>:

int
seek(int fdnum, off_t offset)
{
  800796:	55                   	push   %ebp
  800797:	89 e5                	mov    %esp,%ebp
  800799:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80079c:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80079f:	50                   	push   %eax
  8007a0:	ff 75 08             	pushl  0x8(%ebp)
  8007a3:	e8 0f fc ff ff       	call   8003b7 <fd_lookup>
  8007a8:	83 c4 08             	add    $0x8,%esp
  8007ab:	85 c0                	test   %eax,%eax
  8007ad:	78 0e                	js     8007bd <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8007af:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8007b2:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007b5:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8007b8:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8007bd:	c9                   	leave  
  8007be:	c3                   	ret    

008007bf <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8007bf:	55                   	push   %ebp
  8007c0:	89 e5                	mov    %esp,%ebp
  8007c2:	53                   	push   %ebx
  8007c3:	83 ec 14             	sub    $0x14,%esp
  8007c6:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8007c9:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8007cc:	50                   	push   %eax
  8007cd:	53                   	push   %ebx
  8007ce:	e8 e4 fb ff ff       	call   8003b7 <fd_lookup>
  8007d3:	83 c4 08             	add    $0x8,%esp
  8007d6:	85 c0                	test   %eax,%eax
  8007d8:	78 5f                	js     800839 <ftruncate+0x7a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8007da:	83 ec 08             	sub    $0x8,%esp
  8007dd:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8007e0:	50                   	push   %eax
  8007e1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8007e4:	ff 30                	pushl  (%eax)
  8007e6:	e8 22 fc ff ff       	call   80040d <dev_lookup>
  8007eb:	83 c4 10             	add    $0x10,%esp
  8007ee:	85 c0                	test   %eax,%eax
  8007f0:	78 47                	js     800839 <ftruncate+0x7a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8007f2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8007f5:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8007f9:	75 21                	jne    80081c <ftruncate+0x5d>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8007fb:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  800800:	8b 40 48             	mov    0x48(%eax),%eax
  800803:	83 ec 04             	sub    $0x4,%esp
  800806:	53                   	push   %ebx
  800807:	50                   	push   %eax
  800808:	68 f8 1d 80 00       	push   $0x801df8
  80080d:	e8 96 08 00 00       	call   8010a8 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  800812:	83 c4 10             	add    $0x10,%esp
  800815:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80081a:	eb 1d                	jmp    800839 <ftruncate+0x7a>
	}
	if (!dev->dev_trunc)
  80081c:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80081f:	8b 52 18             	mov    0x18(%edx),%edx
  800822:	85 d2                	test   %edx,%edx
  800824:	74 0e                	je     800834 <ftruncate+0x75>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  800826:	83 ec 08             	sub    $0x8,%esp
  800829:	ff 75 0c             	pushl  0xc(%ebp)
  80082c:	50                   	push   %eax
  80082d:	ff d2                	call   *%edx
  80082f:	83 c4 10             	add    $0x10,%esp
  800832:	eb 05                	jmp    800839 <ftruncate+0x7a>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  800834:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  800839:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80083c:	c9                   	leave  
  80083d:	c3                   	ret    

0080083e <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  80083e:	55                   	push   %ebp
  80083f:	89 e5                	mov    %esp,%ebp
  800841:	53                   	push   %ebx
  800842:	83 ec 14             	sub    $0x14,%esp
  800845:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800848:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80084b:	50                   	push   %eax
  80084c:	ff 75 08             	pushl  0x8(%ebp)
  80084f:	e8 63 fb ff ff       	call   8003b7 <fd_lookup>
  800854:	83 c4 08             	add    $0x8,%esp
  800857:	85 c0                	test   %eax,%eax
  800859:	78 52                	js     8008ad <fstat+0x6f>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80085b:	83 ec 08             	sub    $0x8,%esp
  80085e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800861:	50                   	push   %eax
  800862:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800865:	ff 30                	pushl  (%eax)
  800867:	e8 a1 fb ff ff       	call   80040d <dev_lookup>
  80086c:	83 c4 10             	add    $0x10,%esp
  80086f:	85 c0                	test   %eax,%eax
  800871:	78 3a                	js     8008ad <fstat+0x6f>
		return r;
	if (!dev->dev_stat)
  800873:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800876:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  80087a:	74 2c                	je     8008a8 <fstat+0x6a>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  80087c:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  80087f:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  800886:	00 00 00 
	stat->st_isdir = 0;
  800889:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  800890:	00 00 00 
	stat->st_dev = dev;
  800893:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  800899:	83 ec 08             	sub    $0x8,%esp
  80089c:	53                   	push   %ebx
  80089d:	ff 75 f0             	pushl  -0x10(%ebp)
  8008a0:	ff 50 14             	call   *0x14(%eax)
  8008a3:	83 c4 10             	add    $0x10,%esp
  8008a6:	eb 05                	jmp    8008ad <fstat+0x6f>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8008a8:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8008ad:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8008b0:	c9                   	leave  
  8008b1:	c3                   	ret    

008008b2 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8008b2:	55                   	push   %ebp
  8008b3:	89 e5                	mov    %esp,%ebp
  8008b5:	56                   	push   %esi
  8008b6:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8008b7:	83 ec 08             	sub    $0x8,%esp
  8008ba:	6a 00                	push   $0x0
  8008bc:	ff 75 08             	pushl  0x8(%ebp)
  8008bf:	e8 78 01 00 00       	call   800a3c <open>
  8008c4:	89 c3                	mov    %eax,%ebx
  8008c6:	83 c4 10             	add    $0x10,%esp
  8008c9:	85 c0                	test   %eax,%eax
  8008cb:	78 1b                	js     8008e8 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8008cd:	83 ec 08             	sub    $0x8,%esp
  8008d0:	ff 75 0c             	pushl  0xc(%ebp)
  8008d3:	50                   	push   %eax
  8008d4:	e8 65 ff ff ff       	call   80083e <fstat>
  8008d9:	89 c6                	mov    %eax,%esi
	close(fd);
  8008db:	89 1c 24             	mov    %ebx,(%esp)
  8008de:	e8 18 fc ff ff       	call   8004fb <close>
	return r;
  8008e3:	83 c4 10             	add    $0x10,%esp
  8008e6:	89 f3                	mov    %esi,%ebx
}
  8008e8:	89 d8                	mov    %ebx,%eax
  8008ea:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8008ed:	5b                   	pop    %ebx
  8008ee:	5e                   	pop    %esi
  8008ef:	c9                   	leave  
  8008f0:	c3                   	ret    
  8008f1:	00 00                	add    %al,(%eax)
	...

008008f4 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8008f4:	55                   	push   %ebp
  8008f5:	89 e5                	mov    %esp,%ebp
  8008f7:	56                   	push   %esi
  8008f8:	53                   	push   %ebx
  8008f9:	89 c3                	mov    %eax,%ebx
  8008fb:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  8008fd:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  800904:	75 12                	jne    800918 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  800906:	83 ec 0c             	sub    $0xc,%esp
  800909:	6a 01                	push   $0x1
  80090b:	e8 96 11 00 00       	call   801aa6 <ipc_find_env>
  800910:	a3 00 40 80 00       	mov    %eax,0x804000
  800915:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  800918:	6a 07                	push   $0x7
  80091a:	68 00 50 80 00       	push   $0x805000
  80091f:	53                   	push   %ebx
  800920:	ff 35 00 40 80 00    	pushl  0x804000
  800926:	e8 26 11 00 00       	call   801a51 <ipc_send>
	
	return ipc_recv(NULL, dstva, NULL);
  80092b:	83 c4 0c             	add    $0xc,%esp
  80092e:	6a 00                	push   $0x0
  800930:	56                   	push   %esi
  800931:	6a 00                	push   $0x0
  800933:	e8 a4 10 00 00       	call   8019dc <ipc_recv>
}
  800938:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80093b:	5b                   	pop    %ebx
  80093c:	5e                   	pop    %esi
  80093d:	c9                   	leave  
  80093e:	c3                   	ret    

0080093f <devfile_stat>:
}


static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  80093f:	55                   	push   %ebp
  800940:	89 e5                	mov    %esp,%ebp
  800942:	53                   	push   %ebx
  800943:	83 ec 04             	sub    $0x4,%esp
  800946:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  800949:	8b 45 08             	mov    0x8(%ebp),%eax
  80094c:	8b 40 0c             	mov    0xc(%eax),%eax
  80094f:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0) {
  800954:	ba 00 00 00 00       	mov    $0x0,%edx
  800959:	b8 05 00 00 00       	mov    $0x5,%eax
  80095e:	e8 91 ff ff ff       	call   8008f4 <fsipc>
  800963:	85 c0                	test   %eax,%eax
  800965:	78 2c                	js     800993 <devfile_stat+0x54>
		return r;
	}
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  800967:	83 ec 08             	sub    $0x8,%esp
  80096a:	68 00 50 80 00       	push   $0x805000
  80096f:	53                   	push   %ebx
  800970:	e8 e9 0c 00 00       	call   80165e <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  800975:	a1 80 50 80 00       	mov    0x805080,%eax
  80097a:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  800980:	a1 84 50 80 00       	mov    0x805084,%eax
  800985:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  80098b:	83 c4 10             	add    $0x10,%esp
  80098e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800993:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800996:	c9                   	leave  
  800997:	c3                   	ret    

00800998 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  800998:	55                   	push   %ebp
  800999:	89 e5                	mov    %esp,%ebp
  80099b:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  80099e:	8b 45 08             	mov    0x8(%ebp),%eax
  8009a1:	8b 40 0c             	mov    0xc(%eax),%eax
  8009a4:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8009a9:	ba 00 00 00 00       	mov    $0x0,%edx
  8009ae:	b8 06 00 00 00       	mov    $0x6,%eax
  8009b3:	e8 3c ff ff ff       	call   8008f4 <fsipc>
}
  8009b8:	c9                   	leave  
  8009b9:	c3                   	ret    

008009ba <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  8009ba:	55                   	push   %ebp
  8009bb:	89 e5                	mov    %esp,%ebp
  8009bd:	56                   	push   %esi
  8009be:	53                   	push   %ebx
  8009bf:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8009c2:	8b 45 08             	mov    0x8(%ebp),%eax
  8009c5:	8b 40 0c             	mov    0xc(%eax),%eax
  8009c8:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  8009cd:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8009d3:	ba 00 00 00 00       	mov    $0x0,%edx
  8009d8:	b8 03 00 00 00       	mov    $0x3,%eax
  8009dd:	e8 12 ff ff ff       	call   8008f4 <fsipc>
  8009e2:	89 c3                	mov    %eax,%ebx
  8009e4:	85 c0                	test   %eax,%eax
  8009e6:	78 4b                	js     800a33 <devfile_read+0x79>
		return r;
	assert(r <= n);
  8009e8:	39 c6                	cmp    %eax,%esi
  8009ea:	73 16                	jae    800a02 <devfile_read+0x48>
  8009ec:	68 64 1e 80 00       	push   $0x801e64
  8009f1:	68 6b 1e 80 00       	push   $0x801e6b
  8009f6:	6a 7d                	push   $0x7d
  8009f8:	68 80 1e 80 00       	push   $0x801e80
  8009fd:	e8 ce 05 00 00       	call   800fd0 <_panic>
	assert(r <= PGSIZE);
  800a02:	3d 00 10 00 00       	cmp    $0x1000,%eax
  800a07:	7e 16                	jle    800a1f <devfile_read+0x65>
  800a09:	68 8b 1e 80 00       	push   $0x801e8b
  800a0e:	68 6b 1e 80 00       	push   $0x801e6b
  800a13:	6a 7e                	push   $0x7e
  800a15:	68 80 1e 80 00       	push   $0x801e80
  800a1a:	e8 b1 05 00 00       	call   800fd0 <_panic>
	memmove(buf, &fsipcbuf, r);
  800a1f:	83 ec 04             	sub    $0x4,%esp
  800a22:	50                   	push   %eax
  800a23:	68 00 50 80 00       	push   $0x805000
  800a28:	ff 75 0c             	pushl  0xc(%ebp)
  800a2b:	e8 ef 0d 00 00       	call   80181f <memmove>
	return r;
  800a30:	83 c4 10             	add    $0x10,%esp
}
  800a33:	89 d8                	mov    %ebx,%eax
  800a35:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800a38:	5b                   	pop    %ebx
  800a39:	5e                   	pop    %esi
  800a3a:	c9                   	leave  
  800a3b:	c3                   	ret    

00800a3c <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  800a3c:	55                   	push   %ebp
  800a3d:	89 e5                	mov    %esp,%ebp
  800a3f:	56                   	push   %esi
  800a40:	53                   	push   %ebx
  800a41:	83 ec 1c             	sub    $0x1c,%esp
  800a44:	8b 75 08             	mov    0x8(%ebp),%esi
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  800a47:	56                   	push   %esi
  800a48:	e8 bf 0b 00 00       	call   80160c <strlen>
  800a4d:	83 c4 10             	add    $0x10,%esp
  800a50:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  800a55:	7f 65                	jg     800abc <open+0x80>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800a57:	83 ec 0c             	sub    $0xc,%esp
  800a5a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800a5d:	50                   	push   %eax
  800a5e:	e8 e1 f8 ff ff       	call   800344 <fd_alloc>
  800a63:	89 c3                	mov    %eax,%ebx
  800a65:	83 c4 10             	add    $0x10,%esp
  800a68:	85 c0                	test   %eax,%eax
  800a6a:	78 55                	js     800ac1 <open+0x85>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  800a6c:	83 ec 08             	sub    $0x8,%esp
  800a6f:	56                   	push   %esi
  800a70:	68 00 50 80 00       	push   $0x805000
  800a75:	e8 e4 0b 00 00       	call   80165e <strcpy>
	fsipcbuf.open.req_omode = mode;
  800a7a:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a7d:	a3 00 54 80 00       	mov    %eax,0x805400



	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  800a82:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800a85:	b8 01 00 00 00       	mov    $0x1,%eax
  800a8a:	e8 65 fe ff ff       	call   8008f4 <fsipc>
  800a8f:	89 c3                	mov    %eax,%ebx
  800a91:	83 c4 10             	add    $0x10,%esp
  800a94:	85 c0                	test   %eax,%eax
  800a96:	79 12                	jns    800aaa <open+0x6e>
		fd_close(fd, 0);
  800a98:	83 ec 08             	sub    $0x8,%esp
  800a9b:	6a 00                	push   $0x0
  800a9d:	ff 75 f4             	pushl  -0xc(%ebp)
  800aa0:	e8 ce f9 ff ff       	call   800473 <fd_close>
		return r;
  800aa5:	83 c4 10             	add    $0x10,%esp
  800aa8:	eb 17                	jmp    800ac1 <open+0x85>
	}

	return fd2num(fd);
  800aaa:	83 ec 0c             	sub    $0xc,%esp
  800aad:	ff 75 f4             	pushl  -0xc(%ebp)
  800ab0:	e8 67 f8 ff ff       	call   80031c <fd2num>
  800ab5:	89 c3                	mov    %eax,%ebx
  800ab7:	83 c4 10             	add    $0x10,%esp
  800aba:	eb 05                	jmp    800ac1 <open+0x85>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  800abc:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  800ac1:	89 d8                	mov    %ebx,%eax
  800ac3:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800ac6:	5b                   	pop    %ebx
  800ac7:	5e                   	pop    %esi
  800ac8:	c9                   	leave  
  800ac9:	c3                   	ret    
	...

00800acc <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  800acc:	55                   	push   %ebp
  800acd:	89 e5                	mov    %esp,%ebp
  800acf:	56                   	push   %esi
  800ad0:	53                   	push   %ebx
  800ad1:	8b 75 0c             	mov    0xc(%ebp),%esi
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  800ad4:	83 ec 0c             	sub    $0xc,%esp
  800ad7:	ff 75 08             	pushl  0x8(%ebp)
  800ada:	e8 4d f8 ff ff       	call   80032c <fd2data>
  800adf:	89 c3                	mov    %eax,%ebx
	strcpy(stat->st_name, "<pipe>");
  800ae1:	83 c4 08             	add    $0x8,%esp
  800ae4:	68 97 1e 80 00       	push   $0x801e97
  800ae9:	56                   	push   %esi
  800aea:	e8 6f 0b 00 00       	call   80165e <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  800aef:	8b 43 04             	mov    0x4(%ebx),%eax
  800af2:	2b 03                	sub    (%ebx),%eax
  800af4:	89 86 80 00 00 00    	mov    %eax,0x80(%esi)
	stat->st_isdir = 0;
  800afa:	c7 86 84 00 00 00 00 	movl   $0x0,0x84(%esi)
  800b01:	00 00 00 
	stat->st_dev = &devpipe;
  800b04:	c7 86 88 00 00 00 20 	movl   $0x803020,0x88(%esi)
  800b0b:	30 80 00 
	return 0;
}
  800b0e:	b8 00 00 00 00       	mov    $0x0,%eax
  800b13:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800b16:	5b                   	pop    %ebx
  800b17:	5e                   	pop    %esi
  800b18:	c9                   	leave  
  800b19:	c3                   	ret    

00800b1a <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  800b1a:	55                   	push   %ebp
  800b1b:	89 e5                	mov    %esp,%ebp
  800b1d:	53                   	push   %ebx
  800b1e:	83 ec 0c             	sub    $0xc,%esp
  800b21:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  800b24:	53                   	push   %ebx
  800b25:	6a 00                	push   $0x0
  800b27:	e8 d2 f6 ff ff       	call   8001fe <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  800b2c:	89 1c 24             	mov    %ebx,(%esp)
  800b2f:	e8 f8 f7 ff ff       	call   80032c <fd2data>
  800b34:	83 c4 08             	add    $0x8,%esp
  800b37:	50                   	push   %eax
  800b38:	6a 00                	push   $0x0
  800b3a:	e8 bf f6 ff ff       	call   8001fe <sys_page_unmap>
}
  800b3f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800b42:	c9                   	leave  
  800b43:	c3                   	ret    

00800b44 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  800b44:	55                   	push   %ebp
  800b45:	89 e5                	mov    %esp,%ebp
  800b47:	57                   	push   %edi
  800b48:	56                   	push   %esi
  800b49:	53                   	push   %ebx
  800b4a:	83 ec 1c             	sub    $0x1c,%esp
  800b4d:	89 c7                	mov    %eax,%edi
  800b4f:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  800b52:	a1 04 40 80 00       	mov    0x804004,%eax
  800b57:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  800b5a:	83 ec 0c             	sub    $0xc,%esp
  800b5d:	57                   	push   %edi
  800b5e:	e8 a1 0f 00 00       	call   801b04 <pageref>
  800b63:	89 c6                	mov    %eax,%esi
  800b65:	83 c4 04             	add    $0x4,%esp
  800b68:	ff 75 e4             	pushl  -0x1c(%ebp)
  800b6b:	e8 94 0f 00 00       	call   801b04 <pageref>
  800b70:	83 c4 10             	add    $0x10,%esp
  800b73:	39 c6                	cmp    %eax,%esi
  800b75:	0f 94 c0             	sete   %al
  800b78:	0f b6 c0             	movzbl %al,%eax
		nn = thisenv->env_runs;
  800b7b:	8b 15 04 40 80 00    	mov    0x804004,%edx
  800b81:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  800b84:	39 cb                	cmp    %ecx,%ebx
  800b86:	75 08                	jne    800b90 <_pipeisclosed+0x4c>
			return ret;
		if (n != nn && ret == 1)
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
	}
}
  800b88:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b8b:	5b                   	pop    %ebx
  800b8c:	5e                   	pop    %esi
  800b8d:	5f                   	pop    %edi
  800b8e:	c9                   	leave  
  800b8f:	c3                   	ret    
		n = thisenv->env_runs;
		ret = pageref(fd) == pageref(p);
		nn = thisenv->env_runs;
		if (n == nn)
			return ret;
		if (n != nn && ret == 1)
  800b90:	83 f8 01             	cmp    $0x1,%eax
  800b93:	75 bd                	jne    800b52 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  800b95:	8b 42 58             	mov    0x58(%edx),%eax
  800b98:	6a 01                	push   $0x1
  800b9a:	50                   	push   %eax
  800b9b:	53                   	push   %ebx
  800b9c:	68 9e 1e 80 00       	push   $0x801e9e
  800ba1:	e8 02 05 00 00       	call   8010a8 <cprintf>
  800ba6:	83 c4 10             	add    $0x10,%esp
  800ba9:	eb a7                	jmp    800b52 <_pipeisclosed+0xe>

00800bab <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  800bab:	55                   	push   %ebp
  800bac:	89 e5                	mov    %esp,%ebp
  800bae:	57                   	push   %edi
  800baf:	56                   	push   %esi
  800bb0:	53                   	push   %ebx
  800bb1:	83 ec 28             	sub    $0x28,%esp
  800bb4:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  800bb7:	56                   	push   %esi
  800bb8:	e8 6f f7 ff ff       	call   80032c <fd2data>
  800bbd:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800bbf:	83 c4 10             	add    $0x10,%esp
  800bc2:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800bc6:	75 4a                	jne    800c12 <devpipe_write+0x67>
  800bc8:	bf 00 00 00 00       	mov    $0x0,%edi
  800bcd:	eb 56                	jmp    800c25 <devpipe_write+0x7a>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  800bcf:	89 da                	mov    %ebx,%edx
  800bd1:	89 f0                	mov    %esi,%eax
  800bd3:	e8 6c ff ff ff       	call   800b44 <_pipeisclosed>
  800bd8:	85 c0                	test   %eax,%eax
  800bda:	75 4d                	jne    800c29 <devpipe_write+0x7e>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  800bdc:	e8 ac f5 ff ff       	call   80018d <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  800be1:	8b 43 04             	mov    0x4(%ebx),%eax
  800be4:	8b 13                	mov    (%ebx),%edx
  800be6:	83 c2 20             	add    $0x20,%edx
  800be9:	39 d0                	cmp    %edx,%eax
  800beb:	73 e2                	jae    800bcf <devpipe_write+0x24>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  800bed:	89 c2                	mov    %eax,%edx
  800bef:	81 e2 1f 00 00 80    	and    $0x8000001f,%edx
  800bf5:	79 05                	jns    800bfc <devpipe_write+0x51>
  800bf7:	4a                   	dec    %edx
  800bf8:	83 ca e0             	or     $0xffffffe0,%edx
  800bfb:	42                   	inc    %edx
  800bfc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bff:	8a 0c 39             	mov    (%ecx,%edi,1),%cl
  800c02:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  800c06:	40                   	inc    %eax
  800c07:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800c0a:	47                   	inc    %edi
  800c0b:	39 7d 10             	cmp    %edi,0x10(%ebp)
  800c0e:	77 07                	ja     800c17 <devpipe_write+0x6c>
  800c10:	eb 13                	jmp    800c25 <devpipe_write+0x7a>
  800c12:	bf 00 00 00 00       	mov    $0x0,%edi
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  800c17:	8b 43 04             	mov    0x4(%ebx),%eax
  800c1a:	8b 13                	mov    (%ebx),%edx
  800c1c:	83 c2 20             	add    $0x20,%edx
  800c1f:	39 d0                	cmp    %edx,%eax
  800c21:	73 ac                	jae    800bcf <devpipe_write+0x24>
  800c23:	eb c8                	jmp    800bed <devpipe_write+0x42>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  800c25:	89 f8                	mov    %edi,%eax
  800c27:	eb 05                	jmp    800c2e <devpipe_write+0x83>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  800c29:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  800c2e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c31:	5b                   	pop    %ebx
  800c32:	5e                   	pop    %esi
  800c33:	5f                   	pop    %edi
  800c34:	c9                   	leave  
  800c35:	c3                   	ret    

00800c36 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  800c36:	55                   	push   %ebp
  800c37:	89 e5                	mov    %esp,%ebp
  800c39:	57                   	push   %edi
  800c3a:	56                   	push   %esi
  800c3b:	53                   	push   %ebx
  800c3c:	83 ec 18             	sub    $0x18,%esp
  800c3f:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  800c42:	57                   	push   %edi
  800c43:	e8 e4 f6 ff ff       	call   80032c <fd2data>
  800c48:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800c4a:	83 c4 10             	add    $0x10,%esp
  800c4d:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800c51:	75 44                	jne    800c97 <devpipe_read+0x61>
  800c53:	be 00 00 00 00       	mov    $0x0,%esi
  800c58:	eb 4f                	jmp    800ca9 <devpipe_read+0x73>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
				return i;
  800c5a:	89 f0                	mov    %esi,%eax
  800c5c:	eb 54                	jmp    800cb2 <devpipe_read+0x7c>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  800c5e:	89 da                	mov    %ebx,%edx
  800c60:	89 f8                	mov    %edi,%eax
  800c62:	e8 dd fe ff ff       	call   800b44 <_pipeisclosed>
  800c67:	85 c0                	test   %eax,%eax
  800c69:	75 42                	jne    800cad <devpipe_read+0x77>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  800c6b:	e8 1d f5 ff ff       	call   80018d <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  800c70:	8b 03                	mov    (%ebx),%eax
  800c72:	3b 43 04             	cmp    0x4(%ebx),%eax
  800c75:	74 e7                	je     800c5e <devpipe_read+0x28>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  800c77:	25 1f 00 00 80       	and    $0x8000001f,%eax
  800c7c:	79 05                	jns    800c83 <devpipe_read+0x4d>
  800c7e:	48                   	dec    %eax
  800c7f:	83 c8 e0             	or     $0xffffffe0,%eax
  800c82:	40                   	inc    %eax
  800c83:	8a 44 03 08          	mov    0x8(%ebx,%eax,1),%al
  800c87:	8b 55 0c             	mov    0xc(%ebp),%edx
  800c8a:	88 04 32             	mov    %al,(%edx,%esi,1)
		p->p_rpos++;
  800c8d:	ff 03                	incl   (%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800c8f:	46                   	inc    %esi
  800c90:	39 75 10             	cmp    %esi,0x10(%ebp)
  800c93:	77 07                	ja     800c9c <devpipe_read+0x66>
  800c95:	eb 12                	jmp    800ca9 <devpipe_read+0x73>
  800c97:	be 00 00 00 00       	mov    $0x0,%esi
		while (p->p_rpos == p->p_wpos) {
  800c9c:	8b 03                	mov    (%ebx),%eax
  800c9e:	3b 43 04             	cmp    0x4(%ebx),%eax
  800ca1:	75 d4                	jne    800c77 <devpipe_read+0x41>
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  800ca3:	85 f6                	test   %esi,%esi
  800ca5:	75 b3                	jne    800c5a <devpipe_read+0x24>
  800ca7:	eb b5                	jmp    800c5e <devpipe_read+0x28>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  800ca9:	89 f0                	mov    %esi,%eax
  800cab:	eb 05                	jmp    800cb2 <devpipe_read+0x7c>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  800cad:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  800cb2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cb5:	5b                   	pop    %ebx
  800cb6:	5e                   	pop    %esi
  800cb7:	5f                   	pop    %edi
  800cb8:	c9                   	leave  
  800cb9:	c3                   	ret    

00800cba <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  800cba:	55                   	push   %ebp
  800cbb:	89 e5                	mov    %esp,%ebp
  800cbd:	57                   	push   %edi
  800cbe:	56                   	push   %esi
  800cbf:	53                   	push   %ebx
  800cc0:	83 ec 28             	sub    $0x28,%esp
  800cc3:	8b 7d 08             	mov    0x8(%ebp),%edi
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  800cc6:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800cc9:	50                   	push   %eax
  800cca:	e8 75 f6 ff ff       	call   800344 <fd_alloc>
  800ccf:	89 c3                	mov    %eax,%ebx
  800cd1:	83 c4 10             	add    $0x10,%esp
  800cd4:	85 c0                	test   %eax,%eax
  800cd6:	0f 88 24 01 00 00    	js     800e00 <pipe+0x146>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800cdc:	83 ec 04             	sub    $0x4,%esp
  800cdf:	68 07 04 00 00       	push   $0x407
  800ce4:	ff 75 e4             	pushl  -0x1c(%ebp)
  800ce7:	6a 00                	push   $0x0
  800ce9:	e8 c6 f4 ff ff       	call   8001b4 <sys_page_alloc>
  800cee:	89 c3                	mov    %eax,%ebx
  800cf0:	83 c4 10             	add    $0x10,%esp
  800cf3:	85 c0                	test   %eax,%eax
  800cf5:	0f 88 05 01 00 00    	js     800e00 <pipe+0x146>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  800cfb:	83 ec 0c             	sub    $0xc,%esp
  800cfe:	8d 45 e0             	lea    -0x20(%ebp),%eax
  800d01:	50                   	push   %eax
  800d02:	e8 3d f6 ff ff       	call   800344 <fd_alloc>
  800d07:	89 c3                	mov    %eax,%ebx
  800d09:	83 c4 10             	add    $0x10,%esp
  800d0c:	85 c0                	test   %eax,%eax
  800d0e:	0f 88 dc 00 00 00    	js     800df0 <pipe+0x136>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800d14:	83 ec 04             	sub    $0x4,%esp
  800d17:	68 07 04 00 00       	push   $0x407
  800d1c:	ff 75 e0             	pushl  -0x20(%ebp)
  800d1f:	6a 00                	push   $0x0
  800d21:	e8 8e f4 ff ff       	call   8001b4 <sys_page_alloc>
  800d26:	89 c3                	mov    %eax,%ebx
  800d28:	83 c4 10             	add    $0x10,%esp
  800d2b:	85 c0                	test   %eax,%eax
  800d2d:	0f 88 bd 00 00 00    	js     800df0 <pipe+0x136>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  800d33:	83 ec 0c             	sub    $0xc,%esp
  800d36:	ff 75 e4             	pushl  -0x1c(%ebp)
  800d39:	e8 ee f5 ff ff       	call   80032c <fd2data>
  800d3e:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800d40:	83 c4 0c             	add    $0xc,%esp
  800d43:	68 07 04 00 00       	push   $0x407
  800d48:	50                   	push   %eax
  800d49:	6a 00                	push   $0x0
  800d4b:	e8 64 f4 ff ff       	call   8001b4 <sys_page_alloc>
  800d50:	89 c3                	mov    %eax,%ebx
  800d52:	83 c4 10             	add    $0x10,%esp
  800d55:	85 c0                	test   %eax,%eax
  800d57:	0f 88 83 00 00 00    	js     800de0 <pipe+0x126>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800d5d:	83 ec 0c             	sub    $0xc,%esp
  800d60:	ff 75 e0             	pushl  -0x20(%ebp)
  800d63:	e8 c4 f5 ff ff       	call   80032c <fd2data>
  800d68:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  800d6f:	50                   	push   %eax
  800d70:	6a 00                	push   $0x0
  800d72:	56                   	push   %esi
  800d73:	6a 00                	push   $0x0
  800d75:	e8 5e f4 ff ff       	call   8001d8 <sys_page_map>
  800d7a:	89 c3                	mov    %eax,%ebx
  800d7c:	83 c4 20             	add    $0x20,%esp
  800d7f:	85 c0                	test   %eax,%eax
  800d81:	78 4f                	js     800dd2 <pipe+0x118>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  800d83:	8b 15 20 30 80 00    	mov    0x803020,%edx
  800d89:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800d8c:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  800d8e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800d91:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  800d98:	8b 15 20 30 80 00    	mov    0x803020,%edx
  800d9e:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800da1:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  800da3:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800da6:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  800dad:	83 ec 0c             	sub    $0xc,%esp
  800db0:	ff 75 e4             	pushl  -0x1c(%ebp)
  800db3:	e8 64 f5 ff ff       	call   80031c <fd2num>
  800db8:	89 07                	mov    %eax,(%edi)
	pfd[1] = fd2num(fd1);
  800dba:	83 c4 04             	add    $0x4,%esp
  800dbd:	ff 75 e0             	pushl  -0x20(%ebp)
  800dc0:	e8 57 f5 ff ff       	call   80031c <fd2num>
  800dc5:	89 47 04             	mov    %eax,0x4(%edi)
	return 0;
  800dc8:	83 c4 10             	add    $0x10,%esp
  800dcb:	bb 00 00 00 00       	mov    $0x0,%ebx
  800dd0:	eb 2e                	jmp    800e00 <pipe+0x146>

    err3:
	sys_page_unmap(0, va);
  800dd2:	83 ec 08             	sub    $0x8,%esp
  800dd5:	56                   	push   %esi
  800dd6:	6a 00                	push   $0x0
  800dd8:	e8 21 f4 ff ff       	call   8001fe <sys_page_unmap>
  800ddd:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  800de0:	83 ec 08             	sub    $0x8,%esp
  800de3:	ff 75 e0             	pushl  -0x20(%ebp)
  800de6:	6a 00                	push   $0x0
  800de8:	e8 11 f4 ff ff       	call   8001fe <sys_page_unmap>
  800ded:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  800df0:	83 ec 08             	sub    $0x8,%esp
  800df3:	ff 75 e4             	pushl  -0x1c(%ebp)
  800df6:	6a 00                	push   $0x0
  800df8:	e8 01 f4 ff ff       	call   8001fe <sys_page_unmap>
  800dfd:	83 c4 10             	add    $0x10,%esp
    err:
	return r;
}
  800e00:	89 d8                	mov    %ebx,%eax
  800e02:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e05:	5b                   	pop    %ebx
  800e06:	5e                   	pop    %esi
  800e07:	5f                   	pop    %edi
  800e08:	c9                   	leave  
  800e09:	c3                   	ret    

00800e0a <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  800e0a:	55                   	push   %ebp
  800e0b:	89 e5                	mov    %esp,%ebp
  800e0d:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800e10:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800e13:	50                   	push   %eax
  800e14:	ff 75 08             	pushl  0x8(%ebp)
  800e17:	e8 9b f5 ff ff       	call   8003b7 <fd_lookup>
  800e1c:	83 c4 10             	add    $0x10,%esp
  800e1f:	85 c0                	test   %eax,%eax
  800e21:	78 18                	js     800e3b <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  800e23:	83 ec 0c             	sub    $0xc,%esp
  800e26:	ff 75 f4             	pushl  -0xc(%ebp)
  800e29:	e8 fe f4 ff ff       	call   80032c <fd2data>
	return _pipeisclosed(fd, p);
  800e2e:	89 c2                	mov    %eax,%edx
  800e30:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800e33:	e8 0c fd ff ff       	call   800b44 <_pipeisclosed>
  800e38:	83 c4 10             	add    $0x10,%esp
}
  800e3b:	c9                   	leave  
  800e3c:	c3                   	ret    
  800e3d:	00 00                	add    %al,(%eax)
	...

00800e40 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  800e40:	55                   	push   %ebp
  800e41:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  800e43:	b8 00 00 00 00       	mov    $0x0,%eax
  800e48:	c9                   	leave  
  800e49:	c3                   	ret    

00800e4a <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  800e4a:	55                   	push   %ebp
  800e4b:	89 e5                	mov    %esp,%ebp
  800e4d:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  800e50:	68 b6 1e 80 00       	push   $0x801eb6
  800e55:	ff 75 0c             	pushl  0xc(%ebp)
  800e58:	e8 01 08 00 00       	call   80165e <strcpy>
	return 0;
}
  800e5d:	b8 00 00 00 00       	mov    $0x0,%eax
  800e62:	c9                   	leave  
  800e63:	c3                   	ret    

00800e64 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  800e64:	55                   	push   %ebp
  800e65:	89 e5                	mov    %esp,%ebp
  800e67:	57                   	push   %edi
  800e68:	56                   	push   %esi
  800e69:	53                   	push   %ebx
  800e6a:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800e70:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800e74:	74 45                	je     800ebb <devcons_write+0x57>
  800e76:	b8 00 00 00 00       	mov    $0x0,%eax
  800e7b:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  800e80:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  800e86:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e89:	29 c3                	sub    %eax,%ebx
		if (m > sizeof(buf) - 1)
  800e8b:	83 fb 7f             	cmp    $0x7f,%ebx
  800e8e:	76 05                	jbe    800e95 <devcons_write+0x31>
			m = sizeof(buf) - 1;
  800e90:	bb 7f 00 00 00       	mov    $0x7f,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  800e95:	83 ec 04             	sub    $0x4,%esp
  800e98:	53                   	push   %ebx
  800e99:	03 45 0c             	add    0xc(%ebp),%eax
  800e9c:	50                   	push   %eax
  800e9d:	57                   	push   %edi
  800e9e:	e8 7c 09 00 00       	call   80181f <memmove>
		sys_cputs(buf, m);
  800ea3:	83 c4 08             	add    $0x8,%esp
  800ea6:	53                   	push   %ebx
  800ea7:	57                   	push   %edi
  800ea8:	e8 50 f2 ff ff       	call   8000fd <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800ead:	01 de                	add    %ebx,%esi
  800eaf:	89 f0                	mov    %esi,%eax
  800eb1:	83 c4 10             	add    $0x10,%esp
  800eb4:	3b 75 10             	cmp    0x10(%ebp),%esi
  800eb7:	72 cd                	jb     800e86 <devcons_write+0x22>
  800eb9:	eb 05                	jmp    800ec0 <devcons_write+0x5c>
  800ebb:	be 00 00 00 00       	mov    $0x0,%esi
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  800ec0:	89 f0                	mov    %esi,%eax
  800ec2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ec5:	5b                   	pop    %ebx
  800ec6:	5e                   	pop    %esi
  800ec7:	5f                   	pop    %edi
  800ec8:	c9                   	leave  
  800ec9:	c3                   	ret    

00800eca <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  800eca:	55                   	push   %ebp
  800ecb:	89 e5                	mov    %esp,%ebp
  800ecd:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
  800ed0:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800ed4:	75 07                	jne    800edd <devcons_read+0x13>
  800ed6:	eb 25                	jmp    800efd <devcons_read+0x33>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  800ed8:	e8 b0 f2 ff ff       	call   80018d <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  800edd:	e8 41 f2 ff ff       	call   800123 <sys_cgetc>
  800ee2:	85 c0                	test   %eax,%eax
  800ee4:	74 f2                	je     800ed8 <devcons_read+0xe>
  800ee6:	89 c2                	mov    %eax,%edx
		sys_yield();
	if (c < 0)
  800ee8:	85 c0                	test   %eax,%eax
  800eea:	78 1d                	js     800f09 <devcons_read+0x3f>
		return c;
	if (c == 0x04)	// ctl-d is eof
  800eec:	83 f8 04             	cmp    $0x4,%eax
  800eef:	74 13                	je     800f04 <devcons_read+0x3a>
		return 0;
	*(char*)vbuf = c;
  800ef1:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ef4:	88 10                	mov    %dl,(%eax)
	return 1;
  800ef6:	b8 01 00 00 00       	mov    $0x1,%eax
  800efb:	eb 0c                	jmp    800f09 <devcons_read+0x3f>
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
		return 0;
  800efd:	b8 00 00 00 00       	mov    $0x0,%eax
  800f02:	eb 05                	jmp    800f09 <devcons_read+0x3f>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  800f04:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  800f09:	c9                   	leave  
  800f0a:	c3                   	ret    

00800f0b <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  800f0b:	55                   	push   %ebp
  800f0c:	89 e5                	mov    %esp,%ebp
  800f0e:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  800f11:	8b 45 08             	mov    0x8(%ebp),%eax
  800f14:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  800f17:	6a 01                	push   $0x1
  800f19:	8d 45 f7             	lea    -0x9(%ebp),%eax
  800f1c:	50                   	push   %eax
  800f1d:	e8 db f1 ff ff       	call   8000fd <sys_cputs>
  800f22:	83 c4 10             	add    $0x10,%esp
}
  800f25:	c9                   	leave  
  800f26:	c3                   	ret    

00800f27 <getchar>:

int
getchar(void)
{
  800f27:	55                   	push   %ebp
  800f28:	89 e5                	mov    %esp,%ebp
  800f2a:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  800f2d:	6a 01                	push   $0x1
  800f2f:	8d 45 f7             	lea    -0x9(%ebp),%eax
  800f32:	50                   	push   %eax
  800f33:	6a 00                	push   $0x0
  800f35:	e8 fe f6 ff ff       	call   800638 <read>
	if (r < 0)
  800f3a:	83 c4 10             	add    $0x10,%esp
  800f3d:	85 c0                	test   %eax,%eax
  800f3f:	78 0f                	js     800f50 <getchar+0x29>
		return r;
	if (r < 1)
  800f41:	85 c0                	test   %eax,%eax
  800f43:	7e 06                	jle    800f4b <getchar+0x24>
		return -E_EOF;
	return c;
  800f45:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  800f49:	eb 05                	jmp    800f50 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  800f4b:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  800f50:	c9                   	leave  
  800f51:	c3                   	ret    

00800f52 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  800f52:	55                   	push   %ebp
  800f53:	89 e5                	mov    %esp,%ebp
  800f55:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800f58:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800f5b:	50                   	push   %eax
  800f5c:	ff 75 08             	pushl  0x8(%ebp)
  800f5f:	e8 53 f4 ff ff       	call   8003b7 <fd_lookup>
  800f64:	83 c4 10             	add    $0x10,%esp
  800f67:	85 c0                	test   %eax,%eax
  800f69:	78 11                	js     800f7c <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  800f6b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800f6e:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  800f74:	39 10                	cmp    %edx,(%eax)
  800f76:	0f 94 c0             	sete   %al
  800f79:	0f b6 c0             	movzbl %al,%eax
}
  800f7c:	c9                   	leave  
  800f7d:	c3                   	ret    

00800f7e <opencons>:

int
opencons(void)
{
  800f7e:	55                   	push   %ebp
  800f7f:	89 e5                	mov    %esp,%ebp
  800f81:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  800f84:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800f87:	50                   	push   %eax
  800f88:	e8 b7 f3 ff ff       	call   800344 <fd_alloc>
  800f8d:	83 c4 10             	add    $0x10,%esp
  800f90:	85 c0                	test   %eax,%eax
  800f92:	78 3a                	js     800fce <opencons+0x50>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  800f94:	83 ec 04             	sub    $0x4,%esp
  800f97:	68 07 04 00 00       	push   $0x407
  800f9c:	ff 75 f4             	pushl  -0xc(%ebp)
  800f9f:	6a 00                	push   $0x0
  800fa1:	e8 0e f2 ff ff       	call   8001b4 <sys_page_alloc>
  800fa6:	83 c4 10             	add    $0x10,%esp
  800fa9:	85 c0                	test   %eax,%eax
  800fab:	78 21                	js     800fce <opencons+0x50>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  800fad:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  800fb3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800fb6:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  800fb8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800fbb:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  800fc2:	83 ec 0c             	sub    $0xc,%esp
  800fc5:	50                   	push   %eax
  800fc6:	e8 51 f3 ff ff       	call   80031c <fd2num>
  800fcb:	83 c4 10             	add    $0x10,%esp
}
  800fce:	c9                   	leave  
  800fcf:	c3                   	ret    

00800fd0 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800fd0:	55                   	push   %ebp
  800fd1:	89 e5                	mov    %esp,%ebp
  800fd3:	56                   	push   %esi
  800fd4:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800fd5:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800fd8:	8b 1d 00 30 80 00    	mov    0x803000,%ebx
  800fde:	e8 86 f1 ff ff       	call   800169 <sys_getenvid>
  800fe3:	83 ec 0c             	sub    $0xc,%esp
  800fe6:	ff 75 0c             	pushl  0xc(%ebp)
  800fe9:	ff 75 08             	pushl  0x8(%ebp)
  800fec:	53                   	push   %ebx
  800fed:	50                   	push   %eax
  800fee:	68 c4 1e 80 00       	push   $0x801ec4
  800ff3:	e8 b0 00 00 00       	call   8010a8 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800ff8:	83 c4 18             	add    $0x18,%esp
  800ffb:	56                   	push   %esi
  800ffc:	ff 75 10             	pushl  0x10(%ebp)
  800fff:	e8 53 00 00 00       	call   801057 <vcprintf>
	cprintf("\n");
  801004:	c7 04 24 af 1e 80 00 	movl   $0x801eaf,(%esp)
  80100b:	e8 98 00 00 00       	call   8010a8 <cprintf>
  801010:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801013:	cc                   	int3   
  801014:	eb fd                	jmp    801013 <_panic+0x43>
	...

00801018 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  801018:	55                   	push   %ebp
  801019:	89 e5                	mov    %esp,%ebp
  80101b:	53                   	push   %ebx
  80101c:	83 ec 04             	sub    $0x4,%esp
  80101f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  801022:	8b 03                	mov    (%ebx),%eax
  801024:	8b 55 08             	mov    0x8(%ebp),%edx
  801027:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  80102b:	40                   	inc    %eax
  80102c:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  80102e:	3d ff 00 00 00       	cmp    $0xff,%eax
  801033:	75 1a                	jne    80104f <putch+0x37>
		sys_cputs(b->buf, b->idx);
  801035:	83 ec 08             	sub    $0x8,%esp
  801038:	68 ff 00 00 00       	push   $0xff
  80103d:	8d 43 08             	lea    0x8(%ebx),%eax
  801040:	50                   	push   %eax
  801041:	e8 b7 f0 ff ff       	call   8000fd <sys_cputs>
		b->idx = 0;
  801046:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80104c:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  80104f:	ff 43 04             	incl   0x4(%ebx)
}
  801052:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801055:	c9                   	leave  
  801056:	c3                   	ret    

00801057 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  801057:	55                   	push   %ebp
  801058:	89 e5                	mov    %esp,%ebp
  80105a:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  801060:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  801067:	00 00 00 
	b.cnt = 0;
  80106a:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  801071:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  801074:	ff 75 0c             	pushl  0xc(%ebp)
  801077:	ff 75 08             	pushl  0x8(%ebp)
  80107a:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  801080:	50                   	push   %eax
  801081:	68 18 10 80 00       	push   $0x801018
  801086:	e8 82 01 00 00       	call   80120d <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80108b:	83 c4 08             	add    $0x8,%esp
  80108e:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  801094:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80109a:	50                   	push   %eax
  80109b:	e8 5d f0 ff ff       	call   8000fd <sys_cputs>

	return b.cnt;
}
  8010a0:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8010a6:	c9                   	leave  
  8010a7:	c3                   	ret    

008010a8 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8010a8:	55                   	push   %ebp
  8010a9:	89 e5                	mov    %esp,%ebp
  8010ab:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8010ae:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8010b1:	50                   	push   %eax
  8010b2:	ff 75 08             	pushl  0x8(%ebp)
  8010b5:	e8 9d ff ff ff       	call   801057 <vcprintf>
	va_end(ap);

	return cnt;
}
  8010ba:	c9                   	leave  
  8010bb:	c3                   	ret    

008010bc <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8010bc:	55                   	push   %ebp
  8010bd:	89 e5                	mov    %esp,%ebp
  8010bf:	57                   	push   %edi
  8010c0:	56                   	push   %esi
  8010c1:	53                   	push   %ebx
  8010c2:	83 ec 2c             	sub    $0x2c,%esp
  8010c5:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8010c8:	89 d6                	mov    %edx,%esi
  8010ca:	8b 45 08             	mov    0x8(%ebp),%eax
  8010cd:	8b 55 0c             	mov    0xc(%ebp),%edx
  8010d0:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8010d3:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8010d6:	8b 45 10             	mov    0x10(%ebp),%eax
  8010d9:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8010dc:	8b 7d 18             	mov    0x18(%ebp),%edi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8010df:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8010e2:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  8010e9:	39 55 d4             	cmp    %edx,-0x2c(%ebp)
  8010ec:	72 0c                	jb     8010fa <printnum+0x3e>
  8010ee:	3b 45 d8             	cmp    -0x28(%ebp),%eax
  8010f1:	76 07                	jbe    8010fa <printnum+0x3e>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8010f3:	4b                   	dec    %ebx
  8010f4:	85 db                	test   %ebx,%ebx
  8010f6:	7f 31                	jg     801129 <printnum+0x6d>
  8010f8:	eb 3f                	jmp    801139 <printnum+0x7d>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8010fa:	83 ec 0c             	sub    $0xc,%esp
  8010fd:	57                   	push   %edi
  8010fe:	4b                   	dec    %ebx
  8010ff:	53                   	push   %ebx
  801100:	50                   	push   %eax
  801101:	83 ec 08             	sub    $0x8,%esp
  801104:	ff 75 d4             	pushl  -0x2c(%ebp)
  801107:	ff 75 d0             	pushl  -0x30(%ebp)
  80110a:	ff 75 dc             	pushl  -0x24(%ebp)
  80110d:	ff 75 d8             	pushl  -0x28(%ebp)
  801110:	e8 33 0a 00 00       	call   801b48 <__udivdi3>
  801115:	83 c4 18             	add    $0x18,%esp
  801118:	52                   	push   %edx
  801119:	50                   	push   %eax
  80111a:	89 f2                	mov    %esi,%edx
  80111c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80111f:	e8 98 ff ff ff       	call   8010bc <printnum>
  801124:	83 c4 20             	add    $0x20,%esp
  801127:	eb 10                	jmp    801139 <printnum+0x7d>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  801129:	83 ec 08             	sub    $0x8,%esp
  80112c:	56                   	push   %esi
  80112d:	57                   	push   %edi
  80112e:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  801131:	4b                   	dec    %ebx
  801132:	83 c4 10             	add    $0x10,%esp
  801135:	85 db                	test   %ebx,%ebx
  801137:	7f f0                	jg     801129 <printnum+0x6d>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  801139:	83 ec 08             	sub    $0x8,%esp
  80113c:	56                   	push   %esi
  80113d:	83 ec 04             	sub    $0x4,%esp
  801140:	ff 75 d4             	pushl  -0x2c(%ebp)
  801143:	ff 75 d0             	pushl  -0x30(%ebp)
  801146:	ff 75 dc             	pushl  -0x24(%ebp)
  801149:	ff 75 d8             	pushl  -0x28(%ebp)
  80114c:	e8 13 0b 00 00       	call   801c64 <__umoddi3>
  801151:	83 c4 14             	add    $0x14,%esp
  801154:	0f be 80 e7 1e 80 00 	movsbl 0x801ee7(%eax),%eax
  80115b:	50                   	push   %eax
  80115c:	ff 55 e4             	call   *-0x1c(%ebp)
  80115f:	83 c4 10             	add    $0x10,%esp
}
  801162:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801165:	5b                   	pop    %ebx
  801166:	5e                   	pop    %esi
  801167:	5f                   	pop    %edi
  801168:	c9                   	leave  
  801169:	c3                   	ret    

0080116a <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80116a:	55                   	push   %ebp
  80116b:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80116d:	83 fa 01             	cmp    $0x1,%edx
  801170:	7e 0e                	jle    801180 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  801172:	8b 10                	mov    (%eax),%edx
  801174:	8d 4a 08             	lea    0x8(%edx),%ecx
  801177:	89 08                	mov    %ecx,(%eax)
  801179:	8b 02                	mov    (%edx),%eax
  80117b:	8b 52 04             	mov    0x4(%edx),%edx
  80117e:	eb 22                	jmp    8011a2 <getuint+0x38>
	else if (lflag)
  801180:	85 d2                	test   %edx,%edx
  801182:	74 10                	je     801194 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  801184:	8b 10                	mov    (%eax),%edx
  801186:	8d 4a 04             	lea    0x4(%edx),%ecx
  801189:	89 08                	mov    %ecx,(%eax)
  80118b:	8b 02                	mov    (%edx),%eax
  80118d:	ba 00 00 00 00       	mov    $0x0,%edx
  801192:	eb 0e                	jmp    8011a2 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  801194:	8b 10                	mov    (%eax),%edx
  801196:	8d 4a 04             	lea    0x4(%edx),%ecx
  801199:	89 08                	mov    %ecx,(%eax)
  80119b:	8b 02                	mov    (%edx),%eax
  80119d:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8011a2:	c9                   	leave  
  8011a3:	c3                   	ret    

008011a4 <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
  8011a4:	55                   	push   %ebp
  8011a5:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8011a7:	83 fa 01             	cmp    $0x1,%edx
  8011aa:	7e 0e                	jle    8011ba <getint+0x16>
		return va_arg(*ap, long long);
  8011ac:	8b 10                	mov    (%eax),%edx
  8011ae:	8d 4a 08             	lea    0x8(%edx),%ecx
  8011b1:	89 08                	mov    %ecx,(%eax)
  8011b3:	8b 02                	mov    (%edx),%eax
  8011b5:	8b 52 04             	mov    0x4(%edx),%edx
  8011b8:	eb 1a                	jmp    8011d4 <getint+0x30>
	else if (lflag)
  8011ba:	85 d2                	test   %edx,%edx
  8011bc:	74 0c                	je     8011ca <getint+0x26>
		return va_arg(*ap, long);
  8011be:	8b 10                	mov    (%eax),%edx
  8011c0:	8d 4a 04             	lea    0x4(%edx),%ecx
  8011c3:	89 08                	mov    %ecx,(%eax)
  8011c5:	8b 02                	mov    (%edx),%eax
  8011c7:	99                   	cltd   
  8011c8:	eb 0a                	jmp    8011d4 <getint+0x30>
	else
		return va_arg(*ap, int);
  8011ca:	8b 10                	mov    (%eax),%edx
  8011cc:	8d 4a 04             	lea    0x4(%edx),%ecx
  8011cf:	89 08                	mov    %ecx,(%eax)
  8011d1:	8b 02                	mov    (%edx),%eax
  8011d3:	99                   	cltd   
}
  8011d4:	c9                   	leave  
  8011d5:	c3                   	ret    

008011d6 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8011d6:	55                   	push   %ebp
  8011d7:	89 e5                	mov    %esp,%ebp
  8011d9:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8011dc:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  8011df:	8b 10                	mov    (%eax),%edx
  8011e1:	3b 50 04             	cmp    0x4(%eax),%edx
  8011e4:	73 08                	jae    8011ee <sprintputch+0x18>
		*b->buf++ = ch;
  8011e6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8011e9:	88 0a                	mov    %cl,(%edx)
  8011eb:	42                   	inc    %edx
  8011ec:	89 10                	mov    %edx,(%eax)
}
  8011ee:	c9                   	leave  
  8011ef:	c3                   	ret    

008011f0 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8011f0:	55                   	push   %ebp
  8011f1:	89 e5                	mov    %esp,%ebp
  8011f3:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8011f6:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8011f9:	50                   	push   %eax
  8011fa:	ff 75 10             	pushl  0x10(%ebp)
  8011fd:	ff 75 0c             	pushl  0xc(%ebp)
  801200:	ff 75 08             	pushl  0x8(%ebp)
  801203:	e8 05 00 00 00       	call   80120d <vprintfmt>
	va_end(ap);
  801208:	83 c4 10             	add    $0x10,%esp
}
  80120b:	c9                   	leave  
  80120c:	c3                   	ret    

0080120d <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80120d:	55                   	push   %ebp
  80120e:	89 e5                	mov    %esp,%ebp
  801210:	57                   	push   %edi
  801211:	56                   	push   %esi
  801212:	53                   	push   %ebx
  801213:	83 ec 2c             	sub    $0x2c,%esp
  801216:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801219:	8b 75 10             	mov    0x10(%ebp),%esi
  80121c:	eb 13                	jmp    801231 <vprintfmt+0x24>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  80121e:	85 c0                	test   %eax,%eax
  801220:	0f 84 6d 03 00 00    	je     801593 <vprintfmt+0x386>
				return;
			putch(ch, putdat);
  801226:	83 ec 08             	sub    $0x8,%esp
  801229:	57                   	push   %edi
  80122a:	50                   	push   %eax
  80122b:	ff 55 08             	call   *0x8(%ebp)
  80122e:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  801231:	0f b6 06             	movzbl (%esi),%eax
  801234:	46                   	inc    %esi
  801235:	83 f8 25             	cmp    $0x25,%eax
  801238:	75 e4                	jne    80121e <vprintfmt+0x11>
  80123a:	c6 45 dc 20          	movb   $0x20,-0x24(%ebp)
  80123e:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  801245:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
  80124c:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  801253:	b9 00 00 00 00       	mov    $0x0,%ecx
  801258:	eb 28                	jmp    801282 <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80125a:	89 de                	mov    %ebx,%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  80125c:	c6 45 dc 2d          	movb   $0x2d,-0x24(%ebp)
  801260:	eb 20                	jmp    801282 <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801262:	89 de                	mov    %ebx,%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  801264:	c6 45 dc 30          	movb   $0x30,-0x24(%ebp)
  801268:	eb 18                	jmp    801282 <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80126a:	89 de                	mov    %ebx,%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  80126c:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  801273:	eb 0d                	jmp    801282 <vprintfmt+0x75>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  801275:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  801278:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80127b:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801282:	8a 06                	mov    (%esi),%al
  801284:	0f b6 d0             	movzbl %al,%edx
  801287:	8d 5e 01             	lea    0x1(%esi),%ebx
  80128a:	83 e8 23             	sub    $0x23,%eax
  80128d:	3c 55                	cmp    $0x55,%al
  80128f:	0f 87 e0 02 00 00    	ja     801575 <vprintfmt+0x368>
  801295:	0f b6 c0             	movzbl %al,%eax
  801298:	ff 24 85 20 20 80 00 	jmp    *0x802020(,%eax,4)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80129f:	83 ea 30             	sub    $0x30,%edx
  8012a2:	89 55 d4             	mov    %edx,-0x2c(%ebp)
				ch = *fmt;
  8012a5:	0f be 03             	movsbl (%ebx),%eax
				if (ch < '0' || ch > '9')
  8012a8:	8d 50 d0             	lea    -0x30(%eax),%edx
  8012ab:	83 fa 09             	cmp    $0x9,%edx
  8012ae:	77 44                	ja     8012f4 <vprintfmt+0xe7>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8012b0:	89 de                	mov    %ebx,%esi
  8012b2:	8b 55 d4             	mov    -0x2c(%ebp),%edx
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8012b5:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
  8012b6:	8d 14 92             	lea    (%edx,%edx,4),%edx
  8012b9:	8d 54 50 d0          	lea    -0x30(%eax,%edx,2),%edx
				ch = *fmt;
  8012bd:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  8012c0:	8d 58 d0             	lea    -0x30(%eax),%ebx
  8012c3:	83 fb 09             	cmp    $0x9,%ebx
  8012c6:	76 ed                	jbe    8012b5 <vprintfmt+0xa8>
  8012c8:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  8012cb:	eb 29                	jmp    8012f6 <vprintfmt+0xe9>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8012cd:	8b 45 14             	mov    0x14(%ebp),%eax
  8012d0:	8d 50 04             	lea    0x4(%eax),%edx
  8012d3:	89 55 14             	mov    %edx,0x14(%ebp)
  8012d6:	8b 00                	mov    (%eax),%eax
  8012d8:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8012db:	89 de                	mov    %ebx,%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8012dd:	eb 17                	jmp    8012f6 <vprintfmt+0xe9>

		case '.':
			if (width < 0)
  8012df:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8012e3:	78 85                	js     80126a <vprintfmt+0x5d>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8012e5:	89 de                	mov    %ebx,%esi
  8012e7:	eb 99                	jmp    801282 <vprintfmt+0x75>
  8012e9:	89 de                	mov    %ebx,%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8012eb:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
			goto reswitch;
  8012f2:	eb 8e                	jmp    801282 <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8012f4:	89 de                	mov    %ebx,%esi
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  8012f6:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8012fa:	79 86                	jns    801282 <vprintfmt+0x75>
  8012fc:	e9 74 ff ff ff       	jmp    801275 <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  801301:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801302:	89 de                	mov    %ebx,%esi
  801304:	e9 79 ff ff ff       	jmp    801282 <vprintfmt+0x75>
  801309:	89 5d d8             	mov    %ebx,-0x28(%ebp)
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80130c:	8b 45 14             	mov    0x14(%ebp),%eax
  80130f:	8d 50 04             	lea    0x4(%eax),%edx
  801312:	89 55 14             	mov    %edx,0x14(%ebp)
  801315:	83 ec 08             	sub    $0x8,%esp
  801318:	57                   	push   %edi
  801319:	ff 30                	pushl  (%eax)
  80131b:	ff 55 08             	call   *0x8(%ebp)
			break;
  80131e:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801321:	8b 75 d8             	mov    -0x28(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  801324:	e9 08 ff ff ff       	jmp    801231 <vprintfmt+0x24>
  801329:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// error message
		case 'e':
			err = va_arg(ap, int);
  80132c:	8b 45 14             	mov    0x14(%ebp),%eax
  80132f:	8d 50 04             	lea    0x4(%eax),%edx
  801332:	89 55 14             	mov    %edx,0x14(%ebp)
  801335:	8b 00                	mov    (%eax),%eax
  801337:	85 c0                	test   %eax,%eax
  801339:	79 02                	jns    80133d <vprintfmt+0x130>
  80133b:	f7 d8                	neg    %eax
  80133d:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80133f:	83 f8 0f             	cmp    $0xf,%eax
  801342:	7f 0b                	jg     80134f <vprintfmt+0x142>
  801344:	8b 04 85 80 21 80 00 	mov    0x802180(,%eax,4),%eax
  80134b:	85 c0                	test   %eax,%eax
  80134d:	75 1a                	jne    801369 <vprintfmt+0x15c>
				printfmt(putch, putdat, "error %d", err);
  80134f:	52                   	push   %edx
  801350:	68 ff 1e 80 00       	push   $0x801eff
  801355:	57                   	push   %edi
  801356:	ff 75 08             	pushl  0x8(%ebp)
  801359:	e8 92 fe ff ff       	call   8011f0 <printfmt>
  80135e:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801361:	8b 75 d8             	mov    -0x28(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  801364:	e9 c8 fe ff ff       	jmp    801231 <vprintfmt+0x24>
			else
				printfmt(putch, putdat, "%s", p);
  801369:	50                   	push   %eax
  80136a:	68 7d 1e 80 00       	push   $0x801e7d
  80136f:	57                   	push   %edi
  801370:	ff 75 08             	pushl  0x8(%ebp)
  801373:	e8 78 fe ff ff       	call   8011f0 <printfmt>
  801378:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80137b:	8b 75 d8             	mov    -0x28(%ebp),%esi
  80137e:	e9 ae fe ff ff       	jmp    801231 <vprintfmt+0x24>
  801383:	89 5d d8             	mov    %ebx,-0x28(%ebp)
  801386:	89 de                	mov    %ebx,%esi
  801388:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  80138b:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80138e:	8b 45 14             	mov    0x14(%ebp),%eax
  801391:	8d 50 04             	lea    0x4(%eax),%edx
  801394:	89 55 14             	mov    %edx,0x14(%ebp)
  801397:	8b 00                	mov    (%eax),%eax
  801399:	89 45 d0             	mov    %eax,-0x30(%ebp)
  80139c:	85 c0                	test   %eax,%eax
  80139e:	75 07                	jne    8013a7 <vprintfmt+0x19a>
				p = "(null)";
  8013a0:	c7 45 d0 f8 1e 80 00 	movl   $0x801ef8,-0x30(%ebp)
			if (width > 0 && padc != '-')
  8013a7:	85 db                	test   %ebx,%ebx
  8013a9:	7e 42                	jle    8013ed <vprintfmt+0x1e0>
  8013ab:	80 7d dc 2d          	cmpb   $0x2d,-0x24(%ebp)
  8013af:	74 3c                	je     8013ed <vprintfmt+0x1e0>
				for (width -= strnlen(p, precision); width > 0; width--)
  8013b1:	83 ec 08             	sub    $0x8,%esp
  8013b4:	51                   	push   %ecx
  8013b5:	ff 75 d0             	pushl  -0x30(%ebp)
  8013b8:	e8 6f 02 00 00       	call   80162c <strnlen>
  8013bd:	29 c3                	sub    %eax,%ebx
  8013bf:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8013c2:	83 c4 10             	add    $0x10,%esp
  8013c5:	85 db                	test   %ebx,%ebx
  8013c7:	7e 24                	jle    8013ed <vprintfmt+0x1e0>
					putch(padc, putdat);
  8013c9:	0f be 5d dc          	movsbl -0x24(%ebp),%ebx
  8013cd:	89 75 dc             	mov    %esi,-0x24(%ebp)
  8013d0:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  8013d3:	83 ec 08             	sub    $0x8,%esp
  8013d6:	57                   	push   %edi
  8013d7:	53                   	push   %ebx
  8013d8:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8013db:	4e                   	dec    %esi
  8013dc:	83 c4 10             	add    $0x10,%esp
  8013df:	85 f6                	test   %esi,%esi
  8013e1:	7f f0                	jg     8013d3 <vprintfmt+0x1c6>
  8013e3:	8b 75 dc             	mov    -0x24(%ebp),%esi
  8013e6:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8013ed:	8b 55 d0             	mov    -0x30(%ebp),%edx
  8013f0:	0f be 02             	movsbl (%edx),%eax
  8013f3:	85 c0                	test   %eax,%eax
  8013f5:	75 47                	jne    80143e <vprintfmt+0x231>
  8013f7:	eb 37                	jmp    801430 <vprintfmt+0x223>
				if (altflag && (ch < ' ' || ch > '~'))
  8013f9:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8013fd:	74 16                	je     801415 <vprintfmt+0x208>
  8013ff:	8d 50 e0             	lea    -0x20(%eax),%edx
  801402:	83 fa 5e             	cmp    $0x5e,%edx
  801405:	76 0e                	jbe    801415 <vprintfmt+0x208>
					putch('?', putdat);
  801407:	83 ec 08             	sub    $0x8,%esp
  80140a:	57                   	push   %edi
  80140b:	6a 3f                	push   $0x3f
  80140d:	ff 55 08             	call   *0x8(%ebp)
  801410:	83 c4 10             	add    $0x10,%esp
  801413:	eb 0b                	jmp    801420 <vprintfmt+0x213>
				else
					putch(ch, putdat);
  801415:	83 ec 08             	sub    $0x8,%esp
  801418:	57                   	push   %edi
  801419:	50                   	push   %eax
  80141a:	ff 55 08             	call   *0x8(%ebp)
  80141d:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  801420:	ff 4d e4             	decl   -0x1c(%ebp)
  801423:	0f be 03             	movsbl (%ebx),%eax
  801426:	85 c0                	test   %eax,%eax
  801428:	74 03                	je     80142d <vprintfmt+0x220>
  80142a:	43                   	inc    %ebx
  80142b:	eb 1b                	jmp    801448 <vprintfmt+0x23b>
  80142d:	8b 75 dc             	mov    -0x24(%ebp),%esi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  801430:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  801434:	7f 1e                	jg     801454 <vprintfmt+0x247>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801436:	8b 75 d8             	mov    -0x28(%ebp),%esi
  801439:	e9 f3 fd ff ff       	jmp    801231 <vprintfmt+0x24>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80143e:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  801441:	43                   	inc    %ebx
  801442:	89 75 dc             	mov    %esi,-0x24(%ebp)
  801445:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  801448:	85 f6                	test   %esi,%esi
  80144a:	78 ad                	js     8013f9 <vprintfmt+0x1ec>
  80144c:	4e                   	dec    %esi
  80144d:	79 aa                	jns    8013f9 <vprintfmt+0x1ec>
  80144f:	8b 75 dc             	mov    -0x24(%ebp),%esi
  801452:	eb dc                	jmp    801430 <vprintfmt+0x223>
  801454:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  801457:	83 ec 08             	sub    $0x8,%esp
  80145a:	57                   	push   %edi
  80145b:	6a 20                	push   $0x20
  80145d:	ff 55 08             	call   *0x8(%ebp)
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  801460:	4b                   	dec    %ebx
  801461:	83 c4 10             	add    $0x10,%esp
  801464:	85 db                	test   %ebx,%ebx
  801466:	7f ef                	jg     801457 <vprintfmt+0x24a>
  801468:	e9 c4 fd ff ff       	jmp    801231 <vprintfmt+0x24>
  80146d:	89 5d d8             	mov    %ebx,-0x28(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  801470:	89 ca                	mov    %ecx,%edx
  801472:	8d 45 14             	lea    0x14(%ebp),%eax
  801475:	e8 2a fd ff ff       	call   8011a4 <getint>
  80147a:	89 c3                	mov    %eax,%ebx
  80147c:	89 d6                	mov    %edx,%esi
			if ((long long) num < 0) {
  80147e:	85 d2                	test   %edx,%edx
  801480:	78 0a                	js     80148c <vprintfmt+0x27f>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  801482:	b8 0a 00 00 00       	mov    $0xa,%eax
  801487:	e9 b0 00 00 00       	jmp    80153c <vprintfmt+0x32f>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  80148c:	83 ec 08             	sub    $0x8,%esp
  80148f:	57                   	push   %edi
  801490:	6a 2d                	push   $0x2d
  801492:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  801495:	f7 db                	neg    %ebx
  801497:	83 d6 00             	adc    $0x0,%esi
  80149a:	f7 de                	neg    %esi
  80149c:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  80149f:	b8 0a 00 00 00       	mov    $0xa,%eax
  8014a4:	e9 93 00 00 00       	jmp    80153c <vprintfmt+0x32f>
  8014a9:	89 5d d8             	mov    %ebx,-0x28(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8014ac:	89 ca                	mov    %ecx,%edx
  8014ae:	8d 45 14             	lea    0x14(%ebp),%eax
  8014b1:	e8 b4 fc ff ff       	call   80116a <getuint>
  8014b6:	89 c3                	mov    %eax,%ebx
  8014b8:	89 d6                	mov    %edx,%esi
			base = 10;
  8014ba:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  8014bf:	eb 7b                	jmp    80153c <vprintfmt+0x32f>
  8014c1:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// (unsigned) octal
		case 'o':
            // (MIT 6.828, lab1, Ex.8)  my code : 
            num = getint(&ap, lflag);
  8014c4:	89 ca                	mov    %ecx,%edx
  8014c6:	8d 45 14             	lea    0x14(%ebp),%eax
  8014c9:	e8 d6 fc ff ff       	call   8011a4 <getint>
  8014ce:	89 c3                	mov    %eax,%ebx
  8014d0:	89 d6                	mov    %edx,%esi
            if ((long long) num < 0) {
  8014d2:	85 d2                	test   %edx,%edx
  8014d4:	78 07                	js     8014dd <vprintfmt+0x2d0>
                putch('-', putdat);
                num = -(long long) num;
            }
            base = 8;
  8014d6:	b8 08 00 00 00       	mov    $0x8,%eax
  8014db:	eb 5f                	jmp    80153c <vprintfmt+0x32f>
		// (unsigned) octal
		case 'o':
            // (MIT 6.828, lab1, Ex.8)  my code : 
            num = getint(&ap, lflag);
            if ((long long) num < 0) {
                putch('-', putdat);
  8014dd:	83 ec 08             	sub    $0x8,%esp
  8014e0:	57                   	push   %edi
  8014e1:	6a 2d                	push   $0x2d
  8014e3:	ff 55 08             	call   *0x8(%ebp)
                num = -(long long) num;
  8014e6:	f7 db                	neg    %ebx
  8014e8:	83 d6 00             	adc    $0x0,%esi
  8014eb:	f7 de                	neg    %esi
  8014ed:	83 c4 10             	add    $0x10,%esp
            }
            base = 8;
  8014f0:	b8 08 00 00 00       	mov    $0x8,%eax
  8014f5:	eb 45                	jmp    80153c <vprintfmt+0x32f>
  8014f7:	89 5d d8             	mov    %ebx,-0x28(%ebp)
            goto number;

        // pointer
		case 'p':
			putch('0', putdat);
  8014fa:	83 ec 08             	sub    $0x8,%esp
  8014fd:	57                   	push   %edi
  8014fe:	6a 30                	push   $0x30
  801500:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  801503:	83 c4 08             	add    $0x8,%esp
  801506:	57                   	push   %edi
  801507:	6a 78                	push   $0x78
  801509:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  80150c:	8b 45 14             	mov    0x14(%ebp),%eax
  80150f:	8d 50 04             	lea    0x4(%eax),%edx
  801512:	89 55 14             	mov    %edx,0x14(%ebp)

        // pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  801515:	8b 18                	mov    (%eax),%ebx
  801517:	be 00 00 00 00       	mov    $0x0,%esi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  80151c:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  80151f:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  801524:	eb 16                	jmp    80153c <vprintfmt+0x32f>
  801526:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  801529:	89 ca                	mov    %ecx,%edx
  80152b:	8d 45 14             	lea    0x14(%ebp),%eax
  80152e:	e8 37 fc ff ff       	call   80116a <getuint>
  801533:	89 c3                	mov    %eax,%ebx
  801535:	89 d6                	mov    %edx,%esi
			base = 16;
  801537:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  80153c:	83 ec 0c             	sub    $0xc,%esp
  80153f:	0f be 55 dc          	movsbl -0x24(%ebp),%edx
  801543:	52                   	push   %edx
  801544:	ff 75 e4             	pushl  -0x1c(%ebp)
  801547:	50                   	push   %eax
  801548:	56                   	push   %esi
  801549:	53                   	push   %ebx
  80154a:	89 fa                	mov    %edi,%edx
  80154c:	8b 45 08             	mov    0x8(%ebp),%eax
  80154f:	e8 68 fb ff ff       	call   8010bc <printnum>
			break;
  801554:	83 c4 20             	add    $0x20,%esp
  801557:	8b 75 d8             	mov    -0x28(%ebp),%esi
  80155a:	e9 d2 fc ff ff       	jmp    801231 <vprintfmt+0x24>
  80155f:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  801562:	83 ec 08             	sub    $0x8,%esp
  801565:	57                   	push   %edi
  801566:	52                   	push   %edx
  801567:	ff 55 08             	call   *0x8(%ebp)
			break;
  80156a:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80156d:	8b 75 d8             	mov    -0x28(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  801570:	e9 bc fc ff ff       	jmp    801231 <vprintfmt+0x24>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  801575:	83 ec 08             	sub    $0x8,%esp
  801578:	57                   	push   %edi
  801579:	6a 25                	push   $0x25
  80157b:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  80157e:	83 c4 10             	add    $0x10,%esp
  801581:	eb 02                	jmp    801585 <vprintfmt+0x378>
  801583:	89 c6                	mov    %eax,%esi
  801585:	8d 46 ff             	lea    -0x1(%esi),%eax
  801588:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  80158c:	75 f5                	jne    801583 <vprintfmt+0x376>
  80158e:	e9 9e fc ff ff       	jmp    801231 <vprintfmt+0x24>
				/* do nothing */;
			break;
		}
	}
}
  801593:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801596:	5b                   	pop    %ebx
  801597:	5e                   	pop    %esi
  801598:	5f                   	pop    %edi
  801599:	c9                   	leave  
  80159a:	c3                   	ret    

0080159b <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80159b:	55                   	push   %ebp
  80159c:	89 e5                	mov    %esp,%ebp
  80159e:	83 ec 18             	sub    $0x18,%esp
  8015a1:	8b 45 08             	mov    0x8(%ebp),%eax
  8015a4:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8015a7:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8015aa:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8015ae:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8015b1:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8015b8:	85 c0                	test   %eax,%eax
  8015ba:	74 26                	je     8015e2 <vsnprintf+0x47>
  8015bc:	85 d2                	test   %edx,%edx
  8015be:	7e 29                	jle    8015e9 <vsnprintf+0x4e>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8015c0:	ff 75 14             	pushl  0x14(%ebp)
  8015c3:	ff 75 10             	pushl  0x10(%ebp)
  8015c6:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8015c9:	50                   	push   %eax
  8015ca:	68 d6 11 80 00       	push   $0x8011d6
  8015cf:	e8 39 fc ff ff       	call   80120d <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8015d4:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8015d7:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8015da:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8015dd:	83 c4 10             	add    $0x10,%esp
  8015e0:	eb 0c                	jmp    8015ee <vsnprintf+0x53>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8015e2:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8015e7:	eb 05                	jmp    8015ee <vsnprintf+0x53>
  8015e9:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8015ee:	c9                   	leave  
  8015ef:	c3                   	ret    

008015f0 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8015f0:	55                   	push   %ebp
  8015f1:	89 e5                	mov    %esp,%ebp
  8015f3:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8015f6:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8015f9:	50                   	push   %eax
  8015fa:	ff 75 10             	pushl  0x10(%ebp)
  8015fd:	ff 75 0c             	pushl  0xc(%ebp)
  801600:	ff 75 08             	pushl  0x8(%ebp)
  801603:	e8 93 ff ff ff       	call   80159b <vsnprintf>
	va_end(ap);

	return rc;
}
  801608:	c9                   	leave  
  801609:	c3                   	ret    
	...

0080160c <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80160c:	55                   	push   %ebp
  80160d:	89 e5                	mov    %esp,%ebp
  80160f:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  801612:	80 3a 00             	cmpb   $0x0,(%edx)
  801615:	74 0e                	je     801625 <strlen+0x19>
  801617:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  80161c:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  80161d:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  801621:	75 f9                	jne    80161c <strlen+0x10>
  801623:	eb 05                	jmp    80162a <strlen+0x1e>
  801625:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  80162a:	c9                   	leave  
  80162b:	c3                   	ret    

0080162c <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80162c:	55                   	push   %ebp
  80162d:	89 e5                	mov    %esp,%ebp
  80162f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801632:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801635:	85 d2                	test   %edx,%edx
  801637:	74 17                	je     801650 <strnlen+0x24>
  801639:	80 39 00             	cmpb   $0x0,(%ecx)
  80163c:	74 19                	je     801657 <strnlen+0x2b>
  80163e:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  801643:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801644:	39 d0                	cmp    %edx,%eax
  801646:	74 14                	je     80165c <strnlen+0x30>
  801648:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  80164c:	75 f5                	jne    801643 <strnlen+0x17>
  80164e:	eb 0c                	jmp    80165c <strnlen+0x30>
  801650:	b8 00 00 00 00       	mov    $0x0,%eax
  801655:	eb 05                	jmp    80165c <strnlen+0x30>
  801657:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  80165c:	c9                   	leave  
  80165d:	c3                   	ret    

0080165e <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80165e:	55                   	push   %ebp
  80165f:	89 e5                	mov    %esp,%ebp
  801661:	53                   	push   %ebx
  801662:	8b 45 08             	mov    0x8(%ebp),%eax
  801665:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  801668:	ba 00 00 00 00       	mov    $0x0,%edx
  80166d:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  801670:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  801673:	42                   	inc    %edx
  801674:	84 c9                	test   %cl,%cl
  801676:	75 f5                	jne    80166d <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  801678:	5b                   	pop    %ebx
  801679:	c9                   	leave  
  80167a:	c3                   	ret    

0080167b <strcat>:

char *
strcat(char *dst, const char *src)
{
  80167b:	55                   	push   %ebp
  80167c:	89 e5                	mov    %esp,%ebp
  80167e:	53                   	push   %ebx
  80167f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  801682:	53                   	push   %ebx
  801683:	e8 84 ff ff ff       	call   80160c <strlen>
  801688:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  80168b:	ff 75 0c             	pushl  0xc(%ebp)
  80168e:	8d 04 03             	lea    (%ebx,%eax,1),%eax
  801691:	50                   	push   %eax
  801692:	e8 c7 ff ff ff       	call   80165e <strcpy>
	return dst;
}
  801697:	89 d8                	mov    %ebx,%eax
  801699:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80169c:	c9                   	leave  
  80169d:	c3                   	ret    

0080169e <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80169e:	55                   	push   %ebp
  80169f:	89 e5                	mov    %esp,%ebp
  8016a1:	56                   	push   %esi
  8016a2:	53                   	push   %ebx
  8016a3:	8b 45 08             	mov    0x8(%ebp),%eax
  8016a6:	8b 55 0c             	mov    0xc(%ebp),%edx
  8016a9:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8016ac:	85 f6                	test   %esi,%esi
  8016ae:	74 15                	je     8016c5 <strncpy+0x27>
  8016b0:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
  8016b5:	8a 1a                	mov    (%edx),%bl
  8016b7:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8016ba:	80 3a 01             	cmpb   $0x1,(%edx)
  8016bd:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8016c0:	41                   	inc    %ecx
  8016c1:	39 ce                	cmp    %ecx,%esi
  8016c3:	77 f0                	ja     8016b5 <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8016c5:	5b                   	pop    %ebx
  8016c6:	5e                   	pop    %esi
  8016c7:	c9                   	leave  
  8016c8:	c3                   	ret    

008016c9 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8016c9:	55                   	push   %ebp
  8016ca:	89 e5                	mov    %esp,%ebp
  8016cc:	57                   	push   %edi
  8016cd:	56                   	push   %esi
  8016ce:	53                   	push   %ebx
  8016cf:	8b 7d 08             	mov    0x8(%ebp),%edi
  8016d2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8016d5:	8b 75 10             	mov    0x10(%ebp),%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8016d8:	85 f6                	test   %esi,%esi
  8016da:	74 32                	je     80170e <strlcpy+0x45>
		while (--size > 0 && *src != '\0')
  8016dc:	83 fe 01             	cmp    $0x1,%esi
  8016df:	74 22                	je     801703 <strlcpy+0x3a>
  8016e1:	8a 0b                	mov    (%ebx),%cl
  8016e3:	84 c9                	test   %cl,%cl
  8016e5:	74 20                	je     801707 <strlcpy+0x3e>
  8016e7:	89 f8                	mov    %edi,%eax
  8016e9:	ba 00 00 00 00       	mov    $0x0,%edx
	}
	return ret;
}

size_t
strlcpy(char *dst, const char *src, size_t size)
  8016ee:	83 ee 02             	sub    $0x2,%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8016f1:	88 08                	mov    %cl,(%eax)
  8016f3:	40                   	inc    %eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8016f4:	39 f2                	cmp    %esi,%edx
  8016f6:	74 11                	je     801709 <strlcpy+0x40>
  8016f8:	8a 4c 13 01          	mov    0x1(%ebx,%edx,1),%cl
  8016fc:	42                   	inc    %edx
  8016fd:	84 c9                	test   %cl,%cl
  8016ff:	75 f0                	jne    8016f1 <strlcpy+0x28>
  801701:	eb 06                	jmp    801709 <strlcpy+0x40>
  801703:	89 f8                	mov    %edi,%eax
  801705:	eb 02                	jmp    801709 <strlcpy+0x40>
  801707:	89 f8                	mov    %edi,%eax
			*dst++ = *src++;
		*dst = '\0';
  801709:	c6 00 00             	movb   $0x0,(%eax)
  80170c:	eb 02                	jmp    801710 <strlcpy+0x47>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80170e:	89 f8                	mov    %edi,%eax
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
		*dst = '\0';
	}
	return dst - dst_in;
  801710:	29 f8                	sub    %edi,%eax
}
  801712:	5b                   	pop    %ebx
  801713:	5e                   	pop    %esi
  801714:	5f                   	pop    %edi
  801715:	c9                   	leave  
  801716:	c3                   	ret    

00801717 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  801717:	55                   	push   %ebp
  801718:	89 e5                	mov    %esp,%ebp
  80171a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80171d:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  801720:	8a 01                	mov    (%ecx),%al
  801722:	84 c0                	test   %al,%al
  801724:	74 10                	je     801736 <strcmp+0x1f>
  801726:	3a 02                	cmp    (%edx),%al
  801728:	75 0c                	jne    801736 <strcmp+0x1f>
		p++, q++;
  80172a:	41                   	inc    %ecx
  80172b:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  80172c:	8a 01                	mov    (%ecx),%al
  80172e:	84 c0                	test   %al,%al
  801730:	74 04                	je     801736 <strcmp+0x1f>
  801732:	3a 02                	cmp    (%edx),%al
  801734:	74 f4                	je     80172a <strcmp+0x13>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  801736:	0f b6 c0             	movzbl %al,%eax
  801739:	0f b6 12             	movzbl (%edx),%edx
  80173c:	29 d0                	sub    %edx,%eax
}
  80173e:	c9                   	leave  
  80173f:	c3                   	ret    

00801740 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  801740:	55                   	push   %ebp
  801741:	89 e5                	mov    %esp,%ebp
  801743:	53                   	push   %ebx
  801744:	8b 55 08             	mov    0x8(%ebp),%edx
  801747:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80174a:	8b 45 10             	mov    0x10(%ebp),%eax
	while (n > 0 && *p && *p == *q)
  80174d:	85 c0                	test   %eax,%eax
  80174f:	74 1b                	je     80176c <strncmp+0x2c>
  801751:	8a 1a                	mov    (%edx),%bl
  801753:	84 db                	test   %bl,%bl
  801755:	74 24                	je     80177b <strncmp+0x3b>
  801757:	3a 19                	cmp    (%ecx),%bl
  801759:	75 20                	jne    80177b <strncmp+0x3b>
  80175b:	48                   	dec    %eax
  80175c:	74 15                	je     801773 <strncmp+0x33>
		n--, p++, q++;
  80175e:	42                   	inc    %edx
  80175f:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  801760:	8a 1a                	mov    (%edx),%bl
  801762:	84 db                	test   %bl,%bl
  801764:	74 15                	je     80177b <strncmp+0x3b>
  801766:	3a 19                	cmp    (%ecx),%bl
  801768:	74 f1                	je     80175b <strncmp+0x1b>
  80176a:	eb 0f                	jmp    80177b <strncmp+0x3b>
		n--, p++, q++;
	if (n == 0)
		return 0;
  80176c:	b8 00 00 00 00       	mov    $0x0,%eax
  801771:	eb 05                	jmp    801778 <strncmp+0x38>
  801773:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  801778:	5b                   	pop    %ebx
  801779:	c9                   	leave  
  80177a:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80177b:	0f b6 02             	movzbl (%edx),%eax
  80177e:	0f b6 11             	movzbl (%ecx),%edx
  801781:	29 d0                	sub    %edx,%eax
  801783:	eb f3                	jmp    801778 <strncmp+0x38>

00801785 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  801785:	55                   	push   %ebp
  801786:	89 e5                	mov    %esp,%ebp
  801788:	8b 45 08             	mov    0x8(%ebp),%eax
  80178b:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  80178e:	8a 10                	mov    (%eax),%dl
  801790:	84 d2                	test   %dl,%dl
  801792:	74 18                	je     8017ac <strchr+0x27>
		if (*s == c)
  801794:	38 ca                	cmp    %cl,%dl
  801796:	75 06                	jne    80179e <strchr+0x19>
  801798:	eb 17                	jmp    8017b1 <strchr+0x2c>
  80179a:	38 ca                	cmp    %cl,%dl
  80179c:	74 13                	je     8017b1 <strchr+0x2c>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  80179e:	40                   	inc    %eax
  80179f:	8a 10                	mov    (%eax),%dl
  8017a1:	84 d2                	test   %dl,%dl
  8017a3:	75 f5                	jne    80179a <strchr+0x15>
		if (*s == c)
			return (char *) s;
	return 0;
  8017a5:	b8 00 00 00 00       	mov    $0x0,%eax
  8017aa:	eb 05                	jmp    8017b1 <strchr+0x2c>
  8017ac:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8017b1:	c9                   	leave  
  8017b2:	c3                   	ret    

008017b3 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8017b3:	55                   	push   %ebp
  8017b4:	89 e5                	mov    %esp,%ebp
  8017b6:	8b 45 08             	mov    0x8(%ebp),%eax
  8017b9:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  8017bc:	8a 10                	mov    (%eax),%dl
  8017be:	84 d2                	test   %dl,%dl
  8017c0:	74 11                	je     8017d3 <strfind+0x20>
		if (*s == c)
  8017c2:	38 ca                	cmp    %cl,%dl
  8017c4:	75 06                	jne    8017cc <strfind+0x19>
  8017c6:	eb 0b                	jmp    8017d3 <strfind+0x20>
  8017c8:	38 ca                	cmp    %cl,%dl
  8017ca:	74 07                	je     8017d3 <strfind+0x20>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  8017cc:	40                   	inc    %eax
  8017cd:	8a 10                	mov    (%eax),%dl
  8017cf:	84 d2                	test   %dl,%dl
  8017d1:	75 f5                	jne    8017c8 <strfind+0x15>
		if (*s == c)
			break;
	return (char *) s;
}
  8017d3:	c9                   	leave  
  8017d4:	c3                   	ret    

008017d5 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8017d5:	55                   	push   %ebp
  8017d6:	89 e5                	mov    %esp,%ebp
  8017d8:	57                   	push   %edi
  8017d9:	56                   	push   %esi
  8017da:	53                   	push   %ebx
  8017db:	8b 7d 08             	mov    0x8(%ebp),%edi
  8017de:	8b 45 0c             	mov    0xc(%ebp),%eax
  8017e1:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8017e4:	85 c9                	test   %ecx,%ecx
  8017e6:	74 30                	je     801818 <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8017e8:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8017ee:	75 25                	jne    801815 <memset+0x40>
  8017f0:	f6 c1 03             	test   $0x3,%cl
  8017f3:	75 20                	jne    801815 <memset+0x40>
		c &= 0xFF;
  8017f5:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8017f8:	89 d3                	mov    %edx,%ebx
  8017fa:	c1 e3 08             	shl    $0x8,%ebx
  8017fd:	89 d6                	mov    %edx,%esi
  8017ff:	c1 e6 18             	shl    $0x18,%esi
  801802:	89 d0                	mov    %edx,%eax
  801804:	c1 e0 10             	shl    $0x10,%eax
  801807:	09 f0                	or     %esi,%eax
  801809:	09 d0                	or     %edx,%eax
  80180b:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  80180d:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  801810:	fc                   	cld    
  801811:	f3 ab                	rep stos %eax,%es:(%edi)
  801813:	eb 03                	jmp    801818 <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  801815:	fc                   	cld    
  801816:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  801818:	89 f8                	mov    %edi,%eax
  80181a:	5b                   	pop    %ebx
  80181b:	5e                   	pop    %esi
  80181c:	5f                   	pop    %edi
  80181d:	c9                   	leave  
  80181e:	c3                   	ret    

0080181f <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  80181f:	55                   	push   %ebp
  801820:	89 e5                	mov    %esp,%ebp
  801822:	57                   	push   %edi
  801823:	56                   	push   %esi
  801824:	8b 45 08             	mov    0x8(%ebp),%eax
  801827:	8b 75 0c             	mov    0xc(%ebp),%esi
  80182a:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  80182d:	39 c6                	cmp    %eax,%esi
  80182f:	73 34                	jae    801865 <memmove+0x46>
  801831:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  801834:	39 d0                	cmp    %edx,%eax
  801836:	73 2d                	jae    801865 <memmove+0x46>
		s += n;
		d += n;
  801838:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80183b:	f6 c2 03             	test   $0x3,%dl
  80183e:	75 1b                	jne    80185b <memmove+0x3c>
  801840:	f7 c7 03 00 00 00    	test   $0x3,%edi
  801846:	75 13                	jne    80185b <memmove+0x3c>
  801848:	f6 c1 03             	test   $0x3,%cl
  80184b:	75 0e                	jne    80185b <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  80184d:	83 ef 04             	sub    $0x4,%edi
  801850:	8d 72 fc             	lea    -0x4(%edx),%esi
  801853:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  801856:	fd                   	std    
  801857:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801859:	eb 07                	jmp    801862 <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  80185b:	4f                   	dec    %edi
  80185c:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  80185f:	fd                   	std    
  801860:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  801862:	fc                   	cld    
  801863:	eb 20                	jmp    801885 <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801865:	f7 c6 03 00 00 00    	test   $0x3,%esi
  80186b:	75 13                	jne    801880 <memmove+0x61>
  80186d:	a8 03                	test   $0x3,%al
  80186f:	75 0f                	jne    801880 <memmove+0x61>
  801871:	f6 c1 03             	test   $0x3,%cl
  801874:	75 0a                	jne    801880 <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  801876:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  801879:	89 c7                	mov    %eax,%edi
  80187b:	fc                   	cld    
  80187c:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80187e:	eb 05                	jmp    801885 <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  801880:	89 c7                	mov    %eax,%edi
  801882:	fc                   	cld    
  801883:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  801885:	5e                   	pop    %esi
  801886:	5f                   	pop    %edi
  801887:	c9                   	leave  
  801888:	c3                   	ret    

00801889 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  801889:	55                   	push   %ebp
  80188a:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  80188c:	ff 75 10             	pushl  0x10(%ebp)
  80188f:	ff 75 0c             	pushl  0xc(%ebp)
  801892:	ff 75 08             	pushl  0x8(%ebp)
  801895:	e8 85 ff ff ff       	call   80181f <memmove>
}
  80189a:	c9                   	leave  
  80189b:	c3                   	ret    

0080189c <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  80189c:	55                   	push   %ebp
  80189d:	89 e5                	mov    %esp,%ebp
  80189f:	57                   	push   %edi
  8018a0:	56                   	push   %esi
  8018a1:	53                   	push   %ebx
  8018a2:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8018a5:	8b 75 0c             	mov    0xc(%ebp),%esi
  8018a8:	8b 7d 10             	mov    0x10(%ebp),%edi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8018ab:	85 ff                	test   %edi,%edi
  8018ad:	74 32                	je     8018e1 <memcmp+0x45>
		if (*s1 != *s2)
  8018af:	8a 03                	mov    (%ebx),%al
  8018b1:	8a 0e                	mov    (%esi),%cl
  8018b3:	38 c8                	cmp    %cl,%al
  8018b5:	74 19                	je     8018d0 <memcmp+0x34>
  8018b7:	eb 0d                	jmp    8018c6 <memcmp+0x2a>
  8018b9:	8a 44 13 01          	mov    0x1(%ebx,%edx,1),%al
  8018bd:	8a 4c 16 01          	mov    0x1(%esi,%edx,1),%cl
  8018c1:	42                   	inc    %edx
  8018c2:	38 c8                	cmp    %cl,%al
  8018c4:	74 10                	je     8018d6 <memcmp+0x3a>
			return (int) *s1 - (int) *s2;
  8018c6:	0f b6 c0             	movzbl %al,%eax
  8018c9:	0f b6 c9             	movzbl %cl,%ecx
  8018cc:	29 c8                	sub    %ecx,%eax
  8018ce:	eb 16                	jmp    8018e6 <memcmp+0x4a>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8018d0:	4f                   	dec    %edi
  8018d1:	ba 00 00 00 00       	mov    $0x0,%edx
  8018d6:	39 fa                	cmp    %edi,%edx
  8018d8:	75 df                	jne    8018b9 <memcmp+0x1d>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  8018da:	b8 00 00 00 00       	mov    $0x0,%eax
  8018df:	eb 05                	jmp    8018e6 <memcmp+0x4a>
  8018e1:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8018e6:	5b                   	pop    %ebx
  8018e7:	5e                   	pop    %esi
  8018e8:	5f                   	pop    %edi
  8018e9:	c9                   	leave  
  8018ea:	c3                   	ret    

008018eb <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8018eb:	55                   	push   %ebp
  8018ec:	89 e5                	mov    %esp,%ebp
  8018ee:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  8018f1:	89 c2                	mov    %eax,%edx
  8018f3:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  8018f6:	39 d0                	cmp    %edx,%eax
  8018f8:	73 12                	jae    80190c <memfind+0x21>
		if (*(const unsigned char *) s == (unsigned char) c)
  8018fa:	8a 4d 0c             	mov    0xc(%ebp),%cl
  8018fd:	38 08                	cmp    %cl,(%eax)
  8018ff:	75 06                	jne    801907 <memfind+0x1c>
  801901:	eb 09                	jmp    80190c <memfind+0x21>
  801903:	38 08                	cmp    %cl,(%eax)
  801905:	74 05                	je     80190c <memfind+0x21>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801907:	40                   	inc    %eax
  801908:	39 c2                	cmp    %eax,%edx
  80190a:	77 f7                	ja     801903 <memfind+0x18>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  80190c:	c9                   	leave  
  80190d:	c3                   	ret    

0080190e <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  80190e:	55                   	push   %ebp
  80190f:	89 e5                	mov    %esp,%ebp
  801911:	57                   	push   %edi
  801912:	56                   	push   %esi
  801913:	53                   	push   %ebx
  801914:	8b 55 08             	mov    0x8(%ebp),%edx
  801917:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  80191a:	eb 01                	jmp    80191d <strtol+0xf>
		s++;
  80191c:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  80191d:	8a 02                	mov    (%edx),%al
  80191f:	3c 20                	cmp    $0x20,%al
  801921:	74 f9                	je     80191c <strtol+0xe>
  801923:	3c 09                	cmp    $0x9,%al
  801925:	74 f5                	je     80191c <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  801927:	3c 2b                	cmp    $0x2b,%al
  801929:	75 08                	jne    801933 <strtol+0x25>
		s++;
  80192b:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  80192c:	bf 00 00 00 00       	mov    $0x0,%edi
  801931:	eb 13                	jmp    801946 <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  801933:	3c 2d                	cmp    $0x2d,%al
  801935:	75 0a                	jne    801941 <strtol+0x33>
		s++, neg = 1;
  801937:	8d 52 01             	lea    0x1(%edx),%edx
  80193a:	bf 01 00 00 00       	mov    $0x1,%edi
  80193f:	eb 05                	jmp    801946 <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  801941:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801946:	85 db                	test   %ebx,%ebx
  801948:	74 05                	je     80194f <strtol+0x41>
  80194a:	83 fb 10             	cmp    $0x10,%ebx
  80194d:	75 28                	jne    801977 <strtol+0x69>
  80194f:	8a 02                	mov    (%edx),%al
  801951:	3c 30                	cmp    $0x30,%al
  801953:	75 10                	jne    801965 <strtol+0x57>
  801955:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  801959:	75 0a                	jne    801965 <strtol+0x57>
		s += 2, base = 16;
  80195b:	83 c2 02             	add    $0x2,%edx
  80195e:	bb 10 00 00 00       	mov    $0x10,%ebx
  801963:	eb 12                	jmp    801977 <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  801965:	85 db                	test   %ebx,%ebx
  801967:	75 0e                	jne    801977 <strtol+0x69>
  801969:	3c 30                	cmp    $0x30,%al
  80196b:	75 05                	jne    801972 <strtol+0x64>
		s++, base = 8;
  80196d:	42                   	inc    %edx
  80196e:	b3 08                	mov    $0x8,%bl
  801970:	eb 05                	jmp    801977 <strtol+0x69>
	else if (base == 0)
		base = 10;
  801972:	bb 0a 00 00 00       	mov    $0xa,%ebx
  801977:	b8 00 00 00 00       	mov    $0x0,%eax
  80197c:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  80197e:	8a 0a                	mov    (%edx),%cl
  801980:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  801983:	80 fb 09             	cmp    $0x9,%bl
  801986:	77 08                	ja     801990 <strtol+0x82>
			dig = *s - '0';
  801988:	0f be c9             	movsbl %cl,%ecx
  80198b:	83 e9 30             	sub    $0x30,%ecx
  80198e:	eb 1e                	jmp    8019ae <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  801990:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  801993:	80 fb 19             	cmp    $0x19,%bl
  801996:	77 08                	ja     8019a0 <strtol+0x92>
			dig = *s - 'a' + 10;
  801998:	0f be c9             	movsbl %cl,%ecx
  80199b:	83 e9 57             	sub    $0x57,%ecx
  80199e:	eb 0e                	jmp    8019ae <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  8019a0:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  8019a3:	80 fb 19             	cmp    $0x19,%bl
  8019a6:	77 13                	ja     8019bb <strtol+0xad>
			dig = *s - 'A' + 10;
  8019a8:	0f be c9             	movsbl %cl,%ecx
  8019ab:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  8019ae:	39 f1                	cmp    %esi,%ecx
  8019b0:	7d 0d                	jge    8019bf <strtol+0xb1>
			break;
		s++, val = (val * base) + dig;
  8019b2:	42                   	inc    %edx
  8019b3:	0f af c6             	imul   %esi,%eax
  8019b6:	8d 04 01             	lea    (%ecx,%eax,1),%eax
		// we don't properly detect overflow!
	}
  8019b9:	eb c3                	jmp    80197e <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  8019bb:	89 c1                	mov    %eax,%ecx
  8019bd:	eb 02                	jmp    8019c1 <strtol+0xb3>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  8019bf:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  8019c1:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8019c5:	74 05                	je     8019cc <strtol+0xbe>
		*endptr = (char *) s;
  8019c7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8019ca:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  8019cc:	85 ff                	test   %edi,%edi
  8019ce:	74 04                	je     8019d4 <strtol+0xc6>
  8019d0:	89 c8                	mov    %ecx,%eax
  8019d2:	f7 d8                	neg    %eax
}
  8019d4:	5b                   	pop    %ebx
  8019d5:	5e                   	pop    %esi
  8019d6:	5f                   	pop    %edi
  8019d7:	c9                   	leave  
  8019d8:	c3                   	ret    
  8019d9:	00 00                	add    %al,(%eax)
	...

008019dc <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8019dc:	55                   	push   %ebp
  8019dd:	89 e5                	mov    %esp,%ebp
  8019df:	56                   	push   %esi
  8019e0:	53                   	push   %ebx
  8019e1:	8b 75 08             	mov    0x8(%ebp),%esi
  8019e4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8019e7:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// cprintf("0x%x 0x%x 0x%x\n", (uint32_t)from_env_store, (uint32_t)pg, (uint32_t)perm_store);
	int r;
	if (pg != NULL) {
  8019ea:	85 c0                	test   %eax,%eax
  8019ec:	74 0e                	je     8019fc <ipc_recv+0x20>
		r = sys_ipc_recv(pg);
  8019ee:	83 ec 0c             	sub    $0xc,%esp
  8019f1:	50                   	push   %eax
  8019f2:	e8 b8 e8 ff ff       	call   8002af <sys_ipc_recv>
  8019f7:	83 c4 10             	add    $0x10,%esp
  8019fa:	eb 10                	jmp    801a0c <ipc_recv+0x30>
	} else {
		r = sys_ipc_recv((void *)UTOP);
  8019fc:	83 ec 0c             	sub    $0xc,%esp
  8019ff:	68 00 00 c0 ee       	push   $0xeec00000
  801a04:	e8 a6 e8 ff ff       	call   8002af <sys_ipc_recv>
  801a09:	83 c4 10             	add    $0x10,%esp
	}

	if (r == 0) {
  801a0c:	85 c0                	test   %eax,%eax
  801a0e:	75 26                	jne    801a36 <ipc_recv+0x5a>
		if (from_env_store != NULL) *from_env_store = thisenv->env_ipc_from;
  801a10:	85 f6                	test   %esi,%esi
  801a12:	74 0a                	je     801a1e <ipc_recv+0x42>
  801a14:	a1 04 40 80 00       	mov    0x804004,%eax
  801a19:	8b 40 74             	mov    0x74(%eax),%eax
  801a1c:	89 06                	mov    %eax,(%esi)
		if (perm_store != NULL) *perm_store = thisenv->env_ipc_perm;
  801a1e:	85 db                	test   %ebx,%ebx
  801a20:	74 0a                	je     801a2c <ipc_recv+0x50>
  801a22:	a1 04 40 80 00       	mov    0x804004,%eax
  801a27:	8b 40 78             	mov    0x78(%eax),%eax
  801a2a:	89 03                	mov    %eax,(%ebx)
		return thisenv->env_ipc_value;
  801a2c:	a1 04 40 80 00       	mov    0x804004,%eax
  801a31:	8b 40 70             	mov    0x70(%eax),%eax
  801a34:	eb 14                	jmp    801a4a <ipc_recv+0x6e>
	} else {
		// fails;
		if (from_env_store != NULL) *from_env_store = 0;
  801a36:	85 f6                	test   %esi,%esi
  801a38:	74 06                	je     801a40 <ipc_recv+0x64>
  801a3a:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		if (perm_store != NULL) *perm_store = 0;
  801a40:	85 db                	test   %ebx,%ebx
  801a42:	74 06                	je     801a4a <ipc_recv+0x6e>
  801a44:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
		return r;
	}
}
  801a4a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a4d:	5b                   	pop    %ebx
  801a4e:	5e                   	pop    %esi
  801a4f:	c9                   	leave  
  801a50:	c3                   	ret    

00801a51 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801a51:	55                   	push   %ebp
  801a52:	89 e5                	mov    %esp,%ebp
  801a54:	57                   	push   %edi
  801a55:	56                   	push   %esi
  801a56:	53                   	push   %ebx
  801a57:	83 ec 0c             	sub    $0xc,%esp
  801a5a:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801a5d:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801a60:	8b 75 14             	mov    0x14(%ebp),%esi
	// LAB 4: Your code here.
	// int sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
	int r;
	if (pg == NULL) pg = (void *)UTOP;
  801a63:	85 db                	test   %ebx,%ebx
  801a65:	75 25                	jne    801a8c <ipc_send+0x3b>
  801a67:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
  801a6c:	eb 1e                	jmp    801a8c <ipc_send+0x3b>
	
	while ((r = sys_ipc_try_send(to_env, val, pg, perm)) != 0) {
		if (r == -E_IPC_NOT_RECV) {
  801a6e:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801a71:	75 07                	jne    801a7a <ipc_send+0x29>
			// cprintf("Try Again and Again....\n");
			sys_yield();
  801a73:	e8 15 e7 ff ff       	call   80018d <sys_yield>
  801a78:	eb 12                	jmp    801a8c <ipc_send+0x3b>
		} else {
			panic("ipc_send error %e\n", r);
  801a7a:	50                   	push   %eax
  801a7b:	68 e0 21 80 00       	push   $0x8021e0
  801a80:	6a 43                	push   $0x43
  801a82:	68 f3 21 80 00       	push   $0x8021f3
  801a87:	e8 44 f5 ff ff       	call   800fd0 <_panic>
	// LAB 4: Your code here.
	// int sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
	int r;
	if (pg == NULL) pg = (void *)UTOP;
	
	while ((r = sys_ipc_try_send(to_env, val, pg, perm)) != 0) {
  801a8c:	56                   	push   %esi
  801a8d:	53                   	push   %ebx
  801a8e:	57                   	push   %edi
  801a8f:	ff 75 08             	pushl  0x8(%ebp)
  801a92:	e8 f3 e7 ff ff       	call   80028a <sys_ipc_try_send>
  801a97:	83 c4 10             	add    $0x10,%esp
  801a9a:	85 c0                	test   %eax,%eax
  801a9c:	75 d0                	jne    801a6e <ipc_send+0x1d>
		} else {
			panic("ipc_send error %e\n", r);
		}
	}
	return;
}
  801a9e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801aa1:	5b                   	pop    %ebx
  801aa2:	5e                   	pop    %esi
  801aa3:	5f                   	pop    %edi
  801aa4:	c9                   	leave  
  801aa5:	c3                   	ret    

00801aa6 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801aa6:	55                   	push   %ebp
  801aa7:	89 e5                	mov    %esp,%ebp
  801aa9:	53                   	push   %ebx
  801aaa:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	for (i = 0; i < NENV; i++)
		if (envs[i].env_type == type)
  801aad:	39 1d 50 00 c0 ee    	cmp    %ebx,0xeec00050
  801ab3:	74 22                	je     801ad7 <ipc_find_env+0x31>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801ab5:	b8 01 00 00 00       	mov    $0x1,%eax
		if (envs[i].env_type == type)
  801aba:	8d 0c 85 00 00 00 00 	lea    0x0(,%eax,4),%ecx
  801ac1:	89 c2                	mov    %eax,%edx
  801ac3:	c1 e2 07             	shl    $0x7,%edx
  801ac6:	29 ca                	sub    %ecx,%edx
  801ac8:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801ace:	8b 52 50             	mov    0x50(%edx),%edx
  801ad1:	39 da                	cmp    %ebx,%edx
  801ad3:	75 1d                	jne    801af2 <ipc_find_env+0x4c>
  801ad5:	eb 05                	jmp    801adc <ipc_find_env+0x36>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801ad7:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
			return envs[i].env_id;
  801adc:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  801ae3:	c1 e0 07             	shl    $0x7,%eax
  801ae6:	29 d0                	sub    %edx,%eax
  801ae8:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  801aed:	8b 40 40             	mov    0x40(%eax),%eax
  801af0:	eb 0c                	jmp    801afe <ipc_find_env+0x58>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801af2:	40                   	inc    %eax
  801af3:	3d 00 04 00 00       	cmp    $0x400,%eax
  801af8:	75 c0                	jne    801aba <ipc_find_env+0x14>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801afa:	66 b8 00 00          	mov    $0x0,%ax
}
  801afe:	5b                   	pop    %ebx
  801aff:	c9                   	leave  
  801b00:	c3                   	ret    
  801b01:	00 00                	add    %al,(%eax)
	...

00801b04 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801b04:	55                   	push   %ebp
  801b05:	89 e5                	mov    %esp,%ebp
  801b07:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801b0a:	89 c2                	mov    %eax,%edx
  801b0c:	c1 ea 16             	shr    $0x16,%edx
  801b0f:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801b16:	f6 c2 01             	test   $0x1,%dl
  801b19:	74 1e                	je     801b39 <pageref+0x35>
		return 0;
	pte = uvpt[PGNUM(v)];
  801b1b:	c1 e8 0c             	shr    $0xc,%eax
  801b1e:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  801b25:	a8 01                	test   $0x1,%al
  801b27:	74 17                	je     801b40 <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801b29:	c1 e8 0c             	shr    $0xc,%eax
  801b2c:	66 8b 04 c5 04 00 00 	mov    -0x10fffffc(,%eax,8),%ax
  801b33:	ef 
  801b34:	0f b7 c0             	movzwl %ax,%eax
  801b37:	eb 0c                	jmp    801b45 <pageref+0x41>
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
		return 0;
  801b39:	b8 00 00 00 00       	mov    $0x0,%eax
  801b3e:	eb 05                	jmp    801b45 <pageref+0x41>
	pte = uvpt[PGNUM(v)];
	if (!(pte & PTE_P))
		return 0;
  801b40:	b8 00 00 00 00       	mov    $0x0,%eax
	return pages[PGNUM(pte)].pp_ref;
}
  801b45:	c9                   	leave  
  801b46:	c3                   	ret    
	...

00801b48 <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  801b48:	55                   	push   %ebp
  801b49:	89 e5                	mov    %esp,%ebp
  801b4b:	57                   	push   %edi
  801b4c:	56                   	push   %esi
  801b4d:	83 ec 10             	sub    $0x10,%esp
  801b50:	8b 7d 08             	mov    0x8(%ebp),%edi
  801b53:	8b 4d 10             	mov    0x10(%ebp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  801b56:	89 7d f0             	mov    %edi,-0x10(%ebp)
  801b59:	8b 75 0c             	mov    0xc(%ebp),%esi
  const DWunion dd = {.ll = d};
  801b5c:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  801b5f:	8b 45 14             	mov    0x14(%ebp),%eax
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  801b62:	85 c0                	test   %eax,%eax
  801b64:	75 2e                	jne    801b94 <__udivdi3+0x4c>
    {
      if (d0 > n1)
  801b66:	39 f1                	cmp    %esi,%ecx
  801b68:	77 5a                	ja     801bc4 <__udivdi3+0x7c>
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  801b6a:	85 c9                	test   %ecx,%ecx
  801b6c:	75 0b                	jne    801b79 <__udivdi3+0x31>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  801b6e:	b8 01 00 00 00       	mov    $0x1,%eax
  801b73:	31 d2                	xor    %edx,%edx
  801b75:	f7 f1                	div    %ecx
  801b77:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  801b79:	31 d2                	xor    %edx,%edx
  801b7b:	89 f0                	mov    %esi,%eax
  801b7d:	f7 f1                	div    %ecx
  801b7f:	89 c6                	mov    %eax,%esi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801b81:	89 f8                	mov    %edi,%eax
  801b83:	f7 f1                	div    %ecx
  801b85:	89 c7                	mov    %eax,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  801b87:	89 f8                	mov    %edi,%eax
  801b89:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801b8b:	83 c4 10             	add    $0x10,%esp
  801b8e:	5e                   	pop    %esi
  801b8f:	5f                   	pop    %edi
  801b90:	c9                   	leave  
  801b91:	c3                   	ret    
  801b92:	66 90                	xchg   %ax,%ax
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  801b94:	39 f0                	cmp    %esi,%eax
  801b96:	77 1c                	ja     801bb4 <__udivdi3+0x6c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  801b98:	0f bd f8             	bsr    %eax,%edi
	  if (bm == 0)
  801b9b:	83 f7 1f             	xor    $0x1f,%edi
  801b9e:	75 3c                	jne    801bdc <__udivdi3+0x94>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  801ba0:	39 f0                	cmp    %esi,%eax
  801ba2:	0f 82 90 00 00 00    	jb     801c38 <__udivdi3+0xf0>
  801ba8:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801bab:	39 55 f4             	cmp    %edx,-0xc(%ebp)
  801bae:	0f 86 84 00 00 00    	jbe    801c38 <__udivdi3+0xf0>
  801bb4:	31 f6                	xor    %esi,%esi
  801bb6:	31 ff                	xor    %edi,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  801bb8:	89 f8                	mov    %edi,%eax
  801bba:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801bbc:	83 c4 10             	add    $0x10,%esp
  801bbf:	5e                   	pop    %esi
  801bc0:	5f                   	pop    %edi
  801bc1:	c9                   	leave  
  801bc2:	c3                   	ret    
  801bc3:	90                   	nop
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801bc4:	89 f2                	mov    %esi,%edx
  801bc6:	89 f8                	mov    %edi,%eax
  801bc8:	f7 f1                	div    %ecx
  801bca:	89 c7                	mov    %eax,%edi
  801bcc:	31 f6                	xor    %esi,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  801bce:	89 f8                	mov    %edi,%eax
  801bd0:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801bd2:	83 c4 10             	add    $0x10,%esp
  801bd5:	5e                   	pop    %esi
  801bd6:	5f                   	pop    %edi
  801bd7:	c9                   	leave  
  801bd8:	c3                   	ret    
  801bd9:	8d 76 00             	lea    0x0(%esi),%esi
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  801bdc:	89 f9                	mov    %edi,%ecx
  801bde:	d3 e0                	shl    %cl,%eax
  801be0:	89 45 e8             	mov    %eax,-0x18(%ebp)
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  801be3:	b8 20 00 00 00       	mov    $0x20,%eax
  801be8:	29 f8                	sub    %edi,%eax

	      d1 = (d1 << bm) | (d0 >> b);
  801bea:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801bed:	88 c1                	mov    %al,%cl
  801bef:	d3 ea                	shr    %cl,%edx
  801bf1:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  801bf4:	09 ca                	or     %ecx,%edx
  801bf6:	89 55 ec             	mov    %edx,-0x14(%ebp)
	      d0 = d0 << bm;
  801bf9:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801bfc:	89 f9                	mov    %edi,%ecx
  801bfe:	d3 e2                	shl    %cl,%edx
  801c00:	89 55 f4             	mov    %edx,-0xc(%ebp)
	      n2 = n1 >> b;
  801c03:	89 f2                	mov    %esi,%edx
  801c05:	88 c1                	mov    %al,%cl
  801c07:	d3 ea                	shr    %cl,%edx
  801c09:	89 55 e8             	mov    %edx,-0x18(%ebp)
	      n1 = (n1 << bm) | (n0 >> b);
  801c0c:	89 f2                	mov    %esi,%edx
  801c0e:	89 f9                	mov    %edi,%ecx
  801c10:	d3 e2                	shl    %cl,%edx
  801c12:	8b 75 f0             	mov    -0x10(%ebp),%esi
  801c15:	88 c1                	mov    %al,%cl
  801c17:	d3 ee                	shr    %cl,%esi
  801c19:	09 d6                	or     %edx,%esi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  801c1b:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  801c1e:	89 f0                	mov    %esi,%eax
  801c20:	89 ca                	mov    %ecx,%edx
  801c22:	f7 75 ec             	divl   -0x14(%ebp)
  801c25:	89 d1                	mov    %edx,%ecx
  801c27:	89 c6                	mov    %eax,%esi
	      umul_ppmm (m1, m0, q0, d0);
  801c29:	f7 65 f4             	mull   -0xc(%ebp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801c2c:	39 d1                	cmp    %edx,%ecx
  801c2e:	72 28                	jb     801c58 <__udivdi3+0x110>
  801c30:	74 1a                	je     801c4c <__udivdi3+0x104>
  801c32:	89 f7                	mov    %esi,%edi
  801c34:	31 f6                	xor    %esi,%esi
  801c36:	eb 80                	jmp    801bb8 <__udivdi3+0x70>
	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  801c38:	31 f6                	xor    %esi,%esi
  801c3a:	bf 01 00 00 00       	mov    $0x1,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  801c3f:	89 f8                	mov    %edi,%eax
  801c41:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801c43:	83 c4 10             	add    $0x10,%esp
  801c46:	5e                   	pop    %esi
  801c47:	5f                   	pop    %edi
  801c48:	c9                   	leave  
  801c49:	c3                   	ret    
  801c4a:	66 90                	xchg   %ax,%ax

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  801c4c:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801c4f:	89 f9                	mov    %edi,%ecx
  801c51:	d3 e2                	shl    %cl,%edx

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801c53:	39 c2                	cmp    %eax,%edx
  801c55:	73 db                	jae    801c32 <__udivdi3+0xea>
  801c57:	90                   	nop
		{
		  q0--;
  801c58:	8d 7e ff             	lea    -0x1(%esi),%edi
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  801c5b:	31 f6                	xor    %esi,%esi
  801c5d:	e9 56 ff ff ff       	jmp    801bb8 <__udivdi3+0x70>
	...

00801c64 <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  801c64:	55                   	push   %ebp
  801c65:	89 e5                	mov    %esp,%ebp
  801c67:	57                   	push   %edi
  801c68:	56                   	push   %esi
  801c69:	83 ec 20             	sub    $0x20,%esp
  801c6c:	8b 45 08             	mov    0x8(%ebp),%eax
  801c6f:	8b 4d 10             	mov    0x10(%ebp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  801c72:	89 45 e8             	mov    %eax,-0x18(%ebp)
  801c75:	8b 75 0c             	mov    0xc(%ebp),%esi
  const DWunion dd = {.ll = d};
  801c78:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  801c7b:	8b 7d 14             	mov    0x14(%ebp),%edi
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  801c7e:	89 45 f0             	mov    %eax,-0x10(%ebp)
  n1 = nn.s.high;
  801c81:	89 f2                	mov    %esi,%edx

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  801c83:	85 ff                	test   %edi,%edi
  801c85:	75 15                	jne    801c9c <__umoddi3+0x38>
    {
      if (d0 > n1)
  801c87:	39 f1                	cmp    %esi,%ecx
  801c89:	0f 86 99 00 00 00    	jbe    801d28 <__umoddi3+0xc4>
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801c8f:	f7 f1                	div    %ecx

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
  801c91:	89 d0                	mov    %edx,%eax
  801c93:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  801c95:	83 c4 20             	add    $0x20,%esp
  801c98:	5e                   	pop    %esi
  801c99:	5f                   	pop    %edi
  801c9a:	c9                   	leave  
  801c9b:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  801c9c:	39 f7                	cmp    %esi,%edi
  801c9e:	0f 87 a4 00 00 00    	ja     801d48 <__umoddi3+0xe4>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  801ca4:	0f bd c7             	bsr    %edi,%eax
	  if (bm == 0)
  801ca7:	83 f0 1f             	xor    $0x1f,%eax
  801caa:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801cad:	0f 84 a1 00 00 00    	je     801d54 <__umoddi3+0xf0>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  801cb3:	89 f8                	mov    %edi,%eax
  801cb5:	8a 4d ec             	mov    -0x14(%ebp),%cl
  801cb8:	d3 e0                	shl    %cl,%eax
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  801cba:	bf 20 00 00 00       	mov    $0x20,%edi
  801cbf:	2b 7d ec             	sub    -0x14(%ebp),%edi

	      d1 = (d1 << bm) | (d0 >> b);
  801cc2:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801cc5:	89 f9                	mov    %edi,%ecx
  801cc7:	d3 ea                	shr    %cl,%edx
  801cc9:	09 c2                	or     %eax,%edx
  801ccb:	89 55 f0             	mov    %edx,-0x10(%ebp)
	      d0 = d0 << bm;
  801cce:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801cd1:	8a 4d ec             	mov    -0x14(%ebp),%cl
  801cd4:	d3 e0                	shl    %cl,%eax
  801cd6:	89 45 f4             	mov    %eax,-0xc(%ebp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  801cd9:	89 f2                	mov    %esi,%edx
  801cdb:	d3 e2                	shl    %cl,%edx
	      n0 = n0 << bm;
  801cdd:	8b 45 e8             	mov    -0x18(%ebp),%eax
  801ce0:	d3 e0                	shl    %cl,%eax
  801ce2:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  801ce5:	8b 45 e8             	mov    -0x18(%ebp),%eax
  801ce8:	89 f9                	mov    %edi,%ecx
  801cea:	d3 e8                	shr    %cl,%eax
  801cec:	09 d0                	or     %edx,%eax

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  801cee:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  801cf0:	89 f2                	mov    %esi,%edx
  801cf2:	f7 75 f0             	divl   -0x10(%ebp)
  801cf5:	89 d6                	mov    %edx,%esi
	      umul_ppmm (m1, m0, q0, d0);
  801cf7:	f7 65 f4             	mull   -0xc(%ebp)
  801cfa:	89 55 e8             	mov    %edx,-0x18(%ebp)
  801cfd:	89 c1                	mov    %eax,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801cff:	39 d6                	cmp    %edx,%esi
  801d01:	72 71                	jb     801d74 <__umoddi3+0x110>
  801d03:	74 7f                	je     801d84 <__umoddi3+0x120>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  801d05:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801d08:	29 c8                	sub    %ecx,%eax
  801d0a:	19 d6                	sbb    %edx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
  801d0c:	8a 4d ec             	mov    -0x14(%ebp),%cl
  801d0f:	d3 e8                	shr    %cl,%eax
  801d11:	89 f2                	mov    %esi,%edx
  801d13:	89 f9                	mov    %edi,%ecx
  801d15:	d3 e2                	shl    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
  801d17:	09 d0                	or     %edx,%eax
  801d19:	89 f2                	mov    %esi,%edx
  801d1b:	8a 4d ec             	mov    -0x14(%ebp),%cl
  801d1e:	d3 ea                	shr    %cl,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  801d20:	83 c4 20             	add    $0x20,%esp
  801d23:	5e                   	pop    %esi
  801d24:	5f                   	pop    %edi
  801d25:	c9                   	leave  
  801d26:	c3                   	ret    
  801d27:	90                   	nop
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  801d28:	85 c9                	test   %ecx,%ecx
  801d2a:	75 0b                	jne    801d37 <__umoddi3+0xd3>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  801d2c:	b8 01 00 00 00       	mov    $0x1,%eax
  801d31:	31 d2                	xor    %edx,%edx
  801d33:	f7 f1                	div    %ecx
  801d35:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  801d37:	89 f0                	mov    %esi,%eax
  801d39:	31 d2                	xor    %edx,%edx
  801d3b:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801d3d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801d40:	f7 f1                	div    %ecx
  801d42:	e9 4a ff ff ff       	jmp    801c91 <__umoddi3+0x2d>
  801d47:	90                   	nop
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
  801d48:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  801d4a:	83 c4 20             	add    $0x20,%esp
  801d4d:	5e                   	pop    %esi
  801d4e:	5f                   	pop    %edi
  801d4f:	c9                   	leave  
  801d50:	c3                   	ret    
  801d51:	8d 76 00             	lea    0x0(%esi),%esi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  801d54:	39 f7                	cmp    %esi,%edi
  801d56:	72 05                	jb     801d5d <__umoddi3+0xf9>
  801d58:	3b 4d f0             	cmp    -0x10(%ebp),%ecx
  801d5b:	77 0c                	ja     801d69 <__umoddi3+0x105>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  801d5d:	89 f2                	mov    %esi,%edx
  801d5f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801d62:	29 c8                	sub    %ecx,%eax
  801d64:	19 fa                	sbb    %edi,%edx
  801d66:	89 45 f0             	mov    %eax,-0x10(%ebp)

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
  801d69:	8b 45 f0             	mov    -0x10(%ebp),%eax
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
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  801d74:	8b 55 e8             	mov    -0x18(%ebp),%edx
  801d77:	89 c1                	mov    %eax,%ecx
  801d79:	2b 4d f4             	sub    -0xc(%ebp),%ecx
  801d7c:	1b 55 f0             	sbb    -0x10(%ebp),%edx
  801d7f:	eb 84                	jmp    801d05 <__umoddi3+0xa1>
  801d81:	8d 76 00             	lea    0x0(%esi),%esi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801d84:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  801d87:	72 eb                	jb     801d74 <__umoddi3+0x110>
  801d89:	89 f2                	mov    %esi,%edx
  801d8b:	e9 75 ff ff ff       	jmp    801d05 <__umoddi3+0xa1>
