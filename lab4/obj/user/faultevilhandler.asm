
obj/user/faultevilhandler:     file format elf32-i386


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
  800043:	e8 80 01 00 00       	call   8001c8 <sys_page_alloc>
	sys_env_set_pgfault_upcall(0, (void*) 0xF0100020);
  800048:	83 c4 08             	add    $0x8,%esp
  80004b:	68 20 00 10 f0       	push   $0xf0100020
  800050:	6a 00                	push   $0x0
  800052:	e8 01 02 00 00       	call   800258 <sys_env_set_pgfault_upcall>
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
  800073:	e8 05 01 00 00       	call   80017d <sys_getenvid>
  800078:	25 ff 03 00 00       	and    $0x3ff,%eax
  80007d:	c1 e0 07             	shl    $0x7,%eax
  800080:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800085:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80008a:	85 f6                	test   %esi,%esi
  80008c:	7e 07                	jle    800095 <libmain+0x2d>
		binaryname = argv[0];
  80008e:	8b 03                	mov    (%ebx),%eax
  800090:	a3 00 20 80 00       	mov    %eax,0x802000
	// call user main routine
	umain(argc, argv);
  800095:	83 ec 08             	sub    $0x8,%esp
  800098:	53                   	push   %ebx
  800099:	56                   	push   %esi
  80009a:	e8 95 ff ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  80009f:	e8 0c 00 00 00       	call   8000b0 <exit>
  8000a4:	83 c4 10             	add    $0x10,%esp
}
  8000a7:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000aa:	5b                   	pop    %ebx
  8000ab:	5e                   	pop    %esi
  8000ac:	c9                   	leave  
  8000ad:	c3                   	ret    
	...

008000b0 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000b0:	55                   	push   %ebp
  8000b1:	89 e5                	mov    %esp,%ebp
  8000b3:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
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
  8000f6:	68 4a 0f 80 00       	push   $0x800f4a
  8000fb:	6a 42                	push   $0x42
  8000fd:	68 67 0f 80 00       	push   $0x800f67
  800102:	e8 e1 01 00 00       	call   8002e8 <_panic>

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
  8001b9:	b8 0a 00 00 00       	mov    $0xa,%eax
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

00800258 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800258:	55                   	push   %ebp
  800259:	89 e5                	mov    %esp,%ebp
  80025b:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
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

0080027b <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  80027b:	55                   	push   %ebp
  80027c:	89 e5                	mov    %esp,%ebp
  80027e:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
  800281:	6a 00                	push   $0x0
  800283:	ff 75 14             	pushl  0x14(%ebp)
  800286:	ff 75 10             	pushl  0x10(%ebp)
  800289:	ff 75 0c             	pushl  0xc(%ebp)
  80028c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80028f:	ba 00 00 00 00       	mov    $0x0,%edx
  800294:	b8 0b 00 00 00       	mov    $0xb,%eax
  800299:	e8 26 fe ff ff       	call   8000c4 <syscall>
}
  80029e:	c9                   	leave  
  80029f:	c3                   	ret    

008002a0 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  8002a0:	55                   	push   %ebp
  8002a1:	89 e5                	mov    %esp,%ebp
  8002a3:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
  8002a6:	6a 00                	push   $0x0
  8002a8:	6a 00                	push   $0x0
  8002aa:	6a 00                	push   $0x0
  8002ac:	6a 00                	push   $0x0
  8002ae:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8002b1:	ba 01 00 00 00       	mov    $0x1,%edx
  8002b6:	b8 0c 00 00 00       	mov    $0xc,%eax
  8002bb:	e8 04 fe ff ff       	call   8000c4 <syscall>
}
  8002c0:	c9                   	leave  
  8002c1:	c3                   	ret    

008002c2 <sys_set_priority>:

int
sys_set_priority(envid_t envid, uint32_t new_priority)
{
  8002c2:	55                   	push   %ebp
  8002c3:	89 e5                	mov    %esp,%ebp
  8002c5:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_set_priority, 0, envid, new_priority, 0, 0, 0);
  8002c8:	6a 00                	push   $0x0
  8002ca:	6a 00                	push   $0x0
  8002cc:	6a 00                	push   $0x0
  8002ce:	ff 75 0c             	pushl  0xc(%ebp)
  8002d1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8002d4:	ba 00 00 00 00       	mov    $0x0,%edx
  8002d9:	b8 0d 00 00 00       	mov    $0xd,%eax
  8002de:	e8 e1 fd ff ff       	call   8000c4 <syscall>
}
  8002e3:	c9                   	leave  
  8002e4:	c3                   	ret    
  8002e5:	00 00                	add    %al,(%eax)
	...

008002e8 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8002e8:	55                   	push   %ebp
  8002e9:	89 e5                	mov    %esp,%ebp
  8002eb:	56                   	push   %esi
  8002ec:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  8002ed:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8002f0:	8b 1d 00 20 80 00    	mov    0x802000,%ebx
  8002f6:	e8 82 fe ff ff       	call   80017d <sys_getenvid>
  8002fb:	83 ec 0c             	sub    $0xc,%esp
  8002fe:	ff 75 0c             	pushl  0xc(%ebp)
  800301:	ff 75 08             	pushl  0x8(%ebp)
  800304:	53                   	push   %ebx
  800305:	50                   	push   %eax
  800306:	68 78 0f 80 00       	push   $0x800f78
  80030b:	e8 b0 00 00 00       	call   8003c0 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800310:	83 c4 18             	add    $0x18,%esp
  800313:	56                   	push   %esi
  800314:	ff 75 10             	pushl  0x10(%ebp)
  800317:	e8 53 00 00 00       	call   80036f <vcprintf>
	cprintf("\n");
  80031c:	c7 04 24 9c 0f 80 00 	movl   $0x800f9c,(%esp)
  800323:	e8 98 00 00 00       	call   8003c0 <cprintf>
  800328:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80032b:	cc                   	int3   
  80032c:	eb fd                	jmp    80032b <_panic+0x43>
	...

00800330 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800330:	55                   	push   %ebp
  800331:	89 e5                	mov    %esp,%ebp
  800333:	53                   	push   %ebx
  800334:	83 ec 04             	sub    $0x4,%esp
  800337:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80033a:	8b 03                	mov    (%ebx),%eax
  80033c:	8b 55 08             	mov    0x8(%ebp),%edx
  80033f:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  800343:	40                   	inc    %eax
  800344:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  800346:	3d ff 00 00 00       	cmp    $0xff,%eax
  80034b:	75 1a                	jne    800367 <putch+0x37>
		sys_cputs(b->buf, b->idx);
  80034d:	83 ec 08             	sub    $0x8,%esp
  800350:	68 ff 00 00 00       	push   $0xff
  800355:	8d 43 08             	lea    0x8(%ebx),%eax
  800358:	50                   	push   %eax
  800359:	e8 b3 fd ff ff       	call   800111 <sys_cputs>
		b->idx = 0;
  80035e:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800364:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  800367:	ff 43 04             	incl   0x4(%ebx)
}
  80036a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80036d:	c9                   	leave  
  80036e:	c3                   	ret    

0080036f <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80036f:	55                   	push   %ebp
  800370:	89 e5                	mov    %esp,%ebp
  800372:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800378:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80037f:	00 00 00 
	b.cnt = 0;
  800382:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800389:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80038c:	ff 75 0c             	pushl  0xc(%ebp)
  80038f:	ff 75 08             	pushl  0x8(%ebp)
  800392:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800398:	50                   	push   %eax
  800399:	68 30 03 80 00       	push   $0x800330
  80039e:	e8 82 01 00 00       	call   800525 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8003a3:	83 c4 08             	add    $0x8,%esp
  8003a6:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8003ac:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8003b2:	50                   	push   %eax
  8003b3:	e8 59 fd ff ff       	call   800111 <sys_cputs>

	return b.cnt;
}
  8003b8:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8003be:	c9                   	leave  
  8003bf:	c3                   	ret    

008003c0 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8003c0:	55                   	push   %ebp
  8003c1:	89 e5                	mov    %esp,%ebp
  8003c3:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8003c6:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8003c9:	50                   	push   %eax
  8003ca:	ff 75 08             	pushl  0x8(%ebp)
  8003cd:	e8 9d ff ff ff       	call   80036f <vcprintf>
	va_end(ap);

	return cnt;
}
  8003d2:	c9                   	leave  
  8003d3:	c3                   	ret    

008003d4 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8003d4:	55                   	push   %ebp
  8003d5:	89 e5                	mov    %esp,%ebp
  8003d7:	57                   	push   %edi
  8003d8:	56                   	push   %esi
  8003d9:	53                   	push   %ebx
  8003da:	83 ec 2c             	sub    $0x2c,%esp
  8003dd:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8003e0:	89 d6                	mov    %edx,%esi
  8003e2:	8b 45 08             	mov    0x8(%ebp),%eax
  8003e5:	8b 55 0c             	mov    0xc(%ebp),%edx
  8003e8:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8003eb:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8003ee:	8b 45 10             	mov    0x10(%ebp),%eax
  8003f1:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8003f4:	8b 7d 18             	mov    0x18(%ebp),%edi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8003f7:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8003fa:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  800401:	39 55 d4             	cmp    %edx,-0x2c(%ebp)
  800404:	72 0c                	jb     800412 <printnum+0x3e>
  800406:	3b 45 d8             	cmp    -0x28(%ebp),%eax
  800409:	76 07                	jbe    800412 <printnum+0x3e>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80040b:	4b                   	dec    %ebx
  80040c:	85 db                	test   %ebx,%ebx
  80040e:	7f 31                	jg     800441 <printnum+0x6d>
  800410:	eb 3f                	jmp    800451 <printnum+0x7d>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800412:	83 ec 0c             	sub    $0xc,%esp
  800415:	57                   	push   %edi
  800416:	4b                   	dec    %ebx
  800417:	53                   	push   %ebx
  800418:	50                   	push   %eax
  800419:	83 ec 08             	sub    $0x8,%esp
  80041c:	ff 75 d4             	pushl  -0x2c(%ebp)
  80041f:	ff 75 d0             	pushl  -0x30(%ebp)
  800422:	ff 75 dc             	pushl  -0x24(%ebp)
  800425:	ff 75 d8             	pushl  -0x28(%ebp)
  800428:	e8 c7 08 00 00       	call   800cf4 <__udivdi3>
  80042d:	83 c4 18             	add    $0x18,%esp
  800430:	52                   	push   %edx
  800431:	50                   	push   %eax
  800432:	89 f2                	mov    %esi,%edx
  800434:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800437:	e8 98 ff ff ff       	call   8003d4 <printnum>
  80043c:	83 c4 20             	add    $0x20,%esp
  80043f:	eb 10                	jmp    800451 <printnum+0x7d>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800441:	83 ec 08             	sub    $0x8,%esp
  800444:	56                   	push   %esi
  800445:	57                   	push   %edi
  800446:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800449:	4b                   	dec    %ebx
  80044a:	83 c4 10             	add    $0x10,%esp
  80044d:	85 db                	test   %ebx,%ebx
  80044f:	7f f0                	jg     800441 <printnum+0x6d>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800451:	83 ec 08             	sub    $0x8,%esp
  800454:	56                   	push   %esi
  800455:	83 ec 04             	sub    $0x4,%esp
  800458:	ff 75 d4             	pushl  -0x2c(%ebp)
  80045b:	ff 75 d0             	pushl  -0x30(%ebp)
  80045e:	ff 75 dc             	pushl  -0x24(%ebp)
  800461:	ff 75 d8             	pushl  -0x28(%ebp)
  800464:	e8 a7 09 00 00       	call   800e10 <__umoddi3>
  800469:	83 c4 14             	add    $0x14,%esp
  80046c:	0f be 80 9e 0f 80 00 	movsbl 0x800f9e(%eax),%eax
  800473:	50                   	push   %eax
  800474:	ff 55 e4             	call   *-0x1c(%ebp)
  800477:	83 c4 10             	add    $0x10,%esp
}
  80047a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80047d:	5b                   	pop    %ebx
  80047e:	5e                   	pop    %esi
  80047f:	5f                   	pop    %edi
  800480:	c9                   	leave  
  800481:	c3                   	ret    

00800482 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800482:	55                   	push   %ebp
  800483:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800485:	83 fa 01             	cmp    $0x1,%edx
  800488:	7e 0e                	jle    800498 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80048a:	8b 10                	mov    (%eax),%edx
  80048c:	8d 4a 08             	lea    0x8(%edx),%ecx
  80048f:	89 08                	mov    %ecx,(%eax)
  800491:	8b 02                	mov    (%edx),%eax
  800493:	8b 52 04             	mov    0x4(%edx),%edx
  800496:	eb 22                	jmp    8004ba <getuint+0x38>
	else if (lflag)
  800498:	85 d2                	test   %edx,%edx
  80049a:	74 10                	je     8004ac <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  80049c:	8b 10                	mov    (%eax),%edx
  80049e:	8d 4a 04             	lea    0x4(%edx),%ecx
  8004a1:	89 08                	mov    %ecx,(%eax)
  8004a3:	8b 02                	mov    (%edx),%eax
  8004a5:	ba 00 00 00 00       	mov    $0x0,%edx
  8004aa:	eb 0e                	jmp    8004ba <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8004ac:	8b 10                	mov    (%eax),%edx
  8004ae:	8d 4a 04             	lea    0x4(%edx),%ecx
  8004b1:	89 08                	mov    %ecx,(%eax)
  8004b3:	8b 02                	mov    (%edx),%eax
  8004b5:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8004ba:	c9                   	leave  
  8004bb:	c3                   	ret    

008004bc <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
  8004bc:	55                   	push   %ebp
  8004bd:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8004bf:	83 fa 01             	cmp    $0x1,%edx
  8004c2:	7e 0e                	jle    8004d2 <getint+0x16>
		return va_arg(*ap, long long);
  8004c4:	8b 10                	mov    (%eax),%edx
  8004c6:	8d 4a 08             	lea    0x8(%edx),%ecx
  8004c9:	89 08                	mov    %ecx,(%eax)
  8004cb:	8b 02                	mov    (%edx),%eax
  8004cd:	8b 52 04             	mov    0x4(%edx),%edx
  8004d0:	eb 1a                	jmp    8004ec <getint+0x30>
	else if (lflag)
  8004d2:	85 d2                	test   %edx,%edx
  8004d4:	74 0c                	je     8004e2 <getint+0x26>
		return va_arg(*ap, long);
  8004d6:	8b 10                	mov    (%eax),%edx
  8004d8:	8d 4a 04             	lea    0x4(%edx),%ecx
  8004db:	89 08                	mov    %ecx,(%eax)
  8004dd:	8b 02                	mov    (%edx),%eax
  8004df:	99                   	cltd   
  8004e0:	eb 0a                	jmp    8004ec <getint+0x30>
	else
		return va_arg(*ap, int);
  8004e2:	8b 10                	mov    (%eax),%edx
  8004e4:	8d 4a 04             	lea    0x4(%edx),%ecx
  8004e7:	89 08                	mov    %ecx,(%eax)
  8004e9:	8b 02                	mov    (%edx),%eax
  8004eb:	99                   	cltd   
}
  8004ec:	c9                   	leave  
  8004ed:	c3                   	ret    

008004ee <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8004ee:	55                   	push   %ebp
  8004ef:	89 e5                	mov    %esp,%ebp
  8004f1:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8004f4:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  8004f7:	8b 10                	mov    (%eax),%edx
  8004f9:	3b 50 04             	cmp    0x4(%eax),%edx
  8004fc:	73 08                	jae    800506 <sprintputch+0x18>
		*b->buf++ = ch;
  8004fe:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800501:	88 0a                	mov    %cl,(%edx)
  800503:	42                   	inc    %edx
  800504:	89 10                	mov    %edx,(%eax)
}
  800506:	c9                   	leave  
  800507:	c3                   	ret    

00800508 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800508:	55                   	push   %ebp
  800509:	89 e5                	mov    %esp,%ebp
  80050b:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  80050e:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800511:	50                   	push   %eax
  800512:	ff 75 10             	pushl  0x10(%ebp)
  800515:	ff 75 0c             	pushl  0xc(%ebp)
  800518:	ff 75 08             	pushl  0x8(%ebp)
  80051b:	e8 05 00 00 00       	call   800525 <vprintfmt>
	va_end(ap);
  800520:	83 c4 10             	add    $0x10,%esp
}
  800523:	c9                   	leave  
  800524:	c3                   	ret    

00800525 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800525:	55                   	push   %ebp
  800526:	89 e5                	mov    %esp,%ebp
  800528:	57                   	push   %edi
  800529:	56                   	push   %esi
  80052a:	53                   	push   %ebx
  80052b:	83 ec 2c             	sub    $0x2c,%esp
  80052e:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800531:	8b 75 10             	mov    0x10(%ebp),%esi
  800534:	eb 13                	jmp    800549 <vprintfmt+0x24>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800536:	85 c0                	test   %eax,%eax
  800538:	0f 84 6d 03 00 00    	je     8008ab <vprintfmt+0x386>
				return;
			putch(ch, putdat);
  80053e:	83 ec 08             	sub    $0x8,%esp
  800541:	57                   	push   %edi
  800542:	50                   	push   %eax
  800543:	ff 55 08             	call   *0x8(%ebp)
  800546:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800549:	0f b6 06             	movzbl (%esi),%eax
  80054c:	46                   	inc    %esi
  80054d:	83 f8 25             	cmp    $0x25,%eax
  800550:	75 e4                	jne    800536 <vprintfmt+0x11>
  800552:	c6 45 dc 20          	movb   $0x20,-0x24(%ebp)
  800556:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  80055d:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
  800564:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  80056b:	b9 00 00 00 00       	mov    $0x0,%ecx
  800570:	eb 28                	jmp    80059a <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800572:	89 de                	mov    %ebx,%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  800574:	c6 45 dc 2d          	movb   $0x2d,-0x24(%ebp)
  800578:	eb 20                	jmp    80059a <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80057a:	89 de                	mov    %ebx,%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  80057c:	c6 45 dc 30          	movb   $0x30,-0x24(%ebp)
  800580:	eb 18                	jmp    80059a <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800582:	89 de                	mov    %ebx,%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  800584:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  80058b:	eb 0d                	jmp    80059a <vprintfmt+0x75>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  80058d:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  800590:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800593:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80059a:	8a 06                	mov    (%esi),%al
  80059c:	0f b6 d0             	movzbl %al,%edx
  80059f:	8d 5e 01             	lea    0x1(%esi),%ebx
  8005a2:	83 e8 23             	sub    $0x23,%eax
  8005a5:	3c 55                	cmp    $0x55,%al
  8005a7:	0f 87 e0 02 00 00    	ja     80088d <vprintfmt+0x368>
  8005ad:	0f b6 c0             	movzbl %al,%eax
  8005b0:	ff 24 85 60 10 80 00 	jmp    *0x801060(,%eax,4)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8005b7:	83 ea 30             	sub    $0x30,%edx
  8005ba:	89 55 d4             	mov    %edx,-0x2c(%ebp)
				ch = *fmt;
  8005bd:	0f be 03             	movsbl (%ebx),%eax
				if (ch < '0' || ch > '9')
  8005c0:	8d 50 d0             	lea    -0x30(%eax),%edx
  8005c3:	83 fa 09             	cmp    $0x9,%edx
  8005c6:	77 44                	ja     80060c <vprintfmt+0xe7>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005c8:	89 de                	mov    %ebx,%esi
  8005ca:	8b 55 d4             	mov    -0x2c(%ebp),%edx
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8005cd:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
  8005ce:	8d 14 92             	lea    (%edx,%edx,4),%edx
  8005d1:	8d 54 50 d0          	lea    -0x30(%eax,%edx,2),%edx
				ch = *fmt;
  8005d5:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  8005d8:	8d 58 d0             	lea    -0x30(%eax),%ebx
  8005db:	83 fb 09             	cmp    $0x9,%ebx
  8005de:	76 ed                	jbe    8005cd <vprintfmt+0xa8>
  8005e0:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  8005e3:	eb 29                	jmp    80060e <vprintfmt+0xe9>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8005e5:	8b 45 14             	mov    0x14(%ebp),%eax
  8005e8:	8d 50 04             	lea    0x4(%eax),%edx
  8005eb:	89 55 14             	mov    %edx,0x14(%ebp)
  8005ee:	8b 00                	mov    (%eax),%eax
  8005f0:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005f3:	89 de                	mov    %ebx,%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8005f5:	eb 17                	jmp    80060e <vprintfmt+0xe9>

		case '.':
			if (width < 0)
  8005f7:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8005fb:	78 85                	js     800582 <vprintfmt+0x5d>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005fd:	89 de                	mov    %ebx,%esi
  8005ff:	eb 99                	jmp    80059a <vprintfmt+0x75>
  800601:	89 de                	mov    %ebx,%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800603:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
			goto reswitch;
  80060a:	eb 8e                	jmp    80059a <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80060c:	89 de                	mov    %ebx,%esi
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  80060e:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800612:	79 86                	jns    80059a <vprintfmt+0x75>
  800614:	e9 74 ff ff ff       	jmp    80058d <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800619:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80061a:	89 de                	mov    %ebx,%esi
  80061c:	e9 79 ff ff ff       	jmp    80059a <vprintfmt+0x75>
  800621:	89 5d d8             	mov    %ebx,-0x28(%ebp)
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800624:	8b 45 14             	mov    0x14(%ebp),%eax
  800627:	8d 50 04             	lea    0x4(%eax),%edx
  80062a:	89 55 14             	mov    %edx,0x14(%ebp)
  80062d:	83 ec 08             	sub    $0x8,%esp
  800630:	57                   	push   %edi
  800631:	ff 30                	pushl  (%eax)
  800633:	ff 55 08             	call   *0x8(%ebp)
			break;
  800636:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800639:	8b 75 d8             	mov    -0x28(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  80063c:	e9 08 ff ff ff       	jmp    800549 <vprintfmt+0x24>
  800641:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// error message
		case 'e':
			err = va_arg(ap, int);
  800644:	8b 45 14             	mov    0x14(%ebp),%eax
  800647:	8d 50 04             	lea    0x4(%eax),%edx
  80064a:	89 55 14             	mov    %edx,0x14(%ebp)
  80064d:	8b 00                	mov    (%eax),%eax
  80064f:	85 c0                	test   %eax,%eax
  800651:	79 02                	jns    800655 <vprintfmt+0x130>
  800653:	f7 d8                	neg    %eax
  800655:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800657:	83 f8 08             	cmp    $0x8,%eax
  80065a:	7f 0b                	jg     800667 <vprintfmt+0x142>
  80065c:	8b 04 85 c0 11 80 00 	mov    0x8011c0(,%eax,4),%eax
  800663:	85 c0                	test   %eax,%eax
  800665:	75 1a                	jne    800681 <vprintfmt+0x15c>
				printfmt(putch, putdat, "error %d", err);
  800667:	52                   	push   %edx
  800668:	68 b6 0f 80 00       	push   $0x800fb6
  80066d:	57                   	push   %edi
  80066e:	ff 75 08             	pushl  0x8(%ebp)
  800671:	e8 92 fe ff ff       	call   800508 <printfmt>
  800676:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800679:	8b 75 d8             	mov    -0x28(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  80067c:	e9 c8 fe ff ff       	jmp    800549 <vprintfmt+0x24>
			else
				printfmt(putch, putdat, "%s", p);
  800681:	50                   	push   %eax
  800682:	68 bf 0f 80 00       	push   $0x800fbf
  800687:	57                   	push   %edi
  800688:	ff 75 08             	pushl  0x8(%ebp)
  80068b:	e8 78 fe ff ff       	call   800508 <printfmt>
  800690:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800693:	8b 75 d8             	mov    -0x28(%ebp),%esi
  800696:	e9 ae fe ff ff       	jmp    800549 <vprintfmt+0x24>
  80069b:	89 5d d8             	mov    %ebx,-0x28(%ebp)
  80069e:	89 de                	mov    %ebx,%esi
  8006a0:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  8006a3:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8006a6:	8b 45 14             	mov    0x14(%ebp),%eax
  8006a9:	8d 50 04             	lea    0x4(%eax),%edx
  8006ac:	89 55 14             	mov    %edx,0x14(%ebp)
  8006af:	8b 00                	mov    (%eax),%eax
  8006b1:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8006b4:	85 c0                	test   %eax,%eax
  8006b6:	75 07                	jne    8006bf <vprintfmt+0x19a>
				p = "(null)";
  8006b8:	c7 45 d0 af 0f 80 00 	movl   $0x800faf,-0x30(%ebp)
			if (width > 0 && padc != '-')
  8006bf:	85 db                	test   %ebx,%ebx
  8006c1:	7e 42                	jle    800705 <vprintfmt+0x1e0>
  8006c3:	80 7d dc 2d          	cmpb   $0x2d,-0x24(%ebp)
  8006c7:	74 3c                	je     800705 <vprintfmt+0x1e0>
				for (width -= strnlen(p, precision); width > 0; width--)
  8006c9:	83 ec 08             	sub    $0x8,%esp
  8006cc:	51                   	push   %ecx
  8006cd:	ff 75 d0             	pushl  -0x30(%ebp)
  8006d0:	e8 6f 02 00 00       	call   800944 <strnlen>
  8006d5:	29 c3                	sub    %eax,%ebx
  8006d7:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8006da:	83 c4 10             	add    $0x10,%esp
  8006dd:	85 db                	test   %ebx,%ebx
  8006df:	7e 24                	jle    800705 <vprintfmt+0x1e0>
					putch(padc, putdat);
  8006e1:	0f be 5d dc          	movsbl -0x24(%ebp),%ebx
  8006e5:	89 75 dc             	mov    %esi,-0x24(%ebp)
  8006e8:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  8006eb:	83 ec 08             	sub    $0x8,%esp
  8006ee:	57                   	push   %edi
  8006ef:	53                   	push   %ebx
  8006f0:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8006f3:	4e                   	dec    %esi
  8006f4:	83 c4 10             	add    $0x10,%esp
  8006f7:	85 f6                	test   %esi,%esi
  8006f9:	7f f0                	jg     8006eb <vprintfmt+0x1c6>
  8006fb:	8b 75 dc             	mov    -0x24(%ebp),%esi
  8006fe:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800705:	8b 55 d0             	mov    -0x30(%ebp),%edx
  800708:	0f be 02             	movsbl (%edx),%eax
  80070b:	85 c0                	test   %eax,%eax
  80070d:	75 47                	jne    800756 <vprintfmt+0x231>
  80070f:	eb 37                	jmp    800748 <vprintfmt+0x223>
				if (altflag && (ch < ' ' || ch > '~'))
  800711:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800715:	74 16                	je     80072d <vprintfmt+0x208>
  800717:	8d 50 e0             	lea    -0x20(%eax),%edx
  80071a:	83 fa 5e             	cmp    $0x5e,%edx
  80071d:	76 0e                	jbe    80072d <vprintfmt+0x208>
					putch('?', putdat);
  80071f:	83 ec 08             	sub    $0x8,%esp
  800722:	57                   	push   %edi
  800723:	6a 3f                	push   $0x3f
  800725:	ff 55 08             	call   *0x8(%ebp)
  800728:	83 c4 10             	add    $0x10,%esp
  80072b:	eb 0b                	jmp    800738 <vprintfmt+0x213>
				else
					putch(ch, putdat);
  80072d:	83 ec 08             	sub    $0x8,%esp
  800730:	57                   	push   %edi
  800731:	50                   	push   %eax
  800732:	ff 55 08             	call   *0x8(%ebp)
  800735:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800738:	ff 4d e4             	decl   -0x1c(%ebp)
  80073b:	0f be 03             	movsbl (%ebx),%eax
  80073e:	85 c0                	test   %eax,%eax
  800740:	74 03                	je     800745 <vprintfmt+0x220>
  800742:	43                   	inc    %ebx
  800743:	eb 1b                	jmp    800760 <vprintfmt+0x23b>
  800745:	8b 75 dc             	mov    -0x24(%ebp),%esi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800748:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80074c:	7f 1e                	jg     80076c <vprintfmt+0x247>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80074e:	8b 75 d8             	mov    -0x28(%ebp),%esi
  800751:	e9 f3 fd ff ff       	jmp    800549 <vprintfmt+0x24>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800756:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  800759:	43                   	inc    %ebx
  80075a:	89 75 dc             	mov    %esi,-0x24(%ebp)
  80075d:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  800760:	85 f6                	test   %esi,%esi
  800762:	78 ad                	js     800711 <vprintfmt+0x1ec>
  800764:	4e                   	dec    %esi
  800765:	79 aa                	jns    800711 <vprintfmt+0x1ec>
  800767:	8b 75 dc             	mov    -0x24(%ebp),%esi
  80076a:	eb dc                	jmp    800748 <vprintfmt+0x223>
  80076c:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80076f:	83 ec 08             	sub    $0x8,%esp
  800772:	57                   	push   %edi
  800773:	6a 20                	push   $0x20
  800775:	ff 55 08             	call   *0x8(%ebp)
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800778:	4b                   	dec    %ebx
  800779:	83 c4 10             	add    $0x10,%esp
  80077c:	85 db                	test   %ebx,%ebx
  80077e:	7f ef                	jg     80076f <vprintfmt+0x24a>
  800780:	e9 c4 fd ff ff       	jmp    800549 <vprintfmt+0x24>
  800785:	89 5d d8             	mov    %ebx,-0x28(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800788:	89 ca                	mov    %ecx,%edx
  80078a:	8d 45 14             	lea    0x14(%ebp),%eax
  80078d:	e8 2a fd ff ff       	call   8004bc <getint>
  800792:	89 c3                	mov    %eax,%ebx
  800794:	89 d6                	mov    %edx,%esi
			if ((long long) num < 0) {
  800796:	85 d2                	test   %edx,%edx
  800798:	78 0a                	js     8007a4 <vprintfmt+0x27f>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  80079a:	b8 0a 00 00 00       	mov    $0xa,%eax
  80079f:	e9 b0 00 00 00       	jmp    800854 <vprintfmt+0x32f>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  8007a4:	83 ec 08             	sub    $0x8,%esp
  8007a7:	57                   	push   %edi
  8007a8:	6a 2d                	push   $0x2d
  8007aa:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  8007ad:	f7 db                	neg    %ebx
  8007af:	83 d6 00             	adc    $0x0,%esi
  8007b2:	f7 de                	neg    %esi
  8007b4:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  8007b7:	b8 0a 00 00 00       	mov    $0xa,%eax
  8007bc:	e9 93 00 00 00       	jmp    800854 <vprintfmt+0x32f>
  8007c1:	89 5d d8             	mov    %ebx,-0x28(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8007c4:	89 ca                	mov    %ecx,%edx
  8007c6:	8d 45 14             	lea    0x14(%ebp),%eax
  8007c9:	e8 b4 fc ff ff       	call   800482 <getuint>
  8007ce:	89 c3                	mov    %eax,%ebx
  8007d0:	89 d6                	mov    %edx,%esi
			base = 10;
  8007d2:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  8007d7:	eb 7b                	jmp    800854 <vprintfmt+0x32f>
  8007d9:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// (unsigned) octal
		case 'o':
            // (MIT 6.828, lab1, Ex.8)  my code : 
            num = getint(&ap, lflag);
  8007dc:	89 ca                	mov    %ecx,%edx
  8007de:	8d 45 14             	lea    0x14(%ebp),%eax
  8007e1:	e8 d6 fc ff ff       	call   8004bc <getint>
  8007e6:	89 c3                	mov    %eax,%ebx
  8007e8:	89 d6                	mov    %edx,%esi
            if ((long long) num < 0) {
  8007ea:	85 d2                	test   %edx,%edx
  8007ec:	78 07                	js     8007f5 <vprintfmt+0x2d0>
                putch('-', putdat);
                num = -(long long) num;
            }
            base = 8;
  8007ee:	b8 08 00 00 00       	mov    $0x8,%eax
  8007f3:	eb 5f                	jmp    800854 <vprintfmt+0x32f>
		// (unsigned) octal
		case 'o':
            // (MIT 6.828, lab1, Ex.8)  my code : 
            num = getint(&ap, lflag);
            if ((long long) num < 0) {
                putch('-', putdat);
  8007f5:	83 ec 08             	sub    $0x8,%esp
  8007f8:	57                   	push   %edi
  8007f9:	6a 2d                	push   $0x2d
  8007fb:	ff 55 08             	call   *0x8(%ebp)
                num = -(long long) num;
  8007fe:	f7 db                	neg    %ebx
  800800:	83 d6 00             	adc    $0x0,%esi
  800803:	f7 de                	neg    %esi
  800805:	83 c4 10             	add    $0x10,%esp
            }
            base = 8;
  800808:	b8 08 00 00 00       	mov    $0x8,%eax
  80080d:	eb 45                	jmp    800854 <vprintfmt+0x32f>
  80080f:	89 5d d8             	mov    %ebx,-0x28(%ebp)
            goto number;

        // pointer
		case 'p':
			putch('0', putdat);
  800812:	83 ec 08             	sub    $0x8,%esp
  800815:	57                   	push   %edi
  800816:	6a 30                	push   $0x30
  800818:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  80081b:	83 c4 08             	add    $0x8,%esp
  80081e:	57                   	push   %edi
  80081f:	6a 78                	push   $0x78
  800821:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800824:	8b 45 14             	mov    0x14(%ebp),%eax
  800827:	8d 50 04             	lea    0x4(%eax),%edx
  80082a:	89 55 14             	mov    %edx,0x14(%ebp)

        // pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  80082d:	8b 18                	mov    (%eax),%ebx
  80082f:	be 00 00 00 00       	mov    $0x0,%esi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800834:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800837:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  80083c:	eb 16                	jmp    800854 <vprintfmt+0x32f>
  80083e:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800841:	89 ca                	mov    %ecx,%edx
  800843:	8d 45 14             	lea    0x14(%ebp),%eax
  800846:	e8 37 fc ff ff       	call   800482 <getuint>
  80084b:	89 c3                	mov    %eax,%ebx
  80084d:	89 d6                	mov    %edx,%esi
			base = 16;
  80084f:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  800854:	83 ec 0c             	sub    $0xc,%esp
  800857:	0f be 55 dc          	movsbl -0x24(%ebp),%edx
  80085b:	52                   	push   %edx
  80085c:	ff 75 e4             	pushl  -0x1c(%ebp)
  80085f:	50                   	push   %eax
  800860:	56                   	push   %esi
  800861:	53                   	push   %ebx
  800862:	89 fa                	mov    %edi,%edx
  800864:	8b 45 08             	mov    0x8(%ebp),%eax
  800867:	e8 68 fb ff ff       	call   8003d4 <printnum>
			break;
  80086c:	83 c4 20             	add    $0x20,%esp
  80086f:	8b 75 d8             	mov    -0x28(%ebp),%esi
  800872:	e9 d2 fc ff ff       	jmp    800549 <vprintfmt+0x24>
  800877:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80087a:	83 ec 08             	sub    $0x8,%esp
  80087d:	57                   	push   %edi
  80087e:	52                   	push   %edx
  80087f:	ff 55 08             	call   *0x8(%ebp)
			break;
  800882:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800885:	8b 75 d8             	mov    -0x28(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800888:	e9 bc fc ff ff       	jmp    800549 <vprintfmt+0x24>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80088d:	83 ec 08             	sub    $0x8,%esp
  800890:	57                   	push   %edi
  800891:	6a 25                	push   $0x25
  800893:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800896:	83 c4 10             	add    $0x10,%esp
  800899:	eb 02                	jmp    80089d <vprintfmt+0x378>
  80089b:	89 c6                	mov    %eax,%esi
  80089d:	8d 46 ff             	lea    -0x1(%esi),%eax
  8008a0:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  8008a4:	75 f5                	jne    80089b <vprintfmt+0x376>
  8008a6:	e9 9e fc ff ff       	jmp    800549 <vprintfmt+0x24>
				/* do nothing */;
			break;
		}
	}
}
  8008ab:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8008ae:	5b                   	pop    %ebx
  8008af:	5e                   	pop    %esi
  8008b0:	5f                   	pop    %edi
  8008b1:	c9                   	leave  
  8008b2:	c3                   	ret    

008008b3 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8008b3:	55                   	push   %ebp
  8008b4:	89 e5                	mov    %esp,%ebp
  8008b6:	83 ec 18             	sub    $0x18,%esp
  8008b9:	8b 45 08             	mov    0x8(%ebp),%eax
  8008bc:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8008bf:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8008c2:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8008c6:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8008c9:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8008d0:	85 c0                	test   %eax,%eax
  8008d2:	74 26                	je     8008fa <vsnprintf+0x47>
  8008d4:	85 d2                	test   %edx,%edx
  8008d6:	7e 29                	jle    800901 <vsnprintf+0x4e>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8008d8:	ff 75 14             	pushl  0x14(%ebp)
  8008db:	ff 75 10             	pushl  0x10(%ebp)
  8008de:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8008e1:	50                   	push   %eax
  8008e2:	68 ee 04 80 00       	push   $0x8004ee
  8008e7:	e8 39 fc ff ff       	call   800525 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8008ec:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8008ef:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8008f2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8008f5:	83 c4 10             	add    $0x10,%esp
  8008f8:	eb 0c                	jmp    800906 <vsnprintf+0x53>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8008fa:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8008ff:	eb 05                	jmp    800906 <vsnprintf+0x53>
  800901:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800906:	c9                   	leave  
  800907:	c3                   	ret    

00800908 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800908:	55                   	push   %ebp
  800909:	89 e5                	mov    %esp,%ebp
  80090b:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80090e:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800911:	50                   	push   %eax
  800912:	ff 75 10             	pushl  0x10(%ebp)
  800915:	ff 75 0c             	pushl  0xc(%ebp)
  800918:	ff 75 08             	pushl  0x8(%ebp)
  80091b:	e8 93 ff ff ff       	call   8008b3 <vsnprintf>
	va_end(ap);

	return rc;
}
  800920:	c9                   	leave  
  800921:	c3                   	ret    
	...

00800924 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800924:	55                   	push   %ebp
  800925:	89 e5                	mov    %esp,%ebp
  800927:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80092a:	80 3a 00             	cmpb   $0x0,(%edx)
  80092d:	74 0e                	je     80093d <strlen+0x19>
  80092f:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  800934:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800935:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800939:	75 f9                	jne    800934 <strlen+0x10>
  80093b:	eb 05                	jmp    800942 <strlen+0x1e>
  80093d:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  800942:	c9                   	leave  
  800943:	c3                   	ret    

00800944 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800944:	55                   	push   %ebp
  800945:	89 e5                	mov    %esp,%ebp
  800947:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80094a:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80094d:	85 d2                	test   %edx,%edx
  80094f:	74 17                	je     800968 <strnlen+0x24>
  800951:	80 39 00             	cmpb   $0x0,(%ecx)
  800954:	74 19                	je     80096f <strnlen+0x2b>
  800956:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  80095b:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80095c:	39 d0                	cmp    %edx,%eax
  80095e:	74 14                	je     800974 <strnlen+0x30>
  800960:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800964:	75 f5                	jne    80095b <strnlen+0x17>
  800966:	eb 0c                	jmp    800974 <strnlen+0x30>
  800968:	b8 00 00 00 00       	mov    $0x0,%eax
  80096d:	eb 05                	jmp    800974 <strnlen+0x30>
  80096f:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  800974:	c9                   	leave  
  800975:	c3                   	ret    

00800976 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800976:	55                   	push   %ebp
  800977:	89 e5                	mov    %esp,%ebp
  800979:	53                   	push   %ebx
  80097a:	8b 45 08             	mov    0x8(%ebp),%eax
  80097d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800980:	ba 00 00 00 00       	mov    $0x0,%edx
  800985:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  800988:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  80098b:	42                   	inc    %edx
  80098c:	84 c9                	test   %cl,%cl
  80098e:	75 f5                	jne    800985 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800990:	5b                   	pop    %ebx
  800991:	c9                   	leave  
  800992:	c3                   	ret    

00800993 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800993:	55                   	push   %ebp
  800994:	89 e5                	mov    %esp,%ebp
  800996:	53                   	push   %ebx
  800997:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80099a:	53                   	push   %ebx
  80099b:	e8 84 ff ff ff       	call   800924 <strlen>
  8009a0:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8009a3:	ff 75 0c             	pushl  0xc(%ebp)
  8009a6:	8d 04 03             	lea    (%ebx,%eax,1),%eax
  8009a9:	50                   	push   %eax
  8009aa:	e8 c7 ff ff ff       	call   800976 <strcpy>
	return dst;
}
  8009af:	89 d8                	mov    %ebx,%eax
  8009b1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8009b4:	c9                   	leave  
  8009b5:	c3                   	ret    

008009b6 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8009b6:	55                   	push   %ebp
  8009b7:	89 e5                	mov    %esp,%ebp
  8009b9:	56                   	push   %esi
  8009ba:	53                   	push   %ebx
  8009bb:	8b 45 08             	mov    0x8(%ebp),%eax
  8009be:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009c1:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8009c4:	85 f6                	test   %esi,%esi
  8009c6:	74 15                	je     8009dd <strncpy+0x27>
  8009c8:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
  8009cd:	8a 1a                	mov    (%edx),%bl
  8009cf:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8009d2:	80 3a 01             	cmpb   $0x1,(%edx)
  8009d5:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8009d8:	41                   	inc    %ecx
  8009d9:	39 ce                	cmp    %ecx,%esi
  8009db:	77 f0                	ja     8009cd <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8009dd:	5b                   	pop    %ebx
  8009de:	5e                   	pop    %esi
  8009df:	c9                   	leave  
  8009e0:	c3                   	ret    

008009e1 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8009e1:	55                   	push   %ebp
  8009e2:	89 e5                	mov    %esp,%ebp
  8009e4:	57                   	push   %edi
  8009e5:	56                   	push   %esi
  8009e6:	53                   	push   %ebx
  8009e7:	8b 7d 08             	mov    0x8(%ebp),%edi
  8009ea:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8009ed:	8b 75 10             	mov    0x10(%ebp),%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8009f0:	85 f6                	test   %esi,%esi
  8009f2:	74 32                	je     800a26 <strlcpy+0x45>
		while (--size > 0 && *src != '\0')
  8009f4:	83 fe 01             	cmp    $0x1,%esi
  8009f7:	74 22                	je     800a1b <strlcpy+0x3a>
  8009f9:	8a 0b                	mov    (%ebx),%cl
  8009fb:	84 c9                	test   %cl,%cl
  8009fd:	74 20                	je     800a1f <strlcpy+0x3e>
  8009ff:	89 f8                	mov    %edi,%eax
  800a01:	ba 00 00 00 00       	mov    $0x0,%edx
	}
	return ret;
}

size_t
strlcpy(char *dst, const char *src, size_t size)
  800a06:	83 ee 02             	sub    $0x2,%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800a09:	88 08                	mov    %cl,(%eax)
  800a0b:	40                   	inc    %eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800a0c:	39 f2                	cmp    %esi,%edx
  800a0e:	74 11                	je     800a21 <strlcpy+0x40>
  800a10:	8a 4c 13 01          	mov    0x1(%ebx,%edx,1),%cl
  800a14:	42                   	inc    %edx
  800a15:	84 c9                	test   %cl,%cl
  800a17:	75 f0                	jne    800a09 <strlcpy+0x28>
  800a19:	eb 06                	jmp    800a21 <strlcpy+0x40>
  800a1b:	89 f8                	mov    %edi,%eax
  800a1d:	eb 02                	jmp    800a21 <strlcpy+0x40>
  800a1f:	89 f8                	mov    %edi,%eax
			*dst++ = *src++;
		*dst = '\0';
  800a21:	c6 00 00             	movb   $0x0,(%eax)
  800a24:	eb 02                	jmp    800a28 <strlcpy+0x47>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800a26:	89 f8                	mov    %edi,%eax
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
		*dst = '\0';
	}
	return dst - dst_in;
  800a28:	29 f8                	sub    %edi,%eax
}
  800a2a:	5b                   	pop    %ebx
  800a2b:	5e                   	pop    %esi
  800a2c:	5f                   	pop    %edi
  800a2d:	c9                   	leave  
  800a2e:	c3                   	ret    

00800a2f <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800a2f:	55                   	push   %ebp
  800a30:	89 e5                	mov    %esp,%ebp
  800a32:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a35:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800a38:	8a 01                	mov    (%ecx),%al
  800a3a:	84 c0                	test   %al,%al
  800a3c:	74 10                	je     800a4e <strcmp+0x1f>
  800a3e:	3a 02                	cmp    (%edx),%al
  800a40:	75 0c                	jne    800a4e <strcmp+0x1f>
		p++, q++;
  800a42:	41                   	inc    %ecx
  800a43:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800a44:	8a 01                	mov    (%ecx),%al
  800a46:	84 c0                	test   %al,%al
  800a48:	74 04                	je     800a4e <strcmp+0x1f>
  800a4a:	3a 02                	cmp    (%edx),%al
  800a4c:	74 f4                	je     800a42 <strcmp+0x13>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800a4e:	0f b6 c0             	movzbl %al,%eax
  800a51:	0f b6 12             	movzbl (%edx),%edx
  800a54:	29 d0                	sub    %edx,%eax
}
  800a56:	c9                   	leave  
  800a57:	c3                   	ret    

00800a58 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800a58:	55                   	push   %ebp
  800a59:	89 e5                	mov    %esp,%ebp
  800a5b:	53                   	push   %ebx
  800a5c:	8b 55 08             	mov    0x8(%ebp),%edx
  800a5f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a62:	8b 45 10             	mov    0x10(%ebp),%eax
	while (n > 0 && *p && *p == *q)
  800a65:	85 c0                	test   %eax,%eax
  800a67:	74 1b                	je     800a84 <strncmp+0x2c>
  800a69:	8a 1a                	mov    (%edx),%bl
  800a6b:	84 db                	test   %bl,%bl
  800a6d:	74 24                	je     800a93 <strncmp+0x3b>
  800a6f:	3a 19                	cmp    (%ecx),%bl
  800a71:	75 20                	jne    800a93 <strncmp+0x3b>
  800a73:	48                   	dec    %eax
  800a74:	74 15                	je     800a8b <strncmp+0x33>
		n--, p++, q++;
  800a76:	42                   	inc    %edx
  800a77:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800a78:	8a 1a                	mov    (%edx),%bl
  800a7a:	84 db                	test   %bl,%bl
  800a7c:	74 15                	je     800a93 <strncmp+0x3b>
  800a7e:	3a 19                	cmp    (%ecx),%bl
  800a80:	74 f1                	je     800a73 <strncmp+0x1b>
  800a82:	eb 0f                	jmp    800a93 <strncmp+0x3b>
		n--, p++, q++;
	if (n == 0)
		return 0;
  800a84:	b8 00 00 00 00       	mov    $0x0,%eax
  800a89:	eb 05                	jmp    800a90 <strncmp+0x38>
  800a8b:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800a90:	5b                   	pop    %ebx
  800a91:	c9                   	leave  
  800a92:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800a93:	0f b6 02             	movzbl (%edx),%eax
  800a96:	0f b6 11             	movzbl (%ecx),%edx
  800a99:	29 d0                	sub    %edx,%eax
  800a9b:	eb f3                	jmp    800a90 <strncmp+0x38>

00800a9d <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800a9d:	55                   	push   %ebp
  800a9e:	89 e5                	mov    %esp,%ebp
  800aa0:	8b 45 08             	mov    0x8(%ebp),%eax
  800aa3:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800aa6:	8a 10                	mov    (%eax),%dl
  800aa8:	84 d2                	test   %dl,%dl
  800aaa:	74 18                	je     800ac4 <strchr+0x27>
		if (*s == c)
  800aac:	38 ca                	cmp    %cl,%dl
  800aae:	75 06                	jne    800ab6 <strchr+0x19>
  800ab0:	eb 17                	jmp    800ac9 <strchr+0x2c>
  800ab2:	38 ca                	cmp    %cl,%dl
  800ab4:	74 13                	je     800ac9 <strchr+0x2c>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800ab6:	40                   	inc    %eax
  800ab7:	8a 10                	mov    (%eax),%dl
  800ab9:	84 d2                	test   %dl,%dl
  800abb:	75 f5                	jne    800ab2 <strchr+0x15>
		if (*s == c)
			return (char *) s;
	return 0;
  800abd:	b8 00 00 00 00       	mov    $0x0,%eax
  800ac2:	eb 05                	jmp    800ac9 <strchr+0x2c>
  800ac4:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800ac9:	c9                   	leave  
  800aca:	c3                   	ret    

00800acb <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800acb:	55                   	push   %ebp
  800acc:	89 e5                	mov    %esp,%ebp
  800ace:	8b 45 08             	mov    0x8(%ebp),%eax
  800ad1:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800ad4:	8a 10                	mov    (%eax),%dl
  800ad6:	84 d2                	test   %dl,%dl
  800ad8:	74 11                	je     800aeb <strfind+0x20>
		if (*s == c)
  800ada:	38 ca                	cmp    %cl,%dl
  800adc:	75 06                	jne    800ae4 <strfind+0x19>
  800ade:	eb 0b                	jmp    800aeb <strfind+0x20>
  800ae0:	38 ca                	cmp    %cl,%dl
  800ae2:	74 07                	je     800aeb <strfind+0x20>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800ae4:	40                   	inc    %eax
  800ae5:	8a 10                	mov    (%eax),%dl
  800ae7:	84 d2                	test   %dl,%dl
  800ae9:	75 f5                	jne    800ae0 <strfind+0x15>
		if (*s == c)
			break;
	return (char *) s;
}
  800aeb:	c9                   	leave  
  800aec:	c3                   	ret    

00800aed <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800aed:	55                   	push   %ebp
  800aee:	89 e5                	mov    %esp,%ebp
  800af0:	57                   	push   %edi
  800af1:	56                   	push   %esi
  800af2:	53                   	push   %ebx
  800af3:	8b 7d 08             	mov    0x8(%ebp),%edi
  800af6:	8b 45 0c             	mov    0xc(%ebp),%eax
  800af9:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800afc:	85 c9                	test   %ecx,%ecx
  800afe:	74 30                	je     800b30 <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800b00:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800b06:	75 25                	jne    800b2d <memset+0x40>
  800b08:	f6 c1 03             	test   $0x3,%cl
  800b0b:	75 20                	jne    800b2d <memset+0x40>
		c &= 0xFF;
  800b0d:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800b10:	89 d3                	mov    %edx,%ebx
  800b12:	c1 e3 08             	shl    $0x8,%ebx
  800b15:	89 d6                	mov    %edx,%esi
  800b17:	c1 e6 18             	shl    $0x18,%esi
  800b1a:	89 d0                	mov    %edx,%eax
  800b1c:	c1 e0 10             	shl    $0x10,%eax
  800b1f:	09 f0                	or     %esi,%eax
  800b21:	09 d0                	or     %edx,%eax
  800b23:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800b25:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800b28:	fc                   	cld    
  800b29:	f3 ab                	rep stos %eax,%es:(%edi)
  800b2b:	eb 03                	jmp    800b30 <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800b2d:	fc                   	cld    
  800b2e:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800b30:	89 f8                	mov    %edi,%eax
  800b32:	5b                   	pop    %ebx
  800b33:	5e                   	pop    %esi
  800b34:	5f                   	pop    %edi
  800b35:	c9                   	leave  
  800b36:	c3                   	ret    

00800b37 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800b37:	55                   	push   %ebp
  800b38:	89 e5                	mov    %esp,%ebp
  800b3a:	57                   	push   %edi
  800b3b:	56                   	push   %esi
  800b3c:	8b 45 08             	mov    0x8(%ebp),%eax
  800b3f:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b42:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800b45:	39 c6                	cmp    %eax,%esi
  800b47:	73 34                	jae    800b7d <memmove+0x46>
  800b49:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800b4c:	39 d0                	cmp    %edx,%eax
  800b4e:	73 2d                	jae    800b7d <memmove+0x46>
		s += n;
		d += n;
  800b50:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b53:	f6 c2 03             	test   $0x3,%dl
  800b56:	75 1b                	jne    800b73 <memmove+0x3c>
  800b58:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800b5e:	75 13                	jne    800b73 <memmove+0x3c>
  800b60:	f6 c1 03             	test   $0x3,%cl
  800b63:	75 0e                	jne    800b73 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800b65:	83 ef 04             	sub    $0x4,%edi
  800b68:	8d 72 fc             	lea    -0x4(%edx),%esi
  800b6b:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800b6e:	fd                   	std    
  800b6f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b71:	eb 07                	jmp    800b7a <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800b73:	4f                   	dec    %edi
  800b74:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800b77:	fd                   	std    
  800b78:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800b7a:	fc                   	cld    
  800b7b:	eb 20                	jmp    800b9d <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b7d:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800b83:	75 13                	jne    800b98 <memmove+0x61>
  800b85:	a8 03                	test   $0x3,%al
  800b87:	75 0f                	jne    800b98 <memmove+0x61>
  800b89:	f6 c1 03             	test   $0x3,%cl
  800b8c:	75 0a                	jne    800b98 <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800b8e:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800b91:	89 c7                	mov    %eax,%edi
  800b93:	fc                   	cld    
  800b94:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b96:	eb 05                	jmp    800b9d <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800b98:	89 c7                	mov    %eax,%edi
  800b9a:	fc                   	cld    
  800b9b:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800b9d:	5e                   	pop    %esi
  800b9e:	5f                   	pop    %edi
  800b9f:	c9                   	leave  
  800ba0:	c3                   	ret    

00800ba1 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800ba1:	55                   	push   %ebp
  800ba2:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800ba4:	ff 75 10             	pushl  0x10(%ebp)
  800ba7:	ff 75 0c             	pushl  0xc(%ebp)
  800baa:	ff 75 08             	pushl  0x8(%ebp)
  800bad:	e8 85 ff ff ff       	call   800b37 <memmove>
}
  800bb2:	c9                   	leave  
  800bb3:	c3                   	ret    

00800bb4 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800bb4:	55                   	push   %ebp
  800bb5:	89 e5                	mov    %esp,%ebp
  800bb7:	57                   	push   %edi
  800bb8:	56                   	push   %esi
  800bb9:	53                   	push   %ebx
  800bba:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800bbd:	8b 75 0c             	mov    0xc(%ebp),%esi
  800bc0:	8b 7d 10             	mov    0x10(%ebp),%edi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800bc3:	85 ff                	test   %edi,%edi
  800bc5:	74 32                	je     800bf9 <memcmp+0x45>
		if (*s1 != *s2)
  800bc7:	8a 03                	mov    (%ebx),%al
  800bc9:	8a 0e                	mov    (%esi),%cl
  800bcb:	38 c8                	cmp    %cl,%al
  800bcd:	74 19                	je     800be8 <memcmp+0x34>
  800bcf:	eb 0d                	jmp    800bde <memcmp+0x2a>
  800bd1:	8a 44 13 01          	mov    0x1(%ebx,%edx,1),%al
  800bd5:	8a 4c 16 01          	mov    0x1(%esi,%edx,1),%cl
  800bd9:	42                   	inc    %edx
  800bda:	38 c8                	cmp    %cl,%al
  800bdc:	74 10                	je     800bee <memcmp+0x3a>
			return (int) *s1 - (int) *s2;
  800bde:	0f b6 c0             	movzbl %al,%eax
  800be1:	0f b6 c9             	movzbl %cl,%ecx
  800be4:	29 c8                	sub    %ecx,%eax
  800be6:	eb 16                	jmp    800bfe <memcmp+0x4a>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800be8:	4f                   	dec    %edi
  800be9:	ba 00 00 00 00       	mov    $0x0,%edx
  800bee:	39 fa                	cmp    %edi,%edx
  800bf0:	75 df                	jne    800bd1 <memcmp+0x1d>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800bf2:	b8 00 00 00 00       	mov    $0x0,%eax
  800bf7:	eb 05                	jmp    800bfe <memcmp+0x4a>
  800bf9:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800bfe:	5b                   	pop    %ebx
  800bff:	5e                   	pop    %esi
  800c00:	5f                   	pop    %edi
  800c01:	c9                   	leave  
  800c02:	c3                   	ret    

00800c03 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800c03:	55                   	push   %ebp
  800c04:	89 e5                	mov    %esp,%ebp
  800c06:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800c09:	89 c2                	mov    %eax,%edx
  800c0b:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800c0e:	39 d0                	cmp    %edx,%eax
  800c10:	73 12                	jae    800c24 <memfind+0x21>
		if (*(const unsigned char *) s == (unsigned char) c)
  800c12:	8a 4d 0c             	mov    0xc(%ebp),%cl
  800c15:	38 08                	cmp    %cl,(%eax)
  800c17:	75 06                	jne    800c1f <memfind+0x1c>
  800c19:	eb 09                	jmp    800c24 <memfind+0x21>
  800c1b:	38 08                	cmp    %cl,(%eax)
  800c1d:	74 05                	je     800c24 <memfind+0x21>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800c1f:	40                   	inc    %eax
  800c20:	39 c2                	cmp    %eax,%edx
  800c22:	77 f7                	ja     800c1b <memfind+0x18>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800c24:	c9                   	leave  
  800c25:	c3                   	ret    

00800c26 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800c26:	55                   	push   %ebp
  800c27:	89 e5                	mov    %esp,%ebp
  800c29:	57                   	push   %edi
  800c2a:	56                   	push   %esi
  800c2b:	53                   	push   %ebx
  800c2c:	8b 55 08             	mov    0x8(%ebp),%edx
  800c2f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800c32:	eb 01                	jmp    800c35 <strtol+0xf>
		s++;
  800c34:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800c35:	8a 02                	mov    (%edx),%al
  800c37:	3c 20                	cmp    $0x20,%al
  800c39:	74 f9                	je     800c34 <strtol+0xe>
  800c3b:	3c 09                	cmp    $0x9,%al
  800c3d:	74 f5                	je     800c34 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800c3f:	3c 2b                	cmp    $0x2b,%al
  800c41:	75 08                	jne    800c4b <strtol+0x25>
		s++;
  800c43:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800c44:	bf 00 00 00 00       	mov    $0x0,%edi
  800c49:	eb 13                	jmp    800c5e <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800c4b:	3c 2d                	cmp    $0x2d,%al
  800c4d:	75 0a                	jne    800c59 <strtol+0x33>
		s++, neg = 1;
  800c4f:	8d 52 01             	lea    0x1(%edx),%edx
  800c52:	bf 01 00 00 00       	mov    $0x1,%edi
  800c57:	eb 05                	jmp    800c5e <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800c59:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800c5e:	85 db                	test   %ebx,%ebx
  800c60:	74 05                	je     800c67 <strtol+0x41>
  800c62:	83 fb 10             	cmp    $0x10,%ebx
  800c65:	75 28                	jne    800c8f <strtol+0x69>
  800c67:	8a 02                	mov    (%edx),%al
  800c69:	3c 30                	cmp    $0x30,%al
  800c6b:	75 10                	jne    800c7d <strtol+0x57>
  800c6d:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800c71:	75 0a                	jne    800c7d <strtol+0x57>
		s += 2, base = 16;
  800c73:	83 c2 02             	add    $0x2,%edx
  800c76:	bb 10 00 00 00       	mov    $0x10,%ebx
  800c7b:	eb 12                	jmp    800c8f <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  800c7d:	85 db                	test   %ebx,%ebx
  800c7f:	75 0e                	jne    800c8f <strtol+0x69>
  800c81:	3c 30                	cmp    $0x30,%al
  800c83:	75 05                	jne    800c8a <strtol+0x64>
		s++, base = 8;
  800c85:	42                   	inc    %edx
  800c86:	b3 08                	mov    $0x8,%bl
  800c88:	eb 05                	jmp    800c8f <strtol+0x69>
	else if (base == 0)
		base = 10;
  800c8a:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800c8f:	b8 00 00 00 00       	mov    $0x0,%eax
  800c94:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800c96:	8a 0a                	mov    (%edx),%cl
  800c98:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800c9b:	80 fb 09             	cmp    $0x9,%bl
  800c9e:	77 08                	ja     800ca8 <strtol+0x82>
			dig = *s - '0';
  800ca0:	0f be c9             	movsbl %cl,%ecx
  800ca3:	83 e9 30             	sub    $0x30,%ecx
  800ca6:	eb 1e                	jmp    800cc6 <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  800ca8:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800cab:	80 fb 19             	cmp    $0x19,%bl
  800cae:	77 08                	ja     800cb8 <strtol+0x92>
			dig = *s - 'a' + 10;
  800cb0:	0f be c9             	movsbl %cl,%ecx
  800cb3:	83 e9 57             	sub    $0x57,%ecx
  800cb6:	eb 0e                	jmp    800cc6 <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  800cb8:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800cbb:	80 fb 19             	cmp    $0x19,%bl
  800cbe:	77 13                	ja     800cd3 <strtol+0xad>
			dig = *s - 'A' + 10;
  800cc0:	0f be c9             	movsbl %cl,%ecx
  800cc3:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800cc6:	39 f1                	cmp    %esi,%ecx
  800cc8:	7d 0d                	jge    800cd7 <strtol+0xb1>
			break;
		s++, val = (val * base) + dig;
  800cca:	42                   	inc    %edx
  800ccb:	0f af c6             	imul   %esi,%eax
  800cce:	8d 04 01             	lea    (%ecx,%eax,1),%eax
		// we don't properly detect overflow!
	}
  800cd1:	eb c3                	jmp    800c96 <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800cd3:	89 c1                	mov    %eax,%ecx
  800cd5:	eb 02                	jmp    800cd9 <strtol+0xb3>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800cd7:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800cd9:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800cdd:	74 05                	je     800ce4 <strtol+0xbe>
		*endptr = (char *) s;
  800cdf:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800ce2:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800ce4:	85 ff                	test   %edi,%edi
  800ce6:	74 04                	je     800cec <strtol+0xc6>
  800ce8:	89 c8                	mov    %ecx,%eax
  800cea:	f7 d8                	neg    %eax
}
  800cec:	5b                   	pop    %ebx
  800ced:	5e                   	pop    %esi
  800cee:	5f                   	pop    %edi
  800cef:	c9                   	leave  
  800cf0:	c3                   	ret    
  800cf1:	00 00                	add    %al,(%eax)
	...

00800cf4 <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  800cf4:	55                   	push   %ebp
  800cf5:	89 e5                	mov    %esp,%ebp
  800cf7:	57                   	push   %edi
  800cf8:	56                   	push   %esi
  800cf9:	83 ec 10             	sub    $0x10,%esp
  800cfc:	8b 7d 08             	mov    0x8(%ebp),%edi
  800cff:	8b 4d 10             	mov    0x10(%ebp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  800d02:	89 7d f0             	mov    %edi,-0x10(%ebp)
  800d05:	8b 75 0c             	mov    0xc(%ebp),%esi
  const DWunion dd = {.ll = d};
  800d08:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  800d0b:	8b 45 14             	mov    0x14(%ebp),%eax
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  800d0e:	85 c0                	test   %eax,%eax
  800d10:	75 2e                	jne    800d40 <__udivdi3+0x4c>
    {
      if (d0 > n1)
  800d12:	39 f1                	cmp    %esi,%ecx
  800d14:	77 5a                	ja     800d70 <__udivdi3+0x7c>
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  800d16:	85 c9                	test   %ecx,%ecx
  800d18:	75 0b                	jne    800d25 <__udivdi3+0x31>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  800d1a:	b8 01 00 00 00       	mov    $0x1,%eax
  800d1f:	31 d2                	xor    %edx,%edx
  800d21:	f7 f1                	div    %ecx
  800d23:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  800d25:	31 d2                	xor    %edx,%edx
  800d27:	89 f0                	mov    %esi,%eax
  800d29:	f7 f1                	div    %ecx
  800d2b:	89 c6                	mov    %eax,%esi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800d2d:	89 f8                	mov    %edi,%eax
  800d2f:	f7 f1                	div    %ecx
  800d31:	89 c7                	mov    %eax,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800d33:	89 f8                	mov    %edi,%eax
  800d35:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800d37:	83 c4 10             	add    $0x10,%esp
  800d3a:	5e                   	pop    %esi
  800d3b:	5f                   	pop    %edi
  800d3c:	c9                   	leave  
  800d3d:	c3                   	ret    
  800d3e:	66 90                	xchg   %ax,%ax
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  800d40:	39 f0                	cmp    %esi,%eax
  800d42:	77 1c                	ja     800d60 <__udivdi3+0x6c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  800d44:	0f bd f8             	bsr    %eax,%edi
	  if (bm == 0)
  800d47:	83 f7 1f             	xor    $0x1f,%edi
  800d4a:	75 3c                	jne    800d88 <__udivdi3+0x94>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  800d4c:	39 f0                	cmp    %esi,%eax
  800d4e:	0f 82 90 00 00 00    	jb     800de4 <__udivdi3+0xf0>
  800d54:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800d57:	39 55 f4             	cmp    %edx,-0xc(%ebp)
  800d5a:	0f 86 84 00 00 00    	jbe    800de4 <__udivdi3+0xf0>
  800d60:	31 f6                	xor    %esi,%esi
  800d62:	31 ff                	xor    %edi,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800d64:	89 f8                	mov    %edi,%eax
  800d66:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800d68:	83 c4 10             	add    $0x10,%esp
  800d6b:	5e                   	pop    %esi
  800d6c:	5f                   	pop    %edi
  800d6d:	c9                   	leave  
  800d6e:	c3                   	ret    
  800d6f:	90                   	nop
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800d70:	89 f2                	mov    %esi,%edx
  800d72:	89 f8                	mov    %edi,%eax
  800d74:	f7 f1                	div    %ecx
  800d76:	89 c7                	mov    %eax,%edi
  800d78:	31 f6                	xor    %esi,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800d7a:	89 f8                	mov    %edi,%eax
  800d7c:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800d7e:	83 c4 10             	add    $0x10,%esp
  800d81:	5e                   	pop    %esi
  800d82:	5f                   	pop    %edi
  800d83:	c9                   	leave  
  800d84:	c3                   	ret    
  800d85:	8d 76 00             	lea    0x0(%esi),%esi
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  800d88:	89 f9                	mov    %edi,%ecx
  800d8a:	d3 e0                	shl    %cl,%eax
  800d8c:	89 45 e8             	mov    %eax,-0x18(%ebp)
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  800d8f:	b8 20 00 00 00       	mov    $0x20,%eax
  800d94:	29 f8                	sub    %edi,%eax

	      d1 = (d1 << bm) | (d0 >> b);
  800d96:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800d99:	88 c1                	mov    %al,%cl
  800d9b:	d3 ea                	shr    %cl,%edx
  800d9d:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  800da0:	09 ca                	or     %ecx,%edx
  800da2:	89 55 ec             	mov    %edx,-0x14(%ebp)
	      d0 = d0 << bm;
  800da5:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800da8:	89 f9                	mov    %edi,%ecx
  800daa:	d3 e2                	shl    %cl,%edx
  800dac:	89 55 f4             	mov    %edx,-0xc(%ebp)
	      n2 = n1 >> b;
  800daf:	89 f2                	mov    %esi,%edx
  800db1:	88 c1                	mov    %al,%cl
  800db3:	d3 ea                	shr    %cl,%edx
  800db5:	89 55 e8             	mov    %edx,-0x18(%ebp)
	      n1 = (n1 << bm) | (n0 >> b);
  800db8:	89 f2                	mov    %esi,%edx
  800dba:	89 f9                	mov    %edi,%ecx
  800dbc:	d3 e2                	shl    %cl,%edx
  800dbe:	8b 75 f0             	mov    -0x10(%ebp),%esi
  800dc1:	88 c1                	mov    %al,%cl
  800dc3:	d3 ee                	shr    %cl,%esi
  800dc5:	09 d6                	or     %edx,%esi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  800dc7:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  800dca:	89 f0                	mov    %esi,%eax
  800dcc:	89 ca                	mov    %ecx,%edx
  800dce:	f7 75 ec             	divl   -0x14(%ebp)
  800dd1:	89 d1                	mov    %edx,%ecx
  800dd3:	89 c6                	mov    %eax,%esi
	      umul_ppmm (m1, m0, q0, d0);
  800dd5:	f7 65 f4             	mull   -0xc(%ebp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800dd8:	39 d1                	cmp    %edx,%ecx
  800dda:	72 28                	jb     800e04 <__udivdi3+0x110>
  800ddc:	74 1a                	je     800df8 <__udivdi3+0x104>
  800dde:	89 f7                	mov    %esi,%edi
  800de0:	31 f6                	xor    %esi,%esi
  800de2:	eb 80                	jmp    800d64 <__udivdi3+0x70>
	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  800de4:	31 f6                	xor    %esi,%esi
  800de6:	bf 01 00 00 00       	mov    $0x1,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800deb:	89 f8                	mov    %edi,%eax
  800ded:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800def:	83 c4 10             	add    $0x10,%esp
  800df2:	5e                   	pop    %esi
  800df3:	5f                   	pop    %edi
  800df4:	c9                   	leave  
  800df5:	c3                   	ret    
  800df6:	66 90                	xchg   %ax,%ax

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  800df8:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800dfb:	89 f9                	mov    %edi,%ecx
  800dfd:	d3 e2                	shl    %cl,%edx

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800dff:	39 c2                	cmp    %eax,%edx
  800e01:	73 db                	jae    800dde <__udivdi3+0xea>
  800e03:	90                   	nop
		{
		  q0--;
  800e04:	8d 7e ff             	lea    -0x1(%esi),%edi
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  800e07:	31 f6                	xor    %esi,%esi
  800e09:	e9 56 ff ff ff       	jmp    800d64 <__udivdi3+0x70>
	...

00800e10 <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  800e10:	55                   	push   %ebp
  800e11:	89 e5                	mov    %esp,%ebp
  800e13:	57                   	push   %edi
  800e14:	56                   	push   %esi
  800e15:	83 ec 20             	sub    $0x20,%esp
  800e18:	8b 45 08             	mov    0x8(%ebp),%eax
  800e1b:	8b 4d 10             	mov    0x10(%ebp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  800e1e:	89 45 e8             	mov    %eax,-0x18(%ebp)
  800e21:	8b 75 0c             	mov    0xc(%ebp),%esi
  const DWunion dd = {.ll = d};
  800e24:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  800e27:	8b 7d 14             	mov    0x14(%ebp),%edi
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  800e2a:	89 45 f0             	mov    %eax,-0x10(%ebp)
  n1 = nn.s.high;
  800e2d:	89 f2                	mov    %esi,%edx

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  800e2f:	85 ff                	test   %edi,%edi
  800e31:	75 15                	jne    800e48 <__umoddi3+0x38>
    {
      if (d0 > n1)
  800e33:	39 f1                	cmp    %esi,%ecx
  800e35:	0f 86 99 00 00 00    	jbe    800ed4 <__umoddi3+0xc4>
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800e3b:	f7 f1                	div    %ecx

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
  800e3d:	89 d0                	mov    %edx,%eax
  800e3f:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  800e41:	83 c4 20             	add    $0x20,%esp
  800e44:	5e                   	pop    %esi
  800e45:	5f                   	pop    %edi
  800e46:	c9                   	leave  
  800e47:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  800e48:	39 f7                	cmp    %esi,%edi
  800e4a:	0f 87 a4 00 00 00    	ja     800ef4 <__umoddi3+0xe4>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  800e50:	0f bd c7             	bsr    %edi,%eax
	  if (bm == 0)
  800e53:	83 f0 1f             	xor    $0x1f,%eax
  800e56:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800e59:	0f 84 a1 00 00 00    	je     800f00 <__umoddi3+0xf0>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  800e5f:	89 f8                	mov    %edi,%eax
  800e61:	8a 4d ec             	mov    -0x14(%ebp),%cl
  800e64:	d3 e0                	shl    %cl,%eax
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  800e66:	bf 20 00 00 00       	mov    $0x20,%edi
  800e6b:	2b 7d ec             	sub    -0x14(%ebp),%edi

	      d1 = (d1 << bm) | (d0 >> b);
  800e6e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800e71:	89 f9                	mov    %edi,%ecx
  800e73:	d3 ea                	shr    %cl,%edx
  800e75:	09 c2                	or     %eax,%edx
  800e77:	89 55 f0             	mov    %edx,-0x10(%ebp)
	      d0 = d0 << bm;
  800e7a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800e7d:	8a 4d ec             	mov    -0x14(%ebp),%cl
  800e80:	d3 e0                	shl    %cl,%eax
  800e82:	89 45 f4             	mov    %eax,-0xc(%ebp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  800e85:	89 f2                	mov    %esi,%edx
  800e87:	d3 e2                	shl    %cl,%edx
	      n0 = n0 << bm;
  800e89:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800e8c:	d3 e0                	shl    %cl,%eax
  800e8e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  800e91:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800e94:	89 f9                	mov    %edi,%ecx
  800e96:	d3 e8                	shr    %cl,%eax
  800e98:	09 d0                	or     %edx,%eax

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  800e9a:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  800e9c:	89 f2                	mov    %esi,%edx
  800e9e:	f7 75 f0             	divl   -0x10(%ebp)
  800ea1:	89 d6                	mov    %edx,%esi
	      umul_ppmm (m1, m0, q0, d0);
  800ea3:	f7 65 f4             	mull   -0xc(%ebp)
  800ea6:	89 55 e8             	mov    %edx,-0x18(%ebp)
  800ea9:	89 c1                	mov    %eax,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800eab:	39 d6                	cmp    %edx,%esi
  800ead:	72 71                	jb     800f20 <__umoddi3+0x110>
  800eaf:	74 7f                	je     800f30 <__umoddi3+0x120>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  800eb1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800eb4:	29 c8                	sub    %ecx,%eax
  800eb6:	19 d6                	sbb    %edx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
  800eb8:	8a 4d ec             	mov    -0x14(%ebp),%cl
  800ebb:	d3 e8                	shr    %cl,%eax
  800ebd:	89 f2                	mov    %esi,%edx
  800ebf:	89 f9                	mov    %edi,%ecx
  800ec1:	d3 e2                	shl    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
  800ec3:	09 d0                	or     %edx,%eax
  800ec5:	89 f2                	mov    %esi,%edx
  800ec7:	8a 4d ec             	mov    -0x14(%ebp),%cl
  800eca:	d3 ea                	shr    %cl,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  800ecc:	83 c4 20             	add    $0x20,%esp
  800ecf:	5e                   	pop    %esi
  800ed0:	5f                   	pop    %edi
  800ed1:	c9                   	leave  
  800ed2:	c3                   	ret    
  800ed3:	90                   	nop
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  800ed4:	85 c9                	test   %ecx,%ecx
  800ed6:	75 0b                	jne    800ee3 <__umoddi3+0xd3>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  800ed8:	b8 01 00 00 00       	mov    $0x1,%eax
  800edd:	31 d2                	xor    %edx,%edx
  800edf:	f7 f1                	div    %ecx
  800ee1:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  800ee3:	89 f0                	mov    %esi,%eax
  800ee5:	31 d2                	xor    %edx,%edx
  800ee7:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800ee9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800eec:	f7 f1                	div    %ecx
  800eee:	e9 4a ff ff ff       	jmp    800e3d <__umoddi3+0x2d>
  800ef3:	90                   	nop
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
  800ef4:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  800ef6:	83 c4 20             	add    $0x20,%esp
  800ef9:	5e                   	pop    %esi
  800efa:	5f                   	pop    %edi
  800efb:	c9                   	leave  
  800efc:	c3                   	ret    
  800efd:	8d 76 00             	lea    0x0(%esi),%esi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  800f00:	39 f7                	cmp    %esi,%edi
  800f02:	72 05                	jb     800f09 <__umoddi3+0xf9>
  800f04:	3b 4d f0             	cmp    -0x10(%ebp),%ecx
  800f07:	77 0c                	ja     800f15 <__umoddi3+0x105>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  800f09:	89 f2                	mov    %esi,%edx
  800f0b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800f0e:	29 c8                	sub    %ecx,%eax
  800f10:	19 fa                	sbb    %edi,%edx
  800f12:	89 45 f0             	mov    %eax,-0x10(%ebp)

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
  800f15:	8b 45 f0             	mov    -0x10(%ebp),%eax
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  800f18:	83 c4 20             	add    $0x20,%esp
  800f1b:	5e                   	pop    %esi
  800f1c:	5f                   	pop    %edi
  800f1d:	c9                   	leave  
  800f1e:	c3                   	ret    
  800f1f:	90                   	nop
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  800f20:	8b 55 e8             	mov    -0x18(%ebp),%edx
  800f23:	89 c1                	mov    %eax,%ecx
  800f25:	2b 4d f4             	sub    -0xc(%ebp),%ecx
  800f28:	1b 55 f0             	sbb    -0x10(%ebp),%edx
  800f2b:	eb 84                	jmp    800eb1 <__umoddi3+0xa1>
  800f2d:	8d 76 00             	lea    0x0(%esi),%esi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800f30:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  800f33:	72 eb                	jb     800f20 <__umoddi3+0x110>
  800f35:	89 f2                	mov    %esi,%edx
  800f37:	e9 75 ff ff ff       	jmp    800eb1 <__umoddi3+0xa1>
