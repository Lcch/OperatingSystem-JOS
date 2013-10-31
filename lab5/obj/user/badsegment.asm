
obj/user/badsegment.debug:     file format elf32-i386


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
  80002c:	e8 0f 00 00 00       	call   800040 <libmain>
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
	// Try to load the kernel's TSS selector into the DS register.
	asm volatile("movw $0x28,%ax; movw %ax,%ds");
  800037:	66 b8 28 00          	mov    $0x28,%ax
  80003b:	8e d8                	mov    %eax,%ds
}
  80003d:	c9                   	leave  
  80003e:	c3                   	ret    
	...

00800040 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800040:	55                   	push   %ebp
  800041:	89 e5                	mov    %esp,%ebp
  800043:	56                   	push   %esi
  800044:	53                   	push   %ebx
  800045:	8b 75 08             	mov    0x8(%ebp),%esi
  800048:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = envs + ENVX(sys_getenvid());
  80004b:	e8 15 01 00 00       	call   800165 <sys_getenvid>
  800050:	25 ff 03 00 00       	and    $0x3ff,%eax
  800055:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  80005c:	c1 e0 07             	shl    $0x7,%eax
  80005f:	29 d0                	sub    %edx,%eax
  800061:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800066:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80006b:	85 f6                	test   %esi,%esi
  80006d:	7e 07                	jle    800076 <libmain+0x36>
		binaryname = argv[0];
  80006f:	8b 03                	mov    (%ebx),%eax
  800071:	a3 00 30 80 00       	mov    %eax,0x803000
	// call user main routine
	umain(argc, argv);
  800076:	83 ec 08             	sub    $0x8,%esp
  800079:	53                   	push   %ebx
  80007a:	56                   	push   %esi
  80007b:	e8 b4 ff ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  800080:	e8 0b 00 00 00       	call   800090 <exit>
  800085:	83 c4 10             	add    $0x10,%esp
}
  800088:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80008b:	5b                   	pop    %ebx
  80008c:	5e                   	pop    %esi
  80008d:	c9                   	leave  
  80008e:	c3                   	ret    
	...

00800090 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800090:	55                   	push   %ebp
  800091:	89 e5                	mov    %esp,%ebp
  800093:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800096:	e8 5f 04 00 00       	call   8004fa <close_all>
	sys_env_destroy(0);
  80009b:	83 ec 0c             	sub    $0xc,%esp
  80009e:	6a 00                	push   $0x0
  8000a0:	e8 9e 00 00 00       	call   800143 <sys_env_destroy>
  8000a5:	83 c4 10             	add    $0x10,%esp
}
  8000a8:	c9                   	leave  
  8000a9:	c3                   	ret    
	...

008000ac <syscall>:
	return ret;
}

static int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  8000ac:	55                   	push   %ebp
  8000ad:	89 e5                	mov    %esp,%ebp
  8000af:	57                   	push   %edi
  8000b0:	56                   	push   %esi
  8000b1:	53                   	push   %ebx
  8000b2:	83 ec 1c             	sub    $0x1c,%esp
  8000b5:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8000b8:	89 55 e0             	mov    %edx,-0x20(%ebp)
  8000bb:	89 ca                	mov    %ecx,%edx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000bd:	8b 75 14             	mov    0x14(%ebp),%esi
  8000c0:	8b 7d 10             	mov    0x10(%ebp),%edi
  8000c3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8000c6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8000c9:	cd 30                	int    $0x30
  8000cb:	89 c2                	mov    %eax,%edx
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8000cd:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8000d1:	74 1c                	je     8000ef <syscall+0x43>
  8000d3:	85 c0                	test   %eax,%eax
  8000d5:	7e 18                	jle    8000ef <syscall+0x43>
		panic("syscall %d returned %d (> 0)", num, ret);
  8000d7:	83 ec 0c             	sub    $0xc,%esp
  8000da:	50                   	push   %eax
  8000db:	ff 75 e4             	pushl  -0x1c(%ebp)
  8000de:	68 8a 1d 80 00       	push   $0x801d8a
  8000e3:	6a 42                	push   $0x42
  8000e5:	68 a7 1d 80 00       	push   $0x801da7
  8000ea:	e8 b5 0e 00 00       	call   800fa4 <_panic>

	return ret;
}
  8000ef:	89 d0                	mov    %edx,%eax
  8000f1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8000f4:	5b                   	pop    %ebx
  8000f5:	5e                   	pop    %esi
  8000f6:	5f                   	pop    %edi
  8000f7:	c9                   	leave  
  8000f8:	c3                   	ret    

008000f9 <sys_cputs>:

void
sys_cputs(const char *s, size_t len)
{	
  8000f9:	55                   	push   %ebp
  8000fa:	89 e5                	mov    %esp,%ebp
  8000fc:	83 ec 08             	sub    $0x8,%esp
	// my_sysenter(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
	// return;
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
  8000ff:	6a 00                	push   $0x0
  800101:	6a 00                	push   $0x0
  800103:	6a 00                	push   $0x0
  800105:	ff 75 0c             	pushl  0xc(%ebp)
  800108:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80010b:	ba 00 00 00 00       	mov    $0x0,%edx
  800110:	b8 00 00 00 00       	mov    $0x0,%eax
  800115:	e8 92 ff ff ff       	call   8000ac <syscall>
  80011a:	83 c4 10             	add    $0x10,%esp
	return;
}
  80011d:	c9                   	leave  
  80011e:	c3                   	ret    

0080011f <sys_cgetc>:

int
sys_cgetc(void)
{
  80011f:	55                   	push   %ebp
  800120:	89 e5                	mov    %esp,%ebp
  800122:	83 ec 08             	sub    $0x8,%esp
	// return my_sysenter(SYS_cgetc, 0, 0, 0, 0, 0, 0);
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
  800125:	6a 00                	push   $0x0
  800127:	6a 00                	push   $0x0
  800129:	6a 00                	push   $0x0
  80012b:	6a 00                	push   $0x0
  80012d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800132:	ba 00 00 00 00       	mov    $0x0,%edx
  800137:	b8 01 00 00 00       	mov    $0x1,%eax
  80013c:	e8 6b ff ff ff       	call   8000ac <syscall>
}
  800141:	c9                   	leave  
  800142:	c3                   	ret    

00800143 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800143:	55                   	push   %ebp
  800144:	89 e5                	mov    %esp,%ebp
  800146:	83 ec 08             	sub    $0x8,%esp
	// return my_sysenter(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
  800149:	6a 00                	push   $0x0
  80014b:	6a 00                	push   $0x0
  80014d:	6a 00                	push   $0x0
  80014f:	6a 00                	push   $0x0
  800151:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800154:	ba 01 00 00 00       	mov    $0x1,%edx
  800159:	b8 03 00 00 00       	mov    $0x3,%eax
  80015e:	e8 49 ff ff ff       	call   8000ac <syscall>
}
  800163:	c9                   	leave  
  800164:	c3                   	ret    

00800165 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800165:	55                   	push   %ebp
  800166:	89 e5                	mov    %esp,%ebp
  800168:	83 ec 08             	sub    $0x8,%esp
	// return my_sysenter(SYS_getenvid, 0, 0, 0, 0, 0, 0);
	return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
  80016b:	6a 00                	push   $0x0
  80016d:	6a 00                	push   $0x0
  80016f:	6a 00                	push   $0x0
  800171:	6a 00                	push   $0x0
  800173:	b9 00 00 00 00       	mov    $0x0,%ecx
  800178:	ba 00 00 00 00       	mov    $0x0,%edx
  80017d:	b8 02 00 00 00       	mov    $0x2,%eax
  800182:	e8 25 ff ff ff       	call   8000ac <syscall>
}
  800187:	c9                   	leave  
  800188:	c3                   	ret    

00800189 <sys_yield>:

void
sys_yield(void)
{
  800189:	55                   	push   %ebp
  80018a:	89 e5                	mov    %esp,%ebp
  80018c:	83 ec 08             	sub    $0x8,%esp
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
  80018f:	6a 00                	push   $0x0
  800191:	6a 00                	push   $0x0
  800193:	6a 00                	push   $0x0
  800195:	6a 00                	push   $0x0
  800197:	b9 00 00 00 00       	mov    $0x0,%ecx
  80019c:	ba 00 00 00 00       	mov    $0x0,%edx
  8001a1:	b8 0b 00 00 00       	mov    $0xb,%eax
  8001a6:	e8 01 ff ff ff       	call   8000ac <syscall>
  8001ab:	83 c4 10             	add    $0x10,%esp
}
  8001ae:	c9                   	leave  
  8001af:	c3                   	ret    

008001b0 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  8001b0:	55                   	push   %ebp
  8001b1:	89 e5                	mov    %esp,%ebp
  8001b3:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
  8001b6:	6a 00                	push   $0x0
  8001b8:	6a 00                	push   $0x0
  8001ba:	ff 75 10             	pushl  0x10(%ebp)
  8001bd:	ff 75 0c             	pushl  0xc(%ebp)
  8001c0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8001c3:	ba 01 00 00 00       	mov    $0x1,%edx
  8001c8:	b8 04 00 00 00       	mov    $0x4,%eax
  8001cd:	e8 da fe ff ff       	call   8000ac <syscall>
}
  8001d2:	c9                   	leave  
  8001d3:	c3                   	ret    

008001d4 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8001d4:	55                   	push   %ebp
  8001d5:	89 e5                	mov    %esp,%ebp
  8001d7:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
  8001da:	ff 75 18             	pushl  0x18(%ebp)
  8001dd:	ff 75 14             	pushl  0x14(%ebp)
  8001e0:	ff 75 10             	pushl  0x10(%ebp)
  8001e3:	ff 75 0c             	pushl  0xc(%ebp)
  8001e6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8001e9:	ba 01 00 00 00       	mov    $0x1,%edx
  8001ee:	b8 05 00 00 00       	mov    $0x5,%eax
  8001f3:	e8 b4 fe ff ff       	call   8000ac <syscall>
}
  8001f8:	c9                   	leave  
  8001f9:	c3                   	ret    

008001fa <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  8001fa:	55                   	push   %ebp
  8001fb:	89 e5                	mov    %esp,%ebp
  8001fd:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
  800200:	6a 00                	push   $0x0
  800202:	6a 00                	push   $0x0
  800204:	6a 00                	push   $0x0
  800206:	ff 75 0c             	pushl  0xc(%ebp)
  800209:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80020c:	ba 01 00 00 00       	mov    $0x1,%edx
  800211:	b8 06 00 00 00       	mov    $0x6,%eax
  800216:	e8 91 fe ff ff       	call   8000ac <syscall>
}
  80021b:	c9                   	leave  
  80021c:	c3                   	ret    

0080021d <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  80021d:	55                   	push   %ebp
  80021e:	89 e5                	mov    %esp,%ebp
  800220:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
  800223:	6a 00                	push   $0x0
  800225:	6a 00                	push   $0x0
  800227:	6a 00                	push   $0x0
  800229:	ff 75 0c             	pushl  0xc(%ebp)
  80022c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80022f:	ba 01 00 00 00       	mov    $0x1,%edx
  800234:	b8 08 00 00 00       	mov    $0x8,%eax
  800239:	e8 6e fe ff ff       	call   8000ac <syscall>
}
  80023e:	c9                   	leave  
  80023f:	c3                   	ret    

00800240 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800240:	55                   	push   %ebp
  800241:	89 e5                	mov    %esp,%ebp
  800243:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
  800246:	6a 00                	push   $0x0
  800248:	6a 00                	push   $0x0
  80024a:	6a 00                	push   $0x0
  80024c:	ff 75 0c             	pushl  0xc(%ebp)
  80024f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800252:	ba 01 00 00 00       	mov    $0x1,%edx
  800257:	b8 09 00 00 00       	mov    $0x9,%eax
  80025c:	e8 4b fe ff ff       	call   8000ac <syscall>
}
  800261:	c9                   	leave  
  800262:	c3                   	ret    

00800263 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800263:	55                   	push   %ebp
  800264:	89 e5                	mov    %esp,%ebp
  800266:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
  800269:	6a 00                	push   $0x0
  80026b:	6a 00                	push   $0x0
  80026d:	6a 00                	push   $0x0
  80026f:	ff 75 0c             	pushl  0xc(%ebp)
  800272:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800275:	ba 01 00 00 00       	mov    $0x1,%edx
  80027a:	b8 0a 00 00 00       	mov    $0xa,%eax
  80027f:	e8 28 fe ff ff       	call   8000ac <syscall>
}
  800284:	c9                   	leave  
  800285:	c3                   	ret    

00800286 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800286:	55                   	push   %ebp
  800287:	89 e5                	mov    %esp,%ebp
  800289:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
  80028c:	6a 00                	push   $0x0
  80028e:	ff 75 14             	pushl  0x14(%ebp)
  800291:	ff 75 10             	pushl  0x10(%ebp)
  800294:	ff 75 0c             	pushl  0xc(%ebp)
  800297:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80029a:	ba 00 00 00 00       	mov    $0x0,%edx
  80029f:	b8 0c 00 00 00       	mov    $0xc,%eax
  8002a4:	e8 03 fe ff ff       	call   8000ac <syscall>
}
  8002a9:	c9                   	leave  
  8002aa:	c3                   	ret    

008002ab <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  8002ab:	55                   	push   %ebp
  8002ac:	89 e5                	mov    %esp,%ebp
  8002ae:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
  8002b1:	6a 00                	push   $0x0
  8002b3:	6a 00                	push   $0x0
  8002b5:	6a 00                	push   $0x0
  8002b7:	6a 00                	push   $0x0
  8002b9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8002bc:	ba 01 00 00 00       	mov    $0x1,%edx
  8002c1:	b8 0d 00 00 00       	mov    $0xd,%eax
  8002c6:	e8 e1 fd ff ff       	call   8000ac <syscall>
}
  8002cb:	c9                   	leave  
  8002cc:	c3                   	ret    

008002cd <sys_set_priority>:

int
sys_set_priority(envid_t envid, uint32_t new_priority)
{
  8002cd:	55                   	push   %ebp
  8002ce:	89 e5                	mov    %esp,%ebp
  8002d0:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_set_priority, 0, envid, new_priority, 0, 0, 0);
  8002d3:	6a 00                	push   $0x0
  8002d5:	6a 00                	push   $0x0
  8002d7:	6a 00                	push   $0x0
  8002d9:	ff 75 0c             	pushl  0xc(%ebp)
  8002dc:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8002df:	ba 00 00 00 00       	mov    $0x0,%edx
  8002e4:	b8 0e 00 00 00       	mov    $0xe,%eax
  8002e9:	e8 be fd ff ff       	call   8000ac <syscall>
}
  8002ee:	c9                   	leave  
  8002ef:	c3                   	ret    

008002f0 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8002f0:	55                   	push   %ebp
  8002f1:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8002f3:	8b 45 08             	mov    0x8(%ebp),%eax
  8002f6:	05 00 00 00 30       	add    $0x30000000,%eax
  8002fb:	c1 e8 0c             	shr    $0xc,%eax
}
  8002fe:	c9                   	leave  
  8002ff:	c3                   	ret    

00800300 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800300:	55                   	push   %ebp
  800301:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  800303:	ff 75 08             	pushl  0x8(%ebp)
  800306:	e8 e5 ff ff ff       	call   8002f0 <fd2num>
  80030b:	83 c4 04             	add    $0x4,%esp
  80030e:	05 20 00 0d 00       	add    $0xd0020,%eax
  800313:	c1 e0 0c             	shl    $0xc,%eax
}
  800316:	c9                   	leave  
  800317:	c3                   	ret    

00800318 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800318:	55                   	push   %ebp
  800319:	89 e5                	mov    %esp,%ebp
  80031b:	53                   	push   %ebx
  80031c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  80031f:	a1 00 dd 7b ef       	mov    0xef7bdd00,%eax
  800324:	a8 01                	test   $0x1,%al
  800326:	74 34                	je     80035c <fd_alloc+0x44>
  800328:	a1 00 00 74 ef       	mov    0xef740000,%eax
  80032d:	a8 01                	test   $0x1,%al
  80032f:	74 32                	je     800363 <fd_alloc+0x4b>
  800331:	b8 00 10 00 d0       	mov    $0xd0001000,%eax
  800336:	89 c1                	mov    %eax,%ecx
  800338:	89 c2                	mov    %eax,%edx
  80033a:	c1 ea 16             	shr    $0x16,%edx
  80033d:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800344:	f6 c2 01             	test   $0x1,%dl
  800347:	74 1f                	je     800368 <fd_alloc+0x50>
  800349:	89 c2                	mov    %eax,%edx
  80034b:	c1 ea 0c             	shr    $0xc,%edx
  80034e:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800355:	f6 c2 01             	test   $0x1,%dl
  800358:	75 17                	jne    800371 <fd_alloc+0x59>
  80035a:	eb 0c                	jmp    800368 <fd_alloc+0x50>
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  80035c:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
  800361:	eb 05                	jmp    800368 <fd_alloc+0x50>
  800363:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
  800368:	89 0b                	mov    %ecx,(%ebx)
			return 0;
  80036a:	b8 00 00 00 00       	mov    $0x0,%eax
  80036f:	eb 17                	jmp    800388 <fd_alloc+0x70>
  800371:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800376:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  80037b:	75 b9                	jne    800336 <fd_alloc+0x1e>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  80037d:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_MAX_OPEN;
  800383:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800388:	5b                   	pop    %ebx
  800389:	c9                   	leave  
  80038a:	c3                   	ret    

0080038b <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  80038b:	55                   	push   %ebp
  80038c:	89 e5                	mov    %esp,%ebp
  80038e:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800391:	83 f8 1f             	cmp    $0x1f,%eax
  800394:	77 36                	ja     8003cc <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800396:	05 00 00 0d 00       	add    $0xd0000,%eax
  80039b:	c1 e0 0c             	shl    $0xc,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  80039e:	89 c2                	mov    %eax,%edx
  8003a0:	c1 ea 16             	shr    $0x16,%edx
  8003a3:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8003aa:	f6 c2 01             	test   $0x1,%dl
  8003ad:	74 24                	je     8003d3 <fd_lookup+0x48>
  8003af:	89 c2                	mov    %eax,%edx
  8003b1:	c1 ea 0c             	shr    $0xc,%edx
  8003b4:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8003bb:	f6 c2 01             	test   $0x1,%dl
  8003be:	74 1a                	je     8003da <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8003c0:	8b 55 0c             	mov    0xc(%ebp),%edx
  8003c3:	89 02                	mov    %eax,(%edx)
	return 0;
  8003c5:	b8 00 00 00 00       	mov    $0x0,%eax
  8003ca:	eb 13                	jmp    8003df <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8003cc:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8003d1:	eb 0c                	jmp    8003df <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8003d3:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8003d8:	eb 05                	jmp    8003df <fd_lookup+0x54>
  8003da:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  8003df:	c9                   	leave  
  8003e0:	c3                   	ret    

008003e1 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8003e1:	55                   	push   %ebp
  8003e2:	89 e5                	mov    %esp,%ebp
  8003e4:	53                   	push   %ebx
  8003e5:	83 ec 04             	sub    $0x4,%esp
  8003e8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8003eb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
		if (devtab[i]->dev_id == dev_id) {
  8003ee:	39 0d 04 30 80 00    	cmp    %ecx,0x803004
  8003f4:	74 0d                	je     800403 <dev_lookup+0x22>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8003f6:	b8 00 00 00 00       	mov    $0x0,%eax
  8003fb:	eb 14                	jmp    800411 <dev_lookup+0x30>
		if (devtab[i]->dev_id == dev_id) {
  8003fd:	39 0a                	cmp    %ecx,(%edx)
  8003ff:	75 10                	jne    800411 <dev_lookup+0x30>
  800401:	eb 05                	jmp    800408 <dev_lookup+0x27>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800403:	ba 04 30 80 00       	mov    $0x803004,%edx
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
  800408:	89 13                	mov    %edx,(%ebx)
			return 0;
  80040a:	b8 00 00 00 00       	mov    $0x0,%eax
  80040f:	eb 31                	jmp    800442 <dev_lookup+0x61>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800411:	40                   	inc    %eax
  800412:	8b 14 85 34 1e 80 00 	mov    0x801e34(,%eax,4),%edx
  800419:	85 d2                	test   %edx,%edx
  80041b:	75 e0                	jne    8003fd <dev_lookup+0x1c>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  80041d:	a1 04 40 80 00       	mov    0x804004,%eax
  800422:	8b 40 48             	mov    0x48(%eax),%eax
  800425:	83 ec 04             	sub    $0x4,%esp
  800428:	51                   	push   %ecx
  800429:	50                   	push   %eax
  80042a:	68 b8 1d 80 00       	push   $0x801db8
  80042f:	e8 48 0c 00 00       	call   80107c <cprintf>
	*dev = 0;
  800434:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_INVAL;
  80043a:	83 c4 10             	add    $0x10,%esp
  80043d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800442:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800445:	c9                   	leave  
  800446:	c3                   	ret    

00800447 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800447:	55                   	push   %ebp
  800448:	89 e5                	mov    %esp,%ebp
  80044a:	56                   	push   %esi
  80044b:	53                   	push   %ebx
  80044c:	83 ec 20             	sub    $0x20,%esp
  80044f:	8b 75 08             	mov    0x8(%ebp),%esi
  800452:	8a 45 0c             	mov    0xc(%ebp),%al
  800455:	88 45 e7             	mov    %al,-0x19(%ebp)
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800458:	56                   	push   %esi
  800459:	e8 92 fe ff ff       	call   8002f0 <fd2num>
  80045e:	8d 55 f4             	lea    -0xc(%ebp),%edx
  800461:	89 14 24             	mov    %edx,(%esp)
  800464:	50                   	push   %eax
  800465:	e8 21 ff ff ff       	call   80038b <fd_lookup>
  80046a:	89 c3                	mov    %eax,%ebx
  80046c:	83 c4 08             	add    $0x8,%esp
  80046f:	85 c0                	test   %eax,%eax
  800471:	78 05                	js     800478 <fd_close+0x31>
	    || fd != fd2)
  800473:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  800476:	74 0d                	je     800485 <fd_close+0x3e>
		return (must_exist ? r : 0);
  800478:	80 7d e7 00          	cmpb   $0x0,-0x19(%ebp)
  80047c:	75 48                	jne    8004c6 <fd_close+0x7f>
  80047e:	bb 00 00 00 00       	mov    $0x0,%ebx
  800483:	eb 41                	jmp    8004c6 <fd_close+0x7f>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800485:	83 ec 08             	sub    $0x8,%esp
  800488:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80048b:	50                   	push   %eax
  80048c:	ff 36                	pushl  (%esi)
  80048e:	e8 4e ff ff ff       	call   8003e1 <dev_lookup>
  800493:	89 c3                	mov    %eax,%ebx
  800495:	83 c4 10             	add    $0x10,%esp
  800498:	85 c0                	test   %eax,%eax
  80049a:	78 1c                	js     8004b8 <fd_close+0x71>
		if (dev->dev_close)
  80049c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80049f:	8b 40 10             	mov    0x10(%eax),%eax
  8004a2:	85 c0                	test   %eax,%eax
  8004a4:	74 0d                	je     8004b3 <fd_close+0x6c>
			r = (*dev->dev_close)(fd);
  8004a6:	83 ec 0c             	sub    $0xc,%esp
  8004a9:	56                   	push   %esi
  8004aa:	ff d0                	call   *%eax
  8004ac:	89 c3                	mov    %eax,%ebx
  8004ae:	83 c4 10             	add    $0x10,%esp
  8004b1:	eb 05                	jmp    8004b8 <fd_close+0x71>
		else
			r = 0;
  8004b3:	bb 00 00 00 00       	mov    $0x0,%ebx
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8004b8:	83 ec 08             	sub    $0x8,%esp
  8004bb:	56                   	push   %esi
  8004bc:	6a 00                	push   $0x0
  8004be:	e8 37 fd ff ff       	call   8001fa <sys_page_unmap>
	return r;
  8004c3:	83 c4 10             	add    $0x10,%esp
}
  8004c6:	89 d8                	mov    %ebx,%eax
  8004c8:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8004cb:	5b                   	pop    %ebx
  8004cc:	5e                   	pop    %esi
  8004cd:	c9                   	leave  
  8004ce:	c3                   	ret    

008004cf <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8004cf:	55                   	push   %ebp
  8004d0:	89 e5                	mov    %esp,%ebp
  8004d2:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8004d5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8004d8:	50                   	push   %eax
  8004d9:	ff 75 08             	pushl  0x8(%ebp)
  8004dc:	e8 aa fe ff ff       	call   80038b <fd_lookup>
  8004e1:	83 c4 08             	add    $0x8,%esp
  8004e4:	85 c0                	test   %eax,%eax
  8004e6:	78 10                	js     8004f8 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  8004e8:	83 ec 08             	sub    $0x8,%esp
  8004eb:	6a 01                	push   $0x1
  8004ed:	ff 75 f4             	pushl  -0xc(%ebp)
  8004f0:	e8 52 ff ff ff       	call   800447 <fd_close>
  8004f5:	83 c4 10             	add    $0x10,%esp
}
  8004f8:	c9                   	leave  
  8004f9:	c3                   	ret    

008004fa <close_all>:

void
close_all(void)
{
  8004fa:	55                   	push   %ebp
  8004fb:	89 e5                	mov    %esp,%ebp
  8004fd:	53                   	push   %ebx
  8004fe:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800501:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  800506:	83 ec 0c             	sub    $0xc,%esp
  800509:	53                   	push   %ebx
  80050a:	e8 c0 ff ff ff       	call   8004cf <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  80050f:	43                   	inc    %ebx
  800510:	83 c4 10             	add    $0x10,%esp
  800513:	83 fb 20             	cmp    $0x20,%ebx
  800516:	75 ee                	jne    800506 <close_all+0xc>
		close(i);
}
  800518:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80051b:	c9                   	leave  
  80051c:	c3                   	ret    

0080051d <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  80051d:	55                   	push   %ebp
  80051e:	89 e5                	mov    %esp,%ebp
  800520:	57                   	push   %edi
  800521:	56                   	push   %esi
  800522:	53                   	push   %ebx
  800523:	83 ec 2c             	sub    $0x2c,%esp
  800526:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  800529:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80052c:	50                   	push   %eax
  80052d:	ff 75 08             	pushl  0x8(%ebp)
  800530:	e8 56 fe ff ff       	call   80038b <fd_lookup>
  800535:	89 c3                	mov    %eax,%ebx
  800537:	83 c4 08             	add    $0x8,%esp
  80053a:	85 c0                	test   %eax,%eax
  80053c:	0f 88 c0 00 00 00    	js     800602 <dup+0xe5>
		return r;
	close(newfdnum);
  800542:	83 ec 0c             	sub    $0xc,%esp
  800545:	57                   	push   %edi
  800546:	e8 84 ff ff ff       	call   8004cf <close>

	newfd = INDEX2FD(newfdnum);
  80054b:	8d b7 00 00 0d 00    	lea    0xd0000(%edi),%esi
  800551:	c1 e6 0c             	shl    $0xc,%esi
	ova = fd2data(oldfd);
  800554:	83 c4 04             	add    $0x4,%esp
  800557:	ff 75 e4             	pushl  -0x1c(%ebp)
  80055a:	e8 a1 fd ff ff       	call   800300 <fd2data>
  80055f:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  800561:	89 34 24             	mov    %esi,(%esp)
  800564:	e8 97 fd ff ff       	call   800300 <fd2data>
  800569:	83 c4 10             	add    $0x10,%esp
  80056c:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80056f:	89 d8                	mov    %ebx,%eax
  800571:	c1 e8 16             	shr    $0x16,%eax
  800574:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80057b:	a8 01                	test   $0x1,%al
  80057d:	74 37                	je     8005b6 <dup+0x99>
  80057f:	89 d8                	mov    %ebx,%eax
  800581:	c1 e8 0c             	shr    $0xc,%eax
  800584:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80058b:	f6 c2 01             	test   $0x1,%dl
  80058e:	74 26                	je     8005b6 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  800590:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800597:	83 ec 0c             	sub    $0xc,%esp
  80059a:	25 07 0e 00 00       	and    $0xe07,%eax
  80059f:	50                   	push   %eax
  8005a0:	ff 75 d4             	pushl  -0x2c(%ebp)
  8005a3:	6a 00                	push   $0x0
  8005a5:	53                   	push   %ebx
  8005a6:	6a 00                	push   $0x0
  8005a8:	e8 27 fc ff ff       	call   8001d4 <sys_page_map>
  8005ad:	89 c3                	mov    %eax,%ebx
  8005af:	83 c4 20             	add    $0x20,%esp
  8005b2:	85 c0                	test   %eax,%eax
  8005b4:	78 2d                	js     8005e3 <dup+0xc6>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8005b6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8005b9:	89 c2                	mov    %eax,%edx
  8005bb:	c1 ea 0c             	shr    $0xc,%edx
  8005be:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8005c5:	83 ec 0c             	sub    $0xc,%esp
  8005c8:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  8005ce:	52                   	push   %edx
  8005cf:	56                   	push   %esi
  8005d0:	6a 00                	push   $0x0
  8005d2:	50                   	push   %eax
  8005d3:	6a 00                	push   $0x0
  8005d5:	e8 fa fb ff ff       	call   8001d4 <sys_page_map>
  8005da:	89 c3                	mov    %eax,%ebx
  8005dc:	83 c4 20             	add    $0x20,%esp
  8005df:	85 c0                	test   %eax,%eax
  8005e1:	79 1d                	jns    800600 <dup+0xe3>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8005e3:	83 ec 08             	sub    $0x8,%esp
  8005e6:	56                   	push   %esi
  8005e7:	6a 00                	push   $0x0
  8005e9:	e8 0c fc ff ff       	call   8001fa <sys_page_unmap>
	sys_page_unmap(0, nva);
  8005ee:	83 c4 08             	add    $0x8,%esp
  8005f1:	ff 75 d4             	pushl  -0x2c(%ebp)
  8005f4:	6a 00                	push   $0x0
  8005f6:	e8 ff fb ff ff       	call   8001fa <sys_page_unmap>
	return r;
  8005fb:	83 c4 10             	add    $0x10,%esp
  8005fe:	eb 02                	jmp    800602 <dup+0xe5>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
		goto err;

	return newfdnum;
  800600:	89 fb                	mov    %edi,%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  800602:	89 d8                	mov    %ebx,%eax
  800604:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800607:	5b                   	pop    %ebx
  800608:	5e                   	pop    %esi
  800609:	5f                   	pop    %edi
  80060a:	c9                   	leave  
  80060b:	c3                   	ret    

0080060c <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80060c:	55                   	push   %ebp
  80060d:	89 e5                	mov    %esp,%ebp
  80060f:	53                   	push   %ebx
  800610:	83 ec 14             	sub    $0x14,%esp
  800613:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800616:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800619:	50                   	push   %eax
  80061a:	53                   	push   %ebx
  80061b:	e8 6b fd ff ff       	call   80038b <fd_lookup>
  800620:	83 c4 08             	add    $0x8,%esp
  800623:	85 c0                	test   %eax,%eax
  800625:	78 67                	js     80068e <read+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800627:	83 ec 08             	sub    $0x8,%esp
  80062a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80062d:	50                   	push   %eax
  80062e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800631:	ff 30                	pushl  (%eax)
  800633:	e8 a9 fd ff ff       	call   8003e1 <dev_lookup>
  800638:	83 c4 10             	add    $0x10,%esp
  80063b:	85 c0                	test   %eax,%eax
  80063d:	78 4f                	js     80068e <read+0x82>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80063f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800642:	8b 50 08             	mov    0x8(%eax),%edx
  800645:	83 e2 03             	and    $0x3,%edx
  800648:	83 fa 01             	cmp    $0x1,%edx
  80064b:	75 21                	jne    80066e <read+0x62>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80064d:	a1 04 40 80 00       	mov    0x804004,%eax
  800652:	8b 40 48             	mov    0x48(%eax),%eax
  800655:	83 ec 04             	sub    $0x4,%esp
  800658:	53                   	push   %ebx
  800659:	50                   	push   %eax
  80065a:	68 f9 1d 80 00       	push   $0x801df9
  80065f:	e8 18 0a 00 00       	call   80107c <cprintf>
		return -E_INVAL;
  800664:	83 c4 10             	add    $0x10,%esp
  800667:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80066c:	eb 20                	jmp    80068e <read+0x82>
	}
	if (!dev->dev_read)
  80066e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800671:	8b 52 08             	mov    0x8(%edx),%edx
  800674:	85 d2                	test   %edx,%edx
  800676:	74 11                	je     800689 <read+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  800678:	83 ec 04             	sub    $0x4,%esp
  80067b:	ff 75 10             	pushl  0x10(%ebp)
  80067e:	ff 75 0c             	pushl  0xc(%ebp)
  800681:	50                   	push   %eax
  800682:	ff d2                	call   *%edx
  800684:	83 c4 10             	add    $0x10,%esp
  800687:	eb 05                	jmp    80068e <read+0x82>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  800689:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_read)(fd, buf, n);
}
  80068e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800691:	c9                   	leave  
  800692:	c3                   	ret    

00800693 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  800693:	55                   	push   %ebp
  800694:	89 e5                	mov    %esp,%ebp
  800696:	57                   	push   %edi
  800697:	56                   	push   %esi
  800698:	53                   	push   %ebx
  800699:	83 ec 0c             	sub    $0xc,%esp
  80069c:	8b 7d 08             	mov    0x8(%ebp),%edi
  80069f:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8006a2:	85 f6                	test   %esi,%esi
  8006a4:	74 31                	je     8006d7 <readn+0x44>
  8006a6:	b8 00 00 00 00       	mov    $0x0,%eax
  8006ab:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = read(fdnum, (char*)buf + tot, n - tot);
  8006b0:	83 ec 04             	sub    $0x4,%esp
  8006b3:	89 f2                	mov    %esi,%edx
  8006b5:	29 c2                	sub    %eax,%edx
  8006b7:	52                   	push   %edx
  8006b8:	03 45 0c             	add    0xc(%ebp),%eax
  8006bb:	50                   	push   %eax
  8006bc:	57                   	push   %edi
  8006bd:	e8 4a ff ff ff       	call   80060c <read>
		if (m < 0)
  8006c2:	83 c4 10             	add    $0x10,%esp
  8006c5:	85 c0                	test   %eax,%eax
  8006c7:	78 17                	js     8006e0 <readn+0x4d>
			return m;
		if (m == 0)
  8006c9:	85 c0                	test   %eax,%eax
  8006cb:	74 11                	je     8006de <readn+0x4b>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8006cd:	01 c3                	add    %eax,%ebx
  8006cf:	89 d8                	mov    %ebx,%eax
  8006d1:	39 f3                	cmp    %esi,%ebx
  8006d3:	72 db                	jb     8006b0 <readn+0x1d>
  8006d5:	eb 09                	jmp    8006e0 <readn+0x4d>
  8006d7:	b8 00 00 00 00       	mov    $0x0,%eax
  8006dc:	eb 02                	jmp    8006e0 <readn+0x4d>
		m = read(fdnum, (char*)buf + tot, n - tot);
		if (m < 0)
			return m;
		if (m == 0)
  8006de:	89 d8                	mov    %ebx,%eax
			break;
	}
	return tot;
}
  8006e0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8006e3:	5b                   	pop    %ebx
  8006e4:	5e                   	pop    %esi
  8006e5:	5f                   	pop    %edi
  8006e6:	c9                   	leave  
  8006e7:	c3                   	ret    

008006e8 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8006e8:	55                   	push   %ebp
  8006e9:	89 e5                	mov    %esp,%ebp
  8006eb:	53                   	push   %ebx
  8006ec:	83 ec 14             	sub    $0x14,%esp
  8006ef:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8006f2:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8006f5:	50                   	push   %eax
  8006f6:	53                   	push   %ebx
  8006f7:	e8 8f fc ff ff       	call   80038b <fd_lookup>
  8006fc:	83 c4 08             	add    $0x8,%esp
  8006ff:	85 c0                	test   %eax,%eax
  800701:	78 62                	js     800765 <write+0x7d>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800703:	83 ec 08             	sub    $0x8,%esp
  800706:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800709:	50                   	push   %eax
  80070a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80070d:	ff 30                	pushl  (%eax)
  80070f:	e8 cd fc ff ff       	call   8003e1 <dev_lookup>
  800714:	83 c4 10             	add    $0x10,%esp
  800717:	85 c0                	test   %eax,%eax
  800719:	78 4a                	js     800765 <write+0x7d>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80071b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80071e:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  800722:	75 21                	jne    800745 <write+0x5d>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  800724:	a1 04 40 80 00       	mov    0x804004,%eax
  800729:	8b 40 48             	mov    0x48(%eax),%eax
  80072c:	83 ec 04             	sub    $0x4,%esp
  80072f:	53                   	push   %ebx
  800730:	50                   	push   %eax
  800731:	68 15 1e 80 00       	push   $0x801e15
  800736:	e8 41 09 00 00       	call   80107c <cprintf>
		return -E_INVAL;
  80073b:	83 c4 10             	add    $0x10,%esp
  80073e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800743:	eb 20                	jmp    800765 <write+0x7d>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  800745:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800748:	8b 52 0c             	mov    0xc(%edx),%edx
  80074b:	85 d2                	test   %edx,%edx
  80074d:	74 11                	je     800760 <write+0x78>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80074f:	83 ec 04             	sub    $0x4,%esp
  800752:	ff 75 10             	pushl  0x10(%ebp)
  800755:	ff 75 0c             	pushl  0xc(%ebp)
  800758:	50                   	push   %eax
  800759:	ff d2                	call   *%edx
  80075b:	83 c4 10             	add    $0x10,%esp
  80075e:	eb 05                	jmp    800765 <write+0x7d>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  800760:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  800765:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800768:	c9                   	leave  
  800769:	c3                   	ret    

0080076a <seek>:

int
seek(int fdnum, off_t offset)
{
  80076a:	55                   	push   %ebp
  80076b:	89 e5                	mov    %esp,%ebp
  80076d:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800770:	8d 45 fc             	lea    -0x4(%ebp),%eax
  800773:	50                   	push   %eax
  800774:	ff 75 08             	pushl  0x8(%ebp)
  800777:	e8 0f fc ff ff       	call   80038b <fd_lookup>
  80077c:	83 c4 08             	add    $0x8,%esp
  80077f:	85 c0                	test   %eax,%eax
  800781:	78 0e                	js     800791 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  800783:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800786:	8b 55 0c             	mov    0xc(%ebp),%edx
  800789:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  80078c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800791:	c9                   	leave  
  800792:	c3                   	ret    

00800793 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  800793:	55                   	push   %ebp
  800794:	89 e5                	mov    %esp,%ebp
  800796:	53                   	push   %ebx
  800797:	83 ec 14             	sub    $0x14,%esp
  80079a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80079d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8007a0:	50                   	push   %eax
  8007a1:	53                   	push   %ebx
  8007a2:	e8 e4 fb ff ff       	call   80038b <fd_lookup>
  8007a7:	83 c4 08             	add    $0x8,%esp
  8007aa:	85 c0                	test   %eax,%eax
  8007ac:	78 5f                	js     80080d <ftruncate+0x7a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8007ae:	83 ec 08             	sub    $0x8,%esp
  8007b1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8007b4:	50                   	push   %eax
  8007b5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8007b8:	ff 30                	pushl  (%eax)
  8007ba:	e8 22 fc ff ff       	call   8003e1 <dev_lookup>
  8007bf:	83 c4 10             	add    $0x10,%esp
  8007c2:	85 c0                	test   %eax,%eax
  8007c4:	78 47                	js     80080d <ftruncate+0x7a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8007c6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8007c9:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8007cd:	75 21                	jne    8007f0 <ftruncate+0x5d>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8007cf:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8007d4:	8b 40 48             	mov    0x48(%eax),%eax
  8007d7:	83 ec 04             	sub    $0x4,%esp
  8007da:	53                   	push   %ebx
  8007db:	50                   	push   %eax
  8007dc:	68 d8 1d 80 00       	push   $0x801dd8
  8007e1:	e8 96 08 00 00       	call   80107c <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8007e6:	83 c4 10             	add    $0x10,%esp
  8007e9:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8007ee:	eb 1d                	jmp    80080d <ftruncate+0x7a>
	}
	if (!dev->dev_trunc)
  8007f0:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8007f3:	8b 52 18             	mov    0x18(%edx),%edx
  8007f6:	85 d2                	test   %edx,%edx
  8007f8:	74 0e                	je     800808 <ftruncate+0x75>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8007fa:	83 ec 08             	sub    $0x8,%esp
  8007fd:	ff 75 0c             	pushl  0xc(%ebp)
  800800:	50                   	push   %eax
  800801:	ff d2                	call   *%edx
  800803:	83 c4 10             	add    $0x10,%esp
  800806:	eb 05                	jmp    80080d <ftruncate+0x7a>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  800808:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  80080d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800810:	c9                   	leave  
  800811:	c3                   	ret    

00800812 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  800812:	55                   	push   %ebp
  800813:	89 e5                	mov    %esp,%ebp
  800815:	53                   	push   %ebx
  800816:	83 ec 14             	sub    $0x14,%esp
  800819:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80081c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80081f:	50                   	push   %eax
  800820:	ff 75 08             	pushl  0x8(%ebp)
  800823:	e8 63 fb ff ff       	call   80038b <fd_lookup>
  800828:	83 c4 08             	add    $0x8,%esp
  80082b:	85 c0                	test   %eax,%eax
  80082d:	78 52                	js     800881 <fstat+0x6f>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80082f:	83 ec 08             	sub    $0x8,%esp
  800832:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800835:	50                   	push   %eax
  800836:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800839:	ff 30                	pushl  (%eax)
  80083b:	e8 a1 fb ff ff       	call   8003e1 <dev_lookup>
  800840:	83 c4 10             	add    $0x10,%esp
  800843:	85 c0                	test   %eax,%eax
  800845:	78 3a                	js     800881 <fstat+0x6f>
		return r;
	if (!dev->dev_stat)
  800847:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80084a:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  80084e:	74 2c                	je     80087c <fstat+0x6a>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  800850:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  800853:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80085a:	00 00 00 
	stat->st_isdir = 0;
  80085d:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  800864:	00 00 00 
	stat->st_dev = dev;
  800867:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  80086d:	83 ec 08             	sub    $0x8,%esp
  800870:	53                   	push   %ebx
  800871:	ff 75 f0             	pushl  -0x10(%ebp)
  800874:	ff 50 14             	call   *0x14(%eax)
  800877:	83 c4 10             	add    $0x10,%esp
  80087a:	eb 05                	jmp    800881 <fstat+0x6f>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  80087c:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  800881:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800884:	c9                   	leave  
  800885:	c3                   	ret    

00800886 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  800886:	55                   	push   %ebp
  800887:	89 e5                	mov    %esp,%ebp
  800889:	56                   	push   %esi
  80088a:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  80088b:	83 ec 08             	sub    $0x8,%esp
  80088e:	6a 00                	push   $0x0
  800890:	ff 75 08             	pushl  0x8(%ebp)
  800893:	e8 78 01 00 00       	call   800a10 <open>
  800898:	89 c3                	mov    %eax,%ebx
  80089a:	83 c4 10             	add    $0x10,%esp
  80089d:	85 c0                	test   %eax,%eax
  80089f:	78 1b                	js     8008bc <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8008a1:	83 ec 08             	sub    $0x8,%esp
  8008a4:	ff 75 0c             	pushl  0xc(%ebp)
  8008a7:	50                   	push   %eax
  8008a8:	e8 65 ff ff ff       	call   800812 <fstat>
  8008ad:	89 c6                	mov    %eax,%esi
	close(fd);
  8008af:	89 1c 24             	mov    %ebx,(%esp)
  8008b2:	e8 18 fc ff ff       	call   8004cf <close>
	return r;
  8008b7:	83 c4 10             	add    $0x10,%esp
  8008ba:	89 f3                	mov    %esi,%ebx
}
  8008bc:	89 d8                	mov    %ebx,%eax
  8008be:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8008c1:	5b                   	pop    %ebx
  8008c2:	5e                   	pop    %esi
  8008c3:	c9                   	leave  
  8008c4:	c3                   	ret    
  8008c5:	00 00                	add    %al,(%eax)
	...

008008c8 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8008c8:	55                   	push   %ebp
  8008c9:	89 e5                	mov    %esp,%ebp
  8008cb:	56                   	push   %esi
  8008cc:	53                   	push   %ebx
  8008cd:	89 c3                	mov    %eax,%ebx
  8008cf:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  8008d1:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8008d8:	75 12                	jne    8008ec <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8008da:	83 ec 0c             	sub    $0xc,%esp
  8008dd:	6a 01                	push   $0x1
  8008df:	e8 96 11 00 00       	call   801a7a <ipc_find_env>
  8008e4:	a3 00 40 80 00       	mov    %eax,0x804000
  8008e9:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8008ec:	6a 07                	push   $0x7
  8008ee:	68 00 50 80 00       	push   $0x805000
  8008f3:	53                   	push   %ebx
  8008f4:	ff 35 00 40 80 00    	pushl  0x804000
  8008fa:	e8 26 11 00 00       	call   801a25 <ipc_send>
	
	return ipc_recv(NULL, dstva, NULL);
  8008ff:	83 c4 0c             	add    $0xc,%esp
  800902:	6a 00                	push   $0x0
  800904:	56                   	push   %esi
  800905:	6a 00                	push   $0x0
  800907:	e8 a4 10 00 00       	call   8019b0 <ipc_recv>
}
  80090c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80090f:	5b                   	pop    %ebx
  800910:	5e                   	pop    %esi
  800911:	c9                   	leave  
  800912:	c3                   	ret    

00800913 <devfile_stat>:
}


static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  800913:	55                   	push   %ebp
  800914:	89 e5                	mov    %esp,%ebp
  800916:	53                   	push   %ebx
  800917:	83 ec 04             	sub    $0x4,%esp
  80091a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  80091d:	8b 45 08             	mov    0x8(%ebp),%eax
  800920:	8b 40 0c             	mov    0xc(%eax),%eax
  800923:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0) {
  800928:	ba 00 00 00 00       	mov    $0x0,%edx
  80092d:	b8 05 00 00 00       	mov    $0x5,%eax
  800932:	e8 91 ff ff ff       	call   8008c8 <fsipc>
  800937:	85 c0                	test   %eax,%eax
  800939:	78 2c                	js     800967 <devfile_stat+0x54>
		return r;
	}
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  80093b:	83 ec 08             	sub    $0x8,%esp
  80093e:	68 00 50 80 00       	push   $0x805000
  800943:	53                   	push   %ebx
  800944:	e8 e9 0c 00 00       	call   801632 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  800949:	a1 80 50 80 00       	mov    0x805080,%eax
  80094e:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  800954:	a1 84 50 80 00       	mov    0x805084,%eax
  800959:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  80095f:	83 c4 10             	add    $0x10,%esp
  800962:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800967:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80096a:	c9                   	leave  
  80096b:	c3                   	ret    

0080096c <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  80096c:	55                   	push   %ebp
  80096d:	89 e5                	mov    %esp,%ebp
  80096f:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  800972:	8b 45 08             	mov    0x8(%ebp),%eax
  800975:	8b 40 0c             	mov    0xc(%eax),%eax
  800978:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  80097d:	ba 00 00 00 00       	mov    $0x0,%edx
  800982:	b8 06 00 00 00       	mov    $0x6,%eax
  800987:	e8 3c ff ff ff       	call   8008c8 <fsipc>
}
  80098c:	c9                   	leave  
  80098d:	c3                   	ret    

0080098e <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  80098e:	55                   	push   %ebp
  80098f:	89 e5                	mov    %esp,%ebp
  800991:	56                   	push   %esi
  800992:	53                   	push   %ebx
  800993:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  800996:	8b 45 08             	mov    0x8(%ebp),%eax
  800999:	8b 40 0c             	mov    0xc(%eax),%eax
  80099c:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  8009a1:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8009a7:	ba 00 00 00 00       	mov    $0x0,%edx
  8009ac:	b8 03 00 00 00       	mov    $0x3,%eax
  8009b1:	e8 12 ff ff ff       	call   8008c8 <fsipc>
  8009b6:	89 c3                	mov    %eax,%ebx
  8009b8:	85 c0                	test   %eax,%eax
  8009ba:	78 4b                	js     800a07 <devfile_read+0x79>
		return r;
	assert(r <= n);
  8009bc:	39 c6                	cmp    %eax,%esi
  8009be:	73 16                	jae    8009d6 <devfile_read+0x48>
  8009c0:	68 44 1e 80 00       	push   $0x801e44
  8009c5:	68 4b 1e 80 00       	push   $0x801e4b
  8009ca:	6a 7d                	push   $0x7d
  8009cc:	68 60 1e 80 00       	push   $0x801e60
  8009d1:	e8 ce 05 00 00       	call   800fa4 <_panic>
	assert(r <= PGSIZE);
  8009d6:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8009db:	7e 16                	jle    8009f3 <devfile_read+0x65>
  8009dd:	68 6b 1e 80 00       	push   $0x801e6b
  8009e2:	68 4b 1e 80 00       	push   $0x801e4b
  8009e7:	6a 7e                	push   $0x7e
  8009e9:	68 60 1e 80 00       	push   $0x801e60
  8009ee:	e8 b1 05 00 00       	call   800fa4 <_panic>
	memmove(buf, &fsipcbuf, r);
  8009f3:	83 ec 04             	sub    $0x4,%esp
  8009f6:	50                   	push   %eax
  8009f7:	68 00 50 80 00       	push   $0x805000
  8009fc:	ff 75 0c             	pushl  0xc(%ebp)
  8009ff:	e8 ef 0d 00 00       	call   8017f3 <memmove>
	return r;
  800a04:	83 c4 10             	add    $0x10,%esp
}
  800a07:	89 d8                	mov    %ebx,%eax
  800a09:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800a0c:	5b                   	pop    %ebx
  800a0d:	5e                   	pop    %esi
  800a0e:	c9                   	leave  
  800a0f:	c3                   	ret    

00800a10 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  800a10:	55                   	push   %ebp
  800a11:	89 e5                	mov    %esp,%ebp
  800a13:	56                   	push   %esi
  800a14:	53                   	push   %ebx
  800a15:	83 ec 1c             	sub    $0x1c,%esp
  800a18:	8b 75 08             	mov    0x8(%ebp),%esi
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  800a1b:	56                   	push   %esi
  800a1c:	e8 bf 0b 00 00       	call   8015e0 <strlen>
  800a21:	83 c4 10             	add    $0x10,%esp
  800a24:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  800a29:	7f 65                	jg     800a90 <open+0x80>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800a2b:	83 ec 0c             	sub    $0xc,%esp
  800a2e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800a31:	50                   	push   %eax
  800a32:	e8 e1 f8 ff ff       	call   800318 <fd_alloc>
  800a37:	89 c3                	mov    %eax,%ebx
  800a39:	83 c4 10             	add    $0x10,%esp
  800a3c:	85 c0                	test   %eax,%eax
  800a3e:	78 55                	js     800a95 <open+0x85>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  800a40:	83 ec 08             	sub    $0x8,%esp
  800a43:	56                   	push   %esi
  800a44:	68 00 50 80 00       	push   $0x805000
  800a49:	e8 e4 0b 00 00       	call   801632 <strcpy>
	fsipcbuf.open.req_omode = mode;
  800a4e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a51:	a3 00 54 80 00       	mov    %eax,0x805400



	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  800a56:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800a59:	b8 01 00 00 00       	mov    $0x1,%eax
  800a5e:	e8 65 fe ff ff       	call   8008c8 <fsipc>
  800a63:	89 c3                	mov    %eax,%ebx
  800a65:	83 c4 10             	add    $0x10,%esp
  800a68:	85 c0                	test   %eax,%eax
  800a6a:	79 12                	jns    800a7e <open+0x6e>
		fd_close(fd, 0);
  800a6c:	83 ec 08             	sub    $0x8,%esp
  800a6f:	6a 00                	push   $0x0
  800a71:	ff 75 f4             	pushl  -0xc(%ebp)
  800a74:	e8 ce f9 ff ff       	call   800447 <fd_close>
		return r;
  800a79:	83 c4 10             	add    $0x10,%esp
  800a7c:	eb 17                	jmp    800a95 <open+0x85>
	}

	return fd2num(fd);
  800a7e:	83 ec 0c             	sub    $0xc,%esp
  800a81:	ff 75 f4             	pushl  -0xc(%ebp)
  800a84:	e8 67 f8 ff ff       	call   8002f0 <fd2num>
  800a89:	89 c3                	mov    %eax,%ebx
  800a8b:	83 c4 10             	add    $0x10,%esp
  800a8e:	eb 05                	jmp    800a95 <open+0x85>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  800a90:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  800a95:	89 d8                	mov    %ebx,%eax
  800a97:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800a9a:	5b                   	pop    %ebx
  800a9b:	5e                   	pop    %esi
  800a9c:	c9                   	leave  
  800a9d:	c3                   	ret    
	...

00800aa0 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  800aa0:	55                   	push   %ebp
  800aa1:	89 e5                	mov    %esp,%ebp
  800aa3:	56                   	push   %esi
  800aa4:	53                   	push   %ebx
  800aa5:	8b 75 0c             	mov    0xc(%ebp),%esi
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  800aa8:	83 ec 0c             	sub    $0xc,%esp
  800aab:	ff 75 08             	pushl  0x8(%ebp)
  800aae:	e8 4d f8 ff ff       	call   800300 <fd2data>
  800ab3:	89 c3                	mov    %eax,%ebx
	strcpy(stat->st_name, "<pipe>");
  800ab5:	83 c4 08             	add    $0x8,%esp
  800ab8:	68 77 1e 80 00       	push   $0x801e77
  800abd:	56                   	push   %esi
  800abe:	e8 6f 0b 00 00       	call   801632 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  800ac3:	8b 43 04             	mov    0x4(%ebx),%eax
  800ac6:	2b 03                	sub    (%ebx),%eax
  800ac8:	89 86 80 00 00 00    	mov    %eax,0x80(%esi)
	stat->st_isdir = 0;
  800ace:	c7 86 84 00 00 00 00 	movl   $0x0,0x84(%esi)
  800ad5:	00 00 00 
	stat->st_dev = &devpipe;
  800ad8:	c7 86 88 00 00 00 20 	movl   $0x803020,0x88(%esi)
  800adf:	30 80 00 
	return 0;
}
  800ae2:	b8 00 00 00 00       	mov    $0x0,%eax
  800ae7:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800aea:	5b                   	pop    %ebx
  800aeb:	5e                   	pop    %esi
  800aec:	c9                   	leave  
  800aed:	c3                   	ret    

00800aee <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  800aee:	55                   	push   %ebp
  800aef:	89 e5                	mov    %esp,%ebp
  800af1:	53                   	push   %ebx
  800af2:	83 ec 0c             	sub    $0xc,%esp
  800af5:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  800af8:	53                   	push   %ebx
  800af9:	6a 00                	push   $0x0
  800afb:	e8 fa f6 ff ff       	call   8001fa <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  800b00:	89 1c 24             	mov    %ebx,(%esp)
  800b03:	e8 f8 f7 ff ff       	call   800300 <fd2data>
  800b08:	83 c4 08             	add    $0x8,%esp
  800b0b:	50                   	push   %eax
  800b0c:	6a 00                	push   $0x0
  800b0e:	e8 e7 f6 ff ff       	call   8001fa <sys_page_unmap>
}
  800b13:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800b16:	c9                   	leave  
  800b17:	c3                   	ret    

00800b18 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  800b18:	55                   	push   %ebp
  800b19:	89 e5                	mov    %esp,%ebp
  800b1b:	57                   	push   %edi
  800b1c:	56                   	push   %esi
  800b1d:	53                   	push   %ebx
  800b1e:	83 ec 1c             	sub    $0x1c,%esp
  800b21:	89 c7                	mov    %eax,%edi
  800b23:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  800b26:	a1 04 40 80 00       	mov    0x804004,%eax
  800b2b:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  800b2e:	83 ec 0c             	sub    $0xc,%esp
  800b31:	57                   	push   %edi
  800b32:	e8 a1 0f 00 00       	call   801ad8 <pageref>
  800b37:	89 c6                	mov    %eax,%esi
  800b39:	83 c4 04             	add    $0x4,%esp
  800b3c:	ff 75 e4             	pushl  -0x1c(%ebp)
  800b3f:	e8 94 0f 00 00       	call   801ad8 <pageref>
  800b44:	83 c4 10             	add    $0x10,%esp
  800b47:	39 c6                	cmp    %eax,%esi
  800b49:	0f 94 c0             	sete   %al
  800b4c:	0f b6 c0             	movzbl %al,%eax
		nn = thisenv->env_runs;
  800b4f:	8b 15 04 40 80 00    	mov    0x804004,%edx
  800b55:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  800b58:	39 cb                	cmp    %ecx,%ebx
  800b5a:	75 08                	jne    800b64 <_pipeisclosed+0x4c>
			return ret;
		if (n != nn && ret == 1)
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
	}
}
  800b5c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b5f:	5b                   	pop    %ebx
  800b60:	5e                   	pop    %esi
  800b61:	5f                   	pop    %edi
  800b62:	c9                   	leave  
  800b63:	c3                   	ret    
		n = thisenv->env_runs;
		ret = pageref(fd) == pageref(p);
		nn = thisenv->env_runs;
		if (n == nn)
			return ret;
		if (n != nn && ret == 1)
  800b64:	83 f8 01             	cmp    $0x1,%eax
  800b67:	75 bd                	jne    800b26 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  800b69:	8b 42 58             	mov    0x58(%edx),%eax
  800b6c:	6a 01                	push   $0x1
  800b6e:	50                   	push   %eax
  800b6f:	53                   	push   %ebx
  800b70:	68 7e 1e 80 00       	push   $0x801e7e
  800b75:	e8 02 05 00 00       	call   80107c <cprintf>
  800b7a:	83 c4 10             	add    $0x10,%esp
  800b7d:	eb a7                	jmp    800b26 <_pipeisclosed+0xe>

00800b7f <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  800b7f:	55                   	push   %ebp
  800b80:	89 e5                	mov    %esp,%ebp
  800b82:	57                   	push   %edi
  800b83:	56                   	push   %esi
  800b84:	53                   	push   %ebx
  800b85:	83 ec 28             	sub    $0x28,%esp
  800b88:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  800b8b:	56                   	push   %esi
  800b8c:	e8 6f f7 ff ff       	call   800300 <fd2data>
  800b91:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800b93:	83 c4 10             	add    $0x10,%esp
  800b96:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800b9a:	75 4a                	jne    800be6 <devpipe_write+0x67>
  800b9c:	bf 00 00 00 00       	mov    $0x0,%edi
  800ba1:	eb 56                	jmp    800bf9 <devpipe_write+0x7a>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  800ba3:	89 da                	mov    %ebx,%edx
  800ba5:	89 f0                	mov    %esi,%eax
  800ba7:	e8 6c ff ff ff       	call   800b18 <_pipeisclosed>
  800bac:	85 c0                	test   %eax,%eax
  800bae:	75 4d                	jne    800bfd <devpipe_write+0x7e>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  800bb0:	e8 d4 f5 ff ff       	call   800189 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  800bb5:	8b 43 04             	mov    0x4(%ebx),%eax
  800bb8:	8b 13                	mov    (%ebx),%edx
  800bba:	83 c2 20             	add    $0x20,%edx
  800bbd:	39 d0                	cmp    %edx,%eax
  800bbf:	73 e2                	jae    800ba3 <devpipe_write+0x24>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  800bc1:	89 c2                	mov    %eax,%edx
  800bc3:	81 e2 1f 00 00 80    	and    $0x8000001f,%edx
  800bc9:	79 05                	jns    800bd0 <devpipe_write+0x51>
  800bcb:	4a                   	dec    %edx
  800bcc:	83 ca e0             	or     $0xffffffe0,%edx
  800bcf:	42                   	inc    %edx
  800bd0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bd3:	8a 0c 39             	mov    (%ecx,%edi,1),%cl
  800bd6:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  800bda:	40                   	inc    %eax
  800bdb:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800bde:	47                   	inc    %edi
  800bdf:	39 7d 10             	cmp    %edi,0x10(%ebp)
  800be2:	77 07                	ja     800beb <devpipe_write+0x6c>
  800be4:	eb 13                	jmp    800bf9 <devpipe_write+0x7a>
  800be6:	bf 00 00 00 00       	mov    $0x0,%edi
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  800beb:	8b 43 04             	mov    0x4(%ebx),%eax
  800bee:	8b 13                	mov    (%ebx),%edx
  800bf0:	83 c2 20             	add    $0x20,%edx
  800bf3:	39 d0                	cmp    %edx,%eax
  800bf5:	73 ac                	jae    800ba3 <devpipe_write+0x24>
  800bf7:	eb c8                	jmp    800bc1 <devpipe_write+0x42>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  800bf9:	89 f8                	mov    %edi,%eax
  800bfb:	eb 05                	jmp    800c02 <devpipe_write+0x83>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  800bfd:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  800c02:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c05:	5b                   	pop    %ebx
  800c06:	5e                   	pop    %esi
  800c07:	5f                   	pop    %edi
  800c08:	c9                   	leave  
  800c09:	c3                   	ret    

00800c0a <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  800c0a:	55                   	push   %ebp
  800c0b:	89 e5                	mov    %esp,%ebp
  800c0d:	57                   	push   %edi
  800c0e:	56                   	push   %esi
  800c0f:	53                   	push   %ebx
  800c10:	83 ec 18             	sub    $0x18,%esp
  800c13:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  800c16:	57                   	push   %edi
  800c17:	e8 e4 f6 ff ff       	call   800300 <fd2data>
  800c1c:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800c1e:	83 c4 10             	add    $0x10,%esp
  800c21:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800c25:	75 44                	jne    800c6b <devpipe_read+0x61>
  800c27:	be 00 00 00 00       	mov    $0x0,%esi
  800c2c:	eb 4f                	jmp    800c7d <devpipe_read+0x73>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
				return i;
  800c2e:	89 f0                	mov    %esi,%eax
  800c30:	eb 54                	jmp    800c86 <devpipe_read+0x7c>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  800c32:	89 da                	mov    %ebx,%edx
  800c34:	89 f8                	mov    %edi,%eax
  800c36:	e8 dd fe ff ff       	call   800b18 <_pipeisclosed>
  800c3b:	85 c0                	test   %eax,%eax
  800c3d:	75 42                	jne    800c81 <devpipe_read+0x77>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  800c3f:	e8 45 f5 ff ff       	call   800189 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  800c44:	8b 03                	mov    (%ebx),%eax
  800c46:	3b 43 04             	cmp    0x4(%ebx),%eax
  800c49:	74 e7                	je     800c32 <devpipe_read+0x28>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  800c4b:	25 1f 00 00 80       	and    $0x8000001f,%eax
  800c50:	79 05                	jns    800c57 <devpipe_read+0x4d>
  800c52:	48                   	dec    %eax
  800c53:	83 c8 e0             	or     $0xffffffe0,%eax
  800c56:	40                   	inc    %eax
  800c57:	8a 44 03 08          	mov    0x8(%ebx,%eax,1),%al
  800c5b:	8b 55 0c             	mov    0xc(%ebp),%edx
  800c5e:	88 04 32             	mov    %al,(%edx,%esi,1)
		p->p_rpos++;
  800c61:	ff 03                	incl   (%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800c63:	46                   	inc    %esi
  800c64:	39 75 10             	cmp    %esi,0x10(%ebp)
  800c67:	77 07                	ja     800c70 <devpipe_read+0x66>
  800c69:	eb 12                	jmp    800c7d <devpipe_read+0x73>
  800c6b:	be 00 00 00 00       	mov    $0x0,%esi
		while (p->p_rpos == p->p_wpos) {
  800c70:	8b 03                	mov    (%ebx),%eax
  800c72:	3b 43 04             	cmp    0x4(%ebx),%eax
  800c75:	75 d4                	jne    800c4b <devpipe_read+0x41>
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  800c77:	85 f6                	test   %esi,%esi
  800c79:	75 b3                	jne    800c2e <devpipe_read+0x24>
  800c7b:	eb b5                	jmp    800c32 <devpipe_read+0x28>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  800c7d:	89 f0                	mov    %esi,%eax
  800c7f:	eb 05                	jmp    800c86 <devpipe_read+0x7c>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  800c81:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  800c86:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c89:	5b                   	pop    %ebx
  800c8a:	5e                   	pop    %esi
  800c8b:	5f                   	pop    %edi
  800c8c:	c9                   	leave  
  800c8d:	c3                   	ret    

00800c8e <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  800c8e:	55                   	push   %ebp
  800c8f:	89 e5                	mov    %esp,%ebp
  800c91:	57                   	push   %edi
  800c92:	56                   	push   %esi
  800c93:	53                   	push   %ebx
  800c94:	83 ec 28             	sub    $0x28,%esp
  800c97:	8b 7d 08             	mov    0x8(%ebp),%edi
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  800c9a:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800c9d:	50                   	push   %eax
  800c9e:	e8 75 f6 ff ff       	call   800318 <fd_alloc>
  800ca3:	89 c3                	mov    %eax,%ebx
  800ca5:	83 c4 10             	add    $0x10,%esp
  800ca8:	85 c0                	test   %eax,%eax
  800caa:	0f 88 24 01 00 00    	js     800dd4 <pipe+0x146>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800cb0:	83 ec 04             	sub    $0x4,%esp
  800cb3:	68 07 04 00 00       	push   $0x407
  800cb8:	ff 75 e4             	pushl  -0x1c(%ebp)
  800cbb:	6a 00                	push   $0x0
  800cbd:	e8 ee f4 ff ff       	call   8001b0 <sys_page_alloc>
  800cc2:	89 c3                	mov    %eax,%ebx
  800cc4:	83 c4 10             	add    $0x10,%esp
  800cc7:	85 c0                	test   %eax,%eax
  800cc9:	0f 88 05 01 00 00    	js     800dd4 <pipe+0x146>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  800ccf:	83 ec 0c             	sub    $0xc,%esp
  800cd2:	8d 45 e0             	lea    -0x20(%ebp),%eax
  800cd5:	50                   	push   %eax
  800cd6:	e8 3d f6 ff ff       	call   800318 <fd_alloc>
  800cdb:	89 c3                	mov    %eax,%ebx
  800cdd:	83 c4 10             	add    $0x10,%esp
  800ce0:	85 c0                	test   %eax,%eax
  800ce2:	0f 88 dc 00 00 00    	js     800dc4 <pipe+0x136>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800ce8:	83 ec 04             	sub    $0x4,%esp
  800ceb:	68 07 04 00 00       	push   $0x407
  800cf0:	ff 75 e0             	pushl  -0x20(%ebp)
  800cf3:	6a 00                	push   $0x0
  800cf5:	e8 b6 f4 ff ff       	call   8001b0 <sys_page_alloc>
  800cfa:	89 c3                	mov    %eax,%ebx
  800cfc:	83 c4 10             	add    $0x10,%esp
  800cff:	85 c0                	test   %eax,%eax
  800d01:	0f 88 bd 00 00 00    	js     800dc4 <pipe+0x136>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  800d07:	83 ec 0c             	sub    $0xc,%esp
  800d0a:	ff 75 e4             	pushl  -0x1c(%ebp)
  800d0d:	e8 ee f5 ff ff       	call   800300 <fd2data>
  800d12:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800d14:	83 c4 0c             	add    $0xc,%esp
  800d17:	68 07 04 00 00       	push   $0x407
  800d1c:	50                   	push   %eax
  800d1d:	6a 00                	push   $0x0
  800d1f:	e8 8c f4 ff ff       	call   8001b0 <sys_page_alloc>
  800d24:	89 c3                	mov    %eax,%ebx
  800d26:	83 c4 10             	add    $0x10,%esp
  800d29:	85 c0                	test   %eax,%eax
  800d2b:	0f 88 83 00 00 00    	js     800db4 <pipe+0x126>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800d31:	83 ec 0c             	sub    $0xc,%esp
  800d34:	ff 75 e0             	pushl  -0x20(%ebp)
  800d37:	e8 c4 f5 ff ff       	call   800300 <fd2data>
  800d3c:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  800d43:	50                   	push   %eax
  800d44:	6a 00                	push   $0x0
  800d46:	56                   	push   %esi
  800d47:	6a 00                	push   $0x0
  800d49:	e8 86 f4 ff ff       	call   8001d4 <sys_page_map>
  800d4e:	89 c3                	mov    %eax,%ebx
  800d50:	83 c4 20             	add    $0x20,%esp
  800d53:	85 c0                	test   %eax,%eax
  800d55:	78 4f                	js     800da6 <pipe+0x118>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  800d57:	8b 15 20 30 80 00    	mov    0x803020,%edx
  800d5d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800d60:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  800d62:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800d65:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  800d6c:	8b 15 20 30 80 00    	mov    0x803020,%edx
  800d72:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800d75:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  800d77:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800d7a:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  800d81:	83 ec 0c             	sub    $0xc,%esp
  800d84:	ff 75 e4             	pushl  -0x1c(%ebp)
  800d87:	e8 64 f5 ff ff       	call   8002f0 <fd2num>
  800d8c:	89 07                	mov    %eax,(%edi)
	pfd[1] = fd2num(fd1);
  800d8e:	83 c4 04             	add    $0x4,%esp
  800d91:	ff 75 e0             	pushl  -0x20(%ebp)
  800d94:	e8 57 f5 ff ff       	call   8002f0 <fd2num>
  800d99:	89 47 04             	mov    %eax,0x4(%edi)
	return 0;
  800d9c:	83 c4 10             	add    $0x10,%esp
  800d9f:	bb 00 00 00 00       	mov    $0x0,%ebx
  800da4:	eb 2e                	jmp    800dd4 <pipe+0x146>

    err3:
	sys_page_unmap(0, va);
  800da6:	83 ec 08             	sub    $0x8,%esp
  800da9:	56                   	push   %esi
  800daa:	6a 00                	push   $0x0
  800dac:	e8 49 f4 ff ff       	call   8001fa <sys_page_unmap>
  800db1:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  800db4:	83 ec 08             	sub    $0x8,%esp
  800db7:	ff 75 e0             	pushl  -0x20(%ebp)
  800dba:	6a 00                	push   $0x0
  800dbc:	e8 39 f4 ff ff       	call   8001fa <sys_page_unmap>
  800dc1:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  800dc4:	83 ec 08             	sub    $0x8,%esp
  800dc7:	ff 75 e4             	pushl  -0x1c(%ebp)
  800dca:	6a 00                	push   $0x0
  800dcc:	e8 29 f4 ff ff       	call   8001fa <sys_page_unmap>
  800dd1:	83 c4 10             	add    $0x10,%esp
    err:
	return r;
}
  800dd4:	89 d8                	mov    %ebx,%eax
  800dd6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800dd9:	5b                   	pop    %ebx
  800dda:	5e                   	pop    %esi
  800ddb:	5f                   	pop    %edi
  800ddc:	c9                   	leave  
  800ddd:	c3                   	ret    

00800dde <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  800dde:	55                   	push   %ebp
  800ddf:	89 e5                	mov    %esp,%ebp
  800de1:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800de4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800de7:	50                   	push   %eax
  800de8:	ff 75 08             	pushl  0x8(%ebp)
  800deb:	e8 9b f5 ff ff       	call   80038b <fd_lookup>
  800df0:	83 c4 10             	add    $0x10,%esp
  800df3:	85 c0                	test   %eax,%eax
  800df5:	78 18                	js     800e0f <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  800df7:	83 ec 0c             	sub    $0xc,%esp
  800dfa:	ff 75 f4             	pushl  -0xc(%ebp)
  800dfd:	e8 fe f4 ff ff       	call   800300 <fd2data>
	return _pipeisclosed(fd, p);
  800e02:	89 c2                	mov    %eax,%edx
  800e04:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800e07:	e8 0c fd ff ff       	call   800b18 <_pipeisclosed>
  800e0c:	83 c4 10             	add    $0x10,%esp
}
  800e0f:	c9                   	leave  
  800e10:	c3                   	ret    
  800e11:	00 00                	add    %al,(%eax)
	...

00800e14 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  800e14:	55                   	push   %ebp
  800e15:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  800e17:	b8 00 00 00 00       	mov    $0x0,%eax
  800e1c:	c9                   	leave  
  800e1d:	c3                   	ret    

00800e1e <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  800e1e:	55                   	push   %ebp
  800e1f:	89 e5                	mov    %esp,%ebp
  800e21:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  800e24:	68 96 1e 80 00       	push   $0x801e96
  800e29:	ff 75 0c             	pushl  0xc(%ebp)
  800e2c:	e8 01 08 00 00       	call   801632 <strcpy>
	return 0;
}
  800e31:	b8 00 00 00 00       	mov    $0x0,%eax
  800e36:	c9                   	leave  
  800e37:	c3                   	ret    

00800e38 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  800e38:	55                   	push   %ebp
  800e39:	89 e5                	mov    %esp,%ebp
  800e3b:	57                   	push   %edi
  800e3c:	56                   	push   %esi
  800e3d:	53                   	push   %ebx
  800e3e:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800e44:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800e48:	74 45                	je     800e8f <devcons_write+0x57>
  800e4a:	b8 00 00 00 00       	mov    $0x0,%eax
  800e4f:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  800e54:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  800e5a:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e5d:	29 c3                	sub    %eax,%ebx
		if (m > sizeof(buf) - 1)
  800e5f:	83 fb 7f             	cmp    $0x7f,%ebx
  800e62:	76 05                	jbe    800e69 <devcons_write+0x31>
			m = sizeof(buf) - 1;
  800e64:	bb 7f 00 00 00       	mov    $0x7f,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  800e69:	83 ec 04             	sub    $0x4,%esp
  800e6c:	53                   	push   %ebx
  800e6d:	03 45 0c             	add    0xc(%ebp),%eax
  800e70:	50                   	push   %eax
  800e71:	57                   	push   %edi
  800e72:	e8 7c 09 00 00       	call   8017f3 <memmove>
		sys_cputs(buf, m);
  800e77:	83 c4 08             	add    $0x8,%esp
  800e7a:	53                   	push   %ebx
  800e7b:	57                   	push   %edi
  800e7c:	e8 78 f2 ff ff       	call   8000f9 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800e81:	01 de                	add    %ebx,%esi
  800e83:	89 f0                	mov    %esi,%eax
  800e85:	83 c4 10             	add    $0x10,%esp
  800e88:	3b 75 10             	cmp    0x10(%ebp),%esi
  800e8b:	72 cd                	jb     800e5a <devcons_write+0x22>
  800e8d:	eb 05                	jmp    800e94 <devcons_write+0x5c>
  800e8f:	be 00 00 00 00       	mov    $0x0,%esi
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  800e94:	89 f0                	mov    %esi,%eax
  800e96:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e99:	5b                   	pop    %ebx
  800e9a:	5e                   	pop    %esi
  800e9b:	5f                   	pop    %edi
  800e9c:	c9                   	leave  
  800e9d:	c3                   	ret    

00800e9e <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  800e9e:	55                   	push   %ebp
  800e9f:	89 e5                	mov    %esp,%ebp
  800ea1:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
  800ea4:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800ea8:	75 07                	jne    800eb1 <devcons_read+0x13>
  800eaa:	eb 25                	jmp    800ed1 <devcons_read+0x33>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  800eac:	e8 d8 f2 ff ff       	call   800189 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  800eb1:	e8 69 f2 ff ff       	call   80011f <sys_cgetc>
  800eb6:	85 c0                	test   %eax,%eax
  800eb8:	74 f2                	je     800eac <devcons_read+0xe>
  800eba:	89 c2                	mov    %eax,%edx
		sys_yield();
	if (c < 0)
  800ebc:	85 c0                	test   %eax,%eax
  800ebe:	78 1d                	js     800edd <devcons_read+0x3f>
		return c;
	if (c == 0x04)	// ctl-d is eof
  800ec0:	83 f8 04             	cmp    $0x4,%eax
  800ec3:	74 13                	je     800ed8 <devcons_read+0x3a>
		return 0;
	*(char*)vbuf = c;
  800ec5:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ec8:	88 10                	mov    %dl,(%eax)
	return 1;
  800eca:	b8 01 00 00 00       	mov    $0x1,%eax
  800ecf:	eb 0c                	jmp    800edd <devcons_read+0x3f>
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
		return 0;
  800ed1:	b8 00 00 00 00       	mov    $0x0,%eax
  800ed6:	eb 05                	jmp    800edd <devcons_read+0x3f>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  800ed8:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  800edd:	c9                   	leave  
  800ede:	c3                   	ret    

00800edf <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  800edf:	55                   	push   %ebp
  800ee0:	89 e5                	mov    %esp,%ebp
  800ee2:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  800ee5:	8b 45 08             	mov    0x8(%ebp),%eax
  800ee8:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  800eeb:	6a 01                	push   $0x1
  800eed:	8d 45 f7             	lea    -0x9(%ebp),%eax
  800ef0:	50                   	push   %eax
  800ef1:	e8 03 f2 ff ff       	call   8000f9 <sys_cputs>
  800ef6:	83 c4 10             	add    $0x10,%esp
}
  800ef9:	c9                   	leave  
  800efa:	c3                   	ret    

00800efb <getchar>:

int
getchar(void)
{
  800efb:	55                   	push   %ebp
  800efc:	89 e5                	mov    %esp,%ebp
  800efe:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  800f01:	6a 01                	push   $0x1
  800f03:	8d 45 f7             	lea    -0x9(%ebp),%eax
  800f06:	50                   	push   %eax
  800f07:	6a 00                	push   $0x0
  800f09:	e8 fe f6 ff ff       	call   80060c <read>
	if (r < 0)
  800f0e:	83 c4 10             	add    $0x10,%esp
  800f11:	85 c0                	test   %eax,%eax
  800f13:	78 0f                	js     800f24 <getchar+0x29>
		return r;
	if (r < 1)
  800f15:	85 c0                	test   %eax,%eax
  800f17:	7e 06                	jle    800f1f <getchar+0x24>
		return -E_EOF;
	return c;
  800f19:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  800f1d:	eb 05                	jmp    800f24 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  800f1f:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  800f24:	c9                   	leave  
  800f25:	c3                   	ret    

00800f26 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  800f26:	55                   	push   %ebp
  800f27:	89 e5                	mov    %esp,%ebp
  800f29:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800f2c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800f2f:	50                   	push   %eax
  800f30:	ff 75 08             	pushl  0x8(%ebp)
  800f33:	e8 53 f4 ff ff       	call   80038b <fd_lookup>
  800f38:	83 c4 10             	add    $0x10,%esp
  800f3b:	85 c0                	test   %eax,%eax
  800f3d:	78 11                	js     800f50 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  800f3f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800f42:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  800f48:	39 10                	cmp    %edx,(%eax)
  800f4a:	0f 94 c0             	sete   %al
  800f4d:	0f b6 c0             	movzbl %al,%eax
}
  800f50:	c9                   	leave  
  800f51:	c3                   	ret    

00800f52 <opencons>:

int
opencons(void)
{
  800f52:	55                   	push   %ebp
  800f53:	89 e5                	mov    %esp,%ebp
  800f55:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  800f58:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800f5b:	50                   	push   %eax
  800f5c:	e8 b7 f3 ff ff       	call   800318 <fd_alloc>
  800f61:	83 c4 10             	add    $0x10,%esp
  800f64:	85 c0                	test   %eax,%eax
  800f66:	78 3a                	js     800fa2 <opencons+0x50>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  800f68:	83 ec 04             	sub    $0x4,%esp
  800f6b:	68 07 04 00 00       	push   $0x407
  800f70:	ff 75 f4             	pushl  -0xc(%ebp)
  800f73:	6a 00                	push   $0x0
  800f75:	e8 36 f2 ff ff       	call   8001b0 <sys_page_alloc>
  800f7a:	83 c4 10             	add    $0x10,%esp
  800f7d:	85 c0                	test   %eax,%eax
  800f7f:	78 21                	js     800fa2 <opencons+0x50>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  800f81:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  800f87:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800f8a:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  800f8c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800f8f:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  800f96:	83 ec 0c             	sub    $0xc,%esp
  800f99:	50                   	push   %eax
  800f9a:	e8 51 f3 ff ff       	call   8002f0 <fd2num>
  800f9f:	83 c4 10             	add    $0x10,%esp
}
  800fa2:	c9                   	leave  
  800fa3:	c3                   	ret    

00800fa4 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800fa4:	55                   	push   %ebp
  800fa5:	89 e5                	mov    %esp,%ebp
  800fa7:	56                   	push   %esi
  800fa8:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800fa9:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800fac:	8b 1d 00 30 80 00    	mov    0x803000,%ebx
  800fb2:	e8 ae f1 ff ff       	call   800165 <sys_getenvid>
  800fb7:	83 ec 0c             	sub    $0xc,%esp
  800fba:	ff 75 0c             	pushl  0xc(%ebp)
  800fbd:	ff 75 08             	pushl  0x8(%ebp)
  800fc0:	53                   	push   %ebx
  800fc1:	50                   	push   %eax
  800fc2:	68 a4 1e 80 00       	push   $0x801ea4
  800fc7:	e8 b0 00 00 00       	call   80107c <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800fcc:	83 c4 18             	add    $0x18,%esp
  800fcf:	56                   	push   %esi
  800fd0:	ff 75 10             	pushl  0x10(%ebp)
  800fd3:	e8 53 00 00 00       	call   80102b <vcprintf>
	cprintf("\n");
  800fd8:	c7 04 24 8f 1e 80 00 	movl   $0x801e8f,(%esp)
  800fdf:	e8 98 00 00 00       	call   80107c <cprintf>
  800fe4:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800fe7:	cc                   	int3   
  800fe8:	eb fd                	jmp    800fe7 <_panic+0x43>
	...

00800fec <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800fec:	55                   	push   %ebp
  800fed:	89 e5                	mov    %esp,%ebp
  800fef:	53                   	push   %ebx
  800ff0:	83 ec 04             	sub    $0x4,%esp
  800ff3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800ff6:	8b 03                	mov    (%ebx),%eax
  800ff8:	8b 55 08             	mov    0x8(%ebp),%edx
  800ffb:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  800fff:	40                   	inc    %eax
  801000:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  801002:	3d ff 00 00 00       	cmp    $0xff,%eax
  801007:	75 1a                	jne    801023 <putch+0x37>
		sys_cputs(b->buf, b->idx);
  801009:	83 ec 08             	sub    $0x8,%esp
  80100c:	68 ff 00 00 00       	push   $0xff
  801011:	8d 43 08             	lea    0x8(%ebx),%eax
  801014:	50                   	push   %eax
  801015:	e8 df f0 ff ff       	call   8000f9 <sys_cputs>
		b->idx = 0;
  80101a:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801020:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  801023:	ff 43 04             	incl   0x4(%ebx)
}
  801026:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801029:	c9                   	leave  
  80102a:	c3                   	ret    

0080102b <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80102b:	55                   	push   %ebp
  80102c:	89 e5                	mov    %esp,%ebp
  80102e:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  801034:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80103b:	00 00 00 
	b.cnt = 0;
  80103e:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  801045:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  801048:	ff 75 0c             	pushl  0xc(%ebp)
  80104b:	ff 75 08             	pushl  0x8(%ebp)
  80104e:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  801054:	50                   	push   %eax
  801055:	68 ec 0f 80 00       	push   $0x800fec
  80105a:	e8 82 01 00 00       	call   8011e1 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80105f:	83 c4 08             	add    $0x8,%esp
  801062:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  801068:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80106e:	50                   	push   %eax
  80106f:	e8 85 f0 ff ff       	call   8000f9 <sys_cputs>

	return b.cnt;
}
  801074:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80107a:	c9                   	leave  
  80107b:	c3                   	ret    

0080107c <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80107c:	55                   	push   %ebp
  80107d:	89 e5                	mov    %esp,%ebp
  80107f:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  801082:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  801085:	50                   	push   %eax
  801086:	ff 75 08             	pushl  0x8(%ebp)
  801089:	e8 9d ff ff ff       	call   80102b <vcprintf>
	va_end(ap);

	return cnt;
}
  80108e:	c9                   	leave  
  80108f:	c3                   	ret    

00801090 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  801090:	55                   	push   %ebp
  801091:	89 e5                	mov    %esp,%ebp
  801093:	57                   	push   %edi
  801094:	56                   	push   %esi
  801095:	53                   	push   %ebx
  801096:	83 ec 2c             	sub    $0x2c,%esp
  801099:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80109c:	89 d6                	mov    %edx,%esi
  80109e:	8b 45 08             	mov    0x8(%ebp),%eax
  8010a1:	8b 55 0c             	mov    0xc(%ebp),%edx
  8010a4:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8010a7:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8010aa:	8b 45 10             	mov    0x10(%ebp),%eax
  8010ad:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8010b0:	8b 7d 18             	mov    0x18(%ebp),%edi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8010b3:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8010b6:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  8010bd:	39 55 d4             	cmp    %edx,-0x2c(%ebp)
  8010c0:	72 0c                	jb     8010ce <printnum+0x3e>
  8010c2:	3b 45 d8             	cmp    -0x28(%ebp),%eax
  8010c5:	76 07                	jbe    8010ce <printnum+0x3e>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8010c7:	4b                   	dec    %ebx
  8010c8:	85 db                	test   %ebx,%ebx
  8010ca:	7f 31                	jg     8010fd <printnum+0x6d>
  8010cc:	eb 3f                	jmp    80110d <printnum+0x7d>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8010ce:	83 ec 0c             	sub    $0xc,%esp
  8010d1:	57                   	push   %edi
  8010d2:	4b                   	dec    %ebx
  8010d3:	53                   	push   %ebx
  8010d4:	50                   	push   %eax
  8010d5:	83 ec 08             	sub    $0x8,%esp
  8010d8:	ff 75 d4             	pushl  -0x2c(%ebp)
  8010db:	ff 75 d0             	pushl  -0x30(%ebp)
  8010de:	ff 75 dc             	pushl  -0x24(%ebp)
  8010e1:	ff 75 d8             	pushl  -0x28(%ebp)
  8010e4:	e8 33 0a 00 00       	call   801b1c <__udivdi3>
  8010e9:	83 c4 18             	add    $0x18,%esp
  8010ec:	52                   	push   %edx
  8010ed:	50                   	push   %eax
  8010ee:	89 f2                	mov    %esi,%edx
  8010f0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8010f3:	e8 98 ff ff ff       	call   801090 <printnum>
  8010f8:	83 c4 20             	add    $0x20,%esp
  8010fb:	eb 10                	jmp    80110d <printnum+0x7d>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8010fd:	83 ec 08             	sub    $0x8,%esp
  801100:	56                   	push   %esi
  801101:	57                   	push   %edi
  801102:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  801105:	4b                   	dec    %ebx
  801106:	83 c4 10             	add    $0x10,%esp
  801109:	85 db                	test   %ebx,%ebx
  80110b:	7f f0                	jg     8010fd <printnum+0x6d>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80110d:	83 ec 08             	sub    $0x8,%esp
  801110:	56                   	push   %esi
  801111:	83 ec 04             	sub    $0x4,%esp
  801114:	ff 75 d4             	pushl  -0x2c(%ebp)
  801117:	ff 75 d0             	pushl  -0x30(%ebp)
  80111a:	ff 75 dc             	pushl  -0x24(%ebp)
  80111d:	ff 75 d8             	pushl  -0x28(%ebp)
  801120:	e8 13 0b 00 00       	call   801c38 <__umoddi3>
  801125:	83 c4 14             	add    $0x14,%esp
  801128:	0f be 80 c7 1e 80 00 	movsbl 0x801ec7(%eax),%eax
  80112f:	50                   	push   %eax
  801130:	ff 55 e4             	call   *-0x1c(%ebp)
  801133:	83 c4 10             	add    $0x10,%esp
}
  801136:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801139:	5b                   	pop    %ebx
  80113a:	5e                   	pop    %esi
  80113b:	5f                   	pop    %edi
  80113c:	c9                   	leave  
  80113d:	c3                   	ret    

0080113e <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80113e:	55                   	push   %ebp
  80113f:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  801141:	83 fa 01             	cmp    $0x1,%edx
  801144:	7e 0e                	jle    801154 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  801146:	8b 10                	mov    (%eax),%edx
  801148:	8d 4a 08             	lea    0x8(%edx),%ecx
  80114b:	89 08                	mov    %ecx,(%eax)
  80114d:	8b 02                	mov    (%edx),%eax
  80114f:	8b 52 04             	mov    0x4(%edx),%edx
  801152:	eb 22                	jmp    801176 <getuint+0x38>
	else if (lflag)
  801154:	85 d2                	test   %edx,%edx
  801156:	74 10                	je     801168 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  801158:	8b 10                	mov    (%eax),%edx
  80115a:	8d 4a 04             	lea    0x4(%edx),%ecx
  80115d:	89 08                	mov    %ecx,(%eax)
  80115f:	8b 02                	mov    (%edx),%eax
  801161:	ba 00 00 00 00       	mov    $0x0,%edx
  801166:	eb 0e                	jmp    801176 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  801168:	8b 10                	mov    (%eax),%edx
  80116a:	8d 4a 04             	lea    0x4(%edx),%ecx
  80116d:	89 08                	mov    %ecx,(%eax)
  80116f:	8b 02                	mov    (%edx),%eax
  801171:	ba 00 00 00 00       	mov    $0x0,%edx
}
  801176:	c9                   	leave  
  801177:	c3                   	ret    

00801178 <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
  801178:	55                   	push   %ebp
  801179:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80117b:	83 fa 01             	cmp    $0x1,%edx
  80117e:	7e 0e                	jle    80118e <getint+0x16>
		return va_arg(*ap, long long);
  801180:	8b 10                	mov    (%eax),%edx
  801182:	8d 4a 08             	lea    0x8(%edx),%ecx
  801185:	89 08                	mov    %ecx,(%eax)
  801187:	8b 02                	mov    (%edx),%eax
  801189:	8b 52 04             	mov    0x4(%edx),%edx
  80118c:	eb 1a                	jmp    8011a8 <getint+0x30>
	else if (lflag)
  80118e:	85 d2                	test   %edx,%edx
  801190:	74 0c                	je     80119e <getint+0x26>
		return va_arg(*ap, long);
  801192:	8b 10                	mov    (%eax),%edx
  801194:	8d 4a 04             	lea    0x4(%edx),%ecx
  801197:	89 08                	mov    %ecx,(%eax)
  801199:	8b 02                	mov    (%edx),%eax
  80119b:	99                   	cltd   
  80119c:	eb 0a                	jmp    8011a8 <getint+0x30>
	else
		return va_arg(*ap, int);
  80119e:	8b 10                	mov    (%eax),%edx
  8011a0:	8d 4a 04             	lea    0x4(%edx),%ecx
  8011a3:	89 08                	mov    %ecx,(%eax)
  8011a5:	8b 02                	mov    (%edx),%eax
  8011a7:	99                   	cltd   
}
  8011a8:	c9                   	leave  
  8011a9:	c3                   	ret    

008011aa <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8011aa:	55                   	push   %ebp
  8011ab:	89 e5                	mov    %esp,%ebp
  8011ad:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8011b0:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  8011b3:	8b 10                	mov    (%eax),%edx
  8011b5:	3b 50 04             	cmp    0x4(%eax),%edx
  8011b8:	73 08                	jae    8011c2 <sprintputch+0x18>
		*b->buf++ = ch;
  8011ba:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8011bd:	88 0a                	mov    %cl,(%edx)
  8011bf:	42                   	inc    %edx
  8011c0:	89 10                	mov    %edx,(%eax)
}
  8011c2:	c9                   	leave  
  8011c3:	c3                   	ret    

008011c4 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8011c4:	55                   	push   %ebp
  8011c5:	89 e5                	mov    %esp,%ebp
  8011c7:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8011ca:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8011cd:	50                   	push   %eax
  8011ce:	ff 75 10             	pushl  0x10(%ebp)
  8011d1:	ff 75 0c             	pushl  0xc(%ebp)
  8011d4:	ff 75 08             	pushl  0x8(%ebp)
  8011d7:	e8 05 00 00 00       	call   8011e1 <vprintfmt>
	va_end(ap);
  8011dc:	83 c4 10             	add    $0x10,%esp
}
  8011df:	c9                   	leave  
  8011e0:	c3                   	ret    

008011e1 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8011e1:	55                   	push   %ebp
  8011e2:	89 e5                	mov    %esp,%ebp
  8011e4:	57                   	push   %edi
  8011e5:	56                   	push   %esi
  8011e6:	53                   	push   %ebx
  8011e7:	83 ec 2c             	sub    $0x2c,%esp
  8011ea:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8011ed:	8b 75 10             	mov    0x10(%ebp),%esi
  8011f0:	eb 13                	jmp    801205 <vprintfmt+0x24>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8011f2:	85 c0                	test   %eax,%eax
  8011f4:	0f 84 6d 03 00 00    	je     801567 <vprintfmt+0x386>
				return;
			putch(ch, putdat);
  8011fa:	83 ec 08             	sub    $0x8,%esp
  8011fd:	57                   	push   %edi
  8011fe:	50                   	push   %eax
  8011ff:	ff 55 08             	call   *0x8(%ebp)
  801202:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  801205:	0f b6 06             	movzbl (%esi),%eax
  801208:	46                   	inc    %esi
  801209:	83 f8 25             	cmp    $0x25,%eax
  80120c:	75 e4                	jne    8011f2 <vprintfmt+0x11>
  80120e:	c6 45 dc 20          	movb   $0x20,-0x24(%ebp)
  801212:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  801219:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
  801220:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  801227:	b9 00 00 00 00       	mov    $0x0,%ecx
  80122c:	eb 28                	jmp    801256 <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80122e:	89 de                	mov    %ebx,%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  801230:	c6 45 dc 2d          	movb   $0x2d,-0x24(%ebp)
  801234:	eb 20                	jmp    801256 <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801236:	89 de                	mov    %ebx,%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  801238:	c6 45 dc 30          	movb   $0x30,-0x24(%ebp)
  80123c:	eb 18                	jmp    801256 <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80123e:	89 de                	mov    %ebx,%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  801240:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  801247:	eb 0d                	jmp    801256 <vprintfmt+0x75>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  801249:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80124c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80124f:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801256:	8a 06                	mov    (%esi),%al
  801258:	0f b6 d0             	movzbl %al,%edx
  80125b:	8d 5e 01             	lea    0x1(%esi),%ebx
  80125e:	83 e8 23             	sub    $0x23,%eax
  801261:	3c 55                	cmp    $0x55,%al
  801263:	0f 87 e0 02 00 00    	ja     801549 <vprintfmt+0x368>
  801269:	0f b6 c0             	movzbl %al,%eax
  80126c:	ff 24 85 00 20 80 00 	jmp    *0x802000(,%eax,4)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  801273:	83 ea 30             	sub    $0x30,%edx
  801276:	89 55 d4             	mov    %edx,-0x2c(%ebp)
				ch = *fmt;
  801279:	0f be 03             	movsbl (%ebx),%eax
				if (ch < '0' || ch > '9')
  80127c:	8d 50 d0             	lea    -0x30(%eax),%edx
  80127f:	83 fa 09             	cmp    $0x9,%edx
  801282:	77 44                	ja     8012c8 <vprintfmt+0xe7>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801284:	89 de                	mov    %ebx,%esi
  801286:	8b 55 d4             	mov    -0x2c(%ebp),%edx
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  801289:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
  80128a:	8d 14 92             	lea    (%edx,%edx,4),%edx
  80128d:	8d 54 50 d0          	lea    -0x30(%eax,%edx,2),%edx
				ch = *fmt;
  801291:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  801294:	8d 58 d0             	lea    -0x30(%eax),%ebx
  801297:	83 fb 09             	cmp    $0x9,%ebx
  80129a:	76 ed                	jbe    801289 <vprintfmt+0xa8>
  80129c:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  80129f:	eb 29                	jmp    8012ca <vprintfmt+0xe9>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8012a1:	8b 45 14             	mov    0x14(%ebp),%eax
  8012a4:	8d 50 04             	lea    0x4(%eax),%edx
  8012a7:	89 55 14             	mov    %edx,0x14(%ebp)
  8012aa:	8b 00                	mov    (%eax),%eax
  8012ac:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8012af:	89 de                	mov    %ebx,%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8012b1:	eb 17                	jmp    8012ca <vprintfmt+0xe9>

		case '.':
			if (width < 0)
  8012b3:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8012b7:	78 85                	js     80123e <vprintfmt+0x5d>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8012b9:	89 de                	mov    %ebx,%esi
  8012bb:	eb 99                	jmp    801256 <vprintfmt+0x75>
  8012bd:	89 de                	mov    %ebx,%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8012bf:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
			goto reswitch;
  8012c6:	eb 8e                	jmp    801256 <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8012c8:	89 de                	mov    %ebx,%esi
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  8012ca:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8012ce:	79 86                	jns    801256 <vprintfmt+0x75>
  8012d0:	e9 74 ff ff ff       	jmp    801249 <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8012d5:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8012d6:	89 de                	mov    %ebx,%esi
  8012d8:	e9 79 ff ff ff       	jmp    801256 <vprintfmt+0x75>
  8012dd:	89 5d d8             	mov    %ebx,-0x28(%ebp)
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8012e0:	8b 45 14             	mov    0x14(%ebp),%eax
  8012e3:	8d 50 04             	lea    0x4(%eax),%edx
  8012e6:	89 55 14             	mov    %edx,0x14(%ebp)
  8012e9:	83 ec 08             	sub    $0x8,%esp
  8012ec:	57                   	push   %edi
  8012ed:	ff 30                	pushl  (%eax)
  8012ef:	ff 55 08             	call   *0x8(%ebp)
			break;
  8012f2:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8012f5:	8b 75 d8             	mov    -0x28(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8012f8:	e9 08 ff ff ff       	jmp    801205 <vprintfmt+0x24>
  8012fd:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// error message
		case 'e':
			err = va_arg(ap, int);
  801300:	8b 45 14             	mov    0x14(%ebp),%eax
  801303:	8d 50 04             	lea    0x4(%eax),%edx
  801306:	89 55 14             	mov    %edx,0x14(%ebp)
  801309:	8b 00                	mov    (%eax),%eax
  80130b:	85 c0                	test   %eax,%eax
  80130d:	79 02                	jns    801311 <vprintfmt+0x130>
  80130f:	f7 d8                	neg    %eax
  801311:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  801313:	83 f8 0f             	cmp    $0xf,%eax
  801316:	7f 0b                	jg     801323 <vprintfmt+0x142>
  801318:	8b 04 85 60 21 80 00 	mov    0x802160(,%eax,4),%eax
  80131f:	85 c0                	test   %eax,%eax
  801321:	75 1a                	jne    80133d <vprintfmt+0x15c>
				printfmt(putch, putdat, "error %d", err);
  801323:	52                   	push   %edx
  801324:	68 df 1e 80 00       	push   $0x801edf
  801329:	57                   	push   %edi
  80132a:	ff 75 08             	pushl  0x8(%ebp)
  80132d:	e8 92 fe ff ff       	call   8011c4 <printfmt>
  801332:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801335:	8b 75 d8             	mov    -0x28(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  801338:	e9 c8 fe ff ff       	jmp    801205 <vprintfmt+0x24>
			else
				printfmt(putch, putdat, "%s", p);
  80133d:	50                   	push   %eax
  80133e:	68 5d 1e 80 00       	push   $0x801e5d
  801343:	57                   	push   %edi
  801344:	ff 75 08             	pushl  0x8(%ebp)
  801347:	e8 78 fe ff ff       	call   8011c4 <printfmt>
  80134c:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80134f:	8b 75 d8             	mov    -0x28(%ebp),%esi
  801352:	e9 ae fe ff ff       	jmp    801205 <vprintfmt+0x24>
  801357:	89 5d d8             	mov    %ebx,-0x28(%ebp)
  80135a:	89 de                	mov    %ebx,%esi
  80135c:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  80135f:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  801362:	8b 45 14             	mov    0x14(%ebp),%eax
  801365:	8d 50 04             	lea    0x4(%eax),%edx
  801368:	89 55 14             	mov    %edx,0x14(%ebp)
  80136b:	8b 00                	mov    (%eax),%eax
  80136d:	89 45 d0             	mov    %eax,-0x30(%ebp)
  801370:	85 c0                	test   %eax,%eax
  801372:	75 07                	jne    80137b <vprintfmt+0x19a>
				p = "(null)";
  801374:	c7 45 d0 d8 1e 80 00 	movl   $0x801ed8,-0x30(%ebp)
			if (width > 0 && padc != '-')
  80137b:	85 db                	test   %ebx,%ebx
  80137d:	7e 42                	jle    8013c1 <vprintfmt+0x1e0>
  80137f:	80 7d dc 2d          	cmpb   $0x2d,-0x24(%ebp)
  801383:	74 3c                	je     8013c1 <vprintfmt+0x1e0>
				for (width -= strnlen(p, precision); width > 0; width--)
  801385:	83 ec 08             	sub    $0x8,%esp
  801388:	51                   	push   %ecx
  801389:	ff 75 d0             	pushl  -0x30(%ebp)
  80138c:	e8 6f 02 00 00       	call   801600 <strnlen>
  801391:	29 c3                	sub    %eax,%ebx
  801393:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  801396:	83 c4 10             	add    $0x10,%esp
  801399:	85 db                	test   %ebx,%ebx
  80139b:	7e 24                	jle    8013c1 <vprintfmt+0x1e0>
					putch(padc, putdat);
  80139d:	0f be 5d dc          	movsbl -0x24(%ebp),%ebx
  8013a1:	89 75 dc             	mov    %esi,-0x24(%ebp)
  8013a4:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  8013a7:	83 ec 08             	sub    $0x8,%esp
  8013aa:	57                   	push   %edi
  8013ab:	53                   	push   %ebx
  8013ac:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8013af:	4e                   	dec    %esi
  8013b0:	83 c4 10             	add    $0x10,%esp
  8013b3:	85 f6                	test   %esi,%esi
  8013b5:	7f f0                	jg     8013a7 <vprintfmt+0x1c6>
  8013b7:	8b 75 dc             	mov    -0x24(%ebp),%esi
  8013ba:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8013c1:	8b 55 d0             	mov    -0x30(%ebp),%edx
  8013c4:	0f be 02             	movsbl (%edx),%eax
  8013c7:	85 c0                	test   %eax,%eax
  8013c9:	75 47                	jne    801412 <vprintfmt+0x231>
  8013cb:	eb 37                	jmp    801404 <vprintfmt+0x223>
				if (altflag && (ch < ' ' || ch > '~'))
  8013cd:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8013d1:	74 16                	je     8013e9 <vprintfmt+0x208>
  8013d3:	8d 50 e0             	lea    -0x20(%eax),%edx
  8013d6:	83 fa 5e             	cmp    $0x5e,%edx
  8013d9:	76 0e                	jbe    8013e9 <vprintfmt+0x208>
					putch('?', putdat);
  8013db:	83 ec 08             	sub    $0x8,%esp
  8013de:	57                   	push   %edi
  8013df:	6a 3f                	push   $0x3f
  8013e1:	ff 55 08             	call   *0x8(%ebp)
  8013e4:	83 c4 10             	add    $0x10,%esp
  8013e7:	eb 0b                	jmp    8013f4 <vprintfmt+0x213>
				else
					putch(ch, putdat);
  8013e9:	83 ec 08             	sub    $0x8,%esp
  8013ec:	57                   	push   %edi
  8013ed:	50                   	push   %eax
  8013ee:	ff 55 08             	call   *0x8(%ebp)
  8013f1:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8013f4:	ff 4d e4             	decl   -0x1c(%ebp)
  8013f7:	0f be 03             	movsbl (%ebx),%eax
  8013fa:	85 c0                	test   %eax,%eax
  8013fc:	74 03                	je     801401 <vprintfmt+0x220>
  8013fe:	43                   	inc    %ebx
  8013ff:	eb 1b                	jmp    80141c <vprintfmt+0x23b>
  801401:	8b 75 dc             	mov    -0x24(%ebp),%esi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  801404:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  801408:	7f 1e                	jg     801428 <vprintfmt+0x247>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80140a:	8b 75 d8             	mov    -0x28(%ebp),%esi
  80140d:	e9 f3 fd ff ff       	jmp    801205 <vprintfmt+0x24>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  801412:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  801415:	43                   	inc    %ebx
  801416:	89 75 dc             	mov    %esi,-0x24(%ebp)
  801419:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  80141c:	85 f6                	test   %esi,%esi
  80141e:	78 ad                	js     8013cd <vprintfmt+0x1ec>
  801420:	4e                   	dec    %esi
  801421:	79 aa                	jns    8013cd <vprintfmt+0x1ec>
  801423:	8b 75 dc             	mov    -0x24(%ebp),%esi
  801426:	eb dc                	jmp    801404 <vprintfmt+0x223>
  801428:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80142b:	83 ec 08             	sub    $0x8,%esp
  80142e:	57                   	push   %edi
  80142f:	6a 20                	push   $0x20
  801431:	ff 55 08             	call   *0x8(%ebp)
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  801434:	4b                   	dec    %ebx
  801435:	83 c4 10             	add    $0x10,%esp
  801438:	85 db                	test   %ebx,%ebx
  80143a:	7f ef                	jg     80142b <vprintfmt+0x24a>
  80143c:	e9 c4 fd ff ff       	jmp    801205 <vprintfmt+0x24>
  801441:	89 5d d8             	mov    %ebx,-0x28(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  801444:	89 ca                	mov    %ecx,%edx
  801446:	8d 45 14             	lea    0x14(%ebp),%eax
  801449:	e8 2a fd ff ff       	call   801178 <getint>
  80144e:	89 c3                	mov    %eax,%ebx
  801450:	89 d6                	mov    %edx,%esi
			if ((long long) num < 0) {
  801452:	85 d2                	test   %edx,%edx
  801454:	78 0a                	js     801460 <vprintfmt+0x27f>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  801456:	b8 0a 00 00 00       	mov    $0xa,%eax
  80145b:	e9 b0 00 00 00       	jmp    801510 <vprintfmt+0x32f>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  801460:	83 ec 08             	sub    $0x8,%esp
  801463:	57                   	push   %edi
  801464:	6a 2d                	push   $0x2d
  801466:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  801469:	f7 db                	neg    %ebx
  80146b:	83 d6 00             	adc    $0x0,%esi
  80146e:	f7 de                	neg    %esi
  801470:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  801473:	b8 0a 00 00 00       	mov    $0xa,%eax
  801478:	e9 93 00 00 00       	jmp    801510 <vprintfmt+0x32f>
  80147d:	89 5d d8             	mov    %ebx,-0x28(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  801480:	89 ca                	mov    %ecx,%edx
  801482:	8d 45 14             	lea    0x14(%ebp),%eax
  801485:	e8 b4 fc ff ff       	call   80113e <getuint>
  80148a:	89 c3                	mov    %eax,%ebx
  80148c:	89 d6                	mov    %edx,%esi
			base = 10;
  80148e:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  801493:	eb 7b                	jmp    801510 <vprintfmt+0x32f>
  801495:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// (unsigned) octal
		case 'o':
            // (MIT 6.828, lab1, Ex.8)  my code : 
            num = getint(&ap, lflag);
  801498:	89 ca                	mov    %ecx,%edx
  80149a:	8d 45 14             	lea    0x14(%ebp),%eax
  80149d:	e8 d6 fc ff ff       	call   801178 <getint>
  8014a2:	89 c3                	mov    %eax,%ebx
  8014a4:	89 d6                	mov    %edx,%esi
            if ((long long) num < 0) {
  8014a6:	85 d2                	test   %edx,%edx
  8014a8:	78 07                	js     8014b1 <vprintfmt+0x2d0>
                putch('-', putdat);
                num = -(long long) num;
            }
            base = 8;
  8014aa:	b8 08 00 00 00       	mov    $0x8,%eax
  8014af:	eb 5f                	jmp    801510 <vprintfmt+0x32f>
		// (unsigned) octal
		case 'o':
            // (MIT 6.828, lab1, Ex.8)  my code : 
            num = getint(&ap, lflag);
            if ((long long) num < 0) {
                putch('-', putdat);
  8014b1:	83 ec 08             	sub    $0x8,%esp
  8014b4:	57                   	push   %edi
  8014b5:	6a 2d                	push   $0x2d
  8014b7:	ff 55 08             	call   *0x8(%ebp)
                num = -(long long) num;
  8014ba:	f7 db                	neg    %ebx
  8014bc:	83 d6 00             	adc    $0x0,%esi
  8014bf:	f7 de                	neg    %esi
  8014c1:	83 c4 10             	add    $0x10,%esp
            }
            base = 8;
  8014c4:	b8 08 00 00 00       	mov    $0x8,%eax
  8014c9:	eb 45                	jmp    801510 <vprintfmt+0x32f>
  8014cb:	89 5d d8             	mov    %ebx,-0x28(%ebp)
            goto number;

        // pointer
		case 'p':
			putch('0', putdat);
  8014ce:	83 ec 08             	sub    $0x8,%esp
  8014d1:	57                   	push   %edi
  8014d2:	6a 30                	push   $0x30
  8014d4:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  8014d7:	83 c4 08             	add    $0x8,%esp
  8014da:	57                   	push   %edi
  8014db:	6a 78                	push   $0x78
  8014dd:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8014e0:	8b 45 14             	mov    0x14(%ebp),%eax
  8014e3:	8d 50 04             	lea    0x4(%eax),%edx
  8014e6:	89 55 14             	mov    %edx,0x14(%ebp)

        // pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8014e9:	8b 18                	mov    (%eax),%ebx
  8014eb:	be 00 00 00 00       	mov    $0x0,%esi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8014f0:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8014f3:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  8014f8:	eb 16                	jmp    801510 <vprintfmt+0x32f>
  8014fa:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8014fd:	89 ca                	mov    %ecx,%edx
  8014ff:	8d 45 14             	lea    0x14(%ebp),%eax
  801502:	e8 37 fc ff ff       	call   80113e <getuint>
  801507:	89 c3                	mov    %eax,%ebx
  801509:	89 d6                	mov    %edx,%esi
			base = 16;
  80150b:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  801510:	83 ec 0c             	sub    $0xc,%esp
  801513:	0f be 55 dc          	movsbl -0x24(%ebp),%edx
  801517:	52                   	push   %edx
  801518:	ff 75 e4             	pushl  -0x1c(%ebp)
  80151b:	50                   	push   %eax
  80151c:	56                   	push   %esi
  80151d:	53                   	push   %ebx
  80151e:	89 fa                	mov    %edi,%edx
  801520:	8b 45 08             	mov    0x8(%ebp),%eax
  801523:	e8 68 fb ff ff       	call   801090 <printnum>
			break;
  801528:	83 c4 20             	add    $0x20,%esp
  80152b:	8b 75 d8             	mov    -0x28(%ebp),%esi
  80152e:	e9 d2 fc ff ff       	jmp    801205 <vprintfmt+0x24>
  801533:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  801536:	83 ec 08             	sub    $0x8,%esp
  801539:	57                   	push   %edi
  80153a:	52                   	push   %edx
  80153b:	ff 55 08             	call   *0x8(%ebp)
			break;
  80153e:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801541:	8b 75 d8             	mov    -0x28(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  801544:	e9 bc fc ff ff       	jmp    801205 <vprintfmt+0x24>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  801549:	83 ec 08             	sub    $0x8,%esp
  80154c:	57                   	push   %edi
  80154d:	6a 25                	push   $0x25
  80154f:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  801552:	83 c4 10             	add    $0x10,%esp
  801555:	eb 02                	jmp    801559 <vprintfmt+0x378>
  801557:	89 c6                	mov    %eax,%esi
  801559:	8d 46 ff             	lea    -0x1(%esi),%eax
  80155c:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  801560:	75 f5                	jne    801557 <vprintfmt+0x376>
  801562:	e9 9e fc ff ff       	jmp    801205 <vprintfmt+0x24>
				/* do nothing */;
			break;
		}
	}
}
  801567:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80156a:	5b                   	pop    %ebx
  80156b:	5e                   	pop    %esi
  80156c:	5f                   	pop    %edi
  80156d:	c9                   	leave  
  80156e:	c3                   	ret    

0080156f <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80156f:	55                   	push   %ebp
  801570:	89 e5                	mov    %esp,%ebp
  801572:	83 ec 18             	sub    $0x18,%esp
  801575:	8b 45 08             	mov    0x8(%ebp),%eax
  801578:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80157b:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80157e:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  801582:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  801585:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80158c:	85 c0                	test   %eax,%eax
  80158e:	74 26                	je     8015b6 <vsnprintf+0x47>
  801590:	85 d2                	test   %edx,%edx
  801592:	7e 29                	jle    8015bd <vsnprintf+0x4e>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  801594:	ff 75 14             	pushl  0x14(%ebp)
  801597:	ff 75 10             	pushl  0x10(%ebp)
  80159a:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80159d:	50                   	push   %eax
  80159e:	68 aa 11 80 00       	push   $0x8011aa
  8015a3:	e8 39 fc ff ff       	call   8011e1 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8015a8:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8015ab:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8015ae:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8015b1:	83 c4 10             	add    $0x10,%esp
  8015b4:	eb 0c                	jmp    8015c2 <vsnprintf+0x53>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8015b6:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8015bb:	eb 05                	jmp    8015c2 <vsnprintf+0x53>
  8015bd:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8015c2:	c9                   	leave  
  8015c3:	c3                   	ret    

008015c4 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8015c4:	55                   	push   %ebp
  8015c5:	89 e5                	mov    %esp,%ebp
  8015c7:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8015ca:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8015cd:	50                   	push   %eax
  8015ce:	ff 75 10             	pushl  0x10(%ebp)
  8015d1:	ff 75 0c             	pushl  0xc(%ebp)
  8015d4:	ff 75 08             	pushl  0x8(%ebp)
  8015d7:	e8 93 ff ff ff       	call   80156f <vsnprintf>
	va_end(ap);

	return rc;
}
  8015dc:	c9                   	leave  
  8015dd:	c3                   	ret    
	...

008015e0 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8015e0:	55                   	push   %ebp
  8015e1:	89 e5                	mov    %esp,%ebp
  8015e3:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8015e6:	80 3a 00             	cmpb   $0x0,(%edx)
  8015e9:	74 0e                	je     8015f9 <strlen+0x19>
  8015eb:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  8015f0:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8015f1:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8015f5:	75 f9                	jne    8015f0 <strlen+0x10>
  8015f7:	eb 05                	jmp    8015fe <strlen+0x1e>
  8015f9:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  8015fe:	c9                   	leave  
  8015ff:	c3                   	ret    

00801600 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  801600:	55                   	push   %ebp
  801601:	89 e5                	mov    %esp,%ebp
  801603:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801606:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801609:	85 d2                	test   %edx,%edx
  80160b:	74 17                	je     801624 <strnlen+0x24>
  80160d:	80 39 00             	cmpb   $0x0,(%ecx)
  801610:	74 19                	je     80162b <strnlen+0x2b>
  801612:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  801617:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801618:	39 d0                	cmp    %edx,%eax
  80161a:	74 14                	je     801630 <strnlen+0x30>
  80161c:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  801620:	75 f5                	jne    801617 <strnlen+0x17>
  801622:	eb 0c                	jmp    801630 <strnlen+0x30>
  801624:	b8 00 00 00 00       	mov    $0x0,%eax
  801629:	eb 05                	jmp    801630 <strnlen+0x30>
  80162b:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  801630:	c9                   	leave  
  801631:	c3                   	ret    

00801632 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  801632:	55                   	push   %ebp
  801633:	89 e5                	mov    %esp,%ebp
  801635:	53                   	push   %ebx
  801636:	8b 45 08             	mov    0x8(%ebp),%eax
  801639:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  80163c:	ba 00 00 00 00       	mov    $0x0,%edx
  801641:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  801644:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  801647:	42                   	inc    %edx
  801648:	84 c9                	test   %cl,%cl
  80164a:	75 f5                	jne    801641 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  80164c:	5b                   	pop    %ebx
  80164d:	c9                   	leave  
  80164e:	c3                   	ret    

0080164f <strcat>:

char *
strcat(char *dst, const char *src)
{
  80164f:	55                   	push   %ebp
  801650:	89 e5                	mov    %esp,%ebp
  801652:	53                   	push   %ebx
  801653:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  801656:	53                   	push   %ebx
  801657:	e8 84 ff ff ff       	call   8015e0 <strlen>
  80165c:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  80165f:	ff 75 0c             	pushl  0xc(%ebp)
  801662:	8d 04 03             	lea    (%ebx,%eax,1),%eax
  801665:	50                   	push   %eax
  801666:	e8 c7 ff ff ff       	call   801632 <strcpy>
	return dst;
}
  80166b:	89 d8                	mov    %ebx,%eax
  80166d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801670:	c9                   	leave  
  801671:	c3                   	ret    

00801672 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  801672:	55                   	push   %ebp
  801673:	89 e5                	mov    %esp,%ebp
  801675:	56                   	push   %esi
  801676:	53                   	push   %ebx
  801677:	8b 45 08             	mov    0x8(%ebp),%eax
  80167a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80167d:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801680:	85 f6                	test   %esi,%esi
  801682:	74 15                	je     801699 <strncpy+0x27>
  801684:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
  801689:	8a 1a                	mov    (%edx),%bl
  80168b:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80168e:	80 3a 01             	cmpb   $0x1,(%edx)
  801691:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801694:	41                   	inc    %ecx
  801695:	39 ce                	cmp    %ecx,%esi
  801697:	77 f0                	ja     801689 <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  801699:	5b                   	pop    %ebx
  80169a:	5e                   	pop    %esi
  80169b:	c9                   	leave  
  80169c:	c3                   	ret    

0080169d <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80169d:	55                   	push   %ebp
  80169e:	89 e5                	mov    %esp,%ebp
  8016a0:	57                   	push   %edi
  8016a1:	56                   	push   %esi
  8016a2:	53                   	push   %ebx
  8016a3:	8b 7d 08             	mov    0x8(%ebp),%edi
  8016a6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8016a9:	8b 75 10             	mov    0x10(%ebp),%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8016ac:	85 f6                	test   %esi,%esi
  8016ae:	74 32                	je     8016e2 <strlcpy+0x45>
		while (--size > 0 && *src != '\0')
  8016b0:	83 fe 01             	cmp    $0x1,%esi
  8016b3:	74 22                	je     8016d7 <strlcpy+0x3a>
  8016b5:	8a 0b                	mov    (%ebx),%cl
  8016b7:	84 c9                	test   %cl,%cl
  8016b9:	74 20                	je     8016db <strlcpy+0x3e>
  8016bb:	89 f8                	mov    %edi,%eax
  8016bd:	ba 00 00 00 00       	mov    $0x0,%edx
	}
	return ret;
}

size_t
strlcpy(char *dst, const char *src, size_t size)
  8016c2:	83 ee 02             	sub    $0x2,%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8016c5:	88 08                	mov    %cl,(%eax)
  8016c7:	40                   	inc    %eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8016c8:	39 f2                	cmp    %esi,%edx
  8016ca:	74 11                	je     8016dd <strlcpy+0x40>
  8016cc:	8a 4c 13 01          	mov    0x1(%ebx,%edx,1),%cl
  8016d0:	42                   	inc    %edx
  8016d1:	84 c9                	test   %cl,%cl
  8016d3:	75 f0                	jne    8016c5 <strlcpy+0x28>
  8016d5:	eb 06                	jmp    8016dd <strlcpy+0x40>
  8016d7:	89 f8                	mov    %edi,%eax
  8016d9:	eb 02                	jmp    8016dd <strlcpy+0x40>
  8016db:	89 f8                	mov    %edi,%eax
			*dst++ = *src++;
		*dst = '\0';
  8016dd:	c6 00 00             	movb   $0x0,(%eax)
  8016e0:	eb 02                	jmp    8016e4 <strlcpy+0x47>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8016e2:	89 f8                	mov    %edi,%eax
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
		*dst = '\0';
	}
	return dst - dst_in;
  8016e4:	29 f8                	sub    %edi,%eax
}
  8016e6:	5b                   	pop    %ebx
  8016e7:	5e                   	pop    %esi
  8016e8:	5f                   	pop    %edi
  8016e9:	c9                   	leave  
  8016ea:	c3                   	ret    

008016eb <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8016eb:	55                   	push   %ebp
  8016ec:	89 e5                	mov    %esp,%ebp
  8016ee:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8016f1:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8016f4:	8a 01                	mov    (%ecx),%al
  8016f6:	84 c0                	test   %al,%al
  8016f8:	74 10                	je     80170a <strcmp+0x1f>
  8016fa:	3a 02                	cmp    (%edx),%al
  8016fc:	75 0c                	jne    80170a <strcmp+0x1f>
		p++, q++;
  8016fe:	41                   	inc    %ecx
  8016ff:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  801700:	8a 01                	mov    (%ecx),%al
  801702:	84 c0                	test   %al,%al
  801704:	74 04                	je     80170a <strcmp+0x1f>
  801706:	3a 02                	cmp    (%edx),%al
  801708:	74 f4                	je     8016fe <strcmp+0x13>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  80170a:	0f b6 c0             	movzbl %al,%eax
  80170d:	0f b6 12             	movzbl (%edx),%edx
  801710:	29 d0                	sub    %edx,%eax
}
  801712:	c9                   	leave  
  801713:	c3                   	ret    

00801714 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  801714:	55                   	push   %ebp
  801715:	89 e5                	mov    %esp,%ebp
  801717:	53                   	push   %ebx
  801718:	8b 55 08             	mov    0x8(%ebp),%edx
  80171b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80171e:	8b 45 10             	mov    0x10(%ebp),%eax
	while (n > 0 && *p && *p == *q)
  801721:	85 c0                	test   %eax,%eax
  801723:	74 1b                	je     801740 <strncmp+0x2c>
  801725:	8a 1a                	mov    (%edx),%bl
  801727:	84 db                	test   %bl,%bl
  801729:	74 24                	je     80174f <strncmp+0x3b>
  80172b:	3a 19                	cmp    (%ecx),%bl
  80172d:	75 20                	jne    80174f <strncmp+0x3b>
  80172f:	48                   	dec    %eax
  801730:	74 15                	je     801747 <strncmp+0x33>
		n--, p++, q++;
  801732:	42                   	inc    %edx
  801733:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  801734:	8a 1a                	mov    (%edx),%bl
  801736:	84 db                	test   %bl,%bl
  801738:	74 15                	je     80174f <strncmp+0x3b>
  80173a:	3a 19                	cmp    (%ecx),%bl
  80173c:	74 f1                	je     80172f <strncmp+0x1b>
  80173e:	eb 0f                	jmp    80174f <strncmp+0x3b>
		n--, p++, q++;
	if (n == 0)
		return 0;
  801740:	b8 00 00 00 00       	mov    $0x0,%eax
  801745:	eb 05                	jmp    80174c <strncmp+0x38>
  801747:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  80174c:	5b                   	pop    %ebx
  80174d:	c9                   	leave  
  80174e:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80174f:	0f b6 02             	movzbl (%edx),%eax
  801752:	0f b6 11             	movzbl (%ecx),%edx
  801755:	29 d0                	sub    %edx,%eax
  801757:	eb f3                	jmp    80174c <strncmp+0x38>

00801759 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  801759:	55                   	push   %ebp
  80175a:	89 e5                	mov    %esp,%ebp
  80175c:	8b 45 08             	mov    0x8(%ebp),%eax
  80175f:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  801762:	8a 10                	mov    (%eax),%dl
  801764:	84 d2                	test   %dl,%dl
  801766:	74 18                	je     801780 <strchr+0x27>
		if (*s == c)
  801768:	38 ca                	cmp    %cl,%dl
  80176a:	75 06                	jne    801772 <strchr+0x19>
  80176c:	eb 17                	jmp    801785 <strchr+0x2c>
  80176e:	38 ca                	cmp    %cl,%dl
  801770:	74 13                	je     801785 <strchr+0x2c>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  801772:	40                   	inc    %eax
  801773:	8a 10                	mov    (%eax),%dl
  801775:	84 d2                	test   %dl,%dl
  801777:	75 f5                	jne    80176e <strchr+0x15>
		if (*s == c)
			return (char *) s;
	return 0;
  801779:	b8 00 00 00 00       	mov    $0x0,%eax
  80177e:	eb 05                	jmp    801785 <strchr+0x2c>
  801780:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801785:	c9                   	leave  
  801786:	c3                   	ret    

00801787 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  801787:	55                   	push   %ebp
  801788:	89 e5                	mov    %esp,%ebp
  80178a:	8b 45 08             	mov    0x8(%ebp),%eax
  80178d:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  801790:	8a 10                	mov    (%eax),%dl
  801792:	84 d2                	test   %dl,%dl
  801794:	74 11                	je     8017a7 <strfind+0x20>
		if (*s == c)
  801796:	38 ca                	cmp    %cl,%dl
  801798:	75 06                	jne    8017a0 <strfind+0x19>
  80179a:	eb 0b                	jmp    8017a7 <strfind+0x20>
  80179c:	38 ca                	cmp    %cl,%dl
  80179e:	74 07                	je     8017a7 <strfind+0x20>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  8017a0:	40                   	inc    %eax
  8017a1:	8a 10                	mov    (%eax),%dl
  8017a3:	84 d2                	test   %dl,%dl
  8017a5:	75 f5                	jne    80179c <strfind+0x15>
		if (*s == c)
			break;
	return (char *) s;
}
  8017a7:	c9                   	leave  
  8017a8:	c3                   	ret    

008017a9 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8017a9:	55                   	push   %ebp
  8017aa:	89 e5                	mov    %esp,%ebp
  8017ac:	57                   	push   %edi
  8017ad:	56                   	push   %esi
  8017ae:	53                   	push   %ebx
  8017af:	8b 7d 08             	mov    0x8(%ebp),%edi
  8017b2:	8b 45 0c             	mov    0xc(%ebp),%eax
  8017b5:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8017b8:	85 c9                	test   %ecx,%ecx
  8017ba:	74 30                	je     8017ec <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8017bc:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8017c2:	75 25                	jne    8017e9 <memset+0x40>
  8017c4:	f6 c1 03             	test   $0x3,%cl
  8017c7:	75 20                	jne    8017e9 <memset+0x40>
		c &= 0xFF;
  8017c9:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8017cc:	89 d3                	mov    %edx,%ebx
  8017ce:	c1 e3 08             	shl    $0x8,%ebx
  8017d1:	89 d6                	mov    %edx,%esi
  8017d3:	c1 e6 18             	shl    $0x18,%esi
  8017d6:	89 d0                	mov    %edx,%eax
  8017d8:	c1 e0 10             	shl    $0x10,%eax
  8017db:	09 f0                	or     %esi,%eax
  8017dd:	09 d0                	or     %edx,%eax
  8017df:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  8017e1:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  8017e4:	fc                   	cld    
  8017e5:	f3 ab                	rep stos %eax,%es:(%edi)
  8017e7:	eb 03                	jmp    8017ec <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8017e9:	fc                   	cld    
  8017ea:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8017ec:	89 f8                	mov    %edi,%eax
  8017ee:	5b                   	pop    %ebx
  8017ef:	5e                   	pop    %esi
  8017f0:	5f                   	pop    %edi
  8017f1:	c9                   	leave  
  8017f2:	c3                   	ret    

008017f3 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8017f3:	55                   	push   %ebp
  8017f4:	89 e5                	mov    %esp,%ebp
  8017f6:	57                   	push   %edi
  8017f7:	56                   	push   %esi
  8017f8:	8b 45 08             	mov    0x8(%ebp),%eax
  8017fb:	8b 75 0c             	mov    0xc(%ebp),%esi
  8017fe:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  801801:	39 c6                	cmp    %eax,%esi
  801803:	73 34                	jae    801839 <memmove+0x46>
  801805:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  801808:	39 d0                	cmp    %edx,%eax
  80180a:	73 2d                	jae    801839 <memmove+0x46>
		s += n;
		d += n;
  80180c:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80180f:	f6 c2 03             	test   $0x3,%dl
  801812:	75 1b                	jne    80182f <memmove+0x3c>
  801814:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80181a:	75 13                	jne    80182f <memmove+0x3c>
  80181c:	f6 c1 03             	test   $0x3,%cl
  80181f:	75 0e                	jne    80182f <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  801821:	83 ef 04             	sub    $0x4,%edi
  801824:	8d 72 fc             	lea    -0x4(%edx),%esi
  801827:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  80182a:	fd                   	std    
  80182b:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80182d:	eb 07                	jmp    801836 <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  80182f:	4f                   	dec    %edi
  801830:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  801833:	fd                   	std    
  801834:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  801836:	fc                   	cld    
  801837:	eb 20                	jmp    801859 <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801839:	f7 c6 03 00 00 00    	test   $0x3,%esi
  80183f:	75 13                	jne    801854 <memmove+0x61>
  801841:	a8 03                	test   $0x3,%al
  801843:	75 0f                	jne    801854 <memmove+0x61>
  801845:	f6 c1 03             	test   $0x3,%cl
  801848:	75 0a                	jne    801854 <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  80184a:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  80184d:	89 c7                	mov    %eax,%edi
  80184f:	fc                   	cld    
  801850:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801852:	eb 05                	jmp    801859 <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  801854:	89 c7                	mov    %eax,%edi
  801856:	fc                   	cld    
  801857:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  801859:	5e                   	pop    %esi
  80185a:	5f                   	pop    %edi
  80185b:	c9                   	leave  
  80185c:	c3                   	ret    

0080185d <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  80185d:	55                   	push   %ebp
  80185e:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  801860:	ff 75 10             	pushl  0x10(%ebp)
  801863:	ff 75 0c             	pushl  0xc(%ebp)
  801866:	ff 75 08             	pushl  0x8(%ebp)
  801869:	e8 85 ff ff ff       	call   8017f3 <memmove>
}
  80186e:	c9                   	leave  
  80186f:	c3                   	ret    

00801870 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  801870:	55                   	push   %ebp
  801871:	89 e5                	mov    %esp,%ebp
  801873:	57                   	push   %edi
  801874:	56                   	push   %esi
  801875:	53                   	push   %ebx
  801876:	8b 5d 08             	mov    0x8(%ebp),%ebx
  801879:	8b 75 0c             	mov    0xc(%ebp),%esi
  80187c:	8b 7d 10             	mov    0x10(%ebp),%edi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  80187f:	85 ff                	test   %edi,%edi
  801881:	74 32                	je     8018b5 <memcmp+0x45>
		if (*s1 != *s2)
  801883:	8a 03                	mov    (%ebx),%al
  801885:	8a 0e                	mov    (%esi),%cl
  801887:	38 c8                	cmp    %cl,%al
  801889:	74 19                	je     8018a4 <memcmp+0x34>
  80188b:	eb 0d                	jmp    80189a <memcmp+0x2a>
  80188d:	8a 44 13 01          	mov    0x1(%ebx,%edx,1),%al
  801891:	8a 4c 16 01          	mov    0x1(%esi,%edx,1),%cl
  801895:	42                   	inc    %edx
  801896:	38 c8                	cmp    %cl,%al
  801898:	74 10                	je     8018aa <memcmp+0x3a>
			return (int) *s1 - (int) *s2;
  80189a:	0f b6 c0             	movzbl %al,%eax
  80189d:	0f b6 c9             	movzbl %cl,%ecx
  8018a0:	29 c8                	sub    %ecx,%eax
  8018a2:	eb 16                	jmp    8018ba <memcmp+0x4a>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8018a4:	4f                   	dec    %edi
  8018a5:	ba 00 00 00 00       	mov    $0x0,%edx
  8018aa:	39 fa                	cmp    %edi,%edx
  8018ac:	75 df                	jne    80188d <memcmp+0x1d>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  8018ae:	b8 00 00 00 00       	mov    $0x0,%eax
  8018b3:	eb 05                	jmp    8018ba <memcmp+0x4a>
  8018b5:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8018ba:	5b                   	pop    %ebx
  8018bb:	5e                   	pop    %esi
  8018bc:	5f                   	pop    %edi
  8018bd:	c9                   	leave  
  8018be:	c3                   	ret    

008018bf <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8018bf:	55                   	push   %ebp
  8018c0:	89 e5                	mov    %esp,%ebp
  8018c2:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  8018c5:	89 c2                	mov    %eax,%edx
  8018c7:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  8018ca:	39 d0                	cmp    %edx,%eax
  8018cc:	73 12                	jae    8018e0 <memfind+0x21>
		if (*(const unsigned char *) s == (unsigned char) c)
  8018ce:	8a 4d 0c             	mov    0xc(%ebp),%cl
  8018d1:	38 08                	cmp    %cl,(%eax)
  8018d3:	75 06                	jne    8018db <memfind+0x1c>
  8018d5:	eb 09                	jmp    8018e0 <memfind+0x21>
  8018d7:	38 08                	cmp    %cl,(%eax)
  8018d9:	74 05                	je     8018e0 <memfind+0x21>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8018db:	40                   	inc    %eax
  8018dc:	39 c2                	cmp    %eax,%edx
  8018de:	77 f7                	ja     8018d7 <memfind+0x18>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  8018e0:	c9                   	leave  
  8018e1:	c3                   	ret    

008018e2 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  8018e2:	55                   	push   %ebp
  8018e3:	89 e5                	mov    %esp,%ebp
  8018e5:	57                   	push   %edi
  8018e6:	56                   	push   %esi
  8018e7:	53                   	push   %ebx
  8018e8:	8b 55 08             	mov    0x8(%ebp),%edx
  8018eb:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8018ee:	eb 01                	jmp    8018f1 <strtol+0xf>
		s++;
  8018f0:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8018f1:	8a 02                	mov    (%edx),%al
  8018f3:	3c 20                	cmp    $0x20,%al
  8018f5:	74 f9                	je     8018f0 <strtol+0xe>
  8018f7:	3c 09                	cmp    $0x9,%al
  8018f9:	74 f5                	je     8018f0 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  8018fb:	3c 2b                	cmp    $0x2b,%al
  8018fd:	75 08                	jne    801907 <strtol+0x25>
		s++;
  8018ff:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  801900:	bf 00 00 00 00       	mov    $0x0,%edi
  801905:	eb 13                	jmp    80191a <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  801907:	3c 2d                	cmp    $0x2d,%al
  801909:	75 0a                	jne    801915 <strtol+0x33>
		s++, neg = 1;
  80190b:	8d 52 01             	lea    0x1(%edx),%edx
  80190e:	bf 01 00 00 00       	mov    $0x1,%edi
  801913:	eb 05                	jmp    80191a <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  801915:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  80191a:	85 db                	test   %ebx,%ebx
  80191c:	74 05                	je     801923 <strtol+0x41>
  80191e:	83 fb 10             	cmp    $0x10,%ebx
  801921:	75 28                	jne    80194b <strtol+0x69>
  801923:	8a 02                	mov    (%edx),%al
  801925:	3c 30                	cmp    $0x30,%al
  801927:	75 10                	jne    801939 <strtol+0x57>
  801929:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  80192d:	75 0a                	jne    801939 <strtol+0x57>
		s += 2, base = 16;
  80192f:	83 c2 02             	add    $0x2,%edx
  801932:	bb 10 00 00 00       	mov    $0x10,%ebx
  801937:	eb 12                	jmp    80194b <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  801939:	85 db                	test   %ebx,%ebx
  80193b:	75 0e                	jne    80194b <strtol+0x69>
  80193d:	3c 30                	cmp    $0x30,%al
  80193f:	75 05                	jne    801946 <strtol+0x64>
		s++, base = 8;
  801941:	42                   	inc    %edx
  801942:	b3 08                	mov    $0x8,%bl
  801944:	eb 05                	jmp    80194b <strtol+0x69>
	else if (base == 0)
		base = 10;
  801946:	bb 0a 00 00 00       	mov    $0xa,%ebx
  80194b:	b8 00 00 00 00       	mov    $0x0,%eax
  801950:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  801952:	8a 0a                	mov    (%edx),%cl
  801954:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  801957:	80 fb 09             	cmp    $0x9,%bl
  80195a:	77 08                	ja     801964 <strtol+0x82>
			dig = *s - '0';
  80195c:	0f be c9             	movsbl %cl,%ecx
  80195f:	83 e9 30             	sub    $0x30,%ecx
  801962:	eb 1e                	jmp    801982 <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  801964:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  801967:	80 fb 19             	cmp    $0x19,%bl
  80196a:	77 08                	ja     801974 <strtol+0x92>
			dig = *s - 'a' + 10;
  80196c:	0f be c9             	movsbl %cl,%ecx
  80196f:	83 e9 57             	sub    $0x57,%ecx
  801972:	eb 0e                	jmp    801982 <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  801974:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  801977:	80 fb 19             	cmp    $0x19,%bl
  80197a:	77 13                	ja     80198f <strtol+0xad>
			dig = *s - 'A' + 10;
  80197c:	0f be c9             	movsbl %cl,%ecx
  80197f:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  801982:	39 f1                	cmp    %esi,%ecx
  801984:	7d 0d                	jge    801993 <strtol+0xb1>
			break;
		s++, val = (val * base) + dig;
  801986:	42                   	inc    %edx
  801987:	0f af c6             	imul   %esi,%eax
  80198a:	8d 04 01             	lea    (%ecx,%eax,1),%eax
		// we don't properly detect overflow!
	}
  80198d:	eb c3                	jmp    801952 <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  80198f:	89 c1                	mov    %eax,%ecx
  801991:	eb 02                	jmp    801995 <strtol+0xb3>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  801993:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  801995:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801999:	74 05                	je     8019a0 <strtol+0xbe>
		*endptr = (char *) s;
  80199b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80199e:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  8019a0:	85 ff                	test   %edi,%edi
  8019a2:	74 04                	je     8019a8 <strtol+0xc6>
  8019a4:	89 c8                	mov    %ecx,%eax
  8019a6:	f7 d8                	neg    %eax
}
  8019a8:	5b                   	pop    %ebx
  8019a9:	5e                   	pop    %esi
  8019aa:	5f                   	pop    %edi
  8019ab:	c9                   	leave  
  8019ac:	c3                   	ret    
  8019ad:	00 00                	add    %al,(%eax)
	...

008019b0 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8019b0:	55                   	push   %ebp
  8019b1:	89 e5                	mov    %esp,%ebp
  8019b3:	56                   	push   %esi
  8019b4:	53                   	push   %ebx
  8019b5:	8b 75 08             	mov    0x8(%ebp),%esi
  8019b8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8019bb:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// cprintf("0x%x 0x%x 0x%x\n", (uint32_t)from_env_store, (uint32_t)pg, (uint32_t)perm_store);
	int r;
	if (pg != NULL) {
  8019be:	85 c0                	test   %eax,%eax
  8019c0:	74 0e                	je     8019d0 <ipc_recv+0x20>
		r = sys_ipc_recv(pg);
  8019c2:	83 ec 0c             	sub    $0xc,%esp
  8019c5:	50                   	push   %eax
  8019c6:	e8 e0 e8 ff ff       	call   8002ab <sys_ipc_recv>
  8019cb:	83 c4 10             	add    $0x10,%esp
  8019ce:	eb 10                	jmp    8019e0 <ipc_recv+0x30>
	} else {
		r = sys_ipc_recv((void *)UTOP);
  8019d0:	83 ec 0c             	sub    $0xc,%esp
  8019d3:	68 00 00 c0 ee       	push   $0xeec00000
  8019d8:	e8 ce e8 ff ff       	call   8002ab <sys_ipc_recv>
  8019dd:	83 c4 10             	add    $0x10,%esp
	}

	if (r == 0) {
  8019e0:	85 c0                	test   %eax,%eax
  8019e2:	75 26                	jne    801a0a <ipc_recv+0x5a>
		if (from_env_store != NULL) *from_env_store = thisenv->env_ipc_from;
  8019e4:	85 f6                	test   %esi,%esi
  8019e6:	74 0a                	je     8019f2 <ipc_recv+0x42>
  8019e8:	a1 04 40 80 00       	mov    0x804004,%eax
  8019ed:	8b 40 74             	mov    0x74(%eax),%eax
  8019f0:	89 06                	mov    %eax,(%esi)
		if (perm_store != NULL) *perm_store = thisenv->env_ipc_perm;
  8019f2:	85 db                	test   %ebx,%ebx
  8019f4:	74 0a                	je     801a00 <ipc_recv+0x50>
  8019f6:	a1 04 40 80 00       	mov    0x804004,%eax
  8019fb:	8b 40 78             	mov    0x78(%eax),%eax
  8019fe:	89 03                	mov    %eax,(%ebx)
		return thisenv->env_ipc_value;
  801a00:	a1 04 40 80 00       	mov    0x804004,%eax
  801a05:	8b 40 70             	mov    0x70(%eax),%eax
  801a08:	eb 14                	jmp    801a1e <ipc_recv+0x6e>
	} else {
		// fails;
		if (from_env_store != NULL) *from_env_store = 0;
  801a0a:	85 f6                	test   %esi,%esi
  801a0c:	74 06                	je     801a14 <ipc_recv+0x64>
  801a0e:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		if (perm_store != NULL) *perm_store = 0;
  801a14:	85 db                	test   %ebx,%ebx
  801a16:	74 06                	je     801a1e <ipc_recv+0x6e>
  801a18:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
		return r;
	}
}
  801a1e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a21:	5b                   	pop    %ebx
  801a22:	5e                   	pop    %esi
  801a23:	c9                   	leave  
  801a24:	c3                   	ret    

00801a25 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801a25:	55                   	push   %ebp
  801a26:	89 e5                	mov    %esp,%ebp
  801a28:	57                   	push   %edi
  801a29:	56                   	push   %esi
  801a2a:	53                   	push   %ebx
  801a2b:	83 ec 0c             	sub    $0xc,%esp
  801a2e:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801a31:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801a34:	8b 75 14             	mov    0x14(%ebp),%esi
	// LAB 4: Your code here.
	// int sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
	int r;
	if (pg == NULL) pg = (void *)UTOP;
  801a37:	85 db                	test   %ebx,%ebx
  801a39:	75 25                	jne    801a60 <ipc_send+0x3b>
  801a3b:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
  801a40:	eb 1e                	jmp    801a60 <ipc_send+0x3b>
	
	while ((r = sys_ipc_try_send(to_env, val, pg, perm)) != 0) {
		if (r == -E_IPC_NOT_RECV) {
  801a42:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801a45:	75 07                	jne    801a4e <ipc_send+0x29>
			// cprintf("Try Again and Again....\n");
			sys_yield();
  801a47:	e8 3d e7 ff ff       	call   800189 <sys_yield>
  801a4c:	eb 12                	jmp    801a60 <ipc_send+0x3b>
		} else {
			panic("ipc_send error %e\n", r);
  801a4e:	50                   	push   %eax
  801a4f:	68 c0 21 80 00       	push   $0x8021c0
  801a54:	6a 43                	push   $0x43
  801a56:	68 d3 21 80 00       	push   $0x8021d3
  801a5b:	e8 44 f5 ff ff       	call   800fa4 <_panic>
	// LAB 4: Your code here.
	// int sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
	int r;
	if (pg == NULL) pg = (void *)UTOP;
	
	while ((r = sys_ipc_try_send(to_env, val, pg, perm)) != 0) {
  801a60:	56                   	push   %esi
  801a61:	53                   	push   %ebx
  801a62:	57                   	push   %edi
  801a63:	ff 75 08             	pushl  0x8(%ebp)
  801a66:	e8 1b e8 ff ff       	call   800286 <sys_ipc_try_send>
  801a6b:	83 c4 10             	add    $0x10,%esp
  801a6e:	85 c0                	test   %eax,%eax
  801a70:	75 d0                	jne    801a42 <ipc_send+0x1d>
		} else {
			panic("ipc_send error %e\n", r);
		}
	}
	return;
}
  801a72:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801a75:	5b                   	pop    %ebx
  801a76:	5e                   	pop    %esi
  801a77:	5f                   	pop    %edi
  801a78:	c9                   	leave  
  801a79:	c3                   	ret    

00801a7a <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801a7a:	55                   	push   %ebp
  801a7b:	89 e5                	mov    %esp,%ebp
  801a7d:	53                   	push   %ebx
  801a7e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	for (i = 0; i < NENV; i++)
		if (envs[i].env_type == type)
  801a81:	39 1d 50 00 c0 ee    	cmp    %ebx,0xeec00050
  801a87:	74 22                	je     801aab <ipc_find_env+0x31>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801a89:	b8 01 00 00 00       	mov    $0x1,%eax
		if (envs[i].env_type == type)
  801a8e:	8d 0c 85 00 00 00 00 	lea    0x0(,%eax,4),%ecx
  801a95:	89 c2                	mov    %eax,%edx
  801a97:	c1 e2 07             	shl    $0x7,%edx
  801a9a:	29 ca                	sub    %ecx,%edx
  801a9c:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801aa2:	8b 52 50             	mov    0x50(%edx),%edx
  801aa5:	39 da                	cmp    %ebx,%edx
  801aa7:	75 1d                	jne    801ac6 <ipc_find_env+0x4c>
  801aa9:	eb 05                	jmp    801ab0 <ipc_find_env+0x36>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801aab:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
			return envs[i].env_id;
  801ab0:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  801ab7:	c1 e0 07             	shl    $0x7,%eax
  801aba:	29 d0                	sub    %edx,%eax
  801abc:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  801ac1:	8b 40 40             	mov    0x40(%eax),%eax
  801ac4:	eb 0c                	jmp    801ad2 <ipc_find_env+0x58>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801ac6:	40                   	inc    %eax
  801ac7:	3d 00 04 00 00       	cmp    $0x400,%eax
  801acc:	75 c0                	jne    801a8e <ipc_find_env+0x14>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801ace:	66 b8 00 00          	mov    $0x0,%ax
}
  801ad2:	5b                   	pop    %ebx
  801ad3:	c9                   	leave  
  801ad4:	c3                   	ret    
  801ad5:	00 00                	add    %al,(%eax)
	...

00801ad8 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801ad8:	55                   	push   %ebp
  801ad9:	89 e5                	mov    %esp,%ebp
  801adb:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801ade:	89 c2                	mov    %eax,%edx
  801ae0:	c1 ea 16             	shr    $0x16,%edx
  801ae3:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801aea:	f6 c2 01             	test   $0x1,%dl
  801aed:	74 1e                	je     801b0d <pageref+0x35>
		return 0;
	pte = uvpt[PGNUM(v)];
  801aef:	c1 e8 0c             	shr    $0xc,%eax
  801af2:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  801af9:	a8 01                	test   $0x1,%al
  801afb:	74 17                	je     801b14 <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801afd:	c1 e8 0c             	shr    $0xc,%eax
  801b00:	66 8b 04 c5 04 00 00 	mov    -0x10fffffc(,%eax,8),%ax
  801b07:	ef 
  801b08:	0f b7 c0             	movzwl %ax,%eax
  801b0b:	eb 0c                	jmp    801b19 <pageref+0x41>
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
		return 0;
  801b0d:	b8 00 00 00 00       	mov    $0x0,%eax
  801b12:	eb 05                	jmp    801b19 <pageref+0x41>
	pte = uvpt[PGNUM(v)];
	if (!(pte & PTE_P))
		return 0;
  801b14:	b8 00 00 00 00       	mov    $0x0,%eax
	return pages[PGNUM(pte)].pp_ref;
}
  801b19:	c9                   	leave  
  801b1a:	c3                   	ret    
	...

00801b1c <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  801b1c:	55                   	push   %ebp
  801b1d:	89 e5                	mov    %esp,%ebp
  801b1f:	57                   	push   %edi
  801b20:	56                   	push   %esi
  801b21:	83 ec 10             	sub    $0x10,%esp
  801b24:	8b 7d 08             	mov    0x8(%ebp),%edi
  801b27:	8b 4d 10             	mov    0x10(%ebp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  801b2a:	89 7d f0             	mov    %edi,-0x10(%ebp)
  801b2d:	8b 75 0c             	mov    0xc(%ebp),%esi
  const DWunion dd = {.ll = d};
  801b30:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  801b33:	8b 45 14             	mov    0x14(%ebp),%eax
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  801b36:	85 c0                	test   %eax,%eax
  801b38:	75 2e                	jne    801b68 <__udivdi3+0x4c>
    {
      if (d0 > n1)
  801b3a:	39 f1                	cmp    %esi,%ecx
  801b3c:	77 5a                	ja     801b98 <__udivdi3+0x7c>
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  801b3e:	85 c9                	test   %ecx,%ecx
  801b40:	75 0b                	jne    801b4d <__udivdi3+0x31>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  801b42:	b8 01 00 00 00       	mov    $0x1,%eax
  801b47:	31 d2                	xor    %edx,%edx
  801b49:	f7 f1                	div    %ecx
  801b4b:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  801b4d:	31 d2                	xor    %edx,%edx
  801b4f:	89 f0                	mov    %esi,%eax
  801b51:	f7 f1                	div    %ecx
  801b53:	89 c6                	mov    %eax,%esi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801b55:	89 f8                	mov    %edi,%eax
  801b57:	f7 f1                	div    %ecx
  801b59:	89 c7                	mov    %eax,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  801b5b:	89 f8                	mov    %edi,%eax
  801b5d:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801b5f:	83 c4 10             	add    $0x10,%esp
  801b62:	5e                   	pop    %esi
  801b63:	5f                   	pop    %edi
  801b64:	c9                   	leave  
  801b65:	c3                   	ret    
  801b66:	66 90                	xchg   %ax,%ax
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  801b68:	39 f0                	cmp    %esi,%eax
  801b6a:	77 1c                	ja     801b88 <__udivdi3+0x6c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  801b6c:	0f bd f8             	bsr    %eax,%edi
	  if (bm == 0)
  801b6f:	83 f7 1f             	xor    $0x1f,%edi
  801b72:	75 3c                	jne    801bb0 <__udivdi3+0x94>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  801b74:	39 f0                	cmp    %esi,%eax
  801b76:	0f 82 90 00 00 00    	jb     801c0c <__udivdi3+0xf0>
  801b7c:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801b7f:	39 55 f4             	cmp    %edx,-0xc(%ebp)
  801b82:	0f 86 84 00 00 00    	jbe    801c0c <__udivdi3+0xf0>
  801b88:	31 f6                	xor    %esi,%esi
  801b8a:	31 ff                	xor    %edi,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  801b8c:	89 f8                	mov    %edi,%eax
  801b8e:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801b90:	83 c4 10             	add    $0x10,%esp
  801b93:	5e                   	pop    %esi
  801b94:	5f                   	pop    %edi
  801b95:	c9                   	leave  
  801b96:	c3                   	ret    
  801b97:	90                   	nop
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801b98:	89 f2                	mov    %esi,%edx
  801b9a:	89 f8                	mov    %edi,%eax
  801b9c:	f7 f1                	div    %ecx
  801b9e:	89 c7                	mov    %eax,%edi
  801ba0:	31 f6                	xor    %esi,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  801ba2:	89 f8                	mov    %edi,%eax
  801ba4:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801ba6:	83 c4 10             	add    $0x10,%esp
  801ba9:	5e                   	pop    %esi
  801baa:	5f                   	pop    %edi
  801bab:	c9                   	leave  
  801bac:	c3                   	ret    
  801bad:	8d 76 00             	lea    0x0(%esi),%esi
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  801bb0:	89 f9                	mov    %edi,%ecx
  801bb2:	d3 e0                	shl    %cl,%eax
  801bb4:	89 45 e8             	mov    %eax,-0x18(%ebp)
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  801bb7:	b8 20 00 00 00       	mov    $0x20,%eax
  801bbc:	29 f8                	sub    %edi,%eax

	      d1 = (d1 << bm) | (d0 >> b);
  801bbe:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801bc1:	88 c1                	mov    %al,%cl
  801bc3:	d3 ea                	shr    %cl,%edx
  801bc5:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  801bc8:	09 ca                	or     %ecx,%edx
  801bca:	89 55 ec             	mov    %edx,-0x14(%ebp)
	      d0 = d0 << bm;
  801bcd:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801bd0:	89 f9                	mov    %edi,%ecx
  801bd2:	d3 e2                	shl    %cl,%edx
  801bd4:	89 55 f4             	mov    %edx,-0xc(%ebp)
	      n2 = n1 >> b;
  801bd7:	89 f2                	mov    %esi,%edx
  801bd9:	88 c1                	mov    %al,%cl
  801bdb:	d3 ea                	shr    %cl,%edx
  801bdd:	89 55 e8             	mov    %edx,-0x18(%ebp)
	      n1 = (n1 << bm) | (n0 >> b);
  801be0:	89 f2                	mov    %esi,%edx
  801be2:	89 f9                	mov    %edi,%ecx
  801be4:	d3 e2                	shl    %cl,%edx
  801be6:	8b 75 f0             	mov    -0x10(%ebp),%esi
  801be9:	88 c1                	mov    %al,%cl
  801beb:	d3 ee                	shr    %cl,%esi
  801bed:	09 d6                	or     %edx,%esi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  801bef:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  801bf2:	89 f0                	mov    %esi,%eax
  801bf4:	89 ca                	mov    %ecx,%edx
  801bf6:	f7 75 ec             	divl   -0x14(%ebp)
  801bf9:	89 d1                	mov    %edx,%ecx
  801bfb:	89 c6                	mov    %eax,%esi
	      umul_ppmm (m1, m0, q0, d0);
  801bfd:	f7 65 f4             	mull   -0xc(%ebp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801c00:	39 d1                	cmp    %edx,%ecx
  801c02:	72 28                	jb     801c2c <__udivdi3+0x110>
  801c04:	74 1a                	je     801c20 <__udivdi3+0x104>
  801c06:	89 f7                	mov    %esi,%edi
  801c08:	31 f6                	xor    %esi,%esi
  801c0a:	eb 80                	jmp    801b8c <__udivdi3+0x70>
	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  801c0c:	31 f6                	xor    %esi,%esi
  801c0e:	bf 01 00 00 00       	mov    $0x1,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  801c13:	89 f8                	mov    %edi,%eax
  801c15:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801c17:	83 c4 10             	add    $0x10,%esp
  801c1a:	5e                   	pop    %esi
  801c1b:	5f                   	pop    %edi
  801c1c:	c9                   	leave  
  801c1d:	c3                   	ret    
  801c1e:	66 90                	xchg   %ax,%ax

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  801c20:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801c23:	89 f9                	mov    %edi,%ecx
  801c25:	d3 e2                	shl    %cl,%edx

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801c27:	39 c2                	cmp    %eax,%edx
  801c29:	73 db                	jae    801c06 <__udivdi3+0xea>
  801c2b:	90                   	nop
		{
		  q0--;
  801c2c:	8d 7e ff             	lea    -0x1(%esi),%edi
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  801c2f:	31 f6                	xor    %esi,%esi
  801c31:	e9 56 ff ff ff       	jmp    801b8c <__udivdi3+0x70>
	...

00801c38 <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  801c38:	55                   	push   %ebp
  801c39:	89 e5                	mov    %esp,%ebp
  801c3b:	57                   	push   %edi
  801c3c:	56                   	push   %esi
  801c3d:	83 ec 20             	sub    $0x20,%esp
  801c40:	8b 45 08             	mov    0x8(%ebp),%eax
  801c43:	8b 4d 10             	mov    0x10(%ebp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  801c46:	89 45 e8             	mov    %eax,-0x18(%ebp)
  801c49:	8b 75 0c             	mov    0xc(%ebp),%esi
  const DWunion dd = {.ll = d};
  801c4c:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  801c4f:	8b 7d 14             	mov    0x14(%ebp),%edi
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  801c52:	89 45 f0             	mov    %eax,-0x10(%ebp)
  n1 = nn.s.high;
  801c55:	89 f2                	mov    %esi,%edx

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  801c57:	85 ff                	test   %edi,%edi
  801c59:	75 15                	jne    801c70 <__umoddi3+0x38>
    {
      if (d0 > n1)
  801c5b:	39 f1                	cmp    %esi,%ecx
  801c5d:	0f 86 99 00 00 00    	jbe    801cfc <__umoddi3+0xc4>
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801c63:	f7 f1                	div    %ecx

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
  801c65:	89 d0                	mov    %edx,%eax
  801c67:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  801c69:	83 c4 20             	add    $0x20,%esp
  801c6c:	5e                   	pop    %esi
  801c6d:	5f                   	pop    %edi
  801c6e:	c9                   	leave  
  801c6f:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  801c70:	39 f7                	cmp    %esi,%edi
  801c72:	0f 87 a4 00 00 00    	ja     801d1c <__umoddi3+0xe4>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  801c78:	0f bd c7             	bsr    %edi,%eax
	  if (bm == 0)
  801c7b:	83 f0 1f             	xor    $0x1f,%eax
  801c7e:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801c81:	0f 84 a1 00 00 00    	je     801d28 <__umoddi3+0xf0>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  801c87:	89 f8                	mov    %edi,%eax
  801c89:	8a 4d ec             	mov    -0x14(%ebp),%cl
  801c8c:	d3 e0                	shl    %cl,%eax
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  801c8e:	bf 20 00 00 00       	mov    $0x20,%edi
  801c93:	2b 7d ec             	sub    -0x14(%ebp),%edi

	      d1 = (d1 << bm) | (d0 >> b);
  801c96:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801c99:	89 f9                	mov    %edi,%ecx
  801c9b:	d3 ea                	shr    %cl,%edx
  801c9d:	09 c2                	or     %eax,%edx
  801c9f:	89 55 f0             	mov    %edx,-0x10(%ebp)
	      d0 = d0 << bm;
  801ca2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ca5:	8a 4d ec             	mov    -0x14(%ebp),%cl
  801ca8:	d3 e0                	shl    %cl,%eax
  801caa:	89 45 f4             	mov    %eax,-0xc(%ebp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  801cad:	89 f2                	mov    %esi,%edx
  801caf:	d3 e2                	shl    %cl,%edx
	      n0 = n0 << bm;
  801cb1:	8b 45 e8             	mov    -0x18(%ebp),%eax
  801cb4:	d3 e0                	shl    %cl,%eax
  801cb6:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  801cb9:	8b 45 e8             	mov    -0x18(%ebp),%eax
  801cbc:	89 f9                	mov    %edi,%ecx
  801cbe:	d3 e8                	shr    %cl,%eax
  801cc0:	09 d0                	or     %edx,%eax

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  801cc2:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  801cc4:	89 f2                	mov    %esi,%edx
  801cc6:	f7 75 f0             	divl   -0x10(%ebp)
  801cc9:	89 d6                	mov    %edx,%esi
	      umul_ppmm (m1, m0, q0, d0);
  801ccb:	f7 65 f4             	mull   -0xc(%ebp)
  801cce:	89 55 e8             	mov    %edx,-0x18(%ebp)
  801cd1:	89 c1                	mov    %eax,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801cd3:	39 d6                	cmp    %edx,%esi
  801cd5:	72 71                	jb     801d48 <__umoddi3+0x110>
  801cd7:	74 7f                	je     801d58 <__umoddi3+0x120>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  801cd9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801cdc:	29 c8                	sub    %ecx,%eax
  801cde:	19 d6                	sbb    %edx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
  801ce0:	8a 4d ec             	mov    -0x14(%ebp),%cl
  801ce3:	d3 e8                	shr    %cl,%eax
  801ce5:	89 f2                	mov    %esi,%edx
  801ce7:	89 f9                	mov    %edi,%ecx
  801ce9:	d3 e2                	shl    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
  801ceb:	09 d0                	or     %edx,%eax
  801ced:	89 f2                	mov    %esi,%edx
  801cef:	8a 4d ec             	mov    -0x14(%ebp),%cl
  801cf2:	d3 ea                	shr    %cl,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  801cf4:	83 c4 20             	add    $0x20,%esp
  801cf7:	5e                   	pop    %esi
  801cf8:	5f                   	pop    %edi
  801cf9:	c9                   	leave  
  801cfa:	c3                   	ret    
  801cfb:	90                   	nop
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  801cfc:	85 c9                	test   %ecx,%ecx
  801cfe:	75 0b                	jne    801d0b <__umoddi3+0xd3>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  801d00:	b8 01 00 00 00       	mov    $0x1,%eax
  801d05:	31 d2                	xor    %edx,%edx
  801d07:	f7 f1                	div    %ecx
  801d09:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  801d0b:	89 f0                	mov    %esi,%eax
  801d0d:	31 d2                	xor    %edx,%edx
  801d0f:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801d11:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801d14:	f7 f1                	div    %ecx
  801d16:	e9 4a ff ff ff       	jmp    801c65 <__umoddi3+0x2d>
  801d1b:	90                   	nop
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
  801d1c:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  801d1e:	83 c4 20             	add    $0x20,%esp
  801d21:	5e                   	pop    %esi
  801d22:	5f                   	pop    %edi
  801d23:	c9                   	leave  
  801d24:	c3                   	ret    
  801d25:	8d 76 00             	lea    0x0(%esi),%esi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  801d28:	39 f7                	cmp    %esi,%edi
  801d2a:	72 05                	jb     801d31 <__umoddi3+0xf9>
  801d2c:	3b 4d f0             	cmp    -0x10(%ebp),%ecx
  801d2f:	77 0c                	ja     801d3d <__umoddi3+0x105>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  801d31:	89 f2                	mov    %esi,%edx
  801d33:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801d36:	29 c8                	sub    %ecx,%eax
  801d38:	19 fa                	sbb    %edi,%edx
  801d3a:	89 45 f0             	mov    %eax,-0x10(%ebp)

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
  801d3d:	8b 45 f0             	mov    -0x10(%ebp),%eax
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
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  801d48:	8b 55 e8             	mov    -0x18(%ebp),%edx
  801d4b:	89 c1                	mov    %eax,%ecx
  801d4d:	2b 4d f4             	sub    -0xc(%ebp),%ecx
  801d50:	1b 55 f0             	sbb    -0x10(%ebp),%edx
  801d53:	eb 84                	jmp    801cd9 <__umoddi3+0xa1>
  801d55:	8d 76 00             	lea    0x0(%esi),%esi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801d58:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  801d5b:	72 eb                	jb     801d48 <__umoddi3+0x110>
  801d5d:	89 f2                	mov    %esi,%edx
  801d5f:	e9 75 ff ff ff       	jmp    801cd9 <__umoddi3+0xa1>
