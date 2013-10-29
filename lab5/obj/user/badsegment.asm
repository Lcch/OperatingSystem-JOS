
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
  8000de:	68 ca 1d 80 00       	push   $0x801dca
  8000e3:	6a 42                	push   $0x42
  8000e5:	68 e7 1d 80 00       	push   $0x801de7
  8000ea:	e8 d5 0e 00 00       	call   800fc4 <_panic>

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
  800412:	8b 14 85 74 1e 80 00 	mov    0x801e74(,%eax,4),%edx
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
  80042a:	68 f8 1d 80 00       	push   $0x801df8
  80042f:	e8 68 0c 00 00       	call   80109c <cprintf>
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
  80065a:	68 39 1e 80 00       	push   $0x801e39
  80065f:	e8 38 0a 00 00       	call   80109c <cprintf>
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
  800731:	68 55 1e 80 00       	push   $0x801e55
  800736:	e8 61 09 00 00       	call   80109c <cprintf>
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
  8007dc:	68 18 1e 80 00       	push   $0x801e18
  8007e1:	e8 b6 08 00 00       	call   80109c <cprintf>
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
  800893:	e8 8b 01 00 00       	call   800a23 <open>
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
  8008df:	e8 e9 11 00 00       	call   801acd <ipc_find_env>
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
  8008fa:	e8 79 11 00 00       	call   801a78 <ipc_send>
	
	return ipc_recv(NULL, dstva, NULL);
  8008ff:	83 c4 0c             	add    $0xc,%esp
  800902:	6a 00                	push   $0x0
  800904:	56                   	push   %esi
  800905:	6a 00                	push   $0x0
  800907:	e8 c4 10 00 00       	call   8019d0 <ipc_recv>
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
  800939:	78 39                	js     800974 <devfile_stat+0x61>
		return r;
	}
	cprintf("OVER\n");
  80093b:	83 ec 0c             	sub    $0xc,%esp
  80093e:	68 84 1e 80 00       	push   $0x801e84
  800943:	e8 54 07 00 00       	call   80109c <cprintf>
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  800948:	83 c4 08             	add    $0x8,%esp
  80094b:	68 00 50 80 00       	push   $0x805000
  800950:	53                   	push   %ebx
  800951:	e8 fc 0c 00 00       	call   801652 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  800956:	a1 80 50 80 00       	mov    0x805080,%eax
  80095b:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  800961:	a1 84 50 80 00       	mov    0x805084,%eax
  800966:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  80096c:	83 c4 10             	add    $0x10,%esp
  80096f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800974:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800977:	c9                   	leave  
  800978:	c3                   	ret    

00800979 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  800979:	55                   	push   %ebp
  80097a:	89 e5                	mov    %esp,%ebp
  80097c:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  80097f:	8b 45 08             	mov    0x8(%ebp),%eax
  800982:	8b 40 0c             	mov    0xc(%eax),%eax
  800985:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  80098a:	ba 00 00 00 00       	mov    $0x0,%edx
  80098f:	b8 06 00 00 00       	mov    $0x6,%eax
  800994:	e8 2f ff ff ff       	call   8008c8 <fsipc>
}
  800999:	c9                   	leave  
  80099a:	c3                   	ret    

0080099b <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  80099b:	55                   	push   %ebp
  80099c:	89 e5                	mov    %esp,%ebp
  80099e:	56                   	push   %esi
  80099f:	53                   	push   %ebx
  8009a0:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8009a3:	8b 45 08             	mov    0x8(%ebp),%eax
  8009a6:	8b 40 0c             	mov    0xc(%eax),%eax
  8009a9:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  8009ae:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8009b4:	ba 00 00 00 00       	mov    $0x0,%edx
  8009b9:	b8 03 00 00 00       	mov    $0x3,%eax
  8009be:	e8 05 ff ff ff       	call   8008c8 <fsipc>
  8009c3:	89 c3                	mov    %eax,%ebx
  8009c5:	85 c0                	test   %eax,%eax
  8009c7:	78 51                	js     800a1a <devfile_read+0x7f>
		return r;
	assert(r <= n);
  8009c9:	39 c6                	cmp    %eax,%esi
  8009cb:	73 19                	jae    8009e6 <devfile_read+0x4b>
  8009cd:	68 8a 1e 80 00       	push   $0x801e8a
  8009d2:	68 91 1e 80 00       	push   $0x801e91
  8009d7:	68 80 00 00 00       	push   $0x80
  8009dc:	68 a6 1e 80 00       	push   $0x801ea6
  8009e1:	e8 de 05 00 00       	call   800fc4 <_panic>
	assert(r <= PGSIZE);
  8009e6:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8009eb:	7e 19                	jle    800a06 <devfile_read+0x6b>
  8009ed:	68 b1 1e 80 00       	push   $0x801eb1
  8009f2:	68 91 1e 80 00       	push   $0x801e91
  8009f7:	68 81 00 00 00       	push   $0x81
  8009fc:	68 a6 1e 80 00       	push   $0x801ea6
  800a01:	e8 be 05 00 00       	call   800fc4 <_panic>
	memmove(buf, &fsipcbuf, r);
  800a06:	83 ec 04             	sub    $0x4,%esp
  800a09:	50                   	push   %eax
  800a0a:	68 00 50 80 00       	push   $0x805000
  800a0f:	ff 75 0c             	pushl  0xc(%ebp)
  800a12:	e8 fc 0d 00 00       	call   801813 <memmove>
	return r;
  800a17:	83 c4 10             	add    $0x10,%esp
}
  800a1a:	89 d8                	mov    %ebx,%eax
  800a1c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800a1f:	5b                   	pop    %ebx
  800a20:	5e                   	pop    %esi
  800a21:	c9                   	leave  
  800a22:	c3                   	ret    

00800a23 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  800a23:	55                   	push   %ebp
  800a24:	89 e5                	mov    %esp,%ebp
  800a26:	56                   	push   %esi
  800a27:	53                   	push   %ebx
  800a28:	83 ec 1c             	sub    $0x1c,%esp
  800a2b:	8b 75 08             	mov    0x8(%ebp),%esi
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  800a2e:	56                   	push   %esi
  800a2f:	e8 cc 0b 00 00       	call   801600 <strlen>
  800a34:	83 c4 10             	add    $0x10,%esp
  800a37:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  800a3c:	7f 72                	jg     800ab0 <open+0x8d>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800a3e:	83 ec 0c             	sub    $0xc,%esp
  800a41:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800a44:	50                   	push   %eax
  800a45:	e8 ce f8 ff ff       	call   800318 <fd_alloc>
  800a4a:	89 c3                	mov    %eax,%ebx
  800a4c:	83 c4 10             	add    $0x10,%esp
  800a4f:	85 c0                	test   %eax,%eax
  800a51:	78 62                	js     800ab5 <open+0x92>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  800a53:	83 ec 08             	sub    $0x8,%esp
  800a56:	56                   	push   %esi
  800a57:	68 00 50 80 00       	push   $0x805000
  800a5c:	e8 f1 0b 00 00       	call   801652 <strcpy>
	fsipcbuf.open.req_omode = mode;
  800a61:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a64:	a3 00 54 80 00       	mov    %eax,0x805400



	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  800a69:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800a6c:	b8 01 00 00 00       	mov    $0x1,%eax
  800a71:	e8 52 fe ff ff       	call   8008c8 <fsipc>
  800a76:	89 c3                	mov    %eax,%ebx
  800a78:	83 c4 10             	add    $0x10,%esp
  800a7b:	85 c0                	test   %eax,%eax
  800a7d:	79 12                	jns    800a91 <open+0x6e>
		fd_close(fd, 0);
  800a7f:	83 ec 08             	sub    $0x8,%esp
  800a82:	6a 00                	push   $0x0
  800a84:	ff 75 f4             	pushl  -0xc(%ebp)
  800a87:	e8 bb f9 ff ff       	call   800447 <fd_close>
		return r;
  800a8c:	83 c4 10             	add    $0x10,%esp
  800a8f:	eb 24                	jmp    800ab5 <open+0x92>
	}


	cprintf("OPEN\n");
  800a91:	83 ec 0c             	sub    $0xc,%esp
  800a94:	68 bd 1e 80 00       	push   $0x801ebd
  800a99:	e8 fe 05 00 00       	call   80109c <cprintf>

	return fd2num(fd);
  800a9e:	83 c4 04             	add    $0x4,%esp
  800aa1:	ff 75 f4             	pushl  -0xc(%ebp)
  800aa4:	e8 47 f8 ff ff       	call   8002f0 <fd2num>
  800aa9:	89 c3                	mov    %eax,%ebx
  800aab:	83 c4 10             	add    $0x10,%esp
  800aae:	eb 05                	jmp    800ab5 <open+0x92>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  800ab0:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx


	cprintf("OPEN\n");

	return fd2num(fd);
}
  800ab5:	89 d8                	mov    %ebx,%eax
  800ab7:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800aba:	5b                   	pop    %ebx
  800abb:	5e                   	pop    %esi
  800abc:	c9                   	leave  
  800abd:	c3                   	ret    
	...

00800ac0 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  800ac0:	55                   	push   %ebp
  800ac1:	89 e5                	mov    %esp,%ebp
  800ac3:	56                   	push   %esi
  800ac4:	53                   	push   %ebx
  800ac5:	8b 75 0c             	mov    0xc(%ebp),%esi
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  800ac8:	83 ec 0c             	sub    $0xc,%esp
  800acb:	ff 75 08             	pushl  0x8(%ebp)
  800ace:	e8 2d f8 ff ff       	call   800300 <fd2data>
  800ad3:	89 c3                	mov    %eax,%ebx
	strcpy(stat->st_name, "<pipe>");
  800ad5:	83 c4 08             	add    $0x8,%esp
  800ad8:	68 c3 1e 80 00       	push   $0x801ec3
  800add:	56                   	push   %esi
  800ade:	e8 6f 0b 00 00       	call   801652 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  800ae3:	8b 43 04             	mov    0x4(%ebx),%eax
  800ae6:	2b 03                	sub    (%ebx),%eax
  800ae8:	89 86 80 00 00 00    	mov    %eax,0x80(%esi)
	stat->st_isdir = 0;
  800aee:	c7 86 84 00 00 00 00 	movl   $0x0,0x84(%esi)
  800af5:	00 00 00 
	stat->st_dev = &devpipe;
  800af8:	c7 86 88 00 00 00 20 	movl   $0x803020,0x88(%esi)
  800aff:	30 80 00 
	return 0;
}
  800b02:	b8 00 00 00 00       	mov    $0x0,%eax
  800b07:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800b0a:	5b                   	pop    %ebx
  800b0b:	5e                   	pop    %esi
  800b0c:	c9                   	leave  
  800b0d:	c3                   	ret    

00800b0e <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  800b0e:	55                   	push   %ebp
  800b0f:	89 e5                	mov    %esp,%ebp
  800b11:	53                   	push   %ebx
  800b12:	83 ec 0c             	sub    $0xc,%esp
  800b15:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  800b18:	53                   	push   %ebx
  800b19:	6a 00                	push   $0x0
  800b1b:	e8 da f6 ff ff       	call   8001fa <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  800b20:	89 1c 24             	mov    %ebx,(%esp)
  800b23:	e8 d8 f7 ff ff       	call   800300 <fd2data>
  800b28:	83 c4 08             	add    $0x8,%esp
  800b2b:	50                   	push   %eax
  800b2c:	6a 00                	push   $0x0
  800b2e:	e8 c7 f6 ff ff       	call   8001fa <sys_page_unmap>
}
  800b33:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800b36:	c9                   	leave  
  800b37:	c3                   	ret    

00800b38 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  800b38:	55                   	push   %ebp
  800b39:	89 e5                	mov    %esp,%ebp
  800b3b:	57                   	push   %edi
  800b3c:	56                   	push   %esi
  800b3d:	53                   	push   %ebx
  800b3e:	83 ec 1c             	sub    $0x1c,%esp
  800b41:	89 c7                	mov    %eax,%edi
  800b43:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  800b46:	a1 04 40 80 00       	mov    0x804004,%eax
  800b4b:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  800b4e:	83 ec 0c             	sub    $0xc,%esp
  800b51:	57                   	push   %edi
  800b52:	e8 d1 0f 00 00       	call   801b28 <pageref>
  800b57:	89 c6                	mov    %eax,%esi
  800b59:	83 c4 04             	add    $0x4,%esp
  800b5c:	ff 75 e4             	pushl  -0x1c(%ebp)
  800b5f:	e8 c4 0f 00 00       	call   801b28 <pageref>
  800b64:	83 c4 10             	add    $0x10,%esp
  800b67:	39 c6                	cmp    %eax,%esi
  800b69:	0f 94 c0             	sete   %al
  800b6c:	0f b6 c0             	movzbl %al,%eax
		nn = thisenv->env_runs;
  800b6f:	8b 15 04 40 80 00    	mov    0x804004,%edx
  800b75:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  800b78:	39 cb                	cmp    %ecx,%ebx
  800b7a:	75 08                	jne    800b84 <_pipeisclosed+0x4c>
			return ret;
		if (n != nn && ret == 1)
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
	}
}
  800b7c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b7f:	5b                   	pop    %ebx
  800b80:	5e                   	pop    %esi
  800b81:	5f                   	pop    %edi
  800b82:	c9                   	leave  
  800b83:	c3                   	ret    
		n = thisenv->env_runs;
		ret = pageref(fd) == pageref(p);
		nn = thisenv->env_runs;
		if (n == nn)
			return ret;
		if (n != nn && ret == 1)
  800b84:	83 f8 01             	cmp    $0x1,%eax
  800b87:	75 bd                	jne    800b46 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  800b89:	8b 42 58             	mov    0x58(%edx),%eax
  800b8c:	6a 01                	push   $0x1
  800b8e:	50                   	push   %eax
  800b8f:	53                   	push   %ebx
  800b90:	68 ca 1e 80 00       	push   $0x801eca
  800b95:	e8 02 05 00 00       	call   80109c <cprintf>
  800b9a:	83 c4 10             	add    $0x10,%esp
  800b9d:	eb a7                	jmp    800b46 <_pipeisclosed+0xe>

00800b9f <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  800b9f:	55                   	push   %ebp
  800ba0:	89 e5                	mov    %esp,%ebp
  800ba2:	57                   	push   %edi
  800ba3:	56                   	push   %esi
  800ba4:	53                   	push   %ebx
  800ba5:	83 ec 28             	sub    $0x28,%esp
  800ba8:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  800bab:	56                   	push   %esi
  800bac:	e8 4f f7 ff ff       	call   800300 <fd2data>
  800bb1:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800bb3:	83 c4 10             	add    $0x10,%esp
  800bb6:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800bba:	75 4a                	jne    800c06 <devpipe_write+0x67>
  800bbc:	bf 00 00 00 00       	mov    $0x0,%edi
  800bc1:	eb 56                	jmp    800c19 <devpipe_write+0x7a>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  800bc3:	89 da                	mov    %ebx,%edx
  800bc5:	89 f0                	mov    %esi,%eax
  800bc7:	e8 6c ff ff ff       	call   800b38 <_pipeisclosed>
  800bcc:	85 c0                	test   %eax,%eax
  800bce:	75 4d                	jne    800c1d <devpipe_write+0x7e>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  800bd0:	e8 b4 f5 ff ff       	call   800189 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  800bd5:	8b 43 04             	mov    0x4(%ebx),%eax
  800bd8:	8b 13                	mov    (%ebx),%edx
  800bda:	83 c2 20             	add    $0x20,%edx
  800bdd:	39 d0                	cmp    %edx,%eax
  800bdf:	73 e2                	jae    800bc3 <devpipe_write+0x24>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  800be1:	89 c2                	mov    %eax,%edx
  800be3:	81 e2 1f 00 00 80    	and    $0x8000001f,%edx
  800be9:	79 05                	jns    800bf0 <devpipe_write+0x51>
  800beb:	4a                   	dec    %edx
  800bec:	83 ca e0             	or     $0xffffffe0,%edx
  800bef:	42                   	inc    %edx
  800bf0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bf3:	8a 0c 39             	mov    (%ecx,%edi,1),%cl
  800bf6:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  800bfa:	40                   	inc    %eax
  800bfb:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800bfe:	47                   	inc    %edi
  800bff:	39 7d 10             	cmp    %edi,0x10(%ebp)
  800c02:	77 07                	ja     800c0b <devpipe_write+0x6c>
  800c04:	eb 13                	jmp    800c19 <devpipe_write+0x7a>
  800c06:	bf 00 00 00 00       	mov    $0x0,%edi
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  800c0b:	8b 43 04             	mov    0x4(%ebx),%eax
  800c0e:	8b 13                	mov    (%ebx),%edx
  800c10:	83 c2 20             	add    $0x20,%edx
  800c13:	39 d0                	cmp    %edx,%eax
  800c15:	73 ac                	jae    800bc3 <devpipe_write+0x24>
  800c17:	eb c8                	jmp    800be1 <devpipe_write+0x42>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  800c19:	89 f8                	mov    %edi,%eax
  800c1b:	eb 05                	jmp    800c22 <devpipe_write+0x83>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  800c1d:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  800c22:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c25:	5b                   	pop    %ebx
  800c26:	5e                   	pop    %esi
  800c27:	5f                   	pop    %edi
  800c28:	c9                   	leave  
  800c29:	c3                   	ret    

00800c2a <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  800c2a:	55                   	push   %ebp
  800c2b:	89 e5                	mov    %esp,%ebp
  800c2d:	57                   	push   %edi
  800c2e:	56                   	push   %esi
  800c2f:	53                   	push   %ebx
  800c30:	83 ec 18             	sub    $0x18,%esp
  800c33:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  800c36:	57                   	push   %edi
  800c37:	e8 c4 f6 ff ff       	call   800300 <fd2data>
  800c3c:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800c3e:	83 c4 10             	add    $0x10,%esp
  800c41:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800c45:	75 44                	jne    800c8b <devpipe_read+0x61>
  800c47:	be 00 00 00 00       	mov    $0x0,%esi
  800c4c:	eb 4f                	jmp    800c9d <devpipe_read+0x73>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
				return i;
  800c4e:	89 f0                	mov    %esi,%eax
  800c50:	eb 54                	jmp    800ca6 <devpipe_read+0x7c>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  800c52:	89 da                	mov    %ebx,%edx
  800c54:	89 f8                	mov    %edi,%eax
  800c56:	e8 dd fe ff ff       	call   800b38 <_pipeisclosed>
  800c5b:	85 c0                	test   %eax,%eax
  800c5d:	75 42                	jne    800ca1 <devpipe_read+0x77>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  800c5f:	e8 25 f5 ff ff       	call   800189 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  800c64:	8b 03                	mov    (%ebx),%eax
  800c66:	3b 43 04             	cmp    0x4(%ebx),%eax
  800c69:	74 e7                	je     800c52 <devpipe_read+0x28>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  800c6b:	25 1f 00 00 80       	and    $0x8000001f,%eax
  800c70:	79 05                	jns    800c77 <devpipe_read+0x4d>
  800c72:	48                   	dec    %eax
  800c73:	83 c8 e0             	or     $0xffffffe0,%eax
  800c76:	40                   	inc    %eax
  800c77:	8a 44 03 08          	mov    0x8(%ebx,%eax,1),%al
  800c7b:	8b 55 0c             	mov    0xc(%ebp),%edx
  800c7e:	88 04 32             	mov    %al,(%edx,%esi,1)
		p->p_rpos++;
  800c81:	ff 03                	incl   (%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800c83:	46                   	inc    %esi
  800c84:	39 75 10             	cmp    %esi,0x10(%ebp)
  800c87:	77 07                	ja     800c90 <devpipe_read+0x66>
  800c89:	eb 12                	jmp    800c9d <devpipe_read+0x73>
  800c8b:	be 00 00 00 00       	mov    $0x0,%esi
		while (p->p_rpos == p->p_wpos) {
  800c90:	8b 03                	mov    (%ebx),%eax
  800c92:	3b 43 04             	cmp    0x4(%ebx),%eax
  800c95:	75 d4                	jne    800c6b <devpipe_read+0x41>
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  800c97:	85 f6                	test   %esi,%esi
  800c99:	75 b3                	jne    800c4e <devpipe_read+0x24>
  800c9b:	eb b5                	jmp    800c52 <devpipe_read+0x28>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  800c9d:	89 f0                	mov    %esi,%eax
  800c9f:	eb 05                	jmp    800ca6 <devpipe_read+0x7c>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  800ca1:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  800ca6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ca9:	5b                   	pop    %ebx
  800caa:	5e                   	pop    %esi
  800cab:	5f                   	pop    %edi
  800cac:	c9                   	leave  
  800cad:	c3                   	ret    

00800cae <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  800cae:	55                   	push   %ebp
  800caf:	89 e5                	mov    %esp,%ebp
  800cb1:	57                   	push   %edi
  800cb2:	56                   	push   %esi
  800cb3:	53                   	push   %ebx
  800cb4:	83 ec 28             	sub    $0x28,%esp
  800cb7:	8b 7d 08             	mov    0x8(%ebp),%edi
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  800cba:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800cbd:	50                   	push   %eax
  800cbe:	e8 55 f6 ff ff       	call   800318 <fd_alloc>
  800cc3:	89 c3                	mov    %eax,%ebx
  800cc5:	83 c4 10             	add    $0x10,%esp
  800cc8:	85 c0                	test   %eax,%eax
  800cca:	0f 88 24 01 00 00    	js     800df4 <pipe+0x146>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800cd0:	83 ec 04             	sub    $0x4,%esp
  800cd3:	68 07 04 00 00       	push   $0x407
  800cd8:	ff 75 e4             	pushl  -0x1c(%ebp)
  800cdb:	6a 00                	push   $0x0
  800cdd:	e8 ce f4 ff ff       	call   8001b0 <sys_page_alloc>
  800ce2:	89 c3                	mov    %eax,%ebx
  800ce4:	83 c4 10             	add    $0x10,%esp
  800ce7:	85 c0                	test   %eax,%eax
  800ce9:	0f 88 05 01 00 00    	js     800df4 <pipe+0x146>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  800cef:	83 ec 0c             	sub    $0xc,%esp
  800cf2:	8d 45 e0             	lea    -0x20(%ebp),%eax
  800cf5:	50                   	push   %eax
  800cf6:	e8 1d f6 ff ff       	call   800318 <fd_alloc>
  800cfb:	89 c3                	mov    %eax,%ebx
  800cfd:	83 c4 10             	add    $0x10,%esp
  800d00:	85 c0                	test   %eax,%eax
  800d02:	0f 88 dc 00 00 00    	js     800de4 <pipe+0x136>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800d08:	83 ec 04             	sub    $0x4,%esp
  800d0b:	68 07 04 00 00       	push   $0x407
  800d10:	ff 75 e0             	pushl  -0x20(%ebp)
  800d13:	6a 00                	push   $0x0
  800d15:	e8 96 f4 ff ff       	call   8001b0 <sys_page_alloc>
  800d1a:	89 c3                	mov    %eax,%ebx
  800d1c:	83 c4 10             	add    $0x10,%esp
  800d1f:	85 c0                	test   %eax,%eax
  800d21:	0f 88 bd 00 00 00    	js     800de4 <pipe+0x136>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  800d27:	83 ec 0c             	sub    $0xc,%esp
  800d2a:	ff 75 e4             	pushl  -0x1c(%ebp)
  800d2d:	e8 ce f5 ff ff       	call   800300 <fd2data>
  800d32:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800d34:	83 c4 0c             	add    $0xc,%esp
  800d37:	68 07 04 00 00       	push   $0x407
  800d3c:	50                   	push   %eax
  800d3d:	6a 00                	push   $0x0
  800d3f:	e8 6c f4 ff ff       	call   8001b0 <sys_page_alloc>
  800d44:	89 c3                	mov    %eax,%ebx
  800d46:	83 c4 10             	add    $0x10,%esp
  800d49:	85 c0                	test   %eax,%eax
  800d4b:	0f 88 83 00 00 00    	js     800dd4 <pipe+0x126>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800d51:	83 ec 0c             	sub    $0xc,%esp
  800d54:	ff 75 e0             	pushl  -0x20(%ebp)
  800d57:	e8 a4 f5 ff ff       	call   800300 <fd2data>
  800d5c:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  800d63:	50                   	push   %eax
  800d64:	6a 00                	push   $0x0
  800d66:	56                   	push   %esi
  800d67:	6a 00                	push   $0x0
  800d69:	e8 66 f4 ff ff       	call   8001d4 <sys_page_map>
  800d6e:	89 c3                	mov    %eax,%ebx
  800d70:	83 c4 20             	add    $0x20,%esp
  800d73:	85 c0                	test   %eax,%eax
  800d75:	78 4f                	js     800dc6 <pipe+0x118>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  800d77:	8b 15 20 30 80 00    	mov    0x803020,%edx
  800d7d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800d80:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  800d82:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800d85:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  800d8c:	8b 15 20 30 80 00    	mov    0x803020,%edx
  800d92:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800d95:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  800d97:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800d9a:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  800da1:	83 ec 0c             	sub    $0xc,%esp
  800da4:	ff 75 e4             	pushl  -0x1c(%ebp)
  800da7:	e8 44 f5 ff ff       	call   8002f0 <fd2num>
  800dac:	89 07                	mov    %eax,(%edi)
	pfd[1] = fd2num(fd1);
  800dae:	83 c4 04             	add    $0x4,%esp
  800db1:	ff 75 e0             	pushl  -0x20(%ebp)
  800db4:	e8 37 f5 ff ff       	call   8002f0 <fd2num>
  800db9:	89 47 04             	mov    %eax,0x4(%edi)
	return 0;
  800dbc:	83 c4 10             	add    $0x10,%esp
  800dbf:	bb 00 00 00 00       	mov    $0x0,%ebx
  800dc4:	eb 2e                	jmp    800df4 <pipe+0x146>

    err3:
	sys_page_unmap(0, va);
  800dc6:	83 ec 08             	sub    $0x8,%esp
  800dc9:	56                   	push   %esi
  800dca:	6a 00                	push   $0x0
  800dcc:	e8 29 f4 ff ff       	call   8001fa <sys_page_unmap>
  800dd1:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  800dd4:	83 ec 08             	sub    $0x8,%esp
  800dd7:	ff 75 e0             	pushl  -0x20(%ebp)
  800dda:	6a 00                	push   $0x0
  800ddc:	e8 19 f4 ff ff       	call   8001fa <sys_page_unmap>
  800de1:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  800de4:	83 ec 08             	sub    $0x8,%esp
  800de7:	ff 75 e4             	pushl  -0x1c(%ebp)
  800dea:	6a 00                	push   $0x0
  800dec:	e8 09 f4 ff ff       	call   8001fa <sys_page_unmap>
  800df1:	83 c4 10             	add    $0x10,%esp
    err:
	return r;
}
  800df4:	89 d8                	mov    %ebx,%eax
  800df6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800df9:	5b                   	pop    %ebx
  800dfa:	5e                   	pop    %esi
  800dfb:	5f                   	pop    %edi
  800dfc:	c9                   	leave  
  800dfd:	c3                   	ret    

00800dfe <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  800dfe:	55                   	push   %ebp
  800dff:	89 e5                	mov    %esp,%ebp
  800e01:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800e04:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800e07:	50                   	push   %eax
  800e08:	ff 75 08             	pushl  0x8(%ebp)
  800e0b:	e8 7b f5 ff ff       	call   80038b <fd_lookup>
  800e10:	83 c4 10             	add    $0x10,%esp
  800e13:	85 c0                	test   %eax,%eax
  800e15:	78 18                	js     800e2f <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  800e17:	83 ec 0c             	sub    $0xc,%esp
  800e1a:	ff 75 f4             	pushl  -0xc(%ebp)
  800e1d:	e8 de f4 ff ff       	call   800300 <fd2data>
	return _pipeisclosed(fd, p);
  800e22:	89 c2                	mov    %eax,%edx
  800e24:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800e27:	e8 0c fd ff ff       	call   800b38 <_pipeisclosed>
  800e2c:	83 c4 10             	add    $0x10,%esp
}
  800e2f:	c9                   	leave  
  800e30:	c3                   	ret    
  800e31:	00 00                	add    %al,(%eax)
	...

00800e34 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  800e34:	55                   	push   %ebp
  800e35:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  800e37:	b8 00 00 00 00       	mov    $0x0,%eax
  800e3c:	c9                   	leave  
  800e3d:	c3                   	ret    

00800e3e <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  800e3e:	55                   	push   %ebp
  800e3f:	89 e5                	mov    %esp,%ebp
  800e41:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  800e44:	68 e2 1e 80 00       	push   $0x801ee2
  800e49:	ff 75 0c             	pushl  0xc(%ebp)
  800e4c:	e8 01 08 00 00       	call   801652 <strcpy>
	return 0;
}
  800e51:	b8 00 00 00 00       	mov    $0x0,%eax
  800e56:	c9                   	leave  
  800e57:	c3                   	ret    

00800e58 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  800e58:	55                   	push   %ebp
  800e59:	89 e5                	mov    %esp,%ebp
  800e5b:	57                   	push   %edi
  800e5c:	56                   	push   %esi
  800e5d:	53                   	push   %ebx
  800e5e:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800e64:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800e68:	74 45                	je     800eaf <devcons_write+0x57>
  800e6a:	b8 00 00 00 00       	mov    $0x0,%eax
  800e6f:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  800e74:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  800e7a:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e7d:	29 c3                	sub    %eax,%ebx
		if (m > sizeof(buf) - 1)
  800e7f:	83 fb 7f             	cmp    $0x7f,%ebx
  800e82:	76 05                	jbe    800e89 <devcons_write+0x31>
			m = sizeof(buf) - 1;
  800e84:	bb 7f 00 00 00       	mov    $0x7f,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  800e89:	83 ec 04             	sub    $0x4,%esp
  800e8c:	53                   	push   %ebx
  800e8d:	03 45 0c             	add    0xc(%ebp),%eax
  800e90:	50                   	push   %eax
  800e91:	57                   	push   %edi
  800e92:	e8 7c 09 00 00       	call   801813 <memmove>
		sys_cputs(buf, m);
  800e97:	83 c4 08             	add    $0x8,%esp
  800e9a:	53                   	push   %ebx
  800e9b:	57                   	push   %edi
  800e9c:	e8 58 f2 ff ff       	call   8000f9 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800ea1:	01 de                	add    %ebx,%esi
  800ea3:	89 f0                	mov    %esi,%eax
  800ea5:	83 c4 10             	add    $0x10,%esp
  800ea8:	3b 75 10             	cmp    0x10(%ebp),%esi
  800eab:	72 cd                	jb     800e7a <devcons_write+0x22>
  800ead:	eb 05                	jmp    800eb4 <devcons_write+0x5c>
  800eaf:	be 00 00 00 00       	mov    $0x0,%esi
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  800eb4:	89 f0                	mov    %esi,%eax
  800eb6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800eb9:	5b                   	pop    %ebx
  800eba:	5e                   	pop    %esi
  800ebb:	5f                   	pop    %edi
  800ebc:	c9                   	leave  
  800ebd:	c3                   	ret    

00800ebe <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  800ebe:	55                   	push   %ebp
  800ebf:	89 e5                	mov    %esp,%ebp
  800ec1:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
  800ec4:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800ec8:	75 07                	jne    800ed1 <devcons_read+0x13>
  800eca:	eb 25                	jmp    800ef1 <devcons_read+0x33>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  800ecc:	e8 b8 f2 ff ff       	call   800189 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  800ed1:	e8 49 f2 ff ff       	call   80011f <sys_cgetc>
  800ed6:	85 c0                	test   %eax,%eax
  800ed8:	74 f2                	je     800ecc <devcons_read+0xe>
  800eda:	89 c2                	mov    %eax,%edx
		sys_yield();
	if (c < 0)
  800edc:	85 c0                	test   %eax,%eax
  800ede:	78 1d                	js     800efd <devcons_read+0x3f>
		return c;
	if (c == 0x04)	// ctl-d is eof
  800ee0:	83 f8 04             	cmp    $0x4,%eax
  800ee3:	74 13                	je     800ef8 <devcons_read+0x3a>
		return 0;
	*(char*)vbuf = c;
  800ee5:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ee8:	88 10                	mov    %dl,(%eax)
	return 1;
  800eea:	b8 01 00 00 00       	mov    $0x1,%eax
  800eef:	eb 0c                	jmp    800efd <devcons_read+0x3f>
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
		return 0;
  800ef1:	b8 00 00 00 00       	mov    $0x0,%eax
  800ef6:	eb 05                	jmp    800efd <devcons_read+0x3f>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  800ef8:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  800efd:	c9                   	leave  
  800efe:	c3                   	ret    

00800eff <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  800eff:	55                   	push   %ebp
  800f00:	89 e5                	mov    %esp,%ebp
  800f02:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  800f05:	8b 45 08             	mov    0x8(%ebp),%eax
  800f08:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  800f0b:	6a 01                	push   $0x1
  800f0d:	8d 45 f7             	lea    -0x9(%ebp),%eax
  800f10:	50                   	push   %eax
  800f11:	e8 e3 f1 ff ff       	call   8000f9 <sys_cputs>
  800f16:	83 c4 10             	add    $0x10,%esp
}
  800f19:	c9                   	leave  
  800f1a:	c3                   	ret    

00800f1b <getchar>:

int
getchar(void)
{
  800f1b:	55                   	push   %ebp
  800f1c:	89 e5                	mov    %esp,%ebp
  800f1e:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  800f21:	6a 01                	push   $0x1
  800f23:	8d 45 f7             	lea    -0x9(%ebp),%eax
  800f26:	50                   	push   %eax
  800f27:	6a 00                	push   $0x0
  800f29:	e8 de f6 ff ff       	call   80060c <read>
	if (r < 0)
  800f2e:	83 c4 10             	add    $0x10,%esp
  800f31:	85 c0                	test   %eax,%eax
  800f33:	78 0f                	js     800f44 <getchar+0x29>
		return r;
	if (r < 1)
  800f35:	85 c0                	test   %eax,%eax
  800f37:	7e 06                	jle    800f3f <getchar+0x24>
		return -E_EOF;
	return c;
  800f39:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  800f3d:	eb 05                	jmp    800f44 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  800f3f:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  800f44:	c9                   	leave  
  800f45:	c3                   	ret    

00800f46 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  800f46:	55                   	push   %ebp
  800f47:	89 e5                	mov    %esp,%ebp
  800f49:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800f4c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800f4f:	50                   	push   %eax
  800f50:	ff 75 08             	pushl  0x8(%ebp)
  800f53:	e8 33 f4 ff ff       	call   80038b <fd_lookup>
  800f58:	83 c4 10             	add    $0x10,%esp
  800f5b:	85 c0                	test   %eax,%eax
  800f5d:	78 11                	js     800f70 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  800f5f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800f62:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  800f68:	39 10                	cmp    %edx,(%eax)
  800f6a:	0f 94 c0             	sete   %al
  800f6d:	0f b6 c0             	movzbl %al,%eax
}
  800f70:	c9                   	leave  
  800f71:	c3                   	ret    

00800f72 <opencons>:

int
opencons(void)
{
  800f72:	55                   	push   %ebp
  800f73:	89 e5                	mov    %esp,%ebp
  800f75:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  800f78:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800f7b:	50                   	push   %eax
  800f7c:	e8 97 f3 ff ff       	call   800318 <fd_alloc>
  800f81:	83 c4 10             	add    $0x10,%esp
  800f84:	85 c0                	test   %eax,%eax
  800f86:	78 3a                	js     800fc2 <opencons+0x50>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  800f88:	83 ec 04             	sub    $0x4,%esp
  800f8b:	68 07 04 00 00       	push   $0x407
  800f90:	ff 75 f4             	pushl  -0xc(%ebp)
  800f93:	6a 00                	push   $0x0
  800f95:	e8 16 f2 ff ff       	call   8001b0 <sys_page_alloc>
  800f9a:	83 c4 10             	add    $0x10,%esp
  800f9d:	85 c0                	test   %eax,%eax
  800f9f:	78 21                	js     800fc2 <opencons+0x50>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  800fa1:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  800fa7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800faa:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  800fac:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800faf:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  800fb6:	83 ec 0c             	sub    $0xc,%esp
  800fb9:	50                   	push   %eax
  800fba:	e8 31 f3 ff ff       	call   8002f0 <fd2num>
  800fbf:	83 c4 10             	add    $0x10,%esp
}
  800fc2:	c9                   	leave  
  800fc3:	c3                   	ret    

00800fc4 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800fc4:	55                   	push   %ebp
  800fc5:	89 e5                	mov    %esp,%ebp
  800fc7:	56                   	push   %esi
  800fc8:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800fc9:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800fcc:	8b 1d 00 30 80 00    	mov    0x803000,%ebx
  800fd2:	e8 8e f1 ff ff       	call   800165 <sys_getenvid>
  800fd7:	83 ec 0c             	sub    $0xc,%esp
  800fda:	ff 75 0c             	pushl  0xc(%ebp)
  800fdd:	ff 75 08             	pushl  0x8(%ebp)
  800fe0:	53                   	push   %ebx
  800fe1:	50                   	push   %eax
  800fe2:	68 f0 1e 80 00       	push   $0x801ef0
  800fe7:	e8 b0 00 00 00       	call   80109c <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800fec:	83 c4 18             	add    $0x18,%esp
  800fef:	56                   	push   %esi
  800ff0:	ff 75 10             	pushl  0x10(%ebp)
  800ff3:	e8 53 00 00 00       	call   80104b <vcprintf>
	cprintf("\n");
  800ff8:	c7 04 24 c1 1e 80 00 	movl   $0x801ec1,(%esp)
  800fff:	e8 98 00 00 00       	call   80109c <cprintf>
  801004:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801007:	cc                   	int3   
  801008:	eb fd                	jmp    801007 <_panic+0x43>
	...

0080100c <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80100c:	55                   	push   %ebp
  80100d:	89 e5                	mov    %esp,%ebp
  80100f:	53                   	push   %ebx
  801010:	83 ec 04             	sub    $0x4,%esp
  801013:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  801016:	8b 03                	mov    (%ebx),%eax
  801018:	8b 55 08             	mov    0x8(%ebp),%edx
  80101b:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  80101f:	40                   	inc    %eax
  801020:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  801022:	3d ff 00 00 00       	cmp    $0xff,%eax
  801027:	75 1a                	jne    801043 <putch+0x37>
		sys_cputs(b->buf, b->idx);
  801029:	83 ec 08             	sub    $0x8,%esp
  80102c:	68 ff 00 00 00       	push   $0xff
  801031:	8d 43 08             	lea    0x8(%ebx),%eax
  801034:	50                   	push   %eax
  801035:	e8 bf f0 ff ff       	call   8000f9 <sys_cputs>
		b->idx = 0;
  80103a:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801040:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  801043:	ff 43 04             	incl   0x4(%ebx)
}
  801046:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801049:	c9                   	leave  
  80104a:	c3                   	ret    

0080104b <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80104b:	55                   	push   %ebp
  80104c:	89 e5                	mov    %esp,%ebp
  80104e:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  801054:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80105b:	00 00 00 
	b.cnt = 0;
  80105e:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  801065:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  801068:	ff 75 0c             	pushl  0xc(%ebp)
  80106b:	ff 75 08             	pushl  0x8(%ebp)
  80106e:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  801074:	50                   	push   %eax
  801075:	68 0c 10 80 00       	push   $0x80100c
  80107a:	e8 82 01 00 00       	call   801201 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80107f:	83 c4 08             	add    $0x8,%esp
  801082:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  801088:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80108e:	50                   	push   %eax
  80108f:	e8 65 f0 ff ff       	call   8000f9 <sys_cputs>

	return b.cnt;
}
  801094:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80109a:	c9                   	leave  
  80109b:	c3                   	ret    

0080109c <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80109c:	55                   	push   %ebp
  80109d:	89 e5                	mov    %esp,%ebp
  80109f:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8010a2:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8010a5:	50                   	push   %eax
  8010a6:	ff 75 08             	pushl  0x8(%ebp)
  8010a9:	e8 9d ff ff ff       	call   80104b <vcprintf>
	va_end(ap);

	return cnt;
}
  8010ae:	c9                   	leave  
  8010af:	c3                   	ret    

008010b0 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8010b0:	55                   	push   %ebp
  8010b1:	89 e5                	mov    %esp,%ebp
  8010b3:	57                   	push   %edi
  8010b4:	56                   	push   %esi
  8010b5:	53                   	push   %ebx
  8010b6:	83 ec 2c             	sub    $0x2c,%esp
  8010b9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8010bc:	89 d6                	mov    %edx,%esi
  8010be:	8b 45 08             	mov    0x8(%ebp),%eax
  8010c1:	8b 55 0c             	mov    0xc(%ebp),%edx
  8010c4:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8010c7:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8010ca:	8b 45 10             	mov    0x10(%ebp),%eax
  8010cd:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8010d0:	8b 7d 18             	mov    0x18(%ebp),%edi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8010d3:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8010d6:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  8010dd:	39 55 d4             	cmp    %edx,-0x2c(%ebp)
  8010e0:	72 0c                	jb     8010ee <printnum+0x3e>
  8010e2:	3b 45 d8             	cmp    -0x28(%ebp),%eax
  8010e5:	76 07                	jbe    8010ee <printnum+0x3e>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8010e7:	4b                   	dec    %ebx
  8010e8:	85 db                	test   %ebx,%ebx
  8010ea:	7f 31                	jg     80111d <printnum+0x6d>
  8010ec:	eb 3f                	jmp    80112d <printnum+0x7d>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8010ee:	83 ec 0c             	sub    $0xc,%esp
  8010f1:	57                   	push   %edi
  8010f2:	4b                   	dec    %ebx
  8010f3:	53                   	push   %ebx
  8010f4:	50                   	push   %eax
  8010f5:	83 ec 08             	sub    $0x8,%esp
  8010f8:	ff 75 d4             	pushl  -0x2c(%ebp)
  8010fb:	ff 75 d0             	pushl  -0x30(%ebp)
  8010fe:	ff 75 dc             	pushl  -0x24(%ebp)
  801101:	ff 75 d8             	pushl  -0x28(%ebp)
  801104:	e8 63 0a 00 00       	call   801b6c <__udivdi3>
  801109:	83 c4 18             	add    $0x18,%esp
  80110c:	52                   	push   %edx
  80110d:	50                   	push   %eax
  80110e:	89 f2                	mov    %esi,%edx
  801110:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801113:	e8 98 ff ff ff       	call   8010b0 <printnum>
  801118:	83 c4 20             	add    $0x20,%esp
  80111b:	eb 10                	jmp    80112d <printnum+0x7d>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80111d:	83 ec 08             	sub    $0x8,%esp
  801120:	56                   	push   %esi
  801121:	57                   	push   %edi
  801122:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  801125:	4b                   	dec    %ebx
  801126:	83 c4 10             	add    $0x10,%esp
  801129:	85 db                	test   %ebx,%ebx
  80112b:	7f f0                	jg     80111d <printnum+0x6d>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80112d:	83 ec 08             	sub    $0x8,%esp
  801130:	56                   	push   %esi
  801131:	83 ec 04             	sub    $0x4,%esp
  801134:	ff 75 d4             	pushl  -0x2c(%ebp)
  801137:	ff 75 d0             	pushl  -0x30(%ebp)
  80113a:	ff 75 dc             	pushl  -0x24(%ebp)
  80113d:	ff 75 d8             	pushl  -0x28(%ebp)
  801140:	e8 43 0b 00 00       	call   801c88 <__umoddi3>
  801145:	83 c4 14             	add    $0x14,%esp
  801148:	0f be 80 13 1f 80 00 	movsbl 0x801f13(%eax),%eax
  80114f:	50                   	push   %eax
  801150:	ff 55 e4             	call   *-0x1c(%ebp)
  801153:	83 c4 10             	add    $0x10,%esp
}
  801156:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801159:	5b                   	pop    %ebx
  80115a:	5e                   	pop    %esi
  80115b:	5f                   	pop    %edi
  80115c:	c9                   	leave  
  80115d:	c3                   	ret    

0080115e <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80115e:	55                   	push   %ebp
  80115f:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  801161:	83 fa 01             	cmp    $0x1,%edx
  801164:	7e 0e                	jle    801174 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  801166:	8b 10                	mov    (%eax),%edx
  801168:	8d 4a 08             	lea    0x8(%edx),%ecx
  80116b:	89 08                	mov    %ecx,(%eax)
  80116d:	8b 02                	mov    (%edx),%eax
  80116f:	8b 52 04             	mov    0x4(%edx),%edx
  801172:	eb 22                	jmp    801196 <getuint+0x38>
	else if (lflag)
  801174:	85 d2                	test   %edx,%edx
  801176:	74 10                	je     801188 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  801178:	8b 10                	mov    (%eax),%edx
  80117a:	8d 4a 04             	lea    0x4(%edx),%ecx
  80117d:	89 08                	mov    %ecx,(%eax)
  80117f:	8b 02                	mov    (%edx),%eax
  801181:	ba 00 00 00 00       	mov    $0x0,%edx
  801186:	eb 0e                	jmp    801196 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  801188:	8b 10                	mov    (%eax),%edx
  80118a:	8d 4a 04             	lea    0x4(%edx),%ecx
  80118d:	89 08                	mov    %ecx,(%eax)
  80118f:	8b 02                	mov    (%edx),%eax
  801191:	ba 00 00 00 00       	mov    $0x0,%edx
}
  801196:	c9                   	leave  
  801197:	c3                   	ret    

00801198 <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
  801198:	55                   	push   %ebp
  801199:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80119b:	83 fa 01             	cmp    $0x1,%edx
  80119e:	7e 0e                	jle    8011ae <getint+0x16>
		return va_arg(*ap, long long);
  8011a0:	8b 10                	mov    (%eax),%edx
  8011a2:	8d 4a 08             	lea    0x8(%edx),%ecx
  8011a5:	89 08                	mov    %ecx,(%eax)
  8011a7:	8b 02                	mov    (%edx),%eax
  8011a9:	8b 52 04             	mov    0x4(%edx),%edx
  8011ac:	eb 1a                	jmp    8011c8 <getint+0x30>
	else if (lflag)
  8011ae:	85 d2                	test   %edx,%edx
  8011b0:	74 0c                	je     8011be <getint+0x26>
		return va_arg(*ap, long);
  8011b2:	8b 10                	mov    (%eax),%edx
  8011b4:	8d 4a 04             	lea    0x4(%edx),%ecx
  8011b7:	89 08                	mov    %ecx,(%eax)
  8011b9:	8b 02                	mov    (%edx),%eax
  8011bb:	99                   	cltd   
  8011bc:	eb 0a                	jmp    8011c8 <getint+0x30>
	else
		return va_arg(*ap, int);
  8011be:	8b 10                	mov    (%eax),%edx
  8011c0:	8d 4a 04             	lea    0x4(%edx),%ecx
  8011c3:	89 08                	mov    %ecx,(%eax)
  8011c5:	8b 02                	mov    (%edx),%eax
  8011c7:	99                   	cltd   
}
  8011c8:	c9                   	leave  
  8011c9:	c3                   	ret    

008011ca <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8011ca:	55                   	push   %ebp
  8011cb:	89 e5                	mov    %esp,%ebp
  8011cd:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8011d0:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  8011d3:	8b 10                	mov    (%eax),%edx
  8011d5:	3b 50 04             	cmp    0x4(%eax),%edx
  8011d8:	73 08                	jae    8011e2 <sprintputch+0x18>
		*b->buf++ = ch;
  8011da:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8011dd:	88 0a                	mov    %cl,(%edx)
  8011df:	42                   	inc    %edx
  8011e0:	89 10                	mov    %edx,(%eax)
}
  8011e2:	c9                   	leave  
  8011e3:	c3                   	ret    

008011e4 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8011e4:	55                   	push   %ebp
  8011e5:	89 e5                	mov    %esp,%ebp
  8011e7:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8011ea:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8011ed:	50                   	push   %eax
  8011ee:	ff 75 10             	pushl  0x10(%ebp)
  8011f1:	ff 75 0c             	pushl  0xc(%ebp)
  8011f4:	ff 75 08             	pushl  0x8(%ebp)
  8011f7:	e8 05 00 00 00       	call   801201 <vprintfmt>
	va_end(ap);
  8011fc:	83 c4 10             	add    $0x10,%esp
}
  8011ff:	c9                   	leave  
  801200:	c3                   	ret    

00801201 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  801201:	55                   	push   %ebp
  801202:	89 e5                	mov    %esp,%ebp
  801204:	57                   	push   %edi
  801205:	56                   	push   %esi
  801206:	53                   	push   %ebx
  801207:	83 ec 2c             	sub    $0x2c,%esp
  80120a:	8b 7d 0c             	mov    0xc(%ebp),%edi
  80120d:	8b 75 10             	mov    0x10(%ebp),%esi
  801210:	eb 13                	jmp    801225 <vprintfmt+0x24>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  801212:	85 c0                	test   %eax,%eax
  801214:	0f 84 6d 03 00 00    	je     801587 <vprintfmt+0x386>
				return;
			putch(ch, putdat);
  80121a:	83 ec 08             	sub    $0x8,%esp
  80121d:	57                   	push   %edi
  80121e:	50                   	push   %eax
  80121f:	ff 55 08             	call   *0x8(%ebp)
  801222:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  801225:	0f b6 06             	movzbl (%esi),%eax
  801228:	46                   	inc    %esi
  801229:	83 f8 25             	cmp    $0x25,%eax
  80122c:	75 e4                	jne    801212 <vprintfmt+0x11>
  80122e:	c6 45 dc 20          	movb   $0x20,-0x24(%ebp)
  801232:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  801239:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
  801240:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  801247:	b9 00 00 00 00       	mov    $0x0,%ecx
  80124c:	eb 28                	jmp    801276 <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80124e:	89 de                	mov    %ebx,%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  801250:	c6 45 dc 2d          	movb   $0x2d,-0x24(%ebp)
  801254:	eb 20                	jmp    801276 <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801256:	89 de                	mov    %ebx,%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  801258:	c6 45 dc 30          	movb   $0x30,-0x24(%ebp)
  80125c:	eb 18                	jmp    801276 <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80125e:	89 de                	mov    %ebx,%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  801260:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  801267:	eb 0d                	jmp    801276 <vprintfmt+0x75>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  801269:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80126c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80126f:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801276:	8a 06                	mov    (%esi),%al
  801278:	0f b6 d0             	movzbl %al,%edx
  80127b:	8d 5e 01             	lea    0x1(%esi),%ebx
  80127e:	83 e8 23             	sub    $0x23,%eax
  801281:	3c 55                	cmp    $0x55,%al
  801283:	0f 87 e0 02 00 00    	ja     801569 <vprintfmt+0x368>
  801289:	0f b6 c0             	movzbl %al,%eax
  80128c:	ff 24 85 60 20 80 00 	jmp    *0x802060(,%eax,4)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  801293:	83 ea 30             	sub    $0x30,%edx
  801296:	89 55 d4             	mov    %edx,-0x2c(%ebp)
				ch = *fmt;
  801299:	0f be 03             	movsbl (%ebx),%eax
				if (ch < '0' || ch > '9')
  80129c:	8d 50 d0             	lea    -0x30(%eax),%edx
  80129f:	83 fa 09             	cmp    $0x9,%edx
  8012a2:	77 44                	ja     8012e8 <vprintfmt+0xe7>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8012a4:	89 de                	mov    %ebx,%esi
  8012a6:	8b 55 d4             	mov    -0x2c(%ebp),%edx
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8012a9:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
  8012aa:	8d 14 92             	lea    (%edx,%edx,4),%edx
  8012ad:	8d 54 50 d0          	lea    -0x30(%eax,%edx,2),%edx
				ch = *fmt;
  8012b1:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  8012b4:	8d 58 d0             	lea    -0x30(%eax),%ebx
  8012b7:	83 fb 09             	cmp    $0x9,%ebx
  8012ba:	76 ed                	jbe    8012a9 <vprintfmt+0xa8>
  8012bc:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  8012bf:	eb 29                	jmp    8012ea <vprintfmt+0xe9>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8012c1:	8b 45 14             	mov    0x14(%ebp),%eax
  8012c4:	8d 50 04             	lea    0x4(%eax),%edx
  8012c7:	89 55 14             	mov    %edx,0x14(%ebp)
  8012ca:	8b 00                	mov    (%eax),%eax
  8012cc:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8012cf:	89 de                	mov    %ebx,%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8012d1:	eb 17                	jmp    8012ea <vprintfmt+0xe9>

		case '.':
			if (width < 0)
  8012d3:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8012d7:	78 85                	js     80125e <vprintfmt+0x5d>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8012d9:	89 de                	mov    %ebx,%esi
  8012db:	eb 99                	jmp    801276 <vprintfmt+0x75>
  8012dd:	89 de                	mov    %ebx,%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8012df:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
			goto reswitch;
  8012e6:	eb 8e                	jmp    801276 <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8012e8:	89 de                	mov    %ebx,%esi
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  8012ea:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8012ee:	79 86                	jns    801276 <vprintfmt+0x75>
  8012f0:	e9 74 ff ff ff       	jmp    801269 <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8012f5:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8012f6:	89 de                	mov    %ebx,%esi
  8012f8:	e9 79 ff ff ff       	jmp    801276 <vprintfmt+0x75>
  8012fd:	89 5d d8             	mov    %ebx,-0x28(%ebp)
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  801300:	8b 45 14             	mov    0x14(%ebp),%eax
  801303:	8d 50 04             	lea    0x4(%eax),%edx
  801306:	89 55 14             	mov    %edx,0x14(%ebp)
  801309:	83 ec 08             	sub    $0x8,%esp
  80130c:	57                   	push   %edi
  80130d:	ff 30                	pushl  (%eax)
  80130f:	ff 55 08             	call   *0x8(%ebp)
			break;
  801312:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801315:	8b 75 d8             	mov    -0x28(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  801318:	e9 08 ff ff ff       	jmp    801225 <vprintfmt+0x24>
  80131d:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// error message
		case 'e':
			err = va_arg(ap, int);
  801320:	8b 45 14             	mov    0x14(%ebp),%eax
  801323:	8d 50 04             	lea    0x4(%eax),%edx
  801326:	89 55 14             	mov    %edx,0x14(%ebp)
  801329:	8b 00                	mov    (%eax),%eax
  80132b:	85 c0                	test   %eax,%eax
  80132d:	79 02                	jns    801331 <vprintfmt+0x130>
  80132f:	f7 d8                	neg    %eax
  801331:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  801333:	83 f8 0f             	cmp    $0xf,%eax
  801336:	7f 0b                	jg     801343 <vprintfmt+0x142>
  801338:	8b 04 85 c0 21 80 00 	mov    0x8021c0(,%eax,4),%eax
  80133f:	85 c0                	test   %eax,%eax
  801341:	75 1a                	jne    80135d <vprintfmt+0x15c>
				printfmt(putch, putdat, "error %d", err);
  801343:	52                   	push   %edx
  801344:	68 2b 1f 80 00       	push   $0x801f2b
  801349:	57                   	push   %edi
  80134a:	ff 75 08             	pushl  0x8(%ebp)
  80134d:	e8 92 fe ff ff       	call   8011e4 <printfmt>
  801352:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801355:	8b 75 d8             	mov    -0x28(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  801358:	e9 c8 fe ff ff       	jmp    801225 <vprintfmt+0x24>
			else
				printfmt(putch, putdat, "%s", p);
  80135d:	50                   	push   %eax
  80135e:	68 a3 1e 80 00       	push   $0x801ea3
  801363:	57                   	push   %edi
  801364:	ff 75 08             	pushl  0x8(%ebp)
  801367:	e8 78 fe ff ff       	call   8011e4 <printfmt>
  80136c:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80136f:	8b 75 d8             	mov    -0x28(%ebp),%esi
  801372:	e9 ae fe ff ff       	jmp    801225 <vprintfmt+0x24>
  801377:	89 5d d8             	mov    %ebx,-0x28(%ebp)
  80137a:	89 de                	mov    %ebx,%esi
  80137c:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  80137f:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  801382:	8b 45 14             	mov    0x14(%ebp),%eax
  801385:	8d 50 04             	lea    0x4(%eax),%edx
  801388:	89 55 14             	mov    %edx,0x14(%ebp)
  80138b:	8b 00                	mov    (%eax),%eax
  80138d:	89 45 d0             	mov    %eax,-0x30(%ebp)
  801390:	85 c0                	test   %eax,%eax
  801392:	75 07                	jne    80139b <vprintfmt+0x19a>
				p = "(null)";
  801394:	c7 45 d0 24 1f 80 00 	movl   $0x801f24,-0x30(%ebp)
			if (width > 0 && padc != '-')
  80139b:	85 db                	test   %ebx,%ebx
  80139d:	7e 42                	jle    8013e1 <vprintfmt+0x1e0>
  80139f:	80 7d dc 2d          	cmpb   $0x2d,-0x24(%ebp)
  8013a3:	74 3c                	je     8013e1 <vprintfmt+0x1e0>
				for (width -= strnlen(p, precision); width > 0; width--)
  8013a5:	83 ec 08             	sub    $0x8,%esp
  8013a8:	51                   	push   %ecx
  8013a9:	ff 75 d0             	pushl  -0x30(%ebp)
  8013ac:	e8 6f 02 00 00       	call   801620 <strnlen>
  8013b1:	29 c3                	sub    %eax,%ebx
  8013b3:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8013b6:	83 c4 10             	add    $0x10,%esp
  8013b9:	85 db                	test   %ebx,%ebx
  8013bb:	7e 24                	jle    8013e1 <vprintfmt+0x1e0>
					putch(padc, putdat);
  8013bd:	0f be 5d dc          	movsbl -0x24(%ebp),%ebx
  8013c1:	89 75 dc             	mov    %esi,-0x24(%ebp)
  8013c4:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  8013c7:	83 ec 08             	sub    $0x8,%esp
  8013ca:	57                   	push   %edi
  8013cb:	53                   	push   %ebx
  8013cc:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8013cf:	4e                   	dec    %esi
  8013d0:	83 c4 10             	add    $0x10,%esp
  8013d3:	85 f6                	test   %esi,%esi
  8013d5:	7f f0                	jg     8013c7 <vprintfmt+0x1c6>
  8013d7:	8b 75 dc             	mov    -0x24(%ebp),%esi
  8013da:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8013e1:	8b 55 d0             	mov    -0x30(%ebp),%edx
  8013e4:	0f be 02             	movsbl (%edx),%eax
  8013e7:	85 c0                	test   %eax,%eax
  8013e9:	75 47                	jne    801432 <vprintfmt+0x231>
  8013eb:	eb 37                	jmp    801424 <vprintfmt+0x223>
				if (altflag && (ch < ' ' || ch > '~'))
  8013ed:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8013f1:	74 16                	je     801409 <vprintfmt+0x208>
  8013f3:	8d 50 e0             	lea    -0x20(%eax),%edx
  8013f6:	83 fa 5e             	cmp    $0x5e,%edx
  8013f9:	76 0e                	jbe    801409 <vprintfmt+0x208>
					putch('?', putdat);
  8013fb:	83 ec 08             	sub    $0x8,%esp
  8013fe:	57                   	push   %edi
  8013ff:	6a 3f                	push   $0x3f
  801401:	ff 55 08             	call   *0x8(%ebp)
  801404:	83 c4 10             	add    $0x10,%esp
  801407:	eb 0b                	jmp    801414 <vprintfmt+0x213>
				else
					putch(ch, putdat);
  801409:	83 ec 08             	sub    $0x8,%esp
  80140c:	57                   	push   %edi
  80140d:	50                   	push   %eax
  80140e:	ff 55 08             	call   *0x8(%ebp)
  801411:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  801414:	ff 4d e4             	decl   -0x1c(%ebp)
  801417:	0f be 03             	movsbl (%ebx),%eax
  80141a:	85 c0                	test   %eax,%eax
  80141c:	74 03                	je     801421 <vprintfmt+0x220>
  80141e:	43                   	inc    %ebx
  80141f:	eb 1b                	jmp    80143c <vprintfmt+0x23b>
  801421:	8b 75 dc             	mov    -0x24(%ebp),%esi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  801424:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  801428:	7f 1e                	jg     801448 <vprintfmt+0x247>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80142a:	8b 75 d8             	mov    -0x28(%ebp),%esi
  80142d:	e9 f3 fd ff ff       	jmp    801225 <vprintfmt+0x24>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  801432:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  801435:	43                   	inc    %ebx
  801436:	89 75 dc             	mov    %esi,-0x24(%ebp)
  801439:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  80143c:	85 f6                	test   %esi,%esi
  80143e:	78 ad                	js     8013ed <vprintfmt+0x1ec>
  801440:	4e                   	dec    %esi
  801441:	79 aa                	jns    8013ed <vprintfmt+0x1ec>
  801443:	8b 75 dc             	mov    -0x24(%ebp),%esi
  801446:	eb dc                	jmp    801424 <vprintfmt+0x223>
  801448:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80144b:	83 ec 08             	sub    $0x8,%esp
  80144e:	57                   	push   %edi
  80144f:	6a 20                	push   $0x20
  801451:	ff 55 08             	call   *0x8(%ebp)
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  801454:	4b                   	dec    %ebx
  801455:	83 c4 10             	add    $0x10,%esp
  801458:	85 db                	test   %ebx,%ebx
  80145a:	7f ef                	jg     80144b <vprintfmt+0x24a>
  80145c:	e9 c4 fd ff ff       	jmp    801225 <vprintfmt+0x24>
  801461:	89 5d d8             	mov    %ebx,-0x28(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  801464:	89 ca                	mov    %ecx,%edx
  801466:	8d 45 14             	lea    0x14(%ebp),%eax
  801469:	e8 2a fd ff ff       	call   801198 <getint>
  80146e:	89 c3                	mov    %eax,%ebx
  801470:	89 d6                	mov    %edx,%esi
			if ((long long) num < 0) {
  801472:	85 d2                	test   %edx,%edx
  801474:	78 0a                	js     801480 <vprintfmt+0x27f>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  801476:	b8 0a 00 00 00       	mov    $0xa,%eax
  80147b:	e9 b0 00 00 00       	jmp    801530 <vprintfmt+0x32f>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  801480:	83 ec 08             	sub    $0x8,%esp
  801483:	57                   	push   %edi
  801484:	6a 2d                	push   $0x2d
  801486:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  801489:	f7 db                	neg    %ebx
  80148b:	83 d6 00             	adc    $0x0,%esi
  80148e:	f7 de                	neg    %esi
  801490:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  801493:	b8 0a 00 00 00       	mov    $0xa,%eax
  801498:	e9 93 00 00 00       	jmp    801530 <vprintfmt+0x32f>
  80149d:	89 5d d8             	mov    %ebx,-0x28(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8014a0:	89 ca                	mov    %ecx,%edx
  8014a2:	8d 45 14             	lea    0x14(%ebp),%eax
  8014a5:	e8 b4 fc ff ff       	call   80115e <getuint>
  8014aa:	89 c3                	mov    %eax,%ebx
  8014ac:	89 d6                	mov    %edx,%esi
			base = 10;
  8014ae:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  8014b3:	eb 7b                	jmp    801530 <vprintfmt+0x32f>
  8014b5:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// (unsigned) octal
		case 'o':
            // (MIT 6.828, lab1, Ex.8)  my code : 
            num = getint(&ap, lflag);
  8014b8:	89 ca                	mov    %ecx,%edx
  8014ba:	8d 45 14             	lea    0x14(%ebp),%eax
  8014bd:	e8 d6 fc ff ff       	call   801198 <getint>
  8014c2:	89 c3                	mov    %eax,%ebx
  8014c4:	89 d6                	mov    %edx,%esi
            if ((long long) num < 0) {
  8014c6:	85 d2                	test   %edx,%edx
  8014c8:	78 07                	js     8014d1 <vprintfmt+0x2d0>
                putch('-', putdat);
                num = -(long long) num;
            }
            base = 8;
  8014ca:	b8 08 00 00 00       	mov    $0x8,%eax
  8014cf:	eb 5f                	jmp    801530 <vprintfmt+0x32f>
		// (unsigned) octal
		case 'o':
            // (MIT 6.828, lab1, Ex.8)  my code : 
            num = getint(&ap, lflag);
            if ((long long) num < 0) {
                putch('-', putdat);
  8014d1:	83 ec 08             	sub    $0x8,%esp
  8014d4:	57                   	push   %edi
  8014d5:	6a 2d                	push   $0x2d
  8014d7:	ff 55 08             	call   *0x8(%ebp)
                num = -(long long) num;
  8014da:	f7 db                	neg    %ebx
  8014dc:	83 d6 00             	adc    $0x0,%esi
  8014df:	f7 de                	neg    %esi
  8014e1:	83 c4 10             	add    $0x10,%esp
            }
            base = 8;
  8014e4:	b8 08 00 00 00       	mov    $0x8,%eax
  8014e9:	eb 45                	jmp    801530 <vprintfmt+0x32f>
  8014eb:	89 5d d8             	mov    %ebx,-0x28(%ebp)
            goto number;

        // pointer
		case 'p':
			putch('0', putdat);
  8014ee:	83 ec 08             	sub    $0x8,%esp
  8014f1:	57                   	push   %edi
  8014f2:	6a 30                	push   $0x30
  8014f4:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  8014f7:	83 c4 08             	add    $0x8,%esp
  8014fa:	57                   	push   %edi
  8014fb:	6a 78                	push   $0x78
  8014fd:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  801500:	8b 45 14             	mov    0x14(%ebp),%eax
  801503:	8d 50 04             	lea    0x4(%eax),%edx
  801506:	89 55 14             	mov    %edx,0x14(%ebp)

        // pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  801509:	8b 18                	mov    (%eax),%ebx
  80150b:	be 00 00 00 00       	mov    $0x0,%esi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  801510:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  801513:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  801518:	eb 16                	jmp    801530 <vprintfmt+0x32f>
  80151a:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  80151d:	89 ca                	mov    %ecx,%edx
  80151f:	8d 45 14             	lea    0x14(%ebp),%eax
  801522:	e8 37 fc ff ff       	call   80115e <getuint>
  801527:	89 c3                	mov    %eax,%ebx
  801529:	89 d6                	mov    %edx,%esi
			base = 16;
  80152b:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  801530:	83 ec 0c             	sub    $0xc,%esp
  801533:	0f be 55 dc          	movsbl -0x24(%ebp),%edx
  801537:	52                   	push   %edx
  801538:	ff 75 e4             	pushl  -0x1c(%ebp)
  80153b:	50                   	push   %eax
  80153c:	56                   	push   %esi
  80153d:	53                   	push   %ebx
  80153e:	89 fa                	mov    %edi,%edx
  801540:	8b 45 08             	mov    0x8(%ebp),%eax
  801543:	e8 68 fb ff ff       	call   8010b0 <printnum>
			break;
  801548:	83 c4 20             	add    $0x20,%esp
  80154b:	8b 75 d8             	mov    -0x28(%ebp),%esi
  80154e:	e9 d2 fc ff ff       	jmp    801225 <vprintfmt+0x24>
  801553:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  801556:	83 ec 08             	sub    $0x8,%esp
  801559:	57                   	push   %edi
  80155a:	52                   	push   %edx
  80155b:	ff 55 08             	call   *0x8(%ebp)
			break;
  80155e:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801561:	8b 75 d8             	mov    -0x28(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  801564:	e9 bc fc ff ff       	jmp    801225 <vprintfmt+0x24>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  801569:	83 ec 08             	sub    $0x8,%esp
  80156c:	57                   	push   %edi
  80156d:	6a 25                	push   $0x25
  80156f:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  801572:	83 c4 10             	add    $0x10,%esp
  801575:	eb 02                	jmp    801579 <vprintfmt+0x378>
  801577:	89 c6                	mov    %eax,%esi
  801579:	8d 46 ff             	lea    -0x1(%esi),%eax
  80157c:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  801580:	75 f5                	jne    801577 <vprintfmt+0x376>
  801582:	e9 9e fc ff ff       	jmp    801225 <vprintfmt+0x24>
				/* do nothing */;
			break;
		}
	}
}
  801587:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80158a:	5b                   	pop    %ebx
  80158b:	5e                   	pop    %esi
  80158c:	5f                   	pop    %edi
  80158d:	c9                   	leave  
  80158e:	c3                   	ret    

0080158f <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80158f:	55                   	push   %ebp
  801590:	89 e5                	mov    %esp,%ebp
  801592:	83 ec 18             	sub    $0x18,%esp
  801595:	8b 45 08             	mov    0x8(%ebp),%eax
  801598:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80159b:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80159e:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8015a2:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8015a5:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8015ac:	85 c0                	test   %eax,%eax
  8015ae:	74 26                	je     8015d6 <vsnprintf+0x47>
  8015b0:	85 d2                	test   %edx,%edx
  8015b2:	7e 29                	jle    8015dd <vsnprintf+0x4e>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8015b4:	ff 75 14             	pushl  0x14(%ebp)
  8015b7:	ff 75 10             	pushl  0x10(%ebp)
  8015ba:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8015bd:	50                   	push   %eax
  8015be:	68 ca 11 80 00       	push   $0x8011ca
  8015c3:	e8 39 fc ff ff       	call   801201 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8015c8:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8015cb:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8015ce:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8015d1:	83 c4 10             	add    $0x10,%esp
  8015d4:	eb 0c                	jmp    8015e2 <vsnprintf+0x53>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8015d6:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8015db:	eb 05                	jmp    8015e2 <vsnprintf+0x53>
  8015dd:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8015e2:	c9                   	leave  
  8015e3:	c3                   	ret    

008015e4 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8015e4:	55                   	push   %ebp
  8015e5:	89 e5                	mov    %esp,%ebp
  8015e7:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8015ea:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8015ed:	50                   	push   %eax
  8015ee:	ff 75 10             	pushl  0x10(%ebp)
  8015f1:	ff 75 0c             	pushl  0xc(%ebp)
  8015f4:	ff 75 08             	pushl  0x8(%ebp)
  8015f7:	e8 93 ff ff ff       	call   80158f <vsnprintf>
	va_end(ap);

	return rc;
}
  8015fc:	c9                   	leave  
  8015fd:	c3                   	ret    
	...

00801600 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  801600:	55                   	push   %ebp
  801601:	89 e5                	mov    %esp,%ebp
  801603:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  801606:	80 3a 00             	cmpb   $0x0,(%edx)
  801609:	74 0e                	je     801619 <strlen+0x19>
  80160b:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  801610:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  801611:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  801615:	75 f9                	jne    801610 <strlen+0x10>
  801617:	eb 05                	jmp    80161e <strlen+0x1e>
  801619:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  80161e:	c9                   	leave  
  80161f:	c3                   	ret    

00801620 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  801620:	55                   	push   %ebp
  801621:	89 e5                	mov    %esp,%ebp
  801623:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801626:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801629:	85 d2                	test   %edx,%edx
  80162b:	74 17                	je     801644 <strnlen+0x24>
  80162d:	80 39 00             	cmpb   $0x0,(%ecx)
  801630:	74 19                	je     80164b <strnlen+0x2b>
  801632:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  801637:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801638:	39 d0                	cmp    %edx,%eax
  80163a:	74 14                	je     801650 <strnlen+0x30>
  80163c:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  801640:	75 f5                	jne    801637 <strnlen+0x17>
  801642:	eb 0c                	jmp    801650 <strnlen+0x30>
  801644:	b8 00 00 00 00       	mov    $0x0,%eax
  801649:	eb 05                	jmp    801650 <strnlen+0x30>
  80164b:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  801650:	c9                   	leave  
  801651:	c3                   	ret    

00801652 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  801652:	55                   	push   %ebp
  801653:	89 e5                	mov    %esp,%ebp
  801655:	53                   	push   %ebx
  801656:	8b 45 08             	mov    0x8(%ebp),%eax
  801659:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  80165c:	ba 00 00 00 00       	mov    $0x0,%edx
  801661:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  801664:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  801667:	42                   	inc    %edx
  801668:	84 c9                	test   %cl,%cl
  80166a:	75 f5                	jne    801661 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  80166c:	5b                   	pop    %ebx
  80166d:	c9                   	leave  
  80166e:	c3                   	ret    

0080166f <strcat>:

char *
strcat(char *dst, const char *src)
{
  80166f:	55                   	push   %ebp
  801670:	89 e5                	mov    %esp,%ebp
  801672:	53                   	push   %ebx
  801673:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  801676:	53                   	push   %ebx
  801677:	e8 84 ff ff ff       	call   801600 <strlen>
  80167c:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  80167f:	ff 75 0c             	pushl  0xc(%ebp)
  801682:	8d 04 03             	lea    (%ebx,%eax,1),%eax
  801685:	50                   	push   %eax
  801686:	e8 c7 ff ff ff       	call   801652 <strcpy>
	return dst;
}
  80168b:	89 d8                	mov    %ebx,%eax
  80168d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801690:	c9                   	leave  
  801691:	c3                   	ret    

00801692 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  801692:	55                   	push   %ebp
  801693:	89 e5                	mov    %esp,%ebp
  801695:	56                   	push   %esi
  801696:	53                   	push   %ebx
  801697:	8b 45 08             	mov    0x8(%ebp),%eax
  80169a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80169d:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8016a0:	85 f6                	test   %esi,%esi
  8016a2:	74 15                	je     8016b9 <strncpy+0x27>
  8016a4:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
  8016a9:	8a 1a                	mov    (%edx),%bl
  8016ab:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8016ae:	80 3a 01             	cmpb   $0x1,(%edx)
  8016b1:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8016b4:	41                   	inc    %ecx
  8016b5:	39 ce                	cmp    %ecx,%esi
  8016b7:	77 f0                	ja     8016a9 <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8016b9:	5b                   	pop    %ebx
  8016ba:	5e                   	pop    %esi
  8016bb:	c9                   	leave  
  8016bc:	c3                   	ret    

008016bd <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8016bd:	55                   	push   %ebp
  8016be:	89 e5                	mov    %esp,%ebp
  8016c0:	57                   	push   %edi
  8016c1:	56                   	push   %esi
  8016c2:	53                   	push   %ebx
  8016c3:	8b 7d 08             	mov    0x8(%ebp),%edi
  8016c6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8016c9:	8b 75 10             	mov    0x10(%ebp),%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8016cc:	85 f6                	test   %esi,%esi
  8016ce:	74 32                	je     801702 <strlcpy+0x45>
		while (--size > 0 && *src != '\0')
  8016d0:	83 fe 01             	cmp    $0x1,%esi
  8016d3:	74 22                	je     8016f7 <strlcpy+0x3a>
  8016d5:	8a 0b                	mov    (%ebx),%cl
  8016d7:	84 c9                	test   %cl,%cl
  8016d9:	74 20                	je     8016fb <strlcpy+0x3e>
  8016db:	89 f8                	mov    %edi,%eax
  8016dd:	ba 00 00 00 00       	mov    $0x0,%edx
	}
	return ret;
}

size_t
strlcpy(char *dst, const char *src, size_t size)
  8016e2:	83 ee 02             	sub    $0x2,%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8016e5:	88 08                	mov    %cl,(%eax)
  8016e7:	40                   	inc    %eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8016e8:	39 f2                	cmp    %esi,%edx
  8016ea:	74 11                	je     8016fd <strlcpy+0x40>
  8016ec:	8a 4c 13 01          	mov    0x1(%ebx,%edx,1),%cl
  8016f0:	42                   	inc    %edx
  8016f1:	84 c9                	test   %cl,%cl
  8016f3:	75 f0                	jne    8016e5 <strlcpy+0x28>
  8016f5:	eb 06                	jmp    8016fd <strlcpy+0x40>
  8016f7:	89 f8                	mov    %edi,%eax
  8016f9:	eb 02                	jmp    8016fd <strlcpy+0x40>
  8016fb:	89 f8                	mov    %edi,%eax
			*dst++ = *src++;
		*dst = '\0';
  8016fd:	c6 00 00             	movb   $0x0,(%eax)
  801700:	eb 02                	jmp    801704 <strlcpy+0x47>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  801702:	89 f8                	mov    %edi,%eax
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
		*dst = '\0';
	}
	return dst - dst_in;
  801704:	29 f8                	sub    %edi,%eax
}
  801706:	5b                   	pop    %ebx
  801707:	5e                   	pop    %esi
  801708:	5f                   	pop    %edi
  801709:	c9                   	leave  
  80170a:	c3                   	ret    

0080170b <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80170b:	55                   	push   %ebp
  80170c:	89 e5                	mov    %esp,%ebp
  80170e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801711:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  801714:	8a 01                	mov    (%ecx),%al
  801716:	84 c0                	test   %al,%al
  801718:	74 10                	je     80172a <strcmp+0x1f>
  80171a:	3a 02                	cmp    (%edx),%al
  80171c:	75 0c                	jne    80172a <strcmp+0x1f>
		p++, q++;
  80171e:	41                   	inc    %ecx
  80171f:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  801720:	8a 01                	mov    (%ecx),%al
  801722:	84 c0                	test   %al,%al
  801724:	74 04                	je     80172a <strcmp+0x1f>
  801726:	3a 02                	cmp    (%edx),%al
  801728:	74 f4                	je     80171e <strcmp+0x13>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  80172a:	0f b6 c0             	movzbl %al,%eax
  80172d:	0f b6 12             	movzbl (%edx),%edx
  801730:	29 d0                	sub    %edx,%eax
}
  801732:	c9                   	leave  
  801733:	c3                   	ret    

00801734 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  801734:	55                   	push   %ebp
  801735:	89 e5                	mov    %esp,%ebp
  801737:	53                   	push   %ebx
  801738:	8b 55 08             	mov    0x8(%ebp),%edx
  80173b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80173e:	8b 45 10             	mov    0x10(%ebp),%eax
	while (n > 0 && *p && *p == *q)
  801741:	85 c0                	test   %eax,%eax
  801743:	74 1b                	je     801760 <strncmp+0x2c>
  801745:	8a 1a                	mov    (%edx),%bl
  801747:	84 db                	test   %bl,%bl
  801749:	74 24                	je     80176f <strncmp+0x3b>
  80174b:	3a 19                	cmp    (%ecx),%bl
  80174d:	75 20                	jne    80176f <strncmp+0x3b>
  80174f:	48                   	dec    %eax
  801750:	74 15                	je     801767 <strncmp+0x33>
		n--, p++, q++;
  801752:	42                   	inc    %edx
  801753:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  801754:	8a 1a                	mov    (%edx),%bl
  801756:	84 db                	test   %bl,%bl
  801758:	74 15                	je     80176f <strncmp+0x3b>
  80175a:	3a 19                	cmp    (%ecx),%bl
  80175c:	74 f1                	je     80174f <strncmp+0x1b>
  80175e:	eb 0f                	jmp    80176f <strncmp+0x3b>
		n--, p++, q++;
	if (n == 0)
		return 0;
  801760:	b8 00 00 00 00       	mov    $0x0,%eax
  801765:	eb 05                	jmp    80176c <strncmp+0x38>
  801767:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  80176c:	5b                   	pop    %ebx
  80176d:	c9                   	leave  
  80176e:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80176f:	0f b6 02             	movzbl (%edx),%eax
  801772:	0f b6 11             	movzbl (%ecx),%edx
  801775:	29 d0                	sub    %edx,%eax
  801777:	eb f3                	jmp    80176c <strncmp+0x38>

00801779 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  801779:	55                   	push   %ebp
  80177a:	89 e5                	mov    %esp,%ebp
  80177c:	8b 45 08             	mov    0x8(%ebp),%eax
  80177f:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  801782:	8a 10                	mov    (%eax),%dl
  801784:	84 d2                	test   %dl,%dl
  801786:	74 18                	je     8017a0 <strchr+0x27>
		if (*s == c)
  801788:	38 ca                	cmp    %cl,%dl
  80178a:	75 06                	jne    801792 <strchr+0x19>
  80178c:	eb 17                	jmp    8017a5 <strchr+0x2c>
  80178e:	38 ca                	cmp    %cl,%dl
  801790:	74 13                	je     8017a5 <strchr+0x2c>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  801792:	40                   	inc    %eax
  801793:	8a 10                	mov    (%eax),%dl
  801795:	84 d2                	test   %dl,%dl
  801797:	75 f5                	jne    80178e <strchr+0x15>
		if (*s == c)
			return (char *) s;
	return 0;
  801799:	b8 00 00 00 00       	mov    $0x0,%eax
  80179e:	eb 05                	jmp    8017a5 <strchr+0x2c>
  8017a0:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8017a5:	c9                   	leave  
  8017a6:	c3                   	ret    

008017a7 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8017a7:	55                   	push   %ebp
  8017a8:	89 e5                	mov    %esp,%ebp
  8017aa:	8b 45 08             	mov    0x8(%ebp),%eax
  8017ad:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  8017b0:	8a 10                	mov    (%eax),%dl
  8017b2:	84 d2                	test   %dl,%dl
  8017b4:	74 11                	je     8017c7 <strfind+0x20>
		if (*s == c)
  8017b6:	38 ca                	cmp    %cl,%dl
  8017b8:	75 06                	jne    8017c0 <strfind+0x19>
  8017ba:	eb 0b                	jmp    8017c7 <strfind+0x20>
  8017bc:	38 ca                	cmp    %cl,%dl
  8017be:	74 07                	je     8017c7 <strfind+0x20>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  8017c0:	40                   	inc    %eax
  8017c1:	8a 10                	mov    (%eax),%dl
  8017c3:	84 d2                	test   %dl,%dl
  8017c5:	75 f5                	jne    8017bc <strfind+0x15>
		if (*s == c)
			break;
	return (char *) s;
}
  8017c7:	c9                   	leave  
  8017c8:	c3                   	ret    

008017c9 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8017c9:	55                   	push   %ebp
  8017ca:	89 e5                	mov    %esp,%ebp
  8017cc:	57                   	push   %edi
  8017cd:	56                   	push   %esi
  8017ce:	53                   	push   %ebx
  8017cf:	8b 7d 08             	mov    0x8(%ebp),%edi
  8017d2:	8b 45 0c             	mov    0xc(%ebp),%eax
  8017d5:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8017d8:	85 c9                	test   %ecx,%ecx
  8017da:	74 30                	je     80180c <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8017dc:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8017e2:	75 25                	jne    801809 <memset+0x40>
  8017e4:	f6 c1 03             	test   $0x3,%cl
  8017e7:	75 20                	jne    801809 <memset+0x40>
		c &= 0xFF;
  8017e9:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8017ec:	89 d3                	mov    %edx,%ebx
  8017ee:	c1 e3 08             	shl    $0x8,%ebx
  8017f1:	89 d6                	mov    %edx,%esi
  8017f3:	c1 e6 18             	shl    $0x18,%esi
  8017f6:	89 d0                	mov    %edx,%eax
  8017f8:	c1 e0 10             	shl    $0x10,%eax
  8017fb:	09 f0                	or     %esi,%eax
  8017fd:	09 d0                	or     %edx,%eax
  8017ff:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  801801:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  801804:	fc                   	cld    
  801805:	f3 ab                	rep stos %eax,%es:(%edi)
  801807:	eb 03                	jmp    80180c <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  801809:	fc                   	cld    
  80180a:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  80180c:	89 f8                	mov    %edi,%eax
  80180e:	5b                   	pop    %ebx
  80180f:	5e                   	pop    %esi
  801810:	5f                   	pop    %edi
  801811:	c9                   	leave  
  801812:	c3                   	ret    

00801813 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  801813:	55                   	push   %ebp
  801814:	89 e5                	mov    %esp,%ebp
  801816:	57                   	push   %edi
  801817:	56                   	push   %esi
  801818:	8b 45 08             	mov    0x8(%ebp),%eax
  80181b:	8b 75 0c             	mov    0xc(%ebp),%esi
  80181e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  801821:	39 c6                	cmp    %eax,%esi
  801823:	73 34                	jae    801859 <memmove+0x46>
  801825:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  801828:	39 d0                	cmp    %edx,%eax
  80182a:	73 2d                	jae    801859 <memmove+0x46>
		s += n;
		d += n;
  80182c:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80182f:	f6 c2 03             	test   $0x3,%dl
  801832:	75 1b                	jne    80184f <memmove+0x3c>
  801834:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80183a:	75 13                	jne    80184f <memmove+0x3c>
  80183c:	f6 c1 03             	test   $0x3,%cl
  80183f:	75 0e                	jne    80184f <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  801841:	83 ef 04             	sub    $0x4,%edi
  801844:	8d 72 fc             	lea    -0x4(%edx),%esi
  801847:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  80184a:	fd                   	std    
  80184b:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80184d:	eb 07                	jmp    801856 <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  80184f:	4f                   	dec    %edi
  801850:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  801853:	fd                   	std    
  801854:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  801856:	fc                   	cld    
  801857:	eb 20                	jmp    801879 <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801859:	f7 c6 03 00 00 00    	test   $0x3,%esi
  80185f:	75 13                	jne    801874 <memmove+0x61>
  801861:	a8 03                	test   $0x3,%al
  801863:	75 0f                	jne    801874 <memmove+0x61>
  801865:	f6 c1 03             	test   $0x3,%cl
  801868:	75 0a                	jne    801874 <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  80186a:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  80186d:	89 c7                	mov    %eax,%edi
  80186f:	fc                   	cld    
  801870:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801872:	eb 05                	jmp    801879 <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  801874:	89 c7                	mov    %eax,%edi
  801876:	fc                   	cld    
  801877:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  801879:	5e                   	pop    %esi
  80187a:	5f                   	pop    %edi
  80187b:	c9                   	leave  
  80187c:	c3                   	ret    

0080187d <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  80187d:	55                   	push   %ebp
  80187e:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  801880:	ff 75 10             	pushl  0x10(%ebp)
  801883:	ff 75 0c             	pushl  0xc(%ebp)
  801886:	ff 75 08             	pushl  0x8(%ebp)
  801889:	e8 85 ff ff ff       	call   801813 <memmove>
}
  80188e:	c9                   	leave  
  80188f:	c3                   	ret    

00801890 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  801890:	55                   	push   %ebp
  801891:	89 e5                	mov    %esp,%ebp
  801893:	57                   	push   %edi
  801894:	56                   	push   %esi
  801895:	53                   	push   %ebx
  801896:	8b 5d 08             	mov    0x8(%ebp),%ebx
  801899:	8b 75 0c             	mov    0xc(%ebp),%esi
  80189c:	8b 7d 10             	mov    0x10(%ebp),%edi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  80189f:	85 ff                	test   %edi,%edi
  8018a1:	74 32                	je     8018d5 <memcmp+0x45>
		if (*s1 != *s2)
  8018a3:	8a 03                	mov    (%ebx),%al
  8018a5:	8a 0e                	mov    (%esi),%cl
  8018a7:	38 c8                	cmp    %cl,%al
  8018a9:	74 19                	je     8018c4 <memcmp+0x34>
  8018ab:	eb 0d                	jmp    8018ba <memcmp+0x2a>
  8018ad:	8a 44 13 01          	mov    0x1(%ebx,%edx,1),%al
  8018b1:	8a 4c 16 01          	mov    0x1(%esi,%edx,1),%cl
  8018b5:	42                   	inc    %edx
  8018b6:	38 c8                	cmp    %cl,%al
  8018b8:	74 10                	je     8018ca <memcmp+0x3a>
			return (int) *s1 - (int) *s2;
  8018ba:	0f b6 c0             	movzbl %al,%eax
  8018bd:	0f b6 c9             	movzbl %cl,%ecx
  8018c0:	29 c8                	sub    %ecx,%eax
  8018c2:	eb 16                	jmp    8018da <memcmp+0x4a>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8018c4:	4f                   	dec    %edi
  8018c5:	ba 00 00 00 00       	mov    $0x0,%edx
  8018ca:	39 fa                	cmp    %edi,%edx
  8018cc:	75 df                	jne    8018ad <memcmp+0x1d>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  8018ce:	b8 00 00 00 00       	mov    $0x0,%eax
  8018d3:	eb 05                	jmp    8018da <memcmp+0x4a>
  8018d5:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8018da:	5b                   	pop    %ebx
  8018db:	5e                   	pop    %esi
  8018dc:	5f                   	pop    %edi
  8018dd:	c9                   	leave  
  8018de:	c3                   	ret    

008018df <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8018df:	55                   	push   %ebp
  8018e0:	89 e5                	mov    %esp,%ebp
  8018e2:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  8018e5:	89 c2                	mov    %eax,%edx
  8018e7:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  8018ea:	39 d0                	cmp    %edx,%eax
  8018ec:	73 12                	jae    801900 <memfind+0x21>
		if (*(const unsigned char *) s == (unsigned char) c)
  8018ee:	8a 4d 0c             	mov    0xc(%ebp),%cl
  8018f1:	38 08                	cmp    %cl,(%eax)
  8018f3:	75 06                	jne    8018fb <memfind+0x1c>
  8018f5:	eb 09                	jmp    801900 <memfind+0x21>
  8018f7:	38 08                	cmp    %cl,(%eax)
  8018f9:	74 05                	je     801900 <memfind+0x21>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8018fb:	40                   	inc    %eax
  8018fc:	39 c2                	cmp    %eax,%edx
  8018fe:	77 f7                	ja     8018f7 <memfind+0x18>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  801900:	c9                   	leave  
  801901:	c3                   	ret    

00801902 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  801902:	55                   	push   %ebp
  801903:	89 e5                	mov    %esp,%ebp
  801905:	57                   	push   %edi
  801906:	56                   	push   %esi
  801907:	53                   	push   %ebx
  801908:	8b 55 08             	mov    0x8(%ebp),%edx
  80190b:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  80190e:	eb 01                	jmp    801911 <strtol+0xf>
		s++;
  801910:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801911:	8a 02                	mov    (%edx),%al
  801913:	3c 20                	cmp    $0x20,%al
  801915:	74 f9                	je     801910 <strtol+0xe>
  801917:	3c 09                	cmp    $0x9,%al
  801919:	74 f5                	je     801910 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  80191b:	3c 2b                	cmp    $0x2b,%al
  80191d:	75 08                	jne    801927 <strtol+0x25>
		s++;
  80191f:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  801920:	bf 00 00 00 00       	mov    $0x0,%edi
  801925:	eb 13                	jmp    80193a <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  801927:	3c 2d                	cmp    $0x2d,%al
  801929:	75 0a                	jne    801935 <strtol+0x33>
		s++, neg = 1;
  80192b:	8d 52 01             	lea    0x1(%edx),%edx
  80192e:	bf 01 00 00 00       	mov    $0x1,%edi
  801933:	eb 05                	jmp    80193a <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  801935:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  80193a:	85 db                	test   %ebx,%ebx
  80193c:	74 05                	je     801943 <strtol+0x41>
  80193e:	83 fb 10             	cmp    $0x10,%ebx
  801941:	75 28                	jne    80196b <strtol+0x69>
  801943:	8a 02                	mov    (%edx),%al
  801945:	3c 30                	cmp    $0x30,%al
  801947:	75 10                	jne    801959 <strtol+0x57>
  801949:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  80194d:	75 0a                	jne    801959 <strtol+0x57>
		s += 2, base = 16;
  80194f:	83 c2 02             	add    $0x2,%edx
  801952:	bb 10 00 00 00       	mov    $0x10,%ebx
  801957:	eb 12                	jmp    80196b <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  801959:	85 db                	test   %ebx,%ebx
  80195b:	75 0e                	jne    80196b <strtol+0x69>
  80195d:	3c 30                	cmp    $0x30,%al
  80195f:	75 05                	jne    801966 <strtol+0x64>
		s++, base = 8;
  801961:	42                   	inc    %edx
  801962:	b3 08                	mov    $0x8,%bl
  801964:	eb 05                	jmp    80196b <strtol+0x69>
	else if (base == 0)
		base = 10;
  801966:	bb 0a 00 00 00       	mov    $0xa,%ebx
  80196b:	b8 00 00 00 00       	mov    $0x0,%eax
  801970:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  801972:	8a 0a                	mov    (%edx),%cl
  801974:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  801977:	80 fb 09             	cmp    $0x9,%bl
  80197a:	77 08                	ja     801984 <strtol+0x82>
			dig = *s - '0';
  80197c:	0f be c9             	movsbl %cl,%ecx
  80197f:	83 e9 30             	sub    $0x30,%ecx
  801982:	eb 1e                	jmp    8019a2 <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  801984:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  801987:	80 fb 19             	cmp    $0x19,%bl
  80198a:	77 08                	ja     801994 <strtol+0x92>
			dig = *s - 'a' + 10;
  80198c:	0f be c9             	movsbl %cl,%ecx
  80198f:	83 e9 57             	sub    $0x57,%ecx
  801992:	eb 0e                	jmp    8019a2 <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  801994:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  801997:	80 fb 19             	cmp    $0x19,%bl
  80199a:	77 13                	ja     8019af <strtol+0xad>
			dig = *s - 'A' + 10;
  80199c:	0f be c9             	movsbl %cl,%ecx
  80199f:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  8019a2:	39 f1                	cmp    %esi,%ecx
  8019a4:	7d 0d                	jge    8019b3 <strtol+0xb1>
			break;
		s++, val = (val * base) + dig;
  8019a6:	42                   	inc    %edx
  8019a7:	0f af c6             	imul   %esi,%eax
  8019aa:	8d 04 01             	lea    (%ecx,%eax,1),%eax
		// we don't properly detect overflow!
	}
  8019ad:	eb c3                	jmp    801972 <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  8019af:	89 c1                	mov    %eax,%ecx
  8019b1:	eb 02                	jmp    8019b5 <strtol+0xb3>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  8019b3:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  8019b5:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8019b9:	74 05                	je     8019c0 <strtol+0xbe>
		*endptr = (char *) s;
  8019bb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8019be:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  8019c0:	85 ff                	test   %edi,%edi
  8019c2:	74 04                	je     8019c8 <strtol+0xc6>
  8019c4:	89 c8                	mov    %ecx,%eax
  8019c6:	f7 d8                	neg    %eax
}
  8019c8:	5b                   	pop    %ebx
  8019c9:	5e                   	pop    %esi
  8019ca:	5f                   	pop    %edi
  8019cb:	c9                   	leave  
  8019cc:	c3                   	ret    
  8019cd:	00 00                	add    %al,(%eax)
	...

008019d0 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8019d0:	55                   	push   %ebp
  8019d1:	89 e5                	mov    %esp,%ebp
  8019d3:	57                   	push   %edi
  8019d4:	56                   	push   %esi
  8019d5:	53                   	push   %ebx
  8019d6:	83 ec 0c             	sub    $0xc,%esp
  8019d9:	8b 7d 08             	mov    0x8(%ebp),%edi
  8019dc:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8019df:	8b 75 10             	mov    0x10(%ebp),%esi
	// LAB 4: Your code here.
	cprintf("0x%x 0x%x 0x%x\n", (uint32_t)from_env_store, (uint32_t)pg, (uint32_t)perm_store);
  8019e2:	56                   	push   %esi
  8019e3:	53                   	push   %ebx
  8019e4:	57                   	push   %edi
  8019e5:	68 20 22 80 00       	push   $0x802220
  8019ea:	e8 ad f6 ff ff       	call   80109c <cprintf>
	int r;
	if (pg != NULL) {
  8019ef:	83 c4 10             	add    $0x10,%esp
  8019f2:	85 db                	test   %ebx,%ebx
  8019f4:	74 28                	je     801a1e <ipc_recv+0x4e>
		cprintf("BEGIN\n");
  8019f6:	83 ec 0c             	sub    $0xc,%esp
  8019f9:	68 30 22 80 00       	push   $0x802230
  8019fe:	e8 99 f6 ff ff       	call   80109c <cprintf>
		r = sys_ipc_recv(pg);
  801a03:	89 1c 24             	mov    %ebx,(%esp)
  801a06:	e8 a0 e8 ff ff       	call   8002ab <sys_ipc_recv>
  801a0b:	89 c3                	mov    %eax,%ebx
		cprintf("OVER\n");
  801a0d:	c7 04 24 84 1e 80 00 	movl   $0x801e84,(%esp)
  801a14:	e8 83 f6 ff ff       	call   80109c <cprintf>
  801a19:	83 c4 10             	add    $0x10,%esp
  801a1c:	eb 12                	jmp    801a30 <ipc_recv+0x60>
	} else {
		r = sys_ipc_recv((void *)UTOP);
  801a1e:	83 ec 0c             	sub    $0xc,%esp
  801a21:	68 00 00 c0 ee       	push   $0xeec00000
  801a26:	e8 80 e8 ff ff       	call   8002ab <sys_ipc_recv>
  801a2b:	89 c3                	mov    %eax,%ebx
  801a2d:	83 c4 10             	add    $0x10,%esp
	}

	if (r == 0) {
  801a30:	85 db                	test   %ebx,%ebx
  801a32:	75 26                	jne    801a5a <ipc_recv+0x8a>
		if (from_env_store != NULL) *from_env_store = thisenv->env_ipc_from;
  801a34:	85 ff                	test   %edi,%edi
  801a36:	74 0a                	je     801a42 <ipc_recv+0x72>
  801a38:	a1 04 40 80 00       	mov    0x804004,%eax
  801a3d:	8b 40 74             	mov    0x74(%eax),%eax
  801a40:	89 07                	mov    %eax,(%edi)
		if (perm_store != NULL) *perm_store = thisenv->env_ipc_perm;
  801a42:	85 f6                	test   %esi,%esi
  801a44:	74 0a                	je     801a50 <ipc_recv+0x80>
  801a46:	a1 04 40 80 00       	mov    0x804004,%eax
  801a4b:	8b 40 78             	mov    0x78(%eax),%eax
  801a4e:	89 06                	mov    %eax,(%esi)
		return thisenv->env_ipc_value;
  801a50:	a1 04 40 80 00       	mov    0x804004,%eax
  801a55:	8b 58 70             	mov    0x70(%eax),%ebx
  801a58:	eb 14                	jmp    801a6e <ipc_recv+0x9e>
	} else {
		// fails;
		if (from_env_store != NULL) *from_env_store = 0;
  801a5a:	85 ff                	test   %edi,%edi
  801a5c:	74 06                	je     801a64 <ipc_recv+0x94>
  801a5e:	c7 07 00 00 00 00    	movl   $0x0,(%edi)
		if (perm_store != NULL) *perm_store = 0;
  801a64:	85 f6                	test   %esi,%esi
  801a66:	74 06                	je     801a6e <ipc_recv+0x9e>
  801a68:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		return r;
	}
}
  801a6e:	89 d8                	mov    %ebx,%eax
  801a70:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801a73:	5b                   	pop    %ebx
  801a74:	5e                   	pop    %esi
  801a75:	5f                   	pop    %edi
  801a76:	c9                   	leave  
  801a77:	c3                   	ret    

00801a78 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801a78:	55                   	push   %ebp
  801a79:	89 e5                	mov    %esp,%ebp
  801a7b:	57                   	push   %edi
  801a7c:	56                   	push   %esi
  801a7d:	53                   	push   %ebx
  801a7e:	83 ec 0c             	sub    $0xc,%esp
  801a81:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801a84:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801a87:	8b 75 14             	mov    0x14(%ebp),%esi
	// LAB 4: Your code here.
	// int sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
	int r;
	if (pg == NULL) pg = (void *)UTOP;
  801a8a:	85 db                	test   %ebx,%ebx
  801a8c:	75 25                	jne    801ab3 <ipc_send+0x3b>
  801a8e:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
  801a93:	eb 1e                	jmp    801ab3 <ipc_send+0x3b>
	
	while ((r = sys_ipc_try_send(to_env, val, pg, perm)) != 0) {
		if (r == -E_IPC_NOT_RECV) {
  801a95:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801a98:	75 07                	jne    801aa1 <ipc_send+0x29>
			// cprintf("Try Again and Again....\n");
			sys_yield();
  801a9a:	e8 ea e6 ff ff       	call   800189 <sys_yield>
  801a9f:	eb 12                	jmp    801ab3 <ipc_send+0x3b>
		} else {
			panic("ipc_send error %e\n", r);
  801aa1:	50                   	push   %eax
  801aa2:	68 37 22 80 00       	push   $0x802237
  801aa7:	6a 45                	push   $0x45
  801aa9:	68 4a 22 80 00       	push   $0x80224a
  801aae:	e8 11 f5 ff ff       	call   800fc4 <_panic>
	// LAB 4: Your code here.
	// int sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
	int r;
	if (pg == NULL) pg = (void *)UTOP;
	
	while ((r = sys_ipc_try_send(to_env, val, pg, perm)) != 0) {
  801ab3:	56                   	push   %esi
  801ab4:	53                   	push   %ebx
  801ab5:	57                   	push   %edi
  801ab6:	ff 75 08             	pushl  0x8(%ebp)
  801ab9:	e8 c8 e7 ff ff       	call   800286 <sys_ipc_try_send>
  801abe:	83 c4 10             	add    $0x10,%esp
  801ac1:	85 c0                	test   %eax,%eax
  801ac3:	75 d0                	jne    801a95 <ipc_send+0x1d>
		} else {
			panic("ipc_send error %e\n", r);
		}
	}
	return;
}
  801ac5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801ac8:	5b                   	pop    %ebx
  801ac9:	5e                   	pop    %esi
  801aca:	5f                   	pop    %edi
  801acb:	c9                   	leave  
  801acc:	c3                   	ret    

00801acd <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801acd:	55                   	push   %ebp
  801ace:	89 e5                	mov    %esp,%ebp
  801ad0:	53                   	push   %ebx
  801ad1:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	for (i = 0; i < NENV; i++)
		if (envs[i].env_type == type)
  801ad4:	39 1d 50 00 c0 ee    	cmp    %ebx,0xeec00050
  801ada:	74 22                	je     801afe <ipc_find_env+0x31>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801adc:	b8 01 00 00 00       	mov    $0x1,%eax
		if (envs[i].env_type == type)
  801ae1:	8d 0c 85 00 00 00 00 	lea    0x0(,%eax,4),%ecx
  801ae8:	89 c2                	mov    %eax,%edx
  801aea:	c1 e2 07             	shl    $0x7,%edx
  801aed:	29 ca                	sub    %ecx,%edx
  801aef:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801af5:	8b 52 50             	mov    0x50(%edx),%edx
  801af8:	39 da                	cmp    %ebx,%edx
  801afa:	75 1d                	jne    801b19 <ipc_find_env+0x4c>
  801afc:	eb 05                	jmp    801b03 <ipc_find_env+0x36>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801afe:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
			return envs[i].env_id;
  801b03:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  801b0a:	c1 e0 07             	shl    $0x7,%eax
  801b0d:	29 d0                	sub    %edx,%eax
  801b0f:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  801b14:	8b 40 40             	mov    0x40(%eax),%eax
  801b17:	eb 0c                	jmp    801b25 <ipc_find_env+0x58>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801b19:	40                   	inc    %eax
  801b1a:	3d 00 04 00 00       	cmp    $0x400,%eax
  801b1f:	75 c0                	jne    801ae1 <ipc_find_env+0x14>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801b21:	66 b8 00 00          	mov    $0x0,%ax
}
  801b25:	5b                   	pop    %ebx
  801b26:	c9                   	leave  
  801b27:	c3                   	ret    

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
