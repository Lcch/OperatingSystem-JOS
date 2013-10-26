
obj/user/faultnostack:     file format elf32-i386


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
  80003a:	68 d8 02 80 00       	push   $0x8002d8
  80003f:	6a 00                	push   $0x0
  800041:	e8 02 02 00 00       	call   800248 <sys_env_set_pgfault_upcall>
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
  800063:	e8 05 01 00 00       	call   80016d <sys_getenvid>
  800068:	25 ff 03 00 00       	and    $0x3ff,%eax
  80006d:	c1 e0 07             	shl    $0x7,%eax
  800070:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800075:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80007a:	85 f6                	test   %esi,%esi
  80007c:	7e 07                	jle    800085 <libmain+0x2d>
		binaryname = argv[0];
  80007e:	8b 03                	mov    (%ebx),%eax
  800080:	a3 00 20 80 00       	mov    %eax,0x802000
	// call user main routine
	umain(argc, argv);
  800085:	83 ec 08             	sub    $0x8,%esp
  800088:	53                   	push   %ebx
  800089:	56                   	push   %esi
  80008a:	e8 a5 ff ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  80008f:	e8 0c 00 00 00       	call   8000a0 <exit>
  800094:	83 c4 10             	add    $0x10,%esp
}
  800097:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80009a:	5b                   	pop    %ebx
  80009b:	5e                   	pop    %esi
  80009c:	c9                   	leave  
  80009d:	c3                   	ret    
	...

008000a0 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000a0:	55                   	push   %ebp
  8000a1:	89 e5                	mov    %esp,%ebp
  8000a3:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
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
  8000e6:	68 ca 0f 80 00       	push   $0x800fca
  8000eb:	6a 42                	push   $0x42
  8000ed:	68 e7 0f 80 00       	push   $0x800fe7
  8000f2:	e8 09 02 00 00       	call   800300 <_panic>

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
  8001a9:	b8 0a 00 00 00       	mov    $0xa,%eax
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

00800248 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800248:	55                   	push   %ebp
  800249:	89 e5                	mov    %esp,%ebp
  80024b:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
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

0080026b <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  80026b:	55                   	push   %ebp
  80026c:	89 e5                	mov    %esp,%ebp
  80026e:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
  800271:	6a 00                	push   $0x0
  800273:	ff 75 14             	pushl  0x14(%ebp)
  800276:	ff 75 10             	pushl  0x10(%ebp)
  800279:	ff 75 0c             	pushl  0xc(%ebp)
  80027c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80027f:	ba 00 00 00 00       	mov    $0x0,%edx
  800284:	b8 0b 00 00 00       	mov    $0xb,%eax
  800289:	e8 26 fe ff ff       	call   8000b4 <syscall>
}
  80028e:	c9                   	leave  
  80028f:	c3                   	ret    

00800290 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800290:	55                   	push   %ebp
  800291:	89 e5                	mov    %esp,%ebp
  800293:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
  800296:	6a 00                	push   $0x0
  800298:	6a 00                	push   $0x0
  80029a:	6a 00                	push   $0x0
  80029c:	6a 00                	push   $0x0
  80029e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8002a1:	ba 01 00 00 00       	mov    $0x1,%edx
  8002a6:	b8 0c 00 00 00       	mov    $0xc,%eax
  8002ab:	e8 04 fe ff ff       	call   8000b4 <syscall>
}
  8002b0:	c9                   	leave  
  8002b1:	c3                   	ret    

008002b2 <sys_set_priority>:

int
sys_set_priority(envid_t envid, uint32_t new_priority)
{
  8002b2:	55                   	push   %ebp
  8002b3:	89 e5                	mov    %esp,%ebp
  8002b5:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_set_priority, 0, envid, new_priority, 0, 0, 0);
  8002b8:	6a 00                	push   $0x0
  8002ba:	6a 00                	push   $0x0
  8002bc:	6a 00                	push   $0x0
  8002be:	ff 75 0c             	pushl  0xc(%ebp)
  8002c1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8002c4:	ba 00 00 00 00       	mov    $0x0,%edx
  8002c9:	b8 0d 00 00 00       	mov    $0xd,%eax
  8002ce:	e8 e1 fd ff ff       	call   8000b4 <syscall>
}
  8002d3:	c9                   	leave  
  8002d4:	c3                   	ret    
  8002d5:	00 00                	add    %al,(%eax)
	...

008002d8 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  8002d8:	54                   	push   %esp
	movl _pgfault_handler, %eax
  8002d9:	a1 08 20 80 00       	mov    0x802008,%eax
	call *%eax
  8002de:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  8002e0:	83 c4 04             	add    $0x4,%esp
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	
	// fix old esp
	movl 0x30(%esp), %eax
  8002e3:	8b 44 24 30          	mov    0x30(%esp),%eax
	subl $0x4, %eax
  8002e7:	83 e8 04             	sub    $0x4,%eax
	movl %eax, 0x30(%esp)
  8002ea:	89 44 24 30          	mov    %eax,0x30(%esp)

	// set trap-time %eip
	movl 0x28(%esp), %ebx
  8002ee:	8b 5c 24 28          	mov    0x28(%esp),%ebx
	movl %ebx, (%eax)
  8002f2:	89 18                	mov    %ebx,(%eax)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	addl $0x08, %esp 	// ignore err_code and fault_va
  8002f4:	83 c4 08             	add    $0x8,%esp
	popal 				// restore registers
  8002f7:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $0x04, %esp 	// ignore eip 
  8002f8:	83 c4 04             	add    $0x4,%esp
	popfl				// modify eflags
  8002fb:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp
  8002fc:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  8002fd:	c3                   	ret    
	...

00800300 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800300:	55                   	push   %ebp
  800301:	89 e5                	mov    %esp,%ebp
  800303:	56                   	push   %esi
  800304:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800305:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800308:	8b 1d 00 20 80 00    	mov    0x802000,%ebx
  80030e:	e8 5a fe ff ff       	call   80016d <sys_getenvid>
  800313:	83 ec 0c             	sub    $0xc,%esp
  800316:	ff 75 0c             	pushl  0xc(%ebp)
  800319:	ff 75 08             	pushl  0x8(%ebp)
  80031c:	53                   	push   %ebx
  80031d:	50                   	push   %eax
  80031e:	68 f8 0f 80 00       	push   $0x800ff8
  800323:	e8 b0 00 00 00       	call   8003d8 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800328:	83 c4 18             	add    $0x18,%esp
  80032b:	56                   	push   %esi
  80032c:	ff 75 10             	pushl  0x10(%ebp)
  80032f:	e8 53 00 00 00       	call   800387 <vcprintf>
	cprintf("\n");
  800334:	c7 04 24 7d 12 80 00 	movl   $0x80127d,(%esp)
  80033b:	e8 98 00 00 00       	call   8003d8 <cprintf>
  800340:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800343:	cc                   	int3   
  800344:	eb fd                	jmp    800343 <_panic+0x43>
	...

00800348 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800348:	55                   	push   %ebp
  800349:	89 e5                	mov    %esp,%ebp
  80034b:	53                   	push   %ebx
  80034c:	83 ec 04             	sub    $0x4,%esp
  80034f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800352:	8b 03                	mov    (%ebx),%eax
  800354:	8b 55 08             	mov    0x8(%ebp),%edx
  800357:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  80035b:	40                   	inc    %eax
  80035c:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  80035e:	3d ff 00 00 00       	cmp    $0xff,%eax
  800363:	75 1a                	jne    80037f <putch+0x37>
		sys_cputs(b->buf, b->idx);
  800365:	83 ec 08             	sub    $0x8,%esp
  800368:	68 ff 00 00 00       	push   $0xff
  80036d:	8d 43 08             	lea    0x8(%ebx),%eax
  800370:	50                   	push   %eax
  800371:	e8 8b fd ff ff       	call   800101 <sys_cputs>
		b->idx = 0;
  800376:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80037c:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  80037f:	ff 43 04             	incl   0x4(%ebx)
}
  800382:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800385:	c9                   	leave  
  800386:	c3                   	ret    

00800387 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800387:	55                   	push   %ebp
  800388:	89 e5                	mov    %esp,%ebp
  80038a:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800390:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800397:	00 00 00 
	b.cnt = 0;
  80039a:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8003a1:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8003a4:	ff 75 0c             	pushl  0xc(%ebp)
  8003a7:	ff 75 08             	pushl  0x8(%ebp)
  8003aa:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8003b0:	50                   	push   %eax
  8003b1:	68 48 03 80 00       	push   $0x800348
  8003b6:	e8 82 01 00 00       	call   80053d <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8003bb:	83 c4 08             	add    $0x8,%esp
  8003be:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8003c4:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8003ca:	50                   	push   %eax
  8003cb:	e8 31 fd ff ff       	call   800101 <sys_cputs>

	return b.cnt;
}
  8003d0:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8003d6:	c9                   	leave  
  8003d7:	c3                   	ret    

008003d8 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8003d8:	55                   	push   %ebp
  8003d9:	89 e5                	mov    %esp,%ebp
  8003db:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8003de:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8003e1:	50                   	push   %eax
  8003e2:	ff 75 08             	pushl  0x8(%ebp)
  8003e5:	e8 9d ff ff ff       	call   800387 <vcprintf>
	va_end(ap);

	return cnt;
}
  8003ea:	c9                   	leave  
  8003eb:	c3                   	ret    

008003ec <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8003ec:	55                   	push   %ebp
  8003ed:	89 e5                	mov    %esp,%ebp
  8003ef:	57                   	push   %edi
  8003f0:	56                   	push   %esi
  8003f1:	53                   	push   %ebx
  8003f2:	83 ec 2c             	sub    $0x2c,%esp
  8003f5:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8003f8:	89 d6                	mov    %edx,%esi
  8003fa:	8b 45 08             	mov    0x8(%ebp),%eax
  8003fd:	8b 55 0c             	mov    0xc(%ebp),%edx
  800400:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800403:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800406:	8b 45 10             	mov    0x10(%ebp),%eax
  800409:	8b 5d 14             	mov    0x14(%ebp),%ebx
  80040c:	8b 7d 18             	mov    0x18(%ebp),%edi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80040f:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800412:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  800419:	39 55 d4             	cmp    %edx,-0x2c(%ebp)
  80041c:	72 0c                	jb     80042a <printnum+0x3e>
  80041e:	3b 45 d8             	cmp    -0x28(%ebp),%eax
  800421:	76 07                	jbe    80042a <printnum+0x3e>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800423:	4b                   	dec    %ebx
  800424:	85 db                	test   %ebx,%ebx
  800426:	7f 31                	jg     800459 <printnum+0x6d>
  800428:	eb 3f                	jmp    800469 <printnum+0x7d>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80042a:	83 ec 0c             	sub    $0xc,%esp
  80042d:	57                   	push   %edi
  80042e:	4b                   	dec    %ebx
  80042f:	53                   	push   %ebx
  800430:	50                   	push   %eax
  800431:	83 ec 08             	sub    $0x8,%esp
  800434:	ff 75 d4             	pushl  -0x2c(%ebp)
  800437:	ff 75 d0             	pushl  -0x30(%ebp)
  80043a:	ff 75 dc             	pushl  -0x24(%ebp)
  80043d:	ff 75 d8             	pushl  -0x28(%ebp)
  800440:	e8 33 09 00 00       	call   800d78 <__udivdi3>
  800445:	83 c4 18             	add    $0x18,%esp
  800448:	52                   	push   %edx
  800449:	50                   	push   %eax
  80044a:	89 f2                	mov    %esi,%edx
  80044c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80044f:	e8 98 ff ff ff       	call   8003ec <printnum>
  800454:	83 c4 20             	add    $0x20,%esp
  800457:	eb 10                	jmp    800469 <printnum+0x7d>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800459:	83 ec 08             	sub    $0x8,%esp
  80045c:	56                   	push   %esi
  80045d:	57                   	push   %edi
  80045e:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800461:	4b                   	dec    %ebx
  800462:	83 c4 10             	add    $0x10,%esp
  800465:	85 db                	test   %ebx,%ebx
  800467:	7f f0                	jg     800459 <printnum+0x6d>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800469:	83 ec 08             	sub    $0x8,%esp
  80046c:	56                   	push   %esi
  80046d:	83 ec 04             	sub    $0x4,%esp
  800470:	ff 75 d4             	pushl  -0x2c(%ebp)
  800473:	ff 75 d0             	pushl  -0x30(%ebp)
  800476:	ff 75 dc             	pushl  -0x24(%ebp)
  800479:	ff 75 d8             	pushl  -0x28(%ebp)
  80047c:	e8 13 0a 00 00       	call   800e94 <__umoddi3>
  800481:	83 c4 14             	add    $0x14,%esp
  800484:	0f be 80 1b 10 80 00 	movsbl 0x80101b(%eax),%eax
  80048b:	50                   	push   %eax
  80048c:	ff 55 e4             	call   *-0x1c(%ebp)
  80048f:	83 c4 10             	add    $0x10,%esp
}
  800492:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800495:	5b                   	pop    %ebx
  800496:	5e                   	pop    %esi
  800497:	5f                   	pop    %edi
  800498:	c9                   	leave  
  800499:	c3                   	ret    

0080049a <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80049a:	55                   	push   %ebp
  80049b:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80049d:	83 fa 01             	cmp    $0x1,%edx
  8004a0:	7e 0e                	jle    8004b0 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8004a2:	8b 10                	mov    (%eax),%edx
  8004a4:	8d 4a 08             	lea    0x8(%edx),%ecx
  8004a7:	89 08                	mov    %ecx,(%eax)
  8004a9:	8b 02                	mov    (%edx),%eax
  8004ab:	8b 52 04             	mov    0x4(%edx),%edx
  8004ae:	eb 22                	jmp    8004d2 <getuint+0x38>
	else if (lflag)
  8004b0:	85 d2                	test   %edx,%edx
  8004b2:	74 10                	je     8004c4 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8004b4:	8b 10                	mov    (%eax),%edx
  8004b6:	8d 4a 04             	lea    0x4(%edx),%ecx
  8004b9:	89 08                	mov    %ecx,(%eax)
  8004bb:	8b 02                	mov    (%edx),%eax
  8004bd:	ba 00 00 00 00       	mov    $0x0,%edx
  8004c2:	eb 0e                	jmp    8004d2 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8004c4:	8b 10                	mov    (%eax),%edx
  8004c6:	8d 4a 04             	lea    0x4(%edx),%ecx
  8004c9:	89 08                	mov    %ecx,(%eax)
  8004cb:	8b 02                	mov    (%edx),%eax
  8004cd:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8004d2:	c9                   	leave  
  8004d3:	c3                   	ret    

008004d4 <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
  8004d4:	55                   	push   %ebp
  8004d5:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8004d7:	83 fa 01             	cmp    $0x1,%edx
  8004da:	7e 0e                	jle    8004ea <getint+0x16>
		return va_arg(*ap, long long);
  8004dc:	8b 10                	mov    (%eax),%edx
  8004de:	8d 4a 08             	lea    0x8(%edx),%ecx
  8004e1:	89 08                	mov    %ecx,(%eax)
  8004e3:	8b 02                	mov    (%edx),%eax
  8004e5:	8b 52 04             	mov    0x4(%edx),%edx
  8004e8:	eb 1a                	jmp    800504 <getint+0x30>
	else if (lflag)
  8004ea:	85 d2                	test   %edx,%edx
  8004ec:	74 0c                	je     8004fa <getint+0x26>
		return va_arg(*ap, long);
  8004ee:	8b 10                	mov    (%eax),%edx
  8004f0:	8d 4a 04             	lea    0x4(%edx),%ecx
  8004f3:	89 08                	mov    %ecx,(%eax)
  8004f5:	8b 02                	mov    (%edx),%eax
  8004f7:	99                   	cltd   
  8004f8:	eb 0a                	jmp    800504 <getint+0x30>
	else
		return va_arg(*ap, int);
  8004fa:	8b 10                	mov    (%eax),%edx
  8004fc:	8d 4a 04             	lea    0x4(%edx),%ecx
  8004ff:	89 08                	mov    %ecx,(%eax)
  800501:	8b 02                	mov    (%edx),%eax
  800503:	99                   	cltd   
}
  800504:	c9                   	leave  
  800505:	c3                   	ret    

00800506 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800506:	55                   	push   %ebp
  800507:	89 e5                	mov    %esp,%ebp
  800509:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80050c:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  80050f:	8b 10                	mov    (%eax),%edx
  800511:	3b 50 04             	cmp    0x4(%eax),%edx
  800514:	73 08                	jae    80051e <sprintputch+0x18>
		*b->buf++ = ch;
  800516:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800519:	88 0a                	mov    %cl,(%edx)
  80051b:	42                   	inc    %edx
  80051c:	89 10                	mov    %edx,(%eax)
}
  80051e:	c9                   	leave  
  80051f:	c3                   	ret    

00800520 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800520:	55                   	push   %ebp
  800521:	89 e5                	mov    %esp,%ebp
  800523:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800526:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800529:	50                   	push   %eax
  80052a:	ff 75 10             	pushl  0x10(%ebp)
  80052d:	ff 75 0c             	pushl  0xc(%ebp)
  800530:	ff 75 08             	pushl  0x8(%ebp)
  800533:	e8 05 00 00 00       	call   80053d <vprintfmt>
	va_end(ap);
  800538:	83 c4 10             	add    $0x10,%esp
}
  80053b:	c9                   	leave  
  80053c:	c3                   	ret    

0080053d <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80053d:	55                   	push   %ebp
  80053e:	89 e5                	mov    %esp,%ebp
  800540:	57                   	push   %edi
  800541:	56                   	push   %esi
  800542:	53                   	push   %ebx
  800543:	83 ec 2c             	sub    $0x2c,%esp
  800546:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800549:	8b 75 10             	mov    0x10(%ebp),%esi
  80054c:	eb 13                	jmp    800561 <vprintfmt+0x24>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  80054e:	85 c0                	test   %eax,%eax
  800550:	0f 84 6d 03 00 00    	je     8008c3 <vprintfmt+0x386>
				return;
			putch(ch, putdat);
  800556:	83 ec 08             	sub    $0x8,%esp
  800559:	57                   	push   %edi
  80055a:	50                   	push   %eax
  80055b:	ff 55 08             	call   *0x8(%ebp)
  80055e:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800561:	0f b6 06             	movzbl (%esi),%eax
  800564:	46                   	inc    %esi
  800565:	83 f8 25             	cmp    $0x25,%eax
  800568:	75 e4                	jne    80054e <vprintfmt+0x11>
  80056a:	c6 45 dc 20          	movb   $0x20,-0x24(%ebp)
  80056e:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  800575:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
  80057c:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  800583:	b9 00 00 00 00       	mov    $0x0,%ecx
  800588:	eb 28                	jmp    8005b2 <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80058a:	89 de                	mov    %ebx,%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  80058c:	c6 45 dc 2d          	movb   $0x2d,-0x24(%ebp)
  800590:	eb 20                	jmp    8005b2 <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800592:	89 de                	mov    %ebx,%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800594:	c6 45 dc 30          	movb   $0x30,-0x24(%ebp)
  800598:	eb 18                	jmp    8005b2 <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80059a:	89 de                	mov    %ebx,%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  80059c:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  8005a3:	eb 0d                	jmp    8005b2 <vprintfmt+0x75>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  8005a5:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8005a8:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8005ab:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005b2:	8a 06                	mov    (%esi),%al
  8005b4:	0f b6 d0             	movzbl %al,%edx
  8005b7:	8d 5e 01             	lea    0x1(%esi),%ebx
  8005ba:	83 e8 23             	sub    $0x23,%eax
  8005bd:	3c 55                	cmp    $0x55,%al
  8005bf:	0f 87 e0 02 00 00    	ja     8008a5 <vprintfmt+0x368>
  8005c5:	0f b6 c0             	movzbl %al,%eax
  8005c8:	ff 24 85 e0 10 80 00 	jmp    *0x8010e0(,%eax,4)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8005cf:	83 ea 30             	sub    $0x30,%edx
  8005d2:	89 55 d4             	mov    %edx,-0x2c(%ebp)
				ch = *fmt;
  8005d5:	0f be 03             	movsbl (%ebx),%eax
				if (ch < '0' || ch > '9')
  8005d8:	8d 50 d0             	lea    -0x30(%eax),%edx
  8005db:	83 fa 09             	cmp    $0x9,%edx
  8005de:	77 44                	ja     800624 <vprintfmt+0xe7>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005e0:	89 de                	mov    %ebx,%esi
  8005e2:	8b 55 d4             	mov    -0x2c(%ebp),%edx
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8005e5:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
  8005e6:	8d 14 92             	lea    (%edx,%edx,4),%edx
  8005e9:	8d 54 50 d0          	lea    -0x30(%eax,%edx,2),%edx
				ch = *fmt;
  8005ed:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  8005f0:	8d 58 d0             	lea    -0x30(%eax),%ebx
  8005f3:	83 fb 09             	cmp    $0x9,%ebx
  8005f6:	76 ed                	jbe    8005e5 <vprintfmt+0xa8>
  8005f8:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  8005fb:	eb 29                	jmp    800626 <vprintfmt+0xe9>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8005fd:	8b 45 14             	mov    0x14(%ebp),%eax
  800600:	8d 50 04             	lea    0x4(%eax),%edx
  800603:	89 55 14             	mov    %edx,0x14(%ebp)
  800606:	8b 00                	mov    (%eax),%eax
  800608:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80060b:	89 de                	mov    %ebx,%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  80060d:	eb 17                	jmp    800626 <vprintfmt+0xe9>

		case '.':
			if (width < 0)
  80060f:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800613:	78 85                	js     80059a <vprintfmt+0x5d>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800615:	89 de                	mov    %ebx,%esi
  800617:	eb 99                	jmp    8005b2 <vprintfmt+0x75>
  800619:	89 de                	mov    %ebx,%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  80061b:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
			goto reswitch;
  800622:	eb 8e                	jmp    8005b2 <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800624:	89 de                	mov    %ebx,%esi
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  800626:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80062a:	79 86                	jns    8005b2 <vprintfmt+0x75>
  80062c:	e9 74 ff ff ff       	jmp    8005a5 <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800631:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800632:	89 de                	mov    %ebx,%esi
  800634:	e9 79 ff ff ff       	jmp    8005b2 <vprintfmt+0x75>
  800639:	89 5d d8             	mov    %ebx,-0x28(%ebp)
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80063c:	8b 45 14             	mov    0x14(%ebp),%eax
  80063f:	8d 50 04             	lea    0x4(%eax),%edx
  800642:	89 55 14             	mov    %edx,0x14(%ebp)
  800645:	83 ec 08             	sub    $0x8,%esp
  800648:	57                   	push   %edi
  800649:	ff 30                	pushl  (%eax)
  80064b:	ff 55 08             	call   *0x8(%ebp)
			break;
  80064e:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800651:	8b 75 d8             	mov    -0x28(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800654:	e9 08 ff ff ff       	jmp    800561 <vprintfmt+0x24>
  800659:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// error message
		case 'e':
			err = va_arg(ap, int);
  80065c:	8b 45 14             	mov    0x14(%ebp),%eax
  80065f:	8d 50 04             	lea    0x4(%eax),%edx
  800662:	89 55 14             	mov    %edx,0x14(%ebp)
  800665:	8b 00                	mov    (%eax),%eax
  800667:	85 c0                	test   %eax,%eax
  800669:	79 02                	jns    80066d <vprintfmt+0x130>
  80066b:	f7 d8                	neg    %eax
  80066d:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80066f:	83 f8 08             	cmp    $0x8,%eax
  800672:	7f 0b                	jg     80067f <vprintfmt+0x142>
  800674:	8b 04 85 40 12 80 00 	mov    0x801240(,%eax,4),%eax
  80067b:	85 c0                	test   %eax,%eax
  80067d:	75 1a                	jne    800699 <vprintfmt+0x15c>
				printfmt(putch, putdat, "error %d", err);
  80067f:	52                   	push   %edx
  800680:	68 33 10 80 00       	push   $0x801033
  800685:	57                   	push   %edi
  800686:	ff 75 08             	pushl  0x8(%ebp)
  800689:	e8 92 fe ff ff       	call   800520 <printfmt>
  80068e:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800691:	8b 75 d8             	mov    -0x28(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800694:	e9 c8 fe ff ff       	jmp    800561 <vprintfmt+0x24>
			else
				printfmt(putch, putdat, "%s", p);
  800699:	50                   	push   %eax
  80069a:	68 3c 10 80 00       	push   $0x80103c
  80069f:	57                   	push   %edi
  8006a0:	ff 75 08             	pushl  0x8(%ebp)
  8006a3:	e8 78 fe ff ff       	call   800520 <printfmt>
  8006a8:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006ab:	8b 75 d8             	mov    -0x28(%ebp),%esi
  8006ae:	e9 ae fe ff ff       	jmp    800561 <vprintfmt+0x24>
  8006b3:	89 5d d8             	mov    %ebx,-0x28(%ebp)
  8006b6:	89 de                	mov    %ebx,%esi
  8006b8:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  8006bb:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8006be:	8b 45 14             	mov    0x14(%ebp),%eax
  8006c1:	8d 50 04             	lea    0x4(%eax),%edx
  8006c4:	89 55 14             	mov    %edx,0x14(%ebp)
  8006c7:	8b 00                	mov    (%eax),%eax
  8006c9:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8006cc:	85 c0                	test   %eax,%eax
  8006ce:	75 07                	jne    8006d7 <vprintfmt+0x19a>
				p = "(null)";
  8006d0:	c7 45 d0 2c 10 80 00 	movl   $0x80102c,-0x30(%ebp)
			if (width > 0 && padc != '-')
  8006d7:	85 db                	test   %ebx,%ebx
  8006d9:	7e 42                	jle    80071d <vprintfmt+0x1e0>
  8006db:	80 7d dc 2d          	cmpb   $0x2d,-0x24(%ebp)
  8006df:	74 3c                	je     80071d <vprintfmt+0x1e0>
				for (width -= strnlen(p, precision); width > 0; width--)
  8006e1:	83 ec 08             	sub    $0x8,%esp
  8006e4:	51                   	push   %ecx
  8006e5:	ff 75 d0             	pushl  -0x30(%ebp)
  8006e8:	e8 6f 02 00 00       	call   80095c <strnlen>
  8006ed:	29 c3                	sub    %eax,%ebx
  8006ef:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8006f2:	83 c4 10             	add    $0x10,%esp
  8006f5:	85 db                	test   %ebx,%ebx
  8006f7:	7e 24                	jle    80071d <vprintfmt+0x1e0>
					putch(padc, putdat);
  8006f9:	0f be 5d dc          	movsbl -0x24(%ebp),%ebx
  8006fd:	89 75 dc             	mov    %esi,-0x24(%ebp)
  800700:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  800703:	83 ec 08             	sub    $0x8,%esp
  800706:	57                   	push   %edi
  800707:	53                   	push   %ebx
  800708:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80070b:	4e                   	dec    %esi
  80070c:	83 c4 10             	add    $0x10,%esp
  80070f:	85 f6                	test   %esi,%esi
  800711:	7f f0                	jg     800703 <vprintfmt+0x1c6>
  800713:	8b 75 dc             	mov    -0x24(%ebp),%esi
  800716:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80071d:	8b 55 d0             	mov    -0x30(%ebp),%edx
  800720:	0f be 02             	movsbl (%edx),%eax
  800723:	85 c0                	test   %eax,%eax
  800725:	75 47                	jne    80076e <vprintfmt+0x231>
  800727:	eb 37                	jmp    800760 <vprintfmt+0x223>
				if (altflag && (ch < ' ' || ch > '~'))
  800729:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80072d:	74 16                	je     800745 <vprintfmt+0x208>
  80072f:	8d 50 e0             	lea    -0x20(%eax),%edx
  800732:	83 fa 5e             	cmp    $0x5e,%edx
  800735:	76 0e                	jbe    800745 <vprintfmt+0x208>
					putch('?', putdat);
  800737:	83 ec 08             	sub    $0x8,%esp
  80073a:	57                   	push   %edi
  80073b:	6a 3f                	push   $0x3f
  80073d:	ff 55 08             	call   *0x8(%ebp)
  800740:	83 c4 10             	add    $0x10,%esp
  800743:	eb 0b                	jmp    800750 <vprintfmt+0x213>
				else
					putch(ch, putdat);
  800745:	83 ec 08             	sub    $0x8,%esp
  800748:	57                   	push   %edi
  800749:	50                   	push   %eax
  80074a:	ff 55 08             	call   *0x8(%ebp)
  80074d:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800750:	ff 4d e4             	decl   -0x1c(%ebp)
  800753:	0f be 03             	movsbl (%ebx),%eax
  800756:	85 c0                	test   %eax,%eax
  800758:	74 03                	je     80075d <vprintfmt+0x220>
  80075a:	43                   	inc    %ebx
  80075b:	eb 1b                	jmp    800778 <vprintfmt+0x23b>
  80075d:	8b 75 dc             	mov    -0x24(%ebp),%esi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800760:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800764:	7f 1e                	jg     800784 <vprintfmt+0x247>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800766:	8b 75 d8             	mov    -0x28(%ebp),%esi
  800769:	e9 f3 fd ff ff       	jmp    800561 <vprintfmt+0x24>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80076e:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  800771:	43                   	inc    %ebx
  800772:	89 75 dc             	mov    %esi,-0x24(%ebp)
  800775:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  800778:	85 f6                	test   %esi,%esi
  80077a:	78 ad                	js     800729 <vprintfmt+0x1ec>
  80077c:	4e                   	dec    %esi
  80077d:	79 aa                	jns    800729 <vprintfmt+0x1ec>
  80077f:	8b 75 dc             	mov    -0x24(%ebp),%esi
  800782:	eb dc                	jmp    800760 <vprintfmt+0x223>
  800784:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800787:	83 ec 08             	sub    $0x8,%esp
  80078a:	57                   	push   %edi
  80078b:	6a 20                	push   $0x20
  80078d:	ff 55 08             	call   *0x8(%ebp)
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800790:	4b                   	dec    %ebx
  800791:	83 c4 10             	add    $0x10,%esp
  800794:	85 db                	test   %ebx,%ebx
  800796:	7f ef                	jg     800787 <vprintfmt+0x24a>
  800798:	e9 c4 fd ff ff       	jmp    800561 <vprintfmt+0x24>
  80079d:	89 5d d8             	mov    %ebx,-0x28(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8007a0:	89 ca                	mov    %ecx,%edx
  8007a2:	8d 45 14             	lea    0x14(%ebp),%eax
  8007a5:	e8 2a fd ff ff       	call   8004d4 <getint>
  8007aa:	89 c3                	mov    %eax,%ebx
  8007ac:	89 d6                	mov    %edx,%esi
			if ((long long) num < 0) {
  8007ae:	85 d2                	test   %edx,%edx
  8007b0:	78 0a                	js     8007bc <vprintfmt+0x27f>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8007b2:	b8 0a 00 00 00       	mov    $0xa,%eax
  8007b7:	e9 b0 00 00 00       	jmp    80086c <vprintfmt+0x32f>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  8007bc:	83 ec 08             	sub    $0x8,%esp
  8007bf:	57                   	push   %edi
  8007c0:	6a 2d                	push   $0x2d
  8007c2:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  8007c5:	f7 db                	neg    %ebx
  8007c7:	83 d6 00             	adc    $0x0,%esi
  8007ca:	f7 de                	neg    %esi
  8007cc:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  8007cf:	b8 0a 00 00 00       	mov    $0xa,%eax
  8007d4:	e9 93 00 00 00       	jmp    80086c <vprintfmt+0x32f>
  8007d9:	89 5d d8             	mov    %ebx,-0x28(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8007dc:	89 ca                	mov    %ecx,%edx
  8007de:	8d 45 14             	lea    0x14(%ebp),%eax
  8007e1:	e8 b4 fc ff ff       	call   80049a <getuint>
  8007e6:	89 c3                	mov    %eax,%ebx
  8007e8:	89 d6                	mov    %edx,%esi
			base = 10;
  8007ea:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  8007ef:	eb 7b                	jmp    80086c <vprintfmt+0x32f>
  8007f1:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// (unsigned) octal
		case 'o':
            // (MIT 6.828, lab1, Ex.8)  my code : 
            num = getint(&ap, lflag);
  8007f4:	89 ca                	mov    %ecx,%edx
  8007f6:	8d 45 14             	lea    0x14(%ebp),%eax
  8007f9:	e8 d6 fc ff ff       	call   8004d4 <getint>
  8007fe:	89 c3                	mov    %eax,%ebx
  800800:	89 d6                	mov    %edx,%esi
            if ((long long) num < 0) {
  800802:	85 d2                	test   %edx,%edx
  800804:	78 07                	js     80080d <vprintfmt+0x2d0>
                putch('-', putdat);
                num = -(long long) num;
            }
            base = 8;
  800806:	b8 08 00 00 00       	mov    $0x8,%eax
  80080b:	eb 5f                	jmp    80086c <vprintfmt+0x32f>
		// (unsigned) octal
		case 'o':
            // (MIT 6.828, lab1, Ex.8)  my code : 
            num = getint(&ap, lflag);
            if ((long long) num < 0) {
                putch('-', putdat);
  80080d:	83 ec 08             	sub    $0x8,%esp
  800810:	57                   	push   %edi
  800811:	6a 2d                	push   $0x2d
  800813:	ff 55 08             	call   *0x8(%ebp)
                num = -(long long) num;
  800816:	f7 db                	neg    %ebx
  800818:	83 d6 00             	adc    $0x0,%esi
  80081b:	f7 de                	neg    %esi
  80081d:	83 c4 10             	add    $0x10,%esp
            }
            base = 8;
  800820:	b8 08 00 00 00       	mov    $0x8,%eax
  800825:	eb 45                	jmp    80086c <vprintfmt+0x32f>
  800827:	89 5d d8             	mov    %ebx,-0x28(%ebp)
            goto number;

        // pointer
		case 'p':
			putch('0', putdat);
  80082a:	83 ec 08             	sub    $0x8,%esp
  80082d:	57                   	push   %edi
  80082e:	6a 30                	push   $0x30
  800830:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  800833:	83 c4 08             	add    $0x8,%esp
  800836:	57                   	push   %edi
  800837:	6a 78                	push   $0x78
  800839:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  80083c:	8b 45 14             	mov    0x14(%ebp),%eax
  80083f:	8d 50 04             	lea    0x4(%eax),%edx
  800842:	89 55 14             	mov    %edx,0x14(%ebp)

        // pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800845:	8b 18                	mov    (%eax),%ebx
  800847:	be 00 00 00 00       	mov    $0x0,%esi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  80084c:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  80084f:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  800854:	eb 16                	jmp    80086c <vprintfmt+0x32f>
  800856:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800859:	89 ca                	mov    %ecx,%edx
  80085b:	8d 45 14             	lea    0x14(%ebp),%eax
  80085e:	e8 37 fc ff ff       	call   80049a <getuint>
  800863:	89 c3                	mov    %eax,%ebx
  800865:	89 d6                	mov    %edx,%esi
			base = 16;
  800867:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  80086c:	83 ec 0c             	sub    $0xc,%esp
  80086f:	0f be 55 dc          	movsbl -0x24(%ebp),%edx
  800873:	52                   	push   %edx
  800874:	ff 75 e4             	pushl  -0x1c(%ebp)
  800877:	50                   	push   %eax
  800878:	56                   	push   %esi
  800879:	53                   	push   %ebx
  80087a:	89 fa                	mov    %edi,%edx
  80087c:	8b 45 08             	mov    0x8(%ebp),%eax
  80087f:	e8 68 fb ff ff       	call   8003ec <printnum>
			break;
  800884:	83 c4 20             	add    $0x20,%esp
  800887:	8b 75 d8             	mov    -0x28(%ebp),%esi
  80088a:	e9 d2 fc ff ff       	jmp    800561 <vprintfmt+0x24>
  80088f:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800892:	83 ec 08             	sub    $0x8,%esp
  800895:	57                   	push   %edi
  800896:	52                   	push   %edx
  800897:	ff 55 08             	call   *0x8(%ebp)
			break;
  80089a:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80089d:	8b 75 d8             	mov    -0x28(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8008a0:	e9 bc fc ff ff       	jmp    800561 <vprintfmt+0x24>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8008a5:	83 ec 08             	sub    $0x8,%esp
  8008a8:	57                   	push   %edi
  8008a9:	6a 25                	push   $0x25
  8008ab:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  8008ae:	83 c4 10             	add    $0x10,%esp
  8008b1:	eb 02                	jmp    8008b5 <vprintfmt+0x378>
  8008b3:	89 c6                	mov    %eax,%esi
  8008b5:	8d 46 ff             	lea    -0x1(%esi),%eax
  8008b8:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  8008bc:	75 f5                	jne    8008b3 <vprintfmt+0x376>
  8008be:	e9 9e fc ff ff       	jmp    800561 <vprintfmt+0x24>
				/* do nothing */;
			break;
		}
	}
}
  8008c3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8008c6:	5b                   	pop    %ebx
  8008c7:	5e                   	pop    %esi
  8008c8:	5f                   	pop    %edi
  8008c9:	c9                   	leave  
  8008ca:	c3                   	ret    

008008cb <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8008cb:	55                   	push   %ebp
  8008cc:	89 e5                	mov    %esp,%ebp
  8008ce:	83 ec 18             	sub    $0x18,%esp
  8008d1:	8b 45 08             	mov    0x8(%ebp),%eax
  8008d4:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8008d7:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8008da:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8008de:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8008e1:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8008e8:	85 c0                	test   %eax,%eax
  8008ea:	74 26                	je     800912 <vsnprintf+0x47>
  8008ec:	85 d2                	test   %edx,%edx
  8008ee:	7e 29                	jle    800919 <vsnprintf+0x4e>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8008f0:	ff 75 14             	pushl  0x14(%ebp)
  8008f3:	ff 75 10             	pushl  0x10(%ebp)
  8008f6:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8008f9:	50                   	push   %eax
  8008fa:	68 06 05 80 00       	push   $0x800506
  8008ff:	e8 39 fc ff ff       	call   80053d <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800904:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800907:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80090a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80090d:	83 c4 10             	add    $0x10,%esp
  800910:	eb 0c                	jmp    80091e <vsnprintf+0x53>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800912:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800917:	eb 05                	jmp    80091e <vsnprintf+0x53>
  800919:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  80091e:	c9                   	leave  
  80091f:	c3                   	ret    

00800920 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800920:	55                   	push   %ebp
  800921:	89 e5                	mov    %esp,%ebp
  800923:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800926:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800929:	50                   	push   %eax
  80092a:	ff 75 10             	pushl  0x10(%ebp)
  80092d:	ff 75 0c             	pushl  0xc(%ebp)
  800930:	ff 75 08             	pushl  0x8(%ebp)
  800933:	e8 93 ff ff ff       	call   8008cb <vsnprintf>
	va_end(ap);

	return rc;
}
  800938:	c9                   	leave  
  800939:	c3                   	ret    
	...

0080093c <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80093c:	55                   	push   %ebp
  80093d:	89 e5                	mov    %esp,%ebp
  80093f:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800942:	80 3a 00             	cmpb   $0x0,(%edx)
  800945:	74 0e                	je     800955 <strlen+0x19>
  800947:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  80094c:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  80094d:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800951:	75 f9                	jne    80094c <strlen+0x10>
  800953:	eb 05                	jmp    80095a <strlen+0x1e>
  800955:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  80095a:	c9                   	leave  
  80095b:	c3                   	ret    

0080095c <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80095c:	55                   	push   %ebp
  80095d:	89 e5                	mov    %esp,%ebp
  80095f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800962:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800965:	85 d2                	test   %edx,%edx
  800967:	74 17                	je     800980 <strnlen+0x24>
  800969:	80 39 00             	cmpb   $0x0,(%ecx)
  80096c:	74 19                	je     800987 <strnlen+0x2b>
  80096e:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  800973:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800974:	39 d0                	cmp    %edx,%eax
  800976:	74 14                	je     80098c <strnlen+0x30>
  800978:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  80097c:	75 f5                	jne    800973 <strnlen+0x17>
  80097e:	eb 0c                	jmp    80098c <strnlen+0x30>
  800980:	b8 00 00 00 00       	mov    $0x0,%eax
  800985:	eb 05                	jmp    80098c <strnlen+0x30>
  800987:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  80098c:	c9                   	leave  
  80098d:	c3                   	ret    

0080098e <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80098e:	55                   	push   %ebp
  80098f:	89 e5                	mov    %esp,%ebp
  800991:	53                   	push   %ebx
  800992:	8b 45 08             	mov    0x8(%ebp),%eax
  800995:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800998:	ba 00 00 00 00       	mov    $0x0,%edx
  80099d:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  8009a0:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  8009a3:	42                   	inc    %edx
  8009a4:	84 c9                	test   %cl,%cl
  8009a6:	75 f5                	jne    80099d <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  8009a8:	5b                   	pop    %ebx
  8009a9:	c9                   	leave  
  8009aa:	c3                   	ret    

008009ab <strcat>:

char *
strcat(char *dst, const char *src)
{
  8009ab:	55                   	push   %ebp
  8009ac:	89 e5                	mov    %esp,%ebp
  8009ae:	53                   	push   %ebx
  8009af:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8009b2:	53                   	push   %ebx
  8009b3:	e8 84 ff ff ff       	call   80093c <strlen>
  8009b8:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8009bb:	ff 75 0c             	pushl  0xc(%ebp)
  8009be:	8d 04 03             	lea    (%ebx,%eax,1),%eax
  8009c1:	50                   	push   %eax
  8009c2:	e8 c7 ff ff ff       	call   80098e <strcpy>
	return dst;
}
  8009c7:	89 d8                	mov    %ebx,%eax
  8009c9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8009cc:	c9                   	leave  
  8009cd:	c3                   	ret    

008009ce <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8009ce:	55                   	push   %ebp
  8009cf:	89 e5                	mov    %esp,%ebp
  8009d1:	56                   	push   %esi
  8009d2:	53                   	push   %ebx
  8009d3:	8b 45 08             	mov    0x8(%ebp),%eax
  8009d6:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009d9:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8009dc:	85 f6                	test   %esi,%esi
  8009de:	74 15                	je     8009f5 <strncpy+0x27>
  8009e0:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
  8009e5:	8a 1a                	mov    (%edx),%bl
  8009e7:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8009ea:	80 3a 01             	cmpb   $0x1,(%edx)
  8009ed:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8009f0:	41                   	inc    %ecx
  8009f1:	39 ce                	cmp    %ecx,%esi
  8009f3:	77 f0                	ja     8009e5 <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8009f5:	5b                   	pop    %ebx
  8009f6:	5e                   	pop    %esi
  8009f7:	c9                   	leave  
  8009f8:	c3                   	ret    

008009f9 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8009f9:	55                   	push   %ebp
  8009fa:	89 e5                	mov    %esp,%ebp
  8009fc:	57                   	push   %edi
  8009fd:	56                   	push   %esi
  8009fe:	53                   	push   %ebx
  8009ff:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a02:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800a05:	8b 75 10             	mov    0x10(%ebp),%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800a08:	85 f6                	test   %esi,%esi
  800a0a:	74 32                	je     800a3e <strlcpy+0x45>
		while (--size > 0 && *src != '\0')
  800a0c:	83 fe 01             	cmp    $0x1,%esi
  800a0f:	74 22                	je     800a33 <strlcpy+0x3a>
  800a11:	8a 0b                	mov    (%ebx),%cl
  800a13:	84 c9                	test   %cl,%cl
  800a15:	74 20                	je     800a37 <strlcpy+0x3e>
  800a17:	89 f8                	mov    %edi,%eax
  800a19:	ba 00 00 00 00       	mov    $0x0,%edx
	}
	return ret;
}

size_t
strlcpy(char *dst, const char *src, size_t size)
  800a1e:	83 ee 02             	sub    $0x2,%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800a21:	88 08                	mov    %cl,(%eax)
  800a23:	40                   	inc    %eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800a24:	39 f2                	cmp    %esi,%edx
  800a26:	74 11                	je     800a39 <strlcpy+0x40>
  800a28:	8a 4c 13 01          	mov    0x1(%ebx,%edx,1),%cl
  800a2c:	42                   	inc    %edx
  800a2d:	84 c9                	test   %cl,%cl
  800a2f:	75 f0                	jne    800a21 <strlcpy+0x28>
  800a31:	eb 06                	jmp    800a39 <strlcpy+0x40>
  800a33:	89 f8                	mov    %edi,%eax
  800a35:	eb 02                	jmp    800a39 <strlcpy+0x40>
  800a37:	89 f8                	mov    %edi,%eax
			*dst++ = *src++;
		*dst = '\0';
  800a39:	c6 00 00             	movb   $0x0,(%eax)
  800a3c:	eb 02                	jmp    800a40 <strlcpy+0x47>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800a3e:	89 f8                	mov    %edi,%eax
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
		*dst = '\0';
	}
	return dst - dst_in;
  800a40:	29 f8                	sub    %edi,%eax
}
  800a42:	5b                   	pop    %ebx
  800a43:	5e                   	pop    %esi
  800a44:	5f                   	pop    %edi
  800a45:	c9                   	leave  
  800a46:	c3                   	ret    

00800a47 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800a47:	55                   	push   %ebp
  800a48:	89 e5                	mov    %esp,%ebp
  800a4a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a4d:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800a50:	8a 01                	mov    (%ecx),%al
  800a52:	84 c0                	test   %al,%al
  800a54:	74 10                	je     800a66 <strcmp+0x1f>
  800a56:	3a 02                	cmp    (%edx),%al
  800a58:	75 0c                	jne    800a66 <strcmp+0x1f>
		p++, q++;
  800a5a:	41                   	inc    %ecx
  800a5b:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800a5c:	8a 01                	mov    (%ecx),%al
  800a5e:	84 c0                	test   %al,%al
  800a60:	74 04                	je     800a66 <strcmp+0x1f>
  800a62:	3a 02                	cmp    (%edx),%al
  800a64:	74 f4                	je     800a5a <strcmp+0x13>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800a66:	0f b6 c0             	movzbl %al,%eax
  800a69:	0f b6 12             	movzbl (%edx),%edx
  800a6c:	29 d0                	sub    %edx,%eax
}
  800a6e:	c9                   	leave  
  800a6f:	c3                   	ret    

00800a70 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800a70:	55                   	push   %ebp
  800a71:	89 e5                	mov    %esp,%ebp
  800a73:	53                   	push   %ebx
  800a74:	8b 55 08             	mov    0x8(%ebp),%edx
  800a77:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a7a:	8b 45 10             	mov    0x10(%ebp),%eax
	while (n > 0 && *p && *p == *q)
  800a7d:	85 c0                	test   %eax,%eax
  800a7f:	74 1b                	je     800a9c <strncmp+0x2c>
  800a81:	8a 1a                	mov    (%edx),%bl
  800a83:	84 db                	test   %bl,%bl
  800a85:	74 24                	je     800aab <strncmp+0x3b>
  800a87:	3a 19                	cmp    (%ecx),%bl
  800a89:	75 20                	jne    800aab <strncmp+0x3b>
  800a8b:	48                   	dec    %eax
  800a8c:	74 15                	je     800aa3 <strncmp+0x33>
		n--, p++, q++;
  800a8e:	42                   	inc    %edx
  800a8f:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800a90:	8a 1a                	mov    (%edx),%bl
  800a92:	84 db                	test   %bl,%bl
  800a94:	74 15                	je     800aab <strncmp+0x3b>
  800a96:	3a 19                	cmp    (%ecx),%bl
  800a98:	74 f1                	je     800a8b <strncmp+0x1b>
  800a9a:	eb 0f                	jmp    800aab <strncmp+0x3b>
		n--, p++, q++;
	if (n == 0)
		return 0;
  800a9c:	b8 00 00 00 00       	mov    $0x0,%eax
  800aa1:	eb 05                	jmp    800aa8 <strncmp+0x38>
  800aa3:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800aa8:	5b                   	pop    %ebx
  800aa9:	c9                   	leave  
  800aaa:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800aab:	0f b6 02             	movzbl (%edx),%eax
  800aae:	0f b6 11             	movzbl (%ecx),%edx
  800ab1:	29 d0                	sub    %edx,%eax
  800ab3:	eb f3                	jmp    800aa8 <strncmp+0x38>

00800ab5 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800ab5:	55                   	push   %ebp
  800ab6:	89 e5                	mov    %esp,%ebp
  800ab8:	8b 45 08             	mov    0x8(%ebp),%eax
  800abb:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800abe:	8a 10                	mov    (%eax),%dl
  800ac0:	84 d2                	test   %dl,%dl
  800ac2:	74 18                	je     800adc <strchr+0x27>
		if (*s == c)
  800ac4:	38 ca                	cmp    %cl,%dl
  800ac6:	75 06                	jne    800ace <strchr+0x19>
  800ac8:	eb 17                	jmp    800ae1 <strchr+0x2c>
  800aca:	38 ca                	cmp    %cl,%dl
  800acc:	74 13                	je     800ae1 <strchr+0x2c>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800ace:	40                   	inc    %eax
  800acf:	8a 10                	mov    (%eax),%dl
  800ad1:	84 d2                	test   %dl,%dl
  800ad3:	75 f5                	jne    800aca <strchr+0x15>
		if (*s == c)
			return (char *) s;
	return 0;
  800ad5:	b8 00 00 00 00       	mov    $0x0,%eax
  800ada:	eb 05                	jmp    800ae1 <strchr+0x2c>
  800adc:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800ae1:	c9                   	leave  
  800ae2:	c3                   	ret    

00800ae3 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800ae3:	55                   	push   %ebp
  800ae4:	89 e5                	mov    %esp,%ebp
  800ae6:	8b 45 08             	mov    0x8(%ebp),%eax
  800ae9:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800aec:	8a 10                	mov    (%eax),%dl
  800aee:	84 d2                	test   %dl,%dl
  800af0:	74 11                	je     800b03 <strfind+0x20>
		if (*s == c)
  800af2:	38 ca                	cmp    %cl,%dl
  800af4:	75 06                	jne    800afc <strfind+0x19>
  800af6:	eb 0b                	jmp    800b03 <strfind+0x20>
  800af8:	38 ca                	cmp    %cl,%dl
  800afa:	74 07                	je     800b03 <strfind+0x20>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800afc:	40                   	inc    %eax
  800afd:	8a 10                	mov    (%eax),%dl
  800aff:	84 d2                	test   %dl,%dl
  800b01:	75 f5                	jne    800af8 <strfind+0x15>
		if (*s == c)
			break;
	return (char *) s;
}
  800b03:	c9                   	leave  
  800b04:	c3                   	ret    

00800b05 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800b05:	55                   	push   %ebp
  800b06:	89 e5                	mov    %esp,%ebp
  800b08:	57                   	push   %edi
  800b09:	56                   	push   %esi
  800b0a:	53                   	push   %ebx
  800b0b:	8b 7d 08             	mov    0x8(%ebp),%edi
  800b0e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b11:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800b14:	85 c9                	test   %ecx,%ecx
  800b16:	74 30                	je     800b48 <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800b18:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800b1e:	75 25                	jne    800b45 <memset+0x40>
  800b20:	f6 c1 03             	test   $0x3,%cl
  800b23:	75 20                	jne    800b45 <memset+0x40>
		c &= 0xFF;
  800b25:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800b28:	89 d3                	mov    %edx,%ebx
  800b2a:	c1 e3 08             	shl    $0x8,%ebx
  800b2d:	89 d6                	mov    %edx,%esi
  800b2f:	c1 e6 18             	shl    $0x18,%esi
  800b32:	89 d0                	mov    %edx,%eax
  800b34:	c1 e0 10             	shl    $0x10,%eax
  800b37:	09 f0                	or     %esi,%eax
  800b39:	09 d0                	or     %edx,%eax
  800b3b:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800b3d:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800b40:	fc                   	cld    
  800b41:	f3 ab                	rep stos %eax,%es:(%edi)
  800b43:	eb 03                	jmp    800b48 <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800b45:	fc                   	cld    
  800b46:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800b48:	89 f8                	mov    %edi,%eax
  800b4a:	5b                   	pop    %ebx
  800b4b:	5e                   	pop    %esi
  800b4c:	5f                   	pop    %edi
  800b4d:	c9                   	leave  
  800b4e:	c3                   	ret    

00800b4f <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800b4f:	55                   	push   %ebp
  800b50:	89 e5                	mov    %esp,%ebp
  800b52:	57                   	push   %edi
  800b53:	56                   	push   %esi
  800b54:	8b 45 08             	mov    0x8(%ebp),%eax
  800b57:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b5a:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800b5d:	39 c6                	cmp    %eax,%esi
  800b5f:	73 34                	jae    800b95 <memmove+0x46>
  800b61:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800b64:	39 d0                	cmp    %edx,%eax
  800b66:	73 2d                	jae    800b95 <memmove+0x46>
		s += n;
		d += n;
  800b68:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b6b:	f6 c2 03             	test   $0x3,%dl
  800b6e:	75 1b                	jne    800b8b <memmove+0x3c>
  800b70:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800b76:	75 13                	jne    800b8b <memmove+0x3c>
  800b78:	f6 c1 03             	test   $0x3,%cl
  800b7b:	75 0e                	jne    800b8b <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800b7d:	83 ef 04             	sub    $0x4,%edi
  800b80:	8d 72 fc             	lea    -0x4(%edx),%esi
  800b83:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800b86:	fd                   	std    
  800b87:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b89:	eb 07                	jmp    800b92 <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800b8b:	4f                   	dec    %edi
  800b8c:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800b8f:	fd                   	std    
  800b90:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800b92:	fc                   	cld    
  800b93:	eb 20                	jmp    800bb5 <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b95:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800b9b:	75 13                	jne    800bb0 <memmove+0x61>
  800b9d:	a8 03                	test   $0x3,%al
  800b9f:	75 0f                	jne    800bb0 <memmove+0x61>
  800ba1:	f6 c1 03             	test   $0x3,%cl
  800ba4:	75 0a                	jne    800bb0 <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800ba6:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800ba9:	89 c7                	mov    %eax,%edi
  800bab:	fc                   	cld    
  800bac:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800bae:	eb 05                	jmp    800bb5 <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800bb0:	89 c7                	mov    %eax,%edi
  800bb2:	fc                   	cld    
  800bb3:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800bb5:	5e                   	pop    %esi
  800bb6:	5f                   	pop    %edi
  800bb7:	c9                   	leave  
  800bb8:	c3                   	ret    

00800bb9 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800bb9:	55                   	push   %ebp
  800bba:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800bbc:	ff 75 10             	pushl  0x10(%ebp)
  800bbf:	ff 75 0c             	pushl  0xc(%ebp)
  800bc2:	ff 75 08             	pushl  0x8(%ebp)
  800bc5:	e8 85 ff ff ff       	call   800b4f <memmove>
}
  800bca:	c9                   	leave  
  800bcb:	c3                   	ret    

00800bcc <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800bcc:	55                   	push   %ebp
  800bcd:	89 e5                	mov    %esp,%ebp
  800bcf:	57                   	push   %edi
  800bd0:	56                   	push   %esi
  800bd1:	53                   	push   %ebx
  800bd2:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800bd5:	8b 75 0c             	mov    0xc(%ebp),%esi
  800bd8:	8b 7d 10             	mov    0x10(%ebp),%edi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800bdb:	85 ff                	test   %edi,%edi
  800bdd:	74 32                	je     800c11 <memcmp+0x45>
		if (*s1 != *s2)
  800bdf:	8a 03                	mov    (%ebx),%al
  800be1:	8a 0e                	mov    (%esi),%cl
  800be3:	38 c8                	cmp    %cl,%al
  800be5:	74 19                	je     800c00 <memcmp+0x34>
  800be7:	eb 0d                	jmp    800bf6 <memcmp+0x2a>
  800be9:	8a 44 13 01          	mov    0x1(%ebx,%edx,1),%al
  800bed:	8a 4c 16 01          	mov    0x1(%esi,%edx,1),%cl
  800bf1:	42                   	inc    %edx
  800bf2:	38 c8                	cmp    %cl,%al
  800bf4:	74 10                	je     800c06 <memcmp+0x3a>
			return (int) *s1 - (int) *s2;
  800bf6:	0f b6 c0             	movzbl %al,%eax
  800bf9:	0f b6 c9             	movzbl %cl,%ecx
  800bfc:	29 c8                	sub    %ecx,%eax
  800bfe:	eb 16                	jmp    800c16 <memcmp+0x4a>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800c00:	4f                   	dec    %edi
  800c01:	ba 00 00 00 00       	mov    $0x0,%edx
  800c06:	39 fa                	cmp    %edi,%edx
  800c08:	75 df                	jne    800be9 <memcmp+0x1d>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800c0a:	b8 00 00 00 00       	mov    $0x0,%eax
  800c0f:	eb 05                	jmp    800c16 <memcmp+0x4a>
  800c11:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800c16:	5b                   	pop    %ebx
  800c17:	5e                   	pop    %esi
  800c18:	5f                   	pop    %edi
  800c19:	c9                   	leave  
  800c1a:	c3                   	ret    

00800c1b <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800c1b:	55                   	push   %ebp
  800c1c:	89 e5                	mov    %esp,%ebp
  800c1e:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800c21:	89 c2                	mov    %eax,%edx
  800c23:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800c26:	39 d0                	cmp    %edx,%eax
  800c28:	73 12                	jae    800c3c <memfind+0x21>
		if (*(const unsigned char *) s == (unsigned char) c)
  800c2a:	8a 4d 0c             	mov    0xc(%ebp),%cl
  800c2d:	38 08                	cmp    %cl,(%eax)
  800c2f:	75 06                	jne    800c37 <memfind+0x1c>
  800c31:	eb 09                	jmp    800c3c <memfind+0x21>
  800c33:	38 08                	cmp    %cl,(%eax)
  800c35:	74 05                	je     800c3c <memfind+0x21>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800c37:	40                   	inc    %eax
  800c38:	39 c2                	cmp    %eax,%edx
  800c3a:	77 f7                	ja     800c33 <memfind+0x18>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800c3c:	c9                   	leave  
  800c3d:	c3                   	ret    

00800c3e <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800c3e:	55                   	push   %ebp
  800c3f:	89 e5                	mov    %esp,%ebp
  800c41:	57                   	push   %edi
  800c42:	56                   	push   %esi
  800c43:	53                   	push   %ebx
  800c44:	8b 55 08             	mov    0x8(%ebp),%edx
  800c47:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800c4a:	eb 01                	jmp    800c4d <strtol+0xf>
		s++;
  800c4c:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800c4d:	8a 02                	mov    (%edx),%al
  800c4f:	3c 20                	cmp    $0x20,%al
  800c51:	74 f9                	je     800c4c <strtol+0xe>
  800c53:	3c 09                	cmp    $0x9,%al
  800c55:	74 f5                	je     800c4c <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800c57:	3c 2b                	cmp    $0x2b,%al
  800c59:	75 08                	jne    800c63 <strtol+0x25>
		s++;
  800c5b:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800c5c:	bf 00 00 00 00       	mov    $0x0,%edi
  800c61:	eb 13                	jmp    800c76 <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800c63:	3c 2d                	cmp    $0x2d,%al
  800c65:	75 0a                	jne    800c71 <strtol+0x33>
		s++, neg = 1;
  800c67:	8d 52 01             	lea    0x1(%edx),%edx
  800c6a:	bf 01 00 00 00       	mov    $0x1,%edi
  800c6f:	eb 05                	jmp    800c76 <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800c71:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800c76:	85 db                	test   %ebx,%ebx
  800c78:	74 05                	je     800c7f <strtol+0x41>
  800c7a:	83 fb 10             	cmp    $0x10,%ebx
  800c7d:	75 28                	jne    800ca7 <strtol+0x69>
  800c7f:	8a 02                	mov    (%edx),%al
  800c81:	3c 30                	cmp    $0x30,%al
  800c83:	75 10                	jne    800c95 <strtol+0x57>
  800c85:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800c89:	75 0a                	jne    800c95 <strtol+0x57>
		s += 2, base = 16;
  800c8b:	83 c2 02             	add    $0x2,%edx
  800c8e:	bb 10 00 00 00       	mov    $0x10,%ebx
  800c93:	eb 12                	jmp    800ca7 <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  800c95:	85 db                	test   %ebx,%ebx
  800c97:	75 0e                	jne    800ca7 <strtol+0x69>
  800c99:	3c 30                	cmp    $0x30,%al
  800c9b:	75 05                	jne    800ca2 <strtol+0x64>
		s++, base = 8;
  800c9d:	42                   	inc    %edx
  800c9e:	b3 08                	mov    $0x8,%bl
  800ca0:	eb 05                	jmp    800ca7 <strtol+0x69>
	else if (base == 0)
		base = 10;
  800ca2:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800ca7:	b8 00 00 00 00       	mov    $0x0,%eax
  800cac:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800cae:	8a 0a                	mov    (%edx),%cl
  800cb0:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800cb3:	80 fb 09             	cmp    $0x9,%bl
  800cb6:	77 08                	ja     800cc0 <strtol+0x82>
			dig = *s - '0';
  800cb8:	0f be c9             	movsbl %cl,%ecx
  800cbb:	83 e9 30             	sub    $0x30,%ecx
  800cbe:	eb 1e                	jmp    800cde <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  800cc0:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800cc3:	80 fb 19             	cmp    $0x19,%bl
  800cc6:	77 08                	ja     800cd0 <strtol+0x92>
			dig = *s - 'a' + 10;
  800cc8:	0f be c9             	movsbl %cl,%ecx
  800ccb:	83 e9 57             	sub    $0x57,%ecx
  800cce:	eb 0e                	jmp    800cde <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  800cd0:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800cd3:	80 fb 19             	cmp    $0x19,%bl
  800cd6:	77 13                	ja     800ceb <strtol+0xad>
			dig = *s - 'A' + 10;
  800cd8:	0f be c9             	movsbl %cl,%ecx
  800cdb:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800cde:	39 f1                	cmp    %esi,%ecx
  800ce0:	7d 0d                	jge    800cef <strtol+0xb1>
			break;
		s++, val = (val * base) + dig;
  800ce2:	42                   	inc    %edx
  800ce3:	0f af c6             	imul   %esi,%eax
  800ce6:	8d 04 01             	lea    (%ecx,%eax,1),%eax
		// we don't properly detect overflow!
	}
  800ce9:	eb c3                	jmp    800cae <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800ceb:	89 c1                	mov    %eax,%ecx
  800ced:	eb 02                	jmp    800cf1 <strtol+0xb3>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800cef:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800cf1:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800cf5:	74 05                	je     800cfc <strtol+0xbe>
		*endptr = (char *) s;
  800cf7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800cfa:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800cfc:	85 ff                	test   %edi,%edi
  800cfe:	74 04                	je     800d04 <strtol+0xc6>
  800d00:	89 c8                	mov    %ecx,%eax
  800d02:	f7 d8                	neg    %eax
}
  800d04:	5b                   	pop    %ebx
  800d05:	5e                   	pop    %esi
  800d06:	5f                   	pop    %edi
  800d07:	c9                   	leave  
  800d08:	c3                   	ret    
  800d09:	00 00                	add    %al,(%eax)
	...

00800d0c <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  800d0c:	55                   	push   %ebp
  800d0d:	89 e5                	mov    %esp,%ebp
  800d0f:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  800d12:	83 3d 08 20 80 00 00 	cmpl   $0x0,0x802008
  800d19:	75 52                	jne    800d6d <set_pgfault_handler+0x61>
		// First time through!	
		// LAB 4: Your code here.

		//int sys_page_alloc(envid_t envid, void *va, int perm)
		r = sys_page_alloc(0, (void*)(UXSTACKTOP - PGSIZE), PTE_U | PTE_W | PTE_P);
  800d1b:	83 ec 04             	sub    $0x4,%esp
  800d1e:	6a 07                	push   $0x7
  800d20:	68 00 f0 bf ee       	push   $0xeebff000
  800d25:	6a 00                	push   $0x0
  800d27:	e8 8c f4 ff ff       	call   8001b8 <sys_page_alloc>
		if (r < 0) {
  800d2c:	83 c4 10             	add    $0x10,%esp
  800d2f:	85 c0                	test   %eax,%eax
  800d31:	79 12                	jns    800d45 <set_pgfault_handler+0x39>
			panic("sys_page_alloc error : %e\n", r);
  800d33:	50                   	push   %eax
  800d34:	68 64 12 80 00       	push   $0x801264
  800d39:	6a 24                	push   $0x24
  800d3b:	68 7f 12 80 00       	push   $0x80127f
  800d40:	e8 bb f5 ff ff       	call   800300 <_panic>
		}

		// how to know envid, put 0, envid2env will help us to get curenv in syscall
		r = sys_env_set_pgfault_upcall(0, _pgfault_upcall);		
  800d45:	83 ec 08             	sub    $0x8,%esp
  800d48:	68 d8 02 80 00       	push   $0x8002d8
  800d4d:	6a 00                	push   $0x0
  800d4f:	e8 f4 f4 ff ff       	call   800248 <sys_env_set_pgfault_upcall>
		if (r < 0) {
  800d54:	83 c4 10             	add    $0x10,%esp
  800d57:	85 c0                	test   %eax,%eax
  800d59:	79 12                	jns    800d6d <set_pgfault_handler+0x61>
			panic("sys_env_set_pgfault_upcall error : %e\n", r);
  800d5b:	50                   	push   %eax
  800d5c:	68 90 12 80 00       	push   $0x801290
  800d61:	6a 2a                	push   $0x2a
  800d63:	68 7f 12 80 00       	push   $0x80127f
  800d68:	e8 93 f5 ff ff       	call   800300 <_panic>
		}
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  800d6d:	8b 45 08             	mov    0x8(%ebp),%eax
  800d70:	a3 08 20 80 00       	mov    %eax,0x802008
}
  800d75:	c9                   	leave  
  800d76:	c3                   	ret    
	...

00800d78 <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  800d78:	55                   	push   %ebp
  800d79:	89 e5                	mov    %esp,%ebp
  800d7b:	57                   	push   %edi
  800d7c:	56                   	push   %esi
  800d7d:	83 ec 10             	sub    $0x10,%esp
  800d80:	8b 7d 08             	mov    0x8(%ebp),%edi
  800d83:	8b 4d 10             	mov    0x10(%ebp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  800d86:	89 7d f0             	mov    %edi,-0x10(%ebp)
  800d89:	8b 75 0c             	mov    0xc(%ebp),%esi
  const DWunion dd = {.ll = d};
  800d8c:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  800d8f:	8b 45 14             	mov    0x14(%ebp),%eax
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  800d92:	85 c0                	test   %eax,%eax
  800d94:	75 2e                	jne    800dc4 <__udivdi3+0x4c>
    {
      if (d0 > n1)
  800d96:	39 f1                	cmp    %esi,%ecx
  800d98:	77 5a                	ja     800df4 <__udivdi3+0x7c>
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  800d9a:	85 c9                	test   %ecx,%ecx
  800d9c:	75 0b                	jne    800da9 <__udivdi3+0x31>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  800d9e:	b8 01 00 00 00       	mov    $0x1,%eax
  800da3:	31 d2                	xor    %edx,%edx
  800da5:	f7 f1                	div    %ecx
  800da7:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  800da9:	31 d2                	xor    %edx,%edx
  800dab:	89 f0                	mov    %esi,%eax
  800dad:	f7 f1                	div    %ecx
  800daf:	89 c6                	mov    %eax,%esi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800db1:	89 f8                	mov    %edi,%eax
  800db3:	f7 f1                	div    %ecx
  800db5:	89 c7                	mov    %eax,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800db7:	89 f8                	mov    %edi,%eax
  800db9:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800dbb:	83 c4 10             	add    $0x10,%esp
  800dbe:	5e                   	pop    %esi
  800dbf:	5f                   	pop    %edi
  800dc0:	c9                   	leave  
  800dc1:	c3                   	ret    
  800dc2:	66 90                	xchg   %ax,%ax
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  800dc4:	39 f0                	cmp    %esi,%eax
  800dc6:	77 1c                	ja     800de4 <__udivdi3+0x6c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  800dc8:	0f bd f8             	bsr    %eax,%edi
	  if (bm == 0)
  800dcb:	83 f7 1f             	xor    $0x1f,%edi
  800dce:	75 3c                	jne    800e0c <__udivdi3+0x94>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  800dd0:	39 f0                	cmp    %esi,%eax
  800dd2:	0f 82 90 00 00 00    	jb     800e68 <__udivdi3+0xf0>
  800dd8:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800ddb:	39 55 f4             	cmp    %edx,-0xc(%ebp)
  800dde:	0f 86 84 00 00 00    	jbe    800e68 <__udivdi3+0xf0>
  800de4:	31 f6                	xor    %esi,%esi
  800de6:	31 ff                	xor    %edi,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800de8:	89 f8                	mov    %edi,%eax
  800dea:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800dec:	83 c4 10             	add    $0x10,%esp
  800def:	5e                   	pop    %esi
  800df0:	5f                   	pop    %edi
  800df1:	c9                   	leave  
  800df2:	c3                   	ret    
  800df3:	90                   	nop
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800df4:	89 f2                	mov    %esi,%edx
  800df6:	89 f8                	mov    %edi,%eax
  800df8:	f7 f1                	div    %ecx
  800dfa:	89 c7                	mov    %eax,%edi
  800dfc:	31 f6                	xor    %esi,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800dfe:	89 f8                	mov    %edi,%eax
  800e00:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800e02:	83 c4 10             	add    $0x10,%esp
  800e05:	5e                   	pop    %esi
  800e06:	5f                   	pop    %edi
  800e07:	c9                   	leave  
  800e08:	c3                   	ret    
  800e09:	8d 76 00             	lea    0x0(%esi),%esi
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  800e0c:	89 f9                	mov    %edi,%ecx
  800e0e:	d3 e0                	shl    %cl,%eax
  800e10:	89 45 e8             	mov    %eax,-0x18(%ebp)
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  800e13:	b8 20 00 00 00       	mov    $0x20,%eax
  800e18:	29 f8                	sub    %edi,%eax

	      d1 = (d1 << bm) | (d0 >> b);
  800e1a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800e1d:	88 c1                	mov    %al,%cl
  800e1f:	d3 ea                	shr    %cl,%edx
  800e21:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  800e24:	09 ca                	or     %ecx,%edx
  800e26:	89 55 ec             	mov    %edx,-0x14(%ebp)
	      d0 = d0 << bm;
  800e29:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800e2c:	89 f9                	mov    %edi,%ecx
  800e2e:	d3 e2                	shl    %cl,%edx
  800e30:	89 55 f4             	mov    %edx,-0xc(%ebp)
	      n2 = n1 >> b;
  800e33:	89 f2                	mov    %esi,%edx
  800e35:	88 c1                	mov    %al,%cl
  800e37:	d3 ea                	shr    %cl,%edx
  800e39:	89 55 e8             	mov    %edx,-0x18(%ebp)
	      n1 = (n1 << bm) | (n0 >> b);
  800e3c:	89 f2                	mov    %esi,%edx
  800e3e:	89 f9                	mov    %edi,%ecx
  800e40:	d3 e2                	shl    %cl,%edx
  800e42:	8b 75 f0             	mov    -0x10(%ebp),%esi
  800e45:	88 c1                	mov    %al,%cl
  800e47:	d3 ee                	shr    %cl,%esi
  800e49:	09 d6                	or     %edx,%esi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  800e4b:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  800e4e:	89 f0                	mov    %esi,%eax
  800e50:	89 ca                	mov    %ecx,%edx
  800e52:	f7 75 ec             	divl   -0x14(%ebp)
  800e55:	89 d1                	mov    %edx,%ecx
  800e57:	89 c6                	mov    %eax,%esi
	      umul_ppmm (m1, m0, q0, d0);
  800e59:	f7 65 f4             	mull   -0xc(%ebp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800e5c:	39 d1                	cmp    %edx,%ecx
  800e5e:	72 28                	jb     800e88 <__udivdi3+0x110>
  800e60:	74 1a                	je     800e7c <__udivdi3+0x104>
  800e62:	89 f7                	mov    %esi,%edi
  800e64:	31 f6                	xor    %esi,%esi
  800e66:	eb 80                	jmp    800de8 <__udivdi3+0x70>
	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  800e68:	31 f6                	xor    %esi,%esi
  800e6a:	bf 01 00 00 00       	mov    $0x1,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800e6f:	89 f8                	mov    %edi,%eax
  800e71:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800e73:	83 c4 10             	add    $0x10,%esp
  800e76:	5e                   	pop    %esi
  800e77:	5f                   	pop    %edi
  800e78:	c9                   	leave  
  800e79:	c3                   	ret    
  800e7a:	66 90                	xchg   %ax,%ax

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  800e7c:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800e7f:	89 f9                	mov    %edi,%ecx
  800e81:	d3 e2                	shl    %cl,%edx

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800e83:	39 c2                	cmp    %eax,%edx
  800e85:	73 db                	jae    800e62 <__udivdi3+0xea>
  800e87:	90                   	nop
		{
		  q0--;
  800e88:	8d 7e ff             	lea    -0x1(%esi),%edi
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  800e8b:	31 f6                	xor    %esi,%esi
  800e8d:	e9 56 ff ff ff       	jmp    800de8 <__udivdi3+0x70>
	...

00800e94 <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  800e94:	55                   	push   %ebp
  800e95:	89 e5                	mov    %esp,%ebp
  800e97:	57                   	push   %edi
  800e98:	56                   	push   %esi
  800e99:	83 ec 20             	sub    $0x20,%esp
  800e9c:	8b 45 08             	mov    0x8(%ebp),%eax
  800e9f:	8b 4d 10             	mov    0x10(%ebp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  800ea2:	89 45 e8             	mov    %eax,-0x18(%ebp)
  800ea5:	8b 75 0c             	mov    0xc(%ebp),%esi
  const DWunion dd = {.ll = d};
  800ea8:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  800eab:	8b 7d 14             	mov    0x14(%ebp),%edi
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  800eae:	89 45 f0             	mov    %eax,-0x10(%ebp)
  n1 = nn.s.high;
  800eb1:	89 f2                	mov    %esi,%edx

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  800eb3:	85 ff                	test   %edi,%edi
  800eb5:	75 15                	jne    800ecc <__umoddi3+0x38>
    {
      if (d0 > n1)
  800eb7:	39 f1                	cmp    %esi,%ecx
  800eb9:	0f 86 99 00 00 00    	jbe    800f58 <__umoddi3+0xc4>
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800ebf:	f7 f1                	div    %ecx

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
  800ec1:	89 d0                	mov    %edx,%eax
  800ec3:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  800ec5:	83 c4 20             	add    $0x20,%esp
  800ec8:	5e                   	pop    %esi
  800ec9:	5f                   	pop    %edi
  800eca:	c9                   	leave  
  800ecb:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  800ecc:	39 f7                	cmp    %esi,%edi
  800ece:	0f 87 a4 00 00 00    	ja     800f78 <__umoddi3+0xe4>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  800ed4:	0f bd c7             	bsr    %edi,%eax
	  if (bm == 0)
  800ed7:	83 f0 1f             	xor    $0x1f,%eax
  800eda:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800edd:	0f 84 a1 00 00 00    	je     800f84 <__umoddi3+0xf0>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  800ee3:	89 f8                	mov    %edi,%eax
  800ee5:	8a 4d ec             	mov    -0x14(%ebp),%cl
  800ee8:	d3 e0                	shl    %cl,%eax
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  800eea:	bf 20 00 00 00       	mov    $0x20,%edi
  800eef:	2b 7d ec             	sub    -0x14(%ebp),%edi

	      d1 = (d1 << bm) | (d0 >> b);
  800ef2:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800ef5:	89 f9                	mov    %edi,%ecx
  800ef7:	d3 ea                	shr    %cl,%edx
  800ef9:	09 c2                	or     %eax,%edx
  800efb:	89 55 f0             	mov    %edx,-0x10(%ebp)
	      d0 = d0 << bm;
  800efe:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800f01:	8a 4d ec             	mov    -0x14(%ebp),%cl
  800f04:	d3 e0                	shl    %cl,%eax
  800f06:	89 45 f4             	mov    %eax,-0xc(%ebp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  800f09:	89 f2                	mov    %esi,%edx
  800f0b:	d3 e2                	shl    %cl,%edx
	      n0 = n0 << bm;
  800f0d:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800f10:	d3 e0                	shl    %cl,%eax
  800f12:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  800f15:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800f18:	89 f9                	mov    %edi,%ecx
  800f1a:	d3 e8                	shr    %cl,%eax
  800f1c:	09 d0                	or     %edx,%eax

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  800f1e:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  800f20:	89 f2                	mov    %esi,%edx
  800f22:	f7 75 f0             	divl   -0x10(%ebp)
  800f25:	89 d6                	mov    %edx,%esi
	      umul_ppmm (m1, m0, q0, d0);
  800f27:	f7 65 f4             	mull   -0xc(%ebp)
  800f2a:	89 55 e8             	mov    %edx,-0x18(%ebp)
  800f2d:	89 c1                	mov    %eax,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800f2f:	39 d6                	cmp    %edx,%esi
  800f31:	72 71                	jb     800fa4 <__umoddi3+0x110>
  800f33:	74 7f                	je     800fb4 <__umoddi3+0x120>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  800f35:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800f38:	29 c8                	sub    %ecx,%eax
  800f3a:	19 d6                	sbb    %edx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
  800f3c:	8a 4d ec             	mov    -0x14(%ebp),%cl
  800f3f:	d3 e8                	shr    %cl,%eax
  800f41:	89 f2                	mov    %esi,%edx
  800f43:	89 f9                	mov    %edi,%ecx
  800f45:	d3 e2                	shl    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
  800f47:	09 d0                	or     %edx,%eax
  800f49:	89 f2                	mov    %esi,%edx
  800f4b:	8a 4d ec             	mov    -0x14(%ebp),%cl
  800f4e:	d3 ea                	shr    %cl,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  800f50:	83 c4 20             	add    $0x20,%esp
  800f53:	5e                   	pop    %esi
  800f54:	5f                   	pop    %edi
  800f55:	c9                   	leave  
  800f56:	c3                   	ret    
  800f57:	90                   	nop
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  800f58:	85 c9                	test   %ecx,%ecx
  800f5a:	75 0b                	jne    800f67 <__umoddi3+0xd3>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  800f5c:	b8 01 00 00 00       	mov    $0x1,%eax
  800f61:	31 d2                	xor    %edx,%edx
  800f63:	f7 f1                	div    %ecx
  800f65:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  800f67:	89 f0                	mov    %esi,%eax
  800f69:	31 d2                	xor    %edx,%edx
  800f6b:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800f6d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800f70:	f7 f1                	div    %ecx
  800f72:	e9 4a ff ff ff       	jmp    800ec1 <__umoddi3+0x2d>
  800f77:	90                   	nop
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
  800f78:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  800f7a:	83 c4 20             	add    $0x20,%esp
  800f7d:	5e                   	pop    %esi
  800f7e:	5f                   	pop    %edi
  800f7f:	c9                   	leave  
  800f80:	c3                   	ret    
  800f81:	8d 76 00             	lea    0x0(%esi),%esi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  800f84:	39 f7                	cmp    %esi,%edi
  800f86:	72 05                	jb     800f8d <__umoddi3+0xf9>
  800f88:	3b 4d f0             	cmp    -0x10(%ebp),%ecx
  800f8b:	77 0c                	ja     800f99 <__umoddi3+0x105>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  800f8d:	89 f2                	mov    %esi,%edx
  800f8f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800f92:	29 c8                	sub    %ecx,%eax
  800f94:	19 fa                	sbb    %edi,%edx
  800f96:	89 45 f0             	mov    %eax,-0x10(%ebp)

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
  800f99:	8b 45 f0             	mov    -0x10(%ebp),%eax
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  800f9c:	83 c4 20             	add    $0x20,%esp
  800f9f:	5e                   	pop    %esi
  800fa0:	5f                   	pop    %edi
  800fa1:	c9                   	leave  
  800fa2:	c3                   	ret    
  800fa3:	90                   	nop
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  800fa4:	8b 55 e8             	mov    -0x18(%ebp),%edx
  800fa7:	89 c1                	mov    %eax,%ecx
  800fa9:	2b 4d f4             	sub    -0xc(%ebp),%ecx
  800fac:	1b 55 f0             	sbb    -0x10(%ebp),%edx
  800faf:	eb 84                	jmp    800f35 <__umoddi3+0xa1>
  800fb1:	8d 76 00             	lea    0x0(%esi),%esi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800fb4:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  800fb7:	72 eb                	jb     800fa4 <__umoddi3+0x110>
  800fb9:	89 f2                	mov    %esi,%edx
  800fbb:	e9 75 ff ff ff       	jmp    800f35 <__umoddi3+0xa1>
