
obj/user/buggyhello.debug:     file format elf32-i386


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
  80002c:	e8 17 00 00 00       	call   800048 <libmain>
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
  800037:	83 ec 10             	sub    $0x10,%esp
	sys_cputs((char*)1, 1);
  80003a:	6a 01                	push   $0x1
  80003c:	6a 01                	push   $0x1
  80003e:	e8 ba 00 00 00       	call   8000fd <sys_cputs>
  800043:	83 c4 10             	add    $0x10,%esp
}
  800046:	c9                   	leave  
  800047:	c3                   	ret    

00800048 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800048:	55                   	push   %ebp
  800049:	89 e5                	mov    %esp,%ebp
  80004b:	56                   	push   %esi
  80004c:	53                   	push   %ebx
  80004d:	8b 75 08             	mov    0x8(%ebp),%esi
  800050:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = envs + ENVX(sys_getenvid());
  800053:	e8 11 01 00 00       	call   800169 <sys_getenvid>
  800058:	25 ff 03 00 00       	and    $0x3ff,%eax
  80005d:	89 c2                	mov    %eax,%edx
  80005f:	c1 e2 07             	shl    $0x7,%edx
  800062:	8d 84 82 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,4),%eax
  800069:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80006e:	85 f6                	test   %esi,%esi
  800070:	7e 07                	jle    800079 <libmain+0x31>
		binaryname = argv[0];
  800072:	8b 03                	mov    (%ebx),%eax
  800074:	a3 00 30 80 00       	mov    %eax,0x803000
	// call user main routine
	umain(argc, argv);
  800079:	83 ec 08             	sub    $0x8,%esp
  80007c:	53                   	push   %ebx
  80007d:	56                   	push   %esi
  80007e:	e8 b1 ff ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  800083:	e8 0c 00 00 00       	call   800094 <exit>
  800088:	83 c4 10             	add    $0x10,%esp
}
  80008b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80008e:	5b                   	pop    %ebx
  80008f:	5e                   	pop    %esi
  800090:	c9                   	leave  
  800091:	c3                   	ret    
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
  80009a:	e8 cb 04 00 00       	call   80056a <close_all>
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
  8000e2:	68 ea 1d 80 00       	push   $0x801dea
  8000e7:	6a 42                	push   $0x42
  8000e9:	68 07 1e 80 00       	push   $0x801e07
  8000ee:	e8 21 0f 00 00       	call   801014 <_panic>

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
} 
  800317:	c9                   	leave  
  800318:	c3                   	ret    

00800319 <sys_join>:

// thread:
int
sys_join(envid_t envid)
{
  800319:	55                   	push   %ebp
  80031a:	89 e5                	mov    %esp,%ebp
  80031c:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_join, 0, envid, 0, 0, 0, 0);
  80031f:	6a 00                	push   $0x0
  800321:	6a 00                	push   $0x0
  800323:	6a 00                	push   $0x0
  800325:	6a 00                	push   $0x0
  800327:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80032a:	ba 00 00 00 00       	mov    $0x0,%edx
  80032f:	b8 11 00 00 00       	mov    $0x11,%eax
  800334:	e8 77 fd ff ff       	call   8000b0 <syscall>
}
  800339:	c9                   	leave  
  80033a:	c3                   	ret    

0080033b <sys_getpid>:

envid_t
sys_getpid(void)
{
  80033b:	55                   	push   %ebp
  80033c:	89 e5                	mov    %esp,%ebp
  80033e:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_getpid, 0, 0, 0, 0, 0, 0);
  800341:	6a 00                	push   $0x0
  800343:	6a 00                	push   $0x0
  800345:	6a 00                	push   $0x0
  800347:	6a 00                	push   $0x0
  800349:	b9 00 00 00 00       	mov    $0x0,%ecx
  80034e:	ba 00 00 00 00       	mov    $0x0,%edx
  800353:	b8 10 00 00 00       	mov    $0x10,%eax
  800358:	e8 53 fd ff ff       	call   8000b0 <syscall>
  80035d:	c9                   	leave  
  80035e:	c3                   	ret    
	...

00800360 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800360:	55                   	push   %ebp
  800361:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800363:	8b 45 08             	mov    0x8(%ebp),%eax
  800366:	05 00 00 00 30       	add    $0x30000000,%eax
  80036b:	c1 e8 0c             	shr    $0xc,%eax
}
  80036e:	c9                   	leave  
  80036f:	c3                   	ret    

00800370 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800370:	55                   	push   %ebp
  800371:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  800373:	ff 75 08             	pushl  0x8(%ebp)
  800376:	e8 e5 ff ff ff       	call   800360 <fd2num>
  80037b:	83 c4 04             	add    $0x4,%esp
  80037e:	05 20 00 0d 00       	add    $0xd0020,%eax
  800383:	c1 e0 0c             	shl    $0xc,%eax
}
  800386:	c9                   	leave  
  800387:	c3                   	ret    

00800388 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800388:	55                   	push   %ebp
  800389:	89 e5                	mov    %esp,%ebp
  80038b:	53                   	push   %ebx
  80038c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  80038f:	a1 00 dd 7b ef       	mov    0xef7bdd00,%eax
  800394:	a8 01                	test   $0x1,%al
  800396:	74 34                	je     8003cc <fd_alloc+0x44>
  800398:	a1 00 00 74 ef       	mov    0xef740000,%eax
  80039d:	a8 01                	test   $0x1,%al
  80039f:	74 32                	je     8003d3 <fd_alloc+0x4b>
  8003a1:	b8 00 10 00 d0       	mov    $0xd0001000,%eax
  8003a6:	89 c1                	mov    %eax,%ecx
  8003a8:	89 c2                	mov    %eax,%edx
  8003aa:	c1 ea 16             	shr    $0x16,%edx
  8003ad:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8003b4:	f6 c2 01             	test   $0x1,%dl
  8003b7:	74 1f                	je     8003d8 <fd_alloc+0x50>
  8003b9:	89 c2                	mov    %eax,%edx
  8003bb:	c1 ea 0c             	shr    $0xc,%edx
  8003be:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8003c5:	f6 c2 01             	test   $0x1,%dl
  8003c8:	75 17                	jne    8003e1 <fd_alloc+0x59>
  8003ca:	eb 0c                	jmp    8003d8 <fd_alloc+0x50>
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  8003cc:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
  8003d1:	eb 05                	jmp    8003d8 <fd_alloc+0x50>
  8003d3:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
  8003d8:	89 0b                	mov    %ecx,(%ebx)
			return 0;
  8003da:	b8 00 00 00 00       	mov    $0x0,%eax
  8003df:	eb 17                	jmp    8003f8 <fd_alloc+0x70>
  8003e1:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8003e6:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8003eb:	75 b9                	jne    8003a6 <fd_alloc+0x1e>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8003ed:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_MAX_OPEN;
  8003f3:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8003f8:	5b                   	pop    %ebx
  8003f9:	c9                   	leave  
  8003fa:	c3                   	ret    

008003fb <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8003fb:	55                   	push   %ebp
  8003fc:	89 e5                	mov    %esp,%ebp
  8003fe:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800401:	83 f8 1f             	cmp    $0x1f,%eax
  800404:	77 36                	ja     80043c <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800406:	05 00 00 0d 00       	add    $0xd0000,%eax
  80040b:	c1 e0 0c             	shl    $0xc,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  80040e:	89 c2                	mov    %eax,%edx
  800410:	c1 ea 16             	shr    $0x16,%edx
  800413:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80041a:	f6 c2 01             	test   $0x1,%dl
  80041d:	74 24                	je     800443 <fd_lookup+0x48>
  80041f:	89 c2                	mov    %eax,%edx
  800421:	c1 ea 0c             	shr    $0xc,%edx
  800424:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80042b:	f6 c2 01             	test   $0x1,%dl
  80042e:	74 1a                	je     80044a <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800430:	8b 55 0c             	mov    0xc(%ebp),%edx
  800433:	89 02                	mov    %eax,(%edx)
	return 0;
  800435:	b8 00 00 00 00       	mov    $0x0,%eax
  80043a:	eb 13                	jmp    80044f <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80043c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800441:	eb 0c                	jmp    80044f <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800443:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800448:	eb 05                	jmp    80044f <fd_lookup+0x54>
  80044a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  80044f:	c9                   	leave  
  800450:	c3                   	ret    

00800451 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800451:	55                   	push   %ebp
  800452:	89 e5                	mov    %esp,%ebp
  800454:	53                   	push   %ebx
  800455:	83 ec 04             	sub    $0x4,%esp
  800458:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80045b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
		if (devtab[i]->dev_id == dev_id) {
  80045e:	39 0d 04 30 80 00    	cmp    %ecx,0x803004
  800464:	74 0d                	je     800473 <dev_lookup+0x22>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800466:	b8 00 00 00 00       	mov    $0x0,%eax
  80046b:	eb 14                	jmp    800481 <dev_lookup+0x30>
		if (devtab[i]->dev_id == dev_id) {
  80046d:	39 0a                	cmp    %ecx,(%edx)
  80046f:	75 10                	jne    800481 <dev_lookup+0x30>
  800471:	eb 05                	jmp    800478 <dev_lookup+0x27>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800473:	ba 04 30 80 00       	mov    $0x803004,%edx
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
  800478:	89 13                	mov    %edx,(%ebx)
			return 0;
  80047a:	b8 00 00 00 00       	mov    $0x0,%eax
  80047f:	eb 31                	jmp    8004b2 <dev_lookup+0x61>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800481:	40                   	inc    %eax
  800482:	8b 14 85 94 1e 80 00 	mov    0x801e94(,%eax,4),%edx
  800489:	85 d2                	test   %edx,%edx
  80048b:	75 e0                	jne    80046d <dev_lookup+0x1c>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  80048d:	a1 04 40 80 00       	mov    0x804004,%eax
  800492:	8b 40 48             	mov    0x48(%eax),%eax
  800495:	83 ec 04             	sub    $0x4,%esp
  800498:	51                   	push   %ecx
  800499:	50                   	push   %eax
  80049a:	68 18 1e 80 00       	push   $0x801e18
  80049f:	e8 48 0c 00 00       	call   8010ec <cprintf>
	*dev = 0;
  8004a4:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_INVAL;
  8004aa:	83 c4 10             	add    $0x10,%esp
  8004ad:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8004b2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8004b5:	c9                   	leave  
  8004b6:	c3                   	ret    

008004b7 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8004b7:	55                   	push   %ebp
  8004b8:	89 e5                	mov    %esp,%ebp
  8004ba:	56                   	push   %esi
  8004bb:	53                   	push   %ebx
  8004bc:	83 ec 20             	sub    $0x20,%esp
  8004bf:	8b 75 08             	mov    0x8(%ebp),%esi
  8004c2:	8a 45 0c             	mov    0xc(%ebp),%al
  8004c5:	88 45 e7             	mov    %al,-0x19(%ebp)
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8004c8:	56                   	push   %esi
  8004c9:	e8 92 fe ff ff       	call   800360 <fd2num>
  8004ce:	8d 55 f4             	lea    -0xc(%ebp),%edx
  8004d1:	89 14 24             	mov    %edx,(%esp)
  8004d4:	50                   	push   %eax
  8004d5:	e8 21 ff ff ff       	call   8003fb <fd_lookup>
  8004da:	89 c3                	mov    %eax,%ebx
  8004dc:	83 c4 08             	add    $0x8,%esp
  8004df:	85 c0                	test   %eax,%eax
  8004e1:	78 05                	js     8004e8 <fd_close+0x31>
	    || fd != fd2)
  8004e3:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8004e6:	74 0d                	je     8004f5 <fd_close+0x3e>
		return (must_exist ? r : 0);
  8004e8:	80 7d e7 00          	cmpb   $0x0,-0x19(%ebp)
  8004ec:	75 48                	jne    800536 <fd_close+0x7f>
  8004ee:	bb 00 00 00 00       	mov    $0x0,%ebx
  8004f3:	eb 41                	jmp    800536 <fd_close+0x7f>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8004f5:	83 ec 08             	sub    $0x8,%esp
  8004f8:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8004fb:	50                   	push   %eax
  8004fc:	ff 36                	pushl  (%esi)
  8004fe:	e8 4e ff ff ff       	call   800451 <dev_lookup>
  800503:	89 c3                	mov    %eax,%ebx
  800505:	83 c4 10             	add    $0x10,%esp
  800508:	85 c0                	test   %eax,%eax
  80050a:	78 1c                	js     800528 <fd_close+0x71>
		if (dev->dev_close)
  80050c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80050f:	8b 40 10             	mov    0x10(%eax),%eax
  800512:	85 c0                	test   %eax,%eax
  800514:	74 0d                	je     800523 <fd_close+0x6c>
			r = (*dev->dev_close)(fd);
  800516:	83 ec 0c             	sub    $0xc,%esp
  800519:	56                   	push   %esi
  80051a:	ff d0                	call   *%eax
  80051c:	89 c3                	mov    %eax,%ebx
  80051e:	83 c4 10             	add    $0x10,%esp
  800521:	eb 05                	jmp    800528 <fd_close+0x71>
		else
			r = 0;
  800523:	bb 00 00 00 00       	mov    $0x0,%ebx
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  800528:	83 ec 08             	sub    $0x8,%esp
  80052b:	56                   	push   %esi
  80052c:	6a 00                	push   $0x0
  80052e:	e8 cb fc ff ff       	call   8001fe <sys_page_unmap>
	return r;
  800533:	83 c4 10             	add    $0x10,%esp
}
  800536:	89 d8                	mov    %ebx,%eax
  800538:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80053b:	5b                   	pop    %ebx
  80053c:	5e                   	pop    %esi
  80053d:	c9                   	leave  
  80053e:	c3                   	ret    

0080053f <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  80053f:	55                   	push   %ebp
  800540:	89 e5                	mov    %esp,%ebp
  800542:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800545:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800548:	50                   	push   %eax
  800549:	ff 75 08             	pushl  0x8(%ebp)
  80054c:	e8 aa fe ff ff       	call   8003fb <fd_lookup>
  800551:	83 c4 08             	add    $0x8,%esp
  800554:	85 c0                	test   %eax,%eax
  800556:	78 10                	js     800568 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  800558:	83 ec 08             	sub    $0x8,%esp
  80055b:	6a 01                	push   $0x1
  80055d:	ff 75 f4             	pushl  -0xc(%ebp)
  800560:	e8 52 ff ff ff       	call   8004b7 <fd_close>
  800565:	83 c4 10             	add    $0x10,%esp
}
  800568:	c9                   	leave  
  800569:	c3                   	ret    

0080056a <close_all>:

void
close_all(void)
{
  80056a:	55                   	push   %ebp
  80056b:	89 e5                	mov    %esp,%ebp
  80056d:	53                   	push   %ebx
  80056e:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800571:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  800576:	83 ec 0c             	sub    $0xc,%esp
  800579:	53                   	push   %ebx
  80057a:	e8 c0 ff ff ff       	call   80053f <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  80057f:	43                   	inc    %ebx
  800580:	83 c4 10             	add    $0x10,%esp
  800583:	83 fb 20             	cmp    $0x20,%ebx
  800586:	75 ee                	jne    800576 <close_all+0xc>
		close(i);
}
  800588:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80058b:	c9                   	leave  
  80058c:	c3                   	ret    

0080058d <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  80058d:	55                   	push   %ebp
  80058e:	89 e5                	mov    %esp,%ebp
  800590:	57                   	push   %edi
  800591:	56                   	push   %esi
  800592:	53                   	push   %ebx
  800593:	83 ec 2c             	sub    $0x2c,%esp
  800596:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  800599:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80059c:	50                   	push   %eax
  80059d:	ff 75 08             	pushl  0x8(%ebp)
  8005a0:	e8 56 fe ff ff       	call   8003fb <fd_lookup>
  8005a5:	89 c3                	mov    %eax,%ebx
  8005a7:	83 c4 08             	add    $0x8,%esp
  8005aa:	85 c0                	test   %eax,%eax
  8005ac:	0f 88 c0 00 00 00    	js     800672 <dup+0xe5>
		return r;
	close(newfdnum);
  8005b2:	83 ec 0c             	sub    $0xc,%esp
  8005b5:	57                   	push   %edi
  8005b6:	e8 84 ff ff ff       	call   80053f <close>

	newfd = INDEX2FD(newfdnum);
  8005bb:	8d b7 00 00 0d 00    	lea    0xd0000(%edi),%esi
  8005c1:	c1 e6 0c             	shl    $0xc,%esi
	ova = fd2data(oldfd);
  8005c4:	83 c4 04             	add    $0x4,%esp
  8005c7:	ff 75 e4             	pushl  -0x1c(%ebp)
  8005ca:	e8 a1 fd ff ff       	call   800370 <fd2data>
  8005cf:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  8005d1:	89 34 24             	mov    %esi,(%esp)
  8005d4:	e8 97 fd ff ff       	call   800370 <fd2data>
  8005d9:	83 c4 10             	add    $0x10,%esp
  8005dc:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8005df:	89 d8                	mov    %ebx,%eax
  8005e1:	c1 e8 16             	shr    $0x16,%eax
  8005e4:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8005eb:	a8 01                	test   $0x1,%al
  8005ed:	74 37                	je     800626 <dup+0x99>
  8005ef:	89 d8                	mov    %ebx,%eax
  8005f1:	c1 e8 0c             	shr    $0xc,%eax
  8005f4:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8005fb:	f6 c2 01             	test   $0x1,%dl
  8005fe:	74 26                	je     800626 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  800600:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800607:	83 ec 0c             	sub    $0xc,%esp
  80060a:	25 07 0e 00 00       	and    $0xe07,%eax
  80060f:	50                   	push   %eax
  800610:	ff 75 d4             	pushl  -0x2c(%ebp)
  800613:	6a 00                	push   $0x0
  800615:	53                   	push   %ebx
  800616:	6a 00                	push   $0x0
  800618:	e8 bb fb ff ff       	call   8001d8 <sys_page_map>
  80061d:	89 c3                	mov    %eax,%ebx
  80061f:	83 c4 20             	add    $0x20,%esp
  800622:	85 c0                	test   %eax,%eax
  800624:	78 2d                	js     800653 <dup+0xc6>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  800626:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800629:	89 c2                	mov    %eax,%edx
  80062b:	c1 ea 0c             	shr    $0xc,%edx
  80062e:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800635:	83 ec 0c             	sub    $0xc,%esp
  800638:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  80063e:	52                   	push   %edx
  80063f:	56                   	push   %esi
  800640:	6a 00                	push   $0x0
  800642:	50                   	push   %eax
  800643:	6a 00                	push   $0x0
  800645:	e8 8e fb ff ff       	call   8001d8 <sys_page_map>
  80064a:	89 c3                	mov    %eax,%ebx
  80064c:	83 c4 20             	add    $0x20,%esp
  80064f:	85 c0                	test   %eax,%eax
  800651:	79 1d                	jns    800670 <dup+0xe3>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  800653:	83 ec 08             	sub    $0x8,%esp
  800656:	56                   	push   %esi
  800657:	6a 00                	push   $0x0
  800659:	e8 a0 fb ff ff       	call   8001fe <sys_page_unmap>
	sys_page_unmap(0, nva);
  80065e:	83 c4 08             	add    $0x8,%esp
  800661:	ff 75 d4             	pushl  -0x2c(%ebp)
  800664:	6a 00                	push   $0x0
  800666:	e8 93 fb ff ff       	call   8001fe <sys_page_unmap>
	return r;
  80066b:	83 c4 10             	add    $0x10,%esp
  80066e:	eb 02                	jmp    800672 <dup+0xe5>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
		goto err;

	return newfdnum;
  800670:	89 fb                	mov    %edi,%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  800672:	89 d8                	mov    %ebx,%eax
  800674:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800677:	5b                   	pop    %ebx
  800678:	5e                   	pop    %esi
  800679:	5f                   	pop    %edi
  80067a:	c9                   	leave  
  80067b:	c3                   	ret    

0080067c <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80067c:	55                   	push   %ebp
  80067d:	89 e5                	mov    %esp,%ebp
  80067f:	53                   	push   %ebx
  800680:	83 ec 14             	sub    $0x14,%esp
  800683:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800686:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800689:	50                   	push   %eax
  80068a:	53                   	push   %ebx
  80068b:	e8 6b fd ff ff       	call   8003fb <fd_lookup>
  800690:	83 c4 08             	add    $0x8,%esp
  800693:	85 c0                	test   %eax,%eax
  800695:	78 67                	js     8006fe <read+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800697:	83 ec 08             	sub    $0x8,%esp
  80069a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80069d:	50                   	push   %eax
  80069e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8006a1:	ff 30                	pushl  (%eax)
  8006a3:	e8 a9 fd ff ff       	call   800451 <dev_lookup>
  8006a8:	83 c4 10             	add    $0x10,%esp
  8006ab:	85 c0                	test   %eax,%eax
  8006ad:	78 4f                	js     8006fe <read+0x82>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8006af:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8006b2:	8b 50 08             	mov    0x8(%eax),%edx
  8006b5:	83 e2 03             	and    $0x3,%edx
  8006b8:	83 fa 01             	cmp    $0x1,%edx
  8006bb:	75 21                	jne    8006de <read+0x62>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8006bd:	a1 04 40 80 00       	mov    0x804004,%eax
  8006c2:	8b 40 48             	mov    0x48(%eax),%eax
  8006c5:	83 ec 04             	sub    $0x4,%esp
  8006c8:	53                   	push   %ebx
  8006c9:	50                   	push   %eax
  8006ca:	68 59 1e 80 00       	push   $0x801e59
  8006cf:	e8 18 0a 00 00       	call   8010ec <cprintf>
		return -E_INVAL;
  8006d4:	83 c4 10             	add    $0x10,%esp
  8006d7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8006dc:	eb 20                	jmp    8006fe <read+0x82>
	}
	if (!dev->dev_read)
  8006de:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8006e1:	8b 52 08             	mov    0x8(%edx),%edx
  8006e4:	85 d2                	test   %edx,%edx
  8006e6:	74 11                	je     8006f9 <read+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8006e8:	83 ec 04             	sub    $0x4,%esp
  8006eb:	ff 75 10             	pushl  0x10(%ebp)
  8006ee:	ff 75 0c             	pushl  0xc(%ebp)
  8006f1:	50                   	push   %eax
  8006f2:	ff d2                	call   *%edx
  8006f4:	83 c4 10             	add    $0x10,%esp
  8006f7:	eb 05                	jmp    8006fe <read+0x82>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8006f9:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_read)(fd, buf, n);
}
  8006fe:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800701:	c9                   	leave  
  800702:	c3                   	ret    

00800703 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  800703:	55                   	push   %ebp
  800704:	89 e5                	mov    %esp,%ebp
  800706:	57                   	push   %edi
  800707:	56                   	push   %esi
  800708:	53                   	push   %ebx
  800709:	83 ec 0c             	sub    $0xc,%esp
  80070c:	8b 7d 08             	mov    0x8(%ebp),%edi
  80070f:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  800712:	85 f6                	test   %esi,%esi
  800714:	74 31                	je     800747 <readn+0x44>
  800716:	b8 00 00 00 00       	mov    $0x0,%eax
  80071b:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = read(fdnum, (char*)buf + tot, n - tot);
  800720:	83 ec 04             	sub    $0x4,%esp
  800723:	89 f2                	mov    %esi,%edx
  800725:	29 c2                	sub    %eax,%edx
  800727:	52                   	push   %edx
  800728:	03 45 0c             	add    0xc(%ebp),%eax
  80072b:	50                   	push   %eax
  80072c:	57                   	push   %edi
  80072d:	e8 4a ff ff ff       	call   80067c <read>
		if (m < 0)
  800732:	83 c4 10             	add    $0x10,%esp
  800735:	85 c0                	test   %eax,%eax
  800737:	78 17                	js     800750 <readn+0x4d>
			return m;
		if (m == 0)
  800739:	85 c0                	test   %eax,%eax
  80073b:	74 11                	je     80074e <readn+0x4b>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80073d:	01 c3                	add    %eax,%ebx
  80073f:	89 d8                	mov    %ebx,%eax
  800741:	39 f3                	cmp    %esi,%ebx
  800743:	72 db                	jb     800720 <readn+0x1d>
  800745:	eb 09                	jmp    800750 <readn+0x4d>
  800747:	b8 00 00 00 00       	mov    $0x0,%eax
  80074c:	eb 02                	jmp    800750 <readn+0x4d>
		m = read(fdnum, (char*)buf + tot, n - tot);
		if (m < 0)
			return m;
		if (m == 0)
  80074e:	89 d8                	mov    %ebx,%eax
			break;
	}
	return tot;
}
  800750:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800753:	5b                   	pop    %ebx
  800754:	5e                   	pop    %esi
  800755:	5f                   	pop    %edi
  800756:	c9                   	leave  
  800757:	c3                   	ret    

00800758 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  800758:	55                   	push   %ebp
  800759:	89 e5                	mov    %esp,%ebp
  80075b:	53                   	push   %ebx
  80075c:	83 ec 14             	sub    $0x14,%esp
  80075f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800762:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800765:	50                   	push   %eax
  800766:	53                   	push   %ebx
  800767:	e8 8f fc ff ff       	call   8003fb <fd_lookup>
  80076c:	83 c4 08             	add    $0x8,%esp
  80076f:	85 c0                	test   %eax,%eax
  800771:	78 62                	js     8007d5 <write+0x7d>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800773:	83 ec 08             	sub    $0x8,%esp
  800776:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800779:	50                   	push   %eax
  80077a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80077d:	ff 30                	pushl  (%eax)
  80077f:	e8 cd fc ff ff       	call   800451 <dev_lookup>
  800784:	83 c4 10             	add    $0x10,%esp
  800787:	85 c0                	test   %eax,%eax
  800789:	78 4a                	js     8007d5 <write+0x7d>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80078b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80078e:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  800792:	75 21                	jne    8007b5 <write+0x5d>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  800794:	a1 04 40 80 00       	mov    0x804004,%eax
  800799:	8b 40 48             	mov    0x48(%eax),%eax
  80079c:	83 ec 04             	sub    $0x4,%esp
  80079f:	53                   	push   %ebx
  8007a0:	50                   	push   %eax
  8007a1:	68 75 1e 80 00       	push   $0x801e75
  8007a6:	e8 41 09 00 00       	call   8010ec <cprintf>
		return -E_INVAL;
  8007ab:	83 c4 10             	add    $0x10,%esp
  8007ae:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8007b3:	eb 20                	jmp    8007d5 <write+0x7d>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8007b5:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8007b8:	8b 52 0c             	mov    0xc(%edx),%edx
  8007bb:	85 d2                	test   %edx,%edx
  8007bd:	74 11                	je     8007d0 <write+0x78>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8007bf:	83 ec 04             	sub    $0x4,%esp
  8007c2:	ff 75 10             	pushl  0x10(%ebp)
  8007c5:	ff 75 0c             	pushl  0xc(%ebp)
  8007c8:	50                   	push   %eax
  8007c9:	ff d2                	call   *%edx
  8007cb:	83 c4 10             	add    $0x10,%esp
  8007ce:	eb 05                	jmp    8007d5 <write+0x7d>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8007d0:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  8007d5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007d8:	c9                   	leave  
  8007d9:	c3                   	ret    

008007da <seek>:

int
seek(int fdnum, off_t offset)
{
  8007da:	55                   	push   %ebp
  8007db:	89 e5                	mov    %esp,%ebp
  8007dd:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8007e0:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8007e3:	50                   	push   %eax
  8007e4:	ff 75 08             	pushl  0x8(%ebp)
  8007e7:	e8 0f fc ff ff       	call   8003fb <fd_lookup>
  8007ec:	83 c4 08             	add    $0x8,%esp
  8007ef:	85 c0                	test   %eax,%eax
  8007f1:	78 0e                	js     800801 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8007f3:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8007f6:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007f9:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8007fc:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800801:	c9                   	leave  
  800802:	c3                   	ret    

00800803 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  800803:	55                   	push   %ebp
  800804:	89 e5                	mov    %esp,%ebp
  800806:	53                   	push   %ebx
  800807:	83 ec 14             	sub    $0x14,%esp
  80080a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80080d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800810:	50                   	push   %eax
  800811:	53                   	push   %ebx
  800812:	e8 e4 fb ff ff       	call   8003fb <fd_lookup>
  800817:	83 c4 08             	add    $0x8,%esp
  80081a:	85 c0                	test   %eax,%eax
  80081c:	78 5f                	js     80087d <ftruncate+0x7a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80081e:	83 ec 08             	sub    $0x8,%esp
  800821:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800824:	50                   	push   %eax
  800825:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800828:	ff 30                	pushl  (%eax)
  80082a:	e8 22 fc ff ff       	call   800451 <dev_lookup>
  80082f:	83 c4 10             	add    $0x10,%esp
  800832:	85 c0                	test   %eax,%eax
  800834:	78 47                	js     80087d <ftruncate+0x7a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800836:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800839:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80083d:	75 21                	jne    800860 <ftruncate+0x5d>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  80083f:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  800844:	8b 40 48             	mov    0x48(%eax),%eax
  800847:	83 ec 04             	sub    $0x4,%esp
  80084a:	53                   	push   %ebx
  80084b:	50                   	push   %eax
  80084c:	68 38 1e 80 00       	push   $0x801e38
  800851:	e8 96 08 00 00       	call   8010ec <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  800856:	83 c4 10             	add    $0x10,%esp
  800859:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80085e:	eb 1d                	jmp    80087d <ftruncate+0x7a>
	}
	if (!dev->dev_trunc)
  800860:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800863:	8b 52 18             	mov    0x18(%edx),%edx
  800866:	85 d2                	test   %edx,%edx
  800868:	74 0e                	je     800878 <ftruncate+0x75>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80086a:	83 ec 08             	sub    $0x8,%esp
  80086d:	ff 75 0c             	pushl  0xc(%ebp)
  800870:	50                   	push   %eax
  800871:	ff d2                	call   *%edx
  800873:	83 c4 10             	add    $0x10,%esp
  800876:	eb 05                	jmp    80087d <ftruncate+0x7a>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  800878:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  80087d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800880:	c9                   	leave  
  800881:	c3                   	ret    

00800882 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  800882:	55                   	push   %ebp
  800883:	89 e5                	mov    %esp,%ebp
  800885:	53                   	push   %ebx
  800886:	83 ec 14             	sub    $0x14,%esp
  800889:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80088c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80088f:	50                   	push   %eax
  800890:	ff 75 08             	pushl  0x8(%ebp)
  800893:	e8 63 fb ff ff       	call   8003fb <fd_lookup>
  800898:	83 c4 08             	add    $0x8,%esp
  80089b:	85 c0                	test   %eax,%eax
  80089d:	78 52                	js     8008f1 <fstat+0x6f>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80089f:	83 ec 08             	sub    $0x8,%esp
  8008a2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8008a5:	50                   	push   %eax
  8008a6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8008a9:	ff 30                	pushl  (%eax)
  8008ab:	e8 a1 fb ff ff       	call   800451 <dev_lookup>
  8008b0:	83 c4 10             	add    $0x10,%esp
  8008b3:	85 c0                	test   %eax,%eax
  8008b5:	78 3a                	js     8008f1 <fstat+0x6f>
		return r;
	if (!dev->dev_stat)
  8008b7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8008ba:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8008be:	74 2c                	je     8008ec <fstat+0x6a>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8008c0:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8008c3:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8008ca:	00 00 00 
	stat->st_isdir = 0;
  8008cd:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8008d4:	00 00 00 
	stat->st_dev = dev;
  8008d7:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8008dd:	83 ec 08             	sub    $0x8,%esp
  8008e0:	53                   	push   %ebx
  8008e1:	ff 75 f0             	pushl  -0x10(%ebp)
  8008e4:	ff 50 14             	call   *0x14(%eax)
  8008e7:	83 c4 10             	add    $0x10,%esp
  8008ea:	eb 05                	jmp    8008f1 <fstat+0x6f>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8008ec:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8008f1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8008f4:	c9                   	leave  
  8008f5:	c3                   	ret    

008008f6 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8008f6:	55                   	push   %ebp
  8008f7:	89 e5                	mov    %esp,%ebp
  8008f9:	56                   	push   %esi
  8008fa:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8008fb:	83 ec 08             	sub    $0x8,%esp
  8008fe:	6a 00                	push   $0x0
  800900:	ff 75 08             	pushl  0x8(%ebp)
  800903:	e8 78 01 00 00       	call   800a80 <open>
  800908:	89 c3                	mov    %eax,%ebx
  80090a:	83 c4 10             	add    $0x10,%esp
  80090d:	85 c0                	test   %eax,%eax
  80090f:	78 1b                	js     80092c <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  800911:	83 ec 08             	sub    $0x8,%esp
  800914:	ff 75 0c             	pushl  0xc(%ebp)
  800917:	50                   	push   %eax
  800918:	e8 65 ff ff ff       	call   800882 <fstat>
  80091d:	89 c6                	mov    %eax,%esi
	close(fd);
  80091f:	89 1c 24             	mov    %ebx,(%esp)
  800922:	e8 18 fc ff ff       	call   80053f <close>
	return r;
  800927:	83 c4 10             	add    $0x10,%esp
  80092a:	89 f3                	mov    %esi,%ebx
}
  80092c:	89 d8                	mov    %ebx,%eax
  80092e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800931:	5b                   	pop    %ebx
  800932:	5e                   	pop    %esi
  800933:	c9                   	leave  
  800934:	c3                   	ret    
  800935:	00 00                	add    %al,(%eax)
	...

00800938 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  800938:	55                   	push   %ebp
  800939:	89 e5                	mov    %esp,%ebp
  80093b:	56                   	push   %esi
  80093c:	53                   	push   %ebx
  80093d:	89 c3                	mov    %eax,%ebx
  80093f:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  800941:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  800948:	75 12                	jne    80095c <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  80094a:	83 ec 0c             	sub    $0xc,%esp
  80094d:	6a 01                	push   $0x1
  80094f:	e8 96 11 00 00       	call   801aea <ipc_find_env>
  800954:	a3 00 40 80 00       	mov    %eax,0x804000
  800959:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  80095c:	6a 07                	push   $0x7
  80095e:	68 00 50 80 00       	push   $0x805000
  800963:	53                   	push   %ebx
  800964:	ff 35 00 40 80 00    	pushl  0x804000
  80096a:	e8 26 11 00 00       	call   801a95 <ipc_send>
	
	return ipc_recv(NULL, dstva, NULL);
  80096f:	83 c4 0c             	add    $0xc,%esp
  800972:	6a 00                	push   $0x0
  800974:	56                   	push   %esi
  800975:	6a 00                	push   $0x0
  800977:	e8 a4 10 00 00       	call   801a20 <ipc_recv>
}
  80097c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80097f:	5b                   	pop    %ebx
  800980:	5e                   	pop    %esi
  800981:	c9                   	leave  
  800982:	c3                   	ret    

00800983 <devfile_stat>:
}


static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  800983:	55                   	push   %ebp
  800984:	89 e5                	mov    %esp,%ebp
  800986:	53                   	push   %ebx
  800987:	83 ec 04             	sub    $0x4,%esp
  80098a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  80098d:	8b 45 08             	mov    0x8(%ebp),%eax
  800990:	8b 40 0c             	mov    0xc(%eax),%eax
  800993:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0) {
  800998:	ba 00 00 00 00       	mov    $0x0,%edx
  80099d:	b8 05 00 00 00       	mov    $0x5,%eax
  8009a2:	e8 91 ff ff ff       	call   800938 <fsipc>
  8009a7:	85 c0                	test   %eax,%eax
  8009a9:	78 2c                	js     8009d7 <devfile_stat+0x54>
		return r;
	}
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8009ab:	83 ec 08             	sub    $0x8,%esp
  8009ae:	68 00 50 80 00       	push   $0x805000
  8009b3:	53                   	push   %ebx
  8009b4:	e8 e9 0c 00 00       	call   8016a2 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8009b9:	a1 80 50 80 00       	mov    0x805080,%eax
  8009be:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8009c4:	a1 84 50 80 00       	mov    0x805084,%eax
  8009c9:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8009cf:	83 c4 10             	add    $0x10,%esp
  8009d2:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009d7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8009da:	c9                   	leave  
  8009db:	c3                   	ret    

008009dc <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8009dc:	55                   	push   %ebp
  8009dd:	89 e5                	mov    %esp,%ebp
  8009df:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8009e2:	8b 45 08             	mov    0x8(%ebp),%eax
  8009e5:	8b 40 0c             	mov    0xc(%eax),%eax
  8009e8:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8009ed:	ba 00 00 00 00       	mov    $0x0,%edx
  8009f2:	b8 06 00 00 00       	mov    $0x6,%eax
  8009f7:	e8 3c ff ff ff       	call   800938 <fsipc>
}
  8009fc:	c9                   	leave  
  8009fd:	c3                   	ret    

008009fe <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  8009fe:	55                   	push   %ebp
  8009ff:	89 e5                	mov    %esp,%ebp
  800a01:	56                   	push   %esi
  800a02:	53                   	push   %ebx
  800a03:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  800a06:	8b 45 08             	mov    0x8(%ebp),%eax
  800a09:	8b 40 0c             	mov    0xc(%eax),%eax
  800a0c:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  800a11:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  800a17:	ba 00 00 00 00       	mov    $0x0,%edx
  800a1c:	b8 03 00 00 00       	mov    $0x3,%eax
  800a21:	e8 12 ff ff ff       	call   800938 <fsipc>
  800a26:	89 c3                	mov    %eax,%ebx
  800a28:	85 c0                	test   %eax,%eax
  800a2a:	78 4b                	js     800a77 <devfile_read+0x79>
		return r;
	assert(r <= n);
  800a2c:	39 c6                	cmp    %eax,%esi
  800a2e:	73 16                	jae    800a46 <devfile_read+0x48>
  800a30:	68 a4 1e 80 00       	push   $0x801ea4
  800a35:	68 ab 1e 80 00       	push   $0x801eab
  800a3a:	6a 7d                	push   $0x7d
  800a3c:	68 c0 1e 80 00       	push   $0x801ec0
  800a41:	e8 ce 05 00 00       	call   801014 <_panic>
	assert(r <= PGSIZE);
  800a46:	3d 00 10 00 00       	cmp    $0x1000,%eax
  800a4b:	7e 16                	jle    800a63 <devfile_read+0x65>
  800a4d:	68 cb 1e 80 00       	push   $0x801ecb
  800a52:	68 ab 1e 80 00       	push   $0x801eab
  800a57:	6a 7e                	push   $0x7e
  800a59:	68 c0 1e 80 00       	push   $0x801ec0
  800a5e:	e8 b1 05 00 00       	call   801014 <_panic>
	memmove(buf, &fsipcbuf, r);
  800a63:	83 ec 04             	sub    $0x4,%esp
  800a66:	50                   	push   %eax
  800a67:	68 00 50 80 00       	push   $0x805000
  800a6c:	ff 75 0c             	pushl  0xc(%ebp)
  800a6f:	e8 ef 0d 00 00       	call   801863 <memmove>
	return r;
  800a74:	83 c4 10             	add    $0x10,%esp
}
  800a77:	89 d8                	mov    %ebx,%eax
  800a79:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800a7c:	5b                   	pop    %ebx
  800a7d:	5e                   	pop    %esi
  800a7e:	c9                   	leave  
  800a7f:	c3                   	ret    

00800a80 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  800a80:	55                   	push   %ebp
  800a81:	89 e5                	mov    %esp,%ebp
  800a83:	56                   	push   %esi
  800a84:	53                   	push   %ebx
  800a85:	83 ec 1c             	sub    $0x1c,%esp
  800a88:	8b 75 08             	mov    0x8(%ebp),%esi
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  800a8b:	56                   	push   %esi
  800a8c:	e8 bf 0b 00 00       	call   801650 <strlen>
  800a91:	83 c4 10             	add    $0x10,%esp
  800a94:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  800a99:	7f 65                	jg     800b00 <open+0x80>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800a9b:	83 ec 0c             	sub    $0xc,%esp
  800a9e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800aa1:	50                   	push   %eax
  800aa2:	e8 e1 f8 ff ff       	call   800388 <fd_alloc>
  800aa7:	89 c3                	mov    %eax,%ebx
  800aa9:	83 c4 10             	add    $0x10,%esp
  800aac:	85 c0                	test   %eax,%eax
  800aae:	78 55                	js     800b05 <open+0x85>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  800ab0:	83 ec 08             	sub    $0x8,%esp
  800ab3:	56                   	push   %esi
  800ab4:	68 00 50 80 00       	push   $0x805000
  800ab9:	e8 e4 0b 00 00       	call   8016a2 <strcpy>
	fsipcbuf.open.req_omode = mode;
  800abe:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ac1:	a3 00 54 80 00       	mov    %eax,0x805400



	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  800ac6:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800ac9:	b8 01 00 00 00       	mov    $0x1,%eax
  800ace:	e8 65 fe ff ff       	call   800938 <fsipc>
  800ad3:	89 c3                	mov    %eax,%ebx
  800ad5:	83 c4 10             	add    $0x10,%esp
  800ad8:	85 c0                	test   %eax,%eax
  800ada:	79 12                	jns    800aee <open+0x6e>
		fd_close(fd, 0);
  800adc:	83 ec 08             	sub    $0x8,%esp
  800adf:	6a 00                	push   $0x0
  800ae1:	ff 75 f4             	pushl  -0xc(%ebp)
  800ae4:	e8 ce f9 ff ff       	call   8004b7 <fd_close>
		return r;
  800ae9:	83 c4 10             	add    $0x10,%esp
  800aec:	eb 17                	jmp    800b05 <open+0x85>
	}

	return fd2num(fd);
  800aee:	83 ec 0c             	sub    $0xc,%esp
  800af1:	ff 75 f4             	pushl  -0xc(%ebp)
  800af4:	e8 67 f8 ff ff       	call   800360 <fd2num>
  800af9:	89 c3                	mov    %eax,%ebx
  800afb:	83 c4 10             	add    $0x10,%esp
  800afe:	eb 05                	jmp    800b05 <open+0x85>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  800b00:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  800b05:	89 d8                	mov    %ebx,%eax
  800b07:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800b0a:	5b                   	pop    %ebx
  800b0b:	5e                   	pop    %esi
  800b0c:	c9                   	leave  
  800b0d:	c3                   	ret    
	...

00800b10 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  800b10:	55                   	push   %ebp
  800b11:	89 e5                	mov    %esp,%ebp
  800b13:	56                   	push   %esi
  800b14:	53                   	push   %ebx
  800b15:	8b 75 0c             	mov    0xc(%ebp),%esi
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  800b18:	83 ec 0c             	sub    $0xc,%esp
  800b1b:	ff 75 08             	pushl  0x8(%ebp)
  800b1e:	e8 4d f8 ff ff       	call   800370 <fd2data>
  800b23:	89 c3                	mov    %eax,%ebx
	strcpy(stat->st_name, "<pipe>");
  800b25:	83 c4 08             	add    $0x8,%esp
  800b28:	68 d7 1e 80 00       	push   $0x801ed7
  800b2d:	56                   	push   %esi
  800b2e:	e8 6f 0b 00 00       	call   8016a2 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  800b33:	8b 43 04             	mov    0x4(%ebx),%eax
  800b36:	2b 03                	sub    (%ebx),%eax
  800b38:	89 86 80 00 00 00    	mov    %eax,0x80(%esi)
	stat->st_isdir = 0;
  800b3e:	c7 86 84 00 00 00 00 	movl   $0x0,0x84(%esi)
  800b45:	00 00 00 
	stat->st_dev = &devpipe;
  800b48:	c7 86 88 00 00 00 20 	movl   $0x803020,0x88(%esi)
  800b4f:	30 80 00 
	return 0;
}
  800b52:	b8 00 00 00 00       	mov    $0x0,%eax
  800b57:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800b5a:	5b                   	pop    %ebx
  800b5b:	5e                   	pop    %esi
  800b5c:	c9                   	leave  
  800b5d:	c3                   	ret    

00800b5e <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  800b5e:	55                   	push   %ebp
  800b5f:	89 e5                	mov    %esp,%ebp
  800b61:	53                   	push   %ebx
  800b62:	83 ec 0c             	sub    $0xc,%esp
  800b65:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  800b68:	53                   	push   %ebx
  800b69:	6a 00                	push   $0x0
  800b6b:	e8 8e f6 ff ff       	call   8001fe <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  800b70:	89 1c 24             	mov    %ebx,(%esp)
  800b73:	e8 f8 f7 ff ff       	call   800370 <fd2data>
  800b78:	83 c4 08             	add    $0x8,%esp
  800b7b:	50                   	push   %eax
  800b7c:	6a 00                	push   $0x0
  800b7e:	e8 7b f6 ff ff       	call   8001fe <sys_page_unmap>
}
  800b83:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800b86:	c9                   	leave  
  800b87:	c3                   	ret    

00800b88 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  800b88:	55                   	push   %ebp
  800b89:	89 e5                	mov    %esp,%ebp
  800b8b:	57                   	push   %edi
  800b8c:	56                   	push   %esi
  800b8d:	53                   	push   %ebx
  800b8e:	83 ec 1c             	sub    $0x1c,%esp
  800b91:	89 c7                	mov    %eax,%edi
  800b93:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  800b96:	a1 04 40 80 00       	mov    0x804004,%eax
  800b9b:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  800b9e:	83 ec 0c             	sub    $0xc,%esp
  800ba1:	57                   	push   %edi
  800ba2:	e8 91 0f 00 00       	call   801b38 <pageref>
  800ba7:	89 c6                	mov    %eax,%esi
  800ba9:	83 c4 04             	add    $0x4,%esp
  800bac:	ff 75 e4             	pushl  -0x1c(%ebp)
  800baf:	e8 84 0f 00 00       	call   801b38 <pageref>
  800bb4:	83 c4 10             	add    $0x10,%esp
  800bb7:	39 c6                	cmp    %eax,%esi
  800bb9:	0f 94 c0             	sete   %al
  800bbc:	0f b6 c0             	movzbl %al,%eax
		nn = thisenv->env_runs;
  800bbf:	8b 15 04 40 80 00    	mov    0x804004,%edx
  800bc5:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  800bc8:	39 cb                	cmp    %ecx,%ebx
  800bca:	75 08                	jne    800bd4 <_pipeisclosed+0x4c>
			return ret;
		if (n != nn && ret == 1)
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
	}
}
  800bcc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bcf:	5b                   	pop    %ebx
  800bd0:	5e                   	pop    %esi
  800bd1:	5f                   	pop    %edi
  800bd2:	c9                   	leave  
  800bd3:	c3                   	ret    
		n = thisenv->env_runs;
		ret = pageref(fd) == pageref(p);
		nn = thisenv->env_runs;
		if (n == nn)
			return ret;
		if (n != nn && ret == 1)
  800bd4:	83 f8 01             	cmp    $0x1,%eax
  800bd7:	75 bd                	jne    800b96 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  800bd9:	8b 42 58             	mov    0x58(%edx),%eax
  800bdc:	6a 01                	push   $0x1
  800bde:	50                   	push   %eax
  800bdf:	53                   	push   %ebx
  800be0:	68 de 1e 80 00       	push   $0x801ede
  800be5:	e8 02 05 00 00       	call   8010ec <cprintf>
  800bea:	83 c4 10             	add    $0x10,%esp
  800bed:	eb a7                	jmp    800b96 <_pipeisclosed+0xe>

00800bef <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  800bef:	55                   	push   %ebp
  800bf0:	89 e5                	mov    %esp,%ebp
  800bf2:	57                   	push   %edi
  800bf3:	56                   	push   %esi
  800bf4:	53                   	push   %ebx
  800bf5:	83 ec 28             	sub    $0x28,%esp
  800bf8:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  800bfb:	56                   	push   %esi
  800bfc:	e8 6f f7 ff ff       	call   800370 <fd2data>
  800c01:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800c03:	83 c4 10             	add    $0x10,%esp
  800c06:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800c0a:	75 4a                	jne    800c56 <devpipe_write+0x67>
  800c0c:	bf 00 00 00 00       	mov    $0x0,%edi
  800c11:	eb 56                	jmp    800c69 <devpipe_write+0x7a>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  800c13:	89 da                	mov    %ebx,%edx
  800c15:	89 f0                	mov    %esi,%eax
  800c17:	e8 6c ff ff ff       	call   800b88 <_pipeisclosed>
  800c1c:	85 c0                	test   %eax,%eax
  800c1e:	75 4d                	jne    800c6d <devpipe_write+0x7e>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  800c20:	e8 68 f5 ff ff       	call   80018d <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  800c25:	8b 43 04             	mov    0x4(%ebx),%eax
  800c28:	8b 13                	mov    (%ebx),%edx
  800c2a:	83 c2 20             	add    $0x20,%edx
  800c2d:	39 d0                	cmp    %edx,%eax
  800c2f:	73 e2                	jae    800c13 <devpipe_write+0x24>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  800c31:	89 c2                	mov    %eax,%edx
  800c33:	81 e2 1f 00 00 80    	and    $0x8000001f,%edx
  800c39:	79 05                	jns    800c40 <devpipe_write+0x51>
  800c3b:	4a                   	dec    %edx
  800c3c:	83 ca e0             	or     $0xffffffe0,%edx
  800c3f:	42                   	inc    %edx
  800c40:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c43:	8a 0c 39             	mov    (%ecx,%edi,1),%cl
  800c46:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  800c4a:	40                   	inc    %eax
  800c4b:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800c4e:	47                   	inc    %edi
  800c4f:	39 7d 10             	cmp    %edi,0x10(%ebp)
  800c52:	77 07                	ja     800c5b <devpipe_write+0x6c>
  800c54:	eb 13                	jmp    800c69 <devpipe_write+0x7a>
  800c56:	bf 00 00 00 00       	mov    $0x0,%edi
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  800c5b:	8b 43 04             	mov    0x4(%ebx),%eax
  800c5e:	8b 13                	mov    (%ebx),%edx
  800c60:	83 c2 20             	add    $0x20,%edx
  800c63:	39 d0                	cmp    %edx,%eax
  800c65:	73 ac                	jae    800c13 <devpipe_write+0x24>
  800c67:	eb c8                	jmp    800c31 <devpipe_write+0x42>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  800c69:	89 f8                	mov    %edi,%eax
  800c6b:	eb 05                	jmp    800c72 <devpipe_write+0x83>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  800c6d:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  800c72:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c75:	5b                   	pop    %ebx
  800c76:	5e                   	pop    %esi
  800c77:	5f                   	pop    %edi
  800c78:	c9                   	leave  
  800c79:	c3                   	ret    

00800c7a <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  800c7a:	55                   	push   %ebp
  800c7b:	89 e5                	mov    %esp,%ebp
  800c7d:	57                   	push   %edi
  800c7e:	56                   	push   %esi
  800c7f:	53                   	push   %ebx
  800c80:	83 ec 18             	sub    $0x18,%esp
  800c83:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  800c86:	57                   	push   %edi
  800c87:	e8 e4 f6 ff ff       	call   800370 <fd2data>
  800c8c:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800c8e:	83 c4 10             	add    $0x10,%esp
  800c91:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800c95:	75 44                	jne    800cdb <devpipe_read+0x61>
  800c97:	be 00 00 00 00       	mov    $0x0,%esi
  800c9c:	eb 4f                	jmp    800ced <devpipe_read+0x73>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
				return i;
  800c9e:	89 f0                	mov    %esi,%eax
  800ca0:	eb 54                	jmp    800cf6 <devpipe_read+0x7c>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  800ca2:	89 da                	mov    %ebx,%edx
  800ca4:	89 f8                	mov    %edi,%eax
  800ca6:	e8 dd fe ff ff       	call   800b88 <_pipeisclosed>
  800cab:	85 c0                	test   %eax,%eax
  800cad:	75 42                	jne    800cf1 <devpipe_read+0x77>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  800caf:	e8 d9 f4 ff ff       	call   80018d <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  800cb4:	8b 03                	mov    (%ebx),%eax
  800cb6:	3b 43 04             	cmp    0x4(%ebx),%eax
  800cb9:	74 e7                	je     800ca2 <devpipe_read+0x28>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  800cbb:	25 1f 00 00 80       	and    $0x8000001f,%eax
  800cc0:	79 05                	jns    800cc7 <devpipe_read+0x4d>
  800cc2:	48                   	dec    %eax
  800cc3:	83 c8 e0             	or     $0xffffffe0,%eax
  800cc6:	40                   	inc    %eax
  800cc7:	8a 44 03 08          	mov    0x8(%ebx,%eax,1),%al
  800ccb:	8b 55 0c             	mov    0xc(%ebp),%edx
  800cce:	88 04 32             	mov    %al,(%edx,%esi,1)
		p->p_rpos++;
  800cd1:	ff 03                	incl   (%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800cd3:	46                   	inc    %esi
  800cd4:	39 75 10             	cmp    %esi,0x10(%ebp)
  800cd7:	77 07                	ja     800ce0 <devpipe_read+0x66>
  800cd9:	eb 12                	jmp    800ced <devpipe_read+0x73>
  800cdb:	be 00 00 00 00       	mov    $0x0,%esi
		while (p->p_rpos == p->p_wpos) {
  800ce0:	8b 03                	mov    (%ebx),%eax
  800ce2:	3b 43 04             	cmp    0x4(%ebx),%eax
  800ce5:	75 d4                	jne    800cbb <devpipe_read+0x41>
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  800ce7:	85 f6                	test   %esi,%esi
  800ce9:	75 b3                	jne    800c9e <devpipe_read+0x24>
  800ceb:	eb b5                	jmp    800ca2 <devpipe_read+0x28>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  800ced:	89 f0                	mov    %esi,%eax
  800cef:	eb 05                	jmp    800cf6 <devpipe_read+0x7c>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  800cf1:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  800cf6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cf9:	5b                   	pop    %ebx
  800cfa:	5e                   	pop    %esi
  800cfb:	5f                   	pop    %edi
  800cfc:	c9                   	leave  
  800cfd:	c3                   	ret    

00800cfe <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  800cfe:	55                   	push   %ebp
  800cff:	89 e5                	mov    %esp,%ebp
  800d01:	57                   	push   %edi
  800d02:	56                   	push   %esi
  800d03:	53                   	push   %ebx
  800d04:	83 ec 28             	sub    $0x28,%esp
  800d07:	8b 7d 08             	mov    0x8(%ebp),%edi
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  800d0a:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800d0d:	50                   	push   %eax
  800d0e:	e8 75 f6 ff ff       	call   800388 <fd_alloc>
  800d13:	89 c3                	mov    %eax,%ebx
  800d15:	83 c4 10             	add    $0x10,%esp
  800d18:	85 c0                	test   %eax,%eax
  800d1a:	0f 88 24 01 00 00    	js     800e44 <pipe+0x146>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800d20:	83 ec 04             	sub    $0x4,%esp
  800d23:	68 07 04 00 00       	push   $0x407
  800d28:	ff 75 e4             	pushl  -0x1c(%ebp)
  800d2b:	6a 00                	push   $0x0
  800d2d:	e8 82 f4 ff ff       	call   8001b4 <sys_page_alloc>
  800d32:	89 c3                	mov    %eax,%ebx
  800d34:	83 c4 10             	add    $0x10,%esp
  800d37:	85 c0                	test   %eax,%eax
  800d39:	0f 88 05 01 00 00    	js     800e44 <pipe+0x146>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  800d3f:	83 ec 0c             	sub    $0xc,%esp
  800d42:	8d 45 e0             	lea    -0x20(%ebp),%eax
  800d45:	50                   	push   %eax
  800d46:	e8 3d f6 ff ff       	call   800388 <fd_alloc>
  800d4b:	89 c3                	mov    %eax,%ebx
  800d4d:	83 c4 10             	add    $0x10,%esp
  800d50:	85 c0                	test   %eax,%eax
  800d52:	0f 88 dc 00 00 00    	js     800e34 <pipe+0x136>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800d58:	83 ec 04             	sub    $0x4,%esp
  800d5b:	68 07 04 00 00       	push   $0x407
  800d60:	ff 75 e0             	pushl  -0x20(%ebp)
  800d63:	6a 00                	push   $0x0
  800d65:	e8 4a f4 ff ff       	call   8001b4 <sys_page_alloc>
  800d6a:	89 c3                	mov    %eax,%ebx
  800d6c:	83 c4 10             	add    $0x10,%esp
  800d6f:	85 c0                	test   %eax,%eax
  800d71:	0f 88 bd 00 00 00    	js     800e34 <pipe+0x136>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  800d77:	83 ec 0c             	sub    $0xc,%esp
  800d7a:	ff 75 e4             	pushl  -0x1c(%ebp)
  800d7d:	e8 ee f5 ff ff       	call   800370 <fd2data>
  800d82:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800d84:	83 c4 0c             	add    $0xc,%esp
  800d87:	68 07 04 00 00       	push   $0x407
  800d8c:	50                   	push   %eax
  800d8d:	6a 00                	push   $0x0
  800d8f:	e8 20 f4 ff ff       	call   8001b4 <sys_page_alloc>
  800d94:	89 c3                	mov    %eax,%ebx
  800d96:	83 c4 10             	add    $0x10,%esp
  800d99:	85 c0                	test   %eax,%eax
  800d9b:	0f 88 83 00 00 00    	js     800e24 <pipe+0x126>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800da1:	83 ec 0c             	sub    $0xc,%esp
  800da4:	ff 75 e0             	pushl  -0x20(%ebp)
  800da7:	e8 c4 f5 ff ff       	call   800370 <fd2data>
  800dac:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  800db3:	50                   	push   %eax
  800db4:	6a 00                	push   $0x0
  800db6:	56                   	push   %esi
  800db7:	6a 00                	push   $0x0
  800db9:	e8 1a f4 ff ff       	call   8001d8 <sys_page_map>
  800dbe:	89 c3                	mov    %eax,%ebx
  800dc0:	83 c4 20             	add    $0x20,%esp
  800dc3:	85 c0                	test   %eax,%eax
  800dc5:	78 4f                	js     800e16 <pipe+0x118>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  800dc7:	8b 15 20 30 80 00    	mov    0x803020,%edx
  800dcd:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800dd0:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  800dd2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800dd5:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  800ddc:	8b 15 20 30 80 00    	mov    0x803020,%edx
  800de2:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800de5:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  800de7:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800dea:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  800df1:	83 ec 0c             	sub    $0xc,%esp
  800df4:	ff 75 e4             	pushl  -0x1c(%ebp)
  800df7:	e8 64 f5 ff ff       	call   800360 <fd2num>
  800dfc:	89 07                	mov    %eax,(%edi)
	pfd[1] = fd2num(fd1);
  800dfe:	83 c4 04             	add    $0x4,%esp
  800e01:	ff 75 e0             	pushl  -0x20(%ebp)
  800e04:	e8 57 f5 ff ff       	call   800360 <fd2num>
  800e09:	89 47 04             	mov    %eax,0x4(%edi)
	return 0;
  800e0c:	83 c4 10             	add    $0x10,%esp
  800e0f:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e14:	eb 2e                	jmp    800e44 <pipe+0x146>

    err3:
	sys_page_unmap(0, va);
  800e16:	83 ec 08             	sub    $0x8,%esp
  800e19:	56                   	push   %esi
  800e1a:	6a 00                	push   $0x0
  800e1c:	e8 dd f3 ff ff       	call   8001fe <sys_page_unmap>
  800e21:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  800e24:	83 ec 08             	sub    $0x8,%esp
  800e27:	ff 75 e0             	pushl  -0x20(%ebp)
  800e2a:	6a 00                	push   $0x0
  800e2c:	e8 cd f3 ff ff       	call   8001fe <sys_page_unmap>
  800e31:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  800e34:	83 ec 08             	sub    $0x8,%esp
  800e37:	ff 75 e4             	pushl  -0x1c(%ebp)
  800e3a:	6a 00                	push   $0x0
  800e3c:	e8 bd f3 ff ff       	call   8001fe <sys_page_unmap>
  800e41:	83 c4 10             	add    $0x10,%esp
    err:
	return r;
}
  800e44:	89 d8                	mov    %ebx,%eax
  800e46:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e49:	5b                   	pop    %ebx
  800e4a:	5e                   	pop    %esi
  800e4b:	5f                   	pop    %edi
  800e4c:	c9                   	leave  
  800e4d:	c3                   	ret    

00800e4e <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  800e4e:	55                   	push   %ebp
  800e4f:	89 e5                	mov    %esp,%ebp
  800e51:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800e54:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800e57:	50                   	push   %eax
  800e58:	ff 75 08             	pushl  0x8(%ebp)
  800e5b:	e8 9b f5 ff ff       	call   8003fb <fd_lookup>
  800e60:	83 c4 10             	add    $0x10,%esp
  800e63:	85 c0                	test   %eax,%eax
  800e65:	78 18                	js     800e7f <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  800e67:	83 ec 0c             	sub    $0xc,%esp
  800e6a:	ff 75 f4             	pushl  -0xc(%ebp)
  800e6d:	e8 fe f4 ff ff       	call   800370 <fd2data>
	return _pipeisclosed(fd, p);
  800e72:	89 c2                	mov    %eax,%edx
  800e74:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800e77:	e8 0c fd ff ff       	call   800b88 <_pipeisclosed>
  800e7c:	83 c4 10             	add    $0x10,%esp
}
  800e7f:	c9                   	leave  
  800e80:	c3                   	ret    
  800e81:	00 00                	add    %al,(%eax)
	...

00800e84 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  800e84:	55                   	push   %ebp
  800e85:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  800e87:	b8 00 00 00 00       	mov    $0x0,%eax
  800e8c:	c9                   	leave  
  800e8d:	c3                   	ret    

00800e8e <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  800e8e:	55                   	push   %ebp
  800e8f:	89 e5                	mov    %esp,%ebp
  800e91:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  800e94:	68 f6 1e 80 00       	push   $0x801ef6
  800e99:	ff 75 0c             	pushl  0xc(%ebp)
  800e9c:	e8 01 08 00 00       	call   8016a2 <strcpy>
	return 0;
}
  800ea1:	b8 00 00 00 00       	mov    $0x0,%eax
  800ea6:	c9                   	leave  
  800ea7:	c3                   	ret    

00800ea8 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  800ea8:	55                   	push   %ebp
  800ea9:	89 e5                	mov    %esp,%ebp
  800eab:	57                   	push   %edi
  800eac:	56                   	push   %esi
  800ead:	53                   	push   %ebx
  800eae:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800eb4:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800eb8:	74 45                	je     800eff <devcons_write+0x57>
  800eba:	b8 00 00 00 00       	mov    $0x0,%eax
  800ebf:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  800ec4:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  800eca:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800ecd:	29 c3                	sub    %eax,%ebx
		if (m > sizeof(buf) - 1)
  800ecf:	83 fb 7f             	cmp    $0x7f,%ebx
  800ed2:	76 05                	jbe    800ed9 <devcons_write+0x31>
			m = sizeof(buf) - 1;
  800ed4:	bb 7f 00 00 00       	mov    $0x7f,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  800ed9:	83 ec 04             	sub    $0x4,%esp
  800edc:	53                   	push   %ebx
  800edd:	03 45 0c             	add    0xc(%ebp),%eax
  800ee0:	50                   	push   %eax
  800ee1:	57                   	push   %edi
  800ee2:	e8 7c 09 00 00       	call   801863 <memmove>
		sys_cputs(buf, m);
  800ee7:	83 c4 08             	add    $0x8,%esp
  800eea:	53                   	push   %ebx
  800eeb:	57                   	push   %edi
  800eec:	e8 0c f2 ff ff       	call   8000fd <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800ef1:	01 de                	add    %ebx,%esi
  800ef3:	89 f0                	mov    %esi,%eax
  800ef5:	83 c4 10             	add    $0x10,%esp
  800ef8:	3b 75 10             	cmp    0x10(%ebp),%esi
  800efb:	72 cd                	jb     800eca <devcons_write+0x22>
  800efd:	eb 05                	jmp    800f04 <devcons_write+0x5c>
  800eff:	be 00 00 00 00       	mov    $0x0,%esi
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  800f04:	89 f0                	mov    %esi,%eax
  800f06:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f09:	5b                   	pop    %ebx
  800f0a:	5e                   	pop    %esi
  800f0b:	5f                   	pop    %edi
  800f0c:	c9                   	leave  
  800f0d:	c3                   	ret    

00800f0e <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  800f0e:	55                   	push   %ebp
  800f0f:	89 e5                	mov    %esp,%ebp
  800f11:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
  800f14:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800f18:	75 07                	jne    800f21 <devcons_read+0x13>
  800f1a:	eb 25                	jmp    800f41 <devcons_read+0x33>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  800f1c:	e8 6c f2 ff ff       	call   80018d <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  800f21:	e8 fd f1 ff ff       	call   800123 <sys_cgetc>
  800f26:	85 c0                	test   %eax,%eax
  800f28:	74 f2                	je     800f1c <devcons_read+0xe>
  800f2a:	89 c2                	mov    %eax,%edx
		sys_yield();
	if (c < 0)
  800f2c:	85 c0                	test   %eax,%eax
  800f2e:	78 1d                	js     800f4d <devcons_read+0x3f>
		return c;
	if (c == 0x04)	// ctl-d is eof
  800f30:	83 f8 04             	cmp    $0x4,%eax
  800f33:	74 13                	je     800f48 <devcons_read+0x3a>
		return 0;
	*(char*)vbuf = c;
  800f35:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f38:	88 10                	mov    %dl,(%eax)
	return 1;
  800f3a:	b8 01 00 00 00       	mov    $0x1,%eax
  800f3f:	eb 0c                	jmp    800f4d <devcons_read+0x3f>
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
		return 0;
  800f41:	b8 00 00 00 00       	mov    $0x0,%eax
  800f46:	eb 05                	jmp    800f4d <devcons_read+0x3f>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  800f48:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  800f4d:	c9                   	leave  
  800f4e:	c3                   	ret    

00800f4f <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  800f4f:	55                   	push   %ebp
  800f50:	89 e5                	mov    %esp,%ebp
  800f52:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  800f55:	8b 45 08             	mov    0x8(%ebp),%eax
  800f58:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  800f5b:	6a 01                	push   $0x1
  800f5d:	8d 45 f7             	lea    -0x9(%ebp),%eax
  800f60:	50                   	push   %eax
  800f61:	e8 97 f1 ff ff       	call   8000fd <sys_cputs>
  800f66:	83 c4 10             	add    $0x10,%esp
}
  800f69:	c9                   	leave  
  800f6a:	c3                   	ret    

00800f6b <getchar>:

int
getchar(void)
{
  800f6b:	55                   	push   %ebp
  800f6c:	89 e5                	mov    %esp,%ebp
  800f6e:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  800f71:	6a 01                	push   $0x1
  800f73:	8d 45 f7             	lea    -0x9(%ebp),%eax
  800f76:	50                   	push   %eax
  800f77:	6a 00                	push   $0x0
  800f79:	e8 fe f6 ff ff       	call   80067c <read>
	if (r < 0)
  800f7e:	83 c4 10             	add    $0x10,%esp
  800f81:	85 c0                	test   %eax,%eax
  800f83:	78 0f                	js     800f94 <getchar+0x29>
		return r;
	if (r < 1)
  800f85:	85 c0                	test   %eax,%eax
  800f87:	7e 06                	jle    800f8f <getchar+0x24>
		return -E_EOF;
	return c;
  800f89:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  800f8d:	eb 05                	jmp    800f94 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  800f8f:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  800f94:	c9                   	leave  
  800f95:	c3                   	ret    

00800f96 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  800f96:	55                   	push   %ebp
  800f97:	89 e5                	mov    %esp,%ebp
  800f99:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800f9c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800f9f:	50                   	push   %eax
  800fa0:	ff 75 08             	pushl  0x8(%ebp)
  800fa3:	e8 53 f4 ff ff       	call   8003fb <fd_lookup>
  800fa8:	83 c4 10             	add    $0x10,%esp
  800fab:	85 c0                	test   %eax,%eax
  800fad:	78 11                	js     800fc0 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  800faf:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800fb2:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  800fb8:	39 10                	cmp    %edx,(%eax)
  800fba:	0f 94 c0             	sete   %al
  800fbd:	0f b6 c0             	movzbl %al,%eax
}
  800fc0:	c9                   	leave  
  800fc1:	c3                   	ret    

00800fc2 <opencons>:

int
opencons(void)
{
  800fc2:	55                   	push   %ebp
  800fc3:	89 e5                	mov    %esp,%ebp
  800fc5:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  800fc8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800fcb:	50                   	push   %eax
  800fcc:	e8 b7 f3 ff ff       	call   800388 <fd_alloc>
  800fd1:	83 c4 10             	add    $0x10,%esp
  800fd4:	85 c0                	test   %eax,%eax
  800fd6:	78 3a                	js     801012 <opencons+0x50>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  800fd8:	83 ec 04             	sub    $0x4,%esp
  800fdb:	68 07 04 00 00       	push   $0x407
  800fe0:	ff 75 f4             	pushl  -0xc(%ebp)
  800fe3:	6a 00                	push   $0x0
  800fe5:	e8 ca f1 ff ff       	call   8001b4 <sys_page_alloc>
  800fea:	83 c4 10             	add    $0x10,%esp
  800fed:	85 c0                	test   %eax,%eax
  800fef:	78 21                	js     801012 <opencons+0x50>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  800ff1:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  800ff7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800ffa:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  800ffc:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800fff:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801006:	83 ec 0c             	sub    $0xc,%esp
  801009:	50                   	push   %eax
  80100a:	e8 51 f3 ff ff       	call   800360 <fd2num>
  80100f:	83 c4 10             	add    $0x10,%esp
}
  801012:	c9                   	leave  
  801013:	c3                   	ret    

00801014 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801014:	55                   	push   %ebp
  801015:	89 e5                	mov    %esp,%ebp
  801017:	56                   	push   %esi
  801018:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801019:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80101c:	8b 1d 00 30 80 00    	mov    0x803000,%ebx
  801022:	e8 42 f1 ff ff       	call   800169 <sys_getenvid>
  801027:	83 ec 0c             	sub    $0xc,%esp
  80102a:	ff 75 0c             	pushl  0xc(%ebp)
  80102d:	ff 75 08             	pushl  0x8(%ebp)
  801030:	53                   	push   %ebx
  801031:	50                   	push   %eax
  801032:	68 04 1f 80 00       	push   $0x801f04
  801037:	e8 b0 00 00 00       	call   8010ec <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80103c:	83 c4 18             	add    $0x18,%esp
  80103f:	56                   	push   %esi
  801040:	ff 75 10             	pushl  0x10(%ebp)
  801043:	e8 53 00 00 00       	call   80109b <vcprintf>
	cprintf("\n");
  801048:	c7 04 24 ef 1e 80 00 	movl   $0x801eef,(%esp)
  80104f:	e8 98 00 00 00       	call   8010ec <cprintf>
  801054:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801057:	cc                   	int3   
  801058:	eb fd                	jmp    801057 <_panic+0x43>
	...

0080105c <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80105c:	55                   	push   %ebp
  80105d:	89 e5                	mov    %esp,%ebp
  80105f:	53                   	push   %ebx
  801060:	83 ec 04             	sub    $0x4,%esp
  801063:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  801066:	8b 03                	mov    (%ebx),%eax
  801068:	8b 55 08             	mov    0x8(%ebp),%edx
  80106b:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  80106f:	40                   	inc    %eax
  801070:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  801072:	3d ff 00 00 00       	cmp    $0xff,%eax
  801077:	75 1a                	jne    801093 <putch+0x37>
		sys_cputs(b->buf, b->idx);
  801079:	83 ec 08             	sub    $0x8,%esp
  80107c:	68 ff 00 00 00       	push   $0xff
  801081:	8d 43 08             	lea    0x8(%ebx),%eax
  801084:	50                   	push   %eax
  801085:	e8 73 f0 ff ff       	call   8000fd <sys_cputs>
		b->idx = 0;
  80108a:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801090:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  801093:	ff 43 04             	incl   0x4(%ebx)
}
  801096:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801099:	c9                   	leave  
  80109a:	c3                   	ret    

0080109b <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80109b:	55                   	push   %ebp
  80109c:	89 e5                	mov    %esp,%ebp
  80109e:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8010a4:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8010ab:	00 00 00 
	b.cnt = 0;
  8010ae:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8010b5:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8010b8:	ff 75 0c             	pushl  0xc(%ebp)
  8010bb:	ff 75 08             	pushl  0x8(%ebp)
  8010be:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8010c4:	50                   	push   %eax
  8010c5:	68 5c 10 80 00       	push   $0x80105c
  8010ca:	e8 82 01 00 00       	call   801251 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8010cf:	83 c4 08             	add    $0x8,%esp
  8010d2:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8010d8:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8010de:	50                   	push   %eax
  8010df:	e8 19 f0 ff ff       	call   8000fd <sys_cputs>

	return b.cnt;
}
  8010e4:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8010ea:	c9                   	leave  
  8010eb:	c3                   	ret    

008010ec <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8010ec:	55                   	push   %ebp
  8010ed:	89 e5                	mov    %esp,%ebp
  8010ef:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8010f2:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8010f5:	50                   	push   %eax
  8010f6:	ff 75 08             	pushl  0x8(%ebp)
  8010f9:	e8 9d ff ff ff       	call   80109b <vcprintf>
	va_end(ap);

	return cnt;
}
  8010fe:	c9                   	leave  
  8010ff:	c3                   	ret    

00801100 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  801100:	55                   	push   %ebp
  801101:	89 e5                	mov    %esp,%ebp
  801103:	57                   	push   %edi
  801104:	56                   	push   %esi
  801105:	53                   	push   %ebx
  801106:	83 ec 2c             	sub    $0x2c,%esp
  801109:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80110c:	89 d6                	mov    %edx,%esi
  80110e:	8b 45 08             	mov    0x8(%ebp),%eax
  801111:	8b 55 0c             	mov    0xc(%ebp),%edx
  801114:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801117:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80111a:	8b 45 10             	mov    0x10(%ebp),%eax
  80111d:	8b 5d 14             	mov    0x14(%ebp),%ebx
  801120:	8b 7d 18             	mov    0x18(%ebp),%edi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  801123:	89 45 d0             	mov    %eax,-0x30(%ebp)
  801126:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  80112d:	39 55 d4             	cmp    %edx,-0x2c(%ebp)
  801130:	72 0c                	jb     80113e <printnum+0x3e>
  801132:	3b 45 d8             	cmp    -0x28(%ebp),%eax
  801135:	76 07                	jbe    80113e <printnum+0x3e>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  801137:	4b                   	dec    %ebx
  801138:	85 db                	test   %ebx,%ebx
  80113a:	7f 31                	jg     80116d <printnum+0x6d>
  80113c:	eb 3f                	jmp    80117d <printnum+0x7d>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80113e:	83 ec 0c             	sub    $0xc,%esp
  801141:	57                   	push   %edi
  801142:	4b                   	dec    %ebx
  801143:	53                   	push   %ebx
  801144:	50                   	push   %eax
  801145:	83 ec 08             	sub    $0x8,%esp
  801148:	ff 75 d4             	pushl  -0x2c(%ebp)
  80114b:	ff 75 d0             	pushl  -0x30(%ebp)
  80114e:	ff 75 dc             	pushl  -0x24(%ebp)
  801151:	ff 75 d8             	pushl  -0x28(%ebp)
  801154:	e8 23 0a 00 00       	call   801b7c <__udivdi3>
  801159:	83 c4 18             	add    $0x18,%esp
  80115c:	52                   	push   %edx
  80115d:	50                   	push   %eax
  80115e:	89 f2                	mov    %esi,%edx
  801160:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801163:	e8 98 ff ff ff       	call   801100 <printnum>
  801168:	83 c4 20             	add    $0x20,%esp
  80116b:	eb 10                	jmp    80117d <printnum+0x7d>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80116d:	83 ec 08             	sub    $0x8,%esp
  801170:	56                   	push   %esi
  801171:	57                   	push   %edi
  801172:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  801175:	4b                   	dec    %ebx
  801176:	83 c4 10             	add    $0x10,%esp
  801179:	85 db                	test   %ebx,%ebx
  80117b:	7f f0                	jg     80116d <printnum+0x6d>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80117d:	83 ec 08             	sub    $0x8,%esp
  801180:	56                   	push   %esi
  801181:	83 ec 04             	sub    $0x4,%esp
  801184:	ff 75 d4             	pushl  -0x2c(%ebp)
  801187:	ff 75 d0             	pushl  -0x30(%ebp)
  80118a:	ff 75 dc             	pushl  -0x24(%ebp)
  80118d:	ff 75 d8             	pushl  -0x28(%ebp)
  801190:	e8 03 0b 00 00       	call   801c98 <__umoddi3>
  801195:	83 c4 14             	add    $0x14,%esp
  801198:	0f be 80 27 1f 80 00 	movsbl 0x801f27(%eax),%eax
  80119f:	50                   	push   %eax
  8011a0:	ff 55 e4             	call   *-0x1c(%ebp)
  8011a3:	83 c4 10             	add    $0x10,%esp
}
  8011a6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011a9:	5b                   	pop    %ebx
  8011aa:	5e                   	pop    %esi
  8011ab:	5f                   	pop    %edi
  8011ac:	c9                   	leave  
  8011ad:	c3                   	ret    

008011ae <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8011ae:	55                   	push   %ebp
  8011af:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8011b1:	83 fa 01             	cmp    $0x1,%edx
  8011b4:	7e 0e                	jle    8011c4 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8011b6:	8b 10                	mov    (%eax),%edx
  8011b8:	8d 4a 08             	lea    0x8(%edx),%ecx
  8011bb:	89 08                	mov    %ecx,(%eax)
  8011bd:	8b 02                	mov    (%edx),%eax
  8011bf:	8b 52 04             	mov    0x4(%edx),%edx
  8011c2:	eb 22                	jmp    8011e6 <getuint+0x38>
	else if (lflag)
  8011c4:	85 d2                	test   %edx,%edx
  8011c6:	74 10                	je     8011d8 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8011c8:	8b 10                	mov    (%eax),%edx
  8011ca:	8d 4a 04             	lea    0x4(%edx),%ecx
  8011cd:	89 08                	mov    %ecx,(%eax)
  8011cf:	8b 02                	mov    (%edx),%eax
  8011d1:	ba 00 00 00 00       	mov    $0x0,%edx
  8011d6:	eb 0e                	jmp    8011e6 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8011d8:	8b 10                	mov    (%eax),%edx
  8011da:	8d 4a 04             	lea    0x4(%edx),%ecx
  8011dd:	89 08                	mov    %ecx,(%eax)
  8011df:	8b 02                	mov    (%edx),%eax
  8011e1:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8011e6:	c9                   	leave  
  8011e7:	c3                   	ret    

008011e8 <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
  8011e8:	55                   	push   %ebp
  8011e9:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8011eb:	83 fa 01             	cmp    $0x1,%edx
  8011ee:	7e 0e                	jle    8011fe <getint+0x16>
		return va_arg(*ap, long long);
  8011f0:	8b 10                	mov    (%eax),%edx
  8011f2:	8d 4a 08             	lea    0x8(%edx),%ecx
  8011f5:	89 08                	mov    %ecx,(%eax)
  8011f7:	8b 02                	mov    (%edx),%eax
  8011f9:	8b 52 04             	mov    0x4(%edx),%edx
  8011fc:	eb 1a                	jmp    801218 <getint+0x30>
	else if (lflag)
  8011fe:	85 d2                	test   %edx,%edx
  801200:	74 0c                	je     80120e <getint+0x26>
		return va_arg(*ap, long);
  801202:	8b 10                	mov    (%eax),%edx
  801204:	8d 4a 04             	lea    0x4(%edx),%ecx
  801207:	89 08                	mov    %ecx,(%eax)
  801209:	8b 02                	mov    (%edx),%eax
  80120b:	99                   	cltd   
  80120c:	eb 0a                	jmp    801218 <getint+0x30>
	else
		return va_arg(*ap, int);
  80120e:	8b 10                	mov    (%eax),%edx
  801210:	8d 4a 04             	lea    0x4(%edx),%ecx
  801213:	89 08                	mov    %ecx,(%eax)
  801215:	8b 02                	mov    (%edx),%eax
  801217:	99                   	cltd   
}
  801218:	c9                   	leave  
  801219:	c3                   	ret    

0080121a <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80121a:	55                   	push   %ebp
  80121b:	89 e5                	mov    %esp,%ebp
  80121d:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  801220:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  801223:	8b 10                	mov    (%eax),%edx
  801225:	3b 50 04             	cmp    0x4(%eax),%edx
  801228:	73 08                	jae    801232 <sprintputch+0x18>
		*b->buf++ = ch;
  80122a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80122d:	88 0a                	mov    %cl,(%edx)
  80122f:	42                   	inc    %edx
  801230:	89 10                	mov    %edx,(%eax)
}
  801232:	c9                   	leave  
  801233:	c3                   	ret    

00801234 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  801234:	55                   	push   %ebp
  801235:	89 e5                	mov    %esp,%ebp
  801237:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  80123a:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80123d:	50                   	push   %eax
  80123e:	ff 75 10             	pushl  0x10(%ebp)
  801241:	ff 75 0c             	pushl  0xc(%ebp)
  801244:	ff 75 08             	pushl  0x8(%ebp)
  801247:	e8 05 00 00 00       	call   801251 <vprintfmt>
	va_end(ap);
  80124c:	83 c4 10             	add    $0x10,%esp
}
  80124f:	c9                   	leave  
  801250:	c3                   	ret    

00801251 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  801251:	55                   	push   %ebp
  801252:	89 e5                	mov    %esp,%ebp
  801254:	57                   	push   %edi
  801255:	56                   	push   %esi
  801256:	53                   	push   %ebx
  801257:	83 ec 2c             	sub    $0x2c,%esp
  80125a:	8b 7d 0c             	mov    0xc(%ebp),%edi
  80125d:	8b 75 10             	mov    0x10(%ebp),%esi
  801260:	eb 13                	jmp    801275 <vprintfmt+0x24>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  801262:	85 c0                	test   %eax,%eax
  801264:	0f 84 6d 03 00 00    	je     8015d7 <vprintfmt+0x386>
				return;
			putch(ch, putdat);
  80126a:	83 ec 08             	sub    $0x8,%esp
  80126d:	57                   	push   %edi
  80126e:	50                   	push   %eax
  80126f:	ff 55 08             	call   *0x8(%ebp)
  801272:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  801275:	0f b6 06             	movzbl (%esi),%eax
  801278:	46                   	inc    %esi
  801279:	83 f8 25             	cmp    $0x25,%eax
  80127c:	75 e4                	jne    801262 <vprintfmt+0x11>
  80127e:	c6 45 dc 20          	movb   $0x20,-0x24(%ebp)
  801282:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  801289:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
  801290:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  801297:	b9 00 00 00 00       	mov    $0x0,%ecx
  80129c:	eb 28                	jmp    8012c6 <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80129e:	89 de                	mov    %ebx,%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  8012a0:	c6 45 dc 2d          	movb   $0x2d,-0x24(%ebp)
  8012a4:	eb 20                	jmp    8012c6 <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8012a6:	89 de                	mov    %ebx,%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8012a8:	c6 45 dc 30          	movb   $0x30,-0x24(%ebp)
  8012ac:	eb 18                	jmp    8012c6 <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8012ae:	89 de                	mov    %ebx,%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  8012b0:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  8012b7:	eb 0d                	jmp    8012c6 <vprintfmt+0x75>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  8012b9:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8012bc:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8012bf:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8012c6:	8a 06                	mov    (%esi),%al
  8012c8:	0f b6 d0             	movzbl %al,%edx
  8012cb:	8d 5e 01             	lea    0x1(%esi),%ebx
  8012ce:	83 e8 23             	sub    $0x23,%eax
  8012d1:	3c 55                	cmp    $0x55,%al
  8012d3:	0f 87 e0 02 00 00    	ja     8015b9 <vprintfmt+0x368>
  8012d9:	0f b6 c0             	movzbl %al,%eax
  8012dc:	ff 24 85 60 20 80 00 	jmp    *0x802060(,%eax,4)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8012e3:	83 ea 30             	sub    $0x30,%edx
  8012e6:	89 55 d4             	mov    %edx,-0x2c(%ebp)
				ch = *fmt;
  8012e9:	0f be 03             	movsbl (%ebx),%eax
				if (ch < '0' || ch > '9')
  8012ec:	8d 50 d0             	lea    -0x30(%eax),%edx
  8012ef:	83 fa 09             	cmp    $0x9,%edx
  8012f2:	77 44                	ja     801338 <vprintfmt+0xe7>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8012f4:	89 de                	mov    %ebx,%esi
  8012f6:	8b 55 d4             	mov    -0x2c(%ebp),%edx
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8012f9:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
  8012fa:	8d 14 92             	lea    (%edx,%edx,4),%edx
  8012fd:	8d 54 50 d0          	lea    -0x30(%eax,%edx,2),%edx
				ch = *fmt;
  801301:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  801304:	8d 58 d0             	lea    -0x30(%eax),%ebx
  801307:	83 fb 09             	cmp    $0x9,%ebx
  80130a:	76 ed                	jbe    8012f9 <vprintfmt+0xa8>
  80130c:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  80130f:	eb 29                	jmp    80133a <vprintfmt+0xe9>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  801311:	8b 45 14             	mov    0x14(%ebp),%eax
  801314:	8d 50 04             	lea    0x4(%eax),%edx
  801317:	89 55 14             	mov    %edx,0x14(%ebp)
  80131a:	8b 00                	mov    (%eax),%eax
  80131c:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80131f:	89 de                	mov    %ebx,%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  801321:	eb 17                	jmp    80133a <vprintfmt+0xe9>

		case '.':
			if (width < 0)
  801323:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  801327:	78 85                	js     8012ae <vprintfmt+0x5d>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801329:	89 de                	mov    %ebx,%esi
  80132b:	eb 99                	jmp    8012c6 <vprintfmt+0x75>
  80132d:	89 de                	mov    %ebx,%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  80132f:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
			goto reswitch;
  801336:	eb 8e                	jmp    8012c6 <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801338:	89 de                	mov    %ebx,%esi
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  80133a:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80133e:	79 86                	jns    8012c6 <vprintfmt+0x75>
  801340:	e9 74 ff ff ff       	jmp    8012b9 <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  801345:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801346:	89 de                	mov    %ebx,%esi
  801348:	e9 79 ff ff ff       	jmp    8012c6 <vprintfmt+0x75>
  80134d:	89 5d d8             	mov    %ebx,-0x28(%ebp)
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  801350:	8b 45 14             	mov    0x14(%ebp),%eax
  801353:	8d 50 04             	lea    0x4(%eax),%edx
  801356:	89 55 14             	mov    %edx,0x14(%ebp)
  801359:	83 ec 08             	sub    $0x8,%esp
  80135c:	57                   	push   %edi
  80135d:	ff 30                	pushl  (%eax)
  80135f:	ff 55 08             	call   *0x8(%ebp)
			break;
  801362:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801365:	8b 75 d8             	mov    -0x28(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  801368:	e9 08 ff ff ff       	jmp    801275 <vprintfmt+0x24>
  80136d:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// error message
		case 'e':
			err = va_arg(ap, int);
  801370:	8b 45 14             	mov    0x14(%ebp),%eax
  801373:	8d 50 04             	lea    0x4(%eax),%edx
  801376:	89 55 14             	mov    %edx,0x14(%ebp)
  801379:	8b 00                	mov    (%eax),%eax
  80137b:	85 c0                	test   %eax,%eax
  80137d:	79 02                	jns    801381 <vprintfmt+0x130>
  80137f:	f7 d8                	neg    %eax
  801381:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  801383:	83 f8 0f             	cmp    $0xf,%eax
  801386:	7f 0b                	jg     801393 <vprintfmt+0x142>
  801388:	8b 04 85 c0 21 80 00 	mov    0x8021c0(,%eax,4),%eax
  80138f:	85 c0                	test   %eax,%eax
  801391:	75 1a                	jne    8013ad <vprintfmt+0x15c>
				printfmt(putch, putdat, "error %d", err);
  801393:	52                   	push   %edx
  801394:	68 3f 1f 80 00       	push   $0x801f3f
  801399:	57                   	push   %edi
  80139a:	ff 75 08             	pushl  0x8(%ebp)
  80139d:	e8 92 fe ff ff       	call   801234 <printfmt>
  8013a2:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8013a5:	8b 75 d8             	mov    -0x28(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8013a8:	e9 c8 fe ff ff       	jmp    801275 <vprintfmt+0x24>
			else
				printfmt(putch, putdat, "%s", p);
  8013ad:	50                   	push   %eax
  8013ae:	68 bd 1e 80 00       	push   $0x801ebd
  8013b3:	57                   	push   %edi
  8013b4:	ff 75 08             	pushl  0x8(%ebp)
  8013b7:	e8 78 fe ff ff       	call   801234 <printfmt>
  8013bc:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8013bf:	8b 75 d8             	mov    -0x28(%ebp),%esi
  8013c2:	e9 ae fe ff ff       	jmp    801275 <vprintfmt+0x24>
  8013c7:	89 5d d8             	mov    %ebx,-0x28(%ebp)
  8013ca:	89 de                	mov    %ebx,%esi
  8013cc:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  8013cf:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8013d2:	8b 45 14             	mov    0x14(%ebp),%eax
  8013d5:	8d 50 04             	lea    0x4(%eax),%edx
  8013d8:	89 55 14             	mov    %edx,0x14(%ebp)
  8013db:	8b 00                	mov    (%eax),%eax
  8013dd:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8013e0:	85 c0                	test   %eax,%eax
  8013e2:	75 07                	jne    8013eb <vprintfmt+0x19a>
				p = "(null)";
  8013e4:	c7 45 d0 38 1f 80 00 	movl   $0x801f38,-0x30(%ebp)
			if (width > 0 && padc != '-')
  8013eb:	85 db                	test   %ebx,%ebx
  8013ed:	7e 42                	jle    801431 <vprintfmt+0x1e0>
  8013ef:	80 7d dc 2d          	cmpb   $0x2d,-0x24(%ebp)
  8013f3:	74 3c                	je     801431 <vprintfmt+0x1e0>
				for (width -= strnlen(p, precision); width > 0; width--)
  8013f5:	83 ec 08             	sub    $0x8,%esp
  8013f8:	51                   	push   %ecx
  8013f9:	ff 75 d0             	pushl  -0x30(%ebp)
  8013fc:	e8 6f 02 00 00       	call   801670 <strnlen>
  801401:	29 c3                	sub    %eax,%ebx
  801403:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  801406:	83 c4 10             	add    $0x10,%esp
  801409:	85 db                	test   %ebx,%ebx
  80140b:	7e 24                	jle    801431 <vprintfmt+0x1e0>
					putch(padc, putdat);
  80140d:	0f be 5d dc          	movsbl -0x24(%ebp),%ebx
  801411:	89 75 dc             	mov    %esi,-0x24(%ebp)
  801414:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  801417:	83 ec 08             	sub    $0x8,%esp
  80141a:	57                   	push   %edi
  80141b:	53                   	push   %ebx
  80141c:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80141f:	4e                   	dec    %esi
  801420:	83 c4 10             	add    $0x10,%esp
  801423:	85 f6                	test   %esi,%esi
  801425:	7f f0                	jg     801417 <vprintfmt+0x1c6>
  801427:	8b 75 dc             	mov    -0x24(%ebp),%esi
  80142a:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  801431:	8b 55 d0             	mov    -0x30(%ebp),%edx
  801434:	0f be 02             	movsbl (%edx),%eax
  801437:	85 c0                	test   %eax,%eax
  801439:	75 47                	jne    801482 <vprintfmt+0x231>
  80143b:	eb 37                	jmp    801474 <vprintfmt+0x223>
				if (altflag && (ch < ' ' || ch > '~'))
  80143d:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  801441:	74 16                	je     801459 <vprintfmt+0x208>
  801443:	8d 50 e0             	lea    -0x20(%eax),%edx
  801446:	83 fa 5e             	cmp    $0x5e,%edx
  801449:	76 0e                	jbe    801459 <vprintfmt+0x208>
					putch('?', putdat);
  80144b:	83 ec 08             	sub    $0x8,%esp
  80144e:	57                   	push   %edi
  80144f:	6a 3f                	push   $0x3f
  801451:	ff 55 08             	call   *0x8(%ebp)
  801454:	83 c4 10             	add    $0x10,%esp
  801457:	eb 0b                	jmp    801464 <vprintfmt+0x213>
				else
					putch(ch, putdat);
  801459:	83 ec 08             	sub    $0x8,%esp
  80145c:	57                   	push   %edi
  80145d:	50                   	push   %eax
  80145e:	ff 55 08             	call   *0x8(%ebp)
  801461:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  801464:	ff 4d e4             	decl   -0x1c(%ebp)
  801467:	0f be 03             	movsbl (%ebx),%eax
  80146a:	85 c0                	test   %eax,%eax
  80146c:	74 03                	je     801471 <vprintfmt+0x220>
  80146e:	43                   	inc    %ebx
  80146f:	eb 1b                	jmp    80148c <vprintfmt+0x23b>
  801471:	8b 75 dc             	mov    -0x24(%ebp),%esi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  801474:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  801478:	7f 1e                	jg     801498 <vprintfmt+0x247>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80147a:	8b 75 d8             	mov    -0x28(%ebp),%esi
  80147d:	e9 f3 fd ff ff       	jmp    801275 <vprintfmt+0x24>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  801482:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  801485:	43                   	inc    %ebx
  801486:	89 75 dc             	mov    %esi,-0x24(%ebp)
  801489:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  80148c:	85 f6                	test   %esi,%esi
  80148e:	78 ad                	js     80143d <vprintfmt+0x1ec>
  801490:	4e                   	dec    %esi
  801491:	79 aa                	jns    80143d <vprintfmt+0x1ec>
  801493:	8b 75 dc             	mov    -0x24(%ebp),%esi
  801496:	eb dc                	jmp    801474 <vprintfmt+0x223>
  801498:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80149b:	83 ec 08             	sub    $0x8,%esp
  80149e:	57                   	push   %edi
  80149f:	6a 20                	push   $0x20
  8014a1:	ff 55 08             	call   *0x8(%ebp)
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8014a4:	4b                   	dec    %ebx
  8014a5:	83 c4 10             	add    $0x10,%esp
  8014a8:	85 db                	test   %ebx,%ebx
  8014aa:	7f ef                	jg     80149b <vprintfmt+0x24a>
  8014ac:	e9 c4 fd ff ff       	jmp    801275 <vprintfmt+0x24>
  8014b1:	89 5d d8             	mov    %ebx,-0x28(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8014b4:	89 ca                	mov    %ecx,%edx
  8014b6:	8d 45 14             	lea    0x14(%ebp),%eax
  8014b9:	e8 2a fd ff ff       	call   8011e8 <getint>
  8014be:	89 c3                	mov    %eax,%ebx
  8014c0:	89 d6                	mov    %edx,%esi
			if ((long long) num < 0) {
  8014c2:	85 d2                	test   %edx,%edx
  8014c4:	78 0a                	js     8014d0 <vprintfmt+0x27f>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8014c6:	b8 0a 00 00 00       	mov    $0xa,%eax
  8014cb:	e9 b0 00 00 00       	jmp    801580 <vprintfmt+0x32f>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  8014d0:	83 ec 08             	sub    $0x8,%esp
  8014d3:	57                   	push   %edi
  8014d4:	6a 2d                	push   $0x2d
  8014d6:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  8014d9:	f7 db                	neg    %ebx
  8014db:	83 d6 00             	adc    $0x0,%esi
  8014de:	f7 de                	neg    %esi
  8014e0:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  8014e3:	b8 0a 00 00 00       	mov    $0xa,%eax
  8014e8:	e9 93 00 00 00       	jmp    801580 <vprintfmt+0x32f>
  8014ed:	89 5d d8             	mov    %ebx,-0x28(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8014f0:	89 ca                	mov    %ecx,%edx
  8014f2:	8d 45 14             	lea    0x14(%ebp),%eax
  8014f5:	e8 b4 fc ff ff       	call   8011ae <getuint>
  8014fa:	89 c3                	mov    %eax,%ebx
  8014fc:	89 d6                	mov    %edx,%esi
			base = 10;
  8014fe:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  801503:	eb 7b                	jmp    801580 <vprintfmt+0x32f>
  801505:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// (unsigned) octal
		case 'o':
            // (MIT 6.828, lab1, Ex.8)  my code : 
            num = getint(&ap, lflag);
  801508:	89 ca                	mov    %ecx,%edx
  80150a:	8d 45 14             	lea    0x14(%ebp),%eax
  80150d:	e8 d6 fc ff ff       	call   8011e8 <getint>
  801512:	89 c3                	mov    %eax,%ebx
  801514:	89 d6                	mov    %edx,%esi
            if ((long long) num < 0) {
  801516:	85 d2                	test   %edx,%edx
  801518:	78 07                	js     801521 <vprintfmt+0x2d0>
                putch('-', putdat);
                num = -(long long) num;
            }
            base = 8;
  80151a:	b8 08 00 00 00       	mov    $0x8,%eax
  80151f:	eb 5f                	jmp    801580 <vprintfmt+0x32f>
		// (unsigned) octal
		case 'o':
            // (MIT 6.828, lab1, Ex.8)  my code : 
            num = getint(&ap, lflag);
            if ((long long) num < 0) {
                putch('-', putdat);
  801521:	83 ec 08             	sub    $0x8,%esp
  801524:	57                   	push   %edi
  801525:	6a 2d                	push   $0x2d
  801527:	ff 55 08             	call   *0x8(%ebp)
                num = -(long long) num;
  80152a:	f7 db                	neg    %ebx
  80152c:	83 d6 00             	adc    $0x0,%esi
  80152f:	f7 de                	neg    %esi
  801531:	83 c4 10             	add    $0x10,%esp
            }
            base = 8;
  801534:	b8 08 00 00 00       	mov    $0x8,%eax
  801539:	eb 45                	jmp    801580 <vprintfmt+0x32f>
  80153b:	89 5d d8             	mov    %ebx,-0x28(%ebp)
            goto number;

        // pointer
		case 'p':
			putch('0', putdat);
  80153e:	83 ec 08             	sub    $0x8,%esp
  801541:	57                   	push   %edi
  801542:	6a 30                	push   $0x30
  801544:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  801547:	83 c4 08             	add    $0x8,%esp
  80154a:	57                   	push   %edi
  80154b:	6a 78                	push   $0x78
  80154d:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  801550:	8b 45 14             	mov    0x14(%ebp),%eax
  801553:	8d 50 04             	lea    0x4(%eax),%edx
  801556:	89 55 14             	mov    %edx,0x14(%ebp)

        // pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  801559:	8b 18                	mov    (%eax),%ebx
  80155b:	be 00 00 00 00       	mov    $0x0,%esi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  801560:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  801563:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  801568:	eb 16                	jmp    801580 <vprintfmt+0x32f>
  80156a:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  80156d:	89 ca                	mov    %ecx,%edx
  80156f:	8d 45 14             	lea    0x14(%ebp),%eax
  801572:	e8 37 fc ff ff       	call   8011ae <getuint>
  801577:	89 c3                	mov    %eax,%ebx
  801579:	89 d6                	mov    %edx,%esi
			base = 16;
  80157b:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  801580:	83 ec 0c             	sub    $0xc,%esp
  801583:	0f be 55 dc          	movsbl -0x24(%ebp),%edx
  801587:	52                   	push   %edx
  801588:	ff 75 e4             	pushl  -0x1c(%ebp)
  80158b:	50                   	push   %eax
  80158c:	56                   	push   %esi
  80158d:	53                   	push   %ebx
  80158e:	89 fa                	mov    %edi,%edx
  801590:	8b 45 08             	mov    0x8(%ebp),%eax
  801593:	e8 68 fb ff ff       	call   801100 <printnum>
			break;
  801598:	83 c4 20             	add    $0x20,%esp
  80159b:	8b 75 d8             	mov    -0x28(%ebp),%esi
  80159e:	e9 d2 fc ff ff       	jmp    801275 <vprintfmt+0x24>
  8015a3:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8015a6:	83 ec 08             	sub    $0x8,%esp
  8015a9:	57                   	push   %edi
  8015aa:	52                   	push   %edx
  8015ab:	ff 55 08             	call   *0x8(%ebp)
			break;
  8015ae:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8015b1:	8b 75 d8             	mov    -0x28(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8015b4:	e9 bc fc ff ff       	jmp    801275 <vprintfmt+0x24>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8015b9:	83 ec 08             	sub    $0x8,%esp
  8015bc:	57                   	push   %edi
  8015bd:	6a 25                	push   $0x25
  8015bf:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  8015c2:	83 c4 10             	add    $0x10,%esp
  8015c5:	eb 02                	jmp    8015c9 <vprintfmt+0x378>
  8015c7:	89 c6                	mov    %eax,%esi
  8015c9:	8d 46 ff             	lea    -0x1(%esi),%eax
  8015cc:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  8015d0:	75 f5                	jne    8015c7 <vprintfmt+0x376>
  8015d2:	e9 9e fc ff ff       	jmp    801275 <vprintfmt+0x24>
				/* do nothing */;
			break;
		}
	}
}
  8015d7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8015da:	5b                   	pop    %ebx
  8015db:	5e                   	pop    %esi
  8015dc:	5f                   	pop    %edi
  8015dd:	c9                   	leave  
  8015de:	c3                   	ret    

008015df <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8015df:	55                   	push   %ebp
  8015e0:	89 e5                	mov    %esp,%ebp
  8015e2:	83 ec 18             	sub    $0x18,%esp
  8015e5:	8b 45 08             	mov    0x8(%ebp),%eax
  8015e8:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8015eb:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8015ee:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8015f2:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8015f5:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8015fc:	85 c0                	test   %eax,%eax
  8015fe:	74 26                	je     801626 <vsnprintf+0x47>
  801600:	85 d2                	test   %edx,%edx
  801602:	7e 29                	jle    80162d <vsnprintf+0x4e>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  801604:	ff 75 14             	pushl  0x14(%ebp)
  801607:	ff 75 10             	pushl  0x10(%ebp)
  80160a:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80160d:	50                   	push   %eax
  80160e:	68 1a 12 80 00       	push   $0x80121a
  801613:	e8 39 fc ff ff       	call   801251 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  801618:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80161b:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80161e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801621:	83 c4 10             	add    $0x10,%esp
  801624:	eb 0c                	jmp    801632 <vsnprintf+0x53>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  801626:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80162b:	eb 05                	jmp    801632 <vsnprintf+0x53>
  80162d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  801632:	c9                   	leave  
  801633:	c3                   	ret    

00801634 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  801634:	55                   	push   %ebp
  801635:	89 e5                	mov    %esp,%ebp
  801637:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80163a:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80163d:	50                   	push   %eax
  80163e:	ff 75 10             	pushl  0x10(%ebp)
  801641:	ff 75 0c             	pushl  0xc(%ebp)
  801644:	ff 75 08             	pushl  0x8(%ebp)
  801647:	e8 93 ff ff ff       	call   8015df <vsnprintf>
	va_end(ap);

	return rc;
}
  80164c:	c9                   	leave  
  80164d:	c3                   	ret    
	...

00801650 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  801650:	55                   	push   %ebp
  801651:	89 e5                	mov    %esp,%ebp
  801653:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  801656:	80 3a 00             	cmpb   $0x0,(%edx)
  801659:	74 0e                	je     801669 <strlen+0x19>
  80165b:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  801660:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  801661:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  801665:	75 f9                	jne    801660 <strlen+0x10>
  801667:	eb 05                	jmp    80166e <strlen+0x1e>
  801669:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  80166e:	c9                   	leave  
  80166f:	c3                   	ret    

00801670 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  801670:	55                   	push   %ebp
  801671:	89 e5                	mov    %esp,%ebp
  801673:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801676:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801679:	85 d2                	test   %edx,%edx
  80167b:	74 17                	je     801694 <strnlen+0x24>
  80167d:	80 39 00             	cmpb   $0x0,(%ecx)
  801680:	74 19                	je     80169b <strnlen+0x2b>
  801682:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  801687:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801688:	39 d0                	cmp    %edx,%eax
  80168a:	74 14                	je     8016a0 <strnlen+0x30>
  80168c:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  801690:	75 f5                	jne    801687 <strnlen+0x17>
  801692:	eb 0c                	jmp    8016a0 <strnlen+0x30>
  801694:	b8 00 00 00 00       	mov    $0x0,%eax
  801699:	eb 05                	jmp    8016a0 <strnlen+0x30>
  80169b:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  8016a0:	c9                   	leave  
  8016a1:	c3                   	ret    

008016a2 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8016a2:	55                   	push   %ebp
  8016a3:	89 e5                	mov    %esp,%ebp
  8016a5:	53                   	push   %ebx
  8016a6:	8b 45 08             	mov    0x8(%ebp),%eax
  8016a9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8016ac:	ba 00 00 00 00       	mov    $0x0,%edx
  8016b1:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  8016b4:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  8016b7:	42                   	inc    %edx
  8016b8:	84 c9                	test   %cl,%cl
  8016ba:	75 f5                	jne    8016b1 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  8016bc:	5b                   	pop    %ebx
  8016bd:	c9                   	leave  
  8016be:	c3                   	ret    

008016bf <strcat>:

char *
strcat(char *dst, const char *src)
{
  8016bf:	55                   	push   %ebp
  8016c0:	89 e5                	mov    %esp,%ebp
  8016c2:	53                   	push   %ebx
  8016c3:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8016c6:	53                   	push   %ebx
  8016c7:	e8 84 ff ff ff       	call   801650 <strlen>
  8016cc:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8016cf:	ff 75 0c             	pushl  0xc(%ebp)
  8016d2:	8d 04 03             	lea    (%ebx,%eax,1),%eax
  8016d5:	50                   	push   %eax
  8016d6:	e8 c7 ff ff ff       	call   8016a2 <strcpy>
	return dst;
}
  8016db:	89 d8                	mov    %ebx,%eax
  8016dd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016e0:	c9                   	leave  
  8016e1:	c3                   	ret    

008016e2 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8016e2:	55                   	push   %ebp
  8016e3:	89 e5                	mov    %esp,%ebp
  8016e5:	56                   	push   %esi
  8016e6:	53                   	push   %ebx
  8016e7:	8b 45 08             	mov    0x8(%ebp),%eax
  8016ea:	8b 55 0c             	mov    0xc(%ebp),%edx
  8016ed:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8016f0:	85 f6                	test   %esi,%esi
  8016f2:	74 15                	je     801709 <strncpy+0x27>
  8016f4:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
  8016f9:	8a 1a                	mov    (%edx),%bl
  8016fb:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8016fe:	80 3a 01             	cmpb   $0x1,(%edx)
  801701:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801704:	41                   	inc    %ecx
  801705:	39 ce                	cmp    %ecx,%esi
  801707:	77 f0                	ja     8016f9 <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  801709:	5b                   	pop    %ebx
  80170a:	5e                   	pop    %esi
  80170b:	c9                   	leave  
  80170c:	c3                   	ret    

0080170d <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80170d:	55                   	push   %ebp
  80170e:	89 e5                	mov    %esp,%ebp
  801710:	57                   	push   %edi
  801711:	56                   	push   %esi
  801712:	53                   	push   %ebx
  801713:	8b 7d 08             	mov    0x8(%ebp),%edi
  801716:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801719:	8b 75 10             	mov    0x10(%ebp),%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80171c:	85 f6                	test   %esi,%esi
  80171e:	74 32                	je     801752 <strlcpy+0x45>
		while (--size > 0 && *src != '\0')
  801720:	83 fe 01             	cmp    $0x1,%esi
  801723:	74 22                	je     801747 <strlcpy+0x3a>
  801725:	8a 0b                	mov    (%ebx),%cl
  801727:	84 c9                	test   %cl,%cl
  801729:	74 20                	je     80174b <strlcpy+0x3e>
  80172b:	89 f8                	mov    %edi,%eax
  80172d:	ba 00 00 00 00       	mov    $0x0,%edx
	}
	return ret;
}

size_t
strlcpy(char *dst, const char *src, size_t size)
  801732:	83 ee 02             	sub    $0x2,%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  801735:	88 08                	mov    %cl,(%eax)
  801737:	40                   	inc    %eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  801738:	39 f2                	cmp    %esi,%edx
  80173a:	74 11                	je     80174d <strlcpy+0x40>
  80173c:	8a 4c 13 01          	mov    0x1(%ebx,%edx,1),%cl
  801740:	42                   	inc    %edx
  801741:	84 c9                	test   %cl,%cl
  801743:	75 f0                	jne    801735 <strlcpy+0x28>
  801745:	eb 06                	jmp    80174d <strlcpy+0x40>
  801747:	89 f8                	mov    %edi,%eax
  801749:	eb 02                	jmp    80174d <strlcpy+0x40>
  80174b:	89 f8                	mov    %edi,%eax
			*dst++ = *src++;
		*dst = '\0';
  80174d:	c6 00 00             	movb   $0x0,(%eax)
  801750:	eb 02                	jmp    801754 <strlcpy+0x47>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  801752:	89 f8                	mov    %edi,%eax
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
		*dst = '\0';
	}
	return dst - dst_in;
  801754:	29 f8                	sub    %edi,%eax
}
  801756:	5b                   	pop    %ebx
  801757:	5e                   	pop    %esi
  801758:	5f                   	pop    %edi
  801759:	c9                   	leave  
  80175a:	c3                   	ret    

0080175b <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80175b:	55                   	push   %ebp
  80175c:	89 e5                	mov    %esp,%ebp
  80175e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801761:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  801764:	8a 01                	mov    (%ecx),%al
  801766:	84 c0                	test   %al,%al
  801768:	74 10                	je     80177a <strcmp+0x1f>
  80176a:	3a 02                	cmp    (%edx),%al
  80176c:	75 0c                	jne    80177a <strcmp+0x1f>
		p++, q++;
  80176e:	41                   	inc    %ecx
  80176f:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  801770:	8a 01                	mov    (%ecx),%al
  801772:	84 c0                	test   %al,%al
  801774:	74 04                	je     80177a <strcmp+0x1f>
  801776:	3a 02                	cmp    (%edx),%al
  801778:	74 f4                	je     80176e <strcmp+0x13>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  80177a:	0f b6 c0             	movzbl %al,%eax
  80177d:	0f b6 12             	movzbl (%edx),%edx
  801780:	29 d0                	sub    %edx,%eax
}
  801782:	c9                   	leave  
  801783:	c3                   	ret    

00801784 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  801784:	55                   	push   %ebp
  801785:	89 e5                	mov    %esp,%ebp
  801787:	53                   	push   %ebx
  801788:	8b 55 08             	mov    0x8(%ebp),%edx
  80178b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80178e:	8b 45 10             	mov    0x10(%ebp),%eax
	while (n > 0 && *p && *p == *q)
  801791:	85 c0                	test   %eax,%eax
  801793:	74 1b                	je     8017b0 <strncmp+0x2c>
  801795:	8a 1a                	mov    (%edx),%bl
  801797:	84 db                	test   %bl,%bl
  801799:	74 24                	je     8017bf <strncmp+0x3b>
  80179b:	3a 19                	cmp    (%ecx),%bl
  80179d:	75 20                	jne    8017bf <strncmp+0x3b>
  80179f:	48                   	dec    %eax
  8017a0:	74 15                	je     8017b7 <strncmp+0x33>
		n--, p++, q++;
  8017a2:	42                   	inc    %edx
  8017a3:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8017a4:	8a 1a                	mov    (%edx),%bl
  8017a6:	84 db                	test   %bl,%bl
  8017a8:	74 15                	je     8017bf <strncmp+0x3b>
  8017aa:	3a 19                	cmp    (%ecx),%bl
  8017ac:	74 f1                	je     80179f <strncmp+0x1b>
  8017ae:	eb 0f                	jmp    8017bf <strncmp+0x3b>
		n--, p++, q++;
	if (n == 0)
		return 0;
  8017b0:	b8 00 00 00 00       	mov    $0x0,%eax
  8017b5:	eb 05                	jmp    8017bc <strncmp+0x38>
  8017b7:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8017bc:	5b                   	pop    %ebx
  8017bd:	c9                   	leave  
  8017be:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8017bf:	0f b6 02             	movzbl (%edx),%eax
  8017c2:	0f b6 11             	movzbl (%ecx),%edx
  8017c5:	29 d0                	sub    %edx,%eax
  8017c7:	eb f3                	jmp    8017bc <strncmp+0x38>

008017c9 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8017c9:	55                   	push   %ebp
  8017ca:	89 e5                	mov    %esp,%ebp
  8017cc:	8b 45 08             	mov    0x8(%ebp),%eax
  8017cf:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  8017d2:	8a 10                	mov    (%eax),%dl
  8017d4:	84 d2                	test   %dl,%dl
  8017d6:	74 18                	je     8017f0 <strchr+0x27>
		if (*s == c)
  8017d8:	38 ca                	cmp    %cl,%dl
  8017da:	75 06                	jne    8017e2 <strchr+0x19>
  8017dc:	eb 17                	jmp    8017f5 <strchr+0x2c>
  8017de:	38 ca                	cmp    %cl,%dl
  8017e0:	74 13                	je     8017f5 <strchr+0x2c>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8017e2:	40                   	inc    %eax
  8017e3:	8a 10                	mov    (%eax),%dl
  8017e5:	84 d2                	test   %dl,%dl
  8017e7:	75 f5                	jne    8017de <strchr+0x15>
		if (*s == c)
			return (char *) s;
	return 0;
  8017e9:	b8 00 00 00 00       	mov    $0x0,%eax
  8017ee:	eb 05                	jmp    8017f5 <strchr+0x2c>
  8017f0:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8017f5:	c9                   	leave  
  8017f6:	c3                   	ret    

008017f7 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8017f7:	55                   	push   %ebp
  8017f8:	89 e5                	mov    %esp,%ebp
  8017fa:	8b 45 08             	mov    0x8(%ebp),%eax
  8017fd:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  801800:	8a 10                	mov    (%eax),%dl
  801802:	84 d2                	test   %dl,%dl
  801804:	74 11                	je     801817 <strfind+0x20>
		if (*s == c)
  801806:	38 ca                	cmp    %cl,%dl
  801808:	75 06                	jne    801810 <strfind+0x19>
  80180a:	eb 0b                	jmp    801817 <strfind+0x20>
  80180c:	38 ca                	cmp    %cl,%dl
  80180e:	74 07                	je     801817 <strfind+0x20>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  801810:	40                   	inc    %eax
  801811:	8a 10                	mov    (%eax),%dl
  801813:	84 d2                	test   %dl,%dl
  801815:	75 f5                	jne    80180c <strfind+0x15>
		if (*s == c)
			break;
	return (char *) s;
}
  801817:	c9                   	leave  
  801818:	c3                   	ret    

00801819 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  801819:	55                   	push   %ebp
  80181a:	89 e5                	mov    %esp,%ebp
  80181c:	57                   	push   %edi
  80181d:	56                   	push   %esi
  80181e:	53                   	push   %ebx
  80181f:	8b 7d 08             	mov    0x8(%ebp),%edi
  801822:	8b 45 0c             	mov    0xc(%ebp),%eax
  801825:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  801828:	85 c9                	test   %ecx,%ecx
  80182a:	74 30                	je     80185c <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  80182c:	f7 c7 03 00 00 00    	test   $0x3,%edi
  801832:	75 25                	jne    801859 <memset+0x40>
  801834:	f6 c1 03             	test   $0x3,%cl
  801837:	75 20                	jne    801859 <memset+0x40>
		c &= 0xFF;
  801839:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  80183c:	89 d3                	mov    %edx,%ebx
  80183e:	c1 e3 08             	shl    $0x8,%ebx
  801841:	89 d6                	mov    %edx,%esi
  801843:	c1 e6 18             	shl    $0x18,%esi
  801846:	89 d0                	mov    %edx,%eax
  801848:	c1 e0 10             	shl    $0x10,%eax
  80184b:	09 f0                	or     %esi,%eax
  80184d:	09 d0                	or     %edx,%eax
  80184f:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  801851:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  801854:	fc                   	cld    
  801855:	f3 ab                	rep stos %eax,%es:(%edi)
  801857:	eb 03                	jmp    80185c <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  801859:	fc                   	cld    
  80185a:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  80185c:	89 f8                	mov    %edi,%eax
  80185e:	5b                   	pop    %ebx
  80185f:	5e                   	pop    %esi
  801860:	5f                   	pop    %edi
  801861:	c9                   	leave  
  801862:	c3                   	ret    

00801863 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  801863:	55                   	push   %ebp
  801864:	89 e5                	mov    %esp,%ebp
  801866:	57                   	push   %edi
  801867:	56                   	push   %esi
  801868:	8b 45 08             	mov    0x8(%ebp),%eax
  80186b:	8b 75 0c             	mov    0xc(%ebp),%esi
  80186e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  801871:	39 c6                	cmp    %eax,%esi
  801873:	73 34                	jae    8018a9 <memmove+0x46>
  801875:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  801878:	39 d0                	cmp    %edx,%eax
  80187a:	73 2d                	jae    8018a9 <memmove+0x46>
		s += n;
		d += n;
  80187c:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80187f:	f6 c2 03             	test   $0x3,%dl
  801882:	75 1b                	jne    80189f <memmove+0x3c>
  801884:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80188a:	75 13                	jne    80189f <memmove+0x3c>
  80188c:	f6 c1 03             	test   $0x3,%cl
  80188f:	75 0e                	jne    80189f <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  801891:	83 ef 04             	sub    $0x4,%edi
  801894:	8d 72 fc             	lea    -0x4(%edx),%esi
  801897:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  80189a:	fd                   	std    
  80189b:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80189d:	eb 07                	jmp    8018a6 <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  80189f:	4f                   	dec    %edi
  8018a0:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8018a3:	fd                   	std    
  8018a4:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8018a6:	fc                   	cld    
  8018a7:	eb 20                	jmp    8018c9 <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8018a9:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8018af:	75 13                	jne    8018c4 <memmove+0x61>
  8018b1:	a8 03                	test   $0x3,%al
  8018b3:	75 0f                	jne    8018c4 <memmove+0x61>
  8018b5:	f6 c1 03             	test   $0x3,%cl
  8018b8:	75 0a                	jne    8018c4 <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  8018ba:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  8018bd:	89 c7                	mov    %eax,%edi
  8018bf:	fc                   	cld    
  8018c0:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8018c2:	eb 05                	jmp    8018c9 <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8018c4:	89 c7                	mov    %eax,%edi
  8018c6:	fc                   	cld    
  8018c7:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8018c9:	5e                   	pop    %esi
  8018ca:	5f                   	pop    %edi
  8018cb:	c9                   	leave  
  8018cc:	c3                   	ret    

008018cd <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8018cd:	55                   	push   %ebp
  8018ce:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  8018d0:	ff 75 10             	pushl  0x10(%ebp)
  8018d3:	ff 75 0c             	pushl  0xc(%ebp)
  8018d6:	ff 75 08             	pushl  0x8(%ebp)
  8018d9:	e8 85 ff ff ff       	call   801863 <memmove>
}
  8018de:	c9                   	leave  
  8018df:	c3                   	ret    

008018e0 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8018e0:	55                   	push   %ebp
  8018e1:	89 e5                	mov    %esp,%ebp
  8018e3:	57                   	push   %edi
  8018e4:	56                   	push   %esi
  8018e5:	53                   	push   %ebx
  8018e6:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8018e9:	8b 75 0c             	mov    0xc(%ebp),%esi
  8018ec:	8b 7d 10             	mov    0x10(%ebp),%edi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8018ef:	85 ff                	test   %edi,%edi
  8018f1:	74 32                	je     801925 <memcmp+0x45>
		if (*s1 != *s2)
  8018f3:	8a 03                	mov    (%ebx),%al
  8018f5:	8a 0e                	mov    (%esi),%cl
  8018f7:	38 c8                	cmp    %cl,%al
  8018f9:	74 19                	je     801914 <memcmp+0x34>
  8018fb:	eb 0d                	jmp    80190a <memcmp+0x2a>
  8018fd:	8a 44 13 01          	mov    0x1(%ebx,%edx,1),%al
  801901:	8a 4c 16 01          	mov    0x1(%esi,%edx,1),%cl
  801905:	42                   	inc    %edx
  801906:	38 c8                	cmp    %cl,%al
  801908:	74 10                	je     80191a <memcmp+0x3a>
			return (int) *s1 - (int) *s2;
  80190a:	0f b6 c0             	movzbl %al,%eax
  80190d:	0f b6 c9             	movzbl %cl,%ecx
  801910:	29 c8                	sub    %ecx,%eax
  801912:	eb 16                	jmp    80192a <memcmp+0x4a>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801914:	4f                   	dec    %edi
  801915:	ba 00 00 00 00       	mov    $0x0,%edx
  80191a:	39 fa                	cmp    %edi,%edx
  80191c:	75 df                	jne    8018fd <memcmp+0x1d>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  80191e:	b8 00 00 00 00       	mov    $0x0,%eax
  801923:	eb 05                	jmp    80192a <memcmp+0x4a>
  801925:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80192a:	5b                   	pop    %ebx
  80192b:	5e                   	pop    %esi
  80192c:	5f                   	pop    %edi
  80192d:	c9                   	leave  
  80192e:	c3                   	ret    

0080192f <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  80192f:	55                   	push   %ebp
  801930:	89 e5                	mov    %esp,%ebp
  801932:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  801935:	89 c2                	mov    %eax,%edx
  801937:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  80193a:	39 d0                	cmp    %edx,%eax
  80193c:	73 12                	jae    801950 <memfind+0x21>
		if (*(const unsigned char *) s == (unsigned char) c)
  80193e:	8a 4d 0c             	mov    0xc(%ebp),%cl
  801941:	38 08                	cmp    %cl,(%eax)
  801943:	75 06                	jne    80194b <memfind+0x1c>
  801945:	eb 09                	jmp    801950 <memfind+0x21>
  801947:	38 08                	cmp    %cl,(%eax)
  801949:	74 05                	je     801950 <memfind+0x21>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  80194b:	40                   	inc    %eax
  80194c:	39 c2                	cmp    %eax,%edx
  80194e:	77 f7                	ja     801947 <memfind+0x18>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  801950:	c9                   	leave  
  801951:	c3                   	ret    

00801952 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  801952:	55                   	push   %ebp
  801953:	89 e5                	mov    %esp,%ebp
  801955:	57                   	push   %edi
  801956:	56                   	push   %esi
  801957:	53                   	push   %ebx
  801958:	8b 55 08             	mov    0x8(%ebp),%edx
  80195b:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  80195e:	eb 01                	jmp    801961 <strtol+0xf>
		s++;
  801960:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801961:	8a 02                	mov    (%edx),%al
  801963:	3c 20                	cmp    $0x20,%al
  801965:	74 f9                	je     801960 <strtol+0xe>
  801967:	3c 09                	cmp    $0x9,%al
  801969:	74 f5                	je     801960 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  80196b:	3c 2b                	cmp    $0x2b,%al
  80196d:	75 08                	jne    801977 <strtol+0x25>
		s++;
  80196f:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  801970:	bf 00 00 00 00       	mov    $0x0,%edi
  801975:	eb 13                	jmp    80198a <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  801977:	3c 2d                	cmp    $0x2d,%al
  801979:	75 0a                	jne    801985 <strtol+0x33>
		s++, neg = 1;
  80197b:	8d 52 01             	lea    0x1(%edx),%edx
  80197e:	bf 01 00 00 00       	mov    $0x1,%edi
  801983:	eb 05                	jmp    80198a <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  801985:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  80198a:	85 db                	test   %ebx,%ebx
  80198c:	74 05                	je     801993 <strtol+0x41>
  80198e:	83 fb 10             	cmp    $0x10,%ebx
  801991:	75 28                	jne    8019bb <strtol+0x69>
  801993:	8a 02                	mov    (%edx),%al
  801995:	3c 30                	cmp    $0x30,%al
  801997:	75 10                	jne    8019a9 <strtol+0x57>
  801999:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  80199d:	75 0a                	jne    8019a9 <strtol+0x57>
		s += 2, base = 16;
  80199f:	83 c2 02             	add    $0x2,%edx
  8019a2:	bb 10 00 00 00       	mov    $0x10,%ebx
  8019a7:	eb 12                	jmp    8019bb <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  8019a9:	85 db                	test   %ebx,%ebx
  8019ab:	75 0e                	jne    8019bb <strtol+0x69>
  8019ad:	3c 30                	cmp    $0x30,%al
  8019af:	75 05                	jne    8019b6 <strtol+0x64>
		s++, base = 8;
  8019b1:	42                   	inc    %edx
  8019b2:	b3 08                	mov    $0x8,%bl
  8019b4:	eb 05                	jmp    8019bb <strtol+0x69>
	else if (base == 0)
		base = 10;
  8019b6:	bb 0a 00 00 00       	mov    $0xa,%ebx
  8019bb:	b8 00 00 00 00       	mov    $0x0,%eax
  8019c0:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  8019c2:	8a 0a                	mov    (%edx),%cl
  8019c4:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  8019c7:	80 fb 09             	cmp    $0x9,%bl
  8019ca:	77 08                	ja     8019d4 <strtol+0x82>
			dig = *s - '0';
  8019cc:	0f be c9             	movsbl %cl,%ecx
  8019cf:	83 e9 30             	sub    $0x30,%ecx
  8019d2:	eb 1e                	jmp    8019f2 <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  8019d4:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  8019d7:	80 fb 19             	cmp    $0x19,%bl
  8019da:	77 08                	ja     8019e4 <strtol+0x92>
			dig = *s - 'a' + 10;
  8019dc:	0f be c9             	movsbl %cl,%ecx
  8019df:	83 e9 57             	sub    $0x57,%ecx
  8019e2:	eb 0e                	jmp    8019f2 <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  8019e4:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  8019e7:	80 fb 19             	cmp    $0x19,%bl
  8019ea:	77 13                	ja     8019ff <strtol+0xad>
			dig = *s - 'A' + 10;
  8019ec:	0f be c9             	movsbl %cl,%ecx
  8019ef:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  8019f2:	39 f1                	cmp    %esi,%ecx
  8019f4:	7d 0d                	jge    801a03 <strtol+0xb1>
			break;
		s++, val = (val * base) + dig;
  8019f6:	42                   	inc    %edx
  8019f7:	0f af c6             	imul   %esi,%eax
  8019fa:	8d 04 01             	lea    (%ecx,%eax,1),%eax
		// we don't properly detect overflow!
	}
  8019fd:	eb c3                	jmp    8019c2 <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  8019ff:	89 c1                	mov    %eax,%ecx
  801a01:	eb 02                	jmp    801a05 <strtol+0xb3>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  801a03:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  801a05:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801a09:	74 05                	je     801a10 <strtol+0xbe>
		*endptr = (char *) s;
  801a0b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801a0e:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  801a10:	85 ff                	test   %edi,%edi
  801a12:	74 04                	je     801a18 <strtol+0xc6>
  801a14:	89 c8                	mov    %ecx,%eax
  801a16:	f7 d8                	neg    %eax
}
  801a18:	5b                   	pop    %ebx
  801a19:	5e                   	pop    %esi
  801a1a:	5f                   	pop    %edi
  801a1b:	c9                   	leave  
  801a1c:	c3                   	ret    
  801a1d:	00 00                	add    %al,(%eax)
	...

00801a20 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801a20:	55                   	push   %ebp
  801a21:	89 e5                	mov    %esp,%ebp
  801a23:	56                   	push   %esi
  801a24:	53                   	push   %ebx
  801a25:	8b 75 08             	mov    0x8(%ebp),%esi
  801a28:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a2b:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// cprintf("0x%x 0x%x 0x%x\n", (uint32_t)from_env_store, (uint32_t)pg, (uint32_t)perm_store);
	int r;
	if (pg != NULL) {
  801a2e:	85 c0                	test   %eax,%eax
  801a30:	74 0e                	je     801a40 <ipc_recv+0x20>
		r = sys_ipc_recv(pg);
  801a32:	83 ec 0c             	sub    $0xc,%esp
  801a35:	50                   	push   %eax
  801a36:	e8 74 e8 ff ff       	call   8002af <sys_ipc_recv>
  801a3b:	83 c4 10             	add    $0x10,%esp
  801a3e:	eb 10                	jmp    801a50 <ipc_recv+0x30>
	} else {
		r = sys_ipc_recv((void *)UTOP);
  801a40:	83 ec 0c             	sub    $0xc,%esp
  801a43:	68 00 00 c0 ee       	push   $0xeec00000
  801a48:	e8 62 e8 ff ff       	call   8002af <sys_ipc_recv>
  801a4d:	83 c4 10             	add    $0x10,%esp
	}

	if (r == 0) {
  801a50:	85 c0                	test   %eax,%eax
  801a52:	75 26                	jne    801a7a <ipc_recv+0x5a>
		if (from_env_store != NULL) *from_env_store = thisenv->env_ipc_from;
  801a54:	85 f6                	test   %esi,%esi
  801a56:	74 0a                	je     801a62 <ipc_recv+0x42>
  801a58:	a1 04 40 80 00       	mov    0x804004,%eax
  801a5d:	8b 40 74             	mov    0x74(%eax),%eax
  801a60:	89 06                	mov    %eax,(%esi)
		if (perm_store != NULL) *perm_store = thisenv->env_ipc_perm;
  801a62:	85 db                	test   %ebx,%ebx
  801a64:	74 0a                	je     801a70 <ipc_recv+0x50>
  801a66:	a1 04 40 80 00       	mov    0x804004,%eax
  801a6b:	8b 40 78             	mov    0x78(%eax),%eax
  801a6e:	89 03                	mov    %eax,(%ebx)
		return thisenv->env_ipc_value;
  801a70:	a1 04 40 80 00       	mov    0x804004,%eax
  801a75:	8b 40 70             	mov    0x70(%eax),%eax
  801a78:	eb 14                	jmp    801a8e <ipc_recv+0x6e>
	} else {
		// fails;
		if (from_env_store != NULL) *from_env_store = 0;
  801a7a:	85 f6                	test   %esi,%esi
  801a7c:	74 06                	je     801a84 <ipc_recv+0x64>
  801a7e:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		if (perm_store != NULL) *perm_store = 0;
  801a84:	85 db                	test   %ebx,%ebx
  801a86:	74 06                	je     801a8e <ipc_recv+0x6e>
  801a88:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
		return r;
	}
}
  801a8e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a91:	5b                   	pop    %ebx
  801a92:	5e                   	pop    %esi
  801a93:	c9                   	leave  
  801a94:	c3                   	ret    

00801a95 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801a95:	55                   	push   %ebp
  801a96:	89 e5                	mov    %esp,%ebp
  801a98:	57                   	push   %edi
  801a99:	56                   	push   %esi
  801a9a:	53                   	push   %ebx
  801a9b:	83 ec 0c             	sub    $0xc,%esp
  801a9e:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801aa1:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801aa4:	8b 75 14             	mov    0x14(%ebp),%esi
	// LAB 4: Your code here.
	// int sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
	int r;
	if (pg == NULL) pg = (void *)UTOP;
  801aa7:	85 db                	test   %ebx,%ebx
  801aa9:	75 25                	jne    801ad0 <ipc_send+0x3b>
  801aab:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
  801ab0:	eb 1e                	jmp    801ad0 <ipc_send+0x3b>
	
	while ((r = sys_ipc_try_send(to_env, val, pg, perm)) != 0) {
		if (r == -E_IPC_NOT_RECV) {
  801ab2:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801ab5:	75 07                	jne    801abe <ipc_send+0x29>
			// cprintf("Try Again and Again....\n");
			sys_yield();
  801ab7:	e8 d1 e6 ff ff       	call   80018d <sys_yield>
  801abc:	eb 12                	jmp    801ad0 <ipc_send+0x3b>
		} else {
			panic("ipc_send error %e\n", r);
  801abe:	50                   	push   %eax
  801abf:	68 20 22 80 00       	push   $0x802220
  801ac4:	6a 43                	push   $0x43
  801ac6:	68 33 22 80 00       	push   $0x802233
  801acb:	e8 44 f5 ff ff       	call   801014 <_panic>
	// LAB 4: Your code here.
	// int sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
	int r;
	if (pg == NULL) pg = (void *)UTOP;
	
	while ((r = sys_ipc_try_send(to_env, val, pg, perm)) != 0) {
  801ad0:	56                   	push   %esi
  801ad1:	53                   	push   %ebx
  801ad2:	57                   	push   %edi
  801ad3:	ff 75 08             	pushl  0x8(%ebp)
  801ad6:	e8 af e7 ff ff       	call   80028a <sys_ipc_try_send>
  801adb:	83 c4 10             	add    $0x10,%esp
  801ade:	85 c0                	test   %eax,%eax
  801ae0:	75 d0                	jne    801ab2 <ipc_send+0x1d>
		} else {
			panic("ipc_send error %e\n", r);
		}
	}
	return;
}
  801ae2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801ae5:	5b                   	pop    %ebx
  801ae6:	5e                   	pop    %esi
  801ae7:	5f                   	pop    %edi
  801ae8:	c9                   	leave  
  801ae9:	c3                   	ret    

00801aea <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801aea:	55                   	push   %ebp
  801aeb:	89 e5                	mov    %esp,%ebp
  801aed:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
		if (envs[i].env_type == type)
  801af0:	39 0d 50 00 c0 ee    	cmp    %ecx,0xeec00050
  801af6:	74 1a                	je     801b12 <ipc_find_env+0x28>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801af8:	b8 01 00 00 00       	mov    $0x1,%eax
		if (envs[i].env_type == type)
  801afd:	89 c2                	mov    %eax,%edx
  801aff:	c1 e2 07             	shl    $0x7,%edx
  801b02:	8d 94 82 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,4),%edx
  801b09:	8b 52 50             	mov    0x50(%edx),%edx
  801b0c:	39 ca                	cmp    %ecx,%edx
  801b0e:	75 18                	jne    801b28 <ipc_find_env+0x3e>
  801b10:	eb 05                	jmp    801b17 <ipc_find_env+0x2d>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801b12:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
			return envs[i].env_id;
  801b17:	89 c2                	mov    %eax,%edx
  801b19:	c1 e2 07             	shl    $0x7,%edx
  801b1c:	8d 84 82 08 00 c0 ee 	lea    -0x113ffff8(%edx,%eax,4),%eax
  801b23:	8b 40 40             	mov    0x40(%eax),%eax
  801b26:	eb 0c                	jmp    801b34 <ipc_find_env+0x4a>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801b28:	40                   	inc    %eax
  801b29:	3d 00 04 00 00       	cmp    $0x400,%eax
  801b2e:	75 cd                	jne    801afd <ipc_find_env+0x13>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801b30:	66 b8 00 00          	mov    $0x0,%ax
}
  801b34:	c9                   	leave  
  801b35:	c3                   	ret    
	...

00801b38 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801b38:	55                   	push   %ebp
  801b39:	89 e5                	mov    %esp,%ebp
  801b3b:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801b3e:	89 c2                	mov    %eax,%edx
  801b40:	c1 ea 16             	shr    $0x16,%edx
  801b43:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801b4a:	f6 c2 01             	test   $0x1,%dl
  801b4d:	74 1e                	je     801b6d <pageref+0x35>
		return 0;
	pte = uvpt[PGNUM(v)];
  801b4f:	c1 e8 0c             	shr    $0xc,%eax
  801b52:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  801b59:	a8 01                	test   $0x1,%al
  801b5b:	74 17                	je     801b74 <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801b5d:	c1 e8 0c             	shr    $0xc,%eax
  801b60:	66 8b 04 c5 04 00 00 	mov    -0x10fffffc(,%eax,8),%ax
  801b67:	ef 
  801b68:	0f b7 c0             	movzwl %ax,%eax
  801b6b:	eb 0c                	jmp    801b79 <pageref+0x41>
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
		return 0;
  801b6d:	b8 00 00 00 00       	mov    $0x0,%eax
  801b72:	eb 05                	jmp    801b79 <pageref+0x41>
	pte = uvpt[PGNUM(v)];
	if (!(pte & PTE_P))
		return 0;
  801b74:	b8 00 00 00 00       	mov    $0x0,%eax
	return pages[PGNUM(pte)].pp_ref;
}
  801b79:	c9                   	leave  
  801b7a:	c3                   	ret    
	...

00801b7c <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  801b7c:	55                   	push   %ebp
  801b7d:	89 e5                	mov    %esp,%ebp
  801b7f:	57                   	push   %edi
  801b80:	56                   	push   %esi
  801b81:	83 ec 10             	sub    $0x10,%esp
  801b84:	8b 7d 08             	mov    0x8(%ebp),%edi
  801b87:	8b 4d 10             	mov    0x10(%ebp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  801b8a:	89 7d f0             	mov    %edi,-0x10(%ebp)
  801b8d:	8b 75 0c             	mov    0xc(%ebp),%esi
  const DWunion dd = {.ll = d};
  801b90:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  801b93:	8b 45 14             	mov    0x14(%ebp),%eax
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  801b96:	85 c0                	test   %eax,%eax
  801b98:	75 2e                	jne    801bc8 <__udivdi3+0x4c>
    {
      if (d0 > n1)
  801b9a:	39 f1                	cmp    %esi,%ecx
  801b9c:	77 5a                	ja     801bf8 <__udivdi3+0x7c>
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  801b9e:	85 c9                	test   %ecx,%ecx
  801ba0:	75 0b                	jne    801bad <__udivdi3+0x31>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  801ba2:	b8 01 00 00 00       	mov    $0x1,%eax
  801ba7:	31 d2                	xor    %edx,%edx
  801ba9:	f7 f1                	div    %ecx
  801bab:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  801bad:	31 d2                	xor    %edx,%edx
  801baf:	89 f0                	mov    %esi,%eax
  801bb1:	f7 f1                	div    %ecx
  801bb3:	89 c6                	mov    %eax,%esi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801bb5:	89 f8                	mov    %edi,%eax
  801bb7:	f7 f1                	div    %ecx
  801bb9:	89 c7                	mov    %eax,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  801bbb:	89 f8                	mov    %edi,%eax
  801bbd:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801bbf:	83 c4 10             	add    $0x10,%esp
  801bc2:	5e                   	pop    %esi
  801bc3:	5f                   	pop    %edi
  801bc4:	c9                   	leave  
  801bc5:	c3                   	ret    
  801bc6:	66 90                	xchg   %ax,%ax
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  801bc8:	39 f0                	cmp    %esi,%eax
  801bca:	77 1c                	ja     801be8 <__udivdi3+0x6c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  801bcc:	0f bd f8             	bsr    %eax,%edi
	  if (bm == 0)
  801bcf:	83 f7 1f             	xor    $0x1f,%edi
  801bd2:	75 3c                	jne    801c10 <__udivdi3+0x94>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  801bd4:	39 f0                	cmp    %esi,%eax
  801bd6:	0f 82 90 00 00 00    	jb     801c6c <__udivdi3+0xf0>
  801bdc:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801bdf:	39 55 f4             	cmp    %edx,-0xc(%ebp)
  801be2:	0f 86 84 00 00 00    	jbe    801c6c <__udivdi3+0xf0>
  801be8:	31 f6                	xor    %esi,%esi
  801bea:	31 ff                	xor    %edi,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  801bec:	89 f8                	mov    %edi,%eax
  801bee:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801bf0:	83 c4 10             	add    $0x10,%esp
  801bf3:	5e                   	pop    %esi
  801bf4:	5f                   	pop    %edi
  801bf5:	c9                   	leave  
  801bf6:	c3                   	ret    
  801bf7:	90                   	nop
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801bf8:	89 f2                	mov    %esi,%edx
  801bfa:	89 f8                	mov    %edi,%eax
  801bfc:	f7 f1                	div    %ecx
  801bfe:	89 c7                	mov    %eax,%edi
  801c00:	31 f6                	xor    %esi,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  801c02:	89 f8                	mov    %edi,%eax
  801c04:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801c06:	83 c4 10             	add    $0x10,%esp
  801c09:	5e                   	pop    %esi
  801c0a:	5f                   	pop    %edi
  801c0b:	c9                   	leave  
  801c0c:	c3                   	ret    
  801c0d:	8d 76 00             	lea    0x0(%esi),%esi
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  801c10:	89 f9                	mov    %edi,%ecx
  801c12:	d3 e0                	shl    %cl,%eax
  801c14:	89 45 e8             	mov    %eax,-0x18(%ebp)
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  801c17:	b8 20 00 00 00       	mov    $0x20,%eax
  801c1c:	29 f8                	sub    %edi,%eax

	      d1 = (d1 << bm) | (d0 >> b);
  801c1e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801c21:	88 c1                	mov    %al,%cl
  801c23:	d3 ea                	shr    %cl,%edx
  801c25:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  801c28:	09 ca                	or     %ecx,%edx
  801c2a:	89 55 ec             	mov    %edx,-0x14(%ebp)
	      d0 = d0 << bm;
  801c2d:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801c30:	89 f9                	mov    %edi,%ecx
  801c32:	d3 e2                	shl    %cl,%edx
  801c34:	89 55 f4             	mov    %edx,-0xc(%ebp)
	      n2 = n1 >> b;
  801c37:	89 f2                	mov    %esi,%edx
  801c39:	88 c1                	mov    %al,%cl
  801c3b:	d3 ea                	shr    %cl,%edx
  801c3d:	89 55 e8             	mov    %edx,-0x18(%ebp)
	      n1 = (n1 << bm) | (n0 >> b);
  801c40:	89 f2                	mov    %esi,%edx
  801c42:	89 f9                	mov    %edi,%ecx
  801c44:	d3 e2                	shl    %cl,%edx
  801c46:	8b 75 f0             	mov    -0x10(%ebp),%esi
  801c49:	88 c1                	mov    %al,%cl
  801c4b:	d3 ee                	shr    %cl,%esi
  801c4d:	09 d6                	or     %edx,%esi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  801c4f:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  801c52:	89 f0                	mov    %esi,%eax
  801c54:	89 ca                	mov    %ecx,%edx
  801c56:	f7 75 ec             	divl   -0x14(%ebp)
  801c59:	89 d1                	mov    %edx,%ecx
  801c5b:	89 c6                	mov    %eax,%esi
	      umul_ppmm (m1, m0, q0, d0);
  801c5d:	f7 65 f4             	mull   -0xc(%ebp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801c60:	39 d1                	cmp    %edx,%ecx
  801c62:	72 28                	jb     801c8c <__udivdi3+0x110>
  801c64:	74 1a                	je     801c80 <__udivdi3+0x104>
  801c66:	89 f7                	mov    %esi,%edi
  801c68:	31 f6                	xor    %esi,%esi
  801c6a:	eb 80                	jmp    801bec <__udivdi3+0x70>
	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  801c6c:	31 f6                	xor    %esi,%esi
  801c6e:	bf 01 00 00 00       	mov    $0x1,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  801c73:	89 f8                	mov    %edi,%eax
  801c75:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801c77:	83 c4 10             	add    $0x10,%esp
  801c7a:	5e                   	pop    %esi
  801c7b:	5f                   	pop    %edi
  801c7c:	c9                   	leave  
  801c7d:	c3                   	ret    
  801c7e:	66 90                	xchg   %ax,%ax

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  801c80:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801c83:	89 f9                	mov    %edi,%ecx
  801c85:	d3 e2                	shl    %cl,%edx

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801c87:	39 c2                	cmp    %eax,%edx
  801c89:	73 db                	jae    801c66 <__udivdi3+0xea>
  801c8b:	90                   	nop
		{
		  q0--;
  801c8c:	8d 7e ff             	lea    -0x1(%esi),%edi
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  801c8f:	31 f6                	xor    %esi,%esi
  801c91:	e9 56 ff ff ff       	jmp    801bec <__udivdi3+0x70>
	...

00801c98 <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  801c98:	55                   	push   %ebp
  801c99:	89 e5                	mov    %esp,%ebp
  801c9b:	57                   	push   %edi
  801c9c:	56                   	push   %esi
  801c9d:	83 ec 20             	sub    $0x20,%esp
  801ca0:	8b 45 08             	mov    0x8(%ebp),%eax
  801ca3:	8b 4d 10             	mov    0x10(%ebp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  801ca6:	89 45 e8             	mov    %eax,-0x18(%ebp)
  801ca9:	8b 75 0c             	mov    0xc(%ebp),%esi
  const DWunion dd = {.ll = d};
  801cac:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  801caf:	8b 7d 14             	mov    0x14(%ebp),%edi
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  801cb2:	89 45 f0             	mov    %eax,-0x10(%ebp)
  n1 = nn.s.high;
  801cb5:	89 f2                	mov    %esi,%edx

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  801cb7:	85 ff                	test   %edi,%edi
  801cb9:	75 15                	jne    801cd0 <__umoddi3+0x38>
    {
      if (d0 > n1)
  801cbb:	39 f1                	cmp    %esi,%ecx
  801cbd:	0f 86 99 00 00 00    	jbe    801d5c <__umoddi3+0xc4>
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801cc3:	f7 f1                	div    %ecx

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
  801cc5:	89 d0                	mov    %edx,%eax
  801cc7:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  801cc9:	83 c4 20             	add    $0x20,%esp
  801ccc:	5e                   	pop    %esi
  801ccd:	5f                   	pop    %edi
  801cce:	c9                   	leave  
  801ccf:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  801cd0:	39 f7                	cmp    %esi,%edi
  801cd2:	0f 87 a4 00 00 00    	ja     801d7c <__umoddi3+0xe4>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  801cd8:	0f bd c7             	bsr    %edi,%eax
	  if (bm == 0)
  801cdb:	83 f0 1f             	xor    $0x1f,%eax
  801cde:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801ce1:	0f 84 a1 00 00 00    	je     801d88 <__umoddi3+0xf0>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  801ce7:	89 f8                	mov    %edi,%eax
  801ce9:	8a 4d ec             	mov    -0x14(%ebp),%cl
  801cec:	d3 e0                	shl    %cl,%eax
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  801cee:	bf 20 00 00 00       	mov    $0x20,%edi
  801cf3:	2b 7d ec             	sub    -0x14(%ebp),%edi

	      d1 = (d1 << bm) | (d0 >> b);
  801cf6:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801cf9:	89 f9                	mov    %edi,%ecx
  801cfb:	d3 ea                	shr    %cl,%edx
  801cfd:	09 c2                	or     %eax,%edx
  801cff:	89 55 f0             	mov    %edx,-0x10(%ebp)
	      d0 = d0 << bm;
  801d02:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d05:	8a 4d ec             	mov    -0x14(%ebp),%cl
  801d08:	d3 e0                	shl    %cl,%eax
  801d0a:	89 45 f4             	mov    %eax,-0xc(%ebp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  801d0d:	89 f2                	mov    %esi,%edx
  801d0f:	d3 e2                	shl    %cl,%edx
	      n0 = n0 << bm;
  801d11:	8b 45 e8             	mov    -0x18(%ebp),%eax
  801d14:	d3 e0                	shl    %cl,%eax
  801d16:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  801d19:	8b 45 e8             	mov    -0x18(%ebp),%eax
  801d1c:	89 f9                	mov    %edi,%ecx
  801d1e:	d3 e8                	shr    %cl,%eax
  801d20:	09 d0                	or     %edx,%eax

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  801d22:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  801d24:	89 f2                	mov    %esi,%edx
  801d26:	f7 75 f0             	divl   -0x10(%ebp)
  801d29:	89 d6                	mov    %edx,%esi
	      umul_ppmm (m1, m0, q0, d0);
  801d2b:	f7 65 f4             	mull   -0xc(%ebp)
  801d2e:	89 55 e8             	mov    %edx,-0x18(%ebp)
  801d31:	89 c1                	mov    %eax,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801d33:	39 d6                	cmp    %edx,%esi
  801d35:	72 71                	jb     801da8 <__umoddi3+0x110>
  801d37:	74 7f                	je     801db8 <__umoddi3+0x120>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  801d39:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801d3c:	29 c8                	sub    %ecx,%eax
  801d3e:	19 d6                	sbb    %edx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
  801d40:	8a 4d ec             	mov    -0x14(%ebp),%cl
  801d43:	d3 e8                	shr    %cl,%eax
  801d45:	89 f2                	mov    %esi,%edx
  801d47:	89 f9                	mov    %edi,%ecx
  801d49:	d3 e2                	shl    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
  801d4b:	09 d0                	or     %edx,%eax
  801d4d:	89 f2                	mov    %esi,%edx
  801d4f:	8a 4d ec             	mov    -0x14(%ebp),%cl
  801d52:	d3 ea                	shr    %cl,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  801d54:	83 c4 20             	add    $0x20,%esp
  801d57:	5e                   	pop    %esi
  801d58:	5f                   	pop    %edi
  801d59:	c9                   	leave  
  801d5a:	c3                   	ret    
  801d5b:	90                   	nop
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  801d5c:	85 c9                	test   %ecx,%ecx
  801d5e:	75 0b                	jne    801d6b <__umoddi3+0xd3>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  801d60:	b8 01 00 00 00       	mov    $0x1,%eax
  801d65:	31 d2                	xor    %edx,%edx
  801d67:	f7 f1                	div    %ecx
  801d69:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  801d6b:	89 f0                	mov    %esi,%eax
  801d6d:	31 d2                	xor    %edx,%edx
  801d6f:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801d71:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801d74:	f7 f1                	div    %ecx
  801d76:	e9 4a ff ff ff       	jmp    801cc5 <__umoddi3+0x2d>
  801d7b:	90                   	nop
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
  801d7c:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  801d7e:	83 c4 20             	add    $0x20,%esp
  801d81:	5e                   	pop    %esi
  801d82:	5f                   	pop    %edi
  801d83:	c9                   	leave  
  801d84:	c3                   	ret    
  801d85:	8d 76 00             	lea    0x0(%esi),%esi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  801d88:	39 f7                	cmp    %esi,%edi
  801d8a:	72 05                	jb     801d91 <__umoddi3+0xf9>
  801d8c:	3b 4d f0             	cmp    -0x10(%ebp),%ecx
  801d8f:	77 0c                	ja     801d9d <__umoddi3+0x105>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  801d91:	89 f2                	mov    %esi,%edx
  801d93:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801d96:	29 c8                	sub    %ecx,%eax
  801d98:	19 fa                	sbb    %edi,%edx
  801d9a:	89 45 f0             	mov    %eax,-0x10(%ebp)

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
  801d9d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  801da0:	83 c4 20             	add    $0x20,%esp
  801da3:	5e                   	pop    %esi
  801da4:	5f                   	pop    %edi
  801da5:	c9                   	leave  
  801da6:	c3                   	ret    
  801da7:	90                   	nop
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  801da8:	8b 55 e8             	mov    -0x18(%ebp),%edx
  801dab:	89 c1                	mov    %eax,%ecx
  801dad:	2b 4d f4             	sub    -0xc(%ebp),%ecx
  801db0:	1b 55 f0             	sbb    -0x10(%ebp),%edx
  801db3:	eb 84                	jmp    801d39 <__umoddi3+0xa1>
  801db5:	8d 76 00             	lea    0x0(%esi),%esi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801db8:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  801dbb:	72 eb                	jb     801da8 <__umoddi3+0x110>
  801dbd:	89 f2                	mov    %esi,%edx
  801dbf:	e9 75 ff ff ff       	jmp    801d39 <__umoddi3+0xa1>
