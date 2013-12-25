
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
  800043:	e8 8c 01 00 00       	call   8001d4 <sys_page_alloc>
	sys_env_set_pgfault_upcall(0, (void*) 0xDeadBeef);
  800048:	83 c4 08             	add    $0x8,%esp
  80004b:	68 ef be ad de       	push   $0xdeadbeef
  800050:	6a 00                	push   $0x0
  800052:	e8 30 02 00 00       	call   800287 <sys_env_set_pgfault_upcall>
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
  800073:	e8 11 01 00 00       	call   800189 <sys_getenvid>
  800078:	25 ff 03 00 00       	and    $0x3ff,%eax
  80007d:	89 c2                	mov    %eax,%edx
  80007f:	c1 e2 07             	shl    $0x7,%edx
  800082:	8d 84 82 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,4),%eax
  800089:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80008e:	85 f6                	test   %esi,%esi
  800090:	7e 07                	jle    800099 <libmain+0x31>
		binaryname = argv[0];
  800092:	8b 03                	mov    (%ebx),%eax
  800094:	a3 00 30 80 00       	mov    %eax,0x803000
	// call user main routine
	umain(argc, argv);
  800099:	83 ec 08             	sub    $0x8,%esp
  80009c:	53                   	push   %ebx
  80009d:	56                   	push   %esi
  80009e:	e8 91 ff ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  8000a3:	e8 0c 00 00 00       	call   8000b4 <exit>
  8000a8:	83 c4 10             	add    $0x10,%esp
}
  8000ab:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000ae:	5b                   	pop    %ebx
  8000af:	5e                   	pop    %esi
  8000b0:	c9                   	leave  
  8000b1:	c3                   	ret    
	...

008000b4 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000b4:	55                   	push   %ebp
  8000b5:	89 e5                	mov    %esp,%ebp
  8000b7:	83 ec 08             	sub    $0x8,%esp
	close_all();
  8000ba:	e8 cb 04 00 00       	call   80058a <close_all>
	sys_env_destroy(0);
  8000bf:	83 ec 0c             	sub    $0xc,%esp
  8000c2:	6a 00                	push   $0x0
  8000c4:	e8 9e 00 00 00       	call   800167 <sys_env_destroy>
  8000c9:	83 c4 10             	add    $0x10,%esp
}
  8000cc:	c9                   	leave  
  8000cd:	c3                   	ret    
	...

008000d0 <syscall>:
	return ret;
}

static int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  8000d0:	55                   	push   %ebp
  8000d1:	89 e5                	mov    %esp,%ebp
  8000d3:	57                   	push   %edi
  8000d4:	56                   	push   %esi
  8000d5:	53                   	push   %ebx
  8000d6:	83 ec 1c             	sub    $0x1c,%esp
  8000d9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8000dc:	89 55 e0             	mov    %edx,-0x20(%ebp)
  8000df:	89 ca                	mov    %ecx,%edx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000e1:	8b 75 14             	mov    0x14(%ebp),%esi
  8000e4:	8b 7d 10             	mov    0x10(%ebp),%edi
  8000e7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8000ea:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8000ed:	cd 30                	int    $0x30
  8000ef:	89 c2                	mov    %eax,%edx
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8000f1:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8000f5:	74 1c                	je     800113 <syscall+0x43>
  8000f7:	85 c0                	test   %eax,%eax
  8000f9:	7e 18                	jle    800113 <syscall+0x43>
		panic("syscall %d returned %d (> 0)", num, ret);
  8000fb:	83 ec 0c             	sub    $0xc,%esp
  8000fe:	50                   	push   %eax
  8000ff:	ff 75 e4             	pushl  -0x1c(%ebp)
  800102:	68 0a 1e 80 00       	push   $0x801e0a
  800107:	6a 42                	push   $0x42
  800109:	68 27 1e 80 00       	push   $0x801e27
  80010e:	e8 21 0f 00 00       	call   801034 <_panic>

	return ret;
}
  800113:	89 d0                	mov    %edx,%eax
  800115:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800118:	5b                   	pop    %ebx
  800119:	5e                   	pop    %esi
  80011a:	5f                   	pop    %edi
  80011b:	c9                   	leave  
  80011c:	c3                   	ret    

0080011d <sys_cputs>:

void
sys_cputs(const char *s, size_t len)
{	
  80011d:	55                   	push   %ebp
  80011e:	89 e5                	mov    %esp,%ebp
  800120:	83 ec 08             	sub    $0x8,%esp
	// my_sysenter(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
	// return;
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
  800123:	6a 00                	push   $0x0
  800125:	6a 00                	push   $0x0
  800127:	6a 00                	push   $0x0
  800129:	ff 75 0c             	pushl  0xc(%ebp)
  80012c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80012f:	ba 00 00 00 00       	mov    $0x0,%edx
  800134:	b8 00 00 00 00       	mov    $0x0,%eax
  800139:	e8 92 ff ff ff       	call   8000d0 <syscall>
  80013e:	83 c4 10             	add    $0x10,%esp
	return;
}
  800141:	c9                   	leave  
  800142:	c3                   	ret    

00800143 <sys_cgetc>:

int
sys_cgetc(void)
{
  800143:	55                   	push   %ebp
  800144:	89 e5                	mov    %esp,%ebp
  800146:	83 ec 08             	sub    $0x8,%esp
	// return my_sysenter(SYS_cgetc, 0, 0, 0, 0, 0, 0);
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
  800149:	6a 00                	push   $0x0
  80014b:	6a 00                	push   $0x0
  80014d:	6a 00                	push   $0x0
  80014f:	6a 00                	push   $0x0
  800151:	b9 00 00 00 00       	mov    $0x0,%ecx
  800156:	ba 00 00 00 00       	mov    $0x0,%edx
  80015b:	b8 01 00 00 00       	mov    $0x1,%eax
  800160:	e8 6b ff ff ff       	call   8000d0 <syscall>
}
  800165:	c9                   	leave  
  800166:	c3                   	ret    

00800167 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800167:	55                   	push   %ebp
  800168:	89 e5                	mov    %esp,%ebp
  80016a:	83 ec 08             	sub    $0x8,%esp
	// return my_sysenter(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
  80016d:	6a 00                	push   $0x0
  80016f:	6a 00                	push   $0x0
  800171:	6a 00                	push   $0x0
  800173:	6a 00                	push   $0x0
  800175:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800178:	ba 01 00 00 00       	mov    $0x1,%edx
  80017d:	b8 03 00 00 00       	mov    $0x3,%eax
  800182:	e8 49 ff ff ff       	call   8000d0 <syscall>
}
  800187:	c9                   	leave  
  800188:	c3                   	ret    

00800189 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800189:	55                   	push   %ebp
  80018a:	89 e5                	mov    %esp,%ebp
  80018c:	83 ec 08             	sub    $0x8,%esp
	// return my_sysenter(SYS_getenvid, 0, 0, 0, 0, 0, 0);
	return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
  80018f:	6a 00                	push   $0x0
  800191:	6a 00                	push   $0x0
  800193:	6a 00                	push   $0x0
  800195:	6a 00                	push   $0x0
  800197:	b9 00 00 00 00       	mov    $0x0,%ecx
  80019c:	ba 00 00 00 00       	mov    $0x0,%edx
  8001a1:	b8 02 00 00 00       	mov    $0x2,%eax
  8001a6:	e8 25 ff ff ff       	call   8000d0 <syscall>
}
  8001ab:	c9                   	leave  
  8001ac:	c3                   	ret    

008001ad <sys_yield>:

void
sys_yield(void)
{
  8001ad:	55                   	push   %ebp
  8001ae:	89 e5                	mov    %esp,%ebp
  8001b0:	83 ec 08             	sub    $0x8,%esp
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
  8001b3:	6a 00                	push   $0x0
  8001b5:	6a 00                	push   $0x0
  8001b7:	6a 00                	push   $0x0
  8001b9:	6a 00                	push   $0x0
  8001bb:	b9 00 00 00 00       	mov    $0x0,%ecx
  8001c0:	ba 00 00 00 00       	mov    $0x0,%edx
  8001c5:	b8 0b 00 00 00       	mov    $0xb,%eax
  8001ca:	e8 01 ff ff ff       	call   8000d0 <syscall>
  8001cf:	83 c4 10             	add    $0x10,%esp
}
  8001d2:	c9                   	leave  
  8001d3:	c3                   	ret    

008001d4 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  8001d4:	55                   	push   %ebp
  8001d5:	89 e5                	mov    %esp,%ebp
  8001d7:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
  8001da:	6a 00                	push   $0x0
  8001dc:	6a 00                	push   $0x0
  8001de:	ff 75 10             	pushl  0x10(%ebp)
  8001e1:	ff 75 0c             	pushl  0xc(%ebp)
  8001e4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8001e7:	ba 01 00 00 00       	mov    $0x1,%edx
  8001ec:	b8 04 00 00 00       	mov    $0x4,%eax
  8001f1:	e8 da fe ff ff       	call   8000d0 <syscall>
}
  8001f6:	c9                   	leave  
  8001f7:	c3                   	ret    

008001f8 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8001f8:	55                   	push   %ebp
  8001f9:	89 e5                	mov    %esp,%ebp
  8001fb:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
  8001fe:	ff 75 18             	pushl  0x18(%ebp)
  800201:	ff 75 14             	pushl  0x14(%ebp)
  800204:	ff 75 10             	pushl  0x10(%ebp)
  800207:	ff 75 0c             	pushl  0xc(%ebp)
  80020a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80020d:	ba 01 00 00 00       	mov    $0x1,%edx
  800212:	b8 05 00 00 00       	mov    $0x5,%eax
  800217:	e8 b4 fe ff ff       	call   8000d0 <syscall>
}
  80021c:	c9                   	leave  
  80021d:	c3                   	ret    

0080021e <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  80021e:	55                   	push   %ebp
  80021f:	89 e5                	mov    %esp,%ebp
  800221:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
  800224:	6a 00                	push   $0x0
  800226:	6a 00                	push   $0x0
  800228:	6a 00                	push   $0x0
  80022a:	ff 75 0c             	pushl  0xc(%ebp)
  80022d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800230:	ba 01 00 00 00       	mov    $0x1,%edx
  800235:	b8 06 00 00 00       	mov    $0x6,%eax
  80023a:	e8 91 fe ff ff       	call   8000d0 <syscall>
}
  80023f:	c9                   	leave  
  800240:	c3                   	ret    

00800241 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800241:	55                   	push   %ebp
  800242:	89 e5                	mov    %esp,%ebp
  800244:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
  800247:	6a 00                	push   $0x0
  800249:	6a 00                	push   $0x0
  80024b:	6a 00                	push   $0x0
  80024d:	ff 75 0c             	pushl  0xc(%ebp)
  800250:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800253:	ba 01 00 00 00       	mov    $0x1,%edx
  800258:	b8 08 00 00 00       	mov    $0x8,%eax
  80025d:	e8 6e fe ff ff       	call   8000d0 <syscall>
}
  800262:	c9                   	leave  
  800263:	c3                   	ret    

00800264 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800264:	55                   	push   %ebp
  800265:	89 e5                	mov    %esp,%ebp
  800267:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
  80026a:	6a 00                	push   $0x0
  80026c:	6a 00                	push   $0x0
  80026e:	6a 00                	push   $0x0
  800270:	ff 75 0c             	pushl  0xc(%ebp)
  800273:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800276:	ba 01 00 00 00       	mov    $0x1,%edx
  80027b:	b8 09 00 00 00       	mov    $0x9,%eax
  800280:	e8 4b fe ff ff       	call   8000d0 <syscall>
}
  800285:	c9                   	leave  
  800286:	c3                   	ret    

00800287 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800287:	55                   	push   %ebp
  800288:	89 e5                	mov    %esp,%ebp
  80028a:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
  80028d:	6a 00                	push   $0x0
  80028f:	6a 00                	push   $0x0
  800291:	6a 00                	push   $0x0
  800293:	ff 75 0c             	pushl  0xc(%ebp)
  800296:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800299:	ba 01 00 00 00       	mov    $0x1,%edx
  80029e:	b8 0a 00 00 00       	mov    $0xa,%eax
  8002a3:	e8 28 fe ff ff       	call   8000d0 <syscall>
}
  8002a8:	c9                   	leave  
  8002a9:	c3                   	ret    

008002aa <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8002aa:	55                   	push   %ebp
  8002ab:	89 e5                	mov    %esp,%ebp
  8002ad:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
  8002b0:	6a 00                	push   $0x0
  8002b2:	ff 75 14             	pushl  0x14(%ebp)
  8002b5:	ff 75 10             	pushl  0x10(%ebp)
  8002b8:	ff 75 0c             	pushl  0xc(%ebp)
  8002bb:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8002be:	ba 00 00 00 00       	mov    $0x0,%edx
  8002c3:	b8 0c 00 00 00       	mov    $0xc,%eax
  8002c8:	e8 03 fe ff ff       	call   8000d0 <syscall>
}
  8002cd:	c9                   	leave  
  8002ce:	c3                   	ret    

008002cf <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  8002cf:	55                   	push   %ebp
  8002d0:	89 e5                	mov    %esp,%ebp
  8002d2:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
  8002d5:	6a 00                	push   $0x0
  8002d7:	6a 00                	push   $0x0
  8002d9:	6a 00                	push   $0x0
  8002db:	6a 00                	push   $0x0
  8002dd:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8002e0:	ba 01 00 00 00       	mov    $0x1,%edx
  8002e5:	b8 0d 00 00 00       	mov    $0xd,%eax
  8002ea:	e8 e1 fd ff ff       	call   8000d0 <syscall>
}
  8002ef:	c9                   	leave  
  8002f0:	c3                   	ret    

008002f1 <sys_set_priority>:

int
sys_set_priority(envid_t envid, uint32_t new_priority)
{
  8002f1:	55                   	push   %ebp
  8002f2:	89 e5                	mov    %esp,%ebp
  8002f4:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_set_priority, 0, envid, new_priority, 0, 0, 0);
  8002f7:	6a 00                	push   $0x0
  8002f9:	6a 00                	push   $0x0
  8002fb:	6a 00                	push   $0x0
  8002fd:	ff 75 0c             	pushl  0xc(%ebp)
  800300:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800303:	ba 00 00 00 00       	mov    $0x0,%edx
  800308:	b8 0e 00 00 00       	mov    $0xe,%eax
  80030d:	e8 be fd ff ff       	call   8000d0 <syscall>
}
  800312:	c9                   	leave  
  800313:	c3                   	ret    

00800314 <sys_exec>:

int
sys_exec(uint32_t eip, uint32_t esp, void * ph, uint32_t elf_phnum)
{
  800314:	55                   	push   %ebp
  800315:	89 e5                	mov    %esp,%ebp
  800317:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_exec, 0, eip, esp, (uint32_t)ph, elf_phnum, 0);
  80031a:	6a 00                	push   $0x0
  80031c:	ff 75 14             	pushl  0x14(%ebp)
  80031f:	ff 75 10             	pushl  0x10(%ebp)
  800322:	ff 75 0c             	pushl  0xc(%ebp)
  800325:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800328:	ba 00 00 00 00       	mov    $0x0,%edx
  80032d:	b8 0f 00 00 00       	mov    $0xf,%eax
  800332:	e8 99 fd ff ff       	call   8000d0 <syscall>
} 
  800337:	c9                   	leave  
  800338:	c3                   	ret    

00800339 <sys_join>:

// thread:
int
sys_join(envid_t envid)
{
  800339:	55                   	push   %ebp
  80033a:	89 e5                	mov    %esp,%ebp
  80033c:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_join, 0, envid, 0, 0, 0, 0);
  80033f:	6a 00                	push   $0x0
  800341:	6a 00                	push   $0x0
  800343:	6a 00                	push   $0x0
  800345:	6a 00                	push   $0x0
  800347:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80034a:	ba 00 00 00 00       	mov    $0x0,%edx
  80034f:	b8 11 00 00 00       	mov    $0x11,%eax
  800354:	e8 77 fd ff ff       	call   8000d0 <syscall>
}
  800359:	c9                   	leave  
  80035a:	c3                   	ret    

0080035b <sys_getpid>:

envid_t
sys_getpid(void)
{
  80035b:	55                   	push   %ebp
  80035c:	89 e5                	mov    %esp,%ebp
  80035e:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_getpid, 0, 0, 0, 0, 0, 0);
  800361:	6a 00                	push   $0x0
  800363:	6a 00                	push   $0x0
  800365:	6a 00                	push   $0x0
  800367:	6a 00                	push   $0x0
  800369:	b9 00 00 00 00       	mov    $0x0,%ecx
  80036e:	ba 00 00 00 00       	mov    $0x0,%edx
  800373:	b8 10 00 00 00       	mov    $0x10,%eax
  800378:	e8 53 fd ff ff       	call   8000d0 <syscall>
  80037d:	c9                   	leave  
  80037e:	c3                   	ret    
	...

00800380 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800380:	55                   	push   %ebp
  800381:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800383:	8b 45 08             	mov    0x8(%ebp),%eax
  800386:	05 00 00 00 30       	add    $0x30000000,%eax
  80038b:	c1 e8 0c             	shr    $0xc,%eax
}
  80038e:	c9                   	leave  
  80038f:	c3                   	ret    

00800390 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800390:	55                   	push   %ebp
  800391:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  800393:	ff 75 08             	pushl  0x8(%ebp)
  800396:	e8 e5 ff ff ff       	call   800380 <fd2num>
  80039b:	83 c4 04             	add    $0x4,%esp
  80039e:	05 20 00 0d 00       	add    $0xd0020,%eax
  8003a3:	c1 e0 0c             	shl    $0xc,%eax
}
  8003a6:	c9                   	leave  
  8003a7:	c3                   	ret    

008003a8 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8003a8:	55                   	push   %ebp
  8003a9:	89 e5                	mov    %esp,%ebp
  8003ab:	53                   	push   %ebx
  8003ac:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8003af:	a1 00 dd 7b ef       	mov    0xef7bdd00,%eax
  8003b4:	a8 01                	test   $0x1,%al
  8003b6:	74 34                	je     8003ec <fd_alloc+0x44>
  8003b8:	a1 00 00 74 ef       	mov    0xef740000,%eax
  8003bd:	a8 01                	test   $0x1,%al
  8003bf:	74 32                	je     8003f3 <fd_alloc+0x4b>
  8003c1:	b8 00 10 00 d0       	mov    $0xd0001000,%eax
  8003c6:	89 c1                	mov    %eax,%ecx
  8003c8:	89 c2                	mov    %eax,%edx
  8003ca:	c1 ea 16             	shr    $0x16,%edx
  8003cd:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8003d4:	f6 c2 01             	test   $0x1,%dl
  8003d7:	74 1f                	je     8003f8 <fd_alloc+0x50>
  8003d9:	89 c2                	mov    %eax,%edx
  8003db:	c1 ea 0c             	shr    $0xc,%edx
  8003de:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8003e5:	f6 c2 01             	test   $0x1,%dl
  8003e8:	75 17                	jne    800401 <fd_alloc+0x59>
  8003ea:	eb 0c                	jmp    8003f8 <fd_alloc+0x50>
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  8003ec:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
  8003f1:	eb 05                	jmp    8003f8 <fd_alloc+0x50>
  8003f3:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
  8003f8:	89 0b                	mov    %ecx,(%ebx)
			return 0;
  8003fa:	b8 00 00 00 00       	mov    $0x0,%eax
  8003ff:	eb 17                	jmp    800418 <fd_alloc+0x70>
  800401:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800406:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  80040b:	75 b9                	jne    8003c6 <fd_alloc+0x1e>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  80040d:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_MAX_OPEN;
  800413:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800418:	5b                   	pop    %ebx
  800419:	c9                   	leave  
  80041a:	c3                   	ret    

0080041b <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  80041b:	55                   	push   %ebp
  80041c:	89 e5                	mov    %esp,%ebp
  80041e:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800421:	83 f8 1f             	cmp    $0x1f,%eax
  800424:	77 36                	ja     80045c <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800426:	05 00 00 0d 00       	add    $0xd0000,%eax
  80042b:	c1 e0 0c             	shl    $0xc,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  80042e:	89 c2                	mov    %eax,%edx
  800430:	c1 ea 16             	shr    $0x16,%edx
  800433:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80043a:	f6 c2 01             	test   $0x1,%dl
  80043d:	74 24                	je     800463 <fd_lookup+0x48>
  80043f:	89 c2                	mov    %eax,%edx
  800441:	c1 ea 0c             	shr    $0xc,%edx
  800444:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80044b:	f6 c2 01             	test   $0x1,%dl
  80044e:	74 1a                	je     80046a <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800450:	8b 55 0c             	mov    0xc(%ebp),%edx
  800453:	89 02                	mov    %eax,(%edx)
	return 0;
  800455:	b8 00 00 00 00       	mov    $0x0,%eax
  80045a:	eb 13                	jmp    80046f <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80045c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800461:	eb 0c                	jmp    80046f <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800463:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800468:	eb 05                	jmp    80046f <fd_lookup+0x54>
  80046a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  80046f:	c9                   	leave  
  800470:	c3                   	ret    

00800471 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800471:	55                   	push   %ebp
  800472:	89 e5                	mov    %esp,%ebp
  800474:	53                   	push   %ebx
  800475:	83 ec 04             	sub    $0x4,%esp
  800478:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80047b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
		if (devtab[i]->dev_id == dev_id) {
  80047e:	39 0d 04 30 80 00    	cmp    %ecx,0x803004
  800484:	74 0d                	je     800493 <dev_lookup+0x22>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800486:	b8 00 00 00 00       	mov    $0x0,%eax
  80048b:	eb 14                	jmp    8004a1 <dev_lookup+0x30>
		if (devtab[i]->dev_id == dev_id) {
  80048d:	39 0a                	cmp    %ecx,(%edx)
  80048f:	75 10                	jne    8004a1 <dev_lookup+0x30>
  800491:	eb 05                	jmp    800498 <dev_lookup+0x27>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800493:	ba 04 30 80 00       	mov    $0x803004,%edx
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
  800498:	89 13                	mov    %edx,(%ebx)
			return 0;
  80049a:	b8 00 00 00 00       	mov    $0x0,%eax
  80049f:	eb 31                	jmp    8004d2 <dev_lookup+0x61>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8004a1:	40                   	inc    %eax
  8004a2:	8b 14 85 b4 1e 80 00 	mov    0x801eb4(,%eax,4),%edx
  8004a9:	85 d2                	test   %edx,%edx
  8004ab:	75 e0                	jne    80048d <dev_lookup+0x1c>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8004ad:	a1 04 40 80 00       	mov    0x804004,%eax
  8004b2:	8b 40 48             	mov    0x48(%eax),%eax
  8004b5:	83 ec 04             	sub    $0x4,%esp
  8004b8:	51                   	push   %ecx
  8004b9:	50                   	push   %eax
  8004ba:	68 38 1e 80 00       	push   $0x801e38
  8004bf:	e8 48 0c 00 00       	call   80110c <cprintf>
	*dev = 0;
  8004c4:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_INVAL;
  8004ca:	83 c4 10             	add    $0x10,%esp
  8004cd:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8004d2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8004d5:	c9                   	leave  
  8004d6:	c3                   	ret    

008004d7 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8004d7:	55                   	push   %ebp
  8004d8:	89 e5                	mov    %esp,%ebp
  8004da:	56                   	push   %esi
  8004db:	53                   	push   %ebx
  8004dc:	83 ec 20             	sub    $0x20,%esp
  8004df:	8b 75 08             	mov    0x8(%ebp),%esi
  8004e2:	8a 45 0c             	mov    0xc(%ebp),%al
  8004e5:	88 45 e7             	mov    %al,-0x19(%ebp)
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8004e8:	56                   	push   %esi
  8004e9:	e8 92 fe ff ff       	call   800380 <fd2num>
  8004ee:	8d 55 f4             	lea    -0xc(%ebp),%edx
  8004f1:	89 14 24             	mov    %edx,(%esp)
  8004f4:	50                   	push   %eax
  8004f5:	e8 21 ff ff ff       	call   80041b <fd_lookup>
  8004fa:	89 c3                	mov    %eax,%ebx
  8004fc:	83 c4 08             	add    $0x8,%esp
  8004ff:	85 c0                	test   %eax,%eax
  800501:	78 05                	js     800508 <fd_close+0x31>
	    || fd != fd2)
  800503:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  800506:	74 0d                	je     800515 <fd_close+0x3e>
		return (must_exist ? r : 0);
  800508:	80 7d e7 00          	cmpb   $0x0,-0x19(%ebp)
  80050c:	75 48                	jne    800556 <fd_close+0x7f>
  80050e:	bb 00 00 00 00       	mov    $0x0,%ebx
  800513:	eb 41                	jmp    800556 <fd_close+0x7f>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800515:	83 ec 08             	sub    $0x8,%esp
  800518:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80051b:	50                   	push   %eax
  80051c:	ff 36                	pushl  (%esi)
  80051e:	e8 4e ff ff ff       	call   800471 <dev_lookup>
  800523:	89 c3                	mov    %eax,%ebx
  800525:	83 c4 10             	add    $0x10,%esp
  800528:	85 c0                	test   %eax,%eax
  80052a:	78 1c                	js     800548 <fd_close+0x71>
		if (dev->dev_close)
  80052c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80052f:	8b 40 10             	mov    0x10(%eax),%eax
  800532:	85 c0                	test   %eax,%eax
  800534:	74 0d                	je     800543 <fd_close+0x6c>
			r = (*dev->dev_close)(fd);
  800536:	83 ec 0c             	sub    $0xc,%esp
  800539:	56                   	push   %esi
  80053a:	ff d0                	call   *%eax
  80053c:	89 c3                	mov    %eax,%ebx
  80053e:	83 c4 10             	add    $0x10,%esp
  800541:	eb 05                	jmp    800548 <fd_close+0x71>
		else
			r = 0;
  800543:	bb 00 00 00 00       	mov    $0x0,%ebx
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  800548:	83 ec 08             	sub    $0x8,%esp
  80054b:	56                   	push   %esi
  80054c:	6a 00                	push   $0x0
  80054e:	e8 cb fc ff ff       	call   80021e <sys_page_unmap>
	return r;
  800553:	83 c4 10             	add    $0x10,%esp
}
  800556:	89 d8                	mov    %ebx,%eax
  800558:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80055b:	5b                   	pop    %ebx
  80055c:	5e                   	pop    %esi
  80055d:	c9                   	leave  
  80055e:	c3                   	ret    

0080055f <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  80055f:	55                   	push   %ebp
  800560:	89 e5                	mov    %esp,%ebp
  800562:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800565:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800568:	50                   	push   %eax
  800569:	ff 75 08             	pushl  0x8(%ebp)
  80056c:	e8 aa fe ff ff       	call   80041b <fd_lookup>
  800571:	83 c4 08             	add    $0x8,%esp
  800574:	85 c0                	test   %eax,%eax
  800576:	78 10                	js     800588 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  800578:	83 ec 08             	sub    $0x8,%esp
  80057b:	6a 01                	push   $0x1
  80057d:	ff 75 f4             	pushl  -0xc(%ebp)
  800580:	e8 52 ff ff ff       	call   8004d7 <fd_close>
  800585:	83 c4 10             	add    $0x10,%esp
}
  800588:	c9                   	leave  
  800589:	c3                   	ret    

0080058a <close_all>:

void
close_all(void)
{
  80058a:	55                   	push   %ebp
  80058b:	89 e5                	mov    %esp,%ebp
  80058d:	53                   	push   %ebx
  80058e:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800591:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  800596:	83 ec 0c             	sub    $0xc,%esp
  800599:	53                   	push   %ebx
  80059a:	e8 c0 ff ff ff       	call   80055f <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  80059f:	43                   	inc    %ebx
  8005a0:	83 c4 10             	add    $0x10,%esp
  8005a3:	83 fb 20             	cmp    $0x20,%ebx
  8005a6:	75 ee                	jne    800596 <close_all+0xc>
		close(i);
}
  8005a8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8005ab:	c9                   	leave  
  8005ac:	c3                   	ret    

008005ad <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8005ad:	55                   	push   %ebp
  8005ae:	89 e5                	mov    %esp,%ebp
  8005b0:	57                   	push   %edi
  8005b1:	56                   	push   %esi
  8005b2:	53                   	push   %ebx
  8005b3:	83 ec 2c             	sub    $0x2c,%esp
  8005b6:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8005b9:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8005bc:	50                   	push   %eax
  8005bd:	ff 75 08             	pushl  0x8(%ebp)
  8005c0:	e8 56 fe ff ff       	call   80041b <fd_lookup>
  8005c5:	89 c3                	mov    %eax,%ebx
  8005c7:	83 c4 08             	add    $0x8,%esp
  8005ca:	85 c0                	test   %eax,%eax
  8005cc:	0f 88 c0 00 00 00    	js     800692 <dup+0xe5>
		return r;
	close(newfdnum);
  8005d2:	83 ec 0c             	sub    $0xc,%esp
  8005d5:	57                   	push   %edi
  8005d6:	e8 84 ff ff ff       	call   80055f <close>

	newfd = INDEX2FD(newfdnum);
  8005db:	8d b7 00 00 0d 00    	lea    0xd0000(%edi),%esi
  8005e1:	c1 e6 0c             	shl    $0xc,%esi
	ova = fd2data(oldfd);
  8005e4:	83 c4 04             	add    $0x4,%esp
  8005e7:	ff 75 e4             	pushl  -0x1c(%ebp)
  8005ea:	e8 a1 fd ff ff       	call   800390 <fd2data>
  8005ef:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  8005f1:	89 34 24             	mov    %esi,(%esp)
  8005f4:	e8 97 fd ff ff       	call   800390 <fd2data>
  8005f9:	83 c4 10             	add    $0x10,%esp
  8005fc:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8005ff:	89 d8                	mov    %ebx,%eax
  800601:	c1 e8 16             	shr    $0x16,%eax
  800604:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80060b:	a8 01                	test   $0x1,%al
  80060d:	74 37                	je     800646 <dup+0x99>
  80060f:	89 d8                	mov    %ebx,%eax
  800611:	c1 e8 0c             	shr    $0xc,%eax
  800614:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80061b:	f6 c2 01             	test   $0x1,%dl
  80061e:	74 26                	je     800646 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  800620:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800627:	83 ec 0c             	sub    $0xc,%esp
  80062a:	25 07 0e 00 00       	and    $0xe07,%eax
  80062f:	50                   	push   %eax
  800630:	ff 75 d4             	pushl  -0x2c(%ebp)
  800633:	6a 00                	push   $0x0
  800635:	53                   	push   %ebx
  800636:	6a 00                	push   $0x0
  800638:	e8 bb fb ff ff       	call   8001f8 <sys_page_map>
  80063d:	89 c3                	mov    %eax,%ebx
  80063f:	83 c4 20             	add    $0x20,%esp
  800642:	85 c0                	test   %eax,%eax
  800644:	78 2d                	js     800673 <dup+0xc6>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  800646:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800649:	89 c2                	mov    %eax,%edx
  80064b:	c1 ea 0c             	shr    $0xc,%edx
  80064e:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800655:	83 ec 0c             	sub    $0xc,%esp
  800658:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  80065e:	52                   	push   %edx
  80065f:	56                   	push   %esi
  800660:	6a 00                	push   $0x0
  800662:	50                   	push   %eax
  800663:	6a 00                	push   $0x0
  800665:	e8 8e fb ff ff       	call   8001f8 <sys_page_map>
  80066a:	89 c3                	mov    %eax,%ebx
  80066c:	83 c4 20             	add    $0x20,%esp
  80066f:	85 c0                	test   %eax,%eax
  800671:	79 1d                	jns    800690 <dup+0xe3>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  800673:	83 ec 08             	sub    $0x8,%esp
  800676:	56                   	push   %esi
  800677:	6a 00                	push   $0x0
  800679:	e8 a0 fb ff ff       	call   80021e <sys_page_unmap>
	sys_page_unmap(0, nva);
  80067e:	83 c4 08             	add    $0x8,%esp
  800681:	ff 75 d4             	pushl  -0x2c(%ebp)
  800684:	6a 00                	push   $0x0
  800686:	e8 93 fb ff ff       	call   80021e <sys_page_unmap>
	return r;
  80068b:	83 c4 10             	add    $0x10,%esp
  80068e:	eb 02                	jmp    800692 <dup+0xe5>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
		goto err;

	return newfdnum;
  800690:	89 fb                	mov    %edi,%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  800692:	89 d8                	mov    %ebx,%eax
  800694:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800697:	5b                   	pop    %ebx
  800698:	5e                   	pop    %esi
  800699:	5f                   	pop    %edi
  80069a:	c9                   	leave  
  80069b:	c3                   	ret    

0080069c <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80069c:	55                   	push   %ebp
  80069d:	89 e5                	mov    %esp,%ebp
  80069f:	53                   	push   %ebx
  8006a0:	83 ec 14             	sub    $0x14,%esp
  8006a3:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8006a6:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8006a9:	50                   	push   %eax
  8006aa:	53                   	push   %ebx
  8006ab:	e8 6b fd ff ff       	call   80041b <fd_lookup>
  8006b0:	83 c4 08             	add    $0x8,%esp
  8006b3:	85 c0                	test   %eax,%eax
  8006b5:	78 67                	js     80071e <read+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8006b7:	83 ec 08             	sub    $0x8,%esp
  8006ba:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8006bd:	50                   	push   %eax
  8006be:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8006c1:	ff 30                	pushl  (%eax)
  8006c3:	e8 a9 fd ff ff       	call   800471 <dev_lookup>
  8006c8:	83 c4 10             	add    $0x10,%esp
  8006cb:	85 c0                	test   %eax,%eax
  8006cd:	78 4f                	js     80071e <read+0x82>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8006cf:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8006d2:	8b 50 08             	mov    0x8(%eax),%edx
  8006d5:	83 e2 03             	and    $0x3,%edx
  8006d8:	83 fa 01             	cmp    $0x1,%edx
  8006db:	75 21                	jne    8006fe <read+0x62>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8006dd:	a1 04 40 80 00       	mov    0x804004,%eax
  8006e2:	8b 40 48             	mov    0x48(%eax),%eax
  8006e5:	83 ec 04             	sub    $0x4,%esp
  8006e8:	53                   	push   %ebx
  8006e9:	50                   	push   %eax
  8006ea:	68 79 1e 80 00       	push   $0x801e79
  8006ef:	e8 18 0a 00 00       	call   80110c <cprintf>
		return -E_INVAL;
  8006f4:	83 c4 10             	add    $0x10,%esp
  8006f7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8006fc:	eb 20                	jmp    80071e <read+0x82>
	}
	if (!dev->dev_read)
  8006fe:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800701:	8b 52 08             	mov    0x8(%edx),%edx
  800704:	85 d2                	test   %edx,%edx
  800706:	74 11                	je     800719 <read+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  800708:	83 ec 04             	sub    $0x4,%esp
  80070b:	ff 75 10             	pushl  0x10(%ebp)
  80070e:	ff 75 0c             	pushl  0xc(%ebp)
  800711:	50                   	push   %eax
  800712:	ff d2                	call   *%edx
  800714:	83 c4 10             	add    $0x10,%esp
  800717:	eb 05                	jmp    80071e <read+0x82>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  800719:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_read)(fd, buf, n);
}
  80071e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800721:	c9                   	leave  
  800722:	c3                   	ret    

00800723 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  800723:	55                   	push   %ebp
  800724:	89 e5                	mov    %esp,%ebp
  800726:	57                   	push   %edi
  800727:	56                   	push   %esi
  800728:	53                   	push   %ebx
  800729:	83 ec 0c             	sub    $0xc,%esp
  80072c:	8b 7d 08             	mov    0x8(%ebp),%edi
  80072f:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  800732:	85 f6                	test   %esi,%esi
  800734:	74 31                	je     800767 <readn+0x44>
  800736:	b8 00 00 00 00       	mov    $0x0,%eax
  80073b:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = read(fdnum, (char*)buf + tot, n - tot);
  800740:	83 ec 04             	sub    $0x4,%esp
  800743:	89 f2                	mov    %esi,%edx
  800745:	29 c2                	sub    %eax,%edx
  800747:	52                   	push   %edx
  800748:	03 45 0c             	add    0xc(%ebp),%eax
  80074b:	50                   	push   %eax
  80074c:	57                   	push   %edi
  80074d:	e8 4a ff ff ff       	call   80069c <read>
		if (m < 0)
  800752:	83 c4 10             	add    $0x10,%esp
  800755:	85 c0                	test   %eax,%eax
  800757:	78 17                	js     800770 <readn+0x4d>
			return m;
		if (m == 0)
  800759:	85 c0                	test   %eax,%eax
  80075b:	74 11                	je     80076e <readn+0x4b>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80075d:	01 c3                	add    %eax,%ebx
  80075f:	89 d8                	mov    %ebx,%eax
  800761:	39 f3                	cmp    %esi,%ebx
  800763:	72 db                	jb     800740 <readn+0x1d>
  800765:	eb 09                	jmp    800770 <readn+0x4d>
  800767:	b8 00 00 00 00       	mov    $0x0,%eax
  80076c:	eb 02                	jmp    800770 <readn+0x4d>
		m = read(fdnum, (char*)buf + tot, n - tot);
		if (m < 0)
			return m;
		if (m == 0)
  80076e:	89 d8                	mov    %ebx,%eax
			break;
	}
	return tot;
}
  800770:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800773:	5b                   	pop    %ebx
  800774:	5e                   	pop    %esi
  800775:	5f                   	pop    %edi
  800776:	c9                   	leave  
  800777:	c3                   	ret    

00800778 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  800778:	55                   	push   %ebp
  800779:	89 e5                	mov    %esp,%ebp
  80077b:	53                   	push   %ebx
  80077c:	83 ec 14             	sub    $0x14,%esp
  80077f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800782:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800785:	50                   	push   %eax
  800786:	53                   	push   %ebx
  800787:	e8 8f fc ff ff       	call   80041b <fd_lookup>
  80078c:	83 c4 08             	add    $0x8,%esp
  80078f:	85 c0                	test   %eax,%eax
  800791:	78 62                	js     8007f5 <write+0x7d>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800793:	83 ec 08             	sub    $0x8,%esp
  800796:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800799:	50                   	push   %eax
  80079a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80079d:	ff 30                	pushl  (%eax)
  80079f:	e8 cd fc ff ff       	call   800471 <dev_lookup>
  8007a4:	83 c4 10             	add    $0x10,%esp
  8007a7:	85 c0                	test   %eax,%eax
  8007a9:	78 4a                	js     8007f5 <write+0x7d>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8007ab:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8007ae:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8007b2:	75 21                	jne    8007d5 <write+0x5d>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8007b4:	a1 04 40 80 00       	mov    0x804004,%eax
  8007b9:	8b 40 48             	mov    0x48(%eax),%eax
  8007bc:	83 ec 04             	sub    $0x4,%esp
  8007bf:	53                   	push   %ebx
  8007c0:	50                   	push   %eax
  8007c1:	68 95 1e 80 00       	push   $0x801e95
  8007c6:	e8 41 09 00 00       	call   80110c <cprintf>
		return -E_INVAL;
  8007cb:	83 c4 10             	add    $0x10,%esp
  8007ce:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8007d3:	eb 20                	jmp    8007f5 <write+0x7d>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8007d5:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8007d8:	8b 52 0c             	mov    0xc(%edx),%edx
  8007db:	85 d2                	test   %edx,%edx
  8007dd:	74 11                	je     8007f0 <write+0x78>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8007df:	83 ec 04             	sub    $0x4,%esp
  8007e2:	ff 75 10             	pushl  0x10(%ebp)
  8007e5:	ff 75 0c             	pushl  0xc(%ebp)
  8007e8:	50                   	push   %eax
  8007e9:	ff d2                	call   *%edx
  8007eb:	83 c4 10             	add    $0x10,%esp
  8007ee:	eb 05                	jmp    8007f5 <write+0x7d>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8007f0:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  8007f5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007f8:	c9                   	leave  
  8007f9:	c3                   	ret    

008007fa <seek>:

int
seek(int fdnum, off_t offset)
{
  8007fa:	55                   	push   %ebp
  8007fb:	89 e5                	mov    %esp,%ebp
  8007fd:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800800:	8d 45 fc             	lea    -0x4(%ebp),%eax
  800803:	50                   	push   %eax
  800804:	ff 75 08             	pushl  0x8(%ebp)
  800807:	e8 0f fc ff ff       	call   80041b <fd_lookup>
  80080c:	83 c4 08             	add    $0x8,%esp
  80080f:	85 c0                	test   %eax,%eax
  800811:	78 0e                	js     800821 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  800813:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800816:	8b 55 0c             	mov    0xc(%ebp),%edx
  800819:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  80081c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800821:	c9                   	leave  
  800822:	c3                   	ret    

00800823 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  800823:	55                   	push   %ebp
  800824:	89 e5                	mov    %esp,%ebp
  800826:	53                   	push   %ebx
  800827:	83 ec 14             	sub    $0x14,%esp
  80082a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80082d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800830:	50                   	push   %eax
  800831:	53                   	push   %ebx
  800832:	e8 e4 fb ff ff       	call   80041b <fd_lookup>
  800837:	83 c4 08             	add    $0x8,%esp
  80083a:	85 c0                	test   %eax,%eax
  80083c:	78 5f                	js     80089d <ftruncate+0x7a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80083e:	83 ec 08             	sub    $0x8,%esp
  800841:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800844:	50                   	push   %eax
  800845:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800848:	ff 30                	pushl  (%eax)
  80084a:	e8 22 fc ff ff       	call   800471 <dev_lookup>
  80084f:	83 c4 10             	add    $0x10,%esp
  800852:	85 c0                	test   %eax,%eax
  800854:	78 47                	js     80089d <ftruncate+0x7a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800856:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800859:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80085d:	75 21                	jne    800880 <ftruncate+0x5d>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  80085f:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  800864:	8b 40 48             	mov    0x48(%eax),%eax
  800867:	83 ec 04             	sub    $0x4,%esp
  80086a:	53                   	push   %ebx
  80086b:	50                   	push   %eax
  80086c:	68 58 1e 80 00       	push   $0x801e58
  800871:	e8 96 08 00 00       	call   80110c <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  800876:	83 c4 10             	add    $0x10,%esp
  800879:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80087e:	eb 1d                	jmp    80089d <ftruncate+0x7a>
	}
	if (!dev->dev_trunc)
  800880:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800883:	8b 52 18             	mov    0x18(%edx),%edx
  800886:	85 d2                	test   %edx,%edx
  800888:	74 0e                	je     800898 <ftruncate+0x75>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80088a:	83 ec 08             	sub    $0x8,%esp
  80088d:	ff 75 0c             	pushl  0xc(%ebp)
  800890:	50                   	push   %eax
  800891:	ff d2                	call   *%edx
  800893:	83 c4 10             	add    $0x10,%esp
  800896:	eb 05                	jmp    80089d <ftruncate+0x7a>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  800898:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  80089d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8008a0:	c9                   	leave  
  8008a1:	c3                   	ret    

008008a2 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8008a2:	55                   	push   %ebp
  8008a3:	89 e5                	mov    %esp,%ebp
  8008a5:	53                   	push   %ebx
  8008a6:	83 ec 14             	sub    $0x14,%esp
  8008a9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8008ac:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8008af:	50                   	push   %eax
  8008b0:	ff 75 08             	pushl  0x8(%ebp)
  8008b3:	e8 63 fb ff ff       	call   80041b <fd_lookup>
  8008b8:	83 c4 08             	add    $0x8,%esp
  8008bb:	85 c0                	test   %eax,%eax
  8008bd:	78 52                	js     800911 <fstat+0x6f>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8008bf:	83 ec 08             	sub    $0x8,%esp
  8008c2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8008c5:	50                   	push   %eax
  8008c6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8008c9:	ff 30                	pushl  (%eax)
  8008cb:	e8 a1 fb ff ff       	call   800471 <dev_lookup>
  8008d0:	83 c4 10             	add    $0x10,%esp
  8008d3:	85 c0                	test   %eax,%eax
  8008d5:	78 3a                	js     800911 <fstat+0x6f>
		return r;
	if (!dev->dev_stat)
  8008d7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8008da:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8008de:	74 2c                	je     80090c <fstat+0x6a>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8008e0:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8008e3:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8008ea:	00 00 00 
	stat->st_isdir = 0;
  8008ed:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8008f4:	00 00 00 
	stat->st_dev = dev;
  8008f7:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8008fd:	83 ec 08             	sub    $0x8,%esp
  800900:	53                   	push   %ebx
  800901:	ff 75 f0             	pushl  -0x10(%ebp)
  800904:	ff 50 14             	call   *0x14(%eax)
  800907:	83 c4 10             	add    $0x10,%esp
  80090a:	eb 05                	jmp    800911 <fstat+0x6f>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  80090c:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  800911:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800914:	c9                   	leave  
  800915:	c3                   	ret    

00800916 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  800916:	55                   	push   %ebp
  800917:	89 e5                	mov    %esp,%ebp
  800919:	56                   	push   %esi
  80091a:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  80091b:	83 ec 08             	sub    $0x8,%esp
  80091e:	6a 00                	push   $0x0
  800920:	ff 75 08             	pushl  0x8(%ebp)
  800923:	e8 78 01 00 00       	call   800aa0 <open>
  800928:	89 c3                	mov    %eax,%ebx
  80092a:	83 c4 10             	add    $0x10,%esp
  80092d:	85 c0                	test   %eax,%eax
  80092f:	78 1b                	js     80094c <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  800931:	83 ec 08             	sub    $0x8,%esp
  800934:	ff 75 0c             	pushl  0xc(%ebp)
  800937:	50                   	push   %eax
  800938:	e8 65 ff ff ff       	call   8008a2 <fstat>
  80093d:	89 c6                	mov    %eax,%esi
	close(fd);
  80093f:	89 1c 24             	mov    %ebx,(%esp)
  800942:	e8 18 fc ff ff       	call   80055f <close>
	return r;
  800947:	83 c4 10             	add    $0x10,%esp
  80094a:	89 f3                	mov    %esi,%ebx
}
  80094c:	89 d8                	mov    %ebx,%eax
  80094e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800951:	5b                   	pop    %ebx
  800952:	5e                   	pop    %esi
  800953:	c9                   	leave  
  800954:	c3                   	ret    
  800955:	00 00                	add    %al,(%eax)
	...

00800958 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  800958:	55                   	push   %ebp
  800959:	89 e5                	mov    %esp,%ebp
  80095b:	56                   	push   %esi
  80095c:	53                   	push   %ebx
  80095d:	89 c3                	mov    %eax,%ebx
  80095f:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  800961:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  800968:	75 12                	jne    80097c <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  80096a:	83 ec 0c             	sub    $0xc,%esp
  80096d:	6a 01                	push   $0x1
  80096f:	e8 96 11 00 00       	call   801b0a <ipc_find_env>
  800974:	a3 00 40 80 00       	mov    %eax,0x804000
  800979:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  80097c:	6a 07                	push   $0x7
  80097e:	68 00 50 80 00       	push   $0x805000
  800983:	53                   	push   %ebx
  800984:	ff 35 00 40 80 00    	pushl  0x804000
  80098a:	e8 26 11 00 00       	call   801ab5 <ipc_send>
	
	return ipc_recv(NULL, dstva, NULL);
  80098f:	83 c4 0c             	add    $0xc,%esp
  800992:	6a 00                	push   $0x0
  800994:	56                   	push   %esi
  800995:	6a 00                	push   $0x0
  800997:	e8 a4 10 00 00       	call   801a40 <ipc_recv>
}
  80099c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80099f:	5b                   	pop    %ebx
  8009a0:	5e                   	pop    %esi
  8009a1:	c9                   	leave  
  8009a2:	c3                   	ret    

008009a3 <devfile_stat>:
}


static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8009a3:	55                   	push   %ebp
  8009a4:	89 e5                	mov    %esp,%ebp
  8009a6:	53                   	push   %ebx
  8009a7:	83 ec 04             	sub    $0x4,%esp
  8009aa:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8009ad:	8b 45 08             	mov    0x8(%ebp),%eax
  8009b0:	8b 40 0c             	mov    0xc(%eax),%eax
  8009b3:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0) {
  8009b8:	ba 00 00 00 00       	mov    $0x0,%edx
  8009bd:	b8 05 00 00 00       	mov    $0x5,%eax
  8009c2:	e8 91 ff ff ff       	call   800958 <fsipc>
  8009c7:	85 c0                	test   %eax,%eax
  8009c9:	78 2c                	js     8009f7 <devfile_stat+0x54>
		return r;
	}
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8009cb:	83 ec 08             	sub    $0x8,%esp
  8009ce:	68 00 50 80 00       	push   $0x805000
  8009d3:	53                   	push   %ebx
  8009d4:	e8 e9 0c 00 00       	call   8016c2 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8009d9:	a1 80 50 80 00       	mov    0x805080,%eax
  8009de:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8009e4:	a1 84 50 80 00       	mov    0x805084,%eax
  8009e9:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8009ef:	83 c4 10             	add    $0x10,%esp
  8009f2:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009f7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8009fa:	c9                   	leave  
  8009fb:	c3                   	ret    

008009fc <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8009fc:	55                   	push   %ebp
  8009fd:	89 e5                	mov    %esp,%ebp
  8009ff:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  800a02:	8b 45 08             	mov    0x8(%ebp),%eax
  800a05:	8b 40 0c             	mov    0xc(%eax),%eax
  800a08:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  800a0d:	ba 00 00 00 00       	mov    $0x0,%edx
  800a12:	b8 06 00 00 00       	mov    $0x6,%eax
  800a17:	e8 3c ff ff ff       	call   800958 <fsipc>
}
  800a1c:	c9                   	leave  
  800a1d:	c3                   	ret    

00800a1e <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  800a1e:	55                   	push   %ebp
  800a1f:	89 e5                	mov    %esp,%ebp
  800a21:	56                   	push   %esi
  800a22:	53                   	push   %ebx
  800a23:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  800a26:	8b 45 08             	mov    0x8(%ebp),%eax
  800a29:	8b 40 0c             	mov    0xc(%eax),%eax
  800a2c:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  800a31:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  800a37:	ba 00 00 00 00       	mov    $0x0,%edx
  800a3c:	b8 03 00 00 00       	mov    $0x3,%eax
  800a41:	e8 12 ff ff ff       	call   800958 <fsipc>
  800a46:	89 c3                	mov    %eax,%ebx
  800a48:	85 c0                	test   %eax,%eax
  800a4a:	78 4b                	js     800a97 <devfile_read+0x79>
		return r;
	assert(r <= n);
  800a4c:	39 c6                	cmp    %eax,%esi
  800a4e:	73 16                	jae    800a66 <devfile_read+0x48>
  800a50:	68 c4 1e 80 00       	push   $0x801ec4
  800a55:	68 cb 1e 80 00       	push   $0x801ecb
  800a5a:	6a 7d                	push   $0x7d
  800a5c:	68 e0 1e 80 00       	push   $0x801ee0
  800a61:	e8 ce 05 00 00       	call   801034 <_panic>
	assert(r <= PGSIZE);
  800a66:	3d 00 10 00 00       	cmp    $0x1000,%eax
  800a6b:	7e 16                	jle    800a83 <devfile_read+0x65>
  800a6d:	68 eb 1e 80 00       	push   $0x801eeb
  800a72:	68 cb 1e 80 00       	push   $0x801ecb
  800a77:	6a 7e                	push   $0x7e
  800a79:	68 e0 1e 80 00       	push   $0x801ee0
  800a7e:	e8 b1 05 00 00       	call   801034 <_panic>
	memmove(buf, &fsipcbuf, r);
  800a83:	83 ec 04             	sub    $0x4,%esp
  800a86:	50                   	push   %eax
  800a87:	68 00 50 80 00       	push   $0x805000
  800a8c:	ff 75 0c             	pushl  0xc(%ebp)
  800a8f:	e8 ef 0d 00 00       	call   801883 <memmove>
	return r;
  800a94:	83 c4 10             	add    $0x10,%esp
}
  800a97:	89 d8                	mov    %ebx,%eax
  800a99:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800a9c:	5b                   	pop    %ebx
  800a9d:	5e                   	pop    %esi
  800a9e:	c9                   	leave  
  800a9f:	c3                   	ret    

00800aa0 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  800aa0:	55                   	push   %ebp
  800aa1:	89 e5                	mov    %esp,%ebp
  800aa3:	56                   	push   %esi
  800aa4:	53                   	push   %ebx
  800aa5:	83 ec 1c             	sub    $0x1c,%esp
  800aa8:	8b 75 08             	mov    0x8(%ebp),%esi
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  800aab:	56                   	push   %esi
  800aac:	e8 bf 0b 00 00       	call   801670 <strlen>
  800ab1:	83 c4 10             	add    $0x10,%esp
  800ab4:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  800ab9:	7f 65                	jg     800b20 <open+0x80>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800abb:	83 ec 0c             	sub    $0xc,%esp
  800abe:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800ac1:	50                   	push   %eax
  800ac2:	e8 e1 f8 ff ff       	call   8003a8 <fd_alloc>
  800ac7:	89 c3                	mov    %eax,%ebx
  800ac9:	83 c4 10             	add    $0x10,%esp
  800acc:	85 c0                	test   %eax,%eax
  800ace:	78 55                	js     800b25 <open+0x85>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  800ad0:	83 ec 08             	sub    $0x8,%esp
  800ad3:	56                   	push   %esi
  800ad4:	68 00 50 80 00       	push   $0x805000
  800ad9:	e8 e4 0b 00 00       	call   8016c2 <strcpy>
	fsipcbuf.open.req_omode = mode;
  800ade:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ae1:	a3 00 54 80 00       	mov    %eax,0x805400



	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  800ae6:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800ae9:	b8 01 00 00 00       	mov    $0x1,%eax
  800aee:	e8 65 fe ff ff       	call   800958 <fsipc>
  800af3:	89 c3                	mov    %eax,%ebx
  800af5:	83 c4 10             	add    $0x10,%esp
  800af8:	85 c0                	test   %eax,%eax
  800afa:	79 12                	jns    800b0e <open+0x6e>
		fd_close(fd, 0);
  800afc:	83 ec 08             	sub    $0x8,%esp
  800aff:	6a 00                	push   $0x0
  800b01:	ff 75 f4             	pushl  -0xc(%ebp)
  800b04:	e8 ce f9 ff ff       	call   8004d7 <fd_close>
		return r;
  800b09:	83 c4 10             	add    $0x10,%esp
  800b0c:	eb 17                	jmp    800b25 <open+0x85>
	}

	return fd2num(fd);
  800b0e:	83 ec 0c             	sub    $0xc,%esp
  800b11:	ff 75 f4             	pushl  -0xc(%ebp)
  800b14:	e8 67 f8 ff ff       	call   800380 <fd2num>
  800b19:	89 c3                	mov    %eax,%ebx
  800b1b:	83 c4 10             	add    $0x10,%esp
  800b1e:	eb 05                	jmp    800b25 <open+0x85>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  800b20:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  800b25:	89 d8                	mov    %ebx,%eax
  800b27:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800b2a:	5b                   	pop    %ebx
  800b2b:	5e                   	pop    %esi
  800b2c:	c9                   	leave  
  800b2d:	c3                   	ret    
	...

00800b30 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  800b30:	55                   	push   %ebp
  800b31:	89 e5                	mov    %esp,%ebp
  800b33:	56                   	push   %esi
  800b34:	53                   	push   %ebx
  800b35:	8b 75 0c             	mov    0xc(%ebp),%esi
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  800b38:	83 ec 0c             	sub    $0xc,%esp
  800b3b:	ff 75 08             	pushl  0x8(%ebp)
  800b3e:	e8 4d f8 ff ff       	call   800390 <fd2data>
  800b43:	89 c3                	mov    %eax,%ebx
	strcpy(stat->st_name, "<pipe>");
  800b45:	83 c4 08             	add    $0x8,%esp
  800b48:	68 f7 1e 80 00       	push   $0x801ef7
  800b4d:	56                   	push   %esi
  800b4e:	e8 6f 0b 00 00       	call   8016c2 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  800b53:	8b 43 04             	mov    0x4(%ebx),%eax
  800b56:	2b 03                	sub    (%ebx),%eax
  800b58:	89 86 80 00 00 00    	mov    %eax,0x80(%esi)
	stat->st_isdir = 0;
  800b5e:	c7 86 84 00 00 00 00 	movl   $0x0,0x84(%esi)
  800b65:	00 00 00 
	stat->st_dev = &devpipe;
  800b68:	c7 86 88 00 00 00 20 	movl   $0x803020,0x88(%esi)
  800b6f:	30 80 00 
	return 0;
}
  800b72:	b8 00 00 00 00       	mov    $0x0,%eax
  800b77:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800b7a:	5b                   	pop    %ebx
  800b7b:	5e                   	pop    %esi
  800b7c:	c9                   	leave  
  800b7d:	c3                   	ret    

00800b7e <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  800b7e:	55                   	push   %ebp
  800b7f:	89 e5                	mov    %esp,%ebp
  800b81:	53                   	push   %ebx
  800b82:	83 ec 0c             	sub    $0xc,%esp
  800b85:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  800b88:	53                   	push   %ebx
  800b89:	6a 00                	push   $0x0
  800b8b:	e8 8e f6 ff ff       	call   80021e <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  800b90:	89 1c 24             	mov    %ebx,(%esp)
  800b93:	e8 f8 f7 ff ff       	call   800390 <fd2data>
  800b98:	83 c4 08             	add    $0x8,%esp
  800b9b:	50                   	push   %eax
  800b9c:	6a 00                	push   $0x0
  800b9e:	e8 7b f6 ff ff       	call   80021e <sys_page_unmap>
}
  800ba3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800ba6:	c9                   	leave  
  800ba7:	c3                   	ret    

00800ba8 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  800ba8:	55                   	push   %ebp
  800ba9:	89 e5                	mov    %esp,%ebp
  800bab:	57                   	push   %edi
  800bac:	56                   	push   %esi
  800bad:	53                   	push   %ebx
  800bae:	83 ec 1c             	sub    $0x1c,%esp
  800bb1:	89 c7                	mov    %eax,%edi
  800bb3:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  800bb6:	a1 04 40 80 00       	mov    0x804004,%eax
  800bbb:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  800bbe:	83 ec 0c             	sub    $0xc,%esp
  800bc1:	57                   	push   %edi
  800bc2:	e8 91 0f 00 00       	call   801b58 <pageref>
  800bc7:	89 c6                	mov    %eax,%esi
  800bc9:	83 c4 04             	add    $0x4,%esp
  800bcc:	ff 75 e4             	pushl  -0x1c(%ebp)
  800bcf:	e8 84 0f 00 00       	call   801b58 <pageref>
  800bd4:	83 c4 10             	add    $0x10,%esp
  800bd7:	39 c6                	cmp    %eax,%esi
  800bd9:	0f 94 c0             	sete   %al
  800bdc:	0f b6 c0             	movzbl %al,%eax
		nn = thisenv->env_runs;
  800bdf:	8b 15 04 40 80 00    	mov    0x804004,%edx
  800be5:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  800be8:	39 cb                	cmp    %ecx,%ebx
  800bea:	75 08                	jne    800bf4 <_pipeisclosed+0x4c>
			return ret;
		if (n != nn && ret == 1)
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
	}
}
  800bec:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bef:	5b                   	pop    %ebx
  800bf0:	5e                   	pop    %esi
  800bf1:	5f                   	pop    %edi
  800bf2:	c9                   	leave  
  800bf3:	c3                   	ret    
		n = thisenv->env_runs;
		ret = pageref(fd) == pageref(p);
		nn = thisenv->env_runs;
		if (n == nn)
			return ret;
		if (n != nn && ret == 1)
  800bf4:	83 f8 01             	cmp    $0x1,%eax
  800bf7:	75 bd                	jne    800bb6 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  800bf9:	8b 42 58             	mov    0x58(%edx),%eax
  800bfc:	6a 01                	push   $0x1
  800bfe:	50                   	push   %eax
  800bff:	53                   	push   %ebx
  800c00:	68 fe 1e 80 00       	push   $0x801efe
  800c05:	e8 02 05 00 00       	call   80110c <cprintf>
  800c0a:	83 c4 10             	add    $0x10,%esp
  800c0d:	eb a7                	jmp    800bb6 <_pipeisclosed+0xe>

00800c0f <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  800c0f:	55                   	push   %ebp
  800c10:	89 e5                	mov    %esp,%ebp
  800c12:	57                   	push   %edi
  800c13:	56                   	push   %esi
  800c14:	53                   	push   %ebx
  800c15:	83 ec 28             	sub    $0x28,%esp
  800c18:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  800c1b:	56                   	push   %esi
  800c1c:	e8 6f f7 ff ff       	call   800390 <fd2data>
  800c21:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800c23:	83 c4 10             	add    $0x10,%esp
  800c26:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800c2a:	75 4a                	jne    800c76 <devpipe_write+0x67>
  800c2c:	bf 00 00 00 00       	mov    $0x0,%edi
  800c31:	eb 56                	jmp    800c89 <devpipe_write+0x7a>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  800c33:	89 da                	mov    %ebx,%edx
  800c35:	89 f0                	mov    %esi,%eax
  800c37:	e8 6c ff ff ff       	call   800ba8 <_pipeisclosed>
  800c3c:	85 c0                	test   %eax,%eax
  800c3e:	75 4d                	jne    800c8d <devpipe_write+0x7e>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  800c40:	e8 68 f5 ff ff       	call   8001ad <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  800c45:	8b 43 04             	mov    0x4(%ebx),%eax
  800c48:	8b 13                	mov    (%ebx),%edx
  800c4a:	83 c2 20             	add    $0x20,%edx
  800c4d:	39 d0                	cmp    %edx,%eax
  800c4f:	73 e2                	jae    800c33 <devpipe_write+0x24>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  800c51:	89 c2                	mov    %eax,%edx
  800c53:	81 e2 1f 00 00 80    	and    $0x8000001f,%edx
  800c59:	79 05                	jns    800c60 <devpipe_write+0x51>
  800c5b:	4a                   	dec    %edx
  800c5c:	83 ca e0             	or     $0xffffffe0,%edx
  800c5f:	42                   	inc    %edx
  800c60:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c63:	8a 0c 39             	mov    (%ecx,%edi,1),%cl
  800c66:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  800c6a:	40                   	inc    %eax
  800c6b:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800c6e:	47                   	inc    %edi
  800c6f:	39 7d 10             	cmp    %edi,0x10(%ebp)
  800c72:	77 07                	ja     800c7b <devpipe_write+0x6c>
  800c74:	eb 13                	jmp    800c89 <devpipe_write+0x7a>
  800c76:	bf 00 00 00 00       	mov    $0x0,%edi
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  800c7b:	8b 43 04             	mov    0x4(%ebx),%eax
  800c7e:	8b 13                	mov    (%ebx),%edx
  800c80:	83 c2 20             	add    $0x20,%edx
  800c83:	39 d0                	cmp    %edx,%eax
  800c85:	73 ac                	jae    800c33 <devpipe_write+0x24>
  800c87:	eb c8                	jmp    800c51 <devpipe_write+0x42>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  800c89:	89 f8                	mov    %edi,%eax
  800c8b:	eb 05                	jmp    800c92 <devpipe_write+0x83>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  800c8d:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  800c92:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c95:	5b                   	pop    %ebx
  800c96:	5e                   	pop    %esi
  800c97:	5f                   	pop    %edi
  800c98:	c9                   	leave  
  800c99:	c3                   	ret    

00800c9a <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  800c9a:	55                   	push   %ebp
  800c9b:	89 e5                	mov    %esp,%ebp
  800c9d:	57                   	push   %edi
  800c9e:	56                   	push   %esi
  800c9f:	53                   	push   %ebx
  800ca0:	83 ec 18             	sub    $0x18,%esp
  800ca3:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  800ca6:	57                   	push   %edi
  800ca7:	e8 e4 f6 ff ff       	call   800390 <fd2data>
  800cac:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800cae:	83 c4 10             	add    $0x10,%esp
  800cb1:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800cb5:	75 44                	jne    800cfb <devpipe_read+0x61>
  800cb7:	be 00 00 00 00       	mov    $0x0,%esi
  800cbc:	eb 4f                	jmp    800d0d <devpipe_read+0x73>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
				return i;
  800cbe:	89 f0                	mov    %esi,%eax
  800cc0:	eb 54                	jmp    800d16 <devpipe_read+0x7c>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  800cc2:	89 da                	mov    %ebx,%edx
  800cc4:	89 f8                	mov    %edi,%eax
  800cc6:	e8 dd fe ff ff       	call   800ba8 <_pipeisclosed>
  800ccb:	85 c0                	test   %eax,%eax
  800ccd:	75 42                	jne    800d11 <devpipe_read+0x77>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  800ccf:	e8 d9 f4 ff ff       	call   8001ad <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  800cd4:	8b 03                	mov    (%ebx),%eax
  800cd6:	3b 43 04             	cmp    0x4(%ebx),%eax
  800cd9:	74 e7                	je     800cc2 <devpipe_read+0x28>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  800cdb:	25 1f 00 00 80       	and    $0x8000001f,%eax
  800ce0:	79 05                	jns    800ce7 <devpipe_read+0x4d>
  800ce2:	48                   	dec    %eax
  800ce3:	83 c8 e0             	or     $0xffffffe0,%eax
  800ce6:	40                   	inc    %eax
  800ce7:	8a 44 03 08          	mov    0x8(%ebx,%eax,1),%al
  800ceb:	8b 55 0c             	mov    0xc(%ebp),%edx
  800cee:	88 04 32             	mov    %al,(%edx,%esi,1)
		p->p_rpos++;
  800cf1:	ff 03                	incl   (%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800cf3:	46                   	inc    %esi
  800cf4:	39 75 10             	cmp    %esi,0x10(%ebp)
  800cf7:	77 07                	ja     800d00 <devpipe_read+0x66>
  800cf9:	eb 12                	jmp    800d0d <devpipe_read+0x73>
  800cfb:	be 00 00 00 00       	mov    $0x0,%esi
		while (p->p_rpos == p->p_wpos) {
  800d00:	8b 03                	mov    (%ebx),%eax
  800d02:	3b 43 04             	cmp    0x4(%ebx),%eax
  800d05:	75 d4                	jne    800cdb <devpipe_read+0x41>
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  800d07:	85 f6                	test   %esi,%esi
  800d09:	75 b3                	jne    800cbe <devpipe_read+0x24>
  800d0b:	eb b5                	jmp    800cc2 <devpipe_read+0x28>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  800d0d:	89 f0                	mov    %esi,%eax
  800d0f:	eb 05                	jmp    800d16 <devpipe_read+0x7c>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  800d11:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  800d16:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d19:	5b                   	pop    %ebx
  800d1a:	5e                   	pop    %esi
  800d1b:	5f                   	pop    %edi
  800d1c:	c9                   	leave  
  800d1d:	c3                   	ret    

00800d1e <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  800d1e:	55                   	push   %ebp
  800d1f:	89 e5                	mov    %esp,%ebp
  800d21:	57                   	push   %edi
  800d22:	56                   	push   %esi
  800d23:	53                   	push   %ebx
  800d24:	83 ec 28             	sub    $0x28,%esp
  800d27:	8b 7d 08             	mov    0x8(%ebp),%edi
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  800d2a:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800d2d:	50                   	push   %eax
  800d2e:	e8 75 f6 ff ff       	call   8003a8 <fd_alloc>
  800d33:	89 c3                	mov    %eax,%ebx
  800d35:	83 c4 10             	add    $0x10,%esp
  800d38:	85 c0                	test   %eax,%eax
  800d3a:	0f 88 24 01 00 00    	js     800e64 <pipe+0x146>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800d40:	83 ec 04             	sub    $0x4,%esp
  800d43:	68 07 04 00 00       	push   $0x407
  800d48:	ff 75 e4             	pushl  -0x1c(%ebp)
  800d4b:	6a 00                	push   $0x0
  800d4d:	e8 82 f4 ff ff       	call   8001d4 <sys_page_alloc>
  800d52:	89 c3                	mov    %eax,%ebx
  800d54:	83 c4 10             	add    $0x10,%esp
  800d57:	85 c0                	test   %eax,%eax
  800d59:	0f 88 05 01 00 00    	js     800e64 <pipe+0x146>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  800d5f:	83 ec 0c             	sub    $0xc,%esp
  800d62:	8d 45 e0             	lea    -0x20(%ebp),%eax
  800d65:	50                   	push   %eax
  800d66:	e8 3d f6 ff ff       	call   8003a8 <fd_alloc>
  800d6b:	89 c3                	mov    %eax,%ebx
  800d6d:	83 c4 10             	add    $0x10,%esp
  800d70:	85 c0                	test   %eax,%eax
  800d72:	0f 88 dc 00 00 00    	js     800e54 <pipe+0x136>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800d78:	83 ec 04             	sub    $0x4,%esp
  800d7b:	68 07 04 00 00       	push   $0x407
  800d80:	ff 75 e0             	pushl  -0x20(%ebp)
  800d83:	6a 00                	push   $0x0
  800d85:	e8 4a f4 ff ff       	call   8001d4 <sys_page_alloc>
  800d8a:	89 c3                	mov    %eax,%ebx
  800d8c:	83 c4 10             	add    $0x10,%esp
  800d8f:	85 c0                	test   %eax,%eax
  800d91:	0f 88 bd 00 00 00    	js     800e54 <pipe+0x136>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  800d97:	83 ec 0c             	sub    $0xc,%esp
  800d9a:	ff 75 e4             	pushl  -0x1c(%ebp)
  800d9d:	e8 ee f5 ff ff       	call   800390 <fd2data>
  800da2:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800da4:	83 c4 0c             	add    $0xc,%esp
  800da7:	68 07 04 00 00       	push   $0x407
  800dac:	50                   	push   %eax
  800dad:	6a 00                	push   $0x0
  800daf:	e8 20 f4 ff ff       	call   8001d4 <sys_page_alloc>
  800db4:	89 c3                	mov    %eax,%ebx
  800db6:	83 c4 10             	add    $0x10,%esp
  800db9:	85 c0                	test   %eax,%eax
  800dbb:	0f 88 83 00 00 00    	js     800e44 <pipe+0x126>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800dc1:	83 ec 0c             	sub    $0xc,%esp
  800dc4:	ff 75 e0             	pushl  -0x20(%ebp)
  800dc7:	e8 c4 f5 ff ff       	call   800390 <fd2data>
  800dcc:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  800dd3:	50                   	push   %eax
  800dd4:	6a 00                	push   $0x0
  800dd6:	56                   	push   %esi
  800dd7:	6a 00                	push   $0x0
  800dd9:	e8 1a f4 ff ff       	call   8001f8 <sys_page_map>
  800dde:	89 c3                	mov    %eax,%ebx
  800de0:	83 c4 20             	add    $0x20,%esp
  800de3:	85 c0                	test   %eax,%eax
  800de5:	78 4f                	js     800e36 <pipe+0x118>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  800de7:	8b 15 20 30 80 00    	mov    0x803020,%edx
  800ded:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800df0:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  800df2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800df5:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  800dfc:	8b 15 20 30 80 00    	mov    0x803020,%edx
  800e02:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800e05:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  800e07:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800e0a:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  800e11:	83 ec 0c             	sub    $0xc,%esp
  800e14:	ff 75 e4             	pushl  -0x1c(%ebp)
  800e17:	e8 64 f5 ff ff       	call   800380 <fd2num>
  800e1c:	89 07                	mov    %eax,(%edi)
	pfd[1] = fd2num(fd1);
  800e1e:	83 c4 04             	add    $0x4,%esp
  800e21:	ff 75 e0             	pushl  -0x20(%ebp)
  800e24:	e8 57 f5 ff ff       	call   800380 <fd2num>
  800e29:	89 47 04             	mov    %eax,0x4(%edi)
	return 0;
  800e2c:	83 c4 10             	add    $0x10,%esp
  800e2f:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e34:	eb 2e                	jmp    800e64 <pipe+0x146>

    err3:
	sys_page_unmap(0, va);
  800e36:	83 ec 08             	sub    $0x8,%esp
  800e39:	56                   	push   %esi
  800e3a:	6a 00                	push   $0x0
  800e3c:	e8 dd f3 ff ff       	call   80021e <sys_page_unmap>
  800e41:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  800e44:	83 ec 08             	sub    $0x8,%esp
  800e47:	ff 75 e0             	pushl  -0x20(%ebp)
  800e4a:	6a 00                	push   $0x0
  800e4c:	e8 cd f3 ff ff       	call   80021e <sys_page_unmap>
  800e51:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  800e54:	83 ec 08             	sub    $0x8,%esp
  800e57:	ff 75 e4             	pushl  -0x1c(%ebp)
  800e5a:	6a 00                	push   $0x0
  800e5c:	e8 bd f3 ff ff       	call   80021e <sys_page_unmap>
  800e61:	83 c4 10             	add    $0x10,%esp
    err:
	return r;
}
  800e64:	89 d8                	mov    %ebx,%eax
  800e66:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e69:	5b                   	pop    %ebx
  800e6a:	5e                   	pop    %esi
  800e6b:	5f                   	pop    %edi
  800e6c:	c9                   	leave  
  800e6d:	c3                   	ret    

00800e6e <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  800e6e:	55                   	push   %ebp
  800e6f:	89 e5                	mov    %esp,%ebp
  800e71:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800e74:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800e77:	50                   	push   %eax
  800e78:	ff 75 08             	pushl  0x8(%ebp)
  800e7b:	e8 9b f5 ff ff       	call   80041b <fd_lookup>
  800e80:	83 c4 10             	add    $0x10,%esp
  800e83:	85 c0                	test   %eax,%eax
  800e85:	78 18                	js     800e9f <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  800e87:	83 ec 0c             	sub    $0xc,%esp
  800e8a:	ff 75 f4             	pushl  -0xc(%ebp)
  800e8d:	e8 fe f4 ff ff       	call   800390 <fd2data>
	return _pipeisclosed(fd, p);
  800e92:	89 c2                	mov    %eax,%edx
  800e94:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800e97:	e8 0c fd ff ff       	call   800ba8 <_pipeisclosed>
  800e9c:	83 c4 10             	add    $0x10,%esp
}
  800e9f:	c9                   	leave  
  800ea0:	c3                   	ret    
  800ea1:	00 00                	add    %al,(%eax)
	...

00800ea4 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  800ea4:	55                   	push   %ebp
  800ea5:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  800ea7:	b8 00 00 00 00       	mov    $0x0,%eax
  800eac:	c9                   	leave  
  800ead:	c3                   	ret    

00800eae <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  800eae:	55                   	push   %ebp
  800eaf:	89 e5                	mov    %esp,%ebp
  800eb1:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  800eb4:	68 16 1f 80 00       	push   $0x801f16
  800eb9:	ff 75 0c             	pushl  0xc(%ebp)
  800ebc:	e8 01 08 00 00       	call   8016c2 <strcpy>
	return 0;
}
  800ec1:	b8 00 00 00 00       	mov    $0x0,%eax
  800ec6:	c9                   	leave  
  800ec7:	c3                   	ret    

00800ec8 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  800ec8:	55                   	push   %ebp
  800ec9:	89 e5                	mov    %esp,%ebp
  800ecb:	57                   	push   %edi
  800ecc:	56                   	push   %esi
  800ecd:	53                   	push   %ebx
  800ece:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800ed4:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800ed8:	74 45                	je     800f1f <devcons_write+0x57>
  800eda:	b8 00 00 00 00       	mov    $0x0,%eax
  800edf:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  800ee4:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  800eea:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800eed:	29 c3                	sub    %eax,%ebx
		if (m > sizeof(buf) - 1)
  800eef:	83 fb 7f             	cmp    $0x7f,%ebx
  800ef2:	76 05                	jbe    800ef9 <devcons_write+0x31>
			m = sizeof(buf) - 1;
  800ef4:	bb 7f 00 00 00       	mov    $0x7f,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  800ef9:	83 ec 04             	sub    $0x4,%esp
  800efc:	53                   	push   %ebx
  800efd:	03 45 0c             	add    0xc(%ebp),%eax
  800f00:	50                   	push   %eax
  800f01:	57                   	push   %edi
  800f02:	e8 7c 09 00 00       	call   801883 <memmove>
		sys_cputs(buf, m);
  800f07:	83 c4 08             	add    $0x8,%esp
  800f0a:	53                   	push   %ebx
  800f0b:	57                   	push   %edi
  800f0c:	e8 0c f2 ff ff       	call   80011d <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800f11:	01 de                	add    %ebx,%esi
  800f13:	89 f0                	mov    %esi,%eax
  800f15:	83 c4 10             	add    $0x10,%esp
  800f18:	3b 75 10             	cmp    0x10(%ebp),%esi
  800f1b:	72 cd                	jb     800eea <devcons_write+0x22>
  800f1d:	eb 05                	jmp    800f24 <devcons_write+0x5c>
  800f1f:	be 00 00 00 00       	mov    $0x0,%esi
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  800f24:	89 f0                	mov    %esi,%eax
  800f26:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f29:	5b                   	pop    %ebx
  800f2a:	5e                   	pop    %esi
  800f2b:	5f                   	pop    %edi
  800f2c:	c9                   	leave  
  800f2d:	c3                   	ret    

00800f2e <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  800f2e:	55                   	push   %ebp
  800f2f:	89 e5                	mov    %esp,%ebp
  800f31:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
  800f34:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800f38:	75 07                	jne    800f41 <devcons_read+0x13>
  800f3a:	eb 25                	jmp    800f61 <devcons_read+0x33>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  800f3c:	e8 6c f2 ff ff       	call   8001ad <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  800f41:	e8 fd f1 ff ff       	call   800143 <sys_cgetc>
  800f46:	85 c0                	test   %eax,%eax
  800f48:	74 f2                	je     800f3c <devcons_read+0xe>
  800f4a:	89 c2                	mov    %eax,%edx
		sys_yield();
	if (c < 0)
  800f4c:	85 c0                	test   %eax,%eax
  800f4e:	78 1d                	js     800f6d <devcons_read+0x3f>
		return c;
	if (c == 0x04)	// ctl-d is eof
  800f50:	83 f8 04             	cmp    $0x4,%eax
  800f53:	74 13                	je     800f68 <devcons_read+0x3a>
		return 0;
	*(char*)vbuf = c;
  800f55:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f58:	88 10                	mov    %dl,(%eax)
	return 1;
  800f5a:	b8 01 00 00 00       	mov    $0x1,%eax
  800f5f:	eb 0c                	jmp    800f6d <devcons_read+0x3f>
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
		return 0;
  800f61:	b8 00 00 00 00       	mov    $0x0,%eax
  800f66:	eb 05                	jmp    800f6d <devcons_read+0x3f>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  800f68:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  800f6d:	c9                   	leave  
  800f6e:	c3                   	ret    

00800f6f <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  800f6f:	55                   	push   %ebp
  800f70:	89 e5                	mov    %esp,%ebp
  800f72:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  800f75:	8b 45 08             	mov    0x8(%ebp),%eax
  800f78:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  800f7b:	6a 01                	push   $0x1
  800f7d:	8d 45 f7             	lea    -0x9(%ebp),%eax
  800f80:	50                   	push   %eax
  800f81:	e8 97 f1 ff ff       	call   80011d <sys_cputs>
  800f86:	83 c4 10             	add    $0x10,%esp
}
  800f89:	c9                   	leave  
  800f8a:	c3                   	ret    

00800f8b <getchar>:

int
getchar(void)
{
  800f8b:	55                   	push   %ebp
  800f8c:	89 e5                	mov    %esp,%ebp
  800f8e:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  800f91:	6a 01                	push   $0x1
  800f93:	8d 45 f7             	lea    -0x9(%ebp),%eax
  800f96:	50                   	push   %eax
  800f97:	6a 00                	push   $0x0
  800f99:	e8 fe f6 ff ff       	call   80069c <read>
	if (r < 0)
  800f9e:	83 c4 10             	add    $0x10,%esp
  800fa1:	85 c0                	test   %eax,%eax
  800fa3:	78 0f                	js     800fb4 <getchar+0x29>
		return r;
	if (r < 1)
  800fa5:	85 c0                	test   %eax,%eax
  800fa7:	7e 06                	jle    800faf <getchar+0x24>
		return -E_EOF;
	return c;
  800fa9:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  800fad:	eb 05                	jmp    800fb4 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  800faf:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  800fb4:	c9                   	leave  
  800fb5:	c3                   	ret    

00800fb6 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  800fb6:	55                   	push   %ebp
  800fb7:	89 e5                	mov    %esp,%ebp
  800fb9:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800fbc:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800fbf:	50                   	push   %eax
  800fc0:	ff 75 08             	pushl  0x8(%ebp)
  800fc3:	e8 53 f4 ff ff       	call   80041b <fd_lookup>
  800fc8:	83 c4 10             	add    $0x10,%esp
  800fcb:	85 c0                	test   %eax,%eax
  800fcd:	78 11                	js     800fe0 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  800fcf:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800fd2:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  800fd8:	39 10                	cmp    %edx,(%eax)
  800fda:	0f 94 c0             	sete   %al
  800fdd:	0f b6 c0             	movzbl %al,%eax
}
  800fe0:	c9                   	leave  
  800fe1:	c3                   	ret    

00800fe2 <opencons>:

int
opencons(void)
{
  800fe2:	55                   	push   %ebp
  800fe3:	89 e5                	mov    %esp,%ebp
  800fe5:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  800fe8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800feb:	50                   	push   %eax
  800fec:	e8 b7 f3 ff ff       	call   8003a8 <fd_alloc>
  800ff1:	83 c4 10             	add    $0x10,%esp
  800ff4:	85 c0                	test   %eax,%eax
  800ff6:	78 3a                	js     801032 <opencons+0x50>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  800ff8:	83 ec 04             	sub    $0x4,%esp
  800ffb:	68 07 04 00 00       	push   $0x407
  801000:	ff 75 f4             	pushl  -0xc(%ebp)
  801003:	6a 00                	push   $0x0
  801005:	e8 ca f1 ff ff       	call   8001d4 <sys_page_alloc>
  80100a:	83 c4 10             	add    $0x10,%esp
  80100d:	85 c0                	test   %eax,%eax
  80100f:	78 21                	js     801032 <opencons+0x50>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801011:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801017:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80101a:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  80101c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80101f:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801026:	83 ec 0c             	sub    $0xc,%esp
  801029:	50                   	push   %eax
  80102a:	e8 51 f3 ff ff       	call   800380 <fd2num>
  80102f:	83 c4 10             	add    $0x10,%esp
}
  801032:	c9                   	leave  
  801033:	c3                   	ret    

00801034 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801034:	55                   	push   %ebp
  801035:	89 e5                	mov    %esp,%ebp
  801037:	56                   	push   %esi
  801038:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801039:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80103c:	8b 1d 00 30 80 00    	mov    0x803000,%ebx
  801042:	e8 42 f1 ff ff       	call   800189 <sys_getenvid>
  801047:	83 ec 0c             	sub    $0xc,%esp
  80104a:	ff 75 0c             	pushl  0xc(%ebp)
  80104d:	ff 75 08             	pushl  0x8(%ebp)
  801050:	53                   	push   %ebx
  801051:	50                   	push   %eax
  801052:	68 24 1f 80 00       	push   $0x801f24
  801057:	e8 b0 00 00 00       	call   80110c <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80105c:	83 c4 18             	add    $0x18,%esp
  80105f:	56                   	push   %esi
  801060:	ff 75 10             	pushl  0x10(%ebp)
  801063:	e8 53 00 00 00       	call   8010bb <vcprintf>
	cprintf("\n");
  801068:	c7 04 24 0f 1f 80 00 	movl   $0x801f0f,(%esp)
  80106f:	e8 98 00 00 00       	call   80110c <cprintf>
  801074:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801077:	cc                   	int3   
  801078:	eb fd                	jmp    801077 <_panic+0x43>
	...

0080107c <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80107c:	55                   	push   %ebp
  80107d:	89 e5                	mov    %esp,%ebp
  80107f:	53                   	push   %ebx
  801080:	83 ec 04             	sub    $0x4,%esp
  801083:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  801086:	8b 03                	mov    (%ebx),%eax
  801088:	8b 55 08             	mov    0x8(%ebp),%edx
  80108b:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  80108f:	40                   	inc    %eax
  801090:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  801092:	3d ff 00 00 00       	cmp    $0xff,%eax
  801097:	75 1a                	jne    8010b3 <putch+0x37>
		sys_cputs(b->buf, b->idx);
  801099:	83 ec 08             	sub    $0x8,%esp
  80109c:	68 ff 00 00 00       	push   $0xff
  8010a1:	8d 43 08             	lea    0x8(%ebx),%eax
  8010a4:	50                   	push   %eax
  8010a5:	e8 73 f0 ff ff       	call   80011d <sys_cputs>
		b->idx = 0;
  8010aa:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8010b0:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8010b3:	ff 43 04             	incl   0x4(%ebx)
}
  8010b6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8010b9:	c9                   	leave  
  8010ba:	c3                   	ret    

008010bb <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8010bb:	55                   	push   %ebp
  8010bc:	89 e5                	mov    %esp,%ebp
  8010be:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8010c4:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8010cb:	00 00 00 
	b.cnt = 0;
  8010ce:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8010d5:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8010d8:	ff 75 0c             	pushl  0xc(%ebp)
  8010db:	ff 75 08             	pushl  0x8(%ebp)
  8010de:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8010e4:	50                   	push   %eax
  8010e5:	68 7c 10 80 00       	push   $0x80107c
  8010ea:	e8 82 01 00 00       	call   801271 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8010ef:	83 c4 08             	add    $0x8,%esp
  8010f2:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8010f8:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8010fe:	50                   	push   %eax
  8010ff:	e8 19 f0 ff ff       	call   80011d <sys_cputs>

	return b.cnt;
}
  801104:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80110a:	c9                   	leave  
  80110b:	c3                   	ret    

0080110c <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80110c:	55                   	push   %ebp
  80110d:	89 e5                	mov    %esp,%ebp
  80110f:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  801112:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  801115:	50                   	push   %eax
  801116:	ff 75 08             	pushl  0x8(%ebp)
  801119:	e8 9d ff ff ff       	call   8010bb <vcprintf>
	va_end(ap);

	return cnt;
}
  80111e:	c9                   	leave  
  80111f:	c3                   	ret    

00801120 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  801120:	55                   	push   %ebp
  801121:	89 e5                	mov    %esp,%ebp
  801123:	57                   	push   %edi
  801124:	56                   	push   %esi
  801125:	53                   	push   %ebx
  801126:	83 ec 2c             	sub    $0x2c,%esp
  801129:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80112c:	89 d6                	mov    %edx,%esi
  80112e:	8b 45 08             	mov    0x8(%ebp),%eax
  801131:	8b 55 0c             	mov    0xc(%ebp),%edx
  801134:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801137:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80113a:	8b 45 10             	mov    0x10(%ebp),%eax
  80113d:	8b 5d 14             	mov    0x14(%ebp),%ebx
  801140:	8b 7d 18             	mov    0x18(%ebp),%edi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  801143:	89 45 d0             	mov    %eax,-0x30(%ebp)
  801146:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  80114d:	39 55 d4             	cmp    %edx,-0x2c(%ebp)
  801150:	72 0c                	jb     80115e <printnum+0x3e>
  801152:	3b 45 d8             	cmp    -0x28(%ebp),%eax
  801155:	76 07                	jbe    80115e <printnum+0x3e>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  801157:	4b                   	dec    %ebx
  801158:	85 db                	test   %ebx,%ebx
  80115a:	7f 31                	jg     80118d <printnum+0x6d>
  80115c:	eb 3f                	jmp    80119d <printnum+0x7d>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80115e:	83 ec 0c             	sub    $0xc,%esp
  801161:	57                   	push   %edi
  801162:	4b                   	dec    %ebx
  801163:	53                   	push   %ebx
  801164:	50                   	push   %eax
  801165:	83 ec 08             	sub    $0x8,%esp
  801168:	ff 75 d4             	pushl  -0x2c(%ebp)
  80116b:	ff 75 d0             	pushl  -0x30(%ebp)
  80116e:	ff 75 dc             	pushl  -0x24(%ebp)
  801171:	ff 75 d8             	pushl  -0x28(%ebp)
  801174:	e8 23 0a 00 00       	call   801b9c <__udivdi3>
  801179:	83 c4 18             	add    $0x18,%esp
  80117c:	52                   	push   %edx
  80117d:	50                   	push   %eax
  80117e:	89 f2                	mov    %esi,%edx
  801180:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801183:	e8 98 ff ff ff       	call   801120 <printnum>
  801188:	83 c4 20             	add    $0x20,%esp
  80118b:	eb 10                	jmp    80119d <printnum+0x7d>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80118d:	83 ec 08             	sub    $0x8,%esp
  801190:	56                   	push   %esi
  801191:	57                   	push   %edi
  801192:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  801195:	4b                   	dec    %ebx
  801196:	83 c4 10             	add    $0x10,%esp
  801199:	85 db                	test   %ebx,%ebx
  80119b:	7f f0                	jg     80118d <printnum+0x6d>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80119d:	83 ec 08             	sub    $0x8,%esp
  8011a0:	56                   	push   %esi
  8011a1:	83 ec 04             	sub    $0x4,%esp
  8011a4:	ff 75 d4             	pushl  -0x2c(%ebp)
  8011a7:	ff 75 d0             	pushl  -0x30(%ebp)
  8011aa:	ff 75 dc             	pushl  -0x24(%ebp)
  8011ad:	ff 75 d8             	pushl  -0x28(%ebp)
  8011b0:	e8 03 0b 00 00       	call   801cb8 <__umoddi3>
  8011b5:	83 c4 14             	add    $0x14,%esp
  8011b8:	0f be 80 47 1f 80 00 	movsbl 0x801f47(%eax),%eax
  8011bf:	50                   	push   %eax
  8011c0:	ff 55 e4             	call   *-0x1c(%ebp)
  8011c3:	83 c4 10             	add    $0x10,%esp
}
  8011c6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011c9:	5b                   	pop    %ebx
  8011ca:	5e                   	pop    %esi
  8011cb:	5f                   	pop    %edi
  8011cc:	c9                   	leave  
  8011cd:	c3                   	ret    

008011ce <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8011ce:	55                   	push   %ebp
  8011cf:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8011d1:	83 fa 01             	cmp    $0x1,%edx
  8011d4:	7e 0e                	jle    8011e4 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8011d6:	8b 10                	mov    (%eax),%edx
  8011d8:	8d 4a 08             	lea    0x8(%edx),%ecx
  8011db:	89 08                	mov    %ecx,(%eax)
  8011dd:	8b 02                	mov    (%edx),%eax
  8011df:	8b 52 04             	mov    0x4(%edx),%edx
  8011e2:	eb 22                	jmp    801206 <getuint+0x38>
	else if (lflag)
  8011e4:	85 d2                	test   %edx,%edx
  8011e6:	74 10                	je     8011f8 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8011e8:	8b 10                	mov    (%eax),%edx
  8011ea:	8d 4a 04             	lea    0x4(%edx),%ecx
  8011ed:	89 08                	mov    %ecx,(%eax)
  8011ef:	8b 02                	mov    (%edx),%eax
  8011f1:	ba 00 00 00 00       	mov    $0x0,%edx
  8011f6:	eb 0e                	jmp    801206 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8011f8:	8b 10                	mov    (%eax),%edx
  8011fa:	8d 4a 04             	lea    0x4(%edx),%ecx
  8011fd:	89 08                	mov    %ecx,(%eax)
  8011ff:	8b 02                	mov    (%edx),%eax
  801201:	ba 00 00 00 00       	mov    $0x0,%edx
}
  801206:	c9                   	leave  
  801207:	c3                   	ret    

00801208 <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
  801208:	55                   	push   %ebp
  801209:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80120b:	83 fa 01             	cmp    $0x1,%edx
  80120e:	7e 0e                	jle    80121e <getint+0x16>
		return va_arg(*ap, long long);
  801210:	8b 10                	mov    (%eax),%edx
  801212:	8d 4a 08             	lea    0x8(%edx),%ecx
  801215:	89 08                	mov    %ecx,(%eax)
  801217:	8b 02                	mov    (%edx),%eax
  801219:	8b 52 04             	mov    0x4(%edx),%edx
  80121c:	eb 1a                	jmp    801238 <getint+0x30>
	else if (lflag)
  80121e:	85 d2                	test   %edx,%edx
  801220:	74 0c                	je     80122e <getint+0x26>
		return va_arg(*ap, long);
  801222:	8b 10                	mov    (%eax),%edx
  801224:	8d 4a 04             	lea    0x4(%edx),%ecx
  801227:	89 08                	mov    %ecx,(%eax)
  801229:	8b 02                	mov    (%edx),%eax
  80122b:	99                   	cltd   
  80122c:	eb 0a                	jmp    801238 <getint+0x30>
	else
		return va_arg(*ap, int);
  80122e:	8b 10                	mov    (%eax),%edx
  801230:	8d 4a 04             	lea    0x4(%edx),%ecx
  801233:	89 08                	mov    %ecx,(%eax)
  801235:	8b 02                	mov    (%edx),%eax
  801237:	99                   	cltd   
}
  801238:	c9                   	leave  
  801239:	c3                   	ret    

0080123a <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80123a:	55                   	push   %ebp
  80123b:	89 e5                	mov    %esp,%ebp
  80123d:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  801240:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  801243:	8b 10                	mov    (%eax),%edx
  801245:	3b 50 04             	cmp    0x4(%eax),%edx
  801248:	73 08                	jae    801252 <sprintputch+0x18>
		*b->buf++ = ch;
  80124a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80124d:	88 0a                	mov    %cl,(%edx)
  80124f:	42                   	inc    %edx
  801250:	89 10                	mov    %edx,(%eax)
}
  801252:	c9                   	leave  
  801253:	c3                   	ret    

00801254 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  801254:	55                   	push   %ebp
  801255:	89 e5                	mov    %esp,%ebp
  801257:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  80125a:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80125d:	50                   	push   %eax
  80125e:	ff 75 10             	pushl  0x10(%ebp)
  801261:	ff 75 0c             	pushl  0xc(%ebp)
  801264:	ff 75 08             	pushl  0x8(%ebp)
  801267:	e8 05 00 00 00       	call   801271 <vprintfmt>
	va_end(ap);
  80126c:	83 c4 10             	add    $0x10,%esp
}
  80126f:	c9                   	leave  
  801270:	c3                   	ret    

00801271 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  801271:	55                   	push   %ebp
  801272:	89 e5                	mov    %esp,%ebp
  801274:	57                   	push   %edi
  801275:	56                   	push   %esi
  801276:	53                   	push   %ebx
  801277:	83 ec 2c             	sub    $0x2c,%esp
  80127a:	8b 7d 0c             	mov    0xc(%ebp),%edi
  80127d:	8b 75 10             	mov    0x10(%ebp),%esi
  801280:	eb 13                	jmp    801295 <vprintfmt+0x24>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  801282:	85 c0                	test   %eax,%eax
  801284:	0f 84 6d 03 00 00    	je     8015f7 <vprintfmt+0x386>
				return;
			putch(ch, putdat);
  80128a:	83 ec 08             	sub    $0x8,%esp
  80128d:	57                   	push   %edi
  80128e:	50                   	push   %eax
  80128f:	ff 55 08             	call   *0x8(%ebp)
  801292:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  801295:	0f b6 06             	movzbl (%esi),%eax
  801298:	46                   	inc    %esi
  801299:	83 f8 25             	cmp    $0x25,%eax
  80129c:	75 e4                	jne    801282 <vprintfmt+0x11>
  80129e:	c6 45 dc 20          	movb   $0x20,-0x24(%ebp)
  8012a2:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  8012a9:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
  8012b0:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  8012b7:	b9 00 00 00 00       	mov    $0x0,%ecx
  8012bc:	eb 28                	jmp    8012e6 <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8012be:	89 de                	mov    %ebx,%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  8012c0:	c6 45 dc 2d          	movb   $0x2d,-0x24(%ebp)
  8012c4:	eb 20                	jmp    8012e6 <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8012c6:	89 de                	mov    %ebx,%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8012c8:	c6 45 dc 30          	movb   $0x30,-0x24(%ebp)
  8012cc:	eb 18                	jmp    8012e6 <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8012ce:	89 de                	mov    %ebx,%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  8012d0:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  8012d7:	eb 0d                	jmp    8012e6 <vprintfmt+0x75>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  8012d9:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8012dc:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8012df:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8012e6:	8a 06                	mov    (%esi),%al
  8012e8:	0f b6 d0             	movzbl %al,%edx
  8012eb:	8d 5e 01             	lea    0x1(%esi),%ebx
  8012ee:	83 e8 23             	sub    $0x23,%eax
  8012f1:	3c 55                	cmp    $0x55,%al
  8012f3:	0f 87 e0 02 00 00    	ja     8015d9 <vprintfmt+0x368>
  8012f9:	0f b6 c0             	movzbl %al,%eax
  8012fc:	ff 24 85 80 20 80 00 	jmp    *0x802080(,%eax,4)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  801303:	83 ea 30             	sub    $0x30,%edx
  801306:	89 55 d4             	mov    %edx,-0x2c(%ebp)
				ch = *fmt;
  801309:	0f be 03             	movsbl (%ebx),%eax
				if (ch < '0' || ch > '9')
  80130c:	8d 50 d0             	lea    -0x30(%eax),%edx
  80130f:	83 fa 09             	cmp    $0x9,%edx
  801312:	77 44                	ja     801358 <vprintfmt+0xe7>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801314:	89 de                	mov    %ebx,%esi
  801316:	8b 55 d4             	mov    -0x2c(%ebp),%edx
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  801319:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
  80131a:	8d 14 92             	lea    (%edx,%edx,4),%edx
  80131d:	8d 54 50 d0          	lea    -0x30(%eax,%edx,2),%edx
				ch = *fmt;
  801321:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  801324:	8d 58 d0             	lea    -0x30(%eax),%ebx
  801327:	83 fb 09             	cmp    $0x9,%ebx
  80132a:	76 ed                	jbe    801319 <vprintfmt+0xa8>
  80132c:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  80132f:	eb 29                	jmp    80135a <vprintfmt+0xe9>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  801331:	8b 45 14             	mov    0x14(%ebp),%eax
  801334:	8d 50 04             	lea    0x4(%eax),%edx
  801337:	89 55 14             	mov    %edx,0x14(%ebp)
  80133a:	8b 00                	mov    (%eax),%eax
  80133c:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80133f:	89 de                	mov    %ebx,%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  801341:	eb 17                	jmp    80135a <vprintfmt+0xe9>

		case '.':
			if (width < 0)
  801343:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  801347:	78 85                	js     8012ce <vprintfmt+0x5d>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801349:	89 de                	mov    %ebx,%esi
  80134b:	eb 99                	jmp    8012e6 <vprintfmt+0x75>
  80134d:	89 de                	mov    %ebx,%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  80134f:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
			goto reswitch;
  801356:	eb 8e                	jmp    8012e6 <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801358:	89 de                	mov    %ebx,%esi
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  80135a:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80135e:	79 86                	jns    8012e6 <vprintfmt+0x75>
  801360:	e9 74 ff ff ff       	jmp    8012d9 <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  801365:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801366:	89 de                	mov    %ebx,%esi
  801368:	e9 79 ff ff ff       	jmp    8012e6 <vprintfmt+0x75>
  80136d:	89 5d d8             	mov    %ebx,-0x28(%ebp)
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  801370:	8b 45 14             	mov    0x14(%ebp),%eax
  801373:	8d 50 04             	lea    0x4(%eax),%edx
  801376:	89 55 14             	mov    %edx,0x14(%ebp)
  801379:	83 ec 08             	sub    $0x8,%esp
  80137c:	57                   	push   %edi
  80137d:	ff 30                	pushl  (%eax)
  80137f:	ff 55 08             	call   *0x8(%ebp)
			break;
  801382:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801385:	8b 75 d8             	mov    -0x28(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  801388:	e9 08 ff ff ff       	jmp    801295 <vprintfmt+0x24>
  80138d:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// error message
		case 'e':
			err = va_arg(ap, int);
  801390:	8b 45 14             	mov    0x14(%ebp),%eax
  801393:	8d 50 04             	lea    0x4(%eax),%edx
  801396:	89 55 14             	mov    %edx,0x14(%ebp)
  801399:	8b 00                	mov    (%eax),%eax
  80139b:	85 c0                	test   %eax,%eax
  80139d:	79 02                	jns    8013a1 <vprintfmt+0x130>
  80139f:	f7 d8                	neg    %eax
  8013a1:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8013a3:	83 f8 0f             	cmp    $0xf,%eax
  8013a6:	7f 0b                	jg     8013b3 <vprintfmt+0x142>
  8013a8:	8b 04 85 e0 21 80 00 	mov    0x8021e0(,%eax,4),%eax
  8013af:	85 c0                	test   %eax,%eax
  8013b1:	75 1a                	jne    8013cd <vprintfmt+0x15c>
				printfmt(putch, putdat, "error %d", err);
  8013b3:	52                   	push   %edx
  8013b4:	68 5f 1f 80 00       	push   $0x801f5f
  8013b9:	57                   	push   %edi
  8013ba:	ff 75 08             	pushl  0x8(%ebp)
  8013bd:	e8 92 fe ff ff       	call   801254 <printfmt>
  8013c2:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8013c5:	8b 75 d8             	mov    -0x28(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8013c8:	e9 c8 fe ff ff       	jmp    801295 <vprintfmt+0x24>
			else
				printfmt(putch, putdat, "%s", p);
  8013cd:	50                   	push   %eax
  8013ce:	68 dd 1e 80 00       	push   $0x801edd
  8013d3:	57                   	push   %edi
  8013d4:	ff 75 08             	pushl  0x8(%ebp)
  8013d7:	e8 78 fe ff ff       	call   801254 <printfmt>
  8013dc:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8013df:	8b 75 d8             	mov    -0x28(%ebp),%esi
  8013e2:	e9 ae fe ff ff       	jmp    801295 <vprintfmt+0x24>
  8013e7:	89 5d d8             	mov    %ebx,-0x28(%ebp)
  8013ea:	89 de                	mov    %ebx,%esi
  8013ec:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  8013ef:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8013f2:	8b 45 14             	mov    0x14(%ebp),%eax
  8013f5:	8d 50 04             	lea    0x4(%eax),%edx
  8013f8:	89 55 14             	mov    %edx,0x14(%ebp)
  8013fb:	8b 00                	mov    (%eax),%eax
  8013fd:	89 45 d0             	mov    %eax,-0x30(%ebp)
  801400:	85 c0                	test   %eax,%eax
  801402:	75 07                	jne    80140b <vprintfmt+0x19a>
				p = "(null)";
  801404:	c7 45 d0 58 1f 80 00 	movl   $0x801f58,-0x30(%ebp)
			if (width > 0 && padc != '-')
  80140b:	85 db                	test   %ebx,%ebx
  80140d:	7e 42                	jle    801451 <vprintfmt+0x1e0>
  80140f:	80 7d dc 2d          	cmpb   $0x2d,-0x24(%ebp)
  801413:	74 3c                	je     801451 <vprintfmt+0x1e0>
				for (width -= strnlen(p, precision); width > 0; width--)
  801415:	83 ec 08             	sub    $0x8,%esp
  801418:	51                   	push   %ecx
  801419:	ff 75 d0             	pushl  -0x30(%ebp)
  80141c:	e8 6f 02 00 00       	call   801690 <strnlen>
  801421:	29 c3                	sub    %eax,%ebx
  801423:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  801426:	83 c4 10             	add    $0x10,%esp
  801429:	85 db                	test   %ebx,%ebx
  80142b:	7e 24                	jle    801451 <vprintfmt+0x1e0>
					putch(padc, putdat);
  80142d:	0f be 5d dc          	movsbl -0x24(%ebp),%ebx
  801431:	89 75 dc             	mov    %esi,-0x24(%ebp)
  801434:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  801437:	83 ec 08             	sub    $0x8,%esp
  80143a:	57                   	push   %edi
  80143b:	53                   	push   %ebx
  80143c:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80143f:	4e                   	dec    %esi
  801440:	83 c4 10             	add    $0x10,%esp
  801443:	85 f6                	test   %esi,%esi
  801445:	7f f0                	jg     801437 <vprintfmt+0x1c6>
  801447:	8b 75 dc             	mov    -0x24(%ebp),%esi
  80144a:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  801451:	8b 55 d0             	mov    -0x30(%ebp),%edx
  801454:	0f be 02             	movsbl (%edx),%eax
  801457:	85 c0                	test   %eax,%eax
  801459:	75 47                	jne    8014a2 <vprintfmt+0x231>
  80145b:	eb 37                	jmp    801494 <vprintfmt+0x223>
				if (altflag && (ch < ' ' || ch > '~'))
  80145d:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  801461:	74 16                	je     801479 <vprintfmt+0x208>
  801463:	8d 50 e0             	lea    -0x20(%eax),%edx
  801466:	83 fa 5e             	cmp    $0x5e,%edx
  801469:	76 0e                	jbe    801479 <vprintfmt+0x208>
					putch('?', putdat);
  80146b:	83 ec 08             	sub    $0x8,%esp
  80146e:	57                   	push   %edi
  80146f:	6a 3f                	push   $0x3f
  801471:	ff 55 08             	call   *0x8(%ebp)
  801474:	83 c4 10             	add    $0x10,%esp
  801477:	eb 0b                	jmp    801484 <vprintfmt+0x213>
				else
					putch(ch, putdat);
  801479:	83 ec 08             	sub    $0x8,%esp
  80147c:	57                   	push   %edi
  80147d:	50                   	push   %eax
  80147e:	ff 55 08             	call   *0x8(%ebp)
  801481:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  801484:	ff 4d e4             	decl   -0x1c(%ebp)
  801487:	0f be 03             	movsbl (%ebx),%eax
  80148a:	85 c0                	test   %eax,%eax
  80148c:	74 03                	je     801491 <vprintfmt+0x220>
  80148e:	43                   	inc    %ebx
  80148f:	eb 1b                	jmp    8014ac <vprintfmt+0x23b>
  801491:	8b 75 dc             	mov    -0x24(%ebp),%esi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  801494:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  801498:	7f 1e                	jg     8014b8 <vprintfmt+0x247>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80149a:	8b 75 d8             	mov    -0x28(%ebp),%esi
  80149d:	e9 f3 fd ff ff       	jmp    801295 <vprintfmt+0x24>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8014a2:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  8014a5:	43                   	inc    %ebx
  8014a6:	89 75 dc             	mov    %esi,-0x24(%ebp)
  8014a9:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  8014ac:	85 f6                	test   %esi,%esi
  8014ae:	78 ad                	js     80145d <vprintfmt+0x1ec>
  8014b0:	4e                   	dec    %esi
  8014b1:	79 aa                	jns    80145d <vprintfmt+0x1ec>
  8014b3:	8b 75 dc             	mov    -0x24(%ebp),%esi
  8014b6:	eb dc                	jmp    801494 <vprintfmt+0x223>
  8014b8:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8014bb:	83 ec 08             	sub    $0x8,%esp
  8014be:	57                   	push   %edi
  8014bf:	6a 20                	push   $0x20
  8014c1:	ff 55 08             	call   *0x8(%ebp)
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8014c4:	4b                   	dec    %ebx
  8014c5:	83 c4 10             	add    $0x10,%esp
  8014c8:	85 db                	test   %ebx,%ebx
  8014ca:	7f ef                	jg     8014bb <vprintfmt+0x24a>
  8014cc:	e9 c4 fd ff ff       	jmp    801295 <vprintfmt+0x24>
  8014d1:	89 5d d8             	mov    %ebx,-0x28(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8014d4:	89 ca                	mov    %ecx,%edx
  8014d6:	8d 45 14             	lea    0x14(%ebp),%eax
  8014d9:	e8 2a fd ff ff       	call   801208 <getint>
  8014de:	89 c3                	mov    %eax,%ebx
  8014e0:	89 d6                	mov    %edx,%esi
			if ((long long) num < 0) {
  8014e2:	85 d2                	test   %edx,%edx
  8014e4:	78 0a                	js     8014f0 <vprintfmt+0x27f>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8014e6:	b8 0a 00 00 00       	mov    $0xa,%eax
  8014eb:	e9 b0 00 00 00       	jmp    8015a0 <vprintfmt+0x32f>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  8014f0:	83 ec 08             	sub    $0x8,%esp
  8014f3:	57                   	push   %edi
  8014f4:	6a 2d                	push   $0x2d
  8014f6:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  8014f9:	f7 db                	neg    %ebx
  8014fb:	83 d6 00             	adc    $0x0,%esi
  8014fe:	f7 de                	neg    %esi
  801500:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  801503:	b8 0a 00 00 00       	mov    $0xa,%eax
  801508:	e9 93 00 00 00       	jmp    8015a0 <vprintfmt+0x32f>
  80150d:	89 5d d8             	mov    %ebx,-0x28(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  801510:	89 ca                	mov    %ecx,%edx
  801512:	8d 45 14             	lea    0x14(%ebp),%eax
  801515:	e8 b4 fc ff ff       	call   8011ce <getuint>
  80151a:	89 c3                	mov    %eax,%ebx
  80151c:	89 d6                	mov    %edx,%esi
			base = 10;
  80151e:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  801523:	eb 7b                	jmp    8015a0 <vprintfmt+0x32f>
  801525:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// (unsigned) octal
		case 'o':
            // (MIT 6.828, lab1, Ex.8)  my code : 
            num = getint(&ap, lflag);
  801528:	89 ca                	mov    %ecx,%edx
  80152a:	8d 45 14             	lea    0x14(%ebp),%eax
  80152d:	e8 d6 fc ff ff       	call   801208 <getint>
  801532:	89 c3                	mov    %eax,%ebx
  801534:	89 d6                	mov    %edx,%esi
            if ((long long) num < 0) {
  801536:	85 d2                	test   %edx,%edx
  801538:	78 07                	js     801541 <vprintfmt+0x2d0>
                putch('-', putdat);
                num = -(long long) num;
            }
            base = 8;
  80153a:	b8 08 00 00 00       	mov    $0x8,%eax
  80153f:	eb 5f                	jmp    8015a0 <vprintfmt+0x32f>
		// (unsigned) octal
		case 'o':
            // (MIT 6.828, lab1, Ex.8)  my code : 
            num = getint(&ap, lflag);
            if ((long long) num < 0) {
                putch('-', putdat);
  801541:	83 ec 08             	sub    $0x8,%esp
  801544:	57                   	push   %edi
  801545:	6a 2d                	push   $0x2d
  801547:	ff 55 08             	call   *0x8(%ebp)
                num = -(long long) num;
  80154a:	f7 db                	neg    %ebx
  80154c:	83 d6 00             	adc    $0x0,%esi
  80154f:	f7 de                	neg    %esi
  801551:	83 c4 10             	add    $0x10,%esp
            }
            base = 8;
  801554:	b8 08 00 00 00       	mov    $0x8,%eax
  801559:	eb 45                	jmp    8015a0 <vprintfmt+0x32f>
  80155b:	89 5d d8             	mov    %ebx,-0x28(%ebp)
            goto number;

        // pointer
		case 'p':
			putch('0', putdat);
  80155e:	83 ec 08             	sub    $0x8,%esp
  801561:	57                   	push   %edi
  801562:	6a 30                	push   $0x30
  801564:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  801567:	83 c4 08             	add    $0x8,%esp
  80156a:	57                   	push   %edi
  80156b:	6a 78                	push   $0x78
  80156d:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  801570:	8b 45 14             	mov    0x14(%ebp),%eax
  801573:	8d 50 04             	lea    0x4(%eax),%edx
  801576:	89 55 14             	mov    %edx,0x14(%ebp)

        // pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  801579:	8b 18                	mov    (%eax),%ebx
  80157b:	be 00 00 00 00       	mov    $0x0,%esi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  801580:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  801583:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  801588:	eb 16                	jmp    8015a0 <vprintfmt+0x32f>
  80158a:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  80158d:	89 ca                	mov    %ecx,%edx
  80158f:	8d 45 14             	lea    0x14(%ebp),%eax
  801592:	e8 37 fc ff ff       	call   8011ce <getuint>
  801597:	89 c3                	mov    %eax,%ebx
  801599:	89 d6                	mov    %edx,%esi
			base = 16;
  80159b:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  8015a0:	83 ec 0c             	sub    $0xc,%esp
  8015a3:	0f be 55 dc          	movsbl -0x24(%ebp),%edx
  8015a7:	52                   	push   %edx
  8015a8:	ff 75 e4             	pushl  -0x1c(%ebp)
  8015ab:	50                   	push   %eax
  8015ac:	56                   	push   %esi
  8015ad:	53                   	push   %ebx
  8015ae:	89 fa                	mov    %edi,%edx
  8015b0:	8b 45 08             	mov    0x8(%ebp),%eax
  8015b3:	e8 68 fb ff ff       	call   801120 <printnum>
			break;
  8015b8:	83 c4 20             	add    $0x20,%esp
  8015bb:	8b 75 d8             	mov    -0x28(%ebp),%esi
  8015be:	e9 d2 fc ff ff       	jmp    801295 <vprintfmt+0x24>
  8015c3:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8015c6:	83 ec 08             	sub    $0x8,%esp
  8015c9:	57                   	push   %edi
  8015ca:	52                   	push   %edx
  8015cb:	ff 55 08             	call   *0x8(%ebp)
			break;
  8015ce:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8015d1:	8b 75 d8             	mov    -0x28(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8015d4:	e9 bc fc ff ff       	jmp    801295 <vprintfmt+0x24>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8015d9:	83 ec 08             	sub    $0x8,%esp
  8015dc:	57                   	push   %edi
  8015dd:	6a 25                	push   $0x25
  8015df:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  8015e2:	83 c4 10             	add    $0x10,%esp
  8015e5:	eb 02                	jmp    8015e9 <vprintfmt+0x378>
  8015e7:	89 c6                	mov    %eax,%esi
  8015e9:	8d 46 ff             	lea    -0x1(%esi),%eax
  8015ec:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  8015f0:	75 f5                	jne    8015e7 <vprintfmt+0x376>
  8015f2:	e9 9e fc ff ff       	jmp    801295 <vprintfmt+0x24>
				/* do nothing */;
			break;
		}
	}
}
  8015f7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8015fa:	5b                   	pop    %ebx
  8015fb:	5e                   	pop    %esi
  8015fc:	5f                   	pop    %edi
  8015fd:	c9                   	leave  
  8015fe:	c3                   	ret    

008015ff <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8015ff:	55                   	push   %ebp
  801600:	89 e5                	mov    %esp,%ebp
  801602:	83 ec 18             	sub    $0x18,%esp
  801605:	8b 45 08             	mov    0x8(%ebp),%eax
  801608:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80160b:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80160e:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  801612:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  801615:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80161c:	85 c0                	test   %eax,%eax
  80161e:	74 26                	je     801646 <vsnprintf+0x47>
  801620:	85 d2                	test   %edx,%edx
  801622:	7e 29                	jle    80164d <vsnprintf+0x4e>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  801624:	ff 75 14             	pushl  0x14(%ebp)
  801627:	ff 75 10             	pushl  0x10(%ebp)
  80162a:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80162d:	50                   	push   %eax
  80162e:	68 3a 12 80 00       	push   $0x80123a
  801633:	e8 39 fc ff ff       	call   801271 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  801638:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80163b:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80163e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801641:	83 c4 10             	add    $0x10,%esp
  801644:	eb 0c                	jmp    801652 <vsnprintf+0x53>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  801646:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80164b:	eb 05                	jmp    801652 <vsnprintf+0x53>
  80164d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  801652:	c9                   	leave  
  801653:	c3                   	ret    

00801654 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  801654:	55                   	push   %ebp
  801655:	89 e5                	mov    %esp,%ebp
  801657:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80165a:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80165d:	50                   	push   %eax
  80165e:	ff 75 10             	pushl  0x10(%ebp)
  801661:	ff 75 0c             	pushl  0xc(%ebp)
  801664:	ff 75 08             	pushl  0x8(%ebp)
  801667:	e8 93 ff ff ff       	call   8015ff <vsnprintf>
	va_end(ap);

	return rc;
}
  80166c:	c9                   	leave  
  80166d:	c3                   	ret    
	...

00801670 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  801670:	55                   	push   %ebp
  801671:	89 e5                	mov    %esp,%ebp
  801673:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  801676:	80 3a 00             	cmpb   $0x0,(%edx)
  801679:	74 0e                	je     801689 <strlen+0x19>
  80167b:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  801680:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  801681:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  801685:	75 f9                	jne    801680 <strlen+0x10>
  801687:	eb 05                	jmp    80168e <strlen+0x1e>
  801689:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  80168e:	c9                   	leave  
  80168f:	c3                   	ret    

00801690 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  801690:	55                   	push   %ebp
  801691:	89 e5                	mov    %esp,%ebp
  801693:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801696:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801699:	85 d2                	test   %edx,%edx
  80169b:	74 17                	je     8016b4 <strnlen+0x24>
  80169d:	80 39 00             	cmpb   $0x0,(%ecx)
  8016a0:	74 19                	je     8016bb <strnlen+0x2b>
  8016a2:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  8016a7:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8016a8:	39 d0                	cmp    %edx,%eax
  8016aa:	74 14                	je     8016c0 <strnlen+0x30>
  8016ac:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8016b0:	75 f5                	jne    8016a7 <strnlen+0x17>
  8016b2:	eb 0c                	jmp    8016c0 <strnlen+0x30>
  8016b4:	b8 00 00 00 00       	mov    $0x0,%eax
  8016b9:	eb 05                	jmp    8016c0 <strnlen+0x30>
  8016bb:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  8016c0:	c9                   	leave  
  8016c1:	c3                   	ret    

008016c2 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8016c2:	55                   	push   %ebp
  8016c3:	89 e5                	mov    %esp,%ebp
  8016c5:	53                   	push   %ebx
  8016c6:	8b 45 08             	mov    0x8(%ebp),%eax
  8016c9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8016cc:	ba 00 00 00 00       	mov    $0x0,%edx
  8016d1:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  8016d4:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  8016d7:	42                   	inc    %edx
  8016d8:	84 c9                	test   %cl,%cl
  8016da:	75 f5                	jne    8016d1 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  8016dc:	5b                   	pop    %ebx
  8016dd:	c9                   	leave  
  8016de:	c3                   	ret    

008016df <strcat>:

char *
strcat(char *dst, const char *src)
{
  8016df:	55                   	push   %ebp
  8016e0:	89 e5                	mov    %esp,%ebp
  8016e2:	53                   	push   %ebx
  8016e3:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8016e6:	53                   	push   %ebx
  8016e7:	e8 84 ff ff ff       	call   801670 <strlen>
  8016ec:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8016ef:	ff 75 0c             	pushl  0xc(%ebp)
  8016f2:	8d 04 03             	lea    (%ebx,%eax,1),%eax
  8016f5:	50                   	push   %eax
  8016f6:	e8 c7 ff ff ff       	call   8016c2 <strcpy>
	return dst;
}
  8016fb:	89 d8                	mov    %ebx,%eax
  8016fd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801700:	c9                   	leave  
  801701:	c3                   	ret    

00801702 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  801702:	55                   	push   %ebp
  801703:	89 e5                	mov    %esp,%ebp
  801705:	56                   	push   %esi
  801706:	53                   	push   %ebx
  801707:	8b 45 08             	mov    0x8(%ebp),%eax
  80170a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80170d:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801710:	85 f6                	test   %esi,%esi
  801712:	74 15                	je     801729 <strncpy+0x27>
  801714:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
  801719:	8a 1a                	mov    (%edx),%bl
  80171b:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80171e:	80 3a 01             	cmpb   $0x1,(%edx)
  801721:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801724:	41                   	inc    %ecx
  801725:	39 ce                	cmp    %ecx,%esi
  801727:	77 f0                	ja     801719 <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  801729:	5b                   	pop    %ebx
  80172a:	5e                   	pop    %esi
  80172b:	c9                   	leave  
  80172c:	c3                   	ret    

0080172d <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80172d:	55                   	push   %ebp
  80172e:	89 e5                	mov    %esp,%ebp
  801730:	57                   	push   %edi
  801731:	56                   	push   %esi
  801732:	53                   	push   %ebx
  801733:	8b 7d 08             	mov    0x8(%ebp),%edi
  801736:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801739:	8b 75 10             	mov    0x10(%ebp),%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80173c:	85 f6                	test   %esi,%esi
  80173e:	74 32                	je     801772 <strlcpy+0x45>
		while (--size > 0 && *src != '\0')
  801740:	83 fe 01             	cmp    $0x1,%esi
  801743:	74 22                	je     801767 <strlcpy+0x3a>
  801745:	8a 0b                	mov    (%ebx),%cl
  801747:	84 c9                	test   %cl,%cl
  801749:	74 20                	je     80176b <strlcpy+0x3e>
  80174b:	89 f8                	mov    %edi,%eax
  80174d:	ba 00 00 00 00       	mov    $0x0,%edx
	}
	return ret;
}

size_t
strlcpy(char *dst, const char *src, size_t size)
  801752:	83 ee 02             	sub    $0x2,%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  801755:	88 08                	mov    %cl,(%eax)
  801757:	40                   	inc    %eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  801758:	39 f2                	cmp    %esi,%edx
  80175a:	74 11                	je     80176d <strlcpy+0x40>
  80175c:	8a 4c 13 01          	mov    0x1(%ebx,%edx,1),%cl
  801760:	42                   	inc    %edx
  801761:	84 c9                	test   %cl,%cl
  801763:	75 f0                	jne    801755 <strlcpy+0x28>
  801765:	eb 06                	jmp    80176d <strlcpy+0x40>
  801767:	89 f8                	mov    %edi,%eax
  801769:	eb 02                	jmp    80176d <strlcpy+0x40>
  80176b:	89 f8                	mov    %edi,%eax
			*dst++ = *src++;
		*dst = '\0';
  80176d:	c6 00 00             	movb   $0x0,(%eax)
  801770:	eb 02                	jmp    801774 <strlcpy+0x47>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  801772:	89 f8                	mov    %edi,%eax
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
		*dst = '\0';
	}
	return dst - dst_in;
  801774:	29 f8                	sub    %edi,%eax
}
  801776:	5b                   	pop    %ebx
  801777:	5e                   	pop    %esi
  801778:	5f                   	pop    %edi
  801779:	c9                   	leave  
  80177a:	c3                   	ret    

0080177b <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80177b:	55                   	push   %ebp
  80177c:	89 e5                	mov    %esp,%ebp
  80177e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801781:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  801784:	8a 01                	mov    (%ecx),%al
  801786:	84 c0                	test   %al,%al
  801788:	74 10                	je     80179a <strcmp+0x1f>
  80178a:	3a 02                	cmp    (%edx),%al
  80178c:	75 0c                	jne    80179a <strcmp+0x1f>
		p++, q++;
  80178e:	41                   	inc    %ecx
  80178f:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  801790:	8a 01                	mov    (%ecx),%al
  801792:	84 c0                	test   %al,%al
  801794:	74 04                	je     80179a <strcmp+0x1f>
  801796:	3a 02                	cmp    (%edx),%al
  801798:	74 f4                	je     80178e <strcmp+0x13>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  80179a:	0f b6 c0             	movzbl %al,%eax
  80179d:	0f b6 12             	movzbl (%edx),%edx
  8017a0:	29 d0                	sub    %edx,%eax
}
  8017a2:	c9                   	leave  
  8017a3:	c3                   	ret    

008017a4 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8017a4:	55                   	push   %ebp
  8017a5:	89 e5                	mov    %esp,%ebp
  8017a7:	53                   	push   %ebx
  8017a8:	8b 55 08             	mov    0x8(%ebp),%edx
  8017ab:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8017ae:	8b 45 10             	mov    0x10(%ebp),%eax
	while (n > 0 && *p && *p == *q)
  8017b1:	85 c0                	test   %eax,%eax
  8017b3:	74 1b                	je     8017d0 <strncmp+0x2c>
  8017b5:	8a 1a                	mov    (%edx),%bl
  8017b7:	84 db                	test   %bl,%bl
  8017b9:	74 24                	je     8017df <strncmp+0x3b>
  8017bb:	3a 19                	cmp    (%ecx),%bl
  8017bd:	75 20                	jne    8017df <strncmp+0x3b>
  8017bf:	48                   	dec    %eax
  8017c0:	74 15                	je     8017d7 <strncmp+0x33>
		n--, p++, q++;
  8017c2:	42                   	inc    %edx
  8017c3:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8017c4:	8a 1a                	mov    (%edx),%bl
  8017c6:	84 db                	test   %bl,%bl
  8017c8:	74 15                	je     8017df <strncmp+0x3b>
  8017ca:	3a 19                	cmp    (%ecx),%bl
  8017cc:	74 f1                	je     8017bf <strncmp+0x1b>
  8017ce:	eb 0f                	jmp    8017df <strncmp+0x3b>
		n--, p++, q++;
	if (n == 0)
		return 0;
  8017d0:	b8 00 00 00 00       	mov    $0x0,%eax
  8017d5:	eb 05                	jmp    8017dc <strncmp+0x38>
  8017d7:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8017dc:	5b                   	pop    %ebx
  8017dd:	c9                   	leave  
  8017de:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8017df:	0f b6 02             	movzbl (%edx),%eax
  8017e2:	0f b6 11             	movzbl (%ecx),%edx
  8017e5:	29 d0                	sub    %edx,%eax
  8017e7:	eb f3                	jmp    8017dc <strncmp+0x38>

008017e9 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8017e9:	55                   	push   %ebp
  8017ea:	89 e5                	mov    %esp,%ebp
  8017ec:	8b 45 08             	mov    0x8(%ebp),%eax
  8017ef:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  8017f2:	8a 10                	mov    (%eax),%dl
  8017f4:	84 d2                	test   %dl,%dl
  8017f6:	74 18                	je     801810 <strchr+0x27>
		if (*s == c)
  8017f8:	38 ca                	cmp    %cl,%dl
  8017fa:	75 06                	jne    801802 <strchr+0x19>
  8017fc:	eb 17                	jmp    801815 <strchr+0x2c>
  8017fe:	38 ca                	cmp    %cl,%dl
  801800:	74 13                	je     801815 <strchr+0x2c>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  801802:	40                   	inc    %eax
  801803:	8a 10                	mov    (%eax),%dl
  801805:	84 d2                	test   %dl,%dl
  801807:	75 f5                	jne    8017fe <strchr+0x15>
		if (*s == c)
			return (char *) s;
	return 0;
  801809:	b8 00 00 00 00       	mov    $0x0,%eax
  80180e:	eb 05                	jmp    801815 <strchr+0x2c>
  801810:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801815:	c9                   	leave  
  801816:	c3                   	ret    

00801817 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  801817:	55                   	push   %ebp
  801818:	89 e5                	mov    %esp,%ebp
  80181a:	8b 45 08             	mov    0x8(%ebp),%eax
  80181d:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  801820:	8a 10                	mov    (%eax),%dl
  801822:	84 d2                	test   %dl,%dl
  801824:	74 11                	je     801837 <strfind+0x20>
		if (*s == c)
  801826:	38 ca                	cmp    %cl,%dl
  801828:	75 06                	jne    801830 <strfind+0x19>
  80182a:	eb 0b                	jmp    801837 <strfind+0x20>
  80182c:	38 ca                	cmp    %cl,%dl
  80182e:	74 07                	je     801837 <strfind+0x20>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  801830:	40                   	inc    %eax
  801831:	8a 10                	mov    (%eax),%dl
  801833:	84 d2                	test   %dl,%dl
  801835:	75 f5                	jne    80182c <strfind+0x15>
		if (*s == c)
			break;
	return (char *) s;
}
  801837:	c9                   	leave  
  801838:	c3                   	ret    

00801839 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  801839:	55                   	push   %ebp
  80183a:	89 e5                	mov    %esp,%ebp
  80183c:	57                   	push   %edi
  80183d:	56                   	push   %esi
  80183e:	53                   	push   %ebx
  80183f:	8b 7d 08             	mov    0x8(%ebp),%edi
  801842:	8b 45 0c             	mov    0xc(%ebp),%eax
  801845:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  801848:	85 c9                	test   %ecx,%ecx
  80184a:	74 30                	je     80187c <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  80184c:	f7 c7 03 00 00 00    	test   $0x3,%edi
  801852:	75 25                	jne    801879 <memset+0x40>
  801854:	f6 c1 03             	test   $0x3,%cl
  801857:	75 20                	jne    801879 <memset+0x40>
		c &= 0xFF;
  801859:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  80185c:	89 d3                	mov    %edx,%ebx
  80185e:	c1 e3 08             	shl    $0x8,%ebx
  801861:	89 d6                	mov    %edx,%esi
  801863:	c1 e6 18             	shl    $0x18,%esi
  801866:	89 d0                	mov    %edx,%eax
  801868:	c1 e0 10             	shl    $0x10,%eax
  80186b:	09 f0                	or     %esi,%eax
  80186d:	09 d0                	or     %edx,%eax
  80186f:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  801871:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  801874:	fc                   	cld    
  801875:	f3 ab                	rep stos %eax,%es:(%edi)
  801877:	eb 03                	jmp    80187c <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  801879:	fc                   	cld    
  80187a:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  80187c:	89 f8                	mov    %edi,%eax
  80187e:	5b                   	pop    %ebx
  80187f:	5e                   	pop    %esi
  801880:	5f                   	pop    %edi
  801881:	c9                   	leave  
  801882:	c3                   	ret    

00801883 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  801883:	55                   	push   %ebp
  801884:	89 e5                	mov    %esp,%ebp
  801886:	57                   	push   %edi
  801887:	56                   	push   %esi
  801888:	8b 45 08             	mov    0x8(%ebp),%eax
  80188b:	8b 75 0c             	mov    0xc(%ebp),%esi
  80188e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  801891:	39 c6                	cmp    %eax,%esi
  801893:	73 34                	jae    8018c9 <memmove+0x46>
  801895:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  801898:	39 d0                	cmp    %edx,%eax
  80189a:	73 2d                	jae    8018c9 <memmove+0x46>
		s += n;
		d += n;
  80189c:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80189f:	f6 c2 03             	test   $0x3,%dl
  8018a2:	75 1b                	jne    8018bf <memmove+0x3c>
  8018a4:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8018aa:	75 13                	jne    8018bf <memmove+0x3c>
  8018ac:	f6 c1 03             	test   $0x3,%cl
  8018af:	75 0e                	jne    8018bf <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  8018b1:	83 ef 04             	sub    $0x4,%edi
  8018b4:	8d 72 fc             	lea    -0x4(%edx),%esi
  8018b7:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  8018ba:	fd                   	std    
  8018bb:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8018bd:	eb 07                	jmp    8018c6 <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  8018bf:	4f                   	dec    %edi
  8018c0:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8018c3:	fd                   	std    
  8018c4:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8018c6:	fc                   	cld    
  8018c7:	eb 20                	jmp    8018e9 <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8018c9:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8018cf:	75 13                	jne    8018e4 <memmove+0x61>
  8018d1:	a8 03                	test   $0x3,%al
  8018d3:	75 0f                	jne    8018e4 <memmove+0x61>
  8018d5:	f6 c1 03             	test   $0x3,%cl
  8018d8:	75 0a                	jne    8018e4 <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  8018da:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  8018dd:	89 c7                	mov    %eax,%edi
  8018df:	fc                   	cld    
  8018e0:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8018e2:	eb 05                	jmp    8018e9 <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8018e4:	89 c7                	mov    %eax,%edi
  8018e6:	fc                   	cld    
  8018e7:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8018e9:	5e                   	pop    %esi
  8018ea:	5f                   	pop    %edi
  8018eb:	c9                   	leave  
  8018ec:	c3                   	ret    

008018ed <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8018ed:	55                   	push   %ebp
  8018ee:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  8018f0:	ff 75 10             	pushl  0x10(%ebp)
  8018f3:	ff 75 0c             	pushl  0xc(%ebp)
  8018f6:	ff 75 08             	pushl  0x8(%ebp)
  8018f9:	e8 85 ff ff ff       	call   801883 <memmove>
}
  8018fe:	c9                   	leave  
  8018ff:	c3                   	ret    

00801900 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  801900:	55                   	push   %ebp
  801901:	89 e5                	mov    %esp,%ebp
  801903:	57                   	push   %edi
  801904:	56                   	push   %esi
  801905:	53                   	push   %ebx
  801906:	8b 5d 08             	mov    0x8(%ebp),%ebx
  801909:	8b 75 0c             	mov    0xc(%ebp),%esi
  80190c:	8b 7d 10             	mov    0x10(%ebp),%edi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  80190f:	85 ff                	test   %edi,%edi
  801911:	74 32                	je     801945 <memcmp+0x45>
		if (*s1 != *s2)
  801913:	8a 03                	mov    (%ebx),%al
  801915:	8a 0e                	mov    (%esi),%cl
  801917:	38 c8                	cmp    %cl,%al
  801919:	74 19                	je     801934 <memcmp+0x34>
  80191b:	eb 0d                	jmp    80192a <memcmp+0x2a>
  80191d:	8a 44 13 01          	mov    0x1(%ebx,%edx,1),%al
  801921:	8a 4c 16 01          	mov    0x1(%esi,%edx,1),%cl
  801925:	42                   	inc    %edx
  801926:	38 c8                	cmp    %cl,%al
  801928:	74 10                	je     80193a <memcmp+0x3a>
			return (int) *s1 - (int) *s2;
  80192a:	0f b6 c0             	movzbl %al,%eax
  80192d:	0f b6 c9             	movzbl %cl,%ecx
  801930:	29 c8                	sub    %ecx,%eax
  801932:	eb 16                	jmp    80194a <memcmp+0x4a>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801934:	4f                   	dec    %edi
  801935:	ba 00 00 00 00       	mov    $0x0,%edx
  80193a:	39 fa                	cmp    %edi,%edx
  80193c:	75 df                	jne    80191d <memcmp+0x1d>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  80193e:	b8 00 00 00 00       	mov    $0x0,%eax
  801943:	eb 05                	jmp    80194a <memcmp+0x4a>
  801945:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80194a:	5b                   	pop    %ebx
  80194b:	5e                   	pop    %esi
  80194c:	5f                   	pop    %edi
  80194d:	c9                   	leave  
  80194e:	c3                   	ret    

0080194f <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  80194f:	55                   	push   %ebp
  801950:	89 e5                	mov    %esp,%ebp
  801952:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  801955:	89 c2                	mov    %eax,%edx
  801957:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  80195a:	39 d0                	cmp    %edx,%eax
  80195c:	73 12                	jae    801970 <memfind+0x21>
		if (*(const unsigned char *) s == (unsigned char) c)
  80195e:	8a 4d 0c             	mov    0xc(%ebp),%cl
  801961:	38 08                	cmp    %cl,(%eax)
  801963:	75 06                	jne    80196b <memfind+0x1c>
  801965:	eb 09                	jmp    801970 <memfind+0x21>
  801967:	38 08                	cmp    %cl,(%eax)
  801969:	74 05                	je     801970 <memfind+0x21>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  80196b:	40                   	inc    %eax
  80196c:	39 c2                	cmp    %eax,%edx
  80196e:	77 f7                	ja     801967 <memfind+0x18>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  801970:	c9                   	leave  
  801971:	c3                   	ret    

00801972 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  801972:	55                   	push   %ebp
  801973:	89 e5                	mov    %esp,%ebp
  801975:	57                   	push   %edi
  801976:	56                   	push   %esi
  801977:	53                   	push   %ebx
  801978:	8b 55 08             	mov    0x8(%ebp),%edx
  80197b:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  80197e:	eb 01                	jmp    801981 <strtol+0xf>
		s++;
  801980:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801981:	8a 02                	mov    (%edx),%al
  801983:	3c 20                	cmp    $0x20,%al
  801985:	74 f9                	je     801980 <strtol+0xe>
  801987:	3c 09                	cmp    $0x9,%al
  801989:	74 f5                	je     801980 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  80198b:	3c 2b                	cmp    $0x2b,%al
  80198d:	75 08                	jne    801997 <strtol+0x25>
		s++;
  80198f:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  801990:	bf 00 00 00 00       	mov    $0x0,%edi
  801995:	eb 13                	jmp    8019aa <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  801997:	3c 2d                	cmp    $0x2d,%al
  801999:	75 0a                	jne    8019a5 <strtol+0x33>
		s++, neg = 1;
  80199b:	8d 52 01             	lea    0x1(%edx),%edx
  80199e:	bf 01 00 00 00       	mov    $0x1,%edi
  8019a3:	eb 05                	jmp    8019aa <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  8019a5:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8019aa:	85 db                	test   %ebx,%ebx
  8019ac:	74 05                	je     8019b3 <strtol+0x41>
  8019ae:	83 fb 10             	cmp    $0x10,%ebx
  8019b1:	75 28                	jne    8019db <strtol+0x69>
  8019b3:	8a 02                	mov    (%edx),%al
  8019b5:	3c 30                	cmp    $0x30,%al
  8019b7:	75 10                	jne    8019c9 <strtol+0x57>
  8019b9:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  8019bd:	75 0a                	jne    8019c9 <strtol+0x57>
		s += 2, base = 16;
  8019bf:	83 c2 02             	add    $0x2,%edx
  8019c2:	bb 10 00 00 00       	mov    $0x10,%ebx
  8019c7:	eb 12                	jmp    8019db <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  8019c9:	85 db                	test   %ebx,%ebx
  8019cb:	75 0e                	jne    8019db <strtol+0x69>
  8019cd:	3c 30                	cmp    $0x30,%al
  8019cf:	75 05                	jne    8019d6 <strtol+0x64>
		s++, base = 8;
  8019d1:	42                   	inc    %edx
  8019d2:	b3 08                	mov    $0x8,%bl
  8019d4:	eb 05                	jmp    8019db <strtol+0x69>
	else if (base == 0)
		base = 10;
  8019d6:	bb 0a 00 00 00       	mov    $0xa,%ebx
  8019db:	b8 00 00 00 00       	mov    $0x0,%eax
  8019e0:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  8019e2:	8a 0a                	mov    (%edx),%cl
  8019e4:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  8019e7:	80 fb 09             	cmp    $0x9,%bl
  8019ea:	77 08                	ja     8019f4 <strtol+0x82>
			dig = *s - '0';
  8019ec:	0f be c9             	movsbl %cl,%ecx
  8019ef:	83 e9 30             	sub    $0x30,%ecx
  8019f2:	eb 1e                	jmp    801a12 <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  8019f4:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  8019f7:	80 fb 19             	cmp    $0x19,%bl
  8019fa:	77 08                	ja     801a04 <strtol+0x92>
			dig = *s - 'a' + 10;
  8019fc:	0f be c9             	movsbl %cl,%ecx
  8019ff:	83 e9 57             	sub    $0x57,%ecx
  801a02:	eb 0e                	jmp    801a12 <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  801a04:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  801a07:	80 fb 19             	cmp    $0x19,%bl
  801a0a:	77 13                	ja     801a1f <strtol+0xad>
			dig = *s - 'A' + 10;
  801a0c:	0f be c9             	movsbl %cl,%ecx
  801a0f:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  801a12:	39 f1                	cmp    %esi,%ecx
  801a14:	7d 0d                	jge    801a23 <strtol+0xb1>
			break;
		s++, val = (val * base) + dig;
  801a16:	42                   	inc    %edx
  801a17:	0f af c6             	imul   %esi,%eax
  801a1a:	8d 04 01             	lea    (%ecx,%eax,1),%eax
		// we don't properly detect overflow!
	}
  801a1d:	eb c3                	jmp    8019e2 <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  801a1f:	89 c1                	mov    %eax,%ecx
  801a21:	eb 02                	jmp    801a25 <strtol+0xb3>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  801a23:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  801a25:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801a29:	74 05                	je     801a30 <strtol+0xbe>
		*endptr = (char *) s;
  801a2b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801a2e:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  801a30:	85 ff                	test   %edi,%edi
  801a32:	74 04                	je     801a38 <strtol+0xc6>
  801a34:	89 c8                	mov    %ecx,%eax
  801a36:	f7 d8                	neg    %eax
}
  801a38:	5b                   	pop    %ebx
  801a39:	5e                   	pop    %esi
  801a3a:	5f                   	pop    %edi
  801a3b:	c9                   	leave  
  801a3c:	c3                   	ret    
  801a3d:	00 00                	add    %al,(%eax)
	...

00801a40 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801a40:	55                   	push   %ebp
  801a41:	89 e5                	mov    %esp,%ebp
  801a43:	56                   	push   %esi
  801a44:	53                   	push   %ebx
  801a45:	8b 75 08             	mov    0x8(%ebp),%esi
  801a48:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a4b:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// cprintf("0x%x 0x%x 0x%x\n", (uint32_t)from_env_store, (uint32_t)pg, (uint32_t)perm_store);
	int r;
	if (pg != NULL) {
  801a4e:	85 c0                	test   %eax,%eax
  801a50:	74 0e                	je     801a60 <ipc_recv+0x20>
		r = sys_ipc_recv(pg);
  801a52:	83 ec 0c             	sub    $0xc,%esp
  801a55:	50                   	push   %eax
  801a56:	e8 74 e8 ff ff       	call   8002cf <sys_ipc_recv>
  801a5b:	83 c4 10             	add    $0x10,%esp
  801a5e:	eb 10                	jmp    801a70 <ipc_recv+0x30>
	} else {
		r = sys_ipc_recv((void *)UTOP);
  801a60:	83 ec 0c             	sub    $0xc,%esp
  801a63:	68 00 00 c0 ee       	push   $0xeec00000
  801a68:	e8 62 e8 ff ff       	call   8002cf <sys_ipc_recv>
  801a6d:	83 c4 10             	add    $0x10,%esp
	}

	if (r == 0) {
  801a70:	85 c0                	test   %eax,%eax
  801a72:	75 26                	jne    801a9a <ipc_recv+0x5a>
		if (from_env_store != NULL) *from_env_store = thisenv->env_ipc_from;
  801a74:	85 f6                	test   %esi,%esi
  801a76:	74 0a                	je     801a82 <ipc_recv+0x42>
  801a78:	a1 04 40 80 00       	mov    0x804004,%eax
  801a7d:	8b 40 74             	mov    0x74(%eax),%eax
  801a80:	89 06                	mov    %eax,(%esi)
		if (perm_store != NULL) *perm_store = thisenv->env_ipc_perm;
  801a82:	85 db                	test   %ebx,%ebx
  801a84:	74 0a                	je     801a90 <ipc_recv+0x50>
  801a86:	a1 04 40 80 00       	mov    0x804004,%eax
  801a8b:	8b 40 78             	mov    0x78(%eax),%eax
  801a8e:	89 03                	mov    %eax,(%ebx)
		return thisenv->env_ipc_value;
  801a90:	a1 04 40 80 00       	mov    0x804004,%eax
  801a95:	8b 40 70             	mov    0x70(%eax),%eax
  801a98:	eb 14                	jmp    801aae <ipc_recv+0x6e>
	} else {
		// fails;
		if (from_env_store != NULL) *from_env_store = 0;
  801a9a:	85 f6                	test   %esi,%esi
  801a9c:	74 06                	je     801aa4 <ipc_recv+0x64>
  801a9e:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		if (perm_store != NULL) *perm_store = 0;
  801aa4:	85 db                	test   %ebx,%ebx
  801aa6:	74 06                	je     801aae <ipc_recv+0x6e>
  801aa8:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
		return r;
	}
}
  801aae:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801ab1:	5b                   	pop    %ebx
  801ab2:	5e                   	pop    %esi
  801ab3:	c9                   	leave  
  801ab4:	c3                   	ret    

00801ab5 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801ab5:	55                   	push   %ebp
  801ab6:	89 e5                	mov    %esp,%ebp
  801ab8:	57                   	push   %edi
  801ab9:	56                   	push   %esi
  801aba:	53                   	push   %ebx
  801abb:	83 ec 0c             	sub    $0xc,%esp
  801abe:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801ac1:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801ac4:	8b 75 14             	mov    0x14(%ebp),%esi
	// LAB 4: Your code here.
	// int sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
	int r;
	if (pg == NULL) pg = (void *)UTOP;
  801ac7:	85 db                	test   %ebx,%ebx
  801ac9:	75 25                	jne    801af0 <ipc_send+0x3b>
  801acb:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
  801ad0:	eb 1e                	jmp    801af0 <ipc_send+0x3b>
	
	while ((r = sys_ipc_try_send(to_env, val, pg, perm)) != 0) {
		if (r == -E_IPC_NOT_RECV) {
  801ad2:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801ad5:	75 07                	jne    801ade <ipc_send+0x29>
			// cprintf("Try Again and Again....\n");
			sys_yield();
  801ad7:	e8 d1 e6 ff ff       	call   8001ad <sys_yield>
  801adc:	eb 12                	jmp    801af0 <ipc_send+0x3b>
		} else {
			panic("ipc_send error %e\n", r);
  801ade:	50                   	push   %eax
  801adf:	68 40 22 80 00       	push   $0x802240
  801ae4:	6a 43                	push   $0x43
  801ae6:	68 53 22 80 00       	push   $0x802253
  801aeb:	e8 44 f5 ff ff       	call   801034 <_panic>
	// LAB 4: Your code here.
	// int sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
	int r;
	if (pg == NULL) pg = (void *)UTOP;
	
	while ((r = sys_ipc_try_send(to_env, val, pg, perm)) != 0) {
  801af0:	56                   	push   %esi
  801af1:	53                   	push   %ebx
  801af2:	57                   	push   %edi
  801af3:	ff 75 08             	pushl  0x8(%ebp)
  801af6:	e8 af e7 ff ff       	call   8002aa <sys_ipc_try_send>
  801afb:	83 c4 10             	add    $0x10,%esp
  801afe:	85 c0                	test   %eax,%eax
  801b00:	75 d0                	jne    801ad2 <ipc_send+0x1d>
		} else {
			panic("ipc_send error %e\n", r);
		}
	}
	return;
}
  801b02:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b05:	5b                   	pop    %ebx
  801b06:	5e                   	pop    %esi
  801b07:	5f                   	pop    %edi
  801b08:	c9                   	leave  
  801b09:	c3                   	ret    

00801b0a <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801b0a:	55                   	push   %ebp
  801b0b:	89 e5                	mov    %esp,%ebp
  801b0d:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
		if (envs[i].env_type == type)
  801b10:	39 0d 50 00 c0 ee    	cmp    %ecx,0xeec00050
  801b16:	74 1a                	je     801b32 <ipc_find_env+0x28>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801b18:	b8 01 00 00 00       	mov    $0x1,%eax
		if (envs[i].env_type == type)
  801b1d:	89 c2                	mov    %eax,%edx
  801b1f:	c1 e2 07             	shl    $0x7,%edx
  801b22:	8d 94 82 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,4),%edx
  801b29:	8b 52 50             	mov    0x50(%edx),%edx
  801b2c:	39 ca                	cmp    %ecx,%edx
  801b2e:	75 18                	jne    801b48 <ipc_find_env+0x3e>
  801b30:	eb 05                	jmp    801b37 <ipc_find_env+0x2d>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801b32:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
			return envs[i].env_id;
  801b37:	89 c2                	mov    %eax,%edx
  801b39:	c1 e2 07             	shl    $0x7,%edx
  801b3c:	8d 84 82 08 00 c0 ee 	lea    -0x113ffff8(%edx,%eax,4),%eax
  801b43:	8b 40 40             	mov    0x40(%eax),%eax
  801b46:	eb 0c                	jmp    801b54 <ipc_find_env+0x4a>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801b48:	40                   	inc    %eax
  801b49:	3d 00 04 00 00       	cmp    $0x400,%eax
  801b4e:	75 cd                	jne    801b1d <ipc_find_env+0x13>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801b50:	66 b8 00 00          	mov    $0x0,%ax
}
  801b54:	c9                   	leave  
  801b55:	c3                   	ret    
	...

00801b58 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801b58:	55                   	push   %ebp
  801b59:	89 e5                	mov    %esp,%ebp
  801b5b:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801b5e:	89 c2                	mov    %eax,%edx
  801b60:	c1 ea 16             	shr    $0x16,%edx
  801b63:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801b6a:	f6 c2 01             	test   $0x1,%dl
  801b6d:	74 1e                	je     801b8d <pageref+0x35>
		return 0;
	pte = uvpt[PGNUM(v)];
  801b6f:	c1 e8 0c             	shr    $0xc,%eax
  801b72:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  801b79:	a8 01                	test   $0x1,%al
  801b7b:	74 17                	je     801b94 <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801b7d:	c1 e8 0c             	shr    $0xc,%eax
  801b80:	66 8b 04 c5 04 00 00 	mov    -0x10fffffc(,%eax,8),%ax
  801b87:	ef 
  801b88:	0f b7 c0             	movzwl %ax,%eax
  801b8b:	eb 0c                	jmp    801b99 <pageref+0x41>
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
		return 0;
  801b8d:	b8 00 00 00 00       	mov    $0x0,%eax
  801b92:	eb 05                	jmp    801b99 <pageref+0x41>
	pte = uvpt[PGNUM(v)];
	if (!(pte & PTE_P))
		return 0;
  801b94:	b8 00 00 00 00       	mov    $0x0,%eax
	return pages[PGNUM(pte)].pp_ref;
}
  801b99:	c9                   	leave  
  801b9a:	c3                   	ret    
	...

00801b9c <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  801b9c:	55                   	push   %ebp
  801b9d:	89 e5                	mov    %esp,%ebp
  801b9f:	57                   	push   %edi
  801ba0:	56                   	push   %esi
  801ba1:	83 ec 10             	sub    $0x10,%esp
  801ba4:	8b 7d 08             	mov    0x8(%ebp),%edi
  801ba7:	8b 4d 10             	mov    0x10(%ebp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  801baa:	89 7d f0             	mov    %edi,-0x10(%ebp)
  801bad:	8b 75 0c             	mov    0xc(%ebp),%esi
  const DWunion dd = {.ll = d};
  801bb0:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  801bb3:	8b 45 14             	mov    0x14(%ebp),%eax
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  801bb6:	85 c0                	test   %eax,%eax
  801bb8:	75 2e                	jne    801be8 <__udivdi3+0x4c>
    {
      if (d0 > n1)
  801bba:	39 f1                	cmp    %esi,%ecx
  801bbc:	77 5a                	ja     801c18 <__udivdi3+0x7c>
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  801bbe:	85 c9                	test   %ecx,%ecx
  801bc0:	75 0b                	jne    801bcd <__udivdi3+0x31>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  801bc2:	b8 01 00 00 00       	mov    $0x1,%eax
  801bc7:	31 d2                	xor    %edx,%edx
  801bc9:	f7 f1                	div    %ecx
  801bcb:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  801bcd:	31 d2                	xor    %edx,%edx
  801bcf:	89 f0                	mov    %esi,%eax
  801bd1:	f7 f1                	div    %ecx
  801bd3:	89 c6                	mov    %eax,%esi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801bd5:	89 f8                	mov    %edi,%eax
  801bd7:	f7 f1                	div    %ecx
  801bd9:	89 c7                	mov    %eax,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  801bdb:	89 f8                	mov    %edi,%eax
  801bdd:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801bdf:	83 c4 10             	add    $0x10,%esp
  801be2:	5e                   	pop    %esi
  801be3:	5f                   	pop    %edi
  801be4:	c9                   	leave  
  801be5:	c3                   	ret    
  801be6:	66 90                	xchg   %ax,%ax
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  801be8:	39 f0                	cmp    %esi,%eax
  801bea:	77 1c                	ja     801c08 <__udivdi3+0x6c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  801bec:	0f bd f8             	bsr    %eax,%edi
	  if (bm == 0)
  801bef:	83 f7 1f             	xor    $0x1f,%edi
  801bf2:	75 3c                	jne    801c30 <__udivdi3+0x94>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  801bf4:	39 f0                	cmp    %esi,%eax
  801bf6:	0f 82 90 00 00 00    	jb     801c8c <__udivdi3+0xf0>
  801bfc:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801bff:	39 55 f4             	cmp    %edx,-0xc(%ebp)
  801c02:	0f 86 84 00 00 00    	jbe    801c8c <__udivdi3+0xf0>
  801c08:	31 f6                	xor    %esi,%esi
  801c0a:	31 ff                	xor    %edi,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  801c0c:	89 f8                	mov    %edi,%eax
  801c0e:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801c10:	83 c4 10             	add    $0x10,%esp
  801c13:	5e                   	pop    %esi
  801c14:	5f                   	pop    %edi
  801c15:	c9                   	leave  
  801c16:	c3                   	ret    
  801c17:	90                   	nop
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801c18:	89 f2                	mov    %esi,%edx
  801c1a:	89 f8                	mov    %edi,%eax
  801c1c:	f7 f1                	div    %ecx
  801c1e:	89 c7                	mov    %eax,%edi
  801c20:	31 f6                	xor    %esi,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  801c22:	89 f8                	mov    %edi,%eax
  801c24:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801c26:	83 c4 10             	add    $0x10,%esp
  801c29:	5e                   	pop    %esi
  801c2a:	5f                   	pop    %edi
  801c2b:	c9                   	leave  
  801c2c:	c3                   	ret    
  801c2d:	8d 76 00             	lea    0x0(%esi),%esi
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  801c30:	89 f9                	mov    %edi,%ecx
  801c32:	d3 e0                	shl    %cl,%eax
  801c34:	89 45 e8             	mov    %eax,-0x18(%ebp)
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  801c37:	b8 20 00 00 00       	mov    $0x20,%eax
  801c3c:	29 f8                	sub    %edi,%eax

	      d1 = (d1 << bm) | (d0 >> b);
  801c3e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801c41:	88 c1                	mov    %al,%cl
  801c43:	d3 ea                	shr    %cl,%edx
  801c45:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  801c48:	09 ca                	or     %ecx,%edx
  801c4a:	89 55 ec             	mov    %edx,-0x14(%ebp)
	      d0 = d0 << bm;
  801c4d:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801c50:	89 f9                	mov    %edi,%ecx
  801c52:	d3 e2                	shl    %cl,%edx
  801c54:	89 55 f4             	mov    %edx,-0xc(%ebp)
	      n2 = n1 >> b;
  801c57:	89 f2                	mov    %esi,%edx
  801c59:	88 c1                	mov    %al,%cl
  801c5b:	d3 ea                	shr    %cl,%edx
  801c5d:	89 55 e8             	mov    %edx,-0x18(%ebp)
	      n1 = (n1 << bm) | (n0 >> b);
  801c60:	89 f2                	mov    %esi,%edx
  801c62:	89 f9                	mov    %edi,%ecx
  801c64:	d3 e2                	shl    %cl,%edx
  801c66:	8b 75 f0             	mov    -0x10(%ebp),%esi
  801c69:	88 c1                	mov    %al,%cl
  801c6b:	d3 ee                	shr    %cl,%esi
  801c6d:	09 d6                	or     %edx,%esi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  801c6f:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  801c72:	89 f0                	mov    %esi,%eax
  801c74:	89 ca                	mov    %ecx,%edx
  801c76:	f7 75 ec             	divl   -0x14(%ebp)
  801c79:	89 d1                	mov    %edx,%ecx
  801c7b:	89 c6                	mov    %eax,%esi
	      umul_ppmm (m1, m0, q0, d0);
  801c7d:	f7 65 f4             	mull   -0xc(%ebp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801c80:	39 d1                	cmp    %edx,%ecx
  801c82:	72 28                	jb     801cac <__udivdi3+0x110>
  801c84:	74 1a                	je     801ca0 <__udivdi3+0x104>
  801c86:	89 f7                	mov    %esi,%edi
  801c88:	31 f6                	xor    %esi,%esi
  801c8a:	eb 80                	jmp    801c0c <__udivdi3+0x70>
	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  801c8c:	31 f6                	xor    %esi,%esi
  801c8e:	bf 01 00 00 00       	mov    $0x1,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  801c93:	89 f8                	mov    %edi,%eax
  801c95:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801c97:	83 c4 10             	add    $0x10,%esp
  801c9a:	5e                   	pop    %esi
  801c9b:	5f                   	pop    %edi
  801c9c:	c9                   	leave  
  801c9d:	c3                   	ret    
  801c9e:	66 90                	xchg   %ax,%ax

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  801ca0:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801ca3:	89 f9                	mov    %edi,%ecx
  801ca5:	d3 e2                	shl    %cl,%edx

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801ca7:	39 c2                	cmp    %eax,%edx
  801ca9:	73 db                	jae    801c86 <__udivdi3+0xea>
  801cab:	90                   	nop
		{
		  q0--;
  801cac:	8d 7e ff             	lea    -0x1(%esi),%edi
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  801caf:	31 f6                	xor    %esi,%esi
  801cb1:	e9 56 ff ff ff       	jmp    801c0c <__udivdi3+0x70>
	...

00801cb8 <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  801cb8:	55                   	push   %ebp
  801cb9:	89 e5                	mov    %esp,%ebp
  801cbb:	57                   	push   %edi
  801cbc:	56                   	push   %esi
  801cbd:	83 ec 20             	sub    $0x20,%esp
  801cc0:	8b 45 08             	mov    0x8(%ebp),%eax
  801cc3:	8b 4d 10             	mov    0x10(%ebp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  801cc6:	89 45 e8             	mov    %eax,-0x18(%ebp)
  801cc9:	8b 75 0c             	mov    0xc(%ebp),%esi
  const DWunion dd = {.ll = d};
  801ccc:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  801ccf:	8b 7d 14             	mov    0x14(%ebp),%edi
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  801cd2:	89 45 f0             	mov    %eax,-0x10(%ebp)
  n1 = nn.s.high;
  801cd5:	89 f2                	mov    %esi,%edx

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  801cd7:	85 ff                	test   %edi,%edi
  801cd9:	75 15                	jne    801cf0 <__umoddi3+0x38>
    {
      if (d0 > n1)
  801cdb:	39 f1                	cmp    %esi,%ecx
  801cdd:	0f 86 99 00 00 00    	jbe    801d7c <__umoddi3+0xc4>
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801ce3:	f7 f1                	div    %ecx

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
  801ce5:	89 d0                	mov    %edx,%eax
  801ce7:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  801ce9:	83 c4 20             	add    $0x20,%esp
  801cec:	5e                   	pop    %esi
  801ced:	5f                   	pop    %edi
  801cee:	c9                   	leave  
  801cef:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  801cf0:	39 f7                	cmp    %esi,%edi
  801cf2:	0f 87 a4 00 00 00    	ja     801d9c <__umoddi3+0xe4>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  801cf8:	0f bd c7             	bsr    %edi,%eax
	  if (bm == 0)
  801cfb:	83 f0 1f             	xor    $0x1f,%eax
  801cfe:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801d01:	0f 84 a1 00 00 00    	je     801da8 <__umoddi3+0xf0>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  801d07:	89 f8                	mov    %edi,%eax
  801d09:	8a 4d ec             	mov    -0x14(%ebp),%cl
  801d0c:	d3 e0                	shl    %cl,%eax
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  801d0e:	bf 20 00 00 00       	mov    $0x20,%edi
  801d13:	2b 7d ec             	sub    -0x14(%ebp),%edi

	      d1 = (d1 << bm) | (d0 >> b);
  801d16:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801d19:	89 f9                	mov    %edi,%ecx
  801d1b:	d3 ea                	shr    %cl,%edx
  801d1d:	09 c2                	or     %eax,%edx
  801d1f:	89 55 f0             	mov    %edx,-0x10(%ebp)
	      d0 = d0 << bm;
  801d22:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d25:	8a 4d ec             	mov    -0x14(%ebp),%cl
  801d28:	d3 e0                	shl    %cl,%eax
  801d2a:	89 45 f4             	mov    %eax,-0xc(%ebp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  801d2d:	89 f2                	mov    %esi,%edx
  801d2f:	d3 e2                	shl    %cl,%edx
	      n0 = n0 << bm;
  801d31:	8b 45 e8             	mov    -0x18(%ebp),%eax
  801d34:	d3 e0                	shl    %cl,%eax
  801d36:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  801d39:	8b 45 e8             	mov    -0x18(%ebp),%eax
  801d3c:	89 f9                	mov    %edi,%ecx
  801d3e:	d3 e8                	shr    %cl,%eax
  801d40:	09 d0                	or     %edx,%eax

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  801d42:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  801d44:	89 f2                	mov    %esi,%edx
  801d46:	f7 75 f0             	divl   -0x10(%ebp)
  801d49:	89 d6                	mov    %edx,%esi
	      umul_ppmm (m1, m0, q0, d0);
  801d4b:	f7 65 f4             	mull   -0xc(%ebp)
  801d4e:	89 55 e8             	mov    %edx,-0x18(%ebp)
  801d51:	89 c1                	mov    %eax,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801d53:	39 d6                	cmp    %edx,%esi
  801d55:	72 71                	jb     801dc8 <__umoddi3+0x110>
  801d57:	74 7f                	je     801dd8 <__umoddi3+0x120>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  801d59:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801d5c:	29 c8                	sub    %ecx,%eax
  801d5e:	19 d6                	sbb    %edx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
  801d60:	8a 4d ec             	mov    -0x14(%ebp),%cl
  801d63:	d3 e8                	shr    %cl,%eax
  801d65:	89 f2                	mov    %esi,%edx
  801d67:	89 f9                	mov    %edi,%ecx
  801d69:	d3 e2                	shl    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
  801d6b:	09 d0                	or     %edx,%eax
  801d6d:	89 f2                	mov    %esi,%edx
  801d6f:	8a 4d ec             	mov    -0x14(%ebp),%cl
  801d72:	d3 ea                	shr    %cl,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  801d74:	83 c4 20             	add    $0x20,%esp
  801d77:	5e                   	pop    %esi
  801d78:	5f                   	pop    %edi
  801d79:	c9                   	leave  
  801d7a:	c3                   	ret    
  801d7b:	90                   	nop
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  801d7c:	85 c9                	test   %ecx,%ecx
  801d7e:	75 0b                	jne    801d8b <__umoddi3+0xd3>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  801d80:	b8 01 00 00 00       	mov    $0x1,%eax
  801d85:	31 d2                	xor    %edx,%edx
  801d87:	f7 f1                	div    %ecx
  801d89:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  801d8b:	89 f0                	mov    %esi,%eax
  801d8d:	31 d2                	xor    %edx,%edx
  801d8f:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801d91:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801d94:	f7 f1                	div    %ecx
  801d96:	e9 4a ff ff ff       	jmp    801ce5 <__umoddi3+0x2d>
  801d9b:	90                   	nop
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
  801d9c:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  801d9e:	83 c4 20             	add    $0x20,%esp
  801da1:	5e                   	pop    %esi
  801da2:	5f                   	pop    %edi
  801da3:	c9                   	leave  
  801da4:	c3                   	ret    
  801da5:	8d 76 00             	lea    0x0(%esi),%esi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  801da8:	39 f7                	cmp    %esi,%edi
  801daa:	72 05                	jb     801db1 <__umoddi3+0xf9>
  801dac:	3b 4d f0             	cmp    -0x10(%ebp),%ecx
  801daf:	77 0c                	ja     801dbd <__umoddi3+0x105>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  801db1:	89 f2                	mov    %esi,%edx
  801db3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801db6:	29 c8                	sub    %ecx,%eax
  801db8:	19 fa                	sbb    %edi,%edx
  801dba:	89 45 f0             	mov    %eax,-0x10(%ebp)

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
  801dbd:	8b 45 f0             	mov    -0x10(%ebp),%eax
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  801dc0:	83 c4 20             	add    $0x20,%esp
  801dc3:	5e                   	pop    %esi
  801dc4:	5f                   	pop    %edi
  801dc5:	c9                   	leave  
  801dc6:	c3                   	ret    
  801dc7:	90                   	nop
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  801dc8:	8b 55 e8             	mov    -0x18(%ebp),%edx
  801dcb:	89 c1                	mov    %eax,%ecx
  801dcd:	2b 4d f4             	sub    -0xc(%ebp),%ecx
  801dd0:	1b 55 f0             	sbb    -0x10(%ebp),%edx
  801dd3:	eb 84                	jmp    801d59 <__umoddi3+0xa1>
  801dd5:	8d 76 00             	lea    0x0(%esi),%esi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801dd8:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  801ddb:	72 eb                	jb     801dc8 <__umoddi3+0x110>
  801ddd:	89 f2                	mov    %esi,%edx
  801ddf:	e9 75 ff ff ff       	jmp    801d59 <__umoddi3+0xa1>
