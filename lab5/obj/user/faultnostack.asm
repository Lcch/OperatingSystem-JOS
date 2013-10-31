
obj/user/faultnostack.debug:     file format elf32-i386


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
  80002c:	e8 27 00 00 00       	call   800058 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800034 <umain>:

void _pgfault_upcall();

void
umain(int argc, char **argv)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	83 ec 10             	sub    $0x10,%esp
	sys_env_set_pgfault_upcall(0, (void*) _pgfault_upcall);
  80003a:	68 08 03 80 00       	push   $0x800308
  80003f:	6a 00                	push   $0x0
  800041:	e8 35 02 00 00       	call   80027b <sys_env_set_pgfault_upcall>
	*(int*)0 = 0;
  800046:	c7 05 00 00 00 00 00 	movl   $0x0,0x0
  80004d:	00 00 00 
  800050:	83 c4 10             	add    $0x10,%esp
}
  800053:	c9                   	leave  
  800054:	c3                   	ret    
  800055:	00 00                	add    %al,(%eax)
	...

00800058 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800058:	55                   	push   %ebp
  800059:	89 e5                	mov    %esp,%ebp
  80005b:	56                   	push   %esi
  80005c:	53                   	push   %ebx
  80005d:	8b 75 08             	mov    0x8(%ebp),%esi
  800060:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = envs + ENVX(sys_getenvid());
  800063:	e8 15 01 00 00       	call   80017d <sys_getenvid>
  800068:	25 ff 03 00 00       	and    $0x3ff,%eax
  80006d:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  800074:	c1 e0 07             	shl    $0x7,%eax
  800077:	29 d0                	sub    %edx,%eax
  800079:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80007e:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800083:	85 f6                	test   %esi,%esi
  800085:	7e 07                	jle    80008e <libmain+0x36>
		binaryname = argv[0];
  800087:	8b 03                	mov    (%ebx),%eax
  800089:	a3 00 30 80 00       	mov    %eax,0x803000
	// call user main routine
	umain(argc, argv);
  80008e:	83 ec 08             	sub    $0x8,%esp
  800091:	53                   	push   %ebx
  800092:	56                   	push   %esi
  800093:	e8 9c ff ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  800098:	e8 0b 00 00 00       	call   8000a8 <exit>
  80009d:	83 c4 10             	add    $0x10,%esp
}
  8000a0:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000a3:	5b                   	pop    %ebx
  8000a4:	5e                   	pop    %esi
  8000a5:	c9                   	leave  
  8000a6:	c3                   	ret    
	...

008000a8 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000a8:	55                   	push   %ebp
  8000a9:	89 e5                	mov    %esp,%ebp
  8000ab:	83 ec 08             	sub    $0x8,%esp
	close_all();
  8000ae:	e8 87 04 00 00       	call   80053a <close_all>
	sys_env_destroy(0);
  8000b3:	83 ec 0c             	sub    $0xc,%esp
  8000b6:	6a 00                	push   $0x0
  8000b8:	e8 9e 00 00 00       	call   80015b <sys_env_destroy>
  8000bd:	83 c4 10             	add    $0x10,%esp
}
  8000c0:	c9                   	leave  
  8000c1:	c3                   	ret    
	...

008000c4 <syscall>:
	return ret;
}

static int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  8000c4:	55                   	push   %ebp
  8000c5:	89 e5                	mov    %esp,%ebp
  8000c7:	57                   	push   %edi
  8000c8:	56                   	push   %esi
  8000c9:	53                   	push   %ebx
  8000ca:	83 ec 1c             	sub    $0x1c,%esp
  8000cd:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8000d0:	89 55 e0             	mov    %edx,-0x20(%ebp)
  8000d3:	89 ca                	mov    %ecx,%edx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000d5:	8b 75 14             	mov    0x14(%ebp),%esi
  8000d8:	8b 7d 10             	mov    0x10(%ebp),%edi
  8000db:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8000de:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8000e1:	cd 30                	int    $0x30
  8000e3:	89 c2                	mov    %eax,%edx
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8000e5:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8000e9:	74 1c                	je     800107 <syscall+0x43>
  8000eb:	85 c0                	test   %eax,%eax
  8000ed:	7e 18                	jle    800107 <syscall+0x43>
		panic("syscall %d returned %d (> 0)", num, ret);
  8000ef:	83 ec 0c             	sub    $0xc,%esp
  8000f2:	50                   	push   %eax
  8000f3:	ff 75 e4             	pushl  -0x1c(%ebp)
  8000f6:	68 2a 1e 80 00       	push   $0x801e2a
  8000fb:	6a 42                	push   $0x42
  8000fd:	68 47 1e 80 00       	push   $0x801e47
  800102:	e8 dd 0e 00 00       	call   800fe4 <_panic>

	return ret;
}
  800107:	89 d0                	mov    %edx,%eax
  800109:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80010c:	5b                   	pop    %ebx
  80010d:	5e                   	pop    %esi
  80010e:	5f                   	pop    %edi
  80010f:	c9                   	leave  
  800110:	c3                   	ret    

00800111 <sys_cputs>:

void
sys_cputs(const char *s, size_t len)
{	
  800111:	55                   	push   %ebp
  800112:	89 e5                	mov    %esp,%ebp
  800114:	83 ec 08             	sub    $0x8,%esp
	// my_sysenter(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
	// return;
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
  800117:	6a 00                	push   $0x0
  800119:	6a 00                	push   $0x0
  80011b:	6a 00                	push   $0x0
  80011d:	ff 75 0c             	pushl  0xc(%ebp)
  800120:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800123:	ba 00 00 00 00       	mov    $0x0,%edx
  800128:	b8 00 00 00 00       	mov    $0x0,%eax
  80012d:	e8 92 ff ff ff       	call   8000c4 <syscall>
  800132:	83 c4 10             	add    $0x10,%esp
	return;
}
  800135:	c9                   	leave  
  800136:	c3                   	ret    

00800137 <sys_cgetc>:

int
sys_cgetc(void)
{
  800137:	55                   	push   %ebp
  800138:	89 e5                	mov    %esp,%ebp
  80013a:	83 ec 08             	sub    $0x8,%esp
	// return my_sysenter(SYS_cgetc, 0, 0, 0, 0, 0, 0);
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
  80013d:	6a 00                	push   $0x0
  80013f:	6a 00                	push   $0x0
  800141:	6a 00                	push   $0x0
  800143:	6a 00                	push   $0x0
  800145:	b9 00 00 00 00       	mov    $0x0,%ecx
  80014a:	ba 00 00 00 00       	mov    $0x0,%edx
  80014f:	b8 01 00 00 00       	mov    $0x1,%eax
  800154:	e8 6b ff ff ff       	call   8000c4 <syscall>
}
  800159:	c9                   	leave  
  80015a:	c3                   	ret    

0080015b <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  80015b:	55                   	push   %ebp
  80015c:	89 e5                	mov    %esp,%ebp
  80015e:	83 ec 08             	sub    $0x8,%esp
	// return my_sysenter(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
  800161:	6a 00                	push   $0x0
  800163:	6a 00                	push   $0x0
  800165:	6a 00                	push   $0x0
  800167:	6a 00                	push   $0x0
  800169:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80016c:	ba 01 00 00 00       	mov    $0x1,%edx
  800171:	b8 03 00 00 00       	mov    $0x3,%eax
  800176:	e8 49 ff ff ff       	call   8000c4 <syscall>
}
  80017b:	c9                   	leave  
  80017c:	c3                   	ret    

0080017d <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  80017d:	55                   	push   %ebp
  80017e:	89 e5                	mov    %esp,%ebp
  800180:	83 ec 08             	sub    $0x8,%esp
	// return my_sysenter(SYS_getenvid, 0, 0, 0, 0, 0, 0);
	return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
  800183:	6a 00                	push   $0x0
  800185:	6a 00                	push   $0x0
  800187:	6a 00                	push   $0x0
  800189:	6a 00                	push   $0x0
  80018b:	b9 00 00 00 00       	mov    $0x0,%ecx
  800190:	ba 00 00 00 00       	mov    $0x0,%edx
  800195:	b8 02 00 00 00       	mov    $0x2,%eax
  80019a:	e8 25 ff ff ff       	call   8000c4 <syscall>
}
  80019f:	c9                   	leave  
  8001a0:	c3                   	ret    

008001a1 <sys_yield>:

void
sys_yield(void)
{
  8001a1:	55                   	push   %ebp
  8001a2:	89 e5                	mov    %esp,%ebp
  8001a4:	83 ec 08             	sub    $0x8,%esp
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
  8001a7:	6a 00                	push   $0x0
  8001a9:	6a 00                	push   $0x0
  8001ab:	6a 00                	push   $0x0
  8001ad:	6a 00                	push   $0x0
  8001af:	b9 00 00 00 00       	mov    $0x0,%ecx
  8001b4:	ba 00 00 00 00       	mov    $0x0,%edx
  8001b9:	b8 0b 00 00 00       	mov    $0xb,%eax
  8001be:	e8 01 ff ff ff       	call   8000c4 <syscall>
  8001c3:	83 c4 10             	add    $0x10,%esp
}
  8001c6:	c9                   	leave  
  8001c7:	c3                   	ret    

008001c8 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  8001c8:	55                   	push   %ebp
  8001c9:	89 e5                	mov    %esp,%ebp
  8001cb:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
  8001ce:	6a 00                	push   $0x0
  8001d0:	6a 00                	push   $0x0
  8001d2:	ff 75 10             	pushl  0x10(%ebp)
  8001d5:	ff 75 0c             	pushl  0xc(%ebp)
  8001d8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8001db:	ba 01 00 00 00       	mov    $0x1,%edx
  8001e0:	b8 04 00 00 00       	mov    $0x4,%eax
  8001e5:	e8 da fe ff ff       	call   8000c4 <syscall>
}
  8001ea:	c9                   	leave  
  8001eb:	c3                   	ret    

008001ec <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8001ec:	55                   	push   %ebp
  8001ed:	89 e5                	mov    %esp,%ebp
  8001ef:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
  8001f2:	ff 75 18             	pushl  0x18(%ebp)
  8001f5:	ff 75 14             	pushl  0x14(%ebp)
  8001f8:	ff 75 10             	pushl  0x10(%ebp)
  8001fb:	ff 75 0c             	pushl  0xc(%ebp)
  8001fe:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800201:	ba 01 00 00 00       	mov    $0x1,%edx
  800206:	b8 05 00 00 00       	mov    $0x5,%eax
  80020b:	e8 b4 fe ff ff       	call   8000c4 <syscall>
}
  800210:	c9                   	leave  
  800211:	c3                   	ret    

00800212 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800212:	55                   	push   %ebp
  800213:	89 e5                	mov    %esp,%ebp
  800215:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
  800218:	6a 00                	push   $0x0
  80021a:	6a 00                	push   $0x0
  80021c:	6a 00                	push   $0x0
  80021e:	ff 75 0c             	pushl  0xc(%ebp)
  800221:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800224:	ba 01 00 00 00       	mov    $0x1,%edx
  800229:	b8 06 00 00 00       	mov    $0x6,%eax
  80022e:	e8 91 fe ff ff       	call   8000c4 <syscall>
}
  800233:	c9                   	leave  
  800234:	c3                   	ret    

00800235 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800235:	55                   	push   %ebp
  800236:	89 e5                	mov    %esp,%ebp
  800238:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
  80023b:	6a 00                	push   $0x0
  80023d:	6a 00                	push   $0x0
  80023f:	6a 00                	push   $0x0
  800241:	ff 75 0c             	pushl  0xc(%ebp)
  800244:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800247:	ba 01 00 00 00       	mov    $0x1,%edx
  80024c:	b8 08 00 00 00       	mov    $0x8,%eax
  800251:	e8 6e fe ff ff       	call   8000c4 <syscall>
}
  800256:	c9                   	leave  
  800257:	c3                   	ret    

00800258 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800258:	55                   	push   %ebp
  800259:	89 e5                	mov    %esp,%ebp
  80025b:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
  80025e:	6a 00                	push   $0x0
  800260:	6a 00                	push   $0x0
  800262:	6a 00                	push   $0x0
  800264:	ff 75 0c             	pushl  0xc(%ebp)
  800267:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80026a:	ba 01 00 00 00       	mov    $0x1,%edx
  80026f:	b8 09 00 00 00       	mov    $0x9,%eax
  800274:	e8 4b fe ff ff       	call   8000c4 <syscall>
}
  800279:	c9                   	leave  
  80027a:	c3                   	ret    

0080027b <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  80027b:	55                   	push   %ebp
  80027c:	89 e5                	mov    %esp,%ebp
  80027e:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
  800281:	6a 00                	push   $0x0
  800283:	6a 00                	push   $0x0
  800285:	6a 00                	push   $0x0
  800287:	ff 75 0c             	pushl  0xc(%ebp)
  80028a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80028d:	ba 01 00 00 00       	mov    $0x1,%edx
  800292:	b8 0a 00 00 00       	mov    $0xa,%eax
  800297:	e8 28 fe ff ff       	call   8000c4 <syscall>
}
  80029c:	c9                   	leave  
  80029d:	c3                   	ret    

0080029e <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  80029e:	55                   	push   %ebp
  80029f:	89 e5                	mov    %esp,%ebp
  8002a1:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
  8002a4:	6a 00                	push   $0x0
  8002a6:	ff 75 14             	pushl  0x14(%ebp)
  8002a9:	ff 75 10             	pushl  0x10(%ebp)
  8002ac:	ff 75 0c             	pushl  0xc(%ebp)
  8002af:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8002b2:	ba 00 00 00 00       	mov    $0x0,%edx
  8002b7:	b8 0c 00 00 00       	mov    $0xc,%eax
  8002bc:	e8 03 fe ff ff       	call   8000c4 <syscall>
}
  8002c1:	c9                   	leave  
  8002c2:	c3                   	ret    

008002c3 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  8002c3:	55                   	push   %ebp
  8002c4:	89 e5                	mov    %esp,%ebp
  8002c6:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
  8002c9:	6a 00                	push   $0x0
  8002cb:	6a 00                	push   $0x0
  8002cd:	6a 00                	push   $0x0
  8002cf:	6a 00                	push   $0x0
  8002d1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8002d4:	ba 01 00 00 00       	mov    $0x1,%edx
  8002d9:	b8 0d 00 00 00       	mov    $0xd,%eax
  8002de:	e8 e1 fd ff ff       	call   8000c4 <syscall>
}
  8002e3:	c9                   	leave  
  8002e4:	c3                   	ret    

008002e5 <sys_set_priority>:

int
sys_set_priority(envid_t envid, uint32_t new_priority)
{
  8002e5:	55                   	push   %ebp
  8002e6:	89 e5                	mov    %esp,%ebp
  8002e8:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_set_priority, 0, envid, new_priority, 0, 0, 0);
  8002eb:	6a 00                	push   $0x0
  8002ed:	6a 00                	push   $0x0
  8002ef:	6a 00                	push   $0x0
  8002f1:	ff 75 0c             	pushl  0xc(%ebp)
  8002f4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8002f7:	ba 00 00 00 00       	mov    $0x0,%edx
  8002fc:	b8 0e 00 00 00       	mov    $0xe,%eax
  800301:	e8 be fd ff ff       	call   8000c4 <syscall>
}
  800306:	c9                   	leave  
  800307:	c3                   	ret    

00800308 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  800308:	54                   	push   %esp
	movl _pgfault_handler, %eax
  800309:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  80030e:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  800310:	83 c4 04             	add    $0x4,%esp
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	
	// fix old esp
	movl 0x30(%esp), %eax
  800313:	8b 44 24 30          	mov    0x30(%esp),%eax
	subl $0x4, %eax
  800317:	83 e8 04             	sub    $0x4,%eax
	movl %eax, 0x30(%esp)
  80031a:	89 44 24 30          	mov    %eax,0x30(%esp)

	// set trap-time %eip
	movl 0x28(%esp), %ebx
  80031e:	8b 5c 24 28          	mov    0x28(%esp),%ebx
	movl %ebx, (%eax)
  800322:	89 18                	mov    %ebx,(%eax)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	addl $0x08, %esp 	// ignore err_code and fault_va
  800324:	83 c4 08             	add    $0x8,%esp
	popal 				// restore registers
  800327:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $0x04, %esp 	// ignore eip 
  800328:	83 c4 04             	add    $0x4,%esp
	popfl				// modify eflags
  80032b:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp
  80032c:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  80032d:	c3                   	ret    
	...

00800330 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800330:	55                   	push   %ebp
  800331:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800333:	8b 45 08             	mov    0x8(%ebp),%eax
  800336:	05 00 00 00 30       	add    $0x30000000,%eax
  80033b:	c1 e8 0c             	shr    $0xc,%eax
}
  80033e:	c9                   	leave  
  80033f:	c3                   	ret    

00800340 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800340:	55                   	push   %ebp
  800341:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  800343:	ff 75 08             	pushl  0x8(%ebp)
  800346:	e8 e5 ff ff ff       	call   800330 <fd2num>
  80034b:	83 c4 04             	add    $0x4,%esp
  80034e:	05 20 00 0d 00       	add    $0xd0020,%eax
  800353:	c1 e0 0c             	shl    $0xc,%eax
}
  800356:	c9                   	leave  
  800357:	c3                   	ret    

00800358 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800358:	55                   	push   %ebp
  800359:	89 e5                	mov    %esp,%ebp
  80035b:	53                   	push   %ebx
  80035c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  80035f:	a1 00 dd 7b ef       	mov    0xef7bdd00,%eax
  800364:	a8 01                	test   $0x1,%al
  800366:	74 34                	je     80039c <fd_alloc+0x44>
  800368:	a1 00 00 74 ef       	mov    0xef740000,%eax
  80036d:	a8 01                	test   $0x1,%al
  80036f:	74 32                	je     8003a3 <fd_alloc+0x4b>
  800371:	b8 00 10 00 d0       	mov    $0xd0001000,%eax
  800376:	89 c1                	mov    %eax,%ecx
  800378:	89 c2                	mov    %eax,%edx
  80037a:	c1 ea 16             	shr    $0x16,%edx
  80037d:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800384:	f6 c2 01             	test   $0x1,%dl
  800387:	74 1f                	je     8003a8 <fd_alloc+0x50>
  800389:	89 c2                	mov    %eax,%edx
  80038b:	c1 ea 0c             	shr    $0xc,%edx
  80038e:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800395:	f6 c2 01             	test   $0x1,%dl
  800398:	75 17                	jne    8003b1 <fd_alloc+0x59>
  80039a:	eb 0c                	jmp    8003a8 <fd_alloc+0x50>
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  80039c:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
  8003a1:	eb 05                	jmp    8003a8 <fd_alloc+0x50>
  8003a3:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
  8003a8:	89 0b                	mov    %ecx,(%ebx)
			return 0;
  8003aa:	b8 00 00 00 00       	mov    $0x0,%eax
  8003af:	eb 17                	jmp    8003c8 <fd_alloc+0x70>
  8003b1:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8003b6:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8003bb:	75 b9                	jne    800376 <fd_alloc+0x1e>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8003bd:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_MAX_OPEN;
  8003c3:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8003c8:	5b                   	pop    %ebx
  8003c9:	c9                   	leave  
  8003ca:	c3                   	ret    

008003cb <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8003cb:	55                   	push   %ebp
  8003cc:	89 e5                	mov    %esp,%ebp
  8003ce:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8003d1:	83 f8 1f             	cmp    $0x1f,%eax
  8003d4:	77 36                	ja     80040c <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8003d6:	05 00 00 0d 00       	add    $0xd0000,%eax
  8003db:	c1 e0 0c             	shl    $0xc,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8003de:	89 c2                	mov    %eax,%edx
  8003e0:	c1 ea 16             	shr    $0x16,%edx
  8003e3:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8003ea:	f6 c2 01             	test   $0x1,%dl
  8003ed:	74 24                	je     800413 <fd_lookup+0x48>
  8003ef:	89 c2                	mov    %eax,%edx
  8003f1:	c1 ea 0c             	shr    $0xc,%edx
  8003f4:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8003fb:	f6 c2 01             	test   $0x1,%dl
  8003fe:	74 1a                	je     80041a <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800400:	8b 55 0c             	mov    0xc(%ebp),%edx
  800403:	89 02                	mov    %eax,(%edx)
	return 0;
  800405:	b8 00 00 00 00       	mov    $0x0,%eax
  80040a:	eb 13                	jmp    80041f <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80040c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800411:	eb 0c                	jmp    80041f <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800413:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800418:	eb 05                	jmp    80041f <fd_lookup+0x54>
  80041a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  80041f:	c9                   	leave  
  800420:	c3                   	ret    

00800421 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800421:	55                   	push   %ebp
  800422:	89 e5                	mov    %esp,%ebp
  800424:	53                   	push   %ebx
  800425:	83 ec 04             	sub    $0x4,%esp
  800428:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80042b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
		if (devtab[i]->dev_id == dev_id) {
  80042e:	39 0d 04 30 80 00    	cmp    %ecx,0x803004
  800434:	74 0d                	je     800443 <dev_lookup+0x22>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800436:	b8 00 00 00 00       	mov    $0x0,%eax
  80043b:	eb 14                	jmp    800451 <dev_lookup+0x30>
		if (devtab[i]->dev_id == dev_id) {
  80043d:	39 0a                	cmp    %ecx,(%edx)
  80043f:	75 10                	jne    800451 <dev_lookup+0x30>
  800441:	eb 05                	jmp    800448 <dev_lookup+0x27>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800443:	ba 04 30 80 00       	mov    $0x803004,%edx
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
  800448:	89 13                	mov    %edx,(%ebx)
			return 0;
  80044a:	b8 00 00 00 00       	mov    $0x0,%eax
  80044f:	eb 31                	jmp    800482 <dev_lookup+0x61>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800451:	40                   	inc    %eax
  800452:	8b 14 85 d4 1e 80 00 	mov    0x801ed4(,%eax,4),%edx
  800459:	85 d2                	test   %edx,%edx
  80045b:	75 e0                	jne    80043d <dev_lookup+0x1c>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  80045d:	a1 04 40 80 00       	mov    0x804004,%eax
  800462:	8b 40 48             	mov    0x48(%eax),%eax
  800465:	83 ec 04             	sub    $0x4,%esp
  800468:	51                   	push   %ecx
  800469:	50                   	push   %eax
  80046a:	68 58 1e 80 00       	push   $0x801e58
  80046f:	e8 48 0c 00 00       	call   8010bc <cprintf>
	*dev = 0;
  800474:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_INVAL;
  80047a:	83 c4 10             	add    $0x10,%esp
  80047d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800482:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800485:	c9                   	leave  
  800486:	c3                   	ret    

00800487 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800487:	55                   	push   %ebp
  800488:	89 e5                	mov    %esp,%ebp
  80048a:	56                   	push   %esi
  80048b:	53                   	push   %ebx
  80048c:	83 ec 20             	sub    $0x20,%esp
  80048f:	8b 75 08             	mov    0x8(%ebp),%esi
  800492:	8a 45 0c             	mov    0xc(%ebp),%al
  800495:	88 45 e7             	mov    %al,-0x19(%ebp)
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800498:	56                   	push   %esi
  800499:	e8 92 fe ff ff       	call   800330 <fd2num>
  80049e:	8d 55 f4             	lea    -0xc(%ebp),%edx
  8004a1:	89 14 24             	mov    %edx,(%esp)
  8004a4:	50                   	push   %eax
  8004a5:	e8 21 ff ff ff       	call   8003cb <fd_lookup>
  8004aa:	89 c3                	mov    %eax,%ebx
  8004ac:	83 c4 08             	add    $0x8,%esp
  8004af:	85 c0                	test   %eax,%eax
  8004b1:	78 05                	js     8004b8 <fd_close+0x31>
	    || fd != fd2)
  8004b3:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8004b6:	74 0d                	je     8004c5 <fd_close+0x3e>
		return (must_exist ? r : 0);
  8004b8:	80 7d e7 00          	cmpb   $0x0,-0x19(%ebp)
  8004bc:	75 48                	jne    800506 <fd_close+0x7f>
  8004be:	bb 00 00 00 00       	mov    $0x0,%ebx
  8004c3:	eb 41                	jmp    800506 <fd_close+0x7f>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8004c5:	83 ec 08             	sub    $0x8,%esp
  8004c8:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8004cb:	50                   	push   %eax
  8004cc:	ff 36                	pushl  (%esi)
  8004ce:	e8 4e ff ff ff       	call   800421 <dev_lookup>
  8004d3:	89 c3                	mov    %eax,%ebx
  8004d5:	83 c4 10             	add    $0x10,%esp
  8004d8:	85 c0                	test   %eax,%eax
  8004da:	78 1c                	js     8004f8 <fd_close+0x71>
		if (dev->dev_close)
  8004dc:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8004df:	8b 40 10             	mov    0x10(%eax),%eax
  8004e2:	85 c0                	test   %eax,%eax
  8004e4:	74 0d                	je     8004f3 <fd_close+0x6c>
			r = (*dev->dev_close)(fd);
  8004e6:	83 ec 0c             	sub    $0xc,%esp
  8004e9:	56                   	push   %esi
  8004ea:	ff d0                	call   *%eax
  8004ec:	89 c3                	mov    %eax,%ebx
  8004ee:	83 c4 10             	add    $0x10,%esp
  8004f1:	eb 05                	jmp    8004f8 <fd_close+0x71>
		else
			r = 0;
  8004f3:	bb 00 00 00 00       	mov    $0x0,%ebx
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8004f8:	83 ec 08             	sub    $0x8,%esp
  8004fb:	56                   	push   %esi
  8004fc:	6a 00                	push   $0x0
  8004fe:	e8 0f fd ff ff       	call   800212 <sys_page_unmap>
	return r;
  800503:	83 c4 10             	add    $0x10,%esp
}
  800506:	89 d8                	mov    %ebx,%eax
  800508:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80050b:	5b                   	pop    %ebx
  80050c:	5e                   	pop    %esi
  80050d:	c9                   	leave  
  80050e:	c3                   	ret    

0080050f <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  80050f:	55                   	push   %ebp
  800510:	89 e5                	mov    %esp,%ebp
  800512:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800515:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800518:	50                   	push   %eax
  800519:	ff 75 08             	pushl  0x8(%ebp)
  80051c:	e8 aa fe ff ff       	call   8003cb <fd_lookup>
  800521:	83 c4 08             	add    $0x8,%esp
  800524:	85 c0                	test   %eax,%eax
  800526:	78 10                	js     800538 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  800528:	83 ec 08             	sub    $0x8,%esp
  80052b:	6a 01                	push   $0x1
  80052d:	ff 75 f4             	pushl  -0xc(%ebp)
  800530:	e8 52 ff ff ff       	call   800487 <fd_close>
  800535:	83 c4 10             	add    $0x10,%esp
}
  800538:	c9                   	leave  
  800539:	c3                   	ret    

0080053a <close_all>:

void
close_all(void)
{
  80053a:	55                   	push   %ebp
  80053b:	89 e5                	mov    %esp,%ebp
  80053d:	53                   	push   %ebx
  80053e:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800541:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  800546:	83 ec 0c             	sub    $0xc,%esp
  800549:	53                   	push   %ebx
  80054a:	e8 c0 ff ff ff       	call   80050f <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  80054f:	43                   	inc    %ebx
  800550:	83 c4 10             	add    $0x10,%esp
  800553:	83 fb 20             	cmp    $0x20,%ebx
  800556:	75 ee                	jne    800546 <close_all+0xc>
		close(i);
}
  800558:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80055b:	c9                   	leave  
  80055c:	c3                   	ret    

0080055d <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  80055d:	55                   	push   %ebp
  80055e:	89 e5                	mov    %esp,%ebp
  800560:	57                   	push   %edi
  800561:	56                   	push   %esi
  800562:	53                   	push   %ebx
  800563:	83 ec 2c             	sub    $0x2c,%esp
  800566:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  800569:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80056c:	50                   	push   %eax
  80056d:	ff 75 08             	pushl  0x8(%ebp)
  800570:	e8 56 fe ff ff       	call   8003cb <fd_lookup>
  800575:	89 c3                	mov    %eax,%ebx
  800577:	83 c4 08             	add    $0x8,%esp
  80057a:	85 c0                	test   %eax,%eax
  80057c:	0f 88 c0 00 00 00    	js     800642 <dup+0xe5>
		return r;
	close(newfdnum);
  800582:	83 ec 0c             	sub    $0xc,%esp
  800585:	57                   	push   %edi
  800586:	e8 84 ff ff ff       	call   80050f <close>

	newfd = INDEX2FD(newfdnum);
  80058b:	8d b7 00 00 0d 00    	lea    0xd0000(%edi),%esi
  800591:	c1 e6 0c             	shl    $0xc,%esi
	ova = fd2data(oldfd);
  800594:	83 c4 04             	add    $0x4,%esp
  800597:	ff 75 e4             	pushl  -0x1c(%ebp)
  80059a:	e8 a1 fd ff ff       	call   800340 <fd2data>
  80059f:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  8005a1:	89 34 24             	mov    %esi,(%esp)
  8005a4:	e8 97 fd ff ff       	call   800340 <fd2data>
  8005a9:	83 c4 10             	add    $0x10,%esp
  8005ac:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8005af:	89 d8                	mov    %ebx,%eax
  8005b1:	c1 e8 16             	shr    $0x16,%eax
  8005b4:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8005bb:	a8 01                	test   $0x1,%al
  8005bd:	74 37                	je     8005f6 <dup+0x99>
  8005bf:	89 d8                	mov    %ebx,%eax
  8005c1:	c1 e8 0c             	shr    $0xc,%eax
  8005c4:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8005cb:	f6 c2 01             	test   $0x1,%dl
  8005ce:	74 26                	je     8005f6 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8005d0:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8005d7:	83 ec 0c             	sub    $0xc,%esp
  8005da:	25 07 0e 00 00       	and    $0xe07,%eax
  8005df:	50                   	push   %eax
  8005e0:	ff 75 d4             	pushl  -0x2c(%ebp)
  8005e3:	6a 00                	push   $0x0
  8005e5:	53                   	push   %ebx
  8005e6:	6a 00                	push   $0x0
  8005e8:	e8 ff fb ff ff       	call   8001ec <sys_page_map>
  8005ed:	89 c3                	mov    %eax,%ebx
  8005ef:	83 c4 20             	add    $0x20,%esp
  8005f2:	85 c0                	test   %eax,%eax
  8005f4:	78 2d                	js     800623 <dup+0xc6>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8005f6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8005f9:	89 c2                	mov    %eax,%edx
  8005fb:	c1 ea 0c             	shr    $0xc,%edx
  8005fe:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800605:	83 ec 0c             	sub    $0xc,%esp
  800608:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  80060e:	52                   	push   %edx
  80060f:	56                   	push   %esi
  800610:	6a 00                	push   $0x0
  800612:	50                   	push   %eax
  800613:	6a 00                	push   $0x0
  800615:	e8 d2 fb ff ff       	call   8001ec <sys_page_map>
  80061a:	89 c3                	mov    %eax,%ebx
  80061c:	83 c4 20             	add    $0x20,%esp
  80061f:	85 c0                	test   %eax,%eax
  800621:	79 1d                	jns    800640 <dup+0xe3>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  800623:	83 ec 08             	sub    $0x8,%esp
  800626:	56                   	push   %esi
  800627:	6a 00                	push   $0x0
  800629:	e8 e4 fb ff ff       	call   800212 <sys_page_unmap>
	sys_page_unmap(0, nva);
  80062e:	83 c4 08             	add    $0x8,%esp
  800631:	ff 75 d4             	pushl  -0x2c(%ebp)
  800634:	6a 00                	push   $0x0
  800636:	e8 d7 fb ff ff       	call   800212 <sys_page_unmap>
	return r;
  80063b:	83 c4 10             	add    $0x10,%esp
  80063e:	eb 02                	jmp    800642 <dup+0xe5>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
		goto err;

	return newfdnum;
  800640:	89 fb                	mov    %edi,%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  800642:	89 d8                	mov    %ebx,%eax
  800644:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800647:	5b                   	pop    %ebx
  800648:	5e                   	pop    %esi
  800649:	5f                   	pop    %edi
  80064a:	c9                   	leave  
  80064b:	c3                   	ret    

0080064c <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80064c:	55                   	push   %ebp
  80064d:	89 e5                	mov    %esp,%ebp
  80064f:	53                   	push   %ebx
  800650:	83 ec 14             	sub    $0x14,%esp
  800653:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800656:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800659:	50                   	push   %eax
  80065a:	53                   	push   %ebx
  80065b:	e8 6b fd ff ff       	call   8003cb <fd_lookup>
  800660:	83 c4 08             	add    $0x8,%esp
  800663:	85 c0                	test   %eax,%eax
  800665:	78 67                	js     8006ce <read+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800667:	83 ec 08             	sub    $0x8,%esp
  80066a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80066d:	50                   	push   %eax
  80066e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800671:	ff 30                	pushl  (%eax)
  800673:	e8 a9 fd ff ff       	call   800421 <dev_lookup>
  800678:	83 c4 10             	add    $0x10,%esp
  80067b:	85 c0                	test   %eax,%eax
  80067d:	78 4f                	js     8006ce <read+0x82>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80067f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800682:	8b 50 08             	mov    0x8(%eax),%edx
  800685:	83 e2 03             	and    $0x3,%edx
  800688:	83 fa 01             	cmp    $0x1,%edx
  80068b:	75 21                	jne    8006ae <read+0x62>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80068d:	a1 04 40 80 00       	mov    0x804004,%eax
  800692:	8b 40 48             	mov    0x48(%eax),%eax
  800695:	83 ec 04             	sub    $0x4,%esp
  800698:	53                   	push   %ebx
  800699:	50                   	push   %eax
  80069a:	68 99 1e 80 00       	push   $0x801e99
  80069f:	e8 18 0a 00 00       	call   8010bc <cprintf>
		return -E_INVAL;
  8006a4:	83 c4 10             	add    $0x10,%esp
  8006a7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8006ac:	eb 20                	jmp    8006ce <read+0x82>
	}
	if (!dev->dev_read)
  8006ae:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8006b1:	8b 52 08             	mov    0x8(%edx),%edx
  8006b4:	85 d2                	test   %edx,%edx
  8006b6:	74 11                	je     8006c9 <read+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8006b8:	83 ec 04             	sub    $0x4,%esp
  8006bb:	ff 75 10             	pushl  0x10(%ebp)
  8006be:	ff 75 0c             	pushl  0xc(%ebp)
  8006c1:	50                   	push   %eax
  8006c2:	ff d2                	call   *%edx
  8006c4:	83 c4 10             	add    $0x10,%esp
  8006c7:	eb 05                	jmp    8006ce <read+0x82>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8006c9:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_read)(fd, buf, n);
}
  8006ce:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8006d1:	c9                   	leave  
  8006d2:	c3                   	ret    

008006d3 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8006d3:	55                   	push   %ebp
  8006d4:	89 e5                	mov    %esp,%ebp
  8006d6:	57                   	push   %edi
  8006d7:	56                   	push   %esi
  8006d8:	53                   	push   %ebx
  8006d9:	83 ec 0c             	sub    $0xc,%esp
  8006dc:	8b 7d 08             	mov    0x8(%ebp),%edi
  8006df:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8006e2:	85 f6                	test   %esi,%esi
  8006e4:	74 31                	je     800717 <readn+0x44>
  8006e6:	b8 00 00 00 00       	mov    $0x0,%eax
  8006eb:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = read(fdnum, (char*)buf + tot, n - tot);
  8006f0:	83 ec 04             	sub    $0x4,%esp
  8006f3:	89 f2                	mov    %esi,%edx
  8006f5:	29 c2                	sub    %eax,%edx
  8006f7:	52                   	push   %edx
  8006f8:	03 45 0c             	add    0xc(%ebp),%eax
  8006fb:	50                   	push   %eax
  8006fc:	57                   	push   %edi
  8006fd:	e8 4a ff ff ff       	call   80064c <read>
		if (m < 0)
  800702:	83 c4 10             	add    $0x10,%esp
  800705:	85 c0                	test   %eax,%eax
  800707:	78 17                	js     800720 <readn+0x4d>
			return m;
		if (m == 0)
  800709:	85 c0                	test   %eax,%eax
  80070b:	74 11                	je     80071e <readn+0x4b>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80070d:	01 c3                	add    %eax,%ebx
  80070f:	89 d8                	mov    %ebx,%eax
  800711:	39 f3                	cmp    %esi,%ebx
  800713:	72 db                	jb     8006f0 <readn+0x1d>
  800715:	eb 09                	jmp    800720 <readn+0x4d>
  800717:	b8 00 00 00 00       	mov    $0x0,%eax
  80071c:	eb 02                	jmp    800720 <readn+0x4d>
		m = read(fdnum, (char*)buf + tot, n - tot);
		if (m < 0)
			return m;
		if (m == 0)
  80071e:	89 d8                	mov    %ebx,%eax
			break;
	}
	return tot;
}
  800720:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800723:	5b                   	pop    %ebx
  800724:	5e                   	pop    %esi
  800725:	5f                   	pop    %edi
  800726:	c9                   	leave  
  800727:	c3                   	ret    

00800728 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  800728:	55                   	push   %ebp
  800729:	89 e5                	mov    %esp,%ebp
  80072b:	53                   	push   %ebx
  80072c:	83 ec 14             	sub    $0x14,%esp
  80072f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800732:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800735:	50                   	push   %eax
  800736:	53                   	push   %ebx
  800737:	e8 8f fc ff ff       	call   8003cb <fd_lookup>
  80073c:	83 c4 08             	add    $0x8,%esp
  80073f:	85 c0                	test   %eax,%eax
  800741:	78 62                	js     8007a5 <write+0x7d>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800743:	83 ec 08             	sub    $0x8,%esp
  800746:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800749:	50                   	push   %eax
  80074a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80074d:	ff 30                	pushl  (%eax)
  80074f:	e8 cd fc ff ff       	call   800421 <dev_lookup>
  800754:	83 c4 10             	add    $0x10,%esp
  800757:	85 c0                	test   %eax,%eax
  800759:	78 4a                	js     8007a5 <write+0x7d>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80075b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80075e:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  800762:	75 21                	jne    800785 <write+0x5d>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  800764:	a1 04 40 80 00       	mov    0x804004,%eax
  800769:	8b 40 48             	mov    0x48(%eax),%eax
  80076c:	83 ec 04             	sub    $0x4,%esp
  80076f:	53                   	push   %ebx
  800770:	50                   	push   %eax
  800771:	68 b5 1e 80 00       	push   $0x801eb5
  800776:	e8 41 09 00 00       	call   8010bc <cprintf>
		return -E_INVAL;
  80077b:	83 c4 10             	add    $0x10,%esp
  80077e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800783:	eb 20                	jmp    8007a5 <write+0x7d>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  800785:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800788:	8b 52 0c             	mov    0xc(%edx),%edx
  80078b:	85 d2                	test   %edx,%edx
  80078d:	74 11                	je     8007a0 <write+0x78>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80078f:	83 ec 04             	sub    $0x4,%esp
  800792:	ff 75 10             	pushl  0x10(%ebp)
  800795:	ff 75 0c             	pushl  0xc(%ebp)
  800798:	50                   	push   %eax
  800799:	ff d2                	call   *%edx
  80079b:	83 c4 10             	add    $0x10,%esp
  80079e:	eb 05                	jmp    8007a5 <write+0x7d>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8007a0:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  8007a5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007a8:	c9                   	leave  
  8007a9:	c3                   	ret    

008007aa <seek>:

int
seek(int fdnum, off_t offset)
{
  8007aa:	55                   	push   %ebp
  8007ab:	89 e5                	mov    %esp,%ebp
  8007ad:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8007b0:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8007b3:	50                   	push   %eax
  8007b4:	ff 75 08             	pushl  0x8(%ebp)
  8007b7:	e8 0f fc ff ff       	call   8003cb <fd_lookup>
  8007bc:	83 c4 08             	add    $0x8,%esp
  8007bf:	85 c0                	test   %eax,%eax
  8007c1:	78 0e                	js     8007d1 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8007c3:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8007c6:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007c9:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8007cc:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8007d1:	c9                   	leave  
  8007d2:	c3                   	ret    

008007d3 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8007d3:	55                   	push   %ebp
  8007d4:	89 e5                	mov    %esp,%ebp
  8007d6:	53                   	push   %ebx
  8007d7:	83 ec 14             	sub    $0x14,%esp
  8007da:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8007dd:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8007e0:	50                   	push   %eax
  8007e1:	53                   	push   %ebx
  8007e2:	e8 e4 fb ff ff       	call   8003cb <fd_lookup>
  8007e7:	83 c4 08             	add    $0x8,%esp
  8007ea:	85 c0                	test   %eax,%eax
  8007ec:	78 5f                	js     80084d <ftruncate+0x7a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8007ee:	83 ec 08             	sub    $0x8,%esp
  8007f1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8007f4:	50                   	push   %eax
  8007f5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8007f8:	ff 30                	pushl  (%eax)
  8007fa:	e8 22 fc ff ff       	call   800421 <dev_lookup>
  8007ff:	83 c4 10             	add    $0x10,%esp
  800802:	85 c0                	test   %eax,%eax
  800804:	78 47                	js     80084d <ftruncate+0x7a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800806:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800809:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80080d:	75 21                	jne    800830 <ftruncate+0x5d>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  80080f:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  800814:	8b 40 48             	mov    0x48(%eax),%eax
  800817:	83 ec 04             	sub    $0x4,%esp
  80081a:	53                   	push   %ebx
  80081b:	50                   	push   %eax
  80081c:	68 78 1e 80 00       	push   $0x801e78
  800821:	e8 96 08 00 00       	call   8010bc <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  800826:	83 c4 10             	add    $0x10,%esp
  800829:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80082e:	eb 1d                	jmp    80084d <ftruncate+0x7a>
	}
	if (!dev->dev_trunc)
  800830:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800833:	8b 52 18             	mov    0x18(%edx),%edx
  800836:	85 d2                	test   %edx,%edx
  800838:	74 0e                	je     800848 <ftruncate+0x75>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80083a:	83 ec 08             	sub    $0x8,%esp
  80083d:	ff 75 0c             	pushl  0xc(%ebp)
  800840:	50                   	push   %eax
  800841:	ff d2                	call   *%edx
  800843:	83 c4 10             	add    $0x10,%esp
  800846:	eb 05                	jmp    80084d <ftruncate+0x7a>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  800848:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  80084d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800850:	c9                   	leave  
  800851:	c3                   	ret    

00800852 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  800852:	55                   	push   %ebp
  800853:	89 e5                	mov    %esp,%ebp
  800855:	53                   	push   %ebx
  800856:	83 ec 14             	sub    $0x14,%esp
  800859:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80085c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80085f:	50                   	push   %eax
  800860:	ff 75 08             	pushl  0x8(%ebp)
  800863:	e8 63 fb ff ff       	call   8003cb <fd_lookup>
  800868:	83 c4 08             	add    $0x8,%esp
  80086b:	85 c0                	test   %eax,%eax
  80086d:	78 52                	js     8008c1 <fstat+0x6f>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80086f:	83 ec 08             	sub    $0x8,%esp
  800872:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800875:	50                   	push   %eax
  800876:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800879:	ff 30                	pushl  (%eax)
  80087b:	e8 a1 fb ff ff       	call   800421 <dev_lookup>
  800880:	83 c4 10             	add    $0x10,%esp
  800883:	85 c0                	test   %eax,%eax
  800885:	78 3a                	js     8008c1 <fstat+0x6f>
		return r;
	if (!dev->dev_stat)
  800887:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80088a:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  80088e:	74 2c                	je     8008bc <fstat+0x6a>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  800890:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  800893:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80089a:	00 00 00 
	stat->st_isdir = 0;
  80089d:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8008a4:	00 00 00 
	stat->st_dev = dev;
  8008a7:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8008ad:	83 ec 08             	sub    $0x8,%esp
  8008b0:	53                   	push   %ebx
  8008b1:	ff 75 f0             	pushl  -0x10(%ebp)
  8008b4:	ff 50 14             	call   *0x14(%eax)
  8008b7:	83 c4 10             	add    $0x10,%esp
  8008ba:	eb 05                	jmp    8008c1 <fstat+0x6f>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8008bc:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8008c1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8008c4:	c9                   	leave  
  8008c5:	c3                   	ret    

008008c6 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8008c6:	55                   	push   %ebp
  8008c7:	89 e5                	mov    %esp,%ebp
  8008c9:	56                   	push   %esi
  8008ca:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8008cb:	83 ec 08             	sub    $0x8,%esp
  8008ce:	6a 00                	push   $0x0
  8008d0:	ff 75 08             	pushl  0x8(%ebp)
  8008d3:	e8 78 01 00 00       	call   800a50 <open>
  8008d8:	89 c3                	mov    %eax,%ebx
  8008da:	83 c4 10             	add    $0x10,%esp
  8008dd:	85 c0                	test   %eax,%eax
  8008df:	78 1b                	js     8008fc <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8008e1:	83 ec 08             	sub    $0x8,%esp
  8008e4:	ff 75 0c             	pushl  0xc(%ebp)
  8008e7:	50                   	push   %eax
  8008e8:	e8 65 ff ff ff       	call   800852 <fstat>
  8008ed:	89 c6                	mov    %eax,%esi
	close(fd);
  8008ef:	89 1c 24             	mov    %ebx,(%esp)
  8008f2:	e8 18 fc ff ff       	call   80050f <close>
	return r;
  8008f7:	83 c4 10             	add    $0x10,%esp
  8008fa:	89 f3                	mov    %esi,%ebx
}
  8008fc:	89 d8                	mov    %ebx,%eax
  8008fe:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800901:	5b                   	pop    %ebx
  800902:	5e                   	pop    %esi
  800903:	c9                   	leave  
  800904:	c3                   	ret    
  800905:	00 00                	add    %al,(%eax)
	...

00800908 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  800908:	55                   	push   %ebp
  800909:	89 e5                	mov    %esp,%ebp
  80090b:	56                   	push   %esi
  80090c:	53                   	push   %ebx
  80090d:	89 c3                	mov    %eax,%ebx
  80090f:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  800911:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  800918:	75 12                	jne    80092c <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  80091a:	83 ec 0c             	sub    $0xc,%esp
  80091d:	6a 01                	push   $0x1
  80091f:	e8 02 12 00 00       	call   801b26 <ipc_find_env>
  800924:	a3 00 40 80 00       	mov    %eax,0x804000
  800929:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  80092c:	6a 07                	push   $0x7
  80092e:	68 00 50 80 00       	push   $0x805000
  800933:	53                   	push   %ebx
  800934:	ff 35 00 40 80 00    	pushl  0x804000
  80093a:	e8 92 11 00 00       	call   801ad1 <ipc_send>
	
	return ipc_recv(NULL, dstva, NULL);
  80093f:	83 c4 0c             	add    $0xc,%esp
  800942:	6a 00                	push   $0x0
  800944:	56                   	push   %esi
  800945:	6a 00                	push   $0x0
  800947:	e8 10 11 00 00       	call   801a5c <ipc_recv>
}
  80094c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80094f:	5b                   	pop    %ebx
  800950:	5e                   	pop    %esi
  800951:	c9                   	leave  
  800952:	c3                   	ret    

00800953 <devfile_stat>:
}


static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  800953:	55                   	push   %ebp
  800954:	89 e5                	mov    %esp,%ebp
  800956:	53                   	push   %ebx
  800957:	83 ec 04             	sub    $0x4,%esp
  80095a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  80095d:	8b 45 08             	mov    0x8(%ebp),%eax
  800960:	8b 40 0c             	mov    0xc(%eax),%eax
  800963:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0) {
  800968:	ba 00 00 00 00       	mov    $0x0,%edx
  80096d:	b8 05 00 00 00       	mov    $0x5,%eax
  800972:	e8 91 ff ff ff       	call   800908 <fsipc>
  800977:	85 c0                	test   %eax,%eax
  800979:	78 2c                	js     8009a7 <devfile_stat+0x54>
		return r;
	}
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  80097b:	83 ec 08             	sub    $0x8,%esp
  80097e:	68 00 50 80 00       	push   $0x805000
  800983:	53                   	push   %ebx
  800984:	e8 e9 0c 00 00       	call   801672 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  800989:	a1 80 50 80 00       	mov    0x805080,%eax
  80098e:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  800994:	a1 84 50 80 00       	mov    0x805084,%eax
  800999:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  80099f:	83 c4 10             	add    $0x10,%esp
  8009a2:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009a7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8009aa:	c9                   	leave  
  8009ab:	c3                   	ret    

008009ac <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8009ac:	55                   	push   %ebp
  8009ad:	89 e5                	mov    %esp,%ebp
  8009af:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8009b2:	8b 45 08             	mov    0x8(%ebp),%eax
  8009b5:	8b 40 0c             	mov    0xc(%eax),%eax
  8009b8:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8009bd:	ba 00 00 00 00       	mov    $0x0,%edx
  8009c2:	b8 06 00 00 00       	mov    $0x6,%eax
  8009c7:	e8 3c ff ff ff       	call   800908 <fsipc>
}
  8009cc:	c9                   	leave  
  8009cd:	c3                   	ret    

008009ce <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  8009ce:	55                   	push   %ebp
  8009cf:	89 e5                	mov    %esp,%ebp
  8009d1:	56                   	push   %esi
  8009d2:	53                   	push   %ebx
  8009d3:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8009d6:	8b 45 08             	mov    0x8(%ebp),%eax
  8009d9:	8b 40 0c             	mov    0xc(%eax),%eax
  8009dc:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  8009e1:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8009e7:	ba 00 00 00 00       	mov    $0x0,%edx
  8009ec:	b8 03 00 00 00       	mov    $0x3,%eax
  8009f1:	e8 12 ff ff ff       	call   800908 <fsipc>
  8009f6:	89 c3                	mov    %eax,%ebx
  8009f8:	85 c0                	test   %eax,%eax
  8009fa:	78 4b                	js     800a47 <devfile_read+0x79>
		return r;
	assert(r <= n);
  8009fc:	39 c6                	cmp    %eax,%esi
  8009fe:	73 16                	jae    800a16 <devfile_read+0x48>
  800a00:	68 e4 1e 80 00       	push   $0x801ee4
  800a05:	68 eb 1e 80 00       	push   $0x801eeb
  800a0a:	6a 7d                	push   $0x7d
  800a0c:	68 00 1f 80 00       	push   $0x801f00
  800a11:	e8 ce 05 00 00       	call   800fe4 <_panic>
	assert(r <= PGSIZE);
  800a16:	3d 00 10 00 00       	cmp    $0x1000,%eax
  800a1b:	7e 16                	jle    800a33 <devfile_read+0x65>
  800a1d:	68 0b 1f 80 00       	push   $0x801f0b
  800a22:	68 eb 1e 80 00       	push   $0x801eeb
  800a27:	6a 7e                	push   $0x7e
  800a29:	68 00 1f 80 00       	push   $0x801f00
  800a2e:	e8 b1 05 00 00       	call   800fe4 <_panic>
	memmove(buf, &fsipcbuf, r);
  800a33:	83 ec 04             	sub    $0x4,%esp
  800a36:	50                   	push   %eax
  800a37:	68 00 50 80 00       	push   $0x805000
  800a3c:	ff 75 0c             	pushl  0xc(%ebp)
  800a3f:	e8 ef 0d 00 00       	call   801833 <memmove>
	return r;
  800a44:	83 c4 10             	add    $0x10,%esp
}
  800a47:	89 d8                	mov    %ebx,%eax
  800a49:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800a4c:	5b                   	pop    %ebx
  800a4d:	5e                   	pop    %esi
  800a4e:	c9                   	leave  
  800a4f:	c3                   	ret    

00800a50 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  800a50:	55                   	push   %ebp
  800a51:	89 e5                	mov    %esp,%ebp
  800a53:	56                   	push   %esi
  800a54:	53                   	push   %ebx
  800a55:	83 ec 1c             	sub    $0x1c,%esp
  800a58:	8b 75 08             	mov    0x8(%ebp),%esi
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  800a5b:	56                   	push   %esi
  800a5c:	e8 bf 0b 00 00       	call   801620 <strlen>
  800a61:	83 c4 10             	add    $0x10,%esp
  800a64:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  800a69:	7f 65                	jg     800ad0 <open+0x80>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800a6b:	83 ec 0c             	sub    $0xc,%esp
  800a6e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800a71:	50                   	push   %eax
  800a72:	e8 e1 f8 ff ff       	call   800358 <fd_alloc>
  800a77:	89 c3                	mov    %eax,%ebx
  800a79:	83 c4 10             	add    $0x10,%esp
  800a7c:	85 c0                	test   %eax,%eax
  800a7e:	78 55                	js     800ad5 <open+0x85>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  800a80:	83 ec 08             	sub    $0x8,%esp
  800a83:	56                   	push   %esi
  800a84:	68 00 50 80 00       	push   $0x805000
  800a89:	e8 e4 0b 00 00       	call   801672 <strcpy>
	fsipcbuf.open.req_omode = mode;
  800a8e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a91:	a3 00 54 80 00       	mov    %eax,0x805400



	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  800a96:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800a99:	b8 01 00 00 00       	mov    $0x1,%eax
  800a9e:	e8 65 fe ff ff       	call   800908 <fsipc>
  800aa3:	89 c3                	mov    %eax,%ebx
  800aa5:	83 c4 10             	add    $0x10,%esp
  800aa8:	85 c0                	test   %eax,%eax
  800aaa:	79 12                	jns    800abe <open+0x6e>
		fd_close(fd, 0);
  800aac:	83 ec 08             	sub    $0x8,%esp
  800aaf:	6a 00                	push   $0x0
  800ab1:	ff 75 f4             	pushl  -0xc(%ebp)
  800ab4:	e8 ce f9 ff ff       	call   800487 <fd_close>
		return r;
  800ab9:	83 c4 10             	add    $0x10,%esp
  800abc:	eb 17                	jmp    800ad5 <open+0x85>
	}

	return fd2num(fd);
  800abe:	83 ec 0c             	sub    $0xc,%esp
  800ac1:	ff 75 f4             	pushl  -0xc(%ebp)
  800ac4:	e8 67 f8 ff ff       	call   800330 <fd2num>
  800ac9:	89 c3                	mov    %eax,%ebx
  800acb:	83 c4 10             	add    $0x10,%esp
  800ace:	eb 05                	jmp    800ad5 <open+0x85>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  800ad0:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  800ad5:	89 d8                	mov    %ebx,%eax
  800ad7:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800ada:	5b                   	pop    %ebx
  800adb:	5e                   	pop    %esi
  800adc:	c9                   	leave  
  800add:	c3                   	ret    
	...

00800ae0 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  800ae0:	55                   	push   %ebp
  800ae1:	89 e5                	mov    %esp,%ebp
  800ae3:	56                   	push   %esi
  800ae4:	53                   	push   %ebx
  800ae5:	8b 75 0c             	mov    0xc(%ebp),%esi
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  800ae8:	83 ec 0c             	sub    $0xc,%esp
  800aeb:	ff 75 08             	pushl  0x8(%ebp)
  800aee:	e8 4d f8 ff ff       	call   800340 <fd2data>
  800af3:	89 c3                	mov    %eax,%ebx
	strcpy(stat->st_name, "<pipe>");
  800af5:	83 c4 08             	add    $0x8,%esp
  800af8:	68 17 1f 80 00       	push   $0x801f17
  800afd:	56                   	push   %esi
  800afe:	e8 6f 0b 00 00       	call   801672 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  800b03:	8b 43 04             	mov    0x4(%ebx),%eax
  800b06:	2b 03                	sub    (%ebx),%eax
  800b08:	89 86 80 00 00 00    	mov    %eax,0x80(%esi)
	stat->st_isdir = 0;
  800b0e:	c7 86 84 00 00 00 00 	movl   $0x0,0x84(%esi)
  800b15:	00 00 00 
	stat->st_dev = &devpipe;
  800b18:	c7 86 88 00 00 00 20 	movl   $0x803020,0x88(%esi)
  800b1f:	30 80 00 
	return 0;
}
  800b22:	b8 00 00 00 00       	mov    $0x0,%eax
  800b27:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800b2a:	5b                   	pop    %ebx
  800b2b:	5e                   	pop    %esi
  800b2c:	c9                   	leave  
  800b2d:	c3                   	ret    

00800b2e <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  800b2e:	55                   	push   %ebp
  800b2f:	89 e5                	mov    %esp,%ebp
  800b31:	53                   	push   %ebx
  800b32:	83 ec 0c             	sub    $0xc,%esp
  800b35:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  800b38:	53                   	push   %ebx
  800b39:	6a 00                	push   $0x0
  800b3b:	e8 d2 f6 ff ff       	call   800212 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  800b40:	89 1c 24             	mov    %ebx,(%esp)
  800b43:	e8 f8 f7 ff ff       	call   800340 <fd2data>
  800b48:	83 c4 08             	add    $0x8,%esp
  800b4b:	50                   	push   %eax
  800b4c:	6a 00                	push   $0x0
  800b4e:	e8 bf f6 ff ff       	call   800212 <sys_page_unmap>
}
  800b53:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800b56:	c9                   	leave  
  800b57:	c3                   	ret    

00800b58 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  800b58:	55                   	push   %ebp
  800b59:	89 e5                	mov    %esp,%ebp
  800b5b:	57                   	push   %edi
  800b5c:	56                   	push   %esi
  800b5d:	53                   	push   %ebx
  800b5e:	83 ec 1c             	sub    $0x1c,%esp
  800b61:	89 c7                	mov    %eax,%edi
  800b63:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  800b66:	a1 04 40 80 00       	mov    0x804004,%eax
  800b6b:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  800b6e:	83 ec 0c             	sub    $0xc,%esp
  800b71:	57                   	push   %edi
  800b72:	e8 0d 10 00 00       	call   801b84 <pageref>
  800b77:	89 c6                	mov    %eax,%esi
  800b79:	83 c4 04             	add    $0x4,%esp
  800b7c:	ff 75 e4             	pushl  -0x1c(%ebp)
  800b7f:	e8 00 10 00 00       	call   801b84 <pageref>
  800b84:	83 c4 10             	add    $0x10,%esp
  800b87:	39 c6                	cmp    %eax,%esi
  800b89:	0f 94 c0             	sete   %al
  800b8c:	0f b6 c0             	movzbl %al,%eax
		nn = thisenv->env_runs;
  800b8f:	8b 15 04 40 80 00    	mov    0x804004,%edx
  800b95:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  800b98:	39 cb                	cmp    %ecx,%ebx
  800b9a:	75 08                	jne    800ba4 <_pipeisclosed+0x4c>
			return ret;
		if (n != nn && ret == 1)
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
	}
}
  800b9c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b9f:	5b                   	pop    %ebx
  800ba0:	5e                   	pop    %esi
  800ba1:	5f                   	pop    %edi
  800ba2:	c9                   	leave  
  800ba3:	c3                   	ret    
		n = thisenv->env_runs;
		ret = pageref(fd) == pageref(p);
		nn = thisenv->env_runs;
		if (n == nn)
			return ret;
		if (n != nn && ret == 1)
  800ba4:	83 f8 01             	cmp    $0x1,%eax
  800ba7:	75 bd                	jne    800b66 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  800ba9:	8b 42 58             	mov    0x58(%edx),%eax
  800bac:	6a 01                	push   $0x1
  800bae:	50                   	push   %eax
  800baf:	53                   	push   %ebx
  800bb0:	68 1e 1f 80 00       	push   $0x801f1e
  800bb5:	e8 02 05 00 00       	call   8010bc <cprintf>
  800bba:	83 c4 10             	add    $0x10,%esp
  800bbd:	eb a7                	jmp    800b66 <_pipeisclosed+0xe>

00800bbf <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  800bbf:	55                   	push   %ebp
  800bc0:	89 e5                	mov    %esp,%ebp
  800bc2:	57                   	push   %edi
  800bc3:	56                   	push   %esi
  800bc4:	53                   	push   %ebx
  800bc5:	83 ec 28             	sub    $0x28,%esp
  800bc8:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  800bcb:	56                   	push   %esi
  800bcc:	e8 6f f7 ff ff       	call   800340 <fd2data>
  800bd1:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800bd3:	83 c4 10             	add    $0x10,%esp
  800bd6:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800bda:	75 4a                	jne    800c26 <devpipe_write+0x67>
  800bdc:	bf 00 00 00 00       	mov    $0x0,%edi
  800be1:	eb 56                	jmp    800c39 <devpipe_write+0x7a>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  800be3:	89 da                	mov    %ebx,%edx
  800be5:	89 f0                	mov    %esi,%eax
  800be7:	e8 6c ff ff ff       	call   800b58 <_pipeisclosed>
  800bec:	85 c0                	test   %eax,%eax
  800bee:	75 4d                	jne    800c3d <devpipe_write+0x7e>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  800bf0:	e8 ac f5 ff ff       	call   8001a1 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  800bf5:	8b 43 04             	mov    0x4(%ebx),%eax
  800bf8:	8b 13                	mov    (%ebx),%edx
  800bfa:	83 c2 20             	add    $0x20,%edx
  800bfd:	39 d0                	cmp    %edx,%eax
  800bff:	73 e2                	jae    800be3 <devpipe_write+0x24>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  800c01:	89 c2                	mov    %eax,%edx
  800c03:	81 e2 1f 00 00 80    	and    $0x8000001f,%edx
  800c09:	79 05                	jns    800c10 <devpipe_write+0x51>
  800c0b:	4a                   	dec    %edx
  800c0c:	83 ca e0             	or     $0xffffffe0,%edx
  800c0f:	42                   	inc    %edx
  800c10:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c13:	8a 0c 39             	mov    (%ecx,%edi,1),%cl
  800c16:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  800c1a:	40                   	inc    %eax
  800c1b:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800c1e:	47                   	inc    %edi
  800c1f:	39 7d 10             	cmp    %edi,0x10(%ebp)
  800c22:	77 07                	ja     800c2b <devpipe_write+0x6c>
  800c24:	eb 13                	jmp    800c39 <devpipe_write+0x7a>
  800c26:	bf 00 00 00 00       	mov    $0x0,%edi
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  800c2b:	8b 43 04             	mov    0x4(%ebx),%eax
  800c2e:	8b 13                	mov    (%ebx),%edx
  800c30:	83 c2 20             	add    $0x20,%edx
  800c33:	39 d0                	cmp    %edx,%eax
  800c35:	73 ac                	jae    800be3 <devpipe_write+0x24>
  800c37:	eb c8                	jmp    800c01 <devpipe_write+0x42>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  800c39:	89 f8                	mov    %edi,%eax
  800c3b:	eb 05                	jmp    800c42 <devpipe_write+0x83>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  800c3d:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  800c42:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c45:	5b                   	pop    %ebx
  800c46:	5e                   	pop    %esi
  800c47:	5f                   	pop    %edi
  800c48:	c9                   	leave  
  800c49:	c3                   	ret    

00800c4a <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  800c4a:	55                   	push   %ebp
  800c4b:	89 e5                	mov    %esp,%ebp
  800c4d:	57                   	push   %edi
  800c4e:	56                   	push   %esi
  800c4f:	53                   	push   %ebx
  800c50:	83 ec 18             	sub    $0x18,%esp
  800c53:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  800c56:	57                   	push   %edi
  800c57:	e8 e4 f6 ff ff       	call   800340 <fd2data>
  800c5c:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800c5e:	83 c4 10             	add    $0x10,%esp
  800c61:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800c65:	75 44                	jne    800cab <devpipe_read+0x61>
  800c67:	be 00 00 00 00       	mov    $0x0,%esi
  800c6c:	eb 4f                	jmp    800cbd <devpipe_read+0x73>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
				return i;
  800c6e:	89 f0                	mov    %esi,%eax
  800c70:	eb 54                	jmp    800cc6 <devpipe_read+0x7c>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  800c72:	89 da                	mov    %ebx,%edx
  800c74:	89 f8                	mov    %edi,%eax
  800c76:	e8 dd fe ff ff       	call   800b58 <_pipeisclosed>
  800c7b:	85 c0                	test   %eax,%eax
  800c7d:	75 42                	jne    800cc1 <devpipe_read+0x77>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  800c7f:	e8 1d f5 ff ff       	call   8001a1 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  800c84:	8b 03                	mov    (%ebx),%eax
  800c86:	3b 43 04             	cmp    0x4(%ebx),%eax
  800c89:	74 e7                	je     800c72 <devpipe_read+0x28>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  800c8b:	25 1f 00 00 80       	and    $0x8000001f,%eax
  800c90:	79 05                	jns    800c97 <devpipe_read+0x4d>
  800c92:	48                   	dec    %eax
  800c93:	83 c8 e0             	or     $0xffffffe0,%eax
  800c96:	40                   	inc    %eax
  800c97:	8a 44 03 08          	mov    0x8(%ebx,%eax,1),%al
  800c9b:	8b 55 0c             	mov    0xc(%ebp),%edx
  800c9e:	88 04 32             	mov    %al,(%edx,%esi,1)
		p->p_rpos++;
  800ca1:	ff 03                	incl   (%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800ca3:	46                   	inc    %esi
  800ca4:	39 75 10             	cmp    %esi,0x10(%ebp)
  800ca7:	77 07                	ja     800cb0 <devpipe_read+0x66>
  800ca9:	eb 12                	jmp    800cbd <devpipe_read+0x73>
  800cab:	be 00 00 00 00       	mov    $0x0,%esi
		while (p->p_rpos == p->p_wpos) {
  800cb0:	8b 03                	mov    (%ebx),%eax
  800cb2:	3b 43 04             	cmp    0x4(%ebx),%eax
  800cb5:	75 d4                	jne    800c8b <devpipe_read+0x41>
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  800cb7:	85 f6                	test   %esi,%esi
  800cb9:	75 b3                	jne    800c6e <devpipe_read+0x24>
  800cbb:	eb b5                	jmp    800c72 <devpipe_read+0x28>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  800cbd:	89 f0                	mov    %esi,%eax
  800cbf:	eb 05                	jmp    800cc6 <devpipe_read+0x7c>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  800cc1:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  800cc6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cc9:	5b                   	pop    %ebx
  800cca:	5e                   	pop    %esi
  800ccb:	5f                   	pop    %edi
  800ccc:	c9                   	leave  
  800ccd:	c3                   	ret    

00800cce <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  800cce:	55                   	push   %ebp
  800ccf:	89 e5                	mov    %esp,%ebp
  800cd1:	57                   	push   %edi
  800cd2:	56                   	push   %esi
  800cd3:	53                   	push   %ebx
  800cd4:	83 ec 28             	sub    $0x28,%esp
  800cd7:	8b 7d 08             	mov    0x8(%ebp),%edi
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  800cda:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800cdd:	50                   	push   %eax
  800cde:	e8 75 f6 ff ff       	call   800358 <fd_alloc>
  800ce3:	89 c3                	mov    %eax,%ebx
  800ce5:	83 c4 10             	add    $0x10,%esp
  800ce8:	85 c0                	test   %eax,%eax
  800cea:	0f 88 24 01 00 00    	js     800e14 <pipe+0x146>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800cf0:	83 ec 04             	sub    $0x4,%esp
  800cf3:	68 07 04 00 00       	push   $0x407
  800cf8:	ff 75 e4             	pushl  -0x1c(%ebp)
  800cfb:	6a 00                	push   $0x0
  800cfd:	e8 c6 f4 ff ff       	call   8001c8 <sys_page_alloc>
  800d02:	89 c3                	mov    %eax,%ebx
  800d04:	83 c4 10             	add    $0x10,%esp
  800d07:	85 c0                	test   %eax,%eax
  800d09:	0f 88 05 01 00 00    	js     800e14 <pipe+0x146>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  800d0f:	83 ec 0c             	sub    $0xc,%esp
  800d12:	8d 45 e0             	lea    -0x20(%ebp),%eax
  800d15:	50                   	push   %eax
  800d16:	e8 3d f6 ff ff       	call   800358 <fd_alloc>
  800d1b:	89 c3                	mov    %eax,%ebx
  800d1d:	83 c4 10             	add    $0x10,%esp
  800d20:	85 c0                	test   %eax,%eax
  800d22:	0f 88 dc 00 00 00    	js     800e04 <pipe+0x136>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800d28:	83 ec 04             	sub    $0x4,%esp
  800d2b:	68 07 04 00 00       	push   $0x407
  800d30:	ff 75 e0             	pushl  -0x20(%ebp)
  800d33:	6a 00                	push   $0x0
  800d35:	e8 8e f4 ff ff       	call   8001c8 <sys_page_alloc>
  800d3a:	89 c3                	mov    %eax,%ebx
  800d3c:	83 c4 10             	add    $0x10,%esp
  800d3f:	85 c0                	test   %eax,%eax
  800d41:	0f 88 bd 00 00 00    	js     800e04 <pipe+0x136>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  800d47:	83 ec 0c             	sub    $0xc,%esp
  800d4a:	ff 75 e4             	pushl  -0x1c(%ebp)
  800d4d:	e8 ee f5 ff ff       	call   800340 <fd2data>
  800d52:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800d54:	83 c4 0c             	add    $0xc,%esp
  800d57:	68 07 04 00 00       	push   $0x407
  800d5c:	50                   	push   %eax
  800d5d:	6a 00                	push   $0x0
  800d5f:	e8 64 f4 ff ff       	call   8001c8 <sys_page_alloc>
  800d64:	89 c3                	mov    %eax,%ebx
  800d66:	83 c4 10             	add    $0x10,%esp
  800d69:	85 c0                	test   %eax,%eax
  800d6b:	0f 88 83 00 00 00    	js     800df4 <pipe+0x126>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800d71:	83 ec 0c             	sub    $0xc,%esp
  800d74:	ff 75 e0             	pushl  -0x20(%ebp)
  800d77:	e8 c4 f5 ff ff       	call   800340 <fd2data>
  800d7c:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  800d83:	50                   	push   %eax
  800d84:	6a 00                	push   $0x0
  800d86:	56                   	push   %esi
  800d87:	6a 00                	push   $0x0
  800d89:	e8 5e f4 ff ff       	call   8001ec <sys_page_map>
  800d8e:	89 c3                	mov    %eax,%ebx
  800d90:	83 c4 20             	add    $0x20,%esp
  800d93:	85 c0                	test   %eax,%eax
  800d95:	78 4f                	js     800de6 <pipe+0x118>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  800d97:	8b 15 20 30 80 00    	mov    0x803020,%edx
  800d9d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800da0:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  800da2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800da5:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  800dac:	8b 15 20 30 80 00    	mov    0x803020,%edx
  800db2:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800db5:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  800db7:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800dba:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  800dc1:	83 ec 0c             	sub    $0xc,%esp
  800dc4:	ff 75 e4             	pushl  -0x1c(%ebp)
  800dc7:	e8 64 f5 ff ff       	call   800330 <fd2num>
  800dcc:	89 07                	mov    %eax,(%edi)
	pfd[1] = fd2num(fd1);
  800dce:	83 c4 04             	add    $0x4,%esp
  800dd1:	ff 75 e0             	pushl  -0x20(%ebp)
  800dd4:	e8 57 f5 ff ff       	call   800330 <fd2num>
  800dd9:	89 47 04             	mov    %eax,0x4(%edi)
	return 0;
  800ddc:	83 c4 10             	add    $0x10,%esp
  800ddf:	bb 00 00 00 00       	mov    $0x0,%ebx
  800de4:	eb 2e                	jmp    800e14 <pipe+0x146>

    err3:
	sys_page_unmap(0, va);
  800de6:	83 ec 08             	sub    $0x8,%esp
  800de9:	56                   	push   %esi
  800dea:	6a 00                	push   $0x0
  800dec:	e8 21 f4 ff ff       	call   800212 <sys_page_unmap>
  800df1:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  800df4:	83 ec 08             	sub    $0x8,%esp
  800df7:	ff 75 e0             	pushl  -0x20(%ebp)
  800dfa:	6a 00                	push   $0x0
  800dfc:	e8 11 f4 ff ff       	call   800212 <sys_page_unmap>
  800e01:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  800e04:	83 ec 08             	sub    $0x8,%esp
  800e07:	ff 75 e4             	pushl  -0x1c(%ebp)
  800e0a:	6a 00                	push   $0x0
  800e0c:	e8 01 f4 ff ff       	call   800212 <sys_page_unmap>
  800e11:	83 c4 10             	add    $0x10,%esp
    err:
	return r;
}
  800e14:	89 d8                	mov    %ebx,%eax
  800e16:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e19:	5b                   	pop    %ebx
  800e1a:	5e                   	pop    %esi
  800e1b:	5f                   	pop    %edi
  800e1c:	c9                   	leave  
  800e1d:	c3                   	ret    

00800e1e <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  800e1e:	55                   	push   %ebp
  800e1f:	89 e5                	mov    %esp,%ebp
  800e21:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800e24:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800e27:	50                   	push   %eax
  800e28:	ff 75 08             	pushl  0x8(%ebp)
  800e2b:	e8 9b f5 ff ff       	call   8003cb <fd_lookup>
  800e30:	83 c4 10             	add    $0x10,%esp
  800e33:	85 c0                	test   %eax,%eax
  800e35:	78 18                	js     800e4f <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  800e37:	83 ec 0c             	sub    $0xc,%esp
  800e3a:	ff 75 f4             	pushl  -0xc(%ebp)
  800e3d:	e8 fe f4 ff ff       	call   800340 <fd2data>
	return _pipeisclosed(fd, p);
  800e42:	89 c2                	mov    %eax,%edx
  800e44:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800e47:	e8 0c fd ff ff       	call   800b58 <_pipeisclosed>
  800e4c:	83 c4 10             	add    $0x10,%esp
}
  800e4f:	c9                   	leave  
  800e50:	c3                   	ret    
  800e51:	00 00                	add    %al,(%eax)
	...

00800e54 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  800e54:	55                   	push   %ebp
  800e55:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  800e57:	b8 00 00 00 00       	mov    $0x0,%eax
  800e5c:	c9                   	leave  
  800e5d:	c3                   	ret    

00800e5e <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  800e5e:	55                   	push   %ebp
  800e5f:	89 e5                	mov    %esp,%ebp
  800e61:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  800e64:	68 36 1f 80 00       	push   $0x801f36
  800e69:	ff 75 0c             	pushl  0xc(%ebp)
  800e6c:	e8 01 08 00 00       	call   801672 <strcpy>
	return 0;
}
  800e71:	b8 00 00 00 00       	mov    $0x0,%eax
  800e76:	c9                   	leave  
  800e77:	c3                   	ret    

00800e78 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  800e78:	55                   	push   %ebp
  800e79:	89 e5                	mov    %esp,%ebp
  800e7b:	57                   	push   %edi
  800e7c:	56                   	push   %esi
  800e7d:	53                   	push   %ebx
  800e7e:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800e84:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800e88:	74 45                	je     800ecf <devcons_write+0x57>
  800e8a:	b8 00 00 00 00       	mov    $0x0,%eax
  800e8f:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  800e94:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  800e9a:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e9d:	29 c3                	sub    %eax,%ebx
		if (m > sizeof(buf) - 1)
  800e9f:	83 fb 7f             	cmp    $0x7f,%ebx
  800ea2:	76 05                	jbe    800ea9 <devcons_write+0x31>
			m = sizeof(buf) - 1;
  800ea4:	bb 7f 00 00 00       	mov    $0x7f,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  800ea9:	83 ec 04             	sub    $0x4,%esp
  800eac:	53                   	push   %ebx
  800ead:	03 45 0c             	add    0xc(%ebp),%eax
  800eb0:	50                   	push   %eax
  800eb1:	57                   	push   %edi
  800eb2:	e8 7c 09 00 00       	call   801833 <memmove>
		sys_cputs(buf, m);
  800eb7:	83 c4 08             	add    $0x8,%esp
  800eba:	53                   	push   %ebx
  800ebb:	57                   	push   %edi
  800ebc:	e8 50 f2 ff ff       	call   800111 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800ec1:	01 de                	add    %ebx,%esi
  800ec3:	89 f0                	mov    %esi,%eax
  800ec5:	83 c4 10             	add    $0x10,%esp
  800ec8:	3b 75 10             	cmp    0x10(%ebp),%esi
  800ecb:	72 cd                	jb     800e9a <devcons_write+0x22>
  800ecd:	eb 05                	jmp    800ed4 <devcons_write+0x5c>
  800ecf:	be 00 00 00 00       	mov    $0x0,%esi
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  800ed4:	89 f0                	mov    %esi,%eax
  800ed6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ed9:	5b                   	pop    %ebx
  800eda:	5e                   	pop    %esi
  800edb:	5f                   	pop    %edi
  800edc:	c9                   	leave  
  800edd:	c3                   	ret    

00800ede <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  800ede:	55                   	push   %ebp
  800edf:	89 e5                	mov    %esp,%ebp
  800ee1:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
  800ee4:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800ee8:	75 07                	jne    800ef1 <devcons_read+0x13>
  800eea:	eb 25                	jmp    800f11 <devcons_read+0x33>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  800eec:	e8 b0 f2 ff ff       	call   8001a1 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  800ef1:	e8 41 f2 ff ff       	call   800137 <sys_cgetc>
  800ef6:	85 c0                	test   %eax,%eax
  800ef8:	74 f2                	je     800eec <devcons_read+0xe>
  800efa:	89 c2                	mov    %eax,%edx
		sys_yield();
	if (c < 0)
  800efc:	85 c0                	test   %eax,%eax
  800efe:	78 1d                	js     800f1d <devcons_read+0x3f>
		return c;
	if (c == 0x04)	// ctl-d is eof
  800f00:	83 f8 04             	cmp    $0x4,%eax
  800f03:	74 13                	je     800f18 <devcons_read+0x3a>
		return 0;
	*(char*)vbuf = c;
  800f05:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f08:	88 10                	mov    %dl,(%eax)
	return 1;
  800f0a:	b8 01 00 00 00       	mov    $0x1,%eax
  800f0f:	eb 0c                	jmp    800f1d <devcons_read+0x3f>
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
		return 0;
  800f11:	b8 00 00 00 00       	mov    $0x0,%eax
  800f16:	eb 05                	jmp    800f1d <devcons_read+0x3f>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  800f18:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  800f1d:	c9                   	leave  
  800f1e:	c3                   	ret    

00800f1f <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  800f1f:	55                   	push   %ebp
  800f20:	89 e5                	mov    %esp,%ebp
  800f22:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  800f25:	8b 45 08             	mov    0x8(%ebp),%eax
  800f28:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  800f2b:	6a 01                	push   $0x1
  800f2d:	8d 45 f7             	lea    -0x9(%ebp),%eax
  800f30:	50                   	push   %eax
  800f31:	e8 db f1 ff ff       	call   800111 <sys_cputs>
  800f36:	83 c4 10             	add    $0x10,%esp
}
  800f39:	c9                   	leave  
  800f3a:	c3                   	ret    

00800f3b <getchar>:

int
getchar(void)
{
  800f3b:	55                   	push   %ebp
  800f3c:	89 e5                	mov    %esp,%ebp
  800f3e:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  800f41:	6a 01                	push   $0x1
  800f43:	8d 45 f7             	lea    -0x9(%ebp),%eax
  800f46:	50                   	push   %eax
  800f47:	6a 00                	push   $0x0
  800f49:	e8 fe f6 ff ff       	call   80064c <read>
	if (r < 0)
  800f4e:	83 c4 10             	add    $0x10,%esp
  800f51:	85 c0                	test   %eax,%eax
  800f53:	78 0f                	js     800f64 <getchar+0x29>
		return r;
	if (r < 1)
  800f55:	85 c0                	test   %eax,%eax
  800f57:	7e 06                	jle    800f5f <getchar+0x24>
		return -E_EOF;
	return c;
  800f59:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  800f5d:	eb 05                	jmp    800f64 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  800f5f:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  800f64:	c9                   	leave  
  800f65:	c3                   	ret    

00800f66 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  800f66:	55                   	push   %ebp
  800f67:	89 e5                	mov    %esp,%ebp
  800f69:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800f6c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800f6f:	50                   	push   %eax
  800f70:	ff 75 08             	pushl  0x8(%ebp)
  800f73:	e8 53 f4 ff ff       	call   8003cb <fd_lookup>
  800f78:	83 c4 10             	add    $0x10,%esp
  800f7b:	85 c0                	test   %eax,%eax
  800f7d:	78 11                	js     800f90 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  800f7f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800f82:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  800f88:	39 10                	cmp    %edx,(%eax)
  800f8a:	0f 94 c0             	sete   %al
  800f8d:	0f b6 c0             	movzbl %al,%eax
}
  800f90:	c9                   	leave  
  800f91:	c3                   	ret    

00800f92 <opencons>:

int
opencons(void)
{
  800f92:	55                   	push   %ebp
  800f93:	89 e5                	mov    %esp,%ebp
  800f95:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  800f98:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800f9b:	50                   	push   %eax
  800f9c:	e8 b7 f3 ff ff       	call   800358 <fd_alloc>
  800fa1:	83 c4 10             	add    $0x10,%esp
  800fa4:	85 c0                	test   %eax,%eax
  800fa6:	78 3a                	js     800fe2 <opencons+0x50>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  800fa8:	83 ec 04             	sub    $0x4,%esp
  800fab:	68 07 04 00 00       	push   $0x407
  800fb0:	ff 75 f4             	pushl  -0xc(%ebp)
  800fb3:	6a 00                	push   $0x0
  800fb5:	e8 0e f2 ff ff       	call   8001c8 <sys_page_alloc>
  800fba:	83 c4 10             	add    $0x10,%esp
  800fbd:	85 c0                	test   %eax,%eax
  800fbf:	78 21                	js     800fe2 <opencons+0x50>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  800fc1:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  800fc7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800fca:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  800fcc:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800fcf:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  800fd6:	83 ec 0c             	sub    $0xc,%esp
  800fd9:	50                   	push   %eax
  800fda:	e8 51 f3 ff ff       	call   800330 <fd2num>
  800fdf:	83 c4 10             	add    $0x10,%esp
}
  800fe2:	c9                   	leave  
  800fe3:	c3                   	ret    

00800fe4 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800fe4:	55                   	push   %ebp
  800fe5:	89 e5                	mov    %esp,%ebp
  800fe7:	56                   	push   %esi
  800fe8:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800fe9:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800fec:	8b 1d 00 30 80 00    	mov    0x803000,%ebx
  800ff2:	e8 86 f1 ff ff       	call   80017d <sys_getenvid>
  800ff7:	83 ec 0c             	sub    $0xc,%esp
  800ffa:	ff 75 0c             	pushl  0xc(%ebp)
  800ffd:	ff 75 08             	pushl  0x8(%ebp)
  801000:	53                   	push   %ebx
  801001:	50                   	push   %eax
  801002:	68 44 1f 80 00       	push   $0x801f44
  801007:	e8 b0 00 00 00       	call   8010bc <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80100c:	83 c4 18             	add    $0x18,%esp
  80100f:	56                   	push   %esi
  801010:	ff 75 10             	pushl  0x10(%ebp)
  801013:	e8 53 00 00 00       	call   80106b <vcprintf>
	cprintf("\n");
  801018:	c7 04 24 2f 1f 80 00 	movl   $0x801f2f,(%esp)
  80101f:	e8 98 00 00 00       	call   8010bc <cprintf>
  801024:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801027:	cc                   	int3   
  801028:	eb fd                	jmp    801027 <_panic+0x43>
	...

0080102c <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80102c:	55                   	push   %ebp
  80102d:	89 e5                	mov    %esp,%ebp
  80102f:	53                   	push   %ebx
  801030:	83 ec 04             	sub    $0x4,%esp
  801033:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  801036:	8b 03                	mov    (%ebx),%eax
  801038:	8b 55 08             	mov    0x8(%ebp),%edx
  80103b:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  80103f:	40                   	inc    %eax
  801040:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  801042:	3d ff 00 00 00       	cmp    $0xff,%eax
  801047:	75 1a                	jne    801063 <putch+0x37>
		sys_cputs(b->buf, b->idx);
  801049:	83 ec 08             	sub    $0x8,%esp
  80104c:	68 ff 00 00 00       	push   $0xff
  801051:	8d 43 08             	lea    0x8(%ebx),%eax
  801054:	50                   	push   %eax
  801055:	e8 b7 f0 ff ff       	call   800111 <sys_cputs>
		b->idx = 0;
  80105a:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801060:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  801063:	ff 43 04             	incl   0x4(%ebx)
}
  801066:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801069:	c9                   	leave  
  80106a:	c3                   	ret    

0080106b <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80106b:	55                   	push   %ebp
  80106c:	89 e5                	mov    %esp,%ebp
  80106e:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  801074:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80107b:	00 00 00 
	b.cnt = 0;
  80107e:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  801085:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  801088:	ff 75 0c             	pushl  0xc(%ebp)
  80108b:	ff 75 08             	pushl  0x8(%ebp)
  80108e:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  801094:	50                   	push   %eax
  801095:	68 2c 10 80 00       	push   $0x80102c
  80109a:	e8 82 01 00 00       	call   801221 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80109f:	83 c4 08             	add    $0x8,%esp
  8010a2:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8010a8:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8010ae:	50                   	push   %eax
  8010af:	e8 5d f0 ff ff       	call   800111 <sys_cputs>

	return b.cnt;
}
  8010b4:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8010ba:	c9                   	leave  
  8010bb:	c3                   	ret    

008010bc <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8010bc:	55                   	push   %ebp
  8010bd:	89 e5                	mov    %esp,%ebp
  8010bf:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8010c2:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8010c5:	50                   	push   %eax
  8010c6:	ff 75 08             	pushl  0x8(%ebp)
  8010c9:	e8 9d ff ff ff       	call   80106b <vcprintf>
	va_end(ap);

	return cnt;
}
  8010ce:	c9                   	leave  
  8010cf:	c3                   	ret    

008010d0 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8010d0:	55                   	push   %ebp
  8010d1:	89 e5                	mov    %esp,%ebp
  8010d3:	57                   	push   %edi
  8010d4:	56                   	push   %esi
  8010d5:	53                   	push   %ebx
  8010d6:	83 ec 2c             	sub    $0x2c,%esp
  8010d9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8010dc:	89 d6                	mov    %edx,%esi
  8010de:	8b 45 08             	mov    0x8(%ebp),%eax
  8010e1:	8b 55 0c             	mov    0xc(%ebp),%edx
  8010e4:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8010e7:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8010ea:	8b 45 10             	mov    0x10(%ebp),%eax
  8010ed:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8010f0:	8b 7d 18             	mov    0x18(%ebp),%edi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8010f3:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8010f6:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  8010fd:	39 55 d4             	cmp    %edx,-0x2c(%ebp)
  801100:	72 0c                	jb     80110e <printnum+0x3e>
  801102:	3b 45 d8             	cmp    -0x28(%ebp),%eax
  801105:	76 07                	jbe    80110e <printnum+0x3e>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  801107:	4b                   	dec    %ebx
  801108:	85 db                	test   %ebx,%ebx
  80110a:	7f 31                	jg     80113d <printnum+0x6d>
  80110c:	eb 3f                	jmp    80114d <printnum+0x7d>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80110e:	83 ec 0c             	sub    $0xc,%esp
  801111:	57                   	push   %edi
  801112:	4b                   	dec    %ebx
  801113:	53                   	push   %ebx
  801114:	50                   	push   %eax
  801115:	83 ec 08             	sub    $0x8,%esp
  801118:	ff 75 d4             	pushl  -0x2c(%ebp)
  80111b:	ff 75 d0             	pushl  -0x30(%ebp)
  80111e:	ff 75 dc             	pushl  -0x24(%ebp)
  801121:	ff 75 d8             	pushl  -0x28(%ebp)
  801124:	e8 9f 0a 00 00       	call   801bc8 <__udivdi3>
  801129:	83 c4 18             	add    $0x18,%esp
  80112c:	52                   	push   %edx
  80112d:	50                   	push   %eax
  80112e:	89 f2                	mov    %esi,%edx
  801130:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801133:	e8 98 ff ff ff       	call   8010d0 <printnum>
  801138:	83 c4 20             	add    $0x20,%esp
  80113b:	eb 10                	jmp    80114d <printnum+0x7d>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80113d:	83 ec 08             	sub    $0x8,%esp
  801140:	56                   	push   %esi
  801141:	57                   	push   %edi
  801142:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  801145:	4b                   	dec    %ebx
  801146:	83 c4 10             	add    $0x10,%esp
  801149:	85 db                	test   %ebx,%ebx
  80114b:	7f f0                	jg     80113d <printnum+0x6d>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80114d:	83 ec 08             	sub    $0x8,%esp
  801150:	56                   	push   %esi
  801151:	83 ec 04             	sub    $0x4,%esp
  801154:	ff 75 d4             	pushl  -0x2c(%ebp)
  801157:	ff 75 d0             	pushl  -0x30(%ebp)
  80115a:	ff 75 dc             	pushl  -0x24(%ebp)
  80115d:	ff 75 d8             	pushl  -0x28(%ebp)
  801160:	e8 7f 0b 00 00       	call   801ce4 <__umoddi3>
  801165:	83 c4 14             	add    $0x14,%esp
  801168:	0f be 80 67 1f 80 00 	movsbl 0x801f67(%eax),%eax
  80116f:	50                   	push   %eax
  801170:	ff 55 e4             	call   *-0x1c(%ebp)
  801173:	83 c4 10             	add    $0x10,%esp
}
  801176:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801179:	5b                   	pop    %ebx
  80117a:	5e                   	pop    %esi
  80117b:	5f                   	pop    %edi
  80117c:	c9                   	leave  
  80117d:	c3                   	ret    

0080117e <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80117e:	55                   	push   %ebp
  80117f:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  801181:	83 fa 01             	cmp    $0x1,%edx
  801184:	7e 0e                	jle    801194 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  801186:	8b 10                	mov    (%eax),%edx
  801188:	8d 4a 08             	lea    0x8(%edx),%ecx
  80118b:	89 08                	mov    %ecx,(%eax)
  80118d:	8b 02                	mov    (%edx),%eax
  80118f:	8b 52 04             	mov    0x4(%edx),%edx
  801192:	eb 22                	jmp    8011b6 <getuint+0x38>
	else if (lflag)
  801194:	85 d2                	test   %edx,%edx
  801196:	74 10                	je     8011a8 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  801198:	8b 10                	mov    (%eax),%edx
  80119a:	8d 4a 04             	lea    0x4(%edx),%ecx
  80119d:	89 08                	mov    %ecx,(%eax)
  80119f:	8b 02                	mov    (%edx),%eax
  8011a1:	ba 00 00 00 00       	mov    $0x0,%edx
  8011a6:	eb 0e                	jmp    8011b6 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8011a8:	8b 10                	mov    (%eax),%edx
  8011aa:	8d 4a 04             	lea    0x4(%edx),%ecx
  8011ad:	89 08                	mov    %ecx,(%eax)
  8011af:	8b 02                	mov    (%edx),%eax
  8011b1:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8011b6:	c9                   	leave  
  8011b7:	c3                   	ret    

008011b8 <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
  8011b8:	55                   	push   %ebp
  8011b9:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8011bb:	83 fa 01             	cmp    $0x1,%edx
  8011be:	7e 0e                	jle    8011ce <getint+0x16>
		return va_arg(*ap, long long);
  8011c0:	8b 10                	mov    (%eax),%edx
  8011c2:	8d 4a 08             	lea    0x8(%edx),%ecx
  8011c5:	89 08                	mov    %ecx,(%eax)
  8011c7:	8b 02                	mov    (%edx),%eax
  8011c9:	8b 52 04             	mov    0x4(%edx),%edx
  8011cc:	eb 1a                	jmp    8011e8 <getint+0x30>
	else if (lflag)
  8011ce:	85 d2                	test   %edx,%edx
  8011d0:	74 0c                	je     8011de <getint+0x26>
		return va_arg(*ap, long);
  8011d2:	8b 10                	mov    (%eax),%edx
  8011d4:	8d 4a 04             	lea    0x4(%edx),%ecx
  8011d7:	89 08                	mov    %ecx,(%eax)
  8011d9:	8b 02                	mov    (%edx),%eax
  8011db:	99                   	cltd   
  8011dc:	eb 0a                	jmp    8011e8 <getint+0x30>
	else
		return va_arg(*ap, int);
  8011de:	8b 10                	mov    (%eax),%edx
  8011e0:	8d 4a 04             	lea    0x4(%edx),%ecx
  8011e3:	89 08                	mov    %ecx,(%eax)
  8011e5:	8b 02                	mov    (%edx),%eax
  8011e7:	99                   	cltd   
}
  8011e8:	c9                   	leave  
  8011e9:	c3                   	ret    

008011ea <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8011ea:	55                   	push   %ebp
  8011eb:	89 e5                	mov    %esp,%ebp
  8011ed:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8011f0:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  8011f3:	8b 10                	mov    (%eax),%edx
  8011f5:	3b 50 04             	cmp    0x4(%eax),%edx
  8011f8:	73 08                	jae    801202 <sprintputch+0x18>
		*b->buf++ = ch;
  8011fa:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8011fd:	88 0a                	mov    %cl,(%edx)
  8011ff:	42                   	inc    %edx
  801200:	89 10                	mov    %edx,(%eax)
}
  801202:	c9                   	leave  
  801203:	c3                   	ret    

00801204 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  801204:	55                   	push   %ebp
  801205:	89 e5                	mov    %esp,%ebp
  801207:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  80120a:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80120d:	50                   	push   %eax
  80120e:	ff 75 10             	pushl  0x10(%ebp)
  801211:	ff 75 0c             	pushl  0xc(%ebp)
  801214:	ff 75 08             	pushl  0x8(%ebp)
  801217:	e8 05 00 00 00       	call   801221 <vprintfmt>
	va_end(ap);
  80121c:	83 c4 10             	add    $0x10,%esp
}
  80121f:	c9                   	leave  
  801220:	c3                   	ret    

00801221 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  801221:	55                   	push   %ebp
  801222:	89 e5                	mov    %esp,%ebp
  801224:	57                   	push   %edi
  801225:	56                   	push   %esi
  801226:	53                   	push   %ebx
  801227:	83 ec 2c             	sub    $0x2c,%esp
  80122a:	8b 7d 0c             	mov    0xc(%ebp),%edi
  80122d:	8b 75 10             	mov    0x10(%ebp),%esi
  801230:	eb 13                	jmp    801245 <vprintfmt+0x24>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  801232:	85 c0                	test   %eax,%eax
  801234:	0f 84 6d 03 00 00    	je     8015a7 <vprintfmt+0x386>
				return;
			putch(ch, putdat);
  80123a:	83 ec 08             	sub    $0x8,%esp
  80123d:	57                   	push   %edi
  80123e:	50                   	push   %eax
  80123f:	ff 55 08             	call   *0x8(%ebp)
  801242:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  801245:	0f b6 06             	movzbl (%esi),%eax
  801248:	46                   	inc    %esi
  801249:	83 f8 25             	cmp    $0x25,%eax
  80124c:	75 e4                	jne    801232 <vprintfmt+0x11>
  80124e:	c6 45 dc 20          	movb   $0x20,-0x24(%ebp)
  801252:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  801259:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
  801260:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  801267:	b9 00 00 00 00       	mov    $0x0,%ecx
  80126c:	eb 28                	jmp    801296 <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80126e:	89 de                	mov    %ebx,%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  801270:	c6 45 dc 2d          	movb   $0x2d,-0x24(%ebp)
  801274:	eb 20                	jmp    801296 <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801276:	89 de                	mov    %ebx,%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  801278:	c6 45 dc 30          	movb   $0x30,-0x24(%ebp)
  80127c:	eb 18                	jmp    801296 <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80127e:	89 de                	mov    %ebx,%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  801280:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  801287:	eb 0d                	jmp    801296 <vprintfmt+0x75>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  801289:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80128c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80128f:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801296:	8a 06                	mov    (%esi),%al
  801298:	0f b6 d0             	movzbl %al,%edx
  80129b:	8d 5e 01             	lea    0x1(%esi),%ebx
  80129e:	83 e8 23             	sub    $0x23,%eax
  8012a1:	3c 55                	cmp    $0x55,%al
  8012a3:	0f 87 e0 02 00 00    	ja     801589 <vprintfmt+0x368>
  8012a9:	0f b6 c0             	movzbl %al,%eax
  8012ac:	ff 24 85 a0 20 80 00 	jmp    *0x8020a0(,%eax,4)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8012b3:	83 ea 30             	sub    $0x30,%edx
  8012b6:	89 55 d4             	mov    %edx,-0x2c(%ebp)
				ch = *fmt;
  8012b9:	0f be 03             	movsbl (%ebx),%eax
				if (ch < '0' || ch > '9')
  8012bc:	8d 50 d0             	lea    -0x30(%eax),%edx
  8012bf:	83 fa 09             	cmp    $0x9,%edx
  8012c2:	77 44                	ja     801308 <vprintfmt+0xe7>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8012c4:	89 de                	mov    %ebx,%esi
  8012c6:	8b 55 d4             	mov    -0x2c(%ebp),%edx
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8012c9:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
  8012ca:	8d 14 92             	lea    (%edx,%edx,4),%edx
  8012cd:	8d 54 50 d0          	lea    -0x30(%eax,%edx,2),%edx
				ch = *fmt;
  8012d1:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  8012d4:	8d 58 d0             	lea    -0x30(%eax),%ebx
  8012d7:	83 fb 09             	cmp    $0x9,%ebx
  8012da:	76 ed                	jbe    8012c9 <vprintfmt+0xa8>
  8012dc:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  8012df:	eb 29                	jmp    80130a <vprintfmt+0xe9>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8012e1:	8b 45 14             	mov    0x14(%ebp),%eax
  8012e4:	8d 50 04             	lea    0x4(%eax),%edx
  8012e7:	89 55 14             	mov    %edx,0x14(%ebp)
  8012ea:	8b 00                	mov    (%eax),%eax
  8012ec:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8012ef:	89 de                	mov    %ebx,%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8012f1:	eb 17                	jmp    80130a <vprintfmt+0xe9>

		case '.':
			if (width < 0)
  8012f3:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8012f7:	78 85                	js     80127e <vprintfmt+0x5d>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8012f9:	89 de                	mov    %ebx,%esi
  8012fb:	eb 99                	jmp    801296 <vprintfmt+0x75>
  8012fd:	89 de                	mov    %ebx,%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8012ff:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
			goto reswitch;
  801306:	eb 8e                	jmp    801296 <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801308:	89 de                	mov    %ebx,%esi
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  80130a:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80130e:	79 86                	jns    801296 <vprintfmt+0x75>
  801310:	e9 74 ff ff ff       	jmp    801289 <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  801315:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801316:	89 de                	mov    %ebx,%esi
  801318:	e9 79 ff ff ff       	jmp    801296 <vprintfmt+0x75>
  80131d:	89 5d d8             	mov    %ebx,-0x28(%ebp)
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  801320:	8b 45 14             	mov    0x14(%ebp),%eax
  801323:	8d 50 04             	lea    0x4(%eax),%edx
  801326:	89 55 14             	mov    %edx,0x14(%ebp)
  801329:	83 ec 08             	sub    $0x8,%esp
  80132c:	57                   	push   %edi
  80132d:	ff 30                	pushl  (%eax)
  80132f:	ff 55 08             	call   *0x8(%ebp)
			break;
  801332:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801335:	8b 75 d8             	mov    -0x28(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  801338:	e9 08 ff ff ff       	jmp    801245 <vprintfmt+0x24>
  80133d:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// error message
		case 'e':
			err = va_arg(ap, int);
  801340:	8b 45 14             	mov    0x14(%ebp),%eax
  801343:	8d 50 04             	lea    0x4(%eax),%edx
  801346:	89 55 14             	mov    %edx,0x14(%ebp)
  801349:	8b 00                	mov    (%eax),%eax
  80134b:	85 c0                	test   %eax,%eax
  80134d:	79 02                	jns    801351 <vprintfmt+0x130>
  80134f:	f7 d8                	neg    %eax
  801351:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  801353:	83 f8 0f             	cmp    $0xf,%eax
  801356:	7f 0b                	jg     801363 <vprintfmt+0x142>
  801358:	8b 04 85 00 22 80 00 	mov    0x802200(,%eax,4),%eax
  80135f:	85 c0                	test   %eax,%eax
  801361:	75 1a                	jne    80137d <vprintfmt+0x15c>
				printfmt(putch, putdat, "error %d", err);
  801363:	52                   	push   %edx
  801364:	68 7f 1f 80 00       	push   $0x801f7f
  801369:	57                   	push   %edi
  80136a:	ff 75 08             	pushl  0x8(%ebp)
  80136d:	e8 92 fe ff ff       	call   801204 <printfmt>
  801372:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801375:	8b 75 d8             	mov    -0x28(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  801378:	e9 c8 fe ff ff       	jmp    801245 <vprintfmt+0x24>
			else
				printfmt(putch, putdat, "%s", p);
  80137d:	50                   	push   %eax
  80137e:	68 fd 1e 80 00       	push   $0x801efd
  801383:	57                   	push   %edi
  801384:	ff 75 08             	pushl  0x8(%ebp)
  801387:	e8 78 fe ff ff       	call   801204 <printfmt>
  80138c:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80138f:	8b 75 d8             	mov    -0x28(%ebp),%esi
  801392:	e9 ae fe ff ff       	jmp    801245 <vprintfmt+0x24>
  801397:	89 5d d8             	mov    %ebx,-0x28(%ebp)
  80139a:	89 de                	mov    %ebx,%esi
  80139c:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  80139f:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8013a2:	8b 45 14             	mov    0x14(%ebp),%eax
  8013a5:	8d 50 04             	lea    0x4(%eax),%edx
  8013a8:	89 55 14             	mov    %edx,0x14(%ebp)
  8013ab:	8b 00                	mov    (%eax),%eax
  8013ad:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8013b0:	85 c0                	test   %eax,%eax
  8013b2:	75 07                	jne    8013bb <vprintfmt+0x19a>
				p = "(null)";
  8013b4:	c7 45 d0 78 1f 80 00 	movl   $0x801f78,-0x30(%ebp)
			if (width > 0 && padc != '-')
  8013bb:	85 db                	test   %ebx,%ebx
  8013bd:	7e 42                	jle    801401 <vprintfmt+0x1e0>
  8013bf:	80 7d dc 2d          	cmpb   $0x2d,-0x24(%ebp)
  8013c3:	74 3c                	je     801401 <vprintfmt+0x1e0>
				for (width -= strnlen(p, precision); width > 0; width--)
  8013c5:	83 ec 08             	sub    $0x8,%esp
  8013c8:	51                   	push   %ecx
  8013c9:	ff 75 d0             	pushl  -0x30(%ebp)
  8013cc:	e8 6f 02 00 00       	call   801640 <strnlen>
  8013d1:	29 c3                	sub    %eax,%ebx
  8013d3:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8013d6:	83 c4 10             	add    $0x10,%esp
  8013d9:	85 db                	test   %ebx,%ebx
  8013db:	7e 24                	jle    801401 <vprintfmt+0x1e0>
					putch(padc, putdat);
  8013dd:	0f be 5d dc          	movsbl -0x24(%ebp),%ebx
  8013e1:	89 75 dc             	mov    %esi,-0x24(%ebp)
  8013e4:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  8013e7:	83 ec 08             	sub    $0x8,%esp
  8013ea:	57                   	push   %edi
  8013eb:	53                   	push   %ebx
  8013ec:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8013ef:	4e                   	dec    %esi
  8013f0:	83 c4 10             	add    $0x10,%esp
  8013f3:	85 f6                	test   %esi,%esi
  8013f5:	7f f0                	jg     8013e7 <vprintfmt+0x1c6>
  8013f7:	8b 75 dc             	mov    -0x24(%ebp),%esi
  8013fa:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  801401:	8b 55 d0             	mov    -0x30(%ebp),%edx
  801404:	0f be 02             	movsbl (%edx),%eax
  801407:	85 c0                	test   %eax,%eax
  801409:	75 47                	jne    801452 <vprintfmt+0x231>
  80140b:	eb 37                	jmp    801444 <vprintfmt+0x223>
				if (altflag && (ch < ' ' || ch > '~'))
  80140d:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  801411:	74 16                	je     801429 <vprintfmt+0x208>
  801413:	8d 50 e0             	lea    -0x20(%eax),%edx
  801416:	83 fa 5e             	cmp    $0x5e,%edx
  801419:	76 0e                	jbe    801429 <vprintfmt+0x208>
					putch('?', putdat);
  80141b:	83 ec 08             	sub    $0x8,%esp
  80141e:	57                   	push   %edi
  80141f:	6a 3f                	push   $0x3f
  801421:	ff 55 08             	call   *0x8(%ebp)
  801424:	83 c4 10             	add    $0x10,%esp
  801427:	eb 0b                	jmp    801434 <vprintfmt+0x213>
				else
					putch(ch, putdat);
  801429:	83 ec 08             	sub    $0x8,%esp
  80142c:	57                   	push   %edi
  80142d:	50                   	push   %eax
  80142e:	ff 55 08             	call   *0x8(%ebp)
  801431:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  801434:	ff 4d e4             	decl   -0x1c(%ebp)
  801437:	0f be 03             	movsbl (%ebx),%eax
  80143a:	85 c0                	test   %eax,%eax
  80143c:	74 03                	je     801441 <vprintfmt+0x220>
  80143e:	43                   	inc    %ebx
  80143f:	eb 1b                	jmp    80145c <vprintfmt+0x23b>
  801441:	8b 75 dc             	mov    -0x24(%ebp),%esi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  801444:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  801448:	7f 1e                	jg     801468 <vprintfmt+0x247>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80144a:	8b 75 d8             	mov    -0x28(%ebp),%esi
  80144d:	e9 f3 fd ff ff       	jmp    801245 <vprintfmt+0x24>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  801452:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  801455:	43                   	inc    %ebx
  801456:	89 75 dc             	mov    %esi,-0x24(%ebp)
  801459:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  80145c:	85 f6                	test   %esi,%esi
  80145e:	78 ad                	js     80140d <vprintfmt+0x1ec>
  801460:	4e                   	dec    %esi
  801461:	79 aa                	jns    80140d <vprintfmt+0x1ec>
  801463:	8b 75 dc             	mov    -0x24(%ebp),%esi
  801466:	eb dc                	jmp    801444 <vprintfmt+0x223>
  801468:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80146b:	83 ec 08             	sub    $0x8,%esp
  80146e:	57                   	push   %edi
  80146f:	6a 20                	push   $0x20
  801471:	ff 55 08             	call   *0x8(%ebp)
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  801474:	4b                   	dec    %ebx
  801475:	83 c4 10             	add    $0x10,%esp
  801478:	85 db                	test   %ebx,%ebx
  80147a:	7f ef                	jg     80146b <vprintfmt+0x24a>
  80147c:	e9 c4 fd ff ff       	jmp    801245 <vprintfmt+0x24>
  801481:	89 5d d8             	mov    %ebx,-0x28(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  801484:	89 ca                	mov    %ecx,%edx
  801486:	8d 45 14             	lea    0x14(%ebp),%eax
  801489:	e8 2a fd ff ff       	call   8011b8 <getint>
  80148e:	89 c3                	mov    %eax,%ebx
  801490:	89 d6                	mov    %edx,%esi
			if ((long long) num < 0) {
  801492:	85 d2                	test   %edx,%edx
  801494:	78 0a                	js     8014a0 <vprintfmt+0x27f>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  801496:	b8 0a 00 00 00       	mov    $0xa,%eax
  80149b:	e9 b0 00 00 00       	jmp    801550 <vprintfmt+0x32f>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  8014a0:	83 ec 08             	sub    $0x8,%esp
  8014a3:	57                   	push   %edi
  8014a4:	6a 2d                	push   $0x2d
  8014a6:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  8014a9:	f7 db                	neg    %ebx
  8014ab:	83 d6 00             	adc    $0x0,%esi
  8014ae:	f7 de                	neg    %esi
  8014b0:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  8014b3:	b8 0a 00 00 00       	mov    $0xa,%eax
  8014b8:	e9 93 00 00 00       	jmp    801550 <vprintfmt+0x32f>
  8014bd:	89 5d d8             	mov    %ebx,-0x28(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8014c0:	89 ca                	mov    %ecx,%edx
  8014c2:	8d 45 14             	lea    0x14(%ebp),%eax
  8014c5:	e8 b4 fc ff ff       	call   80117e <getuint>
  8014ca:	89 c3                	mov    %eax,%ebx
  8014cc:	89 d6                	mov    %edx,%esi
			base = 10;
  8014ce:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  8014d3:	eb 7b                	jmp    801550 <vprintfmt+0x32f>
  8014d5:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// (unsigned) octal
		case 'o':
            // (MIT 6.828, lab1, Ex.8)  my code : 
            num = getint(&ap, lflag);
  8014d8:	89 ca                	mov    %ecx,%edx
  8014da:	8d 45 14             	lea    0x14(%ebp),%eax
  8014dd:	e8 d6 fc ff ff       	call   8011b8 <getint>
  8014e2:	89 c3                	mov    %eax,%ebx
  8014e4:	89 d6                	mov    %edx,%esi
            if ((long long) num < 0) {
  8014e6:	85 d2                	test   %edx,%edx
  8014e8:	78 07                	js     8014f1 <vprintfmt+0x2d0>
                putch('-', putdat);
                num = -(long long) num;
            }
            base = 8;
  8014ea:	b8 08 00 00 00       	mov    $0x8,%eax
  8014ef:	eb 5f                	jmp    801550 <vprintfmt+0x32f>
		// (unsigned) octal
		case 'o':
            // (MIT 6.828, lab1, Ex.8)  my code : 
            num = getint(&ap, lflag);
            if ((long long) num < 0) {
                putch('-', putdat);
  8014f1:	83 ec 08             	sub    $0x8,%esp
  8014f4:	57                   	push   %edi
  8014f5:	6a 2d                	push   $0x2d
  8014f7:	ff 55 08             	call   *0x8(%ebp)
                num = -(long long) num;
  8014fa:	f7 db                	neg    %ebx
  8014fc:	83 d6 00             	adc    $0x0,%esi
  8014ff:	f7 de                	neg    %esi
  801501:	83 c4 10             	add    $0x10,%esp
            }
            base = 8;
  801504:	b8 08 00 00 00       	mov    $0x8,%eax
  801509:	eb 45                	jmp    801550 <vprintfmt+0x32f>
  80150b:	89 5d d8             	mov    %ebx,-0x28(%ebp)
            goto number;

        // pointer
		case 'p':
			putch('0', putdat);
  80150e:	83 ec 08             	sub    $0x8,%esp
  801511:	57                   	push   %edi
  801512:	6a 30                	push   $0x30
  801514:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  801517:	83 c4 08             	add    $0x8,%esp
  80151a:	57                   	push   %edi
  80151b:	6a 78                	push   $0x78
  80151d:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  801520:	8b 45 14             	mov    0x14(%ebp),%eax
  801523:	8d 50 04             	lea    0x4(%eax),%edx
  801526:	89 55 14             	mov    %edx,0x14(%ebp)

        // pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  801529:	8b 18                	mov    (%eax),%ebx
  80152b:	be 00 00 00 00       	mov    $0x0,%esi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  801530:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  801533:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  801538:	eb 16                	jmp    801550 <vprintfmt+0x32f>
  80153a:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  80153d:	89 ca                	mov    %ecx,%edx
  80153f:	8d 45 14             	lea    0x14(%ebp),%eax
  801542:	e8 37 fc ff ff       	call   80117e <getuint>
  801547:	89 c3                	mov    %eax,%ebx
  801549:	89 d6                	mov    %edx,%esi
			base = 16;
  80154b:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  801550:	83 ec 0c             	sub    $0xc,%esp
  801553:	0f be 55 dc          	movsbl -0x24(%ebp),%edx
  801557:	52                   	push   %edx
  801558:	ff 75 e4             	pushl  -0x1c(%ebp)
  80155b:	50                   	push   %eax
  80155c:	56                   	push   %esi
  80155d:	53                   	push   %ebx
  80155e:	89 fa                	mov    %edi,%edx
  801560:	8b 45 08             	mov    0x8(%ebp),%eax
  801563:	e8 68 fb ff ff       	call   8010d0 <printnum>
			break;
  801568:	83 c4 20             	add    $0x20,%esp
  80156b:	8b 75 d8             	mov    -0x28(%ebp),%esi
  80156e:	e9 d2 fc ff ff       	jmp    801245 <vprintfmt+0x24>
  801573:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  801576:	83 ec 08             	sub    $0x8,%esp
  801579:	57                   	push   %edi
  80157a:	52                   	push   %edx
  80157b:	ff 55 08             	call   *0x8(%ebp)
			break;
  80157e:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801581:	8b 75 d8             	mov    -0x28(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  801584:	e9 bc fc ff ff       	jmp    801245 <vprintfmt+0x24>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  801589:	83 ec 08             	sub    $0x8,%esp
  80158c:	57                   	push   %edi
  80158d:	6a 25                	push   $0x25
  80158f:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  801592:	83 c4 10             	add    $0x10,%esp
  801595:	eb 02                	jmp    801599 <vprintfmt+0x378>
  801597:	89 c6                	mov    %eax,%esi
  801599:	8d 46 ff             	lea    -0x1(%esi),%eax
  80159c:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  8015a0:	75 f5                	jne    801597 <vprintfmt+0x376>
  8015a2:	e9 9e fc ff ff       	jmp    801245 <vprintfmt+0x24>
				/* do nothing */;
			break;
		}
	}
}
  8015a7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8015aa:	5b                   	pop    %ebx
  8015ab:	5e                   	pop    %esi
  8015ac:	5f                   	pop    %edi
  8015ad:	c9                   	leave  
  8015ae:	c3                   	ret    

008015af <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8015af:	55                   	push   %ebp
  8015b0:	89 e5                	mov    %esp,%ebp
  8015b2:	83 ec 18             	sub    $0x18,%esp
  8015b5:	8b 45 08             	mov    0x8(%ebp),%eax
  8015b8:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8015bb:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8015be:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8015c2:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8015c5:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8015cc:	85 c0                	test   %eax,%eax
  8015ce:	74 26                	je     8015f6 <vsnprintf+0x47>
  8015d0:	85 d2                	test   %edx,%edx
  8015d2:	7e 29                	jle    8015fd <vsnprintf+0x4e>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8015d4:	ff 75 14             	pushl  0x14(%ebp)
  8015d7:	ff 75 10             	pushl  0x10(%ebp)
  8015da:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8015dd:	50                   	push   %eax
  8015de:	68 ea 11 80 00       	push   $0x8011ea
  8015e3:	e8 39 fc ff ff       	call   801221 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8015e8:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8015eb:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8015ee:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8015f1:	83 c4 10             	add    $0x10,%esp
  8015f4:	eb 0c                	jmp    801602 <vsnprintf+0x53>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8015f6:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8015fb:	eb 05                	jmp    801602 <vsnprintf+0x53>
  8015fd:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  801602:	c9                   	leave  
  801603:	c3                   	ret    

00801604 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  801604:	55                   	push   %ebp
  801605:	89 e5                	mov    %esp,%ebp
  801607:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80160a:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80160d:	50                   	push   %eax
  80160e:	ff 75 10             	pushl  0x10(%ebp)
  801611:	ff 75 0c             	pushl  0xc(%ebp)
  801614:	ff 75 08             	pushl  0x8(%ebp)
  801617:	e8 93 ff ff ff       	call   8015af <vsnprintf>
	va_end(ap);

	return rc;
}
  80161c:	c9                   	leave  
  80161d:	c3                   	ret    
	...

00801620 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  801620:	55                   	push   %ebp
  801621:	89 e5                	mov    %esp,%ebp
  801623:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  801626:	80 3a 00             	cmpb   $0x0,(%edx)
  801629:	74 0e                	je     801639 <strlen+0x19>
  80162b:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  801630:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  801631:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  801635:	75 f9                	jne    801630 <strlen+0x10>
  801637:	eb 05                	jmp    80163e <strlen+0x1e>
  801639:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  80163e:	c9                   	leave  
  80163f:	c3                   	ret    

00801640 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  801640:	55                   	push   %ebp
  801641:	89 e5                	mov    %esp,%ebp
  801643:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801646:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801649:	85 d2                	test   %edx,%edx
  80164b:	74 17                	je     801664 <strnlen+0x24>
  80164d:	80 39 00             	cmpb   $0x0,(%ecx)
  801650:	74 19                	je     80166b <strnlen+0x2b>
  801652:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  801657:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801658:	39 d0                	cmp    %edx,%eax
  80165a:	74 14                	je     801670 <strnlen+0x30>
  80165c:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  801660:	75 f5                	jne    801657 <strnlen+0x17>
  801662:	eb 0c                	jmp    801670 <strnlen+0x30>
  801664:	b8 00 00 00 00       	mov    $0x0,%eax
  801669:	eb 05                	jmp    801670 <strnlen+0x30>
  80166b:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  801670:	c9                   	leave  
  801671:	c3                   	ret    

00801672 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  801672:	55                   	push   %ebp
  801673:	89 e5                	mov    %esp,%ebp
  801675:	53                   	push   %ebx
  801676:	8b 45 08             	mov    0x8(%ebp),%eax
  801679:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  80167c:	ba 00 00 00 00       	mov    $0x0,%edx
  801681:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  801684:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  801687:	42                   	inc    %edx
  801688:	84 c9                	test   %cl,%cl
  80168a:	75 f5                	jne    801681 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  80168c:	5b                   	pop    %ebx
  80168d:	c9                   	leave  
  80168e:	c3                   	ret    

0080168f <strcat>:

char *
strcat(char *dst, const char *src)
{
  80168f:	55                   	push   %ebp
  801690:	89 e5                	mov    %esp,%ebp
  801692:	53                   	push   %ebx
  801693:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  801696:	53                   	push   %ebx
  801697:	e8 84 ff ff ff       	call   801620 <strlen>
  80169c:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  80169f:	ff 75 0c             	pushl  0xc(%ebp)
  8016a2:	8d 04 03             	lea    (%ebx,%eax,1),%eax
  8016a5:	50                   	push   %eax
  8016a6:	e8 c7 ff ff ff       	call   801672 <strcpy>
	return dst;
}
  8016ab:	89 d8                	mov    %ebx,%eax
  8016ad:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016b0:	c9                   	leave  
  8016b1:	c3                   	ret    

008016b2 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8016b2:	55                   	push   %ebp
  8016b3:	89 e5                	mov    %esp,%ebp
  8016b5:	56                   	push   %esi
  8016b6:	53                   	push   %ebx
  8016b7:	8b 45 08             	mov    0x8(%ebp),%eax
  8016ba:	8b 55 0c             	mov    0xc(%ebp),%edx
  8016bd:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8016c0:	85 f6                	test   %esi,%esi
  8016c2:	74 15                	je     8016d9 <strncpy+0x27>
  8016c4:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
  8016c9:	8a 1a                	mov    (%edx),%bl
  8016cb:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8016ce:	80 3a 01             	cmpb   $0x1,(%edx)
  8016d1:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8016d4:	41                   	inc    %ecx
  8016d5:	39 ce                	cmp    %ecx,%esi
  8016d7:	77 f0                	ja     8016c9 <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8016d9:	5b                   	pop    %ebx
  8016da:	5e                   	pop    %esi
  8016db:	c9                   	leave  
  8016dc:	c3                   	ret    

008016dd <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8016dd:	55                   	push   %ebp
  8016de:	89 e5                	mov    %esp,%ebp
  8016e0:	57                   	push   %edi
  8016e1:	56                   	push   %esi
  8016e2:	53                   	push   %ebx
  8016e3:	8b 7d 08             	mov    0x8(%ebp),%edi
  8016e6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8016e9:	8b 75 10             	mov    0x10(%ebp),%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8016ec:	85 f6                	test   %esi,%esi
  8016ee:	74 32                	je     801722 <strlcpy+0x45>
		while (--size > 0 && *src != '\0')
  8016f0:	83 fe 01             	cmp    $0x1,%esi
  8016f3:	74 22                	je     801717 <strlcpy+0x3a>
  8016f5:	8a 0b                	mov    (%ebx),%cl
  8016f7:	84 c9                	test   %cl,%cl
  8016f9:	74 20                	je     80171b <strlcpy+0x3e>
  8016fb:	89 f8                	mov    %edi,%eax
  8016fd:	ba 00 00 00 00       	mov    $0x0,%edx
	}
	return ret;
}

size_t
strlcpy(char *dst, const char *src, size_t size)
  801702:	83 ee 02             	sub    $0x2,%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  801705:	88 08                	mov    %cl,(%eax)
  801707:	40                   	inc    %eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  801708:	39 f2                	cmp    %esi,%edx
  80170a:	74 11                	je     80171d <strlcpy+0x40>
  80170c:	8a 4c 13 01          	mov    0x1(%ebx,%edx,1),%cl
  801710:	42                   	inc    %edx
  801711:	84 c9                	test   %cl,%cl
  801713:	75 f0                	jne    801705 <strlcpy+0x28>
  801715:	eb 06                	jmp    80171d <strlcpy+0x40>
  801717:	89 f8                	mov    %edi,%eax
  801719:	eb 02                	jmp    80171d <strlcpy+0x40>
  80171b:	89 f8                	mov    %edi,%eax
			*dst++ = *src++;
		*dst = '\0';
  80171d:	c6 00 00             	movb   $0x0,(%eax)
  801720:	eb 02                	jmp    801724 <strlcpy+0x47>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  801722:	89 f8                	mov    %edi,%eax
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
		*dst = '\0';
	}
	return dst - dst_in;
  801724:	29 f8                	sub    %edi,%eax
}
  801726:	5b                   	pop    %ebx
  801727:	5e                   	pop    %esi
  801728:	5f                   	pop    %edi
  801729:	c9                   	leave  
  80172a:	c3                   	ret    

0080172b <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80172b:	55                   	push   %ebp
  80172c:	89 e5                	mov    %esp,%ebp
  80172e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801731:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  801734:	8a 01                	mov    (%ecx),%al
  801736:	84 c0                	test   %al,%al
  801738:	74 10                	je     80174a <strcmp+0x1f>
  80173a:	3a 02                	cmp    (%edx),%al
  80173c:	75 0c                	jne    80174a <strcmp+0x1f>
		p++, q++;
  80173e:	41                   	inc    %ecx
  80173f:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  801740:	8a 01                	mov    (%ecx),%al
  801742:	84 c0                	test   %al,%al
  801744:	74 04                	je     80174a <strcmp+0x1f>
  801746:	3a 02                	cmp    (%edx),%al
  801748:	74 f4                	je     80173e <strcmp+0x13>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  80174a:	0f b6 c0             	movzbl %al,%eax
  80174d:	0f b6 12             	movzbl (%edx),%edx
  801750:	29 d0                	sub    %edx,%eax
}
  801752:	c9                   	leave  
  801753:	c3                   	ret    

00801754 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  801754:	55                   	push   %ebp
  801755:	89 e5                	mov    %esp,%ebp
  801757:	53                   	push   %ebx
  801758:	8b 55 08             	mov    0x8(%ebp),%edx
  80175b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80175e:	8b 45 10             	mov    0x10(%ebp),%eax
	while (n > 0 && *p && *p == *q)
  801761:	85 c0                	test   %eax,%eax
  801763:	74 1b                	je     801780 <strncmp+0x2c>
  801765:	8a 1a                	mov    (%edx),%bl
  801767:	84 db                	test   %bl,%bl
  801769:	74 24                	je     80178f <strncmp+0x3b>
  80176b:	3a 19                	cmp    (%ecx),%bl
  80176d:	75 20                	jne    80178f <strncmp+0x3b>
  80176f:	48                   	dec    %eax
  801770:	74 15                	je     801787 <strncmp+0x33>
		n--, p++, q++;
  801772:	42                   	inc    %edx
  801773:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  801774:	8a 1a                	mov    (%edx),%bl
  801776:	84 db                	test   %bl,%bl
  801778:	74 15                	je     80178f <strncmp+0x3b>
  80177a:	3a 19                	cmp    (%ecx),%bl
  80177c:	74 f1                	je     80176f <strncmp+0x1b>
  80177e:	eb 0f                	jmp    80178f <strncmp+0x3b>
		n--, p++, q++;
	if (n == 0)
		return 0;
  801780:	b8 00 00 00 00       	mov    $0x0,%eax
  801785:	eb 05                	jmp    80178c <strncmp+0x38>
  801787:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  80178c:	5b                   	pop    %ebx
  80178d:	c9                   	leave  
  80178e:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80178f:	0f b6 02             	movzbl (%edx),%eax
  801792:	0f b6 11             	movzbl (%ecx),%edx
  801795:	29 d0                	sub    %edx,%eax
  801797:	eb f3                	jmp    80178c <strncmp+0x38>

00801799 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  801799:	55                   	push   %ebp
  80179a:	89 e5                	mov    %esp,%ebp
  80179c:	8b 45 08             	mov    0x8(%ebp),%eax
  80179f:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  8017a2:	8a 10                	mov    (%eax),%dl
  8017a4:	84 d2                	test   %dl,%dl
  8017a6:	74 18                	je     8017c0 <strchr+0x27>
		if (*s == c)
  8017a8:	38 ca                	cmp    %cl,%dl
  8017aa:	75 06                	jne    8017b2 <strchr+0x19>
  8017ac:	eb 17                	jmp    8017c5 <strchr+0x2c>
  8017ae:	38 ca                	cmp    %cl,%dl
  8017b0:	74 13                	je     8017c5 <strchr+0x2c>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8017b2:	40                   	inc    %eax
  8017b3:	8a 10                	mov    (%eax),%dl
  8017b5:	84 d2                	test   %dl,%dl
  8017b7:	75 f5                	jne    8017ae <strchr+0x15>
		if (*s == c)
			return (char *) s;
	return 0;
  8017b9:	b8 00 00 00 00       	mov    $0x0,%eax
  8017be:	eb 05                	jmp    8017c5 <strchr+0x2c>
  8017c0:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8017c5:	c9                   	leave  
  8017c6:	c3                   	ret    

008017c7 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8017c7:	55                   	push   %ebp
  8017c8:	89 e5                	mov    %esp,%ebp
  8017ca:	8b 45 08             	mov    0x8(%ebp),%eax
  8017cd:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  8017d0:	8a 10                	mov    (%eax),%dl
  8017d2:	84 d2                	test   %dl,%dl
  8017d4:	74 11                	je     8017e7 <strfind+0x20>
		if (*s == c)
  8017d6:	38 ca                	cmp    %cl,%dl
  8017d8:	75 06                	jne    8017e0 <strfind+0x19>
  8017da:	eb 0b                	jmp    8017e7 <strfind+0x20>
  8017dc:	38 ca                	cmp    %cl,%dl
  8017de:	74 07                	je     8017e7 <strfind+0x20>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  8017e0:	40                   	inc    %eax
  8017e1:	8a 10                	mov    (%eax),%dl
  8017e3:	84 d2                	test   %dl,%dl
  8017e5:	75 f5                	jne    8017dc <strfind+0x15>
		if (*s == c)
			break;
	return (char *) s;
}
  8017e7:	c9                   	leave  
  8017e8:	c3                   	ret    

008017e9 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8017e9:	55                   	push   %ebp
  8017ea:	89 e5                	mov    %esp,%ebp
  8017ec:	57                   	push   %edi
  8017ed:	56                   	push   %esi
  8017ee:	53                   	push   %ebx
  8017ef:	8b 7d 08             	mov    0x8(%ebp),%edi
  8017f2:	8b 45 0c             	mov    0xc(%ebp),%eax
  8017f5:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8017f8:	85 c9                	test   %ecx,%ecx
  8017fa:	74 30                	je     80182c <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8017fc:	f7 c7 03 00 00 00    	test   $0x3,%edi
  801802:	75 25                	jne    801829 <memset+0x40>
  801804:	f6 c1 03             	test   $0x3,%cl
  801807:	75 20                	jne    801829 <memset+0x40>
		c &= 0xFF;
  801809:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  80180c:	89 d3                	mov    %edx,%ebx
  80180e:	c1 e3 08             	shl    $0x8,%ebx
  801811:	89 d6                	mov    %edx,%esi
  801813:	c1 e6 18             	shl    $0x18,%esi
  801816:	89 d0                	mov    %edx,%eax
  801818:	c1 e0 10             	shl    $0x10,%eax
  80181b:	09 f0                	or     %esi,%eax
  80181d:	09 d0                	or     %edx,%eax
  80181f:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  801821:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  801824:	fc                   	cld    
  801825:	f3 ab                	rep stos %eax,%es:(%edi)
  801827:	eb 03                	jmp    80182c <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  801829:	fc                   	cld    
  80182a:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  80182c:	89 f8                	mov    %edi,%eax
  80182e:	5b                   	pop    %ebx
  80182f:	5e                   	pop    %esi
  801830:	5f                   	pop    %edi
  801831:	c9                   	leave  
  801832:	c3                   	ret    

00801833 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  801833:	55                   	push   %ebp
  801834:	89 e5                	mov    %esp,%ebp
  801836:	57                   	push   %edi
  801837:	56                   	push   %esi
  801838:	8b 45 08             	mov    0x8(%ebp),%eax
  80183b:	8b 75 0c             	mov    0xc(%ebp),%esi
  80183e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  801841:	39 c6                	cmp    %eax,%esi
  801843:	73 34                	jae    801879 <memmove+0x46>
  801845:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  801848:	39 d0                	cmp    %edx,%eax
  80184a:	73 2d                	jae    801879 <memmove+0x46>
		s += n;
		d += n;
  80184c:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80184f:	f6 c2 03             	test   $0x3,%dl
  801852:	75 1b                	jne    80186f <memmove+0x3c>
  801854:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80185a:	75 13                	jne    80186f <memmove+0x3c>
  80185c:	f6 c1 03             	test   $0x3,%cl
  80185f:	75 0e                	jne    80186f <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  801861:	83 ef 04             	sub    $0x4,%edi
  801864:	8d 72 fc             	lea    -0x4(%edx),%esi
  801867:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  80186a:	fd                   	std    
  80186b:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80186d:	eb 07                	jmp    801876 <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  80186f:	4f                   	dec    %edi
  801870:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  801873:	fd                   	std    
  801874:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  801876:	fc                   	cld    
  801877:	eb 20                	jmp    801899 <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801879:	f7 c6 03 00 00 00    	test   $0x3,%esi
  80187f:	75 13                	jne    801894 <memmove+0x61>
  801881:	a8 03                	test   $0x3,%al
  801883:	75 0f                	jne    801894 <memmove+0x61>
  801885:	f6 c1 03             	test   $0x3,%cl
  801888:	75 0a                	jne    801894 <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  80188a:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  80188d:	89 c7                	mov    %eax,%edi
  80188f:	fc                   	cld    
  801890:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801892:	eb 05                	jmp    801899 <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  801894:	89 c7                	mov    %eax,%edi
  801896:	fc                   	cld    
  801897:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  801899:	5e                   	pop    %esi
  80189a:	5f                   	pop    %edi
  80189b:	c9                   	leave  
  80189c:	c3                   	ret    

0080189d <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  80189d:	55                   	push   %ebp
  80189e:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  8018a0:	ff 75 10             	pushl  0x10(%ebp)
  8018a3:	ff 75 0c             	pushl  0xc(%ebp)
  8018a6:	ff 75 08             	pushl  0x8(%ebp)
  8018a9:	e8 85 ff ff ff       	call   801833 <memmove>
}
  8018ae:	c9                   	leave  
  8018af:	c3                   	ret    

008018b0 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8018b0:	55                   	push   %ebp
  8018b1:	89 e5                	mov    %esp,%ebp
  8018b3:	57                   	push   %edi
  8018b4:	56                   	push   %esi
  8018b5:	53                   	push   %ebx
  8018b6:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8018b9:	8b 75 0c             	mov    0xc(%ebp),%esi
  8018bc:	8b 7d 10             	mov    0x10(%ebp),%edi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8018bf:	85 ff                	test   %edi,%edi
  8018c1:	74 32                	je     8018f5 <memcmp+0x45>
		if (*s1 != *s2)
  8018c3:	8a 03                	mov    (%ebx),%al
  8018c5:	8a 0e                	mov    (%esi),%cl
  8018c7:	38 c8                	cmp    %cl,%al
  8018c9:	74 19                	je     8018e4 <memcmp+0x34>
  8018cb:	eb 0d                	jmp    8018da <memcmp+0x2a>
  8018cd:	8a 44 13 01          	mov    0x1(%ebx,%edx,1),%al
  8018d1:	8a 4c 16 01          	mov    0x1(%esi,%edx,1),%cl
  8018d5:	42                   	inc    %edx
  8018d6:	38 c8                	cmp    %cl,%al
  8018d8:	74 10                	je     8018ea <memcmp+0x3a>
			return (int) *s1 - (int) *s2;
  8018da:	0f b6 c0             	movzbl %al,%eax
  8018dd:	0f b6 c9             	movzbl %cl,%ecx
  8018e0:	29 c8                	sub    %ecx,%eax
  8018e2:	eb 16                	jmp    8018fa <memcmp+0x4a>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8018e4:	4f                   	dec    %edi
  8018e5:	ba 00 00 00 00       	mov    $0x0,%edx
  8018ea:	39 fa                	cmp    %edi,%edx
  8018ec:	75 df                	jne    8018cd <memcmp+0x1d>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  8018ee:	b8 00 00 00 00       	mov    $0x0,%eax
  8018f3:	eb 05                	jmp    8018fa <memcmp+0x4a>
  8018f5:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8018fa:	5b                   	pop    %ebx
  8018fb:	5e                   	pop    %esi
  8018fc:	5f                   	pop    %edi
  8018fd:	c9                   	leave  
  8018fe:	c3                   	ret    

008018ff <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8018ff:	55                   	push   %ebp
  801900:	89 e5                	mov    %esp,%ebp
  801902:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  801905:	89 c2                	mov    %eax,%edx
  801907:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  80190a:	39 d0                	cmp    %edx,%eax
  80190c:	73 12                	jae    801920 <memfind+0x21>
		if (*(const unsigned char *) s == (unsigned char) c)
  80190e:	8a 4d 0c             	mov    0xc(%ebp),%cl
  801911:	38 08                	cmp    %cl,(%eax)
  801913:	75 06                	jne    80191b <memfind+0x1c>
  801915:	eb 09                	jmp    801920 <memfind+0x21>
  801917:	38 08                	cmp    %cl,(%eax)
  801919:	74 05                	je     801920 <memfind+0x21>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  80191b:	40                   	inc    %eax
  80191c:	39 c2                	cmp    %eax,%edx
  80191e:	77 f7                	ja     801917 <memfind+0x18>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  801920:	c9                   	leave  
  801921:	c3                   	ret    

00801922 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  801922:	55                   	push   %ebp
  801923:	89 e5                	mov    %esp,%ebp
  801925:	57                   	push   %edi
  801926:	56                   	push   %esi
  801927:	53                   	push   %ebx
  801928:	8b 55 08             	mov    0x8(%ebp),%edx
  80192b:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  80192e:	eb 01                	jmp    801931 <strtol+0xf>
		s++;
  801930:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801931:	8a 02                	mov    (%edx),%al
  801933:	3c 20                	cmp    $0x20,%al
  801935:	74 f9                	je     801930 <strtol+0xe>
  801937:	3c 09                	cmp    $0x9,%al
  801939:	74 f5                	je     801930 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  80193b:	3c 2b                	cmp    $0x2b,%al
  80193d:	75 08                	jne    801947 <strtol+0x25>
		s++;
  80193f:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  801940:	bf 00 00 00 00       	mov    $0x0,%edi
  801945:	eb 13                	jmp    80195a <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  801947:	3c 2d                	cmp    $0x2d,%al
  801949:	75 0a                	jne    801955 <strtol+0x33>
		s++, neg = 1;
  80194b:	8d 52 01             	lea    0x1(%edx),%edx
  80194e:	bf 01 00 00 00       	mov    $0x1,%edi
  801953:	eb 05                	jmp    80195a <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  801955:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  80195a:	85 db                	test   %ebx,%ebx
  80195c:	74 05                	je     801963 <strtol+0x41>
  80195e:	83 fb 10             	cmp    $0x10,%ebx
  801961:	75 28                	jne    80198b <strtol+0x69>
  801963:	8a 02                	mov    (%edx),%al
  801965:	3c 30                	cmp    $0x30,%al
  801967:	75 10                	jne    801979 <strtol+0x57>
  801969:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  80196d:	75 0a                	jne    801979 <strtol+0x57>
		s += 2, base = 16;
  80196f:	83 c2 02             	add    $0x2,%edx
  801972:	bb 10 00 00 00       	mov    $0x10,%ebx
  801977:	eb 12                	jmp    80198b <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  801979:	85 db                	test   %ebx,%ebx
  80197b:	75 0e                	jne    80198b <strtol+0x69>
  80197d:	3c 30                	cmp    $0x30,%al
  80197f:	75 05                	jne    801986 <strtol+0x64>
		s++, base = 8;
  801981:	42                   	inc    %edx
  801982:	b3 08                	mov    $0x8,%bl
  801984:	eb 05                	jmp    80198b <strtol+0x69>
	else if (base == 0)
		base = 10;
  801986:	bb 0a 00 00 00       	mov    $0xa,%ebx
  80198b:	b8 00 00 00 00       	mov    $0x0,%eax
  801990:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  801992:	8a 0a                	mov    (%edx),%cl
  801994:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  801997:	80 fb 09             	cmp    $0x9,%bl
  80199a:	77 08                	ja     8019a4 <strtol+0x82>
			dig = *s - '0';
  80199c:	0f be c9             	movsbl %cl,%ecx
  80199f:	83 e9 30             	sub    $0x30,%ecx
  8019a2:	eb 1e                	jmp    8019c2 <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  8019a4:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  8019a7:	80 fb 19             	cmp    $0x19,%bl
  8019aa:	77 08                	ja     8019b4 <strtol+0x92>
			dig = *s - 'a' + 10;
  8019ac:	0f be c9             	movsbl %cl,%ecx
  8019af:	83 e9 57             	sub    $0x57,%ecx
  8019b2:	eb 0e                	jmp    8019c2 <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  8019b4:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  8019b7:	80 fb 19             	cmp    $0x19,%bl
  8019ba:	77 13                	ja     8019cf <strtol+0xad>
			dig = *s - 'A' + 10;
  8019bc:	0f be c9             	movsbl %cl,%ecx
  8019bf:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  8019c2:	39 f1                	cmp    %esi,%ecx
  8019c4:	7d 0d                	jge    8019d3 <strtol+0xb1>
			break;
		s++, val = (val * base) + dig;
  8019c6:	42                   	inc    %edx
  8019c7:	0f af c6             	imul   %esi,%eax
  8019ca:	8d 04 01             	lea    (%ecx,%eax,1),%eax
		// we don't properly detect overflow!
	}
  8019cd:	eb c3                	jmp    801992 <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  8019cf:	89 c1                	mov    %eax,%ecx
  8019d1:	eb 02                	jmp    8019d5 <strtol+0xb3>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  8019d3:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  8019d5:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8019d9:	74 05                	je     8019e0 <strtol+0xbe>
		*endptr = (char *) s;
  8019db:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8019de:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  8019e0:	85 ff                	test   %edi,%edi
  8019e2:	74 04                	je     8019e8 <strtol+0xc6>
  8019e4:	89 c8                	mov    %ecx,%eax
  8019e6:	f7 d8                	neg    %eax
}
  8019e8:	5b                   	pop    %ebx
  8019e9:	5e                   	pop    %esi
  8019ea:	5f                   	pop    %edi
  8019eb:	c9                   	leave  
  8019ec:	c3                   	ret    
  8019ed:	00 00                	add    %al,(%eax)
	...

008019f0 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  8019f0:	55                   	push   %ebp
  8019f1:	89 e5                	mov    %esp,%ebp
  8019f3:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  8019f6:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  8019fd:	75 52                	jne    801a51 <set_pgfault_handler+0x61>
		// First time through!	
		// LAB 4: Your code here.

		//int sys_page_alloc(envid_t envid, void *va, int perm)
		r = sys_page_alloc(0, (void*)(UXSTACKTOP - PGSIZE), PTE_U | PTE_W | PTE_P);
  8019ff:	83 ec 04             	sub    $0x4,%esp
  801a02:	6a 07                	push   $0x7
  801a04:	68 00 f0 bf ee       	push   $0xeebff000
  801a09:	6a 00                	push   $0x0
  801a0b:	e8 b8 e7 ff ff       	call   8001c8 <sys_page_alloc>
		if (r < 0) {
  801a10:	83 c4 10             	add    $0x10,%esp
  801a13:	85 c0                	test   %eax,%eax
  801a15:	79 12                	jns    801a29 <set_pgfault_handler+0x39>
			panic("sys_page_alloc error : %e\n", r);
  801a17:	50                   	push   %eax
  801a18:	68 5f 22 80 00       	push   $0x80225f
  801a1d:	6a 24                	push   $0x24
  801a1f:	68 7a 22 80 00       	push   $0x80227a
  801a24:	e8 bb f5 ff ff       	call   800fe4 <_panic>
		}

		// how to know envid, put 0, envid2env will help us to get curenv in syscall
		r = sys_env_set_pgfault_upcall(0, _pgfault_upcall);		
  801a29:	83 ec 08             	sub    $0x8,%esp
  801a2c:	68 08 03 80 00       	push   $0x800308
  801a31:	6a 00                	push   $0x0
  801a33:	e8 43 e8 ff ff       	call   80027b <sys_env_set_pgfault_upcall>
		if (r < 0) {
  801a38:	83 c4 10             	add    $0x10,%esp
  801a3b:	85 c0                	test   %eax,%eax
  801a3d:	79 12                	jns    801a51 <set_pgfault_handler+0x61>
			panic("sys_env_set_pgfault_upcall error : %e\n", r);
  801a3f:	50                   	push   %eax
  801a40:	68 88 22 80 00       	push   $0x802288
  801a45:	6a 2a                	push   $0x2a
  801a47:	68 7a 22 80 00       	push   $0x80227a
  801a4c:	e8 93 f5 ff ff       	call   800fe4 <_panic>
		}
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801a51:	8b 45 08             	mov    0x8(%ebp),%eax
  801a54:	a3 00 60 80 00       	mov    %eax,0x806000
}
  801a59:	c9                   	leave  
  801a5a:	c3                   	ret    
	...

00801a5c <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801a5c:	55                   	push   %ebp
  801a5d:	89 e5                	mov    %esp,%ebp
  801a5f:	56                   	push   %esi
  801a60:	53                   	push   %ebx
  801a61:	8b 75 08             	mov    0x8(%ebp),%esi
  801a64:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a67:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// cprintf("0x%x 0x%x 0x%x\n", (uint32_t)from_env_store, (uint32_t)pg, (uint32_t)perm_store);
	int r;
	if (pg != NULL) {
  801a6a:	85 c0                	test   %eax,%eax
  801a6c:	74 0e                	je     801a7c <ipc_recv+0x20>
		r = sys_ipc_recv(pg);
  801a6e:	83 ec 0c             	sub    $0xc,%esp
  801a71:	50                   	push   %eax
  801a72:	e8 4c e8 ff ff       	call   8002c3 <sys_ipc_recv>
  801a77:	83 c4 10             	add    $0x10,%esp
  801a7a:	eb 10                	jmp    801a8c <ipc_recv+0x30>
	} else {
		r = sys_ipc_recv((void *)UTOP);
  801a7c:	83 ec 0c             	sub    $0xc,%esp
  801a7f:	68 00 00 c0 ee       	push   $0xeec00000
  801a84:	e8 3a e8 ff ff       	call   8002c3 <sys_ipc_recv>
  801a89:	83 c4 10             	add    $0x10,%esp
	}

	if (r == 0) {
  801a8c:	85 c0                	test   %eax,%eax
  801a8e:	75 26                	jne    801ab6 <ipc_recv+0x5a>
		if (from_env_store != NULL) *from_env_store = thisenv->env_ipc_from;
  801a90:	85 f6                	test   %esi,%esi
  801a92:	74 0a                	je     801a9e <ipc_recv+0x42>
  801a94:	a1 04 40 80 00       	mov    0x804004,%eax
  801a99:	8b 40 74             	mov    0x74(%eax),%eax
  801a9c:	89 06                	mov    %eax,(%esi)
		if (perm_store != NULL) *perm_store = thisenv->env_ipc_perm;
  801a9e:	85 db                	test   %ebx,%ebx
  801aa0:	74 0a                	je     801aac <ipc_recv+0x50>
  801aa2:	a1 04 40 80 00       	mov    0x804004,%eax
  801aa7:	8b 40 78             	mov    0x78(%eax),%eax
  801aaa:	89 03                	mov    %eax,(%ebx)
		return thisenv->env_ipc_value;
  801aac:	a1 04 40 80 00       	mov    0x804004,%eax
  801ab1:	8b 40 70             	mov    0x70(%eax),%eax
  801ab4:	eb 14                	jmp    801aca <ipc_recv+0x6e>
	} else {
		// fails;
		if (from_env_store != NULL) *from_env_store = 0;
  801ab6:	85 f6                	test   %esi,%esi
  801ab8:	74 06                	je     801ac0 <ipc_recv+0x64>
  801aba:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		if (perm_store != NULL) *perm_store = 0;
  801ac0:	85 db                	test   %ebx,%ebx
  801ac2:	74 06                	je     801aca <ipc_recv+0x6e>
  801ac4:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
		return r;
	}
}
  801aca:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801acd:	5b                   	pop    %ebx
  801ace:	5e                   	pop    %esi
  801acf:	c9                   	leave  
  801ad0:	c3                   	ret    

00801ad1 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801ad1:	55                   	push   %ebp
  801ad2:	89 e5                	mov    %esp,%ebp
  801ad4:	57                   	push   %edi
  801ad5:	56                   	push   %esi
  801ad6:	53                   	push   %ebx
  801ad7:	83 ec 0c             	sub    $0xc,%esp
  801ada:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801add:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801ae0:	8b 75 14             	mov    0x14(%ebp),%esi
	// LAB 4: Your code here.
	// int sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
	int r;
	if (pg == NULL) pg = (void *)UTOP;
  801ae3:	85 db                	test   %ebx,%ebx
  801ae5:	75 25                	jne    801b0c <ipc_send+0x3b>
  801ae7:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
  801aec:	eb 1e                	jmp    801b0c <ipc_send+0x3b>
	
	while ((r = sys_ipc_try_send(to_env, val, pg, perm)) != 0) {
		if (r == -E_IPC_NOT_RECV) {
  801aee:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801af1:	75 07                	jne    801afa <ipc_send+0x29>
			// cprintf("Try Again and Again....\n");
			sys_yield();
  801af3:	e8 a9 e6 ff ff       	call   8001a1 <sys_yield>
  801af8:	eb 12                	jmp    801b0c <ipc_send+0x3b>
		} else {
			panic("ipc_send error %e\n", r);
  801afa:	50                   	push   %eax
  801afb:	68 b0 22 80 00       	push   $0x8022b0
  801b00:	6a 43                	push   $0x43
  801b02:	68 c3 22 80 00       	push   $0x8022c3
  801b07:	e8 d8 f4 ff ff       	call   800fe4 <_panic>
	// LAB 4: Your code here.
	// int sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
	int r;
	if (pg == NULL) pg = (void *)UTOP;
	
	while ((r = sys_ipc_try_send(to_env, val, pg, perm)) != 0) {
  801b0c:	56                   	push   %esi
  801b0d:	53                   	push   %ebx
  801b0e:	57                   	push   %edi
  801b0f:	ff 75 08             	pushl  0x8(%ebp)
  801b12:	e8 87 e7 ff ff       	call   80029e <sys_ipc_try_send>
  801b17:	83 c4 10             	add    $0x10,%esp
  801b1a:	85 c0                	test   %eax,%eax
  801b1c:	75 d0                	jne    801aee <ipc_send+0x1d>
		} else {
			panic("ipc_send error %e\n", r);
		}
	}
	return;
}
  801b1e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b21:	5b                   	pop    %ebx
  801b22:	5e                   	pop    %esi
  801b23:	5f                   	pop    %edi
  801b24:	c9                   	leave  
  801b25:	c3                   	ret    

00801b26 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801b26:	55                   	push   %ebp
  801b27:	89 e5                	mov    %esp,%ebp
  801b29:	53                   	push   %ebx
  801b2a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	for (i = 0; i < NENV; i++)
		if (envs[i].env_type == type)
  801b2d:	39 1d 50 00 c0 ee    	cmp    %ebx,0xeec00050
  801b33:	74 22                	je     801b57 <ipc_find_env+0x31>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801b35:	b8 01 00 00 00       	mov    $0x1,%eax
		if (envs[i].env_type == type)
  801b3a:	8d 0c 85 00 00 00 00 	lea    0x0(,%eax,4),%ecx
  801b41:	89 c2                	mov    %eax,%edx
  801b43:	c1 e2 07             	shl    $0x7,%edx
  801b46:	29 ca                	sub    %ecx,%edx
  801b48:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801b4e:	8b 52 50             	mov    0x50(%edx),%edx
  801b51:	39 da                	cmp    %ebx,%edx
  801b53:	75 1d                	jne    801b72 <ipc_find_env+0x4c>
  801b55:	eb 05                	jmp    801b5c <ipc_find_env+0x36>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801b57:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
			return envs[i].env_id;
  801b5c:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  801b63:	c1 e0 07             	shl    $0x7,%eax
  801b66:	29 d0                	sub    %edx,%eax
  801b68:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  801b6d:	8b 40 40             	mov    0x40(%eax),%eax
  801b70:	eb 0c                	jmp    801b7e <ipc_find_env+0x58>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801b72:	40                   	inc    %eax
  801b73:	3d 00 04 00 00       	cmp    $0x400,%eax
  801b78:	75 c0                	jne    801b3a <ipc_find_env+0x14>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801b7a:	66 b8 00 00          	mov    $0x0,%ax
}
  801b7e:	5b                   	pop    %ebx
  801b7f:	c9                   	leave  
  801b80:	c3                   	ret    
  801b81:	00 00                	add    %al,(%eax)
	...

00801b84 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801b84:	55                   	push   %ebp
  801b85:	89 e5                	mov    %esp,%ebp
  801b87:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801b8a:	89 c2                	mov    %eax,%edx
  801b8c:	c1 ea 16             	shr    $0x16,%edx
  801b8f:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801b96:	f6 c2 01             	test   $0x1,%dl
  801b99:	74 1e                	je     801bb9 <pageref+0x35>
		return 0;
	pte = uvpt[PGNUM(v)];
  801b9b:	c1 e8 0c             	shr    $0xc,%eax
  801b9e:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  801ba5:	a8 01                	test   $0x1,%al
  801ba7:	74 17                	je     801bc0 <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801ba9:	c1 e8 0c             	shr    $0xc,%eax
  801bac:	66 8b 04 c5 04 00 00 	mov    -0x10fffffc(,%eax,8),%ax
  801bb3:	ef 
  801bb4:	0f b7 c0             	movzwl %ax,%eax
  801bb7:	eb 0c                	jmp    801bc5 <pageref+0x41>
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
		return 0;
  801bb9:	b8 00 00 00 00       	mov    $0x0,%eax
  801bbe:	eb 05                	jmp    801bc5 <pageref+0x41>
	pte = uvpt[PGNUM(v)];
	if (!(pte & PTE_P))
		return 0;
  801bc0:	b8 00 00 00 00       	mov    $0x0,%eax
	return pages[PGNUM(pte)].pp_ref;
}
  801bc5:	c9                   	leave  
  801bc6:	c3                   	ret    
	...

00801bc8 <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  801bc8:	55                   	push   %ebp
  801bc9:	89 e5                	mov    %esp,%ebp
  801bcb:	57                   	push   %edi
  801bcc:	56                   	push   %esi
  801bcd:	83 ec 10             	sub    $0x10,%esp
  801bd0:	8b 7d 08             	mov    0x8(%ebp),%edi
  801bd3:	8b 4d 10             	mov    0x10(%ebp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  801bd6:	89 7d f0             	mov    %edi,-0x10(%ebp)
  801bd9:	8b 75 0c             	mov    0xc(%ebp),%esi
  const DWunion dd = {.ll = d};
  801bdc:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  801bdf:	8b 45 14             	mov    0x14(%ebp),%eax
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  801be2:	85 c0                	test   %eax,%eax
  801be4:	75 2e                	jne    801c14 <__udivdi3+0x4c>
    {
      if (d0 > n1)
  801be6:	39 f1                	cmp    %esi,%ecx
  801be8:	77 5a                	ja     801c44 <__udivdi3+0x7c>
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  801bea:	85 c9                	test   %ecx,%ecx
  801bec:	75 0b                	jne    801bf9 <__udivdi3+0x31>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  801bee:	b8 01 00 00 00       	mov    $0x1,%eax
  801bf3:	31 d2                	xor    %edx,%edx
  801bf5:	f7 f1                	div    %ecx
  801bf7:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  801bf9:	31 d2                	xor    %edx,%edx
  801bfb:	89 f0                	mov    %esi,%eax
  801bfd:	f7 f1                	div    %ecx
  801bff:	89 c6                	mov    %eax,%esi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801c01:	89 f8                	mov    %edi,%eax
  801c03:	f7 f1                	div    %ecx
  801c05:	89 c7                	mov    %eax,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  801c07:	89 f8                	mov    %edi,%eax
  801c09:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801c0b:	83 c4 10             	add    $0x10,%esp
  801c0e:	5e                   	pop    %esi
  801c0f:	5f                   	pop    %edi
  801c10:	c9                   	leave  
  801c11:	c3                   	ret    
  801c12:	66 90                	xchg   %ax,%ax
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  801c14:	39 f0                	cmp    %esi,%eax
  801c16:	77 1c                	ja     801c34 <__udivdi3+0x6c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  801c18:	0f bd f8             	bsr    %eax,%edi
	  if (bm == 0)
  801c1b:	83 f7 1f             	xor    $0x1f,%edi
  801c1e:	75 3c                	jne    801c5c <__udivdi3+0x94>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  801c20:	39 f0                	cmp    %esi,%eax
  801c22:	0f 82 90 00 00 00    	jb     801cb8 <__udivdi3+0xf0>
  801c28:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801c2b:	39 55 f4             	cmp    %edx,-0xc(%ebp)
  801c2e:	0f 86 84 00 00 00    	jbe    801cb8 <__udivdi3+0xf0>
  801c34:	31 f6                	xor    %esi,%esi
  801c36:	31 ff                	xor    %edi,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  801c38:	89 f8                	mov    %edi,%eax
  801c3a:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801c3c:	83 c4 10             	add    $0x10,%esp
  801c3f:	5e                   	pop    %esi
  801c40:	5f                   	pop    %edi
  801c41:	c9                   	leave  
  801c42:	c3                   	ret    
  801c43:	90                   	nop
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801c44:	89 f2                	mov    %esi,%edx
  801c46:	89 f8                	mov    %edi,%eax
  801c48:	f7 f1                	div    %ecx
  801c4a:	89 c7                	mov    %eax,%edi
  801c4c:	31 f6                	xor    %esi,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  801c4e:	89 f8                	mov    %edi,%eax
  801c50:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801c52:	83 c4 10             	add    $0x10,%esp
  801c55:	5e                   	pop    %esi
  801c56:	5f                   	pop    %edi
  801c57:	c9                   	leave  
  801c58:	c3                   	ret    
  801c59:	8d 76 00             	lea    0x0(%esi),%esi
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  801c5c:	89 f9                	mov    %edi,%ecx
  801c5e:	d3 e0                	shl    %cl,%eax
  801c60:	89 45 e8             	mov    %eax,-0x18(%ebp)
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  801c63:	b8 20 00 00 00       	mov    $0x20,%eax
  801c68:	29 f8                	sub    %edi,%eax

	      d1 = (d1 << bm) | (d0 >> b);
  801c6a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801c6d:	88 c1                	mov    %al,%cl
  801c6f:	d3 ea                	shr    %cl,%edx
  801c71:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  801c74:	09 ca                	or     %ecx,%edx
  801c76:	89 55 ec             	mov    %edx,-0x14(%ebp)
	      d0 = d0 << bm;
  801c79:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801c7c:	89 f9                	mov    %edi,%ecx
  801c7e:	d3 e2                	shl    %cl,%edx
  801c80:	89 55 f4             	mov    %edx,-0xc(%ebp)
	      n2 = n1 >> b;
  801c83:	89 f2                	mov    %esi,%edx
  801c85:	88 c1                	mov    %al,%cl
  801c87:	d3 ea                	shr    %cl,%edx
  801c89:	89 55 e8             	mov    %edx,-0x18(%ebp)
	      n1 = (n1 << bm) | (n0 >> b);
  801c8c:	89 f2                	mov    %esi,%edx
  801c8e:	89 f9                	mov    %edi,%ecx
  801c90:	d3 e2                	shl    %cl,%edx
  801c92:	8b 75 f0             	mov    -0x10(%ebp),%esi
  801c95:	88 c1                	mov    %al,%cl
  801c97:	d3 ee                	shr    %cl,%esi
  801c99:	09 d6                	or     %edx,%esi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  801c9b:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  801c9e:	89 f0                	mov    %esi,%eax
  801ca0:	89 ca                	mov    %ecx,%edx
  801ca2:	f7 75 ec             	divl   -0x14(%ebp)
  801ca5:	89 d1                	mov    %edx,%ecx
  801ca7:	89 c6                	mov    %eax,%esi
	      umul_ppmm (m1, m0, q0, d0);
  801ca9:	f7 65 f4             	mull   -0xc(%ebp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801cac:	39 d1                	cmp    %edx,%ecx
  801cae:	72 28                	jb     801cd8 <__udivdi3+0x110>
  801cb0:	74 1a                	je     801ccc <__udivdi3+0x104>
  801cb2:	89 f7                	mov    %esi,%edi
  801cb4:	31 f6                	xor    %esi,%esi
  801cb6:	eb 80                	jmp    801c38 <__udivdi3+0x70>
	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  801cb8:	31 f6                	xor    %esi,%esi
  801cba:	bf 01 00 00 00       	mov    $0x1,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  801cbf:	89 f8                	mov    %edi,%eax
  801cc1:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801cc3:	83 c4 10             	add    $0x10,%esp
  801cc6:	5e                   	pop    %esi
  801cc7:	5f                   	pop    %edi
  801cc8:	c9                   	leave  
  801cc9:	c3                   	ret    
  801cca:	66 90                	xchg   %ax,%ax

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  801ccc:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801ccf:	89 f9                	mov    %edi,%ecx
  801cd1:	d3 e2                	shl    %cl,%edx

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801cd3:	39 c2                	cmp    %eax,%edx
  801cd5:	73 db                	jae    801cb2 <__udivdi3+0xea>
  801cd7:	90                   	nop
		{
		  q0--;
  801cd8:	8d 7e ff             	lea    -0x1(%esi),%edi
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  801cdb:	31 f6                	xor    %esi,%esi
  801cdd:	e9 56 ff ff ff       	jmp    801c38 <__udivdi3+0x70>
	...

00801ce4 <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  801ce4:	55                   	push   %ebp
  801ce5:	89 e5                	mov    %esp,%ebp
  801ce7:	57                   	push   %edi
  801ce8:	56                   	push   %esi
  801ce9:	83 ec 20             	sub    $0x20,%esp
  801cec:	8b 45 08             	mov    0x8(%ebp),%eax
  801cef:	8b 4d 10             	mov    0x10(%ebp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  801cf2:	89 45 e8             	mov    %eax,-0x18(%ebp)
  801cf5:	8b 75 0c             	mov    0xc(%ebp),%esi
  const DWunion dd = {.ll = d};
  801cf8:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  801cfb:	8b 7d 14             	mov    0x14(%ebp),%edi
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  801cfe:	89 45 f0             	mov    %eax,-0x10(%ebp)
  n1 = nn.s.high;
  801d01:	89 f2                	mov    %esi,%edx

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  801d03:	85 ff                	test   %edi,%edi
  801d05:	75 15                	jne    801d1c <__umoddi3+0x38>
    {
      if (d0 > n1)
  801d07:	39 f1                	cmp    %esi,%ecx
  801d09:	0f 86 99 00 00 00    	jbe    801da8 <__umoddi3+0xc4>
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801d0f:	f7 f1                	div    %ecx

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
  801d11:	89 d0                	mov    %edx,%eax
  801d13:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  801d15:	83 c4 20             	add    $0x20,%esp
  801d18:	5e                   	pop    %esi
  801d19:	5f                   	pop    %edi
  801d1a:	c9                   	leave  
  801d1b:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  801d1c:	39 f7                	cmp    %esi,%edi
  801d1e:	0f 87 a4 00 00 00    	ja     801dc8 <__umoddi3+0xe4>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  801d24:	0f bd c7             	bsr    %edi,%eax
	  if (bm == 0)
  801d27:	83 f0 1f             	xor    $0x1f,%eax
  801d2a:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801d2d:	0f 84 a1 00 00 00    	je     801dd4 <__umoddi3+0xf0>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  801d33:	89 f8                	mov    %edi,%eax
  801d35:	8a 4d ec             	mov    -0x14(%ebp),%cl
  801d38:	d3 e0                	shl    %cl,%eax
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  801d3a:	bf 20 00 00 00       	mov    $0x20,%edi
  801d3f:	2b 7d ec             	sub    -0x14(%ebp),%edi

	      d1 = (d1 << bm) | (d0 >> b);
  801d42:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801d45:	89 f9                	mov    %edi,%ecx
  801d47:	d3 ea                	shr    %cl,%edx
  801d49:	09 c2                	or     %eax,%edx
  801d4b:	89 55 f0             	mov    %edx,-0x10(%ebp)
	      d0 = d0 << bm;
  801d4e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d51:	8a 4d ec             	mov    -0x14(%ebp),%cl
  801d54:	d3 e0                	shl    %cl,%eax
  801d56:	89 45 f4             	mov    %eax,-0xc(%ebp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  801d59:	89 f2                	mov    %esi,%edx
  801d5b:	d3 e2                	shl    %cl,%edx
	      n0 = n0 << bm;
  801d5d:	8b 45 e8             	mov    -0x18(%ebp),%eax
  801d60:	d3 e0                	shl    %cl,%eax
  801d62:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  801d65:	8b 45 e8             	mov    -0x18(%ebp),%eax
  801d68:	89 f9                	mov    %edi,%ecx
  801d6a:	d3 e8                	shr    %cl,%eax
  801d6c:	09 d0                	or     %edx,%eax

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  801d6e:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  801d70:	89 f2                	mov    %esi,%edx
  801d72:	f7 75 f0             	divl   -0x10(%ebp)
  801d75:	89 d6                	mov    %edx,%esi
	      umul_ppmm (m1, m0, q0, d0);
  801d77:	f7 65 f4             	mull   -0xc(%ebp)
  801d7a:	89 55 e8             	mov    %edx,-0x18(%ebp)
  801d7d:	89 c1                	mov    %eax,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801d7f:	39 d6                	cmp    %edx,%esi
  801d81:	72 71                	jb     801df4 <__umoddi3+0x110>
  801d83:	74 7f                	je     801e04 <__umoddi3+0x120>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  801d85:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801d88:	29 c8                	sub    %ecx,%eax
  801d8a:	19 d6                	sbb    %edx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
  801d8c:	8a 4d ec             	mov    -0x14(%ebp),%cl
  801d8f:	d3 e8                	shr    %cl,%eax
  801d91:	89 f2                	mov    %esi,%edx
  801d93:	89 f9                	mov    %edi,%ecx
  801d95:	d3 e2                	shl    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
  801d97:	09 d0                	or     %edx,%eax
  801d99:	89 f2                	mov    %esi,%edx
  801d9b:	8a 4d ec             	mov    -0x14(%ebp),%cl
  801d9e:	d3 ea                	shr    %cl,%edx
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
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  801da8:	85 c9                	test   %ecx,%ecx
  801daa:	75 0b                	jne    801db7 <__umoddi3+0xd3>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  801dac:	b8 01 00 00 00       	mov    $0x1,%eax
  801db1:	31 d2                	xor    %edx,%edx
  801db3:	f7 f1                	div    %ecx
  801db5:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  801db7:	89 f0                	mov    %esi,%eax
  801db9:	31 d2                	xor    %edx,%edx
  801dbb:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801dbd:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801dc0:	f7 f1                	div    %ecx
  801dc2:	e9 4a ff ff ff       	jmp    801d11 <__umoddi3+0x2d>
  801dc7:	90                   	nop
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
  801dc8:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  801dca:	83 c4 20             	add    $0x20,%esp
  801dcd:	5e                   	pop    %esi
  801dce:	5f                   	pop    %edi
  801dcf:	c9                   	leave  
  801dd0:	c3                   	ret    
  801dd1:	8d 76 00             	lea    0x0(%esi),%esi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  801dd4:	39 f7                	cmp    %esi,%edi
  801dd6:	72 05                	jb     801ddd <__umoddi3+0xf9>
  801dd8:	3b 4d f0             	cmp    -0x10(%ebp),%ecx
  801ddb:	77 0c                	ja     801de9 <__umoddi3+0x105>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  801ddd:	89 f2                	mov    %esi,%edx
  801ddf:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801de2:	29 c8                	sub    %ecx,%eax
  801de4:	19 fa                	sbb    %edi,%edx
  801de6:	89 45 f0             	mov    %eax,-0x10(%ebp)

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
  801de9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  801dec:	83 c4 20             	add    $0x20,%esp
  801def:	5e                   	pop    %esi
  801df0:	5f                   	pop    %edi
  801df1:	c9                   	leave  
  801df2:	c3                   	ret    
  801df3:	90                   	nop
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  801df4:	8b 55 e8             	mov    -0x18(%ebp),%edx
  801df7:	89 c1                	mov    %eax,%ecx
  801df9:	2b 4d f4             	sub    -0xc(%ebp),%ecx
  801dfc:	1b 55 f0             	sbb    -0x10(%ebp),%edx
  801dff:	eb 84                	jmp    801d85 <__umoddi3+0xa1>
  801e01:	8d 76 00             	lea    0x0(%esi),%esi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801e04:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  801e07:	72 eb                	jb     801df4 <__umoddi3+0x110>
  801e09:	89 f2                	mov    %esi,%edx
  801e0b:	e9 75 ff ff ff       	jmp    801d85 <__umoddi3+0xa1>
