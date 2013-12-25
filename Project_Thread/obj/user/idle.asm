
obj/user/idle.debug:     file format elf32-i386


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
  80002c:	e8 1b 00 00 00       	call   80004c <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800034 <umain>:
#include <inc/x86.h>
#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	83 ec 08             	sub    $0x8,%esp
	binaryname = "idle";
  80003a:	c7 05 00 30 80 00 e0 	movl   $0x801de0,0x803000
  800041:	1d 80 00 
	// Instead of busy-waiting like this,
	// a better way would be to use the processor's HLT instruction
	// to cause the processor to stop executing until the next interrupt -
	// doing so allows the processor to conserve power more effectively.
	while (1) {
		sys_yield();
  800044:	e8 48 01 00 00       	call   800191 <sys_yield>
  800049:	eb f9                	jmp    800044 <umain+0x10>
	...

0080004c <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80004c:	55                   	push   %ebp
  80004d:	89 e5                	mov    %esp,%ebp
  80004f:	56                   	push   %esi
  800050:	53                   	push   %ebx
  800051:	8b 75 08             	mov    0x8(%ebp),%esi
  800054:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = envs + ENVX(sys_getenvid());
  800057:	e8 11 01 00 00       	call   80016d <sys_getenvid>
  80005c:	25 ff 03 00 00       	and    $0x3ff,%eax
  800061:	89 c2                	mov    %eax,%edx
  800063:	c1 e2 07             	shl    $0x7,%edx
  800066:	8d 84 82 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,4),%eax
  80006d:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800072:	85 f6                	test   %esi,%esi
  800074:	7e 07                	jle    80007d <libmain+0x31>
		binaryname = argv[0];
  800076:	8b 03                	mov    (%ebx),%eax
  800078:	a3 00 30 80 00       	mov    %eax,0x803000
	// call user main routine
	umain(argc, argv);
  80007d:	83 ec 08             	sub    $0x8,%esp
  800080:	53                   	push   %ebx
  800081:	56                   	push   %esi
  800082:	e8 ad ff ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  800087:	e8 0c 00 00 00       	call   800098 <exit>
  80008c:	83 c4 10             	add    $0x10,%esp
}
  80008f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800092:	5b                   	pop    %ebx
  800093:	5e                   	pop    %esi
  800094:	c9                   	leave  
  800095:	c3                   	ret    
	...

00800098 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800098:	55                   	push   %ebp
  800099:	89 e5                	mov    %esp,%ebp
  80009b:	83 ec 08             	sub    $0x8,%esp
	close_all();
  80009e:	e8 cb 04 00 00       	call   80056e <close_all>
	sys_env_destroy(0);
  8000a3:	83 ec 0c             	sub    $0xc,%esp
  8000a6:	6a 00                	push   $0x0
  8000a8:	e8 9e 00 00 00       	call   80014b <sys_env_destroy>
  8000ad:	83 c4 10             	add    $0x10,%esp
}
  8000b0:	c9                   	leave  
  8000b1:	c3                   	ret    
	...

008000b4 <syscall>:
	return ret;
}

static int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  8000b4:	55                   	push   %ebp
  8000b5:	89 e5                	mov    %esp,%ebp
  8000b7:	57                   	push   %edi
  8000b8:	56                   	push   %esi
  8000b9:	53                   	push   %ebx
  8000ba:	83 ec 1c             	sub    $0x1c,%esp
  8000bd:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8000c0:	89 55 e0             	mov    %edx,-0x20(%ebp)
  8000c3:	89 ca                	mov    %ecx,%edx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000c5:	8b 75 14             	mov    0x14(%ebp),%esi
  8000c8:	8b 7d 10             	mov    0x10(%ebp),%edi
  8000cb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8000ce:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8000d1:	cd 30                	int    $0x30
  8000d3:	89 c2                	mov    %eax,%edx
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8000d5:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8000d9:	74 1c                	je     8000f7 <syscall+0x43>
  8000db:	85 c0                	test   %eax,%eax
  8000dd:	7e 18                	jle    8000f7 <syscall+0x43>
		panic("syscall %d returned %d (> 0)", num, ret);
  8000df:	83 ec 0c             	sub    $0xc,%esp
  8000e2:	50                   	push   %eax
  8000e3:	ff 75 e4             	pushl  -0x1c(%ebp)
  8000e6:	68 ef 1d 80 00       	push   $0x801def
  8000eb:	6a 42                	push   $0x42
  8000ed:	68 0c 1e 80 00       	push   $0x801e0c
  8000f2:	e8 21 0f 00 00       	call   801018 <_panic>

	return ret;
}
  8000f7:	89 d0                	mov    %edx,%eax
  8000f9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8000fc:	5b                   	pop    %ebx
  8000fd:	5e                   	pop    %esi
  8000fe:	5f                   	pop    %edi
  8000ff:	c9                   	leave  
  800100:	c3                   	ret    

00800101 <sys_cputs>:

void
sys_cputs(const char *s, size_t len)
{	
  800101:	55                   	push   %ebp
  800102:	89 e5                	mov    %esp,%ebp
  800104:	83 ec 08             	sub    $0x8,%esp
	// my_sysenter(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
	// return;
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
  800107:	6a 00                	push   $0x0
  800109:	6a 00                	push   $0x0
  80010b:	6a 00                	push   $0x0
  80010d:	ff 75 0c             	pushl  0xc(%ebp)
  800110:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800113:	ba 00 00 00 00       	mov    $0x0,%edx
  800118:	b8 00 00 00 00       	mov    $0x0,%eax
  80011d:	e8 92 ff ff ff       	call   8000b4 <syscall>
  800122:	83 c4 10             	add    $0x10,%esp
	return;
}
  800125:	c9                   	leave  
  800126:	c3                   	ret    

00800127 <sys_cgetc>:

int
sys_cgetc(void)
{
  800127:	55                   	push   %ebp
  800128:	89 e5                	mov    %esp,%ebp
  80012a:	83 ec 08             	sub    $0x8,%esp
	// return my_sysenter(SYS_cgetc, 0, 0, 0, 0, 0, 0);
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
  80012d:	6a 00                	push   $0x0
  80012f:	6a 00                	push   $0x0
  800131:	6a 00                	push   $0x0
  800133:	6a 00                	push   $0x0
  800135:	b9 00 00 00 00       	mov    $0x0,%ecx
  80013a:	ba 00 00 00 00       	mov    $0x0,%edx
  80013f:	b8 01 00 00 00       	mov    $0x1,%eax
  800144:	e8 6b ff ff ff       	call   8000b4 <syscall>
}
  800149:	c9                   	leave  
  80014a:	c3                   	ret    

0080014b <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  80014b:	55                   	push   %ebp
  80014c:	89 e5                	mov    %esp,%ebp
  80014e:	83 ec 08             	sub    $0x8,%esp
	// return my_sysenter(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
  800151:	6a 00                	push   $0x0
  800153:	6a 00                	push   $0x0
  800155:	6a 00                	push   $0x0
  800157:	6a 00                	push   $0x0
  800159:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80015c:	ba 01 00 00 00       	mov    $0x1,%edx
  800161:	b8 03 00 00 00       	mov    $0x3,%eax
  800166:	e8 49 ff ff ff       	call   8000b4 <syscall>
}
  80016b:	c9                   	leave  
  80016c:	c3                   	ret    

0080016d <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  80016d:	55                   	push   %ebp
  80016e:	89 e5                	mov    %esp,%ebp
  800170:	83 ec 08             	sub    $0x8,%esp
	// return my_sysenter(SYS_getenvid, 0, 0, 0, 0, 0, 0);
	return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
  800173:	6a 00                	push   $0x0
  800175:	6a 00                	push   $0x0
  800177:	6a 00                	push   $0x0
  800179:	6a 00                	push   $0x0
  80017b:	b9 00 00 00 00       	mov    $0x0,%ecx
  800180:	ba 00 00 00 00       	mov    $0x0,%edx
  800185:	b8 02 00 00 00       	mov    $0x2,%eax
  80018a:	e8 25 ff ff ff       	call   8000b4 <syscall>
}
  80018f:	c9                   	leave  
  800190:	c3                   	ret    

00800191 <sys_yield>:

void
sys_yield(void)
{
  800191:	55                   	push   %ebp
  800192:	89 e5                	mov    %esp,%ebp
  800194:	83 ec 08             	sub    $0x8,%esp
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
  800197:	6a 00                	push   $0x0
  800199:	6a 00                	push   $0x0
  80019b:	6a 00                	push   $0x0
  80019d:	6a 00                	push   $0x0
  80019f:	b9 00 00 00 00       	mov    $0x0,%ecx
  8001a4:	ba 00 00 00 00       	mov    $0x0,%edx
  8001a9:	b8 0b 00 00 00       	mov    $0xb,%eax
  8001ae:	e8 01 ff ff ff       	call   8000b4 <syscall>
  8001b3:	83 c4 10             	add    $0x10,%esp
}
  8001b6:	c9                   	leave  
  8001b7:	c3                   	ret    

008001b8 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  8001b8:	55                   	push   %ebp
  8001b9:	89 e5                	mov    %esp,%ebp
  8001bb:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
  8001be:	6a 00                	push   $0x0
  8001c0:	6a 00                	push   $0x0
  8001c2:	ff 75 10             	pushl  0x10(%ebp)
  8001c5:	ff 75 0c             	pushl  0xc(%ebp)
  8001c8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8001cb:	ba 01 00 00 00       	mov    $0x1,%edx
  8001d0:	b8 04 00 00 00       	mov    $0x4,%eax
  8001d5:	e8 da fe ff ff       	call   8000b4 <syscall>
}
  8001da:	c9                   	leave  
  8001db:	c3                   	ret    

008001dc <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8001dc:	55                   	push   %ebp
  8001dd:	89 e5                	mov    %esp,%ebp
  8001df:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
  8001e2:	ff 75 18             	pushl  0x18(%ebp)
  8001e5:	ff 75 14             	pushl  0x14(%ebp)
  8001e8:	ff 75 10             	pushl  0x10(%ebp)
  8001eb:	ff 75 0c             	pushl  0xc(%ebp)
  8001ee:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8001f1:	ba 01 00 00 00       	mov    $0x1,%edx
  8001f6:	b8 05 00 00 00       	mov    $0x5,%eax
  8001fb:	e8 b4 fe ff ff       	call   8000b4 <syscall>
}
  800200:	c9                   	leave  
  800201:	c3                   	ret    

00800202 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800202:	55                   	push   %ebp
  800203:	89 e5                	mov    %esp,%ebp
  800205:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
  800208:	6a 00                	push   $0x0
  80020a:	6a 00                	push   $0x0
  80020c:	6a 00                	push   $0x0
  80020e:	ff 75 0c             	pushl  0xc(%ebp)
  800211:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800214:	ba 01 00 00 00       	mov    $0x1,%edx
  800219:	b8 06 00 00 00       	mov    $0x6,%eax
  80021e:	e8 91 fe ff ff       	call   8000b4 <syscall>
}
  800223:	c9                   	leave  
  800224:	c3                   	ret    

00800225 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800225:	55                   	push   %ebp
  800226:	89 e5                	mov    %esp,%ebp
  800228:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
  80022b:	6a 00                	push   $0x0
  80022d:	6a 00                	push   $0x0
  80022f:	6a 00                	push   $0x0
  800231:	ff 75 0c             	pushl  0xc(%ebp)
  800234:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800237:	ba 01 00 00 00       	mov    $0x1,%edx
  80023c:	b8 08 00 00 00       	mov    $0x8,%eax
  800241:	e8 6e fe ff ff       	call   8000b4 <syscall>
}
  800246:	c9                   	leave  
  800247:	c3                   	ret    

00800248 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800248:	55                   	push   %ebp
  800249:	89 e5                	mov    %esp,%ebp
  80024b:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
  80024e:	6a 00                	push   $0x0
  800250:	6a 00                	push   $0x0
  800252:	6a 00                	push   $0x0
  800254:	ff 75 0c             	pushl  0xc(%ebp)
  800257:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80025a:	ba 01 00 00 00       	mov    $0x1,%edx
  80025f:	b8 09 00 00 00       	mov    $0x9,%eax
  800264:	e8 4b fe ff ff       	call   8000b4 <syscall>
}
  800269:	c9                   	leave  
  80026a:	c3                   	ret    

0080026b <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  80026b:	55                   	push   %ebp
  80026c:	89 e5                	mov    %esp,%ebp
  80026e:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
  800271:	6a 00                	push   $0x0
  800273:	6a 00                	push   $0x0
  800275:	6a 00                	push   $0x0
  800277:	ff 75 0c             	pushl  0xc(%ebp)
  80027a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80027d:	ba 01 00 00 00       	mov    $0x1,%edx
  800282:	b8 0a 00 00 00       	mov    $0xa,%eax
  800287:	e8 28 fe ff ff       	call   8000b4 <syscall>
}
  80028c:	c9                   	leave  
  80028d:	c3                   	ret    

0080028e <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  80028e:	55                   	push   %ebp
  80028f:	89 e5                	mov    %esp,%ebp
  800291:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
  800294:	6a 00                	push   $0x0
  800296:	ff 75 14             	pushl  0x14(%ebp)
  800299:	ff 75 10             	pushl  0x10(%ebp)
  80029c:	ff 75 0c             	pushl  0xc(%ebp)
  80029f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8002a2:	ba 00 00 00 00       	mov    $0x0,%edx
  8002a7:	b8 0c 00 00 00       	mov    $0xc,%eax
  8002ac:	e8 03 fe ff ff       	call   8000b4 <syscall>
}
  8002b1:	c9                   	leave  
  8002b2:	c3                   	ret    

008002b3 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  8002b3:	55                   	push   %ebp
  8002b4:	89 e5                	mov    %esp,%ebp
  8002b6:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
  8002b9:	6a 00                	push   $0x0
  8002bb:	6a 00                	push   $0x0
  8002bd:	6a 00                	push   $0x0
  8002bf:	6a 00                	push   $0x0
  8002c1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8002c4:	ba 01 00 00 00       	mov    $0x1,%edx
  8002c9:	b8 0d 00 00 00       	mov    $0xd,%eax
  8002ce:	e8 e1 fd ff ff       	call   8000b4 <syscall>
}
  8002d3:	c9                   	leave  
  8002d4:	c3                   	ret    

008002d5 <sys_set_priority>:

int
sys_set_priority(envid_t envid, uint32_t new_priority)
{
  8002d5:	55                   	push   %ebp
  8002d6:	89 e5                	mov    %esp,%ebp
  8002d8:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_set_priority, 0, envid, new_priority, 0, 0, 0);
  8002db:	6a 00                	push   $0x0
  8002dd:	6a 00                	push   $0x0
  8002df:	6a 00                	push   $0x0
  8002e1:	ff 75 0c             	pushl  0xc(%ebp)
  8002e4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8002e7:	ba 00 00 00 00       	mov    $0x0,%edx
  8002ec:	b8 0e 00 00 00       	mov    $0xe,%eax
  8002f1:	e8 be fd ff ff       	call   8000b4 <syscall>
}
  8002f6:	c9                   	leave  
  8002f7:	c3                   	ret    

008002f8 <sys_exec>:

int
sys_exec(uint32_t eip, uint32_t esp, void * ph, uint32_t elf_phnum)
{
  8002f8:	55                   	push   %ebp
  8002f9:	89 e5                	mov    %esp,%ebp
  8002fb:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_exec, 0, eip, esp, (uint32_t)ph, elf_phnum, 0);
  8002fe:	6a 00                	push   $0x0
  800300:	ff 75 14             	pushl  0x14(%ebp)
  800303:	ff 75 10             	pushl  0x10(%ebp)
  800306:	ff 75 0c             	pushl  0xc(%ebp)
  800309:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80030c:	ba 00 00 00 00       	mov    $0x0,%edx
  800311:	b8 0f 00 00 00       	mov    $0xf,%eax
  800316:	e8 99 fd ff ff       	call   8000b4 <syscall>
} 
  80031b:	c9                   	leave  
  80031c:	c3                   	ret    

0080031d <sys_join>:

// thread:
int
sys_join(envid_t envid)
{
  80031d:	55                   	push   %ebp
  80031e:	89 e5                	mov    %esp,%ebp
  800320:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_join, 0, envid, 0, 0, 0, 0);
  800323:	6a 00                	push   $0x0
  800325:	6a 00                	push   $0x0
  800327:	6a 00                	push   $0x0
  800329:	6a 00                	push   $0x0
  80032b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80032e:	ba 00 00 00 00       	mov    $0x0,%edx
  800333:	b8 11 00 00 00       	mov    $0x11,%eax
  800338:	e8 77 fd ff ff       	call   8000b4 <syscall>
}
  80033d:	c9                   	leave  
  80033e:	c3                   	ret    

0080033f <sys_getpid>:

envid_t
sys_getpid(void)
{
  80033f:	55                   	push   %ebp
  800340:	89 e5                	mov    %esp,%ebp
  800342:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_getpid, 0, 0, 0, 0, 0, 0);
  800345:	6a 00                	push   $0x0
  800347:	6a 00                	push   $0x0
  800349:	6a 00                	push   $0x0
  80034b:	6a 00                	push   $0x0
  80034d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800352:	ba 00 00 00 00       	mov    $0x0,%edx
  800357:	b8 10 00 00 00       	mov    $0x10,%eax
  80035c:	e8 53 fd ff ff       	call   8000b4 <syscall>
  800361:	c9                   	leave  
  800362:	c3                   	ret    
	...

00800364 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800364:	55                   	push   %ebp
  800365:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800367:	8b 45 08             	mov    0x8(%ebp),%eax
  80036a:	05 00 00 00 30       	add    $0x30000000,%eax
  80036f:	c1 e8 0c             	shr    $0xc,%eax
}
  800372:	c9                   	leave  
  800373:	c3                   	ret    

00800374 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800374:	55                   	push   %ebp
  800375:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  800377:	ff 75 08             	pushl  0x8(%ebp)
  80037a:	e8 e5 ff ff ff       	call   800364 <fd2num>
  80037f:	83 c4 04             	add    $0x4,%esp
  800382:	05 20 00 0d 00       	add    $0xd0020,%eax
  800387:	c1 e0 0c             	shl    $0xc,%eax
}
  80038a:	c9                   	leave  
  80038b:	c3                   	ret    

0080038c <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  80038c:	55                   	push   %ebp
  80038d:	89 e5                	mov    %esp,%ebp
  80038f:	53                   	push   %ebx
  800390:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800393:	a1 00 dd 7b ef       	mov    0xef7bdd00,%eax
  800398:	a8 01                	test   $0x1,%al
  80039a:	74 34                	je     8003d0 <fd_alloc+0x44>
  80039c:	a1 00 00 74 ef       	mov    0xef740000,%eax
  8003a1:	a8 01                	test   $0x1,%al
  8003a3:	74 32                	je     8003d7 <fd_alloc+0x4b>
  8003a5:	b8 00 10 00 d0       	mov    $0xd0001000,%eax
  8003aa:	89 c1                	mov    %eax,%ecx
  8003ac:	89 c2                	mov    %eax,%edx
  8003ae:	c1 ea 16             	shr    $0x16,%edx
  8003b1:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8003b8:	f6 c2 01             	test   $0x1,%dl
  8003bb:	74 1f                	je     8003dc <fd_alloc+0x50>
  8003bd:	89 c2                	mov    %eax,%edx
  8003bf:	c1 ea 0c             	shr    $0xc,%edx
  8003c2:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8003c9:	f6 c2 01             	test   $0x1,%dl
  8003cc:	75 17                	jne    8003e5 <fd_alloc+0x59>
  8003ce:	eb 0c                	jmp    8003dc <fd_alloc+0x50>
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  8003d0:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
  8003d5:	eb 05                	jmp    8003dc <fd_alloc+0x50>
  8003d7:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
  8003dc:	89 0b                	mov    %ecx,(%ebx)
			return 0;
  8003de:	b8 00 00 00 00       	mov    $0x0,%eax
  8003e3:	eb 17                	jmp    8003fc <fd_alloc+0x70>
  8003e5:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8003ea:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8003ef:	75 b9                	jne    8003aa <fd_alloc+0x1e>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8003f1:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_MAX_OPEN;
  8003f7:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8003fc:	5b                   	pop    %ebx
  8003fd:	c9                   	leave  
  8003fe:	c3                   	ret    

008003ff <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8003ff:	55                   	push   %ebp
  800400:	89 e5                	mov    %esp,%ebp
  800402:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800405:	83 f8 1f             	cmp    $0x1f,%eax
  800408:	77 36                	ja     800440 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  80040a:	05 00 00 0d 00       	add    $0xd0000,%eax
  80040f:	c1 e0 0c             	shl    $0xc,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800412:	89 c2                	mov    %eax,%edx
  800414:	c1 ea 16             	shr    $0x16,%edx
  800417:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80041e:	f6 c2 01             	test   $0x1,%dl
  800421:	74 24                	je     800447 <fd_lookup+0x48>
  800423:	89 c2                	mov    %eax,%edx
  800425:	c1 ea 0c             	shr    $0xc,%edx
  800428:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80042f:	f6 c2 01             	test   $0x1,%dl
  800432:	74 1a                	je     80044e <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800434:	8b 55 0c             	mov    0xc(%ebp),%edx
  800437:	89 02                	mov    %eax,(%edx)
	return 0;
  800439:	b8 00 00 00 00       	mov    $0x0,%eax
  80043e:	eb 13                	jmp    800453 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800440:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800445:	eb 0c                	jmp    800453 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800447:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80044c:	eb 05                	jmp    800453 <fd_lookup+0x54>
  80044e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800453:	c9                   	leave  
  800454:	c3                   	ret    

00800455 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800455:	55                   	push   %ebp
  800456:	89 e5                	mov    %esp,%ebp
  800458:	53                   	push   %ebx
  800459:	83 ec 04             	sub    $0x4,%esp
  80045c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80045f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
		if (devtab[i]->dev_id == dev_id) {
  800462:	39 0d 04 30 80 00    	cmp    %ecx,0x803004
  800468:	74 0d                	je     800477 <dev_lookup+0x22>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  80046a:	b8 00 00 00 00       	mov    $0x0,%eax
  80046f:	eb 14                	jmp    800485 <dev_lookup+0x30>
		if (devtab[i]->dev_id == dev_id) {
  800471:	39 0a                	cmp    %ecx,(%edx)
  800473:	75 10                	jne    800485 <dev_lookup+0x30>
  800475:	eb 05                	jmp    80047c <dev_lookup+0x27>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800477:	ba 04 30 80 00       	mov    $0x803004,%edx
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
  80047c:	89 13                	mov    %edx,(%ebx)
			return 0;
  80047e:	b8 00 00 00 00       	mov    $0x0,%eax
  800483:	eb 31                	jmp    8004b6 <dev_lookup+0x61>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800485:	40                   	inc    %eax
  800486:	8b 14 85 98 1e 80 00 	mov    0x801e98(,%eax,4),%edx
  80048d:	85 d2                	test   %edx,%edx
  80048f:	75 e0                	jne    800471 <dev_lookup+0x1c>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800491:	a1 04 40 80 00       	mov    0x804004,%eax
  800496:	8b 40 48             	mov    0x48(%eax),%eax
  800499:	83 ec 04             	sub    $0x4,%esp
  80049c:	51                   	push   %ecx
  80049d:	50                   	push   %eax
  80049e:	68 1c 1e 80 00       	push   $0x801e1c
  8004a3:	e8 48 0c 00 00       	call   8010f0 <cprintf>
	*dev = 0;
  8004a8:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_INVAL;
  8004ae:	83 c4 10             	add    $0x10,%esp
  8004b1:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8004b6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8004b9:	c9                   	leave  
  8004ba:	c3                   	ret    

008004bb <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8004bb:	55                   	push   %ebp
  8004bc:	89 e5                	mov    %esp,%ebp
  8004be:	56                   	push   %esi
  8004bf:	53                   	push   %ebx
  8004c0:	83 ec 20             	sub    $0x20,%esp
  8004c3:	8b 75 08             	mov    0x8(%ebp),%esi
  8004c6:	8a 45 0c             	mov    0xc(%ebp),%al
  8004c9:	88 45 e7             	mov    %al,-0x19(%ebp)
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8004cc:	56                   	push   %esi
  8004cd:	e8 92 fe ff ff       	call   800364 <fd2num>
  8004d2:	8d 55 f4             	lea    -0xc(%ebp),%edx
  8004d5:	89 14 24             	mov    %edx,(%esp)
  8004d8:	50                   	push   %eax
  8004d9:	e8 21 ff ff ff       	call   8003ff <fd_lookup>
  8004de:	89 c3                	mov    %eax,%ebx
  8004e0:	83 c4 08             	add    $0x8,%esp
  8004e3:	85 c0                	test   %eax,%eax
  8004e5:	78 05                	js     8004ec <fd_close+0x31>
	    || fd != fd2)
  8004e7:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8004ea:	74 0d                	je     8004f9 <fd_close+0x3e>
		return (must_exist ? r : 0);
  8004ec:	80 7d e7 00          	cmpb   $0x0,-0x19(%ebp)
  8004f0:	75 48                	jne    80053a <fd_close+0x7f>
  8004f2:	bb 00 00 00 00       	mov    $0x0,%ebx
  8004f7:	eb 41                	jmp    80053a <fd_close+0x7f>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8004f9:	83 ec 08             	sub    $0x8,%esp
  8004fc:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8004ff:	50                   	push   %eax
  800500:	ff 36                	pushl  (%esi)
  800502:	e8 4e ff ff ff       	call   800455 <dev_lookup>
  800507:	89 c3                	mov    %eax,%ebx
  800509:	83 c4 10             	add    $0x10,%esp
  80050c:	85 c0                	test   %eax,%eax
  80050e:	78 1c                	js     80052c <fd_close+0x71>
		if (dev->dev_close)
  800510:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800513:	8b 40 10             	mov    0x10(%eax),%eax
  800516:	85 c0                	test   %eax,%eax
  800518:	74 0d                	je     800527 <fd_close+0x6c>
			r = (*dev->dev_close)(fd);
  80051a:	83 ec 0c             	sub    $0xc,%esp
  80051d:	56                   	push   %esi
  80051e:	ff d0                	call   *%eax
  800520:	89 c3                	mov    %eax,%ebx
  800522:	83 c4 10             	add    $0x10,%esp
  800525:	eb 05                	jmp    80052c <fd_close+0x71>
		else
			r = 0;
  800527:	bb 00 00 00 00       	mov    $0x0,%ebx
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  80052c:	83 ec 08             	sub    $0x8,%esp
  80052f:	56                   	push   %esi
  800530:	6a 00                	push   $0x0
  800532:	e8 cb fc ff ff       	call   800202 <sys_page_unmap>
	return r;
  800537:	83 c4 10             	add    $0x10,%esp
}
  80053a:	89 d8                	mov    %ebx,%eax
  80053c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80053f:	5b                   	pop    %ebx
  800540:	5e                   	pop    %esi
  800541:	c9                   	leave  
  800542:	c3                   	ret    

00800543 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  800543:	55                   	push   %ebp
  800544:	89 e5                	mov    %esp,%ebp
  800546:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800549:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80054c:	50                   	push   %eax
  80054d:	ff 75 08             	pushl  0x8(%ebp)
  800550:	e8 aa fe ff ff       	call   8003ff <fd_lookup>
  800555:	83 c4 08             	add    $0x8,%esp
  800558:	85 c0                	test   %eax,%eax
  80055a:	78 10                	js     80056c <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  80055c:	83 ec 08             	sub    $0x8,%esp
  80055f:	6a 01                	push   $0x1
  800561:	ff 75 f4             	pushl  -0xc(%ebp)
  800564:	e8 52 ff ff ff       	call   8004bb <fd_close>
  800569:	83 c4 10             	add    $0x10,%esp
}
  80056c:	c9                   	leave  
  80056d:	c3                   	ret    

0080056e <close_all>:

void
close_all(void)
{
  80056e:	55                   	push   %ebp
  80056f:	89 e5                	mov    %esp,%ebp
  800571:	53                   	push   %ebx
  800572:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800575:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  80057a:	83 ec 0c             	sub    $0xc,%esp
  80057d:	53                   	push   %ebx
  80057e:	e8 c0 ff ff ff       	call   800543 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  800583:	43                   	inc    %ebx
  800584:	83 c4 10             	add    $0x10,%esp
  800587:	83 fb 20             	cmp    $0x20,%ebx
  80058a:	75 ee                	jne    80057a <close_all+0xc>
		close(i);
}
  80058c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80058f:	c9                   	leave  
  800590:	c3                   	ret    

00800591 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800591:	55                   	push   %ebp
  800592:	89 e5                	mov    %esp,%ebp
  800594:	57                   	push   %edi
  800595:	56                   	push   %esi
  800596:	53                   	push   %ebx
  800597:	83 ec 2c             	sub    $0x2c,%esp
  80059a:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  80059d:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8005a0:	50                   	push   %eax
  8005a1:	ff 75 08             	pushl  0x8(%ebp)
  8005a4:	e8 56 fe ff ff       	call   8003ff <fd_lookup>
  8005a9:	89 c3                	mov    %eax,%ebx
  8005ab:	83 c4 08             	add    $0x8,%esp
  8005ae:	85 c0                	test   %eax,%eax
  8005b0:	0f 88 c0 00 00 00    	js     800676 <dup+0xe5>
		return r;
	close(newfdnum);
  8005b6:	83 ec 0c             	sub    $0xc,%esp
  8005b9:	57                   	push   %edi
  8005ba:	e8 84 ff ff ff       	call   800543 <close>

	newfd = INDEX2FD(newfdnum);
  8005bf:	8d b7 00 00 0d 00    	lea    0xd0000(%edi),%esi
  8005c5:	c1 e6 0c             	shl    $0xc,%esi
	ova = fd2data(oldfd);
  8005c8:	83 c4 04             	add    $0x4,%esp
  8005cb:	ff 75 e4             	pushl  -0x1c(%ebp)
  8005ce:	e8 a1 fd ff ff       	call   800374 <fd2data>
  8005d3:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  8005d5:	89 34 24             	mov    %esi,(%esp)
  8005d8:	e8 97 fd ff ff       	call   800374 <fd2data>
  8005dd:	83 c4 10             	add    $0x10,%esp
  8005e0:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8005e3:	89 d8                	mov    %ebx,%eax
  8005e5:	c1 e8 16             	shr    $0x16,%eax
  8005e8:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8005ef:	a8 01                	test   $0x1,%al
  8005f1:	74 37                	je     80062a <dup+0x99>
  8005f3:	89 d8                	mov    %ebx,%eax
  8005f5:	c1 e8 0c             	shr    $0xc,%eax
  8005f8:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8005ff:	f6 c2 01             	test   $0x1,%dl
  800602:	74 26                	je     80062a <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  800604:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80060b:	83 ec 0c             	sub    $0xc,%esp
  80060e:	25 07 0e 00 00       	and    $0xe07,%eax
  800613:	50                   	push   %eax
  800614:	ff 75 d4             	pushl  -0x2c(%ebp)
  800617:	6a 00                	push   $0x0
  800619:	53                   	push   %ebx
  80061a:	6a 00                	push   $0x0
  80061c:	e8 bb fb ff ff       	call   8001dc <sys_page_map>
  800621:	89 c3                	mov    %eax,%ebx
  800623:	83 c4 20             	add    $0x20,%esp
  800626:	85 c0                	test   %eax,%eax
  800628:	78 2d                	js     800657 <dup+0xc6>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80062a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80062d:	89 c2                	mov    %eax,%edx
  80062f:	c1 ea 0c             	shr    $0xc,%edx
  800632:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800639:	83 ec 0c             	sub    $0xc,%esp
  80063c:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  800642:	52                   	push   %edx
  800643:	56                   	push   %esi
  800644:	6a 00                	push   $0x0
  800646:	50                   	push   %eax
  800647:	6a 00                	push   $0x0
  800649:	e8 8e fb ff ff       	call   8001dc <sys_page_map>
  80064e:	89 c3                	mov    %eax,%ebx
  800650:	83 c4 20             	add    $0x20,%esp
  800653:	85 c0                	test   %eax,%eax
  800655:	79 1d                	jns    800674 <dup+0xe3>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  800657:	83 ec 08             	sub    $0x8,%esp
  80065a:	56                   	push   %esi
  80065b:	6a 00                	push   $0x0
  80065d:	e8 a0 fb ff ff       	call   800202 <sys_page_unmap>
	sys_page_unmap(0, nva);
  800662:	83 c4 08             	add    $0x8,%esp
  800665:	ff 75 d4             	pushl  -0x2c(%ebp)
  800668:	6a 00                	push   $0x0
  80066a:	e8 93 fb ff ff       	call   800202 <sys_page_unmap>
	return r;
  80066f:	83 c4 10             	add    $0x10,%esp
  800672:	eb 02                	jmp    800676 <dup+0xe5>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
		goto err;

	return newfdnum;
  800674:	89 fb                	mov    %edi,%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  800676:	89 d8                	mov    %ebx,%eax
  800678:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80067b:	5b                   	pop    %ebx
  80067c:	5e                   	pop    %esi
  80067d:	5f                   	pop    %edi
  80067e:	c9                   	leave  
  80067f:	c3                   	ret    

00800680 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  800680:	55                   	push   %ebp
  800681:	89 e5                	mov    %esp,%ebp
  800683:	53                   	push   %ebx
  800684:	83 ec 14             	sub    $0x14,%esp
  800687:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80068a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80068d:	50                   	push   %eax
  80068e:	53                   	push   %ebx
  80068f:	e8 6b fd ff ff       	call   8003ff <fd_lookup>
  800694:	83 c4 08             	add    $0x8,%esp
  800697:	85 c0                	test   %eax,%eax
  800699:	78 67                	js     800702 <read+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80069b:	83 ec 08             	sub    $0x8,%esp
  80069e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8006a1:	50                   	push   %eax
  8006a2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8006a5:	ff 30                	pushl  (%eax)
  8006a7:	e8 a9 fd ff ff       	call   800455 <dev_lookup>
  8006ac:	83 c4 10             	add    $0x10,%esp
  8006af:	85 c0                	test   %eax,%eax
  8006b1:	78 4f                	js     800702 <read+0x82>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8006b3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8006b6:	8b 50 08             	mov    0x8(%eax),%edx
  8006b9:	83 e2 03             	and    $0x3,%edx
  8006bc:	83 fa 01             	cmp    $0x1,%edx
  8006bf:	75 21                	jne    8006e2 <read+0x62>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8006c1:	a1 04 40 80 00       	mov    0x804004,%eax
  8006c6:	8b 40 48             	mov    0x48(%eax),%eax
  8006c9:	83 ec 04             	sub    $0x4,%esp
  8006cc:	53                   	push   %ebx
  8006cd:	50                   	push   %eax
  8006ce:	68 5d 1e 80 00       	push   $0x801e5d
  8006d3:	e8 18 0a 00 00       	call   8010f0 <cprintf>
		return -E_INVAL;
  8006d8:	83 c4 10             	add    $0x10,%esp
  8006db:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8006e0:	eb 20                	jmp    800702 <read+0x82>
	}
	if (!dev->dev_read)
  8006e2:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8006e5:	8b 52 08             	mov    0x8(%edx),%edx
  8006e8:	85 d2                	test   %edx,%edx
  8006ea:	74 11                	je     8006fd <read+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8006ec:	83 ec 04             	sub    $0x4,%esp
  8006ef:	ff 75 10             	pushl  0x10(%ebp)
  8006f2:	ff 75 0c             	pushl  0xc(%ebp)
  8006f5:	50                   	push   %eax
  8006f6:	ff d2                	call   *%edx
  8006f8:	83 c4 10             	add    $0x10,%esp
  8006fb:	eb 05                	jmp    800702 <read+0x82>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8006fd:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_read)(fd, buf, n);
}
  800702:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800705:	c9                   	leave  
  800706:	c3                   	ret    

00800707 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  800707:	55                   	push   %ebp
  800708:	89 e5                	mov    %esp,%ebp
  80070a:	57                   	push   %edi
  80070b:	56                   	push   %esi
  80070c:	53                   	push   %ebx
  80070d:	83 ec 0c             	sub    $0xc,%esp
  800710:	8b 7d 08             	mov    0x8(%ebp),%edi
  800713:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  800716:	85 f6                	test   %esi,%esi
  800718:	74 31                	je     80074b <readn+0x44>
  80071a:	b8 00 00 00 00       	mov    $0x0,%eax
  80071f:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = read(fdnum, (char*)buf + tot, n - tot);
  800724:	83 ec 04             	sub    $0x4,%esp
  800727:	89 f2                	mov    %esi,%edx
  800729:	29 c2                	sub    %eax,%edx
  80072b:	52                   	push   %edx
  80072c:	03 45 0c             	add    0xc(%ebp),%eax
  80072f:	50                   	push   %eax
  800730:	57                   	push   %edi
  800731:	e8 4a ff ff ff       	call   800680 <read>
		if (m < 0)
  800736:	83 c4 10             	add    $0x10,%esp
  800739:	85 c0                	test   %eax,%eax
  80073b:	78 17                	js     800754 <readn+0x4d>
			return m;
		if (m == 0)
  80073d:	85 c0                	test   %eax,%eax
  80073f:	74 11                	je     800752 <readn+0x4b>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  800741:	01 c3                	add    %eax,%ebx
  800743:	89 d8                	mov    %ebx,%eax
  800745:	39 f3                	cmp    %esi,%ebx
  800747:	72 db                	jb     800724 <readn+0x1d>
  800749:	eb 09                	jmp    800754 <readn+0x4d>
  80074b:	b8 00 00 00 00       	mov    $0x0,%eax
  800750:	eb 02                	jmp    800754 <readn+0x4d>
		m = read(fdnum, (char*)buf + tot, n - tot);
		if (m < 0)
			return m;
		if (m == 0)
  800752:	89 d8                	mov    %ebx,%eax
			break;
	}
	return tot;
}
  800754:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800757:	5b                   	pop    %ebx
  800758:	5e                   	pop    %esi
  800759:	5f                   	pop    %edi
  80075a:	c9                   	leave  
  80075b:	c3                   	ret    

0080075c <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80075c:	55                   	push   %ebp
  80075d:	89 e5                	mov    %esp,%ebp
  80075f:	53                   	push   %ebx
  800760:	83 ec 14             	sub    $0x14,%esp
  800763:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800766:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800769:	50                   	push   %eax
  80076a:	53                   	push   %ebx
  80076b:	e8 8f fc ff ff       	call   8003ff <fd_lookup>
  800770:	83 c4 08             	add    $0x8,%esp
  800773:	85 c0                	test   %eax,%eax
  800775:	78 62                	js     8007d9 <write+0x7d>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800777:	83 ec 08             	sub    $0x8,%esp
  80077a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80077d:	50                   	push   %eax
  80077e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800781:	ff 30                	pushl  (%eax)
  800783:	e8 cd fc ff ff       	call   800455 <dev_lookup>
  800788:	83 c4 10             	add    $0x10,%esp
  80078b:	85 c0                	test   %eax,%eax
  80078d:	78 4a                	js     8007d9 <write+0x7d>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80078f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800792:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  800796:	75 21                	jne    8007b9 <write+0x5d>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  800798:	a1 04 40 80 00       	mov    0x804004,%eax
  80079d:	8b 40 48             	mov    0x48(%eax),%eax
  8007a0:	83 ec 04             	sub    $0x4,%esp
  8007a3:	53                   	push   %ebx
  8007a4:	50                   	push   %eax
  8007a5:	68 79 1e 80 00       	push   $0x801e79
  8007aa:	e8 41 09 00 00       	call   8010f0 <cprintf>
		return -E_INVAL;
  8007af:	83 c4 10             	add    $0x10,%esp
  8007b2:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8007b7:	eb 20                	jmp    8007d9 <write+0x7d>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8007b9:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8007bc:	8b 52 0c             	mov    0xc(%edx),%edx
  8007bf:	85 d2                	test   %edx,%edx
  8007c1:	74 11                	je     8007d4 <write+0x78>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8007c3:	83 ec 04             	sub    $0x4,%esp
  8007c6:	ff 75 10             	pushl  0x10(%ebp)
  8007c9:	ff 75 0c             	pushl  0xc(%ebp)
  8007cc:	50                   	push   %eax
  8007cd:	ff d2                	call   *%edx
  8007cf:	83 c4 10             	add    $0x10,%esp
  8007d2:	eb 05                	jmp    8007d9 <write+0x7d>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8007d4:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  8007d9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007dc:	c9                   	leave  
  8007dd:	c3                   	ret    

008007de <seek>:

int
seek(int fdnum, off_t offset)
{
  8007de:	55                   	push   %ebp
  8007df:	89 e5                	mov    %esp,%ebp
  8007e1:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8007e4:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8007e7:	50                   	push   %eax
  8007e8:	ff 75 08             	pushl  0x8(%ebp)
  8007eb:	e8 0f fc ff ff       	call   8003ff <fd_lookup>
  8007f0:	83 c4 08             	add    $0x8,%esp
  8007f3:	85 c0                	test   %eax,%eax
  8007f5:	78 0e                	js     800805 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8007f7:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8007fa:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007fd:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  800800:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800805:	c9                   	leave  
  800806:	c3                   	ret    

00800807 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  800807:	55                   	push   %ebp
  800808:	89 e5                	mov    %esp,%ebp
  80080a:	53                   	push   %ebx
  80080b:	83 ec 14             	sub    $0x14,%esp
  80080e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  800811:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800814:	50                   	push   %eax
  800815:	53                   	push   %ebx
  800816:	e8 e4 fb ff ff       	call   8003ff <fd_lookup>
  80081b:	83 c4 08             	add    $0x8,%esp
  80081e:	85 c0                	test   %eax,%eax
  800820:	78 5f                	js     800881 <ftruncate+0x7a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800822:	83 ec 08             	sub    $0x8,%esp
  800825:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800828:	50                   	push   %eax
  800829:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80082c:	ff 30                	pushl  (%eax)
  80082e:	e8 22 fc ff ff       	call   800455 <dev_lookup>
  800833:	83 c4 10             	add    $0x10,%esp
  800836:	85 c0                	test   %eax,%eax
  800838:	78 47                	js     800881 <ftruncate+0x7a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80083a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80083d:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  800841:	75 21                	jne    800864 <ftruncate+0x5d>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  800843:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  800848:	8b 40 48             	mov    0x48(%eax),%eax
  80084b:	83 ec 04             	sub    $0x4,%esp
  80084e:	53                   	push   %ebx
  80084f:	50                   	push   %eax
  800850:	68 3c 1e 80 00       	push   $0x801e3c
  800855:	e8 96 08 00 00       	call   8010f0 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  80085a:	83 c4 10             	add    $0x10,%esp
  80085d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800862:	eb 1d                	jmp    800881 <ftruncate+0x7a>
	}
	if (!dev->dev_trunc)
  800864:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800867:	8b 52 18             	mov    0x18(%edx),%edx
  80086a:	85 d2                	test   %edx,%edx
  80086c:	74 0e                	je     80087c <ftruncate+0x75>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80086e:	83 ec 08             	sub    $0x8,%esp
  800871:	ff 75 0c             	pushl  0xc(%ebp)
  800874:	50                   	push   %eax
  800875:	ff d2                	call   *%edx
  800877:	83 c4 10             	add    $0x10,%esp
  80087a:	eb 05                	jmp    800881 <ftruncate+0x7a>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  80087c:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  800881:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800884:	c9                   	leave  
  800885:	c3                   	ret    

00800886 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  800886:	55                   	push   %ebp
  800887:	89 e5                	mov    %esp,%ebp
  800889:	53                   	push   %ebx
  80088a:	83 ec 14             	sub    $0x14,%esp
  80088d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800890:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800893:	50                   	push   %eax
  800894:	ff 75 08             	pushl  0x8(%ebp)
  800897:	e8 63 fb ff ff       	call   8003ff <fd_lookup>
  80089c:	83 c4 08             	add    $0x8,%esp
  80089f:	85 c0                	test   %eax,%eax
  8008a1:	78 52                	js     8008f5 <fstat+0x6f>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8008a3:	83 ec 08             	sub    $0x8,%esp
  8008a6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8008a9:	50                   	push   %eax
  8008aa:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8008ad:	ff 30                	pushl  (%eax)
  8008af:	e8 a1 fb ff ff       	call   800455 <dev_lookup>
  8008b4:	83 c4 10             	add    $0x10,%esp
  8008b7:	85 c0                	test   %eax,%eax
  8008b9:	78 3a                	js     8008f5 <fstat+0x6f>
		return r;
	if (!dev->dev_stat)
  8008bb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8008be:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8008c2:	74 2c                	je     8008f0 <fstat+0x6a>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8008c4:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8008c7:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8008ce:	00 00 00 
	stat->st_isdir = 0;
  8008d1:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8008d8:	00 00 00 
	stat->st_dev = dev;
  8008db:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8008e1:	83 ec 08             	sub    $0x8,%esp
  8008e4:	53                   	push   %ebx
  8008e5:	ff 75 f0             	pushl  -0x10(%ebp)
  8008e8:	ff 50 14             	call   *0x14(%eax)
  8008eb:	83 c4 10             	add    $0x10,%esp
  8008ee:	eb 05                	jmp    8008f5 <fstat+0x6f>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8008f0:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8008f5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8008f8:	c9                   	leave  
  8008f9:	c3                   	ret    

008008fa <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8008fa:	55                   	push   %ebp
  8008fb:	89 e5                	mov    %esp,%ebp
  8008fd:	56                   	push   %esi
  8008fe:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8008ff:	83 ec 08             	sub    $0x8,%esp
  800902:	6a 00                	push   $0x0
  800904:	ff 75 08             	pushl  0x8(%ebp)
  800907:	e8 78 01 00 00       	call   800a84 <open>
  80090c:	89 c3                	mov    %eax,%ebx
  80090e:	83 c4 10             	add    $0x10,%esp
  800911:	85 c0                	test   %eax,%eax
  800913:	78 1b                	js     800930 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  800915:	83 ec 08             	sub    $0x8,%esp
  800918:	ff 75 0c             	pushl  0xc(%ebp)
  80091b:	50                   	push   %eax
  80091c:	e8 65 ff ff ff       	call   800886 <fstat>
  800921:	89 c6                	mov    %eax,%esi
	close(fd);
  800923:	89 1c 24             	mov    %ebx,(%esp)
  800926:	e8 18 fc ff ff       	call   800543 <close>
	return r;
  80092b:	83 c4 10             	add    $0x10,%esp
  80092e:	89 f3                	mov    %esi,%ebx
}
  800930:	89 d8                	mov    %ebx,%eax
  800932:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800935:	5b                   	pop    %ebx
  800936:	5e                   	pop    %esi
  800937:	c9                   	leave  
  800938:	c3                   	ret    
  800939:	00 00                	add    %al,(%eax)
	...

0080093c <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  80093c:	55                   	push   %ebp
  80093d:	89 e5                	mov    %esp,%ebp
  80093f:	56                   	push   %esi
  800940:	53                   	push   %ebx
  800941:	89 c3                	mov    %eax,%ebx
  800943:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  800945:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  80094c:	75 12                	jne    800960 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  80094e:	83 ec 0c             	sub    $0xc,%esp
  800951:	6a 01                	push   $0x1
  800953:	e8 96 11 00 00       	call   801aee <ipc_find_env>
  800958:	a3 00 40 80 00       	mov    %eax,0x804000
  80095d:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  800960:	6a 07                	push   $0x7
  800962:	68 00 50 80 00       	push   $0x805000
  800967:	53                   	push   %ebx
  800968:	ff 35 00 40 80 00    	pushl  0x804000
  80096e:	e8 26 11 00 00       	call   801a99 <ipc_send>
	
	return ipc_recv(NULL, dstva, NULL);
  800973:	83 c4 0c             	add    $0xc,%esp
  800976:	6a 00                	push   $0x0
  800978:	56                   	push   %esi
  800979:	6a 00                	push   $0x0
  80097b:	e8 a4 10 00 00       	call   801a24 <ipc_recv>
}
  800980:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800983:	5b                   	pop    %ebx
  800984:	5e                   	pop    %esi
  800985:	c9                   	leave  
  800986:	c3                   	ret    

00800987 <devfile_stat>:
}


static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  800987:	55                   	push   %ebp
  800988:	89 e5                	mov    %esp,%ebp
  80098a:	53                   	push   %ebx
  80098b:	83 ec 04             	sub    $0x4,%esp
  80098e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  800991:	8b 45 08             	mov    0x8(%ebp),%eax
  800994:	8b 40 0c             	mov    0xc(%eax),%eax
  800997:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0) {
  80099c:	ba 00 00 00 00       	mov    $0x0,%edx
  8009a1:	b8 05 00 00 00       	mov    $0x5,%eax
  8009a6:	e8 91 ff ff ff       	call   80093c <fsipc>
  8009ab:	85 c0                	test   %eax,%eax
  8009ad:	78 2c                	js     8009db <devfile_stat+0x54>
		return r;
	}
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8009af:	83 ec 08             	sub    $0x8,%esp
  8009b2:	68 00 50 80 00       	push   $0x805000
  8009b7:	53                   	push   %ebx
  8009b8:	e8 e9 0c 00 00       	call   8016a6 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8009bd:	a1 80 50 80 00       	mov    0x805080,%eax
  8009c2:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8009c8:	a1 84 50 80 00       	mov    0x805084,%eax
  8009cd:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8009d3:	83 c4 10             	add    $0x10,%esp
  8009d6:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009db:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8009de:	c9                   	leave  
  8009df:	c3                   	ret    

008009e0 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8009e0:	55                   	push   %ebp
  8009e1:	89 e5                	mov    %esp,%ebp
  8009e3:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8009e6:	8b 45 08             	mov    0x8(%ebp),%eax
  8009e9:	8b 40 0c             	mov    0xc(%eax),%eax
  8009ec:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8009f1:	ba 00 00 00 00       	mov    $0x0,%edx
  8009f6:	b8 06 00 00 00       	mov    $0x6,%eax
  8009fb:	e8 3c ff ff ff       	call   80093c <fsipc>
}
  800a00:	c9                   	leave  
  800a01:	c3                   	ret    

00800a02 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  800a02:	55                   	push   %ebp
  800a03:	89 e5                	mov    %esp,%ebp
  800a05:	56                   	push   %esi
  800a06:	53                   	push   %ebx
  800a07:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  800a0a:	8b 45 08             	mov    0x8(%ebp),%eax
  800a0d:	8b 40 0c             	mov    0xc(%eax),%eax
  800a10:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  800a15:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  800a1b:	ba 00 00 00 00       	mov    $0x0,%edx
  800a20:	b8 03 00 00 00       	mov    $0x3,%eax
  800a25:	e8 12 ff ff ff       	call   80093c <fsipc>
  800a2a:	89 c3                	mov    %eax,%ebx
  800a2c:	85 c0                	test   %eax,%eax
  800a2e:	78 4b                	js     800a7b <devfile_read+0x79>
		return r;
	assert(r <= n);
  800a30:	39 c6                	cmp    %eax,%esi
  800a32:	73 16                	jae    800a4a <devfile_read+0x48>
  800a34:	68 a8 1e 80 00       	push   $0x801ea8
  800a39:	68 af 1e 80 00       	push   $0x801eaf
  800a3e:	6a 7d                	push   $0x7d
  800a40:	68 c4 1e 80 00       	push   $0x801ec4
  800a45:	e8 ce 05 00 00       	call   801018 <_panic>
	assert(r <= PGSIZE);
  800a4a:	3d 00 10 00 00       	cmp    $0x1000,%eax
  800a4f:	7e 16                	jle    800a67 <devfile_read+0x65>
  800a51:	68 cf 1e 80 00       	push   $0x801ecf
  800a56:	68 af 1e 80 00       	push   $0x801eaf
  800a5b:	6a 7e                	push   $0x7e
  800a5d:	68 c4 1e 80 00       	push   $0x801ec4
  800a62:	e8 b1 05 00 00       	call   801018 <_panic>
	memmove(buf, &fsipcbuf, r);
  800a67:	83 ec 04             	sub    $0x4,%esp
  800a6a:	50                   	push   %eax
  800a6b:	68 00 50 80 00       	push   $0x805000
  800a70:	ff 75 0c             	pushl  0xc(%ebp)
  800a73:	e8 ef 0d 00 00       	call   801867 <memmove>
	return r;
  800a78:	83 c4 10             	add    $0x10,%esp
}
  800a7b:	89 d8                	mov    %ebx,%eax
  800a7d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800a80:	5b                   	pop    %ebx
  800a81:	5e                   	pop    %esi
  800a82:	c9                   	leave  
  800a83:	c3                   	ret    

00800a84 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  800a84:	55                   	push   %ebp
  800a85:	89 e5                	mov    %esp,%ebp
  800a87:	56                   	push   %esi
  800a88:	53                   	push   %ebx
  800a89:	83 ec 1c             	sub    $0x1c,%esp
  800a8c:	8b 75 08             	mov    0x8(%ebp),%esi
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  800a8f:	56                   	push   %esi
  800a90:	e8 bf 0b 00 00       	call   801654 <strlen>
  800a95:	83 c4 10             	add    $0x10,%esp
  800a98:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  800a9d:	7f 65                	jg     800b04 <open+0x80>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800a9f:	83 ec 0c             	sub    $0xc,%esp
  800aa2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800aa5:	50                   	push   %eax
  800aa6:	e8 e1 f8 ff ff       	call   80038c <fd_alloc>
  800aab:	89 c3                	mov    %eax,%ebx
  800aad:	83 c4 10             	add    $0x10,%esp
  800ab0:	85 c0                	test   %eax,%eax
  800ab2:	78 55                	js     800b09 <open+0x85>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  800ab4:	83 ec 08             	sub    $0x8,%esp
  800ab7:	56                   	push   %esi
  800ab8:	68 00 50 80 00       	push   $0x805000
  800abd:	e8 e4 0b 00 00       	call   8016a6 <strcpy>
	fsipcbuf.open.req_omode = mode;
  800ac2:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ac5:	a3 00 54 80 00       	mov    %eax,0x805400



	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  800aca:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800acd:	b8 01 00 00 00       	mov    $0x1,%eax
  800ad2:	e8 65 fe ff ff       	call   80093c <fsipc>
  800ad7:	89 c3                	mov    %eax,%ebx
  800ad9:	83 c4 10             	add    $0x10,%esp
  800adc:	85 c0                	test   %eax,%eax
  800ade:	79 12                	jns    800af2 <open+0x6e>
		fd_close(fd, 0);
  800ae0:	83 ec 08             	sub    $0x8,%esp
  800ae3:	6a 00                	push   $0x0
  800ae5:	ff 75 f4             	pushl  -0xc(%ebp)
  800ae8:	e8 ce f9 ff ff       	call   8004bb <fd_close>
		return r;
  800aed:	83 c4 10             	add    $0x10,%esp
  800af0:	eb 17                	jmp    800b09 <open+0x85>
	}

	return fd2num(fd);
  800af2:	83 ec 0c             	sub    $0xc,%esp
  800af5:	ff 75 f4             	pushl  -0xc(%ebp)
  800af8:	e8 67 f8 ff ff       	call   800364 <fd2num>
  800afd:	89 c3                	mov    %eax,%ebx
  800aff:	83 c4 10             	add    $0x10,%esp
  800b02:	eb 05                	jmp    800b09 <open+0x85>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  800b04:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  800b09:	89 d8                	mov    %ebx,%eax
  800b0b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800b0e:	5b                   	pop    %ebx
  800b0f:	5e                   	pop    %esi
  800b10:	c9                   	leave  
  800b11:	c3                   	ret    
	...

00800b14 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  800b14:	55                   	push   %ebp
  800b15:	89 e5                	mov    %esp,%ebp
  800b17:	56                   	push   %esi
  800b18:	53                   	push   %ebx
  800b19:	8b 75 0c             	mov    0xc(%ebp),%esi
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  800b1c:	83 ec 0c             	sub    $0xc,%esp
  800b1f:	ff 75 08             	pushl  0x8(%ebp)
  800b22:	e8 4d f8 ff ff       	call   800374 <fd2data>
  800b27:	89 c3                	mov    %eax,%ebx
	strcpy(stat->st_name, "<pipe>");
  800b29:	83 c4 08             	add    $0x8,%esp
  800b2c:	68 db 1e 80 00       	push   $0x801edb
  800b31:	56                   	push   %esi
  800b32:	e8 6f 0b 00 00       	call   8016a6 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  800b37:	8b 43 04             	mov    0x4(%ebx),%eax
  800b3a:	2b 03                	sub    (%ebx),%eax
  800b3c:	89 86 80 00 00 00    	mov    %eax,0x80(%esi)
	stat->st_isdir = 0;
  800b42:	c7 86 84 00 00 00 00 	movl   $0x0,0x84(%esi)
  800b49:	00 00 00 
	stat->st_dev = &devpipe;
  800b4c:	c7 86 88 00 00 00 20 	movl   $0x803020,0x88(%esi)
  800b53:	30 80 00 
	return 0;
}
  800b56:	b8 00 00 00 00       	mov    $0x0,%eax
  800b5b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800b5e:	5b                   	pop    %ebx
  800b5f:	5e                   	pop    %esi
  800b60:	c9                   	leave  
  800b61:	c3                   	ret    

00800b62 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  800b62:	55                   	push   %ebp
  800b63:	89 e5                	mov    %esp,%ebp
  800b65:	53                   	push   %ebx
  800b66:	83 ec 0c             	sub    $0xc,%esp
  800b69:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  800b6c:	53                   	push   %ebx
  800b6d:	6a 00                	push   $0x0
  800b6f:	e8 8e f6 ff ff       	call   800202 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  800b74:	89 1c 24             	mov    %ebx,(%esp)
  800b77:	e8 f8 f7 ff ff       	call   800374 <fd2data>
  800b7c:	83 c4 08             	add    $0x8,%esp
  800b7f:	50                   	push   %eax
  800b80:	6a 00                	push   $0x0
  800b82:	e8 7b f6 ff ff       	call   800202 <sys_page_unmap>
}
  800b87:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800b8a:	c9                   	leave  
  800b8b:	c3                   	ret    

00800b8c <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  800b8c:	55                   	push   %ebp
  800b8d:	89 e5                	mov    %esp,%ebp
  800b8f:	57                   	push   %edi
  800b90:	56                   	push   %esi
  800b91:	53                   	push   %ebx
  800b92:	83 ec 1c             	sub    $0x1c,%esp
  800b95:	89 c7                	mov    %eax,%edi
  800b97:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  800b9a:	a1 04 40 80 00       	mov    0x804004,%eax
  800b9f:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  800ba2:	83 ec 0c             	sub    $0xc,%esp
  800ba5:	57                   	push   %edi
  800ba6:	e8 91 0f 00 00       	call   801b3c <pageref>
  800bab:	89 c6                	mov    %eax,%esi
  800bad:	83 c4 04             	add    $0x4,%esp
  800bb0:	ff 75 e4             	pushl  -0x1c(%ebp)
  800bb3:	e8 84 0f 00 00       	call   801b3c <pageref>
  800bb8:	83 c4 10             	add    $0x10,%esp
  800bbb:	39 c6                	cmp    %eax,%esi
  800bbd:	0f 94 c0             	sete   %al
  800bc0:	0f b6 c0             	movzbl %al,%eax
		nn = thisenv->env_runs;
  800bc3:	8b 15 04 40 80 00    	mov    0x804004,%edx
  800bc9:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  800bcc:	39 cb                	cmp    %ecx,%ebx
  800bce:	75 08                	jne    800bd8 <_pipeisclosed+0x4c>
			return ret;
		if (n != nn && ret == 1)
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
	}
}
  800bd0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bd3:	5b                   	pop    %ebx
  800bd4:	5e                   	pop    %esi
  800bd5:	5f                   	pop    %edi
  800bd6:	c9                   	leave  
  800bd7:	c3                   	ret    
		n = thisenv->env_runs;
		ret = pageref(fd) == pageref(p);
		nn = thisenv->env_runs;
		if (n == nn)
			return ret;
		if (n != nn && ret == 1)
  800bd8:	83 f8 01             	cmp    $0x1,%eax
  800bdb:	75 bd                	jne    800b9a <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  800bdd:	8b 42 58             	mov    0x58(%edx),%eax
  800be0:	6a 01                	push   $0x1
  800be2:	50                   	push   %eax
  800be3:	53                   	push   %ebx
  800be4:	68 e2 1e 80 00       	push   $0x801ee2
  800be9:	e8 02 05 00 00       	call   8010f0 <cprintf>
  800bee:	83 c4 10             	add    $0x10,%esp
  800bf1:	eb a7                	jmp    800b9a <_pipeisclosed+0xe>

00800bf3 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  800bf3:	55                   	push   %ebp
  800bf4:	89 e5                	mov    %esp,%ebp
  800bf6:	57                   	push   %edi
  800bf7:	56                   	push   %esi
  800bf8:	53                   	push   %ebx
  800bf9:	83 ec 28             	sub    $0x28,%esp
  800bfc:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  800bff:	56                   	push   %esi
  800c00:	e8 6f f7 ff ff       	call   800374 <fd2data>
  800c05:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800c07:	83 c4 10             	add    $0x10,%esp
  800c0a:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800c0e:	75 4a                	jne    800c5a <devpipe_write+0x67>
  800c10:	bf 00 00 00 00       	mov    $0x0,%edi
  800c15:	eb 56                	jmp    800c6d <devpipe_write+0x7a>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  800c17:	89 da                	mov    %ebx,%edx
  800c19:	89 f0                	mov    %esi,%eax
  800c1b:	e8 6c ff ff ff       	call   800b8c <_pipeisclosed>
  800c20:	85 c0                	test   %eax,%eax
  800c22:	75 4d                	jne    800c71 <devpipe_write+0x7e>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  800c24:	e8 68 f5 ff ff       	call   800191 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  800c29:	8b 43 04             	mov    0x4(%ebx),%eax
  800c2c:	8b 13                	mov    (%ebx),%edx
  800c2e:	83 c2 20             	add    $0x20,%edx
  800c31:	39 d0                	cmp    %edx,%eax
  800c33:	73 e2                	jae    800c17 <devpipe_write+0x24>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  800c35:	89 c2                	mov    %eax,%edx
  800c37:	81 e2 1f 00 00 80    	and    $0x8000001f,%edx
  800c3d:	79 05                	jns    800c44 <devpipe_write+0x51>
  800c3f:	4a                   	dec    %edx
  800c40:	83 ca e0             	or     $0xffffffe0,%edx
  800c43:	42                   	inc    %edx
  800c44:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c47:	8a 0c 39             	mov    (%ecx,%edi,1),%cl
  800c4a:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  800c4e:	40                   	inc    %eax
  800c4f:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800c52:	47                   	inc    %edi
  800c53:	39 7d 10             	cmp    %edi,0x10(%ebp)
  800c56:	77 07                	ja     800c5f <devpipe_write+0x6c>
  800c58:	eb 13                	jmp    800c6d <devpipe_write+0x7a>
  800c5a:	bf 00 00 00 00       	mov    $0x0,%edi
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  800c5f:	8b 43 04             	mov    0x4(%ebx),%eax
  800c62:	8b 13                	mov    (%ebx),%edx
  800c64:	83 c2 20             	add    $0x20,%edx
  800c67:	39 d0                	cmp    %edx,%eax
  800c69:	73 ac                	jae    800c17 <devpipe_write+0x24>
  800c6b:	eb c8                	jmp    800c35 <devpipe_write+0x42>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  800c6d:	89 f8                	mov    %edi,%eax
  800c6f:	eb 05                	jmp    800c76 <devpipe_write+0x83>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  800c71:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  800c76:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c79:	5b                   	pop    %ebx
  800c7a:	5e                   	pop    %esi
  800c7b:	5f                   	pop    %edi
  800c7c:	c9                   	leave  
  800c7d:	c3                   	ret    

00800c7e <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  800c7e:	55                   	push   %ebp
  800c7f:	89 e5                	mov    %esp,%ebp
  800c81:	57                   	push   %edi
  800c82:	56                   	push   %esi
  800c83:	53                   	push   %ebx
  800c84:	83 ec 18             	sub    $0x18,%esp
  800c87:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  800c8a:	57                   	push   %edi
  800c8b:	e8 e4 f6 ff ff       	call   800374 <fd2data>
  800c90:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800c92:	83 c4 10             	add    $0x10,%esp
  800c95:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800c99:	75 44                	jne    800cdf <devpipe_read+0x61>
  800c9b:	be 00 00 00 00       	mov    $0x0,%esi
  800ca0:	eb 4f                	jmp    800cf1 <devpipe_read+0x73>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
				return i;
  800ca2:	89 f0                	mov    %esi,%eax
  800ca4:	eb 54                	jmp    800cfa <devpipe_read+0x7c>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  800ca6:	89 da                	mov    %ebx,%edx
  800ca8:	89 f8                	mov    %edi,%eax
  800caa:	e8 dd fe ff ff       	call   800b8c <_pipeisclosed>
  800caf:	85 c0                	test   %eax,%eax
  800cb1:	75 42                	jne    800cf5 <devpipe_read+0x77>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  800cb3:	e8 d9 f4 ff ff       	call   800191 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  800cb8:	8b 03                	mov    (%ebx),%eax
  800cba:	3b 43 04             	cmp    0x4(%ebx),%eax
  800cbd:	74 e7                	je     800ca6 <devpipe_read+0x28>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  800cbf:	25 1f 00 00 80       	and    $0x8000001f,%eax
  800cc4:	79 05                	jns    800ccb <devpipe_read+0x4d>
  800cc6:	48                   	dec    %eax
  800cc7:	83 c8 e0             	or     $0xffffffe0,%eax
  800cca:	40                   	inc    %eax
  800ccb:	8a 44 03 08          	mov    0x8(%ebx,%eax,1),%al
  800ccf:	8b 55 0c             	mov    0xc(%ebp),%edx
  800cd2:	88 04 32             	mov    %al,(%edx,%esi,1)
		p->p_rpos++;
  800cd5:	ff 03                	incl   (%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800cd7:	46                   	inc    %esi
  800cd8:	39 75 10             	cmp    %esi,0x10(%ebp)
  800cdb:	77 07                	ja     800ce4 <devpipe_read+0x66>
  800cdd:	eb 12                	jmp    800cf1 <devpipe_read+0x73>
  800cdf:	be 00 00 00 00       	mov    $0x0,%esi
		while (p->p_rpos == p->p_wpos) {
  800ce4:	8b 03                	mov    (%ebx),%eax
  800ce6:	3b 43 04             	cmp    0x4(%ebx),%eax
  800ce9:	75 d4                	jne    800cbf <devpipe_read+0x41>
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  800ceb:	85 f6                	test   %esi,%esi
  800ced:	75 b3                	jne    800ca2 <devpipe_read+0x24>
  800cef:	eb b5                	jmp    800ca6 <devpipe_read+0x28>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  800cf1:	89 f0                	mov    %esi,%eax
  800cf3:	eb 05                	jmp    800cfa <devpipe_read+0x7c>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  800cf5:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  800cfa:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cfd:	5b                   	pop    %ebx
  800cfe:	5e                   	pop    %esi
  800cff:	5f                   	pop    %edi
  800d00:	c9                   	leave  
  800d01:	c3                   	ret    

00800d02 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  800d02:	55                   	push   %ebp
  800d03:	89 e5                	mov    %esp,%ebp
  800d05:	57                   	push   %edi
  800d06:	56                   	push   %esi
  800d07:	53                   	push   %ebx
  800d08:	83 ec 28             	sub    $0x28,%esp
  800d0b:	8b 7d 08             	mov    0x8(%ebp),%edi
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  800d0e:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800d11:	50                   	push   %eax
  800d12:	e8 75 f6 ff ff       	call   80038c <fd_alloc>
  800d17:	89 c3                	mov    %eax,%ebx
  800d19:	83 c4 10             	add    $0x10,%esp
  800d1c:	85 c0                	test   %eax,%eax
  800d1e:	0f 88 24 01 00 00    	js     800e48 <pipe+0x146>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800d24:	83 ec 04             	sub    $0x4,%esp
  800d27:	68 07 04 00 00       	push   $0x407
  800d2c:	ff 75 e4             	pushl  -0x1c(%ebp)
  800d2f:	6a 00                	push   $0x0
  800d31:	e8 82 f4 ff ff       	call   8001b8 <sys_page_alloc>
  800d36:	89 c3                	mov    %eax,%ebx
  800d38:	83 c4 10             	add    $0x10,%esp
  800d3b:	85 c0                	test   %eax,%eax
  800d3d:	0f 88 05 01 00 00    	js     800e48 <pipe+0x146>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  800d43:	83 ec 0c             	sub    $0xc,%esp
  800d46:	8d 45 e0             	lea    -0x20(%ebp),%eax
  800d49:	50                   	push   %eax
  800d4a:	e8 3d f6 ff ff       	call   80038c <fd_alloc>
  800d4f:	89 c3                	mov    %eax,%ebx
  800d51:	83 c4 10             	add    $0x10,%esp
  800d54:	85 c0                	test   %eax,%eax
  800d56:	0f 88 dc 00 00 00    	js     800e38 <pipe+0x136>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800d5c:	83 ec 04             	sub    $0x4,%esp
  800d5f:	68 07 04 00 00       	push   $0x407
  800d64:	ff 75 e0             	pushl  -0x20(%ebp)
  800d67:	6a 00                	push   $0x0
  800d69:	e8 4a f4 ff ff       	call   8001b8 <sys_page_alloc>
  800d6e:	89 c3                	mov    %eax,%ebx
  800d70:	83 c4 10             	add    $0x10,%esp
  800d73:	85 c0                	test   %eax,%eax
  800d75:	0f 88 bd 00 00 00    	js     800e38 <pipe+0x136>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  800d7b:	83 ec 0c             	sub    $0xc,%esp
  800d7e:	ff 75 e4             	pushl  -0x1c(%ebp)
  800d81:	e8 ee f5 ff ff       	call   800374 <fd2data>
  800d86:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800d88:	83 c4 0c             	add    $0xc,%esp
  800d8b:	68 07 04 00 00       	push   $0x407
  800d90:	50                   	push   %eax
  800d91:	6a 00                	push   $0x0
  800d93:	e8 20 f4 ff ff       	call   8001b8 <sys_page_alloc>
  800d98:	89 c3                	mov    %eax,%ebx
  800d9a:	83 c4 10             	add    $0x10,%esp
  800d9d:	85 c0                	test   %eax,%eax
  800d9f:	0f 88 83 00 00 00    	js     800e28 <pipe+0x126>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800da5:	83 ec 0c             	sub    $0xc,%esp
  800da8:	ff 75 e0             	pushl  -0x20(%ebp)
  800dab:	e8 c4 f5 ff ff       	call   800374 <fd2data>
  800db0:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  800db7:	50                   	push   %eax
  800db8:	6a 00                	push   $0x0
  800dba:	56                   	push   %esi
  800dbb:	6a 00                	push   $0x0
  800dbd:	e8 1a f4 ff ff       	call   8001dc <sys_page_map>
  800dc2:	89 c3                	mov    %eax,%ebx
  800dc4:	83 c4 20             	add    $0x20,%esp
  800dc7:	85 c0                	test   %eax,%eax
  800dc9:	78 4f                	js     800e1a <pipe+0x118>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  800dcb:	8b 15 20 30 80 00    	mov    0x803020,%edx
  800dd1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800dd4:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  800dd6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800dd9:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  800de0:	8b 15 20 30 80 00    	mov    0x803020,%edx
  800de6:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800de9:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  800deb:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800dee:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  800df5:	83 ec 0c             	sub    $0xc,%esp
  800df8:	ff 75 e4             	pushl  -0x1c(%ebp)
  800dfb:	e8 64 f5 ff ff       	call   800364 <fd2num>
  800e00:	89 07                	mov    %eax,(%edi)
	pfd[1] = fd2num(fd1);
  800e02:	83 c4 04             	add    $0x4,%esp
  800e05:	ff 75 e0             	pushl  -0x20(%ebp)
  800e08:	e8 57 f5 ff ff       	call   800364 <fd2num>
  800e0d:	89 47 04             	mov    %eax,0x4(%edi)
	return 0;
  800e10:	83 c4 10             	add    $0x10,%esp
  800e13:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e18:	eb 2e                	jmp    800e48 <pipe+0x146>

    err3:
	sys_page_unmap(0, va);
  800e1a:	83 ec 08             	sub    $0x8,%esp
  800e1d:	56                   	push   %esi
  800e1e:	6a 00                	push   $0x0
  800e20:	e8 dd f3 ff ff       	call   800202 <sys_page_unmap>
  800e25:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  800e28:	83 ec 08             	sub    $0x8,%esp
  800e2b:	ff 75 e0             	pushl  -0x20(%ebp)
  800e2e:	6a 00                	push   $0x0
  800e30:	e8 cd f3 ff ff       	call   800202 <sys_page_unmap>
  800e35:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  800e38:	83 ec 08             	sub    $0x8,%esp
  800e3b:	ff 75 e4             	pushl  -0x1c(%ebp)
  800e3e:	6a 00                	push   $0x0
  800e40:	e8 bd f3 ff ff       	call   800202 <sys_page_unmap>
  800e45:	83 c4 10             	add    $0x10,%esp
    err:
	return r;
}
  800e48:	89 d8                	mov    %ebx,%eax
  800e4a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e4d:	5b                   	pop    %ebx
  800e4e:	5e                   	pop    %esi
  800e4f:	5f                   	pop    %edi
  800e50:	c9                   	leave  
  800e51:	c3                   	ret    

00800e52 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  800e52:	55                   	push   %ebp
  800e53:	89 e5                	mov    %esp,%ebp
  800e55:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800e58:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800e5b:	50                   	push   %eax
  800e5c:	ff 75 08             	pushl  0x8(%ebp)
  800e5f:	e8 9b f5 ff ff       	call   8003ff <fd_lookup>
  800e64:	83 c4 10             	add    $0x10,%esp
  800e67:	85 c0                	test   %eax,%eax
  800e69:	78 18                	js     800e83 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  800e6b:	83 ec 0c             	sub    $0xc,%esp
  800e6e:	ff 75 f4             	pushl  -0xc(%ebp)
  800e71:	e8 fe f4 ff ff       	call   800374 <fd2data>
	return _pipeisclosed(fd, p);
  800e76:	89 c2                	mov    %eax,%edx
  800e78:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800e7b:	e8 0c fd ff ff       	call   800b8c <_pipeisclosed>
  800e80:	83 c4 10             	add    $0x10,%esp
}
  800e83:	c9                   	leave  
  800e84:	c3                   	ret    
  800e85:	00 00                	add    %al,(%eax)
	...

00800e88 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  800e88:	55                   	push   %ebp
  800e89:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  800e8b:	b8 00 00 00 00       	mov    $0x0,%eax
  800e90:	c9                   	leave  
  800e91:	c3                   	ret    

00800e92 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  800e92:	55                   	push   %ebp
  800e93:	89 e5                	mov    %esp,%ebp
  800e95:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  800e98:	68 fa 1e 80 00       	push   $0x801efa
  800e9d:	ff 75 0c             	pushl  0xc(%ebp)
  800ea0:	e8 01 08 00 00       	call   8016a6 <strcpy>
	return 0;
}
  800ea5:	b8 00 00 00 00       	mov    $0x0,%eax
  800eaa:	c9                   	leave  
  800eab:	c3                   	ret    

00800eac <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  800eac:	55                   	push   %ebp
  800ead:	89 e5                	mov    %esp,%ebp
  800eaf:	57                   	push   %edi
  800eb0:	56                   	push   %esi
  800eb1:	53                   	push   %ebx
  800eb2:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800eb8:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800ebc:	74 45                	je     800f03 <devcons_write+0x57>
  800ebe:	b8 00 00 00 00       	mov    $0x0,%eax
  800ec3:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  800ec8:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  800ece:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800ed1:	29 c3                	sub    %eax,%ebx
		if (m > sizeof(buf) - 1)
  800ed3:	83 fb 7f             	cmp    $0x7f,%ebx
  800ed6:	76 05                	jbe    800edd <devcons_write+0x31>
			m = sizeof(buf) - 1;
  800ed8:	bb 7f 00 00 00       	mov    $0x7f,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  800edd:	83 ec 04             	sub    $0x4,%esp
  800ee0:	53                   	push   %ebx
  800ee1:	03 45 0c             	add    0xc(%ebp),%eax
  800ee4:	50                   	push   %eax
  800ee5:	57                   	push   %edi
  800ee6:	e8 7c 09 00 00       	call   801867 <memmove>
		sys_cputs(buf, m);
  800eeb:	83 c4 08             	add    $0x8,%esp
  800eee:	53                   	push   %ebx
  800eef:	57                   	push   %edi
  800ef0:	e8 0c f2 ff ff       	call   800101 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800ef5:	01 de                	add    %ebx,%esi
  800ef7:	89 f0                	mov    %esi,%eax
  800ef9:	83 c4 10             	add    $0x10,%esp
  800efc:	3b 75 10             	cmp    0x10(%ebp),%esi
  800eff:	72 cd                	jb     800ece <devcons_write+0x22>
  800f01:	eb 05                	jmp    800f08 <devcons_write+0x5c>
  800f03:	be 00 00 00 00       	mov    $0x0,%esi
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  800f08:	89 f0                	mov    %esi,%eax
  800f0a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f0d:	5b                   	pop    %ebx
  800f0e:	5e                   	pop    %esi
  800f0f:	5f                   	pop    %edi
  800f10:	c9                   	leave  
  800f11:	c3                   	ret    

00800f12 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  800f12:	55                   	push   %ebp
  800f13:	89 e5                	mov    %esp,%ebp
  800f15:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
  800f18:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800f1c:	75 07                	jne    800f25 <devcons_read+0x13>
  800f1e:	eb 25                	jmp    800f45 <devcons_read+0x33>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  800f20:	e8 6c f2 ff ff       	call   800191 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  800f25:	e8 fd f1 ff ff       	call   800127 <sys_cgetc>
  800f2a:	85 c0                	test   %eax,%eax
  800f2c:	74 f2                	je     800f20 <devcons_read+0xe>
  800f2e:	89 c2                	mov    %eax,%edx
		sys_yield();
	if (c < 0)
  800f30:	85 c0                	test   %eax,%eax
  800f32:	78 1d                	js     800f51 <devcons_read+0x3f>
		return c;
	if (c == 0x04)	// ctl-d is eof
  800f34:	83 f8 04             	cmp    $0x4,%eax
  800f37:	74 13                	je     800f4c <devcons_read+0x3a>
		return 0;
	*(char*)vbuf = c;
  800f39:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f3c:	88 10                	mov    %dl,(%eax)
	return 1;
  800f3e:	b8 01 00 00 00       	mov    $0x1,%eax
  800f43:	eb 0c                	jmp    800f51 <devcons_read+0x3f>
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
		return 0;
  800f45:	b8 00 00 00 00       	mov    $0x0,%eax
  800f4a:	eb 05                	jmp    800f51 <devcons_read+0x3f>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  800f4c:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  800f51:	c9                   	leave  
  800f52:	c3                   	ret    

00800f53 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  800f53:	55                   	push   %ebp
  800f54:	89 e5                	mov    %esp,%ebp
  800f56:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  800f59:	8b 45 08             	mov    0x8(%ebp),%eax
  800f5c:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  800f5f:	6a 01                	push   $0x1
  800f61:	8d 45 f7             	lea    -0x9(%ebp),%eax
  800f64:	50                   	push   %eax
  800f65:	e8 97 f1 ff ff       	call   800101 <sys_cputs>
  800f6a:	83 c4 10             	add    $0x10,%esp
}
  800f6d:	c9                   	leave  
  800f6e:	c3                   	ret    

00800f6f <getchar>:

int
getchar(void)
{
  800f6f:	55                   	push   %ebp
  800f70:	89 e5                	mov    %esp,%ebp
  800f72:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  800f75:	6a 01                	push   $0x1
  800f77:	8d 45 f7             	lea    -0x9(%ebp),%eax
  800f7a:	50                   	push   %eax
  800f7b:	6a 00                	push   $0x0
  800f7d:	e8 fe f6 ff ff       	call   800680 <read>
	if (r < 0)
  800f82:	83 c4 10             	add    $0x10,%esp
  800f85:	85 c0                	test   %eax,%eax
  800f87:	78 0f                	js     800f98 <getchar+0x29>
		return r;
	if (r < 1)
  800f89:	85 c0                	test   %eax,%eax
  800f8b:	7e 06                	jle    800f93 <getchar+0x24>
		return -E_EOF;
	return c;
  800f8d:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  800f91:	eb 05                	jmp    800f98 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  800f93:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  800f98:	c9                   	leave  
  800f99:	c3                   	ret    

00800f9a <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  800f9a:	55                   	push   %ebp
  800f9b:	89 e5                	mov    %esp,%ebp
  800f9d:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800fa0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800fa3:	50                   	push   %eax
  800fa4:	ff 75 08             	pushl  0x8(%ebp)
  800fa7:	e8 53 f4 ff ff       	call   8003ff <fd_lookup>
  800fac:	83 c4 10             	add    $0x10,%esp
  800faf:	85 c0                	test   %eax,%eax
  800fb1:	78 11                	js     800fc4 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  800fb3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800fb6:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  800fbc:	39 10                	cmp    %edx,(%eax)
  800fbe:	0f 94 c0             	sete   %al
  800fc1:	0f b6 c0             	movzbl %al,%eax
}
  800fc4:	c9                   	leave  
  800fc5:	c3                   	ret    

00800fc6 <opencons>:

int
opencons(void)
{
  800fc6:	55                   	push   %ebp
  800fc7:	89 e5                	mov    %esp,%ebp
  800fc9:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  800fcc:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800fcf:	50                   	push   %eax
  800fd0:	e8 b7 f3 ff ff       	call   80038c <fd_alloc>
  800fd5:	83 c4 10             	add    $0x10,%esp
  800fd8:	85 c0                	test   %eax,%eax
  800fda:	78 3a                	js     801016 <opencons+0x50>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  800fdc:	83 ec 04             	sub    $0x4,%esp
  800fdf:	68 07 04 00 00       	push   $0x407
  800fe4:	ff 75 f4             	pushl  -0xc(%ebp)
  800fe7:	6a 00                	push   $0x0
  800fe9:	e8 ca f1 ff ff       	call   8001b8 <sys_page_alloc>
  800fee:	83 c4 10             	add    $0x10,%esp
  800ff1:	85 c0                	test   %eax,%eax
  800ff3:	78 21                	js     801016 <opencons+0x50>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  800ff5:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  800ffb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800ffe:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801000:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801003:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  80100a:	83 ec 0c             	sub    $0xc,%esp
  80100d:	50                   	push   %eax
  80100e:	e8 51 f3 ff ff       	call   800364 <fd2num>
  801013:	83 c4 10             	add    $0x10,%esp
}
  801016:	c9                   	leave  
  801017:	c3                   	ret    

00801018 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801018:	55                   	push   %ebp
  801019:	89 e5                	mov    %esp,%ebp
  80101b:	56                   	push   %esi
  80101c:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  80101d:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801020:	8b 1d 00 30 80 00    	mov    0x803000,%ebx
  801026:	e8 42 f1 ff ff       	call   80016d <sys_getenvid>
  80102b:	83 ec 0c             	sub    $0xc,%esp
  80102e:	ff 75 0c             	pushl  0xc(%ebp)
  801031:	ff 75 08             	pushl  0x8(%ebp)
  801034:	53                   	push   %ebx
  801035:	50                   	push   %eax
  801036:	68 08 1f 80 00       	push   $0x801f08
  80103b:	e8 b0 00 00 00       	call   8010f0 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801040:	83 c4 18             	add    $0x18,%esp
  801043:	56                   	push   %esi
  801044:	ff 75 10             	pushl  0x10(%ebp)
  801047:	e8 53 00 00 00       	call   80109f <vcprintf>
	cprintf("\n");
  80104c:	c7 04 24 f3 1e 80 00 	movl   $0x801ef3,(%esp)
  801053:	e8 98 00 00 00       	call   8010f0 <cprintf>
  801058:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80105b:	cc                   	int3   
  80105c:	eb fd                	jmp    80105b <_panic+0x43>
	...

00801060 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  801060:	55                   	push   %ebp
  801061:	89 e5                	mov    %esp,%ebp
  801063:	53                   	push   %ebx
  801064:	83 ec 04             	sub    $0x4,%esp
  801067:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80106a:	8b 03                	mov    (%ebx),%eax
  80106c:	8b 55 08             	mov    0x8(%ebp),%edx
  80106f:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  801073:	40                   	inc    %eax
  801074:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  801076:	3d ff 00 00 00       	cmp    $0xff,%eax
  80107b:	75 1a                	jne    801097 <putch+0x37>
		sys_cputs(b->buf, b->idx);
  80107d:	83 ec 08             	sub    $0x8,%esp
  801080:	68 ff 00 00 00       	push   $0xff
  801085:	8d 43 08             	lea    0x8(%ebx),%eax
  801088:	50                   	push   %eax
  801089:	e8 73 f0 ff ff       	call   800101 <sys_cputs>
		b->idx = 0;
  80108e:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801094:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  801097:	ff 43 04             	incl   0x4(%ebx)
}
  80109a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80109d:	c9                   	leave  
  80109e:	c3                   	ret    

0080109f <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80109f:	55                   	push   %ebp
  8010a0:	89 e5                	mov    %esp,%ebp
  8010a2:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8010a8:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8010af:	00 00 00 
	b.cnt = 0;
  8010b2:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8010b9:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8010bc:	ff 75 0c             	pushl  0xc(%ebp)
  8010bf:	ff 75 08             	pushl  0x8(%ebp)
  8010c2:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8010c8:	50                   	push   %eax
  8010c9:	68 60 10 80 00       	push   $0x801060
  8010ce:	e8 82 01 00 00       	call   801255 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8010d3:	83 c4 08             	add    $0x8,%esp
  8010d6:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8010dc:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8010e2:	50                   	push   %eax
  8010e3:	e8 19 f0 ff ff       	call   800101 <sys_cputs>

	return b.cnt;
}
  8010e8:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8010ee:	c9                   	leave  
  8010ef:	c3                   	ret    

008010f0 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8010f0:	55                   	push   %ebp
  8010f1:	89 e5                	mov    %esp,%ebp
  8010f3:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8010f6:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8010f9:	50                   	push   %eax
  8010fa:	ff 75 08             	pushl  0x8(%ebp)
  8010fd:	e8 9d ff ff ff       	call   80109f <vcprintf>
	va_end(ap);

	return cnt;
}
  801102:	c9                   	leave  
  801103:	c3                   	ret    

00801104 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  801104:	55                   	push   %ebp
  801105:	89 e5                	mov    %esp,%ebp
  801107:	57                   	push   %edi
  801108:	56                   	push   %esi
  801109:	53                   	push   %ebx
  80110a:	83 ec 2c             	sub    $0x2c,%esp
  80110d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801110:	89 d6                	mov    %edx,%esi
  801112:	8b 45 08             	mov    0x8(%ebp),%eax
  801115:	8b 55 0c             	mov    0xc(%ebp),%edx
  801118:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80111b:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80111e:	8b 45 10             	mov    0x10(%ebp),%eax
  801121:	8b 5d 14             	mov    0x14(%ebp),%ebx
  801124:	8b 7d 18             	mov    0x18(%ebp),%edi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  801127:	89 45 d0             	mov    %eax,-0x30(%ebp)
  80112a:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  801131:	39 55 d4             	cmp    %edx,-0x2c(%ebp)
  801134:	72 0c                	jb     801142 <printnum+0x3e>
  801136:	3b 45 d8             	cmp    -0x28(%ebp),%eax
  801139:	76 07                	jbe    801142 <printnum+0x3e>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80113b:	4b                   	dec    %ebx
  80113c:	85 db                	test   %ebx,%ebx
  80113e:	7f 31                	jg     801171 <printnum+0x6d>
  801140:	eb 3f                	jmp    801181 <printnum+0x7d>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  801142:	83 ec 0c             	sub    $0xc,%esp
  801145:	57                   	push   %edi
  801146:	4b                   	dec    %ebx
  801147:	53                   	push   %ebx
  801148:	50                   	push   %eax
  801149:	83 ec 08             	sub    $0x8,%esp
  80114c:	ff 75 d4             	pushl  -0x2c(%ebp)
  80114f:	ff 75 d0             	pushl  -0x30(%ebp)
  801152:	ff 75 dc             	pushl  -0x24(%ebp)
  801155:	ff 75 d8             	pushl  -0x28(%ebp)
  801158:	e8 23 0a 00 00       	call   801b80 <__udivdi3>
  80115d:	83 c4 18             	add    $0x18,%esp
  801160:	52                   	push   %edx
  801161:	50                   	push   %eax
  801162:	89 f2                	mov    %esi,%edx
  801164:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801167:	e8 98 ff ff ff       	call   801104 <printnum>
  80116c:	83 c4 20             	add    $0x20,%esp
  80116f:	eb 10                	jmp    801181 <printnum+0x7d>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  801171:	83 ec 08             	sub    $0x8,%esp
  801174:	56                   	push   %esi
  801175:	57                   	push   %edi
  801176:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  801179:	4b                   	dec    %ebx
  80117a:	83 c4 10             	add    $0x10,%esp
  80117d:	85 db                	test   %ebx,%ebx
  80117f:	7f f0                	jg     801171 <printnum+0x6d>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  801181:	83 ec 08             	sub    $0x8,%esp
  801184:	56                   	push   %esi
  801185:	83 ec 04             	sub    $0x4,%esp
  801188:	ff 75 d4             	pushl  -0x2c(%ebp)
  80118b:	ff 75 d0             	pushl  -0x30(%ebp)
  80118e:	ff 75 dc             	pushl  -0x24(%ebp)
  801191:	ff 75 d8             	pushl  -0x28(%ebp)
  801194:	e8 03 0b 00 00       	call   801c9c <__umoddi3>
  801199:	83 c4 14             	add    $0x14,%esp
  80119c:	0f be 80 2b 1f 80 00 	movsbl 0x801f2b(%eax),%eax
  8011a3:	50                   	push   %eax
  8011a4:	ff 55 e4             	call   *-0x1c(%ebp)
  8011a7:	83 c4 10             	add    $0x10,%esp
}
  8011aa:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011ad:	5b                   	pop    %ebx
  8011ae:	5e                   	pop    %esi
  8011af:	5f                   	pop    %edi
  8011b0:	c9                   	leave  
  8011b1:	c3                   	ret    

008011b2 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8011b2:	55                   	push   %ebp
  8011b3:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8011b5:	83 fa 01             	cmp    $0x1,%edx
  8011b8:	7e 0e                	jle    8011c8 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8011ba:	8b 10                	mov    (%eax),%edx
  8011bc:	8d 4a 08             	lea    0x8(%edx),%ecx
  8011bf:	89 08                	mov    %ecx,(%eax)
  8011c1:	8b 02                	mov    (%edx),%eax
  8011c3:	8b 52 04             	mov    0x4(%edx),%edx
  8011c6:	eb 22                	jmp    8011ea <getuint+0x38>
	else if (lflag)
  8011c8:	85 d2                	test   %edx,%edx
  8011ca:	74 10                	je     8011dc <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8011cc:	8b 10                	mov    (%eax),%edx
  8011ce:	8d 4a 04             	lea    0x4(%edx),%ecx
  8011d1:	89 08                	mov    %ecx,(%eax)
  8011d3:	8b 02                	mov    (%edx),%eax
  8011d5:	ba 00 00 00 00       	mov    $0x0,%edx
  8011da:	eb 0e                	jmp    8011ea <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8011dc:	8b 10                	mov    (%eax),%edx
  8011de:	8d 4a 04             	lea    0x4(%edx),%ecx
  8011e1:	89 08                	mov    %ecx,(%eax)
  8011e3:	8b 02                	mov    (%edx),%eax
  8011e5:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8011ea:	c9                   	leave  
  8011eb:	c3                   	ret    

008011ec <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
  8011ec:	55                   	push   %ebp
  8011ed:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8011ef:	83 fa 01             	cmp    $0x1,%edx
  8011f2:	7e 0e                	jle    801202 <getint+0x16>
		return va_arg(*ap, long long);
  8011f4:	8b 10                	mov    (%eax),%edx
  8011f6:	8d 4a 08             	lea    0x8(%edx),%ecx
  8011f9:	89 08                	mov    %ecx,(%eax)
  8011fb:	8b 02                	mov    (%edx),%eax
  8011fd:	8b 52 04             	mov    0x4(%edx),%edx
  801200:	eb 1a                	jmp    80121c <getint+0x30>
	else if (lflag)
  801202:	85 d2                	test   %edx,%edx
  801204:	74 0c                	je     801212 <getint+0x26>
		return va_arg(*ap, long);
  801206:	8b 10                	mov    (%eax),%edx
  801208:	8d 4a 04             	lea    0x4(%edx),%ecx
  80120b:	89 08                	mov    %ecx,(%eax)
  80120d:	8b 02                	mov    (%edx),%eax
  80120f:	99                   	cltd   
  801210:	eb 0a                	jmp    80121c <getint+0x30>
	else
		return va_arg(*ap, int);
  801212:	8b 10                	mov    (%eax),%edx
  801214:	8d 4a 04             	lea    0x4(%edx),%ecx
  801217:	89 08                	mov    %ecx,(%eax)
  801219:	8b 02                	mov    (%edx),%eax
  80121b:	99                   	cltd   
}
  80121c:	c9                   	leave  
  80121d:	c3                   	ret    

0080121e <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80121e:	55                   	push   %ebp
  80121f:	89 e5                	mov    %esp,%ebp
  801221:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  801224:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  801227:	8b 10                	mov    (%eax),%edx
  801229:	3b 50 04             	cmp    0x4(%eax),%edx
  80122c:	73 08                	jae    801236 <sprintputch+0x18>
		*b->buf++ = ch;
  80122e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801231:	88 0a                	mov    %cl,(%edx)
  801233:	42                   	inc    %edx
  801234:	89 10                	mov    %edx,(%eax)
}
  801236:	c9                   	leave  
  801237:	c3                   	ret    

00801238 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  801238:	55                   	push   %ebp
  801239:	89 e5                	mov    %esp,%ebp
  80123b:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  80123e:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  801241:	50                   	push   %eax
  801242:	ff 75 10             	pushl  0x10(%ebp)
  801245:	ff 75 0c             	pushl  0xc(%ebp)
  801248:	ff 75 08             	pushl  0x8(%ebp)
  80124b:	e8 05 00 00 00       	call   801255 <vprintfmt>
	va_end(ap);
  801250:	83 c4 10             	add    $0x10,%esp
}
  801253:	c9                   	leave  
  801254:	c3                   	ret    

00801255 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  801255:	55                   	push   %ebp
  801256:	89 e5                	mov    %esp,%ebp
  801258:	57                   	push   %edi
  801259:	56                   	push   %esi
  80125a:	53                   	push   %ebx
  80125b:	83 ec 2c             	sub    $0x2c,%esp
  80125e:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801261:	8b 75 10             	mov    0x10(%ebp),%esi
  801264:	eb 13                	jmp    801279 <vprintfmt+0x24>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  801266:	85 c0                	test   %eax,%eax
  801268:	0f 84 6d 03 00 00    	je     8015db <vprintfmt+0x386>
				return;
			putch(ch, putdat);
  80126e:	83 ec 08             	sub    $0x8,%esp
  801271:	57                   	push   %edi
  801272:	50                   	push   %eax
  801273:	ff 55 08             	call   *0x8(%ebp)
  801276:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  801279:	0f b6 06             	movzbl (%esi),%eax
  80127c:	46                   	inc    %esi
  80127d:	83 f8 25             	cmp    $0x25,%eax
  801280:	75 e4                	jne    801266 <vprintfmt+0x11>
  801282:	c6 45 dc 20          	movb   $0x20,-0x24(%ebp)
  801286:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  80128d:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
  801294:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  80129b:	b9 00 00 00 00       	mov    $0x0,%ecx
  8012a0:	eb 28                	jmp    8012ca <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8012a2:	89 de                	mov    %ebx,%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  8012a4:	c6 45 dc 2d          	movb   $0x2d,-0x24(%ebp)
  8012a8:	eb 20                	jmp    8012ca <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8012aa:	89 de                	mov    %ebx,%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8012ac:	c6 45 dc 30          	movb   $0x30,-0x24(%ebp)
  8012b0:	eb 18                	jmp    8012ca <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8012b2:	89 de                	mov    %ebx,%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  8012b4:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  8012bb:	eb 0d                	jmp    8012ca <vprintfmt+0x75>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  8012bd:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8012c0:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8012c3:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8012ca:	8a 06                	mov    (%esi),%al
  8012cc:	0f b6 d0             	movzbl %al,%edx
  8012cf:	8d 5e 01             	lea    0x1(%esi),%ebx
  8012d2:	83 e8 23             	sub    $0x23,%eax
  8012d5:	3c 55                	cmp    $0x55,%al
  8012d7:	0f 87 e0 02 00 00    	ja     8015bd <vprintfmt+0x368>
  8012dd:	0f b6 c0             	movzbl %al,%eax
  8012e0:	ff 24 85 60 20 80 00 	jmp    *0x802060(,%eax,4)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8012e7:	83 ea 30             	sub    $0x30,%edx
  8012ea:	89 55 d4             	mov    %edx,-0x2c(%ebp)
				ch = *fmt;
  8012ed:	0f be 03             	movsbl (%ebx),%eax
				if (ch < '0' || ch > '9')
  8012f0:	8d 50 d0             	lea    -0x30(%eax),%edx
  8012f3:	83 fa 09             	cmp    $0x9,%edx
  8012f6:	77 44                	ja     80133c <vprintfmt+0xe7>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8012f8:	89 de                	mov    %ebx,%esi
  8012fa:	8b 55 d4             	mov    -0x2c(%ebp),%edx
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8012fd:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
  8012fe:	8d 14 92             	lea    (%edx,%edx,4),%edx
  801301:	8d 54 50 d0          	lea    -0x30(%eax,%edx,2),%edx
				ch = *fmt;
  801305:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  801308:	8d 58 d0             	lea    -0x30(%eax),%ebx
  80130b:	83 fb 09             	cmp    $0x9,%ebx
  80130e:	76 ed                	jbe    8012fd <vprintfmt+0xa8>
  801310:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  801313:	eb 29                	jmp    80133e <vprintfmt+0xe9>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  801315:	8b 45 14             	mov    0x14(%ebp),%eax
  801318:	8d 50 04             	lea    0x4(%eax),%edx
  80131b:	89 55 14             	mov    %edx,0x14(%ebp)
  80131e:	8b 00                	mov    (%eax),%eax
  801320:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801323:	89 de                	mov    %ebx,%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  801325:	eb 17                	jmp    80133e <vprintfmt+0xe9>

		case '.':
			if (width < 0)
  801327:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80132b:	78 85                	js     8012b2 <vprintfmt+0x5d>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80132d:	89 de                	mov    %ebx,%esi
  80132f:	eb 99                	jmp    8012ca <vprintfmt+0x75>
  801331:	89 de                	mov    %ebx,%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  801333:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
			goto reswitch;
  80133a:	eb 8e                	jmp    8012ca <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80133c:	89 de                	mov    %ebx,%esi
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  80133e:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  801342:	79 86                	jns    8012ca <vprintfmt+0x75>
  801344:	e9 74 ff ff ff       	jmp    8012bd <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  801349:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80134a:	89 de                	mov    %ebx,%esi
  80134c:	e9 79 ff ff ff       	jmp    8012ca <vprintfmt+0x75>
  801351:	89 5d d8             	mov    %ebx,-0x28(%ebp)
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  801354:	8b 45 14             	mov    0x14(%ebp),%eax
  801357:	8d 50 04             	lea    0x4(%eax),%edx
  80135a:	89 55 14             	mov    %edx,0x14(%ebp)
  80135d:	83 ec 08             	sub    $0x8,%esp
  801360:	57                   	push   %edi
  801361:	ff 30                	pushl  (%eax)
  801363:	ff 55 08             	call   *0x8(%ebp)
			break;
  801366:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801369:	8b 75 d8             	mov    -0x28(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  80136c:	e9 08 ff ff ff       	jmp    801279 <vprintfmt+0x24>
  801371:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// error message
		case 'e':
			err = va_arg(ap, int);
  801374:	8b 45 14             	mov    0x14(%ebp),%eax
  801377:	8d 50 04             	lea    0x4(%eax),%edx
  80137a:	89 55 14             	mov    %edx,0x14(%ebp)
  80137d:	8b 00                	mov    (%eax),%eax
  80137f:	85 c0                	test   %eax,%eax
  801381:	79 02                	jns    801385 <vprintfmt+0x130>
  801383:	f7 d8                	neg    %eax
  801385:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  801387:	83 f8 0f             	cmp    $0xf,%eax
  80138a:	7f 0b                	jg     801397 <vprintfmt+0x142>
  80138c:	8b 04 85 c0 21 80 00 	mov    0x8021c0(,%eax,4),%eax
  801393:	85 c0                	test   %eax,%eax
  801395:	75 1a                	jne    8013b1 <vprintfmt+0x15c>
				printfmt(putch, putdat, "error %d", err);
  801397:	52                   	push   %edx
  801398:	68 43 1f 80 00       	push   $0x801f43
  80139d:	57                   	push   %edi
  80139e:	ff 75 08             	pushl  0x8(%ebp)
  8013a1:	e8 92 fe ff ff       	call   801238 <printfmt>
  8013a6:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8013a9:	8b 75 d8             	mov    -0x28(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8013ac:	e9 c8 fe ff ff       	jmp    801279 <vprintfmt+0x24>
			else
				printfmt(putch, putdat, "%s", p);
  8013b1:	50                   	push   %eax
  8013b2:	68 c1 1e 80 00       	push   $0x801ec1
  8013b7:	57                   	push   %edi
  8013b8:	ff 75 08             	pushl  0x8(%ebp)
  8013bb:	e8 78 fe ff ff       	call   801238 <printfmt>
  8013c0:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8013c3:	8b 75 d8             	mov    -0x28(%ebp),%esi
  8013c6:	e9 ae fe ff ff       	jmp    801279 <vprintfmt+0x24>
  8013cb:	89 5d d8             	mov    %ebx,-0x28(%ebp)
  8013ce:	89 de                	mov    %ebx,%esi
  8013d0:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  8013d3:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8013d6:	8b 45 14             	mov    0x14(%ebp),%eax
  8013d9:	8d 50 04             	lea    0x4(%eax),%edx
  8013dc:	89 55 14             	mov    %edx,0x14(%ebp)
  8013df:	8b 00                	mov    (%eax),%eax
  8013e1:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8013e4:	85 c0                	test   %eax,%eax
  8013e6:	75 07                	jne    8013ef <vprintfmt+0x19a>
				p = "(null)";
  8013e8:	c7 45 d0 3c 1f 80 00 	movl   $0x801f3c,-0x30(%ebp)
			if (width > 0 && padc != '-')
  8013ef:	85 db                	test   %ebx,%ebx
  8013f1:	7e 42                	jle    801435 <vprintfmt+0x1e0>
  8013f3:	80 7d dc 2d          	cmpb   $0x2d,-0x24(%ebp)
  8013f7:	74 3c                	je     801435 <vprintfmt+0x1e0>
				for (width -= strnlen(p, precision); width > 0; width--)
  8013f9:	83 ec 08             	sub    $0x8,%esp
  8013fc:	51                   	push   %ecx
  8013fd:	ff 75 d0             	pushl  -0x30(%ebp)
  801400:	e8 6f 02 00 00       	call   801674 <strnlen>
  801405:	29 c3                	sub    %eax,%ebx
  801407:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  80140a:	83 c4 10             	add    $0x10,%esp
  80140d:	85 db                	test   %ebx,%ebx
  80140f:	7e 24                	jle    801435 <vprintfmt+0x1e0>
					putch(padc, putdat);
  801411:	0f be 5d dc          	movsbl -0x24(%ebp),%ebx
  801415:	89 75 dc             	mov    %esi,-0x24(%ebp)
  801418:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  80141b:	83 ec 08             	sub    $0x8,%esp
  80141e:	57                   	push   %edi
  80141f:	53                   	push   %ebx
  801420:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  801423:	4e                   	dec    %esi
  801424:	83 c4 10             	add    $0x10,%esp
  801427:	85 f6                	test   %esi,%esi
  801429:	7f f0                	jg     80141b <vprintfmt+0x1c6>
  80142b:	8b 75 dc             	mov    -0x24(%ebp),%esi
  80142e:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  801435:	8b 55 d0             	mov    -0x30(%ebp),%edx
  801438:	0f be 02             	movsbl (%edx),%eax
  80143b:	85 c0                	test   %eax,%eax
  80143d:	75 47                	jne    801486 <vprintfmt+0x231>
  80143f:	eb 37                	jmp    801478 <vprintfmt+0x223>
				if (altflag && (ch < ' ' || ch > '~'))
  801441:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  801445:	74 16                	je     80145d <vprintfmt+0x208>
  801447:	8d 50 e0             	lea    -0x20(%eax),%edx
  80144a:	83 fa 5e             	cmp    $0x5e,%edx
  80144d:	76 0e                	jbe    80145d <vprintfmt+0x208>
					putch('?', putdat);
  80144f:	83 ec 08             	sub    $0x8,%esp
  801452:	57                   	push   %edi
  801453:	6a 3f                	push   $0x3f
  801455:	ff 55 08             	call   *0x8(%ebp)
  801458:	83 c4 10             	add    $0x10,%esp
  80145b:	eb 0b                	jmp    801468 <vprintfmt+0x213>
				else
					putch(ch, putdat);
  80145d:	83 ec 08             	sub    $0x8,%esp
  801460:	57                   	push   %edi
  801461:	50                   	push   %eax
  801462:	ff 55 08             	call   *0x8(%ebp)
  801465:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  801468:	ff 4d e4             	decl   -0x1c(%ebp)
  80146b:	0f be 03             	movsbl (%ebx),%eax
  80146e:	85 c0                	test   %eax,%eax
  801470:	74 03                	je     801475 <vprintfmt+0x220>
  801472:	43                   	inc    %ebx
  801473:	eb 1b                	jmp    801490 <vprintfmt+0x23b>
  801475:	8b 75 dc             	mov    -0x24(%ebp),%esi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  801478:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80147c:	7f 1e                	jg     80149c <vprintfmt+0x247>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80147e:	8b 75 d8             	mov    -0x28(%ebp),%esi
  801481:	e9 f3 fd ff ff       	jmp    801279 <vprintfmt+0x24>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  801486:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  801489:	43                   	inc    %ebx
  80148a:	89 75 dc             	mov    %esi,-0x24(%ebp)
  80148d:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  801490:	85 f6                	test   %esi,%esi
  801492:	78 ad                	js     801441 <vprintfmt+0x1ec>
  801494:	4e                   	dec    %esi
  801495:	79 aa                	jns    801441 <vprintfmt+0x1ec>
  801497:	8b 75 dc             	mov    -0x24(%ebp),%esi
  80149a:	eb dc                	jmp    801478 <vprintfmt+0x223>
  80149c:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80149f:	83 ec 08             	sub    $0x8,%esp
  8014a2:	57                   	push   %edi
  8014a3:	6a 20                	push   $0x20
  8014a5:	ff 55 08             	call   *0x8(%ebp)
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8014a8:	4b                   	dec    %ebx
  8014a9:	83 c4 10             	add    $0x10,%esp
  8014ac:	85 db                	test   %ebx,%ebx
  8014ae:	7f ef                	jg     80149f <vprintfmt+0x24a>
  8014b0:	e9 c4 fd ff ff       	jmp    801279 <vprintfmt+0x24>
  8014b5:	89 5d d8             	mov    %ebx,-0x28(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8014b8:	89 ca                	mov    %ecx,%edx
  8014ba:	8d 45 14             	lea    0x14(%ebp),%eax
  8014bd:	e8 2a fd ff ff       	call   8011ec <getint>
  8014c2:	89 c3                	mov    %eax,%ebx
  8014c4:	89 d6                	mov    %edx,%esi
			if ((long long) num < 0) {
  8014c6:	85 d2                	test   %edx,%edx
  8014c8:	78 0a                	js     8014d4 <vprintfmt+0x27f>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8014ca:	b8 0a 00 00 00       	mov    $0xa,%eax
  8014cf:	e9 b0 00 00 00       	jmp    801584 <vprintfmt+0x32f>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  8014d4:	83 ec 08             	sub    $0x8,%esp
  8014d7:	57                   	push   %edi
  8014d8:	6a 2d                	push   $0x2d
  8014da:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  8014dd:	f7 db                	neg    %ebx
  8014df:	83 d6 00             	adc    $0x0,%esi
  8014e2:	f7 de                	neg    %esi
  8014e4:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  8014e7:	b8 0a 00 00 00       	mov    $0xa,%eax
  8014ec:	e9 93 00 00 00       	jmp    801584 <vprintfmt+0x32f>
  8014f1:	89 5d d8             	mov    %ebx,-0x28(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8014f4:	89 ca                	mov    %ecx,%edx
  8014f6:	8d 45 14             	lea    0x14(%ebp),%eax
  8014f9:	e8 b4 fc ff ff       	call   8011b2 <getuint>
  8014fe:	89 c3                	mov    %eax,%ebx
  801500:	89 d6                	mov    %edx,%esi
			base = 10;
  801502:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  801507:	eb 7b                	jmp    801584 <vprintfmt+0x32f>
  801509:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// (unsigned) octal
		case 'o':
            // (MIT 6.828, lab1, Ex.8)  my code : 
            num = getint(&ap, lflag);
  80150c:	89 ca                	mov    %ecx,%edx
  80150e:	8d 45 14             	lea    0x14(%ebp),%eax
  801511:	e8 d6 fc ff ff       	call   8011ec <getint>
  801516:	89 c3                	mov    %eax,%ebx
  801518:	89 d6                	mov    %edx,%esi
            if ((long long) num < 0) {
  80151a:	85 d2                	test   %edx,%edx
  80151c:	78 07                	js     801525 <vprintfmt+0x2d0>
                putch('-', putdat);
                num = -(long long) num;
            }
            base = 8;
  80151e:	b8 08 00 00 00       	mov    $0x8,%eax
  801523:	eb 5f                	jmp    801584 <vprintfmt+0x32f>
		// (unsigned) octal
		case 'o':
            // (MIT 6.828, lab1, Ex.8)  my code : 
            num = getint(&ap, lflag);
            if ((long long) num < 0) {
                putch('-', putdat);
  801525:	83 ec 08             	sub    $0x8,%esp
  801528:	57                   	push   %edi
  801529:	6a 2d                	push   $0x2d
  80152b:	ff 55 08             	call   *0x8(%ebp)
                num = -(long long) num;
  80152e:	f7 db                	neg    %ebx
  801530:	83 d6 00             	adc    $0x0,%esi
  801533:	f7 de                	neg    %esi
  801535:	83 c4 10             	add    $0x10,%esp
            }
            base = 8;
  801538:	b8 08 00 00 00       	mov    $0x8,%eax
  80153d:	eb 45                	jmp    801584 <vprintfmt+0x32f>
  80153f:	89 5d d8             	mov    %ebx,-0x28(%ebp)
            goto number;

        // pointer
		case 'p':
			putch('0', putdat);
  801542:	83 ec 08             	sub    $0x8,%esp
  801545:	57                   	push   %edi
  801546:	6a 30                	push   $0x30
  801548:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  80154b:	83 c4 08             	add    $0x8,%esp
  80154e:	57                   	push   %edi
  80154f:	6a 78                	push   $0x78
  801551:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  801554:	8b 45 14             	mov    0x14(%ebp),%eax
  801557:	8d 50 04             	lea    0x4(%eax),%edx
  80155a:	89 55 14             	mov    %edx,0x14(%ebp)

        // pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  80155d:	8b 18                	mov    (%eax),%ebx
  80155f:	be 00 00 00 00       	mov    $0x0,%esi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  801564:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  801567:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  80156c:	eb 16                	jmp    801584 <vprintfmt+0x32f>
  80156e:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  801571:	89 ca                	mov    %ecx,%edx
  801573:	8d 45 14             	lea    0x14(%ebp),%eax
  801576:	e8 37 fc ff ff       	call   8011b2 <getuint>
  80157b:	89 c3                	mov    %eax,%ebx
  80157d:	89 d6                	mov    %edx,%esi
			base = 16;
  80157f:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  801584:	83 ec 0c             	sub    $0xc,%esp
  801587:	0f be 55 dc          	movsbl -0x24(%ebp),%edx
  80158b:	52                   	push   %edx
  80158c:	ff 75 e4             	pushl  -0x1c(%ebp)
  80158f:	50                   	push   %eax
  801590:	56                   	push   %esi
  801591:	53                   	push   %ebx
  801592:	89 fa                	mov    %edi,%edx
  801594:	8b 45 08             	mov    0x8(%ebp),%eax
  801597:	e8 68 fb ff ff       	call   801104 <printnum>
			break;
  80159c:	83 c4 20             	add    $0x20,%esp
  80159f:	8b 75 d8             	mov    -0x28(%ebp),%esi
  8015a2:	e9 d2 fc ff ff       	jmp    801279 <vprintfmt+0x24>
  8015a7:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8015aa:	83 ec 08             	sub    $0x8,%esp
  8015ad:	57                   	push   %edi
  8015ae:	52                   	push   %edx
  8015af:	ff 55 08             	call   *0x8(%ebp)
			break;
  8015b2:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8015b5:	8b 75 d8             	mov    -0x28(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8015b8:	e9 bc fc ff ff       	jmp    801279 <vprintfmt+0x24>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8015bd:	83 ec 08             	sub    $0x8,%esp
  8015c0:	57                   	push   %edi
  8015c1:	6a 25                	push   $0x25
  8015c3:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  8015c6:	83 c4 10             	add    $0x10,%esp
  8015c9:	eb 02                	jmp    8015cd <vprintfmt+0x378>
  8015cb:	89 c6                	mov    %eax,%esi
  8015cd:	8d 46 ff             	lea    -0x1(%esi),%eax
  8015d0:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  8015d4:	75 f5                	jne    8015cb <vprintfmt+0x376>
  8015d6:	e9 9e fc ff ff       	jmp    801279 <vprintfmt+0x24>
				/* do nothing */;
			break;
		}
	}
}
  8015db:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8015de:	5b                   	pop    %ebx
  8015df:	5e                   	pop    %esi
  8015e0:	5f                   	pop    %edi
  8015e1:	c9                   	leave  
  8015e2:	c3                   	ret    

008015e3 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8015e3:	55                   	push   %ebp
  8015e4:	89 e5                	mov    %esp,%ebp
  8015e6:	83 ec 18             	sub    $0x18,%esp
  8015e9:	8b 45 08             	mov    0x8(%ebp),%eax
  8015ec:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8015ef:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8015f2:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8015f6:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8015f9:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  801600:	85 c0                	test   %eax,%eax
  801602:	74 26                	je     80162a <vsnprintf+0x47>
  801604:	85 d2                	test   %edx,%edx
  801606:	7e 29                	jle    801631 <vsnprintf+0x4e>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  801608:	ff 75 14             	pushl  0x14(%ebp)
  80160b:	ff 75 10             	pushl  0x10(%ebp)
  80160e:	8d 45 ec             	lea    -0x14(%ebp),%eax
  801611:	50                   	push   %eax
  801612:	68 1e 12 80 00       	push   $0x80121e
  801617:	e8 39 fc ff ff       	call   801255 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80161c:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80161f:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  801622:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801625:	83 c4 10             	add    $0x10,%esp
  801628:	eb 0c                	jmp    801636 <vsnprintf+0x53>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  80162a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80162f:	eb 05                	jmp    801636 <vsnprintf+0x53>
  801631:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  801636:	c9                   	leave  
  801637:	c3                   	ret    

00801638 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  801638:	55                   	push   %ebp
  801639:	89 e5                	mov    %esp,%ebp
  80163b:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80163e:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  801641:	50                   	push   %eax
  801642:	ff 75 10             	pushl  0x10(%ebp)
  801645:	ff 75 0c             	pushl  0xc(%ebp)
  801648:	ff 75 08             	pushl  0x8(%ebp)
  80164b:	e8 93 ff ff ff       	call   8015e3 <vsnprintf>
	va_end(ap);

	return rc;
}
  801650:	c9                   	leave  
  801651:	c3                   	ret    
	...

00801654 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  801654:	55                   	push   %ebp
  801655:	89 e5                	mov    %esp,%ebp
  801657:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80165a:	80 3a 00             	cmpb   $0x0,(%edx)
  80165d:	74 0e                	je     80166d <strlen+0x19>
  80165f:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  801664:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  801665:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  801669:	75 f9                	jne    801664 <strlen+0x10>
  80166b:	eb 05                	jmp    801672 <strlen+0x1e>
  80166d:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  801672:	c9                   	leave  
  801673:	c3                   	ret    

00801674 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  801674:	55                   	push   %ebp
  801675:	89 e5                	mov    %esp,%ebp
  801677:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80167a:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80167d:	85 d2                	test   %edx,%edx
  80167f:	74 17                	je     801698 <strnlen+0x24>
  801681:	80 39 00             	cmpb   $0x0,(%ecx)
  801684:	74 19                	je     80169f <strnlen+0x2b>
  801686:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  80168b:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80168c:	39 d0                	cmp    %edx,%eax
  80168e:	74 14                	je     8016a4 <strnlen+0x30>
  801690:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  801694:	75 f5                	jne    80168b <strnlen+0x17>
  801696:	eb 0c                	jmp    8016a4 <strnlen+0x30>
  801698:	b8 00 00 00 00       	mov    $0x0,%eax
  80169d:	eb 05                	jmp    8016a4 <strnlen+0x30>
  80169f:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  8016a4:	c9                   	leave  
  8016a5:	c3                   	ret    

008016a6 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8016a6:	55                   	push   %ebp
  8016a7:	89 e5                	mov    %esp,%ebp
  8016a9:	53                   	push   %ebx
  8016aa:	8b 45 08             	mov    0x8(%ebp),%eax
  8016ad:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8016b0:	ba 00 00 00 00       	mov    $0x0,%edx
  8016b5:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  8016b8:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  8016bb:	42                   	inc    %edx
  8016bc:	84 c9                	test   %cl,%cl
  8016be:	75 f5                	jne    8016b5 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  8016c0:	5b                   	pop    %ebx
  8016c1:	c9                   	leave  
  8016c2:	c3                   	ret    

008016c3 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8016c3:	55                   	push   %ebp
  8016c4:	89 e5                	mov    %esp,%ebp
  8016c6:	53                   	push   %ebx
  8016c7:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8016ca:	53                   	push   %ebx
  8016cb:	e8 84 ff ff ff       	call   801654 <strlen>
  8016d0:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8016d3:	ff 75 0c             	pushl  0xc(%ebp)
  8016d6:	8d 04 03             	lea    (%ebx,%eax,1),%eax
  8016d9:	50                   	push   %eax
  8016da:	e8 c7 ff ff ff       	call   8016a6 <strcpy>
	return dst;
}
  8016df:	89 d8                	mov    %ebx,%eax
  8016e1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016e4:	c9                   	leave  
  8016e5:	c3                   	ret    

008016e6 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8016e6:	55                   	push   %ebp
  8016e7:	89 e5                	mov    %esp,%ebp
  8016e9:	56                   	push   %esi
  8016ea:	53                   	push   %ebx
  8016eb:	8b 45 08             	mov    0x8(%ebp),%eax
  8016ee:	8b 55 0c             	mov    0xc(%ebp),%edx
  8016f1:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8016f4:	85 f6                	test   %esi,%esi
  8016f6:	74 15                	je     80170d <strncpy+0x27>
  8016f8:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
  8016fd:	8a 1a                	mov    (%edx),%bl
  8016ff:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  801702:	80 3a 01             	cmpb   $0x1,(%edx)
  801705:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801708:	41                   	inc    %ecx
  801709:	39 ce                	cmp    %ecx,%esi
  80170b:	77 f0                	ja     8016fd <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  80170d:	5b                   	pop    %ebx
  80170e:	5e                   	pop    %esi
  80170f:	c9                   	leave  
  801710:	c3                   	ret    

00801711 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  801711:	55                   	push   %ebp
  801712:	89 e5                	mov    %esp,%ebp
  801714:	57                   	push   %edi
  801715:	56                   	push   %esi
  801716:	53                   	push   %ebx
  801717:	8b 7d 08             	mov    0x8(%ebp),%edi
  80171a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80171d:	8b 75 10             	mov    0x10(%ebp),%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  801720:	85 f6                	test   %esi,%esi
  801722:	74 32                	je     801756 <strlcpy+0x45>
		while (--size > 0 && *src != '\0')
  801724:	83 fe 01             	cmp    $0x1,%esi
  801727:	74 22                	je     80174b <strlcpy+0x3a>
  801729:	8a 0b                	mov    (%ebx),%cl
  80172b:	84 c9                	test   %cl,%cl
  80172d:	74 20                	je     80174f <strlcpy+0x3e>
  80172f:	89 f8                	mov    %edi,%eax
  801731:	ba 00 00 00 00       	mov    $0x0,%edx
	}
	return ret;
}

size_t
strlcpy(char *dst, const char *src, size_t size)
  801736:	83 ee 02             	sub    $0x2,%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  801739:	88 08                	mov    %cl,(%eax)
  80173b:	40                   	inc    %eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  80173c:	39 f2                	cmp    %esi,%edx
  80173e:	74 11                	je     801751 <strlcpy+0x40>
  801740:	8a 4c 13 01          	mov    0x1(%ebx,%edx,1),%cl
  801744:	42                   	inc    %edx
  801745:	84 c9                	test   %cl,%cl
  801747:	75 f0                	jne    801739 <strlcpy+0x28>
  801749:	eb 06                	jmp    801751 <strlcpy+0x40>
  80174b:	89 f8                	mov    %edi,%eax
  80174d:	eb 02                	jmp    801751 <strlcpy+0x40>
  80174f:	89 f8                	mov    %edi,%eax
			*dst++ = *src++;
		*dst = '\0';
  801751:	c6 00 00             	movb   $0x0,(%eax)
  801754:	eb 02                	jmp    801758 <strlcpy+0x47>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  801756:	89 f8                	mov    %edi,%eax
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
		*dst = '\0';
	}
	return dst - dst_in;
  801758:	29 f8                	sub    %edi,%eax
}
  80175a:	5b                   	pop    %ebx
  80175b:	5e                   	pop    %esi
  80175c:	5f                   	pop    %edi
  80175d:	c9                   	leave  
  80175e:	c3                   	ret    

0080175f <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80175f:	55                   	push   %ebp
  801760:	89 e5                	mov    %esp,%ebp
  801762:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801765:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  801768:	8a 01                	mov    (%ecx),%al
  80176a:	84 c0                	test   %al,%al
  80176c:	74 10                	je     80177e <strcmp+0x1f>
  80176e:	3a 02                	cmp    (%edx),%al
  801770:	75 0c                	jne    80177e <strcmp+0x1f>
		p++, q++;
  801772:	41                   	inc    %ecx
  801773:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  801774:	8a 01                	mov    (%ecx),%al
  801776:	84 c0                	test   %al,%al
  801778:	74 04                	je     80177e <strcmp+0x1f>
  80177a:	3a 02                	cmp    (%edx),%al
  80177c:	74 f4                	je     801772 <strcmp+0x13>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  80177e:	0f b6 c0             	movzbl %al,%eax
  801781:	0f b6 12             	movzbl (%edx),%edx
  801784:	29 d0                	sub    %edx,%eax
}
  801786:	c9                   	leave  
  801787:	c3                   	ret    

00801788 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  801788:	55                   	push   %ebp
  801789:	89 e5                	mov    %esp,%ebp
  80178b:	53                   	push   %ebx
  80178c:	8b 55 08             	mov    0x8(%ebp),%edx
  80178f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801792:	8b 45 10             	mov    0x10(%ebp),%eax
	while (n > 0 && *p && *p == *q)
  801795:	85 c0                	test   %eax,%eax
  801797:	74 1b                	je     8017b4 <strncmp+0x2c>
  801799:	8a 1a                	mov    (%edx),%bl
  80179b:	84 db                	test   %bl,%bl
  80179d:	74 24                	je     8017c3 <strncmp+0x3b>
  80179f:	3a 19                	cmp    (%ecx),%bl
  8017a1:	75 20                	jne    8017c3 <strncmp+0x3b>
  8017a3:	48                   	dec    %eax
  8017a4:	74 15                	je     8017bb <strncmp+0x33>
		n--, p++, q++;
  8017a6:	42                   	inc    %edx
  8017a7:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8017a8:	8a 1a                	mov    (%edx),%bl
  8017aa:	84 db                	test   %bl,%bl
  8017ac:	74 15                	je     8017c3 <strncmp+0x3b>
  8017ae:	3a 19                	cmp    (%ecx),%bl
  8017b0:	74 f1                	je     8017a3 <strncmp+0x1b>
  8017b2:	eb 0f                	jmp    8017c3 <strncmp+0x3b>
		n--, p++, q++;
	if (n == 0)
		return 0;
  8017b4:	b8 00 00 00 00       	mov    $0x0,%eax
  8017b9:	eb 05                	jmp    8017c0 <strncmp+0x38>
  8017bb:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8017c0:	5b                   	pop    %ebx
  8017c1:	c9                   	leave  
  8017c2:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8017c3:	0f b6 02             	movzbl (%edx),%eax
  8017c6:	0f b6 11             	movzbl (%ecx),%edx
  8017c9:	29 d0                	sub    %edx,%eax
  8017cb:	eb f3                	jmp    8017c0 <strncmp+0x38>

008017cd <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8017cd:	55                   	push   %ebp
  8017ce:	89 e5                	mov    %esp,%ebp
  8017d0:	8b 45 08             	mov    0x8(%ebp),%eax
  8017d3:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  8017d6:	8a 10                	mov    (%eax),%dl
  8017d8:	84 d2                	test   %dl,%dl
  8017da:	74 18                	je     8017f4 <strchr+0x27>
		if (*s == c)
  8017dc:	38 ca                	cmp    %cl,%dl
  8017de:	75 06                	jne    8017e6 <strchr+0x19>
  8017e0:	eb 17                	jmp    8017f9 <strchr+0x2c>
  8017e2:	38 ca                	cmp    %cl,%dl
  8017e4:	74 13                	je     8017f9 <strchr+0x2c>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8017e6:	40                   	inc    %eax
  8017e7:	8a 10                	mov    (%eax),%dl
  8017e9:	84 d2                	test   %dl,%dl
  8017eb:	75 f5                	jne    8017e2 <strchr+0x15>
		if (*s == c)
			return (char *) s;
	return 0;
  8017ed:	b8 00 00 00 00       	mov    $0x0,%eax
  8017f2:	eb 05                	jmp    8017f9 <strchr+0x2c>
  8017f4:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8017f9:	c9                   	leave  
  8017fa:	c3                   	ret    

008017fb <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8017fb:	55                   	push   %ebp
  8017fc:	89 e5                	mov    %esp,%ebp
  8017fe:	8b 45 08             	mov    0x8(%ebp),%eax
  801801:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  801804:	8a 10                	mov    (%eax),%dl
  801806:	84 d2                	test   %dl,%dl
  801808:	74 11                	je     80181b <strfind+0x20>
		if (*s == c)
  80180a:	38 ca                	cmp    %cl,%dl
  80180c:	75 06                	jne    801814 <strfind+0x19>
  80180e:	eb 0b                	jmp    80181b <strfind+0x20>
  801810:	38 ca                	cmp    %cl,%dl
  801812:	74 07                	je     80181b <strfind+0x20>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  801814:	40                   	inc    %eax
  801815:	8a 10                	mov    (%eax),%dl
  801817:	84 d2                	test   %dl,%dl
  801819:	75 f5                	jne    801810 <strfind+0x15>
		if (*s == c)
			break;
	return (char *) s;
}
  80181b:	c9                   	leave  
  80181c:	c3                   	ret    

0080181d <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  80181d:	55                   	push   %ebp
  80181e:	89 e5                	mov    %esp,%ebp
  801820:	57                   	push   %edi
  801821:	56                   	push   %esi
  801822:	53                   	push   %ebx
  801823:	8b 7d 08             	mov    0x8(%ebp),%edi
  801826:	8b 45 0c             	mov    0xc(%ebp),%eax
  801829:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  80182c:	85 c9                	test   %ecx,%ecx
  80182e:	74 30                	je     801860 <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  801830:	f7 c7 03 00 00 00    	test   $0x3,%edi
  801836:	75 25                	jne    80185d <memset+0x40>
  801838:	f6 c1 03             	test   $0x3,%cl
  80183b:	75 20                	jne    80185d <memset+0x40>
		c &= 0xFF;
  80183d:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  801840:	89 d3                	mov    %edx,%ebx
  801842:	c1 e3 08             	shl    $0x8,%ebx
  801845:	89 d6                	mov    %edx,%esi
  801847:	c1 e6 18             	shl    $0x18,%esi
  80184a:	89 d0                	mov    %edx,%eax
  80184c:	c1 e0 10             	shl    $0x10,%eax
  80184f:	09 f0                	or     %esi,%eax
  801851:	09 d0                	or     %edx,%eax
  801853:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  801855:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  801858:	fc                   	cld    
  801859:	f3 ab                	rep stos %eax,%es:(%edi)
  80185b:	eb 03                	jmp    801860 <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  80185d:	fc                   	cld    
  80185e:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  801860:	89 f8                	mov    %edi,%eax
  801862:	5b                   	pop    %ebx
  801863:	5e                   	pop    %esi
  801864:	5f                   	pop    %edi
  801865:	c9                   	leave  
  801866:	c3                   	ret    

00801867 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  801867:	55                   	push   %ebp
  801868:	89 e5                	mov    %esp,%ebp
  80186a:	57                   	push   %edi
  80186b:	56                   	push   %esi
  80186c:	8b 45 08             	mov    0x8(%ebp),%eax
  80186f:	8b 75 0c             	mov    0xc(%ebp),%esi
  801872:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  801875:	39 c6                	cmp    %eax,%esi
  801877:	73 34                	jae    8018ad <memmove+0x46>
  801879:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  80187c:	39 d0                	cmp    %edx,%eax
  80187e:	73 2d                	jae    8018ad <memmove+0x46>
		s += n;
		d += n;
  801880:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801883:	f6 c2 03             	test   $0x3,%dl
  801886:	75 1b                	jne    8018a3 <memmove+0x3c>
  801888:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80188e:	75 13                	jne    8018a3 <memmove+0x3c>
  801890:	f6 c1 03             	test   $0x3,%cl
  801893:	75 0e                	jne    8018a3 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  801895:	83 ef 04             	sub    $0x4,%edi
  801898:	8d 72 fc             	lea    -0x4(%edx),%esi
  80189b:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  80189e:	fd                   	std    
  80189f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8018a1:	eb 07                	jmp    8018aa <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  8018a3:	4f                   	dec    %edi
  8018a4:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8018a7:	fd                   	std    
  8018a8:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8018aa:	fc                   	cld    
  8018ab:	eb 20                	jmp    8018cd <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8018ad:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8018b3:	75 13                	jne    8018c8 <memmove+0x61>
  8018b5:	a8 03                	test   $0x3,%al
  8018b7:	75 0f                	jne    8018c8 <memmove+0x61>
  8018b9:	f6 c1 03             	test   $0x3,%cl
  8018bc:	75 0a                	jne    8018c8 <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  8018be:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  8018c1:	89 c7                	mov    %eax,%edi
  8018c3:	fc                   	cld    
  8018c4:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8018c6:	eb 05                	jmp    8018cd <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8018c8:	89 c7                	mov    %eax,%edi
  8018ca:	fc                   	cld    
  8018cb:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8018cd:	5e                   	pop    %esi
  8018ce:	5f                   	pop    %edi
  8018cf:	c9                   	leave  
  8018d0:	c3                   	ret    

008018d1 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8018d1:	55                   	push   %ebp
  8018d2:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  8018d4:	ff 75 10             	pushl  0x10(%ebp)
  8018d7:	ff 75 0c             	pushl  0xc(%ebp)
  8018da:	ff 75 08             	pushl  0x8(%ebp)
  8018dd:	e8 85 ff ff ff       	call   801867 <memmove>
}
  8018e2:	c9                   	leave  
  8018e3:	c3                   	ret    

008018e4 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8018e4:	55                   	push   %ebp
  8018e5:	89 e5                	mov    %esp,%ebp
  8018e7:	57                   	push   %edi
  8018e8:	56                   	push   %esi
  8018e9:	53                   	push   %ebx
  8018ea:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8018ed:	8b 75 0c             	mov    0xc(%ebp),%esi
  8018f0:	8b 7d 10             	mov    0x10(%ebp),%edi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8018f3:	85 ff                	test   %edi,%edi
  8018f5:	74 32                	je     801929 <memcmp+0x45>
		if (*s1 != *s2)
  8018f7:	8a 03                	mov    (%ebx),%al
  8018f9:	8a 0e                	mov    (%esi),%cl
  8018fb:	38 c8                	cmp    %cl,%al
  8018fd:	74 19                	je     801918 <memcmp+0x34>
  8018ff:	eb 0d                	jmp    80190e <memcmp+0x2a>
  801901:	8a 44 13 01          	mov    0x1(%ebx,%edx,1),%al
  801905:	8a 4c 16 01          	mov    0x1(%esi,%edx,1),%cl
  801909:	42                   	inc    %edx
  80190a:	38 c8                	cmp    %cl,%al
  80190c:	74 10                	je     80191e <memcmp+0x3a>
			return (int) *s1 - (int) *s2;
  80190e:	0f b6 c0             	movzbl %al,%eax
  801911:	0f b6 c9             	movzbl %cl,%ecx
  801914:	29 c8                	sub    %ecx,%eax
  801916:	eb 16                	jmp    80192e <memcmp+0x4a>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801918:	4f                   	dec    %edi
  801919:	ba 00 00 00 00       	mov    $0x0,%edx
  80191e:	39 fa                	cmp    %edi,%edx
  801920:	75 df                	jne    801901 <memcmp+0x1d>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  801922:	b8 00 00 00 00       	mov    $0x0,%eax
  801927:	eb 05                	jmp    80192e <memcmp+0x4a>
  801929:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80192e:	5b                   	pop    %ebx
  80192f:	5e                   	pop    %esi
  801930:	5f                   	pop    %edi
  801931:	c9                   	leave  
  801932:	c3                   	ret    

00801933 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  801933:	55                   	push   %ebp
  801934:	89 e5                	mov    %esp,%ebp
  801936:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  801939:	89 c2                	mov    %eax,%edx
  80193b:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  80193e:	39 d0                	cmp    %edx,%eax
  801940:	73 12                	jae    801954 <memfind+0x21>
		if (*(const unsigned char *) s == (unsigned char) c)
  801942:	8a 4d 0c             	mov    0xc(%ebp),%cl
  801945:	38 08                	cmp    %cl,(%eax)
  801947:	75 06                	jne    80194f <memfind+0x1c>
  801949:	eb 09                	jmp    801954 <memfind+0x21>
  80194b:	38 08                	cmp    %cl,(%eax)
  80194d:	74 05                	je     801954 <memfind+0x21>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  80194f:	40                   	inc    %eax
  801950:	39 c2                	cmp    %eax,%edx
  801952:	77 f7                	ja     80194b <memfind+0x18>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  801954:	c9                   	leave  
  801955:	c3                   	ret    

00801956 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  801956:	55                   	push   %ebp
  801957:	89 e5                	mov    %esp,%ebp
  801959:	57                   	push   %edi
  80195a:	56                   	push   %esi
  80195b:	53                   	push   %ebx
  80195c:	8b 55 08             	mov    0x8(%ebp),%edx
  80195f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801962:	eb 01                	jmp    801965 <strtol+0xf>
		s++;
  801964:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801965:	8a 02                	mov    (%edx),%al
  801967:	3c 20                	cmp    $0x20,%al
  801969:	74 f9                	je     801964 <strtol+0xe>
  80196b:	3c 09                	cmp    $0x9,%al
  80196d:	74 f5                	je     801964 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  80196f:	3c 2b                	cmp    $0x2b,%al
  801971:	75 08                	jne    80197b <strtol+0x25>
		s++;
  801973:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  801974:	bf 00 00 00 00       	mov    $0x0,%edi
  801979:	eb 13                	jmp    80198e <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  80197b:	3c 2d                	cmp    $0x2d,%al
  80197d:	75 0a                	jne    801989 <strtol+0x33>
		s++, neg = 1;
  80197f:	8d 52 01             	lea    0x1(%edx),%edx
  801982:	bf 01 00 00 00       	mov    $0x1,%edi
  801987:	eb 05                	jmp    80198e <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  801989:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  80198e:	85 db                	test   %ebx,%ebx
  801990:	74 05                	je     801997 <strtol+0x41>
  801992:	83 fb 10             	cmp    $0x10,%ebx
  801995:	75 28                	jne    8019bf <strtol+0x69>
  801997:	8a 02                	mov    (%edx),%al
  801999:	3c 30                	cmp    $0x30,%al
  80199b:	75 10                	jne    8019ad <strtol+0x57>
  80199d:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  8019a1:	75 0a                	jne    8019ad <strtol+0x57>
		s += 2, base = 16;
  8019a3:	83 c2 02             	add    $0x2,%edx
  8019a6:	bb 10 00 00 00       	mov    $0x10,%ebx
  8019ab:	eb 12                	jmp    8019bf <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  8019ad:	85 db                	test   %ebx,%ebx
  8019af:	75 0e                	jne    8019bf <strtol+0x69>
  8019b1:	3c 30                	cmp    $0x30,%al
  8019b3:	75 05                	jne    8019ba <strtol+0x64>
		s++, base = 8;
  8019b5:	42                   	inc    %edx
  8019b6:	b3 08                	mov    $0x8,%bl
  8019b8:	eb 05                	jmp    8019bf <strtol+0x69>
	else if (base == 0)
		base = 10;
  8019ba:	bb 0a 00 00 00       	mov    $0xa,%ebx
  8019bf:	b8 00 00 00 00       	mov    $0x0,%eax
  8019c4:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  8019c6:	8a 0a                	mov    (%edx),%cl
  8019c8:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  8019cb:	80 fb 09             	cmp    $0x9,%bl
  8019ce:	77 08                	ja     8019d8 <strtol+0x82>
			dig = *s - '0';
  8019d0:	0f be c9             	movsbl %cl,%ecx
  8019d3:	83 e9 30             	sub    $0x30,%ecx
  8019d6:	eb 1e                	jmp    8019f6 <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  8019d8:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  8019db:	80 fb 19             	cmp    $0x19,%bl
  8019de:	77 08                	ja     8019e8 <strtol+0x92>
			dig = *s - 'a' + 10;
  8019e0:	0f be c9             	movsbl %cl,%ecx
  8019e3:	83 e9 57             	sub    $0x57,%ecx
  8019e6:	eb 0e                	jmp    8019f6 <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  8019e8:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  8019eb:	80 fb 19             	cmp    $0x19,%bl
  8019ee:	77 13                	ja     801a03 <strtol+0xad>
			dig = *s - 'A' + 10;
  8019f0:	0f be c9             	movsbl %cl,%ecx
  8019f3:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  8019f6:	39 f1                	cmp    %esi,%ecx
  8019f8:	7d 0d                	jge    801a07 <strtol+0xb1>
			break;
		s++, val = (val * base) + dig;
  8019fa:	42                   	inc    %edx
  8019fb:	0f af c6             	imul   %esi,%eax
  8019fe:	8d 04 01             	lea    (%ecx,%eax,1),%eax
		// we don't properly detect overflow!
	}
  801a01:	eb c3                	jmp    8019c6 <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  801a03:	89 c1                	mov    %eax,%ecx
  801a05:	eb 02                	jmp    801a09 <strtol+0xb3>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  801a07:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  801a09:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801a0d:	74 05                	je     801a14 <strtol+0xbe>
		*endptr = (char *) s;
  801a0f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801a12:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  801a14:	85 ff                	test   %edi,%edi
  801a16:	74 04                	je     801a1c <strtol+0xc6>
  801a18:	89 c8                	mov    %ecx,%eax
  801a1a:	f7 d8                	neg    %eax
}
  801a1c:	5b                   	pop    %ebx
  801a1d:	5e                   	pop    %esi
  801a1e:	5f                   	pop    %edi
  801a1f:	c9                   	leave  
  801a20:	c3                   	ret    
  801a21:	00 00                	add    %al,(%eax)
	...

00801a24 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801a24:	55                   	push   %ebp
  801a25:	89 e5                	mov    %esp,%ebp
  801a27:	56                   	push   %esi
  801a28:	53                   	push   %ebx
  801a29:	8b 75 08             	mov    0x8(%ebp),%esi
  801a2c:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a2f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// cprintf("0x%x 0x%x 0x%x\n", (uint32_t)from_env_store, (uint32_t)pg, (uint32_t)perm_store);
	int r;
	if (pg != NULL) {
  801a32:	85 c0                	test   %eax,%eax
  801a34:	74 0e                	je     801a44 <ipc_recv+0x20>
		r = sys_ipc_recv(pg);
  801a36:	83 ec 0c             	sub    $0xc,%esp
  801a39:	50                   	push   %eax
  801a3a:	e8 74 e8 ff ff       	call   8002b3 <sys_ipc_recv>
  801a3f:	83 c4 10             	add    $0x10,%esp
  801a42:	eb 10                	jmp    801a54 <ipc_recv+0x30>
	} else {
		r = sys_ipc_recv((void *)UTOP);
  801a44:	83 ec 0c             	sub    $0xc,%esp
  801a47:	68 00 00 c0 ee       	push   $0xeec00000
  801a4c:	e8 62 e8 ff ff       	call   8002b3 <sys_ipc_recv>
  801a51:	83 c4 10             	add    $0x10,%esp
	}

	if (r == 0) {
  801a54:	85 c0                	test   %eax,%eax
  801a56:	75 26                	jne    801a7e <ipc_recv+0x5a>
		if (from_env_store != NULL) *from_env_store = thisenv->env_ipc_from;
  801a58:	85 f6                	test   %esi,%esi
  801a5a:	74 0a                	je     801a66 <ipc_recv+0x42>
  801a5c:	a1 04 40 80 00       	mov    0x804004,%eax
  801a61:	8b 40 74             	mov    0x74(%eax),%eax
  801a64:	89 06                	mov    %eax,(%esi)
		if (perm_store != NULL) *perm_store = thisenv->env_ipc_perm;
  801a66:	85 db                	test   %ebx,%ebx
  801a68:	74 0a                	je     801a74 <ipc_recv+0x50>
  801a6a:	a1 04 40 80 00       	mov    0x804004,%eax
  801a6f:	8b 40 78             	mov    0x78(%eax),%eax
  801a72:	89 03                	mov    %eax,(%ebx)
		return thisenv->env_ipc_value;
  801a74:	a1 04 40 80 00       	mov    0x804004,%eax
  801a79:	8b 40 70             	mov    0x70(%eax),%eax
  801a7c:	eb 14                	jmp    801a92 <ipc_recv+0x6e>
	} else {
		// fails;
		if (from_env_store != NULL) *from_env_store = 0;
  801a7e:	85 f6                	test   %esi,%esi
  801a80:	74 06                	je     801a88 <ipc_recv+0x64>
  801a82:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		if (perm_store != NULL) *perm_store = 0;
  801a88:	85 db                	test   %ebx,%ebx
  801a8a:	74 06                	je     801a92 <ipc_recv+0x6e>
  801a8c:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
		return r;
	}
}
  801a92:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a95:	5b                   	pop    %ebx
  801a96:	5e                   	pop    %esi
  801a97:	c9                   	leave  
  801a98:	c3                   	ret    

00801a99 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801a99:	55                   	push   %ebp
  801a9a:	89 e5                	mov    %esp,%ebp
  801a9c:	57                   	push   %edi
  801a9d:	56                   	push   %esi
  801a9e:	53                   	push   %ebx
  801a9f:	83 ec 0c             	sub    $0xc,%esp
  801aa2:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801aa5:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801aa8:	8b 75 14             	mov    0x14(%ebp),%esi
	// LAB 4: Your code here.
	// int sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
	int r;
	if (pg == NULL) pg = (void *)UTOP;
  801aab:	85 db                	test   %ebx,%ebx
  801aad:	75 25                	jne    801ad4 <ipc_send+0x3b>
  801aaf:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
  801ab4:	eb 1e                	jmp    801ad4 <ipc_send+0x3b>
	
	while ((r = sys_ipc_try_send(to_env, val, pg, perm)) != 0) {
		if (r == -E_IPC_NOT_RECV) {
  801ab6:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801ab9:	75 07                	jne    801ac2 <ipc_send+0x29>
			// cprintf("Try Again and Again....\n");
			sys_yield();
  801abb:	e8 d1 e6 ff ff       	call   800191 <sys_yield>
  801ac0:	eb 12                	jmp    801ad4 <ipc_send+0x3b>
		} else {
			panic("ipc_send error %e\n", r);
  801ac2:	50                   	push   %eax
  801ac3:	68 20 22 80 00       	push   $0x802220
  801ac8:	6a 43                	push   $0x43
  801aca:	68 33 22 80 00       	push   $0x802233
  801acf:	e8 44 f5 ff ff       	call   801018 <_panic>
	// LAB 4: Your code here.
	// int sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
	int r;
	if (pg == NULL) pg = (void *)UTOP;
	
	while ((r = sys_ipc_try_send(to_env, val, pg, perm)) != 0) {
  801ad4:	56                   	push   %esi
  801ad5:	53                   	push   %ebx
  801ad6:	57                   	push   %edi
  801ad7:	ff 75 08             	pushl  0x8(%ebp)
  801ada:	e8 af e7 ff ff       	call   80028e <sys_ipc_try_send>
  801adf:	83 c4 10             	add    $0x10,%esp
  801ae2:	85 c0                	test   %eax,%eax
  801ae4:	75 d0                	jne    801ab6 <ipc_send+0x1d>
		} else {
			panic("ipc_send error %e\n", r);
		}
	}
	return;
}
  801ae6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801ae9:	5b                   	pop    %ebx
  801aea:	5e                   	pop    %esi
  801aeb:	5f                   	pop    %edi
  801aec:	c9                   	leave  
  801aed:	c3                   	ret    

00801aee <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801aee:	55                   	push   %ebp
  801aef:	89 e5                	mov    %esp,%ebp
  801af1:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
		if (envs[i].env_type == type)
  801af4:	39 0d 50 00 c0 ee    	cmp    %ecx,0xeec00050
  801afa:	74 1a                	je     801b16 <ipc_find_env+0x28>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801afc:	b8 01 00 00 00       	mov    $0x1,%eax
		if (envs[i].env_type == type)
  801b01:	89 c2                	mov    %eax,%edx
  801b03:	c1 e2 07             	shl    $0x7,%edx
  801b06:	8d 94 82 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,4),%edx
  801b0d:	8b 52 50             	mov    0x50(%edx),%edx
  801b10:	39 ca                	cmp    %ecx,%edx
  801b12:	75 18                	jne    801b2c <ipc_find_env+0x3e>
  801b14:	eb 05                	jmp    801b1b <ipc_find_env+0x2d>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801b16:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
			return envs[i].env_id;
  801b1b:	89 c2                	mov    %eax,%edx
  801b1d:	c1 e2 07             	shl    $0x7,%edx
  801b20:	8d 84 82 08 00 c0 ee 	lea    -0x113ffff8(%edx,%eax,4),%eax
  801b27:	8b 40 40             	mov    0x40(%eax),%eax
  801b2a:	eb 0c                	jmp    801b38 <ipc_find_env+0x4a>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801b2c:	40                   	inc    %eax
  801b2d:	3d 00 04 00 00       	cmp    $0x400,%eax
  801b32:	75 cd                	jne    801b01 <ipc_find_env+0x13>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801b34:	66 b8 00 00          	mov    $0x0,%ax
}
  801b38:	c9                   	leave  
  801b39:	c3                   	ret    
	...

00801b3c <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801b3c:	55                   	push   %ebp
  801b3d:	89 e5                	mov    %esp,%ebp
  801b3f:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801b42:	89 c2                	mov    %eax,%edx
  801b44:	c1 ea 16             	shr    $0x16,%edx
  801b47:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801b4e:	f6 c2 01             	test   $0x1,%dl
  801b51:	74 1e                	je     801b71 <pageref+0x35>
		return 0;
	pte = uvpt[PGNUM(v)];
  801b53:	c1 e8 0c             	shr    $0xc,%eax
  801b56:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  801b5d:	a8 01                	test   $0x1,%al
  801b5f:	74 17                	je     801b78 <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801b61:	c1 e8 0c             	shr    $0xc,%eax
  801b64:	66 8b 04 c5 04 00 00 	mov    -0x10fffffc(,%eax,8),%ax
  801b6b:	ef 
  801b6c:	0f b7 c0             	movzwl %ax,%eax
  801b6f:	eb 0c                	jmp    801b7d <pageref+0x41>
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
		return 0;
  801b71:	b8 00 00 00 00       	mov    $0x0,%eax
  801b76:	eb 05                	jmp    801b7d <pageref+0x41>
	pte = uvpt[PGNUM(v)];
	if (!(pte & PTE_P))
		return 0;
  801b78:	b8 00 00 00 00       	mov    $0x0,%eax
	return pages[PGNUM(pte)].pp_ref;
}
  801b7d:	c9                   	leave  
  801b7e:	c3                   	ret    
	...

00801b80 <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  801b80:	55                   	push   %ebp
  801b81:	89 e5                	mov    %esp,%ebp
  801b83:	57                   	push   %edi
  801b84:	56                   	push   %esi
  801b85:	83 ec 10             	sub    $0x10,%esp
  801b88:	8b 7d 08             	mov    0x8(%ebp),%edi
  801b8b:	8b 4d 10             	mov    0x10(%ebp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  801b8e:	89 7d f0             	mov    %edi,-0x10(%ebp)
  801b91:	8b 75 0c             	mov    0xc(%ebp),%esi
  const DWunion dd = {.ll = d};
  801b94:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  801b97:	8b 45 14             	mov    0x14(%ebp),%eax
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  801b9a:	85 c0                	test   %eax,%eax
  801b9c:	75 2e                	jne    801bcc <__udivdi3+0x4c>
    {
      if (d0 > n1)
  801b9e:	39 f1                	cmp    %esi,%ecx
  801ba0:	77 5a                	ja     801bfc <__udivdi3+0x7c>
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  801ba2:	85 c9                	test   %ecx,%ecx
  801ba4:	75 0b                	jne    801bb1 <__udivdi3+0x31>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  801ba6:	b8 01 00 00 00       	mov    $0x1,%eax
  801bab:	31 d2                	xor    %edx,%edx
  801bad:	f7 f1                	div    %ecx
  801baf:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  801bb1:	31 d2                	xor    %edx,%edx
  801bb3:	89 f0                	mov    %esi,%eax
  801bb5:	f7 f1                	div    %ecx
  801bb7:	89 c6                	mov    %eax,%esi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801bb9:	89 f8                	mov    %edi,%eax
  801bbb:	f7 f1                	div    %ecx
  801bbd:	89 c7                	mov    %eax,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  801bbf:	89 f8                	mov    %edi,%eax
  801bc1:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801bc3:	83 c4 10             	add    $0x10,%esp
  801bc6:	5e                   	pop    %esi
  801bc7:	5f                   	pop    %edi
  801bc8:	c9                   	leave  
  801bc9:	c3                   	ret    
  801bca:	66 90                	xchg   %ax,%ax
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  801bcc:	39 f0                	cmp    %esi,%eax
  801bce:	77 1c                	ja     801bec <__udivdi3+0x6c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  801bd0:	0f bd f8             	bsr    %eax,%edi
	  if (bm == 0)
  801bd3:	83 f7 1f             	xor    $0x1f,%edi
  801bd6:	75 3c                	jne    801c14 <__udivdi3+0x94>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  801bd8:	39 f0                	cmp    %esi,%eax
  801bda:	0f 82 90 00 00 00    	jb     801c70 <__udivdi3+0xf0>
  801be0:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801be3:	39 55 f4             	cmp    %edx,-0xc(%ebp)
  801be6:	0f 86 84 00 00 00    	jbe    801c70 <__udivdi3+0xf0>
  801bec:	31 f6                	xor    %esi,%esi
  801bee:	31 ff                	xor    %edi,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  801bf0:	89 f8                	mov    %edi,%eax
  801bf2:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801bf4:	83 c4 10             	add    $0x10,%esp
  801bf7:	5e                   	pop    %esi
  801bf8:	5f                   	pop    %edi
  801bf9:	c9                   	leave  
  801bfa:	c3                   	ret    
  801bfb:	90                   	nop
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801bfc:	89 f2                	mov    %esi,%edx
  801bfe:	89 f8                	mov    %edi,%eax
  801c00:	f7 f1                	div    %ecx
  801c02:	89 c7                	mov    %eax,%edi
  801c04:	31 f6                	xor    %esi,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  801c06:	89 f8                	mov    %edi,%eax
  801c08:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801c0a:	83 c4 10             	add    $0x10,%esp
  801c0d:	5e                   	pop    %esi
  801c0e:	5f                   	pop    %edi
  801c0f:	c9                   	leave  
  801c10:	c3                   	ret    
  801c11:	8d 76 00             	lea    0x0(%esi),%esi
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  801c14:	89 f9                	mov    %edi,%ecx
  801c16:	d3 e0                	shl    %cl,%eax
  801c18:	89 45 e8             	mov    %eax,-0x18(%ebp)
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  801c1b:	b8 20 00 00 00       	mov    $0x20,%eax
  801c20:	29 f8                	sub    %edi,%eax

	      d1 = (d1 << bm) | (d0 >> b);
  801c22:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801c25:	88 c1                	mov    %al,%cl
  801c27:	d3 ea                	shr    %cl,%edx
  801c29:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  801c2c:	09 ca                	or     %ecx,%edx
  801c2e:	89 55 ec             	mov    %edx,-0x14(%ebp)
	      d0 = d0 << bm;
  801c31:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801c34:	89 f9                	mov    %edi,%ecx
  801c36:	d3 e2                	shl    %cl,%edx
  801c38:	89 55 f4             	mov    %edx,-0xc(%ebp)
	      n2 = n1 >> b;
  801c3b:	89 f2                	mov    %esi,%edx
  801c3d:	88 c1                	mov    %al,%cl
  801c3f:	d3 ea                	shr    %cl,%edx
  801c41:	89 55 e8             	mov    %edx,-0x18(%ebp)
	      n1 = (n1 << bm) | (n0 >> b);
  801c44:	89 f2                	mov    %esi,%edx
  801c46:	89 f9                	mov    %edi,%ecx
  801c48:	d3 e2                	shl    %cl,%edx
  801c4a:	8b 75 f0             	mov    -0x10(%ebp),%esi
  801c4d:	88 c1                	mov    %al,%cl
  801c4f:	d3 ee                	shr    %cl,%esi
  801c51:	09 d6                	or     %edx,%esi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  801c53:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  801c56:	89 f0                	mov    %esi,%eax
  801c58:	89 ca                	mov    %ecx,%edx
  801c5a:	f7 75 ec             	divl   -0x14(%ebp)
  801c5d:	89 d1                	mov    %edx,%ecx
  801c5f:	89 c6                	mov    %eax,%esi
	      umul_ppmm (m1, m0, q0, d0);
  801c61:	f7 65 f4             	mull   -0xc(%ebp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801c64:	39 d1                	cmp    %edx,%ecx
  801c66:	72 28                	jb     801c90 <__udivdi3+0x110>
  801c68:	74 1a                	je     801c84 <__udivdi3+0x104>
  801c6a:	89 f7                	mov    %esi,%edi
  801c6c:	31 f6                	xor    %esi,%esi
  801c6e:	eb 80                	jmp    801bf0 <__udivdi3+0x70>
	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  801c70:	31 f6                	xor    %esi,%esi
  801c72:	bf 01 00 00 00       	mov    $0x1,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  801c77:	89 f8                	mov    %edi,%eax
  801c79:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801c7b:	83 c4 10             	add    $0x10,%esp
  801c7e:	5e                   	pop    %esi
  801c7f:	5f                   	pop    %edi
  801c80:	c9                   	leave  
  801c81:	c3                   	ret    
  801c82:	66 90                	xchg   %ax,%ax

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  801c84:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801c87:	89 f9                	mov    %edi,%ecx
  801c89:	d3 e2                	shl    %cl,%edx

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801c8b:	39 c2                	cmp    %eax,%edx
  801c8d:	73 db                	jae    801c6a <__udivdi3+0xea>
  801c8f:	90                   	nop
		{
		  q0--;
  801c90:	8d 7e ff             	lea    -0x1(%esi),%edi
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  801c93:	31 f6                	xor    %esi,%esi
  801c95:	e9 56 ff ff ff       	jmp    801bf0 <__udivdi3+0x70>
	...

00801c9c <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  801c9c:	55                   	push   %ebp
  801c9d:	89 e5                	mov    %esp,%ebp
  801c9f:	57                   	push   %edi
  801ca0:	56                   	push   %esi
  801ca1:	83 ec 20             	sub    $0x20,%esp
  801ca4:	8b 45 08             	mov    0x8(%ebp),%eax
  801ca7:	8b 4d 10             	mov    0x10(%ebp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  801caa:	89 45 e8             	mov    %eax,-0x18(%ebp)
  801cad:	8b 75 0c             	mov    0xc(%ebp),%esi
  const DWunion dd = {.ll = d};
  801cb0:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  801cb3:	8b 7d 14             	mov    0x14(%ebp),%edi
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  801cb6:	89 45 f0             	mov    %eax,-0x10(%ebp)
  n1 = nn.s.high;
  801cb9:	89 f2                	mov    %esi,%edx

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  801cbb:	85 ff                	test   %edi,%edi
  801cbd:	75 15                	jne    801cd4 <__umoddi3+0x38>
    {
      if (d0 > n1)
  801cbf:	39 f1                	cmp    %esi,%ecx
  801cc1:	0f 86 99 00 00 00    	jbe    801d60 <__umoddi3+0xc4>
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801cc7:	f7 f1                	div    %ecx

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
  801cc9:	89 d0                	mov    %edx,%eax
  801ccb:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  801ccd:	83 c4 20             	add    $0x20,%esp
  801cd0:	5e                   	pop    %esi
  801cd1:	5f                   	pop    %edi
  801cd2:	c9                   	leave  
  801cd3:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  801cd4:	39 f7                	cmp    %esi,%edi
  801cd6:	0f 87 a4 00 00 00    	ja     801d80 <__umoddi3+0xe4>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  801cdc:	0f bd c7             	bsr    %edi,%eax
	  if (bm == 0)
  801cdf:	83 f0 1f             	xor    $0x1f,%eax
  801ce2:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801ce5:	0f 84 a1 00 00 00    	je     801d8c <__umoddi3+0xf0>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  801ceb:	89 f8                	mov    %edi,%eax
  801ced:	8a 4d ec             	mov    -0x14(%ebp),%cl
  801cf0:	d3 e0                	shl    %cl,%eax
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  801cf2:	bf 20 00 00 00       	mov    $0x20,%edi
  801cf7:	2b 7d ec             	sub    -0x14(%ebp),%edi

	      d1 = (d1 << bm) | (d0 >> b);
  801cfa:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801cfd:	89 f9                	mov    %edi,%ecx
  801cff:	d3 ea                	shr    %cl,%edx
  801d01:	09 c2                	or     %eax,%edx
  801d03:	89 55 f0             	mov    %edx,-0x10(%ebp)
	      d0 = d0 << bm;
  801d06:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d09:	8a 4d ec             	mov    -0x14(%ebp),%cl
  801d0c:	d3 e0                	shl    %cl,%eax
  801d0e:	89 45 f4             	mov    %eax,-0xc(%ebp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  801d11:	89 f2                	mov    %esi,%edx
  801d13:	d3 e2                	shl    %cl,%edx
	      n0 = n0 << bm;
  801d15:	8b 45 e8             	mov    -0x18(%ebp),%eax
  801d18:	d3 e0                	shl    %cl,%eax
  801d1a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  801d1d:	8b 45 e8             	mov    -0x18(%ebp),%eax
  801d20:	89 f9                	mov    %edi,%ecx
  801d22:	d3 e8                	shr    %cl,%eax
  801d24:	09 d0                	or     %edx,%eax

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  801d26:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  801d28:	89 f2                	mov    %esi,%edx
  801d2a:	f7 75 f0             	divl   -0x10(%ebp)
  801d2d:	89 d6                	mov    %edx,%esi
	      umul_ppmm (m1, m0, q0, d0);
  801d2f:	f7 65 f4             	mull   -0xc(%ebp)
  801d32:	89 55 e8             	mov    %edx,-0x18(%ebp)
  801d35:	89 c1                	mov    %eax,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801d37:	39 d6                	cmp    %edx,%esi
  801d39:	72 71                	jb     801dac <__umoddi3+0x110>
  801d3b:	74 7f                	je     801dbc <__umoddi3+0x120>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  801d3d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801d40:	29 c8                	sub    %ecx,%eax
  801d42:	19 d6                	sbb    %edx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
  801d44:	8a 4d ec             	mov    -0x14(%ebp),%cl
  801d47:	d3 e8                	shr    %cl,%eax
  801d49:	89 f2                	mov    %esi,%edx
  801d4b:	89 f9                	mov    %edi,%ecx
  801d4d:	d3 e2                	shl    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
  801d4f:	09 d0                	or     %edx,%eax
  801d51:	89 f2                	mov    %esi,%edx
  801d53:	8a 4d ec             	mov    -0x14(%ebp),%cl
  801d56:	d3 ea                	shr    %cl,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  801d58:	83 c4 20             	add    $0x20,%esp
  801d5b:	5e                   	pop    %esi
  801d5c:	5f                   	pop    %edi
  801d5d:	c9                   	leave  
  801d5e:	c3                   	ret    
  801d5f:	90                   	nop
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  801d60:	85 c9                	test   %ecx,%ecx
  801d62:	75 0b                	jne    801d6f <__umoddi3+0xd3>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  801d64:	b8 01 00 00 00       	mov    $0x1,%eax
  801d69:	31 d2                	xor    %edx,%edx
  801d6b:	f7 f1                	div    %ecx
  801d6d:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  801d6f:	89 f0                	mov    %esi,%eax
  801d71:	31 d2                	xor    %edx,%edx
  801d73:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801d75:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801d78:	f7 f1                	div    %ecx
  801d7a:	e9 4a ff ff ff       	jmp    801cc9 <__umoddi3+0x2d>
  801d7f:	90                   	nop
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
  801d80:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  801d82:	83 c4 20             	add    $0x20,%esp
  801d85:	5e                   	pop    %esi
  801d86:	5f                   	pop    %edi
  801d87:	c9                   	leave  
  801d88:	c3                   	ret    
  801d89:	8d 76 00             	lea    0x0(%esi),%esi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  801d8c:	39 f7                	cmp    %esi,%edi
  801d8e:	72 05                	jb     801d95 <__umoddi3+0xf9>
  801d90:	3b 4d f0             	cmp    -0x10(%ebp),%ecx
  801d93:	77 0c                	ja     801da1 <__umoddi3+0x105>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  801d95:	89 f2                	mov    %esi,%edx
  801d97:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801d9a:	29 c8                	sub    %ecx,%eax
  801d9c:	19 fa                	sbb    %edi,%edx
  801d9e:	89 45 f0             	mov    %eax,-0x10(%ebp)

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
  801da1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  801da4:	83 c4 20             	add    $0x20,%esp
  801da7:	5e                   	pop    %esi
  801da8:	5f                   	pop    %edi
  801da9:	c9                   	leave  
  801daa:	c3                   	ret    
  801dab:	90                   	nop
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  801dac:	8b 55 e8             	mov    -0x18(%ebp),%edx
  801daf:	89 c1                	mov    %eax,%ecx
  801db1:	2b 4d f4             	sub    -0xc(%ebp),%ecx
  801db4:	1b 55 f0             	sbb    -0x10(%ebp),%edx
  801db7:	eb 84                	jmp    801d3d <__umoddi3+0xa1>
  801db9:	8d 76 00             	lea    0x0(%esi),%esi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801dbc:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  801dbf:	72 eb                	jb     801dac <__umoddi3+0x110>
  801dc1:	89 f2                	mov    %esi,%edx
  801dc3:	e9 75 ff ff ff       	jmp    801d3d <__umoddi3+0xa1>
