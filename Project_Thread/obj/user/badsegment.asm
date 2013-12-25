
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
  80004b:	e8 11 01 00 00       	call   800161 <sys_getenvid>
  800050:	25 ff 03 00 00       	and    $0x3ff,%eax
  800055:	89 c2                	mov    %eax,%edx
  800057:	c1 e2 07             	shl    $0x7,%edx
  80005a:	8d 84 82 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,4),%eax
  800061:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800066:	85 f6                	test   %esi,%esi
  800068:	7e 07                	jle    800071 <libmain+0x31>
		binaryname = argv[0];
  80006a:	8b 03                	mov    (%ebx),%eax
  80006c:	a3 00 30 80 00       	mov    %eax,0x803000
	// call user main routine
	umain(argc, argv);
  800071:	83 ec 08             	sub    $0x8,%esp
  800074:	53                   	push   %ebx
  800075:	56                   	push   %esi
  800076:	e8 b9 ff ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  80007b:	e8 0c 00 00 00       	call   80008c <exit>
  800080:	83 c4 10             	add    $0x10,%esp
}
  800083:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800086:	5b                   	pop    %ebx
  800087:	5e                   	pop    %esi
  800088:	c9                   	leave  
  800089:	c3                   	ret    
	...

0080008c <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80008c:	55                   	push   %ebp
  80008d:	89 e5                	mov    %esp,%ebp
  80008f:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800092:	e8 cb 04 00 00       	call   800562 <close_all>
	sys_env_destroy(0);
  800097:	83 ec 0c             	sub    $0xc,%esp
  80009a:	6a 00                	push   $0x0
  80009c:	e8 9e 00 00 00       	call   80013f <sys_env_destroy>
  8000a1:	83 c4 10             	add    $0x10,%esp
}
  8000a4:	c9                   	leave  
  8000a5:	c3                   	ret    
	...

008000a8 <syscall>:
	return ret;
}

static int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  8000a8:	55                   	push   %ebp
  8000a9:	89 e5                	mov    %esp,%ebp
  8000ab:	57                   	push   %edi
  8000ac:	56                   	push   %esi
  8000ad:	53                   	push   %ebx
  8000ae:	83 ec 1c             	sub    $0x1c,%esp
  8000b1:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8000b4:	89 55 e0             	mov    %edx,-0x20(%ebp)
  8000b7:	89 ca                	mov    %ecx,%edx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000b9:	8b 75 14             	mov    0x14(%ebp),%esi
  8000bc:	8b 7d 10             	mov    0x10(%ebp),%edi
  8000bf:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8000c2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8000c5:	cd 30                	int    $0x30
  8000c7:	89 c2                	mov    %eax,%edx
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8000c9:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8000cd:	74 1c                	je     8000eb <syscall+0x43>
  8000cf:	85 c0                	test   %eax,%eax
  8000d1:	7e 18                	jle    8000eb <syscall+0x43>
		panic("syscall %d returned %d (> 0)", num, ret);
  8000d3:	83 ec 0c             	sub    $0xc,%esp
  8000d6:	50                   	push   %eax
  8000d7:	ff 75 e4             	pushl  -0x1c(%ebp)
  8000da:	68 ca 1d 80 00       	push   $0x801dca
  8000df:	6a 42                	push   $0x42
  8000e1:	68 e7 1d 80 00       	push   $0x801de7
  8000e6:	e8 21 0f 00 00       	call   80100c <_panic>

	return ret;
}
  8000eb:	89 d0                	mov    %edx,%eax
  8000ed:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8000f0:	5b                   	pop    %ebx
  8000f1:	5e                   	pop    %esi
  8000f2:	5f                   	pop    %edi
  8000f3:	c9                   	leave  
  8000f4:	c3                   	ret    

008000f5 <sys_cputs>:

void
sys_cputs(const char *s, size_t len)
{	
  8000f5:	55                   	push   %ebp
  8000f6:	89 e5                	mov    %esp,%ebp
  8000f8:	83 ec 08             	sub    $0x8,%esp
	// my_sysenter(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
	// return;
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
  8000fb:	6a 00                	push   $0x0
  8000fd:	6a 00                	push   $0x0
  8000ff:	6a 00                	push   $0x0
  800101:	ff 75 0c             	pushl  0xc(%ebp)
  800104:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800107:	ba 00 00 00 00       	mov    $0x0,%edx
  80010c:	b8 00 00 00 00       	mov    $0x0,%eax
  800111:	e8 92 ff ff ff       	call   8000a8 <syscall>
  800116:	83 c4 10             	add    $0x10,%esp
	return;
}
  800119:	c9                   	leave  
  80011a:	c3                   	ret    

0080011b <sys_cgetc>:

int
sys_cgetc(void)
{
  80011b:	55                   	push   %ebp
  80011c:	89 e5                	mov    %esp,%ebp
  80011e:	83 ec 08             	sub    $0x8,%esp
	// return my_sysenter(SYS_cgetc, 0, 0, 0, 0, 0, 0);
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
  800121:	6a 00                	push   $0x0
  800123:	6a 00                	push   $0x0
  800125:	6a 00                	push   $0x0
  800127:	6a 00                	push   $0x0
  800129:	b9 00 00 00 00       	mov    $0x0,%ecx
  80012e:	ba 00 00 00 00       	mov    $0x0,%edx
  800133:	b8 01 00 00 00       	mov    $0x1,%eax
  800138:	e8 6b ff ff ff       	call   8000a8 <syscall>
}
  80013d:	c9                   	leave  
  80013e:	c3                   	ret    

0080013f <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  80013f:	55                   	push   %ebp
  800140:	89 e5                	mov    %esp,%ebp
  800142:	83 ec 08             	sub    $0x8,%esp
	// return my_sysenter(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
  800145:	6a 00                	push   $0x0
  800147:	6a 00                	push   $0x0
  800149:	6a 00                	push   $0x0
  80014b:	6a 00                	push   $0x0
  80014d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800150:	ba 01 00 00 00       	mov    $0x1,%edx
  800155:	b8 03 00 00 00       	mov    $0x3,%eax
  80015a:	e8 49 ff ff ff       	call   8000a8 <syscall>
}
  80015f:	c9                   	leave  
  800160:	c3                   	ret    

00800161 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800161:	55                   	push   %ebp
  800162:	89 e5                	mov    %esp,%ebp
  800164:	83 ec 08             	sub    $0x8,%esp
	// return my_sysenter(SYS_getenvid, 0, 0, 0, 0, 0, 0);
	return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
  800167:	6a 00                	push   $0x0
  800169:	6a 00                	push   $0x0
  80016b:	6a 00                	push   $0x0
  80016d:	6a 00                	push   $0x0
  80016f:	b9 00 00 00 00       	mov    $0x0,%ecx
  800174:	ba 00 00 00 00       	mov    $0x0,%edx
  800179:	b8 02 00 00 00       	mov    $0x2,%eax
  80017e:	e8 25 ff ff ff       	call   8000a8 <syscall>
}
  800183:	c9                   	leave  
  800184:	c3                   	ret    

00800185 <sys_yield>:

void
sys_yield(void)
{
  800185:	55                   	push   %ebp
  800186:	89 e5                	mov    %esp,%ebp
  800188:	83 ec 08             	sub    $0x8,%esp
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
  80018b:	6a 00                	push   $0x0
  80018d:	6a 00                	push   $0x0
  80018f:	6a 00                	push   $0x0
  800191:	6a 00                	push   $0x0
  800193:	b9 00 00 00 00       	mov    $0x0,%ecx
  800198:	ba 00 00 00 00       	mov    $0x0,%edx
  80019d:	b8 0b 00 00 00       	mov    $0xb,%eax
  8001a2:	e8 01 ff ff ff       	call   8000a8 <syscall>
  8001a7:	83 c4 10             	add    $0x10,%esp
}
  8001aa:	c9                   	leave  
  8001ab:	c3                   	ret    

008001ac <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  8001ac:	55                   	push   %ebp
  8001ad:	89 e5                	mov    %esp,%ebp
  8001af:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
  8001b2:	6a 00                	push   $0x0
  8001b4:	6a 00                	push   $0x0
  8001b6:	ff 75 10             	pushl  0x10(%ebp)
  8001b9:	ff 75 0c             	pushl  0xc(%ebp)
  8001bc:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8001bf:	ba 01 00 00 00       	mov    $0x1,%edx
  8001c4:	b8 04 00 00 00       	mov    $0x4,%eax
  8001c9:	e8 da fe ff ff       	call   8000a8 <syscall>
}
  8001ce:	c9                   	leave  
  8001cf:	c3                   	ret    

008001d0 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8001d0:	55                   	push   %ebp
  8001d1:	89 e5                	mov    %esp,%ebp
  8001d3:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
  8001d6:	ff 75 18             	pushl  0x18(%ebp)
  8001d9:	ff 75 14             	pushl  0x14(%ebp)
  8001dc:	ff 75 10             	pushl  0x10(%ebp)
  8001df:	ff 75 0c             	pushl  0xc(%ebp)
  8001e2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8001e5:	ba 01 00 00 00       	mov    $0x1,%edx
  8001ea:	b8 05 00 00 00       	mov    $0x5,%eax
  8001ef:	e8 b4 fe ff ff       	call   8000a8 <syscall>
}
  8001f4:	c9                   	leave  
  8001f5:	c3                   	ret    

008001f6 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  8001f6:	55                   	push   %ebp
  8001f7:	89 e5                	mov    %esp,%ebp
  8001f9:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
  8001fc:	6a 00                	push   $0x0
  8001fe:	6a 00                	push   $0x0
  800200:	6a 00                	push   $0x0
  800202:	ff 75 0c             	pushl  0xc(%ebp)
  800205:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800208:	ba 01 00 00 00       	mov    $0x1,%edx
  80020d:	b8 06 00 00 00       	mov    $0x6,%eax
  800212:	e8 91 fe ff ff       	call   8000a8 <syscall>
}
  800217:	c9                   	leave  
  800218:	c3                   	ret    

00800219 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800219:	55                   	push   %ebp
  80021a:	89 e5                	mov    %esp,%ebp
  80021c:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
  80021f:	6a 00                	push   $0x0
  800221:	6a 00                	push   $0x0
  800223:	6a 00                	push   $0x0
  800225:	ff 75 0c             	pushl  0xc(%ebp)
  800228:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80022b:	ba 01 00 00 00       	mov    $0x1,%edx
  800230:	b8 08 00 00 00       	mov    $0x8,%eax
  800235:	e8 6e fe ff ff       	call   8000a8 <syscall>
}
  80023a:	c9                   	leave  
  80023b:	c3                   	ret    

0080023c <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  80023c:	55                   	push   %ebp
  80023d:	89 e5                	mov    %esp,%ebp
  80023f:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
  800242:	6a 00                	push   $0x0
  800244:	6a 00                	push   $0x0
  800246:	6a 00                	push   $0x0
  800248:	ff 75 0c             	pushl  0xc(%ebp)
  80024b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80024e:	ba 01 00 00 00       	mov    $0x1,%edx
  800253:	b8 09 00 00 00       	mov    $0x9,%eax
  800258:	e8 4b fe ff ff       	call   8000a8 <syscall>
}
  80025d:	c9                   	leave  
  80025e:	c3                   	ret    

0080025f <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  80025f:	55                   	push   %ebp
  800260:	89 e5                	mov    %esp,%ebp
  800262:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
  800265:	6a 00                	push   $0x0
  800267:	6a 00                	push   $0x0
  800269:	6a 00                	push   $0x0
  80026b:	ff 75 0c             	pushl  0xc(%ebp)
  80026e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800271:	ba 01 00 00 00       	mov    $0x1,%edx
  800276:	b8 0a 00 00 00       	mov    $0xa,%eax
  80027b:	e8 28 fe ff ff       	call   8000a8 <syscall>
}
  800280:	c9                   	leave  
  800281:	c3                   	ret    

00800282 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800282:	55                   	push   %ebp
  800283:	89 e5                	mov    %esp,%ebp
  800285:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
  800288:	6a 00                	push   $0x0
  80028a:	ff 75 14             	pushl  0x14(%ebp)
  80028d:	ff 75 10             	pushl  0x10(%ebp)
  800290:	ff 75 0c             	pushl  0xc(%ebp)
  800293:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800296:	ba 00 00 00 00       	mov    $0x0,%edx
  80029b:	b8 0c 00 00 00       	mov    $0xc,%eax
  8002a0:	e8 03 fe ff ff       	call   8000a8 <syscall>
}
  8002a5:	c9                   	leave  
  8002a6:	c3                   	ret    

008002a7 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  8002a7:	55                   	push   %ebp
  8002a8:	89 e5                	mov    %esp,%ebp
  8002aa:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
  8002ad:	6a 00                	push   $0x0
  8002af:	6a 00                	push   $0x0
  8002b1:	6a 00                	push   $0x0
  8002b3:	6a 00                	push   $0x0
  8002b5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8002b8:	ba 01 00 00 00       	mov    $0x1,%edx
  8002bd:	b8 0d 00 00 00       	mov    $0xd,%eax
  8002c2:	e8 e1 fd ff ff       	call   8000a8 <syscall>
}
  8002c7:	c9                   	leave  
  8002c8:	c3                   	ret    

008002c9 <sys_set_priority>:

int
sys_set_priority(envid_t envid, uint32_t new_priority)
{
  8002c9:	55                   	push   %ebp
  8002ca:	89 e5                	mov    %esp,%ebp
  8002cc:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_set_priority, 0, envid, new_priority, 0, 0, 0);
  8002cf:	6a 00                	push   $0x0
  8002d1:	6a 00                	push   $0x0
  8002d3:	6a 00                	push   $0x0
  8002d5:	ff 75 0c             	pushl  0xc(%ebp)
  8002d8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8002db:	ba 00 00 00 00       	mov    $0x0,%edx
  8002e0:	b8 0e 00 00 00       	mov    $0xe,%eax
  8002e5:	e8 be fd ff ff       	call   8000a8 <syscall>
}
  8002ea:	c9                   	leave  
  8002eb:	c3                   	ret    

008002ec <sys_exec>:

int
sys_exec(uint32_t eip, uint32_t esp, void * ph, uint32_t elf_phnum)
{
  8002ec:	55                   	push   %ebp
  8002ed:	89 e5                	mov    %esp,%ebp
  8002ef:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_exec, 0, eip, esp, (uint32_t)ph, elf_phnum, 0);
  8002f2:	6a 00                	push   $0x0
  8002f4:	ff 75 14             	pushl  0x14(%ebp)
  8002f7:	ff 75 10             	pushl  0x10(%ebp)
  8002fa:	ff 75 0c             	pushl  0xc(%ebp)
  8002fd:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800300:	ba 00 00 00 00       	mov    $0x0,%edx
  800305:	b8 0f 00 00 00       	mov    $0xf,%eax
  80030a:	e8 99 fd ff ff       	call   8000a8 <syscall>
} 
  80030f:	c9                   	leave  
  800310:	c3                   	ret    

00800311 <sys_join>:

// thread:
int
sys_join(envid_t envid)
{
  800311:	55                   	push   %ebp
  800312:	89 e5                	mov    %esp,%ebp
  800314:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_join, 0, envid, 0, 0, 0, 0);
  800317:	6a 00                	push   $0x0
  800319:	6a 00                	push   $0x0
  80031b:	6a 00                	push   $0x0
  80031d:	6a 00                	push   $0x0
  80031f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800322:	ba 00 00 00 00       	mov    $0x0,%edx
  800327:	b8 11 00 00 00       	mov    $0x11,%eax
  80032c:	e8 77 fd ff ff       	call   8000a8 <syscall>
}
  800331:	c9                   	leave  
  800332:	c3                   	ret    

00800333 <sys_getpid>:

envid_t
sys_getpid(void)
{
  800333:	55                   	push   %ebp
  800334:	89 e5                	mov    %esp,%ebp
  800336:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_getpid, 0, 0, 0, 0, 0, 0);
  800339:	6a 00                	push   $0x0
  80033b:	6a 00                	push   $0x0
  80033d:	6a 00                	push   $0x0
  80033f:	6a 00                	push   $0x0
  800341:	b9 00 00 00 00       	mov    $0x0,%ecx
  800346:	ba 00 00 00 00       	mov    $0x0,%edx
  80034b:	b8 10 00 00 00       	mov    $0x10,%eax
  800350:	e8 53 fd ff ff       	call   8000a8 <syscall>
  800355:	c9                   	leave  
  800356:	c3                   	ret    
	...

00800358 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800358:	55                   	push   %ebp
  800359:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80035b:	8b 45 08             	mov    0x8(%ebp),%eax
  80035e:	05 00 00 00 30       	add    $0x30000000,%eax
  800363:	c1 e8 0c             	shr    $0xc,%eax
}
  800366:	c9                   	leave  
  800367:	c3                   	ret    

00800368 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800368:	55                   	push   %ebp
  800369:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  80036b:	ff 75 08             	pushl  0x8(%ebp)
  80036e:	e8 e5 ff ff ff       	call   800358 <fd2num>
  800373:	83 c4 04             	add    $0x4,%esp
  800376:	05 20 00 0d 00       	add    $0xd0020,%eax
  80037b:	c1 e0 0c             	shl    $0xc,%eax
}
  80037e:	c9                   	leave  
  80037f:	c3                   	ret    

00800380 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800380:	55                   	push   %ebp
  800381:	89 e5                	mov    %esp,%ebp
  800383:	53                   	push   %ebx
  800384:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800387:	a1 00 dd 7b ef       	mov    0xef7bdd00,%eax
  80038c:	a8 01                	test   $0x1,%al
  80038e:	74 34                	je     8003c4 <fd_alloc+0x44>
  800390:	a1 00 00 74 ef       	mov    0xef740000,%eax
  800395:	a8 01                	test   $0x1,%al
  800397:	74 32                	je     8003cb <fd_alloc+0x4b>
  800399:	b8 00 10 00 d0       	mov    $0xd0001000,%eax
  80039e:	89 c1                	mov    %eax,%ecx
  8003a0:	89 c2                	mov    %eax,%edx
  8003a2:	c1 ea 16             	shr    $0x16,%edx
  8003a5:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8003ac:	f6 c2 01             	test   $0x1,%dl
  8003af:	74 1f                	je     8003d0 <fd_alloc+0x50>
  8003b1:	89 c2                	mov    %eax,%edx
  8003b3:	c1 ea 0c             	shr    $0xc,%edx
  8003b6:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8003bd:	f6 c2 01             	test   $0x1,%dl
  8003c0:	75 17                	jne    8003d9 <fd_alloc+0x59>
  8003c2:	eb 0c                	jmp    8003d0 <fd_alloc+0x50>
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  8003c4:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
  8003c9:	eb 05                	jmp    8003d0 <fd_alloc+0x50>
  8003cb:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
  8003d0:	89 0b                	mov    %ecx,(%ebx)
			return 0;
  8003d2:	b8 00 00 00 00       	mov    $0x0,%eax
  8003d7:	eb 17                	jmp    8003f0 <fd_alloc+0x70>
  8003d9:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8003de:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8003e3:	75 b9                	jne    80039e <fd_alloc+0x1e>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8003e5:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_MAX_OPEN;
  8003eb:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8003f0:	5b                   	pop    %ebx
  8003f1:	c9                   	leave  
  8003f2:	c3                   	ret    

008003f3 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8003f3:	55                   	push   %ebp
  8003f4:	89 e5                	mov    %esp,%ebp
  8003f6:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8003f9:	83 f8 1f             	cmp    $0x1f,%eax
  8003fc:	77 36                	ja     800434 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8003fe:	05 00 00 0d 00       	add    $0xd0000,%eax
  800403:	c1 e0 0c             	shl    $0xc,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800406:	89 c2                	mov    %eax,%edx
  800408:	c1 ea 16             	shr    $0x16,%edx
  80040b:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800412:	f6 c2 01             	test   $0x1,%dl
  800415:	74 24                	je     80043b <fd_lookup+0x48>
  800417:	89 c2                	mov    %eax,%edx
  800419:	c1 ea 0c             	shr    $0xc,%edx
  80041c:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800423:	f6 c2 01             	test   $0x1,%dl
  800426:	74 1a                	je     800442 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800428:	8b 55 0c             	mov    0xc(%ebp),%edx
  80042b:	89 02                	mov    %eax,(%edx)
	return 0;
  80042d:	b8 00 00 00 00       	mov    $0x0,%eax
  800432:	eb 13                	jmp    800447 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800434:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800439:	eb 0c                	jmp    800447 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80043b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800440:	eb 05                	jmp    800447 <fd_lookup+0x54>
  800442:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800447:	c9                   	leave  
  800448:	c3                   	ret    

00800449 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800449:	55                   	push   %ebp
  80044a:	89 e5                	mov    %esp,%ebp
  80044c:	53                   	push   %ebx
  80044d:	83 ec 04             	sub    $0x4,%esp
  800450:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800453:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
		if (devtab[i]->dev_id == dev_id) {
  800456:	39 0d 04 30 80 00    	cmp    %ecx,0x803004
  80045c:	74 0d                	je     80046b <dev_lookup+0x22>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  80045e:	b8 00 00 00 00       	mov    $0x0,%eax
  800463:	eb 14                	jmp    800479 <dev_lookup+0x30>
		if (devtab[i]->dev_id == dev_id) {
  800465:	39 0a                	cmp    %ecx,(%edx)
  800467:	75 10                	jne    800479 <dev_lookup+0x30>
  800469:	eb 05                	jmp    800470 <dev_lookup+0x27>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  80046b:	ba 04 30 80 00       	mov    $0x803004,%edx
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
  800470:	89 13                	mov    %edx,(%ebx)
			return 0;
  800472:	b8 00 00 00 00       	mov    $0x0,%eax
  800477:	eb 31                	jmp    8004aa <dev_lookup+0x61>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800479:	40                   	inc    %eax
  80047a:	8b 14 85 74 1e 80 00 	mov    0x801e74(,%eax,4),%edx
  800481:	85 d2                	test   %edx,%edx
  800483:	75 e0                	jne    800465 <dev_lookup+0x1c>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800485:	a1 04 40 80 00       	mov    0x804004,%eax
  80048a:	8b 40 48             	mov    0x48(%eax),%eax
  80048d:	83 ec 04             	sub    $0x4,%esp
  800490:	51                   	push   %ecx
  800491:	50                   	push   %eax
  800492:	68 f8 1d 80 00       	push   $0x801df8
  800497:	e8 48 0c 00 00       	call   8010e4 <cprintf>
	*dev = 0;
  80049c:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_INVAL;
  8004a2:	83 c4 10             	add    $0x10,%esp
  8004a5:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8004aa:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8004ad:	c9                   	leave  
  8004ae:	c3                   	ret    

008004af <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8004af:	55                   	push   %ebp
  8004b0:	89 e5                	mov    %esp,%ebp
  8004b2:	56                   	push   %esi
  8004b3:	53                   	push   %ebx
  8004b4:	83 ec 20             	sub    $0x20,%esp
  8004b7:	8b 75 08             	mov    0x8(%ebp),%esi
  8004ba:	8a 45 0c             	mov    0xc(%ebp),%al
  8004bd:	88 45 e7             	mov    %al,-0x19(%ebp)
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8004c0:	56                   	push   %esi
  8004c1:	e8 92 fe ff ff       	call   800358 <fd2num>
  8004c6:	8d 55 f4             	lea    -0xc(%ebp),%edx
  8004c9:	89 14 24             	mov    %edx,(%esp)
  8004cc:	50                   	push   %eax
  8004cd:	e8 21 ff ff ff       	call   8003f3 <fd_lookup>
  8004d2:	89 c3                	mov    %eax,%ebx
  8004d4:	83 c4 08             	add    $0x8,%esp
  8004d7:	85 c0                	test   %eax,%eax
  8004d9:	78 05                	js     8004e0 <fd_close+0x31>
	    || fd != fd2)
  8004db:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8004de:	74 0d                	je     8004ed <fd_close+0x3e>
		return (must_exist ? r : 0);
  8004e0:	80 7d e7 00          	cmpb   $0x0,-0x19(%ebp)
  8004e4:	75 48                	jne    80052e <fd_close+0x7f>
  8004e6:	bb 00 00 00 00       	mov    $0x0,%ebx
  8004eb:	eb 41                	jmp    80052e <fd_close+0x7f>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8004ed:	83 ec 08             	sub    $0x8,%esp
  8004f0:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8004f3:	50                   	push   %eax
  8004f4:	ff 36                	pushl  (%esi)
  8004f6:	e8 4e ff ff ff       	call   800449 <dev_lookup>
  8004fb:	89 c3                	mov    %eax,%ebx
  8004fd:	83 c4 10             	add    $0x10,%esp
  800500:	85 c0                	test   %eax,%eax
  800502:	78 1c                	js     800520 <fd_close+0x71>
		if (dev->dev_close)
  800504:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800507:	8b 40 10             	mov    0x10(%eax),%eax
  80050a:	85 c0                	test   %eax,%eax
  80050c:	74 0d                	je     80051b <fd_close+0x6c>
			r = (*dev->dev_close)(fd);
  80050e:	83 ec 0c             	sub    $0xc,%esp
  800511:	56                   	push   %esi
  800512:	ff d0                	call   *%eax
  800514:	89 c3                	mov    %eax,%ebx
  800516:	83 c4 10             	add    $0x10,%esp
  800519:	eb 05                	jmp    800520 <fd_close+0x71>
		else
			r = 0;
  80051b:	bb 00 00 00 00       	mov    $0x0,%ebx
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  800520:	83 ec 08             	sub    $0x8,%esp
  800523:	56                   	push   %esi
  800524:	6a 00                	push   $0x0
  800526:	e8 cb fc ff ff       	call   8001f6 <sys_page_unmap>
	return r;
  80052b:	83 c4 10             	add    $0x10,%esp
}
  80052e:	89 d8                	mov    %ebx,%eax
  800530:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800533:	5b                   	pop    %ebx
  800534:	5e                   	pop    %esi
  800535:	c9                   	leave  
  800536:	c3                   	ret    

00800537 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  800537:	55                   	push   %ebp
  800538:	89 e5                	mov    %esp,%ebp
  80053a:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80053d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800540:	50                   	push   %eax
  800541:	ff 75 08             	pushl  0x8(%ebp)
  800544:	e8 aa fe ff ff       	call   8003f3 <fd_lookup>
  800549:	83 c4 08             	add    $0x8,%esp
  80054c:	85 c0                	test   %eax,%eax
  80054e:	78 10                	js     800560 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  800550:	83 ec 08             	sub    $0x8,%esp
  800553:	6a 01                	push   $0x1
  800555:	ff 75 f4             	pushl  -0xc(%ebp)
  800558:	e8 52 ff ff ff       	call   8004af <fd_close>
  80055d:	83 c4 10             	add    $0x10,%esp
}
  800560:	c9                   	leave  
  800561:	c3                   	ret    

00800562 <close_all>:

void
close_all(void)
{
  800562:	55                   	push   %ebp
  800563:	89 e5                	mov    %esp,%ebp
  800565:	53                   	push   %ebx
  800566:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800569:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  80056e:	83 ec 0c             	sub    $0xc,%esp
  800571:	53                   	push   %ebx
  800572:	e8 c0 ff ff ff       	call   800537 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  800577:	43                   	inc    %ebx
  800578:	83 c4 10             	add    $0x10,%esp
  80057b:	83 fb 20             	cmp    $0x20,%ebx
  80057e:	75 ee                	jne    80056e <close_all+0xc>
		close(i);
}
  800580:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800583:	c9                   	leave  
  800584:	c3                   	ret    

00800585 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800585:	55                   	push   %ebp
  800586:	89 e5                	mov    %esp,%ebp
  800588:	57                   	push   %edi
  800589:	56                   	push   %esi
  80058a:	53                   	push   %ebx
  80058b:	83 ec 2c             	sub    $0x2c,%esp
  80058e:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  800591:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800594:	50                   	push   %eax
  800595:	ff 75 08             	pushl  0x8(%ebp)
  800598:	e8 56 fe ff ff       	call   8003f3 <fd_lookup>
  80059d:	89 c3                	mov    %eax,%ebx
  80059f:	83 c4 08             	add    $0x8,%esp
  8005a2:	85 c0                	test   %eax,%eax
  8005a4:	0f 88 c0 00 00 00    	js     80066a <dup+0xe5>
		return r;
	close(newfdnum);
  8005aa:	83 ec 0c             	sub    $0xc,%esp
  8005ad:	57                   	push   %edi
  8005ae:	e8 84 ff ff ff       	call   800537 <close>

	newfd = INDEX2FD(newfdnum);
  8005b3:	8d b7 00 00 0d 00    	lea    0xd0000(%edi),%esi
  8005b9:	c1 e6 0c             	shl    $0xc,%esi
	ova = fd2data(oldfd);
  8005bc:	83 c4 04             	add    $0x4,%esp
  8005bf:	ff 75 e4             	pushl  -0x1c(%ebp)
  8005c2:	e8 a1 fd ff ff       	call   800368 <fd2data>
  8005c7:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  8005c9:	89 34 24             	mov    %esi,(%esp)
  8005cc:	e8 97 fd ff ff       	call   800368 <fd2data>
  8005d1:	83 c4 10             	add    $0x10,%esp
  8005d4:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8005d7:	89 d8                	mov    %ebx,%eax
  8005d9:	c1 e8 16             	shr    $0x16,%eax
  8005dc:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8005e3:	a8 01                	test   $0x1,%al
  8005e5:	74 37                	je     80061e <dup+0x99>
  8005e7:	89 d8                	mov    %ebx,%eax
  8005e9:	c1 e8 0c             	shr    $0xc,%eax
  8005ec:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8005f3:	f6 c2 01             	test   $0x1,%dl
  8005f6:	74 26                	je     80061e <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8005f8:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8005ff:	83 ec 0c             	sub    $0xc,%esp
  800602:	25 07 0e 00 00       	and    $0xe07,%eax
  800607:	50                   	push   %eax
  800608:	ff 75 d4             	pushl  -0x2c(%ebp)
  80060b:	6a 00                	push   $0x0
  80060d:	53                   	push   %ebx
  80060e:	6a 00                	push   $0x0
  800610:	e8 bb fb ff ff       	call   8001d0 <sys_page_map>
  800615:	89 c3                	mov    %eax,%ebx
  800617:	83 c4 20             	add    $0x20,%esp
  80061a:	85 c0                	test   %eax,%eax
  80061c:	78 2d                	js     80064b <dup+0xc6>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80061e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800621:	89 c2                	mov    %eax,%edx
  800623:	c1 ea 0c             	shr    $0xc,%edx
  800626:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80062d:	83 ec 0c             	sub    $0xc,%esp
  800630:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  800636:	52                   	push   %edx
  800637:	56                   	push   %esi
  800638:	6a 00                	push   $0x0
  80063a:	50                   	push   %eax
  80063b:	6a 00                	push   $0x0
  80063d:	e8 8e fb ff ff       	call   8001d0 <sys_page_map>
  800642:	89 c3                	mov    %eax,%ebx
  800644:	83 c4 20             	add    $0x20,%esp
  800647:	85 c0                	test   %eax,%eax
  800649:	79 1d                	jns    800668 <dup+0xe3>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  80064b:	83 ec 08             	sub    $0x8,%esp
  80064e:	56                   	push   %esi
  80064f:	6a 00                	push   $0x0
  800651:	e8 a0 fb ff ff       	call   8001f6 <sys_page_unmap>
	sys_page_unmap(0, nva);
  800656:	83 c4 08             	add    $0x8,%esp
  800659:	ff 75 d4             	pushl  -0x2c(%ebp)
  80065c:	6a 00                	push   $0x0
  80065e:	e8 93 fb ff ff       	call   8001f6 <sys_page_unmap>
	return r;
  800663:	83 c4 10             	add    $0x10,%esp
  800666:	eb 02                	jmp    80066a <dup+0xe5>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
		goto err;

	return newfdnum;
  800668:	89 fb                	mov    %edi,%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  80066a:	89 d8                	mov    %ebx,%eax
  80066c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80066f:	5b                   	pop    %ebx
  800670:	5e                   	pop    %esi
  800671:	5f                   	pop    %edi
  800672:	c9                   	leave  
  800673:	c3                   	ret    

00800674 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  800674:	55                   	push   %ebp
  800675:	89 e5                	mov    %esp,%ebp
  800677:	53                   	push   %ebx
  800678:	83 ec 14             	sub    $0x14,%esp
  80067b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80067e:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800681:	50                   	push   %eax
  800682:	53                   	push   %ebx
  800683:	e8 6b fd ff ff       	call   8003f3 <fd_lookup>
  800688:	83 c4 08             	add    $0x8,%esp
  80068b:	85 c0                	test   %eax,%eax
  80068d:	78 67                	js     8006f6 <read+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80068f:	83 ec 08             	sub    $0x8,%esp
  800692:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800695:	50                   	push   %eax
  800696:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800699:	ff 30                	pushl  (%eax)
  80069b:	e8 a9 fd ff ff       	call   800449 <dev_lookup>
  8006a0:	83 c4 10             	add    $0x10,%esp
  8006a3:	85 c0                	test   %eax,%eax
  8006a5:	78 4f                	js     8006f6 <read+0x82>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8006a7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8006aa:	8b 50 08             	mov    0x8(%eax),%edx
  8006ad:	83 e2 03             	and    $0x3,%edx
  8006b0:	83 fa 01             	cmp    $0x1,%edx
  8006b3:	75 21                	jne    8006d6 <read+0x62>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8006b5:	a1 04 40 80 00       	mov    0x804004,%eax
  8006ba:	8b 40 48             	mov    0x48(%eax),%eax
  8006bd:	83 ec 04             	sub    $0x4,%esp
  8006c0:	53                   	push   %ebx
  8006c1:	50                   	push   %eax
  8006c2:	68 39 1e 80 00       	push   $0x801e39
  8006c7:	e8 18 0a 00 00       	call   8010e4 <cprintf>
		return -E_INVAL;
  8006cc:	83 c4 10             	add    $0x10,%esp
  8006cf:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8006d4:	eb 20                	jmp    8006f6 <read+0x82>
	}
	if (!dev->dev_read)
  8006d6:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8006d9:	8b 52 08             	mov    0x8(%edx),%edx
  8006dc:	85 d2                	test   %edx,%edx
  8006de:	74 11                	je     8006f1 <read+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8006e0:	83 ec 04             	sub    $0x4,%esp
  8006e3:	ff 75 10             	pushl  0x10(%ebp)
  8006e6:	ff 75 0c             	pushl  0xc(%ebp)
  8006e9:	50                   	push   %eax
  8006ea:	ff d2                	call   *%edx
  8006ec:	83 c4 10             	add    $0x10,%esp
  8006ef:	eb 05                	jmp    8006f6 <read+0x82>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8006f1:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_read)(fd, buf, n);
}
  8006f6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8006f9:	c9                   	leave  
  8006fa:	c3                   	ret    

008006fb <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8006fb:	55                   	push   %ebp
  8006fc:	89 e5                	mov    %esp,%ebp
  8006fe:	57                   	push   %edi
  8006ff:	56                   	push   %esi
  800700:	53                   	push   %ebx
  800701:	83 ec 0c             	sub    $0xc,%esp
  800704:	8b 7d 08             	mov    0x8(%ebp),%edi
  800707:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80070a:	85 f6                	test   %esi,%esi
  80070c:	74 31                	je     80073f <readn+0x44>
  80070e:	b8 00 00 00 00       	mov    $0x0,%eax
  800713:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = read(fdnum, (char*)buf + tot, n - tot);
  800718:	83 ec 04             	sub    $0x4,%esp
  80071b:	89 f2                	mov    %esi,%edx
  80071d:	29 c2                	sub    %eax,%edx
  80071f:	52                   	push   %edx
  800720:	03 45 0c             	add    0xc(%ebp),%eax
  800723:	50                   	push   %eax
  800724:	57                   	push   %edi
  800725:	e8 4a ff ff ff       	call   800674 <read>
		if (m < 0)
  80072a:	83 c4 10             	add    $0x10,%esp
  80072d:	85 c0                	test   %eax,%eax
  80072f:	78 17                	js     800748 <readn+0x4d>
			return m;
		if (m == 0)
  800731:	85 c0                	test   %eax,%eax
  800733:	74 11                	je     800746 <readn+0x4b>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  800735:	01 c3                	add    %eax,%ebx
  800737:	89 d8                	mov    %ebx,%eax
  800739:	39 f3                	cmp    %esi,%ebx
  80073b:	72 db                	jb     800718 <readn+0x1d>
  80073d:	eb 09                	jmp    800748 <readn+0x4d>
  80073f:	b8 00 00 00 00       	mov    $0x0,%eax
  800744:	eb 02                	jmp    800748 <readn+0x4d>
		m = read(fdnum, (char*)buf + tot, n - tot);
		if (m < 0)
			return m;
		if (m == 0)
  800746:	89 d8                	mov    %ebx,%eax
			break;
	}
	return tot;
}
  800748:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80074b:	5b                   	pop    %ebx
  80074c:	5e                   	pop    %esi
  80074d:	5f                   	pop    %edi
  80074e:	c9                   	leave  
  80074f:	c3                   	ret    

00800750 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  800750:	55                   	push   %ebp
  800751:	89 e5                	mov    %esp,%ebp
  800753:	53                   	push   %ebx
  800754:	83 ec 14             	sub    $0x14,%esp
  800757:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80075a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80075d:	50                   	push   %eax
  80075e:	53                   	push   %ebx
  80075f:	e8 8f fc ff ff       	call   8003f3 <fd_lookup>
  800764:	83 c4 08             	add    $0x8,%esp
  800767:	85 c0                	test   %eax,%eax
  800769:	78 62                	js     8007cd <write+0x7d>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80076b:	83 ec 08             	sub    $0x8,%esp
  80076e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800771:	50                   	push   %eax
  800772:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800775:	ff 30                	pushl  (%eax)
  800777:	e8 cd fc ff ff       	call   800449 <dev_lookup>
  80077c:	83 c4 10             	add    $0x10,%esp
  80077f:	85 c0                	test   %eax,%eax
  800781:	78 4a                	js     8007cd <write+0x7d>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800783:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800786:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80078a:	75 21                	jne    8007ad <write+0x5d>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  80078c:	a1 04 40 80 00       	mov    0x804004,%eax
  800791:	8b 40 48             	mov    0x48(%eax),%eax
  800794:	83 ec 04             	sub    $0x4,%esp
  800797:	53                   	push   %ebx
  800798:	50                   	push   %eax
  800799:	68 55 1e 80 00       	push   $0x801e55
  80079e:	e8 41 09 00 00       	call   8010e4 <cprintf>
		return -E_INVAL;
  8007a3:	83 c4 10             	add    $0x10,%esp
  8007a6:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8007ab:	eb 20                	jmp    8007cd <write+0x7d>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8007ad:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8007b0:	8b 52 0c             	mov    0xc(%edx),%edx
  8007b3:	85 d2                	test   %edx,%edx
  8007b5:	74 11                	je     8007c8 <write+0x78>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8007b7:	83 ec 04             	sub    $0x4,%esp
  8007ba:	ff 75 10             	pushl  0x10(%ebp)
  8007bd:	ff 75 0c             	pushl  0xc(%ebp)
  8007c0:	50                   	push   %eax
  8007c1:	ff d2                	call   *%edx
  8007c3:	83 c4 10             	add    $0x10,%esp
  8007c6:	eb 05                	jmp    8007cd <write+0x7d>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8007c8:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  8007cd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007d0:	c9                   	leave  
  8007d1:	c3                   	ret    

008007d2 <seek>:

int
seek(int fdnum, off_t offset)
{
  8007d2:	55                   	push   %ebp
  8007d3:	89 e5                	mov    %esp,%ebp
  8007d5:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8007d8:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8007db:	50                   	push   %eax
  8007dc:	ff 75 08             	pushl  0x8(%ebp)
  8007df:	e8 0f fc ff ff       	call   8003f3 <fd_lookup>
  8007e4:	83 c4 08             	add    $0x8,%esp
  8007e7:	85 c0                	test   %eax,%eax
  8007e9:	78 0e                	js     8007f9 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8007eb:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8007ee:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007f1:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8007f4:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8007f9:	c9                   	leave  
  8007fa:	c3                   	ret    

008007fb <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8007fb:	55                   	push   %ebp
  8007fc:	89 e5                	mov    %esp,%ebp
  8007fe:	53                   	push   %ebx
  8007ff:	83 ec 14             	sub    $0x14,%esp
  800802:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  800805:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800808:	50                   	push   %eax
  800809:	53                   	push   %ebx
  80080a:	e8 e4 fb ff ff       	call   8003f3 <fd_lookup>
  80080f:	83 c4 08             	add    $0x8,%esp
  800812:	85 c0                	test   %eax,%eax
  800814:	78 5f                	js     800875 <ftruncate+0x7a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800816:	83 ec 08             	sub    $0x8,%esp
  800819:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80081c:	50                   	push   %eax
  80081d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800820:	ff 30                	pushl  (%eax)
  800822:	e8 22 fc ff ff       	call   800449 <dev_lookup>
  800827:	83 c4 10             	add    $0x10,%esp
  80082a:	85 c0                	test   %eax,%eax
  80082c:	78 47                	js     800875 <ftruncate+0x7a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80082e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800831:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  800835:	75 21                	jne    800858 <ftruncate+0x5d>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  800837:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  80083c:	8b 40 48             	mov    0x48(%eax),%eax
  80083f:	83 ec 04             	sub    $0x4,%esp
  800842:	53                   	push   %ebx
  800843:	50                   	push   %eax
  800844:	68 18 1e 80 00       	push   $0x801e18
  800849:	e8 96 08 00 00       	call   8010e4 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  80084e:	83 c4 10             	add    $0x10,%esp
  800851:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800856:	eb 1d                	jmp    800875 <ftruncate+0x7a>
	}
	if (!dev->dev_trunc)
  800858:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80085b:	8b 52 18             	mov    0x18(%edx),%edx
  80085e:	85 d2                	test   %edx,%edx
  800860:	74 0e                	je     800870 <ftruncate+0x75>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  800862:	83 ec 08             	sub    $0x8,%esp
  800865:	ff 75 0c             	pushl  0xc(%ebp)
  800868:	50                   	push   %eax
  800869:	ff d2                	call   *%edx
  80086b:	83 c4 10             	add    $0x10,%esp
  80086e:	eb 05                	jmp    800875 <ftruncate+0x7a>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  800870:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  800875:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800878:	c9                   	leave  
  800879:	c3                   	ret    

0080087a <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  80087a:	55                   	push   %ebp
  80087b:	89 e5                	mov    %esp,%ebp
  80087d:	53                   	push   %ebx
  80087e:	83 ec 14             	sub    $0x14,%esp
  800881:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800884:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800887:	50                   	push   %eax
  800888:	ff 75 08             	pushl  0x8(%ebp)
  80088b:	e8 63 fb ff ff       	call   8003f3 <fd_lookup>
  800890:	83 c4 08             	add    $0x8,%esp
  800893:	85 c0                	test   %eax,%eax
  800895:	78 52                	js     8008e9 <fstat+0x6f>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800897:	83 ec 08             	sub    $0x8,%esp
  80089a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80089d:	50                   	push   %eax
  80089e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8008a1:	ff 30                	pushl  (%eax)
  8008a3:	e8 a1 fb ff ff       	call   800449 <dev_lookup>
  8008a8:	83 c4 10             	add    $0x10,%esp
  8008ab:	85 c0                	test   %eax,%eax
  8008ad:	78 3a                	js     8008e9 <fstat+0x6f>
		return r;
	if (!dev->dev_stat)
  8008af:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8008b2:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8008b6:	74 2c                	je     8008e4 <fstat+0x6a>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8008b8:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8008bb:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8008c2:	00 00 00 
	stat->st_isdir = 0;
  8008c5:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8008cc:	00 00 00 
	stat->st_dev = dev;
  8008cf:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8008d5:	83 ec 08             	sub    $0x8,%esp
  8008d8:	53                   	push   %ebx
  8008d9:	ff 75 f0             	pushl  -0x10(%ebp)
  8008dc:	ff 50 14             	call   *0x14(%eax)
  8008df:	83 c4 10             	add    $0x10,%esp
  8008e2:	eb 05                	jmp    8008e9 <fstat+0x6f>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8008e4:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8008e9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8008ec:	c9                   	leave  
  8008ed:	c3                   	ret    

008008ee <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8008ee:	55                   	push   %ebp
  8008ef:	89 e5                	mov    %esp,%ebp
  8008f1:	56                   	push   %esi
  8008f2:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8008f3:	83 ec 08             	sub    $0x8,%esp
  8008f6:	6a 00                	push   $0x0
  8008f8:	ff 75 08             	pushl  0x8(%ebp)
  8008fb:	e8 78 01 00 00       	call   800a78 <open>
  800900:	89 c3                	mov    %eax,%ebx
  800902:	83 c4 10             	add    $0x10,%esp
  800905:	85 c0                	test   %eax,%eax
  800907:	78 1b                	js     800924 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  800909:	83 ec 08             	sub    $0x8,%esp
  80090c:	ff 75 0c             	pushl  0xc(%ebp)
  80090f:	50                   	push   %eax
  800910:	e8 65 ff ff ff       	call   80087a <fstat>
  800915:	89 c6                	mov    %eax,%esi
	close(fd);
  800917:	89 1c 24             	mov    %ebx,(%esp)
  80091a:	e8 18 fc ff ff       	call   800537 <close>
	return r;
  80091f:	83 c4 10             	add    $0x10,%esp
  800922:	89 f3                	mov    %esi,%ebx
}
  800924:	89 d8                	mov    %ebx,%eax
  800926:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800929:	5b                   	pop    %ebx
  80092a:	5e                   	pop    %esi
  80092b:	c9                   	leave  
  80092c:	c3                   	ret    
  80092d:	00 00                	add    %al,(%eax)
	...

00800930 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  800930:	55                   	push   %ebp
  800931:	89 e5                	mov    %esp,%ebp
  800933:	56                   	push   %esi
  800934:	53                   	push   %ebx
  800935:	89 c3                	mov    %eax,%ebx
  800937:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  800939:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  800940:	75 12                	jne    800954 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  800942:	83 ec 0c             	sub    $0xc,%esp
  800945:	6a 01                	push   $0x1
  800947:	e8 96 11 00 00       	call   801ae2 <ipc_find_env>
  80094c:	a3 00 40 80 00       	mov    %eax,0x804000
  800951:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  800954:	6a 07                	push   $0x7
  800956:	68 00 50 80 00       	push   $0x805000
  80095b:	53                   	push   %ebx
  80095c:	ff 35 00 40 80 00    	pushl  0x804000
  800962:	e8 26 11 00 00       	call   801a8d <ipc_send>
	
	return ipc_recv(NULL, dstva, NULL);
  800967:	83 c4 0c             	add    $0xc,%esp
  80096a:	6a 00                	push   $0x0
  80096c:	56                   	push   %esi
  80096d:	6a 00                	push   $0x0
  80096f:	e8 a4 10 00 00       	call   801a18 <ipc_recv>
}
  800974:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800977:	5b                   	pop    %ebx
  800978:	5e                   	pop    %esi
  800979:	c9                   	leave  
  80097a:	c3                   	ret    

0080097b <devfile_stat>:
}


static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  80097b:	55                   	push   %ebp
  80097c:	89 e5                	mov    %esp,%ebp
  80097e:	53                   	push   %ebx
  80097f:	83 ec 04             	sub    $0x4,%esp
  800982:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  800985:	8b 45 08             	mov    0x8(%ebp),%eax
  800988:	8b 40 0c             	mov    0xc(%eax),%eax
  80098b:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0) {
  800990:	ba 00 00 00 00       	mov    $0x0,%edx
  800995:	b8 05 00 00 00       	mov    $0x5,%eax
  80099a:	e8 91 ff ff ff       	call   800930 <fsipc>
  80099f:	85 c0                	test   %eax,%eax
  8009a1:	78 2c                	js     8009cf <devfile_stat+0x54>
		return r;
	}
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8009a3:	83 ec 08             	sub    $0x8,%esp
  8009a6:	68 00 50 80 00       	push   $0x805000
  8009ab:	53                   	push   %ebx
  8009ac:	e8 e9 0c 00 00       	call   80169a <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8009b1:	a1 80 50 80 00       	mov    0x805080,%eax
  8009b6:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8009bc:	a1 84 50 80 00       	mov    0x805084,%eax
  8009c1:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8009c7:	83 c4 10             	add    $0x10,%esp
  8009ca:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009cf:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8009d2:	c9                   	leave  
  8009d3:	c3                   	ret    

008009d4 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8009d4:	55                   	push   %ebp
  8009d5:	89 e5                	mov    %esp,%ebp
  8009d7:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8009da:	8b 45 08             	mov    0x8(%ebp),%eax
  8009dd:	8b 40 0c             	mov    0xc(%eax),%eax
  8009e0:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8009e5:	ba 00 00 00 00       	mov    $0x0,%edx
  8009ea:	b8 06 00 00 00       	mov    $0x6,%eax
  8009ef:	e8 3c ff ff ff       	call   800930 <fsipc>
}
  8009f4:	c9                   	leave  
  8009f5:	c3                   	ret    

008009f6 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  8009f6:	55                   	push   %ebp
  8009f7:	89 e5                	mov    %esp,%ebp
  8009f9:	56                   	push   %esi
  8009fa:	53                   	push   %ebx
  8009fb:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8009fe:	8b 45 08             	mov    0x8(%ebp),%eax
  800a01:	8b 40 0c             	mov    0xc(%eax),%eax
  800a04:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  800a09:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  800a0f:	ba 00 00 00 00       	mov    $0x0,%edx
  800a14:	b8 03 00 00 00       	mov    $0x3,%eax
  800a19:	e8 12 ff ff ff       	call   800930 <fsipc>
  800a1e:	89 c3                	mov    %eax,%ebx
  800a20:	85 c0                	test   %eax,%eax
  800a22:	78 4b                	js     800a6f <devfile_read+0x79>
		return r;
	assert(r <= n);
  800a24:	39 c6                	cmp    %eax,%esi
  800a26:	73 16                	jae    800a3e <devfile_read+0x48>
  800a28:	68 84 1e 80 00       	push   $0x801e84
  800a2d:	68 8b 1e 80 00       	push   $0x801e8b
  800a32:	6a 7d                	push   $0x7d
  800a34:	68 a0 1e 80 00       	push   $0x801ea0
  800a39:	e8 ce 05 00 00       	call   80100c <_panic>
	assert(r <= PGSIZE);
  800a3e:	3d 00 10 00 00       	cmp    $0x1000,%eax
  800a43:	7e 16                	jle    800a5b <devfile_read+0x65>
  800a45:	68 ab 1e 80 00       	push   $0x801eab
  800a4a:	68 8b 1e 80 00       	push   $0x801e8b
  800a4f:	6a 7e                	push   $0x7e
  800a51:	68 a0 1e 80 00       	push   $0x801ea0
  800a56:	e8 b1 05 00 00       	call   80100c <_panic>
	memmove(buf, &fsipcbuf, r);
  800a5b:	83 ec 04             	sub    $0x4,%esp
  800a5e:	50                   	push   %eax
  800a5f:	68 00 50 80 00       	push   $0x805000
  800a64:	ff 75 0c             	pushl  0xc(%ebp)
  800a67:	e8 ef 0d 00 00       	call   80185b <memmove>
	return r;
  800a6c:	83 c4 10             	add    $0x10,%esp
}
  800a6f:	89 d8                	mov    %ebx,%eax
  800a71:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800a74:	5b                   	pop    %ebx
  800a75:	5e                   	pop    %esi
  800a76:	c9                   	leave  
  800a77:	c3                   	ret    

00800a78 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  800a78:	55                   	push   %ebp
  800a79:	89 e5                	mov    %esp,%ebp
  800a7b:	56                   	push   %esi
  800a7c:	53                   	push   %ebx
  800a7d:	83 ec 1c             	sub    $0x1c,%esp
  800a80:	8b 75 08             	mov    0x8(%ebp),%esi
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  800a83:	56                   	push   %esi
  800a84:	e8 bf 0b 00 00       	call   801648 <strlen>
  800a89:	83 c4 10             	add    $0x10,%esp
  800a8c:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  800a91:	7f 65                	jg     800af8 <open+0x80>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800a93:	83 ec 0c             	sub    $0xc,%esp
  800a96:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800a99:	50                   	push   %eax
  800a9a:	e8 e1 f8 ff ff       	call   800380 <fd_alloc>
  800a9f:	89 c3                	mov    %eax,%ebx
  800aa1:	83 c4 10             	add    $0x10,%esp
  800aa4:	85 c0                	test   %eax,%eax
  800aa6:	78 55                	js     800afd <open+0x85>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  800aa8:	83 ec 08             	sub    $0x8,%esp
  800aab:	56                   	push   %esi
  800aac:	68 00 50 80 00       	push   $0x805000
  800ab1:	e8 e4 0b 00 00       	call   80169a <strcpy>
	fsipcbuf.open.req_omode = mode;
  800ab6:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ab9:	a3 00 54 80 00       	mov    %eax,0x805400



	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  800abe:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800ac1:	b8 01 00 00 00       	mov    $0x1,%eax
  800ac6:	e8 65 fe ff ff       	call   800930 <fsipc>
  800acb:	89 c3                	mov    %eax,%ebx
  800acd:	83 c4 10             	add    $0x10,%esp
  800ad0:	85 c0                	test   %eax,%eax
  800ad2:	79 12                	jns    800ae6 <open+0x6e>
		fd_close(fd, 0);
  800ad4:	83 ec 08             	sub    $0x8,%esp
  800ad7:	6a 00                	push   $0x0
  800ad9:	ff 75 f4             	pushl  -0xc(%ebp)
  800adc:	e8 ce f9 ff ff       	call   8004af <fd_close>
		return r;
  800ae1:	83 c4 10             	add    $0x10,%esp
  800ae4:	eb 17                	jmp    800afd <open+0x85>
	}

	return fd2num(fd);
  800ae6:	83 ec 0c             	sub    $0xc,%esp
  800ae9:	ff 75 f4             	pushl  -0xc(%ebp)
  800aec:	e8 67 f8 ff ff       	call   800358 <fd2num>
  800af1:	89 c3                	mov    %eax,%ebx
  800af3:	83 c4 10             	add    $0x10,%esp
  800af6:	eb 05                	jmp    800afd <open+0x85>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  800af8:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  800afd:	89 d8                	mov    %ebx,%eax
  800aff:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800b02:	5b                   	pop    %ebx
  800b03:	5e                   	pop    %esi
  800b04:	c9                   	leave  
  800b05:	c3                   	ret    
	...

00800b08 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  800b08:	55                   	push   %ebp
  800b09:	89 e5                	mov    %esp,%ebp
  800b0b:	56                   	push   %esi
  800b0c:	53                   	push   %ebx
  800b0d:	8b 75 0c             	mov    0xc(%ebp),%esi
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  800b10:	83 ec 0c             	sub    $0xc,%esp
  800b13:	ff 75 08             	pushl  0x8(%ebp)
  800b16:	e8 4d f8 ff ff       	call   800368 <fd2data>
  800b1b:	89 c3                	mov    %eax,%ebx
	strcpy(stat->st_name, "<pipe>");
  800b1d:	83 c4 08             	add    $0x8,%esp
  800b20:	68 b7 1e 80 00       	push   $0x801eb7
  800b25:	56                   	push   %esi
  800b26:	e8 6f 0b 00 00       	call   80169a <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  800b2b:	8b 43 04             	mov    0x4(%ebx),%eax
  800b2e:	2b 03                	sub    (%ebx),%eax
  800b30:	89 86 80 00 00 00    	mov    %eax,0x80(%esi)
	stat->st_isdir = 0;
  800b36:	c7 86 84 00 00 00 00 	movl   $0x0,0x84(%esi)
  800b3d:	00 00 00 
	stat->st_dev = &devpipe;
  800b40:	c7 86 88 00 00 00 20 	movl   $0x803020,0x88(%esi)
  800b47:	30 80 00 
	return 0;
}
  800b4a:	b8 00 00 00 00       	mov    $0x0,%eax
  800b4f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800b52:	5b                   	pop    %ebx
  800b53:	5e                   	pop    %esi
  800b54:	c9                   	leave  
  800b55:	c3                   	ret    

00800b56 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  800b56:	55                   	push   %ebp
  800b57:	89 e5                	mov    %esp,%ebp
  800b59:	53                   	push   %ebx
  800b5a:	83 ec 0c             	sub    $0xc,%esp
  800b5d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  800b60:	53                   	push   %ebx
  800b61:	6a 00                	push   $0x0
  800b63:	e8 8e f6 ff ff       	call   8001f6 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  800b68:	89 1c 24             	mov    %ebx,(%esp)
  800b6b:	e8 f8 f7 ff ff       	call   800368 <fd2data>
  800b70:	83 c4 08             	add    $0x8,%esp
  800b73:	50                   	push   %eax
  800b74:	6a 00                	push   $0x0
  800b76:	e8 7b f6 ff ff       	call   8001f6 <sys_page_unmap>
}
  800b7b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800b7e:	c9                   	leave  
  800b7f:	c3                   	ret    

00800b80 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  800b80:	55                   	push   %ebp
  800b81:	89 e5                	mov    %esp,%ebp
  800b83:	57                   	push   %edi
  800b84:	56                   	push   %esi
  800b85:	53                   	push   %ebx
  800b86:	83 ec 1c             	sub    $0x1c,%esp
  800b89:	89 c7                	mov    %eax,%edi
  800b8b:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  800b8e:	a1 04 40 80 00       	mov    0x804004,%eax
  800b93:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  800b96:	83 ec 0c             	sub    $0xc,%esp
  800b99:	57                   	push   %edi
  800b9a:	e8 91 0f 00 00       	call   801b30 <pageref>
  800b9f:	89 c6                	mov    %eax,%esi
  800ba1:	83 c4 04             	add    $0x4,%esp
  800ba4:	ff 75 e4             	pushl  -0x1c(%ebp)
  800ba7:	e8 84 0f 00 00       	call   801b30 <pageref>
  800bac:	83 c4 10             	add    $0x10,%esp
  800baf:	39 c6                	cmp    %eax,%esi
  800bb1:	0f 94 c0             	sete   %al
  800bb4:	0f b6 c0             	movzbl %al,%eax
		nn = thisenv->env_runs;
  800bb7:	8b 15 04 40 80 00    	mov    0x804004,%edx
  800bbd:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  800bc0:	39 cb                	cmp    %ecx,%ebx
  800bc2:	75 08                	jne    800bcc <_pipeisclosed+0x4c>
			return ret;
		if (n != nn && ret == 1)
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
	}
}
  800bc4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bc7:	5b                   	pop    %ebx
  800bc8:	5e                   	pop    %esi
  800bc9:	5f                   	pop    %edi
  800bca:	c9                   	leave  
  800bcb:	c3                   	ret    
		n = thisenv->env_runs;
		ret = pageref(fd) == pageref(p);
		nn = thisenv->env_runs;
		if (n == nn)
			return ret;
		if (n != nn && ret == 1)
  800bcc:	83 f8 01             	cmp    $0x1,%eax
  800bcf:	75 bd                	jne    800b8e <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  800bd1:	8b 42 58             	mov    0x58(%edx),%eax
  800bd4:	6a 01                	push   $0x1
  800bd6:	50                   	push   %eax
  800bd7:	53                   	push   %ebx
  800bd8:	68 be 1e 80 00       	push   $0x801ebe
  800bdd:	e8 02 05 00 00       	call   8010e4 <cprintf>
  800be2:	83 c4 10             	add    $0x10,%esp
  800be5:	eb a7                	jmp    800b8e <_pipeisclosed+0xe>

00800be7 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  800be7:	55                   	push   %ebp
  800be8:	89 e5                	mov    %esp,%ebp
  800bea:	57                   	push   %edi
  800beb:	56                   	push   %esi
  800bec:	53                   	push   %ebx
  800bed:	83 ec 28             	sub    $0x28,%esp
  800bf0:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  800bf3:	56                   	push   %esi
  800bf4:	e8 6f f7 ff ff       	call   800368 <fd2data>
  800bf9:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800bfb:	83 c4 10             	add    $0x10,%esp
  800bfe:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800c02:	75 4a                	jne    800c4e <devpipe_write+0x67>
  800c04:	bf 00 00 00 00       	mov    $0x0,%edi
  800c09:	eb 56                	jmp    800c61 <devpipe_write+0x7a>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  800c0b:	89 da                	mov    %ebx,%edx
  800c0d:	89 f0                	mov    %esi,%eax
  800c0f:	e8 6c ff ff ff       	call   800b80 <_pipeisclosed>
  800c14:	85 c0                	test   %eax,%eax
  800c16:	75 4d                	jne    800c65 <devpipe_write+0x7e>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  800c18:	e8 68 f5 ff ff       	call   800185 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  800c1d:	8b 43 04             	mov    0x4(%ebx),%eax
  800c20:	8b 13                	mov    (%ebx),%edx
  800c22:	83 c2 20             	add    $0x20,%edx
  800c25:	39 d0                	cmp    %edx,%eax
  800c27:	73 e2                	jae    800c0b <devpipe_write+0x24>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  800c29:	89 c2                	mov    %eax,%edx
  800c2b:	81 e2 1f 00 00 80    	and    $0x8000001f,%edx
  800c31:	79 05                	jns    800c38 <devpipe_write+0x51>
  800c33:	4a                   	dec    %edx
  800c34:	83 ca e0             	or     $0xffffffe0,%edx
  800c37:	42                   	inc    %edx
  800c38:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c3b:	8a 0c 39             	mov    (%ecx,%edi,1),%cl
  800c3e:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  800c42:	40                   	inc    %eax
  800c43:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800c46:	47                   	inc    %edi
  800c47:	39 7d 10             	cmp    %edi,0x10(%ebp)
  800c4a:	77 07                	ja     800c53 <devpipe_write+0x6c>
  800c4c:	eb 13                	jmp    800c61 <devpipe_write+0x7a>
  800c4e:	bf 00 00 00 00       	mov    $0x0,%edi
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  800c53:	8b 43 04             	mov    0x4(%ebx),%eax
  800c56:	8b 13                	mov    (%ebx),%edx
  800c58:	83 c2 20             	add    $0x20,%edx
  800c5b:	39 d0                	cmp    %edx,%eax
  800c5d:	73 ac                	jae    800c0b <devpipe_write+0x24>
  800c5f:	eb c8                	jmp    800c29 <devpipe_write+0x42>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  800c61:	89 f8                	mov    %edi,%eax
  800c63:	eb 05                	jmp    800c6a <devpipe_write+0x83>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  800c65:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  800c6a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c6d:	5b                   	pop    %ebx
  800c6e:	5e                   	pop    %esi
  800c6f:	5f                   	pop    %edi
  800c70:	c9                   	leave  
  800c71:	c3                   	ret    

00800c72 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  800c72:	55                   	push   %ebp
  800c73:	89 e5                	mov    %esp,%ebp
  800c75:	57                   	push   %edi
  800c76:	56                   	push   %esi
  800c77:	53                   	push   %ebx
  800c78:	83 ec 18             	sub    $0x18,%esp
  800c7b:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  800c7e:	57                   	push   %edi
  800c7f:	e8 e4 f6 ff ff       	call   800368 <fd2data>
  800c84:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800c86:	83 c4 10             	add    $0x10,%esp
  800c89:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800c8d:	75 44                	jne    800cd3 <devpipe_read+0x61>
  800c8f:	be 00 00 00 00       	mov    $0x0,%esi
  800c94:	eb 4f                	jmp    800ce5 <devpipe_read+0x73>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
				return i;
  800c96:	89 f0                	mov    %esi,%eax
  800c98:	eb 54                	jmp    800cee <devpipe_read+0x7c>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  800c9a:	89 da                	mov    %ebx,%edx
  800c9c:	89 f8                	mov    %edi,%eax
  800c9e:	e8 dd fe ff ff       	call   800b80 <_pipeisclosed>
  800ca3:	85 c0                	test   %eax,%eax
  800ca5:	75 42                	jne    800ce9 <devpipe_read+0x77>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  800ca7:	e8 d9 f4 ff ff       	call   800185 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  800cac:	8b 03                	mov    (%ebx),%eax
  800cae:	3b 43 04             	cmp    0x4(%ebx),%eax
  800cb1:	74 e7                	je     800c9a <devpipe_read+0x28>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  800cb3:	25 1f 00 00 80       	and    $0x8000001f,%eax
  800cb8:	79 05                	jns    800cbf <devpipe_read+0x4d>
  800cba:	48                   	dec    %eax
  800cbb:	83 c8 e0             	or     $0xffffffe0,%eax
  800cbe:	40                   	inc    %eax
  800cbf:	8a 44 03 08          	mov    0x8(%ebx,%eax,1),%al
  800cc3:	8b 55 0c             	mov    0xc(%ebp),%edx
  800cc6:	88 04 32             	mov    %al,(%edx,%esi,1)
		p->p_rpos++;
  800cc9:	ff 03                	incl   (%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800ccb:	46                   	inc    %esi
  800ccc:	39 75 10             	cmp    %esi,0x10(%ebp)
  800ccf:	77 07                	ja     800cd8 <devpipe_read+0x66>
  800cd1:	eb 12                	jmp    800ce5 <devpipe_read+0x73>
  800cd3:	be 00 00 00 00       	mov    $0x0,%esi
		while (p->p_rpos == p->p_wpos) {
  800cd8:	8b 03                	mov    (%ebx),%eax
  800cda:	3b 43 04             	cmp    0x4(%ebx),%eax
  800cdd:	75 d4                	jne    800cb3 <devpipe_read+0x41>
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  800cdf:	85 f6                	test   %esi,%esi
  800ce1:	75 b3                	jne    800c96 <devpipe_read+0x24>
  800ce3:	eb b5                	jmp    800c9a <devpipe_read+0x28>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  800ce5:	89 f0                	mov    %esi,%eax
  800ce7:	eb 05                	jmp    800cee <devpipe_read+0x7c>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  800ce9:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  800cee:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cf1:	5b                   	pop    %ebx
  800cf2:	5e                   	pop    %esi
  800cf3:	5f                   	pop    %edi
  800cf4:	c9                   	leave  
  800cf5:	c3                   	ret    

00800cf6 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  800cf6:	55                   	push   %ebp
  800cf7:	89 e5                	mov    %esp,%ebp
  800cf9:	57                   	push   %edi
  800cfa:	56                   	push   %esi
  800cfb:	53                   	push   %ebx
  800cfc:	83 ec 28             	sub    $0x28,%esp
  800cff:	8b 7d 08             	mov    0x8(%ebp),%edi
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  800d02:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800d05:	50                   	push   %eax
  800d06:	e8 75 f6 ff ff       	call   800380 <fd_alloc>
  800d0b:	89 c3                	mov    %eax,%ebx
  800d0d:	83 c4 10             	add    $0x10,%esp
  800d10:	85 c0                	test   %eax,%eax
  800d12:	0f 88 24 01 00 00    	js     800e3c <pipe+0x146>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800d18:	83 ec 04             	sub    $0x4,%esp
  800d1b:	68 07 04 00 00       	push   $0x407
  800d20:	ff 75 e4             	pushl  -0x1c(%ebp)
  800d23:	6a 00                	push   $0x0
  800d25:	e8 82 f4 ff ff       	call   8001ac <sys_page_alloc>
  800d2a:	89 c3                	mov    %eax,%ebx
  800d2c:	83 c4 10             	add    $0x10,%esp
  800d2f:	85 c0                	test   %eax,%eax
  800d31:	0f 88 05 01 00 00    	js     800e3c <pipe+0x146>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  800d37:	83 ec 0c             	sub    $0xc,%esp
  800d3a:	8d 45 e0             	lea    -0x20(%ebp),%eax
  800d3d:	50                   	push   %eax
  800d3e:	e8 3d f6 ff ff       	call   800380 <fd_alloc>
  800d43:	89 c3                	mov    %eax,%ebx
  800d45:	83 c4 10             	add    $0x10,%esp
  800d48:	85 c0                	test   %eax,%eax
  800d4a:	0f 88 dc 00 00 00    	js     800e2c <pipe+0x136>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800d50:	83 ec 04             	sub    $0x4,%esp
  800d53:	68 07 04 00 00       	push   $0x407
  800d58:	ff 75 e0             	pushl  -0x20(%ebp)
  800d5b:	6a 00                	push   $0x0
  800d5d:	e8 4a f4 ff ff       	call   8001ac <sys_page_alloc>
  800d62:	89 c3                	mov    %eax,%ebx
  800d64:	83 c4 10             	add    $0x10,%esp
  800d67:	85 c0                	test   %eax,%eax
  800d69:	0f 88 bd 00 00 00    	js     800e2c <pipe+0x136>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  800d6f:	83 ec 0c             	sub    $0xc,%esp
  800d72:	ff 75 e4             	pushl  -0x1c(%ebp)
  800d75:	e8 ee f5 ff ff       	call   800368 <fd2data>
  800d7a:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800d7c:	83 c4 0c             	add    $0xc,%esp
  800d7f:	68 07 04 00 00       	push   $0x407
  800d84:	50                   	push   %eax
  800d85:	6a 00                	push   $0x0
  800d87:	e8 20 f4 ff ff       	call   8001ac <sys_page_alloc>
  800d8c:	89 c3                	mov    %eax,%ebx
  800d8e:	83 c4 10             	add    $0x10,%esp
  800d91:	85 c0                	test   %eax,%eax
  800d93:	0f 88 83 00 00 00    	js     800e1c <pipe+0x126>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800d99:	83 ec 0c             	sub    $0xc,%esp
  800d9c:	ff 75 e0             	pushl  -0x20(%ebp)
  800d9f:	e8 c4 f5 ff ff       	call   800368 <fd2data>
  800da4:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  800dab:	50                   	push   %eax
  800dac:	6a 00                	push   $0x0
  800dae:	56                   	push   %esi
  800daf:	6a 00                	push   $0x0
  800db1:	e8 1a f4 ff ff       	call   8001d0 <sys_page_map>
  800db6:	89 c3                	mov    %eax,%ebx
  800db8:	83 c4 20             	add    $0x20,%esp
  800dbb:	85 c0                	test   %eax,%eax
  800dbd:	78 4f                	js     800e0e <pipe+0x118>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  800dbf:	8b 15 20 30 80 00    	mov    0x803020,%edx
  800dc5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800dc8:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  800dca:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800dcd:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  800dd4:	8b 15 20 30 80 00    	mov    0x803020,%edx
  800dda:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800ddd:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  800ddf:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800de2:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  800de9:	83 ec 0c             	sub    $0xc,%esp
  800dec:	ff 75 e4             	pushl  -0x1c(%ebp)
  800def:	e8 64 f5 ff ff       	call   800358 <fd2num>
  800df4:	89 07                	mov    %eax,(%edi)
	pfd[1] = fd2num(fd1);
  800df6:	83 c4 04             	add    $0x4,%esp
  800df9:	ff 75 e0             	pushl  -0x20(%ebp)
  800dfc:	e8 57 f5 ff ff       	call   800358 <fd2num>
  800e01:	89 47 04             	mov    %eax,0x4(%edi)
	return 0;
  800e04:	83 c4 10             	add    $0x10,%esp
  800e07:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e0c:	eb 2e                	jmp    800e3c <pipe+0x146>

    err3:
	sys_page_unmap(0, va);
  800e0e:	83 ec 08             	sub    $0x8,%esp
  800e11:	56                   	push   %esi
  800e12:	6a 00                	push   $0x0
  800e14:	e8 dd f3 ff ff       	call   8001f6 <sys_page_unmap>
  800e19:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  800e1c:	83 ec 08             	sub    $0x8,%esp
  800e1f:	ff 75 e0             	pushl  -0x20(%ebp)
  800e22:	6a 00                	push   $0x0
  800e24:	e8 cd f3 ff ff       	call   8001f6 <sys_page_unmap>
  800e29:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  800e2c:	83 ec 08             	sub    $0x8,%esp
  800e2f:	ff 75 e4             	pushl  -0x1c(%ebp)
  800e32:	6a 00                	push   $0x0
  800e34:	e8 bd f3 ff ff       	call   8001f6 <sys_page_unmap>
  800e39:	83 c4 10             	add    $0x10,%esp
    err:
	return r;
}
  800e3c:	89 d8                	mov    %ebx,%eax
  800e3e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e41:	5b                   	pop    %ebx
  800e42:	5e                   	pop    %esi
  800e43:	5f                   	pop    %edi
  800e44:	c9                   	leave  
  800e45:	c3                   	ret    

00800e46 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  800e46:	55                   	push   %ebp
  800e47:	89 e5                	mov    %esp,%ebp
  800e49:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800e4c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800e4f:	50                   	push   %eax
  800e50:	ff 75 08             	pushl  0x8(%ebp)
  800e53:	e8 9b f5 ff ff       	call   8003f3 <fd_lookup>
  800e58:	83 c4 10             	add    $0x10,%esp
  800e5b:	85 c0                	test   %eax,%eax
  800e5d:	78 18                	js     800e77 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  800e5f:	83 ec 0c             	sub    $0xc,%esp
  800e62:	ff 75 f4             	pushl  -0xc(%ebp)
  800e65:	e8 fe f4 ff ff       	call   800368 <fd2data>
	return _pipeisclosed(fd, p);
  800e6a:	89 c2                	mov    %eax,%edx
  800e6c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800e6f:	e8 0c fd ff ff       	call   800b80 <_pipeisclosed>
  800e74:	83 c4 10             	add    $0x10,%esp
}
  800e77:	c9                   	leave  
  800e78:	c3                   	ret    
  800e79:	00 00                	add    %al,(%eax)
	...

00800e7c <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  800e7c:	55                   	push   %ebp
  800e7d:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  800e7f:	b8 00 00 00 00       	mov    $0x0,%eax
  800e84:	c9                   	leave  
  800e85:	c3                   	ret    

00800e86 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  800e86:	55                   	push   %ebp
  800e87:	89 e5                	mov    %esp,%ebp
  800e89:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  800e8c:	68 d6 1e 80 00       	push   $0x801ed6
  800e91:	ff 75 0c             	pushl  0xc(%ebp)
  800e94:	e8 01 08 00 00       	call   80169a <strcpy>
	return 0;
}
  800e99:	b8 00 00 00 00       	mov    $0x0,%eax
  800e9e:	c9                   	leave  
  800e9f:	c3                   	ret    

00800ea0 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  800ea0:	55                   	push   %ebp
  800ea1:	89 e5                	mov    %esp,%ebp
  800ea3:	57                   	push   %edi
  800ea4:	56                   	push   %esi
  800ea5:	53                   	push   %ebx
  800ea6:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800eac:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800eb0:	74 45                	je     800ef7 <devcons_write+0x57>
  800eb2:	b8 00 00 00 00       	mov    $0x0,%eax
  800eb7:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  800ebc:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  800ec2:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800ec5:	29 c3                	sub    %eax,%ebx
		if (m > sizeof(buf) - 1)
  800ec7:	83 fb 7f             	cmp    $0x7f,%ebx
  800eca:	76 05                	jbe    800ed1 <devcons_write+0x31>
			m = sizeof(buf) - 1;
  800ecc:	bb 7f 00 00 00       	mov    $0x7f,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  800ed1:	83 ec 04             	sub    $0x4,%esp
  800ed4:	53                   	push   %ebx
  800ed5:	03 45 0c             	add    0xc(%ebp),%eax
  800ed8:	50                   	push   %eax
  800ed9:	57                   	push   %edi
  800eda:	e8 7c 09 00 00       	call   80185b <memmove>
		sys_cputs(buf, m);
  800edf:	83 c4 08             	add    $0x8,%esp
  800ee2:	53                   	push   %ebx
  800ee3:	57                   	push   %edi
  800ee4:	e8 0c f2 ff ff       	call   8000f5 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800ee9:	01 de                	add    %ebx,%esi
  800eeb:	89 f0                	mov    %esi,%eax
  800eed:	83 c4 10             	add    $0x10,%esp
  800ef0:	3b 75 10             	cmp    0x10(%ebp),%esi
  800ef3:	72 cd                	jb     800ec2 <devcons_write+0x22>
  800ef5:	eb 05                	jmp    800efc <devcons_write+0x5c>
  800ef7:	be 00 00 00 00       	mov    $0x0,%esi
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  800efc:	89 f0                	mov    %esi,%eax
  800efe:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f01:	5b                   	pop    %ebx
  800f02:	5e                   	pop    %esi
  800f03:	5f                   	pop    %edi
  800f04:	c9                   	leave  
  800f05:	c3                   	ret    

00800f06 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  800f06:	55                   	push   %ebp
  800f07:	89 e5                	mov    %esp,%ebp
  800f09:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
  800f0c:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800f10:	75 07                	jne    800f19 <devcons_read+0x13>
  800f12:	eb 25                	jmp    800f39 <devcons_read+0x33>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  800f14:	e8 6c f2 ff ff       	call   800185 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  800f19:	e8 fd f1 ff ff       	call   80011b <sys_cgetc>
  800f1e:	85 c0                	test   %eax,%eax
  800f20:	74 f2                	je     800f14 <devcons_read+0xe>
  800f22:	89 c2                	mov    %eax,%edx
		sys_yield();
	if (c < 0)
  800f24:	85 c0                	test   %eax,%eax
  800f26:	78 1d                	js     800f45 <devcons_read+0x3f>
		return c;
	if (c == 0x04)	// ctl-d is eof
  800f28:	83 f8 04             	cmp    $0x4,%eax
  800f2b:	74 13                	je     800f40 <devcons_read+0x3a>
		return 0;
	*(char*)vbuf = c;
  800f2d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f30:	88 10                	mov    %dl,(%eax)
	return 1;
  800f32:	b8 01 00 00 00       	mov    $0x1,%eax
  800f37:	eb 0c                	jmp    800f45 <devcons_read+0x3f>
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
		return 0;
  800f39:	b8 00 00 00 00       	mov    $0x0,%eax
  800f3e:	eb 05                	jmp    800f45 <devcons_read+0x3f>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  800f40:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  800f45:	c9                   	leave  
  800f46:	c3                   	ret    

00800f47 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  800f47:	55                   	push   %ebp
  800f48:	89 e5                	mov    %esp,%ebp
  800f4a:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  800f4d:	8b 45 08             	mov    0x8(%ebp),%eax
  800f50:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  800f53:	6a 01                	push   $0x1
  800f55:	8d 45 f7             	lea    -0x9(%ebp),%eax
  800f58:	50                   	push   %eax
  800f59:	e8 97 f1 ff ff       	call   8000f5 <sys_cputs>
  800f5e:	83 c4 10             	add    $0x10,%esp
}
  800f61:	c9                   	leave  
  800f62:	c3                   	ret    

00800f63 <getchar>:

int
getchar(void)
{
  800f63:	55                   	push   %ebp
  800f64:	89 e5                	mov    %esp,%ebp
  800f66:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  800f69:	6a 01                	push   $0x1
  800f6b:	8d 45 f7             	lea    -0x9(%ebp),%eax
  800f6e:	50                   	push   %eax
  800f6f:	6a 00                	push   $0x0
  800f71:	e8 fe f6 ff ff       	call   800674 <read>
	if (r < 0)
  800f76:	83 c4 10             	add    $0x10,%esp
  800f79:	85 c0                	test   %eax,%eax
  800f7b:	78 0f                	js     800f8c <getchar+0x29>
		return r;
	if (r < 1)
  800f7d:	85 c0                	test   %eax,%eax
  800f7f:	7e 06                	jle    800f87 <getchar+0x24>
		return -E_EOF;
	return c;
  800f81:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  800f85:	eb 05                	jmp    800f8c <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  800f87:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  800f8c:	c9                   	leave  
  800f8d:	c3                   	ret    

00800f8e <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  800f8e:	55                   	push   %ebp
  800f8f:	89 e5                	mov    %esp,%ebp
  800f91:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800f94:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800f97:	50                   	push   %eax
  800f98:	ff 75 08             	pushl  0x8(%ebp)
  800f9b:	e8 53 f4 ff ff       	call   8003f3 <fd_lookup>
  800fa0:	83 c4 10             	add    $0x10,%esp
  800fa3:	85 c0                	test   %eax,%eax
  800fa5:	78 11                	js     800fb8 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  800fa7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800faa:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  800fb0:	39 10                	cmp    %edx,(%eax)
  800fb2:	0f 94 c0             	sete   %al
  800fb5:	0f b6 c0             	movzbl %al,%eax
}
  800fb8:	c9                   	leave  
  800fb9:	c3                   	ret    

00800fba <opencons>:

int
opencons(void)
{
  800fba:	55                   	push   %ebp
  800fbb:	89 e5                	mov    %esp,%ebp
  800fbd:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  800fc0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800fc3:	50                   	push   %eax
  800fc4:	e8 b7 f3 ff ff       	call   800380 <fd_alloc>
  800fc9:	83 c4 10             	add    $0x10,%esp
  800fcc:	85 c0                	test   %eax,%eax
  800fce:	78 3a                	js     80100a <opencons+0x50>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  800fd0:	83 ec 04             	sub    $0x4,%esp
  800fd3:	68 07 04 00 00       	push   $0x407
  800fd8:	ff 75 f4             	pushl  -0xc(%ebp)
  800fdb:	6a 00                	push   $0x0
  800fdd:	e8 ca f1 ff ff       	call   8001ac <sys_page_alloc>
  800fe2:	83 c4 10             	add    $0x10,%esp
  800fe5:	85 c0                	test   %eax,%eax
  800fe7:	78 21                	js     80100a <opencons+0x50>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  800fe9:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  800fef:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800ff2:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  800ff4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800ff7:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  800ffe:	83 ec 0c             	sub    $0xc,%esp
  801001:	50                   	push   %eax
  801002:	e8 51 f3 ff ff       	call   800358 <fd2num>
  801007:	83 c4 10             	add    $0x10,%esp
}
  80100a:	c9                   	leave  
  80100b:	c3                   	ret    

0080100c <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80100c:	55                   	push   %ebp
  80100d:	89 e5                	mov    %esp,%ebp
  80100f:	56                   	push   %esi
  801010:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801011:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801014:	8b 1d 00 30 80 00    	mov    0x803000,%ebx
  80101a:	e8 42 f1 ff ff       	call   800161 <sys_getenvid>
  80101f:	83 ec 0c             	sub    $0xc,%esp
  801022:	ff 75 0c             	pushl  0xc(%ebp)
  801025:	ff 75 08             	pushl  0x8(%ebp)
  801028:	53                   	push   %ebx
  801029:	50                   	push   %eax
  80102a:	68 e4 1e 80 00       	push   $0x801ee4
  80102f:	e8 b0 00 00 00       	call   8010e4 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801034:	83 c4 18             	add    $0x18,%esp
  801037:	56                   	push   %esi
  801038:	ff 75 10             	pushl  0x10(%ebp)
  80103b:	e8 53 00 00 00       	call   801093 <vcprintf>
	cprintf("\n");
  801040:	c7 04 24 cf 1e 80 00 	movl   $0x801ecf,(%esp)
  801047:	e8 98 00 00 00       	call   8010e4 <cprintf>
  80104c:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80104f:	cc                   	int3   
  801050:	eb fd                	jmp    80104f <_panic+0x43>
	...

00801054 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  801054:	55                   	push   %ebp
  801055:	89 e5                	mov    %esp,%ebp
  801057:	53                   	push   %ebx
  801058:	83 ec 04             	sub    $0x4,%esp
  80105b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80105e:	8b 03                	mov    (%ebx),%eax
  801060:	8b 55 08             	mov    0x8(%ebp),%edx
  801063:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  801067:	40                   	inc    %eax
  801068:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  80106a:	3d ff 00 00 00       	cmp    $0xff,%eax
  80106f:	75 1a                	jne    80108b <putch+0x37>
		sys_cputs(b->buf, b->idx);
  801071:	83 ec 08             	sub    $0x8,%esp
  801074:	68 ff 00 00 00       	push   $0xff
  801079:	8d 43 08             	lea    0x8(%ebx),%eax
  80107c:	50                   	push   %eax
  80107d:	e8 73 f0 ff ff       	call   8000f5 <sys_cputs>
		b->idx = 0;
  801082:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801088:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  80108b:	ff 43 04             	incl   0x4(%ebx)
}
  80108e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801091:	c9                   	leave  
  801092:	c3                   	ret    

00801093 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  801093:	55                   	push   %ebp
  801094:	89 e5                	mov    %esp,%ebp
  801096:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  80109c:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8010a3:	00 00 00 
	b.cnt = 0;
  8010a6:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8010ad:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8010b0:	ff 75 0c             	pushl  0xc(%ebp)
  8010b3:	ff 75 08             	pushl  0x8(%ebp)
  8010b6:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8010bc:	50                   	push   %eax
  8010bd:	68 54 10 80 00       	push   $0x801054
  8010c2:	e8 82 01 00 00       	call   801249 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8010c7:	83 c4 08             	add    $0x8,%esp
  8010ca:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8010d0:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8010d6:	50                   	push   %eax
  8010d7:	e8 19 f0 ff ff       	call   8000f5 <sys_cputs>

	return b.cnt;
}
  8010dc:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8010e2:	c9                   	leave  
  8010e3:	c3                   	ret    

008010e4 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8010e4:	55                   	push   %ebp
  8010e5:	89 e5                	mov    %esp,%ebp
  8010e7:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8010ea:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8010ed:	50                   	push   %eax
  8010ee:	ff 75 08             	pushl  0x8(%ebp)
  8010f1:	e8 9d ff ff ff       	call   801093 <vcprintf>
	va_end(ap);

	return cnt;
}
  8010f6:	c9                   	leave  
  8010f7:	c3                   	ret    

008010f8 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8010f8:	55                   	push   %ebp
  8010f9:	89 e5                	mov    %esp,%ebp
  8010fb:	57                   	push   %edi
  8010fc:	56                   	push   %esi
  8010fd:	53                   	push   %ebx
  8010fe:	83 ec 2c             	sub    $0x2c,%esp
  801101:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801104:	89 d6                	mov    %edx,%esi
  801106:	8b 45 08             	mov    0x8(%ebp),%eax
  801109:	8b 55 0c             	mov    0xc(%ebp),%edx
  80110c:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80110f:	89 55 dc             	mov    %edx,-0x24(%ebp)
  801112:	8b 45 10             	mov    0x10(%ebp),%eax
  801115:	8b 5d 14             	mov    0x14(%ebp),%ebx
  801118:	8b 7d 18             	mov    0x18(%ebp),%edi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80111b:	89 45 d0             	mov    %eax,-0x30(%ebp)
  80111e:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  801125:	39 55 d4             	cmp    %edx,-0x2c(%ebp)
  801128:	72 0c                	jb     801136 <printnum+0x3e>
  80112a:	3b 45 d8             	cmp    -0x28(%ebp),%eax
  80112d:	76 07                	jbe    801136 <printnum+0x3e>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80112f:	4b                   	dec    %ebx
  801130:	85 db                	test   %ebx,%ebx
  801132:	7f 31                	jg     801165 <printnum+0x6d>
  801134:	eb 3f                	jmp    801175 <printnum+0x7d>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  801136:	83 ec 0c             	sub    $0xc,%esp
  801139:	57                   	push   %edi
  80113a:	4b                   	dec    %ebx
  80113b:	53                   	push   %ebx
  80113c:	50                   	push   %eax
  80113d:	83 ec 08             	sub    $0x8,%esp
  801140:	ff 75 d4             	pushl  -0x2c(%ebp)
  801143:	ff 75 d0             	pushl  -0x30(%ebp)
  801146:	ff 75 dc             	pushl  -0x24(%ebp)
  801149:	ff 75 d8             	pushl  -0x28(%ebp)
  80114c:	e8 23 0a 00 00       	call   801b74 <__udivdi3>
  801151:	83 c4 18             	add    $0x18,%esp
  801154:	52                   	push   %edx
  801155:	50                   	push   %eax
  801156:	89 f2                	mov    %esi,%edx
  801158:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80115b:	e8 98 ff ff ff       	call   8010f8 <printnum>
  801160:	83 c4 20             	add    $0x20,%esp
  801163:	eb 10                	jmp    801175 <printnum+0x7d>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  801165:	83 ec 08             	sub    $0x8,%esp
  801168:	56                   	push   %esi
  801169:	57                   	push   %edi
  80116a:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80116d:	4b                   	dec    %ebx
  80116e:	83 c4 10             	add    $0x10,%esp
  801171:	85 db                	test   %ebx,%ebx
  801173:	7f f0                	jg     801165 <printnum+0x6d>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  801175:	83 ec 08             	sub    $0x8,%esp
  801178:	56                   	push   %esi
  801179:	83 ec 04             	sub    $0x4,%esp
  80117c:	ff 75 d4             	pushl  -0x2c(%ebp)
  80117f:	ff 75 d0             	pushl  -0x30(%ebp)
  801182:	ff 75 dc             	pushl  -0x24(%ebp)
  801185:	ff 75 d8             	pushl  -0x28(%ebp)
  801188:	e8 03 0b 00 00       	call   801c90 <__umoddi3>
  80118d:	83 c4 14             	add    $0x14,%esp
  801190:	0f be 80 07 1f 80 00 	movsbl 0x801f07(%eax),%eax
  801197:	50                   	push   %eax
  801198:	ff 55 e4             	call   *-0x1c(%ebp)
  80119b:	83 c4 10             	add    $0x10,%esp
}
  80119e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011a1:	5b                   	pop    %ebx
  8011a2:	5e                   	pop    %esi
  8011a3:	5f                   	pop    %edi
  8011a4:	c9                   	leave  
  8011a5:	c3                   	ret    

008011a6 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8011a6:	55                   	push   %ebp
  8011a7:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8011a9:	83 fa 01             	cmp    $0x1,%edx
  8011ac:	7e 0e                	jle    8011bc <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8011ae:	8b 10                	mov    (%eax),%edx
  8011b0:	8d 4a 08             	lea    0x8(%edx),%ecx
  8011b3:	89 08                	mov    %ecx,(%eax)
  8011b5:	8b 02                	mov    (%edx),%eax
  8011b7:	8b 52 04             	mov    0x4(%edx),%edx
  8011ba:	eb 22                	jmp    8011de <getuint+0x38>
	else if (lflag)
  8011bc:	85 d2                	test   %edx,%edx
  8011be:	74 10                	je     8011d0 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8011c0:	8b 10                	mov    (%eax),%edx
  8011c2:	8d 4a 04             	lea    0x4(%edx),%ecx
  8011c5:	89 08                	mov    %ecx,(%eax)
  8011c7:	8b 02                	mov    (%edx),%eax
  8011c9:	ba 00 00 00 00       	mov    $0x0,%edx
  8011ce:	eb 0e                	jmp    8011de <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8011d0:	8b 10                	mov    (%eax),%edx
  8011d2:	8d 4a 04             	lea    0x4(%edx),%ecx
  8011d5:	89 08                	mov    %ecx,(%eax)
  8011d7:	8b 02                	mov    (%edx),%eax
  8011d9:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8011de:	c9                   	leave  
  8011df:	c3                   	ret    

008011e0 <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
  8011e0:	55                   	push   %ebp
  8011e1:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8011e3:	83 fa 01             	cmp    $0x1,%edx
  8011e6:	7e 0e                	jle    8011f6 <getint+0x16>
		return va_arg(*ap, long long);
  8011e8:	8b 10                	mov    (%eax),%edx
  8011ea:	8d 4a 08             	lea    0x8(%edx),%ecx
  8011ed:	89 08                	mov    %ecx,(%eax)
  8011ef:	8b 02                	mov    (%edx),%eax
  8011f1:	8b 52 04             	mov    0x4(%edx),%edx
  8011f4:	eb 1a                	jmp    801210 <getint+0x30>
	else if (lflag)
  8011f6:	85 d2                	test   %edx,%edx
  8011f8:	74 0c                	je     801206 <getint+0x26>
		return va_arg(*ap, long);
  8011fa:	8b 10                	mov    (%eax),%edx
  8011fc:	8d 4a 04             	lea    0x4(%edx),%ecx
  8011ff:	89 08                	mov    %ecx,(%eax)
  801201:	8b 02                	mov    (%edx),%eax
  801203:	99                   	cltd   
  801204:	eb 0a                	jmp    801210 <getint+0x30>
	else
		return va_arg(*ap, int);
  801206:	8b 10                	mov    (%eax),%edx
  801208:	8d 4a 04             	lea    0x4(%edx),%ecx
  80120b:	89 08                	mov    %ecx,(%eax)
  80120d:	8b 02                	mov    (%edx),%eax
  80120f:	99                   	cltd   
}
  801210:	c9                   	leave  
  801211:	c3                   	ret    

00801212 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  801212:	55                   	push   %ebp
  801213:	89 e5                	mov    %esp,%ebp
  801215:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  801218:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  80121b:	8b 10                	mov    (%eax),%edx
  80121d:	3b 50 04             	cmp    0x4(%eax),%edx
  801220:	73 08                	jae    80122a <sprintputch+0x18>
		*b->buf++ = ch;
  801222:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801225:	88 0a                	mov    %cl,(%edx)
  801227:	42                   	inc    %edx
  801228:	89 10                	mov    %edx,(%eax)
}
  80122a:	c9                   	leave  
  80122b:	c3                   	ret    

0080122c <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80122c:	55                   	push   %ebp
  80122d:	89 e5                	mov    %esp,%ebp
  80122f:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  801232:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  801235:	50                   	push   %eax
  801236:	ff 75 10             	pushl  0x10(%ebp)
  801239:	ff 75 0c             	pushl  0xc(%ebp)
  80123c:	ff 75 08             	pushl  0x8(%ebp)
  80123f:	e8 05 00 00 00       	call   801249 <vprintfmt>
	va_end(ap);
  801244:	83 c4 10             	add    $0x10,%esp
}
  801247:	c9                   	leave  
  801248:	c3                   	ret    

00801249 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  801249:	55                   	push   %ebp
  80124a:	89 e5                	mov    %esp,%ebp
  80124c:	57                   	push   %edi
  80124d:	56                   	push   %esi
  80124e:	53                   	push   %ebx
  80124f:	83 ec 2c             	sub    $0x2c,%esp
  801252:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801255:	8b 75 10             	mov    0x10(%ebp),%esi
  801258:	eb 13                	jmp    80126d <vprintfmt+0x24>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  80125a:	85 c0                	test   %eax,%eax
  80125c:	0f 84 6d 03 00 00    	je     8015cf <vprintfmt+0x386>
				return;
			putch(ch, putdat);
  801262:	83 ec 08             	sub    $0x8,%esp
  801265:	57                   	push   %edi
  801266:	50                   	push   %eax
  801267:	ff 55 08             	call   *0x8(%ebp)
  80126a:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80126d:	0f b6 06             	movzbl (%esi),%eax
  801270:	46                   	inc    %esi
  801271:	83 f8 25             	cmp    $0x25,%eax
  801274:	75 e4                	jne    80125a <vprintfmt+0x11>
  801276:	c6 45 dc 20          	movb   $0x20,-0x24(%ebp)
  80127a:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  801281:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
  801288:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  80128f:	b9 00 00 00 00       	mov    $0x0,%ecx
  801294:	eb 28                	jmp    8012be <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801296:	89 de                	mov    %ebx,%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  801298:	c6 45 dc 2d          	movb   $0x2d,-0x24(%ebp)
  80129c:	eb 20                	jmp    8012be <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80129e:	89 de                	mov    %ebx,%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8012a0:	c6 45 dc 30          	movb   $0x30,-0x24(%ebp)
  8012a4:	eb 18                	jmp    8012be <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8012a6:	89 de                	mov    %ebx,%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  8012a8:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  8012af:	eb 0d                	jmp    8012be <vprintfmt+0x75>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  8012b1:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8012b4:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8012b7:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8012be:	8a 06                	mov    (%esi),%al
  8012c0:	0f b6 d0             	movzbl %al,%edx
  8012c3:	8d 5e 01             	lea    0x1(%esi),%ebx
  8012c6:	83 e8 23             	sub    $0x23,%eax
  8012c9:	3c 55                	cmp    $0x55,%al
  8012cb:	0f 87 e0 02 00 00    	ja     8015b1 <vprintfmt+0x368>
  8012d1:	0f b6 c0             	movzbl %al,%eax
  8012d4:	ff 24 85 40 20 80 00 	jmp    *0x802040(,%eax,4)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8012db:	83 ea 30             	sub    $0x30,%edx
  8012de:	89 55 d4             	mov    %edx,-0x2c(%ebp)
				ch = *fmt;
  8012e1:	0f be 03             	movsbl (%ebx),%eax
				if (ch < '0' || ch > '9')
  8012e4:	8d 50 d0             	lea    -0x30(%eax),%edx
  8012e7:	83 fa 09             	cmp    $0x9,%edx
  8012ea:	77 44                	ja     801330 <vprintfmt+0xe7>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8012ec:	89 de                	mov    %ebx,%esi
  8012ee:	8b 55 d4             	mov    -0x2c(%ebp),%edx
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8012f1:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
  8012f2:	8d 14 92             	lea    (%edx,%edx,4),%edx
  8012f5:	8d 54 50 d0          	lea    -0x30(%eax,%edx,2),%edx
				ch = *fmt;
  8012f9:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  8012fc:	8d 58 d0             	lea    -0x30(%eax),%ebx
  8012ff:	83 fb 09             	cmp    $0x9,%ebx
  801302:	76 ed                	jbe    8012f1 <vprintfmt+0xa8>
  801304:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  801307:	eb 29                	jmp    801332 <vprintfmt+0xe9>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  801309:	8b 45 14             	mov    0x14(%ebp),%eax
  80130c:	8d 50 04             	lea    0x4(%eax),%edx
  80130f:	89 55 14             	mov    %edx,0x14(%ebp)
  801312:	8b 00                	mov    (%eax),%eax
  801314:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801317:	89 de                	mov    %ebx,%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  801319:	eb 17                	jmp    801332 <vprintfmt+0xe9>

		case '.':
			if (width < 0)
  80131b:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80131f:	78 85                	js     8012a6 <vprintfmt+0x5d>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801321:	89 de                	mov    %ebx,%esi
  801323:	eb 99                	jmp    8012be <vprintfmt+0x75>
  801325:	89 de                	mov    %ebx,%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  801327:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
			goto reswitch;
  80132e:	eb 8e                	jmp    8012be <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801330:	89 de                	mov    %ebx,%esi
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  801332:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  801336:	79 86                	jns    8012be <vprintfmt+0x75>
  801338:	e9 74 ff ff ff       	jmp    8012b1 <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80133d:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80133e:	89 de                	mov    %ebx,%esi
  801340:	e9 79 ff ff ff       	jmp    8012be <vprintfmt+0x75>
  801345:	89 5d d8             	mov    %ebx,-0x28(%ebp)
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  801348:	8b 45 14             	mov    0x14(%ebp),%eax
  80134b:	8d 50 04             	lea    0x4(%eax),%edx
  80134e:	89 55 14             	mov    %edx,0x14(%ebp)
  801351:	83 ec 08             	sub    $0x8,%esp
  801354:	57                   	push   %edi
  801355:	ff 30                	pushl  (%eax)
  801357:	ff 55 08             	call   *0x8(%ebp)
			break;
  80135a:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80135d:	8b 75 d8             	mov    -0x28(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  801360:	e9 08 ff ff ff       	jmp    80126d <vprintfmt+0x24>
  801365:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// error message
		case 'e':
			err = va_arg(ap, int);
  801368:	8b 45 14             	mov    0x14(%ebp),%eax
  80136b:	8d 50 04             	lea    0x4(%eax),%edx
  80136e:	89 55 14             	mov    %edx,0x14(%ebp)
  801371:	8b 00                	mov    (%eax),%eax
  801373:	85 c0                	test   %eax,%eax
  801375:	79 02                	jns    801379 <vprintfmt+0x130>
  801377:	f7 d8                	neg    %eax
  801379:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80137b:	83 f8 0f             	cmp    $0xf,%eax
  80137e:	7f 0b                	jg     80138b <vprintfmt+0x142>
  801380:	8b 04 85 a0 21 80 00 	mov    0x8021a0(,%eax,4),%eax
  801387:	85 c0                	test   %eax,%eax
  801389:	75 1a                	jne    8013a5 <vprintfmt+0x15c>
				printfmt(putch, putdat, "error %d", err);
  80138b:	52                   	push   %edx
  80138c:	68 1f 1f 80 00       	push   $0x801f1f
  801391:	57                   	push   %edi
  801392:	ff 75 08             	pushl  0x8(%ebp)
  801395:	e8 92 fe ff ff       	call   80122c <printfmt>
  80139a:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80139d:	8b 75 d8             	mov    -0x28(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8013a0:	e9 c8 fe ff ff       	jmp    80126d <vprintfmt+0x24>
			else
				printfmt(putch, putdat, "%s", p);
  8013a5:	50                   	push   %eax
  8013a6:	68 9d 1e 80 00       	push   $0x801e9d
  8013ab:	57                   	push   %edi
  8013ac:	ff 75 08             	pushl  0x8(%ebp)
  8013af:	e8 78 fe ff ff       	call   80122c <printfmt>
  8013b4:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8013b7:	8b 75 d8             	mov    -0x28(%ebp),%esi
  8013ba:	e9 ae fe ff ff       	jmp    80126d <vprintfmt+0x24>
  8013bf:	89 5d d8             	mov    %ebx,-0x28(%ebp)
  8013c2:	89 de                	mov    %ebx,%esi
  8013c4:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  8013c7:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8013ca:	8b 45 14             	mov    0x14(%ebp),%eax
  8013cd:	8d 50 04             	lea    0x4(%eax),%edx
  8013d0:	89 55 14             	mov    %edx,0x14(%ebp)
  8013d3:	8b 00                	mov    (%eax),%eax
  8013d5:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8013d8:	85 c0                	test   %eax,%eax
  8013da:	75 07                	jne    8013e3 <vprintfmt+0x19a>
				p = "(null)";
  8013dc:	c7 45 d0 18 1f 80 00 	movl   $0x801f18,-0x30(%ebp)
			if (width > 0 && padc != '-')
  8013e3:	85 db                	test   %ebx,%ebx
  8013e5:	7e 42                	jle    801429 <vprintfmt+0x1e0>
  8013e7:	80 7d dc 2d          	cmpb   $0x2d,-0x24(%ebp)
  8013eb:	74 3c                	je     801429 <vprintfmt+0x1e0>
				for (width -= strnlen(p, precision); width > 0; width--)
  8013ed:	83 ec 08             	sub    $0x8,%esp
  8013f0:	51                   	push   %ecx
  8013f1:	ff 75 d0             	pushl  -0x30(%ebp)
  8013f4:	e8 6f 02 00 00       	call   801668 <strnlen>
  8013f9:	29 c3                	sub    %eax,%ebx
  8013fb:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8013fe:	83 c4 10             	add    $0x10,%esp
  801401:	85 db                	test   %ebx,%ebx
  801403:	7e 24                	jle    801429 <vprintfmt+0x1e0>
					putch(padc, putdat);
  801405:	0f be 5d dc          	movsbl -0x24(%ebp),%ebx
  801409:	89 75 dc             	mov    %esi,-0x24(%ebp)
  80140c:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  80140f:	83 ec 08             	sub    $0x8,%esp
  801412:	57                   	push   %edi
  801413:	53                   	push   %ebx
  801414:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  801417:	4e                   	dec    %esi
  801418:	83 c4 10             	add    $0x10,%esp
  80141b:	85 f6                	test   %esi,%esi
  80141d:	7f f0                	jg     80140f <vprintfmt+0x1c6>
  80141f:	8b 75 dc             	mov    -0x24(%ebp),%esi
  801422:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  801429:	8b 55 d0             	mov    -0x30(%ebp),%edx
  80142c:	0f be 02             	movsbl (%edx),%eax
  80142f:	85 c0                	test   %eax,%eax
  801431:	75 47                	jne    80147a <vprintfmt+0x231>
  801433:	eb 37                	jmp    80146c <vprintfmt+0x223>
				if (altflag && (ch < ' ' || ch > '~'))
  801435:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  801439:	74 16                	je     801451 <vprintfmt+0x208>
  80143b:	8d 50 e0             	lea    -0x20(%eax),%edx
  80143e:	83 fa 5e             	cmp    $0x5e,%edx
  801441:	76 0e                	jbe    801451 <vprintfmt+0x208>
					putch('?', putdat);
  801443:	83 ec 08             	sub    $0x8,%esp
  801446:	57                   	push   %edi
  801447:	6a 3f                	push   $0x3f
  801449:	ff 55 08             	call   *0x8(%ebp)
  80144c:	83 c4 10             	add    $0x10,%esp
  80144f:	eb 0b                	jmp    80145c <vprintfmt+0x213>
				else
					putch(ch, putdat);
  801451:	83 ec 08             	sub    $0x8,%esp
  801454:	57                   	push   %edi
  801455:	50                   	push   %eax
  801456:	ff 55 08             	call   *0x8(%ebp)
  801459:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80145c:	ff 4d e4             	decl   -0x1c(%ebp)
  80145f:	0f be 03             	movsbl (%ebx),%eax
  801462:	85 c0                	test   %eax,%eax
  801464:	74 03                	je     801469 <vprintfmt+0x220>
  801466:	43                   	inc    %ebx
  801467:	eb 1b                	jmp    801484 <vprintfmt+0x23b>
  801469:	8b 75 dc             	mov    -0x24(%ebp),%esi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80146c:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  801470:	7f 1e                	jg     801490 <vprintfmt+0x247>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801472:	8b 75 d8             	mov    -0x28(%ebp),%esi
  801475:	e9 f3 fd ff ff       	jmp    80126d <vprintfmt+0x24>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80147a:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  80147d:	43                   	inc    %ebx
  80147e:	89 75 dc             	mov    %esi,-0x24(%ebp)
  801481:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  801484:	85 f6                	test   %esi,%esi
  801486:	78 ad                	js     801435 <vprintfmt+0x1ec>
  801488:	4e                   	dec    %esi
  801489:	79 aa                	jns    801435 <vprintfmt+0x1ec>
  80148b:	8b 75 dc             	mov    -0x24(%ebp),%esi
  80148e:	eb dc                	jmp    80146c <vprintfmt+0x223>
  801490:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  801493:	83 ec 08             	sub    $0x8,%esp
  801496:	57                   	push   %edi
  801497:	6a 20                	push   $0x20
  801499:	ff 55 08             	call   *0x8(%ebp)
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80149c:	4b                   	dec    %ebx
  80149d:	83 c4 10             	add    $0x10,%esp
  8014a0:	85 db                	test   %ebx,%ebx
  8014a2:	7f ef                	jg     801493 <vprintfmt+0x24a>
  8014a4:	e9 c4 fd ff ff       	jmp    80126d <vprintfmt+0x24>
  8014a9:	89 5d d8             	mov    %ebx,-0x28(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8014ac:	89 ca                	mov    %ecx,%edx
  8014ae:	8d 45 14             	lea    0x14(%ebp),%eax
  8014b1:	e8 2a fd ff ff       	call   8011e0 <getint>
  8014b6:	89 c3                	mov    %eax,%ebx
  8014b8:	89 d6                	mov    %edx,%esi
			if ((long long) num < 0) {
  8014ba:	85 d2                	test   %edx,%edx
  8014bc:	78 0a                	js     8014c8 <vprintfmt+0x27f>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8014be:	b8 0a 00 00 00       	mov    $0xa,%eax
  8014c3:	e9 b0 00 00 00       	jmp    801578 <vprintfmt+0x32f>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  8014c8:	83 ec 08             	sub    $0x8,%esp
  8014cb:	57                   	push   %edi
  8014cc:	6a 2d                	push   $0x2d
  8014ce:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  8014d1:	f7 db                	neg    %ebx
  8014d3:	83 d6 00             	adc    $0x0,%esi
  8014d6:	f7 de                	neg    %esi
  8014d8:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  8014db:	b8 0a 00 00 00       	mov    $0xa,%eax
  8014e0:	e9 93 00 00 00       	jmp    801578 <vprintfmt+0x32f>
  8014e5:	89 5d d8             	mov    %ebx,-0x28(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8014e8:	89 ca                	mov    %ecx,%edx
  8014ea:	8d 45 14             	lea    0x14(%ebp),%eax
  8014ed:	e8 b4 fc ff ff       	call   8011a6 <getuint>
  8014f2:	89 c3                	mov    %eax,%ebx
  8014f4:	89 d6                	mov    %edx,%esi
			base = 10;
  8014f6:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  8014fb:	eb 7b                	jmp    801578 <vprintfmt+0x32f>
  8014fd:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// (unsigned) octal
		case 'o':
            // (MIT 6.828, lab1, Ex.8)  my code : 
            num = getint(&ap, lflag);
  801500:	89 ca                	mov    %ecx,%edx
  801502:	8d 45 14             	lea    0x14(%ebp),%eax
  801505:	e8 d6 fc ff ff       	call   8011e0 <getint>
  80150a:	89 c3                	mov    %eax,%ebx
  80150c:	89 d6                	mov    %edx,%esi
            if ((long long) num < 0) {
  80150e:	85 d2                	test   %edx,%edx
  801510:	78 07                	js     801519 <vprintfmt+0x2d0>
                putch('-', putdat);
                num = -(long long) num;
            }
            base = 8;
  801512:	b8 08 00 00 00       	mov    $0x8,%eax
  801517:	eb 5f                	jmp    801578 <vprintfmt+0x32f>
		// (unsigned) octal
		case 'o':
            // (MIT 6.828, lab1, Ex.8)  my code : 
            num = getint(&ap, lflag);
            if ((long long) num < 0) {
                putch('-', putdat);
  801519:	83 ec 08             	sub    $0x8,%esp
  80151c:	57                   	push   %edi
  80151d:	6a 2d                	push   $0x2d
  80151f:	ff 55 08             	call   *0x8(%ebp)
                num = -(long long) num;
  801522:	f7 db                	neg    %ebx
  801524:	83 d6 00             	adc    $0x0,%esi
  801527:	f7 de                	neg    %esi
  801529:	83 c4 10             	add    $0x10,%esp
            }
            base = 8;
  80152c:	b8 08 00 00 00       	mov    $0x8,%eax
  801531:	eb 45                	jmp    801578 <vprintfmt+0x32f>
  801533:	89 5d d8             	mov    %ebx,-0x28(%ebp)
            goto number;

        // pointer
		case 'p':
			putch('0', putdat);
  801536:	83 ec 08             	sub    $0x8,%esp
  801539:	57                   	push   %edi
  80153a:	6a 30                	push   $0x30
  80153c:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  80153f:	83 c4 08             	add    $0x8,%esp
  801542:	57                   	push   %edi
  801543:	6a 78                	push   $0x78
  801545:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  801548:	8b 45 14             	mov    0x14(%ebp),%eax
  80154b:	8d 50 04             	lea    0x4(%eax),%edx
  80154e:	89 55 14             	mov    %edx,0x14(%ebp)

        // pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  801551:	8b 18                	mov    (%eax),%ebx
  801553:	be 00 00 00 00       	mov    $0x0,%esi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  801558:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  80155b:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  801560:	eb 16                	jmp    801578 <vprintfmt+0x32f>
  801562:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  801565:	89 ca                	mov    %ecx,%edx
  801567:	8d 45 14             	lea    0x14(%ebp),%eax
  80156a:	e8 37 fc ff ff       	call   8011a6 <getuint>
  80156f:	89 c3                	mov    %eax,%ebx
  801571:	89 d6                	mov    %edx,%esi
			base = 16;
  801573:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  801578:	83 ec 0c             	sub    $0xc,%esp
  80157b:	0f be 55 dc          	movsbl -0x24(%ebp),%edx
  80157f:	52                   	push   %edx
  801580:	ff 75 e4             	pushl  -0x1c(%ebp)
  801583:	50                   	push   %eax
  801584:	56                   	push   %esi
  801585:	53                   	push   %ebx
  801586:	89 fa                	mov    %edi,%edx
  801588:	8b 45 08             	mov    0x8(%ebp),%eax
  80158b:	e8 68 fb ff ff       	call   8010f8 <printnum>
			break;
  801590:	83 c4 20             	add    $0x20,%esp
  801593:	8b 75 d8             	mov    -0x28(%ebp),%esi
  801596:	e9 d2 fc ff ff       	jmp    80126d <vprintfmt+0x24>
  80159b:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80159e:	83 ec 08             	sub    $0x8,%esp
  8015a1:	57                   	push   %edi
  8015a2:	52                   	push   %edx
  8015a3:	ff 55 08             	call   *0x8(%ebp)
			break;
  8015a6:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8015a9:	8b 75 d8             	mov    -0x28(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8015ac:	e9 bc fc ff ff       	jmp    80126d <vprintfmt+0x24>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8015b1:	83 ec 08             	sub    $0x8,%esp
  8015b4:	57                   	push   %edi
  8015b5:	6a 25                	push   $0x25
  8015b7:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  8015ba:	83 c4 10             	add    $0x10,%esp
  8015bd:	eb 02                	jmp    8015c1 <vprintfmt+0x378>
  8015bf:	89 c6                	mov    %eax,%esi
  8015c1:	8d 46 ff             	lea    -0x1(%esi),%eax
  8015c4:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  8015c8:	75 f5                	jne    8015bf <vprintfmt+0x376>
  8015ca:	e9 9e fc ff ff       	jmp    80126d <vprintfmt+0x24>
				/* do nothing */;
			break;
		}
	}
}
  8015cf:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8015d2:	5b                   	pop    %ebx
  8015d3:	5e                   	pop    %esi
  8015d4:	5f                   	pop    %edi
  8015d5:	c9                   	leave  
  8015d6:	c3                   	ret    

008015d7 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8015d7:	55                   	push   %ebp
  8015d8:	89 e5                	mov    %esp,%ebp
  8015da:	83 ec 18             	sub    $0x18,%esp
  8015dd:	8b 45 08             	mov    0x8(%ebp),%eax
  8015e0:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8015e3:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8015e6:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8015ea:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8015ed:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8015f4:	85 c0                	test   %eax,%eax
  8015f6:	74 26                	je     80161e <vsnprintf+0x47>
  8015f8:	85 d2                	test   %edx,%edx
  8015fa:	7e 29                	jle    801625 <vsnprintf+0x4e>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8015fc:	ff 75 14             	pushl  0x14(%ebp)
  8015ff:	ff 75 10             	pushl  0x10(%ebp)
  801602:	8d 45 ec             	lea    -0x14(%ebp),%eax
  801605:	50                   	push   %eax
  801606:	68 12 12 80 00       	push   $0x801212
  80160b:	e8 39 fc ff ff       	call   801249 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  801610:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801613:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  801616:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801619:	83 c4 10             	add    $0x10,%esp
  80161c:	eb 0c                	jmp    80162a <vsnprintf+0x53>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  80161e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801623:	eb 05                	jmp    80162a <vsnprintf+0x53>
  801625:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  80162a:	c9                   	leave  
  80162b:	c3                   	ret    

0080162c <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80162c:	55                   	push   %ebp
  80162d:	89 e5                	mov    %esp,%ebp
  80162f:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  801632:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  801635:	50                   	push   %eax
  801636:	ff 75 10             	pushl  0x10(%ebp)
  801639:	ff 75 0c             	pushl  0xc(%ebp)
  80163c:	ff 75 08             	pushl  0x8(%ebp)
  80163f:	e8 93 ff ff ff       	call   8015d7 <vsnprintf>
	va_end(ap);

	return rc;
}
  801644:	c9                   	leave  
  801645:	c3                   	ret    
	...

00801648 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  801648:	55                   	push   %ebp
  801649:	89 e5                	mov    %esp,%ebp
  80164b:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80164e:	80 3a 00             	cmpb   $0x0,(%edx)
  801651:	74 0e                	je     801661 <strlen+0x19>
  801653:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  801658:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  801659:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  80165d:	75 f9                	jne    801658 <strlen+0x10>
  80165f:	eb 05                	jmp    801666 <strlen+0x1e>
  801661:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  801666:	c9                   	leave  
  801667:	c3                   	ret    

00801668 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  801668:	55                   	push   %ebp
  801669:	89 e5                	mov    %esp,%ebp
  80166b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80166e:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801671:	85 d2                	test   %edx,%edx
  801673:	74 17                	je     80168c <strnlen+0x24>
  801675:	80 39 00             	cmpb   $0x0,(%ecx)
  801678:	74 19                	je     801693 <strnlen+0x2b>
  80167a:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  80167f:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801680:	39 d0                	cmp    %edx,%eax
  801682:	74 14                	je     801698 <strnlen+0x30>
  801684:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  801688:	75 f5                	jne    80167f <strnlen+0x17>
  80168a:	eb 0c                	jmp    801698 <strnlen+0x30>
  80168c:	b8 00 00 00 00       	mov    $0x0,%eax
  801691:	eb 05                	jmp    801698 <strnlen+0x30>
  801693:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  801698:	c9                   	leave  
  801699:	c3                   	ret    

0080169a <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80169a:	55                   	push   %ebp
  80169b:	89 e5                	mov    %esp,%ebp
  80169d:	53                   	push   %ebx
  80169e:	8b 45 08             	mov    0x8(%ebp),%eax
  8016a1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8016a4:	ba 00 00 00 00       	mov    $0x0,%edx
  8016a9:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  8016ac:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  8016af:	42                   	inc    %edx
  8016b0:	84 c9                	test   %cl,%cl
  8016b2:	75 f5                	jne    8016a9 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  8016b4:	5b                   	pop    %ebx
  8016b5:	c9                   	leave  
  8016b6:	c3                   	ret    

008016b7 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8016b7:	55                   	push   %ebp
  8016b8:	89 e5                	mov    %esp,%ebp
  8016ba:	53                   	push   %ebx
  8016bb:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8016be:	53                   	push   %ebx
  8016bf:	e8 84 ff ff ff       	call   801648 <strlen>
  8016c4:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8016c7:	ff 75 0c             	pushl  0xc(%ebp)
  8016ca:	8d 04 03             	lea    (%ebx,%eax,1),%eax
  8016cd:	50                   	push   %eax
  8016ce:	e8 c7 ff ff ff       	call   80169a <strcpy>
	return dst;
}
  8016d3:	89 d8                	mov    %ebx,%eax
  8016d5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016d8:	c9                   	leave  
  8016d9:	c3                   	ret    

008016da <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8016da:	55                   	push   %ebp
  8016db:	89 e5                	mov    %esp,%ebp
  8016dd:	56                   	push   %esi
  8016de:	53                   	push   %ebx
  8016df:	8b 45 08             	mov    0x8(%ebp),%eax
  8016e2:	8b 55 0c             	mov    0xc(%ebp),%edx
  8016e5:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8016e8:	85 f6                	test   %esi,%esi
  8016ea:	74 15                	je     801701 <strncpy+0x27>
  8016ec:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
  8016f1:	8a 1a                	mov    (%edx),%bl
  8016f3:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8016f6:	80 3a 01             	cmpb   $0x1,(%edx)
  8016f9:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8016fc:	41                   	inc    %ecx
  8016fd:	39 ce                	cmp    %ecx,%esi
  8016ff:	77 f0                	ja     8016f1 <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  801701:	5b                   	pop    %ebx
  801702:	5e                   	pop    %esi
  801703:	c9                   	leave  
  801704:	c3                   	ret    

00801705 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  801705:	55                   	push   %ebp
  801706:	89 e5                	mov    %esp,%ebp
  801708:	57                   	push   %edi
  801709:	56                   	push   %esi
  80170a:	53                   	push   %ebx
  80170b:	8b 7d 08             	mov    0x8(%ebp),%edi
  80170e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801711:	8b 75 10             	mov    0x10(%ebp),%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  801714:	85 f6                	test   %esi,%esi
  801716:	74 32                	je     80174a <strlcpy+0x45>
		while (--size > 0 && *src != '\0')
  801718:	83 fe 01             	cmp    $0x1,%esi
  80171b:	74 22                	je     80173f <strlcpy+0x3a>
  80171d:	8a 0b                	mov    (%ebx),%cl
  80171f:	84 c9                	test   %cl,%cl
  801721:	74 20                	je     801743 <strlcpy+0x3e>
  801723:	89 f8                	mov    %edi,%eax
  801725:	ba 00 00 00 00       	mov    $0x0,%edx
	}
	return ret;
}

size_t
strlcpy(char *dst, const char *src, size_t size)
  80172a:	83 ee 02             	sub    $0x2,%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  80172d:	88 08                	mov    %cl,(%eax)
  80172f:	40                   	inc    %eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  801730:	39 f2                	cmp    %esi,%edx
  801732:	74 11                	je     801745 <strlcpy+0x40>
  801734:	8a 4c 13 01          	mov    0x1(%ebx,%edx,1),%cl
  801738:	42                   	inc    %edx
  801739:	84 c9                	test   %cl,%cl
  80173b:	75 f0                	jne    80172d <strlcpy+0x28>
  80173d:	eb 06                	jmp    801745 <strlcpy+0x40>
  80173f:	89 f8                	mov    %edi,%eax
  801741:	eb 02                	jmp    801745 <strlcpy+0x40>
  801743:	89 f8                	mov    %edi,%eax
			*dst++ = *src++;
		*dst = '\0';
  801745:	c6 00 00             	movb   $0x0,(%eax)
  801748:	eb 02                	jmp    80174c <strlcpy+0x47>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80174a:	89 f8                	mov    %edi,%eax
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
		*dst = '\0';
	}
	return dst - dst_in;
  80174c:	29 f8                	sub    %edi,%eax
}
  80174e:	5b                   	pop    %ebx
  80174f:	5e                   	pop    %esi
  801750:	5f                   	pop    %edi
  801751:	c9                   	leave  
  801752:	c3                   	ret    

00801753 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  801753:	55                   	push   %ebp
  801754:	89 e5                	mov    %esp,%ebp
  801756:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801759:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80175c:	8a 01                	mov    (%ecx),%al
  80175e:	84 c0                	test   %al,%al
  801760:	74 10                	je     801772 <strcmp+0x1f>
  801762:	3a 02                	cmp    (%edx),%al
  801764:	75 0c                	jne    801772 <strcmp+0x1f>
		p++, q++;
  801766:	41                   	inc    %ecx
  801767:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  801768:	8a 01                	mov    (%ecx),%al
  80176a:	84 c0                	test   %al,%al
  80176c:	74 04                	je     801772 <strcmp+0x1f>
  80176e:	3a 02                	cmp    (%edx),%al
  801770:	74 f4                	je     801766 <strcmp+0x13>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  801772:	0f b6 c0             	movzbl %al,%eax
  801775:	0f b6 12             	movzbl (%edx),%edx
  801778:	29 d0                	sub    %edx,%eax
}
  80177a:	c9                   	leave  
  80177b:	c3                   	ret    

0080177c <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  80177c:	55                   	push   %ebp
  80177d:	89 e5                	mov    %esp,%ebp
  80177f:	53                   	push   %ebx
  801780:	8b 55 08             	mov    0x8(%ebp),%edx
  801783:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801786:	8b 45 10             	mov    0x10(%ebp),%eax
	while (n > 0 && *p && *p == *q)
  801789:	85 c0                	test   %eax,%eax
  80178b:	74 1b                	je     8017a8 <strncmp+0x2c>
  80178d:	8a 1a                	mov    (%edx),%bl
  80178f:	84 db                	test   %bl,%bl
  801791:	74 24                	je     8017b7 <strncmp+0x3b>
  801793:	3a 19                	cmp    (%ecx),%bl
  801795:	75 20                	jne    8017b7 <strncmp+0x3b>
  801797:	48                   	dec    %eax
  801798:	74 15                	je     8017af <strncmp+0x33>
		n--, p++, q++;
  80179a:	42                   	inc    %edx
  80179b:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  80179c:	8a 1a                	mov    (%edx),%bl
  80179e:	84 db                	test   %bl,%bl
  8017a0:	74 15                	je     8017b7 <strncmp+0x3b>
  8017a2:	3a 19                	cmp    (%ecx),%bl
  8017a4:	74 f1                	je     801797 <strncmp+0x1b>
  8017a6:	eb 0f                	jmp    8017b7 <strncmp+0x3b>
		n--, p++, q++;
	if (n == 0)
		return 0;
  8017a8:	b8 00 00 00 00       	mov    $0x0,%eax
  8017ad:	eb 05                	jmp    8017b4 <strncmp+0x38>
  8017af:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8017b4:	5b                   	pop    %ebx
  8017b5:	c9                   	leave  
  8017b6:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8017b7:	0f b6 02             	movzbl (%edx),%eax
  8017ba:	0f b6 11             	movzbl (%ecx),%edx
  8017bd:	29 d0                	sub    %edx,%eax
  8017bf:	eb f3                	jmp    8017b4 <strncmp+0x38>

008017c1 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8017c1:	55                   	push   %ebp
  8017c2:	89 e5                	mov    %esp,%ebp
  8017c4:	8b 45 08             	mov    0x8(%ebp),%eax
  8017c7:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  8017ca:	8a 10                	mov    (%eax),%dl
  8017cc:	84 d2                	test   %dl,%dl
  8017ce:	74 18                	je     8017e8 <strchr+0x27>
		if (*s == c)
  8017d0:	38 ca                	cmp    %cl,%dl
  8017d2:	75 06                	jne    8017da <strchr+0x19>
  8017d4:	eb 17                	jmp    8017ed <strchr+0x2c>
  8017d6:	38 ca                	cmp    %cl,%dl
  8017d8:	74 13                	je     8017ed <strchr+0x2c>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8017da:	40                   	inc    %eax
  8017db:	8a 10                	mov    (%eax),%dl
  8017dd:	84 d2                	test   %dl,%dl
  8017df:	75 f5                	jne    8017d6 <strchr+0x15>
		if (*s == c)
			return (char *) s;
	return 0;
  8017e1:	b8 00 00 00 00       	mov    $0x0,%eax
  8017e6:	eb 05                	jmp    8017ed <strchr+0x2c>
  8017e8:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8017ed:	c9                   	leave  
  8017ee:	c3                   	ret    

008017ef <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8017ef:	55                   	push   %ebp
  8017f0:	89 e5                	mov    %esp,%ebp
  8017f2:	8b 45 08             	mov    0x8(%ebp),%eax
  8017f5:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  8017f8:	8a 10                	mov    (%eax),%dl
  8017fa:	84 d2                	test   %dl,%dl
  8017fc:	74 11                	je     80180f <strfind+0x20>
		if (*s == c)
  8017fe:	38 ca                	cmp    %cl,%dl
  801800:	75 06                	jne    801808 <strfind+0x19>
  801802:	eb 0b                	jmp    80180f <strfind+0x20>
  801804:	38 ca                	cmp    %cl,%dl
  801806:	74 07                	je     80180f <strfind+0x20>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  801808:	40                   	inc    %eax
  801809:	8a 10                	mov    (%eax),%dl
  80180b:	84 d2                	test   %dl,%dl
  80180d:	75 f5                	jne    801804 <strfind+0x15>
		if (*s == c)
			break;
	return (char *) s;
}
  80180f:	c9                   	leave  
  801810:	c3                   	ret    

00801811 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  801811:	55                   	push   %ebp
  801812:	89 e5                	mov    %esp,%ebp
  801814:	57                   	push   %edi
  801815:	56                   	push   %esi
  801816:	53                   	push   %ebx
  801817:	8b 7d 08             	mov    0x8(%ebp),%edi
  80181a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80181d:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  801820:	85 c9                	test   %ecx,%ecx
  801822:	74 30                	je     801854 <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  801824:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80182a:	75 25                	jne    801851 <memset+0x40>
  80182c:	f6 c1 03             	test   $0x3,%cl
  80182f:	75 20                	jne    801851 <memset+0x40>
		c &= 0xFF;
  801831:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  801834:	89 d3                	mov    %edx,%ebx
  801836:	c1 e3 08             	shl    $0x8,%ebx
  801839:	89 d6                	mov    %edx,%esi
  80183b:	c1 e6 18             	shl    $0x18,%esi
  80183e:	89 d0                	mov    %edx,%eax
  801840:	c1 e0 10             	shl    $0x10,%eax
  801843:	09 f0                	or     %esi,%eax
  801845:	09 d0                	or     %edx,%eax
  801847:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  801849:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  80184c:	fc                   	cld    
  80184d:	f3 ab                	rep stos %eax,%es:(%edi)
  80184f:	eb 03                	jmp    801854 <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  801851:	fc                   	cld    
  801852:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  801854:	89 f8                	mov    %edi,%eax
  801856:	5b                   	pop    %ebx
  801857:	5e                   	pop    %esi
  801858:	5f                   	pop    %edi
  801859:	c9                   	leave  
  80185a:	c3                   	ret    

0080185b <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  80185b:	55                   	push   %ebp
  80185c:	89 e5                	mov    %esp,%ebp
  80185e:	57                   	push   %edi
  80185f:	56                   	push   %esi
  801860:	8b 45 08             	mov    0x8(%ebp),%eax
  801863:	8b 75 0c             	mov    0xc(%ebp),%esi
  801866:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  801869:	39 c6                	cmp    %eax,%esi
  80186b:	73 34                	jae    8018a1 <memmove+0x46>
  80186d:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  801870:	39 d0                	cmp    %edx,%eax
  801872:	73 2d                	jae    8018a1 <memmove+0x46>
		s += n;
		d += n;
  801874:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801877:	f6 c2 03             	test   $0x3,%dl
  80187a:	75 1b                	jne    801897 <memmove+0x3c>
  80187c:	f7 c7 03 00 00 00    	test   $0x3,%edi
  801882:	75 13                	jne    801897 <memmove+0x3c>
  801884:	f6 c1 03             	test   $0x3,%cl
  801887:	75 0e                	jne    801897 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  801889:	83 ef 04             	sub    $0x4,%edi
  80188c:	8d 72 fc             	lea    -0x4(%edx),%esi
  80188f:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  801892:	fd                   	std    
  801893:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801895:	eb 07                	jmp    80189e <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  801897:	4f                   	dec    %edi
  801898:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  80189b:	fd                   	std    
  80189c:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  80189e:	fc                   	cld    
  80189f:	eb 20                	jmp    8018c1 <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8018a1:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8018a7:	75 13                	jne    8018bc <memmove+0x61>
  8018a9:	a8 03                	test   $0x3,%al
  8018ab:	75 0f                	jne    8018bc <memmove+0x61>
  8018ad:	f6 c1 03             	test   $0x3,%cl
  8018b0:	75 0a                	jne    8018bc <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  8018b2:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  8018b5:	89 c7                	mov    %eax,%edi
  8018b7:	fc                   	cld    
  8018b8:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8018ba:	eb 05                	jmp    8018c1 <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8018bc:	89 c7                	mov    %eax,%edi
  8018be:	fc                   	cld    
  8018bf:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8018c1:	5e                   	pop    %esi
  8018c2:	5f                   	pop    %edi
  8018c3:	c9                   	leave  
  8018c4:	c3                   	ret    

008018c5 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8018c5:	55                   	push   %ebp
  8018c6:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  8018c8:	ff 75 10             	pushl  0x10(%ebp)
  8018cb:	ff 75 0c             	pushl  0xc(%ebp)
  8018ce:	ff 75 08             	pushl  0x8(%ebp)
  8018d1:	e8 85 ff ff ff       	call   80185b <memmove>
}
  8018d6:	c9                   	leave  
  8018d7:	c3                   	ret    

008018d8 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8018d8:	55                   	push   %ebp
  8018d9:	89 e5                	mov    %esp,%ebp
  8018db:	57                   	push   %edi
  8018dc:	56                   	push   %esi
  8018dd:	53                   	push   %ebx
  8018de:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8018e1:	8b 75 0c             	mov    0xc(%ebp),%esi
  8018e4:	8b 7d 10             	mov    0x10(%ebp),%edi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8018e7:	85 ff                	test   %edi,%edi
  8018e9:	74 32                	je     80191d <memcmp+0x45>
		if (*s1 != *s2)
  8018eb:	8a 03                	mov    (%ebx),%al
  8018ed:	8a 0e                	mov    (%esi),%cl
  8018ef:	38 c8                	cmp    %cl,%al
  8018f1:	74 19                	je     80190c <memcmp+0x34>
  8018f3:	eb 0d                	jmp    801902 <memcmp+0x2a>
  8018f5:	8a 44 13 01          	mov    0x1(%ebx,%edx,1),%al
  8018f9:	8a 4c 16 01          	mov    0x1(%esi,%edx,1),%cl
  8018fd:	42                   	inc    %edx
  8018fe:	38 c8                	cmp    %cl,%al
  801900:	74 10                	je     801912 <memcmp+0x3a>
			return (int) *s1 - (int) *s2;
  801902:	0f b6 c0             	movzbl %al,%eax
  801905:	0f b6 c9             	movzbl %cl,%ecx
  801908:	29 c8                	sub    %ecx,%eax
  80190a:	eb 16                	jmp    801922 <memcmp+0x4a>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  80190c:	4f                   	dec    %edi
  80190d:	ba 00 00 00 00       	mov    $0x0,%edx
  801912:	39 fa                	cmp    %edi,%edx
  801914:	75 df                	jne    8018f5 <memcmp+0x1d>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  801916:	b8 00 00 00 00       	mov    $0x0,%eax
  80191b:	eb 05                	jmp    801922 <memcmp+0x4a>
  80191d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801922:	5b                   	pop    %ebx
  801923:	5e                   	pop    %esi
  801924:	5f                   	pop    %edi
  801925:	c9                   	leave  
  801926:	c3                   	ret    

00801927 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  801927:	55                   	push   %ebp
  801928:	89 e5                	mov    %esp,%ebp
  80192a:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  80192d:	89 c2                	mov    %eax,%edx
  80192f:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  801932:	39 d0                	cmp    %edx,%eax
  801934:	73 12                	jae    801948 <memfind+0x21>
		if (*(const unsigned char *) s == (unsigned char) c)
  801936:	8a 4d 0c             	mov    0xc(%ebp),%cl
  801939:	38 08                	cmp    %cl,(%eax)
  80193b:	75 06                	jne    801943 <memfind+0x1c>
  80193d:	eb 09                	jmp    801948 <memfind+0x21>
  80193f:	38 08                	cmp    %cl,(%eax)
  801941:	74 05                	je     801948 <memfind+0x21>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801943:	40                   	inc    %eax
  801944:	39 c2                	cmp    %eax,%edx
  801946:	77 f7                	ja     80193f <memfind+0x18>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  801948:	c9                   	leave  
  801949:	c3                   	ret    

0080194a <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  80194a:	55                   	push   %ebp
  80194b:	89 e5                	mov    %esp,%ebp
  80194d:	57                   	push   %edi
  80194e:	56                   	push   %esi
  80194f:	53                   	push   %ebx
  801950:	8b 55 08             	mov    0x8(%ebp),%edx
  801953:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801956:	eb 01                	jmp    801959 <strtol+0xf>
		s++;
  801958:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801959:	8a 02                	mov    (%edx),%al
  80195b:	3c 20                	cmp    $0x20,%al
  80195d:	74 f9                	je     801958 <strtol+0xe>
  80195f:	3c 09                	cmp    $0x9,%al
  801961:	74 f5                	je     801958 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  801963:	3c 2b                	cmp    $0x2b,%al
  801965:	75 08                	jne    80196f <strtol+0x25>
		s++;
  801967:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  801968:	bf 00 00 00 00       	mov    $0x0,%edi
  80196d:	eb 13                	jmp    801982 <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  80196f:	3c 2d                	cmp    $0x2d,%al
  801971:	75 0a                	jne    80197d <strtol+0x33>
		s++, neg = 1;
  801973:	8d 52 01             	lea    0x1(%edx),%edx
  801976:	bf 01 00 00 00       	mov    $0x1,%edi
  80197b:	eb 05                	jmp    801982 <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  80197d:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801982:	85 db                	test   %ebx,%ebx
  801984:	74 05                	je     80198b <strtol+0x41>
  801986:	83 fb 10             	cmp    $0x10,%ebx
  801989:	75 28                	jne    8019b3 <strtol+0x69>
  80198b:	8a 02                	mov    (%edx),%al
  80198d:	3c 30                	cmp    $0x30,%al
  80198f:	75 10                	jne    8019a1 <strtol+0x57>
  801991:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  801995:	75 0a                	jne    8019a1 <strtol+0x57>
		s += 2, base = 16;
  801997:	83 c2 02             	add    $0x2,%edx
  80199a:	bb 10 00 00 00       	mov    $0x10,%ebx
  80199f:	eb 12                	jmp    8019b3 <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  8019a1:	85 db                	test   %ebx,%ebx
  8019a3:	75 0e                	jne    8019b3 <strtol+0x69>
  8019a5:	3c 30                	cmp    $0x30,%al
  8019a7:	75 05                	jne    8019ae <strtol+0x64>
		s++, base = 8;
  8019a9:	42                   	inc    %edx
  8019aa:	b3 08                	mov    $0x8,%bl
  8019ac:	eb 05                	jmp    8019b3 <strtol+0x69>
	else if (base == 0)
		base = 10;
  8019ae:	bb 0a 00 00 00       	mov    $0xa,%ebx
  8019b3:	b8 00 00 00 00       	mov    $0x0,%eax
  8019b8:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  8019ba:	8a 0a                	mov    (%edx),%cl
  8019bc:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  8019bf:	80 fb 09             	cmp    $0x9,%bl
  8019c2:	77 08                	ja     8019cc <strtol+0x82>
			dig = *s - '0';
  8019c4:	0f be c9             	movsbl %cl,%ecx
  8019c7:	83 e9 30             	sub    $0x30,%ecx
  8019ca:	eb 1e                	jmp    8019ea <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  8019cc:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  8019cf:	80 fb 19             	cmp    $0x19,%bl
  8019d2:	77 08                	ja     8019dc <strtol+0x92>
			dig = *s - 'a' + 10;
  8019d4:	0f be c9             	movsbl %cl,%ecx
  8019d7:	83 e9 57             	sub    $0x57,%ecx
  8019da:	eb 0e                	jmp    8019ea <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  8019dc:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  8019df:	80 fb 19             	cmp    $0x19,%bl
  8019e2:	77 13                	ja     8019f7 <strtol+0xad>
			dig = *s - 'A' + 10;
  8019e4:	0f be c9             	movsbl %cl,%ecx
  8019e7:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  8019ea:	39 f1                	cmp    %esi,%ecx
  8019ec:	7d 0d                	jge    8019fb <strtol+0xb1>
			break;
		s++, val = (val * base) + dig;
  8019ee:	42                   	inc    %edx
  8019ef:	0f af c6             	imul   %esi,%eax
  8019f2:	8d 04 01             	lea    (%ecx,%eax,1),%eax
		// we don't properly detect overflow!
	}
  8019f5:	eb c3                	jmp    8019ba <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  8019f7:	89 c1                	mov    %eax,%ecx
  8019f9:	eb 02                	jmp    8019fd <strtol+0xb3>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  8019fb:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  8019fd:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801a01:	74 05                	je     801a08 <strtol+0xbe>
		*endptr = (char *) s;
  801a03:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801a06:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  801a08:	85 ff                	test   %edi,%edi
  801a0a:	74 04                	je     801a10 <strtol+0xc6>
  801a0c:	89 c8                	mov    %ecx,%eax
  801a0e:	f7 d8                	neg    %eax
}
  801a10:	5b                   	pop    %ebx
  801a11:	5e                   	pop    %esi
  801a12:	5f                   	pop    %edi
  801a13:	c9                   	leave  
  801a14:	c3                   	ret    
  801a15:	00 00                	add    %al,(%eax)
	...

00801a18 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801a18:	55                   	push   %ebp
  801a19:	89 e5                	mov    %esp,%ebp
  801a1b:	56                   	push   %esi
  801a1c:	53                   	push   %ebx
  801a1d:	8b 75 08             	mov    0x8(%ebp),%esi
  801a20:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a23:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// cprintf("0x%x 0x%x 0x%x\n", (uint32_t)from_env_store, (uint32_t)pg, (uint32_t)perm_store);
	int r;
	if (pg != NULL) {
  801a26:	85 c0                	test   %eax,%eax
  801a28:	74 0e                	je     801a38 <ipc_recv+0x20>
		r = sys_ipc_recv(pg);
  801a2a:	83 ec 0c             	sub    $0xc,%esp
  801a2d:	50                   	push   %eax
  801a2e:	e8 74 e8 ff ff       	call   8002a7 <sys_ipc_recv>
  801a33:	83 c4 10             	add    $0x10,%esp
  801a36:	eb 10                	jmp    801a48 <ipc_recv+0x30>
	} else {
		r = sys_ipc_recv((void *)UTOP);
  801a38:	83 ec 0c             	sub    $0xc,%esp
  801a3b:	68 00 00 c0 ee       	push   $0xeec00000
  801a40:	e8 62 e8 ff ff       	call   8002a7 <sys_ipc_recv>
  801a45:	83 c4 10             	add    $0x10,%esp
	}

	if (r == 0) {
  801a48:	85 c0                	test   %eax,%eax
  801a4a:	75 26                	jne    801a72 <ipc_recv+0x5a>
		if (from_env_store != NULL) *from_env_store = thisenv->env_ipc_from;
  801a4c:	85 f6                	test   %esi,%esi
  801a4e:	74 0a                	je     801a5a <ipc_recv+0x42>
  801a50:	a1 04 40 80 00       	mov    0x804004,%eax
  801a55:	8b 40 74             	mov    0x74(%eax),%eax
  801a58:	89 06                	mov    %eax,(%esi)
		if (perm_store != NULL) *perm_store = thisenv->env_ipc_perm;
  801a5a:	85 db                	test   %ebx,%ebx
  801a5c:	74 0a                	je     801a68 <ipc_recv+0x50>
  801a5e:	a1 04 40 80 00       	mov    0x804004,%eax
  801a63:	8b 40 78             	mov    0x78(%eax),%eax
  801a66:	89 03                	mov    %eax,(%ebx)
		return thisenv->env_ipc_value;
  801a68:	a1 04 40 80 00       	mov    0x804004,%eax
  801a6d:	8b 40 70             	mov    0x70(%eax),%eax
  801a70:	eb 14                	jmp    801a86 <ipc_recv+0x6e>
	} else {
		// fails;
		if (from_env_store != NULL) *from_env_store = 0;
  801a72:	85 f6                	test   %esi,%esi
  801a74:	74 06                	je     801a7c <ipc_recv+0x64>
  801a76:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		if (perm_store != NULL) *perm_store = 0;
  801a7c:	85 db                	test   %ebx,%ebx
  801a7e:	74 06                	je     801a86 <ipc_recv+0x6e>
  801a80:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
		return r;
	}
}
  801a86:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a89:	5b                   	pop    %ebx
  801a8a:	5e                   	pop    %esi
  801a8b:	c9                   	leave  
  801a8c:	c3                   	ret    

00801a8d <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801a8d:	55                   	push   %ebp
  801a8e:	89 e5                	mov    %esp,%ebp
  801a90:	57                   	push   %edi
  801a91:	56                   	push   %esi
  801a92:	53                   	push   %ebx
  801a93:	83 ec 0c             	sub    $0xc,%esp
  801a96:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801a99:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801a9c:	8b 75 14             	mov    0x14(%ebp),%esi
	// LAB 4: Your code here.
	// int sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
	int r;
	if (pg == NULL) pg = (void *)UTOP;
  801a9f:	85 db                	test   %ebx,%ebx
  801aa1:	75 25                	jne    801ac8 <ipc_send+0x3b>
  801aa3:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
  801aa8:	eb 1e                	jmp    801ac8 <ipc_send+0x3b>
	
	while ((r = sys_ipc_try_send(to_env, val, pg, perm)) != 0) {
		if (r == -E_IPC_NOT_RECV) {
  801aaa:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801aad:	75 07                	jne    801ab6 <ipc_send+0x29>
			// cprintf("Try Again and Again....\n");
			sys_yield();
  801aaf:	e8 d1 e6 ff ff       	call   800185 <sys_yield>
  801ab4:	eb 12                	jmp    801ac8 <ipc_send+0x3b>
		} else {
			panic("ipc_send error %e\n", r);
  801ab6:	50                   	push   %eax
  801ab7:	68 00 22 80 00       	push   $0x802200
  801abc:	6a 43                	push   $0x43
  801abe:	68 13 22 80 00       	push   $0x802213
  801ac3:	e8 44 f5 ff ff       	call   80100c <_panic>
	// LAB 4: Your code here.
	// int sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
	int r;
	if (pg == NULL) pg = (void *)UTOP;
	
	while ((r = sys_ipc_try_send(to_env, val, pg, perm)) != 0) {
  801ac8:	56                   	push   %esi
  801ac9:	53                   	push   %ebx
  801aca:	57                   	push   %edi
  801acb:	ff 75 08             	pushl  0x8(%ebp)
  801ace:	e8 af e7 ff ff       	call   800282 <sys_ipc_try_send>
  801ad3:	83 c4 10             	add    $0x10,%esp
  801ad6:	85 c0                	test   %eax,%eax
  801ad8:	75 d0                	jne    801aaa <ipc_send+0x1d>
		} else {
			panic("ipc_send error %e\n", r);
		}
	}
	return;
}
  801ada:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801add:	5b                   	pop    %ebx
  801ade:	5e                   	pop    %esi
  801adf:	5f                   	pop    %edi
  801ae0:	c9                   	leave  
  801ae1:	c3                   	ret    

00801ae2 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801ae2:	55                   	push   %ebp
  801ae3:	89 e5                	mov    %esp,%ebp
  801ae5:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
		if (envs[i].env_type == type)
  801ae8:	39 0d 50 00 c0 ee    	cmp    %ecx,0xeec00050
  801aee:	74 1a                	je     801b0a <ipc_find_env+0x28>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801af0:	b8 01 00 00 00       	mov    $0x1,%eax
		if (envs[i].env_type == type)
  801af5:	89 c2                	mov    %eax,%edx
  801af7:	c1 e2 07             	shl    $0x7,%edx
  801afa:	8d 94 82 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,4),%edx
  801b01:	8b 52 50             	mov    0x50(%edx),%edx
  801b04:	39 ca                	cmp    %ecx,%edx
  801b06:	75 18                	jne    801b20 <ipc_find_env+0x3e>
  801b08:	eb 05                	jmp    801b0f <ipc_find_env+0x2d>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801b0a:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
			return envs[i].env_id;
  801b0f:	89 c2                	mov    %eax,%edx
  801b11:	c1 e2 07             	shl    $0x7,%edx
  801b14:	8d 84 82 08 00 c0 ee 	lea    -0x113ffff8(%edx,%eax,4),%eax
  801b1b:	8b 40 40             	mov    0x40(%eax),%eax
  801b1e:	eb 0c                	jmp    801b2c <ipc_find_env+0x4a>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801b20:	40                   	inc    %eax
  801b21:	3d 00 04 00 00       	cmp    $0x400,%eax
  801b26:	75 cd                	jne    801af5 <ipc_find_env+0x13>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801b28:	66 b8 00 00          	mov    $0x0,%ax
}
  801b2c:	c9                   	leave  
  801b2d:	c3                   	ret    
	...

00801b30 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801b30:	55                   	push   %ebp
  801b31:	89 e5                	mov    %esp,%ebp
  801b33:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801b36:	89 c2                	mov    %eax,%edx
  801b38:	c1 ea 16             	shr    $0x16,%edx
  801b3b:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801b42:	f6 c2 01             	test   $0x1,%dl
  801b45:	74 1e                	je     801b65 <pageref+0x35>
		return 0;
	pte = uvpt[PGNUM(v)];
  801b47:	c1 e8 0c             	shr    $0xc,%eax
  801b4a:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  801b51:	a8 01                	test   $0x1,%al
  801b53:	74 17                	je     801b6c <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801b55:	c1 e8 0c             	shr    $0xc,%eax
  801b58:	66 8b 04 c5 04 00 00 	mov    -0x10fffffc(,%eax,8),%ax
  801b5f:	ef 
  801b60:	0f b7 c0             	movzwl %ax,%eax
  801b63:	eb 0c                	jmp    801b71 <pageref+0x41>
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
		return 0;
  801b65:	b8 00 00 00 00       	mov    $0x0,%eax
  801b6a:	eb 05                	jmp    801b71 <pageref+0x41>
	pte = uvpt[PGNUM(v)];
	if (!(pte & PTE_P))
		return 0;
  801b6c:	b8 00 00 00 00       	mov    $0x0,%eax
	return pages[PGNUM(pte)].pp_ref;
}
  801b71:	c9                   	leave  
  801b72:	c3                   	ret    
	...

00801b74 <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  801b74:	55                   	push   %ebp
  801b75:	89 e5                	mov    %esp,%ebp
  801b77:	57                   	push   %edi
  801b78:	56                   	push   %esi
  801b79:	83 ec 10             	sub    $0x10,%esp
  801b7c:	8b 7d 08             	mov    0x8(%ebp),%edi
  801b7f:	8b 4d 10             	mov    0x10(%ebp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  801b82:	89 7d f0             	mov    %edi,-0x10(%ebp)
  801b85:	8b 75 0c             	mov    0xc(%ebp),%esi
  const DWunion dd = {.ll = d};
  801b88:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  801b8b:	8b 45 14             	mov    0x14(%ebp),%eax
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  801b8e:	85 c0                	test   %eax,%eax
  801b90:	75 2e                	jne    801bc0 <__udivdi3+0x4c>
    {
      if (d0 > n1)
  801b92:	39 f1                	cmp    %esi,%ecx
  801b94:	77 5a                	ja     801bf0 <__udivdi3+0x7c>
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  801b96:	85 c9                	test   %ecx,%ecx
  801b98:	75 0b                	jne    801ba5 <__udivdi3+0x31>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  801b9a:	b8 01 00 00 00       	mov    $0x1,%eax
  801b9f:	31 d2                	xor    %edx,%edx
  801ba1:	f7 f1                	div    %ecx
  801ba3:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  801ba5:	31 d2                	xor    %edx,%edx
  801ba7:	89 f0                	mov    %esi,%eax
  801ba9:	f7 f1                	div    %ecx
  801bab:	89 c6                	mov    %eax,%esi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801bad:	89 f8                	mov    %edi,%eax
  801baf:	f7 f1                	div    %ecx
  801bb1:	89 c7                	mov    %eax,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  801bb3:	89 f8                	mov    %edi,%eax
  801bb5:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801bb7:	83 c4 10             	add    $0x10,%esp
  801bba:	5e                   	pop    %esi
  801bbb:	5f                   	pop    %edi
  801bbc:	c9                   	leave  
  801bbd:	c3                   	ret    
  801bbe:	66 90                	xchg   %ax,%ax
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  801bc0:	39 f0                	cmp    %esi,%eax
  801bc2:	77 1c                	ja     801be0 <__udivdi3+0x6c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  801bc4:	0f bd f8             	bsr    %eax,%edi
	  if (bm == 0)
  801bc7:	83 f7 1f             	xor    $0x1f,%edi
  801bca:	75 3c                	jne    801c08 <__udivdi3+0x94>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  801bcc:	39 f0                	cmp    %esi,%eax
  801bce:	0f 82 90 00 00 00    	jb     801c64 <__udivdi3+0xf0>
  801bd4:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801bd7:	39 55 f4             	cmp    %edx,-0xc(%ebp)
  801bda:	0f 86 84 00 00 00    	jbe    801c64 <__udivdi3+0xf0>
  801be0:	31 f6                	xor    %esi,%esi
  801be2:	31 ff                	xor    %edi,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  801be4:	89 f8                	mov    %edi,%eax
  801be6:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801be8:	83 c4 10             	add    $0x10,%esp
  801beb:	5e                   	pop    %esi
  801bec:	5f                   	pop    %edi
  801bed:	c9                   	leave  
  801bee:	c3                   	ret    
  801bef:	90                   	nop
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801bf0:	89 f2                	mov    %esi,%edx
  801bf2:	89 f8                	mov    %edi,%eax
  801bf4:	f7 f1                	div    %ecx
  801bf6:	89 c7                	mov    %eax,%edi
  801bf8:	31 f6                	xor    %esi,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  801bfa:	89 f8                	mov    %edi,%eax
  801bfc:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801bfe:	83 c4 10             	add    $0x10,%esp
  801c01:	5e                   	pop    %esi
  801c02:	5f                   	pop    %edi
  801c03:	c9                   	leave  
  801c04:	c3                   	ret    
  801c05:	8d 76 00             	lea    0x0(%esi),%esi
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  801c08:	89 f9                	mov    %edi,%ecx
  801c0a:	d3 e0                	shl    %cl,%eax
  801c0c:	89 45 e8             	mov    %eax,-0x18(%ebp)
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  801c0f:	b8 20 00 00 00       	mov    $0x20,%eax
  801c14:	29 f8                	sub    %edi,%eax

	      d1 = (d1 << bm) | (d0 >> b);
  801c16:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801c19:	88 c1                	mov    %al,%cl
  801c1b:	d3 ea                	shr    %cl,%edx
  801c1d:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  801c20:	09 ca                	or     %ecx,%edx
  801c22:	89 55 ec             	mov    %edx,-0x14(%ebp)
	      d0 = d0 << bm;
  801c25:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801c28:	89 f9                	mov    %edi,%ecx
  801c2a:	d3 e2                	shl    %cl,%edx
  801c2c:	89 55 f4             	mov    %edx,-0xc(%ebp)
	      n2 = n1 >> b;
  801c2f:	89 f2                	mov    %esi,%edx
  801c31:	88 c1                	mov    %al,%cl
  801c33:	d3 ea                	shr    %cl,%edx
  801c35:	89 55 e8             	mov    %edx,-0x18(%ebp)
	      n1 = (n1 << bm) | (n0 >> b);
  801c38:	89 f2                	mov    %esi,%edx
  801c3a:	89 f9                	mov    %edi,%ecx
  801c3c:	d3 e2                	shl    %cl,%edx
  801c3e:	8b 75 f0             	mov    -0x10(%ebp),%esi
  801c41:	88 c1                	mov    %al,%cl
  801c43:	d3 ee                	shr    %cl,%esi
  801c45:	09 d6                	or     %edx,%esi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  801c47:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  801c4a:	89 f0                	mov    %esi,%eax
  801c4c:	89 ca                	mov    %ecx,%edx
  801c4e:	f7 75 ec             	divl   -0x14(%ebp)
  801c51:	89 d1                	mov    %edx,%ecx
  801c53:	89 c6                	mov    %eax,%esi
	      umul_ppmm (m1, m0, q0, d0);
  801c55:	f7 65 f4             	mull   -0xc(%ebp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801c58:	39 d1                	cmp    %edx,%ecx
  801c5a:	72 28                	jb     801c84 <__udivdi3+0x110>
  801c5c:	74 1a                	je     801c78 <__udivdi3+0x104>
  801c5e:	89 f7                	mov    %esi,%edi
  801c60:	31 f6                	xor    %esi,%esi
  801c62:	eb 80                	jmp    801be4 <__udivdi3+0x70>
	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  801c64:	31 f6                	xor    %esi,%esi
  801c66:	bf 01 00 00 00       	mov    $0x1,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  801c6b:	89 f8                	mov    %edi,%eax
  801c6d:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801c6f:	83 c4 10             	add    $0x10,%esp
  801c72:	5e                   	pop    %esi
  801c73:	5f                   	pop    %edi
  801c74:	c9                   	leave  
  801c75:	c3                   	ret    
  801c76:	66 90                	xchg   %ax,%ax

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  801c78:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801c7b:	89 f9                	mov    %edi,%ecx
  801c7d:	d3 e2                	shl    %cl,%edx

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801c7f:	39 c2                	cmp    %eax,%edx
  801c81:	73 db                	jae    801c5e <__udivdi3+0xea>
  801c83:	90                   	nop
		{
		  q0--;
  801c84:	8d 7e ff             	lea    -0x1(%esi),%edi
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  801c87:	31 f6                	xor    %esi,%esi
  801c89:	e9 56 ff ff ff       	jmp    801be4 <__udivdi3+0x70>
	...

00801c90 <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  801c90:	55                   	push   %ebp
  801c91:	89 e5                	mov    %esp,%ebp
  801c93:	57                   	push   %edi
  801c94:	56                   	push   %esi
  801c95:	83 ec 20             	sub    $0x20,%esp
  801c98:	8b 45 08             	mov    0x8(%ebp),%eax
  801c9b:	8b 4d 10             	mov    0x10(%ebp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  801c9e:	89 45 e8             	mov    %eax,-0x18(%ebp)
  801ca1:	8b 75 0c             	mov    0xc(%ebp),%esi
  const DWunion dd = {.ll = d};
  801ca4:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  801ca7:	8b 7d 14             	mov    0x14(%ebp),%edi
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  801caa:	89 45 f0             	mov    %eax,-0x10(%ebp)
  n1 = nn.s.high;
  801cad:	89 f2                	mov    %esi,%edx

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  801caf:	85 ff                	test   %edi,%edi
  801cb1:	75 15                	jne    801cc8 <__umoddi3+0x38>
    {
      if (d0 > n1)
  801cb3:	39 f1                	cmp    %esi,%ecx
  801cb5:	0f 86 99 00 00 00    	jbe    801d54 <__umoddi3+0xc4>
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801cbb:	f7 f1                	div    %ecx

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
  801cbd:	89 d0                	mov    %edx,%eax
  801cbf:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  801cc1:	83 c4 20             	add    $0x20,%esp
  801cc4:	5e                   	pop    %esi
  801cc5:	5f                   	pop    %edi
  801cc6:	c9                   	leave  
  801cc7:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  801cc8:	39 f7                	cmp    %esi,%edi
  801cca:	0f 87 a4 00 00 00    	ja     801d74 <__umoddi3+0xe4>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  801cd0:	0f bd c7             	bsr    %edi,%eax
	  if (bm == 0)
  801cd3:	83 f0 1f             	xor    $0x1f,%eax
  801cd6:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801cd9:	0f 84 a1 00 00 00    	je     801d80 <__umoddi3+0xf0>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  801cdf:	89 f8                	mov    %edi,%eax
  801ce1:	8a 4d ec             	mov    -0x14(%ebp),%cl
  801ce4:	d3 e0                	shl    %cl,%eax
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  801ce6:	bf 20 00 00 00       	mov    $0x20,%edi
  801ceb:	2b 7d ec             	sub    -0x14(%ebp),%edi

	      d1 = (d1 << bm) | (d0 >> b);
  801cee:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801cf1:	89 f9                	mov    %edi,%ecx
  801cf3:	d3 ea                	shr    %cl,%edx
  801cf5:	09 c2                	or     %eax,%edx
  801cf7:	89 55 f0             	mov    %edx,-0x10(%ebp)
	      d0 = d0 << bm;
  801cfa:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801cfd:	8a 4d ec             	mov    -0x14(%ebp),%cl
  801d00:	d3 e0                	shl    %cl,%eax
  801d02:	89 45 f4             	mov    %eax,-0xc(%ebp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  801d05:	89 f2                	mov    %esi,%edx
  801d07:	d3 e2                	shl    %cl,%edx
	      n0 = n0 << bm;
  801d09:	8b 45 e8             	mov    -0x18(%ebp),%eax
  801d0c:	d3 e0                	shl    %cl,%eax
  801d0e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  801d11:	8b 45 e8             	mov    -0x18(%ebp),%eax
  801d14:	89 f9                	mov    %edi,%ecx
  801d16:	d3 e8                	shr    %cl,%eax
  801d18:	09 d0                	or     %edx,%eax

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  801d1a:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  801d1c:	89 f2                	mov    %esi,%edx
  801d1e:	f7 75 f0             	divl   -0x10(%ebp)
  801d21:	89 d6                	mov    %edx,%esi
	      umul_ppmm (m1, m0, q0, d0);
  801d23:	f7 65 f4             	mull   -0xc(%ebp)
  801d26:	89 55 e8             	mov    %edx,-0x18(%ebp)
  801d29:	89 c1                	mov    %eax,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801d2b:	39 d6                	cmp    %edx,%esi
  801d2d:	72 71                	jb     801da0 <__umoddi3+0x110>
  801d2f:	74 7f                	je     801db0 <__umoddi3+0x120>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  801d31:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801d34:	29 c8                	sub    %ecx,%eax
  801d36:	19 d6                	sbb    %edx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
  801d38:	8a 4d ec             	mov    -0x14(%ebp),%cl
  801d3b:	d3 e8                	shr    %cl,%eax
  801d3d:	89 f2                	mov    %esi,%edx
  801d3f:	89 f9                	mov    %edi,%ecx
  801d41:	d3 e2                	shl    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
  801d43:	09 d0                	or     %edx,%eax
  801d45:	89 f2                	mov    %esi,%edx
  801d47:	8a 4d ec             	mov    -0x14(%ebp),%cl
  801d4a:	d3 ea                	shr    %cl,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  801d4c:	83 c4 20             	add    $0x20,%esp
  801d4f:	5e                   	pop    %esi
  801d50:	5f                   	pop    %edi
  801d51:	c9                   	leave  
  801d52:	c3                   	ret    
  801d53:	90                   	nop
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  801d54:	85 c9                	test   %ecx,%ecx
  801d56:	75 0b                	jne    801d63 <__umoddi3+0xd3>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  801d58:	b8 01 00 00 00       	mov    $0x1,%eax
  801d5d:	31 d2                	xor    %edx,%edx
  801d5f:	f7 f1                	div    %ecx
  801d61:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  801d63:	89 f0                	mov    %esi,%eax
  801d65:	31 d2                	xor    %edx,%edx
  801d67:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801d69:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801d6c:	f7 f1                	div    %ecx
  801d6e:	e9 4a ff ff ff       	jmp    801cbd <__umoddi3+0x2d>
  801d73:	90                   	nop
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
  801d74:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  801d76:	83 c4 20             	add    $0x20,%esp
  801d79:	5e                   	pop    %esi
  801d7a:	5f                   	pop    %edi
  801d7b:	c9                   	leave  
  801d7c:	c3                   	ret    
  801d7d:	8d 76 00             	lea    0x0(%esi),%esi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  801d80:	39 f7                	cmp    %esi,%edi
  801d82:	72 05                	jb     801d89 <__umoddi3+0xf9>
  801d84:	3b 4d f0             	cmp    -0x10(%ebp),%ecx
  801d87:	77 0c                	ja     801d95 <__umoddi3+0x105>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  801d89:	89 f2                	mov    %esi,%edx
  801d8b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801d8e:	29 c8                	sub    %ecx,%eax
  801d90:	19 fa                	sbb    %edi,%edx
  801d92:	89 45 f0             	mov    %eax,-0x10(%ebp)

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
  801d95:	8b 45 f0             	mov    -0x10(%ebp),%eax
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  801d98:	83 c4 20             	add    $0x20,%esp
  801d9b:	5e                   	pop    %esi
  801d9c:	5f                   	pop    %edi
  801d9d:	c9                   	leave  
  801d9e:	c3                   	ret    
  801d9f:	90                   	nop
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  801da0:	8b 55 e8             	mov    -0x18(%ebp),%edx
  801da3:	89 c1                	mov    %eax,%ecx
  801da5:	2b 4d f4             	sub    -0xc(%ebp),%ecx
  801da8:	1b 55 f0             	sbb    -0x10(%ebp),%edx
  801dab:	eb 84                	jmp    801d31 <__umoddi3+0xa1>
  801dad:	8d 76 00             	lea    0x0(%esi),%esi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801db0:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  801db3:	72 eb                	jb     801da0 <__umoddi3+0x110>
  801db5:	89 f2                	mov    %esi,%edx
  801db7:	e9 75 ff ff ff       	jmp    801d31 <__umoddi3+0xa1>
