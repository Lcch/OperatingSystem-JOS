
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
  8000f6:	68 6a 1e 80 00       	push   $0x801e6a
  8000fb:	6a 42                	push   $0x42
  8000fd:	68 87 1e 80 00       	push   $0x801e87
  800102:	e8 fd 0e 00 00       	call   801004 <_panic>

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
  800452:	8b 14 85 14 1f 80 00 	mov    0x801f14(,%eax,4),%edx
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
  80046a:	68 98 1e 80 00       	push   $0x801e98
  80046f:	e8 68 0c 00 00       	call   8010dc <cprintf>
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
  80069a:	68 d9 1e 80 00       	push   $0x801ed9
  80069f:	e8 38 0a 00 00       	call   8010dc <cprintf>
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
  800771:	68 f5 1e 80 00       	push   $0x801ef5
  800776:	e8 61 09 00 00       	call   8010dc <cprintf>
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
  80081c:	68 b8 1e 80 00       	push   $0x801eb8
  800821:	e8 b6 08 00 00       	call   8010dc <cprintf>
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
  8008d3:	e8 8b 01 00 00       	call   800a63 <open>
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
  80091f:	e8 55 12 00 00       	call   801b79 <ipc_find_env>
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
  80093a:	e8 e5 11 00 00       	call   801b24 <ipc_send>
	
	return ipc_recv(NULL, dstva, NULL);
  80093f:	83 c4 0c             	add    $0xc,%esp
  800942:	6a 00                	push   $0x0
  800944:	56                   	push   %esi
  800945:	6a 00                	push   $0x0
  800947:	e8 30 11 00 00       	call   801a7c <ipc_recv>
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
  800979:	78 39                	js     8009b4 <devfile_stat+0x61>
		return r;
	}
	cprintf("OVER\n");
  80097b:	83 ec 0c             	sub    $0xc,%esp
  80097e:	68 24 1f 80 00       	push   $0x801f24
  800983:	e8 54 07 00 00       	call   8010dc <cprintf>
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  800988:	83 c4 08             	add    $0x8,%esp
  80098b:	68 00 50 80 00       	push   $0x805000
  800990:	53                   	push   %ebx
  800991:	e8 fc 0c 00 00       	call   801692 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  800996:	a1 80 50 80 00       	mov    0x805080,%eax
  80099b:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8009a1:	a1 84 50 80 00       	mov    0x805084,%eax
  8009a6:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8009ac:	83 c4 10             	add    $0x10,%esp
  8009af:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009b4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8009b7:	c9                   	leave  
  8009b8:	c3                   	ret    

008009b9 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8009b9:	55                   	push   %ebp
  8009ba:	89 e5                	mov    %esp,%ebp
  8009bc:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8009bf:	8b 45 08             	mov    0x8(%ebp),%eax
  8009c2:	8b 40 0c             	mov    0xc(%eax),%eax
  8009c5:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8009ca:	ba 00 00 00 00       	mov    $0x0,%edx
  8009cf:	b8 06 00 00 00       	mov    $0x6,%eax
  8009d4:	e8 2f ff ff ff       	call   800908 <fsipc>
}
  8009d9:	c9                   	leave  
  8009da:	c3                   	ret    

008009db <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  8009db:	55                   	push   %ebp
  8009dc:	89 e5                	mov    %esp,%ebp
  8009de:	56                   	push   %esi
  8009df:	53                   	push   %ebx
  8009e0:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8009e3:	8b 45 08             	mov    0x8(%ebp),%eax
  8009e6:	8b 40 0c             	mov    0xc(%eax),%eax
  8009e9:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  8009ee:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8009f4:	ba 00 00 00 00       	mov    $0x0,%edx
  8009f9:	b8 03 00 00 00       	mov    $0x3,%eax
  8009fe:	e8 05 ff ff ff       	call   800908 <fsipc>
  800a03:	89 c3                	mov    %eax,%ebx
  800a05:	85 c0                	test   %eax,%eax
  800a07:	78 51                	js     800a5a <devfile_read+0x7f>
		return r;
	assert(r <= n);
  800a09:	39 c6                	cmp    %eax,%esi
  800a0b:	73 19                	jae    800a26 <devfile_read+0x4b>
  800a0d:	68 2a 1f 80 00       	push   $0x801f2a
  800a12:	68 31 1f 80 00       	push   $0x801f31
  800a17:	68 80 00 00 00       	push   $0x80
  800a1c:	68 46 1f 80 00       	push   $0x801f46
  800a21:	e8 de 05 00 00       	call   801004 <_panic>
	assert(r <= PGSIZE);
  800a26:	3d 00 10 00 00       	cmp    $0x1000,%eax
  800a2b:	7e 19                	jle    800a46 <devfile_read+0x6b>
  800a2d:	68 51 1f 80 00       	push   $0x801f51
  800a32:	68 31 1f 80 00       	push   $0x801f31
  800a37:	68 81 00 00 00       	push   $0x81
  800a3c:	68 46 1f 80 00       	push   $0x801f46
  800a41:	e8 be 05 00 00       	call   801004 <_panic>
	memmove(buf, &fsipcbuf, r);
  800a46:	83 ec 04             	sub    $0x4,%esp
  800a49:	50                   	push   %eax
  800a4a:	68 00 50 80 00       	push   $0x805000
  800a4f:	ff 75 0c             	pushl  0xc(%ebp)
  800a52:	e8 fc 0d 00 00       	call   801853 <memmove>
	return r;
  800a57:	83 c4 10             	add    $0x10,%esp
}
  800a5a:	89 d8                	mov    %ebx,%eax
  800a5c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800a5f:	5b                   	pop    %ebx
  800a60:	5e                   	pop    %esi
  800a61:	c9                   	leave  
  800a62:	c3                   	ret    

00800a63 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  800a63:	55                   	push   %ebp
  800a64:	89 e5                	mov    %esp,%ebp
  800a66:	56                   	push   %esi
  800a67:	53                   	push   %ebx
  800a68:	83 ec 1c             	sub    $0x1c,%esp
  800a6b:	8b 75 08             	mov    0x8(%ebp),%esi
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  800a6e:	56                   	push   %esi
  800a6f:	e8 cc 0b 00 00       	call   801640 <strlen>
  800a74:	83 c4 10             	add    $0x10,%esp
  800a77:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  800a7c:	7f 72                	jg     800af0 <open+0x8d>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800a7e:	83 ec 0c             	sub    $0xc,%esp
  800a81:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800a84:	50                   	push   %eax
  800a85:	e8 ce f8 ff ff       	call   800358 <fd_alloc>
  800a8a:	89 c3                	mov    %eax,%ebx
  800a8c:	83 c4 10             	add    $0x10,%esp
  800a8f:	85 c0                	test   %eax,%eax
  800a91:	78 62                	js     800af5 <open+0x92>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  800a93:	83 ec 08             	sub    $0x8,%esp
  800a96:	56                   	push   %esi
  800a97:	68 00 50 80 00       	push   $0x805000
  800a9c:	e8 f1 0b 00 00       	call   801692 <strcpy>
	fsipcbuf.open.req_omode = mode;
  800aa1:	8b 45 0c             	mov    0xc(%ebp),%eax
  800aa4:	a3 00 54 80 00       	mov    %eax,0x805400



	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  800aa9:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800aac:	b8 01 00 00 00       	mov    $0x1,%eax
  800ab1:	e8 52 fe ff ff       	call   800908 <fsipc>
  800ab6:	89 c3                	mov    %eax,%ebx
  800ab8:	83 c4 10             	add    $0x10,%esp
  800abb:	85 c0                	test   %eax,%eax
  800abd:	79 12                	jns    800ad1 <open+0x6e>
		fd_close(fd, 0);
  800abf:	83 ec 08             	sub    $0x8,%esp
  800ac2:	6a 00                	push   $0x0
  800ac4:	ff 75 f4             	pushl  -0xc(%ebp)
  800ac7:	e8 bb f9 ff ff       	call   800487 <fd_close>
		return r;
  800acc:	83 c4 10             	add    $0x10,%esp
  800acf:	eb 24                	jmp    800af5 <open+0x92>
	}


	cprintf("OPEN\n");
  800ad1:	83 ec 0c             	sub    $0xc,%esp
  800ad4:	68 5d 1f 80 00       	push   $0x801f5d
  800ad9:	e8 fe 05 00 00       	call   8010dc <cprintf>

	return fd2num(fd);
  800ade:	83 c4 04             	add    $0x4,%esp
  800ae1:	ff 75 f4             	pushl  -0xc(%ebp)
  800ae4:	e8 47 f8 ff ff       	call   800330 <fd2num>
  800ae9:	89 c3                	mov    %eax,%ebx
  800aeb:	83 c4 10             	add    $0x10,%esp
  800aee:	eb 05                	jmp    800af5 <open+0x92>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  800af0:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx


	cprintf("OPEN\n");

	return fd2num(fd);
}
  800af5:	89 d8                	mov    %ebx,%eax
  800af7:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800afa:	5b                   	pop    %ebx
  800afb:	5e                   	pop    %esi
  800afc:	c9                   	leave  
  800afd:	c3                   	ret    
	...

00800b00 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  800b00:	55                   	push   %ebp
  800b01:	89 e5                	mov    %esp,%ebp
  800b03:	56                   	push   %esi
  800b04:	53                   	push   %ebx
  800b05:	8b 75 0c             	mov    0xc(%ebp),%esi
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  800b08:	83 ec 0c             	sub    $0xc,%esp
  800b0b:	ff 75 08             	pushl  0x8(%ebp)
  800b0e:	e8 2d f8 ff ff       	call   800340 <fd2data>
  800b13:	89 c3                	mov    %eax,%ebx
	strcpy(stat->st_name, "<pipe>");
  800b15:	83 c4 08             	add    $0x8,%esp
  800b18:	68 63 1f 80 00       	push   $0x801f63
  800b1d:	56                   	push   %esi
  800b1e:	e8 6f 0b 00 00       	call   801692 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  800b23:	8b 43 04             	mov    0x4(%ebx),%eax
  800b26:	2b 03                	sub    (%ebx),%eax
  800b28:	89 86 80 00 00 00    	mov    %eax,0x80(%esi)
	stat->st_isdir = 0;
  800b2e:	c7 86 84 00 00 00 00 	movl   $0x0,0x84(%esi)
  800b35:	00 00 00 
	stat->st_dev = &devpipe;
  800b38:	c7 86 88 00 00 00 20 	movl   $0x803020,0x88(%esi)
  800b3f:	30 80 00 
	return 0;
}
  800b42:	b8 00 00 00 00       	mov    $0x0,%eax
  800b47:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800b4a:	5b                   	pop    %ebx
  800b4b:	5e                   	pop    %esi
  800b4c:	c9                   	leave  
  800b4d:	c3                   	ret    

00800b4e <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  800b4e:	55                   	push   %ebp
  800b4f:	89 e5                	mov    %esp,%ebp
  800b51:	53                   	push   %ebx
  800b52:	83 ec 0c             	sub    $0xc,%esp
  800b55:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  800b58:	53                   	push   %ebx
  800b59:	6a 00                	push   $0x0
  800b5b:	e8 b2 f6 ff ff       	call   800212 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  800b60:	89 1c 24             	mov    %ebx,(%esp)
  800b63:	e8 d8 f7 ff ff       	call   800340 <fd2data>
  800b68:	83 c4 08             	add    $0x8,%esp
  800b6b:	50                   	push   %eax
  800b6c:	6a 00                	push   $0x0
  800b6e:	e8 9f f6 ff ff       	call   800212 <sys_page_unmap>
}
  800b73:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800b76:	c9                   	leave  
  800b77:	c3                   	ret    

00800b78 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  800b78:	55                   	push   %ebp
  800b79:	89 e5                	mov    %esp,%ebp
  800b7b:	57                   	push   %edi
  800b7c:	56                   	push   %esi
  800b7d:	53                   	push   %ebx
  800b7e:	83 ec 1c             	sub    $0x1c,%esp
  800b81:	89 c7                	mov    %eax,%edi
  800b83:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  800b86:	a1 04 40 80 00       	mov    0x804004,%eax
  800b8b:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  800b8e:	83 ec 0c             	sub    $0xc,%esp
  800b91:	57                   	push   %edi
  800b92:	e8 3d 10 00 00       	call   801bd4 <pageref>
  800b97:	89 c6                	mov    %eax,%esi
  800b99:	83 c4 04             	add    $0x4,%esp
  800b9c:	ff 75 e4             	pushl  -0x1c(%ebp)
  800b9f:	e8 30 10 00 00       	call   801bd4 <pageref>
  800ba4:	83 c4 10             	add    $0x10,%esp
  800ba7:	39 c6                	cmp    %eax,%esi
  800ba9:	0f 94 c0             	sete   %al
  800bac:	0f b6 c0             	movzbl %al,%eax
		nn = thisenv->env_runs;
  800baf:	8b 15 04 40 80 00    	mov    0x804004,%edx
  800bb5:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  800bb8:	39 cb                	cmp    %ecx,%ebx
  800bba:	75 08                	jne    800bc4 <_pipeisclosed+0x4c>
			return ret;
		if (n != nn && ret == 1)
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
	}
}
  800bbc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bbf:	5b                   	pop    %ebx
  800bc0:	5e                   	pop    %esi
  800bc1:	5f                   	pop    %edi
  800bc2:	c9                   	leave  
  800bc3:	c3                   	ret    
		n = thisenv->env_runs;
		ret = pageref(fd) == pageref(p);
		nn = thisenv->env_runs;
		if (n == nn)
			return ret;
		if (n != nn && ret == 1)
  800bc4:	83 f8 01             	cmp    $0x1,%eax
  800bc7:	75 bd                	jne    800b86 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  800bc9:	8b 42 58             	mov    0x58(%edx),%eax
  800bcc:	6a 01                	push   $0x1
  800bce:	50                   	push   %eax
  800bcf:	53                   	push   %ebx
  800bd0:	68 6a 1f 80 00       	push   $0x801f6a
  800bd5:	e8 02 05 00 00       	call   8010dc <cprintf>
  800bda:	83 c4 10             	add    $0x10,%esp
  800bdd:	eb a7                	jmp    800b86 <_pipeisclosed+0xe>

00800bdf <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  800bdf:	55                   	push   %ebp
  800be0:	89 e5                	mov    %esp,%ebp
  800be2:	57                   	push   %edi
  800be3:	56                   	push   %esi
  800be4:	53                   	push   %ebx
  800be5:	83 ec 28             	sub    $0x28,%esp
  800be8:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  800beb:	56                   	push   %esi
  800bec:	e8 4f f7 ff ff       	call   800340 <fd2data>
  800bf1:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800bf3:	83 c4 10             	add    $0x10,%esp
  800bf6:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800bfa:	75 4a                	jne    800c46 <devpipe_write+0x67>
  800bfc:	bf 00 00 00 00       	mov    $0x0,%edi
  800c01:	eb 56                	jmp    800c59 <devpipe_write+0x7a>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  800c03:	89 da                	mov    %ebx,%edx
  800c05:	89 f0                	mov    %esi,%eax
  800c07:	e8 6c ff ff ff       	call   800b78 <_pipeisclosed>
  800c0c:	85 c0                	test   %eax,%eax
  800c0e:	75 4d                	jne    800c5d <devpipe_write+0x7e>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  800c10:	e8 8c f5 ff ff       	call   8001a1 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  800c15:	8b 43 04             	mov    0x4(%ebx),%eax
  800c18:	8b 13                	mov    (%ebx),%edx
  800c1a:	83 c2 20             	add    $0x20,%edx
  800c1d:	39 d0                	cmp    %edx,%eax
  800c1f:	73 e2                	jae    800c03 <devpipe_write+0x24>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  800c21:	89 c2                	mov    %eax,%edx
  800c23:	81 e2 1f 00 00 80    	and    $0x8000001f,%edx
  800c29:	79 05                	jns    800c30 <devpipe_write+0x51>
  800c2b:	4a                   	dec    %edx
  800c2c:	83 ca e0             	or     $0xffffffe0,%edx
  800c2f:	42                   	inc    %edx
  800c30:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c33:	8a 0c 39             	mov    (%ecx,%edi,1),%cl
  800c36:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  800c3a:	40                   	inc    %eax
  800c3b:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800c3e:	47                   	inc    %edi
  800c3f:	39 7d 10             	cmp    %edi,0x10(%ebp)
  800c42:	77 07                	ja     800c4b <devpipe_write+0x6c>
  800c44:	eb 13                	jmp    800c59 <devpipe_write+0x7a>
  800c46:	bf 00 00 00 00       	mov    $0x0,%edi
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  800c4b:	8b 43 04             	mov    0x4(%ebx),%eax
  800c4e:	8b 13                	mov    (%ebx),%edx
  800c50:	83 c2 20             	add    $0x20,%edx
  800c53:	39 d0                	cmp    %edx,%eax
  800c55:	73 ac                	jae    800c03 <devpipe_write+0x24>
  800c57:	eb c8                	jmp    800c21 <devpipe_write+0x42>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  800c59:	89 f8                	mov    %edi,%eax
  800c5b:	eb 05                	jmp    800c62 <devpipe_write+0x83>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  800c5d:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  800c62:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c65:	5b                   	pop    %ebx
  800c66:	5e                   	pop    %esi
  800c67:	5f                   	pop    %edi
  800c68:	c9                   	leave  
  800c69:	c3                   	ret    

00800c6a <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  800c6a:	55                   	push   %ebp
  800c6b:	89 e5                	mov    %esp,%ebp
  800c6d:	57                   	push   %edi
  800c6e:	56                   	push   %esi
  800c6f:	53                   	push   %ebx
  800c70:	83 ec 18             	sub    $0x18,%esp
  800c73:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  800c76:	57                   	push   %edi
  800c77:	e8 c4 f6 ff ff       	call   800340 <fd2data>
  800c7c:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800c7e:	83 c4 10             	add    $0x10,%esp
  800c81:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800c85:	75 44                	jne    800ccb <devpipe_read+0x61>
  800c87:	be 00 00 00 00       	mov    $0x0,%esi
  800c8c:	eb 4f                	jmp    800cdd <devpipe_read+0x73>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
				return i;
  800c8e:	89 f0                	mov    %esi,%eax
  800c90:	eb 54                	jmp    800ce6 <devpipe_read+0x7c>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  800c92:	89 da                	mov    %ebx,%edx
  800c94:	89 f8                	mov    %edi,%eax
  800c96:	e8 dd fe ff ff       	call   800b78 <_pipeisclosed>
  800c9b:	85 c0                	test   %eax,%eax
  800c9d:	75 42                	jne    800ce1 <devpipe_read+0x77>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  800c9f:	e8 fd f4 ff ff       	call   8001a1 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  800ca4:	8b 03                	mov    (%ebx),%eax
  800ca6:	3b 43 04             	cmp    0x4(%ebx),%eax
  800ca9:	74 e7                	je     800c92 <devpipe_read+0x28>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  800cab:	25 1f 00 00 80       	and    $0x8000001f,%eax
  800cb0:	79 05                	jns    800cb7 <devpipe_read+0x4d>
  800cb2:	48                   	dec    %eax
  800cb3:	83 c8 e0             	or     $0xffffffe0,%eax
  800cb6:	40                   	inc    %eax
  800cb7:	8a 44 03 08          	mov    0x8(%ebx,%eax,1),%al
  800cbb:	8b 55 0c             	mov    0xc(%ebp),%edx
  800cbe:	88 04 32             	mov    %al,(%edx,%esi,1)
		p->p_rpos++;
  800cc1:	ff 03                	incl   (%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800cc3:	46                   	inc    %esi
  800cc4:	39 75 10             	cmp    %esi,0x10(%ebp)
  800cc7:	77 07                	ja     800cd0 <devpipe_read+0x66>
  800cc9:	eb 12                	jmp    800cdd <devpipe_read+0x73>
  800ccb:	be 00 00 00 00       	mov    $0x0,%esi
		while (p->p_rpos == p->p_wpos) {
  800cd0:	8b 03                	mov    (%ebx),%eax
  800cd2:	3b 43 04             	cmp    0x4(%ebx),%eax
  800cd5:	75 d4                	jne    800cab <devpipe_read+0x41>
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  800cd7:	85 f6                	test   %esi,%esi
  800cd9:	75 b3                	jne    800c8e <devpipe_read+0x24>
  800cdb:	eb b5                	jmp    800c92 <devpipe_read+0x28>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  800cdd:	89 f0                	mov    %esi,%eax
  800cdf:	eb 05                	jmp    800ce6 <devpipe_read+0x7c>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  800ce1:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  800ce6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ce9:	5b                   	pop    %ebx
  800cea:	5e                   	pop    %esi
  800ceb:	5f                   	pop    %edi
  800cec:	c9                   	leave  
  800ced:	c3                   	ret    

00800cee <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  800cee:	55                   	push   %ebp
  800cef:	89 e5                	mov    %esp,%ebp
  800cf1:	57                   	push   %edi
  800cf2:	56                   	push   %esi
  800cf3:	53                   	push   %ebx
  800cf4:	83 ec 28             	sub    $0x28,%esp
  800cf7:	8b 7d 08             	mov    0x8(%ebp),%edi
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  800cfa:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800cfd:	50                   	push   %eax
  800cfe:	e8 55 f6 ff ff       	call   800358 <fd_alloc>
  800d03:	89 c3                	mov    %eax,%ebx
  800d05:	83 c4 10             	add    $0x10,%esp
  800d08:	85 c0                	test   %eax,%eax
  800d0a:	0f 88 24 01 00 00    	js     800e34 <pipe+0x146>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800d10:	83 ec 04             	sub    $0x4,%esp
  800d13:	68 07 04 00 00       	push   $0x407
  800d18:	ff 75 e4             	pushl  -0x1c(%ebp)
  800d1b:	6a 00                	push   $0x0
  800d1d:	e8 a6 f4 ff ff       	call   8001c8 <sys_page_alloc>
  800d22:	89 c3                	mov    %eax,%ebx
  800d24:	83 c4 10             	add    $0x10,%esp
  800d27:	85 c0                	test   %eax,%eax
  800d29:	0f 88 05 01 00 00    	js     800e34 <pipe+0x146>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  800d2f:	83 ec 0c             	sub    $0xc,%esp
  800d32:	8d 45 e0             	lea    -0x20(%ebp),%eax
  800d35:	50                   	push   %eax
  800d36:	e8 1d f6 ff ff       	call   800358 <fd_alloc>
  800d3b:	89 c3                	mov    %eax,%ebx
  800d3d:	83 c4 10             	add    $0x10,%esp
  800d40:	85 c0                	test   %eax,%eax
  800d42:	0f 88 dc 00 00 00    	js     800e24 <pipe+0x136>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800d48:	83 ec 04             	sub    $0x4,%esp
  800d4b:	68 07 04 00 00       	push   $0x407
  800d50:	ff 75 e0             	pushl  -0x20(%ebp)
  800d53:	6a 00                	push   $0x0
  800d55:	e8 6e f4 ff ff       	call   8001c8 <sys_page_alloc>
  800d5a:	89 c3                	mov    %eax,%ebx
  800d5c:	83 c4 10             	add    $0x10,%esp
  800d5f:	85 c0                	test   %eax,%eax
  800d61:	0f 88 bd 00 00 00    	js     800e24 <pipe+0x136>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  800d67:	83 ec 0c             	sub    $0xc,%esp
  800d6a:	ff 75 e4             	pushl  -0x1c(%ebp)
  800d6d:	e8 ce f5 ff ff       	call   800340 <fd2data>
  800d72:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800d74:	83 c4 0c             	add    $0xc,%esp
  800d77:	68 07 04 00 00       	push   $0x407
  800d7c:	50                   	push   %eax
  800d7d:	6a 00                	push   $0x0
  800d7f:	e8 44 f4 ff ff       	call   8001c8 <sys_page_alloc>
  800d84:	89 c3                	mov    %eax,%ebx
  800d86:	83 c4 10             	add    $0x10,%esp
  800d89:	85 c0                	test   %eax,%eax
  800d8b:	0f 88 83 00 00 00    	js     800e14 <pipe+0x126>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800d91:	83 ec 0c             	sub    $0xc,%esp
  800d94:	ff 75 e0             	pushl  -0x20(%ebp)
  800d97:	e8 a4 f5 ff ff       	call   800340 <fd2data>
  800d9c:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  800da3:	50                   	push   %eax
  800da4:	6a 00                	push   $0x0
  800da6:	56                   	push   %esi
  800da7:	6a 00                	push   $0x0
  800da9:	e8 3e f4 ff ff       	call   8001ec <sys_page_map>
  800dae:	89 c3                	mov    %eax,%ebx
  800db0:	83 c4 20             	add    $0x20,%esp
  800db3:	85 c0                	test   %eax,%eax
  800db5:	78 4f                	js     800e06 <pipe+0x118>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  800db7:	8b 15 20 30 80 00    	mov    0x803020,%edx
  800dbd:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800dc0:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  800dc2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800dc5:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  800dcc:	8b 15 20 30 80 00    	mov    0x803020,%edx
  800dd2:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800dd5:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  800dd7:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800dda:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  800de1:	83 ec 0c             	sub    $0xc,%esp
  800de4:	ff 75 e4             	pushl  -0x1c(%ebp)
  800de7:	e8 44 f5 ff ff       	call   800330 <fd2num>
  800dec:	89 07                	mov    %eax,(%edi)
	pfd[1] = fd2num(fd1);
  800dee:	83 c4 04             	add    $0x4,%esp
  800df1:	ff 75 e0             	pushl  -0x20(%ebp)
  800df4:	e8 37 f5 ff ff       	call   800330 <fd2num>
  800df9:	89 47 04             	mov    %eax,0x4(%edi)
	return 0;
  800dfc:	83 c4 10             	add    $0x10,%esp
  800dff:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e04:	eb 2e                	jmp    800e34 <pipe+0x146>

    err3:
	sys_page_unmap(0, va);
  800e06:	83 ec 08             	sub    $0x8,%esp
  800e09:	56                   	push   %esi
  800e0a:	6a 00                	push   $0x0
  800e0c:	e8 01 f4 ff ff       	call   800212 <sys_page_unmap>
  800e11:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  800e14:	83 ec 08             	sub    $0x8,%esp
  800e17:	ff 75 e0             	pushl  -0x20(%ebp)
  800e1a:	6a 00                	push   $0x0
  800e1c:	e8 f1 f3 ff ff       	call   800212 <sys_page_unmap>
  800e21:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  800e24:	83 ec 08             	sub    $0x8,%esp
  800e27:	ff 75 e4             	pushl  -0x1c(%ebp)
  800e2a:	6a 00                	push   $0x0
  800e2c:	e8 e1 f3 ff ff       	call   800212 <sys_page_unmap>
  800e31:	83 c4 10             	add    $0x10,%esp
    err:
	return r;
}
  800e34:	89 d8                	mov    %ebx,%eax
  800e36:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e39:	5b                   	pop    %ebx
  800e3a:	5e                   	pop    %esi
  800e3b:	5f                   	pop    %edi
  800e3c:	c9                   	leave  
  800e3d:	c3                   	ret    

00800e3e <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  800e3e:	55                   	push   %ebp
  800e3f:	89 e5                	mov    %esp,%ebp
  800e41:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800e44:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800e47:	50                   	push   %eax
  800e48:	ff 75 08             	pushl  0x8(%ebp)
  800e4b:	e8 7b f5 ff ff       	call   8003cb <fd_lookup>
  800e50:	83 c4 10             	add    $0x10,%esp
  800e53:	85 c0                	test   %eax,%eax
  800e55:	78 18                	js     800e6f <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  800e57:	83 ec 0c             	sub    $0xc,%esp
  800e5a:	ff 75 f4             	pushl  -0xc(%ebp)
  800e5d:	e8 de f4 ff ff       	call   800340 <fd2data>
	return _pipeisclosed(fd, p);
  800e62:	89 c2                	mov    %eax,%edx
  800e64:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800e67:	e8 0c fd ff ff       	call   800b78 <_pipeisclosed>
  800e6c:	83 c4 10             	add    $0x10,%esp
}
  800e6f:	c9                   	leave  
  800e70:	c3                   	ret    
  800e71:	00 00                	add    %al,(%eax)
	...

00800e74 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  800e74:	55                   	push   %ebp
  800e75:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  800e77:	b8 00 00 00 00       	mov    $0x0,%eax
  800e7c:	c9                   	leave  
  800e7d:	c3                   	ret    

00800e7e <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  800e7e:	55                   	push   %ebp
  800e7f:	89 e5                	mov    %esp,%ebp
  800e81:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  800e84:	68 82 1f 80 00       	push   $0x801f82
  800e89:	ff 75 0c             	pushl  0xc(%ebp)
  800e8c:	e8 01 08 00 00       	call   801692 <strcpy>
	return 0;
}
  800e91:	b8 00 00 00 00       	mov    $0x0,%eax
  800e96:	c9                   	leave  
  800e97:	c3                   	ret    

00800e98 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  800e98:	55                   	push   %ebp
  800e99:	89 e5                	mov    %esp,%ebp
  800e9b:	57                   	push   %edi
  800e9c:	56                   	push   %esi
  800e9d:	53                   	push   %ebx
  800e9e:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800ea4:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800ea8:	74 45                	je     800eef <devcons_write+0x57>
  800eaa:	b8 00 00 00 00       	mov    $0x0,%eax
  800eaf:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  800eb4:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  800eba:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800ebd:	29 c3                	sub    %eax,%ebx
		if (m > sizeof(buf) - 1)
  800ebf:	83 fb 7f             	cmp    $0x7f,%ebx
  800ec2:	76 05                	jbe    800ec9 <devcons_write+0x31>
			m = sizeof(buf) - 1;
  800ec4:	bb 7f 00 00 00       	mov    $0x7f,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  800ec9:	83 ec 04             	sub    $0x4,%esp
  800ecc:	53                   	push   %ebx
  800ecd:	03 45 0c             	add    0xc(%ebp),%eax
  800ed0:	50                   	push   %eax
  800ed1:	57                   	push   %edi
  800ed2:	e8 7c 09 00 00       	call   801853 <memmove>
		sys_cputs(buf, m);
  800ed7:	83 c4 08             	add    $0x8,%esp
  800eda:	53                   	push   %ebx
  800edb:	57                   	push   %edi
  800edc:	e8 30 f2 ff ff       	call   800111 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800ee1:	01 de                	add    %ebx,%esi
  800ee3:	89 f0                	mov    %esi,%eax
  800ee5:	83 c4 10             	add    $0x10,%esp
  800ee8:	3b 75 10             	cmp    0x10(%ebp),%esi
  800eeb:	72 cd                	jb     800eba <devcons_write+0x22>
  800eed:	eb 05                	jmp    800ef4 <devcons_write+0x5c>
  800eef:	be 00 00 00 00       	mov    $0x0,%esi
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  800ef4:	89 f0                	mov    %esi,%eax
  800ef6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ef9:	5b                   	pop    %ebx
  800efa:	5e                   	pop    %esi
  800efb:	5f                   	pop    %edi
  800efc:	c9                   	leave  
  800efd:	c3                   	ret    

00800efe <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  800efe:	55                   	push   %ebp
  800eff:	89 e5                	mov    %esp,%ebp
  800f01:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
  800f04:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800f08:	75 07                	jne    800f11 <devcons_read+0x13>
  800f0a:	eb 25                	jmp    800f31 <devcons_read+0x33>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  800f0c:	e8 90 f2 ff ff       	call   8001a1 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  800f11:	e8 21 f2 ff ff       	call   800137 <sys_cgetc>
  800f16:	85 c0                	test   %eax,%eax
  800f18:	74 f2                	je     800f0c <devcons_read+0xe>
  800f1a:	89 c2                	mov    %eax,%edx
		sys_yield();
	if (c < 0)
  800f1c:	85 c0                	test   %eax,%eax
  800f1e:	78 1d                	js     800f3d <devcons_read+0x3f>
		return c;
	if (c == 0x04)	// ctl-d is eof
  800f20:	83 f8 04             	cmp    $0x4,%eax
  800f23:	74 13                	je     800f38 <devcons_read+0x3a>
		return 0;
	*(char*)vbuf = c;
  800f25:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f28:	88 10                	mov    %dl,(%eax)
	return 1;
  800f2a:	b8 01 00 00 00       	mov    $0x1,%eax
  800f2f:	eb 0c                	jmp    800f3d <devcons_read+0x3f>
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
		return 0;
  800f31:	b8 00 00 00 00       	mov    $0x0,%eax
  800f36:	eb 05                	jmp    800f3d <devcons_read+0x3f>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  800f38:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  800f3d:	c9                   	leave  
  800f3e:	c3                   	ret    

00800f3f <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  800f3f:	55                   	push   %ebp
  800f40:	89 e5                	mov    %esp,%ebp
  800f42:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  800f45:	8b 45 08             	mov    0x8(%ebp),%eax
  800f48:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  800f4b:	6a 01                	push   $0x1
  800f4d:	8d 45 f7             	lea    -0x9(%ebp),%eax
  800f50:	50                   	push   %eax
  800f51:	e8 bb f1 ff ff       	call   800111 <sys_cputs>
  800f56:	83 c4 10             	add    $0x10,%esp
}
  800f59:	c9                   	leave  
  800f5a:	c3                   	ret    

00800f5b <getchar>:

int
getchar(void)
{
  800f5b:	55                   	push   %ebp
  800f5c:	89 e5                	mov    %esp,%ebp
  800f5e:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  800f61:	6a 01                	push   $0x1
  800f63:	8d 45 f7             	lea    -0x9(%ebp),%eax
  800f66:	50                   	push   %eax
  800f67:	6a 00                	push   $0x0
  800f69:	e8 de f6 ff ff       	call   80064c <read>
	if (r < 0)
  800f6e:	83 c4 10             	add    $0x10,%esp
  800f71:	85 c0                	test   %eax,%eax
  800f73:	78 0f                	js     800f84 <getchar+0x29>
		return r;
	if (r < 1)
  800f75:	85 c0                	test   %eax,%eax
  800f77:	7e 06                	jle    800f7f <getchar+0x24>
		return -E_EOF;
	return c;
  800f79:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  800f7d:	eb 05                	jmp    800f84 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  800f7f:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  800f84:	c9                   	leave  
  800f85:	c3                   	ret    

00800f86 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  800f86:	55                   	push   %ebp
  800f87:	89 e5                	mov    %esp,%ebp
  800f89:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800f8c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800f8f:	50                   	push   %eax
  800f90:	ff 75 08             	pushl  0x8(%ebp)
  800f93:	e8 33 f4 ff ff       	call   8003cb <fd_lookup>
  800f98:	83 c4 10             	add    $0x10,%esp
  800f9b:	85 c0                	test   %eax,%eax
  800f9d:	78 11                	js     800fb0 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  800f9f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800fa2:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  800fa8:	39 10                	cmp    %edx,(%eax)
  800faa:	0f 94 c0             	sete   %al
  800fad:	0f b6 c0             	movzbl %al,%eax
}
  800fb0:	c9                   	leave  
  800fb1:	c3                   	ret    

00800fb2 <opencons>:

int
opencons(void)
{
  800fb2:	55                   	push   %ebp
  800fb3:	89 e5                	mov    %esp,%ebp
  800fb5:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  800fb8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800fbb:	50                   	push   %eax
  800fbc:	e8 97 f3 ff ff       	call   800358 <fd_alloc>
  800fc1:	83 c4 10             	add    $0x10,%esp
  800fc4:	85 c0                	test   %eax,%eax
  800fc6:	78 3a                	js     801002 <opencons+0x50>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  800fc8:	83 ec 04             	sub    $0x4,%esp
  800fcb:	68 07 04 00 00       	push   $0x407
  800fd0:	ff 75 f4             	pushl  -0xc(%ebp)
  800fd3:	6a 00                	push   $0x0
  800fd5:	e8 ee f1 ff ff       	call   8001c8 <sys_page_alloc>
  800fda:	83 c4 10             	add    $0x10,%esp
  800fdd:	85 c0                	test   %eax,%eax
  800fdf:	78 21                	js     801002 <opencons+0x50>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  800fe1:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  800fe7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800fea:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  800fec:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800fef:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  800ff6:	83 ec 0c             	sub    $0xc,%esp
  800ff9:	50                   	push   %eax
  800ffa:	e8 31 f3 ff ff       	call   800330 <fd2num>
  800fff:	83 c4 10             	add    $0x10,%esp
}
  801002:	c9                   	leave  
  801003:	c3                   	ret    

00801004 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801004:	55                   	push   %ebp
  801005:	89 e5                	mov    %esp,%ebp
  801007:	56                   	push   %esi
  801008:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801009:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80100c:	8b 1d 00 30 80 00    	mov    0x803000,%ebx
  801012:	e8 66 f1 ff ff       	call   80017d <sys_getenvid>
  801017:	83 ec 0c             	sub    $0xc,%esp
  80101a:	ff 75 0c             	pushl  0xc(%ebp)
  80101d:	ff 75 08             	pushl  0x8(%ebp)
  801020:	53                   	push   %ebx
  801021:	50                   	push   %eax
  801022:	68 90 1f 80 00       	push   $0x801f90
  801027:	e8 b0 00 00 00       	call   8010dc <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80102c:	83 c4 18             	add    $0x18,%esp
  80102f:	56                   	push   %esi
  801030:	ff 75 10             	pushl  0x10(%ebp)
  801033:	e8 53 00 00 00       	call   80108b <vcprintf>
	cprintf("\n");
  801038:	c7 04 24 61 1f 80 00 	movl   $0x801f61,(%esp)
  80103f:	e8 98 00 00 00       	call   8010dc <cprintf>
  801044:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801047:	cc                   	int3   
  801048:	eb fd                	jmp    801047 <_panic+0x43>
	...

0080104c <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80104c:	55                   	push   %ebp
  80104d:	89 e5                	mov    %esp,%ebp
  80104f:	53                   	push   %ebx
  801050:	83 ec 04             	sub    $0x4,%esp
  801053:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  801056:	8b 03                	mov    (%ebx),%eax
  801058:	8b 55 08             	mov    0x8(%ebp),%edx
  80105b:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  80105f:	40                   	inc    %eax
  801060:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  801062:	3d ff 00 00 00       	cmp    $0xff,%eax
  801067:	75 1a                	jne    801083 <putch+0x37>
		sys_cputs(b->buf, b->idx);
  801069:	83 ec 08             	sub    $0x8,%esp
  80106c:	68 ff 00 00 00       	push   $0xff
  801071:	8d 43 08             	lea    0x8(%ebx),%eax
  801074:	50                   	push   %eax
  801075:	e8 97 f0 ff ff       	call   800111 <sys_cputs>
		b->idx = 0;
  80107a:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801080:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  801083:	ff 43 04             	incl   0x4(%ebx)
}
  801086:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801089:	c9                   	leave  
  80108a:	c3                   	ret    

0080108b <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80108b:	55                   	push   %ebp
  80108c:	89 e5                	mov    %esp,%ebp
  80108e:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  801094:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80109b:	00 00 00 
	b.cnt = 0;
  80109e:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8010a5:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8010a8:	ff 75 0c             	pushl  0xc(%ebp)
  8010ab:	ff 75 08             	pushl  0x8(%ebp)
  8010ae:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8010b4:	50                   	push   %eax
  8010b5:	68 4c 10 80 00       	push   $0x80104c
  8010ba:	e8 82 01 00 00       	call   801241 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8010bf:	83 c4 08             	add    $0x8,%esp
  8010c2:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8010c8:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8010ce:	50                   	push   %eax
  8010cf:	e8 3d f0 ff ff       	call   800111 <sys_cputs>

	return b.cnt;
}
  8010d4:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8010da:	c9                   	leave  
  8010db:	c3                   	ret    

008010dc <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8010dc:	55                   	push   %ebp
  8010dd:	89 e5                	mov    %esp,%ebp
  8010df:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8010e2:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8010e5:	50                   	push   %eax
  8010e6:	ff 75 08             	pushl  0x8(%ebp)
  8010e9:	e8 9d ff ff ff       	call   80108b <vcprintf>
	va_end(ap);

	return cnt;
}
  8010ee:	c9                   	leave  
  8010ef:	c3                   	ret    

008010f0 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8010f0:	55                   	push   %ebp
  8010f1:	89 e5                	mov    %esp,%ebp
  8010f3:	57                   	push   %edi
  8010f4:	56                   	push   %esi
  8010f5:	53                   	push   %ebx
  8010f6:	83 ec 2c             	sub    $0x2c,%esp
  8010f9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8010fc:	89 d6                	mov    %edx,%esi
  8010fe:	8b 45 08             	mov    0x8(%ebp),%eax
  801101:	8b 55 0c             	mov    0xc(%ebp),%edx
  801104:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801107:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80110a:	8b 45 10             	mov    0x10(%ebp),%eax
  80110d:	8b 5d 14             	mov    0x14(%ebp),%ebx
  801110:	8b 7d 18             	mov    0x18(%ebp),%edi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  801113:	89 45 d0             	mov    %eax,-0x30(%ebp)
  801116:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  80111d:	39 55 d4             	cmp    %edx,-0x2c(%ebp)
  801120:	72 0c                	jb     80112e <printnum+0x3e>
  801122:	3b 45 d8             	cmp    -0x28(%ebp),%eax
  801125:	76 07                	jbe    80112e <printnum+0x3e>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  801127:	4b                   	dec    %ebx
  801128:	85 db                	test   %ebx,%ebx
  80112a:	7f 31                	jg     80115d <printnum+0x6d>
  80112c:	eb 3f                	jmp    80116d <printnum+0x7d>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80112e:	83 ec 0c             	sub    $0xc,%esp
  801131:	57                   	push   %edi
  801132:	4b                   	dec    %ebx
  801133:	53                   	push   %ebx
  801134:	50                   	push   %eax
  801135:	83 ec 08             	sub    $0x8,%esp
  801138:	ff 75 d4             	pushl  -0x2c(%ebp)
  80113b:	ff 75 d0             	pushl  -0x30(%ebp)
  80113e:	ff 75 dc             	pushl  -0x24(%ebp)
  801141:	ff 75 d8             	pushl  -0x28(%ebp)
  801144:	e8 cf 0a 00 00       	call   801c18 <__udivdi3>
  801149:	83 c4 18             	add    $0x18,%esp
  80114c:	52                   	push   %edx
  80114d:	50                   	push   %eax
  80114e:	89 f2                	mov    %esi,%edx
  801150:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801153:	e8 98 ff ff ff       	call   8010f0 <printnum>
  801158:	83 c4 20             	add    $0x20,%esp
  80115b:	eb 10                	jmp    80116d <printnum+0x7d>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80115d:	83 ec 08             	sub    $0x8,%esp
  801160:	56                   	push   %esi
  801161:	57                   	push   %edi
  801162:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  801165:	4b                   	dec    %ebx
  801166:	83 c4 10             	add    $0x10,%esp
  801169:	85 db                	test   %ebx,%ebx
  80116b:	7f f0                	jg     80115d <printnum+0x6d>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80116d:	83 ec 08             	sub    $0x8,%esp
  801170:	56                   	push   %esi
  801171:	83 ec 04             	sub    $0x4,%esp
  801174:	ff 75 d4             	pushl  -0x2c(%ebp)
  801177:	ff 75 d0             	pushl  -0x30(%ebp)
  80117a:	ff 75 dc             	pushl  -0x24(%ebp)
  80117d:	ff 75 d8             	pushl  -0x28(%ebp)
  801180:	e8 af 0b 00 00       	call   801d34 <__umoddi3>
  801185:	83 c4 14             	add    $0x14,%esp
  801188:	0f be 80 b3 1f 80 00 	movsbl 0x801fb3(%eax),%eax
  80118f:	50                   	push   %eax
  801190:	ff 55 e4             	call   *-0x1c(%ebp)
  801193:	83 c4 10             	add    $0x10,%esp
}
  801196:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801199:	5b                   	pop    %ebx
  80119a:	5e                   	pop    %esi
  80119b:	5f                   	pop    %edi
  80119c:	c9                   	leave  
  80119d:	c3                   	ret    

0080119e <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80119e:	55                   	push   %ebp
  80119f:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8011a1:	83 fa 01             	cmp    $0x1,%edx
  8011a4:	7e 0e                	jle    8011b4 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8011a6:	8b 10                	mov    (%eax),%edx
  8011a8:	8d 4a 08             	lea    0x8(%edx),%ecx
  8011ab:	89 08                	mov    %ecx,(%eax)
  8011ad:	8b 02                	mov    (%edx),%eax
  8011af:	8b 52 04             	mov    0x4(%edx),%edx
  8011b2:	eb 22                	jmp    8011d6 <getuint+0x38>
	else if (lflag)
  8011b4:	85 d2                	test   %edx,%edx
  8011b6:	74 10                	je     8011c8 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8011b8:	8b 10                	mov    (%eax),%edx
  8011ba:	8d 4a 04             	lea    0x4(%edx),%ecx
  8011bd:	89 08                	mov    %ecx,(%eax)
  8011bf:	8b 02                	mov    (%edx),%eax
  8011c1:	ba 00 00 00 00       	mov    $0x0,%edx
  8011c6:	eb 0e                	jmp    8011d6 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8011c8:	8b 10                	mov    (%eax),%edx
  8011ca:	8d 4a 04             	lea    0x4(%edx),%ecx
  8011cd:	89 08                	mov    %ecx,(%eax)
  8011cf:	8b 02                	mov    (%edx),%eax
  8011d1:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8011d6:	c9                   	leave  
  8011d7:	c3                   	ret    

008011d8 <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
  8011d8:	55                   	push   %ebp
  8011d9:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8011db:	83 fa 01             	cmp    $0x1,%edx
  8011de:	7e 0e                	jle    8011ee <getint+0x16>
		return va_arg(*ap, long long);
  8011e0:	8b 10                	mov    (%eax),%edx
  8011e2:	8d 4a 08             	lea    0x8(%edx),%ecx
  8011e5:	89 08                	mov    %ecx,(%eax)
  8011e7:	8b 02                	mov    (%edx),%eax
  8011e9:	8b 52 04             	mov    0x4(%edx),%edx
  8011ec:	eb 1a                	jmp    801208 <getint+0x30>
	else if (lflag)
  8011ee:	85 d2                	test   %edx,%edx
  8011f0:	74 0c                	je     8011fe <getint+0x26>
		return va_arg(*ap, long);
  8011f2:	8b 10                	mov    (%eax),%edx
  8011f4:	8d 4a 04             	lea    0x4(%edx),%ecx
  8011f7:	89 08                	mov    %ecx,(%eax)
  8011f9:	8b 02                	mov    (%edx),%eax
  8011fb:	99                   	cltd   
  8011fc:	eb 0a                	jmp    801208 <getint+0x30>
	else
		return va_arg(*ap, int);
  8011fe:	8b 10                	mov    (%eax),%edx
  801200:	8d 4a 04             	lea    0x4(%edx),%ecx
  801203:	89 08                	mov    %ecx,(%eax)
  801205:	8b 02                	mov    (%edx),%eax
  801207:	99                   	cltd   
}
  801208:	c9                   	leave  
  801209:	c3                   	ret    

0080120a <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80120a:	55                   	push   %ebp
  80120b:	89 e5                	mov    %esp,%ebp
  80120d:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  801210:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  801213:	8b 10                	mov    (%eax),%edx
  801215:	3b 50 04             	cmp    0x4(%eax),%edx
  801218:	73 08                	jae    801222 <sprintputch+0x18>
		*b->buf++ = ch;
  80121a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80121d:	88 0a                	mov    %cl,(%edx)
  80121f:	42                   	inc    %edx
  801220:	89 10                	mov    %edx,(%eax)
}
  801222:	c9                   	leave  
  801223:	c3                   	ret    

00801224 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  801224:	55                   	push   %ebp
  801225:	89 e5                	mov    %esp,%ebp
  801227:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  80122a:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80122d:	50                   	push   %eax
  80122e:	ff 75 10             	pushl  0x10(%ebp)
  801231:	ff 75 0c             	pushl  0xc(%ebp)
  801234:	ff 75 08             	pushl  0x8(%ebp)
  801237:	e8 05 00 00 00       	call   801241 <vprintfmt>
	va_end(ap);
  80123c:	83 c4 10             	add    $0x10,%esp
}
  80123f:	c9                   	leave  
  801240:	c3                   	ret    

00801241 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  801241:	55                   	push   %ebp
  801242:	89 e5                	mov    %esp,%ebp
  801244:	57                   	push   %edi
  801245:	56                   	push   %esi
  801246:	53                   	push   %ebx
  801247:	83 ec 2c             	sub    $0x2c,%esp
  80124a:	8b 7d 0c             	mov    0xc(%ebp),%edi
  80124d:	8b 75 10             	mov    0x10(%ebp),%esi
  801250:	eb 13                	jmp    801265 <vprintfmt+0x24>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  801252:	85 c0                	test   %eax,%eax
  801254:	0f 84 6d 03 00 00    	je     8015c7 <vprintfmt+0x386>
				return;
			putch(ch, putdat);
  80125a:	83 ec 08             	sub    $0x8,%esp
  80125d:	57                   	push   %edi
  80125e:	50                   	push   %eax
  80125f:	ff 55 08             	call   *0x8(%ebp)
  801262:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  801265:	0f b6 06             	movzbl (%esi),%eax
  801268:	46                   	inc    %esi
  801269:	83 f8 25             	cmp    $0x25,%eax
  80126c:	75 e4                	jne    801252 <vprintfmt+0x11>
  80126e:	c6 45 dc 20          	movb   $0x20,-0x24(%ebp)
  801272:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  801279:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
  801280:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  801287:	b9 00 00 00 00       	mov    $0x0,%ecx
  80128c:	eb 28                	jmp    8012b6 <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80128e:	89 de                	mov    %ebx,%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  801290:	c6 45 dc 2d          	movb   $0x2d,-0x24(%ebp)
  801294:	eb 20                	jmp    8012b6 <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801296:	89 de                	mov    %ebx,%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  801298:	c6 45 dc 30          	movb   $0x30,-0x24(%ebp)
  80129c:	eb 18                	jmp    8012b6 <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80129e:	89 de                	mov    %ebx,%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  8012a0:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  8012a7:	eb 0d                	jmp    8012b6 <vprintfmt+0x75>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  8012a9:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8012ac:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8012af:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8012b6:	8a 06                	mov    (%esi),%al
  8012b8:	0f b6 d0             	movzbl %al,%edx
  8012bb:	8d 5e 01             	lea    0x1(%esi),%ebx
  8012be:	83 e8 23             	sub    $0x23,%eax
  8012c1:	3c 55                	cmp    $0x55,%al
  8012c3:	0f 87 e0 02 00 00    	ja     8015a9 <vprintfmt+0x368>
  8012c9:	0f b6 c0             	movzbl %al,%eax
  8012cc:	ff 24 85 00 21 80 00 	jmp    *0x802100(,%eax,4)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8012d3:	83 ea 30             	sub    $0x30,%edx
  8012d6:	89 55 d4             	mov    %edx,-0x2c(%ebp)
				ch = *fmt;
  8012d9:	0f be 03             	movsbl (%ebx),%eax
				if (ch < '0' || ch > '9')
  8012dc:	8d 50 d0             	lea    -0x30(%eax),%edx
  8012df:	83 fa 09             	cmp    $0x9,%edx
  8012e2:	77 44                	ja     801328 <vprintfmt+0xe7>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8012e4:	89 de                	mov    %ebx,%esi
  8012e6:	8b 55 d4             	mov    -0x2c(%ebp),%edx
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8012e9:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
  8012ea:	8d 14 92             	lea    (%edx,%edx,4),%edx
  8012ed:	8d 54 50 d0          	lea    -0x30(%eax,%edx,2),%edx
				ch = *fmt;
  8012f1:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  8012f4:	8d 58 d0             	lea    -0x30(%eax),%ebx
  8012f7:	83 fb 09             	cmp    $0x9,%ebx
  8012fa:	76 ed                	jbe    8012e9 <vprintfmt+0xa8>
  8012fc:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  8012ff:	eb 29                	jmp    80132a <vprintfmt+0xe9>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  801301:	8b 45 14             	mov    0x14(%ebp),%eax
  801304:	8d 50 04             	lea    0x4(%eax),%edx
  801307:	89 55 14             	mov    %edx,0x14(%ebp)
  80130a:	8b 00                	mov    (%eax),%eax
  80130c:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80130f:	89 de                	mov    %ebx,%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  801311:	eb 17                	jmp    80132a <vprintfmt+0xe9>

		case '.':
			if (width < 0)
  801313:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  801317:	78 85                	js     80129e <vprintfmt+0x5d>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801319:	89 de                	mov    %ebx,%esi
  80131b:	eb 99                	jmp    8012b6 <vprintfmt+0x75>
  80131d:	89 de                	mov    %ebx,%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  80131f:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
			goto reswitch;
  801326:	eb 8e                	jmp    8012b6 <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801328:	89 de                	mov    %ebx,%esi
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  80132a:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80132e:	79 86                	jns    8012b6 <vprintfmt+0x75>
  801330:	e9 74 ff ff ff       	jmp    8012a9 <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  801335:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801336:	89 de                	mov    %ebx,%esi
  801338:	e9 79 ff ff ff       	jmp    8012b6 <vprintfmt+0x75>
  80133d:	89 5d d8             	mov    %ebx,-0x28(%ebp)
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  801340:	8b 45 14             	mov    0x14(%ebp),%eax
  801343:	8d 50 04             	lea    0x4(%eax),%edx
  801346:	89 55 14             	mov    %edx,0x14(%ebp)
  801349:	83 ec 08             	sub    $0x8,%esp
  80134c:	57                   	push   %edi
  80134d:	ff 30                	pushl  (%eax)
  80134f:	ff 55 08             	call   *0x8(%ebp)
			break;
  801352:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801355:	8b 75 d8             	mov    -0x28(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  801358:	e9 08 ff ff ff       	jmp    801265 <vprintfmt+0x24>
  80135d:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// error message
		case 'e':
			err = va_arg(ap, int);
  801360:	8b 45 14             	mov    0x14(%ebp),%eax
  801363:	8d 50 04             	lea    0x4(%eax),%edx
  801366:	89 55 14             	mov    %edx,0x14(%ebp)
  801369:	8b 00                	mov    (%eax),%eax
  80136b:	85 c0                	test   %eax,%eax
  80136d:	79 02                	jns    801371 <vprintfmt+0x130>
  80136f:	f7 d8                	neg    %eax
  801371:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  801373:	83 f8 0f             	cmp    $0xf,%eax
  801376:	7f 0b                	jg     801383 <vprintfmt+0x142>
  801378:	8b 04 85 60 22 80 00 	mov    0x802260(,%eax,4),%eax
  80137f:	85 c0                	test   %eax,%eax
  801381:	75 1a                	jne    80139d <vprintfmt+0x15c>
				printfmt(putch, putdat, "error %d", err);
  801383:	52                   	push   %edx
  801384:	68 cb 1f 80 00       	push   $0x801fcb
  801389:	57                   	push   %edi
  80138a:	ff 75 08             	pushl  0x8(%ebp)
  80138d:	e8 92 fe ff ff       	call   801224 <printfmt>
  801392:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801395:	8b 75 d8             	mov    -0x28(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  801398:	e9 c8 fe ff ff       	jmp    801265 <vprintfmt+0x24>
			else
				printfmt(putch, putdat, "%s", p);
  80139d:	50                   	push   %eax
  80139e:	68 43 1f 80 00       	push   $0x801f43
  8013a3:	57                   	push   %edi
  8013a4:	ff 75 08             	pushl  0x8(%ebp)
  8013a7:	e8 78 fe ff ff       	call   801224 <printfmt>
  8013ac:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8013af:	8b 75 d8             	mov    -0x28(%ebp),%esi
  8013b2:	e9 ae fe ff ff       	jmp    801265 <vprintfmt+0x24>
  8013b7:	89 5d d8             	mov    %ebx,-0x28(%ebp)
  8013ba:	89 de                	mov    %ebx,%esi
  8013bc:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  8013bf:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8013c2:	8b 45 14             	mov    0x14(%ebp),%eax
  8013c5:	8d 50 04             	lea    0x4(%eax),%edx
  8013c8:	89 55 14             	mov    %edx,0x14(%ebp)
  8013cb:	8b 00                	mov    (%eax),%eax
  8013cd:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8013d0:	85 c0                	test   %eax,%eax
  8013d2:	75 07                	jne    8013db <vprintfmt+0x19a>
				p = "(null)";
  8013d4:	c7 45 d0 c4 1f 80 00 	movl   $0x801fc4,-0x30(%ebp)
			if (width > 0 && padc != '-')
  8013db:	85 db                	test   %ebx,%ebx
  8013dd:	7e 42                	jle    801421 <vprintfmt+0x1e0>
  8013df:	80 7d dc 2d          	cmpb   $0x2d,-0x24(%ebp)
  8013e3:	74 3c                	je     801421 <vprintfmt+0x1e0>
				for (width -= strnlen(p, precision); width > 0; width--)
  8013e5:	83 ec 08             	sub    $0x8,%esp
  8013e8:	51                   	push   %ecx
  8013e9:	ff 75 d0             	pushl  -0x30(%ebp)
  8013ec:	e8 6f 02 00 00       	call   801660 <strnlen>
  8013f1:	29 c3                	sub    %eax,%ebx
  8013f3:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8013f6:	83 c4 10             	add    $0x10,%esp
  8013f9:	85 db                	test   %ebx,%ebx
  8013fb:	7e 24                	jle    801421 <vprintfmt+0x1e0>
					putch(padc, putdat);
  8013fd:	0f be 5d dc          	movsbl -0x24(%ebp),%ebx
  801401:	89 75 dc             	mov    %esi,-0x24(%ebp)
  801404:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  801407:	83 ec 08             	sub    $0x8,%esp
  80140a:	57                   	push   %edi
  80140b:	53                   	push   %ebx
  80140c:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80140f:	4e                   	dec    %esi
  801410:	83 c4 10             	add    $0x10,%esp
  801413:	85 f6                	test   %esi,%esi
  801415:	7f f0                	jg     801407 <vprintfmt+0x1c6>
  801417:	8b 75 dc             	mov    -0x24(%ebp),%esi
  80141a:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  801421:	8b 55 d0             	mov    -0x30(%ebp),%edx
  801424:	0f be 02             	movsbl (%edx),%eax
  801427:	85 c0                	test   %eax,%eax
  801429:	75 47                	jne    801472 <vprintfmt+0x231>
  80142b:	eb 37                	jmp    801464 <vprintfmt+0x223>
				if (altflag && (ch < ' ' || ch > '~'))
  80142d:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  801431:	74 16                	je     801449 <vprintfmt+0x208>
  801433:	8d 50 e0             	lea    -0x20(%eax),%edx
  801436:	83 fa 5e             	cmp    $0x5e,%edx
  801439:	76 0e                	jbe    801449 <vprintfmt+0x208>
					putch('?', putdat);
  80143b:	83 ec 08             	sub    $0x8,%esp
  80143e:	57                   	push   %edi
  80143f:	6a 3f                	push   $0x3f
  801441:	ff 55 08             	call   *0x8(%ebp)
  801444:	83 c4 10             	add    $0x10,%esp
  801447:	eb 0b                	jmp    801454 <vprintfmt+0x213>
				else
					putch(ch, putdat);
  801449:	83 ec 08             	sub    $0x8,%esp
  80144c:	57                   	push   %edi
  80144d:	50                   	push   %eax
  80144e:	ff 55 08             	call   *0x8(%ebp)
  801451:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  801454:	ff 4d e4             	decl   -0x1c(%ebp)
  801457:	0f be 03             	movsbl (%ebx),%eax
  80145a:	85 c0                	test   %eax,%eax
  80145c:	74 03                	je     801461 <vprintfmt+0x220>
  80145e:	43                   	inc    %ebx
  80145f:	eb 1b                	jmp    80147c <vprintfmt+0x23b>
  801461:	8b 75 dc             	mov    -0x24(%ebp),%esi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  801464:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  801468:	7f 1e                	jg     801488 <vprintfmt+0x247>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80146a:	8b 75 d8             	mov    -0x28(%ebp),%esi
  80146d:	e9 f3 fd ff ff       	jmp    801265 <vprintfmt+0x24>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  801472:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  801475:	43                   	inc    %ebx
  801476:	89 75 dc             	mov    %esi,-0x24(%ebp)
  801479:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  80147c:	85 f6                	test   %esi,%esi
  80147e:	78 ad                	js     80142d <vprintfmt+0x1ec>
  801480:	4e                   	dec    %esi
  801481:	79 aa                	jns    80142d <vprintfmt+0x1ec>
  801483:	8b 75 dc             	mov    -0x24(%ebp),%esi
  801486:	eb dc                	jmp    801464 <vprintfmt+0x223>
  801488:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80148b:	83 ec 08             	sub    $0x8,%esp
  80148e:	57                   	push   %edi
  80148f:	6a 20                	push   $0x20
  801491:	ff 55 08             	call   *0x8(%ebp)
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  801494:	4b                   	dec    %ebx
  801495:	83 c4 10             	add    $0x10,%esp
  801498:	85 db                	test   %ebx,%ebx
  80149a:	7f ef                	jg     80148b <vprintfmt+0x24a>
  80149c:	e9 c4 fd ff ff       	jmp    801265 <vprintfmt+0x24>
  8014a1:	89 5d d8             	mov    %ebx,-0x28(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8014a4:	89 ca                	mov    %ecx,%edx
  8014a6:	8d 45 14             	lea    0x14(%ebp),%eax
  8014a9:	e8 2a fd ff ff       	call   8011d8 <getint>
  8014ae:	89 c3                	mov    %eax,%ebx
  8014b0:	89 d6                	mov    %edx,%esi
			if ((long long) num < 0) {
  8014b2:	85 d2                	test   %edx,%edx
  8014b4:	78 0a                	js     8014c0 <vprintfmt+0x27f>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8014b6:	b8 0a 00 00 00       	mov    $0xa,%eax
  8014bb:	e9 b0 00 00 00       	jmp    801570 <vprintfmt+0x32f>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  8014c0:	83 ec 08             	sub    $0x8,%esp
  8014c3:	57                   	push   %edi
  8014c4:	6a 2d                	push   $0x2d
  8014c6:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  8014c9:	f7 db                	neg    %ebx
  8014cb:	83 d6 00             	adc    $0x0,%esi
  8014ce:	f7 de                	neg    %esi
  8014d0:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  8014d3:	b8 0a 00 00 00       	mov    $0xa,%eax
  8014d8:	e9 93 00 00 00       	jmp    801570 <vprintfmt+0x32f>
  8014dd:	89 5d d8             	mov    %ebx,-0x28(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8014e0:	89 ca                	mov    %ecx,%edx
  8014e2:	8d 45 14             	lea    0x14(%ebp),%eax
  8014e5:	e8 b4 fc ff ff       	call   80119e <getuint>
  8014ea:	89 c3                	mov    %eax,%ebx
  8014ec:	89 d6                	mov    %edx,%esi
			base = 10;
  8014ee:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  8014f3:	eb 7b                	jmp    801570 <vprintfmt+0x32f>
  8014f5:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// (unsigned) octal
		case 'o':
            // (MIT 6.828, lab1, Ex.8)  my code : 
            num = getint(&ap, lflag);
  8014f8:	89 ca                	mov    %ecx,%edx
  8014fa:	8d 45 14             	lea    0x14(%ebp),%eax
  8014fd:	e8 d6 fc ff ff       	call   8011d8 <getint>
  801502:	89 c3                	mov    %eax,%ebx
  801504:	89 d6                	mov    %edx,%esi
            if ((long long) num < 0) {
  801506:	85 d2                	test   %edx,%edx
  801508:	78 07                	js     801511 <vprintfmt+0x2d0>
                putch('-', putdat);
                num = -(long long) num;
            }
            base = 8;
  80150a:	b8 08 00 00 00       	mov    $0x8,%eax
  80150f:	eb 5f                	jmp    801570 <vprintfmt+0x32f>
		// (unsigned) octal
		case 'o':
            // (MIT 6.828, lab1, Ex.8)  my code : 
            num = getint(&ap, lflag);
            if ((long long) num < 0) {
                putch('-', putdat);
  801511:	83 ec 08             	sub    $0x8,%esp
  801514:	57                   	push   %edi
  801515:	6a 2d                	push   $0x2d
  801517:	ff 55 08             	call   *0x8(%ebp)
                num = -(long long) num;
  80151a:	f7 db                	neg    %ebx
  80151c:	83 d6 00             	adc    $0x0,%esi
  80151f:	f7 de                	neg    %esi
  801521:	83 c4 10             	add    $0x10,%esp
            }
            base = 8;
  801524:	b8 08 00 00 00       	mov    $0x8,%eax
  801529:	eb 45                	jmp    801570 <vprintfmt+0x32f>
  80152b:	89 5d d8             	mov    %ebx,-0x28(%ebp)
            goto number;

        // pointer
		case 'p':
			putch('0', putdat);
  80152e:	83 ec 08             	sub    $0x8,%esp
  801531:	57                   	push   %edi
  801532:	6a 30                	push   $0x30
  801534:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  801537:	83 c4 08             	add    $0x8,%esp
  80153a:	57                   	push   %edi
  80153b:	6a 78                	push   $0x78
  80153d:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  801540:	8b 45 14             	mov    0x14(%ebp),%eax
  801543:	8d 50 04             	lea    0x4(%eax),%edx
  801546:	89 55 14             	mov    %edx,0x14(%ebp)

        // pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  801549:	8b 18                	mov    (%eax),%ebx
  80154b:	be 00 00 00 00       	mov    $0x0,%esi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  801550:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  801553:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  801558:	eb 16                	jmp    801570 <vprintfmt+0x32f>
  80155a:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  80155d:	89 ca                	mov    %ecx,%edx
  80155f:	8d 45 14             	lea    0x14(%ebp),%eax
  801562:	e8 37 fc ff ff       	call   80119e <getuint>
  801567:	89 c3                	mov    %eax,%ebx
  801569:	89 d6                	mov    %edx,%esi
			base = 16;
  80156b:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  801570:	83 ec 0c             	sub    $0xc,%esp
  801573:	0f be 55 dc          	movsbl -0x24(%ebp),%edx
  801577:	52                   	push   %edx
  801578:	ff 75 e4             	pushl  -0x1c(%ebp)
  80157b:	50                   	push   %eax
  80157c:	56                   	push   %esi
  80157d:	53                   	push   %ebx
  80157e:	89 fa                	mov    %edi,%edx
  801580:	8b 45 08             	mov    0x8(%ebp),%eax
  801583:	e8 68 fb ff ff       	call   8010f0 <printnum>
			break;
  801588:	83 c4 20             	add    $0x20,%esp
  80158b:	8b 75 d8             	mov    -0x28(%ebp),%esi
  80158e:	e9 d2 fc ff ff       	jmp    801265 <vprintfmt+0x24>
  801593:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  801596:	83 ec 08             	sub    $0x8,%esp
  801599:	57                   	push   %edi
  80159a:	52                   	push   %edx
  80159b:	ff 55 08             	call   *0x8(%ebp)
			break;
  80159e:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8015a1:	8b 75 d8             	mov    -0x28(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8015a4:	e9 bc fc ff ff       	jmp    801265 <vprintfmt+0x24>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8015a9:	83 ec 08             	sub    $0x8,%esp
  8015ac:	57                   	push   %edi
  8015ad:	6a 25                	push   $0x25
  8015af:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  8015b2:	83 c4 10             	add    $0x10,%esp
  8015b5:	eb 02                	jmp    8015b9 <vprintfmt+0x378>
  8015b7:	89 c6                	mov    %eax,%esi
  8015b9:	8d 46 ff             	lea    -0x1(%esi),%eax
  8015bc:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  8015c0:	75 f5                	jne    8015b7 <vprintfmt+0x376>
  8015c2:	e9 9e fc ff ff       	jmp    801265 <vprintfmt+0x24>
				/* do nothing */;
			break;
		}
	}
}
  8015c7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8015ca:	5b                   	pop    %ebx
  8015cb:	5e                   	pop    %esi
  8015cc:	5f                   	pop    %edi
  8015cd:	c9                   	leave  
  8015ce:	c3                   	ret    

008015cf <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8015cf:	55                   	push   %ebp
  8015d0:	89 e5                	mov    %esp,%ebp
  8015d2:	83 ec 18             	sub    $0x18,%esp
  8015d5:	8b 45 08             	mov    0x8(%ebp),%eax
  8015d8:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8015db:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8015de:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8015e2:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8015e5:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8015ec:	85 c0                	test   %eax,%eax
  8015ee:	74 26                	je     801616 <vsnprintf+0x47>
  8015f0:	85 d2                	test   %edx,%edx
  8015f2:	7e 29                	jle    80161d <vsnprintf+0x4e>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8015f4:	ff 75 14             	pushl  0x14(%ebp)
  8015f7:	ff 75 10             	pushl  0x10(%ebp)
  8015fa:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8015fd:	50                   	push   %eax
  8015fe:	68 0a 12 80 00       	push   $0x80120a
  801603:	e8 39 fc ff ff       	call   801241 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  801608:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80160b:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80160e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801611:	83 c4 10             	add    $0x10,%esp
  801614:	eb 0c                	jmp    801622 <vsnprintf+0x53>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  801616:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80161b:	eb 05                	jmp    801622 <vsnprintf+0x53>
  80161d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  801622:	c9                   	leave  
  801623:	c3                   	ret    

00801624 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  801624:	55                   	push   %ebp
  801625:	89 e5                	mov    %esp,%ebp
  801627:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80162a:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80162d:	50                   	push   %eax
  80162e:	ff 75 10             	pushl  0x10(%ebp)
  801631:	ff 75 0c             	pushl  0xc(%ebp)
  801634:	ff 75 08             	pushl  0x8(%ebp)
  801637:	e8 93 ff ff ff       	call   8015cf <vsnprintf>
	va_end(ap);

	return rc;
}
  80163c:	c9                   	leave  
  80163d:	c3                   	ret    
	...

00801640 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  801640:	55                   	push   %ebp
  801641:	89 e5                	mov    %esp,%ebp
  801643:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  801646:	80 3a 00             	cmpb   $0x0,(%edx)
  801649:	74 0e                	je     801659 <strlen+0x19>
  80164b:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  801650:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  801651:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  801655:	75 f9                	jne    801650 <strlen+0x10>
  801657:	eb 05                	jmp    80165e <strlen+0x1e>
  801659:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  80165e:	c9                   	leave  
  80165f:	c3                   	ret    

00801660 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  801660:	55                   	push   %ebp
  801661:	89 e5                	mov    %esp,%ebp
  801663:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801666:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801669:	85 d2                	test   %edx,%edx
  80166b:	74 17                	je     801684 <strnlen+0x24>
  80166d:	80 39 00             	cmpb   $0x0,(%ecx)
  801670:	74 19                	je     80168b <strnlen+0x2b>
  801672:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  801677:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801678:	39 d0                	cmp    %edx,%eax
  80167a:	74 14                	je     801690 <strnlen+0x30>
  80167c:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  801680:	75 f5                	jne    801677 <strnlen+0x17>
  801682:	eb 0c                	jmp    801690 <strnlen+0x30>
  801684:	b8 00 00 00 00       	mov    $0x0,%eax
  801689:	eb 05                	jmp    801690 <strnlen+0x30>
  80168b:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  801690:	c9                   	leave  
  801691:	c3                   	ret    

00801692 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  801692:	55                   	push   %ebp
  801693:	89 e5                	mov    %esp,%ebp
  801695:	53                   	push   %ebx
  801696:	8b 45 08             	mov    0x8(%ebp),%eax
  801699:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  80169c:	ba 00 00 00 00       	mov    $0x0,%edx
  8016a1:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  8016a4:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  8016a7:	42                   	inc    %edx
  8016a8:	84 c9                	test   %cl,%cl
  8016aa:	75 f5                	jne    8016a1 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  8016ac:	5b                   	pop    %ebx
  8016ad:	c9                   	leave  
  8016ae:	c3                   	ret    

008016af <strcat>:

char *
strcat(char *dst, const char *src)
{
  8016af:	55                   	push   %ebp
  8016b0:	89 e5                	mov    %esp,%ebp
  8016b2:	53                   	push   %ebx
  8016b3:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8016b6:	53                   	push   %ebx
  8016b7:	e8 84 ff ff ff       	call   801640 <strlen>
  8016bc:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8016bf:	ff 75 0c             	pushl  0xc(%ebp)
  8016c2:	8d 04 03             	lea    (%ebx,%eax,1),%eax
  8016c5:	50                   	push   %eax
  8016c6:	e8 c7 ff ff ff       	call   801692 <strcpy>
	return dst;
}
  8016cb:	89 d8                	mov    %ebx,%eax
  8016cd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016d0:	c9                   	leave  
  8016d1:	c3                   	ret    

008016d2 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8016d2:	55                   	push   %ebp
  8016d3:	89 e5                	mov    %esp,%ebp
  8016d5:	56                   	push   %esi
  8016d6:	53                   	push   %ebx
  8016d7:	8b 45 08             	mov    0x8(%ebp),%eax
  8016da:	8b 55 0c             	mov    0xc(%ebp),%edx
  8016dd:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8016e0:	85 f6                	test   %esi,%esi
  8016e2:	74 15                	je     8016f9 <strncpy+0x27>
  8016e4:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
  8016e9:	8a 1a                	mov    (%edx),%bl
  8016eb:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8016ee:	80 3a 01             	cmpb   $0x1,(%edx)
  8016f1:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8016f4:	41                   	inc    %ecx
  8016f5:	39 ce                	cmp    %ecx,%esi
  8016f7:	77 f0                	ja     8016e9 <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8016f9:	5b                   	pop    %ebx
  8016fa:	5e                   	pop    %esi
  8016fb:	c9                   	leave  
  8016fc:	c3                   	ret    

008016fd <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8016fd:	55                   	push   %ebp
  8016fe:	89 e5                	mov    %esp,%ebp
  801700:	57                   	push   %edi
  801701:	56                   	push   %esi
  801702:	53                   	push   %ebx
  801703:	8b 7d 08             	mov    0x8(%ebp),%edi
  801706:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801709:	8b 75 10             	mov    0x10(%ebp),%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80170c:	85 f6                	test   %esi,%esi
  80170e:	74 32                	je     801742 <strlcpy+0x45>
		while (--size > 0 && *src != '\0')
  801710:	83 fe 01             	cmp    $0x1,%esi
  801713:	74 22                	je     801737 <strlcpy+0x3a>
  801715:	8a 0b                	mov    (%ebx),%cl
  801717:	84 c9                	test   %cl,%cl
  801719:	74 20                	je     80173b <strlcpy+0x3e>
  80171b:	89 f8                	mov    %edi,%eax
  80171d:	ba 00 00 00 00       	mov    $0x0,%edx
	}
	return ret;
}

size_t
strlcpy(char *dst, const char *src, size_t size)
  801722:	83 ee 02             	sub    $0x2,%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  801725:	88 08                	mov    %cl,(%eax)
  801727:	40                   	inc    %eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  801728:	39 f2                	cmp    %esi,%edx
  80172a:	74 11                	je     80173d <strlcpy+0x40>
  80172c:	8a 4c 13 01          	mov    0x1(%ebx,%edx,1),%cl
  801730:	42                   	inc    %edx
  801731:	84 c9                	test   %cl,%cl
  801733:	75 f0                	jne    801725 <strlcpy+0x28>
  801735:	eb 06                	jmp    80173d <strlcpy+0x40>
  801737:	89 f8                	mov    %edi,%eax
  801739:	eb 02                	jmp    80173d <strlcpy+0x40>
  80173b:	89 f8                	mov    %edi,%eax
			*dst++ = *src++;
		*dst = '\0';
  80173d:	c6 00 00             	movb   $0x0,(%eax)
  801740:	eb 02                	jmp    801744 <strlcpy+0x47>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  801742:	89 f8                	mov    %edi,%eax
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
		*dst = '\0';
	}
	return dst - dst_in;
  801744:	29 f8                	sub    %edi,%eax
}
  801746:	5b                   	pop    %ebx
  801747:	5e                   	pop    %esi
  801748:	5f                   	pop    %edi
  801749:	c9                   	leave  
  80174a:	c3                   	ret    

0080174b <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80174b:	55                   	push   %ebp
  80174c:	89 e5                	mov    %esp,%ebp
  80174e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801751:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  801754:	8a 01                	mov    (%ecx),%al
  801756:	84 c0                	test   %al,%al
  801758:	74 10                	je     80176a <strcmp+0x1f>
  80175a:	3a 02                	cmp    (%edx),%al
  80175c:	75 0c                	jne    80176a <strcmp+0x1f>
		p++, q++;
  80175e:	41                   	inc    %ecx
  80175f:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  801760:	8a 01                	mov    (%ecx),%al
  801762:	84 c0                	test   %al,%al
  801764:	74 04                	je     80176a <strcmp+0x1f>
  801766:	3a 02                	cmp    (%edx),%al
  801768:	74 f4                	je     80175e <strcmp+0x13>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  80176a:	0f b6 c0             	movzbl %al,%eax
  80176d:	0f b6 12             	movzbl (%edx),%edx
  801770:	29 d0                	sub    %edx,%eax
}
  801772:	c9                   	leave  
  801773:	c3                   	ret    

00801774 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  801774:	55                   	push   %ebp
  801775:	89 e5                	mov    %esp,%ebp
  801777:	53                   	push   %ebx
  801778:	8b 55 08             	mov    0x8(%ebp),%edx
  80177b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80177e:	8b 45 10             	mov    0x10(%ebp),%eax
	while (n > 0 && *p && *p == *q)
  801781:	85 c0                	test   %eax,%eax
  801783:	74 1b                	je     8017a0 <strncmp+0x2c>
  801785:	8a 1a                	mov    (%edx),%bl
  801787:	84 db                	test   %bl,%bl
  801789:	74 24                	je     8017af <strncmp+0x3b>
  80178b:	3a 19                	cmp    (%ecx),%bl
  80178d:	75 20                	jne    8017af <strncmp+0x3b>
  80178f:	48                   	dec    %eax
  801790:	74 15                	je     8017a7 <strncmp+0x33>
		n--, p++, q++;
  801792:	42                   	inc    %edx
  801793:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  801794:	8a 1a                	mov    (%edx),%bl
  801796:	84 db                	test   %bl,%bl
  801798:	74 15                	je     8017af <strncmp+0x3b>
  80179a:	3a 19                	cmp    (%ecx),%bl
  80179c:	74 f1                	je     80178f <strncmp+0x1b>
  80179e:	eb 0f                	jmp    8017af <strncmp+0x3b>
		n--, p++, q++;
	if (n == 0)
		return 0;
  8017a0:	b8 00 00 00 00       	mov    $0x0,%eax
  8017a5:	eb 05                	jmp    8017ac <strncmp+0x38>
  8017a7:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8017ac:	5b                   	pop    %ebx
  8017ad:	c9                   	leave  
  8017ae:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8017af:	0f b6 02             	movzbl (%edx),%eax
  8017b2:	0f b6 11             	movzbl (%ecx),%edx
  8017b5:	29 d0                	sub    %edx,%eax
  8017b7:	eb f3                	jmp    8017ac <strncmp+0x38>

008017b9 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8017b9:	55                   	push   %ebp
  8017ba:	89 e5                	mov    %esp,%ebp
  8017bc:	8b 45 08             	mov    0x8(%ebp),%eax
  8017bf:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  8017c2:	8a 10                	mov    (%eax),%dl
  8017c4:	84 d2                	test   %dl,%dl
  8017c6:	74 18                	je     8017e0 <strchr+0x27>
		if (*s == c)
  8017c8:	38 ca                	cmp    %cl,%dl
  8017ca:	75 06                	jne    8017d2 <strchr+0x19>
  8017cc:	eb 17                	jmp    8017e5 <strchr+0x2c>
  8017ce:	38 ca                	cmp    %cl,%dl
  8017d0:	74 13                	je     8017e5 <strchr+0x2c>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8017d2:	40                   	inc    %eax
  8017d3:	8a 10                	mov    (%eax),%dl
  8017d5:	84 d2                	test   %dl,%dl
  8017d7:	75 f5                	jne    8017ce <strchr+0x15>
		if (*s == c)
			return (char *) s;
	return 0;
  8017d9:	b8 00 00 00 00       	mov    $0x0,%eax
  8017de:	eb 05                	jmp    8017e5 <strchr+0x2c>
  8017e0:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8017e5:	c9                   	leave  
  8017e6:	c3                   	ret    

008017e7 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8017e7:	55                   	push   %ebp
  8017e8:	89 e5                	mov    %esp,%ebp
  8017ea:	8b 45 08             	mov    0x8(%ebp),%eax
  8017ed:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  8017f0:	8a 10                	mov    (%eax),%dl
  8017f2:	84 d2                	test   %dl,%dl
  8017f4:	74 11                	je     801807 <strfind+0x20>
		if (*s == c)
  8017f6:	38 ca                	cmp    %cl,%dl
  8017f8:	75 06                	jne    801800 <strfind+0x19>
  8017fa:	eb 0b                	jmp    801807 <strfind+0x20>
  8017fc:	38 ca                	cmp    %cl,%dl
  8017fe:	74 07                	je     801807 <strfind+0x20>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  801800:	40                   	inc    %eax
  801801:	8a 10                	mov    (%eax),%dl
  801803:	84 d2                	test   %dl,%dl
  801805:	75 f5                	jne    8017fc <strfind+0x15>
		if (*s == c)
			break;
	return (char *) s;
}
  801807:	c9                   	leave  
  801808:	c3                   	ret    

00801809 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  801809:	55                   	push   %ebp
  80180a:	89 e5                	mov    %esp,%ebp
  80180c:	57                   	push   %edi
  80180d:	56                   	push   %esi
  80180e:	53                   	push   %ebx
  80180f:	8b 7d 08             	mov    0x8(%ebp),%edi
  801812:	8b 45 0c             	mov    0xc(%ebp),%eax
  801815:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  801818:	85 c9                	test   %ecx,%ecx
  80181a:	74 30                	je     80184c <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  80181c:	f7 c7 03 00 00 00    	test   $0x3,%edi
  801822:	75 25                	jne    801849 <memset+0x40>
  801824:	f6 c1 03             	test   $0x3,%cl
  801827:	75 20                	jne    801849 <memset+0x40>
		c &= 0xFF;
  801829:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  80182c:	89 d3                	mov    %edx,%ebx
  80182e:	c1 e3 08             	shl    $0x8,%ebx
  801831:	89 d6                	mov    %edx,%esi
  801833:	c1 e6 18             	shl    $0x18,%esi
  801836:	89 d0                	mov    %edx,%eax
  801838:	c1 e0 10             	shl    $0x10,%eax
  80183b:	09 f0                	or     %esi,%eax
  80183d:	09 d0                	or     %edx,%eax
  80183f:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  801841:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  801844:	fc                   	cld    
  801845:	f3 ab                	rep stos %eax,%es:(%edi)
  801847:	eb 03                	jmp    80184c <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  801849:	fc                   	cld    
  80184a:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  80184c:	89 f8                	mov    %edi,%eax
  80184e:	5b                   	pop    %ebx
  80184f:	5e                   	pop    %esi
  801850:	5f                   	pop    %edi
  801851:	c9                   	leave  
  801852:	c3                   	ret    

00801853 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  801853:	55                   	push   %ebp
  801854:	89 e5                	mov    %esp,%ebp
  801856:	57                   	push   %edi
  801857:	56                   	push   %esi
  801858:	8b 45 08             	mov    0x8(%ebp),%eax
  80185b:	8b 75 0c             	mov    0xc(%ebp),%esi
  80185e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  801861:	39 c6                	cmp    %eax,%esi
  801863:	73 34                	jae    801899 <memmove+0x46>
  801865:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  801868:	39 d0                	cmp    %edx,%eax
  80186a:	73 2d                	jae    801899 <memmove+0x46>
		s += n;
		d += n;
  80186c:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80186f:	f6 c2 03             	test   $0x3,%dl
  801872:	75 1b                	jne    80188f <memmove+0x3c>
  801874:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80187a:	75 13                	jne    80188f <memmove+0x3c>
  80187c:	f6 c1 03             	test   $0x3,%cl
  80187f:	75 0e                	jne    80188f <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  801881:	83 ef 04             	sub    $0x4,%edi
  801884:	8d 72 fc             	lea    -0x4(%edx),%esi
  801887:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  80188a:	fd                   	std    
  80188b:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80188d:	eb 07                	jmp    801896 <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  80188f:	4f                   	dec    %edi
  801890:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  801893:	fd                   	std    
  801894:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  801896:	fc                   	cld    
  801897:	eb 20                	jmp    8018b9 <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801899:	f7 c6 03 00 00 00    	test   $0x3,%esi
  80189f:	75 13                	jne    8018b4 <memmove+0x61>
  8018a1:	a8 03                	test   $0x3,%al
  8018a3:	75 0f                	jne    8018b4 <memmove+0x61>
  8018a5:	f6 c1 03             	test   $0x3,%cl
  8018a8:	75 0a                	jne    8018b4 <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  8018aa:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  8018ad:	89 c7                	mov    %eax,%edi
  8018af:	fc                   	cld    
  8018b0:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8018b2:	eb 05                	jmp    8018b9 <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8018b4:	89 c7                	mov    %eax,%edi
  8018b6:	fc                   	cld    
  8018b7:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8018b9:	5e                   	pop    %esi
  8018ba:	5f                   	pop    %edi
  8018bb:	c9                   	leave  
  8018bc:	c3                   	ret    

008018bd <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8018bd:	55                   	push   %ebp
  8018be:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  8018c0:	ff 75 10             	pushl  0x10(%ebp)
  8018c3:	ff 75 0c             	pushl  0xc(%ebp)
  8018c6:	ff 75 08             	pushl  0x8(%ebp)
  8018c9:	e8 85 ff ff ff       	call   801853 <memmove>
}
  8018ce:	c9                   	leave  
  8018cf:	c3                   	ret    

008018d0 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8018d0:	55                   	push   %ebp
  8018d1:	89 e5                	mov    %esp,%ebp
  8018d3:	57                   	push   %edi
  8018d4:	56                   	push   %esi
  8018d5:	53                   	push   %ebx
  8018d6:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8018d9:	8b 75 0c             	mov    0xc(%ebp),%esi
  8018dc:	8b 7d 10             	mov    0x10(%ebp),%edi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8018df:	85 ff                	test   %edi,%edi
  8018e1:	74 32                	je     801915 <memcmp+0x45>
		if (*s1 != *s2)
  8018e3:	8a 03                	mov    (%ebx),%al
  8018e5:	8a 0e                	mov    (%esi),%cl
  8018e7:	38 c8                	cmp    %cl,%al
  8018e9:	74 19                	je     801904 <memcmp+0x34>
  8018eb:	eb 0d                	jmp    8018fa <memcmp+0x2a>
  8018ed:	8a 44 13 01          	mov    0x1(%ebx,%edx,1),%al
  8018f1:	8a 4c 16 01          	mov    0x1(%esi,%edx,1),%cl
  8018f5:	42                   	inc    %edx
  8018f6:	38 c8                	cmp    %cl,%al
  8018f8:	74 10                	je     80190a <memcmp+0x3a>
			return (int) *s1 - (int) *s2;
  8018fa:	0f b6 c0             	movzbl %al,%eax
  8018fd:	0f b6 c9             	movzbl %cl,%ecx
  801900:	29 c8                	sub    %ecx,%eax
  801902:	eb 16                	jmp    80191a <memcmp+0x4a>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801904:	4f                   	dec    %edi
  801905:	ba 00 00 00 00       	mov    $0x0,%edx
  80190a:	39 fa                	cmp    %edi,%edx
  80190c:	75 df                	jne    8018ed <memcmp+0x1d>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  80190e:	b8 00 00 00 00       	mov    $0x0,%eax
  801913:	eb 05                	jmp    80191a <memcmp+0x4a>
  801915:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80191a:	5b                   	pop    %ebx
  80191b:	5e                   	pop    %esi
  80191c:	5f                   	pop    %edi
  80191d:	c9                   	leave  
  80191e:	c3                   	ret    

0080191f <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  80191f:	55                   	push   %ebp
  801920:	89 e5                	mov    %esp,%ebp
  801922:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  801925:	89 c2                	mov    %eax,%edx
  801927:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  80192a:	39 d0                	cmp    %edx,%eax
  80192c:	73 12                	jae    801940 <memfind+0x21>
		if (*(const unsigned char *) s == (unsigned char) c)
  80192e:	8a 4d 0c             	mov    0xc(%ebp),%cl
  801931:	38 08                	cmp    %cl,(%eax)
  801933:	75 06                	jne    80193b <memfind+0x1c>
  801935:	eb 09                	jmp    801940 <memfind+0x21>
  801937:	38 08                	cmp    %cl,(%eax)
  801939:	74 05                	je     801940 <memfind+0x21>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  80193b:	40                   	inc    %eax
  80193c:	39 c2                	cmp    %eax,%edx
  80193e:	77 f7                	ja     801937 <memfind+0x18>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  801940:	c9                   	leave  
  801941:	c3                   	ret    

00801942 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  801942:	55                   	push   %ebp
  801943:	89 e5                	mov    %esp,%ebp
  801945:	57                   	push   %edi
  801946:	56                   	push   %esi
  801947:	53                   	push   %ebx
  801948:	8b 55 08             	mov    0x8(%ebp),%edx
  80194b:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  80194e:	eb 01                	jmp    801951 <strtol+0xf>
		s++;
  801950:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801951:	8a 02                	mov    (%edx),%al
  801953:	3c 20                	cmp    $0x20,%al
  801955:	74 f9                	je     801950 <strtol+0xe>
  801957:	3c 09                	cmp    $0x9,%al
  801959:	74 f5                	je     801950 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  80195b:	3c 2b                	cmp    $0x2b,%al
  80195d:	75 08                	jne    801967 <strtol+0x25>
		s++;
  80195f:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  801960:	bf 00 00 00 00       	mov    $0x0,%edi
  801965:	eb 13                	jmp    80197a <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  801967:	3c 2d                	cmp    $0x2d,%al
  801969:	75 0a                	jne    801975 <strtol+0x33>
		s++, neg = 1;
  80196b:	8d 52 01             	lea    0x1(%edx),%edx
  80196e:	bf 01 00 00 00       	mov    $0x1,%edi
  801973:	eb 05                	jmp    80197a <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  801975:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  80197a:	85 db                	test   %ebx,%ebx
  80197c:	74 05                	je     801983 <strtol+0x41>
  80197e:	83 fb 10             	cmp    $0x10,%ebx
  801981:	75 28                	jne    8019ab <strtol+0x69>
  801983:	8a 02                	mov    (%edx),%al
  801985:	3c 30                	cmp    $0x30,%al
  801987:	75 10                	jne    801999 <strtol+0x57>
  801989:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  80198d:	75 0a                	jne    801999 <strtol+0x57>
		s += 2, base = 16;
  80198f:	83 c2 02             	add    $0x2,%edx
  801992:	bb 10 00 00 00       	mov    $0x10,%ebx
  801997:	eb 12                	jmp    8019ab <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  801999:	85 db                	test   %ebx,%ebx
  80199b:	75 0e                	jne    8019ab <strtol+0x69>
  80199d:	3c 30                	cmp    $0x30,%al
  80199f:	75 05                	jne    8019a6 <strtol+0x64>
		s++, base = 8;
  8019a1:	42                   	inc    %edx
  8019a2:	b3 08                	mov    $0x8,%bl
  8019a4:	eb 05                	jmp    8019ab <strtol+0x69>
	else if (base == 0)
		base = 10;
  8019a6:	bb 0a 00 00 00       	mov    $0xa,%ebx
  8019ab:	b8 00 00 00 00       	mov    $0x0,%eax
  8019b0:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  8019b2:	8a 0a                	mov    (%edx),%cl
  8019b4:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  8019b7:	80 fb 09             	cmp    $0x9,%bl
  8019ba:	77 08                	ja     8019c4 <strtol+0x82>
			dig = *s - '0';
  8019bc:	0f be c9             	movsbl %cl,%ecx
  8019bf:	83 e9 30             	sub    $0x30,%ecx
  8019c2:	eb 1e                	jmp    8019e2 <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  8019c4:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  8019c7:	80 fb 19             	cmp    $0x19,%bl
  8019ca:	77 08                	ja     8019d4 <strtol+0x92>
			dig = *s - 'a' + 10;
  8019cc:	0f be c9             	movsbl %cl,%ecx
  8019cf:	83 e9 57             	sub    $0x57,%ecx
  8019d2:	eb 0e                	jmp    8019e2 <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  8019d4:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  8019d7:	80 fb 19             	cmp    $0x19,%bl
  8019da:	77 13                	ja     8019ef <strtol+0xad>
			dig = *s - 'A' + 10;
  8019dc:	0f be c9             	movsbl %cl,%ecx
  8019df:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  8019e2:	39 f1                	cmp    %esi,%ecx
  8019e4:	7d 0d                	jge    8019f3 <strtol+0xb1>
			break;
		s++, val = (val * base) + dig;
  8019e6:	42                   	inc    %edx
  8019e7:	0f af c6             	imul   %esi,%eax
  8019ea:	8d 04 01             	lea    (%ecx,%eax,1),%eax
		// we don't properly detect overflow!
	}
  8019ed:	eb c3                	jmp    8019b2 <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  8019ef:	89 c1                	mov    %eax,%ecx
  8019f1:	eb 02                	jmp    8019f5 <strtol+0xb3>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  8019f3:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  8019f5:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8019f9:	74 05                	je     801a00 <strtol+0xbe>
		*endptr = (char *) s;
  8019fb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8019fe:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  801a00:	85 ff                	test   %edi,%edi
  801a02:	74 04                	je     801a08 <strtol+0xc6>
  801a04:	89 c8                	mov    %ecx,%eax
  801a06:	f7 d8                	neg    %eax
}
  801a08:	5b                   	pop    %ebx
  801a09:	5e                   	pop    %esi
  801a0a:	5f                   	pop    %edi
  801a0b:	c9                   	leave  
  801a0c:	c3                   	ret    
  801a0d:	00 00                	add    %al,(%eax)
	...

00801a10 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801a10:	55                   	push   %ebp
  801a11:	89 e5                	mov    %esp,%ebp
  801a13:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  801a16:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  801a1d:	75 52                	jne    801a71 <set_pgfault_handler+0x61>
		// First time through!	
		// LAB 4: Your code here.

		//int sys_page_alloc(envid_t envid, void *va, int perm)
		r = sys_page_alloc(0, (void*)(UXSTACKTOP - PGSIZE), PTE_U | PTE_W | PTE_P);
  801a1f:	83 ec 04             	sub    $0x4,%esp
  801a22:	6a 07                	push   $0x7
  801a24:	68 00 f0 bf ee       	push   $0xeebff000
  801a29:	6a 00                	push   $0x0
  801a2b:	e8 98 e7 ff ff       	call   8001c8 <sys_page_alloc>
		if (r < 0) {
  801a30:	83 c4 10             	add    $0x10,%esp
  801a33:	85 c0                	test   %eax,%eax
  801a35:	79 12                	jns    801a49 <set_pgfault_handler+0x39>
			panic("sys_page_alloc error : %e\n", r);
  801a37:	50                   	push   %eax
  801a38:	68 bf 22 80 00       	push   $0x8022bf
  801a3d:	6a 24                	push   $0x24
  801a3f:	68 da 22 80 00       	push   $0x8022da
  801a44:	e8 bb f5 ff ff       	call   801004 <_panic>
		}

		// how to know envid, put 0, envid2env will help us to get curenv in syscall
		r = sys_env_set_pgfault_upcall(0, _pgfault_upcall);		
  801a49:	83 ec 08             	sub    $0x8,%esp
  801a4c:	68 08 03 80 00       	push   $0x800308
  801a51:	6a 00                	push   $0x0
  801a53:	e8 23 e8 ff ff       	call   80027b <sys_env_set_pgfault_upcall>
		if (r < 0) {
  801a58:	83 c4 10             	add    $0x10,%esp
  801a5b:	85 c0                	test   %eax,%eax
  801a5d:	79 12                	jns    801a71 <set_pgfault_handler+0x61>
			panic("sys_env_set_pgfault_upcall error : %e\n", r);
  801a5f:	50                   	push   %eax
  801a60:	68 e8 22 80 00       	push   $0x8022e8
  801a65:	6a 2a                	push   $0x2a
  801a67:	68 da 22 80 00       	push   $0x8022da
  801a6c:	e8 93 f5 ff ff       	call   801004 <_panic>
		}
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801a71:	8b 45 08             	mov    0x8(%ebp),%eax
  801a74:	a3 00 60 80 00       	mov    %eax,0x806000
}
  801a79:	c9                   	leave  
  801a7a:	c3                   	ret    
	...

00801a7c <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801a7c:	55                   	push   %ebp
  801a7d:	89 e5                	mov    %esp,%ebp
  801a7f:	57                   	push   %edi
  801a80:	56                   	push   %esi
  801a81:	53                   	push   %ebx
  801a82:	83 ec 0c             	sub    $0xc,%esp
  801a85:	8b 7d 08             	mov    0x8(%ebp),%edi
  801a88:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801a8b:	8b 75 10             	mov    0x10(%ebp),%esi
	// LAB 4: Your code here.
	cprintf("0x%x 0x%x 0x%x\n", (uint32_t)from_env_store, (uint32_t)pg, (uint32_t)perm_store);
  801a8e:	56                   	push   %esi
  801a8f:	53                   	push   %ebx
  801a90:	57                   	push   %edi
  801a91:	68 10 23 80 00       	push   $0x802310
  801a96:	e8 41 f6 ff ff       	call   8010dc <cprintf>
	int r;
	if (pg != NULL) {
  801a9b:	83 c4 10             	add    $0x10,%esp
  801a9e:	85 db                	test   %ebx,%ebx
  801aa0:	74 28                	je     801aca <ipc_recv+0x4e>
		cprintf("BEGIN\n");
  801aa2:	83 ec 0c             	sub    $0xc,%esp
  801aa5:	68 20 23 80 00       	push   $0x802320
  801aaa:	e8 2d f6 ff ff       	call   8010dc <cprintf>
		r = sys_ipc_recv(pg);
  801aaf:	89 1c 24             	mov    %ebx,(%esp)
  801ab2:	e8 0c e8 ff ff       	call   8002c3 <sys_ipc_recv>
  801ab7:	89 c3                	mov    %eax,%ebx
		cprintf("OVER\n");
  801ab9:	c7 04 24 24 1f 80 00 	movl   $0x801f24,(%esp)
  801ac0:	e8 17 f6 ff ff       	call   8010dc <cprintf>
  801ac5:	83 c4 10             	add    $0x10,%esp
  801ac8:	eb 12                	jmp    801adc <ipc_recv+0x60>
	} else {
		r = sys_ipc_recv((void *)UTOP);
  801aca:	83 ec 0c             	sub    $0xc,%esp
  801acd:	68 00 00 c0 ee       	push   $0xeec00000
  801ad2:	e8 ec e7 ff ff       	call   8002c3 <sys_ipc_recv>
  801ad7:	89 c3                	mov    %eax,%ebx
  801ad9:	83 c4 10             	add    $0x10,%esp
	}

	if (r == 0) {
  801adc:	85 db                	test   %ebx,%ebx
  801ade:	75 26                	jne    801b06 <ipc_recv+0x8a>
		if (from_env_store != NULL) *from_env_store = thisenv->env_ipc_from;
  801ae0:	85 ff                	test   %edi,%edi
  801ae2:	74 0a                	je     801aee <ipc_recv+0x72>
  801ae4:	a1 04 40 80 00       	mov    0x804004,%eax
  801ae9:	8b 40 74             	mov    0x74(%eax),%eax
  801aec:	89 07                	mov    %eax,(%edi)
		if (perm_store != NULL) *perm_store = thisenv->env_ipc_perm;
  801aee:	85 f6                	test   %esi,%esi
  801af0:	74 0a                	je     801afc <ipc_recv+0x80>
  801af2:	a1 04 40 80 00       	mov    0x804004,%eax
  801af7:	8b 40 78             	mov    0x78(%eax),%eax
  801afa:	89 06                	mov    %eax,(%esi)
		return thisenv->env_ipc_value;
  801afc:	a1 04 40 80 00       	mov    0x804004,%eax
  801b01:	8b 58 70             	mov    0x70(%eax),%ebx
  801b04:	eb 14                	jmp    801b1a <ipc_recv+0x9e>
	} else {
		// fails;
		if (from_env_store != NULL) *from_env_store = 0;
  801b06:	85 ff                	test   %edi,%edi
  801b08:	74 06                	je     801b10 <ipc_recv+0x94>
  801b0a:	c7 07 00 00 00 00    	movl   $0x0,(%edi)
		if (perm_store != NULL) *perm_store = 0;
  801b10:	85 f6                	test   %esi,%esi
  801b12:	74 06                	je     801b1a <ipc_recv+0x9e>
  801b14:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		return r;
	}
}
  801b1a:	89 d8                	mov    %ebx,%eax
  801b1c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b1f:	5b                   	pop    %ebx
  801b20:	5e                   	pop    %esi
  801b21:	5f                   	pop    %edi
  801b22:	c9                   	leave  
  801b23:	c3                   	ret    

00801b24 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801b24:	55                   	push   %ebp
  801b25:	89 e5                	mov    %esp,%ebp
  801b27:	57                   	push   %edi
  801b28:	56                   	push   %esi
  801b29:	53                   	push   %ebx
  801b2a:	83 ec 0c             	sub    $0xc,%esp
  801b2d:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801b30:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801b33:	8b 75 14             	mov    0x14(%ebp),%esi
	// LAB 4: Your code here.
	// int sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
	int r;
	if (pg == NULL) pg = (void *)UTOP;
  801b36:	85 db                	test   %ebx,%ebx
  801b38:	75 25                	jne    801b5f <ipc_send+0x3b>
  801b3a:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
  801b3f:	eb 1e                	jmp    801b5f <ipc_send+0x3b>
	
	while ((r = sys_ipc_try_send(to_env, val, pg, perm)) != 0) {
		if (r == -E_IPC_NOT_RECV) {
  801b41:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801b44:	75 07                	jne    801b4d <ipc_send+0x29>
			// cprintf("Try Again and Again....\n");
			sys_yield();
  801b46:	e8 56 e6 ff ff       	call   8001a1 <sys_yield>
  801b4b:	eb 12                	jmp    801b5f <ipc_send+0x3b>
		} else {
			panic("ipc_send error %e\n", r);
  801b4d:	50                   	push   %eax
  801b4e:	68 27 23 80 00       	push   $0x802327
  801b53:	6a 45                	push   $0x45
  801b55:	68 3a 23 80 00       	push   $0x80233a
  801b5a:	e8 a5 f4 ff ff       	call   801004 <_panic>
	// LAB 4: Your code here.
	// int sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
	int r;
	if (pg == NULL) pg = (void *)UTOP;
	
	while ((r = sys_ipc_try_send(to_env, val, pg, perm)) != 0) {
  801b5f:	56                   	push   %esi
  801b60:	53                   	push   %ebx
  801b61:	57                   	push   %edi
  801b62:	ff 75 08             	pushl  0x8(%ebp)
  801b65:	e8 34 e7 ff ff       	call   80029e <sys_ipc_try_send>
  801b6a:	83 c4 10             	add    $0x10,%esp
  801b6d:	85 c0                	test   %eax,%eax
  801b6f:	75 d0                	jne    801b41 <ipc_send+0x1d>
		} else {
			panic("ipc_send error %e\n", r);
		}
	}
	return;
}
  801b71:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b74:	5b                   	pop    %ebx
  801b75:	5e                   	pop    %esi
  801b76:	5f                   	pop    %edi
  801b77:	c9                   	leave  
  801b78:	c3                   	ret    

00801b79 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801b79:	55                   	push   %ebp
  801b7a:	89 e5                	mov    %esp,%ebp
  801b7c:	53                   	push   %ebx
  801b7d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	for (i = 0; i < NENV; i++)
		if (envs[i].env_type == type)
  801b80:	39 1d 50 00 c0 ee    	cmp    %ebx,0xeec00050
  801b86:	74 22                	je     801baa <ipc_find_env+0x31>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801b88:	b8 01 00 00 00       	mov    $0x1,%eax
		if (envs[i].env_type == type)
  801b8d:	8d 0c 85 00 00 00 00 	lea    0x0(,%eax,4),%ecx
  801b94:	89 c2                	mov    %eax,%edx
  801b96:	c1 e2 07             	shl    $0x7,%edx
  801b99:	29 ca                	sub    %ecx,%edx
  801b9b:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801ba1:	8b 52 50             	mov    0x50(%edx),%edx
  801ba4:	39 da                	cmp    %ebx,%edx
  801ba6:	75 1d                	jne    801bc5 <ipc_find_env+0x4c>
  801ba8:	eb 05                	jmp    801baf <ipc_find_env+0x36>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801baa:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
			return envs[i].env_id;
  801baf:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  801bb6:	c1 e0 07             	shl    $0x7,%eax
  801bb9:	29 d0                	sub    %edx,%eax
  801bbb:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  801bc0:	8b 40 40             	mov    0x40(%eax),%eax
  801bc3:	eb 0c                	jmp    801bd1 <ipc_find_env+0x58>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801bc5:	40                   	inc    %eax
  801bc6:	3d 00 04 00 00       	cmp    $0x400,%eax
  801bcb:	75 c0                	jne    801b8d <ipc_find_env+0x14>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801bcd:	66 b8 00 00          	mov    $0x0,%ax
}
  801bd1:	5b                   	pop    %ebx
  801bd2:	c9                   	leave  
  801bd3:	c3                   	ret    

00801bd4 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801bd4:	55                   	push   %ebp
  801bd5:	89 e5                	mov    %esp,%ebp
  801bd7:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801bda:	89 c2                	mov    %eax,%edx
  801bdc:	c1 ea 16             	shr    $0x16,%edx
  801bdf:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801be6:	f6 c2 01             	test   $0x1,%dl
  801be9:	74 1e                	je     801c09 <pageref+0x35>
		return 0;
	pte = uvpt[PGNUM(v)];
  801beb:	c1 e8 0c             	shr    $0xc,%eax
  801bee:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  801bf5:	a8 01                	test   $0x1,%al
  801bf7:	74 17                	je     801c10 <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801bf9:	c1 e8 0c             	shr    $0xc,%eax
  801bfc:	66 8b 04 c5 04 00 00 	mov    -0x10fffffc(,%eax,8),%ax
  801c03:	ef 
  801c04:	0f b7 c0             	movzwl %ax,%eax
  801c07:	eb 0c                	jmp    801c15 <pageref+0x41>
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
		return 0;
  801c09:	b8 00 00 00 00       	mov    $0x0,%eax
  801c0e:	eb 05                	jmp    801c15 <pageref+0x41>
	pte = uvpt[PGNUM(v)];
	if (!(pte & PTE_P))
		return 0;
  801c10:	b8 00 00 00 00       	mov    $0x0,%eax
	return pages[PGNUM(pte)].pp_ref;
}
  801c15:	c9                   	leave  
  801c16:	c3                   	ret    
	...

00801c18 <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  801c18:	55                   	push   %ebp
  801c19:	89 e5                	mov    %esp,%ebp
  801c1b:	57                   	push   %edi
  801c1c:	56                   	push   %esi
  801c1d:	83 ec 10             	sub    $0x10,%esp
  801c20:	8b 7d 08             	mov    0x8(%ebp),%edi
  801c23:	8b 4d 10             	mov    0x10(%ebp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  801c26:	89 7d f0             	mov    %edi,-0x10(%ebp)
  801c29:	8b 75 0c             	mov    0xc(%ebp),%esi
  const DWunion dd = {.ll = d};
  801c2c:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  801c2f:	8b 45 14             	mov    0x14(%ebp),%eax
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  801c32:	85 c0                	test   %eax,%eax
  801c34:	75 2e                	jne    801c64 <__udivdi3+0x4c>
    {
      if (d0 > n1)
  801c36:	39 f1                	cmp    %esi,%ecx
  801c38:	77 5a                	ja     801c94 <__udivdi3+0x7c>
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  801c3a:	85 c9                	test   %ecx,%ecx
  801c3c:	75 0b                	jne    801c49 <__udivdi3+0x31>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  801c3e:	b8 01 00 00 00       	mov    $0x1,%eax
  801c43:	31 d2                	xor    %edx,%edx
  801c45:	f7 f1                	div    %ecx
  801c47:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  801c49:	31 d2                	xor    %edx,%edx
  801c4b:	89 f0                	mov    %esi,%eax
  801c4d:	f7 f1                	div    %ecx
  801c4f:	89 c6                	mov    %eax,%esi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801c51:	89 f8                	mov    %edi,%eax
  801c53:	f7 f1                	div    %ecx
  801c55:	89 c7                	mov    %eax,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  801c57:	89 f8                	mov    %edi,%eax
  801c59:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801c5b:	83 c4 10             	add    $0x10,%esp
  801c5e:	5e                   	pop    %esi
  801c5f:	5f                   	pop    %edi
  801c60:	c9                   	leave  
  801c61:	c3                   	ret    
  801c62:	66 90                	xchg   %ax,%ax
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  801c64:	39 f0                	cmp    %esi,%eax
  801c66:	77 1c                	ja     801c84 <__udivdi3+0x6c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  801c68:	0f bd f8             	bsr    %eax,%edi
	  if (bm == 0)
  801c6b:	83 f7 1f             	xor    $0x1f,%edi
  801c6e:	75 3c                	jne    801cac <__udivdi3+0x94>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  801c70:	39 f0                	cmp    %esi,%eax
  801c72:	0f 82 90 00 00 00    	jb     801d08 <__udivdi3+0xf0>
  801c78:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801c7b:	39 55 f4             	cmp    %edx,-0xc(%ebp)
  801c7e:	0f 86 84 00 00 00    	jbe    801d08 <__udivdi3+0xf0>
  801c84:	31 f6                	xor    %esi,%esi
  801c86:	31 ff                	xor    %edi,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  801c88:	89 f8                	mov    %edi,%eax
  801c8a:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801c8c:	83 c4 10             	add    $0x10,%esp
  801c8f:	5e                   	pop    %esi
  801c90:	5f                   	pop    %edi
  801c91:	c9                   	leave  
  801c92:	c3                   	ret    
  801c93:	90                   	nop
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801c94:	89 f2                	mov    %esi,%edx
  801c96:	89 f8                	mov    %edi,%eax
  801c98:	f7 f1                	div    %ecx
  801c9a:	89 c7                	mov    %eax,%edi
  801c9c:	31 f6                	xor    %esi,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  801c9e:	89 f8                	mov    %edi,%eax
  801ca0:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801ca2:	83 c4 10             	add    $0x10,%esp
  801ca5:	5e                   	pop    %esi
  801ca6:	5f                   	pop    %edi
  801ca7:	c9                   	leave  
  801ca8:	c3                   	ret    
  801ca9:	8d 76 00             	lea    0x0(%esi),%esi
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  801cac:	89 f9                	mov    %edi,%ecx
  801cae:	d3 e0                	shl    %cl,%eax
  801cb0:	89 45 e8             	mov    %eax,-0x18(%ebp)
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  801cb3:	b8 20 00 00 00       	mov    $0x20,%eax
  801cb8:	29 f8                	sub    %edi,%eax

	      d1 = (d1 << bm) | (d0 >> b);
  801cba:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801cbd:	88 c1                	mov    %al,%cl
  801cbf:	d3 ea                	shr    %cl,%edx
  801cc1:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  801cc4:	09 ca                	or     %ecx,%edx
  801cc6:	89 55 ec             	mov    %edx,-0x14(%ebp)
	      d0 = d0 << bm;
  801cc9:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801ccc:	89 f9                	mov    %edi,%ecx
  801cce:	d3 e2                	shl    %cl,%edx
  801cd0:	89 55 f4             	mov    %edx,-0xc(%ebp)
	      n2 = n1 >> b;
  801cd3:	89 f2                	mov    %esi,%edx
  801cd5:	88 c1                	mov    %al,%cl
  801cd7:	d3 ea                	shr    %cl,%edx
  801cd9:	89 55 e8             	mov    %edx,-0x18(%ebp)
	      n1 = (n1 << bm) | (n0 >> b);
  801cdc:	89 f2                	mov    %esi,%edx
  801cde:	89 f9                	mov    %edi,%ecx
  801ce0:	d3 e2                	shl    %cl,%edx
  801ce2:	8b 75 f0             	mov    -0x10(%ebp),%esi
  801ce5:	88 c1                	mov    %al,%cl
  801ce7:	d3 ee                	shr    %cl,%esi
  801ce9:	09 d6                	or     %edx,%esi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  801ceb:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  801cee:	89 f0                	mov    %esi,%eax
  801cf0:	89 ca                	mov    %ecx,%edx
  801cf2:	f7 75 ec             	divl   -0x14(%ebp)
  801cf5:	89 d1                	mov    %edx,%ecx
  801cf7:	89 c6                	mov    %eax,%esi
	      umul_ppmm (m1, m0, q0, d0);
  801cf9:	f7 65 f4             	mull   -0xc(%ebp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801cfc:	39 d1                	cmp    %edx,%ecx
  801cfe:	72 28                	jb     801d28 <__udivdi3+0x110>
  801d00:	74 1a                	je     801d1c <__udivdi3+0x104>
  801d02:	89 f7                	mov    %esi,%edi
  801d04:	31 f6                	xor    %esi,%esi
  801d06:	eb 80                	jmp    801c88 <__udivdi3+0x70>
	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  801d08:	31 f6                	xor    %esi,%esi
  801d0a:	bf 01 00 00 00       	mov    $0x1,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  801d0f:	89 f8                	mov    %edi,%eax
  801d11:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801d13:	83 c4 10             	add    $0x10,%esp
  801d16:	5e                   	pop    %esi
  801d17:	5f                   	pop    %edi
  801d18:	c9                   	leave  
  801d19:	c3                   	ret    
  801d1a:	66 90                	xchg   %ax,%ax

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  801d1c:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801d1f:	89 f9                	mov    %edi,%ecx
  801d21:	d3 e2                	shl    %cl,%edx

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801d23:	39 c2                	cmp    %eax,%edx
  801d25:	73 db                	jae    801d02 <__udivdi3+0xea>
  801d27:	90                   	nop
		{
		  q0--;
  801d28:	8d 7e ff             	lea    -0x1(%esi),%edi
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  801d2b:	31 f6                	xor    %esi,%esi
  801d2d:	e9 56 ff ff ff       	jmp    801c88 <__udivdi3+0x70>
	...

00801d34 <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  801d34:	55                   	push   %ebp
  801d35:	89 e5                	mov    %esp,%ebp
  801d37:	57                   	push   %edi
  801d38:	56                   	push   %esi
  801d39:	83 ec 20             	sub    $0x20,%esp
  801d3c:	8b 45 08             	mov    0x8(%ebp),%eax
  801d3f:	8b 4d 10             	mov    0x10(%ebp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  801d42:	89 45 e8             	mov    %eax,-0x18(%ebp)
  801d45:	8b 75 0c             	mov    0xc(%ebp),%esi
  const DWunion dd = {.ll = d};
  801d48:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  801d4b:	8b 7d 14             	mov    0x14(%ebp),%edi
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  801d4e:	89 45 f0             	mov    %eax,-0x10(%ebp)
  n1 = nn.s.high;
  801d51:	89 f2                	mov    %esi,%edx

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  801d53:	85 ff                	test   %edi,%edi
  801d55:	75 15                	jne    801d6c <__umoddi3+0x38>
    {
      if (d0 > n1)
  801d57:	39 f1                	cmp    %esi,%ecx
  801d59:	0f 86 99 00 00 00    	jbe    801df8 <__umoddi3+0xc4>
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801d5f:	f7 f1                	div    %ecx

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
  801d61:	89 d0                	mov    %edx,%eax
  801d63:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  801d65:	83 c4 20             	add    $0x20,%esp
  801d68:	5e                   	pop    %esi
  801d69:	5f                   	pop    %edi
  801d6a:	c9                   	leave  
  801d6b:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  801d6c:	39 f7                	cmp    %esi,%edi
  801d6e:	0f 87 a4 00 00 00    	ja     801e18 <__umoddi3+0xe4>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  801d74:	0f bd c7             	bsr    %edi,%eax
	  if (bm == 0)
  801d77:	83 f0 1f             	xor    $0x1f,%eax
  801d7a:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801d7d:	0f 84 a1 00 00 00    	je     801e24 <__umoddi3+0xf0>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  801d83:	89 f8                	mov    %edi,%eax
  801d85:	8a 4d ec             	mov    -0x14(%ebp),%cl
  801d88:	d3 e0                	shl    %cl,%eax
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  801d8a:	bf 20 00 00 00       	mov    $0x20,%edi
  801d8f:	2b 7d ec             	sub    -0x14(%ebp),%edi

	      d1 = (d1 << bm) | (d0 >> b);
  801d92:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801d95:	89 f9                	mov    %edi,%ecx
  801d97:	d3 ea                	shr    %cl,%edx
  801d99:	09 c2                	or     %eax,%edx
  801d9b:	89 55 f0             	mov    %edx,-0x10(%ebp)
	      d0 = d0 << bm;
  801d9e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801da1:	8a 4d ec             	mov    -0x14(%ebp),%cl
  801da4:	d3 e0                	shl    %cl,%eax
  801da6:	89 45 f4             	mov    %eax,-0xc(%ebp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  801da9:	89 f2                	mov    %esi,%edx
  801dab:	d3 e2                	shl    %cl,%edx
	      n0 = n0 << bm;
  801dad:	8b 45 e8             	mov    -0x18(%ebp),%eax
  801db0:	d3 e0                	shl    %cl,%eax
  801db2:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  801db5:	8b 45 e8             	mov    -0x18(%ebp),%eax
  801db8:	89 f9                	mov    %edi,%ecx
  801dba:	d3 e8                	shr    %cl,%eax
  801dbc:	09 d0                	or     %edx,%eax

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  801dbe:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  801dc0:	89 f2                	mov    %esi,%edx
  801dc2:	f7 75 f0             	divl   -0x10(%ebp)
  801dc5:	89 d6                	mov    %edx,%esi
	      umul_ppmm (m1, m0, q0, d0);
  801dc7:	f7 65 f4             	mull   -0xc(%ebp)
  801dca:	89 55 e8             	mov    %edx,-0x18(%ebp)
  801dcd:	89 c1                	mov    %eax,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801dcf:	39 d6                	cmp    %edx,%esi
  801dd1:	72 71                	jb     801e44 <__umoddi3+0x110>
  801dd3:	74 7f                	je     801e54 <__umoddi3+0x120>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  801dd5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801dd8:	29 c8                	sub    %ecx,%eax
  801dda:	19 d6                	sbb    %edx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
  801ddc:	8a 4d ec             	mov    -0x14(%ebp),%cl
  801ddf:	d3 e8                	shr    %cl,%eax
  801de1:	89 f2                	mov    %esi,%edx
  801de3:	89 f9                	mov    %edi,%ecx
  801de5:	d3 e2                	shl    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
  801de7:	09 d0                	or     %edx,%eax
  801de9:	89 f2                	mov    %esi,%edx
  801deb:	8a 4d ec             	mov    -0x14(%ebp),%cl
  801dee:	d3 ea                	shr    %cl,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  801df0:	83 c4 20             	add    $0x20,%esp
  801df3:	5e                   	pop    %esi
  801df4:	5f                   	pop    %edi
  801df5:	c9                   	leave  
  801df6:	c3                   	ret    
  801df7:	90                   	nop
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  801df8:	85 c9                	test   %ecx,%ecx
  801dfa:	75 0b                	jne    801e07 <__umoddi3+0xd3>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  801dfc:	b8 01 00 00 00       	mov    $0x1,%eax
  801e01:	31 d2                	xor    %edx,%edx
  801e03:	f7 f1                	div    %ecx
  801e05:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  801e07:	89 f0                	mov    %esi,%eax
  801e09:	31 d2                	xor    %edx,%edx
  801e0b:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801e0d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801e10:	f7 f1                	div    %ecx
  801e12:	e9 4a ff ff ff       	jmp    801d61 <__umoddi3+0x2d>
  801e17:	90                   	nop
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
  801e18:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  801e1a:	83 c4 20             	add    $0x20,%esp
  801e1d:	5e                   	pop    %esi
  801e1e:	5f                   	pop    %edi
  801e1f:	c9                   	leave  
  801e20:	c3                   	ret    
  801e21:	8d 76 00             	lea    0x0(%esi),%esi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  801e24:	39 f7                	cmp    %esi,%edi
  801e26:	72 05                	jb     801e2d <__umoddi3+0xf9>
  801e28:	3b 4d f0             	cmp    -0x10(%ebp),%ecx
  801e2b:	77 0c                	ja     801e39 <__umoddi3+0x105>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  801e2d:	89 f2                	mov    %esi,%edx
  801e2f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801e32:	29 c8                	sub    %ecx,%eax
  801e34:	19 fa                	sbb    %edi,%edx
  801e36:	89 45 f0             	mov    %eax,-0x10(%ebp)

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
  801e39:	8b 45 f0             	mov    -0x10(%ebp),%eax
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  801e3c:	83 c4 20             	add    $0x20,%esp
  801e3f:	5e                   	pop    %esi
  801e40:	5f                   	pop    %edi
  801e41:	c9                   	leave  
  801e42:	c3                   	ret    
  801e43:	90                   	nop
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  801e44:	8b 55 e8             	mov    -0x18(%ebp),%edx
  801e47:	89 c1                	mov    %eax,%ecx
  801e49:	2b 4d f4             	sub    -0xc(%ebp),%ecx
  801e4c:	1b 55 f0             	sbb    -0x10(%ebp),%edx
  801e4f:	eb 84                	jmp    801dd5 <__umoddi3+0xa1>
  801e51:	8d 76 00             	lea    0x0(%esi),%esi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801e54:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  801e57:	72 eb                	jb     801e44 <__umoddi3+0x110>
  801e59:	89 f2                	mov    %esi,%edx
  801e5b:	e9 75 ff ff ff       	jmp    801dd5 <__umoddi3+0xa1>
