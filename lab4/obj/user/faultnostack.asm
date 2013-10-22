
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
  80003a:	68 bc 02 80 00       	push   $0x8002bc
  80003f:	6a 00                	push   $0x0
  800041:	e8 0a 02 00 00       	call   800250 <sys_env_set_pgfault_upcall>
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
  800063:	e8 0d 01 00 00       	call   800175 <sys_getenvid>
  800068:	25 ff 03 00 00       	and    $0x3ff,%eax
  80006d:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  800074:	c1 e0 07             	shl    $0x7,%eax
  800077:	29 d0                	sub    %edx,%eax
  800079:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80007e:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800083:	85 f6                	test   %esi,%esi
  800085:	7e 07                	jle    80008e <libmain+0x36>
		binaryname = argv[0];
  800087:	8b 03                	mov    (%ebx),%eax
  800089:	a3 00 20 80 00       	mov    %eax,0x802000
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
  8000ab:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  8000ae:	6a 00                	push   $0x0
  8000b0:	e8 9e 00 00 00       	call   800153 <sys_env_destroy>
  8000b5:	83 c4 10             	add    $0x10,%esp
}
  8000b8:	c9                   	leave  
  8000b9:	c3                   	ret    
	...

008000bc <syscall>:
	return ret;
}

static int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  8000bc:	55                   	push   %ebp
  8000bd:	89 e5                	mov    %esp,%ebp
  8000bf:	57                   	push   %edi
  8000c0:	56                   	push   %esi
  8000c1:	53                   	push   %ebx
  8000c2:	83 ec 1c             	sub    $0x1c,%esp
  8000c5:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8000c8:	89 55 e0             	mov    %edx,-0x20(%ebp)
  8000cb:	89 ca                	mov    %ecx,%edx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000cd:	8b 75 14             	mov    0x14(%ebp),%esi
  8000d0:	8b 7d 10             	mov    0x10(%ebp),%edi
  8000d3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8000d6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8000d9:	cd 30                	int    $0x30
  8000db:	89 c2                	mov    %eax,%edx
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8000dd:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8000e1:	74 1c                	je     8000ff <syscall+0x43>
  8000e3:	85 c0                	test   %eax,%eax
  8000e5:	7e 18                	jle    8000ff <syscall+0x43>
		panic("syscall %d returned %d (> 0)", num, ret);
  8000e7:	83 ec 0c             	sub    $0xc,%esp
  8000ea:	50                   	push   %eax
  8000eb:	ff 75 e4             	pushl  -0x1c(%ebp)
  8000ee:	68 ca 0f 80 00       	push   $0x800fca
  8000f3:	6a 42                	push   $0x42
  8000f5:	68 e7 0f 80 00       	push   $0x800fe7
  8000fa:	e8 e5 01 00 00       	call   8002e4 <_panic>

	return ret;
}
  8000ff:	89 d0                	mov    %edx,%eax
  800101:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800104:	5b                   	pop    %ebx
  800105:	5e                   	pop    %esi
  800106:	5f                   	pop    %edi
  800107:	c9                   	leave  
  800108:	c3                   	ret    

00800109 <sys_cputs>:

void
sys_cputs(const char *s, size_t len)
{	
  800109:	55                   	push   %ebp
  80010a:	89 e5                	mov    %esp,%ebp
  80010c:	83 ec 08             	sub    $0x8,%esp
	// my_sysenter(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
	// return;
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
  80010f:	6a 00                	push   $0x0
  800111:	6a 00                	push   $0x0
  800113:	6a 00                	push   $0x0
  800115:	ff 75 0c             	pushl  0xc(%ebp)
  800118:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80011b:	ba 00 00 00 00       	mov    $0x0,%edx
  800120:	b8 00 00 00 00       	mov    $0x0,%eax
  800125:	e8 92 ff ff ff       	call   8000bc <syscall>
  80012a:	83 c4 10             	add    $0x10,%esp
	return;
}
  80012d:	c9                   	leave  
  80012e:	c3                   	ret    

0080012f <sys_cgetc>:

int
sys_cgetc(void)
{
  80012f:	55                   	push   %ebp
  800130:	89 e5                	mov    %esp,%ebp
  800132:	83 ec 08             	sub    $0x8,%esp
	// return my_sysenter(SYS_cgetc, 0, 0, 0, 0, 0, 0);
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
  800135:	6a 00                	push   $0x0
  800137:	6a 00                	push   $0x0
  800139:	6a 00                	push   $0x0
  80013b:	6a 00                	push   $0x0
  80013d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800142:	ba 00 00 00 00       	mov    $0x0,%edx
  800147:	b8 01 00 00 00       	mov    $0x1,%eax
  80014c:	e8 6b ff ff ff       	call   8000bc <syscall>
}
  800151:	c9                   	leave  
  800152:	c3                   	ret    

00800153 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800153:	55                   	push   %ebp
  800154:	89 e5                	mov    %esp,%ebp
  800156:	83 ec 08             	sub    $0x8,%esp
	// return my_sysenter(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
  800159:	6a 00                	push   $0x0
  80015b:	6a 00                	push   $0x0
  80015d:	6a 00                	push   $0x0
  80015f:	6a 00                	push   $0x0
  800161:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800164:	ba 01 00 00 00       	mov    $0x1,%edx
  800169:	b8 03 00 00 00       	mov    $0x3,%eax
  80016e:	e8 49 ff ff ff       	call   8000bc <syscall>
}
  800173:	c9                   	leave  
  800174:	c3                   	ret    

00800175 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800175:	55                   	push   %ebp
  800176:	89 e5                	mov    %esp,%ebp
  800178:	83 ec 08             	sub    $0x8,%esp
	// return my_sysenter(SYS_getenvid, 0, 0, 0, 0, 0, 0);
	return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
  80017b:	6a 00                	push   $0x0
  80017d:	6a 00                	push   $0x0
  80017f:	6a 00                	push   $0x0
  800181:	6a 00                	push   $0x0
  800183:	b9 00 00 00 00       	mov    $0x0,%ecx
  800188:	ba 00 00 00 00       	mov    $0x0,%edx
  80018d:	b8 02 00 00 00       	mov    $0x2,%eax
  800192:	e8 25 ff ff ff       	call   8000bc <syscall>
}
  800197:	c9                   	leave  
  800198:	c3                   	ret    

00800199 <sys_yield>:

void
sys_yield(void)
{
  800199:	55                   	push   %ebp
  80019a:	89 e5                	mov    %esp,%ebp
  80019c:	83 ec 08             	sub    $0x8,%esp
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
  80019f:	6a 00                	push   $0x0
  8001a1:	6a 00                	push   $0x0
  8001a3:	6a 00                	push   $0x0
  8001a5:	6a 00                	push   $0x0
  8001a7:	b9 00 00 00 00       	mov    $0x0,%ecx
  8001ac:	ba 00 00 00 00       	mov    $0x0,%edx
  8001b1:	b8 0a 00 00 00       	mov    $0xa,%eax
  8001b6:	e8 01 ff ff ff       	call   8000bc <syscall>
  8001bb:	83 c4 10             	add    $0x10,%esp
}
  8001be:	c9                   	leave  
  8001bf:	c3                   	ret    

008001c0 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  8001c0:	55                   	push   %ebp
  8001c1:	89 e5                	mov    %esp,%ebp
  8001c3:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
  8001c6:	6a 00                	push   $0x0
  8001c8:	6a 00                	push   $0x0
  8001ca:	ff 75 10             	pushl  0x10(%ebp)
  8001cd:	ff 75 0c             	pushl  0xc(%ebp)
  8001d0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8001d3:	ba 01 00 00 00       	mov    $0x1,%edx
  8001d8:	b8 04 00 00 00       	mov    $0x4,%eax
  8001dd:	e8 da fe ff ff       	call   8000bc <syscall>
}
  8001e2:	c9                   	leave  
  8001e3:	c3                   	ret    

008001e4 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8001e4:	55                   	push   %ebp
  8001e5:	89 e5                	mov    %esp,%ebp
  8001e7:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
  8001ea:	ff 75 18             	pushl  0x18(%ebp)
  8001ed:	ff 75 14             	pushl  0x14(%ebp)
  8001f0:	ff 75 10             	pushl  0x10(%ebp)
  8001f3:	ff 75 0c             	pushl  0xc(%ebp)
  8001f6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8001f9:	ba 01 00 00 00       	mov    $0x1,%edx
  8001fe:	b8 05 00 00 00       	mov    $0x5,%eax
  800203:	e8 b4 fe ff ff       	call   8000bc <syscall>
}
  800208:	c9                   	leave  
  800209:	c3                   	ret    

0080020a <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  80020a:	55                   	push   %ebp
  80020b:	89 e5                	mov    %esp,%ebp
  80020d:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
  800210:	6a 00                	push   $0x0
  800212:	6a 00                	push   $0x0
  800214:	6a 00                	push   $0x0
  800216:	ff 75 0c             	pushl  0xc(%ebp)
  800219:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80021c:	ba 01 00 00 00       	mov    $0x1,%edx
  800221:	b8 06 00 00 00       	mov    $0x6,%eax
  800226:	e8 91 fe ff ff       	call   8000bc <syscall>
}
  80022b:	c9                   	leave  
  80022c:	c3                   	ret    

0080022d <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  80022d:	55                   	push   %ebp
  80022e:	89 e5                	mov    %esp,%ebp
  800230:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
  800233:	6a 00                	push   $0x0
  800235:	6a 00                	push   $0x0
  800237:	6a 00                	push   $0x0
  800239:	ff 75 0c             	pushl  0xc(%ebp)
  80023c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80023f:	ba 01 00 00 00       	mov    $0x1,%edx
  800244:	b8 08 00 00 00       	mov    $0x8,%eax
  800249:	e8 6e fe ff ff       	call   8000bc <syscall>
}
  80024e:	c9                   	leave  
  80024f:	c3                   	ret    

00800250 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800250:	55                   	push   %ebp
  800251:	89 e5                	mov    %esp,%ebp
  800253:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
  800256:	6a 00                	push   $0x0
  800258:	6a 00                	push   $0x0
  80025a:	6a 00                	push   $0x0
  80025c:	ff 75 0c             	pushl  0xc(%ebp)
  80025f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800262:	ba 01 00 00 00       	mov    $0x1,%edx
  800267:	b8 09 00 00 00       	mov    $0x9,%eax
  80026c:	e8 4b fe ff ff       	call   8000bc <syscall>
}
  800271:	c9                   	leave  
  800272:	c3                   	ret    

00800273 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800273:	55                   	push   %ebp
  800274:	89 e5                	mov    %esp,%ebp
  800276:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
  800279:	6a 00                	push   $0x0
  80027b:	ff 75 14             	pushl  0x14(%ebp)
  80027e:	ff 75 10             	pushl  0x10(%ebp)
  800281:	ff 75 0c             	pushl  0xc(%ebp)
  800284:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800287:	ba 00 00 00 00       	mov    $0x0,%edx
  80028c:	b8 0b 00 00 00       	mov    $0xb,%eax
  800291:	e8 26 fe ff ff       	call   8000bc <syscall>
}
  800296:	c9                   	leave  
  800297:	c3                   	ret    

00800298 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800298:	55                   	push   %ebp
  800299:	89 e5                	mov    %esp,%ebp
  80029b:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
  80029e:	6a 00                	push   $0x0
  8002a0:	6a 00                	push   $0x0
  8002a2:	6a 00                	push   $0x0
  8002a4:	6a 00                	push   $0x0
  8002a6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8002a9:	ba 01 00 00 00       	mov    $0x1,%edx
  8002ae:	b8 0c 00 00 00       	mov    $0xc,%eax
  8002b3:	e8 04 fe ff ff       	call   8000bc <syscall>
}
  8002b8:	c9                   	leave  
  8002b9:	c3                   	ret    
	...

008002bc <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  8002bc:	54                   	push   %esp
	movl _pgfault_handler, %eax
  8002bd:	a1 08 20 80 00       	mov    0x802008,%eax
	call *%eax
  8002c2:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  8002c4:	83 c4 04             	add    $0x4,%esp
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	
	// fix old esp
	movl 0x30(%esp), %eax
  8002c7:	8b 44 24 30          	mov    0x30(%esp),%eax
	subl $0x4, %eax
  8002cb:	83 e8 04             	sub    $0x4,%eax
	movl %eax, 0x30(%esp)
  8002ce:	89 44 24 30          	mov    %eax,0x30(%esp)

	// set trap-time %eip
	movl 0x28(%esp), %ebx
  8002d2:	8b 5c 24 28          	mov    0x28(%esp),%ebx
	movl %ebx, (%eax)
  8002d6:	89 18                	mov    %ebx,(%eax)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	addl $0x08, %esp 	// ignore err_code and fault_va
  8002d8:	83 c4 08             	add    $0x8,%esp
	popal 				// restore registers
  8002db:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $0x04, %esp 	// ignore eip 
  8002dc:	83 c4 04             	add    $0x4,%esp
	popfl				// modify eflags
  8002df:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp
  8002e0:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  8002e1:	c3                   	ret    
	...

008002e4 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8002e4:	55                   	push   %ebp
  8002e5:	89 e5                	mov    %esp,%ebp
  8002e7:	56                   	push   %esi
  8002e8:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  8002e9:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8002ec:	8b 1d 00 20 80 00    	mov    0x802000,%ebx
  8002f2:	e8 7e fe ff ff       	call   800175 <sys_getenvid>
  8002f7:	83 ec 0c             	sub    $0xc,%esp
  8002fa:	ff 75 0c             	pushl  0xc(%ebp)
  8002fd:	ff 75 08             	pushl  0x8(%ebp)
  800300:	53                   	push   %ebx
  800301:	50                   	push   %eax
  800302:	68 f8 0f 80 00       	push   $0x800ff8
  800307:	e8 b0 00 00 00       	call   8003bc <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80030c:	83 c4 18             	add    $0x18,%esp
  80030f:	56                   	push   %esi
  800310:	ff 75 10             	pushl  0x10(%ebp)
  800313:	e8 53 00 00 00       	call   80036b <vcprintf>
	cprintf("\n");
  800318:	c7 04 24 7d 12 80 00 	movl   $0x80127d,(%esp)
  80031f:	e8 98 00 00 00       	call   8003bc <cprintf>
  800324:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800327:	cc                   	int3   
  800328:	eb fd                	jmp    800327 <_panic+0x43>
	...

0080032c <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80032c:	55                   	push   %ebp
  80032d:	89 e5                	mov    %esp,%ebp
  80032f:	53                   	push   %ebx
  800330:	83 ec 04             	sub    $0x4,%esp
  800333:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800336:	8b 03                	mov    (%ebx),%eax
  800338:	8b 55 08             	mov    0x8(%ebp),%edx
  80033b:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  80033f:	40                   	inc    %eax
  800340:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  800342:	3d ff 00 00 00       	cmp    $0xff,%eax
  800347:	75 1a                	jne    800363 <putch+0x37>
		sys_cputs(b->buf, b->idx);
  800349:	83 ec 08             	sub    $0x8,%esp
  80034c:	68 ff 00 00 00       	push   $0xff
  800351:	8d 43 08             	lea    0x8(%ebx),%eax
  800354:	50                   	push   %eax
  800355:	e8 af fd ff ff       	call   800109 <sys_cputs>
		b->idx = 0;
  80035a:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800360:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  800363:	ff 43 04             	incl   0x4(%ebx)
}
  800366:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800369:	c9                   	leave  
  80036a:	c3                   	ret    

0080036b <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80036b:	55                   	push   %ebp
  80036c:	89 e5                	mov    %esp,%ebp
  80036e:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800374:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80037b:	00 00 00 
	b.cnt = 0;
  80037e:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800385:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800388:	ff 75 0c             	pushl  0xc(%ebp)
  80038b:	ff 75 08             	pushl  0x8(%ebp)
  80038e:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800394:	50                   	push   %eax
  800395:	68 2c 03 80 00       	push   $0x80032c
  80039a:	e8 82 01 00 00       	call   800521 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80039f:	83 c4 08             	add    $0x8,%esp
  8003a2:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8003a8:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8003ae:	50                   	push   %eax
  8003af:	e8 55 fd ff ff       	call   800109 <sys_cputs>

	return b.cnt;
}
  8003b4:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8003ba:	c9                   	leave  
  8003bb:	c3                   	ret    

008003bc <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8003bc:	55                   	push   %ebp
  8003bd:	89 e5                	mov    %esp,%ebp
  8003bf:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8003c2:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8003c5:	50                   	push   %eax
  8003c6:	ff 75 08             	pushl  0x8(%ebp)
  8003c9:	e8 9d ff ff ff       	call   80036b <vcprintf>
	va_end(ap);

	return cnt;
}
  8003ce:	c9                   	leave  
  8003cf:	c3                   	ret    

008003d0 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8003d0:	55                   	push   %ebp
  8003d1:	89 e5                	mov    %esp,%ebp
  8003d3:	57                   	push   %edi
  8003d4:	56                   	push   %esi
  8003d5:	53                   	push   %ebx
  8003d6:	83 ec 2c             	sub    $0x2c,%esp
  8003d9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8003dc:	89 d6                	mov    %edx,%esi
  8003de:	8b 45 08             	mov    0x8(%ebp),%eax
  8003e1:	8b 55 0c             	mov    0xc(%ebp),%edx
  8003e4:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8003e7:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8003ea:	8b 45 10             	mov    0x10(%ebp),%eax
  8003ed:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8003f0:	8b 7d 18             	mov    0x18(%ebp),%edi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8003f3:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8003f6:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  8003fd:	39 55 d4             	cmp    %edx,-0x2c(%ebp)
  800400:	72 0c                	jb     80040e <printnum+0x3e>
  800402:	3b 45 d8             	cmp    -0x28(%ebp),%eax
  800405:	76 07                	jbe    80040e <printnum+0x3e>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800407:	4b                   	dec    %ebx
  800408:	85 db                	test   %ebx,%ebx
  80040a:	7f 31                	jg     80043d <printnum+0x6d>
  80040c:	eb 3f                	jmp    80044d <printnum+0x7d>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80040e:	83 ec 0c             	sub    $0xc,%esp
  800411:	57                   	push   %edi
  800412:	4b                   	dec    %ebx
  800413:	53                   	push   %ebx
  800414:	50                   	push   %eax
  800415:	83 ec 08             	sub    $0x8,%esp
  800418:	ff 75 d4             	pushl  -0x2c(%ebp)
  80041b:	ff 75 d0             	pushl  -0x30(%ebp)
  80041e:	ff 75 dc             	pushl  -0x24(%ebp)
  800421:	ff 75 d8             	pushl  -0x28(%ebp)
  800424:	e8 33 09 00 00       	call   800d5c <__udivdi3>
  800429:	83 c4 18             	add    $0x18,%esp
  80042c:	52                   	push   %edx
  80042d:	50                   	push   %eax
  80042e:	89 f2                	mov    %esi,%edx
  800430:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800433:	e8 98 ff ff ff       	call   8003d0 <printnum>
  800438:	83 c4 20             	add    $0x20,%esp
  80043b:	eb 10                	jmp    80044d <printnum+0x7d>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80043d:	83 ec 08             	sub    $0x8,%esp
  800440:	56                   	push   %esi
  800441:	57                   	push   %edi
  800442:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800445:	4b                   	dec    %ebx
  800446:	83 c4 10             	add    $0x10,%esp
  800449:	85 db                	test   %ebx,%ebx
  80044b:	7f f0                	jg     80043d <printnum+0x6d>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80044d:	83 ec 08             	sub    $0x8,%esp
  800450:	56                   	push   %esi
  800451:	83 ec 04             	sub    $0x4,%esp
  800454:	ff 75 d4             	pushl  -0x2c(%ebp)
  800457:	ff 75 d0             	pushl  -0x30(%ebp)
  80045a:	ff 75 dc             	pushl  -0x24(%ebp)
  80045d:	ff 75 d8             	pushl  -0x28(%ebp)
  800460:	e8 13 0a 00 00       	call   800e78 <__umoddi3>
  800465:	83 c4 14             	add    $0x14,%esp
  800468:	0f be 80 1b 10 80 00 	movsbl 0x80101b(%eax),%eax
  80046f:	50                   	push   %eax
  800470:	ff 55 e4             	call   *-0x1c(%ebp)
  800473:	83 c4 10             	add    $0x10,%esp
}
  800476:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800479:	5b                   	pop    %ebx
  80047a:	5e                   	pop    %esi
  80047b:	5f                   	pop    %edi
  80047c:	c9                   	leave  
  80047d:	c3                   	ret    

0080047e <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80047e:	55                   	push   %ebp
  80047f:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800481:	83 fa 01             	cmp    $0x1,%edx
  800484:	7e 0e                	jle    800494 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800486:	8b 10                	mov    (%eax),%edx
  800488:	8d 4a 08             	lea    0x8(%edx),%ecx
  80048b:	89 08                	mov    %ecx,(%eax)
  80048d:	8b 02                	mov    (%edx),%eax
  80048f:	8b 52 04             	mov    0x4(%edx),%edx
  800492:	eb 22                	jmp    8004b6 <getuint+0x38>
	else if (lflag)
  800494:	85 d2                	test   %edx,%edx
  800496:	74 10                	je     8004a8 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800498:	8b 10                	mov    (%eax),%edx
  80049a:	8d 4a 04             	lea    0x4(%edx),%ecx
  80049d:	89 08                	mov    %ecx,(%eax)
  80049f:	8b 02                	mov    (%edx),%eax
  8004a1:	ba 00 00 00 00       	mov    $0x0,%edx
  8004a6:	eb 0e                	jmp    8004b6 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8004a8:	8b 10                	mov    (%eax),%edx
  8004aa:	8d 4a 04             	lea    0x4(%edx),%ecx
  8004ad:	89 08                	mov    %ecx,(%eax)
  8004af:	8b 02                	mov    (%edx),%eax
  8004b1:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8004b6:	c9                   	leave  
  8004b7:	c3                   	ret    

008004b8 <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
  8004b8:	55                   	push   %ebp
  8004b9:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8004bb:	83 fa 01             	cmp    $0x1,%edx
  8004be:	7e 0e                	jle    8004ce <getint+0x16>
		return va_arg(*ap, long long);
  8004c0:	8b 10                	mov    (%eax),%edx
  8004c2:	8d 4a 08             	lea    0x8(%edx),%ecx
  8004c5:	89 08                	mov    %ecx,(%eax)
  8004c7:	8b 02                	mov    (%edx),%eax
  8004c9:	8b 52 04             	mov    0x4(%edx),%edx
  8004cc:	eb 1a                	jmp    8004e8 <getint+0x30>
	else if (lflag)
  8004ce:	85 d2                	test   %edx,%edx
  8004d0:	74 0c                	je     8004de <getint+0x26>
		return va_arg(*ap, long);
  8004d2:	8b 10                	mov    (%eax),%edx
  8004d4:	8d 4a 04             	lea    0x4(%edx),%ecx
  8004d7:	89 08                	mov    %ecx,(%eax)
  8004d9:	8b 02                	mov    (%edx),%eax
  8004db:	99                   	cltd   
  8004dc:	eb 0a                	jmp    8004e8 <getint+0x30>
	else
		return va_arg(*ap, int);
  8004de:	8b 10                	mov    (%eax),%edx
  8004e0:	8d 4a 04             	lea    0x4(%edx),%ecx
  8004e3:	89 08                	mov    %ecx,(%eax)
  8004e5:	8b 02                	mov    (%edx),%eax
  8004e7:	99                   	cltd   
}
  8004e8:	c9                   	leave  
  8004e9:	c3                   	ret    

008004ea <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8004ea:	55                   	push   %ebp
  8004eb:	89 e5                	mov    %esp,%ebp
  8004ed:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8004f0:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  8004f3:	8b 10                	mov    (%eax),%edx
  8004f5:	3b 50 04             	cmp    0x4(%eax),%edx
  8004f8:	73 08                	jae    800502 <sprintputch+0x18>
		*b->buf++ = ch;
  8004fa:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8004fd:	88 0a                	mov    %cl,(%edx)
  8004ff:	42                   	inc    %edx
  800500:	89 10                	mov    %edx,(%eax)
}
  800502:	c9                   	leave  
  800503:	c3                   	ret    

00800504 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800504:	55                   	push   %ebp
  800505:	89 e5                	mov    %esp,%ebp
  800507:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  80050a:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80050d:	50                   	push   %eax
  80050e:	ff 75 10             	pushl  0x10(%ebp)
  800511:	ff 75 0c             	pushl  0xc(%ebp)
  800514:	ff 75 08             	pushl  0x8(%ebp)
  800517:	e8 05 00 00 00       	call   800521 <vprintfmt>
	va_end(ap);
  80051c:	83 c4 10             	add    $0x10,%esp
}
  80051f:	c9                   	leave  
  800520:	c3                   	ret    

00800521 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800521:	55                   	push   %ebp
  800522:	89 e5                	mov    %esp,%ebp
  800524:	57                   	push   %edi
  800525:	56                   	push   %esi
  800526:	53                   	push   %ebx
  800527:	83 ec 2c             	sub    $0x2c,%esp
  80052a:	8b 7d 0c             	mov    0xc(%ebp),%edi
  80052d:	8b 75 10             	mov    0x10(%ebp),%esi
  800530:	eb 13                	jmp    800545 <vprintfmt+0x24>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800532:	85 c0                	test   %eax,%eax
  800534:	0f 84 6d 03 00 00    	je     8008a7 <vprintfmt+0x386>
				return;
			putch(ch, putdat);
  80053a:	83 ec 08             	sub    $0x8,%esp
  80053d:	57                   	push   %edi
  80053e:	50                   	push   %eax
  80053f:	ff 55 08             	call   *0x8(%ebp)
  800542:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800545:	0f b6 06             	movzbl (%esi),%eax
  800548:	46                   	inc    %esi
  800549:	83 f8 25             	cmp    $0x25,%eax
  80054c:	75 e4                	jne    800532 <vprintfmt+0x11>
  80054e:	c6 45 dc 20          	movb   $0x20,-0x24(%ebp)
  800552:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  800559:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
  800560:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  800567:	b9 00 00 00 00       	mov    $0x0,%ecx
  80056c:	eb 28                	jmp    800596 <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80056e:	89 de                	mov    %ebx,%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  800570:	c6 45 dc 2d          	movb   $0x2d,-0x24(%ebp)
  800574:	eb 20                	jmp    800596 <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800576:	89 de                	mov    %ebx,%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800578:	c6 45 dc 30          	movb   $0x30,-0x24(%ebp)
  80057c:	eb 18                	jmp    800596 <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80057e:	89 de                	mov    %ebx,%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  800580:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800587:	eb 0d                	jmp    800596 <vprintfmt+0x75>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  800589:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80058c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80058f:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800596:	8a 06                	mov    (%esi),%al
  800598:	0f b6 d0             	movzbl %al,%edx
  80059b:	8d 5e 01             	lea    0x1(%esi),%ebx
  80059e:	83 e8 23             	sub    $0x23,%eax
  8005a1:	3c 55                	cmp    $0x55,%al
  8005a3:	0f 87 e0 02 00 00    	ja     800889 <vprintfmt+0x368>
  8005a9:	0f b6 c0             	movzbl %al,%eax
  8005ac:	ff 24 85 e0 10 80 00 	jmp    *0x8010e0(,%eax,4)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8005b3:	83 ea 30             	sub    $0x30,%edx
  8005b6:	89 55 d4             	mov    %edx,-0x2c(%ebp)
				ch = *fmt;
  8005b9:	0f be 03             	movsbl (%ebx),%eax
				if (ch < '0' || ch > '9')
  8005bc:	8d 50 d0             	lea    -0x30(%eax),%edx
  8005bf:	83 fa 09             	cmp    $0x9,%edx
  8005c2:	77 44                	ja     800608 <vprintfmt+0xe7>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005c4:	89 de                	mov    %ebx,%esi
  8005c6:	8b 55 d4             	mov    -0x2c(%ebp),%edx
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8005c9:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
  8005ca:	8d 14 92             	lea    (%edx,%edx,4),%edx
  8005cd:	8d 54 50 d0          	lea    -0x30(%eax,%edx,2),%edx
				ch = *fmt;
  8005d1:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  8005d4:	8d 58 d0             	lea    -0x30(%eax),%ebx
  8005d7:	83 fb 09             	cmp    $0x9,%ebx
  8005da:	76 ed                	jbe    8005c9 <vprintfmt+0xa8>
  8005dc:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  8005df:	eb 29                	jmp    80060a <vprintfmt+0xe9>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8005e1:	8b 45 14             	mov    0x14(%ebp),%eax
  8005e4:	8d 50 04             	lea    0x4(%eax),%edx
  8005e7:	89 55 14             	mov    %edx,0x14(%ebp)
  8005ea:	8b 00                	mov    (%eax),%eax
  8005ec:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005ef:	89 de                	mov    %ebx,%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8005f1:	eb 17                	jmp    80060a <vprintfmt+0xe9>

		case '.':
			if (width < 0)
  8005f3:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8005f7:	78 85                	js     80057e <vprintfmt+0x5d>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005f9:	89 de                	mov    %ebx,%esi
  8005fb:	eb 99                	jmp    800596 <vprintfmt+0x75>
  8005fd:	89 de                	mov    %ebx,%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8005ff:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
			goto reswitch;
  800606:	eb 8e                	jmp    800596 <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800608:	89 de                	mov    %ebx,%esi
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  80060a:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80060e:	79 86                	jns    800596 <vprintfmt+0x75>
  800610:	e9 74 ff ff ff       	jmp    800589 <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800615:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800616:	89 de                	mov    %ebx,%esi
  800618:	e9 79 ff ff ff       	jmp    800596 <vprintfmt+0x75>
  80061d:	89 5d d8             	mov    %ebx,-0x28(%ebp)
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800620:	8b 45 14             	mov    0x14(%ebp),%eax
  800623:	8d 50 04             	lea    0x4(%eax),%edx
  800626:	89 55 14             	mov    %edx,0x14(%ebp)
  800629:	83 ec 08             	sub    $0x8,%esp
  80062c:	57                   	push   %edi
  80062d:	ff 30                	pushl  (%eax)
  80062f:	ff 55 08             	call   *0x8(%ebp)
			break;
  800632:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800635:	8b 75 d8             	mov    -0x28(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800638:	e9 08 ff ff ff       	jmp    800545 <vprintfmt+0x24>
  80063d:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// error message
		case 'e':
			err = va_arg(ap, int);
  800640:	8b 45 14             	mov    0x14(%ebp),%eax
  800643:	8d 50 04             	lea    0x4(%eax),%edx
  800646:	89 55 14             	mov    %edx,0x14(%ebp)
  800649:	8b 00                	mov    (%eax),%eax
  80064b:	85 c0                	test   %eax,%eax
  80064d:	79 02                	jns    800651 <vprintfmt+0x130>
  80064f:	f7 d8                	neg    %eax
  800651:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800653:	83 f8 08             	cmp    $0x8,%eax
  800656:	7f 0b                	jg     800663 <vprintfmt+0x142>
  800658:	8b 04 85 40 12 80 00 	mov    0x801240(,%eax,4),%eax
  80065f:	85 c0                	test   %eax,%eax
  800661:	75 1a                	jne    80067d <vprintfmt+0x15c>
				printfmt(putch, putdat, "error %d", err);
  800663:	52                   	push   %edx
  800664:	68 33 10 80 00       	push   $0x801033
  800669:	57                   	push   %edi
  80066a:	ff 75 08             	pushl  0x8(%ebp)
  80066d:	e8 92 fe ff ff       	call   800504 <printfmt>
  800672:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800675:	8b 75 d8             	mov    -0x28(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800678:	e9 c8 fe ff ff       	jmp    800545 <vprintfmt+0x24>
			else
				printfmt(putch, putdat, "%s", p);
  80067d:	50                   	push   %eax
  80067e:	68 3c 10 80 00       	push   $0x80103c
  800683:	57                   	push   %edi
  800684:	ff 75 08             	pushl  0x8(%ebp)
  800687:	e8 78 fe ff ff       	call   800504 <printfmt>
  80068c:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80068f:	8b 75 d8             	mov    -0x28(%ebp),%esi
  800692:	e9 ae fe ff ff       	jmp    800545 <vprintfmt+0x24>
  800697:	89 5d d8             	mov    %ebx,-0x28(%ebp)
  80069a:	89 de                	mov    %ebx,%esi
  80069c:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  80069f:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8006a2:	8b 45 14             	mov    0x14(%ebp),%eax
  8006a5:	8d 50 04             	lea    0x4(%eax),%edx
  8006a8:	89 55 14             	mov    %edx,0x14(%ebp)
  8006ab:	8b 00                	mov    (%eax),%eax
  8006ad:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8006b0:	85 c0                	test   %eax,%eax
  8006b2:	75 07                	jne    8006bb <vprintfmt+0x19a>
				p = "(null)";
  8006b4:	c7 45 d0 2c 10 80 00 	movl   $0x80102c,-0x30(%ebp)
			if (width > 0 && padc != '-')
  8006bb:	85 db                	test   %ebx,%ebx
  8006bd:	7e 42                	jle    800701 <vprintfmt+0x1e0>
  8006bf:	80 7d dc 2d          	cmpb   $0x2d,-0x24(%ebp)
  8006c3:	74 3c                	je     800701 <vprintfmt+0x1e0>
				for (width -= strnlen(p, precision); width > 0; width--)
  8006c5:	83 ec 08             	sub    $0x8,%esp
  8006c8:	51                   	push   %ecx
  8006c9:	ff 75 d0             	pushl  -0x30(%ebp)
  8006cc:	e8 6f 02 00 00       	call   800940 <strnlen>
  8006d1:	29 c3                	sub    %eax,%ebx
  8006d3:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8006d6:	83 c4 10             	add    $0x10,%esp
  8006d9:	85 db                	test   %ebx,%ebx
  8006db:	7e 24                	jle    800701 <vprintfmt+0x1e0>
					putch(padc, putdat);
  8006dd:	0f be 5d dc          	movsbl -0x24(%ebp),%ebx
  8006e1:	89 75 dc             	mov    %esi,-0x24(%ebp)
  8006e4:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  8006e7:	83 ec 08             	sub    $0x8,%esp
  8006ea:	57                   	push   %edi
  8006eb:	53                   	push   %ebx
  8006ec:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8006ef:	4e                   	dec    %esi
  8006f0:	83 c4 10             	add    $0x10,%esp
  8006f3:	85 f6                	test   %esi,%esi
  8006f5:	7f f0                	jg     8006e7 <vprintfmt+0x1c6>
  8006f7:	8b 75 dc             	mov    -0x24(%ebp),%esi
  8006fa:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800701:	8b 55 d0             	mov    -0x30(%ebp),%edx
  800704:	0f be 02             	movsbl (%edx),%eax
  800707:	85 c0                	test   %eax,%eax
  800709:	75 47                	jne    800752 <vprintfmt+0x231>
  80070b:	eb 37                	jmp    800744 <vprintfmt+0x223>
				if (altflag && (ch < ' ' || ch > '~'))
  80070d:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800711:	74 16                	je     800729 <vprintfmt+0x208>
  800713:	8d 50 e0             	lea    -0x20(%eax),%edx
  800716:	83 fa 5e             	cmp    $0x5e,%edx
  800719:	76 0e                	jbe    800729 <vprintfmt+0x208>
					putch('?', putdat);
  80071b:	83 ec 08             	sub    $0x8,%esp
  80071e:	57                   	push   %edi
  80071f:	6a 3f                	push   $0x3f
  800721:	ff 55 08             	call   *0x8(%ebp)
  800724:	83 c4 10             	add    $0x10,%esp
  800727:	eb 0b                	jmp    800734 <vprintfmt+0x213>
				else
					putch(ch, putdat);
  800729:	83 ec 08             	sub    $0x8,%esp
  80072c:	57                   	push   %edi
  80072d:	50                   	push   %eax
  80072e:	ff 55 08             	call   *0x8(%ebp)
  800731:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800734:	ff 4d e4             	decl   -0x1c(%ebp)
  800737:	0f be 03             	movsbl (%ebx),%eax
  80073a:	85 c0                	test   %eax,%eax
  80073c:	74 03                	je     800741 <vprintfmt+0x220>
  80073e:	43                   	inc    %ebx
  80073f:	eb 1b                	jmp    80075c <vprintfmt+0x23b>
  800741:	8b 75 dc             	mov    -0x24(%ebp),%esi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800744:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800748:	7f 1e                	jg     800768 <vprintfmt+0x247>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80074a:	8b 75 d8             	mov    -0x28(%ebp),%esi
  80074d:	e9 f3 fd ff ff       	jmp    800545 <vprintfmt+0x24>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800752:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  800755:	43                   	inc    %ebx
  800756:	89 75 dc             	mov    %esi,-0x24(%ebp)
  800759:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  80075c:	85 f6                	test   %esi,%esi
  80075e:	78 ad                	js     80070d <vprintfmt+0x1ec>
  800760:	4e                   	dec    %esi
  800761:	79 aa                	jns    80070d <vprintfmt+0x1ec>
  800763:	8b 75 dc             	mov    -0x24(%ebp),%esi
  800766:	eb dc                	jmp    800744 <vprintfmt+0x223>
  800768:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80076b:	83 ec 08             	sub    $0x8,%esp
  80076e:	57                   	push   %edi
  80076f:	6a 20                	push   $0x20
  800771:	ff 55 08             	call   *0x8(%ebp)
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800774:	4b                   	dec    %ebx
  800775:	83 c4 10             	add    $0x10,%esp
  800778:	85 db                	test   %ebx,%ebx
  80077a:	7f ef                	jg     80076b <vprintfmt+0x24a>
  80077c:	e9 c4 fd ff ff       	jmp    800545 <vprintfmt+0x24>
  800781:	89 5d d8             	mov    %ebx,-0x28(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800784:	89 ca                	mov    %ecx,%edx
  800786:	8d 45 14             	lea    0x14(%ebp),%eax
  800789:	e8 2a fd ff ff       	call   8004b8 <getint>
  80078e:	89 c3                	mov    %eax,%ebx
  800790:	89 d6                	mov    %edx,%esi
			if ((long long) num < 0) {
  800792:	85 d2                	test   %edx,%edx
  800794:	78 0a                	js     8007a0 <vprintfmt+0x27f>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800796:	b8 0a 00 00 00       	mov    $0xa,%eax
  80079b:	e9 b0 00 00 00       	jmp    800850 <vprintfmt+0x32f>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  8007a0:	83 ec 08             	sub    $0x8,%esp
  8007a3:	57                   	push   %edi
  8007a4:	6a 2d                	push   $0x2d
  8007a6:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  8007a9:	f7 db                	neg    %ebx
  8007ab:	83 d6 00             	adc    $0x0,%esi
  8007ae:	f7 de                	neg    %esi
  8007b0:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  8007b3:	b8 0a 00 00 00       	mov    $0xa,%eax
  8007b8:	e9 93 00 00 00       	jmp    800850 <vprintfmt+0x32f>
  8007bd:	89 5d d8             	mov    %ebx,-0x28(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8007c0:	89 ca                	mov    %ecx,%edx
  8007c2:	8d 45 14             	lea    0x14(%ebp),%eax
  8007c5:	e8 b4 fc ff ff       	call   80047e <getuint>
  8007ca:	89 c3                	mov    %eax,%ebx
  8007cc:	89 d6                	mov    %edx,%esi
			base = 10;
  8007ce:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  8007d3:	eb 7b                	jmp    800850 <vprintfmt+0x32f>
  8007d5:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// (unsigned) octal
		case 'o':
            // (MIT 6.828, lab1, Ex.8)  my code : 
            num = getint(&ap, lflag);
  8007d8:	89 ca                	mov    %ecx,%edx
  8007da:	8d 45 14             	lea    0x14(%ebp),%eax
  8007dd:	e8 d6 fc ff ff       	call   8004b8 <getint>
  8007e2:	89 c3                	mov    %eax,%ebx
  8007e4:	89 d6                	mov    %edx,%esi
            if ((long long) num < 0) {
  8007e6:	85 d2                	test   %edx,%edx
  8007e8:	78 07                	js     8007f1 <vprintfmt+0x2d0>
                putch('-', putdat);
                num = -(long long) num;
            }
            base = 8;
  8007ea:	b8 08 00 00 00       	mov    $0x8,%eax
  8007ef:	eb 5f                	jmp    800850 <vprintfmt+0x32f>
		// (unsigned) octal
		case 'o':
            // (MIT 6.828, lab1, Ex.8)  my code : 
            num = getint(&ap, lflag);
            if ((long long) num < 0) {
                putch('-', putdat);
  8007f1:	83 ec 08             	sub    $0x8,%esp
  8007f4:	57                   	push   %edi
  8007f5:	6a 2d                	push   $0x2d
  8007f7:	ff 55 08             	call   *0x8(%ebp)
                num = -(long long) num;
  8007fa:	f7 db                	neg    %ebx
  8007fc:	83 d6 00             	adc    $0x0,%esi
  8007ff:	f7 de                	neg    %esi
  800801:	83 c4 10             	add    $0x10,%esp
            }
            base = 8;
  800804:	b8 08 00 00 00       	mov    $0x8,%eax
  800809:	eb 45                	jmp    800850 <vprintfmt+0x32f>
  80080b:	89 5d d8             	mov    %ebx,-0x28(%ebp)
            goto number;

        // pointer
		case 'p':
			putch('0', putdat);
  80080e:	83 ec 08             	sub    $0x8,%esp
  800811:	57                   	push   %edi
  800812:	6a 30                	push   $0x30
  800814:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  800817:	83 c4 08             	add    $0x8,%esp
  80081a:	57                   	push   %edi
  80081b:	6a 78                	push   $0x78
  80081d:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800820:	8b 45 14             	mov    0x14(%ebp),%eax
  800823:	8d 50 04             	lea    0x4(%eax),%edx
  800826:	89 55 14             	mov    %edx,0x14(%ebp)

        // pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800829:	8b 18                	mov    (%eax),%ebx
  80082b:	be 00 00 00 00       	mov    $0x0,%esi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800830:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800833:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  800838:	eb 16                	jmp    800850 <vprintfmt+0x32f>
  80083a:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  80083d:	89 ca                	mov    %ecx,%edx
  80083f:	8d 45 14             	lea    0x14(%ebp),%eax
  800842:	e8 37 fc ff ff       	call   80047e <getuint>
  800847:	89 c3                	mov    %eax,%ebx
  800849:	89 d6                	mov    %edx,%esi
			base = 16;
  80084b:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  800850:	83 ec 0c             	sub    $0xc,%esp
  800853:	0f be 55 dc          	movsbl -0x24(%ebp),%edx
  800857:	52                   	push   %edx
  800858:	ff 75 e4             	pushl  -0x1c(%ebp)
  80085b:	50                   	push   %eax
  80085c:	56                   	push   %esi
  80085d:	53                   	push   %ebx
  80085e:	89 fa                	mov    %edi,%edx
  800860:	8b 45 08             	mov    0x8(%ebp),%eax
  800863:	e8 68 fb ff ff       	call   8003d0 <printnum>
			break;
  800868:	83 c4 20             	add    $0x20,%esp
  80086b:	8b 75 d8             	mov    -0x28(%ebp),%esi
  80086e:	e9 d2 fc ff ff       	jmp    800545 <vprintfmt+0x24>
  800873:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800876:	83 ec 08             	sub    $0x8,%esp
  800879:	57                   	push   %edi
  80087a:	52                   	push   %edx
  80087b:	ff 55 08             	call   *0x8(%ebp)
			break;
  80087e:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800881:	8b 75 d8             	mov    -0x28(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800884:	e9 bc fc ff ff       	jmp    800545 <vprintfmt+0x24>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800889:	83 ec 08             	sub    $0x8,%esp
  80088c:	57                   	push   %edi
  80088d:	6a 25                	push   $0x25
  80088f:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800892:	83 c4 10             	add    $0x10,%esp
  800895:	eb 02                	jmp    800899 <vprintfmt+0x378>
  800897:	89 c6                	mov    %eax,%esi
  800899:	8d 46 ff             	lea    -0x1(%esi),%eax
  80089c:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  8008a0:	75 f5                	jne    800897 <vprintfmt+0x376>
  8008a2:	e9 9e fc ff ff       	jmp    800545 <vprintfmt+0x24>
				/* do nothing */;
			break;
		}
	}
}
  8008a7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8008aa:	5b                   	pop    %ebx
  8008ab:	5e                   	pop    %esi
  8008ac:	5f                   	pop    %edi
  8008ad:	c9                   	leave  
  8008ae:	c3                   	ret    

008008af <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8008af:	55                   	push   %ebp
  8008b0:	89 e5                	mov    %esp,%ebp
  8008b2:	83 ec 18             	sub    $0x18,%esp
  8008b5:	8b 45 08             	mov    0x8(%ebp),%eax
  8008b8:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8008bb:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8008be:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8008c2:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8008c5:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8008cc:	85 c0                	test   %eax,%eax
  8008ce:	74 26                	je     8008f6 <vsnprintf+0x47>
  8008d0:	85 d2                	test   %edx,%edx
  8008d2:	7e 29                	jle    8008fd <vsnprintf+0x4e>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8008d4:	ff 75 14             	pushl  0x14(%ebp)
  8008d7:	ff 75 10             	pushl  0x10(%ebp)
  8008da:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8008dd:	50                   	push   %eax
  8008de:	68 ea 04 80 00       	push   $0x8004ea
  8008e3:	e8 39 fc ff ff       	call   800521 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8008e8:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8008eb:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8008ee:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8008f1:	83 c4 10             	add    $0x10,%esp
  8008f4:	eb 0c                	jmp    800902 <vsnprintf+0x53>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8008f6:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8008fb:	eb 05                	jmp    800902 <vsnprintf+0x53>
  8008fd:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800902:	c9                   	leave  
  800903:	c3                   	ret    

00800904 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800904:	55                   	push   %ebp
  800905:	89 e5                	mov    %esp,%ebp
  800907:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80090a:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80090d:	50                   	push   %eax
  80090e:	ff 75 10             	pushl  0x10(%ebp)
  800911:	ff 75 0c             	pushl  0xc(%ebp)
  800914:	ff 75 08             	pushl  0x8(%ebp)
  800917:	e8 93 ff ff ff       	call   8008af <vsnprintf>
	va_end(ap);

	return rc;
}
  80091c:	c9                   	leave  
  80091d:	c3                   	ret    
	...

00800920 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800920:	55                   	push   %ebp
  800921:	89 e5                	mov    %esp,%ebp
  800923:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800926:	80 3a 00             	cmpb   $0x0,(%edx)
  800929:	74 0e                	je     800939 <strlen+0x19>
  80092b:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  800930:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800931:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800935:	75 f9                	jne    800930 <strlen+0x10>
  800937:	eb 05                	jmp    80093e <strlen+0x1e>
  800939:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  80093e:	c9                   	leave  
  80093f:	c3                   	ret    

00800940 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800940:	55                   	push   %ebp
  800941:	89 e5                	mov    %esp,%ebp
  800943:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800946:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800949:	85 d2                	test   %edx,%edx
  80094b:	74 17                	je     800964 <strnlen+0x24>
  80094d:	80 39 00             	cmpb   $0x0,(%ecx)
  800950:	74 19                	je     80096b <strnlen+0x2b>
  800952:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  800957:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800958:	39 d0                	cmp    %edx,%eax
  80095a:	74 14                	je     800970 <strnlen+0x30>
  80095c:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800960:	75 f5                	jne    800957 <strnlen+0x17>
  800962:	eb 0c                	jmp    800970 <strnlen+0x30>
  800964:	b8 00 00 00 00       	mov    $0x0,%eax
  800969:	eb 05                	jmp    800970 <strnlen+0x30>
  80096b:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  800970:	c9                   	leave  
  800971:	c3                   	ret    

00800972 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800972:	55                   	push   %ebp
  800973:	89 e5                	mov    %esp,%ebp
  800975:	53                   	push   %ebx
  800976:	8b 45 08             	mov    0x8(%ebp),%eax
  800979:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  80097c:	ba 00 00 00 00       	mov    $0x0,%edx
  800981:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  800984:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800987:	42                   	inc    %edx
  800988:	84 c9                	test   %cl,%cl
  80098a:	75 f5                	jne    800981 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  80098c:	5b                   	pop    %ebx
  80098d:	c9                   	leave  
  80098e:	c3                   	ret    

0080098f <strcat>:

char *
strcat(char *dst, const char *src)
{
  80098f:	55                   	push   %ebp
  800990:	89 e5                	mov    %esp,%ebp
  800992:	53                   	push   %ebx
  800993:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800996:	53                   	push   %ebx
  800997:	e8 84 ff ff ff       	call   800920 <strlen>
  80099c:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  80099f:	ff 75 0c             	pushl  0xc(%ebp)
  8009a2:	8d 04 03             	lea    (%ebx,%eax,1),%eax
  8009a5:	50                   	push   %eax
  8009a6:	e8 c7 ff ff ff       	call   800972 <strcpy>
	return dst;
}
  8009ab:	89 d8                	mov    %ebx,%eax
  8009ad:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8009b0:	c9                   	leave  
  8009b1:	c3                   	ret    

008009b2 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8009b2:	55                   	push   %ebp
  8009b3:	89 e5                	mov    %esp,%ebp
  8009b5:	56                   	push   %esi
  8009b6:	53                   	push   %ebx
  8009b7:	8b 45 08             	mov    0x8(%ebp),%eax
  8009ba:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009bd:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8009c0:	85 f6                	test   %esi,%esi
  8009c2:	74 15                	je     8009d9 <strncpy+0x27>
  8009c4:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
  8009c9:	8a 1a                	mov    (%edx),%bl
  8009cb:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8009ce:	80 3a 01             	cmpb   $0x1,(%edx)
  8009d1:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8009d4:	41                   	inc    %ecx
  8009d5:	39 ce                	cmp    %ecx,%esi
  8009d7:	77 f0                	ja     8009c9 <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8009d9:	5b                   	pop    %ebx
  8009da:	5e                   	pop    %esi
  8009db:	c9                   	leave  
  8009dc:	c3                   	ret    

008009dd <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8009dd:	55                   	push   %ebp
  8009de:	89 e5                	mov    %esp,%ebp
  8009e0:	57                   	push   %edi
  8009e1:	56                   	push   %esi
  8009e2:	53                   	push   %ebx
  8009e3:	8b 7d 08             	mov    0x8(%ebp),%edi
  8009e6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8009e9:	8b 75 10             	mov    0x10(%ebp),%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8009ec:	85 f6                	test   %esi,%esi
  8009ee:	74 32                	je     800a22 <strlcpy+0x45>
		while (--size > 0 && *src != '\0')
  8009f0:	83 fe 01             	cmp    $0x1,%esi
  8009f3:	74 22                	je     800a17 <strlcpy+0x3a>
  8009f5:	8a 0b                	mov    (%ebx),%cl
  8009f7:	84 c9                	test   %cl,%cl
  8009f9:	74 20                	je     800a1b <strlcpy+0x3e>
  8009fb:	89 f8                	mov    %edi,%eax
  8009fd:	ba 00 00 00 00       	mov    $0x0,%edx
	}
	return ret;
}

size_t
strlcpy(char *dst, const char *src, size_t size)
  800a02:	83 ee 02             	sub    $0x2,%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800a05:	88 08                	mov    %cl,(%eax)
  800a07:	40                   	inc    %eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800a08:	39 f2                	cmp    %esi,%edx
  800a0a:	74 11                	je     800a1d <strlcpy+0x40>
  800a0c:	8a 4c 13 01          	mov    0x1(%ebx,%edx,1),%cl
  800a10:	42                   	inc    %edx
  800a11:	84 c9                	test   %cl,%cl
  800a13:	75 f0                	jne    800a05 <strlcpy+0x28>
  800a15:	eb 06                	jmp    800a1d <strlcpy+0x40>
  800a17:	89 f8                	mov    %edi,%eax
  800a19:	eb 02                	jmp    800a1d <strlcpy+0x40>
  800a1b:	89 f8                	mov    %edi,%eax
			*dst++ = *src++;
		*dst = '\0';
  800a1d:	c6 00 00             	movb   $0x0,(%eax)
  800a20:	eb 02                	jmp    800a24 <strlcpy+0x47>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800a22:	89 f8                	mov    %edi,%eax
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
		*dst = '\0';
	}
	return dst - dst_in;
  800a24:	29 f8                	sub    %edi,%eax
}
  800a26:	5b                   	pop    %ebx
  800a27:	5e                   	pop    %esi
  800a28:	5f                   	pop    %edi
  800a29:	c9                   	leave  
  800a2a:	c3                   	ret    

00800a2b <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800a2b:	55                   	push   %ebp
  800a2c:	89 e5                	mov    %esp,%ebp
  800a2e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a31:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800a34:	8a 01                	mov    (%ecx),%al
  800a36:	84 c0                	test   %al,%al
  800a38:	74 10                	je     800a4a <strcmp+0x1f>
  800a3a:	3a 02                	cmp    (%edx),%al
  800a3c:	75 0c                	jne    800a4a <strcmp+0x1f>
		p++, q++;
  800a3e:	41                   	inc    %ecx
  800a3f:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800a40:	8a 01                	mov    (%ecx),%al
  800a42:	84 c0                	test   %al,%al
  800a44:	74 04                	je     800a4a <strcmp+0x1f>
  800a46:	3a 02                	cmp    (%edx),%al
  800a48:	74 f4                	je     800a3e <strcmp+0x13>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800a4a:	0f b6 c0             	movzbl %al,%eax
  800a4d:	0f b6 12             	movzbl (%edx),%edx
  800a50:	29 d0                	sub    %edx,%eax
}
  800a52:	c9                   	leave  
  800a53:	c3                   	ret    

00800a54 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800a54:	55                   	push   %ebp
  800a55:	89 e5                	mov    %esp,%ebp
  800a57:	53                   	push   %ebx
  800a58:	8b 55 08             	mov    0x8(%ebp),%edx
  800a5b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a5e:	8b 45 10             	mov    0x10(%ebp),%eax
	while (n > 0 && *p && *p == *q)
  800a61:	85 c0                	test   %eax,%eax
  800a63:	74 1b                	je     800a80 <strncmp+0x2c>
  800a65:	8a 1a                	mov    (%edx),%bl
  800a67:	84 db                	test   %bl,%bl
  800a69:	74 24                	je     800a8f <strncmp+0x3b>
  800a6b:	3a 19                	cmp    (%ecx),%bl
  800a6d:	75 20                	jne    800a8f <strncmp+0x3b>
  800a6f:	48                   	dec    %eax
  800a70:	74 15                	je     800a87 <strncmp+0x33>
		n--, p++, q++;
  800a72:	42                   	inc    %edx
  800a73:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800a74:	8a 1a                	mov    (%edx),%bl
  800a76:	84 db                	test   %bl,%bl
  800a78:	74 15                	je     800a8f <strncmp+0x3b>
  800a7a:	3a 19                	cmp    (%ecx),%bl
  800a7c:	74 f1                	je     800a6f <strncmp+0x1b>
  800a7e:	eb 0f                	jmp    800a8f <strncmp+0x3b>
		n--, p++, q++;
	if (n == 0)
		return 0;
  800a80:	b8 00 00 00 00       	mov    $0x0,%eax
  800a85:	eb 05                	jmp    800a8c <strncmp+0x38>
  800a87:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800a8c:	5b                   	pop    %ebx
  800a8d:	c9                   	leave  
  800a8e:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800a8f:	0f b6 02             	movzbl (%edx),%eax
  800a92:	0f b6 11             	movzbl (%ecx),%edx
  800a95:	29 d0                	sub    %edx,%eax
  800a97:	eb f3                	jmp    800a8c <strncmp+0x38>

00800a99 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800a99:	55                   	push   %ebp
  800a9a:	89 e5                	mov    %esp,%ebp
  800a9c:	8b 45 08             	mov    0x8(%ebp),%eax
  800a9f:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800aa2:	8a 10                	mov    (%eax),%dl
  800aa4:	84 d2                	test   %dl,%dl
  800aa6:	74 18                	je     800ac0 <strchr+0x27>
		if (*s == c)
  800aa8:	38 ca                	cmp    %cl,%dl
  800aaa:	75 06                	jne    800ab2 <strchr+0x19>
  800aac:	eb 17                	jmp    800ac5 <strchr+0x2c>
  800aae:	38 ca                	cmp    %cl,%dl
  800ab0:	74 13                	je     800ac5 <strchr+0x2c>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800ab2:	40                   	inc    %eax
  800ab3:	8a 10                	mov    (%eax),%dl
  800ab5:	84 d2                	test   %dl,%dl
  800ab7:	75 f5                	jne    800aae <strchr+0x15>
		if (*s == c)
			return (char *) s;
	return 0;
  800ab9:	b8 00 00 00 00       	mov    $0x0,%eax
  800abe:	eb 05                	jmp    800ac5 <strchr+0x2c>
  800ac0:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800ac5:	c9                   	leave  
  800ac6:	c3                   	ret    

00800ac7 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800ac7:	55                   	push   %ebp
  800ac8:	89 e5                	mov    %esp,%ebp
  800aca:	8b 45 08             	mov    0x8(%ebp),%eax
  800acd:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800ad0:	8a 10                	mov    (%eax),%dl
  800ad2:	84 d2                	test   %dl,%dl
  800ad4:	74 11                	je     800ae7 <strfind+0x20>
		if (*s == c)
  800ad6:	38 ca                	cmp    %cl,%dl
  800ad8:	75 06                	jne    800ae0 <strfind+0x19>
  800ada:	eb 0b                	jmp    800ae7 <strfind+0x20>
  800adc:	38 ca                	cmp    %cl,%dl
  800ade:	74 07                	je     800ae7 <strfind+0x20>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800ae0:	40                   	inc    %eax
  800ae1:	8a 10                	mov    (%eax),%dl
  800ae3:	84 d2                	test   %dl,%dl
  800ae5:	75 f5                	jne    800adc <strfind+0x15>
		if (*s == c)
			break;
	return (char *) s;
}
  800ae7:	c9                   	leave  
  800ae8:	c3                   	ret    

00800ae9 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800ae9:	55                   	push   %ebp
  800aea:	89 e5                	mov    %esp,%ebp
  800aec:	57                   	push   %edi
  800aed:	56                   	push   %esi
  800aee:	53                   	push   %ebx
  800aef:	8b 7d 08             	mov    0x8(%ebp),%edi
  800af2:	8b 45 0c             	mov    0xc(%ebp),%eax
  800af5:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800af8:	85 c9                	test   %ecx,%ecx
  800afa:	74 30                	je     800b2c <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800afc:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800b02:	75 25                	jne    800b29 <memset+0x40>
  800b04:	f6 c1 03             	test   $0x3,%cl
  800b07:	75 20                	jne    800b29 <memset+0x40>
		c &= 0xFF;
  800b09:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800b0c:	89 d3                	mov    %edx,%ebx
  800b0e:	c1 e3 08             	shl    $0x8,%ebx
  800b11:	89 d6                	mov    %edx,%esi
  800b13:	c1 e6 18             	shl    $0x18,%esi
  800b16:	89 d0                	mov    %edx,%eax
  800b18:	c1 e0 10             	shl    $0x10,%eax
  800b1b:	09 f0                	or     %esi,%eax
  800b1d:	09 d0                	or     %edx,%eax
  800b1f:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800b21:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800b24:	fc                   	cld    
  800b25:	f3 ab                	rep stos %eax,%es:(%edi)
  800b27:	eb 03                	jmp    800b2c <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800b29:	fc                   	cld    
  800b2a:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800b2c:	89 f8                	mov    %edi,%eax
  800b2e:	5b                   	pop    %ebx
  800b2f:	5e                   	pop    %esi
  800b30:	5f                   	pop    %edi
  800b31:	c9                   	leave  
  800b32:	c3                   	ret    

00800b33 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800b33:	55                   	push   %ebp
  800b34:	89 e5                	mov    %esp,%ebp
  800b36:	57                   	push   %edi
  800b37:	56                   	push   %esi
  800b38:	8b 45 08             	mov    0x8(%ebp),%eax
  800b3b:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b3e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800b41:	39 c6                	cmp    %eax,%esi
  800b43:	73 34                	jae    800b79 <memmove+0x46>
  800b45:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800b48:	39 d0                	cmp    %edx,%eax
  800b4a:	73 2d                	jae    800b79 <memmove+0x46>
		s += n;
		d += n;
  800b4c:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b4f:	f6 c2 03             	test   $0x3,%dl
  800b52:	75 1b                	jne    800b6f <memmove+0x3c>
  800b54:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800b5a:	75 13                	jne    800b6f <memmove+0x3c>
  800b5c:	f6 c1 03             	test   $0x3,%cl
  800b5f:	75 0e                	jne    800b6f <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800b61:	83 ef 04             	sub    $0x4,%edi
  800b64:	8d 72 fc             	lea    -0x4(%edx),%esi
  800b67:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800b6a:	fd                   	std    
  800b6b:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b6d:	eb 07                	jmp    800b76 <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800b6f:	4f                   	dec    %edi
  800b70:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800b73:	fd                   	std    
  800b74:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800b76:	fc                   	cld    
  800b77:	eb 20                	jmp    800b99 <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b79:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800b7f:	75 13                	jne    800b94 <memmove+0x61>
  800b81:	a8 03                	test   $0x3,%al
  800b83:	75 0f                	jne    800b94 <memmove+0x61>
  800b85:	f6 c1 03             	test   $0x3,%cl
  800b88:	75 0a                	jne    800b94 <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800b8a:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800b8d:	89 c7                	mov    %eax,%edi
  800b8f:	fc                   	cld    
  800b90:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b92:	eb 05                	jmp    800b99 <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800b94:	89 c7                	mov    %eax,%edi
  800b96:	fc                   	cld    
  800b97:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800b99:	5e                   	pop    %esi
  800b9a:	5f                   	pop    %edi
  800b9b:	c9                   	leave  
  800b9c:	c3                   	ret    

00800b9d <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800b9d:	55                   	push   %ebp
  800b9e:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800ba0:	ff 75 10             	pushl  0x10(%ebp)
  800ba3:	ff 75 0c             	pushl  0xc(%ebp)
  800ba6:	ff 75 08             	pushl  0x8(%ebp)
  800ba9:	e8 85 ff ff ff       	call   800b33 <memmove>
}
  800bae:	c9                   	leave  
  800baf:	c3                   	ret    

00800bb0 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800bb0:	55                   	push   %ebp
  800bb1:	89 e5                	mov    %esp,%ebp
  800bb3:	57                   	push   %edi
  800bb4:	56                   	push   %esi
  800bb5:	53                   	push   %ebx
  800bb6:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800bb9:	8b 75 0c             	mov    0xc(%ebp),%esi
  800bbc:	8b 7d 10             	mov    0x10(%ebp),%edi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800bbf:	85 ff                	test   %edi,%edi
  800bc1:	74 32                	je     800bf5 <memcmp+0x45>
		if (*s1 != *s2)
  800bc3:	8a 03                	mov    (%ebx),%al
  800bc5:	8a 0e                	mov    (%esi),%cl
  800bc7:	38 c8                	cmp    %cl,%al
  800bc9:	74 19                	je     800be4 <memcmp+0x34>
  800bcb:	eb 0d                	jmp    800bda <memcmp+0x2a>
  800bcd:	8a 44 13 01          	mov    0x1(%ebx,%edx,1),%al
  800bd1:	8a 4c 16 01          	mov    0x1(%esi,%edx,1),%cl
  800bd5:	42                   	inc    %edx
  800bd6:	38 c8                	cmp    %cl,%al
  800bd8:	74 10                	je     800bea <memcmp+0x3a>
			return (int) *s1 - (int) *s2;
  800bda:	0f b6 c0             	movzbl %al,%eax
  800bdd:	0f b6 c9             	movzbl %cl,%ecx
  800be0:	29 c8                	sub    %ecx,%eax
  800be2:	eb 16                	jmp    800bfa <memcmp+0x4a>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800be4:	4f                   	dec    %edi
  800be5:	ba 00 00 00 00       	mov    $0x0,%edx
  800bea:	39 fa                	cmp    %edi,%edx
  800bec:	75 df                	jne    800bcd <memcmp+0x1d>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800bee:	b8 00 00 00 00       	mov    $0x0,%eax
  800bf3:	eb 05                	jmp    800bfa <memcmp+0x4a>
  800bf5:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800bfa:	5b                   	pop    %ebx
  800bfb:	5e                   	pop    %esi
  800bfc:	5f                   	pop    %edi
  800bfd:	c9                   	leave  
  800bfe:	c3                   	ret    

00800bff <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800bff:	55                   	push   %ebp
  800c00:	89 e5                	mov    %esp,%ebp
  800c02:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800c05:	89 c2                	mov    %eax,%edx
  800c07:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800c0a:	39 d0                	cmp    %edx,%eax
  800c0c:	73 12                	jae    800c20 <memfind+0x21>
		if (*(const unsigned char *) s == (unsigned char) c)
  800c0e:	8a 4d 0c             	mov    0xc(%ebp),%cl
  800c11:	38 08                	cmp    %cl,(%eax)
  800c13:	75 06                	jne    800c1b <memfind+0x1c>
  800c15:	eb 09                	jmp    800c20 <memfind+0x21>
  800c17:	38 08                	cmp    %cl,(%eax)
  800c19:	74 05                	je     800c20 <memfind+0x21>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800c1b:	40                   	inc    %eax
  800c1c:	39 c2                	cmp    %eax,%edx
  800c1e:	77 f7                	ja     800c17 <memfind+0x18>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800c20:	c9                   	leave  
  800c21:	c3                   	ret    

00800c22 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800c22:	55                   	push   %ebp
  800c23:	89 e5                	mov    %esp,%ebp
  800c25:	57                   	push   %edi
  800c26:	56                   	push   %esi
  800c27:	53                   	push   %ebx
  800c28:	8b 55 08             	mov    0x8(%ebp),%edx
  800c2b:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800c2e:	eb 01                	jmp    800c31 <strtol+0xf>
		s++;
  800c30:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800c31:	8a 02                	mov    (%edx),%al
  800c33:	3c 20                	cmp    $0x20,%al
  800c35:	74 f9                	je     800c30 <strtol+0xe>
  800c37:	3c 09                	cmp    $0x9,%al
  800c39:	74 f5                	je     800c30 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800c3b:	3c 2b                	cmp    $0x2b,%al
  800c3d:	75 08                	jne    800c47 <strtol+0x25>
		s++;
  800c3f:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800c40:	bf 00 00 00 00       	mov    $0x0,%edi
  800c45:	eb 13                	jmp    800c5a <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800c47:	3c 2d                	cmp    $0x2d,%al
  800c49:	75 0a                	jne    800c55 <strtol+0x33>
		s++, neg = 1;
  800c4b:	8d 52 01             	lea    0x1(%edx),%edx
  800c4e:	bf 01 00 00 00       	mov    $0x1,%edi
  800c53:	eb 05                	jmp    800c5a <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800c55:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800c5a:	85 db                	test   %ebx,%ebx
  800c5c:	74 05                	je     800c63 <strtol+0x41>
  800c5e:	83 fb 10             	cmp    $0x10,%ebx
  800c61:	75 28                	jne    800c8b <strtol+0x69>
  800c63:	8a 02                	mov    (%edx),%al
  800c65:	3c 30                	cmp    $0x30,%al
  800c67:	75 10                	jne    800c79 <strtol+0x57>
  800c69:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800c6d:	75 0a                	jne    800c79 <strtol+0x57>
		s += 2, base = 16;
  800c6f:	83 c2 02             	add    $0x2,%edx
  800c72:	bb 10 00 00 00       	mov    $0x10,%ebx
  800c77:	eb 12                	jmp    800c8b <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  800c79:	85 db                	test   %ebx,%ebx
  800c7b:	75 0e                	jne    800c8b <strtol+0x69>
  800c7d:	3c 30                	cmp    $0x30,%al
  800c7f:	75 05                	jne    800c86 <strtol+0x64>
		s++, base = 8;
  800c81:	42                   	inc    %edx
  800c82:	b3 08                	mov    $0x8,%bl
  800c84:	eb 05                	jmp    800c8b <strtol+0x69>
	else if (base == 0)
		base = 10;
  800c86:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800c8b:	b8 00 00 00 00       	mov    $0x0,%eax
  800c90:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800c92:	8a 0a                	mov    (%edx),%cl
  800c94:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800c97:	80 fb 09             	cmp    $0x9,%bl
  800c9a:	77 08                	ja     800ca4 <strtol+0x82>
			dig = *s - '0';
  800c9c:	0f be c9             	movsbl %cl,%ecx
  800c9f:	83 e9 30             	sub    $0x30,%ecx
  800ca2:	eb 1e                	jmp    800cc2 <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  800ca4:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800ca7:	80 fb 19             	cmp    $0x19,%bl
  800caa:	77 08                	ja     800cb4 <strtol+0x92>
			dig = *s - 'a' + 10;
  800cac:	0f be c9             	movsbl %cl,%ecx
  800caf:	83 e9 57             	sub    $0x57,%ecx
  800cb2:	eb 0e                	jmp    800cc2 <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  800cb4:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800cb7:	80 fb 19             	cmp    $0x19,%bl
  800cba:	77 13                	ja     800ccf <strtol+0xad>
			dig = *s - 'A' + 10;
  800cbc:	0f be c9             	movsbl %cl,%ecx
  800cbf:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800cc2:	39 f1                	cmp    %esi,%ecx
  800cc4:	7d 0d                	jge    800cd3 <strtol+0xb1>
			break;
		s++, val = (val * base) + dig;
  800cc6:	42                   	inc    %edx
  800cc7:	0f af c6             	imul   %esi,%eax
  800cca:	8d 04 01             	lea    (%ecx,%eax,1),%eax
		// we don't properly detect overflow!
	}
  800ccd:	eb c3                	jmp    800c92 <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800ccf:	89 c1                	mov    %eax,%ecx
  800cd1:	eb 02                	jmp    800cd5 <strtol+0xb3>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800cd3:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800cd5:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800cd9:	74 05                	je     800ce0 <strtol+0xbe>
		*endptr = (char *) s;
  800cdb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800cde:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800ce0:	85 ff                	test   %edi,%edi
  800ce2:	74 04                	je     800ce8 <strtol+0xc6>
  800ce4:	89 c8                	mov    %ecx,%eax
  800ce6:	f7 d8                	neg    %eax
}
  800ce8:	5b                   	pop    %ebx
  800ce9:	5e                   	pop    %esi
  800cea:	5f                   	pop    %edi
  800ceb:	c9                   	leave  
  800cec:	c3                   	ret    
  800ced:	00 00                	add    %al,(%eax)
	...

00800cf0 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  800cf0:	55                   	push   %ebp
  800cf1:	89 e5                	mov    %esp,%ebp
  800cf3:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  800cf6:	83 3d 08 20 80 00 00 	cmpl   $0x0,0x802008
  800cfd:	75 52                	jne    800d51 <set_pgfault_handler+0x61>
		// First time through!	
		// LAB 4: Your code here.

		//int sys_page_alloc(envid_t envid, void *va, int perm)
		r = sys_page_alloc(0, (void*)(UXSTACKTOP - PGSIZE), PTE_U | PTE_W | PTE_P);
  800cff:	83 ec 04             	sub    $0x4,%esp
  800d02:	6a 07                	push   $0x7
  800d04:	68 00 f0 bf ee       	push   $0xeebff000
  800d09:	6a 00                	push   $0x0
  800d0b:	e8 b0 f4 ff ff       	call   8001c0 <sys_page_alloc>
		if (r < 0) {
  800d10:	83 c4 10             	add    $0x10,%esp
  800d13:	85 c0                	test   %eax,%eax
  800d15:	79 12                	jns    800d29 <set_pgfault_handler+0x39>
			panic("sys_page_alloc error : %e\n", r);
  800d17:	50                   	push   %eax
  800d18:	68 64 12 80 00       	push   $0x801264
  800d1d:	6a 24                	push   $0x24
  800d1f:	68 7f 12 80 00       	push   $0x80127f
  800d24:	e8 bb f5 ff ff       	call   8002e4 <_panic>
		}

		// how to know envid, put 0, envid2env will help us to get curenv in syscall
		r = sys_env_set_pgfault_upcall(0, _pgfault_upcall);		
  800d29:	83 ec 08             	sub    $0x8,%esp
  800d2c:	68 bc 02 80 00       	push   $0x8002bc
  800d31:	6a 00                	push   $0x0
  800d33:	e8 18 f5 ff ff       	call   800250 <sys_env_set_pgfault_upcall>
		if (r < 0) {
  800d38:	83 c4 10             	add    $0x10,%esp
  800d3b:	85 c0                	test   %eax,%eax
  800d3d:	79 12                	jns    800d51 <set_pgfault_handler+0x61>
			panic("sys_env_set_pgfault_upcall error : %e\n", r);
  800d3f:	50                   	push   %eax
  800d40:	68 90 12 80 00       	push   $0x801290
  800d45:	6a 2a                	push   $0x2a
  800d47:	68 7f 12 80 00       	push   $0x80127f
  800d4c:	e8 93 f5 ff ff       	call   8002e4 <_panic>
		}
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  800d51:	8b 45 08             	mov    0x8(%ebp),%eax
  800d54:	a3 08 20 80 00       	mov    %eax,0x802008
}
  800d59:	c9                   	leave  
  800d5a:	c3                   	ret    
	...

00800d5c <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  800d5c:	55                   	push   %ebp
  800d5d:	89 e5                	mov    %esp,%ebp
  800d5f:	57                   	push   %edi
  800d60:	56                   	push   %esi
  800d61:	83 ec 10             	sub    $0x10,%esp
  800d64:	8b 7d 08             	mov    0x8(%ebp),%edi
  800d67:	8b 4d 10             	mov    0x10(%ebp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  800d6a:	89 7d f0             	mov    %edi,-0x10(%ebp)
  800d6d:	8b 75 0c             	mov    0xc(%ebp),%esi
  const DWunion dd = {.ll = d};
  800d70:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  800d73:	8b 45 14             	mov    0x14(%ebp),%eax
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  800d76:	85 c0                	test   %eax,%eax
  800d78:	75 2e                	jne    800da8 <__udivdi3+0x4c>
    {
      if (d0 > n1)
  800d7a:	39 f1                	cmp    %esi,%ecx
  800d7c:	77 5a                	ja     800dd8 <__udivdi3+0x7c>
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  800d7e:	85 c9                	test   %ecx,%ecx
  800d80:	75 0b                	jne    800d8d <__udivdi3+0x31>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  800d82:	b8 01 00 00 00       	mov    $0x1,%eax
  800d87:	31 d2                	xor    %edx,%edx
  800d89:	f7 f1                	div    %ecx
  800d8b:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  800d8d:	31 d2                	xor    %edx,%edx
  800d8f:	89 f0                	mov    %esi,%eax
  800d91:	f7 f1                	div    %ecx
  800d93:	89 c6                	mov    %eax,%esi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800d95:	89 f8                	mov    %edi,%eax
  800d97:	f7 f1                	div    %ecx
  800d99:	89 c7                	mov    %eax,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800d9b:	89 f8                	mov    %edi,%eax
  800d9d:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800d9f:	83 c4 10             	add    $0x10,%esp
  800da2:	5e                   	pop    %esi
  800da3:	5f                   	pop    %edi
  800da4:	c9                   	leave  
  800da5:	c3                   	ret    
  800da6:	66 90                	xchg   %ax,%ax
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  800da8:	39 f0                	cmp    %esi,%eax
  800daa:	77 1c                	ja     800dc8 <__udivdi3+0x6c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  800dac:	0f bd f8             	bsr    %eax,%edi
	  if (bm == 0)
  800daf:	83 f7 1f             	xor    $0x1f,%edi
  800db2:	75 3c                	jne    800df0 <__udivdi3+0x94>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  800db4:	39 f0                	cmp    %esi,%eax
  800db6:	0f 82 90 00 00 00    	jb     800e4c <__udivdi3+0xf0>
  800dbc:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800dbf:	39 55 f4             	cmp    %edx,-0xc(%ebp)
  800dc2:	0f 86 84 00 00 00    	jbe    800e4c <__udivdi3+0xf0>
  800dc8:	31 f6                	xor    %esi,%esi
  800dca:	31 ff                	xor    %edi,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800dcc:	89 f8                	mov    %edi,%eax
  800dce:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800dd0:	83 c4 10             	add    $0x10,%esp
  800dd3:	5e                   	pop    %esi
  800dd4:	5f                   	pop    %edi
  800dd5:	c9                   	leave  
  800dd6:	c3                   	ret    
  800dd7:	90                   	nop
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800dd8:	89 f2                	mov    %esi,%edx
  800dda:	89 f8                	mov    %edi,%eax
  800ddc:	f7 f1                	div    %ecx
  800dde:	89 c7                	mov    %eax,%edi
  800de0:	31 f6                	xor    %esi,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800de2:	89 f8                	mov    %edi,%eax
  800de4:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800de6:	83 c4 10             	add    $0x10,%esp
  800de9:	5e                   	pop    %esi
  800dea:	5f                   	pop    %edi
  800deb:	c9                   	leave  
  800dec:	c3                   	ret    
  800ded:	8d 76 00             	lea    0x0(%esi),%esi
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  800df0:	89 f9                	mov    %edi,%ecx
  800df2:	d3 e0                	shl    %cl,%eax
  800df4:	89 45 e8             	mov    %eax,-0x18(%ebp)
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  800df7:	b8 20 00 00 00       	mov    $0x20,%eax
  800dfc:	29 f8                	sub    %edi,%eax

	      d1 = (d1 << bm) | (d0 >> b);
  800dfe:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800e01:	88 c1                	mov    %al,%cl
  800e03:	d3 ea                	shr    %cl,%edx
  800e05:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  800e08:	09 ca                	or     %ecx,%edx
  800e0a:	89 55 ec             	mov    %edx,-0x14(%ebp)
	      d0 = d0 << bm;
  800e0d:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800e10:	89 f9                	mov    %edi,%ecx
  800e12:	d3 e2                	shl    %cl,%edx
  800e14:	89 55 f4             	mov    %edx,-0xc(%ebp)
	      n2 = n1 >> b;
  800e17:	89 f2                	mov    %esi,%edx
  800e19:	88 c1                	mov    %al,%cl
  800e1b:	d3 ea                	shr    %cl,%edx
  800e1d:	89 55 e8             	mov    %edx,-0x18(%ebp)
	      n1 = (n1 << bm) | (n0 >> b);
  800e20:	89 f2                	mov    %esi,%edx
  800e22:	89 f9                	mov    %edi,%ecx
  800e24:	d3 e2                	shl    %cl,%edx
  800e26:	8b 75 f0             	mov    -0x10(%ebp),%esi
  800e29:	88 c1                	mov    %al,%cl
  800e2b:	d3 ee                	shr    %cl,%esi
  800e2d:	09 d6                	or     %edx,%esi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  800e2f:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  800e32:	89 f0                	mov    %esi,%eax
  800e34:	89 ca                	mov    %ecx,%edx
  800e36:	f7 75 ec             	divl   -0x14(%ebp)
  800e39:	89 d1                	mov    %edx,%ecx
  800e3b:	89 c6                	mov    %eax,%esi
	      umul_ppmm (m1, m0, q0, d0);
  800e3d:	f7 65 f4             	mull   -0xc(%ebp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800e40:	39 d1                	cmp    %edx,%ecx
  800e42:	72 28                	jb     800e6c <__udivdi3+0x110>
  800e44:	74 1a                	je     800e60 <__udivdi3+0x104>
  800e46:	89 f7                	mov    %esi,%edi
  800e48:	31 f6                	xor    %esi,%esi
  800e4a:	eb 80                	jmp    800dcc <__udivdi3+0x70>
	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  800e4c:	31 f6                	xor    %esi,%esi
  800e4e:	bf 01 00 00 00       	mov    $0x1,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800e53:	89 f8                	mov    %edi,%eax
  800e55:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800e57:	83 c4 10             	add    $0x10,%esp
  800e5a:	5e                   	pop    %esi
  800e5b:	5f                   	pop    %edi
  800e5c:	c9                   	leave  
  800e5d:	c3                   	ret    
  800e5e:	66 90                	xchg   %ax,%ax

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  800e60:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800e63:	89 f9                	mov    %edi,%ecx
  800e65:	d3 e2                	shl    %cl,%edx

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800e67:	39 c2                	cmp    %eax,%edx
  800e69:	73 db                	jae    800e46 <__udivdi3+0xea>
  800e6b:	90                   	nop
		{
		  q0--;
  800e6c:	8d 7e ff             	lea    -0x1(%esi),%edi
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  800e6f:	31 f6                	xor    %esi,%esi
  800e71:	e9 56 ff ff ff       	jmp    800dcc <__udivdi3+0x70>
	...

00800e78 <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  800e78:	55                   	push   %ebp
  800e79:	89 e5                	mov    %esp,%ebp
  800e7b:	57                   	push   %edi
  800e7c:	56                   	push   %esi
  800e7d:	83 ec 20             	sub    $0x20,%esp
  800e80:	8b 45 08             	mov    0x8(%ebp),%eax
  800e83:	8b 4d 10             	mov    0x10(%ebp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  800e86:	89 45 e8             	mov    %eax,-0x18(%ebp)
  800e89:	8b 75 0c             	mov    0xc(%ebp),%esi
  const DWunion dd = {.ll = d};
  800e8c:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  800e8f:	8b 7d 14             	mov    0x14(%ebp),%edi
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  800e92:	89 45 f0             	mov    %eax,-0x10(%ebp)
  n1 = nn.s.high;
  800e95:	89 f2                	mov    %esi,%edx

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  800e97:	85 ff                	test   %edi,%edi
  800e99:	75 15                	jne    800eb0 <__umoddi3+0x38>
    {
      if (d0 > n1)
  800e9b:	39 f1                	cmp    %esi,%ecx
  800e9d:	0f 86 99 00 00 00    	jbe    800f3c <__umoddi3+0xc4>
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800ea3:	f7 f1                	div    %ecx

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
  800ea5:	89 d0                	mov    %edx,%eax
  800ea7:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  800ea9:	83 c4 20             	add    $0x20,%esp
  800eac:	5e                   	pop    %esi
  800ead:	5f                   	pop    %edi
  800eae:	c9                   	leave  
  800eaf:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  800eb0:	39 f7                	cmp    %esi,%edi
  800eb2:	0f 87 a4 00 00 00    	ja     800f5c <__umoddi3+0xe4>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  800eb8:	0f bd c7             	bsr    %edi,%eax
	  if (bm == 0)
  800ebb:	83 f0 1f             	xor    $0x1f,%eax
  800ebe:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800ec1:	0f 84 a1 00 00 00    	je     800f68 <__umoddi3+0xf0>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  800ec7:	89 f8                	mov    %edi,%eax
  800ec9:	8a 4d ec             	mov    -0x14(%ebp),%cl
  800ecc:	d3 e0                	shl    %cl,%eax
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  800ece:	bf 20 00 00 00       	mov    $0x20,%edi
  800ed3:	2b 7d ec             	sub    -0x14(%ebp),%edi

	      d1 = (d1 << bm) | (d0 >> b);
  800ed6:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800ed9:	89 f9                	mov    %edi,%ecx
  800edb:	d3 ea                	shr    %cl,%edx
  800edd:	09 c2                	or     %eax,%edx
  800edf:	89 55 f0             	mov    %edx,-0x10(%ebp)
	      d0 = d0 << bm;
  800ee2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800ee5:	8a 4d ec             	mov    -0x14(%ebp),%cl
  800ee8:	d3 e0                	shl    %cl,%eax
  800eea:	89 45 f4             	mov    %eax,-0xc(%ebp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  800eed:	89 f2                	mov    %esi,%edx
  800eef:	d3 e2                	shl    %cl,%edx
	      n0 = n0 << bm;
  800ef1:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800ef4:	d3 e0                	shl    %cl,%eax
  800ef6:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  800ef9:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800efc:	89 f9                	mov    %edi,%ecx
  800efe:	d3 e8                	shr    %cl,%eax
  800f00:	09 d0                	or     %edx,%eax

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  800f02:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  800f04:	89 f2                	mov    %esi,%edx
  800f06:	f7 75 f0             	divl   -0x10(%ebp)
  800f09:	89 d6                	mov    %edx,%esi
	      umul_ppmm (m1, m0, q0, d0);
  800f0b:	f7 65 f4             	mull   -0xc(%ebp)
  800f0e:	89 55 e8             	mov    %edx,-0x18(%ebp)
  800f11:	89 c1                	mov    %eax,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800f13:	39 d6                	cmp    %edx,%esi
  800f15:	72 71                	jb     800f88 <__umoddi3+0x110>
  800f17:	74 7f                	je     800f98 <__umoddi3+0x120>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  800f19:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800f1c:	29 c8                	sub    %ecx,%eax
  800f1e:	19 d6                	sbb    %edx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
  800f20:	8a 4d ec             	mov    -0x14(%ebp),%cl
  800f23:	d3 e8                	shr    %cl,%eax
  800f25:	89 f2                	mov    %esi,%edx
  800f27:	89 f9                	mov    %edi,%ecx
  800f29:	d3 e2                	shl    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
  800f2b:	09 d0                	or     %edx,%eax
  800f2d:	89 f2                	mov    %esi,%edx
  800f2f:	8a 4d ec             	mov    -0x14(%ebp),%cl
  800f32:	d3 ea                	shr    %cl,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  800f34:	83 c4 20             	add    $0x20,%esp
  800f37:	5e                   	pop    %esi
  800f38:	5f                   	pop    %edi
  800f39:	c9                   	leave  
  800f3a:	c3                   	ret    
  800f3b:	90                   	nop
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  800f3c:	85 c9                	test   %ecx,%ecx
  800f3e:	75 0b                	jne    800f4b <__umoddi3+0xd3>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  800f40:	b8 01 00 00 00       	mov    $0x1,%eax
  800f45:	31 d2                	xor    %edx,%edx
  800f47:	f7 f1                	div    %ecx
  800f49:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  800f4b:	89 f0                	mov    %esi,%eax
  800f4d:	31 d2                	xor    %edx,%edx
  800f4f:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800f51:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800f54:	f7 f1                	div    %ecx
  800f56:	e9 4a ff ff ff       	jmp    800ea5 <__umoddi3+0x2d>
  800f5b:	90                   	nop
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
  800f5c:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  800f5e:	83 c4 20             	add    $0x20,%esp
  800f61:	5e                   	pop    %esi
  800f62:	5f                   	pop    %edi
  800f63:	c9                   	leave  
  800f64:	c3                   	ret    
  800f65:	8d 76 00             	lea    0x0(%esi),%esi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  800f68:	39 f7                	cmp    %esi,%edi
  800f6a:	72 05                	jb     800f71 <__umoddi3+0xf9>
  800f6c:	3b 4d f0             	cmp    -0x10(%ebp),%ecx
  800f6f:	77 0c                	ja     800f7d <__umoddi3+0x105>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  800f71:	89 f2                	mov    %esi,%edx
  800f73:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800f76:	29 c8                	sub    %ecx,%eax
  800f78:	19 fa                	sbb    %edi,%edx
  800f7a:	89 45 f0             	mov    %eax,-0x10(%ebp)

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
  800f7d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  800f80:	83 c4 20             	add    $0x20,%esp
  800f83:	5e                   	pop    %esi
  800f84:	5f                   	pop    %edi
  800f85:	c9                   	leave  
  800f86:	c3                   	ret    
  800f87:	90                   	nop
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  800f88:	8b 55 e8             	mov    -0x18(%ebp),%edx
  800f8b:	89 c1                	mov    %eax,%ecx
  800f8d:	2b 4d f4             	sub    -0xc(%ebp),%ecx
  800f90:	1b 55 f0             	sbb    -0x10(%ebp),%edx
  800f93:	eb 84                	jmp    800f19 <__umoddi3+0xa1>
  800f95:	8d 76 00             	lea    0x0(%esi),%esi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800f98:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  800f9b:	72 eb                	jb     800f88 <__umoddi3+0x110>
  800f9d:	89 f2                	mov    %esi,%edx
  800f9f:	e9 75 ff ff ff       	jmp    800f19 <__umoddi3+0xa1>
